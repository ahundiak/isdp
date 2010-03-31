class implementation EMSsfmkface;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "EMSas.h"
#include "memory.h"
#include "REmkface.h"
#include "bsparameters.h"
#include "bschangepar.h"

from GRcurve     import GRendpts;
from GRlinear    import GRgetpolyline;
from GRcompcurve import EMmakecomp;
from GRcurve     import GRdisextend;
from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSsubbs    import EMpartolbasis;

#define STUPID_GRADATA_WORKS 0

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
 This method does the actual construction of make face object.

Arguments
Input
  options: ubiquitous argument. Currently not supported and is set to
           NULL.
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

Recomputation informaton for make face:
 OMuint surface; Surface on which make face was done.

Objects connected on the parent channel:
 Curve elements which is used to perform the make face.
 Solid or surface on which the face was made.

History
 12/16/93 : WBC : Need to check at the end of the method and
                  make sure the display_ids have been posted in case
                  they have changed.
 08/12/92 : DLB : Use different assoc type for 2.1 version of mkface
                  due to algorithm change.
 07/24/92 : DLB : Support optional track point parent.
 12/11/91 : DLB : Perform get_parent_info on component parent. 
                  Fixes a problem if making a face on a non-associative
                  surface. 
 06/30/91 : DLB : Initialize grp_info to 0.
 05/16/91 : DLB : Mod so face parent is in parent list rather than as part of
                  recomp_info.
 03/26/91 : DLB : Added cht to recompute info.
 07/08/90 : PP  : Creation
************************************************************************/
{
 IGRdouble            save_cht = 0.0, *cht;
 IGRlong              status, loc_msg;
 union EMSparent_info *roots = NULL;
 IGRuint              real_parent_count, curve_count, mkf_w_track;
 IGRuint              *root_type = NULL;
 struct GRid          my_GRid;
 IGRint               i,number_of_bad_curves, number_of_points;
 IGRlong              bad_curve_indices[50];
 IGRpoint             *points = NULL, track_pt;
 GRobjid              *display_ids=NULL, param_id;
 IGRint               display_count=0;
 struct EMSmkf_grouping_info   grp_info;
 IGRlong                       process_phase;
 struct GRlc_info              *cvinfo = NULL;
 struct GRid                   srf_GRid, track;
 struct GRmd_env               track_env;
 union EMSparent_info          *ptr_root_struct = NULL;
 IGRboolean                    recompute,
                               update_display_ids = FALSE;
 

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (type == EMS_ASmkface_w_track_pt || type == EMS_ASmkface_ver2_1_w_track_pt)
   mkf_w_track = 1;
 else 
   mkf_w_track = 0;

 /*
  * Number of parents that I am associatied with is nb_root - 1 since
  * one of my parents is a component parent.  Number of curves is
  * real_parent_count - 1 since last real parent is the face parent.
  *
  * ALSO!! If have optional parent then real_parent_count is still nb_root-1
  *        BUT curve count is nb_root-1-track_pt.
  */

 real_parent_count = nb_root - 1;
 curve_count = real_parent_count - 1 - mkf_w_track;

 root_type = (IGRuint *) stackalloc
             (sizeof(IGRint) * real_parent_count);
 EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 roots = (union EMSparent_info *) stackalloc
         (sizeof(union EMSparent_info) * real_parent_count);
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 for(i=0; i<real_parent_count; i++) root_type[i] = EMSgrid;

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         real_parent_count, parent_info,
                         root_type, roots),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 number_of_points = 0;
 points = NULL;
 process_phase = EMS_PROCESS_PHASE1;

 cvinfo = (struct GRlc_info *) stackalloc
          (sizeof(struct GRlc_info) * curve_count); 
 EMerr_hndlr(!cvinfo, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 ptr_root_struct = roots;

 for (i=0; i<curve_count; i++)
 {
   cvinfo[i].located_obj = ptr_root_struct->grobj.grid;
   cvinfo[i].module_info = ptr_root_struct->grobj.env;
   ++(ptr_root_struct);
 }

 srf_GRid = ptr_root_struct->grobj.grid;
 ++(ptr_root_struct);

 if (srf_GRid.objid == NULL_OBJID)
 {
   /*Must have been a mismatch on the surface id.*/
   *EMmsg = EMS_I_CantRecompute;
   goto wrapup;
 }

 if (mkf_w_track)
 {
   track = ptr_root_struct->grobj.grid;
   track_env = ptr_root_struct->grobj.env;
 }

 cht = (IGRdouble *) recomp_info;

 if (recompute = options & EMSasconst_recompute)
 {
   IGRlong bs_msg;   
   IGRboolean bs_sts;
 
   /*Save the current tolerance */
   bs_sts = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Set the proper tolerance for this operation*/
   bs_sts = BSchangepar(&bs_msg, BSTOLCHRDHT, *cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Get the display array*/ 
   status = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                   EMmsg, &display_count, &display_ids,
                                   NULL), 
                            my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & status & *EMmsg)) goto wrapup;

   update_display_ids = TRUE;
 } 

 if (mkf_w_track) /*Extract xyz point geom from track point object*/
 {
   IGRint             return_poly=1;
   struct IGRpolyline polyline;
   extern OMuword     OPP_GRpoint_class_id;

   if (!EFisAncestryValid(EMmsg, track.objid, track.osnum,
                          OPP_GRpoint_class_id, FALSE))
   {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

   polyline.points = track_pt;

   status = om$send(msg = message GRlinear.GRgetpolyline(EMmsg,
                          &track_env.md_env.matrix_type,
                          track_env.md_env.matrix,
                          &return_poly, &polyline),
                    targetid = track.objid,
                    targetos = track.osnum);
   if (!(1 & status & *EMmsg)) goto wrapup;
 }

 /*Just do it!*/
 memset((char *) &grp_info, '\0', sizeof(struct EMSmkf_grouping_info));

 status = om$send (msg = message EMSsfmkface.EMmake_face_execute(EMmsg,
                         srf_GRid, construct_list->env_info, 
                         curve_count, cvinfo, construct_list,
                         (IGRlong *)&number_of_points, &points, TRUE,
                         (IGRlong *)&number_of_bad_curves, bad_curve_indices,
                         FALSE, process_phase,(IGRchar *) &grp_info,
                         EMS_DO_DISPLAY | 
                         ((recompute && STUPID_GRADATA_WORKS) ? 
                         EMS_DONT_REDRAW : NULL),
                         recompute ? &display_ids : NULL, 
                         recompute ? &display_count : NULL,
                         mkf_w_track ? track_pt : NULL),
                   targetid = my_id);

 if (recompute)
 {
   /*Put the display_ids in the param object.*/
   IGRboolean bs_sts;    

   /*Reset tolerance.*/
   bs_sts = BSchangepar(&loc_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   status = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                          display_count, display_ids, NULL),
                    targetid = param_id);
   display_ids = NULL;
   update_display_ids = FALSE;
   if (!(1 & loc_msg & status)) {*EMmsg = loc_msg; goto wrapup;}
 }
 else if ((1 & status & *EMmsg) && (*EMmsg != EMS_I_NeedGrpInfo))
 {
   IGRushort null=NULL;
   struct GRid *parents;
   
   /*DLB 12/11/91 - Unwind the component parent into its geometry class.
    *   Must do this since the component parent may not be associative.
    *   Just REUSE same root_type and root arrays.
    */
   parents = (struct GRid *) parent_info;
   status = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                          1, (IGRchar *) &parents[nb_root-1],
                          root_type, roots),
                    targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   status = om$send(msg = message EMSsfdpr.EMadd(&loc_msg, 
                          &roots->grobj.grid, NULL, 
                          construct_list->env_info, &null),
                    targetid = my_id);
   if (!(1 & status & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
 }

 /*
  * Cannot handle ambiguous cases.
  */

 if (*EMmsg == EMS_I_NeedGrpInfo)
 {
   struct GRmd_env          *env;
   IGRboolean               world_flag, is_lp_org;
   struct EMSpartolbasis    partolbasis;
   IGRint                   cur_entry;

   env = construct_list->env_info;

   world_flag = TRUE;

   partolbasis.in_world = TRUE;
   partolbasis.is_valid = TRUE;
   partolbasis.mattyp= &env->md_env.matrix_type;
   partolbasis.mat = env->md_env.matrix;

   status = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg,
                          &env->md_env.matrix_type,
                          env->md_env.matrix,
                          &world_flag, FALSE, &partolbasis.tol),
                    senderid = my_id,
                    targetid = srf_GRid.objid,
                    targetos = srf_GRid.osnum);
   if (!(1 & status & *EMmsg)) goto wrapup;

   status = om$send(msg = message EMSsfmkface.EMgraceful_exit(
                          EMmsg, &partolbasis, env,
                          grp_info.loops_trim_info, 
                          grp_info.num_trim_info, NULL, NULL, 
                          grp_info.gr1_ls_id, grp_info.gr2_ls_id,
                          srf_GRid, grp_info.sf_org_ls,
                          grp_info.sf_org_lps, grp_info.num_sf_org_lps,
                          NULL_OBJID, EMS_DO_DISPLAY),
                    targetid = my_id);
   if (!(1 & status & *EMmsg))
    {
     *EMmsg = EMS_E_MkfGrExit;
     goto wrapup;
    }

   /*
    * delete the ambiguous loops that were not
    * part of the original loopset.
    */

   for (i = 0; i < grp_info.num_amb_lps; i++)
   {
     is_lp_org = FALSE;
     cur_entry = 0;

     do
     {
       if (grp_info.amb_lps[i] == grp_info.sf_org_lps[cur_entry])
         is_lp_org = TRUE;
       else cur_entry++;
     } while (cur_entry < grp_info.num_sf_org_lps && !is_lp_org);

     if (!is_lp_org)
     {
       status = om$send(msg = message Root.delete(1),
                        targetid = grp_info.amb_lps[i]);
       if (!(1 & status)) goto wrapup; 
     }
   }

   /*
    * free memory
    */
   if (grp_info.amb_lps) om$dealloc (ptr = grp_info.amb_lps);
   if (grp_info.sf_org_lps) om$dealloc (ptr=grp_info.sf_org_lps);
   if (grp_info.sf_lps_removed) 
                EMownercomp_free(grp_info.sf_lps_removed, NULL);
   if (grp_info.new_lps_added) om$dealloc(ptr = grp_info.new_lps_added);
   if (grp_info.loops_trim_info)
   {
     for (i = 0; i < grp_info.num_trim_info; i++)
         EMsfintedpar_free(grp_info.loops_trim_info[i],2);

     om$dealloc(ptr = grp_info.loops_trim_info);
   }

   /* *EMmsg = EMS_E_InvalidCase;*/ 

   *EMmsg = EMS_E_MkfGrouping;     /* SM 2/10/93 */

   goto wrapup;
 }
                      
wrapup:
 
 if (update_display_ids)
 {
   status = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                                       display_count, display_ids, NULL),
                    targetid = param_id);
 }

 if (number_of_points) 
 if (points) free(points);
 if (root_type) stackfree(root_type);
 EMWRAPUP (*EMmsg,status, "mkf.const_assoc")
 return (status);
}
end implementation EMSsfmkface;

