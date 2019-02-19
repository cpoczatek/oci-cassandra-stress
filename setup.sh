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
#echo "Installing Oracle Java 8 JDK..."
#wget -O ~/jdk8.rpm -N --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#  https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm
#yum -y localinstall ~/jdk8.rpm

echo "Installing openjdk Java 8 JDK..."
yum -y install java-1.8.0-openjdk

#######################################################
####################### DataStax ######################
#######################################################

sudo yum install libaio

echo "Installing Cassandra..."

# replace 311x with 21x for 2.1.x
echo "[cassandra]
name=Apache Cassandra
baseurl=https://www.apache.org/dist/cassandra/redhat/311x/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.apache.org/dist/cassandra/KEYS" | \
  sudo tee -a /etc/yum.repos.d/cassandra.repo
sudo yum -y install cassandra
