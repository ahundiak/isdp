/* ###################   APOGEE COMPILED   ################## */
class implementation GRgraphics;

# include "EMS.h"           /* for sharables */

# ifndef DRAFT112
# define DRAFT112 0
# endif

/*
HISTORY

27 Jan 1989 jBk Moved inclusion of EMS.h to beginning of
                implementation.
29 Aug 1988 jBk Modified to use dp$build_dis_buffer and
                dp$display instead of directly assigning fields
                of element display headers and directly sending
                message IGEdisplay.DPdisbybuf.
                Changed from implementation of Root to
                implementation of GRgraphics.
*/

# include "OMerrordef.h"    /* OM error code defintions */

# include "dpdef.h"         /* dpmacros.h */
# include "dpmacros.h"      /* dp$display dp$build_dis_buffer */

# include "EMSlogic.h"      /* ISNT */
# include "EMSmsgdef.h"     /* EMS_E_InvalidArg */

IGRlong ECdisplayBsplineBybuffer
(
msg, this_Active_display, this_ModuleInfo, this_id, incurve,
mode, type
)
IGRlong             *msg;
struct IGRbsp_curve *incurve;
struct IGRdisplay   this_Active_display;
struct GRmd_env     this_ModuleInfo;
OM_S_OBJID          this_id;
enum                GRdpmode mode;
IGRshort            type;
{
    IGRlong omrc = OM_S_SUCCESS;

    *msg = EMS_S_Success;

    if (type ISNT IGRBC)
    {
        *msg = EMS_E_InvalidArg;
        omrc = OM_E_ABORT;
    }
    else
    {
        struct  DPele_header displayHeader;
        struct IGResbc cvElementSpecific;

        &cvElementSpecific;

        cvElementSpecific.is_polydis = FALSE;
        cvElementSpecific.is_curvedis = TRUE;

        dp$build_dis_buffer (
            buffer = &displayHeader,
            type = IGRBC,
            display_att = &this_Active_display,
            ele_spec_att = &cvElementSpecific,
            geometry = incurve
        );

#       if NOT DRAFT112
        omrc =
#       endif

        dp$display (
            msg = msg,
            osnum = this_ModuleInfo.md_id.osnum,
            objid = this_ModuleInfo.md_id.objid,
            mode = mode,
            num_elem = 1,
            buffer = &displayHeader
        );
    }

    return omrc;
}

end implementation GRgraphics;
