/* $Id: vdictybase.m,v 1.2 2001/03/11 18:38:03 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdictx/c/vdictxc.m
 *
 * Description: Dot c routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictybase.m,v $
 *      Revision 1.2  2001/03/11 18:38:03  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:00:48  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      creation
 ***************************************************************************/

SOURCE
VDctyMgr.c
VDctyInit.c
VDctyBase.c
VDctyProd.c
VDctyPlot.c
VDctyMisc.c
VDctyStdParts.c
VDctyEngAttrs.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdictybase.o
#else
$VDS/lib/vdictybase.o
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

