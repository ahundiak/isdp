# $Id: VDScheckin.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/bin/VDScheckin.sh 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: VDScheckin.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:07:19  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

# NAME
#   VDScheckin.sh - check in data to the project database
#
# SYNOPSIS
#   $ chkin.sh dbserv dbname assemb_nm assemb_rev
#
#   where,
#	     dbserv     - is the database server node name
#	     dbname     - is the database name
#	     assemb_nm  - is the assembly name
#	     assemb_ver - is the assembly version number
#
# DESCRIPTION
#   VDScheckin.sh is forked by VDS when the user selects the "VDS Post Data"
#   command.  This procedure first looks for any of the following files:
#
#	struct_bm   piping       piping_sup   rway
#       struct_pl   piping_noz   hvac	      equip
#
#   For each file that exists the following will occur:
#	- Existing rows in the corresponding ipdc tables, having the 
#	   same assembly name and assembly version number, will be deleted.
#	- New data will be loaded from the file into the database.
#
#   The database table name is determined by appending the string
#   "_dynamic" to the file name.
#
# NOTES
#  1. Check-in status messages will be displayed in the console window
#     when the variable DEBUG is set to the value TRUE.
#
#  2. Assembly version number is ignored in this version.
#
#  3. The variable ISQL must be set to the path name of the isql 
#     executable on the database server.
#
#  4. The login to the database server is currently hard-coded to 
#     nfmadmin.nfmadmin.
#
#  5. The current procedure used results in a lock on the pdc table
#     while new rows are being added.
#
# FILES
#
# HISTORY
#   15-Jan-1991 (BJ)	Initial creation.
#   29-Jan-1991 (BJ)    Change so that one bad file doesn't bomb the
#			entire check in.
#   03-Apr-1991 (BJ)    Change for new dynamic data table names.
#
#-----------------------------------------------------------------------#

#-----------------------------------------------------------------------#
# Initialization
#-----------------------------------------------------------------------#
DEBUG=FALSE		     # enable/disable debug messages
ISQL=/usr/informix/bin/isql  # location of isql exe
NUM_INPUTS=4		     # expected number of input parameters
PDC_FILLST="struct_bm struct_pl piping piping_noz piping_sup hvac rway equip"
DBSLOGIN=nfmadmin.nfmadmin   # database login

NO_DATA_FOUND="0"	     # parameters
DATA_FOUND="1"		     #
SUCCESS="0"		     #
ERROR="1"		     #

time=`date +%H:%M:%S`
echo "\n$time Check in started - please wait..." >> /dev/console

# if debugging enabled...
if [ "$DEBUG" = "TRUE" ]
then
  # Print out script inputs
  set -vx
  echo "==================================================" >>/dev/console
  echo "CHECK_IN: Start check-in process\n" >>/dev/console
  echo "CHECK_IN: Database server  : $1" >>/dev/console
  echo "CHECK_IN: Database name    : $2" >>/dev/console
  echo "CHECK_IN: Assembly name    : $3" >>/dev/console
  echo "CHECK_IN: Assembly version : $4\n" >>/dev/console
fi

# if inputs are insufficient...
if [ "$#" -ne "$NUM_INPUTS" ]
then
   echo "Missing input parameters - check-in aborted!" >>/dev/console
   exit 1
fi

dbserv=$1		# database server node name
dbname=$2		# database name
assemb_nm=$3		# name of assembly to be checked in
assemb_ver=$4		# version number of assembly

filflag=$NO_DATA_FOUND	# filflag goes to DATA_FOUND if any pdc file found
errflag=$SUCCES		# errflag goes to $ERROR if an error occurs
fillst=""		# fillst hols a list of pdc files found

# for each possible type of pdc file...
for file in $PDC_FILLST
do
  filflag=$DATA_FOUND
  # if pdc file exists...
  if [ -r "$file" ]
  then

#-----------------------------------------------------------------------#
# Create fmu file to send files to the server and execute sql commands
# to update the database
#-----------------------------------------------------------------------#

     echo "send $file" >>fmu.$$			   # send data
     echo "send $$.sql" >>fmu.$$		   # send file of sql commands
     echo "com $ISQL $dbname $$" >>fmu.$$          # run the sql commands
     echo "com rm $$.sql $file" >>fmu.$$	   # clean up temp files
     echo "exit" >>fmu.$$			   # exit from fmu

     fillst=`echo $fillst $file`		   # save list of files sent

#-----------------------------------------------------------------------#
# Create a file of sql commands to delete existing records and load 
# new data into the table
#-----------------------------------------------------------------------#

     table=$file"_dynamic"
     echo "BEGIN WORK;" >> $$.sql
     echo "DELETE FROM $table WHERE assembly_nm='$assemb_nm';" >> $$.sql
     echo "LOAD FROM \"$file\" INSERT INTO $table;" >> $$.sql
     echo "COMMIT WORK;" >> $$.sql

#-----------------------------------------------------------------------#
# Initiate a check-in
#-----------------------------------------------------------------------#

     if [ "$DEBUG" = "TRUE" ]
     then
        echo "\nCHECK_IN: FMU COMMANDS- " >> /dev/console
        cat fmu.$$ >> /dev/console
        echo "\nCHECK_IN: SQL COMMANDS- " >> /dev/console
        cat $$.sql >> /dev/console
        #echo "\nCHECK_IN: DATA FILE---------- " >> /dev/console
        #cat $file >> /dev/console
     fi

     fmuopt="-q"
     if [ "$DEBUG" = "TRUE" ]; then fmuopt="-v"; fi

     fmu $fmuopt $dbserv.$DBSLOGIN <fmu.$$
     # if error...
     if [ "$?" -ne "0" ]
     then
        echo "Check in process for $table failed!\n" >> /dev/console
        errflag=$ERROR
     fi
     rm fmu.$$ $$.sql		# delete temp files
  fi
done

# If no data found to check in...
if [ "$filflag" = "$NO_DATA_FOUND" ]
then
   echo "\nNo data found to check in!\n" >> /dev/console
   exit 1 

else
  # if any error occurred...
  if [ "$errflag" = "$ERROR" ]
  then
     echo "\nErrors occurred during check in!\n" >> /dev/console
     exit 1

  else
     
     if [ "$DEBUG" = "TRUE" ]; then rm $fillst; fi
     time=`date +%H:%M:%S`
     echo "\n$time Check in successfully completed.\n " >> /dev/console
     exit 0
  fi
fi
