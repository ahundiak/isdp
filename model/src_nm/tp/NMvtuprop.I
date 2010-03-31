class implementation NMvertex_use;

method NMprop(IGRlong *EMmsg; unsigned char options, *props)
{
 *EMmsg = EMS_S_Success;
	
 if(options & NMprop_Get) *props = ME.NMvertex_use->props;
 if(options & NMprop_SetOn) ME.NMvertex_use->props |= *props;
 if(options & NMprop_SetOff) ME.NMvertex_use->props &= ~(*props);
 return(OM_S_SUCCESS);
}

end implementation NMvertex_use;
