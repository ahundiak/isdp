class implementation COzoom;




#include <FI.h>
#include <stdio.h>

#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "exdef.h"
#include "dpstruct.h"

#include "igrdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "grmsg.h"

/* prototype files */
%safe
#include "DPvwi.h"
#include "DPvw_cal.h"
%endsafe

/*--------   state table section  --------*/


#define _get_curr_win 0
#define _centering 1

method my_prompt ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRchar buf[80],buf2[80];


    	    if( me->factor > 1.0 )
    	    {
    	        ex$message(buff=buf2,msgnumb=GR_P_ZmInMvOnZmOut);
    	    }
    	    else
    	    {
    	        ex$message(buff=buf2,msgnumb=GR_P_ZmOutMvOnZmIn);
    	    }
    	    ex$message(buff=buf,msgnumb=GR_P_KeyInFactor);
	    sprintf(me->prompt,"%s [%4.2f]%s",buf,me->factor,buf2);
quit:
  return OM_S_SUCCESS;
}

method switch_factor ()
{
  int		  status = OM_S_SUCCESS;

    if( me->factor > 1.0 )
	me->factor = 0.5;
    else
	me->factor = 2.0;
quit:
  return OM_S_SUCCESS;
}

method get_win ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRdouble center[3];

    *sts = OM_S_SUCCESS;

    if ( me->event1.event.button.osnum != me->ModuleInfo.md_id.osnum )
       {
       /* window is not in current module (e.g., the Place */
       /* Macro window) => we can't handle it              */
       *sts = OM_W_WARNING;
       ex$message( msgnumb = GR_E_InvWin );
       }
    else
       {
       DPget_curr_win(&msg,me->event1.event.button.objid,
   			me->base_p,me->wrk_p,me->pyrmd_p);

       /* if window is parallel and dynamics not loaded , quick zoom */
       if( !(me->wrk_p->flags & IS_PERSP) && 
 	    me->wrk_p->s_real_dyn == OFF ) 
          {
     	   center[0] = me->event1.event.button.x;
    	   center[1] = me->event1.event.button.y;
     	   center[2] = me->event1.event.button.z;
    	   DPcenter(&msg,center,FALSE,me->base_p,me->wrk_p); /* not update */

	   DPget_base_wrk(&msg,me->base_p,me->wrk_p);

	   DPfactor_zoom(&msg,me->factor,me->base_p,me->wrk_p,me->pyrmd_p);

          }
       else
          {
          ex$message(field=PROMPT_FIELD,msgnumb=GR_P_AcptZoomKeyInFactor,
	             var=`me->factor`,type="%4.2f");

          DPcvrt_wld_pnt_to_dits( me->event1.event.button.objid,
	                        me->event1.event.button.osnum,
	                        me->event1.event.button.x,
	                        me->event1.event.button.y,
	                        me->event1.event.button.z,
	                        &(me->wrk_p->x0), &(me->wrk_p->y0) );

          DPdyn_phase(&msg,me->base_p,me->wrk_p,me->pyrmd_p);

          }   

      }
quit:
  return OM_S_SUCCESS;
}

method keyin_zoom ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    if(me->event1.event.value != 0.0)
    {
        me->factor = me->event1.event.value;
	if(me->factor < 0.0) me->factor = -me->factor;
    }

    if(me->wrk_p->curr_win != -1)
    {
       DPfactor_zoom(&msg,me->factor,me->base_p,me->wrk_p,me->pyrmd_p);
    }
quit:
  return OM_S_SUCCESS;
}

method centering ()
{
  int		  status = OM_S_SUCCESS;

   IGRdouble center[3];
   IGRlong msg;
   IGRint  sts;

    center[0] = me->event1.event.button.x;
    center[1] = me->event1.event.button.y;
    center[2] = me->event1.event.button.z;


    /* get current working window */

    sts = DPpick_curr_window(&msg,me->event1.event.button.objid,me->wrk_p);

    /* init base_p and wrk_p from the current window */

    sts = DPget_base_wrk(&msg,me->base_p,me->wrk_p);

    /* adjust window center, and re-display */

    sts = DPcenter(&msg,center,TRUE,me->base_p,me->wrk_p);

    DPget_curr_win(&msg,me->event1.event.button.objid,
			me->base_p,me->wrk_p,me->pyrmd_p);

    return(TRUE);
		
quit:
  return OM_S_SUCCESS;
}

method my_wakeup ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    me->wrk_p->cmd_type = DP_ZOOM;

    om$send(msg = message DPvw.COcomm_wakeup(&msg), 
		 targetid = my_id);

quit:
  return OM_S_SUCCESS;
}

method my_sleep ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    om$send(msg = message DPvw.COcomm_sleep(&msg), 
		 targetid = my_id);

    me->state = _get_curr_win;

quit:
  return OM_S_SUCCESS;
}

method my_init ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    me->factor = 0.5;
    om$send(msg = message DPvw.COcomm_init(&msg),
		 targetid = my_id);

quit:
  return OM_S_SUCCESS;
}

end implementation COzoom;
