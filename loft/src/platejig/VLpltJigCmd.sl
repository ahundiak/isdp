/* $Id: VLpltJigCmd.sl,v 1.3 2001/01/16 20:24:49 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/platejig / VLpltJigCmd.sl
 *
 * Description:	plate jigs placement command object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLpltJigCmd.sl,v $
 *	Revision 1.3  2001/01/16 20:24:49  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/16 19:33:42  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/05/04  14:31:14  pinnacle
# Replaced: loft/src/platejig/VLpltJigCmd.sl for:  by azuurhou for Service Pack
#
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/01/02  06:20:50  pinnacle
# Replaced: src/platejig/VLpltJigCmd.sl for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.3  1997/04/07  13:33:32  pinnacle
# Replaced: src/platejig/VLpltJigCmd.sl for: File header added, redisplay located plates by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/07/97   mf		header added.
 *	04/07/97   mf		redisplay located VSplates.
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLpltJigCmd

     ABSTRACT   : creation of 3D plate_jigs.

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLpltJigCmd.
		  This command creates jigs used in manufacturing of plates
		  designed by I/STRUCT.


     CHANGE HISTORY : file created 	20-JAN-1993	Marc Fournier
		      devel resumption 	16-MAR-1993	Marc Fournier
		      file modified	17-MAR-1993	Marc Fournier
		      file modified	19-APR-1993	Marc Fournier
		      file modified	28-APR-1993	Marc Fournier
		      file modified	09-JUN-1993	Marc Fournier
		      file modified     17-JUN-1993     Marc Fournier
		      file upgraded     14-APR-1994     Marc Fournier
		      file modified     19-MAY-1994     Marc Fournier
		      file modified     06-OCT-1994     Marc Fournier
		      file modified     18-OCT-1994     Marc Fournier
	11/05/95	tlb	EMS 3.2 - change cs.h to grcoordsys.h

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_PLATE_JIG, 0, VLCrPlJi
command_table	"vl.cmd"
class		VLpltJigCmd
super_class	VLtpl2dCmd
product_name	"$LOFT"
status_display	"VLplateJig", "-1", "-1"
form		"VLcheckJig", 0, 0, "-1", "-1"

start_state	TO_PLATE

specification

#include        "gr.h"
#include        "grmacros.h"
#include        "growner.h"
#include        "csdef.h"
#include        "grcoordsys.h"
#include        "dpdef.h"
#include        "dp.h"
#include        "godef.h"
#include        "go.h"
#include        "igrtypedef.h"
#include        "igrdef.h"
#include        "igr.h"

instance {
		struct	GRobj_env	FramePlane;
			IGRint		CheckList[100];
			IGRint		RngPlane;
			IGRint		MaxPlane;
			IGRint		NumPlane;
			IGRchar		NamPlane[300];
			IGRint		JigGrid;
			IGRint		JigDirection;
}

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "nddef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "FI.h"
#include	"macro.h"
#include	"vsplatedef.h"
#include	"bstypes.h"

#include	"vlmsg.h"
#include	"vlplatejig.h"
#include	"vluserkey.h"
#include	"vlglobals.h"
#include	"vlmiscmacros.h"

extern	GRclassid	OPP_VLjigMgr_class_id;

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vlplatejig.h"

/******************************************************************************/
state TO_PLATE
	message_key		VL_S_PLATE_JIG
	status_key		VL_S_STATUS_FORM
        execute                 VLfreeList ( &me->ret, 1)

	on ELSE							state PLATE
/******************************************************************************/
state PLATE
	prompt_key		VL_P_PLATE
	accept_key		VL_M_PLATE
	locate_class		"+VSimgFeature,VSplate"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_PLT
/******************************************************************************/
state EVENT_PLT
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)
	on ELSE							state CHOICE
/******************************************************************************/
state CHOICE
	status			" "
	execute			VLcheckJigGrid (&me->ret)
					on RETURN_CODE = 0	state FRAME
					on RETURN_CODE = 1	state TO_PLANE
					on ELSE			state terminate
/******************************************************************************/
state FRAME
	status			" "
	prompt_key		VL_P_FRAME_PLANE
	accept_key		VL_M_FRAME_PLANE
	locate_class		"SMframe"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state TO_PLATE
	on EX_DATA		do VLstoreLocate (&me->ret)
				do VLstoreFrame (&me->ret)	state EVALUATE
/******************************************************************************/
state EVALUATE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
	execute			VLevaluateJigPlane (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS
                                        do status_key VL_S_SUCCESS
								state WAIT_FORM
				on ELSE
                                        do status_key VL_E_FAILURE
								state TO_PLATE
/******************************************************************************/
state WAIT_FORM
	status			" "
	filter			get_event

	on EX_FORM_FINISHED					state TO_LINE
/******************************************************************************/
state TO_PLANE
	status			" "
        execute                 VLfreeList ( &me->ret, 2)

	on ELSE							state PLANE
/******************************************************************************/
state PLANE
	prompt_key		VL_P_PLANE
	accept_key		VL_M_PLANE
	locate_class		"+EMSsurface"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	execute			VLisSurfacePlanarAHon (&me->ret)
	filter			locate

	on EX_BACK_UP						state TO_PLATE
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_PLN
/******************************************************************************/
state EVENT_PLN
        status_key              VL_S_PROCESS
        prompt                  " "
        execute                 VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 2)
        execute                 VLstoreList ( &me->ret, 0, 2)
	execute			VLisSurfacePlanarAHof (&me->ret)

        on ELSE                                                 state TO_LINE
/******************************************************************************/
state TO_LINE
	status			" "
        execute                 VLfreeList ( &me->ret, 3)
	execute			VLcheckJigType (&me->ret)
					on RETURN_CODE = IDX_J3	state LINE
					on RETURN_CODE = IDX_J4	state COMPUTE
					on RETURN_CODE = IDX_J5	state COMPUTE
					on ELSE			state terminate
/******************************************************************************/
state LINE
	prompt_key		VL_P_CHAR_LINE
	accept_key		VL_M_CHAR_LINE
	locate_eligible		"+GRcurve"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state CHOICE
	on EX_RJT_MOVEON 					state COMPUTE
	on EX_OBJID or EX_DATA	do VLstoreLocate (&me->ret)	state EVENT_LIN
/******************************************************************************/
state EVENT_LIN
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 3)
        execute                 VLstoreList ( &me->ret, 0, 3)

	on ELSE							state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLcomputePlateJig (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS
                                        do VLfreeList ( &me->ret, 1)
                                        do VLfreeList ( &me->ret, 2)
                                        do VLfreeList ( &me->ret, 3)
                                        do status_key VL_S_SUCCESS
								state TO_PLATE
				on ELSE
                                        do VLfreeList ( &me->ret, 1)
                                        do VLfreeList ( &me->ret, 2)
                                        do VLfreeList ( &me->ret, 3)
                                        do status_key VL_E_FAILURE
								state TO_PLATE
/******************************************************************************/
action init {

		IGRdouble	value;

	me->ret = om$send ( msg      = message VLpltJigCmd.init( type, str_ptr),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status(sts = me->ret);

	/* Initialize instances */
	me->ShipAxis[0] = 1.0;
	me->ShipAxis[1] = 0.0;
	me->ShipAxis[2] = 0.0;
	me->NamPlane[0] = '\0';

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_TJT, &value),
                  targetid = my_id );
        me->JigType = (IGRint) value;

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_JGO, &value),
                  targetid = my_id );
        me->JigGrid = (IGRint) value;
	me->JigDirection = 0;

	/* Initialize form */
	FIfld_set_list_text (me->status_display_form_ptr,JF_TY,0,0,NAM_J3,TRUE);
	FIfld_set_list_text (me->status_display_form_ptr,JF_TY,1,0,NAM_J4,TRUE);
	FIfld_set_list_text (me->status_display_form_ptr,JF_TY,2,0,NAM_J5,TRUE);

        FIg_disable( me->status_display_form_ptr, JF_SW );
        FIg_disable( me->status_display_form_ptr, 19    );

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action wakeup {

		IGRdouble	value, xlo, ylo;

	/* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
	me->ret = om$send ( msg      = message VLlocateCmd.wakeup (pos),
			    mode     = OM_e_wrt_message,
			    targetid = my_id );
	as$status(sts = me->ret);

	/* Initialize forms */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_XJS, &xlo),
		  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_YJS, &ylo),
		  targetid = my_id);
	FIf_set_location ( me->status_display_form_ptr,
			   (IGRint)xlo, (IGRint)ylo);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_MID, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_MS, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_JGG, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_GG, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_EXT, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_EX, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_RAD, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_HR, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_OFF, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_OS, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_SPA, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_SP, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_JSW, &value),
		  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, JF_SW, value);

	switch (me->JigType) {
		case IDX_J3 :
			FIg_set_text (me->status_display_form_ptr,JF_TY,NAM_J3);
			break;
		case IDX_J4 :
			FIg_set_text (me->status_display_form_ptr,JF_TY,NAM_J4);
			break;
		case IDX_J5 :
			FIg_set_text (me->status_display_form_ptr,JF_TY,NAM_J5);
			break;
		default :
			printf( "Unknown Jig Type %d\n", me->JigType);
			break;
	}

	/* Set toggles */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_JGO, &value),
		  targetid = my_id);
	FIg_set_state (me->status_display_form_ptr, JF_GO, (IGRint)value);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action sleep {

		IGRint	xlo, ylo;

	/* Execute method sleep of upper class */
	me->ret = om$send ( msg      = message VLlocateCmd.sleep (pos),
			    mode     = OM_e_wrt_message,
			    targetid = my_id );
	as$status(sts = me->ret);

	FIf_get_location ( me->status_display_form_ptr, &xlo, &ylo);
	om$send ( msg = message VLlocateCmd.VLmodGlobals
				( &me->ret, NAM_G_XJS, (IGRdouble)xlo),
	  	  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLmodGlobals
				( &me->ret, NAM_G_YJS, (IGRdouble)ylo),
	  	  targetid = my_id);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action form_notification {

		IGRlong		sts;
		IGRint		suc, i, xlo, ylo, state;
		IGRchar		type[80], work[20];
		IGRdouble	value;

	switch (form_label) {

	case 0:

		FIf_get_location ( form_ptr, &xlo, &ylo);
		om$send ( msg = message VLlocateCmd.VLmodGlobals
					( &me->ret, NAM_G_XJF, (IGRdouble)xlo),
		  	  targetid = my_id);
		om$send ( msg = message VLlocateCmd.VLmodGlobals
					( &me->ret, NAM_G_YJF, (IGRdouble)ylo),
		  	  targetid = my_id);

		switch (gadget_label) {

		case FI_EXECUTE:
			for ( i=0; i<me->RngPlane; i++)
				FIfld_get_select ( form_ptr, JF_MCF, i, 0,
						   &me->CheckList[i] );
			sts = VLprocessCheckList ( me->CheckList,
						   me->RngPlane,
						   &me->NumPlane,
						   &me->MaxPlane,
						   me->NamPlane );
/*
			as$status ( sts    = sts,
				    msg    = "VLprocessCheckList()",
                    		    action = GOTO_VALUE,
                    		    value  = quit );
*/
			for ( i=0; i<me->RngPlane; i++) {
				strcpy ( work, &me->NamPlane[10*i]);
				strncat ( work, "          ", 9 - strlen(work));
				FIfld_set_text ( form_ptr, JF_MCF,
						 i, 1, work, FALSE);
			}
			goto quit;

		case FI_ACCEPT:
			for ( i=0; i<me->RngPlane; i++)
				FIfld_get_select ( form_ptr, JF_MCF, i, 0,
						   &me->CheckList[i] );
			sts = VLprocessCheckList ( me->CheckList,
						   me->RngPlane,
						   &me->NumPlane,
						   &me->MaxPlane,
						   me->NamPlane );
/*
			as$status ( sts    = sts,
				    msg    = "VLprocessCheckList()",
                    		    action = GOTO_VALUE,
                    		    value  = quit );
*/
			FIf_erase (form_ptr);
			_put_response (resp = EX_FORM_FINISHED);
			goto quit;

		case FI_CANCEL:
			for ( i=0; i<me->RngPlane; i++)
				FIfld_set_select ( form_ptr, JF_MCF, i, 0,
						   me->CheckList[i] );
			FIf_erase (form_ptr);
			_put_response (resp = EX_FORM_FINISHED);
			goto quit;

		default:
			goto quit;
		}

	case STATUS_FORM:

		FIf_get_location ( form_ptr, &xlo, &ylo);
		om$send ( msg = message VLlocateCmd.VLmodGlobals
					( &me->ret, NAM_G_XJS, (IGRdouble)xlo),
		  	  targetid = my_id);
		om$send ( msg = message VLlocateCmd.VLmodGlobals
					( &me->ret, NAM_G_YJS, (IGRdouble)ylo),
		  	  targetid = my_id);

		switch (gadget_label) {

		case FI_ACCEPT:

			FIg_get_value(form_ptr, JF_MS, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_MID, value),
				  targetid = my_id);

			FIg_get_value(form_ptr, JF_EX, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_EXT, value),
				  targetid = my_id);

			FIg_get_value(form_ptr, JF_HR, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_RAD, value),
				  targetid = my_id);

			FIg_get_value(form_ptr, JF_GG, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_JGG, value),
				  targetid = my_id);

			FIg_get_value(form_ptr, JF_OS, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_OFF, value),
				  targetid = my_id);

			FIg_get_value(form_ptr, JF_SP, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_SPA, value),
				  targetid = my_id);

			FIg_get_text (form_ptr, JF_TY, type);
			if      (!strcmp(type, NAM_J3))	me->JigType = IDX_J3;
			else if (!strcmp(type, NAM_J4))	me->JigType = IDX_J4;
			else				me->JigType = IDX_J5;
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_TJT, (IGRdouble) me->JigType),
                                  targetid = my_id);

			FIg_get_value(form_ptr, JF_SW, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						( &sts, NAM_G_JSW, value),
				  targetid = my_id);

			FIg_get_state(form_ptr, JF_GO, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
					( &sts, NAM_G_JGO, (IGRdouble)state),
				  targetid = my_id);
			me->JigGrid = state;

			FIg_get_state(form_ptr, JF_DR, &me->JigDirection );

		case FI_CANCEL:
			om$send ( msg = message CEO.erase_form_by_label
						( STATUS_FORM, 0, &suc),
				  targetid = my_id);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_MID, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_MS, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_EXT, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_EX, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_RAD, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_HR, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_JGG, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_GG, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_OFF, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_OS, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_SPA, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_SP, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_TJT, &value),
                                  targetid = my_id);
                        me->JigType = (IGRint) value;
                        switch (me->JigType) {
                                case IDX_J3 :
                                        FIg_set_text ( form_ptr, JF_TY, NAM_J3);
                                        break;
                                case IDX_J4 :
                                        FIg_set_text ( form_ptr, JF_TY, NAM_J4);
                                        break;
                                case IDX_J5 :
                                        FIg_set_text ( form_ptr, JF_TY, NAM_J5);
                                        break;
                                default :
                                        printf( "Unknown Jig Type %d\n",
                                                me->JigType);
                                        goto quit;
                        }

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_JSW, &value),
				  targetid = my_id);
			FIg_set_value(form_ptr, JF_SW, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
						( &sts, NAM_G_JGO, &value),
				  targetid = my_id);
			FIg_set_state(form_ptr, JF_GO, (IGRint)value);
                        me->JigGrid = (IGRint) value;

		case JF_MS:
		case JF_EX:
		case JF_HR:
		case JF_GG:
		case JF_OS:
		case JF_SP:
		case JF_TY:
		case JF_GO:
		case JF_SW:
		default:
			goto quit;
		}

	default:
		printf( "FORM %d unkown\n", gadget_label);
		goto quit;
	}
}
/******************************************************************************/
action VLstoreFrame {

	*sts = OM_S_SUCCESS;
	me->FramePlane = me->Loc_env;

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action VLevaluateJigPlane {

			IGRint		i;
			IGRdouble	middle, spacing;
			IGRchar		text[DI_PATH_MAX];
			IGRdouble	xlo, ylo;

	/* Retrieve globals */
	status = om$send ( msg 	    = message VLlocateCmd.VLgetGlobals
						( sts, NAM_G_MID, &middle),
			   targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	status = om$send ( msg 	    = message VLlocateCmd.VLgetGlobals
						( sts, NAM_G_SPA, &spacing),
			   targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate cutting planes */
	status = VLfindPpPoint ( sts, &me->FramePlane, &me->Current,
				 me->Cnt1, me->Lst1, me->ShipAxis, middle,
				 spacing, NULL, NULL, &me->RngPlane );
	as$status ( msg    = "VLfindPpPoint()",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (me->RngPlane > JF_LENGTH) {
		printf( "Too many template_jigs selected\n");
                *sts = MSFAIL;
                goto wrapup;
        }

	/* Initialize <Check Jig> form */
	FIf_reset (me->forms[0].form_ptr);
	FIfld_set_num_rows ( me->forms[0].form_ptr, JF_MCF, me->RngPlane);
	for ( i=0; i<me->RngPlane; i++) {
		text[0] = '\0';
		sprintf ( text, " JIG %2d", i+1);
		FIfld_set_text ( me->forms[0].form_ptr, JF_MCF,
				 i, 0, text, FALSE);
	}
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_XJF, &xlo),
		  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_YJF, &ylo),
		  targetid = my_id);
	FIf_set_location ( me->forms[0].form_ptr, (IGRint)xlo, (IGRint)ylo);

	/* Kick-of <Check Jig> form */
	FIf_display (me->forms[0].form_ptr);

wrapup:
        if (!(status&1&(*sts)))		*sts = VL_E_FAILURE;
	else				*sts = VL_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLcheckJigType { 	*sts = me->JigType;
				status = OM_S_SUCCESS;
				goto quit; }
/******************************************************************************/
action VLcheckJigGrid { 	*sts = me->JigGrid;
				status = OM_S_SUCCESS;
				goto quit; }
/******************************************************************************/
action VLcomputePlateJig {

		IGRint		code, i, var=0, Tnum=MACRO_PM_FTEMP;
		IGRdouble	val[NUM_PM_ATTR];
	struct	GRid		box_id, *Tvar;

	/* Initialize */
	Tvar = NULL;
	box_id.objid = NULL_OBJID;
	box_id.osnum = me->Current.md_id.osnum;

	/* Exit if no VSplates */
	if (!me->Cnt1)	goto wrapup;

	if (me->Cnt2) {
		/* Case of free grid : simulate me->CheckList fill */
		for ( i=0; i<me->Cnt2; i++)	me->CheckList[i] = 1;
		me->RngPlane = me->Cnt2;
	}
	VLencode ( me->CheckList, me->RngPlane, &code);

	/* Construct attribute box */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_JGG, &val[IDX_PM_GRD]),
		  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_EXT, &val[IDX_PM_EXT1]),
		  targetid = my_id);
	val[IDX_PM_EXT2] = val[IDX_PM_EXT1];
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_RAD, &val[IDX_PM_HOLE]),
		  targetid = my_id);
	val[IDX_PM_INV] = (IGRdouble) INVNORM_ON;
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_MID, &val[IDX_PM_MID]),
		  targetid = my_id);
	val[IDX_PM_TYPE] = (IGRdouble) me->JigType;
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_OFF, &val[IDX_PM_OSET]),
		  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					(sts, NAM_G_SPA, &val[IDX_PM_SPAC]),
		  targetid = my_id);
	val[IDX_PM_NPLT] = (IGRdouble) me->Cnt1;
	val[IDX_PM_NFRM] = (IGRdouble) me->RngPlane;
	val[IDX_PM_CODE] = (IGRdouble) code;
	val[IDX_PM_NLIN] = (IGRdouble) me->Cnt3;
	val[IDX_PM_GROP] = (IGRdouble) me->JigGrid;
	val[IDX_PM_DIR]  = (IGRdouble) me->JigDirection;
	val[IDX_PM_STOP] = 0.0;
	om$send ( msg = message VLlocateCmd.VLgetGlobals
				 	(sts, NAM_G_JSW, &val[IDX_PM_STWI]),
		  targetid = my_id);

	status = VLsetPlateJigMgrAttr ( sts, val, &box_id);
	as$status ( msg    = "VLsetPlateJigMgrAttr()",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	
	/* Construct variable templates */
	var = me->Cnt1;
	if (me->JigGrid)		var += me->Cnt2;
	else				var ++;
	if (me->JigType == IDX_J3)	var += me->Cnt3;
	Tvar = om$calloc ( num = MACRO_PM_FTEMP + var, structure = struct GRid);

	/* Set the fix template */
	Tvar[IDX_PM_ATTR] = box_id;

	/* Fist the VSplates */
	Tnum = MACRO_PM_FTEMP;
	for ( i=0; i<me->Cnt1; i++)
		as$make_source ( go_grid = me->Lst1[i].obj_id,
                                 mod_env = &me->Lst1[i].mod_env,
                                 as_os   = me->Current.md_id.osnum,
                                 as_grid = &Tvar[Tnum+i]);
	Tnum += me->Cnt1;

	/* Second the SMplane(s) */
	if (me->JigGrid) {
		for ( i=0; i<me->Cnt2; i++)
			as$make_source ( go_grid = me->Lst2[i].obj_id,
                                 	 mod_env = &me->Lst2[i].mod_env,
                                 	 as_os   = me->Current.md_id.osnum,
                                 	 as_grid = &Tvar[Tnum+i]);
		Tnum += me->Cnt2;
	}
	else {	as$make_source ( go_grid = me->FramePlane.obj_id,
                                 mod_env = &me->FramePlane.mod_env,
                                 as_os   = me->Current.md_id.osnum,
                                 as_grid = &Tvar[Tnum]);
		Tnum++;
	}

	/* Third the characteristic lines (if any) */
	if (me->JigType == IDX_J3) {
		for ( i=0; i<me->Cnt3; i++)
			as$make_source ( go_grid = me->Lst3[i].obj_id,
                                         mod_env = &me->Lst3[i].mod_env,
                                         as_os   = me->Current.md_id.osnum,
                                         as_grid = &Tvar[Tnum+i]);
		Tnum += me->Cnt3;
	}

	/* Construct, place, name & change state of the VLjigMgr macro */
        status = vl$placeLoftMacro ( msg        = sts,
                                     classid    = OPP_VLjigMgr_class_id,
                                     MacName    = MACRO_PM_DEF,
                                     number     = Tnum,
                                     template   = Tvar,
                                     Env        = &me->Current,
                                     MatchKey   = PLATE_JIG_KEY,
                                     CobName    = "VLpltJigCmd",
                                     mode       = OM_e_wrt_parent,
                                     MatchId    = &Tvar[MACRO_PM_FTEMP],
                                     CommonName = MACRO_PM_NAME,
                                     CobMyId    = my_id );
        as$status ( msg    = "vl$placeLoftMacro(VLjigMgr)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	/* Redisplay located VLplates ('cause frozen copies has been deleted) */
	if (me->Lst1) {
		for ( i=0; i<me->Cnt1; i++ ) {
			if (me->Lst1[i].obj_id.objid != NULL_OBJID)
				gr$display_object (
					md_env	  = &me->Lst1[i].mod_env,
					object_id = &me->Lst1[i].obj_id );
		}
	}
	

	if (Tvar) {	om$dealloc(ptr = Tvar);		Tvar = NULL;	}
	goto quit;
}
/******************************************************************************/
