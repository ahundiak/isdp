#include <stdio.h>
#include "machine.h"
#include "INIT.h"
#include "NFMsysstruct.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
#include "NFMenv.h" /* Added for SUN/SCO port - SSRS - 9/11/93 */
#endif

#include "NFMporttypes.h"    /* to include OS specific type defs */

#define GREP "grep"

  extern MSGptr INITmsg_ptr;
  extern struct NFMuser_info_struct NFMuser_info ;

extern  char NFMCWD    [100];
extern  char EXECPATH  [];
extern  char NFM_ENV   [200];
extern  char NFM_SYS   [200];
extern  char NFM_UTL   [200];
extern  char NFM_FILES [200];
extern  char NFM_SA_UTIL[200];
extern char DRP_STR   [];
extern char OWN_ENV_FILE [];
extern char OWN_SERVER_FILE [] ;

int _NFMencrypt (passwd, e_passwd)
  char *passwd, *e_passwd;
  {
    char *fname="_NFMencrypt ";
    int   c, i, j, k, sum, len, offset;
    int   shift_count, padding_len;
    char  temp_str [FIXED_ENCRYPT_LENGTH + 1];

    static int seeded = 0;

    e_passwd [0] = 0;

    _NFMdebug ((fname, "Source = <%s>  : Dest = <%s>\n", passwd, e_passwd));

    if (! seeded)
     {
       srand ((unsigned) time ((long *) 0));
       seeded = 1;
     }

    if (! passwd)
     {
       _NFMdebug ((fname, " SOURCE IS NULL: status = <0x%.8x>\n", 
		   NFM_S_SUCCESS)) ;
       return (NFM_S_SUCCESS) ;
     }

    len = strlen (passwd);

    if (len >= MAX_PASSWD_LENGTH)
    {
       ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Passwd Too Long") ;
       _NFMdebug ((fname, "Passwd Too Long : status = <0x%.8x>\n", NFM_E_MESSAGE));
       return (NFM_E_MESSAGE) ;
    }

    sprintf (temp_str, "%02d%s", len, passwd);

    padding_len = FIXED_ENCRYPT_LENGTH - (len + 2);
 
    for (i = 0; i < padding_len; i++)
      temp_str [(len + 2) + i] = (rand () % ('~' - ' ')) + ' ';

    temp_str[(len + 2) + i] = '\0';

    sum = 0;

    for (i = 0; i < strlen (temp_str); i++)
        sum += temp_str [i];

    for (i = 0; i < FIXED_ENCRYPT_LENGTH; i++)
     {
       c =  temp_str [i];
       if (! isprint (c))
        {
           ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Invalid Password") ;
           _NFMdebug ((fname, "Invalid Password\n")) ;
           return (NFM_E_MESSAGE) ;
        }

       sum -= c;
       offset = (i + C1) * sum;
       c += offset;

       while (c > 0x7e)    c = c - 0x7f + 0x20;

       shift_count = ((i + C2) * sum) % 4;
       j = c & 0x0f;
       c ^= j;

       for (k = 0; k < shift_count; k++)
        {
          j <<= 1;
          if (j & 0x10)
           {
             j |= 1;
             j &= 0x0f;
           }
        }
       temp_str [i] = c | j;
     }

    strcpy (e_passwd, temp_str);

    _NFMdebug ((fname, "SUCCESSFUL : Encrypted String = <%s>\n", e_passwd)) ;
    return (NFM_S_SUCCESS) ;
  }

 long NFMwrite_init_files (node_attr, node_data, st_attr, st_data,
                          user_attr, user_data, db_attr, db_data)
   MEMptr  node_attr, node_data, st_attr, st_data;
   MEMptr  user_attr, user_data, db_attr, db_data;
   {
     static char *fname = "NFMwrite_init_files" ;
     long     status;
     char     **data ;
     char     str [100];
     char     date [20], time [20];
     long     NFMcreate_ser_node ();
     long     NFMcreate_env_node ();
     char     path[40];
     struct passwd *pwd;
     struct stat   buf;

     _NFMdebug ((fname, "WR ENV FILES : %s\n", "")) ;
     db_attr = db_attr ;
     user_data = user_data ;
     user_attr=user_attr ;

     path[0] = 0;
     pwd = getpwnam("nfmadmin");
     sprintf(path, "%s/%s", pwd->pw_dir, "clh_info");
     if(stat(path, &buf))
          mkdir( path, 00775);

     data = (char **) db_data -> data_ptr;

     date [0] = 0; time [0] = 0;
     status = NFMget_datetime (date);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Date & Time Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _INIT_str ("    CREATE SERVER NODE %s", "");

     status = NFMcreate_ser_node (data [0], node_attr, node_data,
              st_attr, st_data);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Write Server Node : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _INIT_str ("    CREATE SERVER NODE SUCCESSFUL%s\n", "");

     _INIT_str ("    CREATE ENVIRONMENT NODE%s", "");

     status = NFMcreate_env_node (node_data, st_data, db_data);
     if (status != NFM_S_SUCCESS)
      {

        sprintf (str, "/usr/lib/nodes/owned/nfms_%s", data [0]);
        unlink (str);
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", data[0]);
#endif
        _NFMdebug ((fname, "Write Env Node : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _INIT_str ("    CREATE ENVIRONMENT NODE SUCCESSFUL%s\n", "");

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

        
 long NFMcreate_ser_node (ser_name, node_attr, node_data,
                          st_attr, st_data)
   char    *ser_name;
   MEMptr  node_attr, node_data;
   MEMptr  st_attr, st_data;
   {
     static char *fname = "NFMcreate_ser_node" ;
     long    dup_stdout;
     long    status;
     char    **data, **n_data;
     char    str [200];
     int     stat_loc ;
     FILE    *owned_file, *fopen();
     FILE    *pp, *popen();
     char    grepbuf[200];
     char    *c_status;
     char    host_node[41];
     char    ch;
     int     i;
     struct passwd *pwd;

     _NFMdebug ((fname, "Ser Name = <%s>\n", ser_name));
     node_attr = node_attr ;
     st_attr = st_attr ;

      data   = (char **) st_data   -> data_ptr;
      n_data = (char **) node_data -> data_ptr;

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     /* This code writes node information to file NFMser.dat, instead of
         writing to  file /usr/lib/nodes/owned/nfms_*. 
        SSRS - 9/11/93
     */
     pwd = getpwnam( "nfmadmin" );
     sprintf (OWN_SERVER_FILE, "%s/%s/%s", pwd->pw_dir, ENV_PATH, SER_FILE);

     sprintf(grepbuf,"%s %s %s 2>/dev/null ", GREP, ser_name, OWN_SERVER_FILE);
      
     if (system(grepbuf) != 0 )
       NFMcreate_header_sun( "ser", ser_name, OWN_SERVER_FILE );
#else
     sprintf (OWN_SERVER_FILE, "/usr/lib/nodes/owned/nfms_%s", ser_name);

      status = _NFMcreate_header_of_node (OWN_SERVER_FILE);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Net Cr Ser Node : status = <0x%.8x>\n", status));
         return (status);
       }

#endif

/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
     /* Commented for SUN  by SSRS  9/11/93 
        This is to be replaced by a suitable clearing house function. 
     */
     status = (long) vfork() ;
     /* child */
     if (status == 0)
       {
	 sprintf (str, "nfms_%s", ser_name) ;
	 _INIT_str ("Executing a /usr/bin/clh -u %s\n",
		    str) ;
	 status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
				str, (char *) 0) ;
	 if (status == -1)
	   {
	     _NFMdebug ((fname, "Execl failed : errno %d\n", errno));
	     exit (0) ;
	   }
       }

     if (status == -1)
       {
	 _NFMdebug ((fname, "vfork failed : errno %d\n", errno));
	 return (status) ;
       } 

     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
	 if (errno == EINTR)
	   {
	     _NFMdebug ((fname, "Receipt of a signal %d\n", errno)) ;
	   }
	 else
	   {
	     _NFMdebug ((fname, "Wait failed %d\n", errno));
	   }
	 return (status) ;
       }
#endif     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS)) ;
     return (NFM_S_SUCCESS);     
   }



 long NFMunlink_env_files (db_attr, db_data)
   MEMptr   db_attr, db_data;
   {
     static char *fname = "NFMunlink_env_files" ;
      char    ser_file [100], env_file [100];
      char    **data;

      _NFMdebug ((fname, "UNLINK ENV : %s\n", ""));
     db_attr = db_attr ;
      data = (char **) db_data -> data_ptr;
      
     sprintf (ser_file, "/usr/lib/nodes/owned/nfms_%s", data [0]);
     sprintf (env_file, "/usr/lib/nodes/owned/nfme_%s", data [1]);

      unlink (ser_file);
      unlink (env_file);

      sprintf (ser_file, "%s/nfms_%s", EXECPATH, data [0]);
      unlink (ser_file);

      _NFMdebug ((fname, "UNLINK ENV : SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

long NFMpre_user_interface ()
{
  static char *fname = "NFMpre_user_interface" ;
  char *cwd, *getcwd();
  long status ;
  char  *p ;

  _NFMdebug ((fname, "ENTER\n")) ;
  NFMuser_info.uid = getuid () ;
  NFMuser_info.gid = getgid () ;

  _NFMdebug ((fname, "Set the NFMuser_info structure uid and gid to the real user uid <%d> : gid <%d>\n",
	      NFMuser_info.uid, NFMuser_info.gid)) ;

  NFMCWD [0] = 0;
  cwd = NULL;
  cwd = (char *) getcwd ( NULL, 98);
  if (! cwd)
    {
      status = ERRload_struct (NFM, NFM_E_GETPWD, "", NULL);
      _NFMdebug ((fname, "INIT : Error No = <%d>\n", errno));
      _NFMdebug ((fname, "INIT : Get CWD Failed : status = <0x%.8x>\n", NFM_E_GETPWD));
      _INIT_num ("INIT : Error No = <%d>\n", errno);
      _INIT_num ("INIT : Get CWD Failed : status = <0x%.8x>\n", NFM_E_GETPWD);
      return (NFM_E_GETPWD);
    }
  else
    strcpy (NFMCWD, cwd);
  
  sprintf (INITmsg_ptr.debug_file, "%s/NFMinit.log", NFMCWD);
  
  _NFMdebug ((fname, "LOG FILE : <%s>\n", INITmsg_ptr.debug_file));
  
  _INIT_str ("LOG FILE : <%s>\n", INITmsg_ptr.debug_file);
  
  status = (long) chmod (INITmsg_ptr.debug_file, 00000666) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "Chmod file %s failed", INITmsg_ptr.debug_file));
      _NFMdebug ((fname, "Chmod error no %d\n", errno));
      _INIT_str ("INIT : Chmod file %s failed", INITmsg_ptr.debug_file) ;
      _INIT_num ("INIT : Chmod error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod of debug file") ;
      return (NFM_E_MESSAGE);
    }
  
  
  /* make utilities storagearea  subdirectory : 
     <NFM executables partition>/ip32/nfm/utilities */
  
  _INIT_str ("INIT : exec path is %s\n", EXECPATH) ;
  
  p = (char *) strrchr (EXECPATH, '/') ;
  *p = NULL ;
  
  p = (char *) strrchr (EXECPATH, '/') ;
  *p = NULL ;
  
  sprintf (NFM_SA_UTIL, "%s/%s", EXECPATH, "utilities");
  
  /*********** RIS 3.0 does not require parameters file ******
   */ /* copy the /usr/ip32/ris/parameters file in EXECPATH */ /*
       */ /* per DURWOOD assume parameter files is always in /usr/ip32/ris */ /*
	     
	     i_status = stat ("/usr/ip32/ris/parameters", &buf) ;
	     if (i_status)
	     {
	     _INIT_str ("/usr/ip32/ris/parameters was not found %s", "") ;
	     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "/usr/ip32/ris/parameters was not found - may have to create software link") ;
	     return (NFM_E_MESSAGE) ;
	     }
	     
	     sprintf (str, "/bin/cp /usr/ip32/ris/parameters %s", EXECPATH) ;
	     
	     _INIT_str ("system -> %s\n", str) ;
	     
	     status = system (str) ;
	     
	     if (status < 0)
	     {
	     _NFMdebug ((fname, "System failed:errno %d\n", errno));
	     _INIT_str ("NFMpre_user_interface : system failed:errorno %d\n",
	     errno) ;
	     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "failed to copy parameters file") ;
	     return (NFM_E_MESSAGE) ;
	     }
	     
	     sprintf (parameter_file, "%s/%s", EXECPATH, "parameters") ;
	     
	     i_status = stat (parameter_file, &buf) ;
	     if (i_status)
	     {
	     _INIT_str ("%s NOT FOUND", parameter_file) ;
	     sprintf (mess, "%s NOT FOUND", parameter_file) ;
	     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", mess) ;
	     return (NFM_E_MESSAGE) ;
	     }
	     
	     status = (long) chmod (parameter_file, 00000666) ;
	     if (status == -1)
	     {
	     _NFMdebug ((fname, "Chmod file %s failed", INITmsg_ptr.debug_file));
	     _NFMdebug ((fname, "Chmod error no %d\n", errno));
	     _INIT_str ("INIT : Chmod file %s failed", INITmsg_ptr.debug_file) ;
	     _INIT_num ("INIT : Chmod error no %d\n", errno) ;
	     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod of debug file") ;
	     return (NFM_E_MESSAGE);
	     }
	     ************************ RIS does not require parameters file ********/
  
  _INIT_str ("PRE USER INTERFACE %s\n", "");
  return (NFM_S_SUCCESS) ;
}


long NFMcreate_directories ()
{
  static char *fname = "NFMcreate_directories" ;
  long  status ;
  
/******  Create all subdirectories needed in NFM ******/

/* make environment subdirectory <NFMCWD>/environment_name (without nfme_) */

    /*  Parameter type casted to take care of solaris port */ 
  status = (long) mkdir (NFM_ENV, (NFM_MODE_T) 00000775) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "mkdir %s failed", NFM_ENV));
      _NFMdebug ((fname, "mkdir error no %d\n", errno));
      _INIT_str ("INIT : mkdir %s failed", NFM_ENV);
      _INIT_num ("INIT : mkdir error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unable to make environment subdirectory") ;
      return (NFM_E_MESSAGE);
    }
  
  status = (long) chown (NFM_ENV, (NFM_UID_T) getuid(), (NFM_GID_T) getgid()) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "chown %s failed", NFM_ENV));
      _NFMdebug ((fname, "chown error no %d\n", errno));
      _INIT_str ("INIT : chown %s failed", NFM_ENV)  ;
      _INIT_num ("INIT : chown error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod of environment subdirectory") ;
      return (NFM_E_MESSAGE);
    }
  
  /* make reports subdirectory <NFMCWD>/NFM_ENV/reports */
  

  status = (long) mkdir (NFM_SYS, (NFM_MODE_T) 00000775) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "mkdir %s failed", NFM_SYS));
      _NFMdebug ((fname, "mkdir error no %d\n", errno));
      _INIT_str ("INIT : mkdir %s failed", NFM_SYS)  ;
      _INIT_num ("INIT : mkdir error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unable to make reports subdirectory") ;
      return (NFM_E_MESSAGE);
    }

  status = (long) chown (NFM_SYS, (NFM_UID_T) getuid(), (NFM_GID_T) getgid()) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "chown %s failed", NFM_SYS));
      _NFMdebug ((fname, "chown error no %d\n", errno));
      _INIT_str ("INIT : chown %s failed", NFM_SYS)  ;
      _INIT_num ("INIT : chown error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod of reports subdirectory") ;
      return (NFM_E_MESSAGE);
    }

  /* make utilities subdirectory <NFMCWD>/NFM_ENV/utilities */


  status = (long) mkdir (NFM_UTL, (NFM_MODE_T) 00000775) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "mkdir %s failed", NFM_UTL));
      _NFMdebug ((fname, "mkdir error no %d\n", errno));
      _INIT_str ("INIT : mkdir failed") ;
      _INIT_num ("INIT : mkdir error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unable to mkdir utilities") ;
      return (NFM_E_MESSAGE);
    }

  status = (long) chown (NFM_UTL, (NFM_UID_T) getuid(), (NFM_GID_T) getgid()) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "chown %s failed", NFM_UTL));
      _NFMdebug ((fname, "chown error no %d\n", errno));
      _INIT_str ("INIT : chown %s failed", NFM_UTL)  ;
      _INIT_num ("INIT : chown error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod of utilities directory") ;
      return (NFM_E_MESSAGE);
    }
  
  /* make files subdirectory : <NFMCWD>/files */
  
  status = (long) mkdir (NFM_FILES, (NFM_MODE_T) 00000775) ;
  if (status == -1)
    {
      _NFMdebug ((fname, "mkdir %s failed", NFM_FILES));
      _NFMdebug ((fname, "mkdir error no %d\n", errno));
      _INIT_str ("INIT : mkdir %s failed", NFM_FILES)  ;
      _INIT_num ("INIT : mkdir error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to mkdir files") ;
      return (NFM_E_MESSAGE);
    }

  status = (long) chown (NFM_FILES, (NFM_UID_T) getuid(), (NFM_GID_T) getgid());
  if (status == -1)
    {
      _NFMdebug ((fname, "chown %s failed", NFM_FILES));
      _NFMdebug ((fname, "chown error no %d\n", errno));
      _INIT_str ("INIT : chown %s failed", NFM_FILES)  ;
      _INIT_num ("INIT : chown error no %d\n", errno) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to chmod on files") ;
      return (NFM_E_MESSAGE);
    }
  
  return (NFM_S_SUCCESS) ;
}


long NFMremove_directories () 
{
  static char *fname = "NFMremove_directories" ;
  char rm_str [100] ;
  long status ;

  /* Vasu Added path /bin for rm - 27.10.93 */  
  sprintf (rm_str, "/bin/rm -rf %s", NFM_ENV) ;
  status = system (rm_str) ;
  if (status < 0)
    {
      _NFMdebug ((fname, "Remove directories failed\n"));
      return (NFM_S_SUCCESS) ;
    }

  return (NFM_S_SUCCESS) ;
}

 long NFMcreate_env_node (node_data, st_data, db_data)
   MEMptr    node_data;
   MEMptr    st_data;
   MEMptr    db_data;
   {
     static char *fname = "NFMcreate_env_node" ;
     long      status;
     FILE      *fopen (), *in_file;
     char      str [100];
     char      **data1, **data, **data2;
     long      stat_loc ;
     char      *c_status;
     char      host_node[41];
     char      ch;
     int       i;
     struct passwd *pwd;

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     /* added to store local environment filename for SUN - SSRS - 4/12/93 */
     char      OWNED_FILE[100];  
     FILE      *in_file2;
#endif
     
     _NFMdebug ((fname, "CR ENV : %s\n", ""));
      data  = (char **) db_data   -> data_ptr;
      data1 = (char **) st_data   -> data_ptr;
      data2 = (char **) node_data -> data_ptr;


/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     /* In this function the code included in 'ifdef' appends environment
        information to NFMenv.dat and NFMowne.dat files. Otherwise a new file
        '/usr/lib/nodes/owned/nfme_*' is created and environment information is 
        written to this file.  SSRS - 9/11/93
     */
     pwd = getpwnam( "nfmadmin" );
     sprintf (OWN_ENV_FILE, "%s/%s/%s", pwd->pw_dir, ENV_PATH, ENV_FILE);
     sprintf (OWNED_FILE, "%s/%s/%s", pwd->pw_dir, ENV_PATH, OWNENV_FILE);

     NFMcreate_header_sun( "env", data[1], OWN_ENV_FILE );
     NFMcreate_header_sun( "env", data[1], OWNED_FILE );

     /* This file contains only local environments */
     if ((in_file2 = fopen (OWNED_FILE, "a")) == NULL)
      {
        status = NET_E_OPEN_FILENAME;
        ERRload_struct(NETS,status,"%s", OWNED_FILE);
        return (status);
      }

#else
     sprintf (OWN_ENV_FILE, "/usr/lib/nodes/owned/nfme_%s", data [1]);

     status = _NFMcreate_header_of_node (OWN_ENV_FILE) ;
     if (status != NFM_S_SUCCESS)
       {
         unlink (OWN_ENV_FILE);
         _NFMdebug ((fname, "Net Cr Ser Node : status = <0x%.8x>\n", status));
         return (status); 
       }
#endif

     in_file = fopen (OWN_ENV_FILE, "a");
     if (! in_file)
      {
        status = NET_E_OPEN_FILENAME;
        ERRload_struct(NETS,status,"%s", OWN_ENV_FILE);
        return (status);
      }

/*******  AS OF 3/17/91 - RIS GETS THE FOLLOWING INFORMATION FROM 
          RISSCHEMA -
	        RDBMS TYPE - NETPROP11
                RDBMS HOME DIR - NETPROP13
                DATABASE NAME - NETPROP14 
                ENVIRONMENT NODE - NETPROP15
********************************************************************/   

      /*   ENCRYPT RIS NETWORK (Encrypted) */ 

      str [0] = 0;
      status = NFMencrypt (data [6], str); 
      if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE);
#endif
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
/*      fprintf (in_file, "%s\1", str); */ /* not adding PROTOCOL now */
/*      fprintf (in_file2, "%s\1", str); */ /* not adding PROTOCOL now */
#else
      fprintf (in_file, "NETPROP16 : %s\n", str); 
#endif

      /*   ENCRYPT SCH NAME */ 

      str [0] = 0;
      status = NFMencrypt (data [7], str); /* was data [6] */
      if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE);
#endif
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      fprintf (in_file, "%s\1", str); 
      fprintf (in_file2, "%s\1", str); 
#else
      fprintf (in_file, "NETPROP20 : %s\n", str);
#endif

      /*   ENCRYPT SCH PWD */ 

      str [0] = 0;
      status = NFMencrypt (data [8], str);  /* was data [7] */
      if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE);
#endif
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      fprintf (in_file, "%s\1", str); 
      fprintf (in_file2, "%s\1", str); 
#else
      fprintf (in_file, "NETPROP21 : %s\n", str);
#endif

      /*   USERNAME  (Encrypted) */ 

      str [0] = 0;
      status = NFMencrypt (data [9], str);
      if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE);
#endif
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      fprintf (in_file, "%s\1", str); 
      fprintf (in_file2, "%s\1", str); 
#else
      fprintf (in_file, "NETPROP17 : %s\n", str);
#endif

      /*   USERS PASSWORD (Encrypted) */ 

      str [0] = 0;
      status = NFMencrypt (data [10], str);
      if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE);
#endif
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      fprintf (in_file, "%s\1\n", str); 
      fprintf (in_file2, "%s\1\n", str); 
#else
      fprintf (in_file, "NETPROP18 : %s\n", str);
#endif

      status = fclose (in_file);
      if (status)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
         unlink (OWN_ENV_FILE); 
#endif
         status = ERRload_struct (NFM, NFM_E_CLOSE_FILE, "", NULL);
         _NFMdebug ((fname, "fclose : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fclose : status = <0x%.8x>\n", NFM_E_CLOSE_FILE));
         return (NFM_E_CLOSE_FILE); 
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      status = fclose (in_file2);
      if (status)
       {
         status = ERRload_struct (NFM, NFM_E_CLOSE_FILE, "", NULL);
         _NFMdebug ((fname, "fclose : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fclose : status = <0x%.8x>\n", NFM_E_CLOSE_FILE));
         return (NFM_E_CLOSE_FILE); 
       }
#endif

/* HP-PORT IGI 25 Aug 94 */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
      /* Commented for SUN by SSRS - 9/11/93  
         This is to be replaced by a suitable clearing house function.
      */
      status = (long) vfork () ;
      if (status == 0)
	{
	  sprintf (str, "nfme_%s", data [1]) ;
	  _INIT_str ("Executing a /usr/bin/clh -u %s\n",
		     str) ;
	  status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
				 str, (char *) 0) ;
	  if (status == -1)
	    {
	      _NFMdebug ((fname, "execl failed %d\n", errno));
	      exit (0) ;
	    }
	}

      if (status == -1)
	{
	  _NFMdebug ((fname, "vfork failed %d\n", errno));
	  return (status) ;
	}


     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
	   {
	     _NFMdebug ((fname, "Receipt of a signal %d\n", errno));
	   }
         else
	   {
	     _NFMdebug ((fname, "wait failed %d\n", errno));
	   }
	 return (status) ;
       }


      status = (long) vfork () ;
      if (status == 0)
	{
          freopen ("/dev/null", "w", stdout);
          freopen ("/usr/tmp/NFMhconv.err", "w", stderr);

	  status = (long) execl ("/usr/lib/hconv", "/usr/lib/hconv",
                                 "-E", 
				 (char *) 0) ;

	  if (status == -1)
	    {
	      _NFMdebug ((fname, "execl failed %d\n", errno));
	      exit (0) ;
	    }
	}

      if (status == -1)
	{
	  _NFMdebug ((fname, "vfork failed %d\n", errno));
	  return (status) ;
	}

      else
        {
          _INIT_str ("Parent process\n", str);
        }
#endif
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);      
   }

NFMtic_to_tics( in, out )
    char *in;
    char *out;
{

    while( *in )
    {
	if( *in == '\'' )
	{
	    *out = '\'';
	    ++out;
	}
	*out++ = *in++;
    }    
    *out = '\0';

    return( NFM_S_SUCCESS );
}

int _NFMcreate_header_of_node (file_name)
  char *file_name;
  {
    char *fname="_NFMcreate_header_of_node" ;
     int    status;
     int    i;
     char   ch;
     char   *c_status;
     char   inet_addr[41], tcp_addr [41];
     char   host_node[41];
     char   encr_user[41], encr_pass[41];
     FILE   *fopen (), *owned_file;

     encr_user [0] = 0; encr_pass [0] = 0;

     /*  Find the nodename for the server node  */
     /* clh_vbyop returns NULL upon success. */

    c_status = (char *) clh_vbyop ("TEMPLATE", "NODENAME", host_node, 40);
    if (c_status)
      {
	status = NET_E_CLH_LOOKUP_FAILED;
	ERRload_struct(NETS,status,"%s%s","TEMPLATE","NODENAME");
	return (status);
      }

     for (i = 0; i < strlen (host_node); ++i)
      {
        ch = tolower (host_node [i]);
        host_node [i] = ch;
      }

     /*  Find the internet address for the server node  */

     c_status = (char *) clh_vbyop (host_node, "ADDRESS", inet_addr, 40);
     if (c_status) inet_addr [0] =0;

     /*  Find the tcp address for the server node  */

     c_status = (char *) clh_vbyop (host_node, "tcp_address", tcp_addr, 40);
     if (c_status) tcp_addr [0] = 0;

     /*  Encrypt the server node properties  */

     if ((owned_file = fopen (file_name, "w")) == NULL)
      {
        status = NET_E_OPEN_FILENAME;
        ERRload_struct(NETS,status,"%s",file_name);
        return (status);
      }

     if (strlen (inet_addr))
      {
        fprintf (owned_file, "Address     : %s\n", inet_addr);
      }
 
     if (strlen (tcp_addr))
       fprintf (owned_file, "tcp_address : %s\n", tcp_addr);

     fprintf (owned_file, "Nodename    : %s\n", host_node);
     
     if (strlen (encr_user))
       fprintf (owned_file, "NETPROP1    : %s\n", encr_user);
     if (strlen (encr_pass))
       fprintf (owned_file, "NETPROP2    : %s\n", encr_pass);
     
     status = fclose (owned_file);
     if (status) /* OK */
      {
        status = NET_E_CLOSE_FILE;
        ERRload_struct(NETS,status,"%s",owned_file);
        return (status);
      }
    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }


_NFMenable_nfm_sql_debug (nfm_debug_flag, sql_debug_flag)
     long nfm_debug_flag, sql_debug_flag ;
{
  _NFMdebug_st.NFMdebug_on = nfm_debug_flag ;
  _NFMdebug_st.SQLdebug_on = sql_debug_flag ;
}

_NFMdisable_nfm_sql_debug (nfm_debug_flag, sql_debug_flag)
     long *nfm_debug_flag, *sql_debug_flag ;
{
  *nfm_debug_flag = _NFMdebug_st.NFMdebug_on ;
  *sql_debug_flag = _NFMdebug_st.SQLdebug_on ;
  _NFMdebug_st.NFMdebug_on = 0 ;
  _NFMdebug_st.SQLdebug_on = 0 ;
}

long _NFMdrop_tables ()
{
  char *fname = "_NFMdrop_tables" ;

  _NFMdebug ((fname, "ENTER\n")) ;
  SQLstmt ("drop table nfmaccess") ;
  SQLstmt ("drop table nfmacls") ;
  SQLstmt ("drop table nfmaclusers") ;
  SQLstmt ("drop table nfmactivity") ;
  SQLstmt ("drop table nfmarchives") ;
  SQLstmt ("drop table nfmattributes") ;
  SQLstmt ("drop table nfmcatalogaclmap") ;
  SQLstmt ("drop table nfmcatalogs") ;
  SQLstmt ("drop table nfmcatalogsamap") ;
  SQLstmt ("drop table nfmclasses") ;
  SQLstmt ("drop table nfmcommands") ;
  SQLstmt ("drop table nfmindex") ;
  SQLstmt ("drop table nfmlists") ;
  SQLstmt ("drop table nfmnodes") ;
  SQLstmt ("drop table nfmprocesses") ;
  SQLstmt ("drop table nfmprograms") ;
  SQLstmt ("drop table nfmprojectaclmap") ;
  SQLstmt ("drop table nfmprojectcit") ;
  SQLstmt ("drop table nfmprojects") ;
  SQLstmt ("drop table nfmprojectsamap") ;
  SQLstmt ("drop table nfmsafiles") ;
  SQLstmt ("drop table nfmsavesets") ;
  SQLstmt ("drop table nfmsetcit") ;
  SQLstmt ("drop table nfmsignoff") ;
  SQLstmt ("drop table nfmsignoffusers") ;
  SQLstmt ("drop table nfmstates") ;
  SQLstmt ("drop table nfmstoragearea") ;
  SQLstmt ("drop table nfmsysattributes") ;
  SQLstmt ("drop table nfmtables") ;
  SQLstmt ("drop table nfmtransitions") ;
  SQLstmt ("drop table nfmusers") ;
  SQLstmt ("drop table nfmvalues") ;
  SQLstmt ("drop table nfmworkflow") ;
  SQLstmt ("drop table nfmsyscat") ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     /* This code writes node information to file NFMser.dat, instead of
         writing to  file /usr/lib/nodes/owned/nfms_*. 
        SSRS - 9/11/93
     */
int NFMcreate_header_sun( str , ser_env_name, file_name )
char *str, *ser_env_name, *file_name;
{
        int    i;
        char   ch;
        char   *c_status;
        char   host_node[41];
        FILE   *owned_file, *fopen();
        int    status;
	 
        c_status = (char *) clh_vbyop ("TEMPLATE", "NODENAME", host_node, 40);
        if (c_status)
        {
	    status = NET_E_CLH_LOOKUP_FAILED;
	    ERRload_struct(NETS,status,"%s%s","TEMPLATE","NODENAME");
	    return (status);
        }

        for (i = 0; i < strlen (host_node); ++i)
        {
            ch = tolower (host_node [i]);
            host_node [i] = ch;
        }

        if ((owned_file = fopen (file_name, "a")) == NULL)
        {
            status = NET_E_OPEN_FILENAME;
            ERRload_struct(NETS,status,"%s",OWN_SERVER_FILE);
            return (status);
        }

	if( strcmp( str, "ser" ) == 0)
            fprintf(owned_file, "nfms_%s\1%s\1NFM\1\n", ser_env_name, host_node);
        else
            fprintf(owned_file, "nfme_%s\1NFM\1%s\1", ser_env_name, host_node);

         status = fclose(owned_file);
         if(status)
         {
             status = NET_E_CLOSE_FILE;
             ERRload_struct(NETS,status,"%s",owned_file);
             return (status);
         }
}

int del_ser_env(location, ser_env_name)
char *location;
char *ser_env_name;
{

        char temp_file_name[100];
        char env_file_name[100];
        char line[200];
        char line2[200];
        char cmd_str[100];
        char se_name[100];
        long status;
        FILE *temp_file,  *env_file,  *fopen();
        struct passwd *pwd;

        static char *fname = "del_ser_env";

        pwd = getpwnam( "nfmadmin" );
        
        if( strcmp(location, "owned") == 0 )
        {
            sprintf(temp_file_name, "/usr/tmp/%s", mktemp("TEMP1XXXXXX"));
            sprintf(env_file_name, "%s/%s/%s", pwd->pw_dir, ENV_PATH, OWNENV_FILE);
            sprintf(se_name, "nfme_%s", ser_env_name);
        }

        if( strcmp(location, "heard") == 0 )
        {
            sprintf(temp_file_name, "/usr/tmp/%s", mktemp("TEMP2XXXXXX"));
            sprintf(env_file_name, "%s/%s/%s", pwd->pw_dir, ENV_PATH, ENV_FILE);
            sprintf(se_name, "nfme_%s", ser_env_name);
        } 

        if( strcmp(location, "server") == 0 )
        {
            sprintf(temp_file_name, "/usr/tmp/%s", mktemp("TEMP3XXXXXX"));
            sprintf(env_file_name, "%s/%s/%s", pwd->pw_dir, ENV_PATH, SER_FILE);
            sprintf(se_name, "nfms_%s", ser_env_name);
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
                if( strcmp( line,  se_name) )
                {
                     fputs( line2,  temp_file);
                }
        }

        fclose(temp_file);
        fclose(env_file);

        sprintf(cmd_str,  "/bin/cp %s %s",  temp_file_name,  env_file_name);
        status = system(cmd_str);
        /*if (status <0)
          {
            _NFMdebug ((fname,  "Remove %s Failed\n",  ser_env_name));
            return (-1);
           } */

        unlink( temp_file_name );

        return(0);
}
#endif
