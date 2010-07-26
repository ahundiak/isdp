/*
Name
        GRgrset.GSinit 

Keywords
        graphic-set

Description
        This method is used to initialize the graphics set.

Synopsis
        IGRlong         *msg           return code
        IGRint          *properties    The properties of the set
        struct GRid     *owner_id      Owner object.
        OM_p_CHANSELECT owner_chansel  Channel of the owner object.

Notes
        If the owner_chansel is NULL then no channel connections are
        attempted.

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        Gray Winn   11/02/86    Creation date.
        mrm         01/25/93    use tag connect to avoid dangling ISOs
*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

extern OMuword OPP_GRgrset_class_id;

method GSinit (IGRlong *msg; 
               IGRint *properties;
               struct GRid *owner_id; 
               OM_p_CHANSELECT owner_chansel)
{
    IGRint              use_tag_connect = FALSE;
    IGRlong             sts;
    OMuword             prev_os, dummy_os, classid;
    OMuint              prev_tagcon_state, dummy_tag;
    OM_S_CHANSELECT     to_owner_sel;

    *msg = MSSUCC;
    to_owner_sel.type = OM_e_name;
    to_owner_sel.u_sel.name = "GRgrset.to_owners";

    /*
     *  Set the properties of the graphics set.
     */

    me->properties = *properties;

    /*
     *  Connect to the owners channel.
     */

    if (owner_chansel)
    {
        if (owner_id->osnum != OM_Gw_current_OS)
        {
            /*  
                This is a transos connection - check whether this operation is
                connecting a graphic set to a command object or a save set.
            */

            om$get_classid(osnum = owner_id->osnum,
                           objid = owner_id->objid,
                           p_classid = &classid);

            sts = om$is_ancestry_valid(subclassid = classid,
                                       superclassid = OPP_GRgrset_class_id);
            if (sts & 1)
            {
                /* 
                    This is a trans-os grset-svset connection.  Use a tag
                    connection to avoid any chance of a dangling ISO should a
                    command forget to clean out all the graphic set objects.
                    Make sure both objects are tagged.  The object in the
                    reference file *must* have the tag to avoid ISO
                    connections.  The object in the master file does not
                    necessarily have to have the tag, but it doesn't hurt to
                    put it there just in case.  The return status from
                    om$add_tag is ignored; someone may have turned off tagging
                    for a valid reason.
                */

                use_tag_connect = TRUE;

                prev_tagcon_state = om$enable_tag_connects(flag = TRUE);

                om$set_tag_os(p_prev_osnum = &prev_os, 
                              osnum = OM_Gw_current_OS);

                if (om$objid_to_tag(p_tag = &dummy_tag) == OM_W_NOTTAGGED)
                    om$add_tag(p_tag = &dummy_tag);

                if (om$objid_to_tag(osnum = owner_id->osnum,
                                    objid = owner_id->objid,
                                    p_tag = &dummy_tag) == OM_W_NOTTAGGED)
                    om$add_tag(osnum = owner_id->osnum,
                               objid = owner_id->objid,
                               p_tag = &dummy_tag);
            }
        }

        /* Connect the set to the specified owner. */

        sts = om$send(msg = message Root.connect(to_owner_sel, NULL, 
                                                 owner_id->objid, 
                                                 owner_id->osnum, 
                                                 *owner_chansel, NULL),
                      senderid = my_id,
                      targetid = my_id);

        if (use_tag_connect)
        {
            /* Restore the previous tagging context. */

            if (prev_tagcon_state)
                om$set_tag_os(p_prev_osnum = &dummy_os, osnum = prev_os);
            else
                om$enable_tag_connects(flag = FALSE);
        }
    }
    
    return ( OM_S_SUCCESS );
}

end implementation GRgrset;
