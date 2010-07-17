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
#include <time.h>
#include <stdlib.h>
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
IMPLEMENT_FUNCTION( VS, string_length ) {

	VStktxt		string ;

	res->type	= VS_int ;
	res->_ival	= 0 ;

	CHECK_ARGCOUNT( 1 )

	res->_ival = strlen( VSdrwStrVal( &arglist->arg, string ) ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONstring_length */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, catenate_strings ) {

	const VSdrwArgLst	*a ;
	const int		maxlen = sizeof( res->_sval ) -1 ;
	const int		remain = maxlen ;

	/* Set default value */
	STR_RES( "" ) ;

	for( a = arglist ; a && remain > 0 ; a = a->next ) {
		VStktxt	str ;
		int	l ;
		VSdrwStrVal( &a->arg, str ) ;
		l = strlen( str ) ;
		if( l < remain ) {
			strcat( res->_sval, str ) ;
		} else {
			strncat( res->_sval, str, remain ) ;
			res->_sval[maxlen] = '\0' ;
			a = NULL ;
		}
	}
	return xfSUCCESS ;

} /* VSdrwFUNCTIONcatenate_strings */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, dup_string ) {

	VStktxt		pattern ;
	int		count ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VSdrwStrVal( &arglist->arg, pattern ) ;
	count = VSdrwIntVal( &arglist->next->arg ) ;

	{ int i, j, k ;
	  const int l = strlen( pattern ) ;
	  for( i = j = 0 ; j < count && i < VS_K_tokMAX_SIZE - 1 ; j++ ) {
		for( k = 0 ; k < l ; k++ ) {
			res->_sval[i++] = pattern[k] ;
		}
	  }
	  res->_sval[i] = '\0' ;
	}

	return xfSUCCESS ;

} /* VSdrwFUNCTIONdup_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, word_count ) {

	VStktxt	string ;

	res->type	= VS_int ;
	res->_ival	= 0 ;

	CHECK_ARGCOUNT( 1 )

	VSdrwStrVal( &arglist->arg, string ) ;

	res->_ival = VSwordcount( VSdrwStrVal( &arglist->arg, string ) ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONword_count */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, get_word ) {

	VStktxt	string ;
	int	wordno ;
	
	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VSdrwStrVal( &arglist->arg      , string ) ;
	wordno = VSdrwIntVal( &arglist->next->arg ) ;

	VSgetword( string, wordno, VS_K_tokMAX_SIZE, res->_sval ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONget_word */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, sub_string ) {

	VStktxt	string ;
	int	ifrom,
		ito ;
	
	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 3 )

	VSdrwStrVal( &arglist->arg      , string ) ;
	ifrom = VSdrwIntVal( &arglist->next->arg ) ;
	ito   = VSdrwIntVal( &arglist->next->next->arg ) ;

	VSsubstring( string, ifrom, ito, VS_K_tokMAX_SIZE, res->_sval ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONsub_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, match_regexp ) {

	VStktxt		pattern,
			stringToMatch ;

	res->type	= VS_int ;
	res->_ival	= FALSE ;

	CHECK_ARGCOUNT( 2 )

	VSdrwStrVal( &arglist->arg      , pattern ) ;
	VSdrwStrVal( &arglist->next->arg, stringToMatch  ) ;

	res->_ival = VSmatchRE( pattern, stringToMatch ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONmatch_regexp */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, substitute_string ) {

	VStktxt	instr,
		torep,
		bystr ;
	int	times ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 4 )

	VSdrwStrVal( &arglist->arg      	, instr ) ;
	VSdrwStrVal( &arglist->next->arg	, torep ) ;
	VSdrwStrVal( &arglist->next->next->arg	, bystr ) ;
	times = VSdrwIntVal( &arglist->next->next->next->arg ) ;

	VSsubstituteString(	instr,
				torep,
				bystr,
				times,
				VS_K_tokMAX_SIZE,
				res->_sval ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONsubstitute_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, format_number ) {

	VStktxt	format ;
	double	toFormat ;
	FILE	*errFile = xData->verbose ? xData->logFile : NULL ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VSdrwStrVal( &arglist->arg, format ) ;
	toFormat = VSdrwDblVal( &arglist->next->arg ) ;

	return VSformatNumber(	format,
				toFormat,
				res->_sval,
				sizeof( res->_sval ),
				errFile ) ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONformat_number */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, time ) {

	VStktxt	format ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 1 )

	VSdrwStrVal( &arglist->arg, format ) ;

	{
	  char		buf[1000] ;
	  time_t	t = time( NULL ) ;
	  cftime( buf, format, &t ) ;

	  STR_RES( buf ) ;
	}
	return xfSUCCESS ;

} /* VSdrwFUNCTIONtime */
/*----------------------------------------------------------------------------*/

