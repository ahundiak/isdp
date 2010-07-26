/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Methods:

    make_grset
    delete_grset

Description:    

    The make_grset method constructs a graphics set from a list of elements
    and fills in an EX_OBJID event structure with the grset's id.

    The delete_grset method passes a GRdelete to all objects in that set
    and then deletes itself.

History:    

    jay wallingford     09/15/89    creation date
						  
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/
class implementation COtools;

#include <coimport.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grgsdef.h>
#include <grgs.h>
#include <grgsmacros.h>
#include <comiscmac.h>

method make_grset ( IGRint * msg;
                    struct GRid * gr_ids;
                    IGRint num;
                    struct GRevent * event )
{
    IGRint  status, size, nret;
    struct GRid gs_id;
    struct GRmd_env mod_env;
    struct EX_button button;
    
    status = OM_S_SUCCESS;
    *msg =  MSSUCC;

    /*
     * Get the current module enviroment.
     */
    size = sizeof ( struct GRmd_env );
    gr$get_module_env ( msg = msg,
                        sizbuf = &size,
                        buffer = &mod_env,
                        nret = &nret );

    /*
     * Initialize a graphics set.
     */
    status = COtool_make_set ( msg, &mod_env, gr_ids, num, &gs_id );

    if ( !(status & *msg & 1) ) goto quit;

    /*
     * Construct the event.
     */
    size = sizeof(struct EX_button);
    gr$get_last_point ( msg = msg,
                        sizbuf = &size,
                        buffer = &button,
                        nret = &nret );      

    co$build_event ( msg = msg,
                     button = &button,
                     event_response = EX_OBJID,
		     event = event );      
      
    event->located_object[0].located_obj = gs_id;

quit:

    if ( !(status & *msg & 1) ) *msg = MSFAIL;

    return ( OM_S_SUCCESS);
}

method delete_grset ( IGRint * msg; OM_S_CHANSELECT * chansel )
{
    gr$gsdelete ( msg = msg,
                  senderid = my_id,
                  senderos = OM_Gw_current_OS,
                  p_chanselect = chansel );

    return ( OM_S_SUCCESS );
}

end implementation COtools;
