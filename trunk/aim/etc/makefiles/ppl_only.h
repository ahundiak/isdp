# $Id: ppl_only.h,v 1.2 2002/05/02 18:30:23 ahundiak Exp $ 

# --------------------------------------------------------------------------
#  I/ROUTE
#
#  File:        aim/etc/makefiles/lib_only.h
#
#  Description: The template (based on the template created by Art) for
#               makefiles which generates .e files out of PPLs
#
#  Dependencies:
#
#  Revision History:
#       $Log: ppl_only.h,v $
#       Revision 1.2  2002/05/02 18:30:23  ahundiak
#       *** empty log message ***
#
#       Revision 1.1  2002/01/16 20:26:59  jdsauby
#       Initial Add into CVS, for making AIM Service Packs
#
#       Revision 1.1  2001/03/31 19:57:05  ahundiak
#       ah
#
#       Revision 1.5  2001/01/26 16:31:41  build
#       *** empty log message ***
#
#       Revision 1.4  2001/01/23 20:35:31  anand
#       VDS' mkmkppl was called thinking it was more generic.
#       But no! One must call only ROUTE's mkmkppl!!
#
#       Revision 1.3  2001/01/22 18:32:02  anand
#       if conditions in makefiles need test arguments!!
#
#       Revision 1.2  2001/01/21 20:56:52  anand
#       Corrected an error in makefiles. Makefiles do not understand
#       parameter substitution as shell scripts do! :(
#
#       Revision 1.1  2001/01/19 20:09:30  anand
#       Template makefile for directory.
#
#  History:
#  	MM/DD/YY  AUTHOR  DESCRIPTION
#  	05/02/05  Ad      creation-update
# --------------------------------------------------------------------------

target:	pplmkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1 ; \
	then \
	   /bin/cp ${SPXA}/ppl/bin/*.e ${SPB}; \
	fi

pplmkfile: ${TGT}.m
	ksh $(AIM_PATH)/etc/bin/mkmkppl ${TGT}.m pplmkfile $(AIM_PATH); \


