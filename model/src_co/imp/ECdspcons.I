/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method displays the construction lines for the
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
	Place plane encompassing planar element	35
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
						47
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
	Cross hatch				111
        Create wireframe model			112
        Place parting lines as curves		113
						--
        Place fillet surface with auto trim	115
        Place parting lines as features		201
	Place angular parting lines             202
        Place angular parting surface		203

 Notes

 This routine may only be called after the events have been
 verified as it assumes that they are valid.  It also accesses
 information deposited in other event fields by the verify function.

 I modified this routine such that displays/erases take place in an
 incremental fashion.  This is move efficent but creates a problem
 since total erasure is not performed before draws any longer.  This
 problem shows up in situations where a display at state i is effected
 by events occuring after state i, e.g. displaying normals for offset.
 I have attempted to solve this problem for normals but patching code
 into the verify method.

 History

 10/28/87 : rlw : The beginning
 12/09/87 : rlw : Reworked due to different interface
 01/04/88 : rlw : Added some commands
 01/15/88 : rlw : Modified due to changes in surface/solid of projection
 03/33/88 : rlw : Added place conic by linestring command and
                  place plane normal to curve command.
 05/30/88 : rlw : Modified fillet surface to support variable radius.
 06/29/88 : rlw : Added place blending surface command
 07/04/88 : rlw : Added place reduced fit curve command
 07/12/88 : rlw : Modified due to function name change in display iso curve
                  Added Place solid by offsetting surface command
                  Modified due to changes in place plane encompassing logic
 07/28/88 : rlw : Added Cross hatch command
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
 21-Sep-89: SM  : Added 'Place angular parting surface'.
 02-Aug-90:ashok: Added/Modified conditional compilation statements to
		  include commands "conic by ......" (23, 24 and 25) in the
		  MDS(I/DRAW) product.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.
 Tapadia 03/25/92 Commented case 84 as it's overriden (ECplsolproj.I)
 08-Jan-93:sampath: Added code to display offset surface direction .
 19-Mar-93:sampath: moved place offset surface (case 45) command object
		    to src_testco/imp/ECcsoffseti.I

 */

class implementation ECconstruct;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE macro */
#include "EMSifmacros.h"
#define MAX_POINTS 20

extern OMuword OPP_EMScompsurf_class_id;

from GRvg import GRgenabsg;

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)

{
 extern		void EFextract_points();
/* extern		IGRlong ECdisplayPointSetByBuffer();*/
#ifndef IDRAW
/* extern		IGRlong EFdisplay_surface_normal();
 extern		IGRlong EFdisplay_curve_normal_or_tangent();
 extern		IGRlong EFdisplay_iso_curve_of_a_surface();
*/
#endif
 IGRboolean	use_default;
 IGRlong	number_of_points, i, alpha, omega, *my_msg, my_type;
 IGRpoint	points[MAX_POINTS];
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
/*
 * Compiler optimizations
 */
 my_display = &me->display;
 my_display_env = &me->display_env;
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * Set up the loop indices
 */
 omega = me->number_of_events_input;
 if (!omega) goto wrapup;		/* Degenerate case */

 if (draw_single)
  alpha = omega;
 else
  alpha = 1;
/*
 * Enter the loop - Note that it is necessary to
 * reextract the points each time since they are
 * messed up in order to perform the display.
 */
 for (i = alpha; i <= omega; i++)
  {
   use_default = FALSE;
   number_of_points = 0;
   if (i < MAX_POINTS)
    {
     EFextract_points(
      i,				/* me->number_of_events_input */
      me->events,
      points);
    }
/*
 * Branch based on the command state
 */
   switch (i)
    {
/*
 * Event 1 construction lines
 */
     case 1:
      switch (my_type)
       {
        case 32:
        case 33:
        case 34:
        case 35:
        case 37:
        case 38:
        case 39:
        case 40:
        case 41:
        case 43:
        case 44:
        case 46:
        case 49:
        case 50:
        case 52:
        case 83:
/*
        case 84:
*/
        case 85:
        case 94:
        case 111:
        case 113:
        case 201:
	case 202:
	case 203:
/*       noop; */
         break;
#ifndef IDRAW
        case 45:
	{
          IGRboolean    natural_normal;
          IGRlong       sts;
          struct        GRlc_info *lc_info;
          GRobjid       tmpid;
          IGRchar       *generic_pointer;
          struct        GRid *id;
          struct        GRmdenv_info *mdenv_info;
          struct        IGRbsp_surface  *surface;
          IGRlong         msg;
          GRclassid     objclass;

          lc_info = &me->events[0].located_object[0];

        /* 
	   Store the objid of the Composite surface in 'tmpid' and assign
           the 'leaf_id' to the 'located_obj.objid'. This enables
           display of the surface normal. 
	*/
          tmpid = lc_info->located_obj.objid;

          lc_info->located_obj.objid = lc_info->geom_parms.leaf_id.objid;

          om$get_classid (objid = tmpid, osnum =lc_info->located_obj.osnum,
           p_classid = &objclass);
          if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMScompsurf_class_id) == OM_S_SUCCESS)
            {
             mdenv_info = &lc_info->module_info.md_env;
             id = &lc_info->located_obj;
             sts = om$send(
               msg = message GRvg.GRgenabsg(
               &msg,
               &mdenv_info->matrix_type,
               mdenv_info->matrix,
               &generic_pointer),
               senderid = my_id,
               targetid = id->objid,
               targetos = id->osnum);
             if (! (1 & sts)) goto wrapup;
             surface = (struct IGRbsp_surface *) generic_pointer;
         
     /*     
	    This indicates whether logical normal reverse of natural normal
            natural_normal = TRUE actually indicates that logical
                                  normal is reverse of nat. nor.
            Note: The flag 'natural_normal' should be read as
                           '(reverse_)natural_normal'
     */
             if(surface->pos_orient)
               natural_normal = TRUE;
             else
               natural_normal = FALSE;

     /*     
	     Now toggle the reverse flag (natural_normal) based on the
            'polygon_inx' value. 
     */

            if(!lc_info->geom_parms.polygon_inx)
               if(natural_normal)
                   natural_normal = FALSE;
               else
                   natural_normal = TRUE;
           }
          else
            natural_normal = lc_info->geom_parms.polygon_inx;

	  /***
          sts = EFdisplay_surface_normal(
           lc_info,
           natural_normal,
           my_id,
           draw_background,
           my_display_env,
           my_display,
           my_msg);
	  ***/
          sts = ems$display_surface_normal(
                            loc_info = lc_info,
                            natural_normal = natural_normal,
                            senderid = my_id,
                            draw_background = draw_background,
                            display_mdenv = my_display_env,
                            display = my_display,
                                msg = my_msg);   

         /* Restore the 'objid' of the located object. */
          lc_info->located_obj.objid = tmpid;

        }
        break;
        case 48:
        case 109:
        case 115:
         {
          IGRboolean	natural_normal;
          IGRlong	sts;
          struct	GRlc_info *lc_info;

          lc_info = &me->events[0].located_object[0];
          natural_normal = lc_info->geom_parms.polygon_inx;
/************************************************************************
          sts = EFdisplay_surface_normal(
           lc_info,
           natural_normal,
           my_id,
           draw_background,
           my_display_env,
           my_display,
           my_msg);
************************************************************************/
          sts = ems$display_surface_normal(
                            loc_info = lc_info,
                            natural_normal = natural_normal,
                            senderid = my_id,
                            draw_background = draw_background,
                            display_mdenv = my_display_env,
                            display = my_display,
                                msg = my_msg);   
         }
         break;
         case 42:
          if (me->events[0].response == EX_MAX_RESPONSE)
           number_of_points = 0;
          else
           number_of_points = 1;
          break;
#endif
        default:				/* 0 */
         number_of_points = 1;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 2 construction lines
 */
     case 2:
      switch (my_type)
       {      /* case 33  moved out from below for MDS -Inasu, Sept 5,1990 */
        case 33:
         number_of_points = 1;
         points[0][0] = points[1][0];
         points[0][1] = points[1][1];
         points[0][2] = points[1][2];
         break;
#ifndef IDRAW
        case 32:
        case 34:
        case 37:
        case 38:
        case 39:
        case 41:
        case 83:
/*
        case 84:
*/
	case 203:
         number_of_points = 1;
         points[0][0] = points[1][0];
         points[0][1] = points[1][1];
         points[0][2] = points[1][2];
         break;
        case 35:
        case 43:
        case 44:
        case 45:
        case 48:
        case 49:
        case 50:
        case 94:
        case 109:
        case 111:
        case 115:
	case 202:
/*       noop; */
         break;
        case 42:
         if (me->events[1].response == EX_MAX_RESPONSE)
          number_of_points = 0;
         else
          number_of_points = 2;
         break;
        case 46:
         {
          IGRboolean	is_curve_reversed;
          IGRlong	sts;
      /*    IGRlong       EFdisplay_curve_normal_or_tangent();*/
          struct	GRlc_info *lc_info;

          lc_info = &me->events[1].located_object[0];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		/* The curve */
            NULL,		/* Not used for tangents */
            FALSE,		/* Display the tangent vector */
            is_curve_reversed,
            my_id,
            draw_background ? GRbd : GRbe,
            my_display_env,
            my_display,
            my_msg);
         }
         break;
        case 52:
         {
          IGRboolean	use_u_curve;
          struct	GRlc_info *lc_info;

          lc_info = &me->events[0].located_object[0];
          use_u_curve = lc_info->geom_parms.polygon_inx;
          EFdisplay_iso_curve_of_a_surface(
           lc_info,
           my_display,
           my_display_env,
           use_u_curve,
           &me->events[1].located_object[0].geom_parms.u,
           draw_background,
           FALSE,			/* Don't wait */
           my_id,
           NULL,
           my_msg);
          number_of_points = 1;
          points[0][0] = points[1][0];
          points[0][1] = points[1][1];
          points[0][2] = points[1][2];
         }
         break;
#endif
        default:			/* 0 - 1 */
         number_of_points = 2;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 3 construction lines
 */
     case 3:
      switch (my_type)
       {
        case 33: /* moved out for MDS - Inasu, Sept 5, 1990 */
         break;
#ifndef IDRAW
        case  2:
        case  3:
         {
          IGRvector	*width_vector;	/* I am cheating here */

          width_vector  = (IGRvector *)&me->events[0].located_object[0].proj_pnt[0];
          number_of_points = 4;		/* 1 - new - 2 - 0 */
          points[3][0] = points[0][0];
          points[3][1] = points[0][1];
          points[3][2] = points[0][2];
          points[0][0] = points[1][0];
          points[0][1] = points[1][1];
          points[0][2] = points[1][2];
          points[1][0] = points[2][0] + width_vector[0][0];
          points[1][1] = points[2][1] + width_vector[0][1];
          points[1][2] = points[2][2] + width_vector[0][2];
         }
         break;
        case  4:
        case  5:
        case 35:
        case 46:
        case 44:
        case 49:
        case 50:
        case 52:
        case 83:
/*
        case 84:
*/
        case 94:
        case 111:
        case 202:
	case 203:
/*       noop; */
         break;
        case 42:
         if (me->events[2].response == EX_MAX_RESPONSE)
          number_of_points = 0;
         else
          use_default = TRUE;
         break;
#endif
        case  8:
        case  9:
        case 22:
        case 32:
        case 37:
         number_of_points = 1;			/* 2 */
         points[0][0] = points[2][0];
         points[0][1] = points[2][1];
         points[0][2] = points[2][2];
         break;
#ifndef IDRAW
        case 10:
        case 11:
        case 30:
        case 31:
        case 36:
         number_of_points = 2;		/* 0 - 2 */
         points[1][0] = points[2][0];
         points[1][1] = points[2][1];
         points[1][2] = points[2][2];
         break;
        case 14:
        case 21:
         number_of_points = 3;		/* 1 - 2 - 0 */
         points[3][0] = points[1][0];	/* 0 - 2 - 1 */
         points[3][1] = points[1][1];
         points[3][2] = points[1][2];
         points[1][0] = points[2][0];
         points[1][1] = points[2][1];
         points[1][2] = points[2][2];
         points[2][0] = points[3][0];
         points[2][1] = points[3][1];
         points[2][2] = points[3][2];
         break;
        case 48:
        case 115:
         {
          IGRboolean	natural_normal;
          IGRlong	sts;
          struct	GRlc_info *lc_info;

          lc_info = &me->events[2].located_object[0];
          natural_normal = lc_info->geom_parms.polygon_inx;
/*************************************************************************
          sts = EFdisplay_surface_normal(
           lc_info,
           natural_normal,
           my_id,
           draw_background,
           my_display_env,
           my_display,
           my_msg);
*************************************************************************/
          sts = ems$display_surface_normal(
                            loc_info = lc_info,
                            natural_normal = natural_normal,
                                  senderid = my_id, 
                                draw_background = draw_background,
                               display_mdenv = my_display_env,
                               display = my_display,
                                   msg = my_msg);  
         }
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 4 construction lines
 */
     case 4:
      switch (my_type)
       {
#ifndef IDRAW
        case 11:
        case 15:
        case 16:
        case 17:
        case 18:
	case 31:
#endif /* added to include type 23[A in MDS 02/aug/90 -ashok */
        case 23:
         points[1][0] = points[3][0];
         points[1][1] = points[3][1];
         points[1][2] = points[3][2];
         switch (my_type)
          {
#ifndef IDRAW /* added to include type 23 in MDS 02/aug/90 -ashok */
           case 11:
	   case 31:
#endif
           case 23:
            number_of_points = 2;		/* 0 - 3 */
            break;
           default:
            number_of_points = 3;		/* 0 - 3 - 2 */
            break;
          } /* switch (my_type) */
         break;
#ifndef IDRAW /* added to include type 23 in MDS 02/aug/90 -ashok */
        case 34:
        case 35:		/* Needed due to restart logic */
        case 36:
        case 38:
        case 39:
        case 42:
        case 48:
        case 52:
        case 111:		/* Needed due to restart logic */
        case 115:
	case 202:
	case 203:
/*       noop; */
         break;
        case 46:
         {
          IGRdouble	*point;
          struct	GRlc_info *lc_info;

          number_of_points = 2;		/* direction point to curve end */
          lc_info = &me->events[1].located_object[0];
          points[0][0] = points[3][0];
          points[0][1] = points[3][1];
          points[0][2] = points[3][2];
          if (lc_info->geom_parms.polygon_inx)		/* is reversed? */
           point = &me->events[1].located_object[1].proj_pnt[0];
          else
           point = &lc_info->proj_pnt[0];
          points[1][0] = point[0];
          points[1][1] = point[1];
          points[1][2] = point[2];
         }
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 5 construction lines
 */
     case 5:
      switch (my_type)
       {
#ifndef IDRAW
        case 16:
        case 17:
        case 18:
         points[1][0] = points[4][0];
         points[1][1] = points[4][1];
         points[1][2] = points[4][2];
         switch (my_type)
          {
           case 16:
            number_of_points = 3;		/* 0 - 4 - 1 */
            points[2][0] = points[1][0];
            points[2][1] = points[1][1];
            points[2][2] = points[1][2];
            break;
           case 17:
            number_of_points = 3;		/* 0 - 4 - 3 */
            points[2][0] = points[3][0];
            points[2][1] = points[3][1];
            points[2][2] = points[3][2];
            break;
           default:
            number_of_points = 2;		/* 0 - 4 */
            break;
          } /* switch (my_type) */
         break;
        case 34:
        case 42:
        case 48:
         break;
        case 115:
         number_of_points = 1;			/* 4 */
         points[0][0] = points[4][0];
         points[0][1] = points[4][1];
         points[0][2] = points[4][2];
         break;
        case 36:
        case 46:
	case 202:
	case 203:
/*       noop; */
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 6 construction lines
 */
     case 6:
      switch (my_type)
       {
#ifndef IDRAW
        case 17:
        case 18:
         number_of_points = 3;		/* 4 - 5 - 1 */
         points[2][0] = points[1][0];
         points[2][1] = points[1][1];
         points[2][2] = points[1][2];
         OM_BLOCK_MOVE(
          points[4],
          points[0],
          sizeof(IGRpoint) * 2);
         break;
        case 36:
        case 46:
        case 48:
        case 115:
	case 203:
/*       noop; */
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 7 construction lines
 */
     case 7:
      switch (my_type)
       {
#ifndef IDRAW
        case 18:
         number_of_points = 3;		/* 5 - 6 - 2 */
         OM_BLOCK_MOVE(
          points[5],
          points[0],
          sizeof(IGRpoint) * 2);
         break;
        case 36:
        case 42:
	case 203:
/*       noop; */
         break;
        case 46:
         {
          IGRboolean	is_curve_reversed;
          IGRlong	sts;
     /*     IGRlong       EFdisplay_curve_normal_or_tangent();*/
          struct	GRlc_info *lc_info;

          lc_info = &me->events[6].located_object[0];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		/* The curve */
            NULL,		/* Not used for tangents */
            FALSE,		/* Display the tangent vector */
            is_curve_reversed,
            my_id,
            draw_background ? GRbd : GRbe,
            my_display_env,
            my_display,
            my_msg);
         }
         break;
        case 48:
        case 115:
         if (me->events[6].response == EX_DATA)
          {
           number_of_points = 1;			/* 6 */
           points[0][0] = points[6][0];
           points[0][1] = points[6][1];
           points[0][2] = points[6][2];
          }
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 8 construction lines
 */
     case 8:
      switch (my_type)
       {
#ifndef IDRAW
        case 46:
        case 48:
         if (me->events[6].response == EX_DATA)
          {
           number_of_points = 1;			/* 6 */
           points[0][0] = points[7][0];
           points[0][1] = points[7][1];
           points[0][2] = points[7][2];
          }
         break;
        case 115:
	case 203:
/*       noop; */
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Event 9 construction lines
 */
     case 9:
      switch (my_type)
       {
#ifndef IDRAW
	case 203:
/*       noop; */
         break;
        case 46:
         {
          IGRdouble	*point;
          struct	GRlc_info *lc_info;

          number_of_points = 2;		/* direction point to curve end */
          lc_info = &me->events[6].located_object[0];
          points[0][0] = points[8][0];
          points[0][1] = points[8][1];
          points[0][2] = points[8][2];
          if (lc_info->geom_parms.polygon_inx)		/* is reversed? */
           point = &me->events[6].located_object[1].proj_pnt[0];
          else
           point = &lc_info->proj_pnt[0];
          points[1][0] = point[0];
          points[1][1] = point[1];
          points[1][2] = point[2];
         }
         break;
#endif
        default:
         use_default = TRUE;
         break;
       } /* switch (my_type) */
      break;
/*
 * Just connect the dots
 */
     default:
      switch(my_type)
       {
	case 203:
/*       noop; */
         break;
	
	default:
         use_default = TRUE;
	 break;
       }  /* switch (my_type) */
      break;

    } /* switch (i) */
/*
 * Display my constructions
 */
   if (use_default)
    {
     number_of_points = 2;
     OM_BLOCK_MOVE(
      &me->events[i - 1].event.button.x,
      points[0],
      sizeof(IGRpoint));
     OM_BLOCK_MOVE(
      &me->events[i - 2].event.button.x,
      points[1],
      sizeof(IGRpoint));
    } /* if (use_default) */
   if (number_of_points)
    {
     IGRlong	sts;
    /* IGRlong    ECdisplayPointSetByBuffer();*/

     sts = ECdisplayPointSetByBuffer(
       my_msg,
       *my_display,
       *my_display_env,
       my_id,
       number_of_points,
       points,
       draw_background);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
    } /* if (number_of_points) */
  } /* for (i = start; i <= end; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation ECconstruct;
