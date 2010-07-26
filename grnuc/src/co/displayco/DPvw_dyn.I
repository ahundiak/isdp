/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:21 $
$Locker:  $
*/

/* 
HISTORY:
	05/26/92  When in real dynamics, 
		(1) to make dynamics faster, don't draw the index line, and 
		    display the pyramids only at the end of each dynamics phase.
		(2) when indexing is on, for commands like rotate_around_coi,
		    rotate_around_eye, and pan, movement is locked in the X or
		    Y direction depending on the first movement of the cursor.
		(3) fixed a small bug:	at 
			if( (x == wrk_p->x0) && (y == wrk_p->y0) )
		    which sometimes can cause a little hesitation in dynamics 
		    movement
*/

class implementation DPvw;

#include <journal.h>
#include "wl.h"

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

#include "igrdef.h"
#include "dpmacros.h"
#include "dpstruct.h"

#include "msdef.h"
#include "msmacros.h"
#include "igrtypedef.h"

#include "DPview.h"

/* prototype include files */
#include "DPvw_dyn.h"
#include "DPinvmxRT.h"
#include "dpalignper.h"
#include "DPvw_cal.h"
#include "DPvwi.h"

#include "maidmx.h"
#include "mamulmx.h"

#if defined( X11 )
extern Display *EXdisplay;
#endif

#define  VIEW_DYN 2001

from IGEgragad import DPcal;

/*
 * on return, wrk_p->phase_state has one of the states:
 * DP_DYN_END 		this dyn phase ended completely 
 * DP_DYN_ABORT 	this dyn phase is abort, (right button) 
 *   when DP_DYN_ABORT, the base_p, wrk_p and the window are the same. Other
 * cases, they are not consistent: base_p has the old value. 
 */

IGRint DPdyn_func(
   IGRchar *func_parm,
   IGRint *lwin_no,
   struct DPgra_gad *curr_gg_p, /* pointer to the current win gragad */
   IGRint *done,
   IGRint *state,
   IGRint *number_of_cycles,
   IGRint *unlimited_cycles,
   IGRint *frame_no )

{
    IGRlong msg;

    struct func_parm_t *pm;   		/* pointer to the parm struct */
    struct DPbase_gg_t *base_p;
    struct DPpyramid_t *pyrmd_p;
    struct DPview_wrk_t *wrk_p;
    IGRint x, y, button;
    WLuint32 base_context_no;
    struct WLnative_info native_info;
    IGRint work_area, keys_buttons;
#if defined( X11 )
    XEvent xevent;
#elif defined( ENV5 )
    IGRint hwwin_no, events, transition, timetag;
#endif
    IGRshort  four = 4;
    IGRdouble trans[4][4];
    IGRdouble view_to_wld[4][4];
    IGRdouble rad_h,rad_v,factor;
    IGRint    i, jj;
    IGRdouble tmpdbl;
/*
    int entered_db = 0;
*/


    pm = (struct func_parm_t *) func_parm;
    pyrmd_p = pm->pyrmd_p;
    wrk_p = pm->wrk_p;
    base_p = pm->base_p;

   /*
    * if abort last time, now exit. The reason why not exit last time is to
    * let display_frame() to update the view back to the original one.
    */
    if( wrk_p->phase_state == DP_DYN_ABORT )
    {
	*done = TRUE;
	goto wrapup;
    }

    /* if DP_DYN_END last time, now exit. We didn't exit last time because
       the "end" data point is used in the calculation and display */ 
    if( wrk_p->phase_state == DP_DYN_END )
    {
	if(JNL_journal() && wrk_p->s_auto)
	{
	    /* Write to Journal records. When view is changed continuously
	       this is the only way we can make journaling playback later */
	    DPvw_save_view_to_jnl(wrk_p);
	}

	*done = TRUE;
	goto wrapup;
    }

   /*
    * last time maybe a WAIT state. clear it
    */

    *state = ~WAIT;   /* not wait, maybe I shall use some other value ? */


    /*
     * get button state 
     */

    wrk_p->phase_state = DP_DYN_CON;   /* if no other event, state will be this */


    WLget_window_base_context( *lwin_no, &base_context_no );
    WLget_native_info( *lwin_no, base_context_no, &native_info );

#if defined( X11 )
    if (JNL_XCheckMaskEvent(EXdisplay, ButtonPressMask|KeyPressMask, &xevent))
    {
       if (xevent.type == ButtonPress)	
       { 
	  x = xevent.xbutton.x; /* get the (x,y) position */
	  y = xevent.xbutton.y;

          button = xevent.xbutton.button - 1;
          switch (button)
          {
                case 1:  /* middle button */
	            if (xevent.xbutton.window == native_info.base_win)
                       wrk_p->phase_state = DP_DYN_END;
		    else
			wrk_p->phase_state = DP_DYN_ABORT;
                    break;

                case 0:  /* left button */

                case 2:  /* right button */
                    wrk_p->phase_state = DP_DYN_ABORT;
                    break;
          }
       }
       else
	  wrk_p->phase_state = DP_DYN_ABORT;
    }
#elif defined( ENV5 )
    JNL_inq_events(&events);
    events &= ~TIMER_EVENT;

    if ( events)
    {
    	if ( ! (events & BUTTON_EVENT) )  /* maybe a key in (xy= ) */
    	{
	    wrk_p->phase_state = DP_DYN_ABORT;
	    if (events & DELETE_EVENT)
	       {
	       IGRint vs_no;

	       if ( Inq_win_vs( native_info.base_win, &vs_no ) )
	          {
	          /* deleted curr_win => get out */
	          *done = TRUE;
	          return( TRUE );
	          }
	       }
    	}
	else
	{
            JNL_inq_button_data( &hwwin_no, &x, &y, &button, &transition, &timetag );

    	    switch (button)
    	    {
	        case MIDDLE_BUTTON:
        	    if ( native_info.base_win == hwwin_no )
			wrk_p->phase_state = DP_DYN_END;
		    else
			wrk_p->phase_state = DP_DYN_ABORT;

		    break;

	        case LEFT_BUTTON:
	        case RIGHT_BUTTON:
			wrk_p->phase_state = DP_DYN_ABORT;
		    break;
    	    }

	    /* clear button events buffer */
	    if( native_info.base_win == hwwin_no)
	    {
		JNL_get_button_data( &hwwin_no, &x, &y, &button, &transition, &timetag );
	    }
	}
    }
#endif

   /* If dynamics continues, get the current mouse position. 
      But if dynamics ends, use the (x,y) from the DATA button, which is 
      important for journaling, since journaling doesn't save mouse movements */

    if( wrk_p->phase_state == DP_DYN_CON)
    {
       /*
	*  if mouse outside the current window, do nothing. but wait until
	*  the mouse back, or other events happen
	*/
        WLmouse_position( *lwin_no, &x, &y, &work_area, &keys_buttons );
        if ( ! work_area )
        {  
	      *state = WAIT;    /* will not to redisplay */
	      goto wrapup;
        }

    }

   /*
    * process
    */

    if( wrk_p->phase_state == DP_DYN_END )
    { 
	/* If is playing back and the command was in auto movement 
	   mode before, we will get the viewing info from the journal
	   file directly */

	if(JNL_playback() && wrk_p->s_auto)
	{
	    DPvw_get_view_fr_jnl(wrk_p);
	    goto wrk_to_gg;
	}
	else
	{
	   /* 
	   Use the "end" data point to calculate the gragad, because this
	   data point is saved in the journaling file, and can be used
	   to play back. (mouse movement events are not saved in the
	   journal file) 

	   Note:x,y variables are already set by the JNL_inq_button_data()
	 
     
 	   /* set "done" to out of the while loop which calls this func */

	   *done = TRUE;
	   goto wrapup;
	}
    }


   /*
    * abort
    */

    if( wrk_p->phase_state == DP_DYN_ABORT )
    {
	DPbase_to_wrk(&msg,base_p,wrk_p);
	goto wrk_to_gg;
    }

    /*
     * continue dynamics
     */

    else
    {

/*
        for ( jj = 0; jj < wrk_p->num_wins; jj++)
        {
           WLenter_db( wrk_p->win_no[jj] );
        }
        entered_db = TRUE;
*/
	if( ! wrk_p->s_auto &&
     	    ( x == wrk_p->prev_x && y == wrk_p->prev_y ) )
	{
	   /*
	    * In the drag mode, if Mouse is not moved, then no need to 
	    * calculate and redisplay. But since rubber line was erased,
	    * we need to redraw it 
	    */

	      if(!wrk_p->s_real_dyn) 
              {
	         DPrubber_line(*lwin_no,&x,&y,wrk_p,TRUE); 
              }

	      *state = WAIT;    /* will not to redisplay */
	      goto wrk_to_gg;
	}

	/* save prev_x, prev_y */

    	wrk_p->prev_x = x;
    	wrk_p->prev_y = y;

       /*
	* if rubline line length is 0, no operation since no cursor movement
	*/

	if( (x == wrk_p->x0) && (y == wrk_p->y0) )
	{
	   *state = WAIT;    /* will not to redisplay */
	   goto wrapup;
	}

	/*
	 * if not real_dynamics draw rubber line and adjust x,y if indexed
	 */


        if(!wrk_p->s_real_dyn)
	{
	    DPrubber_line(*lwin_no,&x,&y,wrk_p,TRUE);
	}
	else
	{
	   if(wrk_p->s_indexing )  /* lock to X, or Y direction */
	   {
	      if(wrk_p->cmd_type==DP_AROUND_COI ||
		 wrk_p->cmd_type==DP_AROUND_EYE ||
		 wrk_p->cmd_type==DP_PAN )
	      {
		 if(wrk_p->cursor_axis_lock==1)       y = wrk_p->y0;
		 else if(wrk_p->cursor_axis_lock==2)  x = wrk_p->x0;
		 else
		 {
		    cursor_indexing(wrk_p,&x,&y);
		    if(y==wrk_p->y0 && (x-wrk_p->x0 > 2 || x-wrk_p->x0 < -2))
		       wrk_p->cursor_axis_lock = 1;
		    else if(x==wrk_p->x0 && (y-wrk_p->y0 > 2 || y-wrk_p->y0 < -2))
		       wrk_p->cursor_axis_lock = 2;
		 }
	      }
	   }
	}

	/*
	 * calculate new gg_p ane wrk_p.  Do DPcal() later.
	 */

	switch( wrk_p->cmd_type)
	{
	   case DP_ZOOM:
			factor = (double)(y - wrk_p->y0) / (double)base_p->scrn_length;

			if( factor > 0.0 ) /* zoom in */
			{
			    factor = 1.0 + factor * MAX_ZOOM_FACTOR;
			}
			else if( factor < 0.0 ) /* zoom out */
			{

			    factor = -factor;
			    factor = 1.0 / (1.0 + factor * MAX_ZOOM_FACTOR);
			}
			else  /* factor == 0 */
			{
			    factor = 1.0;
			}

			DPcal_zoom(&msg,factor,base_p,wrk_p,EN_AUTO);

		   break;

	   case DP_AROUND_COI:

    			rad_v = -6.0 * ( y - wrk_p->y0 ) / base_p->scrn_width ;
   			rad_h = 6.0 * ( x - wrk_p->x0 ) / base_p->scrn_width ;
			DPcal_around_coi(&msg,rad_v,rad_h,base_p,wrk_p,EN_AUTO|EN_INDEXING);
		   break;

	   case DP_AROUND_EYE:

			rad_v = 6.0 * ( y - wrk_p->y0 ) / base_p->scrn_width ;
	    		rad_h = 6.0 * ( x - wrk_p->x0 ) / base_p->scrn_width ;

	   		DPcal_around_eye(&msg,rad_v,rad_h,base_p,wrk_p,EN_AUTO|EN_INDEXING);
		   break;

	   case DP_PAN:
		      /* calc distance should be moved on the proj plane */

		       rad_h = (x - wrk_p->x0) /  base_p->scrn_width ;
		       rad_v = -(y - wrk_p->y0) /  base_p->scrn_length;

		       if(wrk_p->flags & IS_PERSP)
		       {
			   rad_h = 2.0 * rad_h * (wrk_p->coi_vw[2] * wrk_p->tan_x);
			   rad_v = 2.0 * rad_v * (wrk_p->coi_vw[2] * wrk_p->tan_y);
		       }
		       else
		       {
			   rad_h = rad_h * (wrk_p->vw_volume[0] - wrk_p->vw_volume[3]);
			   rad_v = rad_v * (wrk_p->vw_volume[1] - wrk_p->vw_volume[4]);
		       }

	    	       DPcal_pan(&msg,rad_h,rad_v,base_p,wrk_p,EN_AUTO);
		   break;

	   case DP_MV_EYE_TAR:
		   break;

	   case DP_TILT:
			  rad_h =  6.0 * ( x - wrk_p->x0 ) / base_p->scrn_width ;
			  DPcal_tilt(&msg,rad_h,base_p,wrk_p,EN_AUTO|EN_INDEXING);
			  break;

	   case DP_VWANGLE:
   		       /* change angle */

			tmpdbl = (double)(y - wrk_p->y0) / (double)base_p->scrn_length;

    			if(wrk_p->s_auto)
    			{
			    wrk_p->ratio_x +=  (tmpdbl/10.0);
			    wrk_p->ratio_x = ( wrk_p->ratio_x > PI)? PI:wrk_p->ratio_x;
			    tmpdbl = wrk_p->ratio_x;
			}

    		        wrk_p->vw_angle = base_p->gg.vw_angle + tmpdbl; 
			      
		        DPcal_vwangle(&msg,base_p,wrk_p,EN_INDEXING); /* adjust other value */

#ifdef NNNNNNN Too slow
		      /* display the adjusted angle or (mm) on the form ...... */

		        tmpdbl = wrk_p->vw_angle*180/PI;

		       if( wrk_p->idx_flag & FOCAL_INDEXED) 
    		       {
			  sprintf(buf,"%4.1f, %3d(mm)", 
			   	tmpdbl,wrk_p->idx_len[wrk_p->tmp_int]);
		          ex$message(field=ERROR_FIELD,in_buff=buf);

 			  sprintf(buf,"%4.1f, %3d(mm)",tmpdbl,
					wrk_p->idx_len[wrk_p->tmp_int]);
			  FIfld_set_text(wrk_p->view_form,ANGLE_FLD,0,0,buf,0);
   		       }
    		       else
    		       {
			  sprintf(buf,"%4.1f",tmpdbl);
		          ex$message(field=ERROR_FIELD,in_buff=buf);

 			  sprintf(buf,"%4.1f",tmpdbl);
			  FIfld_set_text(wrk_p->view_form,ANGLE_FLD,0,0,buf,0);
    		       }
#endif

		  break;
	}
    }

wrk_to_gg:

    if(wrk_p->s_real_dyn)
    {
    	/* set the gragad with values in wrk_p, and DPcal(), but not update
	   this will set up the gpipe, so display will be correct */

    	DPwrk_to_gg(&msg,wrk_p,curr_gg_p,FALSE);
    }
    else
    {
	/* not real dyn.  not to send to gg to until outside dynamics */
    }

    /* get the wld_to_view matrix for displaying pyramids */

    if( wrk_p->flags & IS_PERSP )
    {
	if(curr_gg_p)	/* can get directly from gragad */
	{
	    MAidmx(&msg, (IGRdouble *)trans);
    	    trans[0][3] = -wrk_p->eye_pt[0];
    	    trans[1][3] = -wrk_p->eye_pt[1];
    	    trans[2][3] = -wrk_p->eye_pt[2];
    	    MAmulmx(&msg, &four, &four, &four, (IGRdouble *)curr_gg_p->rotation,
			(IGRdouble *)trans, wrk_p->wld_to_view);
	}
	else 
	{
	   DPalignper(&msg,0,wrk_p->vpn,wrk_p->vup,wrk_p->eye_pt,
			(IGRdouble *)trans,wrk_p->wld_to_view);
	}
    }
    else /* parallel */
    {
	    MAidmx(&msg, (IGRdouble *)trans);
    	    trans[0][3] = -wrk_p->eye_pt[0];
    	    trans[1][3] = -wrk_p->eye_pt[1];
    	    trans[2][3] = -wrk_p->eye_pt[2];
    	    MAmulmx(&msg, &four, &four, &four, (IGRdouble *)wrk_p->rotation,
			(IGRdouble *)trans, wrk_p->wld_to_view);
    }

   /*
    * if not real dynamics and the hilite plane dynamics was on, display pyramids
    */
    if( !wrk_p->s_real_dyn && wrk_p->hi_dyn_on)
    {
      /* MAinvmx(&msg,&four,wrk_p->wld_to_view, view_to_wld); */
      DPinvmxRT((IGRdouble *)wrk_p->wld_to_view, (IGRdouble *)view_to_wld);
      DPdp_pyramid(&msg, pyrmd_p, wrk_p, (IGRdouble *)view_to_wld, TRUE); 
				   /* TRUE: erase the hilite plane first */
    }

wrapup:

    if ( !work_area ) 
    {
       return( TRUE );
    }

    if( *done )
    {
	/* erase the rubber line */
	i = wrk_p->curr_win;
        WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_NOOP | WL_HILITE_ERASE) );
    	DPco_erase_win(&msg,wrk_p->win_no[i],
	      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
	      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);

       /* if real_dynamice, display pyramids on other windows to show the 
	  end-of-dyn_phase results  */

	if( wrk_p->s_real_dyn && wrk_p->hi_dyn_on)
	{
	   /* MAinvmx(&msg,&four,wrk_p->wld_to_view, view_to_wld); */
	   DPinvmxRT((double *)wrk_p->wld_to_view, (double *)view_to_wld);
	   DPdp_pyramid(&msg, pyrmd_p, wrk_p, (IGRdouble *)view_to_wld, TRUE);
	                                /* TRUE: erase the hilite plane first */
	}
    
    }
/*
    if ( entered_db )
    {
       for(jj=0; jj< wrk_p->num_wins; jj++)
       {
          WLexit_db( wrk_p->win_no[jj] );
       }
       entered_db= FALSE;
    }
*/
    return(TRUE);
}

/********************************************************************/
DPrubber_line(lwin_no,x,y,wrk_p,erase)
IGRint lwin_no,*x,*y,erase;
struct DPview_wrk_t *wrk_p;

/* struct IGRdisplay *dis_att; */

{
    IGRlong   msg;
    IGRint    i;
    struct WLpoint points[2];

    /* if erase is true, then erase the line */

    if(erase)
    {
	/* erase the h_plane */
	i = wrk_p->curr_win;
        WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_NOOP | WL_HILITE_ERASE) );
    	DPco_erase_win(&msg,wrk_p->win_no[i],
	      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
	      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);
    }

    WLset_drawing_mode( lwin_no, (WL_BASE_NOOP | WL_HILITE_DRAW) );
    WLset_active_symbology( lwin_no, 0, DP_SOLID_LINE_STYLE, 0xFFFF, 0,
                            (WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT) );

    switch( wrk_p->cmd_type)
    {
	   case DP_ZOOM:
	   case DP_VWANGLE:
                       points[0].x = wrk_p->x0;
                       points[0].y = wrk_p->y0;
                       points[1].x = wrk_p->x0;
                       points[1].y = *y;
                       WLdraw_2D_line_string( lwin_no, 2, points );
		   break;

	   case DP_TILT:
                       points[0].x = wrk_p->x0;
                       points[0].y = wrk_p->y0;
                       points[1].x = *x;
                       points[1].y = wrk_p->y0;
                       WLdraw_2D_line_string( lwin_no, 2, points );
		   break;

	   case DP_AROUND_COI:
	   case DP_AROUND_EYE:
	   case DP_PAN:
			if(wrk_p->s_indexing)
			{
			    cursor_indexing(wrk_p,x,y);

			    if(wrk_p->idx_flag & CURSOR_INDEXED)
			    {
                               WLset_active_symbology( lwin_no, 0, 0, 0xFFFF, 2,
                                                       WL_SYMB_CHANGE_WEIGHT );
			    }
			}

                        points[0].x = wrk_p->x0;
                        points[0].y = wrk_p->y0;
                        points[1].x = *x;
                        points[1].y = *y;
                        WLdraw_2D_line_string( lwin_no, 2, points );
		   break;

	   case DP_MV_EYE_TAR:

		   break;
    }    /* else, wld_to_view were calculated in DPcal_cmd.I for parallel case */


    WLflush( lwin_no );

    return(TRUE);
}

/********************************************************************/
/* wrk_p->idx_flag is set.					    */
/* if cursor indexed, x,y are reset to the indexed value 	    */
/********************************************************************/

cursor_indexing(wrk_p,x,y)
struct DPview_wrk_t *wrk_p;
IGRint *x,*y;
{
    IGRdouble delt_x,delt_y;
    IGRdouble tmp_double;

    wrk_p->idx_flag = 0;

    if( (*x == wrk_p->x0) && (*y == wrk_p->y0) )
    {
	return(0);
    }
    else if( (*x == wrk_p->x0) || (*y == wrk_p->y0) )
    {
	wrk_p->idx_flag |= CURSOR_INDEXED;
    }
    else
    {
    	delt_x = (*x) - wrk_p->x0;
    	delt_y = (*y) - wrk_p->y0;

	tmp_double = delt_y / delt_x;
	tmp_double = (tmp_double < 0.0)? -tmp_double: tmp_double;

	if( tmp_double < wrk_p->idx_cursor_tol )
	{
	    *y = wrk_p->y0;
	    wrk_p->idx_flag |= CURSOR_INDEXED;
	}
	else if( tmp_double > (1.0/wrk_p->idx_cursor_tol) )
	{
	    *x = wrk_p->x0;
	    wrk_p->idx_flag |= CURSOR_INDEXED;
	}
    }

    return(0);
}

/*------------------------------------------------------------------------*/
DPvw_save_view_to_jnl(struct DPview_wrk_t *wrk_p)
{
    IGRint type, num_bytes;
    IGRchar buffer[400], *p;
    p = buffer;
    
    if(wrk_p->flags & IS_PERSP)
    {
	memcpy(p, (char*)&wrk_p->flags, sizeof(wrk_p->flags));
	p += sizeof(wrk_p->flags);

	memcpy(p, (char*)&wrk_p->vw_angle, sizeof(wrk_p->vw_angle));
	p += sizeof(wrk_p->vw_angle);

	memcpy(p, (char*)wrk_p->eye_pt, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->coi, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->vpn, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->vup, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->vw_volume, sizeof(IGRdouble)*6);
	p+= (sizeof(IGRdouble)*6);

	memcpy(p, (IGRchar*)&wrk_p->act_z, sizeof(wrk_p->act_z));
	p += sizeof(wrk_p->act_z);
    }
    else
    {
	memcpy(p, (char*)&wrk_p->flags, sizeof(wrk_p->flags));
	p += sizeof(wrk_p->flags);

	memcpy(p, (char*)wrk_p->eye_pt, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->coi, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy(p, (char*)wrk_p->rotation, sizeof(IGRdouble)*16);
	p+= (sizeof(IGRdouble)*16);

	memcpy(p, (char*)wrk_p->vw_volume, sizeof(IGRdouble)*6);
	p+= (sizeof(IGRdouble)*6);

	memcpy(p, (char*)&wrk_p->act_z, sizeof(wrk_p->act_z));
	p += sizeof(wrk_p->act_z);
    }

    type = JNL_CHAR;
    num_bytes = p - buffer;
    JNL_record_info_event(type, num_bytes, buffer);
   return(TRUE);
    
}

/*------------------------------------------------------------------------*/
DPvw_get_view_fr_jnl(struct DPview_wrk_t *wrk_p)
{
    IGRint event,type,num_bytes;
    IGRchar buffer[400], *p;
    
#ifdef X11
    XEvent     xevent;

    JNL_echo_input(sizeof(XEvent), (char*)&xevent);
    event = xevent.type;
    type = xevent.xkey.serial;
    num_bytes = xevent.xkey.x;

#else
    JNL_echo_input(4, (char *)&event);
    JNL_echo_input(4, (char *)&type);
    JNL_echo_input(4, (char *)&num_bytes);
#endif
    
    JNL_echo_input(num_bytes, buffer);
    p = buffer;
    
    if(wrk_p->flags & IS_PERSP)
    {
	memcpy((char*)&wrk_p->flags, p, sizeof(wrk_p->flags));
	p += sizeof(wrk_p->flags);

	memcpy((char*)&wrk_p->vw_angle, p, sizeof(wrk_p->vw_angle));
	p += sizeof(wrk_p->vw_angle);

	memcpy((char*)wrk_p->eye_pt, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->coi, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->vpn, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->vup, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->vw_volume, p, sizeof(IGRdouble)*6);
	p+= (sizeof(IGRdouble)*6);

	memcpy((char*)&wrk_p->act_z, p, sizeof(wrk_p->act_z));
	p += sizeof(wrk_p->act_z);
    }
    else
    {
	memcpy((char*)&wrk_p->flags, p, sizeof(wrk_p->flags));
	p += sizeof(wrk_p->flags);

	memcpy((char*)wrk_p->eye_pt, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->coi, p, sizeof(IGRdouble)*3);
	p+= (sizeof(IGRdouble)*3);

	memcpy((char*)wrk_p->rotation, p, sizeof(IGRdouble)*16);
	p+= (sizeof(IGRdouble)*16);

	memcpy((char*)wrk_p->vw_volume, p, sizeof(IGRdouble)*6);
	p+= (sizeof(IGRdouble)*6);

	memcpy((char*)&wrk_p->act_z, p, sizeof(wrk_p->act_z));
	p += sizeof(wrk_p->act_z);
    }
    
    if((p-buffer) != num_bytes) 
    {
	printf("DPvw_dyn.I: Bad Journal File Data\n");
	fflush(stdout);
	return(FALSE);
    }
    
    return(TRUE);
}

end implementation DPvw;
