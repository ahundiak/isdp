# $Id: makefile,v 1.7 2001/10/10 18:46:17 ramarao Exp $  

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
#       Revision 1.7  2001/10/10 18:46:17  ramarao
#       Implemented CR# 5644.
#
#       Revision 1.6  2001/04/16 22:14:10  ramarao
#       *** empty log message ***
#
#       Revision 1.5  2001/04/16 21:47:04  ramarao
#       *** empty log message ***
#
#       Revision 1.4  2001/04/16 21:24:22  ramarao
#       Fixed TR# 5063.
#
#       Revision 1.3  2001/04/16 17:00:35  ramarao
#       Implemented CR#4086 on Auto Labeling.
#
#       Revision 1.2  2001/04/12 20:38:08  ramarao
#       Fixed TR# 5025.
#
#       Revision 1.1.1.1  2001/01/04 21:11:56  cvs
#       Initial import to CVS
#
# 
#  History:
#       MM/DD/YY   AUTHOR       DESCRIPTION
#       10/28/97   Rama Rao     File Creation
#	01/28/00   Rama Rao     Added pplunwext.m
# ************************************************************************/

target: mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXL}/lib/vlunwext; \
	   /bin/cp ${SPXL}/lib/vlunwext.so ${SPL};   \
	   UNWAPI=${SP}/api; \
	   mkdir -p $${UNWAPI}; \
	   chmod +w $${UNWAPI}/.; \
	   if test -f $${UNWAPI}/COz_lblInfo.u; \
	   then \
		chmod +w $${UNWAPI}/*; \
	   fi; \
	   /bin/cp COz_lblInfo.u $${UNWAPI}; \
	   /bin/cp tbl_loft.u $${UNWAPI}; \
	else \
	   ldso    ${LOFT}/lib/vlunwext; \
	   UNWAPI=${LOFT}/api; \
           mkdir -p $${UNWAPI}; \
	   chmod +w $${UNWAPI}/.; \
	   if test -f $${UNWAPI}/COz_lblInfo.u; \
	   then \
	       chmod +w $${UNWAPI}/*; \
	   fi; \
	   /bin/cp COz_lblInfo.u $${UNWAPI}; \
	   /bin/cp tbl_loft.u $${UNWAPI}; \
	fi

VLmodextCmdi.I: VLmodextCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLmodextCmd.sl -p $(LOFT)/spec

VLunwextCmdi.I: VLunwextCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLunwextCmd.sl -p $(LOFT)/spec

mkfile: vlunwext.m
	grmakemake vlunwext.m mkfile

pplmkfile: pplunwext.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl pplunwext.m pplmkfile $(SP); \
	else \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl pplunwext.m pplmkfile $(LOFT); \
	fi
