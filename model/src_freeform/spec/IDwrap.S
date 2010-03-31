class specification IDwrap (1:0) of ECelement;

/*
Abstract
	This command wraps 3d planar vector data (wire frame) onto a
	cynlider, cone or sphere.

Algorithm
	Find a bounding rectangular box enclosing the wire frame.
	Convert the wire frame to a list of polyline strings. Then
	map end points of each segment onto the surface. Finally
	stroke out points between the end points of each segment.

History
	12/29/91	JSY	Design and coding.
	03/05/92	JSY	Add code to wrap graphic group.
*/
#include "grio.h"
#include "lc.h"
#include "igrtypedef.h"
#include "OMtypes.h"
#include "igr.h"
#include "dpstruct.h"
#include "bsgeom_cvsf.h"

/* the following structure is used for store the rectangle which
   encloses the input planar element. The rectangle's length is
   in the direction which is perpendicular to the axis of rotation
   of the conical surface
   h_vec: the length direction; v_vec: the height direction;
   min_pt, max_pt: minimum and maximum points along h_vec;
   min_v_pt, max_v_pt: minimum and maximum points along v_vec;
   rect_len, rect_hgt: length and height of the rectangle;
   rect_pts: points define the rectangle;
   rect_ln: polyline with rect_pts as points;
 */
struct ele_rect
{
  IGRpoint min_pt, max_pt, min_v_pt, max_v_pt;
  IGRvector h_vec, v_vec;
  IGRdouble rect_len, rect_hgt;
  IGRpoint rect_pts[5];
  struct IGRpolyline rect_ln;
};

/* define a new structure used to dynamically display a circular box
   with the cursor and the rule line at the cursor. We need 7 display
   buffers. header[0]: the rule line at the cursor; header[1-4]: the
   moving box; header[5-6]: used to display circles when the box has
   overlapping  */
struct DPquad_surf
{
  struct BSgeom_bsp_surf *quad_surf;
  struct DPele_header header[7];
  IGRpoint int_pt, p1, p2, cnt1, cnt2;
  IGRvector tang_vec, x_axis1, y_axis1, x_axis2, y_axis2;
  IGRdouble len1, len2, pt_buf[6], int_uv, uv1, width1, width2, unit_pts;
  IGRshort u_or_v;
  IGRboolean which, reverse;
  IGRlong rc;
};

/* ------------------------------------------------ */
/* INSTANCE DATA                                    */
/* ------------------------------------------------ */

instance IDwrap
{
  uword	gd_os;
  OM_S_OBJID gd_id;
  struct GRlc_info lc_surf;
  struct BSgeom_bsp_surf quad_surf;
  struct DPquad_surf dp_surf;
  IGRshort u_or_v, arc_type;
  IGRlong unit_pts;
  struct ele_rect rect;
  struct GRsymbology ele_symb, surf_symb;
  IGRvector tang_vec;
  IGRboolean reverse;
  IGRdouble z_dis, width, arc_len, wrap_angle;
  IGRpoint start_pt, end_pt;
  IGRdouble start_uv, start_ln[6], end_uv, end_ln[6];
  IGRint num_poly_ln;
  struct IGRpolyline *poly_lns;
};

override execute, init, wakeup;

message init_surf_geom( IGRlong *rc;
		        struct GRlc_info *surf;
		        struct BSgeom_bsp_surf *quad_surf;
		        IGRshort *u_or_v );
/*
Abstract

    Given a conical surface. This method initialize a data structure
    BSgeom_bsp_surf which will be used by BSP math routines for line
    and surface intersection.

Arguments

    (I) surf		the conical surface. It can be cone, cylinder
			or sphere
    (O) quad_surf	the initialized BSgeom_bsp_surf structure
    (O) u_or_v		used for cylinder or cone. 1: when u is the
    			height direction (line ) and v is in the base
			direction (circular); 2: otherwise
    (O) rc		return code: BSSUCC: successful; BSNULL: fail

Return

    OM_S_SUCCESS
*/

message get_polyline( IGRlong *rc;
		      struct GRlc_info *element;
		      uword gd_os;
		      OM_S_OBJID gd_id;
		      struct IGRdisplay *disp;
		      IGRint *num_poly_ln;
		      struct IGRpolyline **poly_lns );
/*
Abstract:

    Given a planar wire frame element. This method returns a list of
    polylines corresponding to the element. Element can be a line string,
    a polygon, a text or a b-spline curve.

Arguments

    (I) element		the planar object located
    (I) gd_os		the window space #; this is used when element is text
    (I) gd_id		the object id of the gradad; used when element is text
    (I) disp		the active display
    (O) num_poly_lns	number of polylines for the element
    (O) poly_lns        the list of polylines
    (O) rc		return code: TRUE: successful; FALSE: fail

Return

    OM_S_SUCCESS

Notes

    space to store the polylines is allocated inside the method
*/

message disp_iso_cv( IGRlong *rc;
		     struct BSgeom_bsp_surf *quad_surf;
		     IGRdouble uv_par;
		     IGRshort u_or_v;
		     struct IGRdisplay *disp;
		     IGRboolean draw );
/*
Abstract:

    This method displays or erases a rule line on the conical surface.

Arguments

    (I) quad_surf	the surface
    (I) uv_par		the u parameter or v parameter. For cylinder or cone,
			this should be a u parameter. But for sphere, this is
			a v parameter.
    (I) u_or_v		if surface is cylinder, partial cylinder or cone,
    			partial cone, u_or_v == 1 means constant u parameter
			is a rule line (line); u_or_v == 2 means constant v
			parameter is a rule line
    (I) disp		the display
    (I) draw	        TRUE: draw; FALSE: erase
    (O) rc		return code: return code from internal function or
			method call

Return

    OM_S_SUCCESS
*/

message disp_tang_vec( IGRlong *rc;
		       struct GRlc_info *lc_surf;
		       IGRpoint pt;
		       IGRvector vec;
		       struct IGRdisplay *disp;
		       IGRboolean draw );
/*
Abstract:

    This method displays or erases a tangent vector on a surface.

Arguments

    (I) lc_surf		the surface
    (I) pt		the point on the surface
    (I) vec		the tangent vector of the surface at the point
    (I)	disp		the display
    (I) draw	        TRUE: draw; FALSE: erase
    (O) rc		return code: return value from EFdraw_vector_on_screen

Return

    OM_S_SUCCESS
*/

message cnst_ele_rect( IGRlong *rc;
		       struct GRlc_info *element;
		       IGRvector rot_axis;
		       struct ele_rect *rect );
/*
Abstract:

    This method construct a rectangle that encloses the input list of
    input polylines. The rectangle's horizontal direction is perpendicular
    to input axis of rotation.

Arguments

    (I) element		input planar element
    (I) rot_axis	the axis to which the horizontal direction of the
    			rectangle will be perpendicular
    (O) rect		the output rectangle
    (O) rc		return code: BSSUCC: successful; BSFAIL: fail

Return

    OM_S_SUCCESS
*/

message disp_ele_rect( IGRlong *rc;
		       struct GRlc_info *element;
		       struct ele_rect *rect;
		       struct IGRdisplay *disp;
		       IGRboolean draw;
		       IGRboolean show_tang );
/*
Abstract:

    This method displays or erases a rectangle that encloses an input
    planar element (stored in rect->rect_ln) and also shows or erases
    a direction vector on the rectangle

Arguments

    (I) element		the input planar element
    (I) rect		the computed rectangle is store in rect->rect_ln
    			(see definition of struct ele_rect above)
    (I)	disp		the display
    (I) draw	        TRUE: draw; FALSE: erase
    (I) show_tang	TRUE: show the tangent vector; FALSE: erase
    (O) rc		return code: return value from IDwrap.disp_tang_vec
    			or TRUE

Return

    OM_S_SUCCESS
*/

message comp_wrap_angle( IGRlong *rc;
			 IGRshort type;
			 IGRdouble arc_len;
			 IGRvector tang_vec;
		         IGRdouble *wrap_angle );
/*
Abstract:

    This method compute the wrapping angle on the conical surface

Arguments

    (I) type		TWO_RULE_LNS: input via two rule lines (graphic)
			DISTANCE: input via a starting point and distance
			note: distance is considered to be measured at the
			starting point (cursor). The starting point will
			be mapped to a point which is at the middle of the
			element	height
    (I) arc_len		the distance. In case of TWO_RULE_LNS, this is
   			ignored
    (I)	tang_vec	the tangent vector at the starting point
    (O) wrap_angle	the wrapping angle on the surface staring in
     			tang_vec direction
    (O) rc		return code: TRUE

Return

    OM_S_SUCCESS

Note

    This is a private method. The starting point and u, v parameters are
    instance variables of the class
*/

message map_to_sf( IGRlong *rc;
		   struct ele_rect *rect;
		   IGRdouble wrap_angle;
		   IGRdouble width;
		   IGRdouble z_dis;
		   IGRvector x_axis, y_axis;
		   IGRint rot_sign;
		   IGRpoint pt;
		   IGRpoint new_cnt;
		   IGRpoint new_pt;
		   IGRdouble *rot_angle );
/*
Abstract:

    This maps a point of the planar element to a point on the conical
    surface

Arguments

    (I) rect		the rectangle which encloses the element
    			(see struct ele_rect)
    (I) wrap_angle	the wrapping angle on the conical surface
    (I) width		the width on the rotation axis of wrapped element
    (I) z_dis		the starting altitude on the rotation axis for
    			wrapping
    (I) x_axis, y_axis	the coordinate system for rotating point on the
    			conical surface
    (I) rot_sign	1: rotation is counterclockwise; -1: clockwise
    (I)	pt	        the point to be wrapped
    (O) wrap_angle	the wrapping angle on the surface staring in
     			tang_vec direction
    (O) new_cnt		center of the circle of rotation, this center is
    			on the rotation axis
    (O) new_pt		the mapped surface point
    (O) rot_angle	the actual angle being rotated
    (O) rc		return code: TRUE

Return

    OM_S_SUCCESS

Note

    This is a private method. The conical surface is an instance variable
    of the class
*/

message wrap_sf( IGRlong *rc;
		 struct ele_rect *rect;
	         IGRdouble wrap_angle;
		 IGRdouble width;
		 IGRdouble z_dis;
	         IGRvector tang_vec;
	         struct IGRdisplay *disp;
		 IGRshort level );
/*
Abstract:

    This method wraps a planar element onto a conical surface.
    A planar element is defined as planar polyline, polygon, b-spline
    curve and text. A conical surface is defined as cone, partial cone,
    cylinder, partial cylinder and sphere

Arguments

    (I) rect		the rectangle which encloses the element
    			(see struct ele_rect)
    (I) wrap_angle	the wrapping angle on the conical surface
    (I) width		the width on the rotation axis of wrapped element
    (I) z_dis		the starting altitude on the rotation axis for
    			wrapping
    (I) tang_vec	the tangent vector at the start wrapping rule line
    (I) disp		active display
    (I)	level		active level
    (O) rc		return code: TRUE: successful; FALSE: fail

Return

    OM_S_SUCCESS

Note

    This method has not been made public. Since the method uses some
    variables which are instance variables of the class
*/

end specification IDwrap;



