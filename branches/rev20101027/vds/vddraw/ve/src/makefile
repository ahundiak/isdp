# $Id: makefile,v 1.4 2002/03/30 16:19:21 ad Exp $  

# *************************************************************************
# I/VDS
# 
#  File:        vddraw/ve/src/makefile
# 
#  Description: 
# 
#  Dependencies:
# 
#  Revision History:
#       $Log: makefile,v $
#       Revision 1.4  2002/03/30 16:19:21  ad
#       *** empty log message ***
#
#       Revision 1.3  2002/03/30 16:05:05  ad
#       *** empty log message ***
#
#       Revision 1.2  2001/10/20 18:15:23  ylong
#       *** empty log message ***
#
#
#  History:
#       MM/DD/YY   AUTHOR       DESCRIPTION
#       10/20/01   Jayadev      File Creation
# ************************************************************************/

target: mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/vdidrawve_sr; \
	   /bin/cp ${SPXV}/lib/vdidrawve_sr.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/vdidrawve_sr.so /usr/tmp; \
	else \
	   ldso    ${VDS}/vddraw/ve/lib/vdidrawve_sr; \
	   /bin/mv ${VDS}/vddraw/ve/lib/vdidrawve_sr.so /usr/tmp; \
	fi

mkfile: vdvesrc.m
	grmakemake vdvesrc.m mkfile
