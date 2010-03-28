/*      declaration section      */

command_object           GRC_M_TiltS,0,GRTl
class                    COtilt
product_name             "$GRNUC"
super_class              DPvw
start_state              get_curr_win

/*      specification section    */

specification

instance
{
    OM_S_OBJID win_id;
    OMuword    win_os;
    IGRdouble  pt_x, pt_y, pt_z;
}

/*      implementation section    */

implementation

#include "FI.h"
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

%safe
/* prototype files */

#include "DPvw_cal.h"
#include "DPvwi.h"
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

state *
	on EX_RESTART     state get_curr_win
	on EX_BACK_UP     state -


state get_curr_win
   message_key			GRC_M_Tilt
   prompt_key			GR_P_IdWin
   filter                       get_event

   on EX_DATA                   do store_win_data
				do get_win
					on SUCCESS
						do rubber_band_pyramid
						state dynamic_phase
					on ELSE
						state .
				state .

state dynamic_phase
   prompt_key			GR_P_DataPointOrAngle
   filter			get_event

   on EX_DATA                   do validate_point
					on SUCCESS
						do get_win
							on SUCCESS
								do rubber_band_pyramid
								state .
							on ELSE
								state .
						state .
					on ELSE
						state .
				state .

   on SCALAR			do keyin_tilt
				state .


/*-------  action declaration section  --------*/

action store_win_data

{
    me->win_id = me->event1.event.button.objid;
    me->win_os = me->event1.event.button.osnum;

    me->pt_x = me->event1.event.button.x;
    me->pt_y = me->event1.event.button.y;
    me->pt_z = me->event1.event.button.z;
}

action validate_point

{
    if ( me->win_id != me->event1.event.button.objid )
       {
       ex$message( field = ERROR_FIELD, msgnumb = GR_E_NotSameWindow );
       *sts = OM_W_WARNING;
       }
    else
       {
       me->pt_x = me->event1.event.button.x;
       me->pt_y = me->event1.event.button.y;
       me->pt_z = me->event1.event.button.z;
       *sts = OM_S_SUCCESS;
       }
}

action get_win
{
    IGRlong msg;

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
       }
}


action rubber_band_pyramid

{
    IGRlong msg;

    ex$message( msgnumb = GR_P_DataPointAccOrAngle );

    DPcvrt_wld_pnt_to_dits( me->event1.event.button.objid,
	                    me->event1.event.button.osnum,
	                    me->event1.event.button.x,
	                    me->event1.event.button.y,
	                    me->event1.event.button.z,
	                    &(me->wrk_p->x0), &(me->wrk_p->y0) );

    DPdyn_phase(&msg,me->base_p,me->wrk_p,me->pyrmd_p);
}

action keyin_tilt
{
   IGRlong msg;
   IGRdouble rad;  

    rad = PI * (me->event1.event.value / 180.0);

    DPcal_tilt(&msg,rad,me->base_p,me->wrk_p,0);

    /* update gragad */

    DPwrk_to_gg(&msg,me->wrk_p,NULL,TRUE);

    /* get new base_p and wrk_p */

    DPget_base_wrk(&msg,me->base_p,me->wrk_p);
    
   /*
    * display pyramids on all other windows's hilite plane
    */

    DPdp_pyramid(&msg,me->pyrmd_p,me->wrk_p,me->wrk_p->view_to_wld,TRUE); /* TRUE: erase the hilite plane first */

}


/*************************************************************************/
/* initialize some instance data, since after sleep, some window may	*/
/* be deleted, some maybe created					*/
/*************************************************************************/
action my_wakeup()
{
    IGRlong msg;

    me->wrk_p->cmd_type = DP_TILT;

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

    om$send(msg = message DPvw.COcomm_init(&msg),
		 targetid = my_id);
}
