/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method constructs a helix curve.

 RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 NOTES

 This object will delete itself if an error occurs.

 HISTORY

 11/21/87 : rlw : Creation date.
 03/03/88 : rlw : Modified due to argument changes in the math.  The
                  delta radius was changed to the ending radius.  I had
                  fixed this eariler but apparently forgot to check it in.
 08/29/88 : rlw : Renamed the helix method due to additional argument in order
                  to support placement of left hand threads.
 Sudha  06/16/93     Modified for BSprototype ansification

 */

class implementation GRsubbc;

#include "EMS.h"		/* Shared library stuff */

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"			/* Includes the world */
#include "bshelix1.h"
#include "bsfreecv.h"

method EMplace_helix_curve(
 IGRpoint		axis_point_1;
 IGRpoint		axis_point_2;
 IGRpoint		starting_point;
 IGRdouble		starting_radius;
 IGRdouble		ending_radius;
 IGRdouble		pitch_gap;
 IGRlong		number_of_pitches;
 IGRboolean		right_hand_thread;
 struct GRvg_construct	*construct_list)
{
 IGRlong	*msg, sts;
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 curve = NULL;
/*
 * Call the math
 */
 {
  IGRboolean		is_tapered;
  IGRlong		loc_msg;

  is_tapered = (starting_radius != ending_radius);
  BShelix1(
    axis_point_1,
    axis_point_2,
    starting_point,
    starting_radius,
    pitch_gap,
    1,					/* Stop after number of pitches */
    number_of_pitches,
    right_hand_thread,
    is_tapered,
    ending_radius,
    &curve,
    &loc_msg);  
   if (loc_msg != BSSUCC)
    {
     curve = NULL;
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Fill the instance data and such
 */
 construct_list->geometry = (IGRchar *) curve;
 sts = om$send(
   msg = message GRgraphics.GRconstruct(construct_list),
   targetid = my_id);
  if (!(1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (curve) 
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreecv(
    &loc_msg,
    curve);
  }
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
}

end implementation GRsubbc;

