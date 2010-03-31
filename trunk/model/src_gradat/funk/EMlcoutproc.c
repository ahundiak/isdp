/*
  DESCRIPTION

    These function are used to go back and forth from the EMSlcout - properties
    field to IGRboolean variables that contain the T/F info
    explicitly. These functions should eventually disappear when all functions
    and methods having the IGRboolean variables on their argument-list
    change to instead accept the property-word itself.

  HISTORY

    SS  :  09/28/88  :  Creation
*/

#include "EMS.h"
#include "igrtypedef.h"
#include "EMSlcdef.h"

void EMlcout_to_props (props, inside, outside, overlap, located)
IGRushort *props;
IGRboolean inside, outside, overlap, located;
{
 register IGRushort loc_props;

 loc_props = *props;

 if (inside)
   loc_props |= EMSlcoutput_inside;
 else
   loc_props &= ~EMSlcoutput_inside;

 if (outside)
   loc_props |= EMSlcoutput_outside;
 else
   loc_props &= ~EMSlcoutput_outside;

 if (overlap)
   loc_props |= EMSlcoutput_overlap;
 else
   loc_props &= ~EMSlcoutput_overlap;

 if (located)
   loc_props |= EMSlcoutput_located;
 else
   loc_props &= ~EMSlcoutput_located;

 *props = loc_props;
 return;
}


void EMlcout_to_var (props, inside, outside, overlap, located)
register IGRushort props;
IGRboolean *inside, *outside, *overlap, *located;
{
  *inside = props & EMSlcoutput_inside;
  *outside = props & EMSlcoutput_outside;
  *overlap = props & EMSlcoutput_overlap;
  *located = props & EMSlcoutput_located;
  return;
}
