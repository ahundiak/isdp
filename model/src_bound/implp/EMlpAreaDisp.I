/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

# define FIX11JULY1989 1

/*
HISTORY

20 Jul 1990 Inasu Added code for dispalying the loops of the regions
                  (Fix for TR 90n1532).

11 Jul 1989 jBk Replaced matrix and matrix_type arguments of
                EMareaDisplay message with p_env argument.

                Since Allen now tells me that those loops without
                gradata are on surfaces without boundaries, I now
                do a surface display instead of an edge traverse
                coupled with an edge display when there are no
                gradata on the helper channel of a loop.

09 May 1989 ??? (I think the date is correct -- jBk) Someone
                replaced an invocation of om$chanselect with an
                invocation of EMmake_chanselect.

22 Nov 1988 jBk Genesis.  I wanted to make generally available
                the ability of ECidentify's execute method
                implementation to display the area surrounded by
                a P-loop and its C-loops.
*/

# include "EMS.h" /* for shared libraries */

# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include "EMScmacros.h"

extern int EFfprints ();

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

# include "EMStypedef.h"
# include "EMSlmdef.h"  /* EMS_WHL_EDGE */
# include "EMSprop.h"   /* EMED_SUBORDINATE */

from EMSgradata import EMdisplay;
from EMSedge import EMdisplay;
from EMSsubbs import GRdisplay;

method EMareaDisplay (
    IGRlong *rc;
    struct GRmd_env *p_env;
    enum GRdpmode mode
)
{
    IGRshort matrix_type;
    IGRdouble *matrix;
    EMSrc omrc = OM_E_ABORT;
    OM_S_CHANSELECT helperChanselect;

    matrix_type = p_env->md_env.matrix_type;
    matrix = p_env->md_env.matrix;

    if (me^^EMSloop.lp_props & EMLP_PLOOP)
    {
        *rc = EMS_S_Success;
    }
    else
    {
        *rc = EMS_W_InvalidArg;
    }

    if (EMSokay (*rc))
    {
        omrc = EMmake_chanselect (
            EMSrequester_to_helpers,
            &helperChanselect
        );
    }

    if (EMSokay (omrc)) /* okay only via EMmake_chanselect */
    {
        OMuint count;

/*
        AIC says that sending EMSgradata.EMdisplay down an empty
        EMSrequester.to_helpers channel does not return
        OM_I_CHAN_EMPTY right now, because of some bug.  This and
        only this necessitates the following check of channel
        vacancy to determine what message is necessary to send to
        whom. -- jBk
*/

        omrc = om$get_channel_count (
            object = me,
            p_chanselect = &helperChanselect,
            count = &count
        );

        if (EMSokay (omrc))
        {
            if (count /* ISNT 0 */)
                omrc = OM_S_SUCCESS;
            else
                omrc = OM_I_CHAN_EMPTY;
        }

        if (omrc IS OM_S_SUCCESS) /* channel occupied */
        {
            /* do a gradata display */
            IGRboolean dummyBoolean = FALSE;
            struct EMSpartolbasis dummyPartol;

            EMSdbgEPS ("do a gradata display\n");

            dummyPartol.is_valid = FALSE;

            omrc = om$send (
                msg = message EMSgradata.EMdisplay (
                    rc 
                        /* IGRlong *msg */,
                    TRUE
                        /* IGRboolean owner_origin */,
                    &mode
                        /* enum GRdpmode *mode */,
                    NULL
                        /* struct DP_information *sp_info */,
                    NULL
                        /* struct IGResbs *bs_attr */,
                    NULL
                        /* struct DPele_header *ele_header */,
                    &matrix_type
                        /* IGRshort *mx_type */,
                    matrix
                        /* IGRmatrix matrix */,
                    NULL
                        /* IGRchar *buffer */,
                    0
                        /* IGRint buffer_size */,
                    &dummyPartol
                        /* struct EMSpartolbasis *partol */,
                    &dummyBoolean
                        /* IGRboolean *display_done */,
                    NULL
                        /* struct GRid *window_id */
                ),
                p_chanselect = &helperChanselect
            );

            EMSdbgMR (omrc, "gd EMdisplay omrc");
            EMSdbgMR (*rc, "gd EMdisplay *rc");
      /* The following portion is added to fix TR 90n1532 */
         {
            /* do an edge display */
            IGRushort noneMask = EMED_SUBORDINATE;

            /*
                noneMask is assigned EMED_SUBORDINATE
                because we do not want to display
                subordinate edges, just dominant
                edges -- jBk 
            */

            EMSdbgEPS ("do an edge display\n");

            omrc = om$send (
                msg = message EMSloop.EMtree_traverse (
                    rc
                        /* IGRlong *rc */,
                    message EMSedge.EMdisplay (
                        rc
                            /* IGRlong *EMmsg */,
                        NULL
                            /* struct DPele_header *ele_header */,
                        &matrix_type
                            /* IGRshort *mx_type */,
                        matrix
                            /* IGRmatrix matrix */,
                        &mode
                            /* enum GRdpmode *mode */,
                        NULL
                            /* struct DP_information
                                *sp_info */,
                        EMS_WHL_EDGE
                            /* IGRshort display_flag */,
                        NULL
                            /* struct EMSpartedinfo
                                *partinfo */
                    )
                        /* OM_p_MESSAGE messg */,
                    OM_K_MAXINT
                        /* IGRint tree_depth */,
                    1
                        /* IGRint num_classes */,
                    &OPP_EMSedge_class_id
                        /* GRclassid *classids */,
                    TRUE
                        /* IGRushort options */,
                    NULL
                        /* IGRushort all_mask */,
                    NULL
                        /* IGRushort any_mask */,
                    noneMask
                        /* IGRushort none_mask */
                ),
                targetid = my_id
            );

            EMSdbgMR (omrc, "traverse edge display omrc");
            EMSdbgMR (*rc, "traverse edge display *rc");
          }/* Insertion over  TR 90n1532 */
        } /* channel occupied */
        else if (omrc IS OM_I_CHAN_EMPTY) /* channel vacant */
        {
#           if FIX11JULY1989

            GRobjid sf;

            EMSdbgEPS ("do a surface display\n");

            omrc = om$send (
                msg = message EMSloop.EMgetsurface_info (
                    rc
                        /* IGRlong *EMmsg */,
                    &sf
                        /* GRobjid *srfid */,
                    NULL
                        /* struct EMSpartolbasis *partolbasis */
                ),
                targetid = my_id
            );

            EMSdbgMR (omrc, "get surface omrc");
            EMSdbgMR (*rc, "get surface *rc");

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                omrc = om$send (
                    msg = message EMSsubbs.GRdisplay (
                        rc
                            /* IGRlong *msg */,
                        &matrix_type
                            /* IGRshort *type */,
                        matrix
                            /* IGRmatrix matrix */,
                        &mode
                            /* enum GRdpmode *mode */,
                        &p_env->md_id
                            /* struct GRid *display_info */ 
                    ),
                    targetid = sf
                );
            }

            EMSdbgMR (omrc, "surface display omrc");
            EMSdbgMR (*rc, "surface display *rc");

#           else /* not FIX11JULY1989 */

            /* do an edge display */
            IGRushort noneMask = EMED_SUBORDINATE;

            /*
                noneMask is assigned EMED_SUBORDINATE
                because we do not want to display
                subordinate edges, just dominant
                edges -- jBk 
            */

            EMSdbgEPS ("do an edge display\n");

            omrc = om$send (
                msg = message EMSloop.EMtree_traverse (
                    rc
                        /* IGRlong *rc */,
                    message EMSedge.EMdisplay (
                        rc
                            /* IGRlong *EMmsg */,
                        NULL
                            /* struct DPele_header *ele_header */,
                        &matrix_type
                            /* IGRshort *mx_type */,
                        matrix
                            /* IGRmatrix matrix */,
                        &mode
                            /* enum GRdpmode *mode */,
                        NULL
                            /* struct DP_information
                                *sp_info */,
                        EMS_WHL_EDGE
                            /* IGRshort display_flag */,
                        NULL
                            /* struct EMSpartedinfo
                                *partinfo */
                    )
                        /* OM_p_MESSAGE messg */,
                    OM_K_MAXINT
                        /* IGRint tree_depth */,
                    1
                        /* IGRint num_classes */,
                    &OPP_EMSedge_class_id
                        /* GRclassid *classids */,
                    TRUE
                        /* IGRushort options */,
                    NULL
                        /* IGRushort all_mask */,
                    NULL
                        /* IGRushort any_mask */,
                    noneMask
                        /* IGRushort none_mask */
                ),
                targetid = my_id
            );

            EMSdbgMR (omrc, "traverse edge display omrc");
            EMSdbgMR (*rc, "traverse edge display *rc");

#           endif /* FIX11JULY1989 */
        }
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }
    else if (*rc IS EMS_W_InvalidArg)
    {
        omrc = OM_S_SUCCESS;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = EMS_E_Fail;
    }

    return omrc;
}

end implementation EMSloop;
