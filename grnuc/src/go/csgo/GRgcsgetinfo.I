/*
Name
        GRgencs.GRget_cs_info

Description
        This method returns the name, the description, type and/or the id of
        the coordinate system.  If a parameter pointer is NULL, then that
        parameter is not returned.    

Return Codes
        msg     MSSUCC          success
                NAME_TRUNC      information, truncated name returned
                DESC_TRUNC      information, truncated description returned
                BOTH_TRUNC      information, truncated name and description
                                returned
History
        mrm     08/05/87    creation
                03/10/88    use directory subsystem to retrieve name
        dhm     08/06/91    added type argument
        scw     03/10/92    added check for null desc instance data
        dhm     07/15/92    ansi conversion.
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "csdef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

method GRget_cs_info (IGRlong       *msg;
                      IGRint         namebuf_size;
                      IGRchar       *name;
                      IGRint        *namebytes_ret;
                      IGRint         descbuf_size;
                      IGRchar       *desc;
                      IGRint        *descbytes_ret;
                      IGRshort      *type;
                      struct GRid   *id)
{
    IGRchar     pathname[DI_PATH_MAX];     /* cs directory & name */
/*    IGRchar     objname[PATH_MAX]; */     /* cs name */
    IGRlong     sts;                    /* return code */
    IGRlong     overflow;               /* flag */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    overflow = 0;

    if (name)
    {
        sts = di$untranslate (objid = my_id,
                              osnum = OM_Gw_current_OS,
                              objname = pathname);
        if (sts & 1)
        {
            strncpy (name, pathname, namebuf_size);
            if (strlen (pathname) > namebuf_size)
            {
                name[namebuf_size - 1] = '\0';
                overflow |= NAME_TRUNC;
            }
            *namebytes_ret = strlen (name);
        }
        else    /* object is unnamed */
        {
            sts = OM_S_SUCCESS;
            *name = NULL;
            *namebytes_ret = 0;
        }
    }

    if (desc)
    {
        if (me->description)
        {
           strncpy (desc, me->description, descbuf_size);
           if (strlen (me->description) > descbuf_size)
           {
               desc[descbuf_size - 1] = '\0';
               overflow |= DESC_TRUNC;
           }
           *descbytes_ret = strlen (desc);
        }
        else
        {
           sts = OM_S_SUCCESS;
           *desc = NULL;
           *descbytes_ret = 0;
        }
    }

    if (type)
    {
        *type = me->type;
    }

    if (id)
    {
        id->objid = my_id;
        id->osnum = OM_Gw_current_OS;
    }

    *msg = (overflow) ? overflow : MSSUCC;

    return (sts);
}

end implementation GRgencs;
