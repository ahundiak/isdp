/* $Id: vdpdm.m,v 1.1 2001/07/16 13:31:43 jdsauby Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/pdm / vdpdm.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/11/01	jds		created
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
PDMcipart.c
#else
PDMcipart.c
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdpdm.o
#else 
$VDS/lib/vdpdm.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$PDM/include
$NFM/include
$NFMDP/include
$PDU/include
$PDUDP/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$GRNUC/src/assoc/include_priv
$GRNUC/ingrsys
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
