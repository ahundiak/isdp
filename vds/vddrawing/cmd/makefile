#/* $Id: makefile,v 1.7 2002/04/19 21:27:39 ylong Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/drawing/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
#
# * Revision 1.2  2001/01/08 19:02:59  art
# * ah
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/03/01  ah      Creation
# *
# ***************************************************************************/
TGT = vdcdrwcmd
TGT_PPL = vddrwppl

target: sl \
	pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ld -z text -G -o ${SPXV}/lib/${TGT}.so ${SPXV}/lib/${TGT}.o; \
	   /bin/cp ${SPXV}/lib/${TGT}.so ${SPV}; \
	   /bin/mv ${SPXV}/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${VDS}/lib/${TGT}.so ${VDS}/lib/${TGT}.o ; \
	   /bin/mv ${VDS}/lib/${TGT}.so /usr/tmp; \
	fi;

sl:	${VDS}/config/commands/VDMvDrwV

${VDS}/config/commands/VDMvDrwV : VDCmdMvDrwV.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p${VDS}/spec VDCmdMvDrwV.t

mkfile:	vddrwcmd.m
	grmakemake vddrwcmd.m mkfile

pplmkfile: ${TGT_PPL}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(SP); \
	else \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(VDS); \
	fi

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c
