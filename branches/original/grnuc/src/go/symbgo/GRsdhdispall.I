/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdisplay_all_instances

Description
   This method sends a display method out its to_cpx channel.  Thus,
   displaying all instances of itself.

   *msg           IGRlong           return code 
   *mx_type       IGRshort          type of matrix 
   matrix         IGRmatrix         environment transformation matrix
   *mode          enum GRdpmode     the display mode 
   *display_id    struct GRid       The display object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   HGW    02/01/87 : Design Date and Creation Date
   scw    07/23/93 : ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include  "msdef.h"
#include  "OMerrordef.h"

method GRdisplay_all_instances (IGRlong *msg; IGRshort *matrix_type; 
                                IGRmatrix matrix; enum GRdpmode *mode;
                                struct GRid *display_id)
{
IGRlong           om_msg;
OMuint            count;
IGRint            i;
GRobjid           go_objid;
GRspacenum        go_osnum;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRconnector.to_owners";

   /*
    *  Send the display messages to all instances of the symbol
    *  definition.
    */

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel,
            count = &count);

   for (i=count-1; i >= 0 ; --i)
   {
      om_msg = om$get_objid_at_index (object=me, p_chanselect = &chansel,
               index = i, objidaddr = &go_objid, osnumaddr = &go_osnum);

      om_msg = GRis_symbol_replacable (go_osnum, go_objid, &chansel);

      if (om_msg & 1)
      {
         om_msg = om$send(
                  msg = message GRgraphics.GRdisplay (msg, matrix_type,
                  matrix, mode, display_id),
                  targetos = go_osnum, targetid = go_objid);
      }
   }
   return (OM_S_SUCCESS);
}

end implementation GRsmdfhdr;
