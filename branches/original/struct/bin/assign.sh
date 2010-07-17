#   NAME
#
#   assign.sh - assign the shared library paths
#
#   SYNOPSIS
#
#   assign.sh <imagename> <product data file>
#
#   DESCRIPTION
#
#   This script reassigns the shared library paths for the
#   indicated image based on the given product data file.
#
#   NOTE
#
#   This script works only with shells compatible with ksh.
#
#   ERROR CODES
#
#   1 - product data not readable
#   2 - product data not found
#   3 - path for EXNUC not found
#   4 - path for BSPMATH not found
#   5 - path for GRNUC not found
#   6 - path for MODEL not found
#   8 - a shared library was not found
#   9 - wrong number of arguments
#   10 - cannot find the image
#   11 - cannot read the image
#   12 - cannot write the image
#
#   HISTORY
#
#   14 Mar 1989 jBk Modified echopath to match the new, more
#                   robust error checking of the echopath in the
#                   ems script.
#   25 Feb 1989 AIC Genesis

function echopath {
    noerror=$1
    if [ $noerror = noerror ]
    then
        shift
    fi
    item=$1
    pdata=$2
    me=$3

    path=`awk '/ '$item' / {print $5}' $pdata | sort -u`

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

if [ $# = 2 ]
then
    product_data=$2
else
    if [ $# = 1 ]
    then
        product_data=/usr/ip32/product_data
    else
        echo Usage: $0 "<image> [<product data file>]"
        exit 9
    fi
fi

image=$1

if [ ! -f ${image} ]
then
    echo $0: Cannot find ${image}
    exit 10
else
    if [ ! -r ${image} ]
    then
        echo $0: Cannot read ${image}
        exit 11
    else
        if [ ! -w ${image} ]
        then
            echo $0: Cannot write ${image}
            exit 12
        fi
    fi
fi

if [ ! -r ${product_data} ]
then
    if [ -f ${product_data} ]
    then
        echo $0: ${product_data} not readable. 1>&2
        exit 1
    else
        echo $0: ${product_data} not found. 1>&2
        exit 2
    fi
fi

if BSPMATH_path=`echopath I\\\/BSPMATH ${product_data} $0`
then
    true
else
    exit 4
fi

if EXNUC_path=`echopath I\\\/EXNUC ${product_data} $0`
then
    true
else
    exit 3
fi

if GRNUC_path=`echopath I\\\/GRNUC ${product_data} $0`
then
    true
else
    exit 5
fi

if MODEL_path=`echopath I\\\/MODEL ${product_data} $0`
then
    true
else
    exit 6
fi

for lib_s in ${BSPMATH_path}/shlib/bsma_s \
             ${BSPMATH_path}/shlib/bsut_s \
             ${BSPMATH_path}/shlib/bscv_s \
             ${BSPMATH_path}/shlib/bssf_s \
             ${EXNUC_path}/shlib/libexnuc_s \
             ${GRNUC_path}/shlib/libGRco_s \
             ${GRNUC_path}/shlib/libGRgr_s \
             ${GRNUC_path}/raster/shlib/raster_s \
             ${MODEL_path}/shlib/hsurf_s \
             ${MODEL_path}/shlib/ve_s
do
    if [ -f ${lib_s} ]
    then
        ${EXNUC_path}/bin/mls -q -l`basename ${lib_s}`:${lib_s} ${image}
    else
        echo $0: Cannot find ${lib_s}
#        exit 8
    fi
done

exit 0
