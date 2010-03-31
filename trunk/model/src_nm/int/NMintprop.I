class implementation NMinters;

method NMprop(IGRlong *EMmsg; unsigned char options, *props)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *props = ME.NMinters->props;
 if(options & NMprop_SetOn) ME.NMinters->props |= *props;
 if(options & NMprop_SetOff) ME.NMinters->props &= ~(*props);
 return(OM_S_SUCCESS);
}

end implementation NMinters;
