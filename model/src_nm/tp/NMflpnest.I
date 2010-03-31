class implementation NMfeaturelp;

method EMnesting(IGRlong *EMmsg;struct EMSnest_info *nesting;
                  struct EMSpartolbasis *partolbasis)
{
  *EMmsg = EMS_I_Ambiguous;
  return(OM_S_SUCCESS);
}

method NMget_nesting_parent(IGRlong *EMmsg; GRobjid *parent; 
			     IGRboolean get_it)
{
 *EMmsg = EMS_S_Success;

 if(get_it) *parent = ME.NMfeaturelp->nesting_parent;
 else ME.NMfeaturelp->nesting_parent = *parent;

 return(OM_S_SUCCESS);
}

end implementation NMfeaturelp;
