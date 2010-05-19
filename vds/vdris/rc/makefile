# $Id: makefile,v 1.6 2002/03/13 16:19:33 ahundiak Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:		vdris/rc/makefile
#
# Description:  Ris RC Library
#               
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.6  2002/03/13 16:19:33  ahundiak
#	ah
#	
#	Revision 1.5  2002/02/26 16:46:24  ahundiak
#	ah
#	
#	Revision 1.4  2001/11/09 14:57:23  ahundiak
#	ah
#	
#	Revision 1.3  2001/05/24 18:54:07  ahundiak
#	ah
#	
#	Revision 1.2  2001/02/11 17:59:58  ahundiak
#	Renamed VDris2 to VDrisc
#	
#	Revision 1.1  2001/02/01 21:58:19  ahundiak
#	ah
#	
#
# History:
# 02/01/01  ah  Creation
# -------------------------------------------------------------------

PROD = ${VDS_PATH}

TGT = ${PROD}/lib/vdirisrc

INCS = -I${RIS}/risdp/include \
       -I${NFMDP}/include     \
       -I${PROD}/include     \
       -I${VDS}/include

INCF = ${PROD}/include/VDtypedefc.h \
       ${PROD}/include/VDrisc.h     \
       ${PROD}/include/VDnfmc.h 

CCX = cc ${COMPOPT} ${MKDOPT} ${INCS}
CCR = ${RIS}/risdp/bin/riscpp ${COMPOPT} ${INCS}

target : ${TGT}.o
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${TGT}; \
	   /bin/cp ${TGT}.so ${SPV};   \
	   /bin/mv ${TGT}.so /usr/tmp; \
	else \
	   ldso    ${TGT}; \
	   /bin/mv ${TGT}.so /usr/tmp; \
	fi

${TGT}.o : VDrisQry.o VDrisKey.o VDrisBlob.o VDrisUtil.o VDrisDom.o VDrisStdPcmk.o VDrisPdmKey.o
	@ld -r -o ${TGT}.o VDrisQry.o VDrisKey.o VDrisBlob.o VDrisUtil.o VDrisDom.o VDrisStdPcmk.o VDrisPdmKey.o
	@ls -l ${TGT}.o

VDrisQry.o : ${INCF}  VDrisQry.rc
	@echo riscpp  VDrisQry.rc
	@${CCR}   -c  VDrisQry.rc

VDrisDom.o : ${INCF}  VDrisDom.rc
	@echo riscpp  VDrisDom.rc
	@${CCR}   -c  VDrisDom.rc

VDrisKey.o : ${INCF}  VDrisKey.rc
	@echo riscpp  VDrisKey.rc
	@${CCR}   -c  VDrisKey.rc

VDrisPdmKey.o : ${INCF}  VDrisPdmKey.rc
	@echo riscpp  VDrisPdmKey.rc
	@${CCR}   -c  VDrisPdmKey.rc

VDrisBlob.o : ${INCF} VDrisBlob.rc
	@echo riscpp  VDrisBlob.rc
	@${CCR}   -c  VDrisBlob.rc

VDrisStdPcmk.o : ${INCF} VDrisStdPcmk.rc
	@echo riscpp     VDrisStdPcmk.rc
	@${CCR}   -c     VDrisStdPcmk.rc

VDrisUtil.o : ${INCF} VDrisUtil.rc
	@echo riscpp  VDrisUtil.rc
	@${CCR}   -c  VDrisUtil.rc

