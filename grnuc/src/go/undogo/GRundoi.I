/* #######################    APOGEE COMPILED   ######################## */



/*
Name
        super_construct

Description
        This method initializes the instance data of the undo object.

Return Codes

        ()      OM_S_SUCCESS

History
        mrm     09/17/87    updated to new subclassing
        scw     08/09/94    clarified sleep method
*/
class implementation GRundo;

#include "msdef.h"
#include "exmacros.h"
#include "grgsmacros.h"
#include "OMerrordef.h"

from GRgraphics import GRdelete;

method super_construct ()
{
    /*
     *  initialize instance data
     */

    me->can_undo = FALSE;
    me->undo_on = FALSE;
    me->was_gra_set = FALSE;

    return (OM_S_SUCCESS);
}

/*
Name
        wake_up

Description
        This method deletes any objects saved from a previous design
        session.  There should not be any there since the sleep method
        deletes them when the object space is closed, but this check is
        in case any files slipped through with deleted objects saved.
        This override may be discontinued at some future date.

History
        mrm     02/25/88    overridden
*/

method wake_up ()
{
    IGRlong             sts, msg;   /* return code */
    OMuint              count;      /* of channel objects */
    OM_S_CHANSELECT     to_saved;   /* to saved object */

    msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (me->can_undo)
    {
        if (me->was_gra_set)
        {
            me->can_undo = FALSE;    /* sets are not saved across sessions */
        }
        else
        {
            /* check channel count */

            sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                      p_chanselect = &to_saved);
            count = 0;

            sts = om$get_channel_count (object = me,
                                        p_chanselect = &to_saved,
                                        count = &count);
            if ((sts & 1) && (count > 0))
            {
                /* object on channel, get current module id */

                me->context.md_id.osnum = OM_Gw_current_OS;

                sts = ex$get_modid (mod_osnum = me->context.md_id.osnum,
                                    mod_id = &me->context.md_id.objid);

                if (sts & 1)    /* delete the object */
                {
                    sts = om$send (msg = message GRgraphics.GRdelete
                                        (&msg, &me->context),
                                   p_chanselect = &to_saved);
                }
            }
            me->can_undo = FALSE;
        }
    }

#   ifdef dbg
        printf ("GRundo.GRwake_up: sts = %x, msg = %x\n", sts, msg);
#   endif

    return (sts);
}

method global_class.sleep (int type_sleep)
{
    IGRlong             sts, msg;       /* return codes */
    OM_S_CHANSELECT     to_saved;       /* to saved object */
  
    msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (me->can_undo)   /* delete the object(s) */
    {
        if (me->was_gra_set)
        {
            sts = om$make_chanselect (channame = "GRundo.to_grset",
                                      p_chanselect = &to_saved);
            if (sts & 1)
            {
                sts = gr$gsdelete (msg = &msg, p_chanselect = &to_saved);
            }
        }
        else
        {
            sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                      p_chanselect = &to_saved);
            if (sts & 1)
            {
                sts = om$send (msg = message GRgraphics.GRdelete
                                    (&msg, &me->context),
                               p_chanselect = &to_saved);
            }
        }
        me->can_undo = FALSE;
    }

#   ifdef dbg
        printf ("GRundo.GRwake_up: sts = %x, msg = %x\n", sts, msg);
#   endif

    return (sts);
}

end implementation GRundo;
