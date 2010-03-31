/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "EMSas.h"
#include "OMmacros.h"
#include "bssfarrevn.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bschangepar.h"

from EMSdprparam import EMget_display_ids, EMput_display_ids;

                                                /*NEED DIST PARAM*/
#define NUM_PARENTS 3  /*vector, magnatude, face, parent state*/ 
extern IGRboolean _sm_convert_into_plane;

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               GRobjid  old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)
/*****************************************************************
Description
  Lift the face associatively!!!!

Arguments
Input
  options : like to guess??
  nb_root : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

Recomputation informaton for lift face:
 See EMSas.h (cht & surface to lift)

Objects connected on the parent channel:
 vector, magnatude; sf or sl on which the lift was made.

History
    DLB     6/31/91     If POS_WITH_VECT flip sign of incoming magnatude it's 
                        less than zero.
    DLB     6/29/91     Take vector and magnatude rather than from, to pts.
    DLB     3/28/91     Creation.

    Sudha   06/01/93    modified to add for BSprototype headers
    WBC     12/16/93    Need to check at the end of the method and
                        make sure the display_ids have been posted in case
                        they have changed.

*********************************************************************** */
{
 OMuint                 ii, cur_par=0;             
 IGRdouble              save_cht, mag;
 IGRpoint               from_pt, to_pt;
 IGRvector              vect;
 IGRlong                OM_stat=OM_S_SUCCESS, loc_msg;
 struct EMSassoc_lift   *r_c_info;
 struct IGRbsp_surface  *sf_geom=NULL;
 union EMSparent_info   roots[NUM_PARENTS];
 IGRuint        root_type[NUM_PARENTS];
 GRobjid                *display_ids=NULL, param_id;
 IGRint                 display_count=0;
 struct GRid            srf_GRid;
 IGRboolean             recompute, normal_lift=FALSE;
 IGRboolean             save_cvrt_flag = FALSE,
                        update_display_ids = FALSE;

 
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 save_cvrt_flag = _sm_convert_into_plane;

 if (nb_root == 4) 
 {
   root_type[cur_par++] = EMSvector;
 }
 else normal_lift = TRUE;

 root_type[cur_par++] = EMSdistance;
 root_type[cur_par++] = EMSgrid;

 OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                         cur_par, parent_info, 
                         root_type, roots),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 cur_par = 0;

 if (!normal_lift)
   OM_BLOCK_MOVE(roots[cur_par++].vector, vect, sizeof(IGRvector));

 mag = roots[cur_par++].value;

 if (type & EMlft_POS_WITH_VECT)
 {
   if (mag < 0.0) mag *= -1;
 }

 srf_GRid = roots[cur_par++].grobj.grid;

 if (srf_GRid.objid == NULL_OBJID)
 {
   /*Must have been a mismatch on the surface id.*/
   *EMmsg = EMS_I_CantRecompute;
   goto wrapup;
 }

 r_c_info = (struct EMSassoc_lift *) recomp_info;

 if (normal_lift)
 {
   IGRdouble u,v;
   IGRpoint  sf_pt;
   IGRlong   bsrc;
   struct GRlc_info sf_info;

   /*Compute the lift vector*/
   sf_info.located_obj = srf_GRid;
   sf_info.module_info = *(construct_list->env_info);

   OM_stat = EMget_the_geometry(&sf_info, FALSE, FALSE,
                                FALSE, my_id, (IGRchar **)&sf_geom, EMmsg);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   u = v = 0;
   BSsfarrevn(&bsrc, sf_geom, 1, &u, 1, &v, sf_pt, vect);
   if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   BSnorvec(&bsrc, vect);
   if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   if (!sf_geom->pos_orient)
   {
     vect[0] *= -1;
     vect[1] *= -1;
     vect[2] *= -1;
   }

   if (!r_c_info->lift_with_pos_orient)
   {
     vect[0] *= -1;
     vect[1] *= -1;
     vect[2] *= -1;
   }
 }

 from_pt[0] = from_pt[1] = from_pt[2] = 0.0;

 for(ii=0; ii<3; ii++)
 {
   to_pt[ii] = vect[ii] * mag;
 }

 if (recompute = options & EMSasconst_recompute)
 {
   IGRlong bs_msg;   
   IGRboolean bs_sts;
 
   /*Save the current tolerance */
   bs_sts = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Set the proper tolerance for this operation*/
   bs_sts = BSchangepar(&bs_msg, BSTOLCHRDHT, r_c_info->cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Get the display array*/ 
   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                    EMmsg, &display_count, &display_ids,
                                    NULL), 
                             my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   update_display_ids = TRUE;
 } 

 if (!(type & EMlft_PLANE_CONVERSION))
  _sm_convert_into_plane = FALSE;

 /*Just do it!*/
 OM_stat = om$send(msg = message EMSsf_lift.EMlift_face(EMmsg,
                         construct_list->env_info, construct_list,
                         from_pt, to_pt, srf_GRid, EMS_LC_AUTO_COINCIDENCE,
                         NULL,
                         EMS_DO_DISPLAY | (recompute ? EMS_DONT_REDRAW : NULL),
                         recompute ? &display_ids : NULL, 
                         recompute ? &display_count : NULL),
                   targetid = my_id);                         

 if (recompute)
 {
   /*Put the display_ids in the param object.*/
   IGRboolean bs_sts;    

   /*Reset tolerance.*/
   bs_sts = BSchangepar(&loc_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                           display_count, display_ids, NULL),
                    targetid = param_id);
   display_ids = NULL;
   update_display_ids = FALSE;
   if (!(1 & loc_msg & OM_stat)) {*EMmsg = loc_msg; goto wrapup;}
 }
 else
 {
   IGRushort null=NULL;
   struct GRid *parent;
   
   parent = (struct GRid *) parent_info;

   OM_stat = om$send(msg = message EMSsfdpr.EMadd(&loc_msg, 
                           &parent[nb_root-1], NULL, 
                           construct_list->env_info, &null),
                     targetid = my_id);
   if (!(1 & OM_stat & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
 }

wrapup:

 /* post the display_ids to the param object in case an error occurred
  * before the ids were posted in the "normal" flow of the code
  */

 if (update_display_ids)
 {
   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                                         display_count, display_ids, NULL),
                     targetid = param_id);
 }

 if (sf_geom) om$dealloc(ptr = sf_geom);
 EMWRAPUP (*EMmsg,OM_stat, "sf_lft.const_assoc");
 _sm_convert_into_plane = save_cvrt_flag;
 return (OM_stat);
}
end implementation EMSsf_lift;

