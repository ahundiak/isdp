/*
Name
        COtform - erase, transform, and highlight

Synopsis
        IGRint COtform (msg, module, t_matrix, caller_id, caller_os, chansel)

        IGRlong         *msg;           o return code
        struct GRmd_env *module;        i module object
        IGRdouble       *t_matrix;      i matrix to apply to graphics object
        GRobjid          caller_id;     i calling object's id
        OMuword          caller_os;     i calling object's osnum
        OM_S_CHANSELECT *chansel;       i channel the graphics set is on

Description
        This function to erases, transforms, and highlights graphic object(s).
        The function assumes that all operations are to be performed through a
        graphic set channel.

Return values
        return value    OM_S_SUCCESS => success, else OM failure
        msg             (msg & 1) == 1 => success, else function failure

History
        Mike Mathis     07/28/86    Creation
                        09/22/86    OM 4.0 conversion
        Gray Winn       10/08/86    Convert to graphics sets
        Mike Mathis     03/09/87    Revise include files
                        07/29/88    changed arg list for COB conversion
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "grgsmacros.h"

extern IGRboolean MAtypemx();

from GRgraphics import GRxform;

#argsused
IGRint COtform (msg, module, t_matrix, caller_id, caller_os, chansel)

IGRlong         *msg;           /* o return code */
struct GRmd_env *module;        /* i module object */
IGRdouble       *t_matrix;      /* i matrix to apply to graphics object */
GRobjid          caller_id;     /* i calling object's id */
OMuword          caller_os;     /* i calling object's osnum */
OM_S_CHANSELECT *chansel;       /* i channel the graphics set is on */

{
    GRobjid         new_objid;  /* new object's id */
    IGRlong         status;     /* return code */
    IGRshort        mx_type;    /* type of transformation */
    struct GRmd_env context;    /* dummy context; filled in by graphics set */

    /*
     *  send message through graphics set channel to erase self
     */

    status = gr$gsdisplay (msg = msg,
                           dpmode = GRbehe,
                           display_id = &module->md_id,
                           senderid = caller_id,
                           p_chanselect = chansel);

    if (status & *msg & 1)
    {
        MAtypemx (msg, t_matrix, &mx_type);

        /*
         *  send message through graphics set channel to GO to apply 
         *  t_matrix to self
         */

        status = gr$gspass (msg = msg,
                            pass_msg = message GRgraphics.GRxform 
                                      (msg,
                                       &context,
                                       &mx_type, 
                                       t_matrix,
                                       &new_objid),
                            path = &context, 
                            senderid = caller_id,
                            p_chanselect = chansel);

        if (status & *msg & 1)
        {
            /*
             *  send message through graphics set channel to highlight self
             */
                
            status = gr$gsdisplay (msg = msg,
                                   dpmode = GRbdhd,
                                   display_id = &module->md_id,
                                   senderid = caller_id,
                                   p_chanselect = chansel);
        }
    }
    return (status & *msg & 1);
}

end implementation CEO_GSLOCATE;
