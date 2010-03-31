class implementation EMSgraloop;

method EMptnesting(IGRlong *EMmsg;IGRdouble *pt;struct EMSptloc_info *info;
		    struct EMSpartolbasis *partolbasis)
{
  *EMmsg = EMS_S_Success;
  info->location = EMS_L_UNKNWN;
  return(EMS_I_FeatureLoop);
}

end implementation EMSgraloop;
