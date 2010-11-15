#include <sys/types.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <malloc.h>
#include <memory.h>
#include "UMSfile.h"
#include "UMCcomp.h"
#include "COMP.h"

#include "UMSpriv.h"
#include "pums_all.h"
#include "pumc_all.h"

/***********************************************************************

Doc:	UMCReadTxt

Abstract:
	The UMCReadTxt function reads a UMS text file and fills the
	file data structure.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_OPENTEXT		-	Unable to open text file
	COMP_F_EMPTYFILE	-	Text file is empty
	COMP_F_NOFILEIDENT	-	Missing "::UMS" line
	COMP_F_NOT1STLINE	-	"::UMS" is not the first line
	COMP_F_INSVMEM		-	Insufficient virtual memory

    UMCFileHdr errors:
	COMP_F_NOCOMPBASENO	-	No component and/or base number
	COMP_F_BADBASENO	-	Base number too small or too big
	COMP_F_BADCOMPLEN	-	Component too short or too long
	COMP_F_BADCOMPCHAR	-	Component does not start with a letter

    UMCKeyLine errors:
	COMP_F_NOKEYWORDVAL	-	Missing keyword and/or value
	COMP_F_BADKEYWORD	-	Invalid keyword
	COMP_F_BADCOUNT		-	COUNT value out of range

    UMCMsgLine errors:
	COMP_F_BADLABEL		-	Invalid label (< 2 underbars)
	COMP_F_MISSEXT		-	Missing extension
	COMP_F_MISSKEY2		-	Missing secondary key after its comma
	COMP_F_TOOMANYMSG	-	Message count > 4095

History:
	15-MAR-1989	sh	Creation date
	26-MAR-1989	tz	Pre-delivery tweeking
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

***********************************************************************/

int	UMCReadTxt( textFile, fileData )

char		*textFile;	/* i - Message text file name	      */
UMCFileData	*fileData;	/* i/o - Data from message text file  */
{
#define	UMC_FILE_IDENT	"::UMS"

FILE	*fp;
long	textOff, extOff;
int	i, idx, sts, lineNum;
char	line[UMC_BUFLEN];
char    mod_textFile[256];

        /* sml:06-23-93 expand backslashes for use in messages */
        UMSExpandBackslash(textFile, mod_textFile);
	if ( ( fp = fopen( textFile, "r" ) ) == NULL )
	{
	        /* sml:06-23-93 use filename with expanded backslashes */
		UMCErrorMsg( COMP_F_OPENTEXT, "%s", mod_textFile );

		/* sml:04-12-94:NO TR                             */
		/*  direct messages to a file, not stderr         */
		/*perror( "" );*/
		return( COMP_F_OPENTEXT );
	}

	lineNum = 0;
	sts = UMCGetLine( fp, line, &lineNum );
	if ( sts == COMP_I_EOF )
	{
		sts = COMP_F_EMPTYFILE;
		UMCErrorMsg( sts, 0 );
		goto close_it;
	}
	if ( strcmp( line, UMC_FILE_IDENT ) != 0 )
	{
		sts = COMP_F_NOFILEIDENT;
		UMCErrorMsg( sts, "%s", UMC_FILE_IDENT );
		goto close_it;
	}
	if ( lineNum > 1 )
	{
		sts = COMP_F_NOT1STLINE;
		UMCErrorMsg( sts, "%s", UMC_FILE_IDENT );
		goto close_it;
	}

	sts = UMCGetLine( fp, line, &lineNum );
	sts = UMCFileHdr( line, lineNum, fileData );
	if ( sts != COMP_S_SUCCESS )
		goto close_it;

	while ( UMCGetLine( fp, line, &lineNum ) != COMP_I_EOF )
	{
		if ( line[0] == '.' )
			sts = UMCKeyLine( line, lineNum, fileData );
		else
			sts = UMCMsgLine( line, lineNum, fileData );
		if ( sts != COMP_S_SUCCESS )
			goto close_it;
	}
	if ( fileData->hdr.numMsg == 0 )
	{
		sts = COMP_F_NOMSGS;
		UMCErrorMsg( sts, 0 );
		goto close_it;
	}

	textOff =  32 +   /* sizeof (UMSFileHdr) */
		  fileData->hdr.numMsg * sizeof( long ) * UMS_FILEIDX_LEN;
	extOff = textOff + fileData->hdr.textBufLen;
	for ( i = 0; i < fileData->hdr.numMsg; i++ )
	{
		idx = i * UMS_FILEIDX_LEN;
		if ( fileData->fileIdx[idx + UMS_FILEIDX_MSGNUM] != 0 )
		{
			fileData->fileIdx[idx + UMS_FILEIDX_TEXTPTR] += textOff;
			fileData->fileIdx[idx + UMS_FILEIDX_EXTPTR] += extOff;

            /*********************************************************/
            /*                                                       */
            /*  Byte swap the contents of these longs if on the Sun  */
            /*                                                       */
            /*********************************************************/

            UMS_long_convert (&(fileData->fileIdx[idx + UMS_FILEIDX_MSGNUM]));
            UMS_long_convert (&(fileData->fileIdx[idx + UMS_FILEIDX_TEXTPTR]));
            UMS_long_convert (&(fileData->fileIdx[idx + UMS_FILEIDX_EXTPTR]));
		}
	}

	if ( fileData->key2Count == 0 )
		fileData->hdr.key2BufLen = 0;

	sts = COMP_S_SUCCESS;

close_it:
	fclose( fp );
	return( sts );
}

/***********************************************************************

Doc:	UMCFileHdr

Abstract:
	The UMCFileHdr function initializes the file header structure and
	includes parsing the component and base number from the file.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_NOCOMPBASENO	-	No component and/or base number
	COMP_F_BADBASENO	-	Base number too small or too big
	COMP_F_BADCOMPLEN	-	Component too short or too long
	COMP_F_BADCOMPCHAR	-	Component does not start with a letter

History:
	15-MAR-1989	sh	Creation date
	25-MAR-1989	tz	Pre-delivery tweeking
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

***********************************************************************/

int	UMCFileHdr( line, lineNum, fileData )

char		line[];		/* i - Line contents		     */
int		lineNum;	/* i - Line number		     */
UMCFileData	*fileData;	/* i/o - Data from message text file */
{
int	sts, compLen, tmpBase;
char	tmpComp[UMC_BUFLEN];

	tmpComp[0] = '\0';
	tmpBase = 0;
	sts = sscanf( line, "%s%d", tmpComp, &tmpBase );
	if ( sts != 2 )
	{
		UMCErrorMsg( COMP_F_NOCOMPBASENO, "%d", lineNum );
		return( COMP_F_NOCOMPBASENO );
	}
	if ( tmpBase < UMC_BASE_MIN || tmpBase > UMC_BASE_MAX )
	{
		UMCErrorMsg( COMP_F_BADBASENO, "%d%d%d%d",
			     lineNum, tmpBase, UMC_BASE_MIN, UMC_BASE_MAX );
		return( COMP_F_BADBASENO );
	}
	compLen = strlen( tmpComp );
	if ( compLen < UMC_COMP_MIN || compLen > UMS_FILE_COMP_LEN - 1 )
	{
		UMCErrorMsg( COMP_F_BADCOMPLEN, "%d%s%d%d",
			     lineNum, tmpComp, UMC_COMP_MIN, UMS_FILE_COMP_LEN - 1 );
		return( COMP_F_BADCOMPLEN );
	}	
	if ( !isalpha( tmpComp[0] ) )
	{
		UMCErrorMsg( COMP_F_BADCOMPCHAR, "%d%s", lineNum, tmpComp );
		return( COMP_F_BADCOMPCHAR );
	}

	strncpy( fileData->hdr.ums, "UMS", 3 );
	fileData->hdr.version = UMS_FILE_VERSION;
	fileData->hdr.baseNo = tmpBase;
	strcpy( fileData->hdr.comp, tmpComp );
	for ( ; compLen < UMS_FILE_COMP_LEN; compLen++ )
		fileData->hdr.comp[compLen] = '\0';
	fileData->hdr.numMsg = 0;
	fileData->hdr.textBufLen = 0;
	fileData->hdr.extBufLen = 0;
	fileData->hdr.key2BufLen = 0;
	fileData->key2Count = 0;

	return( COMP_S_SUCCESS );
}

/***********************************************************************

Doc:	UMCKeyLine

Abstract:
	The UMCKeyLine function parses and processes a keyword line.
	A keyword line has the following format:

		.<keyword> <value>

	Keyword		Action
	.COUNT		Sets the "counter" for the next message number

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_INSVMEM		-	Insufficient virtual memory
	COMP_F_NOKEYWORDVAL	-	Missing keyword and/or value
	COMP_F_BADKEYWORD	-	Invalid keyword
	COMP_F_BADCOUNT		-	COUNT value out of range

History:
	26-MAR-1989	tz	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

***********************************************************************/

int	UMCKeyLine( line, lineNum, fileData )

char		line[];		/* i - Line contents		     */
int		lineNum;	/* i - Line number		     */
UMCFileData	*fileData;	/* i/o - Data from message text file */
{
int	i, sts, keyLen, keyValue;
char	keyWord[UMC_BUFLEN];

	sts = sscanf( &line[1], "%s%d", keyWord, &keyValue );
	if ( sts != 2 )
	{
		UMCErrorMsg( COMP_F_NOKEYWORDVAL, "%d", lineNum );
		return( COMP_F_NOKEYWORDVAL );
	}
	keyLen = strlen( keyWord );
	for ( i = 0; i < keyLen; i++ )
		keyWord[i] = toupper( keyWord[i] );
	if ( strcmp( keyWord, "COUNT" ) == 0 )
	{
		if ( keyValue <= fileData->hdr.numMsg || keyValue > UMC_COUNT_MAX )
		{
			UMCErrorMsg( COMP_F_BADCOUNT, "%d%d%d%d",
				     lineNum, keyValue,
				     fileData->hdr.numMsg + 1, UMC_COUNT_MAX );
			return( COMP_F_BADCOUNT );
		}
		keyValue--;
		while ( fileData->hdr.numMsg < keyValue )
		{
			sts = UMCCheckMem( 0, 1, 1, fileData );
			if ( sts != COMP_S_SUCCESS )
				return( sts );

			i = fileData->hdr.numMsg * UMS_FILEIDX_LEN;
			fileData->fileIdx[i + UMS_FILEIDX_MSGNUM] = 0;
			fileData->fileIdx[i + UMS_FILEIDX_TEXTPTR] = 0;
			fileData->fileIdx[i + UMS_FILEIDX_EXTPTR] = 0;

			fileData->extBuf[fileData->hdr.extBufLen] = '\0';

			fileData->key2Buf[fileData->hdr.key2BufLen] = '\0';

			fileData->hdr.numMsg++;
			fileData->hdr.extBufLen++;
			fileData->hdr.key2BufLen++;
		}
	}
	else
	{
		UMCErrorMsg( COMP_F_BADKEYWORD, "%d%s", lineNum, keyWord );
		return( COMP_F_BADKEYWORD );
	}

	return( COMP_S_SUCCESS );
}

/***********************************************************************

Doc:	UMCMsgLine

Abstract:
	The UMCMsgLine function parses and processes a message line.
	A message line has the following format:

		<message label> [,<optional key>] <message text>

		where:	<message label> = <component>_<type>_<extension>

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_INSVMEM		-	Insufficient virtual memory
	COMP_F_BADLABEL		-	Invalid label (< 2 underbars)
	COMP_F_MISSEXT		-	Missing extension
	COMP_F_MISSKEY2		-	Missing secondary key after its comma
	COMP_F_TOOMANYMSG	-	Message count > 4095

History:
	15-MAR-1989	sh	Creation date
	26-MAR-1989	tz	Pre-delivery tweek
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS
	08-OCT-1991	sml	change msgNum variable to long for PCs

***********************************************************************/

int	UMCMsgLine( line, lineNum, fileData )

char		line[];		/* i - Line contents		     */
int		lineNum;	/* i - Line number		     */
UMCFileData	*fileData;	/* i/o - Data from message text file */
{
  THREAD_DECL static	char	typeChars[]={ "WSEIFPM" };

  int	sts, idx, len, type, labelLen, extLen, key2Len, msgLen/*, msgNum*/;
  /* sml:11-15-91	change msgNum to long for PCs */
  long msgNum;
  char	*p, buf[UMC_BUFLEN],
	ext[UMS_FILE_EXT_LEN], key2[UMS_FILE_KEY2_LEN], *msg;
  short temp_short;

  long longbaseNo;



  labelLen = strcspn( line, ", \t" );
  strncpy( buf, line, labelLen );
  buf[labelLen] = '\0';
  if ( ( p = strchr( buf, '_' ) ) != NULL )
		p = strchr( p + 1, '_' );
  if ( p == NULL )
    {
	UMCErrorMsg( COMP_F_BADLABEL, "%d%s", lineNum, buf );
	return( COMP_F_BADLABEL );
    }

  p = buf;
  len = strcspn( p, "_" );
  p[len] = '\0';
  if ( len == 0 )
	UMCErrorMsg( COMP_W_MISSCOMP, "%d%s",
			     lineNum, fileData->hdr.comp );
  else if ( strcmp( p, fileData->hdr.comp ) != 0 )
		UMCErrorMsg( COMP_W_BADCOMP, "%d%s%s",
			     lineNum, p, fileData->hdr.comp );

  p += len + 1;
  len = strcspn( p, "_" );
  p[len] = '\0';
  if ( len == 0 )
    {
      type = 6;
      UMCErrorMsg( COMP_W_MISSTYPE, "%d%c", lineNum, typeChars[type] );
    }
  else
    {
      if ( len == 1 )
	{
	  for ( type = 0; type < 7; type++ )
		if ( typeChars[type] == p[0] )
			break;
	}
      else
	type = 7;
      if ( type == 7 )
	{
	  type = 6;
	  UMCErrorMsg( COMP_W_BADTYPE, "%d%s%c", lineNum, p,
			typeChars[type] );
	}
    }

  p += len + 1;
  if ( *p == '\0' )
    {
	UMCErrorMsg( COMP_F_MISSEXT, "%d", lineNum );
	return( COMP_F_MISSEXT );
    }
  else if ( strlen( p ) > UMS_FILE_EXT_LEN - 1 )
    {
	p[UMS_FILE_EXT_LEN - 1] = '\0';
	UMCErrorMsg( COMP_W_LONGEXT, "%d%s", lineNum, p );
    }
  strcpy( ext, p );
  extLen = strlen( ext ) + 1;

  p = line + labelLen;
  p += strspn( p, " \t" );
  if ( *p == ',' )
    {
	p++;
	p += strspn( p, " \t" );
	len = strcspn( p, " \t" );
	strncpy( buf, p, len );
	buf[len] = '\0';
	if ( len == 0 )
	  {
		UMCErrorMsg( COMP_F_MISSKEY2, "%d", lineNum );
		return( COMP_F_MISSKEY2 );
	  }
	else if ( len > UMS_FILE_KEY2_LEN - 1 )
	  {
		buf[UMS_FILE_KEY2_LEN - 1] = '\0';
		UMCErrorMsg( COMP_W_LONGKEY2, "%d%s", lineNum, buf );
	  }
	strcpy( key2, buf );
	key2Len = strlen( key2 ) + 1;

	p += len;
	p += strspn( p, " \t" );
    }
  else
    {
	key2[0] = '\0';
	key2Len = 1;
    }

  msg = p;
  msgLen = strlen( msg );
  if ( msgLen == 0 )
    {
	strcpy( msg, "\1\1" );
	msgLen = 2;
	UMCErrorMsg( COMP_W_BLANKMSG, "%d", lineNum );
    }

  sts = UMCCheckMem( msgLen, extLen, key2Len, fileData );
  if ( sts != COMP_S_SUCCESS )
	return( sts );

  if ( fileData->hdr.numMsg == UMC_COUNT_MAX )
    {
	UMCErrorMsg( COMP_F_TOOMANYMSG, "%d%d",
			     lineNum, UMC_COUNT_MAX );
	return( COMP_F_TOOMANYMSG );
    }

  msgNum = 0x08008000;
  /* sml:11-15-91	use long for baseNo for PCs; else OR-ing with 0 always */
/*  msgNum |= (long)( fileData->hdr.baseNo << 16 ); */
  longbaseNo = fileData->hdr.baseNo;
  msgNum |= (longbaseNo << 16);
  msgNum |= ( ( fileData->hdr.numMsg + 1 ) << 3 );
  msgNum |= type;

  idx = fileData->hdr.numMsg * UMS_FILEIDX_LEN;
  fileData->fileIdx[idx + UMS_FILEIDX_MSGNUM] = msgNum;
  fileData->fileIdx[idx + UMS_FILEIDX_TEXTPTR] = fileData->hdr.textBufLen;
  fileData->fileIdx[idx + UMS_FILEIDX_EXTPTR] = fileData->hdr.extBufLen;

  /*********************************************/
  /*                                           */
  /*  Byte swap the short value if on the Sun  */
  /*                                           */
  /*********************************************/

  temp_short = msgLen;
  UMS_short_convert (&temp_short);

  len = sizeof( short );
  memcpy( fileData->textBuf + fileData->hdr.textBufLen, (char *) &temp_short, len );
  memcpy( fileData->textBuf + fileData->hdr.textBufLen + len, msg, msgLen );

  strcpy( fileData->extBuf + fileData->hdr.extBufLen, ext );

  strcpy( fileData->key2Buf + fileData->hdr.key2BufLen, key2 );
  if ( key2Len > 1 )
	fileData->key2Count++;

  fileData->hdr.numMsg++;
  fileData->hdr.textBufLen += len + msgLen;
  fileData->hdr.extBufLen += extLen;
  fileData->hdr.key2BufLen += key2Len;

  return( COMP_S_SUCCESS );
}

/***********************************************************************

Doc:	UMCGetLine

Abstract:
	The UMCGetLine function returns the next line of meaningful data
	from the message text file, i.e. blank lines and comments are
	not returned.  It also strips leading and trailing white space
	from the line.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_I_EOF		-	Read the end-of-file

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Updated for UMS 2.0 and I/FORMS

***********************************************************************/

int	UMCGetLine( fp, line, lineNum )

  FILE	*fp;		/* i - Message text file pointer        */
  char	line[];		/* o - Buffer of meaningful data        */
  int	*lineNum;	/* i/o - Line number of meaningful data	*/
{
  int	strt, end;
  char	*ptr, tmpLine[UMC_BUFLEN];

	while ( 1 )
	{
		if ( fgets( tmpLine, UMC_BUFLEN, fp ) == NULL )
		{
			line[0] = '\0';
			return( COMP_I_EOF );
		}

		( *lineNum )++;

		strt = strspn( tmpLine, " \t" );
		if ( tmpLine[strt] == '#' )
			continue;

		for ( end = strlen( tmpLine ); end > strt; end-- )
		{
			ptr = &tmpLine[end - 1];
			if ( *ptr != '\n' && *ptr != ' ' && *ptr != '\t' )
				break;
		}
		tmpLine[end] = '\0';

		if ( strlen( &tmpLine[strt] ) )
		{
			strcpy( line, &tmpLine[strt] );
			return( COMP_S_SUCCESS );
		}
	}
}

/***********************************************************************

Doc:	UMCCheckMem

Abstract:
	If necessary, the UMCCheckMem function allocates more memory
	for the various buffers.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_INSVMEM		-	Insufficient virtual memory

History:
	15-MAR-1989	sh	Creation date
	26-MAR-1989	tz	Split into UMCCheckTextMem/UMCCheckIdxMem
	04-NOV-1989	tz	Merged and updated for UMS 2.0 and I/FORMS

***********************************************************************/

int	UMCCheckMem( msgLen, extLen, key2Len, fileData )

int	msgLen;		/* i - Length of the next message text	*/
int	extLen;		/* i - Length of the next extension--
				including null terminator	*/
int	key2Len;	/* i - Length of the next 2nd key--
				including null terminator	*/
UMCFileData *fileData;	/* i/o - Data from message text file	*/
{
	if ( fileData->hdr.numMsg + 1 > fileData->idxAlloc )
	{
	unsigned	idxSize;

		fileData->idxAlloc += UMC_IDXALLOC;
		idxSize = fileData->idxAlloc * sizeof( long ) * UMS_FILEIDX_LEN;
		fileData->fileIdx = ( fileData->fileIdx ) ?
			( long * )realloc( fileData->fileIdx, idxSize ) :
			( long * )malloc( idxSize );
		if ( ! fileData->fileIdx )
			goto insvmem;
	}

	if ( msgLen == 0 )
		;
	else if ( fileData->hdr.textBufLen + sizeof( short ) + msgLen > fileData->textAlloc )
	{
		fileData->textAlloc += UMC_TEXTALLOC;
		fileData->textBuf = ( fileData->textBuf ) ?
			realloc( fileData->textBuf, fileData->textAlloc ) :
			malloc( fileData->textAlloc );
		if ( ! fileData->textBuf )
			goto insvmem;
	}

	if ( (unsigned) (fileData->hdr.extBufLen + extLen) > fileData->extAlloc )
	{
		fileData->extAlloc += UMC_EXTALLOC;
		fileData->extBuf = ( fileData->extBuf ) ?
			realloc( fileData->extBuf, fileData->extAlloc ) :
			malloc( fileData->extAlloc );
		if ( ! fileData->extBuf )
			goto insvmem;
	}

	if ( (unsigned) (fileData->hdr.key2BufLen + key2Len) > fileData->key2Alloc )
	{
		fileData->key2Alloc += UMC_KEY2ALLOC;
		fileData->key2Buf = ( fileData->key2Buf ) ?
			realloc( fileData->key2Buf, fileData->key2Alloc ) :
			malloc( fileData->key2Alloc );
		if ( ! fileData->key2Buf )
			goto insvmem;
	}

	return( COMP_S_SUCCESS );

insvmem:
	UMCErrorMsg( COMP_F_INSVMEM, 0 );
	return( COMP_F_INSVMEM );
}
