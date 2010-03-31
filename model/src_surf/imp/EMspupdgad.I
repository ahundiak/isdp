/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for cylinder and sphere are combined in MDcylndrsphr.
*    form.
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for cylinder and sphere.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns on height.
*
* History:
*
*    msm	05/24/91    creation date.
*
******************************************************************************/


class implementation EMSsphere;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  FIg_erase (form_ptr, CYLINDR_GEOM_SF_HEIGHT);
  return(1);
}
end implementation EMSsphere;

