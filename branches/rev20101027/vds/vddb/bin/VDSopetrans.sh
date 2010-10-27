# $Id: VDSopetrans.sh,v 1.1.1.1 2001/01/04 21:08:03 cvs Exp $

#**********************************************************************
# I/VDS>
#
# File:	vddb/bin/VDSopetrans.sh 
#
# Description:
# This script automates the loading and unloading of the ope_* tables.
# All data from the tables is unloaded/loaded.
#
#
# Dependencies:
#
# Revision History:
#	$Log: VDSopetrans.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:08:03  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/24  15:44:42  pinnacle
# Created: vddb/bin/VDSopetrans.sh by sljenks for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	05/23/96	slj		file added to pinnacle
#
#**********************************************************************
#
#
# Initialie variables
# Get the path to ingrconfig
OS=`uname`
if [ "$OS" = "CLIX" ]
then
	PROD_DIR="/usr/ip32"
else
	PROD_DIR="/opt/ingr"
fi

RIS4PATH="/risucu/bin"		# the path to RIS v.4 executables
OPE_TABLES="OPE_FMT_TABLE OPE_FMT_ALIGN OPE_FMT_COL OPE_FMT_COL OPE_FMT_HDTR OPE_FMT_FILL OPE_SUM_TABLE OPE_SUM_QTY OPE_SUM_MATCH OPE_SORT_TABLE OPE_SORT_KEYS OPE_ADS_TABLE OPE_ADS_REC"


# Get the RIS version and determine the paths accordingly.
#
SQL_FILE=".ope_sql"
CHECK_RIS=`grep RISUTL $PROD_DIR/ingrconfig`
if [ "$CHECK_RIS" != " " ]
then
 	RIS_PATH_START=`grep RISUTL $PROD_DIR/ingrconfig | cut -f6 -d#`
	RIS_PATH="$RIS_PATH_START/bin/"
	RISLOAD="$RIS_PATH/rislod"
	RISUNLOAD="$RIS_PATH/risunlod"
	RISBATCH="$RIS_PATH/risbatch -i $SQL_FILE -o ope.msg"
else
 	RIS_PATH_START=`grep RISUCU $PROD_DIR/ingrconfig | cut -f6 -d#`
	RIS_PATH="$RIS_PATH_START/bin/"
	RISLOAD="$RIS_PATH/risload"
	RISUNLOAD="$RIS_PATH/risunload"
	RISBATCH="$RIS_PATH/risbatch -i $SQL_FILE -o ope.msg"
fi

TMP_FILE=".ope_tmp"
if [ -f ris.err ]
then
  /bin/rm ris.err
fi

# Is this a transfer or install?
valid_input="n"
while [ "$valid_input" != "y" ]
do

echo " "
echo " "
echo "Do you want to do transfer or install the OPE data? ([t]/i) \c"
read SCRIPT_MODE; :  ${SCRIPT_MODE:="t"}
echo " "

case $SCRIPT_MODE in
	["T","t"])  valid_input="y"
	      SCRIPT_MODE="t"
	      ;;
	["I","i"])  valid_input="y"
	      SCRIPT_MODE="i"
	      ;;
        "*")  valid_input="n"
	      echo " "
	      echo "******************************************"
	      echo "ERROR: Please type the letter 't' or 'o'."
	      echo "******************************************"
	      echo " "
	      ;;
esac
done

# Prompt user for the schema they want to use, if they hit <Return>
# show them a list of available schemas.

s_lst=`grep SCHNAME $RIS_PATH_START/../schemas | cut -f2 -d=`
valid_input="n"
while [ "$valid_input" = "n" ]
do
      echo " "
      echo "The following schemas exist on this machine"
      count=0
      in_list="n"

      for name in $s_lst
      do
        count=$count+1
        echo $name
      done

      echo "------"
      if [ "$SCRIPT_MODE" = "i" ]
      then
       echo "Please enter the schema name install to [$name]: \c"
       read schema; : ${schema:="$name"}
      else
       echo "Please enter the schema to transfer from [$name]: \c"
       read schema; : ${schema:="$name"}
      fi

    tst_sch=`grep $schema $RIS_PATH_START/../schemas`

    echo "------"
    echo "Enter the ris schema password for $schema:  \c"
    stty -echo
    read schema_pswd
    stty echo
    echo " "
    echo " "

# Verify schema and password before we begin to much processing
    echo "Verifying schema name and schema password combination."
    echo "default schema $schema.$schema_pswd;" > $SQL_FILE
    echo "exit;" >> $SQL_FILE
    $RISBATCH

    tst=" "
    if [ -f ope.msg ]
    then 
      tst=`grep 'RIS Error' ope.msg`
    fi

    if [ "$tst" != "" ]
    then
      echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      echo "Error opening schema. Please verify the schema name"
      echo "and schema password combination."
      echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      valid_input="n"
    else
      echo "Schema name and password combination are correct."
      echo " "
      echo "-----"
      valid_input="y"
    fi

done     # verifying schema and password

# If this is a unload, do it.
if [ "$SCRIPT_MODE" = "t" ]
then
    echo " "
    echo "\tUnloading OPE tables..."
    echo "$RISUNLOAD -mw -o ope_info.dmp -s $schema .$schema_pswd table with data $OPE_TABLES" >.ris_unload
    echo "/bin/rm .ris_unload" >> .ris_unload
    chmod ugo+x .ris_unload
    .ris_unload

    echo " "
    echo "\tSuccessfully unloaded $schema to the file ope_info.dmp"

# If this is a load, do it.
else

    valid_input="n"
    while [ "$valid_input" = "n" ]
    do
    	echo " "
    	echo "What file do you want to load from? [ope_info.dmp] \c "
    	read read_file; : ${read_file:="ope_info.dmp"}
 
	echo "read file is $read_file"
	if [ ! -f "$read_file" ]
	then
		echo " "
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ERROR: File $read_file does not exist."
	 	echo "Please enter a new filename."
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		valid_input="n"
	else
           # Get the old schema name
           old_schema=`grep "create schema" $read_file | cut -f1 -d. | cut -f3 -d' '`
           if [ "$old_schema" = "" ]
           then
	   	valid_input="n"
	   	echo " "
	   	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	   	echo "ERROR: Unable to determine old schema from $read_file."
	   	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	   else
		valid_input="y"
	   fi
	fi
    done		# making sure file is valid


    echo " "
    echo "Do you want to delete the existing information in the"
    echo "OPE tables before adding the load information? (y/[n]) \c "
    read overwrite; : ${overwrite="n"}

    case $overwrite in
	["y","Y"])	echo " "
		echo "Deleting existing information before loading..."
		echo " "
		overwrite="clear table with data"
		;;
	*)	echo "Adding new data to existing data..."
		overwrite=" "
		;;
    esac
    echo "$RISLOAD -i $read_file -m w -c 1000 -s $old_schema rename $schema .$schema_pswd $overwrite all" > .ris_load
    echo "/bin/rm .ris_load" >> .ris_load
    chmod ugo+x .ris_load
    .ris_load
fi

if [ -f ope.msg ]
then
   /bin/rm ope.msg
fi

if [ -f .ope_sql ]
then
   /bin/rm .ope_sql
fi

if [ -f .ris_load ]
then
   /bin/rm .ris_load
fi

if [ -f .ris_unload ]
then
   /bin/rm .ris_unload
fi

if [ -f ris.err ]
then
  echo " "
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "There are ris errors, please review the file ris.err for more information."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  
else
  echo " "
  echo "\tOPE table operation completed successfully."
  echo " "
  echo " "
fi
