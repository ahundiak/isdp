/****************************************************************************

Name
   pdmoLogin

Abstract
   This function allows a user to log into an nfm environment allowing
   manipulation of the database.

Synopsis
  long pdmoLogin ( )

Description
   Input:

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords
Login

History
   Audra Romans Fri Jul  9 11:26:31 CDT 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/
#include <stdio.h>
#include <signal.h>
#include <PDMapi_value.h>
#include <PDMapi_struc.h>
#include <PDUstorage.h>
#include <PDUuser.h>
#include <NFMerrordef.h>
#include <PDUerror.h>
#include <PDUfile_def.h>
#include <pwd.h>
#include <sys/utsname.h>
#include <PDMproto.h>
#include <PDUproto.h>

/* Externs */

extern struct PDUuser *user;
extern struct PDUstorage *storage;
extern PDMexec_ptr PDMexec;
extern int PDU_apiflag;      /* defined in fmgr_global.c */
extern char *PDU_apimessage; /* defined in fmgr_global.c */


long pdmoLogin (cpr_env,cpr_pdmuser,cpr_pdmpasswd,spm_userinfo )
char *cpr_env, *cpr_pdmuser, *cpr_pdmpasswd;
struct pdmWorkingArea **spm_userinfo;

{
  char **ret_data;
  char *cwd = NULL;
  char *PDUgetcwd();
  char *env_var_name = NULL; 
  int i;
  long status,api_userid;
  struct passwd *user_struct;
  auto struct utsname name;
  MEMptr ret_list = NULL;

  void PDUuser_clear();
  void PDUstorage_clear();
  unsigned short getuid();
#ifdef sparc
  char  *node = NULL;
#endif
  struct utsname system_name;

  
  PDU_apiflag = 1;
  PDU_apimessage = NULL;

/* Set up the environment variable INGRHOME if it has not been set */
  /* ALR  2/3/94  */
   env_var_name = (char *)getenv("INGRHOME");
   _pdm_debug("env_var_name |%s| \n",env_var_name);
/* ALR   5/11/94   This is not the correct settings for SGI ??
   if (!((env_var_name) && (strcmp(env_var_name,"/usr/ip32") == 0)) ||
      ((env_var_name) && (strcmp(env_var_name,"/var/opt/ingr") == 0)) ||
      ((env_var_name) && (strcmp(env_var_name,"/opt/ingr") == 0)))
*/
    if (!env_var_name)
    {
     _pdm_debug("execute uname stmt \n",0);
     uname(&system_name);
     if (strncmp(system_name.sysname,"CLIX",4) == 0)
       putenv("INGRHOME=/usr/ip32");
         /* SGI */
     if (strncmp(system_name.sysname,"IRIX",4) == 0)
       putenv("INGRHOME=/var/opt/ingr");
     if (strncmp(system_name.sysname,"SunOS",5) == 0)
      {     /* SunOS 4.1 */
        if (strncmp(system_name.release,"4.1",2) == 0)
          putenv("INGRHOME=/usr/ip32");
           /* Solaris */
        else
          putenv("INGRHOME=/opt/ingr");
      }
    }


  /* Validate enviornment */
  if ((cpr_env == NULL) || (strcmp(cpr_env,"")))
    {
/* Retrieve a list of environments to verify against */
#if !defined (sparc) && !defined (__Sol2__) && !defined (__sgi)
      status = NFMls_nodes("pdme_",&ret_list);
      if (status != NFM_S_SUCCESS)
	return(PDM_E_LIST_ENVS);
#else
      /* Retrieve a list of sun environments */
     status = PDUget_envs(&ret_list);
     if (status != PDM_S_SUCCESS)
      return(PDM_E_LIST_ENVS);
#endif

      /* check thru list for given environment */

     MEMbuild_array(ret_list);
     ret_data = (char **)ret_list->data_ptr;
     status = PDM_E_BAD_ENV;
     for (i=0; i < ret_list->rows; i ++)
       {
         if (strcmp(ret_data[(ret_list->columns * i) + 0],cpr_env) == 0)
	  {
            status = PDM_S_SUCCESS;
            break;
	  }
       }
     if (ret_list != NULL)
       MEMclose(&ret_list);
     if (status == PDM_E_BAD_ENV)
       return(status);
    }
  else
   return(PDM_E_BAD_ENV);

  /* Validate pdm username and pdm password to insure not null */

  if (cpr_pdmuser == NULL)
   return(PDM_E_BAD_USERNAME);
  else
  if (!strcmp(cpr_pdmuser,""))
   return(PDM_E_BAD_USERNAME);

  /* Check if already logged in */
  if (user)
  {
    _pdm_debug("User already logged in",0);
    return(PDM_S_SUCCESS);
  } 

 /* Determine local workstation info and load pdmWorkingArea structure */

  (*spm_userinfo) = (struct pdmWorkingArea *) malloc (sizeof(struct pdmWorkingArea));
  user_struct = (struct passwd *) malloc(sizeof(struct passwd));
  user_struct = getpwuid(getuid());
 
  strcpy((*spm_userinfo)->user_name,user_struct->pw_name);

/*  ALR  6/16/94  This is not correct. Do not use a passwd from the workstation
  strcpy((*spm_userinfo)->user_passwd,user_struct->pw_passwd);
*/

  (*spm_userinfo)->user_passwd[0] = '\0';

  cwd = PDUgetcwd((char *)NULL, 64);
 
  _pdm_debug("getcwd returns <%d>", (char *)cwd);
  _pdm_debug("cwd = <%s>", cwd);
  strcpy((*spm_userinfo)->path, cwd);

  (*spm_userinfo)->node_name[0] = '\0';

#ifdef sparc

   status = PDUget_sun_nodename (&node);
   strcpy((*spm_userinfo)->node_name, node);
   if (status != PDM_S_SUCCESS)
    return(PDM_E_WRKST_NODE);
  
   _pdm_debug("NODENAME = <%s>\n",(*spm_userinfo)->node_name);

#else

   if ((status = uname (&name)) < 0)
     return(PDM_E_WRKST_NODE);

   strcpy((*spm_userinfo)->node_name,name.nodename); 

#endif  


 /* Load PDUuser struct and PDUstorage struct for internal use */
 /* Load PDMexec struct for internal use */

  PDUuser_init();
  PDUstorage_init();
  PDUpdm_exec_init();
  refresh_init();

  PDUfill_in_string(&user->username,cpr_pdmuser);
  PDUfill_in_string(&user->passwd,cpr_pdmpasswd);
  PDUfill_in_string(&user->environment,cpr_env);
  PDUfill_in_string(&user->wrkst_username,(*spm_userinfo)->user_name);
  PDUfill_in_string(&user->wrkst_passwd,(*spm_userinfo)->user_passwd);
  PDUfill_in_string(&user->wrkst_node,(*spm_userinfo)->node_name);
  PDUfill_in_string(&user->wrkst_cwd,(*spm_userinfo)->path);

  PDUfill_in_string(&storage->storage_name,"");
  PDUfill_in_string(&storage->node_name,user->wrkst_node);
  PDUfill_in_string(&storage->user_name,user->wrkst_username);
  PDUfill_in_string(&storage->passwd,user->wrkst_passwd);
  PDUfill_in_string(&storage->path_name,user->wrkst_cwd);

  PDUload_exec_structure("",cpr_pdmuser,cpr_pdmpasswd,cpr_env,"","","",0,0);
 
  status = PDMlogin(&api_userid);
  if (status != PDM_S_SUCCESS)
    {
     /* TR# 139315093. 18/Jan/95 - raj.	*/
      /*
      if (status == NFM_E_BAD_NODE);
      */
      if (status == NFM_E_BAD_NODE)
        status = PDM_E_BAD_NODE;
      if (status == NFM_E_BAD_PROTOCOL)
       status = PDM_E_BAD_PROTOCOL;
      if (status == NFM_E_BAD_USER)
       status = PDM_E_BAD_USERNAME;
      if (status == NFM_E_BAD_ENV)
       status = PDM_E_BAD_ENV;
      if (status == NFM_E_CLH)
       status = PDM_E_CLH;
      if (status == NFM_E_USER_PASSWD)
       status = PDM_E_USER_PASSWD;
      if (status == NFM_E_LOCATE_SCHEMA_FILE)
       status = PDM_E_LOCATE_SCHEMA_FILE;

      /* clear PDUuser structure */
      PDUuser_clear();
      /* clear PDUstorage structure */
      PDUstorage_clear();

      return(status);
    }
  else
    {
      signal(13,SIG_IGN);

      /* Verify initialization */
      PDUload_exec_structure("","","PDM","2.4.0","","","",0,0);
      status = PDMverify_init();
      if (status != PDM_S_SUCCESS)
      {
        PDUuser_clear();
        PDUstorage_clear();
        return(PDM_E_INITIALIZED);
      }

     /* Load  PDMexec struct with user_id */
      PDMexec->user_id = api_userid;
      (*spm_userinfo)->userid = api_userid;

     /* Load pdmWorkingArea Structure output variables */
      (*spm_userinfo)->userid = api_userid;
      (*spm_userinfo)->sanum = storage->storage_no;
      strcpy((*spm_userinfo)->saname,storage->storage_name);
    }
 
 return(PDM_S_SUCCESS);
}


void PDUuser_clear()
{
  if (user)
    {
      if (user->username)
      {
       free(user->username);
       user->username[0] = '\0';
      }
      if (user->environment)
      {
       free(user->environment);
       user->environment[0] = '\0';
      }
      if (user->server)
      {
       free(user->server);
       user->server[0] = '\0';
      }
      if (user->passwd)
      {
       free(user->passwd);
       user->passwd[0] = '\0';
      }
      user->user_id = NULL;
      if (user->storage_name)
      {
       free(user->storage_name);
       user->storage_name[0] = '\0';
      }

      if (user->wrkst_username)
      {
       free(user->wrkst_username);
       user->wrkst_username[0] = '\0';
      }
      if (user->wrkst_passwd)
      {
       free(user->wrkst_passwd);
       user->wrkst_passwd[0] = '\0';
      }
      if (user->wrkst_cwd)
      {
       free(user->wrkst_cwd);
       user->wrkst_cwd[0] = '\0';
       }
      if (user->wrkst_node)
      {
       free(user->wrkst_node);
       user->wrkst_node[0] = '\0';
      }

      free(user);
      user = NULL;
    }
}

void PDUstorage_clear()
{
  if (storage)
    {
      storage->storage_no = 0;
      if (storage->storage_name)
      {
       free(storage->storage_name);
       storage->storage_name[0] = '\0';
      }
      if (storage->node_name)
      {
       free(storage->node_name);
       storage->node_name[0] = '\0';
      }
      if (storage->user_name)
      {
       free(storage->user_name);
       storage->user_name[0] = '\0';
      }
      if (storage->passwd)
      {
       free(storage->passwd);
       storage->passwd[0] = '\0';
      }  
      if (storage->path_name)
      {
       free(storage->path_name);
       storage->path_name[0] = '\0';
      }

      free(storage);
      storage = NULL;
    }
}

