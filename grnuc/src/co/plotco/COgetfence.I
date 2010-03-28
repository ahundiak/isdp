/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        COget_fence_range

Description
        This function returns the id of the active fence and the window
        associated with that fence.  The range of the fence in both world
        and view coordinates are also returned.  This range includes the
        view depth.

Notes
        The cvprism pointer is set to point to memory allocated in this
        routine using om$malloc.  It is the caller's responsibility to free
        this memory with om$dealloc.

Synposis
        IGRint COget_fence_range (msg, module, fence, window, 
                                  world_range, view_range, cvprism)

        IGRlong             *msg;           O   return code
        struct GRmd_env     *module;        I   current module information
        struct GRid         *fence;         O   fence id
        struct GRid         *window;        O   window id
        IGRdouble           *world_range;   O   fence range in world coordinates
        IGRdouble           *view_range;    O   fence range in view coordinates
        struct IGRcv_prism **cvprism        O   prism corresponding to the
                                                fence

Return values
        IGRint ()       TRUE, successful
                        FALSE, unsuccessful
        IGRlong msg     MSSUCC, successful
                        MSFAIL, unsuccessful

History
        mrm     01/05/88    creation
                11/03/88    change from prism to GRgsmgr.GRget_prism_extents
                01/25/89    call GRgsmgr.GRget_prism to get window id
                02/17/89    add cvprism argument
                03/09/89    change to get the view range from the fence
                            object rather than the prism
        scw     07/17/92    ansi conversion
*/

class implementation CEO_LOCATE;

#include "coimport.h"
#include "msdef.h"
#include "madef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

extern IGRboolean MAoptsxform();
extern IGRboolean MApyextents();
extern IGRboolean MAtypemx();

from GRgraphics import GRgetrang;
from GRgsmgr import GRget_prism_extents, GRget_prism, GRget_prism_size;

IGRint COget_fence_range (msg, module, fence, window, world_range, view_range,
                          cvprism)

IGRlong             *msg;           /* O return code */
struct GRmd_env     *module;        /* I current module information */
struct GRid         *fence;         /* O fence id */
struct GRid         *window;        /* O window id */
IGRdouble           *world_range;   /* O fence range in world coordinates */
IGRdouble           *view_range;    /* O fence range in view coordinates */
struct IGRcv_prism **cvprism;       /* O fence prism */

{
    IGRboolean          world;
    IGRshort            mxtype;
    IGRchar            *prism;
    IGRint              i;                  /* index */
    IGRlong             size;               /* of argument */
    IGRint              prism_type;
    IGRint              num_poles;
    IGRint              num_weights;
    IGRint              num_knots;
    IGRint              num_boundaries;
    IGRint              formatted;
    IGRlong             sts;                /* return code */
    IGRdouble           view_volume[6];     /* view volume */
    IGRmatrix           wtv;                /* rotation matrix */
    struct IGRrt_prism *rt_prism;
    struct IGRcv_prism *cv_prism;
    struct var_list     var_list[3];        /* for gragad inquiry */

    sts = TRUE;
    *msg = MSSUCC;

    /*
     *  get the active fence id
     */

    sts = gr$gsget_fence (msg = msg, fence_id = fence);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get the size of the prism associated with the fence
     */

    sts = om$send (msg = message GRgsmgr.GRget_prism_size
                        (msg, module, &prism_type, (IGRint *)&size, &num_poles,
                         &num_weights, &num_knots, &num_boundaries),
                   senderid = NULL_OBJID,
                   targetid = fence->objid,
                   targetos = fence->osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COget_fence_range: GRgsmgr.GRget_prism_size failed\n");
#endif
        goto finish;
    }

    /*
     *  allocate the space for the prism
     */

    prism = om$malloc (size = size);

    if (!(prism))
    {
#ifdef DEBUG
        printf ("COget_fence_range: om$malloc #1 failed\n");
#endif
        *msg = MANOMEMORY;
        goto finish;
    }

    /*
     *  get the window and the prism associated with the fence
     */

    formatted = FALSE;

    sts = om$send (msg = message GRgsmgr.GRget_prism
                        (msg, module, formatted, prism, window),
                   senderid = NULL_OBJID,
                   targetid = fence->objid,
                   targetos = fence->osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COget_fence_range: GRgsmgr.GRget_prism failed\n");
#endif
        goto finish;
    }

    if (prism_type == GR_RIGHT_PRISM)
    {
        /*
         *  convert the right prism to a curve prism
         */

        rt_prism = (struct IGRrt_prism *) prism;
        /* allocate for prism, poles, and knots */
        size = sizeof (struct IGRcv_prism);
        size += sizeof (IGRdouble) * rt_prism->polygon.num_points * 3;
        size += sizeof (IGRdouble) * (rt_prism->polygon.num_points + 2);
        cv_prism = (struct IGRcv_prism *) om$malloc (size = size);
        if (!(cv_prism))
        {
#ifdef DEBUG
            printf ("COget_fence_range: om$malloc #2 failed\n");
#endif
            *msg = MANOMEMORY;
            goto finish;
        }

        cv_prism->curve.poles = (IGRdouble *) (cv_prism + 1);
        cv_prism->curve.knots = cv_prism->curve.poles +
                                (rt_prism->polygon.num_points * 3);
        sts = MApytobc (msg, &rt_prism->polygon, &cv_prism->curve);
        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("COget_fence_range: MApytobc failed\n");
#endif
            goto finish;
        }

        for (i = 0; i < 16; i++)
        {
            cv_prism->matrix[i] = rt_prism->matrix[i];
        }
        cv_prism->height = rt_prism->height;
        om$dealloc (ptr = rt_prism);
        *cvprism = cv_prism;
    }
    else
    {
        *cvprism = (struct IGRcv_prism *) prism;
    }

    /*
     *  get the fence range in world coordinates
     */    

    sts = om$send (msg = message GRgsmgr.GRget_prism_extents
                        (msg, module, world_range),
                   senderid = NULL_OBJID,
                   targetid = fence->objid,
                   targetos = fence->osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COget_fence_range: GRgsmgr.GRget_prism_extents failed\n");
#endif
        goto finish;
    }

    /*
     *  get the world to view rotation matrix and the view volume
     */

    var_list[0].var = WLD_TO_VIEW;
    var_list[0].var_ptr = (IGRchar *) wtv;
    var_list[0].num_bytes = sizeof (IGRmatrix);
    var_list[0].bytes_returned = &size;
    var_list[1].var = VW_VOLUME;
    var_list[1].var_ptr = (IGRchar *) view_volume;
    var_list[1].num_bytes = 6 * (sizeof (IGRdouble));
    var_list[1].bytes_returned = &size;
    var_list[2].var = END_PARAM;

    sts = dp$inq_set_gragad (msg = msg,
                             osnum = window->osnum,
                             gragad_objid = window->objid,
                             which_error = &i,
                             var_list = var_list);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  Calculate the view range by sending a GRgraphics.GRgetrang message
     *  to the object which defines the fence.  Get the range in view
     *  coordinates by substituting the world-to-view matrix for the
     *  environment matrix passed down to the object.
     */

    MAtypemx (msg, wtv, &mxtype);

    world = TRUE;

    sts = om$send (msg = message GRgraphics.GRgetrang
                        (msg, &mxtype, wtv, &world, view_range),
                   senderid = NULL_OBJID,
                   targetid = fence->objid,
                   targetos = fence->osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("COget_fence_range: GRgraphics.GRgetrang failed\n");
#endif
        goto finish;
    }

    /*
     *  make the z range match the view z extents
     */

    view_range[2] = view_volume[2];
    view_range[5] = view_volume[5];

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COget_fence_range: msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}

end implementation CEO_LOCATE;
