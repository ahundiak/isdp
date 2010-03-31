/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "bserr.h"
#include "emsmacros.h"
#include "bststcvdegn.h"
#include "bsfreecv.h"

method EMtst_degn (
        IGRlong                 *EMmsg;         /* method return code */
        struct IGRbsp_surface   *srf_geom;      /* input - surf struct*/
                                                /* NULL - if not known*/
        GRobjid                 srf_id;         /* input - NULLOBJID  */
                                                /* if not known       */
        struct GRmdenv_info     *md_env;        /* srf env info       */
        IGRboolean              *is_degen)      /* output -           */
                                                /*  TRUE if degenerate */
                                                /*  FALSE if not deg  */

/*

 History  

   RV 	03/10/88	Creation.

   Sudha 06/04/93       modified to include BSprototype header files
*/
{

 BSrc                   rc;
 IGRlong                OM_stat;
 struct  IGRbsp_curve 	*my_geom = NULL;
 struct GRid		srf_GRid;


      OM_stat = OM_S_SUCCESS;
      *EMmsg = EMS_S_Success;   
      
      srf_GRid.objid = srf_id;
      srf_GRid.osnum = OM_Gw_current_OS;

      my_geom = (struct IGRbsp_curve *)
	 om$malloc(size = (OMuint) sizeof(struct IGRbsp_curve));
      EMerr_hndlr(!my_geom,*EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);   
      my_geom->poles = NULL;
      my_geom->knots = NULL;
      my_geom->weights = NULL;
      my_geom->bdrys = NULL;

      OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (EMmsg, md_env,
			  (srf_id == NULL_OBJID ? NULL : &srf_GRid), srf_geom,
				 0, OM_K_MAXINT, FALSE, NULL, my_geom),   
		     targetid = my_id);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

/*
 * test for degeneracy
 */
      *is_degen = FALSE;
      (void) BStstcvdegn (my_geom, is_degen, &rc);
      EMerr_hndlr( (rc != BSSUCC), *EMmsg,EMS_E_BSerror, wrapup);

 wrapup:

  if (my_geom) BSfreecv (&rc, my_geom); 

  EMWRAPUP (*EMmsg, OM_stat, "In EMSedge.EMtst_degn")
  return (OM_stat);
}

end implementation EMSedge;
