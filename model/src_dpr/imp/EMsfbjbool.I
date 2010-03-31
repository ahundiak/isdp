/*
  DESCRIPTION

    The method accepts an EMSsurface object - A, and a set of EMSsurface
    objects - B and performs the requested Boolean operation between them.
    The boundaries of the comprising surfaces are modified to reflect the
    Boolean operation. The surfaces of the two operands will be joined
    along the intersections that occur between. The resulting object after
    this operation is this EMSsfboolean object itself, which will own A and B
    on it's child-channel. 

  RETURN VALUES
  
    Upon exit the completion code will be one of the following

      When the option to handle the STOP-interrupt is set and there has
      been an interrupt the return code is
  
      - EMS_I_Interrupt
         the result is incomplete

      When the operation was successful or could not be completed due
      to the non-intersection between A and B.

      - EMS_S_Success 
          if succeeded

      - EMS_I_NoIntersection
          if no intersections were found

      In all of the following errors a recovery operation succeeded
      and the two input solids are still intact and reusable. The method
      invocation has behaved essentially like a noop.

      - EMS_E_IntersectClosure
          the intersection curves, after performing a trace on them, still
          do not close in model-space, and the option for acceptability
          of open intersections is not on.
      - EMS_E_IntersClosureOrient
          the intersection curves do not close in model-space and this could
          possibly be due to rejection of intersections at tangencies,
          and the option for acceptability of open intersections is not on.

      - EMS_E_IntersectOrient
          the parametric intersection curves are not oriented correctly
          for the Boolean operation to proceed.

      - EMS_E_IntersectTrim
          the trimming of the surface intersection curves was incorrect
          in some way.
      - EMS_E_Intersect
          if the failure occurred due to bad intersection result, but
          the error cannot be pinpointed.

      - EMS_E_Fail
          Most probably a failure in a call to a math-function.
          In some cases the reason for failure was not understood in greater
          detail. 

      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.

      - EMS_E_SurfaceError
          if a failure occurred when a call to a surface method was
          made.
      - EMS_E_LoopsetError
          if a failure occurred when a call to a surface-loopset method was
          made.
      - EMS_E_LoopError
          if a failure occurred when a call to a surface-loop method was
          made.
      - EMS_E_EdgeError
          if a failure occurred when a call to a surface-edge method was
          made.
      - EMS_E_OMError
          if a failure occurred when a call to an OM-primitive was
          made or,
          a failure on invocation of a method on some object.

      - EMS_E_InvalidArg 
          if the input argument list was invalid, ie, the construction list
          specifies an object space that is not the current one.

      A catastrophic failure has occurred. The input objects' topology
      has gotten corrupted.

      - EMS_F_Fail
          If an error occurred and the recovery was not possible or failed,
          the solids have possibility been destroyed beyond recovery.

  HISTORY

    NP  :  05/19/92  : Added calls to "timer" functions for timing the code.
    SS  :  11/14/89  : Added the push-bad-coincidence edges option to
                       surface-intersection call.
    SS  :  09/17/89  : Handling of the STOP-interrupt
    SS  :  06/07/89  : Broke up this method into two basic calls -
                       i) Function that performs the intersection
                       (formerly stages 1 and 2),
                       ii) Function which accepts this intersection
                       and completes the Boolean operation (formerly
                       stages 3 - 7 1/2).
    DLB :  11/03/87  : Modified for version 1.1.0
    SS  :  03/01/87  : Creation
*/

class implementation EMSsfboolean;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "timerdef.h"
#include "EMSsffmacros.h"  
#include "EMStpmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

#define NUM_SFS2_STATIC 5

extern IGRboolean _use_timers;
extern IGRboolean _Pathway, _pathway_trim, _pathway_orient;

method EMjoiningBoolean (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                         GRobjid sf1; IGRint num_sfs2; GRobjid *sfs2; 
                         struct GRvg_construct *const_args;
                         enum EMSbooltype bool_type; IGRushort options;
                         IGRchar *status_str; GRobjid *intobj, *auxobj;
                         GRobjid **display_ids; IGRint *display_count)
{
  IGRboolean double_chk, op_switch,openint_valid, single_topology, no_topology;
  IGRboolean output_intersection, output_aux, handle_stop, status; 
  IGRchar *loc_status_str, status_str_mem[MS_MAX_MSG_LENGTH+1];
  IGRushort inters_opt, outworld_opt, outparam_opt, trim_opt;
  IGRint i, opinx, num_inters;
  IGRlong msg_loc, stat_OM;
  struct GRmd_env sfmdenv;
  struct EMSinters *inters[2];
  struct EMSdataselect *sfs2data, sfs2datamem[NUM_SFS2_STATIC];
  struct GRid my_GRid, sf1id, *sfs2id, sfs2idmem[NUM_SFS2_STATIC];
  struct EMSsftracedata sftrace[2];
  extern void EMsfintedpar_free();
  IGRboolean is_pathway_on=FALSE;
  IGRdouble cht_tol;
  static IGRboolean refined_tolerance = FALSE;

  if (_use_timers)
    start_timer (T_EMJOININGBOOLEAN);

  is_pathway_on = (_Pathway && _pathway_trim && _pathway_orient);
   
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize pointers, variables, etc.
   */

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    inters[opinx] = NULL;
    sftrace[opinx].num_grps = 0;
    sftrace[opinx].num_subgrps_grp = NULL;
    sftrace[opinx].num_elems_subgrp = NULL;
    sftrace[opinx].elems = NULL;
    sftrace[opinx].subgrp_rev = NULL;
    sftrace[opinx].elem_rev = NULL;
    sftrace[opinx].grp_closed = NULL;
    sftrace[opinx].subgrp_closed = NULL;
    }
  sfs2data = NULL;
  sfs2id = NULL;

  double_chk = options & EMSsfbool_opt_doublecheck;
  op_switch = options & EMSsfbool_opt_OperandsSwitched;
  openint_valid = options & EMSsfbool_opt_OpenIntPossible;
  single_topology = options & EMSsfbool_opt_SingleTopology;
  output_intersection = options & EMSsfbool_opt_outinters;
  output_aux = options & EMSsfbool_opt_outaux;
  if (output_intersection || output_aux)
    no_topology = TRUE;
  else
    no_topology = FALSE;
  handle_stop = options & EMSsfbool_opt_HandleStop;

  if (status_str)
    {
    strcpy (status_str_mem, status_str);
    loc_status_str = status_str_mem;
    }
  else
    loc_status_str = NULL;

  /*
   * The two input solids and the objects that get constructed towards
   * the Boolean operation, should also exist in the current object space.
   */

  EMerr_hndlr (const_args->env_info->md_id.osnum != OM_Gw_current_OS, *msg,
   EMS_E_InvalidArg, ret_end);



  /*
   * STAGE 1:
   * Obtain the trimmed intersection of the two input solids, requesting
   * parametric as well as world coordinate intersection curves to be
   * output. The orientation of the parametric curves, being returned as
   * surface boundary edges, is determined by the type of Boolean operation
   * being performed. Set the options for surface-surface intersection,
   * based on these considerations. There must be an intersection between
   * sf1 and each element of sfs2. If open-groups are not explicitly indicated
   * to be valid, any open groups are treated as invalid. The intersections
   * must be oriented correctly. If only the topology on the first element
   * is to be altered, inhibit the generation of the second element's
   * intersection.
   */

  sfmdenv.md_env.matrix_type = *mattyp;
  OM_BLOCK_MOVE (mat, sfmdenv.md_env.matrix, sizeof (IGRmatrix));

  sf1id.objid = sf1;
  sf1id.osnum = OM_Gw_current_OS;

  if (num_sfs2 > NUM_SFS2_STATIC)
    {
    sfs2data = (struct EMSdataselect *) om$malloc (size = num_sfs2 *
                sizeof (struct EMSdataselect));
    sfs2id = (struct GRid *) om$malloc (size = num_sfs2 * 
              sizeof (struct GRid));
    }
  else
    {
    sfs2data = sfs2datamem;
    sfs2id = sfs2idmem;
    }
  EMerr_hndlr (!sfs2data || !sfs2id, *msg, EMS_E_NoDynamicMemory, ret_end);
  for (i=0; i<num_sfs2; i++)
    {
    sfs2id[i].objid = sfs2[i];
    sfs2id[i].osnum = OM_Gw_current_OS;
    sfs2data[i].datatype = EMSdata_object;
    sfs2data[i].data.object = &sfs2id[i];
    }  

  outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
  outparam_opt = EMSINT_OUTPUT_PARAM | 
                 EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT | 
                 (bool_type == EMSbool_intersect ? EMSINT_ORIENT_RIGHT : NULL);
  trim_opt = EMSINT_TRIM_OUTPUT |
             EMSINT_TRIM_BDRYISAREA |
             EMSINT_TRIM_COPLANAR |
             (double_chk ? EMSINT_TRIM_MOREPRECISE | EMSINT_TRIM_PROCOVERLAP :
                           NULL) |
             (bool_type == EMSbool_intersect ? EMSINT_TRIM_ONLYCUTTING : 
                           NULL);
  inters_opt = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
                EMS_SFINT_PUSHBADCOINC |
                (bool_type == EMSbool_difference ||
                 bool_type == EMSbool_saveside ? 
                  EMS_SFINT_REVERSESECONDINT : NULL) |
                (double_chk ? NULL : 
                 (!is_pathway_on ? EMS_SFINT_MUSTNOAMBIGUOUS : NULL)) |
                (openint_valid ? NULL : EMS_SFINT_MUSTCLOSE) |
                (double_chk ? EMS_SFINT_DOUBLECHECK : NULL) |
                (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

  num_inters = 0;
  stat_OM = ems$intersect_surfaces(msg = msg,
             surface1 = &sf1id, surface1env = &sfmdenv.md_env,
             numsurfaces2 = num_sfs2, surfaces2 = sfs2data,
             surfaces2env = &sfmdenv.md_env,
             inters_opts = inters_opt, world_opts = outworld_opt,
             param_opts = outparam_opt, trim_opts = trim_opt,
             construction_args = const_args,
             num_inters = &num_inters,
             surface1_inters = no_topology ? NULL : &inters[FIRST],
             surfaces2_inters = no_topology || single_topology ? 
                                 NULL : &inters[SECOND], 
             surface1_tracedata = no_topology ? NULL : &sftrace[FIRST],
             surfaces2_tracedata = no_topology || single_topology ?
                                    NULL : &sftrace[SECOND],
            inters_outputobj = output_intersection ? intobj : NULL,
            inters_endptsobj = output_aux ? auxobj : NULL,
            status_str = loc_status_str);
  if (*msg == EMS_E_NoIntersection)
    {
    *msg = EMS_I_NoIntersection;
    stat_OM = OM_S_SUCCESS;
    goto ret_end;
    }
  EMomerr_exit (*msg & stat_OM, ret_end);
  if (*msg == EMS_I_Interrupt || no_topology)
    goto ret_end;

  /*
   * STAGE 2:
   * Using the intersection data and the trace information for this
   * intersection data, invoke the Boolean function to complete the
   * Boolean.
   */

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  sfmdenv.md_id = const_args->env_info->md_id;
  stat_OM = ems$boolean_surfaces_w_intersection (msg = msg,
             booleanid = &my_GRid,
             booleanopts = bool_type,
             mdenv = const_args->env_info,
             surface1 = sf1,
             numsurfaces2 = num_sfs2, surfaces2 = sfs2,
             surface1_inters = inters[FIRST],
             surfaces2_inters = inters[SECOND],
             surface1_tracedata = &sftrace[FIRST],
             surfaces2_tracedata = &sftrace[SECOND],
             opts = options,
             num_dispsfs = display_count,
             dispsfids = display_ids,
             status_str = loc_status_str);  
  EMomerr_exit (*msg & stat_OM, ret_end);
  if (*msg == EMS_I_Interrupt)
    goto ret_end;

ret_end:
  /*
   * Free up the dynamic memory used for this
   * method.
   */

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    ems$inters_data_free (msg = &msg_loc, inters_list = inters[opinx],
     num_nodes = MAXINT,
     userdfnd_func_to_free_intobj_moreinfo = EMsfintedpar_free);
    ems$inters_free (inters_list = inters[opinx], num_nodes = MAXINT);
    ems$sfinttrace_free (msg = &msg_loc, num_grps = sftrace[opinx].num_grps,
     num_subgrps_grp = sftrace[opinx].num_subgrps_grp,
     num_elems_subgrp = sftrace[opinx].num_elems_subgrp,
     elems = (IGRchar ***)sftrace[opinx].elems, 
     subgrp_rev = sftrace[opinx].subgrp_rev,
     elem_rev = sftrace[opinx].elem_rev,
     grp_closed = sftrace[opinx].grp_closed,
     subgrp_closed = sftrace[opinx].subgrp_closed);   
     }
  if (sfs2id && sfs2id != sfs2idmem)
    om$dealloc (ptr = sfs2id);
  if (sfs2data && sfs2data != sfs2datamem)
    om$dealloc (ptr = sfs2data);

  if (double_chk)
    {
    /* 
     * If failure occured during double check, try switching the operands
     * if the operation was union or intersection.
     */

    if ((EMSerror(*msg)) && (EMS_SeverityLevel(*msg) != FATL) && 
        (!op_switch) && (num_sfs2 == 1) && !is_pathway_on &&
        ((bool_type == EMSbool_intersect) || (bool_type == EMSbool_union)))
     {
      if (status_str)
       {
        strcpy (status_str_mem, status_str);
        loc_status_str = status_str_mem;
       }
      else
        loc_status_str = NULL;

      stat_OM = om$send (msg = message EMSsfboolean.EMjoiningBoolean (msg,
                mattyp, mat, *sfs2, num_sfs2, &sf1, const_args, bool_type,
                options | EMSsfbool_opt_OperandsSwitched, loc_status_str,
                intobj, auxobj, display_ids, display_count), targetid = my_id);
     }

    EMWRAPUP (*msg, stat_OM, "EMSsfboolean.EMjoiningBoolean");
    }

  /*
   * On a non-fatal failure and the double-check option not being set, proceed
   * to call this method recursively with the double-check option set. This,
   * in the hope of better performance with the double-checking algorithm.
   */

  if (EMSerror (*msg) && EMS_SeverityLevel (*msg) != FATL && !double_chk &&
      (!is_pathway_on))
	{
	/* Try checking by varying tolenrance to 0.0001 if it is 0.001   */
	BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);	
	if(cht_tol == 0.001 && bool_type == EMSbool_difference)
	{
		cht_tol = cht_tol/10.0;
		status = BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);
		refined_tolerance = TRUE;
     stat_OM = om$send (msg = message EMSsfboolean.EMjoiningBoolean (msg,
               mattyp, mat, sf1, num_sfs2, sfs2, const_args, bool_type,
               options, loc_status_str, intobj, auxobj, display_ids, 
		display_count), targetid = my_id);

		cht_tol = cht_tol*10.0;
		status = BSchangepar(&msg_loc, BSTOLCHRDHT, cht_tol);

		if(!(EMSerror(*msg))) {
					refined_tolerance = FALSE;	
					return(stat_OM);
				       }
	}
	if(!(refined_tolerance))
    stat_OM = om$send (msg = message EMSsfboolean.EMjoiningBoolean (msg,
               mattyp, mat, sf1, num_sfs2, sfs2, const_args, bool_type,
               options | EMSsfbool_opt_doublecheck, loc_status_str,
               intobj, auxobj, display_ids, display_count), targetid = my_id);
	}

  if (EMS_SeverityLevel (*msg) == FATL)
    {
	if(refined_tolerance) {
		refined_tolerance = FALSE;
		return(stat_OM);
			      }
    else EMWRAPUP (*msg, stat_OM, "EMSsfboolean.EMjoiningBoolean");
    }

  if (_use_timers)
    stop_timer  (T_EMJOININGBOOLEAN, FALSE, "");

  return (stat_OM);
}

end implementation EMSsfboolean;
