/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRconstruct

Description
    This method is used to perform the initilization of the drawing 
    view.

    *arglist       struct GRvg_construct   Structure used to contain 
                                          arguments for construction.

History
    Gray Winn   02/15/88    Design date.
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"
#include "detaildef.h"
#include "OMmacros.h"

method GRconstruct (struct GRvg_construct *arglist )
{
    IGRlong                       om_msg;
    IGRlong                       ret_msg;
    IGRint                        channel_type;
    IGRint                        connection_type;
    struct GRid                   my_GRid;
    struct GRid                   comp_id;
    struct GRvg_construct         const_list;  
    struct GRdrawview_class_attr  *dv_class_attr;

    *arglist->msg = MSSUCC;
    om_msg = OM_S_SUCCESS;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    me->properties = arglist->properties | GRIS_NEW;
 
    if (arglist->name) 
    {
        om$send( msg = message GRvg.GRputname ( arglist->msg, 
                                                arglist->name ),
                 targetid = my_id);
    }
    
    dv_class_attr = (struct GRdrawview_class_attr *)arglist->class_attr;
    if ((!dv_class_attr) || (dv_class_attr->da_id.objid == NULL_OBJID))
    {
        const_list = *arglist;
        const_list.class_attr = (IGRchar *)&dv_class_attr->da_class_attr;
        comp_id.osnum = arglist->env_info->md_id.osnum;
        om$construct ( osnum = arglist->env_info->md_id.osnum,
                       classname = "GRdvattach", 
                       p_objid = &comp_id.objid,
                       msg = message GRgraphics.GRconstruct(&const_list));
    }
    else comp_id = dv_class_attr->da_id;

    om$send ( msg = message GRowner.GRget_channel_type ( &ret_msg,
                                                         &channel_type, 
                                                         &connection_type ), 
              targetid = my_id);

    GRconnect_object ( &ret_msg, 
                       comp_id.osnum, 
                       comp_id.objid,
                       &my_GRid, 
                       channel_type, 
                       connection_type, 
                       OM_K_MAXINT, 
                       OM_K_MAXINT );

    /*
     * see if we succeeded, and if not, delete the object.
     */
    if (! (ret_msg & *arglist->msg & 1)) 
    {
        om_msg = OM_E_ABORT;
        om$send( msg = message Root.delete(NULL), 
                 targetid = my_id );
    }
    else 
    {
        om$send ( msg = message GRowner.GRadd_to_active_owner ( &ret_msg, 
                                                                arglist->env_info ),
                  targetid = my_id);
    }
    return (om_msg);
}
end implementation GRdrawview;
