/*

 CO_ni_delta_world()

 Abstract:

    Non-interactive function to calculate world coordinates of a data
    point which is at a specified delta ( x, y, z rectangular ) from the
    DPB's last point with respec to the world base ( world ) coordinate
    system ( view independent ).

    Default delta for coordiantes are always zero.  If no view name is 
    specified, the default is the view of the DPB's last point.  

    Events are recognized as "defaults" if the subtype field has the
    value xxx_DEFAULT;


 Arguments:

    IGRlong          * ReturnMsg;
        return code
	   MSSUCC - always succeeds

    struct GRevent   * events[]
        an array of events.  these are usually collected by a command object.  

        Contents of Event pointer array:
        
        on entry:

          Events[1] - delta for X coordinate ( if default, use 0 )
          Events[2] - delta for Y coordinate ( if default, use 0 )
          Events[3] - delta for Z coordinate ( if default, use 0 )
          Events[4] - view name ( if default, use last point's view name )

        on exit:
          
          Events[0] -  resulting data point event ready to be stuffed on 
		       the queue


 Example call

    CO_ni_delta_world( &msg,
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
#define   X_delta         Events[1]->event.value
#define   Y_delta         Events[2]->event.value
#define   Z_delta         Events[3]->event.value
#define   WindowName      Events[4]->event.keyin

/*
 *----------------------------------------
 *   CO_ni_delta_world()
 *----------------------------------------
 */
IGRlong CO_ni_delta_world( ReturnMsg,
                             Events )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];

{

/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong    
                 ReturnStatus = MSSUCC,
                 WhichError,
                 WindowHardwareNumber,
                 BytesReturned;

    /* local x, y, and z coordiantes for new point ( Events[0] )  */
    IGRdouble  
                 X_val,
                 Y_val,
                 Z_val;

    IGRint     
                 Size,
                 ReturnSize;

    struct   GRid 
                 WindowArray,
                 WindowGrid;

    struct   var_list
                 VariableList[2];

    struct   EX_button
                 LastPoint,
                 EventButton;

/* EV - END OF VARIABLE LIST */

    _m_debug_str( "CO_ni_delta_world >" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Initialize data
     *           Get last point from dpb
     * ----------------------------------------------------------------------
     */

    *ReturnMsg = MSSUCC;

    Size = sizeof( LastPoint );

    _m_debug_str( "CO_ni_delta_world:  Calling gr$get_last_point" ); 
    gr$get_last_point(  msg    = ReturnMsg,
                        sizbuf = &Size,
                        buffer = &LastPoint,
                        nret   = &ReturnSize );

    _m_check( *ReturnMsg, 
    {
        _m_debug_str( "CO_ni_delta_world:  gr$get_last_point failed" );
        _m_debug( printf( "    msg = %x\n", *ReturnMsg ) );
        ReturnStatus = MSFAIL;
        *ReturnMsg = MSFAIL;
        goto quit;
    } );
    
    /* 
     * ----------------------------------------------------------------------
     *  Step 1:  Load specified or default X value
     * ----------------------------------------------------------------------
     */
    if ( Events[1]->subtype == GRst_DEFAULT )
    {
       X_val = LastPoint.x;
    }
    else
    {
       X_val = LastPoint.x + X_delta;
    }


    /* 
     * ----------------------------------------------------------------------
     *  Step 2:  Load specified or default Y value
     * ----------------------------------------------------------------------
     */
    if ( Events[2]->subtype == GRst_DEFAULT )
    {
       Y_val = LastPoint.y;
    }
    else
    {
       Y_val = LastPoint.y + Y_delta;
    }


    /* 
     * ----------------------------------------------------------------------
     *  Step 3:  Load specified or default Z value
     * ----------------------------------------------------------------------
     */
    if ( Events[3]->subtype == GRst_DEFAULT )
    {
       Z_val = LastPoint.z;
    }
    else
    {
       Z_val = LastPoint.z + Z_delta;
    }

    /* 
     * ----------------------------------------------------------------------
     *  Step 4:  Load specified or default Window information
     * ----------------------------------------------------------------------
     */
    if ( Events[4]->subtype == GRst_DEFAULT )
    {
       /*
        * use last point's window info 
        */
       _m_debug_str( "CO_ni_delta_world: Using default window" );
       WindowHardwareNumber = LastPoint.window; 
       WindowGrid.osnum     = LastPoint.osnum;
       WindowGrid.objid     = LastPoint.objid;
    }
    else /*  get window information from specified window */
    {

       IGRint
	  TotalNumber,
	  NumberOfGrids,
	  Mask = (GG_WIN_ON | HIDDENLN_GG | IGE_GG );

       _m_debug_str( "CO_ni_delta_world: calling dp$get_gragad_id()" );
       ReturnStatus = dp$get_gragad_id( msg         = ReturnMsg,
                                       name        =  WindowName,
				       array_size  =  1,
				       total_num   = &TotalNumber,
				       type_gragad =  Mask,
                                       numberofids = &NumberOfGrids,
                                       found_GRids = &WindowArray );
    
       _m_check2p ( ReturnStatus, *ReturnMsg,
          "CO_ni_delta_world:  dp$get_gragad_id failed" );
       _m_check2q ( ReturnStatus, *ReturnMsg );
    
       if ( TotalNumber == 0 )
       {
          /*
           *  the expression matches too many windows, 
           *  can only use one
           */
          *ReturnMsg = DPNOOBJECTS;
	  goto quit;
       }
       else if ( TotalNumber > 1 )
       {
          /*
           *  the expression matches too many windows, 
           *  can only use one
           */
          *ReturnMsg = DPAMBIGUOUS;
          goto quit;
       }
       else /* we found a window that uniquely matched expr */
       {
          WindowGrid.objid = WindowArray.objid;
          WindowGrid.osnum = WindowArray.osnum;
    
          /*
           *  Find the hardware window number
           */
          VariableList[0].var = WIN_NO;
          VariableList[0].var_ptr = (IGRchar *) &WindowHardwareNumber;
          VariableList[0].num_bytes = sizeof( IGRint );
          VariableList[0].bytes_returned = &BytesReturned;
          VariableList[1].var = END_PARAM;
    
          _m_debug_str( "CO_ni_delta_world: calling dp$inq_set_gragad()" );
          ReturnStatus = dp$inq_set_gragad( 
                            msg = ReturnMsg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );

          _m_check2p ( ReturnStatus, *ReturnMsg,
             "CO_ni_delta_world:  dp$inq_set_gragad failed" );
          _m_check2q ( ReturnStatus, *ReturnMsg );
       }
    }

    /*
     * -----------------------------------------------------------------------
     *   Step 4:  Build new world coorinate data point event 
     * -----------------------------------------------------------------------
     */
     ReturnStatus = co$build_button( msg       = ReturnMsg,
				    x         =  X_val,
				    y         =  Y_val,
				    z         =  Z_val,
                                    window    =  WindowHardwareNumber,
                                    objid     =  WindowGrid.objid,
                                    osnum     =  WindowGrid.osnum,
				    button    = &EventButton );

     _m_check2( ReturnStatus, *ReturnMsg, 
     {
        _m_debug_str( "CO_ni_delta_world: co$build_button failed" );
        goto quit;
     } );

     ReturnStatus = co$build_event( msg     = ReturnMsg,
                                   button  = &EventButton,
                                   subtype =  GRst_DELTA_WLD,
                                   event   =  Events[0] );

     _m_check2( ReturnStatus, *ReturnMsg, 
     {
        _m_debug_str( "CO_ni_delta_world: co$build_event failed" );
     } );

quit:
    _m_debug( 
       printf( "CO_ni_delta_world: on exit Status = 0x%x\n", ReturnStatus ));
    _m_debug_str( "< CO_ni_delta_world" );
    return( MSSUCC );
}
