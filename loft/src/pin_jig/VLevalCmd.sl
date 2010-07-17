/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLevalCmd

     ABSTRACT   : I/LOFT pin_jigs evaluation

     ON ENTRY   :

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES      : This command object defines the classe VLevalCmd.


     CHANGE HISTORY : 	file created	10-NOV-1993     Marc Fournier
			file upgraded	14-APR-1994	Marc Fournier
			file modified	04-OCT-1994	Marc Fournier
			file modified	25-SEP-1995	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string  VLC_M_EVAL_PJ_POSITION, 0, VLEvPjPo
command_table   "vl.cmd"
class           VLevalCmd
super_class     VLlocateCmd
product_name    "$LOFT"
status_display	"VLevaluate", "-1", "-1"

start_state     TO_GRID

specification

instance {
		IGRint		OptIdx;
		IGRint		OptFlg[6];
		IGRint		InterPin;
		IGRdouble	Interfer;
}

implementation

#include        <stdio.h>
#include        "vlpinjig.h"
#include        "vlprototype.h"
#include        "madef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "dpmacros.h"
#include        "grmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "macro.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "FI.h"
#include        "bsvalues.h"

#include        "vsmiscmacros.h"
#include        "vlglobals.h"
#include        "vlquerydef.h"
#include        "vluserkey.h"
#include        "vlmsg.h"
#include        "vlmiscmacros.h"

#define	FORM_FIELD	100
#define	FORM_INTER	101
#define	FORM_INTFR	102
#define	FORM_TOGGLE	103
#define	FORM_SYMBOL	104

extern	GRclassid	OPP_VLpinjig_class_id;

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include        "vlmsg.h"

/******************************************************************************/
state TO_GRID
        message_key             VL_S_EVAL_PJ_POSITION
	status_key		VL_S_STATUS_FORM
	execute			VLfreeList ( &me->ret, 1)
	execute			VLdisplayForm (&me->ret)

	on ELSE							state GRID
/******************************************************************************/
state GRID
	prompt_key		VL_P_LAYOUT_OBJECTS
	accept_key		VL_M_LAYOUT_OBJECTS
	locate_class		"VLlayout"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_GRID
/******************************************************************************/
state EVENT_GRID
	status_key              VL_S_PROCESS
        prompt                  " "
        execute                 VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)

        on ELSE                                                 state EVALUATE
/******************************************************************************/
state EVALUATE
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLevalPosition (&me->ret)

	on ELSE							state TO_GRID
/******************************************************************************/
action init {

	IGRdouble	value;

	me->ret = om$send ( msg      = message VLevalCmd.init (type, str_ptr),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status ( sts = me->ret );

	/* Multi column field */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_SYO, &value),
                  targetid = my_id );
	me->OptIdx = (IGRint) value;

	/* Set processing options */
	FIfld_set_text ( me->status_display_form_ptr,
			 FORM_FIELD, 0, 0, NAM_PJO_MIP, TRUE );
	FIfld_set_text ( me->status_display_form_ptr,
			 FORM_FIELD, 1, 0, NAM_PJO_ECP, TRUE );
	FIfld_set_text ( me->status_display_form_ptr,
			 FORM_FIELD, 2, 0, NAM_PJO_CSP, TRUE );
	FIfld_set_max_num_rows ( me->status_display_form_ptr, FORM_FIELD, 3);

	/* Set pin jigs symbols */
	FIfld_set_list_text ( me->status_display_form_ptr, FORM_SYMBOL,
			      IDX_PJO_CIR, 0, NAM_PJO_CIR, TRUE );
	FIfld_set_list_text ( me->status_display_form_ptr, FORM_SYMBOL,
			      IDX_PJO_PLU, 0, NAM_PJO_PLU, TRUE );
	FIfld_set_list_text ( me->status_display_form_ptr, FORM_SYMBOL,
			      IDX_PJO_CRO, 0, NAM_PJO_CRO, TRUE );
	FIfld_set_list_text ( me->status_display_form_ptr, FORM_SYMBOL,
			      IDX_PJO_POI, 0, NAM_PJO_POI, TRUE );

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action wakeup {

	IGRdouble	value;

	me->StatusDisplay = TRUE;

        me->ret = om$send ( msg      = message VLevalCmd.wakeup (pos),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Multi column field */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_SYO, &value),
                  targetid = my_id );
	me->OptIdx = (IGRint) value;

	/* Conditional value field */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_IPJ, &value),
                  targetid = my_id );
	me->InterPin = (IGRint) value;
	FIg_set_value (  me->status_display_form_ptr, FORM_INTER, value);

	VLdecode ( me->OptIdx, 6, me->OptFlg);
	if (me->OptFlg[2])
		FIg_enable ( me->status_display_form_ptr, FORM_INTER);
	else	FIg_disable( me->status_display_form_ptr, FORM_INTER);

	/* Interference value field */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
				( &me->ret, NAM_G_PJI, &me->Interfer),
                  targetid = my_id );
	FIg_set_value (  me->status_display_form_ptr, FORM_INTFR, me->Interfer);

	/* Display height toggle */
	if	(me->OptFlg[3] == IDX_PJO_DON)
		FIg_set_state_on  ( me->status_display_form_ptr, FORM_TOGGLE );
	else if (me->OptFlg[3] == IDX_PJO_DOF)
		FIg_set_state_off ( me->status_display_form_ptr, FORM_TOGGLE );

	/* Pin jig symbol field */
	if	(me->OptFlg[4] == 1) {
		if	(me->OptFlg[5] == 1)
			FIg_set_text ( me->status_display_form_ptr,
				       FORM_SYMBOL, NAM_PJO_POI );
		else if (me->OptFlg[5] == 0)
			FIg_set_text ( me->status_display_form_ptr,
				       FORM_SYMBOL, NAM_PJO_CRO );
	}
	else if (me->OptFlg[4] == 0) {
		if	(me->OptFlg[5] == 1)
			FIg_set_text ( me->status_display_form_ptr,
				       FORM_SYMBOL, NAM_PJO_PLU );
		else if (me->OptFlg[5] == 0)
			FIg_set_text ( me->status_display_form_ptr,
				       FORM_SYMBOL, NAM_PJO_CIR );
	}

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

		IGRint		i, suc;
		IGRlong		sts;
		IGRdouble	value;
		IGRchar		text[20];

	switch (gadget_label) {

		case FI_ACCEPT:

			VLencode ( me->OptFlg, 6, &me->OptIdx);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
				  ( &sts, NAM_G_SYO, (IGRdouble) me->OptIdx),
				  targetid = my_id );

			om$send ( msg = message VLlocateCmd.VLmodGlobals
				  ( &sts, NAM_G_IPJ, (IGRdouble) me->InterPin),
				  targetid = my_id );

			om$send ( msg = message VLlocateCmd.VLmodGlobals
				  ( &sts, NAM_G_PJI, (IGRdouble) me->Interfer),
				  targetid = my_id );

                case FI_CANCEL:
	
			status = om$send ( msg = message CEO.erase_form_by_label
                                                        ( STATUS_FORM, 0, &suc),
                                           targetid = my_id );

			om$send ( msg = message VLlocateCmd.VLgetGlobals
				  ( &sts, NAM_G_SYO, &value ),
				  targetid = my_id );
			me->OptIdx = (IGRint) value;

			VLdecode ( me->OptIdx, 6, me->OptFlg);
			for ( i=0; i<3; i++)
				FIfld_set_select ( form_ptr, FORM_FIELD, i, 0,
						   me->OptFlg[i]);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
				  ( &sts, NAM_G_IPJ, &value ),
				  targetid = my_id );
			me->InterPin = (IGRint) value;
			FIg_set_value ( form_ptr, FORM_INTER, value);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
				  ( &sts, NAM_G_PJI, &me->Interfer ),
				  targetid = my_id );
			FIg_set_value ( form_ptr, FORM_INTFR, me->Interfer);

			if	(me->OptFlg[3] == IDX_PJO_DON)
				FIg_set_state_on  ( form_ptr, FORM_TOGGLE );
			else if (me->OptFlg[3] == IDX_PJO_DOF)
				FIg_set_state_off ( form_ptr, FORM_TOGGLE );

			if	(me->OptFlg[5])
				FIg_set_text ( form_ptr, FORM_SYMBOL,
					       NAM_PJO_CRO );
			else if (me->OptFlg[4])
				FIg_set_text ( form_ptr, FORM_SYMBOL,
					       NAM_PJO_PLU );
			else	FIg_set_text ( form_ptr, FORM_SYMBOL,
					       NAM_PJO_CIR );

                        goto quit;

		case FORM_FIELD:
			for ( i=0; i<3; i++) FIfld_get_select ( form_ptr,
								FORM_FIELD,
								i,
								0,
						   		&me->OptFlg[i]);

			if (me->OptFlg[2]) FIg_enable ( form_ptr, FORM_INTER);
			else		   FIg_disable( form_ptr, FORM_INTER);
                        goto quit;

		case FORM_INTER:
			FIg_get_value ( form_ptr, FORM_INTER, &value);
			me->InterPin = (IGRint) value;
                        goto quit;

		case FORM_INTFR:
			FIg_get_value ( form_ptr, FORM_INTFR, &me->Interfer);
                        goto quit;

		case FORM_TOGGLE:
			FIg_get_state ( form_ptr, FORM_TOGGLE, &me->OptFlg[3] );
			goto quit;

		case FORM_SYMBOL:
			FIg_get_text ( form_ptr, FORM_SYMBOL, text );
			if	( !strcmp ( text, NAM_PJO_CIR ) ) {
				me->OptFlg[4] = 0;
				me->OptFlg[5] = 0;
			}
			else if	( !strcmp ( text, NAM_PJO_PLU ) ) {
				me->OptFlg[4] = 1;
				me->OptFlg[5] = 0;
			}
			else if	( !strcmp ( text, NAM_PJO_CRO ) ) {
				me->OptFlg[4] = 0;
				me->OptFlg[5] = 1;
			}
			else if ( !strcmp ( text, NAM_PJO_POI ) ) {
				me->OptFlg[4] = 1;
				me->OptFlg[5] = 1;
			}
			goto quit;

                default:
                        goto quit;
        }
}
/******************************************************************************/
action VLdisplayForm {

		IGRint		i;

	/* Preselection */
	VLdecode ( me->OptIdx, 6, me->OptFlg);
	for ( i=0; i<3; i++) {
		FIfld_set_select ( me->status_display_form_ptr,
				   FORM_FIELD, i, 0, me->OptFlg[i] );
	}

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLevalPosition {

	IGRint          i;
struct  GRid            Tlist[MACRO_P_FTEMP];
        IGRint           numObjects=0;
        struct GRobj_env layout_obj, *list_obj=NULL;

	/* Initialize */
	for ( i=0; i<MACRO_P_FTEMP; i++) {
                Tlist[i].objid = NULL_OBJID;
                Tlist[i].osnum = me->Current.md_id.osnum; }
        *sts = VL_E_FAILURE;

	/* VLpinjig creation */
	for ( i=0; i<me->Cnt1; i++) {
		/* Make source <VLlayout> macro */
	        as$make_source ( go_grid = me->Lst1[i].obj_id,
	                         mod_env = &me->Lst1[i].mod_env,
	                         as_os   = me->Current.md_id.osnum,
	                         as_grid = &Tlist[IDX_PT_MACR] );

        	layout_obj.obj_id  = Tlist[IDX_PT_MACR];
        	layout_obj.mod_env = me->Current;

        	VLbrowseFctInTree( &layout_obj, VL_Q_TOP_SOURCE, NULL,
                                	VL_Q_DOWN_DIRECT,
                                	VLgetMacrosAtStep,
                                	&numObjects,
                                	&list_obj );
        	VLfilterDef(numObjects,list_obj,&numObjects,"pinjig");

        	if( numObjects )
        	{
          	    /* Pin-jigs are already placed on the layout */
          	    gr$display_object ( object_id = &me->Lst1[i].obj_id,
                              		md_env    = &me->Lst1[i].mod_env,
                              		mode      = GRhe);

          	    ex$message(   field   = ERROR_FIELD,
                        	  in_buff = "Pin Jigs are already placed on this layout" );

          	    /* Hilight the pin-jig objects */
          	    vs$bulk_display( dpmode  = GRhd,
                           	     count   = numObjects,
                           	     objenvs = list_obj );
		    if( list_obj ) 
                    {
			om$dealloc( ptr = list_obj ); 
			list_obj = NULL;
                    }
          	    continue;
        	}

		/* Create compute option expression */
		status = exp$create ( exp_value = (IGRdouble) me->OptIdx,
	                              p_exp_id  = &Tlist[IDX_PT_OPTF].objid,
	                              osnum     = me->Current.md_id.osnum,
	                              p_osnum   = &Tlist[IDX_PT_OPTF].osnum );
	        if (status != EXP_S_SUCCESS)    goto quit;

		/* Create intermediate number expression */
		status = exp$create ( exp_value = (IGRdouble) me->InterPin,
	                              p_exp_id  = &Tlist[IDX_PT_IPIN].objid,
	                              osnum     = me->Current.md_id.osnum,
	                              p_osnum   = &Tlist[IDX_PT_IPIN].osnum );
	        if (status != EXP_S_SUCCESS)    goto quit;

		/* Create interference radius expression */
		status = exp$create ( exp_value = me->Interfer,
	                              p_exp_id  = &Tlist[IDX_PT_INFR].objid,
	                              osnum     = me->Current.md_id.osnum,
	                              p_osnum   = &Tlist[IDX_PT_INFR].osnum );
	        if (status != EXP_S_SUCCESS)    goto quit;

		/* Construct, place, name & change state of "pinjig" macro */
	        status = vl$placeLoftMacro ( msg        = sts,
	                                     classid    = OPP_VLpinjig_class_id,
	                                     MacName    = MACRO_PINJIG,
	                                     number     = MACRO_P_FTEMP,
	                                     template   = Tlist,
	                                     Env        = &me->Current,
	                                     MatchKey   = PINJIG_KEY,
	                                     CobName    = "VLevalCmd",
	                                     mode       = OM_e_wrt_parent,
	                                     MatchId    = &Tlist[IDX_PT_MACR],
	                                     CommonName = PINJIG_NAME,
	                                     CobMyId    = my_id );
	        as$status ( msg    = "vl$placeLoftMacro(VLpinjig)",
	                    test   = (!(status & 0x00000001 & (*sts))),
	                    action = GOTO_VALUE,
	                    value  = quit );
	}
}
/******************************************************************************/
