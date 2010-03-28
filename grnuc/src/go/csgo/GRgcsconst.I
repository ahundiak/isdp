/*
Name
        GRgencs.GRconstruct

Description
        This method initializes the newly constructed coordinate system
        by setting up its instance data, name and description (if specified),
        optionally hooking it to the proper channels on its coordinate system
        manager or making it active, ...

Notes
        The class_attr field in the construction argument structure should
        point to a filled-in GRcs_construct (see grcoordsys.h) structure on
        entry.

History
        mrm     03/02/88    creation, some code moved from old
                            GRgencs.GRinitialize method
	jhw	01/23/89    changed call to di$add_name to fix cs
			    naming problem
        dhm     08/06/91    added coordinate system type
        mrm     03/23/92    make sure name goes in target object space
                04/02/92    removed previous fix; this was actually writing
                            the cs name in the root directory of the os */

class implementation GRgencs;

#include "grimport.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "msdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

from GRmodule import GRmdaddwrng;
from GRcsmgr import GRset_active_cs;

method GRconstruct (struct GRvg_construct *args)
{
    IGRshort                i;              /* index */
    IGRlong                 sts, *msg;      /* return codes */
    IGRlong                 flag;           /* flex connect flag */
    IGRlong                 owners_index;   /* index to at which to connect */
    IGRlong                 graphics_index; /* index to at which to connect */
    GRobjid                 new_id;         /* for post method */
    GRrange                 range;          /* to store range */
    struct GRid             csmgr;          /* coordinate system manager */
    struct GRpost_info      post;           /* processing information */
    struct GRcs_construct   *cs_args;       /* cs-specific arguments */
    OM_S_OBJID              new_mod_id;     /* target module id */

    msg = args->msg;
    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  set up the display symbology and properties word
     */

    me->level = args->level;
    me->display_attr = *(args->display);
    me->properties = args->properties | GRIS_NEW;

    /*
     *  set up name and description and type
     */

    if (args->name)
    {
        sts = di$add_name (objname = args->name,
			   objid = my_id);
#ifdef DEBUG
        if (!(sts & 1))
            di$report_error (sts = sts, comment = "GRgcsconst: di$add_name");
#endif
    }

    cs_args = (struct GRcs_construct *)args->class_attr;

    if (cs_args->desc)
    {
        sts = om$vla_set_dimension (varray = me->description,
                                    size = strlen (cs_args->desc) + 1);
        strcpy (me->description, cs_args->desc);
    }

    /*     
     * initialize the type
     */

    if ( (cs_args->type >= 0) && (cs_args->type < 3) )
       me->type = cs_args->type;
    else
       me->type = RECTANGULAR;

    /*
     *  initialize the scale
     */

    me->scale[0] = 1.0;
    me->scale[1] = 1.0;
    me->scale[2] = 1.0;

    /*
     *  post the geometry
     */

    post.construct_flag = TRUE;

    sts = om$send (msg = message GRvg.GRpostabsg
                        (msg, args->env_info, &post, args->geometry, &new_id),
                   targetid = my_id);

    if (!(sts & *msg & 1)) goto finish;

    if (args->env_info->md_id.objid != NULL_OBJID)
    {
        /*
         *  get the range of the geometry and add the object to the Rtree
         */

	new_mod_id = args->env_info->md_id.objid; 

        i = TRUE;

        sts = om$send (msg = message GRgraphics.GRgetrang
                            (msg, &args->env_info->md_env.matrix_type,
                             args->env_info->md_env.matrix, &i, range),
                       targetid = my_id);

        if (!(sts & *msg & 1)) goto finish;

        sts = om$send (msg = message GRmodule.GRmdaddwrng (msg, range, &my_id),
                       targetid = args->env_info->md_id.objid,
                       targetos = args->env_info->md_id.osnum);

        if (!(sts & *msg & 1)) goto finish;
    }
    else
    {
        sts = ex$get_modid (mod_osnum = args->env_info->md_id.osnum,
                                mod_id = &new_mod_id);

        if (!(sts & 1)) goto finish;

    }

    if (cs_args->flag & (CS_CONNECT_TO_MGR | CS_MAKE_ACTIVE))
    {
        /*
         *  get the coordinate system manager's id
         */

        sts = ex$get_super (mod_id = new_mod_id, 
                            mod_osnum = args->env_info->md_id.osnum,
                            super_name = CoordSysMgr,
                            create = TRUE,
                            super_class = "GRcsmgr",
                            super_id = &csmgr.objid,
                            super_osnum = &csmgr.osnum);

        if (!(sts & 1))	goto finish;

    }

    if ((cs_args->flag & CS_CONNECT_TO_MGR) == CS_CONNECT_TO_MGR)
    {
        /*
         *  connect to the coordinate system manager on the
         *  to_owner - to_components channel
         */

        flag = 1;      /* connect with override */

        owners_index = graphics_index = OM_K_MAXINT;

        sts = om$send (msg = message GRconnector.GRflexconn
                           (msg, &flag, &csmgr, &owners_index, &graphics_index),
                       targetid = my_id);

        if (!(sts & *msg & 1)) goto finish;
    }

    if ((cs_args->flag & CS_MAKE_ACTIVE) == CS_MAKE_ACTIVE)
    {
        /*
         *  make the coordinate system active
         */

        sts = om$send (msg = message GRcsmgr.GRset_active_cs
                            (msg, args->env_info, my_id),
                       targetid = csmgr.objid);
    }


finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRgencs.GRconstruct failed\n");
    if (!(*msg & 1)) printf ("msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRgencs;
