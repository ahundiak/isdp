# The plan is to have a utility which can be conveniently installed
# (Newprodded) onto a Machine and used to quickly evaluate UMS.
# NOTES:
# 03/10/93   dmb,sbc     This approach is currently limited to products
#                        installed locally.  
#                        Also, it is limited to the $KEY.full.crt set of
#                        instructions in $HOME/Cert.Masters.
#                        
# 

DEFAULT_REPORT_NAME=""
REPORT_VERSION=00.00.00.00

for arg in $*
do
  case $arg
  in
    -l )
     case $2
     in
       [!-]* )
            LOGFILE=$2
            shift 2
            ;;
       * )
     # NEED TO SUPPLY DEFAULT LOGFILE NAME
            LOGFILE=''
            shift
            ;;
     esac
     echo LOGFILE is $LOGFILE

     ARGS="$ARGS -l $LOGFILE"
     ;;
    -o )
     REPORT_NAME=$2     
     shift 2
     ;;
  esac
done

if [ "$1" ]
then
	prod=$1
else
	read -s prod?"Product: "
fi


REPORT_DATE="`date '+%m%d'`"



# BEGIN INSTRUCTION FILE

#dmb:03/10/93:Attempted workaround
PROD_KEY=`echo $prod | tr '[a-z]' '[A-Z]'`
case $PROD_KEY
in
  ADM )
    INSTR_SOURCE_KEY=ADM
    OUT_FILE_NAME_ROOT=adm
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  CADC )
    INSTR_SOURCE_KEY=CADC
    OUT_FILE_NAME_ROOT=cadc
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  XFORMS* )
    INSTR_SOURCE_KEY=FB
    OUT_FILE_NAME_ROOT=xf
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  FORMS*|IFORMS* )
    INSTR_SOURCE_KEY=FB
    OUT_FILE_NAME_ROOT=fi
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  HELP* )
    INSTR_SOURCE_KEY=HELP
    OUT_FILE_NAME_ROOT=hlp
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  UMS )
    INSTR_SOURCE_KEY=UMS
    OUT_FILE_NAME_ROOT=ums
    RESULTS_MAILING_LIST="sbcrowel@susie dmb@tardis steve@gondor"
    ;;
  LGLASS|LG )
    INSTR_SOURCE_KEY=LG
    OUT_FILE_NAME_ROOT=lg
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  LGA )
    INSTR_SOURCE_KEY=LGA
    OUT_FILE_NAME_ROOT=lga
    RESULTS_MAILING_LIST="sbcrowel@susie"
    ;;
  * )
    INSTR_SOURCE_KEY=""
    echo "ERROR: Can not locate Instructions for $prod." 2>&1
    exit 2
    ;;
esac

OUT_FILE_NAME=$OUT_FILE_NAME_ROOT
#OUT_FILE_NAME="`echo $INSTR_SOURCE_KEY | tr '[A-Z]' '[a-z]'`"


#dmb:04/07/93:Changed to local directory 
INSTRUCTIONS_NAME=$HOME/${INSTR_SOURCE_KEY}.full
#INSTRUCTIONS_NAME=$HOME/Cert.Masters/${INSTR_SOURCE_KEY}.full
ASCII_INSTRUCTIONS_NAME=${INSTRUCTIONS_NAME}.crt
HELP_INSTRUCTIONS_NAME=${INSTRUCTIONS_NAME}.s

>$HELP_INSTRUCTIONS_NAME

echo "<ID>$REPORT_VERSION:english:$OUT_FILE_NAME"  >>$HELP_INSTRUCTIONS_NAME
echo "<TI>Certification Guide"  >>$HELP_INSTRUCTIONS_NAME

echo "<TP>Certification_Instructions"  >>$HELP_INSTRUCTIONS_NAME
echo ":Certification Instructions:"  >>$HELP_INSTRUCTIONS_NAME

echo ""  >>$HELP_INSTRUCTIONS_NAME

#dmb:03/10/93:The hc -h keeps us from needing this.
#sed 's/$//' $ASCII_INSTRUCTIONS_NAME >>$HELP_INSTRUCTIONS_NAME

#dmb:04/07/93:Changed
if [ -f $ASCII_INSTRUCTIONS_NAME ]
then
  cat $ASCII_INSTRUCTIONS_NAME >>$HELP_INSTRUCTIONS_NAME
else
  echo "$0: Can not find input instruction file $ASCII_INSTRUCTIONS_NAME"
fi

#dmb:03/09/93:Generate UMSFILE footer
echo "<ETP>"  >>$HELP_INSTRUCTIONS_NAME

# END INSTRUCTION FILE




# BEGIN REPORT FILE

#dmb:03/10/93:Exp
DEFAULT_REPORT_NAME="${OUT_FILE_NAME}_$REPORT_DATE"
#DEFAULT_REPORT_NAME="${prod}_$REPORT_DATE"
#REPORT_NAME="${REPORT_NAME:-$DEFAULT_REPORT_NAME}"
#dmb:03/10/93:Exp
REPORT_NAME="${REPORT_NAME:-$DEFAULT_REPORT_NAME}"
HELP_SOURCE_NAME=$REPORT_NAME.s


PROD_NAME="`proddata '+%n' $prod`"
PROD_VERSION="`proddata '+%v' $prod`"
PROD_DATE="`proddata '+%d' $prod`"
TEST_DATE="`date '+%d-%h-19%y' | tr '[a-z]' '[A-Z]'`"
TEST_TIME="`date '+%T' | tr '[a-z]' '[A-Z]'`"
TEST_MACHINE="`uname -a`"


PRODUCT_RESULTS_NAME="`echo $PROD_NAME | tr '[A-Z]' '[a-z]'`"
PRODUCT_REPORT_NAME=$PROD_RESULTS_NAME.rpt

echo "Report will be written to $HELP_SOURCE_NAME"
>$HELP_SOURCE_NAME
>$PRODUCT_REPORT_NAME

#dmb:04/07/93:Moved HELPFILE header down

#dmb:04/07/93:Moved inquiries up
echo "Product:          $PROD_NAME" >>$PRODUCT_REPORT_NAME
echo "Product Version:  $PROD_VERSION" >>$PRODUCT_REPORT_NAME
echo "Product Date:     $PROD_DATE" >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME
echo "Test Date:     $TEST_DATE" >>$PRODUCT_REPORT_NAME
echo "Test Time:     $TEST_TIME" >>$PRODUCT_REPORT_NAME

echo "Product Installed under:  `proddata '+%p' $prod`" >>$PRODUCT_REPORT_NAME
echo "                  at:     `proddata '+%w' $prod`" >>$PRODUCT_REPORT_NAME
echo "                  from:   `proddata '+%m' $prod`" >>$PRODUCT_REPORT_NAME
echo "                  on:   $TEST_MACHINE" >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME

echo "Current Hardware Configuration on `uname -n`:" >>$PRODUCT_REPORT_NAME
HW_TESTS="/bin/inqcptype \
/bin/inqcpuid \
/bin/inqdiskless \
/bin/inqfpeg \
/bin/inqfpen \
/bin/inqgra \
/bin/inqifb \
/bin/inqifbtype \
/bin/inqiop \
/bin/inqlgexist \
/bin/inqmemory \
/bin/inqnativex \
/bin/inqrop \
/bin/inqscreens \
/bin/inqsecure \
/bin/inqswap \
/bin/inqzbuf"

#dmb:03/10/93:This one seems broke! Don't use it..
#/bin/inqscsi \

#for test_cmd in /bin/inq*
for test_cmd in $HW_TESTS
do
  echo $test_cmd
  $test_cmd
  echo
done >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME

echo "Current Software Configuration on `uname -n`:" >>$PRODUCT_REPORT_NAME
echo "Products Currently Installed:" >>$PRODUCT_REPORT_NAME
dates | cut -c1-60 | sed 's/$//' >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME

echo "BEGIN Cert Testing `date`" >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME

#dmb:03/09/93:Cert Testing goes here


# dmb:04/07/93:Begin subshell so we can get all the output.
# Eventually we may want to twiddle with where and how the headers
# get written. ( in the Driver script or the testing script )


if [ -f test_${OUT_FILE_NAME_ROOT}.sh ]
then
  test_${OUT_FILE_NAME_ROOT}.sh  | tee -a $PRODUCT_REPORT_NAME
else
  echo "$0: Can not find product test file $PRODUCT_REPORT_NAME"
fi


# dmb:04/07/93:End subshell ... as if it was all just a bad dream...
# dmb:04/07/93:Also note the use of tee instead of >>
##) >> $PRODUCT_REPORT_NAME
#exit

echo ""  >>$PRODUCT_REPORT_NAME

echo "END Cert Testing `date`" >>$PRODUCT_REPORT_NAME
echo "" >>$PRODUCT_REPORT_NAME

echo "Report was written to $HELP_SOURCE_NAME"

# END REPORT FILE

# BEGIN CONVERT REPORT FILE TO HELP FORMAT
#dmb:04/07/93:Now turn report into help format
if [ -f "$PRODUCT_REPORT_NAME" ]
then

  #dmb:03/09/93:Generate HELPFILE header
  #echo "<ID>$REPORT_VERSION:english:$REPORT_NAME"  >>$HELP_SOURCE_NAME
  #echo "<TI>Certification Guide"  >>$HELP_SOURCE_NAME

  echo "<TP>Certification_Report_$REPORT_DATE"  >>$HELP_SOURCE_NAME
  echo ":Certification Report $REPORT_DATE:"  >>$HELP_SOURCE_NAME

  echo ""  >>$HELP_SOURCE_NAME

  cat $PRODUCT_REPORT_NAME >>$HELP_SOURCE_NAME

  echo ""  >>$HELP_SOURCE_NAME

  #dmb:03/09/93:Generate HELPFILE footer
  echo "<ETP>"  >>$HELP_SOURCE_NAME

fi

# END CONVERT REPORT FILE TO HELP FORMAT


#exit 

###
### 04-07-93:sml,dmb,sbc:  Quit here for now
###

echo "Converting Report $HELP_SOURCE_NAME to UMS format"
#dmb:03/10/93:Added to get around current UMS implementation limit (CR???)
set -x
rm -rf $HOME/.IH/english/$OUT_FILE_NAME
#rm $HOME/.IH/english/$OUT_FILE_NAME/$REPORT_VERSION/toc
set +x

#dmb:03/10/93:Alan says we can use the -h switch to generate the equivalent
#    of the hardcoded < CR >s. Yes, really!
set -x
hc -c -h -o $OUT_FILE_NAME.hc $HELP_INSTRUCTIONS_NAME $HELP_SOURCE_NAME
set +x

echo "Installing Report $OUT_FILE_NAME.hc"
set -x
installhdoc.sh $PWD/$OUT_FILE_NAME.hc
set +x

echo "Displaying Report $OUT_FILE_NAME.hc"
set -x
xbrowser -D $OUT_FILE_NAME -l english -v $REPORT_VERSION
set +x


echo "Now Mailing results to users"

if [ -f $HELP_SOURCE_NAME ]
then
#  elm -s "$PROD_NAME $PROD_VERSION Certification $TEST_DATE $TEST_TIME" \
#    $LOGNAME $RESULTS_MAILING_LIST <$HELP_SOURCE_NAME
  elm -s "$PROD_NAME $PROD_VERSION Cert Report" \
    $LOGNAME $RESULTS_MAILING_LIST <$PRODUCT_REPORT_NAME
else
  echo "$0: Can not find input instruction file $HELP_SOURCE_NAME"
fi

#dmb:04/07/93:We'll leave this for now
#rm -f $HELP_SOURCE_NAME
