##########################################################
# FUNCTION: PAS_f_update_file
##########################################################
PAS_f_update_file()
{
  FILE="$1"
  STR="$2"
  VAL="$3"

  #dmb:04/28/93:Add name trimmer for SCO_UNIX
#  TMP_FILE="$TMPDIR/`basename ${FILE}`$$"
  TFILENAME="`basename ${FILE}`$$"
  TFILENAME=`echo $TFILENAME | cut -c1-14`
  TMP_FILE="$TMPDIR/$TFILENAME"

  sed "/^${STR}/s/${STR}.*/${STR}${VAL}/" $FILE >$TMP_FILE
  mv $TMP_FILE $FILE

  echo
  echo "Updating \"$FILE\" to say \"$STR$VAL\""
}
############################################################
# This probably needs work
# FUNCTION: PAS_f_get_pdef_table()
############################################################
PAS_f_get_pdef_table()
{
  #Usage: VAR_LIST="`PAS_f_get_pdef_table 'FILE INFORMATION'`"

  TABLE_NAME=$1

  sed -n -e "/#${TABLE_NAME}/,/#END OF ${TABLE_NAME}/p" $P_DEF |
    sed '1d;s/^#//;$d'
}
############################################################
##########################################################
# FUNCTION: PAS_f_mkdir
##########################################################
PAS_f_mkdir()
{
  DIR=$1
  if [ ! -d "$DIR" ]
  then
    echo mkdir -p "$DIR"   >>$NULL 2>>$NULL
    if mkdir -p "$DIR"
    then
      :
    else
      ### CSS 5.0 bug:  mkdir -p doesn't exit with 0 when successful
      if [ ! -d "$DIR" ]
      then
        echo "Unable to make $DIR"  >>$LOGFILE 2>>$LOGFILE
        exit 1
      fi
    fi
  fi
}
##########################################################
############################################################
# FUNCTION: PAS_f_update_pdef_space_table()
############################################################
PAS_f_update_pdef_space_table()
{
  #Usage: PAS_f_update_pdef_space_table $DLVR_UNIT \
  #          $PROC_TYPE_KEY $COMP_SPACE

  UNIT=$1
  ARCH=$2
  SPACE=$3
  TABLE_NAME="SPACE.ITB"

  TMP_FILE="$TMPDIR/space.itb$$"

  sed -n -e "1,/#${TABLE_NAME}/p" $P_DEF >$TMP_FILE
  sed -n -e "/#${TABLE_NAME}/,/#END OF ${TABLE_NAME}/p" $P_DEF |
      sed "1d;\$d;/${UNIT}	${ARCH}/s/	[^	]*$/	$SPACE/" >>$TMP_FILE
  sed -n -e "/#END OF ${TABLE_NAME}/,\$p" $P_DEF >>$TMP_FILE
  mv $TMP_FILE $P_DEF
}
############################################################
############################################################
# FUNCTION: PAS_f_update_pdef_table()
############################################################
PAS_f_update_pdef_table()
{
  # This definitely needs work...

  #Usage: PAS_f_update_pdef_table 'SPACE.ITB'` \
  #  '$1 == "'$DLVR_UNIT'" && $2 == "'$PROC_TYPE_KEY'" \
  #  { $3 = '$COMPONENT_SPACE'; print; }'

  TABLE_NAME="$1"
  AWK_SCRIPT="$2"
  TMP_FILE="$TMPDIR/table.itb$$"

  sed -n -e "1,/#${TABLE_NAME}/p" $P_DEF >$TMP_FILE
  sed -n -e "/#${TABLE_NAME}/,/#END OF ${TABLE_NAME}/p" $P_DEF |
      sed '1d;s/^#//;$d' |
      awk "BEGIN {FS=OFS=\"	\";} ${AWK_SCRIPT} { print; }" - |
      sed 's/^/#/' >>$TMP_FILE
  sed -n -e "/#END OF ${TABLE_NAME}/,\$p" $P_DEF >>$TMP_FILE
  mv $TMP_FILE $P_DEF
}
############################################################
