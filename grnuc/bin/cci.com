#
## This script is provided as an example to allow parsing of PPL (.u) files 
## from the command line. The environment variable INGRHOME must already be 
## exported (in ~/.profile or ~/.env) to point to the directory location of 
## product_data.
## eg. export INGRHOME=/usr/ip32
##
##	Usage: cci.com   ppl_file(s)_with_.u_extension
##
##	eg. cci.com ppl.u     OR    cci.com *.u
#

if [ "$#" -eq 0 ]
then
   echo "Usage: cci.com   ppl_file(s)_with_.u_extension"
   exit 10
fi

if [ ! -z "${INGRHOME}" ]
then
   pdata=${INGRHOME}/product_data
else
   pdata=/usr/ip32/product_data
   INGRHOME="/usr/ip32"
fi

if [ ! -r "${pdata}" ]
then
   echo "ERROR: $pdata not found; please export INGRHOME variable"
   exit 20
fi

platform=`uname -a |  cut -d" " -f1`
if [ "${platform}" = "IRIX" ]
then
   CCIOPT="-D_MIPS_ISA=_MIPS_ISA_MIPS2 -D_MIPS_SZINT=32 -D_MIPS_SZLONG=32 \
	   -D_MIPS_SZPTR=32"	# required only for SGI parsing
   cputype="sgi"
fi

if [ "${platform}" = "SunOS" ]
then
   CCIOPT=""
   cputype="sun5"
fi

if [ "${platform}" = "CLIX" ]
then
   CCIOPT=""
   cputype=`\inqcpuid`

   if [ "${cputype}" = "C400" ]	
   then
	cputype=c400			# default for CLIX
   elif [ "${cputype}" = "C300" ]
   then
	cputype=c100			# for C300
   else
	cputype=c100			# for C100 or default
   fi
fi
   

BSPMATH=`cat ${pdata} |
 awk -F\  '$2 == "I/BSPMATH" {print $5}'`

EXNUC=`cat ${pdata} |
 awk -F\  '$2 == "I/EXNUC" {print $5}'`

EXTARG=${EXTARG:-$EXNUC}

GRNUC=`cat ${pdata} |
 awk -F\  '$2 == "I/GRNUC" {print $5}'`

MODEL=`cat ${pdata} |
 awk -F\  '$2 == "I/MODEL" {print $5}'`

echo ${cputype} ${platform} ${CCIOPT}

echo $*				# this will echo arguments - source files

$GRNUC/bin/cci 				\
	-q 				\
	-s $* 				\
	-p${EXTARG}/bin/omcpp ${CCIOPT} -s 	\
	-I${INGRHOME}/include		\
	-I${EXNUC}/include		\
	-I${GRNUC}/include/ingrsys		\
	-I${GRNUC}/unix_include/${cputype}		\
	-I${GRNUC}/include		\
	-I${MODEL}/include		\
	-I${BSPMATH}/include
