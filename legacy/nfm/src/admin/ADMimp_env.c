#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
* Abstract         Import environment from remote node to the       *
*                  local node.                                      *
*                                                                   *
* Arguments        						    *
*    long ADMimport_env (node_name, user_name, passwd, environment) *
*			char *node_name;                            *
*			char *user_name;                            *
*			char *passwd;                               *
*			char *environment;                          *
*                                                                   *
* Description         						    *
*    This function imports an environment from a remote node. The   *
* environment directory and its contents are received from the      *
* remote node.                                                      * 
*    This function uses either FMU or FTP to perform file transfers *
* and remote command execution.  First, an attempt is made to       *
* connect to the remote node via FMU. If this is not successful, an *
* attempt is made to use FTP. If both fail, function returns to the *
* calling function.                                                 * 
*    In the case of FMU, the environment directory and its contests *
* are transferred using cpio and rpipe.  For FTP, a cpio file is    *
* built on the remote node, shipped to the local node, and then     *
* a command is executed to decompose the cpio file.                 *
*                                                                   *
*                                                                   *
* Date        : aug 24, 1992                                        *
  Comments    : Add NETfmu_receive() and also get the system err    *
                message incause of anything goes wrong.             *
*********************************************************************
********************************************************************/
#include <pwd.h>
#include "NFMf_xferinc.h"

/* MSSP. 9 Dec 93. */
#include "NFMporttypes.h"

long ADMimport_env ( node_name, user_name, passwd, environment, local_passwd,
        dbpath, make_env)
char *node_name;
char *user_name;
char *passwd;
char *environment;
char *local_passwd;
char *dbpath;
char *make_env;
{

     int 	 status;
     int     cur_uid;
     long    file_size;
     long    ADMimport_env_fmu();
     long    ADMimport_env_ftp();
     int         uname();
     char    msg[500];
     char        *type = "ascii";
     char        *getenv();
     char        *mktemp();
     char        env_dir[64];
     char        src_cpio[32];
     char        dst_cpio[32];
     char        tmp_str[48];
     char        tmp_file[48];
     char        tmp_file2[48];
     char        tmp_file3[48];
     char        tmp_file4[48];
     char        remote_cmd_str[80];
     char        local_cmd_str[80];
     char        local_node_name[32];
     char        buf[250];
     FILE        *fp;
     struct utsname name;
     static struct passwd *getdir;

     static char *local_user_name = "nfmadmin";

     static char *fname = "ADMimport_env";

     _NFMdebug ((fname, "Entering....\n"));


      status = -1;

        cur_uid = getuid();
	/* MSSP. 9 Dec 93. Fixed parameter type for getpwuid() */
        getdir = getpwuid ((NFM_UID_T) cur_uid);
        dbpath = getdir->pw_dir;
        _NFMdebug((fname, "from fmu value for dbpath is <%s>\n",  dbpath));
        sprintf (make_env, "%s/system", environment);
        sprintf (env_dir, "%s/%s", dbpath, make_env);

     /* Attempt to connect to remote node using fmu. If not successful,
    try ftp. */

/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
    status = ADMimport_env_fmu(node_name, user_name, passwd,environment, 
                    local_passwd, dbpath, make_env);
#endif

    if (status != NFM_S_SUCCESS)
     {

       status = ADMimport_env_ftp(node_name, user_name, passwd,environment, 
                     local_passwd, dbpath, make_env);
    
       if (status != NFM_S_SUCCESS)
        {
             _NFMdebug((fname, " ftp failed\n"));
             return(status);
        }

       ADMmessage(msg);
       SCdisplay_msg(msg);
       ERRreset_struct();
       return(status);
 
     }
 
    ADMmessage(msg);
    SCdisplay_msg(msg);
    ERRreset_struct();

    _NFMdebug((fname, "Exiting successfully\n"));
    return(NFM_S_SUCCESS);
  }

long ADMimport_env_fmu ( node_name, user_name, passwd, environment, 
                      local_passwd,dbpath, make_env)
char *node_name;
char *user_name;
char *passwd;
char *environment;
char *local_passwd;
char *dbpath;
char *make_env;
{

     int     status;
     long    file_size;
     char        *type = "ascii";
     char        *getenv();
     char        *mktemp();
     char        env_dir[64];
     char        src_cpio[32];
     char        dst_cpio[32];
     char        tmp_str[48];
     char        tmp_file[48];
     char        tmp_file2[48];
     char        tmp_file3[48];
     char        tmp_file4[48];
     char        remote_cmd_str[80];
     char        local_cmd_str[80];
     char        local_node_name[32];
     char        buf[250];
     FILE        *fp;
     struct utsname name;
     static char *fname = "ADMimport_env_fmu";
     static char *local_user_name = "nfmadmin";

     _NFMdebug ((fname, "Entering....\n"));

     /* Attempt to connect to remote node using fmu. If not successful,
    try ftp. */
  
   _NFMdebug((fname,"Connecting via FMU : Node <%s> : User <%s>\n",
                            node_name,user_name));
     status = NETfmu_connect (node_name, user_name, passwd);
     if (status == NET_S_SUCCESS)
     {
        /* FMU connect was successful. */


        status = uname (&name);
        if (status == -1)
        {
            _NFMdebug ((fname, "System call failed : uname\n"));
            ERRload_struct (NFM,NFM_E_UNAME, "", NULL);
            return (NFM_E_UNAME);
        }

        strcpy (local_node_name, name.nodename);
/**********/
/* MA, try to create a temparary file in /usr/tmp of remote node
        and local node. Because i need to read the message back to user
        if something is wrong (exp : wrong passwd)
*/
        strcpy(tmp_file, mktemp("ADMINXXXXXXXXX"));
        strcpy(tmp_file3, mktemp("ADMIN1XXXXXXXX"));
/******/


        /* cpio option -c added to make it portable across different machines.
           SSRS 28 Feb 94 */
        sprintf (remote_cmd_str,
        "/bin/find %s -print | /bin/cpio -oc 2>&1 | rpipe %s.%s.%s \"/bin/cpio -imud\" > /usr/tmp/%s 2>&1", make_env, local_node_name, local_user_name, local_passwd,
      tmp_file);
       _NFMdebug ((fname, "Issue remote cpio command to <%s %s>\n", node_name,
        remote_cmd_str));

        status = NETfmu_rcmd (remote_cmd_str);
        if (status != NET_S_SUCCESS)
        {
           _NFMdebug((fname,"FMU remote command failed : <0x%.8x>\n", status));
           ERRload_struct (NFM, NFM_E_FMU_RCMD_COMMAND_FAILURE, "", NULL);
           return (NFM_E_FMU_RCMD_COMMAND_FAILURE);
        }
        sprintf(tmp_file2, "/usr/tmp/%s", tmp_file);

        /* cpio option -c added to make it portable across different machines.
           SSRS 28 Feb 94 */
        sprintf (remote_cmd_str,
"/bin/find %s -print | /bin/cpio -oc 2>&1 | rpipe %s.%s.%s \"/bin/cpio -imud\" > /usr/tmp/%s 2>&1", make_env, local_node_name, local_user_name, local_passwd,tmp_file);
        _NFMdebug ((fname, "Issue remote cpio command to <%s %s>\n", node_name,
          remote_cmd_str));

        status = NETfmu_rcmd (remote_cmd_str);
        if (status != NET_S_SUCCESS)
        {
           _NFMdebug((fname,"FMU remote command failed : <0x%.8x>\n", status));
           ERRload_struct (NFM, NFM_E_FMU_RCMD_COMMAND_FAILURE, "", NULL);
           return (NFM_E_FMU_RCMD_COMMAND_FAILURE);
        }
        sprintf(tmp_file2, "/usr/tmp/%s", tmp_file);
        sprintf(tmp_file4, "/usr/tmp/%s", tmp_file3);
/*******************************/
/* MA, i add this function to get the errfile from remote node to local
   node.
*/
        status = NETfmu_receive(tmp_file2, tmp_file4, "", (int *) &file_size);
        _NFMdebug((fname, "the size of file is <%d>\n", file_size));
        if ( status != NET_S_SUCCESS)
         {
           _NFMdebug((fname,"No output was created by fmu_rcmd <%s>:status <0x%.8x>\n", remote_cmd_str,status));
          return(NET_E_INVALID_PASSWD);
        }

      if (file_size >0)
       {
         fp = fopen(tmp_file4,"r");
         if(!fp)
          {
            status = NFM_E_OPEN_FILENAME;
            _NFMdebug((fname,"Unable to open /usr/tmp/NFMserver.log"));
            return (status);
           }
         while (fgets (buf, 81, fp) != (char *) NULL)
         _NFMdebug((fname, "<%s>\n", buf));
         ERRload_struct( NFM, NFM_E_FAILURE, "%s", buf, NULL);

        _NFMdebug ((fname, "Disconnecting from fmu...\n"));
/*****************/

        status = NETfmu_disconnect();
        if (status != NET_S_SUCCESS)
        {
           _NFMdebug ((fname, "FMU disconnect failed : <0x%.8x>\n", status));
           return (status);
        }
/**********/
/* MA, return a status here if is not successfull */

         return(NFM_E_FAILURE);

 /***********************/
      }
   }

      else
       {
          if (status != NET_S_SUCCESS)
           {
               _NFMdebug((fname, "fmu failed so use ftp\n"));
               return(status);
            }
       }
     _NFMdebug ((fname, "Exiting....\n"));

     return (NFM_S_SUCCESS);
}

long ADMimport_env_ftp ( node_name, user_name, passwd, environment, 
       local_passwd, dbpath, make_env)
char *node_name;
char *user_name;
char *passwd;
char *environment;
char *local_passwd;
char *dbpath;
char *make_env;
{

     int         status;
     char        src_cpio[32];
     int         cur_uid;
     long        file_size;
     char        *type = "ascii";
     char        env_dir[64];
     char        dst_cpio[32];
     char        remote_cmd_str[80];
     char        local_cmd_str[80];
     char        local_node_name[32];
     static char *fname = "ADMimport_env_ftp";


        _NFMdebug ((fname, "Entering....\n"));

        /* Build a cpio cmd string to be executed on the remote node. */

        sprintf (src_cpio, "nfmadmincpio");

        /* cpio option -c added to make it portable across different machines.
           SSRS 28 Feb 94 */
        sprintf (remote_cmd_str, "/bin/find %s -print | /bin/cpio -oc > %s",
                        make_env, src_cpio);

        _NFMdebug ((fname, "Ftp rexec : <%s>\n", remote_cmd_str));

        /* Execute remote command string */

        status = NFMftp_rexec (node_name, user_name, passwd, remote_cmd_str);
        if (status != NFM_S_SUCCESS)
        {

           _NFMdebug ((fname, "rexec failed : status <0x%.8x>\n", status));
          ERRload_struct (NFM, NFM_E_FTP_REXEC_FAILED, "", NULL);
          return (NFM_E_FTP_REXEC_FAILED);
        }

        /* Receive the cpio file from the remote node */

        sprintf (dst_cpio, "%s/nfmadmincpio",dbpath);
       
        _NFMdebug((fname, " print <%s>\n", dst_cpio));
        _NFMdebug ((fname, "Ftp receive <%s> from <%s>\n",src_cpio,node_name));

        status = NFMftp_receive (node_name, user_name, passwd, src_cpio,
                        dst_cpio, type, &file_size);
        if (status != NFM_S_SUCCESS)
        {
           _NFMdebug ((fname,
            "Receive <%s> from <%s> failed : status <0x%.8x>\n",
                        src_cpio, node_name));
           ERRload_struct (NFM, NFM_E_FTP_REC_FAILED, "", NULL);
           return (NFM_E_FTP_REC_FAILED);
        }

        /* Execute local command string to decompose the cpio file. */

#ifdef OS_HPUX
        sprintf (local_cmd_str, "cd %s;/bin/cat %s | /bin/cpio -imudc > /dev/null 2>&1",
            dbpath, dst_cpio);
#else
        sprintf (local_cmd_str, "cd %s;/bin/cat %s | /bin/cpio -imud > /dev/null 2>&1",
            dbpath, dst_cpio);
#endif

        _NFMdebug ((fname, "Issue local command <%s>\n", local_cmd_str));

        status = system (local_cmd_str);
        if (status)
        {
           _NFMdebug ((fname, "System command <%s> failed : <0x%.8x>\n",
                        local_cmd_str, status));
           return (status);
        }

        /* Cleanup */

        _NFMdebug ((fname, "Cleanup <%s>\n", dst_cpio));
        unlink (dst_cpio);

     _NFMdebug ((fname, "Exiting....\n"));

     return (NFM_S_SUCCESS);
}
