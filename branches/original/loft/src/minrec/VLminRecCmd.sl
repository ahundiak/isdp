/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLminRecCmd

     ABSTRACT   : I/LOFT minimal rectangle command

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLminRecCmd.
		  This command extract the minimal rectangle including a planar
		  closed curve.
         	  Further enhancements allow the selection of a surface or a
		  VSplate.


     CHANGE HISTORY : file created 	15-SEP-1992	Marc Fournier
		      file modified     01-DEC-1992     Marc Fournier
		      file modified     14-JAN-1993     Marc Fournier
		      file modified     25-FEV-1993     Marc Fournier
		      file modified     17-MAR-1993     Marc Fournier
		      file upgraded	06-APR-1994     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_MIN_RECTANGLE, 0, VLEvMiRe
command_table	"vl.cmd"
class		VLminRecCmd
super_class	VLlocateCmd
product_name	"$LOFT"
status_display	"VLminRec", "-1", "-1"

start_state	start

specification

instance {
			IGRint		button_sav;
			IGRint		button_tmp;
			IGRdouble	margin;
			IGRchar		plate_side[20];
}

implementation

#include        <stdio.h>
#include        "vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "grmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "FI.h"

#include	"vsplatedef.h"

#include	"vlmsg.h"
#include	"vlgrdef.h"
#include	"vlgrmacros.h"

extern	GRclassid	OPP_EMSsubbs_class_id, OPP_VSplate_class_id;

/******************************************************************************/
state_table

#include	"vlmsg.h"

/******************************************************************************/
state start
	message_key		VL_S_MIN_RECTANGLE
	status_key		VL_S_STATUS_FORM

	on ELSE							state LOCATE
/******************************************************************************/
state LOCATE
	prompt_key		VL_P_PLANAR_AND_CLOSE_ENTRY
	accept_key		VL_M_CURVE_OR_SURFACE_OR_PLATE
	locate_eligible		"+VSplate,EMSsubbs,GRcurve"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state start
	on EX_RJT_MOVEON or EX_STRING or EX_VALUE or EX_CHAR	state LOCATE
	on EX_DATA or EX_OBJID	do VLstoreResponse (&me->ret)	state COMPUTE
/******************************************************************************/
state COMPUTE
	prompt			" "
	status_key		VL_S_PROCESS
	execute			VLstoreLocate ( &me->ret)
	execute			VLfreeList    ( &me->ret, 1)
	execute			VLstoreList   ( &me->ret, 0, 1)
	execute			VLcomputeRectangle (&me->ret)
				on RETURN_CODE = VL_E_FAILURE
					do status_key VL_E_FAILURE state LOCATE
				on RETURN_CODE = VL_E_NON_PLANAR
					do status_key VL_E_NON_PLANAR
								    state LOCATE
				on ELSE
					do status_key VL_S_SUCCESS state LOCATE

at delete do VLfreeList    ( &me->ret, 1)
/******************************************************************************/
action init {

	/*|Execute method init of VLlocateCmd*/
	me->ret = om$send ( msg      = message VLminRecCmd.init (type,str_ptr),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status(sts = me->ret);

	/*|Initialize variables*/
	me->button_sav = B_BESTOF;
	me->button_tmp = B_BESTOF;
	me->margin     = 0.0;
	strcpy ( me->plate_side, VS_K_plBotSfName);

        /* Set default values in form */
        FIg_set_value(me->status_display_form_ptr, F_MG, me->margin);
FIfld_set_list_text(me->status_display_form_ptr,F_SD,0,0,VS_K_plBotSfName,TRUE);
FIfld_set_list_text(me->status_display_form_ptr,F_SD,1,0,VS_K_plTopSfName,TRUE);
	FIg_set_text (me->status_display_form_ptr, F_SD, me->plate_side);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action wakeup {

	/* Execute method wakeup of VLlocateCmd*/
	me->StatusDisplay = TRUE;
	me->ret = om$send ( msg      = message VLminRecCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action form_notification {

	IGRint		sts;

	switch (gadget_label) {

    		case FI_CANCEL:
			FIg_set_value ( form_ptr, F_MG, me->margin);
			FIg_set_text  ( form_ptr, F_SD, me->plate_side);
			FIg_set_state ( form_ptr, me->button_tmp, 0);
			FIg_set_state ( form_ptr, me->button_sav, 1);
			status = om$send (
				msg      = message CEO.erase_form_by_label
							( STATUS_FORM, 0, &sts),
				targetid = my_id);
			goto quit;

    		case FI_ACCEPT:
			FIg_get_value ( form_ptr, F_MG, &me->margin);
			FIg_get_text  ( form_ptr, F_SD, me->plate_side);
			status = om$send (
				msg      = message CEO.erase_form_by_label
							( STATUS_FORM, 0, &sts),
				targetid = my_id);
			me->button_sav = me->button_tmp;
			goto quit;

    		case B_INERTI:
    		case B_STROKE:     
    		case B_SQUARE:     
    		case B_BESTOF:     
			me->button_tmp = gadget_label;
		case F_MG:
		case F_SD:
		default:
			goto quit;
	}
}
/******************************************************************************/
action VLcomputeRectangle {

			IGRint		i;
			OMuword		clid;
	struct		GRid		obj[2], group_id;
	struct		GRobj_env	work1, work2;
			IGRchar		side[20];
			IGRboolean	del_flag;
			IGRdouble	L, W;

	for (i=0;i<me->Cnt1;i++) {

		del_flag = FALSE;
		work1  =  me->Lst1[i];

		/*c Determine the class of located object */
		om$get_classid ( osnum	   = work1.obj_id.osnum,
				 objid	   = work1.obj_id.objid,
				 p_classid = &clid );

		/*c If the located object is a VSplate */
		if( om$is_ancestry_valid (
                        superclassid    = OPP_VSplate_class_id,
                        subclassid      = clid ) == OM_S_SUCCESS ) {

			/*c Set VSplate path to wanted surface */
			if      (!strcmp (me->plate_side, VS_K_plBotSfName))
				strcpy ( side, VS_K_plBotSfPath);
			else if (!strcmp (me->plate_side, VS_K_plTopSfName))
				strcpy ( side, VS_K_plTopSfPath);
			else {
				printf( "Unknown VSplate side : <%s>\n",
					me->plate_side );
				break;
			}

			status =
			VLextractVSplateSurface ( sts,
						  &work1.obj_id,
						  &work1.mod_env,
						  side,
						  &work2.obj_id,
						  &work2.mod_env,
						  NULL );
        		if (!(status&1&(*sts))) {
EFmsgReport ( 0, status, "VLextractVSplateSurface()");
EFmsgReport ( 0, *sts,   "VLextractVSplateSurface()");
                		goto quit;
        		}
			work1 = work2;
			om$get_classid ( osnum	   = work1.obj_id.osnum,
				 	 objid	   = work1.obj_id.objid,
				 	 p_classid = &clid );
		}

		/*c If the located object is a EMSsubbs */
		if( om$is_ancestry_valid (
                        superclassid    = OPP_EMSsubbs_class_id,
                        subclassid      = clid ) == OM_S_SUCCESS ) {
			status =
			VSdrwMakeSfContourCompCurve ( sts,
						      &work1.obj_id,
						      &work1.mod_env,
						      &me->Current,
						      &work2.obj_id );
        		if (!(status&1&(*sts))) {
EFmsgReport ( 0, status, "VSdrwMakeSfContourCompCurve()");
EFmsgReport ( 0, *sts,   "VSdrwMakeSfContourCompCurve()");
                		goto quit;
        		}
			work1.obj_id  = work2.obj_id;
			work1.mod_env = me->Current;
			del_flag = TRUE;
		}

		obj[0].objid = obj[1].objid = NULL_OBJID;
		obj[0].osnum = obj[1].osnum = me->Current.md_id.osnum;
		status = vl$minrect ( curve	= &work1.obj_id,
				      environ	= &work1.mod_env,
				      option    = me->button_sav,
				      margin    = me->margin,
				      length    = &L,
				      width     = &W,
				      frame	= &obj[0],
				      text 	= &obj[1],
				      msg       = sts );
        	if (!(status&1&(*sts))) {
                	EFmsgReport ( 0, status, "vl$minrect()");
                	EFmsgReport ( 0, *sts,   "vl$minrect()");
                	goto quit;
        	}
		else *sts = VL_S_SUCCESS;

		if (del_flag == TRUE) {
			status = gr$delete_object (
					msg       = sts,
					md_env    = &work1.mod_env,
					object_id = &work1.obj_id);
        		if (!(status&1&(*sts))) {
EFmsgReport ( 0, status, "gr$delete_object() : sts");
EFmsgReport ( 0, *sts  , "gr$delete_object() : msg");
                		goto quit;
        		}
			status = gr$display_object(
					md_env    = &me->Lst1[i].mod_env,
					object_id = &me->Lst1[i].obj_id);
        		if (!(status&1)) {
EFmsgReport ( 0, status, "gr$display_object() : sts");
                		goto quit;
        		}
		}

		/*c Display minimal rectangle frame */
        	status = gr$display_object ( object_id = &obj[0],
                	                     md_env    = &me->Current,
	                      	             mode      = GRbd );
        	if (!(status&1)) {
                	EFmsgReport ( 0, status, "gr$display_object()");
                	goto quit;
        	}

		/*c Construct graphic group */
        	group_id.objid = NULL_OBJID;
        	group_id.osnum = me->Current.md_id.osnum;
        	status = gr$create_graphic_group ( msg         = sts,
                                                   object_ids  = obj,
                                                   num_objects = 2,
                                                   gg_id       = &group_id);
        	if (!(status&1&(*sts))) {
                	EFmsgReport ( 0, status, "gr$create_graphic_group()");
                	EFmsgReport ( 0, *sts,   "gr$create_graphic_group()");
                	goto quit;
        	}
		else *sts = VL_S_SUCCESS;
	}
}
/******************************************************************************/
