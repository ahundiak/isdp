/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRconstruct

Description
    This method is used to perform the initilization of the drawing 
    sheet.

    *arglist       struct GRvg_construct   Structure used to contain 
                                           arguments for construction.

History
    Gray Winn   02/15/88    Design date.
\*/

class implementation GRdrawsheet;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"
#include "detaildef.h"
#include "exmacros.h"
#include "OMmacros.h"

method GRconstruct (struct GRvg_construct *arglist )
{
    IGRlong                          om_msg;
    IGRlong                          ret_msg;
    IGRint                           one = 1;
    struct GRdrawsheet_class_attr    *class_attr;
    struct GRvg_construct            const_list;
    struct GRid                      db_id;
    struct GRid                      my_GRid;
    struct GRobj_env                 obj_env;

    *arglist->msg = MSSUCC;
    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;
    om_msg = OM_S_SUCCESS;
    class_attr = (struct GRdrawsheet_class_attr *)(arglist->class_attr);

    me->properties = arglist->properties | GRIS_NEW;

    if (arglist->name) 
    {
        om_msg = om$send( msg = message GRvg.GRputname( arglist->msg, 
                                                        arglist->name ),
                          targetid = my_id);
    }

    if (arglist->class_attr) 
    {
        if (class_attr->db_id.objid == NULL_OBJID) 
        {
            /*
             *  Construct the drawing border object.
             */
            const_list.msg = arglist->msg;
            const_list.newflag = FALSE;
            const_list.env_info = arglist->env_info;
            const_list.properties = arglist->properties;
            const_list.geometry = NULL;
            const_list.display = NULL;
            const_list.level = NULL;
            const_list.name = NULL;
            const_list.class_attr = (IGRchar *)&class_attr->db_class_attr;

            db_id.osnum = arglist->env_info->md_id.osnum;
            om$construct ( osnum = arglist->env_info->md_id.osnum,
                           classname = "GRdsborder", 
                           p_objid = &db_id.objid,
                           msg = message GRgraphics.GRconstruct( &const_list ));

            obj_env.mod_env = *(arglist->env_info);
            obj_env.obj_id = db_id;
        }
        else 
        {
            obj_env.mod_env = *(arglist->env_info);
            obj_env.obj_id = class_attr->db_id;
        }

        om_msg = om$send ( msg = message GRowner.GRadd_components ( &ret_msg,
                                                                    arglist->env_info, 
                                                                    &one, 
                                                                    &obj_env, 
                                                                    NULL, 
                                                                    NULL),
                           targetid = my_id);
    }

    om$send ( msg = message GRowner.GRadd_to_active_owner ( &ret_msg,
                                                            arglist->env_info ), 
              targetid = my_id);

    return (om_msg);
}
end implementation GRdrawsheet;
