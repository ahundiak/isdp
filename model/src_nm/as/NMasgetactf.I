class implementation NMassoctrans;

#include "OMmacros.h"
#include "nm.h"

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
   stopinfo->stopclsid = NULL;
   stopinfo->stopid = (struct GRid *) om$malloc(size = sizeof(struct GRid));
   EMerr_hndlr(!stopinfo->stopid, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
   stopinfo->stopid->objid = my_id;
   stopinfo->stopid->osnum = OM_Gw_current_OS;
   (*args)[i] = (IGRchar *) stopinfo;
  }


wrapup:
EMWRAPUP(*EMmsg, sts, "NMassoctrans.NMget_actid_funcs");
return(sts);
}


method NMfree_actid_funcs(IGRlong *EMmsg; IGRint (***f)(); IGRchar ***args)
{
 IGRint			numst = 0, i;
 struct NMgetnode_trans_args *stopinfo = NULL;

 *EMmsg = EMS_S_Success;

 numst = om$dimension_of(varray = ME.NMassoctrans->transmigrate);
 EMerr_hndlr(!numst, *EMmsg, EMS_I_Useless, wrapup);

 if(f && *f) 
  {
   om$dealloc(ptr = *f);
   *f = NULL;
  }

 if(args && *args)
  {
   for(i=0; i<numst; i++)
    {
     if(!(*args)[i]) continue;
     stopinfo = (struct NMgetnode_trans_args *) (*args)[i];
     if(stopinfo->stopid) om$dealloc(ptr = stopinfo->stopid);
     if(stopinfo->stopclsid) om$dealloc(ptr = stopinfo->stopclsid);
     om$dealloc(ptr = stopinfo);
     (*args)[i] = NULL;
    }
   om$dealloc(ptr = *args);
   *args = NULL;
  }

wrapup:
return(OM_S_SUCCESS);
}

end implementation NMassoctrans;
