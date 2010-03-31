class implementation NMvertex_use;

#include "OMmacros.h"

method NMinit(IGRlong *EMmsg; unsigned int nminit_opt;
		unsigned char nmprops; IGRint numedges; GRobjid *edges;
		enum EMScvinttype *loc_on_edge; IGRdouble *uvpt;
		struct NMgmSSI *ssi; struct GRid *sfid)
{
 IGRlong 		sts = OM_S_SUCCESS;
 extern OM_S_OBJID 	current_creator;
 struct NMentities 	*this_nm = NULL;
 unsigned int	connect_opt = NULL;
 IGRboolean 		external_to_model = FALSE;

 *EMmsg = EMS_S_Success;
 external_to_model = (nminit_opt & NMinit_ExternalToModel) ||
		     (nmprops & NMvtxuse_ExternalToModel);
		

 ME.NMvertex_use->props = nmprops;
 if(external_to_model)
  {
   ME.NMvertex_use->props |= NMvtxuse_ExternalToModel;
   connect_opt = NMconnect_ExternalToModel;
  }

 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &current_creator, TRUE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(uvpt) OM_BLOCK_MOVE(uvpt, ME.NMvertex_use->point, 2*sizeof(IGRdouble));

 if((nminit_opt & NMinit_AddToSSI) && ssi && sfid)
  {
   sts = NMsetUpSSI(EMmsg, sfid, ssi, &this_nm);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(!this_nm, *EMmsg, EMS_E_Fail, wrapup);

   this_nm->vtxuses[(this_nm->num_vtxuses)++] = my_id;
   this_nm->vtxusebufsize--;
  }

 if(numedges)
  {
   if(nminit_opt & NMinit_AddToSSI) connect_opt |= NMconnect_AddToSSI;

   sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, numedges, 
	 edges, loc_on_edge, uvpt, connect_opt, ssi), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
	

wrapup:
 EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMinit");
 return(sts);
}

end implementation NMvertex_use;
