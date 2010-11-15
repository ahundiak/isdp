#include <fcntl.h>
#include <errno.h>
/* sml:10-07-91		add stdarg.h to make pums_all.h work */
#include <stdarg.h>

#include <io.h>

#include "UMS.h"
#include "UMSpriv.h"
#include "pums_all.h"

static	int		UMSfp={ -1 };
static	UMSHeader	*UMSOpenHdr={ 0 };

int int_size = 4;
int short_size = 2;
int long_size = 4;

int UMS_int_convert (value)
int * value;
{
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#ifdef sun
   int ii;
   int temp;
   char *tp, *vp;

   for ( ii = 0 , vp = (char *) value , tp = (char *) &temp + int_size - 1; ii < int_size; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#endif
	return( UMS_S_SUCCESS );
}

int UMS_long_convert (value)
long * value;
{
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#ifdef sun
   int ii;
   long temp;
   char *tp, *vp;

   for ( ii = 0 , vp = (char *) value , tp = (char *) &temp + long_size - 1; ii < long_size; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#endif
	return( UMS_S_SUCCESS );
}


int UMS_short_convert (value)
short * value;
{
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#ifdef sun
   int ii;
   short temp;
   char *tp, *vp;

   for (ii = 0 , vp = (char *) value , tp = (char *) &temp + short_size - 1; ii < short_size; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;
/* sml:09-20-91		take out ifdefs for PC
   sml:09-23-91		don't
*/
#endif
	return( UMS_S_SUCCESS );
}

/***********************************************************************

Doc:	_UMSOpenFile
Private:

Abstract:
	The _UMSOpenFile function opens the file described by the given
	header.  If another file is already open, that file is closed.

Return Status:
	UMS_S_SUCCESS	-	File opened
	UMS_E_NOFILE	-	File not found or accessible
	UMS_E_TOOMANY	-	Too many files open
	UMS_E_OPEN	-	Other (obscure) open errors

***********************************************************************/

int	_UMSOpenFile( msgHdr )
 UMSHeader	*msgHdr;	/* i - Open file described in header  */
{
  if ( UMSfp != -1 )
    {
	if ( UMSOpenHdr == msgHdr )
		return( UMS_S_SUCCESS );
	else
		_UMSCloseFile( UMSOpenHdr );
    }

  while ( 1 )
    {
      errno = 0;
      if ( ( UMSfp = open( msgHdr->msgFile, O_RDONLY | O_BINARY ) ) != -1 )
	{
	  UMSOpenHdr = msgHdr;
	  return( UMS_S_SUCCESS );
	}
      else if ( errno == ENOENT || errno == ENOTDIR || errno == EACCES )
	{
	  return( UMS_E_NOFILE );
	}
      else if ( errno == EMFILE || errno == ENFILE )
	{
	  return( UMS_E_TOOMANY );
	}
      else if ( errno != EINTR )
	{
	  return( UMS_E_OPEN );
	}
    }
}



/***********************************************************************

Doc:	_UMSCloseFile
Private:

Abstract:
	The _UMSCloseFile function close the file described by the given
	header if it is the currently opened file.

Return Status:
	UMS_S_SUCCESS	-	File closed

***********************************************************************/

int	_UMSCloseFile( msgHdr )
 UMSHeader	*msgHdr;  /* i - Close file described in header	*/
{
  if ( msgHdr != UMSOpenHdr )
    {
	return( UMS_S_SUCCESS );
    }

  while ( 1 )
    {
      errno = 0;
      if ( close( UMSfp ) != -1 )
	{
	  UMSfp = -1;
	  UMSOpenHdr = 0;
	  return( UMS_S_SUCCESS );
	}
      else if ( errno != EINTR )
	{
	  return( UMS_S_SUCCESS );
	}
    }
}

/***********************************************************************

Doc:	_UMSReadFilePos
Private:

Abstract:
	The _UMSReadFilePos function reads numBytes of data from the
	opened message file at the indicated file position.

Return Status:
	UMS_S_SUCCESS	-	Read numBytes of data
	UMS_E_SEEK	-	Error setting file pointer
	UMS_E_EOF	-	Read past the end-of-file marker
	UMS_E_READ	-	Other error reading file

***********************************************************************/

int	_UMSReadFilePos( dataBuf, numBytes, filePos )
 char		dataBuf[];	/* o - Buffer at least numBytes long  */
 unsigned	numBytes;	/* i - Number of bytes to read	      */
 long		filePos;	/* i - Read at this file position     */
{
  int	sts;

  sts = _UMSFilePos( filePos );
  if ( sts != UMS_S_SUCCESS )
    {
      return( sts );
    }

  sts = _UMSReadFile( dataBuf, numBytes );
  return( sts );
}

/***********************************************************************

Doc:	_UMSFilePos
Private:

Abstract:
	The _UMSFilePos function moves the file pointer to the indicated
	file offset.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_SEEK	-	Error setting file pointer

***********************************************************************/

int	_UMSFilePos( filePos )
 long	filePos;	/* i - Move file pointer to this offset	*/
{
  if ( lseek( UMSfp, filePos, 0 ) == -1 )
	return( UMS_E_SEEK );
  else
	return( UMS_S_SUCCESS );
}

/***********************************************************************

Doc:	_UMSReadFile
Private:

Abstract:
	The _UMSReadFile function read numBytes of data from the opened
	message file at the current file position.

Return Status:
	UMS_S_SUCCESS	-	Read numBytes of data
	UMS_E_EOF	-	Read past the end-of-file marker
	UMS_E_READ	-	Other error reading file

***********************************************************************/

int	_UMSReadFile( dataBuf, numBytes )
 char		dataBuf[]; /* o - Buffer at least numBytes long	*/
 unsigned	numBytes;  /* i - Number of bytes to read	*/
{
  int	numRead;

  while ( 1 )
    {
	errno = 0;
	numRead = read( UMSfp, dataBuf, numBytes );
	if ( (unsigned) numRead == numBytes )
		return( UMS_S_SUCCESS );
	else if ( numRead > -1 )
		return( UMS_E_EOF );
	else if ( errno != EINTR )
		return( UMS_E_READ );
    }
}
