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

    IGRlong CO_ni_modify_element(
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
    This function modifies an element
                                                                            
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
        object to modify

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"

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
from GRvg  import GRmodify;



/*----------------------------------------
 *  CO_ni_modify_element
 *----------------------------------------
 */
IGRlong CO_ni_modify_element(
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
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong
                status;


    struct GRparms
                AcceptParms;

    IGRboolean
                b_status;

    GRobjid
                NewObjid;

    IGRdouble
                BorePoints[6],  /* points to store boreline         */
                FromPoint[3];

    struct IGRline
                BoreLine;       /* boreline for apparent project    */

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "COnimodelem." );


    /*
     *  set up the from point data
     */
    FromPoint[0] = Events[0]->event.button.x;
    FromPoint[1] = Events[0]->event.button.y;
    FromPoint[2] = Events[0]->event.button.z;


    /*
     *  project the data point in the first event
     *  onto the element
     */
    status = co$project_event(
                        msg = msg,
                        event = Events[0],
                        module = ModuleInfo,
                        parms = &AcceptParms,
                        p_chanselect = MyChannelStruct,
                        grid = ObjectsGrid );
    _m_check2p( status, *msg, "COnimodelem - failed co$project_event." );
    _m_check2q( status, *msg );



    /*
     *  set boreline for apparent project
     */
    BoreLine.point1 = &( BorePoints[0] );
    BoreLine.point2 = &( BorePoints[3] );


    /*
     *  use brad's CObrln to find the boreline
     *  so as to do a boreline project
     *  to set up the TO point boreline
     */
    b_status = CObrln( 
                    msg,
                    &my_id,
                    Events[1],
                    &BoreLine );
    _m_check_boolp( b_status, "COnimodelem - failed CObrln." );
    _m_check_boolq( b_status );
    _m_checkp( *msg, "COnimodelem - failed CObrln." );
    _m_checkq( *msg );
                                                                 

    /*
     *     modify the element
     */
    status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRvg.GRmodify(
                        msg,
                        ModuleInfo,
                        &AcceptParms,
                        FromPoint,
                        &BoreLine,
                        &NewObjid ),
                    p_chanselect = MyChannelStruct,
                    grid = ObjectsGrid );

    _m_check2p( status, *msg, "COnimodelem - failed modify" );
    _m_debug_str( "COnimodelem - have modified the object." );

quit:
    return( status );
}

end implementation Root;
