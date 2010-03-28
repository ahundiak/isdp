#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrtypedef.h"
#include "cidef.h"
#include "ciexecmacros.h"	/* Definition of `CIpushlist'	*/
/*----------------------------------------------------------------------------*/
int CIpush( argc, argv ) register int		argc	;
			 register CIpushlist	*argv	; {

/* -- Pushes arguments (in REVERSE order) onto the PPL function stack.
      This function must be invoked via the ci$push macro defined in
      ci/include/ciexecmacros.h (See this file).
      RETURNS: TRUE if successful else FALSE (means stack allocation failed).
   -- */
	int nbytes, size, i ;

	for( i = argc - 1 ; i >= 0 ; i-- ) {

		size	= argv[i].size	;
		nbytes	= size < sizeof( long ) ? sizeof( long ) : size ;

		if( CIpushV( 	argv[i].addr	,
				size		,
				nbytes		) != ISUCCESS ) {
			return FALSE ;
		}
	}
	return TRUE ;
} /* CIpush */
/*----------------------------------------------------------------------------*/
				
