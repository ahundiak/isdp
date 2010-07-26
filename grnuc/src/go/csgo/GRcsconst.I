/*
Name
        GRcsmgr.GRconstruct_new_cs

Description
        This method constructs and makes active a new coordinate system
        of the specified class.

Notes
        If the cs is to be nameless, the csname pointer should be NULL;
        ditto for the description.

History
        Kumar Talluri   10/15/86    Design and Implementation.
        mrm             10/14/87    subclassing changes
                        03/04/88    use GRconstruct rather than GRinitialize
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "csdef.h"
#include "grcoordsys.h"

from GRgraphics import GRconstruct;

method GRconstruct_new_cs (IGRlong               *msg;
                           IGRchar               *classname;
                           struct GRvg_construct *cnst_lis;
                           IGRchar               *csname;
                           IGRchar               *csdesc)
{
    IGRlong                 sts;            /* return code */
    GRobjid                 coord_sys;      /* id of constructed object */
    struct GRvg_construct   local_args;     /* to construct method */
    struct GRcs_construct   cs_args;        /* cs-specific arguments */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    /*
     *  set up construct args
     */

    local_args = *cnst_lis;

/*  KLUDGE to make some existing code work

    local_args.name = (csname) ? csname : NULL;
*/
    if (csname && *csname != '\0')
        local_args.name = csname;
    else
        local_args.name = NULL;

    if (!local_args.class_attr)
    {
#ifdef DEBUG
        printf ("GRconstruct_new_cs: class_attr filled in locally\n");
#endif
        local_args.class_attr = (IGRchar * )&cs_args;

/*      ditto

        cs_args.desc = (csdesc) ? csdesc : NULL;
*/
        if (csdesc && *csdesc != '\0')
            cs_args.desc = csdesc;
        else
            cs_args.desc = NULL;

        cs_args.flag = CS_MAKE_ACTIVE | CS_CONNECT_TO_MGR;
    }

    /*
     *  construct the new coordinate system
     */

    sts = om$construct (osnum = cnst_lis->env_info->md_id.osnum,
                        classname = classname,
                        msg = message GRgraphics.GRconstruct (&local_args),
                        p_objid = &coord_sys);


#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRcsmgr.GRconstruct_new_cs failed\n");
    if (!(*msg & 1)) printf ("msg = %x\n");
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRcsmgr;
