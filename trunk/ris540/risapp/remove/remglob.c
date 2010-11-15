/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
  
  
  
  
  
  
  
  
/*
 * Copyright (c) 1993
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
*/
  
  
  
  
  
  
  
  
  
  
/******************************************************************************
	SOURCE FILE: remsetup.c
	AUTHOR: Rick Kramer
	DATE: 06/25/93
	SDM NUMBER:
	DESCRIPTION: This program contains the set-up data for the remove program.

	FUNCTIONS INVOKED:

	PARAMETERS:
	  ON ENTRY:
	  ON EXIT:
  
	EXTERNAL VARIABLES:
  
	CHANGE HISTORY:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "remglob.prt"

/******************************************************************************
					SetupProduct
******************************************************************************/
extern void SetupProduct(char *ProductName,char *ProductDescription,char *LogFile)
{
	strcpy(ProductName,"RISDP");
	strcpy(ProductDescription,"RIS Development Platform for DOS");
	sprintf(LogFile,"%s.log",ProductName);

}/* SetupProduct */
/******************************************************************************
					SetupBanners
******************************************************************************/
extern void SetupBanners(char *ProdDir,char *RootDir,char *StartBanner, char *CloseBanner,char *ProductDescription, char *ProductName)
{
	char wrk[80];

	/* startup banner */
	sprintf(StartBanner,"This program will remove the %s product.\n",ProductDescription);
	strcat(StartBanner,"This will include all files and programs starting from the following\n");
	if (strcmp(RootDir,"")!=0)
	{
		sprintf(wrk,"directory: %s. If %s\n",ProdDir,RootDir);
		strcat(StartBanner, wrk);
		strcpy(wrk,"is empty, it will also be removed.\n");
		strcat(StartBanner, wrk);
	}
	else
	{
		sprintf(wrk,"directory: %s.\n",ProdDir);
		strcat(StartBanner, wrk);
	}

	/* closing banner */
	strcpy(CloseBanner,"\nRemove the following from your autoexec.bat file:\n");
	sprintf(wrk,"  From the path statement: %s\\bin\n",ProdDir);
	strcat(CloseBanner, wrk);
	sprintf(wrk,"  The line containing SET %s=%s\n",ProductName,ProdDir);
	strcat(CloseBanner, wrk);
}/* SetupBanners */
