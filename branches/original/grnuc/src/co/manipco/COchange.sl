/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COchange

Description
        This class defines actions common to some commands which change
        nongeometric data in graphic objects.  These commands include
        Change Element Color, Element Display Off, Delete, and others.
        Each command has a state transition table, maintained in other
        files, which references the actions found here.

History
        mrm     08/16/88    creation
                09/25/89    removed push_event and erase_hilite (use COtools),
                            added copy
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
product_name        "$PLATFORM"
spec_path           "$GRNUC/co/spec"
start_state         terminate
options             "t"


implementation

#include "coimport.h"
#include "msdef.h"
#include "lc.h"
#include "cochindex.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grmessage.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

extern IGRint (*CO_GA_change[])();      /* function pointer array */

/*
Action
        use_events

Description
        This action uses the function pointer array combined with
        me->mytype to invoke a noninteractive function to perform
        the desired processing.
*/

action use_events ()
{
    struct GRevent *events[3];

    me->ret = MSSUCC;

    events[0] = &me->event2;
    events[1] = &me->event1;
    events[2] = &me->event3;

    status = CO_GA_change[me->mytype] (&me->ret, my_id, OM_Gw_current_OS,
                                       &me->ModuleInfo, events,
                                       &me->located_chansel);

#ifdef dbg
    if (!(status & me->ret & 1)) printf ("COchange.use_events: noninteractive function failed\n");
    if (!(me->ret & 1)) printf ("COchange.use_events: me->ret = %x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif
}

/*
Action
        hhlite_ele ()

Description
        This action halfhighlights elements (according to the cmd argument)
        for the Element Display On and Element Locate On commands.
*/

action hhlite_ele ()
{
    IGRushort       property;       /* locatable or displayable */
     IGRboolean aflag = 0;
     struct GRmd_env rfenv;
 


    if (me->mytype == COch_dis_on || me->mytype == COch_loc_on)
    {
        property = (me->mytype == COch_loc_on) ?
                                             GRIS_LOCATABLE : GRIS_DISPLAYABLE;

     if(aflag = pwIsActivationOn())
     {
      pwGetActiveModuleEnv(&rfenv);
      status = COhhlele (&me->ret, my_id, OM_Gw_current_OS, &rfenv,
                           property);
     }
     else
     {
        status = COhhlele (&me->ret, my_id, OM_Gw_current_OS, &me->ModuleInfo,
                           property);
     }
    }
    else
    {
        me->ret = MSFAIL;
    }
}

/*
Action
        copy

Description
        This action produces a copy of the elements on the specified
        channel using gr$gscopy.
*/

action copy (OM_p_CHANSELECT p_chansel)
{
    gr$gscopy (msg = &me->ret,
               p_chanselect = p_chansel);
}
