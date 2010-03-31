class implementation ECpost31;

#include "EMSprop.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/clsid.h"
#include "PWapi/sfdntrav.h"
#include "PWapi/featquery.h"

#define CMD_SET_POST31		0
#define CMD_UNSET_POST31	1
#define CMD_GET_FEATURE_ID	2
#define CMD_GET_OBJECT_ID	3

#define LOCATE_STATE		0
#define PROCESS_STATE		1

%safe
static PWresult chgpost31
(
  PWobjid,
  PWosnum,
  void *
);
%endsafe

extern GRclassid OPP_GRgraphics_class_id;
extern GRclassid OPP_EMSsubbs_class_id, OPP_EMSsurface_class_id;
extern GRclassid OPP_EMSdpr_class_id;

from EMSdpr import EMsetprops;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  PWboolean set_flag;
  char str[PW_K_MaxCharOnLine];
  long msg_loc, stat_OM;
  PWresult result=PW_K_Success;
  PWobjid elem;
  PWosnum os;
  enum EMSuser_responses useract;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_SET_POST31)
    UI_message ("Set Post 3.1 Behaviour");
  else if (ME.super_cmd->mytype == CMD_UNSET_POST31)
    UI_message ("Unset Post 3.1 Behaviour");
  else if (ME.super_cmd->mytype == CMD_GET_FEATURE_ID)
    UI_message ("Get Feature Id");
  else if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID)
    UI_message ("Get Object Id");
  else
    UI_message ("Unknown command");

  do
    {
      switch (ME.super_cmd->state)
      {
        case LOCATE_STATE:
          if (ME.super_cmd->mytype == CMD_GET_FEATURE_ID)
            strcpy (str, "Surface Of Feature");
          else if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID)
            strcpy (str, "Element");
          else
            strcpy (str, "Recomputable Surface");

          stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                     &useract, response, response_data, str,
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
     
        elem = ME.ECelements->elems[0].located_obj.objid;
        os = ME.ECelements->active_md_env.md_id.osnum;

        if (ME.super_cmd->mytype == CMD_GET_FEATURE_ID)
        {
          if ((elem = pwFeatureIdFromSf (elem, os)) == PW_K_NullObjid)
          {
            UI_status ("Feature could not be found");
          }
          else
          {
            EMdbgdisp (elem, os, 0);
            sprintf (str, "Feature Id = %d,  [OS = %d]", elem, os);
            UI_status (str);
          }
        }
        else if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID)
        {
          sprintf (str, "Element Id = %d,  [OS = %d]", elem, os);
          UI_status (str);
        }
        else
        {
          set_flag = ME.super_cmd->mytype == CMD_SET_POST31 ? TRUE : FALSE;
          result = pwTraverseCSfCSfs (elem, os, TRUE, 
                    (PWresult (*)()) chgpost31, (void *) &set_flag);
          if (IsError (result))
          {
            UI_status ("Error in processing");
            sleep (2);
          }
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
  if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID)
    rtree_classes->p_classes[0] = OPP_GRgraphics_class_id;
  else
    rtree_classes->p_classes[0] = OPP_EMSsubbs_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID)
    elig_classes->p_classes[0] = OPP_GRgraphics_class_id;
  else if (ME.super_cmd->mytype == CMD_GET_FEATURE_ID)
    elig_classes->p_classes[0] = OPP_EMSsubbs_class_id;
  else
    elig_classes->p_classes[0] = OPP_EMSdpr_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  if (ME.super_cmd->mytype == CMD_GET_OBJECT_ID ||
      ME.super_cmd->mytype == CMD_GET_FEATURE_ID)
    *operation = EC_ATTR_READ;
  else
    *operation = EC_ATTR_WRITE;
  *options = NULL;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

/*--------------------------- STATIC FUNCTIONS --------------------------*/

PWresult chgpost31
(
  PWobjid csf,
  PWosnum os,
  void *args
)
{
  char classname[PW_K_MaxStringLen];
  PWboolean action;
  unsigned short newprop=EMS_POST310_OBJECT;
  long msg_loc;

  if (omIsAncestryValid (omClassidFromObjid (csf, os), OPP_EMSdpr_class_id))
  {
    action = *((PWboolean *) args);
    om$send (msg = message EMSdpr.EMsetprops (&msg_loc, &action, &newprop),
     targetid = csf, targetos = os, senderid = NULL_OBJID);

    pwDebugLine (PW_K_DebugTrace, "%d [ %s ] Post-310 -- %d \n", csf,
     omClassNameFromClassid (omClassidFromObjid (csf, os), os, classname),
     action);
  }

  return (PW_K_Success);
}

end implementation ECpost31;
