/* $Id: vdiahc.m,v 1.12 2002/04/01 15:31:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/vdiahc.m
 *
 * Description: c Routines but usable from withing om
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiahc.m,v $
 *      Revision 1.12  2002/04/01 15:31:50  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/05/24 18:32:42  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/03/11 18:34:04  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/02/22 22:51:30  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.8  2001/02/17 13:58:14  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/02/08 15:19:10  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/05/00  ah      creation
 * 05/24/01  ah      Removed VDden, replace with VDval routine
 ***************************************************************************/

SOURCE
VDos.c
VDgbl.c
VDstr.c
VDlog.c
VDfld.c
VDfrm.c
VDfrm1.c
VDassert.c
VDvlaInfo.c
VDsys.c
VDtest.c
VDwarn.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiahc.o
#else
$VDS/lib/vdiahc.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

