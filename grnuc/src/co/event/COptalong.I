/* #######################    APOGEE COMPILED   ######################## */

/*
 Name

 IGRlong CO_ni_pt_along_element( ReturnMsg,
                                 Events[] )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];

 Abstract:

    Non-interactive function to generate a data point event which is at
    a specified distance along an element from a given start point.


 Arguments

    *ReturnMsg
        return codes
           OM_S_SUCCESS
           OM_E_INVARG
           OM_E_NODYNMEM
           OM_E_NOSUCHOS

    Events 
        an array of events.  these are usually collected by
        a command object.  

        on entry:

          Events[1] - distance along element
          Events[2] - located element and start point
          Events[3] - direction point

        on exit:

          Events[0] - resulting data point event; by convention, the first
                      event always returns the event to be placed on the
                      software queue.


 Status returns

        MSSUCC
        MSFAIL


 History
    srh 07/20/87 : creation date

 Caveats

 */

/*   EH -  End of Header  */


class implementation Root;


#include "coimport.h"
#include    "codebug.h"
#include    "OMminimum.h"
#include    "OMprimitives.h"
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

#define  SEQ_Event        Events[0]               /* returned */

#define  DistanceEvent    Events[1]
#define  Distance         DistanceEvent->event.value

#define  AcceptEvent      Events[2]
#define  Element          AcceptEvent->located_object[0]
#define  ElementGrid      AcceptEvent->located_object[0].located_obj
#define  FromParms        AcceptEvent->located_object[0].geom_parms

#define  ModuleInfo       AcceptEvent->located_object[0].module_info
#define  Matrix           ModuleInfo.md_env.matrix
#define  MatrixType       ModuleInfo.md_env.matrix_type

#define  DirectionEvent   Events[3]
#define  DirectionButton  DirectionEvent->event.button
#define  DirectionParms   DirectionEvent->located_object[0].geom_parms


from GRcurve  import 
                      GRptalong;



/*
 * ---------------------------------------------------------------------
 *                        CO_ni_pt_along_element
 * ---------------------------------------------------------------------
 */

IGRlong CO_ni_pt_along_element( ReturnMsg,
                                Events )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
{

/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong     
       ReturnStatus = MSSUCC;

    IGRpoint
       FromPoint,
       DirectionPoint,
       OutPoint;

    struct   EX_button
       EventButton;

/* EV - END OF VARIABLE LIST */



    _m_debug_str( "> CO_ni_pt_along_element" );

    /*
     * ----------------------------------------------------------------------
     *  Step 1:  Send to the graphic object to project the accept point
     *           onto itself
     * ----------------------------------------------------------------------
     */
    _m_debug_str( "  CO_ni_pt_along_element: projecting From point" );
    ReturnStatus = co$project_event( msg    =  ReturnMsg,
                                     event  =  AcceptEvent,
                                     module = &ModuleInfo,
                                     cob_id =  NULL_OBJID,
                                     grid   = &ElementGrid,
		                     parms  = &FromParms,
		                     point  =  FromPoint );
    
    _m_check2p( ReturnStatus, *ReturnMsg,
		" CO_ni_pt_along_element: co$project_event FAILED" );
    _m_check2q( ReturnStatus, *ReturnMsg );


    /*
     * ----------------------------------------------------------------------
     *  Step 2:  Send to the graphic object to project the direction point
     *           onto itself
     * ----------------------------------------------------------------------
     */
    _m_debug_str( "  CO_ni_pt_along_element: projecting direction point" );
    ReturnStatus = co$project_event( msg    =  ReturnMsg,
                                     event  =  DirectionEvent,
                                     module = &ModuleInfo,
                                     cob_id =  NULL_OBJID,
                                     grid   = &ElementGrid,
		                     parms  = &DirectionParms,
		                     point  =  DirectionPoint );
    
    _m_check2p( ReturnStatus, *ReturnMsg,
		" CO_ni_pt_along_element: co$project_event FAILED" );
    _m_check2q( ReturnStatus, *ReturnMsg );

    /* 
     * ----------------------------------------------------------------------
     *  Step 3:  Setup parameters for message send to the located object
     * ----------------------------------------------------------------------
     */
    ReturnStatus = om$send( msg = message GRcurve.GRptalong (
                                  ReturnMsg,
                                 &MatrixType,
                                  Matrix,
                                  FromPoint,
                                  DirectionPoint,
                                 &FromParms,
                                 &DirectionParms,
                                 &Distance,
                                  OutPoint ),
                 senderid = NULL_OBJID,
                 targetid = ElementGrid.objid,
                 targetos = ElementGrid.osnum );

    _m_check2p( ReturnStatus, *ReturnMsg, "COptspdis : GRptalong failed" );
    _m_check2q( ReturnStatus, *ReturnMsg );
    _m_debug( printf( "COptspdis:  The point along element is\n" );
	      printf( "  X = %f\n", OutPoint[0] );
	      printf( "  Y = %f\n", OutPoint[1] );
	      printf( "  Z = %f\n", OutPoint[2] ) );

    /* 
     * ----------------------------------------------------------------------
     *  Step 4:  Build event structure to go on software queue
     * ----------------------------------------------------------------------
     */
    ReturnStatus = co$build_button( 
		       msg    =  ReturnMsg,
                       x      =  OutPoint[0],
                       y      =  OutPoint[1],
                       z      =  OutPoint[2],
                       osnum  =  DirectionButton.osnum,
		       objid  =  DirectionButton.objid,
                       button = &EventButton );

    _m_check2p( ReturnStatus, *ReturnMsg, 
          "CO_ni_pt_along_element: co$build_button failed" );
    _m_check2q( ReturnStatus, *ReturnMsg );


    ReturnStatus = co$build_event( 
                       msg              =  ReturnMsg,
                       button           = &EventButton,
                       subtype          =  GRst_AT_SPEC_DIST,
                       num_id           =  1,
                       num_val          =  1,
                       values_1         =  Distance,
                       located_object_1 = &Element,
                       event            =  SEQ_Event );

    _m_check2p( ReturnStatus, *ReturnMsg,
        "CO_ni_pt_along_element: co$build_event failed" );


quit:
    _m_check2p( ReturnStatus, *ReturnMsg, "CO_ni_pt_along_element: on exit");
    _m_debug_str( "< CO_ni_pt_along_element" );

    return( ReturnStatus );
}

end implementation Root;


