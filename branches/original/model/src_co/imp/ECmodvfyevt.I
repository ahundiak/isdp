/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method determines the validity of an event and the
 termination condition for the following simple commands:

                 Command                      my_type
        ----------------------------------    -------
        Change curve order                      71
        Change surface order                    72
        Increase curve order                    73
        Increase surface order                  74
        Change rule line display                75
        Place solid by capping surface          76
        Toggle polygon on/off                   77
        Insert pole without changing shape      78
        Insert knot                             79
        Extend surface - linear                 80
        Extend surface - circular               81
        Extend surface - polynomial             82
        Delete surface boundaries               86
        Align 2 curves                          87
        Align 2 surfaces                        88
        Bezier curves from a bspline curve      89
        Bezier surfaces from a bspline surface  90
        Insert knotline                         91
                                                --
        Modify curve shape                     106
        Reduce curve data                      107
        Modify surface shape                   108
                                               ---
        Change curve direction                 110
                                               ---
        Reduce surface data                    114

 History

 12/29/87 : rlw : The beginning
 01/05/88 : rlw : Added some commands
 01/14/88 : rlw : Modified such that the capping command checks to
                  ensure that a solid was not located and compress state tree.
 05/23/88 : rlw : Fix a bug whereby I was trying to generate the abstract data
                  of a DPR when deleting surface boundaries.
 07/04/88 : rlw : Added modify curve shape command
 07/08/88 : rlw : Modified default value for reduced fit as per Dieter
                  Added modify surface shape command
 07/20/88 : rlw : Added Change curve direction command
 08/01/88 : rlw : Modified Change rule line display to support fences
                  and also ask for number of rule lines to use.
                  Modified Toggle polygon to support fences.
 08/05/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
                  Added surface data reduction command.
                  Repaired modify surface shape.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 01/12/92 : AMD : Capping being associative, we do not need to do
                  compress tree anymore
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation ECmodify;


#include <math.h>
#include "EMS.h"
#include "ems_m_inc.h"                /* Includes everything */
#include "EC_I.h"                /* Message keys for informational strings */
#include "grmsg.h"
#include "bssfkttol2.h"
#include "bscvkttol2.h"

from GRcurve import GRendpoint, GRendpts;
from GRgraphics import GRdisplay;

from EMSdpr import EMmake_primitive1;

extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_SKgeometry_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_GRbcsubbc_class_id;

method verify_event(
IGRboolean        use_default;
IGRboolean        *was_valid_event;
IGRboolean        *done)

{
  IGRlong        key, sts, *my_msg, my_type;
  struct                GRevent *event;
  struct                IGRbsp_curve *curve;
  struct                IGRbsp_surface *surface;

  /*
   * Compiler optimizations
   */
  my_msg = &me->msg;
  my_type = me->mytype;
  /*
   * Initialize
   */
  *my_msg = MSSUCC;
  *done = FALSE;
  key = EMS_I_00001;
  *was_valid_event = TRUE;
  event = &me->events[me->number_of_events_input - 1];
  /*
   * If this is one of the commands that gets an object as
   * the first action then generate it's abstract data
   * so that we can use it for verification purposes.
   */
  switch (my_type)
  {
  case 75:
  case 76:
  case 77:
  case 87:
  case 86:
  case 88:
  case 107:
    /*  noop; */
    break;
  default:
    {
      IGRchar        *geometry;

      sts = EFgetabstract(
          &me->events[0],
          my_id,
          &geometry,
          my_msg);
      if (! (1 & sts)) goto wrapup;
      curve = (struct IGRbsp_curve *) geometry;
      surface = (struct IGRbsp_surface *) geometry;
    }
    break;
  } /* switch (my_type) */
  /*
   * Branch based on the command state
   */
  switch (me->number_of_events_input)
  {
    /*
     * Event 1 verification
     */
  case 1:
    switch (my_type)
    {
    case 71:
      if (me->u_order > curve->num_poles)
      {
        *was_valid_event = FALSE;
        key = EMS_I_00030;
      }
      else
        *done = TRUE;
      break;
    case 72:
      if ((me->u_order > surface->u_num_poles) ||
          (me->v_order > surface->v_num_poles))
      {
        *was_valid_event = FALSE;
        key = EMS_I_00030;
      }
      else
        *done = TRUE;
      break;
    case 73:
      if (me->u_order < curve->order)
      {
        *was_valid_event = FALSE;
        key = EMS_I_00031;
      }
      else
        *done = TRUE;
      break;
    case 74:
      if ((me->u_order < surface->u_order) ||
          (me->v_order < surface->v_order))
      {
        *was_valid_event = FALSE;
        key = EMS_I_00031;
      }
      else
        *done = TRUE;
      break;
    case 77:
      /* check ancestry for profile or profile component */
      *done = TRUE;
      {
        OMuword          classid;
        struct GRid      dp_grid;
        struct GRid     *id;
        int              unhighlight = FALSE;

        id = &event->located_object[0].located_obj;
        sts = om$get_classid( objid = id->objid,
            osnum = id->osnum,
            p_classid = &classid);
        if (! (1 & sts))
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
        sts = om$is_ancestry_valid( subclassid = classid,
                                    superclassid = OPP_SKmgr_class_id);
        if (sts == 1)
        {
          *was_valid_event = FALSE;
          key = GR_E_InvEleType;
          *done = FALSE;
          unhighlight = TRUE;
        }
        else
        {
          if (om$is_ancestry_valid( subclassid = classid, 
              superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS &&
              om$is_ancestry_valid ( subclassid = classid,
              superclassid = OPP_GRbcsubbc_class_id) != OM_S_SUCCESS)
          {
            *was_valid_event = FALSE;
            key = GR_E_InvEleType;
            *done = FALSE;
            unhighlight = TRUE;
          }
        }
        /* whatever it takes! srh 4/15/92 */
        if (unhighlight)
        {
          dp_grid = event->located_object[0].located_obj;
          dp$display ( msg  = &sts,
              mode =  GRhe,
              oids = &dp_grid );
        }
      }
      break;
    case 86:
    case 89:
    case 90:
      *done = TRUE;
      break;
    case 76:                /* Must be cappable */
      {
        OMuword                classid;
        IGRboolean        not_a_solid;
        struct                GRid *id;
        struct            GRmd_env *md_env;

        id = &event->located_object[0].located_obj;
        md_env = &event->located_object[0].module_info;

        sts = om$get_classid(
            objid = id->objid,
            osnum = id->osnum,
            p_classid = &classid);
        if (! (1 & sts))
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
        sts = om$is_ancestry_valid(
            subclassid = classid,
            superclassid = OPP_EMSsolid_class_id);
        if (! (1 & sts))
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
        not_a_solid = (sts == OM_I_INVANCESTRY);
        if (not_a_solid)
        {
          sts = om$is_ancestry_valid(
              subclassid = classid,
              superclassid = OPP_EMSdpr_class_id);
          if (! (1 & sts))
          {
            *my_msg = MSFAIL;
            goto wrapup;
          }
          *done = TRUE;

          /****************************************************************

  01/12/92 : AMD : Since the command is now associative we do not
                   need to compress the tree.
         --------------------------------------------

          state_tree = (sts == OM_S_SUCCESS);
          if (state_tree)
           {

            sts = om$send(
              msg = message EMSdpr.EMmake_primitive1(
               my_msg,
               md_env,
               id),
              targetid = id->objid,
              targetos = id->osnum);
             if (! (1 & sts))
              {
               *my_msg = MSFAIL;
               goto wrapup;
              }
           } if (state_tree)

***************************************************************/

        } /* if (not_a_solid) */
        else
        {
          enum GRdpmode dpmode;

          *was_valid_event = FALSE;
          key = EMS_I_00011;

          dpmode = GRhe;
          sts = om$send( msg = message GRgraphics.GRdisplay(my_msg,
              &md_env->md_env.matrix_type,
              md_env->md_env.matrix, &dpmode,
              &md_env->md_id),
              targetid = id->objid,
              targetos = id->osnum);
          if (! (1 & sts))
          {
            *my_msg = MSFAIL;
            goto wrapup;
          }
        }
      }
      break;
    case 87:
    case 88:
      {
        IGRlong                number;

        if (use_default)
          number = 0;
        else
          number = event->event.value;
        if ((number < 0) ||
            (number > 3))
        {
          *was_valid_event = FALSE;
          key = EMS_I_00009;
        }
        else
        {
          event->response = EX_VALUE;
          event->event.value = number;
        }
      }
      break;
    case 91:
      event->located_object[0].geom_parms.polygon_inx = TRUE;
      break;
    case 106:
      event->located_object[0].geom_parms.polygon_inx = curve->phy_closed;
      break;
    case 107:
      {
        struct                GRlc_info *loc_info;
        struct                GRid *id;
        struct                GRmdenv_info *mdenv_info;

        loc_info = &event->located_object[0];
        id = &loc_info->located_obj;
        mdenv_info = &loc_info->module_info.md_env;
        sts = om$send(
            msg = message GRcurve.GRendpts(
            my_msg,
            &mdenv_info->matrix_type,
            mdenv_info->matrix,
            loc_info->proj_pnt,                                /* 1st end point */
        &event->located_object[1].proj_pnt[0]),        /* 2nd end point */
        targetid = id->objid,
            targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
      }
      break;
    case 108:
      {
        IGRlong                loc_msg;
        struct                GRparms *parms;

        parms = &event->located_object[0].geom_parms;
        parms->polygon_inx = 0;
        if (surface->u_phy_closed) parms->polygon_inx |= 1;
        if (surface->v_phy_closed) parms->polygon_inx |= 2;
        BSsfkttol2(
            surface->u_order,
            surface->v_order,
            surface->u_knots,
            surface->v_knots,
            surface->u_num_poles,
            surface->v_num_poles,
            surface->poles,
            surface->weights,
            &parms->u,
            &loc_msg);
        if (loc_msg != BSSUCC)
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
      }
      break;
    case 110:
      event->located_object[0].geom_parms.polygon_inx = FALSE;
      break;
    case 114:
      {
        struct                GRparms *parms;

        parms = &event->located_object[0].geom_parms;
        parms->u = surface->u_knots[surface->u_order - 1];
        parms->v = surface->v_knots[surface->v_order - 1];
        parms = &event->located_object[1].geom_parms;
        parms->u = surface->u_knots[surface->u_num_poles];
        parms->v = surface->v_knots[surface->v_num_poles];
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 2 verification
     */
  case 2:
    switch (my_type)
    {
    case 75:
      {
        IGRlong                number;

        if (use_default)
          number = me->surface_element_specific.u_rules;
        else
          number = event->event.value;
        if ((number < 0) ||
            (number > 255))
        {
          *was_valid_event = FALSE;
          key = EMS_I_00009;
        }
        else
        {
          event->response = EX_VALUE;
          event->event.value = number;
        }
      }
      break;
    case 78:
      *done = TRUE;
      break;
    case 79:
    case 91:
    case 106:
    case 108:
      sts = EFpoint_on_object(
          &me->events[0].located_object[0],
          event,
          my_id,
          my_msg);
      break;
    case 80:
    case 81:
    case 82:
      sts = EFfind_closest_side(
          &me->events[0].located_object[0],
          event,
          my_id,
          my_msg);
      break;
    case 107:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      break;
    case 110:
      if (! curve->phy_closed)
        *done = TRUE;
      else if (event->response != EX_DATA)        /* Toggle direction? */
      {
        me->number_of_events_input--;
        sts = EFpatch_the_display_for_normals(
            &me->events[0],
            my_id);
        if (! (1 & sts)) goto wrapup;
        me->number_of_events_input++;
      }
      break;
    case 114:
      if (event->response == EX_RJT_MOVEON)
      {
        IGRlong        i;

        me->event.subtype = GRst_DEFAULT;
        me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
        for (i = 0; i < 2; i++)
        {
          sts = om$send(
              msg = message ECconstruct.add_event(FALSE),
              targetid = my_id);
        } /* for (i = 0; i < 2; i++) */
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 3 verification
     */
  case 3:
    switch (my_type)
    {
    case 75:
      {
        IGRlong                number;

        if (use_default)
          number = me->surface_element_specific.v_rules;
        else
          number = event->event.value;
        if ((number < 0) ||
            (number > 255))
        {
          *was_valid_event = FALSE;
          key = EMS_I_00009;
        }
        else
        {
          *done = TRUE;
          event->response = EX_VALUE;
          event->event.value = number;
        }
      }
      break;
    case 79:
      {
        IGRlong                number;

        if (use_default)
          number = 1;
        else
          number = event->event.value;
        if ((number < 1) ||
            (number > (curve->order - 1)))
        {
          *was_valid_event = FALSE;
          key = EMS_I_00009;
        }
        else
        {
          *done = TRUE;
          event->response = EX_VALUE;
          event->event.value = number;
        }
      }
      break;
    case 80:
    case 81:
    case 82:
      *done = TRUE;
      break;
    case 87:
      {
        IGRboolean        status, EFboreline();
        IGRpoint        point1, point2;
        struct                IGRline bore_line;
        struct                GRlc_info *lc_info;
        struct                GRid *id;
        struct                GRmdenv_info *mdenv_info;

        bore_line.point1 = &point1[0];
        bore_line.point2 = &point2[0];
        status = EFboreline(
            my_msg, 
            my_id, 
            event,
            &bore_line);
        if (! status) goto wrapup;
        lc_info = &me->events[1].located_object[0];
        id = &lc_info->located_obj;
        mdenv_info = &lc_info->module_info.md_env;
        sts = om$send(
            msg = message GRcurve.GRendpoint(
            my_msg,
            &mdenv_info->matrix_type,
            mdenv_info->matrix,
            &bore_line,
            &event->event.button.x),
            targetid = id->objid,
            targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
      }
      break;
    case 88:
      sts = EFfind_closest_side(
          &me->events[1].located_object[0],
          event,
          my_id,
          my_msg);
      break;
    case 91:
      if (event->response != EX_DATA)                /* Toggle direction? */
      {
        me->number_of_events_input--;
        sts = EFpatch_the_display_for_normals(
            &me->events[0],
            my_id);
        if (! (1 & sts)) goto wrapup;
        me->number_of_events_input++;
      }
      break;
    case 107:
    case 114:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
        if (*was_valid_event)
        {
          if (my_type == 107)
            *done = TRUE;
          else if (surface->u_phy_closed)  /* my_type must be 114 */
          {
            me->event.subtype = GRst_DEFAULT;
            me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
            sts = om$send(
                msg = message ECconstruct.add_event(FALSE),
                targetid = my_id);
          }
        } /* if (*was_valid_event) */
      }
      break;
    case 110:
      if (event->response == EX_DATA)
      {
        sts = EFpoint_on_object(
            &me->events[0].located_object[0],
            event,
            my_id,
            my_msg);
        if (! (1 & sts)) goto wrapup;
      }
      *done = TRUE;
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 4 verification
     */
  case 4:
    switch (my_type)
    {
    case 91:
      {
        IGRlong                number, order;

        if (use_default)
          number = 1;
        else
          number = event->event.value;
        if (me->events[0].located_object[0].geom_parms.polygon_inx)
          order = surface->u_order;
        else
          order = surface->v_order;
        if ((number < 1) ||
            (number > (order - 1)))
        {
          *was_valid_event = FALSE;
          key = EMS_I_00009;
        }
        else
        {
          *done = TRUE;
          event->response = EX_VALUE;
          event->event.value = number;
        }
      }
      break;
    case 106:
      if (event->response == EX_RJT_MOVEON)
      {
        me->event.subtype = GRst_DEFAULT;
        me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
        sts = om$send(
            msg = message ECconstruct.add_event(FALSE),
            targetid = my_id);
      }
      else
      {
        IGRboolean        collapsed;
        IGRlong        loc_msg;
        IGRdouble        knot_tol, u_modify, u_from;

        BScvkttol2(
            curve->order,
            curve->knots,
            curve->num_poles,
            curve->poles, 
            curve->weights,
            &knot_tol,
            &loc_msg);
        if (loc_msg != BSSUCC)
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
        sts = EFpoint_on_object(
            &me->events[0].located_object[0],
            event,
            my_id,
            my_msg);
        if (! (1 & sts)) goto wrapup;
        u_modify = me->events[1].located_object[0].geom_parms.u;
        u_from = me->events[3].located_object[0].geom_parms.u;
        collapsed = (fabs(u_modify - u_from) <= knot_tol);
        if (collapsed)
        {
          if (curve->phy_closed)
            *was_valid_event = FALSE;
          else
          {
            IGRboolean                on_left_end, on_right_end;

            on_left_end = (fabs(u_from - curve->knots[curve->order - 1])
                <= knot_tol);
            on_right_end = (fabs(u_from - curve->knots[curve->num_poles])
                <= knot_tol);
            if (! (on_left_end || on_right_end))
              *was_valid_event = FALSE;
          } /* ELSE FOR if (curve->phy_closed) */
        } /* if (collapsed) */
      }
      break;
    case 108:
      if (event->response == EX_RJT_MOVEON)
      {
        IGRlong        count, i;
        struct                GRparms *parms;

        parms = &event->located_object[0].geom_parms;
        parms->u = surface->u_knots[surface->u_order - 1];
        parms->v = surface->v_knots[surface->v_order - 1];
        parms = &me->event.located_object[0].geom_parms;
        parms->u = surface->u_knots[surface->u_num_poles];
        parms->v = surface->v_knots[surface->v_num_poles];
        me->event.subtype = GRst_DEFAULT;
        me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
        count = (surface->u_phy_closed ? 4 : 1);
        for (i = 0; i < count; i++)
        {
          sts = om$send(
              msg = message ECconstruct.add_event(FALSE),
              targetid = my_id);
        } /* for (i = 0; i < count; i++) */
      }
      else
      {
        IGRboolean        same_u, same_v;
        IGRdouble        knot_tol;
        struct                GRparms *modify_uv, *from_uv;

        sts = EFpoint_on_object(
            &me->events[0].located_object[0],
            event,
            my_id,
            my_msg);
        if (! (1 & sts)) goto wrapup;
        knot_tol = me->events[0].located_object[0].geom_parms.u;
        modify_uv = &me->events[1].located_object[0].geom_parms;
        from_uv = &event->located_object[0].geom_parms;
        same_u = (fabs(modify_uv->u - from_uv->u) <= knot_tol);
        same_v = (fabs(modify_uv->v - from_uv->v) <= knot_tol);
        if (same_u || 
            same_v)
        {
          key = EMS_I_00093;
          if (surface->u_phy_closed || 
              surface->v_phy_closed)
            *was_valid_event = FALSE;
          else
          {
            IGRdouble        u_low, u_hig;

            u_low = surface->u_knots[surface->u_order - 1];
            u_hig = surface->u_knots[surface->u_num_poles];
            if ((fabs(modify_uv->u - u_low) > knot_tol) &&
                (fabs(modify_uv->u - u_hig) > knot_tol))
              *was_valid_event = FALSE;
            else
            {
              IGRdouble        v_low, v_hig;

              v_low = surface->v_knots[surface->v_order - 1];
              v_hig = surface->v_knots[surface->v_num_poles];
              if ((fabs(modify_uv->v - v_low) > knot_tol) &&
                  (fabs(modify_uv->v - v_hig) > knot_tol))
                *was_valid_event = FALSE;
            }
          }
        } /* if (same_u || same_v) */
      }
      break;
    case 114:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 5 verification
     */
  case 5:
    switch (my_type)
    {
    case 87:
      {
        IGRboolean        status, EFboreline();
        IGRpoint        point1, point2;
        struct                IGRline bore_line;
        struct                GRlc_info *lc_info;
        struct                GRid *id;
        struct                GRmdenv_info *mdenv_info;

        bore_line.point1 = &point1[0];
        bore_line.point2 = &point2[0];
        status = EFboreline(
            my_msg, 
            my_id, 
            event,
            &bore_line);
        if (! status) goto wrapup;
        lc_info = &me->events[3].located_object[0];
        id = &lc_info->located_obj;
        mdenv_info = &lc_info->module_info.md_env;
        sts = om$send(
            msg = message GRcurve.GRendpoint(
            my_msg,
            &mdenv_info->matrix_type,
            mdenv_info->matrix,
            &bore_line,
            &event->event.button.x),
            targetid = id->objid,
            targetos = id->osnum);
        if (1 & sts) *done = TRUE;
      }
      break;
    case 88:
      sts = EFfind_closest_side(
          &me->events[3].located_object[0],
          event,
          my_id,
          my_msg);
      if (1 & sts) *done = TRUE;
      break;
    case 106:
      {
        IGRlong                loc_msg;
        IGRdouble        knot_tol, u_modify, u_from, u_to;

        BScvkttol2(
            curve->order,
            curve->knots,
            curve->num_poles,
            curve->poles, 
            curve->weights,
            &knot_tol,
            &loc_msg);
        if (loc_msg != BSSUCC)
        {
          *my_msg = MSFAIL;
          goto wrapup;
        }
        sts = EFpoint_on_object(
            &me->events[0].located_object[0],
            event,
            my_id,
            my_msg);
        if (! (1 & sts)) goto wrapup;
        u_modify = me->events[1].located_object[0].geom_parms.u;
        u_from = me->events[3].located_object[0].geom_parms.u;
        u_to = me->events[4].located_object[0].geom_parms.u;
        if (fabs(u_to - u_from) <= knot_tol)
          *was_valid_event = FALSE;
        else
        {
          IGRboolean        collapsed;

          collapsed = (fabs(u_modify - u_to) <= knot_tol);
          if (collapsed)
          {
            if (curve->phy_closed)
              *was_valid_event = FALSE;
            else
            {
              IGRboolean        on_left_end, on_right_end;

              on_left_end = (fabs(u_to - curve->knots[curve->order - 1])
                  <= knot_tol);
              on_right_end = (fabs(u_to - curve->knots[curve->num_poles])
                  <= knot_tol);
              if (! (on_left_end || on_right_end))
                *was_valid_event = FALSE;
            } /* ELSE FOR if (curve->phy_closed) */
          } /* if (collapsed) */
          else
          {
            if (!curve->phy_closed)
            {
              collapsed = (fabs(u_modify - u_from) <= knot_tol);
              if (!collapsed)
              {
                if (u_from > u_to)
                {
                  IGRdouble        temp;

                  temp = u_from;
                  u_from = u_to;
                  u_to = temp;
                } /* if (u_from > u_to) */
                if ((u_modify < u_from) ||
                    (u_modify > u_to))
                {
                  *was_valid_event = FALSE;
                  key = EMS_I_00005;
                }
              } /* if (!collapsed) */
            } /* if (!curve->phy_closed) */
          } /* ELSE FOR if (collapsed) */
        } /* ELSE FOR if (fabs(u_to - u_from) <= knot_tol) */
      }
      break;
    case 108:
      {
        IGRboolean       same_u, same_v;
        IGRdouble        knot_tol;
        struct GRparms   *modify_uv, *to_uv;

        sts = EFpoint_on_object(
            &me->events[0].located_object[0],
            event,
            my_id,
            my_msg);
        if (! (1 & sts)) goto wrapup;
        knot_tol = me->events[0].located_object[0].geom_parms.u;
        modify_uv = &me->events[1].located_object[0].geom_parms;
        to_uv = &event->located_object[0].geom_parms;
        same_u = (fabs(modify_uv->u - to_uv->u) <= knot_tol);
        same_v = (fabs(modify_uv->v - to_uv->v) <= knot_tol);
        if (same_u || 
            same_v)
        {
          key = EMS_I_00093;
          if (surface->u_phy_closed || 
              surface->v_phy_closed)
            *was_valid_event = FALSE;
          else
          {
            IGRdouble        u_low, u_hig;

            u_low = surface->u_knots[surface->u_order - 1];
            u_hig = surface->u_knots[surface->u_num_poles];
            if ((fabs(modify_uv->u - u_low) > knot_tol) &&
                (fabs(modify_uv->u - u_hig) > knot_tol))
              *was_valid_event = FALSE;
            else
            {
              IGRdouble        v_low, v_hig;

              v_low = surface->v_knots[surface->v_order - 1];
              v_hig = surface->v_knots[surface->v_num_poles];
              if ((fabs(modify_uv->v - v_low) > knot_tol) &&
                  (fabs(modify_uv->v - v_hig) > knot_tol))
                *was_valid_event = FALSE;
            }
          }
        } /* if (same_u || same_v) */
        if (*was_valid_event)
        {
          struct        GRparms *from_uv;

          key = EMS_I_00094;
          from_uv = &me->events[3].located_object[0].geom_parms;
          same_u = (fabs(from_uv->u - to_uv->u) <= knot_tol);
          same_v = (fabs(from_uv->v - to_uv->v) <= knot_tol);
          if (same_u &&
              same_v)
            *was_valid_event = FALSE;
          else /* Are we in the box */
          {
            if (! surface->u_phy_closed)
            {
              IGRdouble                u_low, u_hig;

              if (from_uv->u < to_uv->u)
              {
                u_low = from_uv->u;
                u_hig = to_uv->u;
              }
              else
              {
                u_low = to_uv->u;
                u_hig = from_uv->u;
              }
              if ((modify_uv->u < u_low) ||
                  (modify_uv->u > u_hig))
                *was_valid_event = FALSE;
            } /* if (! surface->u_phy_closed) */
            if (! surface->v_phy_closed)
            {
              IGRdouble                v_low, v_hig;

              if (from_uv->v < to_uv->v)
              {
                v_low = from_uv->v;
                v_hig = to_uv->v;
              }
              else
              {
                v_low = to_uv->v;
                v_hig = from_uv->v;
              }
              if ((modify_uv->v < v_low) ||
                  (modify_uv->v > v_hig))
                *was_valid_event = FALSE;
            } /* if (! surface->v_phy_closed) */
          } /* ELSE FOR if (same_u && same_v) */
          if (*was_valid_event)
          {
            me->event.subtype = GRst_DEFAULT;
            me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
            sts = om$send(
                msg = message ECconstruct.add_event(FALSE),
                targetid = my_id);
          } /* if (*was_valid_event) */
        } /*if (*was_valid_event) */
      }
      break;
    case 114:
      if (event->response == EX_RJT_MOVEON)
        *done = TRUE;
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 6 verification
     */
  case 6:
    switch (my_type)
    {
    case 106:
    case 114:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
        if (*was_valid_event &&
            (my_type == 114) &&
            surface->v_phy_closed)
          *done = TRUE;
      }
      break;
    case 108:
      if (event->response == EX_RJT_MOVEON)
      {
        IGRlong        i;

        me->event.subtype = GRst_DEFAULT;
        me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
        for (i = 0; i < 2; i++)
        {
          sts = om$send(
              msg = message ECconstruct.add_event(FALSE),
              targetid = my_id);
        } /* for (i = 0; i < 2; i++) */
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 7 verification
     */
  case 7:
    switch (my_type)
    {
    case 106:
    case 108:
    case 114:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      if (*was_valid_event)
      {
        if ((my_type == 106) ||
            (my_type == 114))
          *done = TRUE;
      } /* if (*was_valid_event) */
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 8 verification
     */
  case 8:
    switch (my_type)
    {
    case 108:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      if (me->events[3].response == EX_DATA)
      {
        me->event.subtype = GRst_DEFAULT;
        me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
        sts = om$send(
            msg = message ECconstruct.add_event(FALSE),
            targetid = my_id);
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 9 verification
     */
  case 9:
    switch (my_type)
    {
    case 108:
      if (event->response == EX_RJT_MOVEON) *done = TRUE;
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 10 verification
     */
  case 10:
    switch (my_type)
    {
    case 108:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Event 11 verification
     */
  case 11:
    switch (my_type)
    {
    case 108:
      {
        IGRboolean        *preserve;

        preserve = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
          *preserve = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
            (event->event.keyin[0] == 'n'))
          *preserve = FALSE;
        else
        {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
        }
      }
      if (*was_valid_event) *done = TRUE;
      break;
    default:
      /*     noop; */
      break;
    } /* switch (my_type) */
    break;
    /*
     * Error 
     */
  default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
  /*
   * Output the error message, if any
   */
  if (! *was_valid_event)
    ex$message(msgnumb = key)
  /*
   * eof
   */
wrapup:
    if (1 & *my_msg)
      return(OM_S_SUCCESS);
    else
      return(OM_E_ABORT);
}

end implementation ECmodify;
