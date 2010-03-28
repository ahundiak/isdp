/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRconstruct

Description
    This method is used to perform the initilization of the drawing 
    border.

    *arglist       struct GRvg_construct   Structure used to contain 
                                          arguments for construction.

History
    Gray Winn   08/24/88    Design date.
\*/

class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"
#include "OMmacros.h"

method GRconstruct (struct GRvg_construct *arglist )
{
    IGRlong                          om_msg;
    IGRlong                          ret_msg;
    IGRint                           num_comp;
/*    IGRint                           size; */
    struct GRdsborder_class_attr     *class_attr;
    struct GRobj_env                 obj_env[2];

    *arglist->msg = MSSUCC;
    om_msg = OM_S_SUCCESS;
    class_attr = (struct  GRdsborder_class_attr *)arglist->class_attr;

    me->properties = arglist->properties | GRIS_NEW;

    if (arglist->name) 
    {
        om_msg = om$send( msg = message GRvg.GRputname ( arglist->msg,
                                                         arglist->name),
                          targetid = my_id);
    }

    if (arglist->class_attr) 
    {
        me->owner_properties = class_attr->proj_angle | GR_ORPHAN;

        if (class_attr->desc[0] != '\0') 
        {
            om$vla_set_dimension(varray = me->desc, size = strlen(class_attr->desc) + 1);
            strcpy (me->desc, class_attr->desc);
        }

        obj_env[0].mod_env = *(arglist->env_info);
        obj_env[0].obj_id = class_attr->polygon_id;

        if (class_attr->border_id.objid == NULL_OBJID) num_comp = 1;
        else 
        {
            num_comp = 2;
            obj_env[1].mod_env = *(arglist->env_info);
            obj_env[1].obj_id = class_attr->border_id;
        }

        om_msg = om$send ( msg = message GRowner.GRadd_components ( &ret_msg,
                                                                    arglist->env_info, 
                                                                    &num_comp, 
                                                                    obj_env, 
                                                                    NULL, 
                                                                    NULL ),
                           targetid = my_id);
    }

    return (om_msg);
}
end implementation GRdsborder;
