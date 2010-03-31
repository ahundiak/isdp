/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"

#define DEBUG 0

#if DEBUG
  #include <stdio.h>
#endif

#include "bsnorvec.h"
#include "bsmdistptcv.h"
#include "bscvkttol2.h"
#include "bscveval_b.h"
#include "bschgdeppar.h"

#define X 0
#define Y 1
#define Z 2
#define START 0
#define STOP 1
#define NO_SPANS 1
#define FROM_SPAN_INX 0
#define COARSE_TOL 0.001


method EMptproject (IGRlong *EMmsg; 
                    IGRdouble *points; 
		    IGRint num_points;
		    struct EMSproj_info *proj_info;
		    struct EMSpartedinfo *bnd;
		    struct EMSpartolbasis *partolbasis)


/* ********************************************************************
Description
          This method projects an input point onto an edge. The input
          point is in parametricspace (2d). The information returned is the
          projected point (2d) on the edge, the minimum distance to the
          the edge and the edge param of the point on the edge (in the
          format span index-parameter pair). The span index is always 0
           
          Input
            point  -   array of points to be projected
            num_points - number of points to be projected
            bnd        - boundary information. Useful when the point is 
                         being projected on the part edge
            partolbasis - parametric basis tolerance

          Output
            proj_info  - information of the projected point which includes
                         the u,v value of the projected point, minimum distance
                         to the edge and the edge param of the point on the
                         edge. The paramter is the true parameter and not the
                         logical parameter
            

Notes
          Upon exit the completion code will be one of the following:
           EMS_S_Success : if successful
           EMS_I_NoSolution
           EMS_I_Ambiguous
           EMS_E_InvalidArg :
           EMS_E_EdgeError :
        

Algorithm

Assumptions

History
	  SS : 10/26/89		   Location was not being set right for
				   closed edges. Fixed that.
          PP : 02/11/89            Fixed a memory fault related to
                                   a wrong pointer being passed to
                                   BScveval_b. This happens for part
                                   edges when the math returns an entire
                                   interval for minimum distance.
	  SM : 12-Apr-88	   Added code to return correct value in
				   the field proj_info.location.
				   Currently I am using the brute method
				   distance check betwwen end point(s) and
				   the projected point. Prasad is going to
				   optimise it later.
          PP : 01/27/88            Returning EMS_I_NoSolution when the
                                   average tangent vector has a zero
                                   magnitude, and EMS_I_Ambiguous if
                                   the number of projected parameters
                                   is > 1.
          PP : 04/02/87            Design date

         Sudha 06/04/93          modified to include BSprototype header files

*********************************************************************** */
{
 IGRboolean		bssts;      /* Math return status */
 IGRboolean		closed, reversed;
 BSrc			rc;         /* Math completion status */
 IGRshort		no_params,  /* number of discrete parameter values
                                       at which the minimum distance occurs */
                        no_intervals, /* number of intervals over which the
                                         minimum distance occurs */
                        i;          /* loopindex */
 
 IGRlong		status;     /* OM completion code */
 IGRdouble		min_dist;   /* minimum distance */
 IGRdouble		basis_tol;  /* basis tolerance */
 IGRdouble		*projected_params;
                                    /* parameter values of the projected 
                                       points */
 IGRdouble              *interval_params, startpar, stoppar, chkpar;
                                    /* start and the ending parameter
                                       values of the interval should the
                                       minimum distance occur over an 
                                       interval */
 IGRdouble		tsign;      /* multiplication term for getting the
                                       tangent vector at the point of projection
                                       for whole edges */

 IGRdouble              mag;
 IGRdouble		knot_tol;
 IGRint 		num_deriv = 1;

 IGRpoint		point_to_be_projected;
                                    /* point that is being projected onto
                                       the curve */
                        
                                    
 IGRboolean             eval_bound = TRUE, boundary;

 IGRpoint		left_deriv[2], 
                        right_deriv[2]; /* left and right derivatives at
                                           the projected parameter */
 struct IGRbsp_curve    whole_edge,
                                    /* curve structure representing the
                                       geometry of the whole edge */
                        part_edge;  /* curve structure representing the 
                                       geometry of the part edge */

 extern  IGRdouble	fabs();
 IGRdouble		lentol, dist;
 IGRdouble		start_pt[2], stop_pt[2];

/* 
 *  Initialisation
 */

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 whole_edge.poles = NULL;
 whole_edge.knots = NULL;
 whole_edge.weights = NULL;
 whole_edge.bdrys = NULL;

 part_edge.poles = NULL;
 part_edge.knots = NULL;
 part_edge.weights = NULL;
 part_edge.bdrys = NULL;

 projected_params = NULL;
 interval_params = NULL;

 bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);

 if (!partolbasis->is_valid)
 {
  status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                          NULL, partolbasis),
                    targetid = my_id);
  EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
 }

 
 status = EFextract_par(BSTOLLENVEC, partolbasis->tol, &lentol, &rc);

 BSchgdeppar (partolbasis->tol, &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);



 if (!bnd) /* if no boundary information is coming in */
 {
  /*
   * Get the true geometry of the whole edge
   */

  closed = !(ME.EMSedge->ed_props & EMED_OPEN);
  reversed = ME.EMSedge->ed_props & EMED_REVERSED;

  status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                          NO_SPANS, reversed,
                          NULL, &whole_edge, partolbasis, NULL),
                    targetid = my_id);
  EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

  status = om$send(msg = message EMSedge.EMendpts(EMmsg, start_pt, stop_pt, 
				NULL, NULL, NULL), targetid = my_id);
  EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

  BScvkttol2  (whole_edge.order, whole_edge.knots, whole_edge.num_poles, 
               whole_edge.poles, whole_edge.weights, &knot_tol, &rc);
  EMerr_hndlr (BSERROR	 (rc), *EMmsg, EMS_E_Fail, wrapup);

  startpar = whole_edge.knots[whole_edge.order-1];
  stoppar = whole_edge.knots[whole_edge.num_poles];

  for (i=0 ; i < num_points; i++)
  {
   point_to_be_projected[X] = points[2*i];
   point_to_be_projected[Y] = points[2*i + 1];
   point_to_be_projected[Z] = 0.0;

   BSmdistptcv (&whole_edge, point_to_be_projected, &no_intervals,
                &no_params, &projected_params, &min_dist, &interval_params,
                &rc);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);


/* 
 * If there are distinct parameters then return the first parameter and its
 * associated point as the result
 * else if there are intervals over which the condition of minimum distance
 * occurs then return the starting point of the interval as the result
 * else something is messed up and invalid arguments is returned
 */

/*
 * We need to check for the reversed bit since in the case of a whole
 * edge we are getting the true geometry of the edge (for efficiency
 * reasons). 
 * Since the tangent is with respect to the logical geometry of the edge
 * tsign is -1.0 when the edge is reversed
 * The part edge gets it logical geometry and hence this multiplication will
 * not be necessary
 */

  if (reversed) tsign = -1.0;
  else
  tsign = 1.0;

   if (no_params) 
   {

/*
 * If the projected parameter is very close to the boundary we snap it to
 * the boundary to prevent curve evaluation from barfing.
 */

    if (fabs (projected_params[0] - startpar) <= knot_tol)
      projected_params[0] = startpar;
    else if (fabs (projected_params[0] - stoppar) <= knot_tol)
     projected_params[0] = stoppar;

    proj_info[i].param.span_inx = 0;
    proj_info[i].param.param = projected_params[0];
    proj_info[i].dist = min_dist;
    proj_info[i].location = EMScvint_unknown;
    chkpar = projected_params[0];

    bssts = BScveval_b ( &rc, &whole_edge, &projected_params[0], &num_deriv,
                         &eval_bound, &boundary, left_deriv, right_deriv);
    EMerr_hndlr(!bssts, *EMmsg, EMS_E_Fail, wrapup);

    if (boundary)
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      BSnorvec (&rc, right_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      left_deriv[1][0] = tsign * ((left_deriv[1][0] + 
					right_deriv[1][0]) / 2.0);
      left_deriv[1][1] = tsign * ((left_deriv[1][1] + 
					right_deriv[1][1]) / 2.0);

      mag = left_deriv[1][0]*left_deriv[1][0] +
            left_deriv[1][1]*left_deriv[1][1];
      if (mag < COARSE_TOL) 
      {
        *EMmsg = EMS_I_NoSolution;
        proj_info[i].tangent[X] = 0.0;
        proj_info[i].tangent[Y] = 0.0;
        goto wrapup;
      }
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[X] = left_deriv[1][0];
      proj_info[i].tangent[Y] = left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else
        proj_info[i].location = EMScvint_middle;
    }
    else
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[0] = tsign * left_deriv[1][0];
      proj_info[i].tangent[1] = tsign * left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
   }
   else if (no_intervals)
   {
    if (fabs (interval_params[0] - startpar) <= knot_tol)
      interval_params[0] = startpar;
    else if (fabs (interval_params[0] - stoppar) <= knot_tol)
     interval_params[0] = stoppar;

    proj_info[i].param.span_inx = 0;
    proj_info[i].param.param = interval_params[0];
    proj_info[i].dist = min_dist;
    chkpar = interval_params[0];

    bssts = BScveval_b ( &rc, &whole_edge, &interval_params[0], &num_deriv,
                         &eval_bound, &boundary, left_deriv, right_deriv);
    EMerr_hndlr(!bssts, *EMmsg, EMS_E_Fail, wrapup);

    if (boundary)
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      BSnorvec (&rc, right_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      left_deriv[1][0] = tsign * ((left_deriv[1][0] + 
					right_deriv[1][0]) / 2.0);
      left_deriv[1][1] = tsign * ((left_deriv[1][1] + 
					right_deriv[1][1]) / 2.0);

      mag = left_deriv[1][0]*left_deriv[1][0] +
            left_deriv[1][1]*left_deriv[1][1];
      if (mag < COARSE_TOL) 
      {
        *EMmsg = EMS_I_NoSolution;
        proj_info[i].tangent[X] = 0.0;
        proj_info[i].tangent[Y] = 0.0;
        goto wrapup;
      }
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[X] = left_deriv[1][0];
      proj_info[i].tangent[Y] = left_deriv[1][1];

      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
    else
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[0] = tsign * left_deriv[1][0];
      proj_info[i].tangent[1] = tsign * left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
    
   }
   else
   {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
   }
 
 /*
  * Correction to location may be needed if the point to be projected is
  * at the end-point of a closed curve.
  */

 if (closed && proj_info[i].location != EMScvint_middle)
   {
   if (fabs (chkpar - startpar) < fabs (chkpar - stoppar))
     proj_info[i].location = reversed ? EMScvint_rtend : EMScvint_lfend;
   else
     proj_info[i].location = reversed ? EMScvint_lfend : EMScvint_rtend;
   }
/* fix for mlk */
  if (projected_params) free (projected_params);
  if (interval_params) free (interval_params);
  projected_params = interval_params =NULL;
 } /* end for loop */
} /* end if no boundaries */
else 
{
 status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                         NO_SPANS, FALSE, bnd, &part_edge, partolbasis, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

 status = om$send(msg = message EMSedge.EMendpts(EMmsg, start_pt, stop_pt, 
				NULL, NULL, bnd), targetid = my_id);
 EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

 BScvkttol2  (part_edge.order, part_edge.knots, part_edge.num_poles, 
              part_edge.poles, part_edge.weights, &knot_tol, &rc);
 EMerr_hndlr (BSERROR	 (rc), *EMmsg, EMS_E_Fail, wrapup);

 startpar = part_edge.knots[part_edge.order-1];
 stoppar = part_edge.knots[part_edge.num_poles];
 closed = !(bnd->edprops & EMED_OPEN);

 for (i=0; i < num_points; i++)
 {
  point_to_be_projected[X] = points[2*i];
  point_to_be_projected[Y] = points[2*i + 1];
  point_to_be_projected[Z] = 0.0;

  BSmdistptcv (&part_edge, point_to_be_projected, &no_intervals,
               &no_params, &projected_params, &min_dist, &interval_params,
               &rc);
  EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

  if (no_params)
  {
    if (fabs (projected_params[0] - startpar) <= knot_tol)
      projected_params[0] = startpar;
    else if (fabs (projected_params[0] - stoppar) <= knot_tol)
     projected_params[0] = stoppar;

    proj_info[i].dist = min_dist;
    proj_info[i].param.span_inx = 0;
    proj_info[i].param.param = bnd->edbdry[START].param + projected_params[0] *
                        (bnd->edbdry[STOP].param - bnd->edbdry[START].param);
    chkpar = projected_params[0];

 
    bssts = BScveval_b ( &rc, &part_edge, &projected_params[0], &num_deriv,
                         &eval_bound, &boundary, left_deriv, right_deriv);
    EMerr_hndlr(!bssts, *EMmsg, EMS_E_Fail, wrapup);

    if (boundary)
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      BSnorvec (&rc, right_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      left_deriv[1][0] = (left_deriv[1][0] + 
					right_deriv[1][0]) / 2.0;
      left_deriv[1][1] = (left_deriv[1][1] + 
					right_deriv[1][1]) / 2.0;

      mag = left_deriv[1][0]*left_deriv[1][0] +
            left_deriv[1][1]*left_deriv[1][1];
      if (mag < COARSE_TOL) 
      {
        *EMmsg = EMS_I_NoSolution;
        proj_info[i].tangent[X] = 0.0;
        proj_info[i].tangent[Y] = 0.0;
        goto wrapup;
      }
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[X] = left_deriv[1][0];
      proj_info[i].tangent[Y] = left_deriv[1][1];

      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
    else
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[0] = left_deriv[1][0];
      proj_info[i].tangent[1] = left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
  
   }
   else if (no_intervals)
   {
    if (fabs (interval_params[0] - startpar) <= knot_tol)
      interval_params[0] = startpar;
    else if (fabs (interval_params[0] - stoppar) <= knot_tol)
     interval_params[0] = stoppar;

    proj_info[i].param.span_inx = 0;
    proj_info[i].dist = min_dist;
    proj_info[i].param.param = bnd->edbdry[START].param + interval_params[0] *
                         (bnd->edbdry[STOP].param - bnd->edbdry[START].param);
    chkpar = interval_params[0];
  
    bssts = BScveval_b ( &rc, &part_edge, &interval_params[0], &num_deriv,
                         &eval_bound, &boundary, left_deriv, right_deriv);
    EMerr_hndlr(!bssts, *EMmsg, EMS_E_Fail, wrapup);

    if (boundary)
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      BSnorvec (&rc, right_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      left_deriv[1][0] = (left_deriv[1][0] + 
					right_deriv[1][0]) / 2.0;
      left_deriv[1][1] = (left_deriv[1][1] + 
					right_deriv[1][1]) / 2.0;

      mag = left_deriv[1][0]*left_deriv[1][0] +
            left_deriv[1][1]*left_deriv[1][1];
      if (mag < COARSE_TOL) 
      {
        *EMmsg = EMS_I_NoSolution;
        proj_info[i].tangent[X] = 0.0;
        proj_info[i].tangent[Y] = 0.0;
        goto wrapup;
      }
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[X] = left_deriv[1][0];
      proj_info[i].tangent[Y] = left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
    else
    {
      BSnorvec (&rc, left_deriv[1]);
      if (rc == BSDGENRAT)
        *EMmsg = EMS_I_DegenerateEdge;

      proj_info[i].tangent[0] = left_deriv[1][0];
      proj_info[i].tangent[1] = left_deriv[1][1];
      proj_info[i].proj_pt[X] = left_deriv[0][0];
      proj_info[i].proj_pt[Y] = left_deriv[0][1];
      if( (dist = EM2ddistptpt(start_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_lfend;
      else if( (dist = EM2ddistptpt(stop_pt, proj_info[i].proj_pt)) < lentol)
       proj_info[i].location = EMScvint_rtend;
      else proj_info[i].location = EMScvint_middle;
    }
   }
   else
   {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
   }

 /*
  * Correction to location may be needed if the point to be projected is
  * at the end-point of a closed curve.
  */

 if (closed && proj_info[i].location != EMScvint_middle)
   {
   if (fabs (chkpar - startpar) < fabs (chkpar - stoppar))
     proj_info[i].location = EMScvint_lfend;
   else
     proj_info[i].location = EMScvint_rtend;
   }
  if (projected_params) free (projected_params);
  if (interval_params) free (interval_params);
  projected_params = interval_params =NULL;
  } /* end for loop */
 } /* end if boundaries */

wrapup:
  BSchgdeppar (basis_tol, &rc);

  if (no_params > 1 )
   *EMmsg = EMS_I_Ambiguous;
  if (part_edge.poles) free (part_edge.poles);
  if (part_edge.knots) free (part_edge.knots);
  if (part_edge.weights) free (part_edge.weights);
  if (part_edge.bdrys) free (part_edge.weights);

  if (whole_edge.poles) free (whole_edge.poles);
  if (whole_edge.knots) free (whole_edge.knots);
  if (whole_edge.weights) free (whole_edge.weights);
  if (whole_edge.bdrys) free (whole_edge.bdrys);

  if (projected_params) free (projected_params);
  if (interval_params) free (interval_params);

  EMWRAPUP (*EMmsg, status, "In EMSbsedge:EMptprojec error ");
  return (status);

}
end implementation EMSbsedge;
