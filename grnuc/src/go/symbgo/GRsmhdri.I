/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRsmhdr.xxx

Description
        This file contains several short methods for the symbol header class.

Notes
        The methods included here are:
            GRget_context
            GRget_matrix
            GRownaddwrng
            GRownremwrng
            GRget_channel_type
            GRget_locate_properties
            GRchg_locate_properties
            GRget_owner_properties
            GRadd_to_active_owner
*/

class implementation GRsmhdr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "dpmacros.h"
#include "grownerdef.h"
#include "grownmacros.h"

/*
Name
        GRget_context

Description
        This method is used to get the module environment to be used by the
        components.

Synopsis
        IGRlong *msg                    completion code
        struct GRmd_env *mod_env        the input module environment
        struct GRmd_env *cmp_mod_env    the world module environment

Return Values
        MSSUCC         if successful
        MSFAIL         if failure

History
        Gray Winn   11/04/87    Creation date
        scw         07/23/92    ansi conversion
*/

method GRget_context (IGRlong *msg; struct GRmd_env *mod_env;
                      struct GRmd_env *cmp_mod_env)
{
    IGRint           i;                  /* index for GRgetabsg      */
    struct IGRlbsys  *absgptr;           /* pointer to abstract geom */

    *msg = MSSUCC;

    *cmp_mod_env = *mod_env;
    GRgetabsg (msg, &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
               (IGRchar **)&absgptr, i);   
    for (i = 0; i < 16; ++i)
    {
        cmp_mod_env->md_env.matrix[i] = absgptr->matrix[i];
    }
    MAtypemx (msg, cmp_mod_env->md_env.matrix,
              &cmp_mod_env->md_env.matrix_type);
    return (OM_S_SUCCESS);
}


/*
Name
        GRget_matrix

Description
        This method is used to get the matrix and matrix type to be used by
        the components.

Synopsis
        IGRlong *msg                completion code
        IGRshort *matrix_type       matrix type
        IGRmatrix matrix            matrix
        IGRshort *cmp_matrix_type   component matrix type
        IGRmatrix cmp_matrix        component matrix

Return Values
        MSSUCC         if successful
        MSFAIL         if failure

History
        Gray Winn   11/04/87    Creation date
        scw         07/23/92    ansi conversion
*/

method GRget_matrix (IGRlong *msg; IGRshort *matrix_type; 
                     IGRmatrix matrix; IGRshort *cmp_matrix_type;
                     IGRmatrix cmp_matrix)
{
    IGRint           i;                  /* index for GRgetabsg      */
    struct IGRlbsys  *absgptr;           /* pointer to abstract geom */

    *msg = MSSUCC;
    GRgetabsg (msg, matrix_type, matrix, (IGRchar **)&absgptr, i);
    for (i = 0; i < 16; ++i)
    {
        cmp_matrix[i] = absgptr->matrix[i];
    }
    MAtypemx (msg, cmp_matrix, cmp_matrix_type);
    return (OM_S_SUCCESS);
}

/*
Name
        GRownaddwrng

Description
        This method adds a component of an owner to the rtree with respect 
        to range.

Synopsis
        IGRlong *msg                completion code
        struct GRmd_env *mod_env    environment information
        GRobjid *objid              objid of the component
        GRrange range               range of component object

Return Values
        MSSUCC - always succeeds
*/

method GRownaddwrng (IGRlong *msg; struct GRmd_env *mod_evn;
                     GRobjid *objid; GRrange range)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

/*
Name
        GRownremwrng

Description
        This method removes a component of an owner from the rtree with 
        respect to range.

Synopsis
        IGRlong *msg                completion code
        struct GRmd_env *mod_env    environment information
        GRobjid *objid              objid of the component
        GRrange range               range of component object

Return Values
        MSSUCC - always succeeds

History
        HGW     07/21/86    Design Date and Creation Date
        scw     07/23/92    ansi conversion
*/

method GRownremwrng (IGRlong *msg; struct GRmd_env *mod_env;
                     GRobjid *objid; GRrange range)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

/*
Name
        GRget_channel_type

Description
        This method is used to get the type of channel (Rigid or Flexible).

Synopsis
        IGRlong *msg            return code
        IGRint *type            the type of channel (GR_RIGID or GR_FLEXIBLE)
        IGRint *conn_type       override the flexible connection
                                (GR_OVERRIDE or GR_NO_OVERRIDE)

Return Values
        MSSUCC - always succeeds
*/

method GRget_channel_type (IGRlong *msg; IGRint *type; IGRint *conn_type)
{
    *msg = MSSUCC;
    *type = GR_FLEXIBLE;
    *conn_type = GR_NO_OVERRIDE;
    return (OM_S_SUCCESS);
}

/*
Name
        GRget_locate_properties

Description
        This method is used to get the owner's locate properties.

Synopsis
        IGRlong *msg            return code
        IGRint *properties      the allowable properties:
                                    GR_LC_CMP_READ
                                    GR_LC_CMP_WRITE
                                    GR_LC_CMP_PRM_READ
                                    GR_LC_CMP_PRM_WRITE
                                    GR_LC_OWN_READ
                                    GR_LC_OWN_WRITE
                                    GR_LC_OWN_PRM_READ
                                    GR_LC_OWN_PRM_WRITE
                                    GR_LC_RIGID
                                    GR_LC_FLEXIBLE
                                    GR_LC_NO_PRM_COMP

Return Values
        MSSUCC - always succeeds
*/

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_CMP_READ        |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_OWN_PRM_READ    |
                  GR_LC_OWN_PRM_WRITE   |
                  GR_LC_RIGID;
    return (OM_S_SUCCESS);
}

method GRchg_owner_properties (IGRlong *msg; IGRint action; IGRshort *mask)
{
    IGRlong sts;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (action == 0)
    {
        me->owner_properties = me->owner_properties & ~*mask;   /* clear */
    }
    else if (action == 1)
    {
        me->owner_properties = me->owner_properties | *mask;    /* set */
    }
    else if (action == 2)
    {
        me->owner_properties = *mask;                           /* replace */
    }
    else
    {
        *msg = MSINARG;
        sts = OM_E_ERROR;
    }
    GR_NOTIFY_LISTENERS (msg, &sts, GR_ATTR_MODIFIED);
    return (sts);
}

method GRget_owner_properties (IGRlong *msg; IGRshort *properties)
{
    *msg = MSSUCC;
    *properties = me->owner_properties;
    return (OM_S_SUCCESS);
}

/*
Name
        GRsmhdr.GRadd_to_active_owner

Description
        This method adds the symbol header to the active owner.

History
        mrm     01/13/89    creation
        scw     07/23/92    ansi conversion
*/

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod)
{
    return (gr$add_to_active_owner (msg = msg, mod_env = mod));
}

end implementation GRsmhdr;
