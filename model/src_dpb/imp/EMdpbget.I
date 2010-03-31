class implementation EMSdpb;

method EMget_dpbinfo (IGRlong *EMmsg;
                      struct EMdpbinfo *dpbinfo)

/* ************************************************************************

Description
  This method gets all the dpb information in one shot. 

Notes
  Upon exit the completion code will be one of the following:
  EMS_S_Success : Always successful

   *********************************************************************** */
{

 *EMmsg = EMS_S_Success;

  dpbinfo->u_order = me->u_order;
  dpbinfo->v_order = me->v_order;
  dpbinfo->u_rules = me->u_rules;
  dpbinfo->v_rules = me->v_rules;
  dpbinfo->props   = me->props;

 return (OM_S_SUCCESS);
}

end implementation EMSdpb;
