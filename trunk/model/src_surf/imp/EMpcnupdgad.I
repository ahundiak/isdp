/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for partial cone and partial cylinder  are combined 
*    in MDpartconecyl form.
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for partial cone and
*     partial cylinder.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns on Height Radius gadget.
*
* History:
*
*    msm	05/29/91    creation date.
*
******************************************************************************/


class implementation EMSpcone;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  FIg_display (form_ptr, PARTLCONE_HEIGHT_RADIUS_GRP);
  return(1);
}
end implementation EMSpcone;

