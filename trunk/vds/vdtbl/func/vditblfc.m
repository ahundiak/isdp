/* $Id: vditblfc.m,v 1.16 2002/06/06 17:03:50 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdtbl/func / vdtblfc.m
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
 *	04/20/95	yz		add VDdrwPreTbl.I
 *	06/20/95	tlb		Add VDdrwcomp.C
 *	07/06/95	rmn		Added VDdrw_tblSum.I
 *	07/11/95	rmn		Added VDdrw_ADS.I
 *	07/17/95	tlb		Added VDdrwGenItem.I
 *	10/10/95	rmn		Added VDdrw_recomp.I, VDdrw_updTbl.I
 *      01/18/01        pn              Added VDdrw_PlSTbl.I
 *	02/19/01	yl		Added VDdrwTblUp.I, VDdrw_tblcheck.I,
 *					VDdrw_tblfunc.I
 *	10/08/01	yl		Added VDdrw_xmlTbl.I
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDdrw_edLnOut.I
VDdrw_tblValid.I
VDdrw_xmlTbl.I
VDdrw_tblfunc.I
VDdrw_CrTbFc.I
VDdrw_PlSTbl.I
VDdrw_PlITbl.I
VDdrw_PlITls.I
VDdrw_attVal.I
VDdrw_sort.I
VDdrw_tblSum.I
VDdrwTblUp.I

#else
VDdrw_edLnOut.I
VDdrw_tblValid.I
VDdrw_xmlTbl.I
VDdrwGenItem.I
VDdrwcomp.C
VDdrw_gMat.I
VDdrw_mvRows.I
VDdrw_addCmp.I
VDdrw_hdrMac.I
VDdrw_rowMac.I
VDdrw_CrTbFc.I
VDdrw_auWrap.I
VDdrw_attVal.I
VDdrwPreTbl.I
VDdrw_sort.I
VDdrw_tblSum.I
VDdrw_ADS.I
VDdrw_recomp.I
VDdrw_updTbl.I
VDclplace.I
VDdrw_PlSTbl.I
VDdrw_PlITbl.I
VDdrw_PlITls.I
VDdrwTblUp.I
VDdrw_tblcheck.I
VDdrw_tblfunc.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vditblfc.o
#else
$VDS/lib/vditblfc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/vdinclude
$(SPXV)/include/prototypes
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
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

