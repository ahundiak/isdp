/*
History
        SM      01-Jul-90       Creation.
        SM      27-Nov-90       Use NDgraph (global) to determine external 
                                tirgger. The update_list passed (which
                                was being used before) is the batch and hence
                                contains only the roots. NDgraph however
                                contains the entire graph of dependents.
                                For now I am using the global NDgraph untill
                                EXNUC provides some other interface.
        DLB     11/28/90        Send EMunevalute instead of EMreplace and
                                always kick off EMevaluateOps.
        DLB     01/23/91        EMunevaluate with DONT_REDRAW.
        DLB     01/24/91        Removed display_ids from EMevaluateOps message.
        DLB     03/07/91        Only need to check UNEVAL bit to decide if
                                internal or external trigger - so I ripped out
                                all the graph checking stuff.
        DLB     03/15/91        Added internal/external trigger code in 1.4.
                                ND environment.
        DLB     03/22/91        See if I'm already uneval'd before looking
                                at external parents (efficiency check only).
        DLB     04/30/91        Get recomp info and pass to evalops.
        Tapadia 05/14/91        Check for macro state added.
        DLB     05/16/91        Send EMstore_key_from_id to children.
        pp      06/11/91        Crystallized the pointer functionality into
                                a seperate class.
        pp      06/15/91        Enhanced the determination of external 
                                trigger.
        DLB     07/08/91        Set current_creator before evalops.
        PP      07/12/91        Changed NDcompute_node to NDupdate and 
                                initalised return codes for the graph.
        DLB     07/15/91        Add DELETE_SSI option to uneval.
        DLB     07/29/91        Removed check for MACRO bit.
        pp      08/10/91        Supporting ND_COMP_NO_ADD_RT and
                                ND_COMP_NO_REM_RT
        PP      08/19/91        Calling the macro to notify dependents after 
                                this element recomputes.
 	Tapadia 07/14/92 	Added support for converting curcular holes
				2.0 holes into 2.1. This involved adding a 
				vector object to all 2.0 files as the vector 
				object was not being explicitly stored for 
				axis_normal holes.
				
        DLB     12/11/92        Check for ND_COMP_FAIL returned from evalops.
        AIC	06/08/93	Error out if GRgetprops fails.
        NP      08/17/93        Further to Tapadia's comments on 7/14/92, check
                                only "EMSslboolfea" classes and NOT the new 
                                feature classes "EMSs[f/l]feature" that are 
                                subclassed off of "EMSs[f/l]boolfea".
        WBC     12/16/93        Need to check at the end of the method and
                                make sure the display_ids have been posted if
                                they have changed.
        Sanjay  08/03/95        I don't know when will we do "RIGHT THINGS 
                                RIGHT"?. First : The Add/Remove material state
                                created does not have the "post310" bit set.
                                Second : Add/Remove material feature is only
                                created in post 310. So don't check for this
                                bit. Third : Removed the call to "EMget_dpr_
                                props", which is a ridiculous one.
*/

class implementation EMSsfdpr;

#include "emserr.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "gocmacros.h"
#include "EMSkey.h"
#include "EMSasfeatdef.h"

from EMSdprparam import EMget_display_ids, EMput_display_ids;
extern OMuword OPP_EMSslboolfea_class_id;
extern OMuword OPP_EMSsffeature_class_id;
extern OMuword OPP_EMSsfboolean_class_id;
extern OMuword OPP_EMSslboolean_class_id;
extern OMuword OPP_EMSslfeature_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;
extern short _Pathway, _pathway_trim, _pathway_orient;


method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid; struct GRmd_env *md_env)
{
  unsigned  short   evalop_options=0;
  OMuint	    children_count=0;
  IGRint            loc_display_count=0;
  IGRlong           status,OM_stat=OM_S_SUCCESS;
  GRobjid           *loc_display_ids=NULL, param_id;
  OM_S_CHANSELECT   to_children;
  IGRboolean        send_store_id=FALSE, evalops_comp_failed=FALSE;
  struct GRid       *local_list=NULL;
  IGRboolean        SAVE_POST220_BEHAVIOR=FALSE, update_display_ids = FALSE;
  IGRshort          grprops = NULL;
  IGRboolean        post_310_object=FALSE;
  OMuword           my_class_id;
  IGRboolean aflag, reset_env = FALSE;
  struct GRmd_env orig_env;

  extern IGRboolean dynamics_in_progress;
  extern IGRboolean EFgot_an_external_trigger();
  extern IGRlong EFadd_vector();

  aflag = pwIsActivationOn();
  if (aflag)
  {
    orig_env = *md_env;
    pwGetActiveModuleEnv(md_env);
    reset_env = TRUE;
  }

  *EMmsg = EMS_S_Success;
  SAVE_POST220_BEHAVIOR = WANT_POST220_BEHAVIOR;

  /*
   * If the object is a post 310 object and Pathway is enabled open up
   * the pathway trimming and orientation.
   */

  post_310_object = (ME.EMSdpr->dpr_props & EMS_POST310_OBJECT) ? TRUE : FALSE;
  if (post_310_object && _Pathway)
  {
    _pathway_trim = 1;
    _pathway_orient = 1;
  }

  OM_stat = om$send(msg =message GRgraphics.GRgetprops((IGRlong *)EMmsg,
                        &grprops),
                    targetid = my_id);
  if(! (1 & OM_stat & *EMmsg)) goto wrapup;

  if(grprops & GRIS_POST220_OBJECT)
    WANT_POST220_BEHAVIOR = TRUE;
  else
    WANT_POST220_BEHAVIOR = FALSE;

  local_list = list;
  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;

  if (dynamics_in_progress) goto wrapup;

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    if (EFgot_an_external_trigger(EMmsg, my_id, OM_Gw_current_OS, 
				  ME.EMSdpr->dpr_props))
    {
      GRobjid ownerid;
 
      /*
       * Get the display_ids array 
       */
      OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                       (IGRlong *)EMmsg, &loc_display_count,
                                       &loc_display_ids, NULL), 
                                my_id, OM_Gw_current_OS, &param_id, NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            
 
      update_display_ids = TRUE;

      OM_stat = om$send(msg = message EMSsurface.EMunevaluate((IGRlong *)EMmsg,
                              EMuneval_DO_DISPLAY | 
                              EMuneval_DONT_REDRAW |
                              EMuneval_IMMEDIATE_OPER |
                              EMuneval_DELETE_SSI, 
                              md_env, &loc_display_ids, &loc_display_count,
                              &ownerid, NULL_OBJID, NULL),
                    targetid = my_id); 
      if(!(1&*EMmsg&OM_stat)) goto wrapup;
   
      if (loc_display_count)
      {
        OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(
                                (IGRlong *)EMmsg,
                                loc_display_count, loc_display_ids, NULL),
                          targetid = param_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                 
   
        loc_display_ids = NULL;
        loc_display_count = 0;
        update_display_ids = FALSE;
      }
    }
    else if (!(1 & *EMmsg)) goto wrapup;
  }
 
  EMmake_chanselect(NDchildren_children, &to_children);

  status = om$get_channel_count(p_chanselect = &to_children,
                                objid = my_id,
                                count = &children_count);
  if (!(1&status)) goto wrapup;

  if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
  {
    IGRlong l_msg,ii;
    for (ii=0;ii<children_count;ii++)
    {
      om$send (msg = message EMSpointerA.EMstore_key_from_id(&l_msg,
                    EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &to_children,
                    from = ii,
                    to = ii);
    }
    send_store_id = TRUE;
  }                                                      

  /********* Tapadia - start *********/

  { 
    /*
     * INTENTIONAL BLOCK
     */

    IGRuint type=0, info_size=0;
    IGRchar *info_ptr=NULL;

    /*
     * get the associativity information. (basically the recompute type and
     * it's size)
     */
    OM_stat = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg, NULL,
                                    &type, &info_size, NULL),
                      targetid = my_id);
    if(!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*
     * get the classid of the object.
     */
    status = om$get_classid (objid= my_id,
                             p_classid = &my_class_id);
    EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    if(info_size) 
    {
      info_ptr = (IGRchar *) stackalloc(info_size);
      if (!info_ptr) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

      OM_stat = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg, NULL,
                              &type, &info_size, &info_ptr),
                        targetid = my_id);
      if(!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    /* Catch only the original solid "hole" class (EMslboolfea) as originally 
     * intended and NOT any of the new feature classes, that are subclassed off
     * of EMSs[f/l]boolfea. This is because, the assoc types between the two 
     * classes are not distinct, i.e. there are common numbers, which will 
     * cause a screw up below. (NP 8/17/93)
     */
    if ( EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
	                   OPP_EMSslboolfea_class_id, FALSE) &&
        !EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                           OPP_EMSsffeature_class_id, FALSE))
    {
	struct GRid *new_list=NULL;

	new_list = (struct GRid *) stackalloc(sizeof(struct GRid) * 
			count + 1);

	/* If the 2.0 hole is not a profile hole then change it */
	if(type == EMS_ASCIR_THRU_ALL_HOLE_TYPE ||
		type == EMS_ASCIR_THRU_NEXT_HOLE_TYPE ||
		type == EMS_ASCIR_THRU_UNTIL_HOLE_TYPE ||
		type == EMS_ASCIR_FINITE_FLAT_HOLE_TYPE ||
		type == EMS_ASCIR_FINITE_V_HOLE_TYPE) {

		struct EMSplace_hole *plhole_info=NULL;
		IGRint new_type=0, hl_count=0;
		IGRboolean axis_normal=FALSE;

		plhole_info = (struct EMSplace_hole *)info_ptr;
		hl_count = plhole_info->hole_count;
		axis_normal = plhole_info->axis_normal;

    		if (info_ptr) stackfree(info_ptr);

		/* replace the existing type with new type */
		if(type == EMS_ASCIR_THRU_ALL_HOLE_TYPE)
			new_type = EMS_ASCIR_THRU_ALL_HOLE_TYPE_1;
		else if(type == EMS_ASCIR_THRU_NEXT_HOLE_TYPE)
			new_type = EMS_ASCIR_THRU_NEXT_HOLE_TYPE_1;
		else if(type == EMS_ASCIR_THRU_UNTIL_HOLE_TYPE)
			new_type = EMS_ASCIR_THRU_UNTIL_HOLE_TYPE_1;
		else if(type == EMS_ASCIR_FINITE_FLAT_HOLE_TYPE)
			new_type = EMS_ASCIR_FINITE_FLAT_HOLE_TYPE_1;
		else if(type == EMS_ASCIR_FINITE_V_HOLE_TYPE)
			new_type = EMS_ASCIR_FINITE_V_HOLE_TYPE_1;

		if(axis_normal) { /* add a parent (vector) */
			OM_stat = EFadd_vector(EMmsg, new_type, 
				(char *)local_list, count, hl_count, new_list, 
				my_id, md_env);

			EMerr_hndlr(!(1 & OM_stat), *EMmsg, EMS_E_Fail, wrapup);

			/* Increased the parent count & list as a new object
			(vector) is added */
			local_list = new_list;
			count++;
		}
		/* Replacing the new type with the old one */
		OM_stat = om$send(msg = message EMSassoc.EMput_info(
		                (IGRlong *)EMmsg, 
				NULL, new_type, info_size, NULL),
			targetid = my_id);
			
      		if (!(1 & OM_stat & *EMmsg)) goto wrapup;
	}
     }
  }

  /********* Tapadia - end *********/

  { 
    /*
     * INTENTIONAL BLOCK
     */
    IGRuint           type=0, info_size=0;
    IGRchar           *info_ptr=NULL;
    extern OM_S_OBJID current_creator;

    OM_stat = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg, NULL,
                                    &type, &info_size, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
    if (info_size)
    {
      info_ptr = (IGRchar *) stackalloc(info_size);
      if (!info_ptr) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

      OM_stat = om$send(msg = message EMSassoc.EMget_info((IGRlong *)EMmsg, NULL,
                              &type, &info_size, &info_ptr),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

   /* No matter what happens, always issue an EMevaluateOps message. */

   /*
    * Added the support for adding and removing from rtree so that
    * associativity would work. This has to be done in the said
    * manner to meet conflicting demands from recomputation in macros
    * vs recomputation when a parameter is changed. This was erstwhile
    * being handled by first recomputing out of the rtree and then
    * adding range.
    * pp 08/10/91
    */
    evalop_options =  EMeval_op_DO_DISPLAY;

    if (cnt_type & ND_COMP_NO_ADD_RT)
      evalop_options |= EMeval_op_NO_ADD_TO_RT;

    if (cnt_type & ND_COMP_NO_REM_RT)
      evalop_options |= EMeval_op_NO_REMOVE_FROM_RT;

    /* end pp */

    current_creator = my_id;
    OM_stat = om$send(msg = message EMSdpr.EMevaluateOps((IGRlong *)EMmsg,
                            evalop_options, md_env, count, local_list,
                            type, info_ptr),
                      targetid = my_id);
    current_creator = NULL_OBJID;

    if (*EMmsg == ND_COMP_FAIL) evalops_comp_failed = TRUE;

    if (info_ptr) stackfree(info_ptr);
  }

  if (post_310_object)
  {
    /*
     * It is a post 310 object, so set corresponding bit in dpr properties
     * as this bit will be erased by the previous operation.
     */

    IGRboolean action=TRUE;
    IGRushort mask = EMS_POST310_OBJECT;

    status = om$send (msg = message EMSdpr.EMsetprops ((IGRlong *)EMmsg,
                                    &action, &mask),
                                    targetid = my_id);
    if (!(1&status&(*EMmsg))) goto wrapup;
  }
 
  if (send_store_id)
  {
    IGRlong loc_msg=EMS_S_Success, loc_stat=OM_S_SUCCESS, ii=0;

    /*
     * calling notify listeners so that my_id's tag is incremented and
     * listeners are notified.
     * pp 08/19/91
     */

    GR_NOTIFY_LISTENERS(&loc_msg, &loc_stat, GR_GEOM_MODIFIED);
    for ( ii=0;ii<children_count;ii++)
    {
        om$send(msg = message EMSpointerA.EMstore_id_from_key(&loc_msg, NULL, NULL),
                    p_chanselect = &to_children,
                    from = ii,
                    to = ii);
    }

    /*  
     * After a boolean operation the solid should get the symbology from
     * definition unless the current symbology is asked for. Fix for TR# 
     * 119312196. 
     */
    if(context->objid != NULL_OBJID)
    {
      struct GRid my_grid;
      
      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      ACtrans_symb(*context,my_grid);
    }

  }

wrapup:

  if (aflag && reset_env)
  {
    *md_env = orig_env;
  }

 /* 
  * post the display_ids to the param object in case an error occurred
  * before the ids were posted in the "normal" flow of the code
  */

 if (update_display_ids && loc_display_count)
 {
   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(
                                                 (IGRlong *)EMmsg,
                                                 loc_display_count,
                                                 loc_display_ids, NULL),
                    targetid = param_id);
 }

 /*
  * Set the return codes correctly for the graph.
  * pp 07/12/91
  */

 if ((1&OM_stat&*EMmsg) && !evalops_comp_failed)
   *EMmsg = ND_COMP_SUCC;
 else
   *EMmsg = ND_COMP_FAIL;

 WANT_POST220_BEHAVIOR = SAVE_POST220_BEHAVIOR;

 /*
  * Reset pathway trimming and orientation flags.
  */

  if (post_310_object && _Pathway)
  {
    _pathway_trim = 0;
    _pathway_orient = 0;
  }

  return(OM_stat);
}

IGRboolean EFgot_an_external_trigger(EMmsg, objid, osnum, dpr_props)
IGRlong     *EMmsg;
GRobjid     objid;
OMuword     osnum;
IGRushort   dpr_props;

/**************************************************************************
  There are two ways a dpr node can get an update message -
  1) Some node below this node in the tree got modified. - Internal trigger.
  2) A parameter on which this node is directly dependent (like CHT) got
     modified - External trigger.
 
  In case of an internal trigger, the unevaluation of all affected nodes has
  already taken place. What remains to be done during update is that 
  each node issue a EMevaluateOps action as NDcompute_node proceeds up the
  tree.  

  In case of the external trigger, the unevaluation has not taken place yet, 
  so this node will unevaluate itself.
 
  In case of both internal and external triggers, the behavior is same as
  for external trigger.
***************************************************************************/
{  
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          count, parent_type, ii;
  OM_S_CHANSELECT to_comps, to_father;
  struct GRid     father_GRid;
  

  *EMmsg = EMS_S_Success;

  EMmake_chanselect(NDfather_father, &to_father);
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*O.K. loop thru each parent, screening out parents that are also
   * components.  For each screened parent, get its type.  If its type is
   * NOT ND_EXTERN that its an external trigger.
   */

  OM_stat = om$get_channel_count(objid = objid,
                                 osnum = osnum,
                                 p_chanselect = &to_father,
                                 count = (OMuint *)&count);
  if (!(1 & OM_stat)) goto wrapup;                                   

  for(ii=0; ii<count; ii++)
  {
    OM_stat = om$get_objid_at_index(objid = objid,
                                    osnum = osnum,
                                    p_chanselect = &to_father,
                                    index = ii,
                                    objidaddr = &father_GRid.objid,
                                    osnumaddr = &father_GRid.osnum);
    if (!(1 & OM_stat)) goto wrapup;
/*
 * Removed the screening of parents that are also components, since they
 * are not going to be connected on the to_father channel.
 * pp 05/04/91 
 */

/*
    OM_stat = om$is_objid_on_channel(objid_c = objid,
                                     osnum_c = osnum,
                                     p_chanselect = &to_comps,
                                     objid = father_GRid.objid);
    if (OM_stat == OM_W_NOTONCHAN)
*/
    {
      /*External parent. Did it cause the trigger?*/
      OM_stat = OM_S_SUCCESS;
      nd$get_type(p_object = &father_GRid,
                  p_type = &parent_type,
                  nb_obj = 1);
      if (parent_type == 0) 
        {
          struct GRid obj_GRid;
          IGRint obj_type;
         /*
          * Check to see if I have been put on the batch. If so
          * perform an emulation as if this is an external
          * trigger.
          * pp 06/15/91
          */

          obj_GRid.objid = objid;
          obj_GRid.osnum = osnum;

          nd$get_type(p_object = &obj_GRid,
                      p_type = &obj_type,
                      nb_obj = 1);
          if (obj_type & ND_ROOT)
           return (TRUE);
	  /* Pattern feature , parent would not have entered compute graph */
          else if(dpr_props & EMS_PATTERN_FEATURE)
	    return(TRUE);
	  else
          {
            *EMmsg = EMS_E_InvalidCase;
            goto wrapup;
          }
        }
      else if (!(parent_type & ND_EXTERN))
      {
        return(TRUE);
      }
    }
  }                                      

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFget_an_external_trigger")
  return(FALSE);
}
end implementation EMSsfdpr;
