/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for ellipse and elliptical arc are combined in 
*    GREllArcGeom form. 
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for ellipse geometry.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns on perimeter and area gadgets and turns off
*  swwep angle, arc length, end point 1 and end point 2 gadgets.
*
* History:
*
*    msm	04/30/91    creation date.
*
******************************************************************************/


class implementation GRellipse;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{
  *msg = MSSUCC;

  FIg_erase (form_ptr, ELL_ARC_SYM_SWEEP_ANGLE);
  FIg_display (form_ptr, ELL_ARC_SYM_PERIMETER);
  FIg_erase (form_ptr, ELL_ARC_SYM_ARC_LENGTH);
  FIg_display (form_ptr, ELL_ARC_SYM_AREA);
  FIg_erase (form_ptr, ELL_ARC_SYM_END_PT_1);
  FIg_erase (form_ptr, ELL_ARC_SYM_END_PT_2);
  return(1);
}
end implementation GRellipse;

