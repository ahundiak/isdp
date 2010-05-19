/*
	I/VDS	Copy
*/
#include <stdlib.h>
#include "v_drw.h"
#include "v_miscmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_lngopproto.h"
/*----------------------------------------------------------------------------*/
struct VD_MemoryForArrays {
	VD_execRes			*array ;
	unsigned			count ;
	struct VD_MemoryForArrays	*next ;
} ;
static struct VD_MemoryForArrays *pVD_MemoryForArrays = NULL ;
/*----------------------------------------------------------------------------*/
VD_execRes *VD_drwAryMalloc( unsigned countOfElements ) {

  struct VD_MemoryForArrays	*pM = NULL ;
  VD_execRes			*pA = NULL ;

  pM = _MALLOC( 1, struct VD_MemoryForArrays ) ;
  pA = _MALLOC( countOfElements, VD_execRes) ;

  if( pM && pA ) {
    pM->array		= pA ;
    pM->count		= countOfElements ;
    pM->next		= pVD_MemoryForArrays ;
    pVD_MemoryForArrays	= pM ;
  } else {
	_FREE( pM ) ;
	_FREE( pA ) ;
	pM = NULL ;
	pA = NULL ;
  }
  return pA ;

} /* VD_drwAryMalloc */
/*----------------------------------------------------------------------------*/
void VD_drwFreeMemoryForArrays( void ) {

	struct VD_MemoryForArrays *pM = NULL ;

	pM = pVD_MemoryForArrays ;

	while( pM ) {
		struct VD_MemoryForArrays *next = pM->next ;
		_FREE( pM->array ) ;
		_FREE( pM ) ;
		pM = next ;
	}
	pVD_MemoryForArrays = NULL ;

} /* VD_drwFreeMemoryForArrays */
/*----------------------------------------------------------------------------*/
void VD_drwGetAryVal( const char *n, const VD_execRes *index, VD_execRes *val ) {

	/* Fetches element at some index in an array given by name. If the
	 * variable is not an array, returns the value of the variable itself.
	 * If the index is invalid, returns 0.
	 */
	VD_execRes ary ;

	VD_drwGetVarVal( n, &ary ) ;

	*val = *VD_getAryElm( &ary, VD_drwIntVal( index ) ) ;

} /* VD_drwGetAryVal */
/*----------------------------------------------------------------------------*/


