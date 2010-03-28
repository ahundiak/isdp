class implementation COrotcoi;



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
#include "DPvwi.h"
#include "DPvw_cal.h"
%endsafe

/*--------   state table section  --------*/


#define _get_curr_win 0
#define _dynamic_phase 1
#define _get_h_angle 2

method store_angle1 ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    me->angle_x = me->event1.event.value;
quit:
  return OM_S_SUCCESS;
}

method keyin_rotcoi ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong   msg;
    IGRdouble rad_h,rad_v;

    /*
     * read in angles.
     */

    me->angle_y = me->event1.event.value;

    if(me->angle_x == 0.0 && me->angle_y == 0.0)  /* just <return> */
    {
	goto quit;	/* do nothing */
    }

    /*
     * rotate -- code from DPcal_cmd.I 
     */

    rad_v = - PI * (me->angle_x / 180.0);    
    rad_h = - PI * (me->angle_y / 180.0);    
    DPcal_around_coi(&msg,rad_v,rad_h,me->base_p,me->wrk_p,0);

    /* update gragad */

    DPwrk_to_gg(&msg,me->wrk_p,NULL,TRUE);

    /* get new base_p and wrk_p */

    DPget_base_wrk(&msg,me->base_p,me->wrk_p);
    
   /*
    * display pyramids on all other windows's hilite plane
    */

    DPdp_pyramid(&msg,me->pyrmd_p,me->wrk_p,me->wrk_p->view_to_wld,TRUE); /* TRUE: erase the hilite plane first */

quit:
  return OM_S_SUCCESS;
}

method validate_point ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method save_win_data ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    me->win_id = me->event1.event.button.objid;
    me->win_os = me->event1.event.button.osnum;

    me->pt_x = me->event1.event.button.x;
    me->pt_y = me->event1.event.button.y;
    me->pt_z = me->event1.event.button.z;

quit:
  return OM_S_SUCCESS;
}

method get_win ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method rubber_band_pyramid ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    ex$message( msgnumb = GR_P_DataPointAccOrVHAngles );

    DPcvrt_wld_pnt_to_dits( me->win_id,
	                    me->win_os,
	                    me->pt_x,
	                    me->pt_y,
	                    me->pt_z,
	                    &(me->wrk_p->x0), &(me->wrk_p->y0) );

    DPdyn_phase(&msg,me->base_p,me->wrk_p,me->pyrmd_p);

quit:
  return OM_S_SUCCESS;
}

method my_wakeup ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    me->wrk_p->cmd_type = DP_AROUND_COI;

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

    om$send(msg = message DPvw.COcomm_init(&msg),
		 targetid = my_id);

quit:
  return OM_S_SUCCESS;
}

end implementation COrotcoi;
