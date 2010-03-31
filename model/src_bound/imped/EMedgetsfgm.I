/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "emsmacros.h"

from GRvg   import GRgetsize, GRgetgeom;

method EMget_sf_geom(IGRlong *EMmsg; struct GRid *srf_id;
                     struct IGRbsp_surface **srf_geom;
                     struct GRmdenv_info *md_env)
/*
 NOTES
    If srf_id is not known, it should be passed as NULL
 
    The caller has the responsibility of deallocating the
    memory of srf_geom.

HISTORY
           RC  03/20/87  Creation date

ALGORITHM
    
    get the surface GRid if not sent by the caller.

    get the surface geometry.
*/
    
{
    IGRlong  OM_stat;
IGRlong   mthd_stat;
IGRlong   srf_size;
    GRobjid  surf;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    *srf_geom = NULL;

    if (!srf_id )
    {
       OM_stat = om$send ( msg = message EMSboundary.EMgetsurface_info 
                            (&mthd_stat, &surf, NULL),
                           targetid = my_id);
     EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    }
    else surf = srf_id->objid;

    /*
     * get the surface geometry
     */

    OM_stat = om$send (msg = message GRvg.GRgetsize(&mthd_stat,
                        &md_env->matrix_type, md_env->matrix, &srf_size),
                       targetid = surf);
    EMerr_hndlr (!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    *srf_geom = (struct IGRbsp_surface *) om$malloc (size = srf_size);
    EMerr_hndlr (!(*srf_geom),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    
    OM_stat = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetgeom (&mthd_stat,
                       &md_env->matrix_type, md_env->matrix,
                       (IGRchar *) *srf_geom),
                      senderid = my_id, targetid = surf);
    EMerr_hndlr (!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    
wrapup:

    if (!(1&OM_stat&*EMmsg))
     {
      if (*srf_geom) om$dealloc (ptr = *srf_geom);
      *srf_geom = NULL;
     }

    EMWRAPUP (*EMmsg, OM_stat, "In EMSedge.EMget_sf_geom")

    return (OM_stat);

}
end implementation EMSedge; 
