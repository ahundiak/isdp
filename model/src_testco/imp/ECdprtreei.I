class implementation ECdprtree;

#include "EMSopt.h"
#include "PWerror.h"
#include "PWapi/clsid.h"
#include "PWapi/grownquery.h"
#include "PWapi/featquery.h"
#include "PWapi/undo.h"

#define CMD_PRINT_DPR_TREE	0
#define CMD_UNDO_DPR_TREE	1

#define LOCATE_STATE		0
#define GET_UNDO_ID_STATE	1
#define GET_FILE_NAME_STATE	2
#define PROCESS_STATE		3

%safe
static PWresult printdprtree
(
  PWobjid,
  PWosnum,
  void *
);

struct printdprtree_args
{
  FILE *outfile;
  PWboolean print_with_spaces;
};
%endsafe

extern GRclassid OPP_EMSsubbs_class_id, OPP_EMSsurface_class_id;
extern GRclassid OPP_EMSdpr_class_id;

%safe
static char _outfile_name[PW_K_MaxCharFilename] = "";
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  PWboolean stat_func;
  char str[PW_K_MaxCharFilename], substr[PW_K_MaxCharFilename];
  long msg_loc, stat_OM, event_mask;
  PWresult result=PW_K_Success;
  PWobjid sf, undoid;
  PWosnum os;
  struct GRevent event;
  enum EMSuser_responses useract;
  struct printdprtree_args print_args;
  FILE *outfile=NULL;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_PRINT_DPR_TREE)
    UI_message ("Z Print Feature Tree");
  else if (ME.super_cmd->mytype == CMD_UNDO_DPR_TREE)
    UI_message ("Z Undo Feature Tree");
  else
    UI_message ("Unknown command");

  do
    {
      switch (ME.super_cmd->state)
      {
        case LOCATE_STATE:
          stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                     &useract, response, response_data, "DPR/Feature object",
                     NULL, NULL, NULL, NULL, NULL),
                     targetid = my_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           wrapup);

          if (useract == EMSuser_data)
          {
            if (ME.super_cmd->mytype == CMD_PRINT_DPR_TREE)
              ME.super_cmd->state = GET_FILE_NAME_STATE;
            else if (ME.super_cmd->mytype == CMD_UNDO_DPR_TREE)
              ME.super_cmd->state = GET_UNDO_ID_STATE;
          }
          else 
          {
            goto wrapup;
          }
          break;

        case GET_FILE_NAME_STATE:
          if (!strlen (_outfile_name))
            strcpy (substr, "stderr");
          else
            strcpy (substr, _outfile_name);
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
                ME.ECdprtree->outfile = (char *) outfile;
                strcpy (_outfile_name, event.event.keyin);
                ME.super_cmd->state = PROCESS_STATE;
              }
              break;

            case EX_RJT_MOVEON:
              if (strlen (_outfile_name))
              {
                if (! (outfile = fopen (_outfile_name, "w")))
                {
                  sprintf (str, "Could not open %s", _outfile_name);
                  UI_status (str);
                  break;
                }
                else
                {
                  ME.ECdprtree->outfile = (char *) outfile;
                }
              }
              else
              {
                ME.ECdprtree->outfile = (char *) stderr;
              }
              ME.super_cmd->state = PROCESS_STATE;
              break;

            case EX_BACK_UP:
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;
              ME.super_cmd->state = LOCATE_STATE;
              break;
  
            default:
              goto wrapup;
          }
          break;

        case GET_UNDO_ID_STATE:
          UI_prompt ("Keyin objid to undo to / Moveon for undo-all");
          event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
          stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                       response = response, response_data = response_data,
                       event = &event);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
          UI_prompt ("");
          if (msg_loc == GRw_no_value)
            event.response = EX_RJT_MOVEON;
   
          switch (event.response)
          {
            case EX_VALUE:
              undoid = (PWobjid) event.event.value;
              os = ME.ECelements->active_md_env.md_id.osnum;

              if ((pwTopOwner (undoid, os) != 
                   ME.ECelements->elems[0].located_obj.objid) ||
                  !omIsAncestryValid (omClassidFromObjid (undoid, os), 
                   OPP_EMSdpr_class_id))
              {
                UI_status ("Invalid feature objid");
              }
              else
              {
                ME.ECdprtree->undoid = undoid;
                ME.super_cmd->state = PROCESS_STATE;
              }
              break;

            case EX_RJT_MOVEON:
              ME.ECdprtree->undoid = PW_K_NullObjid;
              ME.super_cmd->state = PROCESS_STATE;
              break;

            case EX_BACK_UP:
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;
              ME.super_cmd->state = LOCATE_STATE;
              break;

            default:
              goto wrapup;
          }
          break;

        case PROCESS_STATE:
          dp$erase_hilite (msg = &msg_loc);
          ME.ECelements->elems_hilit = FALSE;
  
          UI_status ("");
     
          sf = ME.ECelements->elems[0].located_obj.objid;
          os = ME.ECelements->active_md_env.md_id.osnum;
  
          if (ME.super_cmd->mytype == CMD_PRINT_DPR_TREE)
          {
            print_args.outfile = (FILE *) ME.ECdprtree->outfile;
            if (pwMaxTreeDepth (sf, os) > 50)
              print_args.print_with_spaces = FALSE;
            else
              print_args.print_with_spaces = TRUE;

            result = pwTraverseCSfCSfs (sf, os, FALSE, 
                      (PWresult (*)()) printdprtree, 
                      (void *) &print_args);
            if ((FILE *) ME.ECdprtree->outfile != stderr)
              fclose ((FILE *) ME.ECdprtree->outfile);
          }
          else if (ME.super_cmd->mytype == CMD_UNDO_DPR_TREE)
          {
            if (ME.ECdprtree->undoid == PW_K_NullObjid)
              result = pwUndoFeatureTree (sf, os, MAXINT, NULL, NULL);
            else
              result = pwUndoFeatTreeUntilObjid (sf, os, ME.ECdprtree->undoid,
                        NULL, NULL);
          }
          if (IsError (result))
          {
            UI_status ("Error in processing");
            sleep (1);
          }

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
  elig_classes->p_classes[0] = OPP_EMSdpr_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  if (ME.super_cmd->mytype == CMD_PRINT_DPR_TREE)
    *operation = EC_ATTR_READ;
  else if (ME.super_cmd->mytype == CMD_UNDO_DPR_TREE)
    *operation = EC_GEOM_CHGSHAPE;
  *options = EC_LOC_ASSOCOK | EC_LOC_EXTCONSTOK;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

/*--------------------------- STATIC FUNCTIONS --------------------------*/

PWresult printdprtree
(
  PWobjid csf,
  PWosnum os,
  void *args
)
{
  PWboolean print_with_spaces;
  char classname[PW_K_MaxStringLen]="", spaces[PW_K_MaxStringLen]="";
  int i, compinx, depth, num_comps;
  PWobjid compobj;
  FILE *outfile;

  outfile = ((struct printdprtree_args *) args)->outfile;
  print_with_spaces = ((struct printdprtree_args *) args)->print_with_spaces;

  if (omIsAncestryValid (
       omClassidFromObjid (csf, os), 
       OPP_EMSdpr_class_id))
  {
    depth = pwCompTreeDepth (csf, os);
    num_comps = pwNumCompsOfOwner (csf, os);

    if (print_with_spaces)
    {
      for (i=0; i<depth && i<PW_K_MaxStringLen-1; i++)
        strcat (spaces, " ");
      fprintf (outfile, "%s", spaces);
    }
 
    fprintf (outfile, "+ %3d %s [%d] (Num Ops = %d)\n", depth+1,
     omClassNameFromClassid (omClassidFromObjid (csf, os), os, classname), 
     csf, num_comps);

    for (compinx=0; compinx<num_comps; compinx++)
    {
      compobj = pwCompAtInxOfOwner (csf, os, compinx);
      if (!omIsAncestryValid (
           omClassidFromObjid (compobj, os),
           OPP_EMSdpr_class_id))
      {
        if (print_with_spaces)
        {
          strcpy (spaces, "");
          for (i=0; i<depth && i<PW_K_MaxStringLen-1; i++)
            strcat (spaces, " ");
          fprintf (outfile, "%s", spaces);
        }

        fprintf (outfile, "      %s [%d] (Inx = %d)\n", 
         omClassNameFromClassid (omClassidFromObjid (compobj, os), os,
          classname), compobj, compinx+1);
      }
    }

    fprintf (outfile, "\n");
  }

  return (PW_K_Success);
}

end implementation ECdprtree;
