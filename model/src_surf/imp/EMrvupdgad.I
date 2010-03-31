/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for surface of projection and surface of revolution are 
*    combined in MDcompsfrvpr form. 
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for surface of revolution
*     geometry.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns on "swwep angle" and "start angle" gadgets.
*
* History:
*
*    msm	06/06/91    creation date.
*
******************************************************************************/


class implementation EMSrevol;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  FIg_erase (form_ptr, SURFPJ_GEOM_SF_GROUP);
  FIg_display (form_ptr, SURFRV_GEOM_SF_GROUP);
  return(1);
}
end implementation EMSrevol;

