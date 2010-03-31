/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method evaluates the edge in the (xyz) space
    and returns its geometry in a B-spline format.

  ARGUMENTS

    *mdenv		- input: is the environment info the surface, 
		           the edge is a part of. If the srf_geom is sent, 
		           it can be set to NULL
    *srf_id 		- input: if not known, the caller should set it 
		           to NULL. If the srf_geom is sent, the caller can
		           set it to NULL.
    *srf_geom 		- input: if not known, it should be set to 
			   NULL.
    *curve		- output: the curve containing the B-spline (xyz) space
		           geometry of the edge. The caller should allocate 
			   memory for the struct IGRbsp_curve. If caller
			   allocates memory for curve->poles, knots, weights,
			   it should be enough. Otherwise curve->poles, knots
			   and weights should be initialized to NULL.
		           The caller has the responsibility of deallocating
			   memory for curve->poles, curve->knots and
			   curve->weights.

  HISTORY

    RC        03/18/87      Creation Date
    RC        11/03/87      Modified for version 1.1.0
    RC        03/16/88      Added code to check if the edge
                            is degenerate.
    SS        05/19/88      Removed code to check if the edge
                            is degenerate. Also added modifications
                            for optimized execution is some cases.
    SM        07-Jun-88	    Fixed a bug - if num_spans is MAXINT
                            then num_spans + 1 causes an overflow and
                            the if statement if(num_spans + 1 < num_points)
                            gives wrong result.
                            The fix - if(num_spans > num_points -1)
                                        num_spans = num_points -1;
    SS	      12/06/88      The output curve's planarity bit is now set
                            correctly.
   Jack       04/23/93      Changed dealloc of pts2d to not check if
                            num_points > LOCAL_NUM_POINTS since num_points
                            can get changed if we are getting a partedge.
                            (Purify)
   Sudha      07/06/93      modified for BSprototype includes
				
  ALGORITHM

    Find out if the surface geometry is passed in by
    the caller.
    If not, find out if the surface GRid is passed in
    by the caller.
    If not, get the surface GRid and then get its geometry.
    Evaluate the edge in the (u,v) space and then
    convert it into (xyz) space by evaluating it on the
    surface.
*/		

class implementation EMSlinedge;

#include "EMSopt.h"
#include "emsmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfptseval.h"
#include "bsptlnplan.h"

#include "PWminimum.h"
#include "PWgmdata.h"

#include "PWapi/xyztol.h"
#include "PWapi/partol.h"
#include "PWapi/degengm.h"

/*
 * This constant is a measure of the maximum number of points that may
 * be found in most linear edges. This estimate is used to make room for
 * local arrays to hold these points.
 */

#define LOCAL_NUM_POINTS  200

/*
 * BS-code for non-planar set of points after the call to
 * BSptlnplan().
 */
 
#define NON_PLANAR 4

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMget_bcxyz_geom (IGRlong *EMmsg; struct GRmdenv_info *mdenv;
                         struct GRid *srf_id; struct IGRbsp_surface *srf_geom;
                         IGRint from_spaninx; IGRint num_spans;
                         IGRboolean reverse; struct EMSpartedinfo *partinfo;
                         struct IGRbsp_curve *curve)
{
   IGRlong OM_stat, mthd_stat, rc;
   IGRint i, num_points,  planar_code, num_degen_spans = 0;
   IGRushort ed_props;
   IGRdouble tol=0.0;
   IGRdouble pts2dmem[LOCAL_NUM_POINTS][2], *pts2d, *genptr;
   IGRdouble delta;
   IGRvector dum_vec;
   GRobjid user_id;
   struct IGRpolyline poly;
   struct IGRbsp_surface *surface;

//IGRint num_pts = 0;	
   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   surface = srf_geom;
   pts2d = NULL;
   if (partinfo)
     user_id = partinfo->edid;
   else
     user_id = my_id;

   /*
    * If this is an iso-edge, get the geometry through the special
    * message.
    */
   if (ME.EMSedge->ed_props & EMED_ISO)
     {
     OM_stat = om$send (msg = message EMSlinedge.EMget_iso_geom (&mthd_stat, 
                mdenv, srf_id, srf_geom, reverse, partinfo, curve),
                targetid = my_id);
     EMomerr_exit (OM_stat, wrapup);
     EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

     goto wrapup;
     }

   /*
    * Find out if the surface is passed along. If not obtain this 
    * surfaces geometry.
    */

   if (!surface )
     {
       struct GRid loc_srfid;
       if (!srf_id)
       {
         OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info 
                    (&mthd_stat, &loc_srfid.objid, NULL), 
                    targetid = user_id);
         EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
          EMS_E_EdgeError, wrapup);
         loc_srfid.osnum = OM_Gw_current_OS;
       }
       else
       {
         loc_srfid = *srf_id;
       }

       OM_stat = EMgetvggeom (&mthd_stat, &mdenv->matrix_type,
                  mdenv->matrix, &loc_srfid, &surface, NULL);
       EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
        EMS_E_SurfaceError, wrapup);
     }

   /*
    * Obtain the parametric space geomtery of the edge.
    */

   num_points = ME.EMSlinedge->num_points;
   if (num_spans > num_points - 1)
     num_spans = num_points - 1;
   if (num_spans + 1 < num_points)
     num_points = num_spans+1;

   if (num_points > LOCAL_NUM_POINTS)
     {
     pts2d = (IGRdouble *) om$malloc (size = num_points * 2 * 
              sizeof (IGRdouble));
     EMerr_hndlr (!pts2d, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }
   else
     pts2d = (IGRdouble *)pts2dmem;

   poly.points = pts2d;

   OM_stat = om$send (msg = message EMSedge.EMgetpygeom (&mthd_stat,
              from_spaninx, num_spans, reverse, partinfo, &poly, NULL, NULL),
              targetid = my_id);
   EMomerr_exit (OM_stat, wrapup);
   EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

/* This pathway code has been added to  remove any degenerate spans in the curve
   - TR#119602802 - jeff
*/

  {
   IGRdouble  uvbastol;
   IGRlong rc;
   BSEXTRACTPAR (&rc, BSTOLLENVEC, tol);
   uvbastol = pwGetParTolSf(surface,tol); 

   if (pwNumDegenSpans2d ( poly.num_points, (PWpoint2d *) poly.points, uvbastol))
   {

      IGRint num_pts = 0;
      PWpoint2d *pPtArray = NULL;
      pPtArray = alloca ( poly.num_points * sizeof (PWpoint2d));
      num_degen_spans=   pwRemoveDegenSpans2d ( poly.num_points,
                            (PWpoint2d *)poly.points, &num_pts, pPtArray,uvbastol);
      memmove(poly.points, pPtArray, num_pts * sizeof( PWpoint2d));
      poly.num_points  = num_pts ;
   }
  }

   /*
    * The control information in the rest of the curve structure is filled
    * up here. The knots are determined as uniform.
    */

   /*
    * Convert these points from parametric space to model space poles.
    */
   num_points=poly.num_points;

   if (!curve->poles)
     {
     curve->poles = (IGRdouble *) om$malloc (size = num_points * 3 *
                     sizeof (IGRdouble));
     EMerr_hndlr (!curve->poles, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }

   BSsfptseval (surface, num_points, pts2d, curve->poles, &rc);
   EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);


/* fix is in progress*/








   curve->order = 2;
   curve->periodic = FALSE;
   curve->non_uniform = FALSE;
   curve->num_poles = num_points;
   curve->num_knots = num_points+2;

   if (!curve->knots)
     {
     curve->knots = (IGRdouble *) om$malloc (size = curve->num_knots *
                     sizeof (IGRdouble));
     EMerr_hndlr (!curve->knots, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }
   delta = 1.0 / (num_points-1);
   genptr = curve->knots;
   genptr[0] = genptr[1] = 0.0; 
   genptr[num_points] = genptr[num_points+1] = 1.0;
   for (i=2; i<num_points; i++)
     genptr[i] = genptr[i-1] + delta;

   curve->rational = FALSE;
   if (surface->planar)
     curve->planar = TRUE;
   else
     {
     BSptlnplan (curve->num_poles, FALSE, (IGRpoint *)curve->poles, NULL, &planar_code,
      dum_vec, &rc);
     curve->planar = planar_code == NON_PLANAR ? FALSE : TRUE;
     }

   if (partinfo)
     ed_props = partinfo->edprops;
   else
     ed_props = ME.EMSedge->ed_props;
   if (ed_props & EMED_XYZ_CLOSED)
     curve->phy_closed = TRUE;
   else
     curve->phy_closed = FALSE;
   
   curve->num_boundaries = 0;

   /*
    * If this edge in model-space is degenerate, indicate that
    * by a return code. Control information that would correspond to
    * such a degenerate curve is forced in.
    */

   if (ed_props & EMED_DEGENERATE)
     {
     curve->periodic = FALSE;
     curve->non_uniform = FALSE;
     curve->order = 2;
     curve->num_poles = 2;
     curve->num_knots = 4;
     curve->knots[0] = curve->knots[1] = 0.0;
     curve->knots[2] = curve->knots[3] = 1.0;
     curve->rational = FALSE;
     curve->planar = TRUE;
     curve->phy_closed = TRUE;
     *EMmsg = EMS_I_DegenerateEdge;
     }

wrapup:
  if (!srf_geom)
    om$dealloc (ptr = surface);
  if (pts2d &&  (pts2d != (IGRdouble *)pts2dmem)) 
    om$dealloc (ptr = pts2d);
  EMWRAPUP (*EMmsg, OM_stat, "EMSlinedge.EMget_bcxyz_geom");
  return (OM_stat);
}

end implementation EMSlinedge;
