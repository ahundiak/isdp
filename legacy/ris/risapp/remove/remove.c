/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
  
  
  
  
  
  
  
  
/*
 * Copyright (c) 1993
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
*/
  
  
  
  
  
  
  
  
  
  
/******************************************************************************
	SOURCE FILE: remove.c
	AUTHOR: Rick Kramer
	DATE: 04/23/93
	SDM NUMBER:
	DESCRIPTION: This program will Remove RIS PC programs, files and directories.

	FUNCTIONS INVOKED:

	PARAMETERS:
	  ON ENTRY:
	  ON EXIT:
  
	EXTERNAL VARIABLES:
  
	CHANGE HISTORY:
		06/25/93 -	rewritten to determine prod and root directories and
						to determine product tree.
		Feb. 94 - Modified to remove runtime-product(RISRT) also - Sanju
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <direct.h>
#include "remove.prt"
#include "remglob.prt"

#define VERSION "1.0.0.5"
#define MAX_DIRS 50

#define REMOVE_DIR_FILES_MSG "Removing Files and directory:"
#define REMOVE_DIR_MSG "Removing directory:"
#define REMOVE_DIR_NOT_EMPTY_MSG "Directory is not empty and could not be removed:"
#define REMOVE_DIR_EMPTY_MSG "Directory was removed:"

#define ERROR_REMOVING_FILES	"Error removing files in directory:"
#define ERROR_REMOVING_DIR		"Error removing directory:"

#define DEBUG 0/* on=1 off=0 */

char  ProdDir[80];/* like c:\ris\rick\risutl */
char  RootDir[80]; /* like c:\ris\rick */
char StartBanner[512];
char CloseBanner[512];
char LogFile[80];
int NumSubDirs=0;
char dirs[MAX_DIRS][80];
char szCurrentDir[128], szFileName[128];

void SearchDir (void);
/****************************************************************************
        Name: main rtn
****************************************************************************/
main(argc, argv)
int argc;
char *argv[];
{
	int status;
	char ProductDescription[80];
	char ProductName[80];

	if(1 < argc) /* 1995.10.13:Alan Barksdale:like TR439503705 */
	{
		if( strcmp(argv[1],"-v")==0)
		{
			printf("remove version %s\n",VERSION);
			exit(1);
		}
	}  /* if(1 < argc) */
	/* set up */
	SetupProduct(ProductName,ProductDescription,LogFile);

	DetermineDirectories(argv[0]);/* get prod and root dirs */

	/* setup banners */
	SetupBanners(ProdDir,RootDir,StartBanner,CloseBanner,ProductDescription,
		ProductName);

	/* start processing */
	status = ShowInstructions();/* instructions and get action*/
	if (status == 1)
		exit(0);

	/* change to the product root directory root */
	_chdir(ProdDir);

	/* Delete Product */
	status = RemoveProduct();
	if (status ==0)
		printf("%s",CloseBanner);	/* print autoexec instructions */
	else
	{
		printf("Product not completely removed\n");
	}
}/*main */

/****************************************************************************
        Name: ShowInstructions
****************************************************************************/
extern int ShowInstructions()
{
	char answer[10];
	int status = 2;

	printf("%s\n\n",StartBanner);

	while (status ==2)
	{
		printf("Do you want to continue (y/n): ");
		gets(answer);
	
		if (tolower(answer[0]) == 'n')
			status = 1;

		if (tolower(answer[0]) == 'y')
			status = 0;
	}
	printf("\n\n");
	return(status);
}/* ShowInstructions */

/******************************************************************************
					DetermineDirectories
******************************************************************************/
extern void DetermineDirectories(char *CommandLine)
{
	int i=0,j=0;
	int ProdLen;

	strcpy(ProdDir, CommandLine);
	ProdLen = strlen(ProdDir);
	for (j = ProdLen-1; j>=0; j--)
	{
		if (ProdDir[j] == '\\')
			break;
	}
	ProdDir[j] = '\0';/* strip off program name */
	j = 0;
	for (i=0; i<strlen(ProdDir); i++)
	{
		if (ProdDir[i] == '\\')
			j++;
	}
	if (j == 1)
	{
		/* no root dir */
		strcpy(RootDir,"");
	}
	else
	{
		strcpy(RootDir,ProdDir);
		for (i=strlen(RootDir)-1; i>=0; i--)
		{
			if (RootDir[i] == '\\')
			{
				RootDir[i] = '\0';
				break;
			}
		}
	}
}/* DetermineDirectories */
/******************************************************************************
					RemoveProduct
******************************************************************************/
extern int RemoveProduct()
{
	char wrk[80];
	int i;
	int status;
	char * rt_env;
	char buffer[100];

	/* GetSubDirectories */
	sprintf(wrk, "%s\\*.*", ProdDir);
	SearchDir ();

	/* add in prod dir */
	strcpy(dirs[0], ProdDir);
	NumSubDirs++;

	/* change to the directory root of installed drive */
	sprintf(wrk,"%c:\\",ProdDir[0]);
	_chdir(wrk);

	for(i=NumSubDirs-1; i>=0; i--)
	{
		printf("%s %s\n",REMOVE_DIR_FILES_MSG,dirs[i]);

		/* now delete the files for that dir */
		status = DeleteFiles(dirs[i]);
		if (status == -1)
		{
			printf("%s %s\n", ERROR_REMOVING_FILES,dirs[i]);
			return(-1);
		}
		/* now delete the directory itself */
		status = DeleteDirectory(dirs[i]);
		if (status !=0)
		{
			printf("%s %s\n", ERROR_REMOVING_DIR,dirs[i+1]);
			return(-1);
		}	
	}
	/* remove the runtime procuct RISRT  -- Sanju */
	if ((rt_env = getenv("RISRT")) != NULL)
	{
		strcpy(buffer, rt_env);
		strcat(buffer, "\\remove.exe");
		system(buffer);
	}

	/* remove the log file */
#if DEBUG
printf("removing log file\n");
#endif
	sprintf(wrk,"%s\\%s",RootDir,LogFile);
	remove(wrk);

	/* remove the root if empty */
	if (DeleteDirectory(RootDir) !=0)
		printf("%s %s\n",REMOVE_DIR_NOT_EMPTY_MSG,RootDir);
	else
		printf("%s %s\n",REMOVE_DIR_EMPTY_MSG,RootDir);
	return(0);
}/* RemoveProduct */
/******************************************************************************
				Delete Directory
******************************************************************************/
extern int DeleteDirectory(char *DirName)
{
	/* remove the directory */
#if DEBUG
printf("deleting dir %s\n",DirName);
#endif
	if (_rmdir(DirName) !=0)
		return(-1);
	return(0);
}/* DeleteDirectory */

/******************************************************************************
					DeleteFiles
******************************************************************************/
extern int DeleteFiles(char *path)
{
	struct find_t fileinfo;
	int result;
	char wrk[128];

	sprintf(wrk, "%s\\*.*", path);
	result = _dos_findfirst(wrk, _A_NORMAL, &fileinfo);
	if (result !=0)
		return(0);
	
	while (!result)
	{
		sprintf(wrk, "%s\\%s", path, fileinfo.name);
#if DEBUG
printf("removing %s\n",wrk);
#endif
		if (remove(wrk))
			return(-1);
		result = _dos_findnext(&fileinfo);
	}
	return(0);
}/* DeleteFiles */
/******************************************************************************
					SearchDir
******************************************************************************/
void SearchDir (void)
{
	struct find_t FileInfo;
 
	/* Find the first file in the current directory.*/
	if (!_dos_findfirst ("*.*", _A_NORMAL | _A_RDONLY, &FileInfo))
	{
	    getcwd (szCurrentDir, 128);
		sprintf(szFileName, "%s\\%s",szCurrentDir,FileInfo.name, 128);
 
		/* Loop until all files have been found.*/
		while (!_dos_findnext (&FileInfo))
		{
		    getcwd (szCurrentDir, 128);
			sprintf(szFileName,"%s\\%s",szCurrentDir, FileInfo.name, 128);
		}
	}
	/* Now search for a subdirectory.  If a subdirectory is
	   found, change to it and call SearchDir recursively.*/
 
	if (!_dos_findfirst ("*.*", _A_SUBDIR, &FileInfo))
	{
		if ((FileInfo.attrib & 0x10) != 0x00)
			if ((strcmp (FileInfo.name, ".") != 0) &&
				(strcmp (FileInfo.name, "..") != 0))
			{
				chdir (FileInfo.name);
				SearchDir ();
				chdir ("..");
			}
 
			/* Search for additional subdirectories.*/
			while (!_dos_findnext (&FileInfo))
				if ((FileInfo.attrib & 0x10) != 0x00)
					if ((strcmp (FileInfo.name, ".") != 0) &&
						(strcmp (FileInfo.name, "..") != 0))
					{
					    getcwd (szCurrentDir, 128);
						sprintf(szFileName, "%s\\%s",szCurrentDir,FileInfo.name, 128);
						NumSubDirs++;
						if (NumSubDirs +1 > MAX_DIRS)
						{
							printf("Too many directories to delete, product is still intact\n");
							exit(1);
						}
						strcpy(dirs[NumSubDirs],szFileName);
						chdir (FileInfo.name);
						SearchDir ();
						chdir ("..");
					}
	}
}/* SearchDir */
