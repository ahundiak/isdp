/*
 * specification file for ci, the Command Interpreter of PPL files.
 * Etienne BEEKER
 * Intergraph Paris, France
 * HISTORY:
 * EB 23 Nov 87: The instructions can be shared by other ci files,
 *             : Fields "my_varvaltable", "my_info" added for clones.
 * EB 14 Jan 88: Field "loaded" added, when load is performed, set to "LOADED"
 */


class specification ci (1:2) of super_cmd;

#include "ci.h"

instance ci {
	/* Pointer to the code : data and text			*/
	struct instance_ci *data;	

	char **my_varvaltable;
	char *my_info;

	/* Runtime parameters */
	CIruntime	runparms	;

	/* Execution context :					*/
	CIprogseq	exec_ctx,
	/* For context save/restore :				*/
			save_ctx ;

};


/* PRIVATE MESSAGE
 * Loads an ASCII file into a OM object of class "ci".
 * IN  : filename, relative or absolute pathname of PPL file to load.
 *     : mode, LOAD, DUP, etc. as defined in ciexecdef.h
 * OUT : rc, pointer to completion code.
 */
message load(	int	*rc;
		char	*filename ;
		int	mode );

/* PRIVATE MESSAGE
 * Special message for cloning process.
 */
message load_s( int *rc );

/* PRIVATE MESSAGE
 * To store and restore the context.
 * This allows interruptions of PPL files.
 */
message save_context( int *rc );
message restore_context( int *rc );

/* PUBLIC MESSAGE
 * Sets ( action = EX_SET ) or inquires ( action = EX_INQ ) :
 * - command name
 * - command key
 * - command type
 * NOTE : that for action = EX_INQ, `cmd_key' must be a character array of
 * dimension >= 11, and `cmd_name' of dimension >= 53; for action = EX_SET
 * the command key will be truncated to 10 characters and the command name
 * to 52 characters.
 */
message cmd_info(char *cmd_name; char *cmd_key; int *mytype; int action);

/* PRIVATE MESSAGE
 * Specific treatement before a Root.delete()
 * - runs the user function "delete()" in the PPL file.
 * - deallocates the memory.
 */
message terminate( int *rc ) ;

/* PRIVATE MESSAGE
 * Makes arguments input on the command line available in the "main" function of
 * the PPL file.
 * OUT : rc, pointer to  completion code.
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 */
message setargs( char *arglist ) ;

/* PRIVATE MESSAGE
 * Gets the value returned by a PPL function.
 * IN  : fcnname	: name of the function.
 *     : retsize	: size of the returned value.
 * OUT : p_retval	: pointer to memory to store the returned val.
 * NOTE: nothing is done if retsize is 0 or p_retval is NULL.
 */
/*DLB added ifndef to fix ddp problem*/
#ifndef __DDP__ 
message get_fcn_val( char *fcnname ; void *p_retval ; int retsize ) ;
#endif
/* PUBLIC MESSAGE
 * Executes a portion of code corresponding to the function entry
 * NOTE: the function may not be interrupted by an event.
 * IN  : entry	: name of function to execute.
 *     : retsize: size of value returned by the function ( 0 if not needed )
 * OUT : retval	: pointer to value returned by function ( NULL if not needed )
 *     : rc	: pointer to completion code.
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 * 		CI_W_NO_SUCH_FUN : entry point not found.
 * 		CI_E_FATAL_ERROR : OM error during transaction.
 * NOTE : this message is interfaced by the macro:
 *				ci$f_execute
 * #omdef'd in ci/include/ciexecmacros.h.
 */
message f_execute( int *rc; char *entry; char *retval ; int retsize);

/* PUBLIC MESSAGE
 * Same as f_execute but the context is not saved
 * furthermore a pointer to some value is passed to be assigned to a special
 * variable ( performs a set_value )
 * NOTE: the function may not be interrupted by an event.
 * IN  : entry	: name of function to execute.
 *     : vname	: name of variable to set.
 *     : vvalue : pointer to value to assign.
 *     : vsize  : size of variable to set.
 *     : retsize: size of value returned by the function ( 0 if not needed )
 * OUT : retval	: pointer to value returned by function ( NULL if not needed )
 *     : rc	: pointer to completion code.
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 * 		CI_W_NO_SUCH_FUN : entry point not found.
 * 		CI_W_NO_SUCH_VAR : variable "vname" not found.
 * 		CI_E_FATAL_ERROR : OM error during transaction.
 * NOTE : this message is interfaced by the macro:
 *				ci$exec_fun
 * #omdef'd in ci/include/ciexecmacros.h.
 */
message exec_fun(	int *rc;
			char *entry  ;
			char *vname  ; char *vvalue ; int vsize ;
			char *retval ; int retsize );

/* PUBLIC MESSAGE
 * These 2 messages allow to change or get the value of a variable given its
 * name and a pointer to a value.
 * IN  : vname	: name of variable to set.
 *     : vvalue : pointer to value to assign.
 *     : size   : size of variable to set.
 * OUT : rc	: pointer to completion code ( NULL if not needed ).
 * VALUES OF *rc:
 * 		CI_S_SUCCESS	 : operation sucessfully completed.
 * 		CI_E_OBJCT_EMPTY : object not loaded with a file.
 * 		CI_W_NO_SUCH_VAR : variable "vname" not found.
 * NOTE : this messages are interfaced by the macros:
 *				ci$[gs]et_value
 * #omdef'd in ci/include/ciexecmacros.h.
 */
message get_value( int *rc; char *vname; char *vvalue; int size);
message set_value( int *rc; char *vname; char *vvalue; int size);

/* PUBLIC MESSAGE
 * Checks whether an entry point ( a PPL function ) exists or not in a loaded
 * PPL file.
 * IN  : entry : name of function.
 * OUT : rc    : pointer to completion code.
 * VALUES OF *rc :
 *		CI_S_SUCCESS	: entry point exists.
 *		CI_W_NO_SUCH_FUN: entry point does not exist.
 *		CI_E_OBJCT_EMPTY: the target ci is not loaded with a file.
 * NOTE : this message is interfaced by the macro:
 *				ci$is_entry_point
 * #omdef'd in ci/include/ciexecmacros.h.
 */
message is_entry_point( int *rc ; char *entry ) ;

/*
 * init: initializes the context, i.e. sets the program counter to the first
 * instruction of function entry and empties the stack.
 */
override init, execute, delete, wakeup, super_cmd.sleep, debug, form_input ;

end specification ci;
