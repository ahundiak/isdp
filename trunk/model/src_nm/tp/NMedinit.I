class implementation NMedge;

method NMinit(IGRlong *EMmsg; unsigned int nminit_opt;
		unsigned char nmprops; IGRint num_edges;
		struct GRid *edges, *surfs; IGRboolean *reverse;
		struct GRmd_env *env; struct NMgmSSI *ssi)
{
 IGRlong sts = OM_S_SUCCESS;
 extern OM_S_OBJID current_creator;
 unsigned int connect_opt = NULL;
 IGRboolean external_to_model = FALSE;

 *EMmsg = EMS_S_Success;
 external_to_model = (nminit_opt & NMinit_ExternalToModel) ||
		     (nmprops & NMedge_ExternalToModel);
		
 ME.NMedge->props = nmprops;
 if(external_to_model)
  {
   ME.NMedge->props |= NMedge_ExternalToModel;
   connect_opt = NMconnect_ExternalToModel;
  }

 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &current_creator, TRUE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;


 if((nminit_opt & NMinit_AddToSSI) && ssi)
  {
   sts = NMsetUpSSI(EMmsg, NULL, ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   ssi->nmedges[ssi->num_nmedges++] = my_id;
   ssi->nmedgesbufsize--;
  }

 if(num_edges)
  {
   if(nminit_opt & NMinit_CompatibleVertices)
    connect_opt |= NMconnect_CompatibleVertices;

   if(nminit_opt & NMinit_AddToSSI)
    connect_opt |= NMconnect_AddToSSI;

   sts = om$send(msg = message NMedge.NMconnect_edges(EMmsg, num_edges, 
	 edges, surfs, reverse, env, ssi, connect_opt), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }


wrapup:
 EMWRAPUP(*EMmsg, sts, "NMedge.NMinit");
 return(sts);
}

end implementation NMedge;
