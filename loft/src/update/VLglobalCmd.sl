/*  $Id: VLglobalCmd.sl,v 1.2 2001/09/24 19:27:39 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        src/update/VLglobalCmd.sl 
 *
 *    ABSTRACT   : I/LOFT updates globals in DPR.
 *
 * Revision History:
 *      $Log: VLglobalCmd.sl,v $
 *      Revision 1.2  2001/09/24 19:27:39  ramarao
 *      Added two global bend step and template step values.
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:57  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/06/01  16:16:42  pinnacle
# (No comment)
#
# Revision 1.3  1998/06/01  18:39:52  pinnacle
# Replaced: src/update/VLglobalCmd.sl for:  by smpathak for loft
#
 *
 *  
 *
 *   NOTES	: This command object defines the classe VLglobalCmd.
 *		  This command updates some I/LOFT macros.
 *
  * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      05/03/94   Mark F.      File Creation
 *      06/01/98   Sandeep      File modification for 179800719
 *************************************************************************/


command_string	VLC_M_UPDATE_GLOBALS, 0, VLUpGl
command_table	"vl.cmd"
class		VLglobalCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLglobals", 0, 0, "-1", "-1"

start_state	GLOBAL

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
#include        "grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "FI.h"
#include	"macro.h"
#include	"ACattrib.h"

#include	"vlmsg.h"
#include	"vlunfold.h"
#include	"vlglobals.h"
#include	"vlfloor.h"
#include	"vlplatejig.h"
#include	"vlpinjig.h"
#include	"vlstifftpl.h"
#include	"vlupdate.h"
#include	"vlunwext.h"

#define	NAM_U1	"No Expansion"
#define	NAM_U2	"Expansion by Marking"
#define	NAM_U3	"Global Expansion"

#define	IDX_U1	0
#define	IDX_U2	2
#define	IDX_U3	1

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vscmddef.h"
#include	"vlmsg.h"

/******************************************************************************/
state GLOBAL
	message_key		VL_S_UPDATE_GLOBALS
	status			" "
	prompt			"Perform form operations"
	execute			VLfillForm (&me->ret)

	on ELSE							state WAIT_FORM
/******************************************************************************/
state WAIT_FORM
	filter			get_event

	on EX_FORM_FINISHED					state terminate
	on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
				do fileFormDismissed(VS_K_FILE_ACCEPTED)
				state ASCII
	on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
				do fileFormDismissed(VS_K_FILE_CANCELED)
				state BUTTON
/******************************************************************************/
state ASCII
	execute			VLprocessASCII (&me->ret)

	on ELSE							state BUTTON
/******************************************************************************/
state BUTTON
	execute			VLbuttonOff (&me->ret)

	on ELSE							state WAIT_FORM
/******************************************************************************/
action form_notification {

		IGRdouble	val;
		IGRint		sel, pos, state, option, i, flag[IDX_SC_SIZE];
                IGRint		opt[UNWEXT_NB_OPT];
		IGRlong		sts;
		IGRchar		text[80];

	status = OM_S_SUCCESS;

	switch (gadget_label) {

		case FI_ACCEPT:

/* Multi-field 101 */
			FIfld_get_value(form_ptr, 101, 0, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_MID, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 1, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_TGG, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 2, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_JGG, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 3, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_EXT, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 4, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_PGH, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 5, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_PGW, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 6, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_PGS, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 7, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_RAD, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 8, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_OFF, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101, 9, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_SPA, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,10, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_XPI, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,11, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_YPI, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,12, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_MRG, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,13, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_IPJ, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,14, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_PJI, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,15, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_TSZ, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,16, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_JSZ, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,17, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_STH, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,18, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_STT, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,19, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_STE, val),
				  targetid = my_id);


			FIfld_get_value(form_ptr, 101,20, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_OFFSET, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,21, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_REL_ER, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,22, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_FIB, val),
				  targetid = my_id);
			FIfld_get_value(form_ptr, 101,23, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_X_EXP, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,24, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_Y_EXP, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,25, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_JSW, val),
				  targetid = my_id);

			FIfld_get_value(form_ptr, 101,26, 1, &val, &sel, &pos);
			om$send ( msg = message VLlocateCmd.VLmodGlobals
						(&sts, NAM_G_PJH, val),
				  targetid = my_id);

                        FIfld_get_value(form_ptr, 101,27, 1, &val, &sel, &pos);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                (&sts, NAM_G_BEND_STEP, val),
                                  targetid = my_id);

                        FIfld_get_value(form_ptr, 101,28, 1, &val, &sel, &pos);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                                (&sts, NAM_G_TEMP_STEP, val),
                                  targetid = my_id);

/* Toggle 102 */
			FIg_get_state(form_ptr, 102, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_SPI, (IGRdouble)state),
                                  targetid = my_id);

/* Toggle 103 */
			FIg_get_state(form_ptr, 103, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_PJQ, (IGRdouble)state),
                                  targetid = my_id);

/* Toggle 104 */
			FIg_get_state(form_ptr, 104, &state);
			if (!state)
                        	om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_PJT, (IGRdouble)IDX_J1),
                                  targetid = my_id);
			else	om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_PJT, (IGRdouble)IDX_J2),
                                  targetid = my_id);

/* Toggle 105 */
			FIg_get_state(form_ptr, 105, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_STW, (IGRdouble)state),
                                  targetid = my_id);

// added by GJ
/* Toggle 15 */
			FIg_get_state(form_ptr, 15, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_TESS,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 110 */
			FIg_get_state(form_ptr, 110, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_UNW_SURF,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 16 */
			FIg_get_state(form_ptr, 16, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                       (&sts,NAM_G_WATONPLATE,(IGRdouble)state),
                                  targetid = my_id);

/* Field 106 */
			FIg_get_text (form_ptr, 106, text);
			if      (!strcmp(text, NAM_J3)) option = IDX_J3;
                        else if (!strcmp(text, NAM_J4)) option = IDX_J4;
                        else                            option = IDX_J5;
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_TJT, (IGRdouble) option),
                                  targetid = my_id);

/* Multi-field 107 */
			for ( i=0; i<3; i++)
				FIfld_get_select(form_ptr, 107, i, 0, &flag[i]);
			VLencode ( flag, 3, &option);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_SYO, (IGRdouble) option),
                                  targetid = my_id);

/* Multi-field 108 */
			for ( i=0; i<IDX_SC_SIZE; i++)
				FIfld_get_select(form_ptr, 108, i, 0, &flag[i]);
			VLencode ( flag, IDX_SC_SIZE, &option);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_STC, (IGRdouble) option),
                                  targetid = my_id);

// added by GJ
//modified for 179800719 by SMP
/* Multi-field 14 */
			for ( i=0; i<UNWEXT_ATT_IDX_PARENT ; i++)
			    FIfld_get_select(form_ptr, 14, i, 0, &opt[i]);
/* Multi-field 17 */
                        for ( i=UNWEXT_ATT_IDX_PARENT ; i< UNWEXT_NB_OPT; i++)
                            FIfld_get_select(form_ptr, 17,
					 i-UNWEXT_ATT_IDX_PARENT, 0, &opt[i]);

			VLencode ( opt, UNWEXT_NB_OPT, &option);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_UNW_CODE, (IGRdouble) option),
                                  targetid = my_id);

/* Multi-field 109 */
			for ( i=0; i<IDX_UPD_SIZE; i++)
				FIfld_get_select(form_ptr, 109, i, 0, &flag[i]);
			VLencode ( flag, IDX_UPD_SIZE, &option);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_UPD, (IGRdouble) option),
                                  targetid = my_id);

/* Field 111 */
			FIg_get_text (form_ptr, 111, text);
			if      (!strcmp(text, NAM_U1)) option = IDX_U1;
                        else if (!strcmp(text, NAM_U2)) option = IDX_U2;
                        else                            option = IDX_U3;
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_T_EXP, (IGRdouble) option),
                                  targetid = my_id);

/* Field 18 */
			FIg_get_text (form_ptr, 18, text);
			if      (!strcmp(text, "Base")) option = BASE_SIDE;
                        else if (!strcmp(text, "Offset")) option = OFFSET_SIDE;
			else if (!strcmp(text, "Base-Flip")) option = BASE_FLIP;
                        else if (!strcmp(text, "Offset-Flip")) option = OFFSET_FLIP;

                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  ( &sts, NAM_G_SIDE, (IGRdouble) option),
                                  targetid = my_id);

/* Toggle 112 */
			FIg_get_state(form_ptr, 112, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_JGO,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 113 */
			FIg_get_state(form_ptr, 113, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_JSO,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 114 */
			FIg_get_state(form_ptr, 114, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_PTN,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 115 */
			FIg_get_state(form_ptr, 115, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_PJN,(IGRdouble)state),
                                  targetid = my_id);

/* Toggle 116 */
			FIg_get_state(form_ptr, 116, &state);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts,NAM_G_PJM,(IGRdouble)state),
                                  targetid = my_id);

		case FI_CANCEL:
			FIf_erase (form_ptr);
			_put_response (resp = EX_FORM_FINISHED);
			goto quit;

		case 12:
			me->FileMode = 2;

               		ex$message( field   	  = PROMPT_FIELD,
				    justification = RIGHT_JUS,
                                    in_buff 	  = "Write to the file" );

			om$send ( msg = message VLlocateCmd.VLcreateFileForm
							(&sts),
                                  targetid = my_id);
			goto quit;

		case 13:
			me->FileMode = 1;

               		ex$message( field   	  = PROMPT_FIELD,
				    justification = RIGHT_JUS,
                                    in_buff 	  = "Read from the file" );

			om$send ( msg = message VLlocateCmd.VLcreateFileForm
							(&sts),
                                  targetid = my_id);
			goto quit;

		default:
			goto quit;
	}
}
/******************************************************************************/
action VLfillForm {

		IGRdouble	value;
		IGRint		flag[UNWEXT_NB_OPT], i;

	/* Reset form */
	FIf_reset (me->forms[0].form_ptr);

	/* Values */
	FIfld_set_num_rows ( me->forms[0].form_ptr, 101, 27);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 0, 0, SYN_G_MID, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_MID,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 0, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 1, 0, SYN_G_TGG, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_TGG,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 1, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 2, 0, SYN_G_JGG, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_JGG,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 2, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 3, 0, SYN_G_EXT, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_EXT,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 3, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 4, 0, SYN_G_PGH, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PGH,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 4, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 5, 0, SYN_G_PGW, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PGW,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 5, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 6, 0, SYN_G_PGS, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PGS,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 6, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 7, 0, SYN_G_RAD, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_RAD,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 7, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 8, 0, SYN_G_OFF, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_OFF,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 8, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101, 9, 0, SYN_G_SPA, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_SPA,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101, 9, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,10, 0, SYN_G_XPI, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_XPI,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,10, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,11, 0, SYN_G_YPI, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_YPI,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,11, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,12, 0, SYN_G_MRG, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_MRG,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,12, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,13, 0, SYN_G_IPJ, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_IPJ,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,13, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,14, 0, SYN_G_PJI, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJI,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,14, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,15, 0, SYN_G_TSZ, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_TSZ,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,15, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,16, 0, SYN_G_JSZ, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_JSZ,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,16, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,17, 0, SYN_G_STH, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_STH,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,17, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,18, 0, SYN_G_STT, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_STT,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,18, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,19, 0, SYN_G_STE, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_STE,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,19, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,20, 0, SYN_G_OFFSET, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_OFFSET,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,20, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,21, 0, SYN_G_REL_ER, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_REL_ER,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,21, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,22, 0, SYN_G_FIB, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_FIB,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,22, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,23, 0, SYN_G_X_EXP, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_X_EXP,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,23, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,24, 0, SYN_G_Y_EXP, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_Y_EXP,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,24, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,25, 0, SYN_G_JSW, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_JSW,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,25, 1, value, 0);

	FIfld_set_text ( me->forms[0].form_ptr, 101,26, 0, SYN_G_PJH, 0);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJH,&value),
		targetid=my_id);
	FIfld_set_value( me->forms[0].form_ptr, 101,26, 1, value, 0);

        FIfld_set_text ( me->forms[0].form_ptr, 101,27, 0, SYN_G_BRS, 0);
        om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_BEND_STEP,&value),
                targetid=my_id);
        FIfld_set_value( me->forms[0].form_ptr, 101,27, 1, value, 0);

        FIfld_set_text ( me->forms[0].form_ptr, 101,28, 0, SYN_G_TRS, 0);
        om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_TEMP_STEP,&value),
                targetid=my_id);
        FIfld_set_value( me->forms[0].form_ptr, 101,28, 1, value, 0);

	/* Toggles */
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_SPI,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 102, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJQ,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 103, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJT,&value),
		targetid=my_id);
	if ((IGRint)value == IDX_J1)
		FIg_set_state( me->forms[0].form_ptr, 104, 0);
	else	FIg_set_state( me->forms[0].form_ptr, 104, 1);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_STW,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 105, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_UNW_SURF,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 110, (IGRint)value);

//added by GJ
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_WATONPLATE,
                                                     &value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 16, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_TESS,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 15, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_JGO,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 112, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_JSO,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 113, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PTN,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 114, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJN,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 115, (IGRint)value);

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_PJM,&value),
		targetid=my_id);
	FIg_set_state( me->forms[0].form_ptr, 116, (IGRint)value);

	/* Fields */
	FIfld_set_list_text (me->forms[0].form_ptr,106,0,0,NAM_J3,TRUE);
	FIfld_set_list_text (me->forms[0].form_ptr,106,1,0,NAM_J4,TRUE);
	FIfld_set_list_text (me->forms[0].form_ptr,106,2,0,NAM_J5,TRUE);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_TJT,&value),
		targetid=my_id);
	switch ((IGRint)value) {
		case IDX_J3:	FIg_set_text (me->forms[0].form_ptr,106,NAM_J3);
				break;
		case IDX_J4:	FIg_set_text (me->forms[0].form_ptr,106,NAM_J4);
				break;
		case IDX_J5:	FIg_set_text (me->forms[0].form_ptr,106,NAM_J5);
				break;
	}

	/* Multi-fields */
	FIfld_set_text ( me->forms[0].form_ptr, 107, 0, 0, NAM_PJO_MIP, 1);
	FIfld_set_text ( me->forms[0].form_ptr, 107, 1, 0, NAM_PJO_ECP, 1);
	FIfld_set_text ( me->forms[0].form_ptr, 107, 2, 0, NAM_PJO_CSP, 1);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_SYO,&value),
		targetid=my_id);
	VLdecode ( (IGRint)value, 3, flag);
	for ( i=0; i<3; i++)
		FIfld_set_select ( me->forms[0].form_ptr, 107, i, 0, flag[i]);

	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_BUTT,0,NAM_SC_BUTT,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_CTRL,0,NAM_SC_CTRL,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_MRKL,0,NAM_SC_MRKL,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_SEAM,0,NAM_SC_SEAM,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_WATL,0,NAM_SC_WATL,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_TRAC,0,NAM_SC_TRAC,1);
	FIfld_set_text(me->forms[0].form_ptr,108,IDX_SC_MACR,0,NAM_SC_MACR,1);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_STC,&value),
		targetid=my_id);
	VLdecode ( (IGRint)value, IDX_SC_SIZE, flag);
	for ( i=0; i<IDX_SC_SIZE; i++)
		FIfld_set_select ( me->forms[0].form_ptr, 108, i, 0, flag[i]);

	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_BALP,0,NAM_UPD_BALP,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_STFT,0,NAM_UPD_STFT,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_UNWR,0,NAM_UPD_UNWR,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_PCAV,0,NAM_UPD_PCAV,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_PCAT,0,NAM_UPD_PCAT,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_BOOK,0,NAM_UPD_BOOK,1);

// added by GJ
//modified for 179800719 by SMP
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_UNW_CODE,&value),
		targetid=my_id);
	VLdecode ( (IGRint)value, UNWEXT_NB_OPT, flag);
	for ( i=0; i<UNWEXT_ATT_IDX_PARENT; i++)
		FIfld_set_select ( me->forms[0].form_ptr, 14, i, 0, flag[i]);
        for ( i=UNWEXT_ATT_IDX_PARENT; i< UNWEXT_NB_OPT; i++)
                FIfld_set_select ( me->forms[0].form_ptr, 17,
				 i-UNWEXT_ATT_IDX_PARENT, 0, flag[i]);

	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_BALP,0,NAM_UPD_BALP,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_STFT,0,NAM_UPD_STFT,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_UNWR,0,NAM_UPD_UNWR,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_PCAV,0,NAM_UPD_PCAV,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_PCAT,0,NAM_UPD_PCAT,1);
	FIfld_set_text(me->forms[0].form_ptr,109,IDX_UPD_BOOK,0,NAM_UPD_BOOK,1);


	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_UPD,&value),
		targetid=my_id);
	VLdecode ( (IGRint)value, IDX_UPD_SIZE, flag);
	for ( i=0; i<IDX_UPD_SIZE; i++)
		FIfld_set_select ( me->forms[0].form_ptr, 109, i, 0, flag[i]);

	FIfld_set_list_text (me->forms[0].form_ptr,111,0,0,NAM_U1,TRUE);
	FIfld_set_list_text (me->forms[0].form_ptr,111,1,0,NAM_U2,TRUE);
	FIfld_set_list_text (me->forms[0].form_ptr,111,2,0,NAM_U3,TRUE);
	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_T_EXP,&value),
		targetid=my_id);
	switch ((IGRint)value) {
		case IDX_U1:	FIg_set_text (me->forms[0].form_ptr,111,NAM_U1);
				break;
		case IDX_U2:	FIg_set_text (me->forms[0].form_ptr,111,NAM_U2);
				break;
		case IDX_U3:	FIg_set_text (me->forms[0].form_ptr,111,NAM_U3);
				break;
	}

	om$send(msg=message VLlocateCmd.VLgetGlobals(sts,NAM_G_SIDE,&value),
		targetid=my_id);
	switch ((IGRint)value) {
		case BASE_SIDE:	 FIg_set_text(me->forms[0].form_ptr,18,"Base");
				 break;
		case OFFSET_SIDE: FIg_set_text(me->forms[0].form_ptr,18,
                                               "Offset");
				  break;
		case BASE_FLIP:	 FIg_set_text(me->forms[0].form_ptr,18,"Base-Flip");
				 break;
		case OFFSET_FLIP: FIg_set_text(me->forms[0].form_ptr,18,
                                               "Offset-Flip");
				  break;
	}

	/* Display form */
	FIf_display (me->forms[0].form_ptr);

	status = OM_S_SUCCESS;

	goto quit;
}
/******************************************************************************/
action VLprocessASCII {

switch (me->FileMode) {

case 1: status = om$send ( msg = message VLlocateCmd.VLreadGlobalsFromASCII
						(sts),
			   targetid = my_id );

	status = om$send ( msg = message VLglobalCmd.VLfillForm (sts),
		  	   targetid = my_id );
	as$status ( test   = (!(status & 1 & (*sts))),
		    msg	   = "VLglobalCmd.VLfillForm",
		    action = GOTO_VALUE,
		    value  = quit );
	goto quit;

case 2: status = om$send ( msg = message VLlocateCmd.VLwriteGlobalsInASCII
						(sts),
			   targetid = my_id );
	goto quit;
}
}
/******************************************************************************/
action VLbuttonOff {

	status = OM_S_SUCCESS;

	switch (me->FileMode) {

		case 1:	FIg_set_state_off ( me->forms[0].form_ptr, 13);
			goto quit;

		case 2:	FIg_set_state_off ( me->forms[0].form_ptr, 12);
			goto quit;
	}
}
/******************************************************************************/
