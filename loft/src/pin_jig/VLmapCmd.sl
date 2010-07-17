/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLmapCmd

     ABSTRACT   : I/LOFT defines layout points command

     ON ENTRY   :

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES      : This command object defines the classe VLmapCmd.


     CHANGE HISTORY : 	file created	18-OCT-1993     Marc Fournier
			file upgrade	14-APR-1994	Marc Fournier
			file modified	04-OCT-1994	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string  VLC_M_PIN_JIG_LAYOUT, 0, VLDePjLa
command_table   "vl.cmd"
class           VLmapCmd
super_class     VLlocateCmd
product_name    "$LOFT"
status_display	"VLlayout", "-1", "-1"

start_state	TO_BALANCE

specification

instance {
                        IGRdouble       Xpitch;
                        IGRdouble       Ypitch;
                        IGRdouble       Margin;
}

implementation

#include        <stdio.h>
#include        "vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "nddef.h"
#include        "dpmacros.h"
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
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "ACdyn_col.h"

#include        "vlglobals.h"
#include        "vluserkey.h"
#include        "vlmsg.h"
#include        "vllayout.h"
#include        "vlmiscmacros.h"

from	ACdyn_col	import	ACset_att_prop, ACset_list_attribute;

extern  GRclassid       OPP_ACdyn_col_class_id;
extern  GRclassid       OPP_VLlayout_class_id;

/******************************************************************************/
state_table

#include        "vlmsg.h"

/******************************************************************************/
state TO_BALANCE
        message_key             VL_S_PIN_JIG_LAYOUT
	status_key		VL_S_STATUS_FORM
	execute			VLfreeList ( &me->ret, 1)

	on ELSE							state BALANCE
/******************************************************************************/
state BALANCE
	prompt_key		VL_P_BALANCE_OBJECTS
	accept_key		VL_M_BALANCE_OBJECTS
	locate_class		"VLbalance"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state TO_BALANCE
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_BAL
/******************************************************************************/
state EVENT_BAL
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
	execute			VLfreeList ( &me->ret, 1)
	execute			VLstoreList ( &me->ret, 0, 1)

	on ELSE							state LAYOUT
/******************************************************************************/
state LAYOUT
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLlayoutCompute (&me->ret)
	on ELSE							state TO_BALANCE
/******************************************************************************/
action init {

	me->ret = om$send ( msg      = message VLmapCmd.init (type, str_ptr),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status ( sts = me->ret );

	/* Initialize instances */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_XPI, &me->Xpitch),
		  targetid = my_id );

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_YPI, &me->Ypitch),
		  targetid = my_id );

	om$send ( msg = message VLlocateCmd.VLgetGlobals
					( &me->ret, NAM_G_MRG, &me->Margin),
		  targetid = my_id );

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action wakeup {

	/* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLmapCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	FIg_set_value ( me->status_display_form_ptr, PL_XPI, me->Xpitch);
	FIg_set_value ( me->status_display_form_ptr, PL_YPI, me->Ypitch);
	FIg_set_value ( me->status_display_form_ptr, PL_MRG, me->Margin);

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

                IGRint          suc;
                IGRlong         sts;
		IGRdouble	value;

        switch (gadget_label) {

                case FI_ACCEPT:
			FIg_get_value ( form_ptr, PL_XPI, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_XPI, value),
                                  targetid = my_id);

			FIg_get_value ( form_ptr, PL_YPI, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_YPI, value),
                                  targetid = my_id);

			FIg_get_value ( form_ptr, PL_MRG, &value);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                ( &sts, NAM_G_MRG, value),
                                  targetid = my_id);

                case FI_CANCEL:
                        status = om$send ( msg = message CEO.erase_form_by_label
                                                        ( STATUS_FORM, 0, &suc),
                                           targetid = my_id );

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_XPI, &me->Xpitch),
                                  targetid = my_id);
			FIg_set_value ( form_ptr, PL_XPI, me->Xpitch);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_YPI, &me->Ypitch),
                                  targetid = my_id);
			FIg_set_value ( form_ptr, PL_YPI, me->Ypitch);

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( &sts, NAM_G_MRG, &me->Margin),
                                  targetid = my_id);
			FIg_set_value ( form_ptr, PL_MRG, me->Margin);

                case PL_XPI:
                case PL_YPI:
                case PL_MRG:
                default:
                        goto quit;
        }
}
/******************************************************************************/
action VLlayoutCompute {

		IGRint		i;
	struct	GRid		Tlist[MACRO_L_FTEMP];
	struct	ACrg_coll	attr[IDX_LB_FIXE1];

	/* Initialize */
	for ( i=0; i<MACRO_L_FTEMP; i++) {
		Tlist[i].objid = NULL_OBJID;
		Tlist[i].osnum = me->Current.md_id.osnum;
	}

	/* Build parameter box */
	strcpy ( attr[IDX_LB_XPI].name, NAM_LB_XPI);
	strcpy ( attr[IDX_LB_YPI].name, NAM_LB_YPI);
	strcpy ( attr[IDX_LB_MRG].name, NAM_LB_MRG);
	strcpy ( attr[IDX_LB_COL].name, NAM_LB_COL);
	strcpy ( attr[IDX_LB_LIN].name, NAM_LB_LIN);
	strcpy ( attr[IDX_LB_UNI].name, NAM_LB_UNI);

	attr[IDX_LB_XPI].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_LB_YPI].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_LB_MRG].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_LB_COL].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_LB_LIN].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_LB_UNI].desc.type = AC_ATTRIB_DOUBLE;

	attr[IDX_LB_XPI].desc.value.att_exp = me->Xpitch;
	attr[IDX_LB_YPI].desc.value.att_exp = me->Ypitch;
	attr[IDX_LB_MRG].desc.value.att_exp = me->Margin;
	attr[IDX_LB_COL].desc.value.att_exp = 0.0;
	attr[IDX_LB_LIN].desc.value.att_exp = 0.0;
	attr[IDX_LB_UNI].desc.value.att_exp = 1.0;

	/* Create parameter box */
	om$construct ( classid = OPP_ACdyn_col_class_id,
		       osnum   = Tlist[IDX_LT_GRID].osnum,
		       p_objid = &Tlist[IDX_LT_GRID].objid );

	/* Set parameter box */
        status = om$send ( msg = message ACdyn_col.ACset_list_attribute
                                                ( sts, IDX_LB_FIXE1, attr),
                           targetid = Tlist[IDX_LT_GRID].objid,
                           targetos = Tlist[IDX_LT_GRID].osnum );
        as$status ( msg    = "ACdyn_col.ACset_list_attribute",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );

	/* Set internal properties */
        status = om$send ( msg = message ACdyn_col.ACset_att_prop (
							sts,
							NAM_LB_COL,
							AC_ATTRIB_PRIVATE,
							0 ),
                           targetid = Tlist[IDX_LT_GRID].objid,
                           targetos = Tlist[IDX_LT_GRID].osnum );
        as$status ( msg    = "ACdyn_col.ACset_att_prop(COL)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );
        status = om$send ( msg = message ACdyn_col.ACset_att_prop (
							sts,
							NAM_LB_LIN,
							AC_ATTRIB_PRIVATE,
							0 ),
                           targetid = Tlist[IDX_LT_GRID].objid,
                           targetos = Tlist[IDX_LT_GRID].osnum );
        as$status ( msg    = "ACdyn_col.ACset_att_prop(LIN)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );
        status = om$send ( msg = message ACdyn_col.ACset_att_prop (
							sts,
							NAM_LB_UNI,
							AC_ATTRIB_PRIVATE,
							0 ),
                           targetid = Tlist[IDX_LT_GRID].objid,
                           targetos = Tlist[IDX_LT_GRID].osnum );
        as$status ( msg    = "ACdyn_col.ACset_att_prop(UNI)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );

	/* Make source on <VLbalance> macro */
	for ( i=0; i<me->Cnt1; i++) {
		as$make_source ( go_grid = me->Lst1[i].obj_id,
			 	 mod_env = &me->Lst1[i].mod_env,
			 	 as_os   = me->Current.md_id.osnum,
			 	 as_grid = &Tlist[IDX_LT_MACR] );

		/* Construct, place, name & change state of the layout macro */
	        status = vl$placeLoftMacro ( msg        = sts,
	                                     classid    = OPP_VLlayout_class_id,
	                                     MacName    = MACRO_LAYOUT,
	                                     number     = MACRO_L_FTEMP,
	                                     template   = Tlist,
	                                     Env        = &me->Current,
	                                     MatchKey   = LAYOUT_KEY,
	                                     CobName    = "VLmapCmd",
	                                     mode       = OM_e_wrt_parent,
	                                     MatchId    = &Tlist[IDX_LT_MACR],
	                                     CommonName = LAYOUT_NAME,
	                                     CobMyId    = my_id );
	        as$status ( msg    = "vl$placeLoftMacro(VLlayout)",
	                    test   = (!(status & 0x00000001 & (*sts))),
	                    action = GOTO_VALUE,
	                    value  = quit );
	}
}
/******************************************************************************/
