class implementation ECinpwcvint;

%safe
#include <stdio.h>
%endsafe

#define FILENAME_STATE		 0
#define REQUEST_PERSISTENCE      1
#define PROCESS_PRIMARY_POINTS	 2
#define PROCESS_SECONDARY_POINTS 3

from GRgraphics import GRconstruct, GRdisplay;

%safe
static char infile_name[GR_MAX_CHAR] = "";
static IGRboolean _persistent=TRUE;
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean process;
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  GRobjid const_obj;
  PWpoint point, dumpoint;
  struct GRmd_env *env;
  struct GRevent event;
  struct GRvg_construct const_list;
  enum GRdpmode dpmode;
  FILE *infile = NULL;

  stat_OM = OM_S_SUCCESS;
  env = &ME.ECelements->active_md_env;

  UI_message ("Input Curve Intersection Points");

  do
    {
      switch (ME.super_cmd->state)
      {
      case FILENAME_STATE:
        sprintf (str, "Input Filename [%s]", infile_name);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
 
        switch (event.response)
        {
          case EX_STRING:
            if (! (ME.ECinpwcvint->infile = (char *)
                    fopen (event.event.keyin, "r")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              strcpy (infile_name, event.event.keyin);
              ME.super_cmd->state = REQUEST_PERSISTENCE;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (infile_name))
            {
              if (! (ME.ECinpwcvint->infile = (char *)
                      fopen (infile_name, "r")))
              {
                sprintf (str, "Could not open %s", infile_name);
                UI_status (str);
                break;
              }
              else
              {
                ME.super_cmd->state = REQUEST_PERSISTENCE;
              }
            }
            else
            {
              UI_status ("No filename specified");
            }
            break;

          default:
            goto wrapup;
        }
        break;

      case REQUEST_PERSISTENCE:
        UI_status ("");
        if (_persistent)
          strcpy (substr, "[y]/n");
        else
          strcpy (substr, "y/[n]");
        sprintf (str, "Create persistent object(s) %s", substr);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
  
        switch (event.response)
        {
          case EX_STRING:
            if (toupper(event.event.keyin[0]) == 'Y')
              _persistent = TRUE;
            else
              _persistent = FALSE;

            ME.super_cmd->state = PROCESS_PRIMARY_POINTS;
            break;

          case EX_RJT_MOVEON:
            ME.super_cmd->state = PROCESS_PRIMARY_POINTS;
            break;

          case EX_BACK_UP:
            fclose ((FILE *) ME.ECinpwcvint->infile);
            ME.super_cmd->state = FILENAME_STATE;
            break;

          default:
            goto wrapup;
        }
        break;
     
      case PROCESS_PRIMARY_POINTS:
        UI_status ("");
        UI_prompt ("Create primary intersection points [y]/n");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
  
        process = FALSE;
        switch (event.response)
        {
          case EX_STRING:
            if (toupper(event.event.keyin[0]) == 'Y')
              process = TRUE;
            ME.super_cmd->state = PROCESS_SECONDARY_POINTS;
            break;

          case EX_RJT_MOVEON:
            process = TRUE;
            ME.super_cmd->state = PROCESS_SECONDARY_POINTS;
            break;

          case EX_BACK_UP:
            fclose ((FILE *) ME.ECinpwcvint->infile);
            ME.super_cmd->state = FILENAME_STATE;
            break;

          default:
            goto wrapup;
        }
     
        if (process)
        {
          const_list.msg = &msg_loc;
          const_list.newflag = FALSE;
          const_list.env_info = env;
          const_list.level = ME.ECelements->active_level;
          const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
          const_list.display = &ME.ECelements->active_display;
          const_list.class_attr = NULL;
          const_list.name = NULL;
  
          infile = (FILE *) ME.ECinpwcvint->infile;
          fseek (infile, 0, 0);
          while (pwReadPt (infile, point) && pwReadPt (infile, dumpoint))
          {
            if (_persistent)
            {
              if (! EFplace_line_string (my_id, &const_list, 1, point,
                     &const_obj, &msg_loc))
              {
                UI_status ("Could not construct point");
                const_obj = NULL_OBJID;
                break;
              }
    
              dpmode = GRbdhe;
              om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
               &env->md_env.matrix_type, env->md_env.matrix, &dpmode, 
               &env->md_id), targetid = const_obj, 
               targetos = env->md_id.osnum);
            }
            else
            {
              ECdisplayPointSetByBuffer (&msg_loc, 
               ME.ECelements->active_display, 
               ME.ECelements->active_md_env, NULL_OBJID, 
               1, point, TRUE);
            }
          }
        }
        break;

      case PROCESS_SECONDARY_POINTS:
        UI_status ("");
        UI_prompt ("Create secondary intersection points y/[n]");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
  
        process = TRUE;
        switch (event.response)
        {
          case EX_STRING:
            if (toupper(event.event.keyin[0]) == 'N')
              process = FALSE;
            break;

          case EX_RJT_MOVEON:
            process = FALSE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = PROCESS_PRIMARY_POINTS;
            break;

          default:
            goto wrapup;
        }
     
        if (process)
        {
          const_list.msg = &msg_loc;
          const_list.newflag = FALSE;
          const_list.env_info = env;
          const_list.level = ME.ECelements->active_level;
          const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
          const_list.display = &ME.ECelements->active_display;
          const_list.class_attr = NULL;
          const_list.name = NULL;
  
          infile = (FILE *) ME.ECinpwcvint->infile;
          fseek (infile, 0, 0);
          while (pwReadPt (infile, dumpoint) && pwReadPt (infile, point))
          {
            if (_persistent)
            {
              if (! EFplace_line_string (my_id, &const_list, 1, point,
                     &const_obj, &msg_loc))
              {
                UI_status ("Could not construct point");
                const_obj = NULL_OBJID;
                break;
              }
    
              dpmode = GRbdhe;
              om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
               &env->md_env.matrix_type, env->md_env.matrix, &dpmode, 
               &env->md_id), targetid = const_obj, 
               targetos = env->md_id.osnum);
            }
            else
            {
              ECdisplayPointSetByBuffer (&msg_loc, 
               ME.ECelements->active_display, 
               ME.ECelements->active_md_env, NULL_OBJID, 
               1, point, TRUE);
            }
          }
        }

        fclose ((FILE *) ME.ECinpwcvint->infile);

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = FILENAME_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto wrapup;
      }
    }
  while (TRUE);

wrapup:
  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

end implementation ECinpwcvint;
