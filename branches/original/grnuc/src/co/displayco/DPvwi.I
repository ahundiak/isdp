/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:21 $
$Locker:  $
*/

/*
History:
   08/04/92 1) For a "shaded perspective" window, allow it to be loaded into
            the dynamics buffer and do view dynamics. 2) When loading dynamics,
	    just load everything within view volume. [TW]
*/



/*  -------------- CONTENTS ---------------
 *  COdp_pyramid(msg,pyrmd_p,wrk_p,view_to_wld);
 *  COget_base_wrk(msg,base_p,wrk_p)
 *  COset_gragad(msg,wrk_p,update)
 *  method COcomm_init(IGRlong *msg;)
 *  method COcomm_wakeup(IGRlong *msg;)
 *  method COcomm_sleep(IGRlong *msg;)
 *  DPcenter(msg,actz_pt,update,base_p,wrk_p)
 *  DPpick_curr_window(msg,win_objid,wrk_p)
 *  DPset_pyramid(msg,pyrmd_p,wrk_p)
 *  DPdp_rubline(msg,point,wrk_p)
 *  DPcal_zoom(msg,x,y,base_p,wrk_p)
 *  method COnew_clip_flags(IGRlong *msg;) ---- "NNNNNN'ed 
 *  Disscussion on the gragad data 
 *  Sample gragad data
 */


class implementation DPvw;


#define DP_ERASE_HI_PLANE 0x00000001


#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <FI.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "wl.h"

#include "igecolordef.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "grmsg.h"
#include "DPview.h"

#include "dl.h"

#include "EMdtmacros.h"
#include "EMSdatumdef.h"

#include "bstypes.h"

/* prototype files */
#include "DPvwi.h"
#include "DPvw_cal.h"
#include "DPinvmxRT.h"
#include "DPvw_dyn.h"
#include "DPvw_var.h"
#include "DPgetggid.h"
#include "DPsetinq.h"
#include "DPviewdyn.h"
#include "GRdpbfunc.h"
#include "dpclpstack.h"
#include "dpdiselem.h"
#include "dpmacupdate.h"
#include "dpmacgenupd.h"
#include "dpmacerahil.h"

#include "EFrefpln.h"

#include "bsdistptpt.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "maptsxfor.h"


from IGEgragad import DPcal,DPfit;

/*--- override of IGEwinsup.pre_delete ---------------------------------*/

method pre_delete( IGRlong *msg )

/*
DESCRIPTION
	This message is sent whenever a window is going to be deleted.  When
	this message is received, find the window in the array of working
	windows and set its objid to NULL_OBJID to indicate that it has
	been deleted.

HISTORY
	S.P. Rogers  01/03/92  Creation Date
*/

	{
	IGRint ii;

	*msg = MSSUCC;

	for ( ii = 0; ii < me->wrk_p->num_wins; ii++ )
	   {
	   if ( me->wrk_p->windows[ii].objid == sender_id )
	      {
	      me->wrk_p->windows[ii].objid = NULL_OBJID;
	      }
	   }

	return( OM_S_SUCCESS );
	}


method status_disp()
{

    DPprepare_vw_form();
    FIf_display(me->wrk_p->view_form);
    return( OM_S_SUCCESS );
}


/************************************************************************/
/* init the instance variables if possible				*/
/* This should the first function called for this class.		*/
/* Some variables have to wait for future initialization.		*/
/************************************************************************/
method COcomm_init(IGRlong *msg;)
{
   /* assign var pointers */

    DPassign_var(&me->base_p,&me->wrk_p,&me->pyrmd_p);

    ex$message(field=ERROR_FIELD,msgnumb=GR_M_StsFmAvail);

    return( OM_S_SUCCESS );
}

/****************************************************************/
/* wake up process common for all viewing commands 		*/
/****************************************************************/

method COcomm_wakeup(IGRlong *msg;)
{
   IGRint          ii;
   OM_S_CHANSELECT to_winsup, to_gragad;

   om$make_chanselect( channame = "IGEgragad.winsup", p_chanselect = &to_winsup );
   om$make_chanselect( channame = "IGEwinsup.gra_gad", p_chanselect = &to_gragad );

   /* turn ref plane lock off, if it is on */
   ems$ref_plane_lock( msg = msg,
	               options = EMS_REF_PLANE_LOCK_INQ,
	               mode = &me->ref_plane_lock_mode );

   if ( me->ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON )
       {
       ems$ref_plane_lock( msg = msg,
	                   options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );
       }

   /*
    * set curr_win to -1    
    * read in all windows' infomation for later use
    * initialize the form and initialize static data structure if needed
    */
   
   DPvw_start(msg,me->wrk_p);

   /* connect to all the windows so we can know if any of them are deleted */
   for ( ii = 0; ii < me->wrk_p->num_wins; ii++ )
      {
      om$send( msg = message Root.connect( to_winsup, NULL,
 	                                   my_id, OM_Gw_current_OS,
	                                   to_gragad, NULL ),
	       senderid = my_id,
	       targetid = me->wrk_p->windows[ii].objid,
	       targetos = me->wrk_p->windows[ii].osnum );
      }

   /*------------------------------------------------------------------*/
   /* We want COB accept the "expand key", so we need to declare the   */
   /* status_display_form in the header of .sl file. But we don't want */
   /* COB to create this form automacically. So here we assign         */
   /* our form pointer to it, make it non NULL. COB will think that it */
   /* has already been created.					       */
   /*------------------------------------------------------------------*/

    me->status_display_form_ptr = me->wrk_p->view_form;

    GRstatus_display_button(1);

    return( OM_S_SUCCESS );

}

/****************************************************************/
/* sleep process common for all viewing commands 		*/
/****************************************************************/

method COcomm_sleep(IGRlong *msg;)
{

   IGRint          ii;
   OM_S_OBJID      mod_id;
   OMuword         mod_os;
   OM_S_CHANSELECT to_winsup, to_gragad;

   om$make_chanselect( channame = "IGEgragad.winsup", p_chanselect = &to_winsup );
   om$make_chanselect( channame = "IGEwinsup.gra_gad", p_chanselect = &to_gragad );

   /* turn ref plane lock back on, if required */
   if (me->ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON)
       {
       ems$ref_plane_lock( msg = msg,
	                   options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET );
       }

    /* restore the window's attributes (see DPvw_start() ) */
    if (!(ex$is_batch())) DPvw_end(msg,me->wrk_p,DP_ERASE_HI_PLANE);

   /* disconnect from all the windows */
   for ( ii = 0; ii < me->wrk_p->num_wins; ii++ )
      {
      if ( me->wrk_p->windows[ii].objid == NULL_OBJID )
         continue;  /* this window was deleted so we aren't connected any more */

      om$send( msg = message Root.disconnect( to_winsup,
	                                      my_id, OM_Gw_current_OS,
	                                      to_gragad ),
	       senderid = my_id,
	       targetid = me->wrk_p->windows[ii].objid,
	       targetos = me->wrk_p->windows[ii].osnum );
      }

    /*------------------------------------------------------------------*/
    /* The view form should not be deleted by COB. So I set the pointer */
    /* to NULL to cheat COB not to delete it.				*/
    /*------------------------------------------------------------------*/

    me->status_display_form_ptr = NULL; 

    /* remember leaving time */
    time( & (me->wrk_p->time_leaving) );

    /* erase the pyramids drawn in all the windows */
    ex$get_cur_mod( id = &mod_id, osnum = &mod_os );
    dp$erase_hilite( msg = msg, osnum = mod_os );

    return( OM_S_SUCCESS );
}



/************************************************************************/

IGRint DPget_curr_win(msg,win_objid,base_p,wrk_p,pyrmd_p)
IGRlong *msg;
GRobjid win_objid;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
struct DPpyramid_t *pyrmd_p;
{
   IGRint  sts;
   IGRint  i;
   IGRint levels_is_included;

   /*
    * If the curr window is not changed, then there is no need to do following
    */

    if( ( wrk_p->curr_win == -1) || 
		(wrk_p->windows[wrk_p->curr_win].objid != win_objid) )
    {
       /*
    	* get current working window and turn on/off clipping planes to 
	* all windows 
    	*/

    	sts = DPpick_curr_window(msg,win_objid,wrk_p);

	/* get window class name */

	wrk_p->win_class = 
		  DPwindow_class(&(wrk_p->windows[wrk_p->curr_win]));

    	/* init base_p and wrk_p from the current window */

    	sts = DPget_base_wrk(msg,base_p,wrk_p);

     	/* erase the pyramid left on the new curr window by former cmd */

    	i = wrk_p->curr_win;
	if (!(ex$is_batch()))
	{
                WLset_drawing_mode( wrk_p->win_no[i], WL_BASE_NOOP | WL_HILITE_ERASE );

	    	DPco_erase_win(msg,wrk_p->win_no[i],
		      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
		      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);

	       /* 
	     	* if the hilite plane dynamics was on, set and display pyramid
	     	*/

	        if( wrk_p->hi_dyn_on)
		{
	    	  DPdp_pyramid(msg,pyrmd_p,wrk_p,wrk_p->view_to_wld,TRUE);
	        }
	}
    }


    /*
     * if real dynamics, then prepare dyn frame. Even the curr window is not
     * changed, this is necessary, since the user might toggle the view form
     * to dynamics etc.
     */

    if( wrk_p->s_real_dyn == ON )  /* dynamics is ON */
    {
	/* 
	 * if needed,  try to load dynamics.
         */

	if( wrk_p->frame_info[wrk_p->win_class].frame_loaded ) 
	{
	    /* if is already loaded */

	    levels_is_included = DPlevels_is_included(
                        (char *)(base_p->gg).levels,
			(char *)wrk_p->frame_info[wrk_p->win_class].levels);

	    if( wrk_p->s_auto_load == TRUE ) /* in auto_load mode */
	    {
		if(wrk_p->frame_info[wrk_p->win_class].out_of_date ||
		   ! levels_is_included )
		{
		    sts = DPload_dynamics(msg,wrk_p->win_class,wrk_p,base_p);
		}
	    }
	    else	/* Manu Load, just give warning */
	    {
		if( ! levels_is_included )
		{
		    ex$message(field=ERROR_FIELD,
		       msgnumb=GR_E_WarnSmLvlMayNotLd);
		}
		else if(wrk_p->frame_info[wrk_p->win_class].out_of_date)
		{
		    ex$message(field=ERROR_FIELD,
		       msgnumb=GR_E_WarnDynBufMayOld);
		}
	    }

	}
	else  /* frame not loaded */
	{
		if( wrk_p->s_auto_load == TRUE ) /* need to load */
	        {
		    sts = DPload_dynamics(msg,wrk_p->win_class,wrk_p,base_p);
		}
		else	/* Manu Load, just give warning */
		{
		    ex$message(field=ERROR_FIELD,msgnumb=GR_E_DynNotLd);
		}
	}
    }  /* end if (dyn == ON) */
 
    return( OM_S_SUCCESS );
}    

/**********************************************************************/
IGRint DPunload_dynamics(msg,wrk_p)
IGRlong *msg;
struct DPview_wrk_t *wrk_p;
{
    IGRint sts;

    *msg = OM_S_SUCCESS;
    
    sts = dp$reset_frames(msg = msg);  /* clear frame buffers */

    if( ! (sts & 1))
    {
#ifdef DEBUG
	fprintf(stderr,"DPviewi.I:  DPunload_dynamics() error 213\n");
#endif
    }

    wrk_p->frame_info[IGEFRAME].frame_loaded = FALSE;
    wrk_p->frame_info[HSFRAME].frame_loaded = FALSE;

    return(sts);
    
}
/***********************************************************************/

IGRint DPload_dynamics(msg,win_class,wrk_p,base_p)
IGRlong *msg;
IGRint win_class;
struct DPview_wrk_t *wrk_p;
struct DPbase_gg_t *base_p;
{
    IGRint              disp_buf_status;
    GRobjid		frame_id;	    /* dynamic frame obj id */
    GRspacenum		frame_osnum;
    IGRint		status;

    *msg = OM_S_SUCCESS;
    status = TRUE;

    DPunload_dynamics(msg,wrk_p);  /* clear all former frame buffers */

    ex$message( msgnumb = GR_I_LdDyn);

    /* Note!! I can only start from frame_no 0 even though I don't want	to*/

    status=dp$start_frame( msg = msg,
		    apparent_stroke_scale = 2.0,
		    frame_no = 0,
		    gragad_id = wrk_p->windows[wrk_p->curr_win].objid,
		    gragad_osnum = wrk_p->windows[wrk_p->curr_win].osnum,
		    frame_id = &frame_id,
		    frame_osnum = &frame_osnum);

    if( ! ((status & 1) && (*msg & 1)) )
    {
#ifdef DEBUG
	fprintf(stderr,"DPviewi.I: (104) dp$start_frame() Error\n");
	fprintf(stderr,"status=%d, msg=%d\n",status,*msg);
#endif
	status = FALSE;
	goto wrapup;
    }

    /* generate the contents of the frame buffer */

    status=dp$gen_update( msg = msg,
		   erase = FALSE,
		   objid = frame_id,
		   osnum = frame_osnum);
    if( ! (status & 1 || *msg & 1) )
    {
#ifdef DEBUG
	fprintf(stderr,"DPviewi.I: (105) dp$gen_update() Error\n");
#endif
	status = FALSE;
	goto wrapup;
    }

    status=dp$end_frame(   msg = msg,
		    disp_buf_status = &disp_buf_status,
		    frame_id = frame_id,
		    frame_osnum = frame_osnum);
    if( ! (status & 1 || *msg & 1) )
    {
#ifdef DEBUG
	fprintf(stderr,"DPviewi.I: (106) dp$end_frame() Error\n");
#endif
	status = FALSE;
	goto wrapup;
    }

    /* check if disp_buf_status is prepared OK */

    if( disp_buf_status )  /* failed in prepare frame buffer */
    {
	ex$message(msgnumb = GR_I_NotAllEleLd);
	status = FALSE;
	goto wrapup;
    }

    ex$message(msgnumb = GR_I_DynLd);

    wrk_p->frame_info[win_class].frame_loaded = TRUE;

    /* remember which levels have been loaded. So if new levels turn ON later,
       we can warn user that the dynamics buffer maybe too old */
    OM_BLOCK_MOVE(base_p->gg.levels,wrk_p->frame_info[win_class].levels,
			sizeof(IGRint)*32);


wrapup:
   return(status);
}


/************* DPdyn_phase() ********************************************/
/* 									*/
/************************************************************************/
IGRint DPdyn_phase(msg,base_p,wrk_p,pyrmd_p)
IGRlong *msg;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
struct DPpyramid_t   *pyrmd_p;
{
   struct func_parm_t func_parm;
   IGRint DPdyn_func();
   IGRint sts;

   *msg = OM_S_SUCCESS;

   if (ex$is_batch()) return(TRUE);
   
   wrk_p->ratio_x = 0.0;  /* for the auto accumulate value */
   wrk_p->ratio_y = 0.0;

   wrk_p->prev_x = -100;  /* prevent from thinking that  mouse is not */
   wrk_p->prev_y = -100;  /* moved in DPvw_dyn() */

   /*
    * start dynamics
    */


   /* clear last phase_state, important */

   wrk_p->phase_state = 0;
   /* Initialize the lock state to neither x or y, set on cursor movement */
   wrk_p->cursor_axis_lock=0;
   /* perparre parameters for dyn_func() */

   func_parm.base_p = base_p;
   func_parm.wrk_p = wrk_p;
   func_parm.pyrmd_p = pyrmd_p;

   if(wrk_p->s_real_dyn == ON &&
	 wrk_p->frame_info[wrk_p->win_class].frame_loaded ) 
   {

       sts = dp$display2_frames( msg = msg,
		start_frame = 0,	/*  Note!! must start from 0, sorry. wrk_p->win_class, */
		relative_frame = 0,
		number_of_frames = 1,
		number_of_cycles = DPUNLIMITED_CYCLES,
		direction = DPFORWARD,
		erase = TRUE,
		gragad_id = wrk_p->windows[wrk_p->curr_win].objid,
		gragad_osnum = wrk_p->windows[wrk_p->curr_win].osnum,
		func_ptr = DPdyn_func,
		func_parm = (IGRchar *)(&func_parm) );

       if( ! (sts & 1 && *msg & 1) )
       {
#ifdef DEBUG
	fprintf(stderr,"Failed in sending message--display2_frames()\n");
	fprintf(stderr,"stauts = %d\n",sts);
#endif
       }

   }
   else /* only pyramid dynamics */
   {
	IGRint 		hwwin_no;
	IGRint 		done;
	IGRint 		state;

	if (!(ex$is_batch()))
	{
		hwwin_no = wrk_p->win_no[wrk_p->curr_win];

		done = FALSE;

		while( !done )
		{
		    DPdyn_func((char *)(&func_parm),
			       &hwwin_no,
			       NULL,		/* gragad */
			       &done,
			       &state,
			       NULL,	/* number_of_cycles,	*/
			       NULL,	/* unlimited_cycle,	*/
			       NULL);	/* frame_no		*/
		}


	        if( wrk_p->phase_state != DP_DYN_ABORT )  /* when abort, they are already consitent */
	    	   DPwrk_to_gg(msg,wrk_p,NULL,TRUE);
	}
   }

  /*
   * the dynamics is finished, get the new base_p and wrk_p 
   */
   if( wrk_p->phase_state != DP_DYN_ABORT )  /* when abort, they are already consitent */
      sts = DPget_base_wrk(msg,base_p,wrk_p);

   return(TRUE);

}


/************************************************************************/
/*									*/
/*	DPwrk_to_gg()							*/
/*									*/
/************************************************************************/
IGRint DPwrk_to_gg(msg,wrk_p,curr_gg_p,update)
IGRlong *msg;
struct DPview_wrk_t *wrk_p;
struct DPgra_gad *curr_gg_p;
IGRint update;
{
    struct DPgra_gad    gg,*gg_p;
    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;
    IGRint		status;


    /*
     * modify gragad by values in wrk_p
     */

    if( curr_gg_p == NULL)
    {
    	inq_array[0].var = GRAGAD_STRUCT;
    	inq_array[0].var_ptr = (char *)&gg;
    	inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    	inq_array[0].bytes_returned = &nbytes_ret;
    	inq_array[1].var = END_PARAM;

    	status = dp$inq_set_gragad(msg = msg,
                      gragad_objid = wrk_p->windows[wrk_p->curr_win].objid,
                             osnum = wrk_p->windows[wrk_p->curr_win].osnum,
                       which_error = &error_var,
                          var_list = inq_array);

	gg_p = &gg;
    }
    else
	gg_p = curr_gg_p;

    /*
     * set gragad 
     */

	gg_p->flags = wrk_p->flags;
	OM_BLOCK_MOVE(wrk_p->coi,gg_p->coi,sizeof(IGRdouble)*3);
	OM_BLOCK_MOVE(wrk_p->coi,gg_p->vrp,sizeof(IGRdouble)*3);

	if(wrk_p->flags & IS_PERSP)
	{
	   gg_p->vw_angle = wrk_p->vw_angle;

	   OM_BLOCK_MOVE(wrk_p->eye_pt,gg_p->eye_pt,sizeof(IGRdouble)*3);
	   OM_BLOCK_MOVE(wrk_p->vup,gg_p->vup,sizeof(IGRdouble)*3);
	   OM_BLOCK_MOVE(wrk_p->vpn,gg_p->vpn,sizeof(IGRdouble)*3);

	   /* adjust volume and act_z back to right hand */

	   OM_BLOCK_MOVE(wrk_p->vw_volume,gg_p->vw_volume,sizeof(IGRdouble)*6);
	   gg_p->vw_volume[2] = -wrk_p->vw_volume[5];
	   gg_p->vw_volume[5] = -wrk_p->vw_volume[2];

	   gg_p->act_z = -wrk_p->act_z;
	}
	else
	{
	  OM_BLOCK_MOVE(wrk_p->eye_pt,gg_p->origin,sizeof(IGRdouble)*3);
	  OM_BLOCK_MOVE(wrk_p->rotation,gg_p->rotation,sizeof(IGRdouble)*16);
	  OM_BLOCK_MOVE(wrk_p->vw_volume,gg_p->vw_volume,sizeof(IGRdouble)*6);
	  gg_p->act_z = wrk_p->act_z;
	}

   /*
    *  write back and DPcal()
    */

    if( curr_gg_p == NULL)
    {
    	status = dp$inq_set_gragad(msg = msg,
			inq0_set1 = 1, calc_info = 1,
			update = update,
                      gragad_objid = wrk_p->windows[wrk_p->curr_win].objid,
                             osnum = wrk_p->windows[wrk_p->curr_win].osnum,
                       which_error = &error_var,
                          var_list = inq_array);
    }
    else
    {
        om$send(msg = message IGEgragad.DPcal(msg),
		senderid = NULL_OBJID,
		targetid = wrk_p->windows[wrk_p->curr_win].objid,
		targetos = wrk_p->windows[wrk_p->curr_win].osnum);

	if(update)
	{
	    dp$update( msg = msg,
			range = NULL,
                        objid = wrk_p->windows[wrk_p->curr_win].objid,
                        osnum = wrk_p->windows[wrk_p->curr_win].osnum );
 	}
    }

    return(TRUE);
}


/************************************************************************/
IGRint  DPco_erase_win(msg, win_no, xlo,ylo,xhi,yhi)

IGRlong  *msg;	        /* output completion code       */
IGRint  win_no;        /* hardware window number       */
IGRint  xlo,ylo,xhi,yhi;  

{
   WLcolorref color_ref;
   struct WLrect rect;

   *msg = OM_S_SUCCESS;

   WLset_blendarea( win_no, NULL, TRUE );

   rect.x = xlo;
   rect.y = ylo;
   rect.width = xhi - xlo + 1;
   rect.height = yhi - ylo + 1;

   WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
   WLset_active_symbology( win_no, color_ref, 0, 0, 0, WL_SYMB_CHANGE_COLOR );
   WLdraw_rectangle( win_no, &rect, TRUE );

   return(TRUE);
}



/*** DPget_base_wrk(msg,base_p,wrk_p)  **************************************/
/*									*/
/* Generate the base structure for a given window.			*/
/* Values are adjusted for my convention.				*/
/* initialize the gragad values in wrk struct				*/
/************************************************************************/

IGRint DPget_base_wrk(msg,base_p,wrk_p)
IGRlong *msg;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
{
    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;
    IGRint		status;
    IGRshort		four;
    IGRdouble		trans[4][4];
    IGRdouble		half_angle;
    IGRlong 		one=1;
    IGRdouble		temp[3];
    IGRdouble		d1;

    IGRdouble	tan();

    four = 4;
    *msg = OM_S_SUCCESS;

    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (char *)& (base_p->gg);
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;

    status = dp$inq_set_gragad(msg = msg,
                      gragad_objid = wrk_p->windows[wrk_p->curr_win].objid,
                             osnum = wrk_p->windows[wrk_p->curr_win].osnum,
                       which_error = &error_var,
                          var_list = inq_array);

    if( !(status & 1) )
    {
#ifdef DEBUG
	fprintf(stderr,"Error in DPvwi.I -- 123 \n");
#endif
    }

    /* screen width in dit */

    base_p->scrn_width = base_p->gg.dit_clip_range[3] - base_p->gg.dit_clip_range[0];
    base_p->scrn_length = base_p->gg.dit_clip_range[4] - base_p->gg.dit_clip_range[1];


   /*
    * For persp view, adjust vol[], act_z to right hand, calc tan_x,tan_y. 
    * Reset act_z at coi
    *
    * For parallel view, change to as if persp. view. Set coi at act_z
    */

    if( base_p->gg.flags & IS_PERSP)
    { 
        /*
	 * adjust vw_volume[], act_z to right hand
	 */

	 d1 = base_p->gg.vw_volume[2];
	 base_p->gg.vw_volume[2] = -base_p->gg.vw_volume[5];
	 base_p->gg.vw_volume[5] = -d1;

	 base_p->gg.act_z = -base_p->gg.act_z;


    	/* 
	 * calc tan_x, tan_y 
	 */
	half_angle = base_p->gg.vw_angle/2.0;

	if( base_p->scrn_width < base_p->scrn_length )
	{
	    base_p->tan_x = tan(half_angle);
	    base_p->tan_y = base_p->tan_x * 
				(base_p->scrn_length/base_p->scrn_width);
	}
	else
	{
	    base_p->tan_y = tan(half_angle);
	    base_p->tan_x = base_p->tan_y * 
				(base_p->scrn_width/base_p->scrn_length);
	}
    }
    else /* parallel view */
    {
    	/* MAinvmx(msg,&four,base_p->gg.wld_to_view,base_p->view_to_wld); */
	DPinvmxRT( (IGRdouble *)base_p->gg.wld_to_view, 
				(IGRdouble *)base_p->view_to_wld);

	temp[0]=(base_p->gg.vw_volume[0]+base_p->gg.vw_volume[3])/2.0;
	temp[1]=(base_p->gg.vw_volume[1]+base_p->gg.vw_volume[4])/2.0;

	/* put eye 100 unit in front of the near clip plane */

	temp[2]= base_p->gg.vw_volume[5] + 100; 
    	MAptsxform(msg,&one,base_p->view_to_wld,temp,base_p->gg.eye_pt);

	/* reset coi on the act_z */

	temp[2] = base_p->gg.act_z;
    	MAptsxform(msg,&one,base_p->view_to_wld,temp,base_p->gg.coi);

	/* calc vw_volume w/r to eye_pt, keep 0,1,2 smaller convention */

	base_p->gg.vw_volume[0] -= temp[0];
	base_p->gg.vw_volume[1] -= temp[1];
	base_p->gg.vw_volume[3] -= temp[0];
	base_p->gg.vw_volume[4] -= temp[1];

	d1 = base_p->gg.vw_volume[5] - base_p->gg.vw_volume[2];
	base_p->gg.vw_volume[5] = -100;
	base_p->gg.vw_volume[2] = -100 - d1;
    }

   /*
    * now, treat it as perspective.
    */

    /* set act_z at coi */

    base_p->gg.act_z = -BSdistptpt(msg,base_p->gg.eye_pt,base_p->gg.coi);

    /* calc new wld_to_view matrix and view_to_wld,inv_rotation */

    MAidmx(msg,(IGRdouble *)trans);
    trans[0][3] = -base_p->gg.eye_pt[0];
    trans[1][3] = -base_p->gg.eye_pt[1];
    trans[2][3] = -base_p->gg.eye_pt[2];
    MAmulmx(msg, &four, &four, &four, (IGRdouble *)base_p->gg.rotation,
                     (IGRdouble *)trans, (IGRdouble *)base_p->gg.wld_to_view);

    /* MAinvmx(msg,&four,base_p->gg.wld_to_view,base_p->view_to_wld); */
    DPinvmxRT( (IGRdouble *)base_p->gg.wld_to_view, 
			(IGRdouble *)base_p->view_to_wld);
    /* MAinvmx(msg,&four,base_p->gg.rotation,base_p->inv_rotation); */
    DPinvmxRT( (IGRdouble *)base_p->gg.rotation, 
			(IGRdouble *)base_p->inv_rotation);

   /* calc coi_vw[] */

    MAptsxform(msg, &one, (IGRdouble *)base_p->gg.wld_to_view, base_p->gg.coi,
			base_p->coi_vw);

   /*
    * get abs_up[] 
    */

/* temparorily, let abs_up[] it be wld_z aixs, later put it in DPgra_gad */

    base_p->abs_up[0] = 0.0;
    base_p->abs_up[1] = 0.0;
    base_p->abs_up[2] = 1.0;

    /* reset vup -- so it is unit and perpendicular to viewing vector */

    base_p->gg.vup[0] = base_p->gg.rotation[1][0];   /* vup in wld */
    base_p->gg.vup[1] = base_p->gg.rotation[1][1];
    base_p->gg.vup[2] = base_p->gg.rotation[1][2];

    /* reset vpn -- so it is unit, and for parallel view, need to provide this value any way */

    base_p->gg.vpn[0] = -base_p->gg.rotation[2][0];   /* vpn in wld */
    base_p->gg.vpn[1] = -base_p->gg.rotation[2][1];
    base_p->gg.vpn[2] = -base_p->gg.rotation[2][2];

#ifdef NNNNNNNNNN
    /* calc tilt vector vup_v in VCS3 */

    MAdotvc(msg,base_p->gg.vpn,base_p->abs_up,&d1);

    if( d1 > 0.999 || d1 < -0.999 )  /* parallel vectors */
    {
	base_p->vup_v[0] = 0.0;		/* set no tilt */
	base_p->vup_v[1] = 1.0;
	base_p->vup_v[0] = 0.0;
    }
    else
    {
        DPalignper(msg,0,base_p->gg.vpn,base_p->abs_up,base_p->gg.eye_pt,
				rotate,temp_mx);
    	MAptsxform(msg,&one, (IGRdouble *)rotate,base_p->gg.vup,base_p->vup_v);
    }
#endif

    DPbase_to_wrk(msg,base_p,wrk_p);


#ifdef DEBUG
if( base_p->gg.flags & IS_PERSP )
{
printf("Is_persp view, win = %d\n", wrk_p->windows[wrk_p->curr_win].objid);
}
else
{
printf("Is_Ord view, win = %d\n", wrk_p->windows[wrk_p->curr_win].objid);

}
printf("eye=%f %f %f\n", wrk_p->eye_pt[0], wrk_p->eye_pt[1], wrk_p->eye_pt[2]);
printf("coi=%f %f %f\n", wrk_p->coi[0], wrk_p->coi[1], wrk_p->coi[2]);
printf("origin = %f %f %f\n",wrk_p->origin[0],wrk_p->origin[1],wrk_p->origin[2]);
printf("angle = %f \n", base_p->gg.vw_angle); 
printf("volume=\n");
printf("  %f %f %f\n", wrk_p->vw_volume[0], wrk_p->vw_volume[1], wrk_p->vw_volume[2]);
printf("  %f %f %f\n", wrk_p->vw_volume[3], wrk_p->vw_volume[4], wrk_p->vw_volume[5]);
printf("act_z = %f\n", wrk_p->act_z);
printf("coi_vw=%f %f %f\n", wrk_p->coi_vw[0], wrk_p->coi_vw[1], wrk_p->coi_vw[2]);
#endif

   return(TRUE);
}

/**********************************************************************/
IGRint DPbase_to_wrk(msg,base_p,wrk_p)
IGRlong *msg;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
{

   *msg = OM_S_SUCCESS;

   /* initialize the gragad values in wrk struct */

   wrk_p->flags = base_p->gg.flags;
   wrk_p->vw_angle = base_p->gg.vw_angle;
   wrk_p->act_z  = base_p->gg.act_z;
   wrk_p->tan_x  = base_p->tan_x;
   wrk_p->tan_y  = base_p->tan_y;

   wrk_p->eye_pt_vw[0] = 0.0;
   wrk_p->eye_pt_vw[1] = 0.0;
   wrk_p->eye_pt_vw[2] = 0.0;

   OM_BLOCK_MOVE(base_p->gg.vw_volume,wrk_p->vw_volume,sizeof(IGRdouble)*6);
   OM_BLOCK_MOVE(base_p->gg.coi,wrk_p->coi,sizeof(IGRdouble)*3);
   OM_BLOCK_MOVE(base_p->coi_vw,wrk_p->coi_vw,sizeof(IGRdouble)*3);
   OM_BLOCK_MOVE(base_p->gg.rotation,wrk_p->rotation,sizeof(IGRdouble)*16);
   OM_BLOCK_MOVE(base_p->gg.wld_to_view,wrk_p->wld_to_view,sizeof(IGRdouble)*16);
   OM_BLOCK_MOVE(base_p->view_to_wld,wrk_p->view_to_wld,sizeof(IGRdouble)*16);

   OM_BLOCK_MOVE(base_p->gg.eye_pt,wrk_p->eye_pt,sizeof(IGRdouble)*3);
   OM_BLOCK_MOVE(base_p->gg.vpn,wrk_p->vpn,sizeof(IGRdouble)*3);
   OM_BLOCK_MOVE(base_p->gg.vup,wrk_p->vup,sizeof(IGRdouble)*3);

   OM_BLOCK_MOVE(base_p->abs_up,wrk_p->abs_up,sizeof(IGRdouble)*3);

    return(TRUE);
}

/***********************************************************************/
/* initialize viewing commands data structure. Should be called at     */
/* wake up. See DPvw_end()					       */
/***********************************************************************/

IGRint DPvw_start(msg,wrk_p)
IGRlong *msg;
struct DPview_wrk_t *wrk_p;
{
    struct DPgra_gad 	gg;
    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;
    IGRint		status;
    IGRint		i;
    IGRlong		tmp_long;
    IGRint              msg2;

   /* 
    * if is a consecutive viewing commands, then the contents of frame buffer
    * can be used for Auto-load mode
    */

    time(&tmp_long);

    wrk_p->curr_win = -1;		/* no current window selected */

    if((IGRint)(tmp_long - wrk_p->time_leaving) < 3 ) /* less than 3 seconds */
    {
	wrk_p->frame_info[0].out_of_date = FALSE;
	wrk_p->frame_info[1].out_of_date = FALSE;
    }
    else
    {
	wrk_p->frame_info[0].out_of_date = TRUE;
	wrk_p->frame_info[1].out_of_date = TRUE;
    }

   /*
    * get all the windows' id
    */

    dp$get_gragad_id( msg = msg,
		      name = "*",
                      type_gragad = (ALL_GG_CLASSES | GG_WIN_ON),
		      array_size = MAX_WIN,
		      numberofids = &wrk_p->num_wins,
		      found_GRids = wrk_p->windows);

   /*
    * save gg.flags for each window, ( when sleep, restore them ).
    * save other variables for each window for later use.
    */ 

    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;

    for(i=0;i<wrk_p->num_wins;i++)
    {
    	inq_array[0].var = GRAGAD_STRUCT;
    	inq_array[0].var_ptr = (char *)&gg;
    	inq_array[0].num_bytes = sizeof(struct DPgra_gad);

    	status = dp$inq_set_gragad(msg = msg,
                      gragad_objid = wrk_p->windows[i].objid,
                             osnum = wrk_p->windows[i].osnum,
                       which_error = &error_var,
                          var_list = inq_array);

     	wrk_p->winflags[i] = gg.flags;
     	wrk_p->gpipe_id[i] = gg.gpipe_id;

	OM_BLOCK_MOVE(gg.dit_clip_range,wrk_p->win_dit_rng[i],
						sizeof(IGRdouble)*6);

	wrk_p->win_act_z_screen[i] = gg.act_z_screen;
	OM_BLOCK_MOVE(gg.viewport_to_wld,wrk_p->win_viewport_to_wld[i],
						sizeof(IGRdouble)*16);
	OM_BLOCK_MOVE(gg.wld_to_viewport,wrk_p->win_wld_to_viewport[i],
						sizeof(IGRdouble)*16);

	/* get all the window's attributes */

    	inq_array[0].var = WIN_NO;
    	inq_array[0].var_ptr = (char *)&wrk_p->win_no[i];
    	inq_array[0].num_bytes = sizeof(IGRint);

    	status = dp$inq_set_gragad(msg = msg,
                      gragad_objid = wrk_p->windows[i].objid,
                             osnum = wrk_p->windows[i].osnum,
                       which_error = &error_var,
                          var_list = inq_array);

        WLsync_buffers( wrk_p->win_no[i] );

	/* get display information */

    }
    /* set hi_dyn_on */
    {
	IGRint bufsize;
	IGRint nret;

	bufsize = sizeof(IGRboolean);
        gr$get_dynamics_on(	msg    = &msg2,
				sizbuf = &bufsize,
				buffer = (IGRchar *)&wrk_p->hi_dyn_on,
				nret   = &nret);
    }

    *msg = msg2;

    /*
     * prepare view form for this command (expand key)
     */

    DPprepare_vw_form();

    return(TRUE);
}

/**********************************************************************/
/* Should be called at sleep()					      */
/**********************************************************************/

IGRint DPvw_end(msg,wrk_p,in_flags)
IGRlong *msg;
struct DPview_wrk_t *wrk_p;
IGRint in_flags;
{
    IGRint		i;
    IGRint		rect,front,back;

    for(i=0;i<wrk_p->num_wins;i++)
    {
	if ( wrk_p->windows[i].objid == NULL_OBJID )
	   continue;  /* this window has been deleted */

	if(in_flags & DP_ERASE_HI_PLANE)
	{
	  /* 
	   *  erase hilite_planes for all windows 
	   */

            WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_NOOP | WL_HILITE_ERASE) );

	    DPco_erase_win(msg,wrk_p->win_no[i],
	      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
	      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);
	}

       /*
    	* enable all window's all planes 
    	*/
        WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_DRAW | WL_HILITE_DRAW) );

       /*	
	* Set other windows' clipping status back to their original case.
	*/
	if( i == wrk_p->curr_win)  continue;

	rect = wrk_p->winflags[i] & CLIP;
	front = wrk_p->winflags[i] & FRONT_CLIP;
	back = wrk_p->winflags[i] & BACK_CLIP;
        DPpush_clip(msg,rect,front,back,wrk_p->win_dit_rng[i],
                    wrk_p->gpipe_id[i], wrk_p->vw_volume);
    }

    
    /* if prev command die, this would be wokeup. We need user to identify
       a window again */ 

    wrk_p->curr_win = -1;


    return(TRUE);

}





/********************************************************/
/* pick current window 					*/
/* and set other window's attributes for displaying pyramids	*/
/********************************************************/

IGRint DPpick_curr_window(msg,win_objid,wrk_p)
IGRlong *msg;
GRobjid win_objid;
struct DPview_wrk_t  *wrk_p;

{
    int i;

    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;
    IGRint		status;
    IGRint flag[2];

    wrk_p->curr_win = -1;

    for(i=0;i<wrk_p->num_wins;i++)
    {
	if ( wrk_p->windows[i].objid == NULL_OBJID )
	   continue;  /* this window has been deleted */

	if( win_objid == wrk_p->windows[i].objid )
	{
	    wrk_p->curr_win = i;

	    /* according the viewing form,  turn clip on/off */


	    if( wrk_p->s_clipping == OFF )
	    {
		    flag[0] = FRONT_CLIP|BACK_CLIP;
		    flag[1] = 0;
	    }
	    else
	    {
		    flag[0] = FRONT_CLIP|BACK_CLIP;
		    flag[1] = FRONT_CLIP|BACK_CLIP;
	    }

	    inq_array[0].var = GRAGAD_FLAGS;
    	    inq_array[0].var_ptr = (char *)flag;
    	    inq_array[0].num_bytes = sizeof(IGRint)*2;
	    inq_array[0].bytes_returned = &nbytes_ret;
	    inq_array[1].var = END_PARAM;

    	    status = dp$inq_set_gragad(msg = msg,
		          inq0_set1 = 1, calc_info = 1,
                      gragad_objid = wrk_p->windows[i].objid,
                             osnum = wrk_p->windows[i].osnum,
                       which_error = &error_var,
                          var_list = inq_array);

	}
	else /* other window */
	{
	    /*  if window exits, turn off clipping */
		if (!(ex$is_batch()))
		{
		            if( WLset_drawing_mode( wrk_p->win_no[i], 
                                                    (WL_BASE_NOOP | WL_HILITE_DRAW) ) == WL_SUCCESS )
			    {
			       /* turn clip off so whole pyramid can show */

			       DPpush_clip(msg,0,0,0,wrk_p->win_dit_rng[i],
                                           wrk_p->gpipe_id[i], wrk_p->vw_volume);
			    }
		}
	}
    }
    if( wrk_p->curr_win == -1 )
    {
#ifdef DEBUG
	fprintf(stderr,"DPview.I: syserr -- 101");
#endif
	return(DP_SYS_ERR);
    }
    return(TRUE);
}


/********************** DPdp_pyramid() **************************/
/* display the pyramid on all other windows			*/
/* Assuming that the hilite planes were already enabled		*/
/****************************************************************/

IGRint DPdp_pyramid(msg,pyrmd_p,wrk_p,view_to_wld,erase)
IGRlong *msg;
struct DPpyramid_t   *pyrmd_p;
struct DPview_wrk_t  *wrk_p;
IGRdouble *view_to_wld;
IGRint	erase;

{
    IGRint i,j;
    IGRint hi_weight = 1;	  /* hilite weight, for indexing */
    IGRint nr_weight = 0;	  /* normal weight */
#if FALSE
#if defined( ENV5 )
    IGRint win_not_exist, c_status;
#endif
#endif


   /*
    *  display pyramids
    */

    DPset_pyramid(msg,pyrmd_p,wrk_p,view_to_wld);


    for(i=0; i< wrk_p->num_wins; i++)
    {
	if ( wrk_p->windows[i].objid == NULL_OBJID )
	   continue;  /* this window has been deleted */

        /* !!! need check to see if window is collapsed in WL/DL !!! */
        /* !!! if (collapsed)  continue                          !!! */

	if ( i == wrk_p->curr_win ) /* never display pyramid in curr_win - CR92n5369 */
	{
	   continue;
	}

	if ( erase )	/* note: curr window hi-plane not erased ! and should not erase because of the rubber line*/
	{
            WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_NOOP | WL_HILITE_ERASE) );

	    DPco_erase_win(msg,wrk_p->win_no[i],
	      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
	      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);
	}

	/*
	 * view vector
	 */

	/* coi point */
	DLdraw_3D_point_string( wrk_p->gpipe_id[i], &(pyrmd_p->lines_pts[0][3]), 1,
                                0, 2, DL_OPT_HILITE_DRAW );

	/* view line */	
	DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->lines_pts[0], 2, 
                               0, DP_SOLID_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	
	/*
	 * other parts 
	 */

	if( wrk_p->idx_flag & FOCAL_INDEXED )
	{
	    for(j=1; j<5; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }
	    
	    for(j=5; j<13; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }
	}
	else if(wrk_p->idx_flag &  LEVEL_HRZN_INDEXED )
	{
	    for(j=5; j<9; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0XFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }

	    for(j=1; j<5; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }

	    for(j=9; j<13; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }
	}
	else if ( wrk_p->idx_flag & VIEW_XY_INDEXED)
	{
	    for(j=5; j<13; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }

	    for(j=1; j<5; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }
	}
	else if( wrk_p->idx_flag & VIEW_XZ_INDEXED)
	{
	    for(j=1; j<9; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }

	    for(j=9; j<13; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }
	}
	else if( wrk_p->idx_flag & VIEW_YZ_INDEXED)
	{

	    for(j=1;j<5; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }
	    for(j=9; j<13; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }

	    for(j=5; j<9; j++)
	    {
	       DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->p_lines[j], 2,
                                      0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }
	}
	else /* ( wrk_p->idx_flag ==0 || (wrk_p->idx_flag & VIEW_XYZ_INDEXED) ) */
	{
	    if( wrk_p->idx_flag & VIEW_XYZ_INDEXED )
	    {
	        for(j=1;j<5;j++)
	        {
	           DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->lines_pts[j], 2,
                                          0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	        }
	        DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->planes_pts[0], 5,
                                       0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );

	        DLdraw_3D_line_string( wrk_p->gpipe_id[i],pyrmd_p->planes_pts[1], 5,
                                       0, DP_SOLID_LINE_STYLE, 0xFFFF, hi_weight, DL_OPT_HILITE_DRAW );
	    }
	    else
	    {
	        for(j=1;j<5;j++)
	        {
	           DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->lines_pts[j], 2,
                                          0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	        }
	        DLdraw_3D_line_string( wrk_p->gpipe_id[i], pyrmd_p->planes_pts[0], 5,
                                       0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );

	        DLdraw_3D_line_string( wrk_p->gpipe_id[i],pyrmd_p->planes_pts[1], 5,
                                       0, DP_DASHED_LINE_STYLE, 0xFFFF, nr_weight, DL_OPT_HILITE_DRAW );
	    }

	}
	WLflush( wrk_p->win_no[i] );

    }

    return(TRUE);
}

/************************************************************************/
/* reset the pyramid with values from wrk_p				*/
/************************************************************************/

IGRint DPset_pyramid(msg,pyrmd_p,wrk_p,view_to_wld)
IGRlong *msg;
struct DPpyramid_t   *pyrmd_p;
struct DPview_wrk_t  *wrk_p;
IGRdouble *view_to_wld;
{
    int num_points = 1;
    IGRdouble   plane1[15],	/* wld position of front clip plane */
		plane2[15];
    IGRdouble   x,y;

#ifdef DEBUG
printf("In DPset_pyramid()\n"); fflush(stdout);
#endif

    *msg = OM_S_SUCCESS;

	/* Line: eye --- coi */

   	pyrmd_p->lines[0].points[0] = wrk_p->eye_pt[0];
   	pyrmd_p->lines[0].points[1] = wrk_p->eye_pt[1];   
   	pyrmd_p->lines[0].points[2] = wrk_p->eye_pt[2];   
   	pyrmd_p->lines[0].points[3] = wrk_p->coi[0];   
   	pyrmd_p->lines[0].points[4] = wrk_p->coi[1];   
   	pyrmd_p->lines[0].points[5] = wrk_p->coi[2];   

	if( ! (wrk_p->flags & IS_PERSP) )  /* non persp */
	{
	    /* near plane */

	    plane1[0] = wrk_p->vw_volume[3];	/* on near plane, point 1 */
	    plane1[1] = wrk_p->vw_volume[4];
	    plane1[2] = wrk_p->vw_volume[5];     /* vw_volume[2] is always positive !! */

	    plane1[3] = wrk_p->vw_volume[0];	/* on near plane, point 2 */
	    plane1[4] = wrk_p->vw_volume[4];
	    plane1[5] = wrk_p->vw_volume[5];
	    
	    plane1[6] = wrk_p->vw_volume[0];	/* on near plane, point 3 */
	    plane1[7] = wrk_p->vw_volume[1];
	    plane1[8] = wrk_p->vw_volume[5];

	    plane1[9] = wrk_p->vw_volume[3];	/* on near plane, point 4 */
	    plane1[10] = wrk_p->vw_volume[1];
	    plane1[11] = wrk_p->vw_volume[5];

	    plane1[12] = plane1[0];
	    plane1[13] = plane1[1];
	    plane1[14] = plane1[2];

	    /* far plane */

	    plane2[0] = wrk_p->vw_volume[3];	/* on far plane, point 1 */
	    plane2[1] = wrk_p->vw_volume[4];
	    plane2[2] = wrk_p->vw_volume[2];

	    plane2[3] = wrk_p->vw_volume[0];	/* on far plane, point 2 */
	    plane2[4] = wrk_p->vw_volume[4];
	    plane2[5] = wrk_p->vw_volume[2];
	    
	    plane2[6] = wrk_p->vw_volume[0];	/* on far plane, point 3 */
	    plane2[7] = wrk_p->vw_volume[1];
	    plane2[8] = wrk_p->vw_volume[2];

	    plane2[9] = wrk_p->vw_volume[3];	/* on far plane, point 4 */
	    plane2[10] = wrk_p->vw_volume[1];
	    plane2[11] = wrk_p->vw_volume[2];

	    plane2[12] = plane2[0];
	    plane2[13] = plane2[1];
	    plane2[14] = plane2[2];

	   /*
	    * since the wrk_p->vw_volume[] is with resp. to wrk_p->eye_pt[],
	    * here I must use wrk_p->view_to_wld[][] to transform planes to
	    * the wld system.
	    */
	    num_points = 5;
	    MAptsxform(msg, (IGRlong *)&num_points,view_to_wld,plane1,plane1); /* to wld */
	    MAptsxform(msg, (IGRlong *)&num_points,view_to_wld,plane2,plane2); /* to wld */

	    /* lines */

	    pyrmd_p->lines[1].points[0] = plane1[3];  
	    pyrmd_p->lines[1].points[1] = plane1[4];
	    pyrmd_p->lines[1].points[2] = plane1[5];
	    pyrmd_p->lines[1].points[3] = plane2[3];
	    pyrmd_p->lines[1].points[4] = plane2[4];
	    pyrmd_p->lines[1].points[5] = plane2[5];

 	    pyrmd_p->lines[2].points[0] = plane1[6];  
	    pyrmd_p->lines[2].points[1] = plane1[7];
	    pyrmd_p->lines[2].points[2] = plane1[8];
	    pyrmd_p->lines[2].points[3] = plane2[6];
	    pyrmd_p->lines[2].points[4] = plane2[7];
	    pyrmd_p->lines[2].points[5] = plane2[8];

 	    pyrmd_p->lines[3].points[0] = plane1[9];  
	    pyrmd_p->lines[3].points[1] = plane1[10];
	    pyrmd_p->lines[3].points[2] = plane1[11];
	    pyrmd_p->lines[3].points[3] = plane2[9];
	    pyrmd_p->lines[3].points[4] = plane2[10];
	    pyrmd_p->lines[3].points[5] = plane2[11];

 	    pyrmd_p->lines[4].points[0] = plane1[0];  
	    pyrmd_p->lines[4].points[1] = plane1[1];
	    pyrmd_p->lines[4].points[2] = plane1[2];
	    pyrmd_p->lines[4].points[3] = plane2[0];
	    pyrmd_p->lines[4].points[4] = plane2[1];
	    pyrmd_p->lines[4].points[5] = plane2[2];

	    OM_BLOCK_MOVE(plane1,pyrmd_p->planes[0].points,sizeof(IGRdouble)*15);

	    OM_BLOCK_MOVE(plane2,pyrmd_p->planes[1].points,sizeof(IGRdouble)*15);

	}
	else 	/* perspective */
	{

	    /* other lines */

	    x = wrk_p->vw_volume[5] * wrk_p->tan_x;
	    y = wrk_p->vw_volume[5] * wrk_p->tan_y;

	    plane1[0] = x;
	    plane1[1] = y;
	    plane1[2] = wrk_p->vw_volume[5];

	    plane1[3] = -x;
	    plane1[4] =  y;
	    plane1[5] = wrk_p->vw_volume[5];
	    
	    plane1[6] = -x;
	    plane1[7] = -y;
	    plane1[8] = wrk_p->vw_volume[5];

	    plane1[9] =  x;
	    plane1[10] = -y;
	    plane1[11] = wrk_p->vw_volume[5];

	    num_points = 4;
	    MAptsxform(msg, (IGRlong *)&num_points,view_to_wld,plane1,plane1); /* to wld */

	    plane1[12] = plane1[0];
	    plane1[13] = plane1[1];
	    plane1[14] = plane1[2];


	    x = wrk_p->vw_volume[2] * wrk_p->tan_x;
	    y = wrk_p->vw_volume[2] * wrk_p->tan_y;

	    plane2[0] = x;
	    plane2[1] = y;
	    plane2[2] = wrk_p->vw_volume[2];

	    plane2[3] = -x;
	    plane2[4] =  y;
	    plane2[5] = wrk_p->vw_volume[2];
	    
	    plane2[6] = -x;
	    plane2[7] = -y;
	    plane2[8] = wrk_p->vw_volume[2];

	    plane2[9]  =  x;
	    plane2[10] = -y;
	    plane2[11] = wrk_p->vw_volume[2];

	    num_points = 4;
	    MAptsxform(msg,(IGRlong *)&num_points,view_to_wld,plane2,plane2); /* to wld */

	    plane2[12] = plane2[0];
	    plane2[13] = plane2[1];
	    plane2[14] = plane2[2];


	   /* set the 4 pyrmd lines */

	    pyrmd_p->lines[1].points[0] = wrk_p->eye_pt[0]; 
	    pyrmd_p->lines[1].points[1] = wrk_p->eye_pt[1];
	    pyrmd_p->lines[1].points[2] = wrk_p->eye_pt[2];
	    pyrmd_p->lines[1].points[3] = plane2[3];
	    pyrmd_p->lines[1].points[4] = plane2[4];
	    pyrmd_p->lines[1].points[5] = plane2[5];

 	    pyrmd_p->lines[2].points[0] = wrk_p->eye_pt[0]; 
	    pyrmd_p->lines[2].points[1] = wrk_p->eye_pt[1];
	    pyrmd_p->lines[2].points[2] = wrk_p->eye_pt[2];
	    pyrmd_p->lines[2].points[3] = plane2[6];
	    pyrmd_p->lines[2].points[4] = plane2[7];
	    pyrmd_p->lines[2].points[5] = plane2[8];

 	    pyrmd_p->lines[3].points[0] = wrk_p->eye_pt[0]; 
	    pyrmd_p->lines[3].points[1] = wrk_p->eye_pt[1];
	    pyrmd_p->lines[3].points[2] = wrk_p->eye_pt[2];
	    pyrmd_p->lines[3].points[3] = plane2[9];
	    pyrmd_p->lines[3].points[4] = plane2[10];
	    pyrmd_p->lines[3].points[5] = plane2[11];

	    pyrmd_p->lines[4].points[0] = wrk_p->eye_pt[0];  
	    pyrmd_p->lines[4].points[1] = wrk_p->eye_pt[1];
	    pyrmd_p->lines[4].points[2] = wrk_p->eye_pt[2];
	    pyrmd_p->lines[4].points[3] = plane2[0];
	    pyrmd_p->lines[4].points[4] = plane2[1];
	    pyrmd_p->lines[4].points[5] = plane2[2];

	   /* set the two cliping planes */

	    OM_BLOCK_MOVE(plane1,pyrmd_p->planes[0].points,sizeof(IGRdouble)*15);
	    OM_BLOCK_MOVE(plane2,pyrmd_p->planes[1].points,sizeof(IGRdouble)*15);
	}

    return(TRUE);
}

/***************************************************************************/
/* see if levels1[]'s "1" bits is a subset of levels2[]'s "1" bits	   */
/***************************************************************************/

IGRint DPlevels_is_included(levels1,levels2)
char *levels1, *levels2;   			/* array of [32] */
{
    IGRint i,t;

    for(i=0;i<32;i++)
    {
	t = levels1[i] & (~levels2[i]);  /* use lv2[]'s 1 to kill lv1[]'s 1 */
	if ( t )  /* not all killed */
	{
	    return(FALSE);
	}
    }
    return(TRUE);
}


/************************************************************************/
/* find class name of the window obj					*/
/************************************************************************/

IGRint  DPwindow_class(window)
struct GRid *window;
{
    IGRchar classname[80];

    om$get_classname(osnum = window->osnum,
		   objid = window->objid,
		   classname = classname);

#ifdef DEBUG
printf("Classname is --%s--\n",classname);
#endif

    if(strcmp(classname,"IGEgragad")==0)
	return(IGEFRAME);
    else if(strcmp(classname,"HSgragad")==0)
	return(HSFRAME);
    else
    {
	return(IGEFRAME);  /* unknown window => assume wireframe */
    }
}

/**********************************************************************/

IGRint DPfactor_zoom(msg,factor,base_p,wrk_p,pyrmd_p)
IGRlong *msg; 
IGRdouble factor;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
struct DPpyramid_t *pyrmd_p;
{

    if(wrk_p->curr_win == -1)
    {
	return(TRUE);
    }

    DPcal_zoom(msg,factor,base_p,wrk_p,0);

    /* update gragad */

    DPwrk_to_gg(msg,wrk_p,(struct DPgra_gad *)NULL,TRUE);

    /* get new base_p and wrk_p */

    DPget_base_wrk(msg,base_p,wrk_p);
    
   /*
    * if the hilite plane dynamics was on,
    *  display pyramids on all other windows's hilite plane
    */

    if( wrk_p->hi_dyn_on)
    {
        DPdp_pyramid(msg,pyrmd_p,wrk_p,wrk_p->view_to_wld,TRUE); 
	/* TRUE: erase the hilite plane first */
    }
    return(TRUE);


}


/*--- DPcvrt_wld_pnt_to_dits ----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
void DPcvrt_wld_pnt_to_dits( OM_S_OBJID win_id,
			     OMuword    win_os,
			     IGRdouble  x,
			     IGRdouble  y,
			     IGRdouble  z,
			     IGRint     *dit_x, 
			     IGRint     *dit_y )
#else
void DPcvrt_wld_pnt_to_dits( win_id, win_os, x, y, z, dit_x, dit_y )

	OM_S_OBJID win_id;
	OMuword    win_os;
	IGRdouble  x,y,z;
	IGRint     *dit_x, *dit_y;
#endif

	{
	IGRlong          msg;
	IGRlong          nbytes_ret;
	IGRlong          error_var;
	IGRdouble        new_x, new_y, w;
	struct DPgra_gad gg;
	struct var_list  var_list[2];

    	var_list[0].var = GRAGAD_STRUCT;
    	var_list[0].var_ptr = (char *)&gg;
    	var_list[0].num_bytes = sizeof(struct DPgra_gad);
    	var_list[0].bytes_returned = &nbytes_ret;
    	var_list[1].var = END_PARAM;

	dp$inq_set_gragad( msg          = &msg,
	                   gragad_objid = win_id,
	                   osnum        = win_os,
	                   which_error  = &error_var,
	                   var_list     = var_list );


	if ( gg.flags & IS_PERSP )
	   {
	   /* perspective => transform to XYZW, do perspective divide */
	   /* and scale to the viewport                               */
	   new_x = (gg.wld_to_view[0][0] * x) +
	           (gg.wld_to_view[0][1] * y) +
	           (gg.wld_to_view[0][2] * z) +
	           (gg.wld_to_view[0][3]);
	   new_y = (gg.wld_to_view[1][0] * x) +
	           (gg.wld_to_view[1][1] * y) +
	           (gg.wld_to_view[1][2] * z) +
	           (gg.wld_to_view[1][3]);
	   w     = (gg.wld_to_view[3][0] * x) +
	           (gg.wld_to_view[3][1] * y) +
	           (gg.wld_to_view[3][2] * z) +
	           (gg.wld_to_view[3][3]);

	   /* perspective division and scaling to the viewport */
	   new_x = ((new_x / w) + 1.0) * ((gg.dit_clip_range[3] - gg.dit_clip_range[0]) * 0.5);
	   new_y = ((new_y / w) + 1.0) * ((gg.dit_clip_range[4] - gg.dit_clip_range[1]) * 0.5);
	   }
	else
	   {
	   /* parallel => transform directly to viewport */
	   new_x = (gg.wld_to_viewport[0][0] * x) +
	           (gg.wld_to_viewport[0][1] * y) +
	           (gg.wld_to_viewport[0][2] * z) +
	           (gg.wld_to_viewport[0][3]);
	   new_y = (gg.wld_to_viewport[1][0] * x) +
	           (gg.wld_to_viewport[1][1] * y) +
	           (gg.wld_to_viewport[1][2] * z) +
	           (gg.wld_to_viewport[1][3]);
	   }

	*dit_x = new_x + 0.5;
	*dit_y = new_y + 0.5;
	}

end implementation DPvw;

