class implementation ECpwbool;

#include <string.h>
#include "PWapi/sfbool.h"
#include "PWapi/clock.h"

#define CMD_BOOLEAN_UNION		0
#define CMD_BOOLEAN_DIFFERENCE		1
#define CMD_BOOLEAN_INTERSECTION	2
#define CMD_SURFACE_INTERSECTION	3

#define LOCATE_STATE		0
#define PROCESS_STATE		1

extern IGRboolean _Pathway, _pathway_trim, _pathway_orient;

extern GRclassid OPP_EMSsubbs_class_id, OPP_EMSsurface_class_id;

from GRvg import GRgetsymb;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  char op_str[PW_K_MaxCharOnLine+1], status_str[PW_K_MaxCharOnLine+1];
  char *p_basename, datafilename[PW_K_MaxCharFilename+1], logfilename[30];
  long msg_loc, stat_OM;
  int num_time;
  PWresult result=PW_K_Success;
  PWobjid sf1, sf2, boolean;
  PWosnum os;
  enum EMSuser_responses useract;
  struct GRsymbology symb;
  FILE *logfile=NULL;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_BOOLEAN_UNION)
    UI_message ("z pathway Boolean union");
  else if (ME.super_cmd->mytype == CMD_BOOLEAN_DIFFERENCE)
    UI_message ("z pathway Boolean difference");
  else if (ME.super_cmd->mytype == CMD_BOOLEAN_INTERSECTION)
    UI_message ("z pathway Boolean intersection");
  else if (ME.super_cmd->mytype == CMD_SURFACE_INTERSECTION)
    UI_message ("z pathway surface intersection");
  else  
    UI_message ("Unknown command");

  do
    {
      switch (ME.super_cmd->state)
      {
        case LOCATE_STATE:
          stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                     &useract, response, response_data, "Surface",
                     NULL, NULL, NULL, NULL, NULL),
                     targetid = my_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           wrapup);

          if (useract == EMSuser_data)
          {
            ME.super_cmd->state = PROCESS_STATE;
          }
          else 
          {
            goto wrapup;
          }
          break;

      case PROCESS_STATE:
        dp$erase_hilite (msg = &msg_loc);
        ME.ECelements->elems_hilit = FALSE;

        UI_status ("");
     
        sf1 = ME.ECelements->elems[0].located_obj.objid;
        sf2 = ME.ECelements->elems[1].located_obj.objid;
        os = ME.ECelements->active_md_env.md_id.osnum;
        boolean = PW_K_NullObjid;

        if (_Pathway)
        {
          _pathway_trim = TRUE;
          _pathway_orient = TRUE;
        }

        pwStartClock (0);
        if (ME.super_cmd->mytype == CMD_BOOLEAN_UNION)
          result = pwSfBooleanUnion (sf1, sf2, os, TRUE, &boolean);
        else if (ME.super_cmd->mytype == CMD_BOOLEAN_DIFFERENCE)
          result = pwSfBooleanDifference (sf1, sf2, os, TRUE, &boolean);
        else if (ME.super_cmd->mytype == CMD_BOOLEAN_INTERSECTION)
          result = pwSfBooleanIntersection (sf1, sf2, os, TRUE, &boolean);
        else
          result = SetError (PW_K_Pathway, PW_K_NotImplemented);
        pwStopClock (0);

        if (_Pathway)
        {
          _pathway_trim = FALSE;
          _pathway_orient = FALSE;
        }

        if (ME.super_cmd->mytype == CMD_BOOLEAN_UNION)
          strcpy (op_str, "Union");
        else if (ME.super_cmd->mytype == CMD_BOOLEAN_DIFFERENCE)
          strcpy (op_str, "Difference");
        else if (ME.super_cmd->mytype == CMD_BOOLEAN_INTERSECTION)
          strcpy (op_str, "Intersection");
        else
          strcpy (op_str, "No-op");

        ex$filename (name = datafilename, len = PW_K_MaxCharFilename);
        p_basename = strrchr (datafilename, '/');
        if (p_basename)
          p_basename++;
        else
          p_basename = datafilename;

        sprintf (logfilename, "log/%s.log", p_basename);
        if (! (logfile = fopen (logfilename, "a")))
        {
          sprintf (status_str, "Could not open %s", logfilename);
          UI_status (status_str);
          goto loc_wrap;
        }
        else
        {
          sprintf (status_str, "Command log in %s", logfilename);
          UI_status (status_str);
        }

        symb.level = DEFAULT_GR_LEVEL;
        om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb), 
         targetid = sf1, targetos = os);

        fprintf (logfile, "File: %s\nLayer: %d\n", p_basename, symb.level);
        fprintf (logfile, "Operation: %s (%d, %d)\n", op_str, sf1, sf2);
        if (IsError (result))
          strcpy (op_str, "*** Error ***");
        else
          strcpy (op_str, "Success");
        fprintf (logfile, "Result: %s\n", op_str);
        num_time = pwGetUserTime (0);
        fprintf (logfile, "Time taken: %d (%lf secs.)\n\n", num_time, 
         ((double) num_time) / 60.0);

        fclose (logfile);

        loc_wrap:
        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_STATE;
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
  *operation = EC_GEOM_CHGSHAPE;
  *options = NULL;

  *minnum_to_locate = 2;
  *maxnum_to_locate = 2;

  return (stat_OM);
}

end implementation ECpwbool;
