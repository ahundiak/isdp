/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdisyourself 

Description
   This method sets up display for the components of a saveset object.

   *msg         IGRlong        completion code:
   *mx_type     IGRshort       type of matrix 
   matrix       IGRmatrix      environment transformation matrix
   *mode        GRdpmode       the display mode 
   *alt_symb    struct IGRaltdisplay 
   *sp_info     struct DP_information
   range_key    OM_p_KEY_DESC  range of the grahic object

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/19/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include  "msdef.h"

method GRdisyourself (IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                      enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                      struct DP_information *sp_info;
                      OM_p_KEY_DESC range_key)
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &count);

   if ((om_msg & 1) && count)
   {
      om_msg = om$send(
               msg = message GRgraphics.GRdisyourself ( msg, mx_type,
               matrix, mode, alt_symb, sp_info, range_key),
               p_chanselect = &chansel);
   }
   return(om_msg);
}
end implementation GRsvset;
