/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRgrgrp.GRadd_to_active_owner

Description
        This method adds the graphic group components to the active owner.

Return Values
        IGRlong *msg    MSSUCC - success
                        MANOMEMORY - failure

History
        mrm     01/13/89    creation
*/

class implementation GRgrgrp;

#include "grimport.h"
#include "msdef.h"
#include "grownmacros.h"

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod)
{
    IGRint                  i;
    OMuint                  count;
    IGRlong                 sts;
    struct GRid             active_owner;
    OM_S_CHANSELECT         to_comp;
    OM_S_OBJECT_LINKAGE     buffer[64], *list;

    /*
     *  check for an active owner
     */

    sts = gr$get_active_owner (msg = msg,
                               mod_id = &mod->md_id,
                               active_owner = &active_owner);
    if (sts & *msg & 1)
    {
        /*
         *  active owner exists, get a list of the components to add
         */

        om$make_chanselect (channame = "GRcmpowner.to_components",
                            p_chanselect = &to_comp);

        om$get_channel_count (object = me,
                              p_chanselect = &to_comp,
                              count = &count);

        if ((sts & 1) && count)
        {
            if (count > 64)
            {
                i = sizeof (OM_S_OBJECT_LINKAGE) * count;
                if (!(list = (OM_S_OBJECT_LINKAGE *)om$malloc (size = i)))
                {
                    sts = OM_E_ERROR;   
                    *msg = MANOMEMORY;
                }
            }
            else
            {
                list = buffer;
            }

            if (sts & 1)
            {
                sts = om$get_channel_objects (object = me,
                                              p_chanselect = &to_comp,
                                              list = list,
                                              size = count,
                                              count = &count);
                if (sts & 1)
                {
                    for (i = 0; i < count; i++)
                    {
                        /*
                         *  add the components to the owner
                         */

                        gr$add_to_active_owner (msg = msg,
                                                mod_env = mod,
                                                objid = list[i].S_objid,
                                                osnum = list[i].osnum);
                    }
                }
            }
        }
    }
    else
    {
        /* no active owner */
        sts = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    return (sts);
}

end implementation GRgrgrp;
