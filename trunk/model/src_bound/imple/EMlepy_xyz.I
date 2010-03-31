/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 12/07/88 : Creation
    Sudha   07/06/93        modified for BSprototype includes

    This method returns the geometry of a linear edge in a polyline format
    in model space. surf_id and surf_geom can be NULL, in which case, this
    method will fetch the same.
*/

class implementation EMSlinedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsinter.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "EMSprop.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "bssfptseval.h"
#include "bsdistptpt.h"

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
  IGRlong               blk_size;
  IGRint                i;
  IGRdouble             knot_tol, bas_tol;
extern IGRdouble fabs() ;
  struct IGRpolyline    uv_poly;
  struct IGRpolyline    iso_pygeom;
  struct IGRbsp_surface *surface;

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *swap_valid = FALSE;
  uv_poly.points = NULL;
  iso_pygeom.points = NULL;
  surface = surf_geom;

  if (! surface)
   {
    stat_OM = om$send (msg = message EMSedge.EMget_sf_geom(&msg, surf_id,
                             &surface, &my_env->md_env),
                       targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  if (ME.EMSedge->ed_props & EMED_ISO)
   {
    stat_OM = om$send(msg = message EMSlinedge.EMstroke_iso_edge (&msg,
                            my_env->md_env.matrix,
                            &my_env->md_env.matrix_type, surf_id, surface,
                            reverse, partolbasis, my_id, &uv_poly, FALSE),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }
  else
   {
    if (num_spans > ME.EMSlinedge->num_points - 1)
        num_spans = ME.EMSlinedge->num_points - 1;

    stat_OM = om$send (msg = message EMSedge.EMgetpygeom(&msg,
                             from_spaninx, num_spans, reverse, partinfo,
                             &uv_poly, partolbasis, NULL),
                       targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  if (! pygeom->points)
      pygeom->points = (IGRdouble *) om$malloc (size = 3 * 
                       uv_poly.num_points * sizeof (IGRdouble));

  pygeom->num_points = uv_poly.num_points;

  BSsfptseval (surface, uv_poly.num_points, uv_poly.points,
               pygeom->points, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /* There might be a iso_curve which has already been stroked for this
     surface and this iso_curve happens to coincide fully or partially
     with myself (iso_edge). If this happens then the iso_curve will be
     stroked differently from myself and to avoid this replace the 
     iso_curve pygeom with that of myself (from 0 to 1).
   */

  if (ME.EMSedge->ed_props & EMED_ISO)
   {
    BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
    BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

    for (i=0; i<(*num_iso); i++)
     {
      if (topology[i].u_dir)
       {
        if ((fabs(ME.EMSlinedge->points[0] - ME.EMSlinedge->points[2]) <=
             partolbasis->tol) &&
            (fabs(ME.EMSlinedge->points[0] - topology[i].param) <= 
             partolbasis->tol))
         {
          if ((((ME.EMSlinedge->points[1] <= knot_tol) && 
               (ME.EMSlinedge->points[3] >= 1-knot_tol)) ||
              ((ME.EMSlinedge->points[1] >= 1-knot_tol) && 
               (ME.EMSlinedge->points[3] <= knot_tol))) ||
               (! topology[i].pygeom_sacked))
           {
            om$dealloc (ptr = topology[i].poly->points);
            topology[i].poly->num_points = pygeom->num_points;
            topology[i].poly->points = pygeom->points;
            topology[i].pygeom_sacked = TRUE;
            *swap_valid = TRUE;
            *swap_index = i;
           }
          else
           {
            if (! iso_pygeom.points)
            iso_pygeom.points = (IGRdouble *) om$malloc (size = 3 * 
                (pygeom->num_points + topology[i].poly->num_points) *
                sizeof (IGRdouble));

            iso_pygeom.num_points = pygeom->num_points +
                                    topology[i].poly->num_points;

            if (BSdistptpt(&msg, &pygeom->points[0],
                &topology[i].poly->points[(topology[i].poly->num_points-1)
                *3]) <= bas_tol)
             {
              blk_size = 3*topology[i].poly->num_points*sizeof(IGRdouble);
              OM_BLOCK_MOVE (&topology[i].poly->points[0],
                             &iso_pygeom.points[0], blk_size);
              blk_size = 3 * pygeom->num_points * sizeof(IGRdouble);
              OM_BLOCK_MOVE (&pygeom->points[0],
                     &iso_pygeom.points[3 * topology[i].poly->num_points],
                     blk_size);
             }
            else
             {
              blk_size = 3 * pygeom->num_points * sizeof(IGRdouble);
              OM_BLOCK_MOVE (&pygeom->points[0], &iso_pygeom.points[0],
                             blk_size);
              blk_size = 3*topology[i].poly->num_points*sizeof(IGRdouble);
              OM_BLOCK_MOVE (&topology[i].poly->points[0],
                             &iso_pygeom.points[3 * pygeom->num_points],
                             blk_size);
             }
            topology[i].poly->num_points = iso_pygeom.num_points;
            topology[i].poly->points = iso_pygeom.points;
           }
          break;
         }
       }
      else
       {
        if ((fabs(ME.EMSlinedge->points[1] - ME.EMSlinedge->points[3]) <=
             partolbasis->tol) &&
            (fabs(ME.EMSlinedge->points[1] - topology[i].param) <= 
             partolbasis->tol))
         {
          if ((((ME.EMSlinedge->points[0] <= knot_tol) && 
               (ME.EMSlinedge->points[2] >= 1-knot_tol)) ||
              ((ME.EMSlinedge->points[0] >= 1-knot_tol) && 
               (ME.EMSlinedge->points[2] <= knot_tol))) ||
               (! topology[i].pygeom_sacked))
           {
            om$dealloc (ptr = topology[i].poly->points);
            topology[i].poly->num_points = pygeom->num_points;
            topology[i].poly->points = pygeom->points;
            topology[i].pygeom_sacked = TRUE;
            *swap_valid = TRUE;
            *swap_index = i;
           }
          else
           {
            if (! iso_pygeom.points)
            iso_pygeom.points = (IGRdouble *) om$malloc (size = 3 * 
                (pygeom->num_points + topology[i].poly->num_points) *
                sizeof (IGRdouble));

            iso_pygeom.num_points = pygeom->num_points +
                                    topology[i].poly->num_points;


            if (BSdistptpt(&msg, &pygeom->points[0],
                &topology[i].poly->points[(topology[i].poly->num_points-1)
                *3]) <= bas_tol)
             {
              blk_size = 3*topology[i].poly->num_points*sizeof(IGRdouble);
              OM_BLOCK_MOVE (&topology[i].poly->points[0],
                             &iso_pygeom.points[0], blk_size);
              blk_size = 3 * pygeom->num_points * sizeof(IGRdouble);
              OM_BLOCK_MOVE (&pygeom->points[0],
                     &iso_pygeom.points[3 * topology[i].poly->num_points],
                     blk_size);
             }
            else
             {
              blk_size = 3 * pygeom->num_points * sizeof(IGRdouble);
              OM_BLOCK_MOVE (&pygeom->points[0], &iso_pygeom.points[0],
                             blk_size);
              blk_size = 3*topology[i].poly->num_points*sizeof(IGRdouble);
              OM_BLOCK_MOVE (&topology[i].poly->points[0],
                             &iso_pygeom.points[3 * pygeom->num_points],
                             blk_size);
             }
            topology[i].poly->num_points = iso_pygeom.num_points;
            topology[i].poly->points = iso_pygeom.points;
           }
          break;
         }
       }
     }
   }

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSlinedge.EMpyxyz_geometry");
  if (! surf_geom && surface) om$dealloc (ptr = surface);
  if (uv_poly.points) om$dealloc (ptr = uv_poly.points);

  return (stat_OM);
}

end implementation EMSlinedge;
