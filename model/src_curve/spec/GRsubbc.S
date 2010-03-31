/* ###################   APOGEE COMPILED   ################## */
class specification GRsubbc (1:0) of GRbspline;
/*
ABSTRACT

This is an abstract class which represents freeform bspline
curves.  It does most of the work on these curves except for
posting to the database and generating abstract geometry.

In order to be a subclass of this class the following
requirements must be met:

1) The curve must be representable as a single bspline curve
2) The parameter of the curve must range from 0 to 1, i.e.
    curve->knots[curve->order] = 0.0
    curve->knots[curve->num_poles] = 1.0

HISTORY

kmo 03/24/86 :  Initial creation
rlw 03/30/87 :  Totally redone -
                1) Removed class GRgenbc and GRextbc
                2) Removed methods of class GRextbc
                3) Removed EMmkactive, EMactivecurve,
                    EMcurve_range, EMmkcbymsg, EMmkovflow methods
rlw 05/17/87 :  Removed point project override.  It was
                only overriden before due to boundaries.
rlw 05/19/87 :  Moved merge curve message from class GRcurve to
                this class.  Also changed it to a construction
                method.
dhm 08/18/87 :  Overrode GRkeypoint.
jbk 08/24/87 :  Removed GRdisyourself override which dhm
                erroneously slipped back into this file.
SM  09-17-87 :  Removed override of GRformatele.
rlw 11/17/87 :  Reworked EMgenConicBy5inputs and documented.
                Combined EMgenRhoConic into the 5 input method.
rlw 11/20/87 :  Added EMplace_helix() method.
rlw 12/16/87 :  Reworked and renamed place curve by poles, direct fit, 
                least squares fit, and convex fit methods.  Removed
                the following methods: EMnormknot(), EMcvinit(),
                EMputbcdef(), EMmkcybcrv(), EMmkcybpts(), EMpcurve(),
                EMlsqcur(), EMfitcur(), EMfitcnvpts().  Removed
                ovveride on GRdelvertex() method.
rlw 12/29/87 :  Moved increase order, change order, insert knot,
                and insert pole messages to here and reworked them.
rlw 01/06/88 :  Moved align method down from GRbspline to here, renamed
                it, and reworked it.
rlw 03/22/88 :  Added a conic by linestring method in order to better
                support detailing and NC.
dhm 05/16/88 :  Added override of GRloadform and GRgetsfsize.
rlw 07/04/88 :  Added the modify curve shape method.
                Added curve data reduction method.
AIC 07/24/88 :  Added GRarea override.
rlw 08/05/88 :  Modified curve data reduction method to be a modification,
                as opposed to a construction, method.
rlw 08/29/88 :  Renamed the helix method due to additional argument in order
                to support placement of left hand threads.
rlw 09/02/88 :  Modified least squares curve fit documentation to indicate
                that fitting using data reduction is possible.
rlw 09/05/88 :  Added error arguments to data reduction
rlw 02/28/89 :  Modified to add conditional compilation statements
                for the I/DRAW product.
rlw 09/26/89 :  Modified least squares fit method to add argument.  Also
                renamed it due to argument change.
*/

#include "emsdattyp.h"
#include "EMSerrordef.h"
#include "emserr.h"

override
GRgeomprops; 
/*
  Motivation

  Fill in a message declaration.

  Files 
        GRscgeomprop.I
*/
#ifndef BASE_EMS
message EMalign_curve(
 struct		GRlc_info *my_curve;
 IGRpoint	my_end;
 struct		GRlc_info *his_curve;
 IGRpoint	his_end;
 IGRlong	mode;
 IGRlong	*msg);
/* 
Abstract

 This method modifies one or both of the input curves such that
 they are aligned, i.e. the tangent along a boundary is common.
 The curves must share a command boundary (endpoint).

Arguments

 my_curve
  Locate information for my curve.
 his_curve
  Locate information for the other curve.
 my_end
  A point near the end of me that is supposed to get aligned.
 his_end
  A point near the end of him that is supposed to get aligned.
 mode
  0 - only change first curve
  1 - only change second curve
  2 - change both but common boundary is fixed
  3 - change both, common boundary can move

Return Values

  msg
     Error return code.
        - MSSUCC, if successful
        - MSFAIL, if failed to generate results
        - MANOMEMORY, if unable to allocate memory

Files:
        EMbcalign.I                     The actual method
        bsaligncvt.c                    Supporting math function
*/
#ifndef IDRAW
message EMinsert_pole(
 struct		GRlc_info *lc_info;
 IGRpoint	point;
 IGRlong	*msg);
/*
 Abstract

 This method inserts a pole into the polygon of a freeform curve.
 The curves shape remains unchanged.

 Arguments

  lc_info
   Locate information for this object.
  point
   Point to be inserted into the polygon.

 Return Values

  msg                   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMscinspol.I		The actual method
  bsinspolcv2.c		Math function to insert a pole.
*/
message EMinsert_knot(
 struct		GRlc_info *lc_info;
 IGRdouble	knot_value;
 IGRlong	multiplicity;
 IGRlong	*msg);
/*
 Abstract

 This method inserts a knot into a freeform curve.
 The curves shape remains unchanged.

 Arguments

  lc_info
   Locate information for this object.
  knot_value
   Parameter value at which the knot is to be inserted.
  multiplicity
   Number of times the knot is to be inserted.  Note that the
   maximum muliplicity of any interior knot is (order - 1).

 Return Values

  msg                   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMscinskt.I		The actual method
  bsadd_kt2.c		Math function to insert knots.
*/
message EMmodify_order(
 IGRboolean	increase_it;
 struct		GRlc_info *lc_info;
 IGRlong	order;
 IGRlong	*msg);
/*
 Abstract

 This method changes or increases the order of a freeform curve.

 Arguments

  increase_it
   If TRUE then the order is increased else it is changed.
  lc_info
   Locate information for this object.
  order
   Desired order [2-16].  If changing the order then this must be
   less than or equal to the number of poles in the curve.  If increasing
   the order then this must be greater than or equal to the existing
   order.

 Return Values

  msg                   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMscmodord.I		The actual method
  bschgcvord.c		Math function to change the order.
  bsupthe_deg.c		Math function to increase the order.
*/
message EMcurve_by_poles(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 struct		GRvg_construct *construct_list);
/*
 Abstract

 This method constructs a curve by poles.  The poles may be input
 by passing this method a buffer of points or by specifying a curve (GRcurve)
 object whose poles are to be taken.

 Arguments

  order
   Order of the desired curve.  The order must be less than or equal to
   the number of points input and be in the range [2,16].
  periodic
   Boolean indicating if the curve is to be periodic.
   Note that if periodic is specified then I will move the last point input
   such that it is the same as the first point input.
  number_of_points
   The number of points contained in input_points.
  input_points
   Points if passed by this array.  NULL if you desire to
   use the poles of some existing curve.
  linestring
   Existing object whose poles are to be taken as my poles.
  construct_list
   Standard construction list.

 Return Values

  construct_list->msg   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMcurbypol.I		The actual method
  bschrdlkts.c		Supporting math function
*/
message EMdirect_fit_curve(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 IGRvector	*beg_tangent;
 IGRvector	*end_tangent;
 struct		GRvg_construct *construct_list);
/*
 Abstract

 This method constructs a curve which will pass through the input points.
 The points may be input by passing this method a buffer of points or by 
 specifying a curve (GRcurve) object whose poles are to be used as the points.
 Optional tangents may be input if the curve is not periodic.

 Arguments

  order
   Order of the desired curve.  The order must be less than or equal to
   the number of points input and must be in the range [2-16].
  periodic
   Boolean indicating if the curve is to be periodic.
   Note that if periodic is specified then I will move the last point input
   such that it is the same as the first point input.
  number_of_points
   The number of points contained in input_points.
  input_points
   Points if passed by this array.  NULL if you desire to
   use the poles of some existing curve.
  linestring
   Existing object whose poles are to be taken as my poles.
  beg_tangent
   Tangent vector at the beginning of the curve.  Should point
   from point[0] to a user given point.  Used iff not periodic,
   pass NULL if not specified.
  end_tangent
   Tangent vector at the end of the curve.  Should point
   from point[np - 1] to a user given point.  Used iff not periodic,
   pass NULL if not specified.
  construct_list
   Standard construction list.

 Return Values

  construct_list->msg   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMdirfitcur.I		The actual method
  bsdirfitcv.c		Supporting math function
*/
#endif
message EMleast_squares_fit_curvee(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 IGRvector	*beg_tangent;
 IGRvector	*end_tangent;
 IGRlong	number_of_spans;
 struct		GRlc_info *reference_curve;
 IGRdouble	*average_error;
 IGRdouble	*maximum_error;
 IGRlong	*maximum_indicator;
 IGRpoint	maximum_segment[2];
 struct		GRvg_construct *construct_list);
/*
 Abstract

 This method constructs a curve which will approximately pass through
 the input points.  The points may be input by passing this method a buffer 
 of points or by specifying a curve (GRcurve) object.  If an object is
 passed the points are obtained by stroking the curve by the active
 chord height tolerance.  Optional tangents may be input if the curve
 is not periodic.  If the input order is 2 then the resulting curve
 will be the input curve stroked to the active chord height tolerance.

 This method has been modified such that if the number_of_spans is 0 then
 fitting will be done using a data reduction technique.  In this case
 the resulting curve will be within chord height tolerance of the input
 data.  Also note that in this case periodic curves are not supported.

 This method has been modified such that if a reference curve is present
 then the knots, and thus the number of spans, for the fitted curve are taken
 from the reference curve.  This is useful when one wants to maintain
 better control on curve parameterization resulting from the fitting
 operation.

 Arguments

  order
   Order of the desired curve.  The order must be less than or equal to
   the number of points input.
  periodic
   Boolean indicating if the curve is to be periodic.
   Note that if periodic is specified then I will move the last point input
   such that it is the same as the first point input.
   This argument is not used if the number_of_spans is 0.
  number_of_points
   The number of points contained in input_points.
  input_points
   Points if passed by this array.  NULL if you desire to
   use the poles of some existing curve.
  linestring
   Existing object to get the points from.  Note that the object
   is stroked by the current/active chord height tolerance.
  beg_tangent
   Tangent vector at the beginning of the curve.  Should point
   from point[0] to a user given point.  Used iff not periodic,
   pass NULL if not specified.
  end_tangent
   Tangent vector at the end of the curve.  Should point
   from point[np - 1] to a user given point.  Used iff not periodic,
   pass NULL if not specified.
  number_of_spans
   Number of polynomial spans/pieces desired for the fit.  Must be less than
   the number of input points.  If equal to 1 less than the number of input
   points then a direct fit is performed.  If periodic then a minimum of 3
   is allowed, else a minimum of 1 is allowed.
   Note that if the number of spans is 0 then a fit is performed using
   data reduction techniques.  When this is done you the fitted curve will
   be within chord height tolerance of the input data.
  reference_curve
   Should be NULL if no reference curve is present.
   If a reference curve is present then the knots for the constructed curve
   will be taken from this curve.  Note that this means that the number of
   spans will also be determined by the reference curve.  Also note
   that the located_object[0].polygon_inx field is used to determine
   whether the reference curve needs to be reversed, i.e. TRUE means I
   reverse it.
  construct_list
   Standard construction list.

 Return Values

  average_error		The average error of the fit.
  maximum_error		The maximum error of the fit
  maximum_indicator	Index of the point with maximum error.
                        Set to -1 if error was 0.0.
  maximum_segment[2]	Two points indicating points of maximum error.
			Goes from fitted curve to an input point.
  construct_list->msg   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMlsqfitcur.I		The actual method
  bschtptscv.c		Supporting math function
  bslsqfitcv.c		Supporting math function
  bsfitratcv.c		Supporting math function
  bsdtardupts.c		Supporting math function
*/
#ifndef IDRAW
message EMconvex_fit_curve(
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 IGRvector	*beg_tangent;
 IGRvector	*end_tangent;
 struct		GRvg_construct *construct_list);
/*
 Abstract

 This method constructs a curve which represents a convex cubic fit of the
 input points.  It is expected that the points are nearly planar and
 nearly convex.  The points may be input by passing this method a buffer
 of points or by specifying a curve (GRcurve) object whose poles are to 
 be used as the points.  Optional tangents may be input and a minimum
 of 4 points is expected.

 Arguments

  number_of_points
   The number of points contained in input_points.
  input_points
   Points if passed by this array.  NULL if you desire to
   use the poles of some existing curve.
  linestring
   Existing object whose poles are to be taken as my poles.
  beg_tangent
   Tangent vector at the beginning of the curve.  Should point
   from point[0] to a user given point.  Pass NULL if not specified.
  end_tangent
   Tangent vector at the end of the curve.  Should point
   from point[np - 1] to a user given point.  Pass NULL if not specified.
  construct_list
   Standard construction list.

 Return Values

  construct_list->msg   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMcnvfitcur.I		The actual method
  bsfitcnvpts.c		Supporting math function
*/
message EMplace_helix_curve(
 IGRpoint		axis_point_1;
 IGRpoint		axis_point_2;
 IGRpoint		starting_point;
 IGRdouble		starting_radius;
 IGRdouble		ending_radius;
 IGRdouble		pitch_gap;
 IGRlong		number_of_pitches;
 IGRboolean		right_hand_thread;
 struct GRvg_construct	*construct_list);
/*
 Abstract

 This method constructs a helix given various inputs.  The constructed
 helix will be accurate to within the active chord height tolerance as
 it is approximated by a non-rational curve.

 Arguments

  axis_point_1
   Point 1 of the helix axis.
  axis_point_2
   Point 2 of the helix axis.
  starting_point
   Starting point of helix.  Note that the math will project this point
   onto the plane who's normal is determined by the vector going from
   axis_point_1 to axis_point_2.
  starting_radius
   Radius of helix at the start.
  ending_radius
   Radius of helix at the end.  Note that the helix radius will vary linearly.
  pitch_gap
   Desired distance between successive pitches.
  number_of_pitches
   Number of pitches desired.
  right_hand_thread
   If TRUE then helix will spin counter-clock-wise, otherwise
   it will spin clock-wise.
  construct_list
   Standard construction list.

 Return Values

  construct_list->msg   MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 Files

  EMhelix.I		The actual method
  bshelix1.c		Supporting math function
*/
message EMblnd2cvs ( IGRlong *msg;
                     struct GRmd_env *env1;
                     struct GRmd_env *env2;
                     struct GRid crv1_GRid;
                     struct GRid crv2_GRid;
                     IGRdouble u_crv1;
                     IGRdouble u_crv2;
                     IGRpoint dpt_crv1;
                     IGRpoint dpt_crv2;
                     struct GRvg_construct *construct_list);
/*
Abstract

Arguments
        msg             return code     MSSUCC if successful
                                        MSFAIL otherwise
Files:
        EMblnd2cvs.I
*/
#endif
message EMprb2crvs (IGRlong *msg;
                   struct GRmd_env *env1;
                   struct GRmd_env *env2;
                   struct GRid crv1_GRid;
                   struct GRid crv2_GRid;
                   IGRdouble param1;
                   IGRdouble param2;
                   struct GRvg_construct *construct_list);
/*
Abstract

Arguments
        msg             return code     MSSUCC if successful
                                        MSFAIL otherwise
Files:
        EMprb2crvs.I
*/
message EMgenConicBy5inputs(
struct		GRvg_construct *construct_list; 
IGRint		option;
IGRpoint	points[5];
IGRdouble	rho;
OM_S_OBJID	*constructed_object);
/*
Abstract

 This method constructs a conic by:

 1) 5 points
 2) 3 points and 2 tangents
 3) 4 points and 1 tangent
 4) 2 points, 2 tangents, and rho value

Arguments

construct_list
 Standard construct list with everything filled in except
 the geometry.  See GRconstruct under EMSsubbs for futher
 explanation.

option
 One of the following masks: 
 EMSconic_by_32 (conic by 3 points and 2 tangents), 
 EMSconic_by_41 (conic by 4 points and 1 tangent),
 EMSconic_by_50 (conic by 5 points),
 EMSconic_by_22Rho (conic by 2 points, 2 tangents, and rho).
 The file EMScnc5input.h contains the option masks.

points
 EMSconic_by_32 - order is p1, p2, p3, t1, t2
 EMSconic_by_41 - order is p1, p2, p3, p4, t1
 EMSconic_by_50 - order is p1, p2, p3, p4, p5
 Note tangent points (not vectors) are expected.

rho
 Rho value for EMSconic_by_22Rho case.  Must lie
 between 0 and 1 exclusive.

Return Values

construct_list->msg
 - MSSUCC, if successful
 - MSFAIL, if failed to generate results

constructed_object
 Object id of the resultant object.  If the method
 detects that a higher form (circular arc or elliptical
 arc) can be created then it will do so.

Files:
        EMscGnCnc5in.I		Actual method
	bsconic32.c		Supporting math
	bsconic41.c		Supporting math
	bsconic50.c		Supporting math
        bsconicrho.c		Supporting math
*/
#ifndef IDRAW
message EMmerge_curves(
  IGRlong       number_of_curves;
  struct        GRlc_info curves[];
  struct        GRvg_construct *construct_list;
  IGRlong       *msg);
/* 
Abstract

 This method creates a curve by merging together all the input curves.
 The input curves must be in the proper order for this method to work
 and naturally none of the input curves can be closed.

Arguments
        number_of_curves
                The number of curves that are to be merged together
        curves
                Locate information for each of the curves
        construct_list
                Standard construct list with everything filled in except
                the geometry.  See GRconstruct under EMSsubbs for futher
                explanation.
        msg
                Error return code.

Return Values

        - MSSUCC, if successful
        - MSFAIL, if failed to generate results
        - MSINARG, if math failed, note that this probably indicates that
                   the curves were not connected within the tolerance
        - MANOMEMORY, if unable to allocate memory

Files:
        EMbcmergecv.I                   The actual method
        bsmerge_cv.c                    Supporting math function
 */
#endif
message EMconic_by_linestring(
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 struct		GRvg_construct *construct_list;
 OM_S_OBJID	*constructed_object);
/*
 Abstract

 This method constructs a conic given a set of points lying on the conic.
 The first and last points input are given the least emphasis, i.e. they
 are not required to lie exactly on the conic as long as at least 7 points
 are input.  The points may be input by passing this method a buffer
 of points or by specifying a curve (GRcurve) object whose poles are to 
 be used as the points.  

 Arguments

  number_of_points
   The number of points contained in input_points.
  input_points
   Points if passed by this array.  NULL if you desire to
   use the poles of some existing curve.
  linestring
   Existing object whose poles are to be taken as my poles.
  construct_list
   Standard construction list.

 Return Values

  construct_list->msg   MSSUCC - successfull
			MSINARG - Math does not feel a conic is appropriate
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated
  constructed_object    The object id of the resulting conic.  Note that if
                        this method detects that the result is a circle,
                        ellipse, circular arc, or elliptical arc then it will
                        attempt to promote to that class.

 Files

  EMconicbyls.I		The actual method
  bsconic50.c		Supporting math function
  bscncxttpt.c		Supporting math function
  bsfullarc.c		Supporting math function
*/
message EMmodify_curve_shape(
 struct		GRlc_info *my_curve;
 IGRdouble	modify_parameter;
 IGRpoint	new_position;
 IGRdouble	u_start;
 IGRdouble	u_end;
 IGRboolean	preserve_beginning_tangent;
 IGRboolean	preserve_ending_tangent;
 IGRboolean	is_global_modification;
 IGRlong	*msg);
/* 
Abstract

 This method modifies the shape of a bspline curve either locally
 or globally.  A given point on the curve is modified to pass
 through a specified point.  If the modification is local then
 the u_start and u_end parameters specify the range of the curve
 which may be modified, otherwise these values are not used.
 The beginning and ending tangent vectors may optionally be preserved.

Arguments

 my_curve
  Locate information for my curve.
 modify_parameter
  Parameter of the point on the curve which is to be modified.
 new_position
  The point in model space which the modification point is to
  pass through.
 u_start
  One of two parameters which determine the area of the curve which
  may be modified.  Note that if the curve is closed then this point
  cannot lie at the closure point.
 u_end
  One of two parameters which determine the area of the curve which
  may be modified.  Note that if the curve is closed then this point
  cannot lie at the closure point.
 preserve_beginning_tangent
  Boolean value indicating whether the tangent vector at the
  beginning/start of the curve is to remain as it is.
 preserve_ending_tangent
  Boolean value indicating whether the tangent vector at the
  end of the curve is to remain as it is.
 is_global_modification
  Boolean value indicating whether the modification is to be global
  or local in nature.  If the operation is global then the u_start and
  u_end parameters are not used.  Note that global modification of closed
  curves is not supported.

Return Values

  msg
     Error return code.
        - MSSUCC, if successful
        - MSFAIL, if failed to generate results

Files:
        EMmodcrvshp.I                   The actual method
        bsmodshpcvl.c                   Supporting math function
        bsmodshpcvg.c                   Supporting math function
*/
#ifndef IDRAW
message EMreduced_fit_curve(
 struct		GRlc_info *lc_info;
 IGRboolean	preserve_beginning_tangent;
 IGRboolean	preserve_ending_tangent;
 IGRdouble	*maximum_error;
 IGRdouble	*average_error;
 IGRpoint	maximum_segment[2];
 IGRlong	*msg);
/* 
Abstract

 This method replaces a curve with one that approximates it
 to within the active chord height tolerance.  In addition the
 end tangents of the input curve can optionally be maintained.
 The purpose of this method is to try and reduce the amount
 of data (number of poles) required to represent the curve.

Arguments

 lc_info
  Locate information for myself.
 preserve_beginning_tangent
  Boolean value indicating whether the tangent vector at the
  beginning/start of the curve is to remain as it is.
 preserve_ending_tangent
  Boolean value indicating whether the tangent vector at the
  end of the curve is to remain as it is.

Return Values

  maximum_error
   The maximum error of the fit.
  average_error
   The average error of the fit.
  maximum_segment
   Two points which describe a line indicating the
   point of maximum error.  Line goes from the input/original
   data to the reducted/fitted data.
  msg                   MSSUCC - successfull
                        MSFAIL - if failure

Files:
	EMredcrvdat.I			The actual method
        bsdta_rducv.c                   Supporting math function
*/
#endif
override

GRlnprocess,
/*
    Motivation

    Process the polygon if it is displayed.

    File:   EMscLnProc.I
*/

GRptprocess,
/*
    Motivation

    Process the polygon if it is displayed.

    File:   EMscPtProc.I
*/

GRprismrel,
/*
    Motivation

    Process the polygon if it is displayed.

    File:   EMscPrismRel.I
*/

GRcenter,
/*
  Motivation

  Fill in a message declaration.

  Files
    EMsccenter.I
*/

GRarea,
/*
  Motivation

  Fill in a message declaration.

  Files
    EMscarea.I
*/

GRreport, GRreport_defaults, GRupdate_gadgets,
GRgetexsize,
/*
  Motivation

  Fill in a message declaration.

  Files
    EMscgetexsiz.I
*/

GRgetexgeom,
/*
  Motivation

  Fill in a message declaration.

  Files
    EMscgetexgeo.I
*/

GRdisextend,
/*
  Motivation

  Fill in a message declaration.

  Files
    EMscdisext.I
*/

GRkeypoint,
/*
  Motivation

  Fill in a message declaration.

  Files
        EMsckeypoint.I
*/


GRconstruct, 
/*
  Motivation

  Fill in a message declaration.

  Files 
        GRscconst.I 
*/
/* #ifndef IDRAW - commented out - Ashok Sep 5, 1990 */
GRdynmod,
/* #endif - commented out - Ashok Sep 5, 1990 */ 
/*
  Motivation

  Fill in a message declaration.

  Files 
        GRscdynmod.I
*/
GRptextend,
/*
  Motivation

  Fill in a message declaration.

  Files 
        GRpextend.I
*/
#ifndef IDRAW
debug,
#endif
/*
  Motivation

  Fill in a message declaration.

  Files 
        EMscdebug.I
*/
GRgetobjinfo;
/*
  Motivation

  Fill in a message declaration.

  Files 
        GRbcgetobjin.I
*/

override	GRanalyze_element;
#endif
end specification GRsubbc;
