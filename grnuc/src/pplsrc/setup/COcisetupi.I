/* --
		Command Object for CI setup.
		Command key is "CIRvPPPr".
   -- */
class implementation COcisetup ;

#include "cisetup.h"
#include "cimsg.h"
#include "griomacros.h"

#define NUM_TOKENS 3
/*
 * States
 */
#define UNIC_STATE 0
#define NUM_STATES 1
/*
 * Actions
 */
#define ERR		0
#define EXIT		1
#define WAIT		2
/*----------------------------------------------------------------------------*/
method init( IGRint type ; IGRchar *string_ptr ) {

	ME.super_cmd->mytype		= type		;
	me^^COcisetup.action		= WAIT		;
	ME.super_cmd->state		= UNIC_STATE	;

	if( *CIcci_path == '\0' ) CIiniopt() ;

     	if( CIsu_wakeup( my_id, OM_Gw_current_OS, 1, &me^^super_cmd.form_id ) )
		me^^super_cmd.form_requested = TRUE	;
	else	me^^super_cmd.form_requested = FALSE	;
#ifdef DEBUG
  printf( "COcisetup.init: cmd_key  = <%s>\n", me^^super_cmd.cmd_key  ) ;
  printf( "COcisetup.init: cmd_name = <%s>\n", me^^super_cmd.cmd_name ) ;
#endif
	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method wakeup( IGRint pos ) {

/* --   Reactivate setup form.
   -- */
	if( me^^super_cmd.form_requested ) {
		CIsu_wakeup( my_id, OM_Gw_current_OS, 2,
					&me^^super_cmd.form_id ) ;
	}
	if( me^^super_cmd.mytype ) {
		ex$message( msgnumb = CI_P_suPROMPT ) ;
		ex$message( msgnumb = CM_M_suMTITLE ) ;
	}
	me^^COcisetup.action = WAIT ;

#ifdef DEBUG
  printf( "COcisetup.wakeup: cmd_key  = <%s>\n", me^^super_cmd.cmd_key  ) ;
  printf( "COcisetup.wakeup: cmd_name = <%s>\n", me^^super_cmd.cmd_name ) ;
#endif
	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method execute ( IGRint  *response	;
		 IGRchar *response_data	;
		 IGRint   pos		) {

  struct GRevent	event		; /* event from getevent	*/
  IGRlong		rc		; /* OM return code		*/
  IGRlong		resp		;
  IGRlong		size		; /* size of GRevent struct.	*/
  IGRlong		mask		; /* mask for input		*/



	mask 		= GRm_FORM_FINISHED ;
	size		= sizeof( struct GRevent ) ;
	*response	= TERMINATE	;

	mask =  	GRm_DATA
		|	GRm_RESET
		|	GRm_STRING
		|	GRm_BACK_UP
		|	GRm_MOVE_ON
		|	GRm_SPECIFIED_OBJ
		|	GRm_VALUE
		|	GRm_FORM_FINISHED ;


#ifdef DEBUG
  printf( "COcisetup: B4 co$getevent\n" ) ; fflush( stdout ) ;
#endif
  	co$getevent(	msg		= &rc,
                        event_mask	= mask,
                        response	= &resp, 
                        response_data	= response_data,
                        event		= &event ) ;

  	if( event.response == EX_FORM_FINISHED ) resp = TERMINATE ;
  	*response = resp ;
#ifdef DEBUG
  printf( "COcisetup.execute: EXIT(resp = %d)\n", *response ) ; fflush( stdout ) ;
#endif

 	 return OM_S_SUCCESS ;

} /* method execute */
/*----------------------------------------------------------------------------*/
method super_cmd.sleep( IGRint pos ) {

/* --	Tell set-up form to sleep if any then clear fields.
   -- */
#ifdef DEBUG
   printf( "COcisetup.sleep: ENTER" ) ; fflush( stdout ) ;
#endif
	if( me^^super_cmd.form_requested ) {
		CIsu_sleep( me^^super_cmd.form_id ) ;
	}
	ex$message(	field	= PROMPT_FIELD	,
			in_buff	= ""		) ;
	ex$message(	field	= MESSAGE_FIELD	,
			in_buff	= ""		) ;

#ifdef DEBUG
   printf( "COcisetup.sleep: EXIT" ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int n ) {
	int sts ;

#ifdef DEBUG
   printf( "COcisetup.delete: ENTER" ) ; fflush( stdout ) ;
#endif
/* --	Delete set-up form if any.
   -- */
	if( me^^super_cmd.form_requested )
		CIsu_delete( me^^super_cmd.form_id ) ;

        /* delete self */
	sts = om$send(	msg	 = message Root.delete( n )	,
			mode	 = OM_e_wrt_message		,
			targetid = my_id			) ;

#ifdef DEBUG
   printf( "COcisetup.delete: EXIT" ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
end implementation COcisetup ;
