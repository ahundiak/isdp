/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs the dynamics for the
 following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Place solid box by two points		1
	Place box by four points		2
	Place solid box by four points		3
	Place cone by axis and radii		4
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
	Place curve by poles - points		53
	Place surface of projection		83
	Place solid of projection		84
	Intersect elements			85
	Place conic by linestring		93
	Place plane normal to curve		94
						--
	Place solid by offsetting surface	109
						--
        Create wireframe model			112
        Place parting lines as curves			113
						--
        Place fillet surface with auto trim	115
        Place parting lines as features		201
	Display isophotes                       202
	Place angular parting surface		203
 Notes

 This routine may only be called after the events have been
 verified as it assumes that they are valid.  It also accesses
 information deposited in other event fields by the verify function.

 Bugs

 At times, the dynamics is performed about a point which is not
 the "current point", e.g. a "dx" keyin would not be taken relative
 to this point.  This must seem really stupid to the user but
 correcting it is a bitch.

 Place blend between 2 curves should have better dynamics indicating
 which direction the blend will proceed in.  I should rubberband an
 arrow which lies along the tangent vector of the curve at the blend
 point.

 Place surface of revolution could have better dynamics of the axis
 by restricting the line to the plane of the curve.

 History

 10/28/87 : rlw : The beginning
 01/04/88 : rlw : Added some commands
 01/08/88 : rlw : Modified dynamics for projection vector
 01/15/88 : rlw : Modified dynamics for surface/solid of projection
 03/22/88 : rlw : Added place conic by linestring command and
                  place plane normal to curve command.
 05/30/88 : rlw : Modified fillet surface to support variable radius.
 06/29/88 : rlw : Added place blending surface command
 07/04/88 : rlw : Added place reduced fit curve
 07/12/88 : rlw : Added Place solid by offsetting surface command
 07/28/88 : rlw : Removed Place plane encompassing planar element logic as
                  it's in ECautoplanei.I
 08/01/88 : rlw : Added Create wireframe model command, note that this
                  was originally witten by Sunit on 01/21/88.
                  Added Place parting lines command.
 08/05/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
 08/29/88 : rlw : Added additional question for sweep direction of helix.
 09/02/88 : rlw : Added fillet with auto trim
 12/01/88 : rlw : Moved the place blending surface (105) command to a
                  separate class due to changes in the command.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 08/16/89 : pp  : Modified the project curve onto surface command to
                  let the user identify an infinite plane and to support
                  sets for curves.
 21_Sep-89: SM  : For Place angular parting surface just exit.
 02-Aug-90:ashok: Added/Modified conditional compilation statements to
		  include commands "conic by ......" (23, 24 and 25) in the
		  MDS(I/DRAW) product.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.

 Tapadia 03/25/92 Commented case 84 as it's overriden (ECplsolproj.I)
 03/19/93: sam  : code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I. --sampath

*/

class implementation ECconstruct;


%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE macro */
#define MAX_POINTS 20

method perform_dynamics()

{
 extern		void EFextract_points();
 extern		IGRlong EFrblineseg();
#ifndef IDRAW
 extern		IGRlong EFdylineseg(), EFdybox2pt();
 extern		IGRlong EFdyboxface(), EFdynormal(), EFdyparallel();
 extern		IGRlong EFdywegface(), EFdyboxdepth(), EFdy2normal();
 extern		IGRlong EFdywegdepth(), EFdyvector(), EFdypt5_5f6v();
 extern		IGRlong EFdypt5_6f7v(), EFdypt5_6f8v(), EFdypt6_6f7v();
 extern		IGRlong EFdypt6_6f8v(), EFdypt7_6f8v();
#endif
 IGRboolean	use_default;
 IGRlong	number_of_points, my_type;
 IGRpoint	points[MAX_POINTS];
 struct		IGRdisplay *my_display;
/*
 * Compiler optimizations
 */
 my_type = me->mytype;
 my_display = &me->display;
/*
 * Initialize - note that I have made the assumption that
 * the maximum case # will not exceed MAX_POINTS.
 */
 me->msg = MSSUCC;
 use_default = FALSE;
 if(my_type == 203) goto wrapup;

 if (me->number_of_events_input < MAX_POINTS)
  {
   EFextract_points(
    me->number_of_events_input,
    me->events,
    points);
  }
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 dynamics
 */
   case 1:
    switch (my_type)
     {
#ifndef IDRAW
      case 1:
       EFdybox2pt(
        points,
        my_display);
       break;
#endif
      case 32:
      case 33:
      case 34:
      case 37:
      case 38:
      case 39:
      case 40:
      case 41:
      case 43:
      case 44:
      case 45:   /* code is moved to src_testco/imp/ECcsoffseti.I */
      case 46:
      case 47:
      case 48:
      case 49:
      case 50:
      case 52:
      case 83:
/*
      case 84:
*/
      case 85:
      case 94:
      case 109:
      case 113:
      case 115:
      case 201:
      case 202:
/*     noop; */
       break;
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 2 dynamics
 */
   case 2:
    switch (my_type)
     {
#ifndef IDRAW
      case  2:
      case  3:
      case 19:
       EFdyboxface(
        points[0],
        points[1],
        my_display);
       break;
      case 4:
      case 5:
      case 6:
      case 7:
       EFdynormal(
        points[0],
        points[1],
        my_display);
       break;
#endif
      case  8:
      case  9:
      case 12:
      case 22:
      case 28:
      case 32:
      case 33:
      case 37:
      case 43:
      case 44:
      case 45:   /* code is moved to src_testco/imp/ECcsoffseti.I */
      case 46:
      case 47:
      case 48:
      case 49:
      case 50:
      case 52:
      case 83:
/*
      case 84:
*/
      case 94:
      case 109:
      case 115:
      case 202:
/*     noop; */
       break;
#ifndef IDRAW
      case 10:
      case 11:
      case 13:
      case 29:
      case 30:
      case 31:
      case 36:
       EFdynormal(
        points[1],
        points[0],
        my_display);
       break;
      case 14:
       EFdylineseg(
        2,
        points[0],
        points[1],
        NULL,
        NULL,
        my_display);
       break;
      case 20:
       EFdyparallel(
        points[0],
        points[1],
        my_display);
       break;
      case 21:
       EFdywegface(
        points[0],
        points[1],
        my_display);
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 3 dynamics
 */
   case 3:
    switch (my_type)
     {
#ifndef IDRAW
      case 2:
      case 3:
       EFdyboxdepth(
        points[0],
        points[1],
        points[2],
        my_display);
       break;
      case  4:
      case  5:
       EFdynormal(
        points[1],
        points[0],
        my_display);
       break;
      case 10:
      case 11:
      case 30:
      case 31:
       EFdy2normal(
        TRUE,
        points[0],
        points[1],
        points[2],
        my_display);
       break;
      case 14:
       EFdylineseg(
        3,
        points[0],
        points[1],
        points[2],
        NULL,
        my_display);
       break;
      case 15:
      case 16:
      case 17:
      case 18:
       EFdylineseg(
        2,
        points[0],
        points[2],
        NULL,
        NULL,
        my_display);
       break;
      case 21:
       EFdywegdepth(
        points[0],
        points[1],
        points[2],
        my_display);
       break;
#endif
      case 23:
       EFrblineseg(
        points[0],
        my_display);
       break;
      case 33:    /* Moved out from below for MDS - Inasu, Sept 5,1990 */ 
       break;
#ifndef IDRAW   /* added 02/aug/90 to include case 23 & 24 in MDS -ashok */
      case 32:
      case 34:
      case 36:
      case 37:
      case 38:
      case 39:
      case 41:
      case 42:
      case 44:
      case 48:
      case 49:
      case 50:
      case 52:
      case 94:
      case 115:
      case 202:
/*     noop; */
       break;
      case 46:
       {
        IGRboolean	reverse_curve;
        IGRdouble	*endpoint;
        struct		GRlc_info *lc_info;

        lc_info = &me->events[1].located_object[0];
        reverse_curve = lc_info->geom_parms.polygon_inx;
        if (reverse_curve)
         endpoint = &me->events[1].located_object[1].proj_pnt[0];
        else
         endpoint = &lc_info->proj_pnt[0];
        EFrblineseg(
         endpoint,
         my_display);
       }
       break;
      case 47:
       EFrblineseg(
        points[1],
        my_display);
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	have_plane, is_ortho;
        IGRvector	*normal;

        have_plane = me->events[0].located_object[0].geom_parms.polygon_inx;
        is_ortho = me->events[2].located_object[0].geom_parms.polygon_inx;
        normal = (IGRvector *)&me->events[0].located_object[1].proj_pnt[0];
        if (have_plane &&
            is_ortho)
         EFdyvector(
          normal,
          points[1],
          points[2],
          my_display);
        else
         EFrblineseg(
          points[1],
          my_display);
       }
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 4 dynamics
 */
   case 4:
    switch (my_type)
     {
#ifndef IDRAW
      case 11:
      case 31:
       EFdy2normal(
        FALSE,
        points[0],
        points[1],
        points[3],
        my_display);
       break;
      case 15:
       EFdylineseg(
        4,
        points[0],
        points[1],
        points[2],
        points[3],
        my_display);
       break;
      case 16:
       EFdypt5_5f6v(
        points[0],
        points[1],
        points[2],
        points[3],
        my_display);
       break;
      case 17:
       EFdypt5_6f7v(
        points[0],
        points[1],
        points[2],
        points[3],
        my_display);
       break;
      case 18:
       EFdypt5_6f8v(
        points[0],
        points[1],
        points[2],
        points[3],
        my_display);
       break;
#endif
      case 22:
      case 34:
      case 36:
      case 38:
      case 39:
      case 42:
      case 46:
      case 47:
      case 48:
      case 115:
      case 202:
/*     noop; */
       break;
/* #ifndef IDRAW  commented 02/aug/90 and moved below -ashok */
      case 23:
       EFrblineseg(
        points[2],
        my_display);
       break;
      case 24:
       EFrblineseg(
        points[0],
        my_display);
       break;
#ifndef IDRAW  /* added 02/aug/90 */
      case 52:
       EFrblineseg(
        points[1],
        my_display);
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 5 dynamics
 */
   case 5:
    switch (my_type)
     {
#ifndef IDRAW
      case 16:
       EFdylineseg(
        3,
        points[2],
        points[3],
        points[4],
        NULL,
        my_display);
       break;
      case 17:
       EFdypt6_6f7v(
        points[1],
        points[2],
        points[4],
        my_display);
       break;
      case 18:
       EFdypt6_6f8v(
        points[0],
        points[1],
        points[2],
        points[3],
        points[4],
        my_display);
       break;
      case 36:
      case 46:
      case 47:
      case 48:
      case 115:
      case 202:
/*     noop; */
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 6 dynamics
 */
   case 6:
    switch (my_type)
     {
#ifndef IDRAW
      case 17:
       EFdylineseg(
        3,
        points[2],
        points[4],
        points[5],
        NULL,
        my_display);
       break;
      case 18:
       EFdypt7_6f8v(
        points[2],
        points[3],
        points[4],
        points[5],
        my_display);
       break;
      case 36:
      case 42:
      case 46:
      case 47:
      case 48:
      case 115:
/*     noop; */
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 7 dynamics
 */
   case 7:
    switch (my_type)
     {
#ifndef IDRAW
      case 18:
       EFdylineseg(
        3,
        points[3],
        points[4],
        points[6],
        NULL,
        my_display);
       break;
      case 36:
      case 42:
      case 46:
      case 48:
      case 115:
/*     noop; */
       break;
      case 47:
       EFrblineseg(
        points[5],
        my_display);
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 8 dynamics
 */
   case 8:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
       {
        IGRboolean	reverse_curve;
        IGRdouble	*endpoint;
        struct		GRlc_info *lc_info;

        lc_info = &me->events[6].located_object[0];
        reverse_curve = lc_info->geom_parms.polygon_inx;
        if (reverse_curve)
         endpoint = &me->events[6].located_object[1].proj_pnt[0];
        else
         endpoint = &lc_info->proj_pnt[0];
        EFrblineseg(
         endpoint,
         my_display);
       }
       break;
      case 48:
      case 115:
/*     noop; */
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 9 dynamics
 */
   case 9:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
/*     noop; */
       break;
#endif
      default:
       use_default = TRUE;
       break;
     } /* switch (my_type) */
    break;
/*
 * Just do line rubber banding off of the last point
 */
   default:
    use_default = TRUE;
    break;
  } /* switch (me->number_of_events_input) */
/*
 * Default processing
 */
 if (use_default)
  {
   EFrblineseg(
    &me->events[me->number_of_events_input - 1].event.button.x,
    my_display);
  }
/*
 * eof
 */
wrapup:
 if (1 & me->msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECconstruct;
