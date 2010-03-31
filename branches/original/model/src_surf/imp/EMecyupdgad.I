/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for elliptical cone and elliptical cylinder  are combined 
*    in MDellconecyl form.
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for elliptical cone and
*     elliptical cylinder.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns off scale factor and center and turns on base.
*
* History:
*
*    msm	05/28/91    creation date.
*
******************************************************************************/


class implementation EMSelpcyl;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  FIg_erase (form_ptr, ELLCONE_CNTR_SCALE_FACT_GRP);
  FIg_display (form_ptr, ELLCYLNDR_BASE_POINT);
  return(1);
}
end implementation EMSelpcyl;

