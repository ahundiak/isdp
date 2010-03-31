class implementation ECrebool;

#include "EMSopt.h"

#define CMD_REDO_BOOLEAN	0
#define CMD_PRINT_BOOLEAN	1
#define CMD_UNDO_BOOLEAN	2
#define CMD_REMOVE_SLMACRO	3

#define LOCATE_BOOLEAN_STATE	0
#define OPTIONS_1_STATE		1
#define OPTIONS_2_STATE		2
#define OPTIONS_3_STATE		3
#define OPTIONS_DEPTH_STATE	4
#define PROCESS_STATE		5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsfboolean_class_id, OPP_EMSsubbs_class_id;
extern GRclassid OPP_EMSsfmacro_class_id;

from EMSsfboolean import EMredobooltree, EMgettreedepth;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar str[GR_MAX_CHAR];
  IGRboolean noop, incremental, fancy_display, undo, trynewtol;
  IGRint depth, num;
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  struct GRmd_env *env;
  struct GRevent event;
  enum EMSuser_responses useract;
  FILE *outfile;

  stat_OM = OM_S_SUCCESS;
  noop = FALSE;
  incremental = FALSE;
  fancy_display = FALSE;
  undo = FALSE;
  trynewtol = TRUE;

  if (ME.super_cmd->mytype == CMD_REDO_BOOLEAN)
    UI_message ("Z Redo Boolean Tree");
  else if (ME.super_cmd->mytype == CMD_PRINT_BOOLEAN)
    UI_message ("Z Print Boolean Tree");
  else if (ME.super_cmd->mytype == CMD_UNDO_BOOLEAN)
    UI_message ("Z Undo Boolean Tree");
  else
    UI_message ("Z Remove Macro States");
  
  do
    {
    switch (ME.super_cmd->state)
      {
      case LOCATE_BOOLEAN_STATE:
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, "Boolean",
                   NULL, NULL, NULL, NULL, NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_data)
          {
          sprintf (str, "Boolean Id - %d [OS: %d]", 
           ME.ECelements->elems->located_obj.objid,
           ME.ECelements->elems->located_obj.osnum);
          UI_status (str);
          if (ME.super_cmd->mytype == CMD_REMOVE_SLMACRO)
            ME.super_cmd->state = PROCESS_STATE;
          else if (ME.super_cmd->mytype == CMD_REDO_BOOLEAN ||
                   ME.super_cmd->mytype == CMD_UNDO_BOOLEAN)
            ME.super_cmd->state = OPTIONS_1_STATE;
          else 
            ME.super_cmd->state = OPTIONS_DEPTH_STATE;
          }
        else 
          goto ret_end;
        break;

      case OPTIONS_1_STATE:
        UI_prompt ("Fancy display y/n [n]");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            fancy_display = FALSE;
            if (ME.super_cmd->mytype == CMD_REDO_BOOLEAN)
              ME.super_cmd->state = OPTIONS_2_STATE;
            else
              ME.super_cmd->state = OPTIONS_DEPTH_STATE;
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'N')
              fancy_display = FALSE;
            else if (toupper (event.event.keyin[0]) == 'Y')
              fancy_display = TRUE;
            else
              goto ret_end;
            if (ME.super_cmd->mytype == CMD_REDO_BOOLEAN)
              ME.super_cmd->state = OPTIONS_2_STATE;
            else
              ME.super_cmd->state = OPTIONS_DEPTH_STATE;
            break;

          case EX_BACK_UP:
            ME.ECelements->num_elems = 0;
            ME.ECelements->num_events = 0;
            ME.super_cmd->state = LOCATE_BOOLEAN_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case OPTIONS_2_STATE:
	UI_prompt ("Perform incremental redo y/n [n]");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            incremental = FALSE;
            ME.super_cmd->state = OPTIONS_3_STATE;
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'N')
              incremental = FALSE;
            else if (toupper (event.event.keyin[0]) == 'Y')
              incremental = TRUE;
            else
              goto ret_end;
            ME.super_cmd->state = OPTIONS_3_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = OPTIONS_1_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case OPTIONS_3_STATE:
	UI_prompt ("Try new tolerances on failure y/n [y]");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            trynewtol = TRUE;
            ME.super_cmd->state = OPTIONS_DEPTH_STATE;
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              trynewtol = TRUE;
            else if (toupper (event.event.keyin[0]) == 'N')
              trynewtol = FALSE;
            else
              goto ret_end;
            ME.super_cmd->state = OPTIONS_DEPTH_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = OPTIONS_2_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case OPTIONS_DEPTH_STATE:
        depth = 0;
        om$send (msg = message EMSsfboolean.EMgettreedepth (&msg_loc, 0,
         &depth), targetid = ME.ECelements->elems->located_obj.objid,
         targetos = ME.ECelements->elems->located_obj.osnum);

        sprintf (str, "Input tree depth to process [MAX = %d]", depth);
	UI_prompt (str);
        event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_VALUE:
            depth = event.event.value;
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_BACK_UP:
            if (ME.super_cmd->mytype == CMD_REDO_BOOLEAN)
              ME.super_cmd->state = OPTIONS_2_STATE;
            else
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;
              ME.super_cmd->state = LOCATE_BOOLEAN_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case PROCESS_STATE:
        dp$erase_hilite (msg = &msg_loc);
        ME.ECelements->elems_hilit = FALSE;

        if (ME.super_cmd->mytype == CMD_PRINT_BOOLEAN)
          noop = TRUE;
        else if (ME.super_cmd->mytype == CMD_UNDO_BOOLEAN)
          undo = TRUE;

        UI_status ("");
     
        if (ME.super_cmd->mytype == CMD_REMOVE_SLMACRO)
          {
          num = EMremove_slmacro (&ME.ECelements->elems->located_obj.objid,
                 ME.ECelements->elems->located_obj.osnum);
          sprintf (str, "%d Macro States removed", num);
          UI_status (str);
          }
        else
          {
          env = &ME.ECelements->active_md_env;
          outfile = fopen ("/tmp/redobool.out", "w");
          stat_OM = om$send (msg = message EMSsfboolean.EMredobooltree 
                     (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
                     (noop ? EMS_O_Noop : NULL) | 
                     (incremental ? EMS_O_Incremental : NULL) | 
                     (fancy_display ? EMS_O_Display : NULL) |
                     (undo ? EMS_O_Undo : NULL) |
                     (trynewtol ? EMS_O_Retry : NULL) |
                     EMS_O_Debug,
                     depth,
                     &ME.ECelements->elems->located_obj.objid, outfile),
                     targetid = ME.ECelements->elems->located_obj.objid,
                     targetos = ME.ECelements->elems->located_obj.osnum);
          if (outfile)
            {
            fclose (outfile);
            UI_status ("Output also in /tmp/redobool.out");
            }
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          }

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_BOOLEAN_STATE;
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
  rtree_classes->p_classes[0] = OPP_EMSsubbs_class_id;

  if (ME.super_cmd->mytype != CMD_REMOVE_SLMACRO)
  {
    elig_classes->w_count = 1;
    elig_classes->w_flags = OM_CLST_subclass;
    elig_classes->p_classes[0] = OPP_EMSsfboolean_class_id;
  }
  else
  {
    elig_classes->w_count = 2;
    elig_classes->w_flags = OM_CLST_subclass;
    elig_classes->p_classes[0] = OPP_EMSsfboolean_class_id;
    elig_classes->p_classes[1] = OPP_EMSsfmacro_class_id;
  }
  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_CHGSHAPE;
  *options = EC_LOC_NOHALFHILITE;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

end implementation ECrebool;
