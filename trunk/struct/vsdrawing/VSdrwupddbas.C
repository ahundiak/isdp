/*
	I/STRUCT
*/
#include "vsdrw.h"
#include "VSdrwgrammar.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
void VSdrwUpdateDatabase( const VSdrwExecData *xData, const char *statement ) {

	if( VdsRisAttach() ) {
	  int rc = VDSexecute_sql_stmt( statement ) ;
	    VSdrwPrintf( rc ? " -> successful update\n"
	    	            : " -> update failed\n" ) ;
	} else {
	  VSdrwPrintf( "!!! no connection to database\n" ) ;	
	}

} /* VSdrwUpdateDatabase */
/*----------------------------------------------------------------------------*/

