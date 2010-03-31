#
# checkmk.sh - makes the makefiles
# 
#    Usage  : checkmk.sh [ relative_directory ...]
#    Inputs : $*=directories relative to $MODEL
#    Output : makefile and makefile.m files
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: checkmk.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:06:55  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#
#

verifyenv MODEL MDTARG 

# if an argument is given set LIST to $*
if [ $# -gt 0 ]
then
   LIST="$*"
else

  if [ "$ISL" = "y" ]
  then
    LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/islnomake`
  fi

  if [ "$SUN5" = "y" -o "$SUNZX" = "y" ]
  then
    LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/sunnomake`
  fi

  if [ "$SGI" = "y" ]
  then
    LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/sginomake`
  fi

  if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
  then
    LIST=`cat $MODEL/integ/makelist`
  fi
fi

cd $MODEL

echo $LIST
for f in $LIST
do
  cd $f
  if [ -f spec.m ]
  then 
    export SOURCE=$MODEL/$f
    export TARGET=$MDTARG/$f
    make -f $MODEL/integ/MakeMFLS
    if [ ! -f ${MDTARG}/$f/makefile ]
    then
      echo Remaking makefile in $MDTARG/$f
      $EXTARG/bin/makemake ${MKMKOPT} spec.m $MDTARG/$f/makefile
      if [ `grep 'SOURCE=grp3' $MODEL/$f/spec.m` ]
      then 
        replace "objects =" "objects = \$\(grp1\) \$\(grp2\) \$\(grp3\)" ${MDTARG}/$f/makefile
      else
        if [ `grep 'SOURCE=grp2' $MODEL/$f/spec.m` ]
        then
          replace "objects =" "objects = \$\(grp1\) \$\(grp2\)" ${MDTARG}/$f/makefile
        fi
      fi
      echo copying $MDTARG/$f/makefile to $MDTARG/$f/makefile.m
      ncp $MDTARG/$f/makefile $MDTARG/$f/makefile.m
      replace ".o :" "\$(NODEP).o :" $MDTARG/$f/makefile
      ed $MDTARG/$f/makefile < $MODEL/integ/rmdeped > /dev/null
      echo
      echo
    fi

    if [ ! -s $MDTARG/$f/makefile ]
    then
      errrpt $0 "makefile empty in $MDTARG/$f"
      echo "makefile did not make in $MDTARG/$f" > /tmp/bldlog.$$
      errchk /tmp/bldlog.$$ checkmk.sh
    fi

    if [ ! -s $MDTARG/$f/makefile.m ]
    then
      errrpt $0 "makefile.m empty in $MDTARG/$f"
      echo "makefile.m did not make in $MDTARG/$f" > /tmp/bldlog.$$
      errchk /tmp/bldlog.$$ checkmk.sh
    fi
  fi

  cd -
done

