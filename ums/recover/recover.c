#include <sys/types.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include "UMS.h"

/******************************************************************************

Doc:	main

Abstract:
	This program reconstructs a message text file from the runtime
	message file.

******************************************************************************/

main( argc, argv )
int	argc;
char	*argv[];
{
#define	MSGFILE_ARG	1
#define	TXTFILE_ARG	2
#define	COMP_ARG	3
#define	BASENO_ARG	4

FILE	*fp;
int	baseMsgNum, baseNo, count, type, msgNum;
int	sts, lastCount;
char	*dashPtr, label[45], key2Buf[33], msgBuf[512];

	if ( argc != 5 )
	{
		fprintf( stderr,
			 "Usage : %s <msg file> <text file> <component> <base number>\n",
			 argv[0] );
		exit( 1 );
	}

	if ( ( sts = UMSInitMsg( argv[MSGFILE_ARG],
				 UMS_MESSAGE | UMS_KEY | UMS_KEY2 ) ) != UMS_S_SUCCESS )
	{
		switch ( sts )
		{
		case UMS_E_NOFILE:
		case UMS_E_TOOMANY:
		case UMS_E_OPEN:
			fprintf( stderr, "Error opening %s\n", argv[MSGFILE_ARG] );
			perror( "" );
			break;
		case UMS_E_SEEK:
		case UMS_E_READ:
			fprintf( stderr, "Error reading %s\n", argv[MSGFILE_ARG] );
			perror( "" );
			break;
		case UMS_E_INVFMT:
		case UMS_E_INVVER:
		case UMS_E_EOF:
			fprintf( stderr, "%s is not a valid message file\n", argv[MSGFILE_ARG] );
			break;
		case UMS_E_INSVMEM:
			fprintf( stderr, "Not enough memory to load %s\n", argv[MSGFILE_ARG] );
			break;
		}
		exit( 1 );
	}

	if ( ( fp = fopen( argv[TXTFILE_ARG], "w" ) ) == NULL )
	{
		fprintf( stderr, "Error opening %s\n", argv[TXTFILE_ARG] );
		perror( "" );
		exit( 1 );
	}

	if ( strlen( argv[COMP_ARG] ) < 2 || strlen( argv[COMP_ARG] ) > 9 ||
	     ! isalpha( argv[COMP_ARG][0] ) )
	{
		fprintf( stderr, "Invalid component %s\n", argv[COMP_ARG] );
		exit( 0 );
	}

	baseNo = atoi( argv[BASENO_ARG] );
	if ( baseNo < 1 || baseNo > 2047 )
	{
		fprintf( stderr, "Invalid base number %s\n", argv[BASENO_ARG] );
		exit( 0 );
	}

	fprintf( fp, "::UMS\n" );
	fprintf( fp, "%s\t%d\n", argv[COMP_ARG], baseNo );

	baseMsgNum = 0x08008000 | ( baseNo << 16 );
	lastCount = 1;
	for ( count = 1; count < 4096; count++ )
	{
		msgNum = baseMsgNum | ( count << 3 );
		for ( type = 0; type < 8; type++ )
		{
			msgNum &= 0xfffffff8;
			msgNum |= type;
			sts = UMSMsgCode( label, msgNum, 0, 0, 0, 0 );
			if ( sts == UMS_S_SUCCESS )
				break;
		}

		if ( type == 8 )
			continue;

		if ( lastCount < count - 1 )
			fprintf( fp, ".COUNT %d\n", count );
		lastCount = count;

		dashPtr = strchr( label, '-' );
		dashPtr[0] = '_';
		dashPtr[2] = '_';
		sts = UMSGetKeyByNum( 0, key2Buf, msgNum );
		sts = _UMSReturnByNum( msgBuf, msgNum );

		if ( strcmp( msgBuf, "\1\1" ) == 0 )
			msgBuf[0] = '\0';

		if ( strlen( key2Buf ) )
			fprintf( fp, "%s,%s\t%s\n", label, key2Buf, msgBuf );
		else
			fprintf( fp, "%s\t%s\n", label, msgBuf );
	}

	fclose( fp );
	exit( 0 );
}
