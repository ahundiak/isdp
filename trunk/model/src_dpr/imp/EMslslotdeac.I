/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslslotfea;

/*
Description

This method will deactivate me if I am an active state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

Algorithm

Get the SSI table.
If option==EMS_UNDO_DELETE delete both myself and the feature objects.

Returned values

EMS_S_SUCCESS if all is well.

History

Tapadia 08/30/91   Creation date.

NP      12/10/93   In this method we are deleting ONLY the surfaces that have 
                   been added by the feature. We are NOT deleting the feature 
                   node itself. Therefore removed check for option 
                   "EMS_UNDO_DONTDELME" in deciding whether to delete added 
                   geometry. In fact, if "EMS_UNDO_SAVE" is NOT set, it 
                   automatically implies delete.
*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h"


method EMdeactivate(IGRlong *EMmsg;
		IGRshort *option;
		struct GRmd_env *env;
		GRobjid **display_ids; 
		IGRint *display_count)
{
  IGRboolean  delete;
  IGRlong  sts;
  OM_S_CHANSELECT  to_comps;
    
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  delete = ((*option & EMS_UNDO_SAVE)) ? FALSE : TRUE;

  sts = om$send(mode = OM_e_wrt_message,
		msg = message EMSsfboolean.EMdeactivate(EMmsg, 
		option, env, display_ids, display_count),
                targetid = my_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$make_chanselect(chanaddr = &ME.GRcmpowner->to_components,
                          p_chanselect = &to_comps);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);






if ((*option & EMS_DO_DISPLAY) || delete)
  {
    enum GRdpmode  display_mode;

    /* erase all surfaces of created by the slot */

    display_mode = GRbe;
    sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
		&env->md_env.matrix_type, 
                env->md_env.matrix, &display_mode,
                &env->md_id),
                p_chanselect = &to_comps,
		from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  }

  if(delete)
  {

    /* delete all surfaces created by the slot */

    sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
		p_chanselect = &to_comps,
		from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  } /* if */

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSslslotfea.EMdeactivate")
  return(sts);

} /* EMdeactivate */

end implementation EMSslslotfea;
