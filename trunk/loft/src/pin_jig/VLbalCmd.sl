/* $Id: VLbalCmd.sl,v 1.1.1.1 2001/01/04 21:11:33 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/pin_jig / VLbalCmd.sl
 *
 * Description:	I/LOFT put plates on the floor command.
 *		This command object defines the classe VLbalCmd. It puts
 *		I/STRUCT plates on the floor. The I/STRUCT plates images are
 *		taken in account now. It creates an associative object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLbalCmd.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1998/01/24  18:06:16  pinnacle
# Replaced: src/pin_jig/VLbalCmd.sl for:  by rchennup for loft
#
# Revision 1.3  1997/12/12  04:18:02  pinnacle
# Replaced: src/pin_jig/VLbalCmd.sl for:  by rchennup for loft
#
# Revision 1.2  1997/11/03  19:09:38  pinnacle
# Replaced: src/pin_jig/VLbalCmd.sl for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.6  1997/04/09  14:40:04  pinnacle
# Replaced: src/pin_jig/VLbalCmd.sl for: file header + compilation warning by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	10/12/92   mf		creation.
 *	12/01/92   mf		modification.
 *	12/17/92   mf		modification.
 *	03/17/93   mf		modification.
 *	04/21/93   mf		modification.
 *	06/17/93   mf		modification.
 *	09/27/93   mf		rebuild.
 *	04/14/94   mf		upgrade.
 *	10/05/94   mf		modification.
 *	04/09/97   mf		file header.
 *
 *************************************************************************/

command_string	VLC_M_PLATE_ON_FLOOR, 0, VLPuPlFl
command_table	"vl.cmd"
class		VLbalCmd
super_class	VLlocateCmd
product_name	"$LOFT"
status_display	"VLbalance", "-1", "-1"

start_state	TO_OBJECT

specification

instance {
			IGRint		Option[2];
			IGRint		GrOpt;
		struct	GRobj_env	BalCsys;
			IGRdouble	Angles[3];
			IGRboolean	Created;
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
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include        "FI.h"
#include	"macro.h"
#include	"grcoordsys.h"
#include	"csdef.h"

#include        "bsvalues.h"
#include        "bscrossp.h"
#include        "bsmkvec.h"
#include        "bsnorvec.h"

#include        "vsplatedef.h"
#include        "vsmiscmacros.h"

#include	"vlmsg.h"
#include	"vluserkey.h"
#include	"vltemplate.h"
#include	"vlfloor.h"
#include	"vlglobals.h"
#include        "vlmiscmacros.h"

#define  LOCATE_TWO_POINTS     	100
#define  LOCATE_THREE_POINTS   	101
#define  LOCATE_PLANE          	102
#define  NO_LOCATE		103

extern	GRclassid	OPP_EMSsubbs_class_id;
extern	GRclassid	OPP_VLbalance_class_id;
extern	GRclassid	OPP_VSbeam_class_id;
extern	GRclassid	OPP_VSplate_class_id;

from	GRgencs		import	GRgetmatrix;
from	GRgraphics	import	GRconstruct;
from	GRvg		import	GRcenter, GRdetplane, GRputsymb;
from	NDnode		import	NDchg_state;

/******************************************************************************/
state_table

#include	"vlmsg.h"

#define  LOCATE_TWO_POINTS     	100
#define  LOCATE_THREE_POINTS   	101
#define  LOCATE_PLANE          	102
#define  NO_LOCATE		103

/******************************************************************************/
state TO_OBJECT
	message_key		VL_S_PLATE_ON_FLOOR
	status_key              VL_S_STATUS_FORM
	execute			VLfreeList ( &me->ret, 1)
	execute			VLnotCreate ( &me->ret )

	on ELSE							state OBJECT
/******************************************************************************/
state OBJECT
	prompt			"Identify Plate(s) or Stiffener(s)"
	accept			"Accept Plate(s) or Stiffener(s)/Reject"
	locate_eligible		"+VSfeature"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state .
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_OBJ
/******************************************************************************/
state EVENT_OBJ
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)

	on ELSE							state GCSYS
/******************************************************************************/
state GCSYS
	status_key              VL_S_STATUS_FORM
	prompt_key		VL_P_CREATE_DATA_POINT_CS
	filter			get_event

	on EX_BACK_UP						state TO_OBJECT
	on EX_DATA		do VLloadCst (&me->ret)
				do VLstoreLocate (&me->ret)
				do VLcreateGcs (&me->ret)	state TO_BCS
/*	on ELSE							state . */
/******************************************************************************/
state TO_BCS
	execute			VLfreeList ( &me->ret, 2)
	execute			VLgetGrOpt(&me->ret)

	on RETURN_CODE = LOCATE_TWO_POINTS
		do prompt "Locate two Points"
		state locate_pt
	on RETURN_CODE = LOCATE_THREE_POINTS	
		do prompt "Locate three Points"
		state locate_pt
	on RETURN_CODE = LOCATE_PLANE		state locate_pl
	on RETURN_CODE = NO_LOCATE		state COMPUTE

state locate_pt
	status 			"Use group generator to locate"
        accept                  "Accept points"
        locate_eligible         "+GRpoint"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_OBJID		do VLstoreResponse (&me->ret)	
				state EVENT_BCS
	on EX_BACK_UP		state GCSYS
	on ELSE			state .

state locate_pl
        prompt                  "Locate a Plane"
        accept                  "Accept points"
        locate_eligible         "+EMSplane"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_DATA		do VLstoreResponse (&me->ret)	
				state EVENT_BCS
	on EX_BACK_UP		state GCSYS
	on ELSE			state .

state EVENT_BCS
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 2)
        execute                 VLstoreList ( &me->ret, 0, 2)
	execute			VLcheckInput (&me->ret)
	on   RETURN_CODE = VL_E_FAILURE	     state TO_BCS

	execute			VLloadCst (&me->ret)
        execute                 VLcreateBcs (&me->ret)

	on ELSE							state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
        execute                 VLcomputeFloor (&me->ret)

	on RETURN_CODE = VL_E_NO_REFERENCE_SURFACE
				do status_key VL_E_NO_REFERENCE_SURFACE
								state TO_OBJECT
	on RETURN_CODE = VL_E_FAILURE
				do status_key VL_E_FAILURE
								state TO_OBJECT
	on ELSE			do status_key VL_S_SUCCESS	state TO_OBJECT

	at delete		do VLfreeList ( &me->ret, 1)
				do VLfreeList ( &me->ret, 2)
				do VLdeleteCS ( &me->ret )
/******************************************************************************/
action init {

        me->ret = om$send ( msg      = message VLbalCmd.init( type, str_ptr),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Initialize form */
	FIfld_set_list_text (me->status_display_form_ptr,PJ_TY,0,0,NAM_J1,TRUE);
        FIfld_set_list_text (me->status_display_form_ptr,PJ_TY,1,0,NAM_J2,TRUE);

	/* Initialize balance coordinate system */
	me->BalCsys.obj_id.objid = NULL_OBJID;
	me->BalCsys.obj_id.osnum = me->Current.md_id.osnum;
	me->BalCsys.mod_env	 = me->Current;

	/* Initialize Euler angles values */
	me->Angles[0] = me->Angles[1] = me->Angles[2] = 0.0;
	FIg_erase( me->status_display_form_ptr, PJ_GRP ) ;
	FIg_display( me->status_display_form_ptr, PJ_GS ) ;

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action wakeup {

		IGRdouble	value;

	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLbalCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Initialize type */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PJT, &value),
                  targetid = my_id );
        me->JigType = (IGRint) value;
	switch (me->JigType) {
                case IDX_J1 :
                        FIg_set_text (me->status_display_form_ptr,PJ_TY,NAM_J1);
                        break;
                case IDX_J2 :
                        FIg_set_text (me->status_display_form_ptr,PJ_TY,NAM_J2);
                        break;
                default :
                        printf( "Unknown Jig Type %d\n", me->JigType);
                        break;
        }

	/* Initialize seams' query */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PJQ, &value),
                  targetid = my_id );
        me->Option[0] = (IGRint) value;
        FIg_set_state ( me->status_display_form_ptr, PJ_QY, me->Option[0]);

	/* Initialize marks' query */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PJM, &value),
                  targetid = my_id );
        me->Option[1] = (IGRint) value;
        FIg_set_state ( me->status_display_form_ptr, PJ_MK, me->Option[1]);

	/* Initialize position */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PJN, &value),
                  targetid = my_id );
        FIg_set_state ( me->status_display_form_ptr, PJ_PO, (IGRint) value);

	/* Initialize height */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PJH, &value),
                  targetid = my_id );
        FIg_set_value ( me->status_display_form_ptr, PJ_HI, value);

        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

		IGRint		suc, state;
		IGRlong		sts;
		IGRchar		type[80];
		IGRdouble	value;

	switch (gadget_label) {

		case FI_ACCEPT:
			FIg_get_text (form_ptr, PJ_GS, type);
                        if( !strcmp(type, TWO_PT_SEL) ) me->GrOpt = 1;
			else if( !strcmp(type, THREE_PT_SEL) ) me->GrOpt = 2;
			else if( !strcmp(type, PLANE_SEL) ) me->GrOpt = 3;
			else me->GrOpt = 0;

			FIg_get_text (form_ptr, PJ_TY, type);
                        if      (!strcmp(type, NAM_J1)) me->JigType = IDX_J1;
                        else    			me->JigType = IDX_J2;
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_PJT, (IGRdouble) me->JigType),
                                  targetid = my_id);

			FIg_get_state ( form_ptr, PJ_QY, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_PJQ, (IGRdouble) state),
                                  targetid = my_id);

			FIg_get_state ( form_ptr, PJ_MK, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_PJM, (IGRdouble) state),
                                  targetid = my_id);

			FIg_get_state ( form_ptr, PJ_PO, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_PJN, (IGRdouble) state),
                                  targetid = my_id);

			FIg_get_value ( form_ptr, PJ_HI, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_PJH, value),
                                  targetid = my_id);

			/* Get angle values */
			FIg_get_value ( form_ptr, PJ_EA_X, &me->Angles[0] );
			FIg_get_value ( form_ptr, PJ_EA_Y, &me->Angles[1] );
			FIg_get_value ( form_ptr, PJ_EA_Z, &me->Angles[2] );

		case FI_CANCEL:
			/* Set angle values */
			FIg_set_value ( form_ptr, PJ_EA_X, me->Angles[0] );
			FIg_set_value ( form_ptr, PJ_EA_Y, me->Angles[1] );
			FIg_set_value ( form_ptr, PJ_EA_Z, me->Angles[2] );
			FIf_erase ( form_ptr );

			/* Delete balance CS */
			if (me->BalCsys.obj_id.objid != NULL_OBJID) {
				status = gr$delete_object
					( msg       = &sts,
					  md_env    = &me->BalCsys.mod_env,
				          object_id = &me->BalCsys.obj_id );
				as$status ( msg    = "gr$delete_object()",
test   = (!(status & 0x00000001 & sts)),
					    action = GOTO_VALUE,
					    value  = quit );
				me->BalCsys.obj_id.objid = NULL_OBJID;
			}

			_put_response ( resp = EX_FORM_FINISHED );

			status = om$send ( msg = message CEO.erase_form_by_label
							( STATUS_FORM, 0, &suc),
					   targetid = my_id );

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PJT, &value),
                                  targetid = my_id);
                        me->JigType = (IGRint) value;
                        switch (me->JigType) {
                                case IDX_J1 :
                                        FIg_set_text ( form_ptr, PJ_TY, NAM_J1);
                                        break;
                                case IDX_J2 :
                                        FIg_set_text ( form_ptr, PJ_TY, NAM_J2);
                                        break;
                                default :
                                        printf( "Unknown Jig Type %d\n",
                                                me->JigType);
                                        goto quit;
                        }

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PJQ, &value),
                                  targetid = my_id);
                        me->Option[0] = (IGRint) value;
			FIg_set_state ( form_ptr, PJ_QY, me->Option[0]);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PJM, &value),
                                  targetid = my_id);
                        me->Option[1] = (IGRint) value;
			FIg_set_state ( form_ptr, PJ_MK, me->Option[1]);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PJN, &value),
                                  targetid = my_id);
			FIg_set_state ( form_ptr, PJ_PO, (IGRint)value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PJH, &value),
                                  targetid = my_id);
			FIg_set_value ( form_ptr, PJ_HI, value);

			goto quit;

		case PJ_EA_X:
		case PJ_EA_Y:
		case PJ_EA_Z:
			goto quit;

		case PJ_TG:
			FIg_get_state ( form_ptr, PJ_TG, &state);
			if( state )
			{
                            FIg_erase( form_ptr, PJ_GS ) ;
                            FIg_display( form_ptr, PJ_GRP );
			}
			else
			{
			    FIg_erase( form_ptr, PJ_GRP );
			    FIg_display( form_ptr, PJ_GS ) ;
			}
			goto quit;

		case PJ_TY:
		case PJ_QY:
		case PJ_MK:
		case PJ_PO:
		case PJ_HI:
			goto quit;

		default:
			goto quit;
	  }
}
/******************************************************************************/
action VLcreateBcs {

	IGRmatrix	GrdMat;
	IGRpoint	pntC;
	IGRvector	dirX, dirY, dirZ;
struct	IGRlbsys	lbSys;
struct	GRcs_construct	csCst;
	IGRint		i;
struct	GRid		balCS;

	/* Check number of entries */
	if ( (me->Cnt2 <= 0) || (me->Cnt2 >= 4) )	goto quit;

	/* Initialize struct IGRlbsys */
	for ( i=0; i<3; i++ ) {
		lbSys.diag_pt1[i]	= 0.0;
		lbSys.diag_pt2[i]	= 0.0;
		lbSys.matrix[12+i]	= 0.0;
	}
	lbSys.matrix[15]		= 1.0;

	/* Get ground CS matrix */
	status = om$send ( msg = message GRgencs.GRgetmatrix ( sts, GrdMat ),
			   targetid = me->GrdCsys.obj_id.objid,
			   targetos = me->GrdCsys.obj_id.osnum );
	as$status ( msg    = "GRgencs.GRgetmatrix",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Get center point */
	lbSys.matrix[3]  = pntC[0] = GrdMat[3];
	lbSys.matrix[7]  = pntC[1] = GrdMat[7];
	lbSys.matrix[11] = pntC[2] = GrdMat[11];

	/* Get X direction */
	lbSys.matrix[0] = dirX[0] = GrdMat[0];
	lbSys.matrix[4] = dirX[1] = GrdMat[4];
	lbSys.matrix[8] = dirX[2] = GrdMat[8];

	/* Get other points */
	switch (me->Cnt2) {

		struct	IGRplane	Pln;
			IGRpoint	Pnt[3];
			IGRvector	Nrm[2];

		case 1:	/* Plane object entry */

			/* Memory for struct IGRplane */
			Pln.point	= Pnt[0];
			Pln.normal	= Nrm[0];

			/* Fill struct IGRplane */
			status = om$send ( msg = message GRvg.GRdetplane (
					sts,
					&me->Lst2[0].mod_env.md_env.matrix_type,
					me->Lst2[0].mod_env.md_env.matrix,
					&Pln ),
					targetid = me->Lst2[0].obj_id.objid,
					targetos = me->Lst2[0].obj_id.osnum );
			as$status ( msg    = "GRvg.GRdetplane",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Z direction */
			lbSys.matrix[2]  = dirZ[0] = Pln.normal[0];
			lbSys.matrix[6]  = dirZ[1] = Pln.normal[1];
			lbSys.matrix[10] = dirZ[2] = Pln.normal[2];
			
			break;

		case 2: /* Plane normal by 2 points entry */

			/* Get 1st point */
			status = om$send ( msg = message GRvg.GRcenter (
					sts,
					&me->Lst2[0].mod_env.md_env.matrix_type,
					me->Lst2[0].mod_env.md_env.matrix,
					Pnt[0] ),
					targetid = me->Lst2[0].obj_id.objid,
					targetos = me->Lst2[0].obj_id.osnum );
			as$status ( msg    = "GRvg.GRcenter",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Get 2nd point */
			status = om$send ( msg = message GRvg.GRcenter (
					sts,
					&me->Lst2[1].mod_env.md_env.matrix_type,
					me->Lst2[1].mod_env.md_env.matrix,
					Pnt[1] ),
					targetid = me->Lst2[1].obj_id.objid,
					targetos = me->Lst2[1].obj_id.osnum );
			as$status ( msg    = "GRvg.GRcenter",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Z direction */
			BSmkvec ( sts, dirZ, Pnt[0], Pnt[1] );

			break;

		case 3: /* Plane by 3 points entry */

			/* Get 1st point */
			status = om$send ( msg = message GRvg.GRcenter (
					sts,
					&me->Lst2[0].mod_env.md_env.matrix_type,
					me->Lst2[0].mod_env.md_env.matrix,
					Pnt[0] ),
					targetid = me->Lst2[0].obj_id.objid,
					targetos = me->Lst2[0].obj_id.osnum );
			as$status ( msg    = "GRvg.GRcenter",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Get 2nd point */
			status = om$send ( msg = message GRvg.GRcenter (
					sts,
					&me->Lst2[1].mod_env.md_env.matrix_type,
					me->Lst2[1].mod_env.md_env.matrix,
					Pnt[1] ),
					targetid = me->Lst2[1].obj_id.objid,
					targetos = me->Lst2[1].obj_id.osnum );
			as$status ( msg    = "GRvg.GRcenter",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Get 3rd point */
			status = om$send ( msg = message GRvg.GRcenter (
					sts,
					&me->Lst2[2].mod_env.md_env.matrix_type,
					me->Lst2[2].mod_env.md_env.matrix,
					Pnt[2] ),
					targetid = me->Lst2[2].obj_id.objid,
					targetos = me->Lst2[2].obj_id.osnum );
			as$status ( msg    = "GRvg.GRcenter",
				    test   = (!(status & 0x00000001 & (*sts))),
				    action = GOTO_VALUE,
				    value  = quit );

			/* Z direction */
			BSmkvec ( sts, Nrm[0], Pnt[0], Pnt[1] );
			BSmkvec ( sts, Nrm[1], Pnt[0], Pnt[2] );
			BScrossp ( sts, Nrm[0], Nrm[1], dirZ );

			break;
	}

	/* Z direction */
	BSnorvec ( sts, dirZ );
	lbSys.matrix[2]  = dirZ[0];
	lbSys.matrix[6]  = dirZ[1];
	lbSys.matrix[10] = dirZ[2];

	/* Y direction */
	BScrossp ( sts, dirZ, dirX, dirY );
	lbSys.matrix[1] = dirY[0];
	lbSys.matrix[5] = dirY[1];
	lbSys.matrix[9] = dirY[2];

	/* Construct balance coordinate system */
	csCst.desc		= NULL;
	csCst.flag		= CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
	me->cst.class_attr	= (IGRchar *) &csCst;
	me->cst.geometry	= (IGRchar *) &lbSys;
	balCS.objid		= NULL_OBJID;
	balCS.osnum		= me->Current.md_id.osnum;
	status = om$construct ( classid = OPP_GRgencs_class_id,
				p_objid = &balCS.objid,
				osnum	= balCS.osnum,
				msg	= message GRgraphics.GRconstruct
							(&me->cst) );
	*sts = *(me->cst.msg);
	as$status ( msg    = "om$construct(GRgencs)",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Make source on balance coordinate system */
	me->BalCsys.mod_env = me->Current;
	as$make_source ( go_grid = balCS,
			 mod_env = &me->BalCsys.mod_env,
			 as_os   = me->Current.md_id.osnum,
			 as_grid = &me->BalCsys.obj_id );

	/* Balance coordinate system is support only */
	status = om$send ( msg = message NDnode.NDchg_state
					( ND_SUP_ONLY, ND_SUP_ONLY ),
		  	   targetid = me->BalCsys.obj_id.objid,
		  	   targetos = me->BalCsys.obj_id.osnum );
	as$status ( msg    = "NDnode.NDchg_state",
		    test   = (!(status & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = quit );
	

	/* Display on result */
	gr$display_object ( object_id = &me->BalCsys.obj_id,
                            md_env    = &me->BalCsys.mod_env,
                            mode      = GRbd );
}
/******************************************************************************/
action VLcreateGcs {

	IGRmatrix	matrix;

	/* Create ground coordinate system */
	status = VLcreWinRef ( me->AcceptPoint, me->VLwindow, (IGRboolean) TRUE,
			       &me->cst, (IGRboolean) TRUE, matrix, 
			       &me->GrdCsys, sts );		       
	as$status ( msg    = "VLcreWinRef",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Ground coordinate system is support only */
	status = om$send ( msg = message NDnode.NDchg_state
					( ND_SUP_ONLY, ND_SUP_ONLY ),
		  	   targetid = me->GrdCsys.obj_id.objid,
		  	   targetos = me->GrdCsys.obj_id.osnum );
	as$status ( msg    = "NDnode.NDchg_state",
		    test   = (!(status & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Highlight ground coordinate system */
	gr$display_object ( object_id = &me->GrdCsys.obj_id,
			    md_env    = &me->GrdCsys.mod_env,
			    mode      = GRbehd );
	
	/* Initialize balance coordinate system */
	me->BalCsys.obj_id.objid = NULL_OBJID;
	me->BalCsys.obj_id.osnum = me->Current.md_id.osnum;
	me->BalCsys.mod_env	 = me->Current;

	goto quit;
}
/******************************************************************************/
action VLcomputeFloor {

		IGRint		i, code=0;
	struct	GRid		Tlist[MACRO_B_FTEMP+MACRO_B_VTEMP];
		IGRdouble	value;
	struct	GRsymbology	symbology;
		IGRboolean	balCS = FALSE;

	/* Initialize */
	for ( i=0; i<MACRO_B_FTEMP + MACRO_B_VTEMP; i++) {
		Tlist[i].objid = NULL_OBJID;
		Tlist[i].osnum = me->Current.md_id.osnum; }
	*sts = VL_E_FAILURE;

	/* Test number of selected elements */
	if (me->Cnt1 < 1)	goto quit;

	/* Create ground distance expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_PJH, &value),
			   targetid = my_id);
	status = exp$create ( exp_value = value,
			      p_exp_id  = &Tlist[IDX_BT_GRD].objid,
			      osnum     = me->Current.md_id.osnum,
			      p_osnum   = &Tlist[IDX_BT_GRD].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create reverse flag expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_PJN, &value),
			   targetid = my_id);
	if (!(IGRint) value)	value = (IGRdouble) INVNORM_OF;
	else			value = (IGRdouble) INVNORM_ON;
	status = exp$create ( exp_value = value,
			      p_exp_id  = &Tlist[IDX_BT_REV].objid,
			      osnum     = me->Current.md_id.osnum,
			      p_osnum   = &Tlist[IDX_BT_REV].osnum );

	/* Put ground coordinate system is template list */
	Tlist[IDX_BT_GCS] = me->GrdCsys.obj_id;

	/* Treat balance coordinate system case */
	if (  (me->BalCsys.obj_id.objid == NULL_OBJID)
	   || (  (me->BalCsys.obj_id.objid == me->GrdCsys.obj_id.objid)
	      && (me->BalCsys.obj_id.osnum == me->GrdCsys.obj_id.osnum) ) ) {

		/* Create expression for balance coordinate system */
		status = exp$create ( exp_syntax = "bal_cs",
				      p_exp_id   = &Tlist[IDX_BT_BCS].objid,
				      osnum      = me->Current.md_id.osnum,
				      p_osnum    = &Tlist[IDX_BT_BCS].osnum,
				      type_rq	 = EXP_TEXT );
		if (status != EXP_S_SUCCESS)	goto quit;
	}
	else {	/* Put balance coordinate system is template list */
		Tlist[IDX_BT_BCS] = me->BalCsys.obj_id;

		balCS = TRUE;
	}

	/* Create pin jig type expression */
	status = exp$create ( exp_value = (IGRdouble) me->JigType,
			      p_exp_id  = &Tlist[IDX_BT_TYP].objid,
			      osnum     = me->Current.md_id.osnum,
			      p_osnum   = &Tlist[IDX_BT_TYP].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create query on expression */
	VLencode (  me->Option, 2, &code);
	status = exp$create ( exp_value = (IGRdouble) code,
			      p_exp_id  = &Tlist[IDX_BT_QYO].objid,
			      osnum     = me->Current.md_id.osnum,
			      p_osnum   = &Tlist[IDX_BT_QYO].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Make source on objects to project */
	for ( i=0; i<me->Cnt1; i++)
		as$make_source ( go_grid = me->Lst1[i].obj_id,
				 mod_env = &me->Lst1[i].mod_env,
				 as_os   = me->Current.md_id.osnum,
				 as_grid = &Tlist[MACRO_B_FTEMP+i] );

	/* Find an element with symbology */
	for ( i=0; i<me->Cnt1; i++) {
		if (  (vs$is_ancestry_valid(object  = &me->Lst1[i].obj_id,
                                            classid = OPP_VSplate_class_id))
		   || (vs$is_ancestry_valid(object  = &me->Lst1[i].obj_id,
                                            classid = OPP_EMSsubbs_class_id))
		   || (vs$is_ancestry_valid(object  = &me->Lst1[i].obj_id,
                                            classid = OPP_VSbeam_class_id)) )
			break;
	}

	/* Construct, place, name & change state of the "balance" macro */
	status = vl$placeLoftMacro ( msg        = sts,
				     classid    = OPP_VLbalance_class_id,
				     MacName    = MACRO_FLOOR,
				     number     = MACRO_B_FTEMP + me->Cnt1,
				     template   = Tlist,
				     Env        = &me->Current,
				     MatchKey   = BALANCE_KEY,
				     CobName    = "VLbalCmd",
				     mode       = OM_e_wrt_parent,
				     MatchId    = &Tlist[MACRO_B_FTEMP+i],
				     CommonName = FLOOR_NAME,
				     CobMyId    = my_id,
				     occ_symb   = &symbology );
	as$status ( msg    = "vl$placeLoftMacro(VLbalance)",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Set creation flag */
	me->Created = TRUE;

	/* Change symbology and level of ground coordinate system */
	status = om$send ( msg = message GRvg.GRputsymb ( sts, &symbology),
			   targetid = me->GrdCsys.obj_id.objid,
			   targetos = me->GrdCsys.obj_id.osnum );
	as$status ( msg    = "GRvg.GRputsymb",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	/* Display ground coordinate system */
	gr$display_object ( object_id = &me->GrdCsys.obj_id,
			    md_env    = &me->GrdCsys.mod_env,
			    mode      = GRbdhe );

	/* Change symbology and level of balance coordinate system */
	if (balCS == TRUE) {
		status = om$send ( msg = message GRvg.GRputsymb
						( sts, &symbology),
				   targetid = me->BalCsys.obj_id.objid,
				   targetos = me->BalCsys.obj_id.osnum );
		as$status ( msg    = "GRvg.GRputsymb",
			    test   = (!(status & 0x00000001 & (*sts))),
			    action = GOTO_VALUE,
			    value  = quit );

		gr$display_object ( object_id = &me->BalCsys.obj_id,
				    md_env    = &me->BalCsys.mod_env,
				    mode      = GRbdhe );
	}

	/* Redisplay objects that have been balanced */
	for ( i=0; i<me->Cnt1; i++)
		gr$display_object ( object_id = &me->Lst1[i].obj_id,
				    md_env    = &me->Lst1[i].mod_env,
				    mode      = GRbd );
}
/******************************************************************************/
action VLeulerForm {

	status = OM_S_SUCCESS;

	FIf_reset ( me->forms[0].form_ptr );
	FIg_set_value ( me->forms[0].form_ptr, PJ_EA_X, me->Angles[0] );
	FIg_set_value ( me->forms[0].form_ptr, PJ_EA_Y, me->Angles[1] );
	FIg_set_value ( me->forms[0].form_ptr, PJ_EA_Z, me->Angles[2] );
	FIf_display ( me->forms[0].form_ptr );

	goto quit;
}
/******************************************************************************/
action	VLnotCreate {

	me->GrdCsys.obj_id.objid	= NULL_OBJID;
	me->GrdCsys.obj_id.osnum	= me->Current.md_id.osnum;
	me->GrdCsys.mod_env		= me->Current;

	me->BalCsys.obj_id.objid	= NULL_OBJID;
	me->BalCsys.obj_id.osnum	= me->Current.md_id.osnum;
	me->BalCsys.mod_env		= me->Current;

	me->Angles[0]			= 0.0;
	me->Angles[1]			= 0.0;
	me->Angles[2]			= 0.0;

	me->Created			= FALSE;

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action	VLdeleteCS {

	if (me->Created == FALSE) {

		if (me->GrdCsys.obj_id.objid != NULL_OBJID)
			status = gr$delete_object
					( msg       = &sts,
					  md_env    = &me->GrdCsys.mod_env,
				          object_id = &me->GrdCsys.obj_id );

		if (me->BalCsys.obj_id.objid != NULL_OBJID)
			status = gr$delete_object
					( msg       = &sts,
					  md_env    = &me->BalCsys.mod_env,
				          object_id = &me->BalCsys.obj_id );
	}
	goto quit;
}
/******************************************************************************/

action	VLgetGrOpt {

	IGRlong loc_sts;

	if( !( me->Angles[0] == 0.0 && me->Angles[1] == 0.0 
	       && me->Angles[2] == 0.0 ) )
	{
	   /* Display resulting CS */
	   status = VLeulerCS ( &loc_sts, &me->GrdCsys, me->Angles,
				     &me->Current, &me->BalCsys );
	   as$status ( msg    = "VLeulerCS()",
		       test   = (!(status & 0x00000001 & loc_sts)),
		       action = GOTO_VALUE,
		       value  = quit );
	   me->GrOpt = 0;
	}

       	switch ( me->GrOpt ) {

	   case 0: me->ret = NO_LOCATE;
		   break;

	   case 1: me->ret = LOCATE_TWO_POINTS;
                   break;

           case 2: me->ret = LOCATE_THREE_POINTS;
		   break;

	   case 3: me->ret = LOCATE_PLANE;
		   break;
	}

	status = OM_S_SUCCESS;
	goto quit;       
}

action	VLcheckInput {

	me->ret = VL_E_FAILURE;
	
       	switch ( me->GrOpt ) {

	   case 1: if( me->Cnt2 == 2 )  me->ret = VL_S_SUCCESS;
		   else
		   {
                      ex$message( field   = ERROR_FIELD,
                                  in_buff = "Locate only two points");
		   }
                   break;

           case 2: if( me->Cnt2 == 3 )  me->ret = VL_S_SUCCESS;
                   else
                   {
                      ex$message( field   = ERROR_FIELD,
                                  in_buff = "Locate only three points");
                   }
		   break;

	   case 3: 
		me->ret = VL_S_SUCCESS;
		break;
	}

	status = OM_S_SUCCESS;
	goto quit;
}

