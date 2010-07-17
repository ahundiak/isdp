/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLstfTplCmd

     ABSTRACT   : I/LOFT create templates for bended stiffeners

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLstfTplCmd.
		  This command create templates used in manufacturing of
		  stiffeners designed by I/STRUCT.


     CHANGE HISTORY : 	file created 	09-MAR-1994	Marc Fournier
			file upgraded	07-APR-1994	Marc Fournier
			file modified	06-OCT-1994	Marc Fournier
			file modified	14-OCT-1994	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_STIFFENER_TEMPLATE, 0, VLCrStTe
command_table	"vl.cmd"
class		VLstfTplCmd
super_class	VLlocateCmd
product_name	"$LOFT"
status_display	"VLstfnrTpl", "-1", "-1"

start_state	TO_STIFF

specification

#include	"vlstifftpl.h"

instance {
		IGRint		LineSelect[IDX_SC_SIZE];
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

#include	"vsdef.h"
#include	"vsRDBdef.h"
#include	"vlmsg.h"
#include	"vluserkey.h"
#include	"vlglobals.h"
#include	"vlstifftpl.h"
#include	"vlmiscmacros.h"

#define 	VL_LINEAR  101

extern	GRclassid	OPP_VLstfnrTpl_class_id;

from    NDmacro	import	ACgive_structure;

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vlstifftpl.h"
#define 	VL_LINEAR  101

/******************************************************************************/
state TO_STIFF
	message_key		VL_S_STIFFENER_TEMPLATE
	status_key		VL_S_STATUS_FORM
        execute                 VLfreeList ( &me->ret, 1)

	on ELSE							state STIFF
/******************************************************************************/
state STIFF
	prompt_key		VL_P_STIFFENER
	accept_key		VL_M_STIFFENER
	locate_eligible		"+VSfeature"
	locate_owner		"LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER |
				 LC_REF_OBJECTS"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	execute			VLbeamActionHandlerOn (&me->ret)
	filter			locate

	on EX_BACK_UP						state TO_STIFF
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_STF
/******************************************************************************/
state EVENT_STF
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)
	execute			VLstructActionHandlerOff (&me->ret)
	execute			VLcheckLinear (&me->ret)

        on RETURN_CODE = VL_LINEAR
              do status "Stiffener axis is linear : Computation failed"
	      do VLfreeList ( &me->ret, 1)
              state -
 
	on ELSE							state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
        execute                 VLcomputeStfTpl
        execute                 VLfreeList ( &me->ret, 1)

        on ELSE			do status_key VL_S_SUCCESS	state TO_STIFF
/******************************************************************************/
action wakeup {

			IGRdouble	value;

        /* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLstfTplCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Initialize form */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STH, &value),
                  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, SF_TH, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STT, &value),
                  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, SF_TT, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STE, &value),
                  targetid = my_id);
	FIg_set_value (me->status_display_form_ptr, SF_TE, value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STW, &value),
                  targetid = my_id);
	if (value != VAL_TO_WEBL)	value = VAL_TO_WEBR;
	FIg_set_state (me->status_display_form_ptr, SF_WS, (IGRint)value);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STC, &value),
                  targetid = my_id);
	VLdecode ( (IGRint)value, IDX_SC_SIZE, me->LineSelect);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_BUTT, 0,
			 NAM_SC_BUTT, me->LineSelect[IDX_SC_BUTT]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_CTRL, 0,
			 NAM_SC_CTRL, me->LineSelect[IDX_SC_CTRL]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_MRKL, 0,
			 NAM_SC_MRKL, me->LineSelect[IDX_SC_MRKL]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_SEAM, 0,
			 NAM_SC_SEAM, me->LineSelect[IDX_SC_SEAM]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_WATL, 0,
			 NAM_SC_WATL, me->LineSelect[IDX_SC_WATL]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_TRAC, 0,
			 NAM_SC_TRAC, me->LineSelect[IDX_SC_TRAC]);
	FIfld_set_text ( me->status_display_form_ptr, SF_SL, IDX_SC_MACR, 0,
			 NAM_SC_MACR, me->LineSelect[IDX_SC_MACR]);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action form_notification {

		IGRlong		i, sts;
		IGRint		suc, state, code;
		IGRdouble	value;

	status = OM_S_SUCCESS;

	switch (gadget_label) {

		case FI_ACCEPT:

			FIg_get_value(form_ptr, SF_TH, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &me->ret, NAM_G_STH, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, SF_TT, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &me->ret, NAM_G_STT, value),
                                  targetid = my_id);

			FIg_get_value(form_ptr, SF_TE, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &me->ret, NAM_G_STE, value),
                                  targetid = my_id);

			FIg_get_state(form_ptr, SF_WS, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_STW, (IGRdouble)state),
                                  targetid = my_id);

			for ( i=0; i<IDX_SC_SIZE; i++)
				FIfld_get_select ( form_ptr, SF_SL, i, 0,
						   &me->LineSelect[i] );
			VLencode ( me->LineSelect, IDX_SC_SIZE, &code);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_STC, (IGRdouble)code),
                                  targetid = my_id);

		case FI_CANCEL:

			om$send ( msg = message CEO.erase_form_by_label
                                        ( STATUS_FORM, 0, &suc),
                                  targetid = my_id);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_STH, &value),
                                  targetid = my_id);
			FIg_set_value(form_ptr, SF_TH, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_STT, &value),
                                  targetid = my_id);
			FIg_set_value(form_ptr, SF_TT, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_STE, &value),
                                  targetid = my_id);
			FIg_set_value(form_ptr, SF_TE, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_STW, &value),
                                  targetid = my_id);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_STC, &value),
                                  targetid = my_id);
			VLdecode ( (IGRint)value, IDX_SC_SIZE, me->LineSelect);
			for ( i=0; i<IDX_SC_SIZE; i++)
				FIfld_set_select ( form_ptr, SF_SL, i, 0,
						   me->LineSelect[i]);

			goto quit;

		case SF_TH:
		case SF_TT:
		case SF_TE:
		case SF_WS:
		case SF_SL:
		default:
			goto quit;
	}
}
/******************************************************************************/
action VLcomputeStfTpl {

		IGRint		i;
	struct	GRid		template[MACRO_S_FTEMP+MACRO_S_VTEMP];
		IGRdouble	value;

	/* Initialize templates' array */
	for ( i=0; i<(MACRO_S_FTEMP+MACRO_S_VTEMP); i++) {
		template[i].objid = NULL_OBJID;
		template[i].osnum = me->Current.md_id.osnum; }

	/* Create <tpl_height> expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_STH, &value),
			   targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(STH)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_THEI].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_THEI].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create <tpl_thickness> expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_STT, &value),
			   targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(STT)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_TTHI].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_TTHI].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create <extension1> & <extension2> expressions */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_STE, &value),
			   targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(STE)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_EXT1].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_EXT1].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_EXT2].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_EXT2].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create <web_left> expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_STW, &value),
			   targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(STW)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_WLEF].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_WLEF].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Create <tpl_code> expression */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_STC, &value),
			   targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(STC)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
	exp$create ( exp_value = value,
		     p_exp_id  = &template[IDX_ST_CODE].objid,
		     osnum     = me->Current.md_id.osnum,
		     p_osnum   = &template[IDX_ST_CODE].osnum );
	if (status != EXP_S_SUCCESS)	goto quit;

	/* Loop on Stiffeners */
	for ( i=0; i<me->Cnt1; i++) {

		IGRint	linear=0;
	        status = VLcheckLinearity( &me->Lst1[i], &me->Lst1[i].mod_env, 
								&linear );
	        as$status (sts=status);

	        if( linear ) continue;

		/* Make source on <VSstfBeam> stiffener */
		as$make_source ( go_grid = me->Lst1[i].obj_id,
				 mod_env = &me->Lst1[i].mod_env,
				 as_os   = me->Current.md_id.osnum,
				 as_grid = &template[IDX_ST_STIF] );

		/* Construct, place, name & change state of VLstfnrTpl macro */
                status =
		vl$placeLoftMacro ( msg        = sts,
                                    classid    = OPP_VLstfnrTpl_class_id,
                                    MacName    = MACRO_STFTPL,
                                    number     = MACRO_S_FTEMP,
                                    template   = template,
                                    Env        = &me->Current,
                                    MatchKey   = STIFF_TPL_KEY,
                                    CobName    = "VLstfTplCmd",
                                    mode       = OM_e_wrt_parent,
                                    MatchId    = &template[IDX_ST_STIF],
                                    CommonName = STFTPL_NAME,
                                    CobMyId    = my_id );
                as$status ( msg    = "vl$placeLoftMacro(VLstfnrTpl)",
                            test   = (!(status & 0x00000001 & (*sts))),
                            action = GOTO_VALUE,
                            value  = quit );
	}
}

action VLcheckLinear {

        IGRint                  suc,sts,i,linear=0;
        struct  ret_struct      attrVal;
        char                    attrName[40];

        strcpy( attrName, VS_K_prMbrGeoAttr );

	for(i=0; i<me->Cnt1; i++) {
          sts = om$send( msg = message NDmacro.ACgive_structure (
                                                        &suc,
                                                        NULL,
                                                        attrName,
                                                        &attrVal,
                                                        &me->Current     ),
                        senderid = NULL_OBJID,
                        targetid = me->Lst1[i].obj_id.objid,
                        targetos = me->Lst1[i].obj_id.osnum  );
          as$status ( msg    = "NDmacro.ACgive_structure",
                    test   = (!(sts & 1 & suc)),
                    action = GOTO_VALUE,
                    value  = quit );

          if( attrVal.var.root_pm_st.value == VS_rdb_bmLINEAR )
          {
             linear = 1;
	     if   (me->Cnt1 == 1) 
		  me->ret = VL_LINEAR;	
	     else {
                gr$display_object ( object_id = &me->Lst1[i].obj_id,
                                    md_env    = &me->Current,
                                    mode      = GRhd );

        	ex$message(     
        		field           = ERROR_FIELD,
        		justification   = CENTER_JUS,
        		in_buff         = 
			     "Stiffener axis is linear : Stiffener ignored" );
	     }
    	  }
         } /* for(i=0; i<me->Cnt1; i++) */

}

/******************************************************************************/
