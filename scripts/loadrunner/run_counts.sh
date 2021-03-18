dremio_host=192.168.0.21
query_dir="../../queries"
user_name="dremio"
#Assumes local.pwd exists in /home/dremio. Alternatively the password can be entered explicitly in this file
pwd=$(cat ../../../local.pwd) 

# Capture output of script
NOW=$(date +%Y%m%d%H%M%S)
log_file="../../logs/dremio-load-tester-counts-$NOW.log"

echo "Started query_counts with params:  username="$user_name"  query_dir="$query_dir 2>&1 | tee -a $log_file

sh ../../apache-jmeter-5.1.1/bin/jmeter  \
  -n                                                     \
  -t ../../scripts/loadrunner/query_counts.jmx   \
  -Jdremio_host=$dremio_host                             \
  -Jquery_dir=$query_dir                                 \
  -Jbatch_id=`date +%s`                                  \
  -Jusername=$user_name                                \
  -Jpassword=$pwd 2>&1 | tee -a $log_file

