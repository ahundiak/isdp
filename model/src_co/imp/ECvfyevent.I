/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method determines the validity of an event and the
 termination condition for the following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Place solid box by two points		1
	Place box by four points		2
	Place solid box by four points		3
	Place cone by axis and diameters	4
  	Place solid right trunc. cone		5
	Place cylinder by axis and radius	6
	Place solid right circ. cylinder	7
	Place torus				8
	Place solid torus			9
	Place solid right elliptical cylinder	10
	Place solid trunc. elliptical cone	11
	Place ellipsoid - foci axis len.	12
	Place ellipsoid - ctr. axis rad.	13
	Place solid 4 face 4 vert. polyhedron	14
	Place solid 5 face 5 vert. polyhedron	15
	Place solid 5 face 6 vert. polyhedron	16
	Place solid 6 face 7 vert. polyhedron	17
	Place solid 6 face 8 vert. polyhedron	18
	Place rectangular plane by 3 points	19
	Place parallelogram plane by 3 points	20
	Place solid right angle wedge		21
	Rho conic				22
	Conic by 3 points and 2 tangents	23
	Conic by 4 points and 1 tangent		24
	Conic by 5 points			25
	Place sphere by center and radius	26
	Place solid globe			27
	Place solid ellipsoid - foci axis len.	28
	Place solid ellipsoid - ctr. axis rad.	29
	Place right elliptical cylinder		30
	Place trunc. elliptical cone		31
	Place part of curve			32
	Place parabola tangent to 2 curves	33
	Place blend between 2 curves		34
						--
	Place helix				36
	Place partial surface			37
	Place surface of revolution		38
	Place solid of revolution		39
        Project curve onto surface along norm   40
        Project point along vector onto surf    41
        Project curve along vector onto surf    42
	Place surface by 3 boundaries		43
	Place surface by 4 boundaries		44

	Place offset surface			45
        code for Place offset surface is moved to
        src_testco/imp ECcsoffseti.I

        Blend 2 surfaces - interior		46
	Blend 2 surfaces - exterior		47
	Place fillet surface			48
	Place plane tangent to surface		49
	Place plane tangent to curve		50
						51
        Extract iso curves			52
	Place surface of projection		83
	Place solid of projection		84
	Intersect elements			85
	Place conic by linestring		93
	Place plane normal to curve		94
						--
	Place solid by offsetting surface	109
						--
        Create wireframe model			112
        Place parting lines as curves		113
						--
        Place fillet surface with auto trim	115
        Place parting lines as features		201
	Display isophotes                       202
	Place angular parting surface		203
	
 Notes

 If this function determines that the event was invalid then
 it will output a message to the user informing him of this.

 History

 10/27/87 : rlw : The beginning
 01/04/88 : rlw : Added some commands
 01/08/88 : rlw : Modified such that surface/solid of projection projects in
                  a direction normal to the plane.
 01/15/88 : rlw : Removed modification that forced projection normal to plane,
                  as per Attilio's direction.  Also removed similar logic
                  for surfaces of revolution.
 03/18/88 : rlw : Modified place helix such that a zero pitch gap is
                  allowed for placing spirals.
                  Modified surface/solid of revolution to call
                  validation routine.
 03/22/88 : rlw : Added place conic by linestring command and
                  place plane normal to curve command.
 05/04/88 : rlw : Fixed surface/solid of projection.  I was not projecting
                  in the correct direction for orthogonal keyed in distances.
 05/30/88 : rlw : Modified fillet surface in order to support variable radius.
 06/29/88 : rlw : Added place blending surface command
 07/04/88 : rlw : Added place reduced fit curve command
 07/12/88 : rlw : Modified default value for reduced fit as per Dieter
                  Added Place solid by offsetting surface command
 07/28/88 : rlw : Removed Place plane encompassing planar element logic as
                  it's in ECautoplanei.I
 08/01/88 : rlw : Added Create wireframe model command, note that this
                  was originally witten by Sunit on 01/21/88.
                  Added Place parting lines command.
 08/05/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
 08/29/88 : rlw : Added additional question for sweep direction of helix.
 09/02/88 : rlw : Added fillet with auto trim
 09/20/88 : rlw : Modified intersect two elements to not allow duplicate
                  locate unless first object is a curve.
 12/01/88 : rlw : Moved the place blending surface (105) command to a
                  separate class due to changes in the command.
 01/13/89 : rlw : Added validation checks to solid of revolution.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 07/25/89 : rlw : Added closure check for surface by 3 and 4 boundaries.
 08/16/89 : pp  : Modified the project curve onto surface command to
                  let the user identify an infinite plane and to support
                  sets for curves.
 21-Sep-89: SM  : Added 'Place angular parting surface'.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.
 03/25/92:Carlos: Changed event 6 verification for command 36 (place helix).
 		  Fix for TR92n1937.
 Tapadia 03/25/92 Commented case 84 as it's overriden (ECplsolproj.I)
 03/19/93: sam  : code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I. --sampath
 06/03/93:Sudha : Modified for adding BSprototype headers
 07/14/93:Sudha : Fix for TR#11914140. Modify the event value only if the
		  event response isnot DATA.

 */

class implementation ECconstruct;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_I.h"		/* Message keys for informational strings */
#include "EMSmsgdef.h"		/* Contains EMS error return codes */
#include "maraddeg.h"
#include "bstst_plan.h"
#include "bsparameters.h"
#include "bsnor_to_pl.h"
#include "bsdistptpt.h"
#include "bsdistptli.h"
#include "bsdistncta.h"
#include "bsdistnct2.h"
#include "bscollin.h"

from GRvg import GRdetplane;
from GRcurve import GRendpts;

#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
#endif

/*
 Description

 This function is used to correct the display under
 certain circumstances.

 History

 12/10/87 : rlw : Creation date

 */
#ifndef IDRAW
IGRlong EFpatch_the_display_for_normals(
 event,
 my_stupid_id)

struct		GRevent *event;
OM_S_OBJID	my_stupid_id;

{
 IGRboolean	*reverse_curve;
 IGRlong	sts;
/*
 * Erase the current display
 */
 sts = om$send(
   msg = message ECconstruct.display_constructions(
    FALSE,		/* Erase */
    TRUE),		/* Just one */
   senderid = my_stupid_id,
   targetid = my_stupid_id);
  if (! (1 & sts)) return(sts);
/*
 * Toggle the direction
 */
 reverse_curve = 
   &event->located_object[0].geom_parms.polygon_inx;
 if (*reverse_curve)
  *reverse_curve = FALSE;
 else
  *reverse_curve = TRUE;
/*
 * Redraw the correct display
 */
 sts = om$send(
   msg = message ECconstruct.display_constructions(
    TRUE,		/* Draw */
    TRUE),		/* Just one */
   senderid = my_stupid_id,
   targetid = my_stupid_id);
  if (! (1 & sts)) return(sts);
/*
 * Eof
 */
 return(OM_S_SUCCESS);
}
#endif

method verify_event(
 IGRboolean	use_default;
 IGRboolean	*was_valid_event;
 IGRboolean	*done)

{
 extern		void EFextract_points();
#ifndef IDRAW
 extern		IGRlong EFpoint_on_object(), EFfind_closest_side();
#endif
 IGRlong	save_num_events = 0;
 IGRboolean	*have_plane;
 IGRlong	key, sts, *my_msg, my_type;
 IGRpoint	points[20];
 IGRvector	*height_vector, *width_vector, *depth_vector;
 struct		GRevent *event;
 struct		IGRplane plane;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
 save_num_events = me->number_of_events_input;

/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *done = FALSE;
 key = EMS_I_00001;
 *was_valid_event = TRUE;;
 EFextract_points(
  me->number_of_events_input,
  me->events,
  points);
 event = &me->events[me->number_of_events_input - 1];
/*
 * I am cheating here and storing information computed by 
 * this function in the events array.  This should be okay
 * so long as I only use this stuff in events/places/states
 * which are occur after the storage index.  For example the
 * width and height vectors are used only after I have events[2]
 * and the depth vector is only used after I have events[3].
 */
 {
  struct	GRlc_info *info;

  info          = &me->events[0].located_object[0];
  have_plane    = &info->geom_parms.polygon_inx;
  width_vector  = (IGRvector *)&info->proj_pnt[0];
  height_vector = (IGRvector *)&me->events[0].located_object[1].proj_pnt[0];
  depth_vector  = (IGRvector *)&me->events[1].located_object[0].proj_pnt[0];
  plane.point   = (IGRdouble *)width_vector;
  plane.normal  = (IGRdouble *)height_vector;
 }

 /* For type 203 I am interested in verifying only events 1, 2, 3, and 4. 
    After that the pattern for event,  5, 7, 9 etc. repeats 
    (which is looking for a move on for termination). We do not allow
    termination at even numbered events after 4 because only one of the 
    elements of the normal parting line/angular parting line pair would have 
    been input.
 */
 if( (my_type == 203) && (save_num_events > 4))
  {
   if(save_num_events % 2) me->number_of_events_input = 3;
   else me->number_of_events_input = 4;
  }

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
#ifndef IDRAW
      case 45:  /* code is moved to src_testco/imp/ECcsoffseti.I for case 45 */
      case 47:
      case 48:
      case 52:
      case 109:
      case 115:
       event->located_object[0].geom_parms.polygon_inx = TRUE;
       break;
      case 49:
      case 50:
      case 94:
       if (use_default)
        {
         key = EMS_I_00006;
         *was_valid_event = FALSE;
        }
       else
        {
         IGRboolean	status;
         IGRlong	loc_msg;
         IGRdouble	tolerance, radius;

         status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
         radius = event->event.value;
         if (radius < tolerance) 
          {
           *was_valid_event = FALSE;
           key = EMS_I_00009;
          }
        }
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	is_surface;
        struct		GRlc_info *lc_info;
        struct		GRid *id;
        struct		GRmd_env *md_env;
        struct		GRmdenv_info *mdenv_info;

        lc_info = &event->located_object[0];
        id = &lc_info->located_obj;
        md_env = &lc_info->module_info;
        mdenv_info = &md_env->md_env;
        if (me->mytype == 83)
         is_surface = FALSE;
        else
         {
          OMuword	classid;

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
            superclassid = OPP_EMSsubbs_class_id);
           if (! (1 & sts))
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
          is_surface = (sts == OM_S_SUCCESS);
         } /* ELSE FOR if (me->mytype == 83) */
        event->located_object[1].geom_parms.polygon_inx = is_surface;
        if ((! is_surface) &&
            (me->mytype == 84))
         {
          extern	IGRlong EFgetprops();
          struct	GRprops properties;

          sts = EFgetprops(
            event,
            my_id,
            &properties,
            my_msg);
           if (! (1 & sts)) goto wrapup;
          if (!properties.phy_closed)
           {
            *was_valid_event = FALSE;
            key = EMS_I_00014;
           }
         } /* if ((! is_surface) && (me->mytype == 84)) */
        if (*was_valid_event)
         {
          sts = om$send(
            msg = message GRvg.GRdetplane(
             my_msg,
             &mdenv_info->matrix_type,
             mdenv_info->matrix,
             &plane),
            targetid = id->objid,
            targetos = id->osnum);
           if (! (1 & sts)) goto wrapup;
          if (*my_msg == MSSUCC)
           *have_plane = 1;
          else
           {
            *my_msg = MSSUCC;
            *have_plane = 0;
           }
         } /* if (*was_valid_event) */
       }
       break;
#endif
      case 85:
       {
        IGRboolean	is_curve;
        extern		IGRlong EFgetprops();
        struct		GRprops properties;

        sts = EFgetprops(
          event,
          my_id,
          &properties,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        is_curve = (properties.type == GRCURVE);
        event->located_object[0].geom_parms.polygon_inx = is_curve;
       }
       break;
      case 93:
       {
        extern	IGRlong EFgetabstract();
        struct	IGRbsp_curve *curve;

        sts = EFgetabstract(
          event,
          my_id,
          &curve,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        if (curve->num_poles > 4)
         *done = TRUE;
        else
         {
          *was_valid_event = FALSE;
          key = EMS_I_00022;
         }
       }
       break;
#ifndef IDRAW
      case 112:
       *done = TRUE;
       break;
#endif
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
#ifndef IDRAW
      case 1:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	delta, zero_tol_sq;

        status = BSEXTRACTPAR(
          &loc_msg,
          BSTOLLENVEC,
          zero_tol_sq);
        delta = points[0][0] - points[1][0];
        if (fabs(delta) < zero_tol_sq)
         *was_valid_event = FALSE;
        else
         {
          delta = points[0][1] - points[1][1];
          if (fabs(delta) < zero_tol_sq)
           *was_valid_event = FALSE;
          else
           {
            delta = points[0][2] - points[1][2];
            if (fabs(delta) < zero_tol_sq)
             *was_valid_event = FALSE;
            else
             *done = TRUE;
           } /* ELSE FOR if (fabs(delta) < zero_tol_sq) */
         } /* ELSE FOR if (fabs(delta) < zero_tol_sq) */
       }
       break;
#endif
      case  2:
      case  3:
      case  4:
      case  5:
      case  6:
      case  7:
      case  8:
      case  9:
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
      case 23:
      case 24:
      case 25:
      case 28:
      case 29:
      case 30:
      case 31:
      case 36:
      case 42:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[0],
          points[1]);
         if (!status)
          *was_valid_event = FALSE;
       }
       break;
#ifndef IDRAW
      case 26:
      case 27:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	radius, tolerance;

        if (event->response == EX_DATA)
         radius = BSdistptpt(
          &loc_msg,
          points[0],
          points[1]);
        else if (use_default)
         {
          key = EMS_I_00006;
          *was_valid_event = FALSE;
         }
        else
         radius = event->event.value;
        if (*was_valid_event)
         {
          status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
          if (radius < tolerance) 
           *was_valid_event = FALSE;
          else
           {
            *done = TRUE;
            event->response = EX_VALUE;
/* fix for tentative key point */
            event->num_id=0;

            event->event.value = radius;
           }
         } /* if (*was_valid_event) */
       }
       break;
      case 32:
      case 34:
      case 37:
      case 52:
       sts = EFpoint_on_object(
         &me->events[0].located_object[0],
         event,
         my_id,
         my_msg);
       break;
      case 38:
      case 39:
      case 41:
      case 43:
      case 44:
      case 202:
      case 203:
/*     noop; */
       break;
#endif
      case 33: /* Included for MDS -Inasu, Sept 5,1990 */
       sts = EFpoint_on_object(
         &me->events[0].located_object[0],
         event,
         my_id,
         my_msg);
       break;
      case 40:
      case 85:
      case 113:
      case 201:
       *done = TRUE;
       break;
#ifndef IDRAW
      case 45: /* code is moved to src_testco/imp/ECcsoffseti.I for case 45 */
      case 48:
      case 109:
      case 115:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[0],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 46:
       {
        struct		GRlc_info *loc_info;
        struct		GRid *id;
        struct		GRmdenv_info *mdenv_info;

        loc_info = &event->located_object[0];
        id = &loc_info->located_obj;
        mdenv_info = &loc_info->module_info.md_env;
        loc_info->geom_parms.polygon_inx = FALSE;	/* Not reversed */
        sts = om$send(
          msg = message GRcurve.GRendpts(
           my_msg,
           &mdenv_info->matrix_type,
           mdenv_info->matrix,
           loc_info->proj_pnt,				/* 1st end point */
           &event->located_object[1].proj_pnt[0]),	/* 2nd end point */
          targetid = id->objid,
          targetos = id->osnum);
         if (! (1 & sts)) goto wrapup;
       }
       break;
      case 47:
       sts = EFfind_closest_side(
         &me->events[0].located_object[0],
         event,
         my_id,
         my_msg);
        if (! (1 & sts)) return(OM_E_ABORT);
       break;
      case 49:
      case 50:
      case 94:
       if (use_default)
        {
         key = EMS_I_00006;
         *was_valid_event = FALSE;
        }
       else
        {
         IGRboolean	status;
         IGRlong	loc_msg;
         IGRdouble	tolerance, radius;

         status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
         radius = event->event.value;
         if (radius < tolerance) 
          {
           *was_valid_event = FALSE;
           key = EMS_I_00009;
          }
        }
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	*is_ortho;

        is_ortho = &me->event.located_object[0].geom_parms.polygon_inx;
        me->event.subtype = GRst_DEFAULT;
        if (*have_plane)		/* Put a moveon event on the queue */
         {
          *is_ortho = TRUE;
          me->event.response = EX_RJT_MOVEON;
         }
        else			/* Put a dummy event on the queue to skip */
         {
          *is_ortho = FALSE;
          me->event.response = EX_MAX_RESPONSE;
         }
        sts = om$send(
          msg = message ECconstruct.add_event(FALSE),
          targetid = my_id);
       }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 3 verification
 */
   case 3:
    switch (my_type)
     {
      case  2:
      case  3:
      case  8:
      case  9:
      case 10:
      case 11:
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
      case 23:
      case 24:
      case 25:
      case 30:
      case 31:
      case 36:
      case 42:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BScollin(
          &loc_msg,
          points[0],
          points[1],
          points[2]);
         if (status)
          *was_valid_event = FALSE;
         else
          {
           switch (my_type)
            {
#ifndef IDRAW
             case 19:
             case 20:
              *done = TRUE;
              break;
             case  2:
             case  3:
             case 10:
             case 11:
             case 21:
             case 30:
             case 31:
             case 36:
              {
               extern	IGRlong EFmkperp2vec();

               sts = EFmkperp2vec(
                 points[0],
                 points[1],
                 points[2],
                 width_vector,
                 height_vector);
                if (! (1 & sts))
                 *my_msg = MSFAIL;
                else if (sts == EMS_I_Modified)
                 {
                  struct EX_button *button;
 
                  button = &event->event.button;
                  button->x = points[2][0];
                  button->y = points[2][1];
                  button->z = points[2][2];
                 }
              }
              break;
              case 42:
/*
 * Add a dummy event onto queue.
 */
               me->event.response = EX_MAX_RESPONSE;
               me->event.located_object[0].located_obj.objid = NULL_OBJID;

               sts = om$send(
                  msg = message ECconstruct.add_event(FALSE),
                  targetid = my_id);
               break;
#endif
             default:
/*            noop; */
              break;
            } /* switch (my_type) */
          } /* ELSE FOR if (status) */
        }
       break;
      case 33:
       break;
#ifndef IDRAW
      case  4:
      case  5:
      case  6:
      case  7:
      case 12:
      case 13:
      case 28:
      case 29:
      case 45:			/* offset is cheating a little */
      /* code is moved to src_testco/imp/ECcsoffseti.I for case 45 */
      case 109:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	radius, tolerance;

        if (event->response == EX_DATA)
         {
          status = BSdistptli(
            &loc_msg,
            points[2],
            points[0],
            points[1],
            &radius);
           if (!status)
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
/* start KLUDGE ******/
           switch (my_type)
            {
            case 4:
            case 5:
            case 6:
            case 7:
                radius *= 2.0;
            }
/* end KLUDGE ******/
         } /* if (event->response == EX_DATA) */
        else if (use_default)
         {
          key = EMS_I_00006;
          *was_valid_event = FALSE;
         }
        else
         radius = event->event.value;
        if (*was_valid_event)
         {
          switch (my_type)
           {
            case 12:
            case 28:
             tolerance = BSdistptpt(
              &loc_msg,
              points[0],
              points[1]);
             break;
            default:
             status = BSEXTRACTPAR(
              &loc_msg,
              BSTOLLENVEC,
              tolerance);
             break;
           } /* switch (my_type) */
          if (radius < tolerance)		/* Invalid radius? */
           {
            switch (my_type)
             {
              case 4:			/* Zero is OK for a cone */
              case 5:
               event->response = EX_VALUE;
               event->event.value = 0.0;
               break;
              case 6:
              case 7:
              case 13:
              case 29:
              case 45:      /* code is moved to src_testco/imp/ECcsoffseti.I
                               for case 45 */
              case 109:
               *was_valid_event = FALSE;
               break;
              case 12:
              case 28:
               *was_valid_event = FALSE;
               key = EMS_I_00007;
               break;
              default:
               *my_msg = MSFAIL;
               goto wrapup;
             } /* switch (my_type) */
           } /* if (radius < tolerance) */
          else
           {
            event->response = EX_VALUE;
/* fix for tentative key point */
            event->num_id=0;
            event->event.value = radius;
            switch (my_type)
             {
              case 4:
              case 5:
/*             noop; */
               break;
              case 6:
              case 7:
              case 12:
              case 13:
              case 28:
              case 29:
              case 45:      /* code is moved to src_testco/imp/ECcsoffseti.I
                               for case 45 */
              case 109:
               *done = TRUE;
               break;
              default:
               *my_msg = MSFAIL;
               goto wrapup;
             } /* switch (my_type) */
           } /* ELSE FOR if (radius < tolerance) */
         } /* if (*was_valid_event) */
       }
       break;
      case 32:
      case 37:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        struct		GRprops properties;
        struct		EX_button *button;

        sts = EFpoint_on_object(
          &me->events[0].located_object[0],
          event,
          my_id,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        button = &event->event.button;
        points[2][0] = button->x;
        points[2][1] = button->y;
        points[2][2] = button->z;
        status = BSdistnct2(
          &loc_msg,
          points[1],
          points[2]);
        if (status)
         {
          extern	IGRlong EFgetprops();

          sts = EFgetprops(
            &me->events[0],
            my_id,
            &properties,
            my_msg);
           if (! (1 & sts)) goto wrapup;
          *done = (!properties.phy_closed);
         }
        else
         *was_valid_event = FALSE;
       }
       break;
      case 44:
      case 49:
      case 50:
      case 94:
/*     noop; */
       break;
      case 34:
      case 41:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[1],
          points[2]);
        if (!status)
         *was_valid_event = FALSE;
       }
       break;
      case 38:
      case 39:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[1],
          points[2]);
         if (!status)
          *was_valid_event = FALSE;
         else
          {
           IGRlong	EMmsg;
           extern	IGRlong EFvalidate_surface_of_revolution();

           sts = EFvalidate_surface_of_revolution(
             (my_type == 39),			/* Is solid? */
             &me->events[0].located_object[0],
             points[1],
             my_id,
             &me->display,
             &me->display_env,
             &EMmsg);
            if (EMmsg == EMS_S_Success)
             {
              if (my_type == 39)		/* Is solid? */
               {
                extern	IGRlong EFgetprops();
                struct	GRprops properties;

                sts = EFgetprops(
                  &me->events[0],
                  my_id,
                  &properties,
                  my_msg);
                 if (! (1 & sts)) goto wrapup;
                if (!properties.phy_closed)	/* Avoid making up an event */
                 {
                  struct	GRevent *event;

                  *done = TRUE;
                  event = &me->events[3];
                  event->response = EX_VALUE;
                  event->event.value = 360.0;
                 }
               } /* if (my_type == 39)	*/
             } /* if (EMmsg == EMS_S_Success) */
            else
             {
              *was_valid_event = FALSE;
              if (EMmsg == EMS_I_Intersect)
               key = EMS_I_00068;
              else if (EMmsg == EMS_I_Coincident)
               key = EMS_I_00069;
              else if (EMmsg == EMS_I_Useless)
               key = EMS_I_00070;
             } /* ELSE FOR if (EMmsg == EMS_S_Success) */
          } /* ELSE FOR if (!status) */
       }
       break;
      case 43:
       {
        extern		IGRlong EMreport_curve_gaps();
        IGRboolean	gaps_exist;
        IGRlong		i;
        struct		EX_button buttons[3];
        struct		GRlc_info lc_info[3];

        for (i = 0; i < 3; i++)
         {
          lc_info[i] = me->events[i].located_object[0];
          buttons[i] = me->events[i].event.button;
          if (me->events[i].response != EX_DATA)
           buttons[i].objid = NULL_OBJID;
         } /* for (i = 0; i < 3; i++) */
        sts = EMreport_curve_gaps(
          3,
          lc_info,
          buttons,
          FALSE,
          &me->display,
          &me->display_env,
          &gaps_exist,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        if (gaps_exist)
         {
          *was_valid_event = FALSE;
          key = EMS_I_00074;
         }
        else
         *done = TRUE;
       }
       break;
      case 46:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[1],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 47:
      case 52:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[0],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 48:
       event->located_object[0].geom_parms.polygon_inx = TRUE;
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	*is_ortho;

        is_ortho = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
         *is_ortho = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
                 (event->event.keyin[0] == 'n'))
         *is_ortho = FALSE;
        else
         {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
         }
       }
       break;
      case 115:
       {
        struct	GRlc_info *loc_info;
        struct	GRid *id_1, *id_2;

        event->located_object[0].geom_parms.polygon_inx = TRUE;
        loc_info = &me->events[0].located_object[0];
        id_1 = &loc_info->located_obj;
        loc_info = &event->located_object[0];
        id_2 = &loc_info->located_obj;
        if (id_1->osnum != id_2->osnum)
         {
          *was_valid_event = FALSE;
          key = EMS_I_LocSfSlHasDiffEnv;
         }
       }
       break;

       case 202:
       {
          IGRboolean	status;
          IGRdouble angle;

          if (use_default)
          {
            event->event.value = 0.0;
            event->response = EX_VALUE;
          }
          angle = event->event.value;
          status = MAraddeg(
           my_msg,
           &angle,
           &angle);
          if (angle < 0.0)
          {
           *was_valid_event = FALSE;
            key = EMS_I_00009;
          }
          else
           event->event.value = angle;
       }
       break;
      case 203:
       if (event->response == EX_RJT_MOVEON) *done = TRUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 4 verification
 */
   case 4:
    switch (my_type)
     {
#ifndef IDRAW
      case  2:
      case  3:
      case 10:
      case 11:
      case 21:
      case 30:
      case 31:
       {
        extern	IGRlong EFptonface();

        sts = EFptonface(
          points,
          points[3]);
         if (! (1 & sts))
          *my_msg = MSFAIL;
         else if (sts == EMS_I_OnFace)
          *was_valid_event = FALSE;
         else
          {
           switch (my_type)
            {
             case  2:
             case  3:
             case 10:
             case 21:
             case 30:
              *done = TRUE;	/* No break after this on purpose */
             case 11:
             case 31:
              {
               extern	IGRlong EFmkperpvcpl();

               sts = EFmkperpvcpl(
                 points,
                 points[3],
                 depth_vector);
                if (! (1 & sts))
                 *my_msg = MSFAIL;
                else if (sts == EMS_I_Modified)
                 {
                  struct EX_button *button;
 
                  button = &event->event.button;
                  button->x = points[3][0];
                  button->y = points[3][1];
                  button->z = points[3][2];
                 }
              }
              break;
             default:
              *my_msg = MSFAIL;
              goto wrapup;
            } /* switch (my_type) */
          } /* ELSE FOR else if (sts == EMS_I_OnFace) */
       }
       break;
      case  4:
      case  5:
      case 36:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	radius, tolerance;

        if (event->response == EX_DATA)
         {
          status = BSdistptli(
            &loc_msg,
            points[3],
            points[0],
            points[1],
            &radius);
           if (!status)
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
/* start KLUDGE ******/
           switch (my_type)
            {
            case 4:
            case 5:
                radius *= 2.0;
            }
/* end KLUDGE ******/
         } /* if (event->response == EX_DATA) */
        else if (use_default)
         {
          key = EMS_I_00006;
          *was_valid_event = FALSE;
         }
        else
         radius = event->event.value;
        if (*was_valid_event)
         {
          status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
          if (radius < tolerance)		/* Invalid radius? */
           {
            switch (my_type)
             {
              case 4:
              case 5:
               if (me->events[2].event.value != 0.0)	/* 1st was zero? */
                {
                 event->response = EX_VALUE;
                 event->event.value = 0.0;
                 *done = TRUE;
                }
               else
                *was_valid_event = FALSE;
               break;
              case 36:
               event->event.value = 0.0;
               break;
              default:
               *my_msg = MSFAIL;
               goto wrapup;
             } /* switch (my_type) */
           } /* if (radius < tolerance) */
          else
           {
            event->response = EX_VALUE;
    /* fix for tentative snap */
    event->num_id=0;
            event->event.value = radius;
            switch (my_type)
             {
              case 4:
              case 5:
               *done = TRUE;
               break;
              case 36:
/*             noop; */
               break;
              default:
               *my_msg = MSFAIL;
               goto wrapup;
             } /* switch (my_type) */
           } /* ELSE FOR if (radius < tolerance) */
         } /* if (*was_valid_event) */
       }
       break;
      case  8:
      case  9:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	radius, tolerance;

        if (event->response == EX_DATA)
         radius = BSdistptpt(
          &loc_msg,
          points[2],
          points[3]);
        else if (use_default)
         {
          key = EMS_I_00006;
          *was_valid_event = FALSE;
         }
        else
         radius = event->event.value;
        if (*was_valid_event)
         {
          status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
          if (radius < tolerance) 
           *was_valid_event = FALSE;
          else
           {
            IGRboolean	status;
            IGRdouble	distance;

            status = BSdistptli(
              &loc_msg,
              points[2],
              points[0],
              points[1],
              &distance);
             if (!status)
              {
               *my_msg = MSFAIL;
               goto wrapup;
              }
            if (radius > distance)
             {
              key = EMS_I_00008;
              *was_valid_event = FALSE;
             }
            else
             {
              *done = TRUE;
              event->response = EX_VALUE;
/* fix for tentative key point */
            event->num_id =0;
              event->event.value = radius;
             } /* ELSE FOR if (radius > distance) */
           } /* ELSE FOR if (radius < tolerance)  */
         } /* if (*was_valid_event) */
       }
       break;
#endif
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
      case 22:
      case 23:
      case 24:
      case 25:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistncta(
          me->number_of_events_input,
          points,
          &loc_msg);
         if (!status)
          *was_valid_event = FALSE;
         else
          {
           switch (my_type)
            {
             case 14:
              *done = TRUE;
              break;
             default:
              break;
            } /* switch (my_type) */
          } /* ELSE FOR if (!status) */
       }
       break;
      case 33:   /* Included for MDS -Inasu, Sept 5,1990 */
       sts = EFpoint_on_object(
         &me->events[2].located_object[0],
         event,
         my_id,
         my_msg);
       if (1 & sts) *done = TRUE;
       break;
#ifndef IDRAW
      case 32:
      case 37:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        struct		EX_button *button; 

        sts = EFpoint_on_object(
          &me->events[0].located_object[0],
          event,
          my_id,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        button = &event->event.button;
        points[3][0] = button->x;
        points[3][1] = button->y;
        points[3][2] = button->z;
 
        status = BSdistncta(
          3,
          (IGRpoint *)points[1],
          &loc_msg);
         if (!status)
          *was_valid_event = FALSE;
         else
          *done = TRUE;
       }
       break;
      case 49:
      case 50:
      case 94:
       sts = EFpoint_on_object(
         &me->events[2].located_object[0],
         event,
         my_id,
         my_msg);
        if (1 & sts) *done = TRUE;
       break;
      case 34:
      case 42:
      case 46:
      case 47:
      case 203:
/*     noop; */
       break;
      case 38:
      case 39:
       {
        IGRdouble	sweep_angle;

        if (use_default)
         {
          sweep_angle = 360.0;
          *done = TRUE;
         }
        else
         {
          IGRboolean	status;

          sweep_angle = event->event.value;
          status = MAraddeg(
           my_msg,
           &sweep_angle,
           &sweep_angle);
          if (sweep_angle < .001)
           {
            key = EMS_I_00009;
            *was_valid_event = FALSE;
           }
          else if (sweep_angle > 359.999)
           {
            sweep_angle = 360.0;
            *done = TRUE;
           }
         }
        event->response = EX_VALUE;
        event->event.value = sweep_angle;
       }
       break;
      case 41:
       *done = TRUE;
       break;
      case 44:
       {
        extern		IGRlong EMreport_curve_gaps();
        IGRboolean	gaps_exist;
        IGRlong		i;
        struct		EX_button buttons[4];
        struct		GRlc_info lc_info[4];

        for (i = 0; i < 4; i++)
         {
          lc_info[i] = me->events[i].located_object[0];
          buttons[i] = me->events[i].event.button;
          if (me->events[i].response != EX_DATA)
           buttons[i].objid = NULL_OBJID;
         } /* for (i = 0; i < 4; i++) */
        sts = EMreport_curve_gaps(
          4,
          lc_info,
          buttons,
          TRUE,
          &me->display,
          &me->display_env,
          &gaps_exist,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        if (gaps_exist)
         {
          *was_valid_event = FALSE;
          key = EMS_I_00074;
         }
        else
         *done = TRUE;
       }
       break;
      case 48:
      case 115:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[2],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 52:
       {
        IGRlong		number_of_lines;

        if (use_default)
         number_of_lines = 1;
        else
         number_of_lines = event->event.value;
        if (number_of_lines < 1)
         {
          key = EMS_I_00009;
          *was_valid_event = FALSE;
         }
        else if (number_of_lines == 1)
         *done = TRUE;
        event->response = EX_VALUE;
        event->event.value = number_of_lines;
       }
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	is_ortho, status;
        IGRlong		loc_msg;

        is_ortho = me->events[2].located_object[0].geom_parms.polygon_inx;
        if (*have_plane &&
            is_ortho)
         {
          if (event->response == EX_DATA)
           {
            IGRdouble	t;
            IGRvector	vector;

            vector[0] = points[3][0] - points[1][0];
            vector[1] = points[3][1] - points[1][1];
            vector[2] = points[3][2] - points[1][2];
            t = vector[0] * plane.normal[0] +
                vector[1] * plane.normal[1] + 
                vector[2] * plane.normal[2];
            points[3][0] = points[1][0] + t * plane.normal[0];
            points[3][1] = points[1][1] + t * plane.normal[1];
            points[3][2] = points[1][2] + t * plane.normal[2];
           } /* if (event->response == EX_DATA) */
          else if (use_default)
           {
            *was_valid_event = FALSE;
            key = EMS_I_00006;
           }
          else
           {
            IGRdouble	distance, dot;
            IGRvector	vector;

            vector[0] = points[1][0] - plane.point[0];
            vector[1] = points[1][1] - plane.point[1];
            vector[2] = points[1][2] - plane.point[2];
            dot = vector[0] * plane.normal[0] +
                  vector[1] * plane.normal[1] + 
                  vector[2] * plane.normal[2];
            if (dot < 0.0)
             distance = -event->event.value;
            else
             distance = event->event.value;
            points[3][0] = points[1][0] + distance * plane.normal[0];
            points[3][1] = points[1][1] + distance * plane.normal[1];
            points[3][2] = points[1][2] + distance * plane.normal[2];
           } /* response is a value */
         } /* if (*have_plane && is_ortho) */
        if (*was_valid_event)
         {
          struct	EX_button *button;

          button = &event->event.button;
          button->x = points[3][0];
          button->y = points[3][1];
          button->z = points[3][2];
          status = BSdistnct2(
            &loc_msg,
            points[1],
            points[3]);
          if (!status)
           *was_valid_event = FALSE;
          else
           *done = TRUE;
         } /* if (*was_valid_event) */
       }
       break;
       case 202:
       {
          IGRboolean	status;
          IGRdouble angle;

          if (event->response == EX_RJT_MOVEON)
          {
           *done = TRUE;
           event->located_object[0].geom_parms.polygon_inx = 1;
/*
 * Set this flag to be TRUE to let perform_constructions know that
 * there is no stop angle.
 */
          }
          else
          {
           event->located_object[0].geom_parms.polygon_inx = 0;
           if (use_default)
           {
            event->event.value = 180;
            event->response = EX_VALUE;
           }
           else
           {
            angle = event->event.value;
            status = MAraddeg(
             my_msg,
             &angle,
             &angle);

            if (angle > 179.999)
             angle = 180;

            if (angle < 0.0)
            {
             *was_valid_event = FALSE;
             key = EMS_I_00009;
            }
            else
             event->event.value = angle;
           }
          }
       }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 5 verification
 */
   case 5:
    switch (my_type)
     {
      case 22:
      case 23:
      case 24:
      case 25:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        if (event->response == EX_DATA)
         {
          status = BSdistncta(
            me->number_of_events_input,
            points,
            &loc_msg);
          if (status)
           *done = TRUE;
          else
           *was_valid_event = FALSE;
         } /* if (event->response == EX_DATA) */
        else if (use_default)
         {
          key = EMS_I_00006;
          *was_valid_event = FALSE;
         }
        else
         {
          IGRdouble	rho;

          rho = event->event.value;
          if ((rho > 0.0) && (rho < 1.0))
           *done = TRUE;
          else
           {
            key = EMS_I_00009;
            *was_valid_event = FALSE;
           }
         } /* ELSE FOR if (events->response == EX_DATA) */
       }
       break;
#ifndef IDRAW
      case 11:
      case 31:
       {
        IGRlong		loc_msg;
        IGRboolean	status;
        IGRdouble	radius, tolerance;

        *done = TRUE;
        if (event->response == EX_DATA)
         {
          IGRboolean	is_planar;
          IGRvector	plane_normal;

          BStst_plan(		/* Determine the plane formed by 0,1,2 */
            3,
            (IGRdouble *)points,
            NULL,
            &is_planar,
            plane_normal,
            &loc_msg);
           if ((loc_msg != BSSUCC) || (!is_planar))
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
          status = BSnor_to_pl(	/* Project pnt 4 onto this plane */
            &loc_msg,
            plane_normal,
            points[0],
            points[4],
            points[4]);
           if (!status)
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
          status = BSdistptli(	/* Compute the dist from proj pnt to line */
            &loc_msg,
            points[4],
            points[0],
            points[1],
            &radius);
           if (!status)
            {
             *my_msg = MSFAIL;
             goto wrapup;
            }
         } /* if (event->response == EX_DATA) */
        else if (use_default)
         radius = 0;
        else
         radius = event->event.value;
        status = BSEXTRACTPAR(
         &loc_msg,
         BSTOLLENVEC,
         tolerance);
        if (radius < tolerance) radius = 0.0;
        event->response = EX_VALUE;
        event->event.value = radius;
       }
       break;
      case 15:
       *done = TRUE;
       break;
      case 16:
      case 17:
      case 18:
      case 48:
       if (use_default)
        {
         key = EMS_I_00006;
         *was_valid_event = FALSE;
        }
       else
        {
         IGRboolean	status;
         IGRlong	loc_msg;
         IGRdouble	tolerance;

         status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
         if (event->event.value < tolerance)
          {
           if ((my_type == 48) ||
               (my_type == 115))
            {
             key = EMS_I_00009;
             *was_valid_event = FALSE;
            }
           else if (( ( my_type == 16) || (my_type == 17) || (my_type == 18) )
                     && event->response == EX_DATA ) {
                ;
           } else
            event->event.value = 0.0;
          }
        }
       break;




      case 42:
      case 115:
/*     noop; */
       break;
      case 34:
       sts = EFpoint_on_object(
         &me->events[3].located_object[0],
         event,
         my_id,
         my_msg);
       break;
      case 36:
       {
        IGRboolean	status;
        IGRlong		loc_msg;
        IGRdouble	tolerance, radius;

        if (use_default)
         {
          event->response = EX_VALUE;
          event->event.value = me->events[3].event.value;
         }
        status = BSEXTRACTPAR(
         &loc_msg,
         BSTOLLENVEC,
         tolerance);
        radius = event->event.value;
        if (radius < tolerance)
         {
          if (me->events[3].event.value != 0.0)
           event->event.value = 0.0;
          else
           {
            key = EMS_I_00009;
            *was_valid_event = FALSE;
           }
         }
       }
       break;
      case 38:
      case 39:
       {
        IGRdouble	start_angle;

        if (use_default)
         start_angle = 0.0;
        else
         {
          IGRboolean	status;

          start_angle = event->event.value;
          status = MAraddeg(
           my_msg,
           &start_angle,
           &start_angle);
         }
        *done = TRUE;
        event->response = EX_VALUE;
        event->event.value = start_angle;
       }
       break;
      case 46:
       {
        IGRlong		option;

        if (use_default)
         option = 4;
        else
         option = event->event.value;
        switch (option)
         {
          case 1:
          case 2:
          case 3:
          case 4:
           option -= 1;
           event->event.value = option;
           break;
          default:
           *was_valid_event = FALSE;
           key = EMS_I_00009;
           break;
         } /* switch (option) */
       }
       break;
      case 47:
       event->located_object[0].geom_parms.polygon_inx = TRUE;
       break;
      case 52:
       sts = EFpoint_on_object(
         &me->events[0].located_object[0],
         event,
         my_id,
         my_msg);
       *done = TRUE;
       break;

      case 202:
      {
       if (use_default)
       {
        event->event.value = 10;
        event->response = EX_VALUE;
       }
       if (event->event.value < 0)
       {
         *was_valid_event = FALSE;
         key = EMS_I_00009;
       }
       else
        *done = TRUE;
      }
      break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 6 verification
 */
   case 6:
    switch (my_type)
     {
#ifndef IDRAW
      case 16:
      case 17:
      case 18:
      case 42:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[4],
          points[5]);
         if (!status)
          *was_valid_event = FALSE;
         else
          {
           switch (my_type)
            {
             case 16:
              *done = TRUE;
              break;
             default:
              break;
            } /* switch (my_type) */
          } /* ELSE FOR if (!status) */
       }
       break;
      case 34:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[4],
          points[5]);
        if (status)
         *done = TRUE;
        else
         *was_valid_event = FALSE;
       }
       break;
      case 36:
        break; /* do nothing, fix for TR#92n1937 */
      case 48:

   if( (me->events[4].event.value == me->events[5].event.value) || use_default)
        {
         me->event.subtype = GRst_DEFAULT;
         me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
         sts = om$send(
           msg = message ECconstruct.add_event(FALSE),
           targetid = my_id);
         sts = om$send(
           msg = message ECconstruct.add_event(FALSE),
           targetid = my_id);
         me->events[5].response = EX_MAX_RESPONSE; /* Put dummy on queue */
         *done = TRUE; 
        }
       break;

      case 115:
       if (use_default)
        {
         key = EMS_I_00006;
         *was_valid_event = FALSE;
        }
       else
        {
         IGRboolean	status;
         IGRlong	loc_msg;
         IGRdouble	tolerance;

         status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
         if (event->event.value < tolerance)
          {
           if ((my_type == 48) ||
               (my_type == 115))
            {
             key = EMS_I_00009;
             *was_valid_event = FALSE;
            }
           else
            event->event.value = 0.0;
          }
        }
       break;


      case 46:
/*     noop; */
       break;
      case 47:
       sts = EFfind_closest_side(
         &me->events[4].located_object[0],
         event,
         my_id,
         my_msg);
        if (! (1 & sts)) return(OM_E_ABORT);
       break;
#endif

      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 7 verification
 */
   case 7:
    switch (my_type)
     {
#ifndef IDRAW
      case 17:
      case 18:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BScollin(
          &loc_msg,
          points[4],
          points[5],
          points[6]);
         if (status)
          *was_valid_event = FALSE;
         else
          {
           switch (my_type)
            {
             case 17:
              *done = TRUE;
              break;
             default:
              break;
            } /* switch (my_type) */
          } /* ELSE FOR if (status) */
       }
       break;
      case 36:
       if (use_default)
        {
         key = EMS_I_00006;
         *was_valid_event = FALSE;
        }
       else
        {
         IGRlong	number_of_pitches;

         number_of_pitches = event->event.value;
         if (number_of_pitches < 1)
          {
           *was_valid_event = FALSE;
           key = EMS_I_00009;
          }
        }
       break;
      case 42:
       *done = TRUE;
      break;
      case 46:
       {
        struct		GRlc_info *loc_info;
        struct		GRid *id;
        struct		GRmdenv_info *mdenv_info;

        loc_info = &event->located_object[0];
        id = &loc_info->located_obj;
        mdenv_info = &loc_info->module_info.md_env;
        loc_info->geom_parms.polygon_inx = FALSE;	/* Not reversed */
        sts = om$send(
          msg = message GRcurve.GRendpts(
           my_msg,
           &mdenv_info->matrix_type,
           mdenv_info->matrix,
           loc_info->proj_pnt,				/* 1st end point */
           &event->located_object[1].proj_pnt[0]),	/* 2nd end point */
          targetid = id->objid,
          targetos = id->osnum);
         if (! (1 & sts)) goto wrapup;
       }
       break;
      case 47:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[4],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 48:
       break;
      case 115:
       if (event->response != EX_DATA)
        {
         me->event.subtype = GRst_DEFAULT;
         me->event.response = EX_MAX_RESPONSE; /* Put dummy on queue */
         sts = om$send(
           msg = message ECconstruct.add_event(FALSE),
           targetid = my_id);
        }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 8 verification
 */
   case 8:
    switch (my_type)
     {
#ifndef IDRAW
      case 18:
       {
        IGRboolean	status;
        IGRlong		loc_msg;

        status = BSdistnct2(
          &loc_msg,
          points[6],
          points[7]);
         if (!status)
          *was_valid_event = FALSE;
         else
          *done = TRUE;
       }
       break;
      case 36:
       {
        IGRboolean	*ccw;

        ccw = &event->located_object[0].geom_parms.polygon_inx;
        if (use_default ||
            (event->event.keyin[0] == 'Y') ||
            (event->event.keyin[0] == 'y'))
         *ccw = TRUE;
        else if ((event->event.keyin[0] == 'N') ||
                 (event->event.keyin[0] == 'n'))
         *ccw = FALSE;
        else
         {
          *was_valid_event = FALSE;
          key = EMS_I_00005;
         }
        if (*was_valid_event) *done = TRUE;
       }
       break;
      case 46:
       if (event->response != EX_DATA)		/* Toggle direction? */
        {
         me->number_of_events_input--;
         sts = EFpatch_the_display_for_normals(
           &me->events[6],
           my_id);
          if (! (1 & sts)) goto wrapup;
         me->number_of_events_input++;
        }
       break;
      case 47:
        *done = TRUE;
       break;
      case 48:
       if(event->response == EX_DATA)
         *done=TRUE;
       break;
      case 115:
       if (use_default)
        {
         event->response = EX_VALUE;
         event->event.value = me->events[5].event.value;
        }
       else
        {
         IGRboolean	status;
         IGRlong	loc_msg;
         IGRdouble	tolerance;

         status = BSEXTRACTPAR(
           &loc_msg,
           BSTOLLENVEC,
           tolerance);
         if (event->event.value < tolerance)
          event->event.value = 0.0;
        }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 9 verification
 */
   case 9:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
/*     noop; */
       break;
      case 48:
      case 115:
       {
        IGRdouble	rho;

        if (use_default)
         rho = .41421356237309504880;	/* sqrt(2.0) - 1.0 */
        else
         {
          rho = event->event.value;
          if ((rho < 0.0) || (rho >= 1.0))
           {
            key = EMS_I_00009;
            *was_valid_event = FALSE;
           }
         }
        if (*was_valid_event)
         {
          event->event.value = rho;
          *done = TRUE;
         }
       }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 10 verification
 */
   case 10:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
       {
        IGRlong		option;

        if (use_default)
         option = 4;
        else
         option = event->event.value;
        switch (option)
         {
          case 1:
          case 2:
          case 3:
          case 4:
           option -= 1;
           event->event.value = option;
           *done = TRUE;
           break;
          default:
           *was_valid_event = FALSE;
           key = EMS_I_00009;
           break;
         } /* switch (option) */
       }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
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

 if( (my_type == 203) && (save_num_events > 4))
  me->number_of_events_input = save_num_events;

 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECconstruct;
