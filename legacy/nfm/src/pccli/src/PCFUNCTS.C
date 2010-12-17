#include <stdio.h>
#include <malloc.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include <process.h>
#include <stdlib.h>
#include "CLIerrordef.h"
#include "CLIstruct.h"
#include "CLIextern.h"
#include "NFMerrordef.h"
#include "pc.h"
#include "proto.h"
#include <memcheck.h>
short clnt_fd;
long clientid;
extern char npath[51];
extern char *buffer;

long finddisk(drive)
	char *drive;
{
	struct stat info;
	char x;
	char drivestring[2];

	memset( drivestring, '\0', 2 );
	for ( x='C'; x<='Z'; x++ )
	{
		drivestring[0]=x;
		drivestring[1]=':';
		if ( stat(drivestring, &info) != 0 )
		{
			strcpy(drive,drivestring);
			return(NFM_S_SUCCESS);
		}
	}
	return(NFM_E_FAILURE);
}

long checkdisk(drive)
	char *drive;
{
	struct stat info;
	if ( stat(drive, &info) == 0 )
	{
		return(NFM_S_SUCCESS);
	}
	return(NFM_E_FAILURE);
}

long mountdisk(drive,interaddr,n_username,n_passwd,n_pathname)
	char *drive;
	char *interaddr, *n_username, *n_passwd, *n_pathname;
{
	char doscommand[128];

	memset( doscommand, '\0', 128 );
	sprintf( doscommand, "echo %s| idmnt %c %s %s %s USER %s", n_passwd, drive[0], interaddr, n_pathname, drive, n_username );
	if ( system( doscommand ) == 0)
	{
		/* System call successful - Check if mount exists */
		if ( checkdisk(drive) == NFM_S_SUCCESS )
		{
			/* Mount successful */
			return(NFM_S_SUCCESS);
		}
		else
		{
			/* Mount unsuccessful */
			return(NFM_E_FAILURE);
		}
	}
	/* System call failed */
	return(NFM_E_FAILURE);
}

long unmountdisk(drive)
	char *drive;
{
	char doscommand[128];

	memset( doscommand, '\0', 128 );
	sprintf( doscommand, "idumnt %s", drive );
	if ( system( doscommand ) == 0)
	{
		/* System call successful - Check if mount exists */
		if ( checkdisk(drive) == NFM_E_FAILURE )
		{
			/* UnMount successful */
			return(NFM_S_SUCCESS);
		}
		else
		{
			/* UnMount unsuccessful */
			return(NFM_E_FAILURE);
		}
	}
	/* System call failed */
	return(NFM_E_FAILURE);
}

long ftpget(interaddr,n_username,n_passwd,n_pathname,n_cifilename,localpath,n_cofilename) 
	char *interaddr;
	char *n_username;
	char *n_passwd;
	char *n_pathname;
	char *n_cifilename;
	char *localpath;
	char *n_cofilename;
{
        struct stat filestatus ;
	char doscommand[128];
	char tempcmdfilename[128];
	char tempsendfilename[128];
	FILE *tempcmdfile;
	short status;

	/* check if working area path exists */
	_CLI_str ("stat on %s", localpath) ;
	status = stat (localpath, &filestatus) ;
	if (status != 0)
	  {
	    if ((strcmp (localpath, "C:")) &&
		(strcmp (localpath, "c:")))
	      {
		_CLI_str("bad path  %s", localpath) ;
		return (NFM_E_FAILURE) ;
	      }
	  }

	_CLI_str("wa path %s exists", localpath) ;

	memset( doscommand, '\0', 128 );
	memset( tempcmdfilename, '\0', 128 );
	memset( tempsendfilename, '\0', 128 );
	sprintf( tempcmdfilename, "%s\\temp\\nfmpc.tmp", npath );
	sprintf( tempsendfilename, "%s\\temp\\nfmsend.tmp", npath );
	if ( (tempcmdfile = fopen(tempcmdfilename,"w")) == NULL)
	{
	_CLI_str("%s","FTPGET: Failed to open command file");
	return(NFM_E_FAILURE);
	}
	_CLI_str("%s","FTPGET: Command file opened");
#ifdef PCTCP
	fprintf(tempcmdfile,"%s\n",n_username);
	fprintf(tempcmdfile,"%s\n",n_passwd);
#endif
#ifdef PCNFS
	fprintf(tempcmdfile,"user %s %s\n",n_username,n_passwd);
#endif
	fprintf(tempcmdfile,"cd %s\n",n_pathname);
	fprintf(tempcmdfile,"bin\n");
	fprintf(tempcmdfile,"get %s %s\\%s\n", n_cifilename, localpath, n_cofilename);
	fprintf(tempcmdfile,"bye\n");
	fclose(tempcmdfile);
#ifdef PCTCP
	sprintf(doscommand, "command /c ftp %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
#ifdef PCNFS
	sprintf(doscommand, "ftp -n  %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
	_CLI_str("FTPGET: dos command=<%s>",doscommand);
	status = system(doscommand);
	_CLI_str("FTPGET: dos command status=<%d>",status);
	if ( status == 0)
	{
		/* System call succesful */
		_CLI_str("%s","FTPGET: dos command successful");
		if ( NFMscan_ftp_output(tempsendfilename) != NFM_S_SUCCESS )
		{
			return(NFM_E_FAILURE);
		}
		else
		{
			return(NFM_S_SUCCESS);
		}
	}
	else
	{
		_CLI_str("%s","FTPGET: dos command failed");
		return(NFM_E_FAILURE);
	}
}

long ftpput(interaddr,n_username,n_passwd,n_pathname,n_cifilename,localpath,n_cofilename) 
	char *interaddr;
	char *n_username;
	char *n_passwd;
	char *n_pathname;
	char *n_cifilename;
	char *localpath;
	char *n_cofilename;
{
        struct stat filestatus ;
	char doscommand[128];
	char tempcmdfilename[128];
	char tempsendfilename[128];
	char wa_file [128] ;
	FILE *tempcmdfile;
	short status;

	/* check if working area file exists */
	sprintf (wa_file, "%s\\%s", localpath, n_cofilename) ;
	status = stat (wa_file, &filestatus) ;
	if (status != 0)
	  {
	    _CLI_str("bad wa file %s exists", wa_file) ;
	    return (NFM_E_FAILURE) ;
	  }

	_CLI_str("wa file %s exists", wa_file) ;
	memset( doscommand, '\0', 128 );
	memset( tempcmdfilename, '\0', 128 );
	memset( tempsendfilename, '\0', 128 );
	sprintf( tempcmdfilename, "%s\\temp\\nfmpc.tmp", npath );
	sprintf( tempsendfilename, "%s\\temp\\nfmsend.tmp", npath );
	if ( (tempcmdfile = fopen(tempcmdfilename,"w")) == NULL)
	{
		_CLI_str("%s","FTPSEND: Failed to open command file");
		return(NFM_E_FAILURE);
	}
	_CLI_str("%s","FTPSEND: Command file opened");
#ifdef PCTCP
	fprintf(tempcmdfile,"%s\n",n_username);
	fprintf(tempcmdfile,"%s\n",n_passwd);
#endif
#ifdef PCNFS
	fprintf(tempcmdfile,"user %s %s\n",n_username,n_passwd);
#endif
	fprintf(tempcmdfile,"cd %s\n",n_pathname);
	fprintf(tempcmdfile,"bin\n");
	fprintf(tempcmdfile,"put %s\\%s %s\n", localpath, n_cofilename, n_cifilename);
	fprintf(tempcmdfile,"bye\n");
	fclose(tempcmdfile);
#ifdef PCTCP
	sprintf(doscommand, "command /c ftp %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
#ifdef PCNFS
	sprintf(doscommand, "ftp -n %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
	_CLI_str("FTPSEND: dos command=<%s>",doscommand);
	status = system(doscommand);
	_CLI_str("FTPSEND: dos command status=<%d>",status);
	if ( status == 0)
	{
		/* System call succesful */
		_CLI_str("%s","FTPSEND: dos command successful");
		if ( NFMscan_ftp_output(tempsendfilename) != NFM_S_SUCCESS )
		{
			return(NFM_E_FAILURE);
		}
		else
		{
			return(NFM_S_SUCCESS);
		}
	}
	else
	{
		_CLI_str("%s","FTPSEND: dos command failed");
		return(NFM_E_FAILURE);
	}
}

long ftpdel(interaddr,n_username,n_passwd,n_pathname,n_cifilename,localpath) 
	char *interaddr;
	char *n_username;
	char *n_passwd;
	char *n_pathname;
	char *n_cifilename;
	char *localpath;
{
  char *fname = "ftpdel" ;
  char doscommand[128];
  char tempcmdfilename[128];
  char tempsendfilename[128];
  FILE *tempcmdfile;
  short status;
  
  _CLI_str ("%s : ENTER", fname) ;
  _CLI_str ("interaddress <%s>", interaddr) ;
  _CLI_str ("username <%s>", n_username) ;
  _CLI_str ("pathname <%s>", n_pathname) ;
  _CLI_str ("cifilename <%s>", n_cifilename) ;
  _CLI_str ("local path <%s>", localpath) ;
  
  memset( doscommand, '\0', 128 );
  memset( tempcmdfilename, '\0', 128 );
  memset( tempsendfilename, '\0', 128 );
  sprintf( tempcmdfilename, "%s\\temp\\nfmpc.tmp", npath );
  sprintf( tempsendfilename, "%s\\temp\\nfmsend.tmp", npath );
  if ( (tempcmdfile = fopen(tempcmdfilename,"w")) == NULL)
	{
	_CLI_str("%s","FTPDEL: Failed to open command file");
	return(NFM_E_FAILURE);
	}
	_CLI_str("%s","FTPDEL: Command file opened");
#ifdef PCTCP
	fprintf(tempcmdfile,"%s\n",n_username);
	fprintf(tempcmdfile,"%s\n",n_passwd);
#endif
#ifdef PCNFS
	fprintf(tempcmdfile,"user %s %s\n",n_username,n_passwd);
#endif
	fprintf(tempcmdfile,"cd %s\n",n_pathname);
	fprintf(tempcmdfile,"bin\n");
	fprintf(tempcmdfile,"del %s/%s\n", localpath, n_cifilename) ;
	fprintf(tempcmdfile,"bye\n");
	fclose(tempcmdfile);
#ifdef PCTCP
	sprintf(doscommand, "command /c ftp %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
#ifdef PCNFS
	sprintf(doscommand, "command /c ftp -n %s < %s > %s", interaddr, tempcmdfilename, tempsendfilename);
#endif
	_CLI_str("FTPDEL: dos command=<%s>",doscommand);
	status = system(doscommand);
	_CLI_str("FTPDEL: dos command status=<%d>",status);
	if ( status == 0)
	{
		/* System call succesful */
		_CLI_str("%s","FTPDEL: dos command successful");
		if ( NFMscan_ftp_output(tempsendfilename) != NFM_S_SUCCESS )
		{
			return(NFM_E_FAILURE);
		}
		else
		{
			return(NFM_S_SUCCESS);
		}
	}
	else
	{
		_CLI_str("%s","FTPDEL: dos command failed");
		return(NFM_E_FAILURE);
	}
}
