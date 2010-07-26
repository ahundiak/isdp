/* #######################    APOGEE COMPILED   ######################## */
/* 
Name

IGRlong CO_ni_move_segment(
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
   bmr 03/11/87 : created

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

from GRlinear     import GRmoveseg;

/*----------------------------------------
 *  CO_ni_move_segement
 *----------------------------------------
 */
IGRlong CO_ni_move_segment(
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

    IGRlong                      status;         /* return code             */
    IGRdouble                    BorePoints[6];  /* points to store boreline*/
    struct IGRline               BoreLine; 
    struct GRevent               FromEvent;
    struct GRevent               ToEvent;
    IGRpoint                     proj_pt;
    struct GRparms               ref_parms;
    IGRboolean                   b_status;
    IGRuint                      NumberObjectsFound;
    OM_S_OBJECT_LINKAGE          ChannelLinkage[2];
    struct GRid                  element;

    BoreLine.point1 = &( BorePoints[0] );
    BoreLine.point2 = &( BorePoints[3] );

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

    status = co$project_event( msg     =  msg,
                               event   = &FromEvent,
                               module  =  ModuleInfo,
                               cob_id  =  my_id,
                               grid    = &element,
		               parms   = &ref_parms,
			       point   =  proj_pt );
    _m_check2q(status, *msg);


    b_status = CObrln( 
                    msg,
                    &my_id,
                    &ToEvent,
                    &BoreLine );
                                                                 
     status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRlinear.GRmoveseg( 
                              msg,
                              ModuleInfo,
                              &ref_parms,
                               proj_pt,
                             &BoreLine ),
                    grid = &element );

quit:
    return(OM_S_SUCCESS);

}

end implementation Root;
