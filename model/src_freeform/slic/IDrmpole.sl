command_string		IDFFC_M_RMPLCRV,0,IDRmPole
class			IDrmpole
super_class		IDdisp_poly
super_class		IDundo
super_class		ECcmd
spec_path		"$MODEL/spec"
product_name            "$MODEL"

specification

/*
Abstract
	This command object modifies an element by deleting a selected pole.

History
	6/2/91		Written by Alex Carr using code of Move pole as a
			basis.  Move pole subclasses only off of ECcmd, but
			it was necessary to also subclass off of ECelement
			in order to allow the selected pole to highlight.

	8/1/91		Alex Carr - Changed so that hilite_pole uses
			dp$display.  Thus we do not need to subclass off of
			ECelement.  Also wrote hilite_bez_patch method to
			show the user which portion of the curve would be
			altered.

	8/3/91		Alex Carr - Changed code so that curve geometry
			is not saved in malloced memory.  We used alloca
			instead and get the memory off of the stack.

	8/14/91		Alex Carr - Added state to allow user the ability
			to go back to the original curve geometry. (UNDO)

        9/3/91          Alex Carr - Changed command to subclass off of
                        IDundo and use its UNDO capabilities.

        9/27/91         Alex Carr - Changed command to subclass off of
                        IDdisp_poly and use its polygon display capabilities.

	04/09/92	JSY - Added ele_spec_att to dp$build_dis_buffer
			to properly initialize struct IGResbc entry.
			There was a core dump before doing this initialization.

	04/12/92	JSY - Fix TR 91M0265. Made following modifications
			to the code: 1. remove instance variables
			chg_class_flag,	classid and objid; 2. remove action
			delete_obj, set_cond and arg_name_to_value; 3. add
			action disp_poly -- this is because action at wakeup
			cannot access instance variable pole_selected.
			4. use EMpromote_class in the change_class action.
			5. modified code accordingly and did some cleanup.

	09/17/92	JSY - Change function calls turn_poly_on and
			turn_poly_off to get rid of parameter objid.
			Also not to define TRUE and FALSE instead include
			OMtypes.h.

        11/03/93        dhm - Added method check_ancestry and instance data
                        fields has_owner, owner_classid, owner_id. Changed this
                        to work with components of SKmgr, SKcompcurve, and
                        GRcompcurve.

Possible Problems	Will allow poles to be removed as long as the
			number of poles is greater than 2.
				However, the command will not prevent
			a shape from arising which has colinear poles.  Also,
			problems may arise when using the command on closed
			curves which become open curves.

*/


instance
{
  IGRpoint		pole;  	/* pole to be deleted */
  IGRint	pole_selected;	/* pole has been selected		*/
  IGRboolean    has_owner;      /* flag indicating if object has an owner */
  OMuword       owner_classid;  /* class id of the curve's owner */
  struct GRid   owner_id;       /* id of the curve's owner */
}


implementation
/*
Abstract
	This command object modifies an element by deleting a selected pole.

Algorithm
	If the element is a curve of type other than GRbcsubbc, then this
	command changes the class of it to GRbcsubbc and toggles the polygon
	on.  If the polygon display is off (for either a curve or surface),
	then this command toggles it on.

History
        11/03/93        dhm - Added method check_ancestry and instance data
                        fields has_owner, owner_classid, owner_id. Changed this
                        to work with components of SKmgr, SKcompcurve, and
                        GRcompcurve.

*/
/* #include "EC_F.h"
	#include "EC_I.h"
	#include "EC_M.h"
	#include "EC_P.h"
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
#include "IDffcmd.h"
#include "IDffmsg.h"
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
#include "grmacros.h"
#include "alloca.h"
#include "IDextrbez.h"
#include "IDrmplsi.h"    /* prototypes */
#include "bscvtstclsd.h"    /* prototypes */
#include "bsdelpolcv.h"    /* prototypes */
#include "bsdistptpt.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include <malloc.h>    /* prototypes */
#include "nddef.h"
#include "ndmacros.h"
#include "EMSutlmacros.h"

#define IDFEWPOLES		10000
#define IDRMPL_CURVE	0
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define ID_TANGENCY_NOT_KEPT    10001
#define ID_TANGENCY_KEPT    10002
#define EMS_INV_POLE    102

from GRgraphics import GRdisplay, GRgetprops, GRdelete;
from GRvg	import GRgetattr, GRputattr, GRkeypoint, GRmodify;
from GRvg	import GRdynmod, GRgetsize, GRgetgeom, GRpostabsg,GRgetsymb;
from GRlistener import GRnotifylis;

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_SKcompcurve_class_id;
extern OMuword OPP_SKmgr_class_id;

state_table
#include "OMtypes.h"
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffcmd.h"
#include "IDffmsg.h"
#include "ECmsg.h"

#define IDRMPL_CURVE	0
#define IDFEWPOLES		10000
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define ID_TANGENCY_NOT_KEPT    10001
#define ID_TANGENCY_KEPT    10002
#define EMS_INV_POLE    102

at wakeup      	   do disp_poly
		   do message_key                    IDFFC_M_RMPLCRV
		   do hilite_pole(TRUE)
		   do hilite_bez_patch(TRUE)

at sleep    do turn_poly_off( &me->ret, 
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE)
 	    do hilite_pole(FALSE)
	    do hilite_bez_patch(FALSE)
            do message " "

state start
 on CMD_TYPE = IDRMPL_CURVE	do message_key IDFFC_M_RMPLCRV
                                state start_id

state start_id
 on CMD_TYPE = IDRMPL_CURVE	do prompt_key	IDFF_P_IdentCrv
				do relocate_key IDFF_E_RelocCrv
				do locate_class	"GRbspline"
				state locate_ele

state locate_ele
 locate_display 		"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
 locate_properties		"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
 locate_owner			"LC_FLEX_COMP | LC_RIGID_COMP"
 accept_key			IDFF_P_AccptRejCrv
 filter			locate
 on EX_BACK_UP	    state start_id
 on DATA	    do highlight_located 0 /* dehilited locate channel */
                    do check_ancestry
                      on MSFAIL do status_key EMS_I_InvEleLoc  state .
 		    do ECcmd.EMsave_located_object(&me->event1,
				&me->located_obj[0])
		    do change_class()
		    do turn_poly_on( &me->ret, 
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE)
		    state input_pole

state input_pole
 prompt_key         IDFF_P_InputPole
 filter	            get_event
 on EX_BACK_UP	    do turn_poly_off( &me->ret, 
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE)
                    do status " "
                    state start_id
 on DATA	    do keypoint_pole
                    do status " "
		    do change_pole_state(TRUE)
                    do check_for_endpoint
                      on EMS_INV_POLE
                        do status_key EMS_I_InvPole state .
                      on ID_TANGENCY_NOT_KEPT
		        do status_key IDFF_I_TanNotMaint state accept_pole
		      on ELSE
			do status_key IDFF_I_TanMaint state accept_pole
                    state accept_pole

state accept_pole
 execute                hilite_pole(TRUE)
 execute                hilite_bez_patch(TRUE)
 prompt_key		IDFF_P_RmPlAccptPol
 filter			get_event
 on EX_BACK_UP	    	do hilite_bez_patch(FALSE)
 			do hilite_pole(FALSE)
			do change_pole_state(FALSE)
			state input_pole
 on EX_RJT_MOVEON   	do hilite_bez_patch(FALSE)
 			do hilite_pole(FALSE)
			do change_pole_state(FALSE)
			state input_pole
 on DATA	        do hilite_pole(FALSE)
			do hilite_bez_patch(FALSE)
			do delete_pole
			    on IDFEWPOLES   do delete_saved_geom(ID_CURVE_GEOM)
						state too_few_poles
			    on MSFAIL	do delete_saved_geom(ID_CURVE_GEOM)
						state not_mod

                        do notify_listeners()
			do change_pole_state(FALSE)
			do turn_poly_off( &me->ret, 
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE) 
			state accept_new_curve

state accept_new_curve
 status_key     	IDFF_P_BckMovUndo
 prompt_key		IDFF_P_IdentCrv
 filter			get_event
 on EX_BACK_UP	    	do restore_original_geometry(&me->ret,
				&me->located_obj[0],
				&me->located_obj[0].located_obj.objid)
                        do notify_listeners()
			do delete_saved_geom(ID_CURVE_GEOM)
			do status_key IDFF_M_CrvRestored
			do init_variables
			state start_id
 on EX_RJT_MOVEON   	do restore_original_geometry(&me->ret,
				&me->located_obj[0],
				&me->located_obj[0].located_obj.objid)
                        do notify_listeners()
			do delete_saved_geom(ID_CURVE_GEOM)
			do status_key IDFF_M_CrvRestored
			do init_variables
			state start_id
 on DATA
			do delete_saved_geom(ID_CURVE_GEOM)   
			do change_pole_state(FALSE)
			do init_variables
			do feed_event_back_to_locate
			state start_id


state not_mod
 status		" "
 on CMD_TYPE = IDRMPL_CURVE	do status_key   IDFF_E_CrvNotMod
						state start_id

state too_few_poles
 status		" "
 on CMD_TYPE = IDRMPL_CURVE 	do status_key IDFF_E_RmPlMinPols
			do change_pole_state(FALSE)
			do turn_poly_off( &me->ret, 
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE)
			do init_variables
			state start_id


/* ********************************************************************	*/
/* ********************************************************************	*/
/* ********************************************************************	*/
/* ********************************************************************	*/
action disp_poly
{
	if ( me->pole_selected )
	    status = om$send( msg = message IDdisp_poly.turn_poly_on(
				    &me->ret,
                                    ID_CURVE_GEOM,
				    &me->located_obj[0],
                                    TRUE),
			      mode = OM_e_wrt_message,
			      targetid = my_id );
}

action feed_event_back_to_locate
{
	long size = sizeof(struct GRevent) - sizeof(long) * 2;
	IGRint response = EX_DATA;
	IGRlong msg;

	status = ex$putque(msg= &msg, byte = &size, response = &response,
			   buffer = (IGRchar *) &ME.CEO_LOCATE->event1.event);

}
/* ********************************************************************	*/
/* This method highlights the portion of the curve which will be 	*/
/* affected by the removal of the selected pole.			*/
/*	dependent on:							*/
/*		me->pole_selected (tells whether we have a pole or not) */
/*		me->located_obj						*/
/*		me->pole						*/
/* 		-------------------------------------------------------	*/
action hilite_bez_patch(IGRint draw)
{
 	IGRlong msg;
	struct IGRbsp_curve *bez_patch_crv;
	IGRushort dum_opts;
	BSrc	rc;
	
	struct GRsymbology	symb;

        struct    DPele_header bez_patch_buffer;


	dum_opts = 0;
 	status = OM_S_SUCCESS;
 	msg = 1;
	bez_patch_crv = NULL;

	if (!(me->pole_selected)) 
	{
		goto wrapup;
	}



	/* ----------------------------------------------------	*/
	/* Make the weight of the lines we are going to draw to	*/
	/* be a little greater than the weight of the curve.	*/
	/* ----------------------------------------------------	*/
	status = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
			 targetid = me->located_obj[0].located_obj.objid,
			 targetos = me->located_obj[0].located_obj.osnum);
	if(!(1&msg&status))
	{
			printf("GRgetsymb failed!\n");
			return (OM_E_ABORT);
	}
	/* ---------------------------------------------------- */
	/* Check the weight of the curve.  If we can, make the	*/
	/* weight of our pole be one weight higher.  		*/
	/* ---------------------------------------------------- */
	if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT - 1)
		symb.display_attr.weight += 1;


	IDget_crv_patch_affected_by_pole_deletion(	
			&msg, dum_opts, 
			&me->located_obj[0].module_info.md_env.matrix_type, 
			me->located_obj[0].module_info.md_env.matrix,
			me->pole,
                   	NULL, 
			&me->located_obj[0].located_obj,
                   	&bez_patch_crv);


	/*==========================================================*/
	/* using dp$build_dis_buffer to construct buffer to display */
	/* B-spline curve, must specify ele_spec_att.[JSY] 04/09/92 */
        /*==========================================================*/

	{
	  struct IGResbc attr;

	  /* initialize attr: this is important. Otherwise,
	     it will dump core. [JSY]                */
	  attr.is_polydis = TRUE;
	  attr.is_curvedis = TRUE;
           
        dp$build_dis_buffer(buffer = &bez_patch_buffer,
                            type = IGRBC,
                            display_att = &(symb.display_attr),
	                    ele_spec_att = &attr,
                            geometry = bez_patch_crv);

        dp$display(msg = &msg,
                   mode = ( draw ? GRhd : GRhe),
                   num_elem = 1,
                   buffer = &bez_patch_buffer);

	if(!(1&msg))
	{
		printf("dp$display failed!\n");
		return (OM_E_ABORT);
	}
        }


wrapup:
	if (bez_patch_crv) BSfreecv(&rc, bez_patch_crv);
 	if (!(1&msg)) return (OM_E_ABORT);
}
/* ********************************************************************	*/
/* This method highlights the pole that the user has selected.		*/
/*	dependent on:							*/
/*		me->pole_selected (tells whether we have a pole or not) */
/*		me->located_obj						*/
/*		me->pole						*/
/* 		-------------------------------------------------------	*/
action hilite_pole(IGRint draw)
{
 	IGRlong msg;

	struct GRsymbology	symb;

        struct IGRpointset  	pole_point;
	IGRdouble	pole_storage[3];
        struct    DPele_header  pole_buffer;


 	status = OM_S_SUCCESS;
 	msg = 1;
	if (!(me->pole_selected)) 
	{
		goto wrapup;
	}



	/* ----------------------------------------------------	*/
	/* Make the weight of the lines we are going to draw to	*/
	/* be a little greater than the weight of the curve.	*/
	/* ----------------------------------------------------	*/
	status = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
			 targetid = me->located_obj[0].located_obj.objid,
			 targetos = me->located_obj[0].located_obj.osnum);
	if(!(1&msg&status))
	{
			printf("GRgetsymb failed!\n");
			return (OM_E_ABORT);
	}

	/* ---------------------------------------------------- */
	/* Check the weight of the curve.  If we can, make the	*/
	/* weight of our pole be 4 weights higher.  Otherwise,	*/
	/* just make the pole the maximum weight.		*/
	/* ---------------------------------------------------- */
	if((IGRint) symb.display_attr.weight < GR_HI_WEIGHT - 4)
		symb.display_attr.weight += 4;
	else symb.display_attr.weight = GR_HI_WEIGHT;




	pole_point.num_points = 1;
	pole_point.points    = 	pole_storage;
	pole_point.points[0] = 	me->pole[0];
	pole_point.points[1] = 	me->pole[1];
	pole_point.points[2] = 	me->pole[2];

        dp$build_dis_buffer(buffer = &pole_buffer,
                            type = IGRPS,
                            display_att = &(symb.display_attr),
                            geometry = &pole_point );


        dp$display(msg = &msg,
                   mode = ( draw ? GRhd : GRhe),
                   num_elem = 1,
                   buffer = &pole_buffer);

	if(!(1&msg))
	{
		printf("dp$display failed!\n");
		return (OM_E_ABORT);
	}



wrapup:

 	if (!(1&msg)) return (OM_E_ABORT);
}

/* ********************************************************************	*/
/* This method changes the toggle which represents whether or not the	*/
/* user has selected a pole.  If me->pole_selected is true, it means	*/
/* that upon wakeup, for example, we can highlight the curve.		*/
/*		changes:  me->pole_selected				*/
/*		------------------------------------------------------- */
action change_pole_state(IGRint pole_selected)
{
	me->pole_selected = pole_selected;

}

/* ********************************************************************	*/
/* This method does the actual removal of the pole from the curve and	*/
/* then posts the new geometry.  Erasure of old geometry and display	*/
/* of the new geometry is done too.					*/
/*	dependent on:							*/
/*		me->located_obj						*/
/*		me->event1						*/
/*		me->pole						*/
/*		------------------------------------------------------- */
action delete_pole
{
  IGRlong		msg;
  struct IGRline	boreline;
  BSrc			rc;
  struct GRpost_info  	info;
  struct IGRbsp_curve        *curve_ptr;
  IGRlong         num_bytes; 


 curve_ptr = NULL;

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
 /* curve_ptr = (struct IGRbsp_curve *) stackalloc(num_bytes); */
 curve_ptr = (struct IGRbsp_curve *) alloca(num_bytes);
  if (!curve_ptr)
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
    (IGRchar * ) curve_ptr),
   senderid = my_id, 
   targetid = me->located_obj[0].located_obj.objid, 
   targetos = me->located_obj[0].located_obj.osnum); 
  if (!(1 & *sts & msg))
  {
	*sts = MSFAIL;
	goto ret_end;
  }


  if(  !IDcrv_pole_can_be_deleted(curve_ptr)   )
  {
	*sts = IDFEWPOLES;
	goto ret_end;
  }


  boreline.point2 = NULL;
  boreline.point1 = &me->event1.event.button.x;

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
			  (char *)curve_ptr, ID_CURVE_GEOM),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

  BSdelpolcv(me->pole, curve_ptr, &rc);
  BScvtstclsd( curve_ptr, &rc );


  info.construct_flag = FALSE;
  status = om$send(msg = message GRvg.GRpostabsg(&msg,
                         &me->located_obj[0].module_info, &info,
                         (IGRchar *) curve_ptr,
			 &me->located_obj[0].located_obj.objid),
		   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "GRpostabsg error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);


  /* put this in to clear the object cache so that we show the new change */
  /* THIS WORKS, but try more efficient delete from cache 		  */
  GRabsg_del_all();

  me->pole[0] = boreline.point1[0];
  me->pole[1] = boreline.point1[1];
  me->pole[2] = boreline.point1[2];

ret_end:
  /* if(curve_ptr)	stackfree(curve_ptr); */
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


action notify_listeners()
{
  IGRlong         msg;
  IGRlong         mask = GR_GEOM_POSTED;
  OMuint          count;
  OM_S_CHANSELECT chandef;

  msg = OM_S_SUCCESS;

  if (me->has_owner)
  {
    if (me->owner_classid == OPP_GRcompcurve_class_id)
    {
      om$make_chanselect(channame = "GRnotify.notification",
                         p_chanselect = &chandef);

      status = om$get_channel_count( objid = me->owner_id.objid,
                                     osnum = me->owner_id.osnum,
                                     p_chanselect = &chandef,
                                     count = &count);
      if ((1 & status) && (count))
      {
        /* send notification to the listeners   */

        status = om$send( msg = message GRlistener.GRnotifylis
                                (&msg,&msg,&mask,OPPmargs),
                          senderid = me->owner_id.objid,
                          targetos = me->owner_id.osnum,
                          p_chanselect = &chandef);
     }

    }
    else
    {
      nd$wait_batch(type = GR_GEOM_POSTED,
                    nb_obj = 1,
                    l_object = &me->owner_id);
    }

  }
}


/* ********************************************************************	*/
/* This method exists so that we can initialize, and just as 		*/
/* importantly, REinitialize our variables.				*/
/*	--------------------------------------------------------------- */
action init_variables
{
  	me->located_obj[0].located_obj.objid = NULL_OBJID;
	me->pole_selected = FALSE;
        me->has_owner = FALSE;
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

    /* ------------------------------------------------ */
    /* send init message to IDdisp_poly                 */
    /* ------------------------------------------------ */
    status = om$send (msg = message IDdisp_poly.init(type, str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "IDdisp_poly init");

    status = om$send (msg = message IDrmpole.init_variables(&msg),
                    mode = OM_e_wrt_message,
                    targetid = my_id);


}


/* ********************************************************************	*/
action delete
{
    /* ------------------------------------------------------------ */
    /* send delete message to IDundo so it can delete saved geom    */
    /* ------------------------------------------------------------ */
    status = om$send (msg = message IDundo.delete(f_defer_flag ),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDinspls's parent delete\n");

    /* ------------------------------------------------ */
    /* send delete message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send (msg = message ECcmd.delete(f_defer_flag ),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDinspls's parent delete\n");

}


/* ********************************************************************	*/
/* Redo this method to call EMpromote_class.  04/10/92;  JSY            */
/* ******************************************************************** */

action change_class()
{
  struct GRlc_info *loc_info;
  struct GRmd_env *md_env;
  struct GRid *id;
  OMuword classid;
  IGRlong msg;
  extern OMuword OPP_GRbcsubbc_class_id;
  extern IGRlong EMpromote_class();

  if ( me->located_obj[0].located_obj.objid == NULL_OBJID )
    goto quit;

  loc_info = &me->located_obj[0];
  md_env = &loc_info->module_info;
  id = &loc_info->located_obj;

  status = om$get_classid( osnum = id->osnum,
			   objid = id->objid,
			   p_classid = &classid );
  if ( classid != OPP_GRbcsubbc_class_id )
  {
    /* promote class */
    status = EMpromote_class( TRUE, md_env, id, &msg );
    if ( !( 1 & status ))
      return OM_E_ABORT;
  }
}



/* ********************************************************************	*/
/* This method takes the user input point and finds the pole that	*/
/* the user was trying to select.					*/
/* This code was taken from ECmvpole.sl					*/
/* 	--------------------------------------------------------------- */
action keypoint_pole
{
  IGRpoint		pnt1, pnt2; 
  IGRlong		msg;
  struct GRparms dum_parms;
  struct IGRline boreline;

  boreline.point1 = pnt1;  /* allocates storage for */
  boreline.point2 = pnt2;  /* the boreline          */

  status = EFboreline(&msg, my_id, &me->event1, &boreline);
  EMerr_hndlr(EMis_error(status)||EMis_error(msg), *sts, MSFAIL, quit);

  dum_parms.u = 5.0;  /* kludge for the tolerance */
  status = om$send(msg = message GRvg.GRkeypoint(&msg,
                        &me->located_obj[0].module_info.md_env.matrix_type,
                        me->located_obj[0].module_info.md_env.matrix,
                        &boreline, me->pole, &dum_parms),
                   targetid = me->located_obj[0].located_obj.objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, quit, "GRkeypoint error");
  EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

}


action check_ancestry ( long * sts )
{
 IGRshort          props;
 OM_S_CHANSELECT   to_owner;

 *sts = MSSUCC;
 me->has_owner = FALSE;

 /*
  * Check the located object's ancestry to see if it is a component of a
  * profile, composite profile, or a composite curve. First, check the object's
  * properties for a rigid relationship and then check the class of the owner
  * for SKmgr, SKcompcurve, and GRcompcurve. If the object has no owner,
  * then it is okay to process it.
  */

 status = om$send(msg = message GRgraphics.GRgetprops(sts, &props),
                  targetid = me->event1.located_object[0].located_obj.objid,
                  targetos = me->event1.located_object[0].located_obj.osnum);
 EMomerr_hndlr(status, quit, "ECmvpole.check_ancestry : GRgetprops");
 EMerr_hndlr(EMis_error(*sts), me->ret, OM_E_ABORT, quit);

 if (props & GR_RIGID_RELATIONSHIP)  /* object has a rigid owner */
 {
     me->has_owner = TRUE;

     /*
      * Now let's see if it's one of the ones we want.
      */

     ems$make_chanselect(chan_label = GRconnector_to_owners,
                         chan_selector = &to_owner);

     status = om$get_objid_at_index(
                        osnum = me->event1.located_object[0].located_obj.osnum,
                        objid = me->event1.located_object[0].located_obj.objid,
                        p_chanselect = &to_owner,
                        index = 0,
                        objidaddr = &me->owner_id.objid,
                        osnumaddr = &me->owner_id.osnum);

     status = om$get_classid(osnum = me->owner_id.osnum,
                             objid = me->owner_id.objid,
                             p_classid = &me->owner_classid);
     EMomerr_hndlr(status, quit, "ECmvpole.check_ancestry : om$get_classid");

     status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                   superclassid = OPP_SKmgr_class_id);

     if (status != OM_S_SUCCESS)
     {
         status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                      superclassid = OPP_SKcompcurve_class_id);

         if (status != OM_S_SUCCESS)
         {
             status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                      superclassid = OPP_GRcompcurve_class_id);

             if (status != OM_S_SUCCESS)
             {
                 me->has_owner = FALSE;
                 *sts = MSFAIL;
             }
         }
     }
 }

}


/* ********************************************************************	*/
action check_for_endpoint
{
  IGRlong   msg_loc;
  IGRint    last_pole;
  IGRdouble dist_pole1, dist_pole2, dist_pole3, dist_pole4;
  extern IGRdouble   BSdistptpt();
  IGRdouble tol;
  struct IGRbsp_curve   *crv;
  struct GRlc_info      obj_info;

  crv = NULL;


  obj_info.located_obj.objid = me->located_obj[0].located_obj.objid;
  obj_info.located_obj.osnum = me->located_obj[0].located_obj.osnum;
  OM_BLOCK_MOVE(me->located_obj[0].module_info.md_env.matrix,
                obj_info.module_info.md_env.matrix, sizeof(IGRmatrix) );

  status = EMget_the_geometry(&obj_info, TRUE, FALSE, FALSE, my_id, &crv,
                              &msg_loc);
  EMomerr_hndlr(status, ret_end, "EMget_the_geometry error\n");
  EMerr_hndlr(EMis_error(msg_loc), *sts, OM_E_ABORT, ret_end);

  status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tol);

  dist_pole1 = BSdistptpt(&msg_loc, me->pole, &crv->poles[0]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  dist_pole2 = BSdistptpt(&msg_loc, me->pole, &crv->poles[3]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  last_pole = (crv->num_poles - 1) * 3;
  dist_pole3 = BSdistptpt(&msg_loc, me->pole, &crv->poles[last_pole-3]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  dist_pole4 = BSdistptpt(&msg_loc, me->pole, &crv->poles[last_pole]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  if ( (dist_pole1 <= tol) || (dist_pole2 <= tol) )
  {
    if (me->has_owner)  /* can't modify start poles of a component object */
    {
        *sts = EMS_INV_POLE;
    }
    else
    {
        *sts = ID_TANGENCY_NOT_KEPT;
    }

  }
  else if ( (dist_pole3 <= tol) || (dist_pole4 <= tol) )
  {
    if (me->has_owner)  /* can't modify start poles of a component object */
    {
        *sts = EMS_INV_POLE;
    }
    else
    {
        *sts = ID_TANGENCY_NOT_KEPT;
    }

  }
  else
  {
    *sts = ID_TANGENCY_KEPT;
  }

ret_end:
  if (crv) free(crv);

}

