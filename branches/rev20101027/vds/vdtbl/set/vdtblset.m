/* $Id: vdtblset.m,v 1.2 2001/07/27 14:13:03 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdtbl/set / vdtblset.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/14/95	rmn		Creation
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDdrwSeti.I
#else
VDdrwSet.S
VDdrwSeti.I
VDdrwSetOver.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vditblset.o
#else
$VDS/lib/vditblset.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

OPPFLAGS
/*-l*/

