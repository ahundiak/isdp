class implementation EMSboundary;

from NDnode import NDmake_source;

method EMget_dependents (IGRlong *EMmsg;
                          int options;
                          struct GRid *context_GRid;
                          IGRint *dependent_count;
                          struct GRid **dep_GRid)
/* ************************************************************************
Description
 This message shall get the real dependents of a topology element.

Arguments
 EMmsg : Completion code
 options : Currently unused
 context_GRid : Object grid of the context if applicable. NULL otherwise
                This would be true if the connections have been made
                across reference files.
 dependent_count : Number of real dependents
 dep_GRid : If NULL then only the count is returned.
            If dep_GRid is not NULL and *dep_GRid is NULL then memory
            is malloced inside the routine.
            If dep_GRid is not NULL and *dep_GRid is not NULL then it
            is assumed that enough memory has been malloced for the
            dependents

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there is failure
 EMS_E_DynamicMemoryAllocated : If there is some error in mallocing memory
************************************************************************** */

{
 IGRint status, i;
 OMuint chan_count;
 OM_S_OBJID constr_os;
 OM_S_CHANSELECT children;
 OM_S_OBJECT_LINKAGE *children_linkage = NULL;
 struct GRid ptr_GRid;
 struct GRid my_GRid, *cntxt_ptr, cntxt_buff_GRid;

 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 ptr_GRid.objid = NULL_OBJID;

 if (context_GRid)
 {
  cntxt_ptr = context_GRid;
  constr_os = context_GRid->objid;
 }
 else
 {
  cntxt_ptr = &cntxt_buff_GRid;
  cntxt_ptr->objid = NULL_OBJID;
  constr_os = OM_Gw_current_OS;
 }


 status = EMreturn_pointer(EMmsg, NULL, &my_GRid,cntxt_ptr, constr_os,
                  &ptr_GRid, NULL);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
 if (ptr_GRid.objid == NULL_OBJID)
 {
  *dependent_count = 0;
  return (OM_S_SUCCESS);
 }

 if (cntxt_ptr->objid != NULL_OBJID)
 {
  char path[256];
  struct GRid temp_GRid;

  path[0] = '\0';
  status = om$send (msg = message NDnode.NDmake_source(EMmsg,&ptr_GRid,
                         context_GRid,path,constr_os,&temp_GRid),
                   targetid = ptr_GRid.objid,
                   targetos = ptr_GRid.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  ptr_GRid = temp_GRid;
 }

 status = om$make_chanselect(channame = "NDchildren.children",
                             p_chanselect = &children);
 if (!(1&status)) goto wrapup;

 status = om$get_channel_count(p_chanselect = &children,
                               objid = ptr_GRid.objid,
                               osnum = ptr_GRid.osnum,
                               count = &chan_count);
 if (!(1&status)) goto wrapup;
 
 *dependent_count = chan_count;
 if (!dep_GRid)
  goto wrapup;
 else
 {
  children_linkage = (OM_S_OBJECT_LINKAGE *) stackalloc(chan_count *   
                     sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!children_linkage, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$get_channel_objects(objid = ptr_GRid.objid,
                                  osnum = ptr_GRid.osnum,
                                  p_chanselect = &children,
                                  list = children_linkage,
                                  size = chan_count,
                                  count = &chan_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  if (!(*dep_GRid))
  {
   *dep_GRid = (struct GRid *) om$malloc(size = chan_count *
                               sizeof (struct GRid));
   EMerr_hndlr(!(*dep_GRid), *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
  }

  for (i=0;i<chan_count;i++)
  {
   (*dep_GRid)[i].objid = children_linkage[i].S_objid;
   (*dep_GRid)[i].osnum = children_linkage[i].osnum;
  }
 }
 
wrapup:
 if (children_linkage) stackfree (children_linkage);
 return (status);
}

end implementation EMSboundary;

