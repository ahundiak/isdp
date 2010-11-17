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
PDMloc_part1.c
PDMcp_files.c
PDMCheckOut.c
/* PDMloc_part.c  For reference only */
/* PDMrsearch.c   For reference only */
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdidloadpdm.o
#else 
$VDS/lib/vdidloadpdm.o
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
$RIS/risdp/include
$PDM/include
$NFM/include
$NFMDP/include
$PDU/include
$PDUDP/include
$BS/include
$BS/include/prototypes
$FORMS/include
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
