/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for circle and circular arc are combined in GRCirArcGeom
*    form. 
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for circular arc  geometry.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns off circumference and area gadgets and turns on
*  swwep angle, arc length, end point 1 and end point 2 gadgets.
*
* History:
*
*    msm	04/30/91    creation date.
*
******************************************************************************/


class implementation GRcirarc;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{
  *msg = MSSUCC;

  FIg_erase (form_ptr, CIR_ARC_SYM_CIRCUMFERENCE);
  FIg_display (form_ptr, CIR_ARC_SYM_SWEEP_ANGLE);
  FIg_erase (form_ptr, CIR_ARC_SYM_AREA);
  FIg_display (form_ptr, CIR_ARC_SYM_ARC_LENGTH);
  FIg_display (form_ptr, CIR_ARC_SYM_END_PT_1);
  FIg_display (form_ptr, CIR_ARC_SYM_END_PT_2);
  return(1);
}
end implementation GRcirarc;

