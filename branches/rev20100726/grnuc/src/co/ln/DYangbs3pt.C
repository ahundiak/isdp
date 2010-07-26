/* #######################    APOGEE COMPILED   ######################## */

/*
    IGRint DYrbangbis3pt()

    Abstract:  DYrbangbis3pt sets up the "additional information" needed 
               by DPdynamics.  This routine is invoked from a command
               object's execute method to display a rubberbanding 
               line.


   Sample call:

   DYrbangbis3pt( Events, 
                  display )

   Arguments:
    
    *Events[]    struct GRevent           
        Events[0]  -  first point of angle
        Events[1]  -  vertex point of angle 

    *Display     struct IGRdisplay   display attr. for line

     History:

        srh  6/20/86:  created
        srh 10/23/86:  converted to OM 4.0 and new executive diplay
        srh 08/21/87:  converted to standard COB dynamics arg list 
        srh 10/28/87:  fixed bugs - bad header points


  =-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=---=-=-=-=-=-=-=-=-=-=

    DYangbis3pt()

    Abstract:  
       DYangbis3pt performs the polyline endpoint assignments of a
       rubberbanding pair of lines (2 one-segment polyline) to be 
       drawn by DPdynamics.  The address of this function is passed 
       as a parameter to DPdynamics for the rubberbanding to occur.


   Arguments:

     *additional_info  IGRchar            information passed to DPdynamics
     *point            struct EX_button   current cursor position
     *matrix           IGRdouble          a 4 X 4 homogeneous matrix that
                                              translates world to screen 
                                              coordinates
     **objects         struct GRid         objects in dynamics
     *num_objects      IGRint              number of objects in dynamics
     **buffer          struct DPele_header buffered elements in dynamics
     *num_buffers      IGRint              nbr. of buffered elements in dynamics
     **dummy1          IGRchar             (Not used)
     **dummy2          IGRchar             (Not used)
     **dummy3          IGRchar             (Not used)

   Returns:  MSSUCC  (always)

   History:  srh  6/17/86  - Created.
             srh  8/21/87  - converted to COB dynamics arg specifications

   Schematic:

                          o  angle end_pt1
                         / 
                        /  
                       /  
       angle vertex   /  
       and bisector  o----o bisector end point
       end point      \
                       \
                        \
                         \|
                        --o-- angle end_pt2 (cursor)
                          |

   Caveats:

   Files 

      DYangbis3pt.C

 */

/* EH */

#include "coimport.h"
#include  "codebug.h"
#include  "igrtypedef.h"
#include  "OMminimum.h"
#include  "igetypedef.h"
#include  "igrdef.h"
#include  "godef.h"
#include  "igr.h"
#include  "msdef.h"
#include  "gr.h"
#include  "ex.h"
#include  "igrdp.h"
#include  "dpstruct.h"
#include  "dpmacros.h"
#include  "griodef.h"
#include  "go.h"
#include  "ex.h"
#include  "grio.h"


#define   DASHED         ( 3 )       /* symbolgy of angle    */

#define   FirstPtEvent   Events[0]
#define   VertexPtEvent  Events[1]



IGRint DYangbis3pt( header,
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
                    out_dummy3 )
   
    struct DPele_header      *header;  /* points to an array of two polylines */
    struct   EX_button       *cursor_pt;
    IGRdouble                *matrix; 
    struct   GRid           **objects;
    IGRint                   *num_objects;
    struct DPele_header     **buffer;
    IGRint                   *num_buffers;

    IGRchar                 **in_dummy1;
    IGRchar                 **in_dummy2;
    IGRchar                 **in_dummy3;

    IGRchar                 **out_dummy1;
    IGRchar                 **out_dummy2;
    IGRchar                 **out_dummy3;


{
    /*************************** LOCAL VARIABLES **************************/

    IGRboolean
            b_status;

    IGRlong          
            status,
            msg;

    IGRdouble       
            tparm1,       /* tparm for MA2lnisect  (not used) */
            tparm2,       /* tparm for MA2lnisect  (not used) */
            tolerance,    /* tolerance for MA2lnisect call    */ 
            line1_pts[6],
            line2_pts[6],
            unit_vector_pts[6];

    IGRpoint        
            isect_pt;     /* end point of bisector            */

    struct IGRline  
            line1,        /* line1 & line2 form bisected      */
            line2,        /*   angle                          */
            line3,        /* line3 truncates the bisector     */
            unit_vector;  /* unit vector for bisector         */


    /*************************** END LOCAL VARIABLES *************************/
    

    status = MSSUCC;   /* always successfull */

    /*
     *  set up for buffered geometries 
     */
    *buffer = header;
    *num_buffers = 2;

    /*
     * Get unit vector bisector; vertex point is first point of
     * both line1 and line2.
     */

    line1_pts[0] = header[0].geometry.polyline->points[3];  /* vertex */
    line1_pts[1] = header[0].geometry.polyline->points[4];
    line1_pts[2] = header[0].geometry.polyline->points[5];

    line1_pts[3] = header[0].geometry.polyline->points[0];
    line1_pts[4] = header[0].geometry.polyline->points[1];
    line1_pts[5] = header[0].geometry.polyline->points[2];

    line2_pts[0] = header[0].geometry.polyline->points[3];  /* vertex */
    line2_pts[1] = header[0].geometry.polyline->points[4];
    line2_pts[2] = header[0].geometry.polyline->points[5];

    line2_pts[3] = cursor_pt->x;
    line2_pts[4] = cursor_pt->y;
    line2_pts[5] = cursor_pt->z;

    line1.point1 = &line1_pts[0];
    line1.point2 = &line1_pts[3];

    line2.point1 = &line2_pts[0];
    line2.point2 = &line2_pts[3];
    
    unit_vector.point1 = &unit_vector_pts[0];
    unit_vector.point2 = &unit_vector_pts[3];

    tolerance = 0.1;  /* Not real important in this case */

    b_status = MAangbis(
                   &msg,
                   &line1,
                   &line2,
                   &tolerance,
                   &unit_vector );

    /*
     *  Extend calculated bisector ( unit_vector ) to intersect 
     *   with the opposite side of the triangle (line3) defined
     *   by the three points.
     */
    line3.point1 = &line1_pts[3];
    line3.point2 = &line2_pts[3];
                  
    b_status = MA2lnisect(
                   &msg,
                   &unit_vector, 
                   &line3,
                   &tolerance,
                    isect_pt,
                   &tparm1,   /* tparms not used */
                   &tparm2 );

    /*
     *  assign cursor value to endpoint of angle
     */
    header[0].geometry.polyline->points[6] = cursor_pt->x;
    header[0].geometry.polyline->points[7] = cursor_pt->y;
    header[0].geometry.polyline->points[8] = cursor_pt->z;

    header[1].geometry.polyline->points[3] = isect_pt[0];
    header[1].geometry.polyline->points[4] = isect_pt[1];
    header[1].geometry.polyline->points[5] = isect_pt[2];

    return( status );
}

/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */




IGRint DYrbangbis3pt( Events, BisectorDisplay )

    struct GRevent        *Events[];
    struct IGRdisplay     *BisectorDisplay;

{
    struct DPele_header
            header[2];

    struct IGRpolyline 
            angle,
            bisector;

    struct IGRdisplay 
            AngleDisplay;

    IGRdouble 
            ang_buffer[9],  /* 3 points defining angle */
            bis_buffer[6];  /* 2 points defining bisector */

    /* 
     * set fixed points 
     */
    ang_buffer[0] = FirstPtEvent->event.button.x;
    ang_buffer[1] = FirstPtEvent->event.button.y;
    ang_buffer[2] = FirstPtEvent->event.button.z;

    ang_buffer[3] = VertexPtEvent->event.button.x;
    ang_buffer[4] = VertexPtEvent->event.button.y;
    ang_buffer[5] = VertexPtEvent->event.button.z;

    bis_buffer[0] = VertexPtEvent->event.button.x;
    bis_buffer[1] = VertexPtEvent->event.button.y;
    bis_buffer[2] = VertexPtEvent->event.button.z;

    angle.num_points = 3;
    angle.points = ang_buffer;

    bisector.num_points = 2;
    bisector.points = bis_buffer;

    /*  
     *  Setup display attributes of angle such that it is dashed and 
     *  has a line weight of 0
     */
    AngleDisplay = *BisectorDisplay;
    AngleDisplay.style    = DASHED;
    AngleDisplay.weight   = 0;

    /*
     *  Fill in header information:
     *
     *    header[0] - for angle
     *    header[1] - for bisector
     */
    dp$build_dis_buffer( buffer       = &header[0],
                         type         =  IGRPY,      /* type is polyline  */
                         display_att  = &AngleDisplay,
                         geometry     = &angle  );

    dp$build_dis_buffer( buffer       = &header[1],
                         type         =  IGRPY,      /* type is polyline  */
                         display_att  =  BisectorDisplay,
                         geometry     = &bisector  );

    /*
     *  Invoke dynamics  
     */
    dp$dynamics( dyn_fun = DYangbis3pt, 
                 information = header );
 
    return ( TRUE );
}
