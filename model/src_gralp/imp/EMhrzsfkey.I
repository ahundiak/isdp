class implementation EMShorizon;

#include "EMSkey.h"

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
 Creation : PP : 05/25/91
 Jack 11/18/91   Copied from EMSsurface implementation. 

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
                         OM_Gw_current_OS, my_id,
                         &key_count, key,0,NULL);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  if (!key)
   *key_size = sizeof (struct EMSkey) * key_count;
 }
 else if (options & EMS_OPT_ID_FROM_KEY)
 {
  EMerr_hndlr(!key, *EMmsg, EMS_E_InvalidArg, wrapup);
  key_count = (*key_size) / (sizeof (struct EMSkey));
  EFgenerate_id_from_key(EMmsg, my_id,
                         OM_Gw_current_OS, key_count, *key,
                         component_objid,NULL);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMShorizon:EMtranslate_key_id error");
 return (status);
}
end implementation EMShorizon;

