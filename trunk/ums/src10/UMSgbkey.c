#include <stdio.h>
#include <stdarg.h>

#include "UMS.h"
#include "UMSpriv.h"
#include "UMSfile.h"
#include "pums_pub.h"
#include "pums_pri.h"

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

  char	msgBuf[];	 o - Buffer for resulting message	
  char	*msgKey;	 i - Message key			
  char	*msgFmt;	 i - C format specification for vars	
  va_dcl		i - Variables to be substituted	

***********************************************************************/

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

  char	msgBuf[];	 o - Buffer for resulting message
  char	*msgKey;	 i - Message key
  char	*msgFmt;	 i - C format specification for vars
  va_list	vars;	 i - Variables to be substituted

**********************************************************************/

int UMSGetByKeyVar( char msgBuf[], char *msgKey, char *msgFmt,
         va_list vars )
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
