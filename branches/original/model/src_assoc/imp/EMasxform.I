/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

from EMSparameter import EMparam_xform;

method GRxform(IGRlong         *EMmsg;
               struct GRmd_env *md_env;
               IGRshort        *matrix_type;
               IGRmatrix       matrix;
               GRobjid         *newobjid)
/*
Description
    Xforme EMSparameter parents then do wrt parent GRvg.GRxform.

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
    om$send(msg = message EMSparameter.EMparam_xform(&msg_loc, md_env,
                  matrix_type, matrix, newobjid),
            p_chanselect = &to_father);
  }

  return(om$send(mode = OM_e_wrt_parent,
                 msg = message EMSassoc.GRxform(EMmsg, md_env,
                       matrix_type, matrix, newobjid),
                 targetid = my_id));
}
end implementation EMSassoc;
