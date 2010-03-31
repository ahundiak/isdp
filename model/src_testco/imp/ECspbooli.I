/* ###################   APOGEE COMPILED   ################## */
class implementation ECspbool;

#include "EMS.h"
#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "EMSopt.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "EMSaction.h"                  /* Locate action handler */
#include "msmacros.h"   /* ex$message */
#include "EMStypedef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSsfintsort.h"
#include "emsbool.h"
#include "EMSsfparms.h"
#include "bserr.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_S.h"
#include "ma.h"
#include "matrlmx.h"
#include "marptsxfo.h"
#include "bsnorkts.h"
#include "bsmergecvnn.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"

/*
 ABSTRACT
          This command object supports the following funationalites

          o Trim a surface/solid to intersection
          o Extend a surface/solid to intersection
          o Special boolean difference
          o Special boolean union
          o Special boolean intersection

          The differnce among the regular boolean operations and 
          the corresponding special boolean operations is that user
          has the option to selectively perform an operation i.e., 
          the user can select the portions of operands to be used
          in the boolean operation.
          
 HISTORY
    NP	    7/24/92	Modified error check after "EMtrim_a_surface".
    Tapadia 5/26/92 	Modified for message sub system compliance
    RC      7/14/89     Creation Date
    Sudha   7/05/93     Modified for BSprototypes ansification
    scw    08/14/94     clarified sleep method
*/


#define DEBUG 1

#define  GROWTH_STATE              0
#define  GET_SELECTIVE_BOOL_TYPE   1
#define  GET_FIRST_OPERAND         2
#define  PREPARE_SF                3
#define  GET_SECOND_OPERAND        4
#define  GET_EXTENSION_MODE        5
#define  GET_SAVE_SIDE_SF          6
#define  GET_SAVE_SIDE_SF_PT       7
#define  GET_SAVE_SIDE_ACCEPT_PT   8
#define  PERFORM_SP_BOOLEAN        9

#define  TRIM_CMD               0
#define  TRIM_WITH_EXTEND_CMD   1
#define  SELECTIVE_BOOL_CMD     2
#define  SELECTIVE_DIFF_CMD     3
#define  SELECTIVE_UNION_CMD    4
#define  SELECTIVE_INT_CMD      5

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
            EMSmsgReport (error_number, error_message, FALSE)) \
            {\
              EMSmsgReport(OM_E_ABORT,"In ECspbool",FALSE); \
              goto wrapup; \
            }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }

#endif

#if DEBUG
#define BS_ERROR(error_number, error_message)\
 {\
     if (error_number != BSSUCC) \
     { \
        EMSmsgReport(EMS_E_BSerror,"In ECspbool",FALSE); \
        goto wrapup; \
      }\
 }
#else
#define BS_ERROR(error_number, error_message)\
 {\
  if (error_number != BSSUCC) goto wrapup;\
 }

#endif

extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id,
                OPP_EMSsurface_class_id, OPP_EMSprjcompsf_class_id,
                OPP_EMSsfsolid_class_id, OPP_EMSproject_class_id;

from GRgraphics import GRlnproject, GRdisplay;
from GRvg       import EMptatpr;
from EMSsurface import EMmk_nat_bdry, EMtrim_a_surface;
from EMSsubbs   import EMpartolbasis;
from EMSproject import EMget_params;
from EMSloopset import EMpt_location;

method wakeup(int pos)
{
  switch (ME.super_cmd->mytype)
  {
   case TRIM_CMD:
     ex$message(msgnumb = EM_M_TrimSurSolInt);
     break;

   case TRIM_WITH_EXTEND_CMD:
     ex$message(msgnumb = EM_M_ExtSurSolInt);
     break;

   case SELECTIVE_BOOL_CMD:
     ex$message(msgnumb = EM_M_CreSelSurSolBoo);
     break;

   case SELECTIVE_DIFF_CMD:
     ex$message(msgnumb = EM_M_CreSelSurSolDif);
     break;

   case SELECTIVE_UNION_CMD:
     ex$message(msgnumb = EM_M_CreSelSurSolUni);
     break;

   case SELECTIVE_INT_CMD:
     ex$message(msgnumb = EM_M_CreSelSurSolInt);
     break;
  }
  return(OM_S_SUCCESS);
}


method super_cmd.sleep(int pos)
{
  ex$message(msgnumb = EM_M_ClearMessageField);
  ex$message(msgnumb = EMS_S_ClearStatusField);
  ex$message(msgnumb = EMS_P_ClearPromptField);
  return(OM_S_SUCCESS);
}


method execute(int *response; char *response_data; int pos)
{
 OM_S_CHANSELECT        sf_ls_chan;
 OM_S_OBJECT_LINKAGE    ls_list;
 struct EMSaction_handler already_located;
 struct GRlc_locate     attributes;
 struct IGRline         boreline;
 struct GRmd_env        *sf_md_env = NULL;
 struct GRparms         sf_proj_parms;
 struct EMSpartolbasis  partolbasis;
 OM_S_CLASSLIST         rtree_classes, elig_classes;
 struct GRvg_construct  construct_list;
 struct GRid            *prj_sfs_GRid = NULL;
 struct EMsurface_params sf_params;
 struct IGRbsp_curve    *base_cv, *mrg_cv, *new_cv, *ecap_geom, ln_cv;
 struct EMSsortpt_info  *bad_pts_info = NULL;

 IGRpoint               pnt1, pnt2, *cap_pts, *ln_pts, line_pt;
 IGRdouble              t, sf_uv_pt[2], prj_vec[3], tr_mat[4][4], 
                        poles[6], knots[4], *cap_pars, *ln_pars,
                        bcap_dist, ecap_dist;

 IGRlong                sts = OM_S_SUCCESS, msg, save_msg, num_poles, rc, size;

 OMuint                 num_ls;
 IGRint                 display_flag, locate_mask, accept_mask,
                        object_was_located, i, num_prj_sfs, sfix, 
			num_pts, stat, num_bad_pts = 0;

 IGRshort               order;
 IGRushort      change_mask;
 enum EMSbooltype       bool_type;
 enum GRdpmode          DisplayMode = GRbehe;
 IGRboolean             world = TRUE, all_elements_solid, status, 
                        rational, copy_operand_B;
 GRobjid                sf_id = 0, cur_sf_id, *op2_elems = NULL;
 GRspacenum             sf_os, cur_sf_os;

 OMuword                rclass, eliclass, obj_class, op1_classid;

 IGRchar                locate_prompt[52], accept_prompt[52], 
                        relocate_prompt[52];
 IGRuchar       cur_weight;

extern void EFget_prj_sfs() , EFmake_curve_with_2pts() ;
 extern IGRlong    EFlocate_action_handler();
 extern IGRint     ECprepsurf();

 /* ***************************************************************** */

 size = sizeof(struct GRevent);

 do 
 {

  switch (ME.super_cmd->state)
  {
    case GROWTH_STATE:
     if(ME.super_cmd->mytype == SELECTIVE_BOOL_CMD)
      ME.super_cmd->state = GET_SELECTIVE_BOOL_TYPE;
     else
      ME.super_cmd->state = GET_FIRST_OPERAND;
     break;

    case GET_SELECTIVE_BOOL_TYPE:
      ex$message(msgnumb = EMS_P_BoolDifIntUni);
      accept_mask = GRm_STRING;
      sts = GRgetevent(&msg, &accept_mask, &size, &me->accept_event, 
                       response, response_data);
      ERROR(sts, msg, "GRgetevent error");

      if (me->accept_event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else
      {
       ME.super_cmd->state = GET_FIRST_OPERAND;
       if (toupper(me->accept_event.event.keyin[0]) == 'D')
       {
        ME.super_cmd->mytype = SELECTIVE_DIFF_CMD;
        ex$message(msgnumb = EM_M_CreSelSurSolDif);
       }
       else
       {
        if (toupper(me->accept_event.event.keyin[0]) == 'I')
        {
         ex$message(msgnumb = EM_M_CreSelSurSolInt);
         ME.super_cmd->mytype = SELECTIVE_INT_CMD;
        }
        else
        {
	     if (toupper(me->accept_event.event.keyin[0]) == 'U')
         {
           ex$message(msgnumb = EM_M_CreSelSurSolUni);
           ME.super_cmd->mytype = SELECTIVE_UNION_CMD;
         }
         else
           ME.super_cmd->state = GET_SELECTIVE_BOOL_TYPE;

        }
       }
      }     
     break;

    case GET_FIRST_OPERAND:

      sts = dp$erase_hilite (msg = &msg);
      ERROR (sts, msg, "dp$erase_hilite");

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;

      switch (ME.super_cmd->mytype)
      {
       case TRIM_CMD:
	ex$message(msgnumb = EMS_P_IdSurSolToBeTrimmed, 
		buff = locate_prompt);
	ex$message(msgnumb = EMS_P_AccWiDriSurSolRej, 
		buff = accept_prompt);
       break;

       case TRIM_WITH_EXTEND_CMD:
	ex$message(msgnumb = EMS_P_IdSurSolToBeExtended,  
		buff = locate_prompt);
	ex$message(msgnumb = EMS_P_AccWiDriSurSolRej, 
		buff = accept_prompt);
       break;

       case SELECTIVE_DIFF_CMD:
	ex$message(msgnumb = EMS_P_IdSurSolAreaPart, 
		buff = locate_prompt);
	ex$message(msgnumb = EMS_P_AccWiSurSolHoleRej, 
		buff = accept_prompt);
       break;

       case SELECTIVE_UNION_CMD:
       case SELECTIVE_INT_CMD:
	ex$message(msgnumb = EMS_P_00132, buff = locate_prompt);
	ex$message(msgnumb = EMS_P_AccWiSurSol2Rej,
		buff = accept_prompt);
       break;

      } /* switch (ME.super_cmd->mytype) */
      ex$message(msgnumb = EMS_I_SfSlNotLocated, buff = relocate_prompt); 
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
      attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
                                LC_NO_REF_HEADER | LC_REF_OBJECTS | 
                                LC_LOCALMOD; 

      strcpy(attributes.classes, "EMSsurface");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass = OPP_EMSsurface_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                event2 = &me->accept_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &size, 
                display_flag = display_flag, 
                unhilight_mode = (enum GRdpmode) GRhhd,
                response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      if (!object_was_located)
      {
        if (me->locate_event.response == EX_BACK_UP)
        {
         if ( ME.super_cmd->mytype == SELECTIVE_DIFF_CMD  ||
              ME.super_cmd->mytype == SELECTIVE_UNION_CMD ||
              ME.super_cmd->mytype == SELECTIVE_INT_CMD)
         {
          ex$message(msgnumb = EM_M_CreSelSurSolBoo);
          ME.super_cmd->state = GET_SELECTIVE_BOOL_TYPE;
         }
         else
          ME.super_cmd->state = GROWTH_STATE;
        }
        else
          return(OM_S_SUCCESS);
      }
      else
      {
       me->last_response = EX_DATA;
       me->located_obj_GRids[0] = 
              me->accept_event.located_object[0].located_obj;
       OM_BLOCK_MOVE (&me->accept_event.located_object[0].module_info,
          &me->located_obj_envs[0], sizeof (struct GRmd_env));
       me->num_located_objs = 1;

       ME.super_cmd->state = PREPARE_SF;
       
      }
      break;

    case PREPARE_SF:
      
      locate_mask = GRm_BACK_UP;
      change_mask = 0;

      stat = ECprepsurf (&msg, 
               &me->located_obj_envs[me->num_located_objs-1],
               &ME.COconst->ActiveDisplay, 
               me->located_obj_GRids[me->num_located_objs-1],
               &me->locate_event, locate_mask, response, response_data,
               &change_mask);
      ERROR(stat, msg, "ECprepsurf error");
 
      if (msg == EMS_I_NoResponse)
      {
       if (me->last_response == EX_BACK_UP)
        me->num_located_objs--;
      }
      else 
      {
       if (me->locate_event.response == EX_BACK_UP)
       {
        me->num_located_objs--;
       
        /*
         * Unhilight the last element of the second operand.
         */

        if (me->num_located_objs)
        {
         sts = om$send (msg = message GRgraphics.GRdisplay (&msg,
           &me->located_obj_envs[me->num_located_objs].md_env.matrix_type,
           me->located_obj_envs[me->num_located_objs].md_env.matrix,
           &DisplayMode, 
           &me->located_obj_envs[me->num_located_objs].md_id),
          targetid = me->located_obj_GRids[me->num_located_objs].objid,
          targetos = me->located_obj_GRids[me->num_located_objs].osnum);
         ERROR (sts, msg, "GRdisplay");

        } /* if (me->num_located_objs) */

       } /* if (me->locate_event.response == EX_BACK_UP) */

      } /* if (msg == EMS_I_NoResponse) */

      ME.super_cmd->state = me->num_located_objs ? 
                            GET_SECOND_OPERAND : GET_FIRST_OPERAND;

      if (me->last_response == EX_DATA && 
          ME.super_cmd->state == GET_SECOND_OPERAND)
      {
         *response = EX_DATA;
         sts = ex$putque(msg = &msg, response = response,
                         byte = &size, buffer = (char *)&me->accept_event.event);
         ERROR(sts, msg, "ex$putque error");
 
      }

      break;
      
    case GET_SECOND_OPERAND:

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                     LC_ERASE_LOC_ELEMENT;

      accept_mask = GRm_DATA;

      switch (ME.super_cmd->mytype)
      {
       case TRIM_CMD:
       case TRIM_WITH_EXTEND_CMD:
        if (me->num_located_objs == 1) 
	    ex$message(msgnumb = EMS_P_IdeDriSurSol, type = "%d", 
		var = `me->num_located_objs`, buff = locate_prompt)
        else
	    ex$message(msgnumb = EMS_P_IdeDriSurSolMove, type = "%d", 
		var = `me->num_located_objs`, buff = locate_prompt)
	ex$message(msgnumb = EMS_P_AccDriSurSolRejNo, type = "%d", 
		var = `me->num_located_objs + 1`, buff = accept_prompt)
	ex$message(msgnumb = EMS_P_SurfSolNotFound, type = "%d", 
		var = `me->num_located_objs`, buff = relocate_prompt)
       break;

       case SELECTIVE_DIFF_CMD:
        if (me->num_located_objs == 1)
	    ex$message(msgnumb = EMS_P_IdeSurSolHolePart, type = "%d", 
		var = `me->num_located_objs`, buff = locate_prompt)
        else
	    ex$message(msgnumb = EMS_P_IdeSurSolHolePartMove, type = "%d", 
		var = `me->num_located_objs`, buff = locate_prompt)
	ex$message(msgnumb = EMS_P_AccSurSolHoleRej, type = "%d", 
		var = `me->num_located_objs + 1`, buff = accept_prompt)
	ex$message(msgnumb = EMS_P_SurfSolNotFound, type = "%d", 
		var = `me->num_located_objs`, buff = relocate_prompt)
       break;

       case SELECTIVE_UNION_CMD:
       case SELECTIVE_INT_CMD:
        if (me->num_located_objs == 1)
	    ex$message(msgnumb = EMS_P_IdeSurSolNum, type = "%d", 
		var = `me->num_located_objs + 1`, buff = locate_prompt)
        else
	    ex$message(msgnumb = EMS_P_IdeSurSolNumMove, type = "%d", 
		var = `me->num_located_objs + 1`, buff = locate_prompt)
	ex$message(msgnumb = EMS_P_AccSurSolRej, type = "%d", 
		var = `me->num_located_objs + 2`, buff = accept_prompt)
	ex$message(msgnumb = EMS_P_SurfSolNotFound, type = "%d", 
		var = `me->num_located_objs + 1`, buff = relocate_prompt)
       break;

      } /* switch (ME.super_cmd->mytype) */

      if (me->num_located_objs > 1)
       locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      else     
       locate_mask = GRm_DATA | GRm_BACK_UP;

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
                              LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_LOCALMOD; 
      if (me->mytype == TRIM_WITH_EXTEND_CMD)
       attributes.owner_action |= LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
      strcpy(attributes.classes, "EMSsurface");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass = OPP_EMSsurface_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      already_located.next = NULL;
      already_located.option = 0;
      already_located.type = 1;
      already_located.num_objects = me->num_located_objs;
      already_located.objects.id = me->located_obj_GRids;

      lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                event2 = &me->accept_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &size, 
                display_flag = display_flag, 
                unhilight_mode = (enum GRdpmode) GRhhd,
                response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                act_handler = EFlocate_action_handler,
                act_args = &already_located,
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      if (!object_was_located)
      {
        if (me->locate_event.response == EX_BACK_UP)
        {
          ME.super_cmd->state = PREPARE_SF;
          me->last_response = EX_BACK_UP;
        }
        else if (me->locate_event.response == EX_RJT_MOVEON)
        {
         if (me->num_located_objs > 1)
         {
          me->num_sfs = 0;
          if (ME.super_cmd->mytype == TRIM_WITH_EXTEND_CMD)
            ME.super_cmd->state = GET_EXTENSION_MODE;
          else
            ME.super_cmd->state = GET_SAVE_SIDE_SF;
         }
        }
        return(OM_S_SUCCESS);
      }
      else
      {
       if ( (me->num_located_objs + 1) > 
                (om$dimension_of (varray = me->located_obj_GRids)) )
       {
        sts = om$vla_set_dimension (varray = me->located_obj_GRids,
                 size = me->num_located_objs + 5);

        sts = om$vla_set_dimension (varray = me->located_obj_envs,
                 size = me->num_located_objs + 5);

       }

       me->located_obj_GRids[me->num_located_objs] = 
              me->accept_event.located_object[0].located_obj;

       OM_BLOCK_MOVE (&me->accept_event.located_object[0].module_info,
          &me->located_obj_envs[me->num_located_objs], 
          sizeof (struct GRmd_env));

       me->num_located_objs++;
       me->last_response = EX_DATA;
       ME.super_cmd->state = PREPARE_SF;

      }
     break;

    case GET_EXTENSION_MODE:
    
      sts = dp$erase_hilite (msg = &msg);
      ERROR (sts, msg, "dp$erase_hilite");

      ex$message(msgnumb = EMS_P_IdEndToExtMoBoth);

      accept_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      sts = GRgetevent(&msg, &accept_mask, &size, &me->accept_event, 
                       response, response_data);
      ERROR(sts, msg, "GRgetevent error");

      if (me->accept_event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (me->accept_event.response == EX_BACK_UP)
      {
        me->num_located_objs--;
        ME.super_cmd->state = GET_SECOND_OPERAND;
      }
      else  /* MOVE_ON or data point */
      {
       /*
        * Get the bcap_geom and endcap_geom
        */

        sts = om$get_classid (objid = me->located_obj_GRids[0].objid,
                osnum = me->located_obj_GRids[0].osnum, 
                p_classid = &op1_classid);
        ERROR (sts, 1, "om$get_classid");

        if (op1_classid == OPP_EMSprjcompsf_class_id)
         me->extend_info.object_classid = OPP_EMSprjcompsf_class_id;
        else
        {
         if (op1_classid == OPP_EMSsfsolid_class_id)
          me->extend_info.object_classid = OPP_EMSsfsolid_class_id;
         else
          me->extend_info.object_classid = OPP_EMSproject_class_id; 
        }

        EFget_prj_sfs (&msg, me->located_obj_GRids[0].objid, 
                       &me->located_obj_envs[0], 
                       me->extend_info.object_classid, &num_prj_sfs,
                       &prj_sfs_GRid);
        ERROR (1, msg, "EFget_prj_sfs");

        for (sfix = 0; sfix < num_prj_sfs; sfix++)
        {
         sts = om$send (mode = OM_e_wrt_message,
                        msg = message EMSproject.EMget_params (&msg,
                         NULL, &me->located_obj_envs[0],NULL, &sf_params),
                        senderid = NULL_OBJID,
                        targetid = prj_sfs_GRid[sfix].objid,
                        targetos = prj_sfs_GRid[sfix].osnum);
         ERROR (sts, msg, "EMget_params");

         base_cv = &sf_params.params.project.curve;
         
         if (sfix == 0)
         {
          OM_BLOCK_MOVE (sf_params.params.project.axis_point0, 
                        me->extend_info.bcap_ref_pt, sizeof(IGRpoint));
          OM_BLOCK_MOVE (sf_params.params.project.axis_point1, 
                        me->extend_info.ecap_ref_pt, sizeof(IGRpoint));

          BSalloccv (base_cv->order, base_cv->num_poles, 
                     base_cv->rational, 0, &mrg_cv, &rc);
          BS_ERROR (rc, "BSalloccv");

          status = BScv_copy (&rc, base_cv, mrg_cv);
          BS_ERROR (rc, "BScv_copy");
         }    
         else
         {
          order = mrg_cv->order >= base_cv->order ? mrg_cv->order : 
                                                    base_cv->order;
          if (mrg_cv->order == base_cv->order)
            num_poles = mrg_cv->num_poles + base_cv->num_poles - 1;
          else if (mrg_cv->order > base_cv->order)
            num_poles = mrg_cv->num_poles + base_cv->num_poles +
                        ((base_cv->num_poles - base_cv->order + 2) *
                         (mrg_cv->order - base_cv->order));
          else
            num_poles = base_cv->num_poles + mrg_cv->num_poles +
                        ((mrg_cv->num_poles - mrg_cv->order + 2) *
                         (base_cv->order - mrg_cv->order));

          rational = mrg_cv->rational || base_cv->rational;

          BSalloccv(order, num_poles, rational, 0, &new_cv, &rc);
          BS_ERROR (rc, "BSalloccv");
          
          BSmergecvnn(mrg_cv, base_cv, new_cv, &rc);
          BS_ERROR (rc, "BSmergecvnn");

          status = BSfreecv(&rc, mrg_cv);
          BS_ERROR (rc, "BSfreecv");

          mrg_cv = new_cv;

         } /* else for if (sfix == 0) */

         if (base_cv->poles) om$dealloc (ptr = base_cv->poles);
         if (base_cv->knots) om$dealloc (ptr = base_cv->knots);
         if (base_cv->weights) om$dealloc (ptr = base_cv->weights);

        } /* for (sfix = 0; sfix < num_prj_sfs; sfix++) */
 
        if (prj_sfs_GRid) om$dealloc (ptr = prj_sfs_GRid);

        /*
         * Fix the end weights
         */

        if (mrg_cv->rational)
          BSchgcvewts (mrg_cv, mrg_cv, &rc);
          BS_ERROR (rc, "BSchgcvewts");

        /*
         * Reparameterize
         */

        status = BSnorkts (&rc, &mrg_cv->order, &mrg_cv->num_poles,
                           mrg_cv->knots);
        BS_ERROR (rc, "BSnorkts");

        me->extend_info.bcap_geom = mrg_cv;

        /*
         * Determine which end needs to be extended
         */

        if (me->accept_event.response == EX_DATA)
        {
         BSalloccv(mrg_cv->order, mrg_cv->num_poles, 
                   mrg_cv->rational, 0, &ecap_geom, &rc);
         BS_ERROR (rc, "BSalloccv");

         status = BScv_copy (&rc, mrg_cv, ecap_geom);
         BS_ERROR (rc, "BScv_copy");
        
         for (i = 0; i < 3; i++)
          prj_vec[i] = me->extend_info.ecap_ref_pt[i] - 
                       me->extend_info.bcap_ref_pt[i];

         MAtrlmx (&msg, prj_vec, &tr_mat[0][0]);
         ERROR (1, msg, "MAtrlmx");

        status = MArptsxform (&msg, &mrg_cv->num_poles, &mrg_cv->rational,
                              mrg_cv->weights, &tr_mat[0][0], mrg_cv->poles,
                              ecap_geom->poles);
        ERROR (1, msg, "MArptsxform");

        boreline.point1 = poles;
        boreline.point2 = &poles[3];
        EFboreline (&msg, my_id, &me->accept_event, &boreline);
        ERROR (1, msg, "EFboreline");

        EFmake_curve_with_2pts (&msg, &ln_cv, poles, knots);
        ERROR (1, msg, "EFmake_curve_with_2pts");

        BSmdistcvcv (mrg_cv, &ln_cv, &num_pts, &cap_pars, &ln_pars,
                          &cap_pts, &ln_pts, &bcap_dist, &rc);
        BS_ERROR (rc, "BSmdistcvcv");

         if (cap_pars) om$dealloc (ptr = cap_pars);
         if (ln_pars) om$dealloc (ptr = ln_pars);
         if (cap_pts) om$dealloc (ptr = cap_pts);
         if (ln_pts) om$dealloc (ptr = ln_pts);
         
        BSmdistcvcv (ecap_geom, &ln_cv, &num_pts, &cap_pars, &ln_pars,
                     &cap_pts, &ln_pts, &ecap_dist, &rc);
        BS_ERROR (rc, "BSmdistcvcv");

         if (cap_pars) om$dealloc (ptr = cap_pars);
         if (ln_pars) om$dealloc (ptr = ln_pars);
         if (cap_pts) om$dealloc (ptr = cap_pts);
         if (ln_pts) om$dealloc (ptr = ln_pts);
         
         me->extend_info.extension_type = bcap_dist < ecap_dist ?
                         EMSextend_begin_cap : EMSextend_end_cap;

         status = BSfreecv(&rc, ecap_geom);
         BS_ERROR (rc, "BSfreecv");
         
        } /* if (me->accept_event.response == EX_DATA) */

        else
          me->extend_info.extension_type = EMSextend_both_ends;

        ME.super_cmd->state = PERFORM_SP_BOOLEAN;

      } /* else  MOVE_ON or data point */

      break;


    case GET_SAVE_SIDE_SF:

      sts = dp$erase_hilite (msg = &msg);
      ERROR (sts, msg, "dp$erase_hilite");

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      accept_mask = GRm_DATA;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      ex$message(msgnumb = EMS_P_IdeSurfSolSave, type = "%d",
		var = `me->num_sfs + 1`, buff = locate_prompt);
      if (me->num_sfs)
      {
	IGRchar buff1[52];
	ex$message(msgnumb = EMS_P_Moveon, buff = buff1);
       	locate_mask |= GRm_RJT_MOVEON;
	strcat(locate_prompt, buff1);
      }
      else
        ex$message(msgnumb = EMS_P_AccWiPtInArea, buff = accept_prompt);  
      ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt); 
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                              LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_LOCALMOD; 
      strcpy(attributes.classes, "EMSsurface");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass = OPP_EMSsubbs_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                event2 = &me->accept_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

      if (!object_was_located)
      {
        if (me->locate_event.response == EX_BACK_UP)
        {
         if (me->num_sfs)
         {
          me->num_pts_this_sf = 0;
          cur_sf_id = me->sortpts_info[0].sf_id;
          cur_sf_os = me->sortpts_info[0].md_env.md_id.osnum;

          for (i = 0; i < me->num_pts; i++)
          {
            if (me->sortpts_info[i].sf_id == cur_sf_id   &&
                me->sortpts_info[i].md_env.md_id.osnum == cur_sf_os)
            {
             me->num_pts_this_sf++;
            }
            else
            {
              me->num_pts_this_sf = 1;
              cur_sf_id = me->sortpts_info[i].sf_id;
              cur_sf_os = me->sortpts_info[i].md_env.md_id.osnum;
            }
          } /* for (i = 0; me->num_pts; i++) */

           ME.super_cmd->state = GET_SAVE_SIDE_SF_PT;

         } /* if (me->num_sfs) */
         else
         {
           me->num_located_objs--;
           ME.super_cmd->state = GET_SECOND_OPERAND;
         }          

        } /* if (me->locate_event.response == EX_BACK_UP) */

        else if (me->locate_event.response == EX_RJT_MOVEON)
        {
          if (me->num_pts)
            ME.super_cmd->state = PERFORM_SP_BOOLEAN;
        }
        return(OM_S_SUCCESS);

      } /* if (!object_was_located) */
      else
      {

       if ((me->num_pts+1) > (om$dimension_of (varray=me->sortpts_info)))
       {
         sts = om$vla_set_dimension (varray = me->sortpts_info, 
                                     size = me->num_pts + 5);
         ERROR (sts, 1, "om$vla_set_dimension");
        
       }

       me->sortpts_info[me->num_pts].sf_id = 
              me->accept_event.located_object[0].located_obj.objid;

       OM_BLOCK_MOVE (&me->accept_event.located_object[0].module_info,
         &me->sortpts_info[me->num_pts].md_env, sizeof (struct GRmd_env));
       
       me->num_pts_this_sf = 0;
       me->num_sfs++;

       sts = ex$putque(msg = &msg, response = response,
                        byte = &size, buffer = (char *)&me->accept_event.event);
       ERROR(sts, msg, "ex$putque error");

       me->pt_on_que = TRUE;
       ME.super_cmd->state = GET_SAVE_SIDE_SF_PT;

      }

     break;


    case GET_SAVE_SIDE_SF_PT:
     
      if (!me->pt_on_que)
      {
	IGRchar inp_buff2[52];

	ex$message(msgnumb = EMS_P_InpPointNo, type = "%d",
		var = `me->num_pts_this_sf + 1`, buff = locate_prompt);
       	if (me->num_pts_this_sf) {
		ex$message(msgnumb = EMS_P_Moveon, buff = inp_buff2);
		strcat(locate_prompt, inp_buff2);
	}
	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
		in_buff = locate_prompt);
      }
      
      me->pt_on_que = FALSE;

      accept_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      sts = GRgetevent(&msg, &accept_mask, &size, &me->accept_event, 
                       response, response_data);
      ERROR(sts, msg, "GRgetevent error");

      if (me->accept_event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (me->accept_event.response == EX_BACK_UP)
      {
        if (!me->num_pts_this_sf)
        {
         ME.super_cmd->state = GET_SAVE_SIDE_SF;
         me->num_sfs--;
        }
        else
        {
         me->num_pts_this_sf--;
         me->num_pts--;
         cur_weight = ME.COconst->ActiveDisplay.weight;
         ME.COconst->ActiveDisplay.weight = 3;
         ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                  me->sortpts_info[me->num_pts].md_env, 
                  me->sortpts_info[me->num_pts].sf_id, 1, 
                  me->sortpts_info[me->num_pts].xyz_pt, FALSE);
         ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
         ME.COconst->ActiveDisplay.weight = cur_weight;
        }
      }
      else if (me->accept_event.response == EX_RJT_MOVEON)
      {
       if (me->num_pts_this_sf)
        ME.super_cmd->state = GET_SAVE_SIDE_SF;
       
      }
      else           /* data point */
      {
        boreline.point1 = pnt1;
        boreline.point2 = pnt2;
        EFboreline (&msg, my_id, &me->accept_event, &boreline);
        ERROR (1, msg, "EFboreline");
    
        if (me->num_pts_this_sf)
        {
         sf_md_env = &me->sortpts_info[me->num_pts-1].md_env;
         sf_id = me->sortpts_info[me->num_pts-1].sf_id;
         sf_os = sf_md_env->md_id.osnum;
        }
        else
        {
         sf_md_env = &me->sortpts_info[me->num_pts].md_env;
         sf_id = me->sortpts_info[me->num_pts].sf_id;
         sf_os = sf_md_env->md_id.osnum;
        }

        sts = om$send (msg = message GRgraphics.GRlnproject (&msg,
                        &sf_md_env->md_env.matrix_type,
                        sf_md_env->md_env.matrix, &boreline, line_pt,
                        me->sf_xyz_pt, &t, &sf_proj_parms),
                       targetid = sf_id,
                       targetos = sf_os);
        ERROR (sts, msg, "GRlnproject");

        sf_uv_pt[0] = sf_proj_parms.u;
        sf_uv_pt[1] = sf_proj_parms.v;

        partolbasis.in_world = TRUE;
        partolbasis.mattyp = &sf_md_env->md_env.matrix_type;
        partolbasis.mat = sf_md_env->md_env.matrix;

        sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                        &sf_md_env->md_env.matrix_type,
                        sf_md_env->md_env.matrix, &world, NULL,
                        (IGRdouble *)&partolbasis),
                       targetid = sf_id,
                       targetos = sf_os);
        ERROR (sts, msg, "EMSsubbs.EMpartolbasis");

        sts = om$make_chanselect (channame = "EMSsubbs.to_loopset",
                 p_chanselect = &sf_ls_chan);
        ERROR (sts, 1, "om$make_chanselect");

        sts = om$get_channel_objects (objid = sf_id, osnum = sf_os,
                 p_chanselect = &sf_ls_chan,
                 list = &ls_list, size = 1, count = &num_ls);
        ERROR (sts, 1, "om$get_channel_objects");

        if (!num_ls)
        {
         sts = om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg,
                         &sf_md_env->md_env, NULL),
                        targetid = sf_id, targetos = sf_os);
         ERROR (sts, msg, "EMSsurface.EMmk_nat_bdry");

         sts = om$get_channel_objects (objid = sf_id, osnum = sf_os,
                  p_chanselect = &sf_ls_chan,
                  list = &ls_list, size = 1, count = &num_ls);
         ERROR (sts, 1, "om$get_channel_objects");

        } /* if (!num_ls) */

        sts = om$send (msg = message EMSloopset.EMpt_location (&msg,
                      sf_uv_pt, &me->sortpts_info[me->num_pts].ptloc_info,
                      &partolbasis),
                    targetid = ls_list.S_objid, targetos = sf_os);
        ERROR (sts, msg, "EMSloopset.EMpt_location");

        /*
         * If point location does not return location as either on
         * edge or on vertex, replace the pt_location closest point
         * by sf_uv_pt as this is point shown to user for acceptance.
         */

        if ( (me->sortpts_info[me->num_pts].ptloc_info.location != 
                                         EMS_L_ONEDGE) &&
             (me->sortpts_info[me->num_pts].ptloc_info.location != 
                                         EMS_L_ONVRTX) )
         OM_BLOCK_MOVE ( sf_uv_pt, 
          me->sortpts_info[me->num_pts].ptloc_info.edge[0].nst_pt.proj_pt,
          sizeof(IGRdouble)*2);

        cur_weight = ME.COconst->ActiveDisplay.weight;
        ME.COconst->ActiveDisplay.weight = 3;
        ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                 *sf_md_env, sf_id, 1, me->sf_xyz_pt, TRUE);
        ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
        ME.COconst->ActiveDisplay.weight = cur_weight;
        me->pt_highlighted = TRUE;

        ME.super_cmd->state = GET_SAVE_SIDE_ACCEPT_PT;

      } /*                   data point */
      break;


    case GET_SAVE_SIDE_ACCEPT_PT:

        if (!me->pt_highlighted)
        {
         if (me->num_pts_this_sf)
         {
          sf_md_env = &me->sortpts_info[me->num_pts-1].md_env;
          sf_id = me->sortpts_info[me->num_pts-1].sf_id;
          sf_os = sf_md_env->md_id.osnum;
         }
         else
         {
          sf_md_env = &me->sortpts_info[me->num_pts].md_env;
          sf_id = me->sortpts_info[me->num_pts].sf_id;
          sf_os = sf_md_env->md_id.osnum;
         }

          cur_weight = ME.COconst->ActiveDisplay.weight;
          ME.COconst->ActiveDisplay.weight = 3;
          ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                   *sf_md_env, sf_id, 1, me->sf_xyz_pt, TRUE);
          ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
          ME.COconst->ActiveDisplay.weight = cur_weight;

        } /* if (!me->pt_highlighted) */

        if (me->num_pts_this_sf)
	 ex$message(msgnumb = EMS_P_AccNxtPtOnSurMov)
        else
	 ex$message(msgnumb = EMS_P_AccNxtPtOnSur)
                         
        accept_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
        sts = GRgetevent(&msg, &accept_mask, &size, &me->accept_event, 
                response, response_data);
        ERROR(sts, msg, "GRgetevent error");
/*
        ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                 *sf_md_env, sf_id, 1, me->sf_xyz_pt, FALSE);
        ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
*/
        me->pt_highlighted = FALSE;

        if (me->accept_event.response == GR_UNKNOWN_TYPE)
          return(OM_S_SUCCESS);
        else if (me->accept_event.response == EX_BACK_UP)
        {
         if (!me->num_pts_this_sf)
         {
          me->num_sfs--;
          ME.super_cmd->state = GET_SAVE_SIDE_SF;
         }
         else
         {
           me->num_pts_this_sf--;
           me->num_pts--;
           ME.super_cmd->state = GET_SAVE_SIDE_SF_PT;
           ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                  me->sortpts_info[me->num_pts].md_env, 
                  me->sortpts_info[me->num_pts].sf_id, 1, 
                  me->sortpts_info[me->num_pts].xyz_pt, FALSE);
           ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
         }

         ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                  *sf_md_env, sf_id, 1, me->sf_xyz_pt, FALSE);
         ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");

        }
        else if (me->accept_event.response == EX_RJT_MOVEON)
        {
         if (me->num_pts_this_sf)
          ME.super_cmd->state = GET_SAVE_SIDE_SF;
         else
          ME.super_cmd->state = GET_SAVE_SIDE_SF_PT;

         ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                  *sf_md_env, sf_id, 1, me->sf_xyz_pt, FALSE);
         ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
        }
        else            /* data point */
        {
         if (me->num_pts_this_sf)
         {
          me->sortpts_info[me->num_pts].sf_id = 
              me->sortpts_info[me->num_pts-1].sf_id;

          OM_BLOCK_MOVE (&me->sortpts_info[me->num_pts-1].md_env,
                         &me->sortpts_info[me->num_pts].md_env, 
                         sizeof (struct GRmd_env));

         } /* if (me->num_pts_this_sf) */
       
         OM_BLOCK_MOVE (me->sf_xyz_pt, 
               me->sortpts_info[me->num_pts].xyz_pt, sizeof(IGRpoint));
         me->num_pts++;
         me->num_pts_this_sf++;

         if ((me->num_pts+1) > (om$dimension_of(varray=me->sortpts_info)))
         {
           sts = om$vla_set_dimension (varray = me->sortpts_info, 
                                       size = me->num_pts + 5);
           ERROR (sts, 1, "om$vla_set_dimension");
        
         }

          sts = ex$putque(msg = &msg, response = response,
                         byte = &size, buffer = (char *)&me->accept_event.event);
          ERROR(sts, msg, "ex$putque error");
          me->pt_on_que = TRUE;
          ME.super_cmd->state = GET_SAVE_SIDE_SF_PT;
        }
        break;

    case PERFORM_SP_BOOLEAN:

     all_elements_solid = TRUE;
     for (i = 0; i < me->num_located_objs && all_elements_solid; i++)
     {
      sts = om$get_classid (objid = me->located_obj_GRids[i].objid,
               osnum = me->located_obj_GRids[i].osnum, 
               p_classid = &obj_class);
      ERROR (sts, 1, "om$get_classid");

      sts = om$is_ancestry_valid (subclassid = obj_class, 
                                  superclassid = OPP_EMSsolid_class_id);
      ERROR (sts, 1, "om$is_ancestry_valid");
    
      if (sts == OM_I_INVANCESTRY) all_elements_solid = FALSE;

     } /* for (i =0; i<me->num_located_objs && all_elements_solid;i++) */

     construct_list.msg = &msg;
     construct_list.env_info = me->located_obj_envs;
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.level = ME.COconst->ActiveLevel;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.display = &ME.COconst->ActiveDisplay;
     construct_list.name = NULL;

     if (ME.super_cmd->mytype == TRIM_CMD || 
         ME.super_cmd->mytype == SELECTIVE_DIFF_CMD ||
         ME.super_cmd->mytype == TRIM_WITH_EXTEND_CMD)
       bool_type = EMSbool_difference;
     else
     {
      if (ME.super_cmd->mytype == SELECTIVE_UNION_CMD)
        bool_type = EMSbool_union;
      else
       bool_type = EMSbool_intersect;
     }

     if (ME.super_cmd->mytype == TRIM_CMD  ||
         ME.super_cmd->mytype == TRIM_WITH_EXTEND_CMD)
      copy_operand_B = TRUE;
     else
      copy_operand_B = FALSE;

     op2_elems = (GRobjid *) om$malloc (size = (me->num_located_objs - 1) 
                                         * sizeof(GRobjid));
     for (i = 0; i < (me->num_located_objs - 1); i++)
      op2_elems[i] = me->located_obj_GRids[i+1].objid;

     cur_weight = ME.COconst->ActiveDisplay.weight;
     ME.COconst->ActiveDisplay.weight = 3;
     for (i = 0; i < me->num_pts; i++)
     {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
            me->sortpts_info[i].md_env, me->sortpts_info[i].sf_id, 
            1, me->sortpts_info[i].xyz_pt, FALSE);
      ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
      ME.COconst->ActiveDisplay.weight = cur_weight;

     } /* for (i = 0; i < num_pts; i++) */

     num_bad_pts = 0; /* assume at start */
     sts = om$send (msg = message EMSsurface.EMtrim_a_surface (     
                     &msg, me->located_obj_GRids[0].objid, 
                     &me->located_obj_envs[0], me->num_located_objs - 1,
                     op2_elems,
                     &me->located_obj_envs[1], &construct_list,
                     ME.super_cmd->mytype == TRIM_WITH_EXTEND_CMD ?
                      TRUE : FALSE, 
                     ME.super_cmd->mytype == TRIM_WITH_EXTEND_CMD ?
                      &me->extend_info : NULL,
                     copy_operand_B,                     
                     me->num_pts,
                     me->sortpts_info, bool_type, all_elements_solid,
                     &num_bad_pts, &bad_pts_info),
                    targetid = me->located_obj_GRids[0].objid,
                    targetos = me->located_obj_GRids[0].osnum);

     ex$message(msgnumb = EMS_S_ClearStatusField);

     /* since "msg" variable is re-used below, save it in a new variable
      * so that return code of "EMtrim_a_surface" can be checked after the 
      * "bad" pts are displayed.
      */
     save_msg = msg;

     if (num_bad_pts)
     {
      cur_weight = ME.COconst->ActiveDisplay.weight;
      ME.COconst->ActiveDisplay.weight = 3;

      for (i = 0; i < num_bad_pts; i++)
      {
        ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
            bad_pts_info[i].md_env, me->located_obj_GRids[0].objid, 
            1, bad_pts_info[i].xyz_pt, TRUE);
        ERROR(OM_S_SUCCESS, msg, "exec, dis_pt_set");
      } /* for (i = 0; i < num_bad_pts; i++) */

      ME.COconst->ActiveDisplay.weight = cur_weight;

      if (me->num_pts == num_bad_pts)
      {
	ex$message(msgnumb = EMS_E_OpFaNoValSelPts);
      }
      else
      {
	ex$message(msgnumb = EMS_S_InvalidSelPts);
      }

     } /* if (num_bad_pts) */
	
     /* check saved return code from "EMtrim_a_surface" */
     if (!(1&save_msg))
     {
      switch (save_msg)
      {
        case EMS_E_NoIntersection:
	 ex$message(msgnumb = EMS_E_OpFailedNoIntPos);
         break;

        case EMS_E_IntersectClosure: 
	 ex$message(msgnumb = EMS_E_OpFailedIntClo);
         break;

	case EMS_E_IntersectOrient:
	 ex$message(msgnumb = EMS_E_OpFailedInvSelPts);
	 break;
	
	case EMS_E_AllIntersectionsDeleted:
	 ex$message(msgnumb = EMS_E_OpFaNoValSelPts);
	 break;

        default:
	 ex$message(msgnumb = EMS_E_OperationFailed);
      } 

     }

     om$dealloc (ptr = op2_elems);
     if (bad_pts_info) 
     { om$dealloc (ptr = bad_pts_info);
       num_bad_pts = 0;
     }

     /* Commented out the following line -- SM 19 Feb 1992. ******/
     /* ERROR (OM_S_SUCCESS, msg, "EFtrim_a_surface"); */

     me->num_pts = 0;
     me->num_located_objs = 0;
     me->pt_highlighted = me->pt_on_que = FALSE;

     if (ME.super_cmd->state == TRIM_WITH_EXTEND_CMD)
     {
      if (me->extend_info.bcap_geom)
         status = BSfreecv(&rc, me->extend_info.bcap_geom);
         BS_ERROR (rc, "BSfreecv");
     }

     ME.super_cmd->state = GROWTH_STATE;
     /* ex$message(msgnumb = EMS_S_ClearStatusField); */
     break;

    default:
     ERROR (OM_E_ABORT, 0, "Default state reached");

  } /* switch (ME.super_cmd->state) */

 } while (TRUE);

 wrapup:
   *response = TERMINATE;
  return (sts);

} 

end implementation ECspbool;
