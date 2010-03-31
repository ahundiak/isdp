/* ###################   APOGEE COMPILED   ################## */
/*
NAME
	EFdynormal - Dynamics for orthogonal lines

SYNOPSIS
        EFdynormal(pt0, pt1, display)
        IGRpoint pt0;                point 1 of base
        IGRpoint pt1;                point 2 of base
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
	This function rubberbands off of the second point
	such that the generated line is normal to the input line.
        
NOTES
	none

RETURN VALUES
        This function always returns TRUE.

HISTORY
	rlw	10/21/87	Butchered a Dave Brann function
*/

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

extern IGRlong EFdynorm();

IGRint EFdynormal(
 point_0,
 point_1,
 display)

IGRpoint	point_0, point_1;
struct		IGRdisplay *display;
{
 struct		DPele_header header;
 struct		IGRpolyline polyline;
 IGRpoint	points[3];
/*
 * Initialize
 */
 points[0][0] = point_0[0];
 points[0][1] = point_0[1];
 points[0][2] = point_0[2];
 points[1][0] = point_1[0];
 points[1][1] = point_1[1];
 points[1][2] = point_1[2];
 polyline.num_points = 2;
 polyline.points = &points[1][0];
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
  dyn_fun = EFdynorm,
  information = &header);
/*
 * eof
 */
 return (TRUE);
}

static IGRlong EFdynorm(
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
 IGRlong	sts, EFmkperp2vec();
 IGRvector	width_vector, height_vector;
 IGRpoint	*points;

 points = (IGRpoint *) header->geometry.polyline->points;
 points--;				/* Clever eh? */
 points[2][0] = cursor_pt->x;
 points[2][1] = cursor_pt->y;
 points[2][2] = cursor_pt->z;
 sts = EFmkperp2vec(
   points[1],
   points[0],
   points[2],
   width_vector,
   height_vector);
 *buffer = header;
 if (! (1 & sts))
  *num_buffers = 0;
 else
  *num_buffers = 1;
 return(MSSUCC);
}
