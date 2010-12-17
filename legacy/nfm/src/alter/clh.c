#include "machine.h"
#include "DEBUG.h"
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <malloc.h>
#include <string.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pwd.h>
#include "NFMenv.h"


static char err_msg[100];

/* changing 'string' to 'stringl' to avoid conflict with SCmain.c 
   SSRS 16 Feb 94 */
char stringl[MAXLINE+1], *s_ptr;
FILE *fp, *fopen();
char env_file[100];
char ser_file[100];
extern long get_server_node (char *nodename,char *local_nodename);
extern long get_env_property(char *nodename,long prop_no,char *value,long size);

char *clh_vbyop(nodename,property,value, size)
	char *nodename,*property,*value;
	long size;

{
	struct utsname sys_name;
	long status,prop_len,i;
	struct hostent *hostent_ptr;
	/*struct in_addr in;*/
        struct in_addr *addptr;      /* SSRS - 10/11/93 */
	char *c_status;
	char local_nodename[100];
	char *local_prop;
	long prop_no=0;
        struct passwd *pwd;
        static char *fname = "clh_vbyop" ;

	c_status = NULL;
	prop_no = 0 ;

        _NFMdebug((fname,"Enter:\n")); 
        _NFMdebug((fname,"     :nodename=<%s>,property=<%s>,\
                   size=<%ld>\n",nodename,property,size));

        pwd = getpwnam( "nfmadmin" );
        _NFMdebug((fname,"pwd->pw_dir=<%s>\n",pwd->pw_dir)); 

	sprintf(env_file,"%s/%s/%s", pwd->pw_dir, ENV_PATH, ENV_FILE);
	sprintf(ser_file,"%s/%s/%s", pwd->pw_dir, ENV_PATH, SER_FILE);

        _NFMdebug((fname,"env_file=<%s>,ser_file=<%s>\n",env_file,ser_file)); 

	prop_len = strlen(property);
	if(prop_len < 0 )
	{
	  strcpy(err_msg,"Property must have a value\n");
          _NFMdebug((fname,"prop_len=<%d>, err_msg=<%s>\n",prop_len,err_msg)); 
	  return(err_msg);
	}

	local_prop = (char *) malloc(prop_len+2);
	if(local_prop == NULL)
	{
	   strcpy(err_msg,"Internal error: Malloc failed\n");
           _NFMdebug((fname,"err_msg=<%s>\n",err_msg)); 
	   return(err_msg);
	}

	for(i=0; i < prop_len; i++)
		if(islower(property[i])) local_prop[i]=toupper(property[i]);
		else local_prop[i]=property[i];
	local_prop[prop_len]='\0';

        _NFMdebug((fname,"local_prop=<%s>\n",local_prop)); 

	if(strcmp(local_prop,"TCP_ADDRESS") == 0) prop_no=TCP_ADDR_INDEX ;
	else if(strcmp(local_prop,"NODENAME") == 0 
                || strcmp(local_prop, "NODE") == 0)  /* Added by SSRS */
                  prop_no = NODENAME_INDEX; 
	else if(strcmp(local_prop,"NETPROP16") == 0 )prop_no = PROTOCOL_INDEX; 
	else if(strcmp(local_prop,"NETPROP17") == 0 ) prop_no = USERNAME_INDEX; 
	else if(strcmp(local_prop,"NETPROP18") == 0 )prop_no = USERPASS_INDEX; 
	else if(strcmp(local_prop,"NETPROP20") == 0 )prop_no = SCHEMANAME_INDEX;
	else if(strcmp(local_prop,"NETPROP21") == 0 ) prop_no = SCHEMAPASS_INDEX;
	else if(strcmp(local_prop,"APPLICATION") == 0 ) prop_no = APPLICATION_INDEX;
	else
	{
	    sprintf(err_msg,"Property %20s is not SUPPORTED in NEW design",property);
	    free(local_prop);
            _NFMdebug((fname,"err_msg=<%s>\n",err_msg));
	    return(err_msg);
	}
	free(local_prop);
        _NFMdebug((fname,"prop_no=<%d>\n",prop_no));
       

/* Translate template to nodename */
	
      if((strcmp(nodename,"TEMPLATE")) == 0 || 
          (strcmp(nodename,"template")) == 0)
      {
		if((status=uname(&sys_name)) < 0 )
		{
		    strcpy(err_msg,"Uname failed");
                    _NFMdebug((fname,"err_msg=<%s>\n",err_msg));
		    return(err_msg);
		}
		else
		{
		    strcpy(local_nodename,sys_name.nodename);
                    _NFMdebug((fname,"local_nodename=<%s>\n",local_nodename));
		}
		if(prop_no == NODENAME_INDEX )
	        {
		    strncpy(value,sys_name.nodename,size);
		    value[size-1]='\0';
                    _NFMdebug((fname,"value=<%s>\n",value));
		    return(c_status);
		}
	}
        else if((strncmp(nodename,"nfms_",5) == 0) || (strncmp(nodename,"pdms_",5) == 0 ) )
	{
		status = get_server_node (nodename,local_nodename);
		if(status)
		{
		    sprintf(err_msg,"Cannot extract nodename for server <%s>",nodename);
                    _NFMdebug((fname,"get_server_node:err_msg=<%s>\n",err_msg));
		    return(err_msg);
		}
		if(prop_no == NODENAME_INDEX )
	        {
		   strncpy(value,local_nodename,size);
		   value[size-1]='\0';
                   _NFMdebug((fname,"prop_no=<%d>,value=<%s>\n",prop_no,value));
			   return(c_status);
			}
			
	/* figure out the nodename using NFMenv.dat file */
		}
		else if((strncmp(nodename,"nfme_",5) == 0) || (strncmp(nodename,"pdme_",5) == 0 ) )
		{
	/* Figure out which property is needed. Based on which property open
	   file NFMenv.dat and extract the property */
			if(prop_no == TCP_ADDR_INDEX || prop_no == NETPROP16_INDEX)
			{
				status = get_env_property(nodename,NODENAME_INDEX,local_nodename,99);
				if(status)
				{
					sprintf(err_msg,"Cannot extract nodename for environment <%s>",nodename);
			    _NFMdebug((fname,"get_env_property:err_msg=<%s>\n",err_msg));
					return(err_msg);
				}
			}
			else
			{
				status = get_env_property(nodename,prop_no,value,size);
				if(status)
				{
					sprintf(err_msg,"Cannot extract property <%s> for environment <%s>",property,nodename);
			    _NFMdebug((fname,"get_env_property:err_msg=<%s>\n",err_msg));
					return(err_msg);
				}
			return(c_status);
		}

	}
	else
		strcpy(local_nodename,nodename);
	if(prop_no == TCP_ADDR_INDEX)
	{
		hostent_ptr=gethostbyname(local_nodename);
		if(hostent_ptr == NULL)
		{
			sprintf(err_msg,"gethostbyname failed for <%s>",local_nodename);
		    _NFMdebug((fname,"gethostbyname :err_msg=<%s>\n",err_msg));
			return(err_msg);
/* ERROR */
		}
		else
		{
			
/*
			in.s_addr = (ulong)hostent_ptr->h_addr;
			printf("inet_addr %s\n",inet_ntoa(in));
*/
			/*strncpy(value,hostent_ptr->h_addr,size);*/

                        /* SSRS - 10/11/93 - h_addr changed to h_addr_list 
                                             and inet_ntoa added 
                        */
                        addptr = (struct in_addr *) (*(hostent_ptr->h_addr_list));
                        strncpy(value, inet_ntoa(*addptr),size); 
			value[size-1]='\0';
		    _NFMdebug((fname,"gethostbyname:value =<%s>\n",value));
			return(c_status);
		}
	}
	else if(prop_no == PROTOCOL_INDEX)
	{
		hostent_ptr=gethostbyname(local_nodename);
		if(hostent_ptr == NULL)
		{
			strncpy(value,"XNS",size);
			value[size-1]='\0';
		    _NFMdebug((fname,"PROTOCOL_INDEX:value =<%s>\n",value));
		}
		else
		{
			strncpy(value,"TCP",size);
			value[size-1]='\0';
		    _NFMdebug((fname,"PROTOCOL_INDEX:value =<%s>\n",value));
		}
		return(c_status);
	}
        else
        {
		if(prop_no == NODENAME_INDEX )
	        {
			status = get_server_node (nodename,local_nodename);
			if(status)
			{
		         _NFMdebug((fname,"NODENAME_INDEX :status =<%d>\n",status));
/*
				sprintf(err_msg,"Cannot extract nodename for server <%s>",nodename);
				return(err_msg);
*/
			}
			else
			{
				strncpy(value,local_nodename,size);
				value[size-1]='\0';
		    _NFMdebug((fname,"NODENAME_INDEX :value =<%s>\n",value));
				return(c_status);
			}
		}
		
		status = get_env_property(local_nodename,prop_no,value,size);
		if(status)
		{
			sprintf(err_msg,"Cannot extract property <%s> for environment <%s>",property,nodename);
		    _NFMdebug((fname,"get_env_property:err_msg =<%s>\n",err_msg));
			return(err_msg);
		}
		return(c_status);
	}

	sprintf(err_msg,"Bad node <%s> or property <%s>",nodename,property);
        _NFMdebug((fname,"err_msg =<%s>\n",err_msg));
        return(err_msg);
	
}

long get_server_node(nfms_node, server_node)
	char *nfms_node;
	char *server_node;
{
	char *token1,*token2;
        static char *fname = "get_server_node" ;

        _NFMdebug((fname,"Enter: nfms_node=<%s>\n",nfms_node));
	if((fp=fopen(ser_file,"r")) == (FILE *)0)
	{
#ifdef DEBUG
		printf("Cannot open file <%s>: errno <%d>\n",env_file,errno);
#endif
        _NFMdebug((fname,"fp =<%s>\n",fp));
		
		return(-1);
	}
	while((s_ptr=fgets(stringl,MAXLINE,fp)) != (char *)0)
	{
		if(stringl[0] == '#')	continue;
		/* .dat files contains no '::' at the end of file.
		   So checking for end of file - SSRS 17 Feb 94    */
		/*else if(strncmp(stringl,"::",2) == 0 )*/
		else if( feof( fp ) )
		{
			fclose(fp);
			return(-2);
		}
		token1 = strtok(stringl,"\001");
		if(token1 == (char *)0)
		{
			fclose(fp);
			return(-3);
		}
		token2 = strtok(NULL,"\001");
		if(token2 == (char *)0)
		{
			fclose(fp);
			return(-3);
		}

		if(strcmp(nfms_node,token1) == 0 )
		{
			strcpy(server_node,token2);
			fclose(fp);
			return(0);
		}
	}
	fclose(fp);
	return(-4);
}

long get_env_property(nodename,prop_no,value,size)
	char *nodename;
	long prop_no;
	char *value;
	long size;
{
	char *token1,*token2;
	long flag,index,token_len;
	
	if(prop_no <= 0 )
	{
#ifdef DEBUG
		printf("Bad property number <%d>\n",prop_no);
#endif
		
		return(-1);
	}
	flag = index = 0;
       
        /* Code for PROTOCOL_INDEX added temporarily by SSRS - 15/11/93 */
        /* This has to be taken care of properly */
        if(prop_no == PROTOCOL_INDEX)
        {
             strcpy(value, "TCP");
             value[3] = '\0';
             return(0);
        }

	if((fp=fopen(env_file,"r")) == (FILE *)0)
	{
#ifdef DEBUG
		printf("Cannot open file <%s>: errno <%d>\n",env_file,errno);
#endif
		
		return(-1);
	}
	while((s_ptr=fgets(stringl,MAXLINE,fp)) != (char *)0)
	{
		if(stringl[0] == '#')	continue;
		/* .dat files contains no '::' at the end of file.
		   So checking for end of file - SSRS 17 Feb 94    */
		/*else if(strncmp(stringl,"::",2) == 0 )*/
		 else if( feof( fp ) )
		{
			fclose(fp);
			return(-2);
		}
		token1 = strtok(stringl,"\001");
		if(token1 == (char *)0)
		{
			fclose(fp);
			return(-3);
		}
		if(strcmp(nodename,token1) == 0 )
		{
			while (token1!= (char *)0 && index <= prop_no )
			{
				if (prop_no == index)
				{
					token_len=strlen(token1);
					if(token_len > 0 && token1[token_len-1] == '\n')
						token1[token_len-1] ='\0';
					strncpy(value,token1,size);
					value[size-1]='\0';
					fclose(fp);
					return(0);
				}
				token1=strtok(NULL,"\001");
				index++;
			}
			fclose(fp);
			return(-1);
		}
		
	}
	fclose(fp);
	return(-4);
}
