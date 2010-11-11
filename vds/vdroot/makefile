# $Id: makefile,v 1.3 2001/10/29 17:30:40 anand Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdroot/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.3  2001/10/29 17:30:40  anand
#	On behalf of Ad
#	
#	Revision 1.2  2001/10/27 17:19:19  ad
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:52:00  pinnacle
# rep bin w/txt
#
# Revision 1.4  1995/07/24  16:41:10  pinnacle
# Replaced: vdroot/makefile for:  by hverstee for vds.240
#
# Revision 1.3  1994/12/23  22:09:32  pinnacle
# Replaced: vdroot/makefile by tdumbach r#
#
# Revision 1.2  1994/12/22  00:24:16  pinnacle
# Replaced: vdroot/makefile by azuurhou r#
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
#	12/21/94	adz		add new functions.
#	10/27/01	adz		Adapt for SP.
# -------------------------------------------------------------------

TGT = vdiroot
TGTm = vdroot

target: mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/${TGT}; \
	   /bin/mv ${SPXV}/lib/${TGT}.so ${SPV}; \
	fi

mkfile: ${TGTm}.m
	grmakemake ${TGTm}.m mkfile

clean:
	@rm -f mkfile *.o *.c
