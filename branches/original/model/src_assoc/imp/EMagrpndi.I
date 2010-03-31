class implementation EMSagrp;

#include "EMSkey.h"

from EMSpointer import EMinit;

method NDmake_source(IGRlong *EMmsg;
		     struct GRid *located_obj,*context_GRid;char *path;
		     GRspacenum as_osnum; struct GRid *as)
{
 struct GRid my_GRid;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (located_obj->objid == my_id)
 {
  return (om$send (mode = OM_e_wrt_message,
                   targetid = my_id,
                   msg = message EMSassoc.NDmake_source(EMmsg,located_obj,
                         context_GRid, path, as_osnum, as)));
 }

 return (EFmake_pointer_to_comp(EMmsg, located_obj, context_GRid, path, 
                       as_osnum, as,
                       &my_GRid));
}

method EMtranslate_id_key(IGRlong *EMmsg; 
                          unsigned int options;
                          struct GRmd_env *md_env;
                          GRobjid *component_objid;
                          IGRint *key_size;
                          IGRchar **key)
/* *********************************************************************
Description
 This message translates a component id into a key/or a key into an 
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
 struct GRid my_GRid;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 return (pptranslatekeyid ( EMmsg, options, md_env, component_objid, key_size,
                   key, &my_GRid));

}

end implementation EMSagrp;
