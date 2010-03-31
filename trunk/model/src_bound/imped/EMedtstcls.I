/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "bscvtstclsd.h"

method EMtst_xyz_clsd(
        IGRlong                 *EMmsg;
        struct IGRbsp_surface   *srf_geom;
        GRobjid                 srf_id;
        struct GRmdenv_info     *md_env;
        IGRboolean              *is_xyz_closed)

/*
 NOTES
        Upon exit the return code may be 
        EMS_S_Success - if successfull
        EMS_E_EdgeError - if failure

History
        RC      02/28/88        Creation Date

        Sudha   06/04/93        modified to include BSprototype header files

*/

{

IGRlong                 OM_stat;
IGRlong   mthd_stat;
struct IGRbsp_curve     cv_geom;
struct GRid  		sf_GRid;
BSrc                    rc;



*EMmsg = EMS_S_Success;
OM_stat = OM_S_SUCCESS;

sf_GRid.objid = srf_id;
sf_GRid.osnum = OM_Gw_current_OS;

cv_geom.poles = NULL;
cv_geom.knots = NULL;
cv_geom.weights = NULL;

OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                    &mthd_stat, md_env, 
                    (srf_id == NULL_OBJID ? NULL : &sf_GRid),
                    srf_geom, NULL, OM_K_MAXINT, FALSE, NULL, &cv_geom),
                   targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

BScvtstclsd(&cv_geom, &rc);
EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

if (cv_geom.phy_closed) *is_xyz_closed = TRUE;
else *is_xyz_closed = FALSE;

wrapup:
 if (cv_geom.poles) om$dealloc (ptr = cv_geom.poles);
 if (cv_geom.knots) om$dealloc (ptr = cv_geom.knots);
 if (cv_geom.weights) om$dealloc (ptr = cv_geom.weights);

EMWRAPUP (*EMmsg, OM_stat, "In EMSedge. EMtst_xyz_clsd")

return(OM_stat);
}

end implementation EMSedge;
