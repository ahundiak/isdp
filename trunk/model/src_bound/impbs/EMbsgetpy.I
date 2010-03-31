/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#define FROM_SPAN_INX 0
#define NO_SPANS 1
#define UPPER_LIMIT_FOR_CHT 0.001
#define DEBUG 0
#if DEBUG
 #include <stdio.h>
#endif

method EMgetpygeom (IGRlong *EMmsg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRpolyline *pygeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)
/* ***********************************************************************

Description
  This method gets the polyline geometry by stroking the bspline edge
  with the chordal height tolerance mapped into parametric space.

Notes
 For more information on documentation see EMSedge.S

History
   06/26/89 SS  If this edge is an XYZ-edge then do not push points
                into the [0,1] space.
   06/09/89 SS  If the from_spaninx is greater than the starting index
                of the last span, an information code is returned and
                there is no other output.
   05/04/89 rlw Modified to make sure the points are within [0,1]
                parametric space.
   08/23/88 PP  Made changes so that the bsedge is stroked based on
                the parametric tolerance which is coming in. If the field
                was set to NULL, then the cht is computed based on
                the model space basis tolerance * a factor. Also introduced
                a upper cut off limit for parametric chord height tolerance.
   02/17/88 PP  Not snapping the polyline to boundaries any more
   04/12/87 PP  Creation date

************************************************************************** */
{
 IGRboolean		isxyz;
 IGRshort		i;
 IGRint			num_xferpts;
 IGRlong		status;
 IGRlong		msg_loc;
 struct IGRbsp_curve    bsgeom;
 struct IGRpolyline     polyline;
 IGRdouble		tolerance;
 IGRdouble              cht;

 IGRboolean		bssts;
 extern IGRboolean	EFstroke_the_curve();
 extern IGRboolean      EFextract_par();

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 bsgeom.poles = NULL;
 bsgeom.knots = NULL;
 bsgeom.weights = NULL;
 bsgeom.bdrys = NULL;
 polyline.points = NULL;

 status = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc,
                         FROM_SPAN_INX, NO_SPANS, reverse, partinfo,
                         &bsgeom,partolbasis,options),
                   targetid = my_id);
 EMerr_hndlr (!(1 & status & msg_loc), *EMmsg, EMS_E_EdgeError,wrapup);

/*
 * If there is no parametric tolerance coming in then I multiply the
 * basis tolerance by a factor (0.001) and compute the chord height
 * tolerance based on the same. This should simulate the behaviour which
 * existed before the parametric tolerance code got put in.
 */

 if (partolbasis)
 {
  if (!(partolbasis->is_valid))
  {
   status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                           NULL, partolbasis),
                     targetid = my_id);
   EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
  }
   tolerance = partolbasis->tol;
 }
 else
   bssts = BSEXTRACTPAR (&msg_loc, BSTOLBASIS, tolerance);

 isxyz = ME.EMSedge->ed_props & EMED_XYZ;

 if (isxyz)
   BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
 else
 {
   bssts = EFextract_par(BSTOLCHRDHT, tolerance, &cht, &msg_loc);

  /*
   * The cutoff limit is just a gut value.   cht = UPPER_LIMIT_FOR_CHT
   */

   if (cht > UPPER_LIMIT_FOR_CHT)
   {
     if( cht >= tolerance * 100.0 )
         cht  = tolerance * 100.0 ;
   }
 }
//  #ifdef	DEBUG
//    printf(" Tolerance : %lf, %lf \n", tolerance, cht );
//  #endif

 bssts = EFstroke_the_curve (&bsgeom, &cht, &polyline, &msg_loc);
 EMerr_hndlr (! (1 & bssts & msg_loc), *EMmsg, EMS_E_EdgeError, wrapup);

  /*
   * If the starting span-index from the geometry
   * extraction is larger than the number of spans
   * an error message is returned.
   */

  EMerr_hndlr (from_spaninx > polyline.num_points-2, *EMmsg, EMS_I_OutOfBounds,
   wrapup);

  /*
   * Determine the index of the point in the active
   * linestring from which the extraction begins. Also
   * obtain the number of points to extract.
   */

 if (from_spaninx + num_spans > polyline.num_points - 1)
   num_xferpts = polyline.num_points - from_spaninx;
 else
   num_xferpts = num_spans + 1;

  /*
   * Allocate output memory if no memory has been allocated
   * by the user.
   */

 if (!pygeom->points)
 pygeom->points = (IGRdouble *) om$malloc (size = num_xferpts * 2 *
                                           sizeof (IGRdouble));
 EMerr_hndlr (!pygeom->points, *EMmsg, EMS_E_DynamicMemoryAllocated,
              wrapup);
/*
 * Added logic to make sure the stroked points are within the
 * parametric space of the surface (I am assuming [0,1] space).
 * This is needed for BSedges which are tangent to natural edges
 * because the stroked data may, and in one case did, have sufficent
 * noise to push it outside parametric space.  rlw  05/04/89
 *
 * Don't do this if this edge is an XYZ-edge. - SS 06/26/89
 */

 for (i=from_spaninx ; i<num_xferpts; i++)
  {
  IGRdouble	u;

  u = polyline.points[3*i];
  if (!isxyz)
    {
    if (u < 0.0)
     u = 0.0;
    else if (u > 1.0)
     u = 1.0;
    }
  pygeom->points[2*i] = u;

  u = polyline.points[3*i+1];
  if (!isxyz)
    {
    if (u < 0.0)
     u = 0.0;
    else if (u > 1.0)
     u = 1.0;
    }
  pygeom->points[2*i + 1] = u;
  }

  pygeom->num_points = num_xferpts;

wrapup:
 if (bsgeom.poles) om$dealloc (ptr = bsgeom.poles);
 if (bsgeom.knots) om$dealloc (ptr = bsgeom.knots);
 if (bsgeom.weights) om$dealloc (ptr = bsgeom.weights);
 if (bsgeom.bdrys) om$dealloc (ptr = bsgeom.bdrys);
 if (polyline.points) om$dealloc (ptr = polyline.points);

 EMWRAPUP (*EMmsg, status, "In EMSbsedge:EMgetpygeom error");

 return (status);

}

end implementation EMSbsedge;

