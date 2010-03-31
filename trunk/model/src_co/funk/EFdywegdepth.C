/* ###################   APOGEE COMPILED   ################## */
/*
NAME
        EFdywegdepth - Dynamically place depth area of right angle wedge

SYNOPSIS
        EFdywegdepth(corner_pt, width_pt, height_pt, display)
        IGRpoint corner_pt,           has the corner point of the wedge
                 width_pt,            has the width point of the wedge
                 height_pt;           has the height point of the wedge
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
        This function takes as input the 3 points defining a face
        of a wedge and sets up the DPele_header buffers to dynamically
        draw the depth face and connecting edge points. Each polyline
        will from all of a face except the face already defined and 1 
        other edge. That edge will be filled by the next buffer 
        (i.e. the polylines will wrap around the sides of the wedge).
        
NOTES
        None.

RETURN VALUES
        This function always returns TRUE.

HISTORY
        DLB     12/14/86        Creation date.
        Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "msdef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "dpstruct.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "igrdef.h"
# include "dpmacros.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

extern EFdyrbwegdepth();

struct depth_struct
{
 struct DPele_header ele_header[3];
 IGRvector           nor_vec;
};
       
IGRint EFdywegdepth( corner_pt, width_pt, height_pt, display )
 IGRpoint              corner_pt, width_pt, height_pt;
 struct IGRdisplay     *display;

{
 struct       depth_struct  header;
 struct       IGRpolyline   polyline[3];
 IGRpoint                   pt_buffer[9];
 IGRvector                  w_vec, h_vec;
 IGRint                     size_pnt = sizeof(IGRpoint), i;
 IGRboolean                 status;
 BSrc			    rc;

 /**GET WIDTH, HEIGHT VECTORS AND MAKE THE FOURTH CORNER POINT**/
 for (i=0; i<3; i++)
 {
  w_vec[i] = width_pt[i] - corner_pt[i];
  h_vec[i] = height_pt[i] - corner_pt[i];
 }

 /**MOVE THE REST OF THE POINTS TO THE POLYLINE POINT BUFFER**/
 OM_BLOCK_MOVE(corner_pt, pt_buffer, size_pnt);   
 OM_BLOCK_MOVE(width_pt, &pt_buffer[3][0], size_pnt);
 OM_BLOCK_MOVE(height_pt, &pt_buffer[6][0], size_pnt);

 /**GET THE NORMAL VECTOR TO THE PLANE**/
 status = BScrossp(&rc, w_vec, h_vec, header.nor_vec);
 if (!status) return (TRUE);

 /**NORMALIZE IT**/
 status = BSnorvec(&rc, header.nor_vec);
 if (!status) return (TRUE);
 
 for (i=0; i<3; i++)
 {
  /**INITIALIZE THE POLYLINE**/
  polyline[i].num_points = 3;
  polyline[i].points = &pt_buffer[3*i][0];
 
  /**FILL IN HEADER INFORMATION**/
  dp$build_dis_buffer(        
                      buffer = &header.ele_header[i],
                      type = IGRPY,                /**TYPE IS POLYLINE**/
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline[i]);
 }

 /*  INVOKE DYNAMICS  */
 dp$dynamics( dyn_fun = EFdyrbwegdepth, information = &header );
 return ( TRUE ); /**ALL DONE!!**/
}


/*
NAME    EFdyrbwegdepth
        
SYNOPSIS
        EFdyrbwegdepth(header, cursor_pt, matrix, objects, num_objects, 
                     buffer, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     out_dummy1, out_dummy2, out_dummy3);

INPUT:

NAME               DATA TYPE          DESCRIPTION
----------------   -----------        ------------------------------------
*header            IGRchar            information passed to DPdynamics
*cursor_pt         struct EX_button   current cursor position
*matrix            IGRdouble          a 4 X 4 homogeneous matrix that
                                      translates world to screen 
                                      coordinates
**in_dummy1         IGRchar            (Not used)
**in_dummy2         IGRchar            (Not used)
**in_dummy3         IGRchar            (Not used)

OUTPUT:

NAME            DATA TYPE            DESCRIPTION
------------    -------------------  ------------------------------------
**objects       struct GRid          objects in dynamics
*num_objects    IGRint               number of objects in dynamics
**buffer        struct DPele_header  buffered elements in dynamics
*num_buffers    IGRint               nbr. of buffered elements in dynamics
**out_dummy1    IGRchar              (Not used)
**out_dummy2    IGRchar              (Not used)
**out_dummy3    IGRchar              (Not used)

DESCRIPTION
        This routine is called by dp$dynamics after it has sensed
        a cursor change. The new cursor position is passed to this
        function. The function will calculate the vector normal to 
        infinite plane defined by the corner point and normal vector. 
        Once the vector has been determined, it is added to the 3 corner
        points the have already been defined to get all 6 points of the
        wedge. These points are then moved to the proper postions in the
        DPele_header buffers. The function then returns to dp$dynamics 
        where the buffers are displayed. That function then checkes 
        the cursor again and the cycle is repeated.

RETURN VALUES
        Since only simple calculations are being done and information 
        is being moved around, this function will always return MSSUCC.

HISTORY
        DLB 12/14/86        Creation date.
*/


IGRint EFdyrbwegdepth( header, cursor_pt, matrix, objects, num_objects,
                     buffer, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     out_dummy1, out_dummy2, out_dummy3 )
 struct  depth_struct  *header;
 struct  DPele_header  **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 IGRdouble  dot;
 IGRvector  d_vec;
 IGRint  size_pnt = sizeof(IGRpoint);

 dot = (header->ele_header[0].geometry.polyline->points[0] - 
        cursor_pt->x) * header->nor_vec[0];
 dot += (header->ele_header[0].geometry.polyline->points[1] - 
         cursor_pt->y) * header->nor_vec[1];
 dot += (header->ele_header[0].geometry.polyline->points[2] - 
         cursor_pt->z) * header->nor_vec[2];
 d_vec[0] = cursor_pt->x - (cursor_pt->x + dot * header->nor_vec[0]);
 d_vec[1] = cursor_pt->y - (cursor_pt->y + dot * header->nor_vec[1]);
 d_vec[2] = cursor_pt->z - (cursor_pt->z + dot * header->nor_vec[2]);

 header->ele_header[0].geometry.polyline->points[3] = 
         header->ele_header[0].geometry.polyline->points[0] + d_vec[0];
 header->ele_header[0].geometry.polyline->points[4] = 
         header->ele_header[0].geometry.polyline->points[1] + d_vec[1];
 header->ele_header[0].geometry.polyline->points[5] = 
         header->ele_header[0].geometry.polyline->points[2] + d_vec[2];

 header->ele_header[0].geometry.polyline->points[6] = 
         header->ele_header[1].geometry.polyline->points[0] + d_vec[0];
 header->ele_header[0].geometry.polyline->points[7] = 
         header->ele_header[1].geometry.polyline->points[1] + d_vec[1];
 header->ele_header[0].geometry.polyline->points[8] = 
         header->ele_header[1].geometry.polyline->points[2] + d_vec[2];

 header->ele_header[1].geometry.polyline->points[6] = 
         header->ele_header[2].geometry.polyline->points[0] + d_vec[0];
 header->ele_header[1].geometry.polyline->points[7] = 
         header->ele_header[2].geometry.polyline->points[1] + d_vec[1];
 header->ele_header[1].geometry.polyline->points[8] = 
         header->ele_header[2].geometry.polyline->points[2] + d_vec[2];

 OM_BLOCK_MOVE(&header->ele_header[0].geometry.polyline->points[6], 
               &header->ele_header[1].geometry.polyline->points[3], 
               size_pnt);

 OM_BLOCK_MOVE(&header->ele_header[1].geometry.polyline->points[6],
               &header->ele_header[2].geometry.polyline->points[3],
               size_pnt);

 OM_BLOCK_MOVE(&header->ele_header[0].geometry.polyline->points[3],
               &header->ele_header[2].geometry.polyline->points[6],
               size_pnt);
 *buffer = header->ele_header;
 *num_buffers = 3;
 return( MSSUCC ); /**DO DYMANICS!!**/
}



