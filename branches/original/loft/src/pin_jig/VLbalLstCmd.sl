/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	CLASS NAME : VLbalLstCmd

	ABSTRACT : I/LOFT generate ASCII file from VLbalance objects

	CHANGE HISTORY : 	file created	11-OCT-1993	Marc Fournier
				file upgraded	14-APR-1994	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

command_string	VLC_M_BALANCE_LIST, 0, VLGeBaLi
command_table	"vl.cmd"
class		VLbalLstCmd
super_class	VLlocateCmd
product_name	"$LOFT"

start_state	ASCII

specification

implementation

#include        <stdio.h>
#include        <string.h>
#include        "vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
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
#include        "vsplatedef.h"
#include        "vsmiscmacros.h"

#include        "vlmsg.h"
#include        "vluserkey.h"
#include        "vltemplate.h"
#include        "vlfloor.h"

/******************************************************************************/
state_table

#include        "vscmddef.h"
#include        "vlmsg.h"

/******************************************************************************/
state ASCII
        message_key             VL_S_BALANCE_LIST
        prompt_key              VL_P_FillForm
        status                  " "
        execute                 VLcreateFileForm (&me->ret)
                                on RETURN_CODE = VL_S_SUCCESS  state WAIT_FORM
                                on ELSE                         state ASCII
/******************************************************************************/
state WAIT_FORM
        status                  " "
        filter                  get_event

        on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED   
			do fileFormDismissed(VS_K_FILE_ACCEPTED)
			state TO_OBJECT
        on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
			do fileFormDismissed(VS_K_FILE_CANCELED)
			state terminate
        on EX_STRING						state .
/******************************************************************************/
state TO_OBJECT
        status                  " "
        execute                 VLfreeList ( &me->ret, 1)

        on ELSE                                                 state OBJECT
/******************************************************************************/
state OBJECT
	prompt_key		VL_P_BALANCE_OBJECTS
	accept_key		VL_M_BALANCE_OBJECTS
	locate_eligible		"VLbalance"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state ASCII
        on EX_DATA or EX_OBJID  do VLstoreResponse (&me->ret)	state EVENT_OBJ
/******************************************************************************/
state EVENT_OBJ
        status_key              VL_S_PROCESS
        prompt                  " "
        execute                 VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)

        on ELSE                                                 state GENERATE
/******************************************************************************/
state GENERATE
        status_key              VL_S_PROCESS
        prompt                  " "
        execute                 VLgenerateList (&me->ret)

        on ELSE                 do status_key VL_S_SUCCESS     state ASCII

        at delete               do VLfreeList ( &me->ret, 1)
/******************************************************************************/
action wakeup {

        /* Execute method sleep of upper class */
        me->ret = om$send ( msg      = message VLbalLstCmd.wakeup (pos),
			    mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action VLgenerateList {

	/* Kick-of Apfel-Strudel process */
	status = VLexecBalanceList ( me->Cnt1, me->Lst1, &me->Current,
				     me->Wfile, "RPsetup", sts);
	as$status ( msg	   = "VLexecBalanceList()",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

        goto quit;
}
/******************************************************************************/
