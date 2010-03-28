#include <stdio.h>
#include "ciinclude.h"
#include "ciexecmacros.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "cimsg.h"

extern char *CIexmessage() ;
/*----------------------------------------------------------------------------*/
typedef struct	{
	char		*locfile , /* Name of PPL file containing handler */
			*locfunc ; /* Name of handler function		  */
	OM_S_OBJID	*locciid ; /* Object id of ci running PPL file	  */
	void		*usrargs ; /* User arguments passed to handler	  */
	long		pplexrc	 ; /* Completion code of PPLdynamics	  */
} CIlocargs ;
/*----------------------------------------------------------------------------*/
int PPLlocate_act( act_parms, new_entry, locate_args, action )


CIlocargs		*act_parms	; /* Args for selection criteria */
struct GRlc_info	*new_entry	; /* Graphic object info	 */
struct LC_action_args	*locate_args	;
char			*action		;

{
	int		LCrc	;	/* Return code of locate handler */
	CIerror_msg	msg	;	/* Buffer for error message	 */
	CIpushlist	args[4] ;	/* Args to pass to PPL handler	 */

	if( !ci$load(	file_name	= act_parms->locfile,
			file_id		= &act_parms->locciid,
			sender_id	= NULL_OBJID,
			stat		= &act_parms->pplexrc ) ) {
		goto ERROR ;
	} else {
/* --		Push arguments onto the stack for PPL locate handler.
   -- */
		args[0].addr = &act_parms->usrargs	; /* Arg #1 */
		args[0].size = sizeof act_parms->usrargs;
		args[1].addr = &new_entry		; /* Arg #2 */
		args[1].size = sizeof new_entry		;
		args[2].addr = &locate_args		; /* Arg #3 */
		args[2].size = sizeof locate_args 	;
		args[3].addr = &action			; /* Arg #4 */
		args[3].size = sizeof action		;
		
		ci$push( argc = 4, argv = args ) ;

		if( !ci$run(	file_id		= &act_parms->locciid,
				entry		= act_parms->locfunc,
				delete		= TRUE,
				retval		= &LCrc,
				retsize		= sizeof LCrc,
				sender_id	= NULL_OBJID,
				stat		= &act_parms->pplexrc ) ) {
			ERROR :
			ci$report_error(	status = act_parms->pplexrc,
						buffer = msg	) ;
			fprintf( stderr, "%s: locate handler %s\n\t-> %s\n",
			 	CIexmessage( CI_I_ciCMLGEX ), act_parms->locfile, msg ) ;
			fflush( stderr ) ;
			LCrc = LC_UNKNOWN_TYPE ;
		}
	}

	return LCrc ;
	
} /* PPLlocate_act */
/*----------------------------------------------------------------------------*/

