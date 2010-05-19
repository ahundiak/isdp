/* $Id: vdilocapi.m,v 1.1 2002/03/30 15:56:31 ad Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdlocate/api/vdilocapi.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdilocapi.m,v $
 *	Revision 1.1  2002/03/30 15:56:31  ad
 *	*** empty log message ***
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/01/02	isdp-dev	creation date
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VdsQuery.I
#else
LocateByName.I
VdsQuery.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
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

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdilocapi.o
#else
$VDS/lib/vdilocapi.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
