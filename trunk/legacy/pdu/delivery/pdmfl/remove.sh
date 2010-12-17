# INTERGRAPH Delivery Procedures
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
# Date: 08-AUG-1994
# Calling Seq:  remove.sh [user directory for ip32 if not /usr.  e.g. /usr2]
################################################################################
LANGUAGES="german french"

PDU_CPU=`uname -a | awk '{print $1}'`
if [ "${PDU_CPU}" = "sunos" ]
then
  INGRHOME=${INGRHOME:="/opt/ingr"}
elif [ "${PDU_CPU}" = "irix" ]
then
  INGRHOME=${INGRHOME:="/var/opt/ingr"}
else
  INGRHOME=${INGRHOME:="/usr/ip32"}
fi

INGRHOME=${INGRHOME%%:*}
pd=${INGRHOME}/ingrconfig

dir=`grep "FLS_PDM" $pd | awk -F# '{print $6}'` 
prod_path=${dir}

echopath ()
{
  pdata=$2
  me=$3
  if [ -f $pdata ]
  then
    path=`egrep "$1" $pdata | awk -F# '{print $6}'`
  else
    echo $me: $pdata does not exist
    exit 1
  fi
  if [ -d "$path" ]
  then
    echo $path
    exit 0
  else
    echo $me: $path no path for $1
    exit 1
  fi
}
test_id=`id | cut -c5`
if [ $test_id -eq 0 ]
then
  if [ -r ${dir}/product.def ]
  then
    . ${dir}/product.def
    echo "$0 -- $IDname ($IDnumber)"
    ID=`echo $IDname | sed 's/[Ii]_//p' | tr '[a-z]' '[A-Z]'`
    Idname=`echo $ID | cut -c1-1``echo $ID | cut -c2- | tr '[A-Z]' '[a-z]'`
    idname=`echo $ID | tr '[A-Z]' '[a-z]'`
    echo "Key in directory path of product to be removed: [$prod_path] \c"
    read dir; : ${dir:=$prod_path}
    if [ ! -d "${dir}" ]
    then
      echo "\n$0: directory ${dir} not found.\n"
    else
      echo "Remove $IDname product from ${dir}? [y] \c"
      read answer; : ${answer:=y}
      answer=`echo $answer | cut -c1-1 | tr '[A-Z]' '[a-z]'`
      if [ "$answer" = "y" ]
      then
#       RESTORE ENGLISH 
        PROD="I_PDU"
        path=`echopath ${PROD} ${pd} $0`
        if [ -d "${path}/config/english" ]
        then
          echo "Restoring PDU English message files"
          cd ${path}/config/english
          compress -d < ${dir}/pdu_engint.p | cpio -imud  2>/dev/null
          echo "Restoring PDU English HELP files"
          if [ -f "${dir}/pdu_enghelp.p" ]
          then  
           cd ${path}/config/english
           compress -d < ${dir}/pdu_enghelp.p | cpio -imud  2>/dev/null
          fi
        fi
        PROD="I_PDM"
        path=`echopath ${PROD} ${pd} $0`
        if [ -d "${path}/config" ]
        then
          echo "Restoring PDM English Initialize files"
          cd ${path}/config
          compress -d < ${dir}/pdm_enginit.p | cpio -imud  2>/dev/null
        fi

#       REMOVE FLS DIRECTORY 
        cd ${dir}/..
        rm -rf ${dir}
      fi
    fi
    echo "$0 -- $IDname ($IDnumber) operation complete."
  else
    echo "\n$0: cannot find product.def\n"
  fi
else
  echo "\n$0: must be root to execute\n"
fi
exit 0
