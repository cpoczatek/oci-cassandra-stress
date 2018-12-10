#######################################################"
################### Run test ##########################"
#######################################################"

echo "Running test..."
mkdir results

client=$(hostname)
echo $client > results/client_info.txt
echo $(hostname -I) >> results/client_info.txt
echo $(curl icanhazip.com) >> results/client_info.txt
echo $(curl -L http://169.254.169.254/opc/v1/instance) > results/metadata.json

cqlsh $(echo $nodes | tr ',' ' ' | awk '{print $1}') -e "show version; select * from system.peers;" > results/dse_info.txt

echo "some test results" > results/log

echo "Uploading results..."
for file in $(ls results); do
  curl -X PUT --data-binary "@./results/$file" "$par$test_name/$client/$file"
done;

echo "Done"
