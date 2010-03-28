/* #######################    APOGEE COMPILED   ######################## */
/*
    DYvertex()

    Abstract:  
       DYvertex performs the polyline endpoint assignments of a
       rubberbanding pair of lines (2 one-segment polyline) to be 
       drawn by DPdynamics.  The address of this function is passed 
       as a parameter to DPdynamics for the rubberbanding to occur.
   

   Sample call:

        Value = DYvertex( 
                    additional_info,
                    point,
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
                    out_dummy3 );
   Arguments:

     *additional_info  IGRchar            information passed to DPdynamics
     *point            struct EX_button   current cursor position
     *matrix           IGRdouble          a 4 X 4 homogeneous matrix that
			     		      translates world to screen 
					      coordinates
     **objects      struct GRid         objects in dynamics
     *num_objects   IGRint              number of objects in dynamics
     **buffer       struct DPele_header buffered elements in dynamics
     *num_buffers   IGRint              nbr. of buffered elements in dynamics
     **dummy1       IGRchar             (Not used)
     **dummy2       IGRchar             (Not used)
     **dummy3       IGRchar             (Not used)


     History:  srh  6/17/86  - Created.
               srh  7/28/86  - modified to accomidate changes in DYrbvertex;
		               curson now initializes first point in each
		               of two polyline buffers.

 */

/* EH */

#include "coimport.h"
#include  "igrtypedef.h"
#include  "OMminimum.h"
#include  "igetypedef.h"
#include  "igrdef.h"
#include  "igr.h"
#include  "msdef.h"
#include  "gr.h"
#include  "ex.h"
#include  "igrdp.h"
#include  "dpstruct.h"
#include  "dpmacros.h"



IGRint DYvertex( header,
                 cursor_pt,
                 objects,
		 matrix,
                 num_objects,
                 buffer,
                 num_buffers,
                 in_dummy1,
                 in_dummy2,
                 in_dummy3,
                 out_dummy1,
                 out_dummy2,
                 out_dummy3 )

    struct DPele_header      *header;  /* points to an array of two polylines */
    struct   EX_button       *cursor_pt;
    struct   GRid           **objects;
    IGRdouble                *matrix; 
    IGRint                   *num_objects;
    struct   DPele_header   **buffer;
    IGRint                   *num_buffers;
    IGRchar                 **in_dummy1;
    IGRchar                 **in_dummy2;
    IGRchar                 **in_dummy3;
    IGRchar                 **out_dummy1;
    IGRchar                 **out_dummy2;
    IGRchar                 **out_dummy3;

{
    IGRint status;


    status = MSSUCC;   /* always successfull */

    /* set up buffered element */
    *buffer = header;
    *num_buffers = 2;

    /*
     *  assign vertex value to endpoints of both polylines 
     */
    header->geometry.polyline->points[0] = cursor_pt->x;
    header->geometry.polyline->points[1] = cursor_pt->y;
    header->geometry.polyline->points[2] = cursor_pt->z;

    header++;  /* increment to next buffer */

    header->geometry.polyline->points[0] = cursor_pt->x;
    header->geometry.polyline->points[1] = cursor_pt->y;
    header->geometry.polyline->points[2] = cursor_pt->z;

    return( status );
}
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     FUNCTION:  DYrbvertex

    Abstract:  DYrbvertex sets up the "additional information" needed 
               by DPdynamics.  This routine is invoked from a command
               object's execute method to display a rubberbanding 
               line.

-----
%SC%    
        Value = DYrbvertex( closure,
                            end_pt1, 
                            end_pt2,
                            display1,
                            display2 );

-----
%EN%
     ON ENTRY:

      NAME          DATA TYPE                    DESCRIPTION
     --------  ------------------   ------------------------------------
     closure   *IGRboolean          display angle or triangle flag
     end_pt1   *IGRpoint            end point of first  rubberband line
     end_pt2   *IGRpoint            end point of second rubberband line
     display1  *struct IGRdisplay   display attr. for line from end_pt1
     display2  *struct IGRdisplay   display attr. for line from end_pt2

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   -----------------   -----------------------------------------
      ( None )

-----
%MD%

    MODULES, MACROS AND METHODS INVOKED:

    -------------------------------------------------------------------------
    Modules:
        
        DYdynamics - Standard dynamics function to perform graphics dynamics


-----
%NB%

     NOTES:

     srh  6/20/86: 
         The display attribute <color> is currently hard coded in the 
         DPdynamics function, however, at some later date this attribute 
         may be assigned as specified below.  Thus the assignment statement,

              header.dis_att.color = display1->color;
              header.dis_att.color = display2->color;

         is placed in the code.  When the DPdynamics begins to support color, 
         no changes need to be made to this code to accomodate it. 

     srh  8/28/86:
         I have changed the two point buffers so that pt_buffer_1 represents
         the dashed side of a triangle;  pt_buffer_2 represents the other
         two sides.  The first point in each buffer is initialized by the
         cursor.  Point 2 of pt_buffer1 is end_pt1.  Point 2 of pt_buffer_2
         is end_pt2.  Point 3 of pt_buffer_2 is end_pt1.


                             cursor
                                +
                               / \
                              /   \
                             /     \
                            /       \ 
                   end_pt1 o_________o end_pt2
         
-----
%CH%

     CHANGE HISTORY:

     srh  6/20/86  - Designed/created.

     srh  6/21/86  - Added ability to specify the individual display 
                     attributes for each of the two bubberbanded 
                     segments.

     srh  7/28/86  - Added ability to display triangle; a new parameter
                     was added to specify whether or not to display the
                     segment to close the triangle.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

  Description:

      Two single segment polyline buffers are used for dynamics display.
      Each has its second point assigned by the mouse cursor.  This gives
      the effect of moving a vertex.  Two single segment polylines are 
      used instead of one two segment polyline so that display attributes 
      for each may be independently assigned.

-----
%EH%
-----*/

#define   OPEN       (0)    /* flag to indicate vertex only displayed */
#define   CLOSED     (1)    /* flag to indicate triangle displayed    */

extern    IGRint    DYvertex();

IGRint DYrbvertex( closure, end_pt1, end_pt2, display1, display2 )
                   
    IGRboolean            *closure;
    IGRdouble             *end_pt1;
    IGRdouble             *end_pt2;
    struct IGRdisplay     *display1;
    struct IGRdisplay     *display2;

{
    struct       DPele_header   header[2];
    struct       IGRpolyline    pyline1;
    struct       IGRpolyline    pyline2;
    IGRdouble                   pt_buffer_1[6];
    IGRdouble                   pt_buffer_2[9];

    /* 
     * set fixed points 
     */
    pt_buffer_1[3] = end_pt1[0];
    pt_buffer_1[4] = end_pt1[1];
    pt_buffer_1[5] = end_pt1[2];

    pt_buffer_2[3] = end_pt2[0];
    pt_buffer_2[4] = end_pt2[1];
    pt_buffer_2[5] = end_pt2[2];

    /*
     *  set up pt_buffer_2 according to closure 
     */
    if ( *closure == CLOSED )
    {
        pyline2.num_points = 3;

        pt_buffer_2[6] = end_pt1[0];
        pt_buffer_2[7] = end_pt1[1];
        pt_buffer_2[8] = end_pt1[2];
    }
    else  /* closure == OPEN */
    {
        pyline2.num_points = 2;
    }

    pyline1.num_points = 2;

    pyline1.points = pt_buffer_1;
    pyline2.points = pt_buffer_2;

    /*
     *  Fill in header information
     */
    dp$build_dis_buffer( buffer      = &header[0],
                         type        =  IGRPY,      /* type is polyline  */
                         display_att =  display1,
	                 geometry    = (struct IGRpolyline *) &pyline2  );

    dp$build_dis_buffer( buffer      = &header[1],
                         type        =  IGRPY,      /* type is polyline  */
                         display_att =  display2,
	                 geometry    = (struct IGRpolyline *) &pyline1  );


    /*  Invoke dynamics  */
    dp$dynamics( dyn_fun = DYvertex, 
		 information = header );
 
    return ( TRUE );
}
