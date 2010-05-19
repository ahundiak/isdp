/*
	I/VDS	Copy
*/
#include <stdlib.h>
#include "v_drw.h"
#include "VDdrwgrammar.h"
#include "v_miscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
/*----------------------------------------------------------------------------*/
static VD_drwOutputData	*VD_drwOutputDataTail( head )

VD_drwOutputData	*head ; {

	VD_drwOutputData	*p	= head ;
	VD_drwOutputData	*tail	= NULL ;

	while( p ) {
		tail	= p ;
		p	= p->next ;
	}
	return tail ;

} /* VD_drwOutputDataTail */
/*----------------------------------------------------------------------------*/
VD_drwOutputData	*VD_drwNewOutputData( head )

VD_drwOutputData	**head ; {

	VD_drwOutputData	*new = NULL ;

	if( !head ) return NULL ;

	if( !*head ) {
		new = *head = _MALLOC( 1, VD_drwOutputData ) ;
	} else {
		VD_drwOutputData	*tail = VD_drwOutputDataTail( *head ) ;
		new = tail->next = _MALLOC( 1, VD_drwOutputData ) ;
	}
	if( new ) {
		new->set.count	= 0 ;
		new->set.list 	= NULL ;
		new->tag.type	= VD_int ;
		new->tag._ival	= -1 ;
		new->next	= NULL ; 
	}
	return new ;

} /* VD_drwNewOutputData */
/*----------------------------------------------------------------------------*/
void VD_drwFreeOutputData( head )

VD_drwOutputData	**head ; {

	if( head ) {
 
		VD_drwOutputData	*p = *head ;
		VD_drwOutputData	*n = NULL ;

		while( p ) {
			if( p->set.list ) _FREE( p->set.list ) ;
			n = p->next ;
			_FREE( p ) ;
			p = n ;
		}
		*head = NULL ;
	}

} /* VD_drwFreeOutputData */
/*----------------------------------------------------------------------------*/

