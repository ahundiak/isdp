/* ###################   APOGEE COMPILED   ################## */
/*
NAME
        EFdylineseg - Rubberband off of 2, 3, or 4 points.

SYNOPSIS
        EFdylineseg(num, pt1, pt2, pt3, pt4, display)
        IGRint   num;                number of points to rb off of
        IGRpoint pt1, pt2, pt3, pt4; has the points to rb off of  
        sturct IGRdisplay *display;  has active display stuff     

DESCRIPTION
        This function takes 2, 3, or 4 points and sets up the
        DPele_header buffers to do dynamics off of all points.
        The geometry will be in the form of polylines consisting
        of two points in each. The first point will be that input
        to the function. The second point will be determined by
        the cursor position retrieved by the dp$dynamics routine.
        
NOTES
        If dynamics are desired off of 2 or 3 point then the
        parameters for pt3 and pt4 can be passed and a dummy
        address of type IGRpoint. This is okay since the points 
        will not be looked at if they are not needed.

RETURN VALUES
        This function always returns TRUE.

HISTORY
        DLB     12/11/86        Creation date.
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

extern EFdyrb2lines(), EFdyrb3lines(), EFdyrb4lines();

IGRint EFdylineseg( num, pt1, pt2, pt3, pt4, display )
 IGRint                num;
 IGRpoint              pt1, pt2, pt3, pt4;
 struct IGRdisplay     *display;

{
 struct       DPele_header  header[4];
 struct       IGRpolyline   polyline[4];
 IGRpoint                   pt_buffer[8];
 IGRint                     size_pnt = sizeof(IGRpoint), i;

 /**MOVE THE INPUT POINTS TO THE POLYLINE POINT BUFFER**/
 switch (num)
 {
  case 4:
  {
   OM_BLOCK_MOVE(pt4,&pt_buffer[6][0],size_pnt);   
  }
  case 3:
  {
   OM_BLOCK_MOVE(pt3,&pt_buffer[4][0],size_pnt);    
  }
  case 2:
  {
   OM_BLOCK_MOVE(pt1,pt_buffer,size_pnt);
   OM_BLOCK_MOVE(pt2,&pt_buffer[2][0],size_pnt);
   break;
  }
  default:
  {
   return (TRUE); /**BAD INPUT**/
  }
 } 
 for (i=0; i<num; i++)
 {
  polyline[i].num_points = 2;            /**INITIALIZE THE POLYLINES**/
  polyline[i].points = &pt_buffer[2*i][0];
  dp$build_dis_buffer(                   /**FILL IN HEADER INFORMATION**/
                      buffer = &header[i],
                      type = IGRPY,      /**TYPE IS POLYLINE**/
                      display_att = display,
                      geometry = (struct IGRpolyline *) &polyline[i]);
 } 
 /*  INVOKE DYNAMICS  */
 if (num == 2)
  dp$dynamics( dyn_fun = EFdyrb2lines, information = header );
 else if (num == 3)
  dp$dynamics( dyn_fun = EFdyrb3lines, information = header );
 else 
  dp$dynamics( dyn_fun = EFdyrb4lines, information = header );
 return ( TRUE ); /**ALL DONE!!**/
}


/*
NAME    EFdyrb2lines  \
        EFdyrb3lines  -->  function  called by dp$dynamics to put new
        EFdyrb4lines  /    cursor position in the polyline buffers.
        
SYNOPSIS
        EFdyrb2lines  
        EFdyrb3lines  
        EFdyrb4lines  
        (header, cursor_pt, matrix, objects, num_objects, buffer,
         num_buffers, in_dummy1, in_dummy2, in_dummy3, out_dummy1,
         out_dummy2, out_dummy3);

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
        These routines are called by dp$dynamics after it has sensed
        a cursor change. The new cursor position is passed to one of
        these functions. The function will move the cursor position
        to 2, 3, or 4 DPele_header buffers ( depending on the number
        of points to dynamic off of). The function then returns to 
        dp$dynamics where the buffers are displayed. That function
        then checkes the cursor again and the cycle is repeated.

RETURN VALUES
        Since information is only being moved around, these functions
        will always return TRUE.

HISTORY
        DLB 12/11/86        Creation date.
*/


IGRint EFdyrb2lines( header, cursor_pt, matrix, objects, num_objects,
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
 header[0].geometry.polyline->points[4] = cursor_pt->y;
 header[0].geometry.polyline->points[5] = cursor_pt->z;
 header[1].geometry.polyline->points[3] = cursor_pt->x;
 header[1].geometry.polyline->points[4] = cursor_pt->y;
 header[1].geometry.polyline->points[5] = cursor_pt->z;
 *buffer = header;
 *num_buffers = 2;
 return( MSSUCC ); /**DO DYMANICS!!**/
}


IGRint EFdyrb3lines( header, cursor_pt, matrix, objects, num_objects,
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
 header[0].geometry.polyline->points[4] = cursor_pt->y;
 header[0].geometry.polyline->points[5] = cursor_pt->z;
 header[1].geometry.polyline->points[3] = cursor_pt->x;
 header[1].geometry.polyline->points[4] = cursor_pt->y;
 header[1].geometry.polyline->points[5] = cursor_pt->z;
 header[2].geometry.polyline->points[3] = cursor_pt->x;
 header[2].geometry.polyline->points[4] = cursor_pt->y;
 header[2].geometry.polyline->points[5] = cursor_pt->z;
 *buffer = header;
 *num_buffers = 3;
 return( MSSUCC ); /**DO DYNAMICS!!**/
}


IGRint EFdyrb4lines( header, cursor_pt, matrix, objects, num_objects,
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
 header[0].geometry.polyline->points[4] = cursor_pt->y;
 header[0].geometry.polyline->points[5] = cursor_pt->z;
 header[1].geometry.polyline->points[3] = cursor_pt->x;
 header[1].geometry.polyline->points[4] = cursor_pt->y;
 header[1].geometry.polyline->points[5] = cursor_pt->z;
 header[2].geometry.polyline->points[3] = cursor_pt->x;
 header[2].geometry.polyline->points[4] = cursor_pt->y;
 header[2].geometry.polyline->points[5] = cursor_pt->z;
 header[3].geometry.polyline->points[3] = cursor_pt->x;
 header[3].geometry.polyline->points[4] = cursor_pt->y;
 header[3].geometry.polyline->points[5] = cursor_pt->z;
 *buffer = header;
 *num_buffers = 4;
 return( MSSUCC ); /**DO DYNAMICS!!**/
}
