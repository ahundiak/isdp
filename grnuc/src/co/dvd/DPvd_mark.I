class implementation DPvd;

/*
** DPvd_mark.I - mark, restore and journal view information for 
**               display view dynamics
*/
#include <stdio.h>
#include <math.h>
#include "bsdefs.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exlocale.h"
#include "msdef.h"
#include "msmacros.h"

#include "ex.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "go.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "journal.h"

#include "wl.h"

#include "DPvd.h"

#if defined( X11 )
/* 
On X11, there is no USER_EVENT event as in ENV5. So use KeyRelease 
as xevent.type to cheat the system. Cannot use LASTEvent+1 because 
JNL_XNextEvent() only put known event to the next journal file.
*/
#define DPvd_JNL_XEVENT KeyRelease /* (LASTEvent+1) */
#define USER_EVENT 0x00004000
extern Display *EXdisplay;
#endif

%safe
static struct save_view *list_of_views;
static int n_list_of_views = 0;
%endsafe


/* ------- static routines ------------------------------------------*/


/*--- save_gragad ----------------------------------------*/
static int save_gragad(struct GRid *actid, struct save_DPgra_gad *save_buf)
/*
NAME
	save_gragad

DESCRIPTION
	copy all gragad information, which is to save, into the save buffer.

SYNOPSIS
        static int save_gragad(struct GRid *actid, struct save_DPgra_gad *save_buf)

PARAMETERS
        actid (IN)        - the object  id of the window
                              which should be saved.
        save_buf(OUT)     - A pointer to the structure, which will be
                            set with all information to save.

GLOBALS USED
	none

RETURN VALUES
        1 - success
        0 - cannot read gragad info

NOTES

HISTORY
	07/16/93    G.Werner       save_gragad
	            Creation Date
*/
{
        IGRlong             msg;
        IGRint              sts;
        struct var_list     inq_array[2];
        IGRlong             nbytes_ret;
        IGRlong             error_var;
        struct DPgra_gad    local_gragad;


        /* read the gragad info */

        inq_array[0].var = GRAGAD_STRUCT;
        inq_array[0].var_ptr = (char *) &local_gragad;
        inq_array[0].num_bytes = sizeof(struct DPgra_gad);
        inq_array[0].bytes_returned = &nbytes_ret;
        inq_array[1].var = END_PARAM;
    
        sts = dp$inq_set_gragad(msg = &msg,
			    gragad_objid = actid->objid,
			    osnum = actid->osnum,
			    which_error = &error_var,
			    var_list = inq_array);
        if(!(sts&msg&1)) 
        {
#ifdef DEBUG
	    printf("Cannot get gragad info for window %d\n", actid->objid);
#endif
            return 0;
        }

        /* copy needed information to save_buf */

        save_buf->flags = local_gragad.flags;  	   /* view flags       */
#ifdef UNUSED
!	save_buf->fnt_os_ptr = local_gragad.fnt_os_ptr;/* font os ptr      */
!       save_buf->grid_per_ref_x = local_gragad.grid_per_ref_x;          
!						   /* # of grid dots
!                                                      between x-axis 
!						      cross  	       */
!	save_buf->grid_per_ref_y = local_gragad.grid_per_ref_y;	   /* # of grid dots 
!						      between y-axis
!						      cross	       */
!	save_buf->wld_viewport_type = local_gragad.wld_viewport_type;	   /* world to viewport
!						      matrix type      */
!       save_buf->display_mode = local_gragad.display_mode;              /* which type display
!							is to take place */
!
!       memcpy(&save_buf->levels,&local_gragad.levels,sizeof(IGRint)*32);
!						   /* levels	       */
!	save_buf->gpipe_id = local_gragad.gpipe_id;
!       save_buf->uor_per_ref_x = local_gragad.uor_per_ref_x;
!					           /* uor value between
!                                                     grid reference
!						      x-axis crosses   */
!      save_buf->uor_per_ref_y = local_gragad.uor_per_ref_y;
!					           /* uor value between
!                                                     grid reference
!						      y-axis crosses   */
#endif
       save_buf->origin[0] = local_gragad.origin[0];   /* view origin      */
       save_buf->origin[1] = local_gragad.origin[1];   /* view origin      */
       save_buf->origin[2] = local_gragad.origin[2];   /* view origin      */
       memcpy(&save_buf->rotation, &local_gragad.rotation, 
		sizeof(IGRdouble) *4*4);            /* view rotation matrix */
       memcpy(&save_buf->vw_volume,&local_gragad.vw_volume,
		sizeof(IGRdouble) * 6);             /* view volume */
       save_buf->act_z = local_gragad.act_z;           /* active z in viewing 
						       coordinate system*/
#ifdef UNUSED
!      save_buf->act_z_screen = local_gragad.act_z_screen;/* active z in screen
!                                                      coordinate       */
!      save_buf->dit_tol = local_gragad.dit_tol; /* dit tolerance    */
!      memcpy(&save_buf->wld_to_viewport,&local_gragad.wld_to_viewport,
!		sizeof(IGRdouble) *4*4);   /* world to viewport 
!                                                      transformation
!                                                      matrix           */
!      memcpy(&save_buf->viewport_to_wld,&local_gragad.viewport_to_wld,
!		sizeof(IGRdouble) *4*4);   /* viewport to world
!                                                      transformation
!                                                      matrix           */
!      memcpy(&save_buf->alt_vwport_to_wld,&local_gragad.alt_vwport_to_wld,
!		sizeof(IGRdouble) * 4*4);           /* alternate viewport 
!				to world transformation matrix           */
!      memcpy(&save_buf->construct_plane,&local_gragad.construct_plane,
!		sizeof(IGRdouble) * 4*4);           /* construction plane 
!						       matrix     */
!      memcpy(&save_buf->wld_to_view,&local_gragad.wld_to_view,
!		sizeof(IGRdouble) * 4*4);           /* viewport to view 
!						       transformation   */
#endif
       memcpy(&save_buf->dit_clip_range,&local_gragad.dit_clip_range,
		sizeof(IGRdouble) * 6);             /* dit clip range in */
#ifdef UNUSED
!      save_buf->vvol_viewport_scale = local_gragad.vvol_viewport_scale;     
!					/* view volume to viewport scale   */
#endif
/**********  Perspective data *****************************************/
       memcpy(&save_buf->eye_pt, &local_gragad.eye_pt,
		sizeof(IGRdouble) *3);		  /* eye point for perspective*/
       memcpy(&save_buf->coi, &local_gragad.coi,
		sizeof(IGRdouble) *3);		  /*  center of interest */
       save_buf->vw_angle = local_gragad.vw_angle;	  /*  view angle       */
       memcpy(&save_buf->vrp, &local_gragad.vrp,
		sizeof(IGRdouble) *3);		  /* view reference point */
       memcpy(&save_buf->vpn, &local_gragad.vpn,
		sizeof(IGRdouble) *3);		  /* view plane normal    */
       memcpy(&save_buf->vup, &local_gragad.vup,
		sizeof(IGRdouble) *3);		  /* view up vector     */
  /**********************************************************************/
#ifdef UNUSED
!      save_buf->range_chk = local_gragad.range_chk;	/* used for range
!						      checking	       */
!
!      save_buf->vv_range_chk = local_gragad.vv_range_chk; /* used for range
!						      checking	       */
#endif
 
        return 1;
}



/*--- reset_gragad ----------------------------------------*/

static int reset_gragad(struct GRid *actid, struct save_DPgra_gad *view_to_change)
/*
NAME
	reset_gragad

DESCRIPTION
	Restore gragad information with content of given parameter

SYNOPSIS
        static int reset_gragad(struct GRid *actid, struct save_DPgra_gad *view_to_change)

PARAMETERS
        actid (IN)        - the object  id of the window
                              which should be changed.
        view_to_change(IN)- the gragad information which is to set.

GLOBALS USED
	none

RETURN VALUES
        1 - success
        0 - error, could not set gragad info

NOTES

HISTORY
	07/07/93    G.Werner       reset_gragad
	            Creation Date
*/
{
    IGRlong             msg;
    IGRint              sts;
    struct var_list     inq_array[2];
    IGRlong             nbytes_ret;
    IGRlong             error_var;
    struct DPgra_gad    local_view;


    /* get the view type of the current view  */
    inq_array[0].var = GRAGAD_FLAGS;
    inq_array[0].var_ptr = (char *)&local_view.flags;
    inq_array[0].num_bytes = sizeof(IGRint);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;
		    
    sts = dp$inq_set_gragad(msg = &msg,
			   osnum       = actid->osnum ,
			   gragad_objid= actid->objid ,
			   which_error = &error_var,
			   var_list    = inq_array);
    if(!(sts&1))
    {
#ifdef DEBUG
		printf("Cannot get gragad info.\n");
#endif
		return 0;
    }

    /* Check the view type (perspective, parallel) */

    if((view_to_change->flags&IS_PERSP) && !(local_view.flags&IS_PERSP))
    {
	/* Convert local_view to Perspective */
	sts = dp$set_persp(msg = &msg,
			   gg_id = actid,
			   in_flags = DP_CVT_WN_ONLY|DP_STD_DEFAULTS);
	if(!(sts&msg&1)) return 0;
    }
    else if(!(view_to_change->flags&IS_PERSP) && (local_view.flags&IS_PERSP))
    {
	/* Convert local_view to Parallel */
	sts = dp$un_persp(msg = &msg, 
			  gg_id=actid);
	if(!(sts&msg&1)) return 0;
    }
    
    /* get the current gragad info after converting to persp or parallel view */
    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (char *)&local_view;
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;
		    
    sts = dp$inq_set_gragad(msg = &msg,
			   osnum       = actid->osnum ,
			   gragad_objid= actid->objid ,
			   which_error = &error_var,
			   var_list    = inq_array);
    if(!(sts&1))
    {
#ifdef DEBUG
		printf("Cannot get gragad info.\n");
#endif
		return 0;
    }

    /* change all gragad info, which has not to be restored */

#ifdef UNUSED
!    local_view.flags = (local_view.flags & ~(IS_PERSP)) |
!			      (view_to_change->flags &  (IS_PERSP)) ;
!
!   local_view.fnt_os_ptr = view_to_change->fnt_os_ptr;
!   local_view.grid_per_ref_x = view_to_change->grid_per_ref_x;
!   local_view.grid_per_ref_y = view_to_change->grid_per_ref_y;
!   local_view.wld_viewport_type = view_to_change->wld_viewport_type;
!   local_view.display_mode = view_to_change->display_mode;
!   memcpy(&local_view.levels , &view_to_change->levels, 
!						32 * sizeof(IGRint));
!   local_view.gpipe_id = view_to_change->gpipe_id;
!   local_view.uor_per_ref_x = local_view.uor_per_ref_x;
!   local_view.uor_per_ref_y = local_view.uor_per_ref_y;
#endif
    memcpy(&local_view.origin, &view_to_change->origin,
		sizeof(IGRdouble) * 3);
    memcpy(&local_view.rotation, &view_to_change->rotation,
		sizeof(IGRdouble) * 4*4);
    memcpy(&local_view.vw_volume, &view_to_change->vw_volume,
		sizeof(IGRdouble) * 6);
    local_view.act_z = view_to_change->act_z;
#ifdef UNUSED
!   local_view.act_z_screen = view_to_change->act_z_screen;
!   local_view.dit_tol = view_to_change->dit_tol;
!   memcpy(&local_view.wld_to_viewport, &view_to_change->wld_to_viewport,
!		sizeof(IGRdouble) * 4*4);
!   memcpy(&local_view.viewport_to_wld, &view_to_change->viewport_to_wld,
!		sizeof(IGRdouble) * 4*4);
!   memcpy(&local_view.alt_vwport_to_wld, &view_to_change->alt_vwport_to_wld,
!		sizeof(IGRdouble) * 4*4);
!   memcpy(&local_view.construct_plane, &view_to_change->construct_plane,
!		sizeof(IGRdouble) * 4*4);
!   memcpy(&local_view.wld_to_view, &view_to_change->wld_to_view,
!		sizeof(IGRdouble) * 4*4);
#endif
    memcpy(&local_view.dit_clip_range, &view_to_change->dit_clip_range,
		sizeof(IGRdouble) * 6);
#ifdef UNUSED
!   local_view.vvol_viewport_scale = view_to_change->vvol_viewport_scale;
#endif
    memcpy(&local_view.eye_pt, &view_to_change->eye_pt,
		sizeof(IGRdouble) * 3);
    memcpy(&local_view.coi, &view_to_change->coi,
		sizeof(IGRdouble) * 3);
    local_view.vw_angle = view_to_change->vw_angle;
    memcpy(&local_view.vrp, &view_to_change->vrp,
		sizeof(IGRdouble) * 3);
    memcpy(&local_view.vpn, &view_to_change->vpn,
		sizeof(IGRdouble) * 3);
    memcpy(&local_view.vup, &view_to_change->vup,
		sizeof(IGRdouble) * 3);
#ifdef UNUSED
!   local_view.range_chk = view_to_change->range_chk;
!   local_view.vv_range_chk = view_to_change->vv_range_chk;
#endif

	   
    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (char *)&local_view;
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;
		    
    sts = dp$inq_set_gragad(msg = &msg,
			   inq0_set1 = 1,
			   calc_info = 1, 
			   update = 1,
			   osnum = actid->osnum ,
			   gragad_objid = actid->objid ,
			   which_error  = &error_var,
			   var_list = inq_array);

   return OM_S_SUCCESS;
}


/*--- DPvd_is_same_view ----------------------------------------*/

static int DPvd_is_same_view(struct save_DPgra_gad *view_to_change,
			     struct DPgra_gad *local_view)
/*
NAME
	DPvd_is_same_view 

DESCRIPTION
	Compare if the two views are the same. 

SYNOPSIS
        static int DPvd_is_same_view(struct save_DPgra_gad *view_to_change,
	  		             struct DPgra_gad *local_view)

PARAMETERS
        view_to_change (IN) - the gragad to compare
        local_view(IN) - the gragad to compare

GLOBALS USED
	none

RETURN VALUES
        1 - same view setting
        0 - diff view setting

NOTES

HISTORY
	08/23/93    T. Wang
	            Creation Date, 
*/

{
    IGRint i,j;
    
    if((view_to_change->flags&IS_PERSP)!=(local_view->flags&IS_PERSP))
      return 0;
    
#define DPvd_IS_EQUAL(d1,d2) ((d1-d2)<0.00000000000001 && (d1-d2)> -0.00000000000001)

    for(i=0;i<4;i++)
    {
	for(j=0;j<4;j++)
        {
	    if(!DPvd_IS_EQUAL(view_to_change->rotation[i][j],local_view->rotation[i][j]))
	       return 0;
        }
    }

    if(!DPvd_IS_EQUAL(view_to_change->act_z,local_view->act_z)) return 0;

    for(i=0;i<6;i++)
    {
	if(!DPvd_IS_EQUAL(view_to_change->vw_volume[i],local_view->vw_volume[i]))
	  return 0;
    }
    
    if(view_to_change->flags&IS_PERSP)
    {
	if(!DPvd_IS_EQUAL(view_to_change->vw_angle,local_view->vw_angle))
	  return 0;

	for(i=0;i<3;i++)
	{
	    if(!DPvd_IS_EQUAL(view_to_change->eye_pt[i],local_view->eye_pt[i]))
	      return 0;
	    if(!DPvd_IS_EQUAL(view_to_change->coi[i],local_view->coi[i]))
	      return 0;
	    if(!DPvd_IS_EQUAL(view_to_change->vpn[i],local_view->vpn[i]))
	      return 0;
	    if(!DPvd_IS_EQUAL(view_to_change->vup[i],local_view->vup[i]))
	      return 0;
	    if(!DPvd_IS_EQUAL(view_to_change->vrp[i],local_view->vrp[i]))
	      return 0;
	}
    }
    else
    {
	for(i=0;i<3;i++)
	{
	    if(!DPvd_IS_EQUAL(view_to_change->origin[i],local_view->origin[i]))
	      return 0;
	}
    }
    
    return 1;
}


/* ------ external routines ----------------------------------------*/

#ifdef DEBUG
/*--- DPvd_print_jnl_info -----------------------------------*/

void DPvd_print_jnl_info( struct jnl_storage local_jnl )

/*
NAME
	DPvd_print_jnl_info

DESCRIPTION
        This function writes the contents of a jnl_storage variable for 
	debugging purposes.

SYNOPSIS
	void DPvd_print_jnl_info( struct jnl_storage local_jnl )

PARAMETERS
	local_jnl(IN)      The journal information to print out

GLAOBALS USED
	none

RETURN VALUES
	none

HISTORY
	8/10/94 - B. Druzynski  Creation Date
*/
{
fprintf( stderr, "local_jnl\n");
fprintf( stderr, "---------\n");
fprintf( stderr, "   local_jnl.grid.osnum = %d\n", local_jnl.grid.osnum);
fprintf( stderr, "   local_jnl.grid.objid = %d\n", local_jnl.grid.objid);
fprintf( stderr, "   local_jnl.gragad.flags = %d\n", local_jnl.gragad.flags);
fprintf( stderr, "   local_jnl.gragad.origin = %f  %f  %f\n",
                     local_jnl.gragad.origin[0],
                     local_jnl.gragad.origin[1],
                     local_jnl.gragad.origin[2]);
fprintf( stderr, "   local_jnl.gragad.rotation = %f  %f  %f  %f\n",
                     local_jnl.gragad.rotation[0][0],
                     local_jnl.gragad.rotation[0][1],
                     local_jnl.gragad.rotation[0][2],
                     local_jnl.gragad.rotation[0][3]);
fprintf( stderr, "                            %f  %f  %f  %f\n",
                     local_jnl.gragad.rotation[1][0],
                     local_jnl.gragad.rotation[1][1],
                     local_jnl.gragad.rotation[1][2],
                     local_jnl.gragad.rotation[1][3]);
fprintf( stderr, "                            %f  %f  %f  %f\n",
                     local_jnl.gragad.rotation[2][0],
                     local_jnl.gragad.rotation[2][1],
                     local_jnl.gragad.rotation[2][2],
                     local_jnl.gragad.rotation[2][3]);
fprintf( stderr, "                            %f  %f  %f  %f\n\n",
                     local_jnl.gragad.rotation[3][0],
                     local_jnl.gragad.rotation[3][1],
                     local_jnl.gragad.rotation[3][2],
                     local_jnl.gragad.rotation[3][3]);

fprintf( stderr, "   local_jnl.gragad.vw_volume = %f %f %f\n",
                     local_jnl.gragad.vw_volume[0],
                     local_jnl.gragad.vw_volume[1],
                     local_jnl.gragad.vw_volume[2] );
fprintf( stderr, "                             %f %f %f\n\n",
                     local_jnl.gragad.vw_volume[3],
                     local_jnl.gragad.vw_volume[4],
                     local_jnl.gragad.vw_volume[5] );

fprintf( stderr, "   local_jnl.gragad.act_z = %f\n", local_jnl.gragad.act_z);
 
fprintf( stderr, "   local_jnl.gragad.dit_clip_range = %f %f %f\n",
                     local_jnl.gragad.dit_clip_range[0],
                     local_jnl.gragad.dit_clip_range[1],
                     local_jnl.gragad.dit_clip_range[2] );
fprintf( stderr, "                             %f %f %f\n\n",
                     local_jnl.gragad.dit_clip_range[3],
                     local_jnl.gragad.dit_clip_range[4],
                     local_jnl.gragad.dit_clip_range[5] );
}
#endif

/*--- DPvd_mark_view ----------------------------------------*/

int DPvd_mark_view(int original, struct GRid *actid, struct save_DPgra_gad *in_save_buf)

/*
NAME
	DPvd_mark_view

DESCRIPTION
	This function stores the window/view information for
        later restore.

SYNOPSIS
	extern int DPvd_mark_view(int original, struct GRid *actid)

PARAMETERS
        original(IN)       - TRUE - store as original view,
                             FALSE - store as marked view.
        actid (IN)         - the object  id of the window
                              which should be saved.
	in_save_buf        - if NULL, get save_DPgra_gad from actid; else use
	                     the contents of this buffer.

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 

NOTES

HISTORY
	07/07/93    G.Werner        DPvd_mark_view
	            Creation Date
*/

{
   int result;
   int i;
   struct save_view *current = NULL;
   struct save_DPgra_gad *save_buf;


   /* look in list of views, if this window is already stored */
   for(i=0;i< n_list_of_views; ++i)
   {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	    current = &list_of_views[i];
            break;
	}
   }
   if(current == NULL)
   {
     /* add a new view */
     if(n_list_of_views == 0)
     {
	list_of_views = (struct save_view *)malloc(
		sizeof(struct save_view) * EX_MAX_WINDOW);
     }
     else if(n_list_of_views > EX_MAX_WINDOW)
     {
	list_of_views = (struct save_view *)realloc((char *)list_of_views,
		sizeof(struct save_view) * (n_list_of_views+1));
     }
     if(list_of_views == NULL)
     {
#ifdef DEBUG
	printf("Cannot malloc space for list_of_views.\n");
#endif
	n_list_of_views = 0;
	return 0;
     }
     current = &list_of_views[n_list_of_views++];
     current->win_obj.objid = actid->objid;
     current->win_obj.osnum = actid->osnum;
     current->stored  = 0;
     current->orig_gg = NULL;
     current->temp_gg = NULL;
   }


    if(original)
    {
      if(current->orig_gg == NULL)
       current->orig_gg = (struct save_DPgra_gad *)malloc(sizeof(struct save_DPgra_gad));
      save_buf = current->orig_gg;
    }
    else
    {
      if(current->temp_gg == NULL)
        current->temp_gg = (struct save_DPgra_gad *)malloc(sizeof(struct save_DPgra_gad));
      save_buf = current->temp_gg;
    }
    if(save_buf == NULL)
    {
#ifdef DEBUG
	printf("Cannot malloc space for save gragad info\n");
#endif
	return 0;
    }

   if(in_save_buf==NULL)
   {
       result = save_gragad(actid, save_buf);
   }
   else
   {
       *save_buf = *in_save_buf;
       result = TRUE;
   }
   
   if (original)
   {
      current->stored |= ORIG_STORED;
   }
   else
   {
      current->stored |= TEMP_STORED;
   }

   return result;
}

/*--- DPvd_restore_view ----------------------------------------*/

int DPvd_restore_view(int original, struct GRid *actid)

/*
NAME
	DPvd_restore_view

DESCRIPTION
	This function restores the window/view information of
        the given window.

SYNOPSIS
	extern int DPvd_restore_view(int original, struct GRid *actid)

PARAMETERS
        original(IN)       - TRUE - restore the original view,
                             FALSE - restore the marked view,
				     if it exists, otherwise the original view.
        actid (IN)         - the object id of the window
                              which should be restored.

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 
        0            - nothing stored for this window.

NOTES

HISTORY
	07/07/93    G.Werner            DPvd_restore_view
	            Creation Date
*/

{
  int i;
  struct save_DPgra_gad *view_to_change;
 
  for(i=0; i< n_list_of_views ; ++ i)
  {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	   /*
	   ** set new gragad and update window
	   */
#ifdef DEBUG
/*
           printf("restore view original=%d, %s\n",original, 
		list_of_views[i].temp_gg==NULL?"no marked view":"view marked");
*/
#endif
	   if(!original && (list_of_views[i].stored & TEMP_STORED) != 0)
		view_to_change = list_of_views[i].temp_gg;
	   else if((list_of_views[i].stored & ORIG_STORED) != 0)
		view_to_change = list_of_views[i].orig_gg;
	   else 
	   {
#ifdef DEBUG
		printf("No restore info stored for window.\n");
#endif
		return 0;
	   }

           return  reset_gragad(actid,view_to_change);
	}
  }
#ifdef DEBUG
  printf("Error: nothing stored for this window %d\n",actid->objid);
#endif
  return 0;
}



/*--- DPvd_restore_view2 ----------------------------------------*/

int DPvd_restore_view2(int original, struct GRid *actid)

/*
NAME
	DPvd_restore_view2

DESCRIPTION
	This function differs from DPvd_restore_view() in that when trying
	to restore a marked (temp) view, it checks if the current view is
	already the same as the marked view. If it is, then it restore the
	original view instead. 

SYNOPSIS
	extern int DPvd_restore_view2(int original, struct GRid *actid)

PARAMETERS
        original(IN)       - TRUE - restore the original view,
                             FALSE - restore the marked view,
				     if it exists && not equal to the current view
				     , otherwise the original view.
        actid (IN)         - the object id of the window
                              which should be restored.

GLOBALS USED
	none

RETURN VALUES
        0       - nothing stored for this window.
	1	- tmp view restored
        2       - original view restored

NOTES

HISTORY
	08/23/93    T.Wang            DPvd_restore_view2
	            Create this function for the "restore view" command
*/

{
  int i;
  struct save_DPgra_gad *view_to_change ;
 
  for(i=0; i< n_list_of_views ; ++ i)
  {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	   /*
	   ** set new gragad and update window
	   */

	   if(!original && (list_of_views[i].stored & TEMP_STORED) != 0)
	   {
	       /* Check if the tmp view is the same as the current view */

	       IGRint tmpview_current_same = 0;
	       struct save_DPgra_gad *tmp_view;

	       IGRlong             msg;
	       IGRint              sts;
	       struct var_list     inq_array[2];
	       IGRlong             nbytes_ret;
	       IGRlong             error_var;
	       struct DPgra_gad    local_gragad;

	       /* read the gragad info */
	       
	       inq_array[0].var = GRAGAD_STRUCT;
	       inq_array[0].var_ptr = (char *) &local_gragad;
	       inq_array[0].num_bytes = sizeof(struct DPgra_gad);
	       inq_array[0].bytes_returned = &nbytes_ret;
	       inq_array[1].var = END_PARAM;
	       
	       sts = dp$inq_set_gragad(msg = &msg,
				       gragad_objid = actid->objid,
				       osnum = actid->osnum,
				       which_error = &error_var,
				       var_list = inq_array);
	       if(!(sts&msg&1)) return 0;
	       

               tmp_view = list_of_views[i].temp_gg;

	       tmpview_current_same = DPvd_is_same_view(tmp_view,&local_gragad);

	       if(!tmpview_current_same)
	       {
		   view_to_change = list_of_views[i].temp_gg;
	       }
	       else  /* Try original view */
	       {
		   if((list_of_views[i].stored & ORIG_STORED) != 0)
		   {
		       view_to_change = list_of_views[i].orig_gg;
		   }
		   else return 0;
	       }
	   }
	       
	   else if((list_of_views[i].stored & ORIG_STORED) != 0)
		view_to_change = list_of_views[i].orig_gg;
	   else 
	   {
		return 0;
	   }

           reset_gragad(actid,view_to_change);

	   if(view_to_change == list_of_views[i].orig_gg) 
		return 2; /* orgin view restored */
           else return 1;  /* tmp view restored */
	}
  }
#ifdef DEBUG
  printf("Error: nothing stored for this window %d\n",actid->objid);
#endif
  return 0;
}

/*--- DPvd_clear_view ----------------------------------------*/

int DPvd_clear_view(int original, struct GRid *actid)

/*
NAME
	DPvd_clear_view

DESCRIPTION
	This function clears  the window/view information of
        the given window.

SYNOPSIS
	extern int DPvd_clear_view(int original, struct GRid *actid)

PARAMETERS
        original(IN)       - TRUE - clear the original view,
                             FALSE - clear the marked view,
        actid (IN)         - the object id of the window
                              which should be restored.

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 
        0            - nothing stored for this window.

NOTES

HISTORY
	07/07/93    G.Werner               DPvd_clear_view
	            Creation Date
*/

{
  int i;
 
  for(i=0; i< n_list_of_views ; ++ i)
  {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	   if(original)
		  list_of_views[i].stored &= ~(ORIG_STORED);
	   else
		  list_of_views[i].stored &= ~(TEMP_STORED);
	   return OM_S_SUCCESS;
	}
  }
#ifdef DEBUG
  printf("Error: nothing stored for this window %d\n",actid->objid);
#endif
  return 0;
}



void DPvd_jnl_record_header_event(IGRint event_type)
/*
  Put an event in the journal file so that other system routines
  (like DPhandle_event() will stop when they see this event. And I
  take control from this event. 
*/
{
#if defined( X11 )
    XEvent xevent;

    memset((char*)&xevent,0,sizeof(XEvent));
    xevent.type = DPvd_JNL_XEVENT;
    xevent.xkey.x = event_type;
    JNL_record_input((sizeof ( XEvent)), &xevent);
#elif defined( ENV5 )    
    JNL_record_event(USER_EVENT);
    JNL_record_input( sizeof (int), (char *) &event_type);
#endif
}


/*--- DPvd_mark_changed ----------------------------------------*/

int DPvd_mark_changed(struct GRid *actid)

/*
NAME
	DPvd_mark_changed

DESCRIPTION
	This function sets a bit for the GRid in the local table.
        This bit may later be used to output gragad info to journal file.

SYNOPSIS
	extern int DPvd_mark_changed(struct GRid *actid)

PARAMETERS
        actid (IN)         - the object id of the window
                              is marked as changed.

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 
        0            - nothing stored for this window.

NOTES

HISTORY
	07/07/93    G.Werner               DPvd_mark_changed
	            Creation Date
	10/06/93    T.Wang
	            Fix: if no entry, create one by marking original view.
*/
{
  int i;
 
  for(i=0; i< n_list_of_views ; ++ i)
  {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	   list_of_views[i].stored |= GRMODIFIED;
	   return OM_S_SUCCESS;
	}
  }

  /* Didn't find the entry in the list_of_views[]. 
     Create an entry for it by marking this view as an original view */
  DPvd_mark_view(TRUE, actid, NULL);

  /* mark the GRMODIFIED bit again */
  for(i=0; i< n_list_of_views ; ++ i)
  {
	if(list_of_views[i].win_obj.objid == actid->objid)
	{
	   list_of_views[i].stored |= GRMODIFIED;
	   return OM_S_SUCCESS;
	}
  }

#ifdef DEBUG
  printf("Error: nothing stored for this window %d\n",actid->objid);
#endif

  return(FALSE);
}


void DPvd_jnl_mark_end()
/* The end of my journal records. Leave my playback routine when see this
   mark. */
{
    DPvd_jnl_record_header_event(DPvd_JNL_END);
}


void DPvd_jnl_mark_view(IGRint original,  struct GRid *actid)
/*
NAME
        DPvd_jnl_mark_view
DESCRIPTION
        This routine saves a view in the journal file as a "marked tmp view",
	so when journaling plays back the marked view information can be restored.
	(so future "restore marked view" command will be correct)

SYNOPSIS
        void DPvd_jnl_mark_view(IGRint original,  struct GRid *actid)

PARAMETERS
        original (IN) -- always pass in FALSE since we only need to save marked view
        actid    (IN) -- view id

GLOBALS USED
RETURN VALUES
        void
NOTES

HISTORY
        10/06/93  T. Wang  Creation
*/
{
    struct jnl_storage local_jnl;

    local_jnl.grid = *actid;
    save_gragad(&local_jnl.grid, &local_jnl.gragad);

    /* Only save marked (tmp) view */
    if(!original)
    {
	DPvd_jnl_record_header_event(DPvd_JNL_MARKED_VIEW);
	JNL_record_info_event(JNL_CHAR, sizeof(struct jnl_storage),
			      (char *) &local_jnl);
    }
}


/*--- DPvd_jnl_save_changed ----------------------------------------*/

void DPvd_jnl_save_changed()

/*
NAME
	DPvd_jnl_save_changed

DESCRIPTION
	This function writes an entry into the Journal file for
        all windows, which are marked as changed.
        Also the bit is cleared, so that the next invokation
        starts with a clear table.

        The entry in the journal file has the following format:
           n_entries           (sizeof(int))   - number of changed windows
        followed by "n_entries":
           grid                (sizeof(GRid))  - info about the objectid
           gragad              (sizeof(struct save_DPgra_gad)) 
                                               - the gragad info.

SYNOPSIS
	extern void DPvd_jnl_save_changed()

PARAMETERS

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 
        0            - nothing stored for this window.

NOTES

HISTORY
	07/07/93    G.Werner            DPvd_jnl_changed
	            Creation Date
*/
{
    int i;
    int result;

    struct jnl_storage  local_jnl;
 
  for(i=0; i< n_list_of_views ; ++ i)
  {
     if(list_of_views[i].stored | GRMODIFIED) 
     {
        list_of_views[i].stored &= ~(GRMODIFIED);

        result = save_gragad(&list_of_views[i].win_obj, &local_jnl.gragad);
	if(result != 1) continue; /* This window might have been deleted */

        local_jnl.grid = list_of_views[i].win_obj;

#ifdef DEBUG
        fprintf( stderr, "Writing to Journal file:\n");
	DPvd_print_jnl_info( local_jnl);
#endif

	DPvd_jnl_record_header_event(DPvd_JNL_VIEW);
	JNL_record_info_event(JNL_CHAR, sizeof(struct jnl_storage),
			(char *) &local_jnl);
     }
  }

  return ;
}

/*--- DPvd_jnl_playback ----------------------------------------*/

DPvd_jnl_playback()

/*
NAME
	DPvd_jnl_playback

DESCRIPTION
	This function reads the playbackfile, which will contain
          sizeof(IGRint)   - number of stored view information.
        followed by 
          GRid             - gragad id
          struct DPgra_gad - view info

        all mentioned windows are changed.


SYNOPSIS
	extern DPvd_jnl_playback()

PARAMETERS

GLOBALS USED
	none

RETURN VALUES
        OM_S_SUCCESS - 
        0            - nothing stored for this window.

NOTES

HISTORY
	07/07/93    G.Werner             DPvd_playback
	            Creation Date
	
	 
*/
{
    struct  jnl_storage  local_jnl;
    IGRint  event, num_bytes, user_data;

#if defined( X11 )
    XEvent  xevent;
#endif
    
    /* Until getting the "DPvd_JNL_END" or meet an unknow event, 
       process our journaling record */
    while(1)
    {
	/* Inquire event */

	event = 0;   /* Default, unknown event */
	user_data = 0;

#if defined( X11 )
	xevent.type = 0;  /* clear first */
	xevent.xkey.x = 0;

	if(JNL_XPending(EXdisplay))
	{
	    JNL_XNextEvent(EXdisplay,&xevent);
	    if(xevent.type == DPvd_JNL_XEVENT)
	    {
	         event = USER_EVENT;
	         user_data = xevent.xkey.x;
	    }
	}
        else
	{
	    return (TRUE); /* no event */
	}
#elif defined( ENV5 )
	JNL_inq_events(&event);
	JNL_inq_user_data(&user_data);
#endif

	/* Process event. (Note, in X11 case, the xevent has already 
	   been taken out from the queue, but in ENV5 case, the event
	   is still on the queue. So following process is a little
	   different between X11 and ENV5.)
	   */

	if(event==USER_EVENT)
	{
	    if(user_data==DPvd_JNL_VIEW || user_data==DPvd_JNL_MARKED_VIEW)
	    {
		/*
		 * Consume this USER_DATA event and Get the view info
		 */

#if defined( X11 )
		/* get the INFO event */
		JNL_echo_input(sizeof(XEvent), (char *) &xevent);
		num_bytes = xevent.xbutton.x;
		JNL_echo_input(num_bytes, (char *)&local_jnl);

#elif defined( ENV5 )
		/* take out the USER_INFO event */
		JNL_get_user_data(&user_data);

		/* get the INFO event */
		JNL_echo_input(4, &num_bytes);  /* INFO_EVENT */
		JNL_echo_input(4, &num_bytes);  /* CHAR_TYPE */
		JNL_echo_input(4, (char *) &num_bytes); /* number of bytes */
		JNL_echo_input(num_bytes, (char *)&local_jnl);

#ifdef DEBUG
		fprintf( stderr, "Journal Information:\n");
		DPvd_print_jnl_info(local_jnl);
#endif

#endif
		if(JNL_journal())
		{
		    /* Save info to the next journal file. The above 'echo'ed
		     info will not be saved by JNL system automatically */
		    JNL_record_info_event(JNL_CHAR, sizeof(struct jnl_storage),
					  (char *) &local_jnl);
		} 

		if(user_data == DPvd_JNL_VIEW)
		{
		    /* set the gragad */
		    reset_gragad(&local_jnl.grid, &local_jnl.gragad);
		}
		else if(user_data == DPvd_JNL_MARKED_VIEW)
		{
		    /* mark temporary view */
		    DPvd_mark_view(FALSE, &local_jnl.grid, &local_jnl.gragad);
		}
	    }
	    else if(user_data==DPvd_JNL_END)
	    {
#if defined( ENV5 )
		/* comsume the USER_DATA event */
		JNL_get_user_data(&user_data);
#endif
		/* Leave playback */
		return(TRUE);
	    }
	    else  
	    {
		return(FALSE);
	    }
	}

	else /* Not a USER_DATA event */
	{
	    /* Process if is window events */
#if defined( X11 )	    
	    if((xevent.type == ConfigureNotify ) ||
	       ( xevent.type == DestroyNotify )   ||
	       ( xevent.type == UnmapNotify )     ||
	       ( xevent.type == ReparentNotify ) )
	    {
		DPhandle_event( &xevent );
	    }
	    else /* unkown event */
	    {
		if(xevent.type != 0) JNL_XPutBackEvent(EXdisplay,&xevent);
		return(FALSE);
            }

#elif defined( ENV5 )
	    if(event & (REFRESH_EVENT | DELETE_EVENT | COVER_EVENT | COLLAPSE_EVENT))
	    {
		DPhandle_event();
	    }
	    else
	    {
		/* An unkonwn event. This could happen if the some journaling
		   session stoped in the middle of the DPvd command. But if
		   we return now, it is OK. */

		return(FALSE);
	    }
#endif

	} 
    }  /* while */
}



end implementation DPvd;
