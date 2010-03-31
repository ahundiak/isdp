class implementation NMnonmanitp;

method NMpass_model(IGRlong *EMmsg; OM_S_MESSAGE *messg; 
		    struct GRid *modelid)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSobject_info  *parents = NULL, parentsbuf;
 IGRint			nump = 0;

 *EMmsg = EMS_S_Success;
 if(modelid) modelid->objid = NULL_OBJID;

 parents = &parentsbuf; 
 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
	1, &nump), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!nump, *EMmsg, EMS_I_Fail, wrapup);

 if(messg)
  {
   sts = om$send(msg = messg, targetid = parents[0].grid.objid, 
	 targetos = parents[0].grid.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 if(modelid) *modelid = parents[0].grid;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMnonmanitp.NMpass_model");
return(sts);
}

end implementation NMnonmanitp;
