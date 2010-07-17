/*
	I/STRUCT
*/
#include <stdlib.h>
#include "vsdrw.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsstrngproto.h"

struct variable {
	VStktxt		n ;	/* Name of variable		*/
	VSexecRes	r ;	/* Type and value of variable	*/
} ;
/*
 * Table of variables.
 */
static struct variable	*vrList	= NULL ;
/*
 * Count of variables and allocated size of table of variables.
 */
static short		vrCount	= 0,
			vrSize  = 0 ;
#define CHUNK	10
/*----------------------------------------------------------------------------*/
void VSdrwInitVarTable __(( void )) {

	/*
	 * We do not free the memory allocated for the table since:
	 * - the interpreter is likely to be invoked several times during
	 *   drawing extraction and we avoid reallocating.
	 * - there will likely be few variables used, hence we won't use up
	 *   too much space.
	 * If you want to free anyway, just add :
	 *	if( vrList ) {
	 *		free( char *) vrList ) ;
	 *		vrSize = 0 ;
	 *		vrList = NULL ;
	 *	}
	 * right below.
	 */
	vrCount	= 0 ;

} /* VSdrwInitVarTable */
/*----------------------------------------------------------------------------*/
static struct variable *VSdrwAddVar( n, init )

const char	*n ;
const VSexecRes *init ; {

	struct variable	*newvar = NULL ;

	/*
	 * Adds a new variable to the table, and if `init' is not NULL
	 * initializes it with this value. If `init' is NULL variable is
	 * initialized as a character string containing its own name.
	 * This function returns a pointer to the new table entry or NULL
	 * in case of memory allocation failure.
	 */
	if( vrCount + 1 < vrSize ) {
		newvar = vrList + vrCount ;
		vrCount++ ;
	} else {
		if( vrList ) {
			struct variable	*newptr ;

			newptr = (struct variable *)
					realloc( vrList,
					        ( vrCount + CHUNK )
					        * sizeof *newptr ) ;
			if( newptr ) {
				vrList = newptr ;
				vrSize += CHUNK ;
				newvar = vrList + vrCount ;
				vrCount++ ;
			}
							      
		} else {
			vrList = _MALLOC( CHUNK, struct variable ) ;
			if( vrList ) {
				vrSize		= CHUNK ;
				vrCount		= 1 ;
				newvar		= vrList + 0 ;
			}
		}
	}
	if( newvar ) {
		int	trunc ;

		VSstrncpy( newvar->n, n, VS_K_tokMAX_SIZE, &trunc ) ;

		if( init ) {

			newvar->r = *init ;

		} else {

			/*
			 * Initialize variable to its own name.
			 */
			newvar->r.type = VS_string ;
			VSstrncpy( newvar->r._sval, n, VS_K_tokMAX_SIZE,
				   &trunc ) ;
		}
	}
	return newvar ;

} /* VSdrwAddVar */
/*----------------------------------------------------------------------------*/
static struct variable *VSdrwGetVar( n ) const char *n ; {

	/*
	 * Finds variable that goes by name `n' in the table of variables.
	 * returns a pointer to the entry in the table if found, else NULL.
	 */
	int		i ;
	struct variable	*found = NULL ;

	/*
	 * There will likely be only a few variables, so a linear search will
	 * do.
	 */
	for( i = 0 ; i < vrCount ; i++ ) {

		if( !strcmp( n, vrList[i].n ) ) {
			found = vrList + i ;
		}
	}

	return found ;
		
} /* VSdrwGetVar */
/*----------------------------------------------------------------------------*/
void VSdrwGetVarVal( n, val ) const char *n ; VSexecRes *val ; {

	/*
	 * Returns the value of the variable of name `n'. If variable is not
	 * found in the table, creates a new one which will have its value
	 * initialized as a character string containing the name of the
	 * variable.
	 * The value of the variable is returned in `val'.
	 */
	struct variable	*var = VSdrwGetVar( n ) ;

	if( !var ) {
		if( var = VSdrwAddVar( n, (VSexecRes *) NULL ) ) {
			*val = var->r ;
		} else {
			/*
			 * Allocation failed: return integer 0 as value of
			 * variable.
			 */
		 	val->_ival	= 0 ;
		 	val->type	= VS_int ;
		}
	} else *val = var->r ;

} /* VSdrwGetVarVal */
/*----------------------------------------------------------------------------*/
void VSdrwSetVarVal( n, val ) const char *n ; const VSexecRes *val ; {

	/*
	 * Sets the value of variable of name `n', If variable does not exist
	 * then creates a new one and sets its value.
	 */
	struct variable	*var = VSdrwGetVar( n ) ;

	if( var ) {
		var->r = *val ;
	} else {
		(void) VSdrwAddVar( n, val ) ;
	}

} /* VSdrwSetVarVal */
/*----------------------------------------------------------------------------*/
