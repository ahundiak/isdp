/*

 CO_ni_delta_view()

 Abstract:

    Non-interactive function to calculate world coordinates of a data
    point which is at a specified delta ( x, y, z rectangular ) from the
    DPB's last point in a specified view.

    Default delta for coordiantes are always zero.  If no view name is 
    specified, the default is the view of the DPB's last point.  

    Events are recognized as "defaults" if the subtype field has the
    value GRst_DEFAULT;


 Arguments:

    IGRlong          *sts;
        return code
	   MSSUCC - always succeeds

    struct GRevent   * events[]
        an array of events.  these are usually collected by a command object.  

        Contents of Event pointer array:
        
        on entry:

          events[0] -  NOT USED as of 1.3.0 GRNUC

          events[1] - delta for X coordinate ( if default, use 0 )
          events[2] - delta for Y coordinate ( if default, use 0 )
          events[3] - delta for Z coordinate ( if default, use 0 )
          events[4] - repetition factor ( if default, use 1 )
          events[5] - view name ( if default, use last point's view name )

 Example call

    CO_ni_delta_view(  &msg,
		       events )

 Caveats:

 History:
     
    srh  06/09/87  -  Created;
    dhm  07/14/92  -  ANSI conversion.                         
 */

/*   EH -  End of Header  */

#include "coimport.h"
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

/* 
 * rename event fields for convenience 
 */
#define   X_DELTA          events[1]->event.value
#define   Y_DELTA          events[2]->event.value
#define   Z_DELTA          events[3]->event.value
#define   REPETITIONS      events[4]->event.value
#define   WINDOW_NAME      events[5]->event.keyin

#define   DEFAULT_X_DELTA  events[1]->subtype == GRst_DEFAULT
#define   DEFAULT_Y_DELTA  events[2]->subtype == GRst_DEFAULT
#define   DEFAULT_Z_DELTA  events[3]->subtype == GRst_DEFAULT
#define   DEFAULT_REPS     events[4]->subtype == GRst_DEFAULT
#define   DEFAULT_VIEW     events[5]->subtype == GRst_DEFAULT
/*
 *----------------------------------------
 *   CO_ni_delta_view()
 *----------------------------------------
 */
IGRlong CO_ni_delta_view( sts,
                          events )

    IGRlong              *sts;
    struct GRevent       *events[];

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRboolean 
               b_status;

    IGRshort
	       dim;

    IGRint  
               size,
               return_size,
	       count,
	       repetition_factor;

    IGRlong
               status = MSSUCC,
               which_error,
               number_of_pts = 1,
               window_hard_num,
               ret_bytes;

    IGRmatrix
               world_to_view,
               view_to_world;

    struct GRid 
               window;

    struct var_list 
               var_list[2];

    IGRpoint
	       origin_view_pt,
	       world_pt;

    struct EX_button  
               last_point,
               event_button;


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "CO_ni_delta_view >" );

    /* 
     * ----------------------------------------------------------------
     *  Get last point from dpb
     * ----------------------------------------------------------------
     */

    *sts = MSSUCC;

    size = sizeof( last_point );

    gr$get_last_point(  msg    = sts,
                        sizbuf = &size,
                        buffer = &last_point,
                        nret   = &return_size );
    _m_checkq ( *sts );
    

    /*  Initialize world_pt from last_point */
    world_pt[0] = last_point.x;
    world_pt[1] = last_point.y;
    world_pt[2] = last_point.z;

    /* 
     * -----------------------------------------------------------------
     *  Load specified or default Window information
     * -----------------------------------------------------------------
     */
    if ( DEFAULT_VIEW  )
    {
       /*
        * use last point's window info 
        */
       window_hard_num = last_point.window; 
       window.osnum    = last_point.osnum;
       window.objid    = last_point.objid;
    }
    else /*  get window information from specified window */
    {

       IGRint
	  total,
	  nbr_grids,
	  

       status = dp$get_gragad_id(
		   msg         =  sts,
                   name        =  WINDOW_NAME,
		   array_size  =  1,
		   total_num   = &total,
		   type_gragad =  ( GG_WIN_ON | HIDDENLN_GG | IGE_GG ),
                   numberofids = &nbr_grids,
                   found_GRids = &window  );

       _m_check2q ( status, *sts ); 
    
       if ( total == 0 )
       {
          /*
           *  the expression matches too many windows, 
           *  can only use one
           */
          *sts = DPNOOBJECTS;
          goto quit;
       }
       else if ( total > 1 )
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
          var_list[0].var = WIN_NO;
          var_list[0].var_ptr = (char *) &window_hard_num;
          var_list[0].num_bytes = sizeof( IGRint );
          var_list[0].bytes_returned = &ret_bytes;
          var_list[1].var = END_PARAM;
    
          status = dp$inq_set_gragad( 
                            msg = sts,
                            gragad_objid = window.objid,
                            which_error = &which_error,
                            var_list = var_list );
          _m_check2q ( status, *sts );
       }
    }

    /* 
     * ---------------------------------------------------------------
     *  Get view rotation matrix (world_to_view) and view_to_world matrix
     * ---------------------------------------------------------------
     */

    var_list[0].var            =  VIEW_ROTATION;
    var_list[0].var_ptr        =  (char *) world_to_view;
    var_list[0].num_bytes      =  sizeof( world_to_view );
    var_list[0].bytes_returned = &ret_bytes;
    var_list[1].var            =  END_PARAM;

    status = dp$inq_set_gragad( msg          = sts,
                                osnum        =  window.osnum,
                                gragad_objid =  window.objid,
                                which_error  = &which_error,
                                var_list     =  var_list );
    _m_check2q ( status, *sts );
     
    /*
     *  get view to world matrix 
     */
    dim = 4;
    b_status = MAinvmx( sts, 
                       &dim,
                        world_to_view,
                        view_to_world );
    if( ( ! b_status ) || ( ! ( *sts & 1 ) ) ) goto quit;


    /* 
     * -------------------------------------------------------------
     *  Transform Last point into the view's coordiante system
     * -------------------------------------------------------------
     */
    b_status = MAptsxform( sts,
                          &number_of_pts,
                           world_to_view,
                           world_pt,
                           origin_view_pt );
    if( ( ! b_status ) || ( ! ( *sts & 1 ) ) ) goto quit;

    /*
     * cast repetiton factor to integer
     */
    repetition_factor = ( DEFAULT_REPS ) ? 1 : (IGRint) REPETITIONS;

    size = sizeof( struct GRevent ) - (2 * sizeof( IGRint ));

    for ( count = repetition_factor; count > 0; count -- )
    {
    
       IGRint           response = EX_DATA;
       struct GRevent   seq_event;
       IGRpoint         delta_view_pt;
       /* 
        * --------------------------------------------------------------
        *  Adjust Lastpoint ( in view ) by specified deltas
	*  It is REAL important to put these points on the SEQ in reverse
	*  order so that they are retrieved in the correct order!!!!!
        * --------------------------------------------------------------
        */
       delta_view_pt[0] = 
	  ( DEFAULT_X_DELTA ) ? origin_view_pt[0]
			      : origin_view_pt[0] + (count * X_DELTA);
   
       delta_view_pt[1] = 
	  ( DEFAULT_Y_DELTA ) ? origin_view_pt[1]
			      : origin_view_pt[1] + (count * Y_DELTA);
   
       delta_view_pt[2] = 
	  ( DEFAULT_Z_DELTA ) ? origin_view_pt[2]
			      : origin_view_pt[2] + (count * Z_DELTA);

       /*
        * -------------------------------------------------------------
        *   Transform world_pt back to world coordiantes
        * -------------------------------------------------------------
        */
       b_status = MAptsxform( sts,
                             &number_of_pts,
                              view_to_world,
                              delta_view_pt,
                              world_pt );
       if( ( ! b_status ) || ( ! ( *sts & 1 ) ) ) goto quit;

       /*
        * -----------------------------------------------------------
        *   Build new world coorinate data point event 
        * -----------------------------------------------------------
        */
       status = co$build_button( msg       =  sts,
				 x         =  world_pt[0],
				 y         =  world_pt[1],
				 z         =  world_pt[2],
                                 window    =  window_hard_num,
                                 objid     =  window.objid,
                                 osnum     =  window.osnum,
				 button    = &event_button );
       _m_check2q( status, *sts );

       status = co$build_event( msg     =  sts,
                                button  = &event_button,
                                subtype =  GRst_DELTA_VIEW,
                                event   = &seq_event );
       /* 
        *  Put event on the software queue
        */
       status = ex$putque( msg      =  sts,
                           response = &response,
                           byte     = (IGRlong *) &size,
                           buffer   = (IGRchar *) &seq_event.event );
       _m_check2q( status, *sts );

    }
quit:
    _m_debug_str( "< CO_ni_delta_view" );
    return( MSSUCC );
}
