
initialize_it ()
{
  CFGINIT="config/dload/init"
  CFGPATCH="config/dload/patch"
  LCFGINIT="$TARGETDIR/$CFGINIT"
  LCFGPATCH="$TARGETDIR/$CFGPATCH"

  case $LOGNAME in
    grnuc34 )
              LPROD=grnuc
              break;;
    model34 )
              LPROD=model
              break;;
       *   )
              echo "NOT implemented for $LOGNAME"
              exit
              break;;
  esac

  if [ "$CLIPPER" = "y" ]
  then
    CPU=c100
    DATE=`date +"%d-%b-%y"`
    FSUFF="o"
  fi

  if [ "$C400" = "y" ]
  then
    CPU=c400
    DATE=`date +"%d-%b-%y"`
    FSUFF="o"
  fi

  if [ "$SUN5" = "y" ]
  then
    CPU=ssl
    DATE=`date +"%d-%h-%y"`
    FSUFF="so"
    COMPILER="$COMPILER -KPIC"
  fi

  if [ "$ISL" = "y" ]
  then
    CPU=isl
    DATE=`date +"%d-%h-%Y"`
    FSUFF="so"
    COMPILER="$COMPILER -KPIC"
  fi

  if [ "$SGI" = "y" ]
  then
    CPU=sgi
    DATE=`date +"%d-%b-%y"`
    FSUFF="so"
    COMPILER="$COMPILER -common"
  fi
}

prompt_for_info ()
{
  echo

  read -r EMSVER?"What EMS version are you building ? > 03.04.01."

  if [ "$LPROD" = "grnuc" ]
  then
    read -r PRODVER?"What GRNUC version are you building ? > 03.04.01."
  fi
  if [ "$LPROD" = "model" ]
  then
    read -r PRODVER?"What MODEL version are you building ? > 03.04.01."
  fi

  EMSPRODVER=$EMSVER
  EMSVER="fixes.341$EMSVER"
  REMOTE_INFO="n34emspub@ems130:../$EMSVER"

  if [ "$CLIPPER" = "y" ]
  then
    FIXESFORMS="$HOME/Mail/fixes341.$PRODVER"

    echo "\nGetting the file list from $FIXESFORMS\n"
    getfixfields FILES $FIXESFORMS | cut -d" " -f1 > $SOURCEDIR/$LPROD.list
  fi

  cat $SOURCEDIR/$LPROD.list
  echo

  if [ "$CLIPPER" = "y" ]
  then
    read -r FETCHIT?"Do you want to fetch these source files ? > [n] "
    if [ "$FETCHIT" = "y" ]
    then
      fetchsrc -f $SOURCEDIR/$LPROD.list
    else
      echo "\nNot fetching the source files"
    fi
    read -r POSTEM?"Do you want to post these fixes forms ? > [n] "
    if [ "$POSTEM" = "y" ]
    then
      echo "rcp $FIXESFORMS $REMOTE_INFO/src/fix$(echo $LPROD | cut -c1-3)341.$PRODVER"
      rcp $FIXESFORMS $REMOTE_INFO/src/fix$(echo $LPROD | cut -c1-3)341.$PRODVER
    else
      echo "\nNot posting the fixes forms"
    fi
  fi
}

generate_fixes ()
{
  echo
  read -r GOON?"Do you want to compile any of these source files ? > [y] "
  if [ "$GOON" = "" -o "$GOON" = "y" ]
  then
    for file in $(< $SOURCEDIR/$LPROD.list)
    do
      cd $TARGETDIR/$(dirname $file)
      echo "\n**********************************************************"
      pwd
      echo "**********************************************************"
      FIXFILE=$(basename $file)

      BASEFILE=$(echo $FIXFILE | cut -d"." -f1)

      if [ -f Makefile ]
      then
        MAKEFILE=Makefile
      else
        if [ -f makefile.m ]
        then
          MAKEFILE=makefile.m
        else
          if [ -f makefile ]
          then
            MAKEFILE=makefile
          else
            if [ -f makeimp ]
            then
              MAKEFILE=makeimp
            else
              MAKEFILE=
            fi
          fi
        fi
      fi

      echo "\ngrmake -rk -f $MAKEFILE ${BASEFILE}.o\n"
      read -r GOON?"Compile this file ? > [y] "
      if [ "$GOON" = "" ] || [ "$GOON" = "y" ]
      then
        #
        # Temporary fix for certain file not recompiling - scw
        #
        touch 01010101010101 ${BASEFILE}.o

        #
        # Now back to our regularly scheduled fixes build
        #
        grmake -rk -f $MAKEFILE ${BASEFILE}.o
        if [ "$SUN5" = "y" ]
        then
          echo "ld -z text -G -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o"
          ld -z text -G -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o
        elif [ "$ISL" = "y" ]
        then
          echo "ld -z text -G -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o"
          ld -z text -G -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o
        elif [ "$SGI" = "y" ]
        then
          echo "ld -shared -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o"
          ld -shared -o $LCFGPATCH/${BASEFILE}.so ${BASEFILE}.o
        else
          echo "ln ${BASEFILE}.o $LCFGPATCH/${BASEFILE}.o"
          ln ${BASEFILE}.o $LCFGPATCH/${BASEFILE}.o
        fi

        # Check for zero length object files
        if [ ! -s ${BASEFILE} ]
        then
          echo "\nWARNING: ${BASEFILE}.$FSUFF is a zero length file \n"
        fi

        # Check for filenames that will be truncated on Clippers
        if [ ${#BASEFILE} -ge 12 ]
        then
          echo "\nWARNING: ${BASEFILE}.$FSUFF is too long \n"
          read -r NEW_NAME?"Enter new basename without extensions.  > "
          if [ "$NEW_NAME" = "" ]
          then
            NEW_NAME=$BASEFILE
          fi
        else
          NEW_NAME=$BASEFILE
        fi

        echo "rcp $LCFGPATCH/${BASEFILE}.$FSUFF $REMOTE_INFO/$CPU/$LPROD/$CFGPATCH/${NEW_NAME}.$FSUFF"
        rcp $LCFGPATCH/${BASEFILE}.$FSUFF $REMOTE_INFO/$CPU/$LPROD/$CFGPATCH/${NEW_NAME}.$FSUFF
      else
        echo "\nNOT compiling ${BASEFILE}.o"
      fi
    done
  else
    echo "\nNot compiling the source files"
  fi
}

make_vers_file ()
{
  if [ "$CLIPPER" = "y" ]
  then

    if [ -f $VERSFILE ]
    then
      if [ ! -w $VERSFILE ]
      then
        errrpt $0 "$VERSFILE not writable"
        exit 1
      fi
    fi

    VERSNUM="03.04.01.$PRODVER"

    echo "Making $RUNAME version file"
    if [ "$RUNAME" = "GRNUC" -o "$RUNAME" = "MODEL" ]
    then
      cd $SOURCEDIR
      OLDVER=`grep INGR_S_PRODUCT_DEF $VERSFILE | cut -d' ' -f5-6`
      NEWVER="$VERSNUM $DATE\","
      echo
      replace "${OLDVER}" "${NEWVER}" $VERSFILE
      echo
    else
      cat <<- EOF > $VERSFILE
#include "version.h"
INGR_S_PRODUCT_DEF ${APPLID}_appl_version_id =
                   {
                      "I/$RUNAME $VERSNUM",
                    0,
                      "$PRODNUM",
                      " $VERSNUM ",
    		 };
EOF
    fi
  fi
}

mkversion ()
{
  echo
  read -r GOON?"Generate version information for $LPROD ? > [y] "
  if [ "$GOON" = "" -o "$GOON" = "y" ]
  then

    echo
    case $LPROD in
      grnuc )
          RUNAME=GRNUC
          VERSFILE=$SOURCEDIR/GRNUCver.c
          make_vers_file
          PRODLIST="."
          break;;

      model )
          RUNAME=MODEL
          VERSFILE=$SOURCEDIR/MODELver.c
          make_vers_file

          PRODVER=$EMSPRODVER

          APPLID=EMS_Cornerstone
          RUNAME=EMSCS
          PRODNUM="SM**230"
          VERSFILE=$SOURCEDIR/emspcs/EMSCSver.c
          make_vers_file

          APPLID=EMS_Lite
          RUNAME=EMSLT
          PRODNUM="SM**285"
          VERSFILE=$SOURCEDIR/emsplt/EMSLTver.c
          make_vers_file

          APPLID=EMS_PowerPak
          RUNAME=EMSPP
          PRODNUM="SM**236"
          VERSFILE=$SOURCEDIR/emsppp/EMSPPver.c
          make_vers_file

          APPLID=MDS
          RUNAME=MDS
          PRODNUM="SM**082"
          VERSFILE=$SOURCEDIR/mds/MDSver.c
          make_vers_file

          PRODLIST="model emspcs emsplt emsppp mds"
          break;;
    esac

    for file in $PRODLIST
    do
      if [ "$file" = "model" ]
      then
        file="."
      fi

      echo
      cd $TARGETDIR/$file

      if [ ! -d $CFGINIT ]
      then
        mkdir -p $CFGINIT
      fi

      PROD=$(\ls *ver.o)
      PRODver=$(echo ${PROD%.o})
      prod=$(echo ${PROD%ver.o} | tr [A-Z] [a-z])
      BASEFILE=$(echo ${PROD%.o})

      SRCDIR=$SOURCEDIR/$file

      echo "\nCompiling $PROD version file\n"
      $COMPILER -c $COMPOPT -I$EXNUC/include -c $SRCDIR/${BASEFILE}.c
      $EXTARG/bin/omcpp -I$EXNUC/include $SRCDIR/OMprodinit.C > OMprodinit.c
      $COMPILER -c $COMPOPT -c -I${EXNUC}/include OMprodinit.c

      case $CPU in
         isl )
   echo "ld -z text -G -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o"
   ld -z text -G -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o
   ;;
         ssl )
   echo "ld -z text -G -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o"
   ld -z text -G -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o
   ;;
          sgi )
   echo "ld -shared -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o"
   ld -shared -o $CFGINIT/${BASEFILE}.so ${BASEFILE}.o OMprodinit.o
   ;;
            * )
                ln OMprodinit.o $CFGINIT
                ln ${BASEFILE}.o $CFGINIT
                ;;
      esac

      echo "rcp $CFGINIT/${BASEFILE}.$FSUFF $REMOTE_INFO/$CPU/$prod/$CFGINIT"
      rcp $CFGINIT/${BASEFILE}.$FSUFF $REMOTE_INFO/$CPU/$prod/$CFGINIT

    done
  else
    echo "\nNot generating any version information for $LPROD"
  fi
}

initialize_it
prompt_for_info
generate_fixes
mkversion
