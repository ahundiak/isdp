class implementation NMassoc;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "nddef.h"

#define StaticBuf 10

method NMget_parent_info(IGRlong *EMmsg; struct EMSobject_info **parents;
        IGRint inbufsize, *count)
{
 struct GRid	 *junk = NULL, *loc_parents = NULL, loc_parentsbuf[StaticBuf];
 unsigned int    *root_type = NULL, root_typebuf[StaticBuf], loc_count = 0;
 IGRint		 i;
 IGRlong	sts = OM_S_SUCCESS;
 union EMSparent_info *roots = NULL, rootsbuf[StaticBuf];

 *EMmsg = EMS_S_Success;
 if(count) *count = 0;

 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NDnodein.NDget_objects(ND_ROOT | ND_IN_BUF, NULL, 
       NULL, &junk, 0, MAXINT, (IGRint *) &loc_count), targetid = my_id);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!loc_count, *EMmsg, EMS_I_Useless, wrapup);

 if(parents)
  {
   if(loc_count > StaticBuf)
    {
     loc_parents = (struct GRid *) om$malloc(size = loc_count * 
                 sizeof(struct GRid));
     root_type = (unsigned int *) om$malloc(size = loc_count * 
               sizeof(unsigned int));
     roots = (union EMSparent_info *) om$malloc(size = loc_count *
           sizeof(union EMSparent_info));
    }
   else
    {
     loc_parents = loc_parentsbuf;
     root_type = root_typebuf;
     roots = rootsbuf;
    }

   EMerr_hndlr(!loc_parents || !root_type || !roots, *EMmsg, 
             EMS_E_NoDynamicMemory, wrapup);
   OM_BLOCK_MOVE(junk, loc_parents, loc_count * sizeof(struct GRid));

   for(i=0; i<loc_count; i++) root_type[i] = EMSgrid;

   sts = om$send(mode = OM_e_wrt_message, 
         msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, loc_count, 
         (IGRchar *) loc_parents, root_type, roots), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(loc_count > inbufsize)
    *parents = (struct EMSobject_info *) om$malloc(size = loc_count * 
             sizeof(struct EMSobject_info));
   EMerr_hndlr(!parents, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   for(i=0; i<loc_count; i++) (*parents)[i] = roots[i].grobj;
  }

 if(count) *count = loc_count;

wrapup:
if(loc_parents && (loc_parents != loc_parentsbuf))
 om$dealloc(ptr = loc_parents);
if(root_type && (root_type != root_typebuf))
 om$dealloc(ptr = root_type);
if(roots && (roots != rootsbuf))
 om$dealloc(ptr = roots);

EMWRAPUP(*EMmsg, sts, "NMassoc.NMget_parent_info");
return(sts);
}

end implementation NMassoc;
