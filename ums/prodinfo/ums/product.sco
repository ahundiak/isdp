IDnumber=SN0L256
IDname=UMS
IDtitle="I/UMS User Message System"
IDversion=02.01.06.00
IDdate=29-NOV-1994
IDclass="System Nucleus"
IDassoc="0L"
DELdir=ip32/ums
DELloadp=525
DELattr="PREPROCESS"
DELarch="INTEL_SCO"

DELsize=218

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
#install.sco	29-NOV-1994	"SCO ascii text"
#checkinst.sh	29-NOV-1994	"ALL commands text"
#remove.sco	29-NOV-1994	"SCO ascii text"
#ums.pi3	29-NOV-1994	"SCO compressed cpio"
#END OF FILE INFORMATION

#TAPE ORDER
##filename
#install.sco
#remove.sco
#checkinst.sh
#ums.pi3
#END OF TAPE ORDER

#FLOPPY ORDER
##filename
#install.sco
#remove.sco
#checkinst.sh
#ums.pi3
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
#   SCO
#     I386        AST_I386
##     I486        AST_I486
#   SUN		All SUN machines
#     SUN4	SUN4 SPARC machines
#     SUN4C CUN4C SPARC machines
#   MIPS	All MIPS (SGI) machines
#END OF NOTE


#SUPPORTED_PROCESSOR_TYPES.ITB
#ArchKey	ProcKey
#-------	-------
#CLIPPER	C400
#CLIPPER	C100
#SUN	SUN4
#MIPS	MIPS
#SCO	I386
##SCO	I486
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
#ums	SUN4	428
#ums	I386	218
##ums	I486	224
#ums	MIPS	256
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
#ums	ALL	/usr/bin	bin/umscomp
#ums	CLIPPER	/usr/lib	lib/c100/libUMS.a
#ums	MIPS	/usr/lib	lib/${PROC_TYPE}/libUMS.a
#ums	SCO	/usr/lib	lib/${PROC_TYPE}/libUMS.a
#ums	CLIPPER	/usr/lib/${PROC_TYPE}	lib/${PROC_TYPE}/libUMS.a
#END OF SYMLINK.ITB

#PREINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF PREINSTALL.ITB

#POSTINSTALL.ITB
#Component	ArchKey	Command
#---------	-------	-------
#Component	ArchKey	Command
#ums	ALL	rm -f /usr/bin/umscompile
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp /usr/bin/umscompile
#ums	ALL	rm -f /usr/bin/umcmptxt
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp /usr/bin/umcmptxt
#ums	ALL	rm -f /usr/bin/umscomptxt
#ums	ALL	ln -s ${DESTDIR}/bin/umscomp /usr/bin/umscomptxt
#ums	ALL	getfile checkinst.sh >${DESTDIR}/checkinst.sh
#ums	ALL	chmod 775 ${DESTDIR}/checkinst.sh
#END OF POSTINSTALL.ITB

#PREREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#ums	ALL	rm -f /usr/bin/umscompile
#ums	ALL	rm -f /usr/bin/umcmptxt
#ums	ALL	rm -f /usr/bin/umscomptxt
#END OF PREREMOVE.ITB

#POSTREMOVE.ITB
#Component	ArchKey	Command
#---------	-------	-------
#END OF POSTRMOVE.ITB
