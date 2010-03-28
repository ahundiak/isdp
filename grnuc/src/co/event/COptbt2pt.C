/* #######################    APOGEE COMPILED   ######################## */
/*
    CO_ni_point_between_2_points


    Abstract:  This event generator command can be used to place a point
               on the software queue which is at a given distance from
               a given point and in the direction of a given second point.

    Arguments:

       ReturnMsg      *IGRlong
          return message
             MSSUCC
             MSFAIL

       Events         *struct GRevent[]
          array of events that supply information needed to make the variable
          assignment.

             Events[0]  -  Point to be placed on event queue
             Events[1]  -  Distance
             Events[2]  -  First (origin) point
             Events[3]  -  Second (direction) point

    Returns:

       MSSUCC
       MSFAIL

    Sample Call:

       status = CO_ni_point_between_2_pts( &msg, Events);

*/
#include "coimport.h"
#include     "codebug.h"

#include     "OMminimum.h"
#include     "OMprimitives.h"

#include     "igrtypedef.h"   
#include     "igetypedef.h"
#include     "msdef.h"
#include     "godef.h"
#include     "griodef.h"
#include     "dpdef.h"

#include     "igr.h"
#include     "gr.h"
#include     "igrdp.h"
#include     "go.h"
#include     "ex.h"
#include     "grio.h"
#include     "dp.h"

#include     "griomacros.h"
#include     "comiscmac.h"
#include     "exmacros.h"
#include     "grdpbmacros.h"
#include     "dpmacros.h"
#include     "igrmacros.h"


# define ReturnPoint    Events[0]
# define Distance       Events[1]->event.value
# define StartPoint     Events[2]->event.button
# define DirPoint       Events[3]->event.button


IGRlong CO_ni_point_between_2_pts( ReturnMsg, Events)

    IGRint             *ReturnMsg;
    struct GRevent     *Events[];

{
    IGRlong
       ReturnStatus = MSSUCC;

    IGRboolean
       b_status = TRUE;

    IGRshort
       direction = 1;

    struct IGRline
       Line;

    IGRpoint
       OutPoint,
       Point1,
       Point2;


    /*  EV - end of local variables  */

    
    Point1[0] = StartPoint.x;
    Point1[1] = StartPoint.y;
    Point1[2] = StartPoint.z;

    Point2[0] = DirPoint.x;
    Point2[1] = DirPoint.y;
    Point2[2] = DirPoint.z;

    Line.point1 = Point1;
    Line.point2 = Point2;

    b_status = MAptalln(
                     ReturnMsg,
		     &Line,
		     Point1,
		     &direction,
		     &Distance,
		     OutPoint );

    if ( !b_status )
    {
	ReturnStatus = MSFAIL;
    }

    /*
     *  Build event containing the calculated data point
     *  and put it in the front of the software queue.
    */

    ReturnPoint->event.button.x = OutPoint[0];
    ReturnPoint->event.button.y = OutPoint[1];
    ReturnPoint->event.button.z = OutPoint[2];

    ReturnPoint->event.button.window = StartPoint.window;
    ReturnPoint->event.button.objid = StartPoint.objid;
    ReturnPoint->event.button.osnum = StartPoint.osnum;


    ReturnPoint->event.button.numb = StartPoint.numb;
    ReturnPoint->event.button.clicks = StartPoint.clicks;
    ReturnPoint->event.button.button_down = StartPoint.button_down;
 
    ReturnPoint->response = EX_DATA;

    ReturnPoint->subtype = GRst_AT_DIST_2_PTS;
    ReturnPoint->num_id = 0;
    ReturnPoint->num_val = 1;
    ReturnPoint->values[0] = Distance;

    return ( ReturnStatus );
}

