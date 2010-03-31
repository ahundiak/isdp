class implementation NMinters;

#include "OMmacros.h"
#include "nm.h"

extern OMuword OPP_NMnonmani_class_id;

method NMget_actid_funcs(IGRlong *EMmsg; IGRint (***f)(); IGRchar ***args)
{
 IGRlong 		sts = OM_S_SUCCESS;
 IGRint			numst = 0, i, NMgetnode_trans();
 struct NMgetnode_trans_args *stopinfo;

 *EMmsg = EMS_S_Success;

 numst = om$dimension_of(varray = ME.NMassoctrans->transmigrate);
 EMerr_hndlr(!numst, *EMmsg, EMS_I_Useless, wrapup);

 if(!*f)
  *f = (IGRint (**)()) om$malloc(size = numst * sizeof(IGRint *));

 if(!*args)
  *args = (IGRchar **) om$malloc(size = numst * sizeof(IGRchar *));
 EMerr_hndlr(!*f || !*args, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 for(i=0; i<numst; i++)
  {
   (*f)[i] = NMgetnode_trans;
   stopinfo = (struct NMgetnode_trans_args *) om$malloc(size = 
                sizeof(struct NMgetnode_trans_args));
   EMerr_hndlr(!stopinfo, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   stopinfo->stopclsid = (OMuword *) om$malloc(size = sizeof(OMuword));
   stopinfo->stopid = NULL;
   EMerr_hndlr(!stopinfo->stopclsid, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
   *(stopinfo->stopclsid) = OPP_NMnonmani_class_id;
   (*args)[i] = (IGRchar *) stopinfo;
  }


wrapup:
EMWRAPUP(*EMmsg, sts, "NMinters.NMget_actid_funcs");
return(sts);
}


end implementation NMinters;
