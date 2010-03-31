/* ###################   APOGEE COMPILED   ################## */
class implementation ECconstrain;

/*
HISTORY

05/26/92 Rustagi Modified for Message Sub-system Compliance  
10/05/91    DLB Added & to event_size in lc$locate.
19 May 1989 jBk Changed references of GRgetevent to co$getevent.

11 May 1989 jBk Enhanced wakeup to send to parent.
*/

#include "EMS.h"
#include "OMmacros.h"
#include "griomacros.h" /* co$getevent */
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "EC_M.h"
#include "EC_P.h"

#define X 0
#define Y 1
#define Z 2

#define ALONG_CURVE     0
#define ALONG_LINE      1
#define ALONG_ZDEPTH    2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRbspline_class_id;

method wakeup (IGRint pos)
{
  IGRlong msg_loc;
  IGRshort mytype;
  IGRdouble *pt;
  IGRlong ECdisplayPointSetByBuffer();

  mytype = ME.super_cmd->mytype;

  ex$message(msgnumb = EMS_P_ClearPromptField);
  if (mytype == ALONG_CURVE)
    ex$message(msgnumb = EM_M_CnstCurAlCrve)
  else if (mytype == ALONG_ZDEPTH)
    ex$message(msgnumb = EM_M_CnstCurAlZdpt)
  else if (mytype == ALONG_LINE)
    {
    ex$message(msgnumb = EM_M_CnstCurLine);
    if (ME.super_cmd->state == 1)
      {
      pt = ME.ECconstrain->point;
      ECdisplayPointSetByBuffer0 (&msg_loc, ME.ECelement->active_display,
       ME.ECelement->md_env, my_id, 1, &pt, FALSE);
      }
    }

    return om$send (
        mode = OM_e_wrt_parent,
        msg = message ECconstrain.wakeup (pos),
        targetid = my_id
    );
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean kill_cmd;
  IGRshort mytype, state;
  IGRlong stat_func;
  IGRint event_size;
  IGRlong stat_OM, msg_loc;
  IGRlong window_disp, event_mask1, event_mask2;
  OMuword rclass, eliclass;
  struct GRid locobj;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  struct IGRbsp_curve *crv;
  struct GRmdenv_info *mdenv_info;
  enum EMSdatatype datatype;
  OM_S_CLASSLIST rtree_classes, elig_classes;
  IGRboolean EMconstrain_ptoncrv();
  IGRboolean EMconstrain_ptonline();
  IGRboolean EMconstrain_ptzdepth();
  IGRint EMgetvggeom();
  IGRchar locate_prompt[52], accept_prompt[52], relocate_prompt[52], prompt[52];

  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  kill_cmd = FALSE;

  mytype = ME.super_cmd->mytype;
  state = ME.super_cmd->state;
  event_size = sizeof (struct GRevent);
  crv = NULL;

  if (mytype == ALONG_CURVE)
    {
    event_mask1 = GRm_DATA | GRm_BACK_UP;
    event_mask2 = GRm_DATA;

    window_disp = ELEM_HILIGHT;

    ex$message(msgnumb = EMS_P_IdCvEle, buff = locate_prompt);
    ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
    ex$message(msgnumb = EMS_S_CurEleNotFound, buff = relocate_prompt);

    strcpy (lc_attr.classes, "GRbspline");
    lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
    lc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS |
                            LC_NO_REF_HEADER;
    
    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;
    rclass = OPP_GRbspline_class_id;
    eliclass = OPP_GRbspline_class_id;

/****
DLB 10/5/91	Added & to event_size.  Crash on SUN.
****/

    lc$locate (rc = &msg_loc, event1 = &ME.ECelement->locev,
               event2 = &accev, mask1 = event_mask1, mask2 = event_mask2,
               eventsize = &event_size, display_flag = window_disp,
               response = response, response_data = response_data,
               locate_prompt = locate_prompt,
               acc_prompt = accept_prompt,
               relocate_prompt = relocate_prompt,
               attributes = &lc_attr, stack = &ME.ECelement->locate_stack,
               rtree_classes = &rtree_classes, 
               eligible_classes = &elig_classes);
    ex$message(msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if (msg_loc == LC_OBJ_LOCATED)
      {
      locobj = accev.located_object[0].located_obj;
      mdenv_info = &accev.located_object[0].module_info.md_env;  
      stat_OM = EMgetvggeom (&msg_loc, &mdenv_info->matrix_type,
                 mdenv_info->matrix, &locobj, &crv, &datatype);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

      stat_func = EMconstrain_ptoncrv (crv);
      EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
      kill_cmd = TRUE;
      }
    }

  else if (ME.super_cmd->mytype == ALONG_LINE)
    {
    switch (state)
      {
      case 0:
/*
        event_mask = GRm_DATA;

        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                     response, response_data);
*/
        ex$message(msgnumb = EMS_P_InpFirPtDefLn, buff = prompt);
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
        ));

        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (event.response == EX_DATA)
          {
          OM_BLOCK_MOVE (&event.event.button.x, ME.ECconstrain->point,
           3 * sizeof (IGRdouble));
          ME.super_cmd->state = 1;
          }
        else
          break;

      case 1:
/*
        event_mask = GRm_DATA | GRm_BACK_UP;

        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                     response, response_data);
*/
        ex$message(msgnumb = EMS_P_InpSecPtDefLn, buff = prompt);
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
        ));

        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (event.response == EX_DATA)
          {
          stat_func = EMconstrain_ptonline (ME.ECconstrain->point,
                       &event.event.button.x);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

          kill_cmd = TRUE;
          }
        else if (event.response == EX_BACK_UP)
          ME.super_cmd->state = 0;
        break;
      }
    }

  else if (ME.super_cmd->mytype == ALONG_ZDEPTH)
    {
/*
    event_mask = GRm_DATA;

    stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                 response, response_data);
*/
    ex$message(msgnumb = EMS_P_InpZdptPnt, buff = prompt);

        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
        ));

    EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

    ex$message(msgnumb = EMS_P_ClearPromptField);
    if (event.response == EX_DATA)
      {
      stat_func = EMconstrain_ptzdepth (&event.event.button.x);
      EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

      kill_cmd = TRUE;
      }
    }

ret_end:
  if (crv)
    om$dealloc (ptr = crv);

  if (EMSerror (stat_OM & msg_loc) || kill_cmd)
    *response = TERMINATE;
  stat_func = TRUE;
  EMWRAPUP (stat_func, stat_OM, "ECconstrain.execute");
  return (stat_OM);
}

end implementation ECconstrain;

