/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 12/07/88 : Creation

    Sudha 06/04/93          modified to include BSprototype header files

    This method returns the geometry of a bsedge in a polyline format
    in model space. surf_id and surf_geom can be NULL, in which case, this
    method will fetch the same.
*/

class implementation EMSbsedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsinter.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "bschangepar.h"

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
  struct IGRpolyline    uv_poly;
  struct IGRbsp_surface *surface;
  IGRboolean            status, EFmap_uv_to_xyz_for_planes();

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  *swap_valid = FALSE;

  /* if ((options & EMonly_If_Dominant) && 
      (ME.EMSedge->ed_props & EMED_SUBORDINATE))
       return (stat_OM);
  */

  uv_poly.points = NULL;
  surface = surf_geom;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol); 

  temp_tol = cht_tol / 10.0;

  BSchangepar(&msg, BSTOLCHRDHT, temp_tol);

  stat_OM = om$send (msg = message EMSedge.EMgetpygeom(&msg, from_spaninx,
                           num_spans, reverse, partinfo, &uv_poly,
                           partolbasis, NULL),
                     targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  BSchangepar(&msg, BSTOLCHRDHT, cht_tol);

  if (! pygeom->points)
      pygeom->points = (IGRdouble *) om$malloc (size = 3 * 
                       uv_poly.num_points * sizeof (IGRdouble));

  pygeom->num_points = uv_poly.num_points;

  if (! surface)
   {
    stat_OM = om$send (msg = message EMSedge.EMget_sf_geom(&msg, surf_id,
                             &surface, &my_env->md_env),
                       targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  status =  EFmap_uv_to_xyz_for_planes (&msg, surface, cht_tol,
                                        uv_poly.num_points, 
                                        uv_poly.points,
                                        pygeom->points);
  EMerr_hndlr(! status || !(1 & msg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSbsedge.EMpyxyz_geometry");
  if (! surf_geom && surface) om$dealloc (ptr = surface);
  if (uv_poly.points) om$dealloc (ptr = uv_poly.points);

  return (stat_OM);
}

end implementation EMSbsedge;
