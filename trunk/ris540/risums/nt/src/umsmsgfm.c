#include <sys/types.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <malloc.h>

#include "UMSpriv.h"
#include "UMS.h"
#include "pums_pub.h"

THREAD_DECL extern int UMSexpand_backslash_mode;



/**************************************************************************

Doc:	_UMSPrepFormat
Private:

Abstract:
	The _UMSPrepFormat function counts the conversion specifications in
	the format string and creates a format string with '\1's between them.

	The new format string should be used in a sprintf statement to convert
	C variables into a buffer of '\1' delimited strings.

Return Status:
	UMS_S_SUCCESS	-	Success

**************************************************************************/

int	_UMSPrepFormat( newMsgFmt, numArg, msgFmt )
 char	*newMsgFmt;		/* o - Format string containing '\1' delimited	*/
						/*      conversion specifications				*/
 int	*numArg;		/* o - Number of conversion spec's				*/
 char	*msgFmt;		/* i - Format string containing conversion		*/
						/*      specifications							*/
{
char	*tmpPtr, *tmpPtr1, tmpMsgFmt[128], msgFmtBuf[128];

	*numArg = 0;

	strcpy( tmpMsgFmt, msgFmt );

	tmpPtr = strchr( tmpMsgFmt, '%' );
	*tmpPtr = '\0';
	sprintf( newMsgFmt, "%s%%", tmpMsgFmt );
	tmpPtr1 = tmpPtr + 1;

	while ( tmpPtr = strchr( tmpPtr1, '%' ) )
	{
		*tmpPtr = '\0';
		sprintf( msgFmtBuf, "%s%c%%", tmpPtr1, '\1' );
		strcat( newMsgFmt, msgFmtBuf );
		( *numArg )++;
		tmpPtr1 = tmpPtr + 1;
	}

	strcat( newMsgFmt, tmpPtr1 );
	( *numArg )++;

	return( UMS_S_SUCCESS );
}

/**************************************************************************

Doc:	_UMSSubstitute
Private:

Abstract:
	The _UMSSubstitute function replaces the place holders in the
	message text with the appropriate strings (delimited by '\1')
	from the variable buffer.  

Return Status:
	UMS_S_SUCCESS	-	Success

History:
	Created by Teresa Zager.
	08-28-91	sml	added code to allow backslashed chars
        12-13-93        sml     Check if in expand_backslash mode
**************************************************************************/

int	_UMSSubstitute( msgBuf, textBuf, varBuf, numArg )
 char	*msgBuf;		/* o - Message with substitutions		*/
 char	*textBuf;		/* i - Message with place holders		*/
 char	*varBuf;		/* i - Variable buffer containing '\1'	*/
						/*      separated strings				*/
 int	numArg;			/* i - Number of strings in varBuf		*/
{
int	argNum;
char	tmpVarBuf[UMS_MAX_BUFLEN], tmpTextBuf[UMS_MAX_BUFLEN];
char	*varPtr, *varPtr1, *textPtr, *textPtr1, *frontOfBuffer;

	if ( textBuf[0] == '\1' && textBuf[1] == '\1' &&
	     textBuf[2] == '\0' )		/* Blank message case	*/
	{
		msgBuf[0] = '\0';
		return( UMS_S_SUCCESS );
	}

	strcpy( tmpVarBuf, varBuf );
	strcpy( tmpTextBuf, textBuf );
	msgBuf[0] = '\0';

	textPtr = tmpTextBuf;
	while ( textPtr1 = strchr( textPtr, '$' ) )
	{
		*textPtr1 = '\0';
		strcat( msgBuf, textPtr );
		textPtr1++;

		if ( isdigit( *textPtr1 ) )	/* Numeric place holder	*/
		{
			argNum = strtol( textPtr1, &textPtr1, 10 );
			if ( argNum > 0 && argNum <= numArg )
			{
				varPtr = tmpVarBuf;
				while ( --argNum )
					varPtr = strchr( varPtr, '\1' ) + 1;
				if ( varPtr1 = strchr( varPtr, '\1' ) )
					*varPtr1 = '\0';
				strcat( msgBuf, varPtr );
				strcpy( tmpVarBuf, varBuf );
			}
		}
		else if ( *textPtr1 == '*' )	/* The `*' place holder	*/
		{
			textPtr1++;
			argNum = numArg;
			varPtr = tmpVarBuf;
			while ( --argNum )
			{
				varPtr1 = strchr( varPtr, '\1' );
				*varPtr1 = '\0';
				strcat( msgBuf, varPtr );
				varPtr = varPtr1 + 1;
			}
			strcat( msgBuf, varPtr );
			strcpy( tmpVarBuf, varBuf );
		}
		else if ( *textPtr1 == '$' )	/* Really want a `$'	*/
		{
			textPtr1++;
			strcat( msgBuf, "$" );
		}
		else			/* Error condition, do EXNUC way*/
		{
			textPtr1++;			/* Swallow char	*/
			strcat( msgBuf, textPtr );	/* Repeat prev	*/
		}

		textPtr = textPtr1;
	}

	strcat( msgBuf, textPtr );

        /*****************************************************/
        /* sml:12-13-93:TR 249305525                         */
        /*  Check if not in expand_backslash mode before     */
        /*  converting backslashes to C control chars.       */
        /*****************************************************/
        
        if (!UMSexpand_backslash_mode)
        {        
	/*
	 *	sml:08-28-91	Add code to substitute special chars for
	 *					back-slashed chars (as in C) in messages
	 */

	textPtr = (char *)malloc(strlen(msgBuf)+1);
	frontOfBuffer = textPtr;   /*sml:05-25-94:remember front of buffer */
	strcpy(textPtr, msgBuf);
	
	msgBuf[0] = '\0';
	/* look for backslashes */
	while ( textPtr1 = strchr( textPtr, '\\' ) ) 
	{
		*textPtr1 = '\0';
		strcat( msgBuf, textPtr );
		textPtr1++;

		switch(*textPtr1)	/* determine if a special char */
		{
		  case 'n':	
			strcat(msgBuf,"\n");
			textPtr1++;
			break;

		  case 't':
			strcat(msgBuf,"\t");
			textPtr1++;
			break;

		  case 'b':
			strcat(msgBuf,"\b");
			textPtr1++;
			break;

		  case 'r':
			strcat(msgBuf,"\r");
			textPtr1++;
			break;

		  case 'v':
			strcat(msgBuf,"\v");
			textPtr1++;
			break;

		  case '\\':
			strcat(msgBuf,"\\");
			textPtr1++;
			break;

		  case '\"':
			strcat(msgBuf,"\"");
			textPtr1++;
			break;

		  case '\'':
			strcat(msgBuf,"\'");
			textPtr1++;
			break;

		}	/* end switch *textPtr */

		textPtr = textPtr1;
	}

	strcat( msgBuf, textPtr );

	/*************************************************/
	/* sml:05-13-94:TR 249402034:memory not freed    */
	/*  need to free memory malloced for textPtr.    */
	/* sml:05-25-94:NO TR                            */
	/*  Free using frontOfBuffer instead of textPtr  */
	/*  which has changed from when it was malloced. */
	/*************************************************/

	free(frontOfBuffer);

	} /* end if expand_backslash_mode */

	return( UMS_S_SUCCESS );
}
