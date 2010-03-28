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

IGRlong CO_ni_delete_vertex(
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
    This function deletes a vertex off of an element
                                                                            
Arguments

    msg
        return codes

    events
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the point near the vertex

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    DisplayMode
        redraw the element in hilite or not, or at least how

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
    trc 03/06/87 : adapted to new include file design

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"


#include "OMminimum.h"
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


                                                                 


/*----------------------------------------
 *   imports
 *----------------------------------------
 */
from GRlinear   import  GRdelvertex, GRvtadjseg;
from GRgraphics import GRlnproject;


                                                                 
IGRlong CO_ni_delete_vertex(
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
    IGRlong             status;         /* return code                      */
    IGRpoint            Vertex;         /* the vertex point to be deleted   */
    IGRpoint            InputPoint;     /* point input to function          */
    GRobjid             DummyObjid;
    struct GRparms      VertexParms;    /* parameters of vertex to delete   */
    struct GRparms      Segment1;       /* parameters of first adjacent seg */
    struct GRparms      Segment2;       /* parameters of sec adjacent seg   */
    struct GRparms      ProjectedParms; /* parameters of projected accept pt*/
    
/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */



    _m_debug_str( "CO_ni_delete_vertex." );


    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = MSSUCC;


    /*
     *  project the data point in the first event
     *  onto the element
     */
    status = co$project_event(
                        msg = msg,
                        event = Events[0],
                        module = ModuleInfo,
                        parms = &ProjectedParms,
                        p_chanselect = MyChannelStruct,
                        grid = ObjectsGrid );
    _m_check2p( status, *msg, "COnidelvert - failed co$project_event." );
    _m_check2q( status, *msg );
    _m_debug_str( "CO_ni_delete_vertex - have done co$project_event." );
                                                                 


    /*
     *  set up the accept point data
     */
    InputPoint[0] = Events[0]->event.button.x;
    InputPoint[1] = Events[0]->event.button.y;
    InputPoint[2] = Events[0]->event.button.z;


    /*
     *  send to the graphic object to find
     *  the vertex closest to the projected
     *  accept point.
     *
     *  GOAL : Vertex, Segment1, and Segment2
     */
    if ( ObjectsGrid == NULL )
    {
        status = om$send(
                    msg = message GRlinear.GRvtadjseg(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &ProjectedParms,
                        InputPoint,
                        Vertex,
                        &Segment1,
                        &Segment2 ),
                    p_chanselect = MyChannelStruct );
    }
    else /* do object send */
    {
        status = om$send(
                    msg = message GRlinear.GRvtadjseg(
                        msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &ProjectedParms,
                        InputPoint,
                        Vertex,
                        &Segment1,
                        &Segment2 ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, *msg, "CO_ni_delete_vertex - failed GRvtadjseg." );
    _m_check2q( status, *msg );
    _m_debug_str( "CO_ni_delete_vertex - have done GRvtadjseg." );


    _m_debug(
        printf( "    begin: parms %4.2f\n", Segment1.u );
        printf( "    vertex: parms %4.2f\n", ProjectedParms.u );
        printf( "    end: parms %4.2f\n", Segment2.u );
        printf( "    vertex:\n" );
        printf( "        x %4.2f\n", Vertex[0] );
        printf( "        y %4.2f\n", Vertex[1] );
        printf( "        z %4.2f\n", Vertex[2] );
    );


/* KLUDGE */
    Events[0]->event.button.x = Vertex[0];
    Events[0]->event.button.y = Vertex[1];
    Events[0]->event.button.z = Vertex[2];



    /*
     *  project the vertex
     *  onto the element
     */
/* KLUDGE */
    status = co$project_event(
                        msg = msg,
                        event = Events[0],
                        module = ModuleInfo,
                        parms = &VertexParms,
                        p_chanselect = MyChannelStruct,
                        grid = ObjectsGrid );
    _m_check2p( status, *msg, "COnidelvert - failed co$project_event." );
    _m_check2q( status, *msg );
    _m_debug_str( "CO_ni_delete_vertex - have done co$project_event." );
                                                                 


    /*
     *  we can use the geometric params of the projected
     *  point obtained from line project as the vertex params.
     */
/*    VertexParms = Segment2; */


    /*
     *  send to the graphics object to 
     *  delete the vertex we have found.
     */
    status = co$erase_send_draw(
                msg = msg,
                matrix_type = &ModuleInfo->md_env.matrix_type,
                matrix = ModuleInfo->md_env.matrix,
                erase_obj = DisplayGrid,
                draw_mode = DisplayMode,
                draw_obj = DisplayGrid,
                mesg = message GRlinear.GRdelvertex(
                    msg,
                    ModuleInfo,
                    &VertexParms,
                    &DummyObjid ),
                p_chanselect = MyChannelStruct,
                grid = ObjectsGrid );
    _m_check2p( status, *msg, "CO_ni_delete_vertex - failed GRdelvertex" );
    _m_check2q( status, *msg );
    _m_debug_str( "CO_ni_delete_vertex - have deleted vertex." );


quit:
    return( status );
}
                                                                 
end implementation Root;
                                                                 
