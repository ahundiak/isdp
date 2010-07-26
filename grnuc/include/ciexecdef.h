/*
 * Constants for C and PPL ci$exec/ci$run/ci$load macros defined in
 *	- ciexecmacros.h ( for C )
 *	- ciexec.h ( for PPL )
 * 
 * File dependency: none.
 * NOTE: for convenience, this file is automatically included in the two above.
 */
#ifndef CIEXECDEF_INCLUDE
#	define CIEXECDEF_INCLUDE

/* No load or clone requested */
#	define NO_LOAD		0

/* Load without condition, returns the CI object id. */
#	define LOAD_UNCOND	1

/* Return a model id or an error code if no model exists */
#	define RETRIEVE		2

/* Return a model id or load a new CI object when no model exists */
#	define LOAD		3

/* Load a model if necessary, clone a model, return the resulting object id. */
#	define DUP		4

/* Disable date comparison of PPL files */
#	define NO_DATE		64

#endif
