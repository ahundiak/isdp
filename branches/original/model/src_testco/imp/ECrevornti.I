/* ###################   APOGEE COMPILED   ################## */
class implementation ECrevornt;

/*
HISTORY

19 May 1989 jBk Changed reference of GRlclocate to lc$locate.

12 May 1989 jBk Removed init and wakeup implementations.
*/

# include <stdio.h>
# include "OMmacros.h"
# include "OMerrordef.h"
# include "grdpbmacros.h" /* gr$get_active_display */
# include "griodef.h"
# include "igrdef.h"
# include "codef.h"
# include "msdef.h"
# include "msmacros.h"  /* ex$message */
# include "lcdef.h"     /* lcmacros.h */
# include "lcmacros.h"  /* lc$locate */
# include "emsdef.h"
# include "emserr.h"
# include "bserr.h"
# include "bsparameters.h" 
# include "emssfintdef.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "EMS_M.h"
# include "EMS_P.h"
# include "EMS_I.h"
# include "EMS_F.h"

from GRgraphics import GRdisplay;
from EMSsurface import EMrevorient;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint event_size;
  IGRlong msg_loc, stat_OM, in_all_win;
  IGRlong event_mask1, event_mask2;
  struct GRevent accev;
  struct GRlc_locate lc_attr;
  enum GRdpmode dpmode;

  ex$message (msgnumb = EM_M_RevSfOrient);

  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECrevornt.execute");

  do 
    {
    switch (ME.super_cmd->state)
      {
      case 0:
        if (ME.ECelement->elem_hilit)
          {
          dpmode = GRbdhe;
          stat_OM = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdisplay
                     (&msg_loc, &ME.ECelement->elem.module_info.
                     md_env.matrix_type, ME.ECelement->elem.module_info.
                     md_env.matrix,
                     &dpmode, &ME.ECelement->md_env.md_id),
                            senderid = my_id,
                            targetid = ME.ECelement->elem.located_obj.objid,
                            targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
           errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
          }

        event_mask1 = GRm_DATA | GRm_RESET;
        event_mask2 = GRm_DATA;
        in_all_win = 0x4;

        strcpy (lc_attr.classes, "EMSsurface");
/*
        strcpy (locate_prompt, "Identify surface 1");
        strcpy (relocate_prompt, "Surface not found");
*/
        lc_attr.properties = NULL;
        lc_attr.owner_action = 0xf;
/*
        stat_func = GRlclocate (&msg_loc, &ME.ECelement->locev, &accev, 
                     &event_mask1,
                     &event_mask2, &event_size, &in_all_win, response,
                     response_data, locate_prompt, 
                     "Accept/reject", 
                     relocate_prompt, &lc_attr, &ME.ECelement->locate_stack,
                     NULL, NULL, NULL, NULL, NULL);
*/
        stat_func = lc$locate (
            rc = &msg_loc,
            event1 = &ME.ECelement->locev,
            event2 = &accev, 
            mask1 = GRm_DATA,
            mask2 = GRm_DATA,
            eventsize = &event_size,
            display_flag = NO_PROJ_ACCEPT_POINT | ALL_WINDOWS,
            response = response,
            response_data = response_data,
            locate_key = EMS_P_00031,
            acc_key = EMS_P_00038,
            relocate_key = EMS_I_00011,
            attributes = &lc_attr,
            stack = &ME.ECelement->locate_stack
        );

        ex$message (msgnumb = EMS_I_ClearStatusField);
        ex$message (msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE)
          {
            ex$message (msgnumb = EMS_F_LocFailExitCommand);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == RESET)
            break;
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case DATA:
            ME.ECelement->elem_hilit = TRUE;

            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            ME.ECelement->elem.module_info = accev.located_object[0].
                                         module_info;

            ME.super_cmd->state = 1;
            break;               
          default:
            goto ret_end;
          }
        break;  
   
      case 1:
        ex$message (msgnumb = EMS_I_Processing);

        dpmode = GRbdhe;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay
                   (&msg_loc, &ME.ECelement->elem.module_info.
                   md_env.matrix_type, ME.ECelement->elem.module_info.
                   md_env.matrix, &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
         errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        stat_OM = om$send (msg = message EMSsurface.EMrevorient (&msg_loc),
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
         errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
     
        ex$message (msgnumb = EMS_I_ClearStatusField);
        ME.super_cmd->state = 0;
        break;

      default:
        ex$message (msgnumb = EMS_F_CommandIllegalState);
        printf ("Command in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  return (stat_OM);
}

end implementation ECrevornt;

