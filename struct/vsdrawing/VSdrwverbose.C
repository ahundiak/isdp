/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "vsdrw.h"
#include "VSdrwgrammar.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsioproto.h"

extern int	VSyydrwlineno ;

static FILE	*logFile = stdout ;
/*----------------------------------------------------------------------------*/
void VSdrwIndent __(( void )) {
	int j ;
	for( j = 0 ; j < 8 ; j++ ) putc( ' ', logFile ) ;
} /* VSdrwIndent */
/*----------------------------------------------------------------------------*/
void VSdrwPrtItem( tok, type, val ) int tok, type ; const void *val ; {

	int		j,
			*i,
			_0 = 0 ;
	double		*d ;
	char		*s ;
	const char	*kw = VSdrwKwFromTokType( tok ) ;

	for( j = 0 ; j < 8 ; j++ ) putc( ' ', logFile ) ;

	if( -1 == type ) {
		VSexecRes	*r = (VSexecRes *) val ;
		type = r->type ;
		switch( type ) {
			case VS_int	: val = (void *) &r->_ival ; break ;
			case VS_double	: val = (void *) &r->_dval ; break ;
			case VS_string	: val = (void *)  r->_sval ; break ;
			default		: val = (void *) &_0 ;
					  type = VS_int ;	     break ;
		}
	}
	switch( type ) {
		case VS_int	: i = (int    *) val ;
				  fprintf( logFile, " > %s = %d\n"  , kw, *i ) ;
				  break ;
		case VS_double	: d = (double *) val ;
				  fprintf( logFile, " > %s = %g\n"  , kw, *d ) ;
				  break ;
		case VS_string	: s = (char   *) val ;
				  if( s ) {
					fprintf( logFile, " > %s = '%s'\n",
							  kw,  s ) ;
				  } else {
				  	fprintf( logFile, " > %s =\n", kw ) ;
				  }
				  break ;
	}

} /* VSdrwPrtItem */
/*----------------------------------------------------------------------------*/
const char *VSdrwVerbViewType( vt ) VSdrwViewType vt ; {

	const char	*c = NULL ;
	int		tok= 0 ;

	switch( vt ) {
		case VSfromTop		: tok = TOP		; break ;
		case VSfromBottom	: tok = BOTTOM		; break ;
		case VSfromSide		: tok = SIDE		; break ;
		case VSendOn		: tok = ENDON		; break ;
		case VSunknownViewType	: tok = UNKNOWN_VIEW	; break ;
		default			: c = "UNKNOWN"		; break ;
	}
	if( !c ) {
		c = VSdrwKwFromTokType( tok ) ;
	}
	return c ;

} /* VSdrwVerbViewType */
/*----------------------------------------------------------------------------*/
void VSdrwVerbValue( fmt, val ) const char *fmt ; const VSexecRes *val ; {

	VStktxt	f, g ;
	char	*c = strchr( fmt, '@' ) ;

	if( VS_string == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "'%s'" ) ; i += 4 ;
		strcpy( f + i, c + 1 ) ;
		fmt = f ;
	} else if( VS_object == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "[%d,%d]" ) ; i += 7 ;
		strcpy( f + i, c + 1 ) ;
		fmt = f ;
	} else if( VS_array == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "%s" ) ;
		fmt = f ;
		strcpy( g, c + 1 ) ;
	}

	if( c ) {
	  switch( val->type ) {
	    case VS_int	  : *c = 'd' ;
			    fprintf( logFile, fmt, val->_ival ) ; break ;
	    case VS_double: *c = 'g' ;
			    fprintf( logFile, fmt, val->_dval ) ; break ;
	    case VS_string: fprintf( logFile, fmt, val->_sval ) ; break ;
	    case VS_object: fprintf( logFile, fmt, val->_oval._osnum,
						   val->_oval._objid ) ;
			    break ;
	    case VS_array :
	      fprintf( logFile, fmt, "{" ) ;
	      { const int size = val->_aval.size ;
	        int	  i ;
	        for( i = 0 ; i < size ; i++ ) {
	          VSdrwVerbValue( " %@", val->_aval.element + i ) ;
	          fprintf( logFile, i == size -1 ? " " : "," ) ;
	        }
	      }
	      fprintf( logFile, "}%s", g ) ;
	      break ;
	    default	  : fprintf( logFile, "-> UNKNOWN TYPE %d\n",val->type);
			    break ;
	  }
	  *c = '@' ;
	}

} /* VSdrwVerbValue */
/*----------------------------------------------------------------------------*/
void VSdrwVerbArgLst( argl ) const VSdrwArgLst *argl ; {

	fprintf( logFile, "(" ) ;
	while( argl ) {
		VSdrwVerbValue( " %@", &argl->arg ) ;
		argl = argl->next ;
		if( argl ) fprintf( logFile, "," ) ;
	}
	fprintf( logFile, " )\n" ) ;

} /* VSdrwVerbArgLst */
/*----------------------------------------------------------------------------*/
void VSdrwVerbFcnCall( function, argl )

const char		*function ;
const VSdrwArgLst	*argl ; {

	VSdrwPrintf( "*-* %s", function ) ;
	VSdrwVerbArgLst( argl ) ;

} /* VSdrwVerbFcnCall */
/*----------------------------------------------------------------------------*/
void VSdrwVerbOutput( output, argl, hasSetup )

const char		*output ;
const VSdrwArgLst	*argl ;
int			hasSetup ; {

	VSdrwPrintf( "*-* Output %s\n", output ) ;
	if( argl )	VSdrwVerbArgLst( argl ) ;
	if( hasSetup )	fprintf( logFile, " with\n" ) ;
	else		fprintf( logFile, "\n" ) ;

} /* VSdrwVerbOutput */
/*----------------------------------------------------------------------------*/
void VSdrwVerbOp( op, arg1, arg2, res )

int		op ;
const VSexecRes	*arg1 ;
const VSexecRes	*arg2 ;
const VSexecRes	*res ; {

	char	*c ;

	switch( op ) {
		case '+'		: c = "+"	; break ;
		case '-'		: c = "-"	; break ;
		case '/'		: c = "/"	; break ;
		case '*'		: c = "*"	; break ;
		case '='		: c = "="	; break ;
		case VS_LE		: c = "<="	; break ;
		case VS_LT		: c = "<"	; break ;
		case VS_GE		: c = ">="	; break ;
		case VS_GT		: c = "<"	; break ;
		case VS_NE		: c = "!="	; break ;
		case VS_AND		: c = "and"	; break ;
		case VS_OR		: c = "or"	; break ;
		case VS_NOT		: c = "not"	; break ;
		case VS_POW		: c = "**"	; break ;
		default			: c = "??"	; break ;
	}
	VSdrwPrintf( "Op " ) ;

	if( arg2 ) {
		VSdrwVerbValue( "%@", arg1 ) ;
		fprintf( logFile, " %s ", c ) ;
		VSdrwVerbValue( "%@", arg2 ) ;
	} else {
		fprintf( logFile, "%s ", c ) ;
		VSdrwVerbValue( "%@", arg1 ) ;
	}
	VSdrwVerbValue( " -> %@\n", res ) ;

} /* VSdrwVerbOp */
/*----------------------------------------------------------------------------*/
void VSdrwVerbVar( flag, name, val )

int		flag ;
const char	*name ;
const VSexecRes *val ; {

	if( flag ) {	/* Assignment	*/
		VSdrwPrintf( "*-* Variable setting %s <- ", name ) ;
	} else {	/* Read		*/
		VSdrwPrintf( "*-* Variable evaluation %s -> ", name ) ;
	}
	VSdrwVerbValue( "%@\n", val ) ;

} /* VSdrwVerbVar */
/*----------------------------------------------------------------------------*/
void VSdrwVerbAnchor( member, whichPoint )

const char	*member	;
VSdrwAnchorType	whichPoint ; {

	int	wp ;
	switch( whichPoint ) {
		case VSdrwAnchorCenter	: wp = CENTER		; break ;
		case VSdrwAnchorCtrOfGrv: wp = CTR_OF_GRV	; break ;
		default			:
		case VSdrwAnchorCtrOfBox: wp = AVERAGE_POINT	; break ;
	}
	VSdrwPrintf( "*-* Anchor point( '%s', %s )\n",
			member, VSdrwKwFromTokType( wp ) ) ;

} /* VSdrwVerbAnchor */
/*----------------------------------------------------------------------------*/
FILE *VSdrwOpenLogFile( filename ) const char *filename ; {

	long		msg ;
	char		*openType ;
	FILE		*f ;

	if( VSdrwIsNewExtraction() ) {
		openType = "w" ;
		VSdrwSetExtractionFlg( FALSE ) ;
	} else {
		openType = "a" ;
	}

	f = VSopenFile( &msg, filename, openType ) ;

	if( msg & 1 ) {
		/*
		 * Close previous log file if not stdout.
		 */
		if( logFile != stdout ) fclose( logFile ) ;
		logFile = f ;
	} else {
		VSdrwPrintf( "!!! Cannot open `%s', using previous logfile\n",
			     filename ) ;
	}
	return logFile ;

} /* VSdrwOpenLogFile */
/*----------------------------------------------------------------------------*/
FILE *VSdrwGetLogFile() { return logFile ; }
/*----------------------------------------------------------------------------*/
void VSdrwCloseLogFile() {

	if( logFile != stdout ) fclose( logFile ) ;
	logFile = stdout ;

} /* VSdrwCloseLogFile */
/*----------------------------------------------------------------------------*/
