#include <stdio.h>
#include <stdarg.h>

#include "UMS.h"
#include "UMSpriv.h"
#include "UMSfile.h"
#include "pums_pub.h"
#include "pums_pri.h"

/**********************************************************************

Doc:	UMSGetByNum

Abstract:
	The UMSGetByNum function returns the message text for the given
	message number in the supplied buffer.

	If a format and the matching variables are specified, the data
	will be substituted for the place holders in the message text.

Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message number not found
	other		-	Errors reading message file

  char	msgBuf[];	 o - Buffer for resulting message
  int	msgNum;		 i - Message number			
  char	*msgFmt;	 i - C format specification for vars	
  va_dcl		 i - Variables to be substituted	

**********************************************************************/

/* sml:10-08-91		do prototyping here for variable args 
					change msgNum to long
*/
int UMSGetByNum ( char msgBuf[], long msgNum, char *msgFmt, ... )
{
  va_list	vars;
  int		sts;

/* sml:10-07-91		ansi-ize va_start, add last fixed param as 2nd arg */
  va_start( vars, msgFmt );

  sts = UMSGetByNumVar( msgBuf, msgNum, msgFmt, vars );
  va_end( vars );
  return( sts );
}

/**********************************************************************

Doc:	UMSGetByNumVar

Abstract:
    The UMSGetByNumVar function returns the message text for the given
    message number in the supplied buffer.

    If a format and the matching variables are specified, the data
    will be substituted for the place holders in the message text.
    The data is passed using the variable argument handling structure.
	
Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message number not found
	other		-	Errors reading message file

  char	msgBuf[];	 o - Buffer for resulting message
 sml:09-20-91		change to long for PC limitations
  long	msgNum;		 i - Message number
  char	*msgFmt;	 i - C format specification for vars
  va_list	vars;	 i - Variables to be substituted
**********************************************************************/

int UMSGetByNumVar( char msgBuf[], long msgNum, char *msgFmt,
        va_list vars )
{
  int	sts, numVar;
  char	varBuf[UMS_MAX_BUFLEN], textBuf[UMS_MAX_BUFLEN];

  sts = _UMSReturnByNum( textBuf, msgNum );
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
