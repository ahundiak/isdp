/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpa.GRcopy

Description
        This method copies the pattern header object, the master
        element, and the components.  The new master and components are
        connected to the new pattern header.  The new pattern header's
        id is returned in the newid argument.

History
        mrm     07/01/87    creation
                01/19/88    update to v11
                07/05/89    make sure symbol definition exists in target os,
                            make sure header is in Rtree correctly
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"
#include "lcdef.h"
#include "lcmacros.h"

method GRcopy (IGRlong          *msg;
               struct GRmd_env  *from_mod;
               struct GRmd_env  *to_mod;
               GRobjid          *newid)
{
    IGRlong             i;              /* index */
    OMuint              count;          /* channel count */
    IGRlong             sts;            /* return code */
    GRobjid             symdef;         /* symbol definition in target os */
    struct GRid         copy;           /* object id & osnum of copy */
    struct GRid         new_header;     /* object id & osnum */
    struct GRmd_env     NULL_module;    /* module to copy components to */
    OM_S_CHANSELECT     to_comp;        /* to master & components */
    OM_S_CHANSELECT     to_sym;         /* to symbol defining pattern */
    OM_S_OBJECT_LINKAGE chan_info[1];   /* pull symbol id off channel */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comp);
    if (!(sts & 1)) goto finish;

    sts = om$make_chanselect (channame = "GRpa.to_sym",
                              p_chanselect = &to_sym);
    if (!(sts & 1)) goto finish;
        
    /*
     *  copy self to get a new header
     */

    sts = om$send (mode = OM_e_wrt_message,
                   msg = message GRgraphics.GRcopy
                        (msg, from_mod, to_mod, newid),
                   targetid = my_id);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to copy header\n");
#endif
        goto finish;
    }

    new_header.objid = *newid;
    new_header.osnum = to_mod->md_id.osnum;

    /*
     *  get the current symbol definition id
     */

    sts = lc$get_channel_objects (p_chanselect = &to_sym,
                                  list = chan_info,
                                  size = 1,
                                  count = &count);
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to get symbol definition id\n");
#endif
        goto finish;
    }

    /*
     *  make sure that the pattern symbol definition exists in the
     *  target os; GRsmdfhdr.GRcopy will make the copy only if necessary
     */

    sts = om$send (msg = message GRgraphics.GRcopy
                        (msg, from_mod, to_mod, &symdef),
                   targetid = chan_info[0].S_objid,
                   targetos = chan_info[0].osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to copy symbol definition\n");
#endif
        goto finish;
    }

    /*
     *  connect the new header to the proper symbol definition
     */

    sts = lc$connect (objid = new_header.objid,
                      osnum = new_header.osnum,
                      p_chanselect = &to_sym,
                      go_objid = symdef,
                      go_osnum = to_mod->md_id.osnum);

    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to connect new header to symbol\n");
#endif
        goto finish;
    }

    /*
     *  copy master element and connect it to the new header
     */

    sts = om$send (msg = message GRgraphics.GRcopy
                        (msg, from_mod, to_mod, &copy.objid),
                   from = 0, to = 0,
                   p_chanselect = &to_comp);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to copy master element\n");
#endif
        goto finish;
    }

    i = 0;
    copy.osnum = to_mod->md_id.osnum;

    sts = om$send (msg = message GRconnector.GRrigidconn
                        (msg, &new_header, &i),
                   targetid = copy.objid,
                   targetos = copy.osnum);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to connect master to header\n");
#endif
        goto finish;
    }

    /*
     *  get a count of the components
     */

    sts = om$get_channel_count (objid = my_id,
                                p_chanselect = &to_comp,
                                count = &count);
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("GRpa.GRcopy: failed to get a count of the components\n");
#endif
        goto finish;
    }

    /*
     *  copy each component and connect on to_components channel
     */

    NULL_module = *to_mod;
    NULL_module.md_id.objid = NULL_OBJID;

    for (i = 1; i < count; i++)
    {
        sts = om$send (msg = message GRgraphics.GRcopy
                            (msg, from_mod, &NULL_module, &copy.objid),
                       p_chanselect = &to_comp,
                       from = i, to = i);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpa.GRcopy: failed to copy component #%d\n", i);
#endif
            goto finish;
        }

        sts = om$send (msg = message GRconnector.GRrigidconn
                            (msg, &new_header, &i),
                       targetid = copy.objid,
                       targetos = copy.osnum);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRpa.GRcopy: failed to connect component ");
            printf ("#%d to new header\n", i);
#endif
            goto finish;
        }
    }

    if (to_mod->md_id.objid != NULL_OBJID)
    {
        /*
         *  make sure the new header is in the Rtree
         */

        sts = om$send (msg = message GRpa.GRaddwrng (msg, to_mod),
                       targetid = new_header.objid,
                       targetos = new_header.osnum);
#ifdef DEBUG
        if (!(sts & *msg & 1))
        {
            printf ("GRpa.GRcopy: failed to add new header to the Rtree\n");
        }
#endif
    }

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRpacopy: msg = %x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRpa;
