/*

     CO_ni_dist_dir_view()

     Abstract:
        Non-interactive function to calculate world coordinates of a series
        of one or more data points specified by distance and direction 
        starting from the DPB's last point with respect to a specified view.
        If no view is specified, the default is the view of last point.  If
        no angle is specified, then the active angle from the DPB is used.
        The default repetion factor ( number of points generated ) is one 
        (1).  Distance between points MUST BE SPECIFIED.

        Contents of events pointer array on entry:

          events[0] - NOT USED in 1.3.0 GRNUC
          events[1] - distance ( if default, use zero )
          events[2] - angle ( if default, then use active angle )
          events[3] - repetition factor ( default = 1 )
          events[4] - view name ( if default, then use last point's view name )

     Return Status:
         always return MSSUCC

     Caveats

     History:
     
        srh  06/04/87  -  Created;
        srh  02/04/88  -  Modified function such that it ALWAYS returns
                          a return status of MSSUCC;  All errors are 
                          returned in the sts argument.
        srh  10/05/89  -  Added repetion factor for multi-point generation
        dhm  07/14/92  -  ANSI conversion.
 */

/*   EH -  End of Header  */

#include    "coimport.h"
#include    "codebug.h"
#include    "OMminimum.h"
#include    "igetypedef.h"
#include    "igrtypedef.h"
#include    "godef.h"
#include    "gr.h"
#include    "igr.h"
#include    "igrdp.h"
#include    "msdef.h"
#include    "go.h"
#include    "ex.h"
#include    "griodef.h"
#include    "grio.h"
#include    "dpdef.h"
#include    "dp.h"
#include    "grdpbdef.h"
#include    "grdpb.h"
#include    "griomacros.h"
#include    "grdpbmacros.h"
#include    "madef.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "dpmacros.h"
#include    "OMprimitives.h"
#include    "igrmacros.h"
#include    "grmessage.h"


#define DISTANCE              events[1]->event.value
#define ANGLE_SUBTYPE         events[2]->subtype
#define ANGLE_EVENT           events[2]
#define REPETITIONS           events[3]->event.value
#define REPETITION_SUBTYPE    events[3]->subtype
#define WINDOW_EVENT          events[4]


extern  IGRboolean 
               MAtrnmx(),
               MAptsxform(),
               MAlalpt(),
               MAptsxform();

/*
 *----------------------------------------
 *   CO_ni_dist_dir_view()
 *----------------------------------------
 */
IGRlong CO_ni_dist_dir_view( sts,
                             events )

    IGRlong              *sts;
    struct GRevent       *events[];

{

/* BV - BEGINNING OF VARIABLE LIST */

    IGRboolean  
               b_status;

    IGRshort  
               dim;

    IGRlong    
               status = MSSUCC,
               which_error,
               window_hard_num,
               bytes_returned;

    IGRdouble
               angle;

    IGRint  
               size,
               count,
               num_pts;

    IGRpoint
               Point1,       /* dummy end point IGRline struct */
               PointInWorld;

    IGRmatrix 
               WorldToView,
               ViewToWorld;

    struct   GRid  
               window;

    struct   IGRline 
               Line;

    struct   var_list   
               VariableList[2];

    struct   EX_button
               LastPoint,
               event_button;


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "> CO_ni_dist_dir_view" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Initialize data
     *           Get last point from dpb
     * ----------------------------------------------------------------------
     */

    *sts = MSSUCC;

    Line.point1 = Point1;
    Line.point2 = PointInWorld;

    size = sizeof( LastPoint );

    gr$get_last_point(  msg    =  sts,
                        sizbuf = &size,
                        buffer = &LastPoint,
                        nret   = &bytes_returned );

    _m_checkq( *sts );
    
    /* 
     * ----------------------------------------------------------------------
     *  Step 1:  Retrieve angle from ANGLE_EVENT
     *           IF   ANGLE_EVENT is a default event
     *           THEN use active angle from DPB 
     *           ELSE use the angle in ANGLE_EVENT->event.value
     * ----------------------------------------------------------------------
     */
     if ( ANGLE_SUBTYPE == GRst_DEFAULT )
     {
        /*
         *  Get Active angle
         */
        size = sizeof (IGRdouble );
        gr$get_active_angle( msg    =  sts,
                             sizbuf = &size,
                             buffer = &angle,
                             nret   = &bytes_returned );

        _m_checkq( *sts );
     }
     else
     {
        angle = ANGLE_EVENT->event.value;
     }
    
    /*
     *  Set repetion factor ( must be whole number > 0 )
     */
    num_pts = ( REPETITION_SUBTYPE == GRst_DEFAULT ) ? 1 : (IGRint) REPETITIONS;
    if ( num_pts < 1 ) 
    {
       *sts = GR_E_INVARG;
       goto quit;
    }

    /* 
     * ----------------------------------------------------------------------
     *  Step 3:  Retrieve window name
     *           IF   WINDOW_EVENT is a default event
     *           THEN use last point's window information
     *           ELSE get window info from window specified in WINDOW_EVENT
     *
     *           Information retrieved:
     *              window_hard_num
     *              window.osnum
     *              window.objid
     * ----------------------------------------------------------------------
     */

    if ( WINDOW_EVENT->subtype == GRst_DEFAULT )
    {
       /*
        * use last point's window info 
        */
       window_hard_num = LastPoint.window; 
       window.osnum     = LastPoint.osnum;
       window.objid     = LastPoint.objid;
    }
    else /*  get window information from specified window */
    {

       IGRint
          TotalNumber,
          NumberOfGrids,
          Mask = ( GG_WIN_ON | HIDDENLN_GG | IGE_GG );

       status = dp$get_gragad_id( 
                         msg         =  sts,
                         name        =  WINDOW_EVENT->event.keyin,
                         array_size  =  1,
                         total_num   = &TotalNumber,
                         type_gragad =  Mask,
                         numberofids = &NumberOfGrids,
                         found_GRids = &window );
   
       _m_check2q( status, *sts );
    
       if ( TotalNumber == 0 )
       {
          /*
           *  the expression matches no windows, 
           */
          *sts = DPNOOBJECTS;
          goto quit;
       }
       else if ( TotalNumber > 1 )
       {
          /*
           *  the expression matches too many windows, 
           *  can only use one
           */
          *sts = DPAMBIGUOUS;
          goto quit;
       }
       else /* we found a window that uniquely matched expr */
       {
    
          /*
           *  Find the hardware window number
           */
          VariableList[0].var = WIN_NO;
          VariableList[0].var_ptr = (IGRchar *) &window_hard_num;
          VariableList[0].num_bytes = sizeof( IGRint );
          VariableList[0].bytes_returned = &bytes_returned;
          VariableList[1].var = END_PARAM;
    
          status = dp$inq_set_gragad(
                             msg          =  sts,
                             gragad_objid =  window.objid,
                             which_error  = &which_error,
                             var_list     =  VariableList );
 
          _m_check2q( status, *sts );
 
       }

    }

    /* 
     * ----------------------------------------------------------------------
     *  Step 4:  Get view rotation matrix
     * ----------------------------------------------------------------------
     */

    VariableList[0].var            =  VIEW_ROTATION;
    VariableList[0].var_ptr        =  (IGRchar *) WorldToView;
    VariableList[0].num_bytes      =  sizeof( WorldToView );
    VariableList[0].bytes_returned = &bytes_returned;
    VariableList[1].var            =  END_PARAM;

    status = dp$inq_set_gragad( msg          =  sts,
                                osnum        =  window.osnum,
                                gragad_objid =  window.objid,
                                which_error  = &which_error,
                                var_list     =  VariableList );
            
    _m_check2q( status, *sts );
     
    /*
     * -----------------------------------------------------------------------
     *   Step 5:  Get ViewToWorld matrix 
     * -----------------------------------------------------------------------
     */
    dim = 4;
    b_status = MAtrnmx(  sts,
                        &dim,
                         WorldToView,
                         ViewToWorld );
    if( ( ! b_status ) || ( ! ( *sts & 1 ) ) )  goto quit;

    /*
     * -----------------------------------------------------------------------
     *   Step 6:  Calculate point in specified view's coordinate system given
     *   the distance and angle specified by user;  first a line segment is 
     *   constructed from last point to the point we want (MAlalpt) and then
     *   we extract the endpoint that we want (point2) from the resulting 
     *   line segment (Line).
     * -----------------------------------------------------------------------
     */
    Point1[0] = LastPoint.x;
    Point1[1] = LastPoint.y;
    Point1[2] = LastPoint.z;

   /*
    * -------------------------------------------------------------------
    *   Step 7:  Calculate series of data point events with PointInWorld 
    *   ( Line.point2 )
    * -------------------------------------------------------------------
    */
   size = sizeof(struct GRevent) - ( 2 * sizeof(IGRlong) ) ;
   for ( count = num_pts - 1; count >= 0; count -- )
   {
      IGRdouble        distance;
      IGRint           response = EX_DATA;
      struct GRevent   seq_event;

      distance = DISTANCE + ( count * DISTANCE );
      b_status = MAlalpt(  sts,
                           Point1,
                          &distance,
                          &angle,
                           ViewToWorld,
                          &Line );
    /* Line.point1 = Point1;
       Line.point2 = PointInWorld; */

      if( ( ! b_status ) || ( ! ( *sts & 1 ) ) ) goto quit;

      status = co$build_button( msg       =  sts,
                                x         =  PointInWorld[0],
                                y         =  PointInWorld[1],
                                z         =  PointInWorld[2],
                                window    =  window_hard_num,
                                objid     =  window.objid,
                                osnum     =  window.osnum,
                                button    = &event_button );

      _m_check2q( status, *sts );

      status = co$build_event( msg      =  sts,
                               subtype  =  GRst_DIST_DIR,
                               button   = &event_button,
                               num_val  =  2,
                               values_1 =  DISTANCE,
                               values_2 =  angle,
                               event    = &seq_event );
      /* 
       *  Put event on the software queue
       */
      status = ex$putque( msg      =  sts,
                          response = &response,
                          byte     = (IGRlong *) &size,
                          buffer   = (IGRchar *) &seq_event.event );
      _m_check2q( status, *sts );

/*
 *  Reset from point for next delta
      Point1[0] = PointInWorld[0];
      Point1[1] = PointInWorld[1];
      Point1[2] = PointInWorld[2];
 */

   }

quit:
    _m_debug_str( "< CO_ni_dist_dir_view" );
    return( MSSUCC );
}
