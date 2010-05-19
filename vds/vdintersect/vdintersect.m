/* $Id: vdintersect.m,v 1.2 2001/07/24 17:12:41 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintersect / vdintersect.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdintersect.m,v $
 *	Revision 1.2  2001/07/24 17:12:41  hans
 *	Inconsistent use of _MALLOC/_FREE
 *	Moved toggle_dr.u to vdppl directory
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/18  21:07:20  pinnacle
# CR_179701424: Get surf/frm intersection points; added SOURCE entry VDptsGetSfFr.I
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/06/02  15:18:46  pinnacle
# Replace: vdintersect/vdintersect.m by azuurhou for OPE
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
 *	06/01/95	adz		add new cv data reduction function.
 *      09/18/97	ejm		added SOURCE entry VDptsGetSfFr.I
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDptsGetSfFr.I
#else
EMintelems.I
EMbcPostAb.I
VDSreduidata.I
VDdataredcv.I
VDptsGetSfFr.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdintersect.o
#else
$VDS/lib/vdintersect.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
