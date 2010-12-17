#include "machine.h"
/************************************************************************
*									*
*				NFM Daemon				*
*									*
*	The NFM daemon listens on a particular port for connection	*
*	requests from NFM client or NFM server ( for connecting to a	*
*	file server) or NFM file server ( formerly known as listener)	*
*									*
*	An NFM client will request an NFM server connection.		*
*	The NFM server and file server will request a NFM file server 	*
*	connection.							*
*									*
*	The message header will contain the information to spawn the	*
*	appropriate process						*
*									*
************************************************************************/

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <pwd.h>

#include "net.h"

#include "NFMerrordef.h"
#include "NETtlidef.h"

/* KMM. 09 Dec 93. NFMporttypes.h contains macros for OS dependent  */
/* typedefs */
#include "NFMporttypes.h"

#define MSG_SIZE        128
#define MAXLINE         1024
#define PRODUCTS "/usr/ip32/nfm/config/products"



/* Error file pointer and client_id */
extern FILE *net_err ;
extern int net_client_id ;


/* Static Variables */
static FILE *nfmd_err,*nfmd_config ;
/* Intel/Solaris Port - CN 16 May 95 */
#if defined( OS_SCO_UNIX) || defined(OS_HPUX) || defined(OS_INTELSOL)
static char *nfmd_errfile="/tmp/console" ;
#else
static char *nfmd_errfile="/dev/console" ;
#endif
static char *nfmd_configfile="/etc/nfmd.conf" ;

static int Oargc ;
static char **Oargv;


main(argc,argv)
	int argc;
	char **argv;

{
	char err_msg[MSG_SIZE] ;
	extern int process_com();
	long status ;

/* set argc and argv */
	Oargc = argc;
	Oargv = argv;
/* Open the error message file */
	net_err = fopen(nfmd_errfile , "a" );
	if(net_err == (FILE *)0)
	{
		sprintf(err_msg, "echo fopen failed for file %s. %s Exiting ... > /dev/console",nfmd_errfile,argv[0]);
		system(err_msg) ;
		exit(1) ;
	}
	nfmd_err = net_err ;
	
/* If we were not started in background we need to fork and exit the
   parent in order to release the controlling script 
   As of now assume daemon is started in background */ 

/* 12/16/92 - KT - SUN Port. Only do this for UNIX */
#ifdef OS_CLIX
/* setpgrp to become group leader after a fork in the child process */

	status = setpgrp();
	if(status < 0 )
	{
		fprintf(net_err , "%s:<<<SEVERE ERROR>>>setpgrp failed\
 :errno <%d>\n",argv[0],errno ) ;
		exit(1);	
	}
#endif

/* change directory to root to make sure we are not on a mounted filesystem */
	status = chdir("/");
	if(status < 0 )
	{
		fprintf(net_err , "%s:<<<SEVERE ERROR>>>chdir to </> failed\
 :errno <%d>\n",argv[0],errno ) ;
		exit(1);	
	}
/* clear any inherited file mode creation mask */  
	umask(0);
/* Ensure all processes ignore death of parent */
signal( SIGHUP, SIG_IGN );

/* Ignore zombie processes */
signal( SIGCLD, SIG_IGN );

/* initialize shared memory segment */
	if((status = NETattach_shm()) != NET_S_SHM_SUCCESS)
	{
		fprintf(net_err , "%s:<<<SEVERE ERROR>>>Attach shared memory\
 segment failed. status <0x%.8x> errno <%d>\n",argv[0],status,errno ) ;
		exit(2);
	}
	NETinit_shm() ;

/* Load products file with info */

status = NFMload_product_info();

/* Become a server */
status = net_server(XNS_SOCK , TCP_PORT );
	switch(status)
	{
		case 1: /* Only one socket got bound */
		fprintf(net_err , "%s:<<<<WARNING>>>>  listening either on tcp\
 port <%d> or xns socket <%s> only\n",argv[0],TCP_PORT, XNS_SOCK ) ;
		break;
		case 2: /* Both sockets got bound */
		break;
		default:
		fprintf(net_err , "%s:<<<SEVERE ERROR>>> Failed to bind tcp\
 port <%d> and xns socket <%s> \n",argv[0],TCP_PORT, XNS_SOCK ) ;
		exit(3);
	}

/* Poll for incoming connections */
net_poll( process_com);

/* net_poll returns if error occurs during polling */
fprintf(net_err ,"%s:<<<SEVERE ERROR>>>net_poll returned t_errno = <%d> errno = <%d>\n",argv[0],t_errno , errno);
/*
net_server_stop() ;
*/
exit(4);
} /* End of nfmd function main */
	

int process_com ( fd , address )
	int fd ;
	char *address ;
{
	long status ;
	char *path , **ARGV,*username ;
	long pid = -1,fd2 ;
	struct passwd *pwent;
	struct stat fbuff;

/* 12/17/92 - KT - SUN Port */

/* HP PORT - IGI - 10 Jun 94 */ 
/* Intel/Solaris Port - CN 16 May 95 */
#if (defined(OS_SUNOS)||(defined(OS_SOLARIS) && !defined(OS_INTELSOL))||defined(OS_HPUX))
        long swapbytes ();
#endif
	
	address = address ;
/* Setpgrp so as to detach from the parents pgrp */
/* KT - 1/5/92 - UNIX: call setpgrp */
#ifdef OS_CLIX
	if((status = setpgrp()) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to setpgrp: <%d>\n",Oargv[0],errno);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
#endif

/* KT - 1/5/92 - SUN: call setsid */

/* HP PORT - IGI - 10 Jun 94 */ 

#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX) )
	if((status = setsid()) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to setsid: <%d>\n",Oargv[0],errno);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
#endif
	
/* Get the process id  */

	if((pid = (NFM_PID_T) getpid()) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to get process id pid = <%d>\
 errno = <%d>\n",Oargv[0],pid,errno);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}

/* 12/16/92 - KT - SUN Port - If SUN, swap the incoming serverid bytes */
/* IntelPort - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))||defined(OS_HPUX))
  net_client_id = swapbytes (net_client_id);
#endif

	if((status = NFMget_params (net_client_id, &path , &ARGV,&username )) != NFM_S_SUCCESS)
	{
		fprintf(net_err , "%s:<ERROR> Failed to get path and argv for server number <%d> error <0x%.8x>\n",Oargv[0],net_client_id,status);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}	

	fprintf(net_err , "client_id = %d  path = %s\n",net_client_id,path);
/* Get uid , gid of the username */
	if((pwent= getpwnam(username))== (struct passwd *)0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to get pwentry for username <%s> errno <%d>\n",Oargv[0],username,errno);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
/* Set uid for the user to be process_id */
	if((status = setgid(pwent->pw_gid)) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to setgid to <%d>  errno <%d> username <%s>\n",Oargv[0],pwent->pw_gid,errno,username);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
	if((status = setuid(pwent->pw_uid)) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to setuid to <%d> errno <%d> username <%s>\n",Oargv[0],pwent->pw_uid,errno,username);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
	if((status = chdir(pwent->pw_dir)) < 0)
	{
		fprintf(net_err , "%s:<ERROR> Failed to chdir to <%s> errno <%d>\n",Oargv[0],pwent->pw_dir,errno);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}

/* 12/16/92 - KT - SUN Port - changed 'Stat' to 'stat' */
	status = stat(path,&fbuff);
	if(status)
	{
		fprintf(net_err,"%s:<ERROR> Executable file <%s> does not exist for server_id errno <%d> \n",Oargv[0],path,net_client_id);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}

	if((status = NETinsert_shm(pid,fd)) != NET_S_SHM_SUCCESS)
	{
		fprintf(net_err , "%s:<ERROR>Failed to insert into shm pid = <%d> fd = <%d> status = <0x%.8x>\n",Oargv[0],pid,fd,status); 
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
	for(fd2=0 ; fd2 < _NFILE; fd2++)
		if(fd2!=fd) close (fd2) ;
	errno = 0;
  /* Reset signal trapping for child process */
	signal( SIGCLD, SIG_DFL );

	if((status = execv(path,ARGV)) < 0)
	{
		fprintf(net_err,"%s:<ERROR> execv failed errno <%d> for process <%s>\n",Oargv[0],errno,path);
		NETget_fd_from_shm(pid , &fd2);
		net_reject(fd);
		net_stop(fd);
		exit(1);
	}
		
	fprintf(net_err,"%s:<ERROR>Failed to start server type <%d> \n",Oargv[0],net_client_id);
	net_reject(fd);
	net_stop(fd);
	exit(6) ;
	return(-1);
}

int NFMget_params( type, path , ARGV,username)
	long type ;
	char **path , ***ARGV,**username ;
{
	char *linep , line[MAXLINE],saveline[MAXLINE] ,saveline2[MAXLINE];
	long i=0,flag = 0,length = 0,argc = 0,server_num= -1 ;
	char **argv = NULL,*Next_entry() ;
	
	flag = server_num= 0;
	nfmd_config = fopen ( nfmd_configfile , "r");
	if(nfmd_config == (FILE *)0)
	{
		fprintf(net_err , "%s:<ERROR> Cannot open file <%s>\n",Oargv[0],nfmd_configfile);
		return(NFM_E_NO_CONFIG_FILE);
	}
	while(!flag && (linep = Next_entry ( line , MAXLINE , nfmd_config))!= (char *)0)
	{
		strcpy(saveline2,line);
		linep = strtok ( line ,"!") ;
		if(linep == (char *)0)
		{
			fprintf(net_err,"%s:<ERROR> Bad Entry <%s> in  \
Config file <%s>\nNO SERVER NUMBER\n",Oargv[0],saveline2,nfmd_configfile);
			return(NFM_E_BAD_CONFIG_ENTRY);	
		}
		server_num= atol(linep);
		if(server_num == type) flag = 1;
		if(flag)
		{
			linep = strtok ( 0 ,"!") ;
			if(linep == (char *)0)
			{
				fprintf(net_err,"%s:<ERROR> Bad Entry <%s> in\
 Config file <%s>\nNO USERNAME SPECIFIED\n",Oargv[0],saveline2,nfmd_configfile);
				return(NFM_E_BAD_CONFIG_ENTRY);	
			}
			length = strlen (linep) ;
			*username = (char *) malloc	( length + 1);
			if(*username == (char *)0)
			{
				fprintf(net_err,"%s:<<<SEVERE ERROR>>> Malloc\
 Failed for size <%d>\n",Oargv[0],length+1);
				return(NFM_E_MALLOC_ERROR);	
			}
			strcpy(*username , linep);
			linep = strtok ( 0 ,"!") ;
			if(linep == (char *)0)
			{
				fprintf(net_err,"%s:<ERROR> Bad Entry <%s> in\
 Config file <%s>\nNO SERVER PATH SPECIFIED\n",Oargv[0],saveline2,nfmd_configfile);
				return(NFM_E_BAD_CONFIG_ENTRY);	
			}
			length = strlen (linep) ;
			if ( length <= 0 )
			{
				fprintf(net_err,"%s:<ERROR> Bad Entry <%s> in\
 Config file <%s>\nNO SERVER PATH SPECIFIED\n",Oargv[0],saveline2,nfmd_configfile);
				return(NFM_E_NO_SERVER_PATH ) ;
			}
			strcpy(saveline,linep);
			strcpy(line,linep);
			linep =strtok ( line , " " );
			argc=0;
			while(linep != (char *) 0)
			{
				argc++;
				linep = strtok ( 0 , " ");
			}
    			if ((argv = (char **) malloc ((argc + 1) * sizeof (char *))) == NULL)
			{
				fprintf(net_err,"%s:<<<SEVERE ERROR>>> Malloc\
 Failed for size <%d>\n",Oargv[0],length+1);
				return(NFM_E_MALLOC_ERROR);	
			}
			linep = strtok(saveline , " ");
			length = strlen(linep);
			*path = (char *) malloc	( length + 1);
			if(*path == (char *)0)
			{
				fprintf(net_err,"%s:<<<SEVERE ERROR>>> Malloc\
 Failed for size <%d>\n",Oargv[0],length+1);
				return(NFM_E_MALLOC_ERROR);	
			}
			strcpy(*path , linep);
			i=0;
			while(linep != (char *)0)
			{
				length = strlen(linep);
				argv[i] = (char *) malloc	( length + 1);
				if(argv[i] == (char *)0)
			{
				fprintf(net_err,"%s:<<<SEVERE ERROR>>> Malloc\
 Failed for size <%d>\n",Oargv[0],length+1);
				return(NFM_E_MALLOC_ERROR);	
			}
				strcpy(argv[i] , linep) ;
				linep = strtok(0," " );
				i++;
			}
			*ARGV = argv ;
				
			
		}
	}
	if ( !flag)
	{
		fprintf(net_err,"%s:<ERROR> The config file <%s> has no entry \
for server id <%d>\n",Oargv[0],nfmd_configfile,type);
		 return(NFM_E_NO_SERVER_ENTRY) ;
	}
	return(NFM_S_SUCCESS);
}

char * Next_entry(line,max_num , fp)
	char *line ;
	long max_num ;
	FILE *fp ;
{
	char line2[MAXLINE], *linep ;
	int flag,last,length,last2 ;
	flag=last=length = 0;
	strcpy(line,"");
	while (!flag && ( (linep=fgets(line2,MAXLINE,fp)))!=(char *)0)
	{
		if(line2[0] == '#') continue ;
		last = strlen(line2) ;
		if(last <= 0) continue ;
		if(line2[last-1] == '\n') line2[last-1] = '\0' ;
		last2 = last = last -1 ;
		length = length + last ;
		if(length >= max_num ) 
		{
			fprintf(net_err,"%s:<ERROR> Server entries in file %s exceed max\
length %d \nEntry = <%s%s>\n",Oargv[0],nfmd_configfile,max_num,line,line2);
			return((char *)0);
		}
		while(last2 > 0 && isspace(line2[last2-1])) last2--; 
		if(line2[last2-1] == '!') flag = 1;
		strcat(line,line2);
	}
	if(length <=0 ) return((char *)0);
	return(line);
}


NFMload_product_info()
{
	long xns_f,tcp_f,nfs_f;
	FILE  *prod_fp,*conf_fp, *fopen();
	static char *product_file="/usr/ip32/nfm/config/products" ;
	static char *ingrconfig_file="/usr/ip32/ingrconfig" ;
	char *line, line_buf[1024];
	xns_f=tcp_f=nfs_f = 0;
	prod_fp = fopen(product_file , "w" );
	if(prod_fp == (FILE *)0)
	{
		fprintf(net_err,"Cannot open  products file <%s> for writing\n",product_file);
		return(NFM_E_FOPEN);
	}
	conf_fp = fopen(ingrconfig_file , "r" );
	if(conf_fp == (FILE *)0)
	{
		fprintf(net_err,"Cannot open  config file <%s> for reading\n",ingrconfig_file);
		fclose(prod_fp);
		return(NFM_E_FOPEN);
	}

	while ((line=fgets(line_buf,1023,conf_fp)) != (char *)0)
	{
		if(!xns_f)
			if(strncmp(line_buf,"SS01636",7) == 0 ) xns_f = 1;
		if(!tcp_f)
			if(strncmp(line_buf,"SS01066",7) == 0 ) tcp_f = 1;
		if(!nfs_f)
			if(strncmp(line_buf,"SS01081",7) == 0 ) nfs_f = 1;
	}

	fclose(conf_fp);
	
    	if (!xns_f) 
		fprintf(prod_fp,"N   # XNS NOT PRESENT\n");
 	else 
		fprintf(prod_fp,"Y   # XNS PRESENT\n");
    	if (!tcp_f) 
		fprintf(prod_fp,"N   # TCP NOT PRESENT\n");
 	else 
		fprintf(prod_fp,"Y   # TCP PRESENT\n");
    	if (!nfs_f) 
		fprintf(prod_fp,"N   # NFS NOT PRESENT\n");
 	else 
		fprintf(prod_fp,"Y   # NFS PRESENT\n");
	
	fclose(prod_fp);
	return(NFM_S_SUCCESS);
}

