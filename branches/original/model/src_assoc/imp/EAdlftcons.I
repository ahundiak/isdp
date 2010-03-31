/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdlift;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "EMSas.h"
#include "EMSopt.h"
#include "EMSasopts.h"
#include "bsvalues.h"
#include "bsicmpcvoff.h"
#include "OMmacros.h"
#include "values.h"
%safe
#include "math.h"
#include "bstst_plan.h"
#include "bssfarrevn.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bschangepar.h"
%endsafe

#define DEG_TO_RAD M_PI/180
#define ABS(X) ((X) >= 0 ? (X) : -(X))

from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSboundary import EMget_edges, EMget_objid;

extern IGRboolean _sm_convert_into_plane;

method EMconstruct_associative(IGRlong               *EMmsg;
                               IGRushort     options;
                               GRobjid               old_objid;
                               IGRint                nb_root;
                               IGRchar               *parent_info;
                               IGRint                type;
                               IGRchar               *recomp_info;
                               struct GRvg_construct *construct_list)
/*
Description
 This method does the actual dlift operation.

Notes
 About parameters:
  options: ubiquitous argument. Currently not supported and is set to
           NULL.
  nb_root : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Recomputation informaton for drafted lift:
 struct EMSdrafted_lift

Objects connected on the parent channel:
 lift vector
 surface to lift
 if (surface uniform)
    surface draft angle
 else 
    if (loop uniform)
       loop
       loop draft angle
    else       
       edge
       edge draft angle
 
History
    DLB    06/08/91    Creation
    Tapadia 08/01/91   Checks made for recomputing pocket/boss correctly. Added
                       EMdlft_POS_MAG_INSIDE type. 
    DLB    09/06/91    Wasn't freeing sf_geom. Am now.
    DLB    10/15/91    Allow standard lift.
    Tapadia 11/08/91   Supported pocket/boss without draft & make & lift face.
    DLB    07/30/92    Detect and fix case where no_fillets are used yet
                         the no_fillets flag is FALSE.

    Sudha  06/01/93	to handle BSprototypes
    WBC    12/16/93    Need to check at the end of the method and
                       make sure the display_ids have been posted in case
                       they have changed.
*/
{
 IGRdouble              cht, save_cht, draft_angle, magnatude;
 IGRlong                OM_stat=OM_S_SUCCESS, loc_msg;
 IGRint                 ii, jj, display_count=0, num_edge_GRids=0,
                        edge_buff_size=0; 
 OMuint                 *parent_type=NULL, parent_count, loop_array_size=0,
                        num_loops=0, cur_par; 
 union EMSparent_info   *parents=NULL;
 struct EMSdlft_info    *dlift_info;
 struct EMSdrafted_lift *dlft_recomp_info;
 struct GRid            *edge_GRids=NULL;
 struct IGRbsp_surface  *sf_geom=NULL;
 GRobjid                *display_ids=NULL, param_id, *loops=NULL;
 OMuword                osnum;
 IGRboolean             recompute, standard_lift=FALSE;
 extern OMuword         OPP_EMSplane_class_id;
 IGRboolean             save_cvrt_flag = FALSE,
                        update_display_ids = FALSE;
 

 *EMmsg = EMS_S_Success;
 save_cvrt_flag = _sm_convert_into_plane;

 parent_count = nb_root - 1;

 if (parent_count == 2) standard_lift = TRUE;

 dlft_recomp_info = (struct EMSdrafted_lift *) recomp_info;

 cht = dlft_recomp_info->cht;
 dlift_info = dlft_recomp_info->dlift_info;

 parent_type = (IGRuint *) alloca(parent_count * sizeof(IGRint));
 if (!parent_type) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 parents = (union EMSparent_info *) alloca 
           (parent_count * sizeof(union EMSparent_info)); 
 if (!parents) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 cur_par = 0;
 parent_type[cur_par++] = EMSdistance;
 parent_type[cur_par++] = EMSgrid;
 if (dlift_info->uniform_surface)
 {
   if (!standard_lift) parent_type[cur_par++] = EMSangle;
 }
 else
 {
   for(ii=0, cur_par=2; ii<dlift_info->num_lps; ii++)
   {
     if (dlift_info->lps_info[ii].is_uniform)
     {
       parent_type[cur_par++] = EMSgrid;
       parent_type[cur_par++] = EMSangle;
     }
     else
     {
       for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
       {
         parent_type[cur_par++] = EMSgrid;
         parent_type[cur_par++] = EMSangle;
       }
     }
   }
 }

 /*Get the parents*/
 OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         cur_par, parent_info, parent_type, parents),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*Store the magnatude*/
 cur_par = 0;
 magnatude = parents[cur_par++].value;

 if(standard_lift) 
 { /* for boss & pocket without draft */ 
   if(type & EMlft_POS_WITH_VECT) 
   {
     if(magnatude < 0.0) magnatude *= -1;
   }
 }
 else 
 { /* for boss with draft & make & lift face */
   if (type & EMdlft_NEG_MAG_OUTSIDE) 
   {
     if(magnatude > 0.0) magnatude *= -1;
   }

   if (type & EMdlft_POS_MAG_INSIDE) 
   { /* pocket with draft */
     if(magnatude < 0.0) magnatude *= -1;
   }
 }

 /*Store the surface*/
 dlift_info->sf_GRid = parents[cur_par++].grobj.grid;
 if (dlift_info->sf_GRid.objid == NULL_OBJID)
 {*EMmsg = EMS_I_CantRecompute; goto wrapup;}

 osnum = dlift_info->sf_GRid.osnum;

 { /*INTENTIONAL*/
   IGRdouble u,v;
   IGRpoint  sf_pt, sf_nrml;
   IGRvector unused_vec;
   IGRlong   bsrc;
   struct GRlc_info sf_info;
   IGRboolean planar;
      

   /*Compute the lift vector*/
   sf_info.located_obj = dlift_info->sf_GRid;
   sf_info.module_info = *(construct_list->env_info);

   OM_stat = EMget_the_geometry(&sf_info, FALSE, FALSE,
                                FALSE, my_id, (IGRchar **)&sf_geom, EMmsg);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /*Verify that the surface is still ok for lifting.*/
   (void) BStst_plan(sf_geom->u_num_poles * sf_geom->v_num_poles, 
                     sf_geom->poles,
                     sf_geom->rational ? sf_geom->weights : NULL,
                     &planar, unused_vec, &bsrc);
   if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   if (!planar) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

   u = v = 0;
   BSsfarrevn(&bsrc, sf_geom, 1, &u, 1, &v, sf_pt, sf_nrml);
   if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   BSnorvec(&bsrc, sf_nrml);
   if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   if (!sf_geom->pos_orient)
   {
     sf_nrml[0] *= -1;
     sf_nrml[1] *= -1;
     sf_nrml[2] *= -1;
   }

   if(standard_lift && !(type & EMlft_WITH_POS_ORIENT)) {
     sf_nrml[0] *= -1;
     sf_nrml[1] *= -1;
     sf_nrml[2] *= -1;
   }

   dlift_info->draft_vec[0] = sf_nrml[0] * magnatude;
   dlift_info->draft_vec[1] = sf_nrml[1] * magnatude;   
   dlift_info->draft_vec[2] = sf_nrml[2] * magnatude;    
 } 


 if (dlift_info->uniform_surface)
 {
   if (standard_lift)
   {
     draft_angle = 0.0;
   }
   else
   {
     /*Store the surface draft angle*/
     draft_angle = parents[cur_par++].value;
     draft_angle = draft_angle * DEG_TO_RAD;

     if (type & EMdlft_NEG_ANGLE_OUTSIDE)
     {
       if(draft_angle > 0) draft_angle *= -1;
     }
   }

   dlift_info->mx_exlp_dangle = draft_angle;
 }   
 else dlift_info->mx_exlp_dangle = 0;

 { /*INTENTIONAL*/
   /*DLB 7/30/92 - Determine if the no_fillets field is set correctly.  If
    * no set it.
    */
   if (!dlift_info->no_fillets)
   {
     if (dlift_info->num_lps && dlift_info->lps_info) /*safety net*/
     {
       for(ii=0; ii<dlift_info->num_lps; ii++)
       {
         if (dlift_info->lps_info[ii].fillet == TRUE) break;
       }
       if (ii == dlift_info->num_lps) dlift_info->no_fillets = TRUE;
     }
   }
 }   

 /*Get the loops of this surface*/
 if (dlift_info->uniform_surface)
 {
   dlift_info->num_ed_infos = 0;

   EFgetLoopsEdges(EMmsg, 1, &dlift_info->sf_GRid.objid,
                   &loop_array_size,
                   &num_loops,
                   &loops,
                   NULL, NULL, NULL, osnum);
   if (!(1 & *EMmsg)) goto wrapup;                   

   if (!dlift_info->no_fillets)
   {
     if (!dlift_info->num_lps || !dlift_info->lps_info)
     {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
   }
   else
   {
     dlift_info->num_lps = num_loops;
     dlift_info->lps_info = (struct EMSdlft_lp_info *) alloca
                            (num_loops * sizeof(struct EMSdlft_lp_info));
     if (! dlift_info->lps_info){*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
   }

   for(ii=0; ii<dlift_info->num_lps; ii++)
   {
     /*Fill the variable information it the lp_info struct*/
     dlift_info->lps_info[ii].lp_GRid.objid = loops[ii];
     dlift_info->lps_info[ii].lp_GRid.osnum = osnum;
     dlift_info->lps_info[ii].draft_angle = draft_angle;
     dlift_info->lps_info[ii].is_uniform = TRUE;  

     if (dlift_info->no_fillets)
       dlift_info->lps_info[ii].fillet = FALSE;

     num_edge_GRids = 0;
     OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg, 1, 
                             EMS_OPT_NONDEG_NONSEAM,
                             &edge_GRids, &edge_buff_size, &num_edge_GRids), 
                       targetid = dlift_info->lps_info[ii].lp_GRid.objid,
                       targetos = osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;

     dlift_info->lps_info[ii].num_eds = num_edge_GRids;

     dlift_info->lps_info[ii].eds_info = (struct EMSdlft_ed_info *) alloca
                           (num_edge_GRids * sizeof(struct EMSdlft_ed_info));
     if (!dlift_info->lps_info[ii].eds_info)
     {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}       

     for(jj=0; jj<num_edge_GRids; jj++)
     {
       dlift_info->lps_info[ii].eds_info[jj].ed_GRid = edge_GRids[jj];
       dlift_info->lps_info[ii].eds_info[jj].draft_angle = draft_angle;
       dlift_info->lps_info[ii].eds_info[jj].ed_constraint_type =
                                                     EMS_LC_AUTO_COINCIDENCE;
       dlift_info->lps_info[ii].eds_info[jj].offset_code = BSCONSTOFF;
     }
     dlift_info->num_ed_infos += num_edge_GRids;
   }
 }
 else 
 {
   if (!dlift_info->num_lps || !dlift_info->lps_info)
   {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

   dlift_info->num_ed_infos = 0;

   for(ii=0; ii<dlift_info->num_lps; ii++)
   {
     num_edge_GRids = 0;
     if (dlift_info->lps_info[ii].is_uniform)
     {
       dlift_info->lps_info[ii].lp_GRid = parents[cur_par++].grobj.grid;
       if (dlift_info->lps_info[ii].lp_GRid.objid == NULL_OBJID)
       {*EMmsg = EMS_I_CantRecompute; goto wrapup;}

       draft_angle = parents[cur_par++].value;
       draft_angle = draft_angle * DEG_TO_RAD;

       if (type & EMdlft_NEG_ANGLE_OUTSIDE) draft_angle *= -1;

       dlift_info->lps_info[ii].draft_angle = draft_angle;
       if ( ABS(draft_angle) > ABS(dlift_info->mx_exlp_dangle))
         dlift_info->mx_exlp_dangle = draft_angle;

       OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg, 1, 
                              EMS_OPT_NONDEG_NONSEAM,
                              &edge_GRids, &edge_buff_size, &num_edge_GRids),
                         targetid = dlift_info->lps_info[ii].lp_GRid.objid,
                         targetos = osnum);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

       dlift_info->lps_info[ii].num_eds = num_edge_GRids;

       dlift_info->lps_info[ii].eds_info = (struct EMSdlft_ed_info *) 
                     alloca(num_edge_GRids * sizeof(struct EMSdlft_ed_info));
       if (!dlift_info->lps_info[ii].eds_info)
       {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

       for(jj=0; jj<num_edge_GRids; jj++)
       {
         dlift_info->lps_info[ii].eds_info[jj].ed_GRid = edge_GRids[jj];
         dlift_info->lps_info[ii].eds_info[jj].draft_angle = draft_angle; 
         dlift_info->lps_info[ii].eds_info[jj].ed_constraint_type =
                                                     EMS_LC_AUTO_COINCIDENCE;
         dlift_info->lps_info[ii].eds_info[jj].offset_code = BSCONSTOFF;
       }           
       dlift_info->num_ed_infos += num_edge_GRids;
     }
     else
     {
       GRobjid     tmp_loop_id;
       struct GRid tmp_ed_GRid;         

       tmp_ed_GRid = parents[cur_par].grobj.grid;

       tmp_loop_id = NULL_OBJID;
       OM_stat = EMsend_loops(EMmsg, message EMSboundary.EMget_objid(EMmsg,
                                     &tmp_loop_id),
                              tmp_ed_GRid.objid, 0, OM_K_MAXINT, EMLP_ACTIVE,
                              NULL, NULL);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

       if (tmp_loop_id == NULL_OBJID)
       {*EMmsg = EMS_I_CantRecompute; goto wrapup;}

       OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                               1, EMS_OPT_NONDEG_NONSEAM, 
                               NULL, NULL, &num_edge_GRids),
                         targetid = tmp_loop_id,
                         targetos = osnum);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

       if (dlift_info->lps_info[ii].num_eds != num_edge_GRids)
       {*EMmsg = EMS_I_CantRecompute; goto wrapup;}         

       dlift_info->lps_info[ii].lp_GRid.objid = tmp_loop_id;
       dlift_info->lps_info[ii].lp_GRid.osnum = osnum;

       for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
       {
         dlift_info->lps_info[ii].eds_info[jj].ed_GRid = 
                                               parents[cur_par++].grobj.grid;
         if (dlift_info->lps_info[ii].eds_info[jj].ed_GRid.objid ==
             NULL_OBJID) 
         {*EMmsg = EMS_I_CantRecompute; goto wrapup;}
                                        
         draft_angle = parents[cur_par++].value;
         draft_angle = draft_angle * DEG_TO_RAD;

         if (type & EMdlft_NEG_ANGLE_OUTSIDE) draft_angle *= -1;

         dlift_info->lps_info[ii].eds_info[jj].draft_angle = draft_angle;
         if ( ABS(draft_angle) > ABS(dlift_info->mx_exlp_dangle))
           dlift_info->mx_exlp_dangle = draft_angle;
       }
       dlift_info->num_ed_infos += dlift_info->lps_info[ii].num_eds;
       dlift_info->lps_info[ii].draft_angle = draft_angle; /*same last ed*/
     }
   }
 }

 if (recompute = options & EMSasconst_recompute)
 {
   IGRlong bs_msg;   
   IGRboolean bs_sts;
 
   /*Save the current tolerance */
   bs_sts = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Set the proper tolerance for this operation*/
   bs_sts = BSchangepar(&bs_msg, BSTOLCHRDHT, cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Get the display array*/ 
   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                    EMmsg, &display_count, &display_ids,
                                    NULL), 
                            my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   update_display_ids = TRUE;
 } 

 if (!(type & EMdlft_PLANE_CONVERSION))
  _sm_convert_into_plane = FALSE;

 /*Just do it!*/
 OM_stat = om$send(msg = message EMSsfdlift.EMlift_face(EMmsg,
                         construct_list->env_info,
                         construct_list,
                         dlift_info,
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
 else if (1 & OM_stat & *EMmsg)
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

 /* post the display ids if they did not get posted in the "normal" flow of
  * the code
  */

 if (update_display_ids)
 {
   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                                           display_count, display_ids, NULL),
                     targetid = param_id);
 }

 if (sf_geom) om$dealloc(ptr = sf_geom);
 if (edge_GRids) om$dealloc(ptr = edge_GRids);
 if (loops) om$dealloc(ptr = loops);
 if (dlft_recomp_info->view_info) 
   om$dealloc(ptr = dlft_recomp_info->view_info); 
 EMWRAPUP(*EMmsg, OM_stat, "sfdlft:const_ass")
 _sm_convert_into_plane = save_cvrt_flag;
 return(OM_stat);
}
end implementation EMSsfdlift;

