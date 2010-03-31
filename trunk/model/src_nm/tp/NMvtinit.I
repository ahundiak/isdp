class implementation NMvertex;

#include "OMmacros.h"

method NMinit(IGRlong *EMmsg; unsigned int nminit_opt;
		unsigned char nmprops; IGRint num;
		struct GRid *vtxuses; IGRpoint xyzpoint; 
		struct NMgmSSI *ssi)
{
 IGRlong sts = OM_S_SUCCESS;
 unsigned int	connect_opt = NULL;
 IGRboolean 		external_to_model = FALSE;
 extern OM_S_OBJID current_creator;

 *EMmsg = EMS_S_Success;
 external_to_model = (nminit_opt & NMinit_ExternalToModel) ||
		     (nmprops & NMvtx_ExternalToModel);
		

 ME.NMvertex->props = nmprops;
 if(external_to_model)
  {
   ME.NMvertex->props |= NMvtx_ExternalToModel;
   connect_opt = NMconnect_ExternalToModel;
  }

 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &current_creator, TRUE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(xyzpoint) OM_BLOCK_MOVE(xyzpoint, ME.GR3dpoint->point, sizeof(IGRpoint));
 ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
 ME.GRgraphics->properties |= GRIS_DISPLAYABLE;

 if((nminit_opt & NMinit_AddToSSI) && ssi)
  {
   sts = NMsetUpSSI(EMmsg, NULL, ssi, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   ssi->vtx[ssi->num_vtx++] = my_id;
   ssi->vtxbufsize--;
  }

 if(nminit_opt & NMinit_AddToSSI) connect_opt |= NMconnect_AddToSSI;

 if(num)
  sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, num, 
	vtxuses, xyzpoint, ssi, connect_opt), targetid = my_id);
	

wrapup:
 EMWRAPUP(*EMmsg, sts, "NMvertex.NMinit");
 return(sts);
}

end implementation NMvertex;
