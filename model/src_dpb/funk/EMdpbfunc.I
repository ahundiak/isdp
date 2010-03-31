/* ###################   APOGEE COMPILED   ################## */

class implementation EMSdpb;

#include "EMS.h"
#include "exmacros.h"
#include <stdio.h>

IGRint EMget_dpbobjid (EMmsg,dpbid, dpbos)

IGRlong *EMmsg;
OM_S_OBJID *dpbid;
OMuword *dpbos;

/* ***********************************************************************

 Description
      This function gets the dpb object id from the current module

      Output
       dpbid : object id of the dpb in the current module
       dpbos : object space of the dpb in the current object space

 Notes
      Upon exit the completion code will always be
       EMS_S_Success :  successful

 History
      PP : 10/19/87                 Creation

   ********************************************************************** */

{
 IGRlong 		status ;
 OM_S_OBJID 		mod_id; /* Object id of the module */
 OMuword 		mod_os; /* Object space of the module */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = ex$get_cur_mod (id = &mod_id, osnum = &mod_os);
 if (!(1&status)) goto wrapup;

 status = ex$get_super(mod_id = mod_id, mod_osnum = mod_os,
                       super_name = "EMSdpb", create = TRUE, 
                       super_class = "EMSdpb",
                       super_id = dpbid, super_osnum = dpbos);
 if (!(1&status)) goto wrapup;

wrapup:
 return (status);
}

IGRint EMdpb_getinfo (EMmsg, dpbinfo)
 IGRlong *EMmsg;
 struct EMdpbinfo *dpbinfo;

/* **************************************************************************
 Description
  This function gets the entire dpb information into the structure.
  The structure definition exists in the include file "EMSdpb.h"

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : if successful

History
 Creation : 06/27/88 : pp

  ************************************************************************** */
{
 IGRlong status;
 OM_S_OBJID dpbid;
 OMuword   dpbos;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = EMget_dpbobjid (EMmsg, &dpbid, &dpbos);
 if (!(1&status)) goto wrapup;

 status = om$send (msg = message EMSdpb.EMget_dpbinfo(EMmsg,
                         dpbinfo),
                   senderid = NULL_OBJID,
                   targetid = dpbid,
                   targetos = dpbos);
 if (!(1&status&*EMmsg)) goto wrapup;

 wrapup:
  return (status);
}



IGRint EMdpb_get_trans (EMmsg,parameter,buffer)
IGRlong *EMmsg;
IGRlong  parameter;
IGRlong *buffer;
/* **************************************************************************
Description
 This function when supplied with the dpb parameter interested in, 
 will put the arguments in a format the SUNs can digest and then
 call the the real function that will get the EMS dippy block data.
 Fun huh?  Gotta love the sun.


Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : if successful
  EMS_E_InvalidArg : if invalid arguments


History
 Creation : 03/10/92 : scw

  ************************************************************************** */
{
  IGRlong          status;
  IGRlong          long_buff;
  IGRuchar char_buff;

  long_buff = *buffer;
  char_buff = (IGRchar) long_buff;

  status = EMdpb_get (EMmsg,parameter,&char_buff);

  long_buff = (IGRlong) char_buff;
  *(IGRlong *)buffer = long_buff;
  return (status);
}


IGRint EMdpb_get (EMmsg,parameter,buffer)
IGRlong *EMmsg;
IGRlong parameter;
IGRuchar *buffer;

/* ************************************************************************

Description
 This function when supplied with the dpb parameter interested in, get
 the value of the same in the buffer supplied. Note that the dpb 
 parameter that is returned is that of the current module
  
 
Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : if successful
  EMS_E_InvalidArg : if invalid arguments

History
       PP  :  10/19/87

 ************************************************************************** */ 

{
 IGRlong status;
 OM_S_OBJID dpbid;
 OMuword   dpbos;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = EMget_dpbobjid (EMmsg, &dpbid, &dpbos);
 if (!(1&status)) goto wrapup;

 status = om$send (msg = message EMSdpb.EMget_dpb_parameter (EMmsg,
                         parameter, (IGRchar *)buffer),
                   senderid = NULL_OBJID,
                   targetid = dpbid,
                   targetos = dpbos);
 if (!(1&status&*EMmsg)) goto wrapup;

 wrapup:
  return (status);
}

IGRint EMdpb_putinfo (EMmsg, dpbinfo)
 IGRlong *EMmsg;
 struct EMdpbinfo *dpbinfo;

/* **************************************************************************
 Description
  This function loads the dpb information in the structure into the
  instance data of the dpb object.
  The structure definition exists in the include file "EMSdpb.h"

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : if successful

History
 Creation : 06/27/88 : pp

  ************************************************************************** */
{
 IGRlong status;
 OM_S_OBJID dpbid;
 OMuword   dpbos;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = EMget_dpbobjid (EMmsg, &dpbid, &dpbos);
 if (!(1&status)) goto wrapup;

 status = om$send (msg = message EMSdpb.EMput_dpbinfo(EMmsg,
                         dpbinfo),
                   senderid = NULL_OBJID,
                   targetid = dpbid,
                   targetos = dpbos);
 if (!(1&status&*EMmsg)) goto wrapup;

 wrapup:
  return (status);
}



IGRint EMdpb_put_trans (EMmsg,parameter,buffer)
IGRlong *EMmsg;
IGRlong  parameter;
IGRlong *buffer;
/* **************************************************************************
Description
 This function when supplied with the dpb parameter interested in,
 will put the arguments in a format the SUNs can digest and then
 call the the real function that will put the EMS dippy block data.
 Fun huh?  Gotta love the sun.


Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : if successful
  EMS_E_InvalidArg : if invalid arguments


History
 Creation : 03/10/92 : scw

  ************************************************************************** */

{
  IGRlong          status;
  IGRlong          long_buff;
  IGRuchar char_buff;

  long_buff = *buffer;
  char_buff = (IGRchar) long_buff;

  status = EMdpb_put (EMmsg,parameter,&char_buff);

  long_buff = (IGRlong) char_buff;
  *(IGRlong *)buffer = long_buff;
  return (status);
}


IGRint EMdpb_put (EMmsg, parameter, buffer)
IGRlong *EMmsg;
IGRlong parameter;
IGRuchar *buffer;

/* ************************************************************************

Description
 This function when supplied with the dpb parameter interested in stores
 the value of the same. It reads the value from the buffer field.
 Note that the parameter is stored in the dpb object id belonging to the
 current module. 
 
Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : if successful
  EMS_E_InvalidArg : if invalid arguments

History
       PP  :  10/19/87

 ************************************************************************** */ 
{
 IGRlong	status;
 OM_S_OBJID     dpbid;
 OMuword        dpbos;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = EMget_dpbobjid (EMmsg, &dpbid, &dpbos);
 if (!(1&status)) goto wrapup;

 status = om$send (msg = message EMSdpb.EMput_dpb_parameter (EMmsg,
                         parameter, (IGRchar *)buffer),
                   senderid = NULL_OBJID,
                   targetid = dpbid,
                   targetos = dpbos);
 if (!(1&status&*EMmsg)) goto wrapup;

 EFupdate_form();

 wrapup:
  return (status);
}

IGRint EFupdate_form()
/* ********************************************************************

Description
 This function updates the form values if the form is displayed.
 It returns a value of TRUE if successful or FALSE if there is failure.

   ******************************************************************** */

{
#ifndef IDRAW
 IGRint displayed;
 IGRlong status;
 struct GRid dpbid;
 IGRlong EMmsg;

 status = EMget_dpbobjid (&EMmsg, &dpbid.objid, &dpbid.osnum);
 if (!(1&status)) return (FALSE);

 status = om$send (msg = message EMSdpb.is_displayed(&EMmsg, &displayed),
                  senderid = NULL_OBJID,
                     targetid = dpbid.objid,
                     targetos = dpbid.osnum);
   if (!(1&EMmsg&status)) return (FALSE);
 
 if (displayed)
 {
   status = om$send (msg = message EMSdpb.EMupdate_form(&EMmsg),
                     senderid = NULL_OBJID,
                     targetid = dpbid.objid,
                     targetos = dpbid.osnum);
   if (!(1&EMmsg&status)) return (FALSE);
 }
#endif   
 return(TRUE);
 }
end implementation EMSdpb;
