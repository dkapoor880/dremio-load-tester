dremio_host=192.168.0.21
num_executors=4
#test_description must be a single-line description inside double-quotes
test_description="test"
query_dir="../../queries"
user_name="dremio"
#Assumes local.pwd exists in /home/dremio. Alternatively the password can be entered explicitly in this file
pwd=$(cat ../../../local.pwd) 

# Capture output of script
NOW=$(date +%Y%m%d%H%M%S)
log_file="../../logs/dremio-load-tester-$NOW.log"

echo "1 user, 150 queries"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 1 150
echo "================================================================="

echo "5 users, 30 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 5 30
echo "================================================================="

echo "10 users, 30 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 10 30
echo "================================================================="

echo "20 users, 30 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 20 30
echo "================================================================="

echo "30 users, 30 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 30 30
echo "================================================================="

echo "40 users, 30 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 40 30
echo "================================================================="

echo "50 users, 20 queries each"
./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 50 20
echo "================================================================="

##echo "50 users, 30 queries each"
##./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 50 30
##echo "================================================================="

##echo "50 users, 40 queries each"
##./kick_concurr.sh $dremio_host $user_name $pwd $query_dir $log_file $num_executors "$test_description" 50 40
##echo "================================================================="

