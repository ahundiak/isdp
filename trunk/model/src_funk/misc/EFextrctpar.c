/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to return tolerances which are based
 * on some basis_tolerance.  It returns a requested tolerance based on
 * the input basis tolerance.  This was written so that we could generate
 * a parametric based tolerance such as cross product, dot product, ...,
 * etc. as is done by the math group for model space tolerances.
 *
 * RETURN VALUES
 *
 * status               if TRUE then no problems else failure
 * tolerance		the return tolerance
 * msg                  MSSUCC if success
 *                      MSINARG if input index is invalid
 * NOTES
 *
 * Valid fields are those defined in "ems_ml/include/bsparameters.h"
 * which are based on the basis tolerance.
 *
 * HISTORY
 *
 * 08/23/88 : pp  : Added the calculation of parametric chord height
 *                  tolerance. The routine would extract the model space
 *                  basis tolerance and model space chord height tolerance
 *                  and calculate a proportional parametric chord height tol
 *                  based on the parametric basis tolerance being passed in.
 * 03/17/87 : rlw : creation date
 */
# include "EMS.h"

/* igr.h replacement */

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "bs.h"
#include "bsparameters.h"

IGRboolean EFextract_par(
 field_name,			/* Name of the field - actually an index */
 basis_tolerance,		/* The tolerance on which to base the output */
 tolerance,			/* The resulting tolerance */
 msg)				/* Error return code */

IGRint		field_name;
IGRdouble	basis_tolerance;
IGRdouble	*tolerance;
IGRlong		*msg;

{
/*
  Initialze
 */
 *msg = MSSUCC;
/*
  Branch based on the tolerance requested
 */
 switch (field_name)
  {
/*
a tolerance against which to test the nearness of a triple product with
zero  -- (trpl_tol)
 */
   case BSTOLTRPLPROD:
    *tolerance = .5 * basis_tolerance;
    break;
/*
   a tolerance against which to test the nearness of a vectors length
   with zero -- (dist_tol)
 */
   case BSTOLLENVEC:
    *tolerance = basis_tolerance;
    break;
/*
   a tolerance against which to test the nearness of a vectors squared length
   with zero -- (dist_sqtol)
 */
   case BSTOLSQLENVEC:
    *tolerance = basis_tolerance * basis_tolerance * 10.0;
    break;
/*
   a tolerance against which to test the absolute value of a dot products of
   two vectors to see if if they are orthogonal -- (dot_tol)
 */
   case BSTOLORTHOVEC:
    *tolerance = .5 * basis_tolerance;
    break;
/*
   a tolerance against which to test the absolute value of the length of the
   cross product of two vectors to see if they are collinear -- (cross_tol)
 */
   case BSTOLCOLLINVEC:
    *tolerance = .5 * basis_tolerance;
    break;
/*
   a tolerance against which to test the absolute value of the length of the
   cross product of two vectors to see if they are collinear -- (cross_sqtol)
 */
   case BSTOLSQCOLLINVEC:
    *tolerance = basis_tolerance * basis_tolerance * 2.5;
    break;
/*
   a tolerance for detection of end-of-interation conditions and the difference
   between parameter values -- (par_tol)
 */
   case BSTOLPARAM:
    *tolerance = 1e-3 * basis_tolerance;
    break;
/*
   a tolerance specifically for BSconicgen4 and anyone else who does such
   bizarre things  -- (conic_tol)
 */
   case BSTOLCONICGENCIRCLE:
    *tolerance = basis_tolerance;
    break;
/*
   a tolerance for detection of end-of-interation conditions and the difference
   between knot values -- (knot_tol)
 */   
   case BSTOLKNOT:
    *tolerance = basis_tolerance;
    break;
/*
   the tolerance used to end the iteration in BSqnwt -- (qnwt_tol)
 */
   case BSTOLQNWT:
    *tolerance = basis_tolerance * 1e-1;
    break;
/* 
  tolerance for values close to zero
 */
   case BSTOLCLOSETOZERO:
    *tolerance = basis_tolerance * basis_tolerance / 100;
    break;

   case BSTOLCHRDHT:
   {
    IGRboolean bssts;
    IGRdouble ms_chordheight; /* Model space chord height tolerance */
    IGRdouble ms_basis_tol;   /* Model space basis tolerance */
    IGRint rc;

    bssts = BSEXTRACTPAR(&rc, BSTOLBASIS, ms_basis_tol);
    bssts = BSEXTRACTPAR(&rc, BSTOLCHRDHT,ms_chordheight);

    *tolerance = ms_chordheight * (basis_tolerance / ms_basis_tol);
   }
   break;

/*
  default action
 */
   default:
    *msg = MSINARG;
    break;
  } /* End switch */
/*
 * Eof
 */
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}
