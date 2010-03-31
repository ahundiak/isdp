/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include <stdio.h>

method EMis_associative (IGRlong *EMmsg;
                          IGRboolean *is_associative)
/* *******************************************************************
Description
 This message when sent to an object returns whether it is capable
 of participating in an associative relationship. By this I mean,
 whether it has the parent/child channels. The default implementation 
 is to examine whether it is subclassed off of EMSassoc. If so return
 TRUE, else return FALSE.


Arguments
 Output
 *is_associative: TRUE if associative FALSE otherwise.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail : If there is some form of an error.
History
 Creation : PP : 03/08/91
  ******************************************************************** */
{
 IGRlong status;
 extern OMuword OPP_NDnodein_class_id;
 OMuword my_classid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 status = om$get_classid(objid = my_id,
                         p_classid = &my_classid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$is_ancestry_valid(subclassid = my_classid,
                               superclassid = OPP_NDnodein_class_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (status == OM_S_SUCCESS)
   *is_associative = TRUE;
 else
   *is_associative = FALSE;

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsurface:EMis_associative error");
 return (status);
}

method EMtransform_to_associative(IGRlong *EMmsg;
                                   OM_S_OBJID *new_objid)
/* ******************************************************************
Description
 This message transforms the object to which this message is sent
 to be capable of participating in associative relationships. Default
 implementation is to send a EMget_assoc_class message to myself and
 then change class.

Arguments
 Output
 *new_objid : The object id of the associative counterpart
 EMmsg : Completion message

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail: If there is some form of failure

History
 Creation : PP : 03/08/91
 WBC : 12/03/93 : Removed the printf statement for OM_E_NOSUCHCLASS errors
                  (TR#119313978).
 ******************************************************************** */
{
 IGRlong status;
 char assoc_class_name[20];
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *new_objid = NULL_OBJID;

 status = om$send (msg = message EMSsurface.EMget_assoc_class(EMmsg,
                         assoc_class_name),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 status = om$change_class(objid = my_id,
                          sd_override = OM_K_change_class_sd_override,
                          classname = assoc_class_name);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 *new_objid = my_id;
wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsurface:EMtransform_to_associative error");
 return (status);
}

method EMget_assoc_class(IGRlong *EMmsg;
                          IGRchar *assoc_class_name)
/* ********************************************************************
Description
 This message when sent to a non-associative graphic object returns
 the associative class name which it can map to. The default implementation
 is to get the class name. (All the EMS classes are prefixed by
 EMS) and replace EMS with EMA and return that as class name. If this
 is not true for a subclass the same should be overriden. 

Arguments
 Output
 assoc_class_name: Name of the associative class.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_OMerror: If there is failure.

History
 Creation : PP : 03/07/91
 ******************************************************************** */
{
 IGRlong status;
 IGRchar my_class_name[40];

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = om$get_classname(objid = my_id,
                           classname = my_class_name);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 strcpy(assoc_class_name, my_class_name);
 assoc_class_name[2] = 'A';

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsurface:EMget_assoc_class");
 return (status);
}
end implementation EMSsurface;

