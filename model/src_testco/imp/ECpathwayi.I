class implementation ECpathway;

#include "EMS.h"

#define PATHWAY  		0
#define PATHWAY_TRIM		1
#define PATHWAY_ORIENT 		2
#define PATHWAY_DEBUGLEVEL	3
#define PATHWAY_ERRLOG		4

%safe
short _Pathway=1;
short _pathway_trim=0;
short _pathway_orient=0;
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  char str[PW_K_MaxCharOnLine+1];
  int msg_loc, stat_OM, eventmask;
  struct GRevent event;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == PATHWAY)
    UI_message ("Pathway");
  else if (ME.super_cmd->mytype == PATHWAY_TRIM)
    UI_message ("Pathway Trimming");
  else if (ME.super_cmd->mytype == PATHWAY_ORIENT)
    UI_message ("Pathway Orientation");
  else if (ME.super_cmd->mytype == PATHWAY_DEBUGLEVEL)
    UI_message ("Pathway Debug Level");
  else if (ME.super_cmd->mytype == PATHWAY_ERRLOG)
    UI_message ("Pathway Err Log");
  else 
    UI_status ("Pathway Unknown Command");

  if (ME.super_cmd->mytype == PATHWAY)
  {
    _Pathway = !_Pathway;
    if (!_Pathway)
    {
      _pathway_trim   = 0;
      _pathway_orient = 0;
    }
    if (_Pathway)
      UI_status ("Pathway ON");
    else
      UI_status ("Pathway OFF");
    ems_sleep (2);
  }
  
  else if (ME.super_cmd->mytype == PATHWAY_TRIM)
  {
    _pathway_trim = !_pathway_trim;
    if (_pathway_trim)
      UI_status ("Pathway Trimming ON");
    else
      UI_status ("Pathway Trimming OFF");
    ems_sleep (2);
  }

  else if (ME.super_cmd->mytype == PATHWAY_ORIENT)
  {
    _pathway_orient = !_pathway_orient;
    if (_pathway_orient)
      UI_status ("Pathway Orientation ON");
    else
      UI_status ("Pathway Orientation OFF");
    ems_sleep (2);
  }

  else if (ME.super_cmd->mytype == PATHWAY_DEBUGLEVEL)
  {
    int level;

    sprintf (str, "Current Debug Level - %d", pwGetDebugLevel());
    UI_status (str);
    eventmask = GRm_VALUE | GRm_RJT_MOVEON;
    co$getevent (msg = &msg_loc, event_mask = eventmask,
     value_type = GRIO_SCALAR, 
     prompt = "Enter debug level 0/[1]/2/3",
     response = response, response_data = response_data,
     event = &event);
    if (event.response == EX_VALUE)
    {
      level = (int) event.event.value;
    }
    else
    {
      level = 1;
    }

    pwSetDebugLevel (level);
    sprintf (str, "Debug Level is now - %d", pwGetDebugLevel());
    UI_status (str);
    ems_sleep (2);
  }

  else if (ME.super_cmd->mytype == PATHWAY_ERRLOG)
  {
    char str[PW_K_MaxCharOnLine+1], filename[PW_K_MaxCharFilename+1];
    PWboolean append;

    eventmask = GRm_TEXT_VALUE;
    co$getevent (msg = &msg_loc, event_mask = eventmask,
     prompt = "Filename / (C)lose / [S]tderr",
     response = response, response_data = response_data,
     event = &event);
    if (event.response == EX_STRING)
    {
      if (strlen (event.event.keyin) == 1 && 
          (toupper (event.event.keyin[0]) == 'C' ||
           toupper (event.event.keyin[0]) == 'S'))
      {
        pwResetErrLogFile();
      }
      else
      {
        strcpy (filename, event.event.keyin);
        eventmask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
        co$getevent (msg = &msg_loc, event_mask = eventmask,
         prompt = "Append? [Y]/N",
         response = response, response_data = response_data,
         event = &event);
        if (event.response != EX_RJT_MOVEON &&
            (event.response == EX_STRING && 
             toupper (event.event.keyin[0]) == 'N'))
          append = FALSE;
        else
          append = TRUE;

        pwSetErrLogFile (filename, append);
      }

      if (pwGetErrLogFilename (filename))
      {
        sprintf (str, "Err File: %s", filename);
        UI_status (str);
      }
      else
      {
        UI_status ("Error Log is now stderr");
      }
    } 
    else
    {
      UI_status ("Unrecognized input. Ignoring...");
    }
    ems_sleep (2);
  }
 
  *response = TERMINATE;
  return (OM_S_SUCCESS);
}

end implementation ECpathway;
