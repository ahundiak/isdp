IDnumber=SN0S253
IDname=XFORMSRT
IDtitle="I/XForms Runtime Product"
IDversion=01.02.06.04
IDdate=19-JUL-1995
IDclass="System Nucleus"
IDassoc="0S"

DELdir=xformsrt
DELloadp=525
DELattr="PREPROCESS"
DELarch="INTEL_SOLARIS"

DELsize=147

#PRODUCT DEPENDENCIES
##number name
#NONE
#END OF PRODUCT DEPENDENCIES

#PRODUCT PREREQUISITES
##number name
#NONE
#END OF PRODUCT PREREQUISITES

#RESOURCE DEPENDENCIES
#MEMORY SIZE (MEG):
#USER SPACE (MEG):
#RUNTIME SPACE (MEG):
#SWAP SPACE (MEG):
#COMMENTS:
#END OF RESOURCE DEPENDENCIES

#FILE INFORMATION
##filename	date		type			comment
#README	19-JUL-1995	"ALL ascii text"
#product.def	19-JUL-1995	"ALL ascii text"
#install.isl	19-JUL-1995	"INTEL_SOLARIS commands text"
#checkinst.sh	19-JUL-1995	"ALL commands text"
#xformsrt.pi	19-JUL-1995	"INTEL_SOLARIS compressed cpio for i86pc"
#remove.isl	19-JUL-1995	"INTEL_SOLARIS commands text"
#END OF FILE INFORMATION

#TAPE ORDER
##filename
#install.isl
#remove.isl
#checkinst.sh
#xformsrt.pi
#END OF TAPE ORDER

#FLOPPY ORDER
##filename
#install.isl
#remove.isl
#checkinst.sh
#xformsrt.pi
#END OF FLOPPY ORDER

#DOCUMENTATION
##See Intergraph Document List (ST**008 IDL) for current
##documentation list.
#NONE
#END OF DOCUMENTATION

#TRAINING
##course_number	"title"
#NONE
#END OF TRAINING

#MENU
##menu_number	"title"	status_code
#NONE
#END OF MENU

#COPYRIGHT
# Copyright 1992 Intergraph Corporation
# All Rights Reserved
# 
# Including software, file formats, and audio-visual displays;
# may only be used pursuant to applicable software license agreement;
# contains confidential and proprietary information of Intergraph
# and/or third parties which is protected by copyright and trade
# secret law and may not be provided or otherwise made available
# without proper authorization.
# 
# RESTRICTED RIGHTS LEGENDS
# 
# Use, duplication, or disclosure by the Government is subject to
# restrictions as set forth in subparagraph (c) (1) (ii) of The Rights
# in Technical Data and Computer Software clause at DFARS 252.227-7013
# or subparagraphs (c) (1) and (2) of Commercial Computer Software --
# Restricted Rights at 48 CFR 52.227-19, as applicable.
# 
# Unpublished -- rights reserved under the Copyright Laws of the
# United States.
# 
# Intergraph Corporation
# Huntsville, Alabama   35894-0001
# 
#END OF COPYRIGHT


#NOTE
#  where supported ArchKeys are:
#   CLIPPER	All CLIX machines (Same as CLIX)
#   CLIX	All CLIX machines (Same as CLIPPER)
#     C100	C100 CLIPPERS
#     C300	C300 CLIPPERS
#     C400	C400 CLIPPERS
#   SUN		All SUN machines
#     SUN4	SUN4 SPARC machines
#     SUN4C SUN4C SPARC machines
#   INTEL_SOLARIS 	All INTEL machines running SOLARIS
#   MIPS	All MIPS (SGI) machines
#END OF NOTE


#SUPPORTED_PROCESSOR_TYPES.ITB
#ArchKey	ProcKey
#-------	-------
#CLIPPER	C400
#CLIPPER	C100
#SUN	SUN4
#INTEL_SOLARIS	I86PC
#MIPS	MIPS
#END OF SUPPORTED_PROCESSOR_TYPES.ITB


#PACKAGE.ITB
#Component	ArchKey	File
#---------	-------	----
#xformsrt	ALL	util/bin/xgenmenu
#xformsrt	ALL	util/bin/xmrgpanel
#xformsrt	ALL	util/doc/xgenmenu.doc
#xformsrt	ALL	xfi/config/english/icons/FIsym
#xformsrt	ALL	xfi/config/english/icons/collapse.icon
#xformsrt	SUN	xfi/lib/${PROC_TYPE}/libXFI.so.2
#xformsrt	INTEL_SOLARIS	xfi/lib/${PROC_TYPE}/libXFI.so.2
#xformsrt	MIPS	xfi/lib/${PROC_TYPE}/libXFI.so.2
#xformsrt	CLIPPER	xfi/lib/${PROC_TYPE}/libXFI_s
#END OF PACKAGE.ITB

#SPACE.ITB
#Component	ProcKey	Size
#---------	-------	----
#xformsrt	C100	4175
#xformsrt	C300	2802
#xformsrt	C400	4212
#xformsrt	SUN4	232
#xformsrt	I86PC	147
#xformsrt	MIPS	4361
#END OF SPACE.ITB


#COMMENT
#
# Note: If the Default value for a Component is 'deliver', then it
#       will be delivered automatically, with no questions asked.
#       All components where Default='deliver' should be delivered
#       first for things to work out right and look good.
#
#END OF COMMENT

#INSTALL.ITB
#Component	Default	Title
#---------	-------	-----
#xformsrt	deliver	I/XForms Runtime Product
#END OF INSTALL.ITB


#SYMLINK.ITB
#Component	ArchKey	Directory	File
#---------	-------	---------	----
#xformsrt	ALL	$INGR_RUN/bin	util/bin/xgenmenu
#xformsrt	ALL	$INGR_RUN/bin	util/bin/xmrgpanel
#xformsrt	ALL	$INGR_RUN/lib/xformsrt	xfi/config/english/icons/FIsym
#xformsrt	ALL	$INGR_RUN/lib/xformsrt	xfi/config/english/icons/collapse.icon
#xformsrt	SUN	$INGR_RUN/lib	xfi/lib/${PROC_TYPE}/libXFI.so.2
#xformsrt	INTEL_SOLARIS	$INGR_RUN/lib	xfi/lib/${PROC_TYPE}/libXFI.so.2
#xformsrt	MIPS	$INGR_RUN/lib	xfi/lib/${PROC_TYPE}/libXFI.so
#xformsrt	CLIPPER	$INGR_RUN/shlib	xfi/lib/${PROC_TYPE}/libXFI_s
#END OF SYMLINK.ITB

#PREINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF PREINSTALL.ITB

#POSTINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#xformsrt	ALL	getfile checkinst.sh >$DESTDIR/checkinst.sh
#xformsrt	ALL	chmod 755 $INGR_RUN/lib/xformsrt
#xformsrt	ALL	chmod 755 ${DESTDIR}/checkinst.sh
#xformsrt	CLIPPER	chgrp sys ${DESTDIR}/checkinst.sh
#xformsrt	SUN	chgrp daemon ${DESTDIR}/checkinst.sh
#xformsrt	INTEL_SOLARIS	chgrp daemon ${DESTDIR}/checkinst.sh
#xformsrt	MIPS	chgrp sys ${DESTDIR}/checkinst.sh
#xformsrt	ALL	chown root ${DESTDIR}/checkinst.sh
#xformsrt	SUN	rm -f ${INGR_RUN}/lib/libXFI.so
#xformsrt	INTEL_SOLARIS	rm -f ${INGR_RUN}/lib/libXFI.so
#xformsrt	SUN	ln -s ${DESTDIR}/xfi/lib/${PROC_TYPE}/libXFI.so.2 ${INGR_RUN}/lib/libXFI.so
#xformsrt	INTEL_SOLARIS	ln -s ${DESTDIR}/xfi/lib/${PROC_TYPE}/libXFI.so.2 ${INGR_RUN}/lib/libXFI.so
#END OF POSTINSTALL.ITB

#PREREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF PREREMOVE.ITB

#POSTREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#xformsrt	SUN	rm -f ${INGR_RUN}/lib/libXFI.so
#xformsrt	INTEL_SOLARIS	rm -f ${INGR_RUN}/lib/libXFI.so
#END OF POSTRMOVE.ITB
