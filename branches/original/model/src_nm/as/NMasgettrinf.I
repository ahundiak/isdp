class implementation NMassoctrans;

#include "OMmacros.h"

method NMget_trans_info(IGRlong *EMmsg; IGRboolean **transmigrate;
			 struct GRid **base_state; IGRint *num_states)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			numst = 0, i;
 
 *EMmsg = EMS_S_Success;

 if(num_states) *num_states = 0;

 numst = om$dimension_of(varray = ME.NMassoctrans->transmigrate);
 EMerr_hndlr(!numst, *EMmsg, EMS_I_Useless, wrapup);
 
 if(transmigrate && !*transmigrate)
  {
   *transmigrate = (IGRboolean *) om$malloc(size = numst * sizeof(IGRboolean));
   EMerr_hndlr(!*transmigrate, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(base_state && !*base_state)
  {
   *base_state = (struct GRid *) om$malloc(size = numst * sizeof(struct GRid));
   EMerr_hndlr(!*base_state, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }

 if(transmigrate)
  OM_BLOCK_MOVE(ME.NMassoctrans->transmigrate, *transmigrate, 
                numst * sizeof(IGRboolean));

 if(base_state)
  for(i=0; i<numst; i++)
   {
    sts = NMtag(EMmsg, &(*base_state)[i], &ME.NMassoctrans->base_state[i], 
          FALSE);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }

 if(num_states) *num_states = numst; 

wrapup:
EMWRAPUP(*EMmsg, sts, "NMassoctrans.NMget_trans_info");
return(sts);
}

end implementation NMassoctrans;
