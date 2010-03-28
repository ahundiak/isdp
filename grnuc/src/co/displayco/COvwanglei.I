class implementation COvwangle;



#include <stdio.h>
#include <FI.h>

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
#define _get_keyin_angle 1
#define _dynamic_phase 2

method default_angle ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRdouble angle;
    IGRchar buf[80];

    *sts = OM_S_SUCCESS;

    angle = 46.8;  /* 50 mm lens */

    me->wrk_p->idx_flag = 0;  /* clear former indexing flag if any */

    DPset_angle(&msg,me->base_p,me->wrk_p,me->pyrmd_p,angle);

    /*
     * display new angle on the view form
     */

    sprintf(buf,"%4.1f",angle);
    FIfld_set_text(me->wrk_p->view_form,ANGLE_FLD,0,0,buf,0);
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
       *sts = OM_S_SUCCESS;
       me->pt_x = me->event1.event.button.x;
       me->pt_y = me->event1.event.button.y;
       me->pt_z = me->event1.event.button.z;
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

    DPget_curr_win(&msg,me->win_id,
			me->base_p,me->wrk_p,me->pyrmd_p);


    if( ! (me->wrk_p->flags & IS_PERSP) )
    {
	*sts = OM_W_WARNING;
	goto quit;
    }

    DPcvrt_wld_pnt_to_dits( me->win_id,
	                    me->win_os,
	                    me->pt_x,
	                    me->pt_y,
	                    me->pt_z,
	                    &(me->wrk_p->x0), &(me->wrk_p->y0) );
    quit:
  return OM_S_SUCCESS;
}

method rubber_band_pyramid ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRint sel,pos;
    IGRdouble d1;
    IGRchar buf[80];

    /* display the current angle on the form */

    d1 = me->wrk_p->vw_angle*180/PI;
    sprintf(buf,"%4.1f",d1);
    FIfld_set_text(me->wrk_p->view_form,ANGLE_FLD,0,0,buf,0);

    ex$message( msgnumb = GR_P_DataPointAccOrAngle );
    DPdyn_phase(&msg,me->base_p,me->wrk_p,me->pyrmd_p);

      /*
       * display the adjusted angle or (mm) on the form and in the
       * message strip , ERROR_FIELD 
       */

       if( me->wrk_p->s_indexing == ON && 
	   (me->wrk_p->idx_flag & FOCAL_INDEXED)) 
       {
	  /* me->wrk_p->tmp_int is the index number */

	  FIfld_get_list_text(me->wrk_p->view_form,ANGLE_FLD,
			me->wrk_p->tmp_int,0,40,buf,&sel,&pos);

           ex$message(field=ERROR_FIELD,in_buff=buf);

	   FIfld_set_text(me->wrk_p->view_form,ANGLE_FLD,0,0,buf,0);
   	}
    	else
    	{
           d1 = me->wrk_p->vw_angle*180/PI;
	   sprintf(buf,"%4.1f",d1);
	   ex$message(field=ERROR_FIELD,in_buff=buf);

 	   sprintf(buf,"%4.1f",d1);
	   FIfld_set_text(me->wrk_p->view_form,ANGLE_FLD,0,0,buf,0);
    	}
quit:
  return OM_S_SUCCESS;
}

method keyin_angle ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRdouble angle;
    IGRchar buf[80];

    *sts = OM_S_SUCCESS;

    if ( me->event1.subtype == GRst_DEFAULT )
        angle = 46.8;  /* 50 mm */
    else
       {
       angle = me->event1.event.value;
       angle = (angle < 0.0) ? -angle : angle;
       }

    if( angle < 179.9)
    { 
	me->wrk_p->idx_flag = 0;  /* clear former indexing flag if any */

        DPset_angle(&msg,me->base_p,me->wrk_p,me->pyrmd_p,angle);

       /*
    	*  display new angle on the view form
    	*/

        sprintf(buf,"%4.1f",angle);
        FIfld_set_text(me->wrk_p->view_form,ANGLE_FLD,0,0,buf,0);

    }
    else
    {
	ex$message(field=ERROR_FIELD,msgnumb=GR_E_IllegalViewAngle);
	*sts = OM_W_WARNING;
    }

    if ( angle == 0 )
	*sts = OM_W_WARNING;
quit:
  return OM_S_SUCCESS;
}

method my_wakeup ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    me->wrk_p->cmd_type = DP_VWANGLE;

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

    goto quit;
quit:
  return OM_S_SUCCESS;
}

method my_init ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

    om$send(msg = message DPvw.COcomm_init(&msg),
		 targetid = my_id);

    goto quit;
quit:
  return OM_S_SUCCESS;
}

end implementation COvwangle;
