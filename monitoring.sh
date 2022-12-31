#!/bin/bash
# Above line is an interpretter directive.
# Makes sure that it runs the instruction through bash.

ARCH=`hostnamectl | grep "Operating System"`

# Count the amount of time the word "processor" gets found by grep
# Each processor in cpuinfo will add one instance of this word to cpuinfo
PCPU=`cat /proc/cpuinfo | grep processor | wc -l`
VCPU=`cat /proc/cpuinfo | grep processor | wc -l`
MEM=`free -m | awk '
NR==2{
        printf "%s/%s MB (%.2f%%)", $3, $2, $3*100/$2
}'`

# Add all the values of column 3 and 2 and print out the resulting values
# Use the NR!=1 condition to skip over the first line which are just chars
DISK=`df -BM | awk '
NR!=1{
        {SUMUSED+=$3}{SUMTOT+=$2}
}END{
        printf "%d/%d MB (%.2f%%)", SUMUSED, SUMTOT, SUMUSED/SUMTOT*100
}'`

# Add all values in the CPU% column, print out the total
LOAD=`top -bn1 | awk '
NR>7{
        SUMUSED+=$9
}END{
        printf "%.1f%%", SUMUSED
}'`

# Cut off the "system boot" text, just display values in column 3 & 4
BOOT=`who -b | awk '{print $3" "$4}'`

# grep all lines which contain the word "lvm"
# If grep returns lines lvm is in use, otherwise it's not
LVMA=`lsblk | grep lvm | awk '
END{
        if (NR!=0){
                print "yes";exit;
        }{
                print "no"
        }
}'`
# Display all TCP connections, filter out the established ones, count them
TCPA=`netstat -an | grep ESTABLISHED | wc -l`
# Check who's logged in, grab just the usernames, remove duplicates, count
USRS=`who | awk '{print $1}' | sort -u | wc -l`

IPAD=`hostname -I`
MACA=`ip a | grep link/ether | awk '{print $2}'`
SUCO=test

wall $'#Architecture: ' $ARCH \
$'\n#CPU physical: ' $PCPU \
$'\n#CPU virtual: ' $VCPU \
$'\n#Memory usage: ' $MEM \
$'\n#Disk Usage: ' $DISK \
$'\n#CPU load: ' $LOAD \
$'\n#Last boot: ' $BOOT \
$'\n#LVM use: ' $LVMA \
$'\n#TCP connections: ' $TCPA \
$'\n#Users logged in: ' $USRS \
$'\n#IP address: ' $IPAD $'MAC addr: ' $MACA \
$'\n#sudo count: ' $SUCO