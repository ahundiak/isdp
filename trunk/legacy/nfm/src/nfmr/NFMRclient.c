#include "machine.h"
#include "NFMRextern.h"
#include "NFMRformats.h"
#include <sys/utsname.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>

#include "NFMporttypes.h"

long NFMRget_host_info (user_id, logon)
  long user_id ;
  int  logon ;
{
  int    pid ;
  int    uid;
  long   clock, status ;
  struct utsname ut_name ;
  struct tm *cur_tm ;
  struct passwd  *pswd_ptr; 
  char   ret_date[20], ret_time[20] ;
  char   date_str[50] , time_str[50], value[100] ;
  char   *unix_user, *path, u_user[50], pathname[50], nodename[50] ;

  static char *fname = "NFMRget_host_info";

  _NFMRdebug(( fname, "%s\n", "Entering" ));

  /* get template for date_type and time_type */

  sprintf (date_str, "%s", "%D") ;
  sprintf (time_str, "%s", "%T") ;

  /* get current date and time of machine running this program */
  clock = time ((long *) 0) ;
  
  if (clock == -1)
    {
      _NFMRdebug(( fname, "%s\n", "clock == -1")) ;
      return (NFM_E_FAILURE);
    }
  
  cur_tm = localtime (&clock);
  
  value [0] =0;

#ifdef OS_CLIX
  status = ascftime (value,  date_str,  cur_tm);
#else
/******** Year 2000 Fixes - Ravi 30-May-1998 *******/
/*
  status = strftime (value,  100,  date_str,  cur_tm);
*/
  status = strftime (value,  100,  "%m/%d/%Y",  cur_tm);
/* End of Year 2000 Fixes */
#endif
 
  if (status < 8)
    {
     return (NFM_E_FAILURE) ;
    }

  /*sprintf (ret_date, "%-10.10s", value);*/
  sprintf (ret_date, "%-10.10s", value);
  
  value [0] =0;

#ifdef OS_CLIX
  status = ascftime (value,  time_str,   cur_tm);
#else
  status = strftime (value,  100,  time_str,  cur_tm);
#endif

  if (status < 8)
    {
      return (NFM_E_FAILURE) ;
    }
  
  sprintf (ret_time, "%-8.8s", value);
  
  _NFMRdebug(( fname, "Date %s\n", ret_date));
  _NFMRdebug(( fname, "Time %s\n", ret_time));
  
  /* get host name of current machine */
  status = uname (&ut_name) ;
  if (status == -1)
    {
      _NFMRdebug(( fname, "%s\n", "uname status == -1"));
      return (NFM_E_FAILURE);
    }

  _NFMRdebug(( fname, "Node <%s>\n", ut_name.nodename));
  
  /* get username */
  unix_user = (char *) getlogin () ;
  if (unix_user == NULL)
    {
    pswd_ptr = getpwuid ((NFM_UID_T)(uid=getuid ()));
    /* pswd_ptr = getpwuid (uid=getuid ()); KMM 10 Dec 93. */
    if (pswd_ptr)
      {
        unix_user = (char*)malloc (strlen( pswd_ptr -> pw_name)+1);
	strcpy( unix_user, pswd_ptr->pw_name );
      }
    else
      {
        _NFMRdebug(( fname, "%s\n", "unix_user == NULL"));
        return (NFM_E_FAILURE);
      }
    }

  _NFMRdebug(( fname, "Unix User <%s>\n", unix_user));
  
  /* get process id */
  /* pid = (int) getpid () ; KMM 10 Dec 93. */
 pid = (NFM_PID_T) getpid () ;
  
  _NFMRdebug(( fname, "Pid <%d>\n", pid));

  /*  pathname */
  path = (char *) getcwd ((char *) NULL, 80) ;
  if (path == NULL)
    {
      _NFMRdebug(( fname, "%s\n", "NFMRget_host_info : path == NULL"));
      return (NFM_E_FAILURE);
    }
  
  _NFMRdebug(( fname, "Path : %s\n", path));

  strcpy (nodename, ut_name.nodename) ;
  strcpy (u_user, unix_user) ;
  strcpy (pathname, path) ;

  status = NFMRclient_info (user_id, ret_date, ret_time, nodename,
                            u_user, pid, pathname, logon );
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && \
     !defined(OS_SCO_UNIX) && !defined(OS_HPUX))
  /* For SUN/SCO this results in a memory fault in Nfmalpha - SSRS 16 Feb 94 */
  free (path) ;
#endif

  if (status != NFM_S_SUCCESS)
      return (status);

  return (NFM_S_SUCCESS) ;
}

NFMRclient_info (user_id, ret_date, ret_time, nodename,
                      unix_user, pid, pathname, connect_on )
long    user_id ;
char    *ret_date ;
char    *ret_time ;
char    *nodename ;
char    *unix_user ;
int     pid ;
char    *pathname ;
int     connect_on ;
{

  MEMptr       info = NULL ;
  char         str [1024];
  long         status = 0;
  long         ret_status = 0;
  char         id[20], s_pid[10] ;
  char         connect[5] ;
  struct       stat buf;
  char	       **data_ptr;
  
  static       char *fname = "NFMRclient_info";

  _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
  _NFMRdebug(( fname, "date     : <%s>\n", ret_date));
  _NFMRdebug(( fname, "time     : <%s>\n", ret_time));
  _NFMRdebug(( fname, "nodename : <%s>\n", nodename));
  _NFMRdebug(( fname, "unix user: <%s>\n", unix_user));
  _NFMRdebug(( fname, "pid      : <%d>\n", pid));
  _NFMRdebug(( fname, "pathname : <%s>\n", pathname));
  _NFMRdebug(( fname, "connect  : <%d>\n", connect_on));

  NFMRglobal.date_format = 0;
  NFMRglobal.override    = 0;

  status = MEMopen (&info, 1024);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }
  
  status = MEMwrite_format (info, "user_id", "char(20)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }
  
  status = MEMwrite_format (info, "date", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }
  
  status = MEMwrite_format (info, "time", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }
  
  status = MEMwrite_format (info, "nodename", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }

  status = MEMwrite_format (info, "unix_user", "char(20)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }

  status = MEMwrite_format (info, "pid", "char(15)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }

  status = MEMwrite_format (info, "pathname", "char(15)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }

  status = MEMwrite_format (info, "connect", "char(4)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }

  sprintf (id, "%ld", user_id) ;
  sprintf (s_pid, "%d", pid) ;
  if (connect_on) strcpy (connect, "ON") ;
      else strcpy (connect, "OFF") ;
  
  strcpy (str, id) ;
  strcat (str, "\1") ;
  strcat (str, ret_date) ;
  strcat (str, "\1") ;
  strcat (str, ret_time) ;
  strcat (str, "\1") ;
  strcat (str, nodename) ;
  strcat (str, "\1") ;
  strcat (str, unix_user) ;
  strcat (str, "\1") ;
  strcat (str, s_pid) ;
  strcat (str, "\1") ;
  strcat (str, pathname) ;
  strcat (str, "\1") ;
  strcat (str, connect) ;
  strcat (str, "\1") ;
  
  status = MEMwrite (info, str);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
      return (NFM_E_MEM);
    }
  

  status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CLIENT_INFO, info);
  _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&info);
      return (status);
    }
  
  MEMclose (&info);
  
  status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
  _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&info);
      return (status);
    }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    NFMRglobal.administrator = atol( data_ptr[0] );
    NFMRglobal.query_rows    = atol( data_ptr[1] );
    NFMRglobal.do_not_register_PDM   = atol( data_ptr[2] );

    _NFMRdebug(( fname, "administrator : <%ld>\n",NFMRglobal.administrator ));
    _NFMRdebug(( fname, "block rows    : <%ld>\n",NFMRglobal.query_rows ));
    _NFMRdebug(( fname, "do not register PDM  : <%ld>\n", 
			NFMRglobal.do_not_register_PDM));  
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    MEMclose (&info);

    return( NFM_S_SUCCESS );
}
