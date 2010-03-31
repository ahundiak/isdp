/* ###################   APOGEE COMPILED   ################## */
class implementation EClocalmod;

/*
DESCRIPTION
        This command lifts/moves a face or edge or vertex on a solid.
        The user must first locate a surface of a solid. Then
        the faces, or edges, or vertices are accepted or reject
        one after the other. The user then accepts the object to
        lift/move with a from point as a reference point. The user then
        gives a to point and the solid is modified and redisplayed.
        The user must then accept or reject the change. If it is
        rejected then the solids returns to its original shape.
        If the solid is accepted it is placed on the state tree
        where an undo operation can be done on it.
NOTES
        None.

ASSUMPTIONS
        None.

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

SEE ALSO

BUGS
        Note the comments in the code where external routines
        do not behave as is expected.

HISTORY

22 May 1989 jBk Changed from use of GRgetevent to co$getevent.

                Changed from GRm_STRING mask to GRm_TEXT_VALUE.

        RC     04/01/87    Creation date.
        DLB    05/11/87    Added stuff for re-execute.
        DLB    05/20/87    Massive mod. to use same command for move/lift
        AIC    15-Jul-87   Use edge display message rather that boundary.
        DLB    3/27/91     Lift associative BABY!!!!
        DLB    6/29/91     Compute vect and mag from fr_pt, to_pt for 
                           EFliftface function.
        SCW    09/05/91    Converted to use gr$dpb associative flag
        DLB    09/06/91    Added param to EFlift_face.
        AMD    01/29/92    Fix for TR 92n0288
        DLB    02/21/92    Dont allow locate of associative elements.
        Vadiraj 06/02/92   Modified for message subsystem compliance.
        AMD    10/15/92    Fix for TR 11924042
        Sudha  07/05/93    Modified for BSprototypes ansification
        SCW    08/14/94    Clarified sleep method

*/
#define TEST_NORMAL_LIFT 0

#if TEST_NORMAL_LIFT
#include <stdio.h>
#endif

#define ASSOC 1

#define LFTFACE 0      /** LIFT FACE command  **/
#define LFTEDGE 1      /** LIFT EDGE command  **/
#define LFTVERT 2      /** LIFT VERTEX command**/

#define MVFACE 3      /** MOVE FACE command  **/
#define MVEDGE 4      /** MOVE EDGE command  **/
#define MVVERT 5      /** MOVE VERTEX command**/

#define DEBUG 0  /*SET TO '1' WHEN WANTING ERROR STRINGS PRINTED FOR DEBUG*/

#define EC_DO_SURF 0  /*tell ECvalidate to check for is surf modif*/
#define EC_DO_EDGE 1  /*tell ECvalidate to check for is edge modif*/

#include "EMS.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "EMSerrordef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "emsdef.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h" /* co$getevent */
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_E.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EMSdpbmacros.h"
#include "EMSascmacros.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

from GRgraphics import GRlnproject, GRdisplay, GRdelete;
from EMSsurface import EMgetactiveid, EMmake_active_state, 
                       EMlmmove, EM_lift, EMmove, EMmk_nat_bdry,
                       EMgettreepath;
from EMSedge    import EMdisplay, EMis_edge_modif;
from EMSsubbs   import EMget_edges;
from EMSsf_lift import EMlift_vertex, EMlift_edge, EMlift_face;
from EMSdpr     import EMundo, EMdeactivate;
from GRvg       import GRgetsize, GRgetgeom;
from EMSsfdpr   import EMadd;
from GRowner    import GRget_number_components;


extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsflm_class_id, 
                OPP_EMSsfimpbnd_class_id, OPP_EMSsfround_class_id,
                OPP_EMSsfmkface_class_id;

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhd;
 IGRint        OM_stat = OM_S_SUCCESS;
 IGRlong       EMmsg = EMS_S_Success;
 IGRshort      display_flag;
 /*IGRint        EMdpb_getinfo();*/
 struct GRid   top_id, active_id, *active_state;
 
 if (me->top_lm_active)
 {
   /*Get the active solid id from the state tree*/
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid (
                            &EMmsg, &active_id, &top_id),
                     targetid = me->surf_info.located_obj.objid,
                     targetos = me->surf_info.located_obj.osnum);
   ERROR(OM_stat, EMmsg, "wake, getactiveid error", wrapup);

   if ((me->top_lm_GRid.objid != top_id.objid) ||
       (me->active_state_GRid.objid != active_id.objid))
   {
     ex$message(msgnumb=EMS_E_LocModInfoCorrp)
     return(OM_E_ABORT);
   }

   me->num_states = 0;
   active_state = NULL;
   OM_stat = EFundo_to_lm(&EMmsg, &me->surf_info.located_obj, 
                          &me->top_lm_GRid, &me->active_state_GRid, 
                          &me->surf_info.module_info, &me->num_states,
                          &active_state);
   ERROR(OM_stat, EMmsg, "wake, EFundo_to_lm error", wrapup);
     
   if (active_state) om$dealloc(ptr = active_state);
   ex$message(msgnumb=EMS_S_ClearStatusField);

 } /*End if active and top lm different*/

 if (me->srf_hi)
 { 
   Display_Mode = GRhd;
   OM_stat = om$send(msg = message GRgraphics.GRdisplay(&EMmsg, 
                           &me->surf_info.module_info.md_env.matrix_type, 
                           me->surf_info.module_info.md_env.matrix, 
                           &Display_Mode, 
                           &me->surf_info.module_info.md_id),
                    targetid = me->surf_info.located_obj.objid,
                    targetos = me->surf_info.located_obj.osnum);
   ERROR(OM_stat, EMmsg, "wake, GRdisplay", wrapup);
 }

 if (me->edvt_hi)
 { 
  Display_Mode = GRhd;
  display_flag = me->ed_vt_display_flag;
  OM_stat = om$send(msg = message EMSedge.EMdisplay(&EMmsg, NULL,
                          &me->local_info.module_info.md_env.matrix_type,
                          me->local_info.module_info.md_env.matrix,
                          &Display_Mode, NULL, display_flag, NULL),
                    targetid = me->local_info.located_obj.objid,
                    targetos = me->local_info.located_obj.osnum);
  ERROR(OM_stat, EMmsg, "wake, EMdisplay", wrapup);
 }

 /*
  * Get current dpb 
  */
/******************************************************************
 OM_stat = EMdpb_getinfo (&EMmsg, &me->dpb_info);
******************************************************************/
 OM_stat = ems$dpb_getinfo (msg = (IGRlong *)&EMmsg,
                            dpbinfo = &me->dpb_info);
 ERROR (OM_stat, EMmsg, "wake, EMdpb_getinfo", wrapup);

 gr$get_associative_flag( buffer = &me->associative_flag );

 if (ME.super_cmd->mytype == LFTFACE && me->associative_flag )
   GRdisplay_associative_button(TRUE);

 wrapup:
   return(OM_stat);
}

method super_cmd.sleep(int pos)
{
 IGRint  OM_stat = OM_S_SUCCESS;
 IGRlong EMmsg = EMS_S_Success;
 
 ex$message(msgnumb=EM_M_ClearMessageField);
 ex$message(msgnumb=EMS_S_ClearStatusField);
 ex$message(msgnumb=EMS_P_ClearPromptField);

 if ((me->srf_hi && !me->top_lm_active) || me->edvt_hi)
 { 
   OM_stat = dp$erase_hilite(msg = &EMmsg);
 }

 if (me->top_lm_active)
 {
   OM_stat = EFredo_to_top(&EMmsg, &me->active_state_GRid,
                           &me->surf_info.module_info, &me->num_states,
                           me->state_list);
   ERROR(OM_stat, EMmsg, "sleep, EFredo_to_top", wrapup);
 }

 if (ME.super_cmd->mytype == LFTFACE && me->associative_flag )
   GRdisplay_associative_button(FALSE);
 
 wrapup:
  return (OM_stat);
}

 
method execute(int *response; char *response_data; int pos)
{
  enum    GRdpmode  Display_Mode;
  OMuint  chan_count;
  IGRlong srf_size;
  IGRint  array_size, num_edges, num_sfs;
  IGRlong mthd_stat = EMS_S_Success;
  IGRint  OM_stat = OM_S_SUCCESS,
          size=sizeof(struct GRevent), display_flag, locate_mask,
          accept_mask, mask, token, mytype; 
  IGRlong qsize; 
  IGRdouble  lift_vec[3];
  struct GRvg_construct construct_list;
  struct IGRbsp_surface *srf_geom = NULL;
  struct GRid           *ed_GRids = NULL;
  struct GRlc_locate    attr;
  struct IGResbs        class_attr;
  OM_S_CHANSELECT sf_ls_chan;
  OM_S_CLASSLIST  rtree_classes, elig_classes;
  OMuword    rclass, eliclass;
  IGRboolean continue_while = TRUE, goto_nextstate, gothru = FALSE,
             ck_coinc = FALSE;
  IGRshort   prevstate, i, select_option, deactivate_option,
             which_end_pt = 0, move_type = 0, add_option;
  IGRshort   object_type = 0;
  IGRchar    loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRushort active_constraints;
  extern void EFmerge_single_sf_lift_states();
  void       EFprepare_single_sf_lift();

# define NUM_TOKENS 4
  static int Tokens[NUM_TOKENS] =
  {
    EX_BACK_UP, DATA, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
  };

  enum actions
  {
    NIL, ERR, initialize, store_sf, dehilite_sf,
    dehilite_edvt, store_fr_pt, store_edvt, store_loc_pt, store_to_pt,
    process, undo, add_to_tree
  };

# define NUM_STATES 9
  enum states
  {
    start, got_sf_fr_pt, got_sf_wfr_pt, got_sf_loc_pt,
    got_sf_wloc_pt, got_edvt_fr_pt, got_edvt_wfr_pt, got_to_pt,
    fini
  };

static enum states NextState[NUM_STATES][NUM_TOKENS] =
{
/*token:            BACK_UP         DATA           MOVE  UNK
   old state: */                                      
/*start         */ {start,          got_sf_fr_pt,  start, start               
   }, 
/*got_sf_fr_pt  */ {got_sf_wfr_pt,  got_to_pt,     got_sf_fr_pt, got_sf_fr_pt
   }, 
/*got_sf_wfr_pt */ {start,          got_sf_fr_pt,  got_sf_wfr_pt, got_sf_wfr_pt
   }, 
/*got_sf_loc_pt */ {got_sf_wloc_pt, got_edvt_fr_pt,got_sf_loc_pt, got_sf_loc_pt
   }, 
/*got_sf_wloc_pt*/ {start,          got_sf_loc_pt, got_sf_wloc_pt, got_sf_wloc_pt },
/*got_edvt_fr_pt*/ {got_edvt_wfr_pt,got_to_pt,     got_edvt_fr_pt, got_edvt_fr_pt }, 
/*got_edvt_wfr_pt*/{got_sf_wloc_pt, got_edvt_fr_pt,got_edvt_wfr_pt, got_edvt_wfr_pt},
/*got_to_pt     */ {got_sf_fr_pt,   got_to_pt,     fini,got_to_pt      },
/*fini          */ {got_sf_fr_pt,   start,         fini, start          }
};

static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
{
/* token:           BACK_UP       DATA          MOVE     UNK
   old state: */                                               
/*start          */{NIL,          store_sf,     NIL,     NIL        },
/*got_sf_fr_pt   */{NIL,          store_to_pt,  NIL,     NIL        },
/*got_sf_wfr_pt  */{dehilite_sf,  store_fr_pt,  NIL,     NIL        },
/*got_sf_loc_pt  */{NIL,          store_edvt,   NIL,     NIL        },
/*got_sf_wloc_pt */{dehilite_sf,  store_loc_pt, NIL,     NIL        },
/*got_edvt_fr_pt */{NIL,          store_to_pt,  NIL,     NIL        },
/*got_edvt_wfr_pt*/{dehilite_edvt,store_fr_pt,  NIL,     NIL        },
/*got_to_pt      */{NIL,          NIL,          process, NIL        },
/*fini           */{undo,         add_to_tree,  NIL,     add_to_tree}
};

 mytype = ME.super_cmd->mytype;

 switch(mytype)
 {
  case LFTFACE:
   ex$message(msgnumb=EM_M_LiftFace);
   break;
  case LFTEDGE:
   ex$message(msgnumb=EM_M_LiftEdge);
   break;
  case LFTVERT:
   ex$message(msgnumb=EM_M_LiftVertex);      
   break;
  case MVFACE:
   ex$message(msgnumb=EM_M_MoveFace);
   break;
  case MVEDGE:
   ex$message(msgnumb=EM_M_MoveEdge);
   break;
  case MVVERT:
   ex$message(msgnumb=EM_M_MoveVertex);
   break;

  default:
   *response = TERMINATE;
   return OM_E_ABORT;
 }


 do
 {
  goto_nextstate = TRUE;

  switch (ME.COconst->action)
  {
   
   case NIL:
   case ERR:
    break;


   case initialize:
    me->top_lm_active = FALSE;
    break;


   case store_sf:
   {
    me->srf_hi = TRUE;

    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->surf_info, sizeof(struct GRlc_info));
   
    {/*DLB - Dont allow associative elements - 92n1603*/
      IGRint            pathlist_size=0;
      GRobjid           *pathlist=NULL;
      IGRboolean        assoc_in_tree;
      extern IGRboolean EFassoc_in_tree_path();

      OM_stat = om$send(msg = message EMSsurface.EMgettreepath(&mthd_stat,
                              &pathlist, &pathlist_size, FALSE),
                        targetid = me->surf_info.located_obj.objid,
                        targetos = me->surf_info.located_obj.osnum);
      ERROR(OM_stat, mthd_stat, "EClocmod_exec gettreepath", wrapup);

      assoc_in_tree = EFassoc_in_tree_path(&mthd_stat, pathlist, pathlist_size,
                                           me->surf_info.located_obj.osnum);
      ERROR(OM_S_SUCCESS, mthd_stat, "locmod_exec assoc_in_tree", wrapup);

      if (pathlist) om$dealloc(ptr = pathlist);
    
      if (assoc_in_tree)
      {
        ex$message(msgnumb=EMS_E_AssoEleNotSuppo);
        me->single_sf_lift = FALSE;
        me->state = start;
        dp$erase_hilite(msg = &mthd_stat);
        break;      
      }
    }

    OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);

    OM_stat = om$get_channel_count(objid = me->surf_info.located_obj.objid,
                                   osnum = me->surf_info.located_obj.osnum,
                                   p_chanselect = &sf_ls_chan,
                                   count = &chan_count);
    if (!chan_count)
    {
      OM_stat = om$send(msg = message EMSsurface.EMmk_nat_bdry(&mthd_stat,
                              &me->surf_info.module_info.md_env, NULL),
                        targetid = me->surf_info.located_obj.objid,
                        targetos = me->surf_info.located_obj.osnum);
    }

    /* Moved the validation before ex$putque to fix TR 11924042 
       AMD : 10/15/92 */

    OM_stat = om$send(msg = message EClocalmod.ECvalidate(&mthd_stat, 
                            EC_DO_SURF),
                      targetid = my_id);
    ERROR(OM_stat, mthd_stat, "EClmod, send ECvalidate", wrapup);

    if (mthd_stat == EMS_I_Stop) break;

    if (mytype == LFTFACE || mytype == MVFACE) 
    {
      OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                    &me->local_info, sizeof(struct GRlc_info));
        
      if (mytype == MVFACE)
        OM_BLOCK_MOVE(&me->locate_event.event.button,
                      me->from_pt, sizeof(IGRpoint));

      qsize = sizeof(me->locate_event.event) + sizeof (IGRint);
      OM_stat = ex$putque(msg = &mthd_stat, 
                          response = response, 
                          byte = &qsize,
                          buffer = (char *)&me->locate_event.event);
      ERROR(OM_stat, EMS_S_Success, "EClocmod_exec put que", wrapup);
      
      me->state = got_sf_wfr_pt;
    }
    else    /* for edge or vertex */
    {
      me->project_pt[0] = me->surf_info.geom_parms.u;
      me->project_pt[1] = me->surf_info.geom_parms.v;
    }    

    /*Get the active solid id from the state tree.*/
    OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(&mthd_stat,
                            &me->active_state_GRid, &me->top_lm_GRid),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, mthd_stat, "exec, getacid", wrapup);

    /* In case of lift operation, it may be possible that it is a single sf
     * state tree. In such a case the sf_geometry at the current
     * state is to be used. Therefore, DO NOT UNDO to top_lm.
     */
    if (mytype == LFTFACE || mytype == LFTEDGE || mytype == LFTVERT)
    {
      if (me->active_state_GRid.objid == me->surf_info.located_obj.objid)
      {
        ex$message(msgnumb=EMS_S_SingleSurfNotAllowed);
        me->single_sf_lift = FALSE;
        me->state = start;
        dp$erase_hilite(msg = &mthd_stat);
        break;      
      }
      else
      {
        OM_stat = om$send(msg = message GRowner.GRget_number_components(
                                &mthd_stat, &num_sfs),
                          targetid = me->active_state_GRid.objid,
                          targetos = me->active_state_GRid.osnum);
        ERROR(OM_stat, mthd_stat, "EClmod, GRget_num_components", wrapup);

        if (num_sfs == 1) 
        {
          me->single_sf_lift = TRUE;
          break;        /*1 sf lift ignores modif and tree.*/
        }
        else me->single_sf_lift = FALSE;
      } 
    } 
    else
      me->single_sf_lift = FALSE;

    if (me->single_sf_lift)  /*DLB 9/12/91*/
    {
      ex$message(msgnumb=EMS_S_SingleSurfNotAllowed)
      me->single_sf_lift = FALSE;
      me->state = start;
      dp$erase_hilite(msg = &mthd_stat);
      break;      
    }

    OM_stat = om$send(msg = message EClocalmod.ECvalidate(&mthd_stat, 
                            EC_DO_SURF),
                      targetid = my_id);
    ERROR(OM_stat, mthd_stat, "EClmod, send ECvalidate", wrapup);

    break;
   }


   case dehilite_sf:
   {
    if (me->top_lm_active)
    {
      OM_stat = EFredo_to_top(&mthd_stat, &me->active_state_GRid,
                              &me->surf_info.module_info, &me->num_states,
                              me->state_list);
      ERROR(OM_stat, mthd_stat, "exec, EFredo_to_top", wrapup);

      me->top_lm_active = FALSE;
    }
    else
    {
      OM_stat = dp$erase_hilite(msg = &mthd_stat);
    }     

    me->srf_hi = FALSE;

    break;
   }


   case dehilite_edvt:
   { 
    if (me->top_lm_active && (mytype == MVEDGE || mytype == MVVERT) )
    {
      OM_stat = EFredo_to_top(&mthd_stat, &me->active_state_GRid,
                              &me->surf_info.module_info, &me->num_states,
                              me->state_list);
      ERROR(OM_stat, mthd_stat, "exec, EFredo_to_top", wrapup);

      me->top_lm_active = FALSE;
    }

    OM_stat = dp$erase_hilite(msg = &mthd_stat);

    me->edvt_hi = FALSE;
    break;
   }


   case store_fr_pt:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->from_pt, sizeof(IGRpoint));
    break;
   }
    
   
   case store_edvt:
   {
    me->edvt_hi = TRUE;
    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->local_info, sizeof(struct GRlc_info));
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->from_pt, sizeof(IGRpoint));
    break;
   }

        
   case store_loc_pt:
   { 
    break;
   }
    

   case store_to_pt:
   {
     OM_BLOCK_MOVE(&me->locate_event.event.button, 
                   me->to_pt, sizeof(IGRpoint));
     break;
   }

   
   case process:
   {
    ex$message(msgnumb=EMS_S_Processing);
    ex$message(msgnumb=EMS_P_ClearPromptField);

    /* if it is a vertex or edge, erase it also*/
    if (mytype == LFTVERT || mytype == LFTEDGE || 
        mytype == MVVERT  || mytype == MVEDGE)
    {
     if(mytype == LFTEDGE || mytype == MVEDGE)
       display_flag = EMS_WHL_EDGE;
     else
       display_flag = EMS_EDGE_BEG_PT;    

     Display_Mode = GRbehe;
     OM_stat = om$send(msg = message EMSedge.EMdisplay(&mthd_stat,NULL,
                             &me->local_info.module_info.md_env.matrix_type,
                             me->local_info.module_info.md_env.matrix,
                             &Display_Mode, NULL, display_flag, NULL),
                       targetid = me->local_info.located_obj.objid,
                       targetos = me->local_info.located_obj.osnum);
     ERROR(OM_stat, mthd_stat, "exec, EMdisplay", wrapup);
    } /* end if*/
 
    /*erase a weighted point for from point*/

    ECdisplayPointSetByBuffer(&mthd_stat, ME.COconst->ActiveDisplay,
                               ME.COroot->ModuleInfo, my_id, 1,
                               me->from_pt, FALSE);

    ERROR(OM_S_SUCCESS, mthd_stat, "exec, dis_pt_set", wrapup);

    me->srf_hi = FALSE;
    me->edvt_hi = FALSE;

    switch(mytype)
    {
     case LFTVERT:
     case LFTEDGE:
     case LFTFACE:
     {     

       construct_list.newflag = FALSE;
       construct_list.display = &ME.COconst->ActiveDisplay;
       construct_list.geometry = NULL;
       class_attr.u_rules = (IGRlong) me->dpb_info.u_rules;
       class_attr.v_rules = (IGRlong) me->dpb_info.v_rules;
       class_attr.is_polydis = me->dpb_info.props & EMDPB_POLYGON_DISPLAY_ON;
       class_attr.is_surfdis = TRUE;
       class_attr.is_slowdis = FALSE;
       construct_list.class_attr = (IGRchar *) &class_attr;
       construct_list.msg = &mthd_stat;
       construct_list.env_info = &me->surf_info.module_info;
       construct_list.level = ME.COconst->ActiveLevel;
       construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct_list.name = NULL;

       /*perform the lift operation*/

      active_constraints = ck_coinc ? EMS_LC_AUTO_COINCIDENCE :
                                             NULL;
      /*
       * It may be possible that the surface is by itself or
       * a part of single surface state tree. In such a case,
       * the lift process should result in solid with new
       * surfaces created for the edges even though the edges
       * do not have a common edge.
       */

      if (me->single_sf_lift)
      {
         for (i = 0; i < 3; i++)
           lift_vec[i] = me->to_pt[i] - me->from_pt[i];

         EFprepare_single_sf_lift ( &mthd_stat, me->surf_info.located_obj,
                 &me->surf_info.module_info, &construct_list, 
                 &me->active_state_GRid, lift_vec);
         ERROR(OM_stat, mthd_stat, "EClm", wrapup);

      } /* if (me->single_sf_lift) */
     
      switch (mytype)
      {
        case LFTVERT:
        {
         which_end_pt =EMS_EDGE_BEG_PT;

         OM_stat = om$send (msg = message EMSsurface.EM_lift(
            &mthd_stat,
            message EMSsf_lift.EMlift_vertex(
                &mthd_stat,
                &me->surf_info.module_info,
                &construct_list,
                me->from_pt,
                me->to_pt,
                me->surf_info.located_obj,
                me->local_info.located_obj,
                which_end_pt,
                active_constraints,
                NULL),
                &me->locmod_obj_GRid),
            targetid = me->single_sf_lift ? me->active_state_GRid.objid :
                                            me->top_lm_GRid.objid,
            targetos = me->top_lm_GRid.osnum);

         ERROR(OM_stat, mthd_stat, "exec, lift_vert", wrapup);
         break;
        }
   
        case LFTEDGE:
        {
          OM_stat = om$send (msg = message EMSsurface.EM_lift(
            &mthd_stat,
            message EMSsf_lift.EMlift_edge(
                &mthd_stat,
                &me->surf_info.module_info,
                &construct_list,
                me->from_pt,
                me->to_pt,
                me->surf_info.located_obj,
                me->local_info.located_obj,
                active_constraints,
                NULL),
            &me->locmod_obj_GRid),
        targetid = me->single_sf_lift ? me->active_state_GRid.objid :
                                        me->top_lm_GRid.objid,
        targetos = me->top_lm_GRid.osnum);

          ERROR(OM_stat, mthd_stat, "exec, lift_edge", wrapup);
          break;
        }

        case LFTFACE:     
        {
#if !ASSOC
        OM_stat = om$send (msg = message EMSsurface.EM_lift(
            &mthd_stat,
            message EMSsf_lift.EMlift_face(
                &mthd_stat,
                &me->surf_info.module_info,
                &construct_list,
                me->from_pt,
                me->to_pt,
                me->surf_info.located_obj,
                active_constraints,
                NULL,
                EMS_DO_DISPLAY, NULL, NULL),
            &me->locmod_obj_GRid),
        targetid = me->single_sf_lift ? me->active_state_GRid.objid :
                                        me->top_lm_GRid.objid,
        targetos = me->top_lm_GRid.osnum);
#else
        {
          IGRlong               rc, ii;
          struct EMSvector_info vect_info;
          struct EMSvalue_info  mag_info;
        
          vect_info.type = EMSdatainfo_numeric;

          for(ii=0; ii<3; ii++)
          {
            vect_info.vec[ii] = me->to_pt[ii] - me->from_pt[ii];
          }

          BSnorvec(&rc, vect_info.vec);
          if (BSERROR(rc)) goto wrapup;

          mag_info.type = EMSdatainfo_numeric;

          mag_info.val = BSdistptpt(&rc, me->from_pt, me->to_pt);
          if (BSERROR(rc)) goto wrapup;          

          me->locmod_obj_GRid.objid = NULL_OBJID;

#if TEST_NORMAL_LIFT
fprintf(stderr,"LIFT FACE NORMAL-TO-SURFACE TEST!\n");
/*****************************************************************************
          OM_stat = EFlift_face(&mthd_stat,
                                NULL,
                                &me->surf_info,
                                NULL, &mag_info, FALSE,
                                &construct_list, &me->locmod_obj_GRid,
                                (me->associative_flag) ?
                                NULL : EFfunc_PLACE_NON_ASSOC);
*****************************************************************************/
          OM_stat = ems$lift_face(msg = &mthd_stat,
                                surface = &me->surf_info,
                                magnitude = &mag_info,
                                construction_list = &construct_list,
                                resultant_obj = &me->locmod_obj_GRid,
     general_options = (me->associative_flag) ? NULL : EFfunc_PLACE_NON_ASSOC);                         
#else
/*****************************************************************************
          OM_stat = EFlift_face(&mthd_stat,
                                NULL,
                                &me->surf_info,
                                &vect_info, &mag_info, NULL,
                                &construct_list, &me->locmod_obj_GRid,
                                (me->associative_flag) ?
                                NULL : EFfunc_PLACE_NON_ASSOC);
*****************************************************************************/
          OM_stat = ems$lift_face(msg = &mthd_stat,
                                  surface = &me->surf_info,
                                  vector = &vect_info,
                                  magnitude = &mag_info,
                                  construction_list = &construct_list,
                               resultant_obj = &me->locmod_obj_GRid,
    general_options = (me->associative_flag) ? NULL : EFfunc_PLACE_NON_ASSOC);  
#endif

        }
#endif                              

         ERROR(OM_stat, mthd_stat, "exec, lift face", wrapup);
         break;
        }
     } /* switch*/

    break;
    } /*switch*/
    
    case MVVERT:
    case MVEDGE:
    case MVFACE:
    {
       /*Perform the move operation*/

       switch(mytype)   
       {
         case MVFACE:
              move_type = EMS_MOVE_FACE;
              which_end_pt = NULL;
              break;
         case MVEDGE:
              move_type = EMS_MOVE_EDGE;
              which_end_pt = NULL;
              break;
         case MVVERT:
              move_type = EMS_MOVE_VERTEX;
              which_end_pt = EMS_EDGE_BEG_PT;
              break;
       }

       {
         IGRlong msg1;                             /*DECLARE*/       
         IGRshort display_option = EMS_DO_DISPLAY;

         OM_stat = om$send(msg = message EMSsurface.EMlmmove(&mthd_stat, 
                              message EMSsurface.EMmove(
                              &msg1, move_type, 
                              me->local_info.located_obj,
                              me->from_pt, me->to_pt,
                              which_end_pt, &me->surf_info.module_info, 
                              &display_option),
                              &me->locmod_obj_GRid),
                       targetid = me->top_lm_GRid.objid,
                       targetos = me->top_lm_GRid.osnum);

          if (msg1 == EMS_I_DiffSrfOrder)
          {
            ex$message(msgnumb=EMS_S_SrfsOfDiffOrdMvUnsucc); 
            ems_sleep(2);
            me->state = start;
             
            if (me->top_lm_active)
            {
              OM_stat = EFredo_to_top(&mthd_stat, &me->active_state_GRid,
                               &me->surf_info.module_info, &me->num_states,
                               me->state_list);
              ERROR(OM_stat, mthd_stat, "EClcexec, EFredo_to_top", wrapup);

              me->top_lm_active = FALSE;
            }
          }
       
          ERROR(OM_stat, mthd_stat, "exec, EMmove", wrapup);
       }
       break;
     }
 
    } /* end switch */ 
    break;
   }


   case undo:
   {
    GRobjid *display_ids = NULL;
    IGRint  display_count = 0;
    IGRint invoke_cnt=0;

    OM_stat = dp$erase_hilite(msg = &mthd_stat);

    /* AMD : 1/29/92 : Fix for TR 92n0288 
       The following piece of code will exist as long as 
       Move is not associative */

    if(( mytype==MVFACE) || (mytype == MVEDGE) || (mytype == MVVERT))
    {
     deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

     /*Send deactivate message to the mod object*/
     OM_stat = om$send(msg = message EMSdpr.EMdeactivate(&mthd_stat,
                             &deactivate_option,
                             &me->local_info.module_info, &display_ids,
                             &display_count),
                   targetid = me->locmod_obj_GRid.objid,
                   targetos = me->locmod_obj_GRid.osnum);
    ERROR(OM_stat, mthd_stat, "exec, deactivate", wrapup);
    }
    /* end AMD modification */

    deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
    OM_stat = om$send(msg = message EMSdpr.EMundo(&mthd_stat,
                              (IGRushort *)&deactivate_option,
                              &me->local_info.module_info,
                              NULL,
                              NULL,
                              NULL,  
                              &display_ids,
                              &display_count,
                              &invoke_cnt),
                    targetid = me->locmod_obj_GRid.objid,
                    targetos = me->locmod_obj_GRid.osnum);
    ERROR(OM_stat, mthd_stat, "exec, deactivate", wrapup);

    /*
     * If it is a single_sf_lift, the active_state_GRid is the
     * EMSsldlift object created in preparation mode. There for,
     * undo the active_state also. Also, update the active state
     * GRid after deactivate.
     */

    if (me->single_sf_lift)
    {
      OM_stat = om$send(msg = message EMSdpr.EMdeactivate(&mthd_stat,
                            &deactivate_option,
                            &me->local_info.module_info, &display_ids,
                            &display_count),
                  targetid = me->active_state_GRid.objid,
                  targetos = me->active_state_GRid.osnum);
      ERROR(OM_stat, mthd_stat, "exec, deactivate", wrapup);

      OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (
                             &mthd_stat, &me->active_state_GRid,
                             &me->top_lm_GRid),
                        targetid = me->surf_info.located_obj.objid,
                        targetos = me->surf_info.located_obj.osnum);

      ERROR(OM_stat, mthd_stat, "exec, getacid", wrapup);

    } /* if (me->single_sf_lift) */

    Display_Mode = GRbd;
    for(i=0; i<display_count; i++)
    {
      if (om$is_objid_valid(
                 objid = display_ids[i],
                 osnum = me->locmod_obj_GRid.osnum) == OM_S_SUCCESS)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                              &me->surf_info.module_info.md_env.matrix_type,
                              me->surf_info.module_info.md_env.matrix,
                              &Display_Mode, 
                              &me->surf_info.module_info.md_id),
                        targetid = display_ids[i],
                        targetos = me->surf_info.located_obj.osnum);
        ERROR(OM_stat, mthd_stat, "exec, GRdisplay", wrapup);
      }
    }      

    if (display_ids) om$dealloc(ptr = display_ids);

    Display_Mode = GRhd;
    switch (mytype)
    {
      case LFTVERT:
      case LFTEDGE:
      case MVVERT:
      case MVEDGE:

        if(mytype==LFTEDGE || mytype==MVEDGE)
           display_flag = EMS_WHL_EDGE;
        else
           display_flag = EMS_EDGE_BEG_PT;    

        OM_stat = om$send(
            msg = message EMSedge.EMdisplay(&mthd_stat, NULL,
                &me->surf_info.module_info.md_env.matrix_type,
                me->surf_info.module_info.md_env.matrix,
                &Display_Mode, NULL, display_flag, NULL),
          targetid = me->local_info.located_obj.objid,
          targetos = me->local_info.located_obj.osnum);

        ERROR(OM_stat, mthd_stat, "exec, EMdisplay", wrapup);

        me->edvt_hi = TRUE;
      break;

      case LFTFACE:
      case MVFACE:
       OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat, 
              &me->surf_info.module_info.md_env.matrix_type, 
              me->surf_info.module_info.md_env.matrix, 
              &Display_Mode, 
              &me->surf_info.module_info.md_id),
          targetid = me->surf_info.located_obj.objid,
          targetos = me->surf_info.located_obj.osnum);

      ERROR(OM_stat, mthd_stat, "exec, display", wrapup);

      me->srf_hi = TRUE;
      break;
    
    } /* switch (mytype) */

    if (mytype == LFTFACE) ME.super_cmd->state = got_sf_fr_pt;
    break;
   }


   case add_to_tree:
   {
    ex$message(msgnumb=EMS_P_ClearPromptField);

    if (me->top_lm_active) 
    ex$message(msgnumb=EMS_S_PerfmReexec);

    /*
     * If it is a single surface lift, merge EMSsldlift class
     * object constructed in EFprepare_single_sf_lift() with 
     * EMSsldlift class object constructed above.
     */

    if (me->single_sf_lift)
    {
      EFmerge_single_sf_lift_states (&mthd_stat,
                  me->active_state_GRid, me->locmod_obj_GRid,
                  me->surf_info.located_obj, &me->surf_info.module_info);
      ERROR(OM_stat, mthd_stat, "exec, merge single sf lift", wrapup);

    } /* if (me->single_sf_lift) */
    else if (mytype != LFTFACE)
    {
      add_option = EMS_DO_DISPLAY;
      OM_stat = om$send(msg = message EMSsfdpr.EMadd(&mthd_stat, 
                              (me->top_lm_active ? &me->top_lm_GRid :
                                                   &me->active_state_GRid),
                              (me->top_lm_active ? &me->active_state_GRid :
                                                   NULL), 
                              &me->surf_info.module_info, (IGRushort *)&add_option),
                        targetid = me->locmod_obj_GRid.objid,
                        targetos = me->locmod_obj_GRid.osnum);
      if (! (1 & OM_stat & mthd_stat))
      {
        me->top_lm_active = FALSE;
        ERROR(OM_stat, mthd_stat, "exec, EMadd", wrapup);
      }

      if (mthd_stat == EMS_I_BoolFail)
      {
        /*Delete the lm state*/
        OM_stat = om$send(msg = message GRgraphics.GRdelete(&mthd_stat,
                              &me->surf_info.module_info),
                        targetid = me->locmod_obj_GRid.objid,
                        targetos = me->locmod_obj_GRid.osnum);
        ERROR(OM_stat, mthd_stat, "exec, GRdelete", wrapup);
      }

      me->top_lm_active = FALSE;
    } /* else for if (me->single_sf_lift) */

    ex$message(msgnumb=EMS_S_ClearStatusField);

    if (!gothru)
    {
      /*Place accept event on the software stack*/
      qsize = sizeof(me->locate_event.event) + sizeof (IGRint);
      OM_stat = ex$putque(msg = &mthd_stat, 
                          response = response, 
                          byte = &qsize,
                          buffer = (char *)&me->locate_event.event);
      ERROR(OM_stat, EMS_S_Success, "EClocmod_exec put que", wrapup);
    }
    else
    {
      gothru = FALSE;
      ME.COconst->action = NIL;
      return (OM_stat);
    }

    break; 
   }

   default:
    *response = TERMINATE;
    return OM_E_ABORT;

  } /* switch (ME.COconst->action) */



  switch(ME.super_cmd->state)
  {

   case start:
   {
    me->srf_hi = FALSE;
    me->edvt_hi = FALSE;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   

    if ((mytype == LFTFACE) || (mytype == MVFACE))
    {
     display_flag = 7; /**don't project accept point on surface**/
     ex$message(msgnumb = EMS_P_00031, buff = loc_prompt);
     ex$message(msgnumb = EMS_P_00039, buff = acc_prompt); 
     ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);
    }
    else
    {
     display_flag = 3;  /**project accept point on surface**/
     ex$message(msgnumb = EMS_P_00031, buff = loc_prompt);
     ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);
     if ((mytype == LFTEDGE) || (mytype == MVEDGE))
      ex$message(msgnumb = EMS_P_AcptByIdntEdgRej, buff = acc_prompt)
     else
      ex$message(msgnumb = EMS_P_AcptByIdntVtxRej, buff = acc_prompt); 
    }

    strcpy(attr.classes, "EMSsurface");
    attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
    attr.owner_action = LC_RIGID_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS | 
                        LC_LOCALMOD;

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass = OPP_EMSsubbs_class_id;

      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      lc$locate(rc = &mthd_stat, 
                       event1 = &me->locate_event, 
                       event2 = &me->locate_event,
                       mask1 = locate_mask, mask2 = accept_mask, 
                       eventsize= &size, display_flag = display_flag,
                       response = response, response_data = response_data, 
                       locate_prompt = loc_prompt, 
                       acc_prompt = acc_prompt,
                       relocate_prompt = reloc_prompt, 
                       attributes = &attr, 
                       stack = &me->locate_stack, 
                       rtree_classes = &rtree_classes, 
                       eligible_classes = &elig_classes);


    ERROR(OM_stat, EMS_S_Success, "exec, locate", wrapup);

    token = GRloc_token(&mthd_stat, Tokens, &me->locate_event);
    break;
   }


   case got_sf_fr_pt:
   case got_edvt_fr_pt:
   {
    mask = GRm_DATA | GRm_BACK_UP;
    ex$message(msgnumb=EMS_P_00050); 

    /*draw a weighted point for from point*/

    ECdisplayPointSetByBuffer(&mthd_stat, ME.COconst->ActiveDisplay,
                               ME.COroot->ModuleInfo, my_id, 1,
                               me->from_pt, TRUE);

    ERROR(OM_S_SUCCESS, mthd_stat, "exec, dis_pt_set", wrapup);

    EFrblineseg(me->from_pt, &ME.COconst->ActiveDisplay);

    OM_stat = ems$getevent(msg = &mthd_stat,
                           event_mask = mask,
                           event = &me->locate_event,
                           response = (long *)response,
                           response_data = response_data);
    token = GRloc_token(&mthd_stat, Tokens, &me->locate_event);
 
    OM_BLOCK_MOVE(&me->locate_event, &me->to_pt_event,
                  sizeof(struct GRevent));

    ERROR(OM_stat, mthd_stat, "exec, get_token", wrapup);
    break;
   }

    
   case got_sf_wfr_pt:
   case got_edvt_wfr_pt:
   {
    mask = GRm_DATA | GRm_BACK_UP;
    ex$message(msgnumb=EMS_P_00049); 

    /*erase a weighted point for from point*/

    ECdisplayPointSetByBuffer(&mthd_stat, ME.COconst->ActiveDisplay,
                               ME.COroot->ModuleInfo, my_id, 1,
                               me->from_pt, FALSE);
    ERROR(OM_S_SUCCESS, mthd_stat, "EClcmod_exec, dis_pt_set_buff", wrapup);

    OM_stat = ems$getevent(msg = &mthd_stat,
                           event_mask = mask,
                           event = &me->locate_event,
                           response = (long *)response,
                           response_data = response_data);
    token = GRloc_token(&mthd_stat, Tokens, &me->locate_event);
 
    OM_BLOCK_MOVE(&me->locate_event, &me->from_pt_event,
                  sizeof(struct GRevent));

    ERROR(OM_stat, mthd_stat, "exec, get_token", wrapup);
    break;
   }


   case got_sf_loc_pt:
   {
     /*Dehilite the surface*/
     OM_stat = dp$erase_hilite(msg = &mthd_stat);

     /*get the stack of edges or vertices for the surface */

    if ((mytype == LFTVERT) || (mytype == MVVERT))
            select_option = EMS_OPT_NON_DEG_SEAM_XYZCLSD;
    else select_option = EMS_OPT_NONDEG_NONSEAM;

    ed_GRids = NULL;
    array_size = num_edges = NULL;   
    OM_stat = om$send(msg = message EMSsubbs.EMget_edges(&mthd_stat, MAXINT,
                            select_option, &me->surf_info.module_info,
                            &ed_GRids, &array_size, &num_edges),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, mthd_stat, "exec, get_edges", wrapup);

    if (! num_edges)
    {
        switch(mytype)
        {
            case LFTVERT:
             ex$message(msgnumb=EMS_S_SrfDoesNtHaveVrtx);
             break;
    
            case LFTEDGE:
             ex$message(msgnumb=EMS_S_SrfDoesNtHaveEdge); 
             break;
        }
        ME.super_cmd->state = got_sf_wloc_pt;
        token = 0;    /* for EX_BACK_UP */
        break;
    }

    switch(mytype)
    {
       case LFTVERT:
       case MVVERT:
        me->ed_vt_display_flag = EMS_EDGE_BEG_PT;
        object_type = EMS_GET_MOD_VERT;
        ex$message(msgnumb = EMS_P_AcptWthFrRejVtx, buff = acc_prompt);
        break;
    
       case LFTEDGE:
       case MVEDGE:
        me->ed_vt_display_flag = EMS_WHL_EDGE;
        object_type = EMS_GET_MOD_EDGE;
        ex$message(msgnumb = EMS_P_AcptWthFrRejEdg, buff = acc_prompt);
        break;
    }
    
    OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                             &me->surf_info.module_info.md_env.matrix_type, 
                             me->surf_info.module_info.md_env.matrix, 
                             &srf_size),
                       targetid = me->surf_info.located_obj.objid,
                       targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, mthd_stat, "exec, getsize error", wrapup);

    srf_geom = (struct IGRbsp_surface *) om$malloc (size = srf_size);
    
    OM_stat = om$send(msg = message GRvg.GRgetgeom (&mthd_stat,
                            &me->surf_info.module_info.md_env.matrix_type, 
                            me->surf_info.module_info.md_env.matrix, 
                            (IGRchar *) srf_geom),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, mthd_stat, "exec, getsize error", wrapup);

    accept_mask = GRm_DATA | GRm_BACK_UP;
    OM_stat = EMtpselect(&mthd_stat, ed_GRids, 
                         me->surf_info.located_obj,
                         num_edges, object_type, srf_geom, 
                         me->locate_event,
                         &me->surf_info.module_info,
                         acc_prompt, &accept_mask,
                         &size, response, response_data,
                         &me->locate_event, &me->edvt_hi);
    ERROR(OM_stat, mthd_stat, "exec, tpselect", wrapup);

    token = GRloc_token(&mthd_stat, Tokens, &me->locate_event);

    if ((Tokens[token] == GR_UNKNOWN_TYPE) ||
        (Tokens[token] == EX_BACK_UP))
        break;

    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->local_info, sizeof(struct GRlc_info));

    if ((mytype == MVEDGE || mytype == MVVERT) && (token == 1))
    {
      OM_stat = om$send(msg = message EClocalmod.ECvalidate(&mthd_stat,
                              EC_DO_EDGE),
                        targetid = my_id);
      ERROR(OM_stat, mthd_stat, "EClcmod_exec, ECvalidate", wrapup);

      if (mthd_stat == EMS_I_Stop)
      {
         goto_nextstate = FALSE; 
         me->action = NIL;
         token = 0;
      }
    }
    break;
   }


   case got_sf_wloc_pt:
   {
    /*erase a weighted point for from point*/

    ECdisplayPointSetByBuffer(&mthd_stat, 
                              ME.COconst->ActiveDisplay,
                              ME.COroot->ModuleInfo, my_id, 1,
                                me->from_pt, FALSE);
    ERROR(OM_S_SUCCESS, mthd_stat, "EClcmod_exec, dis pt set buff", wrapup);

    mask = GRm_DATA | GRm_BACK_UP;
    switch (mytype)
    {
      case LFTVERT:
      case MVVERT:
        ex$message(msgnumb=EMS_P_VertexNotFound);
        ex$message(msgnumb=EMS_P_IdntVrtx);
        break;
      case LFTEDGE:
      case MVEDGE:
        ex$message(msgnumb=EMS_P_EdgeNotFound);
        ex$message(msgnumb=EMS_P_IdentifyEdge);
        break;
    }

    token = GRget_token(&mthd_stat, Tokens, &mask, 
                      &me->locate_event, &size, 
                      response, response_data);
    ERROR(OM_stat, mthd_stat, "exec, gettoken", wrapup);
    break;
   }


   case got_to_pt:
   {
     ck_coinc = FALSE;

     if (mytype == MVFACE || 
         mytype == MVEDGE ||
         mytype == MVVERT ||
         mytype == LFTFACE ||
         me->single_sf_lift)
     {
       token = 2; /*SIMULATE MOVE ON EVENT*/
       break;
     }      

     mask = GRm_BACK_UP | GRm_TEXT_VALUE | GRm_RJT_MOVEON;

     co$getevent (
        msg = &mthd_stat,
        event_mask = mask,
        prompt = "Check for coincidence?(y/n) [n]",
        response = response,
        response_data = response_data,
        event = &me->locate_event);

     if (mthd_stat == GRw_no_value)
       me->locate_event.response = EX_RJT_MOVEON;

     switch (me->locate_event.response)
     {
       case STRING:
       {
         token = 2;  /*SIMULATE MOVE ON*/
         if (toupper(me->locate_event.event.keyin[0]) == 'Y')
           ck_coinc = TRUE;
         break;
       }
       case EX_RJT_MOVEON:
       {
         token = 2;  /*SET TOKEN TO MOVE ON*/
         break;
       }
       case EX_BACK_UP:
       {
         token = 0;  /*SET TOKEN TO BACK UP*/
         break;
       }
       default:
       {
         token = 3;  /*SET TOKEN TO UNKNOWN*/
         break;
       }
     }

     break;
   }


   case fini:
   {
       ex$message(msgnumb=EMS_S_ClearStatusField);

       mask = GRm_BACK_UP | GRm_DATA;
       if (me->top_lm_active)
         ex$message(msgnumb=EMS_P_AccWithNxtEvntToReexec)
       else
         ex$message(msgnumb=EMS_P_AccwAnyEventBackupForUndo);

       token = GRget_token(&mthd_stat, Tokens, &mask, 
                           &me->locate_event, &size, 
                           response, response_data);
       ERROR(OM_stat, mthd_stat, "exec, gettoken", wrapup);

       if (Tokens[token] == GR_UNKNOWN_TYPE) 
           gothru = TRUE;
       else
           gothru = FALSE;

       ex$message(msgnumb=EMS_S_ClearStatusField);
       break;
   }


   default:
   {
        *response = TERMINATE;
        return OM_E_ABORT;
   }

  } /*switch(ME.super_cmd->state) */

  prevstate = ME.super_cmd->state;  
  if (goto_nextstate)
  {
    me->action = NextAction[ME.super_cmd->state][token];
    ME.super_cmd->state = NextState[ME.super_cmd->state][token];
  }
  else
    goto_nextstate = TRUE;

  if (((mytype != LFTFACE) && (mytype != MVFACE)) && 
     (ME.super_cmd->state == got_sf_fr_pt) && (Tokens[token] == DATA))
  {
    ME.super_cmd->state = got_sf_loc_pt;
  }
  else if ( (mytype != MVFACE && mytype != MVEDGE && mytype != MVVERT &&
             !me->single_sf_lift) && 
              (ME.super_cmd->state == got_sf_fr_pt) && 
              (prevstate != got_to_pt) &&
              (Tokens[token] == EX_BACK_UP) ) 
  {
    ME.super_cmd->state = got_to_pt;    
  }            

  continue_while = Tokens[token] != GR_UNKNOWN_TYPE;

  if (gothru) continue_while = TRUE;

 } while(continue_while);

 return (OM_stat);

 wrapup:
   *response = TERMINATE;
   return OM_E_ABORT;

}  /*method execute*/

method ECvalidate(IGRlong *EMmsg; IGRushort val_option)
{
  IGRlong     OM_stat;
  IGRshort    modif, which_end_pt = 0, option = 0;


  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /* Added 8/9/88 by DLB: If the region is modifiable then perform the op
   * on the top of the tree.  If not then see if the path to the surface
   * is recomputable (all booleans).  If so then undo to the top lm state.
   * If modifiable now then do the op.
   */

  modif = TRUE;
  if (val_option == EC_DO_SURF)
  {
    switch (ME.super_cmd->mytype)
    {
      case LFTFACE: option = EMS_LIFT_FACE; break;
      case LFTEDGE: 
      case MVEDGE:  option = EMS_LIFT_EDGE; break;
      case LFTVERT:
      case MVVERT:  option = EMS_LIFT_VERTEX; break;
      case MVFACE:  option = EMS_MOVE_FACE; break;
    }    
    OM_stat = EFis_surf_modif(EMmsg, me->surf_info.located_obj,
                              option, &modif);
    ERROR(OM_stat, *EMmsg, "ECval EFis_surf_modif", wrapup);
  }
  else
  {
    switch (ME.super_cmd->mytype)
    {
      case MVEDGE: option = EMS_MOVE_EDGE; break;
      case MVVERT: option = EMS_MOVE_VERTEX;
                   which_end_pt = EMS_EDGE_BEG_PT;
                   break;
    }    
    OM_stat = EFis_edge_modif(EMmsg, 
                             me->locate_event.located_object[0].located_obj,
                             option, which_end_pt, &modif);
    ERROR(OM_stat, *EMmsg, "ECval, EFis_edge_modif", wrapup);
  }

  if (modif) goto wrapup; /*Active state is modif so do the op.*/

#if REMOVE_THIS_CAUSE_CAN_NO_LONGER_HAVE_UNDO_RECOMPUTE
  if (me->active_state_GRid.objid == me->top_lm_GRid.objid)
#endif
  {
    ex$message(msgnumb=EMS_S_FacsWithBoundCantLocMod);
    OM_stat = dp$erase_hilite(msg = EMmsg);
    me->state = 0;     /*HARD CODE start */
    me->top_lm_active = FALSE;
    me->srf_hi = FALSE;
    *EMmsg = EMS_I_Stop;
    goto wrapup;  /*Not modif and no tree so cant even undo.*/
  }

#if REMOVE_THIS_CAUSE_CAN_NO_LONGER_HAVE_UNDO_RECOMPUTE
  me->num_states = 0;
  active_state = NULL;
  OM_stat = EFundo_to_lm(EMmsg, &me->surf_info.located_obj,
                         &me->top_lm_GRid, &me->active_state_GRid,
                         &me->surf_info.module_info, &me->num_states,
                         &active_state);
  ERROR(OM_stat, *EMmsg, "ECval, EFundo_to_lm", wrapup);

  me->top_lm_active = TRUE;
  
  if (me->num_states > om$dimension_of(varray =me->state_list)) 
  {
    OM_stat = om$vla_set_dimension(varray = me->state_list,
                                   size = me->num_states);
    ERROR(OM_stat, *EMmsg, "ECval, set vla", wrapup);
  }

  OM_BLOCK_MOVE(active_state, me->state_list,
                me->num_states * sizeof(struct GRid));

  if (active_state) om$dealloc(ptr = active_state);
 
  if (ME.super_cmd->mytype == LFTFACE || 
      ME.super_cmd->mytype == MVFACE)
  {
    enum    GRdpmode  Display_Mode = GRhd;
    OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                            &me->surf_info.module_info.md_env.matrix_type,
                            me->surf_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->surf_info.module_info.md_id),
                      targetid = me->surf_info.located_obj.objid,
                      targetos = me->surf_info.located_obj.osnum);
    ERROR(OM_stat, *EMmsg, "ECval, GRdisplay", wrapup);
  }

  ex$message(msgnumb=EMS_S_ClearStatusField);

  /*See if modifiable now.  If not then redo back to top and tell user*/
  modif = TRUE;
  if (val_option == EC_DO_SURF)
  {
    OM_stat = EFis_surf_modif(EMmsg, me->surf_info.located_obj,
                              option, &modif);
    ERROR(OM_stat, *EMmsg, "ECval, EFis_surf_modif", wrapup);
  }
  else
  {
    OM_stat = EFis_edge_modif(EMmsg, 
                             me->locate_event.located_object[0].located_obj,
                             option, which_end_pt, &modif);
    ERROR(OM_stat, *EMmsg, "ECval, EFis_edge_modif", wrapup);
  }

  if (!modif)
  {
    OM_stat = EFredo_to_top(EMmsg, &me->active_state_GRid,
                            &me->surf_info.module_info, &me->num_states,
                            me->state_list);
    ERROR(OM_stat, *EMmsg, "ECval, EFredo_to_top", wrapup);

    ex$message(msgnumb=EMS_S_FacsWithBoundCantLocMod);  
    me->top_lm_active = FALSE;
    me->srf_hi = FALSE;
    me->state = 0;     /*HARD CODE start */
    *EMmsg = EMS_I_Stop;
    goto wrapup; /*Even at top lm state it is not modif.*/
  }
#endif

  wrapup:
    return (OM_stat);
}
end implementation EClocalmod;
