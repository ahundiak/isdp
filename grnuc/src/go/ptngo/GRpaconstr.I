/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRconstruct

Description
        This method initializes the instance data for the pattern
        attribute header object.  If a symbol definition is specified,
        that symbol definition is copied into the local symbol library.

Notes
        The const_args.class_attr field is expected to point to a
        GRpaconstruct structure.  If the sym_def.objid field of that struct
        is NULL_OBJID, it is assumed that symbols are not being used to
        generate the pattern.

History
        mrm     12/01/87    creation
                01/29/88    copy symbol definition to local symbol library
                08/29/88    remove reference to ref_env & sym_env
                04/12/91    add to active owner
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "igrdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"
#include "lcmacros.h"
#include "grownmacros.h"

from GRmodule import GRmdaddwrng;

method GRconstruct (struct GRvg_construct *const_args)
{
    IGRint                  size;           /* index */
    IGRlong                 sts;            /* return code */
    IGRlong                *msg;            /* return code */
    GRobjid                 local_symdef;   /* sym def id in local sym lib */
    struct GRdpb_scale      dpb_scale;      /* scale from dpb */
    struct GRpaconstruct   *pa;             /* construction parameters */
    OM_S_CHANSELECT         to_sdh;         /* channel to symbol def */

    msg = const_args->msg;
    *msg = MSSUCC;
    pa = (struct GRpaconstruct *) const_args->class_attr;

    /*
     *  add header to the Rtree
     */

    sts = om$send (msg = message GRmodule.GRmdaddwrng
                        (msg, pa->range, &my_id),
                   targetid = const_args->env_info->md_id.objid,
                   targetos = const_args->env_info->md_id.osnum);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get the active angle & scale
     */

    size = sizeof (me->angle);

    sts = gr$get_active_angle (msg = msg,
                               sizbuf = &size,
                               buffer = &me->angle,
                               nret = &size);

    size = sizeof (dpb_scale);

    sts = gr$get_active_scale (msg = msg,
                               sizbuf = &size,
                               buffer = &dpb_scale,
                               nret = &size);

    /*
     *  fill in instance data
     */

    me->update = FALSE;
    me->translation = FALSE;
    me->origin[0] = pa->origin[0];
    me->origin[1] = pa->origin[1];
    me->origin[2] = pa->origin[2];
    me->scale[0] = dpb_scale.Active_xscale;
    me->scale[1] = dpb_scale.Active_yscale;
    me->scale[2] = dpb_scale.Active_zscale;
    me->dx = pa->dx;

    if (pa->sym_def.objid != NULL_OBJID)
    {
        /*
         *  copy the symbol into the local symbol library
         */

        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg,
                             &pa->sym_def.symbol_env,
                             const_args->env_info,
                             &local_symdef),
                       targetid = pa->sym_def.objid,
                       targetos = pa->sym_def.symbol_env.md_id.osnum);

        if (!(sts & *msg & 1)) goto finish;
 
        /*
         *  connect to the pattern symbol
         */

        sts = om$make_chanselect (channame = "GRpa.to_sym",
                                  p_chanselect = &to_sdh);

        if (!(sts & 1)) goto finish;

        sts = lc$connect (p_chanselect = &to_sdh,
                          go_objid = local_symdef,
                          go_osnum = const_args->env_info->md_id.osnum);
    }

    if (sts & *msg & 1)
    {
        gr$add_to_active_owner(msg = msg, mod_env = const_args->env_info);
    }

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRpa.GRconstruct failed\n");
    if (!(*msg & 1)) printf ("const_args->msg = %#x", *const_args->msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}
end implementation GRpa;
