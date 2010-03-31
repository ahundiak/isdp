class implementation NMfeaturelp;

method EMpt_location( IGRlong *EMmsg;IGRdouble *point;  
                      struct EMSptloc_info *location;
		      struct EMSpartolbasis *partolbasis)
{
 IGRlong	sts = OM_S_SUCCESS;
 IGRshort	saveopt;

 *EMmsg = EMS_S_Success;

 saveopt = location->options;
 location->options |= EMS_PTLOC_NOLOOPTYPE;

 sts = om$send(mode = OM_e_wrt_message, msg = message EMSloop.EMpt_location
       (EMmsg, point, location, partolbasis), targetid = my_id);

location->options = saveopt;
EMWRAPUP(*EMmsg, sts, "NMfeaturelp.EMpt_location");
return(sts);
}

end implementation NMfeaturelp;
