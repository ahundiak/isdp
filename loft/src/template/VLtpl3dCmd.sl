/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLtpl3dCmd

     ABSTRACT   : I/LOFT create 3D templates

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLtpl3dCmd.
		  This command create 3D templates used in manufacturing on
		  plates designed by I/STRUCT.


     CHANGE HISTORY : file created 	08-DEC-1992     Marc Fournier
		      file modified	14-JAN-1993	Marc Fournier
		      file modified     17-JUN-1993     Marc Fournier
		      file upgraded     14-APR-1994     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_3D_TEMPLATE, 0, VLCr3dTe
command_table	"vl.cmd"
class		VLtpl3dCmd
super_class	VLtpl2dCmd
product_name	"$LOFT"
status_display  "VLtemplate", "-1", "-1"

start_state	TO_PLATE

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
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

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state TO_PLATE
	message_key		VL_S_3D_TEMPLATE
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
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
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

	on ELSE							state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
        execute                 VLcomputeTemplate ( &me->ret, PROJECT_OF)
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
        me->ret = om$send ( msg      = message VLtpl3dCmd.init( type, str_ptr),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action wakeup {

        /* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLtpl3dCmd.wakeup (pos),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Change some fields mode */
	FIfld_set_mode(me->status_display_form_ptr, TF_PH, 0, FI_REVIEW);
	FIfld_set_mode(me->status_display_form_ptr, TF_PW, 0, FI_REVIEW);
	FIfld_set_mode(me->status_display_form_ptr, TF_PS, 0, FI_REVIEW);
	FIg_set_text(me->status_display_form_ptr,TF_TIT,"Create Templates");

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
