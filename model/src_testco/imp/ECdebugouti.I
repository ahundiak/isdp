/* ###################   APOGEE COMPILED   ################## */
/*
 History

06/01/92 Rustagi Modified for Message Sub-system Compliance

22 May 1989 jBk Changed comment from referring to GRlclocate to
                refer to lc$locate.

10 May 1989 jBk Changed name from "Debug out" to "z debug out"
 01/08/88 : rlw : Rewritten to conform to ems verison 1.1.
 11/19/86 : jBk : Genesis.

 */

class implementation ECdebugout;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "EMSaction.h"
#include "EMSdpr.h"
#include "EC_M.h"
#include "EC_S.h"

#define START           0
#define GET_ELEMENT     1
#define DEBUG           2
#define MAXSIZE_PRODPATHNAME    200
#define MAXNUM_PRODPATHS        20
#define TEST_EXISTS             0
#define TEST_SUCCESS            0

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    return(OM_E_ABORT);\
   }\
 }

#include "ems_m_inc.h"

extern OMuword OPP_GRvg_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSedge_class_id;

from EMSsurface import EMfix_creator_id;

%safe
IGRboolean      EMSplotUVspace = FALSE;
%endsafe

method init(int type; char *str_ptr)
{

   ME.ECdebugout->locate_stack.num_entries = NULL;

   ME.ECdebugout->type = type;

 return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 IGRchar        locate_prompt[80], accept_prompt[80], relocate_prompt[80];
 OMuword        r_classes[5], e_classes[5];
 OM_S_CLASSLIST rtree_classes, eligible_classes;
 IGRlong        sts, msg;
 IGRlong        object_was_located, display_flag, locate_mask, accept_mask;
 struct         GRid *id;
 struct         GRlc_locate attributes;
 struct         GRevent event, accept_event;
 IGRchar        *argptr[4];
 IGRboolean     path_found;
 IGRchar        fullprocname[MAXSIZE_PRODPATHNAME+1], procname[20];
 IGRint         i;
 OMuint         count;
 OM_S_OBJECT_LINKAGE  loopset_list ;
 OM_S_CHANSELECT      to_loopset;

/*
 * Initialize
 */

 if (ME.ECdebugout->type == 0)
       ex$message(msgnumb = EM_M_ZdbgOut)
 else if (ME.ECdebugout->type == 2)
       ex$message(msgnumb = EM_M_ZdebOuteD)
 else if (ME.ECdebugout->type == 3)
       ex$message(msgnumb = EM_M_ZrSetCrID)
 else if (ME.ECdebugout->type == 4)
       ex$message(msgnumb = EM_M_ZValCrID)
 else
       ex$message(msgnumb = EM_M_DspUVsp);

/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {
/*
 * Room for growth
 */
     case START:
      me->state = GET_ELEMENT;
/*
 * Get the curve or surface
 */
     case GET_ELEMENT:
      ex$message(msgnumb = EMS_P_00033, buff=locate_prompt);
      ex$message(msgnumb = EMS_P_00038, buff=accept_prompt);
      ex$message(msgnumb = EMS_P_ElementNotFound, buff=relocate_prompt);
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
      accept_mask = GRm_DATA;
      display_flag = 
       ONE_WINDOW               |       /* Hilite in only one window */
       ELEM_HILIGHT             |       /* Hilite the whole element */
       NO_PROJ_ACCEPT_POINT     |       /* Don't project the accept point */
       ACC_REJ_CYCLE            |       /* Run through accept reject cycle */
       RELOCATE                 |       /* Relocate if none found */
       LC_REGULAR_HIGHLIGHT     |       /* Use regular hilite not 1/2 */
       LC_ERASE_ALL;                    /* Erase hilite on reject */
      attributes.properties = 
       LC_LC_ONLY               |       /* Locate locatable objects */
       LC_DP_ONLY               |       /* Locate displayable objects */
       IGN_MOD_BIT              |       /* Ignore modified and new props */
       LC_PLANAR_NON_PLANAR     |       /* Planar or not */
       LC_RW;                           /* This is a read operation */
  if (me->type == 0 || me->type == 3 || me->type == 4)
      attributes.owner_action = 
       LC_RIGID_OWNER |
       LC_RIGID_COMP  |
       LC_FLEX_OWNER  |
       LC_FLEX_COMP   |
       LC_REF_OBJECTS |                 /* Objects in ref. files are O.K. */
       LC_NO_REF_HEADER|                /* No reference file headers */
       LC_HANDLES;
  else if (me->type == 2)
       attributes.owner_action = LC_RIGID_COMP  |
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS |
                                 LC_NO_REF_HEADER;
  else
      attributes.owner_action = 
       LC_RIGID_COMP  |
       LC_FLEX_COMP   |
       LC_REF_OBJECTS |                 /* Objects in ref. files are O.K. */
       LC_NO_REF_HEADER;                /* No reference file headers */

  if (me->type == 0 || me->type == 3 || me->type == 4)
  {
      strcpy(attributes.classes, "EMSsurface");
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      r_classes[0] = OPP_GRvg_class_id;
      eligible_classes.w_count = 1;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      e_classes[0] = OPP_GRvg_class_id;
  }
  else if (me->type == 2)  
  {
      strcpy(attributes.classes, "EMSsurface");
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      r_classes[0] = OPP_GRvg_class_id;
      eligible_classes.w_count = 1;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      e_classes[0] = OPP_EMSedge_class_id;
  }
  else
     {
      strcpy(attributes.classes, "EMSsubbs");
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      r_classes[0] = OPP_EMSsubbs_class_id;
      eligible_classes.w_count = 1;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      e_classes[0] = OPP_EMSsubbs_class_id;
      }

      sts = lc$locate(
        rc =                    &object_was_located,
        event1 =                &event,
        event2 =                &accept_event,
        mask1 =                 locate_mask,
        mask2 =                 accept_mask,
        display_flag =          display_flag,
        unhilight_mode =        (enum GRdpmode ) GRhd,  /* Don't unhilite */
        locate_prompt =         locate_prompt,
        acc_prompt =            accept_prompt,
        relocate_prompt =       relocate_prompt,
        attributes =            &attributes,
        stack =                 &me->locate_stack,
        rtree_classes =         &rtree_classes,
        eligible_classes =      &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      if (!object_was_located)
       {
        if (event.response == EX_BACK_UP)
         me->state = START;
        else
         return(OM_S_SUCCESS);
       }
      else
       me->state = DEBUG;
      break;
/*
 * Debug the sucker
 */
     case DEBUG:
      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_S_ClearStatusField);
      sts = dp$erase_hilite(msg = &msg);
       ERROR(sts, msg, "dp$erase_hilite error")
      id = &accept_event.located_object[0].located_obj;

   if (me->type == 1)
     {
      EMSplotUVspace = TRUE;

      sts = om$make_chanselect(
            channame = "EMSsubbs.to_loopset",
            p_chanselect = &to_loopset);

      sts = om$get_channel_objects(
              osnum = id->osnum,
              objid = id->objid,
              p_chanselect = &to_loopset,
              list  = &loopset_list,
              size  = 1,
              count = &count );                                       

      sts = om$send(
       msg = message Root.debug(),
       targetid = loopset_list.S_objid,
       targetos = loopset_list.osnum);

      strcpy (procname, "/bin/graph");
      path_found = FALSE;
       for (i=0; i<MAXNUM_PRODPATHS && !path_found; i++)
        {
          path_found = ex$get_path(index = i, path = fullprocname,
                  len = MAXSIZE_PRODPATHNAME - strlen (procname),
                  type = EX_PRODUCT_PATH);
         if (path_found)
         {
          strcat (fullprocname, procname);
          if (access (fullprocname, TEST_EXISTS) == TEST_SUCCESS)
            break;
          else
            path_found = FALSE;
         }
        }

     if (!path_found)
      {
       ex$message(msgnumb = EMS_S_ExecImNtFnd);
       ems_sleep (2);
       }

        argptr[0] = fullprocname;
        argptr[1] = "-uv";
        argptr[2] = "/tmp/uvplot";

        ex$fork(num_entry = 3, argu = argptr);

        EMSplotUVspace = FALSE;
      }

  else if (me->type == 3)
  {
    sts = om$send(msg = message EMSsurface.EMfix_creator_id(&msg,
                        NULL, NULL_OBJID, NULL),
                  targetid = id->objid,
                  targetos = id->osnum);
  }
  else if (me->type == 4)
  {
    ex$message(msgnumb = EMS_S_ValCrID);
    sts = om$send(msg = message EMSsurface.EMfix_creator_id(&msg,
                        NULL, NULL, EMfix_cr_id_VALIDATE),
                  targetid = id->objid,
                  targetos = id->osnum);
    ex$message(msgnumb = EMS_S_ValComp);
  }
  else
  {
    sts = om$send(msg = message Root.debug(),
                  targetid = id->objid,
                  targetos = id->osnum);
  }

     me->state = START;
     break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
}

end implementation ECdebugout;
