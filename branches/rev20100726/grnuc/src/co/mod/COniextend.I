/* #######################    APOGEE COMPILED   ######################## */
/* 
Name

IGRlong CO_ni_extend_element(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function extends an element by a distance or to a point
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    display_obj
        id of object to display located object

    p_chanselect
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to extend

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    trc 03/06/87 : adapted to new include file design

*/
class implementation Root;

#include "coimport.h"
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
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

from GRcurve      import GRptextend, GRdisextend; 
from IGEgragad    import DPinrot;

/*----------------------------------------
 *  CO_ni_extend_element
 *----------------------------------------
 */
IGRlong CO_ni_extend_element(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               
{

    IGRlong                      status;   
    IGRpoint                     EndPoint;
    struct GRevent               FromEvent;
    struct GRevent               ToEvent;
    struct GRparms               DummyParms;
    IGRuint                      NumberObjectsFound;
    OM_S_OBJECT_LINKAGE          ChannelLinkage[1];
    struct GRid                  element;

    if ( MyChannelStruct != NULL )  /* extract object from channel */
     {
       /*
        *  find out who is on my channel
        */
       status = om$get_channel_objects(
                        objid = my_id,
                        p_chanselect = MyChannelStruct,
                        list = ChannelLinkage,
                        size = 1,
                        count = &NumberObjectsFound );
       element.objid = ChannelLinkage[0].S_objid;
       element.osnum = ChannelLinkage[0].osnum;
     }
    else                            /* grid passed */
     {
        element = *ObjectsGrid;
     }

    /*
     *  pull the events out of the array
     */
    FromEvent = *Events[0];
    ToEvent   = *Events[1];


     /*
     *  send to the graphic object to project
     *  the accept point onto the graphic object
     *  
     */
    status = co$project_event( msg     =  msg,
                               event   = &FromEvent,
                               module  =  ModuleInfo,
                               cob_id  =  my_id,
                               grid    = &element,
		               parms   = &DummyParms,
			       point   =  EndPoint);
    _m_check2q(status, *msg);

    /*
     *  if the ToEvent is a value, then use disextend,
     *  otherwise, use extend
     */
    if ( ToEvent.response == VALUE )
    {

            status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRcurve.GRdisextend( 
                        msg,
                        ModuleInfo,
                        EndPoint,
                       &ToEvent.event.value,
                        EndPoint ),
                    grid = &element );

    }

    else

    {
        IGRpoint ToPoint; /* point to which to extend object */

        /*
         *  extract the destination point from the destination event
         */
        ToPoint[0] = ToEvent.event.button.x;
        ToPoint[1] = ToEvent.event.button.y;
        ToPoint[2] = ToEvent.event.button.z;

        status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRcurve.GRptextend(
                        msg,
                        ModuleInfo,
                        EndPoint,
                        ToPoint,
                        EndPoint ),
                    grid = &element );

        }


quit:
    return(status);
}

end implementation Root;
