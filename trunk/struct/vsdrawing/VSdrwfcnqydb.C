/*
	I/STRUCT

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VSxfRC VSdrwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VSdrwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
#include <string.h>
#include "vsdrwapi.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, query_database ) {

	VSxfRC rc = xfFAILURE ;

	STR_RES( "" ) ;
	CHECK_ARGCOUNT( 1 )

	if( VdsRisAttach() ) {
	  int     countOfColumns= 0,
	          countOfRows	= 0 ;
	  char    **results	= NULL ;
	  VStktxt queryStatement ;

	  if( VDSsql_query( VSdrwStrVal( &arglist->arg, queryStatement ),
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
	      char	**compressed ;
	      
	      VSremove_dups_in_list( &msg, nbResults, results,
	      				   &arraySize, &compressed ) ;

	      if( msg & 1 ) {
	        VSexecRes	*pArray	  = VSdrwAryMalloc( arraySize ) ;

	        if( pArray ) {
	      	  int i ;
	      	  for( i = 0 ; i < arraySize ; i++ ) {
	      	    pArray[i].type = VS_string ;
	      	    strncpy(	pArray[i]._sval,
	      	  		compressed[i],
	      	  		VS_K_tokMAX_LENG )[VS_K_tokMAX_LENG] = '\0' ;
	      	  }
	      	  res->type 		= VS_array ;
	      	  res->_aval.size	= arraySize ;
	      	  res->_aval.element	= pArray ;

	          rc = xfSUCCESS ;
	        } else {
	          XFERR( "!!! %s(): memory allocation failure", function ) ;
	        }
	        free( compressed ) ;
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

} /* VSdrwFUNCTIONquery_database */
/*----------------------------------------------------------------------------*/

