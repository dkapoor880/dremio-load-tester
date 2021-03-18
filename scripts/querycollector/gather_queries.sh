# This script will automatically copy the current queries.json from Dremio into ./dremio_queries/,
# as well as archived queries.json files going back the specified number of days.
# It will then scrub the files to ensure queryText is no longer than 32k characters and will write
# the resulting files into a scrubbed sub-folder.
# Finally, the scrubbed files are transferred into S3/ADLS/HDFS depending on the storage_type specified.
#Input: 
#	storage_type = s3/adls/hdfs 
#	storage_path = path on storage to results folder e.g s3://mybucket
#	num_archive_days = the number of days of archived queries.json files to also copy and scrub.

# USER NEEDS TO ENSURE DREMIO_LOG_DIR IS SET CORRECTLY IN THIS FILE PRIOR TO EXECUTION
DREMIO_LOG_DIR="/var/log/dremio"
storage_type=$1
storage_path=$2
num_archive_days=$3
today_date=`date '+%Y-%m-%d'`
processing_date=$today_date
is_gz_copied=0
count_today_archives=0

rm -f ./dremio_queries/queries*.json
rm -f ./dremio_queries/scrubbed/header.queries*.json
rm -f ./dremio_queries/scrubbed/chunks.queries*.json
# Copy the current queries.json file
echo "Copying current queries.json"
cp $DREMIO_LOG_DIR/queries.json ./dremio_queries

# Copy any archive file generated for today and for however many specified archive days
if [ "$num_archive_days" == "" ]
then
	num_archive_days=0
fi

for ((i=0;i<=$num_archive_days;i++)) 
do
  # Check if there are any archive files for the current processing date
  for f in $DREMIO_LOG_DIR/archive/queries.$processing_date.*json.gz; do 
    # If there are then copy them
    if [ -f "$f" ]; then
      echo "Copying archive file for $processing_date: $f"
	  cp $f ./dremio_queries
	  is_gz_copied=1
	  
	  # if we are processing today's files, count how many archives we have
      if [ $i == 0 ]; then
		count_today_archives=$(($count_today_archives + 1))
		echo "Count of today's archives=$count_today_archives"
	  fi
	fi
  done
  
  processing_date=$(date -I -d "$processing_date - 1 day")  
done

if [ $is_gz_copied == 1 ]; then
  echo "Unzipping archived files"
  # unzip any archived queries.json files into the current folder
  gunzip ./dremio_queries/queries*.gz
fi

echo "Scrubbing files, splitting query text into 4096 byte chunks"
python scrub-queries-json.py ./dremio_queries ./dremio_queries/scrubbed

#Renaming today's scrubbed files to incorporate the date and the next available index number for archive files
echo "Renaming today's header.queries.json to header.queries.$today_date.$count_today_archives.json"
mv ./dremio_queries/scrubbed/header.queries.json ./dremio_queries/scrubbed/header.queries.$today_date.$count_today_archives.json

echo "Renaming today's chunks.queries.json to chunks.queries.$today_date.$count_today_archives.json"
mv ./dremio_queries/scrubbed/chunks.queries.json ./dremio_queries/scrubbed/chunks.queries.$today_date.$count_today_archives.json

if [ "$storage_type" == "s3" ]
then
	echo "Copying scrubbed header files to S3"
	for s3_scrubbed in ./dremio_queries/scrubbed/header.queries*.json; do
	  aws s3 cp $s3_scrubbed $storage_path/results/
	done
	echo "Copying scrubbed chunks files to S3"
	for s3_scrubbed in ./dremio_queries/scrubbed/chunks.queries*.json; do
	  aws s3 cp $s3_scrubbed $storage_path/chunks/
	done
elif [ "$storage_type" == "adls" ]
then
	echo "Copying scrubbed header files to ADLS"
	for adls_scrubbed in ./dremio_queries/scrubbed/header.queries*.json; do
      adls_filename=$(basename $adls_scrubbed)
      az storage copy -s $adls_scrubbed -d $storage_path/results/$adls_filename
	done
	echo "Copying scrubbed chunks files to ADLS"
	for adls_scrubbed in ./dremio_queries/scrubbed/chunks.queries*.json; do
      adls_filename=$(basename $adls_scrubbed)
      az storage copy -s $adls_scrubbed -d $storage_path/chunks/$adls_filename
	done
elif [ "$storage_type" == "hdfs" ]
then
	echo "Copying scrubbed header files to to HDFS"
	for hdfs_scrubbed in ./dremio_queries/scrubbed/header.queries*.json; do
		hdfs dfs -copyFromLocal -f $hdfs_scrubbed $storage_path/results/
	done
	echo "Copying scrubbed files to to HDFS"
	for hdfs_scrubbed in ./dremio_queries/scrubbed/chunks.queries*.json; do
		hdfs dfs -copyFromLocal -f $hdfs_scrubbed $storage_path/chunks/
	done
	
	hdfs dfs -chmod 666 $storage_path/*.json
else
	echo "Unknown storage type "$storage_type", files will remain local and will need manually copying"
fi

echo "Complete"
