/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
NAME
	EFdy2normal - Dynamics for for a line which is
        orthogonal to the the two input lines.

SYNOPSIS
        EFdy2normal(is_begin, pt0, pt1, pt2, display)
        IGRboolean off_begin	Rubberband off of pt0 TRUE,
                                else use pt1 FALSE
        IGRpoint pt0;		Common origin
        IGRpoint pt1;		Line connects from this point to pt0
        IGRpoint pt2;		Line connects from this point to pt0
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
        Given that the line 0-1 is orthogonal to the line 1-2
        this function will rubberband off of pt0 or pt1 creating a
        line which is normal to the plane 0,1,2.
        
NOTES
	none

RETURN VALUES
        This function always returns TRUE.

HISTORY
	rlw	10/22/87	Butchered a Dave Brann function
*/

#include "OMminimum.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "OMlimits.h"
#include "ex.h"
#include "igrdef.h"
#include "dpmacros.h"
#include  "OMmacros.h"

extern IGRlong EFdynormm();

IGRint EFdy2normal(
 off_begin,
 point_0,
 point_1,
 point_2,
 display)

IGRboolean	off_begin;
IGRpoint	point_0, point_1, point_2;
struct		IGRdisplay *display;
{
 struct		DPele_header header;
 struct		IGRpolyline polyline;
 IGRpoint	points[5];
/*
 * Initialize
 */
 points[0][0] = point_0[0];
 points[0][1] = point_0[1];
 points[0][2] = point_0[2];
 points[1][0] = point_1[0];
 points[1][1] = point_1[1];
 points[1][2] = point_1[2];
 points[2][0] = point_2[0];
 points[2][1] = point_2[1];
 points[2][2] = point_2[2];
 if (off_begin)
  {
   points[3][0] = point_0[0];
   points[3][1] = point_0[1];
   points[3][2] = point_0[2];
  }
 else
  {
   points[3][0] = point_1[0];
   points[3][1] = point_1[1];
   points[3][2] = point_1[2];
  }
 polyline.num_points = 2;
 polyline.points = &points[3][0];
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
  dyn_fun = EFdynormm,
  information = &header);
/*
 * eof
 */
 return (TRUE);
}

static IGRlong EFdynormm(
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
 IGRlong	sts, EFmkperpvcpl();
 IGRvector	depth_vector;
 IGRpoint *points;

 points = (IGRpoint *) header->geometry.polyline->points;
 points -= 3;				/* Clever eh? */
 points[4][0] = cursor_pt->x;
 points[4][1] = cursor_pt->y;
 points[4][2] = cursor_pt->z;
 sts = EFmkperpvcpl(
   points,
   points[4],
   depth_vector);
 points[4][0] = points[3][0] + depth_vector[0];
 points[4][1] = points[3][1] + depth_vector[1];
 points[4][2] = points[3][2] + depth_vector[2];
 *buffer = header;
 if (! (1 & sts))
  *num_buffers = 0;
 else
  *num_buffers = 1;
 return(MSSUCC);
}
