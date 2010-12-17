#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
* Abstract         Export environment from local node to a          *
*                  remote node.                                     *
*                                                                   *
* Arguments        						    *
*    long ADMexport_env (node_name, user_name, passwd, environment) *
*			char *node_name;                            *
*			char *user_name;                            *
*			char *passwd;                               *
*			char *environment;                          *
*                                                                   *
* Description         						    *
*    This function exports an environment to a remote node. The     *
* environment file, located on the local node in the /usr/lib/nodes *
* /owned directory, and the environment directory, located in the   *
* directory pointed to by the environment variable DBPATH, are to   *
* transferred to a remote node.                                     * 
*    This function uses either FMU or FTP to perform file transfers *
* and remote command execution.  First, an attempt is made to       *
* connect to the remote node via FMU. If this is not successful, an *
* attempt is made to use FTP. If both fail, function returns to the *
* calling function.                                                 * 
*    In the case of FMU, the environment directory and its contests *
* are transferred using cpio and rpipe.  For FTP, a cpio file is    *
* built on the local node, shipped to the remote node, and then     *
* a remote command is executed via rexec to decompose the cpio file *
* on the remote node.                                               *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/
#include  <pwd.h>
#include  "NFMf_xferinc.h"
#include  "NFMstruct.h"
extern    struct NFMglobal_st NFMglobal;

/* MSSP. 9 Dec 94. NFMporttypes.h contains OS specific typedefs */
#include "NFMporttypes.h"

long ADMexport_env ( node_name, user_name, passwd, environment)
char *node_name;
char *user_name;
char *passwd;
char *environment;
{
     long 	 status;
     long 	 file_size;
     long        ADMexport_env_fmu();
     long        ADMexport_env_ftp();
     char        *type = "";
     char        tmp_str[32];
     char        env_dir[80];
     char        src_env_file[80];
     char        dst_env_file[80];
     char        local_cmd_str[80];
     char        remote_cmd_str[80];
     char        src_cpio[80];
     char        dst_cpio[80];
     char        make_env[100];
     char        msg[250];
     struct stat fbuff;
     static char *fname = "ADMexport_env";

     _NFMdebug ((fname, "Entering...\n"));

     status = -1;

     /* Attempt to connect to remote node using fmu. If not successful,
    try ftp. */
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
    status = ADMexport_env_fmu(node_name, user_name, passwd,environment);
    _NFMdebug ((fname, " NODE is <%s>, USER is <%s>,  PASSWD is <%s> and ENV is <%s>\n", node_name, user_name, passwd, environment));
#endif

    if (status != NFM_S_SUCCESS)
     {
       status = ADMexport_env_ftp (node_name, user_name, passwd, environment);
       if (status != NFM_S_SUCCESS)
        {
          _NFMdebug((fname, "ftp failed too\n"));
          ADMmessage(msg);
          return(status);
        }

    ADMmessage(msg);
    ERRreset_struct();
    return(status);

    }

    _NFMdebug((fname, "Exiting successfully\n"));

    return(NFM_S_SUCCESS);
  }


long ADMexport_env_fmu ( node_name, user_name, passwd, environment)
char *node_name;
char *user_name;
char *passwd;
char *environment;
{
     long    status;
     long    file_size;
     int     cur_uid;
     char    *type = "";
     char    dbpath[120];
     char    *getenv();
     char    tmp_str[32];
     char    env_dir[80];
     char    src_env_file[80];
     char    dst_env_file[80];
     char    local_cmd_str[80];
     char    remote_cmd_str[80];
     char    src_cpio[80];
     char    dst_cpio[80];
     char    make_env[100];
     char    msg[250];
     char    *string;
     char    Invalid;
     char    Password;

     struct stat fbuff;
     static struct passwd *getdir;

     static char *fname = "ADMexport_env_fmu";

     _NFMdebug ((fname, "Entering...\n"));

     sprintf (src_env_file, "/usr/lib/nodes/owned/nfme_%s", environment);
     sprintf (dst_env_file, "/usr/lib/nodes/local/nfme_%s", environment);

     /* Check to ensure that environment file and environment exist on
    local node. */

     status = stat (src_env_file, &fbuff);
     if (status)
      {
        _NFMdebug ((fname, "Environment file <%s> does not exist",
               src_env_file));

        ERRload_struct(NFM, NFM_E_STAT, "%s", src_env_file);
        return (NFM_E_STAT);
      }
        cur_uid = getuid();

	/* MSSP 9 Dec 93. Fixed parameter type for getpwuid */
        getdir = getpwuid ((NFM_UID_T) cur_uid);

        sprintf(dbpath,"%s/", getdir->pw_dir);
        _NFMdebug((fname, "from fmu value for dbpath is <%s>\n",  dbpath));

 /******* modified: Only need to send system subdir under
        environment name to remote node  m.a *****************/

     sprintf(make_env, "%s/system", environment);
     sprintf (env_dir, "%s/%s", dbpath, make_env);

     _NFMdebug ((fname, "Local environment directory <%s>\n", env_dir));

     status = stat (env_dir, &fbuff);
     if (status)
     {
        ERRload_struct(NFM, NFM_E_STAT, "%s", env_dir);
        return (NFM_E_STAT);
     }

     /* Attempt to connect to remote node using fmu. If not successful,
        try ftp.  */
     _NFMdebug ((fname, "Connecting to <%s> via FMU\n", node_name));

     status = NETfmu_connect (node_name, user_name, passwd);
     if (status == NET_S_SUCCESS)
     {
        /* FMU connect was successful. */

        sprintf (local_cmd_str, "cd %s", dbpath);
        _NFMdebug((fname, " change dir is %s\n", local_cmd_str));
        status = system (local_cmd_str);
        if (status)
        {
           _NFMdebug ((fname, "System command <%s> failed : <0x%.8x>\n",
                            local_cmd_str, status));

           sprintf (tmp_str, "System Command");
           ERRload_struct(NFM, NFM_E_FAILURE, "%s%d", tmp_str, status);
           return (NFM_E_FAILURE);
        }
  /* Build cpio string to send environment directory and contents to
       remote node */

        /* cpio option -c added to make it portable across different machines.
           SSRS 28 Feb 94 */
        sprintf (local_cmd_str,
        "/bin/find %s -print | /bin/cpio -oc 2>&1| rpipe %s.%s.%s \"/bin/cpio -imud\" > /dev/null 2>&1", make_env, node_name, user_name, passwd);  /*  m.a  */

        _NFMdebug ((fname, "Executing local cpio command\n"));

        _NFMdebug ((fname, "find %s and rpipe %s.%s.%s\n", make_env, node_name,
              user_name, passwd));

        _NFMdebug ((fname, "local commands is <%s>\n", local_cmd_str));
        status = system (local_cmd_str);
        _NFMdebug((fname, " should be here\n"));
        if (status)
        {
           _NFMdebug ((fname, "System command <%s> failed : <0x%.8x>\n",
                            local_cmd_str, status));
           sprintf(tmp_str, "System Command");
           ERRload_struct(NFM, NFM_E_FAILURE, "%s%d", tmp_str, status);
           return (NFM_E_FAILURE);
        }

        /* Cleanup */

        status = NETfmu_disconnect();
        if (status != NET_S_SUCCESS)
        {
           _NFMdebug ((fname, "FMU disconnect failed : <0x%.8x>\n",status));
           return (status);
        }
   }
        else
           {
             ADMmessage(msg);
             ERRload_struct(NFM, NFM_E_NET, "", NULL);
             return(NFM_E_NET);
           }
          _NFMdebug ((fname, "Exiting...\n"));
          ERRreset_struct();
          return(NFM_S_SUCCESS);
   }


long ADMexport_env_ftp ( node_name, user_name, passwd, environment)
char *node_name;
char *user_name;
char *passwd;
char *environment;
{
     long    status;
     long    file_size;
     int     cur_uid;
     char        *type = "";
     char        dbpath[200];
     char        *getenv();
     char        tmp_str[32];
     char        env_dir[80];
     char        src_env_file[80];
     char        dst_env_file[80];
     char        local_cmd_str[80];
     char        remote_cmd_str[80];
     char        src_cpio[80];
     char        dst_cpio[80];
     char        make_env[100];
     char        msg[250];
     char        password;
     struct stat fbuff;
     static struct passwd *getdir;
     struct passwd *pwd;


     static char *fname = "ADMexport_env_ftp";

     _NFMdebug ((fname, "Entering...\n"));
/* HP-PORT IGI 25 Aug 94 */
#if (defined (OS_SUNOS) || defined (OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     pwd = getpwnam("nfmadmin");
     sprintf(src_env_file,"%s/%s/%s", pwd->pw_dir, "clh_info", "NFMowne.dat");
#else
     sprintf (src_env_file, "/usr/lib/nodes/owned/nfme_%s", environment);
     sprintf (dst_env_file, "/usr/lib/nodes/local/nfme_%s", environment);
#endif

     /* Check to ensure that environment file and environment exist on
    local node. */

     status = stat (src_env_file, &fbuff);
     if (status)
     {
       _NFMdebug ((fname, "Environment file <%s> does not exist", 
        src_env_file));
        ERRload_struct(NFM, NFM_E_STAT, "%s", src_env_file);
        return (NFM_E_STAT);
     }

        cur_uid = getuid();

	/* MSSP. 9 Dec 93. Fixed parameter type for getpwuid() */
        getdir = getpwuid ((NFM_UID_T) cur_uid);
       
        sprintf(dbpath,"%s", getdir->pw_dir);
        _NFMdebug((fname, "value for dbpath <%s>\n", dbpath));

 /******* modified: Only need to send system subdir under
        environment name to remote node  m.a *****************/

     sprintf(make_env, "%s/system", environment);
     sprintf (env_dir, "%s/%s", dbpath, make_env);

     _NFMdebug ((fname, "Local environment directory <%s>\n", env_dir));

     status = stat (env_dir, &fbuff);
     if (status)
      {
        ERRload_struct(NFM, NFM_E_STAT, "%s", env_dir);
        return (NFM_E_STAT);
      }

     /* Attempt to connect to remote node using fmu. If not successful,
        try ftp.  */


        /* FMU connect was unsuccessful. */

        _NFMdebug ((fname, "FMU connect failed : status <0x%.8x>\n", status));

        /* Attempt to send environment file via ftp. */

        /* Build cpio file from local environment directory */

        /* cpio option -c added to make it portable across different machines.
           SSRS 28 Feb 94 */
        sprintf (src_cpio, "%s/nfmadmincpio", dbpath);
#ifdef OS_SOLARIS
  /* On Solaris the '-O filename' option for cpio is creating the output
     file with improper permissions. This may be a bug in Solaris cpio.
     We made a work around. We are redirecting the cpio output to the file.
     If the bug on Solaris is fixed this change can be removed.
     SSRS - 20 Apr 94
     The cpio option -c is not working properly. Using '-H odc' instead of
     that, to make portable across different machines.
     SSRS 22 Apr 94 
  */
  sprintf (local_cmd_str,"/bin/find %s -print | /bin/cpio -o -H odc > nfmadmincpio 2>&1", make_env);  /* m.a */
#elif defined (OS_HPUX)
  sprintf (local_cmd_str,"/bin/find %s -print | /bin/cpio -oc > nfmadmincpio 2>&1", make_env);  /* m.a */
#else
  sprintf (local_cmd_str,"/bin/find %s -print | /bin/cpio -oc -O nfmadmincpio > /dev/null 2>&1", make_env);  /* m.a */
#endif

        _NFMdebug ((fname, "Execute local cpio command : <%s>\n", local_cmd_str));

        status = system (local_cmd_str);
        if (status)
        {
           _NFMdebug ((fname, "System shell str <%s> failed : <0x%.8x>\n",
                        local_cmd_str, status));

           sprintf(tmp_str, "System Command");

           ERRload_struct(NFM, NFM_E_FAILURE, "%s%d", tmp_str, status);
           return (NFM_E_FAILURE);
        }

        /* Send cpio file to remote node */

        sprintf (dst_cpio, "nfmadmincpio");

        _NFMdebug ((fname, "FTP send <%s> to <%s>\n", src_cpio, node_name));

        status = NFMftp_send (node_name, user_name, passwd, src_cpio,
                    dst_cpio, type, &file_size);
        if (status != NFM_S_SUCCESS)
        {
           _NFMdebug ((fname, "FTP send failed : status <0x%.8x>\n", status));
           ERRload_struct (NFM, NFM_E_FTP_SEND_FAILED, "", NULL);
           return (NFM_E_FTP_SEND_FAILED);
        }
 
        /* Execute command on remote machine to decompose cpio file */
#ifdef OS_HPUX
        sprintf (remote_cmd_str,"/bin/cat %s | /bin/cpio -imudc 2>&1", dst_cpio);
#else
        sprintf (remote_cmd_str,"/bin/cat %s | /bin/cpio -imud 2>&1", dst_cpio);
#endif

        _NFMdebug ((fname, "FTP rexec <%s> on <%s>\n",
                    remote_cmd_str, node_name));

        status = NFMftp_rexec (node_name, user_name, passwd, remote_cmd_str);
        if (status != NFM_S_SUCCESS)
        {
           _NFMdebug ((fname, "rexec failed : status <0x%.8x>\n", status));
           ERRload_struct (NFM, NFM_E_FTP_REXEC_FAILED, "", NULL);
           return (NFM_E_FTP_REXEC_FAILED);
        }

        /* Cleanup */

        _NFMdebug ((fname, "Cleanup cpio file on <%s>\n", node_name));
        sprintf (remote_cmd_str, "/bin/rm nfmadmincpio");

        status = NFMftp_rexec (node_name, user_name, passwd, remote_cmd_str);
        if (status != NFM_S_SUCCESS)
         {
         _NFMdebug ((fname, "Cleanup failed : status <0x%.8x>\n", status));
         return(status);
         }
   
/*      ERRreset_struct();*/
     _NFMdebug ((fname, "Exiting...\n"));
     return (NFM_S_SUCCESS);
}
