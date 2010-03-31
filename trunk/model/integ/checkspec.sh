#
# checkspec.sh - compare contents of spec.m with that of the current directory
# 
#    Usage  : checkspec.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/15/93
# $Log: checkspec.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:06:56  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:14:50  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:47:26  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/03/03  16:53:01  model22
# COMMENT : baselining from the build team commando effort
#
# Revision 220.4  1993/02/15  21:13:08  model20
# COMMENT : fixes for unit testing
#
#
#


if [ `ls spec.m | wc -l` != 0 ]
 then
 UNQ=`echo $$`
 for file in `ls spec.m`
 do
     INFILE=$file
     SRC_START=off
     cat ${INFILE} | while read LINE
     do
      LINE=`echo $LINE | cut -d'=' -f1`
      set blap ${LINE}; shift
      if [ $# != 0 ]
      then
        if [ "$1" = "SOURCE" ]
        then
          SRC_START=on
          touch /tmp/filelist.${UNQ}
        else
         if [ $SRC_START = on ]
         then
           if [ "$1" = "RULES" ]
           then
             SRC_START=off
           else
            echo $1 >> /tmp/filelist.${UNQ}
           fi
         fi
        fi
      fi
     done
 done

 sort -u /tmp/filelist.${UNQ} > /tmp/cmplist.${UNQ}

# CHECK FOR POSSIBILITY OF .c WITH PARENT .[ICS]

 rm -f /tmp/loclist.${UNQ} 

 for f in *.[ISCct]
 do
   bname=`echo $f | cut -d. -f1`
        
   if [ "$f" = "${bname}.c" ]
   then 
     if [ ! -f ${bname}.[ICS] ]
     then
       echo $f >> /tmp/loclist.${UNQ}     
     else
       echo "$f has a parent source file...ignored"
     fi
   else
     echo $f >> /tmp/loclist.${UNQ}
   fi
 done     

 sort -u /tmp/loclist.${UNQ} > /tmp/loclists.${UNQ}

 mv /tmp/loclists.${UNQ} /tmp/loclist.${UNQ}
   
 if diff -b /tmp/cmplist.${UNQ} /tmp/loclist.${UNQ} > /dev/null
 then
   echo spec.m and directory contents in sync
 else
   echo spec.m and directory contents out of sync - fixing spec.m
   fixspec.sh
 fi
 rm /tmp/filelist.${UNQ} /tmp/cmplist.${UNQ} /tmp/loclist.${UNQ}
fi
