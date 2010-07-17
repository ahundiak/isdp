#!/bin/ksh
#***********************************************************************
# I/ROUTE
#
# File:		PmaBatch.sh
#
# Description:	This shell script is used for running batch extraction of
#		drawings. This script, when invoked reads setup file,
#		initiates a ROUTE session in batch , and executes an extract
#		for review batch drawing on the design file.  Dm2 is then 
#		iinformed and the design file are fetch to DM2.
#
#
# Usage :	PmaBatch.sh	<node_name>
#				<user_name>
#				<passwd>
#				<cmdfile>
#				<script>
#
#		where:
#
#		"<node_name>"	the node_name of the server/this  system.
#				Server system is the system executing the  
#				extract for review drawing process in batch.
#		"<user_name>"	local username login.
#		"<passwd>"	local passwd of "<user_name>" login.
#		"<cmdfile>"	ASCII file contain list of support files
#				needed for drawing extraction. These 
#				files are copy to local machine from PMU/PDM.
#		"<script>"	name of the exection script file.
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
#	   2) It is checked to see if product I/ROUTE exists.If no, program 
#             is aborted. If product exists then it is checked to see if 
#             I/ROUTE is in active state already. If yes, batch request 
#	      execution is stopped and this message is informed  to client. 
#
#	   3) It is checked if directory $BATCH_DIR exists. If it does not
# 	      exist, $BATCH_DIR is created. Then working directory is
#	      changed to $BATCH_DIR.
#
#	   4) The command for batch extraction of drawings is executed in 
#	      batch mode.
#	      It is assumed that return status of batch extraction ( result of
#	      executing PPL program) is written to file /usr/tmp/pmabatch.sts.
#	      The return status can be either '1' ( SUCCESS) or '0' ( FAILURE ).
#	      Return status of batch extraction is checked. 
#	      If it is '0' program is aborted.
#
#	      If the file '/usr/tmp/pmabatch.sts' not found, it is assumed
#	      that the batch extraction has been completed successfully.
#
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
#	   /usr/tmp/pmabatch is created and design file is pulled there.
#
#	   File /usr/tmp/pmabatch.dbg contains suceess or failure of each step.
#	   The file gives an idea about success or failure of each step and 
#	   program.
#
#****************************************************************************
#
#
#------------------------------------------------------------------------------
Debug() {

	if [ $DEBUG -eq 1 ] ; then
		if [ "$LOG_FILE" = "" ] ; then
			echo " ** $*" >> /dev/console
		else
			echo " ** $*" >> "$LOG_FILE"
		fi
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

	return 0
} # Error
#
#-------------------------------------------------------------------------------
#
# Checking of Product paths 
#
CheckPathFile() {

	RC=0

	ROUTE=`echopath Route`
        E4R=`echopath Extr4rvw`

	if [ "$ROUTE" = "" ] ; then
		RC=1
                echo "Product I/ROUTE not found." >> /dev/console
                exit 1
	fi

#
#	Execute the setup file and see if variables are set.
#


	if [ "$BATCH_PRC_PATH" = "" ] ; then
		BATCH_PRC_PATH="/usr/tmp"
	fi

	if [ "$BATCH_SAV_PATH" = "" ] ; then
		BATCH_SAV_PATH="$BATCH_PRC_PATH"
	fi


	#
	# remove debug file if it exists
	#
	if [ "$BATCH_LOG_FILE" = "" ] ; then
		BATCH_LOG_FILE="pm$DRWFILE.log"
	fi

	if [ "$POST_LOG_FILE" = "" ] ; then
		POST_LOG_FILE="ps$DRWFILE.log"
	fi

	LOG_FILE="/usr/tmp/$BATCH_LOG_FILE" 
	PS_LOG_FILE="/usr/tmp/$POST_LOG_FILE" 

	if [ -f $LOG_FILE ] ; then
		rm -f $LOG_FILE
	fi


	Debug "BATCH_PRC : $BATCH_PRC "
	Debug "BATCH_SAV : $BATCH_SAV "
	Debug "LOG_FILE  : $LOG_FILE "

#
#	Check the needed product paths.
#

	EXNUC=`echopath Exnuc`
	MODEL=`echopath Model`
        VDS=`echopath Vds`
        STRUCT=`echopath Struct`

	if [ "$EXNUC" = "" ] ; then
		RC=1
		Error "Product I/EXNUC not found."
	else if [ "$MODEL" = "" ] ; then
			RC=1
			Error "Product I/MODEL not found." 
	     else if [ "$VDS" = "" ] ; then
			RC=1
                        Error "Product I/VDS not found."
                  else if [ "$STRUCT" = "" ] ; then
                             RC=1
                             ERROR "Product I/STRUCT not found."
                       fi
		  fi
	     fi
	fi
	if [ $RC -eq 0 ];then
		Debug "Found I/EXNUC, I/MODEL, I/VDS, I/STRUCT product paths"
	fi

	Debug "EXNUC : $EXNUC "
	Debug "MODEL : $MODEL "
	Debug "VDS   : $VDS "
        Debug "STRUCT: $STRUCT "

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

	if ( dates i_route | grep "I_ROUTE" >$BB ); then
	    Debug "I/ROUTE found"
	    if (test `ps -ef | grep  -c "$MODEL/bin/Model -p Route"`\
                                                               -gt 1 );then
	    	Error "Model is already active on remote machine"
	        Error "Cannot submit batch request, process already active."
		RC=1
	    fi
	else
	    Error "I/Route not found"
	    RC=1
	fi

	Debug "Exiting ProductCheck"
	return ${RC}

} # ProductCheck
n
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
		if mkdir -m 777 -p "$BATCH_PRC" >$BB 2>$BB
		then
			chmod o=rwx "$BATCH_PRC"
			cd $BATCH_PRC
			RC=$?
               		if [ RC -ne 0 ] ; then
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
# function ExecuteRoute : Executes I/ROUTE in batch mode. 
#                         It executes the command
#			  "ci=PDU_E4RB" in batch mode. The ppl should have
#			   necessary commands for batch extraction of drawings.
#
# 
# Usage	: ExecuteRoute
#
ExecuteRoute() {

	RC=0
	Debug "Entered ExecuteRoute"

	Info "PROCESS : $DRWFILE"

	/* 
	   copy the command file to e4rcmd.txt so e4r can read from it 
   	   to get the PME server name
	*/
        cp $BATCH_PRC/$CMDFILE $BATCH_PRC_PATH/$E4RCMD


	if ( $EXNUC/bin/drive $MODEL/bin/Model -p Route -b -f $BATCH_PRC/$DRWFILE  -C "ci=$E4R/bin/pma/PDU_E4RB">>$LOG_FILE 2>&1 ); then
 		if [ -f /usr/tmp/pma/$DRWFILE.dri ] ; then
			Info "Batch Extraction Finished"
		else
			RC=1
			Error "Extract for Reivew Batch Extraction Failed."
			Debug "Failed in command"
		fi
	fi

	Debug "Exiting ExecuteRoute"
	return ${RC}

} # ExecuteRoute


#
#------------------------------------------------------------------------------
# 
#	Function ExecutePost_DM2:  This function execute the Post_DM2.exe
#				   executable that connects to the DM2 server
#                                  through the Postman executable by way of
#                                  the PROXY_CLIENT_ADDRESS, and executes
#                                  DM2 commands.
#                                  Commands that get executed are:
#
#					1)  FTP extracted files to DM2
#					2)  Register extracted files in DM2
#					3)  Attach extracted files to context
#					4)  Populate File class/table with
#					    extraction information.
#
#
#
ExecutePost_DM2() {

        RC=0
        Debug "Entered ExecutePost_DM2"

  	/* invoke the post_dm2 executable to post the files to PME database */
  	if( $E4R/bin/pma/Post_DM2.exe $NODE $USER $PSWD $BATCH_PRC $DRWFILE $CONTEXTID $CONTEXTNO $SERVER); then
        	RC=0
        	Debug "Posting to DM2"
        fi

        Debug "Exiting ExecutePost_DM2"
        return ${RC}

} # ExecutePost_DM2



#
#------------------------------------------------------------------------------
#
# function CleanUp : Will cleanup all needed information from the server. 
#
CleanUp() {

	RC=0
	Debug "Entered CleanUp"

	# remove locally created and stored files.

	if [ -d  $BATCH_PRC ] ; then
        	/* cd to /usr/tmp and remove /usr/tmp/pmabatch */
        	cd $BATCH_PRC_PATH
		Debug "Remove files in $BATCH_PRC"
		rm -rf $BATCH_PRC/*
		rm -rf $BATCH_PRC/.r*
        	rm -r $BATCH_PRC
                rm /usr/tmp/"$SCRPT.sh"
                rm /usr/tmp/e4rcmd.txt
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
rc=0
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

EXNUC=""
MODEL=""
ROUTE=""

BATCH_PRC_PATH=""	# Working path for the execution process (/usr/tmp).
BATCH_PRC_DIR=""	# Process subdirectory ( pmabatch ).
BATCH_SAV_PATH=""	# Processing saving path (/use/tmp ).
BATCH_SAV_DIR=""	# Resulted execution savings( pma_save ).
BATCH_LOG_FILE=""	# Log file name (pmabatch.log ).

BATCH_PRC=""		# Total path for process directory(/usr/tmp/pmabatch).
BATCH_SAV=""		# Total path for saved executions(/usr/tmp/pma_save).
BATCH_SAVDIR=""		# Created subdirecty using BATCH_SAV as reference.
LOG_FILE=""		# Debug log file.
POST_LOG_FILE=""	# Posting to PME log filename
PS_LOG_FILE=""		# Posting to PMR log file path


uid=$(id | awk '{print $1'}| sed 's/^.*(\(.*\))/\1/' )
if [ $uid != "rje" ]
        then echo "Must be logged in as rje to execute script"; exit 1;
fi

#
# check if 5 arguments have been given to the program
#
if [ $# != 5 ] ; then
  echo "Usage : PmaBatch.sh <node_name> <user_name> <passwd> <cmdfile> <script>"
  Info "Usage : PmaBatch.sh <node_name> <user_name> <passwd> <cmdfile> <script>"
  exit 0
fi

#
# Get the input arguments.
#

NODE=$1
USER=$2
PSWD=$3
CMDFILE=$4
BATCH_PRC_DIR="pma"
E4RCMD="e4rcmd.txt"
SCRPT=$5

DRWFILE=""
FILECOUNT=""
CONTEXTID=""
CONTEXTNO=""
SERVER=""
MAILADDR=""

#
# Check all global and local variables.
#

	
BATCH_PRC="/usr/tmp/$BATCH_PRC_DIR" 

DRWFILE=`cat $BATCH_PRC/$CMDFILE | awk '/\FILENAME:\ /{ print $2 }'`
if [ "DRWFILE" = "" ] ; then
    RC=1
    Error "The command file did not have a drawing file name given."
fi

if ! CheckPathFile ; then
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
Info "REQUEST SETLIST : $SETUP_FILE"
Info "**"
Info "**"


SERVER=`cat $BATCH_PRC/$CMDFILE | awk '/\SERVER:\ /{ print $2 }'`
if [ "SERVER" = "" ] ; then
    RC=1
    Error "The command file did not have a server name given."
fi

FILECOUNT=`cat $BATCH_PRC/$CMDFILE | awk '/\FILENO:\ /{ print $2 }'`
if [ "FILECOUNT" = "" ] ; then
    RC=1
    Error "The command file did not have the files count."
fi

if ProductCheck;then
	if ExecuteRoute;then
   		Debug "  ** SUCCESS"
	else
   		Debug "  ** FAILURE !!"
   		rc=1
 	fi
fi

Info "**"
Info "**"
Info "Ending time of extraction :`date`"
Info "**"
Info "**"

/* get the context id from the commancd file */
CONTEXTID=`cat $BATCH_PRC/$CMDFILE | awk '/\CXT_ID:\ /{ print $2 }'`
if [ "CONTEXTID" = "" ] ; then
 	RC=1
  	Error "The command file did not have a context id given."
fi

CONTEXTNO=`cat $BATCH_PRC/$CMDFILE | awk '/\CXT_NO:\ /{ print $2 }'`
if [ "CONTEXTNO" = "" ] ; then
 	RC=1
  	Error "The command file did not have a context no. given."
fi

/* invoke the post_dm2 executable to post the files to PME database, 
   and also reset the pipe queue.
*/
if [ $RC -ne 1 ]; then
	if ExecutePost_DM2; then
	 	RC=0
		Debug "Posting Complete"
	fi
fi


MAILADDR=`cat $BATCH_PRC/$CMDFILE | awk '/\MAIL_ADDR:\ /{ print $2 }'`
if [ "MAILADDR" = "" ] ; then
 	RC=1
  	Error "The command file did not have a mail address given."
else
	if [ $RC -eq 0 ] ; then
		mailx -s "Context Assembly Process for $DRWFILE is Finished" "$MAILADDR" 
	else
		mailx -s "Context Assembly Process for $DRWFILE is Finished" "$MAILADDR" < $LOG_FILE
	fi		
fi

if [ "MAILADDR" = "" ] ; then
 	RC=1
  	Error "The command file did not have a mail address given."
else
	mailx -s "Posting Extracted Files for $DRWFILE is Finished" "$MAILADDR" < $PS_LOG_FILE
fi
CleanUp;

Debug "Product Model Assembly Process Finished"
Debug "Exiting main"
exit ${rc}



