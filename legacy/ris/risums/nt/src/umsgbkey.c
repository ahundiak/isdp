#include <stdio.h>
/* dmb:11/04/91: This is not needed on Clipper and causes redeclaration */
/*  errors on Sun */
/* #include <varargs.h> */

#include "UMS.h"
/*	sml:10-07-91	need to include stdarg.h (to replace varargs.h)
					for ansi C */
#include <stdarg.h>
#include "UMSpriv.h"
#include "pums_all.h"

/***********************************************************************

Doc:	UMSGetByKey

Abstract:
	The UMSGetByKey function returns the message text for the given
	primary or secondary message key in the supplied buffer.

	If a format and the matching variables are specified, the data
	will be substituted for the place holders in the message text.

Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message key not found
	other		-	Errors reading message file

***********************************************************************/
/*	sml: 10-07-91	ansi-ize
int	UMSGetByKey( msgBuf, msgKey, msgFmt, va_alist )
  char	msgBuf[];	 o - Buffer for resulting message	
  char	*msgKey;	 i - Message key			
  char	*msgFmt;	 i - C format specification for vars	
  va_dcl		i - Variables to be substituted	
*/

/* sml:10-08-91		do prototyping here for variable args */
int	UMSGetByKey( char msgBuf[], char *msgKey, char *msgFmt, ... ) 
{
  va_list	vars;
  int		sts;

/* sml:10-07-91		ansi-ize, specify last fixed parameter
  va_start( vars );
*/
  va_start( vars, msgFmt);
  sts = UMSGetByKeyVar( msgBuf, msgKey, msgFmt, vars );
  va_end( vars );
  return( sts );
}

/**********************************************************************

Doc:	UMSGetByKeyVar

Abstract:
    The UMSGetByKeyVar function returns the message text for the
    given message kye in the supplied buffer.

    If a format and the matching variables are specified, the data
    will be substituted for the place holders in the message text.
    The data is passed using the variable argument handling structure.

Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message key not found
	other		-	Errors reading message file

**********************************************************************/

int UMSGetByKeyVar( msgBuf, msgKey, msgFmt, vars )
  char	msgBuf[];	/* o - Buffer for resulting message	*/
  char	*msgKey;	/* i - Message key			*/
  char	*msgFmt;	/* i - C format specification for vars	*/
  va_list	vars;	/* i - Variables to be substituted	*/
{
  int	sts, numVar;
  char	varBuf[UMS_MAX_BUFLEN], textBuf[UMS_MAX_BUFLEN];

  sts = _UMSReturnByKey( textBuf, msgKey );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  if ( msgFmt )
    {
	char	newMsgFmt[128];

	_UMSPrepFormat( newMsgFmt, &numVar, msgFmt );
	vsprintf( varBuf, newMsgFmt, vars );
    }
  else
    {
	numVar = 0;
	varBuf[0] = '\0';
    }
		
  _UMSSubstitute( msgBuf, textBuf, varBuf, numVar );

  return( UMS_S_SUCCESS );
}
