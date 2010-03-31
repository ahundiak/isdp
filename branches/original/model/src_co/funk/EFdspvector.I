/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function draws a vector on the screen with an arrowhead.
 This routine requires a point (from which to draw the vector),
 a vector (for direction), and a range box (from which to determine
 the length of the vector).

 History

 PP  : Unknown  : Creation
 SS  : 08/26/87 : Modified it to accept display_mode and also decide
                   that display length on it's own.
 rlw : 11/13/87 : Took this out of the EMshow_normals() surface method
                  and put it in a common function.
 rlw : 07/21/88 : Modified due to a changing the arrowhead function.
*/

class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "igrdef.h"		/* IGRPY, IGRPS */
#include "EMSmsgdef.h"		/* EMS_S_Success */
#include "emserr.h"

/*
 * The fraction of the length of the largest side of the
 * range box that will determine the length of the normal
 * to be drawn.
 */

#define LENGTH_FRACTION 0.25

void EFdraw_vector_on_screen(
 my_stupid_id,			/* Your id */
 active_display,		/* Active color, weight, etc. */
 display_env,			/* Active display enviroment */
 display_mode,			/* GRbd, GRbe, etc. */
 reverse_vector,		/* Should I reverse the vector? */
 point,				/* Origin of vector */
 vector,			/* Unit vector */
 range,				/* Range box to compute length from */
 msg)				/* Always returned as EMS_S_Success */

OM_S_OBJID	my_stupid_id;
struct		IGRdisplay *active_display;
struct		GRmd_env *display_env;
enum		GRdpmode display_mode;
IGRboolean	reverse_vector;
IGRpoint	point;
IGRvector	vector;
GRrange		range;
IGRlong		*msg;

{
 IGRlong	i;
 IGRdouble	length;
 IGRpoint	draw_vector[2];
/*
 * Initialize
 */
 *msg = EMS_S_Success;
/*
 * Compute the length of the vector based on the
 * incoming range
 */ 
 {
  IGRdouble	temp_length;
  length = range[3] - range[0];
  temp_length = range[4] - range[1];
  if (temp_length > length)
   length = temp_length;
  temp_length = range[5] - range[2];
  if (temp_length > length)
   length = temp_length;
  length *= LENGTH_FRACTION;
  if (reverse_vector)
   length *= -1.0;
 }
/*
 * Scale the vector by the computed length
 */
 for (i = 0 ; i < 3; i++)
  {
   draw_vector[0][i] = point[i];
   draw_vector[1][i] = point[i] + length * vector[i];
  }
/*
 * Display the vector
 */  
 {
  extern	void EMgetarrowheads();
  IGRlong	loc_msg, ECdisplayPointSetByBuffer0();
  IGRpoint	arrow_head[2][3];

  ECdisplayPointSetByBuffer0(
   &loc_msg,
   *active_display,
   *display_env, 
   my_stupid_id,
   1,
   draw_vector,
   display_mode,
   IGRPS);
  EMerr_hndlr (loc_msg == EMS_I_Interrupt || EMSerror (loc_msg), *msg, loc_msg,
   wrapup);

  ECdisplayPointSetByBuffer0(
   &loc_msg,
   *active_display, 
   *display_env, 
   my_stupid_id,
   2, 
   draw_vector,
   display_mode,
   IGRPY);
  EMerr_hndlr (loc_msg == EMS_I_Interrupt || EMSerror (loc_msg), *msg, loc_msg,
   wrapup);

  EMgetarrowheads(
    &loc_msg,
    draw_vector,
    arrow_head, 1.0);
   if (! (1 & loc_msg)) return;

  ECdisplayPointSetByBuffer0(
   &loc_msg,
   *active_display, 
   *display_env, 
   my_stupid_id,
   3, 
   &arrow_head[0][0][0],
   display_mode,
   IGRPY);
  EMerr_hndlr (loc_msg == EMS_I_Interrupt || EMSerror (loc_msg), *msg, loc_msg,
   wrapup);

  ECdisplayPointSetByBuffer0(
   &loc_msg,
   *active_display, 
   *display_env, 
   my_stupid_id,
   3, 
   &arrow_head[1][0][0],
   display_mode,
   IGRPY);
  EMerr_hndlr (loc_msg == EMS_I_Interrupt || EMSerror (loc_msg), *msg, loc_msg,
   wrapup);
 }
/*
 * eof
 */
wrapup:
  return;
}

end implementation Root;
