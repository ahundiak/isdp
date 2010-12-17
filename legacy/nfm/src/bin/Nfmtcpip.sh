XNSDIR="/usr/lib/nodes"

if [ ! -d ${XNSDIR} ]; then mkdir -p ${XNSDIR}; fi
if [ ! -d ${XNSDIR} ]; then echo Cannot create ${XNSDIR}; exit 1; fi

if [ ! -d ${XNSDIR}/heard ]; then mkdir -p ${XNSDIR}/heard; fi
if [ ! -d ${XNSDIR}/heard ]; then echo Cannot create ${XNSDIR}/heard; exit 1; fi

if [ ! -d ${XNSDIR}/owned ]; then mkdir -p ${XNSDIR}/owned; fi
if [ ! -d ${XNSDIR}/owned ]; then echo Cannot create ${XNSDIR}/owned; exit 1; fi

if [ ! -d ${XNSDIR}/local ]; then mkdir -p ${XNSDIR}/local; fi
if [ ! -d ${XNSDIR}/local ]; then echo Cannot create ${XNSDIR}/local; exit 1; fi

#  Create template file

nodename=`uname -n`
echo "Nodename: $nodename" > /usr/lib/nodes/local/template

#  Create owned/node file

NODEFILE="/usr/lib/nodes/owned/$nodename"

netaddr=`netaddr`
xnsaddr=`echo $netaddr | cut -c1-26`
tcpaddr=`netaddr | grep "Internet Address:" | cut -f2 -d":"` 
sysid=`uname -srv | cut -f1 -d" "`
restid=`uname -srv | cut -f2-10 -d" "`

echo "Address: $xnsaddr" > $NODEFILE
echo "tcp_address: $tcpaddr" >> $NODEFILE
echo "Nodename: $nodename" >> $NODEFILE

# Check if the system is CLIX, then add NETMAP_info
# For others add UNIX  System 
if test  "X$sysid"=XCLIX
then
	echo "NETMAP_info: UNIX System V rel $restid" >> $NODEFILE
else
	echo "NETMAP_info: UNIX System" >> $NODEFILE
fi
