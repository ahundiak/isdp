/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "maerr.h"
#include "bserr.h"

method EMruled_surface(
 struct IGRbsp_curve *curve_1;           /* Input curve 1 data */
 struct GRlc_info *located_curve_1;      /* Input curve 1 object */
 struct IGRbsp_curve *curve_2;           /* Input curve 2 data */
 struct GRlc_info *located_curve_2;      /* Input curve 2 object */
 IGRint number_of_control_points;        /* # of matching points */
 IGRpoint curve_1_points[];              /* matching points on 1 */
 IGRpoint curve_2_points[];              /* matching points on 2 */
 IGRpoint curve_end_points[2];           /* matching end points */
 IGRboolean nat_side;                    /* true, if surface is
                                            pointing into the solid */
 IGRboolean reverse_curve_1;             /* Reverse curve 1? */
 IGRboolean reverse_curve_2;             /* Reverse curve 2? */
 IGRshort options;                       /* [0,1,2] effects constructed sf */
 IGRboolean not_used_2;                  /* Carried over from a previous life*/
 struct GRvg_construct *construct_list;  /* construction data */
 IGRlong *msg)                           /* error return code */
/*
 Notes

        Upon exit the completion code will be one of

        - MSSUCC, if successful
        - MSFAIL, if failed to generate results
        - MSINARG, if no curve was sent in
        - MANOMEMORY, if unable to allocate memory

        If a failure occurs, then the object will commit suicide.

        The input curves are determined by first checking to see if the
        pointer to the curve data structure is not NULL.  If it is not
        then this curve is used, else it is assumed the curve data is
        located in the input curve object.

        The input arguments are further explained in the specification
        file.

 History

 Sanjay 08/25/94    BSroutine  BSrulsfeqpr() does not normalize the ruled 
                    surface geometry. But in EMS every functionality assumes
                    that the geometry is normalized one and because of which
                    lot of problems will come into picture. Now  made a fix 
                    to normalize the geometry irrespective of any routine 
                    which is being used to generate the ruled surface as I am 
                    not sure whether the routine BSdevrulsf() normalizes the
                    geometry or not.  
   Jack 01/11/93    Moved implementation from EMSgenbs to EMSsubbs to aid in
                    analytic surface creation.
    rlw 10/04/89    Was calling wrong math routine for developable ruled sf.
    rlw 06/23/89    Added option for developable.
    rlw 05/02/89    Modified the ruled surface method.  Changed one of the
                    not_used arguments to an option flag for creation of
                    the surface.
    rlw 02/17/88    Reworked.  I changed the arguments but in doing so I
                    believe that the changes will only effect ruled surface
                    with control.
    dhm 07/23/87    Added functionality to reparameterize a closed
                    curve at a given start point.
    PP  06-Feb-1987 Added functionality to flag the
                    surface orientation based on the orientation flag 
    RLW 29-Dec-1986 Modified for solids and change in math.
    RLW 05-Dec-1986 The beginning.
    
*/

{
 IGRlong        loc_msg;
 IGRdouble	*curve_1_parameters, *curve_2_parameters;
 struct         IGRbsp_curve *generating_curve_1, *generating_curve_2;
 struct		IGRbsp_curve *malloced_curve_1, *malloced_curve_2;
 struct         IGRbsp_surface *surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 generating_curve_1 = NULL;
 malloced_curve_1 = NULL;
 curve_1_parameters = NULL;
 generating_curve_2 = NULL;
 malloced_curve_2 = NULL;
 curve_2_parameters = NULL;
 surface = NULL;
/*
 * Get the geometry for curve 1
 */
 if (curve_1)
  {
   generating_curve_1 = curve_1;
  }
 else if (located_curve_1)
  {
   IGRlong	sts;

   sts = EMget_the_geometry(
     located_curve_1,
     TRUE,				/* It is a curve */
     FALSE,				/* It's not directed */
     FALSE,				/* One large malloc will do */
     my_id,
     &generating_curve_1,
     msg);
    if (!(1 & sts)) goto wrapup;
  }
 else
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Prepare the curve data
 */
 {
  extern	void BSalloccv();
  extern	void BSprptsoncv();
  IGRboolean	were_all_points_on_curve;
  IGRlong	poles_needed;

  if (generating_curve_1->phy_closed)
   poles_needed = 2 * generating_curve_1->num_poles;
  else
   poles_needed = generating_curve_1->num_poles;
  BSalloccv(
    generating_curve_1->order,
    poles_needed,
    generating_curve_1->rational,
    0,
    &malloced_curve_1,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (generating_curve_1->phy_closed &&
      number_of_control_points)
   {
    extern		IGRboolean BSprptoncv();
    extern		IGRboolean BSclcvshffl();
    IGRboolean		status;
    IGRboolean		is_point_on_curve, keep_original_sense;
    IGRdouble		u;

    status = BSprptoncv(
      &loc_msg,
      generating_curve_1,
      curve_1_points[0],
      &u,
      &is_point_on_curve);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    keep_original_sense = !reverse_curve_1;
    status = BSclcvshffl(
      &loc_msg,
      generating_curve_1,
      &u,
      &keep_original_sense,
      malloced_curve_1);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* if (curve->phy_closed && ... */
  else
   {
    extern	IGRboolean BScv_copy();
    IGRboolean	status;

    status = BScv_copy(
      &loc_msg,
      generating_curve_1,
      malloced_curve_1);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    if (reverse_curve_1)
     {
      extern	IGRboolean BSrev_cv();

      status = BSrev_cv(
        &loc_msg,
        malloced_curve_1);
       if (!status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     }
    else if (curve_end_points)
     {
      extern	IGRboolean BSdirectcv();

      status = BSdirectcv(
        &loc_msg,
        curve_end_points[0],
        malloced_curve_1,
        malloced_curve_1);
       if (!status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     }
   }
  curve_1_parameters = (IGRdouble *) malloc(
    (number_of_control_points + 2) * sizeof(IGRdouble));
   if (! curve_1_parameters)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (number_of_control_points)
   {
    BSprptsoncv(
      number_of_control_points,
      curve_1_points,
      malloced_curve_1,
      curve_1_parameters,
      &were_all_points_on_curve,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   }
  else
   {
    IGRlong	first_knot;

    first_knot = malloced_curve_1->order - 1;
    curve_1_parameters[0] = malloced_curve_1->knots[first_knot];
   }
 }
/*
 * Get the geometry for curve 2
 */
 if (curve_2)
  {
   generating_curve_2 = curve_2;
  }
 else if (located_curve_2)
  {
   IGRlong	sts;

   sts = EMget_the_geometry(
     located_curve_2,
     TRUE,				/* It is a curve */
     FALSE,				/* It's not directed */
     FALSE,				/* One large malloc will do */
     my_id,
     &generating_curve_2,
     msg);
    if (!(1 & sts)) goto wrapup;
  }
 else
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Prepare the curve data
 */
 {
  extern	void BSalloccv();
  extern	void BSprptsoncv();
  IGRboolean	were_all_points_on_curve;
  IGRlong	loc_msg, poles_needed;

  if (generating_curve_2->phy_closed)
   poles_needed = 2 * generating_curve_2->num_poles;
  else
   poles_needed = generating_curve_2->num_poles;
  BSalloccv(
    generating_curve_2->order,
    poles_needed,
    generating_curve_2->rational,
    0,
    &malloced_curve_2,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (generating_curve_2->phy_closed &&
      number_of_control_points)
   {
    extern		IGRboolean BSprptoncv();
    extern		IGRboolean BSclcvshffl();
    IGRboolean		status;
    IGRboolean		is_point_on_curve, keep_original_sense;
    IGRdouble		u;

    status = BSprptoncv(
      &loc_msg,
      generating_curve_2,
      curve_2_points[0],
      &u,
      &is_point_on_curve);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    keep_original_sense = !reverse_curve_2;
    status = BSclcvshffl(
      &loc_msg,
      generating_curve_2,
      &u,
      &keep_original_sense,
      malloced_curve_2);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* if (curve->phy_closed && ...) */
  else
   {
    extern	IGRboolean BScv_copy();
    IGRboolean	status;

    status = BScv_copy(
      &loc_msg,
      generating_curve_2,
      malloced_curve_2);
     if (!status)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    if (reverse_curve_2)
     {
      extern	IGRboolean BSrev_cv();

      status = BSrev_cv(
        &loc_msg,
        malloced_curve_2);
       if (!status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     }
    else if (curve_end_points)
     {
      extern	IGRboolean BSdirectcv();

      status = BSdirectcv(
        &loc_msg,
        curve_end_points[1],
        malloced_curve_2,
        malloced_curve_2);
       if (!status)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     }
   }
  curve_2_parameters = (IGRdouble *) malloc(
    (number_of_control_points + 2) * sizeof(IGRdouble));
   if (! curve_2_parameters)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (number_of_control_points)
   {
    BSprptsoncv(
      number_of_control_points,
      curve_2_points,
      malloced_curve_2,
      curve_2_parameters,
      &were_all_points_on_curve,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   }
  else
   {
    IGRlong	first_knot;

    first_knot = malloced_curve_2->order - 1;
    curve_2_parameters[0] = malloced_curve_2->knots[first_knot];
   }
 }
/*
 * Form a ruled surface between two curves given
 * alignment information.  This is slightly messy.  I am trying to
 * make intelligent guesses when we have closed curves and a control
 * point at the seam point.  The result will be totally different
 * depending on whether 0 or 1 is picked.
 */
 if (number_of_control_points > 1)
  {
   IGRlong	loc_msg;
   IGRdouble	u_low_1, u_mid_1, u_hig_1;
   IGRdouble	u_low_2, u_mid_2, u_hig_2;
/*
 * Compute the low, middle, and high parameter values
 */
  u_low_1 = malloced_curve_1->knots[malloced_curve_1->order - 1];
  u_hig_1 = malloced_curve_1->knots[malloced_curve_1->num_poles];
  u_mid_1 = (u_hig_1 + u_low_1) / 2.0;
  curve_1_parameters[0] = u_low_1;
  u_low_2 = malloced_curve_2->knots[malloced_curve_2->order - 1];
  u_hig_2 = malloced_curve_2->knots[malloced_curve_2->num_poles];
  u_mid_2 = (u_hig_2 + u_low_2) / 2.0;
  curve_2_parameters[0] = u_low_2;
/*
 * Fix endpoint conditions on curve 1
 */
  if (malloced_curve_1->phy_closed)
   {
    extern	void BScvkttol2();
    IGRlong	loc_msg, i;
    IGRdouble	knot_tol;
 	
    BScvkttol2(
      malloced_curve_1->order,
      malloced_curve_1->knots,
      malloced_curve_1->num_poles,
      malloced_curve_1->poles,
      malloced_curve_1->weights,
      &knot_tol,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
     for (i = 1; i < number_of_control_points; i++)
     {
      if (((curve_1_parameters[i] - u_low_1) < knot_tol) ||
          ((u_hig_1 - curve_1_parameters[i]) < knot_tol))
       {
        if (curve_2_parameters[i] < u_mid_2)
         curve_1_parameters[i] = u_low_1;
        else
         curve_1_parameters[i] = u_hig_1;
       }
     } /* for (i = 1; i < number_of_control_points; i++) */
   } /* if (malloced_curve_1->phy_closed) */
/*
 * Fix endpoint conditions on curve 2
 */
  if (malloced_curve_2->phy_closed)
   {
    extern	void BScvkttol2();
    IGRlong	loc_msg, i;
    IGRdouble	knot_tol;
 	
    BScvkttol2(
      malloced_curve_2->order,
      malloced_curve_2->knots,
      malloced_curve_2->num_poles,
      malloced_curve_2->poles,
      malloced_curve_2->weights,
      &knot_tol,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
     for (i = 1; i < number_of_control_points; i++)
     {
      if (((curve_2_parameters[i] - u_low_2) < knot_tol) ||
          ((u_hig_2 - curve_2_parameters[i]) < knot_tol))
       {
        if (curve_1_parameters[i] < u_mid_1)
         curve_2_parameters[i] = u_low_2;
        else
         curve_2_parameters[i] = u_hig_2;
       }
     } /* for (i = 1; i < number_of_control_points; i++) */
   } /* if (malloced_curve_2->phy_closed) */
  } /* if (number_of_control_points > 1) */
 else if (number_of_control_points == 0)
  number_of_control_points = 1;
/*
 * Create the ruled surface
 */
 {
  IGRlong	loc_msg;

  if ((options == 0) ||
      (options == 1))
   {
    extern	void BSrulsfeqpr();
    IGRboolean	equal_arclength;

    equal_arclength = (options == 1);
    BSrulsfeqpr(
      malloced_curve_1,
      malloced_curve_2,
      number_of_control_points,
      curve_1_parameters,
      curve_2_parameters,
      equal_arclength,
      &surface,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   }
  else if (options == 2)
   {
    extern	void BSdevrulsf();
    IGRlong	seg_num, *seg_type;
    IGRdouble	*seg_par;

    seg_type = NULL;
    seg_par = NULL;
    BSdevrulsf(
      malloced_curve_1,
      malloced_curve_2,
      &seg_num,
      &seg_type,
      &seg_par,
      &surface,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    if (seg_type) free(seg_type);
    if (seg_par) free(seg_par);
   }
  else
   {
    *msg = MSINARG;
    goto wrapup;
   }
 }

/*
 * Normalize the knot vectors of the surface. Because, it is always better to 
 * keep the KNOT VECTOR with in "0 and 1" limits as this is the generalized 
 * definition of NURBS. -- Sanjay 
 */
(void) BSsnorkts( surface->u_order, surface->v_order, surface->u_num_poles,
                  surface->v_num_poles, surface->u_knots, surface->v_knots,
                  (IGRint) 2, &loc_msg );
if (loc_msg != BSSUCC)
{
   *msg = MSFAIL;
   goto wrapup;
}

/*
 * If orientation flag is true then natural normal of the surface is
 * pointing into the solid.
 */
 if (nat_side)
  surface->pos_orient = 1;
 else
  surface->pos_orient = 0;
/*
 * Fill the instance data and such
 */
 {
  IGRlong	sts;

  construct_list->geometry = (IGRchar *) surface;
  sts = om$send(
    msg = message GRgraphics.GRconstruct(construct_list),
    targetid = my_id);
   if (!(1 & sts)) *msg = *(construct_list->msg);
 }
/*
 * End of routine
 */
wrapup:
 if ((!curve_1 && located_curve_1) && generating_curve_1) 
  free(generating_curve_1);
 if ((!curve_2 && located_curve_2) && generating_curve_2) 
  free(generating_curve_2);
 if (curve_1_parameters) free(curve_1_parameters);
 if (curve_2_parameters) free(curve_2_parameters);
 if (malloced_curve_1)
  {
   extern	IGRboolean BSfreecv();
   IGRboolean	status;

   status = BSfreecv(
    &loc_msg,
    malloced_curve_1);
  }
 if (malloced_curve_2)
  {
   extern	IGRboolean BSfreecv();
   IGRboolean	status;

   status = BSfreecv(
    &loc_msg,
    malloced_curve_2);
  }
 if (surface)
  {
   extern	IGRboolean BSfreesf();
   IGRboolean	status;

   status = BSfreesf(
    &loc_msg,
    surface);
  }
 *(construct_list->msg) = *msg;
 if (! (1 & *msg))
  {
   IGRlong	sts;

   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation EMSsubbs;
