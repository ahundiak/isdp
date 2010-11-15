#include <stdarg.h>
#include "memory.h"        /* contains memcpy prototype */
#include "UMS.h"
#include "UMSpriv.h"
#include "UMSfile.h"
#include "pums_all.h"

/**********************************************************************

Doc:	UMSRetPtrByNum

Abstract:
    The UMSRetPtrByNum function returns a pointer to the message text
    in memory and the length of the message text for the given message
    number.

Notes:
	The text string is NOT null-terminated.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_W_NOTINMEM	-	Message text not in memory
	UMS_E_NOTFND	-	Message number not found

**********************************************************************/

int	UMSRetPtrByNum( msgPtr, msgLen, msgNum )
  char	**msgPtr;	/* o - Pointer to the message text	*/
  int	*msgLen;	/* o - Length of the message text	*/
/* sml:09-20-91		changed to long for PC
  int	msgNum;		 i - Message number			*/
  long	msgNum;		/* i - Message number			*/
{
  UMSHeader	*msgHdr;
  int		sts, idx, msgCount;

  sts = _UMSInterpretNum( &msgHdr, &msgCount, msgNum );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  if ( msgHdr->text )
    {
	idx = msgCount - 1;
	if ( msgNum != 0 && msgHdr->nidx[idx].msgNum != msgNum ||
				    msgHdr->nidx[idx].msgNum == 0 )
	  {
		return( UMS_E_NOTFND );
	  }
	_UMSGetMemTextPtr( msgPtr, msgLen, msgHdr, idx );
    }
  else
    return( UMS_W_NOTINMEM );

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSReturnByNum
Private:

Abstract:
	The _UMSReturnByNum function returns the message text for the
	given message number in the supplied buffer.  No data substitution
	is performed.

Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message number not found
	other		-	Errors reading message file

**********************************************************************/

int	_UMSReturnByNum( textBuf, msgNum )
  char	*textBuf;		/* o - Buffer for message text	*/
/* sml:09-20-91		changed to long for PC
  int	msgNum;			 i - Message number		*/
  long	msgNum;			/* i - Message number		*/
{
  UMSHeader	*msgHdr;
  int		sts, msgCount;

  sts = _UMSInterpretNum( &msgHdr, &msgCount, msgNum );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  sts = _UMSRetrieveByNum( textBuf, msgHdr, msgNum, msgCount - 1 );
  return( sts );
}

/**********************************************************************

Doc:	_UMSInterpretNum
Private:

Abstract:
  The _UMSInterpretNum function masks and shifts bits in the message
  number to determine the message base number and the message counter.
  The message base number is then used to find the UMSHeader structure
  containing the indexed message file data.

Return Status:
	UMS_S_SUCCESS	-	Successful interpretation
	UMS_E_NOTFND	-	Message number not found

**********************************************************************/

int	_UMSInterpretNum( msgHdr, msgCount, msgNum )
  UMSHeader	**msgHdr;    /* o - In-memory message file data	*/
  int		*msgCount;   /* o - Message counter		*/
/* sml:09-20-91		changed to long for PC
  int	msgNum;			 i - Message number		*/
  long	msgNum;			/* i - Message number		*/
{
  /* sml:09-23-91 	change baseNo to long 
  int	baseNo;
  */
  long	baseNo;
  /* sml:09-20-91	add long variables to hold mask values */
  long msk07ff = 0x07ffL;
  long msk0fff = 0x0fffL;

/* sml:09-20-91		use mask variables instead of literals
	baseNo = ( msgNum >> 16 ) & 0x07ff;
	*msgCount = ( msgNum >> 3 ) & 0x0fff;
*/
	baseNo = ( msgNum >> 16 ) & msk07ff;
	*msgCount = ( msgNum >> 3 ) & msk0fff;
	*msgHdr = UMSFileList;
	while ( *msgHdr )
	{
		if ( ( *msgHdr )->baseNo == baseNo )
			break;

		*msgHdr = ( UMSHeader * )( *msgHdr )->next;
	}

	if ( ! ( *msgHdr ) )
		return( UMS_E_NOTFND );

	if ( *msgCount < 1 || *msgCount > ( *msgHdr )->numMsg )
		return( UMS_E_NOTFND );

	return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSRetrieveByNum
Private:

Abstract:
    Based on the given indexed file information, the _UMSRetrieveByNum
    function returns the message text in the supplied buffer.

Return Status:
    UMS_S_SUCCESS   -	Successful retrieval
    UMS_E_NOTFND    -	Message number not found--skipped counter
    other	    -	Error reading from message file

**********************************************************************/

int	_UMSRetrieveByNum( textBuf, msgHdr, msgNum, idx )
  char		*textBuf;   /* o - Buffer for message text	  */
  UMSHeader	*msgHdr;    /* i - In-memory message file data	  */
/* sml:09-20-91		changed to long for PC
  int	msgNum;			 i - Message number		*/
  long	msgNum;			/* i - Message number		*/
  int		idx;	    /* i - Index into file/memory indexes */
{
  UMSFileIndex	fileIdx;
  int		sts;
  long          temp;

  if ( msgHdr->text )
    {
	if ( msgNum != 0 && msgHdr->nidx[idx].msgNum != msgNum ||
			    msgHdr->nidx[idx].msgNum == 0 )
	  {
		return( UMS_E_NOTFND );
	  }
	_UMSGetMemText( textBuf, msgHdr, idx );
    }
  else if ( msgHdr->nidx )
    {
	if ( msgNum != 0 && msgHdr->nidx[idx].msgNum != msgNum ||
				    msgHdr->nidx[idx].msgNum == 0 )
	  {
		return( UMS_E_NOTFND );
	  }
	sts = _UMSOpenFile( msgHdr );
	if ( sts != UMS_S_SUCCESS )
		return( sts );
	sts = _UMSGetFileText( textBuf, msgHdr->nidx[idx].textPtr );
	if ( sts != UMS_S_SUCCESS )
		return( sts );
    }
  else
    {
	sts = _UMSOpenFile( msgHdr );
	if ( sts != UMS_S_SUCCESS )
		return( sts );
	sts = _UMSGetFileIdx( fileIdx, idx );
        
        temp = fileIdx[UMS_FILEIDX_MSGNUM];
        UMS_long_convert (&temp);

	if ( sts != UMS_S_SUCCESS )
		return( sts );
	if ( msgNum != 0 && temp != msgNum ||
			    temp == 0 )
	  {
		return( UMS_E_NOTFND );
	  }

        temp = fileIdx[UMS_FILEIDX_TEXTPTR];
        UMS_long_convert (&temp);

	sts = _UMSGetFileText( textBuf, temp );
	if ( sts != UMS_S_SUCCESS )
		return( sts );
    }

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSGetFileIdx
Private:

Abstract:
	The _UMSGetFileIdx function reads the indicated index record
	from the indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Success
	other		-	Error reading index record

**********************************************************************/

int	_UMSGetFileIdx( fileIdx, idx )
 long	fileIdx[];	/* o - Buffer for index record		*/
 int	idx;		/* i - File index array "index"		*/
{
  long	idxSize, idxPos;

  idxSize = sizeof( UMSFileIndex );
  idxPos = sizeof( UMSFileHdr ) + idxSize * idx;
/*	sml:10-07-91	ansi-ize
  return( _UMSReadFilePos( fileIdx, idxSize, idxPos ) );
*/
  return( _UMSReadFilePos( (char *)fileIdx, idxSize, idxPos ) );
}

/**********************************************************************

Doc:	_UMSGetFileText
Private:

Abstract:
    The _UMSGetFileText function reads the message text from the file
    at the given position into the given buffer.

Return Status:
	UMS_S_SUCCESS	-	Success
	other		-	Error reading text

**********************************************************************/

int	_UMSGetFileText( textBuf, textPtr )
 char	textBuf[];	/* o - Buffer for the message text	*/
 long	textPtr;	/* i - Text pointer from file index	*/
{
  long	textLen;
  int	sts;
  short	numBytes;

/*	sml:10-07-91	ansi-ize
	sts = _UMSReadFilePos( &numBytes, sizeof( short ), textPtr );
*/
	sts = _UMSReadFilePos( (char *) &numBytes, sizeof( short ), textPtr );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

        UMS_short_convert (&numBytes);

	textLen = numBytes;
	sts = _UMSReadFile( textBuf, textLen );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

	textBuf[textLen] = '\0';

	return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSGetFileExt
Private:

Abstract:
	The _UMSGetFileExt function reads the message extension from the
	file at the given position into the given buffer.
	
Return Status:
	UMS_S_SUCCESS	-	Success
	other		-	Error reading file

**********************************************************************/

int	_UMSGetFileExt( extBuf, msgHdr, extPtr )
  char		*extBuf;    /* o - Buffer for message extension	     */
  UMSHeader	*msgHdr;    /* i - In-memory message file data	     */
  long		extPtr;	    /* i - Extension pointer from file index */
{
  unsigned	numBytes;
  long		eofPos;
  int		sts;

	eofPos = sizeof( UMSFileHdr ) +
		 msgHdr->numMsg * sizeof( UMSFileIndex ) +
		 msgHdr->textBufLen +
		 msgHdr->extBufLen +
		 msgHdr->key2BufLen;

	if ( extPtr + UMS_MEM_EXT_LEN > eofPos )
		numBytes = eofPos - extPtr;
	else
		numBytes = UMS_MEM_EXT_LEN;

	sts = _UMSReadFilePos( extBuf, numBytes, extPtr );
	return( sts );
}

/**********************************************************************

Doc:	_UMSGetMemText
Private:

Abstract:
	The _UMSGetMemText function locates the message text in memory
	and copies it into the given buffer.

Return Status:
	UMS_S_SUCCESS	-	Success

**********************************************************************/

int	_UMSGetMemText( textBuf, msgHdr, idx )
  char		textBuf[];    /* o - Buffer for the message text   */
  UMSHeader	*msgHdr;      /* i - In-memory message file data   */
  int		idx;	      /* i - Numeric index array "index"   */
{
  int	textLen;
  char	*textPtr;

  _UMSGetMemTextPtr( &textPtr, &textLen, msgHdr, idx );
  memcpy( textBuf, textPtr, textLen );
  textBuf[textLen] = '\0';

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSGetMemTextPtr
Private:

Abstract:
	The _UMSGetMemTextPtr function returns a pointer to the message
	text in memory and the text length.

Return Status:
	UMS_S_SUCCESS	-	Success

**********************************************************************/

int	_UMSGetMemTextPtr( textPtr, textLen, msgHdr, idx )
  char		**textPtr;   /* o - Pointer to the text in memory */
  int		*textLen;    /* o - Text length			  */
  UMSHeader	*msgHdr;     /* i - In-memory message file data	  */
  int		idx;	     /* i - Numeric index array "index"	  */
{
  short	tmpLen;
  char	*lenPtr;

  lenPtr = msgHdr->text + msgHdr->nidx[idx].textPtr;
  *textPtr = lenPtr + sizeof( short );
  memcpy( &tmpLen, lenPtr, sizeof( short ) );
  *textLen = tmpLen;

  return( UMS_S_SUCCESS );
}
