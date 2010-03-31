/* ###################   APOGEE COMPILED   ################## */
/*
NAME
        EFdypt5_6f7v

SYNOPSIS
        EFdypt5_6f7v(~~~~~~)
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION

        
NOTES


RETURN VALUES
        This function always returns TRUE.

HISTORY
        DLB     03/13/86        Creation date.
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

extern EFdyrbpt5_6f7v();

struct pt5_struct
{
 struct DPele_header ele_header[3];
 IGRvector           h_vec, w_vec;
};


IGRint EFdypt5_6f7v( pt1, pt2, pt3, pt4, display )
 IGRpoint            pt1, pt2, pt3, pt4;
 struct IGRdisplay   *display;

{
 struct       pt5_struct    header;
 struct       IGRpolyline   polyline[3];
 IGRpoint                   pt_buffer[10];
 IGRint                     size_pnt = sizeof(IGRpoint), i;

 /**CALCULATE THE HEIGHT AND WIDTH VECTORS**/
 for (i=0; i<3; i++)
 {
  header.h_vec[i] = pt3[i] - pt2[i];
  header.w_vec[i] = pt2[i] - pt1[i];
 }

 /**MOVE THE INPUT POINTS TO THE POLYLINE POINT BUFFER**/
  OM_BLOCK_MOVE(pt1,pt_buffer,size_pnt);   
  OM_BLOCK_MOVE(pt2,&pt_buffer[6][0],size_pnt);    
  OM_BLOCK_MOVE(pt3,&pt_buffer[9][0],size_pnt);
  OM_BLOCK_MOVE(pt4,&pt_buffer[2][0],size_pnt);

 /**INITIALIZE THE POLYLINES**/
  polyline[0].num_points = 3;           
  polyline[0].points = (IGRdouble *) pt_buffer;
  polyline[1].num_points = 3;
  polyline[1].points = &pt_buffer[3][0];
  polyline[2].num_points = 4;
  polyline[2].points = &pt_buffer[6][0];

 for (i=0; i<3; i++)
 { 
  /**FILL IN HEADER INFORMATION**/
  dp$build_dis_buffer(                 
                      buffer = &header.ele_header[i],
                      type = IGRPY,      /**TYPE IS POLYLINE**/
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline[i]);

 }

 /*  INVOKE DYNAMICS  */
 dp$dynamics( dyn_fun = EFdyrbpt5_6f7v, information = &header );

 return ( TRUE ); /**ALL DONE!!**/
}


/*
NAME    EFdyrbpt5_6f7v -->  function called by dp$dynamics to put new
                            stuff in
DESCRIPTION

RETURN VALUES
        Since information is only being moved around, these functions
        will always return TRUE.
HISTORY
        DLB 03/13/86        Creation date.
*/

IGRint EFdyrbpt5_6f7v( header, cursor_pt, matrix, objects, num_objects,
                       buffer, num_buffers, in_dummy1, in_dummy2, 
                       in_dummy3, out_dummy1, out_dummy2, out_dummy3 )
 struct  pt5_struct    *header;
 struct  DPele_header  **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 struct IGRpolyline *ptr;

 /**FIRST POLYLINE**/
 ptr = header->ele_header[0].geometry.polyline;
 ptr->points[3] = cursor_pt->x;
 ptr->points[4] = cursor_pt->y;
 ptr->points[5] = cursor_pt->z;


 /**SECOND POLYLINE**/
 ptr = header->ele_header[1].geometry.polyline;
 ptr->points[0] = cursor_pt->x + header->w_vec[0];
 ptr->points[1] = cursor_pt->y + header->w_vec[1];
 ptr->points[2] = cursor_pt->z + header->w_vec[2];

 OM_BLOCK_MOVE(&header->ele_header[0].geometry.polyline->points[3], 
               &header->ele_header[1].geometry.polyline->points[3], 
               sizeof(IGRpoint));

 ptr->points[6] = cursor_pt->x + header->w_vec[0] + header->h_vec[0];
 ptr->points[7] = cursor_pt->y + header->w_vec[1] + header->h_vec[1];
 ptr->points[8] = cursor_pt->z + header->w_vec[2] + header->h_vec[2];


 /**THIRD POLYLINE**/
 OM_BLOCK_MOVE(&header->ele_header[1].geometry.polyline->points[0], 
               &header->ele_header[2].geometry.polyline->points[3], 
               sizeof(IGRpoint));

 OM_BLOCK_MOVE(&header->ele_header[1].geometry.polyline->points[6], 
               &header->ele_header[2].geometry.polyline->points[6], 
               sizeof(IGRpoint));


 *buffer = header->ele_header;
 *num_buffers = 3;
 return( MSSUCC ); /**DO DYMANICS!!**/
}
