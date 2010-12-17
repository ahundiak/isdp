#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include <ums.h>
#include <umspriv.h>
#include <umsfile.h>
#include <pums_pub.h>
#include <pums_pri.h>

/**********************************************************************

Doc:	UMSRetPtrByKey

Abstract:
    The UMSRetPtrByKey function returns a pointer to the message text
    in memory and the length of the message text for the given message
    key (either primary or secondary).
	
Notes:
	The text string is NOT null-terminated.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_W_NOTINMEM	-	Message text not in memory
	UMS_E_NOTFND	-	Message key not found
	other		-	Errors reading message file

 char	**msgPtr;	 o - Pointer to the message text
 int	*msgLen;	 o - Length of the message text
 char	*msgKey;	 i - Primary or secondary message key

**********************************************************************/

int	UMSRetPtrByKey( char **msgPtr, int *msgLen, char *msgKey )
{
  UMSHeader	*msgHdr;
  int		sts, idx;

  sts = _UMSInterpretKey( &msgHdr, &idx, msgKey );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  if ( msgHdr->text )
    {
	if ( msgHdr->nidx[idx].msgNum == 0 )
		return( UMS_E_NOTFND );
	_UMSGetMemTextPtr( msgPtr, msgLen, msgHdr, idx );
    }
  else
    return( UMS_W_NOTINMEM );

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSReturnByKey
Private:

Abstract:
	The _UMSReturnByKey function returns the message text for the
	given message key (either primary or secondary) in the supplied
	buffer.

Return Status:
	UMS_S_SUCCESS	-	Successful retrieval
	UMS_E_NOTFND	-	Message key not found
	other		-	Errors reading message file

sml:10-01-91	changed msgNum arg in _UMSRetrieveByNum call a long

 char	*textBuf;	 o - Buffer for message text
 char	*msgKey;	 i - Primary or secondary message key

**********************************************************************/

int	_UMSReturnByKey( char *textBuf, char *msgKey )
{
UMSHeader	*msgHdr;
int		sts, idx;

	sts = _UMSInterpretKey( &msgHdr, &idx, msgKey );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

/*	sts = _UMSRetrieveByNum( textBuf, msgHdr, 0, idx ); */
/*  sml:10-01-91	made this a long to match formal parameter */
	sts = _UMSRetrieveByNum( textBuf, msgHdr, 0L, idx );
	return( sts );
}

/**********************************************************************

Doc:	_UMSInterpretKey
Private:

Abstract:
	The _UMSInterpretKey function determines if the given key is a
	primary or secondary key and the does the appropriate searches
	to locate the UMSHeader structure containing the indexed message
	file data and the "index" of the message.

Notes:
	A primary key is constructed by the message compiler and has the
	format:  <component>:<extension>

	A secondary key is an ASCII string defined by the application and
	does not contain a colon, `:'.

Return Status:
	UMS_S_SUCCESS	-	Successful interpretation
	UMS_E_NOTFND	-	Message key not found
	other		-	Errors reading message file

 UMSHeader	**msgHdr;     o - In-memory message file data
 int		*idx;	      o - Message "index" matching key
 char		*msgKey;      i - Message key

**********************************************************************/

int	_UMSInterpretKey( UMSHeader **msgHdr, int *idx, char *msgKey )
{
  int	sts;
  char	comp[2 * UMS_MEM_COMP_LEN], msgExt[2 * UMS_MEM_EXT_LEN];

	if ( strchr( msgKey, ':' ) )
	{
		comp[0] = '\0';
		msgExt[0] = '\0';
		sscanf( msgKey, "%[^:]:%s", comp, msgExt );

		*msgHdr = UMSFileList;
		while ( *msgHdr )
		{
			if ( strcmp( ( *msgHdr )->comp, comp ) == 0 )
				break;

			*msgHdr = ( UMSHeader * )( *msgHdr )->next;
		}

		if ( ! ( *msgHdr ) )
			return( UMS_E_NOTFND );

		if ( msgExt[0] == '\0' )
			return( UMS_E_NOTFND );

		if ( ( *msgHdr )->kidx )
		{
			sts = _UMSFindMemKidx( idx, *msgHdr, msgExt );
			if ( sts != UMS_S_SUCCESS )
				return( sts );
		}
		else
		{
			sts = _UMSOpenFile( *msgHdr );
			if ( sts != UMS_S_SUCCESS )
				return( sts );
			sts = _UMSFindFileKidx( idx, *msgHdr, msgExt );
			if ( sts != UMS_S_SUCCESS )
				return( sts );
		}
	}
	else if ( strlen( msgKey ) )
	{
		sts = _UMSFindMemKey2( msgHdr, idx, msgKey );
		if ( sts == UMS_E_NOTFND )
			sts = _UMSFindFileKey2( msgHdr, idx, msgKey );
		if ( sts != UMS_S_SUCCESS )
			return( sts );
	}
	else
		return( UMS_E_NOTFND );

	return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSFindFileKidx
Private:

Abstract:
	The _UMSFindFileKidx function reads the extensions from the file
	to find the given message extension.  The "index" is returned.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_NOTFND	-	Message extension not found
	other		-	Error reading index records

 int		*idx;	     o - "Index" into extensions
 UMSHeader	*msgHdr;     i - In-memory message file data
 char		*msgExt;     i - Message extension to find

**********************************************************************/

int	_UMSFindFileKidx( int *idx, UMSHeader *msgHdr, char *msgExt )
{
  long	extPos;
  int	sts;

  extPos = 32 + msgHdr->numMsg * sizeof( UMSFileIndex ) + msgHdr->textBufLen;

  sts = _UMSSearchFileBlock( idx, msgExt, extPos, msgHdr->extBufLen );
  return( sts );
}

/**********************************************************************

Doc:	_UMSFindMemKidx
Private:

Abstract:
    The _UMSFindMemKidx function searches the in-memory primary message
    key index for the given message extension.  The index into the array
    is returned.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_NOTFND	-	Message extension not found

  int		*idx;		 o - Key index array "index"
  UMSHeader	*msgHdr;	 i - In-memory message file data
  char		*msgExt;	 i - Message extension to find

**********************************************************************/

int	_UMSFindMemKidx( int *idx, UMSHeader *msgHdr, char *msgExt )
{
	for ( *idx = 0; *idx < msgHdr->numMsg; (*idx)++ )
	{
		if ( msgHdr->nidx[*idx].msgNum != 0 )
		{
			if ( strcmp( msgHdr->k1ext + msgHdr->kidx[*idx],
				     msgExt ) == 0 )
				return( UMS_S_SUCCESS );
		}
	}

	return( UMS_E_NOTFND );
}

/**********************************************************************

Doc:	_UMSFindFileKey2
Private:

Abstract:
	The _UMSFindFileKey2 function searches all the secondary key
	lists that are not in memory for the given secondary message key.

Return Status:
	UMS_S_SUCCESS	-	Successful search
	UMS_E_NOTFND	-	Secondary message key not found
	other		-	Error reading key lists

  UMSHeader	**msgHdr;     o - In-memory message file data
  int		*idx;	      o - "Index" into secondary key block
  char		*msgKey2;     i - Secondary message key
**********************************************************************/

int	_UMSFindFileKey2( UMSHeader **msgHdr, int *idx, char *msgKey2 )
{
  long	key2Pos;
  int	sts;

	*msgHdr = UMSFileList;
	while ( *msgHdr )
	{
		if ( ( *msgHdr )->key2BufLen != 0 && ! ( *msgHdr )->k2lst )
		{
			sts = _UMSOpenFile( *msgHdr );
			if ( sts != UMS_S_SUCCESS )
				return( sts );

			key2Pos = sizeof( UMSFileHdr ) +
				  ( *msgHdr )->numMsg * sizeof( UMSFileIndex ) +
				  ( *msgHdr )->textBufLen +
				  ( *msgHdr )->extBufLen;
			sts = _UMSSearchFileBlock( idx, msgKey2, key2Pos,
						   ( *msgHdr )->key2BufLen );
			if ( sts != UMS_E_NOTFND )
				return( sts );
		}

		*msgHdr = ( UMSHeader * )( *msgHdr )->next;
	}

	return( UMS_E_NOTFND );
}

/**********************************************************************

Doc:	_UMSFindMemKey2
Private:

Abstract:
	The _UMSFindMemKey2 function searches all the in-memory secondary
	key lists for the given secondary message key.

Return Status:
	UMS_S_SUCCESS	-	Successful search
	UMS_E_NOTFND	-	Secondary message key not found

  UMSHeader	**msgHdr;     o - In-memory message file data
  int		*idx;	      o - "Index" into secondary key block
  char		*msgKey2;     i - Secondary message key

**********************************************************************/

int	_UMSFindMemKey2( UMSHeader **msgHdr, int *idx, char *msgKey2 )
{
  char	*keyPtr;

  *msgHdr = UMSFileList;
  while ( *msgHdr )
    {
      if ( ( *msgHdr )->k2lst )
	{
	  keyPtr = ( *msgHdr )->k2lst;
	  for ( *idx = 0; *idx < ( *msgHdr )->numMsg; ( *idx )++ )
	    {
	      if ( keyPtr[0] )
		{
		  if ( strcmp( keyPtr, msgKey2 ) == 0 )
			return( UMS_S_SUCCESS );

		  keyPtr += strlen( keyPtr ) + 1;
		}
	      else
		keyPtr++;
	    }
	}

      *msgHdr = ( UMSHeader * )( *msgHdr )->next;
    }

  return( UMS_E_NOTFND );
}

/**********************************************************************

Doc:	_UMSSearchFileBlock
Private:

Abstract:
    The _UMSSearchFileBlock function searches for either the primary key
    extension or the secondary key in the indicated block of keys
    in the file.  The "index" into the block is returned.

Return Status:
	UMS_S_SUCCESS	-	Successful search
	UMS_E_NOTFND	-	Unsuccessful search
	other		-	Read errors

  int	*idx;		 o - "Index" into key block
  char	*key;		 i - Primary key extension or secondary
			       key to locate
  long	filePos;	 i - Position of the key block
  long	blockSize;	 i - Size of the key block
**********************************************************************/

int	_UMSSearchFileBlock( int *idx, char *key, long filePos, long blockSize )
{
#define	KEYBUF_SIZE	512

  unsigned	numBytes;
  int		sts, counter, firstByte, lastByte, maxBytes;
  char		*keyPtr, keyBuf[KEYBUF_SIZE];

  sts = _UMSFilePos( filePos );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  *idx = 0;
  firstByte = 0;
  while ( blockSize > 0 )
    {
      maxBytes = KEYBUF_SIZE - firstByte;
      numBytes = ( blockSize < maxBytes ) ? blockSize : maxBytes;
      sts = _UMSReadFile( &keyBuf[firstByte], numBytes );
      if ( sts != UMS_S_SUCCESS )
	return( sts );

      lastByte = firstByte + ( int )numBytes;
      firstByte = 0;
      while ( keyBuf[lastByte - 1] != '\0' )
	{
	  lastByte--;
	  firstByte++;
	}

      counter = 0;
      keyPtr = keyBuf;
      while ( counter < lastByte )
	{
	  if ( strcmp( keyPtr, key ) == 0 )
		return( UMS_S_SUCCESS );

	  ( *idx )++;

	  counter += strlen( keyPtr ) + 1;
	  keyPtr = &keyBuf[counter];
	}		

      if ( firstByte )
	{
	  strncpy( keyBuf, keyPtr, firstByte );
	}
      blockSize -= ( int )numBytes;
    }

  return( UMS_E_NOTFND );
}
