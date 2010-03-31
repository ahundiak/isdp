/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolean;

#include "EMS.h"
/*
ALGORITHM

Promote the surfaces to solids.

Find the relationship between the closed surfaces.

Perform the appropriate boolean operation which preserves the
display of both surfaces.

HISTORY

10-May-1988 jBk Genesis.
*/

/* EMSokay EMSerror IS OR AND */
# include "EMSlogic.h"

/* OM_S_SUCCESS OM_E_ABORT */
# include "OMerrordef.h"

/* EMS_E_ messages */
# include "EMS_E.h"

/* EMS_S_Success */
# include "EMSmsgdef.h"

/* EMS_S_INSOLID EMS_S_OUTSOLID */
# include "EMSconstruct.h"

from EMSsfsolid import EMcap_thyself;

method EMsolidFromNonIntersectingClosedSurfaces (
    IGRlong *rc;
    struct GRmd_env env[1];
    OM_S_OBJID sf1, sf2;
    struct GRvg_construct constructList[1];
    IGRushort booleanOptions
)
{
    enum EMSbooltype request;
    IGRulong locationSl1, locationSl2;
    OM_S_OBJID sol1, sol2;
    EMSrc omrc;
    OMuword classid;

    /* intentional block */
    {
        omrc = om$get_classid (
            objid = sf1,
            p_classid = &classid
        );
    }

    if (EMSokay (omrc))
    {
        extern OMuword OPP_EMSsolid_class_id;

        omrc = om$is_ancestry_valid (
            subclassid = classid,
            superclassid = OPP_EMSsolid_class_id
        );
    }

    if (EMSokay (omrc) AND omrc ISNT OM_S_SUCCESS)
    /* if okay, but not solid */
    {
        extern OMuword OPP_EMSsfsolid_class_id;

        omrc = om$construct (
            classid = OPP_EMSsfsolid_class_id,
            p_objid = &sol1,
            msg = message EMSsfsolid.EMcap_thyself (
                rc,
                constructList,
                &sf1
            )
        );

        if (EMSerror (*rc)) omrc = OM_E_ABORT;
    }

    if (EMSokay (omrc))
    {
        omrc = om$get_classid (
            objid = sf2,
            p_classid = &classid
        );
    }

    if (EMSokay (omrc))
    {
        extern OMuword OPP_EMSsolid_class_id;

        omrc = om$is_ancestry_valid (
            subclassid = classid,
            superclassid = OPP_EMSsolid_class_id
        );
    }

    if (EMSokay (omrc) AND omrc ISNT OM_S_SUCCESS)
    /* if okay, but not solid */
    {
        extern OMuword OPP_EMSsfsolid_class_id;

        omrc = om$construct (
            classid = OPP_EMSsfsolid_class_id,
            p_objid = &sol2,
            msg = message EMSsfsolid.EMcap_thyself (
                rc,
                constructList,
                &sf2
            )
        );
    }

    if (EMSerror (omrc))
    /* if there were problems making surface solid */
    {
        omrc = OM_E_ABORT;
        *rc = EMS_E_MakeSfSolidFailed;
    }

    if (EMSokay (omrc))
    {
        EMSrc EFsolidRelationship ();

        omrc = EFsolidRelationship (
            rc,
            NULL_OBJID,
            sol2, sol1,
            OM_Gw_current_OS, OM_Gw_current_OS,
            env, env,
            NULL,
            &locationSl1
        );

        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_SolidRelnNotFound;
        }
        else
        {
            switch (locationSl1)
            {
            case EMS_S_INSOLID:
            case EMS_S_OUTSOLID:
                break;
            default:
                omrc = OM_E_ABORT;
                *rc = EMS_E_SolidRelnInvalid;
            }
        }
    }

    if (EMSokay (omrc))
    {
        EMSrc EFsolidRelationship ();

        omrc = EFsolidRelationship (
            rc,
            NULL_OBJID,
            sol1, sol2,
            OM_Gw_current_OS, OM_Gw_current_OS,
            env, env,
            NULL,
            &locationSl2
        );

        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_SolidRelnNotFound;
        }
        else
        {
            switch (locationSl2)
            {
            case EMS_S_INSOLID:
                if (locationSl1 IS EMS_S_OUTSOLID)
                {
                    request = EMSbool_interiorD;
                }
                else /* locationSl1 IS EMS_S_INSOLID */
                {
                    omrc = OM_E_ABORT;
                    *rc = EMS_E_SolidRelnInvalid;
                }
                break;
            case EMS_S_OUTSOLID:
                if (locationSl1 IS EMS_S_OUTSOLID)
                {
                    request = EMSbool_disjointU;
                }
                else /* locationSl1 IS EMS_S_INSOLID */
                {
                    OM_S_OBJID temp;

                    request = EMSbool_interiorD;

                    temp = sol1;
                    sol1 = sol2;
                    sol2 = temp;
                }
                break;
            default:
                omrc = OM_E_ABORT;
                *rc = EMS_E_SolidRelnInvalid;
            }
        }
    }

    if (EMSokay (omrc))
    {
        om$send (
            msg = message EMSsfboolean.EMboolean (
                rc,
                &env->md_env.matrix_type, env->md_env.matrix,
                sol1,
                1, &sol2,
                constructList,
                request,
                booleanOptions,
                NULL,           /* status_str */
                NULL,           /* intgrp */
                NULL,           /* auxgrp */
                NULL,           /* display_ids */
                NULL            /* display_count */
            ),
            targetid = my_id
        );

        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_SfSolidBooleanFailed;
        }
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }

    return omrc;
}

end implementation EMSslboolean;
