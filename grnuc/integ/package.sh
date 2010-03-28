#
# Synopsis
#
#	package.sh [-r] [-n] [-y] <package definition file>
#
#
# $Log: package.sh,v $
# Revision 1.4  2002/02/14 22:50:52  hans
# Modifications to ensure CVS directories are not copied (-prune)
#
# Revision 1.3  2002/02/13 15:40:01  hans
# *** empty log message ***
#
# Revision 1.2  2002/02/06 23:29:23  hans
# *** empty log message ***
#
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.6  1997/07/25  20:35:43  scott
# COMMENT : Removal of network file system mount options on the Silicon Graphics platform
#
# Revision 340.5  1997/07/25  20:16:05  scott
# COMMENT : Changed syntax for conform with new permissions scheme
#
# Revision 340.4  1997/07/23  20:32:49  scott
# COMMENT : Added nfs mount options for the Silicon Graphics machines
#
# Revision 340.3  1997/07/21  21:55:17  scott
# COMMENT : Added Mount options for common / source package mounts
#
# Revision 340.2  1997/06/26  21:41:35  scott
# COMMENT : Corrected some logic bugs
#
# Revision 340.1  1997/06/26  20:21:00  scott
# COMMENT : Modified entire packaging scheme to use NFS mounts rather than remote commands
#
# Revision 340.0  1997/05/27  22:07:29  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

#set -x

USAGE="$0: [-r] [-n] [-y] <package definition file>"

#
# Set default switches
#
REPORT=1
PRIVATE="CSHARED"
COMPRESS="ON"
MNT_OPT=""

if [ "${SUN5}" = "y" ] || [ "${SUNZX}" = "y" ]
then
  SUN="n"
fi

if [ "$TMPDIR" = "" ]
then
  TMPDIR=/usr2/tmp
fi

#
# Verify and set the correct machine type / package file to use
#
if [ "${SUN5}" = "y" ]                # Sparc Solaris Native X display
then
  PARAM=8
else
  if [ "${C400}" = "y" ]              # Clipper C400
  then
    PARAM=7
    MNT_OPT="-f NFS"
  else
    if [ "${COMMON}" = "y" ]          # Clipper Source Machine
    then
      PARAM=6
      MNT_OPT="-f NFS"
    else
      if [ "${SGI}" = "y" ]           # Silicon Graphics
      then
        PARAM=5
      else
        if [ "${ISL}" = "y" ]         # Intel Solaris
        then
          PARAM=4
        else
          if [ "${SUNZX}" = "y" ]     # Sparc Solaris XGL display
          then
            PARAM=3
          else                        # Clipper C100
            PARAM=2
            MNT_OPT="-f NFS"
          fi
        fi
      fi
    fi
  fi
fi

#
# Check for command line switches
#
while [ $# -gt 1 ]
do
  if [ "$1" = "-r" ]; then REPORT=0; fi
  if [ "$1" = "-n" ]; then MLINKS=n; fi
  if [ "$1" = "-y" ]; then MLINKS=y; fi
  shift
done

if [ $# != 1 ]; then echo ${USAGE}; exit 1; fi
if [ ! -f $1 ]; then echo $1 is not a file; exit 1; fi
if [ ! -r $1 ]; then echo $1 is not readable; exit 1; fi

if [ ${REPORT} = 0 ]; then ECHO=echo; else ECHO=""; fi

INFILE=$1

if [ ${REPORT} = 1 ]
then
  if [ "${MLINKS}" = "" ]
  then
    echo "Do you want to maintain links? (y/n) [n] \c"
    read MLINKS; : ${MLINKS:=n}
  fi
fi


LNODE=`uname -n`

#
# Start looping through package definition file
#
cat ${INFILE} | while read LINE
do
  set blap ${LINE}; shift
  if [ $# != 0 ]
  then

    if [ "$1" = "private:" ]
    then
      PRIVATE=$2
    fi

    if [ "$1" = "compress:" ]
    then
      COMPRESS=$2
    fi

    if [ "$COMMON" = "y" ]
    then
      if [ "$PRIVATE" = "COMMON" ]
      then
        CONTINUE="y"
      else
        if [ "$PRIVATE" = "CSHARED" ]
        then
          CONTINUE="y"
        else
          CONTINUE="n"
        fi
      fi
    else
      if [ "$PRIVATE" = "SHARED" ] || [ "$PRIVATE" = "CSHARED" ]
      then
        CONTINUE="y"
      else
        if [ "$PRIVATE" = "SUN5" ] && [ "$SUN5" = "y" ]
        then
          CONTINUE="y"
        else
          if [ "$PRIVATE" = "SUNZX" ] && [ "$SUNZX" = "y" ]
          then
            CONTINUE="y"
          else
            if [ "$PRIVATE" = "SGI" ] && [ "$SGI" = "y" ]
            then
              CONTINUE="y"
            else
              if [ "$PRIVATE" = "CLIPPER" ] && [ "$CLIPPER" = "y" ]
              then
                CONTINUE="y"
              else
                if [ "$PRIVATE" = "C400" ] && [ "$C400" = "y" ]
                then
                  CONTINUE="y"
                else
                  if [ "$PRIVATE" = "ISL" ] && [ "$ISL" = "y" ]
                  then
                    CONTINUE="y"
                  else
                    CONTINUE="n"
                  fi
                fi
              fi
            fi
          fi
        fi
      fi
    fi

    if [ "$CONTINUE" = "y" ]
    then

      case $1 in

        "mountpoint:" )
           MNT_PNT=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           echo mountpoint: ${MNT_PNT}
           ;;

        "targetmount:" )
           if [ "$LOCAL" = "n" ]
           then
             TARG_MNT=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
             echo targetmount: ${TARG_MNT}
             rootsetuid /etc/mount $MNT_OPT ${TARGET}:${TARG_MNT} $MNT_PNT
           fi
           ;;

        "source:" )
           DIR=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           if [ ! -d ${DIR} ]; then echo ${DIR} is not a directory; exit 1; fi
           cd ${DIR}
           echo source: $PWD
           ;;

        "target:" )
           TARGET=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           echo target: ${TARGET}
           if [ "${TARGET}" = "${LNODE}" ]
           then
             LOCAL=y
           else
             LOCAL=n
           fi
           ;;

        "targetuser:" )
           TUSER=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           echo targetuser: ${TUSER}
           ;;

        "targetpath:" )
           TPATH=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           if [ "$LOCAL" = "n" ]
           then
             TPATH="${MNT_PNT}/${TPATH}"
           fi
           echo targetpath: ${TPATH}
           ;;

        "prodfile:" )
           PRODFILE=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           if [ "${PRODFILE}" = "" ]
           then
             PRODFILE=$(echo ${*} | cut -d' ' -f2)
           fi
           LIST=
           echo prodfile: ${PRODFILE}
           ;;

        "linkto:" )
           LINKTO=$(echo ${*} | cut -d' ' -f`echo ${PARAM}`)
           if [ "$LOCAL" = "n" ]
           then
             LINKTO="${MNT_PNT}/${LINKTO}"
           fi
           ${ECHO} ln ${TPATH}/${PRODFILE} ${LINKTO}
           ;;

        "endprodfile:" )
           if [ ${REPORT} = 0 ]
           then
             find ${LIST} -name CVS -prune -o -print | sort
           else
             if [ "${MLINKS}" != "y" ]
             then
               if [ "${COMPRESS}" = "ON" ]
               then
                 rm ${TPATH}/${PRODFILE}
               else
                 for file in ${LIST}
                 do
                   echo "removing `basename $file`"
                   rm ${TPATH}/`basename ${file}`
                 done
               fi
             fi

             if [ "${LOCAL}" = "y" ]
             then
               if [ "${COMPRESS}" = "ON" ]
               then
                 if [ "${ISL}" = "y" -o "${SUNZX}" = "y" -o "${SUN5}" = "y" -o "${SGI}" = "y" ]
                 then
                   find ${LIST} -name CVS -prune -o -print | sort | cpio -ocL | compress > ${TPATH}/${PRODFILE}
                 else
                   find ${LIST} -name CVS -prune -o -print | sort | cpio -ocm | compress > ${TPATH}/${PRODFILE}
                 fi
               else
                 find ${LIST} -name CVS -prune -o -exec cp {} ${TPATH} \;
               fi
             else
               if [ "${ISL}" = "y" ] || [ "${SUNZX}" = "y" ] || [ "${SGI}" = "y" ] || [ "${SUN5}" = "y" ]
               then
                 if [ "${COMPRESS}" = "ON" ]
                 then
                   if [ "${ISL}" = "y" -o "${SUNZX}" = "y" -o "${SUN5}" = "y" -o "$SGI" = "y" ]
                   then
                     find ${LIST} -name CVS -prune -o -print | sort | cpio -ocL | compress > $TMPDIR/${PRODFILE}
                   else
                     find ${LIST} -name CVS -prune -o -print | sort | cpio -ocm | compress > $TMPDIR/${PRODFILE}
                   fi

                   ls -al $TMPDIR/${PRODFILE}
                   cp $TMPDIR/${PRODFILE} ${TPATH}/${PRODFILE}
                   rm $TMPDIR/${PRODFILE}
                 else
                   for file in `find $LIST -name CVS -prune -o -print | sort `
                   do
                     cp $file ${TPATH}/$file
                   done
                 fi
               else
                 if [ "${COMPRESS}" = "ON" ]
                 then
                   if [ "${SUN5}" = "y" -o "${SUNZX}" = "y" -o "${SGI}" = "y" -o "${ISL}" = "y" ]
                   then
                     find ${LIST} -name CVS -prune -o -print | sort | cpio -ocL | compress > ${TPATH}/${PRODFILE}
                   else
                     find ${LIST} -name CVS -prune -o -print | sort | cpio -ocm | compress > ${TPATH}/${PRODFILE}
                   fi
                 else
                   for file in `find ${LIST} -name CVS -prune -o -print | sort `
                   do
                     cp $file ${TPATH}
                   done
                 fi
               fi
             fi
             ls -l ${TPATH}/${PRODFILE}
           fi
           ;;

        *)
           LIST="${LIST} $*"
           ;;
      esac
    fi
  fi
done # End of looping through package definition file


#
# Unmount delivery partition
#
if [ "$LOCAL" = "n" ]
then
  rootsetuid /etc/umount $MNT_PNT
fi

#set +x
