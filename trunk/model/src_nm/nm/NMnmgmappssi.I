class implementation NMnonmanigm;

method NMappend_SSI(IGRlong *EMmsg; struct NMgmSSI *ssi; 
		    IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct NMgmSSI		new_ssi;
 struct NMentities	*new_nm = NULL, *in_nm = NULL;
 IGRint			i, j, totaledsin = 0, total_oldedsin = 0;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&new_ssi);

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &new_ssi, NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Append the incoming data to my existing data.
 */
 for(i=0; i<ssi->num_nmedges; i++)
  {
   sts = NMsetUpSSI(EMmsg, NULL, &new_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   new_ssi.nmedges[new_ssi.num_nmedges++] = ssi->nmedges[i];
   new_ssi.nmedgesbufsize--;
  }

 for(i=0; i<ssi->num_vtx; i++)
  {
   sts = NMsetUpSSI(EMmsg, NULL, &new_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   new_ssi.vtx[new_ssi.num_vtx++] = ssi->vtx[i];
   new_ssi.vtxbufsize--;
  }

 for(i=0; i<ssi->num_sfs; i++)
  {
   in_nm = &ssi->nmentities[i];

   for(j=0; j<in_nm->num_flps; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->flps[new_nm->num_flps++] = in_nm->flps[j];
     new_nm->flpsbufsize--;
    }

   for(j=0; j<in_nm->num_vtxuses; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->vtxuses[new_nm->num_vtxuses++] = in_nm->vtxuses[j];
     new_nm->vtxusebufsize--;
    }

   for(j=0; j<in_nm->num_edges; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->edges[new_nm->num_edges++] = in_nm->edges[j];
     new_nm->edgesbufsize--;
    }

   new_nm = NULL;
   sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);

   total_oldedsin = 0;
   for(j=0; j<new_nm->numedgesout; j++)
    total_oldedsin += new_nm->numedgesin[j];

   totaledsin = 0;
   for(j=0; j<in_nm->numedgesout; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->edgesout[new_nm->numedgesout] = in_nm->edgesout[j];
     new_nm->numedgesin[new_nm->numedgesout++] = in_nm->numedgesin[j];
     new_nm->edgesoutbufsize--;
     totaledsin += in_nm->numedgesin[j];
    }
 
   for(j=0; j<totaledsin; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->edgesin[total_oldedsin++] = in_nm->edgesin[j];
     new_nm->edgesinbufsize--;
    }


   for(j=0; j<in_nm->numedgesrev; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->edgesrev[new_nm->numedgesrev++] = in_nm->edgesrev[j];
     new_nm->edgesrevbufsize--;
    }


   for(j=0; j<in_nm->numedcon; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->edcon[new_nm->numedcon] = in_nm->edcon[j];
     new_nm->nmedgescon[new_nm->numedcon++] = in_nm->nmedgescon[j];
     new_nm->edconbufsize--;
    }


   for(j=0; j<in_nm->numeddiscon; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->eddiscon[new_nm->numeddiscon] = in_nm->eddiscon[j];
     new_nm->nmedgescon[new_nm->numeddiscon++] = in_nm->nmedgescon[j];
     new_nm->eddisconbufsize--;
    }

   for(j=0; j<in_nm->numvtxusechg; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->vtxusechg[new_nm->numvtxusechg] = in_nm->vtxusechg[j];
     new_nm->origedges[new_nm->numvtxusechg] = in_nm->origedges[j];
     new_nm->repledges[new_nm->numvtxusechg++] = in_nm->repledges[j];
     new_nm->vtxusechgbufsize--;
    }


   for(j=0; j<in_nm->numvtxusetr; j++)
    {
     new_nm = NULL;
     sts = NMsetUpSSI(EMmsg, &in_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!new_nm, *EMmsg, EMS_E_Fail, wrapup);
     new_nm->vtxusetr[new_nm->numvtxusetr] = in_nm->vtxusetr[j];
     new_nm->origvtx[new_nm->numvtxusetr] = in_nm->origvtx[j];
     new_nm->replvtx[new_nm->numvtxusetr++] = in_nm->replvtx[j];
     new_nm->vtxusetrbufsize--;
    }

  } /* for(i=0; i<ssi->num_sfs; i++) */


 /* Post the new ssi.
 */
 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &new_ssi), 
	targetid = my_id);

wrapup:
NMfree_ssi(&new_ssi);
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMappend_SSI");
return(sts);
}

end implementation NMnonmanigm;
