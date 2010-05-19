/* $Id: vdctblcmd.m,v 1.17 2002/05/20 18:39:39 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/vdtblcmdf.m
 *
 * Description:
 *
 * Makefile template for vdtbl/cmd directory
 *     (form layout commands)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdctblcmd.m,v $
 *      Revision 1.17  2002/05/20 18:39:39  ylong
 *      *** empty log message ***
 *
 *      Revision 1.16  2001/08/30 21:19:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.15  2001/08/29 21:02:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.14  2001/08/24 19:01:56  ylong
 *      *** empty log message ***
 *
 *      Revision 1.13  2001/08/24 18:59:04  ylong
 *      *** empty log message ***
 *
 *      Revision 1.12  2001/08/16 21:41:56  ylong
 *      Added export xml functionality
 *
 *      Revision 1.11  2001/07/03 14:09:26  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/05/31 19:48:39  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/05/23 14:28:44  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2001/05/21 13:25:20  paul_noel
 *      add vds/vdtbl/cmd/VDCTBSForm.I
 *
 *      Revision 1.7  2001/05/07 23:43:04  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/05/07 14:02:13  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/05/02 23:00:59  ylong
 *      TR5070
 *
 *      Revision 1.4  2001/05/02 21:29:41  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/04/25 15:49:39  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/25 13:58:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/04/16 14:25:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/04/06 15:23:40  ylong
 *      TR3320 and TR4997
 *
 *      Revision 1.2  2001/01/18 20:47:39  paul_noel
 *      Added VDCTBSForm.I to handle division of control for Create Table By Stage form to a modular form of operations
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:27  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/11  02:41:10  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1995/10/10  20:16:02  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by rmanem for vds.240
#
# Revision 1.8  1995/09/25  23:40:14  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by sundar for vds.240
#
# Revision 1.7  1995/08/18  21:01:36  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by hverstee for vds.240
#
# Revision 1.6  1995/07/30  20:48:26  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/25  14:16:14  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by rmanem for vds.240
#
# Revision 1.4  1995/07/06  16:32:04  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/06/21  13:48:08  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by yzhu for vds.240
#
# Revision 1.2  1995/06/19  20:06:24  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m for:  by hverstee for vds.240
#
# Revision 1.4  1995/05/25  18:06:10  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m by rmanem r#
#
# Revision 1.3  1995/04/29  17:08:12  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m by hverstee r#
#
# Revision 1.2  1995/04/14  19:43:34  pinnacle
# Replaced: vdtbl/cmd/vdtblcmdf.m by rmanem r#
#
# Revision 1.1  1995/04/13  14:11:54  pinnacle
# Created: vdtbl/cmd/vdtblcmdf.m by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *	04/14/95	rmn		Added files for "Place Table Header"
 *					and "Create Table" commands
 *	05/15/95	rmn		Added VDtblIntFTbl.I
 *	06/19/95	yz		Added VDCmdEdTbRw.S, VDCmdEdTbRwi.I
 *                                      and VDEdTbRwFrm.I for edit table row    
 *	07/24/95	rmn		Added VDrowLineOut.I
 *	10/05/95	rmn		Added VDtblRecomp.I
 *      01/18/01        pn              Added VDCTBSForm.I
 *
 * -------------------------------------------------------------------*/

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdctblcmd.o
#else
$VDS/lib/vdctblcmd.o
#endif

SOURCE
#if ISDP_MAKE_SP
VDhdrForm.I
VDCTBSForm.I
VDhdrPlace.I
VDtblFrmNot.I
VDtblInsDel.I
VDtblPlace.I
VDtblUpdCol.I
VDtblSumItm.I
VDtblProcFrm.I
VDtblLoc.I
VDtblMisc.I
VDCmdEdTbRwi.I
VDEdTbRwFrm.I
VDSSC_disp.I
VDTBX_cmdi.I
VDTBX_exec.I
VDTBX_disp.I
VDTBX_fn.I

#else
VDCmdDLO.S
VDDLO_cmdi.I
VDDLO_over.I
VDDLO_start.I
VDDLO_disp.I
VDDLO_edfn.I
VDDLO_cofn.I
VDDLO_htfn.I
VDDLO_flfn.I
VDDLO_rffn.I
VDDLO_rvfn.I
VDDLO_utfn.I
VDDLO_load.I
VDDLO_prev.I

VDCmdPlHdr.S
VDhdrMisc.I
VDhdrForm.I
VDhdrPlace.I

VDCmdCrTbl.S
VDtblMisc.I
VDtblFrmNot.I
VDtblFrmInit.I
VDtblProcFrm.I
VDtblLoc.I
VDtblPlace.I
VDtblUpdCol.I
VDtblUpdRow.I
VDtblSumItm.I
VDtblCpMv.I
VDtblInsDel.I
VDtblIntFTbl.I
VDtblRecomp.I
VDrowLineOut.I

VDCmdDLU.S
VDDLU_cmdi.I
VDDLU_disp.I
VDDLU_fn.I
VDDLU_exec.I
VDDLU_start.I

VDCmdSSC.S
VDSSC_cmdi.I
VDSSC_load.I
VDSSC_disp.I
VDSSC_fsrt.I
VDSSC_fsum.I
VDSSC_fexp.I
VDSSC_expr.I

VDCmdADS.S 
VDADS_cmdi.I
VDADS_disp.I
VDADS_fn.I 

VDCmdTBX.S
VDTBX_cmdi.I
VDTBX_exec.I
VDTBX_disp.I
VDTBX_fn.I

VDCmdEdTbRw.S
VDCmdEdTbRwi.I

VDEdTbRwFrm.I
VDCTBSForm.I

#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$BS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif

$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$NFMDP/include
$BS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$UMS/include
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

