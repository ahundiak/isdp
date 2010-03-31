/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"

/*
HISTORY

Sudha  06/23/93 Modified for BSprototype ansification

18 Apr 1989 jBk Modified to reset me^^EMSdpr.ids[0] to an
                appropriate value after removal of the NULL
                symbol.

                This modification can be greatly simplified when
                there are no removed-operand booleans with
                inconsistently represented ssi table instance
                data.

15 Apr 1988 jBk Genesis.
*/

/* om$dimension_of, om$vla_set_dimension */
# include "OMmacros.h"

/* for grdpb.h and grdpbmacros.h */
# include "grdpbdef.h"

/* struct GRdpb_text_symb */
# include "grdpb.h"

/* gr$get_text_symb */
# include "grdpbmacros.h"

/* co$place_text */
# include "cotxmacros.h"

/* BSrc, BSERROR */
# include "bserr.h"

/* GRbe */
# include "dp.h"

#include "bsdistptpt.h"

method EMattachNullSymbol (
    IGRlong *EMmsg;
    struct GRvg_construct construct_list[1]
)
{
    struct GRid textGRid;
    EMSrc omrc = OM_S_SUCCESS;
    int ii;
    union
    {
        double d;
        char c[8];
    } one;
    struct GRdpb_text_symb activeSymb;
    IGRchar textString[12];
    IGRshort textLength;
    IGRdouble textSize;
    GRrange range;

    textString[0] = '0';
    textString[1] = 033;
    textString[2] = 'h';
    one.d = -1.0;
    for (ii = 0; ii < 8; ii = ii + 1)
    {
        textString[ii + 3] = one.c[ii];
    }
    textString[11] = '/';

    textLength = sizeof (textString);

    /* intentional block to establish range */
    {
        enum EMSbooltype saveType;

        IGRboolean world = TRUE;

        /* to trick GRgetrang into getting range of entire
            collection we call this a union */

        saveType = (enum EMSbooltype)me^^EMSsfboolean.operation;
        me^^EMSsfboolean.operation = (IGRchar)EMSbool_union;

        omrc = om$send (
            msg = message GRvg.GRgetrang (
                EMmsg,
                &construct_list[0].env_info->md_env.matrix_type,
                construct_list[0].env_info->md_env.matrix,
                &world,
                range
            ),
            targetid = my_id
        );

        me^^EMSsfboolean.operation = (IGRchar)saveType;

        if (EMSerror (omrc) OR EMSerror (*EMmsg))
        {
            *EMmsg = EMS_E_Fail;
            omrc = OM_E_ABORT;
        }
    }

    if (EMSokay (*EMmsg))
    {
        BSrc bsrc;

        textSize = BSdistptpt (&bsrc, range, &range[3]);

        if (BSERROR (bsrc)) *EMmsg = EMS_E_Fail;
    }

    if (EMSokay (*EMmsg))
    {
        IGRint sizbuf = sizeof (activeSymb);
        IGRint nret;

        gr$get_text_symb (
            msg = EMmsg,
            sizbuf = &sizbuf,
            buffer = &activeSymb,
            nret = &nret
        );
    }

    if (EMSokay (*EMmsg))
    {
        IGRdouble *range0, *range1, *optr;
        IGRpoint origin;
        IGRmatrix rot_matrix;
        int index = 0;

        ii = 3;
        do
        {
            int jj = 3;

            do
            {
                if (ii IS jj) rot_matrix[index] = 1;
                else rot_matrix[index] = 0;
                index++;
            } while (jj--);
        } while (ii--);

        activeSymb.Active_height = textSize;
        activeSymb.Active_width = 2.0 * textSize / 3.0;

        ii = 2;
        optr = origin;
        range0 = range;
        range1 = &range[3];
        do
        {
            *optr = *range0 > *range1 ? *range1 : *range0;
            optr++;
            range0++;
            range1++;
        } while (ii--);

        co$place_text (
            msg =           EMmsg,
            text_string =   textString,
            text_length =   &textLength,
            origin =        origin,
            rot_matrix =    rot_matrix,
            TextSymb =      &activeSymb,
            mode =          GRbe,
            buffer =        &textGRid
        );
    }

    if (EMSokay (*EMmsg))
    {
        int allocated;

        allocated = om$dimension_of (varray = me^^EMSdpr.ids);

        if (NOT allocated)
        {
            omrc = om$vla_set_dimension (
                varray = me^^EMSdpr.ids,
                size = 1
            );
        }
    }

    if (EMSokay (*EMmsg) AND EMSokay (omrc))
    {
        me^^EMSdpr.ids[0] = textGRid.objid;
        *EMmsg = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *EMmsg = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    return omrc;
}

method EMremoveNullSymbol (
    IGRlong *EMmsg;
    struct GRmd_env *env
)
{
    EMSrc omrc;
    int removed = FALSE;

    omrc = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    if (om$dimension_of (varray = me^^EMSdpr.ids))
    {
        OM_S_OBJID objectId;

        objectId = me^^EMSdpr.ids[0];

        omrc = om$is_objid_valid (objid = objectId);

        if (omrc IS OM_S_SUCCESS)
        {
            OMuword classId;

            omrc = om$get_classid (
                objid = objectId,
                p_classid = &classId
            );

            if (omrc IS OM_S_SUCCESS)
            {
                extern OMuword OPP_GRtext_class_id;

                omrc = om$is_ancestry_valid (
                    subclassid = classId,
                    superclassid = OPP_GRtext_class_id
                );

                if (omrc IS OM_S_SUCCESS)
                {
                    omrc = om$send (
                        msg = message GRvg.GRdelete (EMmsg, env),
                        targetid = objectId
                    );

                    if (EMSokay (omrc) AND EMSokay (*EMmsg))
                    {
                        removed = TRUE;

                        me^^EMSdpr.ids[0] = my_id;
                    }
                }
            }
        }
    }

/*
    When all booleans have their ssi tables consistently
    represented in their instance data, the following "if
    (removed AND NOT me^^EMSsfboolean.num_composites) ..." clause
    can be omitted entirely.
*/

    if (removed AND NOT me^^EMSsfboolean.num_composites)
    {
        /*
            no composites indicated in ssi table instance data
            means this object has the inconsistent flavor of ssi
            table representation in its instance data; it needs
            to replace the first element of the me^^EMSdpr.ids
            array with its first child's id rather than its own.
        */

        IGRint count;

        omrc = om$send (
            msg = message GRowner.GRget_number_components (
                EMmsg,
                &count
            ),
            targetid = my_id
        );

        if (EMSokay (omrc) AND EMSokay (*EMmsg))
        {
            /* got number components */

            if (count)
            {
                struct GRid zeroIndexChild;

/*
                send wrt message for class EMScomposite because I
                do not want the EMSsfdpr implementation of this
                message; that is, I do not necessarily want
                leaves but actual children 
*/

                omrc = om$send (
                    mode = OM_e_wrt_message,
                    msg = message EMScomposite.GRget_components (
                        EMmsg,
                        env,
                        &zeroIndexChild,
                        1,
                        &count,
                        0,
                        OM_K_MAXINT
                    ),
                    targetid = my_id
                );
    
                if (count IS 1 AND EMSokay (omrc) AND EMSokay (*EMmsg))
                {

                    me^^EMSdpr.ids[0] = zeroIndexChild.objid;
                }
                else
                {
                    removed = FALSE;
                }
            }
            else /* zero components; perhaps already removed */
            {
                me^^EMSdpr.ids[0] = NULL_OBJID;
            }

        } /* fi got number components */

    } /* fi no composites indicated in ssi table instance data */

    if (removed)
    {
        *EMmsg = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *EMmsg = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    return omrc;
}


end implementation EMSsfboolean;
