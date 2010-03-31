class implementation EMSgraloop;

method EMnesting(IGRlong *EMmsg;struct EMSnest_info *nesting;
                  struct EMSpartolbasis *partolbasis)
{
  *EMmsg = EMS_I_OpenLoop;
  return(OM_S_SUCCESS);
}

end implementation EMSgraloop;
