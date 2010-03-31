class implementation NMcreated;

#include "asbox.h"    /* For NULL_GRID */
#include "asmacros.h" /* For as$make_source */

from EMSpointer import EMinit;
from NDnode import ASreturn_go;
from NDnode import NDmake_source;

extern OMuword OPP_EMSpointer_class_id;
IGRlong NMreturn_pointer();

method GRmksource(IGRlong *EMmsg; struct GRid *context_GRid; GRspacenum 
		  constr_os;
		   struct GRid *ptr_GRid; IGRint options)
{
 IGRlong status;
 char path[256];
 struct GRid ptr_src_GRid, temp_GRid, my_GRid, *component_GRid;

 struct GRid creator_GRid;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 component_GRid = &my_GRid;
 creator_GRid.osnum = OM_Gw_current_OS;

 status = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg,
       &creator_GRid.objid, FALSE), targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Get the creator and determine if a pointer object already exists.
 */

 ptr_GRid->objid = NULL_OBJID;
 ptr_src_GRid.objid = NULL_OBJID;
/*
 * Examine whether a pointer already exists. 
 */
 status = NMreturn_pointer(EMmsg, NULL, component_GRid,
                           context_GRid, constr_os, ptr_GRid,
                           &ptr_src_GRid, creator_GRid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * No existing pointer object. Construct a new one.
 */
 if (ptr_GRid->objid == NULL_OBJID)
 {
  status = om$construct(classid = OPP_EMSpointer_class_id,
                       p_objid = &ptr_GRid->objid,
                       osnum = ptr_src_GRid.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  ptr_GRid->osnum = ptr_src_GRid.osnum;

  status = om$send (msg = message EMSpointer.EMinit(EMmsg, 
                         NULL,
                         &ptr_src_GRid, context_GRid, component_GRid->objid),
                   senderid = NULL_OBJID,
                   targetid = ptr_GRid->objid,
                   targetos = ptr_GRid->osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }

 temp_GRid = *ptr_GRid;
 path[0] = '\0';
 status = om$send (msg = message NDnode.NDmake_source(EMmsg,&temp_GRid,
                         context_GRid,path,constr_os,ptr_GRid),
                   senderid = NULL_OBJID,
                   targetid = ptr_GRid->objid,
                   targetos = ptr_GRid->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "In NMcreated.GRmksource");
 return (status);
}

static IGRlong NMreturn_pointer(EMmsg, options, component_GRid, 
                         context_GRid, constr_os,ptr_GRid, ptr_src_GRid, 
			 creator_GRid)
IGRlong *EMmsg;
unsigned int options;
struct GRid *component_GRid;
struct GRid *context_GRid;
OMuword constr_os;
struct GRid *ptr_GRid;
struct GRid *ptr_src_GRid, creator_GRid;
{
 IGRlong status, i;
 OMuint chan_count;
 IGRboolean found = FALSE;
 OM_S_CHANSELECT children;
 OM_S_OBJECT_LINKAGE *children_linkage = NULL;
 struct GRid /*creator_GRid,*/ src_GRid, temp_GRid;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 ptr_GRid->objid = NULL_OBJID;
 temp_GRid.objid = NULL_OBJID;
 src_GRid.objid = NULL_OBJID;

/*
 * If the creator is the same as the component, then create a source 
 * object if the connection is across reference files/if the creator is
 * non-associative,
 * else return the creator himself. 
 */

 if ((creator_GRid.objid == (component_GRid->objid)) &&
     (creator_GRid.osnum == (component_GRid->osnum)))
 {
  IGRboolean make_source = FALSE;

  if (!(EFisAncestryValid(EMmsg, creator_GRid.objid, creator_GRid.osnum, 
                          OPP_NDnodein_class_id, FALSE)))
   make_source = TRUE;

  if (context_GRid->objid != NULL_OBJID)
   make_source = TRUE;

  if (make_source)
  {
    status = ASmake_source_from_go(EMmsg, component_GRid,context_GRid,
                                 constr_os, ptr_GRid);
    if (!(1&status&*EMmsg)) goto wrapup;
  }
  else
    *ptr_GRid = *component_GRid;

  return (status);
 }

/*
 * If the creator is not the same as the component and if he is
 * is non-associative construct a source and look on his
 * parent channel for the pointer object. Construct the source with a
 * NULL_OBJID for context, since the pointer is going to be in the same
 * file as the creator.
 *
 * If the creator is associative then look on his parent channel for the
 * pointer object.
 */

if (!(EFisAncestryValid(EMmsg, creator_GRid.objid, creator_GRid.osnum, 
                          OPP_NDnodein_class_id, FALSE)))
{
  struct GRid temp_context;
  temp_context.objid = NULL_OBJID;
  status = ASmake_source_from_go(EMmsg,&creator_GRid,&temp_context,
                                constr_os,&src_GRid);
  if (!(1&status&*EMmsg)) goto wrapup;
}
else
 src_GRid = creator_GRid;

/*
 * If this is true there has been some major foul up.
 */
if (src_GRid.osnum != creator_GRid.osnum)
{
 *EMmsg = EMS_E_InvalidCase;
 goto wrapup;
}

 
 if (ptr_src_GRid)
  *ptr_src_GRid = src_GRid;

/*
 * Determine whether a pointer object already exists by looking for
 * objects on the children channel of the creator's source which could
 * either be a sourcein, source or the creator himself. 
 */

 status = om$make_chanselect(channame = "NDchildren.children",
                             p_chanselect = &children);
 if (!(1&status)) goto wrapup;

 status = om$get_channel_count(p_chanselect = &children,
                               objid = src_GRid.objid,
                               osnum = src_GRid.osnum,
                               count = &chan_count);
 if (!(1&status)) goto wrapup;

 if (chan_count)
 {
  children_linkage = (OM_S_OBJECT_LINKAGE *) om$malloc(size = chan_count *   
                     sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!children_linkage, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$get_channel_objects(objid = src_GRid.objid,
                                  osnum = src_GRid.osnum,
                                  p_chanselect = &children,
                                  list = children_linkage,
                                  size = chan_count,
                                  count = &chan_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
 found = FALSE;
 for (i=0;i<chan_count;i++)
 {
  temp_GRid.objid = NULL_OBJID;
  om$send (msg = message NDnode.ASreturn_go(&temp_GRid,NULL,
                          NULL),
                    senderid = NULL_OBJID,
                    targetid = children_linkage[i].S_objid,
                    targetos = children_linkage[i].osnum);

  if (temp_GRid.objid == (component_GRid->objid))
   {
    ptr_GRid->objid = children_linkage[i].S_objid;
    ptr_GRid->osnum = children_linkage[i].osnum;
    found = TRUE;
    break;
   }
  }
 }

 if (!found)
  ptr_GRid->objid = NULL_OBJID;

wrapup:
 if (children_linkage) om$dealloc (ptr = children_linkage);
 EMWRAPUP (*EMmsg, status, "In NMreturn_pointer");
 return (status);
}

end implementation NMcreated;

