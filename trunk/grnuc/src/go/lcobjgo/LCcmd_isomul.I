/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   The following functions are called by macros.

History
   Gray Winn    08/27/87   Creation date.
   msm          07/09/92   ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "lcmacros.h"

from GRconnector import GRflexconn;

/*\
Name
   lc$multiple_connect

Description
   THIS ROUTINE SHOULD NOT BE USED BY COMMAND OBJECTS.  This routine
   provides the ability to connect several objects to one intermediate
   object.  This can be used in conjunction with the lc$wild_disconnect,
   lc$get_channel_count, lc$get_channel_objects, and lc$is_objid_on_channel
   macros.  This is not intended to work with the other macros.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   index                IGRint            The command's index 
   go_objid             OM_S_OBJID        The objid of the graphics object
   go_osnum             GRspacenum        The osnum of the graphics object
   go_index             IGRint            The index of the graphics object
   preset               IGRint            If none zero, preset the channel

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
#argsused
int LCmultiple_connect (osnum, objid, p_chanselect, index, go_objid,
                        go_osnum, go_index, preset)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
IGRint            index;
OM_S_OBJID        go_objid;
GRspacenum        go_osnum;
IGRint            go_index;
IGRint            preset;
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRlong              connect_flag;
/*IGRint               index;    */        /* apogee compiler    ..MOHAN */
unsigned int         count;
OM_S_OBJECT_LINKAGE  lc_list;
OM_S_CHANSELECT      chansel;
struct GRid          lc_objid;

   connect_flag = 1; /* Override */
   index = OM_K_MAXINT;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the channel count
    */

   om_msg = om$get_channel_count (osnum = osnum, objid = objid, 
            p_chanselect = p_chanselect, count = &count);

   if ((om_msg & 1) && (!count))
   {
      om_msg = lc$connect (osnum = osnum,
                           objid = objid,
                           p_chanselect = p_chanselect,
                           index = index,
                           go_objid = go_objid,
                           go_osnum = go_osnum);

      if (preset)
      {
         /*
          *  Get the LCcmd_iso object.
          */

         om_msg = om$get_channel_objects (osnum = osnum, objid = objid, 
                  p_chanselect = p_chanselect, list = &lc_list, size = 1,
                  count = &count);

         /*
          *  Preset its channel.
          */

         om_msg = om$channel_preset (osnum = lc_list.osnum,
                  objid = lc_list.S_objid, p_chanselect = &chansel, 
                  size = preset);
      }
   }else
   {
      om_msg = om$get_channel_objects (osnum = osnum, objid = objid, 
               p_chanselect = p_chanselect, list = &lc_list, size = 1,
               count = &count);
      
      /*
       *  Connect the intermediate object to the graphics object.
       */

      lc_objid.objid = lc_list.S_objid;
      lc_objid.osnum = lc_list.osnum;
      om_msg = om$send(
               msg = message GRconnector.GRflexconn (&ret_msg, 
               &connect_flag, &lc_objid, (IGRlong *) &index, 
               (IGRlong *) &index), 
               senderid = NULL_OBJID,
               targetid = go_objid, targetos = go_osnum);
   }
   return (om_msg);
}
end implementation Root;
