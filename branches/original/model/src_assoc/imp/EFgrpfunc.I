class implementation EMSagrp;

#include "EMSkey.h"

from EMSpointer import EMinit;

int EFmake_pointer_to_comp(EMmsg, located_obj, context_GRid, path, as_osnum, as,
                       my_GRid)
IGRlong *EMmsg;
struct GRid *located_obj;
struct GRid *context_GRid;
char *path;
GRspacenum as_osnum;
struct GRid *as;
struct GRid *my_GRid;
{
 IGRboolean found = FALSE;
 IGRchar temp_path[256];
 IGRlong status;
 IGRint chan_count,i;
 struct GRid temp_GRid;
 OM_S_CHANSELECT children;
 OM_S_OBJECT_LINKAGE *children_linkage;

 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;	

 as->objid = NULL_OBJID;
 as->osnum = as_osnum;

 EMmake_chanselect(NDchildren_children, &children);

 status = om$get_channel_count(p_chanselect = &children,
                               objid = my_GRid->objid,
                               osnum = my_GRid->osnum,
                               count = (OMuint *)&chan_count);
 if (!(1&status)) goto wrapup;

 if (chan_count)
 {
  children_linkage = (OM_S_OBJECT_LINKAGE *) stackalloc(chan_count *   
                     sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!children_linkage, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$get_channel_objects(objid = my_GRid->objid,
                                  osnum = my_GRid->osnum,
                                  p_chanselect = &children,
                                  list = children_linkage,
                                  size = chan_count,
                                  count = (OMuint *)&chan_count);
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

  if (temp_GRid.objid == (located_obj->objid))
   {
    as->objid = children_linkage[i].S_objid;
    as->osnum = children_linkage[i].osnum;
    found = TRUE;
    break;
   }
  }
 }

 if (!found)
 {
  status = om$construct(classid = OPP_EMSpointer_class_id,
                        p_objid = &as->objid,
                        osnum = as_osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  as->osnum = as_osnum;

  status = om$send (msg = message EMSpointer.EMinit(EMmsg, 
                         NULL,
                         my_GRid, context_GRid, located_obj->objid),
                   senderid = my_GRid->objid,
                   targetid = as->objid,
                   targetos = as->osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }

 temp_GRid = *as;
 temp_path[0] = '\0';
 status = om$send (msg = message NDnode.NDmake_source(EMmsg,&temp_GRid,
                         context_GRid,temp_path,as_osnum,as),
                   senderid = my_GRid->objid,
                   targetid = as->objid,
                   targetos = as->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSagrp:EFmake_pointer_to_comp error");
 return (status);
}

int pptranslatekeyid ( EMmsg, options, md_env, component_objid, key_size,
                   key, my_GRid)
IGRlong *EMmsg;
IGRuint options;
struct GRmd_env *md_env;
GRobjid *component_objid;
IGRint *key_size;
IGRchar **key;
struct GRid *my_GRid;
/* *********************************************************************
Description
 This function translates a component id into a key/or a key into an 
 component id depending upon the options.

Arguments
 EMmsg: Completion code.
 options : EMS_OPT_KEY_FROM_ID : If wanting a key from an id.
           EMS_OPT_ID_FROM_KEY : If wanting an id from a key.
 md_env : environment of the object to which this message is sent.
 component_objid : For EMS_OPT_KEY_FROM_ID
                   The input id. 
                   For EMS_OPT_ID_FROM_KEY
                   The output id
 key_size: Size of the key useful if one wants to malloc/stackalloc
           key information. Only true for EMS_OPT_KEY_FROM_ID 
 key : For EMS_OPT_KEY_FROM_ID
       If *key is set to NULL then memory is malloced and key is returned
       in malloced memory.
       Otherwise it is assumed that the caller has malloced enough memory
       usually determined by sending the same message to the object and
       setting key to NULL
       For EMS_OPT_ID_FROM_KEY
       It is expected that the input key is passed in using this.

Related include files:
 EMSkey.h

Notes
 Upon exit the completion code will be one of the following:
 EMS_E_InvalidArg: As the name says. 
 EMS_E_InvalidCase: Not currently handled.
 EMS_E_Fail: Other forms of failure
 EMS_S_Success: If all goes well.

History
 Creation : PP : 10/02/91

************************************************************************* */
{
 IGRlong status;
 IGRint key_count;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (options & EMS_OPT_KEY_FROM_ID)
 {
  key_count = 0;
  EFgenerate_key_from_id(EMmsg, *component_objid,
                         my_GRid->osnum, my_GRid->objid,
                         &key_count, key,0,NULL);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  if (!key)
   *key_size = sizeof (struct EMSkey) * key_count;
 }
 else if (options & EMS_OPT_ID_FROM_KEY)
 {
  EMerr_hndlr(!key, *EMmsg, EMS_E_InvalidArg, wrapup);
  key_count = (*key_size) / (sizeof (struct EMSkey));
  EFgenerate_id_from_key(EMmsg, my_GRid->objid,
                         my_GRid->osnum, key_count, *key,
                         component_objid,NULL);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In pptranslatekeyid error");
 return (status);
}

end implementation EMSagrp;
