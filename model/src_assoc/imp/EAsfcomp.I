/**********

NOTE, NOTE, NOTE:

DO NOT ACCESS ANY INSTANCE DATA DIRECTLY IN THIS METHOD!!!! THE CLASS OF
OBJECT MAY CHANGE DURING 'EMconstruct_associative'. THE ONLY WAY TO ACCESS
INSTANCE DATA IN SUCH A CASE IS TO SEND A MESSAGE. FOR e.g DO NOT USE
ME.GRgraphics->properties DIRECTLY. INSTEAD SEND GRchgprops MESSAGE.

	SM	04-Jun-92
	AIC	08-Jun-93	Error out if GRgetprops fails.
*************/
class implementation EMAsurface;

#define DEBUG 0
#define RECOMP_BUFF_SIZE 20


#include "EMSopt.h" /* FOR dpr options */
#include "nddef.h"
#include <stdio.h>
#include "EMSdpr.h"
#include "graph.h"
#include "EMSasopts.h" /*  For EMSasconst_recompute */
#include "gocmacros.h"
#include "exmacros.h"
#include "EMSkey.h"
#include "EMSssprops.h"
#include "OMmacros.h"
#include "REswcompsf.h"
#include "REgencompsf.h"
#include "REsfsolid.h"
#include "REgensolid.h"
#include "REpolyhdrn.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "EMSasfeatdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern  struct graph ND_graph;          /* Global graph for the system       */

from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSsubbs    import EMget_props;
from GAcurve import GAget_msc_component;

extern OMuword OPP_EMSswcompsf_class_id, OPP_EMSsfsolid_class_id, 
               OPP_EMSgencompsf_class_id, OPP_EMSgensolid_class_id, 
               OPP_EMSwedge_class_id, OPP_EMSsfboolean_class_id,
               OPP_EMSslboolean_class_id, OPP_EMSslfeature_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;

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
associative surface/solid constructions.

History
 Sanjay:10/04/94  : For an object which is not constructed fully, we should 
                    use Root.delete() rather than GRgraphics.GRdelete(). So 
                    changed the GRgraphics.GRdelete call to Root.delete().  
 WBC:   12/16/93  : Need to check at the end of the method and
                    make sure the display_ids have been posted if
                    they have changed.
 PP :   03/24/93  : Removed the conversion of surfaces to planes as the
                    code was not getting invoked.
 DLB:   03/13/92  : Detemine if I am active by seeing if im owned by a dpr
                        NOT if I am active wrt. the dpr.
 DLB:   03/03/92  : Handle breaks in the graph due to dpr ops removing surfs.
 DLB:   02/08/92  : Ignore return codes when deleting me.
 PP :   01/19/92  : Added support for being able to attach non-associative
                    solids to a coordinate system.
 PP :   09/28/91  : Making sure that at the very least IS_ASSOCIATIVE
                    and HAS_EXTERNAL_CONSTRAINT bit gets set if the
                    old guy had it.
 PP :   08/19/91  : Calling the macro to notify dependents after this
                    element recomputes..
 PP :   08/10/91  : Added support of ND_COMP_NO_ADD_RT and
                    ND_COMP_NO_REM_RT and removed obsolete comments.
 DLB:   07/15/91  : Add DELETE_SSI option to uneval.
 PP :   07/12/91  : Changed NDcompute_node to NDupdate and initalised
                    return codes for the graph
 PP :   06/11/91  : Crystallized the pointer functionality into
                    a seperate class.
 PP :   06/08/91  : Code modification to delete the new object if a failure
                    occurs and send store id from key message at the end.
 DLB:   03/05/91  : Use stackalloc
 DLB:   03/04/91  : Uneval, repl, match
 PP :   07/31/88  : Creation date

   ************************************************************************* */
{
 IGRboolean aflag, reset_env=FALSE;
 IGRshort action;
 IGRlong status, i;
 OMuint  children_count;
 OM_S_CHANSELECT to_owners;
 struct GRid *comp_ids=NULL;
 struct GRsymbology symb;
 struct IGResbs element_specific;
 struct GRvg_construct construct_list;
 extern IGRboolean dynamics_in_progress;
 enum GRdpmode  dpmode;
 IGRboolean recompute = TRUE, active_state=TRUE;
 IGRuint info_size = 0;
 IGRshort graphics_props = NULL, new_graphics_props;
 IGRchar *info_ptr=NULL;
 IGRuint type;
 IGRint  display_count=0;
 OMuword my_class_id;
 OM_S_OBJID new_leafid=NULL_OBJID;
 OM_S_CHANSELECT children;
 OM_S_OBJID store_id = NULL_OBJID;
 struct GRmd_env recomp_env, orig_env, display_env;
 struct GRid cur_mod;
 extern OM_S_OBJID current_creator;
 IGRboolean SAVE_POST220_BEHAVIOR,
            update_display_ids = FALSE;
 GRobjid *display_ids=NULL, param_id;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 SAVE_POST220_BEHAVIOR = WANT_POST220_BEHAVIOR;

 gr$get_module_env(buffer = &display_env);
 aflag = pwIsActivationOn();
 if(aflag)
 {
   orig_env = *md_env;
   pwGetActiveModuleEnv(md_env);
   reset_env = TRUE;
 }

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

/*
 * I am in dynamics else do not recompute to prevent locking up the terminal.
 */

/* Need to have the capability to remove nodes from the graph manager
 * Hence if dynamics in progress prevent recomputation and remove all
 * dependent nodes from the graph of recomputation.
 */

 if (dynamics_in_progress)
  recompute = 0;


 if (recompute)
 {
  GRobjid owner_id, nodes_owner_id=NULL_OBJID;
  extern OMuword OPP_EMAsubbs_class_id;

/*
 * Get the current module for display purposes.
 */

  if(!(cnt_type&ND_COMP_NO_DISPLAY)
    ||!(cnt_type&ND_COMP_NO_ERASE))
   {
    status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
    if (!(1&status)) goto wrapup;
   }
 
  status = EMmake_chanselect(GRconnector_to_owners, &to_owners);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  {/*INTENTIONAL - DLB 3/13/92*/
    OMuint      o_count;
    GRobjid     dprid;
    OMuword     dumos;
    extern OMuword OPP_EMSdpr_class_id;
    

    /*Determine if I am owned by a DPR.  If so, need to unevaluate me.*/
    status = om$get_channel_count(object = me,
                                  p_chanselect = &to_owners,
                                  count = &o_count);
    if (!(1 & status)) goto wrapup;

    if (o_count)
    {
      status = om$get_objid_at_index(object = me,
                                     p_chanselect = &to_owners,
                                     index = 0, /*DPR IS RIGID*/
                                     objidaddr = &dprid,
                                     osnumaddr = &dumos);
      if (!(1 & status)) goto wrapup;                                     

      if (EFisAncestryValid(EMmsg, dprid, dumos, OPP_EMSdpr_class_id, FALSE))
        active_state = FALSE; /*have an owner and its a dpr*/
    }
  }/*INTENTIONAL - DLB 3/13/92*/

  if (active_state && EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                                        OPP_EMAsubbs_class_id, FALSE))
  {
    /*Do secondary check to see if I have been removed from a dpr tree*/
    IGRuchar ssprops;

    status = om$send(msg = message EMSsubbs.EMget_props((IGRlong *)EMmsg, 
                           &ssprops),
                     targetid = my_id);
    if (!(1 & *EMmsg & status)) goto wrapup;                         

    if (ssprops & EMSIS_INACTIVE)
    {
      /*Very touchy situation here.  A dpr operation (boolean or lift face)
       * has removed me from the tree.  I cant recompute yet because I will
       * hose up the dpr ssi information.  I also cant unevaluate the dpr as
       * I have no path to the dpr.  Code was added at the dpr who removed me
       * to establish a father-child relationship to my owner.  If I'm running
       * in an old design file then I dont have this critical information.
       * If running in a design file generated in version 2.0.0.70 or later
       * then the information DOES exist.  Now how do I unevaluate...
       *
       * Well this isnt as bad as it sounds.  The EMunevaluate message was
       * written with just such a senario in mind.  The nodes_owner_id
       * parameter can be passed my owner id to handle the uneval even though
       * I'm not connected to it at this time.  The only thing left to do is 
       * figure out which dpr on the child channel is the real owner. 
       * 
       * So loop thru the children until a DPR is found.  If no dpr is found
       * then must be a pre version 70 design file.
       */
      OM_S_CHANSELECT to_children;
      OMuint          child_count, ii;
      OMuword         dumosnum;
      extern OMuword  OPP_EMSdpr_class_id;

      EMmake_chanselect(NDchildren_children, &to_children);
      status = om$get_channel_count(object = me,
                                    p_chanselect = &to_children,
                                    count = &child_count);
      if (!(1 & status)) goto wrapup;                                    

      for(ii=0; ii<child_count; ii++)
      {
        status = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_children,
                                       index = ii,
                                       objidaddr = &nodes_owner_id,
                                       osnumaddr = &dumosnum);
        if (!(1 & status)) goto wrapup;                                       

        /*Break on first DPR found.  WHAT IF HAVE MULTIPLE DPR CHILDREN???*/
        if (EFisAncestryValid(EMmsg, nodes_owner_id, OM_Gw_current_OS, 
                              OPP_EMSdpr_class_id, FALSE))
        {
          active_state = FALSE;
          break;
        }
      }
      if (ii == child_count)
      {
        /*Must have been a pre version 70 design file so just quit*/
        *EMmsg = EMS_E_Fail;
        goto wrapup;
      }
    }
  } /* if(active_state && EMAsubbs type) */

  if (!active_state)
  {
    /*
     * First unevaluate me
     */
    IGRushort tmp_options;
  
    ex$message ( msgnumb = EMS_I_UnevalAffecNodes);
  
    status = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                             (IGRlong *) EMmsg, 
                             &display_count, &display_ids, NULL),
                             my_id, OM_Gw_current_OS, &param_id, NULL);
    if (!(1 & status & *EMmsg)) goto wrapup;                         

    update_display_ids = TRUE; 
    tmp_options = EMuneval_DELETE_SSI | EMuneval_DO_DISPLAY |
                  EMuneval_DONT_REDRAW;   

    status = om$send(msg = message EMSsurface.EMunevaluate((IGRlong *) EMmsg,
                           tmp_options, md_env, &display_ids, 
                           &display_count,
                           &owner_id, nodes_owner_id, NULL),
                     targetid = my_id);
    if (!(1 & status & *EMmsg)) goto wrapup;
  
    if (*EMmsg == EMS_I_CantRecompute) goto wrapup;

  } /* if (!active_state) */

  status = om$make_chanselect (channame = "NDchildren.children",
                               p_chanselect = &children);
  if (!(1&status)) goto wrapup;

  status = om$get_channel_count(p_chanselect = &children,
                                objid = my_id,
                                count = &children_count);
  if (!(1&status)) goto wrapup;

  for (i=0;i<children_count;i++)
  {
   IGRlong l_msg;
   om$send (msg = message EMSpointerA.EMstore_key_from_id(&l_msg,
                          EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &children,
                    from = i,
                    to = i);
   store_id = my_id;
  }
 
 /*
  * Generate the construct list information
  */
  
 
  construct_list.msg = (IGRlong *) EMmsg;
  construct_list.display = &symb.display_attr;
  construct_list.env_info = &recomp_env;

  if (cnt_type & ND_COMP_FROM_MACRO)
   construct_list.class_attr = NULL;
  else
   construct_list.class_attr = (char *) &element_specific;
 
  status = om$send (msg = message EMSassoc.EMget_construction_info(
                          (IGRlong *) EMmsg,
                          &construct_list),
                    targetid = my_id);
  if (status == OM_I_STOP_SENDING)
   status = OM_S_SUCCESS;
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
 /* 
  * The new flag in the construct_list should be set to FALSE to prevent
  * the same from creating a new entry in the range tree
  */ 
 
  status = om$get_classid(objid = my_id,
                          p_classid = &my_class_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
  construct_list.newflag = FALSE;
 
  status = om$construct(classid = my_class_id,
                        p_objid = &new_leafid);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
  status = om$send (msg = message EMSassoc.EMget_info((IGRlong *) EMmsg,
                          NULL,&type,
                          &info_size, NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 
  if (info_size > 0)
  {
   info_ptr = (IGRchar *) stackalloc(info_size);
   EMerr_hndlr(!info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 
  }
 
  status = om$send (msg = message EMSassoc.EMget_info((IGRlong *) EMmsg, 
                          NULL, &type,
                          &info_size, 
                          &info_ptr),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

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

    status = om$send (msg = message GRgraphics.GRremwrng((IGRlong *) EMmsg,
                            md_env),
                           targetid = my_id);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
   }

   if (!(cnt_type & ND_COMP_NO_ERASE))
   {
    dpmode = GRbe;
    cnt_type |= ND_COMP_NO_ERASE;
    status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *) EMmsg, 
                aflag? &display_env.md_env.matrix_type:
                &md_env->md_env.matrix_type, 
                aflag? display_env.md_env.matrix:
                md_env->md_env.matrix, &dpmode,
                aflag? &display_env.md_id:
                &cur_mod), 
            targetid = my_id);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
/*
 * This function shall transform me with respect to the coordinate system
 * and then return the new cs matrix which I store in my instance data.
 * pp 01/11/91
 */

   EFtransform_with_respect_to_cs(EMmsg, NULL,&my_GRid, info_ptr,
                                  construct_list.env_info,
                                   count, 
                                  (IGRchar *) list);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   new_leafid = my_id;

   status = om$send (msg = message EMSassoc.EMput_info((IGRlong *) EMmsg,NULL,
                           EMS_ASattached_to_cs,sizeof (IGRmatrix), info_ptr),
                     targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (!(cnt_type & ND_COMP_NO_ADD_RT) && ((md_env->md_id.objid) != NULL_OBJID))
   {
    status = om$send (msg = message GRgraphics.GRaddwrng((IGRlong *) EMmsg,
                                md_env),
                           targetid = new_leafid);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
    cnt_type |= ND_COMP_NO_ADD_RT;
   }
/* end pp */

  }  /* else if (type == EMS_ASattached_to_cs) */
  else
  {
   current_creator = new_leafid;
   status = om$send (msg = message EMSassoc.EMconstruct_associative(
                            (IGRlong *) EMmsg,
                           EMSasconst_recompute, my_id,
                          count, (char *) list, type,
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
  * AIC Added GRIS_POST220_OBJECT and simplified code.
    new_graphics_props = 0;
    if (graphics_props & GRIS_ASSOCIATIVE)
     new_graphics_props |= GRIS_ASSOCIATIVE;
    if (graphics_props & GRHAS_EXTERNAL_CONSTRAINT)
     new_graphics_props |= GRHAS_EXTERNAL_CONSTRAINT; 
  */

  action = 1;
  status = om$send (msg = message GRgraphics.GRchgprops((IGRlong *) EMmsg, 
                          &action,
                          &new_graphics_props),
                    targetid = new_leafid);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 } /* if (new_leafid != my_id) */

/*
 * If we have been asked to not remove ourselves from the rtree, then we
 * try to respect the same.
 * pp 08/10/91
 */

  if (!(cnt_type & ND_COMP_NO_REM_RT) && ((md_env->md_id.objid) != NULL_OBJID))
  {
   status = om$send (msg = message GRgraphics.GRremwrng((IGRlong *)EMmsg,
                                md_env),
                           targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
  }
 
  if (!(cnt_type & ND_COMP_NO_ADD_RT) && ((md_env->md_id.objid) != NULL_OBJID))
  {
   status = om$send (msg = message GRgraphics.GRaddwrng((IGRlong *) EMmsg,
                                md_env),
                           targetid = new_leafid);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
  }
  /*
   *Now erase the remaining old surfs, if any.
   */

  if (!(cnt_type & ND_COMP_NO_ERASE))
  {
    dpmode = GRbe;
    status = om$send(msg = message GRgraphics.GRdisplay((IGRlong *) EMmsg, 
                aflag? &display_env.md_env.matrix_type:
                &md_env->md_env.matrix_type, 
                aflag? display_env.md_env.matrix:
                md_env->md_env.matrix, &dpmode,
                aflag? &display_env.md_id:
                &cur_mod), 
            targetid = my_id);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

 /*
  * calling notify listeners so that my_id's tag is incremented before
  * the tag is moved to the new object..
  * pp 08/19/91
  */

  GR_NOTIFY_LISTENERS(EMmsg, &status, GR_GEOM_MODIFIED);
 
  if (new_leafid != my_id)
  {
   EFsetsfstate(EMmsg, my_id, OM_Gw_current_OS, EMS_O_OFF);
   if (!(1 & *EMmsg)) goto wrapup;
  }
 
 
  /*
   * If construction was successful, replace old with new (and perform uneval).
   * DLB 3/4/91 
   */
 
  if (!active_state)
  {
    GRobjid ownerid;

    if (new_leafid != my_id)
    {
     status = om$send(msg = message EMSsurface.EMreplace((IGRlong *) EMmsg,
                           new_leafid, &recomp_env, 
                           EMreplace_DONT_EVAL,
                           NULL, NULL, &ownerid), 
                     targetid = my_id);
     if (!(1 & *EMmsg & status)) goto wrapup;
    }

    {
      /*Record the new objid's surf ids.*/
      IGRint comp_count=0, ii;     
     
      (void) EFgetcomponents(EMmsg, new_leafid, new_leafid, OM_Gw_current_OS,
                             &comp_count, &comp_ids);
      if (!(1 & *EMmsg)) goto wrapup;                                
 
      for(ii=0; ii<comp_count; ii++)
      {
        EFrealloc_if_needed(EMmsg, &display_ids, display_count, 
                            DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
        if (!(1 & *EMmsg)) goto wrapup;
 
        display_ids[display_count] = comp_ids[ii].objid;
        display_count++;
      }
    }
 
    if (display_count)
    {
      /*Put the display_ids in the param object.*/
      status = om$send(msg = message EMSdprparam.EMput_display_ids(
                             (IGRlong *) EMmsg,
                             display_count, display_ids, NULL),
                       targetid = param_id);
      if (!(1 & status & *EMmsg)) goto wrapup;                         
      display_ids = NULL;   
      update_display_ids = FALSE;
    }

  } /* if (!active_state) */
  else
  {
    /* 
     * If construction was successful, send EMstore message to the newobjectid
     * giving it my id as an argument. If EMreplace was done then this was done
     * there.
     */
    if (new_leafid != my_id)
    {
     status = om$send (msg = message EMSassoc.EMastore((IGRlong *) EMmsg,
                            NULL,&recomp_env, 
                            new_leafid),
                      targetid = my_id);
     EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }
  
    /*No DPR so just redraw the new dude*/
    if (!(cnt_type & ND_COMP_NO_DISPLAY))
    {
     dpmode = GRbd;
     om$send(msg = message GRgraphics.GRdisplay((IGRlong *) EMmsg, 
                aflag? &display_env.md_env.matrix_type:
                &md_env->md_env.matrix_type, 
                aflag? display_env.md_env.matrix:
                md_env->md_env.matrix, &dpmode,
                aflag? &display_env.md_id:
                &cur_mod), 
             targetid = new_leafid);
    }
  }
  
 
   if (new_leafid != my_id)
   {
     new_objid->objid = new_leafid;
     new_objid->osnum = OM_Gw_current_OS;

     store_id = new_leafid;

     /*IF the GRdelete fails then ignore error message.  Otherwise, it
      * will cause the new_leafid to get deleted even though it is o.k.
      */
     om$send (msg = message GRgraphics.GRdelete((IGRlong *) EMmsg,
                    &recomp_env), 
              targetid = my_id);
     *EMmsg = EMS_S_Success;
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

 } /* if(recompute) */

wrapup:

 /* post the display_ids to the param object in case an error occurred
  * before the ids were posted in the "normal" flow of the code
  */

  if (update_display_ids && display_count)
  {
   status = om$send(msg = message EMSdprparam.EMput_display_ids(
                                          (IGRlong *) EMmsg,
                                          display_count, display_ids, NULL),
                    targetid = param_id);
  }

  if (!(1&status&*EMmsg) && (new_leafid != NULL_OBJID))
  {
   IGRlong msg_loc;
/*
 * Delete the new object if a failure occurs.
 */
   om$send (msg = message Root.delete(1),
            targetid = new_leafid);
  }

 if (store_id != NULL_OBJID)
 {
  IGRlong msg_loc;
  for (i=0;i<children_count;i++)
  {
   om$send (msg = message EMSpointerA.EMstore_id_from_key (&msg_loc,
                          NULL, NULL),
                     senderid = store_id,
                    p_chanselect = &children,
                    from = i,
                    to = i);
  }
 }

/*
 * Set the return codes correctly for the graph.
 * pp 07/12/91
 */

 if (1&status&*EMmsg)
  *EMmsg = ND_COMP_SUCC;
 else
  *EMmsg = ND_COMP_FAIL;

 if (info_ptr) stackfree(info_ptr);
 if (comp_ids) om$dealloc(ptr = comp_ids);
 WANT_POST220_BEHAVIOR = SAVE_POST220_BEHAVIOR;

 if(aflag && reset_env)
 {
   *md_env = orig_env;
 }

 return (status);
}
end implementation EMAsurface;
