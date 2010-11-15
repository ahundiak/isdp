#include <sys/types.h>
#include <string.h>
#include <stdio.h>

/* dmb:11/04/91: This is not needed on Clipper and causes redeclaration */
/*  errors on Sun */
/* #include <varargs.h> */

#include "UMSfile.h"
#include "UMS.h"
#include "UMCcomp.h"
#include "COMP.h"

/* include stdarg.h and pumc_all.h for ansi */

#include <stdarg.h> 

#include "UMSpriv.h"
#include "pums_all.h"
#include "pumc_all.h"



/******************************************************************************

Doc:	UMCInitCOMP

Abstract:
	The UMCInitCOMP function locates the compiler's message file and
	loads the messages into memory.

        GMD 4/25/91  -- I am using the bootstrap error messages exclusively
                        so the error messages will always be in English.
                        So sue me.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_NOMSGFILE	-	Unable to load the message file

History:
	15-MAR-1989	sh	Creation date
	25-MAR-1989	tz	Pre-delivery tweek
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

******************************************************************************/

int	UMCInitCOMP( compName )

char	*compName;		/* i - Compiler name as keyed in by user*/
{

/* GMD 4/25/91   This is stubbed out so that the english bootstrap
                 error messages will be used instead.  For foreign
                 language error messges in UMScompile, this section
                 would have to be restored.                           */

	return( COMP_S_SUCCESS );
}

/******************************************************************************

Doc:	UMCErrorMsg

Abstract:
	The UMCErrorMsg function retrieves the given message (including
	variable substitution) and displays it to standard error (stderr).

Return Status:
	UMC_S_SUCCESS	-	Success

History:
	04-NOV-1989	tz	Creation date

        GMD 4/25/91   Decided to always use english bootstrap error messages
                      since the UMS system itself is broke as I work on this.
	10-07-91	sml	ansi-ized
					changed msgNum arg to long

******************************************************************************/

/* sml: 10-07-91	ansi-ize, remove va_list arg 
int	UMCErrorMsg( msgNum, msgFmt, va_alist )
int	msgNum;			 i - Message number			
char	*msgFmt;		 i - C format specification for vars	
va_dcl				 i - Variables to be substituted	
*/

/* sml:10-08-91		need to do prototyping here for variable length 
					args
*/
int	UMCErrorMsg( long msgNum, char * msgFmt, ... )
{
va_list	vars;
char	msgBuf[UMC_BUFLEN];

THREAD_DECL static	char	*bootMsgs[]={
		"",
		"Unable to find this file",
		"Illegal option",
		"No message text file",
		"More than one message text file",
		"Usage: $1 [-m <msg file>] [-p <prog file>] [-F] <text file>",
		"Usage: $1 [-m <msg file>] <text file>",
		"Processing message text file $1",
		"Not enough memory to process message text file",
		"Unable to open message text file $1",
		"Empty message text file",
		"Not a message text file; missing the `$1' line",
		"Not a message text file; `$1' is not the first line",
		"Line $1 : Missing component and/or base number",
		"Line $1 : Base number [$2] out of range ($3-$4)",
		"Line $1 : Component [$2] must be $3 to $4 characters long",
		"Line $1 : Component [$2] must start with a letter",
		"Line $1 : Missing keyword and/or value",
		"Line $1 : Invalid keyword [$2]",
		"Line $1 : COUNT [$2] out of current range ($3-$4)",
		"Line $1 : Invalid label [$2]; format <COMP_T_EXTENSION>",
		"Line $1 : Component missing; used `$2'",
		"Line $1 : Invalid component [$2]; used `$3'",
		"Line $1 : Type missing; used '$2'",
		"Line $1 : Invalid type [$2]; used '$3'",
		"Line $1 : Extension missing",
		"Line $1 : Extension too long; truncated to `$2'",
		"Line $1 : Secondary key missing after the comma",
		"Line $1 : Secondary key too long; truncated to `$2'",
		"Line $1 : Blank message",
		"Line $1 : Message count greater than $2 maximum",
		"No messages defined",
		"Error writing message file $1",
		"Created message file $1",
		"Error writing programming file $1",
		"Created programming file $1",
		"Process terminated",
		"Success",
		"End of file"
		};
int		idx, numVar;
char		newMsgFmt[128], varBuf[UMC_BUFLEN];

	/* sml:10-07-91		ansi-ize, add 2nd arg to va_start 
	va_start( vars );
    */
	va_start( vars, msgFmt );

	if ( msgFmt )
	{
		_UMSPrepFormat( newMsgFmt, &numVar, msgFmt );
		vsprintf( varBuf, newMsgFmt, vars );
	}
	else
	{
		numVar = 0;
		varBuf[0] = '\0';
	}
	idx = msgNum;		/* I didn't make the numbers fancy	*/
	_UMSSubstitute( msgBuf, bootMsgs[idx], varBuf, numVar );

	va_end( vars );
/*	fprintf( stderr, "%s\n", msgBuf ); */
        UMCWriteLogComments(msgBuf);

	return( COMP_S_SUCCESS );
}
