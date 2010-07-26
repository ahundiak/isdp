class implementation IGEgragad;

struct col_win
{
   IGRlong	*msg;
   IGRint	*num_windows;
   IGRint	max_ids;
   struct GRid	*wn_list;
   IGRint	flag;
};

#include "grimport.h"

#include "dppriv.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "madef.h"
#include "csmacros.h"
#include "griodef.h"
#include "griomacros.h"

#include "wl.h"

#include "dpdynsup.h"

#define NWINDOW 40

%safe
static  IGRint		(*DPdyn_cur_fun)() = NULL;
static  IGRint		text_dynamics = 0;
static  GRobjid		mod_id;
static  uword		mod_osnum;
%endsafe


from IGEwindow import passon;
from GRgraphics import  GRdisyourself;

#define    DYN_BUF_SIZE	10240   /*  10k */

IGRint DPdyn_set_up(
    struct DP_information 	*dp_info,
    struct DPgad_in_win	  	*win_info,
    IGRint			*win,
    IGRint			*num_win,
    IGRint			*num_gra_gad )


     {
       IGRint		status;
       IGRint		i,j;
       IGRlong		msg;
       IGRint		lwin_no;
       IGRint		temp_num;
       IGRint		extents[4];
       IGRlong		win_no_bytes;
       IGRint		flag;
       IGRlong		which_error;
       struct col_win 	coll_win;
       struct GRid	wn_list[NWINDOW];
       OM_S_MESSAGE	colmsg;
       OM_S_CHANSELECT	chandef;       

	/*  get all the window objects that are connected to this module's channel */
	*num_gra_gad = 0;
	*num_win = 0;

	ex$get_cur_mod( id= &mod_id,
			osnum=&mod_osnum);
	
	for (i = 0; i < NWINDOW ; i++)
	{
	   win_info[i].num_of_gra_gad = 0;
	}

	flag = HIDDENLN_GG |  IGE_GG |ACTIVE_GG | NO_DELAY_GG;
	
	coll_win.msg = &msg;
	coll_win.num_windows = num_gra_gad;
	coll_win.max_ids = 32;
	coll_win.wn_list = wn_list;
	coll_win.flag = flag;

	status = om$make_message(  classname = "IGEgragad",
				   methodname = "DPcollect_win",
				   size = sizeof(struct col_win),
				   p_arglist = &coll_win,
				   p_msg     = &colmsg);

	chandef.type = OM_e_name;
	chandef.u_sel.name = "module.windows";

	
	status = om$send(mode = OM_e_wrt_object,
                         msg = message IGEwindow.passon(&colmsg,"to_children",
							  NULL,NULL),
                         senderid = mod_id,
			 targetos = mod_osnum,
                         p_chanselect = &chandef,
                         from =  NULL,
                         to = NULL);

	for (i = 0; i < *num_gra_gad; i++)
	{

	   struct var_list  list[4];

    	   list[0].var = WIN_NO;
    	   list[0].var_ptr = (char *) &lwin_no;
    	   list[0].num_bytes = sizeof(IGRint);
    	   list[0].bytes_returned= &win_no_bytes;

    	   list[1].var = GRAGAD_DEP;
    	   list[1].var_ptr = (char *)extents;
    	   list[1].num_bytes = sizeof(IGRint)*4;
    	   list[1].bytes_returned= &win_no_bytes;

    	   list[2].var = GRAGAD_STRUCT;
    	   list[2].var_ptr = (char *)dp_info[i].gragad;
    	   list[2].num_bytes = sizeof(struct DPgra_gad);
    	   list[2].bytes_returned= &win_no_bytes;

    	   list[3].var = END_PARAM;
    	   list[3].var_ptr = NULL;
    	   list[3].num_bytes = 0;
    	   list[3].bytes_returned = NULL;

           dp$inq_set_gragad( msg = &msg,
                              osnum = wn_list[i].osnum,
                              gragad_objid = wn_list[i].objid,
                              which_error = &which_error,
                              var_list = list );

	   temp_num = win_info[i].num_of_gra_gad;
	   win_info[i].num_of_gra_gad++;
	
	   win_info[i].gads[temp_num].x_min = extents[0];
	   win_info[i].gads[temp_num].y_min = extents[1];
	   win_info[i].gads[temp_num].x_max = extents[2];
	   win_info[i].gads[temp_num].y_max = extents[3];	
	
	   win_info[i].gads[temp_num].index = i;
	   win_info[i].gads[temp_num].id = wn_list[i].objid;
	
	   dp_info[i].win_no = lwin_no;
	   dp_info[i].view_objid = wn_list[i].objid;
	   dp_info[i].view_osnum = wn_list[i].osnum;
	
           /* !!! make sure window isn't in list already !!! */
	   win[*num_win] = lwin_no;
	   (*num_win)++;
	   WLenter_dynamics( lwin_no );
           WLset_dynamics_drawing_mode( lwin_no, WL_DYN_DRAW_MODE );
	
	   if (dp_info[i].gragad->flags & VALID_ALT_INV)
	   {
	      for (j=0; j<4; j++)
	      {
	 	 dp_info[i].gragad->rotation[0][j] = 
				dp_info[i].gragad->construct_plane[0][j];

	 	 dp_info[i].gragad->rotation[1][j] = 
				dp_info[i].gragad->construct_plane[1][j];

	 	 dp_info[i].gragad->rotation[2][j] = 
				dp_info[i].gragad->construct_plane[2][j];

	 	 dp_info[i].gragad->rotation[3][j] = 
				dp_info[i].gragad->construct_plane[3][j];

	      } /* end of for (j=0 ...)  */
	
	      dp_info[i].gragad->rotation[0][3] = 0;
	      dp_info[i].gragad->rotation[1][3] = 0;
	      dp_info[i].gragad->rotation[2][3] = 0;

	   } /* end of if (.... & VALID_ALT_INV)  */

	} /*  end of for (i = 0; ....) */

     return(0);

     } /* end of DPdyn_set_up  */



IGRint DPdyn_ret_index(
    IGRint   x,
    IGRint   y,
    WLuint32 lwin_no,
    IGRint   num_win,
    struct DP_information *dp_info,
    struct DPgad_in_win	*win_info,
    IGRint *index,
    GRobjid *win_id )

     {

	IGRint ii, jj;
	IGRboolean  found = FALSE;
	
	for (ii = 0; ii < num_win; ii++ )
	{
	   for (jj = 0; jj < win_info->num_of_gra_gad; jj++)
	   {
              if ( (dp_info[win_info[ii].gads[jj].index].win_no == lwin_no) &&
	           (x >= win_info[ii].gads[jj].x_min) &&
	           (x <= win_info[ii].gads[jj].x_max) &&
	           (y >= win_info[ii].gads[jj].y_min) &&
	           (y <= win_info[ii].gads[jj].y_max))
	      {
	         found = TRUE;
	         *index = win_info[ii].gads[jj].index;
	         *win_id = win_info[ii].gads[jj].id;	
	         break;
	      }
	   }
	}

	return(found);
     }


void DPclean_up_dyn(
   struct DP_information *dp_info,
   IGRint index,
   IGRint win_no,
   IGRint num_gra_gad,
   IGRboolean all_windows )

{

    struct DPdit_range	range;
    IGRint		i;

	if (all_windows)
	{
	   for (i = 0; i < num_gra_gad; i++)
	   {
	      range.xlo = dp_info[i].gragad->dit_clip_range[0] + 0.5;
	      range.ylo = dp_info[i].gragad->dit_clip_range[1] + 0.5;
	      range.xhi = dp_info[i].gragad->dit_clip_range[3] + 0.5;
	      range.yhi = dp_info[i].gragad->dit_clip_range[4] + 0.5;

              if ( WLclear_hilite( dp_info[i].win_no ) == WL_NO_HILITE_PLANE )
	      {
                 /* !!! redraw everything here because we are in XOR mode !!! */
              }

	      WLshow_cursor( dp_info[i].win_no );
	      WLflush( dp_info[i].win_no );
	   }
	}
	else
	{
	   range.xlo = dp_info[index].gragad->dit_clip_range[0] + 0.5;
	   range.ylo = dp_info[index].gragad->dit_clip_range[1] + 0.5;
	   range.xhi = dp_info[index].gragad->dit_clip_range[3] + 0.5;
	   range.yhi = dp_info[index].gragad->dit_clip_range[4] + 0.5;

           if ( WLclear_hilite( win_no ) == WL_NO_HILITE_PLANE )
	   {
              /* !!! redraw everything here because we are in XOR mode !!! */
           }

	   WLshow_cursor( win_no );
	   WLflush( win_no );

	}
}

void DPdisp_dyn(
   IGRint num_of_screens,
   IGRint num_phy_screens,
   IGRboolean dynamics_all_windows,
   IGRint actual_cursor,
   IGRint lwin_no,
   struct GRid *objects,
   struct DPele_header *buffers,
   struct GRmdenv_info *mod_info,
   IGRint out_flags,
   struct DP_information *dp_info,
   IGRint num_gra_gad,
   IGRint num_objects,
   IGRint num_buffers,
   struct DPviewind *viewind,
   IGRint no_cursor,
   IGRint num_windows,
   IGRint *win,
   IGRint index,
   struct EX_button *uor_point,
   IGRdouble *mat,
   IGRint *dit_point,
   IGRboolean erase_flag )

{

	struct DPele_header *tmp_buffers;
	struct GRid	    *tmp_objects;
	struct GRmdenv_info *tmp_mod_info;
	IGRint i,j,jj,ii;
	IGRint draw_cursor;
	IGRint start_gragad;
	IGRint end_gragad;
	IGRlong 	msg;
	IGRlong		num_points = 1;
	IGRdouble	*matrix;
	IGRdouble	tmp_point[3];
	IGRshort	type = MAIDMX;

	enum 	GRdpmode disp_mode;
	struct DPviewinfo	old_view_info;
	struct DPdit_range	range;
	struct WLpoint segment[2];

	disp_mode = GRhd;

	/* double buffering totally removed during WL/DL  */
	/* conversion because we weren't doing it anyway. */

	if (actual_cursor)
	{
	   WLhide_cursor( lwin_no, TRUE );
	}

	if (dynamics_all_windows)
	{
	   start_gragad = 0;
	   end_gragad = num_gra_gad;
	}
	else
	{
	   start_gragad = index;
	   end_gragad = index + 1;
	}

	tmp_objects = objects;
	tmp_buffers = buffers;
	tmp_mod_info = mod_info;

#if FALSE
/* Taken out in WL conversion */
	if (!(out_flags & DP_DONT_ERASE))
	{
	   for (i = start_gragad; i< end_gragad; i++)
	   {
		 range.xlo = dp_info[i].gragad->dit_clip_range[0] + 0.5;
		 range.ylo = dp_info[i].gragad->dit_clip_range[1] + 0.5;
		 range.xhi = dp_info[i].gragad->dit_clip_range[3] + 0.5;
		 range.yhi = dp_info[i].gragad->dit_clip_range[4] + 0.5;

                 if ( WLclear_hilite( lwin_no ) == WL_NO_HILITE_PLANE )
   	         {
                    /* !!! redraw everything here because we are in XOR mode !!! */
                 }
	   }
	}
#endif				
				
	if (!( (erase_flag) && (out_flags & DP_DONT_ERASE) ))
        {
	   for (i = start_gragad; i < end_gragad; i++)
	   {
	      if ( erase_flag )
	      {
	         WLset_dynamics_drawing_mode( dp_info[i].win_no, WL_DYN_ERASE_MODE );
   
                 /* clear the hilite plane, if we can */
	         if ( WLclear_hilite( dp_info[i].win_no ) == WL_SUCCESS )
	         {
	            continue;
	         }
	      }
	      else
	      {
	         WLset_dynamics_drawing_mode( dp_info[i].win_no, WL_DYN_DRAW_MODE );
	      }
   
	      for (j=0; j < num_objects; j++,objects++)
	      {
	         if (mod_info)
	         {
		    matrix = mod_info->matrix;
		    type = mod_info->matrix_type;
	         }
	         else
	         {

		    matrix = mat;
		    type = MAIDMX;
	         }

/*
	Fix for TR #:119702555 :

 Change the `rotation' matrix to the `wld_to_view' matrix since we intend to display the dimension always with respect to view plane and not with respect to any (active) reference plane.
	Earlier case - If the ref.plane is inverted with respect to view plane, the dimension used to get displayed inverted, (though) only in dynamics. This was so since GRdisyourself() displayes the item w.r.t. world coordinate system. The following correction makes the display in compliance with the view plane.

								Abhijit.
*/

	for(ii=0;ii<4;ii++)
	for(jj=0;jj<4;jj++)
		dp_info[i].gragad->rotation[ii][jj]=dp_info[i].gragad->wld_to_view[ii][jj];

	         om$send(mode = OM_e_wrt_object,
                             msg = message GRgraphics.GRdisyourself(&msg,
						    &type,matrix,&disp_mode,0,
						    &dp_info[i],NULL),
                             senderid = NULL_OBJID,
                             targetid = objects->objid,
                             targetos = objects->osnum);
	      }
   
	      for (j=0;j<num_buffers;j++,buffers++)
              {
	         if (out_flags & DP_VIEW_IND_BUF)
	         {
		    dp$set_view_ind(  type = viewind->type,
					   point = viewind->point,
					   dp_info = &dp_info[i],
					   old = &old_view_info);
	         }
   
	         DPdiselem(&msg,buffers,&disp_mode, &dp_info[i]);
   
	         if (out_flags & DP_VIEW_IND_BUF)
	         {
		    dp$reset_view_ind( dp_info = &dp_info[i],
					    old = &old_view_info);
	         }
   
	      }
	      buffers = tmp_buffers;
	      objects = tmp_objects;
	      mod_info = tmp_mod_info;
   
	   } /* end of for (i = start_gragad; i< end_gragad; i++)  */
        } /* end of if (!( (erase_flag) && (out_flags & DP_DONT_ERASE) )) */


	if (actual_cursor)
	{
	   WLshow_cursor(lwin_no);
	}

	if (out_flags & DP_NEW_POINT)
	{
	   out_flags = 0;
	   tmp_point[0] = uor_point->x;
	   tmp_point[1] = uor_point->y;
	   tmp_point[2] = uor_point->z;
	   MAoptsxform(&msg,&num_points,&dp_info[index].gragad->wld_viewport_type,
				dp_info[index].gragad->wld_to_viewport,
				            tmp_point,tmp_point);

	   dit_point[0] = (IGRint) (tmp_point[0] + 0.5);
	   dit_point[1] = (IGRint) (tmp_point[1] + 0.5);

        }

	if (!no_cursor && !actual_cursor)
	{
	   draw_cursor = TRUE;
	   if (DPdyn_cur_fun)
	   {
	        draw_cursor = (*DPdyn_cur_fun)(lwin_no,index,dp_info,uor_point,dit_point,mod_osnum);
	   }

	   if (draw_cursor)
	   {
	       /* don't need to set the color because being in dynamics takes care of it */
	       WLset_active_symbology( lwin_no, 0, 0, 0xFFFF, 0,
	              (WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT) );

	       segment[0].x = dit_point[0] - 15;
	       segment[0].y = dit_point[1];
	       segment[1].x = dit_point[0] + 15;
	       segment[1].y = dit_point[1];
	       WLdraw_2D_line_string( lwin_no, 2, segment );

	       segment[0].x = dit_point[0];
	       segment[0].y = dit_point[1] - 15;
	       segment[1].x = dit_point[0];
	       segment[1].y = dit_point[1] + 15;
	       WLdraw_2D_line_string( lwin_no, 2, segment );
	    }
	
	}

 	if (dynamics_all_windows)
	{
	   for (i=0;i< num_windows; i++)
	   {
	       WLflush( win[i] );
	   }
	}
	else
	{
	   WLflush( lwin_no );
	}

}  /* DPdisp_dyn */



IGRint (*DPset_dyn_cur_fun(
   IGRint (*func)() ) )()

{
  IGRint (*temp_func)();

	temp_func = DPdyn_cur_fun;
	DPdyn_cur_fun = func;

	return(temp_func);
}

void DPset_text_dyn(
    IGRint mode )

{
    text_dynamics = mode;
}


end implementation IGEgragad;
