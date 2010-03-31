/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 12/07/88 : Creation


    This method returns the geometry of a natural edge in a polyline
    format in model space. surf_id and surf_geom can be NULL, in which
    case, this method will fetch the same. If the curve is second order,
    only end points are returned.
*/

class implementation EMSnatedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "EMSbnd.h"
#include "EMSopt.h"

method EMpyxyz_geometry (IGRlong                *EMmsg;
                         struct GRmd_env        *my_env;
                         struct GRid            *surf_id;
                         struct IGRbsp_surface  *surf_geom;
                         IGRint                 from_spaninx,
                                                num_spans;
                         IGRboolean             reverse;
                         struct EMSpartedinfo   *partinfo;
                         struct IGRpolyline     *pygeom;
                         struct EMSpartolbasis  *partolbasis;
                         IGRint                 *num_iso;
                         struct EMtopology_info *topology;
                         IGRboolean             *swap_valid;
                         IGRint                 *swap_index;
                         IGRushort      options)

{
  IGRlong               stat_OM, msg;
  IGRdouble             cht_tol, temp_tol;
  struct IGRbsp_curve   iso_curve;
  struct IGRbsp_surface *surface;
  IGRboolean            status, EFstroke_the_curve();

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  *swap_valid = FALSE;

/*  if ((options & EMonly_If_Dominant) && 
      (ME.EMSedge->ed_props & EMED_SUBORDINATE))
       return (stat_OM);
*/
  surface = surf_geom;
  pygeom->points = NULL;

  if (! surface)
   {
    stat_OM = om$send (msg = message EMSedge.EMget_sf_geom(&msg, surf_id,
                             &surface, &my_env->md_env),
                       targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  iso_curve.weights = NULL;
  iso_curve.poles = NULL;
  iso_curve.knots = NULL;
  iso_curve.bdrys = NULL;

  stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                          &my_env->md_env, surf_id, surface, from_spaninx,
                          num_spans, reverse, partinfo, &iso_curve),
                    targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol); 

  temp_tol = cht_tol / 10.0;

  status = EFstroke_the_curve (&iso_curve, &temp_tol, pygeom, &msg);
  EMerr_hndlr (! status || !(1 & msg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSnatedge.EMpyxyz_geometry");
  if (! surf_geom && surface) om$dealloc (ptr = surface);

  if (iso_curve.poles) om$dealloc (ptr = iso_curve.poles);
  if (iso_curve.knots) om$dealloc (ptr = iso_curve.knots);
  if (iso_curve.weights) om$dealloc (ptr = iso_curve.weights);
  if (iso_curve.bdrys) om$dealloc (ptr = iso_curve.bdrys);

  return (stat_OM);
}

end implementation EMSnatedge;
