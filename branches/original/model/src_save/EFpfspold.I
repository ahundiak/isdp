/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include <stdio.h>
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "emsdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "EMSsfintsort.h"
#include "msmacros.h"
#include "emsgeteddef.h"
#include "EMcp.h"

extern OMuword  OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id,
                OPP_EMSpartedge_class_id;

from EMSsubbs    import EMpartolbasis;
from EMSboundary import EMgetsurface_info, EMget_objid;
from EMSloopset  import EMget_loops, EMtreemod;
from EMSedge     import EMendpts, EMget_props;
from EMSloop     import EMnext_edge, EMget_props, EMget_loops,
                        EMgivenestinfo, EMnesting, EMtreemod, EMlpinit;

/*****************************************************************************/
/*                         OLD SELECTIVE BOOLEAN CODE                        */
/*****************************************************************************/
/*
 ABSTRACT
          This following function peforms a boolean operation such that
	      only user defined portions are kept. This is used in 
	      trimming/extending/diff/union/intersection operations.
	      The associated functions are in file EFspboolsup.I

 HISTORY
       	RC    07/22/89     Creation Date
        SS    08/12/89     Changed the function EMbool_validate to
                           EMsfint_topology_validate.
	Tapadia 09/05/91   Added an argument in the function, hence changed 
			   the name to EFperform_special_boolean_mod. If the
			   argument arg_bool_GRid.objid is NULL_OBJID an 
			   object of class EMSsfboolean or EMSslboolean is
			   constructed, else the passed objid is used in 
			   boolean operation. 
	SM    19-Feb-92    Initialized all pointers to NULL in the
	                   declaration itself.
*/


void EFperform_special_boolean_mod(EFmsg, md_env, op1_elem,
            num_op2_elems, op2_elems, all_elements_solid, const_list, 
            bool_type, num_pts, sortpts_info, options, num_bad_pts,
            bad_pts_info, arg_bool_GRid)
 IGRlong                 *EFmsg;
 struct GRmd_env         *md_env;
 GRobjid                 op1_elem;
 IGRint                  num_op2_elems;
 GRobjid                 *op2_elems;
 IGRboolean              all_elements_solid;
 struct GRvg_construct   *const_list;
 enum   EMSbooltype      bool_type;
 IGRint                  num_pts;
 struct EMSsortpt_info   *sortpts_info;
 IGRushort       options;
 IGRint                  *num_bad_pts;
 struct EMSsortpt_info   **bad_pts_info;
 struct GRid 		arg_bool_GRid;
{
 struct EMSdataselect  *op2_elems_dataselect = NULL, 
                       op2_elems_datmem[OP2_BUF_SIZE];

 struct GRid           *op2_elems_GRid = NULL, 
                       op2_elems_GRidmem[OP2_BUF_SIZE],
                       op1_elem_GRid, bool_GRid;

 struct EMSint_set     unsort_set, *sort_sets = NULL, *sets = NULL, 
		       mrg_sort_set, *final_set = NULL;

 struct EMSinters	   *inters[2], *inters_ptr = NULL;
 struct EMSsftracedata *trace_info = NULL, *mrg_trace = NULL, 
		       *sort_trace = NULL;
 struct EMSsfintloopsdata *mrg_sflps = NULL, *sort_sflps = NULL, 
			*sflps_info = NULL;

 enum GRdpmode         DisplayMode = GRbd;

 IGRlong               rc, OM_stat, mthd_stat;

 IGRint                i, j, opix, setix, grix, num_sets, num_inters,
                       num_mrg_grps, num_sort_sets = 0,
                       num_sfs_w_ints, num_dispsfs = 0, dispsfids_arrsz, 
                       sgrix;

 GRobjid               *dispsfids = NULL;
 GRspacenum            cur_os;

 IGRushort     inters_opts, outworld_opts, outparam_opts,
                       trim_opts, bool_options;

 IGRboolean            sort_sets_merged = FALSE, sf_int_used, double_chk;

 IGRchar               status_str[54];

 extern IGRlong        EMintersect_surfaces(), 
                       EMboolean_surfaces_w_intersection(),
                       EMsfint_topology_validate();

 extern void           EFsort_intersections();
 extern void           EMsfinttrace_free(), EMinters_free(),
                       EMsfintloops_free ();


 /* ****************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 op2_elems_dataselect = NULL;
 op2_elems_GRid = NULL; 
 sort_sets = NULL;
 cur_os = md_env->md_id.osnum;
 bool_GRid.objid = NULL_OBJID;
 bool_GRid.osnum = cur_os;

 double_chk = options & EMSsfbool_opt_doublecheck;

 /*
  * Get the oriented intersections for the boolean operation
  */

 if (num_op2_elems > OP2_BUF_SIZE)
 {
  op2_elems_dataselect = (struct EMSdataselect *) om$malloc (size = 
            num_op2_elems * sizeof(struct EMSdataselect));
  EMerr_hndlr (!op2_elems_dataselect,*EFmsg,EMS_E_NoDynamicMemory,wrapup);
 
  op2_elems_GRid = (struct GRid *) om$malloc (size = num_op2_elems *
                                               sizeof(struct GRid));
  EMerr_hndlr (!op2_elems_GRid, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
 
 } /* if (num_op2_elems > OP2_BUF_SIZE) */
 else
 {
   op2_elems_dataselect = op2_elems_datmem;
   op2_elems_GRid = op2_elems_GRidmem;
 }

 op1_elem_GRid.objid = op1_elem;
 op1_elem_GRid.osnum = cur_os;

 for (i = 0; i < num_op2_elems; i++)
 {
  op2_elems_dataselect[i].datatype = EMSdata_object;
  op2_elems_dataselect[i].data.object = &op2_elems_GRid[i];
  op2_elems_GRid[i].objid = op2_elems[i];
  op2_elems_GRid[i].osnum = cur_os;

 } /* for (i = 0; i < num_op2_elems; i++) */

/*
 ex$message (msgnumb = EMS_I_Processing, buff = status_str);
 */

 strcpy (status_str, "Processing");

 inters_opts = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
               (bool_type == EMSbool_difference ? 
                             EMS_SFINT_REVERSESECONDINT : NULL) |
               (double_chk ? EMS_SFINT_DOUBLECHECK : NULL);

 outworld_opts = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;

 outparam_opts = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT |
                 (bool_type == EMSbool_intersect ? EMSINT_ORIENT_RIGHT :
                  NULL);

 trim_opts = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA | 
             EMSINT_TRIM_COPLANAR |
             (double_chk ? EMSINT_TRIM_MOREPRECISE |
                           EMSINT_TRIM_PROCOVERLAP  : NULL);

 num_inters = 0;

 for (opix = 0; opix < 2; opix++)
 {
  inters[opix] = NULL;

  trace_info = &unsort_set.trace_data[opix];
  trace_info->num_grps = 0;
  trace_info->num_subgrps_grp = NULL;
  trace_info->num_elems_subgrp = NULL;
  trace_info->elems = NULL;
  trace_info->subgrp_rev = NULL;
  trace_info->elem_rev = NULL;
  trace_info->grp_closed = NULL;
  trace_info->subgrp_closed = NULL;
  
  sflps_info = &unsort_set.sflp_data[opix];
  sflps_info->loop_sf = NULL;
  sflps_info->endedges = NULL;
  sflps_info->intedpars = NULL;
  sflps_info->sfpartolb = NULL;
  sflps_info->sfintloops_alloced = FALSE;
  sflps_info->numedsplit = 0;
  sflps_info->commed_k_exists = TRUE;
  sflps_info->nocommed_k_exists = FALSE;

 } /* for (i = 0; i < 2; i++) */

 OM_stat = EMintersect_surfaces (&rc, &op1_elem_GRid, &md_env->md_env, 
             num_op2_elems, op2_elems_dataselect, &md_env->md_env, 
             inters_opts, outworld_opts, outparam_opts,
             trim_opts, const_list, &num_inters, 
             &inters[EMSoprnd_A], &inters[EMSoprnd_B], 
             &unsort_set.trace_data[EMSoprnd_A],
             &unsort_set.trace_data[EMSoprnd_B], NULL, NULL, 
             status_str);
 EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);
 EMerr_hndlr (!num_inters, *EFmsg, EMS_E_NoIntersection, wrapup);

 unsort_set.trdata_arrsz[0] = unsort_set.trdata_arrsz[1] = 
                             unsort_set.trace_data[0].num_grps;

 /* Validate intersections - Construct a new object if not already passed */

  if(arg_bool_GRid.objid == NULL_OBJID) {
 	OM_stat = om$construct (classid = all_elements_solid ?
              OPP_EMSslboolean_class_id : OPP_EMSsfboolean_class_id,
              osnum = cur_os, p_objid = &bool_GRid.objid);
 	EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
 }
 else 
	bool_GRid.objid = arg_bool_GRid.objid;

 bool_options = EMSsfbool_opt_display | EMSsfbool_opt_noredraw;

 OM_stat = EMsfint_topology_validate (&rc, &const_list->env_info->md_env,
             inters[EMSoprnd_A], inters[EMSoprnd_B],
             &unsort_set.trace_data[EMSoprnd_A],
             &unsort_set.trace_data[EMSoprnd_B], 
             bool_options,
             &unsort_set.sflp_data[EMSoprnd_A], 
             &unsort_set.sflp_data[EMSoprnd_B]);
 if (rc == EMS_E_IntersectClosure) rc = EMS_S_Success;
 EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);

 /*
  * Oriented intersections have been computed. Next step is,
  *  o For each point provided by the user for the portions to be
  *    saved,
  *    o Traverse the skin of the operand on which point is given
  *    o In the process of trversing, pick up all of the new groups
  *      reachable during traversal.
  *  o Once, all of the reachable groups are extracted, use them
  *    only during in boolean operation.
  */


 EFsort_intersections (&rc, inters, &unsort_set, &sort_sets, 
        &num_sort_sets, num_pts, sortpts_info, md_env, cur_os, 
        num_bad_pts, bad_pts_info);

 EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);
 
 if (!num_sort_sets && arg_bool_GRid.objid == NULL_OBJID)
 {
  /*
   * Delete the boolean object constructed above
   */

  *EFmsg = EMS_E_InvalidArg;
  OM_stat = om$send (msg = message Root.delete(1),
                     senderid = NULL_OBJID, 
                     targetid = bool_GRid.objid, 
                     targetos = bool_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  goto wrapup;

 } /* if (!num_sort_sets) */

 if (num_sort_sets > 1)
 {
  sort_sets_merged = TRUE;
  num_mrg_grps = 0;
  for (i = 0; i < num_sort_sets; i++)
   num_mrg_grps += sort_sets[i].trace_data[EMSoprnd_A].num_grps;

  for (opix = 0; opix < 2; opix++)
  {
   /*
    * Allocate space Merged trace data
    */

   mrg_trace = &mrg_sort_set.trace_data[opix];
   mrg_trace->num_grps = num_mrg_grps;

   mrg_trace->num_subgrps_grp = (IGRint *) om$malloc (
                  size = num_mrg_grps * sizeof(IGRint));
   EMerr_hndlr (!mrg_trace->num_grps,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->num_elems_subgrp = (IGRint **) om$malloc (size = 
                  num_mrg_grps * sizeof(IGRint *));
   EMerr_hndlr (!mrg_trace->num_elems_subgrp,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->elems = (struct EMSintobj ***) om$malloc (size = 
               num_mrg_grps * sizeof(struct EMSintobj **));
   EMerr_hndlr (!mrg_trace->elems,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->subgrp_rev = (IGRboolean **) om$malloc (
                     size = num_mrg_grps * sizeof(IGRboolean *));
   EMerr_hndlr (!mrg_trace->subgrp_rev,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->elem_rev = (IGRboolean ***) om$malloc (size = num_mrg_grps *
                                   sizeof(IGRboolean **));
   EMerr_hndlr (!mrg_trace->elem_rev,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->grp_closed = (IGRboolean *) om$malloc (size = num_mrg_grps *
                                         sizeof(IGRboolean));
   EMerr_hndlr (!mrg_trace->grp_closed,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_trace->subgrp_closed = (IGRboolean **) om$malloc (
                   size = num_mrg_grps * sizeof(IGRboolean *));
   EMerr_hndlr (!mrg_trace->subgrp_closed,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   /*
    * Allocate space for sflps data
    */

   mrg_sflps = &mrg_sort_set.sflp_data[opix];

   mrg_sflps->loop_sf = (GRobjid **) om$malloc (size = num_mrg_grps *
                                   sizeof(GRobjid *));
   EMerr_hndlr (!mrg_sflps->loop_sf,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_sflps->endedges = (GRobjid **) om$malloc (size = num_mrg_grps *
                                   sizeof(GRobjid *));
   EMerr_hndlr (!mrg_sflps->endedges,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_sflps->intedpars = (struct EMSsfintedpar ***) om$malloc (
                   size = num_mrg_grps * sizeof(struct EMSsfintedpar **));
   EMerr_hndlr(!mrg_sflps->intedpars,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   mrg_sflps->sfpartolb = (IGRdouble **) om$malloc (size = num_mrg_grps *
                                   sizeof(IGRdouble *));
   EMerr_hndlr(!mrg_sflps->sfpartolb,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   
   grix = 0;

   for (i = 0; i < num_sort_sets; i++)
   {
    sort_trace = &sort_sets[i].trace_data[opix];
    sort_sflps = &sort_sets[i].sflp_data[opix];

    for (j = 0; j < sort_trace->num_grps; j++, grix++)
    {
     /*
      * Merge trace data
      */

     mrg_trace->num_subgrps_grp[grix] = sort_trace->num_subgrps_grp[j];
     mrg_trace->num_elems_subgrp[grix] = sort_trace->num_elems_subgrp[j];
     mrg_trace->elems[grix] = sort_trace->elems[j];
     mrg_trace->subgrp_rev[grix] = sort_trace->subgrp_rev[j];
     mrg_trace->elem_rev[grix] = sort_trace->elem_rev[j];
     mrg_trace->grp_closed[grix] = sort_trace->grp_closed[j];
     mrg_trace->subgrp_closed[grix] = sort_trace->subgrp_closed[j];

     /*
      * merge sflps data
      */
    
     mrg_sflps->loop_sf[grix] = sort_sflps->loop_sf[j];
     mrg_sflps->endedges[grix] = sort_sflps->endedges[j];
     mrg_sflps->intedpars[grix] = sort_sflps->intedpars[j];
     mrg_sflps->sfpartolb[grix] = sort_sflps->sfpartolb[j];

    } /* for (j = 0; j < sort_trace->num_grps; j++, grix++) */

   } /* for (i = 0; i < num_sort_sets; i++) */

  } /* for (opix = 0; opix < 2; opix++) */

 } /* if (num_sort_sets > 1) */

 /*
  * update numedsplit variables in sorted sflp_data
  */

 final_set =  sort_sets_merged ? &mrg_sort_set : &sort_sets[0];

 for (opix = 0; opix < 2; opix++)
 {
  sflps_info = &final_set->sflp_data[opix];
  trace_info = &final_set->trace_data[opix];

  sflps_info->numedsplit = 0;
  sflps_info->sfintloops_alloced = TRUE;
  sflps_info->commed_k_exists = TRUE;
  sflps_info->nocommed_k_exists = FALSE;

  for (grix = 0; grix < trace_info->num_grps; grix++)
  {
   if (!trace_info->subgrp_closed[grix][0])
    sflps_info->numedsplit += (trace_info->num_subgrps_grp[grix] * 2);    

  } /* for (grix = 0; grix < trace_info->num_grps; grix++) */

 } /* for (opix = 0; opix < 2; opix++) */

 /*
  * It may be possible that some of the groups were open even 
  * after validation. The  processing was continued with
  * the hope that the open groups, if any, will be trashed in
  * the sorting process. If there are still one or more open
  * groups in the sorted list, return closure error.
  */

 for (opix = 0; opix < 2; opix++)
 {
  trace_info = &final_set->trace_data[opix];
  for (grix = 0; grix < trace_info->num_grps; grix++)
   if (!trace_info->grp_closed[grix])
   {
     *EFmsg = EMS_E_IntersectClosure;
     goto wrapup;
   }

 } /* for (opix = 0; opix < 2; opix++) */

 /*
  * Boolean processing will erase the surfaces modified and surfaces
  * to be removed. The modified surafces are picked up from inters_list.
  * Since, in this case inters_list will have surafces whose intersections
  * have been removed, they will be unnecessarily erased and will never
  * been redrawn. The following logic is used to decieve the display
  * processing in the boolean operation for not erasing the surfaces
  * whose intersections are thrown out.
  *
  *  1) Add the surfaces whose intersections are in inters_list but
  *      are not used.
  *  2) Set bool_options to EMSsfbool_opt_display | EMSsfbool_opt_noredraw
  *     This will erase the surfaces which have been modified and are not
  *     disp_sfs array. Also, it will not redraw the modified erased
  *     surfaces.
  *  3) After boolean operation is complete, redraw the surfaces whose
  *     intersections have been used. 
  */

 num_sfs_w_ints = 0;
 for (opix = 0; opix < 2; opix++)
 {
  inters_ptr = inters[opix];
  while (inters_ptr)
  {
   num_sfs_w_ints++;
   inters_ptr = inters_ptr->next;
  }

 } /* for (opix = 0; opix < 2; opix++) */

 
 dispsfids_arrsz = num_sfs_w_ints/DPR_DISPLAY_BUFF_INCR;
 if ((dispsfids_arrsz * DPR_DISPLAY_BUFF_INCR) != num_sfs_w_ints)
  dispsfids_arrsz++;
 
 dispsfids = (GRobjid *) om$malloc (size = dispsfids_arrsz *
                            DPR_DISPLAY_BUFF_INCR * sizeof(GRobjid));
 EMerr_hndlr (!dispsfids, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

 for (opix = 0; opix < 2; opix++)
 {
  inters_ptr = inters[opix];
  trace_info = &final_set->trace_data[opix];
  sflps_info = &final_set->sflp_data[opix];

  while (inters_ptr)
  {
   sf_int_used = FALSE;
   
   for (grix = 0; grix < trace_info->num_grps && !sf_int_used; grix++)
   {
    for (sgrix = 0; sgrix < trace_info->num_subgrps_grp[grix] && 
                    !sf_int_used; sgrix++)
    {
      if ( sflps_info->loop_sf[grix][2*sgrix+1] == 
           inters_ptr->this_obj.objid)
       sf_int_used = TRUE;

    } /* for (sgrix = 0; sgrix < trace_info->num_subgrps_grp[grix] && */

   } /* for (grix=0; grix<trace_info->num_grps &&!sf_int_used; grix++) */

   if (!sf_int_used)
    dispsfids[num_dispsfs++] = inters_ptr->this_obj.objid;

   inters_ptr = inters_ptr->next;

  } /* while (inters_ptr) */

 } /* for (opix = 0; opix < 2; opix++) */

 /*
  * Resume Boolean operation
  */
  

 OM_stat = EMboolean_surfaces_w_intersection (&rc, &bool_GRid, bool_type,
             const_list->env_info, op1_elem, num_op2_elems, op2_elems,
             inters[EMSoprnd_A], inters[EMSoprnd_B],
             &final_set->trace_data[EMSoprnd_A],
             &final_set->trace_data[EMSoprnd_B],
             &final_set->sflp_data[EMSoprnd_A], 
             &final_set->sflp_data[EMSoprnd_B],
             bool_options, &num_dispsfs, &dispsfids, status_str);
 EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);
 
/*
 * Redraw the surafces which have been modified.
 */

 for (opix = 0; opix < 2; opix++)
 {
  inters_ptr = inters[opix];
  trace_info = &final_set->trace_data[opix];
  sflps_info = &final_set->sflp_data[opix];

  while (inters_ptr)
  {
   sf_int_used = FALSE;
   
   for (grix = 0; grix < trace_info->num_grps && !sf_int_used; grix++)
   {
    for (sgrix = 0; sgrix < trace_info->num_subgrps_grp[grix] && 
                    !sf_int_used; sgrix++)
    {
      if ( sflps_info->loop_sf[grix][2*sgrix+1] == 
           inters_ptr->this_obj.objid)
       sf_int_used = TRUE;

    } /* for (sgrix = 0; sgrix < trace_info->num_subgrps_grp[grix] && */

   } /* for (grix=0; grix<trace_info->num_grps &&!sf_int_used; grix++) */

   if (sf_int_used)
   {
    OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                        &const_list->env_info->md_env.matrix_type,
                        const_list->env_info->md_env.matrix,
                        &DisplayMode,
                        &const_list->env_info->md_id),
                       senderid = NULL_OBJID,
                       targetid = inters_ptr->this_obj.objid,
                       targetos = inters_ptr->this_obj.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

   } /* if (sf_int_used) */

   inters_ptr = inters_ptr->next;

  } /* while (inters_ptr) */

 } /* for (opix = 0; opix < 2; opix++) */

wrapup:
 
 if (dispsfids) om$dealloc (ptr = dispsfids);

 /*
  * o Free unsorted sets trace info.
  * o If a sort_sets and mrg_sort_set arrays
  */

 for (opix = 0; opix < 2; opix++)
 {
  trace_info = &unsort_set.trace_data[opix];
  EMsfinttrace_free (&rc, trace_info->num_grps, 
      trace_info->num_subgrps_grp, trace_info->num_elems_subgrp, 
      trace_info->elems, trace_info->subgrp_rev, trace_info->elem_rev,
      trace_info->grp_closed, trace_info->subgrp_closed);

  sflps_info = &unsort_set.sflp_data[opix];

  EMsfintloops_free (sflps_info->loop_sf, sflps_info->endedges, 
                    sflps_info->intedpars, sflps_info->sfpartolb);
 } /* for (opix = 0; opix < 2; opix++) */


 for (i = 0; i < 2; i++)
 {
  if (i)
  {
   num_sets = num_sort_sets;
   sets = sort_sets;
  }
  else
  {
   num_sets = sort_sets_merged ? 1 : 0;
   sets = &mrg_sort_set;
  }
  
  if (num_sets)
  {
   for (setix = 0; setix < num_sets; setix++)
   {
    for (opix = 0; opix < 2; opix++)
    { 
    trace_info = &sets[setix].trace_data[opix];
    sflps_info = &sets[setix].sflp_data[opix];

    if (i)        /* free sort_sets */
    {
     EMsfinttrace_free (&rc, trace_info->num_grps, 
      trace_info->num_subgrps_grp, trace_info->num_elems_subgrp, 
      trace_info->elems, trace_info->subgrp_rev, trace_info->elem_rev,
      trace_info->grp_closed, trace_info->subgrp_closed);
    }
    else
    {                       /* free mrg_sort_set */
     if (trace_info->num_subgrps_grp) 
        om$dealloc (ptr = trace_info->num_subgrps_grp);
     if (trace_info->num_elems_subgrp)
       om$dealloc (ptr = trace_info->num_elems_subgrp);
     if (trace_info->elems) om$dealloc (ptr = trace_info->elems);
     if (trace_info->subgrp_rev) om$dealloc (ptr= trace_info->subgrp_rev);
     if (trace_info->elem_rev) om$dealloc (ptr = trace_info->elem_rev);
     if (trace_info->grp_closed) om$dealloc (ptr= trace_info->grp_closed);
     if (trace_info->subgrp_closed) 
          om$dealloc (ptr = trace_info->subgrp_closed);
    }

    if (sflps_info->loop_sf) om$dealloc (ptr = sflps_info->loop_sf);
    if (sflps_info->endedges) om$dealloc (ptr = sflps_info->endedges);
    if (sflps_info->intedpars) om$dealloc (ptr = sflps_info->intedpars);
    if (sflps_info->sfpartolb) om$dealloc (ptr = sflps_info->sfpartolb);

    } /* for (opix = 0; opix < 2; opix++) */

   } /* for (setix = 0; setix < num_sort_sets; setix++) */
 
  } /* if (num_sets) */
 } /* for (i = 0; i < 2; i++) */

 if (sort_sets) om$dealloc (ptr = sort_sets);

  
 /*
  * Free inters link list
  */

 for (opix = 0; opix < 2; opix++)
  EMinters_free(inters[opix], MAXINT);

 if (num_op2_elems > OP2_BUF_SIZE)
 {
  if (op2_elems_dataselect) om$dealloc (ptr = op2_elems_dataselect);
  if (op2_elems_GRid) om$dealloc (ptr = op2_elems_GRid);

 } /* if (num_op2_elems > OP2_BUF_SIZE) */
 
 /*
  * If the error is non_fatal and the double_check option has not
  * been used, redo the processing using double_checking algorithm.
  */

 if (EMSerror (*EFmsg) && EMS_SeverityLevel (*EFmsg) != FATL && 
     (*EFmsg) != EMS_E_InvalidArg && !double_chk)
  {
   EFperform_special_boolean_mod(&rc, md_env, op1_elem,
            	num_op2_elems, op2_elems, all_elements_solid, const_list, 
            	bool_type, num_pts, sortpts_info, 
          	options | EMSsfbool_opt_doublecheck, num_bad_pts, 
		bad_pts_info, arg_bool_GRid);
  }
 else
  {
   EMWRAPUP (*EFmsg, OM_stat, "EFperform_special_boolean_mod");
  }

 return; 

} /* void EFperform_special_boolean_mod() */



end implementation EMSsfboolean;
