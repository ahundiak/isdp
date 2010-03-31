/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/* 
 * DESCRIPTION
 *
 * This method returns the basis parmateric tolerance of the surface.
 *
 * INPUT
 *
 * EMmsg				Function return value (EMS_S_Success if success).
 * surf					Pointer to surface geometry.
 * 
 *
 * RETURN VALUES
 *
 * OM_stat				OM_S_SUCCESS if success.
 * partolbasis			Parametric basis tolerance of the surface.
 *
 * NOTES
 *
 * The geometry stored in the surface's instance data is in local
 * coordinates. The relevant geometry is obtained by transforming the
 * surface by the input matrix, which gives geometry in the current
 * master file space which is termed as the world coordinate system.
 * If the tolerance is required in local space, this transformation is
 * not done.
 *
 * BUGS
 *
 * For now the tolerance is always computed, regardless of whether it
 * it is stored in the instance data or not. It is possible that some
 * classes have this stored and some don't. Those classes that will not
 * store this value will disregard the request to not compute.
 *
 * HISTORY
 *
 * 07/08/93  Sudha  Modified for BSprototypes ansification
 * 28-Jun-88: SM  : This function was setting surf->num_boundaries to 0.
 *		    Upon exit restore caller's data.
 * 11/20/87 : SAM : EMssptolbas.I was used to create this function.
 * 03/19/87 : SS  : Design and creation of EMssptolbas.I.
 */

# include "OMerrordef.h"
#include  "OMminimum.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "emserr.h"
# include "bserr.h"
# include "bsparameters.h"
# include "EMSbnddef.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMSmsgdef.h"
#include "bssfkttol2.h"
#include "bschangepar.h"

IGRlong EFsspbtol_by_geom (EMmsg, surf, partolbasis)
  IGRlong *EMmsg;                         /* Error return code */
  struct  IGRbsp_surface *surf;
  IGRdouble *partolbasis;
{
  IGRlong OM_stat;
  IGRlong msg_loc, msg_loc2;
  IGRdouble parlentol, lentol, savetol;
  IGRshort	save_num_bdrys = 0;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  save_num_bdrys = surf->num_boundaries;
  surf->num_boundaries = 0;

  /*
   * Call the math function that computes
   * the zero-length-of-vector tolerance in
   * parametric space. This tolerance is to be based
   * on zero-length vector tolerance in model-space, but the
   * math uses knot-tolerance. So set the knot tolerance
   * before calling the math function; then reset it.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLKNOT, savetol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSchangepar (&msg_loc, BSTOLKNOT, lentol);
  BSsfkttol2 (surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
   surf->u_num_poles, surf->v_num_poles, surf->poles, surf->weights,
   &parlentol, &msg_loc);
  BSchangepar (&msg_loc2, BSTOLKNOT, savetol);
  EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_Fail, ret_end);

  /*
   * the relationship between the parametric zero-length-of-vector
   * tolerance and the basis tolerance is identity. Further, if the
   * parametric length tolerance is smaller than EMS_LOW_UVLEN or
   * greater than EMS_HIGH_UVLEN, then the tolerance is adjusted to
   * these values respectively.
   */

  EMadjust_paramtol (&msg_loc, surf, parlentol, partolbasis);

ret_end:
 surf->num_boundaries = save_num_bdrys;
 return (OM_stat);
}
