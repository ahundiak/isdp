/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRclhdr.GRlocate_processing

Description
        This method handles the locate processing for the cell header,
        allowing the cell header or the cell components to locate.

History
        mrm     04/24/89    creation
*/

class implementation GRclhdr;

#include "grimport.h"
#include "grownerdef.h"

%safe
static IGRint GRcomploc = FALSE;
%endsafe

/*
Name
        GRclcomplocon

Description
        This function sets, clears, or returns the value of the flag
        indicating whether cell components should be located rather than
        the cell header.  This is a fix for visible edges which should
        probably be handled through the locate filter owner flags.  Since
        the problem resulting in this fix was discovered very late in the
        delivery cycle, this fix was chosen to avoid unknown complications.

Synopsis
        IGRint GRclcomplocon (value)    The new (or current) value is returned
        IGRint value                    new value for flag
                                            0 - locate header (default)
                                            1 - locate components
                                            2 - return current value (does
                                                not change current value)
*/

IGRint GRclcomplocon (value)
IGRint value;
{
    if (value == 0)
    {
        GRcomploc = FALSE;
    }
    else if (value == 1)
    {
        GRcomploc = TRUE;
    }
    return (GRcomploc);
}

/*
Name
        GRclhdr.GRlocate_processing

Description
        This method performs the locate processing for cell headers.  In
        most cases the cell components are not locatable, so processing is
        sent to the owner class, which will handle these cases adroitly.
        In some cases, such as visible edges, the cell components are
        desired rather than the header.  Those cases are handled here.

Synopsis
        IGRlong *msg;                   return code
        struct GRlc_cvl *cvl;           module and action handler info
        struct GRlc_path *path;         locate path
        IGRint *path_position;          position of calling obj in path struct
        IGRint *owner_eligible;         owner eligibility flag
        IGRint *component_eligible;     component eligibility flag
*/

method GRlocate_processing (IGRlong *msg;
                            struct GRlc_cvl *cvl;
                            struct GRlc_path *path;
                            IGRint *path_position;
                            IGRint *owner_eligible;
                            IGRint *component_eligible)
{
    IGRint props, my_comp_eligible;
    IGRlong sts;
    struct GRlc_cvl my_cvl;

    if (!GRclcomplocon (2))
    {
        /* send to owner to locate the header */

        sts = om$send (mode = OM_e_wrt_message,
                       msg = message GRowner.GRlocate_processing
                            (msg, cvl, path, path_position, owner_eligible,
                             component_eligible),
                       targetid = my_id);
    }
    else
    {
        /* get the cell header locate properties */

        om$send (msg = message GRclhdr.GRget_locate_properties (msg, &props),
                 targetid = my_id);

        /* let the caller do anything with a prism locate - loaded gun here! */

        props &= ~GR_LC_NO_PRM_COMP;
        props |= GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE;

        /* allow rigid components to be located */

        my_cvl = *cvl;
        my_cvl.attributes.obj_attr.owner_action |= LC_RIGID_COMP;

        /* determine component locate eligibility */

        my_comp_eligible = GRcomponent_eligibility (msg, &my_cvl, path,
                                                    path_position, my_id,
                                                    OM_Gw_current_OS, props);

        /* call the GRowner-level function to complete processing */

        sts = GRowner_locate_processing1 (msg, &my_cvl, path, path_position,
                                          owner_eligible, component_eligible,
                                          my_id, OM_Gw_current_OS, props,
                                          my_comp_eligible, FALSE);
    }
    return (sts);
}

end implementation GRclhdr;
