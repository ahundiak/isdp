class implementation EMSdpr;

method EMsend_for_macro(IGRlong     *EMmsg;
                        IGRint      num_levels;
                        IGRboolean  deposit_bottom_up;
                        OM_S_MESSAGE *deposit_message;
                        OMuword     options)
/*
Description
    Apply the deposit message at the target id and previous states until
    num_levels becomes 0.  The message can be deposited bottom up or top down.

Notes
    No options...yet.

History
    DLB     05/02/91    Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRboolean        deposit_here;
  extern IGRboolean EFisAncestryValid();
  extern OMuword    OPP_EMSsfmacro_class_id;


  *EMmsg = EMS_S_Success;

  deposit_here = !EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                                    OPP_EMSsfmacro_class_id, FALSE);

  if (deposit_here && !deposit_bottom_up)
  {
    OM_stat = om$send(msg = deposit_message,
                      targetid = my_id);
    if (!(1 & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  }

  if (deposit_here) num_levels--;

  if (num_levels)
  {
    OM_S_CHANSELECT to_comps;
    to_comps.type = OM_e_addr;
    to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

    OM_stat = om$send(msg = message EMSdpr.EMsend_for_macro(EMmsg, num_levels,
                            deposit_bottom_up, deposit_message, options),
                      p_chanselect = &to_comps);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;  
  }

  if (deposit_here && deposit_bottom_up)
  {
    OM_stat = om$send(msg = deposit_message,
                      targetid = my_id);
    if (!(1 & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  }

  OM_stat = OM_S_SUCCESS;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "dpr.send_for_mac")
  return(OM_stat);
} 

#define MACRO_BUFF_SIZE     8  

method EMget_macro_ids(IGRlong     *EMmsg;
                       IGRint      num_levels;
                       IGRboolean  return_bottom_up;
                       IGRint      *num_macro_ids;
                       GRobjid     **macro_ids;
                       OMuword     options)
/*
Description
    Return the DPR ids that make up the macro.

Notes
    No options...yet.
    Free macro_ids via om$dealloc.

History
    DLB     05/02/91    Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRboolean        return_me;
  extern IGRboolean EFisAncestryValid();
  extern OMuword    OPP_EMSsfmacro_class_id;


  *EMmsg = EMS_S_Success;

  return_me = !EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                                 OPP_EMSsfmacro_class_id, FALSE);
 
  if (return_me && !return_bottom_up)
  {
    EFrealloc_if_needed(EMmsg, macro_ids, *num_macro_ids, 
                        MACRO_BUFF_SIZE, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;

    (*macro_ids)[*num_macro_ids] = my_id;
    (*num_macro_ids)++;
  }  

  if (return_me) num_levels--;

  if (num_levels)
  {
    OM_S_CHANSELECT to_comps;
    to_comps.type = OM_e_addr;
    to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

    OM_stat = om$send(msg = message EMSdpr.EMget_macro_ids(EMmsg, num_levels,
                            return_bottom_up, num_macro_ids, macro_ids,
                            options),
                      p_chanselect = &to_comps);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;  
    OM_stat = OM_S_SUCCESS;
  }

  if (return_me && return_bottom_up)
  {
    EFrealloc_if_needed(EMmsg, macro_ids, *num_macro_ids, 
                        MACRO_BUFF_SIZE, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;

    (*macro_ids)[*num_macro_ids] = my_id;
    (*num_macro_ids)++;
  }  

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "dpr.get_macro_ids")
  return(OM_stat);
}
end implementation EMSdpr;
