  
  
  
  
  
  
  
  
/*
 * Copyright (c) 1989
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
 */
  
  
  
  
  
  
  
  
  
  
/******************************************************************************
  
 SOURCE FILE: di_ftp.c
  
 AUTHOR: Rick Kramer
  
 DATE: 11/27/90
  
 SDM NUMBER:
  
 DESCRIPTION: This routine ftp's the necessary files to the pc.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: 0 = ok, -1 = error receiving program
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <io.h>
#include "dinstall.h"

int DoFTP(path_name, server, which_nfs)
char *path_name, *server;
int which_nfs;
{
	int status, merror, bb;
	FILE *tmp_file;
	char tmp_name[80], wrk[80], wrk1[80], prog_name[80];
		
	if (DB==1)
		fprintf(debug_file, "path=%s server=%s\n", path_name, server);	

	Notify( -1, -1, "Receiving View/Redline programs.");

	/* set up tmp file names */
	sprintf(tmp_name, "%s\\dmands.tmp", path_name);	/* io file */
		
	/* determine program name to look for */
	switch(which_nfs)
	{
		case PC_NFS:
			strcpy(prog_name, "dmands.p");
			break;
		case FTP:
			strcpy(prog_name, "dmands.f");
			break;
		case WOLLENGONG:
			strcpy(prog_name, "dmands.w");
			break;
	}
	/* write tmp file to redirect io to ftp */
	tmp_file = fopen(tmp_name,"w");
	fprintf(tmp_file,"user\n");
	fprintf(tmp_file,"%s %s\n","nfmadmin", "nfmadm1");
	fprintf(tmp_file,"cd /usr/tmp\n");
	fprintf(tmp_file,"bin\n");
	fprintf(tmp_file,"get %s %s\\prod.exe\n", prog_name, path_name);
	fprintf(tmp_file,"bye\n");
	fclose(tmp_file);

	/* execute ftp */
	switch(which_nfs)
	{
		case PC_NFS:
			sprintf(wrk, "ftp -n %s < %s > %s\\nnn", server, tmp_name, path_name);
			break;
		case FTP:
			sprintf(wrk, "ftp -n %s < %s > %s\\nnn", server, tmp_name, path_name);
			break;
		case WOLLENGONG:
			sprintf(wrk, "ftp -n %s < %s > %s\\nnn", server, tmp_name, path_name);
			break;
	}
	if (DB==1)
		fprintf(debug_file, "wrk = %s\n",wrk);

      setovwr(1);
      setrestdir(0);
      setems(1);
      settsr(1);
      sprintf(wrk1, "%s\\nil",path_name);
      merror = holdev( wrk1, 400, wrk );
      bb = childret();
      if (DB==1)
        fprintf(debug_file,"merror=%d child=%d\n",merror,bb);

	/* remove temp files */
	if (access(tmp_name, 0)==0)
		remove(tmp_name);

	sprintf(wrk, "%s\\nnn",path_name);
	if (access(wrk, 0)==0)
		remove(wrk);

	/* is program here */
	sprintf(wrk, "%s\\prod.exe", path_name);
	if (access(wrk, 0)==0)
		status = 0;
	else
		status = 1;
	NotifyOff();
	return(status);
} /* DoFTP */