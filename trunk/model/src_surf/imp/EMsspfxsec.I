/* ###################   APOGEE COMPILED   ################## */
/*
                                
History
    SM  31-Apr-87   Design and Creation.
	SM	25-Mar-88   Moved the message from EMSsolid to EMSsurface
                    This will allow cross section of any surface
                    as long as it is closed.
	SM	04-Apr-88   Call EMfix_sfint_uvtrace for both inters
                    list to cause refinement of
                    intersections and existing linear edges.
    RC  17-Aug-88   Modified for associative cross-section.

Algorithm
*/

class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "bsparameters.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

from EMSedge    import EMset_props;

extern OMuword OPP_EMSloopset_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

method EMperform_xsection(
       IGRlong                   *EMmsg;
       struct GRvg_construct     *construct_list;
       struct GRmd_env           *cs_env;
       struct GRid               *model_GRid;
       struct GRmd_env           *model_env;
       struct EMSxs_assoc_info   *xs_assoc_info)
{
  struct      EMSpartolbasis partolbasis;
  struct      EMSdataselect  model_data;
  struct      EMSsftracedata cs_trace, mdl_trace;
  struct      GRid           my_GRid;
  struct      EMSintobj      *intobj_loc;
  struct      EMSinters      *cs_inters, *model_inters;

  IGRdouble                  trace_tol, **par_tol;

  IGRlong                    OM_stat, mthd_stat, num_inters = 0, 
                             i, j, k, rc;

  IGRint                     /*nat_bd_inx,*/ num_lps_added/*, sf_inx */;

  GRobjid                    ls_id = NULL_OBJID, *lp_added_ids, md_sf_id, 
                             cs_ed_id;


  IGRushort          outworld_options, trim_options, 
                             outparam_options, inters_options;

  IGRboolean                 world, dealloc_cs_trace, dealloc_mdl_trace,
                             open_grps_exist;

  IGRboolean save_pathway_trim, save_pathway_orient;

  extern void                EMsfinttrace(), EMinters_data_free(), 
                             EMinters_free(), EMsfinttrace_free(), 
                             EFsave_xs_assoc_info(),
                             EFcreate_eds_to_cls_grps();
        
  extern IGRlong             EMintersect_surfaces();

  /* *************************************************************** */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  world = TRUE;
  cs_inters = model_inters = NULL;
  par_tol = NULL;
  dealloc_cs_trace = dealloc_mdl_trace = FALSE;
  lp_added_ids = NULL;

  BSEXTRACTPAR (&rc, BSTOLLENVEC, trace_tol);

  /*  
   * Intersect the cross sectional plane with the solid.
   */
 
  ex$message(msgnumb = EMS_I_PerformModXsecInt)
  model_data.datatype = EMSdata_object;
  model_data.data.object = model_GRid;

  outparam_options = NULL | EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
  outworld_options = NULL | EMSINT_OUTPUT_WORLD | EMSINT_ORIENT_OUTPUT |
                    EMSINT_ORIENT_RIGHT;
  trim_options = NULL | EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA;
  inters_options = EMS_SFINT_MUSTORIENT |
                   EMS_SFINT_AUTODOUBLECHECK |
                   EMS_SFINT_MUSTNOAMBIGUOUS;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
 
  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  OM_stat = EMintersect_surfaces (&mthd_stat, &my_GRid, cs_env, 1, 
              &model_data, model_env, inters_options, outworld_options,
              outparam_options, trim_options, construct_list, 
              &num_inters, &cs_inters, &model_inters, &cs_trace,
              &mdl_trace, NULL, NULL, NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_SurfaceError, wrapup);
  EMerr_hndlr(!num_inters, *EMmsg, EMS_I_NoIntersection, wrapup);

  dealloc_cs_trace = dealloc_mdl_trace = TRUE;

  world = TRUE;
  OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis (&mthd_stat,
                      &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
                      &world, FALSE, &partolbasis.tol),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  partolbasis.mattyp = &cs_env->md_env.matrix_type;
  partolbasis.mat = cs_env->md_env.matrix;

 /*
  * In case of jogged cross section where each cross_section
  * plane may not be cutting across the model, it is possible
  * that the groups are not closed. These groups should be
  * merged if needed and closed w.r.t natural boundaries of
  * cross_section plane. The cross section plane is constructed
  * in a way such that the open groups should only close w.r.t
  * natural edges u=0 and u=1. If not, there is actually
  * an intersection closure problem.
  */

 open_grps_exist = FALSE;
 for (i = 0; i < cs_trace.num_grps; i++)
 {
   if (!cs_trace.grp_closed[i])
   {
     open_grps_exist = TRUE;
     break;
   }
 } /* for (i = 0; i < cs_trace.num_grps; i++) */

 if (open_grps_exist)
 {
   /*
    * o Get the end points of the open groups. There will be
    *   only one subgroup/group. Therefore, end point of a group
    *   is the same as that of its subgroup.
    * o sort these end points on u=0 and u=1 edge.
    * o Create part of natural edges for each pair of sorted list
    *   of end points. The end points should be sorted in increasing
    *   value of v for u=0 and in decreasing value of v for u = 1.
    * o Trace the intersections again.
    */

   EFcreate_eds_to_cls_grps (&rc, cs_trace.num_grps, cs_trace.grp_closed, 
            cs_trace.num_subgrps_grp, cs_trace.num_elems_subgrp, 
            cs_trace.elems, xs_assoc_info, &cs_inters->this_obj, 
            (struct IGRbsp_surface *) cs_inters->more_info, 
            partolbasis.tol, cs_env, &cs_inters, TRUE);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   EMsfinttrace_free(&rc, cs_trace.num_grps, cs_trace.num_subgrps_grp,
        cs_trace.num_elems_subgrp, cs_trace.elems, cs_trace.subgrp_rev, 
        cs_trace.elem_rev, cs_trace.grp_closed, cs_trace.subgrp_closed);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * Trace the intersections again.
    */

   EMsfinttrace( &rc, &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
                 cs_inters, NULL, &trace_tol, &cs_trace.num_grps, 
                 &cs_trace.num_subgrps_grp, &cs_trace.num_elems_subgrp, 
                 &cs_trace.elems, &cs_trace.subgrp_rev, 
                 &cs_trace.elem_rev, &cs_trace.grp_closed, 
                 &cs_trace.subgrp_closed );
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

 } /* if (open_grps_exist) */
  
 /*
  * o make loops out of intersection data.
  * o Nest these new loops.
  * o Toggle the loops appropriately.
  */

 ex$message(msgnumb = EMS_I_ConstXsecBdrys)

 EFmk_xsec_lps ( &rc, cs_env, OM_Gw_current_OS, cs_trace.num_grps, 
                 cs_trace.num_subgrps_grp, cs_trace.num_elems_subgrp, 
                 cs_trace.elems, cs_trace.subgrp_rev, cs_trace.elem_rev, 
                 cs_trace.grp_closed, cs_trace.subgrp_closed, 
                 &partolbasis, &ls_id, my_id, &num_lps_added, 
                 &lp_added_ids);
 EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * store the information regarding the surface of the model
  * used in creating this particular edge element.
  */

  for (i = 0; i < cs_trace.num_grps; i++)
  {
    for (j = 0; j < cs_trace.num_subgrps_grp[i]; j++)
    {
      intobj_loc = cs_trace.elems[i][j]; 
      for (k = 0; k < cs_trace.num_elems_subgrp[i][j]; k++)
      {
       if (intobj_loc->other_intobj_node)
       {
        md_sf_id =intobj_loc->other_intobj_node->this_obj_node->this_obj.objid;
        cs_ed_id = intobj_loc->this_uvintobj.data.object->objid;

        EFsave_xs_assoc_info (&rc, xs_assoc_info, md_sf_id, &cs_ed_id, 1);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

       } /* if (intobj_loc->other_intobj_node) */
        
       intobj_loc = intobj_loc->next;

      } /* for (k = 0; k < cs_trace.num_elems_subgrp[i][j]; k++) */

    } /* for (j = 0; j < cs_trace.num_subgrps_grp[i]; j++) */

  } /* for (i = 0; i < cs_trace.num_grps; i++) */

  /*
   * In case the cross section plane is not cutting through
   * the solid, some of its boundaries are made up of natural
   * edges. It is assumed that this situation will arise only if
   * there are other cross plane(s) which along with this plane
   * cut through the model. Therefore, these natural boundaries,
   * which are not real boundaries on the model, should be supressed
   * for display.
   */

/*
  if (open_grps_exist)
  {
    nat_bd_inx = 0;
    for (sf_inx = 0; sf_inx < xs_assoc_info->num_sfs; sf_inx++)
    {
      if (xs_assoc_info->sf_list[sf_inx] == my_id) break;
      else
       nat_bd_inx += xs_assoc_info->num_eds_sf[sf_inx];
    } */ /* for (sf_inx = 0; sf_inx < xs_assoc_info->num_sfs; sf_inx++) */
/*
    for (i = 0; i < xs_assoc_info->num_eds_sf[sf_inx]; i++, nat_bd_inx++)
    {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SUBORDINATE, EMS_O_ON),
                         targetid = xs_assoc_info->ed_list[nat_bd_inx]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

    }*/ /* for (i = 0; i < xs_assoc_info->num_eds_sf[sf_inx]; i++) */
 
 /*  } */ /* if (open_grps_exist) */

wrapup:

  if(cs_inters)
  {
    EMinters_data_free(&rc, cs_inters, NULL, NULL, NULL);
    EMinters_free(cs_inters,NULL);
  }

  if(model_inters)
  {
    EMinters_data_free(&rc, model_inters, NULL, NULL, NULL);
    EMinters_free(model_inters,NULL);
  }

  if(dealloc_cs_trace) 
    EMsfinttrace_free(&rc, cs_trace.num_grps, cs_trace.num_subgrps_grp,
        cs_trace.num_elems_subgrp, cs_trace.elems, cs_trace.subgrp_rev, 
        cs_trace.elem_rev, cs_trace.grp_closed, cs_trace.subgrp_closed);

  if(dealloc_mdl_trace) 
    EMsfinttrace_free(&rc, mdl_trace.num_grps, mdl_trace.num_subgrps_grp,
        mdl_trace.num_elems_subgrp, mdl_trace.elems, mdl_trace.subgrp_rev, 
        mdl_trace.elem_rev, mdl_trace.grp_closed,mdl_trace.subgrp_closed);

 if(lp_added_ids) om$dealloc(ptr = lp_added_ids);

 EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMperform_cross_section");

 return(OM_stat);

}

end implementation EMSxsplane;

