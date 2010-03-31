class implementation NMvertex;

method NMprop(IGRlong *EMmsg; unsigned char options, *props)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *props = ME.NMvertex->props;
 if(options & NMprop_SetOn) ME.NMvertex->props |= *props;
 if(options & NMprop_SetOff) ME.NMvertex->props &= ~(*props);
 return(OM_S_SUCCESS);
}

end implementation NMvertex;
