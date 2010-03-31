class implementation Root;

/*
History 
    JSY	03/19/93	Creation.
    JSY 10/05/93	Use iteration to find a point on the curve but not on
			surface.
*/

#include "EMS.h"
#include "ems_m_inc.h"
#include "emserr.h"
#include "bserr.h"
#include "bscveval.h"
#include "bsmdistptsf.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#inlcude "bsbx2.h"

/*
 * This function display a indicator on a curve with respect to the surface.
 * 
 * INPUTS
 *
 *  lc_surf	Surface located information; NULL if geom_surf is passed in.
 *
 *  geom_surf	Surface geometry; NULL if lc_surf is passed in.
 *
 *  lc_curve	Curve located information; NULL if geom_curve is passed in.
 *
 *  geom_curve	Curve geometry; NULL if lc_curve is passed in.
 *
 *  u_par	The U parameter on the curve where the vector is draw. If
 *		NULL, then the middle point on the curve is selected.
 *
 *  display	Display information.
 *
 *  display_env Module information.
 *
 *  mode	GRbd, GRhd, GRbe, GRhe, ...
 *
 *  reverse	If TRUE then the arrow is drawn in opposite direction.
 *
 *  msg		MSSUCC or MAFAIL.
 */

#define MAXNUM_TRY_POINTS 20

IGRint EMdisplay_curve_ind(msg,
			   lc_surf, geom_surf,
			   lc_curve, geom_curve, u_par,
			   display, display_env, mode, reverse)
IGRlong *msg;
struct GRlc_info *lc_surf, *lc_curve;
struct IGRbsp_surface *geom_surf;
struct IGRbsp_curve *geom_curve;
IGRdouble *u_par;
struct IGRdisplay *display;
struct GRmd_env *display_env;
enum GRdpmode mode;    
{
  struct IGRbsp_surface *bspsf = NULL;
  struct IGRbsp_curve *bspcv = NULL;
  OM_S_OBJID my_id = NULL;
  IGRdouble tolr, low_par, high_par, delta;
  IGRdouble curve_par, surf_u, surf_v, dist;
  IGRpoint curve_eval[2], surf_pt;
  IGRvector normal, tangent, direct;
  GRrange range;
  IGRint i;
  IGRlong sts, loc_msg;
  extern IGRlong EMget_the_geometry();
  extern void EFdraw_vector_on_screen();

  /*
   * Initialize
   */
  *msg = MSSUCC;

  BSEXTRACTPAR(&loc_msg, BSTOLLENVEC, tolr);

  /*
   * get surface geometry
   */
  bspsf = geom_surf;
  if (!bspsf)
  {
    sts = EMget_the_geometry(lc_surf, FALSE, FALSE, FALSE, my_id, &bspsf, &loc_msg);
    EMerr_hndlr(!(loc_msg & sts & 1), *msg, MSFAIL, quit);
  }

  /*
   * get curve geometry
   */
  bspcv = geom_curve;
  if (!bspcv)
  {
    sts = EMget_the_geometry(lc_curve, TRUE, FALSE, FALSE, my_id, &bspcv, &loc_msg);
    EMerr_hndlr(!(loc_msg & sts & 1), *msg, MSFAIL, quit);
  }

  /*
   * find a point on the curve that is not on the surface
   */
  low_par = bspcv->knots[bspcv->order - 1];
  high_par = bspcv->knots[bspcv->num_poles];

  if (u_par)
    curve_par = *u_par;
  else
    curve_par = (low_par + high_par) / 2.0;

  /*
   * get the point and derivative on the curve
   */
  BScveval(bspcv, curve_par, 1, curve_eval, &loc_msg);

  /*
   * get minimum distance from the point to the surface
   */
  BSmdistptsf(&loc_msg, bspsf, curve_eval[0], &surf_u, &surf_v, surf_pt, &dist);
  EMerr_hndlr(loc_msg != BSSUCC, *msg, MSFAIL, quit);

  BSmkvec(&loc_msg, normal, curve_eval[0], surf_pt);
  if (BSlenvec(&loc_msg, normal) < tolr)
  {
    /*
     * Now, we loop through MAXNUM_TRY_POINTS number of points to
     * find one that is not on the surface. If it fails, then we
     * consider that the curve lies entirely on the surface.
     */
    delta = (high_par - low_par) / MAXNUM_TRY_POINTS;
    curve_par = low_par;
    for (i = 0; i <= MAXNUM_TRY_POINTS; i++)
    {
      BScveval(bspcv, curve_par, 1, curve_eval, &loc_msg);
      BSmdistptsf(&loc_msg, bspsf, curve_eval[0], &surf_u, &surf_v, surf_pt, &dist);
      EMerr_hndlr(loc_msg != BSSUCC, *msg, MSFAIL, quit);

      BSmkvec(&loc_msg, normal, curve_eval[0], surf_pt);
      if (BSlenvec(&loc_msg, normal) < tolr)
	curve_par += delta;
      else
	break;
    }
    EMerr_hndlr(i == (MAXNUM_TRY_POINTS + 1), *msg, MSFAIL, quit);
  }
  BSnorvec(&loc_msg, normal);

  memcpy(tangent, curve_eval[1], sizeof(IGRvector));
  BSnorvec(&loc_msg, tangent);

  BScrossp(&loc_msg, normal, tangent, direct);

  /* determine the range of the curve */
  sts = BSbx2(&loc_msg, &bspcv->num_poles, bspcv->poles,
	      (bspcv->rational ? bspcv->weights : NULL),
	      &range[0], &range[3]);

  /* display the direction */
  EFdraw_vector_on_screen(my_id, display, display_env, mode, reverse,
			  curve_eval, direct, range, &loc_msg);
  *msg = MSSUCC;

quit:
  if (!geom_surf)
  {
    if (bspsf)
      om$dealloc(ptr = bspsf);
  }
  if (!geom_curve)
  {
    if (bspcv)
      om$dealloc(ptr = bspcv);
  }

  if (1 & *msg)
    return TRUE;
  else
    return FALSE;
}

end implementation Root;
