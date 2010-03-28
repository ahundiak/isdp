/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRxform

Description
        This method passes the message along to the master element,
        then to the components (with a NULL module id, which specifies
        that no Rtree manipulations are to take place).

History
        mrm     04/01/87    creation
                01/18/88    changed for v11
                07/05/89    make sure master & components exist before
                            trying to talk to them
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRmodule import GRmdremove, GRmdaddwrng;

#define TRANSLATION_2D  1   /* see MAtypemx.c */
#define TRANSLATION_3D  5   /* see MAtypemx.c */

method GRxform (IGRlong         *msg;
                struct GRmd_env *md_info; 
                IGRshort        *mx_type;
                IGRmatrix        matrix;
                GRobjid         *objid)
{
    IGRboolean          world;          /* flag for getrang */
    IGRlong             sts;            /* return code */
    OMuint              count;          /* master + components */
    GRobjid             temp_id;        /* objid for xform return */
    IGRdouble           range[6];       /* range of master element */
    OM_S_CHANSELECT     to_comp;        /* channel to master & components */
    struct GRmd_env     NULL_module;    /* no rtree operations on components */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    *objid = my_id;                 /* return self as new object */

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comp);

    sts = om$get_channel_count (object = me,
                                p_chanselect = &to_comp,
                                count = &count);

    if (!(sts & 1) || !count) goto finish;
        
    /*
     *  remove header from Rtree
     */

    if (md_info->md_id.objid != NULL_OBJID)
    {
        world = TRUE;

        sts = om$send (msg = message GRgraphics.GRgetrang
                            (msg, &md_info->md_env.matrix_type,
                             md_info->md_env.matrix, &world, range),
                       p_chanselect = &to_comp,
                       from = 0,
                       to = 0);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpaxform: failed to get range for remove\n");
#endif
            goto finish;
        }

        sts = om$send (msg = message GRmodule.GRmdremove (msg, range, &my_id),
                       targetid = md_info->md_id.objid,
                       targetos = md_info->md_id.osnum);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpaxform: failed to remove header from Rtree\n");
#endif
            goto finish;
        }
    }

    /*
     *  xform master element
     */

    sts = om$send (msg = message GRgraphics.GRxform
                          (msg, md_info, mx_type, matrix, &temp_id),
                   p_chanselect = &to_comp,
                   from = 0,
                   to = 0);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRxform: failed to xform master\n");
#endif
        goto finish;
    }

    /*
     *  xform pattern components
     */

    NULL_module = *md_info;
    NULL_module.md_id.objid = NULL_OBJID;

    sts = om$send (msg = message GRgraphics.GRxform
                          (msg, &NULL_module, mx_type, matrix, &temp_id),
                   p_chanselect = &to_comp,
                   from = 1);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRxform: failed to xform components\n");
#endif
        goto finish;
    }

    if ((*mx_type == TRANSLATION_2D) || (*mx_type == TRANSLATION_3D))
    {
        me->translation = TRUE;
    }
    else
    {
        me->translation = FALSE;
        me->translation = TRUE;     /* KLUDGE */
    }

    /*
     *  add header back to Rtree
     */

    if (md_info->md_id.objid != NULL_OBJID)
    {
        sts = om$send (msg = message GRgraphics.GRgetrang
                            (msg, &md_info->md_env.matrix_type,
                             md_info->md_env.matrix, &world, range),
                       p_chanselect = &to_comp,
                       from = 0,
                       to = 0);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpaxform: failed to get range for add\n");
#endif
            goto finish;
        }

        sts = om$send (msg = message GRmodule.GRmdaddwrng (msg, range, &my_id),
                       targetid = md_info->md_id.objid,
                       targetos = md_info->md_id.osnum);

#ifdef DEBUG
        if (!(sts & *msg & 1))
        {
            printf ("GRpaxform: failed to add header back to Rtree\n");
        }
#endif
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("msg = 0x%x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif

    return (sts);
}
end implementation GRpa;
