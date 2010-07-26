/* -- Include file for "CI report error" module.
      File dependency: msdef.h
   -- */
#ifndef cierrno_include
#	define cierrno_include

/* -- Max size of buffer to receive error message (including ending '\0').
   -- */
#ifndef MS_MAX_MSG_LENGTH
#	define MS_MAX_MSG_LENGTH 256
#endif

typedef char CIerror_msg[MS_MAX_MSG_LENGTH] ;
extern int CIreport_error() ;
 


/* -- Report CI error
		status		Error code ( defined in cierrordef.h )
		output	=	CI_ERR_MSGSYS, using message system (default).
				CI_ERR_STDOUT, to standard output.
				CI_ERR_STDERR, to standard error.
		buffer		writes error message to a buffer instead of the
				3 above. If `buffer' is not NULL, `output' is
				ignored.
				`buffer' must be declared as
					char buffer[MS_MAX_MSG_LENGTH] ;
				or	CIerror_msg	buffer ;
		RETURNS		CI_S_SUCCESS.

   Sample usage:

   1.	ci$report_error( status = msg ) ;

   2.	CIerror_msg err ;
   	ci$report_error( status = msg, buffer = err ) ;

   3.	ci$report_error( status = msg, output = CI_ERR_MSGSYS ) ;

   -- */

#omdef	ci$report_error( status, output = CI_ERR_MSGSYS, buffer = NULL )
	CIreport_error( (status), (output), (buffer) )
#endomdef

#endif

