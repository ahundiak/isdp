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
IGRlong COarc_to_circle(
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
    This function constructs a circle using the properties of the
    specified arc.  The original arc is deleted.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events
        the event used.  these are usually collected by
        a command object.  

        events - the arc to be converted to a circle

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
                                                                            
History
    jsd 10/16/89 : creation of the command
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

from GRconic    import GRgetarc;
from GRgraphics import GRdisplay;
from GRvg       import GRgetprops;

/*----------------------------------------
 *  COarc_to_circle
 *----------------------------------------
 */
IGRlong COarc_to_circle(
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
    IGRushort	  properties;
    IGRshort	          chan_flag=1;
    IGRshort	          del_flag=1;
    GRobjid	          new_objid;
    enum GRdpmode         display_mode = GRbd;

    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
     status = MSSUCC;
  
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
     _m_check2p( status, *msg, "COarc_to_circle - failed GRgetarc" );
     _m_check2q(status,*msg);

     status = om$send(msg = message GRvg.GRgetprops ( msg, (IGRshort *)&properties ),
		    targetid = events->located_object[0].located_obj.objid,
		    targetos = events->located_object[0].located_obj.osnum );
     _m_check2p(status,*msg,"COarc_to_circle - failed GRgetprops");
     _m_check2q(status,*msg);
       

     status = GRaltchgclass( msg,
		             module_info,
		            &events->located_object[0].located_obj.objid,
		             "GR3dcircle",
		            &properties,
		            &arc,
		            &chan_flag,
		            &del_flag,
		            &new_objid );
     _m_check2p( status, *msg, "COarc_to_circle - failed GRaltchgclass" );
     _m_check2q(status,*msg);

     status = om$send(msg = message GRgraphics.GRdisplay ( msg,
                            &module_info->md_env.matrix_type,
                             module_info->md_env.matrix,
                            &display_mode, 
                             module_grid),
                      targetid = new_objid,
                      targetos = events->located_object[0].located_obj.osnum);
     _m_check2p( status, *msg, "COarc_to_circle - failed GRdisplay" );
     _m_check2q(status,*msg);

quit:
    return ( status );
}

end implementation Root;
