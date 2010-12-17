#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMmach_id.h"
/* #include "RISerror.h" */
 #include "sql.h"
#include "DEBUG.h"
#include "ERR.h"
#include <sys/utsname.h>    /* PS for server node Info */

char *RIS_ENV=NULL;
char envName[30];           /* store current env and server names - PS */
char servName[30];

long NFMwrite_ris_parameters(env_name,node_name)
	char *node_name,*env_name;
{
	char *RISpar_file;
	FILE *fopen();
	char string[1024];
     	long      status,flag;
	char      nfm_usr   [100], d_nfm_usr   [100];
     	char      nfm_pwd    [100], d_nfm_pwd    [100];
     	char      usr_ptcl    [100], d_usr_ptcl    [100];
     	char      temp_str   [100] ;
	char address[100];
	static char *RISTMPDIR="/usr/tmp" ;
     	char *fname="NFMwrite_ris_parameters";
	char *clh_status, *dummy_ptr=NULL;
	schema_file_parms parms;
	

     _NFMdebug ((fname,"Environment Name= <%s> Node Name = <%s>\n",env_name, node_name));

	strcpy(envName, env_name);  /* PS */
	strcpy(servName, node_name);  /* PS */

	flag = 1;
/* Allocate space for the name of RISpar_file */
	if((RISpar_file = (char *)malloc(strlen(RISTMPDIR) + 20))== (char *)0)
	{
		_NFMdebug((fname,"NFMwrite_ris_parameters: Malloc failed for RISpar_file\n"));
		status=ERRload_struct(NFM,NFM_E_MALLOC,"");
		if(status != ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status <0x%.8x>\n",status));
		return(NFM_E_MALLOC);
	}
	sprintf(RISpar_file,"%s/%s",RISTMPDIR,"parameters");
	_NFMdebug((fname,"NFMwrite_ris_parameters: FILENAME  %s\n",RISpar_file));
	dummy_ptr=RIS_ENV ;
	if(RIS_ENV != (char *)0) 
	{
		if((strcmp(RISpar_file,getenv("RIS_PARAMETERS"))) == 0 )
		{
			flag = 0;
			_NFMdebug((fname,"RIS_PARAMETERS already has value <%s>: flag <%d>\n",RISpar_file,flag));
		}
	}
	if(flag)
	{
		sprintf(string,"RIS_PARAMETERS=%s",RISpar_file);
		if((RIS_ENV = (char *)malloc(strlen(string) + 10))== (char *)0)
		{
			_NFMdebug((fname,"NFMwrite_ris_parameters: Malloc failed for RISenv variable \n"));
			ERRload_struct(NFM,NFM_E_MALLOC,"");
			free(RISpar_file);
			RIS_ENV=dummy_ptr;
			return(NFM_E_MALLOC);
		}
		strcpy(RIS_ENV,string);
/* set the environment variable to the parameters file */
		if((status=putenv(RIS_ENV)) !=0)
		{
			_NFMdebug((fname,"Failed to define environment variable %s status <%d>\n",string,status));
			ERRload_struct(NFM,NFM_E_RIS_ENV_VAR,"");
			free(RISpar_file);
			free(RIS_ENV);
			RIS_ENV=dummy_ptr;
			return(NFM_E_RIS_ENV_VAR);
		}
		if(dummy_ptr != (char *)0) free(dummy_ptr);
	}
	_NFMdebug((fname, "RIS_ENV: <%s>\n", RIS_ENV));

/* Initialize the paramaters variable */
	parms.protocol = 'M';
	strcpy(parms.address,"");
	strcpy(parms.username,"");
	strcpy(parms.password,"");
        /* The schema filename changed from rischema to schemas.
           SSRS - 15/11/93
        */
	/*strcpy(parms.filename,"risschema");*/
        strcpy(parms.filename, "schemas");

        /* size changed from 25 to 26 for SUN - SSRS - 15/11/93 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
	clh_status = (char *)clh_vbyop (env_name, "NETPROP17", nfm_usr, 26);
#else

 clh_status = (char *)clh_vbyop (env_name,  "NETPROP17",  nfm_usr,  25);
#endif
     	if (clh_status)
	{
	        _NFMdebug ((fname,"CLH_VBYOP:User name status = <0x%.8x>\nerror <%s>\n",
	        NFM_E_CLH,clh_status));
       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s","NETPROP17",env_name);
		free(RISpar_file);
		NFMreset_ris_env();
	        return (NFM_E_CLH);
      	}

	sprintf (temp_str, "%*.*s", 25, 25, nfm_usr);

	status = NFMdecrypt (temp_str, d_nfm_usr);
	if (status != NFM_S_SUCCESS)
      	{
       		_NFMdebug ((fname,"Decr User Name : status = <0x%.8x>",
       NFM_E_CLH));
/*       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s", "decrypt Failed","NETPROP17"); */
		free(RISpar_file);
		NFMreset_ris_env();
	        return (status);
      	}

        /* size changed from 25 to 26 for SUN - SSRS - 15/11/93 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
 clh_status = (char *)clh_vbyop (env_name,  "NETPROP18",  nfm_pwd,  26);
#else
     	clh_status = (char *)clh_vbyop (env_name, "NETPROP18", nfm_pwd, 25);
#endif
     	if (clh_status)
      	{
       		_NFMdebug ((fname,"Get User Pwd : status = <0x%.8x>\n error <%s>\n",
       NFM_E_CLH,clh_status));
       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s","NETPROP18",env_name);
		free(RISpar_file);
		NFMreset_ris_env();
	        return (NFM_E_CLH);
      	}

	sprintf (temp_str, "%*.*s", 25, 25, nfm_pwd);

	status = NFMdecrypt (temp_str, d_nfm_pwd);
	if (status != NFM_S_SUCCESS)
      	{
       		_NFMdebug ((fname,"Decr NFM Pwd : status = <0x%.8x>",
       NFM_E_CLH));
/*       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s", "decrypt Failed","NETPROP18"); */
		free(RISpar_file);
		NFMreset_ris_env();
	        return (status);
      	}
     	clh_status = (char *)clh_vbyop (env_name, "NETPROP16", usr_ptcl, 25);
     	if (clh_status)
      	{
       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s","NETPROP16",env_name);
       		_NFMdebug ((fname,"Get protocol : status = <0x%.8x>\n error <%s>\n",
        NFM_E_CLH,clh_status));
		free(RISpar_file);
		NFMreset_ris_env();
	        return (NFM_E_CLH);
      	}

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        /* Added for SUN by SSRS - 15/11/93 */
        strcpy(d_usr_ptcl,  usr_ptcl);
#else
        /* SSRS - 15/11/93 - This part is not required on SUN as protocol name
           is not encrypted
        */      
	sprintf (temp_str, "%*.*s", 25, 25, usr_ptcl);

	status = NFMdecrypt (temp_str, d_usr_ptcl);
	if (status != NFM_S_SUCCESS)
      	{
       		_NFMdebug ((fname,"Decr Protocol : status = <0x%.8x>",
       NFM_E_CLH));
/*       		status = ERRload_struct (NFM, NFM_E_CLH,"%s%s", "decrypt Failed","NETPROP16"); */
		free(RISpar_file);
		NFMreset_ris_env();
		return (status);
      	}
#endif
/* Load the nodename as address */
	strcpy(address,node_name);
/* Load parms */
	strcpy(parms.username,d_nfm_usr);
	strcpy(parms.password,d_nfm_pwd);
	strcpy(parms.address,address);

	switch(d_usr_ptcl[0])
	{
		case 'd':
		case 'D':
			parms.protocol='D';
			break;	
		case 't':
		case 'T':
		if(_NFMisfile("/etc/inetd.conf") == NFM_S_SUCCESS)
			parms.protocol='T';
		else
			parms.protocol='X';

			break;	

		case 'x':
		case 'X':
			parms.protocol='X';
			break;	
		default: _NFMdebug((fname,"Bad protocol value <%s>\n",d_usr_ptcl));			
			 return(NFM_E_BAD_PROTOCOL);
	}
        /* Modified by kumar to suppress the display of passwd 10.24.93 */
	_NFMdebug((fname,"Protocol <%c> Address <%s> user <%s> filename <%s>\n",
		   parms.protocol,parms.address,parms.username,parms.filename));

	RISlocate_schema_file(&parms);

	if(SQLCODE != RIS_SUCCESS)
	{
		_NFMdebug((fname,"RIS_locate_schema_file:Failed status <%d>\n",SQLCODE));
/*     		status = ERRload_struct (NFM, NFM_E_RIS_ENV_VAR, ""); */
		ERRload_struct (NFM, NFM_E_LOCATE_SCHEMA_FILE,"%s%s%s%d",
				d_usr_ptcl, address, d_nfm_usr, SQLCODE) ;
		free(RISpar_file);
		NFMreset_ris_env();
		return(NFM_E_LOCATE_SCHEMA_FILE);
	}
	_NFMdebug((fname,"SUCCESSFUL PARAMETERS FILE IS %s\n",RISpar_file));
	free(RISpar_file);
	_NFMdebug((fname,"SUCCESSFUL status = 0x%.8x\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMreset_ris_env()
{
	char *fname="NFMreset_ris_env";
	char *dummy_ptr=NULL;
	int size,status;
	char location[100];

	_NFMdebug((fname,"Entry:Setting RIS_PARAMETERS=RIS_LOCATION/parms\n"));

	size = 96;
	dummy_ptr = RIS_ENV;

	if(RIS_ENV == (char *)0) 
	{
		_NFMdebug((fname,"RIS_PARAMETERS not set: status <0x%.8x>\n",NFM_S_SUCCESS));
		return(NFM_S_SUCCESS);
	
	}
	if((strcmp("/usr/ip32/ris/parameters",getenv("RIS_PARAMETERS"))) == 0 )
	{
/* PS */
	 _NFMdebug((fname,"RIS_PARAMETERS <%s>\n",getenv("RIS_PARAMETERS")));
	 _NFMdebug((fname,"RIS_PARAMETERS already has value </usr/ip32/ris>: status <0x%.8x>\n",NFM_S_SUCCESS));
		return(NFM_S_SUCCESS);
	}

	
	if((RIS_ENV = (char *)malloc(size))== (char *)0)
	{
		_NFMdebug((fname,"Malloc failed for RIS_PARAMETERS environment variable: size <%d> \n",size));
		status=ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
		RIS_ENV=dummy_ptr;
		return(NFM_E_MALLOC);
	}
	if((status=NFMget_ris_location(location)) != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to get location of RIS\n"));
		free(RIS_ENV);
		RIS_ENV=dummy_ptr;
		return(status);
	}
	sprintf(RIS_ENV,"RIS_PARAMETERS=%sparms",location);
/* set the environment variable to the parameters file */
	if((status=putenv(RIS_ENV)) !=0)
	{
		_NFMdebug((fname,"Failed to define environment variable %s status <%d>\n",RIS_ENV,status));
		status=ERRload_struct(NFM,NFM_E_RIS_ENV_VAR,"");
		free(RIS_ENV);
		RIS_ENV=dummy_ptr;
		return(NFM_E_RIS_ENV_VAR);
	}
	if(dummy_ptr != (char *)0) free(dummy_ptr);
	
	_NFMdebug((fname,"SUCCESSFUL:RIS_ENV= <%s>:status: <0x%.8x>\n",RIS_ENV,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);

}

int NFMget_ris_location(loc)
	char *loc;
{
	long status,i;
	char string[500];
/* VK - file /usr/ip32/ingrconfig may not be there always, but 
        /etc/risconfig would be present after RIS is installed -- 
	char *config_file="/usr/ip32/ingrconfig"; 
*/ 
	char *config_file="/etc/risconfig"; 

	char *fname="NFMget_ris_location";
	FILE *fp , *fopen();
	long flag ;
        char *str_ptr, *str_ptr2;

	struct utsname localNode;
	uname(&localNode);

	_NFMdebug((fname,"Entry\n"));
	flag = 0 ;
	if((fp = fopen(config_file,"r")) == (FILE *)0)
	{
		_NFMdebug((fname,"fopen failed for file <%s>: status <0x%.8x>\n"
, config_file,NFM_E_FOPEN));
		ERRload_struct(NFM,NFM_E_FOPEN,"%s%d%s",config_file,errno,"READ");
		return(NFM_E_FOPEN);
	}
	while((str_ptr = fgets ( string, 499, fp )) != (char *)0 && !flag)
	{
			str_ptr = strtok(string,"#");
			str_ptr = strtok(string,"#"); /* VK - 2nd words are 
                                                         Product names 
						      */
/**********************************************
   The product numbers are varying from platform to platform. So,
   Instead of looking for RIS product numbers in 'ingrconfig', I
   am looking for RIS Product names. 

   To support previous Product names of RIS, I am also checking for 
   RISPCUC, RISUCU, RISCCU of Clipper and 
   RISPSUC, RISUSU, RISCSU of SUN.
 
   IGI - 23 Sep 94
**********************************************/
		if(strncmp(str_ptr,"RISDP", 5 )   == 0 ||
		   strncmp(str_ptr,"RISPCUC", 7 ) == 0 ||
		   strncmp(str_ptr,"RISPSUC", 7 ) == 0 ||
		   strncmp(str_ptr,"RISCLI", 6 )  == 0 ||
		   strncmp(str_ptr,"RISCCU", 6 )  == 0 ||
		   strncmp(str_ptr,"RISCSU", 6 )  == 0 ||
		   strncmp(str_ptr,"RISUTL", 6 )  == 0 ||
		   strncmp(str_ptr,"RISUCU", 6 )  == 0 ||
		   strncmp(str_ptr,"RISUSU", 6 )  == 0) 

		{
			_NFMdebug((fname,"RIS entry in configuration file <%s>\
is \n:%s:\n",config_file,string));
			/*str_ptr = strtok(string,"#");*/
/* VK - for loop is reduced with one iteration as each line in /etc/risconfig 
  is one field less than that of /usr/ip32/ingrconfig
*/
			/* for(i=0; i < 5 && str_ptr != (char *)0; i++) */

			for(i=0; i < 4 && str_ptr != (char *)0; i++)
				str_ptr = strtok(NULL,"#");
			if(str_ptr == (char *)0)
			{
				
				_NFMdebug((fname,"Illegal entry in config file\
 <%s>: RIS entry 6th token must be path \n",config_file));
				_NFMdebug((fname,"Continuing to look for \
another RIS entry in configuration file <%s>\n",config_file));
				continue;
			}
		        i = strlen(str_ptr);
			str_ptr2 = str_ptr + i;
			while (*str_ptr2 != '/') 
                        {
			   *str_ptr2= '\0';
			   str_ptr2--;
			}
			strcpy(loc,str_ptr);
			flag=1;
		}
	}
	fclose(fp);
	if(flag)
	{
	_NFMdebug((fname,"SUCCESSFUL: loc <%s> : status <0x%.8x>\n",loc,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
	}
	else
	{
		_NFMdebug((fname,"RIS location Failed: loc <%s> : status <0x%.8x>\n",loc,NFM_E_FAILURE));
		sprintf(string,"RIS entry does not exist or is garbled in \
configuration file <%s> for server <%s> on node <%s>",
config_file, servName, localNode.nodename);
		ERRload_struct(NFM,NFM_E_MESSAGE,"%s",string);
		return(NFM_E_FAILURE);
	}
}
