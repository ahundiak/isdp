#include	<string.h>
#include 	<stdio.h>
#include 	<errno.h>
#include 	<sys/types.h>
#include        <sys/stat.h>
#include 	<dirent.h>
#include	<ctype.h>
#include	<pwd.h>

#define PDM_S_SUCCESS 0

char            PDMCWD[100];
char            ENV_FILE_NAME[100];
extern          int debug_on;
char		admin_path[50];

/***************************************************************************

 MODIFICATION : SSRS 12 Jan 94

       a) The server and environments are being written to different files
          NFMser.dat and NFMenv.dat instead of a single file NFMenv.dat.

       b) The owned environments are being written to NFMowne.dat which 
          was not there earlier.

***************************************************************************/
/****************************************************************************
Name
   nfmClhToTcpConvertor

Abstract
   A converter  written to go through all the nfms_xxxx, and nfme_xxx
   files and create the NFMenv.dat.

Synopsis
  int pdmClhToTcpConvertor ( )

Description
   Input:
     None
   Input/Output:
    NFMenv.bat file
   Output:
    NFMenv.bat
   Algorithm:
   1) Open the directory /usr/lib/nodes/heard directory.
   2) Get the files starting with nfms_
   2) Sort the file alphabatically.
   3) Open each file
       1. Read the information from the file.
       2. Put the information in the NFMenv.bat file
   4) Open the directory /usr/lib/nodes/heard directory.
   5) Get the files starting with nfme_
   6) Sort the file alphabatically.
   7) Open each file
       1. Read the information from the file.
       2. Put the information in the NFMenv.bat file



Return Values

Notes
NFMenv.dat FILE FORMAT
-----------------------

The NFMenv.dat file holds the information regarding servers and environment.

The file has following rules

1. # in the first column indicates a comment.

2. ( \001) is used as a separator.

3. Newline starts a new set of data.

4. ::  indicates end of a set of data.

5. The first set of data includes

#Name of the server, node on which the server will run.

servernamenodename

6. The second set of data includes

#Name of the environment, Application Name (e.g. PDM, NFM ... ),
#Node information where the schema file resides, encrypted schema name,
#encrypted schema password, encrypted username, and encrypted user_password

environmentnameAppl_NAMEnodenameschema_nameschema_passwordusernameuser_password

7. The protocol information is NOT stored. The default protocol will be TCP/IP.
   The protocol information may be obtained using "gethostbyname" type of calls.

Example file

========================================================+++====================
#This is a consolidated data file for I/NFM.
#
#
#
#Name of the server, node on which the server will run.
nfms_kumarnana
nfms_newpdmdel
nfms_xyzw120
nfms_goodb30
nfms_badb12
::
#Name of the environment, Application Name (e.g. PDM, NFM ... ),
#Node information where the schema file resides, encrypted schema name,
#encrypted schema password, encrypted username, and encrypted user_password
nfme_goodb30T3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DNFM
nfme_badb15T3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DPDM
nfme_gooddatamgmtT3Arv_1_q{p-I9tX[h:>Zr;--B"d\STe(8UWb>%zY~!CK`^Pd*:f3'vdb}z14P;?$}]85o_=:"45v$H\9Coz%T2<Dm2jYiz3U(6DNFM
::
================================================================================
Index

Keywords

History
   Kumar Narayanan Fri Mar 19 11:44:59 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int 
nfmClhToTcpConvertor()
{
	char            filename[7];
	char          **env_files = NULL, **server_files = NULL;
        char          **ownenv_files = NULL;
	long             status = PDM_S_SUCCESS;
	int             fcount = -1, envcount = -1, ser_total, env_total, ownenvcount = -1;
	DIR            *infile;
	struct dirent  *dirp;
	char           *fname = "pdmClhToTcpConvertor";
        long           pdmConvertEnvInfo();
        long           pdmConvertServerInfo();
        long           pdmConvertOwnEnvInfo();
	struct passwd  *pwd;

	printf("%s : Converting /usr/lib/nodes/heard/nfme_xxxx to NFMenv.dat file\n", fname);
	printf("%s : Converting /usr/lib/nodes/heard/nfms_xxxx to NFMser.dat file\n", fname);
	printf("%s : Converting /usr/lib/nodes/owned/nfme_xxxx to NFMowne.dat file\n", fname);

        pwd = getpwnam( "nfmadmin" );
	admin_path[0] = 0;
	sprintf( admin_path, "%s/%s", pwd->pw_dir, "clh_info");
	mkdir( admin_path, 00000775 );

	if (debug_on)
		_PDMdebug(fname, " Enter\n");


	status = (long) vfork();
	if (status == 0) {
		freopen("/dev/null", "w", stdout);
		freopen("/usr/tmp/PDMhconv.err", "w", stderr);

		status = (long) execl("/usr/lib/hconv", "/usr/lib/hconv",
				      "-E",
				      (char *) 0);
		if (status == -1) {
			_PDMdebug(fname, "execl failed %d\n", errno);
			exit(0);
		}
	}
	if (status == -1) {
		_PDMdebug(fname, "vfork failed %d\n", errno);
		return (status);
	} else
		_PDMdebug(fname, "Parent process\n");

	strcpy(filename, "nfms_");
	if ((infile = opendir("/usr/lib/nodes/heard")) == NULL){
		printf("error opening /usr/lib/nodes/heard directory \n");
		exit(-1); /* PS */
	}
	else {
		while ((dirp = readdir(infile)) != NULL) {
			if ((strncmp(dirp->d_name, "nfms_", 5)) == 0) {
				++fcount;
				if (server_files != NULL)
					server_files = (char **) realloc(server_files, ((fcount + 1) * sizeof(char *)));
				else
					server_files = (char **) malloc((fcount + 1) * sizeof(char *));
				server_files[fcount] = (char *) malloc(20 * sizeof(char));
				strcpy(server_files[fcount], dirp->d_name);
			} else if ((strncmp(dirp->d_name, "nfme_", 5)) == 0) {
				++envcount;
				if (env_files != NULL)
					env_files = (char **) realloc(env_files, ((envcount + 1) * sizeof(char *)));
				else
					env_files = (char **) malloc((envcount + 1) * sizeof(char *));
				env_files[envcount] = (char *) malloc(20 * sizeof(char));
				strcpy(env_files[envcount], dirp->d_name);
			}
		}
	}
	status = pdmShellSort((fcount + 1), server_files);
	if (status == PDM_S_SUCCESS) {
		status = pdmConvertServerInfo(server_files, (fcount + 1));
		if (status != PDM_S_SUCCESS) {
			_PDMdebug(fname, "pdmConvertServerInfo failed status %d\n", status);
			return (status);
		}
		ser_total = fcount + 1;
		_PDMdebug(fname, "server total = %d  fcount = %d", ser_total, fcount);
	} else {
		_PDMdebug(fname, "pdmShellSort failed status %d\n", status);
		return (status);
	}
	status = pdmShellSort((envcount + 1), env_files);
	if (status == PDM_S_SUCCESS) {
		status = pdmConvertEnvInfo(env_files, (envcount + 1));
		if (status != PDM_S_SUCCESS) {
			_PDMdebug(fname, "pdmConvertEnv failed status %d\n", status);
			return (status);
		}
		env_total = envcount + 1;
		_PDMdebug(fname, "env total = %d  fcount = %d", env_total, envcount);
	} else {
		_PDMdebug(fname, "pdmShellSort failed status %d\n", status);
		return (status);
	}
	if (infile) /* PS */
		closedir(infile);

	if ((infile = opendir("/usr/lib/nodes/owned")) == NULL) {
		printf("error opening /usr/lib/nodes/owned directory \n");
		exit(-1); /* PS */
	}
	else {
		while ((dirp = readdir(infile)) != NULL) {
			if ((strncmp(dirp->d_name, "nfme_", 5)) == 0) {
				++ownenvcount;
				if (ownenv_files != NULL)
					ownenv_files = (char **) realloc(ownenv_files, ((ownenvcount + 1) * sizeof(char *)));
				else
					ownenv_files = (char **) malloc((ownenvcount + 1) * sizeof(char *));
				ownenv_files[ownenvcount] = (char *) malloc(20 * sizeof(char));
				strcpy(ownenv_files[ownenvcount], dirp->d_name);
			}
		}
	}
	status = pdmShellSort((ownenvcount + 1), ownenv_files);
	if (status == PDM_S_SUCCESS) {
		status = pdmConvertOwnEnvInfo(ownenv_files, (ownenvcount + 1));
		if (status != PDM_S_SUCCESS) {
			_PDMdebug(fname, "pdmConvertOwnEnvInfo failed status %d\n", status);
			return (status);
		}
		env_total = ownenvcount + 1;
		_PDMdebug(fname, "env total = %d  ownenvcount = %d", env_total, ownenvcount);
	} else {
		_PDMdebug(fname, "pdmShellSort failed status %d\n", status);
		return (status);
	}
	if (infile) /* PS */
		closedir(infile);

	return (PDM_S_SUCCESS);
}


long 
pdmConvertEnvInfo(char **env_files, int count)
{
	static char    *fname = "pdmConvertEnvInfo";
	long            status = PDM_S_SUCCESS;
	int             i = 0;
	char           *cwd, *s_ptr;
	char           *token = NULL, *token1 = NULL;
        char           *token2 = NULL, *token3 = NULL, *token4 = NULL;
	char           env_file[20], schemaname[40], schemapasswd[40]= "";
	char        application[10], nodename[20]= "", username[40], userpasswd[40];
	FILE           *fopen(), *owned_file, *fp;
	char            str[200], string[257];

	_PDMdebug(fname, "Enter\n");
	cwd = (char *) NULL;
	cwd = (char *) getcwd((char *) NULL, 98);
	if (!cwd) {
		_PDMdebug(fname, "Get CWD Failed : errno = <%d>\n", errno);
		return (-2);
	} else
		strcpy(PDMCWD, cwd);
	sprintf(ENV_FILE_NAME, "%s/%s", admin_path, "NFMenv.dat");
	if ((owned_file = fopen(ENV_FILE_NAME, "a")) == NULL) {
		_PDMdebug(fname, "Could not open NFMenv.dat failed\n");
		_PDMdebug(fname, "Open error no %d\n", errno);
		printf("Could not NFMenv.dat file\n");
		return (status);
	}
	status = (long) chmod(ENV_FILE_NAME, 00000666);
	if (status == -1) {
		_PDMdebug(fname, "Chmod file NFMenv.dat failed\n");
		_PDMdebug(fname, "Chmod error no %d\n", errno);
		printf("Chmod file on NFMenv.dat failed\n");
		return (status);
	}
	status = (long) chown(ENV_FILE_NAME, (int) getuid(), (int) getgid());
	if (status == -1) {
		_PDMdebug(fname, "chown %s failed", ENV_FILE_NAME);
		_PDMdebug(fname, "chown error no %d\n", errno);
		return (status);
	}
        str[0] = '\0';
	sprintf(str,"%s\n", "#  ");
	fprintf(owned_file,"%s", str);
        str[0] = '\0';
	sprintf(str,"%s\n", "#  List of NFM/PDM environments");
	fprintf(owned_file,"%s", str);
        str[0] = '\0';
	sprintf(str,"%s\n", "#  ");
	fprintf(owned_file, "%s", str);
        str[0] = '\0';
	/*sprintf(str,"%s\n", "::");*/
	fprintf(owned_file, "%s", str);

	for (i = 0; i < count; i++) {
		string[0] = '\0';
		env_file[0] = '\0';
		if (env_files[i])
			sprintf(env_file,"%s/%s","/usr/lib/nodes/heard", env_files[i]);

		if (!strncmp(env_files[i], "pdm", 3))
			strcpy(application, "PDM");
		else
			strcpy(application, "NFM");

		if ((fp = fopen(env_file, "r")) == (FILE *) NULL) {
			printf("Cannot open file <%s>: errno <%d>\n", env_file, errno);
			_PDMdebug(fname, "Cannot open file <%s> : errno <%d>\n", env_file, errno);
			if (fp)
				fclose(fp);
			continue;
		}
                strcpy(nodename,"");
                strcpy(username,"");
                strcpy(userpasswd,"");
                strcpy(schemaname,"");
                strcpy(schemapasswd,"");
		while ((s_ptr = fgets(string, 256, fp)) != (char *) NULL) {
			if (string[0] == '#')
				continue;
			else if (!strncmp(string, "Owner", 5))
				continue;
			else if (!strncmp(string, "Address", 7))
				continue;
			else if (!strncmp(string, "tcp_address", 11))
				continue;
			else if (!strncmp(string, "NETPROP16", 9))
				continue;
			else if (!strncmp(string, "Nodename", 8)) {
				token = (char *) strchr(string, ':');
				if (token == (char *) NULL)
					strcpy(nodename, env_file);
				else
                 {
                  memset(nodename, '\0', 20);
          strncpy(nodename, (token +2), (strlen(token+2)-1));
                 }
			} else if (!strncmp(string, "NETPROP17", 9)) {
				token1 = (char *) strchr(string, ':');
				if (token1 == (char *) NULL)
					strcpy(username, "nfmadmin");
				else
                  {
                  memset(username, '\0', 25);
          strncpy(username, (token1 +2), (strlen(token1+2)-1));
                  }
			} else if (!strncmp(string, "NETPROP18", 9)) {
				token2 = (char *) strchr(string, ':');
				if (token2 == (char *) NULL)
					strcpy(userpasswd, "");
				else
                 {
                  memset(userpasswd, '\0', 40);
          strncpy(userpasswd, (token2 +2), (strlen(token2+2) -1 ));
                 }
			} else if (!strncmp(string, "NETPROP20", 9)) {
				token3 = strchr(string, ':');
				if (token3 == (char *) NULL)
					strcpy(schemaname, "");
				else
                                {
                  memset(schemaname, '\0', 25);
          strncpy(schemaname, (token3 +2), (strlen(token3+2)-1 ));
                                 }
			} else if (!strncmp(string, "NETPROP21", 9)) {
				token4 = strchr(string, ':');
				if (token4 == (char *) NULL)
					strcpy(schemapasswd, "");
				else
                                {
                  memset(schemapasswd, '\0', 25);
          strncpy(schemapasswd, (token4 +2), (strlen(token4+2) -1));
                                 }
			} else
				continue;
		}
		str[0] = '\0';
                strcpy(str,env_files[i]);
                strcat(str,"\1");
                strcat(str,application);
                strcat(str,"\1");
                strcat(str,nodename);
                strcat(str,"\1");
                strcat(str,schemaname);
                strcat(str,"\1");
                strcat(str,schemapasswd);
                strcat(str,"\1");
                strcat(str,username);
                strcat(str,"\1");
                strcat(str,userpasswd);
                strcat(str,"\1\n");
                /*
		sprintf(str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1\n", env_files[i], application, nodename, schemaname, schemapasswd, username, userpasswd);
                */

	     token = (char *) NULL; token1 = (char *) NULL;
        token2 = (char *) NULL;  token3 = (char *) NULL; token4 = (char *)NULL;
		fprintf(owned_file, "%s", str);
		if (fp)
			status = fclose(fp);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
		fp = (FILE *) NULL;
	}
		if (owned_file)
			status = fclose(owned_file);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
	_PDMdebug(fname, "Exit\n");
        return(PDM_S_SUCCESS);
}

long 
pdmConvertServerInfo(char **server_files, int count)
{
	static char    *fname = "pdmConvertServerInfo";
	long            status = PDM_S_SUCCESS;
	int             i = 0;
	char           *cwd, *s_ptr;
	char           *token = NULL;
	char           server_file[200];
	char        application[10], nodename[20];
	FILE           *fopen(), *owned_file, *fp;
	char            str[100], string[257];

	_PDMdebug(fname, "Enter\n");
	cwd = (char *) NULL;
	/*
	cwd = (char *) getcwd((char *) NULL, 98);
	if (!cwd) {
		_PDMdebug(fname, "Get CWD Failed : errno = <%d>\n", errno);
		return (-2);
	} else
		strcpy(PDMCWD, cwd);*/

	sprintf(ENV_FILE_NAME, "%s/%s", admin_path, "NFMser.dat");
	if ((owned_file = fopen(ENV_FILE_NAME, "w")) == NULL) {
		_PDMdebug(fname, "Could not open NFMenv.dat failed\n");
		_PDMdebug(fname, "Open error no %d\n", errno);
		printf("Could not NFMenv.dat file\n");
		return (status);
	}
	status = (long) chmod(ENV_FILE_NAME, 00000666);
	if (status == -1) {
		_PDMdebug(fname, "Chmod file NFMenv.dat failed\n");
		_PDMdebug(fname, "Chmod error no %d\n", errno);
		printf("Chmod file on NFMenv.dat failed\n");
		return (status);
	}
	status = (long) chown(ENV_FILE_NAME, (int) getuid(), (int) getgid());
	if (status == -1) {
		_PDMdebug(fname, "chown %s failed", ENV_FILE_NAME);
		_PDMdebug(fname, "chown error no %d\n", errno);
		return (status);
	}
	fprintf(owned_file,"%s", "# \n");
	fprintf(owned_file, "%s","# List of NFM/PDM servers and environments\n");
	fprintf(owned_file, "%s","# \n");
	fprintf(owned_file, "%s", "# List of NFM/PDM servers \n");

	for (i = 0; i < count; i++) {
		string[0] = '\0';
		server_file[0] = '\0';
		if (server_files[i])
	sprintf(server_file,"%s/%s","/usr/lib/nodes/heard", server_files[i]);

		if (!strncmp(server_files[i], "pdm", 3))
			strcpy(application, "PDM");
		else
			strcpy(application, "NFM");

		if ((fp = fopen(server_file, "r")) == (FILE *) NULL) {
			printf("Cannot open file <%s>: errno <%d>\n", server_file, errno);
			_PDMdebug(fname, "Cannot open file <%s> : errno <%d>\n", server_file, errno);
			if (fp)
				fclose(fp);
			continue;
		}
		string[0] = '\0';
                strcpy(nodename,"");
		while ((s_ptr = fgets(string, 256, fp)) != (char *) NULL) {
			if (string[0] == '#')
				continue;
			else if (!strncmp(string, "Owner", 5))
				continue;
			else if (!strncmp(string, "Address", 7))
				continue;
			else if (!strncmp(string, "tcp_address", 11))
				continue;
			else if (!strncmp(string, "Nodename", 8)) {
				token = strchr(string, ':');
				if (token == (char *) NULL)
					strcpy(nodename, server_file);
				else
                                {
                  memset(nodename, '\0', 20);
                  strncpy(nodename, (token +2), (strlen(token+2)-1));
                                }
			} else
				continue;
		}
		str[0] = '\0';
                strcpy(str,server_files[i]);
                strcat(str,"\1");
                strcat(str,nodename);
                strcat(str,"\1");
                strcat(str,application);
                strcat(str,"\1\n");
                /*
    sprintf(str, "%s\1%s\1%s\1\n", server_files[i], nodename, application);
                */
	        token = (char *) NULL; 
		fprintf(owned_file,"%s", str);
		if (fp)
			status = fclose(fp);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
		fp = (FILE *) NULL;
	}
		if (owned_file)
			status = fclose(owned_file);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
	_PDMdebug(fname, "Exit\n");
        return(PDM_S_SUCCESS);
}
long 
pdmConvertOwnEnvInfo(char **env_files, int count)
{
	static char    *fname = "pdmConvertEnvInfo";
	long            status = PDM_S_SUCCESS;
	int             i = 0;
	char           *cwd, *s_ptr;
	char           *token = NULL, *token1 = NULL;
        char           *token2 = NULL, *token3 = NULL, *token4 = NULL;
	char           env_file[20], schemaname[40], schemapasswd[40]= "";
	char        application[10], nodename[20]= "", username[40], userpasswd[40];
	FILE           *fopen(), *owned_file, *fp;
	char            str[200], string[257];

	_PDMdebug(fname, "Enter\n");
	cwd = (char *) NULL;
	cwd = (char *) getcwd((char *) NULL, 98);
	if (!cwd) {
		_PDMdebug(fname, "Get CWD Failed : errno = <%d>\n", errno);
		return (-2);
	} else
		strcpy(PDMCWD, cwd);
	sprintf(ENV_FILE_NAME, "%s/%s", admin_path, "NFMowne.dat");
	if ((owned_file = fopen(ENV_FILE_NAME, "a")) == NULL) {
		_PDMdebug(fname, "Could not open NFMowne.dat failed\n");
		_PDMdebug(fname, "Open error no %d\n", errno);
		printf("Could not NFMowne.dat file\n");
		return (status);
	}
	status = (long) chmod(ENV_FILE_NAME, 00000666);
	if (status == -1) {
		_PDMdebug(fname, "Chmod file NFMowne.dat failed\n");
		_PDMdebug(fname, "Chmod error no %d\n", errno);
		printf("Chmod file on NFMowne.dat failed\n");
		return (status);
	}
	status = (long) chown(ENV_FILE_NAME, (int) getuid(), (int) getgid());
	if (status == -1) {
		_PDMdebug(fname, "chown %s failed", ENV_FILE_NAME);
		_PDMdebug(fname, "chown error no %d\n", errno);
		return (status);
	}
        str[0] = '\0';
	sprintf(str,"%s\n", "#  ");
	fprintf(owned_file,"%s", str);
        str[0] = '\0';
	sprintf(str,"%s\n", "#  List of NFM/PDM environments");
	fprintf(owned_file,"%s", str);
        str[0] = '\0';
	sprintf(str,"%s\n", "#  ");
	fprintf(owned_file, "%s", str);
        str[0] = '\0';
	/*sprintf(str,"%s\n", "::");*/
	fprintf(owned_file, "%s", str);

	for (i = 0; i < count; i++) {
		string[0] = '\0';
		env_file[0] = '\0';
		if (env_files[i])
			sprintf(env_file,"%s/%s","/usr/lib/nodes/heard", env_files[i]);

		if (!strncmp(env_files[i], "pdm", 3))
			strcpy(application, "PDM");
		else
			strcpy(application, "NFM");

		if ((fp = fopen(env_file, "r")) == (FILE *) NULL) {
			printf("Cannot open file <%s>: errno <%d>\n", env_file, errno);
			_PDMdebug(fname, "Cannot open file <%s> : errno <%d>\n", env_file, errno);
			if (fp)
				fclose(fp);
			continue;
		}
                strcpy(nodename,"");
                strcpy(username,"");
                strcpy(userpasswd,"");
                strcpy(schemaname,"");
                strcpy(schemapasswd,"");
		while ((s_ptr = fgets(string, 256, fp)) != (char *) NULL) {
			if (string[0] == '#')
				continue;
			else if (!strncmp(string, "Owner", 5))
				continue;
			else if (!strncmp(string, "Address", 7))
				continue;
			else if (!strncmp(string, "tcp_address", 11))
				continue;
			else if (!strncmp(string, "NETPROP16", 9))
				continue;
			else if (!strncmp(string, "Nodename", 8)) {
				token = (char *) strchr(string, ':');
				if (token == (char *) NULL)
					strcpy(nodename, env_file);
				else
                 {
                  memset(nodename, '\0', 20);
          strncpy(nodename, (token +2), (strlen(token+2)-1));
                 }
			} else if (!strncmp(string, "NETPROP17", 9)) {
				token1 = (char *) strchr(string, ':');
				if (token1 == (char *) NULL)
					strcpy(username, "nfmadmin");
				else
                  {
                  memset(username, '\0', 25);
          strncpy(username, (token1 +2), (strlen(token1+2)-1));
                  }
			} else if (!strncmp(string, "NETPROP18", 9)) {
				token2 = (char *) strchr(string, ':');
				if (token2 == (char *) NULL)
					strcpy(userpasswd, "");
				else
                 {
                  memset(userpasswd, '\0', 40);
          strncpy(userpasswd, (token2 +2), (strlen(token2+2) -1 ));
                 }
			} else if (!strncmp(string, "NETPROP20", 9)) {
				token3 = strchr(string, ':');
				if (token3 == (char *) NULL)
					strcpy(schemaname, "");
				else
                                {
                  memset(schemaname, '\0', 25);
          strncpy(schemaname, (token3 +2), (strlen(token3+2)-1 ));
                                 }
			} else if (!strncmp(string, "NETPROP21", 9)) {
				token4 = strchr(string, ':');
				if (token4 == (char *) NULL)
					strcpy(schemapasswd, "");
				else
                                {
                  memset(schemapasswd, '\0', 25);
          strncpy(schemapasswd, (token4 +2), (strlen(token4+2) -1));
                                 }
			} else
				continue;
		}
		str[0] = '\0';
                strcpy(str,env_files[i]);
                strcat(str,"\1");
                strcat(str,application);
                strcat(str,"\1");
                strcat(str,nodename);
                strcat(str,"\1");
                strcat(str,schemaname);
                strcat(str,"\1");
                strcat(str,schemapasswd);
                strcat(str,"\1");
                strcat(str,username);
                strcat(str,"\1");
                strcat(str,userpasswd);
                strcat(str,"\1\n");
                /*
		sprintf(str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1\n", env_files[i], application, nodename, schemaname, schemapasswd, username, userpasswd);
                */

	     token = (char *) NULL; token1 = (char *) NULL;
        token2 = (char *) NULL;  token3 = (char *) NULL; token4 = (char *)NULL;
		fprintf(owned_file, "%s", str);
		if (fp)
			status = fclose(fp);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
		fp = (FILE *) NULL;
	}
		if (owned_file)
			status = fclose(owned_file);
		if (status)
			_PDMdebug(fname, "fclose : errno  = <%d>\n", errno);
	_PDMdebug(fname, "Exit\n");
        return(PDM_S_SUCCESS);
}
