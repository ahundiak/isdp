/* $Id: VSreportobjs.C,v 1.2 2001/02/20 23:39:27 ramarao Exp $  */

/*************************************************************************
 * I/STRUCT>
 *
 * File:        vsreports/VSreportobjs.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSreportobjs.C,v $
 *      Revision 1.2  2001/02/20 23:39:27  ramarao
 *      Increased the number of columns from 20 to 100
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:56  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/11/23  23:37:58  pinnacle
 * cr179900816
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/01/23  18:52:02  pinnacle
 * Replaced: vsreports/VSreportobjs.C for:  by impd for struct
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.3  1996/03/14  18:54:56  pinnacle
 * Replaced: vsreports/VSreportobjs.C for:  by jwfrosch for struct
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *	03/14/96     HF		Temporary FIX for "Generate BEAM/WELD/PLATE Report from Model"
 *				failure in I/STRUCT on Solaris, due to fact that the INCORRECT
 *				library is used to link $MODEL/bin/Model
 *
 *	11/23/99   ylong 	CR179900816, added ':' to be recognized.
 *      02/20/01   Rama Rao     Increased the number of columns from 20 to 100.
 *************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#ifdef ENV5
#include <stdarg.h>
#endif

#ifdef X11
#include "standards.h"
#include <varargs.h>
#include <stdarg.h>
#endif
/*
 * Temporary : ONLY until $MODEL/bin/Model on Solaris has been linked with the proper library
 */
#include <sys/utsname.h>

#include <string.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "growner.h"
#include "v_miscmacros.h"

#define VD_DEBUG
#include "VDdebug.h"

#define MAXARGS		10
#define MAXARGSIZE	32

#define	ARG_DBL		0
#define ARG_INT		1
#define ARG_IDT		2
#define ARG_STR		3

/*
 * Actually regcmp() and regex() (but not __loc1, documented in UNIX's
 * regcmp(3) !) are defined in <pw.h>, but <pw.h> contains a prototype for
 * a function called index() which is different from another function also
 * called index(), defined in <string.h>, thus causing compiler errors in
 * ANSI mode ...
 */
extern char	*regcmp() ;
extern char	*regex() ;
extern char	*__loc1 ;

/*
 * Temporary : ONLY until $MODEL/bin/Model on Solaris has been linked with the proper library
 */
static int VD_INTEL_Solaris;

/*----------------------------------------------------------------------------*/
static char *VSprecompile( string, argc, argt )

register char	*string ;
int		*argc,
		argt[] ; {

#define	SPACES	"[ \t]+"
#define OSPACES	"[ \t]*"
/*
 * MAXARGSIZE = 32 = 1 for [A-Za-z_] + 30 max for [A-Za-z0-9_]{0,30} + end '\0'
 */
#define IDENT	"([A-Za-z_:][A-Za-z0-9_:]{0,30})"
#define INT	"([1-9][0-9]*)"
#define DBL	"([0-9]+(\\.[0-9]*){0,1})"
/*
 * MAXARGSIZE = 32 = 1 for " + 29 max for .{0,29} + 1 for " + end '\0'
 */
#define STR	"(\".{0,29}\")"		/* does  NOT WORK  on Solaris */
#define STR	"(\"[\t -~]{0,29}\")"	/* works CORRECTLY on Solaris */

#define	L_SPACES	( sizeof( SPACES	) -1 )
#define L_OSPACES	( sizeof( OSPACES	) -1 )
#define L_IDENT		( sizeof( IDENT		) -1 )
#define L_INT		( sizeof( INT		) -1 )
#define L_DBL		( sizeof( DBL		) -1 )
#define L_STR		( sizeof( STR		) -1 )

	int		nsp	= 0,
			nosp	= 0,
			nidt	= 0,
			nint	= 0,
			ndbl	= 0,
			nstr	= 0,
			narg	= 0 ;
	unsigned	size ;
	register char	*s,
			*t,
			*u ;
	char		arg[3] ;

	s = string ;
	while( *s ) {
		switch( *s ) {
			case	'|' : nsp++ ; break ;
			case	'?' : nosp++; break ;
			case	'[' : if( s[1] && s[2] == ']' ) {
					switch( s[1] ) {
						case 'i' : nint++ ; break ;
						case 'd' : ndbl++ ; break ;
						case 'I' : nidt++ ; break ;
						case 's' : nstr++ ; break ;
					}
				      }
				      break ;
		}
		s++ ;
	}
	narg = nint + ndbl + nidt + nstr ;

	if( narg > MAXARGS ) return NULL ;

	size	= strlen( string )
		  - nsp
		  - nosp
		  - narg * 3
		  + nsp  * L_SPACES
		  + nosp * L_OSPACES
		  + nint * L_INT
		  + ndbl * L_DBL
		  + nidt * L_IDENT
		  + nstr * L_STR
		  + narg * 2 /* $n */
		  + 1 ;

	if( !( u = t = _MALLOC( size, char ) ) ) return NULL ;

	s = string ; narg = 0 ;
	while( *s ) {
		switch( *s ) {

		case	'|' :	strcpy( u, SPACES ) ; u += L_SPACES  ; break ;

		case	'?' :	strcpy( u, OSPACES ) ;u += L_OSPACES ; break ;

		case	'[' :
			if( s[1] && s[2] == ']' ) {

				int n ;

				switch( s[1] ) {
				case 'i' : strcpy( u, INT   ) ; u += L_INT ;
					   s += 2 ; argt[narg] = ARG_INT ;
					   break ;

				case 'd' : strcpy( u, DBL   ) ; u += L_DBL ;
					   s += 2 ; argt[narg] = ARG_DBL ;
					   break ;

				case 'I' : strcpy( u, IDENT ) ; u += L_IDENT ;
					   s += 2 ; argt[narg] = ARG_IDT ;
					   break ;
				case 's' : strcpy( u, STR   ) ; u += L_STR ;
					   s += 2 ; argt[narg] = ARG_STR ;
					   break ;
				}
				n = sprintf( arg, "$%d", narg ) ;
				strcpy( u, arg ) ;
				u += n ;
				narg++ ;
			} else *u++ = *s ;

			break ;

		default	: *u++ = *s ; break ;
		}

		s++ ;
	}
	*u = '\0' ;
	*argc = narg ;

	return t ;

} /* VSprecompile */
/*----------------------------------------------------------------------------*/
/*VARGARS0*/
static int VSparseReportFmtLine( va_alist ) va_dcl {

	/*
	 * arg 0	: test string		(char *)
	 * arg 1	: pattern string	(char *)
	 * arg 2-11	: address of string, int or double.
	 */
	va_list		ap ;
	char		*pre     = NULL,
			*cmp     = NULL,
			*last    = NULL,
			*pattern = NULL,
			*test    = NULL,
			ret[MAXARGS][MAXARGSIZE] ;
	int		argc,
			argt[MAXARGS],
			rc = 0 ;

	char  lst[MAXARGSIZE];

  __enterFunction ( name = "VSparseReportFmtLine" );

	va_start( ap, 0 ) ;

	test	= va_arg( ap, char *	) ;
	pattern	= va_arg( ap, char *	) ;

	if( !( pre = VSprecompile( pattern, &argc, argt ) ) ) goto wrapup ;

  __printf ( "test = <%s>", test );
  __printf ( "pre  = <%s>", pre );
  __printf ( "argc = %d", argc );

	memset ( ret, 0, MAXARGS * MAXARGSIZE );
	memset ( lst, 0, MAXARGSIZE );

	/*
	 * Temporary : ONLY until $MODEL/bin/Model on Solaris has been linked with the proper library
	 */
	if ( VD_INTEL_Solaris )
	{
	  int   sts;

	  sts = VS_tmp_regex_solaris ( test, pre, ret );

	  if ( ! sts )
	  {
	    __print_goto ( "wrapup" );
	    goto wrapup;
	  }
	  /*
	   * We have to fake this, because '__loc1' & 'last' are set in a
	   * separate executable, and thus are not available ...
	   */
	  if ( test[0] == '!' )
	  {
	    __loc1 = test;
	    last   = lst;
	  }
	  else
	  {
	    __loc1 = last   = NULL;
	  }
	}
	else
	{
	  if( !( cmp = regcmp( pre, NULL ) ) ) goto wrapup ;

  __printf ( "strlen(cmp) = %d, cmp  = <%s>", `strlen(cmp), cmp` );

	  last = regex(	cmp,
			test,
			ret[0],
			ret[1],
			ret[2],
			ret[3],
			ret[4],
			ret[5],
			ret[6],
			ret[7],
			ret[8],
			ret[9] ) ;
	}

	if( last && !*last && __loc1 == test )
	{
		int						i ;
		union { int *i ; double *d ; char *s ; }	a ;

		for( i = 0 ; i < argc ; i++ )
		{
			a.s = va_arg( ap, char * ) ;

			switch( argt[i] )
			{
				case ARG_INT : *a.i = atol( ret[i] ) ; break ;

				case ARG_DBL : *a.d = atof( ret[i] ) ; break ;

				case ARG_IDT : strcpy( a.s, ret[i] ) ; break ;

				case ARG_STR : strcpy( a.s, ret[i] + 1 ) ;
					       a.s[strlen( a.s )-1] = '\0' ;
					       break ;
			}
		}
		rc = 1 ;
	} /* else match started at __loc1 */

	_FREE( cmp ) ;
	_FREE( pre ) ;

  __exitFunction  ( name = "VSparseReportFmtLine" );

	wrapup :
		va_end( ap ) ;
		return rc ;

} /* VSparseReportFmtLine */
/*----------------------------------------------------------------------------*/
typedef struct COLUMN {
	int	width ;
	char	item [MAXARGSIZE],
		title[MAXARGSIZE] ;
} COLUMN ;

#define MAX_ITEMS_PER_LINE	100

int VSreportObjects( infile, outfile, nbObjs, objList )

FILE			*infile,	/* File of formatting directives*/
			*outfile ;	/* Report file			*/
int			nbObjs ;
struct GRobj_env	*objList ; {

	char	*pattern,
		ident[MAXARGSIZE],
		title[MAXARGSIZE],
		buffer[BUFSIZ] ;
	int	rc,
		writeErr = 0,
		i,
		j,
		ncols,
		parse,
		width,
		totwidth ;
	COLUMN	cols[MAX_ITEMS_PER_LINE] ;

	struct utsname  unix_info;

  __enterFunction ( name = "VSreportObjects" );

	VD_INTEL_Solaris = 0;

	if ( uname ( &unix_info ) != -1 )
	{
	  __printf ( "unix_info.sysname  = <%s>", unix_info.sysname );
	  __printf ( "unix_info.nodename = <%s>", unix_info.nodename );
	  __printf ( "unix_info.machine  = <%s>", unix_info.machine );

	  if ( //strcmp ( unix_info.machine, "i86pc" ) == 0 &&
	         strcmp ( unix_info.sysname, "SunOS" ) == 0 )	// Test ONLY for "SunOS"
	  {
	    /*
	     * RESTORING ORIGINAL FUNCTIONALITY
	     *
	     * AFTER $MODEL/bin/Model on Solaris has been linked with the CORRECT library
	     *   (check file "$GRNUC/islmakelib" for "-lgen" versus "SUN_libPW.o"),
	     * THEN,
	     * it is ONLY required to set 'VD_INTEL_Solaris = 0' in order to
	     * PREVENT calling VS_tmp_regex_solaris() & executing VD_isl_regex ...!!!
	     */

	    VD_INTEL_Solaris = 1;	/* >>>> Set : VD_INTEL_Solaris = 0; <<<<< */
	  }
	}
	else
	{
	  perror ("uname failed");
	}

	if ( 1 )	// Force processing of $VDS/config/weld_symbols
	{
	  int sts, num_sym = 0;
	  
	  sts = VDread_weld_sym_char( &num_sym );
	}

	/*
	 * Pattern of column-format directives.
	 * '|' = mandatory space(s)
	 * '?' = optional  space(s)
	 * [I] = want identifier (C-style)
	 * [s] = want string (C-style)
	 * [d] = want double-precision floating-point number
	 * [i] = want integer
	 */
	pattern = "!col|attr?=?[I]|width?=?[i]|title?=?[s]?" ;

	parse = 1 ;

	for( ncols = 0 ; ; ) {
		if( !fgets( buffer, BUFSIZ, infile ) ) {
			/*
			 * Error or EOF.
			 */
			break ;
		}
		/*
		 * Ignore line beginning with '#'.
		 */
		if( *buffer == '#' ) continue ;

		/*
		 * Remove \n.
		 */
		buffer[strlen(buffer)-1] = '\0' ;

  __printf ( "buffer[%d] = <%s>", `ncols, buffer` );

		if( parse ) {
			rc = VSparseReportFmtLine(	buffer,
							pattern,
							ident,
							&width,
							title ) ;
			if( rc ) {
				if( ncols >= MAX_ITEMS_PER_LINE ) {
					rc = fprintf(
						 outfile,
						 "* Cmd %d ignored (max cmds = %d) : '%s'\n",
						 ncols + 1,
						 MAX_ITEMS_PER_LINE,
						 buffer ) ;
					if( rc < 0 ) {
						writeErr = 1 ;
						goto wrapup ;
					}
				} else {
					cols[ncols].width = width ;
					strcpy( cols[ncols].item , ident ) ;
					strcpy( cols[ncols].title, title ) ;
					ncols++ ;
				}
			} else {
				/*
				 * First unrecognized line, stop parsing,
				 * output line as is.
				 */
				rc = fprintf( outfile, "%s\n", buffer ) ;
				if( rc < 0 ) {
					writeErr = 1 ; goto wrapup ;
				}
				parse = 0 ;
			}
		} else {
			/*
			 * Output line as is.
			 */
			rc = fprintf( outfile, "%s\n", buffer ) ;
			if( rc < 0 ) { writeErr = 1 ; goto wrapup ; }
		}
	}

	/*
	 * Output column titles.
	 */
	for( i = totwidth = 0 ; i < ncols ; i++ ) {
		width = cols[i].width ;
		rc = fprintf( outfile, "%-*.*s|", width, width, cols[i].title ) ;
		if( rc < 0 ) { writeErr = 1 ; goto wrapup ; }
		totwidth += width + 1 ;
	}

	/*
	 * Separate titles from items with a line of '-'s
	 */
	if( fputc( '\n', outfile ) == EOF ) { writeErr = 1 ; goto wrapup ; }

	for( i = 0 ; i < totwidth ; i++ ) {
		if( fputc( '-', outfile ) == EOF ) {
			writeErr = 1 ; goto wrapup ;
		}
	}

	if( fputc( '\n', outfile ) == EOF ) { writeErr = 1 ; goto wrapup ; }

	/*
	 * Output item values for all objects.
	 */
	for( j = 0 ; j < nbObjs ; j++ ) {
		for( i = 0 ; i < ncols ; i++ ) {

			width = cols[i].width ;

			VSgetItemValueForReport( objList + j,
						 cols[i].item,
						 buffer ) ;

			rc = fprintf( outfile, "%-*.*s|", width, width, buffer ) ;
			if( rc < 0 ) { writeErr = 1 ; goto wrapup ; }
		}
		if( fputc( '\n', outfile ) == EOF ) {
			writeErr = 1 ; goto wrapup ;
		}
	}
	wrapup :

  __exitFunction  ( name = "VSreportObjects" );

		return writeErr ? 0 : 1 ;

} /* VSreportObjects */
/*----------------------------------------------------------------------------*/

/*
 * Temporary Function:
 * ==================
 * To FIX the failure of commands "Generate Beam/Weld/Plate Report from Model"
 *
 * ONLY necessary until $MODEL/bin/Model on Solaris has been linked with "/usr/ccs/libgen.a"
 */

int VS_tmp_regex_solaris
(
  char  *test,
  char  *pre,
  char  ret[][MAXARGSIZE]
)
{
  int   i0, sts, status = 1;

  __enterFunction  ( name = "VS_tmp_regex_solaris" );

  if ( VD_INTEL_Solaris )
  {
    FILE *fp = NULL;
    char  lst[MAXARGSIZE];

    if ( fp = fopen ( ".str_rpt_1", "w" ) )
    {
      fprintf ( fp, "%s\n", pre );
      fprintf ( fp, "%s\n", test );
      fclose  ( fp );

      	/*
      	 * The separate EXECUTABLE "VD_isl_regex" (linked with "/usr/ccs/libgen.a")
      	 *   - reads the file ".str_rpt_1"
      	 *   - processes data from ".str_rpt_1" using the CORRECT versions of
      	 *     functions regex() & regcmp()
      	 *   - writes the file ".str_rpt_2"
      	 */

      if ( VDfunct | VDcomment )		// Toggled at run-time by "ci=toggle"
      {
	sts = system ( "VD_isl_regex DEBUG" );
      }
      else
      {
	sts = system ( "VD_isl_regex" );
      }

      if ( sts == 0 )
      {
	__prints ( "Successfull execution of VD_isl_regex" );

	if ( fp = fopen ( ".str_rpt_2", "r" ) )
	{
	  i0 = 0;

	  while ( fgets ( lst, sizeof (lst), fp ) )
	  {
	    /*
	     * Remove '\n' at end...
	     */
	    if ( lst[strlen(lst) - 1] == '\n' ) lst[strlen(lst) - 1] = '\0';

	    __printf ( "lst[%d] = <%s>", `i0, lst` );

	    strcpy ( ret[i0++], lst );

	    if ( i0 > 9 )
	      break;
	  }
	  fclose ( fp );

	  for ( i0=0; i0 < 10 && ret[i0][0] ; i0++ )
	  {
	    __printf ( "ret[%d] = <%s>", `i0, ret[i0]` );
	  }
	}
      }
      else
      {
	__print_goto ( "wrapup : Failure execution of VD_isl_regex" );
	status = 0;
	goto wrapup;
      }
    }
    else
    {
      status = 0;
      goto wrapup ;
    }
  }

wrapup:

  __exitFunction  ( name = "VS_tmp_regex_solaris" );

  return (status);
}
