/*
	I/VDS	Copy
*/
#include "v_drw.h"
#include "VDdrwgrammar.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
void VD_drwUpdateDatabase( const VD_drwExecData *xData, const char *statement ) {

	if( VdsRisAttach() ) {
	  int rc = VDSexecute_sql_stmt( statement ) ;
	    VD_drwPrintf( rc ? " -> successful update\n"
	    	            : " -> update failed\n" ) ;
	} else {
	  VD_drwPrintf( "!!! no connection to database\n" ) ;	
	}

} /* VD_drwUpdateDatabase */
/*----------------------------------------------------------------------------*/

