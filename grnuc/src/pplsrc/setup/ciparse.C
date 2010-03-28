/*
 * contains the functions used by CI
 * to run cci, the ci compiler
 *
 * Etienne BEEKER
 * Alain FALASSE
 * Dec 1, '87
 */
#  	include "exsysdep.h"
#	include "OMminimum.h"
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msdef.h"
#	include "msmacros.h"
#	include "cimsg.h"
#	include <string.h>
#	include <stdio.h>
#	include <unistd.h>
#	include <sys/param.h>
/*
   rlw 2/14/92 added the line below since this macro is not defined
   on the Sun.  On the Clipper it is defined in param.h.
 */
#ifdef BIG_ENDIAN
#define	hibyte(X)	(((unsigned char *)&X)[1])
#endif
#	include "cidef.h"
#	include "cisetup.h"
/* -- 0: compiles without clock, 1: compiles with clock.
   -- */
#	define CI_CLOCK 0
/*----------------------------------------------------------------------------*/
#argsused
int ciruncompiler( ciid, file )

char *file ; OM_S_OBJID ciid ;

/* -- Use driver machinery to kick off CI compiler. If no driver was to be found
      do feel sorry for the dear user, but there is no way out here!
      INPUT  : file : name of file to compile
      RETURNS: 1 if it could compile and all went fine and 0 otherwise
      NOTE   : a) "ex$fork" is used to run the CI compiler and not "fork" :
               the memory amount required by normal forking causes disasters.
               b) paths to cci and pre-processor main contain shell variables
               this is why they are expanded. The source file `file' has already
	       been expanded in `get_cipath'. Include file paths ( -I options )
	       are not expanded since cci will pass them to the pre-processor
	       via `popen' in which they will be expanded by the shell.
   -- */

{	char		*argv[30]		;
  	int		nargs, rc, i		;
	UNIXpath	cci_exp, cpp_exp	;
	extern int	errno			;
	extern char	*sys_errlist[]		;	

  if( ex$is_driver_exist() ) {

/*      Fill arguments
        -------------- */
	nargs = 0 ;

	CIexpand( CIcci_path, cci_exp, CI_PATH_MAX + 1 ) ;
	if( access( cci_exp, X_OK | R_OK ) == -1 ) {
		ex$message(	msgnumb = CI_S_erCCIRUN ) ;
		ex$message(	msgnumb = CI_F_erCCIRUN		,
				type	= "%s"			,
				var	= `sys_errlist[errno]`	) ;
		return 0 ;
	}

	CIexpand( CIprepronm, cpp_exp, CI_PATH_MAX + 1 ) ;
	argv[nargs++] = cci_exp     	;
	argv[nargs++] = file      	;
	argv[nargs++] = cpp_exp		;

	for( i = 0 ; CIcciargs[i] != NULL ; i++ ) {
#ifdef DEBUG
  printf( "cci arg <%s>\n", CIcciargs[i] ) ;
#endif
		argv[nargs++] = CIcciargs[i] ;
	}
       	argv[nargs++] = CIeroutput == 1 ? "-V" : "-e1"      	;

	switch( CIeroutput ) {
#if CI_CLOCK
		case 0 : rc = CIpipe( ciid, nargs, argv ) ;
			 break ;
#else
		case 0 :
#endif
		case 1 : rc = ex$fork(	num_entry = nargs	,
	              			argu	  = argv	,
	             			wait_flag = 1		) ;
/* --			The return code from cci is in the 2nd byte ( 0 means
			success for cci )
   --*/
			 rc = hibyte( rc ) == 0 ;
			 break ;

	}
  } else {
	ex$message( msgnumb = CI_F_lsNODRIV ) ;
	rc = 0 ;
  }


  return rc ;

} /* ciruncompiler */
