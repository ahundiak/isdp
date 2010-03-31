/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Returns dummy edge definition.
History
	23-Mar-89	SM	Creation.
*/
class implementation EMSdumedge;

method EMgetedgedef(IGRlong *EMmsg; IGRushort options;
		    struct EMSedgeinfo *edinfo)
{
 IGRlong		sts;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = om$send(mode = OM_e_wrt_message, msg = message EMSpartedge.EMgetedgedef
			(EMmsg, options, edinfo), targetid = my_id);
 edinfo->edgetype = EMSdummy;

 return(OM_S_SUCCESS);
}

end implementation EMSdumedge;
