/* ###################   APOGEE COMPILED   ################## */
/*
History 
    Ramana  08/16/95 Removed values.h as bsvalues.h is changed.
    Sudha  07/05/93  Modified for BSprototypes ansification
    Kumar N 1/29/93  Port to WINDOWS NT
    NP     07/22/92  Updated for message subsystem compliance.
    DLB    04/01/92  Check for consistent draft directions for edges.
    NP     03/22/92  Refixed TR92n2257. After lifting, the "eds_info" pointers
                     were getting reset, which was a problem on backup to redo 
                     the operation. Such info is now saved before the call to
                     the "EFdrafted_lift" function & then reset after the call.
    NP     03/20/92  Undid Dave's fix for TR 92N2257 by using previous
                     version of this file (201.16). Also made a small change
                     where surface fillets were not getting produced even when
                     asked for. This fixes TRs 92n2982, 92n2986 & 92n2256. Fix
                     will still need to be put in for TR 92N2257.
    Tapadia 02 Dec 91 Added a few checks because lift/dlift is in one function.
    AIC    06 Oct 91 Changed arguments to EMget_ele_header.
    SCW    08/08/91  Modified to use Grnuc associative flag
    RC     11/28/89  Fixed a few logical bugs.
    DLB    08/17/88  Remove undo/recompute code.
    DLB    07/20/88  Don't check getevent return code if mask is MOVEON and
                     STRING.  Set event.response to MOVEON if return code
                     is GRw_no_value.
    Chopra xx/xx/88  Creation.
*/
class implementation ECdlift;

#include <stdio.h>
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
#include "emserr.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "EMSlmdef.h"
#include "emsdef.h"
#include "EMSlift.h"
#include "bsicmpcvoff.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "EMSasmacros.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSasopts.h"
#include "bsparameters.h"
#ifdef NT
#include "bsvalues.h"
#endif

%safe
#include "math.h"
%endsafe
#include "msmacros.h" /* ex$message */
#include "ECcmd.h"
#include "ECmsg.h"
#include "bsvalues.h"
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

#define DEG_TO_RAD M_PI/180
#define ABS(X) ((X) >= 0 ? (X) : -(X))

#define ID_SF                 0
#define FROM_PT               1
#define TO_PT                 2
#define SF_DRAFT_ANGLE        3
#define SF_FILLET             4
#define CHK_COINCIDENCE       5
#define PROCESS               6
#define ADD_TO_TREE           7
#define LP_DRAFT_ANGLE        8
#define ED_DRAFT_ANGLE        9
#define ED_DRAFT_MODE         10
#define ED_DRAFT_ANGLE_MODE   11
#define LP_FILLET             12


#define LAST_STATE_SF_DANGLE        1
#define LAST_STATE_LP_DANGLE        2
#define LAST_STATE_ED_DANGLE        3
#define LAST_STATE_ED_DMODE         4 
#define LAST_STATE_ED_DANGLE_MODE   5
#define LAST_STATE_SF_FILLET        6
#define LAST_STATE_LP_FILLET        7

from EMSsurface     import  EMgetactiveid, EMmake_active_state,
                            EMlift_face_w_draft, EMmk_nat_bdry;
from EMSsubbs       import  EMget_ele_header;
from EMSsfdlift     import  EMlift_face;
from EMSsfdpr       import  EMadd;
from EMSdpr         import  EMundo, EMdeactivate;
from GRgraphics     import  GRdisplay, GRdelete;
from EMSboundary    import  EMget_edges, EMtree_traverse;
from EMSloopset     import  EMget_loops;
from EMSedge        import  EMdisplay ;
from GRowner        import  GRget_number_components;

extern OMuword   OPP_EMSsubbs_class_id;

#define DLFT 0
#define LFT  1


method wakeup (IGRint pos)
{
 enum GRdpmode Display_Mode = GRhd;
    IGRlong       OM_stat = OM_S_SUCCESS;
   IGRlong   mthd_stat = EMS_S_Success;
 
 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_ClearStatusField);

 if (me->mytype == DLFT)
 {
   ex$message(msgnumb = EM_M_LiftFaceWithDraft);
 }
 else
 {
   ex$message(msgnumb = EM_M_LiftFace);
 }

 if (me->sf_hi)
 { 
   OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat, 
                      &me->sf_info.module_info.md_env.matrix_type, 
                       me->sf_info.module_info.md_env.matrix, 
                           &Display_Mode, 
                           &me->sf_info.module_info.md_id),
                    targetid = me->sf_info.located_obj.objid,
                    targetos = me->sf_info.located_obj.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),OM_stat,OM_E_ABORT,wrapup);
 }

 {
  IGRboolean    state;

  gr$get_associative_flag( buffer = &state );
  if (state)
  {
    GRdisplay_associative_button(TRUE);
    me->associative = TRUE;
  }
 }

wrapup:
  EMWRAPUP (mthd_stat, OM_stat, "In ECdlift.wakeup");
  return (OM_stat);
}

method sleep(int pos)
{
 IGRint  OM_stat = OM_S_SUCCESS;
 IGRint   mthd_stat = EMS_S_Success;
 
 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_ClearStatusField);
 ex$message(msgnumb = EM_M_ClearMessageField);

 if (me->sf_hi)
 { 
   OM_stat = dp$erase_hilite(msg = &mthd_stat);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),OM_stat,OM_E_ABORT,wrapup);
 }

 if (me->associative) GRdisplay_associative_button(FALSE);

 wrapup:
  EMWRAPUP (mthd_stat, OM_stat, "In ECdlift_sleep");
  return (OM_stat);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
 struct GRvg_construct     construct_list;
 struct GRevent            event, accept_event;
 struct GRlc_locate        attributes;
 struct GRid               *ed_GRids;
 struct IGRbsp_surface     *sf_geom;
 struct EMSdlft_lp_info    *lp_info;
 struct EMSdlft_ed_info    *ed_info, *last_ed_info, *next_ed_info;
 union  IGRele_attr        ele_spec_att;
 struct DPele_header       sf_ele_header;
 struct IGResqbs           bsqsurf;
 struct GRsymbology        symb;
 OM_S_CLASSLIST            rtree_classes, elig_classes;
 OM_S_CHANSELECT           sf_ls_chan;
 OM_S_OBJECT_LINKAGE       ls_list;
 enum  GRdpmode            Display_Mode;

 GRrange                   range;
 IGRdouble                 u, v, sf_pt[3], draft_angle, u_v[2]; 
 extern IGRdouble          fabs();

 OMuint                    count;
 IGRint                    size, object_was_located, display_flag, mask,
                           locate_mask, accept_mask, i, j, token, 
                           buf_size, array_size, depth, num_lps,
                           cum_num_eds, num_lp_eds, cur_ed, num_sfs, c_mem;

 IGRint                    EFdyvector();

 IGRlong                   OM_stat;
 IGRlong                   mthd_stat;
 IGRlong                   rc, func_stat;
 IGRlong                   EMget_the_geometry ();

 GRobjid                   *lp_ids;

 GRspacenum                sf_os;

 OMuword                   rclass, eliclass;

 IGRushort         active_constraints;
 IGRshort                  deactivate_option;

 IGRboolean                sf_fillet, chk_coincidence = FALSE, sf_ele_header_good,
                           nghbr_ed_lvarying;

 IGRchar                   locate_prompt[52], accept_prompt[52], 
                           relocate_prompt[52];

 void                      EFget_sf_ele_header(),
                           EFprepare_single_sf_lift(), 
                           EFmerge_single_sf_lift_states();

#   define NUM_TOKENS 6

/* */ static /* */ int Tokens[NUM_TOKENS] =

{
   EX_BACK_UP, DATA, STRING, EX_VALUE, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
};

/* ********************************************************** */ 

  size = sizeof (struct GRevent);
  OM_stat = OM_S_SUCCESS;
  sf_geom = NULL;
  sf_ele_header_good = FALSE;

  do 
  {
    switch (ME.super_cmd->state)
    {

      case ID_SF:
        me->pos_mag_outside = FALSE;
        me->sf_hi = FALSE;
        sf_geom = NULL;
        sf_ele_header_good = FALSE;
        me->dlift_info.mx_exlp_dangle = 0;
        display_flag = NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT; /*7;*/
        locate_mask = GRm_DATA | GRm_BACK_UP;
        accept_mask = GRm_DATA;
        ex$message(msgnumb = EMS_P_IdentPlnSf,
                   buff    = locate_prompt);
        ex$message(msgnumb = EMS_P_AccRjectSf,
                   buff    = accept_prompt);
        ex$message(msgnumb = EMS_I_PlanarSurfNotFound,
                   buff    = relocate_prompt);
        attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY |
                                LC_PLANAR_ONLY; 
        attributes.owner_action = LC_RIGID_COMP | LC_NO_REF_HEADER |
                                  LC_REF_OBJECTS | LC_LOCALMOD; 
        strcpy(attributes.classes, "EMSsurface");

        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
        rclass = OPP_EMSsubbs_class_id;
        eliclass = OPP_EMSsubbs_class_id;
        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;

        lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                  event2 = &accept_event, mask1 = locate_mask, 
                  mask2 = accept_mask, eventsize= &size, 
                  display_flag = display_flag, response = response, 
                  response_data = response_data, 
                  locate_prompt = locate_prompt, 
                  acc_prompt = accept_prompt,
                  relocate_prompt = relocate_prompt, 
                  attributes = &attributes, 
                  stack = &me->locate_stack, 
                  rtree_classes = &rtree_classes, 
                  eligible_classes = &elig_classes);
               
        if (!object_was_located)
        {
          if (me->locate_event.response == EX_BACK_UP)
            ME.super_cmd->state = ID_SF;
          else
            goto wrapup;

        } /* if (!object_was_located) */
        else
        {
          me->sf_info = accept_event.located_object[0];
          OM_BLOCK_MOVE (&accept_event.event.button, me->from_pt,
                          sizeof(IGRpoint));
          OM_BLOCK_MOVE (&accept_event.event.button, me->to_pt,
                          sizeof(IGRpoint));

          /*
           * get the active state id from the state tree
           */

          OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (
                              &mthd_stat, &me->active_state_GRid, 
                              NULL),
                             targetid = me->sf_info.located_obj.objid,
                             targetos = me->sf_info.located_obj.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

          /*
           * It may be possible that it is a single sf state
           * tree. In such a case the sf_geometry at the current
           * state is to be used.
           */

          if (me->active_state_GRid.objid ==me->sf_info.located_obj.objid)
            me->single_sf_lift = TRUE;
          else
          {
            OM_stat = om$send (
                        msg = message GRowner.GRget_number_components(
                         &mthd_stat, &num_sfs),
                        targetid = me->active_state_GRid.objid,
                        targetos = me->active_state_GRid.osnum);
            EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
            if (num_sfs == 1)
              me->single_sf_lift = TRUE;
            else
              me->single_sf_lift = FALSE;

          } /* else for if (me->active_state_GRid.objid ==
                            me->sf_info.located_obj.objid) */

          if (me->single_sf_lift)  /*DLB 9/12/91*/
          {
            ex$message(msgnumb = EMS_S_SingleSurfNotAllowed);
            me->single_sf_lift = FALSE;
            me->state = ID_SF;
            dp$erase_hilite(msg = &mthd_stat);
            break;      
          }

          me->sf_hi = TRUE;
          ME.super_cmd->state = TO_PT;
          me->last_state_processed = ID_SF;
        } /* else for if (!object_was_located) */

        break;

#if I_EVER_NEED_TO_KEEP_THE_FROM_POINT_PROCESSING_CODE
      case FROM_PT:
        ex$message(msgnumb = EMS_P_00049); /* Input from point */
        mask = GRm_DATA | GRm_BACK_UP;
        token = GRget_token(&rc, Tokens, &mask, &event, &size, response,
                            response_data);
        EMerr_hndlr (!(1&rc),*response,TERMINATE,wrapup);
  
        ex$message(msgnumb = EMS_P_ClearPromptField);

        switch (Tokens[token])
        {
          case EX_DATA:
            OM_BLOCK_MOVE (&event.event.button, me->from_pt,
                            sizeof(IGRpoint));
            OM_BLOCK_MOVE (&event.event.button, me->to_pt,
                            sizeof(IGRpoint));

            ME.super_cmd->state = TO_PT;
            me->last_state_processed = FROM_PT;
            break;

          case EX_BACK_UP:
           if (me->sf_hi)
           {
            OM_stat = dp$erase_hilite(msg = &mthd_stat);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
            me->sf_hi = FALSE;

           }

            ME.super_cmd->state = ID_SF;
            if (sf_geom)  {
               free(sf_geom);  
               sf_geom = NULL;
            }
            break;

          default:
            goto wrapup;

        }

        break;
#endif


      case TO_PT:
        ex$message(msgnumb = EMS_P_InptDestPtDistToLiftMvOnToChgDir);
        ex$message(msgnumb = EMS_I_DistKeyinWillLiftInArrowDir);

        OM_stat = EFshow_normals1(&rc, &me->sf_info.module_info,
                                  &ME.COconst->ActiveDisplay,
                                  GRbd, 
                                  me->pos_mag_outside ? 0x2 : 0x0,
                                  u_v,
                                  me->sf_info.located_obj.objid,
                                  me->sf_info.located_obj.osnum);
        EMerr_hndlr(!(1&rc&OM_stat), *response, TERMINATE, wrapup);        

        /*
         * Get the vector normal to the surface and passing
         * through an area location.
         */
        u = u_v[0];
        v = u_v[1];

        if (!sf_geom)
        {
          func_stat = EMget_the_geometry(&me->sf_info, FALSE, FALSE,
                      FALSE, my_id, (IGRchar **)&sf_geom, &rc);
          EMerr_hndlr (!(1&rc&func_stat),*response,TERMINATE,wrapup);
        } /* if (!sf_geom) */

        BSsfarrevn(&rc, sf_geom, 1, &u, 1, &v, sf_pt, me->sf_nrml);
        EMerr_hndlr(BSERROR(rc), *response, TERMINATE, wrapup);

        BSnorvec(&rc, me->sf_nrml);
        EMerr_hndlr(BSERROR(rc), *response, TERMINATE, wrapup);

        if (!sf_geom->pos_orient)
        {
          me->sf_nrml[0] *= -1;
          me->sf_nrml[1] *= -1;
          me->sf_nrml[2] *= -1;
        }

        OM_BLOCK_MOVE(sf_pt, me->from_pt, sizeof(IGRpoint));
        OM_BLOCK_MOVE(sf_pt, me->to_pt, sizeof(IGRpoint));

        EFdyvector(me->sf_nrml, me->from_pt, me->to_pt,
                   &ME.COconst->ActiveDisplay);

        OM_stat = ems$getevent(msg = &rc,
                               event_mask = GRm_DATA | GRm_VALUE | 
                                            GRm_BACK_UP | GRm_RJT_MOVEON,
                               value_type = GRIO_SCALAR,
                               event = &event,
                               response = (long *)response,
                               response_data = response_data);
        token = GRloc_token(&rc, Tokens, &event);

        EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);
  
        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_ClearStatusField);

        OM_stat = EFshow_normals1(&rc, &me->sf_info.module_info,
                                  &ME.COconst->ActiveDisplay,
                                  GRbe, 
                                  me->pos_mag_outside ? 0x2 : 0x0,
                                  NULL,
                                  me->sf_info.located_obj.objid,
                                  me->sf_info.located_obj.osnum);
        EMerr_hndlr(!(1&rc&OM_stat), *response, TERMINATE, wrapup);        

        switch (Tokens[token])
        {
          case EX_RJT_MOVEON:
          {
            me->pos_mag_outside = !me->pos_mag_outside;
            break;
          }

          case EX_VALUE:
          case EX_DATA:
          {
            if (Tokens[token] == EX_VALUE)
            {
              if (event.event.value < 0.0)
              {
                ex$message(msgnumb = EMS_E_NegativeValueNotAllowed);
                break;
              }
              me->dlift_info.assoc_magnatude.type = EMSdatainfo_event;
              me->dlift_info.assoc_magnatude.valevent =
                                                     &me->event_magnatude_mem; 
              *(me->dlift_info.assoc_magnatude.valevent) = event;
            }
            else
            {
              IGRdouble mag, tol;
              IGRpoint pt_vec;

              /*Assume the EFdyvector call did not modify the to_pt due to 
               * an event generator case.
               */
              { /*TR 92N5987*/
                IGRvector v2, v1;
                IGRdouble lensq, dotp, t;

                v2[0] = event.event.button.x - me->from_pt[0];
                v2[1] = event.event.button.y - me->from_pt[1];
                v2[2] = event.event.button.z - me->from_pt[2];
 
                OM_BLOCK_MOVE(me->sf_nrml, v1, sizeof(IGRvector));

                lensq = v1[0]*v1[0] + v1[1]*v1[1] + v1[2]*v1[2];
                dotp = v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
                t = dotp/lensq;

                me->to_pt[0] = me->from_pt[0] + t * v1[0];
                me->to_pt[1] = me->from_pt[1] + t * v1[1];
                me->to_pt[2] = me->from_pt[2] + t * v1[2];
              }

              /*Figure out if the value should be negative*/
              pt_vec[0] = me->to_pt[0] - me->from_pt[0];
              pt_vec[1] = me->to_pt[1] - me->from_pt[1];
              pt_vec[2] = me->to_pt[2] - me->from_pt[2];            

              BSnorvec(&rc, pt_vec);
              if (rc == BSDGENRAT)
              {
                /*vector is not long enough!!!!!*/
                rc = EMS_S_Success;
                break;
              }

              mag = BSdistptpt(&rc, me->from_pt, me->to_pt);
              EMerr_hndlr(BSERROR(rc), *response, TERMINATE, wrapup);

              BSEXTRACTPAR(&rc, BSTOLLENVEC, tol);
              EMerr_hndlr(BSERROR(rc), *response, TERMINATE, wrapup);

              if (ABS(pt_vec[0] + me->sf_nrml[0]) < tol  &&
                  ABS(pt_vec[1] + me->sf_nrml[1]) < tol  &&
                  ABS(pt_vec[2] + me->sf_nrml[2]) < tol) mag *= -1; /*negdir*/

              if(mag < 0.0) 
              {
                mag *= -1;
                me->pos_mag_outside = TRUE;
              }
              else 
                me->pos_mag_outside = FALSE;

              me->dlift_info.assoc_magnatude.type = EMSdatainfo_numeric;
              me->dlift_info.assoc_magnatude.val = mag;
            }

            ME.super_cmd->state = SF_DRAFT_ANGLE;
            me->last_state_processed = TO_PT;

            /*
             * If there is no loopset attached to the surface,
             * make one and 
             * allocate space for lps_info and eds_info.
             */

            lp_ids = NULL;
  
            OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
            EMerr_hndlr (!(1&OM_stat),*response, TERMINATE, wrapup);

            OM_stat = om$get_channel_count (
                       objid = me->sf_info.located_obj.objid,
                       osnum = me->sf_info.located_obj.osnum,
                       p_chanselect = &sf_ls_chan,
                       count = &count);
            EMerr_hndlr (!(1&OM_stat),*response,TERMINATE,wrapup);
            if (!count)
            {
              OM_stat = om$send (msg = message EMSsurface.EMmk_nat_bdry(
                                  &mthd_stat, &me->sf_info.module_info.md_env,
                                  NULL),
                   targetid = me->sf_info.located_obj.objid,
                   targetos = me->sf_info.located_obj.osnum);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
            } /* if (!count) */

            OM_stat = om$get_channel_objects (
                  objid = me->sf_info.located_obj.objid,
                  osnum = me->sf_info.located_obj.osnum, 
                  p_chanselect = &sf_ls_chan,
                  list = &ls_list, size = 1, count = &count);
            EMerr_hndlr (!(1&OM_stat),*response, TERMINATE, wrapup);
            EMerr_hndlr (count != 1, *response, TERMINATE, wrapup);

            depth = MAXINT;
            buf_size = 0;
            num_lps = 0;
            OM_stat = om$send (msg = message EMSloopset.EMget_loops (
                                &mthd_stat, EMS_OPT_ALL, &depth, &lp_ids, 
                                NULL, &buf_size, &num_lps),
                               targetid = ls_list.S_objid,
                               targetos = ls_list.osnum);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

            if (num_lps > om$dimension_of (varray = me->lps_info) )
            {
              OM_stat = om$vla_set_dimension (varray = me->lps_info,
                                              size = num_lps);
              EMerr_hndlr (!(1&OM_stat), *response, TERMINATE, wrapup);
            } /* if (num_lps > om$dimension_of (varray = me->lps_info) )*/

            me->dlift_info.num_lps = num_lps;
            me->dlift_info.lps_info = me->lps_info;
            me->dlift_info.sf_GRid = me->sf_info.located_obj;
            sf_os = me->sf_info.located_obj.osnum;

            array_size = 0;
            cum_num_eds = 0;
            ed_GRids = NULL;

            for (i = 0; i < num_lps; i++)
            {
               lp_info = &me->lps_info[i];
               lp_info->lp_GRid.objid = lp_ids[i];
               lp_info->lp_GRid.osnum = sf_os;
                   
               num_lp_eds = 0;
               OM_stat = om$send (
                            msg = message EMSboundary.EMget_edges(
                             &mthd_stat, 1, EMS_OPT_NONDEG_NONSEAM, 
                             NULL,&array_size, &num_lp_eds),
                           targetid = lp_ids[i],
                           targetos = sf_os);
               EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,
                            wrapup); 
               cum_num_eds +=  num_lp_eds;

            } /* for (i = 0; i < num_lps; i++) */

            me->dlift_info.num_ed_infos = cum_num_eds;

            if ( cum_num_eds > om$dimension_of(varray = me->eds_info))
            {
              OM_stat = om$vla_set_dimension ( varray = me->eds_info,
                                               size = cum_num_eds);
              EMerr_hndlr (!(1&OM_stat),*response,TERMINATE,wrapup);
            }

            OM_stat = om$vla_set_dimension(varray = me->d_angle_mem,
                                           size = num_lps + cum_num_eds);
            EMerr_hndlr (!(1&OM_stat),*response,TERMINATE,wrapup);

            c_mem = 0;
            cur_ed = 0;
            for (i = 0; i < num_lps; i++)
            {
              num_lp_eds = 0;
              OM_stat = om$send (
                           msg = message EMSboundary.EMget_edges(
                            &mthd_stat, 1, EMS_OPT_NONDEG_NONSEAM, 
                            &ed_GRids,&array_size, &num_lp_eds),
                          targetid = lp_ids[i],
                          targetos = sf_os);
              EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,
                           wrapup); 
              lp_info = &me->dlift_info.lps_info[i];
              lp_info->assoc_draft_angle.valevent = &me->d_angle_mem[c_mem++];
              lp_info->eds_info = &me->eds_info[cur_ed];
              lp_info->num_eds = num_lp_eds;

              for (j = 0; j < num_lp_eds; j++, cur_ed++)
              {
                me->eds_info[cur_ed].ed_GRid = ed_GRids[j];
                me->eds_info[cur_ed].assoc_draft_angle.valevent = 
                                                    &me->d_angle_mem[c_mem++];
              }

            } /* for (i = 0; i < num_lps; i++) */
                 
            if (lp_ids) om$dealloc (ptr = lp_ids);
            if (ed_GRids) om$dealloc (ptr = ed_GRids);
            break;
          }

          case EX_BACK_UP:
          {
            if (me->sf_hi)
            {
              OM_stat = dp$erase_hilite(msg = &mthd_stat);
              EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
              me->sf_hi = FALSE;
            }
            /* fix for mlk */
            if (sf_geom)  {
               free(sf_geom);  
               sf_geom = NULL;
            }
            ME.super_cmd->state = ID_SF;
            break;
          }

          default:
          {
            {/*92N5987*/
              OM_BLOCK_MOVE(&me->locate_event, &event, sizeof(struct GRevent));
              event.event.button.x = sf_pt[0];
              event.event.button.y = sf_pt[1];
              event.event.button.z = sf_pt[2];
              gr$put_last_point(buffer = &event.event.button);

              co$update_current_point_form(msg = &rc);
            }
            goto wrapup;
          }

        } /* switch (Tokens[token]) */

        break;


      case SF_DRAFT_ANGLE:
        if (me->mytype == DLFT)
        {
          me->dlift_info.uniform_surface = FALSE;
          ex$message(msgnumb = EMS_P_EnterSfDraftAngBkupInputEachLoop);
          ex$message(msgnumb = EMS_I_PosAngOutNegAngInDraft);
          mask = GRm_ANGLE | GRm_BACK_UP;
  
          OM_stat = ems$getevent(msg = &rc,
                                 event_mask = GRm_VALUE | GRm_BACK_UP,
                                 value_type = GRIO_SCALAR,
                                 event = &event,
                                 response = (long *)response,
                                 response_data = response_data);
          token = GRloc_token(&rc, Tokens, &event);
  
          /*Added by DLB. 08/18/88*/
          if (rc == GRw_no_value)
          {
            event.response = GR_UNKNOWN_TYPE;
            token = 5; /*Simulate GR_UNKNOWN_TYPE*/
          }
  
          ex$message(msgnumb = EMS_P_ClearPromptField);
        }
        else
        {
          event.event.value = 0.0;
          token = 3; /*Simulate EX_VALUE event*/
        }

        switch (Tokens[token])
        {
          case EX_VALUE:

            draft_angle = event.event.value;
            draft_angle = draft_angle * DEG_TO_RAD;
            me->dlift_info.uniform_surface = TRUE;

            me->dlift_info.assoc_draft_angle.valevent = &me->sf_d_angle_mem;
            
            if (me->mytype == DLFT)
              me->dlift_info.assoc_draft_angle.type = EMSdatainfo_event;
            else
              me->dlift_info.assoc_draft_angle.type = EMSdatainfo_numeric;

            *(me->dlift_info.assoc_draft_angle.valevent) = event;

            me->dlift_info.mx_exlp_dangle = draft_angle;

            me->last_dangle_state_processed = LAST_STATE_SF_DANGLE;

            for (i = 0; i < me->dlift_info.num_lps; i++)
            { 
              lp_info = &me->lps_info[i];
              lp_info->is_uniform = TRUE;

              lp_info->draft_angle = draft_angle;
              lp_info->assoc_draft_angle.type = EMSdatainfo_event;
              *(lp_info->assoc_draft_angle.valevent) = event;

              for (j = 0; j < me->lps_info[i].num_eds; j++)
              {
                ed_info = &lp_info->eds_info[j];
                ed_info->draft_angle = draft_angle;
                ed_info->assoc_draft_angle.type = EMSdatainfo_event;
                *(ed_info->assoc_draft_angle.valevent) = event;
                ed_info->offset_code = BSCONSTOFF;
              }
            }
            
            ME.super_cmd->state = SF_FILLET;

            break;

          case EX_BACK_UP:

            ME.super_cmd->state = LP_DRAFT_ANGLE;
            me->cur_lp = 0;
            break;

          default:
            goto wrapup;

        } /* switch (Tokens[token]) */

        ex$message(msgnumb = EMS_I_ClearStatusField);
        break;

    
      case SF_FILLET:
        if (me->mytype == DLFT)
        {
          ex$message(msgnumb = EMS_P_FilletSfBkupForEachLoop);
          mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
          token = GRget_token(&rc, Tokens, &mask, &event,
                              &size, response, response_data);
        }
        else
        {
          event.event.keyin[0] = 'N';
          rc = MSSUCC;
          token = 2; /*Simulate STRING event*/
        }

        /*Added by DLB.*/
        if (rc == GRw_no_value)
        {
          /*Simulate MOVEON event.*/
          token = 4; 
          event.response = EX_RJT_MOVEON;
        }

        sf_fillet = FALSE;
        switch (Tokens[token])
        {
          case STRING:
             
            if ( (toupper(event.event.keyin[0]) == 'Y' ) ||
                 (event.event.keyin[0] == NULL) )
             sf_fillet = TRUE;

            else if ( toupper(event.event.keyin[0]) == 'N')
              sf_fillet = FALSE;

            else
              goto wrapup;

            ME.super_cmd->state = CHK_COINCIDENCE;
            break;

           case EX_RJT_MOVEON:
             sf_fillet = TRUE;
             ME.super_cmd->state = CHK_COINCIDENCE;
             break;

           case EX_BACK_UP:
              ME.super_cmd->state = LP_FILLET;
              me->cur_lp = 0;
              break;
           
           default:
             goto wrapup;

        } /* switch (Tokens[token]) */

        me->dlift_info.no_fillets = FALSE;

        if (ME.super_cmd->state == CHK_COINCIDENCE)
        {
          /**************** 
          This was causing fillets NOT to get formed even though asked for,
          when using the surface to draft and fillet (without backing up to 
          loops or edges). Fixes TR 92n2256.
                          Navin.
          me->dlift_info.no_fillets = TRUE;
          ******************/

          me->last_fillet_state_processed = LAST_STATE_SF_FILLET;

          for (i = 0; i < me->dlift_info.num_lps; i++)
          {
            lp_info = &me->dlift_info.lps_info[i];
            lp_info->fillet = sf_fillet;

          }/*for (i = 0; i < me->dlift_info.num_lps; i++) */

          if (me->single_sf_lift) ME.super_cmd->state = PROCESS;

        } /* if (ME.super_cmd->state == CHK_COINCIDENCE) */

        break;


      case CHK_COINCIDENCE:

        /***************************************
        *** Message subsystem key NOT defined for below *** 
        UI_prompt("Check for coincidence?(y/n) [n]"); 

        mask = GRm_BACK_UP | GRm_STRING | GRm_RJT_MOVEON;
        token = GRget_token(&rc, Tokens, &mask, &event, &size, 
                             response, response_data);
        if (rc == GRw_no_value)
        ****************************************/
        {
          /*Simulate STRING event.*/
          token = 2; 
          event.response = STRING;
          event.event.keyin[0] = 'Y';
        }

        switch (Tokens[token])
        {
          case STRING:
            if (toupper(event.event.keyin[0]) == 'Y') 
              chk_coincidence = TRUE;

            else if ( (toupper(event.event.keyin[0]) == 'N') ||
                      (event.event.keyin[0] == NULL) )
              chk_coincidence = FALSE;
 
            else
              goto wrapup;

            ME.super_cmd->state = PROCESS;
            break;

           case EX_RJT_MOVEON:
             chk_coincidence = FALSE;
             ME.super_cmd->state = PROCESS;
             break;

           case EX_BACK_UP:

              OM_stat = dp$erase_hilite(msg = &mthd_stat);
              EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,
                          wrapup); 
              if (me->last_fillet_state_processed == LAST_STATE_SF_FILLET)
                 ME.super_cmd->state = SF_FILLET;
              else
                 ME.super_cmd->state = LP_FILLET;
              break;
           
           default:
             goto wrapup;

        } /* switch (Tokens[token]) */

        if (ME.super_cmd->state == PROCESS)
        {
          active_constraints = chk_coincidence ? 
                                 EMS_LC_AUTO_COINCIDENCE : NULL;

          for (i = 0; i < me->dlift_info.num_lps; i++)
          {
            lp_info = &me->dlift_info.lps_info[i];

            for (j = 0; j < lp_info->num_eds; j++)
             lp_info->eds_info[j].ed_constraint_type = active_constraints;

          } /* for(i = 0; i < me->dlift_info.num_lps; i++)*/

        } /* if (ME.super_cmd->state = PROCESS) */

        break;


      case PROCESS:

       construct_list.newflag = FALSE;
       construct_list.display = &ME.COconst->ActiveDisplay;
       construct_list.geometry = NULL;
       construct_list.class_attr = NULL;
       construct_list.msg = &mthd_stat;
       construct_list.env_info = &me->sf_info.module_info;
       construct_list.level = ME.COconst->ActiveLevel;
       construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct_list.name = NULL;

       /*
        * It may be possible that the surafce is by itself or
        * a part of single surface state tree. In such a case,
        * the lift process should result in solid with new
        * surfaces created for the edges even though the edges
        * do not have a common edge.
        */

       if (me->single_sf_lift)
       {
         EFprepare_single_sf_lift ( &mthd_stat, me->sf_info.located_obj,
                 &me->sf_info.module_info, &construct_list, 
                 &me->active_state_GRid, me->dlift_info.draft_vec);
         EMerr_hndlr (!(1&mthd_stat),*response,TERMINATE,wrapup);

       } /* if (me->single_sf_lift) */

       ex$message(msgnumb = EMS_P_ClearPromptField);
       /**************************************************
       OM_stat = om$send (msg = message EMSsurface.EMlift_face_w_draft(
                           &mthd_stat,
                           message EMSsfdlift.EMlift_face( &mthd_stat,
                             &me->sf_info.module_info,
                             &construct_list,
                             &me->dlift_info, EMS_DO_DISPLAY, NULL, NULL),
                          &me->locmod_obj_GRid),
          targetid = me->active_state_GRid.objid,
          targetos = me->active_state_GRid.osnum);
       **************************************************/

       {/*INTENTIONAL DLB 7/30/92*/
         IGRint ii;  

         /*Set the no_fillets flag based on whether any of the lps_info.fillet
          * flags are set.
          */
         me->dlift_info.no_fillets = TRUE;
         for(ii=0; ii<me->dlift_info.num_lps; ii++)
         {
           if (me->dlift_info.lps_info[ii].fillet == TRUE)
           {
             me->dlift_info.no_fillets = FALSE;
           }
         }
       }

       {
          IGRint                 tmp_num_lps = 0;
          struct EMSdlft_lp_info *tmp_lps_info = NULL;
          OMuword                dlft_opts;
          IGRboolean             reset_lps_info=FALSE;
          IGRint                 *save_eds_per_lp = NULL, i, save_num_lps = 0;
          struct EMSdlft_ed_info **save_eds_info = NULL;
          struct EMSdlft_lp_info *save_lps_info = NULL;


         /* There seems to be some problem of the "lps_info[i].eds_info"
          * array pointer getting reset after the call to "EFdrafted_lift".
          * This can create problems if a backup is done and the drafting is 
          * re-done. 
          *     SURPRISINGLY, this behavior caused a crash only in a very 
          * specific case (TR 92n2257) and was not observed to be a problem
          * normally.
          *     To SOLVE this problem, the "lps_info" pointer and the 
          * "eds_info" pointer (corresponding to each "lps_info[i]") are stored 
          * before the call to "EFdrafted_lift" and are reset after the call.
          * Currently, only the "eds_info" pointers were observed to change,but
          * for future integrity, the "lps_info" pointer is also stored.
          *     HOWEVER, this fix may be undone, if someday, the 
          * "EFdrafted_lift" and downstream functions/methods are modified such
          * that the above info is not changed. 
          */

          if (me->dlift_info.uniform_surface &&
              me->dlift_info.no_fillets)
          {
            /*Dont need to pass in and info on loops or edges*/
            tmp_num_lps = me->dlift_info.num_lps;
            me->dlift_info.num_lps = 0;
            tmp_lps_info = me->dlift_info.lps_info;
            me->dlift_info.lps_info = NULL;
            reset_lps_info = TRUE;
          }
          else
          {
            /** START saving info ***/
            save_eds_per_lp = (IGRint *) alloca (me->dlift_info.num_lps *
                                                 sizeof (IGRint) );
            save_eds_info   = (struct EMSdlft_ed_info **) alloca 
                              (me->dlift_info.num_lps * 
                               sizeof (struct EMSdlft_ed_info *));
          
            save_num_lps    = me->dlift_info.num_lps;
            save_lps_info   = me->dlift_info.lps_info;

            for (i=0; i<me->dlift_info.num_lps; i++)
            { save_eds_per_lp[i] = me->dlift_info.lps_info[i].num_eds;
              save_eds_info[i]   = me->dlift_info.lps_info[i].eds_info;
            }
            /** END saving info ***/
          }

          dlft_opts = me->associative ? NULL : EFfunc_PLACE_NON_ASSOC;
          dlft_opts |= me->pos_mag_outside ? EFdlft_NEG_MAG_OUTSIDE : NULL;

          /* for ordinary lift */
          if(me->mytype == LFT) 
            dlft_opts |= me->pos_mag_outside ? NULL : EFlft_WITH_POS_ORIENT;

          me->locmod_obj_GRid.objid = NULL_OBJID;

          OM_stat = EFdrafted_lift(&mthd_stat,
                                   NULL,
                                   &construct_list,
                                   &me->dlift_info,
                                   &me->locmod_obj_GRid,
                                   dlft_opts);

          if (reset_lps_info)
          {
            me->dlift_info.num_lps = tmp_num_lps;
            me->dlift_info.lps_info = tmp_lps_info;
          }
          else
          {
            /** START reset info ***/
            me->dlift_info.num_lps  = save_num_lps;
            me->dlift_info.lps_info = save_lps_info;

            for (i=0; i<save_num_lps; i++)
            { me->dlift_info.lps_info[i].num_eds = save_eds_per_lp[i];
              me->dlift_info.lps_info[i].eds_info = save_eds_info[i];
            }
            /* No need to free, since this is stack allocated memory.??????*/
            /** END reset info ***/
          }
       }
       if(!(1&OM_stat&mthd_stat))
        ex$message(msgnumb = EMS_F_0004)

       EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

       /*
        * EMlift_face replaces the sf_id in dlift_info by newly created
        * drfated surface. This is needed by someone for unknown purposes.
        * Change it back as it will create problems after a backup.
        *                                        -- RC 11/28/89
        */

       me->dlift_info.sf_GRid = me->sf_info.located_obj;

       ME.super_cmd->state = ADD_TO_TREE;
       break;


      case ADD_TO_TREE:

       /*
        * ask if the newly constructed dpr make-face
        * object is to be added to the state tree ?
        */

       ex$message(msgnumb = EMS_P_AccBackMove);

       mask = GRm_BACK_UP | GRm_DATA | GRm_RJT_MOVEON;
       token = GRget_token(&rc, Tokens, &mask, &event, &size, 
                           response, response_data);
       EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);

       switch (Tokens[token])
       {
         case DATA:
         case GR_UNKNOWN_TYPE:

          ex$message(msgnumb = EMS_P_ClearPromptField);

          /*
           * If it is a single surface lift, merge EMSsldlift class
           * object constructed in EFprepare_single_sf_lift() with 
           * EMSsldlift class object constructed above.
           */

          if (me->single_sf_lift)
          {
           EFmerge_single_sf_lift_states (&mthd_stat,
                   me->active_state_GRid, me->locmod_obj_GRid,
                   me->sf_info.located_obj, &me->sf_info.module_info);
           EMerr_hndlr (!(1&mthd_stat),*response,TERMINATE,wrapup);

          } /* if (me->single_sf_lift) */
          else
          {
            /********************************************************
            add_option = EMS_DO_DISPLAY;
            OM_stat = om$send(msg = message EMSsfdpr.EMadd(&mthd_stat, 
                                    &me->active_state_GRid, NULL, 
                                    &me->sf_info.module_info, &add_option),
                           targetid = me->locmod_obj_GRid.objid,
                           targetos = me->locmod_obj_GRid.osnum);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
            *********************************************************/
          } /* else for if (me->single_sf_lift) */

            if (sf_geom)  {
               free(sf_geom);  
               sf_geom = NULL;
            }
          ME.super_cmd->state = ID_SF;
          if (Tokens[token] == DATA)
          {
            IGRlong qsize = sizeof(me->locate_event.event) + sizeof (IGRint);  
            func_stat = ex$putque(msg = &rc, response = response, 
                        byte = &qsize, buffer = (char *)&me->locate_event.event);
            EMerr_hndlr (!(1&func_stat),*response,TERMINATE,wrapup);
           }
           else goto wrapup;

           break;

       case EX_BACK_UP:
       case EX_RJT_MOVEON:

       {
         GRobjid *display_ids = NULL;
         IGRint  display_count = 0;

        deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
        /*****************************************************************
        OM_stat = om$send(msg = message EMSdpr.EMdeactivate(&mthd_stat,
                               &deactivate_option,
                               &me->sf_info.module_info, &display_ids,
                               &display_count),
                          targetid = me->locmod_obj_GRid.objid,
                          targetos = me->locmod_obj_GRid.osnum);
        ******************************************************************/
        {
          IGRint invoke_cnt=0;
          OM_stat = om$send(msg = message EMSdpr.EMundo(&mthd_stat,
                                  (IGRushort *)&deactivate_option, 
                                  &me->sf_info.module_info,
                                  NULL, NULL, NULL,
                                  &display_ids, &display_count, &invoke_cnt),
                            targetid = me->locmod_obj_GRid.objid,
                            targetos = me->locmod_obj_GRid.osnum);
        }
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

        /*
         * If it is a single_sf_lift, the active_state_GRid is the
         * EMSsldlift object created in preparation mode. There for,
         * undo the active_state also. Also, update the active state
         * id after undo.
         */

        if (me->single_sf_lift)
        {
          OM_stat = om$send(msg = message EMSdpr.EMdeactivate(&mthd_stat,
                               &deactivate_option,
                               &me->sf_info.module_info, &display_ids,
                               &display_count),
                          targetid = me->active_state_GRid.objid,
                          targetos = me->active_state_GRid.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

          OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (
                                  &mthd_stat, &me->active_state_GRid, NULL),
                             targetid = me->sf_info.located_obj.objid,
                             targetos = me->sf_info.located_obj.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

        } /* if (me->single_sf_lift) */

        if (Tokens[token] == EX_RJT_MOVEON) 
        {
          ME.super_cmd->state = ID_SF;
            if (sf_geom)  {
               free(sf_geom);  
               sf_geom = NULL;
            }
        } /* if (Tokens[token] == EX_RJT_MOVEON)  */
        else
        {
          /*****************************
          if (me->single_sf_lift)
          *****************************/
          {
            if (me->mytype == LFT)
              ME.super_cmd->state = TO_PT;
            else
            {
              if (me->last_fillet_state_processed == LAST_STATE_SF_FILLET)
                ME.super_cmd->state = SF_FILLET;
              else
                ME.super_cmd->state = LP_FILLET;
            }
          } /* if (me->single_sf_lift) */
          /***************************************
          else
            ME.super_cmd->state = CHK_COINCIDENCE;
          ***************************************/

          if (ME.super_cmd->state == SF_FILLET || 
              ME.super_cmd->state == CHK_COINCIDENCE ||
              ME.super_cmd->state == TO_PT)
          {          
           Display_Mode = GRhd;
           OM_stat = om$send(msg = message GRgraphics.GRdisplay(
                            &mthd_stat,
                            &me->sf_info.module_info.md_env.matrix_type,
                            me->sf_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->sf_info.module_info.md_id),
                        targetid = me->sf_info.located_obj.objid,
                        targetos = me->sf_info.located_obj.osnum);
           EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
           me->sf_hi = TRUE;
          
          } /* if (ME.super_cmd->state == SF_FILLET || 
                   ME.super_cmd->state == CHK_COINCIDENCE ) */
        }
        break;
       } /* end case EX_BACK_UP or EX_RJT_MOVEON */


       } /* switch (Tokens[token)) */

       break;

      case LP_DRAFT_ANGLE:
        
        /*
         * For each of the unprocessed loop:
         *
         * o Highlight it and prompt for draft angle/Backup for input
         *   for each edge.
         * o save the information. 
         */
 
        if (me->sf_hi)
        { 
          OM_stat = dp$erase_hilite(msg = &mthd_stat);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),OM_stat,OM_E_ABORT,wrapup);
          me->sf_hi = FALSE;
        }

        if (!sf_ele_header_good)
        {
          EFget_sf_ele_header (&rc, &sf_geom, &me->sf_info, my_id, 
                               &ele_spec_att, &sf_ele_header, &bsqsurf,
                               &symb, range);
          EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);

          sf_ele_header_good = TRUE;
           
        } /* if (!sf_ele_header_good) */
   
       event.response = EX_VALUE;
       ex$message(msgnumb = EMS_P_EnterLpDraftAngBkupInputEachEdge);
       ex$message(msgnumb = EMS_I_PosAngOutNegAngInDraft);
             
       while (me->cur_lp < me->dlift_info.num_lps &&
              event.response == EX_VALUE &&
              ME.super_cmd->state == LP_DRAFT_ANGLE )
       {
          lp_info = &me->dlift_info.lps_info[me->cur_lp];
          Display_Mode = GRhd;
          
          OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                         &mthd_stat, 
                          message EMSedge.EMdisplay (&mthd_stat,
                           &sf_ele_header, 
                           &me->sf_info.module_info.md_env.matrix_type,
                            me->sf_info.module_info.md_env.matrix,
                           &Display_Mode, NULL, EMS_WHL_EDGE, NULL),
                            1, 1, &OPP_EMSedge_class_id, TRUE,
                            NULL, NULL, NULL),
                         targetid = lp_info->lp_GRid.objid,
                         targetos = lp_info->lp_GRid.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
 
          mask = GRm_ANGLE | GRm_BACK_UP;
          /**********************************************
          token = GRget_token(&rc, Tokens, &mask, &event, &size, response,
                              response_data);
          ***********************************************/

          OM_stat = ems$getevent(msg = &rc,
                                 event_mask = GRm_VALUE | GRm_BACK_UP,
                                 value_type = GRIO_SCALAR,
                                 event = &event,
                                 response = (long *)response,
                                 response_data = response_data);
          token = GRloc_token(&rc, Tokens, &event);

          /*Added by DLB. 08/18/88*/
          if (rc == GRw_no_value)
          {
            event.response = GR_UNKNOWN_TYPE;
            token = 5; /*Simulate GR_UNKNOWN_TYPE*/
          }

          OM_stat = dp$erase_hilite(msg = &mthd_stat);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

          switch (Tokens[token])
          {
            case EX_VALUE:
 
             draft_angle = event.event.value;
             draft_angle = draft_angle * DEG_TO_RAD;
             lp_info->is_uniform = TRUE;
             lp_info->draft_angle = draft_angle;
             lp_info->assoc_draft_angle.type = EMSdatainfo_event;
             *(lp_info->assoc_draft_angle.valevent) = event;

             for (j = 0; j < lp_info->num_eds; j++)
             {
               ed_info = &lp_info->eds_info[j];
               ed_info->draft_angle = draft_angle;
               ed_info->assoc_draft_angle.type = EMSdatainfo_event;
               *(ed_info->assoc_draft_angle.valevent) = event;
               ed_info->offset_code = BSCONSTOFF;
 
             } /* for (j = 0; j < lp_info->num_eds; j++) */
 
             if (draft_angle > me->dlift_info.mx_exlp_dangle)
                   me->dlift_info.mx_exlp_dangle = draft_angle;
 
            if (me->cur_lp + 1 == me->dlift_info.num_lps)
            {
               ME.super_cmd->state = SF_FILLET;
              me->last_dangle_state_processed = LAST_STATE_LP_DANGLE;
            }
            else
             me->cur_lp++;
            break;
 
           case EX_BACK_UP:
             ME.super_cmd->state = ED_DRAFT_ANGLE;
             lp_info->is_uniform = FALSE;
             me->cur_ed = 0;
             break;
 
           default:
             goto wrapup;
 
         } /* switch (Tokens[token]) */
 
        } /* while (me->cur_lp < me->dlift_info.num_lps &&
             event.response == EX_VALUE &&
             ME.super_cmd->state == LP_DRAFT_ANGLE) */

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_ClearStatusField);
        break;
 
      case ED_DRAFT_ANGLE:
      {
        IGRshort draft_positive = -1, dd;

        /*
         * For each edge of the current loop:
         *
         * o Highlight it and prompt for draft angle/Backup for input.
         * o save the information. 
         */
 
        if (!sf_ele_header_good)
        {
          EFget_sf_ele_header (&rc, &sf_geom, &me->sf_info, my_id, 
                               &ele_spec_att, &sf_ele_header, &bsqsurf,
                               &symb, range);
          EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);

          sf_ele_header_good = TRUE;
           
        } /* if (!sf_ele_header_good) */
         
        event.response = EX_VALUE;
        lp_info = &me->dlift_info.lps_info[me->cur_lp];
        ed_info = &lp_info->eds_info[me->cur_ed];

        for(dd=0; dd<me->cur_ed; dd++)
        {
          if (lp_info->eds_info[dd].draft_angle != 0.0 &&
              lp_info->eds_info[dd].offset_code == BSCONSTOFF)
          {
            if (lp_info->eds_info[dd].draft_angle > 0)
              draft_positive = TRUE;            
            else
              draft_positive = FALSE;            
            break;
          }
        }

        ex$message(msgnumb = EMS_P_EnterEdDrftAngBkupToChgMode);
        ex$message(msgnumb = EMS_I_PosAngOutNegAngInDraft);

        while (me->cur_ed < lp_info->num_eds &&
               event.response == EX_VALUE &&
               ME.super_cmd->state == ED_DRAFT_ANGLE)
        {
          Display_Mode = GRhd;
          OM_stat = om$send(msg = message EMSedge.EMdisplay (&mthd_stat,
                                &sf_ele_header, 
                                &me->sf_info.module_info.md_env.matrix_type,
                                me->sf_info.module_info.md_env.matrix,
                                &Display_Mode, NULL, EMS_WHL_EDGE, NULL),
                            targetid = ed_info->ed_GRid.objid,
                            targetos = ed_info->ed_GRid.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
 
          mask = GRm_ANGLE | GRm_BACK_UP;

          /***********************************************
          token = GRget_token(&rc, Tokens, &mask, &event, &size, response,
                              response_data);
          ***********************************************/

          OM_stat = ems$getevent(msg = &rc,
                                 event_mask = GRm_VALUE | GRm_BACK_UP,
                                 value_type = GRIO_SCALAR,
                                 event = &event,
                                 response = (long *)response,
                                 response_data = response_data);
          token = GRloc_token(&rc, Tokens, &event);

          /*Added by DLB. 08/18/88*/
          if (rc == GRw_no_value)
          {
            event.response = GR_UNKNOWN_TYPE;
            token = 5; /*Simulate GR_UNKNOWN_TYPE*/
          }

          switch (Tokens[token])
          {
            case EX_VALUE:
            {
              ed_info->draft_angle = event.event.value;
              ed_info->draft_angle = ed_info->draft_angle * DEG_TO_RAD;

              if (draft_positive != -1)
              {
                if (ed_info->draft_angle != 0)
                {
                  if ((ed_info->draft_angle > 0 && !draft_positive) ||
                      (ed_info->draft_angle < 0 && draft_positive))
                  {
                    ex$message(msgnumb = EMS_E_DrftDirMustConsistantFirstEdge);
                    if (draft_positive)
                    {
                      ex$message(msgnumb = EMS_I_DraftMustZeroOrPositiveVal);
                    }
                    else
                    {
                      ex$message(msgnumb = EMS_I_DraftMustZeroOrNegativeVal);
                    }
                    break;
                  }
                }
              }
              else if (ed_info->draft_angle != 0)
              {
                if (ed_info->draft_angle > 0)
                  draft_positive = TRUE;
                else
                  draft_positive = FALSE;
              }

              ed_info->offset_code = BSCONSTOFF;
              ed_info->assoc_draft_angle.type = EMSdatainfo_event;
              *(ed_info->assoc_draft_angle.valevent) = event;

              if (ed_info->draft_angle > me->dlift_info.mx_exlp_dangle)
                   me->dlift_info.mx_exlp_dangle = ed_info->draft_angle;
               
              if (lp_info->num_eds == me->cur_ed +1 )
              {
                if (me->dlift_info.num_lps == me->cur_lp + 1 )
                {
                  me->last_dangle_state_processed = LAST_STATE_ED_DANGLE;
                  ME.super_cmd->state = SF_FILLET;
                }
                else
                {
                  me->cur_lp++;
                  me->cur_ed = 0;
                  ME.super_cmd->state = LP_DRAFT_ANGLE;
                }  
              } /* if (lp_info->num_eds == me->cur_ed +1 ) */
              else
              {
                me->cur_ed++;
                ed_info = &lp_info->eds_info[me->cur_ed];             
              }
              break;
            }

            case EX_BACK_UP:
            {
              ME.super_cmd->state = ED_DRAFT_MODE;
              break;
            }
 
            default:
            {
              goto wrapup;
            }
          } /* switch (Tokens[token]) */
 
          if ( Tokens[token] != EX_BACK_UP )
          {
            OM_stat = dp$erase_hilite(msg = &mthd_stat);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
          } 
        } /* while (me->cur_ed < lp_info->num_eds &&
                    event.response == EX_VALUE &&
                    ME.super_cmd->state == ED_DRAFT_ANGLE) */

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_ClearStatusField);
        break;
      }

      case ED_DRAFT_MODE:
        nghbr_ed_lvarying = FALSE;
        lp_info = &me->dlift_info.lps_info[me->cur_lp];

        if (me->cur_ed)
        {
          last_ed_info = &lp_info->eds_info[me->cur_ed-1];
          if (last_ed_info->offset_code == BSLINVAROFF) 
                   nghbr_ed_lvarying = TRUE;

          if (me->cur_ed == lp_info->num_eds - 1 &&
              !nghbr_ed_lvarying)
          {
            next_ed_info = &lp_info->eds_info[0];
            if (next_ed_info->offset_code == BSLINVAROFF)
                   nghbr_ed_lvarying = TRUE;
          }

        } /* if (me->cur_ed) */

        else if (lp_info->num_eds == 1)
             nghbr_ed_lvarying = TRUE;

        if (nghbr_ed_lvarying)
        {
           ex$message(msgnumb = EMS_P_DraftOrPreserveDefaultDraft);
        }
        else
        {
           ex$message(msgnumb = EMS_P_DrftOrPrsrvOrLinVarDefaultDrft);
        }

        mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        token = GRget_token(&rc, Tokens, &mask, &event,
                            &size, response, response_data);
        /*Added by DLB.*/
        if (rc == GRw_no_value)
        {
          /*Simulate MOVEON event.*/
          token = 4; 
          event.response = EX_RJT_MOVEON;
        }

        switch (Tokens[token])
        {
          case STRING:
             
            ed_info = &lp_info->eds_info[me->cur_ed];
             
            if ( (toupper(event.event.keyin[0]) == 'D' ) ||
                 (event.event.keyin[0] == NULL) )
              ME.super_cmd->state = ED_DRAFT_ANGLE_MODE;

            else if ( toupper(event.event.keyin[0]) == 'P' ||
                      toupper(event.event.keyin[0]) == 'L')
            {
              if (nghbr_ed_lvarying &&
                  toupper(event.event.keyin[0]) == 'L' )
              {
                ex$message(msgnumb = EMS_I_InvalModeNeighborEdgeLinVar);
              }
              else
              {
                 if ( toupper(event.event.keyin[0]) == 'P')
                    ed_info->offset_code = BSPRESERVCVSHP;
                 else
                    ed_info->offset_code = BSLINVAROFF;

                 if (lp_info->num_eds == me->cur_ed+1)
                 {
                  if (me->dlift_info.num_lps == me->cur_lp+1)
                  {
                   ME.super_cmd->state = SF_FILLET;
                   me->last_dangle_state_processed = LAST_STATE_ED_DMODE;
                  }
                  else
                  {
                    me->cur_lp++;
                    me->cur_ed = 0;
                    ME.super_cmd->state = LP_DRAFT_ANGLE;
                  }
  
                 } /* if (lp_info->num_eds == me->cur_ed+1) */
                 else
                 {
                    me->cur_ed++;
                   ME.super_cmd->state = ED_DRAFT_ANGLE;
    
                 } /* else for if (lp_info->num_eds == me->cur_ed+1) */
                  
              } /* else for if (nghbr_ed_lvarying &&
                  toupper(event.event.keyin[0]) == 'L' ) */

            } /* else if ( toupper(event.event.keyin[0]) == 'P' ||
                      toupper(event.event.keyin[0]) == 'L') */
            else
              goto wrapup;

            break;

           case EX_RJT_MOVEON:
             ME.super_cmd->state = ED_DRAFT_ANGLE_MODE;
             break;

           case EX_BACK_UP:
              if (me->cur_ed)
              {
                me->cur_ed--;
                ME.super_cmd->state = ED_DRAFT_ANGLE;
              }
              else if (me->cur_lp)
              {
                me->cur_lp--;
                ME.super_cmd->state = LP_DRAFT_ANGLE;
              }
              else
                ME.super_cmd->state = TO_PT;
              break;
           
           default:
             goto wrapup;

        } /* switch (Tokens[token]) */
    
        OM_stat = dp$erase_hilite(msg = &mthd_stat);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

       break;

      case LP_FILLET:
        /*
         * For each of the unprocessed loop:
         *
         * o Highlight it and prompt for draft-w-fillet
         * o save the information. 
         */
 
        if (!sf_ele_header_good)
        {
          EFget_sf_ele_header (&rc, &sf_geom, &me->sf_info, my_id, 
                               &ele_spec_att, &sf_ele_header, &bsqsurf,
                               &symb, range);
          EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);

          sf_ele_header_good = TRUE;
           
        } /* if (!sf_ele_header_good) */
   
       event.response = EX_RJT_MOVEON;
             
       while (me->cur_lp < me->dlift_info.num_lps &&
              (event.response == EX_STRING ||
               event.response == EX_RJT_MOVEON) &&
               ME.super_cmd->state == LP_FILLET )
       {
          lp_info = &me->dlift_info.lps_info[me->cur_lp];
          Display_Mode = GRhd;
          
          OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                         &mthd_stat, 
                          message EMSedge.EMdisplay (&mthd_stat,
                           &sf_ele_header, 
                           &me->sf_info.module_info.md_env.matrix_type,
                            me->sf_info.module_info.md_env.matrix,
                           &Display_Mode, NULL, EMS_WHL_EDGE, NULL),
                            1, 1, &OPP_EMSedge_class_id, TRUE,
                            NULL, NULL, NULL),
                         targetid = lp_info->lp_GRid.objid,
                         targetos = lp_info->lp_GRid.osnum);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
 
          ex$message(msgnumb = EMS_P_FilletLoopYesNoDefaultYes);
          mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
          token = GRget_token(&rc, Tokens, &mask, &event,
                              &size, response, response_data);
          /*Added by DLB.*/
          if (rc == GRw_no_value)
          {
            /*Simulate MOVEON event.*/
            token = 4; 
            event.response = EX_RJT_MOVEON;
          }

          ex$message(msgnumb = EMS_P_ClearPromptField);
          OM_stat = dp$erase_hilite(msg = &mthd_stat);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);

        switch (Tokens[token])
        {
          case STRING:
             
            if ( (toupper(event.event.keyin[0]) == 'Y' ) ||
                 (event.event.keyin[0] == NULL) )
             lp_info->fillet = TRUE;

            else if ( toupper(event.event.keyin[0]) == 'N')
              lp_info->fillet = FALSE;

            else
              goto wrapup;

            if (me->dlift_info.num_lps == me->cur_lp+1)
            {
               me->last_fillet_state_processed = LAST_STATE_LP_FILLET;
               ME.super_cmd->state = me->single_sf_lift ? PROCESS :
                                     CHK_COINCIDENCE;
            }
            else
               me->cur_lp++;
            break;


           case EX_RJT_MOVEON:
             lp_info->fillet = TRUE;
             if (me->dlift_info.num_lps == me->cur_lp+1)
             {
               me->last_fillet_state_processed = LAST_STATE_LP_FILLET;
               ME.super_cmd->state = me->single_sf_lift ? PROCESS :
                                     CHK_COINCIDENCE;
             }
             else
               me->cur_lp++;
             break;

           case EX_BACK_UP:
              if (me->cur_lp)
                 me->cur_lp--;
              else 
              {
                switch (me->last_dangle_state_processed)
                {
                  case LAST_STATE_SF_DANGLE:
                   ME.super_cmd->state = SF_DRAFT_ANGLE;
                   break;
 
                  case LAST_STATE_LP_DANGLE:
                    me->cur_lp = me->dlift_info.num_lps - 1;
                    ME.super_cmd->state = LP_DRAFT_ANGLE;
                    break;

                 case LAST_STATE_ED_DANGLE:
                 case LAST_STATE_ED_DMODE:
                 case LAST_STATE_ED_DANGLE_MODE:

                    me->cur_lp = me->dlift_info.num_lps - 1;
                    lp_info = &me->lps_info[me->cur_lp];
                    me->cur_ed = lp_info->num_eds - 1;
                    ME.super_cmd->state = ED_DRAFT_ANGLE;
                    break;

                 default:
                   fprintf (stderr, "somthing got screwed up \n");
                   *response = TERMINATE;
                   OM_stat = OM_E_ABORT;
                   goto wrapup;

                } /* swtich (me->last_dangle_state_processed) */

              } /* else for if (me->cur_lp) */

              break;

           default:
             goto wrapup;

        } /* switch (Tokens[token]) */

       } /* while (me->cur_lp < me->dlift_info.num_lps &&
              (event.response == EX_STRING ||
               event.response == EX_RJT_MOVEON) &&
               ME.super_cmd->state == LP_FILLET ) */

        break;
 
      case ED_DRAFT_ANGLE_MODE:
      {
        IGRshort draft_positive = -1, dd;

        if (!sf_ele_header_good)
        {
          EFget_sf_ele_header (&rc, &sf_geom, &me->sf_info, my_id, 
                               &ele_spec_att, &sf_ele_header, &bsqsurf,
                               &symb, range);
          EMerr_hndlr (!(1&rc), *response, TERMINATE, wrapup);

          sf_ele_header_good = TRUE;
           
        } /* if (!sf_ele_header_good) */
         
        event.response = EX_VALUE;
        lp_info = &me->dlift_info.lps_info[me->cur_lp];
        ed_info = &lp_info->eds_info[me->cur_ed];

        for(dd=0; dd<me->cur_ed; dd++)
        {
          if (lp_info->eds_info[dd].draft_angle != 0.0 &&
              lp_info->eds_info[dd].offset_code == BSCONSTOFF)
          {
            if (lp_info->eds_info[dd].draft_angle > 0)
              draft_positive = TRUE;            
            else
              draft_positive = FALSE;            
            break;
          }
        }

        Display_Mode = GRhd;
        OM_stat = om$send(msg = message EMSedge.EMdisplay (&mthd_stat,
                                  &sf_ele_header, 
                                  &me->sf_info.module_info.md_env.matrix_type,
                                  me->sf_info.module_info.md_env.matrix,
                                  &Display_Mode, NULL, EMS_WHL_EDGE, NULL),
                          targetid = ed_info->ed_GRid.objid,
                          targetos = ed_info->ed_GRid.osnum);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
 
        ex$message(msgnumb = EMS_P_EnterEdDrftAng);
                   
        mask = GRm_ANGLE | GRm_BACK_UP;
        /***************************************************
        token = GRget_token(&rc, Tokens, &mask, &event, &size, response,
                              response_data);
        ***************************************************/
        OM_stat = ems$getevent(msg = &rc,
                               event_mask = GRm_VALUE | GRm_BACK_UP,
                               value_type = GRIO_SCALAR,
                               event = &event,
                               response = (long *)response,
                               response_data = response_data);
        token = GRloc_token(&rc, Tokens, &event);

        /*Added by DLB. 08/18/88*/
        if (rc == GRw_no_value)
        {
          event.response = GR_UNKNOWN_TYPE;
          token = 5; /*Simulate GR_UNKNOWN_TYPE*/
        }
    
        ex$message(msgnumb = EMS_P_ClearPromptField);
        OM_stat = dp$erase_hilite(msg = &mthd_stat);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*response,TERMINATE,wrapup);
 
        switch (Tokens[token])
        {
          case EX_VALUE:
          {
            ed_info->draft_angle = event.event.value;
            ed_info->draft_angle = ed_info->draft_angle * DEG_TO_RAD;

            if (draft_positive != -1)
            {
              if (ed_info->draft_angle != 0)
              {
                if ((ed_info->draft_angle > 0 && !draft_positive) ||
                    (ed_info->draft_angle < 0 && draft_positive))
                {
                  ex$message(msgnumb = EMS_E_DrftDirMustConsistantFirstEdge);
                  if (draft_positive)
                  {
                    ex$message(msgnumb = EMS_I_DraftMustZeroOrPositiveVal);
                  }
                  else
                  {
                    ex$message(msgnumb = EMS_I_DraftMustZeroOrNegativeVal);
                  }
                  break;
                }
              }
            }
            else if (ed_info->draft_angle != 0)
            {
              if (ed_info->draft_angle > 0)
                draft_positive = TRUE;
              else
                draft_positive = FALSE;
            }

            ed_info->offset_code = BSCONSTOFF;
            ed_info->assoc_draft_angle.type = EMSdatainfo_event;
            *(ed_info->assoc_draft_angle.valevent) = event;

            if (ed_info->draft_angle > me->dlift_info.mx_exlp_dangle)
                me->dlift_info.mx_exlp_dangle = ed_info->draft_angle;
               
            if (lp_info->num_eds == me->cur_ed +1 )
            {
              if (me->dlift_info.num_lps == me->cur_lp + 1 )
              {
                me->last_dangle_state_processed = LAST_STATE_ED_DANGLE_MODE;
                ME.super_cmd->state = SF_FILLET;
              }
              else
              {
                me->cur_lp++;
                me->cur_ed = 0;
                ME.super_cmd->state = LP_DRAFT_ANGLE;
              }  
            } /* if (lp_info->num_eds == me->cur_ed +1 ) */
            else
            {
              me->cur_ed++;
              ed_info = &lp_info->eds_info[me->cur_ed];             
              ME.super_cmd->state = ED_DRAFT_ANGLE;
            }
            break;
          }

          case EX_BACK_UP:
          {
            if (me->cur_ed)
            {
              me->cur_ed--;
              ME.super_cmd->state = ED_DRAFT_ANGLE;
            }
            else if (me->cur_lp)
            {
              me->cur_lp--;
              ME.super_cmd->state = LP_DRAFT_ANGLE;
            }
            else
              ME.super_cmd->state = SF_DRAFT_ANGLE;
            break;
          }

          default:
          {
            goto wrapup;
          }
        } /* switch (Tokens[token]) */

        break;
      }

      /*       
       * Something has messed up our state table
       */

     default:
      fprintf (stderr, "Default state reached\n");
      EMerr_hndlr (OM_E_ABORT, *response, TERMINATE, wrapup);

    } /* switch (ME.super_cmd->state) */

  } while(TRUE);

 wrapup:
  if (sf_geom)  free(sf_geom);  
  return(OM_stat);

}

void EFget_sf_ele_header (
     EFmsg,
     sf_geom,
     sf_info,
     sender_id, 
     ele_spec_att,
     sf_ele_header,
     bsqsurf,
     symb,
     range)

  IGRlong                  *EFmsg;
  struct  IGRbsp_surface   **sf_geom;
  struct  GRlc_info        *sf_info;
  GRobjid                  sender_id;
  union  IGRele_attr       *ele_spec_att;
  struct DPele_header      *sf_ele_header;
  struct IGResqbs          *bsqsurf;
  struct GRsymbology       *symb;
  IGRdouble                *range;

{
     IGRlong   OM_stat;
   IGRlong   mthd_stat;
IGRlong   rc, func_stat;
  IGRlong   EMget_the_geometry ();

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  if (!(*sf_geom))
  {
    func_stat = EMget_the_geometry (sf_info, FALSE, FALSE,
                          FALSE, sender_id, (IGRchar **)sf_geom, &rc);
    EMerr_hndlr (!(1&rc&func_stat),*EFmsg,EMS_E_Fail,wrapup);

  } /* if (!(*sf_geom)) */
 
  /*
   * get the element header to be used in display
   */
 
  ele_spec_att->bsqsurf = bsqsurf;
  OM_stat = om$send (msg = message EMSsubbs.EMget_ele_header (
                      &mthd_stat, *sf_geom, 
                      &sf_info->module_info.md_env, 
                       NULL, sf_ele_header, range, 
                      &symb->display_attr, *ele_spec_att, NULL), 
                     senderid = NULL_OBJID,
                     targetid = sf_info->located_obj.objid, 
                     targetos = sf_info->located_obj.osnum);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
 
 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFget_sf_ele_header");
  return;

} /* void static EFget_sf_ele_header () */


end implementation ECdlift;

