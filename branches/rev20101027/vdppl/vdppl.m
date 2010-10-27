/* $Id: vdppl.m,v 1.62 2002/06/07 14:48:08 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdppl / vdppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdppl.m,v $
 *	Revision 1.62  2002/06/07 14:48:08  ramarao
 *	Implemented To Do List.
 *	
 *	Revision 1.61  2002/05/31 16:16:23  jdsauby
 *	Added COz_risCache for debug tool of VDrisCache.c, JDS
 *	
 *	Revision 1.60  2002/05/29 19:07:19  anand
 *	missing from the build
 *	
 *	Revision 1.59  2002/05/20 18:43:07  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.58  2002/05/15 17:49:19  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.57  2002/05/10 18:50:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.56  2002/05/09 17:46:10  ahundiak
 *	ah
 *	
 *	Revision 1.55  2002/05/02 21:13:36  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.54  2002/04/24 14:31:34  ahundiak
 *	ah
 *	
 *	Revision 1.53  2002/04/12 17:25:30  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.52  2002/04/12 14:36:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.51  2002/04/04 21:08:31  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.50  2002/01/04 22:01:14  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.49  2001/11/29 15:22:19  ylong
 *	Add COz_SumSrt.u, remove COz_tblSum.u and COz_tblSort.u
 *	
 *	Revision 1.48  2001/11/15 16:47:40  hans
 *	Fix for TR# MP5602
 *	
 *	Revision 1.47  2001/11/05 19:12:44  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.46  2001/10/21 18:58:18  ramarao
 *	Implemented CR# 4081.
 *	
 *	Revision 1.45  2001/10/20 18:37:22  ramarao
 *	Implemented CR# 4033.
 *	
 *	Revision 1.44  2001/10/19 16:54:22  ramarao
 *	Fixed TR# 5594.
 *	
 *	Revision 1.43  2001/10/02 16:11:24  paul_noel
 *	new ppl
 *	
 *	Revision 1.42  2001/09/20 14:35:56  ahundiak
 *	ah
 *	
 *	Revision 1.41  2001/09/19 16:09:07  hans
 *	Tool to fix TR# MP5556
 *	
 *	Revision 1.40  2001/09/12 21:06:15  ramarao
 *	Gives a warning in case of GRcontext problems TR# 5583 and TR# 5111.
 *	
 *	Revision 1.39  2001/09/07 17:24:26  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.38  2001/08/30 17:57:40  hans
 *	TR# 5508 - Add VDclean_UOM.u & dbgUOM.u
 *	
 *	Revision 1.37  2001/08/30 13:55:17  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.36  2001/08/24 16:07:07  ramarao
 *	Fixed TR# 5500.
 *	
 *	Revision 1.35  2001/08/14 20:21:39  ramarao
 *	Made VDclean_ctx ppl obsolete.
 *	
 *	Revision 1.34  2001/07/24 17:28:14  hans
 *	Moved toggle_dr.u to vdppl directory from vdintersect
 *	
 *	Revision 1.33  2001/07/10 20:00:42  hans
 *	*** empty log message ***
 *	
 *	Revision 1.32  2001/07/10 18:44:18  hans
 *	No TR. Optimizations for suppressing FALSE Interferences
 *	
 *	Revision 1.31  2001/07/03 14:42:41  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.30  2001/06/24 18:18:19  jayadev
 *	modify iso frames command
 *	
 *	Revision 1.29  2001/06/22 14:59:54  ahundiak
 *	ah
 *	
 *	Revision 1.28  2001/06/08 20:48:43  ahundiak
 *	ah
 *	
 *	Revision 1.27  2001/06/03 14:56:45  ahundiak
 *	ah
 *	
 *	Revision 1.26  2001/05/24 18:28:29  ahundiak
 *	ah
 *	
 *	Revision 1.25  2001/05/24 18:24:47  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.24  2001/05/23 14:20:35  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.23  2001/05/01 14:41:07  ramarao
 *	Fixed TR# 5130.
 *	
 *	Revision 1.22  2001/04/30 15:22:18  ramarao
 *	Added COz_chkConst ppl.
 *	
 *	Revision 1.21  2001/04/24 13:14:00  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.20  2001/04/12 22:38:18  ramarao
 *	Fixed TR# 5033.
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/24/95	tlb		Drop COrmVolSet.u - no longer used
 *	09/13/95	adz		Add COReview.u
 *	03/04/96	adz		Add COerr_symb.u
 *	08/07/96	yzhu		Add format_caps.u
 *	09/29/97	sundar/adz	Add COUpdEquip.u
 *      03/05/98        ah              Add COdbgFlags.u
 *      04/24/98        ah              Add VDgenCL.u
 *      07/23/98        ah              Add COWrLayers.u
 *      08/17/98        Vinit           Add create_part.u
 *      08/21/98        ejm             Add vd_shared.u
 *      10/01/98        ah              Add CORevAttr.u
 *      11/05/98        ah              Add some connections repair ppl's
 *      02/12/99 	Ming		Add COdrwfrm_iso.u
 *      02/18/99 	ejm 		Add COqryPDM.u, COsrchPDM.u
 *      02/19/99 	ylong 		Add COdrw_orient.u
 *      03/05/99 	ejm 		Add COdrop_mac.u
 *      04/21/99        ah              Add COpdmGen.u and COpdmSearch.u
 *      04/27/99 	ejm 		Add VDgetFileNm.u
 *      04/30/99        ah              Add COset_trace.u
 *      06/03/99        ah              Add COz_update.u
 *      10/12/99        ah              File size cleanup problems
 *      10/13/99        ah              Add COname_base.u
 *      01/17/00        ah              Add COz_ScanCtx.u
 *      01/18/00        ah              Add COz_FixTR.u
 *      01/27/00        ylong           Add COoffsetData.u
 *      03/17/00        ah              Add COz_tag.u
 *                 SP16 additions
 *	04/27/00	adz		Add COz_ctx.u
 *      05/19/00        ah              Add COz_CompObj.u
 *      05/30/00        HF              Add false_intf.u
 *                                      Update COz_FixTR.u
 *      06/03/00        ah              Update CORevAttr.u
 *      06/05/00        Alwin           Add ExitPDU.u
 *      06/05/00        HF              Add getsetscale.u
 *      06/05/00        Jayadev         Add COz_userPath.u
 *      06/14/00        HF              Add toggle_pmsg.u
 *      06/14/00        HF              Add toggle_sbuf.u
 *      06/27/00        ah              Add COlist routines to debug locate stuff
 *      08/05/00        ah              Add CObroNB.u (moved from vdnb/ppl)
 *      08/07/00        ylong		Add VDdrwTblUp.u
 *      08/08/00        HF              Add MODELversion.u
 *      08/17/00        ah              Add COz_schema.u
 *      08/17/00        ah              Add COz_schema.u
 *      08/21/00        jvh             Add VDlocateMacs.u VDlocateACps.u
 *      08/25/00        HF              Renamed existing COz_FixRT.u to COz_OldRT.u
 *                                      and created new version of COz_FixRT.u
 *                                      (eventually COz_OldRT.u should be phased out!)
 *      08/30/00        HF              Add VDclean_ndn.u CR#179901913
 *      09/20/00        jvh             Add VDreportMacs.u list all macros in files
 *      09/24/00        Jayadev         Add COz_iso.u
 *      09/28/00        jvh	        Add COinfo.u
 *	10/16/00	ah		Add COz_DelBlobs.u
 *      10/18/00        HF              Add toggle_intf.u
 *	10/19/00	ah		Add COz_FixTags.u
 *      10/20/00        ah              Add COz_ShowCol.u
 *      10/23/00        Jayadev         Add AStoggle.u
 *	10/31/00	ylong		Add COoffsetData.u
 *	10/31/00	jvh		Add rtree.u
 *      11/01/00        pn              Add PartQty.u
 *      11/01/00        Jayadev         Add COz_reduce.u
 *      11/02/00        HF              Add redurange.u & toggle_rdrg
 *      11/03/00        Jayadev         Add COz_deldrw3d.u
 *      11/27/00        ah              Add COListBlobs.u COz_act.u
 *                                      Add COz_QryMat.u COz_GetSch.u
 *      10/18/01        HF              Merged SP16 additions/modifications
 *	02/05/01	Anand		Added CO_ExQry.u
 *	02/06/01	Jayadev		Added COz_consume.u
 *      02/11/00        HF              Add BSPversion.u
 *	02/13/01	Jayadev		Added COz_evalExp.u
 *      03/02/01        HF              Added VDreadjnl.u
 *      03/03/01        HF              Added toggle_verb.u
 *      03/05/01        HF              Added VDstrjnl.u
 *      04/24/01        ylong		Added COz_rvtRow.u
 *      07/10/01        HF              Add truerange.u & rngchk_intf.u
 *	08/29/2001	HF		TR#5508 - Add VDclean_UOM.u & dbgUOM.u
 *	09/19/2001	HF		Tool to fix TR# MP5556 - Add COz_fr_rtree.u
 *	11/16/2001	HF		Add COdmplan.u - Fix for TR# MP5602
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q

#if ISDP_MAKE_SP
COz_tblDbg.u
COz_tblValid.u
COz_drwSetup.u
COclr_comp.u
COz_SumSrt.u
VDstartup.u
COz_CompFile.u
COz_rvtRow.u
COz_chkConst.u
COz_reffiles.u
VDdrwTblUp.u
COz_act.u
COz_tree.u
COvalSpades.u
COvalSpades2.u
COvalXml.u
CORevAttr.u
COatXml.u
COatGetPost.u
COrev_xml.u
COmodfrm_iso.u
truerange.u
rngchk_intf.u
VDclean_ctx.u
VDclean_ctx1.u
COz_rprDisp.u
VDclean_UOM.u
dbgUOM.u
COlisty.u
COz_refCtx.u
COz_fr_rtree.u
COz_xslt1.u
COz_xmlxsl.u
COz_drwDisp.u
COz_badOcc.u
COz_eqpDup.u
COdmplan.u
#else
COz_fix01.u
#if 0
COmodfrm_iso.u
COz_tblDbg.u
COz_tblValid.u
COclr_comp.u
ACget_mac_id.u
ACget_obj_id.u
ACren_temp.u
COReview.u
COTogDspOff.u
COUpdEquip.u
COWrLayers.u
COall_comp.u
CObatData.u
COchg_ups.u
COdbgFlags.u
COdrop_mac.u
COdrw_orient.u
COdrwfrm_iso.u
COerr_symb.u
COname_base.u
COpdmGen.u
COpdmSearch.u
COqryPDM.u
COset_trace.u
COsrchPDM.u
COupd_comp.u
COz_DispId.u
COz_DrwEnv.u
COz_FileDate.u
COz_PrtTog.u
COz_ScanCtx.u
COz_ShowId.u
COz_UsrAtt.u
COz_checkLib.u
COz_copyLo.u
COz_cvonsf.u
COz_dispattr.u
COz_evalsurf.u
COz_exp.u
COz_fix01.u
COz_fixrtree.u
COz_osnames.u
COz_pnav.u
COz_rvRefLib.u
COz_scan01.u
COz_space.u
COz_tag.u
COz_tagcons.u
COz_update.u
COz_SumSrt.u
VDLogDb.u
VDclasslist.u
VDclean_crv.u
VDclean_exp.u
VDclean_nci.u
VDgenCL.u
VDgetFileNm.u
VDpostconn.u
VDswaptask.u
add_reps.u
batdrw.u
chreftype.u
create_part.u
format_caps.u
mem.u
moff.u
mtrace.u
nodecog.u
nodedim.u
nodemass.u
nodevolume.u
pdu_start.u
reverse.u
scanchan.u
showcusp.u
showdir.u
showmultpol.u
showpoles.u
split_poles.u
stopsign.u
testdir.u
toggle.u
toggle_BSdbg.u
toggle_bs.u
toggle_loop.u
updModel.u
vd_shared.u

/* SP16 additions/modifications */

AStoggle.u
COListBlobs.u
CORevAttr.u
CObroNB.u
COinfo.u
COlist.u
COlistx.u
COlisty.u
COoffsetData.u
COrefOff.u
COrefOn.u
COz_BugRoot.u
COz_CompObj.u
COz_DelBlobs.u
COz_DelTag.u
COz_FixRT.u
COz_FixTags.u
COz_GetSch.u
COz_OldRT.u
COz_QryMat.u
COz_RefMgr.u
COz_ShowCol.u
COz_TogRule.u
COz_act.u
COz_checkBAD.u
COz_chkprt.u
COz_cleanRT.u
COz_ctx.u
COz_deldrw3d.u
COz_delref.u
COz_iso.u
COz_like.u
COz_macro.u
COz_chanObj.u
COz_reduce.u
COz_reffiles.u
COz_repAttr.u
COz_schema.u
COz_siblings.u
COz_undodel.u
COz_userPath.u
ExitPDU.u
MODELversion.u
PartQty.u
VDcheckTbl.u
VDclean_ctx.u
VDclean_ctx1.u
COz_rprDisp.u
VDclean_ndn.u
VDdrwTblUp.u
VDlocateACps.u
VDlocateMacs.u
VDreportMacs.u
VDstartup.u
false_intf.u
getsetscale.u
redurange.u
showrange.u
truerange.u
toggle_intf.u
toggle_pmsg.u
toggle_rdrg.u
toggle_sbuf.u
rngchk_intf.u

/* Pload 2.6.2.0 additions */

BSPversion.u
COz_ExQry.u
COz_consume.u
COz_fixColl.u
COz_evalExp.u
COz_drwSetup.u
VDreadjnl.u
VDstrjnl.u
toggle_verb.u
toggle_dr.u
COz_chkSym.u
COz_exit.u
COPPLinfo.u
COz_CompFile.u
COz_rvtRow.u
COz_chkConst.u
COrev_xml.u
VDclean_UOM.u
dbgUOM.u
COz_refCtx.u
COz_fr_rtree.u
COz_drwDisp.u
COz_badOcc.u
COz_eqpDup.u
COz_DRC.u
COdmplan.u

COvalSpades.u
COvalSpades2.u

/* Pload 2.6.3.0 additions */

COz_risCache.u
COtoDoList.u
#endif
#endif
