/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRudundo

Synopsis
        method GRudsave (long *msg; int undo_status)

Description
        This method turns the displayable & locatable bits
        of the object(s) on the undo_chan.

Notes
        Initially undo supports only "undelete"

        Return codes
            undo_status = MSFAIL            Failure
                        = MSSUCC            Success
                        = GR_F_UndelOff     Undo is turned off
                        = GR_F_NothUndel    No undo information is available    
History
        mrm     09/05/86    Creation
                10/14/86    OM 4.0 conversion
                09/23/87    Channel changes
                08/18/88    changed return codes for off and no info
                06/23/89    don't count on me->can_undo; check channel count
*/

class implementation GRundo;

#include "grimport.h"
#include "madef.h"
#include "godef.h"
#include "msdef.h"
#include "grgsmacros.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "grmessage.h"

#define UNDOOFF    GR_F_UndelOff
#define UNDONOINFO GR_F_NothUndel

from GRgraphics  import GRdisplay;
from GRconnector import GRdisconn;
from GRvg        import GRchgprops;

method GRudundo (long *msg; int *undo_status)
{
    long                sts;            /* return code */
    IGRboolean          set;            /* flag for chprops */
    short unsigned      properties;     /* flag for chprops */
    struct GRid         display_obj;    /* current module */
    struct GRid         myGRid;         /* id & os */
    enum GRdpmode       dpmode;         /* to redisplay in */
    OMuint              object_count;   /* number of objs on undel channel */
    OM_S_CHANSELECT     save_chan;      /* channel to saved object(s) */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    *undo_status = MSSUCC;

    if (!me->undo_on)
    {
        *undo_status = UNDOOFF;     /* undo turned off */
    }
    else if (!me->can_undo)
    {
        *undo_status = UNDONOINFO;  /* no undo information available */
    }
    else
    {
        if (me->was_gra_set)
        {
            sts = om$make_chanselect (channame = "GRundo.to_grset",
                                      p_chanselect = &save_chan);
        }
        else
        {
            sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                      p_chanselect = &save_chan);
        }

        /* make sure that there is something on the channel */

        sts = om$get_channel_count (object = me,
                                    p_chanselect = &save_chan,
                                    count = &object_count);

        if (!(sts & 1) || !object_count)
        {
            me->can_undo = FALSE;
            goto finish;
        }

        /*
         *  turn on display & locate bits in GO on delete channel
         */

        set = TRUE;
        properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        if (me->was_gra_set)
        {
            sts = om$make_chanselect (channame = "GRundo.to_grset",
                                      p_chanselect = &save_chan);

            sts = gr$gspass (msg = msg,
                             pass_msg = message GRvg.GRchgprops
                                       (msg, &set, (IGRshort *)&properties),
                             p_chanselect = &save_chan);
        }
        else
        {
            sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                      p_chanselect = &save_chan);

            sts = om$send (msg = message GRvg.GRchgprops 
                                  (msg, &set, (IGRshort *)&properties),
                           p_chanselect = &save_chan);

        }
        if (!(sts & *msg & 1))
        {
            *undo_status = MSFAIL;
            goto finish;
        } 

        /*
         *  redisplay the object
         */

        dpmode = GRbdhe;

        sts = ex$get_cur_mod (id = &display_obj.objid,
                              osnum = &display_obj.osnum);

        if (me->was_gra_set)
        {
            sts = gr$gsdisplay (msg = msg,
                                dpmode = dpmode,
                                display_id = &display_obj,
                                p_chanselect = &save_chan);
        }
        else
        {
            sts = om$send (msg = message GRgraphics.GRdisplay
                                (msg, &me->context.md_env.matrix_type,
                                 me->context.md_env.matrix, &dpmode,
                                 &display_obj),
                           p_chanselect = &save_chan);
        }
        if (!(sts & *msg & 1))
        {
            *undo_status = MSFAIL;
            goto finish;
        }

        /*
         *  disconnect everything from the undo channel
         */

        if (me->was_gra_set)
        {
            sts = om$send (msg = message Root.wild_disconnect (save_chan),
                           targetid = my_id,
                           targetos = OM_Gw_current_OS);
        }
        else
        {
            myGRid.objid = my_id;
            myGRid.osnum = OM_Gw_current_OS;

            sts = om$send (msg = message GRconnector.GRdisconn (msg, &myGRid),
                           p_chanselect = &save_chan);
        }
        if (sts & *msg & 1)
        {
            me->can_undo = FALSE;
        }
    }

finish:

    return (sts);
}

end implementation GRundo;
