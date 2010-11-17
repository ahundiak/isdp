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
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/05/00  ah      creation
 * 05/24/01  ah      Removed VDden, replace with VDval routine
 * 11/17/10  ah      SOL10 Added VDship and VDdom2
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
VDship.c
VDdom2.c

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

