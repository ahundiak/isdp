class implementation ECclock;

#include <alloca.h>

#define CMD_INIT_CLOCK  0
#define CMD_PRINT_CLOCK 1

#define GET_FILENAME		0
#define GET_CLOCK_NUM		1
#define PROCESS			2

%safe
static char outfile_name[GR_MAX_CHAR] = "";
%endsafe

method init (IGRint type; IGRchar *string)
{
  om$send (mode = OM_e_wrt_parent, msg = message ECclock.init (type, string),
   targetid = my_id);

  if (type == CMD_INIT_CLOCK)
    ME.super_cmd->state = GET_CLOCK_NUM;
  else
    ME.super_cmd->state = GET_FILENAME;

  return (OM_S_SUCCESS);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean status;
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRint i, inx, num_clocks=0, *clock_nums=NULL;
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  struct GRevent event;
  FILE *outfile=NULL;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_INIT_CLOCK)
    UI_message ("Initialize Performance Clocks");
  else if (ME.super_cmd->mytype == CMD_PRINT_CLOCK)
    UI_message ("Print Performance Clocks");
  else  
    UI_message ("Unknown command");

  do
  {
    switch (ME.super_cmd->state)
    {
      case GET_FILENAME:
        if (!strlen (outfile_name))
          strcpy (substr, "stderr");
        else
          strcpy (substr, outfile_name);
        sprintf (str, "Output Filename [%s]", substr);
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
            if (! (outfile = fopen (event.event.keyin, "w")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              ME.ECclock->outfile = (char *) outfile;
              strcpy (outfile_name, event.event.keyin);
              ME.super_cmd->state = GET_CLOCK_NUM;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (outfile_name))
            {
              if (! (outfile = fopen (outfile_name, "w")))
              {
                sprintf (str, "Could not open %s", outfile_name);
                UI_status (str);
                break;
              }
              else
              {
                ME.ECclock->outfile = (char *) outfile;
              }
            }
            else
            {
              ME.ECclock->outfile = (char *) stderr;
            }
            ME.super_cmd->state = GET_CLOCK_NUM;
            break;

          default:
            goto wrapup;
        }
        break;

      case GET_CLOCK_NUM:
        UI_prompt ("Clock numbers (num1 num2 ...) / Move on for all");
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
            num_clocks = pwNumFields (event.event.keyin);
            clock_nums = (int *) alloca (num_clocks * sizeof (int));
            status = TRUE;
            for (i=0; i<num_clocks; i++)
            {
              inx = pwGetInxOfField (i, event.event.keyin);
              if (sscanf (&event.event.keyin[inx], "%d", &clock_nums[i]) &&
                  !(clock_nums[i] >= 0 && clock_nums[i] < MAX_CLOCKS))
              {
                sprintf (str, "%dth number is not a valid clock", i);
                UI_status (str);
                sleep (1);
                status = FALSE;
                break;
              }
            }
            if (status)
              ME.super_cmd->state = PROCESS;
            break;

          case EX_RJT_MOVEON:
            num_clocks = MAX_CLOCKS;
            clock_nums = (int *) alloca (num_clocks * sizeof (int));
            for (i=0; i<num_clocks; i++)
              clock_nums[i] = i;
            ME.super_cmd->state = PROCESS;
            break;

          default:
            goto wrapup;
        }
        break;

      case PROCESS:
        UI_status ("");

        if (ME.super_cmd->mytype == CMD_INIT_CLOCK)
        {
          for (i=0; i<num_clocks; i++)
            pwInitClock (clock_nums[i]);
          UI_status ("Clock(s) initialized");
        }
        else if (ME.super_cmd->mytype == CMD_PRINT_CLOCK)
        {
          outfile = (FILE *) ME.ECclock->outfile;

          for (i=0; i<num_clocks; i++)
            pwPrintClock (outfile, clock_nums[i]);

          if (outfile != stderr)
            fclose (outfile);
          UI_status ("Clock(s) printed");
        }

        if (ME.super_cmd->mytype == CMD_INIT_CLOCK)
          ME.super_cmd->state = GET_CLOCK_NUM;
        else
          ME.super_cmd->state = GET_FILENAME;
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

end implementation ECclock;
