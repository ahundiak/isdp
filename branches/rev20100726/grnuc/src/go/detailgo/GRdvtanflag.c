/* 

Name:
  GRdv_tangent_edge_display
  
Notes:
  This function is used to communicate between a drawing view and
  the many edge display methods.  When a drawing view sends a display
  to it's elements, it will check if it's tangent edge display bit
  (GR_TAN_ED_DIS_OFF_CURRENT) is set.  If set, it will call this function
  and set the static variable.  Then when an edge gets the display,
  it will call this function and check if tangent edge display is on
  or off for the drawing view that sent the display.  When the display
  is complete, the drawing view will again call this function and reset
  the static variable.  Note: the default for tangent edge display is
  supressed.
  
History:
  Jack  06/19/92  Creation   

*/

#include "igrtypedef.h"

static IGRint dv_tan_ed_dis = 1;

void GRdv_tangent_edge_display(inquire_only,turn_on,result)

IGRint  inquire_only, /* do not change the static variable's value */
        turn_on,      /* set the static variable's value */
       *result;      /* value of the static variable at exit */

{

  if(inquire_only)
    *result = dv_tan_ed_dis;
  else
  {
    if(turn_on)
      *result = dv_tan_ed_dis = 1;
    else 
      *result = dv_tan_ed_dis = 0;      

    DPdlist_tangent_edge_display_notify( dv_tan_ed_dis );
  }

  return;
}

