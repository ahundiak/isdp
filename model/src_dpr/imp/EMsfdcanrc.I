/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

method EMcanRecompute(IGRlong *EMmsg; IGRboolean *can_rc)
/*
Description
    This message will indicate the ability of this node to recompute. 

Return Values
    EMS_S_Success is always returned.

Notes
    About parameters:
      can_rc - if true this node can recompute.

History
    DLB 06/07/89 Creation.
    mrm 03/22/91 always return TRUE (everything should recompute, right?)
    DLB 05/06/91 based on a bit now.
*/
{
  *EMmsg = EMS_S_Success;
  *can_rc = ME.GRgraphics->properties & GRIS_ASSOCIATIVE;
  return(OM_S_SUCCESS);
}
end implementation EMSsfdpr;
