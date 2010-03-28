/* #######################    APOGEE COMPILED   ######################## */
/* 
IGRlong CO_ni_extend_1_insect(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyOs,
                MyChannelStruct;    
                ObjectsGrids )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo[];
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    GRspacenum            MyOs;
    OM_S_CHANSELECT      *MyChannelStruct;    
    struct GRid          *ObjectsGrids[];

                                                                               

Abstract
                                                                            
Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point

    struct GRmd_env   *module
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    GRspacenum        cob_os
        object space number of calling object, or at least some object

    struct GRid       *display_obj
        id of object to display located object

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    bmr 03/06/87 : adapted to the new include file design
    scw 03/22/88 : reversed the order elements are put on the channel
    jjc 01/24/90 : switched references to ModuleInfo.  [0] => [1] and 
                                                       [1] => [0]    
*/
class implementation Root;

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
#include "codebug.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "dp.h"
#include "maerr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "coimport.h"

from GRcurve      import GRptextend;
from GRvg         import GRgetsize,
                         GRgetgeom;
from IGEgragad    import DPinrot; 

/*----------------------------------------
 *  CO_ni_extend_1_insect
 *----------------------------------------
 */
IGRlong CO_ni_extend_1_insect(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyOs,
                MyChannelStruct,
                ObjectsGrid)
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo[];
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    GRspacenum            MyOs;
    OM_S_CHANSELECT      *MyChannelStruct;    
    struct GRid          *ObjectsGrid[];
                                                                               
{

    IGRlong                      status; 
    IGRpoint                     EndPoint;
    IGRpoint                     appr_intersect;
    IGRpoint                     extend_point;
    struct GRevent               FromEvent;
    struct GRevent               ToEvent;
    struct GRevent               ApproxEvent;
    struct GRparms               ToParms;
    struct GRparms               FromParms;
    IGRuint                      NumberObjectsFound;
    OM_S_OBJECT_LINKAGE          ChannelLinkage[2];
    struct GRid                  element1;
    struct GRid                  element2;
    IGRvector                    view_vector;
    IGRmatrix                    rot_matrix;
    IGRboolean                   apparent_flag;
    IGRlong                      size;
    IGRlong                      ret_size;
    struct IGRbsp_curve          *curve;
    IGRpoint                     tmp_pt;

    _m_debug_str("COniex1in.");

    if ( MyChannelStruct != NULL )  /* extract object from channel */
     {
       /*
        *  find out who is on my channel
        */
       status = om$get_channel_objects(
                        objid = my_id,
                        p_chanselect = MyChannelStruct,
                        list = ChannelLinkage,
                        size = 2,
                        count = &NumberObjectsFound );
       element2.objid = ChannelLinkage[0].S_objid;
       element2.osnum = ChannelLinkage[0].osnum;

       element1.objid = ChannelLinkage[1].S_objid;
       element1.osnum = ChannelLinkage[1].osnum;

     }
    else                            /* grid passed */
     {
        element2 = *ObjectsGrid[0]; /* intersect element */
        element1 = *ObjectsGrid[1]; /* element to extend */
     }

    /*
     *  pull the events out of the array
     */
    FromEvent = *Events[0];  /* element to extend */
    ToEvent   = *Events[1];  /* intersect element */


    /* approx intersect */
    ApproxEvent = *Events[2]; 


    /*
     *  pull out approximate intersection point 
     */
    appr_intersect[0] = Events[2]->event.button.x;
    appr_intersect[1] = Events[2]->event.button.y;
    appr_intersect[2] = Events[2]->event.button.z;


    status = co$project_event( msg     =  msg,
                               event   = &FromEvent,
                               module  =  ModuleInfo[1],
                               cob_id  =  my_id,
                               grid    = &element1,
		               parms   = &FromParms,
			       point   =  EndPoint );
    _m_check2q(status, *msg);


    /*
     * Project second point onto second object in ObjectsGrid list
     */
    status = co$project_event( msg     =  msg,
                               event   = &ApproxEvent,
                               module  =  ModuleInfo[0],
                               cob_id  =  my_id,
                               grid    = &element2,
		               parms   = &ToParms,
			       point   =  tmp_pt );
    _m_check2q(status, *msg);

    /*
     *  Compute intersection
     */
    size = sizeof(apparent_flag);
    status = gr$get_apparent_flag(msg = msg,
				  sizbuf = &size,
				  buffer = &apparent_flag,
				  nret= &ret_size);
    if(apparent_flag)
    {
       status = om$send(msg = message GRvg.GRgetsize(msg,
                             &ModuleInfo[1]->md_env.matrix_type,
                              ModuleInfo[1]->md_env.matrix,
                             &size),
                        targetid = element1.objid,
                        targetos = element1.osnum );
 
       curve = (struct IGRbsp_curve *)om$malloc( size = size );

       status = om$send(msg = message GRvg.GRgetgeom(msg,         
                             &ModuleInfo[1]->md_env.matrix_type,
                              ModuleInfo[1]->md_env.matrix,
                              (IGRchar *)curve),
                        targetid = element1.objid,
                        targetos = element1.osnum);

        /* load view vector */
        status = om$send(msg = message IGEgragad.DPinrot(msg,
						         rot_matrix ),
		         senderid = NULL_OBJID,
		         targetid = ToEvent.event.button.objid,
		         targetos = ToEvent.event.button.osnum );
        _m_check2q(status, *msg);
      
	/* get the unit view vector */
        view_vector[0] = rot_matrix[8];
        view_vector[1] = rot_matrix[9];
        view_vector[2] = rot_matrix[10];

	/* calculated apparent intersect point is ON THE FIRST ELEMENT */
        status = GR2objaisect( msg,
                             &element1,               /* extend grid        */
                             &ModuleInfo[1]->md_env,  /* extend context     */
                             &FromParms,              /* extend parms       */
                             &element2,               /* intersect grid     */
                             &ModuleInfo[0]->md_env,  /* intersect context  */
                             &ToParms,                /* intersect parms    */
                              appr_intersect,         /* approximate int pt */
			      view_vector,            /* unit view vector   */
                              extend_point );         /* actual intersect   */
        _m_check2q(status,*msg);
    }
    else
    {
        status = GR2objisect( msg,
                             &element2,               /* intersect grid    */
                             &ModuleInfo[0]->md_env,  /* intersect context */
                             &ToParms,                /* intersect parms   */
                             &element1,               /* extend obj grid   */
                             &ModuleInfo[1]->md_env,  /* extend context    */
                             &FromParms,              /* extend parms      */
                              appr_intersect,         /* approximate int pt*/
                              extend_point );         /* actual intersect  */
       if(*msg != MAIDGENRAT)
        {
         _m_check2p( status, *msg, "COniext1int - failed GR2objisect" );
         _m_check2q( status,*msg);
        }
    }


    /*
     *  send to the object to get it to extend itself
     */

    status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &ModuleInfo[1]->md_env.matrix_type,
                    matrix = ModuleInfo[1]->md_env.matrix,
                    erase_obj = DisplayGrid,
                    draw_mode = DisplayMode,
                    draw_obj = DisplayGrid,
                    mesg = message GRcurve.GRptextend( msg,
                                                       ModuleInfo[1],
                                                       EndPoint,
                                                       extend_point,
                                                       EndPoint ),
                    grid = &element1 );
quit:
    /* COB error checking detects an error only on MSFAIL
     * therefore all errors must be returned as MSFAIL.  This
     * was implemented because of the possible presence of
     * MANOSOLUTION from the GR2objinsect function.
     */
    if (!(*msg & 1)) *msg = MSFAIL;

    return(status);
}

end implementation Root;
