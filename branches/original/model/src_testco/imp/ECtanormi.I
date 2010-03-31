/* ###################   APOGEE COMPILED   ################## */
/*
ABSTRACT

This Command Object outputs the tangents and normals of an
element at a single or a set of points, specified or implied by
the user.

HISTORY

07/05/93    Sudha  Modified for BSprototypes ansification
05/25/92   Rustagi Modified for Message Sub-system Compliance

10/05/91    DLB Added & to event_size in lc$locate.
pp 10/02/89 Making graphics groups of the assorted lines representing
            tangents/normals when output to database option is
            selected.
22 May 1989 jBk Replaced GRm_STRING masks with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

15 May 1989 jBk Removed wakeup implementation.

dhm 2/28/89 : added ifndef's for the I/DRAW product.

dhm 2/24/89 : Changed to work for reference file objects and
              to use the active module environment for
              displays and constructs.

dhm 01/20/89 : Initialized const_list.msg and newflag field.

dhm 01/03/89 : Changed to not project the accept point on a locate.

rlw 11/28/88 : Modified due to changes in the extract 
               iso curve method.  Also modified to support
               <cr> and <R> appropriately.

rlw 05/29/87 : Changed command string

SS  10/04/86 : Design Date
*/

class implementation ECtanorm;

#include "EMS.h"
#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "igrdef.h"
#include "codef.h"
#include "exdef.h"
#include "exmacros.h"
#include "griomacros.h" /* co$getevent */
#include "grdpbmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EC_I.h"
#include "EC_M.h"
#include "bsdistptpt.h"


#define X 0
#define Y 1
#define Z 2

#define TANORM_CURVE 0
#define TANORM_SURFACE 1

from GRgraphics import GRlnproject;
from GRgraphics import GRdisplay;
from GRvg import GRgeomprops;
from GRbspline import EMcvtanorm;
#ifndef IDRAW
  from EMSsubbs import EMsftanorm, EMisoparcvs;
#endif


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
#ifndef IDRAW
  extern IGRlong EFdisplay_iso_curve_of_a_surface();
#endif
  IGRboolean stat_func, disponly;
  IGRchar locate_prompt[MAX_PROMPT_SIZE], relocate_prompt[MAX_PROMPT_SIZE];
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint event_size;
  IGRlong stat_OM, msg_loc, msg_loc2, i;
  IGRlong in_all_win, event_mask, event_mask1, event_mask2;
  IGRlong numpts_per_pt;
  IGRdouble delta, dum_t;
  IGRdouble *upars, *vpars, *outpoly;
  IGRdouble *pt1, *pt2;
  IGRpoint dum_pt, proj_point;
  IGRpoint lnpt1, lnpt2, xyz;
  GRobjid *outobj;
  struct IGRline brln;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  struct GRprops props;
  struct GRparms proj_parms, temp_parms;
  struct GRvg_construct const_list;
  enum GRdpmode dpmode;
  OMuword rclass, eliclass;
  OM_S_CLASSLIST rtree_classes, elig_classes;
  IGRlong ECdisplayPointSetByBuffer0(), EFpoint_on_object();

  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  brln.point1 = lnpt1;
  brln.point2 = lnpt2;
  outpoly = NULL;
  outobj = NULL;
  upars = NULL;
  vpars = NULL;
  strcpy (errmsg, "ECtanorm.execute");

  if (ME.super_cmd->mytype == TANORM_CURVE)
    ex$message(msgnumb = EM_M_MesTanNrmCur)
#ifndef IDRAW
  else if (ME.super_cmd->mytype == TANORM_SURFACE)
    ex$message(msgnumb = EM_M_MNrTnSr)
#endif
  else
    printf ("%s\n", errmsg);
    
  do 
    {
    switch (ME.super_cmd->state)
      {
      case 0:
        if (ME.ECelement->elem_hilit)
          {
          dpmode = GRbdhe;
          stat_OM = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdisplay
                     (&msg_loc, &ME.ECelement->elem.module_info.
                     md_env.matrix_type, ME.ECelement->elem.module_info.
                     md_env.matrix,
                     &dpmode, &ME.ECelement->md_env.md_id),
                            senderid = my_id,
                            targetid = ME.ECelement->elem.located_obj.objid,
                            targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE;
           goto ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
          }
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
        in_all_win = ONE_WINDOW | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;

        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;
        if (ME.super_cmd->mytype == TANORM_CURVE)
          {
          rclass = OPP_GRbspline_class_id;
          eliclass = OPP_GRbspline_class_id;
          strcpy (lc_attr.classes, "GRbspline");
          ex$message(msgnumb = EMS_P_00030, buff=locate_prompt);
          ex$message(msgnumb = EMS_I_00010, buff=relocate_prompt);
          }
        else
          {
#ifndef IDRAW
          rclass = OPP_EMSsubbs_class_id;
          eliclass = OPP_EMSsubbs_class_id;
          strcpy (lc_attr.classes, "EMSsubbs");
          ex$message(msgnumb = EMS_P_00031, buff=locate_prompt);
          ex$message(msgnumb = EMS_I_00011, buff=relocate_prompt); 
#endif
          }
        lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
        lc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                           LC_REF_OBJECTS |  /* locate reference objects */
                           LC_NO_REF_HEADER; /* no reference file header */

/****
DLB 10/5/91	Added & to event_size.  Crash on SUN.
****/

        lc$locate (rc = &msg_loc, event1 = &ME.ECelement->locev,
                   event2 = &accev, mask1 = event_mask1, mask2 = event_mask2,
                   eventsize = &event_size, display_flag = in_all_win,
                   response = response, response_data = response_data,
                   locate_prompt = locate_prompt, acc_prompt = "Accept/Reject",
                   relocate_prompt = relocate_prompt,
                   attributes = &lc_attr, stack = &ME.ECelement->locate_stack,
                   rtree_classes = &rtree_classes, 
                   eligible_classes = &elig_classes);
        ex$message(msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (msg_loc == LC_NO_OBJ_LOCATED)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            ME.ECelement->elem.module_info = accev.located_object[0].
                                         module_info;
            
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRgeomprops
                       (&msg_loc, &ME.ECelement->elem.module_info.
                       md_env.matrix_type, ME.ECelement->elem.module_info.
                       md_env.matrix,
                       &props),
                              senderid = my_id,
                              targetid = ME.ECelement->elem.located_obj.objid,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE,
             ret_end);

            ME.ECtanorm->elem_planar = props.planar;
            ME.super_cmd->state = 1;
            break;
          default:
            goto ret_end;
          }
        break;

      case 1:
/*
        ex$message(msgnumb = EMS_P_KeyTanNrmBth);
        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = "Key in (T)angents, (N)ormals or [B]oth",
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
           ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.ECtanorm->tangent = TRUE;
            ME.ECtanorm->normal = TRUE;
            ME.super_cmd->state = 2;
            break;
          case EX_STRING:
            switch (toupper (event.event.keyin[0]))
              {
              case 'T':
                ME.ECtanorm->tangent = TRUE;
                ME.ECtanorm->normal = FALSE;
                break;
              case 'N':
                ME.ECtanorm->normal = TRUE;
                ME.ECtanorm->tangent = FALSE;
                break;
              default:
                ME.ECtanorm->tangent = TRUE;
                ME.ECtanorm->normal = TRUE;
              }
            ME.super_cmd->state = 2;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 0;
            break;
          default:
            goto ret_end;
          }
        break;

      case 2:
/*
        ex$message(msgnumb = EMS_P_00077);
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            prompt = "Input start point",
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            stat_func = EFpoint_on_object(&ME.ECelement->elem, &event,
                         my_id, &msg_loc);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            pt1 = &event.event.button.x;
            pt2 = ME.ECtanorm->start_pt;
            OM_BLOCK_MOVE (pt1, pt2, sizeof (IGRpoint));
            OM_BLOCK_MOVE (&event.located_object[0].geom_parms,
             &ME.ECtanorm->start_parms, sizeof (struct GRparms));


            OM_BLOCK_MOVE (pt1, &ME.ECelement->locev.event.button.x,
             sizeof (IGRpoint));
            DPdrawcross (&msg_loc, &ME.ECelement->locev.event.button);
            
            ME.super_cmd->state = 3;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 1;
            break;
          default:
            goto ret_end;
          }
        break;

      case 3:
/*
        ex$message(msgnumb = EMS_P_00138);
        event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP,
            prompt = "Input end point/move on",
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            stat_func = EFpoint_on_object(&ME.ECelement->elem, &event,
                         my_id, &msg_loc);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            pt1 = &event.event.button.x;
            pt2 = proj_point;
            OM_BLOCK_MOVE (pt1, pt2, sizeof (IGRpoint));
            OM_BLOCK_MOVE (&event.located_object[0].geom_parms,
             &ME.ECtanorm->end_parms, sizeof (struct GRparms));

            OM_BLOCK_MOVE (pt1, &ME.ECelement->locev.event.button.x,
             sizeof (IGRpoint));
            DPdrawcross (&msg_loc, &ME.ECelement->locev.event.button);
            
            ME.ECtanorm->moveon = FALSE;
            if (ME.super_cmd->mytype == TANORM_CURVE)
              ME.super_cmd->state = 4;
            else
              ME.super_cmd->state = 5;
            break;
          case EX_RJT_MOVEON:
            ME.ECtanorm->u_num_pts = 1;
            ME.ECtanorm->v_num_pts = 1;
            ME.ECtanorm->moveon = TRUE;
            ME.super_cmd->state = 7;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 2;
            break;
          default:
            goto ret_end;
          }
        break;

      case 4:
/*
        ex$message(msgnumb = EMS_P_KeyNumPts);
        event_mask = GRm_SCALAR | GRm_BACK_UP | GRm_RJT_MOVEON;

        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_SCALAR,
            prompt = "Key in number of points: 1-n [1]",
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.ECtanorm->u_num_pts = 1;
            ME.ECtanorm->v_num_pts = 1;
            ME.super_cmd->state = 7;
            break;
          case EX_VALUE:
            ME.ECtanorm->u_num_pts = event.event.value;
            ME.ECtanorm->v_num_pts = 1;
            if (ME.ECtanorm->u_num_pts <= 0)
              ex$message(msgnumb = EMS_I_00022)
            else
              ME.super_cmd->state = 7;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 3;
            break;
          default:
            goto ret_end;
          }
        break;

      case 5:
#ifndef IDRAW
        ex$message(msgnumb = EMS_P_KeyNumPtsDir);
        EFdisplay_iso_curve_of_a_surface(
          &ME.ECelement->elem,
          &ME.ECelement->active_display,
          &ME.ECelement->md_env,
          FALSE,
          &ME.ECtanorm->start_parms.u,
          FALSE,        /* Don't care */
          TRUE,         /* Wait for input then erase */
          my_id,
          NULL,         /* Delete the curve after display */
          &msg_loc);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
/*
        event_mask = GRm_SCALAR | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_SCALAR,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit); 
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.ECtanorm->u_num_pts = 1;
            ME.super_cmd->state = 6;
            break;
          case EX_VALUE:
            ME.ECtanorm->u_num_pts = event.event.value;
            if (ME.ECtanorm->u_num_pts <= 0)
              ex$message(msgnumb = EMS_I_00022)
            else
              ME.super_cmd->state = 6;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 3;
            break;
          default:
            goto ret_end;
          }
#endif
        break;

      case 6:
#ifndef IDRAW
        ex$message(msgnumb = EMS_P_KeyNumPtsDir);
        EFdisplay_iso_curve_of_a_surface(
          &ME.ECelement->elem,
          &ME.ECelement->active_display,
          &ME.ECelement->md_env,
          TRUE,
          &ME.ECtanorm->start_parms.u,
          FALSE,        /* Don't care */
          TRUE,         /* Wait for input then erase */
          my_id,
          NULL,         /* Delete the curve after display */
          &msg_loc);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
/*
        event_mask = GRm_SCALAR | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            value_type = GRIO_SCALAR,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit); 
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.ECtanorm->v_num_pts = 1;
            ME.super_cmd->state = 7;
            break;
          case EX_VALUE:
            ME.ECtanorm->v_num_pts = event.event.value;
            if (ME.ECtanorm->v_num_pts <= 0)
              ex$message(msgnumb = EMS_I_00022)
            else
              ME.super_cmd->state = 7;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 5;
            break;
          default:
            goto ret_end;
          }
#endif
        break;

      case 7:
        ex$message(msgnumb = EMS_P_EntLenTanNrm);
        EFrblineseg (ME.ECtanorm->start_pt, &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_DIST | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP,
            value_type = GRIO_DISTANCE,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_S_ClearStatusField); 
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
          ex$message(msgnumb = EMS_I_00006);
          break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:

	    xyz[0] = event.event.button.x;
	    xyz[1] = event.event.button.y;
	    xyz[2] = event.event.button.z;

            ME.ECtanorm->len = BSdistptpt (&msg_loc, /*&event.event.button*/xyz, 
					ME.ECtanorm->start_pt);
            EMerr_hndlr (msg_loc != BSSUCC, *response, TERMINATE, ret_end);

            if (ME.ECtanorm->normal && (ME.super_cmd->mytype == TANORM_CURVE ?
                               ME.ECtanorm->elem_planar : TRUE))
              ME.super_cmd->state = 8;
            else
              ME.super_cmd->state = 9;
            break;
          case EX_VALUE:
            ME.ECtanorm->len = event.event.value;
            if (ME.ECtanorm->normal && (ME.super_cmd->mytype == TANORM_CURVE ?
                               ME.ECtanorm->elem_planar : TRUE))
              ME.super_cmd->state = 8;
            else
              ME.super_cmd->state = 9;
            break;
          case EX_BACK_UP:
            if (ME.ECtanorm->moveon)
              ME.super_cmd->state = 3;
            else if (ME.super_cmd->mytype == TANORM_CURVE)
              ME.super_cmd->state = 4;
            else
              ME.super_cmd->state = 6;
            break;
          default:
            goto ret_end;
          }
        break;

      case 8:
        ex$message(msgnumb = EMS_P_InpPtDirNrm);
        EFrblineseg (ME.ECtanorm->start_pt, &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_BACK_UP | GRm_SCALAR;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP | GRm_VALUE,
            value_type = GRIO_SCALAR,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
          ME.ECtanorm->natural = TRUE;
          ME.super_cmd->state = 9;
          break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            ME.ECtanorm->natural = FALSE;
            ME.ECtanorm->dirpt[X] = event.event.button.x;
            ME.ECtanorm->dirpt[Y] = event.event.button.y;
            ME.ECtanorm->dirpt[Z] = event.event.button.z;
            ME.super_cmd->state = 9;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 7;
            break;
          default:
            goto ret_end;
          }
        break;

      case 9:
/*
        ex$message(msgnumb = EMS_P_OutpDatabase);
        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = "Output into database? y/n [n]",
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);  
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
         event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_RJT_MOVEON:
            disponly = TRUE;
            ME.super_cmd->state = 10;
            break;
          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              disponly = FALSE;
            else
              disponly = TRUE;
            ME.super_cmd->state = 10;
            break;
          case EX_BACK_UP:
            if (ME.ECtanorm->normal && (ME.super_cmd->mytype == TANORM_CURVE ?
                               ME.ECtanorm->elem_planar : TRUE))
              ME.super_cmd->state = 8;
            else
              ME.super_cmd->state = 7;
            break;
          default:
            goto ret_end;
          }
        break;
     
      case 10:
        ex$message(msgnumb = EMS_I_00003);
        dpmode = GRbdhe;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay
                   (&msg_loc, &ME.ECelement->elem.module_info.
                   md_env.matrix_type, ME.ECelement->elem.module_info.
                   md_env.matrix, &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE;
         goto ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        /*
         * All the data has been gathered.
         * Allocate memory, invoke method,
         * display and deallocate memory.
         */

        if (disponly)
          {
          if (ME.super_cmd->mytype == TANORM_CURVE)
            numpts_per_pt = (ME.ECtanorm->tangent && ME.ECtanorm->normal ? 
                             3 : 2);
          else
            numpts_per_pt = (ME.ECtanorm->tangent && ME.ECtanorm->normal ? 5 :
                             (ME.ECtanorm->tangent ? 3 : 2));
          outpoly = (IGRdouble *) om$malloc(size = ME.ECtanorm->u_num_pts *
                                   ME.ECtanorm->v_num_pts * numpts_per_pt * 
                                   sizeof (IGRpoint));
          EMerr_hndlr_action (!outpoly, *response, TERMINATE, 
           ex$message(msgnumb = EMS_S_NoMemorAlloc);goto ret_end);
          outobj = NULL;
          }
        else
          {
          outobj = (GRobjid *) om$malloc(size = ME.ECtanorm->u_num_pts * 
                                ME.ECtanorm->v_num_pts * sizeof (GRobjid));
          EMerr_hndlr_action (!outobj, *response, TERMINATE, 
           ex$message(msgnumb = EMS_S_NoMemorAlloc); goto ret_end);

          const_list.msg = &msg_loc;
          const_list.newflag = FALSE;
          const_list.env_info = &ME.ECelement->md_env;
          const_list.level = ME.ECelement->active_level;
          const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
          const_list.display = &ME.ECelement->active_display;
          const_list.class_attr = NULL;
          const_list.name = NULL;
  
          outpoly = NULL;
          }

        upars = (IGRdouble *) om$malloc(size = ME.ECtanorm->u_num_pts * sizeof 
                               (IGRdouble));
        EMerr_hndlr_action (!upars, *response, TERMINATE, 
         ex$message(msgnumb = EMS_S_NoMemorAlloc); goto ret_end);

        if (!ME.ECtanorm->moveon && 
            ME.ECtanorm->start_parms.u > ME.ECtanorm->end_parms.u)
          {
          temp_parms = ME.ECtanorm->start_parms;
          ME.ECtanorm->start_parms = ME.ECtanorm->end_parms;
          ME.ECtanorm->end_parms = temp_parms;
          }
        upars[0] = ME.ECtanorm->start_parms.u;
        if (ME.ECtanorm->u_num_pts > 1)
          { 
          delta = (ME.ECtanorm->end_parms.u - ME.ECtanorm->start_parms.u) / 
                   (ME.ECtanorm->u_num_pts - 1);
          for (i=1; i<ME.ECtanorm->u_num_pts-1; i++)
            upars[i] = upars[i-1] + delta;
          upars[ME.ECtanorm->u_num_pts-1] = ME.ECtanorm->end_parms.u;
          }
        if (ME.super_cmd->mytype == TANORM_SURFACE)
          {
          vpars = (IGRdouble *) om$malloc(size = ME.ECtanorm->v_num_pts * 
                                 sizeof (IGRdouble));
          EMerr_hndlr_action (!vpars, *response, TERMINATE, 
           ex$message(msgnumb = EMS_S_NoMemorAlloc); goto ret_end);

          if (!ME.ECtanorm->moveon &&
              ME.ECtanorm->start_parms.v > ME.ECtanorm->end_parms.v)
            {
            temp_parms = ME.ECtanorm->start_parms;
            ME.ECtanorm->start_parms = ME.ECtanorm->end_parms;
            ME.ECtanorm->end_parms = temp_parms;
            }
          vpars[0] = ME.ECtanorm->start_parms.v;
          if (ME.ECtanorm->v_num_pts > 1)
            {
            delta = (ME.ECtanorm->end_parms.v - ME.ECtanorm->start_parms.v) / 
                     (ME.ECtanorm->v_num_pts - 1);
            for (i=1; i<ME.ECtanorm->v_num_pts-1; i++)
              vpars[i] = vpars[i-1] + delta;
            vpars[ME.ECtanorm->v_num_pts-1] = ME.ECtanorm->end_parms.v;
            }
          }

        if (ME.super_cmd->mytype == TANORM_CURVE)
          {
          stat_OM = om$send(msg = message GRbspline.EMcvtanorm
                     (&msg_loc, &ME.ECelement->elem.module_info.
                     md_env.matrix_type, ME.ECelement->elem.module_info.
                     md_env.matrix,
                     &const_list,
                     ME.ECtanorm->u_num_pts, 
                     &ME.ECtanorm->start_parms,
                     &ME.ECtanorm->mid_parms,
                     &ME.ECtanorm->end_parms,
                     ME.ECtanorm->len, 
                     ME.ECtanorm->natural ? NULL : ME.ECtanorm->dirpt,
                     ME.ECtanorm->tangent, ME.ECtanorm->normal, 
                     outpoly, outobj),
                     targetid = ME.ECelement->elem.located_obj.objid,
                     targetos = ME.ECelement->elem.located_obj.osnum);
          }
        else
          {
#ifndef IDRAW
          stat_OM = om$send(msg = message EMSsubbs.EMsftanorm
                     (&msg_loc, &ME.ECelement->elem.module_info.
                     md_env.matrix_type, ME.ECelement->elem.module_info.
                     md_env.matrix,
                     &const_list,
                     ME.ECtanorm->u_num_pts, upars, ME.ECtanorm->v_num_pts,
                     vpars, ME.ECtanorm->len,
                     ME.ECtanorm->natural ? NULL : ME.ECtanorm->dirpt,
                     ME.ECtanorm->tangent, ME.ECtanorm->normal, outpoly, 
                     outobj),
                     targetid = ME.ECelement->elem.located_obj.objid,
                     targetos = ME.ECelement->elem.located_obj.osnum);
#endif
          }
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; 
         ex$message(msgnumb = EMS_S_SeverError); goto ret_end, errmsg);
        EMerr_hndlr_action (EMis_error (msg_loc), msg_loc, msg_loc, 
        ex$message(msgnumb = EMS_S_CouldNtComp); ME.super_cmd->state = 0; break);

        if (ME.super_cmd->mytype == TANORM_SURFACE)
          {
          om$dealloc(ptr = vpars);
          vpars = NULL;
          }
        om$dealloc(ptr = upars);
        upars = NULL;

        if (outobj)
          {
          IGRint total_obj = 0;
          GRobjid group_obj;

          group_obj = NULL_OBJID;

          dpmode = GRbd;
          total_obj = ME.ECtanorm->u_num_pts * 
                      ME.ECtanorm->v_num_pts; 
          if (total_obj > 1)
          {
              EFbuild_graphic_group(total_obj,outobj,
                                    NULL,&const_list,&group_obj,&msg_loc);
              EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          }
          else 
              group_obj = outobj[0];
   

            stat_OM = om$send(msg = message GRgraphics.GRdisplay
                       (&msg_loc, &ME.ECelement->md_env.md_env.
                       matrix_type, ME.ECelement->md_env.md_env.matrix,
                       &dpmode, &ME.ECelement->md_env.md_id),
                       targetid = group_obj,
                       targetos = ME.ECelement->md_env.md_id.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE;
             goto ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          om$dealloc(ptr = outobj);
          outobj = NULL;
          }
        if (outpoly)
          {
          for (i=0; i<ME.ECtanorm->u_num_pts*ME.ECtanorm->v_num_pts; i++)
            {
            stat_OM = ECdisplayPointSetByBuffer0 (&msg_loc,
                       ME.ECelement->active_display, ME.ECelement->md_env, 
                       my_id,
                       numpts_per_pt, &outpoly[i*3*numpts_per_pt], GRhd,
                       IGRPY);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
             ret_end);
            }
          om$dealloc(ptr = outpoly);
          outpoly = NULL;
          }
        
        ex$message(msgnumb = EMS_S_TanNrmDisp);
        ME.super_cmd->state = 0;
        break;

      default:
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (vpars) om$dealloc(ptr = vpars);
  if (upars) om$dealloc(ptr = upars);
  if (outobj) om$dealloc(ptr = outobj);
  if (outpoly) om$dealloc(ptr = outpoly);
  return (stat_OM);
}

end implementation ECtanorm;

