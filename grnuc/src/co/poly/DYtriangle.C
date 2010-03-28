/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* ----------------------------------------------------------------------------
    DYtriangle()

    Abstract:  

       DYtriangle performs the polyline endpoint assignments of a
       rubberbanding 3 segment polyline to be drawn by DPdynamics.
       The address of this function is passed as a parameter to
       DPdynamics for the rubberbanding to occur.
   

   Sample call:

        Value = DYtriangle( 
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
     *cursor           struct EX_button   current cursor position
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


     History:  srh  04/28/87 - Created.  For COB polygon dynamics.

 --------------------------------------------------------------------------- */

/*  EH - End of Header for DYtriangle */

#include  "coimport.h"
#include  "igrtypedef.h"
#include  "OMminimum.h"
#include  "OMerrordef.h"
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

#include "codebug.h"
#include  "igrmacros.h"


IGRlong DYtriangle( header,
                    cursor,
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

    struct DPele_header     * header;  /* contains polyline for triangle */
    struct   EX_button      * cursor;
    struct   GRid          ** objects;
    IGRdouble               * matrix; 
    IGRint                  * num_objects;
    struct   DPele_header  ** buffer;
    IGRint                  * num_buffers;
    IGRchar                ** in_dummy1;
    IGRchar                ** in_dummy2;
    IGRchar                ** in_dummy3;
    IGRchar                ** out_dummy1;
    IGRchar                ** out_dummy2;
    IGRchar                ** out_dummy3;

{
    IGRint status = MSSUCC;  /* always successfull */

    /* set up buffered element */
    *buffer = header;
    *num_buffers = 1;

    /*
     *  assign triangle value to endpoints of both polylines 
     */
    header->geometry.polyline->points[3] = cursor->x;
    header->geometry.polyline->points[4] = cursor->y;
    header->geometry.polyline->points[5] = cursor->z;

    return( status );
}


/* ----------------------------------------------------------------------------

   IGRlong DYrbtriangle( events, display )

   Abstract:

      DYrbtriangle sets up the "additional information" needed by DPdynamics.
      This routine is invoked from a command object's execute method to 
      display a rubberbanding line.

   Sample Call:

      status = DYrbtriangle( &events, &dispaly );


   Arguments:

    struct GRevent   *events[]
        An array of events; these are usually collected by a command object.  

           events[0] is the first vertex of the angle
           events[1] is the third vertex of the angle

	( the cursor will provide the second vertex of the triangle )

    struct IGRdisplay  *display
        color, style, weight, etc. of display


   History:

      srh 04/28/87 -  created ( cloned from DYrbvertex.C from old dynamic
		      interface, converted to COB standard interface )
      jjc 12/15/89 -  added code to DYrbtriangle to allow special
                      construction points.

   Notes:
       The pt_buffer array holds the vertices of a triangle. 
       Refering to the diagram below:

          - Vertex 1 is set from events[0]'s button coordinates;  these
	    coordinates are stored in pt_buffer[0-2] and in pt_buffer[9-11]
	    ( for closure ).

	  - Vertex 2 is initialized by the cursor.  these coordinates are
	    stored in pt_buffer[3-5]. 
      
          - Vertex 3 is set from events[1]'s button coordinates;  these
	    coordinates are stored in pt_buffer[6-8]. 


                            ( cursor )
                             Vertex 2
                                +
                               / \
                              /   \
                             /     \
           ( events[0] )    /       \   ( events[1] )
                  Vertex 1 o _ _ _ _ o Vertex 3


   Notes:

      A single three segment polyline buffer is used for dynamics display.
      
 --------------------------------------------------------------------------- */

/*  EH - End of Header for DYrbtriangle */


IGRlong DYrbtriangle( events, display )
                   
    struct  GRevent         *events[];      /* array of pointers to events */
    struct  IGRdisplay      *display;
{
    IGRdouble                pt_buffer[12]; /* enough for 4 points */
    struct  DPele_header     header;
    struct  IGRpolyline      pyline;
    IGRshort                  NumberOfEvents;
    IGRboolean               b_status;
    IGRlong                  msg;
    IGRlong                  status;
    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line 
     */
    GRls_declare( line, LinePolesetc );

/* EV - end of variable declarations */


    _m_debug_str( "DYrbtriangle: here!" );
    /*
     *  declare buffer attributes
     */
    pyline.num_points = 4;
    pyline.points = pt_buffer;



    status = OM_S_SUCCESS;
    NumberOfEvents = 2;

    /*
     *  initialize the poles, weights, knots pointers in the line 
     */
    GRls_init( line, LinePolesetc );

    /*  
     *  ROUTER:
     *  Construct the nurb form of a line given
     *  the two data point events.  Special construction
     *  points are handled by this router.
     */
    b_status = GRls2pt( 
                   &msg,
                    events,
                   &NumberOfEvents,
                   &line );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(&msg,&line);
    _m_checkq(status);


    /*  extract the points from the line passed back by the router 
     *  and set the fixed vertices.
     *
     *  Vertex 1
     */
    pt_buffer[0]  = line.poles[0];
    pt_buffer[1]  = line.poles[1];
    pt_buffer[2]  = line.poles[2];

    /*  Vertex 3
     */
    pt_buffer[6]  = line.poles[3];
    pt_buffer[7]  = line.poles[4];
    pt_buffer[8]  = line.poles[5];

#ifdef DEBUG
    pt_buffer[3]  = 0.0;   /* Cursors point  */
    pt_buffer[4]  = 0.0;
    pt_buffer[5]  = 0.0;
#endif DEBUG

    /*
     *  close polyline 
     */
    pt_buffer[9]  = pt_buffer[0];   /* same as Vertex 1 */
    pt_buffer[10] = pt_buffer[1];
    pt_buffer[11] = pt_buffer[2];

#ifdef DEBUG
    printf( "DYrbtriangle:  Polyline point array:\n");
    {
       IGRshort index;

       printf("\n");
       for ( index = 0; index <= 11; index++ )
       {
	  printf( "   pt_buffer[%d] = %f \n", index, pt_buffer[index] );
       }
       printf("\n");
    }
#endif DEBUG

    _m_debug_str( "DYrbtriangle: calling dp$build_dis_buffer" );

    /*
     *  Fill in header information
     */
    dp$build_dis_buffer( buffer      = &header,
                         type        =  IGRPY,      /* type is polyline  */
                         display_att =  display,
	                 geometry    = (struct IGRpolyline *) &pyline  );

    /*  Invoke dynamics  */
    _m_debug_str( "DYrbtriangle: calling dp$dynamics" );
    dp$dynamics( dyn_fun = DYtriangle, 
		 information = &header );
 
quit:
    _m_debug_str( "DYrbtriangle: gone ..." );
    return ( status );
}
