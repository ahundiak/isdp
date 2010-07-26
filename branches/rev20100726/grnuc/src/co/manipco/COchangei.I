class implementation COchange;



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



method use_events ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method hhlite_ele ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method copy (OM_p_CHANSELECT p_chansel)
{
  int		  status = OM_S_SUCCESS;

    gr$gscopy (msg = &me->ret,
               p_chanselect = p_chansel);
quit:
  return OM_S_SUCCESS;
}

end implementation COchange;
