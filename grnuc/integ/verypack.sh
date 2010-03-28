#
# Synopsis
#
#	verypack.sh [-p] <package definition file>
#
# $Log: verypack.sh,v $
# Revision 1.3  2002/02/07 23:02:32  hans
# removed -s"Packaging errors" from $MAILER
#
# Revision 1.2  2002/02/06 23:29:32  hans
# *** empty log message ***
#
# Revision 1.1.1.1  2001/12/17 22:40:08  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:50  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:23:29  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/08/28  06:05:20  grnuc32
# COMMENT : Corrected error mailing problems for TD and xgl
#
# Revision 320.1  1995/01/03  08:43:05  grnuc32
# COMMENT : Checking in from 4.0
#
# Revision 400.3  1994/07/05  20:06:52  dodd
# COMMENT : Creating new script that will force status of TR/CR to 1I and making verypack.sh a little bit smarter - JSD
#
# Revision 400.2  1994/06/09  15:41:12  dodd
# COMMENT : Making the output a little more meaningful - now gives excellent results of the difference between TARGETDIR and product.def - JSD
#
# Revision 400.1  1994/05/19  15:35:42  dodd
# COMMENT : Added CSHARED code to the find from the package.def file and made sure we cd to the target directory before doing the find - JSD
#
# Revision 400.0  1994/03/16  16:28:19  grnuc40
# COMMENT : Initial checkin to 4.0 RCS
#
# Revision 240.1  1993/09/14  18:10:39  grnuc20
# COMMENT : Changing mail path from tim and/or c10138 to BUILDER - JSD
#
# Revision 240.0  1993/03/04  14:30:18  grnuc20
# COMMENT : baselining fixes from the build commando effort
#
# Revision 220.0  1993/02/19  21:59:03  model22
# COMMENT : Moved from /usr2/ip32/integ to /integ
#
# Revision 201.3  1992/09/28  21:38:14  model20
# COMMENT : display name of machine verifying
#
# Revision 201.2  1992/09/28  13:17:44  ems20
# COMMENT : rearranged code to handle everything verifying correctly
#
#

USAGE="$0: [-p] <package definition file>"

set_defaults ()
{

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  MAILER=elm
else
  MAILER=Mail
fi

rm -f /usr/tmp/verylist /usr/tmp/veryerr

REPORT=1
PRIVATE="SHARED"

if [ "${XVERSION}" = "y" ]
 then
   PARAM=4
else
   if [ "$SUN" = "y" ]
    then
      PARAM=3
   else
      PARAM=2
   fi
fi

while [ $# -gt 1 ]
do
  if [ "$1" = "-r" ]; then REPORT=0; fi
  shift
done

if [ $# != 1 ]; then echo ${USAGE}; exit 1; fi
if [ ! -f $1 ]; then echo $1 is not a file; exit 1; fi
if [ ! -r $1 ]; then echo $1 is not readable; exit 1; fi

if [ ${REPORT} = 0 ]; then ECHO=echo; else ECHO=""; fi

INFILE=$1

LNODE=`uname -n`

}

get_source_files ()
{

cd $TARGETDIR

cat ${INFILE} | while read LINE
do
  set blap ${LINE}; shift
  if [ $# != 0 ]; then

    if [ "$1" = "private:" ]; then
      PRIVATE=$2
    fi

    if [ "$PRIVATE" = "SHARED" ] || [ "$PRIVATE" = "CSHARED" ]
     then
      CONTINUE="y"
    else
     if [ "$PRIVATE" = "SUN" ] && [ "$SUN" = "y" ]
      then
       CONTINUE="y"
     else
      if [ "$PRIVATE" = "CLIPPER" ] && [ "$SUN" != "y" ]
      then
       CONTINUE="y"
      else
       CONTINUE="n"
      fi
     fi
    fi
    if [ "$CONTINUE" = "y" ]
    then
      if [ "$1" = "source:" ]; then
        echo > /dev/null
      else if [ "$1" = "target:" ]; then
        echo > /dev/null
      else if [ "$1" = "targetuser:" ]; then
        echo > /dev/null
      else if [ "$1" = "targetpath:" ]; then
        PRELIST="$(basename $2)/"
        if [ "$(echo $PRELIST | cut -c1-3)" = "$(echo $LOGNAME | cut -c1-3)" ]
        then
          PRELIST=
        fi
      else if [ "$1" = "prodfile:" ]; then
        LIST=
      else if [ "$1" != "endprodfile:" ]; then
        LIST="${LIST} ${PRELIST}$*"
      else
         find ${LIST} -print >> /usr/tmp/verylist2 2>>/usr/tmp/veryerr
      fi;fi;fi;fi;fi;fi
    fi
  fi
done
sort -u /usr/tmp/verylist2 > /usr/tmp/verylist
rm -f /usr/tmp/verylist2

}

get_target_files ()
{

find . -print | cut -d'/' -f2- > /usr/tmp/totlist2
sort -u /usr/tmp/totlist2 > /usr/tmp/totlist
rm -f /usr/tmp/totlist2

}

get_common_files ()
{

cd $SOURCEDIR

PRIVATE="COMMON"

cat ${INFILE} | while read LINE
do
  set blap ${LINE}; shift
  if [ $# != 0 ]; then

    if [ "$1" = "private:" ]; then
      PRIVATE=$2
    fi

    if [ "$PRIVATE" = "COMMON" ]
    then
     CONTINUE="y"
    else
     CONTINUE="n"
    fi

    if [ "$CONTINUE" = "y" ]
    then
      if [ "$1" = "source:" ]; then
        echo > /dev/null
      else if [ "$1" = "target:" ]; then
        echo > /dev/null
      else if [ "$1" = "targetuser:" ]; then
        echo > /dev/null
      else if [ "$1" = "targetpath:" ]; then
        PRELIST="$(basename $2)/"
        if [ "$(echo $PRELIST | cut -c1-3)" = "$(echo $LOGNAME | cut -c1-3)" ]
        then
          PRELIST=
        fi
      else if [ "$1" = "prodfile:" ]; then
        LIST=
      else if [ "$1" != "endprodfile:" ]; then
        LIST="${LIST} ${PRELIST}$*"
      else
         find ${LIST} -print >> /usr/tmp/commonlist2 2>>/usr/tmp/commonerr
      fi;fi;fi;fi;fi;fi
    fi
  fi
done
sort -u /usr/tmp/commonlist2 > /usr/tmp/commonlist
rm -f /usr/tmp/commonlist2 /usr/tmp/commonerr

}

package_def_diffs ()
{

if [ -s /usr/tmp/veryerr ]
then
  echo "FILES IN package.def BUT NOT IN INTEGRATION AREA" > /usr/tmp/veryerr2
  echo "================================================" >> /usr/tmp/veryerr2
  echo $LOGNAME >> /usr/tmp/veryerr2
  uname -a >> /usr/tmp/veryerr2
  echo "================================================" >> /usr/tmp/veryerr2
  echo >> /usr/tmp/veryerr2
  sort -u /usr/tmp/veryerr >> /usr/tmp/veryerr2
  rm /usr/tmp/veryerr
  $MAILER  $BUILDER < /usr/tmp/veryerr2
else
  rm -f /usr/tmp/veryerr
fi

}


integration_diffs ()
{

diff /usr/tmp/totlist /usr/tmp/verylist > /usr/tmp/verydiff

if [ -s /usr/tmp/verydiff ]
then
 echo "FILES IN INTEGRATION AREA BUT NOT package.def" > /usr/tmp/verydiff2
 echo "=============================================" >> /usr/tmp/verydiff2
 echo $LOGNAME >> /usr/tmp/verydiff2
 uname -a >> /usr/tmp/verydiff2
 echo "=============================================" >> /usr/tmp/verydiff2
 echo >> /usr/tmp/verydiff2
# grep "<" /usr/tmp/verydiff | cut -d'<' -f2- >> /usr/tmp/verydiff2

  echo "C: File is packaged in a COMMON file" >> /usr/tmp/verydiff2
  echo "N: File is not packaged at all\n" >> /usr/tmp/verydiff2

  for file in $(grep "<" /usr/tmp/verydiff)
  do
    if [ "$file" = "<" ] || \
       [ "$file" = "." ]
    then
      continue
    fi

    grep "^${file}$" /usr/tmp/commonlist 2>&1 >/dev/null
    if [ "$?" = "0" ]
    then
      if [ ! -d "$file" ]
      then
        echo "C: $file" >> /usr/tmp/verydiff3
      fi
    else
      if [ ! -d "$file" ]
      then
        echo "N: $file" >> /usr/tmp/verydiff3
      fi
    fi
  done
  sort -u /usr/tmp/verydiff3 >> /usr/tmp/verydiff2



 $MAILER  $BUILDER < /usr/tmp/verydiff2
 rm -f /usr/tmp/verydiff3
else
  rm -f /usr/tmp/verydiff
fi

}

clean_up ()
{

rm -f /usr/tmp/totlist /usr/tmp/verylist /usr/tmp/veryerr2
rm -f /usr/tmp/verydiff /usr/tmp/verydiff2 /usr/tmp/commonlist

}

set_defaults $*
get_common_files
get_source_files
get_target_files
package_def_diffs
integration_diffs
clean_up
