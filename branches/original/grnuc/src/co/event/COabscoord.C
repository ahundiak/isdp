/* #######################    APOGEE COMPILED   ######################## */
/*

 CO_ni_abs_wld_coord()

 Abstract:

    Non-interactive function to calculate world coordinates of a data
    point which has specified X, Y, and Z coordiantes and view name.
    Default coordiante values are from the DPB's last point.  If no
    view name is specified, the default is the view of last point.  

    Events are recognized as "defaults" if the subtype field has the
    value GRst_DEFAULT;


 Arguments:

    *ReturnMsg        IGRlong
	return code 
	   MSSUCC - always succeeds

    *Events[]         struct GRevent   
        An array of events.

        on entry:

        Events[1] - X coordinate (if default or pt use last pt's X coordiante)
        Events[2] - Y coordinate (if default or pt use last pt's Y coordiante)
        Events[3] - Z coordinate (if default or pt use last pt's Z coordiante)
        Events[4] - view name (if default, use last pt's view name)

        on exit:
          
        Events[0] -  resulting DATA event ready to be stuffed on the queue


 Example call

    CO_ni_abs_wld_coord( &rc,
			  Events );

 Status returns

        MSFAIL
        MSSUCC

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
#include    "exdef.h"
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
#define   X_coordinate    Events[1]->event.value
#define   Y_coordinate    Events[2]->event.value
#define   Z_coordinate    Events[3]->event.value
#define   WindowName      Events[4]->event.keyin

/*
 *----------------------------------------
 *   CO_ni_abs_wld_coord()
 *----------------------------------------
 */

IGRlong CO_ni_abs_wld_coord( ReturnMsg,
                             Events )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];

{

/* BV - BEGINNING OF VARIABLE LIST */


    IGRlong     ReturnStatus = MSSUCC;
    IGRlong     WhichError;
    IGRlong     WindowHardwareNumber;
    IGRlong     BytesReturned;

    /* local x, y, and z coordiantes for new point ( Events[0] )  */
    IGRdouble   X_val;
    IGRdouble   Y_val;
    IGRdouble   Z_val;

    IGRint      Size;
    IGRint      ReturnSize;

    struct   GRid           WindowArray;
    struct   GRid           WindowGrid;

    struct   var_list       VariableList[2];

    struct   EX_button      LastPoint;
    struct   EX_button      EventButton;


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "CO_ni_abs_wld_coord >" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Initialize data
     *           Get last point from dpb
     * ----------------------------------------------------------------------
     */

    *ReturnMsg = MSSUCC;

    Size = sizeof( LastPoint );

    _m_debug_str( "CO_ni_abs_wld_coord:  Calling gr$get_last_point" ); 
    gr$get_last_point(  msg    = ReturnMsg,
                        sizbuf = &Size,
                        buffer = &LastPoint,
                        nret   = &ReturnSize );

    _m_check( *ReturnMsg,
    {
        _m_debug_str( "CO_ni_abs_wld_coord:  gr$get_last_point failed" );
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
       X_val = LastPoint.x;      /* default is last pt's X coordiante */
    }
    else if ( Events[1]->response == EX_DATA )
    {
       X_val = Events[1]->event.button.x;  /* X coord from data point entered */
    }
    else 
    {
       X_val = X_coordinate;
    }


    /* 
     * ----------------------------------------------------------------------
     *  Step 2:  Load specified or default Y value
     * ----------------------------------------------------------------------
     */
    if ( Events[2]->subtype == GRst_DEFAULT )
    {
       Y_val = LastPoint.y;      /* default is last pt's Y coordiante */
    }
    else if ( Events[2]->response == EX_DATA )
    {
       Y_val = Events[2]->event.button.y;  /* Y coord from data point entered */
    }
    else
    {
       Y_val = Y_coordinate;
    }


    /* 
     * ----------------------------------------------------------------------
     *  Step 3:  Load specified or default Z value
     * ----------------------------------------------------------------------
     */
    if ( Events[3]->subtype == GRst_DEFAULT )
    {
       Z_val = LastPoint.z;      /* default is last pt's Z coordiante */
    }
    else if ( Events[3]->response == EX_DATA )
    {
       Z_val = Events[3]->event.button.z;  /* Z coord from data point entered */
    }
    else
    {
       Z_val = Z_coordinate;
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
       _m_debug_str( "CO_ni_abs_wld_coord: Using default window" );
       WindowHardwareNumber = LastPoint.window; 
       WindowGrid.osnum     = LastPoint.osnum;
       WindowGrid.objid     = LastPoint.objid;
    }
    else /*  get window information from specified window */
    {

       IGRint
	  TotalNumber,
	  NumberOfGrids,
	  Mask = ( GG_WIN_ON | HIDDENLN_GG | IGE_GG );

       _m_debug_str( "CO_ni_abs_wld_coord: calling dp$get_gragad_id()" );
       ReturnStatus = dp$get_gragad_id( msg         = ReturnMsg,
                                       name        =  WindowName,
				       array_size  =  1,
				       total_num   = &TotalNumber,
				       type_gragad =  Mask,
                                       numberofids = &NumberOfGrids,
                                       found_GRids = &WindowArray );
    
       _m_check2p ( ReturnStatus, *ReturnMsg, 
          "CO_ni_abs_wld_coord:  dp$get_gragad_id failed" );
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
    
          _m_debug_str("CO_ni_abs_wld_coord: calling dp$inq_set_gragad");
          ReturnStatus = dp$inq_set_gragad( 
                            msg = ReturnMsg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );

          _m_check2p ( ReturnStatus, *ReturnMsg, 
            "CO_ni_abs_wld_coord: dp$inq_set_gragad failed");
          _m_check2q ( ReturnStatus, *ReturnMsg ); 
       }
    }

    /*
     * -----------------------------------------------------------------------
     *   Step 5:  Build new world coorinate data point event 
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
        _m_debug_str( "CO_ni_abs_wld_coord: co$build_button failed" );
        goto quit;
     } );

     ReturnStatus = co$build_event( msg      = ReturnMsg,
                                    button   = &EventButton,
                                    subtype  =  GRst_PREC_WLD,
                                    event    =  Events[0] );

     _m_check2( ReturnStatus, *ReturnMsg, 
     {
        _m_debug_str( "CO_ni_abs_wld_coord: co$build_event failed" );
     } );


quit:
    _m_debug_str( "< CO_ni_abs_wld_coord" );

    return( MSSUCC );
}
