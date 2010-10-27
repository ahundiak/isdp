#!/bin/ksh
# $Id: vdlite.sh,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $
#***********************************************************************
# I/VDS
#
# File:		vdlite/bin/vdlite.sh
#
# Description:
#		This script control the construction of an adapted
#		user interface for VDS based on EMS Lite.
#
# Dependencies:
#
# Revision History
#	$Log: vdlite.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
#	Initial import to CVS
#	
# Revision 1.2  2000/04/02  18:37:00  pinnacle
# Replaced: vdlite/bin/vdlite.sh for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/01/29  22:12:06  pinnacle
# Created: ./vdlite/bin/vdlite.sh by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	01/29/96	adz		creation date
#
#***********************************************************************
#
# Compilation variables.
#

CPP="${CPP_COMP} -P -Dems"
MENU="${GENMENU}"

#
# ============================================================================
# Set and check the input and output files.
#
VDS_MENUS="${VDS}/config/english/menus"
VDS_PATHS="${VDS}/config/english/cmdpaths"
VDS_CMDTB="${VDS}/config/cmd_tbl_list"

LITE="${VDS}/vdlite"
LITEMENUS="${LITE}/config/english/menus"

LITEPOPUP="${LITE}/config/popups"
LITEPATHS="${LITE}/config/english/cmdpaths/IMVds"
LITECMDTB="${LITE}/config/cmd_tbl_list"

TMP_POPUP="${LITE}/config/popups.tmp"
TMP_PATHS="${LITE}/config/english/cmdpaths/IMVds.tmp"

#
# ============================================================================
# Get the BAR_MENU and PANEL_MENU information and regenerate the files
# based on the given corrections.
#

PAN_OTL="${LITEMENUS}/src/VDpan.otl"
PAN_CPP="${LITEMENUS}/src/VDpan.cpp"
PAN_TMP="${LITEMENUS}/src/VDpan.tmp"

BAR_OTL="${LITEMENUS}/src/VDbar.otl"
BAR_CPP="${LITEMENUS}/src/VDbar.cpp"
BAR_TMP="${LITEMENUS}/src/VDbar.tmp"

#
# ============================================================================
#	Create needed directories.
#
	list="$list ${LITE}/config/english/menus/src"
	list="$list ${LITE}/config/cmd_tbl"
	list="$list ${LITE}/config/english/cmdpaths"
	list="$list ${LITE}/config/english/palettes"

	for dir in ${list}
	do
	  if [ ! -d ${dir} ] ; then mkdir -p ${dir} ; fi
	  if [ ! -d ${dir} ] ; then echo "Error mkdir failed " ; exit 1 ; fi
	done

#
# ============================================================================
#	Copy the original files from the VDS version.
#
	rm -f ${PAN_OTL} ${BAR_OTL} ${LITEPATHS} ${LITECMDTB}

	cp ${VDS_MENUS}/src/VDpan.otl	${PAN_OTL}
	cp ${VDS_MENUS}/src/VDbar.otl	${BAR_OTL}
	cp ${VDS_PATHS}/IMVds		${LITEPATHS}

	chmod a+w ${PAN_OTL}
	chmod a+w ${BAR_OTL}

#
# ============================================================================
#	Read a list of commands that are not in EMS Lite
#	Remove unused commands from otl file (not needed for bar menu)
#
	set `cat ${LITE}/bin/remove.list`
	while [ $1 ] ; do 
		echo Processing $1 ......
		grep -v $1 ${PAN_OTL} > ${PAN_TMP}
		mv ${PAN_TMP} ${PAN_OTL}
		shift
	done

#
#	This section is for buttons that no longer have popups
#	Read list of commands that no longer have popups
#

	cp ${VDS}/config/popups ${LITEPOPUP}

#
# ============================================================================
#	Go through the list and change symbol 254 to -1
#
	set `cat ${LITE}/bin/modify.list`
	while [ $1 ] ; do

		echo "\tProcessing $1 for popups"

		grep -v $1 ${LITEPOPUP} > ${TMP_POPUP}
		mv ${TMP_POPUP} ${LITEPOPUP}
		chmod 777 ${LITEPOPUP}

#
#		Remove arrow from menu indicating popup 
#		Check to see if entry is in the panel, else use bar
#

		COUNT=`grep -c $1 ${PAN_OTL}`
		if [ $COUNT = "0" ] ; then

		  sed /$1/s/254/-1/1 ${BAR_OTL} > ${BAR_TMP}
		  mv ${BAR_TMP} ${BAR_OTL}

		  sed /$1/s/254/-1/1 ${LITEPATHS} > ${TMP_PATHS}
		  mv ${TMP_PATHS} ${LITEPATHS}
		  chmod 777 ${LITEPATHS}

		else

		  sed /$1/s/254/-1/1 ${PAN_OTL} > ${PAN_TMP}
		  mv ${PAN_TMP} ${PAN_OTL}

		  sed /$1/s/254/-1/1 ${LITEPATHS} > ${TMP_PATHS}
		  mv ${TMP_PATHS} ${LITEPATHS}
		  chmod 777 ${LITEPATHS}

		fi
		shift
	done

#
#	Change the cmd_tbl_list to add the Macro related commands.
#

	echo "\tModify config/cmd_tbl_list"

	cp ${LITE}/bin/vlt.tbl ${LITE}/config/cmd_tbl/.
	cat ${VDS}/config/cmd_tbl_list ${LITE}/bin/cmd_tbl_add >> ${LITECMDTB}

#
# ============================================================================
#	Compile the new version of VDpan.otl
#
	echo "\tCompile ${PAN_OTL}"

	cd ${LITEMENUS}
        rm -f VD* SM* EM*
        ${CPP} ${PAN_OTL} | awk '{ if ($$0 != "") print $$0 }' > ${PAN_CPP}
        if [ -f ${MENU} ] ; then
        	${MENU} ${PAN_CPP} ${LITEMENUS}/IMVDS ; 
		else echo "ERROR: ${MENU} not found ..." ;
		exit 1 ;
        fi
        rm -f ${PAN_CPP} ${PAN_TMP}
        cp IMVDS PANEL_MENU

#
#	Recreate the pan.tbl for the headers ...
#
	if [ -f ${LITEMENUS}/pan.cmd ] ; then
	  rm -f ${LITEMENUS}/pan.cmd
	fi

	cd ${LITEMENUS}
	ls EM* VD* SM* > pan.list
	for file in `cat pan.list`
	do
	  print '^"'$file'",'$file',COci,0,0,,"Blank"' >> pan.cmd
	done

	rm pan.list

	if [ -f pan.cmd ] ; then

	  cp pan.cmd ${LITE}/config/cmd_tbl/pan.tbl
	  rm pan.cmd
	fi

#
# ============================================================================
#	Create the correction of the BAR_MENU.
#
	echo "\tCompile ${BAR_OTL}"

        ${CPP} ${BAR_OTL} | awk '{ if ($0 != "") print $0 }' > ${BAR_CPP}
        genbarmenu -n ${BAR_CPP} BAR_VDS
        cp BAR_VDS BAR_MENU
        rm -f ${BAR_CPP} ${BAR_TMP}

	echo "\tFinished VDS Lite PANEL_MENU."
	echo "\n"

