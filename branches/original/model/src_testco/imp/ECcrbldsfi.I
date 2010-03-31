class implementation ECcrbldsf;

/*
Abstract
    This is the command object for manual mode rounding.

History 
    JSY	12/10/92	Creation.
    scw 08/14/94        clarified sleep method
*/

#include "EMS.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EMSasmacros.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "bsmalloc.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "msdef.h"
#include "comndef.h"
#include "grmacros.h"
#include "grdpbmacros.h"
#include "grmessage.h"
#include "adpdef.h"
#include "alloca.h"
#include "FI.h"

/* form constants */
#define STAT_FM 100
#define SAVE_CHANGE 1
#define NO_CHANGE 4
#define DEF_MIN1 18
#define DEF_MAX1 13
#define DEF_MIN2 19
#define DEF_MAX2 17
#define SLIDER1 12
#define SLIDER2 14

/* state number definition */
#define BEGIN 0
#define LOCATE_SOLID 1
#define LOCATE_FILLET 2
#define INIT_PROC_CUTBACK_CV 3
#define SPECIFY_CUTBACK_ISOCV 4
#define SPECIFY_CUTBACK_PLANECUT_PT 5
#define SPECIFY_CUTBACK_PLANECUT_CV 6
#define INIT_PROC_BLEND_CV 7
#define SPECIFY_BLEND_CV 8
#define SPECIFY_PT_ON_EDGE 9
#define VALIDATE_BLEND_CV 10
#define PROCESS_BLEND_SF 11
#define ACC_REJECT_RESULT 12

/* constants used in dynamics */
#define U_DIRECTION 1
#define V_DIRECTION 2
#define DYN_SUCCESS 0
#define DYN_BOUNDARY 1
#define DYN_NO_MEMORY 2
#define DYN_NO_INTERSECTION 3
#define DYN_OUT_SURFACE 4
#define DYN_NO_PROJECTION 5
#define DYN_SUCC_FIND_PT 6
#define DYN_SUCC_FIND_EDGE 7
#define DYN_NOT_FIND 8

#define ISOCV 1
#define PLANECUT 2
#define PLANECUT_PT 3
#define BOUNDARY 4
#define BLENDCV 5
#define PTON_EDGE 6

#define FIND_CLOSEST_SURF 0
#define NO_CLOSEST_SURF 1
#define MORE_THAN_ONE_CLOSEST_SURF 2

#define SPL_PT_TO_SPL_PT 1
#define SPL_PT_TO_EDGE_PT 2

/* return codes for routine EMnat_u_edge */
#define MULTIPLE_EDGES_ON_U0 1
#define MULTIPLE_EDGES_ON_U1 2

#define EMomerr_exit(sts, label) if (EMSerror(sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id,
                 OPP_EMSsurface_class_id,
                 OPP_EMScompsurf_class_id,
                 OPP_EMSsolid_class_id,
 		 OPP_GR3dpoint_class_id;

from EMSsurface import EMgetedges, EMcrvsrfint;
from EMSedge import EMendpts, EMget_props, EMget_bcxyz_geom, EMgetsurface_info;
from EMSloopset import EMlsparttrim;
from GRcurve import GRendpts;
from GRvg import GRgetsymb, GRpostabsg;
from GRgraphics import GRgetrang, GRconstruct, GRdelete, GRcopy, GRptproject;

/*
 * This structure is used as an argument to the action-handler
 * called within the 'do_locate' method.
 */
struct locate_acthndlr_args
{
  IGRushort options;
  IGRchar *loc_prompt, *acc_prompt, *reloc_prompt;
  IGRint numelems;
  struct GRlc_info *elems;
  OM_S_CLASSLIST nelig_classes;
};

/*
 * This structure is used as an argument to the action-handler
 * called within this command's execute method.
 */
struct open_surf_hndlr_args
{
  struct GRid *solid;
  struct GRmd_env *env;
  struct locate_acthndlr_args actargs;
};

method init(IGRint type; IGRchar *strptr)
{
  IGRdouble gd_val;
  IGRlong sts = OM_S_SUCCESS;
  extern void ECcrbldsf_process_fm();

  sts = om$send(msg = message ECelements.init(type, strptr),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  sts = FIf_new(STAT_FM, "EMBlendSurf", ECcrbldsf_process_fm, &me->stat_fm);
  if (sts != FI_SUCCESS)
    return OM_E_ABORT;
  sts = FIf_set_cmd_oid_os(me->stat_fm, my_id, OM_Gw_current_OS);
  if (sts != FI_SUCCESS)
    return OM_E_ABORT;
  FIg_get_value(me->stat_fm, SLIDER1, &gd_val);
  me->fm_ratio1 = (IGRint) gd_val;
  FIg_get_value(me->stat_fm, SLIDER2, &gd_val);
  me->fm_ratio2 = (IGRint) gd_val;

  me->form_displayed = FALSE;
  me->num_solid = 0;
  
  return OM_S_SUCCESS;
}

method wakeup(IGRint pos)
{
  IGRint i;
  IGRlong sts, msg;
  extern IGRint EFdisplay_isocv(), EFdisplay_plncutcv();
  extern void EFdisplay_bspcv();

  sts = OM_S_SUCCESS;

  sts = om$send(msg = message ECelements.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (me->form_displayed)
    FIf_display(me->stat_fm);

  switch (ME.super_cmd->state)
  {
  case LOCATE_FILLET:
  case INIT_PROC_CUTBACK_CV:
  case SPECIFY_CUTBACK_ISOCV:
  case SPECIFY_CUTBACK_PLANECUT_PT:
  case SPECIFY_CUTBACK_PLANECUT_CV:
  case INIT_PROC_BLEND_CV:
  case SPECIFY_BLEND_CV:
  case SPECIFY_PT_ON_EDGE:
  case PROCESS_BLEND_SF:
    for (i = 0; i < me->num_solid; i++)
      gr$display_object(object_id = &me->solids[i].located_obj,
			mode = GRhhd);

    switch (ME.super_cmd->state)
    {
    case INIT_PROC_CUTBACK_CV:
    case SPECIFY_CUTBACK_ISOCV:
    case SPECIFY_CUTBACK_PLANECUT_PT:
    case SPECIFY_CUTBACK_PLANECUT_CV:
    case INIT_PROC_BLEND_CV:
    case SPECIFY_BLEND_CV:
    case SPECIFY_PT_ON_EDGE:
    case PROCESS_BLEND_SF:
      for (i = 0; i < me->num_elems; i++)
	gr$display_object(object_id = &me->elems[i].located_obj,
			  mode = GRhhd);

      switch (ME.super_cmd->state)
      {
      case SPECIFY_CUTBACK_ISOCV:
      case SPECIFY_CUTBACK_PLANECUT_PT:
      case SPECIFY_CUTBACK_PLANECUT_CV:
      case INIT_PROC_BLEND_CV:
      case SPECIFY_BLEND_CV:
      case SPECIFY_PT_ON_EDGE:
      case PROCESS_BLEND_SF:
	for (i = 0; i < me->curr_flt; i++)
	  if (me->cutback_cvs[i].type == ISOCV)
	    EFdisplay_isocv(&msg,
			    NULL,
			    &me->elems[i],
			    V_DIRECTION,
			    me->cutback_cvs[i].cutcv.isocv_parm,
			    &me->active_display,
			    GRbd);
	  else if (me->cutback_cvs[i].type == PLANECUT)
	    EFdisplay_plncutcv(&msg,
			       NULL,
			       &me->elems[i],
			       me->cutback_cvs[i].midpt,
			       me->cutback_cvs[i].cutcv.cutpln.normal,
			       &me->active_display,
			       GRbd);

	switch (ME.super_cmd->state)
	{
	case INIT_PROC_BLEND_CV:
	case SPECIFY_BLEND_CV:
	case SPECIFY_PT_ON_EDGE:
	case PROCESS_BLEND_SF:
	  for (i = 0; i < me->curr_pnt_index; i++)
	    gr$display_object(object_id = &me->spl_pts[i].pt_id,
			      mode = GRbd);

	  switch (ME.super_cmd->state)
	  {
	  case SPECIFY_BLEND_CV:
	  case SPECIFY_PT_ON_EDGE:
	  case PROCESS_BLEND_SF:
	    for (i = 0; i < me->curr_blend_index; i++)
	      EFdisplay_bspcv(me->blend_cvs[i].bspcv, &me->active_display, GRbd);
	    break;
	  default:
	    break;
	  }
	  break;
	default:
	  break;
	}
	break;
      default:
	break;
      }
      break;
    default:
      break;
    }
    break;
  default:
    break;
  }
  
  return sts;
}

method super_cmd.sleep(IGRint pos)
{
  IGRlong sts;

  sts = OM_S_SUCCESS;

  sts = om$send(msg = message ECelements.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  GRstatus_display_button(0);
  if (me->form_displayed)
    FIf_erase(me->stat_fm);

  return sts;
}

method delete(IGRint defer_flag)
{
  IGRlong sts;
  
  sts = OM_S_SUCCESS;
  
  sts = om$send(msg = message ECelements.delete(defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (me->stat_fm)
    FIf_delete(me->stat_fm);

  return sts;
}

method execute(IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRdouble tolr;
  GRclassid r_classmem[2], e_classmem[2], ne_classmem[2];
  OM_S_CLASSLIST rtree_classes, elig_classes, nelig_classes;
  IGRushort geomprops, options;
  IGRshort operation;
  IGRboolean loop = TRUE;
  char elem_type[GR_MAX_CHAR], msg1[GR_MAX_CHAR], msg2[GR_MAX_CHAR];
  enum EMSuser_responses useract;
  struct GRevent acc_event;
  IGRlong event_mask;
  IGRint num_minbnd_edges, num_maxbnd_edges, curr_edge_index;
  IGRint u_or_v, vla_size, i, j;
  IGRboolean finish = FALSE;
  struct GRid *minbnd_edges, *maxbnd_edges, *spl_edge;
  struct GRid closest_surf, closest_surf1, closest_surf2, co_edge_id;
  struct FilletBnd *curr_bnd;
  struct CutBack *curr_cb;
  struct SpecialPnt *curr_sp;
  struct IGRbsp_curve *bspcv;
  struct BlendCv *curr_bcv;
  struct GRmd_env pt_env;
  OM_S_CHANSELECT edge_chan;
  OM_S_OBJECT_LINKAGE edge_link;
  OMuint edge_count;
  IGRlong sts, msg;
  extern IGRlong EMget_the_geometry(), EFpoint_on_object();
  extern void BSsfarrevn(), EFdisplay_bspcv();
  extern IGRboolean BSmkvec(), BScrossp(), BSfreecv();
  extern IGRint EMcheck_nonclose_fillet();
  extern IGRint EFdisplay_isocv(), EFdisplay_plncutcv();
  extern IGRint EMget_bnd_parms(), EMnat_u_edges();
  extern IGRint EMget_closest_surf_along_direction();
  extern IGRdouble BSdistptpt();

  ex$message(field = MESSAGE_FIELD, msgnumb = EM_M_PlaceBlndBtFilSrfs);
  event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART;

  memcpy(&pt_env, &me->active_md_env, sizeof(struct GRmd_env));
  pt_env.md_id.objid = NULL_OBJID;

  /* enter infinite loop */
  do
  {
    switch (ME.super_cmd->state)
    {
    case BEGIN:
      ME.super_cmd->state = LOCATE_SOLID;
      break;

    case LOCATE_SOLID:
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;
      r_classmem[0] = OPP_EMSsurface_class_id;

      elig_classes.w_count = 1;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;
      e_classmem[0] = OPP_EMSsurface_class_id;

      nelig_classes.w_count = 0;
      nelig_classes.w_flags = OM_CLST_subclass;
      nelig_classes.p_classes = ne_classmem;

      geomprops = NULL;
      operation = EC_GEOM_READ;
      options = EC_LOC_APPENDOBJNUM;

      sts = om$send(msg = message ECelements.set_locate_criteria(&msg,
								 MAXNUM_RESTRICTIVE_CLASSES-1,
								 &rtree_classes,
								 &elig_classes,
								 &nelig_classes,
								 geomprops,
								 operation,
								 options,
								 1,
								 MAXINT),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      ex$message(msgnumb = EMS_P_SolidSurf, buff = elem_type);
      strcpy(msg2, " ");
      strcat(msg2, elem_type);
      ME.ECelements->locobj_hndlr = NULL;
      sts = om$send(msg = message ECelements.do_locate(&msg,
						       &useract,
						       response,
						       response_data,
						       elem_type,
						       NULL,
						       NULL,
						       msg2,
						       NULL,
						       NULL),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      if (useract == EMSuser_moveon)
      {
	if (me->num_elems == 0)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	  ME.super_cmd->state = LOCATE_SOLID;
	}
	else
	{
	  me->num_solid = me->num_elems;
	  vla_size = om$dimension_of(varray = me->solids);
	  if (me->num_solid > vla_size)
	  {
	    sts = om$vla_set_dimension(varray = me->solids,
				       size = me->num_solid);
	    EMomerr_exit(sts, quit);
	  }
	  memcpy(me->solids, me->elems, me->num_solid * sizeof(struct GRlc_info));

	  ME.super_cmd->state = LOCATE_FILLET;
	}
      }
      else if (useract == EMSuser_backup)
      {
	for (i = 0; i < me->num_solid; i++)
	  gr$display_object(object_id = &me->solids[i].located_obj,
			    mode = GRhe);
	ME.super_cmd->state = LOCATE_SOLID;
      }
      else 
	goto quit;
      break;

    case LOCATE_FILLET:
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;
      r_classmem[0] = OPP_EMSsubbs_class_id;

      elig_classes.w_count = 1;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;
      e_classmem[0] = OPP_EMSsubbs_class_id;

      nelig_classes.w_count = 0;
      nelig_classes.w_flags = OM_CLST_subclass;
      nelig_classes.p_classes = ne_classmem;

      geomprops = NULL;
      operation = EC_GEOM_READ;
      options = EC_LOC_PROJLOCPT | EC_LOC_APPENDOBJNUM;

      sts = om$send(msg = message ECelements.set_locate_criteria(&msg,
								 MAXNUM_RESTRICTIVE_CLASSES-1,
								 &rtree_classes,
								 &elig_classes,
								 &nelig_classes,
								 geomprops,
								 operation,
								 options,
								 1,
								 MAXINT),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      strcpy(msg1, " ");
      ex$message(msgnumb = EMS_P_NearBlndCorner, buff = elem_type);
      strcat(msg1, elem_type);

      strcpy(msg2, " ");
      ex$message(msgnumb = EMS_P_Fl, buff = elem_type);
      strcat(msg2, elem_type);
      ex$message(msgnumb = EMS_P_NearBlndCorner, buff = elem_type);
      strcat(msg2, elem_type);

      ex$message(msgnumb = EMS_P_Fl, buff = elem_type);

      ME.ECelements->locobj_hndlr = EMcheck_nonclose_fillet;
      sts = om$send(msg = message ECelements.do_locate(&msg,
						       &useract,
						       response,
						       response_data,
						       elem_type,
						       NULL,
						       msg1,
						       msg2,
						       NULL,
						       NULL),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      if (useract == EMSuser_moveon)
      {
	if (me->num_elems == 0)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	  ME.super_cmd->state = LOCATE_FILLET;
	}
	else
	  ME.super_cmd->state = INIT_PROC_CUTBACK_CV;
      }
      else if (useract == EMSuser_backup)
	ME.super_cmd->state = LOCATE_SOLID;
      else 
	goto quit;
      break;

    case INIT_PROC_CUTBACK_CV:
      curr_edge_index = 0;
      
      vla_size = om$dimension_of(varray = me->parm_ranges);
      if (me->num_elems > vla_size)
      {
	sts = om$vla_set_dimension(varray = me->parm_ranges,
				   size = me->num_elems);
	EMomerr_exit(sts, quit);

	sts = om$vla_set_dimension(varray = me->fillet_bounds,
				   size = me->num_elems);
	EMomerr_exit(sts, quit);

	sts = om$vla_set_dimension(varray = me->cutback_cvs,
				   size = me->num_elems);
	EMomerr_exit(sts, quit);
      }

      /*
       * For each fillet surface, we calculate and store the following
       * information:
       * a) the number and GRids of edges composing the boundary in 
       *    the minimum and maxmum v sides -- using EMget_bnd_parm
       * b) the GRids of the edges having u=0 and u=1 -- using EMnat_u_edges
       *
       * Our tolerance is set as 10 times the parametric tolerance
       */

      BSxtractpar(&msg, BSTOLPARAM, &tolr);
      tolr *= 10.0;
      u_or_v = 0;
      for (i = 0; i < me->num_elems; i++)
      {
	if (EMget_bnd_parms(&msg,
			    &me->elems[i].located_obj,
			    tolr,
			    u_or_v,
			    me->parm_ranges[i],
			    &num_minbnd_edges,
			    &minbnd_edges,
			    &num_maxbnd_edges,
			    &maxbnd_edges) != OM_E_ABORT)
	{
	  me->fillet_bounds[i].num_minbnd_edges = num_minbnd_edges;
	  me->fillet_bounds[i].num_maxbnd_edges = num_maxbnd_edges;
	  
	  vla_size = om$dimension_of(varray = me->bound_edges);
	  if ((curr_edge_index + num_minbnd_edges + num_maxbnd_edges + 1)
	      > vla_size)
	  {
	    sts = om$vla_set_dimension(varray = me->bound_edges,
				       size = curr_edge_index +
				       num_minbnd_edges + num_maxbnd_edges +
				       ELEMS_ARRAY_INCR);
	    EMomerr_exit(sts, quit);
	  }
	  me->fillet_bounds[i].minbnd_edges_index = curr_edge_index;
	  memcpy(me->bound_edges + curr_edge_index,
		 minbnd_edges, num_minbnd_edges * sizeof(struct GRid));
	  curr_edge_index += num_minbnd_edges;
	  me->fillet_bounds[i].maxbnd_edges_index = curr_edge_index;
	  memcpy(me->bound_edges + curr_edge_index,
		 maxbnd_edges, num_maxbnd_edges * sizeof(struct GRid));
	  curr_edge_index += num_maxbnd_edges;

	  om$dealloc(ptr = minbnd_edges);
	  om$dealloc(ptr = maxbnd_edges);

	  if (EMnat_u_edges(&msg,
			    &me->elems[i].located_obj,
			    tolr,
			    &me->fillet_bounds[i].edge_u0,
			    &me->fillet_bounds[i].edge_u1) == OM_E_ABORT)
	    return OM_E_ABORT;
	}
	else
	  return OM_E_ABORT;
      }
      
      me->curr_flt = 0;
      ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
      
      break;

    case SPECIFY_CUTBACK_ISOCV:
      ex$message(field = PROMPT_FIELD, msgnumb = EMS_P_IdCutBkCv);
      sts = om$send(msg = message ECcrbldsf.dynamics(&msg, ISOCV),
		    targetid = my_id);

      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	if (me->curr_flt == 0)
	{
	  for (i = 0; i < me->num_solid; i++)
	    gr$display_object(object_id = &me->solids[i].located_obj,
			      mode = GRhhd);
	  for (i = 0; i < me->num_elems; i++)
	    gr$display_object(object_id = &me->elems[i].located_obj,
			      mode = GRhe);
	  ME.super_cmd->state = LOCATE_FILLET;
	}
	else
	{
	  me->curr_flt--;
	  if (me->cutback_cvs[me->curr_flt].type == ISOCV)
	    EFdisplay_isocv(&msg,
			    NULL,
			    &me->elems[me->curr_flt],
			    V_DIRECTION,
			    me->cutback_cvs[me->curr_flt].cutcv.isocv_parm,
			    &me->active_display,
			    GRbe);
	  else if (me->cutback_cvs[me->curr_flt].type == PLANECUT)
	    EFdisplay_plncutcv(&msg,
			       NULL,
			       &me->elems[me->curr_flt],
			       me->cutback_cvs[me->curr_flt].midpt,
			       me->cutback_cvs[me->curr_flt].cutcv.cutpln.normal,
			       &me->active_display,
			       GRbe);
	  ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	}
	break;

      case EX_DATA:
	if (acc_event.subtype != GRst_REGULAR)
	{
	  IGRpoint gen_pt;

	  memcpy(gen_pt, &acc_event.event.button.x, sizeof(IGRpoint));
	  sts = om$send(msg = message ECcrbldsf.chk_gen_point(&msg,
							      gen_pt,
							      ISOCV),
			targetid = my_id);
	  if (sts == OM_E_ABORT)
	    return sts;
	  if (msg == MSFAIL)
	    ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	  else
	  {
	    curr_cb = &me->cutback_cvs[me->curr_flt];

	    if (curr_cb->type == ISOCV)
	      EFdisplay_isocv(&msg,
			      NULL,
			      &me->elems[me->curr_flt],
			      V_DIRECTION,
			      curr_cb->cutcv.isocv_parm,
			      &me->active_display,
			      GRbd);

	    me->curr_flt++;
	    if (me->curr_flt == me->num_elems)
	      ME.super_cmd->state = INIT_PROC_BLEND_CV;
	    else
	      ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	  }
	}
	else if (me->isocv_buff.rc == DYN_SUCCESS ||
		 me->isocv_buff.rc == DYN_BOUNDARY)
	{
	  curr_cb = &me->cutback_cvs[me->curr_flt];
	  
	  memcpy(curr_cb->endpt1, me->isocv_buff.endpt1, sizeof(IGRpoint));
	  memcpy(curr_cb->endpt2, me->isocv_buff.endpt2, sizeof(IGRpoint));
	  memcpy(curr_cb->midpt, me->isocv_buff.midpt, sizeof(IGRpoint));
	  memcpy(curr_cb->testpt1, me->isocv_buff.testpt1, sizeof(IGRpoint));
	  memcpy(curr_cb->testpt2, me->isocv_buff.testpt2, sizeof(IGRpoint));
	  memcpy(curr_cb->testvec1, me->isocv_buff.testvec1, sizeof(IGRvector));
	  memcpy(curr_cb->testvec2, me->isocv_buff.testvec2, sizeof(IGRvector));

	  if (me->isocv_buff.rc == DYN_SUCCESS)
	  {
	    EFdisplay_isocv(&msg,
			    NULL,
			    &me->elems[me->curr_flt],
			    V_DIRECTION,
			    me->isocv_buff.vpar,
			    &me->active_display,
			    GRbd);

	    curr_cb->type = ISOCV;
	    curr_cb->cutcv.isocv_parm = me->isocv_buff.vpar;
	  }
	  else
	  {
	    curr_cb->type = BOUNDARY;
	    curr_bnd = &me->fillet_bounds[me->curr_flt];
	    if (me->isocv_buff.side)
	    {
	      curr_cb->cutcv.bdry.index = curr_bnd->maxbnd_edges_index;
	      curr_cb->cutcv.bdry.num_edges = curr_bnd->num_maxbnd_edges;
	    }
	    else
	    {
	      curr_cb->cutcv.bdry.index = curr_bnd->minbnd_edges_index;
	      curr_cb->cutcv.bdry.num_edges = curr_bnd->num_minbnd_edges;
	    }
	  }

	  me->curr_flt++;
	  if (me->curr_flt == me->num_elems)
	    ME.super_cmd->state = INIT_PROC_BLEND_CV;
	  else
	    ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	}
	else if (me->isocv_buff.rc == DYN_NO_MEMORY)
	  return OM_E_ABORT;
	else
	  ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	break;

      case EX_RJT_MOVEON:
	me->which_u = 0;
	ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_PT;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;
      
    case SPECIFY_CUTBACK_PLANECUT_PT:
      ex$message(field = PROMPT_FIELD, msgnumb = EMS_P_IdCutFirstPt);
      sts = om$send(msg = message ECcrbldsf.dynamics(&msg, PLANECUT_PT),
		    targetid = my_id);

      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	break;

      case EX_DATA:
	if (acc_event.subtype != GRst_REGULAR)
	{
	  IGRpoint gen_pt;

	  memcpy(gen_pt, &acc_event.event.button.x, sizeof(IGRpoint));
	  sts = om$send(msg = message ECcrbldsf.chk_gen_point(&msg,
							      gen_pt,
							      PLANECUT_PT),
			targetid = my_id);
	  if (sts == OM_E_ABORT)
	    return sts;
	  if (msg == MSFAIL)
	    ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_PT;
	  else
	    ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_CV;
	}
	else if (me->startpt_buff.rc == DYN_SUCCESS)
	{
	  curr_cb = &me->cutback_cvs[me->curr_flt];
	  
	  memcpy(curr_cb->endpt1, me->startpt_buff.startpt, sizeof(IGRpoint));
	  memcpy(curr_cb->testpt1, me->startpt_buff.testpt, sizeof(IGRpoint));
	  memcpy(curr_cb->testvec1, me->startpt_buff.testvec, sizeof(IGRvector));
	  curr_cb->type = PLANECUT;
	  curr_cb->cutcv.cutpln.which_u = me->which_u;

	  ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_CV;
	}
	else if (me->startpt_buff.rc == DYN_NO_MEMORY)
	  return OM_E_ABORT;
	else
	  ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_PT;
	break;

      case EX_RJT_MOVEON:
	me->which_u = (me->which_u + 1) % 2;
	ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_PT;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case SPECIFY_CUTBACK_PLANECUT_CV:
      ex$message(field = PROMPT_FIELD, msgnumb = EMS_P_PosTrimCv);
      sts = om$send(msg = message ECcrbldsf.dynamics(&msg, PLANECUT),
		    targetid = my_id);

      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_PT;
	break;

      case EX_DATA:
	if (acc_event.subtype != GRst_REGULAR)
	{
	  IGRpoint gen_pt, midpoint;
	  IGRvector sfnormal, basevec;
	  IGRdouble uparm, vparm, *planenormal;
	  struct IGRbsp_surface *surf;

	  memcpy(gen_pt, &acc_event.event.button.x, sizeof(IGRpoint));
	  sts = om$send(msg = message ECcrbldsf.chk_gen_point(&msg,
							      gen_pt,
							      PLANECUT),
			targetid = my_id);
	  if (sts == OM_E_ABORT)
	    return sts;
	  if (msg == MSFAIL)
	    ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_CV;
	  else
	  {
	    curr_cb = &me->cutback_cvs[me->curr_flt];

	    /* calculate the mid point */
	    midpoint[0] = (curr_cb->endpt1[0] + curr_cb->endpt2[0]) / 2;
	    midpoint[1] = (curr_cb->endpt1[1] + curr_cb->endpt2[1]) / 2;
	    midpoint[2] = (curr_cb->endpt1[2] + curr_cb->endpt2[2]) / 2;
	    memcpy(&acc_event.event.button, midpoint, sizeof(IGRpoint));

	    /* project mid point onto surface */
	    EFpoint_on_object(&me->elems[me->curr_flt],
			      &acc_event, my_id, &msg);

	    uparm = acc_event.located_object[0].geom_parms.u;
	    vparm = acc_event.located_object[0].geom_parms.v;

	    /* get surface geometry */
	    sts = EMget_the_geometry(&me->elems[me->curr_flt],
				     FALSE, FALSE, FALSE, my_id, &surf, &msg);
	    if (!(1 & sts & msg))
	    {
	      if (surf)
		om$dealloc(ptr = surf);
	      return OM_E_ABORT;
	    }
    
	    /* evaluate surface normal at the projection point */
	    BSsfarrevn(&msg, surf, 1, &uparm, 1, &vparm,
		       curr_cb->midpt, sfnormal);

	    /* calculate plane normal */
	    planenormal = curr_cb->cutcv.cutpln.normal;
	    BSmkvec(&msg, basevec, curr_cb->endpt1, curr_cb->endpt2);
	    BSnorvec(&msg, basevec);
	    BScrossp(&msg, sfnormal, basevec, planenormal);
	    BSnorvec(&msg, planenormal);

	    EFdisplay_plncutcv(&msg,
			       NULL,
			       &me->elems[me->curr_flt],
			       curr_cb->midpt,
			       curr_cb->cutcv.cutpln.normal,
			       &me->active_display,
			       GRbd);

	    om$dealloc(ptr = surf);
	    me->curr_flt++;
	    if (me->curr_flt == me->num_elems)
	      ME.super_cmd->state = INIT_PROC_BLEND_CV;
	    else
	      ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	  }
	}
	else if (me->planecut_buff.rc == DYN_SUCCESS)
	{
	  curr_cb = &me->cutback_cvs[me->curr_flt];
	  
	  memcpy(curr_cb->endpt2, me->planecut_buff.endpt, sizeof(IGRpoint));
	  memcpy(curr_cb->midpt, me->planecut_buff.midpt, sizeof(IGRpoint));
	  memcpy(curr_cb->testpt2, me->planecut_buff.testpt, sizeof(IGRpoint));
	  memcpy(curr_cb->testvec2, me->planecut_buff.testvec, sizeof(IGRvector));
	  memcpy(curr_cb->cutcv.cutpln.normal, me->planecut_buff.normal,
		 sizeof(IGRvector));

	  EFdisplay_plncutcv(&msg,
			     NULL,
			     &me->elems[me->curr_flt],
			     curr_cb->midpt,
			     curr_cb->cutcv.cutpln.normal,
			     &me->active_display,
			     GRbd);

	  me->curr_flt++;
	  if (me->curr_flt == me->num_elems)
	    ME.super_cmd->state = INIT_PROC_BLEND_CV;
	  else
	    ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	}
	else if (me->planecut_buff.rc == DYN_NO_MEMORY)
	  return OM_E_ABORT;
	else
	  ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_CV;
	break;

      case EX_RJT_MOVEON:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	ME.super_cmd->state = SPECIFY_CUTBACK_PLANECUT_CV;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case INIT_PROC_BLEND_CV:
      /*
       * Perform the following tasks
       * o Find the supporting surfaces that define each fillet
       *   surface where cut back had been performed
       * o Refine the endpoints of the cut back curves to the
       *   supporting surfaces
       * o Construct special points using refined endpoints of
       *   the cut back curves
       */
      me->curr_onsurf_index = 0;
      me->curr_pnt_index = 0;
      for (i = 0; i < me->num_elems; i++)
      {
	curr_cb = &me->cutback_cvs[i];
	
	for (j = 0; j < me->num_solid; j++)
	{
	  if (EMget_closest_surf_along_direction(&msg,
						 &me->solids[j],
						 curr_cb->testpt1,
						 curr_cb->testvec1,
						 &me->elems[i],
						 &closest_surf1) == OM_E_ABORT)
	    return OM_E_ABORT;

	  if (msg == FIND_CLOSEST_SURF)
	    break;
	}
	if (j == me->num_solid)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_E_NoClosestSurf);
	  return OM_E_ABORT;
	}

	for (j = 0; j < me->num_solid; j++)
	{
	  if (EMget_closest_surf_along_direction(&msg,
						 &me->solids[j],
						 curr_cb->testpt2,
						 curr_cb->testvec2,
						 &me->elems[i],
						 &closest_surf2) == OM_E_ABORT)
	    return OM_E_ABORT;
	    
	  if (msg == FIND_CLOSEST_SURF)
	    break;
	}
	if (j == me->num_solid)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_E_NoClosestSurf);
	  return OM_E_ABORT;
	}

	/*
	 * Now that the two surfaces on which fillet surfaces are
	 * created are found. Refine endpoints of cut back curves
	 * to lie on the two surfaces.
	 */
	sts = om$send(msg = message ECcrbldsf.refine_cut_curve_endpoints
		      (&msg,
		       i,
		       &closest_surf1,
		       &closest_surf2),
		      targetid = my_id);
	/*
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	*/
	
	sts = om$send(msg = message ECcrbldsf.construct_spl_point
		      (&msg,
		       curr_cb->endpt1,
		       curr_cb->testpt1,
		       &closest_surf1,
		       curr_cb->type == PLANECUT && curr_cb->cutcv.cutpln.which_u ? &me->fillet_bounds[i].edge_u1 : &me->fillet_bounds[i].edge_u0,
		       i),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

	sts = om$send(msg = message ECcrbldsf.construct_spl_point
		      (&msg,
		       curr_cb->endpt2,
		       curr_cb->testpt2,
		       &closest_surf2,
		       curr_cb->type == PLANECUT && curr_cb->cutcv.cutpln.which_u ? &me->fillet_bounds[i].edge_u0 : &me->fillet_bounds[i].edge_u1,
		       i),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
      }

      me->form_avail = FALSE;
      me->bsp_start_edge = NULL;
      me->bsp_spl_edge = NULL;
      me->curr_blend_index = 0;
      me->curr_unused = 0;
      me->moveon = FALSE;

      /* check whether specified cut back curves form a closed loop */
      BSxtractpar(&msg, BSTOLCHRDHT, &tolr);
      for (i = 0; i < me->curr_pnt_index; i++)
	if (me->spl_pts[i].used == FALSE)
	{
	  for (j = i + 1; j < me->curr_pnt_index; j++)
	    if (me->spl_pts[j].used == FALSE &&
		BSdistptpt(&msg, me->spl_pts[i].pt_coord, me->spl_pts[j].pt_coord) < tolr)
	    {
	      me->spl_pts[i].used = TRUE;
	      me->spl_pts[j].used = TRUE;
	      break;
	    }
	}

      for (i = 0; i < me->curr_pnt_index; i++)
	if (me->spl_pts[i].used == FALSE)
	  break;
      if (i == me->curr_pnt_index)
	ME.super_cmd->state = PROCESS_BLEND_SF;
      else
	ME.super_cmd->state = SPECIFY_BLEND_CV;
      
      break;

    case SPECIFY_BLEND_CV:
      finish = FALSE;
      if (me->spl_pts[me->curr_unused].used == TRUE || me->moveon)
      {
	i = (me->curr_unused + 1) % me->curr_pnt_index;
	while (i != me->curr_unused && me->spl_pts[i].used == TRUE)
	  i = (i + 1) % me->curr_pnt_index;
	if (i == me->curr_unused)
	  finish = TRUE;
	else
	  me->curr_unused = i;
      }

      if (me->moveon)
	finish = FALSE;

      if (finish == TRUE)
	ME.super_cmd->state = PROCESS_BLEND_SF;
      else
      {
	ex$message(field = PROMPT_FIELD, msgnumb = EMS_P_AccBlndPtOrEd);
	if (me->form_avail)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_InvkStatusFrm);
          GRstatus_display_button(1);
	}
	sts = om$send(msg = message ECcrbldsf.dynamics(&msg, BLENDCV),
		      targetid = my_id);

	co$getevent(msg = &msg,
		    event_mask = event_mask | GRm_FORM_FINISHED,
		    response = response,
		    response_data = response_data,
		    event = &acc_event);
	switch (acc_event.response)
	{
	case EX_BACK_UP:
	  BSfreecv(&msg, me->bsp_start_edge);
	  if (me->curr_blend_index)
	  {
	    me->curr_blend_index--;
	    curr_bcv = &me->blend_cvs[me->curr_blend_index];
	    bspcv = curr_bcv->bspcv;

	    /* erase the last curve */
	    EFdisplay_bspcv(bspcv, &me->active_display, GRbe);

	    /* free the memory */
	    if (bspcv->poles)
	      om$dealloc(ptr = bspcv->poles);
	    if (bspcv->knots)
	      om$dealloc(ptr = bspcv->knots);
	    if (bspcv->weights)
	    om$dealloc(ptr = bspcv->weights);

	    me->spl_pts[curr_bcv->index1].used = FALSE;
	    me->spl_pts[curr_bcv->index2].used = FALSE;

	    if (curr_bcv->newpt)
	    {
	      me->curr_pnt_index--;
	      curr_sp = &me->spl_pts[me->curr_pnt_index];

	      /* erase the display of the point */
	      gr$display_object(object_id = &curr_sp->pt_id,
				mode = GRbe);

	      sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							      &pt_env),
			    senderid = my_id,
			    targetid = curr_sp->pt_id.objid,
			    targetos = curr_sp->pt_id.osnum);
	      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	      
	      /*
	      if (me->curr_unused == me->curr_pnt_index && me->curr_unused)
		me->curr_unused--;
		*/
	      me->moveon = FALSE;
	    }
	    me->curr_unused = curr_bcv->index1;
	    ME.super_cmd->state = SPECIFY_BLEND_CV;
	  }
	  else
	  {
	    /* delete all the special points */
	    for (i = 0; i < me->curr_pnt_index; i++)
	    {
	      curr_sp = &me->spl_pts[i];

	      /* erase the display of the point */
	      gr$display_object(object_id = &curr_sp->pt_id,
				mode = GRbe);

	      sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							      &pt_env),
			    senderid = my_id,
			    targetid = curr_sp->pt_id.objid,
			    targetos = curr_sp->pt_id.osnum);
	      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	    }

	    /* go back to the last fillet */
	    if (me->curr_flt == 0)
	    {
	      for (i = 0; i < me->num_solid; i++)
		gr$display_object(object_id = &me->solids[i].located_obj,
				  mode = GRhhd);
	      for (i = 0; i < me->num_elems; i++)
		gr$display_object(object_id = &me->elems[i].located_obj,
				  mode = GRhe);
	      ME.super_cmd->state = LOCATE_FILLET;
	    }
	    else
	    {
	      me->curr_flt--;
	      if (me->cutback_cvs[me->curr_flt].type == ISOCV)
		EFdisplay_isocv(&msg,
				NULL,
				&me->elems[me->curr_flt],
				V_DIRECTION,
				me->cutback_cvs[me->curr_flt].cutcv.isocv_parm,
				&me->active_display,
				GRbe);
	      else if (me->cutback_cvs[me->curr_flt].type == PLANECUT)
		EFdisplay_plncutcv(&msg,
				   NULL,
				   &me->elems[me->curr_flt],
				   me->cutback_cvs[me->curr_flt].midpt,
				   me->cutback_cvs[me->curr_flt].cutcv.cutpln.normal,
				   &me->active_display,
				   GRbe);
	      ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	    }
	  }
	  break;

	case EX_DATA:
	  if (acc_event.subtype != GRst_REGULAR)
	  {
	    IGRpoint gen_pt;

	    memcpy(gen_pt, &acc_event.event.button.x, sizeof(IGRpoint));
	    sts = om$send(msg = message ECcrbldsf.chk_gen_point(&msg,
								gen_pt,
								BLENDCV),
			  targetid = my_id);
	    if (sts == OM_E_ABORT)
	    {
	      BSfreecv(&msg, me->bsp_start_edge);
	      return sts;
	    }
	  }
	  
	  if (acc_event.subtype != GRst_REGULAR && msg == MSFAIL)
	  {
	    BSfreecv(&msg, me->bsp_start_edge);
	    ME.super_cmd->state = SPECIFY_BLEND_CV;
	  }
	  else if (me->blendcv_buff.rc == DYN_SUCC_FIND_PT)
	  {
	    curr_sp = &me->spl_pts[me->curr_unused];
	    curr_sp->used = TRUE;

	    me->spl_pts[me->blendcv_buff.index].used = TRUE;
    
	    /* construct the blending curve */
	    sts = om$send(msg = message ECcrbldsf.construct_blend_curve
			  (&msg,
			   curr_sp->pt_coord,
			   me->spl_pts[me->blendcv_buff.index].pt_coord,
			   me->curr_unused,
			   me->blendcv_buff.index,
			   curr_sp->surf_index,
			   SPL_PT_TO_SPL_PT),
			  targetid = my_id);

	    BSfreecv(&msg, me->bsp_start_edge);
	    BSfreecv(&msg, me->bsp_spl_edge);

	    ME.super_cmd->state = VALIDATE_BLEND_CV;
	  }
	  else if (me->blendcv_buff.rc == DYN_SUCC_FIND_EDGE)
	  {
	    curr_sp = &me->spl_pts[me->curr_unused];
	    curr_sp->used = TRUE;
	    ME.super_cmd->state = SPECIFY_PT_ON_EDGE;
	  }
	  else
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_NoBlndPtOrEd);
	    BSfreecv(&msg, me->bsp_start_edge);
	    me->spl_pts[me->curr_unused].used = FALSE;
	    ME.super_cmd->state = SPECIFY_BLEND_CV;
	  }
	  me->moveon = FALSE;
	  break;

	case EX_RJT_MOVEON:
	  BSfreecv(&msg, me->bsp_start_edge);
	  me->spl_pts[me->curr_unused].used = FALSE;
	  me->moveon = TRUE;
	  ME.super_cmd->state = SPECIFY_BLEND_CV;
	  break;

	case EX_FORM_FINISHED:
	  ME.super_cmd->state = VALIDATE_BLEND_CV;
	  break;

	default:
	  me->moveon = FALSE;
	  return OM_S_SUCCESS;
	}
      }
      break;

    case SPECIFY_PT_ON_EDGE:
      ex$message(field = PROMPT_FIELD, msgnumb = EMS_P_PosBlndPoint);
      sts = om$send(msg = message ECcrbldsf.dynamics(&msg, PTON_EDGE),
		    targetid = my_id);

      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	BSfreecv(&msg, me->bsp_start_edge);
	BSfreecv(&msg, me->bsp_spl_edge);
	me->spl_pts[me->curr_unused].used = FALSE;
	ME.super_cmd->state = SPECIFY_BLEND_CV;
	break;

      case EX_DATA:
	if (acc_event.subtype != GRst_REGULAR)
	{
	  IGRpoint gen_pt;

	  memcpy(gen_pt, &acc_event.event.button.x, sizeof(IGRpoint));
	  sts = om$send(msg = message ECcrbldsf.chk_gen_point(&msg,
							      gen_pt,
							      PTON_EDGE),
			targetid = my_id);
	  if (sts == OM_E_ABORT)
	  {
	    BSfreecv(&msg, me->bsp_start_edge);
	    BSfreecv(&msg, me->bsp_spl_edge);
	    return sts;
	  }
	}

	if (acc_event.subtype != GRst_REGULAR && msg == MSFAIL)
	{
	  BSfreecv(&msg, me->bsp_start_edge);
	  BSfreecv(&msg, me->bsp_spl_edge);
	  ME.super_cmd->state = SPECIFY_PT_ON_EDGE;
	}
	else if (me->blendpt_buff.rc == DYN_SUCCESS)
	{
	  curr_sp = &me->spl_pts[me->curr_unused];
	  me->spl_pts[me->curr_pnt_index].which_fillet = -1;

	  /* construct the blending curve */
	  sts = om$send(msg = message ECcrbldsf.construct_blend_curve
			(&msg,
			 curr_sp->pt_coord,
			 me->blendpt_buff.edge_pt,
			 me->curr_unused,
			 me->curr_pnt_index,
			 curr_sp->surf_index,
			 SPL_PT_TO_EDGE_PT),
			targetid = my_id);

	  /*
	  spl_edge = &me->spl_pts[me->curr_pnt_index].edge_id;
	  */
	  spl_edge = &me->spl_edge_id;

	  sts = om$make_chanselect(channame = "EMSedge.to_common_edge",
				   p_chanselect = &edge_chan);
	  EMomerr_exit(sts, quit);

	  sts = om$get_channel_objects(objid = spl_edge->objid,
				       osnum = spl_edge->osnum,
				       p_chanselect = &edge_chan,
				       size = 1,
				       list = &edge_link,
				       count = &edge_count);
	  EMomerr_exit(sts, quit);

	  sts = om$send(msg = message EMSedge.EMgetsurface_info(&msg,
								&closest_surf.objid,
								NULL),
			targetid = edge_link.S_objid,
			targetos = spl_edge->osnum);
	  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	  closest_surf.osnum = spl_edge->osnum;

	  co_edge_id.objid = edge_link.S_objid;
	  co_edge_id.osnum = spl_edge->osnum;

	  sts = om$send(msg = message ECcrbldsf.construct_spl_point
			(&msg,
			 me->blendpt_buff.edge_pt,
			 me->blendpt_buff.testpt,
			 &closest_surf,
			 &co_edge_id,
			 -1),
			targetid = my_id);
	  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

	  BSfreecv(&msg, me->bsp_start_edge);
	  BSfreecv(&msg, me->bsp_spl_edge);
	  
	  ME.super_cmd->state = VALIDATE_BLEND_CV;
	}
	else
	  ME.super_cmd->state = SPECIFY_PT_ON_EDGE;
	break;

      case EX_RJT_MOVEON:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	ME.super_cmd->state = SPECIFY_PT_ON_EDGE;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case VALIDATE_BLEND_CV:
      /*
       * check whether the blend curve intersects surface boundary
       */
      sts = om$send(msg = message ECcrbldsf.check_blend_bdry_intersect(&msg),
		    targetid = my_id);
      if (sts == OM_E_ABORT)
	return sts;

      if (msg == MSFAIL || msg == EMS_I_IntersectTrim)
      {
	sts = om$send(msg = message ECcrbldsf.status_disp(),
		      targetid = my_id);

	/*
	 * Waiting for user to modify blend curve
	 */
	co$getevent(msg = &msg,
		    event_mask = GRm_FORM_FINISHED,
		    response = response,
		    response_data = response_data,
		    event = &acc_event);
	if (acc_event.response == EX_FORM_FINISHED)
	  ME.super_cmd->state = VALIDATE_BLEND_CV;
	else
	  return OM_S_SUCCESS;
      }
      else
	ME.super_cmd->state = SPECIFY_BLEND_CV;
      break;

    case PROCESS_BLEND_SF:
      if (me->form_avail)
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_InvkStatusFrm);
        GRstatus_display_button(1);
      }
      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  msgnum = EMS_P_MoveOnProc,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	if (me->curr_blend_index)
	{
	  me->curr_blend_index--;
	  curr_bcv = &me->blend_cvs[me->curr_blend_index];
	  bspcv = curr_bcv->bspcv;

	  /* erase the last curve */
	  EFdisplay_bspcv(bspcv, &me->active_display, GRbe);

	  /* free the memory */
	  if (bspcv->poles)
	    om$dealloc(ptr = bspcv->poles);
	  if (bspcv->knots)
	    om$dealloc(ptr = bspcv->knots);
	  if (bspcv->weights)
	    om$dealloc(ptr = bspcv->weights);

	  me->spl_pts[curr_bcv->index1].used = FALSE;
	  me->spl_pts[curr_bcv->index2].used = FALSE;

	  ME.super_cmd->state = SPECIFY_BLEND_CV;
	}
	else
	{
	  /* delete all the special points */
	  for (i = 0; i < me->curr_pnt_index; i++)
	  {
	    curr_sp = &me->spl_pts[i];
	    
	    /* erase the display of the point */
	    gr$display_object(object_id = &curr_sp->pt_id,
			      mode = GRbe);
	    
	    sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							    &pt_env),
			  senderid = my_id,
			  targetid = curr_sp->pt_id.objid,
			  targetos = curr_sp->pt_id.osnum);
	    EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	  }

	  /* go back to the last fillet */
	  if (me->curr_flt == 0)
	  {
	    for (i = 0; i < me->num_solid; i++)
	      gr$display_object(object_id = &me->solids[i].located_obj,
				mode = GRhhd);
	    for (i = 0; i < me->num_elems; i++)
	      gr$display_object(object_id = &me->elems[i].located_obj,
				mode = GRhe);
	    ME.super_cmd->state = LOCATE_FILLET;
	  }
	  else
	  {
	    me->curr_flt--;
	    if (me->cutback_cvs[me->curr_flt].type == ISOCV)
	      EFdisplay_isocv(&msg,
			      NULL,
			      &me->elems[me->curr_flt],
			      V_DIRECTION,
			      me->cutback_cvs[me->curr_flt].cutcv.isocv_parm,
			      &me->active_display,
			      GRbe);
	    else if (me->cutback_cvs[me->curr_flt].type == PLANECUT)
	      EFdisplay_plncutcv(&msg,
				 NULL,
				 &me->elems[me->curr_flt],
				 me->cutback_cvs[me->curr_flt].midpt,
				 me->cutback_cvs[me->curr_flt].cutcv.cutpln.normal,
				 &me->active_display,
				 GRbe);
	    ME.super_cmd->state = SPECIFY_CUTBACK_ISOCV;
	  }
	}
	break;

      case EX_DATA:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	ME.super_cmd->state = PROCESS_BLEND_SF;
	break;

      case EX_RJT_MOVEON:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_PlaceBlndSurf);

	/*
	vla_size = om$dimension_of(varray = me->surf_copies);
	if ((me->num_elems + me->curr_blend_index + 1)
	    > vla_size)
	{
	  sts = om$vla_set_dimension(varray = me->surf_copies,
				     size = me->num_elems +
				     me->curr_blend_index + 1);
	  EMomerr_exit(sts, quit);
	}
	*/

	/* make a copy of all the surfaces involved */
	/*
	for (i = 0; i < me->num_elems; i++)
	{
	  curr_sf = &me->surf_copies[i];
	  sts = om$send(msg = message GRgraphics.GRcopy(&msg,
							&me->active_md_env,
							&pt_env,
							&curr_sf->objid),
			targetid = me->elems[i].located_obj.objid,
			targetos = me->elems[i].located_obj.osnum);
	  curr_sf->osnum = me->active_md_env.md_id.osnum;
	}
	for (i = me->num_elems; i < me->num_elems + me->curr_blend_index; i++)
	{
	  curr_sf = &me->surf_copies[i];
	  curr_bcv = &me->blend_cvs[i - me->num_elems];
	  sts = om$send(msg = message GRgraphics.GRcopy(&msg,
							&me->active_md_env,
							&pt_env,
							&curr_sf->objid),
			targetid = me->on_surfs[curr_bcv->surf_index].objid,
			targetos = me->on_surfs[curr_bcv->surf_index].osnum);
	  curr_sf->osnum = me->active_md_env.md_id.osnum;
	}
	*/

	sts = om$send(msg = message ECcrbldsf.construct_blend_surf(&msg),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

	ME.super_cmd->state = ACC_REJECT_RESULT;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;
      
    case ACC_REJECT_RESULT:
      co$getevent(msg = &msg,
		  event_mask = event_mask,
		  msgnum = EMS_P_AccMvRestart,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
      case EX_RJT_MOVEON:
	/*
	 * Erase and delet the blend surface
	 */
	gr$display_object(object_id = &ME.ECcrbldsf->blend_sf,
			  mode = GRbe);
	sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							&me->active_md_env),
		      targetid = ME.ECcrbldsf->blend_sf.objid,
		      targetos = ME.ECcrbldsf->blend_sf.osnum);

	/*
	 * Redraw cut back and blend curves
	 */
	for (i = 0; i < me->curr_flt; i++)
	  if (me->cutback_cvs[i].type == ISOCV)
	    EFdisplay_isocv(&msg,
			    NULL,
			    &me->elems[i],
			    V_DIRECTION,
			    me->cutback_cvs[i].cutcv.isocv_parm,
			    &me->active_display,
			    GRbd);
	  else if (me->cutback_cvs[i].type == PLANECUT)
	    EFdisplay_plncutcv(&msg,
			       NULL,
			       &me->elems[i],
			       me->cutback_cvs[i].midpt,
			       me->cutback_cvs[i].cutcv.cutpln.normal,
			       &me->active_display,
			       GRbd);

	for (i = 0; i < me->curr_blend_index; i++)
	  EFdisplay_bspcv(me->blend_cvs[i].bspcv, &me->active_display, GRbd);

	ME.super_cmd->state = PROCESS_BLEND_SF;
	break;

      case EX_DATA:
	/*
	 * Free all the memory allocated.
	 */
	for (i = 0; i < me->curr_blend_index; i++)
	{
	  curr_bcv = &me->blend_cvs[i];
	  if (curr_bcv->bspcv)
	  {
	    BSfreecv(&msg, curr_bcv->bspcv);
	    curr_bcv->bspcv = NULL;
	  }
	  if (curr_bcv->uvcv)
	  {
	    BSfreecv(&msg, curr_bcv->uvcv);
	    curr_bcv->uvcv = NULL;
	  }
	}

	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_ClearStatusField);

	for (i = 0; i < me->curr_pnt_index; i++)
	{
	  curr_sp = &me->spl_pts[i];
	  
	  /* erase the display of the point */
	  gr$display_object(object_id = &curr_sp->pt_id,
			    mode = GRbe);
	  
	  sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							  &pt_env),
			senderid = my_id,
			targetid = curr_sp->pt_id.objid,
			targetos = curr_sp->pt_id.osnum);
	  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	}

	/*
	 * Redraw the blend surface
	 */
	gr$display_object(object_id = &ME.ECcrbldsf->blend_sf,
			  mode = GRbd);
	ME.super_cmd->state = LOCATE_SOLID;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;
    }
  } while (loop);

 quit:
  if (EMSerror(sts))
    *response = TERMINATE;
  return sts;
}

method dynamics(IGRlong *msg; IGRint dynamics)
{
  struct IGRbsp_surface *surf = NULL;
  struct IGRbsp_curve *bspcv = NULL, *bspcv1 = NULL;
  struct GRsymbology sf_symb;
  struct IGResbc curve_att;
  struct IGRdisplay dyncv_display;
  IGRlong sts;
  extern IGRlong EMget_the_geometry();
  extern void BSalloccv(), BScveval();
  extern IGRboolean BScv_copy(), BSfreecv(), BSconstprcv(), BSactivsplt();
  extern void BSmdistptcv();
  extern IGRdouble fabs();

  sts = OM_S_SUCCESS;

  /* initialize to display curve not polygon */
  curve_att.is_polydis = FALSE;
  curve_att.is_curvedis = TRUE;

  if (dynamics == BLENDCV || dynamics == PTON_EDGE)
  {
    struct SpecialPnt *curr_sp;
    IGRint surf_index;
    IGRdouble poly_pts[6];
    struct IGRpolyline poly;
    struct IGRdisplay dyn_display;

    curr_sp = &me->spl_pts[me->curr_unused];
    surf_index = curr_sp->surf_index;
    
    /*
     * Get surface symbology. We want the dynamic curve to
     * have weight 1 bigger than the surface weight.
     */
    sts = om$send(msg = message GRvg.GRgetsymb(msg, &sf_symb),
		  targetid = me->on_surfs[surf_index].objid,
		  targetos = me->on_surfs[surf_index].osnum);

    memcpy(&dyncv_display, &me->active_display, sizeof(struct IGRdisplay));
    if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 1)
      dyncv_display.weight = sf_symb.display_attr.weight + 1;
    else
      dyncv_display.weight = GR_HI_WEIGHT;

    /*
     * fill up the starting point coordinates
     */
    poly.num_points = 2;
    poly.points = poly_pts;
    memcpy(poly_pts, curr_sp->pt_coord, sizeof(IGRpoint));

    if (dynamics == BLENDCV)
    {
      IGRint num_spl_pts, buf_size, num_edges, i, j, count = 0;
      IGRdouble tolr, *pars, *intpars, dist;
      struct GRid *sf_edges, *which_surf;
      IGRshort k, n;
      extern IGRint DYFUNCblendcv();

      BSxtractpar(msg, BSTOLCHRDHT, &tolr);
      memcpy(me->blendcv_buff.testpt, curr_sp->test_coord, sizeof(IGRpoint));

      /*
       * determine how many special points are on the same surface
       * as the current special point
       */
      me->blendcv_buff.ptr_spl_pts = me->spl_pts;
      num_spl_pts = 0;
      for (i = 0; i < me->curr_pnt_index; i++)
	if (i != me->curr_unused &&
	    me->spl_pts[i].used == FALSE &&
	    me->spl_pts[i].surf_index == surf_index)
	  num_spl_pts++;

      /*
       * If there are special points on the same surface,
       * then only u=0 or u=1 edges of the fillet surface
       * where special points are constructed are used
       */
      if (num_spl_pts > 0)
      {
	/*
	 * These special points are found via indices to the
	 * array where all special points are stored
	 */
	me->blendcv_buff.num_spl_pts = num_spl_pts;
	me->blendcv_buff.pt_indices = (IGRint *) alloca(num_spl_pts * sizeof(IGRint));
	for (i = 0, j = 0; i < me->curr_pnt_index; i++)
	  if (i != me->curr_unused &&
	      me->spl_pts[i].used == FALSE &&
	      me->spl_pts[i].surf_index == surf_index)
	    me->blendcv_buff.pt_indices[j++] = i;

	/*
	 * Get geometry of the edges on which special points lie
	 */
	me->blendcv_buff.num_edges = num_spl_pts;
	me->blendcv_buff.edges = (struct IGRbsp_curve *) alloca(num_spl_pts * sizeof(struct IGRbsp_curve));
	for (i = 0; i < num_spl_pts; i++)
	{
	  me->blendcv_buff.edges[i].poles = NULL;
	  me->blendcv_buff.edges[i].knots = NULL;
	  me->blendcv_buff.edges[i].weights = NULL;
	  j = me->blendcv_buff.pt_indices[i];
	  if (me->spl_pts[j].which_fillet == -1)
	    which_surf = &me->on_surfs[surf_index];
	  else
	    which_surf = &me->elems[me->spl_pts[j].which_fillet].located_obj;
	  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							       &me->active_md_env.md_env,
							       which_surf,
							       NULL,
							       0,
							       MAXINT,
							       FALSE,
							       NULL,
							       &me->blendcv_buff.edges[i]),
			targetid = me->spl_pts[j].edge_id.objid,
			targetos = me->spl_pts[j].edge_id.osnum);
	  EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);
	}
      }
      else
      {
	/*
	 * If no special points exist on the same surface, then
	 * surface edges will be used to find special edge on the
	 * save surface to create blend curve
	 */
	me->blendcv_buff.num_spl_pts = 0;
	me->blendcv_buff.pt_indices = NULL;

	/*
	 * Get the edges of the surface and their geometry
	 */
	buf_size = num_edges = 0;
	sts = om$send(msg = message EMSsurface.EMgetedges(msg,
							  EMS_OPT_NONDEG_NONSEAM,
							  &sf_edges,
							  &buf_size,
							  &num_edges,
							  NULL,
							  NULL,
							  NULL,
							  NULL),
		      targetid = me->on_surfs[surf_index].objid,
		      targetos = me->on_surfs[surf_index].osnum);
	EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);

	me->blendcv_buff.num_edges = num_edges;
	me->blendcv_buff.edges = (struct IGRbsp_curve *) alloca(num_edges * sizeof(struct IGRbsp_curve));
	count = 0;
	for (i = 0; i < num_edges; i++)
	{
	  me->blendcv_buff.edges[i].poles = NULL;
	  me->blendcv_buff.edges[i].knots = NULL;
	  me->blendcv_buff.edges[i].weights = NULL;
	  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							       &me->active_md_env.md_env,
							       &me->on_surfs[surf_index],
							       NULL,
							       0,
							       MAXINT,
							       FALSE,
							       NULL,
							       &me->blendcv_buff.edges[i]),
			targetid = sf_edges[i].objid,
			targetos = sf_edges[i].osnum);
	  EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);

	  /*
	   * determine whether the starting point lies on any edge
	   */
	  bspcv = &me->blendcv_buff.edges[i];
	  BSmdistptcv(bspcv, curr_sp->test_coord,
		      &k, &n, &pars, &dist, &intpars, msg);
	  if (n > 0 && pars)
	    om$dealloc(ptr = pars);
	  if (k > 0 && intpars)
	    om$dealloc(ptr = intpars);

	  if (fabs(dist) < tolr && !count)
	  {
	    BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
		      &me->bsp_start_edge, msg);
	    BScv_copy(msg, bspcv, me->bsp_start_edge);
	    count++;
	  }
	}
      }

      /*
       * If we cannot find an edge of the surface that the starting
       * special point is on, then we use boundary edges (on u=0 or u=1)
       * of the fillet surface where the special points are on
       */
      if (num_spl_pts > 0 || !count)
      {
	bspcv = (struct IGRbsp_curve *) alloca(sizeof(struct IGRbsp_curve));
	bspcv->poles = NULL;
	bspcv->knots = NULL;
	bspcv->weights = NULL;
	if (curr_sp->which_fillet == -1)
	  which_surf = &me->on_surfs[surf_index];
	else
	  which_surf = &me->elems[curr_sp->which_fillet].located_obj;
	sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							     &me->active_md_env.md_env,
							     which_surf,
							     NULL,
							     0,
							     MAXINT,
							     FALSE,
							     NULL,
							     bspcv),
		      targetid = curr_sp->edge_id.objid,
		      targetos = curr_sp->edge_id.osnum);
	EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);

	BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
		  &me->bsp_start_edge, msg);
	BScv_copy(msg, bspcv, me->bsp_start_edge);

	/*
	 * free memory allocated
	 */
	if (bspcv->poles)
	  om$dealloc(ptr = bspcv->poles);
	if (bspcv->knots)
	  om$dealloc(ptr = bspcv->knots);
	if (bspcv->weights)
	  om$dealloc(ptr = bspcv->weights);
      }
    
      /*
       * build display buffer for the rubberbanding line
       */
      dp$build_dis_buffer(buffer = &me->blendcv_buff.disp_hd[0],
			  type = IGRPY,
			  display_att = &dyncv_display,
			  geometry = (struct IGRpolyline *) &poly);

      memcpy(&dyn_display, &me->active_display, sizeof(struct IGRdisplay));
      if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 3)
	dyn_display.weight = sf_symb.display_attr.weight + 3;
      else
	dyn_display.weight = GR_HI_WEIGHT;

      /*
       * build display buffer for the edge
       */
      dp$build_dis_buffer(buffer = &me->blendcv_buff.disp_hd[1],
			  type = IGRBC,
			  display_att = &dyn_display,
			  ele_spec_att = &curve_att,
			  geometry = (struct IGRbsp_curve *) NULL);

      dp$dynamics(dyn_fun = DYFUNCblendcv,
		  information = &me->blendcv_buff);
      if (me->blendcv_buff.rc == DYN_SUCC_FIND_PT)
      {
	/*
	 * If special point is found, then the u=0 or u=1
	 * edge of the fillet surface will be used for creating
	 * blend curve
	 */
	bspcv = &me->blendcv_buff.edges[me->blendcv_buff.index];
	BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
		  &me->bsp_spl_edge, msg);
	BScv_copy(msg, bspcv, me->bsp_spl_edge);
	me->blendcv_buff.index =
	  me->blendcv_buff.pt_indices[me->blendcv_buff.index];
      }
      else if (me->blendcv_buff.rc == DYN_SUCC_FIND_EDGE)
      {
	/*
	 * Edge can only be found if there is no special point on
	 * the same surface as the starting special point
	 */
	bspcv = &me->blendcv_buff.edges[me->blendcv_buff.index];
	BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
		  &me->bsp_spl_edge, msg);
	BScv_copy(msg, bspcv, me->bsp_spl_edge);
	memcpy(&me->spl_edge_id, &sf_edges[me->blendcv_buff.index],
	       sizeof(struct GRid));
      }

      /*
       * free allocated memory
       */
      if (!num_spl_pts)
	om$dealloc(ptr = sf_edges);

      for (i = 0; i < me->blendcv_buff.num_edges; i++)
      {
	if (me->blendcv_buff.edges[i].poles)
	  om$dealloc(ptr = me->blendcv_buff.edges[i].poles);
	if (me->blendcv_buff.edges[i].knots)
	  om$dealloc(ptr = me->blendcv_buff.edges[i].knots);
	if (me->blendcv_buff.edges[i].weights)
	  om$dealloc(ptr = me->blendcv_buff.edges[i].weights);
      }
    }
    else
    {
      struct IGRpointset proj_cursor;
      struct IGRdisplay dyn_display;
      extern IGRint DYFUNCblendpt();

      /* build display buffer for the line and edge */
      dp$build_dis_buffer(buffer = &me->blendpt_buff.disp_hd[0],
			  type = IGRPY,
			  display_att = &dyncv_display,
			  geometry = (struct IGRpolyline *) &poly);

      dp$build_dis_buffer(buffer = &me->blendpt_buff.disp_hd[1],
			  type = IGRBC,
			  display_att = &dyncv_display,
			  ele_spec_att = &curve_att,
			  geometry = (struct IGRbsp_curve *) me->bsp_spl_edge);

      /* set up display buffer for the projected cursor point */
      proj_cursor.num_points = 1;
      proj_cursor.points = poly_pts + 3;
	
      memcpy(&dyn_display, &me->active_display, sizeof(struct IGRdisplay));
      if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 4)
	dyn_display.weight = sf_symb.display_attr.weight + 4;
      else
	dyn_display.weight = GR_HI_WEIGHT;
	
      dp$build_dis_buffer(buffer = &me->blendpt_buff.disp_hd[2],
			  type = IGRPS,
			  display_att = &dyn_display,
			  geometry = (struct IGRpointset *) &proj_cursor);
	
      dp$dynamics(dyn_fun = DYFUNCblendpt,
		  information = &me->blendpt_buff);
    }
  }
  else
  {
    /* get surface geometry */
    sts = EMget_the_geometry(&me->elems[me->curr_flt],
			     FALSE, FALSE, FALSE, my_id, &surf, msg);
    if (!(1 & sts & *msg))
    {
      *msg = MSFAIL;
      goto quit;
    }
    
    /* get surface symbology */
    sts = om$send(msg = message GRvg.GRgetsymb(msg, &sf_symb),
		  targetid = me->elems[me->curr_flt].located_obj.objid,
		  targetos = me->elems[me->curr_flt].located_obj.osnum);
    memcpy(&dyncv_display, &me->active_display, sizeof(struct IGRdisplay));
    if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 1)
      dyncv_display.weight = sf_symb.display_attr.weight + 1;
    else
      dyncv_display.weight = GR_HI_WEIGHT;
    
    switch (dynamics)
    {
    case ISOCV:
      {
	struct FilletBnd *curr_bnd;
	IGRint num_bndedges, curr_index, i;
	struct IGRdisplay dyn_display;
	extern IGRint DYFUNCisocv();
	
	/* initialize BSgeom_bsp_surf */
	me->isocv_buff.geomsurf.geom_prop = FALSE;
	me->isocv_buff.geomsurf.type = BSGEN_BSP_SF;
	me->isocv_buff.geomsurf.bounded = TRUE;
	me->isocv_buff.geomsurf.urange[0] = surf->u_knots[surf->u_order - 1];
	me->isocv_buff.geomsurf.urange[1] = surf->u_knots[surf->u_num_poles];
	me->isocv_buff.geomsurf.vrange[0] = surf->v_knots[surf->v_order - 1];
	me->isocv_buff.geomsurf.vrange[1] = surf->v_knots[surf->v_num_poles];
	me->isocv_buff.geomsurf.bspsf = surf;
	me->isocv_buff.geomsurf.sfgen_cv = NULL;
	
	me->isocv_buff.lc_surf = &me->elems[me->curr_flt];
	me->isocv_buff.pole_direction = V_DIRECTION;
	
	/* get parameter range of the boundary edges */
	memcpy(me->isocv_buff.parmrange, me->parm_ranges[me->curr_flt],
	       sizeof(ParmRange));
	
	/* get xyz geometry curve of the boundary edges */
	curr_bnd = &me->fillet_bounds[me->curr_flt];
	
	num_bndedges = curr_bnd->num_minbnd_edges;
	me->isocv_buff.num_min_xyzedges = num_bndedges;
	
	me->isocv_buff.min_xyzedges = (struct IGRbsp_curve *) alloca(num_bndedges * sizeof(struct IGRbsp_curve));
	
	for (i = 0; i < num_bndedges; i++)
	{
	  curr_index = curr_bnd->minbnd_edges_index + i;
	  me->isocv_buff.min_xyzedges[i].poles = NULL;
	  me->isocv_buff.min_xyzedges[i].knots = NULL;
	  me->isocv_buff.min_xyzedges[i].weights = NULL;
	  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							       NULL,
							       NULL,
							       surf,
							       0,
							       MAXINT,
							       FALSE,
							       NULL,
							       &me->isocv_buff.min_xyzedges[i]),
			senderid = my_id,
			targetid = me->bound_edges[curr_index].objid,
			targetos = me->bound_edges[curr_index].osnum);
	  EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);
	}
	
	num_bndedges = curr_bnd->num_maxbnd_edges;
	me->isocv_buff.num_max_xyzedges = num_bndedges;
	
	me->isocv_buff.max_xyzedges = (struct IGRbsp_curve *) alloca(num_bndedges * sizeof(struct IGRbsp_curve));
	
	for (i = 0; i < num_bndedges; i++)
	{
	  curr_index = curr_bnd->maxbnd_edges_index + i;
	  me->isocv_buff.max_xyzedges[i].poles = NULL;
	  me->isocv_buff.max_xyzedges[i].knots = NULL;
	  me->isocv_buff.max_xyzedges[i].weights = NULL;
	  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							       NULL,
							       NULL,
							       surf,
							       0,
							       MAXINT,
							       FALSE,
							       NULL,
							       &me->isocv_buff.max_xyzedges[i]),
			senderid = my_id,
			targetid = me->bound_edges[curr_index].objid,
			targetos = me->bound_edges[curr_index].osnum);
	  EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);
	}
	
	if (me->isocv_buff.num_min_xyzedges > num_bndedges)
	  num_bndedges = me->isocv_buff.num_min_xyzedges;
	
	me->isocv_buff.disp_hd = (struct DPele_header *) alloca((num_bndedges + 1) * sizeof(struct DPele_header));
	
	memcpy(&dyn_display, &me->active_display, sizeof(struct IGRdisplay));
	if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 3)
	  dyn_display.weight = sf_symb.display_attr.weight + 3;
	else
	  dyn_display.weight = GR_HI_WEIGHT;
	
	for (i = 1; i < num_bndedges + 1; i++)
	{
	  dp$build_dis_buffer(buffer = &me->isocv_buff.disp_hd[i],
			      type = IGRBC,
			      display_att = &dyn_display,
			      ele_spec_att = &curve_att,
			      geometry = (struct IGRbsp_curve *) NULL);
	}
	
	/* set up display buffer for the iso curve */
	BSalloccv(surf->u_order, surf->u_num_poles, surf->rational, 0,
		  &bspcv, msg);
	
	dp$build_dis_buffer(buffer = &me->isocv_buff.disp_hd[0],
			    type = IGRBC,
			    display_att = &dyncv_display,
			    ele_spec_att = &curve_att,
			    geometry = (struct IGRbsp_curve *) bspcv);
	
	dp$dynamics(dyn_fun = DYFUNCisocv,
		    information = &me->isocv_buff);
	
	for (i = 0; i < me->isocv_buff.num_min_xyzedges; i++)
	{
	  if (me->isocv_buff.min_xyzedges[i].poles)
	    om$dealloc(ptr = me->isocv_buff.min_xyzedges[i].poles);
	  if (me->isocv_buff.min_xyzedges[i].knots)
	    om$dealloc(ptr = me->isocv_buff.min_xyzedges[i].knots);
	  if (me->isocv_buff.min_xyzedges[i].weights)
	    om$dealloc(ptr = me->isocv_buff.min_xyzedges[i].weights);
	}
	for (i = 0; i < me->isocv_buff.num_max_xyzedges; i++)
	{
	  if (me->isocv_buff.max_xyzedges[i].poles)
	    om$dealloc(ptr = me->isocv_buff.max_xyzedges[i].poles);
	  if (me->isocv_buff.max_xyzedges[i].knots)
	    om$dealloc(ptr = me->isocv_buff.max_xyzedges[i].knots);
	  if (me->isocv_buff.max_xyzedges[i].weights)
	    om$dealloc(ptr = me->isocv_buff.max_xyzedges[i].weights);
	}
	
	break;
      }
    case PLANECUT_PT:
      {
	IGRboolean testplnr;
	IGRdouble parm;
	IGRshort opt;
	IGRpoint pt_coord;
	struct IGRpointset proj_cursor;
	struct IGRdisplay dyn_display;
	extern IGRint DYFUNCstartpt();
	
	me->startpt_buff.surf = surf;
	
	/* get parameter range */
	me->startpt_buff.min_parm =
	  me->parm_ranges[me->curr_flt][me->which_u * 2];
	me->startpt_buff.max_parm =
	  me->parm_ranges[me->curr_flt][me->which_u * 2 + 1];
	me->startpt_buff.uparm = (IGRdouble) me->which_u;
	
	/* set up display buffer for the iso curve */
	BSalloccv(surf->v_order, surf->v_num_poles, surf->rational, 0,
		  &bspcv, msg);
	BSalloccv(surf->v_order, surf->v_num_poles, surf->rational, 0,
		  &bspcv1, msg);
	
	/* extract iso curve of me->which_u */
	opt = U_DIRECTION;
	parm = (IGRdouble) me->which_u;
	testplnr = FALSE;
	BSconstprcv(msg, surf, &opt, &parm, &testplnr, bspcv);
	BSactivsplt(msg, bspcv, &me->startpt_buff.min_parm,
		    &me->startpt_buff.max_parm, bspcv1, &testplnr);
	
	me->startpt_buff.bdrycv = bspcv;
	BScveval(bspcv, me->startpt_buff.min_parm, 0,
		 me->startpt_buff.min_pt, msg);
	BScveval(bspcv, me->startpt_buff.max_parm, 0,
		 me->startpt_buff.max_pt, msg);
	
	/* set up display buffer for me->which_u curve */
	dp$build_dis_buffer(buffer = &me->startpt_buff.disp_hd[0],
			    type = IGRBC,
			    display_att = &dyncv_display,
			    ele_spec_att = &curve_att,
			    geometry = (struct IGRbsp_curve *) bspcv1);
	
	/* set up display buffer for the projected cursor point */
	proj_cursor.num_points = 1;
	proj_cursor.points = pt_coord;
	
	memcpy(&dyn_display, &me->active_display, sizeof(struct IGRdisplay));
	if (sf_symb.display_attr.weight < GR_HI_WEIGHT - 4)
	  me->startpt_buff.weight1 = sf_symb.display_attr.weight + 4;
	else
	  me->startpt_buff.weight1 = GR_HI_WEIGHT;
	if (me->startpt_buff.weight1 < GR_HI_WEIGHT - 3)
	  me->startpt_buff.weight2 = me->startpt_buff.weight1 + 3;
	else
	  me->startpt_buff.weight2 = GR_HI_WEIGHT;
	
	dp$build_dis_buffer(buffer = &me->startpt_buff.disp_hd[1],
			    type = IGRPS,
			    display_att = &dyn_display,
			    geometry = (struct IGRpointset *) &proj_cursor);
	
	dp$dynamics(dyn_fun = DYFUNCstartpt,
		    information = &me->startpt_buff);
	
	break;
      }
    case PLANECUT:
      {
	IGRshort opt;
	IGRdouble parm;
	IGRboolean testplnr;
	struct IGRdisplay dyn_display;
	struct IGRpolyline poly;
	extern IGRint DYFUNCplanecut();
	
	me->planecut_buff.lc_surf = &me->elems[me->curr_flt];
	me->planecut_buff.surf = surf;
	memcpy(me->planecut_buff.startpt, me->cutback_cvs[me->curr_flt].endpt1,
	       sizeof(IGRpoint));
	me->planecut_buff.uparm = (IGRdouble) ((me->which_u + 1) % 2);
	
	/* get parameter range */
	me->planecut_buff.min_parm =
	  me->parm_ranges[me->curr_flt][((me->which_u + 1) % 2) * 2];
	me->planecut_buff.max_parm =
	  me->parm_ranges[me->curr_flt][((me->which_u + 1) % 2) * 2 + 1];
	
	/* set up display buffer for the iso curve */
	BSalloccv(surf->v_order, surf->v_num_poles, surf->rational, 0,
		  &bspcv, msg);
	BSalloccv(surf->v_order, surf->v_num_poles, surf->rational, 0,
		  &bspcv1, msg);
	
	/* extract iso curve of u=0 or u=1 */
	opt = U_DIRECTION;
	parm = (IGRdouble) ((me->which_u + 1) % 2);
	testplnr = FALSE;
	BSconstprcv(msg, surf, &opt, &parm, &testplnr, bspcv);
	BSactivsplt(msg, bspcv, &me->planecut_buff.min_parm,
		    &me->planecut_buff.max_parm, bspcv1, &testplnr);
	
	me->planecut_buff.bdrycv = bspcv;
	BScveval(bspcv, me->planecut_buff.min_parm, 0,
		 me->planecut_buff.min_pt, msg);
	BScveval(bspcv, me->planecut_buff.max_parm, 0,
		 me->planecut_buff.max_pt, msg);
	
	/* set up display buffer for the other curve */
	dp$build_dis_buffer(buffer = &me->planecut_buff.disp_hd[0],
			    type = IGRBC,
			    display_att = &dyncv_display,
			    ele_spec_att = &curve_att,
			    geometry = (struct IGRbsp_curve *) bspcv1);
	
	poly.num_points = 0;
	poly.points = NULL;
	memcpy(&dyn_display, &dyncv_display, sizeof(struct IGRdisplay));
	me->planecut_buff.weight1 = dyncv_display.weight;
	if (me->planecut_buff.weight1 < GR_HI_WEIGHT - 3)
	  me->planecut_buff.weight2 = me->planecut_buff.weight1 + 3;
	else
	  me->planecut_buff.weight2 = GR_HI_WEIGHT;
	
	dp$build_dis_buffer(buffer = &me->planecut_buff.disp_hd[1],
			    type = IGRPY,
			    display_att = &dyn_display,
			    geometry = (struct IGRpolyline *) &poly);
	
	dp$dynamics(dyn_fun = DYFUNCplanecut,
		    information = &me->planecut_buff);
	
	break;
      }
    default:
      break;
    }
    
    if (bspcv)
      BSfreecv(msg, bspcv);
    if (bspcv1)
      BSfreecv(msg, bspcv1);
    om$dealloc(ptr = surf);
    surf = NULL;
  }
  
 quit:
  if (surf)
    om$dealloc(ptr = surf);
  if (*msg == MSFAIL)
    return OM_E_ABORT;
  else
    return sts;
}

method chk_gen_point(IGRlong *msg; IGRpoint gen_pt; IGRint type)
{
  struct IGRbsp_surface *surf;
  IGRdouble tolr, u, v, dist, *curr_rng, *pars, *intpars;
  IGRdouble minmin, minmax, maxmin, maxmax, uparm, vparm;
  IGRpoint basept;
  IGRvector midvec;
  struct FilletBnd *curr_bnd;
  struct CutBack *curr_cb;
  struct SpecialPnt *curr_sp;
  struct GRid *sf_edges;
  struct IGRbsp_curve *bspcv, *bsp_edges;
  IGRint surf_index, num_edges, buf_size, i, j;
  IGRshort k, n;
  IGRlong sts;
  BSrc rc;
  extern IGRlong EMget_the_geometry();
  extern IGRboolean BSmdistptsf(), BScv_copy(), BSfreecv();
  extern IGRdouble fabs(), BSdistptpt();
  extern void BSsfarrevn(), BSmdistptcv(), BSalloccv(), BScveval();

  sts = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  BSxtractpar(msg, BSTOLCHRDHT, &tolr);

  if (type == ISOCV || type == PLANECUT_PT || type == PLANECUT)
  {
    /* get surface geometry */
    sts = EMget_the_geometry(&me->elems[me->curr_flt],
			     FALSE, FALSE, FALSE, my_id, &surf, msg);
    if (!(1 & sts & *msg))
    {
      if (surf)
	om$dealloc(ptr = surf);
      *msg = MSFAIL;
      sts = OM_E_ABORT;
      goto quit;
    }
    
    BSmdistptsf(&rc, surf, gen_pt, &u, &v, basept, &dist);
    if (rc == BSSUCC)
    { 
      if (fabs(dist) < tolr)
      {
	curr_rng = me->parm_ranges[me->curr_flt];
	curr_bnd = &me->fillet_bounds[me->curr_flt];
	
	switch (type)
	{
	case ISOCV:
	  minmin = curr_rng[0];
	  minmax = curr_rng[2];
	  if (minmax < minmin)
	  {
	    minmax = minmin;
	    minmin = curr_rng[2];
	  }
	  maxmin = curr_rng[1];
	  maxmax = curr_rng[3];
	  if (maxmax < maxmin)
	  {
	    maxmax = maxmin;
	    maxmin = curr_rng[3];
	  }
	  
	  if (fabs(v - minmin) >= tolr && v < minmin ||
	      fabs(v - maxmax) >= tolr && v > maxmax)
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
	    *msg = MSFAIL;
	  }
	  else
	  {
	    curr_cb = &me->cutback_cvs[me->curr_flt];
	    
	    if (((minmax - minmin) > tolr && v > minmin && v < minmax) ||
		((minmax - minmin) <= tolr && v < minmax &&
		 fabs(v - minmin) <= tolr))
	    {
	      curr_cb->type = BOUNDARY;
	      
	      uparm = 0.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &curr_rng[0],
			 curr_cb->endpt1, curr_cb->testvec1);
	      uparm = 1.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &curr_rng[2],
			 curr_cb->endpt2, curr_cb->testvec2);
	      uparm = 0.5;
	      vparm = (curr_rng[0] + curr_rng[2]) / 2.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &vparm,
			 curr_cb->midpt, midvec);

	      curr_cb->cutcv.bdry.index = curr_bnd->minbnd_edges_index;
	      curr_cb->cutcv.bdry.num_edges = curr_bnd->num_minbnd_edges;
	    }
	    else if (((maxmax - maxmin) > tolr && v > maxmin && v < maxmax) ||
		     ((maxmax - maxmin) <= tolr && v > maxmin &&
		      fabs(v - maxmax) <= tolr))
	    {
	      curr_cb->type = BOUNDARY;
	      
	      uparm = 0.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &curr_rng[1],
			 curr_cb->endpt1, curr_cb->testvec1);
	      uparm = 1.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &curr_rng[3],
			 curr_cb->endpt2, curr_cb->testvec2);
	      uparm = 0.5;
	      vparm = (curr_rng[1] + curr_rng[3]) / 2.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &vparm,
			 curr_cb->midpt, midvec);

	      curr_cb->cutcv.bdry.index = curr_bnd->maxbnd_edges_index;
	      curr_cb->cutcv.bdry.num_edges = curr_bnd->num_maxbnd_edges;
	    }
	    else
	    {
	      curr_cb->type = ISOCV;
	      
	      if (fabs(v - minmax) < tolr && v >= minmax)
		v = minmax;
	      else if (fabs(v - maxmin) < tolr && v <= maxmin)
		v = maxmin;
	      
	      uparm = 0.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &v,
			 curr_cb->endpt1, curr_cb->testvec1);
	      uparm = 1.0;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &v,
			 curr_cb->endpt2, curr_cb->testvec2);
	      uparm = 0.5;
	      BSsfarrevn(msg, surf, 1, &uparm, 1, &v,
			 curr_cb->midpt, midvec);
	      
	      curr_cb->cutcv.isocv_parm = v;
	    }

	    uparm = 0.0;
	    v = (curr_rng[0] + curr_rng[1]) / 2.0;
	    BSsfarrevn(msg, surf, 1, &uparm, 1, &v,
		       curr_cb->testpt1, curr_cb->testvec1);
	    uparm = 1.0;
	    v = (curr_rng[2] + curr_rng[3]) / 2.0;
	    BSsfarrevn(msg, surf, 1, &uparm, 1, &v,
		       curr_cb->testpt2, curr_cb->testvec2);

	    *msg = MSSUCC;
	  }
	  break;
	  
	case PLANECUT_PT:
	case PLANECUT:
	  if (fabs(u - me->which_u) < tolr)
	  {
	    if ((me->which_u == 0 &&
		 (fabs(v - curr_rng[0]) >= tolr && v < curr_rng[0]) ||
		 (fabs(v - curr_rng[1]) >= tolr && v > curr_rng[1])) ||
		(me->which_u == 1 &&
		 (fabs(v - curr_rng[2]) >= tolr && v < curr_rng[2]) ||
		 (fabs(v - curr_rng[3]) >= tolr && v > curr_rng[3])))
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
	      *msg = MSFAIL;
	    }
	    else
	    {
	      curr_cb = &me->cutback_cvs[me->curr_flt];
	      curr_cb->type = PLANECUT;
	      
	      if (me->which_u == 0)
	      {
		if (fabs(v - curr_rng[0]) < tolr)
		  v = curr_rng[0];
		else if (fabs(v - curr_rng[1]) < tolr)
		  v = curr_rng[1];
		vparm = (curr_rng[0] + curr_rng[1]) / 2.0;
	      }
	      else
	      {
		if (fabs(v - curr_rng[2]) < tolr)
		  v = curr_rng[2];
		else if (fabs(v - curr_rng[3]) < tolr)
		  v = curr_rng[3];
		vparm = (curr_rng[2] + curr_rng[3]) / 2.0;
	      }
	      
	      if (type == PLANECUT_PT)
	      {
		BSsfarrevn(msg, surf, 1, (IGRdouble *) &me->which_u, 1, &v,
			   curr_cb->endpt1, curr_cb->testvec1);
		BSsfarrevn(msg, surf, 1, (IGRdouble *) &me->which_u, 1, &vparm,
			   curr_cb->testpt1, curr_cb->testvec1);
	      }
	      else
	      {
		BSsfarrevn(msg, surf, 1, (IGRdouble *) &me->which_u, 1, &v,
			   curr_cb->endpt2, curr_cb->testvec2);
		BSsfarrevn(msg, surf, 1, (IGRdouble *) &me->which_u, 1, &vparm,
			   curr_cb->testpt2, curr_cb->testvec2);
	      }
	      
	      *msg = MSSUCC;
	    }
	  }
	  else
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
	    *msg = MSFAIL;
	  }
	  break;
	}
      }
      else
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
	*msg = MSFAIL;
      }
    }
    else
      sts = OM_E_ABORT;
    
    if (surf)
      om$dealloc(ptr = surf);
  }
  else
  {
    if (type == BLENDCV)
    {
      curr_sp = &me->spl_pts[me->curr_unused];
      surf_index = curr_sp->surf_index;
      
      /* get the edges of the surface */
      buf_size = num_edges = 0;
      sts = om$send(msg = message EMSsurface.EMgetedges(msg,
							EMS_OPT_NONDEG_NONSEAM,
							&sf_edges,
							&buf_size,
							&num_edges,
							NULL,
							NULL,
							NULL,
							NULL),
		    targetid = me->on_surfs[surf_index].objid,
		    targetos = me->on_surfs[surf_index].osnum);
      EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);
      
      bsp_edges = (struct IGRbsp_curve *) alloca(num_edges * sizeof(struct IGRbsp_curve));
      for (i = 0; i < num_edges; i++)
      {
	bsp_edges[i].poles = NULL;
	bsp_edges[i].knots = NULL;
	bsp_edges[i].weights = NULL;
	sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							     &me->active_md_env.md_env,
							     &me->on_surfs[surf_index],
							     NULL,
							     0,
							     MAXINT,
							     FALSE,
							     NULL,
							     &bsp_edges[i]),
		      targetid = sf_edges[i].objid,
		      targetos = sf_edges[i].osnum);
	EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);
      }
      
      /* check to see if gen_pt is close to any special point */
      for (i = 0; i < me->curr_pnt_index; i++)
	if (i != me->curr_unused &&
	    me->spl_pts[i].used == FALSE &&
	    me->spl_pts[i].surf_index == surf_index &&
	    BSdistptpt(msg, gen_pt, me->spl_pts[i].pt_coord) < tolr)
	  break;
      
      if (i < me->curr_pnt_index)
      {
	/* find the edge that the point lies on */
	for (j = 0; j < num_edges; j++)
	{
	  bspcv = &bsp_edges[j];
	  BSmdistptcv(bspcv, me->spl_pts[i].pt_coord,
		      &k, &n, &pars, &dist, &intpars, msg);
	  if (n > 0 && pars)
	    om$dealloc(ptr = pars);
	  if (k > 0 && intpars)
	    om$dealloc(ptr = intpars);
	  
	  if (fabs(dist) < tolr)
	  {
	    me->blendcv_buff.index = i;
	    me->blendcv_buff.rc = DYN_SUCC_FIND_PT;
	    
	    BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
		      &me->bsp_spl_edge, msg);
	    BScv_copy(msg, bspcv, me->bsp_spl_edge);
	    
	    /* mark the special points to be used */
	    curr_sp->used = TRUE;
	    
	    *msg = MSSUCC;
	    break;
	  }
	}
	if (j == num_edges)
	  *msg = MSFAIL;
      }
      else
      {
	/* check to see whether we find an edge on the same surface */
	for (i = 0; i < num_edges; i++)
	{
	  /*
	  if (sf_edges[i].objid != me->start_edge_id.objid)
	  */
	  {
	    bspcv = &bsp_edges[i];
	    BSmdistptcv(bspcv, gen_pt, &k, &n, &pars, &dist, &intpars, msg);
	    if (n > 0 && pars)
	      om$dealloc(ptr = pars);
	    if (k > 0 && intpars)
	      om$dealloc(ptr = intpars);
	    
	    if (fabs(dist) < tolr)
	    {
	      /* if a line has a special point, then find the point */
	      for (j = 0; j < me->curr_pnt_index; j++)
	      {
		if (j != me->curr_unused)
		{
		  BSmdistptcv(bspcv, me->spl_pts[j].pt_coord, &k, &n, &pars,
			      &dist, &intpars, msg);
		  if (n > 0 && pars)
		    om$dealloc(ptr = pars);
		  if (k > 0 && intpars)
		    om$dealloc(ptr = intpars);
		  
		  if (fabs(dist) < tolr)
		  {
		    me->blendcv_buff.index = j;
		    me->blendcv_buff.rc = DYN_SUCC_FIND_PT;
		    
		    BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational,
			      0, &me->bsp_spl_edge, msg);
		    BScv_copy(msg, bspcv, me->bsp_spl_edge);
		    
		    /* mark the special points to be used */
		    curr_sp->used = TRUE;
		    
		    *msg = MSSUCC;
		    break;
		  }
		}
	      }
	      
	      if (j == me->curr_pnt_index)
	      {
		me->blendcv_buff.index = i;
		me->blendcv_buff.rc = DYN_SUCC_FIND_EDGE;
		
		/* find edge */
		curr_sp->used = TRUE;
		
		BSalloccv(bspcv->order, bspcv->num_poles, bspcv->rational, 0,
			  &me->bsp_spl_edge, msg);
		BScv_copy(msg, bspcv, me->bsp_spl_edge);
	      }
	      break;
	    }
	  }
	}
	if (i == num_edges)
	  *msg = MSFAIL;
	else
	  *msg = MSSUCC;
      }
    
      /* free memory */
      om$dealloc(ptr = sf_edges);
      for (i = 0; i < num_edges; i++)
      {
	if (bsp_edges[i].poles)
	  om$dealloc(ptr = bsp_edges[i].poles);
	if (bsp_edges[i].knots)
	  om$dealloc(ptr = bsp_edges[i].knots);
	if (bsp_edges[i].weights)
	  om$dealloc(ptr = bsp_edges[i].weights);
      }
    }
    else
    {
      BSmdistptcv(me->bsp_spl_edge, gen_pt,
		  &k, &n, &pars, &dist, &intpars, msg);
      if (n > 0 && pars)
	om$dealloc(ptr = pars);
      if (k > 0 && intpars)
	om$dealloc(ptr = intpars);
      
      if (fabs(dist) < tolr)
      {
	memcpy(me->blendpt_buff.edge_pt, gen_pt, sizeof(IGRpoint));
	bspcv = me->bsp_spl_edge;
	uparm = (bspcv->knots[bspcv->order - 1] +
		 bspcv->knots[bspcv->num_poles]) / 2.0;
	BScveval(bspcv, uparm, 0, me->blendpt_buff.testpt, msg);
	me->blendpt_buff.rc = DYN_SUCCESS;
	*msg = MSSUCC;
      }
      else
	*msg = MSFAIL;
    }
  }

 quit:
  return sts;
}

method refine_cut_curve_endpoints(IGRlong *msg; IGRint index;
				  struct GRid *cls_sf1, *cls_sf2;)
{
  IGRdouble radius;
  IGRvector vec1, vec2, normal;
  IGRpoint proj_pt1, proj_pt2, ref_pt1, ref_pt2;
  IGRdouble uv_pt1[2], uv_pt2[2];
  IGRboolean u0_on_sf, nat_normal1, nat_normal2;
  IGRlong sts, loc_msg;
  GRobjid new_objid;
  struct GRparms parms;
  struct IGRplane plane;
  struct EMSdataselect fillet, sf1, sf2, sf3;
  struct GRlc_info lc_surf;
  struct GRpost_info info;
  struct CutBack *curr_cb;
  struct IGRbsp_surface *mod_fillet;
  extern IGRboolean BSmkvec(), BScrossp(), BSfreesf();
  extern IGRint EMdetermine_nat_side();
  extern IGRint EMget_fillet_radius();
  extern IGRlong EMsingle_fillet_refine();

  /*
   * Initialize
   */
  curr_cb = &me->cutback_cvs[index];

  /*
   * Set up EMSdataselect for fillet and surfaces
   */
  fillet.datatype = EMSdata_object;
  fillet.data.object = &me->elems[index].located_obj;

  sf1.datatype = EMSdata_object;
  sf1.data.object = cls_sf1;
  sf2.datatype = EMSdata_object;
  sf2.data.object = cls_sf2;

  /*
   * Find two approximate points on surface1 and surface2 by
   * projecting the endpoints of the cut back curve to the
   * two surfaces.
   */
  sts = om$send(msg = message GRgraphics.GRptproject(&loc_msg,
						     &me->active_md_env.md_env.matrix_type,
						     me->active_md_env.md_env.matrix,
						     curr_cb->endpt1,
						     proj_pt1,
						     &parms),
		targetid = cls_sf1->objid,
		targetos = cls_sf1->osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
  uv_pt1[0] = parms.u;
  uv_pt1[1] = parms.v;

  sts = om$send(msg = message GRgraphics.GRptproject(&loc_msg,
						     &me->active_md_env.md_env.matrix_type,
						     me->active_md_env.md_env.matrix,
						     curr_cb->endpt2,
						     proj_pt2,
						     &parms),
		targetid = cls_sf2->objid,
		targetos = cls_sf2->osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
  uv_pt2[0] = parms.u;
  uv_pt2[1] = parms.v;

  /*
   * Construct surface 3
   */
  BSmkvec(&loc_msg, vec1, curr_cb->midpt, proj_pt1);
  BSmkvec(&loc_msg, vec2, curr_cb->midpt, proj_pt2);
  BScrossp(&msg, vec1, vec2, normal);
  plane.point = curr_cb->midpt;
  plane.normal = normal;
	     
  sf3.datatype = EMSdata_plane;
  sf3.data.plane = &plane;
  
  /*
   * Get fillet surface radius
   */
  EMget_fillet_radius(&loc_msg, NULL, &me->elems[index], TRUE, &radius);

  /*
   * Determine which side of cls_sf1 and cls_sf2 the fillet lies
   */
  memcpy(&lc_surf.located_obj, cls_sf1, sizeof(struct GRid));
  memcpy(&lc_surf.module_info, &me->active_md_env, sizeof(struct GRmd_env));

  EMdetermine_nat_side(&loc_msg, NULL, &lc_surf, proj_pt2, &nat_normal1);
  
  memcpy(&lc_surf.located_obj, cls_sf2, sizeof(struct GRid));
  memcpy(&lc_surf.module_info, &me->active_md_env, sizeof(struct GRmd_env));

  EMdetermine_nat_side(&loc_msg, NULL, &lc_surf, proj_pt1, &nat_normal2);

  /*
   * Determine which surface fillet u0 is on
   */
  if (curr_cb->type == PLANECUT)
    u0_on_sf = curr_cb->cutcv.cutpln.which_u ? FALSE : TRUE;
  else
    u0_on_sf = TRUE;

  /*
   * Refine the fillet to pass the first point
   */
  mod_fillet = NULL;
  sts = EMsingle_fillet_refine(&loc_msg, NULL, &me->active_md_env,
			       &fillet, &sf1, &sf2, &sf3,
			       uv_pt1, u0_on_sf, radius,
			       NULL, nat_normal1, nat_normal2,
			       &mod_fillet, ref_pt1, NULL, NULL);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  /*
   * Post modified fillet geometry
   */
  info.construct_flag = FALSE;
  sts = om$send(msg = message GRvg.GRpostabsg(&loc_msg,
					      &me->elems[index].module_info,
					      &info,
					      (IGRchar *) mod_fillet,
					      &new_objid),
		targetid = me->elems[index].located_obj.objid,
		targetos = me->elems[index].located_obj.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  GRabsg_del_by_objid(&me->elems[index].located_obj.objid,
		      &me->elems[index].located_obj.osnum);

  /*
   * Delete memory allocated for modified fillet
   */
  BSfreesf(&loc_msg, mod_fillet);

  /*
   * Determine which surface fillet u0 is on
   */
  if (curr_cb->type == PLANECUT)
    u0_on_sf = curr_cb->cutcv.cutpln.which_u ? TRUE : FALSE;
  else
    u0_on_sf = FALSE;

  /*
   * Refine the fillet to pass the second point
   */
  mod_fillet = NULL;
  sts = EMsingle_fillet_refine(&loc_msg, NULL, &me->active_md_env,
			       &fillet, &sf2, &sf1, &sf3,
			       uv_pt2, u0_on_sf, radius,
			       NULL, nat_normal2, nat_normal1,
			       &mod_fillet, ref_pt2, NULL, NULL);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  /*
   * Post modified fillet geometry
   */
  info.construct_flag = FALSE;
  sts = om$send(msg = message GRvg.GRpostabsg(&loc_msg,
					      &me->elems[index].module_info,
					      &info,
					      (IGRchar *) mod_fillet,
					      &new_objid),
		targetid = me->elems[index].located_obj.objid,
		targetos = me->elems[index].located_obj.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  GRabsg_del_by_objid(&me->elems[index].located_obj.objid,
		      &me->elems[index].located_obj.osnum);

  /*
   * Delete memory allocated for modified fillet
   */
  BSfreesf(&loc_msg, mod_fillet);

  /*
   * Adjust data points
   */
  memcpy(curr_cb->endpt1, ref_pt1, sizeof(IGRpoint));
  memcpy(curr_cb->endpt2, ref_pt2, sizeof(IGRpoint));
  
 quit:
  return sts;
}

method construct_spl_point(IGRlong *msg; IGRpoint pt_coord, test_coord;
			   struct GRid *on_surf, *edge_id; IGRint fillet)
{
  IGRdouble bsppt_poles[6], bsppt_knots[4];
  struct IGRbsp_curve bsppt;
  struct GRvg_construct cnst;
  struct IGRdisplay pt_display;
  struct GRmd_env pt_env;
  IGRint vla_size, surf_index, k;
  struct SpecialPnt *curr_sp;
  IGRlong sts, loc_msg;

  sts = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  /* initialize bsp point */
  bsppt.order = 2;
  bsppt.periodic = FALSE;
  bsppt.non_uniform = FALSE;
  bsppt.num_poles = 2;
  bsppt.poles = bsppt_poles;
  memcpy(bsppt_poles, pt_coord, sizeof(IGRpoint));
  memcpy(bsppt_poles + 3, pt_coord, sizeof(IGRpoint));
  bsppt.num_knots = 4;
  bsppt.knots = bsppt_knots;
  bsppt_knots[0] = bsppt_knots[1] = 0.0;
  bsppt_knots[2] = bsppt_knots[3] = 1.0;
  bsppt.rational = FALSE;
  bsppt.weights = NULL;
  bsppt.planar = TRUE;
  bsppt.phy_closed = FALSE;
  bsppt.num_boundaries = 0;
  bsppt.bdrys = NULL;

  /* initialize vg construct list */
  memcpy(&pt_display, &me->active_display, sizeof(struct IGRdisplay));
  pt_display.weight = pt_display.weight + 4;
  memcpy(&pt_env, &me->active_md_env, sizeof(struct GRmd_env));
  pt_env.md_id.objid = NULL_OBJID;

  cnst.msg = &loc_msg;
  cnst.env_info = &pt_env;
  cnst.newflag = FALSE;
  cnst.level = me->active_level;
  cnst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE; /*| GRNOT_IN_RTREE;*/
  cnst.geometry = (IGRchar *) &bsppt;
  cnst.display = &pt_display;
  cnst.class_attr = NULL;
  cnst.name = NULL;

  surf_index = me->curr_onsurf_index;
  for (k = 0; k < me->curr_onsurf_index; k++)
    if (on_surf->objid == me->on_surfs[k].objid &&
	on_surf->osnum == me->on_surfs[k].osnum)
    {
      surf_index = k;
      break;
    }	      

  if (k == me->curr_onsurf_index)
  {
    /* expand array if necessary for storing closest surface */
    vla_size = om$dimension_of(varray = me->on_surfs);
    if ((me->curr_onsurf_index + 1) > vla_size)
    {
      sts = om$vla_set_dimension(varray = me->on_surfs,
				 size = me->curr_onsurf_index +
				 ELEMS_ARRAY_INCR);
      EMomerr_exit(sts, quit);
    }
    
    /* store the surface */
    me->on_surfs[me->curr_onsurf_index].objid = on_surf->objid;
    me->on_surfs[me->curr_onsurf_index].osnum = on_surf->osnum;
    me->curr_onsurf_index++;
  }

  /* expand array if necessary for storing special point */
  vla_size = om$dimension_of(varray = me->spl_pts);
  if ((me->curr_pnt_index + 1) > vla_size)
  {
    sts = om$vla_set_dimension(varray = me->spl_pts,
			       size = me->curr_pnt_index +
			       ELEMS_ARRAY_INCR);
    EMomerr_exit(sts, quit);
  }

  curr_sp = &me->spl_pts[me->curr_pnt_index];

  /* construct the special point */
  sts = om$construct(classid = OPP_GR3dpoint_class_id,
		     msg = message GRgraphics.GRconstruct(&cnst),
		     osnum = me->active_md_env.md_id.osnum,
		     p_objid = &curr_sp->pt_id.objid);
  curr_sp->pt_id.osnum = me->active_md_env.md_id.osnum;

  /* display the constructed point */
  gr$display_object(object_id = &curr_sp->pt_id,
		    mode = GRbd);

  memcpy(curr_sp->pt_coord, pt_coord, sizeof(IGRpoint));
  memcpy(curr_sp->test_coord, test_coord, sizeof(IGRpoint));
  curr_sp->which_fillet = fillet;
  curr_sp->surf_index = surf_index;
  memcpy(&curr_sp->edge_id, edge_id, sizeof(struct GRid));
  curr_sp->used = FALSE;
	  
  me->curr_pnt_index++;

 quit:
  return sts;
}

/*
Abstract
    This function constructs a blend curve on the surface. It takes
    two special points and con

    INPUTS
    pt1, pt2	- Coordinates of the two special points
    index1, index2
		- Indices into the array me->spl_pts[] where special
		  points are stored
    surf_index	- Index into the array me->on_surfs[] where surfaces
                  on which blend curves lie are stored
    type	- SPL_PT_TO_SPL_PT: blend from special point to special point
    		  SPL_PT_TO_EDGE_PT: blend from special point to a special
		                     point of nonfillet edge

    OUTPUTS
    msg		- return code:
    
*/

method construct_blend_curve(IGRlong *msg; IGRpoint pt1, pt2;
			     IGRint index1, index2, surf_index;
			     IGRboolean type)
{
  IGRint vla_size, which_fillet, i;
  IGRdouble dist, *pars, *intpars, u1, u2, ratio1, ratio2, *loc_pt;
  IGRdouble gd_val, test_u;
  IGRboolean dir1, dir2;
  struct GRlc_info lc_surf;
  struct BSgeom_bsp_surf geom_bspsf;
  struct BlendCv *curr_bcv;
  struct SpecialPnt *curr_sp;
  struct IGRbsp_surface *bspsf;
  IGRshort k, n;
  IGRlong loc_msg, sts;
  extern IGRlong EMget_the_geometry();
  extern void EFinit_geom_surface();
  extern void BSmdistptcv(), BSblndcvosf();
  extern void EFdisplay_bspcv();
  extern IGRdouble fabs();

  sts = OM_S_SUCCESS;
  *msg = MSSUCC;
  test_u = u1 = u2 = 1.0;
  
  vla_size = om$dimension_of(varray = me->blend_cvs);
  if ((me->curr_blend_index + 1) > vla_size)
  {
    sts = om$vla_set_dimension(varray = me->blend_cvs,
			       size = me->curr_blend_index +
			       ELEMS_ARRAY_INCR);
    EMomerr_exit(sts, quit);
  }
  curr_bcv = &me->blend_cvs[me->curr_blend_index];
  curr_bcv->newpt = (type == SPL_PT_TO_EDGE_PT ? 1 : 0);
  curr_bcv->index1 = index1;
  curr_bcv->index2 = index2;
  curr_bcv->surf_index = surf_index;

  /*
   * Get the surface geometry
   */
  memcpy(&lc_surf.located_obj, &me->on_surfs[surf_index], sizeof(struct GRid));
  memcpy(&lc_surf.module_info, &me->active_md_env, sizeof(struct GRmd_env));
  
  sts = EMget_the_geometry(&lc_surf, FALSE, FALSE, FALSE, my_id, &bspsf, &loc_msg);
  if (!(1 & sts & loc_msg))
  {
    if (bspsf)
      om$dealloc(ptr = bspsf);
    sts = OM_E_ABORT;
    goto quit;
  }

  /*
   * Calculate the u parameters on the edges to place blend curve
   */
  BSmdistptcv(me->bsp_start_edge, pt1, &k, &n, &pars,
	      &dist, &intpars, &loc_msg);
  if (n > 0 && pars)
  {
    u1 = 1.0;
    for (i = 0; i < n; i++)
      if (pars[i] < u1)
	u1 = pars[i];
    om$dealloc(ptr = pars);
  }
  if (k > 0 && intpars)
    om$dealloc(ptr = intpars);

  BSmdistptcv(me->bsp_spl_edge, pt2, &k, &n, &pars,
	      &dist, &intpars, &loc_msg);
  if (n > 0 && pars)
  {
    u2 = 1.0;
    for (i = 0; i < n; i++)
      if (pars[i] < u2)
	u2 = pars[i];
    om$dealloc(ptr = pars);
  }
  if (k > 0 && intpars)
    om$dealloc(ptr = intpars);

  curr_bcv->u1 = u1;
  curr_bcv->u2 = u2;

  /*
   * Determine the curve directions for placing the blend curve
   */
  curr_sp = &me->spl_pts[index1];
  if ((which_fillet = curr_sp->which_fillet) == -1)
    dir1 = TRUE;
  else
  {
    loc_pt = me->locevents[which_fillet].located_object[0].proj_pnt;
    BSmdistptcv(me->bsp_start_edge, loc_pt, &k, &n, &pars,
		&dist, &intpars, &loc_msg);
    if (k > 0 && intpars)
      om$dealloc(ptr = intpars);
    if (n > 0 && pars)
    {
      test_u = pars[0];
      om$dealloc(ptr = pars);
    }
    else
      dir1 = TRUE;

    loc_pt = curr_sp->pt_coord;
    BSmdistptcv(me->bsp_start_edge, loc_pt, &k, &n, &pars,
		&dist, &intpars, &loc_msg);
    if (k > 0 && intpars)
      om$dealloc(ptr = intpars);
    if (n > 0 && pars)
    {
      dir1 = (test_u >= pars[0] ? TRUE : FALSE);
      om$dealloc(ptr = pars);
    }
    else
      dir1 = TRUE;
  }

  curr_sp = &me->spl_pts[index2];
  if (type == SPL_PT_TO_EDGE_PT ||
      (which_fillet = curr_sp->which_fillet) == -1)
    dir2 = TRUE;
  else
  {
    loc_pt = me->locevents[which_fillet].located_object[0].proj_pnt;
    BSmdistptcv(me->bsp_spl_edge, loc_pt, &k, &n, &pars,
		&dist, &intpars, &loc_msg);
    if (k > 0 && intpars)
      om$dealloc(ptr = intpars);
    if (n > 0 && pars)
    {
      test_u = pars[0];
      om$dealloc(ptr = pars);
    }
    else
      dir2 = TRUE;
    
    loc_pt = curr_sp->pt_coord;
    BSmdistptcv(me->bsp_spl_edge, loc_pt, &k, &n, &pars,
		&dist, &intpars, &loc_msg);
    if (k > 0 && intpars)
      om$dealloc(ptr = intpars);
    if (n > 0 && pars)
    {
      dir2 = (test_u >= pars[0] ? TRUE : FALSE);
      om$dealloc(ptr = pars);
    }
    else
      dir2 = TRUE;
  }
  curr_bcv->dir1 = dir1;
  curr_bcv->dir2 = dir2;

  /*
   * Use the default form ratio
   */
  if (me->fm_ratio1)
    ratio1 = (IGRdouble) me->fm_ratio1 / 50.0;
  else
    ratio1 = 0.02;
  if (me->fm_ratio2)
    ratio2 = (IGRdouble) me->fm_ratio2 / 50.0;
  else
    ratio2 = 0.02;
  curr_bcv->ratio1 = ratio1;
  curr_bcv->ratio2 = ratio2;
  
  /*
   * Initialize BSgeom_bsp_surf structure
   */
  EFinit_geom_surface(&loc_msg, bspsf,
		      me->on_surfs[surf_index].objid,
		      me->on_surfs[surf_index].osnum,
		      &geom_bspsf);

  /*
   * Call math to fit a blending curve
   */
  curr_bcv->bspcv = NULL;
  BSblndcvosf(me->bsp_start_edge, u1, dir1, 1, ratio1,
	      me->bsp_spl_edge, u2, dir2, 1, ratio2,
	      &geom_bspsf,
	      &curr_bcv->bspcv,
	      (IGRint *) &curr_bcv->uvln.num_points,
	      &curr_bcv->uvln.points,
	      &curr_bcv->uvcv,
	      &loc_msg);
  if (loc_msg != BSSUCC)
  {
    curr_bcv->bspcv = NULL;
    curr_bcv->uvln.num_points = 0;
    curr_bcv->uvln.points = NULL;
    curr_bcv->uvcv = NULL;

    sts = OM_E_ABORT;
  }

  me->ratio1 = ratio1;
  me->ratio2 = ratio2;

  gd_val = (IGRdouble) me->fm_ratio1;
  FIg_set_value(me->stat_fm, SLIDER1, gd_val);
  gd_val = (IGRdouble) me->fm_ratio2;
  FIg_set_value(me->stat_fm, SLIDER2, gd_val);

  me->curr_blend_index++;

  EFdisplay_bspcv(curr_bcv->bspcv, &me->active_display, GRbd);

  if (!me->form_avail)
    me->form_avail = TRUE;

  if (bspsf)
    om$dealloc(ptr = bspsf);

 quit:
  return sts;
}

method modify_blend_curve(IGRlong *msg)
{
  struct BlendCv *curr_bcv;
  struct SpecialPnt *curr_sp;
  struct GRid *which_surf;
  struct IGRbsp_surface *bspsf;
  struct IGRbsp_curve edge1, edge2;
  struct GRlc_info lc_surf;
  struct BSgeom_bsp_surf geom_bspsf;
  IGRlong loc_msg, sts;
  extern IGRboolean BSfreecv();
  extern IGRlong EMget_the_geometry();
  extern void EFinit_geom_surface();
  extern void BSblndcvosf(), EFdisplay_bspcv();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  curr_bcv = &me->blend_cvs[me->curr_blend_index - 1];
  
  /*
   * Erase the old blend curve and free memory allocated
   */
  if (curr_bcv->bspcv)
  {
    EFdisplay_bspcv(curr_bcv->bspcv, &me->active_display, GRbe);
    BSfreecv(&loc_msg, curr_bcv->bspcv);
    curr_bcv->bspcv = NULL;
  }
  
  /*
   * Get the surface geometry
   */
  memcpy(&lc_surf.located_obj, &me->on_surfs[curr_bcv->surf_index],
	 sizeof(struct GRid));
  memcpy(&lc_surf.module_info, &me->active_md_env, sizeof(struct GRmd_env));
  
  sts = EMget_the_geometry(&lc_surf, FALSE, FALSE, FALSE, my_id, &bspsf, &loc_msg);
  if (!(1 & sts & loc_msg))
  {
    if (bspsf)
      om$dealloc(ptr = bspsf);
    sts = OM_E_ABORT;
    goto quit;
  }

  /*
   * Get geometry of the first edge
   */
  curr_sp = &me->spl_pts[curr_bcv->index1];
  if (curr_sp->which_fillet == -1)
    which_surf = &me->on_surfs[curr_sp->surf_index];
  else
    which_surf = &me->elems[curr_sp->which_fillet].located_obj;

  edge1.poles = NULL;
  edge1.knots = NULL;
  edge1.weights = NULL;
  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&loc_msg,
						       &me->active_md_env.md_env,
						       which_surf,
						       NULL,
						       0,
						       MAXINT,
						       FALSE,
						       NULL,
						       &edge1),
		targetid = curr_sp->edge_id.objid,
		targetos = curr_sp->edge_id.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  /*
   * Get geometry of the second edge
   */
  curr_sp = &me->spl_pts[curr_bcv->index2];
  if (curr_sp->which_fillet == -1)
    which_surf = &me->on_surfs[curr_sp->surf_index];
  else
    which_surf = &me->elems[curr_sp->which_fillet].located_obj;

  edge2.poles = NULL;
  edge2.knots = NULL;
  edge2.weights = NULL;
  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&loc_msg,
						       &me->active_md_env.md_env,
						       which_surf,
						       NULL,
						       0,
						       MAXINT,
						       FALSE,
						       NULL,
						       &edge2),
		targetid = curr_sp->edge_id.objid,
		targetos = curr_sp->edge_id.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  /*
   * Initialize BSgeom_bsp_surf structure
   */
  EFinit_geom_surface(&loc_msg, bspsf,
		      me->on_surfs[curr_bcv->surf_index].objid,
		      me->on_surfs[curr_bcv->surf_index].osnum,
		      &geom_bspsf);

  /*
   * Call math to fit a new blend curve and display it
   */
  BSblndcvosf(&edge1, curr_bcv->u1, curr_bcv->dir1, 1, me->ratio1,
	      &edge2, curr_bcv->u2, curr_bcv->dir2, 1, me->ratio2,
	      &geom_bspsf, &curr_bcv->bspcv,
	      (IGRint *) &curr_bcv->uvln.num_points,
	      &curr_bcv->uvln.points,
	      &curr_bcv->uvcv,
	      &loc_msg);
  
  EFdisplay_bspcv(curr_bcv->bspcv, &me->active_display, GRbd);

  ME.super_cmd->state = VALIDATE_BLEND_CV;

  if (bspsf)
    om$dealloc(ptr = bspsf);
  if (edge1.poles)
    om$dealloc(ptr = edge1.poles);
  if (edge1.knots)
    om$dealloc(ptr = edge1.knots);
  if (edge1.weights)
    om$dealloc(ptr = edge1.weights);
  if (edge2.poles)
    om$dealloc(ptr = edge2.poles);
  if (edge2.knots)
    om$dealloc(ptr = edge2.knots);
  if (edge2.weights)
    om$dealloc(ptr = edge2.weights);

 quit:
  return sts;
}

method check_blend_bdry_intersect(IGRlong *msg)
{
  IGRint bdry_nums, num_ints;
  IGRdouble cht_tol, bas_tol, tol_ratio, ncht_tol, nbas_tol;
  IGRdouble *int_pts, *par_edge, *par_bcv, *end_pts, *over_edge, *over_bcv;
  IGRlong loc_msg, sts, num_over;
  OM_S_CHANSELECT chan_to_loopset;
  OM_S_OBJECT_LINKAGE loopset_link;
  OMuint loopset_count;
  struct EMSpartolbasis partolbasis;
  struct EMSdataselect blend_cv;
  struct IGRbsp_curve edge1, edge2;
  struct EMSpypoint *bdry_pts;
  struct EMSsfintedpar *bdry_pars;
  struct BlendCv *curr_bcv;
  struct SpecialPnt *curr_sp;
  struct GRid *surf_id, *which_surf;
  extern IGRlong EMmake_chanselect();
  extern IGRboolean BScvcv_int();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;

  curr_bcv = &me->blend_cvs[me->curr_blend_index - 1];
  if (curr_bcv->bspcv == NULL)
  {
    *msg = MSFAIL;
    return sts;
  }
  
  surf_id = &me->on_surfs[curr_bcv->surf_index];

  edge1.poles = NULL;
  edge1.knots = NULL;
  edge1.weights = NULL;
  edge2.poles = NULL;
  edge2.knots = NULL;
  edge2.weights = NULL;

  if (curr_bcv->uvln.num_points)
  {
    blend_cv.datatype = EMSdata_poly2d;
    blend_cv.data.poly = &curr_bcv->uvln;
  }
  else
  {
    blend_cv.datatype = EMSdata_curve3d;
    blend_cv.data.curve = curr_bcv->uvcv;
  }

  partolbasis.is_valid = FALSE;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = &me->active_md_env.md_env.matrix_type;
  partolbasis.mat = me->active_md_env.md_env.matrix;

  bdry_nums = 0;
  bdry_pts = NULL;
  bdry_pars = NULL;

  sts = om$make_chanselect(channame = "EMSsubbs.to_loopset",
			   p_chanselect = &chan_to_loopset);

  sts = om$get_channel_objects(objid = surf_id->objid,
			       osnum = surf_id->osnum,
			       p_chanselect = &chan_to_loopset,
			       size = 1,
			       list = &loopset_link,
			       count = &loopset_count);
  
  sts = om$send(msg = message EMSloopset.EMlsparttrim(&loc_msg,
						      &blend_cv,
						      &partolbasis,
						      EMS_INTER_BDRYISAREA,
						      &bdry_nums,
						      &bdry_pts,
						      &bdry_pars),
		targetid = loopset_link.S_objid,
		targetos = surf_id->osnum);
  if (!(1 & sts & loc_msg))
  {
    sts = OM_E_ABORT;
    *msg = MSFAIL;
    goto quit;
  }

  if (bdry_nums == 1 && loc_msg == EMS_I_InAreaTrim)
  {
    /*
     * If the blend curve does not intersect boundary of the surface
     * it still could intersect the boundary of the fillet since the
     * boundary of the fillet may not be imposed on the surface.
     * We need to check whether two boundary edges of the fillet
     * intersect the blend curve. This checking should be performed
     * in care due to tolerance problem.
     */

    /*
     * Get geometry of the first edge
     */
    curr_sp = &me->spl_pts[curr_bcv->index1];
    if (curr_sp->which_fillet == -1)
      which_surf = &me->on_surfs[curr_sp->surf_index];
    else
      which_surf = &me->elems[curr_sp->which_fillet].located_obj;
    
    sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&loc_msg,
							 &me->active_md_env.md_env,
							 which_surf,
							 NULL,
							 0,
							 MAXINT,
							 FALSE,
							 NULL,
							 &edge1),
		  targetid = curr_sp->edge_id.objid,
		  targetos = curr_sp->edge_id.osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    
    /*
     * Get geometry of the second edge
     */
    curr_sp = &me->spl_pts[curr_bcv->index2];
    if (curr_sp->which_fillet == -1)
      which_surf = &me->on_surfs[curr_sp->surf_index];
    else
      which_surf = &me->elems[curr_sp->which_fillet].located_obj;
    
    sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&loc_msg,
							 &me->active_md_env.md_env,
							 which_surf,
							 NULL,
							 0,
							 MAXINT,
							 FALSE,
							 NULL,
							 &edge2),
		  targetid = curr_sp->edge_id.objid,
		  targetos = curr_sp->edge_id.osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

    /*
     * Extract the current chord height and basis tolerances
     */
    BSxtractpar(&loc_msg, BSTOLCHRDHT, &cht_tol);
    BSxtractpar(&loc_msg, BSTOLBASIS, &bas_tol);

    tol_ratio = 2.0 * cht_tol / bas_tol;
    tol_ratio = 1.0;

    /*
     * Increase both chord height and basis tolerances
     */
    nbas_tol = tol_ratio * bas_tol;
    ncht_tol = tol_ratio * cht_tol;
    
    BSchgdeppar(nbas_tol, &loc_msg);
    BSchangepar(&loc_msg, BSTOLCHRDHT, ncht_tol);

    /*
     * Intersect edge1 with the blend curve
     */
    int_pts = NULL;
    par_edge = par_bcv = NULL;
    end_pts = NULL;
    over_edge = over_bcv = NULL;
    BScvcv_int(&loc_msg, &edge1, curr_bcv->bspcv,
	       &num_ints, &int_pts, &par_edge, &par_bcv,
	       &num_over, &end_pts, &over_edge, &over_bcv);

    /*
     * Free memory
     */
    if (int_pts)
      om$dealloc(ptr = int_pts);
    if (par_edge)
      om$dealloc(ptr = par_edge);
    if (par_bcv)
      om$dealloc(ptr = par_bcv);
    if (int_pts)
      om$dealloc(ptr = end_pts);
    if (par_edge)
      om$dealloc(ptr = over_edge);
    if (par_bcv)
      om$dealloc(ptr = over_bcv);

    if (num_ints > 1)
    {
      /*
       * Reset old chord height and basis tolerance
       */
      BSchgdeppar(bas_tol, &loc_msg);
      BSchangepar(&loc_msg, BSTOLCHRDHT, cht_tol);

      *msg = EMS_I_IntersectTrim;
      goto quit;
    }
    
    /*
     * Intersect edge2 with the blend curve
     */
    int_pts = NULL;
    par_edge = par_bcv = NULL;
    end_pts = NULL;
    over_edge = over_bcv = NULL;
    BScvcv_int(&loc_msg, &edge2, curr_bcv->bspcv,
	       &num_ints, &int_pts, &par_edge, &par_bcv,
	       &num_over, &end_pts, &over_edge, &over_bcv);

    /*
     * Free memory
     */
    if (int_pts)
      om$dealloc(ptr = int_pts);
    if (par_edge)
      om$dealloc(ptr = par_edge);
    if (par_bcv)
      om$dealloc(ptr = par_bcv);
    if (int_pts)
      om$dealloc(ptr = end_pts);
    if (par_edge)
      om$dealloc(ptr = over_edge);
    if (par_bcv)
      om$dealloc(ptr = over_bcv);

    /*
     * Reset old chord height and basis tolerance
     */
    BSchgdeppar(bas_tol, &loc_msg);
    BSchangepar(&loc_msg, BSTOLCHRDHT, cht_tol);

    if (num_ints > 1)
      *msg = EMS_I_IntersectTrim;
    else
      *msg = EMS_I_InAreaTrim;
  }
  else
    *msg = EMS_I_IntersectTrim;

 quit:
  if (edge1.poles)
    om$dealloc(ptr = edge1.poles);
  if (edge1.knots)
    om$dealloc(ptr = edge1.knots);
  if (edge1.weights)
    om$dealloc(ptr = edge1.weights);
  if (edge2.poles)
    om$dealloc(ptr = edge2.poles);
  if (edge2.knots)
    om$dealloc(ptr = edge2.knots);
  if (edge2.weights)
    om$dealloc(ptr = edge2.weights);

  return sts;
}

method construct_blend_surf(IGRlong *msg)
{
  IGRdouble offset_dist;
  IGRint i, j, index;
  IGRint num_cvs, num_cutbacks, numgrps, total_numcvs;
  IGRvector blend_sf_normal;
  IGRpoint blend_cnt_pt;
  IGRboolean test_planar = FALSE;
  IGRlong loc_msg, sts;
  BSrc bs_rc;
  IGRshort opt = V_DIRECTION;
  IGRshort cvscode;
  OM_S_OBJID my_id = NULL;
  struct GRvg_construct cnst_list;
  struct BSgeom_bsp_surf geomsurf, geompln;
  struct GRlc_info lc_surf;
  IGRint *numints, *numpts;
  IGRpoint **intpts;
  struct IGRbsp_curve **bnd_cvs, *bnd_edges;
  struct IGRbsp_surface **tngt_sfs;
  struct CutBack *curr_cb;
  struct BlendCv *curr_bcv;
  BSpair **uvpars1, **uvpars2;
  struct BSgeom_bsp_curve *xyzcvs, *uvcvs1, *uvcvs2;
  extern IGRlong EMget_the_geometry();
  extern void BSalloccv(), BSsfsfint();
  extern IGRboolean BSconstprcv(), BScv_copy(), BSfreecv();
  extern IGRlong EMget_blend_sf();
  void EFdisplay_bspcv();

  /*
   * Initialize
   */
  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

  cnst_list.msg = &loc_msg;
  cnst_list.env_info = &me->active_md_env;
  cnst_list.newflag = FALSE;
  cnst_list.level = me->active_level;
  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_list.geometry = NULL;
  cnst_list.display = &me->active_display;
  cnst_list.class_attr = NULL;
  cnst_list.name = NULL;

  /*
   * Determine the number of bounding curves. This is the sum
   * of blend curves and cut back curves. However, when cut back
   * curve is a boundary, then all the edges of the boundary
   * have to be counted.
   */
  num_cvs = 0;
  for (i = 0; i < me->num_elems; i++)
  {
    if (me->cutback_cvs[i].type == BOUNDARY)
      num_cvs += me->cutback_cvs[i].cutcv.bdry.num_edges;
    else
      num_cvs++;
  }
  num_cvs += me->curr_blend_index;

  /*
   * Allocate memory for curves and surfaces composing the boundary of
   * blend surface and surfaces to which the blend surface is tanget.
   */
  bnd_cvs = (struct IGRbsp_curve **) alloca(num_cvs * sizeof(struct IGRbsp_curve *));
  tngt_sfs = (struct IGRbsp_surface **) alloca(num_cvs * sizeof(struct IGRbsp_surface *));

  /*
   * Get B-spline geometry for all the cut back curves
   */
  for (i = 0; i < me->num_elems;)
  {
    curr_cb = &me->cutback_cvs[i];

    /*
     * Get fillet surface geometry
     */
    sts = EMget_the_geometry(&me->elems[i], FALSE, FALSE, FALSE, my_id,
			     &tngt_sfs[i], &loc_msg);
    if (!(1 & sts & loc_msg))
    {
      if (tngt_sfs[i])
	om$dealloc(ptr = tngt_sfs[i]);
      *msg = MSFAIL;
      goto quit;
    }

    switch (curr_cb->type)
    {
    case ISOCV:
      /*
       * Allocate memory to store the iso curve
       */
      BSalloccv(tngt_sfs[i]->u_order, tngt_sfs[i]->u_num_poles,
		tngt_sfs[i]->rational, 0, &bnd_cvs[i], &loc_msg);

      /*
       * Extract the iso curve
       */
      BSconstprcv(&loc_msg, tngt_sfs[i], &opt, &curr_cb->cutcv.isocv_parm,
		  &test_planar, bnd_cvs[i]);

      i++;
      break;

    case PLANECUT:
      /*
       * Prepare BSgeom_bsp_surf for surface and plane in order
       * to call surface/surface intersection routine
       */
      geomsurf.geom_prop = FALSE;
      geomsurf.type = BSGEN_BSP_SF;
      geomsurf.bounded = TRUE;
      geomsurf.urange[0] = tngt_sfs[i]->u_knots[tngt_sfs[i]->u_order - 1];
      geomsurf.urange[1] = tngt_sfs[i]->u_knots[tngt_sfs[i]->u_num_poles];
      geomsurf.vrange[0] = tngt_sfs[i]->v_knots[tngt_sfs[i]->v_order - 1];
      geomsurf.vrange[1] = tngt_sfs[i]->v_knots[tngt_sfs[i]->v_num_poles];
      geomsurf.bspsf = tngt_sfs[i];
      geomsurf.sfgen_cv = NULL;

      geompln.geom_prop = TRUE;
      geompln.type = BSINF_PLANE;
      geompln.bounded = FALSE;
      geompln.reg_constr = TRUE;
      memcpy(geompln.pt1, curr_cb->midpt, sizeof(IGRpoint));
      memcpy(geompln.vec1, curr_cb->cutcv.cutpln.normal, sizeof(IGRvector));

      /*
       * Call math routine to get intersection curve
       */
      BSsfsfint(&geompln, &geomsurf, &numgrps, &numints, &numpts,
		&intpts, &uvpars1, &uvpars2, &cvscode,
		&xyzcvs, &uvcvs1, &uvcvs2, &bs_rc);

      bnd_cvs[i] = xyzcvs[0].bspcv;
      xyzcvs[0].bspcv = NULL;
      
      /*
       * Free memory allocated by math
       */
      total_numcvs = 0;
      for (j = 0; j < numgrps; j++)
	total_numcvs += numints[j];
    
      if ((cvscode == 1 || cvscode == 3 || cvscode == 4 || cvscode == 5) &&
	  xyzcvs)
      {
	for (j = 0; j < total_numcvs; j++)
	{
	  if (xyzcvs[j].array1)
	  {
	    BSdealloc((char *) xyzcvs[j].array1);
	    xyzcvs[j].array1 = NULL;
	  }
	  if (xyzcvs[j].bspcv)
	  {
	    BSfreecv(&bs_rc, xyzcvs[j].bspcv);
	    xyzcvs[j].bspcv = NULL;
	  }
	}
      }
      if ((cvscode == 2 || cvscode == 3 || cvscode == 4) && uvcvs1)
      {
	for (j = 0; j < total_numcvs; j++)
	{
	  if (uvcvs1[j].array1)
	  {
	    BSdealloc((char *) uvcvs1[j].array1);
	    uvcvs1[j].array1 = NULL;
	  }
	  if (uvcvs1[j].bspcv)
	  {
	    BSfreecv(&bs_rc, uvcvs1[j].bspcv);
	    uvcvs1[j].bspcv = NULL;
	  }
	}
      }
      if ((cvscode == 2 || cvscode == 3 || cvscode == 5) && uvcvs2)
      {
	for (j = 0; j < total_numcvs; j++)
	{
	  if (uvcvs2[j].array1)
	  {
	    BSdealloc((char *) uvcvs2[j].array1);
	    uvcvs2[j].array1 = NULL;
	  }	    
	  if (uvcvs2[j].bspcv)
	  {
	    BSfreecv(&bs_rc, uvcvs2[j].bspcv);
	    uvcvs2[j].bspcv = NULL;
	  }
	}
      }
      if (intpts)
      {
	for (j = 0; j < numgrps; j++)
	  if (intpts[j])
	    om$dealloc(ptr = intpts[j]);
	om$dealloc(ptr = intpts);
      }
      if (uvpars1)
      {
	for (j = 0; j < numgrps; j++)
	  if (uvpars1[j])
	    om$dealloc(ptr = uvpars1[j]);
	om$dealloc(ptr = uvpars1);
      }
      if (uvpars2)
      {
	for (j = 0; j < numgrps; j++)
	  if (uvpars2[j])
	    om$dealloc(ptr = uvpars2[j]);
	om$dealloc(ptr = uvpars2);
      }
      if (numints)
	om$dealloc(ptr = numints);
      if (numpts)
	om$dealloc(ptr = numpts);

      i++;
      break;

    case BOUNDARY:
      /*
       * Allocate memory for boundary edges
       */
      bnd_edges = (struct IGRbsp_curve *)
	alloca(curr_cb->cutcv.bdry.num_edges * sizeof(struct IGRbsp_curve));

      /*
       * Get boundary edge B-spline geometry
       */
      for (j = 0, index = curr_cb->cutcv.bdry.index;
	   j < curr_cb->cutcv.bdry.num_edges;
	   j++, index++, i++)
      {
	bnd_cvs[i] = &bnd_edges[j];
	bnd_edges[j].poles = NULL;
	bnd_edges[j].knots = NULL;
	bnd_edges[j].weights = NULL;
	sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(msg,
							     NULL,
							     NULL,
							     tngt_sfs[i],
							     0,
							     MAXINT,
							     FALSE,
							     NULL,
							     &bnd_edges[j]),
		      senderid = my_id,
		      targetid = me->bound_edges[index].objid,
		      targetos = me->bound_edges[index].osnum);
	EMerr_hndlr(EMSerror(sts & *msg), sts, OM_E_ABORT, quit);

	tngt_sfs[i + 1] = tngt_sfs[i];
      }

      break;
    }
  }

  /*
   * Get B-spline geometry for all the blend curves
   */
  num_cutbacks = i;
  for (i = 0; i < me->curr_blend_index; i++)
  {
    curr_bcv = &me->blend_cvs[i];
    index = num_cutbacks + i;

    memcpy(&lc_surf.located_obj, &me->on_surfs[curr_bcv->surf_index],
	   sizeof(struct GRid));
    memcpy(&lc_surf.module_info, &me->active_md_env, sizeof(struct GRmd_env));

    sts = EMget_the_geometry(&lc_surf, FALSE, FALSE, FALSE, my_id,
			     &tngt_sfs[index], &loc_msg);
    if (!(1 & sts & loc_msg))
    {
      if (tngt_sfs[index])
	om$dealloc(ptr = tngt_sfs[index]);
      *msg = MSFAIL;
      goto quit;
    }
    
    /*
     * Allocate memory to store the iso curve
     */
    BSalloccv(curr_bcv->bspcv->order, curr_bcv->bspcv->num_poles,
	      curr_bcv->bspcv->rational, 0, &bnd_cvs[index], &loc_msg);
    BScv_copy(&loc_msg, curr_bcv->bspcv, bnd_cvs[index]);
    /*
    bnd_cvs[index] = curr_bcv->bspcv;
    */
  }

  /*
   * Now, fit a blend surface through the set of cut back curves
   * and blend curves
   */
  offset_dist = 0.0;
  ME.ECcrbldsf->blend_sf.objid = NULL_OBJID;
  sts = EMget_blend_sf(&loc_msg, NULL, &cnst_list,
		       num_cvs, bnd_cvs, tngt_sfs,
		       &me->cutback_cvs[0].testvec2, offset_dist,
		       &ME.ECcrbldsf->blend_sf,
		       &blend_sf_normal, &blend_cnt_pt,
		       NULL, NULL, NULL, NULL);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  /*
   * Erase cut back and blend curves used to create blend surface
   */
  for (i = 0; i < num_cvs; i++)
    EFdisplay_bspcv(bnd_cvs[i], &me->active_display, GRbe);
  
  /*
   * Display the result
   */
  gr$display_object(object_id = &ME.ECcrbldsf->blend_sf,
		    mode = GRbd);

  /*
   * Free memory allocated
   */
  for (i = 0; i < num_cvs; i++)
  {
    if (tngt_sfs[i])
    {
      om$dealloc(ptr = tngt_sfs[i]);
      tngt_sfs[i] = NULL;
    }
    if (bnd_cvs[i]->poles)
    {
      om$dealloc(ptr = bnd_cvs[i]->poles);
      bnd_cvs[i]->poles = NULL;
    }
    if (bnd_cvs[i]->knots)
    {
      om$dealloc(ptr = bnd_cvs[i]->knots);
      bnd_cvs[i]->knots = NULL;
    }
    if (bnd_cvs[i]->weights)
    {
      om$dealloc(ptr = bnd_cvs[i]->weights);
      bnd_cvs[i]->weights = NULL;
    }
    om$dealloc(ptr = bnd_cvs[i]);
  }
  
 quit:
  return sts;
}

method status_disp()
{
  if (me->form_avail && !me->form_displayed)
  {
    FIf_display(me->stat_fm);
    me->form_displayed = TRUE;
  }
  return OM_S_SUCCESS;
}

method do_form(IGRlong *msg; IGRint form_label, gadget_label; IGRdouble value)
{
  IGRdouble gd_val;
  IGRint response = EX_FORM_FINISHED;
  IGRlong sts, sizbuf;
  struct GRevent event;
  struct BlendCv *curr_bcv;
  extern IGRboolean BSmkvec();
  extern IGRdouble BSlenvec();
  extern void EFdisplay_bspcv();

  sts = OM_S_SUCCESS;
  if (me->form_avail && form_label == STAT_FM)
  {
    curr_bcv = &me->blend_cvs[me->curr_blend_index - 1];
    
    switch (gadget_label)
    {
    case SAVE_CHANGE:
      curr_bcv->ratio1 = me->ratio1;
      curr_bcv->ratio2 = me->ratio2;

      FIg_reset(me->stat_fm, SAVE_CHANGE);
      FIf_erase(me->stat_fm);
      me->form_displayed = FALSE;
      break;
    case NO_CHANGE:
      me->ratio1 = curr_bcv->ratio1;
      me->ratio2 = curr_bcv->ratio2;

      FIg_reset(me->stat_fm, NO_CHANGE);
      FIf_erase(me->stat_fm);
      me->form_displayed = FALSE;
      break;
    case SLIDER1:
      FIg_get_value(me->stat_fm, gadget_label, &gd_val);
      if ((IGRint) gd_val)
	me->ratio1 = gd_val / 50.0;
      else
	me->ratio1 = 0.02;
      break;
    case SLIDER2:
      FIg_get_value(me->stat_fm, gadget_label, &gd_val);
      if ((IGRint) gd_val)
	me->ratio2 = gd_val / 50.0;
      else
	me->ratio2 = 0.02;
      break;
    default:
      break;
    }

    switch (gadget_label)
    {
    case NO_CHANGE:
    case SLIDER1:
    case SLIDER2:
      sts = om$send(msg = message ECcrbldsf.modify_blend_curve(msg),
		    targetid = my_id);

      sizbuf = sizeof(struct GRevent) - 2 * sizeof(IGRint);
      ex$putque(msg = msg,
		response = &response,
		byte = &sizbuf,
		buffer = (IGRchar *) &event.event);
      break;
    case SAVE_CHANGE:
      break;
    }
  }

  return OM_S_SUCCESS;
}

void ECcrbldsf_process_fm(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
  GRobjid cmd_obj;
  GRspacenum cmd_os;
  IGRlong sts, msg;

  sts = FIf_get_cmd_oid_os(form_ptr, &cmd_obj, &cmd_os);
  EMerr_hndlr(sts != FI_SUCCESS, sts, OM_E_ABORT, quit);
  
  sts = om$send(msg = message ECcrbldsf.do_form(&msg,
						form_label,
						gadget_label,
						value),
		senderid = NULL_OBJID,
		targetid = cmd_obj,
		targetos = cmd_os);
  EMerr_hndlr(sts & msg, sts, OM_E_ABORT, quit);

 quit:
  return;
}


/*
 * DESCRIPTION
 *
 *     This function is used to check whether located fillet is a closed
 *     fillet. It is called after do_locate method of the ECelements located
 *     one object. The function returns OM_S_SUCCESS or OM_E_ABORT.
 *
 * OPTION
 *
 *     No option supported.
 *     The argument list corresponses to that of the method proc_locobj in
 *     ECelements (event1, event2 and event3 of lc$locate macro).
 *
 * ALGORITHM
 *
 *     Get the geometry of the fillet. If the natural surface is not closed,
 *     then return not closed. Otherwise, check whether there is closed loop
 *     of imposed boundary.
 */

#argsused
IGRint EMcheck_nonclose_fillet(msg, locev, accev, objev)
IGRlong *msg;
struct GRevent *locev, *accev, *objev;
{
  OM_S_OBJID my_id = NULL_OBJID;
  struct GRlc_info *lc_surf;
  struct IGRbsp_surface *surf = NULL;
  struct GRid *edges = NULL;
  IGRint buf_size, num_edges, curr_range, i, j, count;
  IGRdouble *beg_parms, *end_parms, *parm_ranges, *ptr1, *ptr2;
  IGRdouble tolr, min, max, du, dv, dist;
  IGRshort *used;
  IGRlong sts, loc_msg;
  extern IGRlong EMget_the_geometry();
  extern IGRdouble sqrt(), fabs();

  min = 1.0;
  max = 0.0;
  lc_surf = &objev->located_object[0];
  
  /* get surface geometry */
  sts = EMget_the_geometry(lc_surf, FALSE, FALSE, FALSE, my_id, &surf, &loc_msg);
  if (!(1 & sts & loc_msg))
  {
    if (surf)
      om$dealloc(ptr = surf);
    return OM_E_ABORT;
  }

  if (surf->u_phy_closed || surf->v_phy_closed)
  {
    if (surf->u_phy_closed && surf->v_phy_closed)
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_InvalidFilSurf);
      *msg = EMS_I_NotFound;
    }
    else
    {
      buf_size = num_edges = 0;
      sts = om$send(msg = message EMSsurface.EMgetedges(&loc_msg,
							EMS_OPT_NONDEG,
							&edges,
							&buf_size,
							&num_edges,
							NULL,
							NULL,
							NULL,
							NULL),
		    senderid = NULL_OBJID,
		    targetid = lc_surf->located_obj.objid,
		    targetos = lc_surf->located_obj.osnum);
      EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    
      beg_parms = (IGRdouble *) alloca(num_edges * 2 * sizeof(IGRdouble));
      end_parms = (IGRdouble *) alloca(num_edges * 2 * sizeof(IGRdouble));
      parm_ranges = (IGRdouble *) alloca(num_edges * sizeof(IGRdouble));
      used = (IGRshort *) alloca(num_edges * sizeof(IGRshort));
      for (i = 0; i < num_edges; i++)
      {
	sts = om$send(msg = message EMSedge.EMendpts(&loc_msg,
						     beg_parms + i*2,
						     end_parms + i*2,
						     NULL,
						     NULL,
						     NULL),
		      senderid = NULL_OBJID,
		      targetid = edges[i].objid,
		      targetos = edges[i].osnum);
	EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

	used[i] = FALSE;
      }

      BSxtractpar(&loc_msg, BSTOLCHRDHT, &tolr);
      curr_range = 0;
      for (i = 0; i < num_edges; i++)
	if (used[i] == FALSE)
	{
	  ptr1 = beg_parms + i * 2;
	  if (surf->u_phy_closed)
	    max = min = *ptr1;
	  else
	    max = min = *(ptr1 + 1);

	  for (j = i + 1; j < num_edges; j++)
	    if (used[j] == FALSE)
	    {
	      used[j] = TRUE;

	      ptr2 = beg_parms + j * 2;
	      if (surf->u_phy_closed)
	      {
		if (*ptr2 > max)
		  max = *ptr2;
		if (*ptr2 < min)
		  min = *ptr2;
	      }
	      else
	      {
		if (*(ptr2 + 1) > max)
		  max = *(ptr2 + 1);
		if (*(ptr2 + 1) < min)
		  min = *(ptr2 + 1);
	      }
	      
	      du = end_parms[j * 2] - *ptr1;
	      dv = end_parms[j * 2 + 1] - *(ptr1 + 1);
	      dist = sqrt(du * du + dv * dv);
	      if (dist < tolr)
	      {
		used[i] = TRUE;
		parm_ranges[curr_range * 2] = min;
		parm_ranges[curr_range * 2 + 1] = max;
		curr_range++;
		break;
	      }
	    }
	}

      if (curr_range > 1)
      {
	for (i = 0; i < 2 * curr_range; i++)
	  used[i] = FALSE;

	for (i = 0; i < curr_range; i++)
	  if (used[2 * i] == FALSE)
	  {
	    for (j = 0; j < curr_range; j++)
	      if (j != i && used[2 * j + 1] == FALSE)
	      {
		if (fabs(parm_ranges[2 * i] - parm_ranges[2 * j + 1]) < tolr)
		{
		  used[2 * i] = TRUE;
		  used[2 * j + 1] = TRUE;
		  break;
		}
	      }
	  }

	count = 0;
	for (i = 0; i < curr_range; i++)
	  if (used[2 * i] == FALSE)
	  {
	    count++;
	    min = parm_ranges[2 * i];
	  }
	if (count > 1)
	  *msg = EMS_I_Found;
	else
	{
	  count = 0;
	  for (i = 0; i < curr_range; i++)
	    if (used[2 * i + 1] == FALSE)
	    {
	      count++;
	      max = parm_ranges[2 * i + 1];
	    }
	  if (count > 1)
	    *msg = EMS_I_Found;
	  else
	  {
	    if (fabs(min) < tolr && fabs(max - 1.0) < tolr)
	      *msg = EMS_I_NotFound;	/* this is a closed fillet */
	    else
	      *msg = EMS_I_Found;
	  }
	}
      }
      else
      {
	if (fabs(parm_ranges[0]) < tolr && fabs(parm_ranges[1] - 1.0) < tolr)
	  *msg = EMS_I_NotFound;	/* this is a closed fillet */
	else
	  *msg = EMS_I_Found;
      }
    }
  }
  else
    *msg = EMS_I_Found;

 quit:
  if (edges)
    om$dealloc(ptr = edges);
  if (surf)
    om$dealloc(ptr = surf);
  return OM_S_SUCCESS;
}

/*
 * DESCRIPTION
 *
 *     Given an EX_button structure, this function return the correct
 *     tolerance used in dynamic functions.
 *
 */

IGRdouble dyn_tolerance(msg, cursor)
IGRlong *msg;
struct EX_button *cursor;
{
  IGRdouble scale, tolr;
  IGRlong sizbuf, nret, which_error, loc_msg, sts;
  struct var_list var_list[2];

  /*
   * initialize
   */
  *msg = MSSUCC;
  sizbuf = sizeof(IGRdouble);

  /*
   * get dit_tolerance
   */
  gr$get_dit_tolerance(msg = &loc_msg,
		       sizbuf = &sizbuf,
		       buffer = &tolr,
		       nret = &nret);

  /*
   * From the gragad inquire the view volume to viewport scale
   */
  var_list[0].var = VVOL_VIEWPORT_SCALE;
  var_list[0].var_ptr = (IGRchar *) &scale;
  var_list[0].num_bytes = sizbuf;
  var_list[0].bytes_returned = &nret;

  var_list[1].var = END_PARAM;
  var_list[1].var_ptr = NULL;
  var_list[1].num_bytes = 0;
  var_list[1].bytes_returned = NULL;

  sts = dp$inq_set_gragad(msg = &loc_msg,
			  var_list = var_list,
			  gragad_objid = cursor->objid,
			  osnum = cursor->osnum,
			  which_error = &which_error);
  if (!(sts & 1))
  {
    om$report_error(sts = sts);
    *msg = MSFAIL;
    return tolr;
  }
  else
    return (tolr / scale);
}


#argsused
IGRint DYFUNCisocv(DYinfo, point, matrix, objects, num_objects,
		   buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		   dummy_out1, dummy_out2, dummy_out3 )
struct ECDYN_isocv *DYinfo;
struct EX_button *point;
IGRdouble *matrix;
struct GRid **objects;
struct DPele_header **buffers;
IGRint *num_objects, *num_buffers;
IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
{
  struct GRevent event;
  struct IGRline boreline;
  GRobjid stupid_id = NULL;
  IGRpoint startpoint, endpoint, *int_pts;
  IGRvector linevec;
  IGRboolean allocpts, testplnr;
  IGRint numint_pts, i;
  IGRdouble *int_uvs, tolr, minmin, minmax, maxmin, maxmax, uparm, vparm;
  struct IGRbsp_curve *isocv;
  IGRshort opt;
  IGRlong msg;
  extern IGRboolean EFboreline(), BSmkvec(), BSconstprcv();
  extern IGRdouble dyn_tolerance(), fabs();
  extern void BSsfarrevn();

  /*
   * initialize
   */
  tolr = dyn_tolerance(&msg, point);
  if (msg == MSFAIL)
  {
    BSxtractpar(&msg, BSTOLCHRDHT, &tolr);
    tolr *= 10.0;
  }

  event.event.button = *point;
  boreline.point1 = startpoint;
  boreline.point2 = endpoint;

  EFboreline(&msg, stupid_id, &event, &boreline);
  BSmkvec(&msg, linevec, startpoint, endpoint);
  BSnorvec(&msg, linevec);

  allocpts = TRUE;
  BSxlngmsf(&DYinfo->geomsurf , startpoint, linevec, TRUE, 0, NULL, NULL,
	    &allocpts, &numint_pts, &int_pts, &int_uvs, &msg);
  if (msg == BSNOMEMORY || msg == BSNOSTKMEMORY)
  {
    DYinfo->rc = DYN_NO_MEMORY;
    goto quit;
  }
  if (msg == BSNOSOLUTION || msg == BSCOINCIDENT)
  {
    DYinfo->rc = DYN_NO_INTERSECTION;
    goto quit;
  }

  if (numint_pts > 0)
  {
    minmin = DYinfo->parmrange[0];
    minmax = DYinfo->parmrange[2];
    if (minmax < minmin)
    {
      minmax = minmin;
      minmin = DYinfo->parmrange[2];
    }
    maxmin = DYinfo->parmrange[1];
    maxmax = DYinfo->parmrange[3];
    if (maxmax < maxmin)
    {
      maxmax = maxmin;
      maxmin = DYinfo->parmrange[3];
    }
    
    if (int_uvs[1] < minmin || int_uvs[1] > maxmax)
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
      DYinfo->rc = DYN_OUT_SURFACE;
    }
    else
    {
      ex$message(msgnumb = EMS_S_ClearStatusField);

      if ((fabs(minmax - minmin) > tolr &&
	   int_uvs[1] >= minmin && int_uvs[1] < minmax) ||
	  (fabs(minmax - minmin) <= tolr && fabs(int_uvs[1] - minmin) <= tolr))
      {
	for (i = 0; i < DYinfo->num_min_xyzedges; i++)
	  DYinfo->disp_hd[i + 1].geometry.bspcurve = (struct IGRbsp_curve *) &DYinfo->min_xyzedges[i];

	uparm = 0.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm,
		   1, &DYinfo->parmrange[0], DYinfo->endpt1, linevec);
	uparm = 1.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm,
		   1, &DYinfo->parmrange[2], DYinfo->endpt2, linevec);
	uparm = 0.5;
	vparm = (DYinfo->parmrange[0] + DYinfo->parmrange[2]) / 2.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &vparm,
		   DYinfo->midpt, linevec);

	DYinfo->rc = DYN_BOUNDARY;
	DYinfo->side = 0;
	*num_buffers = DYinfo->num_min_xyzedges;
	*buffers = &DYinfo->disp_hd[1];
      }
      else if ((fabs(maxmax - maxmin) > tolr &&
		int_uvs[1] > maxmin && int_uvs[1] <= maxmax) ||
	       (fabs(maxmax - maxmin) <= tolr &&
		fabs(int_uvs[1] - maxmin) <= tolr))
      {
	for (i = 0; i < DYinfo->num_max_xyzedges; i++)
	  DYinfo->disp_hd[i + 1].geometry.bspcurve = (struct IGRbsp_curve *) &DYinfo->max_xyzedges[i];

	uparm = 0.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm,
		   1, &DYinfo->parmrange[1], DYinfo->endpt1, linevec);
	uparm = 1.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm,
		   1, &DYinfo->parmrange[3], DYinfo->endpt2, linevec);
	uparm = 0.5;
	vparm = (DYinfo->parmrange[1] + DYinfo->parmrange[3]) / 2.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &vparm,
		   DYinfo->midpt, linevec);

	DYinfo->rc = DYN_BOUNDARY;
	DYinfo->side = 1;
	*num_buffers = DYinfo->num_max_xyzedges;
	*buffers = &DYinfo->disp_hd[1];
      }
      else
      {
	isocv = DYinfo->disp_hd[0].geometry.bspcurve;
	opt = DYinfo->pole_direction;
	testplnr = FALSE;
	BSconstprcv(&msg, DYinfo->geomsurf.bspsf, &opt, &int_uvs[1], &testplnr, isocv);
	DYinfo->upar = int_uvs[0];
	DYinfo->vpar = int_uvs[1];

	uparm = 0.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &int_uvs[1],
		   DYinfo->endpt1, linevec);
	uparm = 1.0;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &int_uvs[1],
		   DYinfo->endpt2, linevec);
	uparm = 0.5;
	BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &int_uvs[1],
		   DYinfo->midpt, linevec);

	DYinfo->rc = DYN_SUCCESS;
	*num_buffers = 1;
	*buffers = DYinfo->disp_hd;
      }
      uparm = 0.0;
      vparm = (DYinfo->parmrange[0] + DYinfo->parmrange[1]) / 2.0;
      BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &vparm,
		 DYinfo->testpt1, DYinfo->testvec1);
      uparm = 1.0;
      vparm = (DYinfo->parmrange[2] + DYinfo->parmrange[3]) / 2.0;
      BSsfarrevn(&msg, DYinfo->geomsurf.bspsf, 1, &uparm, 1, &vparm,
		 DYinfo->testpt2, DYinfo->testvec2);
    }
  }
  else
  {
    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutFilInpAg);
    DYinfo->rc = DYN_OUT_SURFACE;
  }
  
 quit:
  if (DYinfo->rc != DYN_SUCCESS && DYinfo->rc != DYN_BOUNDARY)
    *num_buffers = 0;
  *num_objects = 1;
  *objects = &DYinfo->lc_surf->located_obj;

  return OM_S_SUCCESS;
}

#argsused
IGRint DYFUNCstartpt(DYinfo, point, matrix, objects, num_objects,
		     buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		     dummy_out1, dummy_out2, dummy_out3 )
struct ECDYN_startpt *DYinfo;
struct EX_button *point;
IGRdouble *matrix;
struct GRid **objects;
struct DPele_header **buffers;
IGRint *num_objects, *num_buffers;
IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
{
  struct GRevent event;
  struct IGRline boreline;
  GRobjid stupid_id = NULL;
  IGRpoint startpoint, endpoint, linept, curvept;
  IGRdouble tolr, lineparm, curveparm;
  IGRvector pt_vec;
  IGRlong msg;
  extern IGRboolean EFboreline(), MAlnbcproj(), BSmkvec();
  extern IGRdouble dyn_tolerance(), BSlenvec();
  extern void BSsfarrevn();

  /*
   * initialize
   */
  tolr = dyn_tolerance(&msg, point);
  if (msg == MSFAIL)
  {
    BSxtractpar(&msg, BSTOLCHRDHT, &tolr);
    tolr *= 10.0;
  }

  event.event.button = *point;
  boreline.point1 = startpoint;
  boreline.point2 = endpoint;
  EFboreline(&msg, stupid_id, &event, &boreline);

  if (MAlnbcproj(&msg, &boreline, DYinfo->bdrycv, &tolr,
		 linept, curvept, &lineparm, &curveparm))
  {
    if (curveparm >= DYinfo->min_parm && curveparm <= DYinfo->max_parm)
    {
      /*
      BSxtractpar(&msg, BSTOLLENVEC, &tolr);
      */
      BSmkvec(&msg, pt_vec, DYinfo->min_pt, curvept);
      if (BSlenvec(&msg, pt_vec) < tolr)
      {
	DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight2;
	memcpy(curvept, DYinfo->min_pt, sizeof(IGRpoint));
      }
      else
      {
	BSmkvec(&msg, pt_vec, DYinfo->max_pt, curvept);
	if (BSlenvec(&msg, pt_vec) < tolr)
	{
	  DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight2;
	  memcpy(curvept, DYinfo->max_pt, sizeof(IGRpoint));
	}
	else
	{
	  DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight1;
	}
      }
      curveparm = (DYinfo->min_parm + DYinfo->max_parm) / 2.0;
      BSsfarrevn(&msg, DYinfo->surf, 1, &DYinfo->uparm, 1, &curveparm,
		 DYinfo->testpt, DYinfo->testvec);

      memcpy(DYinfo->disp_hd[1].geometry.point_set->points, curvept,
	     sizeof(IGRpoint));
      memcpy(DYinfo->startpt, curvept, sizeof(IGRpoint));
      DYinfo->rc = DYN_SUCCESS;

      ex$message(msgnumb = EMS_S_ClearStatusField);
      *num_buffers = 2;
    }
    else
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutParmRng);
      DYinfo->rc = DYN_NO_PROJECTION;
      *num_buffers = 1;
    }
  }
  else
  {
    DYinfo->rc = DYN_NO_PROJECTION;
    *num_buffers = 1;
  }
  *buffers = DYinfo->disp_hd;

  return OM_S_SUCCESS;
}

#argsused
IGRint DYFUNCplanecut(DYinfo, point, matrix, objects, num_objects,
		      buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		      dummy_out1, dummy_out2, dummy_out3 )
struct ECDYN_planecut *DYinfo;
struct EX_button *point;
IGRdouble *matrix;
struct GRid **objects;
struct DPele_header **buffers;
IGRint *num_objects, *num_buffers;
IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
{
  struct GRevent event;
  struct IGRline boreline;
  GRobjid stupid_id = NULL;
  IGRpoint startpoint, endpoint, linept, curvept, midpoint;
  IGRdouble tolr, lineparm, curveparm, uparm, vparm, sfnormal[3];
  IGRvector pt_vec, basevec, planenormal;
  struct IGRpolyline *poly;
  struct IGRbsp_curve bspln;
  IGRdouble bspln_poles[6], bspln_knots[4];
  IGRint numgrps, *numpts, i;
  IGRpoint **pj_pts;
  BSpair **pars;
  IGRlong msg;
  extern IGRboolean EFboreline(), MAlnbcproj(), BSmkvec(), BScrossp();
  extern IGRlong EFpoint_on_object();
  extern void BSsfarrevn(), BSpjcvtsf();
  extern IGRdouble BSlenvec();

  /* initialize */
  event.event.button = *point;
  boreline.point1 = startpoint;
  boreline.point2 = endpoint;
  EFboreline(&msg, stupid_id, &event, &boreline);

  BSxtractpar(&msg, BSTOLCHRDHT, &tolr);

  if (MAlnbcproj(&msg, &boreline, DYinfo->bdrycv, &tolr,
		 linept, curvept, &lineparm, &curveparm))
  {
    if (curveparm >= DYinfo->min_parm && curveparm <= DYinfo->max_parm)
    {
      BSmkvec(&msg, pt_vec, DYinfo->min_pt, curvept);
      if (BSlenvec(&msg, pt_vec) < tolr)
      {
	DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight2;
	memcpy(curvept, DYinfo->min_pt, sizeof(IGRpoint));
      }
      else
      {
	BSmkvec(&msg, pt_vec, DYinfo->max_pt, curvept);
	if (BSlenvec(&msg, pt_vec) < tolr)
	{
	  DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight2;
	  memcpy(curvept, DYinfo->max_pt, sizeof(IGRpoint));
	}
	else
	{
	  DYinfo->disp_hd[1].dis_att->weight = DYinfo->weight1;
	}
      }
      curveparm = (DYinfo->min_parm + DYinfo->max_parm) / 2.0;
      BSsfarrevn(&msg, DYinfo->surf, 1, &DYinfo->uparm, 1, &curveparm,
		 DYinfo->testpt, DYinfo->testvec);

      /* calculate the mid point */
      midpoint[0] = (DYinfo->startpt[0] + curvept[0]) / 2;
      midpoint[1] = (DYinfo->startpt[1] + curvept[1]) / 2;
      midpoint[2] = (DYinfo->startpt[2] + curvept[2]) / 2;

      event.event.button = *point;
      memcpy(&event.event.button, midpoint, sizeof(IGRpoint));

      /* project mid point onto surface */
      EFpoint_on_object(DYinfo->lc_surf, &event, stupid_id, &msg);

      uparm = event.located_object[0].geom_parms.u;
      vparm = event.located_object[0].geom_parms.v;
    
      /* evaluate surface normal at the projection point */
      BSsfarrevn(&msg, DYinfo->surf, 1, &uparm, 1, &vparm,
		 DYinfo->midpt, sfnormal);
      memcpy(DYinfo->midpt, midpoint, sizeof(IGRpoint));

      /* calculate plane normal */
      BSmkvec(&msg, basevec, DYinfo->startpt, curvept);
      BSnorvec(&msg, basevec);
      BScrossp(&msg, sfnormal, basevec, planenormal);
      BSnorvec(&msg, planenormal);

      poly = DYinfo->disp_hd[1].geometry.polyline;
      if (poly->points)
      {
	om$dealloc(ptr = poly->points);
	poly->points = NULL;
      }

      bspln.order = 2;
      bspln.periodic = FALSE;
      bspln.non_uniform = FALSE;
      bspln.num_poles = 2;
      bspln.poles = bspln_poles;
      memcpy(bspln_poles, DYinfo->startpt, sizeof(IGRpoint));
      memcpy(bspln_poles + 3, curvept, sizeof(IGRpoint));
      bspln.num_knots = 4;
      bspln.knots = bspln_knots;
      bspln_knots[0] = bspln_knots[1] = 0.0;
      bspln_knots[2] = bspln_knots[3] = 1.0;
      bspln.rational = FALSE;
      bspln.weights = NULL;
      bspln.planar = TRUE;
      bspln.phy_closed = FALSE;
      bspln.num_boundaries = 0;
      bspln.bdrys = NULL;

      BSpjcvtsf(&bspln, DYinfo->surf, sfnormal, &numgrps, &numpts,
		&pj_pts, &pars, &msg);
      if (msg == BSSUCC)
      {
	poly->num_points = numpts[0];
	poly->points = (IGRdouble *) om$malloc(size = numpts[0] * sizeof(IGRpoint));
	if (poly->points == NULL)
	{
	  DYinfo->rc = DYN_NO_MEMORY;
	  *num_buffers = 1;
	}
	else
	{
	  memcpy(poly->points, pj_pts[0][0], numpts[0] * sizeof(IGRpoint));
	  
	  for (i = 0; i < numgrps; i++)
	  {
	    om$dealloc(ptr = pj_pts[i]);
	    om$dealloc(ptr = pars[i]);
	  }
	  om$dealloc(ptr = numpts);

	  memcpy(DYinfo->normal, planenormal, sizeof(IGRvector));
	  memcpy(DYinfo->endpt, curvept, sizeof(IGRpoint));

	  DYinfo->rc = DYN_SUCCESS;
	  
	  ex$message(msgnumb = EMS_S_ClearStatusField);
	  *num_buffers = 2;
	}
      }
      else
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_E_ErrPlnSurfInt);
	DYinfo->rc = DYN_NO_INTERSECTION;
	*num_buffers = 1;
      }
    }
    else
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutParmRng);
      DYinfo->rc = DYN_NO_PROJECTION;
      *num_buffers = 1;
    }
  }
  else
  {
    DYinfo->rc = DYN_NO_PROJECTION;
    *num_buffers = 1;
  }
  *buffers = DYinfo->disp_hd;

  return OM_S_SUCCESS;
}

#argsused
IGRint DYFUNCblendcv(DYinfo, point, matrix, objects, num_objects,
		     buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		     dummy_out1, dummy_out2, dummy_out3 )
struct ECDYN_blendcv *DYinfo;
struct EX_button *point;
IGRdouble *matrix;
struct GRid **objects;
struct DPele_header **buffers;
IGRint *num_objects, *num_buffers;
IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
{
  IGRdouble tolr;
  IGRpoint startpoint, endpoint, *pt1, *pt2;
  IGRvector linevec, pt_vec, dir_vec, proj_vec;
  IGRint i, j, pt_index, num_pts;
  struct GRevent event;
  struct IGRline boreline;
  GRobjid stupid_id = NULL;
  struct SpecialPnt *curr_sp = NULL;
  IGRboolean find_edge;
  struct IGRbsp_curve bspln;
  IGRdouble bspln_poles[6], bspln_knots[4];
  IGRdouble *par1, *par2, dist, *ptr_pt, *pars, *intpars;
  IGRshort k, n;
  IGRlong msg;
  extern IGRboolean EFboreline(), BSmkvec(), BScrossp();
  extern IGRdouble dyn_tolerance(), BSdotp(), fabs();
  extern void BSmdistcvcv(), BSmdistptcv();

  /*
   * initialize
   */
  tolr = dyn_tolerance(&msg, point);
  if (msg == MSFAIL)
  {
    BSxtractpar(&msg, BSTOLCHRDHT, &tolr);
    tolr *= 10.0;
  }

  memcpy(DYinfo->disp_hd[0].geometry.polyline->points + 3, &point->x,
	 sizeof(IGRpoint));

  event.event.button = *point;
  boreline.point1 = startpoint;
  boreline.point2 = endpoint;

  EFboreline(&msg, stupid_id, &event, &boreline);
  BSmkvec(&msg, linevec, startpoint, endpoint);
  BSnorvec(&msg, linevec);

  *num_buffers = 1;
  *buffers = &DYinfo->disp_hd[0];

  *num_objects = 0;

  for (i = 0; i < DYinfo->num_spl_pts; i++)
  {
    pt_index = DYinfo->pt_indices[i];
    curr_sp = &DYinfo->ptr_spl_pts[pt_index];
    BSmkvec(&msg, pt_vec, curr_sp->pt_coord, startpoint);
    BScrossp(&msg, linevec, pt_vec, dir_vec);
    BScrossp(&msg, linevec, dir_vec, proj_vec);
    BSnorvec(&msg, proj_vec);

    if (fabs(BSdotp(&msg, proj_vec, pt_vec)) < tolr)
    {
      memcpy(DYinfo->disp_hd[0].geometry.polyline->points + 3,
	     curr_sp->pt_coord, sizeof(IGRpoint));
	
      *num_objects = 1;
      *objects = &curr_sp->pt_id;
      
      DYinfo->rc = DYN_SUCC_FIND_PT;
      DYinfo->index = i;
      
      break;
    }
  }

  if (i == DYinfo->num_spl_pts)
  {
    bspln.order = 2;
    bspln.periodic = FALSE;
    bspln.non_uniform = FALSE;
    bspln.num_poles = 2;
    bspln.poles = bspln_poles;
    memcpy(bspln_poles, startpoint, sizeof(IGRpoint));
    memcpy(bspln_poles + 3, endpoint, sizeof(IGRpoint));
    bspln.num_knots = 4;
    bspln.knots = bspln_knots;
    bspln_knots[0] = bspln_knots[1] = 0.0;
    bspln_knots[2] = bspln_knots[3] = 1.0;
    bspln.rational = FALSE;
    bspln.weights = NULL;
    bspln.planar = TRUE;
    bspln.phy_closed = FALSE;
    bspln.num_boundaries = 0;
    bspln.bdrys = NULL;

    find_edge = FALSE;
    for (i = 0; i < DYinfo->num_edges; i++)
    {
      BSmdistcvcv(&bspln, &DYinfo->edges[i], &num_pts, &par1, &par2,
		  &pt1, &pt2, &dist, &msg);
      if (par1)
	om$dealloc(ptr = par1);
      if (par2)
	om$dealloc(ptr = par2);
      if (pt1)
	om$dealloc(ptr = pt1);
      if (pt2)
	om$dealloc(ptr = pt2);

      if (msg == BSSUCC)
      {
	if (fabs(dist) < tolr)
	{
	  /* reject lines that the starting point is on */
	  BSmdistptcv(&DYinfo->edges[i], DYinfo->testpt, &k, &n, &pars,
		      &dist, &intpars, &msg);
	  if (n > 0 && pars)
	    om$dealloc(ptr = pars);
	  if (k > 0 && intpars)
	    om$dealloc(ptr = intpars);

	  if (fabs(dist) >= tolr)
	  {
	    /* reject line that has a special point on */
	    for (j = 0; j < DYinfo->num_spl_pts; j++)
	    {
	      pt_index = DYinfo->pt_indices[j];
	      curr_sp = &DYinfo->ptr_spl_pts[pt_index];
	      ptr_pt = curr_sp->pt_coord;
	      BSmdistptcv(&DYinfo->edges[i], ptr_pt, &k, &n, &pars,
			  &dist, &intpars, &msg);
	      if (n > 0 && pars)
		om$dealloc(ptr = pars);
	      if (k > 0 && intpars)
		om$dealloc(ptr = intpars);

	      if (fabs(dist) < tolr)
		break;
	    }

	    DYinfo->disp_hd[1].geometry.bspcurve = &DYinfo->edges[i];
	    *num_buffers = 2;

	    find_edge = TRUE;

	    if (j == DYinfo->num_spl_pts)
	    {
	      DYinfo->rc = DYN_SUCC_FIND_EDGE;
	      DYinfo->index = i;
	    }
	    else
	    {
	      memcpy(DYinfo->disp_hd[0].geometry.polyline->points + 3,
		     curr_sp->pt_coord, sizeof(IGRpoint));

	      *num_objects = 1;
	      *objects = &curr_sp->pt_id;
      
	      DYinfo->rc = DYN_SUCC_FIND_PT;
	      DYinfo->index = j;
	    }
	  }
	}
      }

      if (find_edge == TRUE)
	break;
    }

    if (find_edge == FALSE)
      DYinfo->rc = DYN_NOT_FIND;
  }

  return OM_S_SUCCESS;
}

#argsused
IGRint DYFUNCblendpt(DYinfo, point, matrix, objects, num_objects,
		     buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		     dummy_out1, dummy_out2, dummy_out3 )
struct ECDYN_blendpt *DYinfo;
struct EX_button *point;
IGRdouble *matrix;
struct GRid **objects;
struct DPele_header **buffers;
IGRint *num_objects, *num_buffers;
IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
{
  struct GRevent event;
  struct IGRline boreline;
  GRobjid stupid_id = NULL;
  struct IGRbsp_curve *bspcv;
  IGRpoint startpoint, endpoint, linept, curvept;
  IGRdouble tolr, lineparm, curveparm;
  IGRlong msg;
  extern IGRboolean EFboreline(), MAlnbcproj();
  extern IGRdouble dyn_tolerance(), fabs();
  extern void BScveval();

  /*
   * initialize
   */
  tolr = dyn_tolerance(&msg, point);
  if (msg == MSFAIL)
  {
    BSxtractpar(&msg, BSTOLCHRDHT, &tolr);
    tolr *= 10.0;
  }

  event.event.button = *point;
  boreline.point1 = startpoint;
  boreline.point2 = endpoint;
  EFboreline(&msg, stupid_id, &event, &boreline);

  memcpy(DYinfo->disp_hd[0].geometry.polyline->points + 3,
	 &point->x, sizeof(IGRpoint));

  bspcv = DYinfo->disp_hd[1].geometry.bspcurve;
  if (MAlnbcproj(&msg, &boreline, bspcv, &tolr,
		 linept, curvept, &lineparm, &curveparm))
  {
    if (curveparm >= bspcv->knots[bspcv->order - 1] &&
	curveparm <= bspcv->knots[bspcv->num_poles])
    {
      /*
      BSxtractpar(&msg, BSTOLLENVEC, &tolr);
      */
      if (fabs(curveparm - bspcv->knots[bspcv->order - 1]) < tolr)
	BScveval(bspcv, bspcv->knots[bspcv->order - 1], 0, curvept, &msg);
      else if (fabs(curveparm - bspcv->knots[bspcv->num_poles]) < tolr)
	BScveval(bspcv, bspcv->knots[bspcv->num_poles], 0, curvept, &msg);
      curveparm = (bspcv->knots[bspcv->order - 1] +
		   bspcv->knots[bspcv->num_poles]) / 2.0;
      BScveval(bspcv, curveparm, 0, DYinfo->testpt, &msg);

      memcpy(DYinfo->disp_hd[2].geometry.point_set->points, curvept,
	     sizeof(IGRpoint));
      memcpy(DYinfo->edge_pt, curvept, sizeof(IGRpoint));
      DYinfo->rc = DYN_SUCCESS;

      ex$message(msgnumb = EMS_S_ClearStatusField);
      *num_buffers = 3;
    }
    else
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_PtOutParmRng);
      DYinfo->rc = DYN_NO_PROJECTION;
      *num_buffers = 2;
    }
  }
  else
  {
    DYinfo->rc = DYN_NO_PROJECTION;
    *num_buffers = 2;
  }
  *buffers = DYinfo->disp_hd;

  return OM_S_SUCCESS;
}


IGRint EFdisplay_isocv(rc, geomsurf, lc_info, opt, parm, display, mode)
IGRlong *rc;
struct IGRbsp_surface *geomsurf;
struct GRlc_info *lc_info;
IGRshort opt;
IGRdouble parm;
struct IGRdisplay *display;
enum GRdpmode mode;
{
  OM_S_OBJID my_id = NULL;
  struct IGRbsp_surface *surf;
  IGRboolean alloc = FALSE;
  struct IGRdisplay active_display;
  struct IGRbsp_curve *isocv;
  IGRboolean test_planar = FALSE;
  IGRlong sts, msg;
  extern IGRlong EMget_the_geometry();
  extern void BSalloccv(), EFdisplay_bspcv();
  extern IGRboolean BSfreecv(), BSconstprcv();

  /* get surface geometry */
  if (geomsurf)
    surf = geomsurf;
  else
  {
    sts = EMget_the_geometry(lc_info, FALSE, FALSE, FALSE, my_id, &surf, &msg);
    if (!(1 & sts & msg))
    {
      if (surf)
	om$dealloc(ptr = surf);
      *rc = MSFAIL;
      goto quit;
    }
    alloc = TRUE;
  }

  if (display == NULL)
  {
    IGRlong sizbuf, nret;
    
    sizbuf = sizeof(struct IGRdisplay);
    gr$get_active_display(msg = &msg,
			  sizbuf = &sizbuf,
			  buffer = &active_display,
			  nret = &nret);
    display = &active_display;
  }

  /* allocate memory to store the iso curve */
  if (opt == U_DIRECTION)
    BSalloccv(surf->v_order, surf->v_num_poles, surf->rational, 0, &isocv, &msg);
  else
    BSalloccv(surf->u_order, surf->u_num_poles, surf->rational, 0, &isocv, &msg);

  /* construct the iso curve */
  BSconstprcv(&msg, surf, &opt, &parm, &test_planar, isocv);
  if (msg != BSSUCC)
  {
    if (alloc == TRUE)
      om$dealloc(ptr = surf);
    if (isocv)
      BSfreecv(&msg, isocv);
    *rc = MSFAIL;
    goto quit;
  }

  EFdisplay_bspcv(isocv, display, mode);

  *rc = MSSUCC;
  
  /* free allocated memory and return */
  if (alloc == TRUE)
    om$dealloc(ptr = surf);
  BSfreecv(&msg, isocv);

 quit:
  return OM_S_SUCCESS;
}

IGRint EFdisplay_plncutcv(rc, bspsurf, lc_info, point, normal, display, mode)
IGRlong *rc;
struct IGRbsp_surface *bspsurf;
struct GRlc_info *lc_info;
IGRpoint point;
IGRvector normal;
struct IGRdisplay *display;
enum GRdpmode mode;
{
  OM_S_OBJID my_id = NULL;
  struct IGRbsp_surface *surf;
  IGRboolean alloc = FALSE;
  struct IGRdisplay active_display;
  struct BSgeom_bsp_surf geomsurf, geompln;
  struct BSgeom_bsp_curve *xyzcvs, *uvcvs1, *uvcvs2;
  IGRint numgrps, *numints, *numpts, i, total_numcvs;
  IGRpoint **intpts;
  BSpair **uvpars1, **uvpars2;
  IGRshort cvscode;
  IGRlong msg, sts;
  BSrc bs_rc;
  extern IGRlong EMget_the_geometry();
  extern void BSsfsfint(), EFdisplay_bspcv();
  extern IGRboolean BSfreecv();

  /* get surface geometry */
  if (bspsurf)
    surf = bspsurf;
  else
  {
    sts = EMget_the_geometry(lc_info, FALSE, FALSE, FALSE, my_id, &surf, &msg);
    if (!(1 & sts & msg))
    {
      if (surf)
	om$dealloc(ptr = surf);
      *rc = MSFAIL;
      goto quit;
    }
    alloc = TRUE;
  }

  if (display == NULL)
  {
    IGRlong sizbuf, nret;
    
    sizbuf = sizeof(struct IGRdisplay);
    gr$get_active_display(msg = &msg,
			  sizbuf = &sizbuf,
			  buffer = &active_display,
			  nret = &nret);
    display = &active_display;
  }

  /* initialize BSgeom_bsp_surf for surface and plane */
  geomsurf.geom_prop = FALSE;
  geomsurf.type = BSGEN_BSP_SF;
  geomsurf.bounded = TRUE;
  geomsurf.urange[0] = surf->u_knots[surf->u_order - 1];
  geomsurf.urange[1] = surf->u_knots[surf->u_num_poles];
  geomsurf.vrange[0] = surf->v_knots[surf->v_order - 1];
  geomsurf.vrange[1] = surf->v_knots[surf->v_num_poles];
  geomsurf.bspsf = surf;
  geomsurf.sfgen_cv = NULL;

  geompln.geom_prop = TRUE;
  geompln.type = BSINF_PLANE;
  geompln.bounded = FALSE;
  geompln.reg_constr = TRUE;
  memcpy(geompln.pt1, point, sizeof(IGRpoint));
  memcpy(geompln.vec1, normal, sizeof(IGRvector));

  BSsfsfint(&geompln, &geomsurf, &numgrps, &numints, &numpts, &intpts,
	    &uvpars1, &uvpars2, &cvscode, &xyzcvs, &uvcvs1, &uvcvs2, &bs_rc);
  if (bs_rc == BSSUCC && cvscode)
  {
    EFdisplay_bspcv(xyzcvs[0].bspcv, display, mode);

    /* free memory */
    total_numcvs = 0;
    for (i = 0; i < numgrps; i++)
      total_numcvs += numints[i];

    if ((cvscode == 1 || cvscode == 3 || cvscode == 4 || cvscode == 5) &&
	xyzcvs)
    {
      for (i = 0; i < total_numcvs; i++)
      {
	if (xyzcvs[i].array1)
	  om$dealloc(ptr = xyzcvs[i].array1);
	if (xyzcvs[i].bspcv)
	  BSfreecv(&bs_rc, xyzcvs[i].bspcv);
      }
      om$dealloc(ptr = xyzcvs);
    }
    if ((cvscode == 2 || cvscode == 3 || cvscode == 4) && uvcvs1)
    {
      for (i = 0; i < total_numcvs; i++)
      {
	if (uvcvs1[i].array1)
	  om$dealloc(ptr = uvcvs1[i].array1);
	if (uvcvs1[i].bspcv)
	  BSfreecv(&bs_rc, uvcvs1[i].bspcv);
      }
      om$dealloc(ptr = uvcvs1);
    }
    if ((cvscode == 2 || cvscode == 3 || cvscode == 5) && uvcvs2)
    {
      for (i = 0; i < total_numcvs; i++)
      {
	if (uvcvs2[i].array1)
	  om$dealloc(ptr = uvcvs2[i].array1);
	if (uvcvs2[i].bspcv)
	  BSfreecv(&bs_rc, uvcvs2[i].bspcv);
      }
      om$dealloc(ptr = uvcvs2);
    }
    if (intpts)
    {
      for (i = 0; i < numgrps; i++)
	if (intpts[i])
	  om$dealloc(ptr = intpts[i]);
      om$dealloc(ptr = intpts);
    }
    if (uvpars1)
    {
      for (i = 0; i < numgrps; i++)
	if (uvpars1[i])
	  om$dealloc(ptr = uvpars1[i]);
      om$dealloc(ptr = uvpars1);
    }
    if (uvpars2)
    {
      for (i = 0; i < numgrps; i++)
	if (uvpars2[i])
	  om$dealloc(ptr = uvpars2[i]);
      om$dealloc(ptr = uvpars2);
    }
    if (numints)
      om$dealloc(ptr = numints);
    if (numpts)
      om$dealloc(ptr = numpts);
    *rc = MSSUCC;
  }
  else
  {
    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_ErrPlnSurfInt);
    *rc = MSFAIL;
  }
  if (alloc == TRUE)
    om$dealloc(ptr = surf);

 quit:
  return OM_S_SUCCESS;
}

/*
Abstract
    This function takes a input fillet surface and returns the edges
    of the surface with parameter u=0 and u=1. It assumes that only
    one edge can have parameter u=0 and u=1 respectively.

    INPUTS
    surf	- GRid of fillet surface
    tolr	- Tolerance used to determine points on u=0 or u=1

    OUTPUTS
    edge_u0, edge_u1
    		- GRid's of edges on u=0 and u=1
    msg		- return code:
    		  MULTIPLE_EDGES_ON_U0,	more than one edge on u=0
    		  MULTIPLE_EDGES_ON_U1,	more than one edge on u=1
    
*/

IGRint EMnat_u_edges(msg, surf, tolr, edge_u0, edge_u1)
IGRlong *msg;
struct GRid *surf;
IGRdouble tolr;
struct GRid *edge_u0, *edge_u1;
{
  IGRint buf_size, num_edges, cnt0, cnt1, i;
  IGRdouble beginpt[2], endpt[2];
  IGRboolean alloced = FALSE;
  struct GRid *edges;
  IGRlong sts, loc_msg;
  extern IGRdouble fabs();
  
  /* initialize */
  *msg = MSSUCC;
  sts = OM_S_SUCCESS;
  
  /* get parameter space tolerance */
  /*
  BSxtractpar(&loc_msg, BSTOLPARAM, &tolr);
  */

  buf_size = num_edges = 0;
  sts = om$send(msg = message EMSsurface.EMgetedges(&loc_msg,
						    EMS_OPT_NONDEG_NONSEAM,
						    &edges,
						    &buf_size,
						    &num_edges,
						    NULL,
						    NULL,
						    NULL,
						    NULL),
		senderid = NULL_OBJID,
		targetid = surf->objid,
		targetos = surf->osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
  alloced = TRUE;

  cnt0 = cnt1 = 0;
  for (i = 0; i < num_edges; i++)
  {
    sts = om$send(msg = message EMSedge.EMendpts(&loc_msg,
						 beginpt,
						 endpt,
						 NULL,
						 NULL,
						 NULL),
		  senderid = NULL_OBJID,
		  targetid = edges[i].objid,
		  targetos = edges[i].osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    if (fabs(beginpt[0]) < tolr && fabs(endpt[0]) < tolr)
    {
      if (cnt0)
      {
	*msg = MULTIPLE_EDGES_ON_U0;
	sts = OM_E_ABORT;
	goto quit;
      }
      else
      {
	memcpy(edge_u0, edges + i, sizeof(struct GRid));
	cnt0++;
      }
    }
    else if (fabs(beginpt[0] - 1.0) < tolr && fabs(endpt[0] - 1.0) < tolr)
    {
      if (cnt1)
      {
	*msg = MULTIPLE_EDGES_ON_U1;
	sts = OM_E_ABORT;
	goto quit;
      }
      else
      {
	memcpy(edge_u1, edges + i, sizeof(struct GRid));
	cnt1++;
      }
    }
  }

 quit:
  if (alloced)
    om$dealloc(ptr = edges);
  return sts;
}

/*
Abstract
    This function takes a input fillet surface and returns the radius
    of the fillet surface. We assume that fillet surface was created
    with arc in u direction.

    INPUTS
    bsp_fillet	- B-spline geometry of the fillet surface
    lc_fillet	- Located fillet surface

		  Input either one of them.

    which_end	- Extract radius from which end of the u parameter
    	          TRUE: at v=0 end;
		  FALSE: at v=1 end;

    OUTPUTS
    radius	- Radius of the fillet surface
    rc		- MSSUCC: successful; MSFAIL: failure
*/

IGRint EMget_fillet_radius(rc, bsp_fillet, lc_fillet, which_end, radius)
IGRlong *rc;
struct IGRbsp_surface *bsp_fillet;
struct GRlc_info *lc_fillet;
IGRboolean which_end;
IGRdouble *radius;
{
  IGRboolean alloc = FALSE;
  IGRboolean test_planar = FALSE;
  IGRdouble v_par;
  IGRlong msg, sts;
  OM_S_OBJID my_id = NULL;
  struct BSgeom_bsp_curve gm_cv;
  struct IGRbsp_surface *surf;
  struct IGRbsp_curve *end_arc;
  IGRshort opt = 2;			/* for constant v */
  extern IGRlong EMget_the_geometry();
  extern IGRboolean BSconstprcv(), BScirc_prop(), BSfreecv();
  extern void BSalloccv();

  /*
   * get surface geometry
   */
  if (bsp_fillet)
    surf = bsp_fillet;
  else
  {
    sts = EMget_the_geometry(lc_fillet, FALSE, FALSE, FALSE, my_id, &surf, &msg);
    if (!(1 & sts & msg))
    {
      if (surf)
	om$dealloc(ptr = surf);
      *rc = MSFAIL;
      goto quit;
    }
    alloc = TRUE;
  }

  /*
   * Allocate space for end arc
   */
  BSalloccv(surf->u_order, surf->u_num_poles, surf->rational, 0,
	    &end_arc, &msg);

  v_par = which_end == TRUE ? 0.0 : 1.0;

  /*
   * Extract the end arc
   */
  BSconstprcv(&msg, surf, &opt, &v_par, &test_planar, end_arc);

  /*
   * Initialize geometric curve structure
   */
  gm_cv.geom_prop = FALSE;
  gm_cv.bscv_flag = TRUE;
  gm_cv.type = BSCIRC_ARC;
  gm_cv.bspcv = end_arc;

  /*
   * Extract the property of the end arc
   */
  BScirc_prop(&gm_cv, &msg);
  *radius = gm_cv.len1;

  /*
   * Free allocated memory
   */
  if (alloc == TRUE)
    om$dealloc(ptr = surf);
  BSfreecv(&msg, end_arc);

  *rc = MSSUCC;

 quit:
  return OM_S_SUCCESS;
}


/*
Abstract
    This function takes a surface and a point. It determines whether
    the point is on the natural normal side of the surface.

    INPUTS
    bsp_sf	- B-spline geometry of the surface
    lc_sf	- Located surface

		  Input either one of them.

    point	- testing point


    OUTPUTS
    side	- TRUE: if the point is on the naturl side; FALSE: otherwise
    rc		- MSSUCC: successful; MSFAIL: failure
*/

IGRint EMdetermine_nat_side(msg, bsp_sf, lc_sf, point, side)
IGRlong *msg;
struct IGRbsp_surface *bsp_sf;
struct GRlc_info *lc_sf;
IGRpoint point;
IGRboolean *side;
{
  IGRboolean alloc = FALSE;
  IGRlong loc_msg, sts;
  OM_S_OBJID my_id = NULL;
  struct IGRbsp_surface *surf;
  extern IGRlong EMget_the_geometry();
  extern void BSptonnsdsf();

  /*
   * get surface geometry
   */
  if (bsp_sf)
    surf = bsp_sf;
  else
  {
    sts = EMget_the_geometry(lc_sf, FALSE, FALSE, FALSE, my_id, &surf, &loc_msg);
    if (!(1 & sts & loc_msg))
    {
      if (surf)
	om$dealloc(ptr = surf);
      *msg = MSFAIL;
      goto quit;
    }
    alloc = TRUE;
  }

  BSptonnsdsf(surf, point, side, &loc_msg);

  /*
   * Free allocated memory
   */
  if (alloc == TRUE)
    om$dealloc(ptr = surf);

  *msg = MSSUCC;

 quit:
  return OM_S_SUCCESS;
}


void EFdisplay_bspcv(bspcv, display, mode)
struct IGRbsp_curve *bspcv;
struct IGRdisplay *display;
enum GRdpmode mode;
{
  struct IGResbc curve_att;
  struct DPele_header disp_hd;
  IGRlong msg;

  /* initialize to display curve not polygon */
  curve_att.is_polydis = FALSE;
  curve_att.is_curvedis = TRUE;

  dp$build_dis_buffer(buffer = &disp_hd,
		      type = IGRBC,
		      display_att = display,
		      ele_spec_att = &curve_att,
		      geometry = (struct IGRbsp_curve *) bspcv);

  dp$display(msg = &msg,
	     mode = mode,
	     num_elem = 1,
	     buffer = &disp_hd);
}

end implementation ECcrbldsf;
