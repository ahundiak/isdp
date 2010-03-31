class implementation IDrmpls;

#include "EMS.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include <stdio.h>
#include "exmacros.h"   /* For ex$put_que*/  
#include "griomacros.h" /* For co$get_event */
#include "OMmacros.h"   /* For OM_BLOCK_MOVE */
#include "OMerrordef.h"
#include "EMSmvpl.h"   /* For EMMOVE_POLES_ALONG_SPECIFIED_VECTORS */
#include "bserr.h"
#include "OMminimum.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "igrdef.h"     /* For IGRPS */
#include "dpmacros.h"
#include "dp.h"
#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
#include "madef.h" 
#include "dpstruct.h" 
#include "adpdef.h" 
#include "IDffcmd.h"
#include "IDffmsg.h" 
#include "alloca.h"

#include "EMSssprops.h" /* For EMSIS_POLYDIS */
#include "dperr.h" 
#include "bsparameters.h" /* For BSEXT.. */
#include "IDextrbezsf.h"
#include "IDrmplsi.h" /* prototypes */
#include "bsdelpolsf.h"    /* prototypes */
#include "bsfreesf.h"    /* prototypes */
#include "bssftstclsd.h"    /* prototypes */

#define BUFF_SIZE 		10
#define INCREMENT 		10
#define LINE_TYPE		4
#define ACCEPT_REJECT_NEW_SURFACE 8
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0

from GRvg import GRgetsize,GRgetgeom,GRgetattr,GRputattr, GRpostabsg,GRgetsymb;
from GRgraphics import GRdisplay,GRdelete, GRaltconstruct;
from EMSsurface import EMgetactiveid;

extern OMuword OPP_EMSsolid_class_id;

/* ********************************************************************	*/
/* This method highlights the portion of the surface which will be 	*/
/* affected by the removal of the selected row of poles.		*/
/*	dependent on:							*/
/* 		-------------------------------------------------------	*/
method hilite_bez_patch(IGRboolean draw)
{
 	IGRlong msg,sts;
	struct IGRbsp_surface *bez_patch_surf;
	IGRushort dum_opts = 0;
	BSrc	rc;
	struct GRsymbology	symb;
        struct    DPele_header bez_patch_buffer;
    	struct IGResqbs esqs;
    	IGRint u_bounds[5], v_bounds[5], i;
    	IGRdouble u_rules[5], v_rules[5];
    	IGRdouble u_ktdel, v_ktdel;

 	msg = 1;
	bez_patch_surf = NULL;

	/* ----------------------------------------------------	*/
	/* Make the weight of the lines we are going to draw to	*/
	/* be a little greater than the weight of the curve.	*/
	/* ----------------------------------------------------	*/
	sts = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
               		targetid = me->surface.located_obj.objid,
               		targetos = me->surface.located_obj.osnum);
	if(!(1&msg&sts))
	{
			return (OM_E_ABORT);
	}

	/* ---------------------------------------------------- */
	/* Check the weight of the curve.  If we can, make the	*/
	/* weight of our pole be one weight higher.  		*/
	/* ---------------------------------------------------- */
	if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT - 1)
		symb.display_attr.weight += 0;
		/* original symb.display_attr.weight += 1; */

	IDextrbezsf(	&msg, dum_opts, 
			&me->surface.module_info.md_env.matrix_type,
                       	me->surface.module_info.md_env.matrix,
			me->del_pole,
                        me->row,
                   	NULL, 
			&me->surface.located_obj,
                   	&bez_patch_surf);

   /* -------------------------------
    * Fill in the element display
    * header information. 
    * -------------------------------   */

        u_ktdel = (bez_patch_surf->u_knots[bez_patch_surf->u_num_poles] - 
		bez_patch_surf->u_knots[bez_patch_surf->u_order-1]) / 4.0;
        v_ktdel = (bez_patch_surf->v_knots[bez_patch_surf->v_num_poles] - 
		bez_patch_surf->v_knots[bez_patch_surf->v_order-1]) / 4.0;
        u_rules[0] = bez_patch_surf->u_knots[bez_patch_surf->u_order-1];
        v_rules[0] = bez_patch_surf->v_knots[bez_patch_surf->v_order-1];
        for (i=1; i<4; i++)
        {
            u_rules[i] = u_rules[i-1] + u_ktdel;
            v_rules[i] = v_rules[i-1] + v_ktdel;
        }
        u_rules[4] = bez_patch_surf->u_knots[bez_patch_surf->u_num_poles];
        v_rules[4] = bez_patch_surf->v_knots[bez_patch_surf->v_num_poles];

        for (i=0; i<5; i++)
        {
            u_bounds[i] = 0;
            v_bounds[i] = 0;
        }

        esqs.u_rules = 5;
        esqs.v_rules = 5;
        esqs.is_polydis = FALSE;
        esqs.is_surfdis = TRUE;
        esqs.is_slowdis = FALSE;
        esqs.type = NULL;
        esqs.rules_specified = FALSE;
        esqs.u_rule_values = u_rules;
        esqs.v_rule_values = v_rules;
        esqs.u_num_bound = u_bounds;
        esqs.v_num_bound = v_bounds;
        esqs.u_bdrys = NULL;
        esqs.v_bdrys = NULL;

        dp$build_dis_buffer(buffer = &bez_patch_buffer,
                            type = IGRQS,
                            display_att = &(symb.display_attr),
			    ele_spec_att = &esqs,
                            geometry = bez_patch_surf);
	
        dp$display(msg = &msg,
                   mode = ( draw ? GRhd : GRhe),
                   num_elem = 1,
                   buffer = &bez_patch_buffer);

	if(!(1&msg))
	{
		return (OM_E_ABORT);
	}

	if (bez_patch_surf) BSfreesf(&rc, bez_patch_surf);
 	if (!(1&msg)) return (OM_E_ABORT);
	else return (OM_S_SUCCESS);
}

method IDcreate_line_string(IGRboolean draw)
{
  	IGRlong  		msg, sts;
	int 			y,j,x;
 	IGRdouble 		weight = 1;
	IGRdouble		*pt_buffer;
	struct GRsymbology	symb;
        struct IGRpointset  	pole_pointset;

        struct    IGRpolyline  polyline;
        struct    DPele_header polyline_buffer;

	pt_buffer = NULL;
	pt_buffer = (IGRdouble *) alloca(me->num_poles * 3 * sizeof(IGRdouble));
	if( !pt_buffer ) 
	{
		return (OM_E_ABORT);
	}

	/* ----------------------------------------------------	*/
	/* Make the weight of the lines we are going to draw to	*/
	/* be a little greater than the weight of the surface.	*/
	/* ----------------------------------------------------	*/
	sts = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
       		targetid = me->surface.located_obj.objid,
       		targetos = me->surface.located_obj.osnum);
	if(!(1&msg&sts))
	{
			return (OM_E_ABORT);
	}
	if((IGRint)symb.display_attr.weight < GR_HI_WEIGHT - 2)
	{
		symb.display_attr.weight += 2;
	}
	else    symb.display_attr.weight =  GR_HI_WEIGHT;
	symb.display_attr.style = LINE_TYPE;


	/* ------------------------------------------------------------	*/
	/* We wish to draw a highlighted line between the poles in the	*/
	/* row of poles that the user has selected for deletion.	*/
	/* Create a buffer containing all the vertices in the		*/
	/* linestring we wish to create.  Pass this on to dp$display.	*/
	/* ------------------------------------------------------------	*/
	for(x = 0; x < me->num_poles; x++)
	{
  		j = me->indices[x];
  		if (me->surf_ptr->rational) weight = me->surf_ptr->weights[j];
  		else weight = 1;

		/* ----------------------------------------------------	*/
		/* For weighted poles, the weight is stored multiplied	*/
		/* into the pole, so to get the x,y,z coordinates, it	*/
		/* is necessary to divide out the weight.		*/
		/* ----------------------------------------------------	*/
		for(y=0; y<3; y++) 
		{
			pt_buffer[x*3 + y] =   
				me->surf_ptr->poles[j*3 +y]/weight;

		}
	}
 	polyline.num_points = me->num_poles;
	polyline.points = pt_buffer;

        dp$build_dis_buffer(buffer = &polyline_buffer,
                            type = IGRPY,
                            display_att = &(symb.display_attr),
                            geometry = &polyline);


        dp$display(msg = &msg,
                   mode = ( draw ? GRhd : GRhe),
                   num_elem = 1,
                   buffer = &polyline_buffer);

	/* ------------------------------------------------------------ */
	/* We have already displayed a line connecting the poles, so	*/
	/* now, let's highlight the poles individually.			*/
	/* ------------------------------------------------------------ */
    	pole_pointset.num_points = me->num_poles;
    	pole_pointset.points = pt_buffer;

	/* ------------------------------------------------------------ */
	/* We want the poles to be visible above the line we just drew,	*/
	/* so make the poles even thicker.				*/
	/* ------------------------------------------------------------ */
	if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT)
		symb.display_attr.weight++;
        dp$build_dis_buffer(buffer = &polyline_buffer,
                            type = IGRPS,
                            display_att = &(symb.display_attr),
                            geometry = &pole_pointset);

        dp$display(msg = &msg,
                   mode = ( draw ? GRhd : GRhe),
                   num_elem = 1,
                   buffer = &polyline_buffer);

	if(!(1&msg))
	{
		return (OM_E_ABORT);
	}

  	return(OM_S_SUCCESS);
}


method change_surface_by_deleting_row()
{
	IGRlong sts,msg;
	struct IGRbsp_surface 	*surf;
	IGRint 			indx,i,x;

	BSrc			rc;
	struct GRpost_info  	info;
	enum GRdpmode 		display_mode;
	IGRpoint 		del_pole;
 	IGRdouble 		weight = 1;

	surf = me->surf_ptr;

        sts = OM_S_SUCCESS;

	/* ----------------------------------------------------	*/
	/* Here, we erase the object as it used to be...	*/
	/* ----------------------------------------------------	*/
       	display_mode = GRbe;
       	sts = om$send (msg = message GRgraphics.GRdisplay(
			&msg, 
			&me->surface.module_info.md_env.matrix_type,
                       	me->surface.module_info.md_env.matrix,
                       	&display_mode,
                       	&me->surface.module_info.md_id),
               		targetid = me->surface.located_obj.objid,
               		targetos = me->surface.located_obj.osnum);
       	if (!(1&sts&msg)) 
	{
                goto fini;
	}

        /* ---------------------------------------- */
        /* Don't redisplay after toggling polygon,  */
        /* since it will get done after the delete. */
	/* Toggle polygon off here, so that we we   */
        /* don't have to update the surface twice.  */
        /* ---------------------------------------- */
       	sts = om$send (msg = message 
                                IDrmpls.display_polygon(FALSE,FALSE),
                     		targetid = my_id);

	indx = me->del_pole_index;
	for (i=0;i<3;i++) del_pole[i] = surf->poles[3*indx+i];

	for(x = 0; x < 1; x++)
	{
		IGRint j,y;

  		j = me->indices[x];
  		if (me->surf_ptr->rational) weight = me->surf_ptr->weights[j];
  		else weight = 1;

		/* ----------------------------------------------------	*/
		/* For weighted poles, the weight is stored multiplied	*/
		/* into the pole, so to get the x,y,z coordinates, it	*/
		/* is necessary to divide out the weight.		*/
		/* ----------------------------------------------------	*/
		for(y=0; y<3; y++) 
		{
			del_pole[x*3 + y] =   
				me->surf_ptr->poles[j*3 +y]/weight;

		}
	}

        sts =om$send (msg = message IDundo.save_original_geometry(&msg,
				(IGRchar *) me->surf_ptr, ID_SURFACE_GEOM),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
        if (!(1&sts)) 
        {
                goto fini;
        }

	BSdelpolsf( me->surf_ptr, (IGRint)(!me->row), me->del_pole, &rc );
	if(rc != BSSUCC) 
	{
		ex$message(field = ERROR_FIELD, msgnumb = IDFF_E_MAERR);
		sts = OM_E_ABORT;
                goto fini;
	}

	/* ------------------------------------------------------------ */
	/* add this in, because above routine does not reset the closed */
	/* bit when one of the end poles is deleted in a closed surface */
	/* ------------------------------------------------------------ */
    	BSsftstclsd(me->surf_ptr, &rc);
	if(rc != BSSUCC) 
	{
		ex$message(field = ERROR_FIELD, msgnumb = IDFF_E_MAERR);
		sts = OM_E_ABORT;
                goto fini;
	}


	info.construct_flag = FALSE;
	sts = om$send(msg = message GRvg.GRpostabsg(&msg,
               	&me->surface.module_info, &info,
               	(IGRchar *) me->surf_ptr, 
		&me->surface.located_obj.objid),
       		targetid = me->surface.located_obj.objid,
       		targetos = me->surface.located_obj.osnum);
       	if (!(1&sts&msg)) 
	{
		sts = OM_E_ABORT;
                goto fini;
	}


	/* --------------------------------------------	*/
	/* Delete the object from the Object Cache so 	*/
	/* that the draw routine uses the NEW geometry.	*/
	/* --------------------------------------------	*/
	GRabsg_del_by_objid(&me->surface.located_obj.objid, 
			&me->surface.located_obj.osnum);


	/* Now, we redraw the object with the changes.	*/
	display_mode = GRbd;
	sts = om$send (msg = message GRgraphics.GRdisplay(
		&msg, 
		&me->surface.module_info.md_env.matrix_type,
              	me->surface.module_info.md_env.matrix,
               	&display_mode,
               	&me->surface.module_info.md_id),
       		targetid = me->surface.located_obj.objid,
       		targetos = me->surface.located_obj.osnum);
	if (!(1&sts&msg)) 
	{
		sts = OM_E_ABORT;
                goto fini;
	}
 
fini:
	if (!(1&sts)) 
	{
            om$send (msg = message IDundo.delete_saved_geom(
			ID_SURFACE_GEOM),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
        }

  	return(sts);


}

/* *******************************************************************	*/
/*	FUNCTION							*/
/* 	---------------------------------------------------------------	*/
IGRboolean IDsurf_has_enough_rows_to_delete_one(
	struct IGRbsp_surface *surf_ptr, 
	IGRboolean v_direction)
{
	IGRboolean have_enough_rows = TRUE;

	/* ----------------------------------------------------	*/
	/* Check to make sure the number of rows which will 	*/
	/* remain is greater than the order.			*/
	/* ----------------------------------------------------	*/
	if(v_direction)
	{
		/* deleting row of poles along constant u	*/
		/* if(surf_ptr->u_order >= surf_ptr->u_num_poles)
			{
			have_enough_rows = FALSE;
			}
		*/	
		if(  (surf_ptr->u_num_poles <= 2) || 
		  ( (surf_ptr->u_phy_closed) && (surf_ptr->u_num_poles<=4)) )
		{
				have_enough_rows = FALSE;
		}
		
	}
	else
	{
		/* if(surf_ptr->v_order >= surf_ptr->v_num_poles)
			{
			have_enough_rows = FALSE;
			}
		*/
		if( (surf_ptr->v_num_poles <= 2) ||
		  ( (surf_ptr->v_phy_closed) && (surf_ptr->v_num_poles<=4)) )
		{
			have_enough_rows = FALSE;
		}
		
	}
  	return(have_enough_rows);
}

/* ************************************************************	*/
/* FUNCTION							*/
IGRboolean IDcrv_pole_can_be_deleted(struct IGRbsp_curve *crv)
{
	IGRboolean can_delete_pole;

	can_delete_pole = TRUE;
	if(crv->num_poles <= 2) 
	{
		can_delete_pole = FALSE;
	}

	return(can_delete_pole);
}







/* ************************************************************	*/
/* This function checks to see whether the given pole index 	*/
/* corresponds to a row of poles which is a surface boundary.	*/
/* It requires the following:					*/
/*		surf_ptr:  ptr to surface geometry.		*/
/*		v_direction:	TRUE if pole index is for a	*/
/*				V row. False if for U.		*/
/*		pole_index:     index of the pole.  This should */
/*				be a number between 0 and	*/
/*				num_poles - 1.  (it should be	*/
/*				one of the U,V coordinates.)	*/
/*				Thus, it should 		*/
/*				not be an absolute index.	*/
/*		-----------------------------------------------	*/
IGRboolean IDrow_is_surface_boundary(
	struct IGRbsp_surface *surf_ptr, 
	IGRboolean v_direction, 
	IGRint pole_index)
{
	IGRboolean		is_boundary = FALSE;


	if(v_direction)
	{
		if( 	(pole_index <= surf_ptr->v_order-2 ) ||
			(pole_index >= surf_ptr->v_num_poles - 1 )  )
		{
			is_boundary = TRUE;
		}
	}
	else
	{
		if( 	(pole_index <= surf_ptr->u_order-2 ) ||
			(pole_index >= surf_ptr->u_num_poles - 1 )  )
		{
			is_boundary = TRUE;
		}
	}
  	return(is_boundary);
}


method get_pole_position(struct GRevent *event;IGRint *pole_index;
                         IGRboolean *onpolygon)
{
  	IGRpoint		pnt1, pnt2; 
  	IGRlong		msg;
  	IGRlong sizbuf, nret;       /* sizbuf added to be used in
				       gr$get_dit_tolerance. 04/09/92, JSY */
  	struct GRparms dum_parms;
  	struct IGRline boreline;
  	IGRlong sts,which_error;
  	IGRdouble tol,scale;
  	IGRdouble line_point[3],line_parameter,mindist;
  	IGRpoint pole;
  	struct var_list list_var[2];
  	struct IGRbsp_surface *surf;
  	IGRint temp_u,temp_v;



  	*pole_index = 0;

  	boreline.point1 = pnt1;  /* allocates storage for */
  	boreline.point2 = pnt2;  /* the boreline          */

  	sts = EFboreline(&msg, my_id, event, &boreline);
  	if (!(1&sts&msg)) goto wrapup;

  	if (!me->surf_ptr) return (OM_E_ABORT);
  	else surf = me->surf_ptr;

  	dum_parms.u = 5.0;  /* kludge for the tolerance */

  	prj_line_to_pole (&msg,surf, &boreline,line_point,&line_parameter,
                    pole, &temp_u, &temp_v,&mindist);
  	if (!(1&msg)) goto wrapup;

	sizbuf = sizeof( IGRdouble ); /* added by JSY */

  	sts = gr$get_dit_tolerance(msg = &msg,sizbuf = &sizbuf,
                            buffer = &tol, nret = &nret);
  	if (!(1&sts)) return (OM_E_ABORT);

  	list_var[0].var            = VVOL_VIEWPORT_SCALE;
  	list_var[0].var_ptr        = (IGRchar *) &scale;
  	list_var[0].num_bytes      = sizeof(IGRdouble);
  	list_var[0].bytes_returned = &nret;

  	list_var[1].var            = END_PARAM;
  	list_var[1].var_ptr        = NULL;
  	list_var[1].num_bytes      = 0;
  	list_var[1].bytes_returned = NULL;

 	sts = dp$inq_set_gragad (msg = &msg,
              osnum = event->event.button.osnum,
              gragad_objid = event->event.button.objid,
              which_error = &which_error,
              var_list = list_var);
  	if (!(1&sts&msg)) goto wrapup;

  	tol /= scale;

  	if (mindist > tol)   *onpolygon = FALSE;
  	else   *onpolygon = TRUE;

  	*pole_index = (surf->u_num_poles)*temp_v + temp_u;
wrapup:
  	if (!(1&sts&msg)) return (OM_E_ABORT);
  	return(OM_S_SUCCESS);
}


method display_polygon(IGRboolean display; IGRboolean update_display)
{
  	IGRint status = OM_S_SUCCESS;
  	IGRlong		msg;

  	msg = MSSUCC;
  	status = OM_S_SUCCESS;

    if(display)
    {
     	status = om$send(msg = message IDdisp_poly.turn_poly_on(
                            &msg, 
                            ID_SURFACE_GEOM,
                            &me->surface,
                            update_display),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
    }
    else
    {
     	status = om$send(msg = message IDdisp_poly.turn_poly_off(
                            &msg, 
                            ID_SURFACE_GEOM,
                            &me->surface,
                            update_display),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
    }

  	if (!(1&status&msg)) return (OM_E_ABORT);
  	return (status);
}

method wakeup(int pos)
{
 	IGRlong sts;
 	IGRlong EMmsg;

 	sts = OM_S_SUCCESS;
 	EMmsg = 1;
 

 	sts = om$send(mode = OM_e_wrt_message,
                  msg = message ECelement.wakeup(pos),
                  targetid = my_id);
 	if (!(1&sts)) return (OM_E_ABORT);

 	if ((me->num_pole_events) && 
		(ME.super_cmd->state != ACCEPT_REJECT_NEW_SURFACE))
 	{
   		sts = om$send(msg=message IDrmpls.display_pole_event(TRUE),
                  	targetid = my_id);
   		if (!(1&sts)) return (OM_E_ABORT);
 	}

	/*
	 * Display the newly constructed surface which has been constructed with
	 * polygon turned off since it is an order 2 surface and the polgon 
	 * matches the surface display. 
	 */

	sts = om$send(msg = message IDrmpls.display_polygon(TRUE, TRUE),
               		targetid = my_id);
	if (!(1&sts)) return (OM_E_ABORT);
	return (sts);

}

method sleep(int pos)
{
 	IGRlong sts,msg;

 	sts = OM_S_SUCCESS;
 	msg = 1;


 	if (me->num_pole_events)
 	{
   		sts = om$send (msg = message IDrmpls.display_pole_event(FALSE),
                  	targetid = my_id);
   		if (!(1&sts)) return (OM_E_ABORT);
 	}
	/*
	 * Erase the constructed surface.
	 */

  		sts = om$send (msg=message IDrmpls.display_polygon(FALSE,TRUE),
                	targetid = my_id);
  		if (!(1&sts)) return (OM_E_ABORT);
 	return (sts);
}

method init_variables()
{
  	int		  status = OM_S_SUCCESS;

  	me->surf_ptr = 0;
  	me->surf_size = 0;
  	me->num_poles = 0;
  	me->row = 1;
  	me->num_pole_events = 0;
  	me->surface.located_obj.objid = NULL_OBJID;

  	return (status);
}

method init(int type; char *str_ptr)
{

  	int		  status = OM_S_SUCCESS;

  	status = om$send (msg = message IDundo.init(type,str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  	if (!(1&status)) return (OM_E_ABORT);

  	status = om$send (msg = message IDdisp_poly.init(type,str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  	if (!(1&status)) return (OM_E_ABORT);

  	status = om$send (msg = message ECelement.init(type,str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  	if (!(1&status)) return (OM_E_ABORT);

  	status = om$send (msg = message IDrmpls.init_variables(),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  	if (!(1&status)) return (OM_E_ABORT);

  	return (status);
}


method display_indices(IGRlong from_index; IGRlong to_index;
               IGRboolean draw)
{
 	IGRlong sts;
 	IGRlong msg,i,j,k;
 	IGRpoint point;
 	IGRshort type;
 	IGRdouble weight = 1;
 	IGRint save_wt;
 	struct IGRbsp_surface *surf;
	struct GRsymbology	symb;

 	sts = OM_S_SUCCESS;
 	msg = 1;


 	if ((from_index < 0 ) || (to_index > me->num_poles))
 	{
  		return (OM_E_ABORT);
 	}
 	surf = me->surf_ptr;

 	type = IGRPS;

	/* ----------------------------------------------------	*/
	/* Make the weight of the pts we are going to draw to	*/
	/* be a little greater than the weight of the surface.	*/
	/* ----------------------------------------------------	*/
	sts = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
       		targetid = me->surface.located_obj.objid,
       		targetos = me->surface.located_obj.osnum);
	if(!(1&msg&sts))
	{
			return (OM_E_ABORT);
	}
	if((IGRint)symb.display_attr.weight < GR_HI_WEIGHT - 3)
	{
		symb.display_attr.weight += 3;
	}
 	save_wt = ME.ECelement->active_display.weight;
	ME.ECelement->active_display.weight = symb.display_attr.weight;


 	for (i=from_index;i<to_index;i++)
 	{
  		j = me->indices[i];
  		if (surf->rational) weight = surf->weights[j];
  		else weight = 1;

		/* ----------------------------------------------------	*/
		/* For weighted poles, the weight is stored multiplied	*/
		/* into the pole, so to get the x,y,z coordinates, it	*/
		/* is necessary to divide out the weight.		*/
		/* ----------------------------------------------------	*/
  		for (k=0;k<3;k++) point[k] = surf->poles[3*j+k]/weight; 


  		ECdisplayPointSetByBuffer0 (&msg, ME.ECelement->active_display,
       			ME.ECelement->md_env, my_id, 1, point, 
			(draw ? GRhd : GRhe), type);
  		if (!(1&msg)) goto wrapup;
 	}

wrapup:
 	ME.ECelement->active_display.weight = save_wt;
 	if (!(1&sts&msg)) return (OM_E_ABORT);
 	return (sts);
}

method store_row(IGRboolean row; IGRint index)
{
 	IGRlong sts;
 	IGRint i;
 	IGRint stinx,edinx,u_pole_inx, v_pole_inx,current_size, future_size;
 	struct IGRbsp_surface *surf = NULL;
	IGRint 			indx,x;
	IGRdouble weight = 1;

 	sts = OM_S_SUCCESS;

 	surf = me->surf_ptr;
 	if (!surf) return (OM_E_ABORT);

	/* Convert absolute index into u,v coordinates	*/
 	u_pole_inx = index % surf->u_num_poles;
 	v_pole_inx = index / surf->u_num_poles;

  	if (row) future_size = me->num_poles + surf->u_num_poles;
  	else future_size = me->num_poles + surf->v_num_poles;

  	current_size = OM_DIMENSION_OF(me->indices);

  	if (current_size < future_size)
   		sts = OM_SET_DIMENSION(me->indices,future_size);
   	if (!(1&sts))
   	{
    		sts = OM_E_ABORT;
    		goto wrapup;
   	}

 	if (row)
 	{
		/* U direction means constant V	*/
  		stinx = v_pole_inx * surf->u_num_poles;
  		edinx = stinx + surf->u_num_poles;

  		for (i=stinx;i< edinx;i++)
  		{
    			me->indices[me->num_poles] = i;
    			++(me->num_poles);
  		}

		/* Alex - put this in here to test theory	*/
		me->del_pole_index = v_pole_inx;

 	}
 	else
 	{
		/* V direction means constant U	*/
   		stinx = u_pole_inx;
   		edinx = surf->u_num_poles * surf->v_num_poles;

   		for (i=u_pole_inx;i<edinx;i += (surf->u_num_poles))
   		{
     			me->indices[me->num_poles] = i;
     			++(me->num_poles);
   		}
		/* Alex - put this in here to test theory	*/
		me->del_pole_index = u_pole_inx;
 	}


	indx = me->del_pole_index;
	indx = index;
	for (i=0;i<3;i++) me->del_pole[i] = surf->poles[3*indx+i];

	for(x = 0; x < 1; x++)
	{
		IGRint j,y;

  		j = me->indices[x];
  		if (me->surf_ptr->rational) weight = me->surf_ptr->weights[j];
  		else weight = 1;

		/* ----------------------------------------------------	*/
		/* For weighted poles, the weight is stored multiplied	*/
		/* into the pole, so to get the x,y,z coordinates, it	*/
		/* is necessary to divide out the weight.		*/
		/* ----------------------------------------------------	*/
		for(y=0; y<3; y++) 
		{
			me->del_pole[x*3 + y] =   
				me->surf_ptr->poles[j*3 +y]/weight;

		}
	}




  	sts = om$send (msg = message IDrmpls.add_pole_event(
			(row ? surf->u_num_poles :
                       	surf->v_num_poles)),
                 	targetid = my_id);
  	if (!(1&sts)) goto wrapup;

wrapup:
 	return (sts);
}

method storepoles_in_volume(IGRlong *msg; IGRint type; 
                            struct GRmd_env *md_env;
                            struct GRid *volume)
{
 	IGRlong sts;
 	IGRint *b_ptr = NULL, b_indices[BUFF_SIZE],*m_indices = NULL;
 	IGRint num_poles;

 	sts = OM_S_SUCCESS;

 	if (type & FENCE_LOCATED)
 	{
   		EFreturn_poles_within_fence(msg,
                               me->surf_ptr,
                               NULL,NULL,
                               md_env,
                               volume,
                               NULL,NULL,
                               &num_poles,BUFF_SIZE,
                               b_indices,NULL,&m_indices,NULL);
   		if (!(1&*msg)) goto wrapup;
 	}
 	else if (type & SOLID_LOCATED)
 	{
   		EFreturn_poles_within_solid(msg,
                               me->surf_ptr,
                               &me->surface.module_info,
                               &me->surface.located_obj,
                               md_env,
                               volume,
                               &num_poles,BUFF_SIZE,
                               b_indices,NULL,&m_indices,NULL);
   		if (!(1&*msg)) goto wrapup;
 	}
 
   	if (num_poles > BUFF_SIZE)    b_ptr = m_indices;
   	else  b_ptr = b_indices;

   	sts = om$send (msg = message IDrmpls.add_pole(num_poles,b_ptr),
                  targetid = my_id);
   	if (!(1&sts)) goto wrapup;

   	sts = om$send (msg = message IDrmpls.add_pole_event(num_poles),
                  targetid = my_id);
   	if (!(1&sts)) goto wrapup;

   	sts = om$send (msg = message IDrmpls.display_pole_event(TRUE),
                  targetid = my_id);
   	if (!(1&sts)) goto wrapup;

wrapup:
   	if (m_indices) om$dealloc(ptr = m_indices);
   	if (!(1&sts&*msg)) return (OM_E_ABORT);
 	return (sts);
}

method store_geom(IGRlong *msg)
{
 	IGRlong sts;
 	struct GRmd_env *md_env;
 	IGRlong buff_size;

 	*msg = MSSUCC;

 	md_env = &me->surface.module_info;
 	sts = om$send (msg = message GRvg.GRgetsize (msg, 
                      &md_env->md_env.matrix_type, 
                      md_env->md_env.matrix,
                      &buff_size), 
                targetid = me->surface.located_obj.objid,
                targetos = me->surface.located_obj.osnum);
 	if (!(1&sts&*msg)) return (OM_E_ABORT);

 	if (buff_size > me->surf_size)
 	{
  		if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
        
  		me->surf_ptr = (struct IGRbsp_surface *) om$malloc(
			size = buff_size);
  		if (!me->surf_ptr) return (OM_E_ABORT);

  		me->surf_size = buff_size;
 	}
 	sts = om$send (msg = message GRvg.GRgetgeom(msg,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix,
                        (IGRchar *) me->surf_ptr),
                	targetid = me->surface.located_obj.objid,
                	targetos = me->surface.located_obj.osnum);
 	if (!(1&sts&*msg)) return (OM_E_ABORT);

 	if (!(1&sts&*msg)) return (OM_E_ABORT);
 	return (sts);
}

method add_pole(IGRint num_poles; IGRint *inx)
{
 	IGRshort i;
 	IGRlong sts,current_size, future_size;
 
 	sts = OM_S_SUCCESS;

 	current_size = OM_DIMENSION_OF(me->indices);
 	future_size = me->num_poles + num_poles;

 	if (future_size > current_size)
   	sts = OM_SET_DIMENSION(me->indices, future_size + INCREMENT);
   	if (!(1&sts)) goto wrapup;

 	for (i=0;i<num_poles;i++)
 	{
   		me->indices[me->num_poles] =  inx[i];
   		++(me->num_poles);
 	}

wrapup:
 	return (sts);
}

method add_pole_event(IGRint num_poles)
{
 	IGRlong sts,current_size,future_size;

 	sts = OM_S_SUCCESS;

 	current_size = OM_DIMENSION_OF(me->num_poles_array);
 	future_size = me->num_pole_events + 1;

 	if (future_size > current_size)
 	{
  		sts = OM_SET_DIMENSION(me->num_poles_array,future_size + 
			INCREMENT);
  		if (!(1&sts)) goto wrapup;
 	}

 	me->num_poles_array[me->num_pole_events] = num_poles;
 	++(me->num_pole_events);

wrapup:
 	return (sts);
}

method display_pole_event(IGRboolean display)
{
 	IGRlong sts, msg;

 	sts = OM_S_SUCCESS;
	if(!display) 
	{
            /* ------------------------------------------------------------ */
            /* Erase the entire highlight plane to increase speed.          */
            /* ------------------------------------------------------------ */
            sts = dp$erase_hilite ( msg = &msg);
	}
	else
	{
	    /*  alex - put indices display in create_line_string
	    sts = om$send (msg = message IDrmpls.display_indices(0,
			me->num_poles,display),
                       targetid = my_id);
	    if (!(1&sts)) goto wrapup;
	    */

       	    sts = om$send(msg=message IDrmpls.IDcreate_line_string(display),
                     		targetid = my_id);
  	    if (!(1&sts)) goto wrapup;


       	    sts = om$send(msg=message IDrmpls.hilite_bez_patch(display),
                     		targetid = my_id);
  	    if (!(1&sts)) goto wrapup;
        }

wrapup:
	return(sts);
}

method backup_pole_event()
{
 	IGRint num_poles_in_last_event;
 	IGRint i,ii,j;
 	IGRlong sts = OM_S_SUCCESS;
 
 	num_poles_in_last_event = me->num_poles_array[me->num_pole_events - 1];
 	me->num_poles -= num_poles_in_last_event;
 	--(me->num_pole_events);

	/*
	 * Redisplay overlapping poles.
	 */

 	for (i=0;i<num_poles_in_last_event;i++)
 	{
  		j = me->indices[me->num_poles + i];
  		for (ii=0;ii<me->num_poles;ii++)
  		{
   			if (j == me->indices[ii])
   			{
    				sts = om$send (msg = message 
					IDrmpls.display_indices(ii,ii+1, TRUE),
                 			targetid = my_id);
    				if (!(1&sts)) return(sts);
   			}
  		}
 	}
 
	 return (OM_S_SUCCESS);
}

method delete(int defer_flag)
{
 	IGRlong sts;

 	sts = OM_S_SUCCESS;

  	sts = om$send(mode = OM_e_wrt_message,
		msg = message IDundo.delete(defer_flag),
                targetid = my_id);
  	if (!(1&sts)) return (OM_E_ABORT);

	/*
	 * Delete the nodal surface if constructed.
	 */

  	sts = om$send(mode = OM_e_wrt_message,
                msg = message Root.delete(defer_flag),
                targetid = my_id);
  	if (!(1&sts)) return (OM_E_ABORT);

 	return (sts);
}

end implementation IDrmpls;

