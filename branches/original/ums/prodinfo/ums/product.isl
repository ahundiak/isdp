IDnumber=SN0S256
IDname=UMS
IDtitle="I/UMS User Message System"
IDversion=02.01.06.00
IDdate=29-NOV-1994
IDclass="System Nucleus"
IDassoc="0S"
DELdir=ums
DELloadp=525
DELattr="PREPROCESS"
DELarch="INTEL_SOLARIS"

DELsize=17

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
#README	29-NOV-1994	"ALL ascii text"
#product.def	29-NOV-1994	"ALL ascii text"
#install.isl	29-NOV-1994	"INTEL_SOLARIS ascii text"
#checkinst.sh	29-NOV-1994	"ALL commands text"
#remove.isl	29-NOV-1994	"INTEL_SOLARIS ascii text"
#ums.pi	29-NOV-1994	"INTEL_SOLARIS compressed cpio for i86pc"
#END OF FILE INFORMATION

#TAPE ORDER
##filename
#install.isl
#remove.isl
#checkinst.sh
#ums.pi
#END OF TAPE ORDER

#FLOPPY ORDER
##filename
#install.isl
#remove.isl
#checkinst.sh
#ums.pi
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
##menu_number	"title"	menu_status
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
#ums	ALL	bin/umscomp
#ums	ALL	include/UMS.h
#ums	ALL	include/UMS.inc
#ums	ALL	include/pums_pub.h
#ums	ALL	lib/${PROC_TYPE}/libUMS.a
#END OF PACKAGE.ITB

#SPACE.ITB
#Component	ProcKey	Size
#---------	-------	----
#ums	C100	285
#ums	C300	274
#ums	C400	287
#ums	SUN4	21
#ums	I86PC	17
#ums	MIPS	280
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
#ums	deliver	I/UMS User Message System
#END OF INSTALL.ITB

#SYMLINK.ITB
#Component	ArchKey	Directory	File
#---------	-------	---------	----
#ums	ALL	$INGR_RUN/bin	bin/umscomp
#ums	CLIPPER	$INGR_RUN/lib	lib/c100/libUMS.a
#ums	SUN	$INGR_RUN/lib	lib/${PROC_TYPE}/libUMS.a
#ums	INTEL_SOLARIS	$INGR_RUN/lib	lib/${PROC_TYPE}/libUMS.a
#ums	MIPS	$INGR_RUN/lib	lib/${PROC_TYPE}/libUMS.a
#ums	CLIPPER	$INGR_RUN/lib/${PROC_TYPE}	lib/${PROC_TYPE}/libUMS.a
#END OF SYMLINK.ITB

#PREINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF PREINSTALL.ITB

#POSTINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#Component	ArchKey	Command
#ums	ALL	rm -f $INGR_RUN/bin/umscompile
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp $INGR_RUN/bin/umscompile
#ums	ALL	rm -f $INGR_RUN/bin/umcmptxt
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp $INGR_RUN/bin/umcmptxt
#ums	ALL	rm -f $INGR_RUN/bin/umscomptxt
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp $INGR_RUN/bin/umscomptxt
#ums	ALL	getfile checkinst.sh >${DESTDIR}/checkinst.sh
#ums	ALL	chmod 755 ${DESTDIR}/checkinst.sh
#ums	CLIPPER	chgrp sys ${DESTDIR}/checkinst.sh
#ums	SUN	chgrp daemon ${DESTDIR}/checkinst.sh
#ums	INTEL_SOLARIS	chgrp daemon ${DESTDIR}/checkinst.sh
#ums	MIPS	chgrp sys ${DESTDIR}/checkinst.sh
#ums	ALL	chown root ${DESTDIR}/checkinst.sh
#END OF POSTINSTALL.ITB

#PREREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#ums	ALL	rm -f $INGR_RUN/bin/umscompile
#ums	ALL	rm -f $INGR_RUN/bin/umcmptxt
#ums	ALL	rm -f $INGR_RUN/bin/umscomptxt
#END OF PREREMOVE.ITB

#POSTREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF POSTRMOVE.ITB
