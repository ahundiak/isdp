/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element 
*    command if two or more commands are combined in one form. In this case 
*    this method just passes on the message to the dominant surface.
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method returns success because gadgets need not be updated.
*
*
* Method: GRupdate_gadgets (IGRlong *msg; IGRchar *form_ptr)
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method returns success.
*
* History:
*
*    msm 	06/05/91    creation date.
*
******************************************************************************/
#include "msdef.h"

class implementation EMSsfsolid;

method GRupdate_gadgets ( IGRlong *msg; IGRchar *form_ptr)
{
IGRlong    status;
OM_S_CHANSELECT to_components;

  /*
   * Initalize variables.
   */

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  to_components.type = OM_e_addr;
  to_components.u_sel.addr = &me^^GRcmpowner.to_components;

   status = om$send (msg = OPPmargs,
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
   EMerr_hndlr(!(1&status&*msg), *msg, *msg, ret_end);


  ret_end:
    return (status);
}
end implementation EMSsfsolid;

