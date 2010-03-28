/* #######################    APOGEE COMPILED   ######################## */
/*
 HISTORY:
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "dpstruct.h"
#include "OMindex.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

method GRdisyourself (IGRlong               *msg;
                      IGRshort              *type;
                      IGRmatrix              matrix;
                      enum GRdpmode         *mode;
                      struct IGRaltdisplay  *alt_symb;
                      struct DP_information *sp_info;
                      OM_p_KEY_DESC          key)
{
    IGRlong         sts;        /* return code */
    IGRint          size;       /* of module structure */
    struct GRmd_env mod;        /* current module info */
    OM_S_CHANSELECT ptn_chan;   /* channel to components */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &ptn_chan);

    if (me->update)
    {
        size = sizeof (struct GRmd_env);
        sts = gr$get_module_env (msg = msg,
                                 sizbuf = &size,
                                 buffer = &mod,
                                 nret = &size);                    

        if (!(sts & *msg & 1)) goto finish;

        sts = om$send (msg = message GRpa.GRgenerate (msg, &mod),
                       targetid = my_id);

        me->update = FALSE;

        if (!(sts & *msg & 1)) goto finish;
    }
        
    sts = om$send (msg = message GRgraphics.GRdisyourself
                          (msg, type, matrix, mode, alt_symb, sp_info, key),
                   p_chanselect = &ptn_chan);
finish:

    return (sts);
}


method GRplotyourself (IGRlong          *msg;
                       struct GRmd_env  *md_env;
                       IGRchar          *dgn_buf;
                       IGRchar          *bs_buf;
                       IGRchar          *ele_buf;
                       IGRint           *ele_size;
                       IGRint           *file_des;
                       IGRdouble        *max_overflow;
                       struct GRid      *window_id;
                       IGRdouble        *scale_factor)
{
    IGRlong         sts;        /* return code */
    IGRint          size;       /* of module structure */
    struct GRmd_env mod;        /* current module info */
    OM_S_CHANSELECT ptn_chan;   /* channel to components */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &ptn_chan);

    if (me->update)
    {
        size = sizeof (struct GRmd_env);
        sts = gr$get_module_env (msg = msg,
                                 sizbuf = &size,
                                 buffer = &mod,
                                 nret = &size);                    

        if (!(sts & *msg * 1)) goto finish;

        sts = om$send (msg = message GRpa.GRgenerate (msg, &mod),
                       targetid = my_id);

        me->update = FALSE;

        if (!(sts & *msg & 1)) goto finish;
    }
        
    sts = om$send (msg = message GRgraphics.GRplotyourself
                          (msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size,
                           file_des, max_overflow, window_id, scale_factor),
                  p_chanselect = &ptn_chan);
finish:

    return (sts);
}

end implementation GRpa;
