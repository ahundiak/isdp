/*
	I/VDS	Copy.

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VD_xfRC VD_drwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VD_drwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include "v_drwapi.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, string_length ) {

	VD_tktxt		string ;

	res->type	= VD_int ;
	res->_ival	= 0 ;

	CHECK_ARGCOUNT( 1 )

	res->_ival = strlen( VD_drwStrVal( &arglist->arg, string ) ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONstring_length */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, catenate_strings ) {

	const VD_drwArgLst	*a ;
	const int		maxlen = sizeof( res->_sval ) -1 ;
	const int		remain = maxlen ;

	/* Set default value */
	STR_RES( "" ) ;

	for( a = arglist ; a && remain > 0 ; a = a->next ) {
		VD_tktxt	str ;
		int	l ;
		VD_drwStrVal( &a->arg, str ) ;
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

} /* VD_drwFUNCTIONcatenate_strings */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, dup_string ) {

	VD_tktxt		pattern ;
	int		count ;

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VD_drwStrVal( &arglist->arg, pattern ) ;
	count = VD_drwIntVal( &arglist->next->arg ) ;

	{ int i, j, k ;
	  const int l = strlen( pattern ) ;
	  for( i = j = 0 ; j < count && i < VD_K_tokMAX_SIZE - 1 ; j++ ) {
		for( k = 0 ; k < l ; k++ ) {
			res->_sval[i++] = pattern[k] ;
		}
	  }
	  res->_sval[i] = '\0' ;
	}

	return xfSUCCESS ;

} /* VD_drwFUNCTIONdup_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, word_count ) {

	VD_tktxt	string ;

	res->type	= VD_int ;
	res->_ival	= 0 ;

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, string ) ;

	res->_ival = VD_wordcount( VD_drwStrVal( &arglist->arg, string ) ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONword_count */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, get_word ) {

	VD_tktxt	string ;
	int	wordno ;
	
	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VD_drwStrVal( &arglist->arg      , string ) ;
	wordno = VD_drwIntVal( &arglist->next->arg ) ;

	VD_getword( string, wordno, VD_K_tokMAX_SIZE, res->_sval ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONget_word */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, sub_string ) {

	VD_tktxt	string ;
	int	ifrom,
		ito ;
	
	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 3 )

	VD_drwStrVal( &arglist->arg      , string ) ;
	ifrom = VD_drwIntVal( &arglist->next->arg ) ;
	ito   = VD_drwIntVal( &arglist->next->next->arg ) ;

	VD_substring( string, ifrom, ito, VD_K_tokMAX_SIZE, res->_sval ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONsub_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, match_regexp ) {

	VD_tktxt		pattern,
			stringToMatch ;

	res->type	= VD_int ;
	res->_ival	= FALSE ;

	CHECK_ARGCOUNT( 2 )

	VD_drwStrVal( &arglist->arg      , pattern ) ;
	VD_drwStrVal( &arglist->next->arg, stringToMatch  ) ;

	res->_ival = VD_matchRE( pattern, stringToMatch ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONmatch_regexp */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, substitute_string ) {

	VD_tktxt	instr,
		torep,
		bystr ;
	int	times ;

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 4 )

	VD_drwStrVal( &arglist->arg      	, instr ) ;
	VD_drwStrVal( &arglist->next->arg	, torep ) ;
	VD_drwStrVal( &arglist->next->next->arg	, bystr ) ;
	times = VD_drwIntVal( &arglist->next->next->next->arg ) ;

	VD_substituteString(	instr,
				torep,
				bystr,
				times,
				VD_K_tokMAX_SIZE,
				res->_sval ) ;

	return xfSUCCESS ;

} /* VD_drwFUNCTIONsubstitute_string */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, format_number ) {

	VD_tktxt  format ;
	double	toFormat ;
	FILE	*errFile = xData->verbose ? xData->logFile : NULL ;

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 2 )

	VD_drwStrVal( &arglist->arg, format ) ;
	toFormat = VD_drwDblVal( &arglist->next->arg ) ;

	return VD_formatNumber(	format,
				toFormat,
				res->_sval,
				sizeof( res->_sval ),
				errFile ) ? xfSUCCESS : xfFAILURE ;

} /* VD_drwFUNCTIONformat_number */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, time ) {

	VD_tktxt	format ;

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, format ) ;

	{
	  char		buf[1000] ;
	  time_t	t = time( NULL ) ;
	  cftime( buf, format, &t ) ;

	  STR_RES( buf ) ;
	}
	return xfSUCCESS ;

} /* VD_drwFUNCTIONtime */

/*----------------------------------------------------------------------------*/

