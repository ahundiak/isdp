#include <sys/types.h>
#include <string.h>
#include <malloc.h>
#include <stdarg.h>

#include <UMS.h>
#include <UMSpriv.h>
#include <UMSfile.h>
#include <pums_pub.h>
#include <pums_pri.h>
/**********************************************************************/
/***  Must not initialize this !  ( Something to do with dynamic    ***/
/***  loading errors if you do initialize it )  JAJ:05/17/91	    ***/
/**********************************************************************
UMSHeader	*UMSFileList={ 0 };
***********************************/

UMSHeader	*UMSFileList;

#define	NUM_IDX_READ	50

/**********************************************************************

Doc:	UMSInitMsg

Abstract:
    The UMSInitMsg function initializes internal data structures based
    on the optFlag argument for the given indexed message file.

    This function must be called prior to retrieving the first message
    from an indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization

	UMS_E_INVOPT	-	Invalid optFlag

	UMS_I_DUPINIT	-	File already initialized
	UMS_E_NOFILE	-	File not found or accessible
	UMS_E_TOOMANY	-	Too many files open
	UMS_E_INVFMT	-	Not in indexed message file format
	UMS_E_INVVER	-	Invalid file version

	UMS_E_OPEN	-	Other (obscure) open errors
	UMS_E_SEEK	-	Error setting file pointer
	UMS_E_EOF	-	Read past the end-of-file marker
	UMS_E_READ	-	Other error reading file

	UMS_E_INSVMEM	-	Insufficient memory for allocation

 char	*msgFile;	 i - Indexed message file
 int	optFlag;	 i - Bit flag indicating data to save
			 UMS_INDEX - message number index
			 UMS_KEY - primary message keys
			 UMS_KEY2 - secondary message keys
			 UMS_MESSAGE - message text

**********************************************************************/

int UMSInitMsg ( char *msgFile, int optFlag )
{
  int		sts;
  UMSHeader	*newHdr, *lastHdr, *_UMSHdrByFile();
  static  int	done_init = 0;

//printf("UMSInitMsg %s\n",msgFile);

  if ( ! done_init )
    {
      UMSFileList = 0;
      done_init   = 1;
    }

  switch ( optFlag )
    {
	case 0:
	case UMS_KEY2:
	case UMS_INDEX:
	case ( UMS_INDEX | UMS_KEY2 ):
	case UMS_KEY:
	case ( UMS_KEY | UMS_KEY2 ):
	case UMS_MESSAGE:
	case ( UMS_MESSAGE | UMS_KEY ):
	case ( UMS_MESSAGE | UMS_KEY2 ):
	case ( UMS_MESSAGE | UMS_KEY | UMS_KEY2 ):
		break;

	default:
		return( UMS_E_INVOPT );
    }

  newHdr = _UMSHdrByFile ( msgFile );
  if ( newHdr )
    {
	sts = _UMSOpenFile ( newHdr );
	return ( ( sts == UMS_S_SUCCESS ) ? UMS_I_DUPINIT : sts );
    }

  sts = _UMSInitMsgHdr ( &newHdr, msgFile );
  if ( sts != UMS_S_SUCCESS )
    {
      if ( newHdr )
	{
	  _UMSCloseFile( newHdr );
	  free( newHdr );
	}
      return( sts );
    }

  if ( optFlag & UMS_INDEX_BIT )
    {
      if ( optFlag & UMS_KEY_BIT )
	{
	  sts = _UMSInitBothIdx ( newHdr );
	}
      else
	{
	  sts = _UMSInitNumIdx ( newHdr );
	}

      if ( sts != UMS_S_SUCCESS )
	{
	  goto init_failure;
	}
    }

  if ( optFlag & UMS_MSG_BIT )
    {
	sts = _UMSInitTextBuf( newHdr );
	if ( sts != UMS_S_SUCCESS )
		goto init_failure;
    }

  if ( optFlag & UMS_KEY_BIT )
    {
	sts = _UMSInitKeyExt( newHdr );
	if ( sts != UMS_S_SUCCESS )
		goto init_failure;
    }

  if ( optFlag & UMS_KEY2_BIT )
    {
	sts = _UMSInitKeyLst( newHdr );
	if ( sts != UMS_S_SUCCESS )
		goto init_failure;
    }

  if ( ! UMSFileList )
    {
	UMSFileList = newHdr;
    }
  else
    {
	lastHdr = UMSFileList;
	while ( lastHdr->next )
	  {
		lastHdr = ( UMSHeader * ) lastHdr->next;
	  }
	lastHdr->next = ( char * )newHdr;
    }

  return( UMS_S_SUCCESS );

init_failure:
  _UMSCloseFile( newHdr );
  _UMSFreeMem( newHdr );
  return( sts );
}					

/**********************************************************************

Doc:	_UMSInitMsgHdr
Private:

Abstract:
	The _UMSInitMsgHdr function initializes the message header for
	the given indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	UMS_E_INVFMT	-	Not in indexed message file format
	UMS_E_INVVER	-	Invalid file version
	other		-	Open or read errors

  UMSHeader	**newHdr;   o - Header to allocate and initialize
  char		*msgFile;   i - Indexed message file

**********************************************************************/

int  _UMSInitMsgHdr( UMSHeader **newHdr, char *msgFile )
{
  UMSFileHdr	fileHdr;
  unsigned	bufSize;
  int		sts;

  bufSize = sizeof( UMSHeader ) + strlen( msgFile );
  *newHdr = ( UMSHeader * )malloc( bufSize );
  if ( ! *newHdr )
    {
	return( UMS_E_INSVMEM );
    }

  strcpy( ( *newHdr )->msgFile, msgFile );
  sts = _UMSOpenFile( *newHdr );
  if ( sts != UMS_S_SUCCESS )
    {
	return( sts );
    }

/*
  sts = _UMSReadFile( &fileHdr, sizeof( UMSFileHdr ) );
*/
 
  sts = _UMSReadFile (&(fileHdr.ums[0]), 3);

  if ( strncmp( fileHdr.ums, "UMS", 3 ) != 0 )
	return( UMS_E_INVFMT );

  sts = _UMSReadFile (&(fileHdr.version), 1);
/*	sml:10-04-91	test without this code.
  if ( fileHdr.version != UMS_FILE_VERSION )
 	return( UMS_E_INVVER );
*/
  sts = _UMSReadFile ((char *)&(fileHdr.baseNo), 2);  /* Actual baseNo */
  UMS_short_convert (&(fileHdr.baseNo));

  sts = _UMSReadFile (&(fileHdr.comp[0]), UMS_FILE_COMP_LEN);

  sts = _UMSReadFile ((char *)&(fileHdr.numMsg), 4);
  UMS_long_convert (&(fileHdr.numMsg));

  sts = _UMSReadFile ((char *)&(fileHdr.textBufLen), 4);
  UMS_long_convert (&(fileHdr.textBufLen));

  sts = _UMSReadFile ((char *)&(fileHdr.extBufLen), 4);
  UMS_long_convert (&(fileHdr.extBufLen));

  sts = _UMSReadFile ((char *)&(fileHdr.key2BufLen), 4);
  UMS_long_convert (&(fileHdr.key2BufLen));

  if ( sts != UMS_S_SUCCESS )
	return( sts );

  ( *newHdr )->baseNo     = fileHdr.baseNo;
  strcpy( ( *newHdr )->comp, fileHdr.comp );
  ( *newHdr )->numMsg     = fileHdr.numMsg;
  ( *newHdr )->textBufLen = fileHdr.textBufLen;
  ( *newHdr )->extBufLen  = fileHdr.extBufLen;
  ( *newHdr )->key2BufLen = fileHdr.key2BufLen;
  ( *newHdr )->nidx  = ( UMSNumIndex * ) 0;
  ( *newHdr )->kidx  = ( long * ) 0;
  ( *newHdr )->text  = ( char * ) 0;
  ( *newHdr )->k1ext = ( char * ) 0;
  ( *newHdr )->k2lst = ( char * ) 0;
  ( *newHdr )->next  = ( char * ) 0;

  return( UMS_S_SUCCESS );
}

/***********************************************************************

Doc:	_UMSInitNumIdx
Private:

Abstract:
	The _UMSInitNumIdx function reads and saves the numeric index
	for the current indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	other		-	Read errors

 UMSHeader	*newHdr;  i/o - Add index to this header

***********************************************************************/

int _UMSInitNumIdx( UMSHeader *newHdr )
{
  UMSFileIndex	fileIdx[NUM_IDX_READ];
  unsigned	bufSize;
  int		i, sts, numMsg,/* numLeft,*/ numRead;

/* sml:09-23-91		change to long for PC
  int           temp;
  int		numLeft;
*/
  long		numLeft;
  long           temp;

  newHdr->nidx = ( UMSNumIndex * ) malloc ( newHdr->numMsg *
						sizeof( UMSNumIndex ) );
  if ( ! newHdr->nidx )
    {
	return( UMS_E_INSVMEM );
    }

  numMsg = 0;
  numLeft = newHdr->numMsg;
  while ( numLeft > 0 )
    {
      numRead = ( numLeft < NUM_IDX_READ ) ? numLeft : NUM_IDX_READ;

      bufSize = numRead * sizeof( UMSFileIndex );
      sts = _UMSReadFile( (char *) fileIdx, bufSize );
      if ( sts != UMS_S_SUCCESS )
	{
	  return( sts );
	}

      for ( i = 0; i < numRead; i++, numMsg++ )
	{
          temp = fileIdx[i][UMS_FILEIDX_MSGNUM];
          UMS_long_convert (&temp);
	  newHdr->nidx[numMsg].msgNum = temp;
          temp = fileIdx[i][UMS_FILEIDX_TEXTPTR];
          UMS_long_convert (&temp);
	  newHdr->nidx[numMsg].textPtr = temp;
	}

      numLeft -= numRead;
    }
  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSInitBothIdx
Private:

Abstract:
  The _UMSInitBothIdx function reads and saves both the numeric and
  primary key indexes for the current indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	other		-	Read errors

 UMSHeader	*newHdr;  i/o - Add indexes to this header

**********************************************************************/

int _UMSInitBothIdx( UMSHeader *newHdr )
{
  UMSFileIndex	fileIdx[NUM_IDX_READ];
  unsigned	bufSize;
  int		i, sts, numMsg, /*numLeft,*/ numRead;
/* sml:09-26-91		change to long for PC
  int 		numLeft;
  int           temp;
*/
  long numLeft;
  long temp;



  newHdr->nidx = ( UMSNumIndex * ) malloc ( newHdr->numMsg *
					sizeof( UMSNumIndex ) );
  if ( ! newHdr->nidx )
    {
      return( UMS_E_INSVMEM );
    }

  newHdr->kidx = ( long * )malloc( newHdr->numMsg * sizeof( long ) );
  if ( ! newHdr->kidx )
    {
	return( UMS_E_INSVMEM );
    }

  numMsg = 0;
  numLeft = newHdr->numMsg;
  while ( numLeft > 0 )
    {
      numRead = ( numLeft < NUM_IDX_READ ) ? numLeft : NUM_IDX_READ;

      bufSize = numRead * sizeof( UMSFileIndex );
      sts = _UMSReadFile( (char *) fileIdx, bufSize );
      if ( sts != UMS_S_SUCCESS )
	{
	  return( sts );
	}

      for ( i = 0; i < numRead; i++, numMsg++ )
	{
          temp = fileIdx[i][UMS_FILEIDX_MSGNUM];
          UMS_long_convert (&temp);
	  newHdr->nidx[numMsg].msgNum = temp;
          temp = fileIdx[i][UMS_FILEIDX_TEXTPTR];
          UMS_long_convert (&temp);
	  newHdr->nidx[numMsg].textPtr = temp;
          temp = fileIdx[i][UMS_FILEIDX_EXTPTR];
          UMS_long_convert (&temp);
	  newHdr->kidx[numMsg] = temp;
	}

      numLeft -= numRead;
    }

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSInitTextBuf
Private:

Abstract:
	The _UMSInitTextBuf function reads and saves the message text
	from the current indexed message file.  The text pointers in the
	numeric index are changed to offsets into the text buffer.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	other		-	Read errors

 UMSHeader	*newHdr;	i/o - Add text to this header

**********************************************************************/

int  _UMSInitTextBuf( UMSHeader *newHdr )
{
  long	textPos;
  int	sts, idx;
  short temp_short;

  newHdr->text = malloc( newHdr->textBufLen );
  if ( ! newHdr->text )
    {
	return( UMS_E_INSVMEM );
    }

  sts = _UMSReadFile( newHdr->text, newHdr->textBufLen );
  if ( sts != UMS_S_SUCCESS )
    {
	return( sts );
    }

  textPos = 32 + newHdr->numMsg * sizeof( UMSFileIndex );

  for ( idx = 0; idx < newHdr->numMsg; idx++ )
    {
	if ( newHdr->nidx[idx].msgNum != 0 )
	  {
            newHdr->nidx[idx].textPtr -= textPos;

            memcpy ((char *)&temp_short, &(newHdr->text[newHdr->nidx[idx].textPtr]), 2);
            UMS_short_convert (&temp_short);
            memcpy (&(newHdr->text[newHdr->nidx[idx].textPtr]), (char *)&temp_short, 2);
	  }
    }

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSInitKeyExt
Private:

Abstract:
  The _UMSInitKeyExt function reads and saves the message extensions
  (used in primary message keys) for the current indexed message file.
  The extension pointers in the primary key index are changed to offsets
  into the extension buffer.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	other		-	Read errors

  UMSHeader	*newHdr;  i/o - Add extensions to this header

**********************************************************************/

int _UMSInitKeyExt( UMSHeader *newHdr )
{
  long	extPos;
  int	sts, idx;

  newHdr->k1ext = malloc( newHdr->extBufLen );
  if ( ! newHdr->k1ext )
    {
	return( UMS_E_INSVMEM );
    }

  extPos = 32 + newHdr->numMsg * sizeof( UMSFileIndex ) + newHdr->textBufLen;

  sts = _UMSReadFilePos( newHdr->k1ext, newHdr->extBufLen, extPos );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  for ( idx = 0; idx < newHdr->numMsg; idx++ )
    {
	if ( newHdr->nidx[idx].msgNum != 0 )
		newHdr->kidx[idx] -= extPos;
    }

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSInitKeyLst
Private:

Abstract:
  The _UMSInitKeyLst function reads and saves the secondary message
  keys for the current indexed message file.

Return Status:
	UMS_S_SUCCESS	-	Successful initialization
	UMS_E_INSVMEM	-	Insufficient memory for allocation
	other		-	Read errors

  UMSHeader	*newHdr;  i/o - Add secondary keys to this hdr

**********************************************************************/

int _UMSInitKeyLst( UMSHeader *newHdr )
{
  long	key2Pos;
  int	sts;

  if ( newHdr->key2BufLen == 0 )
    return( UMS_S_SUCCESS );

  newHdr->k2lst = malloc( newHdr->key2BufLen );
  if ( ! newHdr->k2lst )
	return( UMS_E_INSVMEM );

  key2Pos = 32 +
		  newHdr->numMsg * sizeof( UMSFileIndex ) +
		  newHdr->textBufLen +
		  newHdr->extBufLen;

  sts = _UMSReadFilePos( newHdr->k2lst, newHdr->key2BufLen, key2Pos );
  return( sts );
}

/**********************************************************************

Doc:	UMSClearMsg

Abstract:
  The UMSClearMsg function clears and frees internal structures used
  to store the data about the given indexed message file.

  Before messages can again be retrieved from the file, UMSInitMsg
  must be called.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_NOTINIT	-	File not initialized

  char	*msgFile;	i - Clear memory for this file

**********************************************************************/

int UMSClearMsg ( char *msgFile )
{
  UMSHeader	*msgHdr, *prevHdr, *_UMSHdrByFile();

  msgHdr = _UMSHdrByFile( msgFile );
  if ( ! msgHdr )
	return( UMS_E_NOTINIT );

  if ( UMSFileList == msgHdr )
    {
	UMSFileList = ( UMSHeader * )msgHdr->next;
    }
  else
    {
	prevHdr = UMSFileList;
	while ( ( UMSHeader * )prevHdr->next != msgHdr )
	  {
	    prevHdr = ( UMSHeader * )prevHdr->next;
	  }
	prevHdr->next = msgHdr->next;
    }

  _UMSCloseFile( msgHdr );
  _UMSFreeMem( msgHdr );

  return( UMS_S_SUCCESS );
}

/**********************************************************************

Doc:	_UMSHdrByFile
Private:

Abstract:
	The _UMSHdrByFile function returns the address of the UMSHeader
	structure matching the given indexed message file name.

	If the indexed message file name is not found, _UMSHdrByFile
	returns 0.

Return Values:
	Address of UMSHeader	-	Found message file
	0			0	Did not found message file

  char	*msgFile;	 i - Message file name to find

**********************************************************************/

UMSHeader *_UMSHdrByFile( char *msgFile )
{
  UMSHeader	*msgHdr;

  msgHdr = UMSFileList;
  while ( msgHdr )
    {
	if ( strcmp( msgHdr->msgFile, msgFile ) == 0 )
		break;

	msgHdr = ( UMSHeader * )msgHdr->next;
    }
  return( msgHdr );
}

/**********************************************************************

Doc:	_UMSFreeMem
Private:

Abstract:
	The _UMSFreeMem function frees all the memory allocated for the
	given UMSHeader structure.

Return Status:
	UMS_S_SUCCESS	-	Success

  UMSHeader	*msgHdr;    i - Free this header's memory

**********************************************************************/

int _UMSFreeMem( UMSHeader *msgHdr )
{
  if ( msgHdr->nidx )
    {
	free( msgHdr->nidx );
    }

  if ( msgHdr->kidx )
    {
 	free( msgHdr->kidx );
    }

  if ( msgHdr->text )
    {
	free( msgHdr->text );
    }

  if ( msgHdr->k1ext )
    {
	free( msgHdr->k1ext );
    }

  if ( msgHdr->k2lst )
    {
	free( msgHdr->k2lst );
    }

  free( msgHdr );

  return( UMS_S_SUCCESS );
}
