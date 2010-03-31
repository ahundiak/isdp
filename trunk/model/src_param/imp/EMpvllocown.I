/*

Name
  EMpvllocown.I

Description
  This file contain the GRlocate_owner method
Notes


 */

class implementation EMSparamvl;

#include "EMSopt.h"
#include "lcdef.h"
#include "lcmsg.h"
#include "msdef.h"
#include "grerr.h"


/*

Name
  GRlocate_owner

Abstract

Synopsis

Description
  This method prevents to locate the EMSparamvl object while deleting.
Return Value

Notes

Index

Keywords
  
History
  10/13/93 : G Mallikarjuna : created

 */


method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
 *msg = EMS_S_Success;

 /*
  * check for delete command and return with success
  */
 if (!(cvl->attributes.obj_attr.owner_action & LC_DELETE_CMD))
  return (om$send (mode = OM_e_wrt_parent,
                   msg = message EMSparamvl.GRlocate_owner(msg,
                         cvl,path, path_position),
                   targetid = my_id));
 else
 {
  cvl->msg = MSSUCC;
  return (OM_S_SUCCESS);
 }
}


end implementation EMSparamvl;
