/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRdelete

Description
        This method deletes itself, the patterned element, and the
        pattern components.

History
        sdm     04/01/87    creation
        mrm     08/26/87    stuff NULL_OBJID in module id for deleting
                            self, since GRpa.GRownremwrng has already
                            removed this object from the R-tree
                01/18/88    update for v11
                02/09/89    check for PATTERN_KLUDGE to leave master
                07/06/89    make sure header is deleted
        scw     06/28/92    ANSI conversion
*/
    
class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "gocmacros.h"
#include "lcmacros.h"
#include "grsymdef.h"   /* kludge */
#include "grsym.h"      /* kludge */
#include "grptn.h"      /* kludge */

method GRdelete (IGRlong *msg; struct GRmd_env *md_info)
{
    IGRint              i;              /* index */
    IGRint              leave_master;   /* flag for deleting the master obj */
    IGRuint             count;          /* on to_ptn channel */
    IGRlong             sts;            /* return code */
    struct GRmd_env     NULL_mod;       /* NULL_OBJID; no R-tree operations */
    OM_S_OBJECT_LINKAGE *buffer;        /* for channel objects */
    OM_S_CHANSELECT     to_comp;        /* to master & components */
    OM_S_CHANSELECT     to_sym;         /* channel to symbol definition */

    /*
     *  The following is an ugly kludge.  See grptn.h for an explanation
     *  of this madness.  If you can think of a better solution, do it.
     */

    leave_master = (*msg == PATTERN_KLUDGE);


    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    buffer = NULL;
    count = 0;
    NULL_mod = *md_info;
    NULL_mod.md_id.objid = NULL_OBJID;

    /* 
     *  get the number of objects on to_components channel
     */

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_comp);

    sts = om$get_channel_count (object = me,
                                p_chanselect = &to_comp, 
                                count = &count);

    if (!(sts & 1)) goto finish;

    if (count)
    {
        /*
         *  get the components 
         */

        if (!(buffer = (OM_S_OBJECT_LINKAGE *)om$malloc 
                              (size = sizeof (OM_S_OBJECT_LINKAGE) * count)))
        {
#ifdef DEBUG
            printf ("GRpadelete: failed to allocate buffer for components\n");
#endif
            *msg = MANOMEMORY;
            goto finish;
        }

        sts = om$get_channel_objects (object = me, 
                                      p_chanselect = &to_comp,
                                      list = buffer,
                                      size = count, 
                                      count = &count);

        if (!(sts & 1))
        {
#ifdef DEBUG
            printf ("GRpadelete: failed to get channel objects\n");
#endif
            goto finish;
        }
    }

    /*
     *  disconnect from the pattern symbol
     */

    om$make_chanselect (channame = "GRpa.to_sym", p_chanselect = &to_sym);

    lc$wild_disconnect (p_chanselect = &to_sym);

    /*
     *  delete self
     */
 
    sts = om$send (mode = OM_e_wrt_message,
                   msg = message GRgraphics.GRdelete (msg, md_info),
                   targetid = my_id);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpadelete: GRgraphics.GRdelete failed to delete self\n");
#endif
        sts = om$send (mode = OM_e_wrt_message,
                       msg = message GRgraphics.GRdelete (msg, &NULL_mod),
                       targetid = my_id);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpadelete: GRgraphics.GRdelete failed to delete self with NULL module\n");
#endif
            sts = om$send (msg = message Root.delete (NULL),
                           targetid = my_id);
#ifdef DEBUG
            if (!(sts & 1))
            {
                printf ("GRpadelete: Root.delete failed to delete self\n");
            }
#endif
        }
    }

    if (count)
    {
        if (!leave_master)
        {
            /*
             *  delete master element
             */

            sts = om$send (msg = message GRgraphics.GRdelete (msg, md_info),
                       targetid = buffer[0].S_objid,
                       targetos = buffer[0].osnum);
#ifdef DEBUG
            printf ("GRpa.GRdelete: GRgraphics.GRdelete (master element): ");
            printf ("%#x, %#x\n", sts, *msg);
#endif
        }

        /*
         *  delete pattern components
         */

        for (i = 1; i < count; i++)
        {
            sts = om$send (msg = message GRgraphics.GRdelete (msg, &NULL_mod),
                         targetid = buffer[i].S_objid,
                         targetos = buffer[i].osnum);
#ifdef DEBUG
            printf ("GRpa.GRdelete: GRgraphics.GRdelete (%d): ", i);
            printf ("%#x, %#x\n", sts, *msg);
#endif
        }
    }

    /*
     *  remove name from directory
     */

    di$rm_objid (objid = my_id, osnum = OM_Gw_current_OS);

finish:

    if (buffer) om$dealloc (ptr = buffer);

    GR_NOTIFY_LISTENERS (msg, &sts, GR_DELETED);

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRpadelete: msg = 0x%x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRpa;
