/* $Id: vdassoc.m,v 1.13 2001/11/10 17:12:41 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / vdassoc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdassoc.m,v $
 *	Revision 1.13  2001/11/10 17:12:41  ramarao
 *	Fixed TR# 4425.
 *	
 *	Revision 1.12  2001/09/07 14:58:29  ramarao
 *	Implemented CR# 5346.
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/30/94	R. Manem	Added GRown_over.I
 *	01/17/95	R. Manem	Added ACpretendi.I
 *	02/07/95	R. Manem	Added COm_crdef1.I
 *	06/06/95	adz		Added ASfence.I
 *	09/18/95	rmn		Added pretendi.I pretendini.I
 *	11/03/95	adz		Add Macro problem/Remove for EMS2.3
 *	12/15/95	adz		TR179529394/TR179528392.
 *	01/24/96	adz		TR179528417 Warning connect messages.
 * 	03/05/96	adz		TR179600399 Invalid Point on CS objects
 *	05/20/96	adz		TR179420733 Mod Macro Def.
 *	10/29/97	ah		TR179701965 Macro naming
 *	01/08/98	adz		TR179603633 Macro crashes on ACformat
 *      03/05/98        ah              Add ov_ci_mac run_ci trace routine
 *      03/06/98        ah              Add VDbro1.I for debugging
 *      03/06/98        ah              TR179800518 Removed ASindexpti.I
 *      06/10/98        ejm             TR179701509 Added ACchg_feet.I
 *      09/27/98        ah              TR179801268 Added ACm_dn_const.I
 *      04/01/99        ylong           TR179900455 Added ACcpxi_macro.I
 *      04/10/99        ah              Added ASsrcNotify/VDsrcNotify routines
 *      02/10/00        HF              Removed COm_navigi.I from list, replaced
 *                                      by version in emsfixes/grnuc
 *      01/22/01        ah              Moved library to vds/lib
 *                                      Removed VDbro1.I as part of this process
 *	08/15/01	adz		Add ACrg_coli.I for MP2625
 * -------------------------------------------------------------------*/

SOURCE

#if ISDP_MAKE_SP
ACpretendi.I
ACrg_coli.I
ov_ci_maci.I
NDnodei.I
ACm_dn_const.I
ACchg_feet.I
nci_macroi.I
ACconsti.I
ACncpx_comp.I
#else
nci_macroi.I            /* To allow xml VDbufMacro ACgive_struct to work */

ACcpxi_macro.I
ACchg_feet.I
/* VDbro1.I */
ov_ci_maci.I

headloc.I		/*  ( cvl->attributes.type == GR_nam_loc ) line 122   */
NDnode_notif.I		/* TR179528417 Warning during disconnect/connect      */
NDnodei.I		/* Override NDconnect_graph to add trans_table info   */
ACcpx_loc.I             /* error message with ACpl_hold object selection      */
ASsupport.I		/* correction make_source for VDS surface objects     */
ACcond_defi.I		/* Test on ZERO feet & ...                            */
ACncpx_pass.I		/* ACbubble_up with no parents found crash.           */
ACcpx_symb.I		/* difference in channel criteria                     */
ACheadnddel.I		/* NDdelete; R-tree arrangement before deleting       */
ACheadxform.I		/* GRxform; R-tree arrangement before getting matrix  */
CO_hilitei.I		/* execute; NDdisplay on ACpretend & ACrg_collect err */
dir_macro.I 		/* change total path for libraries into relative      */
			/* Adapt for problem of checkin/checkout              */
NDmacro_over.I		/* transform GRgrgrp into ASgroup when they become    */
		        /* foot of a macro.                                   */
graphJL.I		/* NDancestor -> NDreal_ancestor for gettting list    */
trans_symb.I		/* ACtrans_symb check on pl_hold.                     */
smhdr_mat.I		/* Memory fault au reaffichage d'une Image lorsque on */
			/* detache le fichier reference contenant son model   */
COm_move3.I		/* Copy/Move Dependency Graph seleect problem         */
exp_util.I		/* method DIgive_output react invalid on OPT_TRAILER  */
exp_lib.I               /* function EXP_rec_untranslate: kludge for correct   */
                        /* display of expressions in directory system         */
ASfence.I		/* bug in ASstart_var_parent : introduced check for   */
                        /* non-zero count value, before allocating memory     */
ACrg_coli.I             /* dump method : improper argument to ACreturn_foot   */
                        /* method, leading to argument corruption             */
GRown_over.I		/* fix for improper return code, if no range is found */
ACpretendi.I		/* Suppress error message about bend_sweep            */
COm_crdef1.I		/* Suppress GRdisplay error message (navigate on      */
			/* private collectors of Struct objects)	      */
ASget_par.I		/* The locate can fail and result in crash of         */
			/*  requested locate command.			      */
			/* deleted         				      */
COm_option.I		/* fct COm_get_condit_def_hdr() corrections           */
COm_place4.I		/* Template naming changement.                        */
ACncpx_comp.I		/* Update problem in Nested macros		      */
AScspointi.I		/* Inform about invalid expression                    */
COcspointi.I		/* Avoid construction with invalid expression         */
text_expi.I		/* Avoid crash in NDgive_structure for long expression*/
ACinit.I		/* Function ACfind_temp_defn() possible cause of crash*/   	
COm_place3.I		/* Modified execute method for TRs 179601483/179600317*/
NDchannel.I		/* If the count  of objects is zero return OM_W_ABORT */
COm_modif4i.I		/* Mod Macro Defin problem */

COm_plName.I		/* TR179701965 */
ACadd_dir.I		/* TR179701965 */
ACm_dn_const.I          /* TR179801268  Can have invalid objects when recomputing macro */

ASsrcNotify.I
VDsrcNotify.I
ASindexpt1.I 		/* adz Crash on v_equal */

/* COm_navigi.I		TR179603633  Crash when ACmacro_defn.upscan failes
 *      02/10/00        HF           Removed COm_navigi.I from list, replaced
 *                                   by version in emsfixes/grnuc
 * -------------------------------------------------------------------*/

/* ---------------------------------
 * TR179800518 Art Hundiak
 * This fix to arcs broke a bunch of struct detail macros
 * Removing it from here but leaving the code in vdassoc
 * until it can be reviewed
 */
/* ASindexpti.I */		/* TR179800518 */

/*
 * MACRO CORRUPTION PROBLEM.
 */
ACtmp_defni.I		/* Macro corruption Correcton           */
ACndir.I		/* Macro corruption Error Message       */
NDsleep.I		/* Macro corruption Error Message       */
NDnsleep.I		/* Macro corruption Correcton           */
ACfind_temp.I		/* Macro corruption Error Message       */
super_parai.I		/* Macro corruption Correcton		*/

ACconsti.I
ASextbspi.I
ASnodei.I
AStextpmi.I
AStoggle.I
GRgrchgname.I
GRgrputname.I

/* INTEGRATED IN 02.04.00.24 */
/* pretendi.I		: Check for return status from ACfind_parent          */
/* pretendini.I		: Check for count, when model obj in ref file is      */
/* ASnode_other.I	: method ASadd_opt: introduced clone object           */
/* ACpretdefi.I         : NULL pointer crash for condinional                  */
/* ACdiowneri.I		: EMS 02.03. ACgive_path for ACrg_collect object      */

/* ACconsti.I		: Integrated in EMS 3                                 */
/* ACncpxi.I		: Integrated in EMS 3                                 */
/* ACcpxi.I		: Integrated in EMS 3                                 */
/* ACheaderi.I		: ACshow_data in EMS 3                                */
/* ACheadloc.I		: ACSget_part_path in EMS 3                           */
/* ACncpx_comp.I	: ACcontext_compute in EMS 3                          */
/* ACpretendi.I		: ASreturn_go in EMS 3                                */
/* ACpretendini.I	: ACfind_parent in EMS 3                              */
/* ACrep_sup.I		: ACcompute_rep_value in EMS 3                        */
/* ACrg_coli.I          : ACmod_list_attribute in EMS 3                       */
/* ASmultigo.I		: ACconnect_pretendin in EMS 3                        */
/* ASsourcei.I		: NDupdate in EMS 3                                   */
/* ASsourceini.I	: ASreturn_go in EMS 3                                */
/* COm_condit3.I	: Execute method with different instances.            */
/* COm_condit4.I	: find_feet() store from which macro the foot comes   */
/* NDchannel.I		: Integrated in EMS 3                                 */
/* ACconsume.I		: Integrated in EMS 3                                 */
/* NDMacCons.I		: Integrated in EMS 3 : file NDmacro_over.I	      */
/* headcontco.I		: Integrated in EMS 3 ACcontext_compute	              */
/* headloc.I		: GRlocate ( cvl->attributes.type == GR_nam_loc )     */
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdidloadassoc.o
#else
$(VDS)/lib/vdidloadassoc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
