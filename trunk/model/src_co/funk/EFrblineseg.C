/* ###################   APOGEE COMPILED   ################## */
/*
NAME
	EFrblineseg - Dynamics about a point

SYNOPSIS
        EFdybox2pt(pt0, display)
        IGRpoint pt0;                has the point
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
	This function rubberbands about a point.
        
NOTES
	This function was necessary since the nice IGE people
	removed the old DYrblineseg function from the image
	without telling us.

RETURN VALUES
        This function always returns TRUE.

HISTORY
	rlw	10/20/87	Butchered a Dave Brann function
        rlw     01/25/89        Modified to do last point stuff
*/

#include "EMS.h"

# include "EMS.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "msdef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dpstruct.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "igrdef.h"
# include "dpmacros.h"
# include "griodef.h"
# include "grio.h"
# include "griomacros.h"
# include "grdpbdef.h"
# include "grdpb.h"
# include "grdpbmacros.h"
# include "griomacros.h"

extern IGRlong EFdyrbline();

IGRint EFrblineseg(
 point,
 display)

IGRpoint	point;
struct		IGRdisplay *display;
{
 IGRpoint	points[2];
 struct		DPele_header header;
 struct		IGRpolyline polyline;
/*
 * If the point coming in is not established as the last point
 * then change the last point such that the user can do
 * relative keyins.
 */
 {
  IGRlong	msg, bytes_in, bytes_out;
  struct	EX_button button;

  bytes_in = sizeof(button);
  gr$get_last_point(
    msg = &msg,
    sizbuf = &bytes_in,
    buffer = &button,
    nret = &bytes_out);
   if (! (1 & msg)) goto wrapup;
  if ((button.x != point[0]) ||
      (button.y != point[1]) ||
      (button.z != point[2]))
   {
    button.x = point[0];
    button.y = point[1];
    button.z = point[2];
    gr$put_last_point(
      msg = &msg,
      sizbuf = &bytes_in,
      buffer = &button);
     if (! (1 & msg)) goto wrapup;
    co$update_current_point_form(msg = &msg);
     if (! (1 & msg)) goto wrapup;
   } /* if (coordinates are different) */
 }
/*
 * Initialize data for dynamics
 */
 points[0][0] = point[0];
 points[0][1] = point[1];
 points[0][2] = point[2];
 polyline.num_points = 2;
 polyline.points = &points[0][0];
/*
 * Build the display buffer
 */
 dp$build_dis_buffer(
  buffer = &header,
  type = IGRPY,
  display_att = display,
  geometry = &polyline);
/*
 * Invoke dynamics
 */
 dp$dynamics(
  dyn_fun = EFdyrbline,
  information = &header);
/*
 * eof
 */
wrapup:
 return (TRUE);
}

static IGRlong EFdyrbline(
 header,
 cursor_pt, 
 matrix, 
 objects, 
 num_objects,
 buffer, 
 num_buffers,
 in_dummy1,
 in_dummy2,
 in_dummy3,
 out_dummy1,
 out_dummy2,
 out_dummy3)

 struct  DPele_header  *header, **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 header->geometry.polyline->points[3] = cursor_pt->x;
 header->geometry.polyline->points[4] = cursor_pt->y;
 header->geometry.polyline->points[5] = cursor_pt->z;
 *buffer = header;
 *num_buffers = 1;
 return(MSSUCC);
}
