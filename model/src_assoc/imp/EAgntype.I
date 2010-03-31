/* ###################   APOGEE COMPILED   ################## */
class implementation EMAgenbs;

#include "EMS.h"

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

method EMget_parent_type(IGRlong *EMmsg;
                         IGRint primitive_type;
                         IGRuint root_count;
                         IGRuint *root_type)

/* ************************************************************************
Description
 This function gets the root types which is used for getting information
 about the parents. Adequate memory needs to be allocated for root_type 
 enough to suffice the number of parents.

Arguments
 Input
  root_count : number of roots expected. Necessary.
  
 Output
  root_type : Memory allocated to suffice the number of parents.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there was an error in getting the root_structures.
 EMS_E_InvalidArg : If the number of roots expected does not match what
                    is returned.
                    Or if the construction code is invalid.
                    Or if root list is not supplied.

History
   09/29/88 : PP  : Creation
   04/4/91  : jhw : Added Box4pts and Tube.
 ************************************************************************* */

{
 IGRlong status;
 IGRint i;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
  
 switch (primitive_type)
 {
  case EMS_ASdirect_fit_surface:
  case EMS_ASdirect_fit_surface_by_curves:
  case EMS_ASnetwork_of_curves:
  case EMS_ASsurface_by_poles:
  case EMS_ASsurface_by_bound:
  case EMS_ASfitted_surface:
  case EMS_ASdefault_ruled_surface:
  case EMS_ASarclength_ruled_surface:
  case EMS_ASdevelopable_ruled_surface:
  case EMS_ASblend_exterior: 
  {
   IGRint i;

   for (i=0;i<root_count;i++)
    root_type[i] = EMSlcinfo;
  }
  break;

  case EMS_ASskinning_surface:
  {
   IGRint i;

   for (i=0;i<root_count;i++)
    root_type[i] = EMSgrid;
  }
  break;

  case EMS_ASbox_by_4pts:
      root_type[BASE] = EMSpoint;
      root_type[WIDTH] = root_type[HEIGHT] = root_type[LENGTH] = EMSdistance;
      root_type[WIDTH_VEC] = root_type[HEIGHT_VEC] = root_type[LENGTH_VEC] = EMSvector;
      break;

  case EMS_AStube_by_linear_and_radii:
      root_type[0] = EMSgrid;
      for (i=1; i<root_count; ++i) root_type[i] = EMSdistance;
      break;

  default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

wrapup:
 EMWRAPUP (status, *EMmsg, "In EMAgenbs:EMget_parent_type error"); 
 return (status);
}
end implementation EMAgenbs;

