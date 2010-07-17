/*
	I/STRUCT
*/
#include <stdlib.h>
#include "vs.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
void VSfreeOpHistory( history ) VSopHistory *history ; {

	VSopHistory *h ;

	while( history ) {
		_FREE( history->opList ) ;
		h = history->next ;
		_FREE( history ) ;
		history = h ;
	}

} /* VSfreeOpHistory */
/*----------------------------------------------------------------------------*/

