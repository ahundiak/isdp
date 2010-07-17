/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLtpl2dCmd

     ABSTRACT   : I/LOFT create directly 2D templates

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLtpl2dCmd.
		  This command create templates used in manufacturing of plates
		  designed by I/STRUCT.


     CHANGE HISTORY : file created 	22-NOV-1992	Marc Fournier
		      file modified	26-NOV-1992	Marc Fournier
		      file modified     01-DEC-1992     Marc Fournier
		      file modified     08-DEC-1992     Marc Fournier
		      file modified     13-JAN-1993     Marc Fournier
		      file modified     17-MAR-1993     Marc Fournier
		      file modified     09-JUN-1993     Marc Fournier
		      file modified     17-JUN-1993     Marc Fournier
		      file modified     29-JUL-1993     Marc Fournier
		      file modified     17-AUG-1993     Marc Fournier
		      file upgraded     14-APR-1994     Marc Fournier
		      file modified     05-OCT-1994     Marc Fournier
		      file modified     01-JUN-1995     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_2D_TEMPLATE, 0, VLCr2dTe
command_table	"vl.cmd"
class		VLtpl2dCmd
super_class	VLlocateCmd
product_name	"$LOFT"
status_display	"VLtemplate", "-1", "-1"

start_state	TO_PLATE

specification

instance {
			IGRdouble	ShipAxis[3];
	struct		GRobj_env	SpineRef;
}

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "cotxmacros.h"
#include        "nddef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grmacros.h"
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
#include	"ACattrib.h"

#include	"vsplatedef.h"
#include	"vsmiscmacros.h"

#include	"vlmsg.h"
#include	"vluserkey.h"
#include	"vlglobals.h"
#include	"vltemplate.h"
#include	"vlmiscmacros.h"

from	ACrg_collect	import	ACcreate, ACset_list_attribute;
from	GRowner		import	GRget_components, GRget_number_components;
from	expression	import	NDgive_value;

extern	GRclassid	OPP_ACrg_collect_class_id;
extern	GRclassid	OPP_VLtplMgr_class_id;

extern	void		COB_FI_form_notification();

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state TO_PLATE
	message_key		VL_S_2D_TEMPLATE
	status_key		VL_S_STATUS_FORM
        execute                 VLfreeList ( &me->ret, 1)

	on ELSE							state PLATE
/******************************************************************************/
state PLATE
	prompt_key		VL_P_PLATE
	accept_key		VL_M_PLATE
	locate_eligible		"+VSplate"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state TO_PLATE
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_PLT
/******************************************************************************/
state EVENT_PLT
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)

	on ELSE							state TO_PLANE
/******************************************************************************/
state TO_PLANE
	status			" "
        execute                 VLfreeList ( &me->ret, 2)

	on ELSE							state PLANE
/******************************************************************************/
state PLANE
	prompt_key		VL_P_PLANE
	accept_key		VL_M_PLANE
	locate_eligible		"+EMSsurface"
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
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 2)
        execute                 VLstoreList ( &me->ret, 0, 2)
	execute			VLisSurfacePlanarAHof (&me->ret)

	on ELSE							state RIB_CS
/******************************************************************************/
state RIB_CS
        status			" "
        prompt_key              VL_P_TPL_COOR_SYS
        accept_key              VL_M_TPL_COOR_SYS
        locate_eligible         "+GRgencs"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state TO_PLANE
        on EX_DATA or EX_OBJID  do VLstoreLocate (&me->ret)
                                do VLstoreResponse (&me->ret)
                                do VLstoreCoorSyst (&me->ret) state SPI_CS
/******************************************************************************/
state SPI_CS
        status			" "
        prompt_key              VL_P_SPI_COOR_SYS
        accept_key              VL_M_SPI_COOR_SYS
        locate_eligible         "+GRgencs"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state RIB_CS
        on EX_DATA or EX_OBJID  do VLstoreLocate (&me->ret)
                                do VLstoreResponse (&me->ret)
                                do VLstoreSpiCsys (&me->ret) state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
        execute                 VLcomputeTemplate ( &me->ret, PROJECT_ON)
				on RETURN_CODE = VL_S_SUCCESS
                                        do VLfreeList ( &me->ret, 2)
                                        do VLfreeList ( &me->ret, 1)
                                        do status_key VL_S_SUCCESS
								state TO_PLATE
				on ELSE
                                        do VLfreeList ( &me->ret, 2)
                                        do VLfreeList ( &me->ret, 1)
                                        do status_key VL_E_FAILURE
								state TO_PLATE
/******************************************************************************/
action init {

	/* Execute method init of upper class */
	me->ret = om$send ( msg      = message VLtpl2dCmd.init( type, str_ptr),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status(sts = me->ret);

	/* Initialize instances */
	me->ShipAxis[0] = 1.0;
	me->ShipAxis[1] = 0.0;
	me->ShipAxis[2] = 0.0;

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action wakeup {

		IGRdouble	value, xlo, ylo;
		IGRlong		size=sizeof(struct GRdpb_text_symb);
		IGRlong		nret;
	struct	GRdpb_text_symb	text_symb;

        /* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLtpl2dCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Get active size */
	gr$get_text_symb ( msg    = &me->ret,
			   sizbuf = &size,
			   buffer = &text_symb,
			   nret   = &nret );
	if (text_symb.Active_width > text_symb.Active_height)
		me->ActiveTextSize = text_symb.Active_width;
	else	me->ActiveTextSize = text_symb.Active_height;

	/* Initialize forms */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_XTS, &xlo),
                  targetid = my_id);
        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_YTS, &ylo),
                  targetid = my_id);

	xlo = 2.0;	ylo = 495.0;

        FIf_set_location ( me->status_display_form_ptr,
                           (IGRint)xlo, (IGRint)ylo);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_MID, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_XM, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_TGG, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_MD, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_EXT, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_EX, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PGH, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_PH, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PGW, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_PW, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PGS, &value),
                  targetid = my_id);
        FIg_set_value (me->status_display_form_ptr, TF_PS, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_TSZ, &value),
                  targetid = my_id);
	if (value <= 0.0)	value = me->ActiveTextSize;
        FIg_set_value (me->status_display_form_ptr, TF_SZ, value);

        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_SPI, &value),
                  targetid = my_id);
	FIg_set_state (me->status_display_form_ptr, TF_BX, (IGRint)value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_FUL, &value),
                  targetid = my_id);
/* aborted development for ACH
	FIg_set_state (me->status_display_form_ptr, TF_FH, (IGRint)value);
*/

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_PTN, &value),
                  targetid = my_id);
	FIg_set_state (me->status_display_form_ptr, TF_IN, (IGRint)value);

	FIfld_set_list_text(me->status_display_form_ptr,TF_AX,0,0,X_AXIS,TRUE);
	FIfld_set_list_text(me->status_display_form_ptr,TF_AX,1,0,Y_AXIS,TRUE);
	FIfld_set_list_text(me->status_display_form_ptr,TF_AX,2,0,Z_AXIS,TRUE);
	FIg_set_text       (me->status_display_form_ptr,TF_AX,X_AXIS);
	FIg_set_text    (me->status_display_form_ptr,TF_TIT,"Create Templates");

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action sleep {

                IGRint  xlo, ylo;

        /* Execute method sleep of upper class */
        me->ret = om$send ( msg      = message VLtpl2dCmd.sleep (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Store form location */
        FIf_get_location ( me->status_display_form_ptr, &xlo, &ylo);
        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                ( &me->ret, NAM_G_XTS, (IGRdouble)xlo),
                  targetid = my_id);
        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                ( &me->ret, NAM_G_YTS, (IGRdouble)ylo),
                  targetid = my_id);

        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

		IGRlong		sts;
		IGRint		suc, state;
		IGRchar		axis[10];
		IGRdouble	value;
		IGRint		xlo, ylo;

	status = OM_S_SUCCESS;

	FIf_get_location ( form_ptr, &xlo, &ylo);
	om$send ( msg = message VLlocateCmd.VLmodGlobals
				( &me->ret, NAM_G_XTS, (IGRdouble)xlo),
	  	  targetid = my_id);
	om$send ( msg = message VLlocateCmd.VLmodGlobals
				( &me->ret, NAM_G_YTS, (IGRdouble)ylo),
		  targetid = my_id);

	switch (gadget_label) {

		case FI_ACCEPT:

			FIg_get_value(form_ptr, TF_MD, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_TGG, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_EX, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_EXT, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_PH, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_PGH, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_PW, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_PGW, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_PS, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_PGS, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_XM, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_MID, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, TF_SZ, &value);
			if (value != me->ActiveTextSize)
				om$send (
				msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_TSZ, value),
                                targetid = my_id);

			FIg_get_text (form_ptr, TF_AX, axis);

			if      (!strcmp( axis, X_AXIS)) {
				me->ShipAxis[0] = 1.0;
				me->ShipAxis[1] = 0.0;
				me->ShipAxis[2] = 0.0;
			}
			else if (!strcmp( axis, Y_AXIS)) {
				me->ShipAxis[0] = 0.0;
				me->ShipAxis[1] = 1.0;
				me->ShipAxis[2] = 0.0;
			}
			else				 {
				me->ShipAxis[0] = 0.0;
				me->ShipAxis[1] = 0.0;
				me->ShipAxis[2] = 1.0;
			}

			FIg_get_state(form_ptr, TF_BX, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_SPI, (IGRdouble)state),
                                  targetid = my_id);

/* aborted development for ACH
			FIg_get_state(form_ptr, TF_FH, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_FUL, (IGRdouble)state),
                                  targetid = my_id);
*/

			FIg_get_state(form_ptr, TF_IN, &state);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_PTN, (IGRdouble)state),
                                  targetid = my_id);

		case FI_CANCEL:

			om$send ( msg      = message CEO.erase_form_by_label
							( STATUS_FORM, 0, &suc),
                                  targetid = my_id);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_TGG, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_MD, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_EXT, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_EX, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PGH, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_PH, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PGW, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_PW, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PGS, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_PS, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_MID, &value),
                                  targetid = my_id);
                        FIg_set_value(form_ptr, TF_XM, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_TSZ, &value),
                                  targetid = my_id);
			if (value <= 0.0)	value = me->ActiveTextSize;
                        FIg_set_value(form_ptr, TF_SZ, value);

			if      (me->ShipAxis[0] == 1.0)
				FIg_get_text (form_ptr, TF_AX, X_AXIS);
			else if (me->ShipAxis[1] == 1.0)
				FIg_get_text (form_ptr, TF_AX, Y_AXIS);
			else 	FIg_get_text (form_ptr, TF_AX, Z_AXIS);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_SPI, &value),
                                  targetid = my_id);
			FIg_set_state(form_ptr, TF_BX, (IGRint)value);

/* aborted development for ACH
			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_FUL, &value),
                                  targetid = my_id);
			FIg_set_state(form_ptr, TF_FH, (IGRint)value);
*/
			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_PTN, &value),
                                  targetid = my_id);
			FIg_set_state(form_ptr, TF_IN, (IGRint)value);

                        goto quit;

/* aborted development for ACH
		case TF_FH:
*/
		case TF_MD:
		case TF_AX:
		case TF_BX:
		case TF_EX:
		case TF_PH:
		case TF_PW:
		case TF_PS:
		case TF_XM:
		case TF_IN:
		default:
			goto quit;
	}
}
/******************************************************************************/
action VLstoreSpiCsys {

        me->SpineRef = me->Loc_env;
        *sts = OM_S_SUCCESS;

        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action VLcomputeTemplate ( IGRlong * sts; IGRint flag ) {

	struct	GRid		template[MACRO_TM_FTEMP+MACRO_TM_VTEMP];
		IGRint		i, spine_flag, count;
		IGRdouble	midship, shipaxis, value, page_h, page_w;
		IGRdouble	Bp_num=0.0,Bw_max=0.0,Bx_rng=0.0,By_rng=0.0;
		IGRdouble	Rp_num=0.0,Rw_max=0.0,Rx_rng=0.0,Ry_rng=0.0;
	struct	ACrg_coll	attr[NUM_TM_ATTR];
	struct	GRid		occ_id, dummy;

	/* Initialize templates' array */
	for ( i=0; i<(MACRO_TM_FTEMP+MACRO_TM_VTEMP); i++) {
		template[i].objid = NULL_OBJID;
		template[i].osnum = me->Current.md_id.osnum; }
	count = MACRO_TM_FTEMP;

	/* Create parameter box : names */
	strcpy ( attr[IDX_TM_GRD].name,  NAM_TM_GRD );
	strcpy ( attr[IDX_TM_EXT1].name, NAM_TM_EXT1);
	strcpy ( attr[IDX_TM_EXT2].name, NAM_TM_EXT2);
	strcpy ( attr[IDX_TM_INV].name,  NAM_TM_INV );
	strcpy ( attr[IDX_TM_SPIN].name, NAM_TM_SPIN);
	strcpy ( attr[IDX_TM_SCAL].name, NAM_TM_SCAL);
	strcpy ( attr[IDX_TM_MID].name,  NAM_TM_MID );
	strcpy ( attr[IDX_TM_AXIS].name, NAM_TM_AXIS);
	strcpy ( attr[IDX_TM_PGH].name,  NAM_TM_PGH );
	strcpy ( attr[IDX_TM_PGW].name,  NAM_TM_PGW );
	strcpy ( attr[IDX_TM_RPNI].name, NAM_TM_RPNI);
	strcpy ( attr[IDX_TM_RWMI].name, NAM_TM_RWMI);
	strcpy ( attr[IDX_TM_RXRI].name, NAM_TM_RXRI);
	strcpy ( attr[IDX_TM_RYRI].name, NAM_TM_RYRI);
	strcpy ( attr[IDX_TM_BPNI].name, NAM_TM_BPNI);
	strcpy ( attr[IDX_TM_BWMI].name, NAM_TM_BWMI);
	strcpy ( attr[IDX_TM_BXRI].name, NAM_TM_BXRI);
	strcpy ( attr[IDX_TM_BYRI].name, NAM_TM_BYRI);
	strcpy ( attr[IDX_TM_FULL].name, NAM_TM_FULL);
	strcpy ( attr[IDX_TM_HLEN].name, NAM_TM_HLEN);
	strcpy ( attr[IDX_TM_HRAD].name, NAM_TM_HRAD);
	strcpy ( attr[IDX_TM_HWID].name, NAM_TM_HWID);
	strcpy ( attr[IDX_TM_TXSZ].name, NAM_TM_TXSZ);

	/* Create parameter box : types */
	for ( i=0; i<NUM_TM_ATTR; i++)  attr[i].desc.type = AC_ATTRIB_DOUBLE;

	/* Create parameter box : values */
	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_TGG, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_GRD].desc.value.att_exp  = value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_EXT, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_EXT1].desc.value.att_exp = value;
	attr[IDX_TM_EXT2].desc.value.att_exp = value;


	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PTN, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (!(IGRint)value)
		attr[IDX_TM_INV].desc.value.att_exp  = (IGRdouble) INVNORM_OF;
	else	attr[IDX_TM_INV].desc.value.att_exp  = (IGRdouble) INVNORM_ON;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_SPI, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_SPIN].desc.value.att_exp = value;
	spine_flag = (IGRint)value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_FUL, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_FULL].desc.value.att_exp = value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_HLE, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_HLEN].desc.value.att_exp = value;
#ifdef TRACE
printf( "value [%g] from global <%s> into <%s>\n",
	value, NAM_G_HLE, NAM_TM_HLEN);
#endif
	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_HRA, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_HRAD].desc.value.att_exp = value;
#ifdef TRACE
printf( "value [%g] from global <%s> into <%s>\n",
	value, NAM_G_HRA, NAM_TM_HRAD);
#endif
	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_HWI, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_HWID].desc.value.att_exp = value;
#ifdef TRACE
printf( "value [%g] from global <%s> into <%s>\n",
	value, NAM_G_HWI, NAM_TM_HWID);
#endif
	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGS, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_SCAL].desc.value.att_exp = value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_MID, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if      (me->ShipAxis[1] == 1.0) { midship  = Y_MID_SHIP;
					   shipaxis = IDX_AX2; }
	else if (me->ShipAxis[2] == 1.0) { midship  = Z_MID_SHIP;
					   shipaxis = IDX_AX3; }
	else				 { midship  = value;
					   shipaxis = IDX_AX1; }
	attr[IDX_TM_MID].desc.value.att_exp  = midship;
	attr[IDX_TM_AXIS].desc.value.att_exp = shipaxis;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGH, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_PGH].desc.value.att_exp = value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGW, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_PGW].desc.value.att_exp = value;

	status = om$send ( msg      = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_TSZ, &value),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	attr[IDX_TM_TXSZ].desc.value.att_exp = value;

	/* Set coordinate system template */
	if (flag == PROJECT_ON) {

		status = om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGH, &page_h),
                                   targetid = my_id);
                as$status ( msg    = "VLlocateCmd.VLgetGlobals(PGH)",
                            test   = (!(status & 0x00000001 & (*sts))),
                            action = GOTO_VALUE,
                            value  = wrapup );
                status = om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGW, &page_w),
                                   targetid = my_id);
                as$status ( msg    = "VLlocateCmd.VLgetGlobals(PGW)",
                            test   = (!(status & 0x00000001 & (*sts))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                as$make_source ( go_grid = me->GrdCsys.obj_id,
                                 mod_env = &me->GrdCsys.mod_env,
                                 as_os   = me->Current.md_id.osnum,
                                 as_grid = &template[IDX_TM_R_CS] );

                if (spine_flag) {
                        as$make_source ( go_grid = me->SpineRef.obj_id,
                                         mod_env = &me->SpineRef.mod_env,
                                         as_os   = me->Current.md_id.osnum,
                                         as_grid = &template[IDX_TM_B_CS] );
                }
                else {	status =
                        exp$create ( exp_syntax = "spi_cs",
                                     p_exp_id   = &template[IDX_TM_B_CS].objid,
                                     osnum      = me->Current.md_id.osnum,
                                     p_osnum    = &template[IDX_TM_B_CS].osnum,
                                     type_rq    = EXP_TEXT);
                        if (status != EXP_S_SUCCESS) goto quit;
                }
	}
	else {	status = exp$create ( exp_syntax = "tpl_cs",
			      	      p_exp_id   = &template[IDX_TM_R_CS].objid,
			      	      osnum      = me->Current.md_id.osnum,
			      	      p_osnum    = &template[IDX_TM_R_CS].osnum,
			      	      type_rq    = EXP_TEXT);
		if (status != EXP_S_SUCCESS) goto quit;

		status = exp$create ( exp_syntax = "spi_cs",
			      	      p_exp_id   = &template[IDX_TM_B_CS].objid,
			      	      osnum      = me->Current.md_id.osnum,
			      	      p_osnum    = &template[IDX_TM_B_CS].osnum,
			      	      type_rq    = EXP_TEXT);
		if (status != EXP_S_SUCCESS) goto quit;
	}

	/* Make source on Planes */
	for ( i=0; i<me->Cnt2; i++)
		as$make_source ( go_grid = me->Lst2[i].obj_id,
			 	 mod_env = &me->Lst2[i].mod_env,
		 	 	 as_os   = me->Current.md_id.osnum,
			 	 as_grid = &template[MACRO_TM_FTEMP+i]);
	count += me->Cnt2;

	/* Loop on Plates */
	for ( i=0; i<me->Cnt1; i++) {


        	/* Add Roll Line (to maintain assoc) */
		dummy.objid = NULL_OBJID;
		status = VDchk_child_on_class ( sts,
               	                                &me->Lst1[i].obj_id,
                                                &me->Lst1[i].obj_id,
                                                "VLrolLine",
                                                &dummy );
        	if (dummy.objid != NULL_OBJID) {
			as$make_source ( go_grid = dummy,
				 	 mod_env = &me->Lst1[i].mod_env,
			 	 	 as_os   = me->Current.md_id.osnum,
				 	 as_grid = &template[count] );
			count++;
		}

		/* Make source on Struct plate */
		as$make_source ( go_grid = me->Lst1[i].obj_id,
				 mod_env = &me->Lst1[i].mod_env,
			 	 as_os   = me->Current.md_id.osnum,
				 as_grid = &template[IDX_TM_PLAT] );

		/* The last template-manager must generate a template-box */
                if (i == (me->Cnt1-1))
                        attr[IDX_TM_FULL].desc.value.att_exp = -1.0;
                else    attr[IDX_TM_FULL].desc.value.att_exp =  1.0;

		attr[IDX_TM_RPNI].desc.value.att_exp = Rp_num;
		attr[IDX_TM_RWMI].desc.value.att_exp = Rw_max;
		attr[IDX_TM_RXRI].desc.value.att_exp = Rx_rng;
		attr[IDX_TM_RYRI].desc.value.att_exp = Ry_rng;
		attr[IDX_TM_BPNI].desc.value.att_exp = Bp_num;
		attr[IDX_TM_BWMI].desc.value.att_exp = Bw_max;
		attr[IDX_TM_BXRI].desc.value.att_exp = Bx_rng;
		attr[IDX_TM_BYRI].desc.value.att_exp = By_rng;

		/* Create parameter box : construct */
		om$construct ( classid = OPP_ACrg_collect_class_id,
		       	       osnum   = template[IDX_TM_ATTR].osnum,
		       	       p_objid = &template[IDX_TM_ATTR].objid );

		/* Create parameter box : setting */
		status =
		om$send ( msg = message ACrg_collect.ACset_list_attribute
						( sts, NUM_TM_ATTR, attr),
			  targetid = template[IDX_TM_ATTR].objid,
			  targetos = template[IDX_TM_ATTR].osnum );
		as$status ( msg    = "ACrg_collect.ACset_list_attribute",
                    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Place the "template_mgr" macro */
		status =
		vl$placeLoftMacro ( msg        = sts,
	                            classid    = OPP_VLtplMgr_class_id,
	                            MacName    = MACRO_TM_DEF,
	                            number     = count,
	                            template   = template,
	                            Env        = &me->Current,
	                            MatchKey   = TEMPLATE_KEY,
	                            CobName    = "VLtpl2dCmd",
	                            mode       = OM_e_wrt_parent,
	                            MatchId    = &template[IDX_TM_PLAT],
	                            CommonName = MACRO_TM_NAME,
	                            CobMyId    = my_id,
				    occ_id     = &occ_id );
	        as$status ( msg    = "vl$placeLoftMacro(VLtplMgr)",
	                    test   = (!(status & 0x00000001 & (*sts))),
	                    action = GOTO_VALUE,
	                    value  = loopend );

		if (flag == PROJECT_ON) {

			/* Retrieve Page Number */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_RPNO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(RPNO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Rp_num),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(RPNO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			/* Retrieve Width Max */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_RWMO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(RWMO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Rw_max),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(RWMO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			/* Retrieve X place */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_RXRO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(RXRO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Rx_rng),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(RXRO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			/* Retrieve Y place */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_RYRO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(RYRO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Ry_rng),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(RYRO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			if (spine_flag) {

				/* Retrieve Page Number */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_BPNO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(BPNO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Bp_num),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(BPNO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

				/* Retrieve Width Max */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_BWMO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(BWMO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Bw_max),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(BWMO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

				/* Retrieve X place */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_BXRO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(BXRO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&Bx_rng),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(BXRO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

				/* Retrieve Y place */
			status = vl$return_foot ( msg    = sts,
						  name   = NAM_TM_BYRO,
						  objId  = &occ_id,
						  footId = &dummy );
			as$status ( msg    = "vl$return_foot(BYRO)",
                   	    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			status = om$send ( msg = message expression.NDgive_value
							(&By_rng),
				   	   targetid = dummy.objid,
				   	   targetos = dummy.osnum );
			as$status ( msg    = "expression.NDgive_value(BYRO)",
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );
			}
		}
loopend:
	*sts = VL_S_SUCCESS;
	}

wrapup:
	*sts = VL_S_SUCCESS;
}
/******************************************************************************/
