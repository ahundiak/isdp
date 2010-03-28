/*
Name
        GUotype5lv9

Description
        This function is used to convert elements in a reference file
        attachment to the IGDS format.  This is implemented primarily for
        drawing views.  Therefore, more emphasis is placed on getting the
        picture correct than on model integrity or design intent.

Algorithm
        Since getting the picture right is the primary goal, this function
        uses the existing code that produces plotting metafiles.  In fact, it
        goes to considerable trouble to pretend that it is translating for
        plotting.

History
        mrm     02/13/92    creation
*/

class implementation GRreffile;

#include <alloca.h>
#include "msdef.h"
#include "OMprimitives.h"
#include "dpdef.h"
#include "dpmacros.h"

extern OMuword OPP_LCcmd_iso_class_id, OPP_GRdvattach_class_id;
extern struct GRid GUwindow_being_plotted;


IGRint GUotype5lv9(msg, ref_id, ref_os, mod, file_des, dgn_buf, bs_buf,
                   ele_buf, ele_size, scale_factor, max_overflow)
IGRlong         *msg;
OM_S_OBJID      ref_id;
OMuword         ref_os;
struct GRmd_env *mod;
IGRint          *file_des;
IGRchar         *dgn_buf;
IGRchar         *bs_buf;
IGRchar         *ele_buf;
IGRint          *ele_size;
IGRdouble       *scale_factor;
IGRdouble       *max_overflow;
{
    OMuword     classid;
    IGRint      sts, i, count, size;
    IGRint	levels[32], num_prisms = 0;
    IGRlong     plot_msg;
    struct GRid         clipobj, objs[2], window;
    struct var_list	params[2];
    OM_S_CHANSELECT     ownchan;
    OM_S_OBJECT_LINKAGE *owners;

    *msg = MSSUCC;

    /* make sure that this reference file is attached to a drawing view */

    count = 0;
    GRget_to_owner_chansel(&ownchan);
    sts = om$get_channel_count(osnum = ref_os,
                               objid = ref_id,
                               p_chanselect = &ownchan,
                               count = (OMuint * ) &count);

    if (!(sts & 1) || (count == 0)) goto finish;
    
    size = sizeof(OM_S_OBJECT_LINKAGE) * count;
    owners = (OM_S_OBJECT_LINKAGE *)alloca(size);

    sts = om$get_channel_objects(osnum = ref_os,
                                 objid = ref_id,
                                 p_chanselect = &ownchan,
                                 list = owners,
                                 size = size,
                                 count = (OMuint * ) &count);

    if (!(sts & 1) || (count == 0)) goto finish;

    for (i = 0; i < count; i++)
    {
        om$get_classid(osnum = owners[i].osnum,
                       objid = owners[i].S_objid,
                       p_classid = &classid);

        sts = om$is_ancestry_valid(superclassid = OPP_GRdvattach_class_id,
                                   subclassid = classid);

        if (sts & 1) break;
    }

    if (i == count) goto finish; /* not a drawing view reference file */

    /* get the window to be referenced during conversion */

    if (!GRget_conversion_window(&window))
    {
        goto finish;            /* skip this attachment */
    }

    /* set var used by symbology overrides and horizon edges */
    
    GUwindow_being_plotted = window;

    /* set var used to find symbology overrides */

    EMSsubbs_put_locate_window(window.objid, window.osnum);

    /* get the level map for the window */

    params[0].var = LEVELS;
    params[0].var_ptr = (IGRchar *)levels;
    params[0].num_bytes = sizeof(IGRlong)*32;
    params[0].bytes_returned = (IGRlong *) &i;
    params[1].var = END_PARAM;

    sts = dp$inq_set_gragad(msg = msg,
                            inq0_set1 = 0,
                            osnum = window.osnum,
                            gragad_objid = window.objid,
                            which_error = &size,
                            var_list = params);

    /* construct a dummy owner object to group any objects resulting
       from clipping reference file objects */

    sts = om$construct(classid = OPP_LCcmd_iso_class_id,
                       osnum = (clipobj.osnum = mod->md_id.osnum),
                       p_objid = &clipobj.objid);
    if (!(sts & 1)) goto finish;

    /* fill in the obj array as expected by GRplotpass */

    objs[0] = window;
    objs[1] = clipobj;

    /* pass the plot message through the reference file */

    sts = om$send(msg = message GRreffile.GRplotpass
		       (msg, message GRvg.GRplotyourself
                            (&plot_msg, mod, dgn_buf, bs_buf, ele_buf,
                             ele_size, file_des, max_overflow,
                             objs, scale_factor),
                        levels,
                        NULL,           /* prisms - this may not be enough */
                        &num_prisms,
                        NULL, NULL),    /* filter function and args */
                  senderid = ref_id,
                  targetid = ref_id,
                  targetos = ref_os);

    /* delete the dummy owner object */

  finish:

    return(*msg & 1);
}

end implementation GRreffile;
