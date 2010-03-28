/* 
Name
  COx_arc_angle

Abstract

Synopsis

    IGRlong      *msg        return codes
    struct GRevent   *events the event used.  
    			these are usually collected by
        		a command object.  
    events - the arc

Description

Return Value
        OM_S_SUCCESS            
        OM_E_INVARG             
 
Notes

Index

Keywords
 arc,modify,angle
History
    10/19/89:jsd: creation of the command
    01/19/90:jsd: added BSdmod to start and sweep angles,
		   added logic for all possible extensions
    4/9/93:Carlos M. Diaz: added prototypr for BSdmod(it was ret 0).
*/

class implementation Root;

#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
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

extern IGRlong GRabsg_del_by_objid();

from GRconic    import GRgetarc,
		       GRputarc;
from GRgraphics import GRdisplay;

double BSdmod(); 

/*----------------------------------------
 *  COx_arc_angle
 *----------------------------------------
 */
IGRlong COx_arc_angle(
                msg,
                events,
                module_info,
                module_grid,
                my_id,
                p_chanselect )

    IGRlong              *msg;
    struct GRevent       *events;
    struct GRmd_env      *module_info;
    struct GRid          *module_grid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *p_chanselect;

{
    IGRint                status;
    IGRlong               rc;
    IGRboolean            b_status;
    struct IGRarc         arc;
    enum GRdpmode         display_mode = GRbd;
    struct GRpost_info    post_info;
    GRobjid               new_objid;
    IGRdouble             endpts[6],
                          dist1,
                          dist2,
			  twopi = 2*PI;

    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
     status = MSSUCC;
     post_info.construct_flag = FALSE;
  
     if ( p_chanselect != NULL )
     {
       status = om$send(msg = message GRconic.GRgetarc(
                                              msg,
				             &module_info->md_env.matrix_type,
				              module_info->md_env.matrix,  
					     &arc ),
		        p_chanselect = p_chanselect );
     }
     else
     {
       status = om$send(msg = message GRconic.GRgetarc(
                                              msg,
				             &module_info->md_env.matrix_type,
				              module_info->md_env.matrix,  
					     &arc ),
		       targetid = events->located_object[0].located_obj.objid,
		       targetos = events->located_object[0].located_obj.osnum );
     }
     _m_check2p( status, *msg, "COx_arc_angle - failed GRgetarc" );
     _m_check2q(status,*msg);

     status = MAarendpts ( msg, &arc, endpts );
     _m_check2p( status, *msg, "COx_arc_angle - failed MAarendpts" );
     _m_check2q(status,*msg);

     b_status = MA2ptdis ( msg,
                          &events->located_object[0].proj_pnt[0],
			  &endpts[0],
			  &dist1 );

     b_status = MA2ptdis ( msg,
                          &events->located_object[0].proj_pnt[0],
			  &endpts[3],
			  &dist2 );

     if ( dist1 < dist2 )
     {
       arc.start_angle = arc.start_angle - events->event.value;
       if ( arc.start_angle < 0.0 )
	 arc.start_angle = arc.start_angle + twopi;

       arc.sweep_angle = arc.sweep_angle + events->event.value;
     }
     else
       arc.sweep_angle = arc.sweep_angle + events->event.value;

     if ( arc.sweep_angle < 0.0 )
     {
       arc.start_angle = arc.start_angle + arc.sweep_angle;
       arc.sweep_angle = -arc.sweep_angle;
     }

     arc.sweep_angle = BSdmod( arc.sweep_angle,
                               twopi,
                              &rc );

     arc.start_angle = BSdmod( arc.start_angle,
                               twopi,
                              &rc );

     _m_check2p( status, *msg, "COx_arc_angle - failed MAarendpts" );
     _m_check2q(status,*msg);

     status = om$send(msg = message GRconic.GRputarc(
                                            msg,
                                            module_info,
                                           &post_info,
                                           &arc,
                                           &new_objid ),
		     targetid = events->located_object[0].located_obj.objid,
		     targetos = events->located_object[0].located_obj.osnum );
     _m_check2p( status, *msg, "COx_arc_angle - failed GRputarc" );
     _m_check2q(status,*msg);

     status = GRabsg_del_by_objid(&events->located_object[0].located_obj.objid,
		                  &events->located_object[0].located_obj.osnum);

     status = om$send(msg = message GRgraphics.GRdisplay ( msg,
                            &module_info->md_env.matrix_type,
                             module_info->md_env.matrix,
                            &display_mode, 
                             module_grid),
                      targetid = new_objid,
                      targetos = events->located_object[0].located_obj.osnum);
     _m_check2p( status, *msg, "COx_arc_angle - failed GRdisplay" );
     _m_check2q(status,*msg);

quit:
    return ( status );
}

end implementation Root;
