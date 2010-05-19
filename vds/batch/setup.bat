#!/bin/ksh
#***********************************************************************
#
#	Setting global variables for Batch Process Control.
#
#***********************************************************************

#
# Give the path were user can execute the batch process and were the user
#	will store executed version when connection with client system is
#	broken.
#	The client will be informed by 'mail'.
#	When 'BATCH_SAV_PATH' is not specified, 'BATCH_PRC_PATH' will be
#	used.
#
# export	BATCH_PRC_PATH="/usr/tmp"
# export	BATCH_SAV_PATH="/usr/tmp"



#
# Give the name of subdirectory in which the server process till store the
#	files to execute.
#
# export	BATCH_PRC_DIR="vdsbatch"



#
# Give the name of subdirectory where server can store execution results 
#	when the client system went down during execution.
#
# export	BATCH_SAV_DIR="vds_save"



#
# Give the name of 'log' file to be used to store process information.
#
# export	BATCH_LOG_FILE="vdbatch.log"

