#include  <stdio.h>
#include  <stdlib.h>
#include  <ctype.h>
#include  <string.h>
#include  <io.h>
#include  "NFMerrordef.h"
#include  "ERR.h"
/* #include "NFMdebug.h" */
#include "CLIstruct.h"
#include "proto.h"
#include <memcheck.h>

/*main()
{
	long status;

	char	ss[12];

	status = NFMscan_ftp_output("/usr/tmp/NFMsend2");
	if(status == NFM_S_SUCCESS)
	{
		printf("NO FTP ERROR\n");
	}
	else if(status == NFM_E_FAILURE)
	{
		printf("FTP ERROR\n");
	}
}
*/

long NFMcount_ftp_output(out_file,rfilesize)
	char *out_file;
	long *rfilesize;
{
	char *fname="NFMcount_ftp_output";
	FILE	*fopen(), *out_fptr;
	long	status;
	char	ss[1024], sx[40],*sx2;
	long	i;

	_CLI_str("FTPCount: out_file = <%s>", out_file);

	out_fptr = fopen(out_file,"r");
	if(!out_fptr)
	{
		status = NFM_E_OPEN_FILENAME;
		_CLI_str("%s","FTPCount: File Open failed");
		return(status);
	}
	while(fgets(ss,1024,out_fptr))
	{
		_CLI_str("FTPCount: ss -> %s",ss);
		for(i=0;i<11;i++)
		{
			sx[i] = ss[i];
		}
		sx[11] = '\0';
		_CLI_str("FTPCount: sx -> <%s>",sx);
		if(!strcmp(sx,"Transferred"))
		{
			fclose(out_fptr);
			sx2=strtok(ss," ");
			_CLI_str("FTPCount: sx2 -> %s",sx2);
			sx2=strtok(NULL," ");
			_CLI_str("FTPCount: Transferred <%s> bytes",sx2);
			*rfilesize=atol(sx2);
			_CLI_str("FTPCount: Transferred <%ld> bytes",*rfilesize);
			return(NFM_S_SUCCESS);
		}
	}
	fclose(out_fptr);
	_CLI_str("%s","FTPCount: Failure");
	return(NFM_E_FAILURE);
}

long NFMscan_ftp_output(out_file)
/* KT - 5/20/91 Added to avoid Apogee error (how did this work without this?)
*/
	char *out_file;

{
	char *fname="NFMscan_ftp_output";
	FILE	*fopen(), *out_fptr;
	long	status;
	char	ss[1024], err_code[32], sx[40];
	long	err_no, entry_found;
	long	i;
	short	k;

	_CLI_str("FTPScan: out_file = <%s>", out_file);

	out_fptr = fopen(out_file,"r");
	if(!out_fptr)
	{
		status = NFM_E_OPEN_FILENAME;
		_CLI_str("%s","FTPScan: File Open failed");
		return(status);
	}
	while(fgets(ss,1024,out_fptr))
	{
		entry_found = 0;
		_CLI_str("FTPScan: ss -> %s",ss);
		for(i=0;i<14;i++)
		{
			sx[i] = ss[i];
		}
		sx[14] = '\0';
		_CLI_str("FTPScan: sx -> %s",sx);
		if(!strcmp(sx,"Not connected."))
		{
			fclose(out_fptr);
			_CLI_str("%s","FTPScan: ftp not connected");
			return(NFM_E_FAILURE);
		}
		if(isdigit(ss[0]) && isdigit(ss[1]) && isdigit(ss[2]))
		{
   		  	k = 2;
		  	for(i=3;i<((long)strlen(ss));i++)
		  	{
  				if(isdigit(ss[i]))
				{
		 			k = k + 1;
				}
				else
				{
					break;
				}
		  	}
		  	sx[0] = ss[k+2]; sx[1] = ss[k+3]; 
		  	sx[2] = ss[k+4]; sx[3] = ss[k+5]; 
		  	sx[4] = ss[k+6];
		  	sx[5] = '\0';
		  	if(strncmp(sx,"bytes",5))
		  	{
			 	entry_found = 1;
		  	}
		  	if(entry_found)
		  	{
				err_code[0] = 0;
				strncpy(err_code,ss,k+1);
				err_code[k+1] = '\0' ;
				err_no = atoi(err_code);
				if(err_no >= 350)
				{
					fclose(out_fptr);
					_CLI_str("FTPScan: Found ftp error <%d>",err_no);
					return(NFM_E_FAILURE);
				}
				else if(err_no == 230)
				{
					k = strlen(ss) - 1;
					for(i=0;i<10;i++)
					{
						sx[i] = ss[k-10+i]; 
					}
		  			sx[10] = '\0';
					_CLI_str("FTPScan: sx <%s>",sx);
 					if(!strcmp(sx, "(ReadOnly)")) 
					{
						fclose(out_fptr);
						_CLI_str("FTPScan: ReadOnly error <%d>",err_no);
						return(NFM_E_FAILURE);
					}
				}
		   	}
		}
	}
	fclose(out_fptr);
	_CLI_str("%s","FTPScan: Success");
	return(NFM_S_SUCCESS);
}

long NFMscan_ftp_output1(out_file)
/* KT - 5/20/91 Added to avoid Apogee error (how did this work without this?)
*/
	char *out_file;

{
	char *fname="NFMscan_ftp_output1";
	FILE	*fopen(), *out_fptr;
	long	status;
	char	ss[1024], err_code[32], sx[40];
	long	err_no, entry_found;
	long	i;
	short	k;

/*
	_NFMdebug((fname,"SCAN FTP1 : out_file = <%s>\n ",out_file));
*/

	out_fptr = fopen(out_file,"r");
	if(!out_fptr)
	{
		status = NFM_E_OPEN_FILENAME;
/*
		_NFMdebug((fname," Open File : status = <0x%.8lx>\n",status));
				ERRload_struct (NFM, status, "%s", out_file);
*/
		return(status);
	}
	while(fgets(ss,1024,out_fptr))
	{
/*
_NFMdebug((fname," ss -> %s\n",ss));
*/
		entry_found = 0;
		for(i=0;i<14;i++)
		sx[i] = ss[i];
			sx[14] = '\0';
/*
_NFMdebug((fname," sx -> %s\n",sx));
*/
		if(!strcmp(sx,"Not connected."))
		{
		fclose(out_fptr);
/*
		_NFMdebug((fname,"SCAN FTP1 : ftp Not Connected \n"));
				ERRload_struct (NFM, NFM_E_FAILURE, "%s", "Not Connected");
*/
		return(NFM_E_FAILURE);
		}
		if(isdigit(ss[0]) && isdigit(ss[1]) && isdigit(ss[2]))
		{
   		  k = 2;
		  for(i=3;i<((short)strlen(ss));i++)
		  {
  			if(isdigit(ss[i]))
			{
		 	   k = k + 1;
			}
			else
			{
				break;
			}
		  }
		  sx[0] = ss[k+2]; sx[1] = ss[k+3]; 
		  sx[2] = ss[k+4]; sx[3] = ss[k+5]; 
		  sx[4] = ss[k+6];
		  sx[5] = '\0';
		  if(strncmp(sx,"bytes",5))
		  {
			 entry_found = 1;
		  }
		  if(entry_found)
		  {
			err_code[0] = 0;
			strncpy(err_code,ss,k+1);
		err_code[k+1] = '\0' ;
			err_no = atoi(err_code);
			if(err_no >= 350)
		{
			fclose(out_fptr);
/*
			_NFMdebug((fname,"SCAN FTP1 : Found ftp error  <%d>\n",err_no));
						ERRload_struct (NFM, NFM_E_FAILURE, "%s", "ftp Error");
*/
			return(NFM_E_FAILURE);
				}

/*
			switch(err_no)
	 		{
				case 550:
					fclose(out_fptr);
					_NFMdebug((fname,"SCAN FTP: Found ftp error:<%d>\n", err_no));
					return(NFM_E_FAILURE);
					break;
		
	 			default:
					break;
			 }
*/
		   }
		}
	}
	fclose(out_fptr);
/*
	_NFMdebug((fname,"SUCCESS  <0x%.8lx>\n",NFM_S_SUCCESS));
*/
	return(NFM_S_SUCCESS);
}

