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

IGRlong CO_ni_insert_vertex(
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
    This function inserts a vertex in a linear type element
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] identies the segment
        event[1] is the new vertex

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

History
    trc 03/08/87 : adapted to the new include file design

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




from GRgraphics import GRlnproject;
from GRcurve  import GRinsvertex;



/*----------------------------------------
 *  CO_ni_insert_vertex
 *----------------------------------------
 */
IGRlong CO_ni_insert_vertex(
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

    IGRlong             status;         /* return code                  */
    IGRdouble           BorePoints[6];  /* points to store boreline         */
    struct IGRline      BoreLine;       /* boreline for apparent project    */
    struct GRparms      AcceptParms;
    IGRboolean          b_status;
    GRobjid             NewObjid;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    /*
     *  set boreline for apparent project
     */
    BoreLine.point1 = &( BorePoints[0] );
    BoreLine.point2 = &( BorePoints[3] );


    /*
     *  project the first event onto the element
     */
    status = co$project_event(
                        msg = msg,
                        event = Events[0],
                        module = ModuleInfo,
                        parms = &AcceptParms,
                        p_chanselect = MyChannelStruct,
                        grid = ObjectsGrid );
    _m_check2p( status, *msg, "COniinsertv - failed co$project_event." );
    _m_check2q( status, *msg );



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
                                                                 

    /*
     *     modify the element
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRcurve.GRinsvertex(
                        msg,
                        ModuleInfo,
                        &AcceptParms,
                        &BoreLine,
                        &NewObjid ),
                    p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo->md_env.matrix_type,
                    matrix = ModuleInfo->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRcurve.GRinsvertex(
                        msg,
                        ModuleInfo,
                        &AcceptParms,
                        &BoreLine,
                        &NewObjid ),
                    grid = ObjectsGrid );
    }

    _m_check2p( status, *msg, "CO_ni_insert_vertex - failed insertion" );
    _m_debug_str( "CO_ni_insert_vertex - have modified the object." );

quit:
    return( status );
}

end implementation Root;
