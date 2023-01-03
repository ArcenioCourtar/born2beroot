#!/bin/bash
# Above line is an interpretter directive.
# Makes sure that it runs the instruction through bash.

# Print the OS version, kernel version, and the architecture type,
# Filtering the necessary fields from hostnamectl.
# Or just use uname --all but that looks terrible
ARCH=`hostnamectl | awk '
NR==7{
        $1=$2="";print $0","
}NR==8{
        $1="";print $0","
}NR==9{
        $1="";print $0
}'`

# Use lscpu to get all the necessary CPU information
# grep the first instance of "CPU(s)" and display the number
PCPU=`lscpu | grep "CPU(s): " -m 1 | awk '{print $2}'`

# Readout cpuinfo and grep the number of times "processor"
# appears in a line. Each CPU will result in one instance.
# You can also just use "nproc --all".
# The number of pCPUs and vCPUs are essentially the same in this case.
VCPU=`cat /proc/cpuinfo | grep processor | wc -l`

# Display the available and used memory and format it using awk
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
# Note that logging in as non-root user and then using "su" does not add root as a user
USRS=`who | awk '{print $1}' | sort -u | wc -l`

# hostname -I displays the host's IP address. The awk statement removes the trailing
# space that's there for some reason.
IPAD=`hostname -I | awk '{$1=$1;print}'`

# The MAC address is located behind the link/ether line.
# grep and print what comes after.
MACA=`ip a | grep link/ether | awk '{print $2}'`

# Count the number of times sudo has ben used by counting the number of lines
# in the log file.
# I'm not reading the contents of auth.log becaue
# those log files get rotated out on a weekly basis.
SUCO=`cat /var/log/sudo/sudo.log | wc -l | awk '{print ($1/2)}'`

wall $'#OS, Kernel, Arch:' $ARCH \
$'\n#CPU physical: ' $PCPU \
$'\n#CPU virtual: ' $VCPU \
$'\n#Memory usage: ' $MEM \
$'\n#Disk Usage: ' $DISK \
$'\n#CPU load: ' $LOAD \
$'\n#Last boot: ' $BOOT \
$'\n#LVM use: ' $LVMA \
$'\n#TCP connections: ' $TCPA \
$'\n#Users logged in: ' $USRS \
$'\n#IP address, MAC addr:' $IPAD, $MACA \
$'\n#sudo count: ' $SUCO