#include "igrtypedef.h"
#include "igewindef.h"
#ifdef ENV5
#include <tools.h>
#endif
#include "igeterm.h"
#ifdef X11
#include "OMminimum.h"
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include "wl.h"
#include "cm.h"
extern Display *EXdisplay;
#endif

extern struct  IGEterm_info	term_info;
#ifdef ENV5
static IGRint  hl_ability[2];
#endif

void  IGEget_num_screens(type,num_screens)

   IGRint	type;
   IGRint	*num_screens;

    {


	if (num_screens)
	{
	   if (type == 0)
	   {
	      *num_screens = term_info.num_of_screens;
	   }
	   else
	   {
	      *num_screens = term_info.num_phy_screens;
	   }
	}
    }

void	IGEinq_term_info(screen_no,bg_planes,hilite_plane,vs_no,num_of_planes,
			 plane_mask,vlt_size,dac_size,x_extent,y_extent,
			 fixed_vlt_start,fixed_vlt_size,db_enabled,zb_enabled,
			 sr_vlt_enabled)

   IGRint	screen_no;
   IGRint	*bg_planes;
   IGRint	*hilite_plane;
   IGRint	*vs_no;
   IGRint	*num_of_planes;
   IGRint	*plane_mask;
   IGRint	*vlt_size;
   IGRint	*dac_size;
   IGRint	*x_extent;
   IGRint	*y_extent;
   IGRint	*fixed_vlt_start;
   IGRint	*fixed_vlt_size;
   IGRint	*db_enabled;
   IGRint	*zb_enabled;
   IGRint	*sr_vlt_enabled;

    {

      struct  IGEscreen_info	*scn_info;

	if (screen_no == IGE_RIGHT_SCREEN)
	{
	   scn_info = &term_info.r_scn;
	}
	else
	{
	   scn_info = &term_info.l_scn;
	}

	if (bg_planes)
	{
	   *bg_planes = scn_info->bckgnd_planes;
	}

	if (hilite_plane)
	{
	   *hilite_plane = scn_info->hilite_plane;
	}

	if (vs_no)
	{
	   *vs_no = scn_info->vs_no;
	}

	if (num_of_planes)
	{
	   *num_of_planes = scn_info->num_planes;
	}
	
	if (plane_mask)
	{
	   *plane_mask = scn_info->plane_mask;
	}

	if (vlt_size)
	{
	   *vlt_size = scn_info->vlt_size;
	}

	if (dac_size)
	{
	   *dac_size = scn_info->dac_size;
	}

	if (x_extent)
	{
	   *x_extent = scn_info->x_extent;
	}

	if (y_extent)
	{
	   *y_extent = scn_info->y_extent;
	}

	if (fixed_vlt_start)
	{
	   *fixed_vlt_start = scn_info->fixed_vlt_start;
	}

	if (fixed_vlt_size)
	{
	   *fixed_vlt_size = scn_info->fixed_vlt_size;
	}

	if (db_enabled)
	{
	   *db_enabled = scn_info->db_enabled;
	}

	if (zb_enabled)
	{
	   *zb_enabled = scn_info->zb_enabled;
	}

	if (sr_vlt_enabled)
	{
	   *sr_vlt_enabled = scn_info->sr_vlt_enabled;
	}


    }

IGRint	IGEload_term_info()

    {


      IGRint		i;
#ifdef ENV5
      IGRint		right_vs = -1;
      IGRint		left_vs = -1;
      IGRint		num_phy_screens = 0;
      IGRboolean	not_done;
#endif
      IGRint		num_screens = 0;
      IGRint		tmp_int;
      IGRint		error = FALSE;
#ifdef X11
      int               status;
      int               lscreen_type;
      WLuint16          lscreen;
      WLuint32          ctx_num;
      int               depth;
      Visual            *visual;
      struct WLnative_info native_info;
#endif

#ifdef ENV5

      struct  scr_info  dep_scr_info[MAX_SCREENS];

      Inq_screen_info(dep_scr_info);

      not_done = TRUE;
#endif

      i = 0;

#ifdef X11
       status = WLget_active_screen ( &lscreen, &lscreen_type );
       if (status != WL_SUCCESS)
       {
          return (-1);
       }

       status = CMget_active_context ( lscreen, &ctx_num );
       if (status != CM_SUCCESS)
       {
          return (-1);
       }

       status = WLget_native_info_from_context ( lscreen, ctx_num, &native_info );
       if (status != WL_SUCCESS)
       {
          return (-1);
       }

       num_screens = ScreenCount( EXdisplay );
       depth = DisplayPlanes ( EXdisplay, native_info.screen );
       visual = native_info.visual;
       
   /* find high order bit for highlight  */
     
           term_info.r_scn.hilite_plane = 1 << ( depth - 1 );
           term_info.r_scn.bckgnd_planes = (1 << (depth - 1) ) - 1;
	   term_info.r_scn.vs_no = 0;
	   term_info.r_scn.num_planes = depth;
	   term_info.r_scn.plane_mask = (1 << depth ) - 1;
	   term_info.r_scn.vlt_size = visual->map_entries;
           if( depth < 8)
	   {
     	      term_info.r_scn.dac_size = 4;
	      term_info.r_scn.fixed_vlt_start = 0;
              term_info.r_scn.fixed_vlt_size = 0;
	      term_info.r_scn.sr_vlt_enabled = 16;
	   }
	   else
	   {
              term_info.r_scn.dac_size = 8;
	      term_info.r_scn.fixed_vlt_start = 1;
              term_info.r_scn.fixed_vlt_size = 14;
              term_info.r_scn.sr_vlt_enabled = 0;
	   }
	   term_info.r_scn.x_extent = DisplayWidth(EXdisplay,0);
	   term_info.r_scn.y_extent = DisplayHeight(EXdisplay,0);
	   term_info.r_scn.db_enabled = 0;
	   term_info.r_scn.zb_enabled = 0;


        if (num_screens == 2)
        {

   /* find high order bit for highlight  */

           term_info.l_scn.hilite_plane = 1 << ( depth - 1 );
           term_info.l_scn.bckgnd_planes = (1 << (depth - 1) ) - 1;
	   term_info.l_scn.vs_no = 1;
	   term_info.l_scn.num_planes = depth;
	   term_info.l_scn.plane_mask = (1 << depth ) - 1;
	   term_info.l_scn.vlt_size = visual->map_entries;
           if( depth < 8)
	   {
     	      term_info.l_scn.dac_size = 4;
	      term_info.l_scn.fixed_vlt_start = 0;
              term_info.l_scn.fixed_vlt_size = 0;
	      term_info.l_scn.sr_vlt_enabled = 16;
	   }
	   else
	   {
              term_info.l_scn.dac_size = 8;
	      term_info.l_scn.fixed_vlt_start = 1;
              term_info.l_scn.fixed_vlt_size = 14;
              term_info.l_scn.sr_vlt_enabled = 0;
	   }
	   term_info.l_scn.x_extent = DisplayWidth(EXdisplay,1);
	   term_info.l_scn.y_extent = DisplayHeight(EXdisplay,1);
	   term_info.l_scn.db_enabled = 0;
	   term_info.l_scn.zb_enabled = 0;


	}


        term_info.num_of_screens = num_screens;	
        term_info.num_phy_screens = num_screens;	
#endif
#ifdef ENV5
	while ((i < MAX_SCREENS) && not_done)
	{
	   if (dep_scr_info[i].vsi_screen_num != -1)
	   {
	      if ( dep_scr_info[i].vsi_flags & VSI_VIRTUAL_SCREEN)
	      {
		 num_screens++;
		 if ( num_screens < 3)
		 {
		    if (dep_scr_info[i].vsi_flags & VSI_LEFT_SCREEN)
		    {
		       num_phy_screens++;
		       if (left_vs == -1)
		       {
			  left_vs = i;
	                  term_info.l_scn.db_enabled = dep_scr_info[left_vs].vsi_flags  &
	   			     			VSI_DB_ABILITY;

		       }
		       else
		       {
			  error = TRUE;
			  not_done = FALSE;
		       }
		    } 
		    else  /* else of if (... & VSI_LEFT_SCREEN)  */
		    {
		       if (right_vs == -1)
		       {
			  num_phy_screens++;
			  right_vs = i;
		       }
		       else
		       {
			  left_vs = i;
		       }
		    }
		 }
		 else /* else of if (num_screens < 3)   */
		 {
		    error = TRUE;
		    not_done = FALSE;
		 }
		       
	      } /* end of then part of if ( ... & VSI_VIRTUAL SCREEN) */

	   }  /* end of then part of if (...screen_num ==-1) */
	   else
	   {
	      not_done = FALSE;
	   } /* end of else of if ( ...screen_num == -1)  */

	   i++;
	}  /* end of while (i < MAX_SCREENS ... */
	

   /* find high order bit for highlight  */
     
	if (!error)
	{
	   i = 31;
	   not_done = TRUE;
	   tmp_int = dep_scr_info[right_vs].vsi_plane_mask;

	   while ( (i >= 0 ) && not_done)
	   {
	      if (tmp_int & 0x80000000)
	      {
	         term_info.r_scn.hilite_plane = (1 << i );
	         term_info.r_scn.bckgnd_planes = 
	   				dep_scr_info[right_vs].vsi_plane_mask &
	   				   (~ term_info.r_scn.hilite_plane);
	         not_done = FALSE;
	      }
	      else
	      {
	         tmp_int <<= 1;
	         i--;
	      }
	   }

	   term_info.r_scn.vs_no = right_vs;
	   term_info.r_scn.num_planes = dep_scr_info[right_vs].vsi_num_planes;
	   term_info.r_scn.plane_mask = dep_scr_info[right_vs].vsi_plane_mask;
	   term_info.r_scn.vlt_size = dep_scr_info[right_vs].vsi_VLT_size;
	   term_info.r_scn.dac_size = dep_scr_info[right_vs].vsi_DAC_size;
	   term_info.r_scn.x_extent = dep_scr_info[right_vs].vsi_x;

	   term_info.r_scn.y_extent = dep_scr_info[right_vs].vsi_y;

/*	   Inq_message_location(right_vs,&msg_status);
	   
	   if (msg_status)
	   {
	      term_info.r_scn.y_extent -= MESSAGE_STRIP_HEIGHT;
	   }
*/

	   if (dep_scr_info[right_vs].vsi_flags & VSI_VLT_FIXED)
	   {
               term_info.r_scn.fixed_vlt_start = 
                                       dep_scr_info[right_vs].vsi_fixed_vlt_start;
               term_info.r_scn.fixed_vlt_size = 
                                       dep_scr_info[right_vs].vsi_fixed_vlt_size;
	   }
	   else
	   {
               term_info.r_scn.fixed_vlt_start = 0;
               term_info.r_scn.fixed_vlt_size = 0;
	   }

	   term_info.r_scn.db_enabled = dep_scr_info[right_vs].vsi_flags  &
	   			     VSI_DB_ABILITY;

	   term_info.r_scn.zb_enabled = dep_scr_info[right_vs].vsi_flags  &
	   			     VSI_ZB_ABILITY;

	   term_info.r_scn.sr_vlt_enabled = dep_scr_info[right_vs].vsi_flags  &
	   			     VSI_SR_VLT_ABILITY;

	   hl_ability[0] = dep_scr_info[right_vs].vsi_flags & VSI_HL;

	   if (num_screens == 2)
	   {
	   

   /* find high order bit for highlight  */

	      i = 31;
	      not_done = TRUE;
	      tmp_int = dep_scr_info[left_vs].vsi_plane_mask;

	      while ( (i >= 0 ) && not_done)
	      {
	         if (tmp_int & 0x80000000)
	         {
	   	    term_info.l_scn.hilite_plane = (1 << i );
	            term_info.l_scn.bckgnd_planes = 
	   				dep_scr_info[left_vs].vsi_plane_mask &
	   				   (~ term_info.l_scn.hilite_plane);
	   	    not_done = FALSE;
	         }
	         else
	         {
	   	    tmp_int <<= 1;
	   	    i--;
	         }
	      }

	      term_info.l_scn.vs_no = left_vs;
	      term_info.l_scn.num_planes = dep_scr_info[left_vs].vsi_num_planes;
	      term_info.l_scn.plane_mask = dep_scr_info[left_vs].vsi_plane_mask;
	      term_info.l_scn.vlt_size = dep_scr_info[left_vs].vsi_VLT_size;
	      term_info.l_scn.dac_size = dep_scr_info[left_vs].vsi_DAC_size;
	      term_info.l_scn.x_extent = dep_scr_info[left_vs].vsi_x;
	      term_info.l_scn.y_extent = dep_scr_info[left_vs].vsi_y;

/*	      Inq_message_location(left_vs,&msg_status);
	   
	      if (msg_status)
	      {
	         term_info.l_scn.y_extent -= MESSAGE_STRIP_HEIGHT;
	      }
*/
	      if (dep_scr_info[left_vs].vsi_flags & VSI_VLT_FIXED)
	      {

                  term_info.l_scn.fixed_vlt_start = 
                                       dep_scr_info[left_vs].vsi_fixed_vlt_start;
                  term_info.l_scn.fixed_vlt_size = 
                                       dep_scr_info[left_vs].vsi_fixed_vlt_size;
	      }
	      else
	      {
                  term_info.l_scn.fixed_vlt_start = 0; 
                  term_info.l_scn.fixed_vlt_size = 0;
	      }

	      term_info.l_scn.db_enabled = dep_scr_info[left_vs].vsi_flags  &
	   			     VSI_DB_ABILITY;

	      term_info.l_scn.zb_enabled = dep_scr_info[left_vs].vsi_flags  &
	   			     VSI_ZB_ABILITY;

	      term_info.l_scn.sr_vlt_enabled = dep_scr_info[left_vs].vsi_flags  &
	   			     VSI_SR_VLT_ABILITY;

	      hl_ability[1]= dep_scr_info[left_vs].vsi_flags  &
	   			     VSI_HL;

	   }
	   
	   term_info.num_of_screens = num_screens;	
	   term_info.num_phy_screens = num_phy_screens;	
        }
#endif

	if (term_info.r_scn.num_planes < 5)
	{
	   error = TRUE;
	   goto wrapup;
	}

#ifdef X11
	if (num_screens > 1)
	{
           if (term_info.l_scn.num_planes < 5)
	   {
	      error = TRUE;
	   }
	}
#endif

wrapup:	     
 	return(!error);

     }

IGRint IGEhlability()

{
#ifdef ENV5
	return(hl_ability[0]);
#endif
#ifdef X11
	printf("IGEhlability not supported under X\n");
	return -1;
#endif
}

