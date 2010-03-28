/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRremwrng

Description
            This method removes the header and the master element from
        the Rtree.

History
        mrm     02/05/88    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

from GRmodule import GRmdremove;

method GRremwrng (IGRlong *msg; struct GRmd_env *module)
{
    IGRboolean          world;      /* indicates don't apply env matrix */
    OMuint              count;      /* of objects on to_component channel */
    IGRlong             sts;        /* return code */
    GRrange             range;      /* range of object */
    OM_S_CHANSELECT     to_comp;    /* channel to master & components */
    OM_S_OBJECT_LINKAGE list[1];    /* to get master's id off channel */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    world = FALSE;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comp);

    if (!(sts & 1)) goto finish;

    /*
     *  get the range of the master element
     */

    sts = om$send (msg = message GRgraphics.GRgetrang
                        (msg, &module->md_env.matrix_type,
                         module->md_env.matrix, &world, range),
                   from = 0, to = 0,
                   p_chanselect = &to_comp);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRparemwrng: GRgraphics.GRgetrang failed\n");
#endif
        goto finish;
    }

    /*
     *  remove the master
     */

    sts = om$get_channel_objects (object = me,
                                  p_chanselect = &to_comp,
                                  list = list,
                                  size = 1,
                                  count = &count);

    if (!(sts & 1) || !count) goto finish;

    sts = om$send (msg = message GRmodule.GRmdremove
                        (msg, range, &list[0].S_objid),
                   targetid = module->md_id.objid,
                   targetos = module->md_id.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRparemwrng: GRmodule.GRremove failed to remove master\n");
#endif
        goto finish;
    }

    /*
     *  remove the header
     */

    sts = om$send (msg = message GRmodule.GRmdremove (msg, range, &my_id),
                   targetid = module->md_id.objid,
                   targetos = module->md_id.osnum);

#ifdef DEBUG
    if (!(sts & *msg & 1))
    {
        printf ("GRparemwrng: GRmodule.GRremove failed to remove header\n");
    }
#endif

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRparemwrng: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRpa;
