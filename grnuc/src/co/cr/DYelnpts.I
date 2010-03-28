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

class implementation Root;

#include "coimport.h"
#include "codebug.h"

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "griodef.h"
#include "msdef.h"
#include "igrdef.h"
#include "codef.h"
#include "madef.h"
#include "godef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dpstruct.h"

#include "igrmacros.h"
#include "dpmacros.h"


/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from IGEgragad import DPinrot;


/*
 *  set up extern definitions for functions used
 */
%safe
extern    IGRint    DYel_by_npts();
%endsafe
extern    IGRboolean    COelnptrtr();




struct DYellipse_params 
{
    IGRshort                 NumberOfEvents;
    IGRlong                 msg;
    IGRpoint                point1;
    IGRpoint                point2;
    IGRpoint                point3;
    IGRvector               DirectionVector;
    struct GRevent        **events;
    struct DPele_header     ElementBuffers[2];
};




IGRlong DYrbel_by_npts( Events, EllipseDisplay, NumberOfEvents )

    struct GRevent             *Events[];
    struct IGRdisplay          *EllipseDisplay;  /* Active symbologies     */
    IGRshort                     NumberOfEvents;

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong                   msg;
    IGRlong                   status;
    struct DYellipse_params   DYinfo;
    struct IGResbc            BsplineSpecific;
    struct IGRbsp_curve       block;
    IGRdouble                 PoleBuffer[15];  /* stub poles for bspline  */
    IGRdouble                 KnotBuffer[15];  /* stub knots for bspline  */
    IGRmatrix                 RotationMatrix; /* rotation mtx from view  */
    struct IGRdisplay         BlockDisplay;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a bspline using 
     *  eddie jennings macro
     */
    GRconic_declare( EllipseBspline, EllipsePolesetc );


/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    /*
     *  initialize the poles, weights, knots pointers in the bspline 
     *  using the macro defined by eddie jennings
     */
    GRconic_init( EllipseBspline, EllipsePolesetc );

    _m_debug_str( "DYelnpts." );
    _m_debug(
        printf( "DYelnpts - NumberOfEvents is %d.\n", NumberOfEvents );
    );

    DYinfo.point1[0] = Events[0]->event.button.x;
    DYinfo.point1[1] = Events[0]->event.button.y;
    DYinfo.point1[2] = Events[0]->event.button.z;
    *Events[NumberOfEvents - 1] = *Events[0];

    if ( NumberOfEvents == 2 )
    {
        _m_debug_str( "DYelnpts - sending IGRgragad.DPinrot." );
        status = om$send(
                msg = message IGEgragad.DPinrot(
                    &msg,
                    RotationMatrix ),
                senderid = NULL_OBJID,
                targetid = Events[0]->event.button.objid,
                targetos = Events[0]->event.button.osnum );
        _m_checkp( msg, "COelnptrtr - failed in IGEgrad.DPinrot." );
        _m_checkq( msg );
        _m_debug_str( "DYelnpts - sent IGRgragad.DPinrot." );

        DYinfo.DirectionVector[0] = RotationMatrix[4];
        DYinfo.DirectionVector[1] = RotationMatrix[5];
        DYinfo.DirectionVector[2] = RotationMatrix[6];
    }
    else /* if ( NumberOfEvents == 3 ) */
    {
        DYinfo.point2[0] = Events[1]->event.button.x;
        DYinfo.point2[1] = Events[1]->event.button.y;
        DYinfo.point2[2] = Events[1]->event.button.z;
    }

    block.poles                 = PoleBuffer;
    block.knots                 = KnotBuffer;
    BsplineSpecific.is_polydis  = FALSE;
    BsplineSpecific.is_curvedis = TRUE;
    DYinfo.events               = Events;
    DYinfo.NumberOfEvents       = NumberOfEvents;
    BlockDisplay.weight         = 0;
    BlockDisplay.style          = 0;

    _m_debug_str( "DYelnpts - building ellipse display buffer." );
    dp$build_dis_buffer(
                    buffer = DYinfo.ElementBuffers,
                    display_att = EllipseDisplay,
                    geometry = &EllipseBspline,
                    ele_spec_att = &BsplineSpecific );

    _m_debug_str( "DYelnpts - building block display buffer." );
    dp$build_dis_buffer(
                    buffer = &DYinfo.ElementBuffers[1],
                    display_att = &BlockDisplay,
                    geometry = &block,
                    ele_spec_att = &BsplineSpecific );

    _m_debug_str( "DYelnpts - calling DYel_by_npts." );
    dp$dynamics( 
                dyn_fun = DYel_by_npts,
                information = &DYinfo );
    _m_debug_str( "DYelnpts - back from DYel_by_npts." );

quit:
    return( OM_S_SUCCESS );
}


IGRint DYel_by_npts( 
                DYinfo,
                point,
                matrix,
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

        struct DYellipse_params      *DYinfo;
        struct EX_button             *point;
        IGRdouble                    *matrix;
        struct GRid                  **objects;
        IGRint                       *num_objects;
        struct DPele_header          **buffers;
        IGRint                       *num_buffers;

        IGRchar                      *dummy_in1;
        IGRchar                      *dummy_in2;
        IGRchar                      *dummy_in3;

        IGRchar                      **dummy_out1;
        IGRchar                      **dummy_out2;
        IGRchar                      **dummy_out3;

{
    IGRboolean b_status;

    _m_debug_str( "DYelnpts - in dynamics." );

    DYinfo->events[DYinfo->NumberOfEvents - 1]->event.button = *point;

    
    /*
     *  call the router for ellipse by two point construction
     */
    _m_debug_str( "DYelnpts - calling COelnptrtr." );
    b_status = COelnptrtr( 
                &DYinfo->msg,
                DYinfo->events,
                &DYinfo->NumberOfEvents,
                DYinfo->ElementBuffers[0].geometry.bspcurve );
    _m_check_boolp( b_status,"DYelnpts - failed in COelnptrtr.");
    _m_check_boolq( b_status );
    _m_checkp( DYinfo->msg, "DYelnpts - failed in COelnptrtr." );
    _m_checkq( DYinfo->msg );

    if ( DYinfo->NumberOfEvents == 2 )
    {
        DYinfo->point2[0] = point->x;
        DYinfo->point2[1] = point->y;
        DYinfo->point2[2] = point->z;

        _m_debug_str( "DYelnpts - calling MA2ptrcconstr." );
        b_status = MA2ptrcconstr(
                            &DYinfo->msg,
                            DYinfo->point1,
                            DYinfo->point2,
                            DYinfo->DirectionVector,
                            DYinfo->ElementBuffers[1].geometry.bspcurve );
        _m_check_boolp( b_status,"DYelnpts - failed in MA2ptrcconstr." );
        _m_check_boolq( b_status );
        _m_checkp( DYinfo->msg, "DYelnpts - failed in MA2ptrcconstr." );
        _m_checkq( DYinfo->msg );
    }
    else /* if ( DYinfo->NumberOfEvents == 3 ) */
    {
        DYinfo->point3[0] = point->x;
        DYinfo->point3[1] = point->y;
        DYinfo->point3[2] = point->z;

        _m_debug_str( "DYelnpts - calling MA3ptrcconstr." );
        b_status = MA3ptrcconstr(
                            &DYinfo->msg,
                            DYinfo->point1,
                            DYinfo->point3,
                            DYinfo->point2,
                            DYinfo->ElementBuffers[1].geometry.bspcurve );
        _m_check_boolp( b_status,"DYelnpts - failed in MA3ptrcconstr.");
        _m_check_boolq( b_status );
        _m_checkp( DYinfo->msg, "DYelnpts - failed in MA3ptrcconstr." );
        _m_checkq( DYinfo->msg );
    }
    _m_debug_str( "DYelnpts - have built the block." );

    *buffers = DYinfo->ElementBuffers;
    *num_buffers = 2;

quit:
    return( (b_status && !COERROR( DYinfo->msg )) ? MSSUCC : MSFAIL );
}

end implementation Root;
