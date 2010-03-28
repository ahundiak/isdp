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
IGRlong COcomp_arc(
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

Abstract
    This function constructs the 360 degree complement of a specified arc.
    The original arc is deleted.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events
        the event used.  these are usually collected by
        a command object.  

        events - the arc

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
                                                                            
History
    jsd 10/19/89 : creation of the command
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

/*----------------------------------------
 *  COcomp_arc
 *----------------------------------------
 */
IGRlong COcomp_arc(
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
    struct IGRarc         arc;
    enum GRdpmode         display_mode = GRbd;
    struct GRpost_info    post_info;
    GRobjid               new_objid;

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
     _m_check2p( status, *msg, "COcomp_arc - failed GRgetarc" );
     _m_check2q(status,*msg);

     if ( arc.sweep_angle <= 0 )
       arc.sweep_angle = ( 2 * PI ) + arc.sweep_angle;
     else
       arc.sweep_angle = arc.sweep_angle - ( 2 * PI );

     status = om$send(msg = message GRconic.GRputarc(
                                            msg,
                                            module_info,
                                           &post_info,
                                           &arc,
                                           &new_objid ),
		     targetid = events->located_object[0].located_obj.objid,
		     targetos = events->located_object[0].located_obj.osnum );
     _m_check2p( status, *msg, "COcomp_arc - failed GRputarc" );
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
     _m_check2p( status, *msg, "COcomp_arc - failed GRdisplay" );
     _m_check2q(status,*msg);

quit:
    return ( status );
}

end implementation Root;
