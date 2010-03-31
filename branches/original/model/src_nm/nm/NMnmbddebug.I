class implementation NMnonmanibnd;

method debug()
{
 IGRint j, i;
 IGRchar keyin;
 OM_S_CHANSELECT to_comps;
 IGRlong EMmsg = EMS_S_Success, sts = OM_S_SUCCESS;
 struct NMgmSSI ssi;
 struct GRid *cvptr;

 NMinit_ssi(&ssi);

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(&EMmsg, &ssi, NULL), 
       targetid = my_id);
 if(!(1&EMmsg&sts)) goto wrapup;

 fprintf(stderr, "NM Bdry Creation object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tProps: 0x%x\n", ME.NMnonmanigm->nmprops);
 fprintf(stderr, "\tGraphics Props: 0x%x\n", (IGRushort)ME.GRgraphics->properties);
 fprintf(stderr, "\tOwner Props: 0x%x\n", ME.GRflxown->owner_properties);
 fprintf(stderr, "\tCht = %lf\n", ME.NMnonmanibnd->cht);
 fprintf(stderr, "\tRecomp info:\n");

 cvptr = ME.NMnonmanibnd->cvid;
 for(i=0; i<ME.NMnonmanibnd->num_sfs; i++)
  {
   struct GRid grid;

   grid.objid = NULL_OBJID;
   sts = NMtag(&EMmsg, &grid, &ME.NMnonmanibnd->sfid[i], FALSE);
   fprintf(stderr, "\t\t%d) Surface: %d.%d\n", i+1, grid.osnum, grid.objid);
   fprintf(stderr, "\t\t\tCurves:\n");
   for(j=0; j<ME.NMnonmanibnd->num_cvs[i]; j++)
    {
     grid.objid = NULL_OBJID;
     sts = NMtag(&EMmsg, &grid, cvptr, FALSE);
     fprintf(stderr, "\t\t\t%d) %d.%d\n", j+1, grid.osnum, grid.objid);
     cvptr++;
    }
  }

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

end implementation NMnonmanibnd;
