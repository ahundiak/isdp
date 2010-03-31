class implementation ECpwtol;

#define CMD_SET_ANGTOL  0

#define GET_TOL		0

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar str[GR_MAX_CHAR], valuetype[GR_MAX_CHAR];
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  struct GRevent event;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_SET_ANGTOL)
    UI_message ("Pathway: Set Angle Tolerance");
  else  
    UI_message ("Unknown command");

  do
  {
    switch (ME.super_cmd->state)
    {
      case GET_TOL:
        sprintf (str, "Current Tolerance = %7.14lf", pwGetZeroAngTolDeg());
        if (ME.super_cmd->mytype == CMD_SET_ANGTOL)
          strcat (str, " deg");
        UI_status (str);

        if (ME.super_cmd->mytype == CMD_SET_ANGTOL)
        {
          strcpy (valuetype, GRIO_ANGLE);
          event.event.value = pwGetZeroAngTolDeg();
        }

        UI_prompt ("Keyin new tolerance");
        event_mask = GRm_VALUE;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     value_type = valuetype, 
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
 
        switch (event.response)
        {
          case EX_VALUE:
            pwSetZeroAngTolRad (event.event.value);
            break;

          default:
            goto wrapup;
        }
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

end implementation ECpwtol;
