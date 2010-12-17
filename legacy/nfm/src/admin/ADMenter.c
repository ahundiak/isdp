#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCextern.h"
#include "ERR.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "NFMstruct.h"
#include "NFIerrordef.h"

/* NFMporttypes.h  contains all the OS specific type definitions */
/* M. S. Sai Prasad.  9 Dec 93.                                  */

#include "NFMporttypes.h"

#define  L_cuserid  9

extern long sqlstatus;
       long NFMuser_id ; 
extern char   NFMprint_file[] ;
extern struct NFMglobal_st NFMglobal;

extern int LOGIN_FLAG;   /* defined in ADMlog.c - tmpPS */

nfm_enter (server, env_name,cmd_line_user, cmd_line_passwd, path) 
    char *server;
    char *env_name;
    char *cmd_line_user;
    char *cmd_line_passwd;
    char *path;

{
char   sql_str [1024];
char   *cwd;
char   message[100];
char   *unix_user;
char   unix_login[100];
char   NFMCWD [100];
char   msg[250];
long   user_pid ;
long   status;
int    i, j, k;
struct passwd *pwd_ptr ;
struct stat buf;
static char *fname = "nfm_enter";

    _NFMdebug ((fname, "ENTER\n"));

    /* Override the name of the print file defined in SC */

        strcpy (SCprint_file, "./Nfmadmin.prt");

    _NFMdebug_st.NFMdebug_on = 1 ;
    strcpy (_NFMdebug_st.NFMdebug_file, "/usr/tmp/server.dbg") ;
    _NFMdebug_st.SQLdebug_on = 1 ;
    strcpy (_NFMdebug_st.SQLdebug_file, "/usr/tmp/server.dbg") ;
/*
    strcpy (server, "");
    strcpy (path, "");
*/
    status = user_login();

    if (status != NFI_S_SUCCESS)
     {
       _NFMdebug ((fname, "user_login failed : status = <0x%.8x>\n", status)) ;

       ERRget_message (msg) ;
       SCdisplay_msg(msg);
       return (NFI_E_FAILURE);
     }

/* tmpPS  actual Login for arguments entered on command line 

  status = NFMlog_in (cmd_line_user, cmd_line_passwd, env_name, "NFM") ;

  _NFMdebug ((fname, "NFMlogin : <0x%.8x>\n", status));
  ADMmessage ();
  if (status != NFM_S_SUCCESS)
    {
     SCdisplay_msg("Login Failed");
     return(NFI_E_FAILURE); 
    }
    LOGIN_FLAG=0;
    
 end - tmpPS */
    _NFMdebug ((fname, "EXIT\n"));
/*    ERRload_struct (NFI, NFI_S_SUCCESS, "", "");*/
/*    return (NFI_E_FAILURE);*/   return (NFI_S_SUCCESS); 
}

user_login ()
{
 int   cur_uid;
/* The buffer size is increased from 20 to 255 to avoid a SEGV that
   comes as a side effect of this  MVR 10/11/1993 */
 char  cur_login[255];
/* end of change */
 char   name[L_cuserid];
 char   *pos;
 long   status;
 char   message[100];
 char   msg[250];
 struct passwd *pwd_ptr;
 static char *fname = "user_login" ;

     _NFMdebug ((fname, "ENTER\n"));

     cur_uid = getuid ();
     /* Fixed Param type. MSSP. 9 Dec 94 */
     status = getpw((NFM_UID_T) cur_uid,cur_login); 
     _NFMdebug((fname, "get cur_login <%s> and cur_uid <%d>\n",cur_login, cur_uid));
/*
   
     sprintf(msg, " echo \"cur_login is <%s> and cur_uid is <%d>\n\" > /dev/console", cur_login, cur_uid);  
     system (msg);
*/
     pos = (char *)strchr(cur_login, ':');
     if (pos != NULL)
        pos [0] = NULL;

     if (status !=0)
       {
/*         status = ERRload_struct (NFM, NFM_E_GETPWD, "", NULL);*/
         status = ERRload_struct (NFM, NFM_E_GETLOGIN, "", NULL);
/*         return (NFM_E_GETPWD);*/
         return (NFM_E_GETLOGIN);
       }

     if (strcmp (cur_login, "nfmadmin"))
       {
          status = NFM_I_ADMIN_DIR;
         _NFMdebug ((fname,"Nfmadmin must run from nfmadmin login directory"));
         ERRload_struct (NFM, NFM_I_ADMIN_DIR, NULL, NULL);
/*         ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                  "Nfmadmin must run from nfmadmin login directory", NULL);*/
/*          ERRget_message (msg) ;*/
/*          SCdisplay_msg (msg) ;*/
          return (status);
/*          return (NFM_E_MESSAGE);*/   
       }

    _NFMdebug ((fname, "EXIT\n"));
    return (NFI_S_SUCCESS);
}

nfm_exit ()
{
long   status;
static char *fname = "NFMexit";

    _NFMdebug ((fname, "ENTER\n"));

    _NFMdebug ((fname, "EXIT : status = <0x%.8x>\n", status));

    _NFMdebug ((fname, "EXIT\n"));
    return (NFM_S_SUCCESS);
}




