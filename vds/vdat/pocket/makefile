# $Id $  

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdat/pocket/makefile
# *
# * Description: makefile for Select Assembly Component command
# *
# * Dependencies: .t file (not a .sl) is input to the slic processor
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.3  2001/05/25 17:05:00  ylong
# *      CR5067 and CR3986
# *
# *      Revision 1.2  2001/01/11 21:01:17  art
# *      sp merge
# *
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
# Revision 1.1  1997/12/18  21:08:14  pinnacle
# Assembly Tree: makefile for Select Assembly Component command, new
#
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 12/16/97  ejm     Created this file.
# * 01/11/01  ap      sp merge
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile
	ldso	${VDS_PATH}/lib/vdiatpoc
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   /bin/cp ${VDS_PATH}/lib/vdiatpoc.so ${SPV}; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/vdiatpoc.so /usr/tmp;


sl: ${VDS}/config/commands/VDSlAsCp

${VDS}/config/commands/VDSlAsCp: VDCSlAsCp.S VDCSlAsCp.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCSlAsCp.t

mkfile:	vdiatpoc.m
	grmakemake vdiatpoc.m mkfile

clean:
	@rm -f mkfile *.o *.c

