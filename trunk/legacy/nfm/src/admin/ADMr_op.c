#include "machine.h"
#include <signal.h>
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "NFMdef.h"
#include "NFMsacdef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "NETstruct.h"
#include "MSGstruct.h"

extern MSGptr NFMmsg_ptr;
extern long max_num_rows ;

extern long sqlstatus;
extern struct NFMglobal_st NFMglobal;

long ADMdrop_table (user_id, oper_env)
     long    user_id;
     char   *oper_env;
{
        long status,i,j,len;
        long flag;
        char env_name[100];
        char msg[256];
        char str[50];
        char sql_str[1025];
        char rm_str[100];
        char remove_str[100];
        char temp_str[100];
        char temp_str1[100];
        char sch_n[100];
        char sch_p[100];
        char **data;
        MEMptr list = NULL;
        long return_status;

        static char *fname = "ADMdrop_table";


      _NFMdebug((fname,"Entry>> user_id  %d oper_env  %s\n",user_id,oper_env));
        flag = 0;
        return_status = NFM_S_SUCCESS;
        if(strlen(oper_env) <= 0)
         {
           _NFMdebug((fname,"Operating environment name is NULL\n"));
            status=ERRload_struct(NFM,NFM_E_NO_ENV_NAME,"");
            if(status!=ERR_S_SUCCESS)
             {
              _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
               return(NFM_E_NO_ENV_NAME);
             }
          }

           sprintf(env_name , "%s%s","nfme_",oper_env);

        if((status = ADMdef_schema(env_name)) != NFM_S_SUCCESS)
        {
          _NFMdebug((fname,"Unable to open schema for environment<%s>\n", oper_env));
          status=ERRload_struct(NFM,NFM_E_DEFINE_SCHEMA,"%s",env_name); 
           if(status!=ERR_S_SUCCESS)
           _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
           return(NFM_E_DEFINE_SCHEMA);
         }


        if((status = ADMtables_list(NFMglobal.NFMuserid,&list))!=NFM_S_SUCCESS)
        {

          _NFMdebug((fname,"Failed to generate list for operrating environment %s\n", env_name));
           status=ERRload_struct(NFM,NFM_E_FAILURE,"");
           if(status!=ERR_S_SUCCESS)
           {
             _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
             return(NFM_E_FAILURE);
           }
        }
        
        status = MEMbuild_array (list);
        data = (char **) list -> data_ptr;
   
        for (i=0; i<list-> rows; i++)
        {
           sprintf (sql_str,"DROP TABLE %s" , data[i]);
         if ((strcmp( data[i],"catalog")==0) || 
            (strcmp(data[i], "f_catalog")==0))
             continue;
          else
              status = SQLexec_imm (sql_str) ;
      
     /*         if (status != SQL_S_SUCCESS)
            {
              _NFMdebug((fname,"FIND NO TABLE\n"))
              return (NFM_E_SQL_QUERY);
            }*/

         }
            status = SQLstmt("DROP TABLE nfmattributes");
            status = SQLstmt("DROP TABLE nfmindex");
            status = SQLstmt("DROP TABLE nfmlists");
            status = SQLstmt("DROP TABLE nfmsysattributes");
            status = SQLstmt("DROP TABLE nfmtables");
            status = SQLstmt("DROP TABLE nfmvalues");

        if (strcmp(oper_env, NFMglobal.environment_name)==0)
         {
           if((status = ADMlogoff(env_name)) != NFM_S_SUCCESS)
            {
             _NFMdebug((fname,"Unable to logoff from environment<%s>\n", 
			oper_env));
             status=ERRload_struct(NFM,NFM_E_DEFINE_SCHEMA,"%s",env_name); 
             if(status!=ERR_S_SUCCESS)
             _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
             return(NFM_E_DEFINE_SCHEMA);
            }
            else 
             {
               _NFMdebug((fname, "Successfull loged off\n"));
              }

            if((status = ADMdrop_schema(env_name)) != NFM_S_SUCCESS)
             {
                _NFMdebug((fname, "Unable to Drop Schema", "%s", env_name));
                return(status);
             }

/* HP-PORT IGI 25 Aug 94 */
 #if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
      defined(OS_SCO_UNIX ) || defined(OS_HPUX))
               /* To delete environment entry from NFMenv.dat file.
                  Added by SSRS - 4/12/93 */
	       status = del_env("owned", env_name);
               if (status < 0)
                {
                 _NFMdebug ((fname,  "Remove %s Failed\n",  env_name));
                 return (NFM_S_SUCCESS);
                 }
               status = del_env("heard", env_name);
               if (status < 0)
                {
                 _NFMdebug ((fname,  "Remove %s Failed\n",  env_name));
                 return (NFM_S_SUCCESS);
                 }
#else
                sprintf(rm_str, "clh -d %s", env_name);
                status = system (rm_str);
                if (status < 0)
                 {
                  _NFMdebug ((fname, "Remove %s Failed\n", env_name));
                  return (NFM_S_SUCCESS);
                  }
#endif

/*
                 sprintf(remove_str, "rm -rf /usr/nfmadmin/%s",oper_env);
                 Adding the full path for rm. Vasu - 26.11.93
                 Getting path of nfmadmin from getenv() - SSRS - 21/12/93
*/
                sprintf(remove_str, "/bin/rm -rf %s/%s", getenv( "HOME" ), oper_env);

                _NFMdebug((fname, "system command: %s\n", remove_str));
                status = system (remove_str);
                if (status <0)
                 {
                   _NFMdebug ((fname, "Remove directories failed\n"));
                   return (NFM_S_SUCCESS);
                  } 
/***   put message here   ***/
                 _NFMdebug((fname, "You are loged off\n"));
                 ERRload_struct(NFM, NFM_I_AUTO_LOGOUT, "%s",NFMglobal.environment_name, NULL);
                 ERRget_message (msg) ;
                 SCdisplay_msg (msg);
                 return(NFM_I_AUTO_LOGOUT);
           }
        else
         {
            if((status = ADMdrop_schema(env_name)) != NFM_S_SUCCESS)
             {
               _NFMdebug((fname, "Unable to Drop Schema", "%s", env_name));
               return(status);
              }
             
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
               /* To delete environment entry from NFMenv.dat file.
                  Added by SSRS - 4/12/93 */
	       status = del_env("owned", env_name);
               if (status < 0)
                {
                 _NFMdebug ((fname,  "Remove %s Failed\n",  env_name));
                 return (NFM_S_SUCCESS);
                 }
               status = del_env("heard", env_name);
               if (status < 0)
                {
                 _NFMdebug ((fname,  "Remove %s Failed\n",  env_name));
                 return (NFM_S_SUCCESS);
                 }
#else
               sprintf(rm_str, "clh -d %s", env_name);
               status = system (rm_str);
               if (status < 0)
                {
                 _NFMdebug ((fname, "Remove %s Failed\n", env_name));
                 return (NFM_S_SUCCESS);
                 }
#endif
/*
                sprintf(remove_str, "rm -rf /usr/nfmadmin/%s",oper_env);
                Adding the full path for rm.  Vasu - 26.11.93
                Getting path of nfmadmin from getenv() - SSRS - 21/12/93
*/
               sprintf(remove_str, "/bin/rm -rf %s/%s", getenv( "HOME" ), oper_env);
       
               sprintf(remove_str, "/bin/rm -rf /usr/nfmadmin/%s",oper_env);
               _NFMdebug((fname, "system command: %s\n", remove_str));
               status = system (remove_str);
               if (status <0)
                {
                  _NFMdebug ((fname, "Remove directories failed\n"));
                  return (NFM_S_SUCCESS);
                 } 
  
         sprintf (temp_str, "%*.*s", 25, 25, NFMglobal.NFMsch_name);

         status = NFMdecrypt (temp_str, sch_n);
         if (status != NFM_S_SUCCESS)
          {
           status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
          _NFMdebug ((fname,"Decr Sch Pwd : status = <0x%.8x>", NFM_E_NET));
           return (NFM_E_FAILURE);
          }
         sprintf (temp_str1, "%*.*s", 25, 25, NFMglobal.NFMsch_passwd);
         status = NFMdecrypt (temp_str1,sch_p);
         if (status != NFM_S_SUCCESS)
          {
           status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
          _NFMdebug ((fname,"Decr Sch Pwd : status = <0x%.8x>", NFM_E_NET));
           return (NFM_E_FAILURE);
          }

     if (! strlen (sch_p))
       sprintf (sql_str, "DEFAULT SCHEMA %s", sch_n);

     else
       sprintf (sql_str, "DEFAULT SCHEMA %s.%s", sch_n, sch_p);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {

      status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname,"Default Schema : status = <0x%.8x>", NFM_E_SQL_STMT));
      return (NFM_E_SQL_STMT);
      }         
   }
         return (NFM_S_SUCCESS);
}

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
     defined(OS_SCO_UNIX ) || defined(OS_HPUX))
/* This part of code added to delete environments from NFMenv.dat file, 
   rather than deleting nfme_* file from /usr/lib/nodes/heard directory
           wiht 'clh -d' operation. (clh -d operation in not available
on SUN).
   SSRS - 4/12/93
*/
#include "NFMenv.h"
#include <pwd.h>
int del_env(env_loc, env_name)
char *env_loc;
char *env_name;
{

        char temp_file_name[100];
        char env_file_name[100];
        char line[200];
        char line2[200];
        char cmd_str[100];
        long status;
        FILE *temp_file,  *env_file,  *fopen();
        struct passwd *pwd;

        static char *fname = "ADMdel_env";

        pwd = getpwnam( "nfmadmin" );

        if( strcmp(env_loc, "owned") == 0 )
        {
            sprintf(temp_file_name, "/usr/tmp/%s", mktemp("TEMP1XXXXXX"));
            sprintf(env_file_name, "%s/%s/%s", pwd->pw_dir, ENV_PATH, OWNENV_FILE);
        }

        if( strcmp(env_loc, "heard") == 0 )
        {
            sprintf(temp_file_name, "/usr/tmp/%s", mktemp("TEMP2XXXXXX"));
            sprintf(env_file_name, "%s/%s/%s", pwd->pw_dir, ENV_PATH, ENV_FILE);
        } 
        if( (temp_file = fopen(temp_file_name,  "w")) == NULL )
        {
            _NFMdebug ((fname,  "Cannot open temp. file %s\n",  temp_file_name));
            return(-1);
        }
        if( (env_file = fopen(env_file_name,  "r")) == NULL )
        {
            _NFMdebug ((fname,  "Cannot open file %s\n",  env_file_name));
            return(-1);
        }
        while(1)
        {
            fgets(line,  200,  env_file);

            if(feof(env_file))
                break;

            strcpy(line2,  line);
            if( (strtok( line,  "\001")) )
                if( strcmp( line,  env_name) )
                {
                     fputs( line2,  temp_file);
                }
        }

        fclose(temp_file);
        fclose(env_file);

        sprintf(cmd_str,  "/bin/cp %s %s",  temp_file_name,  env_file_name);
        signal(SIGCHLD,SIG_DFL);
        status = system(cmd_str);
        /*if (status <0)
          {
            _NFMdebug ((fname,  "Remove %s Failed\n",  env_name));
            return (-1);
           } */

        return(0);
}
#endif

