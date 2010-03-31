/* ###################   APOGEE COMPILED   ################## */

/* HISTORY :
            Vadiraj  06/08/92  Modified for message subsystem compliance.
*/
class implementation ECmvpls;

#include "EMS.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_S.h"
#include <stdio.h>
#include "exmacros.h"   /* For ex$put_que*/  
#include "dpmacros.h"   /* For dp$erase_hilite */
#include "griomacros.h" /* For co$get_event */
#include "OMmacros.h"   /* For OM_BLOCK_MOVE */
#include "EMSmvpl.h"   /* For EMMOVE_POLES_ALONG_SPECIFIED_VECTORS */
#include "bserr.h"
#include "igrdef.h"     /* For IGRPS */
#include "bsparameters.h" /* For BSEXT.. */

/* command object mytype */

#define MOVE_POLES 0
#define MOVE_NODES 1

/* command object states */

#define IDENTIFY_SURFACE 3
#define INPUT_POLE 4
#define INPUT_FROM_POLE 4
#define ACCEPT_REJECT_POLE 5
#define INPUT_TO_POLE 6
#define IDENTIFY_NORMAL_ELEMENT 7
#define INPUT_FROM_POINT 8
#define INPUT_TO_POINT 9

#define INCREMENT 10

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1 & error_number))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn ECmvpls error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1 & error_number))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }
#endif

from GRvg import GRgetsize, GRgetsymb,GRgetgeom,GRgetattr;
from EMSsubbs import EMdynmod,EMmove_poles;
from GRgraphics import GRdisplay,GRdelete;
from EMSsubbs import EMgenerate_node_pt_surf;

extern OMuword OPP_GRbspline_class_id, OPP_EMSsubbs_class_id;

method execute(int *response; char *response_data; int pos)
{
 IGRlong sts,msg,j;
 IGRint locate_mask, accept_mask, event_mask, display_flag;
 IGRchar string[80];
 enum GRdpmode display_mode;
 struct GRlc_locate attributes;
 struct GRevent event;
 IGRboolean onpolygon;
 IGRlong putque_size;
 OMuword r_classes[5], e_classes[5];
 OM_S_CLASSLIST	rtree_classes, eligible_classes;
 struct GRevent accept_event;
 struct GRmd_env *md_env = NULL;
 struct IGRbsp_surface *surf;
 IGRchar locate_prompt1[52], locate_prompt2[52], acc_prompt1[52], 
         acc_prompt2[52];   

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 locate_mask = GRm_DATA | GRm_BACK_UP;
 accept_mask = GRm_DATA;

 if (me->mytype == MOVE_POLES)
  ex$message(msgnumb = EM_M_MvMnyPlsOnSrf)
 else if (me->mytype == MOVE_NODES)
  ex$message(msgnumb = EM_M_MvNdsOnSrf);

 display_flag = 
      ELEM_HILIGHT		| 	/* Hilite the whole element */
      NO_PROJ_ACCEPT_POINT	| 	/* Don't project the accept point */
      ACC_REJ_CYCLE		|	/* Run through accept reject cycle */
      RELOCATE			| 	/* Relocate if none found */
      LC_REGULAR_HIGHLIGHT	|	/* Use regular hilite not 1/2 */
      LC_ERASE_ALL;			/* Erase the hilite plane */

 attributes.properties = 
        LC_LC_ONLY		|	/* Locate locatable objects */
        LC_DP_ONLY		|	/* Locate displayable objects */
        IGN_MOD_BIT             |	/* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    ;	/* Planarity doesn't matter */

  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = &r_classes[0];
  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.p_classes = &e_classes[0];

/*
 * Enter infinite loop.
 */
 do
 {
  switch (ME.super_cmd->state)
  {
   case 0:
    ME.super_cmd->state = IDENTIFY_SURFACE;
   break;

   case IDENTIFY_SURFACE:
      {
       GRstatus_display_button(1);
       ex$message(msgnumb = EMS_I_InvkStatusFrm);
                      /* Invoke status form to review options */
       attributes.properties |= LC_WRITE_ONLY;

       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_REF_OBJECTS |		/* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;		/* No reference file headers */

       rtree_classes.w_count = 1;
       eligible_classes.w_count = 1;
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;

       ex$message(msgnumb = EMS_P_IdntSfOrBuToChngOpt, buff = locate_prompt1);
       ex$message(msgnumb = EMS_P_AccptRjctSf, buff = acc_prompt1);

       sts = lc$locate(
         rc =			&msg,
         event1 =		&me->locate_event,
         event2 =		&accept_event,
         mask1 =		locate_mask,
         mask2 =		accept_mask,
         display_flag =		display_flag,
         locate_prompt =        locate_prompt1,
         acc_prompt =           acc_prompt1,
         relocate_key = 	EMS_I_00011,
         attributes = 		&attributes,
         stack = 		&me->locate_stack,
         rtree_classes = 	&rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, 1, "GRlclocate error")

       GRstatus_display_button(0);
       
       if (!(1&msg))
       {
         return(OM_S_SUCCESS);
       }
       else
       {
        struct GRid lcobj;

        ME.ECmvpls->surface = accept_event.located_object[0];
        lcobj = ME.ECmvpls->surface.located_obj;

        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "erase hilite error")

        if (me->mytype == MOVE_POLES)
        {
         sts = om$send (msg = message ECmvpls.display_polygon(TRUE),
                       targetid = my_id);
         ERROR(sts,1,"Error in displaying polygon")
        }
        else if (me->mytype == MOVE_NODES)
        {
         OM_S_OBJID newobjid;
         struct GRvg_construct construct_list;
         struct GRmd_env temp_env;
         struct IGRdisplay local_disp;

         construct_list.msg = &msg;
/*
 * The node surface is not put into the R-tree.
 */
         temp_env = me->surface.module_info;
         temp_env.md_id.objid = NULL_OBJID;

         construct_list.msg = &msg;
         construct_list.env_info = &temp_env;
         construct_list.newflag = FALSE;
         construct_list.geometry = NULL;
         construct_list.class_attr = NULL;
         construct_list.level = ME.ECelement->active_level;
         construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
         local_disp = ME.ECelement->active_display;
         local_disp.style = 7; /* Dot Dashed */
         construct_list.display = &local_disp;
         construct_list.name = NULL;

         if (me->u_vals) om$dealloc(ptr = me->u_vals);
         me->u_vals = NULL;

         if (me->v_vals) om$dealloc(ptr = me->v_vals);
         me->v_vals = NULL;

         if (me->node_pts) om$dealloc(ptr = me->node_pts);
         me->node_pts = NULL;

         if (me->weights) om$dealloc(ptr = me->weights);
         me->weights = NULL;

         sts = om$send (msg = message EMSsubbs.EMgenerate_node_pt_surf(&msg,
                              &me->surface.module_info,
                              me->u_insert, me->v_insert,NULL,
                              &construct_list, &newobjid,
                              &me->unum, &me->u_vals, &me->vnum, &me->v_vals,
                              &me->num_pts, &me->weights, (IGRdouble **)&me->node_pts),
                        targetid = me->surface.located_obj.objid,
                        targetos = me->surface.located_obj.osnum);
         ERROR(sts,msg,"In EMgenerate node pt surf")

/*
 * Store the surface being modified and fool this command object into
 * thinking that the object being modified is the new object constructed.
 */
         me->save_surf = me->surface;

         me->surface.module_info.md_id.objid = NULL_OBJID;
         me->surface.located_obj.objid = newobjid;

         display_mode = GRbd;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
         ERROR(sts,msg,"In erasing surface")
       }


        sts = om$send (msg = message ECmvpls.store_geom(&msg),
                       targetid = my_id);
        ERROR(sts,msg,"Error in storing geometry")

        ME.super_cmd->state = INPUT_POLE;
       }
      }
   break;

/*   case INPUT_POLE:    ### THIS HAS SAME VALUE AS INPUT_FROM_POLE - Ashok */
   case INPUT_FROM_POLE:
   {
    event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_RESTART | GRm_BACK_UP;

     if (me->pole_selection == RANGE)
     {
      if (me->mytype == MOVE_POLES)
      {
       if (me->num_poles == 0)
         ex$message(msgnumb = EMS_P_InputFrPl, buff = string)
       else
         ex$message(msgnumb = EMS_P_InputFrPlMvOn, buff = string);
      }
      else
      {
       if (me->num_poles == 0)
         ex$message(msgnumb = EMS_P_InputFrNdPt, buff = string) 
       else
         ex$message(msgnumb = EMS_P_InputFrNdPtMvOn, buff = string); 
      }
     }
     else 
     {
      if (me->mytype == MOVE_POLES )
      {
       if (me->num_poles == 0)
        ex$message(msgnumb = EMS_P_InputPl, buff = string)
       else 
        ex$message(msgnumb = EMS_P_InputPlMvOn, buff = string);
      }
      else
      {
       if (me->num_poles == 0)
        ex$message(msgnumb = EMS_P_InputNdPt, buff = string)
       else 
        ex$message(msgnumb = EMS_P_InputNdPtMvOn, buff = string);
      }
     }

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);

    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_BACK_UP)
    {
     if (me->num_pole_events == 0) /* At the start then */
     {

      ME.super_cmd->state = IDENTIFY_SURFACE;

      if (me->mytype == MOVE_NODES)
      {
         display_mode = GRbe;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
         ERROR(sts,msg,"In displaying surface")

         {
           IGRlong cln_sts,loc_msg;

           cln_sts = om$send (msg = message GRgraphics.GRdelete(&loc_msg,
                              &me->surface.module_info),
                              targetid = me->surface.located_obj.objid,
                              targetos = me->surface.located_obj.osnum);
         }  

         me->surface = me->save_surf;
         me->save_surf.located_obj.objid = NULL_OBJID;
      }
      else
      {
/*
 * Erase the polygon should we go back to the state where we relocate
 * the surface.
 */
       sts = om$send (msg = message ECmvpls.display_polygon(FALSE),
                     targetid = my_id);
       ERROR(sts,1,"Error in displaying polygon")
       me->savedis = TRUE;

      }
     }
     else
     {
      sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,FALSE),
                     targetid = my_id);
      ERROR(sts,1,"display pole event")

      sts = om$send (msg = message ECmvpls.backup_pole_event(),
                     targetid = my_id);
      ERROR(sts,1,"backup pole event")
     }
    }
    else if (event.response == EX_DATA)
    {
/*
 * Get the pole index.
 */
     if (me->pole_selection == RANGE)
     {
      /*
       * Ask him to enter the to pole.
       */
      sts = om$send (msg = message ECmvpls.get_pole_position(&event,
                           &me->from_pole_inx,&onpolygon),
                    targetid = my_id);
      ERROR(sts,1,"get_pole_position error")

      if (onpolygon)
       ME.super_cmd->state = INPUT_TO_POLE;
      else
       {
        ME.super_cmd->state = INPUT_POLE;
        if (me->mytype == MOVE_POLES)
         ex$message(msgnumb = EMS_S_PlNtFnd) 
        else
         ex$message(msgnumb = EMS_S_NdNtFnd); 
       }
     }
     else 
     {
       /*
        * See if a fence or a solid has been located. If so use the same
        * to determine any poles which are inside and then go to the
        * state input pole again in which case he may decide to input
        * more poles or moves on.
        */

        IGRpoint pole;
        IGRint indices;
        IGRboolean volume_located = FALSE;
        IGRint future_size, current_size;
        struct GRid *component_GRid;
        struct GRid volume_GRid;
        IGRint type;
        IGRboolean return_volume_object();

        md_env = &event.located_object[0].module_info;

        if ((me->pole_selection == INDIVIDUALLY) &&
            (event.subtype == GRst_KEYPOINT))
        {
         component_GRid = &event.located_object[0].located_obj;

         sts = return_volume_object(&msg, component_GRid, md_env,
               &volume_GRid,&type);
         ERROR(1,msg,"return volume object")

         volume_located = ((type & VOLUME_LOCATED) ? TRUE : FALSE);
        }

        if (!volume_located)
        {
         sts = om$send (msg = message ECmvpls.get_pole_position(&event,
                           &me->from_pole_inx,&onpolygon),
                       targetid = my_id);
         ERROR(sts,1,"get_pole_position error")

        if (onpolygon)
         {
          if (me->pole_selection != ROW)
          {
            sts = om$send(msg = message ECmvpls.add_pole(1,&me->from_pole_inx),
                          targetid = my_id);
            ERROR(sts,1,"add pole error")

            sts = om$send (msg = message ECmvpls.add_pole_event(1),
                           targetid = my_id);
            ERROR(sts,1,"add pole event error")

            sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,TRUE),
                           targetid = my_id);
            ERROR(sts,1,"display_pole_event error")

            ME.super_cmd->state = INPUT_POLE;
         }
         else
         {
          IGRint pole_index;

            pole_index = me->from_pole_inx;

            sts = om$send (msg = message ECmvpls.store_row(me->row,
                                 pole_index),
                           targetid = my_id);
            if (!(1&sts)) return (OM_E_ABORT);

            sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,TRUE),
                           targetid = my_id);
            ERROR(sts,1,"display_pole_event error")

            ME.super_cmd->state = ACCEPT_REJECT_POLE;
         }
        }
         else
         {
          ME.super_cmd->state = INPUT_POLE;
          if (me->mytype == MOVE_POLES)
           ex$message(msgnumb = EMS_S_PlNtFnd)
          else
           ex$message(msgnumb = EMS_S_NdNtFnd);
         }
        }
        else
        {
         IGRint oldnum;

         oldnum = me->num_poles;

         if (type & FENCE_LOCATED)
         {
          if (me->mytype == MOVE_POLES)
           ex$message(msgnumb = EMS_S_ProcPlsInFnc)
          else
           ex$message(msgnumb = EMS_S_ProcNdsInFnc);
         }
         else if (type & SOLID_LOCATED)
         {
          if (me->mytype == MOVE_POLES)
           ex$message(msgnumb = EMS_S_ProcPlsInSld)
          else
           ex$message(msgnumb = EMS_S_ProcNdsInSld); 
         }

         
         sts = om$send (msg = message ECmvpls.storepoles_in_volume(&msg, 
                              type,md_env, &volume_GRid),
                        targetid = my_id);
         ERROR(sts,msg,"process volume"); 

        }
     }
    }
    else if (event.response == EX_RJT_MOVEON)
    {
      if (me->direction == VECTOR)
        ME.super_cmd->state = INPUT_FROM_POINT;
      else
        ME.super_cmd->state = IDENTIFY_NORMAL_ELEMENT;
 
    }
   }
   break;

   case ACCEPT_REJECT_POLE:
   {
    IGRint pole_index;
 
    event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP | GRm_RJT_MOVEON;


    if (me->mytype == MOVE_POLES)
     ex$message(msgnumb = EMS_P_AccptWithNxtStOfPlPts, buff = string)     
    else
     ex$message(msgnumb = EMS_P_AccptWithNxtStOfNdPts, buff = string); 

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_BACK_UP)
    {
      ME.super_cmd->state = INPUT_POLE;

      sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,FALSE),
                           targetid = my_id);
      ERROR(sts,1,"display_pole_event error")

      sts = om$send (msg = message ECmvpls.backup_pole_event(),
                           targetid = my_id);
      ERROR(sts,1,"display_pole_event error")
    }
    else if (event.response == EX_RJT_MOVEON)
    {
      sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,FALSE),
                           targetid = my_id);
      ERROR(sts,1,"display_pole_event error")

      sts = om$send (msg = message ECmvpls.backup_pole_event(),
                           targetid = my_id);
      ERROR(sts,1,"display_pole_event error")

      me->row = !me->row;

      sts = om$send (msg = message ECmvpls.store_row(me->row,
                           me->from_pole_inx),
                   targetid = my_id);
      if (!(1&sts)) return (OM_E_ABORT);

      sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,TRUE),
                           targetid = my_id);
      ERROR(sts,1,"display_pole_event error")

      ME.super_cmd->state = INPUT_POLE;
    }
    else if (event.response == EX_DATA)
    {
/*
 * Put the accept point on queue and go to INPUT_POLE_STATE again.
 */
      putque_size = sizeof(struct GRevent);
      sts =  ex$putque(msg = &msg, response = response,
                  byte =&putque_size, buffer = (IGRchar *) &event.event);
      ERROR(sts, msg, "ex$putque error")

      ME.super_cmd->state = INPUT_POLE;
    }
   }
   break;

   case INPUT_TO_POLE:
   {
    IGRpoint from_point;
    struct IGRbsp_surface *surf;
    IGRdouble weight;
    IGRshort type = IGRPS;
    IGRint indx,i;

    indx = me->from_pole_inx;
    surf = me->surf_ptr;

    if (surf->rational) weight = surf->weights[indx];
    else weight = 1;

    for (i=0;i<3;i++)
     from_point[i] = surf->poles[3*indx+i] / weight;
    
    ECdisplayPointSetByBuffer0 (&msg, ME.ECelement->active_display,
       ME.ECelement->md_env, my_id, 1, from_point, GRhd, type);
    ERROR(1,msg,"display point")

    event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP ;

    if (me->mytype == MOVE_POLES)
     ex$message(msgnumb = EMS_P_InputToPl, buff = string) 
    else
     ex$message(msgnumb = EMS_P_InputToNdPt, buff = string); 

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_BACK_UP)
    {
      ECdisplayPointSetByBuffer0 (&msg, ME.ECelement->active_display,
       ME.ECelement->md_env, my_id, 1, from_point, GRhe, type);
      ERROR(1,msg,"display point")

      ME.super_cmd->state = INPUT_FROM_POLE;
    }
    else if (event.response == EX_DATA)
    {
/*
 * Get the pole index.
 */
     sts = om$send (msg = message ECmvpls.get_pole_position(&event,
                          &me->to_pole_inx,&onpolygon),
                    targetid = my_id);
     ERROR(sts,1,"get_pole_position error")

     if (!onpolygon)
     {
      if (me->mytype == MOVE_POLES)
        ex$message(msgnumb = EMS_S_PlNtFnd)
      else
        ex$message(msgnumb = EMS_S_NdNtFnd);
      ME.super_cmd->state = INPUT_TO_POLE;
      break;
     }

     ME.super_cmd->state = INPUT_FROM_POLE;

    {
	IGRint current_size = 0, future_size = 0;
        IGRint i,u_inx, v_inx;
        IGRint save;
        IGRpoint poles[2];
        IGRint num_poles_in_event;
        IGRint indices[2],from_u_pole_inx, from_v_pole_inx,
               to_u_pole_inx,to_v_pole_inx,ptnum,from_p_inx, to_p_inx,cnt;
       
        indices[0] = me->from_pole_inx;
        indices[1] = me->to_pole_inx;

        surf = me->surf_ptr;

        from_u_pole_inx = indices[0] % surf->u_num_poles;
        from_v_pole_inx = indices[0] / surf->u_num_poles;

        to_u_pole_inx = indices[1] % surf->u_num_poles;
        to_v_pole_inx = indices[1] / surf->u_num_poles;

        if (from_u_pole_inx > to_u_pole_inx)
        {
          ptnum = from_u_pole_inx;
          from_u_pole_inx = to_u_pole_inx; 
          to_u_pole_inx = ptnum;
        }

        if (from_v_pole_inx > to_v_pole_inx)
        {
          ptnum = from_v_pole_inx;
          from_v_pole_inx = to_v_pole_inx;
          to_v_pole_inx = ptnum;
        }

        current_size = OM_DIMENSION_OF(me->indices);
        num_poles_in_event = 
                     (to_u_pole_inx - from_u_pole_inx + 1) *
                      (to_v_pole_inx - from_v_pole_inx + 1);
        future_size = me->num_poles + num_poles_in_event;

        if (future_size > current_size)
            OM_SET_DIMENSION(me->indices, future_size);

        save = cnt = me->num_poles;

        from_p_inx = surf->u_num_poles * from_v_pole_inx + 
                     from_u_pole_inx;
        to_p_inx = surf->u_num_poles * to_v_pole_inx +
                   to_u_pole_inx;

        for (i=from_p_inx; i<=to_p_inx;i++)
        {
          u_inx = i % surf->u_num_poles ; 
          v_inx = i / surf->u_num_poles ; 

         if (( u_inx >= from_u_pole_inx ) && 
            ( u_inx <= to_u_pole_inx) && 
            ( v_inx >= from_v_pole_inx) && 
            ( v_inx <= to_v_pole_inx)) 
          { 
            me->indices[cnt] = i;
            ++cnt;
          } 
        else 
            continue ; 
        } 
        me->num_poles = cnt;

        sts = om$send (msg = message ECmvpls.add_pole_event(num_poles_in_event),
                             targetid = my_id);
        ERROR(sts,1,"addpole event")

        sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,TRUE),
                       targetid = my_id);
        ERROR(sts,1,"display pole event")
      }
     }
    }
   break;
/*
 * Identify element normal to which the poles should be moved.
 */
   case IDENTIFY_NORMAL_ELEMENT :
      {
       attributes.properties &= ~LC_WRITE_ONLY; 
       if (me->form_displayed) 
       {
        FIf_erase(ME.ECmvpls->form1);
        me->form_displayed = FALSE;
       }

       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_REF_OBJECTS |		/* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;		/* No reference file headers */

       rtree_classes.w_count = 1;
       eligible_classes.w_count = 2;
       r_classes[0] = OPP_GRvg_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[1] = OPP_GRbspline_class_id;

       ex$message(msgnumb = EMS_P_IdnEleNorToWhPlsMv, buff = locate_prompt2);
       ex$message(msgnumb = EMS_P_AccptFrPtToMv, buff = acc_prompt2);

       sts = lc$locate(
         rc =			&msg,
         event1 =		&me->locate_event,
         event2 =		&accept_event,
         mask1 =		locate_mask,
         mask2 =		accept_mask,
         display_flag =		display_flag,
         locate_prompt =        locate_prompt2,
         acc_prompt =           acc_prompt2,
         relocate_key = 	EMS_I_00011,
         attributes = 		&attributes,
         stack = 		&me->locate_stack,
         rtree_classes = 	&rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, 1, "GRlclocate error")

       if (!(1&msg))
       {
        if (ME.ECmvpls->locate_event.response == EX_BACK_UP)
        {
         sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,FALSE),
                        targetid = my_id);
         ERROR(sts,1,"display pole event")

         sts = om$send (msg = message ECmvpls.backup_pole_event(),
                        targetid = my_id);
         ERROR(sts,1,"backup pole event");

         if (me->pole_selection == RANGE)
          ME.super_cmd->state = INPUT_TO_POLE;
         else
          ME.super_cmd->state = INPUT_POLE;
        }
        else
         return(OM_S_SUCCESS);
       }
       else
       {
         display_mode = GRhe;

         ME.ECmvpls->normal_element = accept_event.located_object[0];

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->normal_element.module_info.md_env.matrix_type,
                         me->normal_element.module_info.md_env.matrix,
                         &display_mode,
                         &me->normal_element.module_info.md_id),
                   targetid = me->normal_element.located_obj.objid,
                   targetos = me->normal_element.located_obj.osnum);
         ERROR(sts,msg,"In erasing surface")

/*
 * Put the accept point on queue.
 */
        if (accept_event.response == EX_DATA)
        {
          putque_size = sizeof(struct GRevent);
          sts =  ex$putque(msg = &msg, response = response,
                  byte =&putque_size, buffer = (IGRchar *) &accept_event.event);
          ERROR(sts, msg, "ex$putque error")
        }
        ME.super_cmd->state = INPUT_FROM_POINT;
       }
     }
   break;

   case INPUT_FROM_POINT:
   {
    event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP;
/*
 * Determine the pole indices and store the same in the instance data.
 * Highlight the pole indices.
 */
    if (me->form_displayed) 
    {
      FIf_erase(ME.ECmvpls->form1);
      me->form_displayed = FALSE;
    }

    ex$message(msgnumb = EMS_P_00049, buff = string);

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_BACK_UP)
    {
     if (me->direction == NORMAL_TO_ELEMENT)
      ME.super_cmd->state = IDENTIFY_NORMAL_ELEMENT;
     else 
     {
         sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,FALSE),
                        targetid = my_id);
         ERROR(sts,1,"display pole event")

         sts = om$send (msg = message ECmvpls.backup_pole_event(),
                        targetid = my_id);
         ERROR(sts,1,"backup pole event");

         if (me->pole_selection == RANGE)
          ME.super_cmd->state = INPUT_TO_POLE;
         else
          ME.super_cmd->state = INPUT_POLE;
     }
    }
    else if (event.response == EX_DATA)
    {
      struct EX_button *data;
      data = &event.event.button;
      me->from_point[0] = data->x;
      me->from_point[1] = data->y;
      me->from_point[2] = data->z;
     ME.super_cmd->state = INPUT_TO_POINT;;
    }
   }
   break;

/*
 * Get the to position of the vector used to move the poles.
 */
   case INPUT_TO_POINT:
   {
    struct EMmove_pole_addtnl_info info;
    IGRdouble max_dist = 0.0, min_dist = 0.0;
    IGRboolean max_dist_ok = FALSE, min_dist_ok = FALSE;
    IGRdouble zero_tol,*dist_ptr;
    IGRushort options;
    IGRboolean same = FALSE;
    IGRint rc;

    info.vectors = NULL;
    info.dists = NULL;
    info.ref_vector = NULL;
    info.ref_dist = NULL;

    event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP;

    ex$message(msgnumb = EMS_P_00050, buff = string);
    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
               in_buff = string);   

    BSEXTRACTPAR(&rc,BSTOLBASIS,zero_tol);

    if (me->direction == NORMAL_TO_ELEMENT)
    {
      IGRint current_size,future_size,index,npts,i,j;
      struct IGRbsp_surface *surf = NULL;
      IGRdouble weight;

       current_size = OM_DIMENSION_OF(me->vectors);

/*
 * +1 is to also pass the direction of the from_point to the minimum 
 * distance point on the surface.
 */
       future_size = (me->num_poles + 1) * 3;
       npts = me->num_poles + 1;

       if (future_size > current_size)
       {
         sts = OM_SET_DIMENSION (me->vectors,future_size);
         ERROR(sts,1,"In mallocing memory");
       }

       current_size = OM_DIMENSION_OF(me->pts);

       if (future_size > current_size)
       {
        sts = OM_SET_DIMENSION(me->pts,future_size);
        ERROR(sts,1,"In mallocing memory");
       }

       if (me->mag != EQUALLY)
       {
        current_size = OM_DIMENSION_OF(me->dists);
        future_size = npts;

        if (future_size > current_size)
        {
         sts = OM_SET_DIMENSION(me->dists,future_size);
         ERROR(sts,1,"In mallocing memory");
        }
       }
        
       if (me->surf_ptr) surf = me->surf_ptr;
       else
        ERROR(0,0,"Invalid State")

       for (i=0;i<me->num_poles;i++)
       {
        index = me->indices[i];
        if (surf->rational)
         weight = surf->weights[index];
        else
         weight = 1;
        for (j=0;j<3;j++)
         me->pts[3*i+j] = surf->poles[3*index+j]/weight;
       }

       for (i=0;i<3;i++)
        me->pts[3*(npts - 1) + i] = me->from_point[i];

       sts = EFproject_pts_onto_element(&msg,&me->normal_element.located_obj,
                                  &me->normal_element.module_info,npts,
                                  me->pts,me->vectors,
                                  ((me->mag == EQUALLY) ? NULL : me->dists),
                                  NULL,
                                  me->vectors,
                                  me->from_point);
       ERROR(sts,msg,"EFproject_pts")

       info.vectors = me->vectors;

      if (me->mag != EQUALLY)
      {
        max_dist = me->dists[0];
        min_dist = me->dists[0];
        for (i=0;i<me->num_poles;i++)
        {
         if (me->dists[i] > max_dist)
          max_dist = me->dists[i];

         if (me->dists[i] < min_dist)
          min_dist = me->dists[i];
        }

       max_dist_ok = ((max_dist > zero_tol) ? TRUE : FALSE);
       min_dist_ok = ((min_dist > zero_tol) ? TRUE : FALSE);

       for (i=0;i<me->num_poles;i++)
       {
        dist_ptr = &me->dists[i];

        if (me->mag == DIRECTLY)
          (*dist_ptr) = (max_dist_ok ? (*dist_ptr/max_dist) : 1.0);
        else if (me->mag == INVERSELY)
        {
          if (*dist_ptr < zero_tol) *dist_ptr = 1.0;
          else
           *dist_ptr = min_dist/(*dist_ptr);
/*
 *        (*dist_ptr) = (min_dist_ok ? (min_dist/(*dist_ptr)) : 1.0);
 */
        }
       }
        info.dists = me->dists;
      }
       info.ref_vector = &me->vectors[3*(npts - 1)];
     }

    sts = om$send (msg = message ECmvpls.display_pole_event(TRUE,FALSE),
                   targetid = my_id);
    ERROR(sts,1,"Display pole event")

    options = ((me->direction == NORMAL_TO_ELEMENT) ?
                EMMOVE_POLE_ALONG_SPECIFIED_VECTORS : NULL);

    if (me->mag != EQUALLY)
     options |= EMMOVE_POLE_ALONG_SPECIFIED_DISTS;

    sts = om$send(msg = message EMSsubbs.EMdynmod(&msg,
                              &me->surface.module_info.md_env.
                              matrix_type, me->surface.
                              module_info.md_env.matrix, 
                              options,
                              me->num_poles,
                              me->indices,NULL,me->from_point,
                              (IGRchar *) 
                              ((me->direction == NORMAL_TO_ELEMENT) ?
                              &info : NULL)),
                        targetid = me->surface.located_obj.objid,
                        targetos = me->surface.located_obj.osnum);
    ERROR(sts,msg,"In dynamics")

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt     =       string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_BACK_UP)
    {
/*
 * Redisplay all the poles.
 */

      ME.super_cmd->state = INPUT_FROM_POINT;
      sts = om$send (msg = message ECmvpls.display_pole_event(TRUE,TRUE),
                   targetid = my_id);
      ERROR(sts,1,"Display pole event")
    }
    else if (event.response == EX_DATA)
    {
      OM_BLOCK_MOVE (&event.event.button.x,me->to_point,sizeof(IGRpoint));

    display_mode = GRbe;

    sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
    ERROR(sts,msg,"In erasing surface")

    if (me->mytype == MOVE_NODES)
    {
     display_mode = GRbe;

     sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->save_surf.module_info.md_env.matrix_type,
                         me->save_surf.module_info.md_env.matrix,
                         &display_mode,
                         &me->save_surf.module_info.md_id),
                   targetid = me->save_surf.located_obj.objid,
                   targetos = me->save_surf.located_obj.osnum);
     ERROR(sts,msg,"In erasing surface")
    }

/*
 * store the fact if the surface being modified is the same as the
 * normal element.
 */

    if (me->direction == NORMAL_TO_ELEMENT)
    {
     same = IF_EQ_OBJID(me->surface.located_obj.objid,
             me->normal_element.located_obj.objid);
    }

    ex$message(msgnumb = EMS_I_00003);

    sts = om$send(mode = OM_e_wrt_object,
                     msg = message EMSsubbs.EMmove_poles(&msg,
                              &me->surface.module_info,
                              options,
                              me->num_poles,
                              me->indices,me->from_point,me->to_point,
                              (IGRchar *) ((me->direction == NORMAL_TO_ELEMENT) ?
                              &info : NULL),
                              &me->surface.located_obj.objid),
                        targetid = me->surface.located_obj.objid,
                        targetos = me->surface.located_obj.osnum);
    ERROR(sts,msg,"In moving poles")

    if (me->mytype == MOVE_NODES)
    {
     struct IGResbs element_specific;
     struct GRlc_info temp_info;

/*
 * The new geometry is returned in save_surf.
 */

     p_fit_rational_surface(&msg,&me->save_surf.module_info,
                            &me->save_surf.located_obj,
                            me->unum, me->vnum, me->u_vals, me->v_vals,
                            me->weights, me->node_pts,
                            &me->surface.located_obj,
                            &me->surface.module_info);
     ERROR(1,msg,"p fit rational surf")

     if ((me->surface.located_obj.objid != NULL_OBJID) &&
       (me->save_surf.located_obj.objid != NULL_OBJID))
     {
        IGRlong cln_sts,loc_msg;

        cln_sts = om$send (msg = message GRgraphics.GRdelete(&loc_msg,
                  &me->surface.module_info),
                  targetid = me->surface.located_obj.objid,
                  targetos = me->surface.located_obj.osnum);
     }
     me->surface = me->save_surf;
     me->save_surf.located_obj.objid = NULL_OBJID;
    }

    display_mode = GRbd;

    sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
    ERROR(sts,msg,"In drawing surface")

/*
 * If the normal element is the same as the object being modified then
 * should the object id change reflect the same in the object id stored
 * of the normal element.
 */
    if ((me->direction == NORMAL_TO_ELEMENT) && same)
    {
      me->normal_element.located_obj = 
        me->surface.located_obj;
    }

   ex$message(msgnumb = EMS_S_ClearStatusField); 

   if (me->mytype == MOVE_POLES)
   {
/*
 * Need to restore the geometry because it has changed.
 */
    sts = om$send (msg = message ECmvpls.store_geom(&msg),
                      targetid = my_id);
    ERROR(sts,msg,"Error in storing geometry")

    OM_BLOCK_MOVE(me->to_point, me->from_point, sizeof(IGRpoint));

     ME.super_cmd->state = INPUT_TO_POINT;
   }
   else
   {
     ME.super_cmd->state = IDENTIFY_SURFACE;
/*
 * Delete the saved surface.
 */

    if (me->num_pole_events)
    {
      sts = om$send (msg = message ECmvpls.display_pole_event(TRUE,FALSE),
                     targetid = my_id);
      ERROR(sts,1,"In display pole event")
    }

     me->num_pole_events = 0;
     me->num_poles = 0;

     me->surface.located_obj.objid = NULL_OBJID;
     me->save_surf.located_obj.objid = NULL_OBJID; 
     me->savedis = TRUE;
   }
  }
 }
   break;
  }
 } while (TRUE);
 return (OM_S_SUCCESS);
}
end implementation ECmvpls;

