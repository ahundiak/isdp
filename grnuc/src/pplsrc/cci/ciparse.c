/*
 * Etienne BEEKER
 * creation:27-3-86
 *
 * Partly recoded when CI became a standalone compiler by Alain FALASSE.
 */

/* -- Content of this file :
      - OPTget ( static )
      - CPPrun
      - cistat
      - FILEclose
      - FILEparse
      - main
   -- */
#define DEBUG 0
/*-INCLUDES-------------------------------------------------------------------*/
#include "exsysdep.h"
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "fcidef.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <sys/param.h>
#include <signal.h>

#ifdef BIG_ENDIAN
#ifndef hibyte
#define  hibyte(s)  ((unsigned char *)&(s))[0]
#endif
#endif

#if !defined(P_tmpdir)
#define P_tmpdir "/usr/tmp/"
#endif

typedef enum { ERROR = FALSE, RUN = TRUE, STOP } action ;
/*-STATICS--------------------------------------------------------------------*/
/* -- Name of user-requested pre-processor.
   -- */
SysVfname CPPname ;

/* -- Flags whether pre-processing is requested.
   -- */

char      CPPexec ;

/* -- Set of include files for pre-processor.
   -- */
static char	PCItag[CI_MAXTAG] ;
/*----------------------------------------------------------------------------*/
extern FILE	*yyin	;
void		STBdestroy();
void		GLOinit(), SYSinit(), LEXinit();
void		STRdump(), TDFdump(), ENMdump(), CSTdump(), UFNdump(),
  		TYIdump(), UOPdump(), VARdump();
void		STRfree(), TDFfree(), CSTfree(), ENMfree(), SWfree(),
		LABfree(), UFNfree(), UOPfree(), TYIfree(), IMPfree() ;

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static void OPTinit __((void));
static action OPTget __((int nopt, char **optlist));
static int warn_about_unused_symbols __((void));
static void PCIsigset __((void));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
static void OPTinit()	{
  CPPexec		= TRUE	;
  PCItag[0]		= EOSTR	;
  PCIopt.dumpinfo	= FALSE	;
  PCIopt.noptrchk	= FALSE	;
  PCIopt.noargchk	= FALSE	;
  PCIopt.unusedfn	= FALSE	;
  PCIopt.externfn	= FALSE	;
  PCIopt.warnmsgs	= TRUE  ;
  PCIopt.prtxsyms	= FALSE	;
  PCIopt.erlogstr	= stderr;
  PCIopt.nomsgdel	= FALSE	;
  PCIopt.noexinfo	= FALSE ;
  PCIopt.keepfile	= FALSE ;

} /* OPTinit */
/*----------------------------------------------------------------------------*/
action PCIxflag( sw ) char *sw ; {

	action rc = RUN ;

	     if( !strcmp( sw, NOPTRCHK ) ) PCIopt.noptrchk = TRUE ;
	else if( !strcmp( sw, NOARGCHK ) ) PCIopt.noargchk = TRUE ;
	else if( !strcmp( sw, UNUSEDFN ) ) PCIopt.unusedfn = TRUE ;
        else if( !strcmp( sw, EXTERNFN ) ) PCIopt.externfn = TRUE ;
	else rc = ERROR ;

	return rc ;
}
/*----------------------------------------------------------------------------*/
action PCIeflag( errlog ) char *errlog ; {

	action rc = RUN ;

	     if( !strcmp( errlog, "1" ) ) PCIopt.erlogstr = stdout ;
	else if( !strcmp( errlog, "2" ) ) PCIopt.erlogstr = stderr ;
	else if( ( PCIopt.erlogstr = fopen( errlog, "a" ) ) == NULL ) {
		PCIopt.erlogstr = stderr ;
		ERRusr( "FILEOP", "cannot open error log file", errlog ) ;
		rc = ERROR ;
	}

	return rc ;
}
/*----------------------------------------------------------------------------*/
static action OPTget( nopt, optlist )	int  nopt	;
					char **optlist	; {

/* --  Collects options
		-p<pre-processor>, -P, -V, -s, -I<include>, -h, -p, -d, -t, -D,
		-X<check options> -q
       INPUT  : nopt, optlist
       RETURNS: FALSE if no args else TRUE.
       NOTE   : for `nopt' options to scan `getopt'(3C) must be entered `nopt+1'
   -- */

  int		c		;
  action	rc = RUN	;
  extern char	*optarg		;
  extern int	opterr		;
  
#define cp( to, from, max ) strncpy( to, from, max )[max-1] = EOSTR

  OPTinit() ;
/*  nomsg = quiet = keep = FALSE ; */

  if( nopt > 0 ) {
    opterr = 0 ;
    while( ( c = getopt(	nopt + 1,
    				optlist	,
    				"p:PVsI:dht:D:X:e:qnmk" ) ) != EOF ) {
      switch( c ) {
	case 'p' : cp( CPPname, optarg, CI_PATH_MAX )	; break ;
	case 'P' : CPPexec = FALSE			; break ;
	case 'V' : civersion()				; break ;
	case 's' : PCIopt.warnmsgs = FALSE           	; break ;
	case 'D' : rc = (action)CPPopt( "-D", optarg )	; break ;
	case 'I' : rc = (action)CPPopt( "-I", optarg )	; break ;
	case 'd' : PCIopt.dumpinfo = TRUE		; break ;
	case 't' : cp( PCItag, optarg, CI_MAXTAG )	; break ;
	case 'h' : rc = (action)cihelp( 0 )		; break ;
	case 'e' : rc = PCIeflag( optarg )		; break ;
	case 'q' : PCIopt.noexinfo = TRUE		; break ;
	case 'n' : PCIopt.prtxsyms = TRUE		; break ;
	case 'm' : PCIopt.nomsgdel = TRUE		; break ;
	case 'k' : PCIopt.keepfile = TRUE		; break ;
	case 'X' : if( PCIxflag( optarg ) == RUN )	  break ;
	case '?' : rc = (action)cihelp( 1 )		; break ;
      } /* switch */
      if( rc == STOP || rc == ERROR ) break ;
    } /* while */
  } /* if */
#undef cp

/* -- "PPL" will be #defined for conditional compilations.
   -- */
   CPPopt( "-D", "PPL=1" ) ;
/* ERASE
  if( quiet ) {
  	strcat( PCItag, CI_QUIET_STRING ) ;
  }
  if( nomsg ) {
  	strcat( PCItag, CI_NOMSG_STRING ) ;
  }
  if( keep ) {
  	strcat( PCItag, CI_KEEP_STRING ) ;
  }
  */
  return rc ;

} /* OPTget */
/*----------------------------------------------------------------------------*/
static int warn_about_unused_symbols() {

/* -- Issues a warning  for the  declared but unused  symbols ( except those the
      names of which start with "M_" ).
      Initializes the GRobjs with NULL_OBJID at the same time. Writes used 
      externals to a ".n" file.
      RETURNS: TRUE if writing to ".n" succeeded else FALSE.
   -- */

  int	i, rc = TRUE		;
  char	*class, *type		;
  usage	*U			;
  emsg	err			;
  FILE *xfi = NULL		;

   PCI_Set_current_file( PCIfile ) ;

   for( i = 0, U = &PCIusd( 0 ) ; i < PCInvar ; i++, U++ ) {
	if( U->stat == VAR_NOT_USED && strncmp( PCIvar( i ), "M_", 2 )
	            && isidchar( PCIvar( i )[0] ) ) {
  	  if( PCIopt.warnmsgs ) {  
	    class = isextern( i ) ? " (external)" : "" ;
	    type  = isfunction( i ) ? "unused function"
		                    : "unused variable" ;
	    sprintf( err, "%.*s%s", MAXEMSG - 12, PCIvar( i ), class ) ;
	    ciwarning( type, err ) ;
	  } /* if */
	  if( isextern( i ) ) {
#if DEBUG
  printf( "Extern and not used <%s>\n", PCIvar( i ) ) ;
#endif
	  	PCIval( i ) = (char *) -1 ;
	  	PCI_G_externals--	  ;
	  }
	} else {
		if( isvar( i ) && isGRobj( i )
			       && !isextern( i )
                               && !isint( i ) ) GRobjinit( i ) ;
		if( isextern( i ) ) {
			if( !( rc = VARext( &xfi, PCIvar( i ) ) ) ) break ;
			PCIval( i ) = PCIval( 0 ) ;
#if DEBUG
  printf( "Extern and used <%s> <%u>\n", PCIvar( i ), PCIval( i ) ) ;
#endif
		}
	}
    } /* for */

 if( xfi != NULL ) rc = fclose( xfi ) == 0 ;

 return rc ;

} /* warn_about_unused_symbols */
/*----------------------------------------------------------------------------*/
void cistat() {

  printf( "\tLabels\t\t: %d\n\tVariables\t: %d\n", PCInlab, PCInvar ) ;
  printf( "\tExternals\t: %d\n", PCI_G_externals ) ;
  printf( "\tText size\t: %u bytes\n",
  	  2 * ( PCIseg.text - PCIdata->code[0].paramlist ) ) ;
  printf( "\tInstr #  \t: %u\n", PCInins ) ;
}
/*----------------------------------------------------------------------------*/
int FILEclose()

/* -- KLUDGE : pclose return code is < -1 on certain parsing error (?). Hence
      the test on `u'.
   -- */

{ int rc = FALSE, u ; emsg tmp ;

  if( CPPexec )
  	switch( u = pclose( yyin ) ) {
          case -1 : rc = ERRsys( "pipe close error" )	; break ;
          case 0  : rc = TRUE				; break	;
          default : if( u > 0 ) {
          	      sprintf( tmp, "error code %d", hibyte( u ) ) ;
                      rc = ERRusr( "PREPRO", "pre-processor error", tmp ) ;
          	    }   
        }
  else if( fclose( yyin ) != 0 ) rc = ERRsys( "file close error" ) ;
  else rc = TRUE ;

  return rc ;

} /* FILEclose */
/*----------------------------------------------------------------------------*/
int FILEparse( fcmd )	SysVfname fcmd ; {

/* -- Parse file and writes compiled code to disk.
      INPUT  : fcmd, name of file to parse.
               compiled, name of compiled file.
      RETURNS: TRUE or FALSE ( for many reasons ! )
   -- */

  int		stat, rc = FALSE	;
  SysVfname	infile			;

#if DEBUG
  printf( "FILEparse: ENTER <%s>\n", fcmd ) ;
#endif
 if( CPPrun( strcpy( infile, fcmd ), &yyin ) ) {
#if DEBUG
  printf( "FILEparse: B4 alloc_ci_data\n" ) ;
#endif
   if( alloc_ci_data(  MAXVAR		,
		       MAXDATA		,
		       INSQUANTUM	,
		       TXTQUANTUM	,
		       MAXFUNC		,
		       &PCIdata		,
		       &PCIseg.data	,
		       &PCIseg.text	) ) {
#if DEBUG
  printf( "FILEparse: PCIseg.text = %u\n", PCIseg.text ) ;
  printf( "FILEparse: PCIcode[0].paramlist = %u\n", PCIcode[0].paramlist ) ;
#endif
      if( !STBcreate() ) {
	  rc = ERRmem( "symbol table" ) ;
	  goto PANIC ;
       } else {
    	  GLOinit( infile )	;
          SYSinit()		;
	  LEXinit()		;
#if DEBUG
  printf( "FILEparse: B4 yyparse\n" ) ;
#endif
          stat = yyparse()	;
#if DEBUG
  printf( "FILEparse: stat %d PCIerr %d\n", stat, PCIerr ) ; fflush( stdout ) ;
#endif
          if( rc = FILEclose() ) {
#if DEBUG
  printf( "FILEparse: B4 LAB...\n" ) ; fflush( stdout ) ;
#endif
            if( !( rc = !stat && !PCIerr && LABcheck() && LABresolve() ) )
          	fprintf( PCIopt.erlogstr, "*** exiting with syntax error(s).\n\n" ) ;
            else rc = warn_about_unused_symbols() ;
	 }
#if DEBUG
  printf( "FILEparse: rc %d\n", rc ) ; fflush( stdout ) ;
#endif
    	 /* STBdestroy() ; */
      } /* if STBcreate */
    } /* if alloc_ci_data */ else goto PANIC ;
  } /* if CPPrun */ else {

	PANIC : exit( 0 ) ;
  }

#if DEBUG
  printf( "FILEparse: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* FILEparse */
/*----------------------------------------------------------------------------*/
int MKdot_e( dot_u, dot_e )	SysVfname dot_u, dot_e ; {

/* -- Transforms a ".u" file name into a ".e". Erases previous ".e" if any.
      INPUT  : dot_u, supposed ".u" file.
      OUTPUT : dot_e, ".e" file.
      RETURNS: FALSE if "dot_u" is not a ".u" else TRUE.
      NOTE   : if `dot_u' is an empty string `dot_e' is set to CMP_DEF.
   -- */

		register char *p_dot ; int rc = TRUE ;

  if( *dot_u == EOSTR ) strcpy( dot_e, CMP_DEF ) ;
  else {
  	p_dot = strchr( dot_u, EOSTR ) ;

  	if( *--p_dot == SRC_EXT && *--p_dot == DOT ) {
  		strcpy( dot_e, dot_u )[(int) ( p_dot - dot_u + 1 )] = CMP_EXT ;

  	} else {
	   rc = ERRusr( "SRCNAM", "source file must end with \".u\"", NULL ) ;
  	}
  }

  return rc ;

} /* MKdot_e */
/*----------------------------------------------------------------------------*/
int PCIdump( source )	SysVfname source ; {

/* -- Writes compilation facts onto a `.d' file. Must be called BEFORE any
      freeing of global data occurs !.
   -- */

  SysVfname	listing			;
  FILE		*dump			;
  int		rc = TRUE		;

  if( PCIopt.dumpinfo ) {
  	*( strchr( strcpy( listing, source ), EOSTR ) - 1 ) = 'd' ;
#if DEBUG
  printf( "PCIdump : writing <%s>\n", listing ) ;
#endif
  	if( ( dump = fopen( listing, "w" ) ) != NULL ) {
  		fprintf( dump, "\n\tCCI %s.%d file : %s\n\n",
  				CI_VERSION_NUMBER,
  				PCI_VERSION	 ,
  				source		 ) ;
  				
  		TDFdump( dump ) ;	/* Dump typedefs	*/
  		STRdump( dump ) ;	/* Dump unions & structs*/
  		ENMdump( dump ) ;	/* Dump enums		*/
  		VARdump( dump ) ;	/* Dump variables	*/
  		CSTdump( dump ) ;	/* Dump constants	*/
  		UFNdump( dump ) ;	/* Dump user-functions	*/
  		TYIdump( dump ) ;	/* Dump typeinits	*/
  		UOPdump( dump ) ;	/* Dump overloaded ops	*/
  		fclose ( dump ) ;
  	} else rc = ERRusr( "FILEOP", "cannot open file", listing ) ;
  }

  return rc ;

} /* PCIdump */	 
/*----------------------------------------------------------------------------*/
int MKcode( file, show )	SysVfname file ; int show ; {

/* -- Compiles and stores the file after various checks.
      INPUT  : file, name of file to compile
      RETURNS: TRUE or FALSE
   -- */

  int		rc			;
  SysVfname	compfile		;
  emsg		e			;

#if DEBUG
       printf( "MKcode: ENTER\n" ) ; fflush( stdout ) ;
#endif
/* -- Generates name for compiled file.
   -- */
  if( rc = MKdot_e( file, compfile ) ) {

/* -- Parse file.
   -- */
	if( IS_READ( file ) || IS_EMPTY( file ) ) {

  		unlink( compfile ) ;
		if( show ) printf( "%s:\n", file ) ;
#if DEBUG
       printf( "MKcode: parsing <%s>\n", file ) ; fflush( stdout ) ;
#endif
/* --		Dump run-time options into file tag.
   -- */
      		if( rc = FILEparse( file ) ) {

		if( PCIopt.noexinfo ) strcat( PCItag, CI_QUIET_STRING ) ;
		if( PCIopt.nomsgdel ) strcat( PCItag, CI_NOMSG_STRING ) ;
		if( PCIopt.keepfile ) strcat( PCItag, CI_KEEP_STRING  ) ;

/* -- Store file.
   -- */
#if DEBUG
  printf( "MKcode: PCIseg.text = %u\n", PCIseg.text ) ;
  printf( "MKcode: PCIcode[0].paramlist = %u\n", PCIcode[0].paramlist ) ;
#endif
  	  	if( !store_parsed(	compfile   , PCItag	 	,
  	  		     		PCIdata    , PCIseg.data	,
    	                     		PCIseg.text, PCI_G_externals	,
    	                     		e				 ) )
	  		rc = ERRsys( e ) ;
		else rc = PCIdump( file ) ;
#if DEBUG
       cistat() ;
#endif
		}
#if DEBUG
       printf( "MKcode: B4 frees\n" ) ; fflush( stdout ) ;
#endif
		STRfree() ; TDFfree() ; CSTfree() ; ENMfree() ; SWfree() ;
		LABfree() ; UFNfree() ; UOPfree() ; TYIfree() ; IMPfree();
		STBdestroy() ;
		free_ci_data( PCIdata, 0 ) ;
#if DEBUG
       printf( "MKcode: after frees\n" ) ; fflush( stdout ) ;
#endif
	} else ERRusr( "FILEOP", "cannot read", file ) ;
  }

#if DEBUG
       printf( "MKcode: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;
 
} /* MKcode */
/*----------------------------------------------------------------------------*/
int sortargs( argc, argv )	int  argc   ;
				char **argv ; {

/* -- Separates options ( preceded by '-' ) from the rest ( believed to be file
      names ). File names are put away first.
      INPUT  : argc, number of arguments.
      UPDATE : argv, argument array ( rearranged as explained above )
      RETURNS: the number of file names ( i.e. non-option args ) found
   -- */

			int i, j, nfiles ; char *s ;

   nfiles = 0 ; i = 0 ;
   while( i < argc ) {
   	if( *argv[i] == OPTION ) {
   		j = i + 1 ;
   		while( j < argc ) {
   			if( *argv[j] != OPTION ) { 
   				s = argv[i] ; argv[i] = argv[j] ; argv[j] = s ;
				nfiles++ ;
   				break ;
			}
			j++ ;
		}
	} else nfiles++ ;
	i++ ;
   }
   return nfiles ;

} /* sortargs */		
/*----------------------------------------------------------------------------*/
void PCIwriterc( rc ) int rc ; {
	SysVfname ccirc ; FILE *f ;

#if DEBUG
  printf( "PCIwriterc: ENTER\n" ) ; fflush( stdout ) ;
#endif
	sprintf( ccirc, "%s%s%d", P_tmpdir, "ccirc", getpid() ) ;
#if DEBUG
  printf( "PCIwriterc: after sprintf <%s>\n", ccirc ) ; fflush( stdout ) ;
#endif
	if( ( f = fopen( ccirc, "w" ) ) != NULL ) {
#if DEBUG
  printf( "PCIwriterc: after fopen\n" ) ; fflush( stdout ) ;
#endif
		fprintf( f, "%d", rc )	;
#if DEBUG
  printf( "PCIwriterc: after fprintf\n" ) ; fflush( stdout ) ;
#endif
		fclose( f )		;
	}
#if DEBUG
  printf( "PCIwriterc: EXIT\n" ) ; fflush( stdout ) ;
#endif
}
/*----------------------------------------------------------------------------*/
static void PCIsigset() {
	void PCIcatch() ;

	signal( SIGBUS , PCIcatch ) ;
	signal( SIGFPE , PCIcatch ) ;
	signal( SIGSEGV, PCIcatch ) ;
	signal( SIGSYS , PCIcatch ) ;
	signal( SIGILL , PCIcatch ) ;
}
/*----------------------------------------------------------------------------*/
int main( argc, argv )	int  argc    ;
			char *argv[] ; {

/* -- How to invoke PCI : see cihelp() in cierrmess.c
   -- */

		int nfiles, i, sysrc = 0 ; void CPPfree() ;

  PCIsigset() ;
  nfiles = sortargs( argc, argv ) ;
/* -- Get options
   -- */
  switch( OPTget( argc - nfiles, &argv[nfiles - 1] ) ) {
    case RUN	:
  	switch( nfiles ) {
  		case 1  : sysrc = !MKcode( ""     , FALSE ) ;  break ;
  		case 2  : sysrc = !MKcode( argv[1], FALSE ) ;  break ;
  		default : for( i = 1 ; i < nfiles ; i++ ) {
				if( !MKcode( argv[i], TRUE ) ) sysrc = 1 ;
		  	  }
	}
	break ;
    case STOP	:	      break ;
    case ERROR	: sysrc = 1 ; break ;
  }
#if DEBUG
  printf( "main: B4 CPPfree\n" ) ; fflush( stdout ) ;
#endif
  CPPfree() ;
#if DEBUG
  printf( "main: after CPPfree\n" ) ; fflush( stdout ) ;
#endif

  /* I have no idea why they are doing this - so I commented it ...

  PCIwriterc( sysrc ) ;
*/

#if DEBUG
  printf( "main: after PCIwriterc\n" ) ; fflush( stdout ) ;
#endif

  return sysrc ;
  
} /* main */
/*----------------------------------------------------------------------------*/
