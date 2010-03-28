class implementation COevgen;



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



method use_events ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method store_event (int f, t)
{
  int		  status = OM_S_SUCCESS;

    if (f > 0 && f < 3 && t >= 0 && t < MAXEVENTS)
    {
        me->ret = MSSUCC;
        me->events[t] = (f == 1) ? me->event1 : me->event2;
    }
    else
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method push_event (int n)
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method display_coords (int n)
{
  int		  status = OM_S_SUCCESS;

    struct GRevent  *event;

    if (n == 1)
        event = &me->event1;
    else if (n == 2)
        event = &me->event2;
    else
        event = &me->events[abs(n)];

    status = COdiscoords (&me->ret, &event->event.button, &me->ModuleInfo,
                          KEYIN_FIELD, LEFT_JUS);
quit:
  return OM_S_SUCCESS;
}

method move_angle_to_event (int n)
{
  int		  status = OM_S_SUCCESS;

    me->ret = MSSUCC;

    if ((n >= 0) && (n < MAXEVENTS)) 
        me->events[n].event.value = me->ActiveAngle;
    else
        me->ret = MSFAIL;
quit:
  return OM_S_SUCCESS;
}

method setup_select_handler ()
{
  int		  status = OM_S_SUCCESS;

    me->select = (char(*)())COtkselect;
    me->select_args = (char *)&me->event2;
quit:
  return OM_S_SUCCESS;
}

method display_segment (int object_index;
                        enum GRdpmode element_mode, extension_mode)
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method erase_hilite_plane ()
{
  int		  status = OM_S_SUCCESS;

    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
quit:
  return OM_S_SUCCESS;
}

end implementation COevgen;
