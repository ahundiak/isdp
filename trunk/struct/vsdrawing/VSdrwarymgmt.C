/*
	I/STRUCT
*/
#include <stdlib.h>
#include "vsdrw.h"
#include "vsmiscmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vslngopproto.h"
/*----------------------------------------------------------------------------*/
struct MemoryForArrays {
	VSexecRes		*array ;
	unsigned		count ;
	struct MemoryForArrays	*next ;
} ;
static struct MemoryForArrays *pMemoryForArrays = NULL ;
/*----------------------------------------------------------------------------*/
VSexecRes *VSdrwAryMalloc( unsigned countOfElements ) {

  struct MemoryForArrays *pM = NULL ;
  VSexecRes 		 *pA = NULL ;

  if( !countOfElements ) return pA ;

  pM = _MALLOC( 1, struct MemoryForArrays ) ;
  pA = _MALLOC( countOfElements, VSexecRes) ;

  if( pM && pA ) {
    pM->array		= pA ;
    pM->count		= countOfElements ;
    pM->next		= pMemoryForArrays ;
    pMemoryForArrays	= pM ;
  } else {
    _FREE( pM ) ; _FREE( pA ) ; pM = NULL ;
  }
  return pA ;

} /* VSdrwAryMalloc */
/*----------------------------------------------------------------------------*/
void VSdrwFreeMemoryForArrays( void ) {

	struct MemoryForArrays *pM = pMemoryForArrays ;

	while( pM ) {
		struct MemoryForArrays *next = pM->next ;
		_FREE( pM->array ) ;
		free( pM ) ;
		pM = next ;
	}
	pMemoryForArrays = NULL ;

} /* VSdrwFreeMemoryForArrays */
/*----------------------------------------------------------------------------*/
void VSdrwGetAryVal( const char *n, const VSexecRes *index, VSexecRes *val ) {

	/* Fetches element at some index in an array given by name. If the
	 * variable is not an array, returns the value of the variable itself.
	 * If the index is invalid, returns 0.
	 */
	VSexecRes ary ;

	VSdrwGetVarVal( n, &ary ) ;

	*val = *VSgetAryElm( &ary, VSdrwIntVal( index ) ) ;

} /* VSdrwGetAryVal */
/*----------------------------------------------------------------------------*/


