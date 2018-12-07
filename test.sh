#######################################################"
################### Run test ##########################"
#######################################################"

echo "Running test..."
mkdir results

cqlsh $(echo $nodes | tr ',' ' ' | awk '{print $1}') -e "show version; select * from system.peers;" > results/dse_version.txt

echo "some test results" > results/log

echo "Uploading results..."
for file in $(ls results); do
  curl -X PUT --data-binary "@./results/$file" "$par$test_name/$file"
done;

echo "Done"
