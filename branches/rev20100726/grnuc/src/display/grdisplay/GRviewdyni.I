
class implementation GRviewdyn;

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
#include "referr.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "wl.h"
#include "dl.h"

/* prototype files */
%safe
#include "DPviewdyn.h"
#include "GRcheckref.h"
#include "GRdisthruref.h"
#include "GRdpbfunc.h"
#include "GRlcquery.h"
#include "dpdiselem.h"
#include "dpviewind.h"
#include "dpclpstack.h"
#include "dpgetrng.h"
#include "dpmtxstack.h"
#include "dpsetrng.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "maptsxfor.h"
%endsafe

extern void DPdraw_ground_plane( /*win_id, win_os, gg_ptr )*/

        OM_S_OBJID       win_id,
        OMuword          win_os,
        struct DPgra_gad *gg_ptr );



from IGEwinsup import pre_update, post_update;
from GRgraphics import GRdisyourself; 
from IGEwinsup import pre_single_display, post_single_display;

struct DPdismsg
{
	IGRlong *msg;
	IGRshort *mx_type;
	IGRdouble *matrix;
	enum GRdpmode *mode;
	struct IGRaltdisplay *alt_symb;
	struct DP_information *dp_info;
	OM_p_KEY_DESC range_key;
};



#ifndef NULL
#define NULL 0
#endif


method GRviewdyn_set_up(IGRlong *msg; IGRdouble stroke_scale_factor)
{

   IGRdouble	*dbl_ptr2;
   IGRdouble	*dbl_ptr3;
   IGRdouble	id_mtx[16];
   IGRdouble	inv_mtx[16];
   IGRint	i;
   IGRdouble	*gpipe_fb_buf;
   IGRint	status = TRUE;
   IGRint	fb_gpipe_id;
   IGRshort	rect;
   IGRshort	front;
   IGRshort	back;
   IGRshort	four = 4,j,k;
   IGRlong	eight = 8;
   IGRdouble	pt[24],min,max;

   struct DPrange_check	rng_check;

	
/* set up matrices so that world coordinates are mapped to world coordinates */

	ME.IGEgragad->gragad.flags |= AXIS_WLD_ALIGN;

	if (ME.IGEgragad->gragad.flags & IS_PERSP)
	{
		/* change vw_volume to make it a cube like parallel */

                for (k=0, i = 0; i < 8; i++)
                {
			pt[k++] = (i&1) ? ME.IGEgragad->gragad.dit_clip_range[3] :
				ME.IGEgragad->gragad.dit_clip_range[0];
			pt[k++] = (i&2) ? ME.IGEgragad->gragad.dit_clip_range[4] :
				ME.IGEgragad->gragad.dit_clip_range[1];
			pt[k++] = (i&4) ? ME.IGEgragad->gragad.dit_clip_range[5] :
				ME.IGEgragad->gragad.dit_clip_range[2];
                }
		if (!MAptsxform(msg, &eight,
			    (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
			     pt, pt))
		{
#ifdef DEBUG
			printf("error in ptsxform\n");
#endif
		}

		for (j = 0; j < 3; j++)    /* for x,y,z coordinate */
		{
		       min = max = pt[j];
		       for (i = 0, k = j; i < 8; i++, k += 3)
		       {
		           min = ( pt[k] < min ) ? pt[k] : min;
		           max = ( pt[k] > max ) ? pt[k] : max;
		       }
		       ME.IGEgragad->gragad.dit_clip_range[j] = min;
			ME.IGEgragad->gragad.dit_clip_range[j+3] = max;
		}
	} 

	MAidmx(msg,id_mtx);

	dbl_ptr2 = (IGRdouble *)ME.IGEgragad->gragad.wld_to_viewport;
	dbl_ptr3 = (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld;

	for (i = 0; i < 16; i++)
	{
	   *dbl_ptr2++ = id_mtx[i];
	   *dbl_ptr3++ = id_mtx[i];
	}

	DPsetrng(msg, (IGRdouble *)ME.IGEgragad->gragad.wld_to_viewport,
			&ME.IGEgragad->gragad.range_chk);


/* create gpipe feedback buffer	*/

	gpipe_fb_buf = DPinq_gpipe_fb_buf();

	if ( DLcreate_feedback_pipeline( DL_ORTHO_PIPE, gpipe_fb_buf, DPFB_BUF_SIZE, &fb_gpipe_id ) != DL_SUCCESS )
	{
	   status = FALSE;
	   goto wrapup;
	}

/* set up gpipe with correct information  */

	DLset_curve_max_points( fb_gpipe_id, 100 );

        rect = ME.IGEgragad->gragad.flags & CLIP;
        front = ME.IGEgragad->gragad.flags & FRONT_CLIP;
        back = ME.IGEgragad->gragad.flags & BACK_CLIP;

	ME.IGEgragad->gragad.gpipe_id = fb_gpipe_id;

        DPpush_vwmtx(msg,id_mtx,
	   ME.IGEgragad->gragad.vvol_viewport_scale,
	   ME.IGEgragad->gragad.gpipe_id,
           NULL, NULL, NULL );

/* dit tolerance is equivalent to world tolerance (mapping world to world)  */

	DLset_curve_tolerance( fb_gpipe_id,
			(double) (2.0/ stroke_scale_factor) / ME.IGEgragad->gragad.vvol_viewport_scale,
			(double) (2.0 / stroke_scale_factor)/ ME.IGEgragad->gragad.vvol_viewport_scale );


/* calculate range in world coordinates */

	MAinvmx(msg, &four, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
				inv_mtx);
	DPsetrng(msg,inv_mtx,&rng_check);
	if (!(ME.IGEgragad->gragad.flags&IS_PERSP))
	{
		DPgetrng(msg,inv_mtx,&rng_check,ME.IGEgragad->gragad.vw_volume,
			ME.IGEgragad->gragad.dit_clip_range);
	}


        /* added vw_volume parameter for OPENGL setup for perspective */	
        DPpush_clip(msg,rect,front,back,ME.IGEgragad->gragad.dit_clip_range,
	    ME.IGEgragad->gragad.gpipe_id, ME.IGEgragad->gragad.vw_volume);



	ME.IGEgragad->gragad.flags |= DPVIEW_DYNAMICS;


wrapup:

	return(status);
}


method GRviewdyn_reset(IGRlong *msg)
{
   IGRint	status = TRUE;



/* Delete fb gpipe */

	DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id );


	status = om$send  ( mode = OM_e_wrt_message, 
        		    msg = message Root.delete(1), 
               		    senderid = my_id, 
               		    targetid = my_id);


	return(status);
}



method DPgen_update (IGRlong *msg; struct DPdit_range *range; 
                 IGRboolean *update_all; enum GRdpmode mode; IGRboolean erase)

{


   IGRint                 sts, msg_int;            /* OM return status         */

   enum GRlocate_types    loc_type;
   struct GRlc_upd_loc    loc_parms;
   struct GRmd_env        mdenv;
   struct DP_information  dp_info;
   IGRint                 num_byte;
   IGRint                 byte_rcvd;   
   IGRshort               rect,front,back;
   IGRdouble              *my_range;
   struct GRid            gragad_id;
   OMuint                 count;
   OM_S_CHANSELECT        chandef;


	sts = OM_S_SUCCESS; 
	*msg = MSSUCC;
			

	sts = om$make_chanselect (channame = "IGEgragad.winsup", 
			    p_chanselect = &chandef);
			
	if (!(sts & 1))
	{
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }
			
       sts = om$get_channel_count(objid = my_id, 
                                 p_chanselect = &chandef, 
                                 count = &count);

	
        if (!(sts & 1))
        {
            
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }

	gragad_id.objid = my_id;
	gragad_id.osnum = OM_Gw_current_OS;




	loc_parms.is_ortho = 1;
 
    /* get dpb information    */

	num_byte = sizeof(struct GRmd_env);
	gr$get_module_env( msg = &msg_int, 
		        sizbuf = &num_byte, 
		        buffer = (IGRchar *)&mdenv, 
		          nret = &byte_rcvd);


        *msg = msg_int;
	if ( ! (1&(msg_int)) )
	{
#ifdef DEBUG            
           printf("\nGRwn.update get_module_env\n");
           printf(" msg is 0x%x\n",msg_int);
#endif
           goto wrapup0;
	}

	ex$get_cur_mod(	id = &mdenv.md_id.objid,
			osnum = &mdenv.md_id.osnum);


        if ( ME.IGEgragad->gragad.flags & DP_GROUND_PLANE )
        {
          DPdraw_ground_plane( my_id, OM_Gw_current_OS, &ME.IGEgragad->gragad );
        }


/*-----------------------------------------------------------------------*/
    /* call locate          */

	loc_type = GR_upd_loc;
	loc_parms.msg = *msg;
	loc_parms.mode = mode;
	loc_parms.alt_symb = 0;

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

/**** BEGIN LOCAL PLOT changes.     -Gangadhar **********/
        
	if(!(DEget_localplot()))
        {
	        memcpy((char *)loc_parms.upd_range,
		  (char *) ME.IGEgragad->gragad.dit_clip_range,
                    sizeof(IGRdouble)*6);
	}
	else
	{
		my_range = (IGRdouble *)range;
	        memcpy((char *)loc_parms.upd_range,
		  (char *) my_range, sizeof(IGRdouble)*6);

		rect = ME.IGEgragad->gragad.flags & CLIP;
		front = ME.IGEgragad->gragad.flags & FRONT_CLIP;
		back = ME.IGEgragad->gragad.flags & BACK_CLIP;

                /* added vw_volume parameter for OPENGL setup for perspective */	
		DPpush_clip(msg,rect,front,back,loc_parms.upd_range,
		    ME.IGEgragad->gragad.gpipe_id, ME.IGEgragad->gragad.vw_volume);
	}
/*** END  LOCAL PLOT *****/

	if (count)
	{

            sts = om$send(msg = message IGEwinsup.pre_update(msg, 
					&gragad_id, &dp_info,&mdenv), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
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

            sts = om$send(msg = message IGEwinsup.post_update(msg, 
								&gragad_id), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
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



wrapup0:

/*-----------------------------------------------------------------------*/


wrapup:

   return(sts);
 }





 method DPdisbyoid (IGRlong *msg;enum GRdpmode *mode;
		       struct GRid *buffer; IGRlong *no_oids;
		       IGRshort *type; IGRmatrix *matrix[];
		       struct IGRaltdisplay *alt_symb)



    {

       IGRint sts,i;
       struct GRid	gragad_id, graphic_id;
       struct DP_information sp_info;
       struct DPdismsg	dismsg;
       OM_S_CHANSELECT  chandef;
       OM_S_MESSAGE	display_msg;
       OMuint		count;

	*msg = MSSUCC;
        sts = OM_S_SUCCESS;


	sts = om$make_chanselect (channame = "IGEgragad.winsup", 
			    p_chanselect = &chandef);
			
        if (!(sts & 1))
        {
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }
			
	sts = om$get_channel_count(objid = my_id, 
                                 p_chanselect = &chandef, 
                                 count = &count);

	
        if (!(sts & 1))
        {
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }

	gragad_id.objid = my_id;
	gragad_id.osnum = OM_Gw_current_OS;


	sp_info.gragad = &ME.IGEgragad->gragad;
	sp_info.win_no = ME.IGEgadget->win_no;
	sp_info.is_update = FALSE;
	sp_info.is_fit = FALSE;
	sp_info.is_hidden_line = FALSE;
	sp_info.hline_info = NULL;
	sp_info.hl_tiler = NULL;
	sp_info.view_objid = my_id;
	sp_info.view_osnum = OM_Gw_current_OS;


	for (i=0; i < (*no_oids); i++,buffer++,type++,matrix++)
	{
		
	   if (count)
	   {
		
	      graphic_id = *buffer;

	      sts = om$send(msg = message IGEwinsup.pre_single_display(msg, 
								&gragad_id, 
								&graphic_id), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
              /* protect against unknown objects */
              if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

	      if (!(sts & 1))
	      {
#ifdef DEBUG
	        printf("Error in Window's DPdisbyoid, Error: ");
	        om$report_error(sts = sts);
#endif
	        *msg = MSFAIL;
	        goto wrapup;
	      }
				
	   }

	   /* This expects and IGRmatrix parameter (matrix) and can't type cast to IGRmatrix */
	   sts = GRcheckref(msg,type,*matrix[0],&OM_Gw_current_OS,
			&buffer->osnum);
	   
	   if ((*msg != GRNOTREFFILE) && ( 1 & *msg & sts))
	   {

		dismsg.msg = msg;
		dismsg.mx_type = type;
		dismsg.matrix = (IGRdouble *) *matrix;
		dismsg.mode = mode;
		dismsg.alt_symb = alt_symb;
		dismsg.dp_info = &sp_info;
		dismsg.range_key = NULL;

		om$make_message( classname = "GRgraphics",
				 methodname = "GRdisyourself",
				 size = sizeof (struct DPdismsg),
				 p_arglist = &dismsg,
				 p_msg = &display_msg);



		sts = GRdisthruref(msg,&display_msg,buffer);

	   }
	   else
	   {
	        sts = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdisyourself(msg,type,
			  (IGRdouble *) *matrix,mode,alt_symb,&sp_info, 0),
                        senderid = my_id,
                        targetid = buffer->objid,
                        targetos = buffer->osnum);
	  }

	   if (!(sts & 1))
	   {
#ifdef DEBUG
	     printf("Error in Window's DPdisbyoid, Error: ");
	     om$report_error(sts = sts);
#endif
	     *msg = MSFAIL;
	     goto wrapup;
	   }
	   else
	   {
		if (!( *msg & 1))
		{
		   goto wrapup;
		}
	   }
	
	   if (count)
	   {
		

	      sts = om$send(msg = message IGEwinsup.post_single_display(msg, 
								&gragad_id, 
								&graphic_id), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
              /* protect against unknown objects */
              if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

	      if (!(sts & 1))
	      {
#ifdef DEBUG
	        printf("Error in Window's DPdisbyoid, Error: ");
	        om$report_error(sts = sts);
#endif
	        *msg = MSFAIL;
	        goto wrapup;
	      }
				
	   }
	
	}

wrapup:
	
	return(sts);

}

method DPdisbybuf (IGRlong *msg; enum GRdpmode *mode;
		       struct DPele_header  *buffer; IGRlong *no_elem;
		       IGRint view_ind; IGRint view_ind_type;
		       IGRdouble *view_ind_point)
    {

	      
       IGRint 		sts,i,msg_int;
       struct DPviewinfo	old_view_info;
       struct DP_information sp_info;


	*msg = MSSUCC;
	sts = OM_S_SUCCESS;


	sp_info.gragad = &ME.IGEgragad->gragad;
	sp_info.win_no = ME.IGEgadget->win_no;
	sp_info.is_update = FALSE;
	sp_info.is_fit = FALSE;	
	sp_info.is_hidden_line = FALSE;
	sp_info.hline_info = NULL;
	sp_info.hl_tiler = NULL;
	sp_info.view_objid = my_id;
	sp_info.view_osnum = OM_Gw_current_OS;

	if (view_ind)
	{
	   dp$set_view_ind(	type = view_ind_type,
				point = view_ind_point,
				dp_info = &sp_info,
				old = &old_view_info);
	}

	for (i=0; i < (*no_elem); i++,buffer++)
	{
	   if ( ! DPdiselem( &msg_int, buffer, mode, &sp_info ) )
	   {
#ifdef DEBUG
	     printf("Error in Window's DPdiselem, Error: ");
#endif
	     *msg = MSFAIL;
	     goto wrapup;
	   }
	   else
	   {
	        *msg = msg_int;
		if (!(*msg & 1))
		{
		   goto wrapup;
		}
	   }

	}
wrapup:
	if (view_ind)
	{
	   dp$reset_view_ind(	dp_info = &sp_info,
				old = &old_view_info);
	}

	return(sts);


	}

end implementation GRviewdyn;
