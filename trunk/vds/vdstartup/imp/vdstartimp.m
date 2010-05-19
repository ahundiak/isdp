/* $Id: vdstartimp.m,v 1.4 2001/11/08 17:39:05 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / vdstartimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdstartimp.m,v $
 *	Revision 1.4  2001/11/08 17:39:05  ramarao
 *	Fixed TR# 5662.
 *	
 *	Revision 1.3  2001/08/01 21:57:00  ramarao
 *	Fixed TR# 5480.
 *	
 *	Revision 1.2  2001/01/26 00:14:21  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/16  20:04:24  pinnacle
# Replaced: vdstartup/imp/vdstartimp.m for:  by lawaddel for vds
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/11/21  00:57:50  pinnacle
# Replaced: ./vdstartup/imp/vdstartimp.m for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/10  18:30:56  pinnacle
# Replaced: vdstartup/imp/vdstartimp.m for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDureflib.I
VDSupdrefdep.I
#else
VDsuper.S		/* create & check VDsuper object	*/
VDsuperi.I

VDScheck_pdu.C		/* check if PDU is present		*/
VDSnopdu_ini.C		/* setting PDU functionality		*/
VDaddPktMenu.C          /* Call back function for VDS		*/
VDSudp_init.I		/* set "user defined path"		*/

VDureflib.I
VDSupdrefdep.I		/* check update reference files		*/

/* VDSnopdu_def.c 	: obsolete file comming from VDSno_pdu	*/
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdstartimp.o
#else
$VDS/lib/vdstartimp.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$EXNUC/om/include
$GRNUC/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$MODEL/include
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/vdinclude
$(SPXV)/include/prototypes
#endif
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
