/*
	I/STRUCT
*/
#include <stdlib.h>
#include "vsdrw.h"
#include "VSdrwgrammar.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
static VSdrwOutputData	*VSdrwOutputDataTail( head )

VSdrwOutputData	*head ; {

	VSdrwOutputData	*p	= head ;
	VSdrwOutputData	*tail	= NULL ;

	while( p ) {
		tail	= p ;
		p	= p->next ;
	}
	return tail ;

} /* VSdrwOutputDataTail */
/*----------------------------------------------------------------------------*/
VSdrwOutputData	*VSdrwNewOutputData( head )

VSdrwOutputData	**head ; {

	VSdrwOutputData	*new ;

	if( !head ) return NULL ;

	if( !*head ) {
		new = *head = _MALLOC( 1, VSdrwOutputData ) ;
	} else {
		VSdrwOutputData	*tail = VSdrwOutputDataTail( *head ) ;
		new = tail->next = _MALLOC( 1, VSdrwOutputData ) ;
	}
	if( new ) {
		new->set.count	= 0 ;
		new->set.list 	= NULL ;
		new->tag.type	= VS_int ;
		new->tag._ival	= -1 ;
		new->next	= NULL ; 
	}
	return new ;

} /* VSdrwNewOutputData */
/*----------------------------------------------------------------------------*/
void VSdrwFreeOutputData( head )

VSdrwOutputData	**head ; {

	if( head ) {
 
		VSdrwOutputData	*p = *head ;
		VSdrwOutputData	*n ;

		while( p ) {
			if( p->set.list ) free( p->set.list ) ;
			n = p->next ;
			free( p ) ;
			p = n ;
		}
		*head = NULL ;
	}

} /* VSdrwFreeOutputData */
/*----------------------------------------------------------------------------*/

