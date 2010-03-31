class implementation EMSsfrndbool;
/*
Description

This method will deactivate me.

Algorithm

Get the SSI table.
If option==EMS_UNDO_DELETE delete both myself and the feature objects.

Returned values

EMS_S_SUCCESS if all is well.

History

DLB   01/23/92      Creation date. - removed EMundo override.
*/

#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

method EMdeactivate(IGRlong *EMmsg;
                    IGRshort *option;
                    struct GRmd_env *env;
                    GRobjid **display_ids; 
                    IGRint *display_count)
{
  IGRlong     sts=OM_S_SUCCESS;
  IGRboolean  delete;
  OM_S_CHANSELECT  to_comps;
    

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  delete = ((*option & EMS_UNDO_DONTDELME) || (*option & EMS_UNDO_SAVE)) 
           ? FALSE : TRUE;

  sts = om$send(mode = OM_e_wrt_message,
                msg = message EMSsfboolean.EMdeactivate(EMmsg, 
                option, env, display_ids, display_count),
                targetid = my_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  if ((*option & EMS_DO_DISPLAY) || delete)
  {
    enum GRdpmode  display_mode;
    struct GRmd_env display_env;
    IGRint env_size=sizeof(struct GRmd_env), nret;

    gr$get_display_env(msg = EMmsg,
                         sizbuf = &env_size,
                         buffer = &display_env,
                         nret = &nret);
    EMerr_hndlr (EMSerror (*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    /* erase all surfaces of the features */
    display_mode = GRbe;
    sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                        &display_env.md_env.matrix_type, 
                        display_env.md_env.matrix, &display_mode,
                        &display_env.md_id),
                        p_chanselect = &to_comps,
                  from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
  }

  if(delete)
  {
    /* delete surfaces of features */

    sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                  p_chanselect = &to_comps,
                  from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
  } /* if */

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfrndlbool.EMdeactivate")
  return(sts);
}
end implementation EMSsfrndbool;
