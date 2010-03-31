/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

/*
   History

        Sudha   07/06/93        modified for BSprototype includes
*/

#include "EMS.h"
#include "emsmacros.h"		/* for EMWRAPUP */
#include "bstypes.h"		/* for BSrc */
#include "bssfeval.h"

method EMget_bcxyz_geom (
  IGRlong		*EMmsg;
  struct GRmdenv_info  	*mdenv;
  struct GRid		*srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRint		from_spaninx;
  IGRint		num_spans;
  IGRboolean		reverse;
  struct EMSpartedinfo  *partinfo;
  struct IGRbsp_curve 	*curve)

{
	IGRlong  OM_stat;		/* om return status 	*/
	IGRlong  mthd_stat;		/* method return code	*/
	IGRint	 i;
	BSrc rc;
	struct IGRbsp_surface *surface;

	*EMmsg = EMS_S_Success;			/* initialize messages	*/
  	OM_stat = OM_S_SUCCESS;
	surface = srf_geom;

	/*
	 * find out if the surface is passed along
	 */

	if (!surface )
	{
          struct GRid loc_srfid;

          if (!srf_id)
          {
            OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info 
                       (&mthd_stat, &loc_srfid.objid, NULL), 
                       targetid = my_id);
            EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
             EMS_E_EdgeError, wrapup);
            loc_srfid.osnum = OM_Gw_current_OS;
          }
          else
          {
            loc_srfid = *srf_id;
          }

          OM_stat = EMgetvggeom (&mthd_stat, &mdenv->matrix_type,
                     mdenv->matrix, &loc_srfid, &surface, NULL);
          EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
           EMS_E_SurfaceError, wrapup);
	}

	/*
	 * get (u,v) space geomtery of the edge
	 */

	curve->poles = NULL;
	curve->knots = NULL;
	curve->weights = NULL;

	OM_stat = om$send (msg = message EMSedge.EMgetbcgeom (
			&mthd_stat, from_spaninx, num_spans, 
			 reverse, partinfo, curve, NULL, NULL),
		   targetid = my_id);
	EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

	/*
	 * convert the Poles from (u,v) space to (x,y,z) space
	 */

	for (i = 0; i < curve->num_poles; i++)
	{
	    BSsfeval (surface,
		      curve->poles[i*3],
		      curve->poles[i*3 + 1],
		      0,
		     (IGRpoint *)&curve->poles[i*3],
		     &rc);

	    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_BSerror,wrapup);
	} 
wrapup:

  if (!srf_geom) om$dealloc (ptr = (char *) surface);
  if (!(1&OM_stat&*EMmsg))
  {
    if (curve->poles) om$dealloc (ptr = (char *) curve->poles);
    if (curve->knots) om$dealloc (ptr = (char *) curve->knots);
    if (curve->weights) om$dealloc (ptr = (char *) curve->weights);
  }
  EMWRAPUP (*EMmsg,OM_stat,"In EMSptedge.EMget_bcxyz_geom");
  return (OM_stat);

}

end implementation EMSptedge;
