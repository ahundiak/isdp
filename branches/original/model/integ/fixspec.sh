#
# fixspec.sh - put the files in the current directory that need to be compiled
#              in spec.m
# 
#    Usage  : fixspec.sh
#    Inputs : none
#    Output : error messages/spec.m
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: fixspec.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:23  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:15:16  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:47:54  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/03/03  16:53:11  model22
# COMMENT : baselining from the build team commando effort
#
# Revision 220.4  1993/02/15  21:13:09  model20
# COMMENT : fixes for unit testing
#
# Revision 220.0  1993/02/13  22:51:59  tim
# COMMENT : initial creation of verification and error reporting utilities
#
#


MAX=150
MAX2=300
if [ `ls spec.m | wc -l` != 0 ]
 then
 UNQ=`echo $$`
 cat spec.m | while read LINE
 do
   LINE=`echo $LINE | cut -d'=' -f1`
   set blap ${LINE}; shift
   if [ $# != 0 ]
   then
     if [ "$1" != "SOURCE" ]
     then
       echo $LINE >> /tmp/spec.${UNQ}
     else
       let NUMFILES=0
       \ls *.[ISCt] > /tmp/srcfiles.${UNQ}
       NUMFILES=`\ls *.[ISCt] | wc -l`
       if [ $NUMFILES -gt $MAX ] 
        then
          echo "WRITING grp1 SOURCE FILES to /tmp/spec.${UNQ}"     
          let NUMFILES=0
          echo "SOURCE=grp1" >> /tmp/spec.${UNQ}
          for ff in `cat /tmp/srcfiles.${UNQ}`
           do
            echo $ff >> /tmp/spec.${UNQ}
            NUMFILES=`expr $NUMFILES + 1`
            if [ $NUMFILES -eq $MAX ] 
              then 
               echo "WRITING grp2 SOURCE FILES to /tmp/spec.${UNQ}"     
               echo "SOURCE=grp2" >> /tmp/spec.${UNQ}
            fi
            if [ $NUMFILES -eq $MAX2 ] 
              then 
               echo "WRITING grp3 SOURCE FILES to /tmp/spec.${UNQ}"     
               echo "SOURCE=grp3" >> /tmp/spec.${UNQ}
            fi
          done
       else
         echo SOURCE >> /tmp/spec.${UNQ}       
         echo "WRITING SOURCE FILES to /tmp/spec.${UNQ}"     
         cat /tmp/srcfiles.${UNQ} >> /tmp/spec.${UNQ}
       fi
       if [ -f *.c ]
       then 
           for f in *.c
           do
               bname=`echo $f | cut -d. -f1`
               if [ ! -f ${bname}.[ICS] ]
               then
                   echo $f >> /tmp/spec.${UNQ}
               else
                   echo "$f has a parent source file...not added"
               fi
          done
       fi

       mv /tmp/spec.${UNQ} spec.m
       rm -f /tmp/srcfiles.${UNQ}
       exit
    fi
  fi
  done
fi

rm -f /tmp/srcfiles.${UNQ}
