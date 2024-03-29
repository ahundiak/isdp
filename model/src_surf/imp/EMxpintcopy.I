/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSobjmgr.h"
# include "EMSobjmgrdef.h"

/*

 History     

        RC      11/14/88    Creation Date
        SM      06-Jul-89   Added bdry_options and sf_options arguments
        AIC     09/09/91    Removed HSURF bundle changes; handled by EMSsubbs
*/

from EMSboundary import EMget_edges;
 
method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
	IGRushort       bdry_options,  sf_options)
{
  OM_S_CHANSELECT       xs_mdl_chan, mdl_xs_chan, sf_ls_chan;
  OM_S_OBJECT_LINKAGE   mdl_list;
  IGRlong               OM_stat, mthd_stat, rc;
  OMuint                num_mdls;
  GRobjid               mdl_cp;
  IGRboolean            mdl_cp_exists, my_copy_exists;
  extern void           EMcpsearch();

  /* ***************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am all done
   */
        
  EMcpsearch (&rc, my_id, newobjid, copy_info, 0, &my_copy_exists);
  EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists) goto wrapup;

  /*
   * o Do whatever my parent wants to do.
   * o Check if I am connected to the model,
   *   and the model is copied, connect my copy with my model's copy.
   */
  
  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMSplane.EMintcopy (&mthd_stat,
                      obj_mdenv, new_mdenv, newobjid, copy_info, 
		      bdry_options, sf_options),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

  OM_stat = EMmake_chanselect (EMSxsection_to_model, &xs_mdl_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (object = me, 
               p_chanselect = &xs_mdl_chan, count = &num_mdls);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  if (num_mdls)
  {
    OM_stat = om$get_channel_objects (object = me, 
                 p_chanselect = &xs_mdl_chan, list = &mdl_list,
                 size = 1, count = &num_mdls);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    if (num_mdls != 1)
    {
       *EMmsg = EMS_E_InvalidCase;       goto wrapup;
    }

    EMcpsearch (EMmsg, mdl_list.S_objid, &mdl_cp, copy_info,
                0, &mdl_cp_exists);
    EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    if (mdl_cp_exists)
    {
      OM_stat = EMmake_chanselect (GRnotify_notification, &mdl_xs_chan);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message Root.connect (mdl_xs_chan,
                          NULL, *newobjid, new_mdenv->md_id.osnum,
                          xs_mdl_chan, NULL),
                         targetid = mdl_cp,
                         targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    } /* if (mdl_cp_exists) */

  } /* if (num_mdls) */

  wrapup:
   EMWRAPUP (OM_stat, *EMmsg, "In EMSxsplane.EMintcopy");
   return (OM_stat);
}

end implementation EMSxsplane;
