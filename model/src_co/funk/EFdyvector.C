/* ###################   APOGEE COMPILED   ################## */
/*

DESCRIPTION

	This function does dynamics between a static from_point and a
	dynamic to_point, along a given vector. 
        
NOTES

	On exit, the dynamic to_point (pnt2) is the constrained point
	and not the actual cursor position.


RETURN VALUES
        This function always returns TRUE.

HISTORY

	12/31/87	RV	Creation
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


static struct info { struct DPele_header header; IGRdouble *normal; };


IGRint EFdyvector(vec, pt1, pt2, display )
 IGRdouble             *vec;
 IGRpoint              pt1, pt2;
 struct IGRdisplay     *display;

{
 struct       info	    info_buffer;
 struct       IGRpolyline   polyline;
 IGRpoint                   pt_buffer[2];

 IGRint EFdymodvec();

  pt_buffer[0][0] = pt1[0];
  pt_buffer[0][1] = pt1[1];
  pt_buffer[0][2] = pt1[2];
  pt_buffer[1][0] = pt2[0];
  pt_buffer[1][1] = pt2[1];
  pt_buffer[1][2] = pt2[2];

  polyline.points = (IGRdouble *) pt_buffer;
  polyline.num_points = 2; 

  dp$build_dis_buffer(buffer = &info_buffer.header,
                      type = IGRPY,   
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline);

  info_buffer.normal = vec;

 /*  INVOKE DYNAMICS  */

  dp$dynamics( dyn_fun = EFdymodvec, information = &info_buffer);

  pt2[0] = info_buffer.header.geometry.polyline->points[3];
  pt2[1] = info_buffer.header.geometry.polyline->points[4];
  pt2[2] = info_buffer.header.geometry.polyline->points[5];

 return ( TRUE ); /**ALL DONE!!**/
}



IGRint EFdymodvec( info_buffer, cursor_pt, matrix, objects, num_objects,
                    buffer, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                    out_dummy1, out_dummy2, out_dummy3 )
 struct  info	       *info_buffer;
 struct  DPele_header  **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 IGRvector v2, v1;
 IGRpoint  from_pt;
 IGRdouble lensq, dotp, t;
 
 from_pt[0] = (info_buffer->header.geometry.polyline)->points[0];
 from_pt[1] = (info_buffer->header.geometry.polyline)->points[1];
 from_pt[2] = (info_buffer->header.geometry.polyline)->points[2];

 v2[0] = cursor_pt->x - from_pt[0];
 v2[1] = cursor_pt->y - from_pt[1];
 v2[2] = cursor_pt->z - from_pt[2];
 
 v1[0] = info_buffer->normal[0];
 v1[1] = info_buffer->normal[1];
 v1[2] = info_buffer->normal[2];

 lensq = v1[0]*v1[0] + v1[1]*v1[1] + v1[2]*v1[2];
 dotp = v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
 t = dotp/lensq;

 (info_buffer->header.geometry.polyline)->points[3] = from_pt[0] + t * v1[0];
 (info_buffer->header.geometry.polyline)->points[4] = from_pt[1] + t * v1[1];
 (info_buffer->header.geometry.polyline)->points[5] = from_pt[2] + t * v1[2];

 *buffer = &info_buffer->header;
 *num_buffers = 1;
 return( MSSUCC ); /**DO DYMANICS!!**/
}

