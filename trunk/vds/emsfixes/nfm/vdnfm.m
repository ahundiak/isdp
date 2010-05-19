/* $Id: vdnfm.m,v 1.2 2002/02/26 16:51:42 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/nfm / vdnfm.m
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
VDnfmZip.c
NFMfile_tr.c
#else
VDnfmZip.c
NFMfile_tr.c
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdnfm.o
#else 
$VDS/lib/vdnfm.o
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
$SPXV/emsfixes/nfm/include
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
$RIS/risdp/include
./include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
