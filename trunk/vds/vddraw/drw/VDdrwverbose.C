/* $Id: VDdrwverbose.C,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwverbose.C
 *
 * Description:
 *	Verbose print functions
 *	Used by:
 *		Visual interpreter			vddraw/drw
 *		attribute expression interpreter:	vdtbl/parser
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwverbose.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/04/19  13:43:42  pinnacle
 * Replaced: vddraw/drw/VDdrwverbose.C for:  by impd for vds
 *
 * Revision 1.2  1998/04/09  17:16:42  pinnacle
 * Replaced: vddraw/drw/VDdrwverbose.C for:  by v250_int for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.5  1995/08/21  18:55:58  pinnacle
 * Replaced: vddraw/drw/VDdrwverbose.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/07/27  23:17:18  pinnacle
 * Replaced: vddraw/drw/V*verb*.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/05/05  08:05:08  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.2  1995/03/31  10:52:22  pinnacle
 * Replace: by tlbriggs for OPE
 *
 *
 * History:
 *	3/27/95	   tlb	Change VD_drwPrintf to VD_drwParserTrace,
 *					VD_drwParserWarn
 *	5/2/95	   tlb	Add trace message to OpenLogFile
 *
 *	7/24/95	   tlb	Fix print for VD_GT
 *			Add support for all operators in v_slcdef.h
 *			Add support for VD_null, VD_bool
 *			Add VD_drwVerbConv, VD_drwVerbAttr,
 *				VD_drwVerbType, VD_drwVerbValType
 *	08/19/95   tlb  Modify attribute print format
 *	04/09/98   adz  Crash fix for VD_drwVerbValue
 *
 *************************************************************************/
/*
	I/VDS	Copy.
*/
#include <stdio.h>
#include <string.h>
#include "v_drw.h"
#include "VDdrwgrammar.h"
#include "v_miscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_ioproto.h"

extern int	VDyydrwlineno ;

static FILE	*logFile = stdout ;
/*----------------------------------------------------------------------------*/
void VD_drwIndent __(( void )) {
	int j ;
	for( j = 0 ; j < 8 ; j++ ) putc( ' ', logFile ) ;
} /* VD_drwIndent */
/*----------------------------------------------------------------------------*/
void VD_drwPrtItem( tok, type, val ) int tok, type ; const void *val ; {

	int		j,
			*i,
			_0 = 0 ;
	double		*d ;
	char		*s ;
	const char	*kw = VD_drwKwFromTokType( tok ) ;

	for( j = 0 ; j < 8 ; j++ ) putc( ' ', logFile ) ;

	if( -1 == type ) {
		VD_execRes	*r = (VD_execRes *) val ;
		type = r->type ;
		switch( type ) {
			case VD_null	: val = (void *) "null" ; break ;
			case VD_bool	: val = (void *) &r->_ival ; break ;
			case VD_int	: val = (void *) &r->_ival ; break ;
			case VD_double	: val = (void *) &r->_dval ; break ;
			case VD_string	: val = (void *)  r->_sval ; break ;
			default		: val = (void *) &_0 ;
					  type = VD_int ;	     break ;
		}
	}
	switch( type ) {
		case VD_bool	:
		case VD_int	: i = (int    *) val ;
				  fprintf( logFile, " > %s = %d\n"  , kw, *i ) ;
				  break ;
		case VD_double	: d = (double *) val ;
				  fprintf( logFile, " > %s = %g\n"  , kw, *d ) ;
				  break ;
		case VD_null	:
		case VD_string	: s = (char   *) val ;
				  if( s ) {
					fprintf( logFile, " > %s = '%s'\n",
							  kw,  s ) ;
				  } else {
				  	fprintf( logFile, " > %s =\n", kw ) ;
				  }
				  break ;
	}

} /* VD_drwPrtItem */
/*----------------------------------------------------------------------------*/
const char *VD_drwVerbViewType( vt ) VD_drwViewType vt ; {

	const char	*c = NULL ;
	int		tok= 0 ;

	switch( vt ) {
		case VD_fromTop		: tok = TOP		; break ;
		case VD_fromBottom	: tok = BOTTOM		; break ;
		case VD_fromSide		: tok = SIDE		; break ;
		case VD_endOn		: tok = ENDON		; break ;
		case VD_unknownViewType	: tok = UNKNOWN_VIEW	; break ;
		default			: c = "UNKNOWN"		; break ;
	}
	if( !c ) {
		c = VD_drwKwFromTokType( tok ) ;
	}
	return c ;

} /* VD_drwVerbViewType */
/*----------------------------------------------------------------------------*/
void 
VD_drwVerbValue( 	const char *fmt ,
			const VD_execRes *val )
{
	VD_tktxt	f, g ;
	char	*c = strchr( fmt, '@' ) ;

	if( !val ){
		fprintf( logFile, " %s\n", "-> UNDEFINED TYPE.");
		return ;
	}

	if( VD_string == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "'%s'" ) ; i += 4 ;
		strcpy( f + i, c + 1 ) ;
		fmt = f ;
	}else if( VD_null == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "'%s'" ) ; i += 4 ;
		strcpy( f + i, c + 1 ) ;
		fmt = f ;
	} else if( VD_object == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "[%d,%d]" ) ; i += 7 ;
		strcpy( f + i, c + 1 ) ;
		fmt = f ;
	} else if( VD_array == val->type ) {
		int	i = c - fmt - 1 ;
		strncpy( f, fmt, i ) ;
		strcpy( f + i, "%s" ) ;
		fmt = f ;
		strcpy( g, c + 1 ) ;
        } else if( VD_int == val->type ) {
                int     i = c - fmt - 1;
                strncpy( f, fmt, i ) ;
                strcpy( f + i, "%d" ) ; i += 2 ;
                strcpy( f + i, c + 1 ) ;
                fmt = f ;
        } else if( VD_bool == val->type ) {
                int     i = c - fmt - 1;
                strncpy( f, fmt, i ) ;
                strcpy( f + i, "%d" ) ; i += 2 ;
                strcpy( f + i, c + 1 ) ;
                fmt = f ;
        } else if( VD_double == val->type ) {
                int     i = c - fmt - 1 ;
                strncpy( f, fmt, i ) ;
                strcpy( f + i, "%g" ) ; i += 2 ;
                strcpy( f + i, c + 1 ) ;
                fmt = f ;
        }

	if( c ) {
	  switch( val->type ) {
	    case VD_bool:
	    case VD_int	:   fprintf( logFile, fmt, val->_ival ) ; break ;
	    case VD_double: fprintf( logFile, fmt, val->_dval ) ; break ;
	    case VD_null:   fprintf( logFile, fmt, "null") ;      break ;
	    case VD_string: fprintf( logFile, fmt, val->_sval ) ; break ;
	    case VD_object: fprintf( logFile, fmt, val->_oval._osnum,
						   val->_oval._objid ) ;
		 		break ;
	    case VD_array : fprintf( logFile, fmt, "{" ) ;
	      		{ const int size = val->_aval.size ;
	        	  int  i ;
	        	  for( i=0 ; i<size ; i++ ) {
	          	    VD_drwVerbValue( " %@", val->_aval.element + i);
	          	    fprintf( logFile, i == size -1 ? " " : "," ) ;
	        	  }
	      		}
	      		fprintf( logFile, "}%s", g ) ;
	      		break ;
	    default  :
			fprintf( logFile, "-> UNKNOWN TYPE %d\n",val->type);
			break ;
	    }
	  *c = '@' ;
	}

} /* VD_drwVerbValue */
/*----------------------------------------------------------------------------*/
/* return string with data type  */
char *
VD_drwVerbType(  const VD_execRes *val)
{
	char * str;

	switch (val->type) {
	    	case VD_bool: 		str ="bool" ; break ;
	    	case VD_int : 		str ="int" ; break ;
	    	case VD_double: 	str ="double" ; break ;
	    	case VD_string: 	str ="string" ; break ;
	    	case VD_null:		str ="null" ; break;
	    	case VD_object: 	str ="object" ; break ;
	    	case VD_array : 	str ="array" ; break ;
	    	default	  : 		str ="unknown"; break ;
		}
	return str;
}
/*----------------------------------------------------------------------------*/
/* Print value + data type -
 *	substitue for %@: 	<value> (<type>)
 */
void
VD_drwVerbValType(  	const char 	*fmt ,
			const VD_execRes *val)
{
	VD_tktxt	f;
	char 		*type;
	char		*c = strchr( fmt, '@' ) ;
	int		i = c - fmt - 1 ;

	strncpy (f, fmt, i ) ;
	strcpy  (f+i, "%@ (" ) ; 	i += 4 ;
	type = VD_drwVerbType (val); 
	strcpy  (f+i, type); 		i += strlen(type);
	strcpy  (f+i, ")");		i++;
	strcpy  (f+i, c+1 ) ;

 	VD_drwVerbValue (f, val );
}
/*----------------------------------------------------------------------------*/
void
VD_drwVerbArgLst( const VD_drwArgLst *argl )
{
	fputs( "(", logFile ) ;
	while( argl ) {
		VD_drwVerbValue( " %@", &argl->arg ) ;
		argl = argl->next ;
		if( argl ) fprintf( logFile, "," ) ;
		}
	fputs( " ) ", logFile) ;
} /* VD_drwVerbArgLst */
/*----------------------------------------------------------------------------*/
void
VD_drwVerbFcnCall( const char		*function ,
		   const VD_drwArgLst	*argl )
{
	VD_drwPrintf(" Func: %s", function ) ;
	VD_drwVerbArgLst( argl ) ;
} /* VD_drwVerbFcnCall */
/*----------------------------------------------------------------------------*/
void
VD_drwVerbUnitConv( const char		*unit ,
		    const VD_drwArgLst	*argl ,
		    const VD_execRes	*res )
{
	VD_drwPrintf (" Unit: %s", unit);
	VD_drwVerbArgLst( argl ) ;
	VD_drwVerbValue( " -> %@\n", res );
}
/*----------------------------------------------------------------------------*/
void
VD_drwVerbUnitConst( const char		*unit,
		     const VD_execRes	*value,
		     const VD_execRes	*res )
{
	VD_drwPrintf(" Unit value: ");
	VD_drwVerbValue ( "%@", value) ;
	fprintf (logFile, " %s" , unit ) ;
	VD_drwVerbValue( " -> %@\n", res );
}
/*----------------------------------------------------------------------------*/
void VD_drwVerbOutput( output, argl, hasSetup )

const char		*output ;
const VD_drwArgLst	*argl ;
int			hasSetup ; {

	VD_drwParserTrace("Output:  %s ", output ) ;
	if( argl )	VD_drwVerbArgLst( argl ) ;
	if( hasSetup )	fprintf( logFile, " with\n" ) ;
	else		fprintf( logFile, "\n" ) ;

} /* VD_drwVerbOutput */
/*----------------------------------------------------------------------------*/
void VD_drwVerbOp( 	int			op ,
			const VD_execRes	*arg1 ,
			const VD_execRes	*arg2 ,
			const VD_execRes	*res )
{
	char	*c ;

	switch( op ) {
		case '+'		: c = "+"	; break ;
		case '-'		: c = "-"	; break ;
		case '/'		: c = "/"	; break ;
		case '*'		: c = "*"	; break ;
		case '='		: c = "="	; break ;
		case VD_LT		: c = "<"	; break ;
		case VD_GE		: c = ">="	; break ;
		case VD_GT		: c = ">"	; break ;
		case VD_NE		: c = "!="	; break ;
		case VD_AND		: c = "and"	; break ;
		case VD_OR		: c = "or"	; break ;
		case VD_NOT		: c = "not"	; break ;
		case VD_POW		: c = "**"	; break ;

		case VD_plus		: c = "+"	; break ;
		case VD_minus		: c = "-"	; break ;
		case VD_div		: c = "/"	; break ;
		case VD_mult		: c = "*"	; break ;
		case VD_concat		: c = "++"	; break ;
		case VD_eq		: c = "=="	; break ;
		case VD_le		: c = "<="	; break ;
		case VD_lt		: c = "<"	; break ;
		case VD_ge		: c = ">="	; break ;
		case VD_gt		: c = "<"	; break ;
		case VD_ne		: c = "!="	; break ;
		case VD_and		: c = "and"	; break ;
		case VD_or		: c = "or"	; break ;
		case VD_not		: c = "not"	; break ;
		case VD_pow		: c = "**"	; break ;
		default			: c = "??"	; break ;
		}
	VD_drwPrintf( " Op:   " ) ;

	/* binary operator */
	if( arg2 ) {
		VD_drwVerbValue( "%@", arg1 ) ;
		fprintf( logFile, " %s ", c ) ;
		VD_drwVerbValue( "%@", arg2 ) ;
		}
	/* unary operator */
	else {
		fprintf( logFile, "%s ", c ) ;
		VD_drwVerbValue( "%@", arg1 ) ;
		}
	VD_drwVerbValue( " -> %@\n", res ) ;

} /* VD_drwVerbOp */
/*----------------------------------------------------------------------------*/
/* Print string to numeric conversions */
void VD_drwVerbConv( 	const VD_execRes	*arg ,
			const VD_execRes	*res )
{
	if (arg->type == VD_string )
		switch (res->type) {
		 	case VD_bool:
			case VD_int:
			case VD_double: 	break;
			default: 		return;
			}
	else if (res->type == VD_string )
		switch (arg->type) {
		 	case VD_bool:
			case VD_int:
			case VD_double: 	break;
			default: 		return;
			}
	else
		return;

	VD_drwPrintf( " Conv: " ) ;
	VD_drwVerbValue( "%@", arg ) ;
	VD_drwVerbValue( " -> %@\n", res ) ;

} /* VD_drwVerbConv */
/*----------------------------------------------------------------------------*/
/* Print string for attribute evaluation */
void
VD_drwVerbAttr ( struct GRobj_env	obj,
		VD_execRes		*attr,
		VD_execRes		*res)
{
	VD_drwPrintf( " Attr: " ) ;
	VD_drwVerbValue( "%@", attr ) ;
	fprintf (logFile, "\tfor obj[%d, %d]",
				obj.obj_id.osnum, obj.obj_id.objid);
	VD_drwVerbValue( " -> %@\n", res ) ;
}
/*----------------------------------------------------------------------------*/
void
VD_drwVerbVar( 	int		flag ,
		const char	*name ,
		const VD_execRes *val )
{
	if( flag ) {	/* Assignment	*/
		VD_drwParserTrace( "Variable setting %s <- ", name ) ;
	} else {	/* Read		*/
		VD_drwParserTrace( "Variable evaluation %s -> ", name ) ;
	}
	VD_drwVerbValue( "%@\n", val ) ;

} /* VD_drwVerbVar */
/*----------------------------------------------------------------------------*/
void
VD_drwVerbAnchor( const char	*member	,
		  VD_drwAnchorType	whichPoint )
{
	int	wp ;
	switch( whichPoint ) {
		case VD_drwAnchorCenter	: wp = CENTER		; break ;
		case VD_drwAnchorCtrOfGrv: wp = CTR_OF_GRV	; break ;
		default			:
		case VD_drwAnchorCtrOfBox: wp = AVERAGE_POINT	; break ;
	}
	VD_drwParserTrace( "Anchor point( '%s', %s )\n",
			member, VD_drwKwFromTokType( wp ) ) ;

} /* VD_drwVerbAnchor */
/*----------------------------------------------------------------------------*/
FILE
*VD_drwOpenLogFile( const char *filename )
{
	long		msg ;
	char		*openType ;
	FILE		*f ;

	if( VD_drwIsNewExtraction() ) {
		openType = "w" ;
		VD_drwSetExtractionFlg( FALSE ) ;
	} else {
		openType = "a" ;
	}

	f = VD_openFile( &msg, filename, openType ) ;

	if( msg & 1 ) {
		/*
		 * Close previous log file if not stdout.
 		 *	write trace message before closing
		 */
		if( logFile != stdout ) {
			VD_drwParserTrace ("Open logfile: %s\n", filename);
			fclose( logFile ) ;
			}
		logFile = f ;
	} else {
		VD_drwParserWarn (FALSE,
			"Cannot open `%s', using previous logfile\n", filename);
	}
	return logFile ;

} /* VD_drwOpenLogFile */
/*----------------------------------------------------------------------------*/
FILE *VD_drwGetLogFile() { return logFile ; }
/*----------------------------------------------------------------------------*/
void
VD_drwCloseLogFile() {

	if( logFile != stdout ) fclose( logFile ) ;
	logFile = stdout ;

} /* VD_drwCloseLogFile */
/*----------------------------------------------------------------------------*/
