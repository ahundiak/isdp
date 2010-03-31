/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
/* ************************************************************************

Description

 This method constructs associative objects subclassed from GRbspline.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  env : Module environment of the master file.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_SurfaceError : If there is an error in doing one of these:
           a) Get the surface definition
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History
 03/18/91 : WBC : Creation date.
 07/31/91 : WBC : Notifying symbology override table an objid has changed
                  if the MSC has a symbology override.

*********************************************************************** */

class implementation GAcurve;

#include "EMS.h"
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSdpb.h"
#include <stdio.h>
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdef.h"
#include "EMSopt.h"
#include "EMSconstruct.h"
#include "EMSkey.h"
#include "REcurve.h"
#include "DEsomacros.h"

from EMSedge import EMget_bcxyz_geom;
from EMScreator import EMgive_noncount_based_key;


method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint num_parents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)

{
    IGRboolean aflag=0;
    extern IGRlong       EFgenerate_id_from_key();
    int                  is_msc;
    IGRlong              status, msg, long_rc;
    IGRuint      info_type, new_type, new_key_size, loc_stat;
    OM_S_OBJID           amsc_with_edge,
                         edge_id;
    OMuword              edge_osnum;
    struct IGRbsp_curve  bc_geom;
    struct GRid          old_GRid, new_GRid;
    union EMSparent_info root;

    status = OM_S_SUCCESS;
    long_rc = OM_S_SUCCESS; /* fix for umr */
    *EMmsg = EMS_S_Success;
    bc_geom.poles = NULL;
    bc_geom.weights = NULL;
    bc_geom.knots= NULL;

    aflag = pwIsActivationOn();

    /* find the construction geometry based on the edge
     * to which this object is connected;
     * get the objid of the edge corresponding to this associative
     * model-space counterpart
     */

    amsc_with_edge = (old_objid == NULL_OBJID) ? my_id : old_objid;


    (void) EFis_msc(EMmsg, type, &is_msc);

    if (!is_msc) 
    {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
    }

    /* get the edge objid and osnum */

    status = om$send(msg = message GAcurve.GAget_msc_component(EMmsg,
                                                 &edge_id, &edge_osnum),
                     targetid = amsc_with_edge);
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    /* get the module environment of the parent; there should only be 1 */

    if (num_parents == 1)
    {
        info_type = EMSgrid;
        status = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                                                         NULL, 1, parent_info,
                                                         &info_type, &root),
                         targetid = my_id);
    }
    else
        status = OM_E_ABORT;
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    status = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg,
                                             &root.grobj.env.md_env,
                                             NULL, NULL, 0, OM_K_MAXINT,
                                             FALSE, NULL, &bc_geom),
                     targetid = edge_id,
                     targetos = edge_osnum);
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    construct_list->geometry = (IGRchar *) &bc_geom;

    if(aflag)
    {
      GRobjid modid;

      modid = construct_list->env_info->md_id.objid;
      pwGetActiveModuleEnv(construct_list->env_info);
      construct_list->env_info->md_id.objid = modid;
    }

    status = om$send(msg = message GRgraphics.GRconstruct(construct_list),
                     targetid = my_id);
    EMerr_hndlr(!(1 & status & *(construct_list->msg)), *EMmsg, EMS_E_Fail, wrapup);

    /* notify symbology override that the object id is changing */

    if ((old_objid != NULL_OBJID) &&
        (ME.GRgraphics->properties & DEHAS_OVERRIDE))
    {
        old_GRid.objid = old_objid;
        old_GRid.osnum = OM_Gw_current_OS;
        new_GRid.objid = my_id;
        new_GRid.osnum = OM_Gw_current_OS;

        de$objid_changed(msg = &msg,
                         old = &old_GRid,
                         new = &new_GRid);
    }

    if(old_objid == NULL_OBJID)
      {
	unsigned char *info;
	/* Add the special processing needed */
	
	loc_stat = om$send( msg = message EMScreator.EMgive_noncount_based_key(
						&long_rc,
						EMS_CREATE_MSCS,
					        &edge_id,
						&new_type,
						&new_key_size,
						NULL),
			 targetid = root.grobj.grid.objid,
			 targetos = root.grobj.grid.osnum);
	if(long_rc & loc_stat &1)
	  {
	    info = stackalloc(new_key_size);
	    if(!info) goto wrapup;

	    status = 
	    om$send( msg = message EMScreator.EMgive_noncount_based_key(
						&long_rc,
						EMS_CREATE_MSCS,
					        &edge_id,
						&new_type,
						&new_key_size,
						&info),
			 targetid = root.grobj.grid.objid,
			 targetos = root.grobj.grid.osnum);
	    EMerr_hndlr(!(1 & status & long_rc), long_rc, EMS_E_Fail, wrapup);
	    ME.EMSassoc->type = new_type;
	    status =
	    om$send(msg = message EMSassoc.EMput_info( &long_rc,
						 NULL,
						 new_type,
						 new_key_size,
						 (IGRchar *)info),
		    targetid = my_id);
	    EMerr_hndlr(!(1 & status & long_rc), long_rc, EMS_E_Fail, wrapup);
	  }
      }
wrapup:

    if (bc_geom.poles)
        om$dealloc(ptr = bc_geom.poles);
    if (bc_geom.weights)
        om$dealloc(ptr = bc_geom.weights);
    if (bc_geom.knots)
        om$dealloc(ptr = bc_geom.knots);

    return (status);
}
end implementation GAcurve;



