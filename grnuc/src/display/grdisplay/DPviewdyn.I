class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <journal.h>
#include <assert.h>

#include "grimport.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "msdef.h"
#include "msmacros.h"
#include "madef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "grmessage.h"
#include "OMmacros.h"

#include "wl.h"
#include "dl.h"

/* prototype files */
#include "DPviewdyn.h"
#include "dpviewind.h"
#include "dpmacgenupd.h"
#include "dpdynevent.h"

#include "marotmx.h"
#include "masqrt.h"
#include "maptsxfor.h"
#include "exproto.h"

#if defined (X11)
#include "xdpdynevent.h"
#endif

struct DPframe
{
    IGRdouble	*frame_ptr;
    IGRdouble	block_size;
};

%safe
static IGRint		DPdyn_buffer_full;	/* TRUE if dynamics buffer full	*/
static IGRint		DPapp_fb_buffer_full;	/* TRUE if application buffer	*/
static struct DPframe   DPstatic_frame;		/* contains pointer to static 	*/
						/* frame 			*/
static struct DPframe	*DPdynamic_frames;	/* constiains pointer to an 	*/
						/* array of pointers to frames	*/
static IGRdouble	**DPactive_frame;	/* contain address of current 	*/
						/* dynamics frame, either the 	*/
						/* frame of a dynamic frame	*/
static IGRint		DPcurrent_display_frame;/* holds the currently 		*/
						/* displayed frame		*/
static IGRint		DPnum_of_frames;	/* number of frames stored in	*/
						/* display memory		*/
static IGRint		DPframe_active;		/* TRUE if a frame is active	*/
						/* (i.e. dp$start_frame was 	*/
						/* called, but dp$end_frame 	*/
						/* has not been called		*/
static IGRint		DPnum_of_frame_ptrs;	/* number of frame pointers	*/
						/* that have been allocated	*/
static IGRdouble	*DPdyn_buf_ptr;		/* pointer to current position	*/
						/* in dynamic frame		*/
static IGRdouble	*DPend_dyn_buf;		/* pointer to end of dynamic	*/
						/* frame			*/
static IGRdouble	*DPbeg_app_buf;		/* pointer to beginning of 	*/
						/* application buffer		*/
static IGRdouble	*DPapp_fb_buf_ptr;	/* pointer to current position	*/
						/* of application buffer	*/
static IGRdouble	*DPend_app_fb_buf;	/* pointer to end of application*/
						/* buffer			*/
static IGRdouble	*DPgpipe_fb_buf;	/* pointer to gpipe feedback	*/
						/* buffer			*/
static IGRdouble	**DPnext_block;
static IGRint		DPframe_block_size = 120 * 1024;
					 	/* contains the size in bytes of	*/
						/* the block size for the frames	*/
static GRobjid		DPframe_id;
static GRspacenum	DPframe_osnum;
%endsafe

from GRviewdyn import GRviewdyn_set_up,GRviewdyn_reset;

#define		SPEED_FACTOR	1.05

/************************************************************************/
/*									*/
/*	Method - display_frame						*/
/*									*/
/*									*/
/************************************************************************/

method display_frame(IGRdouble *frame; IGRint erase)
{

register   IGRdouble		*buf_ptr;
   IGRint		done = FALSE;
   IGRint		total_wtf;
   IGRint		poly_curve_wtf;
   IGRint		num_pts;
   IGRint		ele_type;
   IGRint		vi_type;
   IGRint		dyn_flags;
   IGRdouble		*next_block;
   struct IGRdisplay	*dis_attr;
   struct DPviewinfo	view_info;
   WLuint32             color_ref;


/* if erase is request, then erase before redraw	*/
	
	if (erase)
	{
	   WLclear_window( ME.IGEgadget->win_no );
	}


	buf_ptr = frame;

	if (*(IGRint *) buf_ptr != DPWIREFRAME_FRAME)
	{
	   goto wrapup;
	}

	buf_ptr++;

	next_block = (IGRdouble *) *(IGRint *) buf_ptr;
	buf_ptr++;

	while (!done && ((*(IGRuint *) buf_ptr) != 0))
	{
	   ele_type = *(IGRuint *) buf_ptr;

	   if (ele_type == DPFRAMELINK)
	   {
		buf_ptr = next_block;
		next_block = (IGRdouble *) *(IGRint *) buf_ptr;
		buf_ptr++;

		continue;
	   }

	   total_wtf = *((IGRint *) buf_ptr + 1);
	   buf_ptr++;

	   dyn_flags = *(IGRuint *) buf_ptr;

	   if (dyn_flags & DPVIEW_IND)
	   {
	      vi_type = *((IGRint *) buf_ptr + 1);
	      buf_ptr++;

	      om$send( msg = message IGEgragad.set_view_ind(vi_type,buf_ptr,
					&view_info),
			   	  senderid = NULL_OBJID,
			   	  targetid = my_id);

	      buf_ptr += 3;
	      total_wtf -= 8;
	   }
	   else
	   {
	      buf_ptr++;
	      total_wtf -= 2;
	   }

	   switch (ele_type)
	   {

		case IGRBC:
		case IGRQS:
		case IGRPY:
		case IGRLB:
		case IGRPS:		
			while (total_wtf > 0)
			{
			   dis_attr = (struct IGRdisplay *) buf_ptr;

			   WLpack_index_colorref( dis_attr->color, &color_ref, FALSE );

			   buf_ptr++;
			   total_wtf -= 2;
			   poly_curve_wtf = *(IGRint *) buf_ptr;
			   total_wtf -= (poly_curve_wtf +1);
			   buf_ptr++;
			   poly_curve_wtf--;
			
			   while (poly_curve_wtf > 0)
			   {
			      num_pts = *(IGRint *) buf_ptr;
			      buf_ptr++;
			      poly_curve_wtf -= 2;

			      if (num_pts)
			      {
				 if (ele_type == IGRPS)
				 {
			             DLdraw_3D_point_string( ME.IGEgragad->gragad.gpipe_id, buf_ptr, num_pts,
	                                                     color_ref, dis_attr->weight,
                                                             DL_OPT_BASE_DRAW);
				 }
				 else
				 {
			             DLdraw_3D_line_string( ME.IGEgragad->gragad.gpipe_id, buf_ptr, num_pts,
	                                                    color_ref, dis_attr->style, 0xFFFF, dis_attr->weight,
                                                            DL_OPT_BASE_DRAW);
				 }
			         buf_ptr += (num_pts * 3);
			
			         poly_curve_wtf -= (num_pts * 3 * 2);
			      }
			   }
			}
			break;



		default:
			done = TRUE;
			break;
	   }

	   if (dyn_flags & DPVIEW_IND)
	   {
	      om$send( msg = message IGEgragad.reset_view_ind(&view_info),
			   	  senderid = NULL_OBJID,
			   	  targetid = my_id);
	   }
	}/* end of while (!done)  */

wrapup:
	return(1);
}	


/************************************************************************/
/*									*/
/*	method - display_frames						*/
/*									*/
/*									*/
/************************************************************************/

method display_frames(IGRlong *msg; IGRint start_frame; IGRint relative_frame;
		      IGRint number_of_frames; IGRint number_of_cycles;
		      IGRint direction; IGRint erase; IGRint rotation_allowed;
		      IGRint db_allowed; IGRdouble zoom_factor;
		      IGRdouble pan_factor;  IGRdouble max_rotate_factor;
		      IGRint (*func_ptr)(); IGRchar *func_parms )

{

	IGRint		end_frame;	
	IGRint		frame_no;
	IGRint		old_frame=-1;
	IGRint		unlimited_cycles = FALSE;
	IGRint		frame_increment;
	IGRdouble	dframe_no;
	IGRdouble	dframe_increment;
	IGRdouble	dframe_limit;
	IGRboolean	speed_control;
	
    IGRlong   status = TRUE;
    IGRlong   msg1;
    IGRdouble tmp_point[6];
    IGRint    pan_state = TRUE;
    IGRlong   one = 1;
    IGRshort  rotate_flag;
    IGRint    x_extent;
    IGRint    y_extent;
    IGRint    erase_dyn_frame = TRUE;
    IGRint    max_extent;
    IGRdouble cent_x,cent_y;
    IGRdouble new_extents[2];
    IGRdouble vec[3];
    IGRdouble tmpdbl;
    IGRdouble rad;
    IGRdouble rot_matrix1[16];
    IGRint    pan_point[2];
    IGRint    done = FALSE;
    IGRint    x,y;
    IGRint    state = WAIT;
    IGRint    in_window;
    IGRint    key_buttons;
    WLuint32  lwin_no;
    IGRchar   new_name[DI_PATH_MAX];
    IGRchar   path_name[DI_PATH_MAX];
    IGRchar   tmpname[100];
    IGRchar   error_msg[120];
    IGRchar   buff[100];

    IGRchar   pan_name[100];
    IGRchar   rot_name[100];
    IGRchar   rot_speed_name[100];

    IGRint    old_state=-1;
    int       reading;

#if defined( X11 )
    int but_state;
#endif

	sprintf(pan_name, " ");
	sprintf(rot_name, " ");
	sprintf(rot_speed_name, " ");

	ex$message(buff = buff, msgnumb=GR_I_ZiPanZo);
        strcat(pan_name, buff);

	ex$message(buff = buff, msgnumb=GR_I_ZiRotZo);
        strcat(rot_name, buff);

	ex$message(buff = buff, msgnumb=GR_I_SuRotSd);
        strcat(rot_speed_name, buff);

	pan_state = FALSE;

/* make sure there are no frames active	*/

	if (DPframe_active)
	{
	   *msg = DPFRAMEACT;
	   goto wrapup;
	}

/* make sure there is at least on dynamic frame		*/

	if (DPnum_of_frames == 0)
	{
	   *msg = DPNOFRAMES;
	   goto wrapup;
	}
      

/* make sure start_frame is a valid frame number	*/
	
	if (start_frame == -1 )
	{
	   start_frame = DPcurrent_display_frame + relative_frame;
	}

	if (start_frame < 0)
	{
	   start_frame = 0;
	}
	else
	{
	   if (start_frame >= DPnum_of_frames)
	   {
	      start_frame = DPnum_of_frames - 1;
	   }
	}


/* calculate the end frame	*/

	if (direction == DPBACKWARD)
	{

/* check less than -1 because frames start at frame 0.  An example would be if
   starting frame is 3 and number of frames is 4, frame 3,2,1,0 would be
   displayed 	*/

	   if (number_of_frames == DPALL_FRAMES)
	   {
	      end_frame = 0;
	   }
	   else
	   {

	      if ((start_frame - number_of_frames) < -1)
	      {
	         number_of_frames = start_frame + 1;
	      }
	      end_frame = start_frame - number_of_frames +1;
	   }
	}
	else
	{
	   if (number_of_frames == DPALL_FRAMES)
	   {
	      end_frame = DPnum_of_frames - 1;
	   }
	   else
	   {

/* make sure number of frames is valid	*/

	      if ((start_frame + number_of_frames) > DPnum_of_frames)
	      {
	         number_of_frames = DPnum_of_frames - start_frame;
	      }
	      end_frame = start_frame + number_of_frames - 1;
	   }	
	}

	

/* check for unlimited cycles  */

	speed_control = (start_frame < end_frame);

	if (number_of_cycles == DPUNLIMITED_CYCLES)
	{
	   unlimited_cycles = TRUE;
	}

	/*  set up beginning frame number and which way to increment frames */
	
	frame_no = start_frame;
	dframe_no = (IGRdouble)frame_no;
	dframe_limit = (double)(end_frame - start_frame)/3.0;

	if( direction == DPBACKWARD )
		{
		frame_increment = -1;
		dframe_increment = -1.0;
		}
	else
		{
		frame_increment = 1;
		dframe_increment = 1.0;
		}


	DPcurrent_display_frame = start_frame;

	if (DPstatic_frame.frame_ptr || !erase)
	{
	    erase_dyn_frame = FALSE;
	}

	lwin_no = ME.IGEgadget->win_no;

/* find the extents of the window   */

	x_extent = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
	y_extent = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;

/* find the max extent of the window  */

	max_extent = ( x_extent > y_extent) ? x_extent : y_extent;

/* find center point of the window  */

	cent_x = (ME.IGEgadget->min_x_dep +ME.IGEgadget->max_x_dep) / 2.0;
	cent_y = (ME.IGEgadget->min_y_dep + ME.IGEgadget->max_y_dep) / 2.0;

	if( func_ptr == NULL )
	{
		/* concatanate ZI-PAN-ZO to window name and display in window strip  */

		status = di$untranslate (objname = path_name,
				path = GRDP_VIEWSS,
				objid = my_id,
				osnum = OM_Gw_current_OS);
		if (!(status &1))
		{
#ifdef DEBUG
		   di$report_error(sts = status, comment = "untranslate failed in DPviewdyn");
#endif
		   goto wrapup;
		}

		status = di$split(pathname=path_name, name=tmpname);
		if (!(status &1))
		{
#ifdef DEBUG
		   di$report_error(sts = status, comment = "split failed in DPsetinq");
#endif
		   goto wrapup;
		}

		strcpy(new_name,tmpname);
		if (rotation_allowed) 
		   if (speed_control) 
			strcat(new_name,rot_speed_name);
		   else 
			strcat(new_name,rot_name);
		else
		   strcat(new_name,pan_name);

		WLset_window_name( lwin_no, new_name );
		if (ME.IGEgragad->gragad.flags & IS_PERSP) 
			ex$message(msgnumb = GR_I_DynPerspZmCtr);
	}
       
        reading = JNL_playback();
        if (reading)
            done = 1;
	while((( number_of_cycles > 0) || unlimited_cycles) && !done)
	{
	if( func_ptr )
		{
		/* Execute the user's function */
		(*func_ptr)( func_parms, &lwin_no, &(ME.IGEgragad->gragad), &done, &state,
			&number_of_cycles, &unlimited_cycles, &frame_no );
		}
	else	/* Default processing */
		{

		/* 
		 *  see if events happened				
		 */
		old_state=state;
		 
#if defined( X11 )
			NEDPdynevent( lwin_no, &state, &pan_state, pan_point, &but_state );
#else
			DPdynevent( lwin_no, &state, &pan_state, pan_point );
#endif

		switch( state )
		   	{

			/* 
			 * change from pan to rotate state and vice versa	
			 */

			case CHANGE_STATE:
				if( pan_state )
					{
					strcpy( new_name, tmpname );
					strcat( new_name, pan_name );

					WLset_window_name( lwin_no, new_name );

					}
				else
					{

					/* 
					 * change to ZI-ROT-ZO unless it is not a IGEgragad class	
					 */

					if( rotation_allowed )
						{
						strcpy( new_name, tmpname );
						if( speed_control )
							strcat( new_name, rot_speed_name );
						else
							strcat( new_name, rot_name );
			
						WLset_window_name( lwin_no, new_name );
						}
					else
						{
						pan_state = TRUE;
						ex$message( msgnumb = GR_E_RotNotAlwd,
							       buff = error_msg);

#if defined( ENV5 )
						Error_box( 0, error_msg, 3 );
#endif
						}
					}

				state = WAIT;
				break;
		
			case DP_EXIT:

				done = TRUE;
				break;

			default:
				break;

			} /* end of switch (state)  */

		/* check the mouse position if not in the wait state  */

		if( !done && (state != WAIT) )
	   		{
			WLmouse_position( lwin_no, &x, &y, &in_window, &key_buttons );
			if( in_window )
				{
				switch ( state )
					{
					case ZOOM_IN:
						if( pan_state || !speed_control )
						{
							if (ME.IGEgragad->gragad.flags & IS_PERSP)
							{ /* perspective view */
								if (old_state==ZOOM_IN)
								{
									tmp_point[0]=cent_x;
			   						tmp_point[1]=cent_y;
								}	
								else
								{
		   	 	  					tmp_point[0]=x;
			 	  					tmp_point[1]=y;
			  	 				}
			   					tmp_point[2]=ME.IGEgragad->gragad.act_z_screen;
				   				MAptsxform(msg, &one,
								      	(IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
								      	tmp_point,tmp_point);
								status = om$send(mode = OM_e_wrt_object,
									msg = message IGEgragad.DPzoom(&msg1,0,
					             		 		tmp_point,zoom_factor,
										FALSE),
									senderid = my_id,
									targetid = my_id);
							}
							else
							{ /*parallel view*/
							/* adjust view volume so that it zooms in about the dit point */
		 					/* transform dit point to world		*/
							tmp_point[0] = x;
							tmp_point[1] = y;
							tmp_point[2] = ME.IGEgragad->gragad.act_z_screen;

							/* transform dit point to world		*/

							MAptsxform( &msg1,
								    &one,
								    (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
								    tmp_point,
								    tmp_point );

							/* transform point to viewing coordinates	*/

							MAptsxform( &msg1,
								    &one,
								    (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
								    tmp_point,
								    tmp_point);

							/* adjust view volume so that it zooms in about the dit point */

							new_extents[0] = (ME.IGEgragad->gragad.vw_volume[3] -
									  ME.IGEgragad->gragad.vw_volume[0]) *
										(1/zoom_factor);

							new_extents[1] = (ME.IGEgragad->gragad.vw_volume[4] -
									  ME.IGEgragad->gragad.vw_volume[1]) *
										(1/zoom_factor);
	
							ME.IGEgragad->gragad.vw_volume[3] = tmp_point[0] + 
								(ME.IGEgragad->gragad.vw_volume[3] - tmp_point[0]) *
								(1/zoom_factor);

							ME.IGEgragad->gragad.vw_volume[4] = tmp_point[1] + 
								(ME.IGEgragad->gragad.vw_volume[4] - tmp_point[1]) *
								(1/zoom_factor);

							ME.IGEgragad->gragad.vw_volume[0] = ME.IGEgragad->gragad.vw_volume[3] -
								new_extents[0];

							ME.IGEgragad->gragad.vw_volume[1] = ME.IGEgragad->gragad.vw_volume[4] -
								new_extents[1];

							/* recalculate matrices		*/
	
							status = om$send( msg = message IGEgragad.DPcal( &msg1 ),
								     targetid = my_id );
							}
						}
						else
							{
							dframe_increment *= SPEED_FACTOR;
							
							if( dframe_increment > 0.0 && dframe_increment > dframe_limit )
								dframe_increment = dframe_limit;
							else
							if( dframe_increment < 0.0 && dframe_increment < -dframe_limit )
								dframe_increment = -dframe_limit;

							}
						break;
						
		    		case ZOOM_OUT:

				if( pan_state || !speed_control )
				{
					if (ME.IGEgragad->gragad.flags & IS_PERSP)
					{
						if (old_state==ZOOM_OUT)
						{
							tmp_point[0]=cent_x;
			   				tmp_point[1]=cent_y;
						}	
						else
						{
		   	 	  			tmp_point[0]=x;
			 	  			tmp_point[1]=y;
			  	 		}
			   			tmp_point[2]=ME.IGEgragad->gragad.act_z_screen;
				   		MAptsxform(msg, &one,
						      	(IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
						      	tmp_point,tmp_point);
						status = om$send(mode = OM_e_wrt_object,
							msg = message IGEgragad.DPzoom(&msg1,1,
								tmp_point,zoom_factor,FALSE),
							senderid = my_id,
							targetid = my_id);

					}
					else
					{
			   		tmp_point[0] = x;
			   		tmp_point[1] = y;
			   		tmp_point[2] = ME.IGEgragad->gragad.act_z_screen;

 					/* transform dit point to world		*/

			   		MAptsxform(&msg1, &one,
						(IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
						tmp_point,tmp_point);

					/* transform point to viewing coordinates	*/

			   		MAptsxform(&msg1, &one,
				      		(IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
				      		tmp_point,tmp_point);

			   		new_extents[0] = (ME.IGEgragad->gragad.vw_volume[3] -
					     ME.IGEgragad->gragad.vw_volume[0]) *
					     zoom_factor;
			   		new_extents[1] = (ME.IGEgragad->gragad.vw_volume[4] -
					     ME.IGEgragad->gragad.vw_volume[1]) *
					     zoom_factor;

					/* adjust view volume so that it zooms out about the dit point	*/

			   		ME.IGEgragad->gragad.vw_volume[3] = tmp_point[0] + 
					(ME.IGEgragad->gragad.vw_volume[3] - tmp_point[0]) *
				         zoom_factor;

			   		ME.IGEgragad->gragad.vw_volume[4] = tmp_point[1] + 
					(ME.IGEgragad->gragad.vw_volume[4] - tmp_point[1]) *
				         zoom_factor;

			   		ME.IGEgragad->gragad.vw_volume[0] = ME.IGEgragad->gragad.vw_volume[3] -
								new_extents[0];

			   		ME.IGEgragad->gragad.vw_volume[1] = ME.IGEgragad->gragad.vw_volume[4] -
								new_extents[1];

			   		status = om$send(msg = message IGEgragad.DPcal(&msg1),
			 		    targetid = my_id);
			 		}
			 	}
			 	else
				{
					dframe_increment /= SPEED_FACTOR;
					
					if( dframe_increment > 0.0 && dframe_increment < 0.00001 )
						dframe_increment = 0.00001;

					else
					if( dframe_increment < 0.0 && dframe_increment > -0.00001 )
						dframe_increment = -0.00001;

					}
			 		
					break;
		    		case PAN:
					/* calculate new center		*/
			   		tmp_point[0] = cent_x + ((x - pan_point[0]) * pan_factor);
			   		tmp_point[1] = cent_y + ((y - pan_point[1]) * pan_factor);
			   		tmp_point[2] = ME.IGEgragad->gragad.act_z_screen;

			   		MAptsxform(&msg1, &one,
						(IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
				     		tmp_point,tmp_point);

			   		status = om$send(msg = message IGEgragad.DPcenter(&msg1,
						tmp_point,(IGRboolean) FALSE),
			 		    	targetid = my_id);
					break;

		    		case ROTATE:
					/* get rotation vector		*/
					vec[0] = y - cent_y;
					vec[1] = x - cent_x;
					vec[2] = 0.0;

					/* figure out distance from center to cursor position	*/
					tmpdbl = (vec[0] * vec[0]) + (vec[1] * vec[1]);
					tmpdbl = MAsqrt(&msg1,&tmpdbl);

					/* calculate distance based on distance   */
					rad = (tmpdbl / max_extent) * max_rotate_factor;

					/* get rotation matrix from radians    */
					MArotmx(&msg1,vec,&rad,rot_matrix1);

					/*  change rotation to old rotation * new rotation  */
					rotate_flag = LEFT_MULT | ORIGIN_CENTER;
					status = om$send( msg = message IGEgragad.DProtate
					  	(&msg1,rotate_flag,NULL,rot_matrix1,
					  	(IGRboolean) FALSE),
					   	senderid = my_id,
					   	targetid = my_id);
		    		default:
					break;
		 		}
	      		}/* end of if (lwin_no == ...  ) */

		} /* end of if (!done && state) */

	  } /* end of Default processing */

	   if (((state != WAIT) || (start_frame != end_frame)) && !done)
	   {

	      if (db_allowed)
	      {
	         WLenter_db( lwin_no );
	      }	

	      WLhide_cursor( lwin_no, TRUE );

/* if static frame, draw it	*/	
	       
	      if (DPstatic_frame.frame_ptr)
	      {
		  om$send(msg = message IGEgragad.display_frame ( DPstatic_frame.frame_ptr,erase),
			  senderid = my_id,
			  targetid = my_id);
	      }


/* draw dynamic frame  */

/* This if will stop the "flash" of multiple frame view dynamics.  It will not
   erase the screen if it is the exact same image i.e.  waiting or speeding up
   or slowing down and same frame.  The motion speed will be a little faster 
   when sitting due to erase time.
   (start_frame!=end_frame) = multiple frame view dynamics
   (old_frame==frame_no)    = second time in a row trying to draw this frame 
   !(db_allowed)= not double buffered
   (state==WAIT)            = no button press
   ( ((state==ZOOM_OUT)||(state==ZOOM_IN)) && (!pan_state))
   			    = changing speed (rot mode so zoom in or out is speed up or down)
   if (multiple frame view dynamics) and (going to draw the same frame) 
   and (not double buffered) and [(waiting) or  (changing speed)]
   then draw
   else draw and erase
*/
         
	      if (!( (start_frame!=end_frame) && (old_frame==frame_no) &&
	             !(db_allowed) && 
	           ( (state==WAIT) ||( ((state==ZOOM_OUT)||(state==ZOOM_IN)) 
	              && (!pan_state)) )) )  
	      { 
	      	old_frame=frame_no;
		om$send(msg = message IGEgragad.display_frame ( 
			DPdynamic_frames[frame_no].frame_ptr,erase_dyn_frame),
			  senderid = my_id,
			  targetid = my_id);
	      }
	      else
	      {
		om$send(msg = message IGEgragad.display_frame ( 
			DPdynamic_frames[frame_no].frame_ptr,FALSE),
			  senderid = my_id,
			  targetid = my_id);
	      }
			  
	      WLshow_cursor( lwin_no );
	      WLflush( lwin_no );

	      if( db_allowed )
	      {
	         WLexit_db( lwin_no );
	      }

		if( start_frame != end_frame )
			{

			/* update current display frame		*/

			DPcurrent_display_frame = frame_no;

			if( direction == DPOSCILATING )
				{
 				if( dframe_increment > -1.0 && dframe_increment < 1.0 )
					dframe_no += 1.0 / ( (double)( (int)(1.0/dframe_increment) ) );
				else
					dframe_no += dframe_increment;
					
				frame_no = (IGRint)dframe_no;

				/* check to see if the direction needs to be changed  */

				if( dframe_increment > 0.0 )
					{
					/* changed >= to > so that will stay on end frame
					   until it would normaly advance frame_no (if
					   advancing slower than 1 a cycle) */
					if( frame_no > end_frame )
						{
						dframe_increment = -dframe_increment;
						frame_no = end_frame - (frame_no - end_frame);
						dframe_no = (double)frame_no+1+dframe_increment;
						}
					}
				else
					{
					/* did NOT change <= to < because dframe_no starts
					   over at whole number and thus is correct */
					if( frame_no <= start_frame )
						{
						dframe_increment = -dframe_increment;
						number_of_cycles--;
						frame_no = start_frame + (start_frame - frame_no);
						dframe_no = (double)frame_no;
						}
					}
				}
			else
				{

				/* 
				 *  check to see if the end frame has been reached and if 
				 *  so change frame no to the start frame	
				 */

 				if( dframe_increment > -1.0 && dframe_increment < 1.0 )
					dframe_no += 1.0 / ( (double)( (int)(1.0/dframe_increment) ) );
				else
					dframe_no += dframe_increment;

				frame_no = (IGRint)dframe_no;

				/* to reach end frame, changed from >= to > and set frame
				   to 1 less than difference because 1 after end_frame
				   should be start frame. */
				if( frame_no > end_frame )
					{
					frame_no = start_frame + (frame_no - end_frame -1);
					dframe_no = (double)frame_no;
					number_of_cycles--;
					}
				}
			}
		else
			{
			number_of_cycles--;
			}
		} /* end of if ((state != WAIT) || (start_frame != end_frame)) */
	} /* end of while (number_of_cycles ..... )  */

	if( func_ptr == NULL )
	{
		WLset_window_name( lwin_no, tmpname );
	}

wrapup:
	if (!(*msg & 1))
	{
	   status = FALSE;
	}

	return(status);

}

/************************************************************************/
/*									*/
/*	method - dynamics						*/
/*									*/
/*									*/
/************************************************************************/

method dynamics( IGRlong *msg; IGRdouble zoom_factor; IGRdouble pan_factor;
		 IGRdouble max_rotate_factor; IGRdouble stroke_scale_factor)


{	

   IGRint 	status;
   IGRint	buf_status;
   GRobjid	frame_id;
   GRspacenum	frame_osnum;


    	status = OM_S_SUCCESS;
	
	*msg = MSSUCC;


	status = dp$reset_frames(msg = msg);

	
	status = dp$start_frame(msg = msg,
			apparent_stroke_scale = stroke_scale_factor,
			frame_no = 0,
			gragad_id = my_id,
			gragad_osnum = OM_Gw_current_OS,
			frame_id = &frame_id,
			frame_osnum = &frame_osnum);

	if (!status)
	{
#ifdef DEBUG
	   printf("Error in start_frame\n");
#endif
	   goto wrapup;
	}

	ex$message( msgnumb = GR_I_LdDyn);


	dp$gen_update(	msg = msg,
			erase = FALSE,
			objid = frame_id,
			osnum = frame_osnum);


	status = dp$end_frame(	msg = msg,
				disp_buf_status = &buf_status,
				frame_id = frame_id,
				frame_osnum = frame_osnum);

	if (!status)
	{
#ifdef DEBUG
	   printf("Error in end_frame\n");
#endif
	   goto wrapup;
	}

	if (buf_status)
	{
	   ex$message(msgnumb = GR_I_NotAllEleLd);

	}
	else
	{
	   ex$message(msgnumb = GR_I_DynLd);
	}




	status = dp$display_frames(	msg = msg,
					number_of_cycles = DPUNLIMITED_CYCLES,
					zoom_factor = zoom_factor,
					pan_factor = pan_factor,
					max_rotate_factor = max_rotate_factor,
					gragad_id = my_id,
					gragad_osnum = OM_Gw_current_OS);

			
	if (!status)
	{
#ifdef DEBUG
	   printf("Error in display_frames\n");
#endif
	}
/*
 * Modified 02/07/92 : rlw
 *
 * The following sections of code deal with support of journaling
 * for view dynamics.
 *
 * Modified 03/12/92 : rlw
 *
 * Changed to accomodate journaling API on the Sun
 *
 */
/*
 * If we are playing back a journal file then read the final
 * window information from the journal file and effect the changes
 */
 {
  int      reading;

  reading = JNL_playback();
  if (reading)
   {
    int        event, type, num_bytes, buffer_size_ok;
    enum       GRdpmode mode = GRbd;
    IGRboolean update_all = TRUE;
    IGRdouble  *ptr, contig_array[41];
    struct     DPgra_gad *g;
#if defined( X11 )
    XEvent     xevent;

    JNL_echo_input(sizeof(XEvent), (char *)(&xevent));
    event = xevent.type;
    type = xevent.xkey.serial;
    num_bytes = xevent.xkey.x;
#elif defined( ENV5 )
    JNL_echo_input(4, (char *)(&event) );
    JNL_echo_input(4, (char *)(&type) );
    JNL_echo_input(4, (char *)(&num_bytes) );
#endif
    buffer_size_ok = (num_bytes == (41 * sizeof(IGRdouble)));
    assert((event == JNL_INFO_EVENT) && (type == JNL_CHAR) && buffer_size_ok);
    ptr = contig_array;
    JNL_echo_input(num_bytes, (char *)ptr);
    g = &ME.IGEgragad->gragad;
    OM_BLOCK_MOVE(ptr, g->origin, 3 * sizeof(IGRdouble));
    ptr += 3;
    OM_BLOCK_MOVE(ptr, g->rotation, 16 * sizeof(IGRdouble));
    ptr += 16;
    OM_BLOCK_MOVE(ptr, g->vw_volume, 6 * sizeof(IGRdouble));
    ptr += 6;
    OM_BLOCK_MOVE(ptr, g->wld_to_viewport, 16 * sizeof(IGRdouble));
    status = om$send(
      msg = message IGEgragad.DPcal(msg),
      targetid = my_id);
    if ((1 & status) && (1 & *msg))
     status = om$send(
       msg = message IGEgragad.DPgen_update(
        msg, NULL, &update_all, mode, TRUE),
       targetid = my_id);
   }
 }

/*
 * If we are creating a journal file then write the necessary
 * information to the journal
 */
 {
  int      journaling;

  journaling = JNL_journal();
  if (journaling)
   {
    int        type, num_bytes;
    IGRdouble  *ptr, contig_array[41];
    struct     DPgra_gad *g;

    g = &ME.IGEgragad->gragad;
    ptr = contig_array;
    OM_BLOCK_MOVE(g->origin, ptr, 3 * sizeof(IGRdouble));
    ptr += 3;
    OM_BLOCK_MOVE(g->rotation, ptr, 16 * sizeof(IGRdouble));
    ptr += 16;
    OM_BLOCK_MOVE(g->vw_volume, ptr, 6 * sizeof(IGRdouble));
    ptr += 6;
    OM_BLOCK_MOVE(g->wld_to_viewport, ptr, 16 * sizeof(IGRdouble));
    num_bytes = 41 * sizeof(IGRdouble);
    type = JNL_CHAR;
    JNL_record_info_event(type, num_bytes, (char *)contig_array);
   }
 }


wrapup:
    	return ( status );
}

/************************************************************************/
/*									*/
/*	method - start_frame						*/
/*									*/
/*									*/
/************************************************************************/


method  start_frame(IGRlong *msg; IGRint load_frame;
		    IGRdouble **buffer; IGRint *buf_size;
		    IGRint *gpipe_fb; IGRdouble **gpipe_fb_buf;
		    IGRint *gpipe_fb_size; GRobjid *frame_id;
		    GRspacenum *frame_osnum)
{


   IGRint	status = TRUE;

	
	*msg = MSSUCC;

	if (load_frame)
	{
	   *buf_size = DPframe_block_size;

	}

	*gpipe_fb = TRUE;
	*gpipe_fb_buf = (IGRdouble *) om$malloc( size = (DPFB_BUF_SIZE * 
						sizeof(IGRdouble)));
	
	if (!*gpipe_fb_buf)
	{
	   *msg = DPNODYNMEM;
	   goto wrapup;
	}

	*gpipe_fb_size = DPFB_BUF_SIZE * sizeof(IGRdouble);




	*frame_osnum = OM_Gw_TransOSnum_0;

	status = om$construct_and_copy(	objid = my_id,
					osnum = *frame_osnum,
					p_objid = frame_id);

	if (!(1 & status))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	status = om$change_class(	osnum = OM_Gw_TransOSnum_0,
					objid = *frame_id,
					classname = "GRviewdyn");

	if (!(1 & status))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

wrapup:

	if (!(*msg & 1))
	{
	   status = FALSE;
	}

	return(status);
}
	   
/************************************************************************/
/*									*/
/*	function - DPclear_buf_full					*/
/*									*/
/*									*/
/************************************************************************/

void	DPclear_buf_full()
{
	DPdyn_buffer_full = FALSE;
	DPapp_fb_buffer_full = FALSE;
}

/************************************************************************/
/*									*/
/*	function - DPdisplay_frames					*/
/*									*/
/*									*/
/************************************************************************/


IGRint	DPdisplay_frames(IGRlong		*msg,
			IGRint		start_frame,
			IGRint		relative_frame,
			IGRint		number_of_frames,
			IGRint		number_of_cycles,
			IGRint		direction,
			IGRint		erase,
			IGRdouble	zoom_factor,
			IGRdouble	pan_factor,
			IGRdouble	max_rotate_factor,
			GRobjid		gragad_id,
			GRspacenum	gragad_osnum,
			IGRint		(*func_ptr)(),
			IGRchar		*func_parms )

	{
	IGRint	status;

	status = om$send( msg = message IGEgragad.display_frames( msg,
								  start_frame,
								  relative_frame,
								  number_of_frames,
								  number_of_cycles,
								  direction,
								  erase,
								  TRUE,
								  TRUE,
								  zoom_factor,
								  pan_factor,
								  max_rotate_factor,
								  func_ptr,
								  func_parms ),
		     senderid = NULL_OBJID,
		     targetid = gragad_id,
		     targetos = gragad_osnum);

	return(status);
	}

/************************************************************************/
/*									*/
/*	fuction - DPfree_frame						*/
/*									*/
/*									*/
/************************************************************************/

static void DPfree_frame(IGRdouble *frame_ptr)

{
    IGRdouble	*block_ptr;
    IGRdouble	**next_block_ptr;

	block_ptr = frame_ptr;
	next_block_ptr =  (IGRdouble **) (frame_ptr + 1);

	while (*next_block_ptr)
	{
	    next_block_ptr = (IGRdouble **) *next_block_ptr;
	    om$dealloc(ptr = block_ptr);
	    block_ptr = (IGRdouble *) next_block_ptr;
	}

	om$dealloc(ptr = block_ptr);
	   	    
}

/************************************************************************/
/*									*/
/*	function - DPdyn_set_up_buf					*/
/*									*/
/*									*/
/************************************************************************/


IGRint	DPdyn_set_up_buf(msg,static_frame,frame_no,buffer,buf_size)

   IGRlong 	*msg;
   IGRint	static_frame;
   IGRint	*frame_no;
   IGRdouble	*buffer;
   IGRint	buf_size;
{

   IGRint	i;
   IGRint	status = TRUE;

/* if static frame is specified, allocate memory	*/

	if (static_frame)
	{
	   if (DPstatic_frame.frame_ptr)
	   {
	      om$dealloc(ptr = DPstatic_frame.frame_ptr);
	   }


	   if (!buffer)
	   {
	   
	      DPstatic_frame.frame_ptr = (IGRdouble *) om$malloc(size = buf_size);
	      if (!DPstatic_frame.frame_ptr)
	      {
	         *msg = DPNODYNMEM;
	         goto wrapup;
	      }
	   }
	   else
	   {
	      DPstatic_frame.frame_ptr = buffer;
	   }

	   *(IGRint *) DPstatic_frame.frame_ptr = DPWIREFRAME_FRAME;

  /* set pointer to next block to 0				*/

	   *(IGRint *) (DPstatic_frame.frame_ptr +1) = 0;

  /* set block size (1 int after block pointer) 		*/

	   *((IGRint *) DPstatic_frame.frame_ptr + 3) = buf_size;
	   DPstatic_frame.block_size = buf_size;
	}
	else
	{
	   if (*frame_no != DPADD_TO_END)
	   {

/* make sure frame_no is replacing a frame of is the in sequence  */

	      if (*frame_no > DPnum_of_frames)
	      {
		 *msg = DPINVFRAMENO;
		 goto wrapup;
	      }
	      else
	      {
		 if (*frame_no == DPnum_of_frames)
		 {
		     DPnum_of_frames++;
		 }
	      }
	      
	   }
	   else
	   {
	      *frame_no = DPnum_of_frames++;
	   }

/* if no memory has been allocate for the frame pointers, allocate the memory */

	   if (!DPdynamic_frames)
	   {
	      DPdynamic_frames = (struct DPframe *) om$calloc(size =DPFRAME_PTRS_BLOCK_SIZE * 
						sizeof(struct DPframe));

	      if (!DPdynamic_frames)
	      {
		 *msg = DPNODYNMEM;
		 goto wrapup;
	      }

/* keep track of how many frame pointers have been allocated  */

	      DPnum_of_frame_ptrs = DPFRAME_PTRS_BLOCK_SIZE;
	   }

/* make sure frame number is not greater than number of frame pointers allocated */
/* if it is greater, allocate more frame pointers  	*/

	   if (*frame_no >= DPnum_of_frame_ptrs)
	   {
	      DPdynamic_frames = (struct DPframe *) om$realloc(
						ptr = (char *)DPdynamic_frames,
						size = (DPnum_of_frame_ptrs +
						DPFRAME_PTRS_BLOCK_SIZE) *
						sizeof(struct DPframe));
	      if (!DPdynamic_frames)
	      {
	         *msg = DPNODYNMEM;
		 goto wrapup;
	      }

	      for (i = DPnum_of_frame_ptrs; i < (DPnum_of_frame_ptrs + DPFRAME_PTRS_BLOCK_SIZE);
								i++)
	      {
		 DPdynamic_frames[i].frame_ptr = 0;
	      }


	      DPnum_of_frame_ptrs += DPFRAME_PTRS_BLOCK_SIZE;
	   }

/*	
	   if (DPdynamic_frames[*frame_no].frame_ptr)
	   {
	      om$dealloc(ptr = DPdynamic_frames[*frame_no].frame_ptr);
	   }
*/

/* allocate memory for the frame	*/

	   if (!buffer)
	   {
	      if (!DPdynamic_frames[*frame_no].frame_ptr)
	      {
	          DPdynamic_frames[*frame_no].frame_ptr = (IGRdouble *) om$malloc(size = buf_size);

	          if (!DPdynamic_frames[*frame_no].frame_ptr)
	          {
	              *msg = DPNODYNMEM;
	              goto wrapup;
	          }
	          *(IGRint *) DPdynamic_frames[*frame_no].frame_ptr = DPWIREFRAME_FRAME;

  /* set pointer to next block to 0				*/

		  *(IGRint *) (DPdynamic_frames[*frame_no].frame_ptr +1) = 0;

  /* set block size (1 int after block pointer) 		*/

	   	  *((IGRint *) DPdynamic_frames[*frame_no].frame_ptr + 3) = buf_size;

		  DPdynamic_frames[*frame_no].block_size = buf_size;

	       }
	       else
	       {
		  if (buf_size > DPdynamic_frames[*frame_no].block_size)
		  {
		      DPfree_frame(DPdynamic_frames[*frame_no].frame_ptr);
		      DPdynamic_frames[*frame_no].frame_ptr = (IGRdouble *) om$malloc(size = buf_size);

		      if (!DPdynamic_frames[*frame_no].frame_ptr)
		      {
			  *msg = DPNODYNMEM;
			  goto wrapup;
		      }
		      *(IGRint *) DPdynamic_frames[*frame_no].frame_ptr = DPWIREFRAME_FRAME;

  /* set pointer to next block to 0				*/

		      *(IGRint *) (DPdynamic_frames[*frame_no].frame_ptr +1) = 0;

  /* set block size (1 int after block pointer) 		*/

	   	      *((IGRint *) DPdynamic_frames[*frame_no].frame_ptr + 3) = buf_size;
		      DPdynamic_frames[*frame_no].block_size = buf_size;
		  }	      
	       }

	   }
	   else
	   {
		if (DPdynamic_frames[*frame_no].frame_ptr)
		{
		    DPfree_frame(DPdynamic_frames[*frame_no].frame_ptr);
		}
		DPdynamic_frames[*frame_no].frame_ptr = buffer;
		*(IGRint *) DPdynamic_frames[*frame_no].frame_ptr = DPWIREFRAME_FRAME;

  /* set pointer to next block to 0				*/

		*(IGRint *) (DPdynamic_frames[*frame_no].frame_ptr +1) = 0;

  /* set block size (1 int after block pointer) 		*/

	   	*((IGRint *) DPdynamic_frames[*frame_no].frame_ptr + 3) = buf_size;
		DPdynamic_frames[*frame_no].block_size = buf_size;

	   }
	}
	DPframe_block_size = buf_size;
wrapup:

	if (!(1 & *msg))
	{
	   status = FALSE;
	}

	return(status);
}


/************************************************************************/
/*									*/
/*	function - DPend_frame						*/
/*									*/
/*									*/
/************************************************************************/


IGRint	DPend_frame(	IGRlong		*msg,
			IGRint		*buffer_size,
			IGRint		*fb_buf_status,
			IGRint		*disp_buf_status,
			GRobjid		frame_id,
			GRspacenum	frame_osnum )
{


   IGRint	disp_buf_size;
   IGRint	app_buf_size;
   IGRint	status = TRUE;
 
	*msg = MSSUCC;

	if (!DPframe_active)
	{
	   *msg = DPFRAMENOTACT;
	   goto wrapup;
	}


/* check to see that frame_id and frame_osnum are valid  */
/* reset view */


	status = om$send( msg = message GRviewdyn.GRviewdyn_reset(msg),
			  senderid = NULL_OBJID,
			  targetid = frame_id,
			  targetos = frame_osnum);

	if (!(1 & status))
	{
	   status = FALSE;
	   goto wrapup;
	}


	if (DPgpipe_fb_buf)
	{
	   om$dealloc(ptr = DPgpipe_fb_buf);
	}

	if (DPbeg_app_buf)
	{

	   *(IGRint *) DPapp_fb_buf_ptr = 0;

	   DPapp_fb_buf_ptr++;

	   app_buf_size = 	(IGRchar *) DPapp_fb_buf_ptr - 
				(IGRchar *) DPbeg_app_buf;

	   if (app_buf_size <= 8)
	   {
	      *msg = DPFRAMEMPTY;
	      goto wrapup;
	   }

	   if (buffer_size)
	   {
	      *buffer_size = app_buf_size;
	   }

	   if (fb_buf_status)
	   {
	      *fb_buf_status = DPinq_app_buf_full();
	   }

	}

	if (DPdyn_buf_ptr)
	{
	   if (disp_buf_status)
	   {
	      *disp_buf_status = DPinq_dyn_buf_full();
	   }

	   *(IGRint *) DPdyn_buf_ptr = 0;

	   DPdyn_buf_ptr++;

	   disp_buf_size = (IGRchar *) DPdyn_buf_ptr -
			   (IGRchar *) *DPactive_frame;

	   if ( ((IGRchar *) DPdyn_buf_ptr - 16) == ((IGRchar * ) *DPactive_frame))
	   {
	      *msg = DPFRAMEMPTY;
	      goto wrapup;
	   }
/*
	   *DPactive_frame = om$realloc(ptr = *DPactive_frame,
					size = disp_buf_size);

	   if (!*DPactive_frame)
	   {
	      *msg = DPNODYNMEM;
	      goto wrapup;
	   }
*/


	}

	DPactive_frame = NULL;
	DPdyn_buf_ptr = NULL;
	DPend_dyn_buf = NULL;
	DPbeg_app_buf = NULL;
	DPapp_fb_buf_ptr = NULL;	
	DPend_app_fb_buf = NULL;
	DPgpipe_fb_buf = NULL;
	   
wrapup:
	DPframe_active = FALSE;

	if (!(1 & *msg))
	{
	   status = FALSE;
	}

	return(status);
}


/************************************************************************/
/*									*/
/*	function - DPget_frame_block					*/
/*									*/
/*									*/
/************************************************************************/


IGRint	DPget_frame_block(size)

   IGRint	size;

{

    IGRdouble 	*new_ptr;
    IGRdouble 	*next_block_ptr;
    IGRdouble 	*save_block_ptr;
    IGRint	malloc_size;

	*(IGRint *) DPdyn_buf_ptr = DPFRAMELINK;

  	if (size)
	{
   /* make sure malloc size of a multiple of double word          */
	    malloc_size = size & 0xfffffff8;
	}
	else
	{
	    malloc_size = DPframe_block_size;
	}

	if (!*DPnext_block)
	{
		 
	    new_ptr = (IGRdouble *) om$malloc(size = malloc_size);

	    if (new_ptr)
	    {

  /* set pointer to next block in previous block	*/
	        *DPnext_block = new_ptr;

  /* set buffer pointer to new block			*/

		DPdyn_buf_ptr = (IGRdouble *) new_ptr;

  /* set pointer to next block to NULL (no next block)	*/
		*(IGRint *) DPdyn_buf_ptr = 0;

  /* put size of block in 2nd word of block		*/

		*(IGRint *) ((IGRint *) DPdyn_buf_ptr + 1)  = malloc_size;

	    }
	    else
	    {

  /* no more malloced memory				*/

 	        malloc_size = 0;
		goto wrapup;
	    }
	}
	else
	{ 

  /* already next block			*/

	    next_block_ptr = *DPnext_block;

  /* see if next block is at least as big as size asked	*/
 
 	    if (malloc_size > (*((IGRint *) next_block_ptr + 1)))
	    {
  /* if not big enough, replace next block with bigger block  */

  /* save the pointer to the block after the block being replaced	*/

		save_block_ptr = (IGRdouble *) *(IGRint *) next_block_ptr;

  /* deallocate smaller block				*/

		om$dealloc(ptr = next_block_ptr);

  /* allocate new block					*/

		new_ptr = (IGRdouble *) om$malloc(size = malloc_size);

		if (new_ptr)
		{
  /* change pointer to next block to point to the new block	*/

	            *DPnext_block = new_ptr;

  /* set buffer pointer to new block				*/

		    DPdyn_buf_ptr = new_ptr;

  /* put pointer to block after the new block in the new block   */

		    *(IGRdouble **) DPdyn_buf_ptr = save_block_ptr;

  /* put size of block in 2nd word of block		*/

		    *((IGRint *) DPdyn_buf_ptr + 1)  = malloc_size;

		}
		else
		{
  /* no more malloced memory				*/

 	            malloc_size = 0;
		    goto wrapup;
		}
	    }
	    else
	    {

  /* set pointer to buffer to pointer to next block		*/

		DPdyn_buf_ptr = *DPnext_block;

  /* return size of block					*/

 	        malloc_size  =  (*((IGRint *) DPdyn_buf_ptr + 1));
	    }

	}

	DPend_dyn_buf = (IGRdouble *)((IGRchar *) DPdyn_buf_ptr + malloc_size);
	DPnext_block = (IGRdouble **)DPdyn_buf_ptr++;	

wrapup:
	return(malloc_size);
}

/************************************************************************/
/*									*/
/*	function - DPinq_app_buf_full					*/
/*									*/
/*									*/
/************************************************************************/

IGRint	DPinq_app_buf_full()
{
	return(DPapp_fb_buffer_full);
}

/************************************************************************/
/*									*/
/*	fuction - DPinq_buf_ptrs					*/
/*									*/
/*									*/
/************************************************************************/

IGRint DPinq_buf_ptrs(	cur_disp_ptr,end_disp_ptr,cur_app_fb_ptr,end_app_fb_ptr)

IGRdouble	***cur_disp_ptr;
IGRdouble	**end_disp_ptr;
IGRdouble	***cur_app_fb_ptr;
IGRdouble	**end_app_fb_ptr;
{

	*cur_disp_ptr = &DPdyn_buf_ptr;
	*end_disp_ptr = DPend_dyn_buf;
	
	*cur_app_fb_ptr = &DPapp_fb_buf_ptr;
	*end_app_fb_ptr = DPend_app_fb_buf;

	return(1);
}
		

/************************************************************************/
/*									*/
/*	functio - DPinq_dyn_buffers					*/
/*									*/
/*									*/
/************************************************************************/

IGRint	DPinq_dyn_buffers(dyn_buf_ptr,end_buf,fb_buf)

   IGRdouble	***dyn_buf_ptr;
   IGRdouble	***end_buf;
   IGRdouble	***fb_buf;
{
	*dyn_buf_ptr = &DPdyn_buf_ptr;
	*end_buf = &DPend_dyn_buf;
	*fb_buf	 = &DPgpipe_fb_buf;
	return(1);
}

/************************************************************************/
/*									*/
/*	function - DPinq_dyn_buf_full					*/
/*									*/
/*									*/
/************************************************************************/

		
IGRint	DPinq_dyn_buf_full()
{
	return(DPdyn_buffer_full);
}

/************************************************************************/
/*									*/
/*	function - DPinq_gpipe_fb_buf					*/
/*									*/
/*									*/
/************************************************************************/

IGRdouble	*DPinq_gpipe_fb_buf()
{
	return(DPgpipe_fb_buf);
}		



/************************************************************************/
/*									*/
/*	function - DPload_frame						*/
/*									*/
/*									*/
/************************************************************************/


IGRint	DPload_frame(	msg,static_frame,frame_no,buffer,buf_size)

   IGRlong	*msg;
   IGRint	static_frame;
   IGRint	frame_no;
   IGRdouble	*buffer;
   IGRint	buf_size;
{

   IGRint	status = TRUE;

	*msg = MSSUCC;


/*  cannot load new frame if frame is already active  */

	if (DPframe_active)
	{
	   *msg = DPFRAMEACT;
	   goto wrapup;
	}


	if (!DPdyn_set_up_buf(msg,static_frame,&frame_no,(IGRdouble *)NULL,buf_size))
	{
	   goto wrapup;
	}

	if (static_frame)
	{
	   OM_BLOCK_MOVE(buffer,DPstatic_frame.frame_ptr,buf_size );
	}
   	else
	{
	   OM_BLOCK_MOVE(buffer,DPdynamic_frames[frame_no].frame_ptr,buf_size );
	}


wrapup:

	if (!(1 & *msg))
	{
	   status = FALSE;
	}

	return(status);
}

/************************************************************************/
/*									*/
/*	fuction - DPpack_buffer						*/
/*									*/
/*									*/
/************************************************************************/

IGRint DPpack_buffer(type,dis_attr)

   IGRint		type;
   struct IGRdisplay	*dis_attr;


{
     IGRint	status = TRUE;	/*  return status		*/
     IGRint	*total_wtf;	/*  total words to follow	*/
     IGRint	*wtf_ptr;	/*  words to follow pointer	*/
     IGRint	curve;		/*  TRUE if curve is in buffer	*/
     IGRint	polygon;	/*  TRUE if polygon is in buffer*/
     IGRint	done;		/*  done with feedback buffer	*/
     IGRint	line_wtf;	/*  line wtf for feedback buffer*/
     IGRint	bsp_curve_wtf;  /*  bspline curve wtf for 	*/
				/*  feedback buffer		*/
     IGRint	bsp_surf_wtf;	/*  bspline surface wtf for 	*/
				/*  feedback buffer		*/
     IGRint	save_wtf;	/*  temp storage for wtf	*/
     IGRint	num_pts;	/*  number of points 		*/
     IGRint	alldone = FALSE;/*  TRUE if finished		*/
     IGRint	vi_flag;	/*  TRUE if element is a view	*/
				/*  independent element		*/
     IGRint	vi_type;	/*  which type of view 		*/
				/*  independence; ROTATION, 	*/
				/*  SCALE, ROTATION_AND_SCALE	*/
     IGRint	frame_block_size;/* size of block to allocate   */
     IGRdouble	vi_point[3];	/*  point obout which element	*/
				/*  is view independent		*/
     IGRdouble	*fb_buf_ptr;	/*  pointer into the feedback	*/
				/*  buffer			*/
     IGRdouble  **dyn_buf_ptr;	/*  points to current buffer.	*/
				/*  either the display buffer	*/
				/*  or the application specified*/
				/*  buffer			*/
     IGRdouble	**end_dyn_buf;	/*  pointd to the end of the 	*/
				/*  the current buffer.  either	*/
				/*  the display buffer of the 	*/
				/*  application buffer		*/
     IGRint 	*buffer_full;	/*  either points the the 	*/
				/*  display or applicatino 	*/
				/*  buffer full variable	*/
     IGRint	frame_buffer;	/*  TRUE if a display frame	*/
				/*  FALSE an application buffer	*/
     IGRdouble  *sav_dyn_ptr;	/*  addres of dynamic buffer	*/


	frame_buffer = TRUE;

	while (!alldone)
	{
	   if (frame_buffer)
	   {
	      dyn_buf_ptr = &DPdyn_buf_ptr;
	      end_dyn_buf = &DPend_dyn_buf;
	      buffer_full = &DPdyn_buffer_full;
	      frame_buffer = FALSE;
	   }
	   else
	   {
	      dyn_buf_ptr = &DPapp_fb_buf_ptr;
	      end_dyn_buf = &DPend_app_fb_buf;
	      buffer_full = &DPapp_fb_buffer_full;
	      alldone = TRUE;
	   }


	   if (!*dyn_buf_ptr)
	   {
	      continue;	
	   }

	   if (*buffer_full)
	   {
	      continue;
	   }


	   fb_buf_ptr = DPgpipe_fb_buf;
	   sav_dyn_ptr = *dyn_buf_ptr;

	   if ( ( *end_dyn_buf - *dyn_buf_ptr) < 9)
	   {
	      if (alldone)
	      {
	          *buffer_full = TRUE;
	          continue;
	      }
	      else
	      {
		  frame_buffer = TRUE;
		  status = DPget_frame_block(0);
		  if (!status)
		  {
		     alldone = TRUE;
		  }		
	      }
	   }

/*  put type in buffer  */

	   *(IGRint *) *dyn_buf_ptr = type;
	   total_wtf = ((IGRint *) *dyn_buf_ptr + 1);

	   (*dyn_buf_ptr)++;

	   DPinq_vi_info(&vi_flag,&vi_type,vi_point);

	   if (vi_flag)
	   {
	      *(IGRint *) *dyn_buf_ptr = DPVIEW_IND;
	      *((IGRint *) *dyn_buf_ptr + 1) = vi_type;

	      (*dyn_buf_ptr)++;

	      OM_BLOCK_MOVE(vi_point,*dyn_buf_ptr,
		sizeof(IGRdouble) * 3);

	      *dyn_buf_ptr += 3;
	   }
	   else
	   {
	      *(IGRint *) *dyn_buf_ptr = 0;;
	   
	      (*dyn_buf_ptr)++;
	   }

	   wtf_ptr = NULL;
	   done = FALSE;

	   switch(type)
	   {

/*  Process polylines, point sets, curves, surfaces, and text		*/

	   case IGRBC:
	   case IGRQS:
	   case IGRLB:
	   case IGRPY:
	   case IGRPS:
 

/* put polygon display attributes in buffer  */

		*(struct IGRdisplay *) *dyn_buf_ptr = *dis_attr;

		if ((type == IGRBC) || (type == IGRQS))
		{
		    ((struct IGRdisplay *) *dyn_buf_ptr)->style = 4;
		}
		

		curve = FALSE;
		polygon = FALSE;

		while (!done)
		{
	   	   switch (*(WLuint16 *) fb_buf_ptr)
		   {

			case DL_FB_BSS_LXYZ:

			   curve = TRUE;

/*  fill in number of polygon wtf					*/
			   if (wtf_ptr)
			   {
			       *wtf_ptr = (((IGRint) *dyn_buf_ptr - (IGRint) wtf_ptr) / 4) - 1;
			   }


			   *(struct IGRdisplay *) *dyn_buf_ptr = *dis_attr;
			   (*dyn_buf_ptr)++;

/*  save curve wft pointer to be filled in after all curves have been	*/
/*  processed								*/

			   wtf_ptr = (IGRint *) (*dyn_buf_ptr)++;


			   bsp_surf_wtf = *((IGRint *) fb_buf_ptr + 1);
			   fb_buf_ptr++;

			   if ( (IGRint) (bsp_surf_wtf + 1) > (IGRint) (*end_dyn_buf -  *dyn_buf_ptr))
			   {
			      *dyn_buf_ptr = sav_dyn_ptr;
			      if (alldone)
			      {
				  *buffer_full = TRUE;
			      }
			      else
			      {
				  frame_buffer = TRUE;
				  if (((bsp_surf_wtf + 1) * sizeof(IGRdouble)) > DPframe_block_size)
				  {
				      frame_block_size = (bsp_surf_wtf + 100) * sizeof(IGRdouble);
				  }
				  else
				  {
				      frame_block_size = 0;
				  }

			          status = DPget_frame_block(frame_block_size);
				  if (!status)
				  {
				     alldone = TRUE;
				  }
			      }
			      done = TRUE;
			      continue;
			   }

			
			   while( bsp_surf_wtf > 0)
			   {
			      bsp_curve_wtf = *((IGRint *) fb_buf_ptr + 1);
			      fb_buf_ptr++;

			      save_wtf = bsp_curve_wtf;		
			      while( bsp_curve_wtf > 0)
			      {
			         fb_buf_ptr++;

			         line_wtf = *((IGRint *) fb_buf_ptr + 1);
	
			         num_pts = line_wtf / 3;
			         fb_buf_ptr ++;

/*  put number of vectors in buffer and copy vectors into buffer 	*/

			         *(IGRint *) *dyn_buf_ptr = num_pts;
			         (*dyn_buf_ptr)++;
			         OM_BLOCK_MOVE(fb_buf_ptr,*dyn_buf_ptr,
				       sizeof(IGRdouble) * 3 * num_pts);
			         *dyn_buf_ptr += (3 * num_pts);

			         fb_buf_ptr += line_wtf;
			         bsp_curve_wtf -= (line_wtf + 2);
			      }
			   
			      bsp_surf_wtf -= (save_wtf + 1);
			   }
	
			   break;

			case DL_FB_BSC_LXYZ:

			   curve = TRUE;


/*  fill in number of polygon wtf					*/
			   if (wtf_ptr)
			   {
			       *wtf_ptr = (((IGRint) *dyn_buf_ptr - (IGRint) wtf_ptr) / 4) - 1;
			   }


/*  fill in curve display attributes					*/

			   *(struct IGRdisplay *) *dyn_buf_ptr = *dis_attr;
			   (*dyn_buf_ptr)++;

/*  save curve wtf pointer to be filled in after all curves have been	*/
/*  processed								*/

			   wtf_ptr = (IGRint *) (*dyn_buf_ptr)++;


			   bsp_curve_wtf = *((IGRint *) fb_buf_ptr + 1);
			   fb_buf_ptr++;
			
			   if ( (bsp_curve_wtf + 1) > (IGRint)(*end_dyn_buf -  *dyn_buf_ptr))
			   {
			      *dyn_buf_ptr = sav_dyn_ptr;
			      if (alldone)
			      {
				  *buffer_full = TRUE;
			      }
			      else
			      {
				  frame_buffer = TRUE;
				  if (((bsp_curve_wtf + 1) * sizeof(IGRdouble)) > DPframe_block_size)
				  {
				      frame_block_size = (bsp_curve_wtf + 100) * sizeof(IGRdouble);
				  }
				  else
				  {
				      frame_block_size = 0;
				  }

			          status = DPget_frame_block(frame_block_size);

				  if (!status)
				  {
				     alldone = TRUE;
				  }
			      }
			      done = TRUE;
			      continue;
			   }


			   while( bsp_curve_wtf > 0)
			   {
			      fb_buf_ptr++;
			      line_wtf = *((IGRint *) fb_buf_ptr + 1);
	
			      num_pts = line_wtf / 3;
			      fb_buf_ptr++;

/*  put number of vectors in buffer and copy vectors into buffer 	*/

			      *(IGRint *) *dyn_buf_ptr = num_pts;
			      (*dyn_buf_ptr)++;
			      OM_BLOCK_MOVE(fb_buf_ptr,*dyn_buf_ptr,
				sizeof(IGRdouble) * 3 * num_pts);
			      *dyn_buf_ptr += (3 * num_pts);

			      fb_buf_ptr += line_wtf;
			      bsp_curve_wtf -= (line_wtf + 2);
			   }
			   break;

			case DL_FB_LXYZ:
			case DL_FB_PNTXYZ:

			   if (!polygon)
			   {
			       (*dyn_buf_ptr)++;
			       wtf_ptr = (IGRint *) (*dyn_buf_ptr)++;
			       polygon = TRUE;
			   }

			   line_wtf = *((IGRint *) fb_buf_ptr + 1);

			   if ( (line_wtf + 1) > (IGRint)( *end_dyn_buf - *dyn_buf_ptr))
			   {

			      *dyn_buf_ptr = sav_dyn_ptr;			      if (alldone)
			      {

				  *buffer_full = TRUE;
			      }
			      else
			      {
				  frame_buffer = TRUE;
				  if (((line_wtf + 1) * sizeof(IGRdouble)) > DPframe_block_size)
				  {
				      frame_block_size = (line_wtf + 100) * sizeof(IGRdouble);
				  }
				  else
				  {
				      frame_block_size = 0;
				  }

			          status = DPget_frame_block(frame_block_size);
				  if (!status)
				  {
				     alldone = TRUE;
				  }
			      }
			      done = TRUE;
			      continue;
			   }

			   num_pts = line_wtf / 3;
			   fb_buf_ptr++;

/*  put number of vectors in buffer and copy vectors into buffer 	*/

			   *(IGRint *) *dyn_buf_ptr = num_pts;
			   (*dyn_buf_ptr)++;
			   OM_BLOCK_MOVE(fb_buf_ptr,*dyn_buf_ptr,
				sizeof(IGRdouble) * 3 * num_pts);
			   *dyn_buf_ptr += (3 * num_pts);

			   fb_buf_ptr += line_wtf;
			   break;

			default:

/*  If no curve was present, fill in polygon words to follow and	*/
/*  curve display attributes						*/
/*  Also, fill in curve wtf and #vector to 0 (done to make buffers	*/
/*  uniform								*/
			   if (wtf_ptr)
			   {
			       *wtf_ptr = (((IGRint) *dyn_buf_ptr - 
					    (IGRint) wtf_ptr) / 4) -1;
			   }

/* Fill in total words to follow					*/

			   *total_wtf = (((IGRint) *dyn_buf_ptr -
					     (IGRint) total_wtf) / 4) -1;

			      
			   done = TRUE;

		   } /* end if switch (fb_buf_ptr)  */

	        } /* end of while (!done)  */
		break;


	   default:
		break;

	   }  /* end switch (type)  */

/* check to make sure there is room to put the end tag in buffer  */

	   if ( ( *end_dyn_buf - *dyn_buf_ptr) < 1)
	   {
	      *dyn_buf_ptr = sav_dyn_ptr;
	      *buffer_full = TRUE;
	   }

	}  /* end while (!done)  */
	
	return(status);
}

/************************************************************************/
/*									*/
/*	function - DPreset_frames							*/
/*									*/
/*									*/
/************************************************************************/



IGRint DPreset_frames(msg)

   IGRlong	*msg;
{


   register struct DPframe	*dyn_frames;
   IGRint		i;
   IGRint		status = TRUE;

	*msg = MSSUCC;

/*  If there is no frame active, clear memory  */

	if (!DPframe_active)
	{

	   if (DPstatic_frame.frame_ptr)
	   {
	      DPfree_frame(DPstatic_frame.frame_ptr);
	      DPstatic_frame.frame_ptr = NULL;
	   
	   }

	   if (DPdynamic_frames)
	   {
	      dyn_frames = DPdynamic_frames;

/*	      dyn_frames++; */

/*  deallocate memory for all dynamic frames	*/

	      for (i = 0; i< DPnum_of_frames; i++)
	      {
	         if (dyn_frames->frame_ptr)
	         {
		    DPfree_frame(dyn_frames->frame_ptr);
		    dyn_frames->frame_ptr = NULL;
	         }
		 dyn_frames++;
	      }
	   }
	

	   DPnum_of_frames = 0;
	   DPcurrent_display_frame = 0;
	}
	else
	{
	   *msg = DPFRAMEACT;
	   status = FALSE;
	}

	return(status);
	
   
}

/************************************************************************/
/*									*/
/*	function - DPstart_frame					*/
/*									*/
/*									*/
/************************************************************************/

IGRint  DPstart_frame(	IGRlong		*msg,
			IGRint		static_frame,
			IGRint		frame_no,
			IGRint		load_frame,
			IGRint		feedback,
			IGRdouble	*feedback_buf,
			IGRint		feedback_size,
			IGRdouble	apparent_stroke_scale,
			GRobjid		gragad_id,
			GRspacenum	gragad_osnum,
			GRobjid		*frame_id,
			GRspacenum	*frame_osnum )

   {
   IGRint	status = TRUE;
   IGRdouble	*disp_buf = 0;
   IGRint	disp_buf_size = 0;
   IGRint	gpipe_fb;
   IGRdouble	*gpipe_fb_buf;
   IGRint	gpipe_fb_size;

	*msg = MSSUCC;


/*  cannot start new frame if frame is already active  */

	if (DPframe_active)
	{
	   *msg = DPFRAMEACT;
	   goto wrapup;
	}

/*  a feedback buffer or loading into display memory has to be true  */

	if (!feedback && !load_frame)
	{
	   *msg = DPINVREQUEST;
	   goto wrapup;
	}

/* if feedback is TRUE, a feedback buffer must be specified	*/

	if (feedback && (!feedback_buf  || (feedback_size <= 0)))
	{
	   *msg = DPNOFDBCKBUF;
	   goto wrapup;
	}


/* set up view */

	status = om$send( msg = message IGEgragad.start_frame(msg,load_frame,
					&disp_buf,&disp_buf_size,
					&gpipe_fb,&gpipe_fb_buf,
					&gpipe_fb_size,frame_id,
					frame_osnum),
			  senderid = NULL_OBJID,
			  targetid = gragad_id,
			  targetos = gragad_osnum);

	if (!(1 & status))
	{
	   
	   status = FALSE;
	   goto wrapup;
	}

/* set up buffer  */
	if (load_frame)
	{

	   if (!DPdyn_set_up_buf(msg,static_frame,&frame_no,disp_buf,
				 disp_buf_size))
	   {
	      goto wrapup;
	   }

	   

/* set up pointers to buffers  */

/* keep pointer to active frame so that if memory is reallocated, everything
   will be kept up to date	*/

	   if (static_frame)
	   {
	      DPactive_frame = &DPstatic_frame.frame_ptr;
	      DPdyn_buf_ptr = DPstatic_frame.frame_ptr;
	      DPend_dyn_buf = (IGRdouble *)((IGRchar *) DPdyn_buf_ptr + (IGRint )DPstatic_frame.block_size);
	   }
   	   else
	   {
	      DPactive_frame = &DPdynamic_frames[frame_no].frame_ptr;
	      DPdyn_buf_ptr = DPdynamic_frames[frame_no].frame_ptr;
	      DPend_dyn_buf = (IGRdouble *)((IGRchar *) DPdyn_buf_ptr + (IGRint )DPdynamic_frames[frame_no].block_size);
	   }



	   DPdyn_buf_ptr++;
	   DPnext_block = (IGRdouble **) DPdyn_buf_ptr++;


	   *(IGRint *) DPdyn_buf_ptr = 0;

	}


	   if (DPgpipe_fb_buf)
	   {
	      om$dealloc(ptr = DPgpipe_fb_buf);
	   }

/* allocate memory for the gpipe feedback buffer  	*/

	   if (gpipe_fb)
	   {
	      DPgpipe_fb_buf = gpipe_fb_buf;
		
	      if (!DPgpipe_fb_buf)
	      {
	         *msg = DPNODYNMEM;
	         goto wrapup;
	      }
	   }

/* set up application feedback buffers	*/

	if (feedback)
	{
	  DPbeg_app_buf = feedback_buf;
	  DPapp_fb_buf_ptr = feedback_buf;

/*  make sure size is a multiple of eight	*/

	  feedback_size &= ~7;

	  DPend_app_fb_buf = (IGRdouble *) ((IGRchar *) feedback_buf + feedback_size);

	  *(IGRint *) DPapp_fb_buf_ptr = DPWIREFRAME_FRAME;

	  DPapp_fb_buf_ptr++;

	  *(IGRint *) DPapp_fb_buf_ptr = 0;

	 DPapp_fb_buf_ptr++;

          *(IGRint *) DPapp_fb_buf_ptr = 0;

	}

/* clear buffer full flags	*/

	DPclear_buf_full();

/* set up view for view dynanamics	*/

	status = om$send( msg = message GRviewdyn.GRviewdyn_set_up(msg,
						  apparent_stroke_scale),
			  senderid = NULL_OBJID,
			  targetid = *frame_id,
			  targetos = *frame_osnum);

	if (!(1 & status))
	{
	   
	   status = FALSE;
	   goto wrapup;
	}

	DPframe_id = *frame_id;
	DPframe_osnum = *frame_osnum;

	DPframe_active = TRUE;


wrapup:

	if (!(1 & *msg))
	{
/* if error clear memory */
	   if (DPactive_frame)
	   {
	      om$dealloc(ptr = *DPactive_frame);
	   }

	   if (DPgpipe_fb_buf)
	   {
	      om$dealloc(ptr = DPgpipe_fb_buf);
	   }
	   
	   status = FALSE;
	}

	return(status);
}

	   
end implementation IGEgragad;

 
