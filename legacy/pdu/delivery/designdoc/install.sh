#
# Copyright Intergraph Corporation
#
# I/PDU Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

\cd ${UNIXDIR}
LOGFILE=${UNIXDIR}/log

TOTAL=900

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

#
# Get responses to prompts
#
echo
   answer=`getanswer "Install the PDU/PDM Design Documentation locally (y/n) ? " "y"`

if [ "$answer" != "n" ]
then
  echo

  echo Installing DESIGNDOC in $UNIXDIR
  echo Installing DESIGNDOC in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

    getfile designdoc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

exit 0
