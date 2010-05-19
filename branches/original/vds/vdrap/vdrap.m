/* $Id: vdrap.m,v 1.2 2001/06/06 16:38:40 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / vdrap.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdrap.m,v $
 *	Revision 1.2  2001/06/06 16:38:40  hans
 *	Fix for TR#5210 - Start/Stop record not working if ISDP_JOURNAL is not set.
 *	
 *	Revision 1.1  2001/03/02 22:56:02  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdirap.o
#else
$VDS/lib/vdirap.o
#endif

SOURCE
#if ISDP_MAKE_SP
VDRAPlisnri.I
#else
VDRAPcobCO.S
VDRAPlisnr.S
VDRAPcobCOi.I
VDRAPlisnri.I
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$INGRHOME/include
$XINCL/include
$EXNUC/include
$BS/include
$GRNUC/include
$BS/include/prototypes
$GRNUC/proto_pub
$GRNUC/proto_priv
$VDS/include
$VDS/vdinclude

OPP
$EXTARG/bin/opp

OMCPP
$EXTARG/bin/omcpp
