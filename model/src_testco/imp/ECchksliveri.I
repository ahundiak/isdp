class implementation ECchksliver;

#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"

#define LOCATE_COMPSURF_STATE	0
#define OPTIONS_1_STATE		1
#define OPTIONS_2_STATE		2
#define PROCESS_STATE		3

extern GRclassid OPP_EMSsurface_class_id, OPP_EMSsubbs_class_id;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar str[GR_MAX_CHAR];
  IGRint num_sliver_sfs;
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  IGRdouble xyztol;
  struct GRmd_env *env;
  struct GRevent event;
  enum EMSuser_responses useract;
  FILE *outfile;

  stat_OM = OM_S_SUCCESS;
  
  UI_message ("Z Check Slivers");
  
  do
    {
    switch (ME.super_cmd->state)
      {
      case LOCATE_COMPSURF_STATE:
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data,
                   "Surface / Composite Surface", 
                   NULL, NULL, NULL, NULL, NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_data)
          {
          sprintf (str, "Located Id - %d [OS: %d]", 
           ME.ECelements->elems->located_obj.objid,
           ME.ECelements->elems->located_obj.osnum);
          UI_status (str);

          ME.super_cmd->state = OPTIONS_1_STATE;
          }
        else 
          goto ret_end;
        break;

      case OPTIONS_1_STATE:
        UI_prompt ("Number of sample pts to use [3]");
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
            ME.ECchksliver->num_samplepts = 3;
            ME.super_cmd->state = OPTIONS_2_STATE;
            break;

          case EX_VALUE:
            ME.ECchksliver->num_samplepts = event.event.value;
            if (ME.ECchksliver->num_samplepts <= 0)
              UI_status ("Bad number of sample pts - re-specify");
            else
              ME.super_cmd->state = OPTIONS_2_STATE;
            break;

          case EX_BACK_UP:
            ME.ECelements->num_elems = 0;
            ME.ECelements->num_events = 0;
            ME.super_cmd->state = LOCATE_COMPSURF_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case OPTIONS_2_STATE:
        BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
        sprintf (str, "Model space tolerance to use [%lf]", xyztol);
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
            ME.ECchksliver->xyztol = xyztol;
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_VALUE:
            ME.ECchksliver->xyztol = event.event.value;
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = OPTIONS_1_STATE;
            break;

          default:
            goto ret_end;
          }
        break;

      case PROCESS_STATE:
        dp$erase_hilite (msg = &msg_loc);
        ME.ECelements->elems_hilit = FALSE;

        UI_status ("Processing...");

        env = &ME.ECelements->active_md_env;
        outfile = fopen ("/tmp/chksliver.out", "w");
        num_sliver_sfs = EMchksliver (&msg_loc, EMS_O_Display | EMS_O_Debug, 
                          &env->md_env.matrix_type, env->md_env.matrix,
                          &ME.ECelements->elems->located_obj,
                          ME.ECchksliver->xyztol, 
                          ME.ECchksliver->num_samplepts,
                          NULL, NULL, outfile);
        if (outfile)
          fclose (outfile);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (num_sliver_sfs)
          {     
          sprintf (str, "Num sliver sfs = %d. Details in /tmp/chksliver.out",
           num_sliver_sfs);
          UI_status (str);
          }
        else
          UI_status ("No slivers found");

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_COMPSURF_STATE;
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

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_EMSsurface_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_NOHALFHILITE;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

end implementation ECchksliver;
