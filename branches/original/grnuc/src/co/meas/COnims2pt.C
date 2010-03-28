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

    IGRlong CO_ni_measure_distance_btwn_2pts(
                ReturnMsg,
                Events,
                Distance,
                Units );
                                                                               
    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    IGRdouble            *Distance;
    IGRchar              *Units;
                                                                               

Abstract
    This function measures the distance between two points
                                                                            
Arguments

    ReturnMsg
        return codes

    Events
        an array of events.  these are usually collected by
        a command object.  

        Events[0] is the from point
        Events[1] is the to point

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    Distance
        value of everything that we measure

Status returns

    om return codes

History
    trc 03/19/87 : created
    srh 11/19/87 : added apparent measuremant code

*/

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"

#define  p_FirstEvent    Events[0]
#define  p_SecondEvent   Events[1]




/*
 * ----------------------------------------
 *  CO_ni_measure_distance_btwn_2pts
 * ----------------------------------------
 */
IGRlong CO_ni_measure_distance_btwn_2pts(
                ReturnMsg,
                Events,
                Distance,
                Units )
                                                                               
    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    IGRdouble            *Distance;
    IGRchar              *Units;
                                                                               
{
    IGRint
                BufferSize = sizeof( IGRboolean ),  /* sizeof ApparentFlag */
                ReturnSize;

    IGRlong   
                ReturnStatus = MSSUCC;   /* return code                    */

    IGRboolean
                BooleanStatus,
                ApparentFlag;

    IGRpoint    
                FirstPoint,              /* first point                    */
                SecondPoint;             /* second point                   */

    struct GRevent
                ModifiedSecondEvent;     /* Second event with window info  */
                                         /*  from first event              */

    /*  EV */


    _m_debug_str( "> CO_ni_measure_distance_btwn_2pts" );

    /*
     *  determine if the measurement is true of apparent
     */
    _m_debug_str( 
       "  CO_ni_measure_distance_btwn_2pts: calling gr$get_apparent_flag" );
#ifndef IDRAW

    ReturnStatus = gr$get_apparent_flag( msg    = ReturnMsg,
                                         sizbuf = &BufferSize,
                                         buffer = &ApparentFlag,
                                         nret   = &ReturnSize );
#else 
    ApparentFlag = 0;
#endif /* IDRAW */

    if( ApparentFlag )
    {
#ifndef IDRAW
       /*
        *  Project first point onto view plane where it was entered
        */
       _m_debug_str( 
          "  CO_ni_measure_distance_btwn_2pts: projecting first point" );
       BooleanStatus = COproj_pt_to_view_pl( ReturnMsg,
                                             p_FirstEvent,
                                             FirstPoint );
       _m_check_boolp( BooleanStatus, 
          "  CO_ni_measure_distance_btwn_2pts: COproj_pt_to_view_pl FAILED" );
       _m_check_boolq( BooleanStatus );

       /*
        *  Project second point onto view plane where the first 
        *  point was entered;
        *
        *  Copy window info from the first point into ModifiedSecondEvent;
        *  this assures that we project the two points onto the same view
        *  plane
        */
       ModifiedSecondEvent = *p_FirstEvent;

       /*
        * copy coordinates from the second point into ModifiedSecondEvent
        */
       ModifiedSecondEvent.event.button.x = p_SecondEvent->event.button.x;
       ModifiedSecondEvent.event.button.y = p_SecondEvent->event.button.y;
       ModifiedSecondEvent.event.button.z = p_SecondEvent->event.button.z;

       _m_debug_str( 
          "  CO_ni_measure_distance_btwn_2pts: projecting second point" );
       BooleanStatus = COproj_pt_to_view_pl( ReturnMsg,
                                            &ModifiedSecondEvent,
                                             SecondPoint );
       _m_check_boolp( BooleanStatus, 
          "  CO_ni_measure_distance_btwn_2pts: COproj_pt_to_view_pl FAILED" );
       _m_check_boolq( BooleanStatus );
#endif /* IDRAW */

    }
    else
    {
       /*
        *  Use the absolute ( true ) coordinates of the two data point events
        */
       FirstPoint[0]  = p_FirstEvent->event.button.x;
       FirstPoint[1]  = p_FirstEvent->event.button.y;
       FirstPoint[2]  = p_FirstEvent->event.button.z;

       SecondPoint[0] = p_SecondEvent->event.button.x;
       SecondPoint[1] = p_SecondEvent->event.button.y;
       SecondPoint[2] = p_SecondEvent->event.button.z;

    }

    /*
     * convert coordiantes to active CS before measuring the distance
     */
/* Do not convert to active coordiante system since it  create problem if the 
   active coordinate system is  not rectangular -Inasu */
   
/*
    ReturnStatus = COcvt_pts_to_lcl_coord( ReturnMsg,
                                           1,
                                           FirstPoint,
                                           FirstPoint);

    ReturnStatus = COcvt_pts_to_lcl_coord( ReturnMsg,
                                           1,
                                           SecondPoint,
                                           SecondPoint );

*/
    /*
     *  calculate the distance between the two points.
     */
    ReturnStatus = MA2ptdis( ReturnMsg,
                             FirstPoint,
                             SecondPoint,
                             Distance );


    _m_check2p( ReturnStatus, *ReturnMsg, 
                "CO_ni_measure_distance_btwn_2pts - failed MA2ptdis" );


    /*
     *  we are measuring distance
     */
    strncpy( Units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );

quit:
    _m_debug_str( "< CO_ni_measure_distance_btwn_2pts" );

    return( ReturnStatus );

}
