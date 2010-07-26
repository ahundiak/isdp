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

/*
    Name

    IGRlong DYrbcircle( 
                Events,
                display,
                router_pointer,
                NumberOfEvents,
                EventToReplace )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  
extern    IGRboolean    (*router_pointer)();
    IGRshort                     NumberOfEvents;
    IGRlong                     EventToReplace;

                                                                            
Abstract
    This routine does rubberbanding for all circle commands.
    Passed in are a pointer to a router function, the number of events,
    and which event is to be replaced.
                                                                            
Arguments

    Events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the center point.

    display
        color, style, weight, etc. of display

    router_pointer
        a pointer to the router function that will calculate the
        circle's bspline based on the input events.

    NumberOfEvents
        number of events that will be passed to the router

    EventToReplace
        which event in the array will be replaced with the cursor
        position.  Some routers are used by different commands,
        and will replace different positions in the array.
        The event to replace may not be the zeroth event.

Example call

    DYrbcircle( 
                events,
                &ME.COconst->ActiveDisplay,
                GRcr3pt,
                2,
                1 );

Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    trc 3/13/86 : creation date
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
#include "msdef.h"
#include "madef.h"
#include "codef.h"
#include "igrdef.h"
#include "exdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dpstruct.h"
#include "igrmacros.h"
#include "dpmacros.h"



extern    IGRint    DYcircledyn();



struct DYcircle_params
{
    IGRboolean    (*router_pointer)();
    IGRshort                 NumberOfEvents;
    IGRlong                 EventToReplace;
    struct GRevent           **Events;
    struct DPele_header    *circle;
};





IGRlong DYrbcircle( 
                Events,
                display,
                router_pointer,
                NumberOfEvents,
                EventToReplace )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  /* Active symbologies     */
    IGRboolean    (*router_pointer)();
    IGRshort                     NumberOfEvents;
    IGRlong                     EventToReplace;

{
/* BV - BEGINNING OF VARIABLES, USED FOR SEARCHING */

    struct DPele_header       element;
    struct DYcircle_params    DYinfo;
    struct IGResbc            CircleSpecific;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a circle using 
     *  eddie jennings macro
     */
    GRconic_declare( circle, CirclePolesetc );

/* EV - END OF VARIABLES, USED FOR SEARCHING */


    /*
     *  initialize the poles, weights, knots pointers in the bspline 
     *  using the macro defined by eddie jennings
     */
    GRconic_init( circle, CirclePolesetc );


    _m_debug( 
        printf( "DYrbcircle - NumberOfEvents %d.\n", NumberOfEvents );
        printf( "DYrbcircle - EventToReplace %d.\n", EventToReplace );
    );
    if ( EventToReplace == 0 )
    {
        *Events[0] = *Events[1];
        Events[0]->response = DATA;
        Events[0]->subtype = GRst_REGULAR;
    }
    else
    {
        *Events[EventToReplace] = *Events[0];
        Events[EventToReplace]->subtype = GRst_REGULAR;
    }


    CircleSpecific.is_polydis = FALSE;
    CircleSpecific.is_curvedis = TRUE;

    dp$build_dis_buffer(
                    buffer = &element,
                    display_att = display,
                    geometry = &circle,
                    ele_spec_att = &CircleSpecific );

    DYinfo.Events = Events;
    DYinfo.router_pointer = router_pointer;
    DYinfo.EventToReplace = EventToReplace;
    DYinfo.NumberOfEvents = NumberOfEvents;
    DYinfo.circle = &element;

    dp$dynamics( 
                dyn_fun = DYcircledyn,
                information = &DYinfo );
    return(TRUE);
}


IGRint DYcircledyn( 
                DYinfo,
                Cursor,
                RotationMatrix,
                objects,
                num_objects,
                buffers,
                 num_buffers,
                dummy_in1,
                dummy_in2,
                dummy_in3,
                dummy_out1,
                dummy_out2,
                dummy_out3 )

        struct DYcircle_params  *DYinfo;
        struct EX_button        *Cursor;
        IGRdouble               *RotationMatrix;
        struct GRid             **objects;
        IGRint                  *num_objects;
        struct DPele_header     **buffers;
        IGRint                  *num_buffers;

        IGRchar                 *dummy_in1;
        IGRchar                 *dummy_in2;
        IGRchar                 *dummy_in3;

        IGRchar                 **dummy_out1;
        IGRchar                 **dummy_out2;
        IGRchar                 **dummy_out3;

{
    IGRboolean    b_status = TRUE;
    IGRlong       msg = MSSUCC;

    /*
     *  store the cursor information
     */
    DYinfo->Events[DYinfo->EventToReplace]->event.button = *Cursor;

    
    /*  
     *  ROUTER:
     *  Construct the nurb form of a circle given
     *  the data point events.  Special construction
     *  points are handled by this router.
     */
    _m_debug_str( "DYcircle - Calling router_pointer Router." );
    b_status = DYinfo->router_pointer( 
                    &msg,
                    DYinfo->Events,
                    &DYinfo->NumberOfEvents,
                    DYinfo->circle->geometry.bspcurve );
    _m_check_boolp( b_status, "DYcircle - failed in router_pointer." );
    _m_check_boolq( b_status );
    _m_checkp( msg, "DYcircle - failed in router_pointer." );
    _m_checkq( msg );


    *buffers = DYinfo->circle;
    *num_buffers = 1;

quit:
    return( (b_status && !COERROR( msg ))  ?  MSSUCC : MSFAIL );
}
