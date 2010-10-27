/* $Id: vdmacrimp.m,v 1.3 2001/06/22 20:02:30 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/vdmacrimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmacrimp.m,v $
 *	Revision 1.3  2001/06/22 20:02:30  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/06/18 20:53:46  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/10/29  22:15:32  pinnacle
# Replaced: vdequip/api/vdmacrimp.m for:  by v241_int for vds.241
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
EquipMod.I
EquipPla.I
#else
Collector.I
EquipDef.I
EquipMod.I
EquipPla.I
MacroDef.I
MacroMod.I
MacroPla.I
PlaceGen.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
/usr/ip32/forms/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes
$PDU/include

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdmacrimp.o
#else
$VDS/lib/vdmacrimp.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
