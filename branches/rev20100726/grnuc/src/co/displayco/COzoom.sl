/*      declaration section      */

command_object           GRC_M_Zoom,0,GRZm
class                    COzoom
product_name             "$GRNUC"
super_class              DPvw
start_state              get_curr_win

/*      specification section    */

specification

instance
{
    IGRdouble factor;
}

/*      implementation section    */

implementation


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

state_table

#include "grcmd.h"
#include "grmsg.h"
#include "DPview.h"

at init
	 do my_init()

at wakeup 
	 do my_wakeup()

at sleep 
	 do my_sleep()
/*
	 do delete()
*/

state *
	on EX_RESTART           state get_curr_win


state get_curr_win

   message_key			GRC_M_Zoom
   execute my_prompt() 

   filter                       get_event 

   on EX_DATA                   do get_win       /* major processing here */
				state  .

   on EX_RJT_MOVEON or
      SCALAR.GRst_DEFAULT	do switch_factor()
				state  .

   on SCALAR			do keyin_zoom()
				state  .

   on EX_BACK_UP		state centering



state centering 
   prompt_key			GR_P_IdentNewCenter
   filter			get_event

   on EX_DATA			do centering()
				state  get_curr_win

   on EX_BACK_UP		state  get_curr_win

   on EX_RJT_MOVEON or
      EX_STRING = ""		do switch_factor()
				state .


/*-------  action declaration section  --------*/

action my_prompt
{
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
}

action switch_factor()
{
    if( me->factor > 1.0 )
	me->factor = 0.5;
    else
	me->factor = 2.0;
}

action get_win
{
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
}


/**************************************************************/
action keyin_zoom()
{
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
}


action centering()
{
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
		
}


/*************************************************************************/
/* initialize some instance data, since after sleep, some window may	*/
/* be deleted, some maybe created					*/
/*************************************************************************/
action my_wakeup()
{
    IGRlong msg;

    me->wrk_p->cmd_type = DP_ZOOM;

    om$send(msg = message DPvw.COcomm_wakeup(&msg), 
		 targetid = my_id);

}

action my_sleep()
{
    IGRlong msg;
    om$send(msg = message DPvw.COcomm_sleep(&msg), 
		 targetid = my_id);

    me->state = _get_curr_win;

}

action my_init()
{
    IGRlong msg;

    me->factor = 0.5;
    om$send(msg = message DPvw.COcomm_init(&msg),
		 targetid = my_id);

}



