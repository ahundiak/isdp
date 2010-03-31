class implementation NMnonmanigm;

method NMprop(IGRlong *EMmsg; IGRushort options, *props)
{
 *EMmsg = EMS_S_Success;
 if(options & NMprop_Get) *props = ME.NMnonmanigm->nmprops;
 if(options & NMprop_SetOn) ME.NMnonmanigm->nmprops |= *props;
 if(options & NMprop_SetOff) ME.NMnonmanigm->nmprops &= ~(*props);
 return(OM_S_SUCCESS);
}
end implementation NMnonmanigm;
