/* ###################   APOGEE COMPILED   ################## */
/* 
Description
   This command object splits a surface given the direction to split in
   and an array of parameters at which to split the surface

Algorithm
   Identify a surface and accept with the first point at which to split.
   Display an isoparametric curve in the u direction. If it is accepted, 
   then keep asking for points until the user gives a MOVEON.  If it is  
   not accepted, then display an isoparametric curve in the v direction.
   If v direction curve is accepted, then keep asking for points until
   the user gives a EX_RJT_MOVEON.

Return values
   Returns an OM_S_SUCCESS  if successful and returns an OM_E_ABORT
   if it fails. On a failure, response is set to TERMINATE.

History
    dfh   04/15/87:  creation date
    gupta 04/16/87:  completion date
    DLB   05/21/87:  added re-execute code.
    DLB   02/29/88:  complete rewrite to reduce complexity and code size.
    DLB   08/16/88:  modified recompute code.
    rlw   11/28/88:  modified due to changes in the iso curve extract method
    rlw   01/17/89   modified to locate flexible components
    NP    07/21/92:  Updated for message subsystem compliance
*/

class implementation ECsplit;

#include "EMS.h"
#include <stdio.h>
#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdfh.h"
#include "lcmacros.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h" /* gr$put_last_point */
#include "exmacros.h"
#include "msmacros.h" /* ex$message */
#include "ECcmd.h"
#include "ECmsg.h"


from GRgraphics import GRdisplay, GRdelete, GRgetprops, GRlnproject;
from EMSsurface import EMsplit_surface;
from EMSsurface import EMlmsplit;
from EMSsurface import EMgetactiveid;
from EMSsubbs   import EMisoparcvs;
from EMSdpr     import EMdeactivate;
from EMSsfdpr   import EMadd;

extern OMuword OPP_EMSsflm_class_id, OPP_EMSsurface_class_id,
               OPP_EMSlift_class_id, OPP_EMSsfimpbnd_class_id,
               OPP_EMSsfmkface_class_id, OPP_EMSsfround_class_id;

#define SURFACE 1
#define SOLID 2
#define U 0
#define V 1

#ifndef DEBUG
#define DEBUG 0  /*Set to 1 if want error strings printed.*/
#endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message, label)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
            EMSmsgReport (error_number, error_message, FALSE)) \
            goto label; \
 }
#else
#define ERROR(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid & error_number)) goto label;\
 }
#endif


method wakeup(int pos)
{
 IGRint status = OM_S_SUCCESS;
 IGRlong msg;
 struct GRid top_id, active_id, *active_state;
 enum GRdpmode DisplayMode;

 if (ME.super_cmd->mytype == SURFACE)
 {
   ex$message(msgnumb = EM_M_SplitSurface);
 }
 else if (ME.super_cmd->mytype == SOLID)
 {
   ex$message(msgnumb = EM_M_SplitFace);
 }

 if (me->top_lm_active)
 {
    /*Get the active solid id from the state tree*/
    status = om$send (msg = message EMSsurface.EMgetactiveid (
                            &msg, &active_id, &top_id),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(status, msg, "wake, getactiveid error", quit);

    if ((me->top_lm_GRid.objid != top_id.objid) ||
        (me->active_state_GRid.objid != active_id.objid))
    {
      ex$message(msgnumb = EMS_S_ModInfCrpt);
      ERROR(OM_E_ABORT, EMS_E_Fail, "wake", quit);     
    }

    me->num_states = 0;
    active_state = NULL;

    status = EFundo_to_lm(&msg, &me->surf_info.located_obj,
                           &me->top_lm_GRid, 
                           &me->active_state_GRid,
                           &me->surf_info.module_info, &me->num_states,
                           &active_state);
    ERROR(status, msg, "wake, EFundo_to_lm", quit);  

    if (active_state) om$dealloc(ptr = active_state);

 } /*End if active and top lm different*/

 if (me->obj_hilited)
 {
    DisplayMode = GRhd;
    status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->surf_info.module_info.md_env.matrix_type,
                           me->surf_info.module_info.md_env.matrix,
                           &DisplayMode, &me->surf_info.module_info.md_id),
                     targetid = me->surf_info.located_obj.objid,
                     targetos = me->surf_info.located_obj.osnum);
    ERROR(status, msg, "wakeup, display", quit);

    if (me->iso_displayed)
    {
      DisplayMode = GRhd;
      status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                       targetid = me->isocrv_id,
                       targetos = me->surf_info.located_obj.osnum);
      ERROR(status, msg, "wakeup, display", quit);
    }
 }

 quit:
  return(status);
}


method sleep(int pos)
{
 IGRint status=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_I_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);

 if ( (me->obj_hilited && !me->top_lm_active) || me->iso_displayed)
 {
    status = dp$erase_hilite(msg = &msg);
    ERROR(status, msg, "sleep, erase_hilite", quit);
 }

 if (me->top_lm_active)
 {
   status = EFredo_to_top(&msg, &me->active_state_GRid,
                          &me->surf_info.module_info, &me->num_states,
                          me->state_list);
   ERROR(status, msg, "sleep, EFredo_to_top", quit);
 }

 quit:
  return(status);
}


method delete(int f_defer_flag)
{
  IGRlong status=OM_S_SUCCESS;
 
  if (me->isocrv_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(NULL),
                     targetid = me->isocrv_id,
                     targetos = me->surf_info.located_obj.osnum);
    ERROR(status, EMS_S_Success, "delete, GRgetprops", quit);            
  }

  status = om$send(mode = OM_e_wrt_message,
                   msg = message COconst.delete(NULL),
                   targetid = my_id); 
  ERROR(status, EMS_S_Success, "delete, GRgetprops", quit);  

 quit:
  return(status);
}


method execute(int *response; char *response_data; int pos)
{
 IGRlong            status=OM_S_SUCCESS, 
                    bytes_in=sizeof(struct EX_button),
                    msg,
                    size=sizeof(struct GRevent);
 IGRint             qsize=sizeof(me->event.event), token = 0,
                    locate_mask, accept_mask, display_flag, i;
 enum GRdpmode      DisplayMode;
 struct GRlc_locate attributes;
 struct GRvg_construct  construct_list;
 struct GRid        *active_state;
 struct GRevent     event2;
 OM_S_CLASSLIST     rtree_classes, elig_classes;
 OMuword            rclass, eliclass;
 IGRushort          add_option;
 IGRboolean         continue_flag, gothru=FALSE;
 IGRchar            locate_prompt[52],accept_prompt[52],relocate_prompt[52];

 

#define NUM_TOKENS 4
 static int tokens[NUM_TOKENS] = 
 {
   EX_BACK_UP, DATA, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

#define NUM_STATES 5
 enum states
 {
   start, got_sf, got_pt, got_dir, acc_rjt
 };

 enum actions
 {
   NIL, ERR, init, store_sf, rem_sf, store_pt, rem_pt, store_dir, split_sf,
   undo, add_to_tree
 };


 static enum states next_state[NUM_STATES][NUM_TOKENS] = 
 {
 /*token:      BACK_UP  DATA     MOVEON   UNK
 old state:*/
 /*start   */ {start,   got_sf,  start,   start  },
 /*got_sf  */ {start,   got_pt,  got_sf,  got_sf },
 /*got_pt  */ {got_sf,  got_dir, got_dir, got_pt },
 /*got_dir */ {got_dir, got_dir, acc_rjt, got_dir},
 /*acc_rjt */ {got_dir, start,   start,   start  }
 };

 static enum actions next_action[NUM_STATES][NUM_TOKENS] =
 {
 /* token:     BACK_UP DATA         MOVEON       UNK
 old state:*/
 /*start   */ {NIL,    store_sf,    NIL,         NIL},
 /*got_sf  */ {rem_sf, store_pt,    NIL,         NIL},
 /*got_pt  */ {rem_pt, store_dir,   store_dir,   NIL},
 /*got_dir */ {rem_pt, store_pt,    split_sf,    NIL},
 /*acc_rjt */ {undo,   add_to_tree, add_to_tree, add_to_tree}
 };


 do
 {


  switch(ME.COconst->action)
  {

   case NIL:
   case ERR:
   {
     break;
   }

 
   case init:
   {
     break;
   }


   case store_sf:
   {
     IGRboolean modif; 


     me->surf_info = me->event.located_object[0];
     me->obj_hilited = TRUE;

     status = ex$putque(msg = &msg, 
                        response = &me->event1.response, 
                        byte = &size,
                        buffer = (char *)&me->event1.event);
     ERROR(status, EMS_S_Success, "exec, put que", quit);

     /*Get the active id from the state tree*/
     status = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                            &me->active_state_GRid, &me->top_lm_GRid),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
     ERROR(status, msg, "exec, getacid", quit);

     if (me->active_state_GRid.objid == me->surf_info.located_obj.objid) 
       me->have_owner = FALSE;
     else 
       me->have_owner = TRUE;

     modif = TRUE;
     status = EFis_surf_modif(&msg, me->surf_info.located_obj,
                              EMS_SPLIT_SURFACE, &modif); 
     ERROR(status, msg, "exec, EFis_surf_mod", quit);
  
     if (modif) break; /*Active state is modif so do op.*/

     if (me->active_state_GRid.objid == me->top_lm_GRid.objid)
     {
       ex$message(msgnumb = EMS_I_SurfWithBdryCantSplit);
       status = dp$erase_hilite(msg = &msg);
       ems_sleep(2);
       me->obj_hilited = FALSE;
       me->state = start;
       break;  /*Not modif and no tree so cant even undo.*/
     }

     me->num_states = 0;
     active_state = NULL;
     status = EFundo_to_lm(&msg, &me->surf_info.located_obj,
                           &me->top_lm_GRid, &me->active_state_GRid,
                           &me->surf_info.module_info, &me->num_states,
                           &active_state);
     ERROR(status, msg, "exec, EFundo_to_lm", quit);

     me->top_lm_active = TRUE;
  
     if (me->num_states > om$dimension_of(varray = me->state_list)) 
     {
       status = om$vla_set_dimension(varray = me->state_list,
                                     size = me->num_states);
       ERROR(status, EMS_S_Success, "exec, set vla", quit);
     }

     OM_BLOCK_MOVE(active_state, me->state_list,
                   me->num_states * sizeof(struct GRid));

     if (active_state) om$dealloc(ptr = active_state);
 
     DisplayMode = GRhd;
     status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, 
                            &me->surf_info.module_info.md_id),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
     ERROR(status, msg, "exec, GRdisplay", quit);

     ex$message(msgnumb = EMS_I_ClearStatusField);

     /*See if modifiable.  If not then redo back to top and tell user*/
     modif = TRUE;
     status = EFis_surf_modif(&msg, me->surf_info.located_obj,
                              EMS_SPLIT_SURFACE, &modif);
     ERROR(status, msg, "exec, EFis_surf_modif", quit);

     if (!modif)
     {
       status = EFredo_to_top(&msg, &me->active_state_GRid,
                              &me->surf_info.module_info,
                              &me->num_states, 
                              me->state_list);
       ERROR(status, msg, "exec, EFredo_to_top", quit);

       ex$message(msgnumb = EMS_I_SurfWithBdryCantSplit);

       ems_sleep(2);
       me->obj_hilited = FALSE;
       me->top_lm_active = FALSE;
       me->state = start;
       break;    /*Even at top lm state it is not modif.*/
     }

     break;
   }


   case rem_sf:
   {
     status = dp$erase_hilite(msg = &msg);
     ERROR(status, msg, "exec, erase hilite", quit);

     me->obj_hilited = FALSE;

     if (me->top_lm_active)
     {
       status = EFredo_to_top(&msg, &me->active_state_GRid,
                              &me->surf_info.module_info, &me->num_states,
                              me->state_list);
       ERROR(status, msg, "exec, EFredo_to_top", quit);

       me->top_lm_active = FALSE;
     }

     me->state = start;
     break;
   }


   case store_pt:
   {
     status = EFpoint_on_object(&me->surf_info, &me->event, my_id, &msg);
     ERROR(status, msg, "exec, EFpoint_on_object", quit);

     status = DPdrawcross(&msg, &me->event.event.button);
     ERROR(status, msg, "exec, drawcross", quit);

     if (me->num_parms == 0) 
     {
       /*This is the first input point so the direction is not yet known*/

       /*Since the user may accept the direction with a data point, the
        * event for the first point to split must be saved so the users dx
        * type command will work properly.
        */

       OM_BLOCK_MOVE(&me->event.event, 
                     &me->saved_event, 
                     sizeof(struct EX_button));

       /*At this point the direction of spliting is not determined so
        * both parameters will be stored and the proper one
        * used when the direction is known (see below).
        */
 
       me->parms[0] = me->event.located_object[0].geom_parms.u;

       /*Store the first projected point and its param for back use.*/
       me->surf_info.geom_parms = me->event.located_object[0].geom_parms;
     }
     else
     {
       /*Increase the vla size if needed.*/
       if (om$dimension_of(varray = me->parms) <= me->num_parms)
       {
         status = om$vla_set_dimension(varray = me->parms,
                                       size = me->num_parms + 2);
         ERROR(status, msg, "exec, set vla dim", quit);
       }

       /*Store the next param in the vla.*/
       me->parms[me->num_parms] = (me->option == U ? 
                                   me->event.located_object[0].geom_parms.u : 
                                   me->event.located_object[0].geom_parms.v); 
     }

     me->num_parms++;
     break;
   }



   case rem_pt:
   {
     if ( (me->num_parms <= 1) && (ME.super_cmd->state == got_dir ||
                                   ME.super_cmd->state == got_sf)   )
     {

       if (ME.super_cmd->state == got_dir)
       {
         me->parms[0] = me->surf_info.geom_parms.u;
         ME.super_cmd->state = got_pt;
       }
       else
         me->num_parms--;

       DisplayMode = GRhe;
       status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                        targetid = me->isocrv_id,
                        targetos = me->surf_info.located_obj.osnum);
       ERROR(status, msg, "exec, display", quit);

       status = om$send(msg = message Root.delete(NULL),
                        targetid = me->isocrv_id,
                        targetos = me->surf_info.located_obj.osnum);
       ERROR(status, msg, "exec, Root.delete", quit);

       me->iso_displayed = FALSE;
       me->isocrv_id = NULL_OBJID;

     }
     else me->num_parms--;

     break;
   }


   case store_dir:

   {
     if (tokens[token] == EX_RJT_MOVEON)
     {
       /*Split in v direction.*/

       me->option = V;

       DisplayMode = GRhe;
       status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                        targetid = me->isocrv_id,
                        targetos = me->surf_info.located_obj.osnum);
       ERROR(status, msg, "exec, display", quit);

       status = om$send(msg = message Root.delete(NULL),
                        targetid = me->isocrv_id,
                        targetos = me->surf_info.located_obj.osnum);
       ERROR(status, msg, "exec, display", quit);

       /*Now I know the direction is V so put the proper param in the vla
        * for the first point.
        */
       me->parms[0] = me->surf_info.geom_parms.v;

       status = EFextract_and_display_isocurve(&msg,
                                               &me->ActiveDisplay,
                                               &me->surf_info.module_info,
                                               me->ActiveLevel,
                                               me->parms,
                                               &me->isocrv_id,
                                               &me->surf_info.located_obj,
                                               FALSE);
       ERROR(status, msg, "exec, extract and dis iso", quit);    
     }
     else
     {
       me->option = U;

       /*All is well except that the first input point needs to be
        * recognized as the last point (instead of the accept point)
        * for dx keyin purposes.
        */

       gr$put_last_point(msg = &msg,
                         sizbuf = &bytes_in,
                         buffer = &me->saved_event);
       ERROR(OM_S_SUCCESS, msg, "exec, gr$put_last_point", quit);
     }
     break;
   }


   case split_sf:
   {
     IGRdouble      *out_parms;    
     IGRlong        msg1, num_good_parms, i;
     GRobjid        *surf_out_ids;
     struct GRid    surf_GRid;
     IGRboolean     bad_error = FALSE, is_closed[2];


     ex$message(msgnumb = EMS_P_ClearPromptField);
     ex$message(msgnumb = EMS_I_Processing);

     /*Erase all.*/
     status = dp$erase_hilite(msg = &msg);
     ERROR(status, msg, "exec, erase hilite", quit);

     surf_GRid.objid = me->surf_info.located_obj.objid;
     surf_GRid.osnum = me->surf_info.located_obj.osnum;

     /* Erase the surface to be split */
     DisplayMode = GRbe;
     status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode,
                            &me->surf_info.module_info.md_id), 
                     targetid = surf_GRid.objid,
                     targetos = surf_GRid.osnum);
     ERROR(status, msg, "exec, display", quit);

     me->obj_hilited = FALSE;

     construct_list.msg = &msg;
     construct_list.env_info = &me->surf_info.module_info;
     construct_list.newflag = FALSE;
     construct_list.geometry =  NULL;
     construct_list.class_attr = NULL;
     construct_list.level = me->ActiveLevel;
     construct_list.properties = GRIS_LOCATABLE   |
                                 GRIS_DISPLAYABLE |
                                 GRIS_NEW;
     construct_list.display = &me->ActiveDisplay;
     construct_list.name = NULL;

     surf_out_ids = NULL;

     if (me->have_owner)  /* surface has an owner */
     {
       status = om$send(msg = message EMSsurface.EMlmsplit(&msg,
                              message EMSsurface.EMsplit_surface(&msg1,
                              &me->surf_info.module_info,
                              &construct_list, me->option,
                              (IGRlong) me->num_parms, &num_good_parms,
                              me->parms, &out_parms, surf_GRid,
                              &surf_out_ids, is_closed, FALSE),
                              &me->split_obj_GRid),
                        targetid = me->top_lm_GRid.objid,
                        targetos = me->top_lm_GRid.osnum);
       EMSmsgReport(status, "exec split surf", FALSE);
       EMSmsgReport(msg, "exec split surf", FALSE);
       EMSmsgReport(msg1, "exec split surf", FALSE);
     }
     else
     {
       status = om$send(msg = message EMSsurface.EMsplit_surface(&msg,
                              &me->surf_info.module_info,
                              &construct_list, me->option,
                              (IGRlong) me->num_parms, &num_good_parms,
                              me->parms, &out_parms, surf_GRid, 
                              &surf_out_ids,
                              is_closed, TRUE),
                        targetid = surf_GRid.objid,
                        targetos = surf_GRid.osnum);
       EMSmsgReport(status, "exec split surf", FALSE);
       EMSmsgReport(msg, "exec split surf", FALSE);
     }

     ex$message(msgnumb = EMS_I_ClearStatusField);

     if ( !(1 & status & msg) || !num_good_parms)
     {
       ex$message(msgnumb = EMS_I_ErrorWhileSplitting);


       bad_error = TRUE;

       DisplayMode = GRbd;
       status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                        targetid = surf_GRid.objid,
                        targetos = surf_GRid.osnum);
       ERROR(status, msg, "exec, display", quit);

       status = om$send(msg = message Root.delete(NULL),
                        targetid = me->isocrv_id,
                        targetos = me->surf_info.located_obj.osnum);
       ERROR(status, msg, "exec, display", quit);

       if (me->top_lm_active)
       {
         ems_sleep(2);
         status = EFredo_to_top(&msg, &me->active_state_GRid,
                                &me->surf_info.module_info, &me->num_states,
                                me->state_list);
         ERROR(status, msg, "exec, EFredo_to_top", quit);

         me->top_lm_active = FALSE;
       }
       me->isocrv_id = NULL_OBJID;
     }
     else
     {
        IGRint num_split_surfs;

        num_split_surfs = ((is_closed[0] || is_closed[1]) ? num_good_parms - 1
                                                          : num_good_parms);

       /*All is well so display the new surfaces.*/

       for (i=0; i <= num_split_surfs; i++)
       {
         DisplayMode = GRbd;
         status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                          targetid = surf_out_ids[i],
                          targetos = me->surf_info.located_obj.osnum);
         ERROR(status, msg, "exec, display", quit);
       }
     } 

     if (surf_out_ids) om$dealloc(ptr = surf_out_ids);

     /* fix for mlk */
     if (out_parms) om$dealloc(ptr = out_parms);
     if ( !me->have_owner || bad_error)
     {
       me->num_parms = 0;
       ME.super_cmd->state = start;
     }
     else
     {
       ME.super_cmd->state = acc_rjt;
     }

     break;
   }


   case undo:
   {
     GRobjid *display_ids = NULL;
     IGRint display_count = 0;

     IGRboolean deactivate_option;          /*DECL*/

     status = dp$erase_hilite(msg = &msg);
     ERROR(status, msg, "ECsplit_sleep, erase_hilite", quit);

     /*Undo the split operation.*/
     deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY | EMS_DELETE_DPR;
     status = om$send(msg = message EMSdpr.EMdeactivate(&msg,
                            &deactivate_option, &me->surf_info.module_info,
                            &display_ids, &display_count),
                      targetid = me->split_obj_GRid.objid,
                      targetos = me->split_obj_GRid.osnum);
     ERROR(status, msg, "exec, deactivate", quit);

     DisplayMode = GRbd;
     for(i=0; i<display_count; i++)
     {
       if (om$is_objid_valid(
                 objid = display_ids[i],
                 osnum = me->split_obj_GRid.osnum) == OM_S_SUCCESS)
       {
         status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &me->surf_info.module_info.md_env.matrix_type,
                              me->surf_info.module_info.md_env.matrix,
                              &DisplayMode, 
                              &me->surf_info.module_info.md_id),
                         targetid = display_ids[i],
                         targetos = me->surf_info.located_obj.osnum);
         ERROR(status, msg, "EClocalmod_exec, GRdisplay", quit);
       }
     }      

     if (display_ids) om$dealloc(ptr = display_ids);

     /* Redraw the surface to be split */
     DisplayMode = GRhd;
     status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode,
                            &me->surf_info.module_info.md_id), 
                     targetid = me->surf_info.located_obj.objid,
                     targetos = me->surf_info.located_obj.osnum);
     ERROR(status, msg, "exec, display", quit);

     me->obj_hilited = TRUE;

     /* And the iso curve.*/
     DisplayMode = GRhd;
     status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &DisplayMode, &me->surf_info.module_info.md_id),
                      targetid = me->isocrv_id,
                      targetos = me->surf_info.located_obj.osnum);
     ERROR(status, msg, "exec, display", quit);
     break;
   }


   case add_to_tree:
   {  
     /* Delete the isocrv*/
     status = om$send(msg = message Root.delete(NULL),
                      targetid = me->isocrv_id,
                      targetos = me->surf_info.located_obj.osnum);
     ERROR(status, msg, "exec, iso-cv delete", quit);

     me->isocrv_id = NULL_OBJID;

     ex$message(msgnumb = EMS_P_ClearPromptField);

     if (me->top_lm_active) 
     { ex$message(msgnumb = EMS_S_PerfmReexec);
     }
     add_option = EMS_DO_DISPLAY;
     status = om$send(msg = message EMSsfdpr.EMadd(&msg, 
                            (me->top_lm_active ? &me->top_lm_GRid :
                                                 &me->active_state_GRid),
                            (me->top_lm_active ? &me->active_state_GRid :
                                                 NULL), 
                            &me->surf_info.module_info, &add_option),
                      targetid = me->split_obj_GRid.objid,
                      targetos = me->split_obj_GRid.osnum);
     if (! (1 & status & msg))
     {
       me->top_lm_active = FALSE;
       ERROR(status, msg, "exec, EMadd", quit);
     }

     if (msg == EMS_I_BoolFail)
     {
       /*Delete the lm state*/
       status = om$send(msg = message GRgraphics.GRdelete(&msg,
                              &me->surf_info.module_info),
                        targetid = me->split_obj_GRid.objid,
                        targetos = me->split_obj_GRid.osnum);
       ERROR(status, msg, "exec, GRdelete", quit);
     }

     me->top_lm_active = FALSE;
  
     ex$message(msgnumb = EMS_I_ClearStatusField);

     me->num_parms = 0;
     ME.super_cmd->state = start;

     if (!gothru)
     {
       /*Place accept event on the software stack.*/
       qsize = sizeof(me->event.event);
       status = ex$putque(msg = &msg, 
                          response = response, 
                          byte = &size,
                          buffer = (char *)&me->event.event);
       ERROR(status, msg, "exec put que", quit);
     }
     else
     {
       gothru = FALSE;
       ME.COconst->action = NIL;
       return (OM_S_SUCCESS);
     }

     break; 
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "exec, invalid active", quit);
   }
  } /* end action switch */



  switch(ME.super_cmd->state)
  {

   case start:
   {
     me->num_parms = 0;
     me->iso_displayed = FALSE;
     me->top_lm_active = FALSE;
     me->isocrv_id = NULL_OBJID;

     display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;

     locate_mask = GRm_DATA | GRm_BACK_UP;
     accept_mask = GRm_DATA;

     attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
/*   attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP; */
     attributes.owner_action = LC_FLEX_COMP | 
                               LC_RIGID_OWNER | LC_LOCALMOD;

     ex$message(msgnumb = EMS_P_00031,   /* Identify surface */
                buff    = locate_prompt);
     ex$message(msgnumb = EMS_P_AcceptWithSplitPtReject,
                buff    = accept_prompt);
     ex$message(msgnumb = EMS_I_00011, /* Surface not found */
                buff    = relocate_prompt);
     strcpy(attributes.classes, "EMSsurface");

     rtree_classes.w_count = 1;
     elig_classes.w_count = 1;
     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
     rclass = OPP_EMSsubbs_class_id;
     eliclass = OPP_EMSsubbs_class_id;

     rtree_classes.p_classes = &rclass;
     elig_classes.p_classes = &eliclass;

     lc$locate(rc = &msg, 
               event1 = &me->event, 
               event2 = &me->event1,
               event3 = &event2,
               mask1 = locate_mask, 
               mask2 = accept_mask, 
               eventsize= &size, 
               display_flag = display_flag,
               response = response, 
               response_data = response_data, 
               locate_prompt = locate_prompt, 
               acc_prompt = accept_prompt,
               relocate_prompt = relocate_prompt, 
               attributes = &attributes, 
               stack = &ME.ECsplit->locate_stack, 
               rtree_classes = &rtree_classes, 
               eligible_classes = &elig_classes);

     if (msg == LC_OBJ_LOCATED) /*Something was located.*/
     {
       me->event.num_id = event2.num_id;
       me->event.located_object[0] = event2.located_object[0];
       me->event.response = me->event1.response;    /*correct it*/
     }
     else if (me->locate_stack.num_entries)
       /*Exited locate during acc/rjt, reflect response in locate_event.*/
       me->event.response = me->event1.response; 
     else if (me->event.response == EX_DATA)    
       me->event.response = EX_BACK_UP;     /*Backed out of acc/rjt*/

     token = GRloc_token(&msg, tokens, &me->event);

     break;
   }


   case got_sf:
   {
     ex$message(msgnumb = EMS_I_ClearStatusField);
     ex$message(msgnumb = EMS_P_InputSplitPoint);

     locate_mask = GRm_DATA | GRm_BACK_UP;

     token = GRget_token(&msg, tokens, &locate_mask, &me->event, &size,
                         response, response_data);
     ERROR(OM_S_SUCCESS, msg, "exec, get token", quit);
     break;
   }


   case got_pt:
   {
     if (me->isocrv_id == NULL_OBJID)
     {
       status = EFextract_and_display_isocurve(&msg,
                                               &me->ActiveDisplay,
                                               &me->surf_info.module_info,
                                               me->ActiveLevel,
                                               me->parms,
                                               &me->isocrv_id,
                                               &me->surf_info.located_obj,
                                               TRUE);
       ERROR(status, msg, "exec, extract and dis iso", quit);    
       me->iso_displayed = TRUE;
     }

     ex$message(msgnumb = EMS_I_ClearStatusField);
     ex$message(msgnumb = EMS_P_00061); /* Accept displayed direction/reject */

     locate_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;

     token = GRget_token(&msg, tokens, &locate_mask, &me->event, &size,
                         response, response_data);
     ERROR(OM_S_SUCCESS, msg, "exec, get token", quit);

     break;
   }


   case got_dir:
   {
     IGRchar       buffer[52];             /*DECL*/


     ex$message(msgnumb = EMS_I_ClearStatusField);

     ex$message(msgnumb = EMS_P_InputPtNumAtWhichToSplitMoveOn,
                type    = "%2d",
                var     = `me->num_parms + 1`,
                buff    = buffer );
     ex$message(in_buff = buffer);

     locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

     token = GRget_token(&msg, tokens, &locate_mask, &me->event, &size,
                         response, response_data);
     ERROR(OM_S_SUCCESS, msg, "exec, get token", quit);

     break;
   }


   case acc_rjt:
   {
     locate_mask = GRm_BACK_UP | GRm_DATA;
 
     if (me->top_lm_active)
     {
       ex$message(msgnumb = EMS_P_AccWithNxtEvntToReexec);
     }
     else
     {
       ex$message(msgnumb = EMS_P_AccwAnyEventBackupForUndo);
     }
   
     token = GRget_token(&msg, tokens, &locate_mask, &me->event, &size,
                         response, response_data);
     ERROR(OM_S_SUCCESS, msg, "exec, get_token", quit);

     if (tokens[token] == GR_UNKNOWN_TYPE)
       gothru = TRUE; 
     else gothru = FALSE;

     ex$message(msgnumb = EMS_I_ClearStatusField);
     break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "exec, state table", quit);
   }
  }   /* end state switch */


  me->action = next_action[me->state][token];
  me->state = next_state[me->state][token];
  continue_flag = (tokens[token] != GR_UNKNOWN_TYPE);

  if (gothru) continue_flag = TRUE;

 }
 while(continue_flag);

 return (status);

 quit:
  *response = TERMINATE;
  return(status);
}


EFextract_and_display_isocurve(msg, active_display, md_env, active_level,
                               parms,  isocrv_id, surf_GRid, in_u_dir)

IGRlong           *msg;
struct IGRdisplay *active_display;
struct GRmd_env   *md_env;
IGRshort          active_level;
IGRdouble         *parms;
GRobjid           *isocrv_id;
struct GRid       *surf_GRid;
IGRboolean        in_u_dir;   /*TRUE if extracting a u param curve.*/

{
  IGRlong               status=OM_S_SUCCESS;
  IGRlong		number_of_curves;
  GRobjid               saved_module_id, *curves;
  enum   GRdpmode       DisplayMode;
  struct IGRdisplay     iso_display;     
  struct GRvg_construct construct_list;  
  


  iso_display = *active_display;
  iso_display.weight += 2;


  /*Do not post the constructed curve in the r-tree.*/
  saved_module_id = md_env->md_id.objid;
  md_env->md_id.objid = NULL_OBJID;
  construct_list.env_info = md_env;

  construct_list.msg = msg;
  construct_list.newflag = FALSE;
  construct_list.geometry =  NULL;
  construct_list.class_attr = NULL;
  construct_list.level = active_level;
  construct_list.properties = GRIS_LOCATABLE   |
                              GRIS_DISPLAYABLE |
                              GRIS_NEW;
  construct_list.display = &iso_display;
  construct_list.name = NULL;

  /*Extract an iso parametric curve.*/
  curves = NULL;
  status = om$send(msg = message EMSsubbs.EMisoparcvs(msg,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         &construct_list, FALSE, 1, 
                         &parms[0],
                         in_u_dir, &number_of_curves, &curves),
                senderid = NULL_OBJID,
                targetid = surf_GRid->objid,
                targetos = surf_GRid->osnum);

  md_env->md_id.objid = saved_module_id;

  ERROR(status, *msg, "EFext_and_dis_iso, isparcv", quit);

  *isocrv_id = curves[0];
  free(curves);
  DisplayMode = GRhd;
  status = om$send(msg = message GRgraphics.GRdisplay(msg,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         &DisplayMode, &md_env->md_id),
             senderid = NULL_OBJID,
             targetid = *isocrv_id,
             targetos = surf_GRid->osnum);
  ERROR(status, *msg, "EFext_and_dis_iso, display", quit);

  quit:
   return(status);
}

end implementation ECsplit;
