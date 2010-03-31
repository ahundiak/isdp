/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element
*    command if two or more commands are combined in one form. In this case 
*    review element for solid cone and solid torus are combined in MDtoruscone
*    form.
*    
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method updates the subform gadgets for cone and torus.
*
*
* Method: GRupdate_gadgets
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method turns off heading "Torus", "Major" and "Minor" redii, "Base" and
*  and "Normal" point positions and turns on the heading "Cone", "Top" and 
*  "Bottom" redii, "Center" and "Height" point positions.
*
* History:
*
*    msm	05/21/91    creation date.
*
******************************************************************************/


class implementation EMScone;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  FIg_erase (form_ptr, TORUS_HEADING_RADII_POINT_GRP);
  FIg_display (form_ptr, CONE_HEADING_RADII_POINT_GRP);
  return(1);
}
end implementation EMScone;

