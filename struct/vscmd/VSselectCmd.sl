/*
	I/STRUCT
	"Place Structural Selector" command.
*/
command_string	VSC_M_VSPlStSl,0,VSPlStSl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSselectCmd
super_class	VSlocateCmd
product_name	"$STRUCT"
form		"VSstructSlc.fm",1,0,"-1","-1"

specification

#include <stdio.h>
#include "vsslcdef.h"

instance {
	/*
	 * Count of input objects to selector.
	 */
	char	inputCount,
	/*
	 * List of user-defined names for input objects (aliases).
	 */
		inputAlias[VS_K_MAX_INPUT][VS_K_tokMAX_SIZE] ;
	/*
	 * Active row in program statements field.
	 */
	int	programRow,
	/*
	 * Active character in program statements field.
	 */
		programChar,
	/*
	 * Index of currently located input object.
	 */
		index ;
	/*
	 * Pointer to keyboard sub-form.
	 */
	char	*keyboardForm,
		*prevForm ;
	int	prevLabel ;

	/*
	 * Pointer to input-file-name form.
	 */
	char	*fileForm ;

	VSfileFormInfo	fileInfo ;
	
	/*
	 * Last-deleted word.
	 */
	variable char	delWord[0] ;

	/*
	 * Original location of keyboard button.
	 */
	int	kbx,
		kby ;

	/*
	 * Original location of statements field and original number of
	 * visible rows.
	 */
	int	stx,
		sty,
		stvisrows ;

	/*
	 * Template for basename of constructed selector.
	 */
	char	tempBsNm[FILENAME_MAX+2] ;

	/*
	 * TRUE if program entered interactively, FALSE if read from a file.
	 */
	int	interactiveKeyIn ;
}

implementation

#include <sys/param.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <FI.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsslcmacros.h"
#include "vsslformdef.h"
#include "vsmiscmacros.h"
#include "vsnamemacros.h"
#include "vsformmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsfmcpypaste.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsslcproto.h"

%safe
static char	curPATH[MAXPATHLEN	+1]	= ".",
		curNAME[FILENAME_MAX	+1]	= "",
		curRGXP[VS_K_MAX_RGXP]		= "*" ;
%endsafe

from	GRgraphics	import GRconstruct ;
/*----------------------------------------------------------------------------*/
static void VSset_btn_texts( kbForm ) char *kbForm ; {

	char	*text ;

#define PUTMSG( x ) \
	FIg_set_text( kbForm, VS_K_sl##x##btn, VSmsgkey2string( VS_gI_kw##x ) )

	PUTMSG( IF	) ;
	PUTMSG( THEN	) ;
	PUTMSG( ELSE	) ;
	PUTMSG( ENDIF	) ;
	PUTMSG( AND	) ;
	PUTMSG( OR	) ;
	PUTMSG( NOT	) ;
	PUTMSG( OUTPUT	) ;

	text = VSmsgkey2string( VS_gI_kwBEAM ) ;
	strcat( text, "(" ) ;
	FIg_set_text( kbForm, VS_K_slBEAMbtn, text ) ;

	text = VSmsgkey2string( VS_gI_kwPLATE ) ;
	strcat( text, "(" ) ;
	FIg_set_text( kbForm, VS_K_slPLATEbtn, text ) ;

} /* VSset_btn_texts */
/*----------------------------------------------------------------------------*/
static char *VSgetProgramBuffer( form ) char *form ; {

	char	*dcl,
		*prg,
		*buf ;

	dcl = VSfld_get_lines( form, VS_K_slInputField ) ;
	prg = VSfld_get_lines( form, VS_K_slStmntField ) ;

	if( dcl && prg ) {
		buf = _MALLOC( strlen( dcl ) + strlen( prg ) + 2, char ) ;
		if( buf ) {
			sprintf( buf, "%s\n%s", dcl, prg ) ;
		} else {
			__DBGpr_com( "No mem for BUF" ) ;
		}
	} else {
		__DBGpr_com( "No mem for DCL or PRG" ) ;
		buf = NULL ;
	}
#ifdef vsDEBUG
	VSdumpString( prg ) ;
	printf( "END PROG BUF" ) ;
#endif
	_FREE( dcl ) ; _FREE( prg ) ;

	return buf ;

} /* VSgetProgramBuffer */
/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "grmsg.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start
	message_key	VS_M_VSPlStSl
	execute		resetCmd()
	on ELSE		state getInputAliases

state getInputAliases
	/*
	 * Ask for correspondance "input <n> = <user name>"
	 */
	execute		formPromptAlias()
	filter		get_event
		/*
		 * End of aliasing.
		 */
		on GR_UNKNOWN_TYPE.VS_K_END_STATE	state getProgram
		/*
		 * User wants to read program from an ASCII file.
		 */
		on GR_UNKNOWN_TYPE.VS_K_FILE_STARTED	state readFile
		/*
		 * User wants to modify previously defined alias.
		 */
		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state modAliasFromInput
		on GR_UNKNOWN_TYPE.VS_K_SAME_STATE	state .
		on EX_BACK_UP				state start
		on EX_RESTART				state start

state readFile
	prompt_key	VS_P_KeyInFileName
	filter		get_event
		on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
			do fileFormDismissed( VS_K_FILE_ACCEPTED )
			do prompt ""
			do fileToForm( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS" state -
			state getProgram
		on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
			do fileFormDismissed( VS_K_FILE_CANCELED )
			do prompt ""
			state -
		on ELSE					state .

state modAliasFromInput
	/*
	 * User wants to modify an alias from the aliasing state.
	 */
	execute		aliasFieldOnly()
	filter		get_event
		on EX_RESTART				state start
		/*
		 * Return whence you came.
		 */
		on GR_UNKNOWN_TYPE.VS_K_END_STATE	state getInputAliases

state modAliasFromProgram
	/*
	 * User wants to modify an alias from the program key-in state.
	 */
	execute		aliasFieldOnly()
	filter		get_event
		on EX_RESTART				state start
		/*
		 * Return whence you come.
		 */
		on GR_UNKNOWN_TYPE.VS_K_END_STATE	state getProgram
	
state getProgram
	/*
	 * Key-in selector's program.
	 */
	execute		formPromptProgram()
	execute		set_dynamics_in_form( &me->ret, me->forms[0].form_ptr )
	filter		get_event
		on EX_RESTART				state start
		/*
		 * User wants to modify previously defined alias.
		 */
		on GR_UNKNOWN_TYPE.VS_K_CH_STATE
			do stop_dynamics_in_form( &me->ret,
						  me->forms[0].form_ptr )
			state modAliasFromProgram
		on GR_UNKNOWN_TYPE.VS_K_SAME_STATE	state .
		on GR_UNKNOWN_TYPE.VS_K_DYN_MOUSE	state .
		on GR_UNKNOWN_TYPE.VS_K_FILE_STARTED	state writeFile
		/*
		 * Program has been entered: go and locate input.
		 */
		on GR_UNKNOWN_TYPE.VS_K_END_STATE
			do formOpByIndex( 0, VS_FIf_ERASE )
			do formOpByPtr( me->keyboardForm, VS_FIf_ERASE )
							state locateInput

state writeFile
	prompt_key	VS_P_KeyInFileName
	filter		get_event
		on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
			do fileFormDismissed( VS_K_FILE_ACCEPTED )
			do prompt ""
			do formToFile( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS" state -
			state -
		on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
			do prompt ""
			do fileFormDismissed( VS_K_FILE_CANCELED )
			state -
		on ELSE					state .


state locateInput
	execute			locatePrompt()
	locate_class		"+GRvg"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_RJT_MOVEON | GRm_BACK_UP"
	filter			locate_noauto
		on EX_DATA or EX_OBJID
			do storeInput( 1 )
				on RETURN_CODE = "VS_K_ABORT_CMD"
						state terminate
				/*
				 * Need more input.
				 */
				on RETURN_CODE = "VS_K_SAME_STATE"
						state .
				/*
				 * All needed input located.
				 */
				on RETURN_CODE = "VS_K_CH_STATE"
						state cstSelector
				/*
				 * Control should not get here.
				 */
				state terminate
		on EX_BACK_UP
			do removeLastInput()
				on RETURN_CODE = "VS_K_ACT_SUCCESS"
						state .
				/*
				 * All input has been discarded.
				 */
				on RETURN_CODE = "VS_K_CH_STATE"
						state returnToProg
				/*
				 * Control should not get here.
				 */
				state terminate
		on EX_RJT_MOVEON
				state getExpression

state getExpression
	execute			locatePrompt()
	locate_mask		"GRm_DATA | GRm_RESET | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP | GRm_RJT_MOVEON"
	accept_mask		"GRm_DATA | GRm_RESET | GRm_OBJID"
	filter			VSget_exp
		on ERROR			state .
		on EX_OBJID or EX_DATA or EX_STRING
			do storeInput( 0 )
				on RETURN_CODE = "VS_K_ABORT_CMD"
						state terminate
				/*
				 * Need more input.
				 */
				on RETURN_CODE = "VS_K_SAME_STATE"
						state .
				/*
				 * All needed input located.
				 */
				on RETURN_CODE = "VS_K_CH_STATE"
						state cstSelector
				/*
				 * Control should not get here.
				 */
				state terminate
		on EX_BACK_UP
			do error_box "BACKUP"
			do removeLastInput()
				on RETURN_CODE = "VS_K_ACT_SUCCESS"
						state .
				/*
				 * All input has been discarded.
				 */
				on RETURN_CODE = "VS_K_CH_STATE"
						state returnToProg
				/*
				 * Control should not get here.
				 */
				state terminate
		on EX_RJT_MOVEON
				state locateInput

state cstSelector
	execute constructSelector()
	/*
	 * Discard all input.
	 */
	execute rmLastLocObjs( 0 )
	on ELSE state returnToProg

state returnToProg
	execute formOpByIndex( 0, VS_FIf_DISPLAY )
	execute formOpByPtr( me->keyboardForm, VS_FIf_DISPLAY )
	prompt	""
	on ELSE state getProgram

at init		do initCmd()
at wakeup	do TurnFormsOnOff( 1 )
		do checkPWD()
at sleep	do TurnFormsOnOff( 0 )
at delete	do cleanUp()
/*----------------------------------------------------------------------------*/
action initCmd() {

	extern int COB_FI_initial_form_notification() ;
	FIf_set_initial_notification_routine( me->forms[0].form_ptr,
					      COB_FI_initial_form_notification ) ; 
	return OM_S_SUCCESS ;

} /* action initCmd */
/*----------------------------------------------------------------------------*/
action cleanUp() {

	VSf_resetCopyPasteInfo( me->forms[0].form_ptr ) ;
	if( me->keyboardForm )  FIf_delete( me->keyboardForm ) ;
	return OM_S_SUCCESS ;
	
} /* action cleanUp */
/*----------------------------------------------------------------------------*/
action fileFormDismissed( int dismissType ) {

	char	*masterForm = me->forms[0].form_ptr ;

	
	FIg_set_state_off( masterForm, VS_K_slReadFilBtn ) ;
	FIg_set_state_off( masterForm, VS_K_slWritFilBtn ) ;

	switch( dismissType ) {
		case VS_K_FILE_ACCEPTED : break ;
		case VS_K_FILE_CANCELED : me->fileInfo.pathName[0] = '\0' ;
					  break ;
	}
	me->fileForm = NULL ;
	return OM_S_SUCCESS ;

} /* action fileFormDismissed */
/*----------------------------------------------------------------------------*/
action formToFile( long *msg ) {

	char		*program ;
	FILE		*f ;

	__DBGpr_str( "WRITE TO", me->fileInfo.pathName ) ;

	program = VSgetProgramBuffer( me->forms[0].form_ptr ) ;
	if( !program ) {
		__DBGpr_com( "No mem for program" ) ;
		*msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}

	f = VSopenFile( msg, me->fileInfo.pathName, "w" ) ;
	if( f ) {
		char	*p ;
		int	trunc ;

		fputs( program, f ) ;
		fputs( "\n"   , f ) ;
		fclose( f ) ;
		/*
		 * Use file name as a template for selector's name.
		 */
		p = strrchr( me->fileInfo.pathName, '/' ) ;
		VSstrncpy( me->tempBsNm, p+1, FILENAME_MAX, &trunc ) ;
		strcat( me->tempBsNm, "_1" ) ;
		*msg = VS_K_ACT_SUCCESS ;
	} else {
		long	key ;
		key = VSgetMsgKey( *msg ) ;
		VSfi_msg( me->forms[0].form_ptr, VSmsgkey2string( key ) ) ;
		*msg = MSFAIL ;
	}

	wrapup :
		_FREE( program ) ;
		return OM_S_SUCCESS ;

} /* action formToFile */
/*----------------------------------------------------------------------------*/
action fileToForm( long *msg ) {

	char		*program,
			*mform = me->forms[0].form_ptr,
			*p ;
	int		isASCII,
			x0, y0,
			x1, y1,
			visrows1,
			visrows2,
			trunc ;

	program = VSreadASCIIfileToBuffer( msg, me->fileInfo.pathName, &isASCII);

	if( !( *msg & 1 ) ) {
		long key ;
		if( !isASCII ) {
			key = VS_gE_NotAnASCIIfile ;
		} else {
			key = VSgetMsgKey( *msg ) ;
		}
		VSfi_msgkey( mform, key ) ;

		*msg = MSFAIL ; goto wrapup ;
	}

	/*
	 * Erase alias and input fields. Move some gadgets around to make room
	 * for the program field.
	 * We not not need the alias and input fields any longer since the
	 * corresponding declarations are supposed to be in the file just read.
	 */
	FIg_get_location( mform, VS_K_slAliasField, &x0, &y0 ) ;
	FIg_get_location( mform, VS_K_slInputField, &x1, &y1 ) ;
	vs$g_erase_gadgets(	form	= mform,
				list	= `VS_K_slAliasField,
					   VS_K_slInputBtn_0,
					   VS_K_slInputBtn_1,
					   VS_K_slInputBtn_2,
					   VS_K_slInputBtn_3,
					   VS_K_slInputBtn_4,
					   VS_K_slKyBoardBtn,
					   VS_K_slStmntField,
					   VS_K_slInputField` ) ;

	FIg_get_location( mform, VS_K_slKyBoardBtn, &me->kbx, &me->kby ) ;
	FIg_get_location( mform, VS_K_slStmntField, &me->stx, &me->sty ) ;

	FIg_set_location( mform, VS_K_slKyBoardBtn, x0, y0 ) ;
	FIg_set_location( mform, VS_K_slStmntField, x1, y1 ) ;

	FIfld_get_num_vis_rows( mform, VS_K_slInputField, &visrows1 ) ;
	FIfld_get_num_vis_rows( mform, VS_K_slStmntField, &visrows2 ) ;
	me->stvisrows = visrows2 ;
	visrows2 += visrows1 ;
	FIfld_set_num_vis_rows( mform, VS_K_slStmntField, visrows2 ) ;

	VSfld_set_lines( mform, VS_K_slStmntField, program ) ;

	vs$g_display_gadgets(	form	= mform,
				list	= `VS_K_slKyBoardBtn,
					   VS_K_slStmntField` ) ;

	me->programChar = me->programRow = 0 ;
	/*
	 * Flag that no aliases have been input interactively.
	 */
	me->interactiveKeyIn = FALSE ;
	me->inputCount  = -1 ;

	/*
	 * Use file name as a template for selector's name.
	 */
	p = strrchr( me->fileInfo.pathName, '/' ) ;
	VSstrncpy( me->tempBsNm, p+1, FILENAME_MAX, &trunc ) ;
	strcat( me->tempBsNm, "_1" ) ;

	*msg = VS_K_ACT_SUCCESS ;

	wrapup :
		_FREE( program ) ;
		return OM_S_SUCCESS ;

} /* action fileToForm */
/*----------------------------------------------------------------------------*/
action TurnFormsOnOff( int Switch ) {

	char	*mform	= me->forms[0].form_ptr,
		*kform	= me->keyboardForm ;

	if( Switch ) {
		if( me->state == _getProgram ||
		    me->state == _readFile   ||
		    me->state == _writeFile ) {
			vs$g_enable_gadgets(	form	= mform,
						list	= `FI_RESET,
							   FI_EXECUTE,
							   FI_ACCEPT,
							   FI_CANCEL,
							   VS_K_slAliasField,
							   VS_K_slInputField` );
			if( me->fileForm ) FIf_display( me->fileForm ) ;
		} else {
			if( me->state != _locateInput ) {
				/*
				 * Form was erased for locates, do not redisplay
				 * it upon wakeup.
				 */
				FIf_display( mform ) ;
				if( kform ) FIf_display( kform ) ;
				if( me->fileForm ) FIf_display( me->fileForm ) ;
			}
		}
	} else {
		if( me->state == _getProgram ||
		    me->state == _readFile   ||
		    me->state == _writeFile ) {
			vs$g_disable_gadgets(	form	= mform,
						list	= `FI_RESET,
							   FI_EXECUTE,
							   FI_ACCEPT,
							   FI_CANCEL,
							   VS_K_slAliasField,
							   VS_K_slInputField` );
			if( me->fileForm ) FIf_erase( me->fileForm ) ;
		} else {
			FIf_erase( mform ) ;
			if( kform ) FIf_erase( kform ) ;
			if( me->fileForm ) FIf_erase( me->fileForm ) ;
		}
	}

	return OM_S_SUCCESS ;

} /* action TurnFormsOnOff */
/*----------------------------------------------------------------------------*/
action removeLastInput() {

	if( me->index >= 1 ) {
	  me->index-- ;

	  om$send( msg      = message VSlocateCmd.rmLastLocObjs( me->index ),
		   targetid = my_id ) ;
	  me->ret = VS_K_ACT_SUCCESS ;
	} else	me->ret = VS_K_CH_STATE ;

	return OM_S_SUCCESS ;

} /* action removeLastInput */
/*----------------------------------------------------------------------------*/
action storeInput( int putQ ) {

	long	sts ;

	SetProc( storeInput ) ; Begin

	sts = om$send(	msg	= message VSlocateCmd.addLocObj(
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				me->index ),
			targetid= my_id ) ;

	__DBGpr_obj( "Stored operand", me->event1.located_object[0].located_obj );
	__DBGpr_int( "At index", me->index ) ;

	if( !( sts & 1 ) ) { me->ret = VS_K_ABORT_CMD ; goto wrapup ; }
	me->index++ ;

	if( putQ ) {
		if( me->index < me->inputCount ) {
			long	size = sizeof( struct GRevent ) ;
			long	msg ;

			me->event1.num_id = 0 ;

			ex$putque(	msg	= &msg,
					response= me->response,
					byte	= &size,
					buffer	= (char *) &me->event1.event ) ;
			me->ret = VS_K_SAME_STATE ;
		} else	me->ret = VS_K_CH_STATE ;
	} else {
		me->ret = me->index < me->inputCount ? VS_K_SAME_STATE
						     : VS_K_CH_STATE ;
	}

	__DBGpr_int( "Input index", me->index ) ;
	__DBGpr_int( "me->ret", me->ret ) ;

	wrapup :
		End
		return OM_S_SUCCESS ;

} /* action storeInput */
/*----------------------------------------------------------------------------*/
action locatePrompt() {

	long	msgnum ;
	char	msg[MS_MAX_MSG_LENGTH] ;
	int	trunc ;

	switch( me->state ) {
		default			: msgnum = MS_NO_MSG	    ; break ;
		case _locateInput	: msgnum = VS_gP_IdGrInput  ; break ;
		case _getExpression	: msgnum = VS_gP_IdExpInput ; break ;
	}
	__DBGpr_int( "State", me->state ) ;

	ex$message(	msgnumb	= msgnum,
			type	= "%d%s",
			var	= `me->index, me->inputAlias[me->index]`,
			buff	= msg ) ;

	VSstrncpy( me->prompt, msg, _max_key, &trunc ) ;
	if( me->index < me->inputCount - 1 ) {

		int	next = me->index + 1 ;

		ex$message(	msgnumb	= VS_gP_AccWNxInput,
				type	= "%d%s",
				var	= `next, me->inputAlias[next]`,
				buff	= msg ) ;

	} else {
		ex$message(	msgnumb	= VS_gP_AccRej,
				buff	= msg ) ;
	}
	VSstrncpy( me->acc_prompt, msg, _max_key, &trunc ) ;

	return OM_S_SUCCESS ;

} /* action locatePrompt */
/*----------------------------------------------------------------------------*/
action resetCmd() {
	char	*form = me->forms[0].form_ptr ;

	me->interactiveKeyIn	= TRUE ;
	me->inputCount		= 0 ;
	me->index		= 0 ;
	me->programRow		= -1;
	me->programChar		= 0 ;
	strcpy( me->tempBsNm, "SLC1" ) ;

	if( me->stvisrows ) {
		/*
		 * Keyboard button and statements field have been moved around:
		 * put them back to their original locations.
		 */
		vs$g_erase_gadgets(	form	= form,
					list	= `VS_K_slKyBoardBtn,
					   	   VS_K_slStmntField` ) ;

		FIg_set_location( form, VS_K_slKyBoardBtn, me->kbx, me->kby ) ;
		FIg_set_location( form, VS_K_slStmntField, me->stx, me->sty ) ;
		FIfld_set_num_vis_rows( form, VS_K_slStmntField, me->stvisrows ) ;

		vs$g_display_gadgets(	form	= form,
					list	= `VS_K_slKyBoardBtn,
					   	   VS_K_slStmntField` ) ;
		me->stvisrows = 0 ;
	}
	VSfld_restart( form, VS_K_slAliasField ) ;
	FIg_reset( form, VS_K_slStmntField ) ;
	vs$g_disable_gadgets(	form	= form,
				list	= `VS_K_slStmntField,
					   VS_K_slInputGroup,
					   VS_K_slWritFilBtn,
					   VS_K_slKyBoardBtn` ) ;
	vs$g_enable_gadgets(	form	= form,
				list	= `VS_K_slReadFilBtn` ) ;

	VSg_chg_attr( form, VS_K_slAliasField, FI_CLEAR_ON_SELECTION, 0 ) ;
	FIfld_set_mode( form, VS_K_slInputField, 0, FI_SINGLE_SELECT ) ;

	if( me->keyboardForm ) {
		FIf_delete( me->keyboardForm ) ; me->keyboardForm = NULL ;
	}
	if( me->fileForm ) {
		FIf_delete( me->fileForm ) ; me->fileForm = NULL ;
	}
	return OM_S_SUCCESS ;

} /* action resetCmd */
/*----------------------------------------------------------------------------*/
action aliasFieldOnly() {
	char	*form = me->forms[0].form_ptr,
		buf[30+VS_K_tokMAX_SIZE] ;
	int	sel,
		pos,
		row ;

	vs$g_disable_gadgets(	form	= form,
				list	= `VS_K_slStmntField,
					   VS_K_slKyBoardBtn,
					   VS_K_slInputGroup,
					   VS_K_slWritFilBtn,
					   VS_K_slInputField` ) ;

	/*
	 * Print alias to modify to form's message filed.
	 */
	FIfld_get_active_row(	form,
			  	VS_K_slInputField,
			  	&row,
			  	&pos ) ;
	FIfld_get_text(	form,
			VS_K_slInputField,
			row, 0,
			sizeof buf,
			(unsigned char *) buf,
			&sel, &pos ) ;

	VSfi_msg( form, buf ) ;

	VSfld_restart( form, VS_K_slAliasField ) ;

	__DBGpr_int( "Want alias for", row ) ;

	ex$message(	msgnumb	= VS_gP_KyInAlias,
			type	= "%d",
			var	= `row`,
			buff	= buf ) ;

	VSfi_prompt( form, buf ) ;

	if( me->state == _modAliasFromProgram ) {
		VSfld_get_cursor(	form,
					VS_K_slStmntField,
					&me->programRow,
					&me->programChar ) ;
	}
	return OM_S_SUCCESS ;

} /* aliasFieldOnly */
/*----------------------------------------------------------------------------*/
action formPromptAlias() {

	char	prompt[MS_MAX_MSG_LENGTH],
		*form = me->forms[0].form_ptr ;

	__DBGpr_int( "Want alias for", me->inputCount ) ;

	FIg_enable( form, VS_K_slInputField ) ;

	ex$message(	msgnumb	= VS_gP_KyInAlias,
			type	= "%d",
			var	= `me->inputCount`,
			buff	= prompt ) ;

	VSfi_prompt( form, prompt ) ;

	return OM_S_SUCCESS ;

} /* action formPromptAlias */
/*----------------------------------------------------------------------------*/
action formPromptProgram() {

	char	prompt[MS_MAX_MSG_LENGTH],
		*form = me->forms[0].form_ptr ;

	me->index = 0 ;

	FIg_erase( form, VS_K_slAliasField ) ;
	vs$g_enable_gadgets(	form	= form,
				list	= `VS_K_slStmntField,
					   VS_K_slKyBoardBtn,
					   VS_K_slInputGroup,
					   VS_K_slWritFilBtn,
					   VS_K_slInputField` ) ;

	vs$g_disable_gadgets(	form	= form,
				list	= `VS_K_slReadFilBtn` ) ;

	ex$message(	msgnumb	= VS_gP_KyInProgram,
			buff	= prompt ) ;

	VSfi_prompt( form, prompt ) ;

	if( me->programRow == -1 ) {
		FIfld_set_num_rows( form, VS_K_slStmntField, 1 ) ;
		FIfld_set_text( form, VS_K_slStmntField, 0, 0, "", FALSE ) ;
		me->programRow = 0 ;
	}
	VSfld_set_cursor( form, VS_K_slStmntField, me->programRow, me->programChar ) ;
	return OM_S_SUCCESS ;

} /* action formPromptProgram */
/*----------------------------------------------------------------------------*/
action constructSelector() {

	long			sts,
				msg ;
	struct GRobj_env	parents[VS_K_MAX_INPUT] ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;
	char			*program,
				*iprogram ;
	extern OMuword		OPP_VSselector_class_id ;
	GRname			basename,
				fullname ;
	int			isWritable,
				dirInModel ;

	SetProc( constructSelector ) ; Begin ;

	program = iprogram = NULL ;

	/*
	 * Get parents.
	 */
	__DBGpr_int( "Parent count", me->inputCount ) ;
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						&msg,
						me->inputCount,
						parents ),
				targetid= my_id ) ;
	__CheckRC( sts, msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	vs$cnstDefaults(	msg	= &msg,
				symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;

	/*
	 * Get current directory (if usable) to name constructed selector.
	 */
	di$pwd( dirname = me->Cwd ) ;

	vs$isDirUsable(	dirname	= me->Cwd,
			inModel	= &dirInModel,
			writable= &isWritable ) ;

	if( dirInModel && isWritable ) {
		VSbuildName( &msg, me->Cwd, me->tempBsNm, basename ) ;
		DIstmcpy( fullname, me->Cwd, basename, NULL ) ;
	} else {
		*fullname = '\0' ;
	}

	vs$fill_cnst_list(
		Cnst_list	= cst,
		Msg		= &msg,
		Env_info	= &me->cstEnv,
		Display		= &me->ActiveDisplay,
		Level		= me->ActiveLevel,
		Name		= fullname,
		Class_attr	= &attr ) ;

	attr.parent_count	= me->index ;
	attr.parent_list	= parents ;

	program			= VSgetProgramBuffer( me->forms[0].form_ptr ) ;
	if( !program ) {
		__DBGpr_com( "No mem for program" ) ;
		msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}
	/*
	 * Translate program text from local language to internal language.
	 */
	vs$transToInternal(	msg		= &msg,
				extProgram	= program,
				p_intProgram	= &iprogram ) ;

	if( !( msg & 1 ) ) {
		__DBGpr_com( "No mem for translated program" ) ;
		goto wrapup ;
	}
	attr.feature_att	= iprogram ;
	attr.representation	= AC_NO_REP ;

	/*
	 * Construct object.
	 */
	me->constructedObject.osnum = me->cstEnv._MD_OS ;

	__DBGpr_com( "om$construct/GRconstruct" ) ;
	msg = EMS_E_OMerror ;

	sts = om$construct(
			classid	= OPP_VSselector_class_id,
			osnum	= me->cstEnv._MD_OS,
			p_objid	= &me->constructedObject.objid,
			msg	= message GRgraphics.GRconstruct( &cst ) ) ;

	if( sts & 1 & msg ) {
		if( *fullname ) {
			ex$message(	msgnumb	= VS_gI_CreatedObj,
					type	= "%s",
					var	= `basename` ) ;
		}	
		vs$bulk_display( grids = &me->constructedObject,
				 theEnv= &me->cstEnv ) ;
	}
	wrapup :
		_FREE( program ) ; _FREE( iprogram ) ;

		if( !( msg & 1 ) ) {
			msg = VSgetMsgKey( msg ) ;
			ex$message(	msgnumb		= msg,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					time		= 2 ) ;
		}
	
		End
		return OM_S_SUCCESS ;

} /* action constructSelector */
/*----------------------------------------------------------------------------*/
action keyboardNotification( char *form_ptr ; int gadget_label ) {

	long	msg ;
	char	*parentForm = me->forms[0].form_ptr,
		text[MS_MAX_MSG_LENGTH],
		*delWord ;
	int	rowoffset,
		chroffset,
		rowDeleted ;

	VSfld_get_cursor(	parentForm,
				VS_K_slStmntField,
				&me->programRow,
				&me->programChar ) ;

  	switch( gadget_label ) {

	case FI_CANCEL		:
	/*----------------------*/
	om$send(msg	= message VSlocateCmd.stop_dynamics_in_form(
						&msg, me->keyboardForm ),
		targetid= my_id ) ;

	FIf_delete( me->keyboardForm ) ;
	me->keyboardForm = NULL ;
	FIg_enable( parentForm, VS_K_slKyBoardBtn ) ;
	FIg_set_state_off( parentForm, VS_K_slKyBoardBtn ) ;
	break ;

	case VS_K_slIFbtn	: case VS_K_slTHENbtn	: 
	case VS_K_slELSEbtn	: case VS_K_slENDIFbtn	:
	case VS_K_slOUTPUTbtn	: case VS_K_slBEAMbtn	:
	case VS_K_slPLATEbtn	: case VS_K_slANDbtn	:
	case VS_K_slORbtn	: case VS_K_slNOTbtn	:
	case VS_K_slEQbtn	: case VS_K_slNEbtn	:
	case VS_K_slLEbtn	: case VS_K_slLTbtn	:
	case VS_K_slCOLONbtn	: case VS_K_slGEbtn	:
	case VS_K_slGTbtn	: case VS_K_slQUOTEbtn	:
	case VS_K_slLPARbtn	: case VS_K_slRPARbtn	:

		FIg_get_text( form_ptr, gadget_label, text ) ;
		strcat( text, " " ) ;
		rowoffset = 0 ; chroffset = strlen( text ) ;
		VSfld_insert_text(	parentForm,
					VS_K_slStmntField,
					me->programRow,
					0,
					me->programChar,
					text ) ;

		goto POSCURSOR ;

	default			:
	/*----------------------*/
		__DBGpr_int( "Kb label", gadget_label ) ;
		chroffset = rowoffset = 0 ;
		goto POSCURSOR ;

	case VS_K_slDELWORDbtn	:
	/*----------------------*/
		VSfld_delete_word(	parentForm,
					VS_K_slStmntField,
					me->programRow,
					0,
					me->programChar,
					&rowDeleted,
					&delWord ) ;
		chroffset = 0 ;
		__DBGpr_int( "Row deleted ?", rowDeleted ) ;

		if( rowDeleted ) {
			if( me->programRow > 0 )	rowoffset = -1 ;
			else				rowoffset = 0 ;
		} else {
			rowoffset = 0 ;
		}
		if( delWord ) {
			__DBGpr_str( "Deleted word", delWord ) ;
			om$vla_set_dimension(
				varray	= me->delWord,
				size	= 1 + strlen( delWord ) ) ;
			strcpy( me->delWord, delWord ) ;
			_FREE( delWord ) ;
		} 
		goto POSCURSOR ;

	case VS_K_slPASTEbtn	:
	/*----------------------*/
		if( om$dimension_of( varray = me->delWord ) ) {
			__DBGpr_str( "Pasting word", me->delWord ) ;
			VSfld_insert_text(	parentForm,
						VS_K_slStmntField,
						me->programRow,
						0,
						me->programChar,
						me->delWord ) ;
			chroffset = strlen( me->delWord ) ;
		} else	chroffset = 0 ;
		rowoffset = 0 ;
		goto POSCURSOR ;

	case VS_K_slBLANKbtn	:
	/*----------------------*/
		VSfld_insert_text(	parentForm,
					VS_K_slStmntField,
					me->programRow,
					0,
					me->programChar,
					" " ) ;
		rowoffset = 0 ; chroffset = 1 ;
		goto POSCURSOR ;

	case VS_K_slCRbtn	:
	/*----------------------*/
		VSfld_insert_newline(	parentForm,
					VS_K_slStmntField,
					me->programRow ) ;
		rowoffset = 1 ;
		chroffset = -1 ;

	POSCURSOR :
	if( chroffset == -1 )	me->programChar = 0 ;
	else			me->programChar += chroffset ;
	me->programRow += rowoffset ;

	__DBGpr_int( "New row", me->programRow ) ;
	__DBGpr_int( "New chr", me->programChar ) ;

	VSfld_set_cursor( parentForm, VS_K_slStmntField, me->programRow, me->programChar ) ;

	FIg_set_state_off( form_ptr, gadget_label ) ;
	break ;
	
	}

	return OM_S_SUCCESS ;

} /* keyboardNotification */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
action form_notification {

	long	msg ;
	int	backToAliasField = FALSE ;
	int	sel,
		pos,
		offset,
		numrows,
		putQ = FALSE ;
	char	buf[30+VS_K_tokMAX_SIZE] ;
	int     actRow, actChr,  position = 0 ;

	SetProc( VSselectCmd_form_notification ) ; Begin

	__DBGpr_int( "Form label", form_label ) ;
	__DBGpr_int( "Gadget label", gadget_label ) ;

  if( form_label == VS_K_slKyBoardBtn ) {

	om$send(msg	= message VSselectCmd.keyboardNotification(
						form_ptr, gadget_label ),
		targetid= my_id ) ;
  } else {
	/*
	 * Clear prompt and message fields.
	 */
	VSfi_msg	( form_ptr, "" ) ;
	VSfi_prompt	( form_ptr, "" ) ;

  	switch( gadget_label ) {

	case FI_RESET		:
	/*----------------------*/
	sel = EX_RESTART ;
	ex$putque( msg = &msg, response = &sel ) ; putQ = TRUE ;
	break ;

	case VS_K_slCopyFldBtn	:
	/*----------------------*/
	VSf_CopyFromForm( form_ptr ) ;
	break ;

	case VS_K_slPsteFldBtn	:
	/*----------------------*/
	VSf_PasteToForm( form_ptr ) ;
	break ;

	case FI_EXECUTE 	:
	case FI_ACCEPT		:
	/*----------------------*/

	if( me->state == _getProgram ) {
		char		*program,
				*iprogram ;
		int		rc ;
		VSparseErr	err ;

		__DBGpr_com( "Running program" ) ;
		program = VSgetProgramBuffer( form_ptr ) ;
		__DBGpr_str( "PROGRAM\n", program ) ;

		/*
		 * Translate program text from local language to internal
		 * language.
		 */
		vs$transToInternal(	msg		= &msg,
					extProgram	= program,
					p_intProgram	= &iprogram ) ;
		_FREE( program ) ;

		__DBGpr_int( "Input count", me->inputCount ) ;
		if( msg & 1 ) {

			if( me->interactiveKeyIn ) {
				rc = vs$checkSyntax(	error	= &err,
							program	= iprogram ) ;
			} else {
				int	count ;

				/*
				 * Aliases have not been input interactively:
				 * this means that the program was read from
				 * a file: get input aliases and count from
				 * the syntax checking routine.
				 */
				rc = vs$checkSyntax(
						error	= &err,
						program	= iprogram,
						count	= &count,
						aliases	= me->inputAlias ) ;
				me->inputCount = count ;
				__DBGpr_int( "Computed input count", me->inputCount ) ;
			}
			_FREE( iprogram ) ;

			if( !rc ) {
				char error[MS_MAX_MSG_LENGTH] ;

				if( me->interactiveKeyIn ) {
					if( err.lineno >= me->inputCount ) {
						err.lineno -= me->inputCount ;
					}	
				}
				VSslcOutputParsingError( &err, error ) ;
				VSfi_msg( form_ptr, error ) ;

				rc = VS_K_SAME_STATE ;
			} else {
				rc = VS_K_END_STATE ;
			}
		} else {
			rc = VS_K_SAME_STATE ;
		}
		ex$putque( msg = &msg, response = &rc ) ; putQ = TRUE ;

	}
	FIg_set_state( form_ptr, gadget_label, 0 ) ;
	break ;

	case FI_CANCEL		:
	/*----------------------*/

	__DBGpr_com( "TERMINATE" ) ;
	sel = TERMINATE ;
	ex$putque( msg = &msg, response = &sel ) ; putQ = TRUE ;
	break ;

	case VS_K_slAliasField	:
	/*----------------------*/
	
	FIfld_get_text(	form_ptr,
			VS_K_slAliasField,
			0, 0,
			VS_K_tokMAX_SIZE,
			(unsigned char*) buf,
			&sel, &pos ) ;
	__DBGpr_str( "Input", buf ) ;

	if( !isascii( *buf ) ) {
		/*
		 * A membrane key has been pushed during field read.
		 * Returned text contains garbage. Force cursor out of alias
		 * field or get-event will hang !.
		 */
		backToAliasField = FALSE ;
		break ;
	}
	__DBGpr_int( "My state", me->state ) ;
	if( me->state == _getInputAliases ) {
		int	redspPrompt = FALSE ;

		if( !*buf ) {
			__DBGpr_com( "No input" ) ;
			backToAliasField = redspPrompt = TRUE ;
		} else if( !strcmp( buf, "." ) ) {
			if( me->inputCount > 0 ) {
				sel = VS_K_END_STATE ;
				ex$putque( msg = &msg, response = &sel ) ;
				putQ = TRUE ;
				backToAliasField = FALSE ;
			} else {
				__DBGpr_com( "No input" ) ;
				redspPrompt = backToAliasField = TRUE ;
			}
		} else if( me->inputCount < VS_K_MAX_INPUT ) {

			/*
			 * Check that input is a valid identifier.
			 */
			if( !VSmatchREGEXP( "[a-zA-Z_][a-zA-Z_0-9]*", buf ) ) {
				char warning[MS_MAX_MSG_LENGTH] ;

				ex$message(	msgnumb	= VS_gI_InvAlias,
						type	= "%s",
						var	= `buf`,
						buff	= warning ) ;
				VSfi_msg( form_ptr, warning ) ;
				backToAliasField = TRUE ;
				break ;
			}
			
			strcpy( me->inputAlias[me->inputCount], buf ) ;

			sprintf( buf, "input %d = %s", me->inputCount,
				 me->inputAlias[me->inputCount] ) ;

			__DBGpr_str( "Buffer", buf ) ;

			VSfld_set_text_and_scroll(	form_ptr,
							VS_K_slInputField,
							me->inputCount,
							buf ) ;
			me->inputCount++ ;
			backToAliasField = TRUE ;

			sel = VS_K_SAME_STATE ;
			ex$putque( msg = &msg, response = &sel ) ;
			putQ = TRUE ;
		}
		if( me->inputCount == VS_K_MAX_INPUT ) {
				sel = VS_K_END_STATE ;
				ex$putque( msg = &msg, response = &sel ) ;
				putQ = TRUE ;
				backToAliasField = FALSE ;
		}
		if( redspPrompt ) {
			om$send(msg	= message VSselectCmd.formPromptAlias(),
				targetid= my_id ) ;
		}
	} else { /* STATE modAlias */
		int	row ;

		__DBGpr_com( "Modifying alias" ) ;
		FIfld_get_active_row(	form_ptr,
				  	VS_K_slInputField,
				  	&row,
				  	&pos ) ;
					  

		if( !*buf || !strcmp( buf, "." ) ) {
			/*
			 * Do nothing.
			 */
		} else {
			strcpy( me->inputAlias[row], buf ) ;
			sprintf( buf, "input %d = %s", row,
				 me->inputAlias[row] ) ;
			__DBGpr_str( "Buffer", buf ) ;
			VSfld_set_text_and_scroll(	form_ptr,
							VS_K_slInputField,
							row,
							buf ) ;
		}
		sel = VS_K_END_STATE ;
		ex$putque( msg = &msg, response = &sel ) ;
		putQ = TRUE ;
		backToAliasField = me->state == _modAliasFromInput ;
	}
	break ;

	case VS_K_slInputField	:
	/*----------------------*/
	sel = VS_K_CH_STATE ;
	ex$putque( msg = &msg, response = &sel ) ; putQ = TRUE ;
	break ;

	case VS_K_slKyBoardBtn	:
	/*----------------------*/

	if ( me->keyboardForm ) FIf_erase( me->keyboardForm ) ;	
	VSf_sub_form(	form_ptr,
			gadget_label,
			VS_K_KEYBOARD_FILE,
			&me->keyboardForm ) ;
	FIf_display( me->keyboardForm ) ;

	VSset_btn_texts( me->keyboardForm ) ;

	FIg_disable( form_ptr, gadget_label ) ;

	om$send(msg	= message VSlocateCmd.set_dynamics_in_form(
						&msg, me->keyboardForm ),
		targetid= my_id ) ;
	break ;

	case VS_K_slInputBtn_0	: pos = 0 ; goto INSERT_ALIAS ;
	case VS_K_slInputBtn_1	: pos = 1 ; goto INSERT_ALIAS ;
	case VS_K_slInputBtn_2	: pos = 2 ; goto INSERT_ALIAS ;
	case VS_K_slInputBtn_3	: pos = 3 ; goto INSERT_ALIAS ;
	case VS_K_slInputBtn_4	: pos = 4 ;
	/*----------------------*/

	INSERT_ALIAS		:
		FIfld_get_row_offset( form_ptr, VS_K_slInputField, &offset ) ;
		FIfld_get_num_rows  ( form_ptr, VS_K_slInputField, &numrows ) ;
		pos += offset ;
		if( pos < numrows && pos < me->inputCount ) {
			VSfld_get_cursor(	form_ptr,
						VS_K_slStmntField,
						&me->programRow,
						&me->programChar ) ;
			VSfld_insert_text(	form_ptr,
						VS_K_slStmntField,
						me->programRow,
						0,
						me->programChar,
						me->inputAlias[pos] ) ;
			offset = strlen( me->inputAlias[pos] ) ;
		} else	offset = 0 ;
		me->programChar += offset ;

		VSfld_set_cursor( form_ptr, VS_K_slStmntField,
				  me->programRow, me->programChar ) ;
		FIg_set_state_off( form_ptr, gadget_label ) ;
		break ;

	case VS_K_slReadFilBtn	:
	/*----------------------*/
		strcpy( me->fileInfo.openMode, "r" ) ;
		goto FILEFORM ;

	case VS_K_slWritFilBtn	:
	/*----------------------*/
		strcpy( me->fileInfo.openMode, "w" ) ;
	FILEFORM :
		me->fileInfo.callBack= NULL ;
		me->fileInfo.curPATH = curPATH ;
		me->fileInfo.curNAME = curNAME ;
		me->fileInfo.curRGXP = curRGXP ;
		if( !me->fileForm ) {
			int x, y ;

			FIf_get_location( form_ptr, &x, &y ) ;

			me->fileForm = VScreateFileForm(  x,
							  y,
							  &me->fileInfo ) ;
			if( !me->fileForm ) {
				__DBGpr_com( "Cannot create file form" ) ;
			} else {
				sel = VS_K_FILE_STARTED ;
				ex$putque( msg = &msg, response = &sel ) ;
				putQ = TRUE;
			}
		}
		break ;

	case VS_K_slStmntField :


		FIfld_get_num_rows (  form_ptr, VS_K_slStmntField, &actRow) ;
		FIfld_get_active_char(  form_ptr, VS_K_slStmntField, 0,
							&actChr, &position ) ;

		me->programRow  = actRow ;
		me->programChar = actChr;

		break;

	default			:
	/*----------------------*/
	 break ;

	} /* End of switch */

  } /* if form_label ... */

	if( backToAliasField ) {
		__DBGpr_com( "Restarting alias field" ) ;
		VSfld_restart( form_ptr, VS_K_slAliasField ) ;
	}
	if(    me->state == _getProgram
	    &&  (  (gadget_label == VS_K_slWritFilBtn && putQ)
	    	|| (gadget_label != VS_K_slWritFilBtn && !putQ))
	    && !( me->execFlags & VS_m_CmdStacked ) ) {
	    	sel = VS_K_DYN_MOUSE ;
		ex$putque( msg = &msg, response = &sel ) ;
	}
	if (gadget_label == VS_K_slWritFilBtn) sel = VS_K_FILE_STARTED;
	End
	return OM_S_SUCCESS ;

} /* action form_notification */
/*----------------------------------------------------------------------------*/
action initial_form_notification {


	VSf_storeCopyPasteInfo( form_ptr, gadget_label ) ;

	return OM_S_SUCCESS ;

} /* action initial_form_notification */
/*----------------------------------------------------------------------------*/
action arg_name_to_value {

	__DBGpr_str( "Class name", class_name ) ;
	__DBGpr_str( "Argument", arg ) ;

	if( *class_name ) {
		/*
		 * Argument starts with "me->".
		 */
		if( !strcmp( arg, "keyboardForm" ) ) {
			switch( addr_mode ) {
				case _COB_regular	:
					data->p   = me->keyboardForm ;
					*ret_type = _COB_arg_p ;
					*is_const = FALSE ;
					break ;

				case _COB_address	:
					data->p   = (char *) &me->keyboardForm ;
					*ret_type = _COB_arg_p ;
					*is_const = TRUE ;
					break ;

				default			:
					*ret_type = _COB_UNKNOWN_ARG ;
					break ;
			}
		} else {
			*ret_type = _COB_UNKNOWN_ARG ;
		}
	} else {
		*ret_type = _COB_UNKNOWN_ARG ;
	}
	if( *ret_type == _COB_UNKNOWN_ARG ) {
		om$send(msg	= message VSlocateCmd.arg_name_to_value(
								addr_mode,
								class_name,
								arg,
								data,
								ret_type,
								is_const ),
			targetid= my_id,
			mode	= OM_e_wrt_message ) ;
	}

	return OM_S_SUCCESS ;

} /* action arg_name_to_value */
/*----------------------------------------------------------------------------*/
action mouse( long *msg ; char *form ; int x, y ) {

	int	label ;
	char	buf[MS_MAX_MSG_LENGTH] ;


	if( FIf_find_gadget( form, FI_FORM_GROUP, x, y,
			     &label ) != FI_SUCCESS ) {
		goto wrapup ;
	}
	if( form == me->prevForm && label == me->prevLabel ) {
		goto wrapup ;
	}

	if( form == me->forms[0].form_ptr ) {
		int	pos,
			offst,
			nrows ;

		switch( label ) {

		case VS_K_slReadFilBtn	:
			ex$message(	msgnumb	= VS_gI_ReadFromFile,
					buff	= buf ) ;
			break ;

		case VS_K_slWritFilBtn	:
			ex$message(	msgnumb	= VS_gI_WriteToFile,
					buff	= buf ) ;
			break ;

		case VS_K_slPsteFldBtn	:
			ex$message(	msgnumb	= VS_gI_PasteFrClpbrd,
					buff	= buf ) ;
			break ;

		case VS_K_slCopyFldBtn	:
			ex$message(	msgnumb	= VS_gI_CpyToClpbrd,
					buff	= buf ) ;
			break ;

		case VS_K_slInputBtn_0	: pos = 0 ; goto FIND_ALIAS ;
		case VS_K_slInputBtn_1	: pos = 1 ; goto FIND_ALIAS ;
		case VS_K_slInputBtn_2	: pos = 2 ; goto FIND_ALIAS ;
		case VS_K_slInputBtn_3	: pos = 3 ; goto FIND_ALIAS ;
		case VS_K_slInputBtn_4	: pos = 4 ;
		FIND_ALIAS		:
			FIfld_get_row_offset( form, VS_K_slInputField, &offst );
			FIfld_get_num_rows  ( form, VS_K_slInputField, &nrows );

			if( pos < nrows && pos < me->inputCount ) {
				ex$message(	msgnumb	= VS_gI_InsAtCursor,
						type	= "%s",
						var	= `me->inputAlias[pos]`,
						buff	= buf ) ;
			} else {
				*buf = '\0' ;
			}
			break ;

		case VS_K_slKyBoardBtn	:
			ex$message(	msgnumb	= VS_gI_InvKbForm,
					buff	= buf ) ;
			break ;

		default			: *buf = '\0' ; break ;
		}

	} else if( form == me->keyboardForm ) {

		char	txt[MS_MAX_MSG_LENGTH] ;

		switch( label ) {

		case VS_K_slIFbtn	: case VS_K_slTHENbtn	:
		case VS_K_slELSEbtn	: case VS_K_slENDIFbtn	:
		case VS_K_slOUTPUTbtn	: case VS_K_slBEAMbtn	:
		case VS_K_slPLATEbtn	: case VS_K_slANDbtn	:
		case VS_K_slORbtn	: case VS_K_slNOTbtn	:
		case VS_K_slEQbtn	: case VS_K_slNEbtn	:
		case VS_K_slLEbtn	: case VS_K_slLTbtn	:
		case VS_K_slCOLONbtn	: case VS_K_slGEbtn	:
		case VS_K_slGTbtn	: case VS_K_slQUOTEbtn	:
		case VS_K_slLPARbtn	: case VS_K_slRPARbtn	:

			FIg_get_text( form, label, txt ) ;
			ex$message(	msgnumb	= VS_gI_InsAtCursor,
					type	= "%s",
					var	= `txt`,
					buff	= buf ) ;
			break ;

		case VS_K_slBLANKbtn	:
			ex$message(	msgnumb	= VS_gI_InsAtCursor,
					type	= "%s",
					var	= `" "`,
					buff	= buf ) ;
			break ;

		case VS_K_slDELWORDbtn	:
			ex$message(	msgnumb	= VS_gI_DelWAtCursor,
					buff	= buf ) ;
			break ;

		case VS_K_slPASTEbtn	:
			ex$message(	msgnumb	= VS_gI_PasteAtCursor,
					buff	= buf ) ;
			break ;

		case VS_K_slCRbtn	:
			ex$message(	msgnumb	= VS_gI_InsNLAtCursor,
					buff	= buf ) ;
			break ;

		default			:
			*buf = '\0' ; break ;
		}
	}

	me->prevForm = form ;
	me->prevLabel= label ;

	VSfi_msg( me->forms[0].form_ptr, buf ) ;

	wrapup :
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;

} /* action mouse */
/*----------------------------------------------------------------------------*/
