/* #######################    APOGEE COMPILED   ######################## */
/* 

    IGRlong CO_ni_measure_angle_by_2_pts(
                msg,
                events,
                Angle,
                units)

                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    IGRdouble            *Angle;
    IGRchar              *units;

Abstract
    This function measures an angle given 2 points. The angle is
    APPARENT to the view in with the first point was entered.  This
    is NEVER a true measurement.
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] endpoint 1, defines line end point and view
        event[1] endpoint 2

    Angle 
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    Model
        sweep vector - vector endpoint1 endpoint2
        axis  vector - view vector


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
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"



extern    IGRboolean    MAang3pt();


from IGEgragad import DPinrot;
/*----------------------------------------
 *  CO_ni_measure_angle_by_2_pts
 *----------------------------------------
 */
IGRlong CO_ni_measure_angle_by_2_pts(
                msg,
                events,
                Angle,
                units)
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    IGRdouble            *Angle;
    IGRchar              *units;

{

    IGRpoint  
       SweepPoint,     /* End point of Sweep line                    */
       IsectPoint,     /* Intersection point of Sweep and Axis lines */
       AxisPoint;      /* end point of Axis line                     */

    IGRboolean  
       b_status;    
    
    struct GRid
       ViewGrid;

    IGRdouble
       Mangle[3];


   /* EV - end of local variable  declarations */

   *msg = MSSUCC;

   ViewGrid.osnum = events[0]->event.button.osnum;
   ViewGrid.objid = events[0]->event.button.objid;
    
   b_status = CO_ni_world_to_view( msg,
                                   events[0],
                                  &ViewGrid,
                                   SweepPoint );

   b_status = CO_ni_world_to_view( msg,
                                   events[1],
                                  &ViewGrid,
                                   IsectPoint );

   /*
    *  The Sweep and Isect points are now in View coordinates and projected
    *  onto the view's X/Y plane.  To get a relative X axis point, we can add
    *  1.0 to the X coordinate of the Isect point.
    */
   AxisPoint[0] = IsectPoint[0] + 1.0;  /* X */
   AxisPoint[1] = IsectPoint[1];        /* Y */
   AxisPoint[2] = IsectPoint[2];        /* Z */

   b_status = MAang3pt( msg,   
                        AxisPoint,
                        IsectPoint,
                        SweepPoint,
                        Mangle );

   *Angle = ( Mangle[0] >= PI ) ? ( Mangle[0] - PI ) : Mangle[0];

   /*
    *  we are measuring angle
    */
   strncpy( units, GRIO_ANGLE, GRIO_MAX_ALIAS_SIZE );

   return( OM_S_SUCCESS );
}

end implementation Root;
