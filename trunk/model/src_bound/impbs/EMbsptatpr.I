/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

/*

  History

         Sudha 06/04/93          modified to include BSprototype header files

*/

#include "EMS.h"
# include "bserr.h"
# include "emsmacros.h"
#include "bscveval.h"

# define NUM_DERIV 0
# define FROM_SPAN_INX 0
# define NUM_SPANS 1


method EMptatpr (IGRlong *EMmsg; IGRint num_param; struct EMSedgebound *param;
                 IGRdouble *bs_param; IGRdouble *point)
 
/* *************************************************************************

Description
   
   ************************************************************************* */

{

 IGRshort		i;

 IGRdouble 		*parameter;
 BSrc			rc;
 IGRlong		status;     /* OM return status */
 IGRpoint		evaluated_point;

 struct IGRbsp_curve	curve;


/****************************

  Initialisation
 
 **************************** */

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 curve.bdrys = NULL;
 curve.weights = NULL;
 curve.poles = NULL;
 curve.knots = NULL;



 if (num_param <= 0) *EMmsg = EMS_E_InvalidArg;

 if (bs_param)
  parameter = bs_param;
 else
 if (param)
   parameter = &param->param;
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

   curve.poles = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                             3 * ME.EMSbsedge->num_poles);

   curve.knots = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                      ( ME.EMSbsedge->num_poles + ME.EMSbsedge->order));

   if (ME.EMSbsedge->bs_props & EMBS_RATIONAL)
    curve.weights = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                           ME.EMSbsedge->num_poles);

/*
 * Get the true geometry of the bspline edge since definition of a parameter
 * is with respect to the true geometry and not the logical geometry.
 * Also note the definition of span is different from the knot vector span
 * A bspline edge has always one span and a span index of 0.  This 
 * terminology is adopted to maintain consistency with the polyline
 * geometry defintion.
 */ 


   status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                           NUM_SPANS, ME.EMSedge->ed_props & EMED_REVERSED, 
                           NULL, &curve, NULL, NULL),
                     targetid = my_id);
   if (! (1 & status & *EMmsg)) goto wrapup;
 
  for (i=0 ; i < num_param; i++)
  {
   BScveval (&curve, parameter[i], NUM_DERIV, (IGRpoint *)evaluated_point, &rc);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

   point[2 * i] = evaluated_point[0];
   point[2 * i + 1] = evaluated_point[1];
  }

wrapup:
 if (curve.poles) om$dealloc (ptr = curve.poles);
 if (curve.knots) om$dealloc (ptr = curve.knots);
 if (curve.weights) om$dealloc (ptr = curve.weights);

 EMWRAPUP ( *EMmsg, status, "In EMSbsedge : EMptatpr error");
 return (status);
}

end implementation EMSbsedge;
