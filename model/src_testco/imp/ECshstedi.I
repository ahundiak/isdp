/* ###################   APOGEE COMPILED   ################## */
class implementation ECshsted;

/*
HISTORY

06/01/92 Rustagi Modified for Message Sub-system Compliance.
15 May 1989 jBk Removed init, wakeup and sleep implementations.
*/

#include "EMS.h"
#include "OMerrordef.h"
#include "EC_M.h"
#include "EC_P.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSopt.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"

#define X 0
#define Y 1
#define Z 2


extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;


from GRgraphics import GRdisplay;
from EMSsurface import EMdisplay_edges;



method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54], stat_str[54];
  IGRint event_size, display_flag;
  IGRlong stat_OM, msg_loc;
  IGRlong event_mask1, event_mask2;
  struct GRevent accev;
  struct GRlc_locate lc_attr;
  enum GRdpmode dpmode;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  IGRint                num_sti_edges = 0;

 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECshsted.execute");

  ex$message(msgnumb = EM_M_ShStEd);

  do 
    {
    switch (ME.super_cmd->state)
      {
      case 0:
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
      ex$message(msgnumb = EMS_P_00031, buff=loc_prompt);
    display_flag = 6;

    ex$message(msgnumb = EMS_P_00038, buff=acc_prompt);
    ex$message(msgnumb = EMS_I_00011, buff=reloc_prompt);
    lc_attr.properties = 0x11;
    lc_attr.owner_action = 0x7;
    strcpy(lc_attr.classes, "EMSsurface");

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsurface_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelement->locev, 
              event2 = &accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &lc_attr, 
              stack = &ME.ECelement->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

        ex$message(msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            me->mod_info = accev.located_object[0].module_info;

            ME.super_cmd->state = 1;
            break;
          default:
            goto ret_end;
          }
        break;

      case 1:
        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_00003);

        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        dpmode = GRhd;
        num_sti_edges = 0;
        stat_OM = om$send(msg = message EMSsurface.EMdisplay_edges(&msg_loc,
                            &me->mod_info,
                            EMS_OPT_CONNECTABLE,
                            dpmode,
                            &num_sti_edges),
                       targetid = ME.ECelement->elem.located_obj.objid,
                       targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        ex$message(msgnumb = EMS_S_StitEdsDspl, buff = stat_str, 
                   type ="%d", var = `num_sti_edges`);
	ex$message(field = ERROR_FIELD, in_buff = stat_str);
                  
        ME.super_cmd->state = 0;
        break;

      default:
        
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:

  /*
    Sleep message implementation always performed the
    dp$erase_hilite.  To obviate need for override, I do it here.
    -- jBk 15 May 1989
  */
  {
    IGRlong dpehrc;

    dp$erase_hilite (msg = &dpehrc);
  }

  return (stat_OM);
}

end implementation ECshsted;
