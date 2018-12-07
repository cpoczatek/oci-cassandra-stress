echo "#########################"
echo "### Running test.sh"
echo "#########################"

#echo "Sleeping 4 min before start..."
#sleep 4m

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

#######################################################
######################### Java ########################
#######################################################
echo "Installing Oracle Java 8 JDK..."
wget -O ~/jdk8.rpm -N --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm
yum -y localinstall ~/jdk8.rpm

#######################################################
####################### DataStax ######################
#######################################################

sudo yum install libaio

echo "[datastax]
name = DataStax Repository
baseurl=https://datastax%40oracle.com:*9En9HH4j^p4@rpm.datastax.com/enterprise
enabled=1
gpgcheck=0" > /etc/yum.repos.d/datastax.repo

yum -y install dse-full-6.0.4-1
