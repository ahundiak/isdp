command_string	IDFFC_M_SMTHSURF,0,IDSmthSf
class			IDsmthsf
super_class		IDundo
super_class		ECcmd
spec_path		"$MODEL/spec"
product_name	"$MODEL"

specification

/*
Abstract
	This command object modifies an element by deleting a selected pole.

History

*/

/* ------------------------------------------------ */
/* INSTANCE DATA                                    */
/* ------------------------------------------------ */
instance
{
    IGRint	pole_direction;  	/* 0: U  or   1:  V direction */
    IGRint  	enable_hilite;
}


implementation
/*
Abstract

Algorithm

*/

/*      ************ */


#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "emsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bsparameters.h"
#include "adpdef.h" 
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
/* #include "madef.h" */
#include "dpstruct.h" 
#include "dperr.h" 
#include "alloca.h"
#include "bsalloccv.h"    /* prototypes */
#include "bsconstprcv.h"    /* prototypes */
#include "bsfndsfcsp.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsmdelpolsf.h"    /* prototypes */

#define EMS_CK_TANGENCY 101
#define IDSMTH_SURFACE	0
#define U_CUSPS		0
#define V_CUSPS		1
#define BOTH_UV_CUSPS	2
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define IDNOCUSPS		10000
#define IDNOHILITE		10002

from GRgraphics import GRdisplay, GRgetprops, GRdelete;
from GRvg	import GRgetattr, GRputattr, GRkeypoint, GRmodify;
from GRvg	import GRdynmod, GRgetsize, GRgetgeom, GRpostabsg,GRgetsymb;

state_table
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffmsg.h"
#include "IDffcmd.h"
#define EMS_CK_TANGENCY 101
#define IDSMTH_SURFACE	0
#define TRUE 1
#define FALSE 0
#define U_CUSPS		0
#define V_CUSPS		1
#define BOTH_UV_CUSPS	2
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define IDNOCUSPS		10000
#define IDNOHILITE		10002

at wakeup 	do message_key  IDFFC_M_SMTHSURF

at sleep    	do hilite_cusps(&me->ret, FALSE)
		do delete_obj(&me->located_obj[0].located_obj.objid, FALSE)

state start
 on CMD_TYPE = IDSMTH_SURFACE	do message_key IDFFC_M_SMTHSURF
                        state start_id

state start_id
 on CMD_TYPE = IDSMTH_SURFACE	do message_key IDFFC_M_SMTHSURF
				do prompt_key IDFF_P_IdentSurf
				do relocate_key IDFF_E_RelocSurf
				do locate_class		"EMSsubbs"
				state locate_ele
state locate_ele
 locate_display 		"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
 locate_properties		29 /* locate locatable,displayable,read_write */
 locate_owner			LC_FLEX_COMP  /* locate flexible comp */
 accept_key			IDFF_P_AccptRejSurf
 filter			locate
 on EX_BACK_UP	    state start_id
 on DATA	    do highlight_located	0 /* dehilited locate channel */
 		    do ECcmd.EMsave_located_object(&me->event1,
				&me->located_obj[0])
                    do status_key  IDFF_M_SMTHCusps
                    do change_hilite_state(TRUE)
                    do hilite_cusps(&me->ret, TRUE)
			 on IDNOCUSPS   
                                do status_key IDFF_M_SMTHSfNoCusp
		    		state accept_direction
		    state accept_direction

state accept_direction
 prompt_key		IDFF_P_AccptPolDir
 filter			get_event
 on EX_BACK_UP	    	
			state start_id
 on EX_RJT_MOVEON   	
                        do status_key IDFF_M_SMTHCusps
			do toggle_row_direction
			    on IDNOCUSPS   
                                do status_key IDFF_M_SMTHSfNoCusp
				state accept_direction
			state accept_direction
 on DATA 	    
                        do hilite_cusps(&me->ret, FALSE)
                        do change_hilite_state(FALSE)
		    	do smooth_surface
			    on MSFAIL   do delete_saved_geom(ID_SURFACE_GEOM)
						state not_mod

			state accept_new_surface

state accept_new_surface
 prompt_key		IDFF_P_IdentSurf
 status_key		IDFF_P_BckMovUndo
 filter			get_event
 on EX_BACK_UP	    	do restore_original_geometry(&me->ret,
				&me->located_obj[0],
				&me->located_obj[0].located_obj.objid)
			do delete_saved_geom(ID_SURFACE_GEOM)
			do status_key	IDFF_M_SurfRestored
			do delete_obj(&me->located_obj[0].located_obj.objid, 
				FALSE)
			do init_variables
			state start_id
 on EX_RJT_MOVEON   	do restore_original_geometry(&me->ret,
				&me->located_obj[0],
				&me->located_obj[0].located_obj.objid)
			do delete_saved_geom(ID_SURFACE_GEOM)
			do status_key	IDFF_M_SurfRestored
			do delete_obj(&me->located_obj[0].located_obj.objid, 
				FALSE)
			do init_variables
			state start_id
 on DATA		
			do delete_saved_geom(ID_SURFACE_GEOM)   
			do delete_obj(&me->located_obj[0].located_obj.objid, 
				FALSE)
			do init_variables
			do feed_event_back_to_locate
			state start_id


state not_mod
 status		" "
 on CMD_TYPE = IDSMTH_SURFACE	do status_key IDFF_E_SurfNotMod
						state start_id

/* ********************************************************************	*/
/* ********************************************************************	*/
/* ********************************************************************	*/
/* ********************************************************************	*/
action change_hilite_state(IGRint   enable_hilite)
{
        me->enable_hilite = enable_hilite;
}
/* ********************************************************************	*/
/* This method highlights the portion of the curve which will be 	*/
/* affected by the removal of the selected pole.			*/
/*	dependent on:							*/
/*		me->pole_selected (tells whether we have a pole or not) */
/*		me->located_obj						*/
/*		me->pole						*/
/* 		-------------------------------------------------------	*/
action hilite_cusps(IGRlong *msg; IGRint draw)
{
 	IGRlong                 sts;
	BSrc	                rc;
	struct IGRbsp_curve     *current_iso_crv;
	IGRshort	        uv_option;
	struct GRsymbology	symb;

        struct    DPele_header  current_iso_buffer;
  	struct IGRbsp_surface   *surface_ptr;  
	struct IGResbc		curr_iso_dpattr;
        IGRlong                 num_bytes; 

        IGRint                  num_u_cusps, 
                                num_v_cusps;
        IGRdouble               *u_cusp_parms, 
                                *v_cusp_parms, 
                                *uv_parms;
        IGRboolean              test_for_planarity;
        IGRint                  total_num_directions, 
                                current_direction_count,
                                counter_max_value,
		                cusp_counter;

    /* ---------------------------------------------------- */
    /* surface_ptr will hold the geometry of the surface    */
    /* current_iso_crv will store the geometry of EACH iso  */
    /*      curve (one at a time) that we draw.             */
    /* ---------------------------------------------------- */
    surface_ptr = NULL;
    current_iso_crv = NULL;
    counter_max_value = 0;
    uv_parms = NULL;

    *msg = OM_S_SUCCESS;
    status = OM_S_SUCCESS;
    sts = 1;
    curr_iso_dpattr.is_polydis = FALSE;
    curr_iso_dpattr.is_curvedis = TRUE;

    /* ---------------------------------------------------- */
    /* Check to see if we're in a state where the iso       */
    /* curves should be drawn.                              */
    /* ---------------------------------------------------- */
    if(! me->enable_hilite)
    {
	*msg = IDNOHILITE;
        goto ret_end;
    }

    /* ------------------------------------	*/
    /* Compute the number of bytes required */
    /* ------------------------------------	*/
    sts = om$send(
        msg = message GRvg.GRgetsize(
        msg, 
        &me->located_obj[0].module_info.md_env.matrix_type,
        me->located_obj[0].module_info.md_env.matrix,
        &num_bytes), 
        senderid = my_id, 
        targetid = me->located_obj[0].located_obj.objid, 
        targetos = me->located_obj[0].located_obj.osnum); 
    if (!(1 & sts & *msg))   
    {
	*msg = MSFAIL;
	goto ret_end;
    }

    /* ----------------------------------------------------	*/
    /* Alloc the required memory off the stack		*/
    /* ----------------------------------------------------	*/
    surface_ptr = (struct IGRbsp_surface *) alloca(num_bytes);
    if (!surface_ptr)
    {
	printf("No memory available in Remove Pole");
    	*msg = MSFAIL; 
	sts = OM_E_ABORT;
    	goto ret_end;
    }


    /* ------------------------------------	*/
    /* Get the geometry			*/
    /* ------------------------------------	*/
    sts = om$send(
        msg = message GRvg.GRgetgeom(
        msg, 
        &me->located_obj[0].module_info.md_env.matrix_type,
        me->located_obj[0].module_info.md_env.matrix,
        (IGRchar * ) surface_ptr),
        senderid = my_id, 
        targetid = me->located_obj[0].located_obj.objid, 
        targetos = me->located_obj[0].located_obj.osnum); 
    if (!(1 & sts & *msg))
    {
	    *msg = MSFAIL;
    	    goto ret_end;
    }


    /* ------------------------------------------------------------ */
    /* Now, we need to find out where the cusps are.  We can call   */
    /* BSfndsfcsp, but we need to allocate memory to hold all the   */
    /* cusp u and v parameters.  We don't know how many cusps there */
    /* are, so we allocate for the maximum possible.                */
    /* ------------------------------------------------------------ */
    u_cusp_parms = NULL;
    v_cusp_parms = NULL;
    u_cusp_parms = (IGRdouble *) alloca( sizeof(IGRdouble) * 
            (surface_ptr->u_num_poles - surface_ptr->u_order + 1) );
    v_cusp_parms = (IGRdouble *) alloca( sizeof(IGRdouble) * 
            (surface_ptr->v_num_poles - surface_ptr->v_order + 1) );
    if ( (!u_cusp_parms) || (!v_cusp_parms) )
    {
	    printf("No stack memory available in smooth surface");
            sts = OM_E_ABORT;
	    *msg = MSFAIL;
    	    goto ret_end;
    }

    /* ------------------------------------------------------------ */
    /* This routine finds the U and V parameters of all the cusp    */
    /* lines in the surfaces.                                       */
    /* ------------------------------------------------------------ */
    BSfndsfcsp(surface_ptr, &num_u_cusps, u_cusp_parms, &num_v_cusps,
            v_cusp_parms, &rc);
    if(rc != BSSUCC) 
    {
	    printf("BSfndsfcsp failed! could not get cusps.\n");
	    *msg = MSFAIL;
            sts = rc;
            goto ret_end;
    }



    /* ----------------------------------------------------	*/
    /* Now, get the symbology of the surface so we can draw our */
    /* iso lines in the same manner.                            */
    /* Make the weight of the lines we are going to draw to	*/
    /* be a little greater than the weight of the curve.	*/
    /* ----------------------------------------------------	*/
    sts = om$send(msg = message GRvg.GRgetsymb(msg, &symb),
       		targetid = me->located_obj[0].located_obj.objid,
       		targetos = me->located_obj[0].located_obj.osnum);
    if(!(1&*msg&sts))
    {
	    printf("GRgetsymb failed!\n");
	    *msg = MSFAIL;
            goto ret_end;
    }
    /* ---------------------------------------------------- */
    /* Check the weight of the curve.  If we can, make the	*/
    /* weight of our pole be one weight higher.  		*/
    /* ---------------------------------------------------- */
    if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT - 1)
		symb.display_attr.weight += 1;


    /* ------------------------------------------------------------ */
    /* We need to set uv_option, which is used by BSconstprcv to    */
    /* tell it in which direction to search for cusps.              */
    /*      1:  cusps with constant U parm.                         */
    /*      2:  cusps with constant V parm.                         */
    /* Also, check to see if we're doing 1 or both directions.      */
    /* ------------------------------------------------------------ */
    if(me->pole_direction ==  U_CUSPS) /* constant u */
    {
        if(num_u_cusps == 0)
        {
            *msg = IDNOCUSPS;
            goto ret_end;
        }
        uv_option = 1;  /* header says 1 for constant u parameter */
        total_num_directions = 1;
    }
    else if(me->pole_direction ==  V_CUSPS) /* constant v */
    {
        if(num_v_cusps == 0)
        {
            *msg = IDNOCUSPS;
            goto ret_end;
        }
        uv_option = 2;  /* header says 2 for constant v parameter */
        total_num_directions = 1;
    }
    else if(me->pole_direction ==  BOTH_UV_CUSPS) /* constant u */
    {
        if( (num_u_cusps + num_v_cusps) == 0)
        {
            *msg = IDNOCUSPS;
            goto ret_end;
        }
        uv_option = 1;
        total_num_directions = 2;
    }
    else 
    {
            *msg = IDNOCUSPS;
            goto ret_end;
    }



    /* ---------------------------------------------------- */
    /* Loop through both U and V directions if necessary    */
    /* Allocate space for iso curve geometry.  The amount   */
    /* needed is dependent upon whether the curve is in the */
    /* U or V direction.  All curves, in a particular       */
    /* direction, however, require the same amount of space.*/
    /* Thus, as we loop through all cusps of a certain      */
    /* direction, we can use the same buffer, and we won't  */
    /* have to do a second malloc unless we do both         */
    /* directions.                                          */
    /* ---------------------------------------------------- */
    for(    current_direction_count = 0; 
            current_direction_count < total_num_directions; 
            current_direction_count++)
    {
            if(uv_option == 1) /* constant u */
            {
                /* ------------------------------------------------ */
                /* We want constant u-parm curves, so set up loop   */
                /* variables to go through the U cusps.             */
                /* ------------------------------------------------ */
                counter_max_value = num_u_cusps;
                uv_parms = u_cusp_parms;
                BSalloccv ( surface_ptr->v_order, surface_ptr->v_num_poles, 
                     surface_ptr->rational, 0, &current_iso_crv, &rc);
                if(rc != BSSUCC) 
                {
		        printf("BSalloccv failed!\n");
                        sts = rc;
	                *msg = MSFAIL;
                        goto ret_end;
                }
            }
            else if(uv_option == 2) /* constant v */
            {
                counter_max_value = num_v_cusps;
                uv_parms = v_cusp_parms;
                BSalloccv ( surface_ptr->u_order, surface_ptr->u_num_poles, 
                     surface_ptr->rational, 0, &current_iso_crv, &rc);
                if(rc != BSSUCC) 
                {
		        printf("BSalloccv failed!\n");
                        sts = rc;
	                *msg = MSFAIL;
                        goto ret_end;
                }
            }

            /* ---------------------------------------------------- */
            /* Loop through all of the cusps we found in this       */
            /* direction.  For each one,                            */
            /*      1) extract an iso curve (create geometry),      */
            /*      2) build a display buffer for it,               */
            /*      3) display the iso curve.                       */
            /* ---------------------------------------------------- */
            for(cusp_counter = 0; cusp_counter < counter_max_value;  
                    cusp_counter++)
            {
                    /* -------------------------------------------- */
                    /* We don't need this test, since we will       */
                    /* discard geometry after displaying it.        */
                    /* -------------------------------------------- */
	            test_for_planarity = FALSE;  
	            BSconstprcv( &rc, surface_ptr, &uv_option, 
                            &uv_parms[cusp_counter],
			    &test_for_planarity, current_iso_crv);
    	            if(rc != BSSUCC) 
                    {
		            printf("BSconstprcv failed!\n");
                            sts = rc;
	                    *msg = MSFAIL;
                            goto ret_end;
                    }

                    dp$build_dis_buffer(buffer = &current_iso_buffer,
                            type = IGRBC,
                            display_att = &(symb.display_attr),
			    ele_spec_att = &curr_iso_dpattr,
                            geometry = current_iso_crv);

                    dp$display(msg = msg,
                            mode = ( draw ? GRhd : GRhe),
                            num_elem = 1,
                            buffer = &current_iso_buffer);
	            if(!(1&*msg))
	            {
		        printf("dp$display failed!\n");
	                *msg = MSFAIL;
                        goto ret_end;
	            }
            }  /* end of cusp_counter loop through uv parameters */

            /* ---------------------------------------------------- */
            /* If we're drawing curves for both directions of       */
            /* cusps, then switch to the other direction now.       */
            /* ---------------------------------------------------- */
            if(total_num_directions ==2) uv_option = 2; 
	    if (current_iso_crv) 
	    {
		BSfreecv(&rc, current_iso_crv);
		current_iso_crv = NULL;
	    }
   }   /* end for loop through desired directions  */

ret_end:
	if (current_iso_crv) 
	{
		BSfreecv(&rc, current_iso_crv);
		current_iso_crv = NULL;
	}
 	if (!(1&sts)) return (OM_E_ABORT);
}
/* ********************************************************************	*/
action feed_event_back_to_locate
{
	long size = sizeof(struct GRevent) - sizeof(long) * 2;
	IGRint response = EX_DATA;
	IGRlong sts;

	status = ex$putque(msg= &sts, byte = &size, response = &response,
		buffer = (IGRchar *) &ME.CEO_LOCATE->event1.event);

}


/* ********************************************************************	*/
/*		------------------------------------------------------- */
action toggle_row_direction
{
    IGRlong msg;

    status = om$send (msg = message IDsmthsf.hilite_cusps(&msg, FALSE),
                    mode = OM_e_wrt_message,
                    targetid = my_id);

    switch(me->pole_direction)
    {
        case    U_CUSPS:
            me->pole_direction = V_CUSPS;
        break;

        case    V_CUSPS:
            me->pole_direction =  BOTH_UV_CUSPS;
        break;

        case    BOTH_UV_CUSPS:
            me->pole_direction = U_CUSPS;
        break;

	default:
		printf("Invalid option passed to toggle_row_direction\n");
	break;
    }

    status = om$send (msg = message IDsmthsf.hilite_cusps(&msg, TRUE),
                    mode = OM_e_wrt_message,
                    targetid = my_id);

    if(msg == IDNOCUSPS) *sts = IDNOCUSPS;
}

/* *******************************************************************	*/
/* ********************************************************************	*/
/* This method does the actual removal of the pole from the surface and	*/
/* then posts the new geometry.  Erasure of old geometry and display	*/
/* of the new geometry is done too.					*/
/*	dependent on:							*/
/*		me->located_obj						*/
/*		me->event1						*/
/*		me->located_obj[0].located_obj.objid						*/
/*		------------------------------------------------------- */
action smooth_surface
{
  IGRlong		msg;
  BSrc			rc;
  struct GRpost_info  	info;

  /* IGRchar        tmp_ptr;  */
  struct IGRbsp_surface        *surface_ptr;
  IGRlong         num_bytes; 


 surface_ptr = NULL;

  msg = OM_S_SUCCESS;


/* ------------------------------------	*/
/* Compute the number of bytes required */
/* ------------------------------------	*/
 *sts = om$send(
   msg = message GRvg.GRgetsize(
    &msg, 
    &me->located_obj[0].module_info.md_env.matrix_type,
    me->located_obj[0].module_info.md_env.matrix,
    &num_bytes), 
   senderid = my_id, 
   targetid = me->located_obj[0].located_obj.objid, 
   targetos = me->located_obj[0].located_obj.osnum); 
  if (!(1 & *sts & msg))   
  {
	*sts = MSFAIL;
	goto ret_end;
  }

/* ----------------------------------------------------	*/
/* Alloc the required memory off the stack		*/
/* ----------------------------------------------------	*/
 surface_ptr = (struct IGRbsp_surface *) alloca(num_bytes);
  if (!surface_ptr)
   {
	printf("No memory available in Remove Pole");
    	*sts = MSFAIL; 
    	goto ret_end;
   }


/* ------------------------------------	*/
/* Get the geometry			*/
/* ------------------------------------	*/
 *sts = om$send(
   msg = message GRvg.GRgetgeom(
    &msg, 
    &me->located_obj[0].module_info.md_env.matrix_type,
    me->located_obj[0].module_info.md_env.matrix,
    (IGRchar * ) surface_ptr),
   senderid = my_id, 
   targetid = me->located_obj[0].located_obj.objid, 
   targetos = me->located_obj[0].located_obj.osnum); 
  if (!(1 & *sts & msg))
  {
	*sts = MSFAIL;
	goto ret_end;
  }


  me->DisplayMode = GRbe;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
			&me->located_obj[0].module_info.md_env.
                        matrix_type, me->located_obj[0].module_info.
                        md_env.matrix, &me->DisplayMode,
                        &me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);


  status = om$send (msg = message IDundo.save_original_geometry(&msg, 
			  (char *) surface_ptr, ID_SURFACE_GEOM),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);



    /* ------------------------------------
     * Promote the class, if required
     * ------------------------------------ */
    *sts = EMpromote_class(
     				 FALSE,
      				&me->located_obj[0].module_info,
      				&me->located_obj[0].located_obj,
      				&msg);
    if (! (1 & *sts)) 
    {
		printf("EMpromote_class failed!\n");
		return (OM_E_ABORT);
    }

    /* --------------------------------------------------------------  
      option        (0) Remove poles corresponding to multiple knots
                    (1) Remove poles corresponding to cusps
      --------------------------------------------------------------    */
    BSmdelpolsf( me->pole_direction, 1, surface_ptr, &rc );

    if(rc != BSSUCC) 
    {
		printf("BSdelpolsf failed!\n");
		return (OM_E_ABORT);
    }


  info.construct_flag = TRUE;
  info.construct_flag = FALSE;
  status = om$send(msg = message GRvg.GRpostabsg(&msg,
                         &me->located_obj[0].module_info, &info,
                         (IGRchar *) surface_ptr, &me->located_obj[0].located_obj.objid),
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "GRpostabsg error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);


  /* put this in to clear the object cache so that we show the new change */
  /* THIS WORKS, but try more efficient delete from cache 		  */
  /* 	GRabsg_del_all(); */
  GRabsg_del_by_objid(&me->located_obj[0].located_obj.objid, &me->located_obj[0].located_obj.osnum);


ret_end:
  /* if(surface_ptr)	stackfree(surface_ptr); */
  me->DisplayMode = GRbd;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
				&me->located_obj[0].module_info.md_env.
                            	matrix_type, me->located_obj[0].module_info.
                            	md_env.matrix, &me->DisplayMode,
                            	&me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, quit, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);

}
/* ******************************************************************	*/
action wakeup(int pos)
{
 	IGRlong sts;
 	IGRlong msg;

 	sts = OM_S_SUCCESS;
 	msg = 1;
 
 	sts = om$send(mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.wakeup(pos),
                  targetid = my_id);
 	if (!(1&sts)) return (OM_E_ABORT);

    	sts = om$send (msg = message IDsmthsf.hilite_cusps(&msg, TRUE),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
	if(msg == IDNOCUSPS) UI_status("No cusps found in this direction");
	else if(msg != IDNOHILITE)
	{
		UI_status("Highlighted cusps will be smoothed");
	}

	if (!(1&sts)) return (OM_E_ABORT);

	return (sts);

}


/* ********************************************************************	*/
/* This method exists so that we can initialize, and just as 		*/
/* importantly, REinitialize our variables.				*/
/*	--------------------------------------------------------------- */
action init_variables
{
	me->pole_direction = U_CUSPS;
        me->enable_hilite = FALSE;
}

/* ********************************************************************	*/
action init
{
	IGRlong msg;


    /* ------------------------------------------------ */
    /* send init message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send (msg = message ECcmd.init(type, str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "ECcmd init");

    /* ------------------------------------------------ */
    /* send init message to IDundo                      */
    /* ------------------------------------------------ */
    status = om$send (msg = message IDundo.init(type, str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "IDundo init");

    status = om$send (msg = message IDsmthsf.init_variables(&msg),
                    mode = OM_e_wrt_message,
                    targetid = my_id);

    me->located_obj[0].located_obj.objid = NULL_OBJID;

}


/* ********************************************************************	*/
action delete
{
    status = om$send(msg = message IDsmthsf.delete_obj(
		    &me->located_obj[0].located_obj.objid, FALSE),
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "delete method:IDsmthsf.delete_obj\n");

    /* ------------------------------------------------------------ */
    /* send delete message to IDundo so it can delete saved geom    */
    /* ------------------------------------------------------------ */
    status = om$send (msg = message IDundo.delete(f_defer_flag ),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDsmthsf's parent delete\n");

    /* ------------------------------------------------ */
    /* send delete message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send (msg = message ECcmd.delete(f_defer_flag ),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDsmthsf's parent delete\n");

}

/* ********************************************************************	*/
action delete_obj(GRobjid *objid; IGRint reinitialize)
{
  if (reinitialize)
     *objid = NULL_OBJID;
}

