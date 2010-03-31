class implementation ECprfsksf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "EC_M.h"

#include "EMSmsgdef.h"		        /* EMS_I_NotFound */
#ifndef ECmsg_include
#define ECmsg_include
#include "ECmsg.h"
#endif

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

#include "EMSdpb.h"
#include "emsdef.h"
#include "EMSifmacros.h"
#include "EMSasmacros.h"
#include "EMSasnuc.h"
#include "grmacros.h"
#include "EMSdatumdef.h"
#include "maunitvc.h"
#include "bsdistptpts.h"
#include "bserr.h"

from GRgraphics import GRdelete;
from GRcurve import GRendpts;
from EMSdatpln import EMget_pln_info;

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRplanar_class_id;
extern OMuword OPP_GRlinestr_class_id;

%safe
/* static IGRboolean GS_tansf = FALSE; */
static IGRboolean GS_smooth = FALSE, GS_point = TRUE, GS_angle = TRUE;
static IGRlong    GS_coords = 1;
%endsafe


/*
Name
  execute

Abstract
 Places a cross-section surface.

Synopsis
 int *response; 
 char *response_data; 
 int pos;

Description
 This is the command object for the place surface by planar
 cross-sections functionality.

 The basic flow is as follows:
 Define one trace (surface boundarys are allowed).
 Switch trace curve coordinate system method by options form. 
 Define trace curve coordinate system (to bring cross-sections into line)
 Collect all cross sections.
  - (1) Select cross-section
  - (2) Select origin of cross-section
  - (3) Select location on curve
  - (4) Map cross-section onto curve
  - (5) Manipulate ( rotate and/or mirror ) cross-section at location.
 If more cross-sections to select, repeat steps 1 - 4 for every
 cross-section ( without mirroring ).
 Ask if trace is to be closed (not implemented).
 Generate a sufficient number of linear blended supporting profiles  
 Place cross-section surface.

Keywords
 place,surface,execute
History
 02/15/94       R. Burkhart
    Creation date. This command was written based on the old command ECplcskinsfi.I .
*/

method execute(int *response; char *response_data; int pos)
{
 IGRchar        prompt[80];
 IGRdouble      dist1, dist2;
 IGRpoint       start_pt, end_pt, chk_pt, dir_vector;
 IGRboolean	put_on_queue, use_default, is_curve_reversed;
 IGRlong        event_mask, i, j, key, sts, msg, previous_state;
 OMuword	srfos;
 GRobjid	srfid;
 struct		GRprops	props;
 struct		GRlc_info *lc_info;
 struct		GRid id;
 struct		RLW_locate_info loc_info;

 /* Initialize */
  ex$message ( msgnumb = EM_M_PlcrsecSurf )

 /* Enter infinite loop */
 do
 {
  /*
   * I am trying to save the position of the command before it enters
   * the processing state so that I can backup to that state again
   * after processing.
   */
   if (me->state != PROCESS)
      previous_state = me->state;

   /* Branch based on our state */
   switch(me->state)
   {
     /* Room for growth */

     case INITIALIZE:
        me->previous_trace_count = me->num_trace;   /* Save for wrap around */
        me->previous_cross_count = me->num_cross;
        me->num_trace = 0;
        me->num_cross = 0;

        /* global statics */
        me->smooth = GS_smooth;
        /*me->tan_constrnt = GS_tansf;*/
        me->select_screen_pos = GS_point;
        me->angle_constant = GS_angle ;

        if (me->have_a_constructed_object)
            key = EMS_I_PrCompBcUp;
        else
            key = EMS_I_SwTrcoords;

        ex$message(msgnumb = key);
        GRstatus_display_button(1);

        /* enable select of trace curve coordinate system, does work for save/restore form only.
        if form was made permanent, update comes to view after an action on form */
        sts = om$send(msg = message ECconstruct.update_status_form(),
                 targetid = my_id);
         ON_ERROR goto kill_command;

        me->state = TRACE_CURVES;
        break;

     /* Get the trace curve */

     case TRACE_CURVES:

      event_mask = GRm_DATA | GRm_BACK_UP;
      ex$message( msgnumb = EMS_P_SelTrCurve, buff = prompt);  /* Select trace curve */

      EFget_locate_information( BIG_CURVE, &loc_info);
      loc_info.identify_event_type = good_data;
      loc_info.accept_event_type = dummy;

       /* if edge curves are currently not locatable, set this mode locally */
       me->edges_locatable = EFedge_curves_locatable();
       if (! me->edges_locatable)
          EFset_locate_eligibility(&msg, 1, "EMSedge");

      sts = om$send( msg = message ECconstruct.locate_object(
                                        event_mask,
                                        prompt,
                                        LC_NO_MSG,	/* No locate key */
                                        &loc_info,
                                        TRUE,           /* Automatically put accept event on queue */
                                        &put_on_queue,  /* Is possible to put accept event on queue? */
                                        response,
                                        response_data),
                targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);

      /* reset edge locatability */
      if (! me->edges_locatable)
         EFset_locate_eligibility(&msg, 0, "EMSedge");

      switch (me->event.response)
      {
        case GR_UNKNOWN_TYPE:
           return(OM_S_SUCCESS);
        case EX_BACK_UP:
        {
           IGRboolean	wraping;
 
           wraping = ((me->number_of_events_input == 0) &&
                     me->have_a_constructed_object);
           if (wraping)
           {
              me->num_trace = me->previous_trace_count;
              me->num_cross = me->previous_cross_count;
           }

           /* decrement number of events, reloads last point information */
           sts = om$send( msg = message ECconstruct.backup_event(),
                     targetid = my_id);
           ON_ERROR goto kill_command;
           if (wraping)
           {
              /* switch from backup_msg to options_msg */
              ex$message(msgnumb = EMS_I_InvkStatusFrm);

              /* redisplay previously mapped cross_sections */
              for (i=0;i<me->previous_cross_count;i++)
              {
                 sts = gr$display_object ( object_id = &me->crspic[i], mode = GRbd);
                  ON_ERROR goto kill_command;
              }

           }
           else if (me->num_trace == 0)
              me->state = INITIALIZE;
           else
           {
              me->num_trace--;
              lc_info = &me->trcobj[me->num_trace];
              is_curve_reversed = lc_info->geom_parms.polygon_inx;
/*********************************************************************
              EFdisplay_curve_normal_or_tangent:
                               lc_info 		The curve 
                               NULL 		Not used for tangents 
                               FALSE 		Display the tangent vector 
                               GRbe 		Drawmode: Erase 
                               &me->display     color, weight, style
**************************************************************************/
              sts = ems$display_curve_normal_or_tangent(
                                          loc_info = lc_info,
                            display_normal_tangent = FALSE,
                                    reverse_vector = is_curve_reversed,
                                          senderid = my_id,
                                         draw_mode = GRbe,
                                     display_mdenv = &me->display_env,
                                           display = &me->display,
                                               msg = &msg);
              ON_ERROR goto kill_command;
           }
        }
        break;

        default:                  /* Object was located */
        {
          IGRlong	current_size;
 
          sts = om$send( msg = message ECconstruct.add_event(TRUE),    /* It is a located object */
                    targetid = my_id);
           ON_ERROR goto kill_command;

          /* check number of alloc. elements for VLA, change size */
          current_size = om$dimension_of(varray = me->trcobj);
          if (me->num_trace == current_size)
           {
            sts = om$vla_set_dimension( varray = me->trcobj, size = current_size + 10);
             ON_ERROR goto kill_command;
           }

          /* curve parameter flow */
          sts = EFdetermine_direction( &me->event, my_id, &msg);
           ON_ERROR goto kill_command;

          /*get properties of input event (closed,segmented,obj.type ...)*/
          sts = EFgetprops( &me->event, my_id, &props, &msg);
           ON_ERROR goto kill_command;

          me->trcobj[me->num_trace] = me->event.located_object[0];
          lc_info = &me->trcobj[me->num_trace];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          lc_info->geom_parms.leaf_id.objid = props.phy_closed;
/*************************************************************************
          EFdisplay_curve_normal_or_tangent:
                                  lc_info	The curve 
                                  NULL 		Not used for tangents 
                                  FALSE		Display the tangent vector 
                                  GRbd 		Draw background 
**************************************************************************/
          sts = ems$display_curve_normal_or_tangent(
                                        loc_info = lc_info,
                          display_normal_tangent = FALSE,
                                  reverse_vector = is_curve_reversed,
                                        senderid = my_id,
                                       draw_mode = GRbd,
                                   display_mdenv = &me->display_env,
                                         display = &me->display,
                                             msg = &msg);
          ON_ERROR goto kill_command;

          me->traces_are_closed = TRUE;
          if (! me->trcobj[me->num_trace].geom_parms.leaf_id.objid)
                me->traces_are_closed = FALSE;

          me->num_trace++;

          /* switch to selected definition of trace curve coordinate system */
          if (me->coordsys_case == 1 )
          {
             me->state = PARALLEL_TO_PLANE;
          }
          else if (me->coordsys_case == 2 )
          {
             me->state = VEC_DIRECTION;
          }
          else if (me->coordsys_case == 3 )
          {
             me->state = SURFACE_NORMAL;
          }
        }
        /* disable reselect of trace curve coordinate system */
        sts = om$send(msg = message ECconstruct.update_status_form(),
                 targetid = my_id);
         ON_ERROR goto kill_command;

        /* delete previously mapped cross_sections */
        for (i=0;i<me->previous_cross_count;i++)
        {
           gr$delete_object (msg = &msg, object_id = &me->crspic[i]);
           if (!(1&msg)) goto kill_command;
        }

        break; /* end case default */
      }        /* end switch (me->event.response) */
      break;   /* end case TRACE_CURVES */

    /* define the trace curve coordinate system by parallel plane */
    case PARALLEL_TO_PLANE:
       ex$message(msgnumb = EMS_I_XisPartoPl);

       event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       ex$message( msgnumb = EMS_P_IdBasePlnMvOnXY, buff = prompt);  /* Identify base plane/Move on for xy-plane */

       EFget_locate_information( BIG_SURFACE, &loc_info);
       loc_info.identify_event_type = good_data;
       loc_info.accept_event_type = dummy;
       loc_info.planar_flag =  LC_PLANAR_ONLY;
       loc_info.relocate_key = EMS_P_ElementNotFound;

       loc_info.eligible_classes.w_count = 2;
       loc_info.e_classes[0] = OPP_EMSsubbs_class_id;
       loc_info.e_classes[1] = OPP_EMSdatpln_class_id;
       loc_info.eligible_classes.p_classes = loc_info.e_classes;

       loc_info.rtree_classes.w_count = 1;
       loc_info.r_classes[0] = OPP_GRvg_class_id;
       loc_info.rtree_classes.p_classes = loc_info.r_classes;

       sts = om$send( msg = message ECconstruct.locate_object(
                                        event_mask,
                                        prompt,
                                        LC_NO_MSG,      /* No locate key */
                                        &loc_info,
                                        TRUE,           /* Automatically put accept event on queue */
                                        &put_on_queue,  /* Is possible to put accept event on queue? */
                                        response,
                                        response_data),
                 targetid = my_id);
        ON_ERROR goto kill_command;
       if (me->locate_stack.num_entries) return(OM_S_SUCCESS);

       switch (me->event.response)
       {
         case GR_UNKNOWN_TYPE:
            return(OM_S_SUCCESS);

         case EX_RJT_MOVEON:
            sts = om$send( msg = message ECconstruct.add_event(FALSE),
                      targetid = my_id);
             ON_ERROR goto kill_command;
            /* use normal of xy-plane */
            for (i=0;i<3;i++){ me->wrk.parpln[i] = 0.0;}
            me->wrk.parpln[2] = 1.0;
            me->state = CROSS_CURVES;
            break;
 
         case EX_BACK_UP:
            sts = om$send( msg = message ECconstruct.backup_event(),
                      targetid = my_id);
             ON_ERROR goto kill_command;
            me->state = TRACE_CURVES;
            break;

         default:
            sts = om$send( msg = message ECconstruct.add_event(TRUE),    /* It is a located object */
                      targetid = my_id);
             ON_ERROR goto kill_command;

            /* get the reference plane normal */
            for (i=0;i<3;i++){ me->wrk.parpln[i] = 0.0;}

            sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg, NULL, NULL,
                                                   NULL, NULL, &(me->wrk.parpln[0]), NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = me->event.located_object[0].located_obj.objid,
                      targetos = me->event.located_object[0].located_obj.osnum);
             ON_ERROR goto kill_command;
            me->state = CROSS_CURVES;
            break;
       } 
    break;

    /* define the trace curve coordinate system by direction vector */
    case VEC_DIRECTION:
       ex$message(msgnumb = EMS_I_XisParVec);

       key = EMS_P_EntDirVec;  /*  Enter axis (net direction) [x]/Move on for using vector */
       event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
       sts = om$send( msg = message ECconstruct.getevent(
                                                    NONE,     /* Don't need a value */
                                              event_mask,
                                                    NULL,     /* No prompt string */
                                                     key,
                                                response,
                                           response_data),
                 targetid = my_id);
        ON_ERROR goto kill_command;

       switch (me->event.response)
       {
         case GR_UNKNOWN_TYPE:
            return(OM_S_SUCCESS);

         case EX_BACK_UP:
            sts = om$send( msg = message ECconstruct.backup_event(),
                      targetid = my_id);
             ON_ERROR goto kill_command;
            me->state = TRACE_CURVES;
            break;

         case EX_RJT_MOVEON:
            me->state = GET_VECTOR;
            break;

         default:
            for (i=0;i<3;i++){ me->wrk.parpln[i] = 0.0;}
            use_default = (me->msg == GRw_no_value);
            if (use_default || (toupper(me->event.event.keyin[0]) == 'X'))
               me->wrk.parpln[0] = 1.0;
            else if (toupper(me->event.event.keyin[0]) == 'Y')
               me->wrk.parpln[1] = 1.0;
            else if (toupper(me->event.event.keyin[0]) == 'Z')
               me->wrk.parpln[2] = 1.0;
            else
               return(OM_S_SUCCESS);       /* Must have meant a command */

            sts = om$send( msg = message ECconstruct.add_event( FALSE),  /* Not a located object */
                      targetid = my_id);
             ON_ERROR goto kill_command;
            me->state = CROSS_CURVES;
            break;
        } /* switch (me->event.response) */
    break;

    /* locate a line to determine direction vector */
    case GET_VECTOR:
       event_mask = GRm_DATA | GRm_BACK_UP;
       ex$message( msgnumb = EMS_P_VecLocLin, buff = prompt);  /* Identify line for direction vector */

       EFget_locate_information( LITTLE_CURVE, &loc_info);
       loc_info.identify_event_type = good_data;
       loc_info.accept_event_type = dummy;
       loc_info.acc_key = EMS_P_AccAtPosEnd;                   /* Accept near desired endpoint/Reject */
       loc_info.e_classes[0] = OPP_GRlinear_class_id;

       sts = om$send( msg = message ECconstruct.locate_object(
                                         event_mask,
                                         prompt,
                                         LC_NO_MSG,      /* No locate key */
                                         &loc_info,
                                         TRUE,           /* Automatically put accept event on queue */
                                         &put_on_queue,  /* Is possible to put accept event on queue? */
                                         response,
                                         response_data),
                 targetid = my_id);
        ON_ERROR goto kill_command;
       if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
 
       switch (me->event.response)
       {
         case GR_UNKNOWN_TYPE:
            return(OM_S_SUCCESS);

         case EX_BACK_UP:
            sts = om$send( msg = message ECconstruct.backup_event(),
                      targetid = my_id);
             ON_ERROR goto kill_command;
            me->state = VEC_DIRECTION;
            break;

         default:
            id = me->event.located_object[0].located_obj;
            sts = gr$display_object( object_id = &id, mode = GRhe );
            ON_ERROR goto kill_command;

            /* check, if wrong element was selected */
            if (EFisAncestryValid(&msg, id.objid, id.osnum, OPP_GRpoint_class_id, FALSE)||
                EFisAncestryValid(&msg, id.objid, id.osnum, OPP_GRplanar_class_id, FALSE)||
                EFisAncestryValid(&msg, id.objid, id.osnum, OPP_GRlinestr_class_id, FALSE))
            {
               ex$message( msgnumb = EMS_S_ElmNotAld);  /* Element not allowed */
               me->state = GET_VECTOR;
               break;
            }
            sts = om$send( msg = message ECconstruct.add_event(TRUE),    /* It is a located object */
                      targetid = my_id);
             ON_ERROR goto kill_command;

            /* find endpoints of line */
            sts = om$send ( msg = message GRcurve.GRendpts ( &msg,
                                          &me->event.located_object[0].module_info.md_env.matrix_type,
                                          me->event.located_object[0].module_info.md_env.matrix,
                                          start_pt, end_pt),
                            senderid = my_id,
                                mode = OM_e_wrt_object,
                            targetid = id.objid,
                            targetos = id.osnum );
            ON_ERROR goto kill_command;

            /* should we switch the points ? */
            chk_pt[0] = me->event1.event.button.x;
            chk_pt[1] = me->event1.event.button.y;
            chk_pt[2] = me->event1.event.button.z;
            dist1 = BSdistptpts(&msg, start_pt, chk_pt);
            if (msg) goto kill_command;
            dist2 = BSdistptpts(&msg, end_pt, chk_pt);
            if (msg) goto kill_command;

            if (dist1 < dist2)
            {
               /* switch points */
               OM_BLOCK_MOVE ( &start_pt, &chk_pt, sizeof(IGRpoint) );
               OM_BLOCK_MOVE ( &end_pt, &start_pt, sizeof(IGRpoint) );
               OM_BLOCK_MOVE ( &chk_pt, &end_pt, sizeof(IGRpoint) );
            }
            /* unitize direction vector */
            dir_vector[0] = end_pt[0] - start_pt[0];
            dir_vector[1] = end_pt[1] - start_pt[1];
            dir_vector[2] = end_pt[2] - start_pt[2];
         
            MAunitvc(&msg, &dir_vector[0], &me->wrk.parpln[0] );
            me->state = CROSS_CURVES;
            break;
        } /* switch (me->event.response) */
    break;
 
    /* define the trace curve coordinate system by surface normal */
    case SURFACE_NORMAL:
       /* initialize for recomputation info */
       for (i=0;i<3;i++){ me->wrk.parpln[i] = 0.0;}

       ex$message(msgnumb = EMS_I_YisSurfNor);
       srfid = NULL_OBJID;
       /* check, if trace is surface_boundary */
       /* get surface objid */
       {
          OM_S_CHANSELECT	father;
          OMuint		sf;

          sts = EMmake_chanselect (NDfather_father, &father);
          if(! (1&sts))
          {
             me->state = GET_SURFACE;
             break;
          }

          sts = om$get_channel_count(objid = me->trcobj[0].located_obj.objid,
                                     osnum = me->trcobj[0].located_obj.osnum,
                              p_chanselect = &father,
                                     count = &sf);

          /* no father channel or empty channel */
          if ( !sf || !(1&sts) )
          {
             me->state = GET_SURFACE; 
             break;
          }
          else
          {
             OM_S_OBJECT_LINKAGE    srf;
             OMuint                 count;

             sts = om$get_channel_objects(objid = me->trcobj[0].located_obj.objid,
                                          osnum = me->trcobj[0].located_obj.osnum,
                                   p_chanselect = &father,
                                           list = &srf,
                                           size = 1,
                                          count = &count);
             if((!(1&sts)) || (count!=1)){me->state = GET_SURFACE; break;}
             srfid = srf.S_objid;
             srfos = srf.osnum;
          }
       }

       if  ((srfid != NULL_OBJID) &&
           (EFisAncestryValid(&msg, srfid, srfos, OPP_EMSgenbs_class_id, FALSE)) )
       {
          /* should we use this surface ? */
          key = EMS_P_UseSrfTrc;  /* Should the surface of trace curve (boundary) be used? y/n [y] */
          event_mask = GRm_TEXT_VALUE | GRm_BACK_UP;
          sts = om$send( msg = message ECconstruct.getevent( NONE,     /* Don't need a value */
                                                       event_mask,
                                                             NULL,     /* No prompt string */
                                                              key,
                                                         response,
                                                   response_data),
                    targetid = my_id);
           ON_ERROR goto kill_command;

          switch (me->event.response)
          {
            case GR_UNKNOWN_TYPE:
               return(OM_S_SUCCESS);

            case EX_BACK_UP:
               sts = om$send( msg = message ECconstruct.backup_event(),
                         targetid = my_id);
                ON_ERROR goto kill_command;
               me->state = TRACE_CURVES;
               break;

            default:
               use_default = (me->msg == GRw_no_value);
               if (use_default || (toupper(me->event.event.keyin[0]) == 'Y'))
               {
                  /* build the lc_info of the surface as a copy from boundary, did not find a macro
                  or method for getting this by the objid of surface */
                  me->orient_surface = me->trcobj[0]; 
                  me->orient_surface.located_obj.objid = srfid;
                  me->orient_surface.geom_parms.leaf_id.objid = NULL;
                  me->orient_surface.geom_parms.leaf_id.osnum = NULL;
                  me->orient_surface.geom_parms.polygon_inx   = 85;     /* may be another value will also work */
                  me->state = CROSS_CURVES;
               }
               else if (toupper(me->event.event.keyin[0]) == 'N')
                  me->state = GET_SURFACE;
               else
                  return(OM_S_SUCCESS);       /* Must have meant a command */

               sts = om$send( msg = message ECconstruct.add_event( FALSE),  /* Not a located object */
                         targetid = my_id);
                ON_ERROR goto kill_command;
               break;
          } /* switch (me->event.response) */
       }
       else
       {
          me->state = GET_SURFACE;
       }
       break;

    /* select surface */
    case GET_SURFACE:
       event_mask = GRm_DATA | GRm_BACK_UP;

       ex$message( msgnumb = EMS_P_00031, buff = prompt);  /* Identify surface */

       EFget_locate_information( LITTLE_SURFACE, &loc_info);
       loc_info.identify_event_type = good_data;
       loc_info.accept_event_type = dummy;
       sts = om$send( msg = message ECconstruct.locate_object(
                                       event_mask,
                                       prompt,
                                       LC_NO_MSG,        /* No locate key */
                                       &loc_info,
                                       TRUE,             /* Automatically put accept event on queue */
                                       &put_on_queue,    /* Is possible to put accept event on queue? */
                                       response,
                                       response_data),
                 targetid = my_id);
        ON_ERROR goto kill_command;
       if (me->locate_stack.num_entries) return(OM_S_SUCCESS);

       switch (me->event.response)
       {
         case GR_UNKNOWN_TYPE:
            return(OM_S_SUCCESS);
  
         case EX_BACK_UP:
            sts = om$send( msg = message ECconstruct.backup_event(),
                     targetid = my_id);
            ON_ERROR goto kill_command;
            me->state = TRACE_CURVES;
            break;
  
         default:                                            /* Object was located */
            id = me->event.located_object[0].located_obj;
            sts = gr$display_object( object_id = &id, mode = GRhe );
            ON_ERROR goto kill_command;

            sts = om$send( msg = message ECconstruct.add_event(TRUE),
                      targetid = my_id);
             ON_ERROR goto kill_command;
            me->orient_surface = me->event.located_object[0];
            me->state = CROSS_CURVES;
            break;
        } /* switch (me->event.response) */

     break;

     /* Get the cross sections */
     case CROSS_CURVES:

        /* start with hangup_method if cmd was gone to sleep there */
        if (me->sleep_in_hangup)
           goto come_back;

        /* delete previous trace curve coord_system */
        if ( !me->wrk.loc_coord                               /* there is a coord_system */
             && me->num_cross == 0) 
        {
           struct     IGRdisplay arrow_display;
           IGRpoint   ptt;
           IGRvector  vcc;

           for (i=0; i<3; i++)
           {
              OM_BLOCK_MOVE(&me->wrk.coords.display, &arrow_display, sizeof (struct IGRdisplay) );
              if (i==0)
              {
                 arrow_display.weight = me->wrk.coords.display.weight + 2;
                 OM_BLOCK_MOVE(&me->wrk.coords.csys[9], &ptt, sizeof(IGRpoint) );
              }
              else
                 arrow_display.weight = me->wrk.coords.display.weight;
      
              OM_BLOCK_MOVE(&me->wrk.coords.csys[i*3], &vcc, sizeof(IGRvector) );
              EFdraw_vector_on_screen (my_id, &arrow_display, &me->construct_env,
                                       GRbe, FALSE, ptt, vcc, me->wrk.coords.range, &msg);
           }
        me->wrk.loc_coord = TRUE;          /* we do need a new coord_system */
        }

        /* disable or enable angle switch */
        sts = om$send(msg = message ECconstruct.update_status_form(),
                 targetid = my_id);
         ON_ERROR goto kill_command;

        event_mask = GRm_DATA | GRm_BACK_UP;
        if  (me->num_cross == 0) 
         key = EMS_P_SelScCurve  ;           /* Select cross section curve*/
        else
         {
          event_mask |= GRm_RJT_MOVEON;
          key =  EMS_P_IdntScMvOn;          /* Identify section curve/Moveon */
         }
        ex$message( msgnumb = key, buff = prompt)

        /* sets up locate info - only planar curves are allowed */
        EFget_locate_information( BIG_CURVE, &loc_info);
        loc_info.identify_event_type = good_data;
        loc_info.accept_event_type = dummy;
        loc_info.planar_flag =  LC_PLANAR_ONLY;
        loc_info.allow_duplicate_objects = TRUE;
  
        loc_info.eligible_classes.w_count = 1;
        loc_info.e_classes[0] = OPP_GRcurve_class_id;
        loc_info.eligible_classes.p_classes = loc_info.e_classes;

        loc_info.rtree_classes.w_count = 1;
        loc_info.r_classes[0] = OPP_GRbspline_class_id;
        loc_info.rtree_classes.p_classes = loc_info.r_classes;

        sts = om$send( msg = message ECconstruct.locate_object(
                                          event_mask,
                                          prompt,
                                          LC_NO_MSG,       /* No locate key, use string */
                                          &loc_info,
                                          TRUE,            /* Put accept event on queue */
                                          &put_on_queue,   /* Is possible to put accept event on queue? */
                                          response,
                                          response_data),
                  targetid = my_id);
         ON_ERROR goto kill_command;
        if (me->locate_stack.num_entries) return(OM_S_SUCCESS);

        switch (me->event.response)
        {
          case GR_UNKNOWN_TYPE:
             return(OM_S_SUCCESS);

          case EX_BACK_UP:
             sts = om$send( msg = message ECconstruct.backup_event(),
                       targetid = my_id);
             ON_ERROR goto kill_command;
             if (me->num_cross == 0)
             {
                /* switch to selected definition of trace curve coordinate system */
                if (me->coordsys_case == 1 )
                   me->state = PARALLEL_TO_PLANE;
                else if (me->coordsys_case == 2 )
                   me->state = VEC_DIRECTION;
                else if (me->coordsys_case == 3 )
                   me->state = SURFACE_NORMAL;
             }
             else
             {
                me->num_cross--;
                lc_info = &me->crsobj[me->num_cross];
                is_curve_reversed = lc_info->geom_parms.polygon_inx;
                /************************************************************************
                EFdisplay_curve_normal_or_tangent:
                                     lc_info,	The curve 
                                     NULL,	Not used for tangents 
                                     FALSE,	Display the tangent vector
                                     GRbe,	Erase
                *************************************************************************/
                sts = ems$display_curve_normal_or_tangent(
                                              loc_info = lc_info,
                                display_normal_tangent = FALSE,
                                        reverse_vector = is_curve_reversed,
                                              senderid = my_id,
                                             draw_mode = GRbe,
                                         display_mdenv = &me->display_env,
                                               display = &me->display,
                                                   msg = &msg);
                ON_ERROR goto kill_command;

                /* resort all cross-sections dependent on parameter value of trace position */
                for (i=0; i<me->num_cross;i++)
                {
                   if (me->ascend_pos[i] == me->num_cross)
                      break;
                }

                for (j=i; j<me->num_cross;j++)
                   me->ascend_pos[j] = me->ascend_pos[j+1];

                gr$delete_object (msg = &msg, object_id = &me->crspic[me->num_cross]);
                if (!(1&msg)) goto kill_command;
             }  /* end if num_cross=0 */
             break;

        case EX_RJT_MOVEON:
           /* check for only one cross_section at parameter 1.0 */
           if (me->num_cross == 1 && me->crsloc[0] == 1.0)
           {
              ex$message(msgnumb = EMS_S_WrongLocAtTrSngCs);     /* Wrong location at trace for single cross section */
           }
           else
           {
              sts = om$send( msg = message ECconstruct.add_event( FALSE),    /* Not a located object */
                        targetid = my_id);
              ON_ERROR goto kill_command;
              me->state = PROCESS;
           }
           break;

        default:                  /* Object was located */
        {
           IGRboolean	has_plane = TRUE;
           IGRboolean	backup = TRUE;
           IGRlong	current_size, current_sx, current_sy, current_sz, current_si;
           int          event_response = NULL;

           sts = om$send( msg = message ECconstruct.add_event( TRUE),   /* It is a located object */
                     targetid = my_id);
            ON_ERROR goto kill_command;
           current_size = om$dimension_of(varray = me->crsobj);
           current_sx = om$dimension_of(varray = me->crsloc);
           current_sy = om$dimension_of(varray = me->crsopt);
           current_si = om$dimension_of(varray = me->crspic);
           current_sz = om$dimension_of(varray = me->ascend_pos);
           if (me->num_cross == current_size)
           {
              sts = om$vla_set_dimension( varray = me->crsobj, size = current_size + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->crsopt, size = current_sy + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->crsloc, size = current_sx + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->trcloc, size = current_size + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->crsang, size = current_sx + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->crspic, size = current_si + 10);
               ON_ERROR goto kill_command;
              sts = om$vla_set_dimension( varray = me->ascend_pos, size = current_sz + 10);
               ON_ERROR goto kill_command; 
           }
           sts = EFdetermine_direction( &me->event, my_id, &msg);
            ON_ERROR goto kill_command;

           sts = EFgetprops( &me->event, my_id, &props, &msg);
            ON_ERROR goto kill_command;
           me->crsobj[me->num_cross] = me->event.located_object[0];
           lc_info = &me->crsobj[me->num_cross];
           is_curve_reversed = lc_info->geom_parms.polygon_inx;
           lc_info->geom_parms.leaf_id.objid = props.phy_closed;

           /* Check if one of the cross-sections parents is member of class EMSdatpln */
           sts = om$send( msg = message ECprfsksf.check_ref_plane( TRUE, &me->crsobj[me->num_cross], &has_plane), 
                     targetid = my_id);
            ON_ERROR goto kill_command;

           if (! has_plane)
           {
              if (me->num_cross == 0)
                 key = EMS_S_CurveMustLieOnRefPlane;
              else
                 key = EMS_S_AllCrsOnOneRefPln;
              ex$message( msgnumb = key)
              sts = om$send( msg = message ECconstruct.backup_event(),
                        targetid = my_id);
               ON_ERROR goto kill_command;
              break;
           }
           lc_info = &me->crsobj[me->num_cross];
           is_curve_reversed = lc_info->geom_parms.polygon_inx;
           /**************************************************************************
           EFdisplay_curve_normal_or_tangent:
                                    lc_info,	The curve 
                                    NULL,	Not used for tangents 
                                    FALSE,	Display the tangent vector 
                                    GRbd,	Draw background 
           ***************************************************************************/
           sts = ems$display_curve_normal_or_tangent(
                                     loc_info = lc_info,
                       display_normal_tangent = FALSE,
                               reverse_vector = is_curve_reversed,
                                     senderid = my_id,
                                    draw_mode = GRbd,
                                display_mdenv = &me->display_env,
                                      display = &me->display,
                                          msg = &msg);
            ON_ERROR goto kill_command;
come_back:
           /* Hang up cross-section at trace */
           sts = om$send( msg = message ECprfsksf.hang_up_section( &backup, &event_response,
                                                                     response, response_data), 
                     targetid = my_id);
            ON_ERROR goto kill_command;

           me->sleep_in_hangup = FALSE;
           if (event_response == GR_UNKNOWN_TYPE)
           {
              /* save tmp_crv id to delete it later on */
              OM_BLOCK_MOVE(&me->wrk.tmp_crv, &me->crspic[me->num_cross], sizeof(struct GRid) );
              me->sleep_in_hangup = TRUE;
              return (OM_S_SUCCESS);
           }

           if (! backup)
           {
              sts = om$send( msg = message ECconstruct.backup_event(),
                        targetid = my_id);
               ON_ERROR goto kill_command;

              lc_info = &me->crsobj[me->num_cross];
              is_curve_reversed = lc_info->geom_parms.polygon_inx;
              sts = ems$display_curve_normal_or_tangent(
                                              loc_info = lc_info,
                                display_normal_tangent = FALSE,
                                        reverse_vector = is_curve_reversed,
                                              senderid = my_id,
                                             draw_mode = GRbe,
                                         display_mdenv = &me->display_env,
                                               display = &me->display,
                                                   msg = &msg);
               ON_ERROR goto kill_command;

              /* delete trace curve coord_system */
              if ( !me->wrk.loc_coord && me->num_cross == 0)
              {
                 struct     IGRdisplay arrow_display;
                 IGRpoint   ptt;
                 IGRvector  vcc;

                 OM_BLOCK_MOVE(&me->wrk.coords.display, &arrow_display, sizeof (struct IGRdisplay) );
                 for (i=0; i<3; i++)
                 {
                    if (i==0)
                    {
                       arrow_display.weight = me->wrk.coords.display.weight + 2;
                       OM_BLOCK_MOVE(&me->wrk.coords.csys[9], &ptt, sizeof(IGRpoint) );
                    }
                    else
                       arrow_display.weight = me->wrk.coords.display.weight;

                    OM_BLOCK_MOVE(&me->wrk.coords.csys[i*3], &vcc, sizeof(IGRvector) );
                    EFdraw_vector_on_screen (my_id, &arrow_display, &me->display_env,
                                             GRbe, FALSE, ptt, vcc, me->wrk.coords.range, &msg);
                 }
              me->wrk.loc_coord = TRUE;          /* we do need a new coord_system */
              } /* end of delete trace curve coord_system */
           }
           else
           {
              /* handle special case: trace = closed && parameter 0.0 || 1.0 */
              if (me->traces_are_closed && (me->crsloc[me->num_cross] == 0.0 ||
                                            me->crsloc[me->num_cross] == 1.0) )
              {
                 if (me->num_cross == 0)
                    /* we assume user wants to have cross_section at start of surface*/
                    me->crsloc[me->num_cross] = 0.0;
                 else
                    me->crsloc[me->num_cross] = 1.0;
              }

              /* sort all cross-sections dependent on parameter value of trace position */
              for (i=0;i<me->num_cross;i++)
              {
                 if (me->crsloc[me->ascend_pos[i]] > me->crsloc[me->num_cross])
                    break;
              }
              for (j=me->num_cross;j>i;j--)
              {
                 me->ascend_pos[j] = me->ascend_pos[j-1];
              }
              if (me->num_cross == 0)
                 me->ascend_pos[0] = 0;
              else
                 me->ascend_pos[i] = me->num_cross;

              /* save tmp_crv id to delete it later on */
              OM_BLOCK_MOVE(&me->wrk.tmp_crv, &me->crspic[me->num_cross], sizeof(struct GRid) );

              me->num_cross++;
           }
         }
         break;
       } /* switch (me->event.response) */
       break;

     case PROCESS:
        /*may be the form should not be erased at this point*/
        if (me->form_requested)
        {
           me->form_requested = FALSE;
           FIf_erase(me->form1);
        } /* if (me->form_requested) */

        /* Unhighlight all the geometry */
        ex$message(msgnumb = EMS_P_00000)
        ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
        pos = EX_suspend;
        sts = om$send( msg = message super_cmd.sleep( pos),
                  targetid = my_id);
         ON_ERROR goto kill_command;

        /* Turn associative button on again (sleep changed it) */
        if (me->associative)
           GRdisplay_associative_button(TRUE);

        /* Get the construct list */
        sts = om$send( msg = message ECconstruct.load_construction_information(),
                  targetid = my_id);
         ON_ERROR goto kill_command;
        ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ")
/*
 * Finally let's do something
 */
      {
       IGRboolean	construction_failed;

       construction_failed = FALSE;

       /* Added for associativity */
       {
         IGRint cssurf_size;
         IGRint tot_num = 0;
         IGRint cnt = 0;
         IGRchar *char_info = NULL;
         struct EMScross_section_surface *cssurf = NULL;
         struct EMSobject_info *list_ptr = NULL;

         cssurf_size = sizeof (struct EMScross_section_surface) + 
                       (me->num_cross + me->num_trace) * sizeof(char)+
                       (me->num_cross) * sizeof (IGRpoint) +
                       (me->num_cross) * sizeof (IGRdouble) +
                       sizeof (struct GRlc_info);

         cssurf = (struct EMScross_section_surface *)stackalloc(cssurf_size);
         if (!cssurf) 
         {
          msg = MANOMEMORY;
          goto kill_command;
         }
         cssurf->number_of_sections = me->num_cross;
         cssurf->number_of_trace_curves = me->num_trace;
         OM_BLOCK_MOVE (&me->wrk.refpln,&cssurf->refpln,(sizeof (double) * 12) );
         OM_BLOCK_MOVE (&me->wrk.parpln,&cssurf->dirvec,(sizeof (double) * 3) );
         cssurf->mirror_case = me->wrk.mirror_case;
         cssurf->att_method_props = 0;
         cssurf->gen_type_props = 0;
         cssurf->cross_surf_props = 0;
 
         if (me->coordsys_case == 1)
            cssurf->att_method_props |= EMS_FIRST_ATTCH;
         else if (me->coordsys_case == 2)
            cssurf->att_method_props |= EMS_SECOND_ATTCH;
         else
            cssurf->att_method_props |= EMS_FOURTH_ATTCH;

         cssurf->gen_type_props |= EMS_CREA_CURV;

         if (me->smooth)
            cssurf->cross_surf_props |= EMS_IS_CROSS_SEC_REPARAM;

         cssurf->cross_surf_props |= EMS_IS_BLEND_TYPE_PARAMETER;

         tot_num += (me->num_cross * 2) + me->num_trace; 

         list_ptr = (struct EMSobject_info *) stackalloc
                (sizeof (struct EMSobject_info) * tot_num);
         if (!list_ptr)
         {
            msg = MANOMEMORY;
            if (cssurf) stackfree(cssurf); 
            cssurf = NULL;
            goto kill_command;
         }

         char_info =  cssurf->chardata;

         for (i=0;i<me->num_cross;i++,cnt++)
         {
            list_ptr[cnt].grid = me->trcloc[me->ascend_pos[i]].located_obj;
            list_ptr[cnt].env = me->trcloc[me->ascend_pos[i]].module_info;
         }

         for (i=0;i<me->num_cross;i++,cnt++)
         {
            list_ptr[cnt].grid = me->crsobj[me->ascend_pos[i]].located_obj;
            list_ptr[cnt].env = me->crsobj[me->ascend_pos[i]].module_info;
            if (me->crsobj[me->ascend_pos[i]].geom_parms.polygon_inx)
               *char_info = 1;
            else
               *char_info = 0;
            ++char_info;
         }

         for (i=0;i<me->num_trace;i++,cnt++)
         {
            list_ptr[cnt].grid = me->trcobj[i].located_obj;
            list_ptr[cnt].env = me->trcobj[i].module_info;
            if (me->trcobj[i].geom_parms.polygon_inx)
               *char_info = 1;
            else
            {
               *char_info = 0;
            }
            ++char_info;
         }

         /* add not assoc data to char_info */
         for (i=0;i<me->num_cross;i++)
         {
            OM_BLOCK_MOVE ((char *)&me->crsopt[me->ascend_pos[i]], char_info,
                          sizeof(IGRpoint) );
            char_info = char_info + sizeof(IGRpoint);
         }

         for (i=0;i<me->num_cross;i++)
         {
            OM_BLOCK_MOVE ((char *)&me->crsang[me->ascend_pos[i]], char_info,
                          sizeof(IGRdouble) );
            char_info = char_info + sizeof(IGRdouble);
         }

         if (me->coordsys_case == 3)
         {
            OM_BLOCK_MOVE ((char *)&me->orient_surface, char_info,
                          sizeof(struct GRlc_info) );
         }

         sts = ems$associative_element_by_function ( msg = &msg,
                                             associative = me->associative,
                                             num_parents = tot_num,
                                                 parents = list_ptr,
                                               info_size = cssurf_size,
                                                    info = (IGRchar *)cssurf,
                                           function_name = "EFCsecSurf",
                                          construct_list = &me->construct_list,
                                              created_id = &me->constructed_object);
         if (cssurf) 
         {
          stackfree(cssurf);
          cssurf = NULL;
         }
       } /* ends associative processing */
         

       if (!(1 & sts))
        construction_failed = TRUE;

       me->have_a_constructed_object = TRUE;

       if (construction_failed)
        {
         me->constructed_object = NULL_OBJID;
         ex$message(msgnumb = EMS_I_00002)
        }
       else
        {

         enum	GRdpmode DisplayMode;

         ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ")
         DisplayMode = GRbd;
         sts = om$send( msg = message ECconstruct.display_constructed_object(DisplayMode),
                   targetid = my_id);
          ON_ERROR goto kill_command;
         ex$message(msgnumb = EMS_I_00000)
        }

        /* Clear my memory for a fresh start */
        me->state = previous_state + 1;  /* see backup_event() and last_state_to_first_state() */
        sts = om$send( msg = message ECconstruct.last_state_to_first_state(),
                  targetid = my_id);
         ON_ERROR goto kill_command;
       }
      break;

     /* Something has messed up our state table */
     default:
      goto kill_command;
    }
 }
 while(TRUE);

/* Kill the command */
kill_command:
 CMD_KILL
}

method display_constructions( IGRboolean draw_background; IGRboolean draw_single)
{
 enum		GRdpmode mode;   
 IGRboolean	is_curve_reversed;
 IGRlong	i, sts;
 struct		GRlc_info *lc_info;

 /* Initialize */
 me->msg = MSSUCC;
 if (draw_single) return(OM_S_SUCCESS);

 /* Draw the vectors */
 mode = (draw_background ? GRbd : GRbe);
 for (i = 0; i < me->num_trace; i++)
 {
   lc_info = &me->trcobj[i];
   is_curve_reversed = lc_info->geom_parms.polygon_inx;
    
   sts = ems$display_curve_normal_or_tangent(
                               loc_info = lc_info,
                 display_normal_tangent = FALSE,
                         reverse_vector = is_curve_reversed,
                               senderid = my_id,
                              draw_mode = mode,
                          display_mdenv = &me->display_env,
                                display = &me->display,
                                    msg = &me->msg);
    ON_ERROR return(sts);
 } /* for (i = 0; i < me->num_trace; i++) */

 for (i = 0; i < me->num_cross; i++)
 {
   lc_info = &me->crsobj[i];
   is_curve_reversed = lc_info->geom_parms.polygon_inx;
/***************************************************************************
   EFdisplay_curve_normal_or_tangent:
                    lc_info,		The curve 
                    NULL,		Not used for tangents 
                    FALSE,		Display the tangent vector 
******************************************************************************/
   sts = ems$display_curve_normal_or_tangent(
                               loc_info = lc_info,
                 display_normal_tangent = FALSE,
                         reverse_vector = is_curve_reversed,
                               senderid = my_id,
                              draw_mode = mode,
                          display_mdenv = &me->display_env,
                                display = &me->display,
                                    msg = &me->msg); 
    ON_ERROR return(sts);
 } /* for (i = 0; i < me->num_cross; i++) */

 /* eof */
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */

method update_status_form()
{
  FIfld_set_list_select (me->form1, CSOp_COORDS_FLD, me->coordsys_case - 1, 0, TRUE);
  FIg_display (me->form1,CSOp_SMOOTH_TGL);
  /*
  FIg_display (me->form1,CSOp_TANGENCY_TGL);
  */
  FIg_display (me->form1,CSOp_POINT_TGL);
  FIg_display (me->form1,CSOp_ANGLE_TGL);
  FIg_display (me->form1,CSOp_COORDS_FLD);
  FIg_display (me->form1,CSOp_STEP_FLD);
 
  if (me->smooth == 0)
     FIg_set_state_on (me->form1, CSOp_SMOOTH_TGL);
  else if (me->smooth == 1)
     FIg_set_state_off (me->form1, CSOp_SMOOTH_TGL);

  /*
  if (me->tan_constrnt == 1)
     FIg_set_state_on (me->form1, CSOp_TANGENCY_TGL);
  else if (me->tan_constrnt == 0)
     FIg_set_state_off (me->form1, CSOp_TANGENCY_TGL);
  */

  if (me->select_screen_pos == 0)
     FIg_set_state_on (me->form1, CSOp_POINT_TGL);
  else if (me->select_screen_pos == 1)
     FIg_set_state_off (me->form1, CSOp_POINT_TGL);

  if (me->angle_constant == 0)
     FIg_set_state_on (me->form1, CSOp_ANGLE_TGL);
  else if (me->angle_constant == 1)
     FIg_set_state_off (me->form1, CSOp_ANGLE_TGL);

  if (me->state != TRACE_CURVES)
     FIg_disable(me->form1,  CSOp_COORDS_FLD);
  else
     FIg_enable (me->form1,  CSOp_COORDS_FLD);
  
  if (me->state == CROSS_CURVES && me->num_cross > 0)
     FIg_disable(me->form1,  CSOp_ANGLE_TGL);
  else
     FIg_enable (me->form1,  CSOp_ANGLE_TGL);

 return(OM_S_SUCCESS);
}

method status_disp()

{
  IGRlong status, EMmsg;
  int display_status, ret;

  status = OM_S_SUCCESS;
  EMmsg = 1;

   status = om$send(msg = message ECconstruct.update_status_form(),
               targetid = my_id);

   FIf_is_displayed( me->form1, &display_status );
   if ( ! display_status )
   {
       ret = FIf_display(me->form1);
       if (ret) { status = FALSE; goto wrapup; }
       me->form_requested = TRUE;
   }
     
wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}

IGRint ECprfsksf_process_form (form_label, gadget_label, value, form_ptr)
IGRint form_label;
IGRint  gadget_label;
IGRdouble value;
Form form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func != FI_SUCCESS)
     return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECprfsksf.do_form (&msg_loc, form_label,
                     gadget_label, value, form_ptr),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if (!(stat_OM & 1))
    return (OM_E_ABORT);

return (stat_OM);
}


/*
NAME
        do_form

DESCRIPTION
        Notification method of cross-section surface options forms,
        which is invoked from function ECprfsksf_process_form.
NOTES
        It is important that this method not modify the variable
        me->msg as this screws up the locate filter.  In general,
        this method should be extremely careful about modifying
        any instance data.
HISTORY
        02/18/93    Ralf Burkhart
*/

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value; Form fp)
{
  IGRboolean	update_form;

  /* Initialize */
  update_form = TRUE;
  value = value;

 /* Branch based on the form label which was affected. */

  switch ( form_label )
  {
    case CS_OPTIONS_FORM:
       switch ( gadget_label )
       {
         case FI_CVT_TO_PERM_WIN:
            FIf_cvrt_to_perm_win ( fp );
            break;

         case FI_ACCEPT:
            update_form = FALSE;
            FIg_set_state_off (fp, gadget_label);
            me->form_requested = FALSE;
            FIf_erase(fp);
            GRstatus_display_button(1);
            break;

         case CSOp_STEP_FLD:
            FIg_get_value (fp, CSOp_STEP_FLD, &me->wrk.dyn_step);
            break;
 
         case CSOp_SMOOTH_TGL:
            GS_smooth = me->smooth = (me->smooth ? FALSE : TRUE);
            if (me->smooth == 0){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->smooth == 1){
               FIg_set_state_on (fp, gadget_label);
               }
            break;

         /*
         case CSOp_TANGENCY_TGL:
            GS_tansf = me->tan_constrnt = (me->tan_constrnt ? FALSE : TRUE);
            if (me->tan_constrnt == 1){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->tan_constrnt == 0){
               FIg_set_state_on (fp, gadget_label);
               }
            break;
          */

         case CSOp_POINT_TGL:
            GS_point = me->select_screen_pos = (me->select_screen_pos ? FALSE : TRUE);
            if (me->select_screen_pos == 1){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->select_screen_pos == 0){
              FIg_set_state_on (fp, gadget_label);
              }
            break;

         case CSOp_ANGLE_TGL:
            GS_angle = me->angle_constant = (me->angle_constant ? FALSE : TRUE);
            if (me->angle_constant == 1){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->angle_constant == 0){
              FIg_set_state_on (fp, gadget_label);
              }
            break;

         case CSOp_COORDS_FLD:
         {
          IGRint	i, sel_flag;
          IGRboolean    no_case;

          no_case = TRUE;
          for (i=0; (i < 3) && no_case; i++)
          {
             FIfld_get_list_select (fp, gadget_label, i, 0, &sel_flag);
             if (sel_flag)
             {
                no_case = FALSE;
                GS_coords = me->coordsys_case = i+1;
             }
          } /* end for */
         }
         FIfld_set_list_select (fp, gadget_label, me->coordsys_case - 1, 0, TRUE);
         break;

         default:
            update_form = FALSE;
            break;

       } /* END switch ( gadget_label ) */
       break;
  } /* END switch ( form_label ) */

  /* Update the form, if required */
  if (update_form)
  {
     om$send( msg = message ECconstruct.update_status_form(),
         targetid = my_id);
   }

   return(OM_S_SUCCESS);
} 

method create_form (int form_label;
                    char *form_name; Form *form)
{
        int status;
        IGRint ECprfsksf_process_form();

        status = FIf_new(form_label, form_name, ECprfsksf_process_form, form);
        if (status != FI_SUCCESS)
        {
                return(OM_E_ABORT);
        }
        status = FIf_set_cmd_oid_os(*form, my_id, OM_Gw_current_OS);
        if (status != FI_SUCCESS)
        {
                return(OM_E_ABORT);
        }
        return(OM_S_SUCCESS);
}

method is_associative(IGRint type; IGRlong *associative)
{
 IGRlong    EMmsg;
 IGRboolean state;

 EMmsg = 1;

 gr$get_associative_flag( buffer = &state );

 if (state)
  *associative = TRUE;
 else
  *associative = FALSE;
 return(OM_S_SUCCESS); 
}

method init(int type; char *str_ptr)
{
   IGRint status;
   int form_mask;

   status = OM_S_SUCCESS;

   /* let the parents work */
   status = om$send( msg = message ECconstruct.init(type, str_ptr),
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

   /* initialisation of option form */
   status =  om$send( msg = message ECprfsksf.create_form(CS_OPTIONS_FORM,
                                                  "EMPlCrossSec",&me->form1),
              targetid = my_id);
    if(!(1&status)){goto wrapup;}
   FIf_set_location (me->form1, 0, 125);

   /* set save_restore bit of form */
   FIf_get_attr(me->form1,&form_mask);
   form_mask |= FI_SAVE_RESTORE;
   FIf_set_attr(me->form1,form_mask);
   
   /* don't display tangency text */
   FIg_erase (me->form1,CSOp_TANGENCY_TXT);

   /* set special start values of the command */
   me->sleep_in_hangup = FALSE;
   me->wrk.loc_coord = TRUE;    /* we do need one*/
   me->wrk.repaint = FALSE;    /* do not draw coordsys first time in wakeup */
   me->wrk.dyn_step = 1.0;
   me->absolute_orientation = FALSE;
   me->num_cross = 0;

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status); 
}

method sleep(int pos)
{
   IGRint status, i;
   IGRlong msg;

   status = OM_S_SUCCESS;

   /* let the parents work */
   status = om$send( msg = message ECconstruct.sleep(pos),
                senderid = NULL_OBJID,
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

   /* delete trace curve coord_system */
   if ( !me->wrk.loc_coord)                               /* there is a coord_system */
   {
      struct     IGRdisplay arrow_display;
      IGRpoint   ptt;
      IGRvector  vcc;

      OM_BLOCK_MOVE(&me->wrk.coords.display, &arrow_display, sizeof (struct IGRdisplay) );
      for (i=0; i<3; i++)
      {
         if (i==0)
         {
            arrow_display.weight = me->wrk.coords.display.weight + 2;
            OM_BLOCK_MOVE(&me->wrk.coords.csys[9], &ptt, sizeof(IGRpoint) );
         }
         else
            arrow_display.weight = me->wrk.coords.display.weight;

         OM_BLOCK_MOVE(&me->wrk.coords.csys[i*3], &vcc, sizeof(IGRvector) );
         EFdraw_vector_on_screen (my_id, &arrow_display, &me->display_env,
                                  GRbe, FALSE, ptt, vcc, me->wrk.coords.range, &msg);
      }
   me->wrk.repaint = TRUE;
   me->wrk.loc_coord = TRUE;          /* we do need a new coord_system */
   }

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status);
}

method wakeup(int pos)
{
   IGRint sel, num_char;
   IGRint status, i;
   IGRlong msg;

   status = OM_S_SUCCESS;

   /* let the parents work */
   status = om$send( msg = message ECconstruct.wakeup(pos),
                senderid = NULL_OBJID,
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

   /* redisplay trace curve coord_system */
   if ( me->wrk.loc_coord && me->wrk.repaint )    /* we need a coord_system */
   {
      struct     IGRdisplay arrow_display;
      IGRpoint   ptt;
      IGRvector  vcc;

      OM_BLOCK_MOVE(&me->wrk.coords.display, &arrow_display, sizeof (struct IGRdisplay) );
      for (i=0; i<3; i++)
      {
         if (i==0)
         {
            arrow_display.weight = me->wrk.coords.display.weight + 2;
            OM_BLOCK_MOVE(&me->wrk.coords.csys[9], &ptt, sizeof(IGRpoint) );
         }
         else
            arrow_display.weight = me->wrk.coords.display.weight;

         OM_BLOCK_MOVE(&me->wrk.coords.csys[i*3], &vcc, sizeof(IGRvector) );
         EFdraw_vector_on_screen (my_id, &arrow_display, &me->display_env,
                                  GRbd, FALSE, ptt, vcc, me->wrk.coords.range, &msg);
      }
   me->wrk.loc_coord = FALSE;          /* we have a new coord_system */
   }

   me->coordsys_case = GS_coords;
   /* set default text of of CSOp_COORDS_FLD */
   FIfld_get_list_text_length (me->form1, CSOp_COORDS_FLD, me->coordsys_case - 1,
                               0, &num_char);
   FIfld_get_list_text (me->form1, CSOp_COORDS_FLD, me->coordsys_case - 1,
                        0, num_char, me->wrk.coord_default, &sel);
   FIfld_set_default_text (me->form1, CSOp_COORDS_FLD, 0, 0, me->wrk.coord_default, TRUE);

   GRstatus_display_button(1);

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status);
}

method delete(int f_defer_flag)
{
   IGRint status, cross_count, i;
   IGRlong msg;

   status = OM_S_SUCCESS;

   /* delete mapped cross_sections */
   if (me->state <= TRACE_CURVES)
      cross_count = me->previous_cross_count;
   else
      cross_count = me->num_cross;

   for (i=0;i<cross_count;i++)
   {
      gr$delete_object (msg = &msg, object_id = &me->crspic[i]);
       if (!(1&msg)) goto wrapup;
   }

   /* let the parents work */
   status = om$send( msg = message ECconstruct.delete(f_defer_flag),
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status);
}

end implementation ECprfsksf;
