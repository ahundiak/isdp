/* ###################   APOGEE COMPILED   ################## */
/*
NAME
        EFdyboxface - Dynamically place the face of a box by 2 points

SYNOPSIS
        EFdyboxface(corner_pt, width_pt, display)
        IGRpoint corner_pt,               has the corner point of the box
                 width_pt;                has the width point of the box
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
        This function takes the corner and width points of a box
        and sets up a DPele_header buffer to dynamically draw the
        face of a rectangular box by 4 points. The geometry of the
        buffer will be in the form of a polyline with 4 points
        in it. The polyline will form all of the face except the
        base line. 
        
NOTES
        None.

RETURN VALUES
        This function always returns TRUE.

HISTORY
        DLB     12/13/86        Creation date.
        Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"
# include "OMminimum.h"
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
# include "OMmacros.h"
#include "bserr.h"
#include "bsnorvec.h"

extern EFdyrbboxface();

struct face_struct
{
 struct DPele_header ele_header;
 IGRvector           vec, nor_vec;
};
       
IGRint EFdyboxface( corner_pt, width_pt, display )
 IGRpoint              corner_pt, width_pt;
 struct IGRdisplay     *display;

{
 struct       face_struct   header;
 struct       IGRpolyline   polyline;
 IGRpoint                   pt_buffer[4];
 IGRint                     size_pnt = sizeof(IGRpoint);
 BSrc			    rc;
 IGRboolean                 status;

 /**MOVE THE INPUT POINTS TO THE POLYLINE POINT BUFFER**/
 OM_BLOCK_MOVE(corner_pt, pt_buffer, size_pnt);   
 OM_BLOCK_MOVE(width_pt, &pt_buffer[3][0], size_pnt); 

 /**GET VECTOR FROM CORNER POINT TO WIDTH POINT**/
 header.vec[0] = width_pt[0] - corner_pt[0];
 header.vec[1] = width_pt[1] - corner_pt[1];
 header.vec[2] = width_pt[2] - corner_pt[2];

 /**NORMALIZE IT**/
 header.nor_vec[0] = header.vec[0];
 header.nor_vec[1] = header.vec[1];
 header.nor_vec[2] = header.vec[2];
 status = BSnorvec(&rc, header.nor_vec);
 if (!status) return (TRUE);
 
 /**INITIALIZE THE POLYLINE**/
 polyline.num_points = 4;           
 polyline.points = (IGRdouble *) pt_buffer;

 /**FILL IN HEADER INFORMATION**/
 dp$build_dis_buffer(        
                     buffer = &header.ele_header,
                     type = IGRPY,                /**TYPE IS POLYLINE**/
                     display_att = display,
                     geometry = (struct IGRpolyline *) &polyline);

 /*  INVOKE DYNAMICS  */
 dp$dynamics( dyn_fun = EFdyrbboxface, information = &header );
 return ( TRUE ); /**ALL DONE!!**/
}


/*
NAME    EFdyrbboxface
        
SYNOPSIS
        EFdyrbboxface(header, cursor_pt, matrix, objects, num_objects, 
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
        function. The function calculate the vector from the infinite
        base line  of the face to the cursor postion. From that the
        2 height points can be calculated and moved to the DPele_header
        buffer.
        
RETURN VALUES
        Since only simple calculations are involved and information 
        is being moved around, this function will always return MSSUCC.

HISTORY
        DLB 12/13/86        Creation date.
*/


IGRint EFdyrbboxface( header, cursor_pt, matrix, objects, num_objects,
                    buffer, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                    out_dummy1, out_dummy2, out_dummy3 )
 struct  face_struct   *header;
 struct  DPele_header  **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 IGRdouble  dot;

 dot = (header->ele_header.geometry.polyline->points[0] - cursor_pt->x) *
         header->nor_vec[0];
 dot += (header->ele_header.geometry.polyline->points[1] - cursor_pt->y) *
         header->nor_vec[1];
 dot += (header->ele_header.geometry.polyline->points[2] - cursor_pt->z) *
         header->nor_vec[2];
 header->ele_header.geometry.polyline->points[3] = cursor_pt->x + dot *
         header->nor_vec[0];
 header->ele_header.geometry.polyline->points[4] = cursor_pt->y + dot *
         header->nor_vec[1];
 header->ele_header.geometry.polyline->points[5] = cursor_pt->z + dot *
         header->nor_vec[2];
 header->ele_header.geometry.polyline->points[6] = 
         header->ele_header.geometry.polyline->points[3] + 
         header->vec[0];
 header->ele_header.geometry.polyline->points[7] = 
         header->ele_header.geometry.polyline->points[4] + 
         header->vec[1];
 header->ele_header.geometry.polyline->points[8] = 
         header->ele_header.geometry.polyline->points[5] + 
         header->vec[2];
 *buffer = &header->ele_header;
 *num_buffers = 1;
 return( MSSUCC ); /**DO DYMANICS!!**/
}
