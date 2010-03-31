/*
  DESCRIPTION

    This function is used to compute the cross-product between two
    2D-vectors. It returns the value of the cross-product, the
    absolute value and the sign of the cross-product. Some care is taken
    to see that the sign is output correctly, viz, the result of
    the cross-product, if the vectors had been normalized, is used
    in cases where an ambiguity might arise. The vectors are not explicitly
    normalized for this purpose but the normalization is simulated.

  ARGUMENTS

    tol			- Input: The cross-product tolerance w.r.t which
			  the cross-product is zero. If not supplied (NULL)
                          the cross-product has the sign zero only when
                          it is identically zero.
    v1, v2		- Input: The 2D-vectors.
    aval, val		- Output: the absolute value and the true value
			   respectively. If these have a NULL value, this
                           output is ignored.

  RETURN VALUE

    The function returns the sign of the cross-product:
      
    0 - cross-product is neither positive nor negative (zero w.r.t. tol)
    1 - cross-product is negative
    2 - cross-product is positive

  HISTORY

Tapadia :  03/06/91  :  Fix for TR 91n0715. Changed to use the exact
			vector components while normalizing the vectors. This
			was found necessary because using 'zeroed' components
			can present misleading results especially if there
			are other components which are very small but did not
			get zeroed out being just greater than the tolerance
			value.
    SS  :  05/10/89  :  The tolerance - "tol", and the outputs "aval" and
                        "val" can be set to NULL. See above.
    SS  :  02/24/88  :  Creation
*/

#include <math.h>
#include "igrtypedef.h"

/*
 * While computing the cross-product, this constant is used to determine
 * if the vectors should have been normalized before the computation.
 * If the sign of the cross-product has been evaluated to be zero based
 * on a cross-product value that is greater than this zero-tolerance, the
 * cross-product is reevaluated. This sign is now based on the
 * normalized vectors. Also, if the incoming tolerance is even lesser
 * than this constant, the zero-tolerance is computed as a fraction
 * of the incoming tolerance.
 */

#define ZERO_CROSS_TOL  1e-15
#define PRECISION_FACTOR 0.01
#define CROSSTOL_MAGNIFY_FACTOR 10

#define X 0
#define Y 1

#define ZERO 0
#define NEGATIVE 1
#define POSITIVE 2

IGRint EM2dcrossp (tol, v1, v2, aval, val)
IGRdouble *tol, v1[], v2[], *aval, *val;
{
    IGRboolean zeroed;
    IGRdouble signprod, exactprod, prod, nprod;
    IGRdouble zerotol, cktol, lentol;
    IGRdouble v1x, v1y, v2x, v2y, v1len, v2len;
    IGRint sign;

    /*
     * Obtain the tolerances
     */

    cktol = tol ? *tol : 0.0;
    lentol = cktol + cktol;
    zerotol = ZERO_CROSS_TOL;
    if (cktol < ZERO_CROSS_TOL)
      zerotol = PRECISION_FACTOR * cktol;

    /*
     * If any component of either of the vectors is within
     * lentol, force that component to zero length for calculation
     * of the sign. The computation of the actual value of the 
     * cross-product is exact though.
     */

    v1x = v1[X];
    v1y = v1[Y];
    v2x = v2[X];
    v2y = v2[Y];
    zeroed = FALSE;
    if (fabs (v1x) < lentol)
      {
      v1x = 0.0;
      zeroed = TRUE;
      }
    if (fabs (v1y) < lentol)
      {
      v1y = 0.0;
      zeroed = TRUE;
      }
    if (fabs (v2x) < lentol)
      {
      v2x = 0.0;
      zeroed = TRUE;
      }
    if (fabs (v2y) < lentol)
      {
      v2y = 0.0;
      zeroed = TRUE;
      }

    /*
     * Compute the cross-product values - exact cross-product and
     * the cross-product that can be used for tolerance-sensitive,
     * sign computation.
     */

    if (zeroed)
      {
      exactprod = v1[X] * v2[Y] - v1[Y] * v2[X];
      signprod = v1x * v2y - v1y * v2x;
      }
    else
      {
      exactprod = v1x * v2y - v1y * v2x;
      signprod = exactprod;
      } 

    /*
     * Compute the sign as best as possible - Firstly, the sign is checked
     * for negativity; if not negative it is marked positive. Then, if the
     * absolute cross-product is less than a locally hard-coded zero value
     * (zerotol), it means that the cross-product is zero without doubt. But 
     * if the cross-product is in the grey-area, between this zero-value and
     * a slightly magnified tolerance that's passed in (10*cktol), the vectors
     * are normalized and processed for the sign.
     */

    if (signprod < 0.0) 
      sign = NEGATIVE; 
    else
      sign = POSITIVE;

    if (fabs (signprod) <= zerotol) 
      sign = ZERO;
    else if (fabs (signprod) < CROSSTOL_MAGNIFY_FACTOR * cktol)
      {
      /* 
       * Determine the cross-product of the noramlized vectors. This can
       * be derived in terms of the exact cross product.
       */

      v1len = sqrt (v1[X] * v1[X] + v1[Y] * v1[Y]);
      v2len = sqrt (v2[X] * v2[X] + v2[Y] * v2[Y]);
      nprod = exactprod / (v1len * v2len);

      /*
       * Assign the correct sign based on the above algebraic value.
       */

      if (fabs (nprod) < cktol)
        sign = ZERO;
      else if (nprod > 0.0)
        sign = POSITIVE;
      else
        sign = NEGATIVE;
      }

    /*
     * The exact values of the cross-product (including absolute value)
     * is checked for consistency before return. That is, if the sign
     * is positive the cross-product should not be negative and
     * vice-versa. Such a situation happens only when exact-product and
     * sign-product are of opposite signs and the sign is construed
     * to be non-zero. This should never happen if the tolerances do their
     * job. But if it does, then the value returned is that of the
     * sign-product.
     */

    if (sign == NEGATIVE && exactprod > 0.0 ||
        sign == POSITIVE && exactprod < 0.0)
      prod = signprod;
    else
      prod = exactprod;

    if (val)
      *val = prod;
    if (aval)
      *aval = fabs (prod);

    return (sign);
}

