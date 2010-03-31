class implementation EMSparamgm;

#include "dimdef.h"
#include "dimmacros.h"
#include "dim.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "EC_I.h"
#include "EC_S.h"
#include "EC_M.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define DISP_FACTOR 10

from EMSimpcnstr import EMgeomhandle;

method EMgeomhandle (IGRlong *msg; IGRushort opts;
                     struct GRmd_env *md_env)
{
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_cnstrs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (NDfather_father, &chan_to_cnstrs);
  om$send (msg = message EMSimpcnstr.EMgeomhandle (&msg_loc, NULL, md_env,
   NULL), p_chanselect = &chan_to_cnstrs);

  return (stat_OM);
}

method EMdisplay_underconstrained (IGRlong *msg; IGRushort opts;
                                   struct GRmd_env *md_env)
{
  IGRlong msg_loc, stat_OM;
  IGRint i, num_uncnstr;
  IGRdouble *pt;
  IGRvector uncnstr_vecs[3];
  GRrange range;
  struct DMenv_param env_param;
  struct EMSgeomdata geomdata;
  struct IGRdisplay actdisp;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Get the vectors in the direction of undercontrainedness
   */

  num_uncnstr = 0;
  stat_OM = om$send (msg = message EMSparamgm.EMsolve (&msg_loc, NULL, 0, NULL,
   md_env, NULL, NULL, NULL, &num_uncnstr, uncnstr_vecs), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (!num_uncnstr, *msg, msg_loc, ret_end);

  /*
   * Obtain the point at which the vectors are going to be displayed
   */

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             &md_env->md_env.matrix_type, md_env->md_env.matrix,
             &geomdata), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  if (geomdata.geomtype == GEOMDATA_POINT)
    pt = geomdata.point;
  else if (geomdata.geomtype == GEOMDATA_LINE)
    pt = geomdata.line.line_pt1;
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);}

  /*
   * Obtain the range box wrt which the display vector is going to 
   * be computed. This is related to the dimension text height
   */

  stat_OM = dm$get_dim_param (type = DM_ENV_PARAM, p_data = &env_param );
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  for (i=0; i<6; i++)
    range[i] = 0.0;
  range[4] = DISP_FACTOR * env_param.txt_heig;

  /*
   * Display the vectors
   */

  gr$get_active_display (msg = &msg_loc, buffer = &actdisp);
  for (i=0; i<num_uncnstr; i++)
    EFdraw_vector_on_screen (my_id, &actdisp, md_env, GRhd, FALSE, pt,
     uncnstr_vecs[i], range, &msg_loc);
  ex$message(msgnumb = EMS_S_NoOfDegreesOfFreedom , var =  num_uncnstr,
       type = "%d");

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSparamgm.EMdisuncnstr");
  return (stat_OM);
}

/*

Name
  EMparam_delete

Abstract

Synopsis

Description
  Delete EMSparam?? objects.
Return Value

Notes

Index

Keywords
  delete

History
  ??/??/?? : ????? : created
  11/29/93 : G M K : Delete constriant objects which are in children channel.
                     TR # 119313554 
 */

method EMparam_delete (IGRlong *EMmsg; 
                       struct GRmd_env *md_env)
{
    IGRlong msg_loc,stat_OM;
    enum GRdpmode mode = GRbehe;
    OMuint om_msg, child_count=0 ,ch_count =0;
    OM_S_CHANSELECT chan_to_children;
    OM_S_CHANSELECT chan_to_cnstrs;

    *EMmsg = EMS_S_Success;
 
   EMmake_chanselect (NDchildren_children, &chan_to_children);
   EMmake_chanselect (NDfather_father, &chan_to_cnstrs);

   om_msg = om$get_channel_count(p_chanselect = &chan_to_children,
                                 objid = my_id,
                                 count = &child_count);
   if(!(1&om_msg)) goto wrapup;

   if (child_count)
   {
     IGRchar      mask, n_state;
     int	  ii;
     GRclassid 	  classid;
     OM_S_OBJECT_LINKAGE *objlist=NULL;
     extern GRclassid OPP_EMScnstr_class_id;
/*
 *   Change my state such that it gets deleted only if there is nobody 
 *   depending on me.
 *   pp 09/01/93
 */
     mask = ~0;
     n_state = ND_DEL_NO_CH;

     om$send (msg = message NDnode.NDchg_state(mask, n_state),
              targetid = my_id);
     
     /*
      * delete all constraint objects which are in children channel
      * TR # 119313554      GMK 11/29/93
      */
     objlist = (OM_p_OBJECT_LINKAGE) alloca (child_count * sizeof (OM_S_OBJECT_LINKAGE));
     EMerr_hndlr (!objlist, msg_loc, EMS_E_NoStackMemory, wrapup);
 
     stat_OM = om$get_channel_objects (p_chanselect = &chan_to_children,
               object = me, count = &child_count, size = child_count,
               list = objlist);
     EMerr_hndlr (EMSerror (stat_OM), msg_loc, FALSE, wrapup);
    
     for (ii = 0; ii < child_count; ii++)
     {
       om$get_classid (objid = objlist[ii].S_objid, osnum = objlist[ii].osnum,
                    p_classid = &classid);
       if (om$is_ancestry_valid (subclassid = classid,
         superclassid = OPP_EMScnstr_class_id) == OM_S_SUCCESS)
       {
         om$send ( msg = message GRgraphics.GRdisplay 
                                           ( &msg_loc,
                                             &md_env->md_env.matrix_type,
                                             md_env->md_env.matrix,
                                             &mode,
                                             &md_env->md_id ),
                targetid = objlist[ii].S_objid,
                targetos = objlist[ii].osnum);

         om$send (msg = message GRgraphics.GRdelete(&msg_loc, md_env),
                targetid = objlist[ii].S_objid,
                targetos = objlist[ii].osnum);
       }
     }
/*
 * Commented the following code, since this does not need to be freed
 * as the memory has been alloced as opposed to malloced.
 *
 begin pp

     if (objlist)
     {
       free (objlist);
       objlist = NULL;
     }

 end pp
*/
   }
/*
 * Always Delete the constraints.
 */

    {
      struct GRid cnstr;
      om_msg = om$get_objid_at_index(objid = my_id,
                                p_chanselect = &chan_to_cnstrs,
                                index = 0,
                                objidaddr = &cnstr.objid,
                                osnumaddr = &cnstr.osnum);

      om_msg = om$get_channel_count(p_chanselect = &chan_to_children,
                                 objid = cnstr.objid,
                                 osnum = cnstr.osnum,
                                 count = &ch_count);

      if(!(1&om_msg)) goto wrapup;
    }

/*
 * * Do not delete if the child count is more than one . This constraint 
 *   is shared by other axis parameters also. -gvk TR#119421469 
 */
   if(ch_count <2)
   {
     
    om$send ( msg = message GRgraphics.GRdisplay 
                                           ( &msg_loc,
                                             &md_env->md_env.matrix_type,
                                             md_env->md_env.matrix,
                                             &mode,
                                             &md_env->md_id ),
                  p_chanselect = &chan_to_cnstrs);

     om$send (msg = message GRgraphics.GRdelete(&msg_loc, md_env),
                   p_chanselect = &chan_to_cnstrs);
   }
   
wrapup:
 if (!child_count)
 {
    return(om$send(msg = message EMSparameter.delete(NULL),
                   mode = OM_e_wrt_message,
                   targetid = my_id));  
 }
 else
  return (OM_S_SUCCESS);
}


end implementation EMSparamgm;
