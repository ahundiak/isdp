

class implementation IGEgragad;

#include <stdio.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "igr.h"
#include "igrdp.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
#include "madef.h" 
#include "dpstruct.h" 
#include "ma.h"

%safe
/* prototype files */
#include "DPmpflyfunc.h"
#include "DPsetinq.h"

#include "maasin.h"
#include "masincos.h"
#include "madabs.h"
#include "maatan.h"
#include "masqrt.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "maptsxfor.h"
#include "mazrotmx.h"
%endsafe

/* #define DISPLAY_DELTA	.001 */
#define DISPLAY_DELTA		1.0 

/* ******************************************************************	*/
/* This function changes all the data in the Window Gragad so that a	*/
/* 'fly in' towards the center_pnt is effected.				*/
/*	---------------------------------------------------------------	*/
#if defined(__STDC__)
int DPmpflyfunc ( IGRlong     *msg,
                  IGRshort    in_out_flag,
                  IGRdouble   *center_pnt,
                  IGRdouble   factor, 
                  IGRboolean  update,
                  GRobjid     *gg_objid,
                  GRspacenum  *gg_osnum )
#else
int DPmpflyfunc (msg, in_out_flag, center_pnt, factor, update,gg_objid,gg_osnum)

	IGRlong     *msg;
	IGRshort    in_out_flag;
	IGRdouble   *center_pnt;
	IGRdouble   factor; 
	IGRboolean  update;
	GRobjid     *gg_objid;
	GRspacenum  *gg_osnum;
#endif

{

	/* Alex did this */
	IGRdouble  vw_vec[3];
	IGRdouble  rotation[4][4];
	IGRdouble  *near_depthz;
	IGRdouble  *far_depthz;


	struct DPgra_gad   gg;
	struct DPgra_gad   *p_gg;
	IGRlong            num_points = 1;

	/* ------------------------------------------------------------	*/
	/* this is needed to preserve any view volume messages such 	*/
	/* as (maximum window - DPDGNLIMIT) 				*/
	/* ------------------------------------------------------------	*/
	IGRlong            vol_msg = MSSUCC; 

	IGRboolean         update_all = FALSE;
	IGRdouble          temp[3],d1,old_coi_vw[3];
	IGRdouble          vw_coi[3];
	IGRdouble          tmp_vw_coi2;
	IGRdouble          vv_ext[2];
	IGRdouble          sine;
	IGRdouble          m_cos;
	IGRdouble          persp_fact;
	IGRdouble          half_angle;
	IGRdouble          ydelta;
	IGRdouble          trans[4][4];
	IGRdouble          wld_to_view[4][4];
	IGRint             status = OM_S_SUCCESS;
	IGRlong            per_msg = MSSUCC;
	IGRshort           four=4;
	struct var_list    var_list[2];
	IGRlong            return_bytes;
	IGRlong            which_error;
	IGRboolean         pos_coi;
	IGRdouble          vw_eye[3];
	IGRdouble          view_to_wld[4][4];
	IGRdouble          distance;
	IGRdouble          distance_eyept_is_moved;

	*msg = MSSUCC;

	p_gg = &gg;
	pos_coi = FALSE;


	/* ***** ------------------------------------------------****	*/
	/* In this section, we acquire the graphic gadget data and then */
	/* call DPcenter with the centerpoint.  DPcenter will center	*/
	/* the window (graphic gadget) about the x & y values of the	*/
	/* centerpt.  After that, all we have to do is move in closer	*/
	/* to the object, since the lateral movement has been taken	*/
	/* care of.  This means that the line of sight is kept parallel	*/

		/* ----------------------------------------------------	*/
		/* Get gragad instance data.				*/
		/* ----------------------------------------------------	*/
		var_list[0].var = GRAGAD_STRUCT;
    		var_list[0].var_ptr = (IGRchar *)&gg;
    		var_list[0].num_bytes = sizeof(struct DPgra_gad);
    		var_list[0].bytes_returned = &return_bytes;
		var_list[1].var = END_PARAM;
	
		dp$inq_set_gragad (msg =msg, which_error = &which_error, 
			      var_list = var_list, 
			      gragad_objid = *gg_objid,
                              osnum =  *gg_osnum);
        	if ( !(status & 1))
        	{
#ifdef DEBUG
              		printf("\nin DPinquire failed\n");
			om$report_error(sts = status);
#endif
			goto fini;
        	}
		/* ----------------------------------------------------	*/

		if (center_pnt != NULL)
		{

		/*-----------------------------------------------------------*/
		/* July 2 -- T. Wang					     */
		/* if persp,map center_pnt from act_z plane to the coi plane */
		/* This is only a temporary fix to the losing object problem */
		/*-----------------------------------------------------------*/
		if( gg.flags & IS_PERSP)
		{
    		    MAidmx(msg,(IGRdouble *)trans);
    		    trans[0][3] = -gg.eye_pt[0];
    		    trans[1][3] = -gg.eye_pt[1];
    		    trans[2][3] = -gg.eye_pt[2];
    		    MAmulmx(msg, &four, &four, &four, (IGRdouble *)gg.rotation,
                            (IGRdouble *)trans, (IGRdouble *)wld_to_view);

    		    MAinvmx(msg, &four, (IGRdouble *)wld_to_view,
                            (IGRdouble *)view_to_wld);

    		    MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view,
                               center_pnt,temp); 

    		    MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view,
                               gg.coi,old_coi_vw);

		    center_pnt[2] = old_coi_vw[2];  /* center_pnt on new plane */
		    d1 = old_coi_vw[2]/temp[2];
		    d1 = (d1 > 0)? d1 : -d1;
		    center_pnt[0] = temp[0] * d1;
		    center_pnt[1] = temp[1] * d1;

    		    MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
                               center_pnt, center_pnt);
		}
		/* note, for NON_persp, it doesn't matter on which plane */


		/* adjust window to new center*/

	    		status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcenter
						(&vol_msg,center_pnt,FALSE),
                             senderid = NULL_OBJID,
                             targetid = *gg_objid,
			     targetos = *gg_osnum);
	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
		                printf("\nDPzoom Error DPcenter failed\n");
                		om$report_error(sts = status);
#endif
				goto fini;
            		}
		}




	/* ------------------------------------------------------------ */
	/* Get gragad instance data.  We need to do this again, since	*/
	/* DPcenter has changed it.					*/
	/*        ----------------------------------------------------- */
	var_list[0].var = GRAGAD_STRUCT;
    	var_list[0].var_ptr = (IGRchar *)&gg;
    	var_list[0].num_bytes = sizeof(struct DPgra_gad);
    	var_list[0].bytes_returned = &return_bytes;
	var_list[1].var = END_PARAM;
	
	dp$inq_set_gragad (msg =msg, which_error = &which_error, 
			      var_list = var_list, 
			      gragad_objid = *gg_objid,
                              osnum =  *gg_osnum);
        if ( !(status & 1))
        {
#ifdef DEBUG
              	printf("\nin DPinquire failed\n");
		om$report_error(sts = status);
#endif
		goto fini;
        }
	/* ------------------------------------------------------------ */



	if ((p_gg->flags & IS_PERSP))
	{
    		persp_fact = factor;
    		half_angle = p_gg->vw_angle / 2.0;
    		if (!MAsincos(msg,&half_angle,&sine,&m_cos) )
    		{
	    		goto fini;
    		}


		/* ----------------------------------------------------	*/
		/* Create a transformation to a special coordinate	*/
		/* system.  This system will have the eyept as its	*/
		/* origin, and the line between the COI and the eyept	*/
		/* as its Z axis.  This will make for easier changes.	*/
		/* ----------------------------------------------------	*/
    		if (!MAidmx(msg, (IGRdouble *)trans))
    		{
    			goto fini;
    		}
		/* ----------------------------------------------------	*/
		/* translate eyept to the origin			*/
		/* ----------------------------------------------------	*/
    		trans[0][3] = -p_gg->eye_pt[0];
    		trans[1][3] = -p_gg->eye_pt[1];
    		trans[2][3] = -p_gg->eye_pt[2];

		/* ----------------------------------------------------	*/
		/* Find the view vector (the vector between the eyept	*/
		/* and the center of interest) so that we can rotate	*/
		/* to have it become our Z axis.			*/
		/* ----------------------------------------------------	*/
    		vw_vec[0] = p_gg->eye_pt[0] -  p_gg->coi[0];
    		vw_vec[1] = p_gg->eye_pt[1] -  p_gg->coi[1];
    		vw_vec[2] = p_gg->eye_pt[2] -  p_gg->coi[2];

		/* ----------------------------------------------------	*/
    		/* Create transformation to rotate to system with z 	*/
		/* axis of vw_vec 					*/
		/* ----------------------------------------------------	*/
    		if (!MAzrotmx(msg, vw_vec, (IGRdouble *)rotation))
    		{
			goto fini;
    		}

		/* ----------------------------------------------------	*/
    		/*  Create composite transformation			*/
		/* ----------------------------------------------------	*/
    		if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)rotation,
                            (IGRdouble *)trans, (IGRdouble *)wld_to_view))
    		{
			goto fini;
    		}

		/* ----------------------------------------------------	*/
		/* Create inverse transformation to map from our	*/
		/* coordinate system back to world coordinates.		*/
		/* ----------------------------------------------------	*/
    		if ( !MAinvmx(msg,&four, (IGRdouble *)wld_to_view,
                              (IGRdouble *)view_to_wld))
    		{
			goto fini;
    		}


    		/* translate coi to viewing coordinates			*/
    		if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view,
                                p_gg->coi,vw_coi))
		{
#ifdef DEBUG
	    		printf("\nin COwnctr pt transfrom failed\n");
#endif
	    		goto fini;
		}            

		if (vw_coi[2] > 0) pos_coi = TRUE;
		/* ---------------------------------------------------	*/
		/* Alex - I changed this to store the absolute value in	*/ 
		/* a temp variable because we use vw_coi[2] later.	*/
		/* ----------------------------------------------------	*/
		tmp_vw_coi2 = MAdabs(msg,&vw_coi[2]);
     		ydelta = (sine/m_cos) * tmp_vw_coi2;

		if ( in_out_flag == 0 )
        	{
	     		ydelta = ydelta / factor;
        	}
        	else
        	{
	     		ydelta = ydelta * factor;
		}
		ydelta = MAdabs(msg,&ydelta);  


		/* ----------------------------------------------------	*/
		/* distance is distance from center of interest (coi)  	*/
		/* to the new eyept.					*/
		/* ---------------------------------------------------- */
		distance = ydelta * (m_cos/sine);
		distance = MAdabs(msg, &distance);
		vw_eye[0]=0;
		vw_eye[1]=0;
		vw_eye[2]= distance - tmp_vw_coi2 ;
		distance_eyept_is_moved = MAdabs(msg, &vw_eye[2]);
		if(pos_coi) vw_eye[2] = -vw_eye[2];

		/* ---------------------------------------------------- */
		/* Transform viewing eyept back to world coordinates 	*/
		/* and then store it in p_gg.				*/
		/* ---------------------------------------------------- */
		if(!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
                               vw_eye, p_gg->eye_pt))
		{
	    		goto fini;
		}


		/*  ------------------------------------------------------- */
		/*   Alex - Here we must change the view volume 	    */
		/*   	(display depths)				    */
		/*							    */
		/*  fly IN: What we do is let the eyept move all the way    */
		/*  up to the near display depth without changing the far   */
		/*  display depth.  Remember that the display depths are    */
		/*  delta values representing distances from the eyept.  So */
		/*  in zooming in, we actually make the near depth smaller  */
		/*  so that the eyept and the near depth plane actually	    */
		/*  become the same (within our DISPLAY DELTA).		    */
		/*  ------------------------------------------------------- */
		near_depthz = &p_gg->vw_volume[2];
		far_depthz = &p_gg->vw_volume[5];

		if( in_out_flag == 0)
		{
			/*  ZOOM IN	*/
			if( distance_eyept_is_moved > 
				(*near_depthz - DISPLAY_DELTA) )
			{
				/* ------------------------------------	*/
				/* 					*/
				/* We've zoomed in past where near 	*/
				/* display depth was, so set near depth */
				/* to be close to 0 so that near 	*/
				/* clipping plane is just barely in 	*/
				/* front of eyept.  This gives us the 	*/
				/* most	hope of not clipping off the 	*/
				/* object we are zooming towards in the */
				/* picture.				*/
				/* ------------------------------------ */
				*near_depthz = DISPLAY_DELTA;
			}
			else
			{
				/* ------------------------------------ */
				/* Move near clipping plane closer to 	*/
				/* the eyept so we don't clip off any 	*/
				/* objects the user			*/
				/* may be zooming in towards.		*/
				/* ------------------------------------ */
				*near_depthz -= distance_eyept_is_moved;
			}
		}
		else
		{
			/* -------------------------------------------- */
			/*  ZOOM OUT					*/
			/* If zooming out, simply enlarge the view 	*/
			/* volume by pushing out the far display depth.	*/
			/* -------------------------------------------- */
			*far_depthz += distance_eyept_is_moved;
		}

    		dp$inq_set_gragad (msg =msg, which_error = &which_error, 
			      var_list = var_list, inq0_set1 = 1,
			      gragad_objid = *gg_objid,
                              osnum =  *gg_osnum);
    		if ( !(status & 1))
    		{
#ifdef DEBUG
               		printf("\nin COsavevw  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			goto fini;
    		}

		if (center_pnt != NULL)
		{
	    		status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcenter
						(&vol_msg,center_pnt,update),
                             senderid = NULL_OBJID,
                             targetid = *gg_objid,
			     targetos = *gg_osnum);
	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
		                printf("\nDPzoom Error DPcenter failed\n");
                		om$report_error(sts = status);
#endif
				goto fini;
            		}
		}
	}	/* end perspective	*/
	else

	{	
		/* --------------------------------------------	*/
		/* ELSE we have a parallel view			*/
		/* --------------------------------------------	*/
    		if (center_pnt == NULL)	
    		{
    			temp[0] = (p_gg->vw_volume[3] + 
				p_gg->vw_volume[0]) / 2.0;
    			temp[1] = (p_gg->vw_volume[4] + 
				p_gg->vw_volume[1]) / 2.0;
    		}
    		else
    		{
    			OM_BLOCK_MOVE (center_pnt, temp, sizeof(IGRdouble)*3);

			/* applies a transform to a point */
    			if(!MAptsxform(msg, &num_points, (IGRdouble *)p_gg->wld_to_view,
				temp, temp))
    			{
#ifdef DEBUG
            		    	printf("\nin COwnrot  pt transfrom failed\n");
#endif
	    		     	goto fini;
    			}            
    		}

    		/* get extents of view volume */	
    		vv_ext[0] = p_gg->vw_volume[3] - p_gg->vw_volume[0];
    		vv_ext[1] = p_gg->vw_volume[4] - p_gg->vw_volume[1];

    		if ( in_out_flag == 0 )    /* zoom in */
    		{
			/* vw_volume represents two points which are 	*/
			/* the min and max points of the area to which 	*/
			/* the view volume is being mapped Here, we are */
			/* calculating the new points.  Note that the	*/
			/* points are calculated using the old extents 	*/
			/* changed by a	factor. (the factor is decided 	*/
			/* by the user.)				*/
			p_gg->vw_volume[0] = temp[0] - vv_ext[0] / 
				(2 * factor);
        		p_gg->vw_volume[3] = temp[0] + vv_ext[0] / 
				(2 * factor);
        		p_gg->vw_volume[1] = temp[1] - vv_ext[1] / 
				(2 * factor);
        		p_gg->vw_volume[4] = temp[1] + vv_ext[1] / 
				(2 * factor);
    		}
    		else  /* zoom out */
    		{
    			p_gg->vw_volume[0] = temp[0] - vv_ext[0] * factor / 2;
        		p_gg->vw_volume[3] = temp[0] + vv_ext[0] * factor / 2;
        		p_gg->vw_volume[1] = temp[1] - vv_ext[1] * factor / 2;
        		p_gg->vw_volume[4] = temp[1] + vv_ext[1] * factor / 2;
    		}
    		dp$inq_set_gragad (msg =msg, which_error = &which_error, 
			      var_list = var_list, inq0_set1 = 1,
			      gragad_objid = *gg_objid,
                              osnum =  *gg_osnum);
    		if ( !(status & 1))
    		{
#ifdef DEBUG
               		printf("\nin COsavevw  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			goto fini;
    		}
	}

	if ((!(p_gg->flags & IS_PERSP)) || (center_pnt == NULL))
	{
		/* ----------------------------------------------------	*/
	    	/* Make a call to DPcal, which calculates the new	*/
	    	/* transformation matrix for the window.		*/
		/* ----------------------------------------------------	*/
	    	status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = NULL_OBJID,
                             targetid = *gg_objid,
			     targetos = *gg_osnum);
	    	if ( ! (1 & status) )
            	{
#ifdef DEBUG
                	printf("\nIN DPzoom Error send to window DPcal\n");
                	om$report_error(sts = status);
#endif
                	goto fini;	  
            	} 


	    	if (update)
	    	{
	       		if ( !(p_gg->flags & DP_DELAY))
	       		{
		  		/* ALEX - this updates the window object */
	          		status = om$send(mode = OM_e_wrt_object,
                             		msg = message IGEgragad.DPupdate(msg,
						NULL,	&update_all),
                             		senderid = NULL_OBJID,
                             		targetid = *gg_objid,
			     		targetos = *gg_osnum);

	      	   		if ( ! (1 & status) )
            	   		{
#ifdef DEBUG
		                	printf("\nDPFLYfunc: Error in ");
					printf("send to window DPupdate\n");
                			om$report_error(sts = status);
#endif
                			goto fini;	  
            	    		} 
	        	}
			else
			{
		   		ex$message( msgnumb = GR_I_DlyOn);
			}

	    	}
	}
	if(*msg == MSSUCC)
	{
	    if (per_msg !=MSSUCC)
	    {
	    	*msg = per_msg;
	    }
	    else
	    {
	    	*msg = vol_msg;
	    }
	}


fini:
	return(status);


}

end implementation IGEgragad;
