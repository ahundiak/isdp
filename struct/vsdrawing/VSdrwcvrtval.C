/*
	I/STRUCT
*/
#include <string.h>
#include <stdlib.h>
#include "vsdrw.h"
#include "parametric.h"
#include "VSdrwgrammar.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vslngopproto.h"
/*----------------------------------------------------------------------------*/
double VSdrwDblVal( t ) const VSexecRes *t ; {

	/*
	 * Interprets input value as a double.
	 * Will work OK if `t' is an INT or a DOUBLE; if `t' is a STRING then
	 * - "123.23"	will be evaluated to 123.23
	 * - "12.3xx"	will be evaluated to 12.3
	 * - "abcd"	will be evaluated to 0
	 */
	double		d ;
	long		msg ;
	VSexecRes	r ;

	switch( t->type ) {
	  case VS_int    : d = (double) t->_ival;		   break ;
	  case VS_double : d = t->_dval		;		   break ;
	  case VS_string : d = atof( t->_sval )	;		   break ;
	  case VS_object : VSgetObjVal( &msg, &t->_oval, &r ) ;
			   d = msg & 1 ? VSdrwDblVal( &r ) : 0 ;   break ;
	  case VS_array	: d = VSdrwDblVal( VSgetAryElm( t, 0 ) ) ; break ;
	  default	: d = 0	;				   break ;
	}
	return d ;

} /* VSdrwDblVal */
/*----------------------------------------------------------------------------*/
int VSdrwIntVal( t ) const VSexecRes *t ; {

	/*
	 * Interprets input value as an integer.
	 * Will work OK if `t' is an INT or a DOUBLE (truncation may occur);
	 * if `t' is a STRING then
	 * - "123.23"	will be evaluated to 123
	 * - "12.3xx"	will be evaluated to 12
	 * - "abcd"	will be evaluated to 0
	 */
	int		i ;
	long		msg ;
	VSexecRes	r ;

	switch( t->type ) {
	  case VS_int	 : i = t->_ival		;		    break ;
	  case VS_double : i = (int) t->_dval	;		    break ;
	  case VS_string : i = atof( t->_sval )	;		    break ;
	  case VS_object : VSgetObjVal( &msg, &t->_oval, &r ) ;
			   i = msg & 1 ? VSdrwIntVal( &r ) : 0 ;    break ;
	  case VS_array	 : i = VSdrwIntVal( VSgetAryElm( t, 0 ) ) ; break ;
	  default	 : i = 0 ;				    break ;
	}
	return i ;

} /* VSdrwIntVal */
/*----------------------------------------------------------------------------*/
int VSdrwBoolVal( t ) const VSexecRes *t ; {

	/*
	 * Interprets input value as an boolean.
	 * `t' is an INT	: TRUE if non-zero else FALSE.
	 * `t' is a DOUBLE	: TRUE if non-zero else FALSE.
	 * `t' is a STRING	: TRUE if non-empty ( != "" ) else FALSE.
	 */
	int		bool ;
	long		msg ;
	VSexecRes	r ;

	switch( t->type ) {
	  case VS_int	: bool = t->_ival  != 0		;		 break ;
	  case VS_double: bool = t->_dval  != 0.	;		 break ;
	  case VS_string: bool = *t->_sval != '\0'	;		 break ;
	  case VS_object: VSgetObjVal( &msg, &t->_oval, &r ) ;
			  bool = msg & 1 ? VSdrwBoolVal( &r ) : FALSE ;  break ;
	  case VS_array	: bool = VSdrwBoolVal( VSgetAryElm( t, 0 ) ) ;	 break ;
	  default	: bool = FALSE ;				 break ;
	}
	return bool ;

} /* VSdrwBoolVal */
/*----------------------------------------------------------------------------*/
char *VSdrwStrVal( t, s ) const VSexecRes *t ; char *s ; {

	/*
	 * Interprets input value as a string.
	 * `t' is an INT	: format "%d" used.
	 * `t' is a DOUBLE	: format "%g" used
	 * `t' is a STRING	: returns copy of input.
	 */
	long		msg ;
	VSexecRes	r ;

	switch( t->type ) {
	  case VS_int	 : sprintf( s, "%d", t->_ival )	;	  break ;
	  case VS_double : sprintf( s, "%g", t->_dval )	;	  break ;
	  case VS_string : strcpy( s, t->_sval ) ;		  break ;
	  case VS_object : VSgetObjVal( &msg, &t->_oval, &r ) ;
			   if( msg & 1 ) VSdrwStrVal( &r, s ) ;
			   else		s[0] = '\0' ;		  break ;
	  case VS_array	: VSdrwStrVal( VSgetAryElm( t, 0 ), s ) ; break ;
	  default	: s[0] = '\0' ; break ;
	}
	return s ;

} /* VSdrwStrVal */ 
/*----------------------------------------------------------------------------*/

