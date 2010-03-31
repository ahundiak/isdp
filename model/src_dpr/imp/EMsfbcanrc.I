/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

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
    DLB 06/29/91 Handle boolean features.
    DLB 06/07/89 Creation.
*/
{
  IGRlong          OM_stat=OM_S_SUCCESS;
  enum EMSbooltype exact_type;
  extern OMuword   OPP_EMSsfspltwsf_class_id, OPP_EMSsfboolfea_class_id, 
	           OPP_EMSsfrndbool_class_id;

  *EMmsg = EMS_S_Success;
  *can_rc = TRUE;  

  if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                        OPP_EMSsfboolfea_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                        OPP_EMSsfrndbool_class_id))
  {
    *can_rc = ME.GRgraphics->properties & GRIS_ASSOCIATIVE;
  }
  else
  {
    /* Get the operation type. */
    OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                            EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if ( exact_type == EMSbool_delDisjArea ||
         EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                           OPP_EMSsfspltwsf_class_id, FALSE) )
    {
      *can_rc = FALSE;
    }
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfbool.EMcanRecompute")
    return(OM_stat);
}
end implementation EMSsfboolean;
