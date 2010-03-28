/*
Name
        GRcsbase.GRdelete

Description
        This method is overridden to disallow the deletion of the base
        coordinate system, so that there will always be at least one
        coordinate system available.

History
        kt      11/08/86    design and implementation.
        mrm     01/30/87    Return new error code
*/

class implementation GRcsbase;

#include "grimport.h"
#include "grerr.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "msdef.h"
#include "gocmacros.h"

method GRdelete (IGRlong *msg; struct GRmd_env *current_module)
{
    /*
     *  the base coordinate system object cannot be deleted
     */

    *msg = GRNODELBCS;
    return (OM_W_ABORT);
}

/*
Name
        GRcsbase.GRxform

Description
        This method is overridden to disallow manipulating the base cs.

History
        mrm     03/31/88    overridden
*/

method GRxform (IGRlong         *msg;
                struct GRmd_env *current_module;
                IGRshort        *matrix_type;
                IGRmatrix        matrix;
                GRobjid         *newobjid)
{
    *msg = MSFAIL;
    return (OM_W_ABORT);
}

/*
Name
        GRcsbase.GRcopy

Description
        This method "copies" the base cordinate system by producing a cs
        of class GRgencs.

History
        mrm     04/27/88    overridden
*/

method GRcopy (IGRlong         *msg;
               struct GRmd_env *current_mod;
               struct GRmd_env *target_mod;
               GRobjid         *newobjid)
{
    IGRshort                properties;     /* of the copy */
    IGRlong                 sts;            /* return code */
    struct IGRdisplay       display;        /* display symbology */
    struct GRvg_construct   vg_construct;   /* construction argument list */
    struct GRcs_construct   cs_construct;   /* cs-specific arguments */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  generate my abstract geometry for use in the construct
     */

    sts = om$send (msg = message GRgencs.GRgenabsg
                        (msg, &current_mod->md_env.matrix_type,
                         current_mod->md_env.matrix,
                         &vg_construct.geometry),
                   targetid = my_id);

    if (sts & *msg & 1)
    {
        /*
         *  construct the new coordinate system - do not make active
         */

        display = me->display_attr;
        display.weight = 0;

        properties = me->properties & ~GR_RIGID_RELATIONSHIP & ~GRIS_READ_ONLY;

        cs_construct.desc = NULL;
        cs_construct.flag = CS_NO_MAKE_ACTIVE | CS_CONNECT_TO_MGR;
        cs_construct.type = RECTANGULAR;

        vg_construct.msg = msg;
        vg_construct.name = NULL;
        vg_construct.newflag = FALSE;
        vg_construct.class_attr = (IGRchar *) &cs_construct;
        vg_construct.level = me->level;
        vg_construct.display = &display;
        vg_construct.properties = properties;
        vg_construct.env_info = target_mod;

        sts = om$construct (osnum = target_mod->md_id.osnum,
                            classname = "GRgencs",
                            msg = message GRgraphics.GRconstruct
                                 (&vg_construct),
                            p_objid = newobjid);
    }

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRcsbase.GRcopy failed\n");
    if (!(*msg & 1)) printf ("msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    GR_NOTIFY_LISTENERS (msg, &sts, GR_COPIED);

    return (sts);
}

end implementation GRcsbase;

