/*
	I/VDS	Copy

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VD_xfRC VD_drwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VD_drwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
#include <string.h>
#include "v_drwapi.h"
#include "v_miscmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, query_database ) {

	VD_xfRC rc = xfFAILURE ;

	STR_RES( "" ) ;
	CHECK_ARGCOUNT( 1 )

	if( VdsRisAttach() ) {
	  int     countOfColumns= 0,
	          countOfRows	= 0 ;
	  char    **results	= NULL ;
	  VD_tktxt queryStatement ;

	  if( VDSsql_query( VD_drwStrVal( &arglist->arg, queryStatement ),
			    &countOfColumns,
			    &countOfRows,
			    &results ) ) {
	    if( countOfColumns && countOfRows ) {
	      /*
	       * We may have multiply equal entries in the items returned
	       * (because of the way the catalogs are made...). So trim down
	       * to one occurence per item.
	       */
	      long	msg ;
	      int	nbResults = countOfColumns * countOfRows ;
	      int	arraySize ;
	      char	**compressed = NULL ;
	      
	      VD_remove_dups_in_list( &msg, nbResults, results,
	      				   &arraySize, &compressed ) ;

	      if( msg & 1 ) {
	        VD_execRes	*pArray	  = NULL ;

	        pArray = VD_drwAryMalloc( arraySize ) ;
	        if( pArray ) {
	      	  int i ;
	      	  for( i = 0 ; i < arraySize ; i++ ) {
	      	    pArray[i].type = VD_string ;
	      	    strncpy(	pArray[i]._sval,
	      	  		compressed[i],
	      	  		VD_K_tokMAX_LENG )[VD_K_tokMAX_LENG] = '\0' ;
	      	  }
	      	  res->type 		= VD_array ;
	      	  res->_aval.size	= arraySize ;
	      	  res->_aval.element	= pArray ;

	          rc = xfSUCCESS ;
	        } else {
	          XFERR( "!!! %s(): memory allocation failure", function ) ;
	        }
	        _FREE( compressed ) ;
	      } else {
	      	 XFERR( "!!! %s(): memory allocation failure", function ) ;
	      }
	      VdsRisFreeBuffer( results, nbResults ) ;
	    } else {
	      rc = xfSUCCESS ;
	    }
	  } else {
	    XFERR( "!!! %s(): query '%s' failed\n", function, queryStatement ) ;
	  }	
	} else {
	  XFERR( "!!! %s(): no connection to database\n", function ) ;	
	}

	return rc ;

} /* VD_drwFUNCTIONquery_database */
/*----------------------------------------------------------------------------*/

