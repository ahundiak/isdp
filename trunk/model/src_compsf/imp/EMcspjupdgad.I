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
*     This method updates the subform gadgets for surface of projection 
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
*  This method turns off heading "Composite Surface of Revolution" and 
*  "swwep angle" gadget and turns on heading "Composite Surface of Projection".
*
* History:
*
*    msm	05/14/91    creation date.
*
******************************************************************************/


class implementation EMSprjcompsf;

#include "MDreveledef.h"

method GRupdate_gadgets( IGRlong *msg; IGRchar *form_ptr)
{

  IGRint 	num_components;
  IGRint 	status;
  OM_S_CHANSELECT to_comps;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  num_components = 0;

  status = om$send(msg = message GRowner.GRget_number_components
                    (msg, &num_components),
                targetid = my_id);
  EMomerr_hndlr ( status, wrapup, "GRget_number_components");

  if(num_components==1)
   {
    status = om$send(msg = OPPmargs, p_chanselect = &to_comps);
    EMomerr_hndlr ( status, wrapup, "GRcsupdate_gadgets");   
    goto wrapup;
   }
  else
    FIg_erase (form_ptr, COMPSFRV_SWEEP_ANGLE_GRP);

wrapup:
  return(1);
}
end implementation EMSprjcompsf;

