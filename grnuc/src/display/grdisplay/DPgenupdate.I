/*----
%GP% CODE CLASSIFICATION
-----
%HD%
        CLASS NAME:     IGEgragad
        METHOD NAME:    DPgen_update

        Abstract:      general update of a window
-----
%SC%
        IGEgraga.DPgen_update(&msg, &range, &upd_all,mode,erase)
-----
%EN%
        ON ENTRY:

        NAME      DATA TYPE             DESCRIPTION
       ------    -----------            ----------------------------
       *range    struct DPdit_range      area of window to be updated

       *update_all IGRboolean            used by hidden line windows

       mode	 enum GRdpmode		 the display mode

       erase	IGRboolean		 whether to erase the window.

-----
%EX%
        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
        *msg    IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed
-----
%MD%
        MODULES AND METHODS INVOKED:
        modu:    MAidmx()
                 MAtypemx()
                 MAoptxform()
        methods: GRwn.GRwnerase

-----
%RL%
        RELATIONS REFERENCED:
-----
%NB%
        NOTES:
-----
%CH%
        CHANGE HISTORY

        HT  05/8/86     : Design date.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

          This method is used to update a window.  The method
        calculate the range of window , use query plan to locate all
        elements in the window( with a passon message asking graphic
        object to expose itself. 

----*/
/*EH*/


class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "grimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "wl.h"

/* prototype files */
#include "GRdpbfunc.h"
#include "GRlcquery.h"
#include "dpmtxstack.h"
#include "dperase.h"
#include "dpclpstack.h"
#include "dpdiselem.h"

#include "maoptsxfo.h"
#include "maptsxfor.h"
#include "matypemx.h"

%safe
static IGRint (*DPapp_draw_ground_plane)( IGRlong *, struct GRid *, struct DPgra_gad *, int ) = NULL;

static IGRboolean winsup_chandef_defined = FALSE;
static OM_S_CHANSELECT winsup_chandef;
%endsafe

#ifdef	TIMING_TEST
long	dpdiselem_time;
long	dpgenupdate_time;
long	dpbcstrk_time;
long	dptxstrk_time;
long	dptxsetup_time;
long    dptxvwsetup_time;
long    dptxvwsetup_time2;
long	dpfs_time;
long	dpactstrk_time;
long	dptxgp_fill;
long    dpnumtxvec;

long	num_polys;
long	num_2_bsplines;
long	num_3_bsplines;
long	num_bspline_surfs;
long 	num_texts;
long	num_point_sets;
#endif

extern IGRboolean DPdynamic_update_in_progress;

from IGEwinsup import pre_update, post_update;

/*--- DPset_app_ground_plane_function -----------------------*/

void DPset_app_ground_plane_function( app_func )

	IGRint (*app_func)();

	{
	DPapp_draw_ground_plane = app_func;
	}  /* DPset_app_ground_plane_function */


/*--- DPdraw_ground_plane ------------------------------------*/

void DPdraw_ground_plane( /*win_id, win_os, gg_ptr )*/

	OM_S_OBJID       win_id,
	OMuword          win_os,
	struct DPgra_gad *gg_ptr )

	{
	IGRlong     msg;
	struct GRid gg_grid;
	
	if (DPapp_draw_ground_plane)
	   {
	   gg_grid.objid = win_id;
	   gg_grid.osnum = win_os;
	   (*DPapp_draw_ground_plane)( &msg, &gg_grid, gg_ptr, 0 );
	   }

	}  /* DPdraw_ground_plane */


method DPgen_update (IGRlong *msg; struct DPdit_range *range; 
                 IGRboolean *update_all; enum GRdpmode mode; IGRboolean erase)

{
   IGRint       sts;            /* OM return status         */
   IGRdouble    pt[24];         /* temporary variable       */
   IGRshort     k,i,j,ind; /* loop index               */
   IGRshort 	maxj;
   IGRdouble    min,max;
   IGRdouble    rng[6];         /* window range               */
   IGRdouble    rng1[6];        /* skew range (small range) */
   IGRdouble    tmp_range[4];
   IGRlong      num_pts = 8;    /* number of points         */

   IGRshort	rect = 0;
   IGRshort     front = 0;
   IGRshort     back = 0;


   enum GRlocate_types loc_type;
   struct GRlc_upd_loc loc_parms;
   struct GRmd_env     mdenv;
   struct DP_information dp_info;
   struct DPdit_range range1;
   struct DPdit_range *ditrng;
   struct GRid  gragad_id;
   OMuint count;
   IGRint quiet_flag;
#ifdef TIMING_TEST
   long	beg_time,end_time;
   double  diselem_time,genupdate_time,bcstrk_time,txstrk_time,total_time;
   double  txsetup_time,txvwsetup_time,fs_time,actstrk_time,gpfill_time;
#endif

#ifdef TIMING_TEST
   dpdiselem_time = 0;
   dpgenupdate_time = 0;
   dpbcstrk_time = 0;
   dptxstrk_time = 0;
   dptxsetup_time = 0;
   dptxvwsetup_time = 0;
   dptxvwsetup_time2 = 0;
   dpfs_time = 0;
   dpactstrk_time = 0;
   dptxgp_fill = 0;
   dpnumtxvec = 0;
   total_time = 0;

   num_polys = 0;
   num_2_bsplines = 0;
   num_3_bsplines = 0;
   num_bspline_surfs = 0;
   num_texts = 0;
   num_point_sets = 0;

   beg_time = clock();
#endif
	
   sts = OM_S_SUCCESS; 

   if ( ! DPdynamic_update_in_progress )
   {
      /* only check this stuff if not doing dynamics */
      if (ex$is_batch() || ige$SR_active())
      {
         goto end1;
      }

      if( !(ME.IGEgragad->gragad.flags & IS_ACTIVE))
      {
         goto end1;    /* window is not active ,exit */
      }

      ex$disp_flag( flag = &quiet_flag );

      if (quiet_flag)
      {
         goto end1;
      }

 /* if stop draw has been selected, don't update  */

      if (!range)
      {
         if (IGEstop())
         {
   	    goto end1;
         }
      }

      /* don't output "display in progress" message during       */
      /* "dynamic updates" because it screws up double buffering */
      ex$message( msgnumb = GR_I_DpProg );
   }

   if ( ! winsup_chandef_defined )
   {
      om$make_chanselect( channame = "IGEgragad.winsup", 
                          p_chanselect = &winsup_chandef );
		
      winsup_chandef_defined = TRUE;
   }
			
   gragad_id.objid = my_id;
   gragad_id.osnum = OM_Gw_current_OS;

   WLhide_cursor( ME.IGEgadget->win_no, FALSE );

   /* set blend pattern to solid */
   WLset_blendarea( ME.IGEgadget->win_no, NULL, TRUE );

   if ( range == NULL )
   {
      range1.xlo = ME.IGEgadget->min_x_dep;
      range1.ylo = ME.IGEgadget->min_y_dep;

      range1.xhi = ME.IGEgadget->max_x_dep;
      range1.yhi = ME.IGEgadget->max_y_dep;

      ditrng = &range1;
   }
   else
   {
     ditrng = range;

     if (!(ME.IGEgragad->gragad.flags & IS_PERSP))

     {

/*  Only update needed part of window.  The 3 is added and subtracted to  */
/*  in order to take into account the grid cross 			  */
/*  TOOK OUT CHANGE AND MOVED TO DPGRIDDRAW TO PICK UP GRID CENTER */
        tmp_range[0] = ME.IGEgragad->gragad.dit_clip_range[0];
        tmp_range[1] = ME.IGEgragad->gragad.dit_clip_range[1];
        tmp_range[2] = ME.IGEgragad->gragad.dit_clip_range[3];
        tmp_range[3] = ME.IGEgragad->gragad.dit_clip_range[4];

        if ((range->xlo) < tmp_range[0] )
        {
           ME.IGEgragad->gragad.dit_clip_range[0] = tmp_range[0];
        } 
        else
        {
           ME.IGEgragad->gragad.dit_clip_range[0] = range->xlo;
        }

        if ((range->ylo) < tmp_range[1])
        {
           ME.IGEgragad->gragad.dit_clip_range[1] = tmp_range[1];
        } 
        else
        {
           ME.IGEgragad->gragad.dit_clip_range[1] = range->ylo;
        }

        if ((range->xhi) > tmp_range[2])
        {
           ME.IGEgragad->gragad.dit_clip_range[3] = tmp_range[2];
        } 
        else
        {
           ME.IGEgragad->gragad.dit_clip_range[3] = range->xhi;
        }
     
        if ((range->yhi) > tmp_range[3])
        {
           ME.IGEgragad->gragad.dit_clip_range[4] = tmp_range[3];
        } 
        else
        {
           ME.IGEgragad->gragad.dit_clip_range[4] = range->yhi;
        }
     

        rect = ME.IGEgragad->gragad.flags & CLIP;
        front = ME.IGEgragad->gragad.flags & FRONT_CLIP;
        back = ME.IGEgragad->gragad.flags & BACK_CLIP;

        /* added vw_volume parameter for OPENGL setup for perspective */	
        DPpush_clip(msg,rect,front,back,ME.IGEgragad->gragad.dit_clip_range,
           ME.IGEgragad->gragad.gpipe_id, ME.IGEgragad->gragad.vw_volume);
     }

   }

   /*
   ** erase window
   */

   if (erase)
   {
      /*  If opengl and dynamics, dont erase hilite.  Stop VIC FLIC  */
#if defined (OPENGL)
      if( DPdynamic_update_in_progress )
      {
         WLset_drawing_mode( ME.IGEgadget->win_no, (WL_BASE_ERASE | WL_HILITE_NOOP)  );
      }
      else
#endif
      {
         WLset_drawing_mode( ME.IGEgadget->win_no, (WL_BASE_ERASE | WL_HILITE_ERASE ) );
      }

      if (! (DPerase(msg,&ME.IGEgadget->win_no, ditrng)) )
      {
#ifdef DEBUG            
         printf("\nError in dperase window\n");
#endif
         *msg = MSFAIL;
         goto wrapup;
      }

      WLset_drawing_mode( ME.IGEgadget->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

      /* check to see if needs grid */
      if( ME.IGEgragad->gragad.flags & GRID_ON)
      {
          sts = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgragad.DPgriddraw(msg, ditrng),
                     senderid = my_id,
                     targetid = my_id);



          if(!(1&sts))
          {
#ifdef DEBUG            
              printf("GRwn send to DPgriddraw error\n");
              om$report_error(sts = sts);
#endif
              goto wrapup;
          }

      }

      /* see if ground plane needs to be drawn */
      if ( ME.IGEgragad->gragad.flags & DP_GROUND_PLANE )
      {
         DPdraw_ground_plane( my_id, OM_Gw_current_OS, &ME.IGEgragad->gragad );
      }


   }  /* end of  if (erase) */

   /* get 8 corner points of dit clip range */
   pt[0] = pt[6] = pt[12] = pt[18] = ditrng->xlo;
   pt[1] = pt[4] = pt[13] = pt[16] = ditrng->ylo;
   pt[2] = pt[5] = pt[8] = pt[11] = ME.IGEgragad->gragad.dit_clip_range[2];
   pt[3] = pt[9] = pt[15] = pt[21] = ditrng->xhi;
   pt[7] = pt[10] = pt[19] = pt[22] = ditrng->yhi;
   pt[14] = pt[17] = pt[20] = pt[23] = ME.IGEgragad->gragad.dit_clip_range[5];

   /* transform 8 points to world coordinate system (wcs) */                                                                    
   MAptsxform( msg, &num_pts, (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld, pt, pt );

   /*
   **   get view range   (accumulate hi's and low's)
   */

   min = max = pt[0];
   i = 7;
   k = 3;
   while ( i > 0 )
   {
      if ( pt[k] < min )
      {
         min = pt[k];
      }
      else if ( pt[k] > max )
      {
         max = pt[k];
      }
      i--;
      k += 3;
   }

   rng[0] = min;
   rng[3] = max;

   min = max = pt[1];
   i = 7;
   k = 4;
   while ( i > 0 )
   {
      if ( pt[k] < min )
      {
         min = pt[k];
      }
      else if ( pt[k] > max )
      {
         max = pt[k];
      }
      i--;
      k += 3;
   }

   rng[1] = min;
   rng[4] = max;

   min = max = pt[2];
   i = 7;
   k = 5;
   while ( i > 0 )
   {
      if ( pt[k] < min )
      {
         min = pt[k];
      }
      else if ( pt[k] > max )
      {
         max = pt[k];
      }
      i--;
      k += 3;
   }

   rng[2] = min;
   rng[5] = max;

   loc_parms.is_ortho = 1;

   /*
   **   if skew then get skew range  
   */
   if ( ! (ME.IGEgragad->gragad.flags & AXIS_WLD_ALIGN))
   {
      loc_parms.is_ortho = 0;

      if (ME.IGEgragad->gragad.flags & IS_PERSP)
      {
	  j = 12;
	  maxj = 15;
          loc_parms.view_vector[0] = - ME.IGEgragad->gragad.rotation[2][0];
          loc_parms.view_vector[1] = - ME.IGEgragad->gragad.rotation[2][1];
          loc_parms.view_vector[2] = - ME.IGEgragad->gragad.rotation[2][2];

      }
      else
      {
	  maxj = 3;
	  j = 0;
          loc_parms.view_vector[0] = ME.IGEgragad->gragad.rotation[2][0];
          loc_parms.view_vector[1] = ME.IGEgragad->gragad.rotation[2][1];
          loc_parms.view_vector[2] = ME.IGEgragad->gragad.rotation[2][2];

      }

      ind = 0;
      while ( j < maxj )    /* for x,y,z coordinate */
      {
          min = max = pt[j];
          for (i = 0, k = j; i < 4; i++, k += 3)
          {
              if ( pt[k] < min )
              {
                 min = pt[k];
              }
              else if ( pt[k] > max )
              {
                 max = pt[k];
              }
          }
          rng1[ind] = min;
          rng1[ind + 3] = max;
      	  j++;
	  ind++;
      }
      loc_parms.upd_range2[0] = rng1[0];
      loc_parms.upd_range2[1] = rng1[1];
      loc_parms.upd_range2[2] = rng1[2];
      loc_parms.upd_range2[3] = rng1[3];
      loc_parms.upd_range2[4] = rng1[4];
      loc_parms.upd_range2[5] = rng1[5];
   }       
 
    /* get dpb information    */
    gr$get_module_env( buffer = (IGRchar *)&mdenv );

    if ( mdenv.md_id.osnum != OM_Gw_current_OS )
    {
       /* get module id for current OS because this might be  */
       /* the dreaded "place macro" window which isn't in the */
       /* master file                                         */
       ex$get_modid( mod_osnum = OM_Gw_current_OS,
                     mod_id = &mdenv.md_id.objid );

       mdenv.md_id.osnum = OM_Gw_current_OS;
    }

/*-----------------------------------------------------------------------*/
    /* call locate          */

    loc_type = GR_dlist_upd_loc;
    loc_parms.msg = MSSUCC;;
    loc_parms.mode = mode;
    loc_parms.alt_symb = NULL;

    sts = om$send( msg = message IGEgragad.DPupd_app_init(msg,&dp_info),
		      senderid = my_id,
		      targetid = my_id);

    if (!(sts & 1))
    {
#ifdef DEBUG            
        printf("Error in Window's DPupdate,  Error: ");
        om$report_error(sts = sts);
#endif
        *msg = MSFAIL;
        goto wrapup;
    }

    loc_parms.sp_info = &dp_info;

   loc_parms.upd_range[0] = rng[0];
   loc_parms.upd_range[1] = rng[1];
   loc_parms.upd_range[2] = rng[2];
   loc_parms.upd_range[3] = rng[3];
   loc_parms.upd_range[4] = rng[4];
   loc_parms.upd_range[5] = rng[5];

   sts = om$get_channel_count(objid = my_id, 
                              p_chanselect = &winsup_chandef, 
                              count = &count);
	
   if (!(sts & 1))
   {
      goto wrapup;
   }

    if (count)
    {
        sts = om$send(msg = message IGEwinsup.pre_update(msg, 
                                                         &gragad_id, &dp_info,&mdenv), 
                      senderid = my_id, 
                      p_chanselect = &winsup_chandef);
	    
        /* protect against unknown objects */
        if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

        if (!(sts & 1))
        {
#ifdef DEBUG            
	     printf("Error in Window's DPupdate,  Error: ");
             om$report_error(sts = sts);
#endif
             *msg = MSFAIL;
	     goto wrapup;
        }
				
    }

    if( ! GRlcquery(msg,&mdenv, &loc_type, (IGRchar *) &loc_parms,NULL,NULL,NULL) )
    {
      *msg = MSFAIL;
    }

    if (count)
    {
        sts = om$send(msg = message IGEwinsup.post_update(msg, &gragad_id), 
                      senderid = my_id, 
	              p_chanselect = &winsup_chandef);
	    
        /* protect against unknown objects */
        if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

        if (!(sts & 1))
        {
#ifdef DEBUG            
	    printf("Error in Window's DPupdate,  Error: ");
	    om$report_error(sts = sts);
#endif
	    *msg = MSFAIL;
	    goto wrapup;
	}
				
    }

    if ( (! DPdynamic_update_in_progress) && (! dp_info.is_hidden_line) )
    {
        ex$message ( msgnumb = GR_I_DpCmpl);
    }

wrapup0:

/*-----------------------------------------------------------------------*/


wrapup:
    if ((range) && !(ME.IGEgragad->gragad.flags & IS_PERSP))
    {
        ME.IGEgragad->gragad.dit_clip_range[0] = tmp_range[0];
        ME.IGEgragad->gragad.dit_clip_range[1] = tmp_range[1];
        ME.IGEgragad->gragad.dit_clip_range[3] = tmp_range[2];
        ME.IGEgragad->gragad.dit_clip_range[4] = tmp_range[3];

        /* added vw_volume parameter for OPENGL setup for perspective */	
        DPpush_clip(msg,rect,front,back,ME.IGEgragad->gragad.dit_clip_range,
	    ME.IGEgragad->gragad.gpipe_id, ME.IGEgragad->gragad.vw_volume);

    }

    WLshow_cursor( ME.IGEgadget->win_no );
#if defined( IRIX )
    if (! DPdynamic_update_in_progress) 
    {
       WLsync_buffers(  ME.IGEgadget->win_no );
    }
#endif
    WLflush( ME.IGEgadget->win_no );
     

#ifdef TIMING_TEST

    end_time = clock();
    dpgenupdate_time += (end_time - beg_time);

    printf("The totals of the times are:\n\n");

    total_time = dpgenupdate_time * 0.000001;
    genupdate_time = (dpgenupdate_time - dpdiselem_time) * 0.000001;
    diselem_time = (dpdiselem_time - dpbcstrk_time - dptxstrk_time) * 0.000001;
    bcstrk_time = dpbcstrk_time * 0.000001;
    txstrk_time = dptxstrk_time * 0.000001;
    txsetup_time = dptxsetup_time * 0.000001;
    txvwsetup_time = (dptxvwsetup_time + dptxvwsetup_time2) * 0.000001;
    fs_time = (dpfs_time - (dpactstrk_time + dptxvwsetup_time2)) * 0.000001;
    actstrk_time = dpactstrk_time * 0.000001;
    gpfill_time = dptxgp_fill *     0.000001;

    printf(" total time is : %f\n\n",total_time);
    printf(" DPgenupdate method: %f\n",genupdate_time);
    printf(" DPdiselem: %f\n",diselem_time);
    printf(" DPbcstrk: %f\n",bcstrk_time);
    printf(" DPtxstrk: %f\n",txstrk_time);
    printf(" text setup time: %f\n",txsetup_time);
    printf(" text view calculation: %f\n",txvwsetup_time);
    printf(" font server time: %f\n",fs_time);
    printf(" actual stroking time: %f\n\n",actstrk_time);
    printf(" actual gpfill_time: %f\n\n",gpfill_time);
    printf("%d text vectors \n",dpnumtxvec);

    printf("\n\nThe total number of elements displayed is:\n\n");

    printf("%d polylines\n",num_polys);
    printf("%d order 2 bspline curves\n",num_2_bsplines);
    printf("%d order 3 bspline curves\n",num_3_bsplines);
    printf("%d bspline surfaces\n",num_bspline_surfs);
    printf("%d text elements\n",num_texts);
    printf("%d point set elements\n",num_point_sets);
#endif
	
end1:

   return(sts);
}

method DPupd_app_init(IGRlong *msg; struct DP_information *dp_info)
{


    *msg = MSSUCC;

    dp_info->gragad = &ME.IGEgragad->gragad;
    dp_info->win_no = ME.IGEgadget->win_no;
    dp_info->is_update = TRUE;
    dp_info->is_fit = FALSE;
    dp_info->is_hidden_line = FALSE;

    dp_info->hline_info = NULL;
    dp_info->hl_tiler = NULL;
    dp_info->view_objid = my_id;
    dp_info->view_osnum = OM_Gw_current_OS;

    return(1);
}


end implementation IGEgragad;
