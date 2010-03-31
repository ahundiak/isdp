/* ###################   APOGEE COMPILED   ################## */

/*

   History

     Sudha 06/04/93          modified to include BSprototype header files

*/

class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsprptoncv.h"
#include "bschgdeppar.h"

#define START 0
#define STOP 1
#define FROM_SPAN_INX 0
#define NUM_SPANS 1

method EMpratpt (IGRlong *EMmsg; IGRdouble *points; IGRint num_points;
                 struct EMSedgebound *param; IGRboolean *off_edge;
                 struct EMSpartedinfo *bnd; struct EMSpartolbasis *partolbasis)

{
 IGRboolean		bssts;    /* Math return status */
 BSrc			rc;       /* Math completion status */
 IGRlong 		status;   /* OM return status */
 IGRdouble              basis_tol;
                                  /* basis tolerance */
 struct IGRbsp_curve    curve;    /* bspline edge structure */


                                  /* Function declarations */


/*
 * Initialisation
 */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 curve.weights = NULL;
 curve.knots = NULL;
 curve.poles = NULL;
 curve.bdrys = NULL;

 bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
 EMerr_hndlr (!bssts , *EMmsg, EMS_E_Fail, wrapup);

/*
 * Determine the parametric tolerance
 */

 if (!partolbasis->is_valid)
 {
  status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg, NULL,
                          partolbasis),
                    targetid = my_id);
  EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
 }

/*
 * Get the true geometry of the edge regardless of the edge direction
 */


 status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                         NUM_SPANS, ME.EMSedge->ed_props & EMED_REVERSED,
                         NULL, &curve, partolbasis, NULL), 
                   targetid = my_id);
 EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
 

/*
 * Get the parameters for the incoming points.
 */

 {
   IGRboolean 		on_curve;   /* flag to determine if the point is lying
                                      on the curve or not */
   IGRshort 		i;
   IGRpoint 		point_for_evaluation;
                                   /* necessary to represent a 2d point as 3d */
   IGRdouble		parameter; /* parameter corresponding to the point on
                                      on the curve */

/* 
 * Change the basis tolerance to account for tolerance in parametric space
 */


   BSchgdeppar (partolbasis->tol, &rc);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

   point_for_evaluation[Z] = 0.0;

   for (i=0 ; i < num_points; i++)
   {
    point_for_evaluation[X] = points[2*i];
    point_for_evaluation[Y] = points[2*i + 1];

    param[i].span_inx = 0;
    bssts = BSprptoncv ( &rc, &curve, point_for_evaluation, &parameter,
                         &on_curve);
    EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);

      param[i].span_inx = 0;
      param[i].param = parameter;

    if (on_curve)
     off_edge[i] = FALSE;
    else
     off_edge[i] = TRUE;
  }
 }


wrapup:
 BSchgdeppar (basis_tol, &rc);
 if (curve.weights) om$dealloc (ptr = curve.weights);
 if (curve.poles) om$dealloc (ptr = curve.poles);
 if (curve.knots) om$dealloc (ptr = curve.knots);
 if (curve.bdrys) om$dealloc (ptr = curve.bdrys);
 EMWRAPUP (*EMmsg, status, "In EMSbsedge: EMpratpt error");
 return (status);
}

end implementation EMSbsedge;

