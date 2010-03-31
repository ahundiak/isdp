/* ###################   APOGEE COMPILED   ################## */
class implementation ECscoffset;

/* History 

TAPADIA 22nd Jan. 91 - Fixed TR 90n2844. Invalid variation curve name/number
			resulted in memory fault.  		
AMD  :  Feb, 1990 :  Creation 
Vadiraj 22/05/92  :  Modified for message subsystem compliance. 
Sudha   07/05/93  :  Modified for BSprototypes ansification
scw  :  08/14/94  :  clarified sleep method
*/

#include "EMS.h"
#include "OMerrordef.h"
# include "grdpbmacros.h" /* gr$get_active_display */
# include "griodef.h"
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"
#include "griomacros.h" /* co$getevent */
#include "bserr.h"
#include "bsicmpcvoff.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "EC_M.h"
#include "EC_I.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_E.h"
#include "maptlnpro.h"
#include "bsdistptpt.h"

#define X 0
#define Y 1
#define Z 2
#define INVALID_INX     -1

#define ID_SURFACE      0
#define ID_CURVE        1
#define DIR_POINT       2
#define DIST1           3
#define DIST2           4
#define LAW_CV          5
#define PROCESS         6

extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRcurve_class_id;

from GRgraphics import GRlnproject, GRdisplay, GRptproject;
from GRvg import GRgetattr, GRdetplane, GRgeomprops, GRgetrang;
from GRcurve import EMcvoffset, GRgenabsg, GRendpts;
from EMSsubbs import EMsfcvoffset, EMsftanorm;
from EMSsurface import EMshow_normals;

method init (IGRint type; IGRchar *string)
{
  return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    IGRint stat_OM;

    ME.ECelement->elem_hilit = FALSE;
    stat_OM = OM_S_SUCCESS;
    return(stat_OM);
}



method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean            stat_func;
  IGRchar               errmsg[EMMAXERRMSG_LEN];
  IGRchar               loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint                event_size, display_flag;
  IGRlong               stat_OM, msg, msg_loc;
  IGRlong               event_mask, event_mask1, event_mask2;
  IGRlong               sts=OM_S_SUCCESS;
  struct GRevent        accev, event;
  struct GRlc_locate    lc_attr;
  struct GRvg_construct const_list;
  struct IGResbc        esbc;
  enum GRdpmode         dpmode;
  struct GRid           cvoffset_id;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  IGRchar               lawcv_name[MAX_CHAR+1];
  IGRint                cvinx;
  struct IGRbsp_curve   *law_curve = NULL;
  static IGRpoint       start_pnt, end_pnt, proj_start_pnt, proj_end_pnt;
  IGRpoint              cursor_pt1, cursor_pt2;
  static  IGRpoint      proj_pnt1, proj_pnt2;
  static struct GRparms        proj_parms1, proj_parms2;      
  IGRboolean            in_world_system = TRUE;
  GRrange               range;
  static IGRdouble             norm_pts1[6], norm_pts2[6];
  IGRdouble             t_par1, t_par2;
  IGRvector             norm_vec1, norm_vec2;
  struct IGRline        line1, line2;

  extern void EFdraw_vector_on_screen();
  extern IGRint EFdyptproj();

  ex$message(msgnumb=EMS_P_ClearPromptField);
  ex$message(msgnumb=EM_M_PlOfstCrvNortoSrf);
 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECscoffset.execute");

  do 
    {
    switch (ME.super_cmd->state)
     {
      case ID_SURFACE:
      {      
       dpmode = GRbdhe;
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc, 
             &ME.ECelement->elem.module_info.md_env.matrix_type, 
	     ME.ECelement->elem.module_info.md_env.matrix, 
	     &dpmode, &ME.ECelement->md_env.md_id),
             targetid = ME.ECelement->elem.located_obj.objid,
             targetos = ME.ECelement->elem.located_obj.osnum);

       ME.ECelement->elem_hilit = FALSE;

      /* Identify the surface */

      event_mask1 = GRm_DATA | GRm_BACK_UP;
      event_mask2 = GRm_DATA;

      ex$message(msgnumb = EMS_P_00031, buff = loc_prompt); 
      ex$message(msgnumb = EMS_P_AcptWthCrvToBeOfstRjct, buff = acc_prompt);
      ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       lc_attr.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_WRITE_ONLY;                  /* I'm going to change this guy */
       strcpy(lc_attr.classes, "EMSsubbs"); 
       lc_attr.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |                /* We want the surface itself */
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &rclass;
       elig_classes.w_count = 1;
       elig_classes.w_flags = OM_CLST_subclass;
       elig_classes.p_classes = &eliclass;
       rclass   = OPP_EMSsubbs_class_id;
       eliclass = OPP_EMSsubbs_class_id;
       stat_func = lc$locate(
             rc =                   &msg_loc,
             event1 =               &ME.ECelement->locev,
             event2 =               &accev,
             mask1 =                event_mask1,
             mask2 =                event_mask2,
             eventsize =            &event_size,
             display_flag =         display_flag,
             response =             response,
             response_data =        response_data,
             locate_prompt =        loc_prompt,
             acc_prompt =           acc_prompt,
             relocate_prompt =      reloc_prompt,
             attributes =           &lc_attr,
             stack =                &me->locate_stack,
             rtree_classes =        &rtree_classes,
             eligible_classes =     &elig_classes);

 
        if (stat_func == FALSE)
          {
          ex$message(msgnumb=EMS_E_FailInputProcExit);
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

        if(accev.response == EX_DATA)
          {
	   IGRlong  qsize;

           ME.ECelement->elem_hilit = TRUE;
           
           ME.ECscoffset->surf.objid = accev.located_object[0].
                                                  located_obj.objid;
           ME.ECscoffset->surf.osnum = accev.located_object[0].
                                                  located_obj.osnum;

	   /* accept with edge */
           qsize = sizeof(accev) - 2 * sizeof(IGRint);
           sts = ex$putque(msg = &msg_loc, response = response,
                byte = &qsize, buffer = (char *)&accev.event);

           ME.super_cmd->state = ID_CURVE;
            
          } /* if */
	else 	goto  ret_end;

      } /* case 0 */
      break;


   case ID_CURVE:

   /* Identify the curve */

    if (ME.ECelement->elem_hilit)
        {
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        }
    event_mask1 = GRm_DATA | GRm_BACK_UP;
    event_mask2 = GRm_DATA;
    ex$message(msgnumb = EMS_P_00030, buff = loc_prompt);
 
    display_flag =
     ELEM_HILIGHT                |
     NO_PROJ_ACCEPT_POINT        |
     ACC_REJ_CYCLE               |
     RELOCATE                    |
     LC_REGULAR_HIGHLIGHT        |
     LC_ERASE_ALL;

    ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
    ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW | IGN_MOD_BIT;
    lc_attr.owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
                           LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER;
    strcpy(lc_attr.classes, "GRcurve");

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_GRbspline_class_id;
    eliclass = OPP_GRcurve_class_id;

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

        ex$message(msgnumb=EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb=EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
          {
           ME.super_cmd->state = ID_SURFACE;
           break;
          }
          else
           goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:

           ME.ECscoffset->curv.objid = accev.located_object[0].
                                                  located_obj.objid;
           ME.ECscoffset->curv.osnum = accev.located_object[0].
                                                  located_obj.osnum;
           ME.ECelement->elem_hilit = TRUE;
           ME.super_cmd->state = DIR_POINT;
         break;
         case EX_BACK_UP:
           ME.super_cmd->state = ID_SURFACE;
         break;
         default:
           goto ret_end;
          }
      break;


      case DIR_POINT:

      /* Find the direction to project the curve */

      sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          start_pnt,
                          end_pnt),
                    targetid = me->curv.objid,
                    targetos = me->curv.osnum,
                    senderid = my_id);
      EMomerr_hndlr ( sts, ret_end, "GRcurve.GRendpts");

      sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          start_pnt,
                          proj_start_pnt,
                          &proj_parms1),
                    senderid = my_id,
                    targetid = me->surf.objid,
                    targetos = me->surf.osnum);                          
      EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRptproject");

      sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          end_pnt,
                          proj_end_pnt,
                          &proj_parms2),
                    senderid = my_id,
                    targetid = me->surf.objid,
                    targetos = me->surf.osnum);                          
      EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRptproject");
      
      sts = om$send(mode= OM_e_wrt_object,
                    msg = message GRvg.GRgetrang(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &in_world_system,
                          range),
                    senderid = my_id,
                    targetid = me->surf.objid,
                    targetos = me->surf.osnum);
      EMomerr_hndlr ( sts, ret_end, "GRvg.GRgetrang");
      
      sts = om$send(msg = message EMSsubbs.EMsftanorm(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          NULL,
                          1, &proj_parms1.u,
                          1, &proj_parms1.v,
                          1.0,
                          NULL,                /* natural normal */   
                          FALSE,
                          TRUE,
                          norm_pts1,
                          NULL),
                    targetid = me->surf.objid,
                    targetos = me->surf.osnum,
                    senderid = NULL_OBJID);
      EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMsftanorm");

      sts = om$send(msg = message EMSsubbs.EMsftanorm(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          NULL,
                          1, &proj_parms2.u,
                          1, &proj_parms2.v,
                          1.0,
                          NULL,                /* natural normal */   
                          FALSE,
                          TRUE,
                          norm_pts2,
                          NULL),
                    targetid = me->surf.objid,
                    targetos = me->surf.osnum,
                    senderid = NULL_OBJID);
      EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMsftanorm");

      norm_vec1[0] = norm_pts1[3] - norm_pts1[0];
      norm_vec1[1] = norm_pts1[4] - norm_pts1[1];
      norm_vec1[2] = norm_pts1[5] - norm_pts1[2];

      norm_vec2[0] = norm_pts2[3] - norm_pts2[0];
      norm_vec2[1] = norm_pts2[4] - norm_pts2[1];
      norm_vec2[2] = norm_pts2[5] - norm_pts2[2];
  
      EFdraw_vector_on_screen(
        NULL_OBJID,
        &me->active_display,
        &me->md_env,
        GRhd,
        FALSE,
        proj_start_pnt,
        norm_vec1,
        range,
        &msg);

      EFdraw_vector_on_screen(
        NULL_OBJID,
        &me->active_display,
        &me->md_env,
        GRhd,
        FALSE,
        proj_end_pnt,
        norm_vec2,
        range,
        &msg);

      ex$message(msgnumb=EMS_P_IsTheOfstDirnCorct);

      event_size = sizeof (struct GRevent);

      stat_func = EMSokay (co$getevent (
        msg = &msg_loc,
        event_mask = GRm_TEXT_VALUE | GRm_BACK_UP| GRm_RJT_MOVEON,
        response = response,
        response_data = response_data,
        event = &event
      ));

      ex$message(msgnumb=EMS_P_ClearPromptField);
      if (stat_func == FALSE)
       {
        ex$message(msgnumb=EMS_E_FailInputProcExit);
        *response = TERMINATE;
        goto ret_end;
       }

       if (msg_loc == GRw_no_value)
        {
          ME.ECscoffset->right_side = TRUE;
          ME.super_cmd->state = DIST1;
         break;
        }
       if (msg_loc != MSSUCC)
        goto ret_end;


      switch(event.response)
       {
        case STRING:
          if (toupper (event.event.keyin[0]) == 'Y')
             ME.ECscoffset->right_side = TRUE;
          else 
             ME.ECscoffset->right_side = FALSE;

          ME.super_cmd->state = DIST1;
          break;
        case EX_BACK_UP:
            ME.super_cmd->state = ID_CURVE;
            stat_OM = dp$erase_hilite(msg = &msg_loc);
          break;
        case EX_RJT_MOVEON:
          ME.ECscoffset->right_side = TRUE;
          ME.super_cmd->state = DIST1;
        break;
        default:
          goto ret_end;
       }
      break;
 
      case DIST1:

      /* Find offset distance at start point */

        
        ex$message(msgnumb=EMS_P_EntOfstDistAtStPt);

          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
 
          dpmode = GRhd;
          stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            &dpmode, &me->md_env.md_id),
                            senderid = my_id,
                            targetid = ME.ECelement->elem.located_obj.objid, 
                            targetos = ME.ECelement->elem.located_obj.osnum);
         EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRdisplay");


         EFdyptproj( proj_start_pnt, norm_vec1,
                     me->right_side, &me->active_display);

         stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP,
            value_type = GRIO_DISTANCE,
            response = response,
            response_data = response_data,
            event = &event
         ));

         ex$message(msgnumb=EMS_P_ClearPromptField); 
         if (stat_func == FALSE)
          {
          ex$message(msgnumb=EMS_E_FailInputProcExit);
          *response = TERMINATE; 
          goto ret_end;
          }
         if (msg_loc == GRw_no_value)
          {
          ex$message(msgnumb=EMS_I_00006);
          break;
          }
         if (msg_loc != MSSUCC)
          goto ret_end;
         switch (event.response)
          {
          case EX_DATA:
            cursor_pt1[0] = event.event.button.x;
            cursor_pt1[1] = event.event.button.y;
            cursor_pt1[2] = event.event.button.z;

          if( ME.ECscoffset->right_side)
            {
            line1.point1 = &norm_pts1[0];
            line1.point2 = &norm_pts1[3];
            }
          else
            {
            line1.point1 = &norm_pts1[3];
            line1.point2 = &norm_pts1[0];
            }

            MAptlnproj(&msg_loc, cursor_pt1, &line1, proj_pnt1, &t_par1 );

            if (t_par1 < 0.0)
            {
            ex$message(msgnumb=EMS_S_DataIpOnWrongSide);
            ME.super_cmd->state = DIST1;
            break; 
            }                 
            me->dist1 = BSdistptpt (&msg_loc,proj_pnt1,
                                     proj_start_pnt);

            EMerr_hndlr (msg_loc != BSSUCC, *response, TERMINATE, ret_end);
            ME.super_cmd->state = DIST2;
            break;

          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
              ex$message(msgnumb=EMS_I_DistMustBepositive);
              break;
              }
            me->dist1 = event.event.value;
            ME.super_cmd->state = DIST2;
            break;
          case EX_BACK_UP:
             
            ME.super_cmd->state = DIR_POINT;
            break;

          default:
            goto ret_end;
          }

        break;

      case DIST2:

      /* Find offset distance at end point */

        
          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
 
          dpmode = GRhd;
          stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            &dpmode, &me->md_env.md_id),
                            senderid = my_id,
                            targetid = ME.ECelement->elem.located_obj.objid, 
                            targetos = ME.ECelement->elem.located_obj.osnum);

         ex$message(msgnumb=EMS_P_EntOfstDistAtEndPt);

         EFdyptproj( proj_end_pnt, norm_vec2,
                     me->right_side, &me->active_display);

         stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA|GRm_VALUE|GRm_BACK_UP|GRm_RJT_MOVEON,
            value_type = GRIO_DISTANCE,
            response = response,
            response_data = response_data,
            event = &event
         ));

         ex$message(msgnumb=EMS_P_ClearPromptField);  
         if (stat_func == FALSE)
          {
          ex$message(msgnumb=EMS_E_FailInputProcExit)
          *response = TERMINATE;
          goto ret_end;
          }
         if (msg_loc == GRw_no_value)
          {
          ex$message(msgnumb=EMS_I_00006);
          break;
          }
         if (msg_loc != MSSUCC)
          goto ret_end;
         switch (event.response)
          {
          case EX_DATA:
            cursor_pt2[0] = event.event.button.x;
            cursor_pt2[1] = event.event.button.y;
            cursor_pt2[2] = event.event.button.z;

          if( ME.ECscoffset->right_side)
            {
            line2.point1 = &norm_pts2[0];
            line2.point2 = &norm_pts2[3];
            }
          else
            {
            line2.point1 = &norm_pts2[3];
            line2.point2 = &norm_pts2[0];
            }

            MAptlnproj(&msg_loc, cursor_pt2, &line2, proj_pnt2, &t_par2 );

            if (t_par2 < 0.0)
            {
            ex$message(msgnumb=EMS_S_DataIpOnWrongSide);
            ME.super_cmd->state = DIST2;
            break; 
            }                
            me->dist2 = BSdistptpt (&msg_loc,proj_pnt2, 
                                     proj_end_pnt);

            EMerr_hndlr (msg_loc != BSSUCC, *response, TERMINATE, ret_end);

            ME.super_cmd->state = LAW_CV;
            break;
          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
              ex$message(msgnumb=EMS_I_DistMustBepositive); 
              break;
              }
            me->dist2 = event.event.value;
            me->is_not_uniform = TRUE; 
            ME.super_cmd->state = LAW_CV;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = DIST1;
            break;
          case EX_RJT_MOVEON:
            me->dist2 = NULL;
            me->is_not_uniform = FALSE;
            me->is_linear = NULL;
            law_curve = NULL;
            ME.super_cmd->state = PROCESS;
            break;

          default:
            goto ret_end;
          }

        break;


      case LAW_CV:

      /* Find the mode of variation */

        ex$message(msgnumb=EMS_P_EntNamOfVarCrv);
        event_mask = GRm_TEXT_VALUE|GRm_VALUE|GRm_BACK_UP|GRm_RJT_MOVEON;           
        stat_func = co$getevent(
                    msg = &msg_loc,
                    event_mask = event_mask,
                    value_type = GRIO_SCALAR,
                    response = response,
                    response_data = response_data,
                    event = &event);
        EMerr_hndlr(!stat_func, stat_OM, OM_E_ABORT, ret_end);

        ex$message(msgnumb=EMS_P_ClearPromptField); 
         if (stat_func == FALSE)
          {
          ex$message(msgnumb=EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
         if (msg_loc == GRw_no_value)
          {
          ex$message(msgnumb=EMS_I_00006);
          break;
          }
         if (msg_loc != MSSUCC)
          goto ret_end;

        switch(event.response)
          {
          case EX_STRING:
            cvinx = INVALID_INX;
            EMget_lawcurve(
              &msg,
              event.event.keyin,
              &cvinx,
              &law_curve);
	/* To account for invalid variation curve name */
            if ((!(1 & msg)) || (msg == EMS_I_NotFound)) {
            	me->is_linear = TRUE;
            	me->is_not_uniform = TRUE;
            	law_curve = NULL;
	    } 
	    else me->is_linear = FALSE;
            ME.super_cmd->state = PROCESS;
            break;
          case EX_VALUE:
            ex$message(msgnumb = EMS_S_ClearStatusField, buff = lawcv_name);
            cvinx = event.event.value;
            EMget_lawcurve(
              &msg,
              lawcv_name,
              &cvinx,
              &law_curve);
	/* To account for invalid variation curve number */
            if ((!(1 & msg)) || (msg == EMS_I_NotFound)) {
            	me->is_linear = TRUE;
            	me->is_not_uniform = TRUE;
            	law_curve = NULL;
	    }
	    else me->is_linear = FALSE;
            ME.super_cmd->state = PROCESS;
            break;                                  
          case EX_BACK_UP:
            ME.super_cmd->state = DIST2;
            break;
          case EX_RJT_MOVEON:
            me->is_linear = TRUE;
            me->is_not_uniform = TRUE;
            law_curve = NULL;
            ME.super_cmd->state = PROCESS;
            break;
          default:
            goto ret_end;
          }
      break;


      case PROCESS:

      /* Do it !! */

        ex$message(msgnumb=EMS_I_Processing);

        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRvg.GRgetattr(&msg_loc, (char *)&esbc),
                          senderid = my_id,
                          targetid = me->curv.objid,
                          targetos = me->curv.osnum);

        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         ret_end);

        const_list.msg = &msg_loc;
        const_list.env_info = &me->md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelement->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
        const_list.geometry = NULL;
        const_list.display = &ME.ECelement->active_display;
        const_list.class_attr = (char *)&esbc;
        const_list.name = NULL;

        stat_OM = om$send(msg = message EMSsubbs.EMsfcvoffset(&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &const_list,
                         &ME.ECscoffset->curv,
                         ME.ECscoffset->right_side,
                         ME.ECscoffset->dist1,
                         ME.ECscoffset->dist2,
                         ME.ECscoffset->is_linear,
                         ME.ECscoffset->is_not_uniform,
                         law_curve,
                         &cvoffset_id),
                  senderid = my_id,
                  targetid = me->surf.objid,
                  targetos = me->surf.osnum);

        if (msg_loc == EMS_I_InvalidArg)
                ex$message(msgnumb=EMS_S_InvalidOfstCode)  

        else if ((msg_loc == EMS_I_BSerror) ||
                 (! (1 & msg_loc)) ||
                 (! (1 & stat_OM)))
                 ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd)

        else 
        ex$message(msgnumb=EMS_S_OfstCrvCrtd)
        dpmode = GRbd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                       targetid = cvoffset_id.objid,
                       targetos = cvoffset_id.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         ret_end);

        ME.super_cmd->state = ID_SURFACE;
        break;

      default:
        ex$message(msgnumb=EMS_F_CommandIllegalState); 
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  return (OM_S_SUCCESS);
}

end implementation ECscoffset;

