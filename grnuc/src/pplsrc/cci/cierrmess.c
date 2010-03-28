/*
 * Contains the error messages for syntax, system, overflow, user errors,
 * bugs, and obsolete formats.
 * Messages are output preceded by :
 *			PCI-cccccc-sss
 * where cccccc is a 6-letter code ( a mnemo ) for the message
 *       sss    is the severity, ERR : fatal, WNG : you may survive
 */

#include <stdio.h>
#include "pci.h"
#include "pcidef.h"
#include "fcidef.h"
#include "pcimacros.h"
#include <signal.h>
/*----------------------------------------------------------------------------*/
#define INPUT() ( !strcmp( PCI_Get_current_file(), "stdin" ) ?	\
				SRC_DEF : PCI_Get_current_file() )
/*-WARNING--------------------------------------------------------------------*/
int ciwarning( why, data ) char *why, *data ; {

  if( PCIopt.warnmsgs ) {
	fprintf( PCIopt.erlogstr, "\"%s\", WARNING - %s: %s.\n",
		 INPUT()	, why, data ) ;
	fflush( PCIopt.erlogstr ) ;
  }
  return TRUE ;
}
/*-OVERFLOW-------------------------------------------------------------------*/
int ERRovr( why, data ) char *why, *data ; {

  if( data != NULL ) 
  	fprintf( PCIopt.erlogstr, "PPL-OVRFLW-ERR, %s: %s.\n", why, data ) ;
  else	fprintf( PCIopt.erlogstr, "PPL-OVRFLW-ERR, %s -\n"   , why       ) ;
  fflush( PCIopt.erlogstr ) ;
  return FALSE ;
}
/*-SYNTAX-ERROR---------------------------------------------------------------*/
int ERRsynL( why, data, line )	char	*why, *data	;
				int	line		; {

/* -- Displays syntax error on screen. Flags that parsing failed.
   -- */
  if( data != NULL )
    fprintf( 	PCIopt.erlogstr, "\"%s\", line %d - %s: %s.\n",
    		INPUT()		, line		, why		, data ) ;
  else
    fprintf(	PCIopt.erlogstr, "\"%s\", line %d - %s.\n"	,
		INPUT()		, line		, why			) ;

  fflush( PCIopt.erlogstr ) ;
  PCIerr = TRUE ; return FALSE ;
}

int ERRsyn( why, data ) char *why, *data ; {
	return ERRsynL( why, data, (int) PCI_Get_current_line() ) ;
}
/*-SYNTAX-WARNING-------------------------------------------------------------*/
int WNGsyn( why, data ) char *why, *data ; {

  if( PCIopt.warnmsgs )
    if( data != NULL )
      fprintf( PCIopt.erlogstr, "\"%s\", line %d WARNING - %s: %s.\n",
               INPUT(), PCI_Get_current_line(), why, data ) ;
    else
      fprintf( PCIopt.erlogstr, "\"%s\", line %d WARNING - %s.\n"    ,
               INPUT(), PCI_Get_current_line(), why       ) ;
  fflush( PCIopt.erlogstr ) ;

  return TRUE ;
}
/*-SYSTEM---------------------------------------------------------------------*/
int ERRsys( msg ) char *msg ; {

   fprintf( PCIopt.erlogstr, "PPL-SYSTEM-ERR, system error - %s.\n", msg ) ;
   fflush( PCIopt.erlogstr ) ;
   return FALSE ;

} /* ERRsys */
/*-MEMORY---------------------------------------------------------------------*/
int ERRmem( msg )	char *msg ; { 

  fprintf( PCIopt.erlogstr,
           "PPL-MEMORY-ERR, memory error - cannot get space for %s.\n", msg ) ;
  fflush( PCIopt.erlogstr ) ;
  return FALSE ;

} /* ERRmem */
/*-SOFTWARE-BUG---------------------------------------------------------------*/
int cibugchk( procedure, msg )	char *procedure, *msg ; {

  fprintf( PCIopt.erlogstr,
 "PPL-BUGCHK-ERR, software error - procedure `%s' :\n\t-> %s.\n\tDetected in %s line %d\n",
           procedure, msg, INPUT(), PCI_Get_current_line() ) ;
  fflush( PCIopt.erlogstr ) ;
  return FALSE ;
}
/*----------------------------------------------------------------------------*/
void PCIcatch( sig ) int sig ; {

    char *signame ;
    switch( sig ) {
    	case SIGBUS	: signame = "bus error"			; break ;
    	case SIGFPE	: signame = "floating exception"	; break ;
    	case SIGSEGV	: signame = "memory fault"		; break ;
    	case SIGSYS	: signame = "bad system call"		; break ;
    	case SIGILL	: signame = "illegal instruction"	; break ;
    	default		: signame = "unknown signal"		; break ;
    }
    fprintf( 	PCIopt.erlogstr	,
    		"PCI-BUGSIG-ERR, system signal \"%s\", line %d - %s.\n",
    		INPUT(), (int) PCI_Get_current_line(), signame ) ;
    		
    exit( 1 ) ;
}
/*-OLD-COMMAND-OR-INSTRUCTION-------------------------------------------------*/
int cibygones( code, why, data )	char *code, *why, *data ; {

  if( data != NULL ) 
  	fprintf( PCIopt.erlogstr	, "PPL-%s-OBS, %s - file %s, line %d\n\t-> %s.\n",
  		 code, why, INPUT()	,
  	         PCI_Get_current_line()	, data				) ;
  else	fprintf( PCIopt.erlogstr	, "PPL-%s-OBS, %s - file %s, line %d\n",
  		 code, why, INPUT()	,
  		 PCI_Get_current_line()					) ;
  fflush( PCIopt.erlogstr ) ;

  return FALSE ;
}
/*-USER-----------------------------------------------------------------------*/
int ERRusr( code, why, data )	char *code, *why, *data ; {

  if( data != NULL ) 
  	fprintf( PCIopt.erlogstr, "PPL-%s-ERR, %s - %s.\n", code, why, data ) ;
  else	fprintf( PCIopt.erlogstr, "PPL-%s-ERR, %s -\n"    , code, why       ) ;
  fflush( PCIopt.erlogstr ) ;
  return FALSE ;
}
/*-USER-WARNING---------------------------------------------------------------*/
int WNGusr( why, data )	char *why, *data ; {

  if( PCIopt.warnmsgs )
    if( data != NULL )
       fprintf( PCIopt.erlogstr, "pci: WARNING - %s: %s.\n", why, data ) ;
    else
       fprintf( PCIopt.erlogstr, "pci: WARNING - %s.\n"    , why       ) ;
  fflush( PCIopt.erlogstr ) ;
  return TRUE ;
}
/*-NOT-IMPLEMENTED------------------------------------------------------------*/
int cinotimpl( why )	char *why ; {

  fprintf( PCIopt.erlogstr, "PPL-NOTIMP-ERR, %s - file %s, line %d\n", why, 
                   INPUT(), PCI_Get_current_line() ) ;
  fflush( PCIopt.erlogstr ) ;
  return FALSE ;

}
/*-HELP-----------------------------------------------------------------------*/
int cihelp( err ) int err ; {
				 int rc ;

  if( err ) rc = ERRusr( "INVARG", "invalid arguments", (char *)NULL ) ;
  else rc = FALSE ;
 
  fprintf( PCIopt.erlogstr, "\n\
	Usage : cci <files> -p<pre-processor> -P -V -s -I<include>\n\
		            -D<name> -D<name>=<def> -t<tag> -X<opt>\n\
		            -e<errlog> -n -q -m -k\n\
		<files> PPL source files, with `.u' extensions.\n\
		-p	wanted pre-processor ( default `/lib/cpp' ).\n\
		-P	supresses pre-processing ( -p option ignored ).\n\
		-V	prints version.\n\
		-s	silent, suppresses warnings.\n\
		-I	include file directories, same usage as `cc'.\n\
		-D	defines <name> to pre-processor, same  usage as `cc'.\n\
		-t	inserts <tag> ( max : 255 chars ) into compiled file.\n\
		-d	dumps parsing informations  to file with .d extension\n\
		-n	writes names  of used  external symbols to a .n file.\n\
		-q	quiet: disables information messages from the Command\n\
			Interpreter at runtime.\n\
		-m	disables  message/status/prompt  redisplay in case of\n\
			recursive invocations of the Command Interpreter.\n\
		-k	keeps a clone of file in memory at runtime.\n\
		-X	parsing options :\n\
			  - `externfn', considers undefined user functions as\n\
			                externals of type int.\n\
			  - `unusedfn', warns  about unused  user  functions.\n\
			  - `noptrchk', does not check pointer compatibility.\n\
			  - `noargchk', does not check actual/formal argument\n\
			                type match in user functions.\n\
		-e	error  log file, either `1' for standard output, `2',\n\
			for standard error or a file name (default : standard\n\
			error).\n\
SAMPLE EXAMPLE:\n\
	cci myfile.u -I/usr/include -I../cisrc -p../../om/bin/omcpp\n\
		     -DDEBUG=0 -t4thJuly2001 -Xnoargchk -Xnoptrchk\n\
		     -e/usr/tmp/ccilog\n\n"
          ) ;
  fflush( PCIopt.erlogstr ) ;
  return rc ;

} /* cihelp */
/*----------------------------------------------------------------------------*/

