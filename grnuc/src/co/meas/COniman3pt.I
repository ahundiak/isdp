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

    IGRlong CO_ni_measure_angle_by_3_pts(
                msg,
                events,
                Angle,
                units)

                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    IGRdouble            *Angle;
    IGRchar              *units;

Abstract
    This function measures a angle given 3 points.
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] endpoint 1
        event[1] vertex point
        event[2] endpoint 2

    Angle 
        Angle of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used


Status returns

    om error codes

History
    bmr 05/06/87 : created

*/
class implementation Root;


#include "coimport.h"
#include "OMminimum.h"
#include "OMerrordef.h"
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
#include "madef.h"
#include "bsdefs.h" /* for ABS macro */
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

extern  IGRboolean  CO_ni_world_to_view();
extern  IGRboolean  MAang3pt();


/*----------------------------------------
 *  CO_ni_measure_angle_by_3_pts(
 *----------------------------------------
 */
IGRlong CO_ni_measure_angle_by_3_pts(
                msg,
                events,
                Angle,
                units)
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    IGRdouble            *Angle;
    IGRchar              *units;

{

    IGRpoint            sweep_point,    /* start point on the curve         */
                        middle_point,   /* another point                    */
                        axis_point;      /* end point on the curve           */

    IGRdouble           Mangle[3]; /* for MAang3pt */

    IGRboolean          b_status,
                        apparent_flag;

    IGRlong             size,
                        status = MSSUCC,
                        ret_size;

   *msg = MSSUCC;

#ifndef IDRAW
    size = sizeof(apparent_flag);
    status = gr$get_apparent_flag( msg    = msg,
	   	                   sizbuf = &size,
   		                   buffer = &apparent_flag,
		                   nret   = &ret_size );
#else 
    apparent_flag = 0;

#endif /* IDRAW */

    if(apparent_flag)
    {
#ifndef IDRAW

       struct GRid         ViewGrid;


       ViewGrid.objid = events[0]->event.button.objid;
       ViewGrid.osnum = events[0]->event.button.osnum;

       b_status = CO_ni_world_to_view(  msg,
                                        events[0],
                                       &ViewGrid,
                                        sweep_point);

       if ( !b_status ) { status = MSFAIL; goto quit; }

       b_status = CO_ni_world_to_view(  msg,
                                        events[1],
                                       &ViewGrid,
                                        middle_point);

       if ( !b_status ) { status = MSFAIL; goto quit; }

       b_status = CO_ni_world_to_view(  msg,
                                        events[2],
                                       &ViewGrid,
                                        axis_point);

       if ( !b_status ) { status = MSFAIL; goto quit; }
#endif /* IDRAW */
    }
    else
    {
       sweep_point[0] = events[0]->event.button.x;
       sweep_point[1] = events[0]->event.button.y;
       sweep_point[2] = events[0]->event.button.z;  

       middle_point[0] = events[1]->event.button.x;
       middle_point[1] = events[1]->event.button.y;
       middle_point[2] = events[1]->event.button.z;  

       axis_point[0] = events[2]->event.button.x;
       axis_point[1] = events[2]->event.button.y;
       axis_point[2] = events[2]->event.button.z;  
    }

    b_status = MAang3pt( msg,   
			 axis_point,
			 middle_point,
			 sweep_point,
			 Mangle );

    *Angle = ( Mangle[0] >= PI ) ? ( Mangle[0] - PI ) : Mangle[0];

    /*
     *  we are measuring angle
     */
    strncpy( units, GRIO_ANGLE, GRIO_MAX_ALIAS_SIZE );

quit:
    return( status );
}

end implementation Root;

