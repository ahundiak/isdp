#
# This file should be executed in the current shell by users of
# the MODEL development platform.
#
# HISTORY
#
# 06 Jun 1989   jBk Re-added definition of EMS shell variable.
#
#                   Enhanced echopath function to ignore lines in
#                   product_data file which begin with # and to
#                   try to handle multiple product_data entries
#                   for a particular product.
#
#                   Moved exportations of assigned variables to
#                   their respective assignments.

# echopath - extract the path for a module from the product data file

function echopath {
    noerror=$1
    if [ $noerror = noerror ]
    then
        shift
    fi
    item=$1
    pdata=$2
    me=$3

    path=`egrep -v '^#' $pdata | awk '/ '$item' / {print $5}' | sort -u`

    if [ -d "$path" ]
    then
        echo $path
        exit 0
    else
        set blap $path
        if [ $# -gt 2 ]
        then
            echo $me:  found more than one path for $item: 1>&2
            for p in $path
            do
                echo \\t$p 1>&2
            done
        else
            if [ $noerror != noerror ]
            then
                echo $me: \"$path\" no path for $item 1>&2
            fi
        fi
        exit 1
    fi
}

if [ $# != 0 ]
then
    if [ "$1" = "-d" ]
    then
        export LDSWITCHES="${LDSWITCHES} -u _dload"
    fi
fi

#   OM_VALIDATE_OS is defined as 1 to cause object space
#   validation by OM. To prevent object space validation, change
#   the definition to 0 or remove the definition all together.
#
OM_VALIDATE_OS=1

#
# Get the defintions for BSPMATH, EXNUC, GRNUC, MODEL and EMS
# from the product data file unless they have been previously
# defined.
#
TARGET_OS=`uname -s`

case ${TARGET_OS} in
CLIX)
   export INGRHOME=${INGRHOME:-/usr/ip32}
;; # End of CLIX
SunOS)
   OSver="$(uname -r | cut -c1-3)"
   case $OSver in
   4.1)
     export INGRHOME=${INGRHOME:-/usr/ip32}
   ;;
   5.[1-9])
     export INGRHOME=${INGRHOME:-/opt/ingr}
   ;;
   *)
     echo
     echo "Unsupported SunOS version $OSver"
     echo
     exit 1
     ;;
   esac
;; # End of SunOS
IRIX)
   OSver="$(uname -r | cut -c1)"
   case $OSver in
   5)
     export INGRHOME=${INGRHOME:-/var/opt/ingr}
     ;;
   *)
     echo
     echo "Unsupported IRIX version $OSver"
     echo
     exit 1
     ;;
   esac
;; # End of IRIX
*)
   echo
   echo "Unknown TARGET Operation System \"$TARGET_OS\""
   echo
   exit 1
;;
esac  # End of TARGET_OS case

if [ "${BS}" = "" ]
then
    export BS=`echopath I\\\/BSPMATH $INGRHOME/product_data $0`
fi

if [ "${EXNUC}" = "" ]
then
    export EXNUC=`echopath I\\\/EXNUC $INGRHOME/product_data $0`
fi

if [ "${GRNUC}" = "" ]
then
    export GRNUC=`echopath I\\\/GRNUC $INGRHOME/product_data $0`
fi

if [ "${MODEL}" = "" ]
then
    export MODEL=`echopath I\\\/MODEL $INGRHOME/product_data $0`
fi

if [ "${EMS}" = "" ]
then
    export EMS=`echopath noerror I\\\/EMS $INGRHOME/product_data $0`
fi

#
# Derive OM, PDU, PDM, HLINE, from EXNUC, GRNUC, and MODEL
#
if [ "${OM}" = "" ]
then
    export OM=$EXNUC/om
fi

if [ "${PDU}" = "" ]
then
    export PDU=${GRNUC}
fi

if [ "${PDM}" = "" ]
then
    export PDM=${PDU}
fi

export INGR=`dirname ${MODEL}`

if [ "${HLINE}" = "" ]
then
    export HLINE=${MODEL}
fi

if [ "${makeems}" = "" -o ! -f ${MODEL}/${makeems} ]
then
    export makeems=makeems
fi

#
# The following defines are used by COB
#
COBCPPOPT="-I$EXNUC/include -I$GRNUC/include -I$BS/include -I$MODEL/include"

export COBCPPOPT

alias -x slic=${EXNUC}/bin/slic
