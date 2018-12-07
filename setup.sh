echo "#########################"
echo "### Running test.sh"
echo "#########################"

echo "Sleeping 4 min before start..."
sleep 4m
echo "Nodes passed: " $nodes

#######################################################"
################# Turn Off the Firewall ###############"
#######################################################"
echo "Turning off the Firewall..."

echo "" > /etc/iptables/rules.v4
echo "" > /etc/iptables/rules.v6

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

#######################################################"
################### Run test ##########################"
#######################################################"

echo "Done"
