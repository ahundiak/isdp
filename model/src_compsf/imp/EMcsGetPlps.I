/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

# ifndef DEBUG
# define DEBUG 0
# endif

/*
HISTORY

29 Sep 1988 jBk Genesis.
*/

# include "EMS.h"
# include "EMS_E.h"
# include "EMSmsgdef.h"

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

method EMgetLoops (
    EMSrc *rc;
    IGRlong option;
    int *p_count;
    struct EMStreeHeap **pp_oloops
)
{
    EMSrc omrc;
    OM_S_CHANSELECT chansel;

#   if DEBUG
    static numCalls = 0;
    char name[OM_K_MAXCLASS_LEN];

    om$get_classname (object = me, classname = name);
    fprintf (stderr, "EMcsGetPlps:  begin %d %s\n", ++numCalls, name);
#   endif

    *rc = EMS_E_OperationFailed;

    omrc = EMmake_chanselect (GRcmpowner_to_components, &chansel    );

    if (EMSokay (omrc))
    {
        omrc = om$send (
            msg = message EMSsurface.EMgetLoops (
                rc,
                option,
                p_count,
                pp_oloops
            ),
            p_chanselect = &chansel
        );

        if (omrc IS OM_I_CHAN_EMPTY AND *rc IS EMS_E_OperationFailed)
        {
/*
            Then this send went nowhere, but that is okay.  The
            surface or surfaces of this composite were probably
            removed by a boolean operation or something similar.
*/
            *rc = EMS_I_NotFound;
        }
    }

#   if DEBUG
    fprintf (stderr, "EMcsGetPlps:  end %d omrc %d\n", numCalls, omrc);
#   endif

    return omrc;
}

end implementation EMScompsurf;
