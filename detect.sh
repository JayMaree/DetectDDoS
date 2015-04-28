#!/bin/bash
#===============================================================================================
#   System Required:  CentOS 6,7, Debian, Ubuntu
#   Description:  Detect if your webserver is being DDoSed
#	  Extra's:
#   Author: Jay Maree <pm@me>
#   Intro:  github.com/jaymaree
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root :("
    echo "Please try running this command again as root user"
    exit 1
fi

#set variables
SYNCREC=`netstat -n -p | grep SYN_REC | sort -u`
NUMBERCONN=`netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n|wc -l`
ESTASH=`netstat -plan|grep :80|awk {'print $5'}|cut -d: -f 1|sort|uniq -c|sort -nk 1`

function printMessage() {
    echo -e "\e[1;37m# $1\033[0m"
}

function ddosdir() {
    mkdir /tmp/ddos
}

function tcpdump() {
  # just a simple one
  # let's check for udp flooding
  timeout 10s tcpdump -n udp > /tmp/ddos/udpflood.log
  # SYN
  timeout 10s tcpdump -n tcp |grep S > /tmp/ddos/synflood.log
  # ICMP
  timeout 10s tcpdump -n icmp > /tmp/ddos/icmpflood.log
}

function netstats() {
  # TOP IP addresses
  netstat -n|grep :80|cut -c 45-|cut -f 1 -d ':'|sort|uniq -c|sort -nr|more > /tmp/ddos/topIP.log
  # This will display all active connections to the server
  netstat -an | grep :80 | sort > /tmp/ddos/activeConn.log
}

clear

echo ""
echo "---------------------------------------------------------------"
echo "Are some kiddies DDoSing your servers? Let's find out!"
echo "  Version: 0.1"
echo "  Needs: none"
echo "  "
echo "  Some current statistics:"
echo "  SYN_REC Connections: $SYNREC"
echo "  Total connections: $NUMBERCONN"
echo "  Established Connections: $ESTASH"
echo "---------------------------------------------------------------"
echo ""
printMessage "Starting the analysis right now..."
ddosdir
printMessage "Executing the tcpdump commands..."
tcpdump
printMessage "Executing the netstat commands..."
netstats


printMessage "I have created the analyse logs in the following dir /tmp/ddos/"

echo ""
