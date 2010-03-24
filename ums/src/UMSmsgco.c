#include <sys/types.h>
#include <string.h>
#include <stdarg.h>

#include <UMS.h>
#include <UMSpriv.h>
#include <UMSfile.h>
#include <pums_pub.h>
#include <pums_pri.h>

/**********************************************************************

Doc:	UMSMsgCode

Abstract:
	The UMSMsgCode function interprets the given message number and
	creates an alphanumeric code consisting of the message component,
	the message type and the message extension separated by hyphens,
	e.g. COMP-W-DONTMATCH.

	The interpretation of any part may be suppressed by setting the
	appropriate bit in supFlag.

	The default interpretation for any part may be overridden by
	supplying an alternate character string.

Return Status:
	UMS_S_SUCCESS	-	Successful interpretation
	UMS_E_NOTFND	-	Message number not found
	other		-	Error reading message file

  char	codeBuf[];   o - Buffer for resulting alphanumeric code
 sml:09-20-91		change to long for PC limitations
  long	msgNum;	     i - Message number to interpret
  int	supFlag;     i - Bit flag for suppressing interpretation
		           UMS_SUPPRESS_COMP - no component
		           UMS_SUPPRESS_TYPE - no type
		           UMS_SUPPRESS_EXT - no extension
  char	*newComp;    i - String to use in place of component
  char	*newType;    i - String to use in place of type character
  char	*newExt;     i - String to use in place of extension

**********************************************************************/

int	UMSMsgCode( char codeBuf[], long msgNum, int supFlag, char *newComp,
        char *newType, char *newExt )
{
  UMSFileIndex	fileIdx;
  UMSHeader	*msgHdr;
  int		sts, idx, msgCount, idxFlag, hyfnFlag;
  char		extBuf[UMS_MEM_EXT_LEN];
  static char	*UMSTypeChar[]={ "W", "S", "E", "I", "F", "P", "M", "?" };
  long          fileIdx_offset;

	sts = _UMSInterpretNum( &msgHdr, &msgCount, msgNum );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

	idx = msgCount - 1;

	if ( msgHdr->nidx )
	{
		if ( msgHdr->nidx[idx].msgNum != msgNum )
			return( UMS_E_NOTFND );
		idxFlag = 0;
	}
	else
	{
		sts = _UMSOpenFile( msgHdr );
		if ( sts != UMS_S_SUCCESS )
			return( sts );
		sts = _UMSGetFileIdx( fileIdx, idx );
		if ( sts != UMS_S_SUCCESS )
			return( sts );
		if ( fileIdx[UMS_FILEIDX_MSGNUM] != msgNum )
			return( UMS_E_NOTFND );
		idxFlag = 1;
	}

	codeBuf[0] = '\0';
	hyfnFlag = 0;

	if ( ! ( supFlag & UMS_SUPPRESS_COMP ) )
	{
	  strcat( codeBuf, ( ( newComp ) ? newComp : msgHdr->comp ) ) ;
	  hyfnFlag = 1;
	}

	if ( ! ( supFlag & UMS_SUPPRESS_TYPE ) )
	{
	  if ( hyfnFlag )
		strcat( codeBuf, "-" );

	  if ( newType )
	 	strcat( codeBuf, newType );
	  else
		strcat( codeBuf, UMSTypeChar[ msgNum & 0x0007 ] );
	  hyfnFlag = 1;
	}

	if ( ! ( supFlag & UMS_SUPPRESS_EXT ) )
	{
	  if ( hyfnFlag )
		strcat( codeBuf, "-" );

	  if ( newExt )
		strcat( codeBuf, newExt );
	  else if ( msgHdr->kidx )
		strcat( codeBuf, msgHdr->k1ext + msgHdr->kidx[idx] );
	  else
	    {
	      if ( ! idxFlag  )
		{
		  sts = _UMSOpenFile( msgHdr );
		  if ( sts != UMS_S_SUCCESS )
			return( sts );

		  sts = _UMSGetFileIdx( fileIdx, idx );
		  if ( sts != UMS_S_SUCCESS )
			return( sts );
		}

		/*****************************************************/
		/* sml:03-04-93                                      */
		/* Use UMS_long_convert to swap bytes if necessary   */
		/*****************************************************/

        fileIdx_offset =  fileIdx[UMS_FILEIDX_EXTPTR];
        sts = UMS_long_convert(&fileIdx_offset);
        sts = _UMSGetFileExt ( extBuf, msgHdr, fileIdx_offset);
/*                                      fileIdx[UMS_FILEIDX_EXTPTR] );*/

	      if ( sts != UMS_S_SUCCESS )
		return( sts );

	      strcat( codeBuf, extBuf );
	    }
	}

  return( UMS_S_SUCCESS );
}
