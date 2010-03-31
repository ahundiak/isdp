/* ###################   APOGEE COMPILED   ################## */
class implementation ECmklps;

/*
HISTORY

06/01/92 Rustagi  Modified for Message Sub-system Compliance 
12 May 1989 jBk   Removed init and wakeup implementations.
07/05/93  Sudha   Modified for BSprototypes ansification
*/

#include "EMS.h"
#include <stdio.h>
#include "OMerrordef.h"
#include "EC_M.h"
#include "EC_S.h"
/* include "igemacros.h"*/
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */
/* include "grutildef.h"*/

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */
/* include "grvaluedef.h"*/

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */

#include "lcmacros.h"

/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "bsreadbsps.h"

#define MAKE_LPS        0

from GRgraphics import GRdisplay;
from GRvg import GRconstruct;
from EMSloopset import EMmakeFRT;

extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsfimpbnd_class_id;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar locate_prompt[MAX_PROMPT_SIZE], errmsg[EMMAXERRMSG_LEN];
  IGRchar relocate_prompt[MAX_PROMPT_SIZE];
  IGRint event_size, yes;
  IGRlong msg_loc, stat_OM, in_all_win;
  IGRlong event_mask1, event_mask2;
  struct GRevent accev;
  struct GRlc_locate lc_attr;
  enum GRdpmode dpmode;
  IGRint EMmakeloopset();
  OM_S_CHANSELECT to_loopset,to_surface;
  GRobjid lpset;
 OM_S_CLASSLIST rtree_classes, elig_classes;
 OMuword        rclass, eliclass[2];

  if(ME.super_cmd->mytype == MAKE_LPS)
    ex$message(msgnumb = EM_M_MakeSf)
  else 
    ex$message(msgnumb = EM_M_TstInsPol);

  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECmklps.execute");

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
          fflush(stdin);
          printf ("Build surface, Locate by objid, locate by data-pt?(0/1/2) ")
                ;
          scanf ("%d", &yes);

        if (yes == 0)
          {
          IGRchar filename[30];
          struct IGRbsp_surface srf;
          struct GRid           result_obj;
          struct GRvg_construct cnst_data;
          FILE *fileptr;

          printf ("Surface Filename _: ");
          scanf ("%s", filename);
          fileptr = fopen (filename, "r");
  
          ex$message(msgnumb = EMS_I_00003);
          ex$message(msgnumb = EMS_P_ClearPromptField); 

          srf.u_knots = NULL;
          srf.v_knots = NULL;
          srf.poles = NULL;
          srf.weights = NULL;
          srf.bdrys = NULL;
          if (! BSreadbsps (fileptr, &srf))
            fprintf (stderr, "Error in BSreadbsps\n");

          cnst_data.msg        = (IGRlong *)&msg_loc;
          cnst_data.geometry   = (IGRchar *)&srf;
          cnst_data.class_attr = NULL;  /* use defaults */
          cnst_data.env_info = &ME.ECelement->md_env;
          cnst_data.level = ME.ECelement->active_level;
          cnst_data.display = &ME.ECelement->active_display;
          cnst_data.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
          cnst_data.newflag    = FALSE;
          cnst_data.name       = NULL;

          stat_OM = om$construct(classname = "EMSbssubbs",
                   p_objid = &result_obj.objid, msg = message
                   GRvg.GRconstruct (&cnst_data));
          EMomerr_hndlr(stat_OM, ret_end, errmsg);
          result_obj.osnum = OM_Gw_current_OS;

          dpmode = GRbdhd;
          stat_OM = om$send(msg = message GRgraphics.GRdisplay
                    (&msg_loc, &ME.ECelement->elem.module_info.
                    md_env.matrix_type, ME.ECelement->elem.module_info.
                    md_env.matrix,
                    &dpmode, &ME.ECelement->md_env.md_id),
                    targetid = result_obj.objid, 
                    targetos = result_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
           errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

          ME.ECelement->elem_hilit = TRUE;
          ME.ECelement->elem.located_obj = result_obj;
          ME.ECelement->elem.module_info = ME.ECelement->md_env;
          ME.super_cmd->state = 1;
          }
        else
          {
          event_mask1 = GRm_DATA | GRm_BACK_UP;
          event_mask2 = GRm_DATA;
          in_all_win = 0x6;

          strcpy (lc_attr.classes, "EMSsubbs");
          ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);
          ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt); 

          lc_attr.properties = NULL;
          lc_attr.owner_action = 0x6;
          rtree_classes.w_count = 1;
          elig_classes.w_count = 2;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
          rclass = OPP_EMSsubbs_class_id;
          eliclass[0] = OPP_EMSsubbs_class_id;
          eliclass[1] = OPP_EMSsfimpbnd_class_id;

          rtree_classes.p_classes = &rclass;
          elig_classes.p_classes = &eliclass[0];

/*********************
          stat_func = GRlclocate (&msg_loc, &ME.ECelement->locev, &accev, 
                       &event_mask1,
                       &event_mask2, &event_size, &in_all_win, response,
                       response_data, locate_prompt, 
                       "Accept/reject", 
                       relocate_prompt, &lc_attr, &ME.ECelement->locate_stack,
                       NULL, NULL, NULL, NULL, NULL);
*******************/

      lc$locate(rc = &msg_loc, 
                event1 = &ME.ECelement->locev, 
                event2 = &accev,
                mask1 = event_mask1, 
                mask2 = event_mask2, 
                eventsize= &event_size, 
                display_flag = in_all_win,
                response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = "Accept/Reject",
                relocate_prompt = relocate_prompt, 
                attributes = &lc_attr, 
                stack = &ME.ECelement->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);


          ex$message(msgnumb = EMS_S_ClearStatusField);
          ex$message(msgnumb = EMS_P_ClearPromptField);
            {
            if (ME.ECelement->locev.response == EX_BACK_UP)
              break;
            else
              goto ret_end;
            }

/*  Removed unreachable code.
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
*/
          }
        break;  
   
      case 1:
        printf ("Located surface object is %d\n", 
            ME.ECelement->elem.located_obj.objid);
        if(ME.super_cmd->mytype == MAKE_LPS) 
           ex$message(msgnumb = EMS_S_MkLoopSet)
        dpmode = GRbehe;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                   &ME.ECelement->elem.module_info.md_env.matrix_type,
                   ME.ECelement->elem.module_info.md_env.matrix,
                   &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = ME.ECelement->elem.located_obj.objid, 
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
         errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
            errmsg);
        stat_OM = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
             errmsg);

        fflush(stdin);
        printf ("Attach Loopset? (1/0) ");
        scanf ("%d", &yes);
        if (yes)
         {
          stat_OM = EMmakeloopset (&msg_loc, &ME.ECelement->elem.module_info,
                        &lpset, ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
             errmsg);
          EMerr_hndlr (EMSerror (msg_loc), *response, TERMINATE, ret_end);

          stat_OM = om$send(msg=message Root.connect(to_surface,NULL,
                   ME.ECelement->elem.located_obj.objid,
                   ME.ECelement->elem.located_obj.osnum, 
                   to_loopset,NULL), targetid=lpset, 
                   targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
             errmsg);
          stat_OM = om$send(msg = message EMSloopset.EMmakeFRT
                         (&msg_loc, ME.ECelement->elem.located_obj.objid), 
                        targetid=lpset, 
                        targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
             errmsg);
          EMerr_hndlr (EMSerror (msg_loc), *response, TERMINATE, ret_end);

         }
        dpmode = GRbd;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                   &ME.ECelement->elem.module_info.md_env.matrix_type,
                   ME.ECelement->elem.module_info.md_env.matrix,
                   &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = ME.ECelement->elem.located_obj.objid, 
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto ret_end,
         errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        ME.super_cmd->state = 0;
        break;

      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  return (stat_OM);
}

end implementation ECmklps;

