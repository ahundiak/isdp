/* -- This module handles the pre-processor options and executes the
      pre-processor.
      NOTE: if the requested pre-processor is not found or no pre-processor
            has been specified, /lib/cpp is used.
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
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
#define DEBUG 0
/*----------------------------------------------------------------------------*/
static char	 *cpp__Dopts =
#ifdef IRIX
	"-D_MIPS_ISA=_MIPS_ISA_MIPS2 -D_MIPS_SZINT=32 -D_MIPS_SZLONG=32 -D_MIPS_SZPTR=32";
#else
	"";
#endif
static char      *cpp__options	= NULL	;
static char	 cpp__malloc	= FALSE	;
extern char      CPPexec		;
extern SysVfname CPPname		;
/*----------------------------------------------------------------------------*/
int CPPopt( opt, arg )	char *opt, *arg ; {

/* -- Fills arrays of "-I/-D" options.
      INPUT  : arg, argument to "-I/-D" option.
               opt, flag ( "-I" or "-D" ).
      RETURNS: FALSE if argument too long, too many options, or memory
               allocation failure, otherwise TRUE.
   -- */

		int		rc	= TRUE	;
		static unsigned size	= 0	;

#if DEBUG
  printf( "CPPopt: ENTER\n" ) ; fflush( stdout ) ;
#endif
  if( !size ) {
  	*MALLOC( cpp__options, size = 1, char ) = EOSTR ;
  	cpp__malloc = TRUE ;
  }
  
  size += ( strlen( arg ) + 3 ) ;

  if( ALLOC( cpp__options, size, char ) != NULL ) {
  	strcat( strcat( strcat( cpp__options, opt ), arg ), " " ) ;
  } else rc = ERRmem( "pre-processor options" ) ;
  
#if DEBUG
  printf( "CPPopt: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* CPPopt */
/*----------------------------------------------------------------------------*/
char *CPPcmd( pp, name ) SysVfname *pp, *name ; {

/* -- Sets up preprocessor command line.
      NOTE : "omcpp" is piped into "sed" because it splits PPL's 2-character
              supplementary operators as well as "0r" and "0R".
   -- */
		unsigned	l	;
		char		*c	;

		static char sedpipe[] =
		"( %s %s %s %s %s && true )";

/*********************************************************
| /bin/sed	-e \"s/\\: \\=/\\:\\=/\"		\
		-e \"s/\\: \\:/\\:\\:/\"		\
		-e \"s/\\. \\./\\.\\./\"		\
		-e \"s/\\< \\>/\\<\\>/\"		\
		-e \"s/\\%% \\%%/\\%%\\%%/\"		\
		-e \"s/\\@ \\@/\\@\\@/\"		\
		-e \"s/\\? \\?/\\?\\?/\"		\
		-e \"s/\\@ \\: /\\@\\:/\"		\
		-e \"s/\\@ \\* /\\@\\*REMOVE/\"		\
		-e \"s/\\@ \\+ /\\@\\+/\"		\
		-e \"s/\\0 \\r/\\0\\r/\"		\
		-e \"s/\\- \\^ /\\-\\^/\"		\
		-e \"s/\\0 \\R/\\0\\R/\""
**********************************************************/
#if DEBUG
  printf( "CPPcmd: ENTER\n" ) ; fflush( stdout ) ;
#endif
	if( cpp__options == NULL ) cpp__options = "" ;

/* -- command =
<pp><BLANK>"-U__STDC__"<BLANK><cpp__Dopts><BLANK><cpp__opt><BLANK><name><null>
   -- */
	l =   strlen( (char *)pp ) + 10 + strlen( cpp__Dopts )
			+ strlen( cpp__options ) + strlen( (char *)name )
			+ 4 + strlen( sedpipe ) ;
	if( MALLOC( c, l, char ) ) {
		sprintf( c, sedpipe, pp, "-U__STDC__", \
				cpp__Dopts, cpp__options, name ) ;
	}
#if DEBUG
	printf( "CPPcmd: <%s>\n", c ) ; fflush( stdout ) ;
#endif

	return c ;
}
/*----------------------------------------------------------------------------*/
int CPPrun( fcmd, input ) SysVfname fcmd ; FILE **input ; {

/* -- Runs file "fcmd" through user-defined pre-processor or cpp if requested,
      opens it for reading.
      INPUT   : fcmd, file to pre-process
                path_name, path name to include files
      RETURNS : FALSE if pre-processing or file/pipe open failed else
                TRUE.
  -- */
 
   char	*cipp		;
   int  rc  = TRUE	;
#if DEBUG
  printf( "CPPrun: ENTER\n" ) ; fflush( stdout ) ;
#endif

/* -- Try to find a pre-processor.
   -- */
  if( !CPPexec ) {
  	if( IS_EMPTY( fcmd ) ) *input = stdin ;
	else if( ( *input = fopen( fcmd, "r" ) ) == NULL ) {
      		rc = ERRusr( "FILEOP", "cannot open file", fcmd ) ;
	}
  } else {
  	if( IS_EXEC( CPPname ) ) {
  	   	if( !( cipp = CPPcmd( (SysVfname *)CPPname, (SysVfname *)fcmd ) ) ) {
  	   	  rc = ERRmem( "pre-processor command line" ) ;
  	   	}
  	} else {
  	   if( !IS_EMPTY( CPPname ) )
  	     WNGusr( "requested pre-processor not found (running /lib/cpp)",
  	               CPPname ) ;
  	   if( IS_EXEC( "/lib/cpp" ) ) {
  	   	if( !( cipp = CPPcmd( (SysVfname *)"/lib/cpp", (SysVfname *)fcmd ) ) ) {
  	   	  rc = ERRmem( "pre-processor command line" ) ;
  	   	}
	   } else rc = ERRusr( "NOPREP", "no pre-processor found", NULL ) ;
	
	}
	if( rc ) {
	   if( ( *input = (FILE *)popen( cipp, "r" ) ) == NULL ) {
		rc = ERRsys( "pipe open with pre-processor failed" ) ;
	   }
	   FREE( cipp ) ;
	}
   } /* if !CPPexec */
/* -- File has no name : give it one.
   -- */
  if( IS_EMPTY( fcmd ) ) strcpy( fcmd, SRC_DEF ) ;

#if DEBUG
	printf( "CPPrun: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* CPPrun */
/*----------------------------------------------------------------------------*/
void CPPfree() {
	if( cpp__malloc ) FREE( cpp__options ) ;
}
/*----------------------------------------------------------------------------*/
	
