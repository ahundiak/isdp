/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
HISTORY

21 Nov 1988 jBk Modified to accomodate addition of
                EMSbool_delDisjArea to EMSbooltype enumeration.
14 Apr 1988 jBk Genesis.  See EMget_operation_type message of
                class EMSsfboolean for interface details.

NOTES

Function EFextractOperationInformation has no paramter
"exactOperation."  The parameter "request" is called "operation"
since it is always input for this function.
*/

/* OM_S_SUCCESS, OM_E_ABORT */
# ifndef OM_D_ERRORDEF
# include "OMerrordef.h"
# endif

/* EMSokay */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMS_S_Success, EMS_E_InvalidArg */
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

/* IGR typedefs */
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

/* EMSrc */
# ifndef EMStypedef_include
# include "EMStypedef.h"
# endif

/* Boolean operation enumeration */
# ifndef emsbool_include
# include "emsbool.h"
# endif

/* message numbers for boolean types */
# ifndef EMS_I_include
# include "EMS_I.h"
# endif

EMSrc EFextractOperationInformation (
    EMmsg,
    operation,
    generalOperation,
    reverseOrientation,
    emptySet,
    disjointSurfaces,
    firstOnly,
    allButFirst,
    lastOnly,
    removedSolids,
    msgNumber
)
    IGRlong *EMmsg;
    enum EMSbooltype operation;
    enum EMSbooltype *generalOperation;
    IGRboolean *reverseOrientation;
    IGRboolean *emptySet;
    IGRboolean *disjointSurfaces;
    IGRboolean *firstOnly;
    IGRboolean *allButFirst;
    IGRboolean *lastOnly;
    IGRboolean *removedSolids;
    IGRlong *msgNumber;
{
    EMSrc omrc;

    switch (operation)
    {
    case EMSbool_intersect:
    case EMSbool_union:
    case EMSbool_difference:
    case EMSbool_saveside:
    case EMSbool_interiorD:
    case EMSbool_disjointD:
    case EMSbool_surroundD:
    case EMSbool_interiorU:
    case EMSbool_disjointU:
    case EMSbool_surroundU:
    case EMSbool_interiorI:
    case EMSbool_disjointI:
    case EMSbool_surroundI:
    case EMSbool_solidNullU:
    case EMSbool_nullSolidU:
    case EMSbool_solidNullD:
    case EMSbool_nullSolidD:
    case EMSbool_solidNullI:
    case EMSbool_nullSolidI:
    case EMSbool_nullNullU:
    case EMSbool_nullNullD:
    case EMSbool_nullNullI:
    case EMSbool_delDisjArea:
    case EMSbool_TrimCompsfs:
        *EMmsg = EMS_S_Success;
        omrc = OM_S_SUCCESS;
        break;
    default:
        *EMmsg = EMS_E_InvalidArg;
        omrc = OM_E_ABORT;
        /* no break necessary */
    }

    if (EMSokay (omrc))
    {
        if (generalOperation)
        {
            switch (operation)
            {
            case EMSbool_intersect:
            case EMSbool_interiorI:
            case EMSbool_disjointI:
            case EMSbool_surroundI:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullI:
                *generalOperation = EMSbool_intersect;
                break;

            case EMSbool_union:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_nullNullU:
                *generalOperation = EMSbool_union;
                break;

            case EMSbool_saveside:
            case EMSbool_difference:
            case EMSbool_interiorD:
            case EMSbool_disjointD:
            case EMSbool_surroundD:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_nullNullD:
            case EMSbool_delDisjArea:
                *generalOperation = EMSbool_difference;
                 break;

            case EMSbool_TrimCompsfs:
                 *generalOperation = EMSbool_TrimCompsfs;

            /* no default nor break necessary */
            }
        }

        if (reverseOrientation)
        {
            switch (operation)
            {
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
                *reverseOrientation = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_disjointD:
            case EMSbool_surroundD:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_interiorI:
            case EMSbool_disjointI:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *reverseOrientation = FALSE;

            /* no default nor break necessary */
            }
        }

        if (emptySet)
        {
            switch (operation)
            {
            case EMSbool_surroundD:
            case EMSbool_disjointI:
            case EMSbool_nullNullU:
            case EMSbool_nullSolidD:
            case EMSbool_nullNullD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullI:
                *emptySet = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
            case EMSbool_disjointD:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_interiorI:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_solidNullD:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *emptySet = FALSE;

            /* no default nor break necessary */
            }
        }

        if (disjointSurfaces)
        {
            switch (operation)
            {
            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *disjointSurfaces = FALSE;
                break;

            case EMSbool_interiorD:
            case EMSbool_disjointD:
            case EMSbool_surroundD:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_interiorI:
            case EMSbool_disjointI:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
                *disjointSurfaces = TRUE;

            /* no default nor break necessary */
            }
        }

        if (firstOnly)
        {
            switch (operation)
            {
            case EMSbool_disjointD:
            case EMSbool_interiorU:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_solidNullD:
                *firstOnly = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
            case EMSbool_surroundD:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_interiorI:
            case EMSbool_disjointI:
            case EMSbool_nullSolidU:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *firstOnly = FALSE;

            /* no default nor break necessary */
            }
        }

        if (allButFirst)
        {
            switch (operation)
            {
            case EMSbool_interiorI:
            case EMSbool_nullSolidU:
                *allButFirst = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
            case EMSbool_disjointD:
            case EMSbool_surroundD:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_surroundU:
            case EMSbool_disjointI:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *allButFirst = FALSE;

            /* no default nor break necessary */
            }
        }

        if (lastOnly)
        {
            switch (operation)
            {
            case EMSbool_surroundU:
                *lastOnly = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
            case EMSbool_disjointD:
            case EMSbool_surroundD:
            case EMSbool_interiorU:
            case EMSbool_disjointU:
            case EMSbool_interiorI:
            case EMSbool_disjointI:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *lastOnly = FALSE;

            /* no default nor break necessary */
            }
        }

        if (removedSolids)
        {
            switch (operation)
            {
            case EMSbool_interiorU:
            case EMSbool_interiorI:
            case EMSbool_disjointD:
            case EMSbool_disjointI:
            case EMSbool_surroundD:
            case EMSbool_surroundU:
            case EMSbool_surroundI:
            case EMSbool_solidNullU:
            case EMSbool_nullSolidU:
            case EMSbool_solidNullD:
            case EMSbool_nullSolidD:
            case EMSbool_solidNullI:
            case EMSbool_nullSolidI:
            case EMSbool_nullNullU:
            case EMSbool_nullNullD:
            case EMSbool_nullNullI:
                *removedSolids = TRUE;
                break;

            case EMSbool_intersect:
            case EMSbool_union:
            case EMSbool_difference:
            case EMSbool_saveside:
            case EMSbool_interiorD:
            case EMSbool_disjointU:
            case EMSbool_delDisjArea:
            case EMSbool_TrimCompsfs:
                *removedSolids = FALSE;

            /* no default nor break necessary */
            }
        }

        if (msgNumber)
        {
            switch (operation)
            {
            case EMSbool_intersect:
                *msgNumber = EMS_I_BooleanIntersection;
                break;
            case EMSbool_union:
                *msgNumber = EMS_I_BooleanUnion;
                break;
            case EMSbool_difference:
                *msgNumber = EMS_I_BooleanDifference;
                break;
            case EMSbool_TrimCompsfs:
                *msgNumber = EMS_I_TrimmedSurface;
                break;
#ifndef IDRAW
            case EMSbool_saveside:
                *msgNumber = EMS_I_IntersectSaveSide;
                break;
            case EMSbool_interiorD:
                *msgNumber = EMS_I_InteriorBooleanDiff;
                break;
            case EMSbool_disjointD:
                *msgNumber = EMS_I_DisjointBooleanDiff;
                break;
            case EMSbool_surroundD:
                *msgNumber = EMS_I_ExteriorBooleanDiff;
                break;
            case EMSbool_interiorU:
                *msgNumber = EMS_I_InteriorBooleanUnion;
                break;
            case EMSbool_disjointU:
                *msgNumber = EMS_I_DisjointBooleanUnion;
                break;
            case EMSbool_surroundU:
                *msgNumber = EMS_I_ExteriorBooleanUnion;
                break;
            case EMSbool_interiorI:
                *msgNumber = EMS_I_InteriorBooleanIntx;
                break;
            case EMSbool_disjointI:
                *msgNumber = EMS_I_DisjointBooleanIntx;
                break;
            case EMSbool_surroundI:
                *msgNumber = EMS_I_ExteriorBooleanIntx;
                break;
            case EMSbool_solidNullU:
                *msgNumber = EMS_I_SolidNullUnion;
                break;
            case EMSbool_nullSolidU:
                *msgNumber = EMS_I_NullSolidUnion;
                break;
            case EMSbool_solidNullD:
                *msgNumber = EMS_I_SolidNullDiff;
                break;
            case EMSbool_nullSolidD:
                *msgNumber = EMS_I_NullSolidDiff;
                break;
            case EMSbool_solidNullI:
                *msgNumber = EMS_I_SolidNullIntx;
                break;
            case EMSbool_nullSolidI:
                *msgNumber = EMS_I_NullSolidIntx;
                break;
            case EMSbool_nullNullU:
                *msgNumber = EMS_I_NullNullUnion;
                break;
            case EMSbool_nullNullD:
                *msgNumber = EMS_I_NullNullDiff;
                break;
            case EMSbool_nullNullI:
                *msgNumber = EMS_I_NullNullIntx;
                break;
            case EMSbool_delDisjArea:
                *msgNumber = EMS_I_ModViaDelDisjArea;
#endif

            /* no default nor break necessary */
            }
        }

    } /* end if (EMSokay (omrc)) */

    return omrc;
}
