/* $Id: VDreportobjs.C,v 1.2 2001/02/20 23:37:46 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdat/report/VDreportobjs.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDreportobjs.C,v $
 *      Revision 1.2  2001/02/20 23:37:46  ramarao
 *      Increased the number of columns from 20 to 100
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/02/03  21:31:56  pinnacle
 * Replaced: vdat/report/VDreportobjs.C for:  by impd252 for vds
 *
 * Revision 1.2  1999/11/23  23:39:48  pinnacle
 * CR179900816
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/12/31  13:47:44  pinnacle
 * Moved from vdastree
 *
 * Revision 1.4  1997/12/05  09:29:24  pinnacle
 * Replaced: vdastree/report/VDreportobjs.C for:  by ksundar for vds
 *
 * Revision 1.3  1997/11/21  14:55:16  pinnacle
 * ah
 *
 * Revision 1.2  1997/11/21  14:38:12  pinnacle
 * ah
 *
 * Revision 1.1  1997/11/04  17:42:14  pinnacle
 * Created: vdastree/report/VDreportobjs.C by v250_int for vds
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *	10/23/97   ADZ		Creation Date. 
 *	11/21/97   ah           vslogname resolution
 *	12/30/97   ah		moved to vdat
 *	11/23/99   ylong	CR179900816, added ':' to be recognized 
 *	02/03/00   adz		CR179900809, add -S option into process.
 *	02/20/01   Rama Rao	Increased the number of columns from 20 to 100.
 *************************************************************************/

/* ah
 * vslogname is not in vds product, tried switching to vdlogname but
 * get unresolved symbol still so just replaced the routine
 * with the actual two lines of code
 */
#include <stdio.h>
#include <sys/param.h>
#include <string.h>
#include <stdlib.h>
#include "pwd.h"

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
#include "OMversion.h"
#include "exmacros.h"
#include "msmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "go.h"
#include "vdsmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_globalmsg.h"

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
 * Prototypes Include Files.
 */
#include	"v_ioproto.h"

/*
 * Temporary : ONLY until $MODEL/bin/Model on Solaris has been linked with the proper library
 */
static int VDrp_INTEL_Solaris;

/*----------------------------------------------------------------------------*/
static char *VD_precompile( string, argc, argt )

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
 * #define STR	"(\".{0,29}\")"		-- does  NOT WORK  on Solaris --
 */
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

	SetProc( VD_precompile ); Begin

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

	End

	return t ;

} /* VD_precompile */
/*----------------------------------------------------------------------------*/
/*VARGARS0*/
static int VD_parseReportFmtLine( va_alist ) va_dcl {

	/*
	 * arg 0	: text string		(char *)
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

	SetProc( VD_parseReportFmtLine ); Begin

	va_start( ap, 0 ) ;

	test	= va_arg( ap, char *	) ;
	pattern	= va_arg( ap, char *	) ;

	if( !( pre = VD_precompile( pattern, &argc, argt ) ) ) goto wrapup ;

	__DBGpr_str( "test ", test );
	__DBGpr_str( "pre  ", pre );
	__DBGpr_int( "argc ", argc );

	memset ( ret, 0, MAXARGS * MAXARGSIZE );
	memset ( lst, 0, MAXARGSIZE );

	/*
	 * Temporary : ONLY until $MODEL/bin/Model on Solaris has been linked with the proper library
	 */
	if ( VDrp_INTEL_Solaris )
	{
	  int   sts;

	  sts = VD_tmp_regex_solaris ( test, pre, ret );

	  if ( ! sts )
	  {
	    __DBGpr_com ( "wrapup" );
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

	  __DBGpr_int(" strlen(cmp) ", strlen(cmp) );
	  __DBGpr_str(" cmp         ", cmp );

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


	wrapup :
		va_end( ap ) ;
		End
		return rc ;

} /* VD_parseReportFmtLine */
/*----------------------------------------------------------------------------*/
typedef struct COLUMN {
	int	width ;
	char	item [MAXARGSIZE],
		title[MAXARGSIZE] ;
} COLUMN ;

#define MAX_ITEMS_PER_LINE	100

int VD_reportObjects( infile, outfile, nbObjs, objList )

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

	SetProc( VD_reportObjects ); Begin

	VDrp_INTEL_Solaris = 0;

	if ( uname ( &unix_info ) != -1 )
	{
	  __DBGpr_str ( "unix_info.sysname  ", unix_info.sysname );
	  __DBGpr_str ( "unix_info.nodename ", unix_info.nodename );
	  __DBGpr_str ( "unix_info.machine  ", unix_info.machine );

	  if ( //strcmp ( unix_info.machine, "i86pc" ) == 0 &&
	         strcmp ( unix_info.sysname, "SunOS" ) == 0 )	// Test ONLY for "SunOS"
	  {
	    /*
	     * RESTORING ORIGINAL FUNCTIONALITY
	     *
	     * AFTER $MODEL/bin/Model on Solaris has been linked with the CORRECT library
	     *   (check file "$GRNUC/islmakelib" for "-lgen" versus "SUN_libPW.o"),
	     * THEN,
	     * it is ONLY required to set 'VDrp_INTEL_Solaris = 0' in order to
	     * PREVENT calling VD_tmp_regex_solaris() & executing VD_isl_regex ...!!!
	     */

	    VDrp_INTEL_Solaris = 1;	/* >>>> Set : VDrp_INTEL_Solaris = 0; <<<<< */
	  }
	}
	else
	{
	  perror ("uname failed");
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
		if( (*buffer == '#') || (*buffer == '\n') ) continue ;

		/*
		 * Remove \n.
		 */
		buffer[strlen(buffer)-1] = '\0' ;

		__DBGpr_str(" Buffer ", buffer );

		if( parse ) {
			rc = VD_parseReportFmtLine(	buffer,
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

			VD_getItemValueForReport(objList + j,
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

		End
		return writeErr ? 0 : 1 ;

} /* VD_reportObjects */
/*----------------------------------------------------------------------------*/
void VD_reportHeader( rF, title ) FILE *rF ; char *title ; {

	char				model[OM_K_MAXOSNAME_LEN] ;
	extern INGR_S_PRODUCT_DEF	VDS_appl_version_id ;

	struct passwd *passwd_ptr;

	SetProc( VD_reportHeader ); Begin

	ex$filename( name = model, len = OM_K_MAXOSNAME_LEN ) ;

      // Get login name
      passwd_ptr = getpwuid (getuid ());

	fprintf( rF,
		 "# %s\n# %s\n# User: %s\n# File: %s\n# Date: %s\n# Time: %s\n\n",
		 VDS_appl_version_id.curr_version,
		 title,
		 passwd_ptr->pw_name,
		 model,
		 VD_date(),
		 VD_time() ) ;

	End

} /* VD_reportHeader */
/*----------------------------------------------------------------------------*/
int VD_reportObjectsToASCII( msg, fFpath, fFname, rFname,title,nbObjs, objList )

IGRlong			*msg ;
IGRchar			*fFpath ;	/* Report File Path	*/
IGRchar			*fFname ;	/* Report File Name	*/
IGRchar			*rFname ;	/* Layout File Name	*/
IGRchar			*title ;	/* Report Title Name	*/
IGRint			nbObjs ;
struct GRobj_env	*objList ; {

	long			sts ;
	FILE			*rF = NULL ;	/* report file	*/
	FILE			*fF = NULL ;	/* layout file	*/
	IGRchar			pathName[MAXPATHLEN],
					relPath[MAXPATHLEN],
					firstDir[MAXPATHLEN],
					thenDir[MAXPATHLEN],
					absPath[MAXPATHLEN];

	SetProc( VD_reportObjectsToASCII ); Begin

	sts = OM_S_SUCCESS ;
	*msg = MSSUCC ;

    /*
     * Look for report-format file in product paths. Copy the name of
	 * the sub-directiry paths in the pathName buffer.
     */
	if( fFpath )
			sprintf( pathName, "%s/%s", fFpath, fFname );
	else	sprintf( pathName, "./%s", fFname );

	__DBGpr_str(" Total Path ", pathName );

    VD_findFileInPwdOrPath( msg, fFname, pathName ) ;
	if( ! (*msg & 1 )){
		__DBGpr_str(" Can't find file ", fFname );
                *msg = MSFAIL ; goto wrapup ;
	}

	/*
	 * Open the Output file for processing.
	 */
	fF = VD_openFile( msg, pathName, "w" );
	if ( ! fF ){
		__DBGpr_str(" Can't create the output file ", pathName );
                *msg = MSFAIL ; goto wrapup ;
	}

	/*
	 * Look for the report file.
	 */
	strcpy( relPath, rFname );
	strcpy( firstDir, "." );
	strcpy( thenDir, "config/reports" );
	VD_findFileInDirOrProductPaths( &sts, relPath, firstDir, thenDir,
									 absPath );
	__DBGpr_str(" Report Path", absPath );
	if( sts & 1 ){
		/*
		 * Open the report file for processing.
		 */
		rF = VD_openFile( msg, absPath, "r" );
		if ( !rF ) {

                ex$message(     msgnumb         = VD_gE_NotFound,
                                field           = ERROR_FIELD,
                                justification   = CENTER_JUS ) ;
                *msg = MSFAIL ; goto wrapup ;
        }

        if( title ) VD_reportHeader( fF, title ) ;
        sts = VD_reportObjects( rF, fF, nbObjs, objList ) ;

        if( !sts ) {
                /*
                 * Output error.
                 */
                ex$message(     msgnumb         = VD_gS_WrtFlErr,
                                field           = ERROR_FIELD,
                                justification   = CENTER_JUS ) ;

        } else {
                ex$message(     msgnumb         = VD_gI_CreatedObj,
                                field           = ERROR_FIELD,
                                justification   = CENTER_JUS,
                                type            = "%s",
                                var             = `pathName` ) ;
        }
	}

wrapup:

	fclose(rF);
	fclose(fF);
	return( sts ) ;
}

	

/*----------------------------------------------------------------------------*/

int VD_tmp_regex_solaris
(
  char  *test,
  char  *pre,
  char  ret[][MAXARGSIZE]
)
{
  int   i0, sts, status = 1;

  SetProc ( VD_tmp_regex_solaris ); Begin

  if ( VDrp_INTEL_Solaris )
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

      sts = system ( "VD_isl_regex" );

      if ( sts == 0 )
      {
	__DBGpr_com( "Successfull execution of VD_isl_regex" );

	if ( fp = fopen ( ".str_rpt_2", "r" ) )
	{
	  i0 = 0;

	  while ( fgets ( lst, sizeof (lst), fp ) )
	  {
	    /*
	     * Remove '\n' at end...
	     */
	    if ( lst[strlen(lst) - 1] == '\n' ) lst[strlen(lst) - 1] = '\0';

	    strcpy ( ret[i0++], lst );

	    if ( i0 > 9 )
	      break;
	  }
	  fclose ( fp );
	}
      }
      else
      {
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

	End
	return (status);
}
