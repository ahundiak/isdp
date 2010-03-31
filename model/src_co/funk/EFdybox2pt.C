/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
NAME
        EFdybox2pt - Dynamically place box by 2 points

SYNOPSIS
        EFdybox2pt(pt0, display)
        IGRpoint pt0;                has the corner point of the box
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
        This function takes as input 1 corner of a box and 
        sets up the DPele_header buffers dynamically draw
        a rectangular box by 2 points. The box will be based
        on the same idea as a range box. The bounding planes
        will be parallel to the coordinate axes of the design
        file. The geometry of the buffers will be in the form
        of polylines consisting of 4 points in each. Each
        polyline will form all of a face except for 1 edge line.
        Another polyline will fill that edge (i.e. the polylines
        will wrap around the sides of the box). The other corner
        that makes up the box will be determined by the cursor 
        position retrieved by the dp$dynamics routine.
        
NOTES
        None.

RETURN VALUES
        This function always returns TRUE.

HISTORY
        DLB     12/12/86        Creation date.
*/

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

extern EFdyrbbox2pt();

IGRint EFdybox2pt( pt0, display )
 IGRpoint              pt0;
 struct IGRdisplay     *display;

{
 struct       DPele_header  header[4];
 struct       IGRpolyline   polyline[4];
 IGRpoint                   pt_buffer[16];
 IGRint                     size_pnt = sizeof(IGRpoint), i;

 /**MOVE THE INPUT POINT TO THE POLYLINE POINT BUFFER**/
 for (i=0; i<16; i++)
  OM_BLOCK_MOVE(pt0, &pt_buffer[i][0], size_pnt);   
 for (i=0; i<4; i++)
 {
  polyline[i].num_points = 4;            /**INITIALIZE THE POLYLINES**/
  polyline[i].points = &pt_buffer[4*i][0];
  dp$build_dis_buffer(                   /**FILL IN HEADER INFORMATION**/
                      buffer = &header[i],
                      type = IGRPY,      /**TYPE IS POLYLINE**/
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline[i]);
 } 
 /*  INVOKE DYNAMICS  */
 dp$dynamics( dyn_fun = EFdyrbbox2pt, information = header );
 return ( TRUE ); /**ALL DONE!!**/
}


/*
NAME    EFdyrbbox2pt
        
SYNOPSIS
        EFdyrbbox2pt(header, cursor_pt, matrix, objects, num_objects, 
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
        functions. The function will move the cursor position x, y, 
        and z values to the proper corner points of the DPele_headers
        that define the box. The function then returns to dp$dynamics 
        where the buffers are displayed. That function
        then checkes the cursor again and the cycle is repeated.

RETURN VALUES
        Since information is only being moved around, this function
        will always return MSSUCC.

HISTORY
        DLB 12/12/86        Creation date.
*/


IGRint EFdyrbbox2pt( header, cursor_pt, matrix, objects, num_objects,
                    buffer, num_buffers, in_dummy1, in_dummy2, in_dummy3,
                    out_dummy1, out_dummy2, out_dummy3 )
 struct  DPele_header  *header, **buffer;
 struct  GRid          **objects;
 struct  EX_button     *cursor_pt;
 IGRint                *num_objects, *num_buffers;
 IGRdouble             *matrix;
 IGRchar               **in_dummy1, **in_dummy2, **in_dummy3;
 IGRchar               **out_dummy1, **out_dummy2, **out_dummy3;
{
 header[0].geometry.polyline->points[3] = cursor_pt->x;
 header[0].geometry.polyline->points[6] = cursor_pt->x;
 header[0].geometry.polyline->points[7] = cursor_pt->y;
 header[0].geometry.polyline->points[10] = cursor_pt->y;

 header[1].geometry.polyline->points[0] = cursor_pt->x;
 header[1].geometry.polyline->points[3] = cursor_pt->x;
 header[1].geometry.polyline->points[5] = cursor_pt->z;
 header[1].geometry.polyline->points[6] = cursor_pt->x;
 header[1].geometry.polyline->points[7] = cursor_pt->y;
 header[1].geometry.polyline->points[8] = cursor_pt->z;
 header[1].geometry.polyline->points[9] = cursor_pt->x;
 header[1].geometry.polyline->points[10] = cursor_pt->y;

 header[2].geometry.polyline->points[0] = cursor_pt->x;
 header[2].geometry.polyline->points[1] = cursor_pt->y;
 header[2].geometry.polyline->points[2] = cursor_pt->z;
 header[2].geometry.polyline->points[4] = cursor_pt->y;
 header[2].geometry.polyline->points[5] = cursor_pt->z;
 header[2].geometry.polyline->points[8] = cursor_pt->z;
 header[2].geometry.polyline->points[9] = cursor_pt->x;
 header[2].geometry.polyline->points[11] = cursor_pt->z;

 header[3].geometry.polyline->points[1] = cursor_pt->y;
 header[3].geometry.polyline->points[2] = cursor_pt->z;
 header[3].geometry.polyline->points[4] = cursor_pt->y;
 header[3].geometry.polyline->points[11] = cursor_pt->z;

 *buffer = header;
 *num_buffers = 4;
 return( MSSUCC ); /**DO DYMANICS!!**/
}
