cd ..# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smspace/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:16:40  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile
	grmake -r -k -f mkfile 

mkfile : smspacefc.m
	grmakemake smspacefc.m mkfile

clean:
	@rm -f mkfile *.o
	@rm -f SMspcTmpStr.c SMextcurv.c SMspace_int.c SMOrie.c
	@rm -f VDmdist.c SMspace_fn.c SMspace_int1.c SMSolUtil.c
