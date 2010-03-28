/*
Name
        COevgen

Description
        This class defines instance data and actions (methods) intended
        for use by event generators.

History
        mrm     02/17/88    creation
	jhw	11/07/88    changed pt at intersection so the locate point
                            identifies the segment to be intersected rather
                            than the accept point
        mrm     04/17/90    added display segment
                06/14/90    added erase highlight plane
        scw     07/13/92    ansi conversion
*/

class               COevgen
super_class         CEO_LOCATE
product_name        "$SOURCE"
start_state         terminate
options             "t"

/*-----*/

specification

#define MAXEVENTS    4

instance
{
    struct GRevent      events[MAXEVENTS];    /* event pushed on queue */
}

/*-----*/

implementation

#include "coimport.h"
#include <stdio.h>
#include "dpmacros.h"
#include "msdef.h"
#include "grmessage.h"
#include "coevindex.h"
#include "maerr.h"

extern IGRlong (*CO_GA_ev_func[])();    /* function-pointer array */
extern IGRlong COtkselect();            /* tentative keypoint select handler */

from GRgraphics import GRlocaldp;

/*
Action
        use_events

Description
        This action invokes the noninteractive function referenced by 
        me->mytype in the global array CO_GA_ev_func.
*/

action use_events ()
{
    struct GRid     mygrid;

    me->ret = MSSUCC;

    mygrid.objid = my_id;
    mygrid.osnum = OM_Gw_current_OS;

    if ((me->mytype == COev_pt_intersection || me->mytype == COev_pt_snap)
        && me->events[0].num_id == 2)
    {
        me->events[1].located_object[0] = me->events[0].located_object[1];
        me->events[3].located_object[0] = me->events[0].located_object[1];
    }

#ifdef UseFirstTwoFound
    /*
        This code will intersect the first two of several elements
        found.  It is removed since an accept/reject cycle has been
        decreed.
    */

    if (me->mytype == COev_pt_snap &&
        me->events[0].num_id == 0 &&
        me->stack.num_entries > 2)
    {
        me->events[0].num_id = 2;
        me->events[0].located_object[0] = me->stack.entry[0];
        me->events[1].located_object[0] = me->stack.entry[1];
    }
#endif

    status = CO_GA_ev_func[me->mytype] (&me->ret, &mygrid, me->events);

    if ((me->mytype == COev_pt_intersection || me->mytype == COev_pt_snap) &&
        (me->events[0].num_id == 2) &&
        (me->ret == MANOSOLUTION))
    {
        /*
            The objects failed to intersect (probably parallel or
            coincident).  The command will try to recover by ignoring
            the second (auto-accepted) element and prompting the user to
            identify another "second" element.  The num_id field must be
            reset to avoid falling back through the same trap.
        */

        me->events[0].num_id = 1;
    }
        
#ifdef dbg
    if (!(status & me->ret & 1))
        printf ("COevgen.use_events: noninteractive function failed\n");
    if (!(me->ret & 1)) printf ("COevgen.use_events: me->ret = %x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif
}



/*
Action
        store_event (int f, t)

Description
        This action stores user input into COevgen instance data.  The
        argument "f" signals which CEO event to store; "t" specifies
        which COevgen event in which to store the data.

Notes
        The from argument "f" should be 1, 2 or 3; the to argument "t" can
        range from 0 to the max number of COevgen args.
*/

action store_event (int f, t)
{
    if (f > 0 && f < 3 && t >= 0 && t < MAXEVENTS)
    {
        me->ret = MSSUCC;
        me->events[t] = (f == 1) ? me->event1 : me->event2;
    }
    else
    {
        me->ret = MSFAIL;
    }
}

/*
Action
        push_event

Description
        This action pushes an one of the COevgen events 
        onto the event queue based on the input argument n.
*/

action push_event (int n)
{
    IGRlong         size;

    if ((n >= 0) && (n < MAXEVENTS)) {

        size = sizeof (struct GRevent) - (2 * (sizeof (IGRint)));

        status = ex$putque (msg = &me->ret,
                            pos = FRONT,
                            response = &(me->events[n].response),
                            byte = &size,
                            buffer = (IGRchar *)&(me->events[n].event));
    }
    else me->ret = MSFAIL;
}

/*
Action
        display_coords

Description
        This action displays the coordinates of the point in me->event1
        or me->event2 (based on n) in the keyin field.  If n is anything
        besides 1 or 2, then the event me->events[abs(n)] is used (hokey,
        but it works).
*/

action display_coords (int n)
{
    struct GRevent  *event;

    if (n == 1)
        event = &me->event1;
    else if (n == 2)
        event = &me->event2;
    else
        event = &me->events[abs(n)];

    status = COdiscoords (&me->ret, &event->event.button, &me->ModuleInfo,
                          KEYIN_FIELD, LEFT_JUS);
}


/*
Action
        move_angle_to_event

Description
        This action places the active angle in one of the COevgen events
        referenced by n.
*/

action move_angle_to_event (int n)
{
    me->ret = MSSUCC;

    if ((n >= 0) && (n < MAXEVENTS)) 
        me->events[n].event.value = me->ActiveAngle;
    else
        me->ret = MSFAIL;
}


/*
Action
        setup_select_handler

Description
        This action sets the pointers for the locate select handler for the
        tentative keypoint snap command.
*/

action setup_select_handler ()
{
    me->select = (char(*)())COtkselect;
    me->select_args = (char *)&me->event2;
}

/*
Action
        display_segment

Description
        This action displays the object[s] on the locate channel with
        segment display.
*/

action display_segment (int object_index;
                        enum GRdpmode element_mode, extension_mode)
{
    short *mxtype, ext;
    double *mx;
    struct GRlc_info *lcobj;
    enum GRdpmode dpmode[2];

    ext = 0;
    dpmode[0] = element_mode;
    dpmode[1] = extension_mode;
    lcobj = &me->events[object_index].located_object[0];
    mxtype = &lcobj->module_info.md_env.matrix_type;
    mx = lcobj->module_info.md_env.matrix;

    status = om$send (msg = message GRgraphics.GRlocaldp
                           (&me->ret, mxtype, mx, &lcobj->geom_parms,
                            dpmode, &me->ModuleInfo.md_id, NULL, &ext),
                      targetid = lcobj->located_obj.objid,
                      targetos = lcobj->located_obj.osnum);
}

/*
Action
        erase_hilite_plane

Description
        This action erases the highlight plane.

Note
        This action may be removed when COB adds a keyword to erase the
        highlight plane.
*/

action erase_hilite_plane ()
{
    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
}
