/*
 * ciforms.I
 *
 * Contains the methods used by ci, the command interpreter
 * when interfaced with the FORMS subsystem
 *
 * Etienne BEEKER
 * creation: 05/22/87
 * 
 */
class implementation ci;

#include "FI.h"
#include "cimsg.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "ciexecmacros.h"
#include "cisetup.h"


method form_input ( int form_label; char *value )

/*
 * This method has the only purpose of calling a function named called
 *				 "form_input"
 * in the PPL file in order to execute some code written by the user.
 * Seeing that CI function didn't admit parameters before, 2 reserved variables
 * are stiil used to pass them:
 *	int			form_label
 *	struct  FI_X_data_st	*form_data
 * The two variables above are also passed as arguments to the "form_input"
 * function.
 */
{
	int		flag,		/* Action for ci$f_execute	*/
			OMrc,		/* OM return code		*/
			CIsts ;		/* CI completion code		*/
	CIpushlist	FIargs[2] ;	/* List of args to be pushed	*/

#ifdef DEBUG
  printf( "ci.form_input enter label %d my_id %d\n", form_label, my_id ) ;
#endif
/* -- 	Intercept form_inputs for the CI Runtime Error form.
   -- */
	if( CIcci_form_process  (form_label, (struct FI_X_data_st *)value) ||
	    CIerror_form_process (form_label, (struct FI_X_data_st *)value)   )
			goto WRAPUP ;
	/* Else it was not the error form: go on ... */

	ci$is_entry_point(	stat	= &CIsts,
				file	= my_id,
				entry	= "form_input" ) ;
	switch( CIsts ) {
	   case CI_E_OBJCT_EMPTY : CIprog_error( CIsts,
						 "method ci.form_input" ) ;
	   case CI_W_NO_SUCH_FUN : goto WRAPUP ;
	   case CI_S_SUCCESS	 : break ;
	}

	ci$set_value(	name	= "form_label",
			p_val	= &form_label ,
			file	= my_id		) ;

	ci$set_value(	name	= "form_data",
			p_val	= &value,
			file	= my_id		) ;
	
	/* Push arguments onto the stack for `form_input' */
	FIargs[0].addr = &form_label		;
	FIargs[0].size = sizeof form_label 	;
	FIargs[1].addr = &value			;
	FIargs[1].size = sizeof value 		;

	ci$push( argc = 2, argv = FIargs ) ;
	

	/* Executes function `form_input' if one exists */
	flag = 0;
	OMrc = ci$f_execute(	file	= my_id,
				entry	= "form_input",
				action	= &flag ) ;
	if( OMrc != OM_S_SUCCESS ) {
		ci$om_failed(	sts	= OMrc,
				text	= "ci.form_input -> ci.f_execute" ) ;
	}

	WRAPUP :
	return OM_S_SUCCESS ;
}

end implementation ci;
