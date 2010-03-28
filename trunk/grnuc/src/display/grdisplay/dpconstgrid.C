/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

	MODULE NAME - DPconstgrid 
 
     	Abstract: This method draws construction plane grid

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *wn	 struct DPwindow	window structure

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg           IGRlong	 MSSUCC -- successful completion


-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	HT  04/28/86  : Creation date.
--
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"
#include "wl.h"
#include "igecolordef.h"

/* prototype files */
#include "dpconstgrid.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "masqrt.h"
#include "maptsxfor.h"
#include "mamulmx.h"


#define debug  0

IGRint	DPconstgrid (msg,wn, win_no, wn_min_x, wn_min_y, wn_max_x, wn_max_y)

    IGRlong		*msg;
    struct DPgra_gad 	*wn;
    IGRint		win_no;
    IGRint		wn_min_x;
    IGRint		wn_min_y;
    IGRint		wn_max_x;
    IGRint		wn_max_y;

     {

	IGRlong status = OM_S_SUCCESS;
	IGRdouble grid_delta_x[3];/* distance between 2 grid dot/ref in dits */
	IGRdouble grid_delta_y[3];
	IGRdouble tmp;
	IGRdouble tmp_mtx[16],scale_mtx[16],const_rot[16],final_mtx[16];
	IGRdouble inv_rot[16],tran_mtx[16];
	IGRdouble uor_per_grid_x,uor_per_grid_y;
	IGRdouble min_x,min_y,min_z,max_x,max_y,max_z;
	IGRdouble xdit,ydit,zdit;
	IGRdouble start_pnt[3];
	IGRdouble const_org[3];
	IGRdouble ul_pnt[3];
	IGRdouble ll_pnt[3];
	IGRdouble ur_pnt[3];
	IGRdouble lr_pnt[3];
	IGRdouble cross_delta_x[3];
	IGRdouble cross_delta_y[3];
	IGRdouble x_len;
	IGRdouble y_len;
	IGRboolean clip_ok = TRUE;
	IGRint	  num_x_pnts;
	IGRint	  num_y_pnts;
	IGRint	  num_x_refs;
	IGRint	  num_y_refs; 
	IGRlong   one = 1;
	IGRint i,j;
	IGRshort four = 4;
	WLcolorref color_ref;
	struct WLpoint mypnt, line_pt[2];


	*msg = MSSUCC;
	if (wn->flags & GRID_ON)
	{
           WLpack_index_colorref( IGE_LOGICAL_HILITE, &color_ref, FALSE );
	}
	else
	{
           WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
	}

	WLset_active_symbology( win_no, color_ref, 0, 0xFFFF, 0, 
                                WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_COLOR |
                                WL_SYMB_CHANGE_WEIGHT );
        
	uor_per_grid_x = (wn->uor_per_ref_x/wn->grid_per_ref_x);
	uor_per_grid_y = (wn->uor_per_ref_y/wn->grid_per_ref_y);
	
	MAidmx(msg,scale_mtx);
	scale_mtx[0] = wn->vvol_viewport_scale;
	scale_mtx[5] = wn->vvol_viewport_scale;
	scale_mtx[10] = wn->vvol_viewport_scale;


	MAmulmx(msg, &four, &four, &four, scale_mtx, (IGRdouble *)wn->rotation,
		tmp_mtx);

	OM_BLOCK_MOVE(wn->construct_plane,const_rot,
				sizeof(IGRdouble)*16);


	const_org[0] = const_rot[3];
	const_org[1] = const_rot[7];
	const_org[2] = const_rot[11];

	const_rot[3] = 0;
	const_rot[7] = 0;
	const_rot[11] = 0;

	MAinvmx(msg,&four,const_rot,inv_rot);

	MAmulmx(msg,&four,&four,&four,tmp_mtx,inv_rot,final_mtx);

	grid_delta_x[0] = uor_per_grid_x;
	grid_delta_x[1] = 0;
	grid_delta_x[2] = 0;

	grid_delta_y[0] = 0;
	grid_delta_y[1] = uor_per_grid_y;
	grid_delta_y[2] = 0;

	MAptsxform(msg,&one,final_mtx,grid_delta_x,grid_delta_x);

	MAptsxform(msg,&one,final_mtx,grid_delta_y,grid_delta_y);

  /* adjust to axis of hardware  */

	grid_delta_x[1] = - grid_delta_x[1];
	grid_delta_y[1] = - grid_delta_y[1];

	ul_pnt[0] = wn_min_x;
	ul_pnt[1] = wn_min_y;
	ul_pnt[2] = wn->act_z_screen;

	ll_pnt[0] = wn_min_x;
	ll_pnt[1] = wn_max_y;
	ll_pnt[2] = wn->act_z_screen;

	ur_pnt[0] = wn_max_x;
	ur_pnt[1] = wn_min_y;
	ur_pnt[2] = wn->act_z_screen;

	lr_pnt[0] = wn_max_x;
	lr_pnt[1] = wn_max_y;
	lr_pnt[2] = wn->act_z_screen;


	MAidmx(msg,tran_mtx);

	tran_mtx[3] = - (const_org[0]);
	tran_mtx[7] = - (const_org[1]);
	tran_mtx[11] = - (const_org[2]);

	MAmulmx(msg,&four,&four,&four,const_rot,tran_mtx,tmp_mtx);

	MAmulmx(msg, &four, &four, &four, tmp_mtx, 
		(IGRdouble *)wn->alt_vwport_to_wld, final_mtx);

  /*  find the  range of the four corner points  */

	MAptsxform(msg,&one,final_mtx,ul_pnt,ul_pnt);
	MAptsxform(msg,&one,final_mtx,ll_pnt,ll_pnt);
	MAptsxform(msg,&one,final_mtx,ur_pnt,ur_pnt);
	MAptsxform(msg,&one,final_mtx,lr_pnt,lr_pnt);

  /* get mins and maxes  */


	min_x = ul_pnt[0];
	max_x = ul_pnt[0];

	if (ll_pnt[0] < min_x)
	{
	   min_x = ll_pnt[0];
	}
	
	if (ll_pnt[0] > max_x)
	{
	   max_x = ll_pnt[0];
	}

	if (ur_pnt[0] < min_x)
	{
	   min_x = ur_pnt[0];
	}
	
	if (ur_pnt[0] > max_x)
	{
	   max_x = ur_pnt[0];
	}

	if (lr_pnt[0] < min_x)
	{
	   min_x = lr_pnt[0];
	}
	
	if (lr_pnt[0] > max_x)
	{
	   max_x = lr_pnt[0];
	}




	min_y = ul_pnt[1];
	max_y = ul_pnt[1];

	if (ll_pnt[1] < min_y)
	{
	   min_y = ll_pnt[1];
	}
	
	if (ll_pnt[1] > max_y)
	{
	   max_y = ll_pnt[1];
	}

	if (ur_pnt[1] < min_y)
	{
	   min_y = ur_pnt[1];
	}
	
	if (ur_pnt[1] > max_y)
	{
	   max_y = ur_pnt[1];
	}

	if (lr_pnt[1] < min_y)
	{
	   min_y = lr_pnt[1];
	}
	
	if (lr_pnt[1] > max_y)
	{
	   max_y = lr_pnt[1];
	}




	min_z = ul_pnt[2];
	max_z = ul_pnt[2];

	if (ll_pnt[2] < min_z)
	{
	   min_z = ll_pnt[2];
	}
	
	if (ll_pnt[2] > max_z)
	{
	   max_z = ll_pnt[2];
	}

	if (ur_pnt[2] < min_z)
	{
	   min_z = ur_pnt[2];
	}
	
	if (ur_pnt[2] > max_z)
	{
	   max_z = ur_pnt[2];
	}

	if (lr_pnt[2] < min_z)
	{
	   min_z = lr_pnt[2];
	}
	
	if (lr_pnt[2] > max_z)
	{
	   max_z = lr_pnt[2];
	}



 /* calculate number of points needed  */

	num_x_pnts = (IGRint) ((max_x - min_x) / 
			(uor_per_grid_x));

	num_x_pnts += 2;

	num_x_refs = (IGRint)(num_x_pnts/wn->grid_per_ref_x);

	num_x_refs += 2;

	num_y_pnts = (IGRint) ((max_y - min_y) / 
			(uor_per_grid_y));

	num_y_pnts += 2;

	num_y_refs = (IGRint)(num_y_pnts/wn->grid_per_ref_y);

	num_y_refs += 2;

  /* find start point for grid dots */

	start_pnt[0] = (IGRdouble)(IGRint) (min_x / (uor_per_grid_x));
	start_pnt[0] *= uor_per_grid_x;

	start_pnt[1] = (IGRdouble)(IGRint) (min_y / uor_per_grid_y);
	start_pnt[1] *= uor_per_grid_y;

	start_pnt[2] = 0;


	tran_mtx[3] = const_org[0];
	tran_mtx[7] = const_org[1];
	tran_mtx[11] = const_org[2];	

	MAmulmx(msg, &four, &four, &four, (IGRdouble *)wn->wld_to_viewport,
		tran_mtx, tmp_mtx);

	MAmulmx(msg,&four,&four,&four,tmp_mtx,inv_rot,final_mtx);

	MAptsxform(msg,&one,final_mtx,start_pnt,start_pnt);

	tmp = grid_delta_x[0]*grid_delta_x[0] +
	      grid_delta_x[1]*grid_delta_x[1];

	x_len = MAsqrt(msg,&tmp);


	tmp = grid_delta_y[0]*grid_delta_y[0] +
	      grid_delta_y[1]*grid_delta_y[1];

	y_len = MAsqrt(msg,&tmp);

	WLset_active_symbology( win_no, 0, DP_SOLID_LINE_STYLE, 0xffff, 0, 
                                WL_SYMB_CHANGE_STYLE );
	WLhide_cursor( win_no, TRUE ); 
	WLflush( win_no );

	if ((x_len >= MIN_GRID_DELTA) && (y_len >= MIN_GRID_DELTA))
	{
	   for (i=0; i < num_y_pnts; i++)
	   {
	      xdit = start_pnt[0] + (i * grid_delta_y[0]);
	      ydit = start_pnt[1] + (i * grid_delta_y[1]);
	      zdit = start_pnt[2] + (i * grid_delta_y[2]);
	      for (j=0 ; j < num_x_pnts; j++)
	      {

	/*  clip to dit clip range  */

		 if (wn->flags & FRONT_CLIP)
		 {
		    clip_ok = (zdit >= wn->dit_clip_range[2]) ? TRUE : FALSE;
		 }

		 if ((wn->flags & BACK_CLIP) && clip_ok)
		 {
		    clip_ok = (zdit <= wn->dit_clip_range[5]) ? TRUE : FALSE;
		 }

		 if (clip_ok)
		 {
                   mypnt.x =  (short) ( xdit + 0.5 );
                   mypnt.y =  (short) ( ydit + 0.5 );
		   WLdraw_2D_point_string( win_no, 1, &mypnt );
		 }

		 xdit += grid_delta_x[0];
		 ydit += grid_delta_x[1];
		 zdit += grid_delta_x[2];
	      }
	   }
	}



  /* find start point for reference cross */

	start_pnt[0] = (IGRdouble)(IGRint) (min_x / (wn->uor_per_ref_x));
	start_pnt[0] *= wn->uor_per_ref_x;

	start_pnt[1] = (IGRdouble)(IGRint) (min_y / wn->uor_per_ref_y);
	start_pnt[1] *= wn->uor_per_ref_y;


	start_pnt[2] = 0;



	MAptsxform(msg,&one,final_mtx,start_pnt,start_pnt);

	grid_delta_x[0] *= wn->grid_per_ref_x;    	
	grid_delta_x[1] *= wn->grid_per_ref_x;    	
	grid_delta_x[2] *= wn->grid_per_ref_x;    	

	grid_delta_y[0] *= wn->grid_per_ref_y;    	
	grid_delta_y[1] *= wn->grid_per_ref_y;    	
	grid_delta_y[2] *= wn->grid_per_ref_y;    	


  /*  get reference cross orientation  */

	MAmulmx(msg, &four, &four, &four, (IGRdouble *)wn->rotation, inv_rot,
		final_mtx);


	cross_delta_x[0]= 3;	
	cross_delta_x[1]= 0;	
	cross_delta_x[2]= 0;	

	cross_delta_y[0]= 0;
	cross_delta_y[1]= 3;	
	cross_delta_y[2]= 0;	

	MAptsxform(msg,&one,final_mtx,cross_delta_x,cross_delta_x);
	MAptsxform(msg,&one,final_mtx,cross_delta_y,cross_delta_y);

  /*  adjust for hardware   */

	cross_delta_x[1] = - (cross_delta_x[1]);
	cross_delta_y[1] = - (cross_delta_y[1]);

	tmp = grid_delta_x[0]*grid_delta_x[0] +
	      grid_delta_x[1]*grid_delta_x[1];

	x_len = MAsqrt(msg,&tmp);


	tmp = grid_delta_y[0]*grid_delta_y[0] +
	      grid_delta_y[1]*grid_delta_y[1];

	y_len = MAsqrt(msg,&tmp);


	if ((x_len >= MIN_REF_DELTA) && (y_len >= MIN_REF_DELTA))	
	{
	   for (i=0; i < num_y_refs; i++)
	   {
	      xdit = start_pnt[0] + (i * grid_delta_y[0]);
	      ydit = start_pnt[1] + (i * grid_delta_y[1]);
	      zdit = start_pnt[2] + (i * grid_delta_y[2]);
	      for (j=0 ; j < num_x_refs; j++)
	      {


		 if (wn->flags & FRONT_CLIP)
		 {
		    clip_ok = (zdit >= wn->dit_clip_range[2]) ? TRUE : FALSE;
		 }

		 if ((wn->flags & BACK_CLIP) && clip_ok)
		 {
		    clip_ok = (zdit <= wn->dit_clip_range[5]) ? TRUE : FALSE;
		 }

		 if (clip_ok)
		 {
		    line_pt[0].x = ( short )( xdit - cross_delta_x[0] + 0.5 );
		    line_pt[0].y = ( short )( ydit - cross_delta_x[1] + 0.5 );
		    line_pt[1].x = ( short )( xdit + cross_delta_x[0] + 0.5 );
		    line_pt[1].y = ( short )( ydit + cross_delta_x[1] + 0.5 );

                    WLdraw_2D_line_string( win_no, 2, line_pt );

		    line_pt[0].x = ( short )( xdit - cross_delta_y[0] + 0.5 );
		    line_pt[0].y = ( short )( ydit - cross_delta_y[1] + 0.5 );
		    line_pt[1].x = ( short )( xdit + cross_delta_y[0] + 0.5 );
		    line_pt[1].y = ( short )( ydit + cross_delta_y[1] + 0.5 );

                    WLdraw_2D_line_string( win_no, 2, line_pt );

		 }
		 xdit += grid_delta_x[0];
		 ydit += grid_delta_x[1];
		 zdit += grid_delta_x[2];
	      }
	   }
	}

	WLshow_cursor( win_no );
	WLflush( win_no );

	return (status);
       }

