class implementation NMlistvtxuse;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"


#define StaticBuf 10

method NMget_parent_info(IGRlong *EMmsg; struct EMSobject_info **parents;
        IGRint inbufsize, *count)
{
 IGRint		 	i;
 OMuint			loc_count;
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_edges;
 OM_S_OBJECT_LINKAGE	*edges = NULL, edgesbuf[StaticBuf];
 struct GRmd_env 	my_env;
 IGRint 		bytes_in, bytes_out, rc;

 *EMmsg = EMS_S_Success;
 NMmake_chanselect(NMlistvtxuse_to_edges, &to_edges);

 bytes_in = sizeof(struct GRmd_env);
 gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                    nret = &bytes_out);
 EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);


 if(count) *count = 0;

 sts = om$get_channel_count(object = me, p_chanselect = &to_edges, 
       count = &loc_count);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!loc_count, *EMmsg, EMS_I_Useless, wrapup);
 
 if(loc_count > StaticBuf)
  edges = (OM_S_OBJECT_LINKAGE *) om$malloc(size = loc_count * sizeof
	   (OM_S_OBJECT_LINKAGE));
 else edges = edgesbuf;
 EMerr_hndlr(!edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$get_channel_objects(object = me, p_chanselect = &to_edges, 
       list = edges, size = loc_count, count = &loc_count);
 if(!(1&sts)) goto wrapup;

 if(loc_count > inbufsize)
  *parents = (struct EMSobject_info *) om$malloc(size = loc_count * 
             sizeof(struct EMSobject_info));
 EMerr_hndlr(!parents, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 for(i=0; i<loc_count; i++)
  {
   (*parents)[i].grid.objid = edges[i].S_objid;
   (*parents)[i].grid.osnum = edges[i].osnum;
   (*parents)[i].env = my_env;
  }

 if(count) *count = loc_count;

wrapup:
if(edges && (edges != edgesbuf))
 om$dealloc(ptr = edges);

EMWRAPUP(*EMmsg, sts, "NMlistvtxuse.NMget_parent_info");
return(sts);
}

end implementation NMlistvtxuse;
