/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

from EMSparameter import EMparam_delete;

method GRdelete(IGRlong *EMmsg; 
                struct GRmd_env *md_env)
/*
Description
    Delete EMSparameter parents then do wrt parent GRvg.GRdelete.

Notes
    None.

History
    DLB 04/20/91    Creation.
*/
{
  *EMmsg = EMS_S_Success;

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  {
    IGRlong msg_loc;
    OM_S_CHANSELECT to_father;
    EMmake_chanselect(NDfather_father, &to_father);
    om$send(msg = message EMSparameter.EMparam_delete(&msg_loc, md_env),
            p_chanselect = &to_father);
  }

  return(om$send(mode = OM_e_wrt_message,
                 msg = message GRvg.GRdelete(EMmsg, md_env),
                 targetid = my_id));
}
end implementation EMSassoc;
