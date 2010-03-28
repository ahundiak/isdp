/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRsend_to_next_sibling

Description
   This function is used to send a message to the next element on
   a channel.  

   chan_osnum     GRspacenum     The osnum of the channel owner
   chan_objid     GRobjid        The objid of the channel owner
   osnum          GRspacenum     The osnum of an object on the channel
   objid          GRobjid        The objid of an object on the channel
   pass_msg       OM_p_MESSAGE   The message to be passed to the next
                                 object on the channel.

Return Values
   OM_S_SUCCESS   -  if successful

History
   Gray Winn   12/15/87       Creation Date
   scw         06/16/93       Initialized index variable
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"

IGRint GRsend_to_next_sibling (chan_osnum, chan_objid, osnum, objid,
                               pass_msg)
GRspacenum        chan_osnum;
GRobjid           chan_objid;
GRspacenum        osnum;
GRobjid           objid;
OM_p_MESSAGE      pass_msg;
{
IGRlong           om_msg;
OMuint            index;
GRobjid           go_objid;
GRspacenum        go_osnum;
OM_S_CHANSELECT   chansel;

   index = 0;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRconnector.to_owners";

   om_msg = om$get_index (
            osnum_c = chan_osnum, objid_c = chan_objid,
            p_chanselect = &chansel, objid = objid, osnum2 = osnum,
            indexaddr = &index);

   index++;
   om_msg = om$get_objid_at_index (
            osnum = chan_osnum, objid = chan_objid, 
            p_chanselect = &chansel, index = index, objidaddr = &go_objid,
            osnumaddr = &go_osnum);

   if ((om_msg == OM_E_INVINDEX) ||
       (om_msg == OM_E_NOSUCHOBJ) ||
       (om_msg == OM_W_INDEXEMPTY))
   {
      om_msg = OM_S_SUCCESS;
   }else
   {
      /*
       *  Pass message to the next sibling on the channel.
       */

      om_msg = om$send (
               msg = pass_msg, senderid = objid,
               targetid = go_objid, targetos = go_osnum);
   }
   return (om_msg);
}      
