/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

/*
HISTORY

6/02/92 Rustagi Modified for Message Sub-system Compliance
22 May 1989 jBk Changed GRm_STRING mask to GRm_TEXT_VALUE.

                Changed GRgetevent to co$getevent.  Made
                corresponding changes to type of stat_func and
                error checks.
*/

#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "griodef.h"
#include "exdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "msmacros.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "ECprepsf.h"
# include "griomacros.h" /* co$getevent */
#include "EC_P.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;


IGRint ECprepsurf(msg, mdenv, display, sfid, event, event_mask,
                  response, response_data, changes)
IGRlong           *msg;
struct GRmd_env   *mdenv;
struct IGRdisplay *display;
struct GRid       sfid;
IGRlong           event_mask;
struct GRevent    *event;
IGRint            *response;
IGRchar           *response_data;
IGRushort *changes;
{
/*  IGRboolean      stat_func;*/
  EMSrc           stat_func;
  IGRint          event_size;
  OMuint          loopset_count;
  IGRlong         event_msg, msg_loc, stat_OM;
  GRclassid       sfid_class;
  OM_S_CHANSELECT chan_to_loopset;
  
  *msg = EMS_I_NoResponse;
  stat_OM = OM_S_SUCCESS;

  *changes = NULL;

  /*
   * If this is a single surface without a loopset, put a natural
   * loop on it.
   */

  stat_OM = om$get_classid (objid = sfid.objid, 
                            osnum = sfid.osnum,
                            p_classid = &sfid_class);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$is_ancestry_valid (subclassid = sfid_class,
                                  superclassid = OPP_EMSsubbs_class_id);
  if (stat_OM == OM_S_SUCCESS)
  {
    stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = sfid.objid, osnum = sfid.osnum,
                                    p_chanselect = &chan_to_loopset, 
                                    count = &loopset_count);
    EMomerr_exit (stat_OM, ret_end);

    if (! loopset_count)
    {
      stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg_loc,
                               &mdenv->md_env, NULL), 
                         targetid = sfid.objid, targetos = sfid.osnum,
                         senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  
      *changes |= EMS_SURF_NATLOOP_ADDED;
    }
  }

  /*
   * Ask user if the current orientation is good enough. If not
   * reverse the orientation.
   */

  stat_OM = om$is_ancestry_valid (subclassid = sfid_class,
                                  superclassid = OPP_EMSsolid_class_id);
  if (stat_OM != OM_S_SUCCESS)
  {
    stat_OM = om$send (msg = message EMSsurface.EMshow_normals (&msg_loc,
                             mdenv, display, GRhd), 
                       targetid = sfid.objid,
                       targetos = sfid.osnum, senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

    event_size = sizeof (struct GRevent);
/*
    ex$message(msgnumb = EMS_P_CorrectSurfOrnt);
*/
    event_mask |= (GRm_TEXT_VALUE | GRm_RJT_MOVEON);
/*
    stat_func = GRgetevent (&event_msg, &event_mask, &event_size, event,
                            response, response_data);
*/
    stat_func = co$getevent (
        msg = &event_msg,
        event_mask = event_mask,
        prompt = "Is surface orientation correct? y/n [y]",
        response = response,
        response_data = response_data,
        event = event
    );

    ex$message(msgnumb = EMS_P_ClearPromptField);
    *msg = EMS_S_Success;
    
    if (stat_OM != OM_I_STOP_SENDING)
      {
      stat_OM = om$send (msg = message EMSsurface.EMshow_normals (&msg_loc,
                 mdenv, display, GRhe), targetid = sfid.objid,
                 targetos = sfid.osnum, senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
      }
  
    if (stat_func == MSFAIL)
      {
      ex$message(msgnumb = EMS_E_FailProcExit);
      *response = TERMINATE;
      goto ret_end;
      }
  
    if (event_msg != MSSUCC)
      goto ret_end;
  

    if (event->response == STRING)
    {
      if (toupper (event->event.keyin[0]) == 'N')
      {
        stat_OM = om$send (msg = message EMSsurface.EMrevorient (&msg_loc),
                           targetid = sfid.objid, targetos = sfid.osnum,
                           senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  
        *changes |= EMS_SURF_ORIENT_REVERSED;
      }
    }
    else if (event->response == EX_RJT_MOVEON) 
    {
      event->response = STRING;
      event->event.keyin[0] = '\0';
    }
  }

  ret_end:
    EMWRAPUP (*msg, stat_OM, "ECprepsurf");
    return (stat_OM);
}
end implementation EMSsurface;
