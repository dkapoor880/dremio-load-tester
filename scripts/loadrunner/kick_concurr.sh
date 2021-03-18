dremio_host=$1
run_as_user=$2
pwd=$3
query_dir=$4
log_file=$5
num_executors=$6
test_description=$7
num_threads=$8
queries_per_thread=$9

# NOTE: query_dir is relative to where this script is running, so typically it's value will be ../../queries

echo "Started with params:  run_as_user="$run_as_user"  query_dir="$query_dir"  num_threads="$num_threads"  queries_per_thread="$queries_per_thread" test_description="$test_description 2>&1 | tee -a $log_file

## kinit <<< $pwd

## hdfs dfs -rm -r -skipTrash /tmp/fact_smoke_tests/concurrent/*

sh ../../apache-jmeter-5.1.1/bin/jmeter  \
  -n                                                     \
  -t ../../scripts/loadrunner/concurrent_repeatable.jmx   \
  -Dorg.slf4j.simpleLogger.log.org.apache.jmeter.samplers.SampleEvent=ERROR \
  -Dorg.slf4j.simpleLogger.log.org.apache.jmeter.JMeter=ERROR \
  -Dorg.slf4j.simpleLogger.log.cdjd.com.dremio=ERROR     \
  -Dorg.slf4j.simpleLogger.log.org.apache.jmeter.engine.util.CompoundVariable=ERROR \
  -Jdremio_host=$dremio_host                             \
  -Jquery_dir=$query_dir                                 \
  -Jnum_executors=$num_executors                         \
  -Jtest_description="$test_description"                   \
  -Jbatch_id=`date +%s`                                  \
  -Jnum_users=$num_threads                               \
  -Jqueries_per_user=$queries_per_thread                 \
  -Jusers_ramp_time=1                                    \
  -Jusername=$run_as_user                                \
  -Jpassword=$pwd 2>&1 | tee -a $log_file

