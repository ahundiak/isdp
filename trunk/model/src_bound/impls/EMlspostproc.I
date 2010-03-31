/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMSobjmgrdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMpostdelete (IGRlong *msg; IGRushort options; 
                     struct GRmd_env *model_env)
{
  OM_S_CHANSELECT chan_to_loops;
  extern IGRlong EMremshobj();
  IGRlong msg_loc;

  *msg = EMS_S_Success;

  if (ME.EMSloopset->ls_props & EMLS_SHELL)
    {
    EMremshobj (&msg_loc, NULL, EMSshobj_sfbdry, OM_Gw_current_OS, my_id);
    ME.EMSloopset->ls_props &= ~EMLS_SHELL;
    }

  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);

ret_end:
  return (OM_S_SUCCESS);
}


method EMpostxform_xyz (IGRlong *msg; IGRushort options; 
                        struct GRmd_env *model_env; 
                        IGRshort *xmattyp; IGRmatrix *xmat)
{
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;

  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);

ret_end:
  return (OM_S_SUCCESS);
}


method EMpostrtree (IGRlong *msg; IGRboolean add; IGRushort options; 
                    struct GRmd_env *model_env)
{
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;

  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);

ret_end:
  return (OM_S_SUCCESS);
}

end implementation EMSloopset;
