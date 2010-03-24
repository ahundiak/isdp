#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <UMSfile.h>
#include <UMCcomp.h>
#include <COMP.h>

#include <pums_pub.h>
#include <pums_pri.h>

/*#define	UMC_MSGTYPE( msgNum )	msgNum & 0x0007*/
/* sml:10-08-91		change to long literal for PCs */
#define	UMC_MSGTYPE( msgNum )	msgNum & 0x00000007

static	char	typeChars[]={ "WSEIFPM" };

/*static int int_size = sizeof (int);		 not used */
static int short_size = sizeof (short);
static int long_size = sizeof (long);

/******************************************************************************

Doc:	UMCWriteMsg

Abstract:
	The UMCWriteMsg function uses the data generated from the message
	text file to produce the UMS message file.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_WRITEMSG		-	Error writing message file

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

char		*msgFile;	 i - Indexed message file
UMCFileData	*fileData;	 i - Data from message text file

******************************************************************************/

int	UMCWriteMsg( char *msgFile, UMCFileData *fileData )
{
int	sts, msgFd;
/*int temp;*/
/*sml:10-08-91			change temp to long for PCs */
long temp;
short temp_short;

/* sml:11-18-91		define O_BINARY for workstations */
#ifndef O_BINARY
#define O_BINARY 0
#endif
	msgFd = open( msgFile, O_BINARY | O_WRONLY | O_CREAT | O_TRUNC, 0666 );
	if ( msgFd == -1 )
	{
		UMCErrorMsg( COMP_F_WRITEMSG, "%s", msgFile );
		perror( "" );
		return( COMP_F_WRITEMSG );
	}
/*
	sts = write( msgFd, &fileData->hdr, sizeof( UMSFileHdr ) );
*/
/*
fprintf (stderr, "sizeof (UMSFileHdr) = %d\n", sizeof (UMSFileHdr));
*/

/**********************************************************************/
/*                                                                    */
/*      Instead of writing out the whole structure at once, save the  */
/*      elements of the structure.  GMD 4/26/91                       */
/*                                                                    */
/**********************************************************************/

        sts = write (msgFd, &(fileData->hdr.ums[0]), 3);
        sts = write (msgFd, &(fileData->hdr.version), 1);

        temp_short = fileData->hdr.baseNo;
        UMS_short_convert (&temp_short);
        sts = write (msgFd, &temp_short, short_size);

	sts = write (msgFd, &(fileData->hdr.comp[0]), UMS_FILE_COMP_LEN);

        temp = fileData->hdr.numMsg; 
        UMS_long_convert (&temp);
	sts = write (msgFd, &temp, long_size);

        temp = fileData->hdr.textBufLen;
        UMS_long_convert (&temp);
        sts = write (msgFd, &temp, long_size);

        temp = fileData->hdr.extBufLen;
        UMS_long_convert (&temp);
        sts = write (msgFd, &temp, long_size);

        temp = fileData->hdr.key2BufLen;
        UMS_long_convert (&temp);
        sts = write (msgFd, &temp, long_size);
	if ( sts == -1 )
		goto write_error;

	sts = write( msgFd, fileData->fileIdx,
		     fileData->hdr.numMsg * sizeof( long ) * UMS_FILEIDX_LEN );
	if ( sts == -1 )
		goto write_error;
	sts = write( msgFd, fileData->textBuf, fileData->hdr.textBufLen );
	if ( sts == -1 )
		goto write_error;
	sts = write( msgFd, fileData->extBuf, fileData->hdr.extBufLen );
	if ( sts == -1 )
		goto write_error;
	if ( fileData->hdr.key2BufLen )
	{
		sts = write( msgFd, fileData->key2Buf, fileData->hdr.key2BufLen );
		if ( sts == -1 )
			goto write_error;
	}
	close( msgFd );

	UMCErrorMsg( COMP_M_CREATEMSG, "%s", msgFile );
	return( COMP_S_SUCCESS );

write_error:
	UMCErrorMsg( COMP_F_WRITEMSG, "%s", msgFile );
	perror( "" );
	close( msgFd );
	return( COMP_F_WRITEMSG );
}	

/******************************************************************************

Doc:	UMCWriteH

Abstract:
	The UMCWriteH function uses the data generated by reading the
	message text file to produce a C header file.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_WRITEPROG	-	Error writing programming file

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

char		*progFile;	 i - Programming file
UMCFileData	*fileData;	 i - Data from message text file

******************************************************************************/

int	UMCWriteH( char *progFile, UMCFileData *fileData )
{
FILE	*fp;
long	extOff, msgNum;
int	i, idx, len, noTab;
char	*extPtr, buf[80];
/*int temp;*/
/* sml:10-08-91			change temp to long for PCs */
long     temp;

	extOff = 32 +   /*  sizeof( UMSFileHdr )  */
		 fileData->hdr.numMsg * sizeof( long ) * UMS_FILEIDX_LEN +
		 fileData->hdr.textBufLen;

	if ( ( fp = fopen( progFile, "w" ) ) == NULL )
	{
		UMCErrorMsg( COMP_F_WRITEPROG, "%s", progFile );
		perror( "" );
		return( COMP_F_WRITEPROG );
	}
	for ( i = 0; i < fileData->hdr.numMsg; i++ )
	{
		idx = i * UMS_FILEIDX_LEN;
		temp = fileData->fileIdx[idx + UMS_FILEIDX_MSGNUM];
                UMS_long_convert (&temp);
 		msgNum = temp;
		if ( msgNum != 0 )
		{
                        temp = fileData->fileIdx[idx + UMS_FILEIDX_EXTPTR];
                        UMS_long_convert (&temp);
			extPtr = fileData->extBuf + temp - extOff;
			sprintf( buf, "#define\t%s_%c_%s\t", fileData->hdr.comp,
				 typeChars[ UMC_MSGTYPE( msgNum )], extPtr );

			len = strlen( buf );
			for ( noTab = 4 - ( len - 1 ) / 8; noTab > 0; noTab-- )
				buf[len++] = '\t';
			/* sml:11-18-91 change format to 0x%08lx for PC */
			/* sprintf( &buf[len], "0x%08x", msgNum ); */
			sprintf( &buf[len], "0x%08lx", msgNum );
			fprintf( fp, "%s\n", buf );
		}
	}
	fclose( fp );

	UMCErrorMsg( COMP_M_CREATEPROG, "%s", progFile );
	return( COMP_S_SUCCESS );
}

/******************************************************************************

Doc:	UMCWriteInc

Abstract:
	The UMCWriteInc function uses the data generated by reading the
	message text file to produce a Fortran include file.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_WRITEPROG	-	Error writing programming file

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS


char		*progFile;	 i - Programming file
UMCFileData	*fileData;	 i - Data from message text file

******************************************************************************/

int	UMCWriteInc( char *progFile, UMCFileData *fileData )
{
FILE	*fp;
long	extOff, msgNum;
int	i, idx;
char	*extPtr;
/*int     temp;*/
/* sml:10-08-91		change temp to long for PCs */
long temp;
	
	extOff = 32 +  /* sizeof( UMSFileHdr ) */
		 fileData->hdr.numMsg * sizeof( long ) * UMS_FILEIDX_LEN +
		 fileData->hdr.textBufLen;

	if ( ( fp = fopen( progFile,"w" ) ) == NULL )
	{
		UMCErrorMsg( COMP_F_WRITEPROG, "%s", progFile );
		perror( "" );
		return( COMP_F_WRITEPROG );
	}
	for ( i = 0; i < fileData->hdr.numMsg; i++ )
	{
		idx = i * UMS_FILEIDX_LEN;
		temp = fileData->fileIdx[idx + UMS_FILEIDX_MSGNUM];
                UMS_long_convert (&temp);
		msgNum = temp;
		if ( msgNum != 0 )
		{
                        temp = fileData->fileIdx[idx + UMS_FILEIDX_EXTPTR];
                        UMS_long_convert (&temp);
			extPtr = fileData->extBuf + temp - extOff;

			/***************************************************/
			/* sml:04-29-94:TR 249302397                       */
			/*  Don't use parentheses in Fortran statements.   */
			/*  This makes the numbers real, not integer.      */
			/***************************************************/
/*			fprintf( fp, "\tparameter (%s_%c_%s = %d)\n",*/
			fprintf( fp, "\tparameter %s_%c_%s = %d\n",
				 fileData->hdr.comp,
				 typeChars[ UMC_MSGTYPE( msgNum ) ],
				 extPtr, msgNum );
		}
	}
	fclose( fp );

	UMCErrorMsg( COMP_M_CREATEPROG, "%s", progFile );
	return( COMP_S_SUCCESS );
}
