/*
Name
        GSobject_add 

Keywords
        graphic-set

Description
        This method is used to add an object to an existing graphics set.

Synopsis
        IGRlong *msg                return code
        struct GRid *obj_id         The object id of the object to be
                                    added to the save set.
        struct GRmd_env *path       Structure containing the new module
                                    environment.
        IGRint *env_properties      environment properties.
        struct GRid *target_id      The object id of the owner.
        OM_p_CHANSELECT target_sel  The channel to connect the graphics set to.

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        Gray Winn    11/02/86    Creation date.
        msm          07/10/92    ANSI-C conversion.
        mrm          01/25/93    use tag connect to avoid dangling ISOs
*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsmacros.h"
#include "grgsdef.h"

from GRconnector import GRflexconn;

method GSobject_add(IGRlong *msg; 
                    struct GRid *obj_id;
                    struct GRmd_env *path; 
                    IGRint *env_properties;
                    struct GRid *target_id; 
                    OM_p_CHANSELECT target_sel)
{
    IGRint            use_tag_connect = FALSE;
    IGRlong           sts;
    IGRlong           ret_msg;
    IGRlong           connect_flag;
    IGRlong           index;
    OMuword           prev_os, dummy_os;
    OMuint            prev_tagcon_state, dummy_tag;
    OM_S_CHANSELECT   to_owners_sel;
    struct GRid       my_GRid;

    *msg = MSSUCC;
    connect_flag = 1;           /* Override */
    index = OM_K_MAXINT;   
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    to_owners_sel.type = OM_e_name;
    to_owners_sel.u_sel.name = "GRgrset.to_owners";

    me->path = *path;
    me->properties |= *env_properties & GSIS_SV_PROP_MASK;

    sts = gr$gsis_graphics_set(msg = &ret_msg, object_id = obj_id);

    if (sts & ret_msg & 1)
    {
        if (obj_id->osnum != target_id->osnum)
        {
            /* 
                This is a trans-os grset-svset connection.  Use a tag
                connection to avoid any chance of a dangling ISO should a
                command forget to clean out all the graphic set objects.  Make
                sure both objects are tagged.  The object in the reference
                file *must* have the tag to avoid ISO connections.  The object
                in the master file does not necessarily have to have the tag,
                but it doesn't hurt to put it there just in case.  The return
                status from om$add_tag is ignored; someone may have turned off
                tagging for a valid reason.
            */

            use_tag_connect = TRUE;

            prev_tagcon_state = om$enable_tag_connects(flag = TRUE);

            om$set_tag_os(p_prev_osnum = &prev_os, 
                          osnum = OM_Gw_current_OS);

            if (om$objid_to_tag(osnum = obj_id->osnum,
                                objid = obj_id->objid,
                                p_tag = &dummy_tag) == OM_W_NOTTAGGED)
                om$add_tag(osnum = obj_id->osnum,
                           objid = obj_id->objid,
                           p_tag = &dummy_tag);

            if (om$objid_to_tag(osnum = target_id->osnum,
                                objid = target_id->objid,
                                p_tag = &dummy_tag) == OM_W_NOTTAGGED)
                om$add_tag(osnum = target_id->osnum,
                           objid = target_id->objid,
                           p_tag = &dummy_tag);
        }

        /* Connect the set to the specified owner. */

        sts = om$send(msg = message Root.connect(*target_sel,
                                                 OM_K_MAXINT, 
                                                 obj_id->objid,
                                                 obj_id->osnum,
                                                 to_owners_sel,
                                                 OM_K_MAXINT),
                      targetid = target_id->objid,
                      targetos = target_id->osnum);

        if (use_tag_connect)
        {
            /* Restore the previous tagging context. */

            if (prev_tagcon_state)
                om$set_tag_os(p_prev_osnum = &dummy_os, osnum = prev_os);
            else
                om$enable_tag_connects(flag = FALSE);
        }
    }
    else
    {
        /*
         *  The object is not a graphics set. Add the object to the save set.
         */

        sts = om$send(msg = message GRconnector.GRflexconn(&ret_msg, 
                                                           &connect_flag,
                                                           &my_GRid,
                                                           &index,
                                                           &index), 
                      targetid = obj_id->objid, 
                      targetos = obj_id->osnum);
    }
    return (sts);
}

end implementation GRsvset;
