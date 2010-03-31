class implementation ECfilletsf1;

/*
Abstract
    This is the command object for manual mode rounding.

History 
    JSY	02/12/93	Creation.
    scw 08/14/94        clarified sleep method
*/

#include "EMS.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EMSasmacros.h"
#include "emssfintdef.h"
#include "EMSaction.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "igrdp.h"
#include "lcdef.h"
#include "dpstruct.h"
#include "msdef.h"
#include "comndef.h"
#include "grmacros.h"
#include "grmessage.h"
#include "adpdef.h"
#include "alloca.h"
#include "FI.h"
#include "EMSfillet.h"
#include "REgencompsf.h"

struct my_action_handler
{
  IGRint fill_type;
  Form form_ptr;
  IGRboolean state;
};

/* form constants */
#define STAT_FM 101
#define SAVE_CHANGE 1
#define TO_WINDOW 5
#define FILLET_TYPE 17
#define VAR_RAD_TYPE 18
#define FILLET_ENDS 19
#define INTERIOR_CUSPS 21
#define PROFILE_TYPE 22
#define EXT_DISTANCE 20
#define DISTANCE_TEXT 16
#define EXT_RADIUS_RATIO 25
#define RADIUS_RATIO_TEXT 26
#define RHO_VALUE 23
#define RHO_VALUE_TEXT 24

#define SUB_FM1 102
#define SF_SF_RAD 11
#define SF_SF_R1_R2 12
#define SF_SF_CV 13
#define SF_CV_RAD 14
#define SF_SF_SF 15

#define SUB_FM2 103
#define LINEAR_RAD 11
#define ARBITRARY_RAD 12

#define SUB_FM3 104
#define SHARP_CORNER 11
#define ROLLING_BALL 12

#define SUB_FM4 105
#define CIRCULAR 11
#define CHAMFER 12
#define ARBITRARY 13

#define SF1_SF2_RAD 1
#define SF1_SF2_EDGE 2

#define DEFAULT_RADIUS 0.1
#define DEFAULT_EXT_RADIUS_RATIO 2
#define CIR_RHO 0.41421356237309504880

/* state number definition */
#define BEGIN 0
#define PRE_LOCATE_ELEM 1
#define LOCATE_ELEM 2
#define DETERMINE_SURF_ORIENT 3
#define FLIP_SURFACE_NORMAL 4
#define GET_ENDING_RADIUS 5
#define INPUT_END_POINTS 6
#define LOCATE_LAW_CURVE 7
#define INPUT_MAXMIN_RADIUS 8
#define INPUT_FILLET_DIR 9

#define EMomerr_exit(sts, label) if (EMSerror(sts)) goto label;
#define MyStackAlloc(name) (struct name *) alloca(sizeof(struct name))

/*
%safe
static IGRboolean save_restore = FALSE;
%endsafe
*/

extern GRclassid OPP_EMSsubbs_class_id,
                 OPP_EMSedge_class_id,
                 OPP_GRbspline_class_id,
                 OPP_GAbcsubbc_class_id,
                 OPP_GRgraphics_class_id;

from EMSedge import EMxyz_endpt, EMgetsurface_info, EMtangent;
from GRgraphics import GRgetrang, GRdelete;

method init(IGRint type; IGRchar *strptr)
{
  IGRdouble g_val;
  IGRint i;
  IGRlong sts = OM_S_SUCCESS;
  IGRint labels[] = {SUB_FM1, SUB_FM2, SUB_FM3, SUB_FM4};
  IGRchar *names[] = {"EMFilSurfSb1", "EMFilSurfSb2", "EMFilSurfSb3", "EMFilSurfSb4"};
  extern void ECfilletsf1_process_fm();

  /* send the init message to my parent */
  sts = om$send(msg = message ECelements.init(type, strptr),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  /* initialize forms */
  if (FIf_new(STAT_FM, "EMFilSurf", ECfilletsf1_process_fm,
	      &ME.ECfilletsf1->stat_fm) != FI_SUCCESS)
    return OM_E_ABORT;
  if (FIf_set_cmd_oid_os(ME.ECfilletsf1->stat_fm, my_id, OM_Gw_current_OS)
      != FI_SUCCESS)
    return OM_E_ABORT;
  ME.ECfilletsf1->fm_disp = FALSE;

  for (i = 0; i < 4; i++)
  {
    if (FIf_new(labels[i], names[i], ECfilletsf1_process_fm,
		&ME.ECfilletsf1->sub_fms[i]) != FI_SUCCESS)
      return OM_E_ABORT;
    if (FIf_set_cmd_oid_os(ME.ECfilletsf1->sub_fms[i], my_id, OM_Gw_current_OS)
	!= FI_SUCCESS)
      return OM_E_ABORT;
  }

  ME.ECfilletsf1->fill_type = SF_SF_RAD;
  FIg_disable(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
  ME.ECfilletsf1->vrad_type = LINEAR_RAD;
  FIg_get_value(ME.ECfilletsf1->stat_fm, FILLET_ENDS, &g_val);
  ME.ECfilletsf1->ext_opt = (IGRboolean) g_val ? FALSE : TRUE;
  if (ME.ECfilletsf1->ext_opt)
  {
    g_val = TRUE;
    FIg_set_value(ME.ECfilletsf1->stat_fm, FILLET_ENDS, g_val);
    ME.ECfilletsf1->ext_opt = FALSE;
  }
  
  ME.ECfilletsf1->ext_radius_ratio = DEFAULT_EXT_RADIUS_RATIO;
  ME.ECfilletsf1->ext_distance = DEFAULT_EXT_RADIUS_RATIO * DEFAULT_RADIUS;
  if (ME.ECfilletsf1->ext_opt)
  {
    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO,
		  ME.ECfilletsf1->ext_radius_ratio);
    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_DISTANCE,
		  ME.ECfilletsf1->ext_distance);
  }
  else
  {
    FIg_erase(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
    FIg_erase(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
    FIg_erase(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
    FIg_erase(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
  }
  ME.ECfilletsf1->int_opt = SHARP_CORNER;
  ME.ECfilletsf1->prof_type = CIRCULAR;
  ME.ECfilletsf1->rho_value = CIR_RHO;
  FIg_set_value(ME.ECfilletsf1->stat_fm, RHO_VALUE, CIR_RHO);
  FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE);
  FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE_TEXT);
  
  ME.ECfilletsf1->radius = DEFAULT_RADIUS;
  ME.ECfilletsf1->radius1 = DEFAULT_RADIUS;
  ME.ECfilletsf1->radius2 = DEFAULT_RADIUS;
  ME.ECfilletsf1->maxmin_radius = DEFAULT_RADIUS;
  ME.ECfilletsf1->ctrline_cv = NULL;
  ME.ECfilletsf1->fillet_constructed = FALSE;
  ME.ECfilletsf1->undo_fillet = FALSE;

  return OM_S_SUCCESS;
}

method wakeup(IGRint pos)
{
  IGRlong sts = OM_S_SUCCESS, msg;
  IGRboolean assoc_state;

  gr$get_associative_flag(buffer = &assoc_state);
  if (assoc_state)
  {
    GRdisplay_associative_button(TRUE);
    me->associative = TRUE;
  }

  GRstatus_display_button(TRUE);

  sts = om$send(msg = message ECelements.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (ME.ECfilletsf1->fm_disp)
    FIf_display(ME.ECfilletsf1->stat_fm);

  switch (ME.ECfilletsf1->fill_type)
  {
  case SF_SF_RAD:
    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilConstRad);
    break;
  case SF_SF_R1_R2:
    if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLin);
    }
    else
    {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLaw);
    }
    break;
  case SF_SF_CV:
    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilSurfAlgCv);
    break;
  case SF_CV_RAD:
    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilCvToSurf);
    break;
  case SF_SF_SF:
    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilTripleSurf);
    break;
  }

  switch (ME.super_cmd->state)
  {
  case INPUT_FILLET_DIR:
    sts = om$send(msg = message ECfilletsf1.show_fillet_direction(&msg,
								  GRhd),
		  targetid = my_id);
    break;
  }

  return sts;
}

method super_cmd.sleep(IGRint pos)
{
  IGRlong sts = OM_S_SUCCESS, msg;

  if (me->associative)
    GRdisplay_associative_button(FALSE);

  GRstatus_display_button(FALSE);
  
  sts = om$send(msg = message ECelements.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (ME.ECfilletsf1->fm_disp)
    FIf_erase(ME.ECfilletsf1->stat_fm);

  switch (ME.super_cmd->state)
  {
  case INPUT_FILLET_DIR:
    sts = om$send(msg = message ECfilletsf1.show_fillet_direction(&msg,
								  GRhe),
		  targetid = my_id);
    break;
  }

  return sts;
}

method delete(IGRint defer_flag)
{
  IGRint i;
  IGRlong msg, sts = OM_S_SUCCESS;
  extern IGRboolean BSfreecv();

  sts = om$send(msg = message ECelements.delete(defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (ME.ECfilletsf1->stat_fm)
    FIf_delete(ME.ECfilletsf1->stat_fm);
  for (i = 0; i < 4; i++)
    if (ME.ECfilletsf1->sub_fms[i])
      FIf_delete(ME.ECfilletsf1->sub_fms[i]);

  if (ME.ECfilletsf1->ctrline_cv)
  {
    BSfreecv(&msg, ME.ECfilletsf1->ctrline_cv);
    ME.ECfilletsf1->ctrline_cv = NULL;
  }

  return sts;
}

method execute(IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRdouble tolr, tolr1, default_radius;
  GRclassid r_classmem[2], e_classmem[2], ne_classmem[2];
  OM_S_CLASSLIST rtree_classes, elig_classes, nelig_classes;
  IGRushort geomprops, options;
  IGRshort operation;
  IGRboolean loop = TRUE, edge_locatable = FALSE, *orient;
  char elem_type[GR_MAX_CHAR], msg1[GR_MAX_CHAR], msg2[GR_MAX_CHAR];
  enum EMSuser_responses useract;
  struct EMSaction_handler act_args;
  struct my_action_handler my_args;
  struct GRevent acc_event, loc_event;
  IGRint ev_response, min_to_lc, max_to_lc, i;
  IGRlong event_mask, event_mask1, locate_mask, bufsiz;
  struct IGRdisplay pt_disp;
  struct IGRpointset edge_endpt;
  struct DPele_header dis_buf;
  struct GRlc_info *elems, *lc_elem;
  struct GRlc_locate lc_attr;
  IGRlong sts, msg;
  extern IGRdouble fabs(), BSdistptpt();
  extern IGRboolean EFedge_curves_locatable(), BSfreecv();
  extern IGRlong EFdisplay_surface_normal();
  extern IGRint EFlocate_action_handler(), EMfilletsf_action_handler();
  extern IGRint EMdisplay_curve_ind();

  msg = MSSUCC;
  sts = OM_S_SUCCESS;
  
  ex$message(field = MESSAGE_FIELD, msgnumb = EM_M_0048);
  event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART;
  event_mask1 = event_mask;
  bufsiz = sizeof(struct GRevent) - 2 * sizeof(IGRint);
  BSxtractpar(&msg, BSTOLCLOSETOZERO, &tolr);
  BSxtractpar(&msg, BSTOLLENVEC, &tolr1);

  /* enter infinite loop */
  do
  {
    switch (ME.super_cmd->state)
    {
    case BEGIN:
      /* initialize */
      for (i = 0; i < 3; i++)
	ME.ECfilletsf1->orient[i] = TRUE;
      ME.ECfilletsf1->count = 1;
      ME.ECfilletsf1->closed = FALSE;
      ME.ECfilletsf1->equal_radii = FALSE;
      ME.ECfilletsf1->reverse = FALSE;
      ME.ECfilletsf1->get_rad = FALSE;
      ME.ECfilletsf1->get_rad1 = FALSE;
      ME.ECfilletsf1->get_rad2 = FALSE;
      ME.ECfilletsf1->get_maxmin_rad = FALSE;

      if (1 & msg)
      {
	switch (ME.ECfilletsf1->fill_type)
	{
	case SF_SF_RAD:
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilConstRad);
	  break;
	case SF_SF_R1_R2:
	  if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLin);
	  }
	  else
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLaw);
	  }
	  break;
	case SF_SF_CV:
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilSurfAlgCv);
	  break;
	case SF_CV_RAD:
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilCvToSurf);
	  break;
	case SF_SF_SF:
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilTripleSurf);
	  break;
	}
      }
      FIg_enable(ME.ECfilletsf1->stat_fm, FILLET_TYPE);
      if (ME.ECfilletsf1->ext_opt)
      {
	if (ME.ECfilletsf1->fillet_constructed == TRUE)
	{
	  ME.ECfilletsf1->ext_radius_ratio = DEFAULT_EXT_RADIUS_RATIO;
	  if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	  {
	    ME.ECfilletsf1->ext_distance = DEFAULT_EXT_RADIUS_RATIO *
	                                   ME.ECfilletsf1->radius;
	    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_DISTANCE,
			  ME.ECfilletsf1->ext_distance);
	  }
	  else
	    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO,
			  ME.ECfilletsf1->ext_radius_ratio);
	}
      }

      if (ME.ECfilletsf1->ctrline_cv)
      {
	BSfreecv(&msg, ME.ECfilletsf1->ctrline_cv);
	ME.ECfilletsf1->ctrline_cv = NULL;
      }

      if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	  ME.ECfilletsf1->fill_type == SF_SF_R1_R2)
      {
	ME.ECfilletsf1->prev_state = BEGIN;
	co$getevent(msg = &msg,
		    event_mask = event_mask | GRm_FORM_FINISHED,
		    msgnum = EMS_P_IdEdgeMvSurf,
		    response = response,
		    response_data = response_data,
		    event = &acc_event);
	switch (acc_event.response)
	{
	case EX_BACK_UP:
	  if (ME.ECfilletsf1->fillet_constructed == TRUE &&
	      ME.ECfilletsf1->undo_fillet == FALSE)
	  {
	    gr$display_object(object_id = &ME.ECfilletsf1->fillet_GRid,
			      mode = GRbe);
	    sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							    &me->active_md_env),
			  targetid = ME.ECfilletsf1->fillet_GRid.objid,
			  targetos = ME.ECfilletsf1->fillet_GRid.osnum);
	    ME.ECfilletsf1->undo_fillet = TRUE;
	  }
	  else
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	  }
	  break;
	
	case EX_RJT_MOVEON:
	  ME.ECfilletsf1->sub_type = SF1_SF2_RAD;
	  ME.ECfilletsf1->prev_state = PRE_LOCATE_ELEM;
	  ME.super_cmd->state = PRE_LOCATE_ELEM;
	  break;

	case EX_DATA:
	  /* put data point back for locating */
	  ev_response = EX_DATA;
	  if (acc_event.subtype != GRst_REGULAR)
	    acc_event.subtype = GRst_REGULAR;
	  sts = ex$putque(msg = &msg,
			  response = &ev_response,
			  byte = &bufsiz,
			  buffer = (IGRchar *) &acc_event.event);
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_S_ClearStatusField);
	  ME.ECfilletsf1->sub_type = SF1_SF2_EDGE;
	  ME.super_cmd->state = LOCATE_ELEM;
	  break;

	case EX_FORM_FINISHED:
	  if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	      ME.ECfilletsf1->fill_type == SF_SF_R1_R2)
	  {
	    ME.ECfilletsf1->prev_state = BEGIN;
	    ME.super_cmd->state = BEGIN;
	  }
	  else
	    ME.super_cmd->state = PRE_LOCATE_ELEM;
	  break;

	default:
	  return OM_S_SUCCESS;
	}
      }
      else
	ME.super_cmd->state = PRE_LOCATE_ELEM;
      break;

    case PRE_LOCATE_ELEM:
      switch (ME.ECfilletsf1->count)
      {
      case 1:
	FIg_enable(ME.ECfilletsf1->stat_fm, FILLET_TYPE);
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD)
	{
	  ex$message(msgnumb = EMS_P_CtrlCv, buff = msg1);
	  ex$message(buff = elem_type, msgnumb = EMS_S_IdenElemtype,
		     type = "%s", var = `msg1`);
	}
	else
	{
	  ex$message(msgnumb = EMS_P_IdentifySurface1, buff = elem_type);
	}
	break;
      case 2:
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD)
	{
	  ex$message(msgnumb = ME.ECfilletsf1->fill_type == SF_SF_CV ?
		               EMS_P_ContainCv : EMS_P_ToFillet,
		     buff = msg1);
	  ex$message(buff = elem_type, msgnumb = EMS_P_00062,
		     type = "%s", var = `msg1`);
	}
	else
	{
	  ex$message(buff = elem_type, msgnumb = EMS_P_IdentifySurface2);
	}
	break;
      case 3:
	ex$message(buff = elem_type, msgnumb = EMS_P_00062,
		   type = "%d", var = `ME.ECfilletsf1->count`);
	break;
      }
      co$getevent(msg = &msg,
		  event_mask = event_mask | GRm_FORM_FINISHED,
		  prompt = elem_type,
		  response = response,
		  response_data = response_data,
		  event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	if (ME.ECfilletsf1->count == 1)
	{
	  if (ME.ECfilletsf1->fillet_constructed == TRUE &&
	      ME.ECfilletsf1->undo_fillet == FALSE)
	  {
	    gr$display_object(object_id = &ME.ECfilletsf1->fillet_GRid,
			      mode = GRbe);
	    sts = om$send(msg = message GRgraphics.GRdelete(&msg,
							    &me->active_md_env),
			  targetid = ME.ECfilletsf1->fillet_GRid.objid,
			  targetos = ME.ECfilletsf1->fillet_GRid.osnum);
	    ME.ECfilletsf1->undo_fillet = TRUE;
	  }
	  ME.super_cmd->state = BEGIN;
	}
	else
	{
	  elems = ME.ECfilletsf1->lc_elems;
	  gr$display_object(object_id = &elems[ME.ECfilletsf1->count - 1].located_obj,
			    mode = GRbdhe);
	  ME.ECfilletsf1->count--;
	  ME.super_cmd->state = PRE_LOCATE_ELEM;
	}
	break;
	
      case EX_RJT_MOVEON:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	ME.super_cmd->state = PRE_LOCATE_ELEM;
	break;

      case EX_DATA:
	/* put data point back for locating */
	ev_response = EX_DATA;
	if (acc_event.subtype != GRst_REGULAR)
	  acc_event.subtype = GRst_REGULAR;
	sts = ex$putque(msg = &msg,
			response = &ev_response,
			byte = &bufsiz,
			buffer = (IGRchar *) &acc_event.event);
	ME.super_cmd->state = LOCATE_ELEM;
	break;

      case EX_FORM_FINISHED:
	if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	    ME.ECfilletsf1->fill_type == SF_SF_R1_R2)
	  ME.super_cmd->state = ME.ECfilletsf1->prev_state;
	else
	  ME.super_cmd->state = PRE_LOCATE_ELEM;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case LOCATE_ELEM:
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;

      elig_classes.w_count = 1;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;

      nelig_classes.w_count = 0;
      nelig_classes.w_flags = OM_CLST_subclass;
      nelig_classes.p_classes = ne_classmem;

      geomprops = NULL;
      operation = EC_GEOM_READ;

      max_to_lc = 1;
      min_to_lc = 0;

      options = EC_LOC_APPENDOBJNUM;

      switch (ME.ECfilletsf1->count)
      {
      case 1:
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD)
	{
	  r_classmem[0] = OPP_GRbspline_class_id;
	  e_classmem[0] = OPP_GRbspline_class_id;
	}
	else if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
		  ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
		 ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	{
	  r_classmem[0] = OPP_EMSedge_class_id;
	  e_classmem[0] = OPP_EMSedge_class_id;
	  edge_locatable = EFedge_curves_locatable();
	  if (!edge_locatable)
	    EFset_locate_eligibility(&msg, 1, "EMSedge");
	}
	else
	{
	  r_classmem[0] = OPP_EMSsubbs_class_id;
	  e_classmem[0] = OPP_EMSsubbs_class_id;
	}
	options = EC_LOC_APPENDOBJNUM;/* | EC_LOC_NO_RELOCATE;*/
	min_to_lc = 1;
	break;
      case 2:
      case 3:
	r_classmem[0] = OPP_EMSsubbs_class_id;
	e_classmem[0] = OPP_EMSsubbs_class_id;
	options = EC_LOC_APPENDOBJNUM;
	min_to_lc = 1;
	break;
      }

      sts = om$send(msg = message ECelements.set_locate_criteria(&msg,
								 MAXNUM_RESTRICTIVE_CLASSES-1,
								 &rtree_classes,
								 &elig_classes,
								 &nelig_classes,
								 geomprops,
								 operation,
								 options,
								 min_to_lc,
								 max_to_lc),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      switch (ME.ECfilletsf1->count)
      {
      case 1:
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD)
	{
	  ex$message(msgnumb = EMS_P_CtrlCv, buff = elem_type);
	  ex$message(msgnumb = ME.ECfilletsf1->fill_type == SF_SF_CV ?
		               EMS_P_ContainCv : EMS_P_ToFillet,
		     buff = msg2);
	  ex$message(buff = msg1, msgnumb = EMS_P_00062,
		     type = "%s", var = `msg2`);
	  strcpy(msg2, " (");
	  strcat(msg2, msg1);
	  strcat(msg2, ")");
	  strcpy(msg1, "");
	}
	else if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
		  ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
		 ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	{
	  ex$message(msgnumb = EMS_P_FillEdge, buff = elem_type);
	  strcpy(msg1, "");
	  strcpy(msg2, "");
	}
	else
	{
	  ex$message(msgnumb = EMS_P_FillSurf, buff = elem_type);
	  ex$message(msgnumb = EMS_P_IdentifySurface2, buff = msg1);
	  strcpy(msg2, " (");
	  strcat(msg2, msg1);
	  strcat(msg2, ")");
	  sprintf(msg1, " %d", ME.ECfilletsf1->count);
	}
	my_args.fill_type = ME.ECfilletsf1->fill_type;
	my_args.form_ptr = ME.ECfilletsf1->stat_fm;
	my_args.state = ME.ECfilletsf1->ext_opt;
	sts = om$send(msg = message ECelements.set_hndlr_funcs(&msg,
							       (IGRboolean (*) ()) EMfilletsf_action_handler,
							       (IGRchar *) &my_args,
							       NULL,
							       NULL),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	break;
      case 2:
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD)
	{
	  if (ME.ECfilletsf1->fill_type == SF_SF_CV)
	  {
	    ex$message(msgnumb = EMS_P_IdentifySurface2, buff = msg1);
	    strcpy(msg2, " (");
	    strcat(msg2, msg1);
	    strcat(msg2, ")");
	  }
	  else
	    strcpy(msg2, "");
	  ex$message(msgnumb = ME.ECfilletsf1->fill_type == SF_SF_CV ?
		               EMS_P_ContainCv : EMS_P_ToFillet,
		     buff = elem_type);
	  sprintf(msg1, " %s", elem_type);
	  ex$message(buff = elem_type, msgnumb = EMS_P_FillSurf);
	  
	  sts = om$send(msg = message ECelements.set_hndlr_funcs(&msg,
								 NULL,
								 NULL,
								 NULL,
								 NULL),
			targetid = my_id);
	  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	}
	else
	{
	  ex$message(buff = elem_type, msgnumb = EMS_P_FillSurf);
	  if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	  {
	    i = ME.ECfilletsf1->count + 1;
	    ex$message(buff = msg1, msgnumb = EMS_P_00062,
		       type = "%d", var = `i`);
	    strcpy(msg2, " (");
	    strcat(msg2, msg1);
	    strcat(msg2, ")");
	  }
	  else
	    strcpy(msg2, "");
	  sprintf(msg1, " %d", ME.ECfilletsf1->count);

	  elems = ME.ECfilletsf1->lc_elems;
	  act_args.next = NULL;
	  act_args.option = 0;
	  act_args.type = 0;
	  act_args.num_objects = 1;
	  act_args.objects.lc_info[0] = &ME.ECfilletsf1->lc_elems[0];
	  sts = om$send(msg = message ECelements.set_hndlr_funcs(&msg,
								 (IGRboolean (*) ()) EFlocate_action_handler,
								 (IGRchar *) &act_args,
								 NULL,
								 NULL),
			targetid = my_id);
	  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	}
	break;
      case 3:
	i = ME.ECfilletsf1->fill_type == SF_SF_SF ? ME.ECfilletsf1->count :
	                                            ME.ECfilletsf1->count - 1;
	ex$message(buff = elem_type, msgnumb = EMS_P_FillSurf);
	strcpy(msg2, "");
	sprintf(msg1, " %d", i);
	act_args.next = NULL;
	act_args.option = 0;
	act_args.type = 0;
	if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	{
	  act_args.num_objects = 2;
	  act_args.objects.lc_info[0] = &ME.ECfilletsf1->lc_elems[0];
	  act_args.objects.lc_info[1] = &ME.ECfilletsf1->lc_elems[1];
	}
	else
	{
	  act_args.num_objects = 1;
	  act_args.objects.lc_info[0] = &ME.ECfilletsf1->lc_elems[1];
	}
	sts = om$send(msg = message ECelements.set_hndlr_funcs(&msg,
							       (IGRboolean (*) ()) EFlocate_action_handler,
							       (IGRchar *) &act_args,
							       NULL,
							       NULL),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	break;
      }

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

      if (useract == EMSuser_data)
      {
	if (ME.ECelements->num_elems)
	{
	  switch (ME.ECfilletsf1->count)
	  {
	  case 1:
	    memcpy(ME.ECfilletsf1->lc_elems, ME.ECelements->elems,
		   sizeof(struct GRlc_info));

	    /* disable the form gadget */
	    FIg_disable(ME.ECfilletsf1->stat_fm, FILLET_TYPE);

	    if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
		 ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
		ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	    {
	      if (!edge_locatable)
		EFset_locate_eligibility(&msg, 0, "EMSedge");

	      /*
	       * If we are doing variable radii filleting, we need to
	       * extract the end points of the edge and determine if
	       * the edge is closed.
	       */
	      elems = ME.ECfilletsf1->lc_elems;
	      sts = om$send(msg = message EMSedge.EMxyz_endpt(&msg,
							      NULL,
							      &elems[0].module_info.md_env,
							      NULL,
							      NULL,
							      ME.ECfilletsf1->start_pt,
							      ME.ECfilletsf1->end_pt,
							      NULL),
			    targetid = elems[0].located_obj.objid,
			    targetos = elems[0].located_obj.osnum);
	      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	
	      if (BSdistptpt(&msg,
			     ME.ECfilletsf1->start_pt,
			     ME.ECfilletsf1->end_pt) < tolr1)
		ME.ECfilletsf1->closed = TRUE;
	      else
		ME.ECfilletsf1->closed = FALSE;

	      if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2 &&
		  ME.ECfilletsf1->sub_type == SF1_SF2_EDGE &&
		  ME.ECfilletsf1->closed == FALSE &&
		  ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
		ME.ECfilletsf1->which_point = 0;
	      ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	    }
	    else
	    {
	      /* put data point back for locating */
	      ev_response = EX_DATA;
	      if (ME.ECelements->accev.subtype != GRst_REGULAR)
		ME.ECelements->accev.subtype = GRst_REGULAR;
	      sts = ex$putque(msg = &msg,
			      response = &ev_response,
			      byte = &bufsiz,
			      buffer = (IGRchar *) &ME.ECelements->accev.event);
	      ME.ECfilletsf1->count++;
	      ME.super_cmd->state = LOCATE_ELEM;
	    }
	    break;
	  case 2:
	    memcpy(&ME.ECfilletsf1->lc_elems[1], ME.ECelements->elems,
		   sizeof(struct GRlc_info));

	    if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
		ME.ECfilletsf1->fill_type == SF_SF_SF)
	    {
	      /* put data point back for locating */
	      ev_response = EX_DATA;
	      if (ME.ECelements->accev.subtype != GRst_REGULAR)
		ME.ECelements->accev.subtype = GRst_REGULAR;
	      sts = ex$putque(msg = &msg,
			      response = &ev_response,
			      byte = &bufsiz,
			      buffer = (IGRchar *) &ME.ECelements->accev.event);
	      ME.ECfilletsf1->count++;
	      ME.super_cmd->state = LOCATE_ELEM;
	    }
	    else
	      ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	    break;
	  case 3:
	    memcpy(&ME.ECfilletsf1->lc_elems[2], ME.ECelements->elems,
		   sizeof(struct GRlc_info));
	    ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	    break;
	  }
	}
	else
	{
	  if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	       ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	      ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	    ME.super_cmd->state = BEGIN;
	  else if (ME.ECfilletsf1->count == 1)
	    ME.super_cmd->state = PRE_LOCATE_ELEM;
	  else
	    ME.super_cmd->state = LOCATE_ELEM;
	}
      }
      else if (useract == EMSuser_moveon)
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	     ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	    ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	  ME.super_cmd->state = BEGIN;
	else
	  ME.super_cmd->state = PRE_LOCATE_ELEM;
      }
      else if (useract == EMSuser_backup)
      {
	if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	     ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	    ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	  ME.super_cmd->state = BEGIN;
	else
	{
	  if (ME.ECfilletsf1->count > 1)
	  {
	    elems = ME.ECfilletsf1->lc_elems;
	    gr$display_object(object_id = &elems[ME.ECfilletsf1->count - 2].located_obj,
			      mode = GRbdhe);
	    ME.ECfilletsf1->count--;
	  }
	  ME.super_cmd->state = PRE_LOCATE_ELEM;
	}
      }
      else
      {
	if (useract == EMSuser_unknown)/* && (options & EC_LOC_NO_RELOCATE))*/
	{
	  /*
	  if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	       ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	      ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	    ME.super_cmd->state = BEGIN;
	  else
	    ME.super_cmd->state = PRE_LOCATE_ELEM;
	  */
	  return OM_S_SUCCESS;
	}
	else
	  goto quit;
      }
      break;

    case DETERMINE_SURF_ORIENT:
      if (ME.ECfilletsf1->fill_type == SF_SF_RAD &&
	  ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
      {
	ex$message(msgnumb = EMS_P_RadiusType3, buff = msg1);
	default_radius = ME.ECfilletsf1->radius;
	ex$message(buff = elem_type, msgnumb = EMS_P_KeyinRadius,
		   type = "%s%.3f", var = `msg1, default_radius`);
	event_mask1 = event_mask | GRm_VALUE;
      }
      else if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2 &&
	       ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
      {
	if (ME.ECfilletsf1->closed == TRUE)
	{
	  ex$message(msgnumb = EMS_P_RadiusType1, buff = msg1);
	  strcat(msg1, "/");
	  ex$message(msgnumb = EMS_P_RadiusType2, buff = msg2);
	  strcat(msg1, msg2);
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_StEndRadEqEd);
	}
	else
	{
	  ex$message(msgnumb = EMS_P_RadiusType1, buff = msg1);
	}
	default_radius = ME.ECfilletsf1->radius1;
	ex$message(buff = elem_type, msgnumb = EMS_P_KeyinRadius,
		   type = "%s%.3f", var = `msg1, default_radius`);
	if (ME.ECfilletsf1->closed != TRUE &&
	    ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	{
	  strcat(elem_type, "/");
	  ex$message(msgnumb = EMS_P_DataFlipEdEnds, buff = msg2);
	  strcat(elem_type, msg2);
	}
	event_mask1 = event_mask | GRm_VALUE;

	/*
	 * Construct the display buffer to display the starting point
	 * in 4 * active_weight
	 */
	edge_endpt.num_points = 1;
	if (ME.ECfilletsf1->closed != TRUE &&
	    ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	{
	  if (ME.ECfilletsf1->which_point)
	    edge_endpt.points = ME.ECfilletsf1->end_pt;
	  else
	    edge_endpt.points = ME.ECfilletsf1->start_pt;
	}
	else
	  edge_endpt.points = ME.ECfilletsf1->start_pt;
	
	memcpy(&pt_disp, &me->active_display, sizeof(struct IGRdisplay));
	if (pt_disp.weight < GR_HI_WEIGHT - 4)
	  pt_disp.weight += 4;
	else
	  pt_disp.weight = GR_HI_WEIGHT;

	dp$build_dis_buffer(buffer = &dis_buf,
			    type = IGRPS,
			    display_att = &pt_disp,
			    geometry = (struct IGRpointset *) &edge_endpt);
	dp$display(msg = &msg,
		   mode = GRhd,
		   num_elem = 1,
		   buffer = &dis_buf);
      }
      else
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_ArrIndFillDir);

	ex$message(msgnumb = EMS_P_FlipNormal, buff = msg1);
	if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD ||
	    ME.ECfilletsf1->fill_type == SF_SF_R1_R2)
	{
	  ex$message(buff = elem_type, msgnumb = EMS_P_00062,
		     type = "%s", var = `msg1`);
	  strcat(elem_type, "/");
	  ex$message(msgnumb = ME.ECfilletsf1->fill_type == SF_SF_R1_R2 ?
		               EMS_P_RadiusType1 : EMS_P_RadiusType3,
		     buff = msg1);
	  default_radius = ME.ECfilletsf1->fill_type == SF_SF_R1_R2 ?
	                   ME.ECfilletsf1->radius1 : ME.ECfilletsf1->radius;
	  ex$message(buff = msg2, msgnumb = EMS_P_KeyinRadius,
		     type = "%s%.3f", var = `msg1, default_radius`);
	  strcat(elem_type, msg2);
	  event_mask1 = event_mask | GRm_VALUE;
	}
	else if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
		 ME.ECfilletsf1->fill_type == SF_SF_SF)
	{
	  ex$message(buff = elem_type, msgnumb = EMS_P_00139,
		     type = "%s", var = `msg1`);
	  event_mask1 = event_mask;
	}

	orient = ME.ECfilletsf1->orient;
	elems = ME.ECfilletsf1->lc_elems;

	if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	    ME.ECfilletsf1->fill_type == SF_SF_R1_R2 ||
	    ME.ECfilletsf1->fill_type == SF_SF_SF)
	  EFdisplay_surface_normal(&elems[0], orient[0], my_id, TRUE,
				   &me->active_md_env, &me->active_display,
				   &msg);
	else if (ME.ECfilletsf1->fill_type == SF_CV_RAD)
	  EMdisplay_curve_ind(&msg, &elems[1], NULL, &elems[0], NULL, NULL,
			      &me->active_display, &elems[1].module_info,
			      GRhd, orient[0]);

	EFdisplay_surface_normal(&elems[1],
				 ME.ECfilletsf1->fill_type == SF_SF_CV ?
				 orient[0] : orient[1],
				 my_id, TRUE,
				 &me->active_md_env, &me->active_display,
				 &msg);
	if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_SF_SF)
	  EFdisplay_surface_normal(&elems[2],
				   ME.ECfilletsf1->fill_type == SF_SF_CV ?
				   orient[1] : orient[2],
				   my_id, TRUE,
				   &me->active_md_env, &me->active_display,
				   &msg);
      }

      ems$getevent(msg = &msg,
		   event_mask = event_mask1,
		   value_type = GRIO_DISTANCE,
		   prompt = elem_type,
		   response = (IGRlong *) response,
		   response_data = response_data,
		   event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	     ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	    ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	{
	  elems = ME.ECfilletsf1->lc_elems;
	  gr$display_object(object_id = &elems[0].located_obj,
			    mode = GRbdhe);
	  ME.super_cmd->state = BEGIN;
	}
	else
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_S_ClearStatusField);
	  orient = ME.ECfilletsf1->orient;
	  elems = ME.ECfilletsf1->lc_elems;

	  if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	      ME.ECfilletsf1->fill_type == SF_SF_R1_R2 ||
	      ME.ECfilletsf1->fill_type == SF_SF_SF)
	    EFdisplay_surface_normal(&elems[0], orient[0], my_id, FALSE,
				     &me->active_md_env, &me->active_display,
				     &msg);
	  else if (ME.ECfilletsf1->fill_type == SF_CV_RAD)
	    EMdisplay_curve_ind(&msg, &elems[1], NULL, &elems[0], NULL, NULL,
				&me->active_display, &elems[1].module_info,
				GRhe, orient[0]);

	  EFdisplay_surface_normal(&elems[1],
				   ME.ECfilletsf1->fill_type == SF_SF_CV ?
				   orient[0] : orient[1],
				   my_id, FALSE,
				   &me->active_md_env, &me->active_display,
				   &msg);
	  if (ME.ECfilletsf1->fill_type == SF_SF_CV ||
	      ME.ECfilletsf1->fill_type == SF_SF_SF)
	    EFdisplay_surface_normal(&elems[2],
				     ME.ECfilletsf1->fill_type == SF_SF_CV ?
				     orient[1] : orient[2],
				     my_id, FALSE,
				     &me->active_md_env, &me->active_display,
				     &msg);

	  gr$display_object(object_id = &elems[ME.ECfilletsf1->count - 1].located_obj,
			    mode = GRbdhe);

	  ME.super_cmd->state = LOCATE_ELEM;
	}
	break;

      case EX_DATA:
	if ((ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	     ME.ECfilletsf1->fill_type == SF_SF_R1_R2) &&
	    ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	{
	  if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2 &&
	      ME.ECfilletsf1->closed != TRUE &&
	      ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	  {
	    /*
	     * Construct the display buffer to erase the starting point
	     * in 4 * active_weight
	     */
	    edge_endpt.num_points = 1;
	    if (ME.ECfilletsf1->which_point)
	      edge_endpt.points = ME.ECfilletsf1->end_pt;
	    else
	      edge_endpt.points = ME.ECfilletsf1->start_pt;
	
	    memcpy(&pt_disp, &me->active_display, sizeof(struct IGRdisplay));
	    if (pt_disp.weight < GR_HI_WEIGHT - 4)
	      pt_disp.weight += 4;
	    else
	      pt_disp.weight = GR_HI_WEIGHT;

	    dp$build_dis_buffer(buffer = &dis_buf,
				type = IGRPS,
				display_att = &pt_disp,
				geometry = (struct IGRpointset *) &edge_endpt);
	    dp$display(msg = &msg,
		       mode = GRhe,
		       num_elem = 1,
		       buffer = &dis_buf);

	    if (ME.ECfilletsf1->which_point)
	      ME.ECfilletsf1->which_point = 0;
	    else
	      ME.ECfilletsf1->which_point = 1;
	  }
	  else
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	  ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	}
	else
	{
	  /* put data point back for locating */
	  if (acc_event.subtype != GRst_REGULAR)
	    acc_event.subtype = GRst_REGULAR;
	  sts = ex$putque(msg = &msg,
			  response = &acc_event.response,
			  byte = &bufsiz,
			  buffer = (IGRchar *) &acc_event.event);
	  ME.super_cmd->state = FLIP_SURFACE_NORMAL;
	}
	break;

      case EX_VALUE:
	if (acc_event.subtype != GRst_DEFAULT)
	{
	  if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	      ME.ECfilletsf1->fill_type == SF_CV_RAD)
	  {
	    ME.ECfilletsf1->radius = acc_event.event.value;
	    memcpy(&ME.ECfilletsf1->rad_ev, &acc_event,
		   sizeof(struct GRevent));
	    ME.ECfilletsf1->get_rad = TRUE;
	  }	    
	  else
	  {
	    ME.ECfilletsf1->radius1 = acc_event.event.value;
	    memcpy(&ME.ECfilletsf1->rad1_ev, &acc_event,
		   sizeof(struct GRevent));
	    ME.ECfilletsf1->get_rad1 = TRUE;
	  }
	}
	/* NO break */
	
      case EX_RJT_MOVEON:
	if (ME.ECfilletsf1->fill_type == SF_SF_RAD ||
	    ME.ECfilletsf1->fill_type == SF_CV_RAD ||
	    ME.ECfilletsf1->fill_type == SF_SF_CV ||
	    ME.ECfilletsf1->fill_type == SF_SF_SF)
	{
	  sts = om$send(msg = message ECfilletsf1.perform_construction(&msg),
			targetid = my_id);
	  ME.super_cmd->state = BEGIN;
	}
	else if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2)
	{
	  if (ME.ECfilletsf1->closed == TRUE)
	  {
	    ME.ECfilletsf1->radius2 = ME.ECfilletsf1->radius1;
	    ME.ECfilletsf1->equal_radii = TRUE;
	    if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
	    {
	      /*
	       * Place a varying radii fillet based on:
	       * o Closed edge
	       * o Linear law
	       * o Starting radius == Ending radius (replicate)
	       */
	      sts = om$send(msg = message ECfilletsf1.perform_construction
			    (&msg),
			    targetid = my_id);
	      ME.super_cmd->state = BEGIN;
	    }
	    else
	      ME.super_cmd->state = LOCATE_LAW_CURVE;
	  }
	  else
	  {
	    /*
	     * Since surfaces may be relocated, we have to free the
	     * center line intersection curve if there is any.
	     */
	    if (ME.ECfilletsf1->sub_type != SF1_SF2_EDGE &&
		ME.ECfilletsf1->ctrline_cv)
	    {
	      BSfreecv(&msg, ME.ECfilletsf1->ctrline_cv);
	      ME.ECfilletsf1->ctrline_cv = NULL;
	    }

	    ME.super_cmd->state = GET_ENDING_RADIUS;
	  }
	}
	else
	  ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case FLIP_SURFACE_NORMAL:
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;
      r_classmem[0] = OPP_EMSsubbs_class_id;

      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;
      e_classmem[0] = OPP_EMSsubbs_class_id;

      nelig_classes.w_count = 0;
      nelig_classes.w_flags = OM_CLST_subclass;
      nelig_classes.p_classes = ne_classmem;

      if (ME.ECfilletsf1->fill_type == SF_CV_RAD)
      {
	rtree_classes.w_count = 2;
	elig_classes.w_count = 2;
	r_classmem[1] = OPP_GRbspline_class_id;
	e_classmem[1] = OPP_GRbspline_class_id;
      }
      else
      {
	rtree_classes.w_count = 1;
	elig_classes.w_count = 1;
      }

      geomprops = NULL;
      operation = EC_GEOM_READ;
      options = EC_LOC_NO_ACC_RJT | EC_LOC_APPENDOBJNUM;

      sts = om$send(msg = message ECelements.set_locate_criteria(&msg,
								 MAXNUM_RESTRICTIVE_CLASSES-1,
								 &rtree_classes,
								 &elig_classes,
								 &nelig_classes,
								 geomprops,
								 operation,
								 options,
								 0,
								 1),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      if (ME.ECfilletsf1->fill_type == SF_SF_CV)
	elems = &ME.ECfilletsf1->lc_elems[1];
      else
	elems = ME.ECfilletsf1->lc_elems;
      act_args.next = NULL;
      act_args.option = 1;
      act_args.type = 0;
      act_args.num_objects = 2;
      act_args.objects.lc_info[0] = &elems[0];
      act_args.objects.lc_info[1] = &elems[1];
      if (ME.ECfilletsf1->fill_type == SF_SF_SF)
      {
	act_args.num_objects++;
	act_args.objects.lc_info[2] = &elems[2];
      }
      sts = om$send(msg = message ECelements.set_hndlr_funcs(&msg,
							     (IGRboolean (*) ()) EFlocate_action_handler,
							     (IGRchar *) &act_args,
							     NULL,
							     NULL),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      sts = om$send(msg = message ECelements.do_locate(&msg,
						       &useract,
						       response,
						       response_data,
						       elem_type,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       NULL),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
      
      if (useract == EMSuser_data)
      {
	if (ME.ECelements->num_elems)
	{
	  orient = ME.ECfilletsf1->orient;
	  lc_elem = &ME.ECelements->elems[0];
	  for (i = 0; i < act_args.num_objects; i++)
	    if (lc_elem->located_obj.objid == elems[i].located_obj.objid &&
		lc_elem->located_obj.osnum == elems[i].located_obj.osnum)
	    {
	      if (!i && ME.ECfilletsf1->fill_type == SF_CV_RAD)
		  EMdisplay_curve_ind(&msg, &elems[1], NULL, &elems[0], NULL, NULL,
				      &me->active_display, &elems[1].module_info,
				      GRhe, orient[0]);
	      else
		EFdisplay_surface_normal(&elems[i], orient[i], my_id, FALSE,
					 &me->active_md_env, &me->active_display, &msg);
		
	      orient[i] = (orient[i] ? FALSE : TRUE);
	      break;
	    }
	  if (i == act_args.num_objects)
	  {
	    ex$message(field = ERROR_FIELD, msgnumb = EMS_I_00011);
	  }
	}
	else
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_00011);
	}
      }
      else 
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_00011);
      }
      ME.super_cmd->state = DETERMINE_SURF_ORIENT;
      break;
      
    case GET_ENDING_RADIUS:
      /*
       * Reset locate criteria per Mike Mathis.
       * This is to fix the snapping problem reported by Eric Mawby
       * in the varying radius filleting where he cannot snap to a
       * Profile Point.
       */
      LCdel_criteria();

      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;
      rtree_classes.w_count = 1;
      r_classmem[0] = OPP_GRgraphics_class_id;

      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;
      elig_classes.w_count = 1;
      e_classmem[0] = OPP_GRgraphics_class_id;

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
								 0,
								 0),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      lc_attr.owner_action = ME.ECelements->owner_action;
      lc_attr.properties = ME.ECelements->properties;
      LCadd_criteria(ME.ECelements->display_flag,
		     &lc_attr,
		     &ME.ECelements->rtree_classes,
		     &ME.ECelements->elig_classes,
		     0,
		     GRhd,
		     ME.ECelements->options & EC_LOC_NOHALFHILITE ?
		     GRhe : GRhhd);

      if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
      {
	/*
	 * Construct the display buffer to erase the starting point
	 * and display the ending point in 4 * active_weight
	 */
	memcpy(&pt_disp, &me->active_display, sizeof(struct IGRdisplay));
	if (pt_disp.weight < GR_HI_WEIGHT - 4)
	  pt_disp.weight += 4;
	else
	  pt_disp.weight = GR_HI_WEIGHT;
	
	edge_endpt.num_points = 1;
	if (ME.ECfilletsf1->closed != TRUE &&
	    ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	{
	  if (ME.ECfilletsf1->which_point)
	    edge_endpt.points = ME.ECfilletsf1->end_pt;
	  else
	    edge_endpt.points = ME.ECfilletsf1->start_pt;
	}
	else
	  edge_endpt.points = ME.ECfilletsf1->start_pt;
	
	dp$build_dis_buffer(buffer = &dis_buf,
			    type = IGRPS,
			    display_att = &pt_disp,
			    geometry = (struct IGRpointset *) &edge_endpt);
	dp$display(msg = &msg,
		   mode = GRhe,
		   num_elem = 1,
		   buffer = &dis_buf);

	edge_endpt.num_points = 1;
	if (ME.ECfilletsf1->closed != TRUE &&
	    ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	{
	  if (ME.ECfilletsf1->which_point)
	    edge_endpt.points = ME.ECfilletsf1->start_pt;
	  else
	    edge_endpt.points = ME.ECfilletsf1->end_pt;
	}
	else
	  edge_endpt.points = ME.ECfilletsf1->end_pt;
	
	dp$build_dis_buffer(buffer = &dis_buf,
			    type = IGRPS,
			    display_att = &pt_disp,
			    geometry = (struct IGRpointset *) &edge_endpt);
	dp$display(msg = &msg,
		   mode = GRhd,
		   num_elem = 1,
		   buffer = &dis_buf);
      }

      ex$message(msgnumb = EMS_P_RadiusType2, buff = msg1);
      ex$message(buff = elem_type, msgnumb = EMS_P_KeyinRadius,
		 type = "%s%.3f", var = `msg1, ME.ECfilletsf1->radius2`);
      ems$getevent(msg = &msg,
		   event_mask = event_mask | GRm_VALUE,
		   value_type = GRIO_DISTANCE,
		   prompt = elem_type,
		   response = (IGRlong *) response,
		   response_data = response_data,
		   event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	ME.super_cmd->state = DETERMINE_SURF_ORIENT;
	break;

      case EX_DATA:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	ME.super_cmd->state = GET_ENDING_RADIUS;
	break;

      case EX_RJT_MOVEON:
      case EX_VALUE:
	if (acc_event.response == EX_VALUE)
	{
	  if (acc_event.subtype != GRst_DEFAULT)
	  {
	    ME.ECfilletsf1->radius2 = acc_event.event.value;
	    memcpy(&ME.ECfilletsf1->rad2_ev, &acc_event,
		   sizeof(struct GRevent));
	    ME.ECfilletsf1->get_rad2 = TRUE;
	  }
	}

	if (fabs(ME.ECfilletsf1->radius2 - ME.ECfilletsf1->radius1) < tolr)
	{
	  ME.ECfilletsf1->radius2 = ME.ECfilletsf1->radius1;
	  ME.ECfilletsf1->equal_radii = TRUE;
	}

	if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	{
	  /*
	   * Unhighlight the point
	   */
	  memcpy(&pt_disp, &me->active_display, sizeof(struct IGRdisplay));
	  if (pt_disp.weight < GR_HI_WEIGHT - 4)
	    pt_disp.weight += 4;
	  else
	    pt_disp.weight = GR_HI_WEIGHT;
	    
	  edge_endpt.num_points = 1;
	  if (ME.ECfilletsf1->closed != TRUE &&
	      ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	  {
	    if (ME.ECfilletsf1->which_point)
	      edge_endpt.points = ME.ECfilletsf1->start_pt;
	    else
	      edge_endpt.points = ME.ECfilletsf1->end_pt;
	  }
	  else
	    edge_endpt.points = ME.ECfilletsf1->end_pt;
	    
	  dp$build_dis_buffer(buffer = &dis_buf,
			      type = IGRPS,
			      display_att = &pt_disp,
			      geometry = (struct IGRpointset *) &edge_endpt);
	  dp$display(msg = &msg,
		     mode = GRhe,
		     num_elem = 1,
		     buffer = &dis_buf);
	    
	  if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
	  {
	    /*
	     * Place a varying radii fillet based on:
	     * o Open edge
	     * o Linear law
	     * o Starting radius
	     * o Ending radius
	     */
	    sts = om$send(msg = message ECfilletsf1.perform_construction
			  (&msg),
			  targetid = my_id);
	    ME.super_cmd->state = BEGIN;
	  }
	  else
	    ME.super_cmd->state = LOCATE_LAW_CURVE;
	}
	else
	{
	  ME.ECfilletsf1->which_point = 0;
	  ME.super_cmd->state = INPUT_END_POINTS;
	}
	break;

      default:
	return OM_S_SUCCESS;
      }

      break;

    case INPUT_END_POINTS:
      ems$getevent(msg = &msg,
		   event_mask = event_mask,
		   msgnum = ME.ECfilletsf1->which_point ?
		            EMS_P_FillEndPt : EMS_P_FillStartPt,
		   response = (IGRlong *) response,
		   response_data = response_data,
		   event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	if (ME.ECfilletsf1->which_point)
	{
	  ME.ECfilletsf1->which_point--;
	  ME.super_cmd->state = INPUT_END_POINTS;
	}
	else
	  ME.super_cmd->state = GET_ENDING_RADIUS;
	break;

      case EX_DATA:
	if (ME.ECfilletsf1->which_point)
	{
	  memcpy(&ME.ECfilletsf1->endpts[1], &acc_event,
		 sizeof(struct GRevent));
	  memcpy(ME.ECfilletsf1->end_pt, &acc_event.event.button.x,
		 sizeof(IGRpoint));

	  /*
	   * Set flag to indicate whether starting and ending points are
	   * the same.
	   */
	  if (BSdistptpt(&msg,
			 ME.ECfilletsf1->start_pt,
			 ME.ECfilletsf1->end_pt) < tolr1)
	    ME.ECfilletsf1->closed = TRUE;
	  else
	    ME.ECfilletsf1->closed = FALSE;

	  if (ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
	  {
	    if (ME.ECfilletsf1->closed == TRUE &&
		ME.ECfilletsf1->equal_radii != TRUE)
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_StEndPtEqInv);
	      ME.super_cmd->state = INPUT_END_POINTS;
	    }
	    else
	      ME.super_cmd->state = LOCATE_LAW_CURVE;
	  }
	  else
	  {
	    if (ME.ECfilletsf1->equal_radii != TRUE &&
		ME.ECfilletsf1->closed == TRUE)
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_StEndPtEqInv);
	      ME.super_cmd->state = INPUT_END_POINTS;
	    }
	    else
	    {
	      /*
	       * Call math to determine if the center line curve is closed.
	       * - This is the case where law curve is not input.
	       * Calculate center line curve based on:
	       * o sf1 & sf2
	       * o start_radius
	       * o end_radius
	       * o start_point
	       * o end_point 
	       * o linear option
	       */
	      if (!ME.ECfilletsf1->ctrline_cv)
	      {
		sts = om$send(msg = message ECfilletsf1.comp_fillet_ctrline
			      (&msg),
			      targetid = my_id);
		EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	      }

	      if (ME.ECfilletsf1->ctrline_cv->phy_closed)
	      {
		if (ME.ECfilletsf1->equal_radii == TRUE &&
		    ME.ECfilletsf1->closed == TRUE)
		{
		  /*
		   * Place a varying radii fillet based on:
		   * o Surface1 and Surface2
		   * o Starting radius == ending radius
		   * o Starting point == ending point
		   * o Linear law
		   * o Closed center line curve
		   */
		  sts = om$send(msg = message ECfilletsf1.perform_construction
				(&msg),
				targetid = my_id);
		  ME.super_cmd->state = BEGIN;
		}
		else
		{
		  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_ClsdFilEntDir);
		  ME.ECfilletsf1->prev_state = INPUT_END_POINTS;
		  ME.super_cmd->state = INPUT_FILLET_DIR;
		}
	      }
	      else if (ME.ECfilletsf1->equal_radii == TRUE &&
		       ME.ECfilletsf1->closed == TRUE)
	      {
		ex$message(field = ERROR_FIELD, msgnumb = EMS_E_StEndPtEqInv);
		ME.super_cmd->state = INPUT_END_POINTS;
	      }
	      else
	      {
		/*
		 * Place a varying radii fillet based on:
		 * o Surface1 and Surface2
		 * o Starting radius
		 * o ending radius
		 * o Starting point <> ending point
		 * o Linear law
		 * o Nonclosed center line curve
		 */
		sts = om$send(msg = message ECfilletsf1.perform_construction
			      (&msg),
			      targetid = my_id);
		ME.super_cmd->state = BEGIN;
	      }
	    }
	  }
	}
	else
	{
	  memcpy(&ME.ECfilletsf1->endpts[0], &acc_event,
		 sizeof(struct GRevent));
	  memcpy(ME.ECfilletsf1->start_pt, &acc_event.event.button.x,
		 sizeof(IGRpoint));
	  ME.ECfilletsf1->which_point++;
	  ME.super_cmd->state = INPUT_END_POINTS;
	}
	break;

      case EX_RJT_MOVEON:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_IgRjtMvOn);
	ME.super_cmd->state = INPUT_END_POINTS;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case LOCATE_LAW_CURVE:
      /*
       * Locate named law curve. Unfortunately, we cannot use do_locate
       * to do the job since do_locate does not support locate NAMED object.
       */
      locate_mask = GRm_TEXT_VALUE | GRm_BACK_UP;
      event_mask1 = GRm_TEXT_VALUE;
      
      lc_attr.properties = IGN_LC_BIT | IGN_RW_BIT | IGN_DP_BIT | IGN_MOD_BIT;
      lc_attr.owner_action = LC_NON_GEOM_MOD;

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = r_classmem;
      r_classmem[0] = OPP_GAbcsubbc_class_id;

      elig_classes.w_count = 1;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = e_classmem;
      e_classmem[0] = OPP_GAbcsubbc_class_id;

      sts = lc$locate(rc = &msg,
		      event1 = &loc_event,
		      event2 = &acc_event,
		      mask1 = locate_mask,
		      mask2 = event_mask1,
		      response = response,
		      response_data = response_data,
		      display_flag = LC_ACC_ONE_ELEMENT,
		      locate_key = EMS_P_EntNumbVarcv,
		      acc_key = EMS_P_AcceptReject,
		      relocate_key = EMS_I_CvNotLocated,
		      attributes = &lc_attr,
		      stack = &me->locate_stack,
		      rtree_classes = &rtree_classes,
		      eligible_classes = &elig_classes);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
      
      if (!(1 & msg))
      {
	if (loc_event.response == EX_BACK_UP)
	  ME.super_cmd->state = INPUT_END_POINTS;
	else
	  return OM_S_SUCCESS;
      }
      else
      {
	switch (acc_event.response)
	{
	case EX_STRING:
	  if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	  {
	    memcpy(&ME.ECfilletsf1->lc_elems[1], &acc_event.located_object[0],
		   sizeof(struct GRlc_info));

	    if (ME.ECfilletsf1->closed == TRUE ||
		ME.ECfilletsf1->equal_radii == TRUE)
	      ME.super_cmd->state = INPUT_MAXMIN_RADIUS;
	    else
	    {
	      /*
	       * Place a varying radii fillet based on:
	       * o Open edge
	       * o Law curve
	       * o Starting radius <> Ending radius
	       */
	      sts = om$send(msg = message ECfilletsf1.perform_construction
			    (&msg),
			    targetid = my_id);
	      ME.super_cmd->state = BEGIN;
	    }
	  }
	  else
	  {
	    memcpy(&ME.ECfilletsf1->lc_elems[2], &acc_event.located_object[0],
		   sizeof(struct GRlc_info));

	    if (ME.ECfilletsf1->equal_radii == TRUE)
	      ME.super_cmd->state = INPUT_MAXMIN_RADIUS;
	    else
	    {
	      /*
	       * Call math to determine if the center line curve is closed.
	       * - This is the case where law curve is input but maxmin
	       *   radius is not required.
	       * Calculate center line curve based on:
	       * o sf1 & sf2
	       * o start_radius <> end_radius
	       * o start_point <> end_point 
	       * o law curve option
	       */
	      if (!ME.ECfilletsf1->ctrline_cv)
	      {
		sts = om$send(msg = message ECfilletsf1.comp_fillet_ctrline
			      (&msg),
			      targetid = my_id);
		EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	      }

	      if (ME.ECfilletsf1->ctrline_cv->phy_closed)
	      {
		ex$message(field = ERROR_FIELD, msgnumb = EMS_I_ClsdIntEntDir);
		ME.ECfilletsf1->prev_state = LOCATE_LAW_CURVE;
		ME.super_cmd->state = INPUT_FILLET_DIR;
	      }
	      else
	      {
		/*
		 * Place a varying radii fillet based on:
		 * o Surface1 and Surface2
		 * o Starting radius <> ending radius
		 * o Starting point <> ending point
		 * o Law curve
		 * o Nonclosed center line curve
		 */
		sts = om$send(msg = message ECfilletsf1.perform_construction
			      (&msg),
			      targetid = my_id);
		ME.super_cmd->state = BEGIN;
	      }
	    }
	  }
	  break;
	  
	case EX_BACK_UP:
	  ME.super_cmd->state = INPUT_END_POINTS;
	  break;

	case EX_RJT_MOVEON:
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	  ME.super_cmd->state = LOCATE_LAW_CURVE;
	  break;
	  
	default:
	  return OM_S_SUCCESS;
	}
      }
      break;

    case INPUT_MAXMIN_RADIUS:
      ex$message(msgnumb = EMS_P_InMaxMinRad, buff = msg1);
      ex$message(buff = elem_type, msgnumb = EMS_P_InMaxMinRad,
		 type = "%.3f", var = `ME.ECfilletsf1->maxmin_radius`);
      ems$getevent(msg = &msg,
		   event_mask = event_mask | GRm_VALUE,
		   value_type = GRIO_DISTANCE,
		   prompt = elem_type,
		   response = (IGRlong *) response,
		   response_data = response_data,
		   event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	ME.super_cmd->state = LOCATE_LAW_CURVE;
	break;

      case EX_DATA:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_S_InpIgnored);
	ME.super_cmd->state = INPUT_MAXMIN_RADIUS;
	break;

      case EX_RJT_MOVEON:
      case EX_VALUE:
	if (acc_event.response == EX_VALUE)
	{
	  if (acc_event.subtype != GRst_DEFAULT)
	  {
	    ME.ECfilletsf1->maxmin_radius = acc_event.event.value;
	    memcpy(&ME.ECfilletsf1->maxmin_rad_ev, &acc_event,
		   sizeof(struct GRevent));
	    ME.ECfilletsf1->get_maxmin_rad = TRUE;
	  }
	}

	if (fabs(ME.ECfilletsf1->maxmin_radius - ME.ECfilletsf1->radius1)
	    < tolr)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_MMRadEqStEndInv);
	  ME.super_cmd->state = INPUT_MAXMIN_RADIUS;
	}
	else
	{
	  if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
	  {
	    if (ME.ECfilletsf1->closed == TRUE)
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_I_ClsdEdEntDir);
	      ME.ECfilletsf1->prev_state = INPUT_MAXMIN_RADIUS;
	      ME.super_cmd->state = INPUT_FILLET_DIR;
	    }
	    else
	    {
	      /*
	       * Place a varying radii fillet based on:
	       * o Open edge
	       * o Law curve
	       * o Starting radius
	       * o Ending radius
	       * o Maxmin radius
	       */
	      sts = om$send(msg = message ECfilletsf1.perform_construction
			    (&msg),
			    targetid = my_id);
	      ME.super_cmd->state = BEGIN;
	    }
	  }
	  else
	  {
	    /*
	     * Call math to determine if the center line curve is closed.
	     * - This is the case where law curve is input and maxmin
	     *   radius is required input.
	     * Calculate center line curve based on:
	     * o sf1 & sf2
	     * o start_radius == end_radius
	     * o maximum/minimum radius
	     * o start_point
	     * o end_point 
	     * o law curve option
	     */
	    if (!ME.ECfilletsf1->ctrline_cv)
	    {
	      sts = om$send(msg = message ECfilletsf1.comp_fillet_ctrline
			    (&msg),
			    targetid = my_id);
	      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	    }

	    if (ME.ECfilletsf1->ctrline_cv->phy_closed)
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_I_ClsdIntEntDir);
	      ME.ECfilletsf1->prev_state = INPUT_MAXMIN_RADIUS;
	      ME.super_cmd->state = INPUT_FILLET_DIR;
	    }
	    else if (ME.ECfilletsf1->closed == TRUE)
	    {
	      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_StEndPtEqInv);
	      ME.super_cmd->state = INPUT_END_POINTS;
	    }
	    else
	    {
	      /*
	       * Place a varying radii fillet based on:
	       * o Surface1 and Surface2
	       * o Starting radius == ending radius
	       * o Maximum or minimum radius
	       * o Starting point <> ending point
	       * o Law curve
	       * o Nonclosed center line curve
	       */
	      sts = om$send(msg = message ECfilletsf1.perform_construction
			    (&msg),
			    targetid = my_id);
	      ME.super_cmd->state = BEGIN;
	    }
	  }
	}
	break;

      default:
	return OM_S_SUCCESS;
      }

      break;
      
    case INPUT_FILLET_DIR:
      sts = om$send(msg = message ECfilletsf1.show_fillet_direction(&msg,
								    GRhd),
		    targetid = my_id);
      EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

      ems$getevent(msg = &msg,
		   event_mask = event_mask,
		   msgnum = EMS_P_AccFilletDir,
		   response = (IGRlong *) response,
		   response_data = response_data,
		   event = &acc_event);
      switch (acc_event.response)
      {
      case EX_BACK_UP:
	sts = om$send(msg = message ECfilletsf1.show_fillet_direction(&msg,
								      GRhe),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);
	ME.super_cmd->state = ME.ECfilletsf1->prev_state;
	break;

      case EX_DATA:
      case EX_RJT_MOVEON:
	ME.ECfilletsf1->reverse = acc_event.response == EX_DATA ?
	                          FALSE : TRUE;
	sts = om$send(msg = message ECfilletsf1.show_fillet_direction(&msg,
								      GRhe),
		      targetid = my_id);
	EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

	/*
	 * Place a varying radii fillet based on:
	 *
	 * A. Edge
	 *    o Closed edge
	 *    o start_radius == end_radius
	 *    o maximum or minimum radius
	 *    o start_point == end_point 
	 *    o law curve option
	 *
	 * B. Surfaces
	 *    a)
	 *    o Surface1 and Surface2
	 *    o start_radius == end_radius || start_radius <> end_radius
	 *    o start_point <> end_point 
	 *    o linear option
	 *    o closed center line curve
	 *    b)
	 *    o Surface1 and Surface2
	 *    o start_radius <> end_radius
	 *    o start_point <> end_point 
	 *    o law curve option
	 *    o closed center line curve
	 *    c)
	 *    o Surface1 and Surface2
	 *    o start_radius == end_radius
	 *    o maximum or minimum radius
	 *    o start_point <> end_point || start_point == end_point
	 *    o law curve option
	 *    o closed center line curve
	 *
	 */
	sts = om$send(msg = message ECfilletsf1.perform_construction(&msg),
		      targetid = my_id);

	ME.super_cmd->state = BEGIN;
	break;

      default:
	return OM_S_SUCCESS;
      }
    }
  } while (loop);

 quit:
  if (EMSerror(sts))
    *response = TERMINATE;
  return sts;
}

method status_disp()
{
  GRstatus_display_button(TRUE);

  if (!ME.ECfilletsf1->fm_disp)
  {
    FIf_display(ME.ECfilletsf1->stat_fm);
    ME.ECfilletsf1->fm_disp = TRUE;
  }
  return OM_S_SUCCESS;
}

method do_form(IGRlong *msg; IGRint form_label, gadget_label; IGRdouble value)
{
  IGRdouble tolr, g_val;
  IGRint index, response = EX_FORM_FINISHED;
  IGRint gxloc, gyloc;
  struct GRevent event;
  IGRlong bufsiz;
  extern IGRdouble fabs();

  bufsiz = sizeof(struct GRevent) - 2 * sizeof(IGRint);
  BSxtractpar(msg, BSTOLCLOSETOZERO, &tolr);

  switch (form_label)
  {
  case STAT_FM:
    switch (gadget_label)
    {
    case SAVE_CHANGE:
      FIg_reset(ME.ECfilletsf1->stat_fm, gadget_label);
      FIf_erase(ME.ECfilletsf1->stat_fm);
      ME.ECfilletsf1->fm_disp = FALSE;
      break;
    case TO_WINDOW:
      /*
      save_restore = TRUE;
      */
      break;
    case FILLET_TYPE:
      FIg_set_state_off(ME.ECfilletsf1->stat_fm, gadget_label);
      FIg_get_location(ME.ECfilletsf1->stat_fm, gadget_label, &gxloc, &gyloc);
      FIf_set_rel_location(ME.ECfilletsf1->sub_fms[0],
			    gxloc, gyloc,
			    ME.ECfilletsf1->stat_fm);
      FIf_display(ME.ECfilletsf1->sub_fms[0]);
      break;
    case VAR_RAD_TYPE:
      FIg_set_state_off(ME.ECfilletsf1->stat_fm, gadget_label);
      FIg_get_location(ME.ECfilletsf1->stat_fm, gadget_label, &gxloc, &gyloc);
      FIf_set_rel_location(ME.ECfilletsf1->sub_fms[1],
			    gxloc, gyloc,
			    ME.ECfilletsf1->stat_fm);
      FIf_display(ME.ECfilletsf1->sub_fms[1]);
      break;
    case FILLET_ENDS:
      FIg_get_value(ME.ECfilletsf1->stat_fm, gadget_label, &g_val);
      ME.ECfilletsf1->ext_opt = (IGRboolean) g_val ? FALSE : TRUE;
      if (ME.ECfilletsf1->ext_opt)
      {
	if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	{
	  FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_DISTANCE,
			ME.ECfilletsf1->ext_distance);
	  FIg_display(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
	  FIg_display(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
	}
	else
	{
	  FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO,
			ME.ECfilletsf1->ext_radius_ratio);
	  FIg_display(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
	  FIg_display(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
	}
      }
      else
      {
	if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	{
	  FIg_erase(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
	  FIg_erase(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
	}
	else
	{
	  FIg_erase(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
	  FIg_erase(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
	}
      }
      break;
    case INTERIOR_CUSPS:
      FIg_set_state_off(ME.ECfilletsf1->stat_fm, gadget_label);
      FIg_get_location(ME.ECfilletsf1->stat_fm, gadget_label, &gxloc, &gyloc);
      FIf_set_rel_location(ME.ECfilletsf1->sub_fms[2],
			    gxloc, gyloc,
			    ME.ECfilletsf1->stat_fm);
      FIf_display(ME.ECfilletsf1->sub_fms[2]);
      break;
    case PROFILE_TYPE:
      FIg_set_state_off(ME.ECfilletsf1->stat_fm, gadget_label);
      FIg_get_location(ME.ECfilletsf1->stat_fm, gadget_label, &gxloc, &gyloc);
      FIf_set_rel_location(ME.ECfilletsf1->sub_fms[3],
			    gxloc, gyloc,
			    ME.ECfilletsf1->stat_fm);
      FIf_display(ME.ECfilletsf1->sub_fms[3]);
      break;
    case EXT_DISTANCE:
      FIg_get_value(ME.ECfilletsf1->stat_fm, gadget_label,
		    &ME.ECfilletsf1->ext_distance);
      ME.ECfilletsf1->fillet_constructed = FALSE;
      break;
    case EXT_RADIUS_RATIO:
      FIg_get_value(ME.ECfilletsf1->stat_fm, gadget_label,
		    &ME.ECfilletsf1->ext_radius_ratio);
      ME.ECfilletsf1->fillet_constructed = FALSE;
      break;
    case RHO_VALUE:
      FIg_get_value(ME.ECfilletsf1->stat_fm, gadget_label,
		    &ME.ECfilletsf1->rho_value);
      if (fabs(ME.ECfilletsf1->rho_value) < tolr)
      {
	ME.ECfilletsf1->prof_type = CHAMFER;
	ME.ECfilletsf1->rho_value = 0.0;
	FIg_set_value(ME.ECfilletsf1->stat_fm, gadget_label, 0.0);
	FIg_erase(ME.ECfilletsf1->stat_fm, gadget_label);
	FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE_TEXT);
	FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[3], CHAMFER, &index);
	FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, PROFILE_TYPE, index);
	FIg_activate(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
	FIg_display(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
	FIg_set_state_on(ME.ECfilletsf1->sub_fms[3], CHAMFER);
	FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], CIRCULAR);
	FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], ARBITRARY);
      }
      else if (fabs(ME.ECfilletsf1->rho_value - CIR_RHO) < tolr)
      {
	ME.ECfilletsf1->prof_type = CIRCULAR;
	ME.ECfilletsf1->rho_value = CIR_RHO;
	FIg_set_value(ME.ECfilletsf1->stat_fm, gadget_label, CIR_RHO);
	FIg_erase(ME.ECfilletsf1->stat_fm, gadget_label);
	FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE_TEXT);
	FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[3], CIRCULAR, &index);
	FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, PROFILE_TYPE, index);
	FIg_activate(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
	FIg_display(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
	FIg_set_state_on(ME.ECfilletsf1->sub_fms[3], CIRCULAR);
	FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], CHAMFER);
	FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], ARBITRARY);
      }
      break;
    }
    /*
    if (ME.ECfilletsf1->fm_disp && !save_restore &&
	gadget_label != FILLET_TYPE && gadget_label != VAR_RAD_TYPE &&
	gadget_label != INTERIOR_CUSPS && gadget_label != PROFILE_TYPE)
    {
      FIf_erase(ME.ECfilletsf1->stat_fm);
      FIf_display(ME.ECfilletsf1->stat_fm);
    }
    */
    break;

  case SUB_FM1:
    switch (gadget_label)
    {
    case SF_SF_RAD:
    case SF_SF_R1_R2:
    case SF_SF_CV:
    case SF_CV_RAD:
    case SF_SF_SF:
      ME.ECfilletsf1->fill_type = gadget_label;
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[0], SF_SF_RAD);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[0], SF_SF_R1_R2);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[0], SF_SF_CV);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[0], SF_CV_RAD);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[0], SF_SF_SF);
      FIg_set_state_on(ME.ECfilletsf1->sub_fms[0], gadget_label);
      FIf_erase(ME.ECfilletsf1->sub_fms[0]);
      FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[0], gadget_label, &index);
      FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, FILLET_TYPE, index);
      FIg_activate(ME.ECfilletsf1->stat_fm, FILLET_TYPE);
      FIg_display(ME.ECfilletsf1->stat_fm, FILLET_TYPE);
      if (gadget_label != SF_SF_R1_R2)
	FIg_disable(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
      else
      {
	FIg_enable(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
	FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[1],
			     ME.ECfilletsf1->vrad_type, &index);
	FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE, index);
	FIg_activate(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
	FIg_display(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
      }
      if (gadget_label == SF_SF_CV || gadget_label == SF_CV_RAD)
      {
	FIg_disable(ME.ECfilletsf1->stat_fm, FILLET_ENDS);
	FIg_erase(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
	FIg_erase(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
	FIg_erase(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
	FIg_erase(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
      }
      else
      {
	FIg_enable(ME.ECfilletsf1->stat_fm, FILLET_ENDS);
	if (ME.ECfilletsf1->ext_opt)
	{
	  if (ME.ECfilletsf1->fill_type == SF_SF_SF)
	  {
	    FIg_erase(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
	    FIg_erase(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
	    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_DISTANCE,
			  ME.ECfilletsf1->ext_distance);
	    FIg_display(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
	    FIg_display(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
	  }
	  else
	  {
	    FIg_erase(ME.ECfilletsf1->stat_fm, DISTANCE_TEXT);
	    FIg_erase(ME.ECfilletsf1->stat_fm, EXT_DISTANCE);
	    FIg_set_value(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO,
			  ME.ECfilletsf1->ext_radius_ratio);
	    FIg_display(ME.ECfilletsf1->stat_fm, RADIUS_RATIO_TEXT);
	    FIg_display(ME.ECfilletsf1->stat_fm, EXT_RADIUS_RATIO);
	  }
	}
      }
      if (gadget_label != SF_SF_RAD)
	FIg_disable(ME.ECfilletsf1->stat_fm, INTERIOR_CUSPS);
      else
	FIg_enable(ME.ECfilletsf1->stat_fm, INTERIOR_CUSPS);
      ex$putque(msg = msg,
		response = &response,
		byte = &bufsiz,
		buffer = (IGRchar *) &event.event);
      switch (ME.ECfilletsf1->fill_type)
      {
      case SF_SF_RAD:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilConstRad);
	break;
      case SF_SF_R1_R2:
	if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLin);
	}
	else
	{
	  ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLaw);
	}
	break;
      case SF_SF_CV:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilSurfAlgCv);
	break;
      case SF_CV_RAD:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilCvToSurf);
	break;
      case SF_SF_SF:
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilTripleSurf);
	break;
      }
      break;
    default:
      break;
    }
    break;

  case SUB_FM2:
    switch (gadget_label)
    {
    case LINEAR_RAD:
    case ARBITRARY_RAD:
      ME.ECfilletsf1->vrad_type = gadget_label;
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[1], ARBITRARY_RAD);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[1], LINEAR_RAD);
      FIg_set_state_on(ME.ECfilletsf1->sub_fms[1], gadget_label);
      FIf_erase(ME.ECfilletsf1->sub_fms[1]);
      FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[1], gadget_label, &index);
      FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE, index);
      FIg_activate(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
      FIg_display(ME.ECfilletsf1->stat_fm, VAR_RAD_TYPE);
      if (ME.ECfilletsf1->vrad_type == LINEAR_RAD)
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLin);
      }
      else
      {
	ex$message(field = ERROR_FIELD, msgnumb = EMS_I_FilVarRadLaw);
      }
      break;
    default:
      break;
    }
    break;

  case SUB_FM3:
    switch (gadget_label)
    {
    case SHARP_CORNER:
    case ROLLING_BALL:
      ME.ECfilletsf1->int_opt = gadget_label;
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[2], ROLLING_BALL);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[2], SHARP_CORNER);
      FIg_set_state_on(ME.ECfilletsf1->sub_fms[2], gadget_label);
      FIf_erase(ME.ECfilletsf1->sub_fms[2]);
      FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[2], gadget_label, &index);
      FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, INTERIOR_CUSPS, index);
      FIg_activate(ME.ECfilletsf1->stat_fm, INTERIOR_CUSPS);
      FIg_display(ME.ECfilletsf1->stat_fm, INTERIOR_CUSPS);
      break;
    default:
      break;
    }
    break;

  case SUB_FM4:
    switch (gadget_label)
    {
    case CIRCULAR:
    case CHAMFER:
    case ARBITRARY:
      ME.ECfilletsf1->prof_type = gadget_label;
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], CIRCULAR);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], CHAMFER);
      FIg_set_state_off(ME.ECfilletsf1->sub_fms[3], ARBITRARY);
      FIg_set_state_on(ME.ECfilletsf1->sub_fms[3], gadget_label);
      FIf_erase(ME.ECfilletsf1->sub_fms[3]);
      if (gadget_label == CIRCULAR || gadget_label == CHAMFER)
      {
	ME.ECfilletsf1->rho_value = gadget_label == CIRCULAR ? CIR_RHO : 0.0;
	FIg_set_value(ME.ECfilletsf1->stat_fm, RHO_VALUE,
		      ME.ECfilletsf1->rho_value);
	FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE);
	FIg_erase(ME.ECfilletsf1->stat_fm, RHO_VALUE_TEXT);
      }
      else
      {
	FIg_display(ME.ECfilletsf1->stat_fm, RHO_VALUE);
	FIg_display(ME.ECfilletsf1->stat_fm, RHO_VALUE_TEXT);
      }
      FIg_get_symbol_index(ME.ECfilletsf1->sub_fms[3], gadget_label, &index);
      FIg_set_symbol_index(ME.ECfilletsf1->stat_fm, PROFILE_TYPE, index);
      FIg_activate(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
      FIg_display(ME.ECfilletsf1->stat_fm, PROFILE_TYPE);
      break;
    default:
      break;
    }
    break;

  default:
    break;
  }
  /*
  if ((form_label == SUB_FM1 || form_label == SUB_FM2 ||
       form_label == SUB_FM3 || form_label == SUB_FM4) && !save_restore)
  {
    FIf_erase(ME.ECfilletsf1->stat_fm);
    FIf_display(ME.ECfilletsf1->stat_fm);
  }
  */
  return OM_S_SUCCESS;
}

method comp_fillet_direction(IGRlong *EMmsg)
{
  IGRdouble u1, v1, dist1, u2, v2, dist2;
  IGRpoint pt1, pt2;
  IGRvector normal1, normal2;
  struct GRid sf1_GRid, sf2_GRid, *edge_GRid = NULL;
  OM_S_CHANSELECT edge_chan;
  OM_S_OBJECT_LINKAGE edge_link;
  OMuint edge_count;
  struct GRmdenv_info *md_env1, *md_env2;
  struct IGRbsp_surface *ptr_geom_sf1, *ptr_geom_sf2;
  IGRlong loc_msg, sts;

  extern IGRboolean BSmdistptsf(), BScrossp(), BSnorvec();
  extern void BSsfarrevn();
  
  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;

  ptr_geom_sf1 = ptr_geom_sf2 = NULL;

  if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
  {
    edge_GRid = &ME.ECfilletsf1->lc_elems[0].located_obj;
    sts = om$send(msg = message EMSedge.EMgetsurface_info(&loc_msg,
							  &sf1_GRid.objid,
							  NULL),
		  senderid = NULL_OBJID,
		  targetid = edge_GRid->objid,
		  targetos = edge_GRid->osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    sf1_GRid.osnum = edge_GRid->osnum;

    sts = om$make_chanselect(channame = "EMSedge.to_common_edge",
			     p_chanselect = &edge_chan);
    EMerr_hndlr(EMSerror(sts), sts, OM_E_ABORT, quit);

    sts = om$get_channel_objects(objid = edge_GRid->objid,
				 osnum = edge_GRid->osnum,
				 p_chanselect = &edge_chan,
				 size = 1,
				 list = &edge_link,
				 count = &edge_count);
    EMerr_hndlr(EMSerror(sts), sts, OM_E_ABORT, quit);

    sts = om$send(msg = message EMSedge.EMgetsurface_info(&loc_msg,
							  &sf2_GRid.objid,
							  NULL),
		  senderid = NULL_OBJID,
		  targetid = edge_link.S_objid,
		  targetos = edge_GRid->osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    sf2_GRid.osnum = edge_GRid->osnum;

    md_env1 = md_env2 = &ME.ECfilletsf1->lc_elems[0].module_info.md_env;
  }
  else
  {
    sf1_GRid = ME.ECfilletsf1->lc_elems[0].located_obj;
    md_env1 = &ME.ECfilletsf1->lc_elems[0].module_info.md_env;
    sf2_GRid = ME.ECfilletsf1->lc_elems[1].located_obj;
    md_env2 = &ME.ECfilletsf1->lc_elems[1].module_info.md_env;
  }
  
  sts = EMgetvggeom(&loc_msg,
		    &md_env1->matrix_type,
		    md_env1->matrix,
		    &sf1_GRid,
		    &ptr_geom_sf1,
		    NULL);
  EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);

  sts = EMgetvggeom(&loc_msg,
		    &md_env2->matrix_type,
		    md_env2->matrix,
		    &sf2_GRid,
		    &ptr_geom_sf2,
		    NULL);
  EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);

  BSmdistptsf(&loc_msg, ptr_geom_sf1, ME.ECfilletsf1->start_pt,
	      &u1, &v1, &pt1, &dist1);
  EMerr_hndlr(loc_msg != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

  BSmdistptsf(&loc_msg, ptr_geom_sf2, ME.ECfilletsf1->start_pt,
	      &u2, &v2, &pt2, &dist2);
  EMerr_hndlr(loc_msg != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

  BSsfarrevn(&loc_msg, ptr_geom_sf1, 1, &u1, 1, &v1, pt1, normal1);
  BSsfarrevn(&loc_msg, ptr_geom_sf2, 1, &u2, 1, &v2, pt2, normal2);
  BScrossp(&loc_msg, normal1, normal2, ME.ECfilletsf1->fillet_dir);
  BSnorvec(&loc_msg, ME.ECfilletsf1->fillet_dir);
 
 quit:
  if (ptr_geom_sf1)
    om$dealloc(ptr = ptr_geom_sf1);
  
  if (ptr_geom_sf2)
    om$dealloc(ptr = ptr_geom_sf2);
  
  return sts;
}

method show_fillet_direction(IGRlong *msg; enum GRdpmode mode)
{
  GRrange range;
  struct GRid *edge_GRid, sf_GRid;
  IGRboolean wd_loc = TRUE;
  struct GRmd_env *md_env;
  IGRlong loc_msg, sts;

  extern void EFdraw_vector_on_screen();
  extern IGRboolean BSnorvec();
  
  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  md_env = &ME.ECfilletsf1->lc_elems[0].module_info;
  if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
  {
    edge_GRid = &ME.ECfilletsf1->lc_elems[0].located_obj;
    sts = om$send(msg = message EMSedge.EMgetsurface_info(&loc_msg,
							  &sf_GRid.objid,
							  NULL),
		  senderid = NULL_OBJID,
		  targetid = edge_GRid->objid,
		  targetos = edge_GRid->osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    sf_GRid.osnum = edge_GRid->osnum;

    sts = om$send(msg = message EMSedge.EMtangent(&loc_msg,
						  md_env,
						  &sf_GRid.objid,
						  ME.ECfilletsf1->start_pt,
						  1.0,
						  NULL,
						  ME.ECfilletsf1->fillet_dir),
		  senderid = NULL_OBJID,
		  targetid = edge_GRid->objid,
		  targetos = edge_GRid->osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    BSnorvec(&msg, ME.ECfilletsf1->fillet_dir);
  }
  else
    sf_GRid = ME.ECfilletsf1->lc_elems[0].located_obj;
    
  sts = om$send(msg = message GRgraphics.GRgetrang(&loc_msg,
						   &md_env->md_env.matrix_type,
						   md_env->md_env.matrix,
						   &wd_loc,
						   range),
		targetid = sf_GRid.objid,
		targetos = sf_GRid.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
  
  EFdraw_vector_on_screen(my_id,
			  &me->active_display,
			  md_env,
			  mode,
			  FALSE,
			  ME.ECfilletsf1->start_pt,
			  ME.ECfilletsf1->fillet_dir,
			  range,
			  &loc_msg);

 quit:
  return sts;
}


method comp_fillet_ctrline(IGRlong *msg)
{
  IGRboolean *orient;
  struct GRlc_info *elems;
  struct GRmd_env *md_env;
  struct GRid *law_cv_GRid = NULL;
  IGRlong loc_msg, sts;

  extern IGRint EMget_fillet_ctrline();
  extern IGRboolean BSnorvec();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  elems = ME.ECfilletsf1->lc_elems;
  orient = ME.ECfilletsf1->orient;
  md_env = &ME.ECfilletsf1->lc_elems[0].module_info;

  if (ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
    law_cv_GRid = &elems[2].located_obj;

  sts = EMget_fillet_ctrline(&loc_msg,
			     md_env,
			     &elems[0].located_obj,
			     NULL,
			     &elems[1].located_obj,
			     NULL,
			     orient[0],
			     orient[1],
			     ME.ECfilletsf1->radius1,
			     ME.ECfilletsf1->radius2,
			     ME.ECfilletsf1->maxmin_radius,
			     ME.ECfilletsf1->start_pt,
			     ME.ECfilletsf1->end_pt,
			     NULL,
			     NULL,
			     law_cv_GRid,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     NULL,
			     ME.ECfilletsf1->reverse,
			     ME.ECfilletsf1->ext_distance,
			     ME.ECfilletsf1->ext_distance,
			     ME.ECfilletsf1->rho_value,
			     &ME.ECfilletsf1->ctrline_cv,
			     &ME.ECfilletsf1->ctrline_type);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  BSmkvec(&msg,
	  ME.ECfilletsf1->fillet_dir,
	  &ME.ECfilletsf1->ctrline_cv->poles[0],
	  &ME.ECfilletsf1->ctrline_cv->poles[3]);
  BSnorvec(&msg, ME.ECfilletsf1->fillet_dir);

 quit:
  return sts;
}


method perform_construction(IGRlong *msg)
{
  IGRdouble tolr;
  IGRboolean assoc_placement, *orient, normal1, normal2, normal3, is_chamfer;
  struct GRlc_info *elems;
  struct EMSobject_info *element1, *element2, *element3, *law_curve;
  struct EMSpoint_info *start_point, *end_point;
  struct EMSvalue_info *start_radius, *end_radius, *mm_radius;
  struct EMSvalue_info *ext_distance, *rho_value;
  IGRint fillet_type;
  IGRushort fillet_opts = NULL;
  char msg1[GR_MAX_CHAR], msg2[GR_MAX_CHAR];
  IGRlong loc_msg, sts;
  extern IGRlong EFdisplay_surface_normal();
  extern IGRint EMdisplay_curve_ind();
  extern IGRdouble fabs();
  extern IGRlong EMplace_fillet1();
  extern IGRboolean BSfreecv();
  
  /* initilize */
  ME.ECfilletsf1->fillet_constructed = FALSE;
  ME.ECfilletsf1->undo_fillet = TRUE;
  
  /*
  BSxtractpar(&loc_msg, BSRHO_VALUE, &default_rho);
  */
  BSxtractpar(&loc_msg, BSTOLCLOSETOZERO, &tolr);
  elems = ME.ECfilletsf1->lc_elems;
  orient = ME.ECfilletsf1->orient;

  element1 = element2 = element3 = law_curve = NULL;
  normal1 = normal2 = normal3 = NULL;
  start_radius = end_radius = mm_radius = NULL;
  start_point = end_point = NULL;
  ext_distance = rho_value = NULL;
  fillet_type = 0;

  /*
   * get associative flag
   */
  gr$get_associative_flag(buffer = &assoc_placement);

  switch (ME.ECfilletsf1->fill_type)
  {
  case SF_SF_RAD:
    fillet_type = ME.ECfilletsf1->sub_type == SF1_SF2_EDGE ? 1 : 2;

    element1 = MyStackAlloc(EMSobject_info);
    memcpy(&element1->grid, &elems[0].located_obj, sizeof(struct GRid));
    memcpy(&element1->env, &elems[0].module_info, sizeof(struct GRmd_env));
    normal1 = orient[0];

    /* redraw located objects in background */
    gr$display_object(object_id = &elems[0].located_obj,
		      mode = GRbdhe);

    if (ME.ECfilletsf1->sub_type != SF1_SF2_EDGE)
    {
      element2 = MyStackAlloc(EMSobject_info);
      memcpy(&element2->grid, &elems[1].located_obj, sizeof(struct GRid));
      memcpy(&element2->env, &elems[1].module_info, sizeof(struct GRmd_env));
      normal2 = orient[1];

      /* redraw located objects in background */
      gr$display_object(object_id = &elems[1].located_obj,
			mode = GRbdhe);

      /* erase display of surface normals */
      EFdisplay_surface_normal(&elems[0], orient[0], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      EFdisplay_surface_normal(&elems[1], orient[1], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
    }
    
    start_radius = MyStackAlloc(EMSvalue_info);
    if (ME.ECfilletsf1->get_rad == TRUE)
    {
      start_radius->type = EMSdatainfo_event;
      start_radius->valevent = &ME.ECfilletsf1->rad_ev;
    }
    else
    {
      start_radius->type = EMSdatainfo_numeric;
      start_radius->val = ME.ECfilletsf1->radius;
    }

    ext_distance = MyStackAlloc(EMSvalue_info);
    ext_distance->type = EMSdatainfo_numeric;
    ext_distance->val = ME.ECfilletsf1->ext_opt ?
                        ME.ECfilletsf1->ext_radius_ratio : 0.0;
    break;
      
  case SF_SF_R1_R2:
    fillet_type = ME.ECfilletsf1->sub_type == SF1_SF2_EDGE ? 3 : 4;

    element1 = MyStackAlloc(EMSobject_info);
    memcpy(&element1->grid, &elems[0].located_obj, sizeof(struct GRid));
    memcpy(&element1->env, &elems[0].module_info, sizeof(struct GRmd_env));
    normal1 = orient[0];

    /* redraw located objects in background */
    gr$display_object(object_id = &elems[0].located_obj,
		      mode = GRbdhe);

    if (ME.ECfilletsf1->sub_type != SF1_SF2_EDGE)
    {
      element2 = MyStackAlloc(EMSobject_info);
      memcpy(&element2->grid, &elems[1].located_obj, sizeof(struct GRid));
      memcpy(&element2->env, &elems[1].module_info, sizeof(struct GRmd_env));
      normal2 = orient[1];

      /* redraw located objects in background */
      gr$display_object(object_id = &elems[1].located_obj,
			mode = GRbdhe);

      /* erase display of surface normals */
      EFdisplay_surface_normal(&elems[0], orient[0], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      EFdisplay_surface_normal(&elems[1], orient[1], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);

      start_point = MyStackAlloc(EMSpoint_info);
      start_point->type = EMSdatainfo_event;
      start_point->ptevent = &ME.ECfilletsf1->endpts[0];

      end_point = MyStackAlloc(EMSpoint_info);
      end_point->type = EMSdatainfo_event;
      end_point->ptevent = &ME.ECfilletsf1->endpts[1];
    }

    start_radius = MyStackAlloc(EMSvalue_info);
    if (ME.ECfilletsf1->get_rad1 == TRUE)
    {
      start_radius->type = EMSdatainfo_event;
      start_radius->valevent = &ME.ECfilletsf1->rad1_ev;
    }
    else
    {
      start_radius->type = EMSdatainfo_numeric;
      start_radius->val = ME.ECfilletsf1->radius1;
    }

    end_radius = MyStackAlloc(EMSvalue_info);
    if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE &&
	ME.ECfilletsf1->closed == TRUE)
      memcpy(end_radius, start_radius, sizeof(struct EMSvalue_info));
    else
    {
      if (ME.ECfilletsf1->get_rad2 == TRUE)
      {
	end_radius->type = EMSdatainfo_event;
	end_radius->valevent = &ME.ECfilletsf1->rad2_ev;
      }
      else
      {
	end_radius->type = EMSdatainfo_numeric;
	end_radius->val = ME.ECfilletsf1->radius2;
      }
    }

    if (ME.ECfilletsf1->equal_radii == TRUE &&
	ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
    {
      mm_radius = MyStackAlloc(EMSvalue_info);
      if (ME.ECfilletsf1->get_maxmin_rad == TRUE)
      {
	mm_radius->type = EMSdatainfo_event;
	mm_radius->valevent = &ME.ECfilletsf1->maxmin_rad_ev;
      }
      else
      {
	mm_radius->type = EMSdatainfo_numeric;
	mm_radius->val = ME.ECfilletsf1->maxmin_radius;
      }
    }
    
    if (ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
    {
      law_curve = MyStackAlloc(EMSobject_info);
      if (ME.ECfilletsf1->sub_type == SF1_SF2_EDGE)
      {
	memcpy(&law_curve->grid, &elems[1].located_obj, sizeof(struct GRid));
	memcpy(&law_curve->env, &elems[1].module_info,
	       sizeof(struct GRmd_env));
      }
      else
      {
	memcpy(&law_curve->grid, &elems[2].located_obj, sizeof(struct GRid));
	memcpy(&law_curve->env, &elems[2].module_info,
	       sizeof(struct GRmd_env));
      }
    }

    ext_distance = MyStackAlloc(EMSvalue_info);
    ext_distance->type = EMSdatainfo_numeric;
    ext_distance->val = ME.ECfilletsf1->ext_opt ?
                        ME.ECfilletsf1->ext_radius_ratio : 0.0;
    break;

  case SF_SF_CV:
  case SF_SF_SF:
    /* erase display of surface normals and set fillet type */
    if (ME.ECfilletsf1->fill_type == SF_SF_CV)
    {
      EFdisplay_surface_normal(&elems[1], orient[0], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      EFdisplay_surface_normal(&elems[2], orient[1], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      fillet_type = 5;
    }
    else
    {
      EFdisplay_surface_normal(&elems[0], orient[0], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      EFdisplay_surface_normal(&elems[1], orient[1], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      EFdisplay_surface_normal(&elems[2], orient[2], my_id, FALSE,
			       &me->active_md_env, &me->active_display,
			       &loc_msg);
      fillet_type = 7;
    }

    /* redraw located objects in background */
    gr$display_object(object_id = &elems[0].located_obj,
		      mode = GRbdhe);
    gr$display_object(object_id = &elems[1].located_obj,
		      mode = GRbdhe);
    gr$display_object(object_id = &elems[2].located_obj,
		      mode = GRbdhe);

    /* initialize */
    element1 = MyStackAlloc(EMSobject_info);
    memcpy(&element1->grid, &elems[0].located_obj, sizeof(struct GRid));
    memcpy(&element1->env, &elems[0].module_info, sizeof(struct GRmd_env));
    
    element2 = MyStackAlloc(EMSobject_info);
    memcpy(&element2->grid, &elems[1].located_obj, sizeof(struct GRid));
    memcpy(&element2->env, &elems[1].module_info, sizeof(struct GRmd_env));
    
    element3 = MyStackAlloc(EMSobject_info);
    memcpy(&element3->grid, &elems[2].located_obj, sizeof(struct GRid));
    memcpy(&element3->env, &elems[2].module_info, sizeof(struct GRmd_env));

    normal1 = orient[0];
    normal2 = orient[1];
    if (ME.ECfilletsf1->fill_type == SF_SF_SF)
    {
      normal3 = orient[2];

      ext_distance = MyStackAlloc(EMSvalue_info);
      ext_distance->type = EMSdatainfo_numeric;
      ext_distance->val = ME.ECfilletsf1->ext_opt ?
	                  ME.ECfilletsf1->ext_distance : 0.0;
    }
    
    break;

  case SF_CV_RAD:
    /* erase display of curve indicator and surface normal */
    EMdisplay_curve_ind(&loc_msg, &elems[1], NULL, &elems[0], NULL, NULL,
			&me->active_display, &elems[1].module_info,
			GRhe, orient[0]);
    EFdisplay_surface_normal(&elems[1], orient[1], my_id, FALSE,
			     &me->active_md_env, &me->active_display,
			     &loc_msg);

    /* redraw curve and surface in background */
    gr$display_object(object_id = &elems[0].located_obj,
		      mode = GRbdhe);
    gr$display_object(object_id = &elems[1].located_obj,
		      mode = GRbdhe);

    fillet_type = 6;

    element1 = MyStackAlloc(EMSobject_info);
    memcpy(&element1->grid, &elems[0].located_obj, sizeof(struct GRid));
    memcpy(&element1->env, &elems[0].module_info, sizeof(struct GRmd_env));

    element2 = MyStackAlloc(EMSobject_info);
    memcpy(&element2->grid, &elems[1].located_obj, sizeof(struct GRid));
    memcpy(&element2->env, &elems[1].module_info, sizeof(struct GRmd_env));

    normal1 = orient[0] ? FALSE : TRUE;
    normal2 = orient[1];

    start_radius = MyStackAlloc(EMSvalue_info);
    if (ME.ECfilletsf1->get_rad == TRUE)
    {
      start_radius->type = EMSdatainfo_event;
      start_radius->valevent = &ME.ECfilletsf1->rad_ev;
    }
    else
    {
      start_radius->type = EMSdatainfo_numeric;
      start_radius->val = ME.ECfilletsf1->radius;
    }
  }

  if (normal1)
    fillet_opts |= EMS_FIL_NATURAL_NORMAL1;
  if (normal2)
    fillet_opts |= EMS_FIL_NATURAL_NORMAL2;
  if (normal3)
    fillet_opts |= EMS_FIL_NATURAL_NORMAL3;

  fillet_opts |= EMS_FIL_BOUND_SURF;

  if (ME.ECfilletsf1->int_opt == ROLLING_BALL)
    fillet_opts |= EMS_FIL_INT_ROLLING_BALL;

  if (ME.ECfilletsf1->equal_radii == TRUE)
    fillet_opts |= EMS_FIL_EQUAL_END_RADII;
  
  is_chamfer = ME.ECfilletsf1->prof_type == CHAMFER ||
               fabs(ME.ECfilletsf1->rho_value) <= tolr;

  /*
  fillet_opts |= fabs(ME.ECfilletsf1->rho_value - default_rho) <= tolr ?
                 EMS_FIL_DEFAULT_RHO : NULL;
  */

  if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2 &&
      ME.ECfilletsf1->sub_type == SF1_SF2_EDGE &&
      ME.ECfilletsf1->closed == FALSE &&
      ME.ECfilletsf1->vrad_type == ARBITRARY_RAD)
  {
    if (ME.ECfilletsf1->which_point)
      fillet_opts |= EMS_FIL_FLIP_EDGE_ENDS;
  }
  
  rho_value = MyStackAlloc(EMSvalue_info);
  rho_value->type = EMSdatainfo_numeric;
  rho_value->val = ME.ECfilletsf1->rho_value;

  sts = EMplace_fillet1(&loc_msg,
			assoc_placement ? NULL : EMSasconst_notassociative,
			fillet_type,
			fillet_opts,
			&ME.ECelements->active_md_env,
			ME.ECelements->active_level,
			&ME.ECelements->active_display,
			NULL,
			NULL,
			element1,
			element2,
			element3,
			start_radius,
			end_radius,
			mm_radius,
			start_point,
			end_point,
			ext_distance,
			law_curve,
			rho_value,
			is_chamfer,
			ME.ECfilletsf1->reverse,
			ME.ECfilletsf1->ctrline_cv,
			ME.ECfilletsf1->ctrline_type,
			&ME.ECfilletsf1->fillet_GRid.objid);
  if (!(1 & sts & loc_msg))
  {
    if (loc_msg == EMS_Fil_NeutralEdge)
    {
      ex$message(buff = msg1, msgnumb = EMS_S_NotCrFillSrf);
      strcat(msg1, " - ");
      ex$message(buff = msg2, msgnumb = EMS_I_NeutEdgeLoc);
      strcat(msg1, msg2);
      ex$message(field = ERROR_FIELD, in_buff = msg1);
    }
    else
      ex$message(field = ERROR_FIELD, msgnumb = EMS_S_NotCrFillSrf);
    *msg = loc_msg;
    sts = OM_E_ABORT;
    goto quit;
  }

  /*
   * Display constructed fillet surface
   */
  ME.ECfilletsf1->fillet_GRid.osnum = me->active_md_env.md_id.osnum;
  gr$display_object(object_id = &ME.ECfilletsf1->fillet_GRid,
		    mode = GRbd);

  ME.ECfilletsf1->fillet_constructed = TRUE;
  ME.ECfilletsf1->undo_fillet = FALSE;
  *msg = MSSUCC;

 quit:
  if (ME.ECfilletsf1->fill_type == SF_SF_R1_R2 &&
      ME.ECfilletsf1->sub_type != SF1_SF2_EDGE)
  {
    if (ME.ECfilletsf1->ctrline_cv)
    {
      BSfreecv(&loc_msg, ME.ECfilletsf1->ctrline_cv);
      ME.ECfilletsf1->ctrline_cv = NULL;
    }
  }
  
  if (EMSerror(sts))
    return OM_E_ABORT;
  else
    return OM_S_SUCCESS;
}


/*
 * DESCRIPTION
 *
 *     Standard interface function for form processing.
 *
 * OPTION
 *
 *     No option supported.
 *
 * ALGORITHM
 *
 *     None.
 */

void ECfilletsf1_process_fm(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
  GRobjid cmd_obj;
  GRspacenum cmd_os;
  IGRlong sts = OM_S_SUCCESS, msg;

  sts = FIf_get_cmd_oid_os(form_ptr, &cmd_obj, &cmd_os);
  EMerr_hndlr(sts != FI_SUCCESS, sts, OM_E_ABORT, quit);
  
  sts = om$send(msg = message ECfilletsf1.do_form(&msg,
						  form_label,
						  gadget_label,
						  value),
		senderid = NULL_OBJID,
		targetid = cmd_obj,
		targetos = cmd_os);
  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

 quit:
  return;
}

/*
 * DESCRIPTION
 *
 *     This function serves as the action handler when locating elements.
 *     The purpose is to disable certain nonapplicable gadgets on status form.
 *
 * OPTION
 *
 *     No option supported.
 *
 * ALGORITHM
 *
 *     None.
 */

#argsused
EMfilletsf_action_handler(my_args, entry, locate_args, action)
struct my_action_handler *my_args;
struct GRlc_info *entry;
struct LC_action_args *locate_args;
enum GRlocate_action *action;
{
  IGRlong sts = OM_S_SUCCESS;
  extern IGRlong LCptlocact();

  /*
  if (my_args->fill_type != SF_SF_RAD)
    FIg_disable(my_args->form_ptr, INTERIOR_CUSPS);
  if (my_args->fill_type == SF_SF_R1_R2)
    FIg_disable(my_args->form_ptr, VAR_RAD_TYPE);
  if (my_args->fill_type == SF_SF_CV || my_args->fill_type == SF_CV_RAD)
  {
    FIg_disable(my_args->form_ptr, FILLET_ENDS);
    if (my_args->state)
    {
      FIg_disable(my_args->form_ptr, EXT_DISTANCE);
      FIg_disable(my_args->form_ptr, DISTANCE_TEXT);
      FIg_disable(my_args->form_ptr, EXT_RADIUS_RATIO);
      FIg_disable(my_args->form_ptr, RADIUS_RATIO_TEXT);
    }
  }
  */
  sts = LCptlocact(NULL, entry, locate_args, action);

  return sts;
}

end implementation ECfilletsf1;
