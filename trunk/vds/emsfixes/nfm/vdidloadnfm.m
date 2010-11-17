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
/* ====================================================
 * SOL10 16 Nov 2010
 * NDMtr_files is causing a core dump when retrieving a file
 * Skip for now
 */
SOURCE
#if ISDP_MAKE_SP
VDnfmZip.c
NFMfile_tr.c
NFMtr_files.c
#else
VDnfmZip.c
NFMfile_tr.c
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdidoladnfm.o
#else 
$VDS/lib/vdidloadnfm.o
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
$UMS/include
$FORMS/include
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
