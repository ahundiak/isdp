#
# Copyright Intergraph Corporation
#
# I/PDU Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

TOTAL=500

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

#
# Get responses to prompts
#

   echo
   echo MODELDBG is a model image linked with special debugging tools
   echo
   echo WARNING:
   echo
   echo This version of MODELDBG requires you to have the same version   
   echo of model already downloaded and will overwrite your current Model 
   echo image.
   echo
   echo The standard MODELDBG image equires approximately ${TOTAL} blocks.
   answer=`getanswer "Install the MODELDBG image locally (y/n) ? " "y"`

   echo 
   SOURCEDIR=`getanswer "Enter the MODEL product patch. " "/usr/ip32/model"`

\cd ${SOURCEDIR}
LOGFILE=${SOURCEDIR}/log

if [ "$answer" = "y" ]
then
  echo
  echo Installing MODELDBG in $SOURCEDIR/bin
  echo Installing MODELDBG in $SOURCEDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

    getfile model.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chmod 777 'find $SOURCEDIR/bin/Model -print'
  fi

exit 0
