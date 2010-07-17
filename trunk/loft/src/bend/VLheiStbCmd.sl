/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLheiStbCmd.sl

     ABSTRACT   : I/LOFT evaluate inverse bending lines heights

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLheiStbCmd.sl.
		  This command creates an ASCII file with outputs.


     CHANGE HISTORY : 	file created 	01-AUG-1994     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_HEI_BEND_STFNR, 0, VLHeBeSt
command_table	"vl.cmd"
class		VLheiStbCmd
super_class	VLlocateCmd
product_name	"$LOFT"

start_state	ASCII

implementation

#include        <stdio.h>
#include        <string.h>
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
#include        "godef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "FI.h"
#include        "ACattrib.h"
#include        "msmacros.h"
#include        "vsmiscmacros.h"

#include	"vlmsg.h"

/******************************************************************************/
state_table

#include        "vscmddef.h"
#include	"vlmsg.h"

/******************************************************************************/
state ASCII
	message_key		VL_S_HEI_BEND_STFNR
        prompt_key              VL_P_FillForm
	status			" "
	execute			VLcreateFileForm (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS	state WAIT_FORM
				on ELSE				state ASCII
/******************************************************************************/
state WAIT_FORM
	status			" "
	filter			get_event

	on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
				do fileFormDismissed(VS_K_FILE_ACCEPTED)
				state TO_TPL
	on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
				do fileFormDismissed(VS_K_FILE_CANCELED)
				state terminate
	on EX_STRING						state .
/******************************************************************************/
state TO_TPL
	status			" "
	execute			VLfreeList ( &me->ret, 1)
	
	on ELSE							state TEMPLATE
/******************************************************************************/
state TEMPLATE
	prompt_key		VL_P_BEND_STFNR
	accept_key		VL_M_BEND_STFNR
	locate_eligible		"VLstifBend"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state ASCII
        on EX_DATA or EX_OBJID	do VLstoreResponse (&me->ret)	state EVENT_TPL
/******************************************************************************/
state EVENT_TPL
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
	execute			VLfreeList (&me->ret, 1)
	execute			VLstoreList (&me->ret, 0, 1)

        on ELSE							state GENERATE
/******************************************************************************/
state GENERATE
        status_key              VL_S_PROCESS
        prompt			" "
	execute			VLgenerateList (&me->ret)

        on ELSE                                                 state ASCII

	at delete		do VLfreeList (&me->ret, 1)
/******************************************************************************/
action VLgenerateList {

        /* Kick-of Apfel-Strudel process */
        status = VLexecHeiBendStfnrList ( me->Cnt1, me->Lst1, &me->Current,
                                          me->Wfile, "RPsetup", sts);
        as$status ( msg    = "VLexecHeiBendStfnrList()",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );

        goto quit;
}
/******************************************************************************/
