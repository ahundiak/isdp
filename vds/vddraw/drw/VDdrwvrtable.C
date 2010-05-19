/*
	I/VDS	Copy.
*/
#include <stdlib.h>
#include "v_drw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_strngproto.h"

struct VDvariable {
	VD_tktxt		n ;	/* Name of variable		*/
	VD_execRes	r ;	/* Type and value of variable	*/
} ;
/*
 * Table of variables.
 */
static struct VDvariable	*vrList	= NULL ;
/*
 * Count of variables and allocated size of table of variables.
 */
static short		vrCount	= 0,
			vrSize  = 0 ;
#define CHUNK	10
/*----------------------------------------------------------------------------*/
void VD_drwInitVarTable __(( void )) {

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

} /* VD_drwInitVarTable */
/*----------------------------------------------------------------------------*/
static struct VDvariable *VD_drwAddVar( n, init )

const char	*n ;
const VD_execRes *init ; {

	struct VDvariable	*newvar = NULL ;

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
			struct VDvariable	*newptr = NULL ;

			newptr = (struct VDvariable *)
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
			vrList = _MALLOC( CHUNK, struct VDvariable ) ;
			if( vrList ) {
				vrSize		= CHUNK ;
				vrCount		= 1 ;
				newvar		= vrList + 0 ;
			}
		}
	}
	if( newvar ) {
		int	trunc ;

		VD_strncpy( newvar->n, n, VD_K_tokMAX_SIZE, &trunc ) ;

		if( init ) {

			newvar->r = *init ;

		} else {

			/*
			 * Initialize variable to its own name.
			 */
			newvar->r.type = VD_string ;
			VD_strncpy( newvar->r._sval, n, VD_K_tokMAX_SIZE,
				   &trunc ) ;
		}
	}
	return newvar ;

} /* VD_drwAddVar */
/*----------------------------------------------------------------------------*/
static struct VDvariable *VD_drwGetVar( n ) const char *n ; {

	/*
	 * Finds variable that goes by name `n' in the table of variables.
	 * returns a pointer to the entry in the table if found, else NULL.
	 */
	int		i ;
	struct VDvariable	*found = NULL ;

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
		
} /* VD_drwGetVar */
/*----------------------------------------------------------------------------*/
void VD_drwGetVarVal( n, val ) const char *n ; VD_execRes *val ; {

	/*
	 * Returns the value of the variable of name `n'. If variable is not
	 * found in the table, creates a new one which will have its value
	 * initialized as a character string containing the name of the
	 * variable.
	 * The value of the variable is returned in `val'.
	 */
	struct VDvariable	*var = NULL ;

	var = VD_drwGetVar( n ) ;

	if( !var ) {
		if( var = VD_drwAddVar( n, (VD_execRes *) NULL ) ) {
			*val = var->r ;
		} else {
			/*
			 * Allocation failed: return integer 0 as value of
			 * variable.
			 */
		 	val->_ival	= 0 ;
		 	val->type	= VD_int ;
		}
	} else *val = var->r ;

} /* VD_drwGetVarVal */
/*----------------------------------------------------------------------------*/
void VD_drwSetVarVal( n, val ) const char *n ; const VD_execRes *val ; {

	/*
	 * Sets the value of variable of name `n', If variable does not exist
	 * then creates a new one and sets its value.
	 */
	struct VDvariable	*var = NULL ;

	var = VD_drwGetVar( n ) ;

	if( var ) {
		var->r = *val ;
	} else {
		(void) VD_drwAddVar( n, val ) ;
	}

} /* VD_drwSetVarVal */
/*----------------------------------------------------------------------------*/
