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

Version 2.2
Date extracted 8/11/87 - 10:38:40
Date current version created 8/7/87 - 13:07:27
*/ 

class implementation Root;

#include "coimport.h"
#include "codebug.h"

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "madef.h"
#include "msdef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "igrmacros.h"
#include "comiscmac.h"


/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from IGEgragad import DPinrot;




/*----------------------------------------
 *  COelnptrtr
 *----------------------------------------
 */
IGRboolean COelnptrtr( 
                    msg,
                    Events,
                    NumberOfEvents,
                    ellipse )


    IGRlong              *msg;
    struct GRevent       *Events[];
    IGRshort              *NumberOfEvents;
    struct IGRbsp_curve  *ellipse;

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong             status;         /* return code             */
    IGRboolean          b_status = 1;   /* return status           */
    IGRmatrix           RotationMatrix; /* rotation mtx from view  */
    IGRvector           DirectionVector;/* direct vector for block */
    IGRpoint            point1;
    IGRpoint            point2;
    IGRpoint            point3;
    struct IGRbsp_curve block;
    IGRdouble           PoleBuffer[15];  /* stub poles for bspline  */
    IGRdouble           KnotBuffer[15];  /* stub knots for bspline  */
    struct GRevent     *LocalEvents[3];
    struct GRevent      Event1;
    struct GRevent      Event2;
    struct GRevent      Event3;
    IGRshort             LocalNumberOfEvents = 3;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "COelnptrtr." );

    /*
     *  set up msg and status
     */
    *msg        = MSSUCC;
    status      = OM_S_SUCCESS;
    block.poles = PoleBuffer;         
    block.knots = KnotBuffer;


    point1[0] = Events[0]->event.button.x;
    point1[1] = Events[0]->event.button.y;
    point1[2] = Events[0]->event.button.z;

    point2[0] = Events[1]->event.button.x;
    point2[1] = Events[1]->event.button.y;
    point2[2] = Events[1]->event.button.z;


    /*
     *  construct a box.
     */
    if ( *NumberOfEvents == 2 )
    {
        _m_debug_str( "COelnptrtr - sending IGRgragad.DPinrot." );
        status = om$send(
                msg = message IGEgragad.DPinrot(
                    msg,
                    RotationMatrix ),
                senderid = NULL_OBJID,
                targetid = Events[0]->event.button.objid,
                targetos = Events[0]->event.button.osnum );
        _m_checkp( *msg, "COelnptrtr - failed in IGEgrad.DPinrot." );
        _m_checkq( *msg );
        _m_debug_str( "COelnptrtr - sent IGRgragad.DPinrot." );

        DirectionVector[0] = RotationMatrix[4];
        DirectionVector[1] = RotationMatrix[5];
        DirectionVector[2] = RotationMatrix[6];

        _m_debug_str( "COelnptrtr - calling MA2ptrcconstr." );
        b_status = MA2ptrcconstr(
                            msg,
                            point1,
                            point2,
                            DirectionVector,
                            &block ); 
        _m_check_boolp( b_status,"COelnptrtr - failed in MA2ptrcconstr." );
        _m_check_boolq( b_status );
        _m_checkp( *msg, "COelnptrtr - failed in MA2ptrcconstr." );
        _m_checkq( *msg );
    }
    else if ( *NumberOfEvents == 3 )
    {
        point3[0] = Events[2]->event.button.x;
        point3[1] = Events[2]->event.button.y;
        point3[2] = Events[2]->event.button.z;


        _m_debug_str( "COelnptrtr - calling MA3ptrcconstr." );
        b_status = MA3ptrcconstr(
                            msg,
                            point1,
                            point3,
                            point2,
                            &block );
        _m_check_boolp( b_status,"COelnptrtr - failed in MA3ptrcconstr.");
        _m_check_boolq( b_status );
        _m_checkp( *msg, "COelnptrtr - failed in MA3ptrcconstr." );
        _m_checkq( *msg );
    }
    else  /* bad number of inputs */
    {
        _m_debug_str( "COelnptrtr - *NumberOfEvents isnt 2 or 3." );
        *msg = MSFAIL;
        return( FALSE );
    }


    /*
     *  use the point in the block to construct the ellipse two
     *  axis points, and a point on the edge.  all of these points
     *  are midpoints along the edges of the blocks.
     */
    LocalEvents[0] = &Event1;
    LocalEvents[1] = &Event2;
    LocalEvents[2] = &Event3;
    *LocalEvents[0] = *Events[0];
    *LocalEvents[1] = *Events[1];
    *LocalEvents[2] = *Events[1];

    LocalEvents[0]->event.button.x = ( PoleBuffer[0] + PoleBuffer[3] ) / 2;
    LocalEvents[0]->event.button.y = ( PoleBuffer[1] + PoleBuffer[4] ) / 2;
    LocalEvents[0]->event.button.z = ( PoleBuffer[2] + PoleBuffer[5] ) / 2;

    LocalEvents[1]->event.button.x = ( PoleBuffer[6] + PoleBuffer[9]  ) / 2;
    LocalEvents[1]->event.button.y = ( PoleBuffer[7] + PoleBuffer[10] ) / 2;
    LocalEvents[1]->event.button.z = ( PoleBuffer[8] + PoleBuffer[11] ) / 2;

    LocalEvents[2]->event.button.x = ( PoleBuffer[3] + PoleBuffer[6] ) / 2;
    LocalEvents[2]->event.button.y = ( PoleBuffer[4] + PoleBuffer[7] ) / 2;
    LocalEvents[2]->event.button.z = ( PoleBuffer[5] + PoleBuffer[8] ) / 2;

    _m_debug_str( "COelnptrtr - calling GRelaxaxpt." );
    b_status = GRelaxaxpt(
                        msg,
                        LocalEvents,
                        &LocalNumberOfEvents,
                        ellipse );
    _m_check_boolp( b_status,"COelnptrtr - failed in GRelaxaxpt.");
    _m_check_boolq( b_status );
    _m_checkp( *msg, "COelnptrtr - failed in GRelaxaxpt." );
    _m_checkq( *msg );

quit:
    return ( b_status );
}

end implementation Root;
