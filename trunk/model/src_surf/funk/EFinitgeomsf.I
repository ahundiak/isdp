/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EFinit_geom_surface

Description
        This method initializes the required members of the geometric
    surface structure.

History
        WBC     12/01/92    Creation.
*/

class implementation EMSsurface;

#include "bsgeom_cvsf.h"


void EFinit_geom_surface(EMmsg, bsp_surface, surface_id, surface_os,
                         geom_surface)

IGRlong                 *EMmsg;        /* Output; Return code */
struct IGRbsp_surface   *bsp_surface;  /* Input; surface's b-spline geometry */
GRobjid                  surface_id;   /* Input; surface's objid */
GRspacenum               surface_os;   /* Input; surface's osnum */
struct BSgeom_bsp_surf  *geom_surface; /* Output; minimally initialized
                                          geometric surface structure that
                                          corresponds to the input surface */
{
    IGRint                  npoints;

    *EMmsg = EMS_S_Success;
    npoints = 1;

    geom_surface->geom_prop = FALSE;
    geom_surface->bspsf = bsp_surface;
    getsftype(surface_id, surface_os, &geom_surface->type);
    geom_surface->bounded = TRUE;
    geom_surface->sfgen_cv = NULL;

    /* currently the math functions do not use the uv-ranges so the values
     * are hard-coded, but if the math functions do begin using these values
     * the uv-ranges below could be obtained by sending the message
     * EMgetuvrange to the specified surface - the range returned from this
     * method would probably need to be adjusted by some tolerance as in the
     * example that follows:
     *
     *  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);
     *  BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);
     *  UVRNGTOL_FACTOR = 100 * (cht/bastol);
     *
     * stat_OM = om$send (msg = message EMSsubbs.EMgetuvrange (&msg_loc,
     *                                                         my_uvrange),
     *                    targetid = surface_id,
     *                    targetos = surface_os);
     * EMomerr_exit (stat_OM, ret_end);
     * EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
     *
     * tol = UVRNGTOL_FACTOR * my_partolbasis.tol;
     * for (i=UMIN; i<=VMAX; i++)
     * {
     *   if (i <= VMIN)
     *   {
     *     if (my_uvrange[i] - tol < 0.0)
     *       my_uvrange[i] = 0.0;
     *     else
     *       my_uvrange[i] -= tol;
     *   }
     *   else
     *   {
     *     if (my_uvrange[i] + tol > 1.0)
     *       my_uvrange[i] = 1.0;
     *     else
     *       my_uvrange[i] += tol;
     *   }
     * }
     */

    geom_surface->urange[0] = 0.0;
    geom_surface->urange[1] = 1.0;
    geom_surface->vrange[0] = 0.0;
    geom_surface->vrange[1] = 1.0;
}

end implementation EMSsurface;
