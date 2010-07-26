/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: IGEgragad
     METHOD NAME: DPcenter

     Abstract:  DPcenter performs a "window" center on a graphic gadget.
		This means that the view volume is changed so that it is
		centered around wld_point.
-----
%SC%    

    VALUE = OM_S_SUCCESS

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     wld_point	   IGRdouble	 a point in world coordinates that 
				 you want the view volume centered around
				
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong        completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE () =

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
        
        MAS     05/01/87 : Design date.
	MSP	05/19/89 : taking measures to keep the view angle positive
				using absolute value
	JDU	06/13/91 : Integrated Alex Carr's (I/Design) changes into
				DPzoom to keep same angle in perspective
				mode when zooming in and out so that the 
				perspective is the same only larger objects.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;
#define DEBUG	1

#include <stdio.h>

/* These include files added for additions from I/Design */
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
/* End added include files */

#include "grimport.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "madef.h"
#include "dpstruct.h"
#include "dpcodef.h"
#include "dpcomacros.h"
#include "ma.h"

/* prototype files */
%safe
#include "DPcodpbi.h"

#include "maatan.h"
#include "madabs.h"
#include "mainvmx.h"
#include "maidmx.h"
#include "martrnmx.h"
#include "mazrotmx.h"
#include "masincos.h"
#include "mamulmx.h"
#include "maptsxfor.h"
#include "ma2ptdis.h"
%endsafe

#define DISPLAY_DELTA  1.00

method DPcenter (IGRlong *msg; IGRdouble *wld_point; IGRboolean update)
{
struct DPgra_gad *p_gg;
IGRlong num_points = 1;
IGRlong vol_msg = MSSUCC; /* this is needed to preserve any view volume 
			     messages such as (maximum window - DPDGNLIMIT) */
IGRboolean update_all = FALSE;
IGRdouble temp[3];
IGRdouble delta[3];
IGRdouble new_coi_vw[3];
IGRdouble old_coi_vw[3];
IGRdouble coi_vw[3];
IGRdouble vv_ext[2];
IGRdouble view_to_wld[4][4];
IGRdouble trans[4][4];
IGRdouble wld_to_view[4][4];
IGRint status = OM_S_SUCCESS;
IGRshort four=4;


*msg = MSSUCC;

p_gg = &ME.IGEgragad->gragad;

#ifndef IDRAW

if (!(p_gg->flags & IS_PERSP))

#endif /* IDRAW */

{

	if(!MAptsxform(msg, &num_points, (IGRdouble *)p_gg->wld_to_view,
				wld_point, temp))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            

                /* calculate new vvol */
	
	vv_ext[0] = p_gg->vw_volume[3] - p_gg->vw_volume[0];
	vv_ext[1] = p_gg->vw_volume[4] - p_gg->vw_volume[1];
		
	p_gg->vw_volume[0] = temp[0] - vv_ext[0] /  2.0 ;
	p_gg->vw_volume[3] = temp[0] + vv_ext[0] /  2.0 ;
	p_gg->vw_volume[1] = temp[1] - vv_ext[1] /  2.0 ;
	p_gg->vw_volume[4] = temp[1] + vv_ext[1] /  2.0 ;
}
#ifndef IDRAW

else
{
    if (!MAidmx(msg, (IGRdouble *)trans))
    {
    	goto fini;
    }
    trans[0][3] = -p_gg->eye_pt[0];
    trans[1][3] = -p_gg->eye_pt[1];
    trans[2][3] = -p_gg->eye_pt[2];

    if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view))
    {
	goto fini;
    }
	if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, wld_point,
					new_coi_vw))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
	if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, p_gg->coi,
					old_coi_vw))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            

    delta[0] = new_coi_vw[0] - old_coi_vw[0];
    delta[1] = new_coi_vw[1] - old_coi_vw[1];
    delta[2] = 0;

    coi_vw[0] = new_coi_vw[0];
    coi_vw[1] = new_coi_vw[1];
    coi_vw[2] = old_coi_vw[2];

    if (!MAinvmx(msg, &four, (IGRdouble *)wld_to_view, (IGRdouble *)view_to_wld))
    {
	goto fini;
    }
    if(!MAptsxform(msg,&num_points, (IGRdouble *)view_to_wld,delta,p_gg->eye_pt))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
    if(!MAptsxform(msg,&num_points, (IGRdouble *)view_to_wld,coi_vw,p_gg->coi))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
}

#endif  /* IDRAW */

	    status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = my_id,
                             targetid = my_id);
	    if ( ! (1 & status) )
            {
#ifdef DEBUG
                printf("\nIN DPcenter Error send to window DPcal\n");
                om$report_error(sts = status);
#endif
                goto fini;	  
            } 

	    if (update)
	    {
	       if (!(p_gg->flags & DP_DELAY))
	       {
	          status = om$send(mode = OM_e_wrt_object,
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
	        }
		else
		{
		   ex$message( msgnumb = GR_I_DlyOn);
		}
	    }
	if(*msg == MSSUCC)
	{
	    *msg = vol_msg;
	}
fini:
	return(status);
}

/* called DPmpzoomfunc in I/Designs code */
method DPzoom (IGRlong *msg; IGRshort in_out_flag; IGRdouble
*center_pnt; IGRdouble factor; IGRboolean update)
{
struct DPgra_gad *p_gg;
IGRlong num_points = 1;
IGRlong vol_msg = MSSUCC; /* this is needed to preserve any view volume 
			     messages such as (maximum window - DPDGNLIMIT) */
IGRboolean update_all = FALSE;
IGRdouble temp[3];
IGRdouble vw_coi[3];
IGRdouble vv_ext[2];
IGRdouble sine;
IGRdouble m_cos;
IGRdouble persp_fact;
IGRdouble half_angle;
IGRdouble m_tan;
IGRdouble ydelta;
IGRdouble trans[4][4];
IGRdouble wld_to_view[4][4];
IGRint status = OM_S_SUCCESS;
IGRlong per_msg = MSSUCC;
IGRshort four=4;

/* added variables-JU */
	 IGRushort pflag;
	/*pflag=0 => same perspective angle, =! => dif perspec angle(original)*/
IGRdouble vw_vec[3];
IGRdouble rotation[4][4];
IGRdouble vw_eye[3];
IGRdouble view_to_wld[4][4];
IGRdouble distance;
	/* Alex did this */
	IGRdouble *near_depthz;
	IGRdouble *far_depthz;
	IGRdouble tmp_vw_coi2;
	IGRdouble distance_eyept_is_moved;
	IGRboolean pos_coi = FALSE;


*msg = MSSUCC;

p_gg=&ME.IGEgragad->gragad;

#ifndef IDRAW

dp$codpb_get_persp_flags( persp_flags= &pflag );

if (!(pflag & PERSP_CHANGE_ANGLE) && (p_gg->flags & IS_PERSP))
{
	/* ********************************************************************	*/
	/* ******************************************************************	*/
	/* This function changes all the data in the Window Gragad so that a	*/
	/* 'fly in' towards the center_pnt is effected.				*/
	/*	---------------------------------------------------------------	*/

	/* ***** ------------------------------------------------****	*/
	/* In this section, we acquire the graphic gadget data and then */
	/* call DPcenter with the centerpoint.  DPcenter will center	*/
	/* the window (graphic gadget) about the x & y values of the	*/
	/* centerpt.  After that, all we have to do is move in closer	*/
	/* to the object, since the lateral movement has been taken	*/
	/* care of.  This means that the line of sight is kept parallel	*/
		if (center_pnt != NULL)
		{
	    		status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcenter
						(&vol_msg,center_pnt,FALSE),
                             senderid = NULL_OBJID,
                             targetid = my_id);
	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
		                printf("\nDPzoom Error DPcenter failed\n");
                		om$report_error(sts = status);
#endif
				goto fini;
            		}
		}


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
    		if (!MAzrotmx(msg,vw_vec, (IGRdouble *)rotation))
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
    		if ( !MAinvmx(msg, &four, (IGRdouble *)wld_to_view,
				(IGRdouble *)view_to_wld))
    		{
			goto fini;
    		}


    		/* translate coi to viewing coordinates			*/
    		if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view,
					p_gg->coi, vw_coi))
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

		if(((in_out_flag==0)&&(persp_fact>1))||
		    ((in_out_flag!=0)&&(persp_fact<1)))
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
				*far_depthz -= distance_eyept_is_moved;
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
				*far_depthz -= distance_eyept_is_moved;
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

		if (center_pnt != NULL)
		{
	    		status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcenter
						(&vol_msg,center_pnt,FALSE),
                             senderid = NULL_OBJID,
                             targetid = my_id);
	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
		                printf("\nDPzoom Error DPcenter failed\n");
                		om$report_error(sts = status);
#endif
				goto fini;
            		}
		}
	/* end perspective and same view angle	*/
}

if ((p_gg->flags & IS_PERSP) && (pflag & PERSP_CHANGE_ANGLE))
{
    	persp_fact = factor;
    	half_angle = p_gg->vw_angle / 2.0;
    	if (!MAsincos(msg,&half_angle,&sine,&m_cos) )
    	{
	    goto fini;
    	}
    	if (!MAidmx(msg, (IGRdouble *)trans))
    	{
    		goto fini;
    	}
    	trans[0][3] = -p_gg->eye_pt[0];
    	trans[1][3] = -p_gg->eye_pt[1];
    	trans[2][3] = -p_gg->eye_pt[2];

    	/* I added this matrix multiplication to obtain view vector */
	/* This is the change to the zoom in out function that changes the 
           viewangle.  The code that is a change to zoom in out and keeps the 
           view angle the same is the above if clause */
	/* The following change was made because of an invalid assumption
	   of where to compute the angle (the view plane normal vector)
	   it is now changed to the view vector.  There is little difference
	   in the function of the code but is more correct. */

	vw_vec[0] = p_gg->eye_pt[0] -  p_gg->coi[0];
	vw_vec[1] = p_gg->eye_pt[1] -  p_gg->coi[1];
	vw_vec[2] = p_gg->eye_pt[2] -  p_gg->coi[2];

	/* I added this IF	*/
	if (!MAzrotmx(msg, vw_vec, (IGRdouble *)p_gg->rotation))
	{
		goto fini;
	}

	if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view))
	{
		goto fini;
	}

	if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, p_gg->coi,
			vw_coi))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
	vw_coi[2] = MAdabs(msg,&vw_coi[2]);
     	ydelta = (sine/m_cos) * vw_coi[2];
	if ( in_out_flag == 0 )
        {
	    ydelta = ydelta / factor;
        }
        else
        {
	     ydelta = ydelta * factor;
	}
	ydelta = MAdabs(msg,&ydelta);
	m_tan = ydelta/vw_coi[2];
	if (m_tan == 0)
	{
	    m_tan = 0.00000000000001;
	    per_msg = DPDGNSLIMIT;
	}

	p_gg->vw_angle = MAatan (msg,&m_tan) * 2.0;

	if (center_pnt != NULL)
	{
		status = om$send(mode = OM_e_wrt_object,
                            msg = message IGEgragad.DPcenter
					(&vol_msg,center_pnt,update),
                            senderid = NULL_OBJID,
                            targetid = my_id,
			/* needed ???targetos = *gg_osnum*/);

		if ( ! (1 & status) )
	        {
#ifdef DEBUG
                	printf("\nIN DPzoom Error send to window DPcenter\n");
                	om$report_error(sts = status);
#endif
			goto fini;
            	}
	}
}
if (!(p_gg->flags & IS_PERSP))

#endif /* IDRAW */

{	
    	if (center_pnt == NULL)	
    	{
    		temp[0] = (p_gg->vw_volume[3] + p_gg->vw_volume[0]) / 2.0;
    		temp[1] = (p_gg->vw_volume[4] + p_gg->vw_volume[1]) / 2.0;
    	}
   	else
    	{
    		OM_BLOCK_MOVE (center_pnt, temp, sizeof(IGRdouble)*3);

    		if(!MAptsxform(msg, &num_points, (IGRdouble *)p_gg->wld_to_view,
				temp, temp))
    		{
#ifdef DEBUG
            	    printf("\nin COwnrot  pt transfrom failed\n");
#endif
		    goto fini;
    		}            
    	}
    	vv_ext[0] = p_gg->vw_volume[3] - p_gg->vw_volume[0];
    	vv_ext[1] = p_gg->vw_volume[4] - p_gg->vw_volume[1];

    	if ( in_out_flag == 0 )    /* zoom in */
    	{
		p_gg->vw_volume[0] = temp[0] - vv_ext[0] / ( 2 * factor );
        	p_gg->vw_volume[3] = temp[0] + vv_ext[0] / ( 2 * factor );
        	p_gg->vw_volume[1] = temp[1] - vv_ext[1] / ( 2 * factor );
        	p_gg->vw_volume[4] = temp[1] + vv_ext[1] / ( 2 * factor );
    	}
    	else  /* zoom out */
    	{
    		p_gg->vw_volume[0] = temp[0] - vv_ext[0] * factor / 2;
        	p_gg->vw_volume[3] = temp[0] + vv_ext[0] * factor / 2;
        	p_gg->vw_volume[1] = temp[1] - vv_ext[1] * factor / 2;
        	p_gg->vw_volume[4] = temp[1] + vv_ext[1] * factor / 2;
    	}                    
}    	

	#ifndef IDRAW
	if ((!(p_gg->flags & IS_PERSP)) || (center_pnt == NULL))
	#endif /* IDRAW  */
	{
	    status = om$send(mode = OM_e_wrt_object,
        	                     msg = message IGEgragad.DPcal(&vol_msg),
                	             senderid = my_id,
                        	     targetid = my_id);
	}
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
	   	if (!(p_gg->flags & DP_DELAY))
	   	{
		         status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate(msg,NULL,
						&update_all),
                             senderid = my_id,
                             targetid = my_id);

	      		if ( ! (1 & status) )
            		{
#ifdef DEBUG
                		printf("\nIN DPzoom Error send to window DPupdate\n");
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

method DPscroll (IGRlong *msg; IGRdouble *wld_points; IGRboolean update)
{
IGRlong num_points = 2;
IGRlong vol_msg = MSSUCC; /* this is needed to preserve any view volume 
			     messages such as (maximum window - DPDGNLIMIT) */
IGRboolean  update_all = FALSE;
IGRdouble delta[3];
IGRdouble ex_pnts[6];
IGRdouble old_coi_vw[3];
IGRdouble trans[4][4];
IGRdouble wld_to_view[4][4];
IGRdouble view_to_wld[4][4];
IGRshort four=4;
struct DPgra_gad *p_gg;

IGRint status = OM_S_SUCCESS;
p_gg = &ME.IGEgragad->gragad;

*msg = MSSUCC;


#ifndef IDRAW

if ((p_gg->flags & IS_PERSP))
{
    if (!MAidmx(msg, (IGRdouble *)trans))
    {
    	goto fini;
    }
    trans[0][3] = -p_gg->eye_pt[0];
    trans[1][3] = -p_gg->eye_pt[1];
    trans[2][3] = -p_gg->eye_pt[2];

    if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view))
    {
	goto fini;
    }
    if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, wld_points, 
				ex_pnts ))
    {
#ifdef DEBUG
    	printf("\nDPscroll ptsxform\n");
#endif
    	goto fini;
    }
    delta[0] = ex_pnts[0] - ex_pnts[3];
    delta[1] = ex_pnts[1] - ex_pnts[4];
    delta[2] = 0;
    if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, p_gg->coi,
					old_coi_vw))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
    old_coi_vw[0] += delta[0];
    old_coi_vw[1] += delta[1];
/* old_coi_vw[2] should stay the same */

    if (!MAinvmx(msg, &four, (IGRdouble *)wld_to_view, (IGRdouble *)view_to_wld))
    {
	goto fini;
    }
    if(!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, delta,
				p_gg->eye_pt))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
    if(!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld, old_coi_vw,
				p_gg->coi))
	{
#ifdef DEBUG
	    printf("\nin COwnctr pt transfrom failed\n");
#endif
	    goto fini;
	}            
}
else
#endif  /* IDRAW  */

{
if (!MAptsxform(msg, &num_points, (IGRdouble *)p_gg->wld_to_view, wld_points, 
				ex_pnts ))
{
#ifdef DEBUG
    printf("\nDPscroll ptsxform\n");
#endif
    goto fini;
}
                delta[0] = ex_pnts[3] - ex_pnts[0];
                delta[1] = ex_pnts[4] - ex_pnts[1];
                p_gg->vw_volume[0] -= delta[0];
                p_gg->vw_volume[3] -= delta[0];
                p_gg->vw_volume[1] -= delta[1];
                p_gg->vw_volume[4] -= delta[1];
}
	    status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = my_id,
                             targetid = my_id);
	    if ( ! (1 & status) )
            {
#ifdef DEBUG
                printf("\nIN DPscroll Error send to window DPcal\n");
                om$report_error(sts = status);
#endif
                goto fini;	  
            } 


	    if (update)
	    {
	       if (!(p_gg->flags & DP_DELAY))
	       {
	          status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate(msg,NULL,
						&update_all),
                             senderid = my_id,
                             targetid = my_id);

	      	   if ( ! (1 & status) )
            	   {
#ifdef DEBUG
                	printf("\nIN DPscroll Error send to window DPupdate\n");
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
	if(*msg == MSSUCC)
	{
	    *msg = vol_msg;
	}
fini:

	return(status);
}
method DProtate (IGRlong *msg; IGRshort flag; IGRdouble *origin;
IGRdouble *mtx; IGRboolean update)

{
	IGRshort four=4;
	IGRboolean update_all = FALSE;
	IGRdouble trans[4][4];
	IGRdouble rotate[4][4];
	IGRdouble wld_to_view[4][4];		
	IGRdouble view_to_wld[4][4];		
	IGRdouble inv_rot[4][4];
	IGRdouble transform_mtx[4][4];
	IGRdouble complete_mtx[4][4];
	IGRdouble vw_eye[3];
	IGRdouble ex_origin[3];	
	IGRdouble temp[3];	
	IGRdouble vw_coi[3];	
	IGRdouble dist;	
	IGRdouble pt_rot[3]; /* point of rotation */
	struct DPgra_gad *p_gg;
	IGRint status = OM_S_SUCCESS;
	IGRlong num_points = 1;
	IGRlong vol_msg = MSSUCC; /* this is needed to preserve any view volume 
			     messages such as (maximum window - DPDGNLIMIT) */


	*msg = MSSUCC;
p_gg = &ME.IGEgragad->gragad;

#ifndef IDRAW
if (!(p_gg->flags & IS_PERSP))
{
#endif    
    if (origin != NULL)
    {
        OM_BLOCK_MOVE(origin,p_gg->origin,sizeof(IGRdouble)*3);
    }
    if ((origin == NULL) && (flag & ORIGIN_CENTER))
    {
 	temp[0]= (p_gg->vw_volume[3] + p_gg->vw_volume[0]) / 2.0;
	temp[1]= (p_gg->vw_volume[4] +	p_gg->vw_volume[1]) / 2.0;
	temp[2]= p_gg->act_z;

    	if (!MAinvmx(msg, &four, (IGRdouble *)p_gg->wld_to_view, 
				(IGRdouble *)view_to_wld))
    	{
#ifdef DEBUG
	    printf("error in DPcenter MAinvmx\n");
#endif
    	}

    	if (!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
				temp, p_gg->origin ))
    	{
#ifdef DEBUG
    	    printf("\nDPcenter ptsxform\n");
#endif
    	    goto fini;
    	}
    }

    if (!MAptsxform(msg, &num_points, (IGRdouble *)p_gg->wld_to_view, 
			p_gg->origin, ex_origin))
    {
#ifdef DEBUG
    	printf("\nDPcenter ptsxform\n");
#endif
    	goto fini;
    }
    p_gg->vw_volume[0] -= ex_origin[0];
    p_gg->vw_volume[3] -= ex_origin[0];

    p_gg->vw_volume[1] -= ex_origin[1];
    p_gg->vw_volume[4] -= ex_origin[1];

    p_gg->vw_volume[2] -= ex_origin[2];
    p_gg->vw_volume[5] -= ex_origin[2];

    p_gg->act_z -= ex_origin[2];
	
    if (flag & LEFT_MULT)
    {
    	if (!MAmulmx(msg, &four, &four, &four, (IGRdouble *)mtx,
			(IGRdouble *)p_gg->rotation, (IGRdouble *)rotate))
    	{
#ifdef DEBUG
	    printf("error in DProtate matrix multiple/n");
#endif
	goto fini;
    	}
        OM_BLOCK_MOVE(rotate,p_gg->rotation,sizeof(IGRdouble)*16);
    }
    if(flag & RIGHT_MULT)
    {
    	if (!MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
				(IGRdouble *)mtx, (IGRdouble *)rotate))
    	{
#ifdef DEBUG
	    printf("error in DProtate matrix multiple/n");
#endif
	goto fini;
        }
    	OM_BLOCK_MOVE(rotate,p_gg->rotation,sizeof(IGRdouble)*16);
    }
    if (flag & REPLACE_MTX)
    {
    	OM_BLOCK_MOVE(mtx,p_gg->rotation,sizeof(IGRdouble)*16);
    }
#ifndef IDRAW
} /* close for if not perspective */

else
{
    /* forming wld to left-handed-view mtx */
    MAidmx(msg, (IGRdouble *)trans);
    trans[0][3] = -p_gg->eye_pt[0];
    trans[1][3] = -p_gg->eye_pt[1];
    trans[2][3] = -p_gg->eye_pt[2];

    if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)p_gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view))
    {
	goto fini;
    }

    if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, p_gg->coi,
				vw_coi))
    {
    	goto fini;
    }

    if ((flag & RIGHT_MULT) || (flag & LEFT_MULT))
    {
    	if (origin != NULL)
    	{
    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, origin,
					pt_rot))
    	    {
    		goto fini;
    	    }
    	}
    	else
    	{
    	    OM_BLOCK_MOVE(vw_coi,pt_rot,sizeof(IGRdouble)*3);
    	}
    
    	MAidmx(msg, (IGRdouble *)trans);
    	trans[0][3] = -pt_rot[0];
    	trans[1][3] = -pt_rot[1];
    	trans[2][3] = -pt_rot[2];

    	if (!MAinvmx(msg, &four, (IGRdouble *)mtx, (IGRdouble *)inv_rot))
    	{
#ifdef DEBUG
		printf("error in DProtate MAinvmx\n");
#endif
    	}
   	if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)inv_rot,
			(IGRdouble *)trans, (IGRdouble *)transform_mtx))
    	{
	    goto fini;
    	}
    	trans[0][3] = pt_rot[0];
    	trans[1][3] = pt_rot[1];
    	trans[2][3] = pt_rot[2];

    	if(!MAmulmx(msg, &four, &four, &four, (IGRdouble *)trans, 
			(IGRdouble *)transform_mtx, (IGRdouble *)complete_mtx))
    	    {
		goto fini;
    	    }

	if (flag & RIGHT_MULT)
    	{
	    if (!MAptsxform(msg, &num_points, (IGRdouble *)complete_mtx,
				p_gg->eye_pt, p_gg->eye_pt))
	    {
	    	goto fini;
	    }
    	    if (origin != NULL)
    	    {
    	    	if (!MAptsxform(msg, &num_points, (IGRdouble *)complete_mtx,
				p_gg->coi, p_gg->coi))
    	    	{
    		goto fini;
    	    	}
		/* the new coi in the viewing coordinates of the old
		system for z calculations */
    	    	if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view,
					p_gg->coi, vw_coi))
    	    	{
    		goto fini;
    	    	}
    	    }
    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)inv_rot,
				p_gg->vup, p_gg->vup))
    	    {
    	    goto fini;
            }
		/* the new eye_pt in the viewing coordinates of the old
		system for z calculations */
	    if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view ,
				p_gg->eye_pt, vw_eye))
	    {
	    	goto fini;
	    }
	}
	else /* LEFT_MULT */
	{
    	    if (!MAinvmx(msg, &four, (IGRdouble *)wld_to_view,
				(IGRdouble *)view_to_wld))
    	    {
#ifdef DEBUG
		printf("error in DProtate MAinvmx\n");
#endif
    	    }
 	    vw_eye[0] = 0;
 	    vw_eye[1] = 0;
 	    vw_eye[2] = 0;
    	    if (origin != NULL)
    	    {
    	    	if (!MAptsxform(msg, &num_points, (IGRdouble *)complete_mtx,
				vw_coi, vw_coi))
    	    	{
    		goto fini;
    	    	}
    	    	if (!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
				vw_coi, p_gg->coi))
    	    	{
    		goto fini;
    	    	}
    	    }
    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)complete_mtx,
				vw_eye, vw_eye))
    	    {
    		goto fini;
    	    }
    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
				vw_eye, p_gg->eye_pt))
    	    {
    		goto fini;
    	    }
    	    p_gg->vup[0] = 0;
    	    p_gg->vup[1] = 1;
    	    p_gg->vup[2] = 0;
	/* might want to use real vup ( take vup to viewing and trans by whole
		vector so that z in included ie. now the projected vector 
		is used */
	/* this is rotating the viewing vup by the new rotation */

    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)inv_rot, 
				p_gg->vup, p_gg->vup))
    	    {
    	    goto fini;
            }
	/* this is taking the viewing vup back to world coordinates */
    	    if (!MArtrnmx(msg, &four, &four, (IGRdouble *)p_gg->rotation,
				(IGRdouble *)inv_rot))
    	    {
    	    goto fini;
            }
    	    if (!MAptsxform(msg, &num_points, (IGRdouble *)inv_rot, p_gg->vup,
				p_gg->vup))
    	    {
    	    goto fini;
            }
	} /* close for if left mult */
    	p_gg->vpn[0] = p_gg->eye_pt[0] - p_gg->coi[0];
    	p_gg->vpn[1] = p_gg->eye_pt[1] - p_gg->coi[1];
    	p_gg->vpn[2] = p_gg->eye_pt[2] - p_gg->coi[2];
    } /* close for if left or right mult */
    else if (flag & REPLACE_MTX)
    {
	/* NOTE THAT WITH REPLACE I AM NOT ALLOWING THE INPUT POINT TO BE
		THE POINT OF ROTATION THE COI IS THE POINT OF ROTATION
		HENCE THE COI DOES NOT CHANGE HERE */

    	OM_BLOCK_MOVE(mtx,rotate,sizeof(IGRdouble)*16);
    	MA2ptdis(msg,p_gg->eye_pt,p_gg->coi,&dist);

    	p_gg->eye_pt[0] = (rotate[2][0] * dist) + p_gg->coi[0];
    	p_gg->eye_pt[1] = (rotate[2][1] * dist) + p_gg->coi[1];
    	p_gg->eye_pt[2] = (rotate[2][2] * dist) + p_gg->coi[2];

    	p_gg->vpn[0] = rotate[2][0];
    	p_gg->vpn[1] = rotate[2][1];
    	p_gg->vpn[2] = rotate[2][2];

    	p_gg->vup[0] = rotate[1][0];
    	p_gg->vup[1] = rotate[1][1];
    	p_gg->vup[2] = rotate[1][2];
	/* the new eye_pt in the viewing coordinates of the old
		system for z calculations */
    	if (!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view ,
			p_gg->eye_pt, vw_eye))
    	{
    	    goto fini;
    	}
    } /* close for if replace */
    MA2ptdis(msg,p_gg->eye_pt,p_gg->coi,&p_gg->act_z);

}
#endif
/* code common to perspective and parallel */

status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = my_id,
                             targetid = my_id);
	    if ( ! (1 & status) )
            {
#ifdef DEBUG
                printf("\nIN DPscroll Error send to window DPcal\n");
                om$report_error(sts = status);
#endif
		goto fini;
            }


	    if (update)
	    {
	       if (!(p_gg->flags & DP_DELAY))
	       {
	          status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate(msg,NULL,
						&update_all),
                             senderid = my_id,
                             targetid = my_id);

	      	   if ( ! (1 & status) )
            	   {
#ifdef DEBUG
                	printf("\nIN DProtate Error send to window DPupdate\n");
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
	if(*msg == MSSUCC)
	{
	    *msg = vol_msg;
	}
fini:
	return(status);
}

end implementation IGEgragad;


