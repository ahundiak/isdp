/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgensolid;

#include "EMS.h"
/*
NAME

EFnaturalGeneralSolidFromSurfaces -- derive a solid from two surfaces

DESCRIPTION

If the two surfaces are closed, they are made into surface solids
and a DISJOINT boolean operation is performed on them.  The type
of operation depends upon their spatial relationship.  If one
inside the other, a hollow difference is performed.  Otherwise a
disjoint union is performed.

If the two surfaces are not closed, this function causes
construction of surfaces between corresponding connectable,
natural edges of two input surfaces and use the input and
constructed surfaces to complete a composite surface which is
then made into a surface solid.

NOTES

If an input surface has no loopset, it will be sent a "make
natural loopset" message.  Consequently a surface may be returned
in a modified state even if this message fails.  Another
potential modification to a surface is toggling its indicator for
a reversed-normal.

Also, if the surfaces are both closed, they will become
components of surface solids if this function is at least
partially successful.

This function could work for any two surfaces that each have a
natural loop, but currently it is implemented to look for a
natural loopset.

ARGUMENTS

See EMSgencompsf message EMmk_w_natural_sides_twixt_2sf and
EMSslboolean message EMsolidFromNonIntersectingClosedSurfaces.

Additionally:

Upon success, parts[0] will contain NULL_OBJID.  Upon failure in
a case where sides are constructed, parts[0] will contain a
graphic group any newly created natural sides, if the graphic
group was creatable.  Else parts[0] will contain NULL_OBJID.

os:  the object space of surf1, surf2 and the solid to be
created.

solid:  the constructed solid.  In the event of a failure
regarding conversion of a solid boolean to a general solid
primitive or the change of a general composite surface into a
general solid when the original object seems to be preserved,
solid will point to said original.  Otherwise, solid points to
NULL_OBJID.

selfId:  the id of the calling object, if any.  Can be
NULL_OBJID.

RETURNED VALUES

OM_S_SUCCESS if the implementation of this message succeeds.

OM_E_ABORT if there is a non-OM failure.

An OM failure message for OM problems.

For rc:

See EMSgencompsf message EMmk_w_natural_sides_twixt_2sf and
EMSslboolean message EMsolidFromNonIntersectingClosedSurfaces.

EMS_E_ConVBoolWClS for unknown failure while attempting to create
a disjoint solid boolean of two closed surfaces.

EMS_E_MakeDprPrimitive for failure making the disjoint solid
boolean of two closed surfaces into a primitive solid.

EMS_I_ConGenVWClS for successful completion of making a primitive
solid from a disjoint solid boolean of two closed surfaces.

EMS_E_ConSCompWNatSyd for unknown failure while attempting to
create a composite surface of the input surfaces and their
natural sides.

EMS_E_CompSNotClosed if the created composite surface is not
closed.

EMS_E_ChgSCompToV for failure to change general composite surface
to solid.

EMS_E_OrientV for failure of the solid (made from the general
composite surface) to orient itself.

EMS_I_ConGenVWNatSyd for successful construction of general solid
with natural sides.

EMS_E_ExactlyOneSurfClosed if one and only one of the input
surfaces is closed.

EMS_E_OperationFailed if somehow I goofed and did not label an
error condition properly.  One ought not get this message.

All of the above EMS message codes are constructed with the
message subsystem and can be used with message subsystem output
macros.

HISTORY

12 Jul 1988 jBk Changed to EMSgencompsf.EMmkWNatSidesTw2S to
                EMSsfsolid.EMmk_w_natural_sides_twixt_2sf.  Now
                check closure here and perform change of class to
                make composite into general solid.
                In cases where both surfaces are closed, the
                boolean is now made primitive.
                Changed name from EFnaturalSolidFromSurfaces to
                EFnaturalGeneralSolidFromSurfaces.
                Eliminated numParts argument and modified
                meanings of parts and solid arguments.
?           jBk Genesis.
*/

/* EMS_I_ConGenVWClS EMS_I_ConGenVWNatSyd */
# include "EMS_I.h"

/* EMS_E_ConVBoolWClS EMS_E_ChgSCompWNatSyd ... */
# include "EMS_E.h"

from EMSslboolean import EMsolidFromNonIntersectingClosedSurfaces;
from EMSslboolean import EMmake_primitive1;
from EMSgencompsf import EMmkWNatSidesTw2S;

IGRlong EFnaturalGeneralSolidFromSurfaces (
    rc,
    selfId,
    os,
    surf1, surf2,
    constructList,
    parts,
    solid
)
    IGRlong *rc;
    OM_S_OBJID selfId;
    OMuword os;
    OM_S_OBJID surf1, surf2;
    struct GRvg_construct constructList[1];
    OM_S_OBJID parts[1];
    OM_S_OBJID solid[1];
{
    EMSrc omrc;
    int bothClosed;
    IGRboolean closed[2];
    int ii, okay = TRUE;
    OM_S_OBJID localParts[2];

    if (parts) parts[0] = NULL_OBJID;
    *solid = NULL_OBJID;

    localParts[0] = surf1;
    localParts[1] = surf2;

    ii = 1;
    do
    {
        *rc = EMS_E_FailIsSurfClosed;

        omrc = om$send (
            msg = message EMSsurface.EMisClosed (
                rc,
                constructList->env_info,
                &closed[ii]
            ),
            senderid = selfId,
            targetos = os,
            targetid = localParts[ii]
        );

        okay = EMSokay (omrc) AND EMSokay (*rc);
    } while (ii-- AND okay);

    if (okay) /* individual openness */
    {
        if (closed[0] ISNT closed[1])
        {
            *rc = EMS_E_ExactlyOneSurfClosed;
            okay = FALSE;
        }
        else
            bothClosed = closed[0] AND closed[1];
    }

    if (okay) /* combined openness */
    {
        if (bothClosed)
        {
            extern OMuword OPP_EMSslboolean_class_id;

            *rc = EMS_E_ConVBoolWClS;

            omrc = om$construct (
                classid = OPP_EMSslboolean_class_id,
                msg = message EMSslboolean.
                    EMsolidFromNonIntersectingClosedSurfaces (
                    rc,
                    constructList->env_info,
                    surf1,
                    surf2,
                    constructList,
                    NULL        /* booleanOptions */
                ),
                osnum = os,
                p_objid = solid
            );

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                struct GRid gensolidGRid;

                omrc = om$send (
                    msg = message EMSslboolean.EMmake_primitive1 (
                        rc,                         /* EMmsg */
                        constructList->env_info,    /* my_env */
                        &gensolidGRid               /* new_id */
                    ),
                    senderid = selfId,
                    targetid = *solid,
                    targetos = os
                );

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    *rc = EMS_I_ConGenVWClS;
                    *solid = gensolidGRid.objid;
                }
                else /* make primitive failed */
                {
                    EMSrc validomrc;

                    *rc = EMS_E_MakeDprPrimitive;

                    validomrc = om$is_objid_valid (
                        osnum = os,
                        objid = *solid
                    );

                    if (EMSerror (validomrc))
                    {
                        *solid = NULL_OBJID;
                    }
                } /* fi make primitive */
            }
            else /* boolean failed */
            {
                *solid = NULL_OBJID;
            } /* fi boolean */
        }
        else /* both not closed */
        {
            extern OMuword OPP_EMSgencompsf_class_id;

            *rc = EMS_E_ConSCompWNatSyd;

            omrc = om$construct (
                classid = OPP_EMSgencompsf_class_id,
                msg = message EMSgencompsf.EMmkWNatSidesTw2S (
                    rc,
                    surf1,
                    surf2,
                    constructList,
                    parts
                ),
                osnum = os,
                p_objid = solid
            );

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                IGRboolean compClosed;

                omrc = om$send (
                    msg = message EMSsurface.EMisClosed (
                        rc,
                        constructList->env_info,
                        &compClosed
                    ),
                    senderid = selfId,
                    targetid = *solid,
                    targetos = os
                );

                if (compClosed AND EMSokay (omrc) AND EMSokay (*rc))
                {
                    omrc = om$change_class (
                        osnum = os,
                        objid = *solid,
                        classname = "EMSgensolid"
                    );

                    if (EMSokay (omrc))
                    {
                        omrc = om$send (
                            msg = message EMSgensolid.EMorient_yourself (
                                rc,
                                NULL, /* options */
                                constructList->env_info
                            ),
                            senderid = selfId,
                            targetid = *solid,
                            targetos = os
                        );

                        if (EMSokay (omrc) AND EMSokay (*rc))
                        {
                            *rc = EMS_I_ConGenVWNatSyd;
                        }
                        else
                        {
                            *rc = EMS_E_OrientV;
                        }                    
                    }
                    else /* change class failed */
                    {
                        EMSrc validomrc;

                        *rc = EMS_E_ChgSCompToV;

                        validomrc = om$is_objid_valid (
                            osnum = os,
                            objid = *solid
                        );

                        if (EMSerror (validomrc))
                        {
                            *solid = NULL_OBJID;
                        }
                    } /* fi change class */
                }
                else /* not closed */
                {
                    *rc = EMS_E_CompSNotClosed;
                } /* fi closed */
            }
            else /* EMSgencompsf.EMmkWNatSidesTw2S failed*/
            {
                *solid = NULL_OBJID;
            } /* fi EMSgencompsf.EMmkWNatSidesTw2S success */
        } /* end else both not closed */
    } /* end if okay with regard to combined openness */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        if (EMSokay (omrc)) omrc = OM_E_ABORT;
        if (EMSokay (*rc)) *rc = EMS_E_OperationFailed;
    }

    return omrc;
}

end implementation EMSgensolid;
