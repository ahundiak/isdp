/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLexBookCmd

     ABSTRACT   : I/LOFT generate loftbook ASCII file command

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLexBookCmd.
		  This command creates an ASCII file with outputs.


     CHANGE HISTORY : 	file created 	12-AUG-1994     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_EXEC_LOFTBOOK, 0, VLExLoBo
command_table	"vl.cmd"
class		VLexBookCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLexecBook", 0, 0, "-1", "-1"

start_state	WAIT_FORM1

specification

#include	"vlbook.h"

instance {
	IGRchar		UserPath[DI_PATH_MAX];
	IGRint		Chapter[VL_EXEC_BOOK_ROW];
}

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
#include        "grmacros.h"
#include        "macro.h"

#include	"vlmsg.h"
#include	"vlbook.h"
#include	"vlglobals.h"

/******************************************************************************/
state_table

#include	"vscmddef.h"
#include	"vlmsg.h"

/******************************************************************************/
state WAIT_FORM1
        message_key             VL_S_EXEC_LOFTBOOK
        status                  " "
        prompt                  "Select Chapters and Accept"

        filter                  get_event

	on EX_FORM_FINISHED					state VERIFY
/******************************************************************************/
state VERIFY
	status_key		VL_S_PROCESS
	execute			VLverifyData (&me->ret)
				on RETURN_CODE = VL_E_NO_BOOK_CHAP
					do status_key VL_E_NO_BOOK_CHAP
								state FINISH
				on RETURN_CODE = VL_E_NO_BOOK_DATA
					do status_key VL_E_NO_BOOK_DATA
								state FINISH
				on ELSE				state ASCII
/******************************************************************************/
state ASCII
        execute                 VLcreateFileForm (&me->ret)
                                on RETURN_CODE = VL_S_SUCCESS   state WAIT_FORM2
                                on ELSE                         state ASCII
/******************************************************************************/
state WAIT_FORM2
        status                  " "
        filter                  get_event

        on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
			do fileFormDismissed(VS_K_FILE_ACCEPTED)
			state COMPUTE
        on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
			do fileFormDismissed(VS_K_FILE_CANCELED)
			state FINISH
        on ELSE                                                 state .
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	execute			VLgenerateList (&me->ret)
				on RETURN_CODE = VL_E_FAILURE
					do status_key VL_E_FAILURE
								state terminate
				on RETURN_CODE = VL_S_SUCCESS
					do status_key VL_S_SUCCESS
								state terminate
/******************************************************************************/
state FINISH
        status                  " "

        on ELSE                                                 state terminate
/******************************************************************************/
action init {

		IGRdouble	value=0.0;

	/* Execute method init of upper class */
        me->ret = om$send ( msg = message VLexBookCmd.init( type, str_ptr),
                            mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Initialize chapters */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                ( &me->ret, NAM_G_BOO, &value),
                  targetid = my_id);
	VLdecode ( (IGRint)value, VL_EXEC_BOOK_ROW, me->Chapter);

	/* Initialize form */
	FIf_reset (me->forms[0].form_ptr);

        FIfld_set_num_rows ( me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP,
                             VL_EXEC_BOOK_ROW);
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_A,
			0, VL_BOOK_TIT_A, me->Chapter[VL_BOOK_IDX_A] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_B,
			0, VL_BOOK_TIT_B, me->Chapter[VL_BOOK_IDX_B] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_C,
			0, VL_BOOK_TIT_C, me->Chapter[VL_BOOK_IDX_C] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_D,
			0, VL_BOOK_TIT_D, me->Chapter[VL_BOOK_IDX_D] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_E,
			0, VL_BOOK_TIT_E, me->Chapter[VL_BOOK_IDX_E] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_F,
			0, VL_BOOK_TIT_F, me->Chapter[VL_BOOK_IDX_F] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_G,
			0, VL_BOOK_TIT_G, me->Chapter[VL_BOOK_IDX_G] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_H,
			0, VL_BOOK_TIT_H, me->Chapter[VL_BOOK_IDX_H] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_I,
			0, VL_BOOK_TIT_I, me->Chapter[VL_BOOK_IDX_I] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_J,
			0, VL_BOOK_TIT_J, me->Chapter[VL_BOOK_IDX_J] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_K,
			0, VL_BOOK_TIT_K, me->Chapter[VL_BOOK_IDX_K] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_L,
			0, VL_BOOK_TIT_L, me->Chapter[VL_BOOK_IDX_L] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_M,
			0, VL_BOOK_TIT_M, me->Chapter[VL_BOOK_IDX_M] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_N,
			0, VL_BOOK_TIT_N, me->Chapter[VL_BOOK_IDX_N] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_O,
			0, VL_BOOK_TIT_O, me->Chapter[VL_BOOK_IDX_O] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_P,
			0, VL_BOOK_TIT_P, me->Chapter[VL_BOOK_IDX_P] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_Q,
			0, VL_BOOK_TIT_Q, me->Chapter[VL_BOOK_IDX_Q] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_R,
			0, VL_BOOK_TIT_R, me->Chapter[VL_BOOK_IDX_R] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_S,
			0, VL_BOOK_TIT_S, me->Chapter[VL_BOOK_IDX_S] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_T,
			0, VL_BOOK_TIT_T, me->Chapter[VL_BOOK_IDX_T] );
	FIfld_set_text (me->forms[0].form_ptr, VL_EXEC_BOOK_CHAP, VL_BOOK_IDX_U,
			0, VL_BOOK_TIT_U, me->Chapter[VL_BOOK_IDX_U] );

	FIf_display (me->forms[0].form_ptr);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action form_notification {

                IGRlong         i, sts;
                IGRint          code;
                IGRdouble       value;

        status = OM_S_SUCCESS;

        switch (gadget_label) {

                case FI_ACCEPT:

                        for ( i=0; i<VL_EXEC_BOOK_ROW; i++)
                                FIfld_get_select ( form_ptr, VL_EXEC_BOOK_CHAP,
						   i, 0, &me->Chapter[i] );
                        VLencode ( me->Chapter, VL_EXEC_BOOK_ROW, &code);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_BOO, (IGRdouble)code),
                                  targetid = my_id);

                        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_BOO, &value),
                                  targetid = my_id);
                        VLdecode( (IGRint)value, VL_EXEC_BOOK_ROW, me->Chapter);
                        for ( i=0; i<VL_EXEC_BOOK_ROW; i++)
                                FIfld_set_select ( form_ptr, VL_EXEC_BOOK_CHAP,
						   i, 0, me->Chapter[i]);
			FIf_erase (form_ptr);
			_put_response (resp = EX_FORM_FINISHED);
                        goto quit;

                case FI_CANCEL:

                        om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_BOO, &value),
                                  targetid = my_id);
                        VLdecode( (IGRint)value, VL_EXEC_BOOK_ROW, me->Chapter);
                        for ( i=0; i<VL_EXEC_BOOK_ROW; i++)
                                FIfld_set_select ( form_ptr, VL_EXEC_BOOK_CHAP,
						   i, 0, me->Chapter[i]);
			FIf_erase (form_ptr);
			_put_response (resp = TERMINATE);
                        goto quit;

                default:
                        goto quit;
        }
}
/******************************************************************************/
action VLverifyData (	IGRlong		*msg	)
{
		IGRint		i;

	/* Initialize */
	*msg = VL_E_NO_BOOK_CHAP;

	/* Generate directories (if prepare never used before ...) */
	status = VLgenerateDirectories ( &me->Current, me->UserPath);
        as$status ( msg    = "VLgenerateDirectories()",
                    action = GOTO_VALUE,
                    value  = quit );

	/* Loop on chapters */
	for ( i=0; i<VL_EXEC_BOOK_ROW; i++) {
		if (me->Chapter[i])	VLverifyInDir ( i, me->UserPath, msg);
	}

	goto quit;
}
/******************************************************************************/
action VLgenerateList
{
	/* Kick-of Apfel-Strudel process */
        status = VLexecLoftBookList ( me->Chapter, me->UserPath, &me->Current,
                                      me->Wfile, "LBsetup", sts);
	if ((status & 0x00000001 & (*sts)))	*sts = VL_S_SUCCESS;
	else					*sts = VL_E_FAILURE;

	goto quit;
}
/******************************************************************************/
