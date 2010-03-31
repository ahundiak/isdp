class implementation ECtester;

#define CMD_INT_POLY		0
#define CMD_INT_CURVE		1
#define CMD_INT_CURVE_BSPMATH	2
#define CMD_SURFACE_OPEN	3
#define CMD_SURFACE_OPEN_OLD	4
#define CMD_GET_TOPOWNERS	5
#define CMD_PRINT_READ		6
#define CMD_SFRULE_CURVES	7
#define CMD_SFEDGE_CURVES	8
#define CMD_GETTOLS		9
#define CMD_SFGMQTYS		10

#define GET_INPUT_FILE		0
#define GET_OUTPUT_FILE		1
#define PROCESS_STATE		2

%safe
static char infile_name[GR_MAX_CHAR] = "";
static char outfile_name[GR_MAX_CHAR] = "";
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean status;
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  struct GRevent event;
  FILE *infile=NULL, *outfile=NULL;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_INT_POLY)
    UI_message ("Test Intersect Polyline 2d");
  else if (ME.super_cmd->mytype == CMD_INT_CURVE)
    UI_message ("Test Intersect Curve 2d");
  else if (ME.super_cmd->mytype == CMD_INT_CURVE_BSPMATH)
    UI_message ("Test Intersect Curve - Bspmath");
  else if (ME.super_cmd->mytype == CMD_SURFACE_OPEN)
    UI_message ("Test Open Surface");
  else if (ME.super_cmd->mytype == CMD_SURFACE_OPEN_OLD)
    UI_message ("Test Open Surface - Old");
  else if (ME.super_cmd->mytype == CMD_GET_TOPOWNERS)
    UI_message ("Test Get Top Owners");
  else if (ME.super_cmd->mytype == CMD_PRINT_READ)
    UI_message ("Test Print / Read");
  else if (ME.super_cmd->mytype == CMD_SFRULE_CURVES)
    UI_message ("Test Surface Rule Lines");
  else if (ME.super_cmd->mytype == CMD_SFEDGE_CURVES)
    UI_message ("Test Surface Edge Curves");
  else if (ME.super_cmd->mytype == CMD_GETTOLS)
    UI_message ("Test Get Tols");
  else if (ME.super_cmd->mytype == CMD_SFGMQTYS)
    UI_message ("Test Surface Geometric Quantities");
  else  
    UI_message ("Unknown command");

  do
  {
    switch (ME.super_cmd->state)
    {
      case GET_INPUT_FILE:
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
            if (! (infile = fopen (event.event.keyin, "r")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              ME.ECtester->infile = (char *) infile;
              strcpy (infile_name, event.event.keyin);
              ME.super_cmd->state = GET_OUTPUT_FILE;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (infile_name))
            {
              if (! (infile = fopen (infile_name, "r")))
              {
                sprintf (str, "Could not open %s", infile_name);
                UI_status (str);
                break;
              }
              else
              {
                ME.ECtester->infile = (char *) infile;
                ME.super_cmd->state = GET_OUTPUT_FILE;
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

      case GET_OUTPUT_FILE:
        if (!strlen (outfile_name))
          strcpy (substr, "stderr");
        else
          strcpy (substr, outfile_name);
        sprintf (str, "Output Filename [%s]", substr);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
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
              ME.ECtester->outfile = (char *) outfile;
              strcpy (outfile_name, event.event.keyin);
              ME.super_cmd->state = PROCESS_STATE;
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
                ME.ECtester->outfile = (char *) outfile;
              }
            }
            else
            {
              ME.ECtester->outfile = (char *) stderr;
            }
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = GET_INPUT_FILE;
            break;

          default:
            goto wrapup;
        }
        break;

      case PROCESS_STATE:
        UI_status ("");
    
        infile = (FILE *) ME.ECtester->infile;
        outfile = (FILE *) ME.ECtester->outfile;

        pwInitClock(0);
        switch (ME.super_cmd->mytype)
        {
          case CMD_INT_POLY:
            status = test_pwIntPyPy2d (infile, outfile, 0);
            break;

          case CMD_INT_CURVE_BSPMATH:
            status = test_BScvcv_int (infile, outfile, 0);
            break;

          case CMD_SURFACE_OPEN:
            status = test_pwIsSfOpen (infile, outfile, 0);
            break;

          case CMD_SURFACE_OPEN_OLD:
            status = test_pwIsSfOpen_old (infile, outfile, 0);
            break;

          case CMD_GET_TOPOWNERS:
            status = test_pwGetTopOwnersOfOS (infile, outfile, 0);
            break;

          case CMD_PRINT_READ:
            status = test_pwPrintRead (infile, outfile, 0);
            break;

          case CMD_SFRULE_CURVES:
            status = test_pwSfRuleCvs (infile, outfile, 0);
            break;

          case CMD_SFEDGE_CURVES:
            status = test_pwSfEdCvs (infile, outfile, 0);
            break;

          case CMD_GETTOLS:
            status = test_pwGetTols (infile, outfile, 0);
            break;

          case CMD_SFGMQTYS:
            status = test_pwSfGmQtys (infile, outfile, 0);
            break;

          default:
            stat_OM = OM_E_ABORT;
            goto wrapup;
        }

        fclose (infile);

        if (!status)
        {
          UI_status ("Test not performed");
          fprintf (outfile, "Test not performed\n");
        }
        else
        {
          fprintf (outfile, "\nTime Taken:\n");
          pwPrintClock (outfile, 0);
        }
        if (outfile != stderr)
          fclose (outfile);

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = GET_INPUT_FILE;
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

end implementation ECtester;
