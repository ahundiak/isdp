/* ###################   APOGEE COMPILED   ################## */
class implementation ECmkarea;

/*
  History

  Rustagi 05/26/92  Modified for Message Sub-system Compliance
  Sudha   07/05/93  Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "bserr.h"
#include "EC_S.h"
#include "EC_M.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define NODELETE_STATE  0
#define GETPLANE_STATE	1
#define LOCATE_STATE	2
#define AREAPTS_STATE	3
#define PROCESS_STATE	4
#define ACCOUTPUT_STATE 5
#define DELDRAW_STATE	6

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;

from GRgraphics import GRdisplay, GRdelete;

method init (IGRint type; IGRchar *string)
{
  IGRlong stat_OM;

  ME.ECmkarea->delete_cvs = TRUE;
  ME.ECmkarea->natural_plane = TRUE;
  ME.ECmkarea->numareas = 0;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message ECelements.init
             (type, string), targetid = my_id);

  ME.super_cmd->state = LOCATE_STATE;
  return (stat_OM);
}

method delete (IGRint defer_flag)
{
  IGRint i;
  IGRlong stat_OM, msg_loc;

  if (ME.super_cmd->state == ACCOUTPUT_STATE)
    {
    for (i=0; i<ME.ECmkarea->numareas; i++)
      {
      if (ME.ECmkarea->areacvs[i] == NULL_OBJID)
        continue;

      stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                 &ME.ECelements->active_md_env),
                 targetid = ME.ECmkarea->areacvs[i], 
                 targetos = ME.ECelements->active_md_env.md_id.osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
      }
    }

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message Root.delete
             (defer_flag), targetid = my_id);
  
ret_end:
  return (stat_OM);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar str[MAX_CHAR], buff1[MAX_CHAR];
  IGRint i, numundef;
  IGRlong msg_loc, stat_OM, eventmask;
  IGRdouble *plnpt, *plnnor;
  IGRpoint blinept1, blinept2;
  struct GRlc_info *elems;
  struct GRevent event;
  struct IGRline bline;
  struct IGRplane projpln, *projpln_ptr;
  struct GRvg_construct const_list;
  struct IGResbc esbc;
  struct GRmd_env *env;
  enum EMSuser_responses useract;
  enum GRdpmode dpmode;
extern IGRboolean EFboreline() ;
  extern IGRlong EMmkarea();

  stat_OM = OM_S_SUCCESS;
  bline.point1 = blinept1;
  bline.point2 = blinept2;

  ex$message(msgnumb = EM_M_CrArCr);

  do
    {
    switch (ME.super_cmd->state)
      {
      case NODELETE_STATE:
        ex$message(msgnumb = EMS_P_PresLocCur, buff=str);
        if (ME.ECmkarea->delete_cvs)
          ex$message(msgnumb = EMS_P_No, buff=buff1)
        else
          ex$message(msgnumb = EMS_P_Yes, buff=buff1);
          strcat (str,buff1);
        ex$message(field=PROMPT_FIELD, justification=RIGHT_JUS, in_buff=str);
        eventmask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.super_cmd->state = GETPLANE_STATE;
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'N')
              ME.ECmkarea->delete_cvs = TRUE;
            else if (toupper (event.event.keyin[0]) == 'Y')
              ME.ECmkarea->delete_cvs = FALSE;
            else
              goto ret_end;
            ME.super_cmd->state = GETPLANE_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = LOCATE_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case GETPLANE_STATE:
        ex$message(msgnumb = EMS_P_FlatToview, buff=str)
        if (ME.ECmkarea->natural_plane)
          ex$message(msgnumb = EMS_P_No, buff=buff1)
        else
          ex$message(msgnumb = EMS_P_Yes, buff=buff1);
          strcat (str,buff1);
        ex$message(field=PROMPT_FIELD, justification=RIGHT_JUS, in_buff=str);
        eventmask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField); 
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.super_cmd->state = LOCATE_STATE;
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'N')
              ME.ECmkarea->natural_plane = TRUE;
            else if (toupper (event.event.keyin[0]) == 'Y')
              ME.ECmkarea->natural_plane = FALSE;
            else
              goto ret_end;
            ME.super_cmd->state = LOCATE_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = NODELETE_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case LOCATE_STATE:
        if (ME.ECmkarea->delete_cvs)
          {
          ME.ECelements->properties &= ~LC_READ_ONLY;
          ME.ECelements->owner_action &= ~LC_RIGID_COMP;
          }
        else
          {
          ME.ECelements->properties |= LC_READ_ONLY;
          ME.ECelements->owner_action |= LC_RIGID_COMP;
          }

        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, "curve", 
                   NULL, " / Backup for options", NULL, NULL,
                   NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_moveon)
          ME.super_cmd->state = AREAPTS_STATE;
        else if (useract == EMSuser_backup)
          ME.super_cmd->state = NODELETE_STATE;
        else 
          goto ret_end;
        break;

      case AREAPTS_STATE:
        ex$message(msgnumb = EMS_P_InpPntInArea);
        eventmask = GRm_DATA | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     value_type = GRIO_SCALAR, response = response,
                     response_data = response_data, event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField);  

        switch (event.response)
          {
          case EX_DATA:
            ME.ECmkarea->numareas = 1;
            stat_func = EFboreline (&msg_loc, my_id, &event, &bline);
            EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

            if (!ME.ECmkarea->natural_plane)
              {
              plnpt = ME.ECmkarea->plnpt;
              plnnor = ME.ECmkarea->plnnor;

              OM_BLOCK_MOVE (&event.event.button.x, plnpt, sizeof (IGRpoint));
              plnnor[X] = blinept2[X] - blinept1[X];
              plnnor[Y] = blinept2[Y] - blinept1[Y];
              plnnor[Z] = blinept2[Z] - blinept1[Z];
              stat_func = BSnorvec (&msg_loc, plnnor);
              EMerr_hndlr (!stat_func || msg_loc != BSSUCC, stat_OM,
               OM_E_ABORT, ret_end);
              }

            OM_BLOCK_MOVE (bline.point1, ME.ECmkarea->areapts[0],
             sizeof (IGRpoint));
            OM_BLOCK_MOVE (bline.point2, ME.ECmkarea->areapts[1],
             sizeof (IGRpoint));
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = LOCATE_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case PROCESS_STATE:
        if (ME.ECelements->elems_hilit)
          {
          stat_OM = dp$erase_hilite (msg = &msg_loc);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          ME.ECelements->elems_hilit = FALSE;
          }
        
        const_list.msg = &msg_loc;
        const_list.env_info = &ME.ECelements->active_md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelements->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
        const_list.geometry = NULL;
        const_list.display = &ME.ECelements->active_display;
        esbc.is_polydis = FALSE;
        esbc.is_curvedis = TRUE;
        const_list.class_attr = (char *)&esbc;
        const_list.name = NULL;

        if (!ME.ECmkarea->natural_plane)
          {
          projpln.point = ME.ECmkarea->plnpt;
          projpln.normal = ME.ECmkarea->plnnor;
          projpln_ptr = &projpln;
          }
        else
          projpln_ptr = NULL;

        ex$message(msgnumb = EMS_I_00003);
        stat_OM = EMmkarea (&msg_loc, ME.ECelements->num_elems,
                   ME.ECelements->elems, ME.ECmkarea->numareas,
                   ME.ECmkarea->areapts, projpln_ptr, &const_list, NULL,
                   ME.ECmkarea->areacvs);
        ex$message(msgnumb = EMS_S_ClearStatusField);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

        if (msg_loc == EMS_I_NotFound)
          {
          numundef = 0;
          for (i=0; i<ME.ECmkarea->numareas; i++)
            if (ME.ECmkarea->areacvs[i] == NULL_OBJID)
              numundef++;

          if (numundef == ME.ECmkarea->numareas)
            {
            ex$message(msgnumb = EMS_S_AreaNtDef, buff=str);
            ME.ECelements->num_elems = 0;
            ME.ECelements->num_events = 0;
            ME.super_cmd->state = LOCATE_STATE;
            }
          else
            {
            ex$message(msgnumb = EMS_S_SomAreaNtDef, buff=str);
            ME.super_cmd->state = ACCOUTPUT_STATE;
            }
          ex$message(field=ERROR_FIELD, justification=CENTER_JUS, in_buff=str);
          }
        else
          ME.super_cmd->state = ACCOUTPUT_STATE;
        break;

      case ACCOUTPUT_STATE:
        env = &ME.ECelements->active_md_env;
        dpmode = GRhd;
        for (i=0; i<ME.ECmkarea->numareas; i++)
          {
          if (ME.ECmkarea->areacvs[i] == NULL_OBJID)
            continue;

          stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                     &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                     &env->md_id), targetid = ME.ECmkarea->areacvs[i], 
                     targetos = env->md_id.osnum);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
          }

        ex$message(msgnumb = EMS_P_00038);
        eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     value_type = GRIO_SCALAR, response = response,
                     response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

        stat_OM = dp$erase_hilite (msg = &msg_loc);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        switch (event.response)
          {
          case EX_RJT_MOVEON:
          case EX_BACK_UP:
            for (i=0; i<ME.ECmkarea->numareas; i++)
              {
              if (ME.ECmkarea->areacvs[i] == NULL_OBJID)
                continue;

              stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                         env), targetid = ME.ECmkarea->areacvs[i], 
                         targetos = env->md_id.osnum);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
              }

            if (event.response == EX_BACK_UP)
              ME.super_cmd->state = AREAPTS_STATE;
            else
              {
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;
              ME.super_cmd->state = LOCATE_STATE;
              }
            break;

          case EX_DATA:
            ME.super_cmd->state = DELDRAW_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case DELDRAW_STATE:
        if (ME.ECmkarea->delete_cvs)
          {
          elems = ME.ECelements->elems;
          dpmode = GRbe;
          for (i=0; i<ME.ECelements->num_elems; i++)
            {
            if (!elems[i].geom_parms.polygon_inx)
              continue;

            env = &elems[i].module_info;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                       &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                       &ME.ECelements->active_md_env.md_id),
                       targetid = elems[i].located_obj.objid, 
                       targetos = elems[i].located_obj.osnum);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                       env), targetid = elems[i].located_obj.objid, 
                       targetos = elems[i].located_obj.osnum);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
            }
          }

        dpmode = GRbd;
        env = &ME.ECelements->active_md_env;
        for (i=0; i<ME.ECmkarea->numareas; i++)
          {
          if (ME.ECmkarea->areacvs[i] == NULL_OBJID)
            continue;

          stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                     &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                     &env->md_id), targetid = ME.ECmkarea->areacvs[i], 
                     targetos = env->md_id.osnum);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
          }

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort *geomprops;
                            IGRshort *operation; IGRushort *options;
                            IGRint *minnum_to_locate, *maxnum_to_locate)
{
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  rtree_classes->p_classes[0] = OPP_GRbspline_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_GRcurve_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_CHGSHAPE;
  *options = EC_LOC_APPENDOBJNUM;

  *minnum_to_locate = 1;
  *maxnum_to_locate = MAXINT;

  return (stat_OM);
}

end implementation ECmkarea;

