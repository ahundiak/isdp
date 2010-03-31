/*

Name
  ECeditdim.execute

Abstract
  Command object for the Edit Dimensional Value command.
  
Synopsis

Description

Return Value

Notes

Index

Keywords

History
 ???????? :     ???       : Created
 04/31/93 : Jack Curtin   : Initialized display_info.osnum to OM_Gw_current_OS to 
                            fix uninitialized memory read flagged by Purify.
 06/09/93 : Rajiv Agrawal : Removed checking class of the located element to find out
                            the type of the dimension.
 09/24/93 : Rajiv Agrawal : Allow user to accept with a dimension value. (CR#11912612)

 11/05/93 : Satya         : Even TEXT_WITH_LEADER(with value_type == DIM_ANGLE)
			    is treated as an angular dimension. TR# 119307898
 11/05/93 : HGB		  : Don't try to support keyin of expressions, just get
                            the value (119311450)
 */
class implementation ECeditdim;

#include <values.h>
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "dimdload.h"
#include "dimdef.h"
#include "dim.h"
#include "dimmacros.h"
#include "dimplcmacros.h"
#include "DIglob.h" 
#include "DIprims.h"
#include "SKdef.h"
#include "EMSasprops.h"
#include "EMSasmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

static void post_temp_value();

#define GET_DIM		0
#define GET_DIM_VALUE	1
#define PROCESS		2

extern GRclassid OPP_GRvg_class_id;
extern GRclassid OPP_SKexplicit_class_id, OPP_EMSlndmcnstr_class_id;

from expression 	import modify, list, give_formula, NDgive_value;
from NDnode             import NDget_objects;
from DMroot 		import replace_text, return_dim_go, get_dim_type;
from DMtext 		import make_text_string;
from DMdim 		import get_active_params;
from GRgraphics 	import GRdisplay;
from GRowner 		import GRget_components;
from EMScnstr 		import EMgetprops;
from EMSparamvl 	import EMputval;
from SKconstraint 	import SKgetprops;
from SKexplicit 	import SKputval;

method execute ( int *response; char *response_data; int pos )
{
  IGRboolean         units_convert, defer_update;
  short		     dim_type;
  char               locate_prompt [GR_MAX_CHAR], accept_prompt [GR_MAX_CHAR];
  char               relocate_prompt [GR_MAX_CHAR], valuetype [GR_MAX_CHAR];
  char		     expr_formula[DI_PATH_MAX];
  unsigned short     props;
  int                eventsize, display_flag, count, mode;
  int 	             NumberOfParents = 0;
  long               eventmask, locate_mask, accept_mask, msg_loc, stat_OM;
  double             raw_value, value, oldang, tol;
  GRclassid          eliclass [2], eleclass;
  struct GRevent     *p_event, event, accept_event;
  struct GRlc_locate attributes;
  struct GRid        eleid, dimid, *locid;
  struct GRmd_env    *env;
  enum GRdpmode      dpmode;
  OM_S_CLASSLIST     elig_classes, rtree_classes;
  struct	DMsenv_param	par_senv;
  IGRint	status;
  IGRboolean aflag = 0;

  extern IGRlong RFlocate_ref_plane_handler();

  aflag = pwIsActivationOn();

  stat_OM = OM_S_SUCCESS;
  
  ex$message ( msgnumb = EM_M_EditDimensionalValue);

  eventsize = sizeof (struct GRevent);

  do
  {
    switch (ME.super_cmd->state)
    {
    case GET_DIM:
      dp$erase_hilite (msg = &msg_loc);
      ex$message (msgnumb = EMS_S_ClearStatusField);
      display_flag = ALL_WINDOWS | ELEM_HILIGHT;
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
      accept_mask = GRm_DATA | GRm_TEXT_VALUE;
      ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyDimension);
      ex$message ( buff = accept_prompt, msgnumb = EMS_P_KeyinDimensionValueReject);
      ex$message ( buff = relocate_prompt, msgnumb = EMS_S_DimensionNotFound);
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
          LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_HANDLES;

      elig_classes.w_count = 2;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = eliclass;
      eliclass[0] = OPP_SKexplicit_class_id;
      eliclass[1] = OPP_EMSexpcnstr_class_id;

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &OPP_GRvg_class_id;

      if (aflag)
      {
        GRspacenum osn;
        osn = pwGetActiveOs();
       
        lc$locate (rc = &msg_loc,
          event1 = &me->locate_event,
          event2 = &accept_event,
          mask1 = locate_mask, 
          mask2 = accept_mask,
          eventsize= &eventsize, 
          display_flag = display_flag,
          response = response, 
          response_data = response_data, 
          locate_prompt = locate_prompt, 
          acc_prompt = accept_prompt,
          relocate_prompt = relocate_prompt, 
          attributes = &attributes, 
          stack = &me->locate_stack, 
          eligible_classes = &elig_classes,
          rtree_classes = &rtree_classes,
          act_handler = RFlocate_ref_plane_handler,
          act_args = &osn);
      }
      else
      {
      lc$locate (rc = &msg_loc,
          event1 = &me->locate_event,
          event2 = &accept_event,
          mask1 = locate_mask, 
          mask2 = accept_mask,
          eventsize= &eventsize, 
          display_flag = display_flag,
          response = response, 
          response_data = response_data, 
          locate_prompt = locate_prompt, 
          acc_prompt = accept_prompt,
          relocate_prompt = relocate_prompt, 
          attributes = &attributes, 
          stack = &me->locate_stack, 
          eligible_classes = &elig_classes,
          rtree_classes = &rtree_classes);
      }

      if (msg_loc == LC_NO_OBJ_LOCATED)
        goto ret_end;

      me->ele_info = accept_event.located_object[0];
      eleid = me->ele_info.located_obj;
      env = &ME.ECeditdim->ele_info.module_info;

      /*
       * If the dimension has parents then one cannot use this command
       * to modify the value since the syntax will be lost and the design
       * intent as well. Per EMS steering commitee January 1993. Henry.
       */
      om$send ( msg = message NDnode.NDget_objects ( ND_ROOT, NULL, 0, NULL,
                      0, 0, &NumberOfParents ),
                targetid = eleid.objid, targetos = eleid.osnum );
      
      /*
       * Dimensions are connected to the DMsrc and the DMplan
       */
      om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
        p_classid = &eleclass);
      if (om$is_ancestry_valid (superclassid = OPP_EMSlndmcnstr_class_id,
            subclassid = eleclass) == OM_S_SUCCESS)
        NumberOfParents -= 2;

      if (NumberOfParents)
      {
        ex$message ( msgnumb = EMS_I_DimNotEditable );
        sleep ( 2 );
      }
      else
      {
        if (om$is_ancestry_valid (superclassid = OPP_SKexplicit_class_id,
            subclassid = eleclass) == OM_S_SUCCESS)
        {
          stat_OM = om$send (msg = message SKconstraint.SKgetprops (&msg_loc,
                                   &props), 
                             targetid = eleid.objid,
                             targetos = eleid.osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
              ret_end);

          if (props & SK_NOVALUE)
          {
            ex$message ( msgnumb = EMS_S_DimNotEditable);
            sleep ( 2 );
            break;
          }
          ME.ECeditdim->is_vg = TRUE;
        }
        else
          ME.ECeditdim->is_vg = FALSE;
        /*
         * Find the type of the dimension i.e. whether linear or angular.
         */
        ME.ECeditdim->is_angle = FALSE;
        stat_OM = om$send ( msg = message GRowner.GRget_components
                                  (&msg_loc, env, &dimid, 1, &count, 0, OM_K_MAXINT),
                            targetos = eleid.osnum, 
                            targetid = eleid.objid );
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
        if (count) 
        {
          stat_OM = om$send (msg = message DMroot.get_dim_type (&dim_type),
                             targetid = dimid.objid,
                             targetos = dimid.osnum);
          EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end );


	  /**  treat TEXT_WITH_LEADER dimension with value_type DIM_ANGLE 
	       also an an angular entity ****/
          status = dm$get_dim_param(type = DM_SENV_PARAM,
          			    dim_objid = dimid.objid,
          			    dim_osnum = dimid.osnum,
          			    p_data = (char *)&par_senv);
          EMerr_hndlr (EMSerror (status), status, OM_E_ABORT, ret_end );
          if (dim_type == STACKED_ANGULAR || dim_type == STRINGED_ANGULAR ||
              dim_type == SINGLE_ARC_ANGLE || (dim_type == TEXT_WITH_LEADER &&
	      par_senv.value_type == DIM_ANGLE))
            ME.ECeditdim->is_angle = TRUE;
        }
        
        if (*response == EX_STRING)
        {
          ex$putque ( msg = &msg_loc, response = response,
                      byte = (long *) &eventsize, 
                      buffer = (char *) &accept_event.event );
        }
        else
        {
          /*
           * Display the expression in the status field.
           */
          expr_formula [0] = NULL;
          om$send ( msg = message expression.list ( expr_formula ),
                    targetid = eleid.objid, targetos = eleid.osnum );
          UI_status ( expr_formula );
        }
        ME.super_cmd->state = GET_DIM_VALUE;
      }
      break;

    case GET_DIM_VALUE:
      if (ME.ECeditdim->is_angle)
        strcpy (valuetype, GRIO_ANGLE);
      else
        strcpy (valuetype, GRIO_DISTANCE);
      eventmask = GRm_VALUE | GRm_BACK_UP;
      
      if (*response != EX_STRING)
        ex$message ( msgnumb = EMS_P_KeyinDimensionValue);

      event.event.value = 0.0;
      stat_OM = ems$getevent (msg = &msg_loc, event_mask = eventmask,
                              value_type = valuetype, event = &event,
                              response = (long *) response, 
                              response_data = response_data);
      EMerr_hndlr (!stat_OM, stat_OM, OM_E_ABORT, ret_end);
      if (msg_loc == GRw_no_value)
        event.response = EX_RJT_MOVEON;

      switch (event.response)
      {
        case EX_VALUE:
          me->dimval_event = event;
          ME.super_cmd->state = PROCESS;
          break;
  
        case EX_BACK_UP:
          ME.super_cmd->state = GET_DIM;
          break;
  
        default:
          goto ret_end;
      }
      break;

    case PROCESS:
      dp$erase_hilite (msg = &msg_loc);
      
      eleid = ME.ECeditdim->ele_info.located_obj;
      env = &ME.ECeditdim->ele_info.module_info;
      raw_value = value = ME.ECeditdim->dimval_event.event.value;

      SKgettol (ME.ECeditdim->is_angle ? NULL : &tol, 
                ME.ECeditdim->is_angle ? &tol : NULL);
      if (value <= tol)
      {
        ex$message ( msgnumb = EMS_S_ValueLessThanTol);
        ME.super_cmd->state = GET_DIM_VALUE;
        break;
      }
      else if (ME.ECeditdim->is_angle)
      {
        oldang = 0.0;
        om$send (msg = message expression.NDgive_value (&oldang),
                 targetid = eleid.objid, targetos = eleid.osnum);

        value *= (180.0 / M_PI);

        if ((oldang > 180.0 && value < 180.0) ||
            (oldang < 180.0 && value > 180.0))
        {
          ex$message ( msgnumb = EMS_S_AngleChangesConvexity);
          ME.super_cmd->state = GET_DIM_VALUE;
          break;
        }
      }

      defer_update = FALSE;
      nd$mod_batch (request = ND_GET, p_ret_mode = &mode);
      if (mode == ND_DEFER)
      {
        struct GRid display_info;
        
        stat_OM = om$send (msg = message GRowner.GRget_components 
                                 (&msg_loc, env, &dimid, 1, &count, 0, OM_K_MAXINT),
                           targetid = eleid.objid, 
                           targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

        stat_OM = om$send (msg = message DMroot.get_dim_type (&dim_type),
                           targetid = dimid.objid, 
                           targetos = dimid.osnum);
        EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);
                   
        if (! ((1 << dim_type) & ANNOTATION_MASK))
        {
            dpmode = GRbehe;
            display_info.osnum = OM_Gw_current_OS; 
            display_info.objid = NULL_OBJID;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
                &env->md_env.matrix_type, env->md_env.matrix, 
                &dpmode, &display_info ),
                targetid = eleid.objid, targetos = eleid.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                ret_end);

            post_temp_value (dim_type, raw_value, &dimid, env);
 
            dpmode = GRbd;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
                &env->md_env.matrix_type, env->md_env.matrix, 
                &dpmode, &display_info),
                targetid = eleid.objid, targetos = eleid.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                ret_end);
        }
        else 
          defer_update = TRUE;
      }

      p_event = &ME.ECeditdim->dimval_event;
      if (p_event->subtype == GRst_v_SYNTAX ||
          p_event->subtype == GRst_v_NEWEXPR)
      {
        locid = &p_event->located_object[0].located_obj;
        if (p_event->subtype == GRst_v_NEWEXPR)
        {
          om$send (msg = message Root.delete (TRUE),
                   targetid = locid->objid, targetos = locid->osnum);
          ex$message ( msgnumb = EMS_S_NameExpIgnored);
        }
      }
      
      props = NULL;
      units_convert = FALSE;
      if (ME.ECeditdim->is_vg)
      {
        om$send (msg = message SKconstraint.SKgetprops (&msg_loc,
            &props), targetid = eleid.objid, targetos = eleid.osnum);
        if (props & SK_UNITSCONVERT)
          units_convert = TRUE;
      }
      else
      {
        om$send (msg = message EMScnstr.EMgetprops (&msg_loc,
            &props), targetid = eleid.objid, targetos = eleid.osnum);
        if (props & EMScnstr_convert_units)
          units_convert = TRUE;
      }

      if (units_convert)
        EMcnvt_db_dim_units (&msg_loc, &eleid, &value,
            ME.ECeditdim->is_angle ? GRIO_ANGLE : GRIO_DISTANCE, FALSE);

      if (ME.ECeditdim->is_vg)
        stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc,
            SK_OPT_SAVE_OLD_VALUE, value, NULL ),
            targetid = eleid.objid, targetos = eleid.osnum);
      else
        stat_OM = om$send (msg = message EMSparamvl.EMputval (&msg_loc,
            NULL, value, NULL ),
            targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
          ret_end);
      DIupdate_form ();

      if (defer_update)
        dm$set_type (type = DIM_INTERMEDIATE, update = TRUE,
            md_env = env, dim_grid = &dimid);
  
      ME.super_cmd->state = GET_DIM;
      break;

    default:
      stat_OM = OM_E_ABORT;
      goto ret_end;
    }
  }  while (TRUE);

ret_end:
  dp$erase_hilite (msg = &msg_loc);
      
  if (EMSerror (stat_OM))
    *response = TERMINATE;

  return stat_OM;
}


/*
  DESCRIPTION

    Function used to post a temporary text value into the dimension.
    This text will be replaced by the actual read-out on re-compute

  HISTORY

    Poovanan : 02/24/92 : Creation
*/

static void post_temp_value (dim_type, dim_value, dim_grid, md_env)
IGRshort dim_type;
double dim_value;
struct GRid *dim_grid;
struct GRmd_env *md_env;
{
  IGRlong msg_loc;
  struct DMenv_param par_env;
  struct DMloc_param par_loc;
  struct DMmisc_param par_misc;
  struct GRid txtid;

  om$send (msg = message DMdim.get_active_params (
	(int *) &msg_loc,
	&par_env,
	&par_loc),
	senderid = NULL_OBJID,
	targetid = dim_grid->objid,
	targetos = dim_grid->osnum);

  dm$get_dim_param(
	type = DM_MISC_PARAM,
	dim_objid = dim_grid->objid,
	dim_osnum = dim_grid->osnum,
	p_data = &par_misc);

  txtid.objid = NULL_OBJID;
  om$send (msg = message DMroot.return_dim_go (
	(int *) &msg_loc,
	DIM_TEXT,
	TRUE,
	DM_TEXT,
	md_env,
	&txtid),
	senderid = NULL_OBJID,
	targetid = dim_grid->objid,
	targetos = dim_grid->osnum);

  if (dim_type == SYMMETRICAL_DIAMETER)
  {
    /*
     * The user has keyed in a value relative to the number
     * that is seen with the dimension. This number is, by definition,
     * twice the value that would be measured from the geometry that this
     * dimension sits on. The following message is coded with the idea
     * that dim_value is obtained from the geometry. In order to simulate
     * that value, we must halve the input dim_value.
     */

    dim_value /= 2.0;
  }
  om$send (msg = message DMtext.make_text_string(
	dim_value,
	dim_type,
	&par_loc,
	&par_env,
	&par_misc,
	md_env),
	senderid = NULL_OBJID,
	targetid = txtid.objid,
	targetos = txtid.osnum);

  dm$set_type (
	type = DIM_INTERMEDIATE,
	update = TRUE,
       	md_env = md_env,
        dim_grid = dim_grid);

  return;
}

end implementation ECeditdim;
