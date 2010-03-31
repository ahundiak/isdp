/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

01 Feb 1989 jBk Fixed a bug in setting the layers mask.
16 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"

/* EMSokay AND */
# include "EMSlogic.h"

/* dp$levels_on_off */
# include "dpmacros.h"

/* gr$put_active_level */
# include "grdpbmacros.h"

from GRvg import GRchglevel;

# define ERRORLAYER     100
# define NUM32BITWORDS   32

method ECmoveToErrorLayer (
    EMSrc *rc;
    struct GRid element;
    struct GRid environ
)
{
    EMSrc omrc, clyrc, palrc, loorc;
    IGRshort layer = ERRORLAYER;

    /* intentional block */
    {
        omrc = om$send (
            msg = message GRvg.GRchglevel ((IGRlong *)&clyrc, &layer),
            targetos = element.osnum,
            targetid = element.objid
        );
    }

    /* intentional block */
    {
        IGRint sizeofLayer = sizeof layer;

        gr$put_active_level (
            msg = &palrc,
            sizbuf = &sizeofLayer,
            buffer = &layer
        );
    }

    /* intentional block */
    {
        OMulong layersMask[NUM32BITWORDS], *lm = layersMask;
        int ii = NUM32BITWORDS - 1;

        do
        {
            *lm++ = 0xffffffff;
        } while (ii--);

        dp$levels_on_off (
            msg = &loorc,
            levels_mask = layersMask,
            on_off_flag = 0 /* off */,
            update = FALSE /* do not update */,
            osnum = environ.osnum,
            mod_objid = environ.objid
        );
    }

    if (EMSokay (clyrc) AND
        EMSokay (palrc) AND
        EMSokay (loorc) AND
        EMSokay (omrc))
    {
        *rc = MSSUCC;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *rc = MSFAIL;
        omrc = OM_E_ABORT;
    }

    return omrc;
}

end implementation ECigdsiems;
