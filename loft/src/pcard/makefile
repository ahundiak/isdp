# $Id: makefile,v 1.4 2002/03/26 00:28:43 ad Exp $  

# *************************************************************************
# I/LOFT
# 
#  File:        src/unwext/makefile
# 
#  Description: 
# 
#  Dependencies:
# 
#  Revision History:
#       $Log: makefile,v $
#       Revision 1.4  2002/03/26 00:28:43  ad
#       Update the makefile & pcard.m
#
#       Revision 1.3  2001/10/19 19:48:11  ylong
#       *** empty log message ***
#
#  History:
#       MM/DD/YY   AUTHOR       DESCRIPTION
#       10/19/01   Jayadev      File Creation
# ************************************************************************/

target: mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXL}/lib/vlpcard; \
	   /bin/cp ${SPXL}/lib/vlpcard.so ${SPL};   \
	else \
	   ldso    ${LOFT}/lib/vlpcard; \
	fi

mkfile: pcard.m
	grmakemake pcard.m mkfile

pplmkfile: pplpcard.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl pplpcard.m pplmkfile $(SP); \
	else \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl pplpcard.m pplmkfile $(LOFT); \
	fi
