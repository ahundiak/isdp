/* -- This modules handles the reporting of errors for CI.
   -- */

#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"
#include "msmacros.h"
/*#include "fidef.h"*/
#include "cidef.h"
#include "cimsg.h"
#include "cierrordef.h"
#include "cierrmacros.h"
/*----------------------------------------------------------------------------*/
/* -- Error number-to-message-number conversion array.
   -- */

static unsigned	err2msg[] = {
/*  1 */			CI_S_ciSUCCSS,
/*  2 */			CI_E_ciNO_VAR,
/*  3 */			CI_S_ciNOACCS,
/*  4 */			CI_S_ciNOSYMB,
/*  5 */			CI_E_ciNOMMRY,
/*  6 */			CI_S_ciNOLOAD,
/*  7 */			CI_E_ciNOFUNC,
/*  8 */			CI_W_ciXABORT,
/*  9 */			CI_E_ciFATLER,
/* 10 */			CI_E_ciUNKFIL,
/* 11 */			CI_E_ciCLNING,
/* 12 */			CI_E_ciLOADNG,
/* 13 */			CI_E_ciNOMODL,
/* 14 */			CI_E_ciDBOVRF,
/* 15 */			CI_E_ciINVARG,
/* 16 */			CI_E_ciACCCMP,
/* 17 */			CI_E_ciUNKERR,
/* 18 */			CI_E_ciBADEXC,
/* 19 */			CI_E_ciBADVER,
/* 20 */			CI_W_ciWRTDGN,
/* 21 */			CI_W_ciCLODGN,
/* 22 */			CI_W_ciOPNDGN,
/* 23 */			CI_E_ciNOFORM,
/* 24 */			CI_E_ciNOWIND,
/* 25 */			CI_W_ciWNNTFD,

} ;				

/*----------------------------------------------------------------------------*/
int CIreport_error( msg, out, buf ) long msg ; int out ; char *buf ; {

/* -- Interprets an error code.
      INPUT  : out, type of output desired:
			- IGE message system
			- standard output
			- standard error
			- no output
	       msg, error message code ( defined in cierrordef.h )
      OUTPUT : if message to be returned in a buffer ( `out' ignored ).
      RETURNS: CI_S_SUCCESS.
      NOTE   : if not NULL, `buf' must have dimension MS_MAX_MSG_LENGTH,
	       ( defined in msdef.h ).
      This function is PUBLIC.
   -- */

	int		index, sever	;
	FILE		*stream		;
	CIerror_msg	tmp		;
	char		*CIexmessage()	;

  if( msg == CI_S_SUCCESS ) index = 1 ;
  else {
  	sever = msg & SEVE ;
  	index = ( msg - (OM_FACILITY_CODE << 16) - 0X8000 - sever ) >> 3 ;
  }
#ifdef DEBUG
  printf( "CIreport_error : index %d\n", index ) ;
#endif

  index -= 1 ;
  if( index < 0 || index > CI_K_LAST_MSG_INDEX ) {
/* --	Bad error code specified.
   -- */
  	CIreport_error( (long)CI_E_UNK_ERRCODE, out, buf ) ;
  	goto WRAPUP ;
  }

  if( buf != NULL ) {
		ex$message(	msgnumb = err2msg[index],
				buff	= buf ) ;
  } else switch( out ) {

	case CI_ERR_MSGSYS : ex$message(	msgnumb = err2msg[index] ) ;
			     break ;

	case CI_ERR_STDOUT : stream = stdout ; goto PRINT ;

	case CI_ERR_STDERR : stream = stderr ;
			     PRINT :
			     fprintf( stream, "%s: ",
				     CIexmessage( CI_I_ciCMLGEX ) ) ;
				ex$message(	msgnumb = err2msg[index],
						buff	= tmp		) ;
			     fprintf( stream, "%s\n", tmp ) ; fflush( stream ) ;
			     break ;

  } /* switch */

  WRAPUP :
  return CI_S_SUCCESS ;

} /* CIreport_error */
/*----------------------------------------------------------------------------*/
int CIprog_error( msg, text )	long msg ; char *text ; {

extern char *CIexmessage ();

/* -- Reports programming errors. Internal use only.
   -- */
	CIerror_msg error ;

	ci$report_error(	status = msg,
				buffer = error ) ;

	fprintf( stderr, "*-*\n%s:\n\t-> %s\n\t-> %s\n*-*\n",
		 CIexmessage( CI_I_ciCMLGEX ), text, error ) ;

	fflush( stderr ) ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/

