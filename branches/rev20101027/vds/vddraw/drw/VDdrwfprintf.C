/* $Id: VDdrwfprintf.C,v 1.2 2001/02/15 00:34:08 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	Vddraw/drw / VDdrwfprintf.C
 *
 * Description:
 *	Various general, trace, warning and error print routines for parser
 *	Seperate routines used to avoid muliple packing/unpacking for varargs 
 *	Used by:
 *		Visual interpreter			vddraw/drw
 *		attribute expression interpreter:	vdtbl/parser	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwfprintf.C,v $
 *	Revision 1.2  2001/02/15 00:34:08  ramarao
 *	Removed v_dbgmacros.h include file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.6  1995/10/30  15:10:42  pinnacle
 * Replaced: vddraw/drw/VDdrwfprintf.C for:  by sundar for vds.240
 *
 * Revision 1.5  1995/07/27  23:17:38  pinnacle
 * Replaced: vddraw/drw/V*printf.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/05/11  19:12:30  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.3  1995/05/05  08:05:08  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.2  1995/03/31  10:52:22  pinnacle
 * Replace: by tlbriggs for OPE
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	3/21/95	   tlb		Add VD_drwParserWarn, VD_drwParserTrace, 
 *					VD_drwPrintMsg, VD_drwParserError
 *	5/2/95	   tlb		Change STDERR print format
 *				Increment VDyydrwnerrs
 *	5/9/95	   tlb		Add VD_drwPrintDebug, VD_drwPrintFlogFile
 *	7/25/95	   tlb		Add VD_drwSetLinePrefix
 *     10/30/95    Sundar	Include standards.h,varargs.h,stdarg.h during
 *				Solaris port.
 *************************************************************************/
/*
	I/VDS	Copy.
*/
#include <stdio.h>
#include <string.h>

#ifdef ENV5
#include <stdarg.h>
#endif
 
#include "igrdef.h"     /* define TRUE */
 
#ifdef X11
#include "standards.h"
#include <varargs.h>
#include <stdarg.h>
#endif


/* 
 * Can't include v_drwproto.h - fake arguments for variable lists 
 */
extern FILE	*VD_drwGetLogFile __(( void )) ;
extern char	*VD_drwGetInputFileName __(( void )) ;
extern void	 VD_drwPrintLinePrefix __(( void ));

/* 
 * Parser variables
 */
extern int	VDyydrwlineno ;
extern int	VDyydrwerrflag ;
extern int	VDyydrwnerrs;

static void (*VD_drwLinePrefixFunc)();			\
/* 
 * Standard logfile and screen formats
 */

#define SLOG_PRINT	{if (VD_drwLinePrefixFunc) (*VD_drwLinePrefixFunc)(); \
			 vfprintf (logFile, fmt, args ) ; }

#define LOG_PRINT(p,s)	{if (VD_drwLinePrefixFunc) (*VD_drwLinePrefixFunc)(); \
			 fprintf (logFile, " %s %s: ",(p), (s) );	\
			 vfprintf (logFile, fmt, args ) ; }

#define STDERR_PRINT(s) {fprintf (stderr, "  \"%s\", line %d: %s: ", \
				VD_drwGetInputFileName(), VDyydrwlineno, (s)); \
			vfprintf (stderr,  fmt, args); }

/*----------------------------------------------------------------------------*/
/* VD_drwSetLinePrefix
 *	set call-back function to print line prefix for parser
 */
void 
VD_drwSetLinePrefix (void (*foo) () ) 
	{ VD_drwLinePrefixFunc = (foo) ? foo : VD_drwPrintLinePrefix; }
/*----------------------------------------------------------------------------*/
/* VD_drwPrintLinePrefix
 *	standard line prefix for visual interpreter
 */ 
void 
VD_drwPrintLinePrefix () 
	{fprintf (VD_drwGetLogFile(), "%4d ", VDyydrwlineno);}
/*----------------------------------------------------------------------------*/
/* VD_drwPrintLogFile
 *	print to log file w/0 line number
 */
void VD_drwPrintLogFile (va_alist ) 
va_dcl 
{
	va_list	args ;
	char	*fmt ;
	FILE	*logFile = VD_drwGetLogFile() ;

	va_start( args, 0 ) ;
		fmt = va_arg( args, char * ) ;
		vfprintf (logFile, fmt, args);
	va_end( args ) ;

} /* VD_drwPrintf */
/*----------------------------------------------------------------------------*/
/* VD_drwPrintf
 *	printf for log file
 *		messages preceeded by line number
 */
void VD_drwPrintf (va_alist ) 
va_dcl 
{
	va_list	args ;
	char	*fmt ;
	FILE	*logFile = VD_drwGetLogFile() ;

	va_start( args, 0 ) ;
		fmt = va_arg( args, char * ) ;
		SLOG_PRINT ;
	va_end( args ) ;

} /* VD_drwPrintf */
/*----------------------------------------------------------------------------*/

/* VD_drwPrintMsg
 *	print trace message
 *		1st argument is prefix
 */
void 
VD_drwPrintMsg( va_alist ) 
	/*    	char	*prefix
	 *	char 	*format;
 	 *		... args
 	 */
va_dcl 
{
	va_list	args ;
	char	*fmt , *prefix;
	FILE	*logFile = VD_drwGetLogFile() ;

	va_start( args, 0 ) ;
		prefix = va_arg( args, char * ) ;
		fmt = va_arg( args, char * ) ;
		LOG_PRINT(prefix, "") ;
	va_end( args ) ;

} /* VD_drwPrintMsg */
/*----------------------------------------------------------------------------*/
/* VD_drwParserTrace 
 *	Print parser trace message with "*-*" prefix
 *	variable number of arguments
 */
void
VD_drwParserTrace( va_alist )	
	/* 	    char 	*format
 	 *			...args
	 */
va_dcl
{
	va_list	args ;
	char	*fmt ;
	FILE 	*logFile = VD_drwGetLogFile();

	va_start( args, 0 ) ;
		fmt = va_arg( args, char * ) ;
		LOG_PRINT ("*-*", "") ;
	va_end( args ) ;
}	
/*----------------------------------------------------------------------------*/
/* VD_drwParserDebug 
 *	Print parser debug message with "###" prefix
 *	variable number of arguments
 */
void
VD_drwParserDebug( va_alist )	
	/* 	    char 	*format
 	 *			...args
	 */
va_dcl
{
	va_list	args ;
	char	*fmt ;
	FILE 	*logFile = VD_drwGetLogFile();

	va_start( args, 0 ) ;
		fmt = va_arg( args, char * ) ;
		LOG_PRINT ("###", "") ;
	va_end( args ) ;
}	


/*----------------------------------------------------------------------------*/
/* VD_drwParserWarn
 *	Print parser warning
 *	variable number of arguments
 */

void
VD_drwParserWarn( va_alist )	
	/*		int	verbose		 TRUE/FALSE 
 	 *		char 	*format
 	 *			...args
	 */
va_dcl
{
	va_list	args ;
	char	*fmt;
	int	verbose;
	FILE 	*logFile = VD_drwGetLogFile();

        va_start( args, 0 ) ;
	
	/* Determine if verbose set */
	verbose = va_arg (args, int);
	fmt = va_arg (args, char *); 

	/* Verbose mode - print to logfile and screen if necessary */
	if ( verbose ){
		
		/* print log file message */
		LOG_PRINT ("!!!", "Warning") ;

		/* print stderr message if logfile is not on screen */
		if (logFile != stdout && logFile != stderr ) 
			STDERR_PRINT("Warning") ;
		}

	/* Not verbose mode - print to screen only */
	else 
		STDERR_PRINT("Warning") ;

    va_end( args ) ;

} /* VD_drwParserWarn */
/*----------------------------------------------------------------------------*/
/* VD_drwParserError
 *	Print parser error, set paser error flag
 *	For use in routines outside parser
 *	variable number of arguments
 */

void
VD_drwParserError( va_alist )	
	/*		int	verbose		 TRUE/FALSE 
 	 *		char 	*format
 	 *			...args
	 */
va_dcl
{
	va_list	args ;
	char	*fmt;
	int	verbose;
	FILE 	*logFile = VD_drwGetLogFile();

        va_start( args, 0 ) ;
	
	/* Determine if verbose set */
	verbose = va_arg (args, int);
	fmt = va_arg (args, char *); 

	/* Verbose mode - print to logfile and screen if necessary */
	if ( verbose ){
		
		/* print log file message */
		LOG_PRINT ("!!!", "Error") ;

		/* print stderr message if logfile is not on screen */
		if (logFile != stdout && logFile != stderr ) 
			STDERR_PRINT("Error") ;
		}

	/* Not verbose mode - print to screen only */
	else 
		STDERR_PRINT("Error") ;

	/* increment the number of errors
 	 *	this ensures a syntax error will be reported even 
 	 * 	if errror routine is called outside of parser
	 */
	VDyydrwnerrs++;

    va_end( args ) ;

} /* VD_drwParserError */
/*----------------------------------------------------------------------------*/
/* VD_drwSyntaxError
 *	Print parser syntax error, set paser error flag
 *	For use in routines outside parser
 *	variable number of arguments
 */

void
VD_drwSyntaxError( va_alist )	
	/*		int	verbose		 TRUE/FALSE 
 	 *		char 	*format
 	 *			...args
	 */
va_dcl
{
	va_list	args ;
	char	*fmt;
	int	verbose;
	FILE 	*logFile = VD_drwGetLogFile();

        va_start( args, 0 ) ;
	
	/* Determine if verbose set */
	verbose = va_arg (args, int);
	fmt = va_arg (args, char *); 

	/* Verbose mode - print to logfile and screen if necessary */
	if ( verbose ){
		
		/* print log file message */
		LOG_PRINT ("!!!", "Syntax Error") ;

		/* print stderr message if logfile is not on screen */
		if (logFile != stdout && logFile != stderr ) 
			STDERR_PRINT("Syntax Error") ;
		}

	/* Not verbose mode - print to screen only */
	else 
		STDERR_PRINT("Syntax Error") ;

	/* increment the number of errors
 	 *	this ensures a syntax error will be reported even 
 	 * 	if errror routine is called outside of parser
	 */
	VDyydrwnerrs++;

    va_end( args ) ;

} /* VD_drwSyntaxError */
