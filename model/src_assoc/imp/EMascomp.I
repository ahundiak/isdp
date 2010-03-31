/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#define DEBUG 0
#include <stdio.h>
#include "graph.h"
#include "EMSasopts.h" /*  For EMSasconst_recompute */
#include "gocmacros.h"
#include "nddef.h" /* For ND_COMP_SUCC */
#include "exmacros.h"
#include "EMSkey.h"
#include "EMSasectvw.h"

extern IGRboolean WANT_POST220_BEHAVIOR;
from GAcurve import GAis_msc;
from EMSpointer import EMstore_id;

extern short  _pathway_trim, _pathway_orient;
extern OMuword OPP_EMSagrp_class_id;
extern OMuword OPP_GAcurve_class_id;
extern OMuword OPP_EMSpointer_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_EMSasectvw_class_id;

method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
/* *************************************************************************

Description
This method computes the new geometry and updates the node for all
associative vector graphic constructions.

History
 Add WANT_POST220_BEHAVIOR logic : AIC : 06/08/93
 Setting construct_list.class_attr to NULL since : WBC : 11/11/92
 we don't know what the element specific attribute
 of the component will be.
 Making sure that at the very least IS_ASSOCIATIVE : PP : 09/28/91
 and HAS_EXTERNAL_CONSTRAINT bit gets set if the
 old guy had it.
 Added support of ND_COMP_NO_ADD_RT and : PP : 08/10/91
 ND_COMP_NO_REM_RT and removed obsolete comments.
 Changed NDcompute_node to NDupdate : PP : 07/12/91
 and removed code related to the
 kludge below. 
 Set current_creator to the new id  : DLB : 6/01/91
 Moved kludge_new_objid to here from batch.I : DLB : 3/26/91
 Added a check for pointer updation (specific to recreation of solid
 in section views    : SpB, Satish
 Creation Date       : PP : 03/07/91
   ************************************************************************* */
{
 IGRlong status,msg_loc;
 IGRshort action;
 struct GRsymbology symb;
 struct GRvg_construct construct_list;
 extern IGRboolean dynamics_in_progress;
 enum GRdpmode  dpmode;
 IGRuint info_size;
 IGRint recompute = TRUE;
 IGRchar *info_ptr;
 IGRuint type;
 IGRshort graphics_props, new_graphics_props;
 OMuword my_classid;
 OM_S_OBJID new_leafid, store_id = NULL_OBJID;
 struct GRmd_env recomp_env;
 struct GRid cur_mod;
 extern OM_S_OBJID current_creator;
 OM_S_CHANSELECT children;
 IGRboolean SAVE_POST220_BEHAVIOR;
 IGRint dont_display=0;
 short save_pathway_trim=0, save_pathway_orient=0;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /*
  * AIC 06/08/93
  * Set the global "WANT_POST220_BEHAVIOR" based on my
  * GRIS_POST220_OBJECT properties bit.
  */
 SAVE_POST220_BEHAVIOR = WANT_POST220_BEHAVIOR;
 status = om$send(msg = message GRgraphics.GRgetprops((IGRlong *)EMmsg,
                    &graphics_props), 
                  targetid = my_id);
 if(! (1 & status & *EMmsg)) goto wrapup;
 if(graphics_props & GRIS_POST220_OBJECT)
  WANT_POST220_BEHAVIOR = TRUE;
 else
  WANT_POST220_BEHAVIOR = FALSE;

/*
 * Initialise the new object to be myself so that even if we fail
 * the dependents can still recompute based on my geometry if they
 * like.
 * pp 07/12/91
 */
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;
 recomp_env = *md_env;
 recomp_env.md_id.objid = NULL_OBJID;

 if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                          OPP_GAcurve_class_id, FALSE))
 {
  IGRint flag=0;

   om$send (msg = message GAcurve.GAis_msc((IGRlong *)EMmsg, &flag),
                  targetid = my_id);
   if (flag) dont_display=1;
  
 }

/*
 * I am in dynamics else do not recompute to prevent locking up the terminal.
 */

/* Need to have the capability to remove nodes from the graph manager
 * Hence if dynamics in progress prevent recomputation and remove all
 * dependent nodes from the graph of recomputation.
 */

if (dynamics_in_progress)
 recompute = 0;

 EMmake_chanselect(NDchildren_children, &children);

if (recompute)
{
/*
 * Get the current module for display purposes.
 */

  if(!(cnt_type&ND_COMP_NO_DISPLAY)
    ||!(cnt_type&ND_COMP_NO_ERASE))
   {
    status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
    if (!(1&status)) goto wrapup;
   }
/*
 * Generate the construct list information
 */
 construct_list.msg = (IGRlong *)EMmsg;
 construct_list.display = &symb.display_attr;
 construct_list.env_info = &recomp_env;
 construct_list.class_attr = NULL;


 status = om$send (msg = message EMSassoc.EMget_construction_info(
                        (IGRlong *)EMmsg,
                        &construct_list),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/* 
 * The new flag in the construct_list should be set to FALSE to prevent
 * the same from creating a new entry in the range tree
 */ 

 status = om$get_classid(objid = my_id,
                         p_classid = &my_classid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 construct_list.newflag = FALSE;

 status = om$construct(classid = my_classid,
                       p_objid = &new_leafid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMget_info(
                         (IGRlong *)EMmsg,NULL,&type,
                         &info_size, NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * Always keep pathway on for intersect element recompute
  */
 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 if ((my_classid == OPP_EMSagrp_class_id) && type==5)
 {
   _pathway_trim = 1;
   _pathway_orient = 1;
 }
 if (info_size > 0)
 {
  info_ptr = (IGRchar *) stackalloc(info_size);
  EMerr_hndlr(!info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 
 }
 else
  info_ptr = NULL;

 status = om$send (msg = message EMSassoc.EMget_info(
                         (IGRlong *)EMmsg, NULL, &type,
                         &info_size, 
                         &info_ptr),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 
 om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                         EMS_OPT_STORE_ID, NULL),
                   p_chanselect = &children);
 store_id = my_id;


 if (!(cnt_type & ND_COMP_NO_ERASE) && !(dont_display))
 {
  dpmode = GRbe;

  status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *)EMmsg, 
               &md_env->md_env.matrix_type, 
               md_env->md_env.matrix, &dpmode,
               &cur_mod), 
         targetid = my_id);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * Recomputation is being done outside the rtree to simplify the
 * the conflicting demands from macro copy/recomputation and 
 * recomputation when a parent is changed. (In EMS today most of
 * the the time when we copy, we do so outside the rtree.)
 * Further, it ensures that we do not mess up the rtree should
 * the recomputation fail.
 * pp 08/10/91
 */
 
 if (type == 255)
 {
   status = om$send (msg = message EMSassoc.EMprocess_function_call(
                           (IGRlong *) EMmsg, cnt_type, count, list,
                           &new_leafid, md_env, info_ptr, info_size,
                           &construct_list),
                     targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (type == EMS_ASattached_to_cs)
 {
   struct GRid my_GRid;
 
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   if (!(cnt_type & ND_COMP_NO_REM_RT) && ((md_env->md_id.objid) != NULL_OBJID))
   {
    cnt_type |= ND_COMP_NO_REM_RT;

    status = om$send (msg = message GRgraphics.GRremwrng(
                                (IGRlong *)EMmsg,md_env),
                           targetid = my_id);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
   }

   if (!(cnt_type & ND_COMP_NO_ERASE) && !dont_display)
   {
    dpmode = GRbe;
    cnt_type |= ND_COMP_NO_ERASE;
    status = om$send(msg = message GRgraphics.GRdisplay(
                (IGRlong *)EMmsg, 
                &md_env->md_env.matrix_type, 
                md_env->md_env.matrix, &dpmode,
                &cur_mod), 
            targetid = my_id);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
/*
 * This function shall transform me with respect to the coordinate system
 * and then return the new cs matrix which I store in my instance data.
 * pp 01/11/91
 */

   EFtransform_with_respect_to_cs((IGRlong *)EMmsg, NULL,&my_GRid, info_ptr,
                                  construct_list.env_info,
                                   count, 
                                  (IGRchar *) list);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   new_leafid = my_id;

   status = om$send (msg = message EMSassoc.EMput_info((IGRlong *)EMmsg,NULL,
                           EMS_ASattached_to_cs,sizeof (IGRmatrix), info_ptr),
                     targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (!(cnt_type & ND_COMP_NO_ADD_RT) && ((md_env->md_id.objid) != NULL_OBJID))
   {
    status = om$send (msg = message GRgraphics.GRaddwrng(
                              (IGRlong *)EMmsg,md_env),
                           targetid = new_leafid);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
    cnt_type |= ND_COMP_NO_ADD_RT;
   }
/* end pp */
 }
 else
 {
  current_creator = new_leafid; 

  status = om$send (msg = message EMSassoc.EMconstruct_associative(
                         (IGRlong *)EMmsg,
                         EMSasconst_recompute,my_id, count, 
                         (IGRchar *)list, type,
                         info_ptr, &construct_list),
                   targetid = new_leafid);
  current_creator = NULL_OBJID; 
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * Just make sure that IS_ASSOCIATIVE bit and EXTERNAL_CONSTRAINT bit
 * is set at the very least.
 * pp 09/27/91
 */
 if (new_leafid != my_id)
 {
   new_graphics_props = graphics_props & (GRIS_ASSOCIATIVE |
                                          GRHAS_EXTERNAL_CONSTRAINT |
                                          GRIS_POST220_OBJECT);
/*
 * AIC 06/08/93
 * Added GRIS_POST220_OBJECT and simplified code.
    if (graphics_props & GRIS_ASSOCIATIVE)
     new_graphics_props |= GRIS_ASSOCIATIVE;
    if (graphics_props & GRHAS_EXTERNAL_CONSTRAINT)
     new_graphics_props |= GRHAS_EXTERNAL_CONSTRAINT;
 */
  action = 1;
  status = om$send (msg = message GRgraphics.GRchgprops(
                          (IGRlong *)EMmsg, &action,
                          &new_graphics_props),
                    targetid = new_leafid);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * If we have been asked to not remove ourselves from the rtree, then we
 * try to respect the same.
 * pp 08/10/91
 */

  if (!(cnt_type & ND_COMP_NO_REM_RT) && ((md_env->md_id.objid) != NULL_OBJID))
  {
   status = om$send (msg = message GRgraphics.GRremwrng(
                               (IGRlong *)EMmsg,md_env),
                           targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
  }

 if (!(cnt_type & ND_COMP_NO_ADD_RT) && ((md_env->md_id.objid) != NULL_OBJID))
 {
  status = om$send (msg = message GRgraphics.GRaddwrng(
                              (IGRlong *)EMmsg,md_env),
                          targetid = new_leafid);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
 }


 if (!(cnt_type & ND_COMP_NO_DISPLAY) && !dont_display)
 {
  dpmode = GRbd;
  status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *)EMmsg, 
                 &md_env->md_env.matrix_type, 
                 md_env->md_env.matrix, &dpmode,
                 &cur_mod), 
           targetid = new_leafid);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

 /*
  * calling notify listeners before calling EMastore so that my_id's tag
  * version counter is incremented before the tag is moved to the new object
  * (which happens in EMastore)
  */

 GR_NOTIFY_LISTENERS(EMmsg, &status, GR_GEOM_MODIFIED);

/*
 * Kludge. This has to be done since the object id of a node in the
 * dependency graph is changing. This would not be necessary once
 * we have the capability to return the new id via the argument list.
 * pp (03/07/91)
 */ 

 /* 
  * If construction was successful, send EMstore message to the newobjectid
  * giving it my id as an argument. 
  */

 if (new_leafid != my_id)
  {
   IGRlong loc_msg;

    status = om$send (msg = message EMSassoc.EMastore(
                         (IGRlong *)EMmsg, NULL,&recomp_env,
                         new_leafid),
                   targetid = my_id);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    store_id = new_leafid;
    new_objid->objid = new_leafid;
    new_objid->osnum = OM_Gw_current_OS;
/*
 * Delete the old object. More properly store the object for recovery
 * purposes. (BUT delete for now.)
 */
     om$send (msg = message GRgraphics.GRdelete(&loc_msg, &recomp_env),
                    targetid = my_id);
  }

/*
 * If context is coming in then transfer symbology based on the context.
 * This usually happens during recomputation of an entity in a const
 * macro.
 * pp 07/28/92
 */

   if (context->objid != NULL_OBJID)
   {
    struct GRid new_GRid;

    if (new_leafid != my_id)
     new_GRid.objid = new_leafid;
    else
     new_GRid.objid = my_id;

    new_GRid.osnum = OM_Gw_current_OS;

  
    ACtrans_symb(*context, new_GRid);
   }
 }

wrapup:

 if (store_id != NULL_OBJID)
 {

  /* If I am a EMSasectvw and I have that peculiar combination of recreation
   * after deletion, then get the new compcurve(s) and update the pointer(s).
   * - Satish, SpB
   * The logic here is that for every compcurve created, there is one 
   * EMSpointer created. Therefore, the pointers are updated after recompute
   * with the new compcurves because during recreation of the solid, the 
   * indices of the compcurves get changed, resulting in a topology mismatch
   * when the EMSpointers are queried. CR Section View enh.
   *
   * BEGIN FIX FOR TOPOLOGY MISMATCH
   */
   
   struct GRmd_env           module_env;
   IGRuint                   info_size,type;
   struct EMS_ASsectvw_info  *sect_view_info = NULL;
    
   status = om$send(msg = message EMSassoc.EMget_info(&msg_loc, NULL,
                                                   &type, &info_size,
                                                   NULL),
                                       targetid = store_id,
                                       targetos = OM_Gw_current_OS);

   sect_view_info = (struct EMS_ASsectvw_info *)alloca(info_size);

   status = om$send(msg = message EMSassoc.EMget_info(&msg_loc,                                                     NULL, &type,
                                    &info_size,
                                    (IGRchar **) &sect_view_info),
                                    targetid = store_id,
                                    targetos = OM_Gw_current_OS);

   if (!(sect_view_info->view_info.flags & SV_SHOW_VISIBLE_LINES))
   {
    if (sect_view_info->view_info.flags & SV_RECREATE_SOLID)
    { 
      OMuword classid;

      status = om$get_classid(osnum = OM_Gw_current_OS,
                             objid = store_id,
                             p_classid = &classid);

      if (classid == OPP_EMSasectvw_class_id)
	  {
		OM_S_CHANSELECT to_child, to_comp;
		OMuint num_child, num_comp;
		OM_S_OBJECT_LINKAGE *c_ids, *co_ids;
		IGRshort mat_type;
		IGRmatrix matrix;
		int i,j,last;
		

		/** Get All children **/
		status=om$make_chanselect(channame="NDchildren.children",
								  p_chanselect = &to_child);

		status = om$get_channel_count(osnum=OM_Gw_current_OS,
									  objid =store_id,
									  p_chanselect = &to_child,
									  count = &num_child);

		c_ids = (OM_S_OBJECT_LINKAGE *)alloca (num_child *
											  sizeof(OM_S_OBJECT_LINKAGE));
		status = om$get_channel_objects(objid = store_id,
										osnum = OM_Gw_current_OS,
										p_chanselect = &to_child,
										list = c_ids,
										size = num_child,
										count = &num_child);

		/** Get All components **/
		status=om$make_chanselect(channame="GRcmpowner.to_components",
								  p_chanselect = &to_comp);

		status = om$get_channel_count(osnum=OM_Gw_current_OS,
									  objid =store_id,
									  p_chanselect = &to_comp,
									  count = &num_comp);

		co_ids = (OM_S_OBJECT_LINKAGE *)alloca (num_comp *
											  sizeof(OM_S_OBJECT_LINKAGE));
		status = om$get_channel_objects(objid = store_id,
										osnum = OM_Gw_current_OS,
										p_chanselect = &to_comp,
										list = co_ids,
										size = num_comp,
										count = &num_comp);

		for(i=0;i<num_child;i++)
		{
		   last = 0;
		   status = om$get_classid(osnum = c_ids[i].osnum,
								   objid = c_ids[i].S_objid,
								   p_classid = &classid);

		   if (classid == OPP_EMSpointer_class_id)
		   {
			 for(j=last;j<num_comp;j++)
			 {
				status = om$get_classid(osnum = co_ids[i].osnum,
								   objid = co_ids[i].S_objid,
								   p_classid = &classid);
				if (classid == OPP_GRcompcurve_class_id)
				{
					om$send(msg = message EMSpointer.EMstore_id(&msg_loc,
															NULL,
															co_ids[i].S_objid),
							targetid = c_ids[i].S_objid,
							targetos = c_ids[i].osnum);
					om$send (msg = message EMSpointerA.EMstore_key_from_id(
																   &msg_loc,
													EMS_OPT_STORE_ID, NULL),
							 senderid = store_id,
							 targetid = c_ids[i].S_objid,
							 targetos = c_ids[i].osnum);
					last = j + 1;
					break;
				}
			 }
		   }
		}
	  }
    }
  } 
  /* END FIX FOR TOPOLOGY MISMATCH */

   om$send (msg = message EMSpointerA.EMstore_id_from_key (&msg_loc,
                          NULL, NULL),
                    senderid = store_id,
                    p_chanselect = &children);
 }
/*
 * Set the return codes correctly for the graph.
 * pp 07/12/91
 */

 if (1&status&*EMmsg)
 {
  *EMmsg = ND_COMP_SUCC;
  if (new_leafid != NULL_OBJID)
   om$send (msg = message EMSassoc.EMcompute_postprocess(),
           targetid = new_leafid); 
 }
 else
 {
  int child_count = 0;
  OM_S_CHANSELECT children;

  EMmake_chanselect(NDchildren_children, &children);

  om$get_channel_count(p_chanselect = &children,
                       objid = my_id,
                       count = (OMuint *)&child_count);
  if (!child_count)
  {
   *EMmsg = ND_COMP_SUCC;
   status = OM_S_SUCCESS;
  }
  else
   *EMmsg = ND_COMP_FAIL;
 }

 if (info_ptr) stackfree(info_ptr);
 WANT_POST220_BEHAVIOR = SAVE_POST220_BEHAVIOR;  /* AIC 06/08/93 */
 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;
 return (status);
}


end implementation EMSassoc;
