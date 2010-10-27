/*
	I/VDS	Copy.
*/
#include <string.h>
#include <stdlib.h>
#include "v_drw.h"
#include "parametric.h"
#include "VDdrwgrammar.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_lngopproto.h"
/*----------------------------------------------------------------------------*/
double VD_drwDblVal( t ) const VD_execRes *t ; {

	/*
	 * Interprets input value as a double.
	 * Will work OK if `t' is an INT or a DOUBLE; if `t' is a STRING then
	 * - "123.23"	will be evaluated to 123.23
	 * - "12.3xx"	will be evaluated to 12.3
	 * - "abcd"	will be evaluated to 0
	 */
	double		d ;
	long		msg ;
	VD_execRes	r ;

	switch( t->type ) {
	  case VD_int    : d = (double) t->_ival;		   break ;
	  case VD_double : d = t->_dval		;		   break ;
	  case VD_string : d = atof( t->_sval )	;		   break ;
	  case VD_object : VD_getObjVal( &msg, &t->_oval, &r ) ;
			   d = msg & 1 ? VD_drwDblVal( &r ) : 0 ;   break ;
	  case VD_array	: d = VD_drwDblVal( VD_getAryElm( t, 0 ) ) ; break ;
	  default	: d = 0	;				   break ;
	}
	return d ;

} /* VD_drwDblVal */
/*----------------------------------------------------------------------------*/
int VD_drwIntVal( t ) const VD_execRes *t ; {

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
	VD_execRes	r ;

	switch( t->type ) {
	  case VD_int	 : i = t->_ival		;		    break ;
	  case VD_double : i = (int) t->_dval	;		    break ;
	  case VD_string : i = atof( t->_sval )	;		    break ;
	  case VD_object : VD_getObjVal( &msg, &t->_oval, &r ) ;
			   i = msg & 1 ? VD_drwIntVal( &r ) : 0 ;    break ;
	  case VD_array	 : i = VD_drwIntVal( VD_getAryElm( t, 0 ) ) ; break ;
	  default	 : i = 0 ;				    break ;
	}
	return i ;

} /* VD_drwIntVal */
/*----------------------------------------------------------------------------*/
int VD_drwBoolVal( t ) const VD_execRes *t ; {

	/*
	 * Interprets input value as an boolean.
	 * `t' is an INT	: TRUE if non-zero else FALSE.
	 * `t' is a DOUBLE	: TRUE if non-zero else FALSE.
	 * `t' is a STRING	: TRUE if non-empty ( != "" ) else FALSE.
	 */
	int		bool ;
	long		msg ;
	VD_execRes	r ;

	switch( t->type ) {
	  case VD_int	: bool = t->_ival  != 0		;		 break ;
	  case VD_double: bool = t->_dval  != 0.	;		 break ;
	  case VD_string: bool = *t->_sval != '\0'	;		 break ;
	  case VD_object: VD_getObjVal( &msg, &t->_oval, &r ) ;
			  bool = msg & 1 ? VD_drwBoolVal( &r ) : FALSE ;  break ;
	  case VD_array	: bool = VD_drwBoolVal( VD_getAryElm( t, 0 ) ) ;	 break ;
	  default	: bool = FALSE ;				 break ;
	}
	return bool ;

} /* VD_drwBoolVal */
/*----------------------------------------------------------------------------*/
char *VD_drwStrVal( t, s ) const VD_execRes *t ; char *s ; {

	/*
	 * Interprets input value as a string.
	 * `t' is an INT	: format "%d" used.
	 * `t' is a DOUBLE	: format "%g" used
	 * `t' is a STRING	: returns copy of input.
	 */
	long		msg ;
	VD_execRes	r ;

	switch( t->type ) {
	  case VD_int	 : sprintf( s, "%d", t->_ival )	;	  break ;
	  case VD_double : sprintf( s, "%g", t->_dval )	;	  break ;
	  case VD_string : strcpy( s, t->_sval ) ;		  break ;
	  case VD_object : VD_getObjVal( &msg, &t->_oval, &r ) ;
			   if( msg & 1 ) VD_drwStrVal( &r, s ) ;
			   else		s[0] = '\0' ;		  break ;
	  case VD_array	: VD_drwStrVal( VD_getAryElm( t, 0 ), s ) ; break ;
	  default	: s[0] = '\0' ; break ;
	}
	return s ;

} /* VD_drwStrVal */ 
/*----------------------------------------------------------------------------*/

