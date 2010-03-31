/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

28 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"

/* AND EMSokay */
# include "EMSlogic.h"

from GRowner import GRget_number_components;

method ECnumSections (
    EMSrc *rc;
    IGRint firstBoundaryGroupCount;
    struct GRid boundaryGroup;
    IGRint *numSections
)
{
    EMSrc omrc;
    IGRint bigCount;

    /* get total number of elements in all boundaries */

    /* intentional block */
    {
        omrc = om$send (
            msg = message GRowner.GRget_number_components (
                (IGRlong *)rc,
                &bigCount
            ),
            targetid = boundaryGroup.objid,
            targetos = boundaryGroup.osnum
        );
    }

    /* find number of boundaries */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        *numSections = bigCount / firstBoundaryGroupCount;

        if (bigCount % firstBoundaryGroupCount /* ISNT 0 */)
        {
            *rc = MSFAIL;
        }
    }

    /* polish returned message codes */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = MSSUCC;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = MSFAIL;
    }

    return omrc;
}

end implementation ECigdsiems;
