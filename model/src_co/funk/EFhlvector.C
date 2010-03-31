/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION
	This function does dynamics between a static from_point and a
	dynamic to_point based on the cursor position. The to point is at
	a constant distance.
NOTES
	On exit, the dynamic to_point (pnt2) is the constrained point
	and not the actual cursor position.
RETURN VALUES
        This function always returns TRUE.
HISTORY
	07/27/92 Tapadia	Genesis	
	05/26/93 sampath	Added code to display a list of objects
				in hilite mode.
        Sudha   06/02/93        modified to include for BSprototype headers
	09/10/93 sampath	Fixed problem with flipping the direction of
				arrow.
        02/14/94 sanjay         Modified the code to check input variables
                                before populating them [TR# 119417121].
*/

# include "EMS.h"
# include "EMSmsgdef.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "msdef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dpstruct.h"
# include "dp.h"
# include "dpdef.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "igrdef.h"
# include "dpmacros.h"
#include "bserr.h"
#include "bsproj0.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

static struct info
{	struct DPele_header header;
	IGRdouble *normal;
	IGRint    num_elems;
	struct GRid *elems;
};


IGRint Hole_EFdyvector(vec, pt1, to_pt, display,num_elems,elems)
 IGRdouble             *vec;
 IGRpoint              pt1, to_pt;
 struct IGRdisplay     *display;
 IGRint                num_elems;
 struct GRid           *elems;
{
 struct       info	    info_buffer;
 struct       IGRpolyline   polyline;
 IGRpoint     pt_buffer[5];
 IGRint       i, Hole_EFdymodvec();

  info_buffer.num_elems = num_elems;
  info_buffer.elems = elems;

  pt_buffer[0][0] = pt1[0];
  pt_buffer[0][1] = pt1[1];
  pt_buffer[0][2] = pt1[2];

  for(i = 1; i < 5; i++) {
  	pt_buffer[i][0] = to_pt[0];
  	pt_buffer[i][1] = to_pt[1];
  	pt_buffer[i][2] = to_pt[2];
  }

  polyline.points = (IGRdouble *)pt_buffer;
  polyline.num_points = 5; 

  dp$build_dis_buffer(buffer = &info_buffer.header,
                      type = IGRPY,   
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline);

  info_buffer.normal = vec;

 /*  INVOKE DYNAMICS  */

  dp$dynamics( dyn_fun = Hole_EFdymodvec, information = &info_buffer);

  vec = info_buffer.normal;

 return ( TRUE ); /**ALL DONE!!**/
}

#argsused

IGRint Hole_EFdymodvec( info_buffer, cursor_pt, matrix, objects, num_objects,
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
 IGRvector 	v1, new_vec,v2,p_normal;
 IGRlong 	msg_loc = EMS_S_Success;
 IGRpoint  	from_pt, min, new_pt,new_pt1,point2,point3;
 IGRint 	i;
 IGRdouble 	dotp, dia_dist;
 IGRpoint 	draw_vector[2];
 IGRpoint 	arrow_head[2][3];
 IGRdouble 	proj_line[2][3], point[3];
 IGRpoint 	arr_pt0, arr_pt1, arr_pt2;
 IGRlong 	ret_bytes1, stat_OM, which_error;
 IGRmatrix 	matrix1;
 struct var_list params[2];
 extern void hole_EMgetarrowheads();
 extern void EMgetarrowheads();

 from_pt[0] = (info_buffer->header.geometry.polyline)->points[0];
 from_pt[1] = (info_buffer->header.geometry.polyline)->points[1];
 from_pt[2] = (info_buffer->header.geometry.polyline)->points[2];
 min[0] = (info_buffer->header.geometry.polyline)->points[3];
 min[1] = (info_buffer->header.geometry.polyline)->points[4];
 min[2] = (info_buffer->header.geometry.polyline)->points[5];
 v1[0] = info_buffer->normal[0];
 v1[1] = info_buffer->normal[1];
 v1[2] = info_buffer->normal[2];

 OM_BLOCK_MOVE(from_pt, proj_line[0], sizeof(IGRpoint));
 dia_dist = BSdistptpt(&msg_loc, from_pt, min);

 proj_line[1][0] = from_pt[0] + v1[0];
 proj_line[1][1] = from_pt[1] + v1[1];
 proj_line[1][2] = from_pt[2] + v1[2];


 /* Project the cursor onto the view plane at the from_pt
    along the view direction. */

 point[0] = cursor_pt->x;
 point[1] = cursor_pt->y;
 point[2] = cursor_pt->z;

 params[0].var               = VW_ROT_NO_CON;
 params[0].var_ptr           = (IGRchar *)matrix1;
 params[0].num_bytes         = sizeof(IGRdouble) * 16;
 params[0].bytes_returned    = &ret_bytes1;

 params[1].var               = END_PARAM;

 stat_OM = dp$inq_set_gragad(msg = &msg_loc,
                            inq0_set1 = 0,
                            osnum = cursor_pt->osnum,
                            gragad_objid = cursor_pt->objid,
                            which_error = &which_error,
                            var_list = params);

 if (! (stat_OM & msg_loc & 1)) goto ret_end;
 for( i = 0; i < 3; i++)
 {
   p_normal[i] = matrix1[8+i];
   point2[i] = point[i] + matrix1[8+i] * dia_dist;
 }

 BSxlnpl(&msg_loc,p_normal,from_pt,point,point2,new_pt);

/* Project the second point of arrow onto the view plane at the from_pt
   along the view direction. */

 for( i = 0; i < 3; i++)
   point2[i] = from_pt[i] + dia_dist * v1[i];
 for( i = 0; i < 3; i++)
   point3[i] = point2[i] + dia_dist * p_normal[i];

 BSxlnpl(&msg_loc,p_normal,from_pt,point2,point3,new_pt1);

 v2[0] = new_pt1[0] - from_pt[0];
 v2[1] = new_pt1[1] - from_pt[1];
 v2[2] = new_pt1[2] - from_pt[2];

 new_vec[0] = new_pt[0] - from_pt[0];
 new_vec[1] = new_pt[1] - from_pt[1];
 new_vec[2] = new_pt[2] - from_pt[2];

 BSnorvec(&msg_loc, new_vec);

 dotp = v2[0]*new_vec[0] + v2[1]*new_vec[1] + v2[2]*new_vec[2];

 /* change the direction */
 if(dotp < 0) {	
	v1[0] *= -1.0; 
	v1[1] *= -1.0; 
	v1[2] *= -1.0; 
 }

 for(i = 0; i < 3; i++) {
	draw_vector[0][i] = from_pt[i]; 
	draw_vector[1][i] = from_pt[i] + dia_dist * v1[i]; 
 }

 EMgetarrowheads(&msg_loc, draw_vector, arrow_head, 1.0);
 
 /* mid point of arrow */
 arr_pt0[0] = arrow_head[0][1][0];
 arr_pt0[1] = arrow_head[0][1][1];
 arr_pt0[2] = arrow_head[0][1][2];
 /* one end of arrow */
 arr_pt1[0] = arrow_head[0][0][0];
 arr_pt1[1] = arrow_head[0][0][1];
 arr_pt1[2] = arrow_head[0][0][2];
 /* other end of arrow */
 arr_pt2[0] = arrow_head[0][2][0];
 arr_pt2[1] = arrow_head[0][2][1];
 arr_pt2[2] = arrow_head[0][2][2];

 (info_buffer->header.geometry.polyline)->points[3] = arr_pt0[0];
 (info_buffer->header.geometry.polyline)->points[4] = arr_pt0[1];
 (info_buffer->header.geometry.polyline)->points[5] = arr_pt0[2];

 (info_buffer->header.geometry.polyline)->points[6] = arr_pt1[0];
 (info_buffer->header.geometry.polyline)->points[7] = arr_pt1[1];
 (info_buffer->header.geometry.polyline)->points[8] = arr_pt1[2];

 (info_buffer->header.geometry.polyline)->points[9] = arr_pt0[0];
 (info_buffer->header.geometry.polyline)->points[10] = arr_pt0[1];
 (info_buffer->header.geometry.polyline)->points[11] = arr_pt0[2];

 (info_buffer->header.geometry.polyline)->points[12] = arr_pt2[0];
 (info_buffer->header.geometry.polyline)->points[13] = arr_pt2[1];
 (info_buffer->header.geometry.polyline)->points[14] = arr_pt2[2];

 for(i = 0; i < 3; i++) 
 	info_buffer->normal[i] = v1[i];
 if( buffer)
     *buffer = &info_buffer->header;
 if( num_objects )
     *num_objects = info_buffer->num_elems;
 if( objects )
     *objects = info_buffer->elems;
 if( num_buffers )
     *num_buffers = 1;

ret_end:

 return( MSSUCC ); /**DO DYMANICS!!**/
}
