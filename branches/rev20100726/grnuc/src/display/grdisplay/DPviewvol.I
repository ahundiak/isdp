class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "dpdef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "madef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "codpdef.h"

/* prototype files */
%safe
#include "DPviewvol.h"
#include "DPzdepfnc.h"
#include "DPwldvw.h"
#include "dpgetrng.h"
#include "dpsetrng.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "maptsxfor.h"
%endsafe


#if defined(__STDC__) || defined(__cplusplus)
int DPviewvol ( IGRlong      *msg,
                IGRshort     in_flags, 
                IGRshort     *ret_flags,
                struct GRid  *gg_id, 
                IGRdouble    *origin, 
                IGRdouble    *rotation, 
                IGRdouble    *vw_vol, 
                IGRdouble    *display_depths,
                IGRdouble    *active_z,
                IGRshort     *defaults_vol,
                IGRshort     *def_dis_depths,
                IGRdouble    *new_vw_vol,
                IGRdouble    *new_display_depths,
                IGRdouble    *new_active_z,
                IGRdouble    *new_coor_vol,
                IGRboolean   update )

#else
int DPviewvol (msg, in_flags, ret_flags, gg_id, origin, rotation, vw_vol,
display_depths, active_z, defaults_vol, def_dis_depths, new_vw_vol, new_display_depths, 
new_active_z, new_coor_vol, update)

IGRlong *msg;
IGRshort in_flags; 
IGRshort *ret_flags;
struct GRid *gg_id; 
IGRdouble *origin; 
IGRdouble *rotation; 
IGRdouble *vw_vol; 
IGRdouble *display_depths;
IGRdouble *active_z;
IGRshort *defaults_vol;
IGRshort *def_dis_depths;
IGRdouble *new_vw_vol;
IGRdouble *new_display_depths;
IGRdouble *new_active_z;
IGRdouble *new_coor_vol;
IGRboolean update;
#endif

{

IGRint status = OM_S_SUCCESS;
IGRlong vvol_msg;
*msg = MSSUCC;

status = om$send (msg = message IGEgragad.DPview_vol(&vvol_msg,
in_flags, ret_flags, origin, rotation, vw_vol, display_depths, active_z,
defaults_vol, def_dis_depths, new_vw_vol, new_display_depths, 
new_active_z, new_coor_vol,update),
			senderid = NULL_OBJID, 
			targetid = gg_id->objid, 
			targetos = gg_id->osnum);
		if (!(1 & status))
		{
#ifdef DEBUG
		    printf("send to DPview_vol error\n");
		    om$report_error(sts = status);
#endif
		}
*msg = vvol_msg;

return (status);
}

method DPview_vol (IGRlong *msg; IGRshort flags; IGRshort *ret_flags;
IGRdouble *origin; IGRdouble *rotation; IGRdouble *vw_vol; IGRdouble *
display_depths; IGRdouble *active_z; IGRshort *defaults_vol; IGRshort *
def_dis_depths; IGRdouble *new_vw_vol; IGRdouble *new_display_depths; 
IGRdouble *new_active_z; IGRdouble *new_coor_vol; IGRboolean update)

{
IGRint status = OM_S_SUCCESS;
IGRboolean update_all = FALSE;
IGRdouble n_origin[3];
IGRdouble rotate[4][4];
IGRdouble trans_VOR[4][4];
IGRdouble wld_to_view[4][4];
IGRdouble view_to_wld[4][4];
IGRdouble temp;
IGRshort four = 4;
IGRlong num_pts;
IGRlong vw_vol_msg;
IGRdouble old_depths[2];
IGRdouble new_origin[3];
IGRdouble old_origin[3];
IGRdouble extra_vol[6];
IGRdouble ex_dd[6]; /* extra display depths */
IGRdouble ex_zpt[3];
IGRdouble save_z;
IGRdouble set_depths[2];
/*IGRdouble long_vol[24]; */
struct DPrange_check range_chk;
IGRboolean b_sts; 
struct DPgra_gad *gg;

gg = &ME.IGEgragad->gragad;

if(ret_flags != NULL)
{
    *ret_flags = 0;
}
if (flags & SETIN)
{
    if (flags & FRONT_CLIP)
    {
    	gg->flags |= FRONT_CLIP;
    }
    if (flags & BACK_CLIP)
    {
	gg->flags |= BACK_CLIP;	
    }

     if (flags & WORLD_COOR)
    {
	/* Changes need to be made to the active z and display depths when
	the origin and rotation are changed.  To accomplish these
	changes the following is done.  In all cases, the "old" view origin is
	multiplied by the "old" rotation, and its z is added to the
	active z.  Then the z value from a point is subtracted from that
	resultant active z, but how that point is derived depends upon 
	several variables. 
	If a "new" origin and a "new" rotation exist, then the "new"
	view origin is multiplied by the "new" rotation to derive this
	point. If the rotation doesn't change, the "new" view origin is
	multiplied by the "old" rotation.  If the origin
	doesn't change but the rotation does, the "old" origin is
	multiplied by the "new" rotation amd subtracted from the active z. */

	
	
	num_pts = 1;	
	
    if(!MAptsxform(msg, &num_pts, (IGRdouble *)gg->rotation, gg->origin, 
			old_origin))
    {
	goto fini;
    }
    if (origin != NULL)
    {
	OM_BLOCK_MOVE(origin, gg->origin, sizeof(IGRdouble) * 3);
    }
    if(!MAptsxform(msg, &num_pts, (IGRdouble *)gg->wld_to_view, gg->origin,
			new_origin))
    {
	goto fini;
    }
    if (rotation != NULL)
    {
	OM_BLOCK_MOVE(rotation, gg->rotation, sizeof(IGRdouble) * 16);
    }
#ifndef IDRAW
    if ( gg->flags & IS_PERSP)
    {
	b_sts = dp$cal_wldvw_mtx(msg=msg,in_flags = DPLEFT_VIEW,
				origin = gg->eye_pt,
				rotation =  (IGRdouble *)gg->rotation,
				wldvw_mtx = (IGRdouble *)wld_to_view,
				vwwld_mtx = (IGRdouble *)view_to_wld);
	if (!b_sts)
	{
	    goto fini;
        }
	new_origin[0] = 0;
	new_origin[1] = 0;
	new_origin[2] = 0;
    }
    else
#endif /* IDRAW */
    {
	b_sts = dp$cal_wldvw_mtx(msg=msg,in_flags = DPRIGHT_VIEW,
				origin = gg->origin,
				rotation =  (IGRdouble *)gg->rotation,
				wldvw_mtx = (IGRdouble *)wld_to_view,
				vwwld_mtx = (IGRdouble *)view_to_wld);
	if (!b_sts)
	{
	    goto fini;
        }
    }
    if (vw_vol != NULL)
    {

    	DPsetrng(msg, (IGRdouble *)wld_to_view, &range_chk);
	if (vw_vol[0] > vw_vol[3])
	{
	    temp = vw_vol[3];
	    vw_vol[3] = vw_vol[0];
	    vw_vol[0] = temp;
	}
	if (vw_vol[1] > vw_vol[4])
	{
	    temp = vw_vol[4];
	    vw_vol[4] = vw_vol[1];
	    vw_vol[1] = temp;
	}
	if (vw_vol[2] > vw_vol[5])
	{
	    temp = vw_vol[5];
	    vw_vol[5] = vw_vol[2];
	    vw_vol[2] = temp;
	}
    	DPgetrng(msg, (IGRdouble *)wld_to_view, &range_chk, vw_vol, extra_vol);
	/* extra_vol is vw_vol in the viewing coordinates.  
	   If there is some rotation the extra_vol is made somewhat 
	   larger so that you will still see the complete area you 
	   defined with vw_vol and define it at the viewing coord. 
	   with diagonal points. */
    	if (defaults_vol != NULL)
    	{
    	    if (defaults_vol[0] == 1)    
	    {
	        extra_vol[0] = gg->vw_volume[0];
	    }
	    if (defaults_vol[1] == 1)
	    {
	        extra_vol[1] = gg->vw_volume[1];
	    }
	    if (defaults_vol[2] == 1)
	    {
	        extra_vol[2] = gg->vw_volume[2];
	    }
	    if (defaults_vol[3] == 1)    
	    {
	        extra_vol[3] = gg->vw_volume[3];
	    }
	    if (defaults_vol[4] == 1)
	    {
	        extra_vol[4] = gg->vw_volume[4];
	    }
	    if (defaults_vol[5] == 1)
	    {
	        extra_vol[5] = gg->vw_volume[5];
	    }
    	}	
    	OM_BLOCK_MOVE(extra_vol, gg->vw_volume, sizeof(IGRdouble) * 6);
    }
    else  /* view volume = NULL */
    {
	gg->vw_volume[2] = gg->vw_volume[2] - new_origin[2];
	
    	gg->vw_volume[5] = gg->vw_volume[5] - new_origin[2];
    }
    if(display_depths != NULL)
    {
	old_depths[0] = gg->vw_volume[2];
	old_depths[1] = gg->vw_volume[5];
	if (flags & NONABS_DD1)
	{
    	    num_pts = 1;
    	    if(!MAptsxform(msg, &num_pts, (IGRdouble *)wld_to_view,
				display_depths, ex_dd))
    	    {
	    	goto fini;
	    }
	}
	else
	{
	    DPset_zdep(msg, 0, (IGRdouble *)gg->rotation, (IGRdouble *)wld_to_view,
			&display_depths[2], 1, &ex_dd[2]);
	}
	if (flags & NONABS_DD2)
	{
    	    num_pts = 1;
    	    if(!MAptsxform(msg, &num_pts, (IGRdouble *)wld_to_view,
				&display_depths[3], &ex_dd[3]))
    	    {
	    	goto fini;
	    }
	}
	else
	{
	    DPset_zdep(msg, 0, (IGRdouble *)gg->rotation, (IGRdouble *)wld_to_view,
			&display_depths[5], 1, &ex_dd[5]);

	}
	if (def_dis_depths != NULL)
	{
	    if((def_dis_depths[0] == 0 && def_dis_depths[1] == 0))
	    {
	    	if (ex_dd[2]!=ex_dd[5]) 
		{
		        gg->vw_volume[2] = ex_dd[2];
		    	gg->vw_volume[5] = ex_dd[5];	
		}
		else
		{
			*msg=DPFarEqNear;
			goto fini;
		}
	    }
	    else
	    {
		/* set the lower limit if possible as long as it is not
		   greater than the upper default limit			*/

	    	if(def_dis_depths[0] == 0 ) 
	    	{
		    if (ex_dd[2] < gg->vw_volume[5])
		    {
			gg->vw_volume[2] = ex_dd[2];
		    }
		    else
		    {
		    	gg->vw_volume[5] = ex_dd[2];
		    }
	    	}
		/* set the upper limit (if possible) as long as it is not
		   less than the lower default limit			*/

	    	if(def_dis_depths[1] == 0 )
	    	{
		    if (ex_dd[5] > gg->vw_volume[2])
		    {
		    	gg->vw_volume[5] = ex_dd[5];
		    }
		    else
		    {
			gg->vw_volume[2] = ex_dd[5];
		    }
	    	}
	    }
	} /* close for if def_dis_depths != NULL */
	else
	{
	    gg->vw_volume[2] = ex_dd[2];
	    gg->vw_volume[5] = ex_dd[5];
	}
    } /* close for if display_depths != NULL */

    if (gg->vw_volume[2] > gg->vw_volume[5])
    {
	temp = gg->vw_volume[2];
	gg->vw_volume[2] = gg->vw_volume[5];
	gg->vw_volume[5] = temp;
    }	
    if ( active_z == NULL)
    {
        gg->act_z = gg->act_z - new_origin[2];
    }
    else
    {
	if (flags & NONABS_Z)
	{
    	    num_pts = 1;
    	    if(!MAptsxform(msg, &num_pts, (IGRdouble *)wld_to_view, active_z,
					ex_zpt))
    	    {
	    	goto fini;
	    }
	    gg->act_z = ex_zpt[2];	
	}
	else
	{
	    DPset_zdep(msg, 0, (IGRdouble *)gg->rotation, (IGRdouble *)wld_to_view,
				&active_z[2],1,&gg->act_z);
	}
    } /* close for active_z != NULL */
    if ( gg->act_z < gg->vw_volume[2] || 
	gg->act_z > gg->vw_volume[5])
    {
	    if ( flags & ACTIVE_Z_EDGE)	    
	    {
		if ( gg->act_z < gg->vw_volume[2])
		{
		    if (ret_flags != NULL)
		    {
		    	*ret_flags |= ACT_Z_FRONT;
		    }
		    gg->act_z = gg->vw_volume[2];
		}
		if( gg->act_z	> gg->vw_volume[5])
		{
		    if (ret_flags != NULL)
		    {
		    	*ret_flags |= ACT_Z_BACK;
		    }
		    gg->act_z = gg->vw_volume[5];
		}
	    } /* close for if active z edge */
	    else if (flags & ACT_Z_FRONT)
	    {
		    if (ret_flags != NULL)
		    {
		    	*ret_flags |= ACT_Z_FRONT;
		    }
		    gg->act_z = gg->vw_volume[2];
	    }
	    else if (flags & ACT_Z_BACK)	
	    {
		if (ret_flags != NULL)
		{
		    *ret_flags |= ACT_Z_BACK;
		}
		gg->act_z = gg->vw_volume[5];
	    }
	    else  /* if ( flags & ACTIVE_Z_MIDDLE) */
	    {
	        if (ret_flags != NULL)	
		{
		    *ret_flags |= ACTIVE_Z_MIDDLE;		
		}
		gg->act_z  =
		(gg->vw_volume[2] +
		gg->vw_volume[5]) / 2.0;
	    }
	} /* close for if active z is outside of range */

    save_z = gg->act_z;

    status = om$send (msg = message IGEgragad.DPcal(&vw_vol_msg), 
			senderid = my_id, 
			targetid = my_id);
    if (!(1 & status))
    {
#ifdef DEBUG
	printf("send to DPcal error in DPviewvol\n");
	om$report_error(sts = status);
#endif
    }
    if (save_z != gg->act_z)
    {
        if (ret_flags != NULL)	
	{
    		*ret_flags &= ~ACT_Z_FRONT;
		*ret_flags &= ~ACT_Z_BACK;
		*ret_flags |= ACTIVE_Z_MIDDLE;		
	}
    }
    if (new_display_depths != NULL )
    {
	set_depths[0] = gg->vw_volume[2];
	set_depths[1] = gg->vw_volume[5];
	 
	DPgetvwz_in_wld(msg, 0, (IGRdouble *)gg->rotation, (IGRdouble *)wld_to_view,
				set_depths, 2, ex_dd);

	    if (ex_dd[0] > ex_dd[1])
	    {
		new_display_depths[1] = ex_dd[0];
		new_display_depths[0] = ex_dd[1];
	    }
	    else
	    {
		new_display_depths[0] = ex_dd[0];
		new_display_depths[1] = ex_dd[1];
	    }
    }
    	if ( new_active_z != NULL)
	{
	    DPgetvwz_in_wld(msg, 0, (IGRdouble *)gg->rotation, (IGRdouble *)wld_to_view,
				&gg->act_z, 1, new_active_z);
	}

    if (update)
    {
       if (!(gg->flags & DP_DELAY))
       {
/* TESTING PARTIAL UPDATE 
	if (display_depths != NULL)
	{
        	rect = gg->flags & CLIP;
        	front = gg->flags & FRONT_CLIP;
        	back = gg->flags & BACK_CLIP;

		trans = (gg->vw_volume[5] - gg->vw_volume[2]) * gg->vvol_viewport_scale;
		old_dit_z[0] = gg->dit_clip_range[2];
		old_dit_z[1] = gg->dit_clip_range[5];
		scrn_z = -(old_depths[0] - gg->vw_volume[2]) * gg->vvol_viewport_scale + trans;
	    	if (scrn_z > trans )
		{
			gg->dit_clip_range[2] = trans;
			gg->dit_clip_range[5] = scrn_z;
        		DPpush_clip(msg,rect,front,back,gg->dit_clip_range,
		    			gg->gpipe_id, gg->vw_volume);
		   	dp$gen_update( msg = msg,mode = GRbe,
					erase = FALSE, objid = my_id);
		}
		else
		{
			gg->dit_clip_range[2] = scrn_z;
			gg->dit_clip_range[5] = trans;
        		DPpush_clip(msg,rect,front,back,gg->dit_clip_range,
		   			 gg->gpipe_id, gg->vw_volume);

		   	dp$gen_update( msg = msg, mode = GRbd,
					erase = FALSE, objid = my_id);
		}
		scrn_z = -(old_depths[1] - gg->vw_volume[2]) * gg->vvol_viewport_scale + trans;
		if (scrn_z < 0)
		{
			gg->dit_clip_range[2] = scrn_z;
			gg->dit_clip_range[5] = 0;
        		DPpush_clip(msg,rect,front,back,gg->dit_clip_range,
		    		gg->gpipe_id, gg->vw_volume);

		   dp$gen_update( msg = msg,range = extra_vol, mode = GRbe,
					erase = FALSE, objid = my_id);
		}
		else
		{
			gg->dit_clip_range[2] = 0;
			gg->dit_clip_range[5] = scrn_z;
        		DPpush_clip(msg,rect,front,back,gg->dit_clip_range,
		    		gg->gpipe_id, gg->vw_volume);

		   dp$gen_update( msg = msg,range = extra_vol, mode = GRbd,
					erase = FALSE, objid = my_id);
		}
		gg->dit_clip_range[2]= old_dit_z[0];
		gg->dit_clip_range[5]= old_dit_z[1];
        	DPpush_clip(msg,rect,front,back,gg->dit_clip_range,
		    gg->gpipe_id, gg->vw_volume);

	}
	else
	{
*/          status = om$send(mode = OM_e_wrt_object,
                            msg = message IGEgragad.DPupdate(msg,NULL,
					&update_all),
                            senderid = my_id,
                            targetid = my_id);

      	   if ( ! (1 & status) )
       	   {
#ifdef DEBUG
               	printf("\nIN DPcenter Error send to window DPupdate\n");
               	om$report_error(sts = status);
#endif
               	goto fini;	  
       	    } 
/*	 } */ 
        }
	else
	{
	   ex$message( msgnumb = GR_I_DlyOn);
	}

    }
    if (new_coor_vol != NULL)
    {
       OM_BLOCK_MOVE(gg->vw_volume, new_coor_vol, sizeof(IGRdouble)*6);
    }
    if (new_vw_vol != NULL)
    {
    	OM_BLOCK_MOVE(gg->vw_volume,extra_vol,sizeof(IGRdouble) * 6);
	/* already in min. max. order */
    	DPsetrng(msg, (IGRdouble *)view_to_wld, &range_chk);
    	DPgetrng(msg, (IGRdouble *)view_to_wld, &range_chk, extra_vol, 
			new_vw_vol);
    }
    *msg = vw_vol_msg;  
  }      
}
else /* setin not set */
{
    if (origin != NULL)
    {
	OM_BLOCK_MOVE(origin, n_origin, sizeof(IGRdouble)*3);
    }
    else
    {
	OM_BLOCK_MOVE(gg->origin, n_origin, sizeof(IGRdouble)*3);
    }
    if(rotation != NULL)
    {
	OM_BLOCK_MOVE(rotation, rotate, sizeof(IGRdouble)*16);
    }
    else
    {
	OM_BLOCK_MOVE(gg->rotation, rotate, sizeof(IGRdouble)*16);	
    }
    MAidmx(msg, (IGRdouble *)trans_VOR);
    trans_VOR[0][3] = -n_origin[0];
    trans_VOR[1][3] = -n_origin[1];
    trans_VOR[2][3] = -n_origin[2];

    if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)rotate, 
                   (IGRdouble *)trans_VOR, (IGRdouble *)wld_to_view))
    {
	goto fini;
    }
    if (!MAinvmx(msg,&four,(IGRdouble *)wld_to_view,(IGRdouble *)view_to_wld))
    {
	goto fini;
    }
    if (vw_vol != NULL)
    {
    	if (new_coor_vol != NULL)
    	{
	    if (vw_vol[0] > vw_vol[3])
	    {
	    	temp = vw_vol[3];
	    	vw_vol[3] = vw_vol[0];
	    	vw_vol[0] = temp;
	    }
	    if (vw_vol[1] > vw_vol[4])
	    {
	    	temp = vw_vol[4];
	    	vw_vol[4] = vw_vol[1];
	    	vw_vol[1] = temp;
	    }
	    if (vw_vol[2] > vw_vol[5])
	    {
	    	temp = vw_vol[5];
	    	vw_vol[5] = vw_vol[2];
	    	vw_vol[2] = temp;
	    }

    	    if (flags & WORLD_COOR)
    	    {
    	    	DPsetrng(msg, (IGRdouble *)wld_to_view, &range_chk);
    	    	DPgetrng(msg, (IGRdouble *)wld_to_view, &range_chk, vw_vol,
			new_coor_vol);
	    }
    	    if (flags & VIEW_COOR)
	    {
    	    	DPsetrng(msg, (IGRdouble *)view_to_wld, &range_chk);
    	    	DPgetrng(msg, (IGRdouble *)view_to_wld, &range_chk, vw_vol,
			new_coor_vol);
            }
        }
    }
    else
    {
	status = OM_E_ABORT;
    }
}
fini:
    return (status);
}

end implementation IGEgragad;
 
