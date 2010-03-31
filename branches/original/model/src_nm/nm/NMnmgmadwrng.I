class implementation NMnonmanigm;

method GRaddwrng (IGRlong *EMmsg; struct GRmd_env *md_info)
{
  OM_S_CHANNUM   channum;
  OM_S_CHANSELECT to_components;
  IGRlong sts = OM_S_SUCCESS, i;
  struct NMgmSSI ssi;


  *EMmsg = EMS_S_Success;
  NMinit_ssi(&ssi);
  EMmake_chanselect(GRcmpowner_to_components, &to_components);

  sts = om$get_channel_number (channame = "GRconnector.to_owners",
                                  p_channum = &channum);
  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, MSFAIL, wrapup);

  if ( (channum.classid == in_channel.classid &&
      channum.number == in_channel.number) ||
      (ME.NMnonmanigm->nmprops & NMgm_Active))
  {
   sts = om$send( msg = OPPmargs,
                     p_chanselect = &to_components,
                     from = NULL,
                     to   = GRDGNLIMITS_MAX_I);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 sts = om$send(msg = message NMnonmanigm.NMget_SSI
       (EMmsg, &ssi, NMgetssi_cache), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<ssi.num_vtx; i++)
  {
   sts = om$send(msg = OPPmargs, targetid = ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "NMnonmanig.GRaddwrng");
return(sts);
}
end implementation NMnonmanigm;

