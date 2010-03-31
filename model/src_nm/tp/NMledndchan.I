class implementation NMlistedge;

#include "OMmacros.h"

method NDdisconnect(int nb_root; struct GRid *root)
{
 IGRlong		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 OM_S_CHANSELECT	to_edges;


 NMmake_chanselect(NMlistedge_to_edges, &to_edges);

 if(!nb_root || !root)
  {
   sts = om$send(msg = message Root.wild_disconnect(to_edges), 
	 targetid = my_id);

   sts = om$vla_set_dimension(varray = ME.NMedge->reverse, size = 0);
  }
 else
  sts = OM_E_ABORT;

EMWRAPUP(EMmsg, sts, "NMlistedge.NDdisconnect");
return(sts);
}


method NDconnect(int nb_root; struct GRid *root; struct GRid original;
	         IGRint type)
{
 return(OM_E_ABORT);
}



end implementation NMlistedge;
