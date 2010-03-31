/* ###################   APOGEE COMPILED   ################## */
class implementation ECslprjsfpl;

#include "EMS.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "EC_M.h"
#include "EC_P.h"

/*
DESCRIPTION
        This command constructs a solid of revolution given
        an open surface to project, a planar surface that the other
        surface will be projected on, and a direction vector. Note 
        that three points can be given instead of locating a planar
        surface. The method only needs a point and normal defining
        a plane.
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
        scw     08/14/94    clarified sleep method
     Sudha      07/05/93    Modified for BSprototypes ansification
     Rustagi    06/02/92    Modified for Message Sub-system Compliance   
        scw     08/08/91    Converted to use gr$dpb associative flag
        jhw     04/15/91    Modified to call associative placement function.
        PP      06/13/87    Added error checking so that if the surface
                            has boundaries, an error message is displayed
                            and also should the surface have degenerate
                            edges.
                            appropriate error message are displayed.
        DLB     02/03/87    Creation date.
*/

#include <stdio.h>
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "EMSbnddef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "dp.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "griodef.h"
#include "EMSerrordef.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMScmacros.h"
#include "EMSlogic.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "emsdef.h"
#include "EMSascmacros.h"
#include "madetplan.h"
#include "bsdistnct2.h"
#include "bscollin.h"

from GRgraphics import GRdisplay;
from GRvg import GRgeomprops, GRdetplane;
from EMSsolid import EMproj_4_bnd_on_plane;
from EMSloopset import EMget_props;
from EMSsfimpbnd import EMget_subbs;


method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhd;
 IGRint sts;
 IGRlong msg;

 if (me->obj1_hi)
 { 
  sts = om$send(mode = OM_e_wrt_object,
         msg = message GRgraphics.GRdisplay(&msg, 
             &me->sf_info.module_info.md_env.matrix_type, 
             me->sf_info.module_info.md_env.matrix, 
             &Display_Mode, 
             &me->sf_info.module_info.md_id),
         targetid = me->sf_info.located_obj.objid,
         targetos = me->sf_info.located_obj.osnum);

  ERROR(sts, msg, "slprj exec display", wrapup)
 }

 if (me->obj2_hi)
 {
  sts = om$send(mode = OM_e_wrt_object,
         msg = message GRgraphics.GRdisplay(&msg, 
             &me->pl_info.module_info.md_env.matrix_type, 
             me->pl_info.module_info.md_env.matrix, 
             &Display_Mode, 
             &me->pl_info.module_info.md_id),
         targetid = me->pl_info.located_obj.objid,
         targetos = me->pl_info.located_obj.osnum);
  ERROR(sts, msg, "slprj exec display", wrapup)
 }

 {
    IGRboolean  state;

    gr$get_associative_flag( buffer = &state );
    GRdisplay_associative_button(state);
 }

 return OM_S_SUCCESS;

 wrapup:
  return OM_E_ABORT;
}


method super_cmd.sleep(int pos)
{
 IGRint sts;
 IGRlong msg;

 if (me->obj1_hi || me->obj2_hi)
 {
   sts = dp$erase_hilite(msg = &msg);
   ERROR(sts, msg, "slprj sleep erase hi", wrapup);
 }

 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);

 GRdisplay_associative_button(FALSE);
 return OM_S_SUCCESS;

 wrapup:
  return OM_E_ABORT;
}


extern OMuword OPP_EMSgensolid_class_id, OPP_EMSsubbs_class_id;

method execute(int *response; char *response_data; int pos)
{
 IGRdouble             tolerance;
 IGRpoint              vec_point;
 enum     GRdpmode     Display_Mode;
 IGRint                sts=OM_S_SUCCESS, size=sizeof(struct GRevent),display_flag;
 IGRlong               msg, no_pts;
 IGRint                locate_mask, accept_mask, mask, token, num = 0;
 GRobjid               surf_id;
 OM_S_CHANSELECT       to_loopset;
 struct   GRlc_locate  attr;
 struct   GRid         solid_GRid;
 struct   GRprops      props;
 IGRushort     loopset_props;
 extern void           EMinitvgcnstr();
 extern void           EMgetvgcnstr();
 IGRboolean            bs_sts;
 IGRshort              prevstate = 0, i;
 IGRchar               loc_prompt[40], acc_prompt[40], reloc_prompt[40];
 struct GRvg_construct *construction_list;

 
#   define NUM_TOKENS 4
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, STRING, GR_UNKNOWN_TYPE
    };

#   define NUM_STATES 9
    enum states
    {
        start, got_sf, got_yes, got_no, got_pt1, got_pt2, got_pl,
        got_vc1, got_vc2
    };

    /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:     BACK_UP    DATA     STRING   UNK
    old state: */                                   
    /* start   */ {start,   got_sf,  start,   start   },
    /* got_sf  */ {start,   got_no,  got_yes, got_sf  },
    /* got_yes */ {got_sf,  got_pl,  got_yes, got_yes },
    /* got_no  */ {got_sf,  got_pt1, got_no,  got_no  },
    /* got_pt1 */ {got_no,  got_pt2, got_pt1, got_pt1 },
    /* got_pt2 */ {got_pt1, got_pl,  got_pt2, got_pt2 },
    /* got_pl  */ {got_pt2, got_vc1, got_yes, got_pl  },
    /* got_vc1 */ {got_pl,  got_vc2, got_vc1, got_vc1 },
    /* got_vc2 */ {got_vc2, start,   got_vc2, got_vc2 }
    };

    enum actions
    {
         NIL, ERR, initialize, sto_sf, sto_pl, dehi1, dehi2,
         sto_pt1, sto_pt2, sto_pt3, sto_vc1, sto_vc2, mk_sol
    };

    /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:     BACK_UP  DATA     STRING UNK
    old state: */                                     
    /* start   */ {NIL,   sto_sf,  ERR,   NIL }, 
    /* got_sf  */ {dehi1, NIL,     NIL,   NIL },
    /* got_yes */ {NIL,   sto_pl,  ERR,   NIL },
    /* got_no  */ {NIL,   sto_pt1, ERR,   NIL },
    /* got_pt1 */ {NIL,   sto_pt2, ERR,   NIL },
    /* got_pt2 */ {NIL,   sto_pt3, ERR,   NIL },
    /* got_pl  */ {NIL,   sto_vc1, dehi2, NIL },
    /* got_vc1 */ {NIL,   sto_vc2, ERR,   NIL },
    /* got_vc2 */ {NIL,   mk_sol,  NIL,   NIL }
    };

 ex$message(msgnumb = EM_M_SolProSftoPl);

 do
 {
  switch (ME.COconst->action)
  {
   

   case NIL:
   case initialize:
    break;

   case ERR:
   {
    ex$message(msgnumb = EMS_S_InvInp);
    break;
   }
 

   case sto_sf:
   {
    me->obj1_hi = TRUE;
    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->sf_info, sizeof(struct GRlc_info));

    /**DETERMINE IF THE SURFACE MEETS THE RESTRICTIONS OF THIS COMMAND**/
    sts = om$send(
          msg = message GRvg.GRgeomprops(&msg, 
                &me->sf_info.module_info.md_env.matrix_type,
                me->sf_info.module_info.md_env.matrix,
                &props),
          targetid = me->sf_info.located_obj.objid,
          targetos = me->sf_info.located_obj.osnum);
    ERROR(sts, msg, "slprj exec get geomprops", wrapup)

    /**NOTE: IF THE SURFACE IS CLOSED THEN THIS METHOD DOES NOT BREAK. 
             EXECUTION WILL FALL THROUGH TO THE DEHI
             ACTION WHERE THE LOCATED SURFACE WILL BE DEHILITED. THEN
             THE ACTION WILL BREAK AS NORMAL.
    **/
    /**THE SURFACE MUST NOT BE CLOSED**/

    if (props.phy_closed || props.closed)
    {
      ex$message(msgnumb = EMS_S_SfisClose);
      ME.super_cmd->state = prevstate;
    }
    else
    {
      sts = om$send (msg = message EMSsfimpbnd.EMget_subbs (&msg, &surf_id),
                     targetid = me->sf_info.located_obj.objid,
                     targetos = me->sf_info.located_obj.osnum);

      if (sts == OM_W_UNKNOWN_MSG)
      {
        sts = OM_S_SUCCESS;
        msg = EMS_S_Success;
        surf_id = me->sf_info.located_obj.objid;
      }

      ERROR(sts, msg, "slprj exec get subbs", wrapup)

      {
        OMuint count;
        OM_S_OBJECT_LINKAGE ls_linkage;

        sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
        ERROR(sts, EMS_S_Success, "slprj exec mk chansel", wrapup)

        sts = om$get_channel_objects(objid = surf_id,
                                     osnum = me->sf_info.located_obj.osnum,
                                     p_chanselect = &to_loopset,
                                     list = &ls_linkage,
                                     size = 1,
                                     count = &count);
        ERROR(sts, EMS_S_Success, "slprj exec get chan obj", wrapup)

        if (count < 1)
        {
          sts = OM_S_SUCCESS;
          msg = EMS_S_Success;
          break;
        }

        sts = om$send(msg = message EMSloopset.EMget_props (&msg, 
                            &loopset_props),
                      targetid = ls_linkage.S_objid,
                      targetos = ls_linkage.osnum);
        ERROR(sts, msg, "slprj exec get props", wrapup)

        if (!(loopset_props & EMLS_NATURAL))
        {
          ex$message(msgnumb = EMS_S_SfImpBound);
          ME.super_cmd->state = prevstate;
        }
        else
          break;
      }
    }
   }   


   case dehi1:
   {
    me->obj1_hi = FALSE;
    Display_Mode = GRhe;
    sts = om$send(
          mode = OM_e_wrt_object,
          msg = message GRgraphics.GRdisplay(&msg,
               &me->sf_info.module_info.md_env.matrix_type,
               me->sf_info.module_info.md_env.matrix,
               &Display_Mode, 
               &me->sf_info.module_info.md_id),
          targetid = me->sf_info.located_obj.objid,
          targetos = me->sf_info.located_obj.osnum);
    ERROR(sts, msg, "slprj exec display", wrapup)
    break;
   }


   case sto_pl:
   {
    me->obj2_hi = TRUE;
    OM_BLOCK_MOVE(&me->locate_event.located_object[0],
                  &me->pl_info, sizeof(struct GRlc_info));

    /**DETERMINE IF THE SURFACE MEETS THE RESTRICTIONS OF THIS COMMAND**/
    sts = om$send(
          msg = message GRvg.GRgeomprops(&msg, 
                &me->pl_info.module_info.md_env.matrix_type,
                me->pl_info.module_info.md_env.matrix,
                &props),
          targetid = me->pl_info.located_obj.objid,
          targetos = me->pl_info.located_obj.osnum);
    ERROR(sts, msg, "slprj exec get geomprops", wrapup)

    /**NOTE: IF THE SURFACE IS NOT PLANAR THEN THIS METHOD DOES NOT BREAK.
             EXECUTION WILL FALL THROUGH TO THE DEHI
             ACTION WHERE THE LOCATED SURFACE WILL BE DEHILITED. THEN
             THE ACTION WILL BREAK AS NORMAL.
    **/
    /**THE SURFACE MUST BE PLANAR**/
    if (!props.planar)
    {
      ex$message(msgnumb = EMS_S_SfNotPlanar);
      ME.super_cmd->state = prevstate;
    }
    else
    {
     /**ALL IS WELL SO GET POINT AND NORMAL DEFINING THE PLANE**/
     me->plane.point = (IGRdouble *) om$malloc 
                                   (structure = IGRpoint);
     me->plane.normal = (IGRdouble *) om$malloc 
                                    (structure = IGRvector);
     if (!me->plane.point || !me->plane.normal)
     {
       ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec couldn't malloc", wrapup)
     }   
     sts = om$send(
           msg = message GRvg.GRdetplane(&msg,
               &me->pl_info.module_info.md_env.matrix_type,
               me->pl_info.module_info.md_env.matrix,
               &me->plane),
           targetid = me->pl_info.located_obj.objid,     
           targetos = me->pl_info.located_obj.osnum);
     ERROR(sts, msg, "slprj exec det plane", wrapup)
     break;
    }
   }   


   case dehi2:
   {
    me->obj2_hi = FALSE;
    Display_Mode = GRhe;
    sts = om$send(
          mode = OM_e_wrt_object,
          msg = message GRgraphics.GRdisplay(&msg,
               &me->pl_info.module_info.md_env.matrix_type,
               me->pl_info.module_info.md_env.matrix,
               &Display_Mode, 
               &me->pl_info.module_info.md_id),
          targetid = me->pl_info.located_obj.objid,
          targetos = me->pl_info.located_obj.osnum);
    ERROR(sts, msg, "slprj exec display", wrapup)
    break;
   }


   case sto_pt1:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->plane_pt, sizeof(IGRpoint));
    break;
   }
  
  
   case sto_pt2:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->plane_pt[1], sizeof(IGRpoint));
    bs_sts = BSdistnct2(&msg, me->plane_pt[0], me->plane_pt[1]);
    if (BSERROR(msg))
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec BSdistnct2 ", wrapup)
    }        
    if (!bs_sts)
    {
      ex$message(msgnumb = EMS_S_MstbeUniqPoint);
      ME.super_cmd->state = prevstate;
      break;
    }
    break;
   }
  
  
   case sto_pt3:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->plane_pt[2], sizeof(IGRpoint));
    /** CHECK FOR POINTS BEING COLLINEAR**/
    bs_sts = BScollin(&msg, me->plane_pt[0], me->plane_pt[1], 
                      me->plane_pt[2]);
    if (BSERROR(msg))     
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec BScollin", wrapup)
    }
    if (bs_sts)
    {
      ex$message(msgnumb = EMS_S_PointsColliner);
      ME.super_cmd->state = prevstate;
      break;
    }
    /**DETERMINE THE PLANE**/
    me->plane.point = (IGRdouble *) om$malloc 
                                  (structure = IGRpoint);
    me->plane.normal = (IGRdouble *) om$malloc 
                                   (structure = IGRvector);
    if (!me->plane.point || !me->plane.normal)
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec no mem for pl.pt & pl.norm",
            wrapup)
    }
    bs_sts = BSEXTRACTPAR(&msg, BSTOLLENVEC,tolerance);
    if (!bs_sts)
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec extract par", wrapup)
    }
    no_pts = 3;
    bs_sts = MAdetplane(&msg, (IGRdouble *)me->plane_pt, &no_pts,&tolerance, &me->plane);
    if (!bs_sts)
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec MAdetplane", wrapup)
    }
    break;
   }
  
  
   case sto_vc1:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  me->vec, sizeof(IGRvector));
    break;
   }
  
  
   case sto_vc2:
   {
    OM_BLOCK_MOVE(&me->locate_event.event.button,
                  vec_point, sizeof(IGRpoint));
    bs_sts = BSdistnct2(&msg, me->vec, vec_point);
    if (BSERROR(msg))
    {
      ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec BSdistnct2", wrapup)
    }        
    if (!bs_sts)
    {
      ex$message(msgnumb = EMS_S_MstbeUniqPoint);
      ME.super_cmd->state = prevstate;
      break;
    }
    for(i = 0; i<3; i++)
    {
      me->vec[i] = vec_point[i] - me->vec[i];
    }
    break;
   }


   case mk_sol:
   {
    ex$message(msgnumb = EMS_I_00003); 
    ex$message(msgnumb = EMS_P_ClearPromptField);
    me->obj1_hi = FALSE;
    me->obj2_hi = FALSE;

    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "slprj sleep erase hi", wrapup);

    {
        IGRboolean              assoc_placement;
        struct EMSobject_info   surface;
        struct EMSvector_info   vector;
        struct EMSplane_info    plane;

        gr$get_associative_flag( buffer = &assoc_placement );

        surface.env  = me->sf_info.module_info;
        surface.grid = me->sf_info.located_obj;

        vector.type = EMSdatainfo_numeric;
        memcpy(vector.vec, me->vec, sizeof(IGRvector));

        if (me->pl_info.located_obj.objid == NULL_OBJID)
        {
            plane.type = EMSdatainfo_numeric;
            memcpy(plane.pt, me->plane.point, sizeof(IGRpoint));
            memcpy(plane.normal, me->plane.normal, sizeof(IGRvector));
        }
        else
        {
            plane.type = EMSdatainfo_object;
            plane.plobj.env  = me->pl_info.module_info;
            plane.plobj.grid = me->pl_info.located_obj;
        }

        solid_GRid.osnum = me->sf_info.located_obj.osnum;
/*****************************************************************************
        sts = EMplace_surface_to_plane_solid_of_proj
                                ( &msg,
                                  assoc_placement ? 
                                  NULL : EMSasconst_notassociative,
                                  &me->sf_info.module_info,
                                  ME.COconst->ActiveLevel,
                                  &ME.COconst->ActiveDisplay,
                                  NULL,
                                  NULL,
                                  &surface,
                                  &vector,
                                  &plane,
                                  &solid_GRid.objid );
*****************************************************************************/
        construction_list = (struct GRvg_construct *) om$malloc(size =
                                                sizeof(struct GRvg_construct));
        EMinitvgcnstr(&msg, &me->sf_info.module_info,
                      &ME.COconst->ActiveDisplay,
                      NULL, construction_list);
        EMgetvgcnstr(NULL, NULL, &me->sf_info.module_info,
                     ME.COconst->ActiveLevel,
                     &ME.COconst->ActiveDisplay,
                     NULL, NULL, construction_list); 
        sts = ems$pl_surf_to_pln_sld_of_proj(msg =&msg,
                 options = assoc_placement ? NULL : EMSasconst_notassociative,
                 construction_list = construction_list,
                 surface = &surface,
                 plane = &plane,
                 projection_vector = &vector,
                 sldprj_obj = &solid_GRid.objid );
    }

    ex$message(msgnumb = EMS_S_ClearStatusField);
    om$dealloc(ptr = me->plane.point);
    om$dealloc(ptr = me->plane.normal);

    if (COERROR(sts) || COERROR(msg))
    {
     EMSmsgReport(sts, "method send", FALSE);
     EMSmsgReport(msg, "method send", FALSE);
     if (msg == EMS_E_DegenerateEdge)
       ex$message(msgnumb = EMS_S_SfDegnBound)
     else
       ex$message(msgnumb = EMS_S_SolidNtConst);
     om$report_error(sts = sts);
     break;
    }

    /**DISPLAY THE SOLID**/
    Display_Mode = GRbd;
    sts = om$send(mode = OM_e_wrt_object,
          msg = message GRgraphics.GRdisplay(&msg, 
               &me->sf_info.module_info.md_env.matrix_type, 
               me->sf_info.module_info.md_env.matrix, 
               &Display_Mode, 
               &me->sf_info.module_info.md_id),
          targetid = solid_GRid.objid,
          targetos = solid_GRid.osnum);
    ERROR(sts, msg, "slprj exec display", wrapup)

    break;
   }


   default:
   {
    ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec bad action", wrapup)
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {

   case start:
   {
    me->obj1_hi = FALSE;
    me->obj2_hi = FALSE;
   }
   case got_yes:
   {
    OM_S_CLASSLIST rtree_classes, elig_classes;   /*DECL*/
    OMuword        rclass, eliclass;

    display_flag = 4;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   
    if (ME.super_cmd->state == start)
      ex$message(msgnumb = EMS_P_IdenfSufToPrj, buff=loc_prompt)
    else
      ex$message(msgnumb = EMS_P_IdentPlnSf, buff=loc_prompt);
    ex$message(msgnumb = EMS_P_AccRegSurf, buff=acc_prompt);
    ex$message(msgnumb = EMS_I_00011, buff=reloc_prompt);
    strcpy(attr.classes, "EMSsubbs");
    attr.properties = 0x11 | LC_RW;
    attr.owner_action = 0x5;

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsubbs_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->locate_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &attr, 
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }


   case got_sf:
   {
    IGRboolean state;

    gr$get_associative_flag( buffer = &state );

    if (state)
    {
        strcpy (me->locate_event.event.keyin, "yes");
        token = 2;
    }
    else
    {
        me->pl_info.located_obj.objid = NULL_OBJID;
        mask = GRm_STRING | GRm_BACK_UP;
        ex$message(msgnumb = EMS_P_DoesPlSfExist);
        token = GRget_token(&msg, Tokens, &mask, 
                            &me->locate_event, &size, 
                            response, response_data);
    }
    ex$message(msgnumb = EMS_S_ClearStatusField);

    if (token == 2)  /**STRING EVENT**/
    {
     if (!strlen(me->locate_event.event.keyin))
       token = 1;  /**DATA TOKEN: DO got_no STATE**/
     else if (me->locate_event.event.keyin[0] == 'N' ||
              me->locate_event.event.keyin[0] == 'n') 
       token = 1;  /**DATA TOKEN: DO got_no STATE**/
    }
    else if (token == 3)  /** UNKNOWN EVENT ***/
     token = 1;  /**DATA TOKEN: DO got_no STATE**/
    break;
   }
   

   case got_no:
   case got_pt1:
   case got_pt2:
   {
    switch (ME.super_cmd->state)
    {
     case got_no:
      ex$message(msgnumb = EMS_P_InpPt_1_ofPl);
      num = 0;
      break;
     case got_pt1:
      ex$message(msgnumb = EMS_P_InpPt_2_ofPl);
      num = 1;
     break;
     case got_pt2:
      ex$message(msgnumb = EMS_P_InpPt_3_ofPl);
      num = 2;
      break;
     default:
      break;
    }
    if (ME.super_cmd->state != got_no)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                num, me->plane_pt, TRUE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set bn bf", wrapup)

      EFrblineseg(me->plane_pt[num-1],&ME.COconst->ActiveDisplay);
    }
    mask = GRm_DATA | GRm_BACK_UP;
    token = GRget_token(&msg, Tokens, &mask, 
                        &me->locate_event, &size, 
                        response, response_data);

    if (ME.super_cmd->state != got_no)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                num, me->plane_pt, FALSE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set by bf", wrapup)
    }
    ex$message(msgnumb = EMS_S_ClearStatusField);
    break;
   }


   case got_pl:
   case got_vc1:
   {
    if (ME.super_cmd->state == got_pl)
      ex$message(msgnumb = EMS_P_InpPt_1_DirVec)
    else
      ex$message(msgnumb = EMS_P_InpPt_2_DirVec);

    if (!me->obj2_hi)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                3, me->plane_pt, TRUE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set by bf", wrapup)
    }
    if (ME.super_cmd->state == got_vc1)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                1, me->vec, TRUE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set by bf", wrapup)

      EFrblineseg(me->vec, &ME.COconst->ActiveDisplay);
    }
    mask = GRm_DATA | GRm_BACK_UP;
    token = GRget_token(&msg, Tokens, &mask, 
                        &me->locate_event, &size, 
                        response, response_data);
    if (!me->obj2_hi)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                3, me->plane_pt, FALSE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set by bf", wrapup)
    }

    if (ME.super_cmd->state == got_vc1)
    {
      ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay,
                                ME.COroot->ModuleInfo, my_id, 
                                1, me->vec, FALSE);
      ERROR(OM_S_SUCCESS, msg, "slprj exec dis pt set by bf", wrapup)
    }

    if (ME.super_cmd->state == got_pl)
    {
      if (token == 0 && me->obj2_hi)     
        token = 2;  /**STRING TOKEN: GO BACK TO got_yes state**/
    }
    ex$message(msgnumb = EMS_S_ClearStatusField);
    break;
   }


   case got_vc2:
   {
     token = 1; /**SIMULATE DATA INPUT**/
     break;
   }

   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "slprj exec bad state", wrapup)
   }

  } /*switch(state) */

  prevstate = ME.super_cmd->state;  
  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return sts;

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);

}/*method execute*/

end implementation ECslprjsfpl;
