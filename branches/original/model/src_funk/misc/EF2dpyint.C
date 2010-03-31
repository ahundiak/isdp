# include "OMminimum.h"
# include "msdef.h" 
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "bs.h"				
# include "bsparameters.h"
# include "ma.h"				
# include "msmacros.h"				
# include "emsdattyp.h"
# include "emsinter.h"
# include "emsbreak.h"
# include "emsdef.h"

#define X 0
#define Y 1

#define ZERO 0
#define NEGATIVE 1
#define POSITIVE 2
#define ZERO_NEGATIVE ZERO + NEGATIVE
#define NEG_POSITIVE NEGATIVE + POSITIVE

#define T_S 0
#define T_T 1
#define S_S 2
#define S_T 3
/* 
 * DESCRIPTION
 *
 * Given two 2d lines this routine will compute their intersection, if
 * any.
 *
 * RETURN VALUES
 *
 * status	if TRUE then intersection was found
 *		else no intersection was found
 *
 * type_w	EMScvint_middle    Intersection not at endpoint
 *		EMScvint_end       Intersection at endpoint (Not colinear)
 *		EMScvint_endcoll   Intersection at endpoint (Colinear lines)
 *		EMScvint_collapsed Intersection (line was a point)
 *		EMScvint_overlap   Intersection is a line
 *
 * par_w	if (status is FALSE) then invalid
 *		if (status is TRUE) and (type_c is not EMint_OVERLAP) then
 *		  par_w[0] is parameter on W line
 *		if (status is TRUE) and (type_c is EMint_OVERLAP) then
 *		  par_w[0] is starting parameter on W line
 *		  par_w[1] is ending parameter on W line
 *
 * type_c	EMScvint_middle    Intersection not at endpoint
 *		EMScvint_end       Intersection at endpoint (Not colinear)
 *		EMScvint_endcoll   Intersection at endpoint (Colinear lines)
 *		EMScvint_collapsed Intersection (line was a point)
 *		EMScvint_overlap   Intersection is a line
 *
 * par_c	if (status is FALSE) then invalid
 *		if (status is TRUE) and (type_w is not EMScvint_overlap) then
 *		  par_c[0] is parameter on C line
 *		if (status is TRUE) and (type_w is EMScvint_overlap) then
 *		  par_c[0] is starting parameter on C line
 *		  par_c[1] is ending parameter on C line
 *
 * pt		if (status is FALSE) then invalid
 *		if (status is TRUE) && (neither type is not EMScvint_overlap) 
 *                then  pt[0] is intersection
 *		if (status is TRUE) and (both types are EMScvint_overlap) then
 *		  pt[0] is first point of intersection line
 *		  pt[1] is second point of intersection line
 *
 * msg		MSSUCC, if success
 *		MSFAIL, if failure => note that this implies that an
 *		assertion made by this routine was incorrect (failed) and is
 *		most likely a coding or algorithm problem in this routine
 * NOTES
 *
 * If one type is EMScvint_overlap then the other will be the same.
 *
 * The following tolerances are used:
 *
 * BSTOLCOLLINVEC	tolerance to check cross product for colinear vectors
 * BSTOLSQLENVEC	small distance squared (zero distance squared)
 * BSTOLLENVEC		small distance (zero distance)
 *
 * If the caller passes in a NULL pointer to the basis tolerance then these
 * tolerances are retrieved via BSEXTRACTPAR, else they are retrieved via
 * EXextract_par.
 *
 * HISTORY
 *
 * 12/20/86 : rlw : creation date (I mauled Siki's code)
 * 01/27/87 : rlw : repaired tolerancing problem which occurred when
 *                  the lines were almost colinear
 * 03/17/87 : rlw : added additional argument to allow the user to optionally
 *                  pass in a basis tolerance
 * 06/17/87 : sm  : corrected enum definition EMScvint_type to
 *                  EMScvinttype.
 * 11/18/88 : rlw : Modified not to use the sign_cross() functions because
 *                  of tolerancing problems.  Changed the calls to use
 *                  Siki's EM2dcrossp().
 */


IGRboolean EF2dpyint(
 basis_tolerance,		/* Pointer to optional basis tolerance */
 cpt1, 				/* Point 1 of C line */
 cpt2, 				/* Point 2 of C line */
 wpt1, 				/* Point 1 of W line */
 wpt2, 				/* Point 2 of W line */
 type_w,			/* Type of intersection on W line */
 par_w,				/* Parameters for intersection on W line */
 type_c,			/* Type of intersection on C line */
 par_c,				/* Parameters for intersection on C line */
 pt,				/* Intersections point(s) */
 msg)				/* Error return code */

IGRdouble	*basis_tolerance;
IGRdouble	cpt1[2], cpt2[2];
IGRdouble 	wpt1[2], wpt2[2];
enum		EMScvinttype *type_w, *type_c;
IGRdouble	par_w[2], par_c[2];
IGRdouble	pt[2][2];
IGRlong		*msg;

{
 IGRboolean	EFextract_par();
 IGRshort	s1, s2, s3, s4, status;
 IGRint		EM2dcrossp();
 IGRlong	msg_loc;
 IGRdouble	c1, c2, c3, c4;
 IGRdouble 	ac1, ac2, ac3, ac4;
 IGRdouble	vc[2], vc1[2], vc2[2];
 extern  IGRdouble  sqrt();
 IGRdouble	cross_tol;
/*
 * Get the tolerance
 */
 *msg = MSSUCC;
 if (basis_tolerance)
  status = EFextract_par(BSTOLCOLLINVEC, *basis_tolerance, &cross_tol, msg);
 else
  status = BSEXTRACTPAR(&msg_loc, BSTOLCOLLINVEC, cross_tol);
 if (!status)
  {
   *msg = MSFAIL;
   return(FALSE);
  }
/*
 * Compute the vectors
 */
 vc[X] = cpt2[X] - cpt1[X];
 vc[Y] = cpt2[Y] - cpt1[Y];
 vc1[X] = wpt1[X] - cpt1[X];
 vc1[Y] = wpt1[Y] - cpt1[Y];
 vc2[X] = wpt2[X] - cpt1[X];
 vc2[Y] = wpt2[Y] - cpt1[Y];
/*
 * Compute the cross products
 */
 s3 = EM2dcrossp (&cross_tol, vc, vc1, &ac3, &c3);
 s4 = EM2dcrossp (&cross_tol, vc, vc2, &ac4, &c4);
/*
 * If the following check is true, no endpoint condition exists
 * on the W vector.
 */
 if (s3 != ZERO && s4 != ZERO)                         
  {
   IGRdouble vw[2], vw1[2], vw2[2];
/*
 * W-vector on the same side of C-vector.  Hence reject.
 */
   if (s3 == s4) return (FALSE);          
/*
 * Compute the vectors
 */
   vw[X] = wpt2[X] - wpt1[X];
   vw[Y] = wpt2[Y] - wpt1[Y];
   vw1[X] = cpt1[X] - wpt1[X];
   vw1[Y] = cpt1[Y] - wpt1[Y];
   vw2[X] = cpt2[X] - wpt1[X];
   vw2[Y] = cpt2[Y] - wpt1[Y];
/*
 * Compute the cross-products
 */
   s1 = EM2dcrossp (&cross_tol, vw, vw1, &ac1, &c1);
   s2 = EM2dcrossp (&cross_tol, vw, vw2, &ac2, &c2);
/*
 * C-vector on the same side of W-vector.  Hence reject.
 */
   if (s1 == s2) return (FALSE);                    
/*
 * Compute the intersection
 */
   if (s1 == ZERO)
    {
     pt[0][X] = cpt1[X];
     pt[0][Y] = cpt1[Y];
     par_c[0] = 0.0;
     *type_c = EMScvint_end;
    }
   else if (s2 == ZERO)
    {
     pt[0][X] = cpt2[X];
     pt[0][Y] = cpt2[Y];
     par_c[0] = 1.0;
     *type_c = EMScvint_end;
    }
   else
    {
     *type_c = EMScvint_middle;
     par_c[0] = ac1 / (ac1 + ac2);
     pt[0][X] = cpt1[X] + par_c[0] * vc[X];
     pt[0][Y] = cpt1[Y] + par_c[0] * vc[Y];
    }
   *type_w = EMScvint_middle;
   par_w[0] = ac3 / (ac3 + ac4);
  }
 else
  {
/*
 * If s3=s4=ZERO then s1=s2=ZERO, i.e. all points are colinear or 
 * there is some coincidence.
 */
   if ((s3 == ZERO) && (s4 == ZERO))
    {
     IGRlong		c_is_zero_length, w_is_zero_length;
     IGRdouble		dist_sqtol, dist_tol, vw[2];
     IGRdouble		distance_squared, par_tol;
     IGRdouble		c_magnitude, w_magnitude;

     if (basis_tolerance)
      status = EFextract_par(BSTOLSQLENVEC, *basis_tolerance, &dist_sqtol,msg);
     else
      status = BSEXTRACTPAR(&msg_loc, BSTOLSQLENVEC, dist_sqtol);
     if (!status)
      {
       *msg = MSFAIL;
       return(FALSE);
      }
     if (basis_tolerance)
      status = EFextract_par(BSTOLLENVEC, *basis_tolerance, &dist_tol, msg);
     else
      status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, dist_tol);
     if (!status)
      {
       *msg = MSFAIL;
       return(FALSE);
      }
     c_magnitude = vc[X] * vc[X] + vc[Y] * vc[Y];
     c_is_zero_length = (c_magnitude < dist_sqtol);
     vw[X] = wpt2[X] - wpt1[X];
     vw[Y] = wpt2[Y] - wpt1[Y];
     w_magnitude = vw[X] * vw[X] + vw[Y] * vw[Y];
     w_is_zero_length = (w_magnitude < dist_sqtol);
/*
 * If the two vectors are points then check and see if they are the same
 */
     if (c_is_zero_length && w_is_zero_length) /* C and W vectors are pnts */
      {
       distance_squared = vc1[X] * vc1[X] + vc1[Y] * vc1[Y];
       if (distance_squared > dist_sqtol) return(FALSE);
       pt[0][X] = cpt1[X];
       pt[0][Y] = cpt1[Y];
       par_c[0] = 1.0;
       par_w[0] = 0.0;
       *type_c = EMScvint_collapsed;
       *type_w = EMScvint_collapsed;
      }
/*
 * If the C vector is a point then check and see if it lies on the W line.
 * This is done by computing the parameter of the C point wrt the W line
 * and comparing it to the parametric range [0,1].
 */
     else if (c_is_zero_length)
      {
       IGRdouble	vw1[2];

       vw1[X] = cpt1[X] - wpt1[X];
       vw1[Y] = cpt1[Y] - wpt1[Y];
       par_w[0] = (vw[X] * vw1[X] + vw[Y] * vw1[Y]) / w_magnitude;
       par_tol = dist_tol / sqrt(w_magnitude);
       if ((par_w[0] > -par_tol) && (par_w[0] < par_tol))
        {
         *type_w = EMScvint_end;         
         par_w[0] = 0.0;
        }
       else if ((par_w[0] > (1.0 - par_tol)) && (par_w[0] < (1.0 + par_tol)))
        {
         *type_w = EMScvint_end;
         par_w[0] = 1.0;
        }
       else if ((par_w[0] > 0.0) && (par_w[0] < 1.0))
        *type_w = EMScvint_middle;         
       else
        return(FALSE);
       *type_c = EMScvint_collapsed;
       par_c[0] = 1.0;
       pt[0][X] = cpt1[X];
       pt[0][Y] = cpt1[Y];
      }
/*
 * If the W vector is a point then check and see if it lies on the C line.
 * This is done by computing the parameter of the W point wrt the C line
 * and comparing it to the parametric range [0,1].
 */
     else if (w_is_zero_length)
      {
       par_c[0] = (vc[X] * vc1[X] + vc[Y] * vc1[Y]) / c_magnitude;
       par_tol = dist_tol / sqrt(c_magnitude);
       if ((par_c[0] > -par_tol) && (par_c[0] < par_tol))
        {
         *type_c = EMScvint_end;
         par_c[0] = 0.0;
        }
       else if ((par_c[0] > (1.0 - par_tol)) && (par_c[0] < (1.0 + par_tol)))
        {
         *type_c = EMScvint_end;
         par_c[0] = 1.0;
        }
       else if ((par_c[0] > 0.0) && (par_c[0] < 1.0))
        *type_c = EMScvint_middle;         
       else
        return(FALSE);
       *type_w = EMScvint_collapsed;
       par_w[0] = 0.0;
       pt[0][X] = wpt1[X];
       pt[0][Y] = wpt1[Y];
      }
/*
 * Neither W or C is a collapsed vector.  At this stage in the game
 * an overlap is possible, the endpoints match, or the lines do not
 * intersect.  A way to resolve this is to convert one of the lines to
 * the parametric space of the other line and check it against the
 * range [0,1].  I chose to map the W vector into C space.
 */
     else
      {
       IGRboolean	reversed = FALSE;
       IGRdouble	par_w_in_c[2], temp;

       par_w_in_c[0] = (vc[X] * vc1[X] + vc[Y] * vc1[Y]) / c_magnitude;
       par_w_in_c[1] = (vc[X] * vc2[X] + vc[Y] * vc2[Y]) / c_magnitude;
       par_tol = dist_tol / sqrt(c_magnitude);
       if (par_w_in_c[0] > par_w_in_c[1])
        {
         reversed = TRUE;
         temp = par_w_in_c[0];
         par_w_in_c[0] = par_w_in_c[1];
         par_w_in_c[1] = temp;
        }
/*
 * Check to see if the line is to the far right, far left, just touching
 * on the right or just touching on the left.
 */
       if (par_w_in_c[0] > (1.0 + par_tol))
        return(FALSE);
       else if (par_w_in_c[1] < -par_tol)
        return(FALSE);
       else if (par_w_in_c[0] > (1.0 - par_tol))
        {
         *type_w = EMScvint_endcoll;
         *type_c = EMScvint_endcoll;
         par_c[0] = 1.0;
         if (reversed)
          par_w[0] = 1.0;
         else
          par_w[0] = 0.0;
         pt[0][X] = cpt2[X];
         pt[0][Y] = cpt2[Y];
        }
       else if (par_w_in_c[1] < par_tol)
        {
         *type_w = EMScvint_endcoll;
         *type_c = EMScvint_endcoll;
         par_c[0] = 0.0;
         if (reversed)
          par_w[0] = 0.0;
         else
          par_w[0] = 1.0;
         pt[0][X] = cpt1[X];
         pt[0][Y] = cpt1[Y];
        }
/*
 * Overlap condition definitely exists
 */
       else
        {
         IGRdouble	vw1[2], vw2[2];

         if (par_w_in_c[0] < par_tol) par_w_in_c[0] = 0.0;
         if (par_w_in_c[1] > (1.0 - par_tol)) par_w_in_c[1] = 1.0;
         *type_w = EMScvint_overlap;
         *type_c = EMScvint_overlap;
         par_c[0] = par_w_in_c[0];
         par_c[1] = par_w_in_c[1];
         pt[0][X] = cpt1[X] + par_c[0] * (cpt2[X] - cpt1[X]);
         pt[0][Y] = cpt1[Y] + par_c[0] * (cpt2[Y] - cpt1[Y]);
         pt[1][X] = cpt1[X] + par_c[1] * (cpt2[X] - cpt1[X]);
         pt[1][Y] = cpt1[Y] + par_c[1] * (cpt2[Y] - cpt1[Y]);
/*
 * Map the intersections into W parametric space
 */
         vw1[X] = pt[0][X] - wpt1[X];
         vw1[Y] = pt[0][Y] - wpt1[Y];
         vw2[X] = pt[1][X] - wpt1[X];
         vw2[Y] = pt[1][Y] - wpt1[Y];
         par_w[0] = (vw[X] * vw1[X] + vw[Y] * vw1[Y]) / w_magnitude;
         par_w[1] = (vw[X] * vw2[X] + vw[Y] * vw2[Y]) / w_magnitude;
         par_tol = dist_tol / sqrt(w_magnitude);
         if (par_w[0] < par_tol) 
          par_w[0] = 0.0;
         else if (par_w[0] > (1.0 - par_tol)) 
          par_w[0] = 1.0;
         if (par_w[1] < par_tol) 
          par_w[1] = 0.0;
         else if (par_w[1] > (1.0 - par_tol)) 
          par_w[1] = 1.0;
        }
      }
    }
   else 
    {
     IGRdouble vw[2], vw1[2], vw2[2];
/*
 * Compute the vectors
 */
     vw[X] = wpt2[X] - wpt1[X];
     vw[Y] = wpt2[Y] - wpt1[Y];
     vw1[X] = cpt1[X] - wpt1[X];
     vw1[Y] = cpt1[Y] - wpt1[Y];
     vw2[X] = cpt2[X] - wpt1[X];
     vw2[Y] = cpt2[Y] - wpt1[Y];
/*
 * Compute the cross-products
 */
     s1 = EM2dcrossp (&cross_tol, vw, vw1, &ac1, &c1);
     s2 = EM2dcrossp (&cross_tol, vw, vw2, &ac2, &c2);
/*
 * Does an end-point condition exist on the extended line out of bounds?
 */
     if (s1 == s2) return(FALSE);
/*
 * At this point we know there is a valid endpoint intersection on one
 * endpoint of the W vector and perhaps an endpoint on the C vector.
 *
 * Find the intersection on the C vector.
 */
     if (s1 == ZERO)
      {
       if (s2 == ZERO)
        {
         *msg = MSFAIL;
         return(FALSE);
        }
       par_c[0] = 0.0;
       *type_c = EMScvint_end;
      }
     else if (s2 == ZERO)
      {
       par_c[0] = 1.0;
       *type_c = EMScvint_end;
      }
     else			/* neither is zero */
      {
       par_c[0] = ac1 / (ac1 + ac2);
       *type_c = EMScvint_middle;
      }
/*
 * Compute the intersection on the W vector (It must be on an endpoint)
 */
     *type_w = EMScvint_end;
     if (s3 == ZERO)
      {
       pt[0][X] = wpt1[X];
       pt[0][Y] = wpt1[Y];
       par_w[0] = 0.0;
      }
     else /* if (s4 == ZERO) */
      {
       pt[0][X] = wpt2[X];
       pt[0][Y] = wpt2[Y];
       par_w[0] = 1.0;
      }
    }
  }
 return(TRUE);
}

