QueryCollector
==============
The querycollector folder and the collection of scripts within it will need to be installed on the Dremio Coordinator node, in the dremio user's home directory.
gather_queries.sh is the main script that users will execute. 

This script is responsible for performing the following actions:
- Copying the queries.json file(s) for the current day and any archived queries.json files for a specified number of days in the past locally to the querycollector.
- Scrub the files to ensure that the queryText element contains no more than 32000 characters (the Dremio limit on field size) 
- Write the resulting data out to a scrubbed sub-folder.
- Copy the scrubbed files into the chosen data lake storage location (s3/adls/hdfs)

# Usage
./gather_queries.sh <storage_type> <storage_path> <num_archive_days>