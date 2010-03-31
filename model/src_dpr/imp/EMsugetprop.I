class implementation EMSsuppress;

method EMgetProps(IGRlong *EMmsg; OMuword *props)
/*
Description
    This message will get the props bits in the props instance data.

Returned values
    EMSS_S_Success if all is well.

Notes
 
History
    07/19/91    DLB     Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  *props = ME.EMSsuppress->props;

  return(OM_S_SUCCESS);
}

end implementation EMSsuppress;
