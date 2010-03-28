/**
**   PROGRAM:  FTBChTf.c
**
**   HISTORY:  Name             Date       Note
**           ---------------------------------------------
**           Joe Wagner         12-89      
**
**DESCRIPTION: This program reads a file and checks to see if it is a
**		BITSTREAM file.
**
**      The arguments are :
**			INPUT filename
**
**				returns 0 = success
**						1 = failure
**/

/*
$Log: GRChTf.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:28  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:46  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:39  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:54:03  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:55  root
 * COMMENT : Corresponds to Rel201.5 in 2.0.1 RCS
 *
 * Revision 201.5  1992/07/13  20:41:36  tim
 * COMMENT : added Log variable
 *
*/

#include "igrtypedef.h"
#include <stdio.h>

#define MAX_NAME 100

main(argc,argv)

int     argc;
char	*argv[];

{
	IGRchar    buffer[132];
	IGRchar    filename[MAX_NAME];
	FILE       *file_read = 0;
	FILE       *fopen();

	if (argc <= 1)
	{
	  printf("Enter INPUT filename to be checked: ");
	  scanf("%s",filename);
	}
	else
	{
	  strcpy(filename,argv[1]);
	}

	if ((file_read = fopen(filename,"r")) == 0)
	{
	  printf("\nERROR : Can't open INPUT file.\n");
	  goto wrapup;
	}

	/*************************************************************/
	/***     Read first 132 bytes from the input file.         ***/
	/***     Then check to see if the word BITSTREAM is        ***/
	/***     between locations 146 and 156.                    ***/
	/*************************************************************/

	fread (buffer, 1, 132, file_read);

	if ((buffer[102]==0x42) && (buffer[103]==0x69) && (buffer[104]==0x74) /
	    (buffer[105]==0x73) && (buffer[106]==0x74) && (buffer[107]==0x72) /
	    (buffer[108]==0x65) && (buffer[109]==0x61) && (buffer[110]==0x6d))
		{
/*		printf("The file is a Bitstream file.\n"); */
		exit(0);
		}
	else
		{
		printf("The file is NOT a Bitstream file.\n");
		exit(1);
		}
wrapup:

	if (file_read)
	{
	  fclose(file_read);
	}
}	
