class implementation EMSname;

#include "EMS.h"
/*
HISTORY

11-Feb-1988 jBk Added EMcmpDescription message implementation.
30-Sep-1987 J. Brooke King  Creation
*/

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
# include <stdio.h>
# endif

/* strlen (), strcpy (), strcat (), strcmp () */
# include <string.h>

/* om$dimension_of, om$vla_set_dimension */
# ifndef OM_D_MACROS
# include "OMmacros.h"
# endif

# ifndef OM_D_ERRORDEF
# include "OMerrordef.h"
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

from EMSsurface import EMputDescription;

method EMascopy (
    IGRlong *rc;
    struct GRid *new_geom_id;
    struct EMcp_info *copy_info
)
{
    return om$send (
        msg = message EMSsurface.EMputDescription (
            (EMSrc *)rc,
            me->name
        ),
        targetid = new_geom_id->objid,
        targetos = new_geom_id->osnum
    );
}

/*
method EMasdelete (IGRlong *rc)
{
    *rc = om$send (
        msg = message Root.delete (FALSE),
        targetid = my_id
    );

    return *rc;
}
*/

method EMputDescription (EMSrc *rc; char description[])
{
    char *desc = "";
    int len;

#   if DEBUG
    (void)fprintf (stderr, "EMnamei put [%s] my_id %d\n",
        description IS NULL ? "NULL" : description, my_id);
#   endif

    if (description ISNT NULL)
    {
        desc = description;
    }

    if (len = strlen (desc))
    {
        len++; /* 1 for null terminator */
        *rc = om$vla_set_dimension (size = len, varray = me->name);
        if (EMSokay (*rc))
        {
            (void)strcpy (me->name, desc);
        }
    }
    else
    {
        *rc = om$vla_set_dimension (size = 0, varray = me->name);
    }

    return *rc;
}

method EMappDescription (EMSrc *rc; char appendix[])
{
    *rc = OM_S_SUCCESS;

#   if DEBUG
    (void)fprintf (stderr, "EMnamei.I app:  %s\n",
        appendix IS NULL ? "NULL" : appendix);
#   endif

    if (appendix ISNT NULL)
    {
        int len;

        if (len = strlen (appendix))
        {
            int original;

            *rc = om$send (
                msg = message EMSname.EMlenDescription (
                    rc,
                    &original
                ),
                targetid = my_id
            );

            if (EMSokay (*rc))
            {
                len += original + 1;
                *rc = om$vla_set_dimension (
                    size = len,
                    varray = me->name
                );
                if (EMSokay (*rc))
                {
                    (void)strcat (me->name, appendix);
                }
            }
        }
    }

    return *rc;
}

method EMgetDescription (EMSrc *rc; char description[]; int len)
{
    *rc = OM_S_SUCCESS;

#   if DEBUG
    (void)fprintf (stderr, "EMnamei.I get:  %s\n",
        om$dimension_of (varray = me->name) IS 0 ? "NULL" : me->name);
#   endif

    if (len >= 0)
    {
        if (om$dimension_of (varray = me->name) IS 0)
        {
            description[0] = '\0';
        }
        else if (len) /* is greater than 0 */
        {
            (void)strncpy (description, me->name, len);
            description[len] = '\0';
        }
        else /* len IS NULL */
            (void)strcpy (description, me->name);
    }
    else *rc = OM_E_INVARG;

    return *rc;
}

method EMlenDescription (EMSrc *rc; int *len)
{
#   if DEBUG
    (void)fprintf (stderr, "EMnamei.I len:  %d\n",
        om$dimension_of (varray = me->name) IS 0 ? 0 : strlen (me->name));
#   endif

    if (om$dimension_of (varray = me->name) IS 0)
        *len = 0;
    else
        *len = strlen (me->name);

    *rc = OM_S_SUCCESS;
    return OM_S_SUCCESS;
}

method EMcmpDescription (
    EMSrc *rc;
    char string[];
    int *relationship
)
{
    int mydim, stdim = 0;

#   if DEBUG
        (void)fprintf (stderr, "EMname cmp me [%s] it [%s]\n",
            om$dimension_of (varray = me->name) ? me->name : "NONE",
            string ? string : "NONE"
        );
#   endif

    mydim = om$dimension_of (varray = me->name);
    if (mydim)
    {
        if (me->name[0] IS '\0') mydim = 0;
    }

    if (string)
    {
        stdim = strlen (string);
    }

    if (NOT (stdim)) /* string dim is zero */
    {
        if (NOT (mydim)) /* myname dim is zero */
        {
            *relationship = 0;
        }
        else            /* myname dim is not zero */
        {
            *relationship = -1;
        }
    }
    else if (NOT (mydim)) /* string dim is not zero, myname dim is zero */
    {
        *relationship = 1;
    }
    else /* neither dim is zero */
    {
        *relationship = strcmp (string, me->name);
    }

#   if DEBUG
        (void)fprintf (stderr, "EMname cmp my_id %d reln %d\n",
            my_id, *relationship);
#   endif

    return *rc = OM_S_SUCCESS;
}

end implementation EMSname;
