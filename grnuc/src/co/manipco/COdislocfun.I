/*
Name
        COdislocfun

Description
        This file contains functions used by the Element Display On and
        Element Locate On commands.  The function COhhlele sets up an Rtree
        pass to call COdislocfun to halfhighlight all nonlocatable or
        nondisplayable objects.

History
        xx/xx/xx  Who knows  Genesis
        03/04/92  scw        Put in SUN compiler work arounds
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "msdef.h"
#include "OMindex.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gomacros.h"

from module import GRmod_passon;
from GRgraphics import GRdisplay, GRgetprops;

/*
Function
        COhhlele

Description
        This function sets up an Rtree pass to halfhighlight all
        nonlocatable or nondisplayable objects.

History
        mrm     03/22/93    added "module." to the channel spec
*/

#argsused
IGRint COhhlele (msg, caller_id, caller_os, mod, property)

IGRlong            *msg;            /* return code */
OM_S_OBJID          caller_id;      /* calling object's id */
OMuword             caller_os;      /* calling object's osnum */
struct GRmd_env    *mod;            /* current module information */
IGRushort   property;       /* indicates display or locate */

{
    int                     r_msg;          /* for R-tree pass */
    int                     start, stop;    /* for R-tree pass */
    unsigned int            long_props;     /* pad property to a word */
    IGRint                  COdislocfun();  /* called by GRfunction */
    IGRint                  sts;            /* return code */
    IGRlong                 size;           /* dpb arg */
    IGRlong                 f_msg;          /* for GRfunction */
    OM_S_MESSAGE            rtree_msg;      /* Rtree pass msg */
    OM_S_MESSAGE            grfunc_msg;     /* msg to pass through Rtree */
    OM_S_KEY_DESC           select_key;     /* for R-tree pass */
    OM_S_KEY_DESC           target_key;     /* for R-tree pass */
    DB_3D_DBL_BOX           range_box;      /* for R-tree pass */
    DB_3D_DBL_BOX           target_box;     /* for R-tree pass */
    struct GRmd_env         loc_module;     /* mod to locate in */
    struct GRfunction_info  func_info;      /* args to COdislocfun */
    struct                                  /* args to GRfunction */
    {
        IGRlong            *msg;
        IGRint            (*function)();
        IGRchar            *info;
    } GRfunction_args;
    struct                                  /* args to Rtree passon */
    {
        OM_p_MESSAGE        grfunction_msg;
        OM_p_KEY_DESC       p_select_key;
        char               *p_criteria;
        OM_p_KEY_DESC       p_target_key;
        int               (*user_compare)();
        int                *return_status;
    } passon_args;

    /*
     *  get the locate module info
     */

    size = sizeof (loc_module);

    gr$get_locate_env (msg = msg,
                       sizbuf = &size,
                       buffer = &loc_module,
                       nret = &size);

    /* This line of code is to pacify the SUN compiler */
    long_props = (unsigned int) property;

    /*
     *  make the message to pass down the rtree -- GRfunction will
     *  call COdislocfun to highlight the necessary objects
     */

    go$build_user_function_buffer (buffer = &func_info,
                                   md_env = &loc_module,
                                   pass_on = 0,
                                   your_info = &long_props);
    GRfunction_args.msg = &f_msg;
    GRfunction_args.function = COdislocfun;
    GRfunction_args.info = (IGRchar *) &func_info;

    sts = om$make_message (classname = "GRgraphics",
                           methodname = "GRfunction",
                           size = sizeof (GRfunction_args),
                           p_arglist = &GRfunction_args,
                           p_msg = &grfunc_msg);
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("COhhlele: om$make_message GRgraphics.GRfunction failed\n");
#endif
        goto finish;
    }

    /*
     *  make the Rtree-pass message
     */

    passon_args.grfunction_msg = &grfunc_msg;
    passon_args.p_select_key = &select_key;
    passon_args.p_select_key->type = KEY_3D_DBL;
    passon_args.p_select_key->key.p_3ddbl = &range_box;
    passon_args.p_select_key->key.p_3ddbl->xmin = GRDGNLIMITS_MIN_D;
    passon_args.p_select_key->key.p_3ddbl->ymin = GRDGNLIMITS_MIN_D;
    passon_args.p_select_key->key.p_3ddbl->zmin = GRDGNLIMITS_MIN_D;
    passon_args.p_select_key->key.p_3ddbl->xmax = GRDGNLIMITS_MAX_D;
    passon_args.p_select_key->key.p_3ddbl->ymax = GRDGNLIMITS_MAX_D;
    passon_args.p_select_key->key.p_3ddbl->zmax = GRDGNLIMITS_MAX_D;
    passon_args.p_criteria = NULL;
    passon_args.p_target_key = &target_key;
    passon_args.p_target_key->key.p_3ddbl = &target_box;
    passon_args.user_compare = NULL;
    passon_args.return_status = &r_msg;

    sts = om$make_message (classname = "OMrtree",
                           methodname = "pass",
                           size = sizeof (passon_args),
                           p_arglist = &passon_args,
                           p_msg = &rtree_msg);
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("COhhlele: om$make_message OMrtree.pass failed\n");
#endif
        goto finish;
    }

    /*
     *  send the message through the R-tree
     */

    start = 0;
    stop = GRDGNLIMITS_MAX_I;

    sts = om$send (msg = message module.GRmod_passon
                        (msg, &rtree_msg, "module.primary", &start, &stop),
                   senderid = caller_id,
                   targetid = mod->md_id.objid,
                   targetos = mod->md_id.osnum);

#ifdef DEBUG
    if (!(sts & *msg & 1))
    {
        printf ("COhhlele: module.GRmod_passon failed\n");
    }
#endif

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COhhele: msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}


/*
Function
        COdislocfun

Description
        This function is called by the GRgraphics.GRfunction method
        during a pass through the R-tree initiated by the COdisloc
        command object.  Its purpose is to determine whether the calling
        object is non-displayable or non-locatable, depending upon the
        property passed in, and if so, display the object in half-highlight.

History
        mrm     05/11/87    creation
        mrm     08/21/87    use hhdo mode
        scw     03/04/92    added stuff for the Sun compiler
*/

IGRint COdislocfun (msg, caller, info)

IGRlong                 *msg;
struct GRid             *caller;
struct GRfunction_info  *info;

{
    IGRint              sts;            /* return code */
    int                *long_props;     /* long properties passed in */
    unsigned short      short_props;    /* shorted properties passed in */
    IGRushort   properties;     /* from graphic object */
    enum GRdpmode       display_mode;   /* GRhhd */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    sts = om$send (msg = message GRgraphics.GRgetprops (msg, (IGRshort *)&properties),
                   senderid = caller->objid,
                   targetid = caller->objid,
                   targetos = caller->osnum);

    /* These lines of code are to pacify the SUN compiler.           */
    /* For some strange reason it couldn't handle it all on one line */
    long_props = (int *)info->info;
    short_props = (unsigned short) *long_props;

    if ((sts & *msg & 1) &&
        (!(properties & short_props)) &&
        (!(properties & GRIS_READ_ONLY)))
    {
        display_mode = GRhhdo;

        sts = om$send (msg = message GRgraphics.GRdisplay
                            (msg, &info->md_env->md_env.matrix_type,
                             info->md_env->md_env.matrix,
                             &display_mode, &info->md_env->md_id),
                       senderid = caller->objid,
                       targetid = caller->objid,
                       targetos = caller->osnum);

    }

    return (sts);
}

end implementation CEO_GSLOCATE;
