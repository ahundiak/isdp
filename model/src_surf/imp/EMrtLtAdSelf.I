/* ###################   APOGEE COMPILED   ################## */
class implementation Rootmsg;

# include "EMS.h"           /* for shared libraries */
# include "OMerrordef.h"    /* OM_S_SUCCESS OM_E_ABORT */
# include "EMSlogic.h"      /* EMSokay */

# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include <stdio.h>
#   include "EMScmacros.h"

extern int EFfprints ();

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

method EMaddSelfToList (
    EMSrc *rc;
    struct EMStreeHeap *p_list
)
{
    EMSrc omrc;
    extern EMSrc EFtreeAddNode ();
    extern int EFcmpInt ();

    *rc = EFtreeAddNode (my_id, EFcmpInt, p_list, NULL);

    EMSdbgMR (*rc, "Rootmsg.EMaddSelfToList EFtreeAddNode *rc");

    if (EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
    }

    omrc;
}

end implementation Rootmsg;
