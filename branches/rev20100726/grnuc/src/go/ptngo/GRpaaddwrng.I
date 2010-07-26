/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRaddwrng

Description
            This method updates the range in the Rtree for the header
        and the master element.

History
        mrm     02/05/88    creation
	ashok	09/27/90    modified to send GRgraphics.GRaddwrng to master
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

from GRmodule import GRmdaddwrng;

method GRaddwrng (IGRlong *msg; struct GRmd_env *module)
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
        printf ("GRpaaddwrng: GRgraphics.GRgetrang failed\n");
#endif
        goto finish;
    }

    /*
     *  update the master's range
     */

    sts = om$get_channel_objects (object = me,
                                  p_chanselect = &to_comp,
                                  list = list,
                                  size = 1,
                                  count = &count);

    if (!(sts & 1) || !count) goto finish;

/** BLOCK Added By Ashok - 28/Sep/1990 **/
/** Modified to send GRgraphics.GRaddwrng to master instead of 
    GRmodule.GRmdaddwrng */

/* *********    commented out - 28/Sep/1990

      sts = om$send (msg = message GRmodule.GRmdaddwrng
                        (msg, range, &list[0].S_objid),
                     targetid = module->md_id.objid,
                     targetos = module->md_id.osnum);

      if (!(sts & *msg & 1))
      {
#ifdef DEBUG
        printf ("GRpaaddwrng: GRmodule.GRaddwrng failed to add master\n");
#endif

        goto finish;
      }

   ********** */
            
      sts = om$send(msg = message GRgraphics.GRaddwrng(msg, module),
                              targetid = list[0].S_objid,
                              targetos = list[0].osnum);
      if (!(sts & *msg & 1))
      {
#ifdef DEBUG
        printf ("GRpaaddwrng: GRgraphics.GRaddwrng failed to add master\n");
#endif

        goto finish;
      }
/** BLOCK END - Ashok **/

    /*
     *  update the header's range
     */

    sts = om$send (msg = message GRmodule.GRmdaddwrng (msg, range, &my_id),
                   targetid = module->md_id.objid,
                   targetos = module->md_id.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpaaddwrng: GRmodule.GRaddwrng failed to add header\n");
#endif
        goto finish;
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRpaaddwrng: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRpa;
