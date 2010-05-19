# $Id: VDbatchDrw.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh

#***********************************************************************
# I/VDS
#
# File:		batch/VDbatchDrw.sh
#
# Description:	This shell script is used for running batch extraction of
#		drawings. This script, when invoked gets design file and
#		setup files from client machine, executes the batch
#		extraction of drawings on the design file and sends the
#		design file back to client.
#
#		It also sends e-mails at start and end of the execution of
#		batch extraction.
#
# Usage :	VDbatchDrw.sh	<node_name>
#				<user_name>
#				<passwd>
#				<file_dir>
#			 	<Drawingfile_name>
#				<setupfile>
#				[product_runname]
#
#		where:
#
#		"<node_name>"	the node_name of the client system.
#				Client system is the system requesting for
#				a drawing process on batch.
#		"<user_name>"	clients username login.
#		"<passwd>"	clinets passwd of "<user_name>" login.
#		"<file_dir>"	directory where the design file is saved.
#		"<file_name>"	design file name, prepared fro drawing
#				extraction on batch.
#		"<setupfile>"	ASCII file contain list of support files
#				needed for drawing extraction. The total
#				path is given for these support files.
#		"[prod_runname]" for example "Vds", "Route", etc.
#
# Algorithm :
#
#	   	Following steps are executed on server.
#		---------------------------------------
#
#	   1) Initially it checks for paths and these paths are assigned
#	      to global variables for future use. If paths for respctive
#	      products are not found then program is aborted.
#
#	   2) It is checked to see if product I/VDS exists.If no, program 
#             is aborted. If product exists then it is checked to see if 
#             I/VDS is in active state already. If yes, batch request 
#	      execution is stopped and this message is informed  to client. 
#
#	   3) It is checked if directory $BATCH_DIR exists. If it does not
# 	      exist, $BATCH_DIR is created. Then working directory is
#	      changed to $BATCH_DIR.
#
#	   4) Before pulling the design file to server machine, it is checked
#	      to see the sufficient disk space is available,if the space is  
#             not available then the program is aborted.
#
#	   5) Specified design file is pulled from client machine from the
#	      specified directory using ftp. File 'setup.lst' is pulled
#	      from client from specified directory. The files specified in the
#	      file 'setup.lst' also are pulled from client. It is assumed
#	      that the names of files specified in 'setup.lst' are absolute
#	      filenames.
#
#	   6) The command for batch extraction of drawings is executed in 
#	      batch mode.
#	      It is assumed that return status of batch extraction ( result of
#	      executing PPL program) is written to file /usr/tmp/batdrw.sts.
#	      The return status can be either '1' ( SUCCESS) or '0' ( FAILURE ).
#	      Return status of batch extraction is checked. 
#	      If it is '0' program is aborted.
#
#	      If the file '/usr/tmp/batdrw.sts' not found, it is assumed
#	      that the batch extraction has been completed successfully.
#
#	   7) Design file will be sent back to client to the directory
#	      from where it has been pulled.
#
# Dependencies:
#
#	   1) This uses TCPIP for transfer of files. TCPIP product should exist
#	      on both client and server.
#
#	   2) Login on client should have a password.
#
# Notes :
#	   If environment variable $BATCH_DIR exists, design file is
#	   pulled to $BATCH_DIR, else a temporary directory 
#	   /usr/tmp/vdsbatch is created and design file is pulled there.
#
#	   File /usr/tmp/batdrw.dbg contains suceess or failure of each step.
#	   The file gives an idea about success or failure of each step and 
#	   program.
#
#****************************************************************************
#
# Revision History
#	$Log: VDbatchDrw.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:07:19  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/04/08  20:49:40  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by kddinov for vds.241
#
# Revision 1.3  1997/04/01  16:04:00  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by kddinov for vds.241
#
# Revision 1.2  1997/03/17  18:40:34  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by kddinov for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.19  1996/06/06  23:21:08  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by sljenks for vds.240
#
# Revision 1.18  1996/05/27  05:38:46  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by rgade for vds.240
#
# Revision 1.17  1996/05/20  10:24:20  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by rgade for vds.240
#
# Revision 1.16  1996/03/13  18:35:28  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by v240_int for vds.240
#
# Revision 1.15  1996/03/13  18:06:20  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by v240_int for vds.240
#
# Revision 1.14  1996/03/08  12:18:58  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by rgade for vds.240
#
# Revision 1.13  1996/02/23  23:31:04  pinnacle
# Replaced: ./batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.12  1995/12/13  00:11:22  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.11  1995/12/07  15:36:40  pinnacle
# Replaced: ./batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.9  1995/10/06  15:20:00  pinnacle
# Replaced: ./batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/31  21:46:44  pinnacle
# Replaced: ./batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.7  1995/08/16  12:44:20  pinnacle
# Replaced: batch/ for:  by msbraju for vds.240
#
# Revision 1.6  1995/08/03  15:48:10  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.5  1995/08/02  21:42:18  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/01  19:23:20  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/28  13:42:20  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/27  20:35:36  pinnacle
# Replaced: batch/VDbatchDrw.sh for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:00:02  pinnacle
# Created: batch/VDbatchDrw.sh by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#       07/22/95	G.Ravichandra	Creation
#	07/25/95	adz		Memory checking.
#	07/27/95	adz		Add 'setup.bat' file for export var.
#	07/28/95	ravi		Delete the setup file from client.
#	07/30/95	ravi		Check directory is write protected.
#					Cleanup process information in ~rje.
#					Checking file sizes.
#	08/02/95	ravi		Changed process validation.
#	12/03/95	adz/ravi	Adaption ftp for Solaris.
#	02/23/96	adz/tbl		Available space problem/error report.
#	Aprl-97		kdd		product_runaname
#
#****************************************************************************
#
#------------------------------------------------------------------------------
#define DEBUG 1

Debug() {

	if [ $DEBUG -eq 1 ] ; then
		if [ "$LOG_FILE" = "" ] ; then
			echo " ** $*" >> /dev/console
		else
			echo " ** $*" >> "$LOG_FILE"
		fi
		echo "I/VDS-DEBUG: -- $*" >> /dev/console
	fi
	return 0
} # Debug
#
#------------------------------------------------------------------------------
#
Info() {

	if [ "$LOG_FILE" = "" ] ; then
		echo " ** $*" >> /dev/console
	else
		echo " ** $*" >> "$LOG_FILE"
	fi

	echo "I/VDS-BATCH: ** $*" >> /dev/console
	return 0
} # Info
#
#------------------------------------------------------------------------------
#
Error() {

	if [ "$LOG_FILE" = "" ] ; then
		echo "ERROR : ***** $*" >> /dev/console
	else
		echo "ERROR : ***** $*" >> "$LOG_FILE"
	fi

	echo "I/VDS-ERROR: ***** $*" >> /dev/console
	return 0
} # Error
#
#-------------------------------------------------------------------------------
#
ErrorMail() {
	
	Debug "Entered ErrorMail"

  echo " ERROR ERROR ERROR ERRROR "				>> "$LOG_FILE"
  echo " "							>> "$LOG_FILE"
  echo " ERROR: $*"						>> "$LOG_FILE"
  echo " "							>> "$LOG_FILE"
  echo " ERROR ERROR ERROR ERRROR "				>> "$LOG_FILE"
  echo " "							>> "$LOG_FILE"
  echo "Your batch visualization process has failed. Please "	>> "$LOG_FILE"
  echo "perform the following steps: "				>> "$LOG_FILE"
  echo " 1. Preprocessed objects in the design file should be " >> "$LOG_FILE"
  echo "    deleted by the user. Select the 'set' input "	>> "$LOG_FILE"
  echo "    generator from the pocket menu."			>> "$LOG_FILE"
  echo " 2. In a local window keyin 'rm *.lst' to delete the  "	>> "$LOG_FILE"
  echo "    local batch .lst support file."			>> "$LOG_FILE"
  echo " 3. To perform the visualization process you can either:" >> "$LOG_FILE"
  echo "    a. Resubmit the batch process to a different queue ">> "$LOG_FILE"
  echo "       --- or --- "	>> "$LOG_FILE"
  echo "    b. Run 'Local' interactive visualization process."	>> "$LOG_FILE"
  echo " "							>> "$LOG_FILE"

  if [ "$LOG_FILE" != "" ] ; then
	mailx -s "Error in Batch Process" "$USER@$NODE"<$LOG_FILE
  fi

	Debug "Exiting ErrorMail"

  exit 1;

} # ErrorMail
#
#------------------------------------------------------------------------------
#
# Checking of Product paths 
#
CheckPathFile() {

	RC=0

	VDS=`echopath Vds`
	Debug "VDS product_path: $VDS"
	
	if [ "$VDS" = "" ] ; then
		RC=1
                Debug "Product I/VDS not found." >> /dev/console
		ErrorMail "Product I/VDS not found on server"
	fi

#
#	Execute the setup file and see if variables are set.
#

	if [ -f $VDS/batch/setup.bat ] ; then 
		. $VDS/batch/setup.bat
	fi

	if [ "$BATCH_PRC_PATH" = "" ] ; then
# KDD March 97		BATCH_PRC_PATH="/usr/tmp"
		BATCH_PRC_PATH="/tmp"
	fi

	if [ "$BATCH_SAV_PATH" = "" ] ; then
		BATCH_SAV_PATH="$BATCH_PRC_PATH"
	fi

	if [ "$BATCH_PRC_DIR" = "" ] ; then
		BATCH_PRC_DIR="vdsbatch"
	fi

	if [ "$BATCH_SAV_DIR" = "" ] ; then
		BATCH_SAV_DIR="vds_save"
	fi

	BATCH_PRC="$BATCH_PRC_PATH/$BATCH_PRC_DIR"
	BATCH_SAV="$BATCH_SAV_PATH/$BATCH_SAV_DIR"

	#
	# remove debug file if it exists
	#
	if [ "$BATCH_LOG_FILE" = "" ] ; then
		BATCH_LOG_FILE="vdbatch.log"
	fi

#KDD	LOG_FILE="$BATCH_PRC_PATH/$BATCH_LOG_FILE"

	if [ -f $LOG_FILE ] ; then
		rm -f $LOG_FILE
	fi

	Debug "Entered CheckPathFile"

	Debug "BATCH_PRC : $BATCH_PRC "
	Debug "BATCH_SAV : $BATCH_SAV "
	Debug "LOG_FILE  : $LOG_FILE "

#
#	Check the needed product paths.
#

	EXNUC=`echopath Exnuc`
	MODEL=`echopath Model`

	if [ "$EXNUC" = "" ] ; then
		RC=1
		Error "Product I/EXNUC not found."
		ErrorMail "Product I/EXNUC not found on server."
	else if [ "$MODEL" = "" ] ; then
			RC=1
			Error "Product I/MODEL not found." 
			ErrorMail "Product I/MODEL not found on server." 
	     else if [ "$VDS" = "" ] ; then
			RC=1
                        Error "Product I/VDS not found."
                        ErrorMail "Product I/VDS not found server."
		  fi
	     fi
	fi
	if [ $RC -eq 0 ];then
		Debug "Found I/EXNUC, I/MODEL, I/VDS product paths"
	fi

	Debug "EXNUC : $EXNUC "
	Debug "MODEL : $MODEL "
	Debug "VDS   : $VDS "

	Debug "Exiting CheckPathFile"
	return ${RC}

} # CheckPathFile
#
#------------------------------------------------------------------------------
#
# function ProductCheck: checks if the product I/VDS exists and also
# checks the I/VDS is in active state already. If yes,program is aborted
#
ProductCheck() {

	RC=0
	Debug "Entered ProductCheck"

#	if ( dates i_vds | grep "I_VDS" >$BB ); then
	ls $VDS
	if [ "$?" = "0" ]; then 
	    Debug "I/VDS found"
            if [ test `ps -ef | grep -c "$MODEL/bin/Model -p Vds"` -gt 1 ]; then
	    	Error "Model is already active on remote machine"
	        Error "Cannot submit batch request, process already active."
		RC=1
	    fi
	else
	    Error "I/VDS not found"
	    RC=1
	fi

	Debug "Exiting ProductCheck"
	return ${RC}

} # ProductCheck
#
#------------------------------------------------------------------------------
#
# function Chdir: It checks if directory $BATCH_PRC exists. If not
#		  it creates the directory. Changes to $BATCH_PRC.
#
# Usage : Chdir
#
Chdir() {
	RC=0
	Debug "Entered Chdir"

	if [ ! -d "$BATCH_PRC" ]; then
# KDD 97              mkdir -m 777 -p "$BATCH_PRC" >$BB 2>$BB
              mkdir -m 777 -p "$BATCH_PRC"
              if [ -d "$BATCH_PRC" ]; then
                      	chmod ugo=rwx "$BATCH_PRC"
			cd $BATCH_PRC
			RC=$?
               		if [ "$RC" != "0" ] ; then
                	        Error "chdir to $BATCH_PRC failed"
                       	 	return 1
                	fi
			Debug "Directory $BATCH_PRC made"
		else
			Error "Cannot make $BATCH_PRC"
			Info " Check the permissions of $BATCH_PRC_PATH"
			Info " directory. Permission must be drwxrwxrwx " 
			return 1	
		fi
	else
		cd $BATCH_PRC
		RC=$?
		if [ RC -ne 0 ] ; then
			Error "chdir to $BATCH_PRC failed"
			return 1
		fi
		Debug "pwd = $PWD"
		Debug "Directory $BATCH_PRC exists"
	fi

	Debug "Exiting Chdir"
	return ${RC}

} # chdir
#
#-------------------------------------------------------------------------------
#
# function CheckSpace: It checks the file size of the design file on the
#			client machine and compare with free space on
#			server.
CheckSpace() {

	FSIZE=0
	RBLOCKS=0

	RC=0
	Debug "Entering CheckSpace"

	rm -f /usr/tmp/dirlist

# KDD	if (
#              echo user $2 $3
#              echo dir $DRWDIR /usr/tmp/dirlist
#              echo quit
#              ) | $FTP_OPTION $1 ; then

        echo "user $USER $3 \ndir $DRWDIR /usr/tmp/dirlist \nquit\n" | $FTP_OPTION $NODE >> $LOG_FILE 2>&1
        RC=$?
        if [ "$RC" = "0" ]; then
              if [ ! -f /usr/tmp/dirlist ] ; then
                  Error "  ** Could not get size of design file"
                  return 1
              fi
	fi

	FSIZE=`cat /usr/tmp/dirlist|awk -F" "  '$9 == "'$DRWFILE'"{print $5}'`
	Debug "Files Size $FSIZE "

	let RBLOCKS=$FSIZE/512
	Debug "Block Size $RBLOCKS "

	ABLOCKS=`Free |awk '/usr/{ print $3 }'`
	Debug "Availble: $ABLOCKS"

	if Free -t $BATCH_PRC $RBLOCKS; then
		Debug "Block(s) space available : $ABLOCKS"
		Debug "Block(s) space required  : $RBLOCKS"
		Debug "Enough Space to Process Job"
	else
		Error "WARNING: Diskspace is not sufficient to get design file"
		RC=1
	fi

	rm -f /usr/tmp/dirlist

	Debug "Exiting CheckSpace"
	return ${RC}

} # CheckSpace
#
#-------------------------------------------------------------------------------
#
# function GetFile : Gets design file and <setupfile> file from clinet.
#		     Also gets the files listed in the <setupfile>.
#
# Usage :	GetFile <node_name> <user_name> <passwd> <file_name>
# 
GetFile() {

	RC=0
	Debug "Entered GetFile"

	#
	# check if node, login and passwd are OK
	#
	if ( echo user $2 $3 | $FTP_OPTION $1 | grep "logged in" ) ; then
		Debug "ftp to client success"
	else
		Error "ftp to client failed( Check node/login/passwd )"
		return 1
	fi

	#
	# remove files in the directory, if any
	#
	rm -f $BATCH_PRC/*

	#
	# pull the files from remote client
	#
	if (
		echo user $2 $3
		echo bin
		echo get $DRWDIR/$DRWFILE  $DRWFILE 
		echo get $DRWDIR/$SETUP_FILE  $SETUP_FILE 
		echo quit
		) | $FTP_OPTION $1 >> $LOG_FILE 2>&1 ; then

		if [ ! -f $DRWFILE ] ; then
			Error "Could not get design file $DRWFILE"
			Error "    ( check directory and design filename )"
			return 1
		else
		 	if [ -s $DRWFILE ];then
		  		Info "Pulled design file $DRWFILE"
		  	else
				Error "$DRWFILE is an empty file"
				return 1
		  	fi
		fi

		if [ ! -f $SETUP_FILE ] ; then
			Error "Could not get setup file $SETUP_FILE"
			return 1
		else
			if [ -s $SETUP_FILE ];then
		  		Debug "Pulled setup $SETUP_FILE successfully"
                  	else
                       		Error "$SETUP_FILE is an empty file"
				return 1
                  	fi
		  
		fi
	fi

	#
	# Pull the setupfiles and check file sizes 
	#

#KDD March 97
        for f in `cat $SETUP_FILE`
        do
            FIL=`basename $f`
              echo "user $USER $3 \nget $f $BATCH_PRC/$FIL \nquit\n" | $FTP_OPTION $NODE >> $LOG_FILE 2>&1
 
            if [ -f $BATCH_PRC/$FIL ]; then
                        if [ -s $BATCH_PRC/$FIL ]; then
                                 Info "$BATCH_PRC/$FIL file is pulled properly"
                else
                                 Error "$BATCH_PRC/$FIL file is empty "
                         return 1
                fi
            else
                Error  "Could not get the file $BATCH_PRC/$FIL"
                Info "check the file on client <$NODE> system"
                return 1
            fi
        done   

	Debug "Exiting GetFile"	
	return ${RC}

} # GetFile
#
#-------------------------------------------------------------------------------
#
# function ExecuteVds : Executes I/VDS in batch mode. It executes the command
#			"ci=batdrw" in batch mode. The ppl should have
#			necessary commands for batch extraction of drawings.
#
# 
# Usage	: ExecuteVds
#
ExecuteVds() {

	RC=0
	Debug "Entered ExecuteVds"

	Info "PROCESS : $DRWFILE"

	rm -f /usr/tmp/batdrw.sts

# KDD March  97
         $EXNUC/bin/drive $MODEL/bin/Model -p $PROD_RUNNAME -b -f $BATCH_PRC/$DRWFILE  -C \"ci=batdrw\" >> $LOG_FILE 2>&1 
        RC=$?

        if [ "$RC" = "0" ]; then
		if [ -f /usr/tmp/batdrw.sts ] ; then
			RSTATUS=`cat /usr/tmp/batdrw.sts`
			if [ RSTATUS -ne 1 ] ; then
				RC=1
				Error "Batch Extraction of Drawings Failed."	
				Debug "batdrw.sts File exist, but sts -ne to 1"
			else
				Info "Batch Extraction Finished"
			fi
		else
			RC=1
			Error "Batch Extraction of Drawings Failed"
			Debug "/usr/tmp/batdrw.sts file does't exist"
		fi
	else
		Error "Batch Extraction Failed."
		Debug "Failed in command ExecuteVds"
	fi

	rm -f /usr/tmp/batdrw.sts

	Debug "Exiting ExecuteVds"
	return ${RC}

} # ExecuteVds
#
#------------------------------------------------------------------------------
#
# function SendFile : sends design file to client.
# Usage : SendFile <node-name> <user-name> <passwd> <file_name> 
#
SendFile() {

	RC=0
	Debug "Entered SendFile"

	# send the design file to remote client

	SAVELOC=0

	if ( (
		echo user $2 $3
		echo bin
		echo put $BATCH_PRC/$DRWFILE  $DRWDIR/$DRWFILE 
		echo quit
	    ) | $FTP_OPTION $1 >> $LOG_FILE 2>&1  ) ; then
		Info "Design files sent back to $1.$2" 
	else
		Error "Failed to send Drawing file to $1@$2."
		SAVELOC=1
		RC=1
	fi

	Debug "Exiting SendFile"
	return ${RC}

} # SendFile
#
#------------------------------------------------------------------------------
#
# function SaveLoc : Check if we need to save the file local.
#
SaveLoc() {

	RC=0
	Debug "Entered SaveLoc"

	# Check for the local save flag. If '1' store the files.

	if [ $SAVELOC -eq 1 ] ; then

		BATCH_SAVDIR=$BATCH_SAV/${SETUP_FILE%.*}
		if [ ! -d "$BATCH_SAVDIR" ]; then
			if mkdir -m 777 -p "$BATCH_SAVDIR" >$BB 2>$BB ; then 
				chmod o=rwx "$BATCH_SAVDIR"
				Debug "Directory $BATCH_SAVDIR made"
			else
				Error "Cannot make $BATCH_SAVDIR"
				RC=$?
			fi
		fi

		if [ $RC -eq 0 ] ; then

			Info " -- SAVE : Result is at server. "
			Info " -- SAVE : Location : $BATCH_SAVDIR/$DRWFILE"
			mv $BATCH_PRC/*  $BATCH_SAVDIR/.
			
			Info "**"
                	Info "Drawing file ( $DRWFILE )is saved in the "
                	Info " $BATCH_SAVDIR on remote server $1."
               		Info " Please recover it immediatly.***"
			SAVELOC=2
		fi
	fi

	Debug "Exiting SaveLoc"
	return ${RC}

} # SaveLoc
#
#------------------------------------------------------------------------------
#
# function CleanUp : Will cleanup all needed information from the server. 
#
CleanUp() {

	RC=0
	Debug "Entered CleanUp"

	# remove localy created and stored files.

	if [ -d  $BATCH_PRC ] ; then
		Debug "Remove files in $BATCH_PRC"
		rm -rf $BATCH_PRC/*
	fi

#	if [ -f $LOG_FILE ] ; then
#		rm -f $LOG_FILE
#	fi

	if ((
              echo user $2 $3
              echo delete  $DRWDIR/$SETUP_FILE
              echo quit
              ) | $FTP_OPTION $1 | grep "250 DELE" ) ; then
                Debug "Removed setupfile ($SETUP_FILE) on client"
        else
                Debug "Unable to remove $SETUP_FILE in $DRWDIR on $1"
        fi
	
	#
	# Cleanup the Home ( /usr/rje ) 
	#

	if [ $DEBUG -eq 0 ]; then
		rm -rf $HOME/*.e*
		rm -rf $HOME/*.o*
	fi

	Debug "Exiting CleanUp"
	return ${RC}

} # CleanUp
#
#------------------------------------------------------------------------------
#
#	************************************************************
#	Main program that gets executed when this script is invoked.
#	************************************************************
#
#
#
#  Init globals.
#
RC=0
trap "Info '-INTERRUPT-'"

#
# Debug mode toggle.
#

DEBUG=1
SAVELOC=0

#
# Initialization of global variables.
#
BB=/dev/null
BB=/dev/console

EXNUC=""
MODEL=""
VDS=""

BATCH_PRC_PATH=""	# Working path for the execution process.
BATCH_PRC_DIR=""	# Process subdirectory.
BATCH_SAV_PATH=""	# Processing saving path (partition).
BATCH_SAV_DIR=""	# Resulted execution savings.
BATCH_LOG_FILE="/tmp/BATCH_LOG_FILE"	# Log file name.

BATCH_PRC=""		# Total path for process directory.
BATCH_SAV=""		# Total path for saved executions.
BATCH_SAVDIR=""		# Created subdirecty using BATCH_SAV as reference.
LOG_FILE="/tmp/LOG_FILE"		# Debug log file.
FTP_OPTION=""		# -h option variable for ftp.


#
# At least 6 arguments must be been given to the program
#
if [ $# -lt 6 ] ; then
  echo "Usage : VDbatDrwExt.sh <node_name> <user_name> <passwd> <file_dir>"
  echo "                       <file_name> <setupfile> [prod_name]"
  Info "Usage : VDbatDrwExt.sh <node_name> <user_name> <passwd> <file_dir>"
  Info "		       <file_name> <setupfile> [prod_name]"
  exit 0
fi

#
# Initialize
#
if [ -r $BATCH_LOG_FILE ]; then
        rm -f $BATCH_LOG_FILE
	touch $BATCH_LOG_FILE
fi
 
if [ -r $LOG_FILE ]; then
        rm -f $LOG_FILE
	touch $LOG_FILE
fi

#
# Get the input arguments.
#

NODE=$1
USER=$2
DRWDIR=$4
DRWFILE=$5
SETUP_FILE=$6
if [ $# -gt 6 ]; then 
	PROD_RUNNAME=$7
else
	PROD_RUNNAME="Vds"
fi

#
# Check all global and local variables.
#

CheckPathFile
rc=$?

if [ $rc != 0 ] ; then
	echo "Invalid setup ...."
	exit 0 ;
fi
	
Info "**"
Info "**"
Info "Starting time of extraction :`date`"
Info "**"
Info "**"
Info "REQUEST OWNER   : $NODE.$USER"
Info "REQUEST NAME    : $DRWDIR/$DRWFILE"
Info "REQUEST SETLIST : $DRWDIR/$SETUP_FILE"
Info "**"
Info "**"

if [ -f $LOG_FILE ] ; then
  mailx -s "Extraction $DRWFILE Started" "$USER@$NODE"<$LOG_FILE
fi

if [ `uname -s` = "CLIX" ] ; then
	FTP_OPTION="ftp -h -ni"
else
	FTP_OPTION="ftp -niv"
fi
Debug "FTP_OPTION : $FTP_OPTION"
RC=0
if ProductCheck;then
	if Chdir;then
		if CheckSpace $1 $2 $3 ; then
			if GetFile $1 $2 $3 ; then
				if ExecuteVds; then
					if SendFile $1 $2 $3  ; then
						Debug "  ** SUCCESS"
					else
						Debug "  ** FAILURE !!"
						RC=1
					fi
				fi
			fi
		fi
	fi
fi


if [ $RC -eq 0 ] ; then

	Info "**"
	Info "**"
	Info "Ending time of extraction :`date`"
	Info "**"
	Info "**"
else
	Info "**"
	Info "**"
	Info "Ending time of error :`date`"
	Info "**"
	Info "**"
	ErrorMail "Error occured during processing script"
fi

#
# Check if we need to save the file temporary on the server.
#
SaveLoc ;

if [ -f $LOG_FILE ] ; then
  mailx -s "Extraction $DRWFILE Finished" "$USER@$NODE" <$LOG_FILE
fi

CleanUp $1 $2 $3 ;

set +xv 

Debug "Exiting main"
# KDD if [ $SAVELOC -eq 2 ] ; then
#	mv $LOG_FILE $BATCH_SAVDIR/.
#fi
exit ${RC}



