# Do not alter this SPC information: $Revision: 1.1.55.1 $
#############################################################################
#
# file:		build/send.vax
#
# usage:	send.vax
#		 or
# 			send.vax <node.user.passwd>
#
# purpose:	to build one or all of the RIS servers on a VAX/VMS system.
#
# If a specific database server is desired, all source will be sent, 
# but only the specified database server will be built.
#
# This script uses the local unix environment variable RIS_VERS to determine
# the current version to be built, then on the VAX/VMS system, it creates
# the directory [.$RIS_VERS] as a root directory. It creates all the needed
# directories on the VAX, and sends all the needed files to the correct
# directories using FMU.  It also creates a file [.build]batch.vax that
# will be submitted to the batch que and executed in the background.
#
# The [.build]batch.vax will rename it's process to node_RISbatch (where
# node is the value returned from the "uname -n" shell command) and
# then spawns [.build]build.com to build RIS servers. Afterwards the
# background job will mail the log file to the user who started the job.
#
# [.build]build.com renames it's process to "RIScommon" and sets it's 
# process priority to a faster pace, then it calls on [.build]make.vax
# for each of the database system servers that need to be built.
#
# [.build]make.vax calls on [.-.<dir-name>]make.vax in each directory
# that has source files. These make.vax files are very small. They setup
# some symbols and call [.build]maketplt.vax. This is a single template
# file that is used to compile all of the source files. This file reads
# the directory's <dir-name>vax.m file for the list of source files to
# be compiled.
#
# [.build]build.log is a log file of the complete build session.
# The log file will be about 37 blocks in size (vax blocks) and have
# about 650 lines (when no errors have occured). If the
# session was completed without error, you should see a line at the
# end of the file like this:
# "**************** RIS BUILD COMPLETE ********** *********"
# You may use 'grep' to find errors by searching for a percent sign "%"
# which is the begining of all VAX/VMS error messages.
# Our error messages have "ERROR" in them.
#
##############################################################################

	#
	# if the first parameter is not specified, set it.
	#
if [ -z "$1" ] ; then
	machine=risvax.mcintyre.terry
else
	machine=$1
fi

	#
	# if the environment variable RIS_VERS is not set, we exit.
	#
if [ -z "$RIS_VERS" ] ; then
	echo "Environment variable RIS_VERS must be set (0_7_17 or something)."
	exit 1
fi

	#
	# create a file that will be submitted to a batch que and executed in the
	# background. It will spawn a process to build RIS. Afterwards it will
	# mail the log file to the user who started the job
	#

node=`uname -n`
echo "\$ set proc/name=\"${node}_RISbc\"" >  batch.vax
echo "\$ set proc/priv=all\"" >>  batch.vax
echo "\$ set default [.$RIS_VERS.build]" >> batch.vax
echo "\$ spawn/out=build.log @build.com $2" >> batch.vax
#echo "\$ mailx $node.$LOGNAME -s \"VAX BUILD log file\"  < build.log" >> batch.vax

	#
	# lets watch what is being sent to the vax
	#
echo "
com cre/dir/version_limit=2 [.$RIS_VERS]
rcd $RIS_VERS
com cre/dir/version_limit=2 [.build]
com cre/dir/version_limit=2 [.include],[.lib]
com cre/dir/version_limit=2 [.net],[.net.prt],[.comm]
com cre/dir/version_limit=2 [.comm.prt],[.arch],[.arch.prt]
com cre/dir/version_limit=2 [.commint]
com sho def
send batch.vax [.build]
send build.com [.build]
send make.vax [.build]
send maketplt.vax [.build]
" | fmu $machine

echo "
rcd $RIS_VERS
send ../../riscom/arch/*c [.arch]
send ../../riscom/arch/prt/* [.arch.prt]
send ../../riscom/arch/*vax* [.arch]
send ../../riscom/common/*c [.comm]
send ../../riscom/common/prt/* [.comm.prt]
send ../../riscom/common/*vax* [.comm]
send ../../riscom/include/*h [.include]
send ../../riscom/internal/* [.commint]
send ../../riscom/network/*c [.net]
send ../../riscom/network/prt/* [.net.prt]
send ../../riscom/network/*vax* [.net]
rcd [.build]
com submit batch.vax
" | fmu $machine
rm batch.vax
