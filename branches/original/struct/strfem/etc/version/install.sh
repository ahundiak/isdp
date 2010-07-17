#
# Copyright Intergraph Corporation	14-NOV-1990
#
# I/STRFEM Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#
# History
#
# Sep  7, 1994  Adopted from  I/STRUCT
#

DEFDIR=$4

SUFF="XXXX"

#-------------------------------------------------------------------------------
#       Define path product_data.
#-------------------------------------------------------------------------------
if [ "$0" = "install.isl" ]
then
  SUFF="_ISL"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.sgi" ]
then
  SUFF="_SGI"
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="_SSL"
  export INGRHOME=${INGRHOME:-/opt/ingr}
  OSver="$(uname -r | cut -c1-3)"
  if [ "${OSver}" -ge "5.4" ]  # Solaris 2.4 or higher
  then
    PROMPTXGL="y"
  fi
fi

if [ "$0" = "install.sh" ]
then
  SUFF="C100"
  if [ -x /bin/inqcpuid ] ; then
        DEFAULT=`/bin/inqcpuid`
        case "${DEFAULT}" in
          [Cc]100) SUFF=C100 ; break ;;
          [Cc]300) SUFF=C100 ; break ;;
          [Cc]400) SUFF=C400 ; break ;;
          *)       SUFF=C100 ; break ;;
        esac
  fi
  export INGRHOME=${INGRHOME:-/usr/ip32}
  if [ "$INGRHOME" = "/dev/null" ]
  then
    INGRHOME="/usr/ip32"
  fi
fi

#
#  Add the ip32 (if missing) on clix boxes
#
if [ "${SUFF}" = "C100" -o "${SUFF}" = "C400" ]
then
  ProDir="`basename ${DEFDIR}`"
  Df3="`echo $DEFDIR | cut -d'/' -f3`"
  if [ "$Df3" = "$ProDir" ]
  then
    Df2="`echo $DEFDIR | cut -d'/' -f2`"
    DEFDIR="/${Df2}/ip32/${Df3}"
  fi
fi

#-------------------------------------------------------------------------------
function SetGlobals {

	chmod +x ./product.def
	. ./product.def

	VERSION=${IDversion}
	TITLE=${IDtitle}

	UNIXDIR=""
	UNIX_DB=""

	DB_SIZE=10
	STRFEM_SIZE=5000


} # function SetGlobals
#-------------------------------------------------------------------------------
function Title {

        echo "\n\t\t${TITLE} ${VERSION}\n\n"

} # Title
#-------------------------------------------------------------------------------
function SetDBdir {

        # $1: prompt

        echo
        VDS=`echopath VDS 2>/dev/null`
	DEFDIR1=${VDS}/data/struct
        UNIX_DB=`getanswer \
        "Key in directory for I/STRFEM Data Base Neutral Files" "${DEFDIR1}"`

        if [ ! -d ${UNIX_DB} ]; then mkdir -p ${UNIX_DB}; fi
        if [ ! -d ${UNIX_DB} ]; then
                echo "Cannot create ${UNIX_DB}" ;
                exit 1 ;
        fi

        cd ${UNIX_DB}
        LOGFILE=${UNIX_DB}/log

} # SetDBdir
#-------------------------------------------------------------------------------
function SetDeliveryDir {

        # $1: prompt

        echo
        UNIXDIR=`getanswer "Key in directory for I/STRFEM" "${DEFDIR}"`

        if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
        if [ ! -d ${UNIXDIR} ]; then
                echo "Cannot create ${UNIXDIR}" ;
                exit 1 ;
        fi

        cd ${UNIXDIR}
        LOGFILE=${UNIXDIR}/log

} # SetDeliveryDir
#-------------------------------------------------------------------------------
Check_Space () { # Check Disk Space
	checkDIR=$1
	checkSIZE=$2
	checkPRODUCT=$3  

	set `df $checkDIR`
	Disk_Space=$3

	if [ $Disk_Space -lt $checkSIZE ] ;
	then
		echo ${checkPRODUCT} requires ${checkSIZE} blocks.
		echo ${checkDIR} has only ${Disk_Space} free blocks.
		exit 1
	fi
} # Check_Space
#-------------------------------------------------------------------------------
function LoadDirectory {

        typeset AOK

        # $1: file to unwind into directory.

        getfile $1 | compress -d | cpio -imud >>${LOGFILE} 2>&1
        AOK=$?
        if [ "${AOK}" != "0" ] ; then exit ${AOK} ; fi

} # LoadDirectory
#-------------------------------------------------------------------------------
function ModifProduct_Data {

        pd=${INGRHOME}/product_data
        pdtmp=${INGRHOME}/Product_data
        echo > ${pdtmp}
        if [ -f ${pd} ] ; then sed '/\"Strfem\"/d' ${pd} > ${pdtmp} ; fi
        echo "\"Strfem\" I/STRFEM GRmodule Strfem:Fem:Struct ${UNIXDIR}" >> ${pdtmp}
        mv ${pdtmp} ${pd}

} # ModifProduct_Data
#-------------------------------------------------------------------------------
function Installing {

	echo
	echo "Installing $1 in ${UNIXDIR}"
	echo "Installing $1 in ${UNIXDIR}" >> ${LOGFILE} 2>&1
	date >>${LOGFILE} 2>&1

} # function Installing
#-------------------------------------------------------------------------------
function hasBasePlateformsBeenLoaded {

	STRUCT=`echopath STRUCT 2>/dev/null`
	if [ -z "${STRUCT}" ] ; then
		echo "*\n* I/STRUCT must be loaded prior to I/STRFEM."
		echo "* Please load I/STRUCT, then restart this procedure.\n*"
		exit 1
	fi

	FEM=`echopath FEM 2>/dev/null`
	if [ -z "${FEM}" ] ; then
		echo "*\n* I/FEM must be loaded prior to I/STRFEM."
		echo "* Please load I/FEM, then restart this procedure.\n*"
		exit 1
	fi
}
#-------------------------------------------------------------------------------
function AdaptLookingGlass {

if inqlgexist
then
  cat << EO > /usr/tmp/strfemp.ftc
#include <ftdefs.h>
DEFINE TYPE	DEM_STRFEM
 ICON		DEM_STRFEM
  FILE_DESCRIPTION	"I/STRFEM script"
 TEXT
 AND NAME "strfem"
 AND DIRECTORY "*/strfem/bin"
COMMAND  CdEx(/bin/ksh -c #c/.lgshell)
COMMAND_DESCRIPTION "Run I/STRFEM"
COMMAND ATTRIBUTE : NATIVE "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions I/STRFEM'"
COMMAND_DESCRIPTION "Set I/STRFEM options"
END
EO

  cp /usr/tmp/strfemp.ftc .

  cat << EO > /usr/tmp/strfemd.ftc
#include <ftdefs.h>
DEFINE TYPE DEM_STRFEM_OS
 ICON		DEM_STRFEM_OS
	FILE_DESCRIPTION "I/STRFEM Design File ( Object Based )"
 BINARY_DATA
   AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 TO 414 STRING "Strfem"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 TO 414 STRING "Strfem"

COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '${UNIXDIR}/bin/.lgshell -f #c/#f'"
COMMAND_DESCRIPTION "Run I/STRFEM"
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EO
  cp /usr/tmp/strfemd.ftc .

  lgadddefs prog /usr/tmp/strfemp.ftc
  lgadddefs prog /usr/tmp/strfemd.ftc
fi

} # AdaptLookingGlass
#-------------------------------------------------------------------------------

#       Script for downloading STRFEM product starts here
#
#	Get responses to prompts
#

	SetGlobals

	Title

	hasBasePlateformsBeenLoaded


#
#	Configuring a PDM Data Base Server of downloading a workstation ?
#
	while true ; do
	    echo "Do you want to"
	    echo "         - download to a workstation[w] ?"
	    echo "         - configure a database server[s] ?"
	    echo "         - do both above[b] ?"
	    DB=`getanswer "         - exit[e] ?" "w"`
	    case ${DB} in
		w) break ;;
		s) break ;;
		b) break ;;
		e) exit 1 ;;
		*) echo "\nInvalid response: \"${DB}\"\n" ;;
	    esac
	done

	if [ ${DB} = "s" -o ${DB} = "b" ] ; then

	#
	#	Server download.
	#
	    SetDBdir

	    Check_Space ${UNIX_DB} ${DB_SIZE} "I/STRFEM Data Base Neutral Files"

	    Installing "I/STRFEM Data Base Neutral Files"

	    LoadDirectory  db.p

  	    echo

	fi

	if [ ${DB} = "w" -o ${DB} = "b" ] ; then

#
#	Workstation download.
#
echo "\nI/STRFEM depends on I/STRUCT and I/FEM. The two products must be loaded"
echo " before loading I/STRFEM"
echo "\nCAUTION:"
echo "Any previous version of I/STRFEM should be removed from the workstation,"
echo "before loading I/STRFEM ${VERSION}. Please read your Delivery Letter."
echo "To remove I/STRFEM use remove.sh delivered with the version being removed."
echo

#
#	Leave user a chance to load elsewhere than in the default directory.
#
		SetDeliveryDir

		echo "\nThe I/STRFEM Runtime Platform requires\c"
		echo " ${STRFEM_SIZE} blocks."
		INST_STRFEM=`getanswer \
			    "Install I/STRFEM Runtime Platform ?" "y"`

		ModifProduct_Data

#
#	Load I/STRFEM
#
		if [ "${INST_STRFEM}" = "y" ] ; then

		    Check_Space ${UNIXDIR} ${STRFEM_SIZE} "I/STRFEM"

		    Installing "I/STRFEM"

		#
		# Empty config/dload to avoid surprises, (.o files from the
		# version being overwritten left because thet do not exist
		# in the new version, but which would be automatically loaded
		# by EXNUC at startup), just in case the user did not remove
		# the old version before dloading this here new one.
		#
		    rm -r config/dload > /dev/null 2>&1

		    LoadDirectory  config.p

		    LoadDirectory  strfem${SUFF}.p

		#
		# Temporary removing the VDS palettes in I/STRUCT
		# Only GRSwPr palette stays active .
		#       Ad Zuurhout (7/28/93)
		#
		# rm -r config/english/palettes/*pal >/dev/null 2>&1


		   LoadDirectory  ppl${SUFF}.p

		   LoadDirectory  include.p

		fi

#
#	Adapt for Looking Glass (TM)
#
		AdaptLookingGlass

	fi # Of "if [ ${DB} = "w" -o ${DB} = "b" ] ... "

	exit 0
