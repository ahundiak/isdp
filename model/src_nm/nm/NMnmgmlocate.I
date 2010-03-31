class implementation NMnonmanigm;

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
 IGRlong    sts=OM_S_SUCCESS;
 IGRint     EMmsg=EMS_S_Success;

 if (ME.NMnonmanigm->nmprops & NMgm_Active)
  {
   /*Eligible for locate...*/
   sts = om$send(mode = OM_e_wrt_message,
                      msg = message NMnonmani.GRlocate(cvl, range_key),
                      targetid = my_id);
  }
 EMWRAPUP(EMmsg, sts, "NMnonmanigm.GRlocate");
 return(sts);
}

end implementation NMnonmanigm;

