/* #######################    APOGEE COMPILED   ######################## */
/* 
IGRlong CO_ni_extend_2_insect(
                msg,
                events,
                module_info,
                display_mode,
                display_grid,
                my_id,
                my_os,
                my_channel_struct;    
                objects_grid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info[];
    enum GRdpmode         display_mode;
    struct GRid          *display_grid;
    GRobjid               my_id;
    GRspacenum            my_os;
    OM_S_CHANSELECT      *my_channel_struct;    
    struct GRid          *objects_grid[];

                                                                               

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
#include "codebug.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRcurve      import GRptextend; 
from GRvg         import GRgetsize,
                         GRgetgeom;
from IGEgragad    import DPinrot; 


/*----------------------------------------
 *  CO_ni_extend_2_insect
 *----------------------------------------
 */
IGRlong CO_ni_extend_2_insect(
                msg,
                events,
                module_info,
                display_mode,
                display_grid,
                my_id,
                my_os,
                my_channel_struct,
                objects_grid)
                                                                               
    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info[];
    enum GRdpmode         display_mode;
    struct GRid          *display_grid;
    GRobjid               my_id;
    GRspacenum            my_os;
    OM_S_CHANSELECT      *my_channel_struct;    
    struct GRid          *objects_grid[];
                                                                               
{

    IGRlong                      status; 
    IGRpoint                     extend_point1;
    IGRpoint                     extend_point2;
    struct GRevent               event_on_element1;
    struct GRevent               event_on_element2;
    IGRpoint                     point_on_element1;
    IGRpoint                     point_on_element2;
    IGRpoint                     point_approx_int;
    IGRpoint                     new_end_point;
    struct GRparms               parms_on_element2;
    struct GRparms               parms_on_element1;
    IGRuint                      num_objects_found;
    OM_S_OBJECT_LINKAGE          channel_linkage[2];
    struct GRid                  element1;
    struct GRid                  element2;
    IGRvector                    view_vector;
    IGRmatrix                    rot_matrix;
    IGRboolean                   apparent_flag;
    IGRlong                      size;
    IGRlong                      ret_size;
    struct IGRbsp_curve          *curve;

    _m_debug_str("COniex2in - Extend 2 Elem to intersect");

    if ( my_channel_struct != NULL )  /* extract object from channel */
     {
       /*
        *  find out who is on my channel
        */
       status = om$get_channel_objects(
                        objid = my_id,
                        p_chanselect = my_channel_struct,
                        list = channel_linkage,
                        size = 2,
                        count = &num_objects_found );
       element1.objid = channel_linkage[0].S_objid;
       element1.osnum = channel_linkage[0].osnum;

       element2.objid = channel_linkage[1].S_objid;
       element2.osnum = channel_linkage[1].osnum;

     }
    else                            /* grid passed */
     {
        element1 = *objects_grid[0];
        element2 = *objects_grid[1];
     }


    /*
     *  pull the events out of the array
     */
    event_on_element1 = *events[0];
    event_on_element2 = *events[1];
    point_approx_int[0] = events[2]->event.button.x;
    point_approx_int[1] = events[2]->event.button.y;
    point_approx_int[2] = events[2]->event.button.z;

    /*
     * Project first point onto first object in objects_grid list
     */
    status = co$project_event( msg     =  msg,
                               event   =  &event_on_element1,
                               module  =  module_info[0],
                               cob_id  =  my_id,
                               grid    = &element1,
		               parms   = &parms_on_element1,
			       point   =  point_on_element1 );
    _m_check2q(status, *msg);

    /*
     * Project second point onto second object in objects_grid list
     */
    status = co$project_event( msg     =  msg,
                               event   =  &event_on_element2,
                               module  =  module_info[1],
                               cob_id  =  my_id,
                               grid    = &element2,
		               parms   = &parms_on_element2,
			       point   =  point_on_element2 );
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
                             &module_info[0]->md_env.matrix_type,
                              module_info[0]->md_env.matrix,
                             &size),
                        targetid = element1.objid,
                        targetos = element1.osnum );
 
       curve = (struct IGRbsp_curve *)om$malloc( size = size );

       status = om$send(msg = message GRvg.GRgetgeom(msg,         
                             &module_info[0]->md_env.matrix_type,
                              module_info[0]->md_env.matrix,
                              (IGRchar *)curve),
                        targetid = element1.objid,
                        targetos = element1.osnum);

        /* load view vector */
        status = om$send(msg = message IGEgragad.DPinrot(msg,
						         rot_matrix ),
		         senderid = NULL_OBJID,
		         targetid = event_on_element2.event.button.objid,
		         targetos = event_on_element2.event.button.osnum );
        _m_check2q(status, *msg);
      
	/* get unit view vector */
        view_vector[0] = rot_matrix[8];
        view_vector[1] = rot_matrix[9];
        view_vector[2] = rot_matrix[10];

	/* calculated apparent intersect point is ON THE FIRST ELEMENT */
	/* first call gets extend_point for first element */
        status = GR2objaisect( msg,
                             &element1,               /* extend1 grid    */
                             &module_info[0]->md_env, /* extend1 context */
                             &parms_on_element1,      /* extend1 parms   */
                             &element2,               /* extend2 obj grid   */
                             &module_info[1]->md_env, /* extend2 context    */
                             &parms_on_element2,      /* extend2 parms      */
                              point_approx_int,       /* approximate int pt*/
			      view_vector,            /* unit view vector  */
                              extend_point1 );        /* actual intersect  */
        _m_check2q(status,*msg);

	/* second call gets extend_point for second element */
        status = GR2objaisect( msg,
                             &element2,               /* extend2 grid    */
                             &module_info[1]->md_env, /* extend2 context */
                             &parms_on_element2,      /* extend2 parms   */
                             &element1,               /* extend1 obj grid   */
                             &module_info[0]->md_env, /* extend1 context    */
                             &parms_on_element1,      /* extend1 parms      */
                              point_approx_int,       /* approximate int pt*/
			      view_vector,            /* unit view vector  */
                              extend_point2 );        /* actual intersect  */
        _m_check2q(status,*msg);
    }
    else
    {
       status = GR2objisect(
                        msg,
                       &element1,
                       &module_info[0]->md_env, 
                       &parms_on_element1,
                       &element2,
                       &module_info[1]->md_env, 
                       &parms_on_element2,
                        point_approx_int,
                        extend_point1 );

       if(*msg != MAIDGENRAT)
        {
         _m_check2p( status, *msg, "COniext1int - failed GR2objisect" );
         _m_check2q( status, *msg );
        }

       /* if true intersection, use same extend point for both extensions */
       extend_point2[0] = extend_point1[0];
       extend_point2[1] = extend_point1[1];
       extend_point2[2] = extend_point1[2];
    }


    /*
     *  send to extend to object 1
     */
    status = co$erase_send_draw(
                    msg = msg,
                    matrix_type = &module_info[0]->md_env.matrix_type,
                    matrix = module_info[0]->md_env.matrix,
                    erase_obj = display_grid,
                    draw_mode = display_mode,
                    draw_obj = display_grid,
                    mesg = message GRcurve.GRptextend(msg,
                                                      module_info[0],
                                                      point_on_element1,
                                                      extend_point1,
                                                      new_end_point ),
                    grid = &element1 );
    _m_check2q( status, *msg );

    /*
     *  send to extend to object 2
     */
    status = co$erase_send_draw(msg = msg,
                            matrix_type = &module_info[1]->md_env.matrix_type,
                            matrix = module_info[1]->md_env.matrix,
                            erase_obj = display_grid,
                            draw_mode = display_mode,
                            draw_obj = display_grid,
                            mesg = message GRcurve.GRptextend(msg,
                                                              module_info[1],
                                                              point_on_element2,
                                                              extend_point2,
                                                              new_end_point ),
                            grid = &element2 );

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
