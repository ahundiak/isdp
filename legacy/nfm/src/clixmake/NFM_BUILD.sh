#-----------------------------------------------------------------------------
#
#         For Automation of NFM Build Procedure
#
#         1.  Fetches all the latest files from SPC
#         2.  Prepares the list of latest files fetched
#         3.  Builds the NFM Libraries and Executables
#
#  Usage:
#    Run CH_VER before using this script to update the NFM Version Number
#
#                                          ---- Jujare      3 March 1995 
#
#-----------------------------------------------------------------------------

set -v

export VER_DIR=`cat LOG/version.nfm`
export SPC_LOC=$HOME/$VER_DIR
export SPC_LOG=$HOME/LOG

################################
#  These are needed for compare.out 

export PROJECTDIR=$SPC_LOC
export NFMDEVDIR=$SPC_LOC 
export SPC_PROJECT=nfm
export SPC_LIB=/usr3/nfm_spc/spc/nfm

echo   "`date +%y%m%d`"                       > $SPC_LOG/today
date
export TODAY_DATE=`cat $SPC_LOG/today`

export LOG_FILE=$SPC_LOG/$TODAY_DATE.log
export OUT_FILE=$SPC_LOG/$TODAY_DATE.cmp
export NEWER=' -newer $SPC_LOC/project.tim '
export RESERVATIONS="$SPC_LOG/reservations"
export FILE_LIST=$SPC_LOG/$TODAY_DATE.out
 
echo  "\nFETCH on `date`: \n\n"                 >> $LOG_FILE
echo  "Sources being Fetched into $NFMDEVDIR"   >> $LOG_FILE
echo  "Newer than $SPC_LOC/project.tim \c"      >> $LOG_FILE
echo  "   -- dated `ls -ld $SPC_LOC/project.tim |\
	awk '{ print $6, $7, $8 }'`\n"          >> $LOG_FILE
echo  "NEWER = $NEWER\n"                        >> $LOG_FILE

spc  -q <<-END
cd   $NFMDEVDIR   > /usr/tmp/spc.out
set  proj nfm     > /dev/null
show defaults     > /usr/tmp/default.out
END

echo "Verifying the SPC defaults ...\n"        >> $LOG_FILE

$SPC_LOG/compare.out $LOG_FILE 
if [ $? != 0 ]
then
    echo "Error in verifying spc defaults"     >> $LOG_FILE
    echo "Exiting build...\n"                  >> $LOG_FILE
    exit 1
fi

echo "Verified the SPC default Information\n"  >> $LOG_FILE

  #---------------------------------------------------------------------------
  #    Fetch the files from the spc system.  It will only fetch the files
  #    from the spc system that are newer that the files on the build
  #    machine.  This should be the files that were checked in since
  #    the last time this shell was ran.
  #---------------------------------------------------------------------------

echo "Now Fetching Files ... "                >> $LOG_FILE

spc  -q <<-END
cd     $NFMDEVDIR     >> $LOG_FILE
set    proj nfm       >> $LOG_FILE
show   defaults       >> $LOG_FILE
fetch  project -touch -all -newer -overwrite   > $OUT_FILE
set    proj nfm       >> $LOG_FILE
cd     $NFMDEVDIR     >> $LOG_FILE
fetch  project.tim -overwrite      >> $LOG_FILE
show   project reservations -all   > $RESERVATIONS
END

VER_FILE=$SPC_LOG/version.nfm
RELEASE_VER=`cat $VER_FILE | cut -c1-0`
DATE=`date +%m`/`date +%d`/`date +%y`

spc  -q  <<-END
set      project  nfm      >> $LOG_FILE
cd       $NFMDEVDIR        >> $LOG_FILE
reserve  -nocopy -comment 'Touching tstamp times - $DATE - Jujare' \
         project.tim       >> $LOG_FILE
replace  -comment 'Touching tstamp times - $DATE - Jujare' \
         project.tim       >> $LOG_FILE
set      project  nfm      >> $LOG_FILE
create   project release -comment 'Release created - $DATE: Jujare' \
         -all $RELEASE_VER >> $LOG_FILE
END

echo "Finished creating release: `date`"         >> $LOG_FILE

echo "Preparing the List of Latest Files ... "   >> $LOG_FILE

( cd $VER_DIR;
list=` /bin/ls                  |
       egrep -v "^ads$"         |
       egrep -v "^binc100$"     |
       egrep -v "^binc400$"     |
       egrep -v "^binpc$"       |
       egrep -v "^bintcp$"      |
       egrep -v "^binvax$"      |
       egrep -v "^cfg$"         |
       egrep -v "^deliver_dp$"  |
       egrep -v "^deliver_srv$" |
       egrep -v "^deliver_ui$"  |
       egrep -v "^libc100$"     |
       egrep -v "^libc400$"     |
       egrep -v "^make$" `

find $list $NEWER ! -name '*.[0-9oal]' ! -type d  ! -name 'project.tim' \
                    ! -name 'line.count' ! -name '*.set' \
                      -print  )                         >  $FILE_LIST

echo "Finished Preparing the List of Latest Files ... " >> $LOG_FILE

echo "Building NFM libraries ..."                       >> $LOG_FILE

(cd $VER_DIR/make; makeall c100400 )

echo "Finished Building NFM libraries ..."              >> $LOG_FILE

echo "Building NFM Executables..."                      >> $LOG_FILE

(cd $VER_DIR/make; makeexec c100400 )

echo "Finished Building NFM Executables..."             >> $LOG_FILE

