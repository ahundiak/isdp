/*
IGRlong CO_ni_generate_arc_pt_pattern( msg, events );
    IGRlong              *msg;
    struct GRevent       *events[];

Abstract
    This function generates several data points on the Software Event
    Queue.  The coordinates of these points are determined by

       1) a delta sweep angle from a specified axis
       2) number of equally spaced points along a polar axis
       2) delta between points along the polar axis

    polygon, then constructs and optionally displays a polygon object.
    If the display_obj is specified, then the object is displayed.




                            o           o
                             \         /
                              o       o
                               \     /
                                o   o
                                 \C/              A
                      o---o---o---+---o---o---o   +
                                 / \      ^   ^
                                o   o     |<->|
                               /     \      d
                              o       o
                             /         \
                            o           o

          Legend:
             +  = data points entered by user
             o  = data points generated by command

             C  = centroid point
             A  = point on axis
             N1 = 3 ( number of points generated on a ray
             N2 = 6 ( number of rays per sweep; 2 <= N2 <= 360 )
             d  = distance between points along an axis


Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.

        events[0]
             N2 = 6 ( number of points per sweep > 1 )

        events[1]
             N1 = 3 ( number of sweeps > 0)

        events[2]
             d  = distance between points along an axis

        events[3]
             C  = centroid point

        events[4]
             A  = point on axis


Status returns

Caveats

History
    srh 10/20/89 : created
    dhm 07/14/92 : ANSI conversion.

*/

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "madef.h"
#include "msdef.h"
#include "dpdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "griomacros.h"
#include "comiscmac.h"
#include "dpmacros.h"


#define NBR_OF_PTS_PER_SWEEP     events[0]->event.value
#define NBR_OF_SWEEPS            events[1]->event.value
#define DEFAULT_NBR_OF_SWEEPS   (events[1]->subtype == GRst_DEFAULT)
#define DISTANCE_BETWEEN_SWEEPS  events[2]->event.value
#define CENTER_PT                events[3]->event.button
#define WINDOW                   events[3]->event.button
#define SWEEP_PT                 events[4]->event.button

/* variable names for Generate Polar Array of Points commands */
#define  MOVEON_TOGGLE_NAME     "_GR_MOVEON_TOGGLE"
#define  CENTER_PT_TOGGLE_NAME  "_GR_CENTER_PT_TOGGLE"
#define  CLOSE_TOGGLE_NAME      "_GR_CLOSE_TOGGLE"
#define  START_PT_TOGGLE_NAME   "_GR_POL_START_PT_TOG"

#define _X_                       ( 0 )
#define _Y_                       ( 1 )
#define _Z_                       ( 2 )


/*----------------------------------------
 *  CO_ni_generate_arc_pt_pattern
 *----------------------------------------
 */
IGRlong CO_ni_generate_arc_pt_pattern( msg, events)

    IGRlong              *msg;
    struct GRevent       *events[];

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRboolean
       b_status = TRUE,      /* boolean return status                       */
       reset_flag,           /* queue EX_RJT_MOVEON after each sweep        */
       close_flag,           /* (don't) regenerate start pt of each sweep   */
       center_pt_flag,       /* (don't) generate center pt                  */
       gen_start_pt_flag;    /* (don't) generate start point of first sweep */ 

    IGRshort
       direction = 1;

    IGRlong
       status = MSSUCC,  /* return code                  */
       sweep_index,
       WhichError,
       Size = sizeof( struct EX_button ),
       BytesReturned,
       NumberOfSides;

    IGRint 
       Response;

    IGRdouble
       Distance,
       SweepDelta,
      *PointArray = NULL;

    IGRpoint
       CenterPoint,
       EdgePoint,
       StartPoint;

    IGRmatrix
       RotationMatrix;

    struct GRid
       WindowGrid;       /* window object id */

    struct IGRline
       Line;

    struct IGRpolyline
       polyline;       /* polyline used to when making bsp */

    struct var_list
       VariableList[2];

   struct GRIOvar_def
      var;

    struct EX_button
       SEQ_Event;

   extern IGRlong 
      COnpolygonConstruct();

   extern IGRboolean
      MA2ptdis(),
      MAptalln();


/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "CO_ni_generate_arc_pt_pattern" );


    *msg = MSSUCC;

    /*
     *  Allocate for polyline points for one sweep of points
     */
    NumberOfSides = (IGRlong) NBR_OF_PTS_PER_SWEEP;
    PointArray = (IGRdouble *)om$malloc(
                    size = ((NumberOfSides + 1) * 3) * sizeof( IGRdouble ) );
    if ( PointArray == NULL )
    {
        *msg = MSFAIL;
        status = OM_E_ABORT;
        goto quit;
    }

    WindowGrid.objid = WINDOW.objid;
    WindowGrid.osnum = WINDOW.osnum;

    /*
     *  set up the variable list
     */
    VariableList[0].var       = VIEW_ROTATION;
    VariableList[0].var_ptr   = ( char * ) RotationMatrix;
    VariableList[0].num_bytes = sizeof( IGRdouble ) * 16;
    VariableList[0].bytes_returned = &BytesReturned;
    VariableList[1].var = END_PARAM;


    /*
     *  get the view matrix for the display
     */
    _m_debug_str( "COnipoly - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
    _m_check2p( status, *msg, "COnipoly - failed inq_set_gragad." );
    _m_check2q( status, *msg );

    /*
     *  init the polyline
     */
    polyline.num_points = NumberOfSides + 1;
    polyline.points     = PointArray;

    /*
     *  construct the point array of the polygon
     */
    CenterPoint[0] = CENTER_PT.x;
    CenterPoint[1] = CENTER_PT.y;
    CenterPoint[2] = CENTER_PT.z;

    EdgePoint[0]   = SWEEP_PT.x;
    EdgePoint[1]   = SWEEP_PT.y;
    EdgePoint[2]   = SWEEP_PT.z;

    Line.point1  = CenterPoint;
    Line.point2  = EdgePoint;

    /*
     *  The distance between center and first sweep is different
     *  than the distance between the subsequent sweeps.  Calculate
     *  this distance.
     */
    b_status = MA2ptdis( msg,
                         CenterPoint,
                         EdgePoint,
                        &Distance );
    if ( !b_status ) { status = MSFAIL; goto quit; }
    
    /* 
     *  calculate the points for one sweep at a time; put the points on the
     *  SEQ after each sweep is calculated.  Put them on the queue in 
     *  reverse order so they will be retrieved in the expected order.
     */
    if ( DEFAULT_NBR_OF_SWEEPS ) 
    { 
       sweep_index = 0;
       SweepDelta = 0.0;
    }
    else
    {
       sweep_index = ( (IGRlong) NBR_OF_SWEEPS ) - 1;
       SweepDelta = DISTANCE_BETWEEN_SWEEPS ;
    }

    Distance += ( sweep_index * SweepDelta ); /* from outside in */

    /*
     * get reset, close, and center_pt flags from variable table; in
     * 2.0 release, these need to go to the dpb.
     */
    status = co$cvtvar( msg    =  msg,
                        alias  =  MOVEON_TOGGLE_NAME,
                        osnum  =  WINDOW.osnum,
                        var    = &var );
    reset_flag = ( IGRboolean ) var.contents.ivalue;

    status = co$cvtvar( msg    =  msg,
                        alias  =  CENTER_PT_TOGGLE_NAME,
                        osnum  =  WINDOW.osnum,
                        var    = &var );
    center_pt_flag = ( IGRboolean ) var.contents.ivalue;

    status = co$cvtvar( msg    =  msg,
                        alias  =  CLOSE_TOGGLE_NAME,
                        osnum  =  WINDOW.osnum,
                        var    = &var );
    close_flag = ( IGRboolean ) var.contents.ivalue;

    status = co$cvtvar( msg    =  msg,
                        alias  =  START_PT_TOGGLE_NAME,
                        osnum  =  WINDOW.osnum,
                        var    = &var );
    gen_start_pt_flag = ( IGRboolean ) var.contents.ivalue;

    /*
     *  Generate points on software event queue (SEQ)
     */
    for ( ;sweep_index >= 0; sweep_index-- )
    {
       IGRlong
          pt_index;

       /*
        *  calcular point start of sweep point along axis.
        */
       b_status = MAptalln( msg,
                           &Line,
                            CenterPoint,
                           &direction,
                           &Distance,
                            StartPoint );
       if ( !b_status ) { status = MSFAIL; goto quit; }

       status = COnpolygonConstruct(  msg,
                                      RotationMatrix,
                                      CenterPoint,
                                      StartPoint,
                                     &NumberOfSides,
                                      PointArray );
       _m_check2q( status, *msg );

       /*
        *  Put each of the points on this sweep on the SEQ 
        *  subtype is specified so that ATP's will work
        */

       if ( reset_flag )
       {
          Response = EX_RJT_MOVEON;

          status = ex$putque ( msg      =  msg,
                               response = &Response,
                               byte     = &Size,
                               buffer   = (IGRchar *) &SEQ_Event );
       }

       if ( close_flag )
       {
          status = co$build_button( msg    =  msg,
                                    x      =  PointArray[_X_],
                                    y      =  PointArray[_Y_],
                                    z      =  PointArray[_Z_],
                                    osnum  =  WINDOW.osnum,
                                    objid  =  WINDOW.objid,
                                    button = &SEQ_Event );

          Response = EX_DATA;

          status = ex$putque ( msg      =  msg,
                               response = &Response,
                               byte     = &Size,
                               buffer   = (IGRchar *) &SEQ_Event );
          _m_checkq( status );
       }

       /* generate points for a sweep */
       for ( pt_index = NumberOfSides - 1; pt_index >= 0; pt_index-- )
       {
	  /*  optionally generate start point */
          if (    ( !gen_start_pt_flag ) 
	       && ( pt_index == 0 ) 
	       && ( sweep_index == 0   ) 
	     ) break;

          status = co$build_button( msg    =  msg,
                                    x      =  PointArray[(pt_index*3) + _X_],
                                    y      =  PointArray[(pt_index*3) + _Y_],
                                    z      =  PointArray[(pt_index*3) + _Z_],
                                    osnum  =  WINDOW.osnum,
                                    objid  =  WINDOW.objid,
                                    button = &SEQ_Event );

          Response           = EX_DATA;

          status = ex$putque ( msg      =  msg,
                               response = &Response,
                               byte     = &Size,
                               buffer   = (IGRchar *) &SEQ_Event );
          _m_checkq( status );
       }
       Distance -= SweepDelta;

    }
    /*
     *  if we generate the center point , we put it on the top FRONT
     *  of the SEQ so it's the first point generated.
     */

    /* center point position modified to BACK to fix TR 90N1165  */

    if ( center_pt_flag )
    {
       if ( reset_flag )
       {
          Response = EX_RJT_MOVEON;

          status = ex$putque ( msg      =  msg,
                               response = &Response,
                               byte     = &Size,
			       pos	= BACK,
                               buffer   = (IGRchar *) &SEQ_Event );
       }

       Response  = EX_DATA;
       SEQ_Event = CENTER_PT;

       status = ex$putque ( msg      =  msg,
                            response = &Response,
                            byte     = &Size,
                            buffer   = (IGRchar *) &SEQ_Event );
       _m_checkq( status );
    }

quit:
    if ( PointArray ) om$dealloc( ptr = PointArray );
    return ( status );
}
