class implementation ci ;

#include <string.h>
#include "ci.h"
#include "exmacros.h"
#include "grdpbmacros.h"
/*----------------------------------------------------------------------------*/
method setargs( char *arglist ) {

/* -- Splits argument list passed to the CI command:
		CI = <filename> <arg1> <arg2> ... <argn>
      Store argument string and pointers to arguments in instance data.
      Push argument count and argument array onto the PPL function stack so
      that the main function in the file can access them.
      NOTE: for safety's sake, this method must be invoked just before the
      ci.execute message is send from COci to ci.
   -- */
#define MY_ARGS ( ( (ci_IGE *) (me^^ci.data->info) )->args )

	int			argc		; /* Count of user args + 1 */
	unsigned		Transferred	, /* Bytes transferred	    */
				Received	; /* Butes received	    */
	char			*p, *s, **argv	; /* Auxilliary pointer	    */
	void			**env		; /*  variables		    */
	CIpushlist 		main_args[3]	; /* For ci$push	    */
	struct EX_var_list	globals[2]	; /* For ex$global	    */
	int			status		; /* Everybody's ret. status*/

	strncpy( MY_ARGS.str, arglist, CI_MAX_ARGSTRING ) ;
	MY_ARGS.str[CI_MAX_ARGSTRING] = '\0' ;
#ifdef DEBUG
 printf( "ci.setargs: arglist <%s>\n", MY_ARGS.str ) ;
#endif
	argc = 0 ;
/* --	Argument #0 is the file name.
   --	*/
	MY_ARGS.ptr[argc++] = strcpy( MY_ARGS.ppl, me^^ci.data->ficcmd ) ;

	s = MY_ARGS.str ;
	while( ( p = strtok( s, " \t" ) ) != NULL && argc < CI_MAX_ARGS ) {
		MY_ARGS.ptr[argc++] = p ;
		s = NULL ;
	}
#ifdef DEBUG
 printf( "ci.setargs: argc %d\n", argc ) ;
#endif
/* --	Get master file name.
   -- */
   	Transferred		= sizeof MY_ARGS.dgn	;
	globals[0].var		= EX_CUR_FILENAME	;
	globals[0].var_value	= MY_ARGS.dgn		;
	globals[0].num_bytes	= (int *)&Transferred		;
	globals[1].var		= EX_END_PARAM		;

	ex$global(	var		= globals	,
			which_error	= &status	) ;
/* --   Get command name and key.
   -- */
	om$send( msg	  = message ci.cmd_info( MY_ARGS.cmd	,
						 MY_ARGS.key	,
						 &status	,
						 EX_INQ		),
		 targetid = my_id ) ;
/* --	Get current module environment.
   -- */
	Transferred	= sizeof MY_ARGS.mod	;
	gr$get_module_env(	msg	= &status	,
				sizbuf	= &Transferred	,
				buffer	= &MY_ARGS.mod	,
				nret	= &Received	) ;
/* -- Fill `environment' pointer.
	0 : command name.
	1 : command key.
	2 : master file name.
	4 : module environment.
	End with NULL.
   -- */
	MY_ARGS.env[0] = MY_ARGS.cmd	;
	MY_ARGS.env[1] = MY_ARGS.key	;
	MY_ARGS.env[2] = MY_ARGS.dgn	;
	MY_ARGS.env[3] = &MY_ARGS.mod	;
	MY_ARGS.env[4] = NULL		;

/* -- Push onto PPL function stack:
	1 : Count of arguments.
	2 : Array of pointer to arguments.
	3 : Array of pointers to `environment'.
   -- */
	argv	= MY_ARGS.ptr ;
	env	= MY_ARGS.env ;
	main_args[0].addr = &argc		;
	main_args[0].size = sizeof argc		;
	main_args[1].addr = &argv		;
	main_args[1].size = sizeof argv		;
	main_args[2].addr = &env		;
	main_args[2].size = sizeof env		;

	ci$push(	argc	= 3		,
			argv	= main_args	) ;

	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
end implementation  ci ;

