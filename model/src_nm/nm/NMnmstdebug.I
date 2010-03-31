class implementation NMnonmanist;

method debug()
{
 IGRchar keyin;
 OM_S_CHANSELECT to_comps;
 IGRlong EMmsg = EMS_S_Success, sts = OM_S_SUCCESS;
 struct NMgmSSI ssi;
 void NMprint_ssi_debug();

 NMinit_ssi(&ssi);

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(&EMmsg, &ssi, NULL), 
       targetid = my_id);
 if(!(1&EMmsg&sts)) goto wrapup;

 fprintf(stderr, "NM stitch object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tProps: 0x%x\n", ME.NMnonmanigm->nmprops);
 fprintf(stderr, "\tGraphics Props: 0x%x\n", (IGRushort)ME.GRgraphics->properties);
 fprintf(stderr, "\tOwner Props: 0x%x\n", ME.GRflxown->owner_properties);
 fprintf(stderr, "\tCht = %lf, Lentol = %lf\n", ME.NMnonmanist->cht, 
         ME.NMnonmanist->lentol);

 NMprint_ssi_debug(&ssi);

 sts = om$send(mode = OM_e_wrt_message, msg = message NMassoctrans.debug(), 
       targetid = my_id);

 EFgetchar (stderr, "Debug components y/n [n] ", &keyin);
 if (toupper (keyin) == 'Y')
  {
   EMmake_chanselect(GRcmpowner_to_components, &to_comps);
   sts = om$send(msg = message Root.debug(), p_chanselect = &to_comps);
  }

wrapup:
NMfree_ssi(&ssi);

return(OM_S_SUCCESS);
}

end implementation NMnonmanist;
