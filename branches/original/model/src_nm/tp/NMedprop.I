class implementation NMedge;

method NMprop(IGRlong *EMmsg; unsigned char options, *props)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *props = ME.NMedge->props;
 if(options & NMprop_SetOn) ME.NMedge->props |= *props;
 if(options & NMprop_SetOff) ME.NMedge->props &= ~(*props);
 return(OM_S_SUCCESS);
}

end implementation NMedge;
