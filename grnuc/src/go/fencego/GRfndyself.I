/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdisyourself

Description
   This method sets up display for the fence object.

Arguments
   *msg         IGRlong          completion code:
   *mx_type     IGRshort         type of matrix 
   matrix       IGRmatrix        environment transformation matrix
   *mode        GRdpmode         the display mode 
   *alt_symb    struct IGRaltdisplay 
   *sp_info     struct DP_information
   range_key    OM_p_KEY_DESC    range of the grahic object

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

extern IGRboolean dynamics_in_progress;

method GRdisyourself (IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                      enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                      struct DP_information *sp_info;
                      OM_p_KEY_DESC range_key)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg  = OM_S_SUCCESS;

   /*
    *  Is the fence object displayable in this window?
    */

   if (me->fence_properties & GRFN_IS_DISPLAYABLE ||
       dynamics_in_progress)
   {
      /*
       *  Send display to fence.
       */

      om_msg = GRpass_on_to_fence (OM_Gw_current_OS, my_id, OPPmargs);
   }
   return (om_msg);
}
end implementation GRgsmgr;
