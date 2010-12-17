#include "machine.h"
#include "NFMU.h"
#include <time.h>

#ifdef OS_SOLARIS
/* Added becasue 'execlp' on SysV needs this - SSRS - 9/12/93 */
#include <unistd.h>
#endif

#include <signal.h>

extern struct NFMglobal_st NFMglobal ;
char NFM_DM_NODENAME[NFM_NODENAME+1];
extern long DM_MANAGER;
extern long PDMVAULT_DONT_TYPE_SET;
extern long NFM_FTR_INITED;
static long log_file_entry=0;


long NFMclient_info (item_list, admin_flag, query_rows, miscInfo)
     MEMptr    item_list;
     long      *admin_flag ;
     long      *query_rows ;
     long      *miscInfo ;
   {
     static char *fname = "NFMclient_info" ;
     long    status ;
     int     x, pid, pid2 ;
     int     PDM_flag = 0;
     int     FTR_flag = 0;
     long    NFMget_server_info () ;
     long    NFMget_NFM_version () ;
     char    **column, **data ;
     char    cl_date[20], cl_time[20], cl_pid[20] ;
     char    cl_path[20], cl_node[20], cl_unix_user[20], cl_conn[5] ;
     char    ret_date[20], ret_time[20] ;
     char    *NFMmonitor_path="/usr/ip32/nfm/bin/NFMmonitor";

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (item_list);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "Build Array : status = <%d>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) item_list -> column_ptr;
     data   = (char **) item_list -> data_ptr;

     
     for (x = 0; x < item_list -> columns; ++x)
       {
	 if (! strcmp (column [x], "date"))
	   strcpy (cl_date, data [x]) ;
	 else if (! strcmp (column [x], "time"))
	   strcpy (cl_time, data [x]) ;
	 else if (! strcmp (column [x], "nodename"))
	   strcpy (cl_node, data [x]) ;
	 else if (! strcmp (column [x], "unix_user"))
	   strcpy (cl_unix_user, data [x]) ;
	 else if (! strcmp (column [x], "pid"))
	   strcpy (cl_pid, data [x]) ;
	 else if (! strcmp (column [x], "pathname"))
	   strcpy (cl_path, data [x]) ;
	 else if (! strcmp (column [x], "connect"))
	   strcpy (cl_conn, data [x]) ;
       }

     status = NFMget_server_info (ret_date, ret_time, &pid)  ;
     if (status != NFM_S_SUCCESS) 
       {
        _NFMdebug ((fname, "Get Server Info : status = <%d>\n", status));
        return (status);
       }

     strcpy (NFM_DM_NODENAME, cl_node);
   
     if(log_file_entry == 0 )
     {
      log_file_entry++;
      _SER_str ("\nClient : Node Name %s", cl_node) ;
      _SER_str ("Date %s", cl_date) ;
      _SER_str ("Time %s", cl_time) ;
      _SER_str ("PID %s",  cl_pid) ;
      _SER_str ("Path %s", cl_path) ;
      _SER_str ("Status %s", cl_conn) ;
       if(DM_MANAGER)
               _SER_str ("ClientId %s","DMMGR");
       else
               _SER_str ("ClientId %s","NFM");

      _SER_str ("\nServer : Date %s", ret_date) ;
      _SER_str ("Time %s", ret_time) ;
      _SER_num ("Pid %d\n",  pid) ;
     

     	if(DM_MANAGER)
	{
      		status = NFMsystem(NFMmonitor_path);
      		if(status != NFM_S_SUCCESS)
      		{
			_NFMdebug((fname,"Cannot start NFMmonitor process: status : <0x%.8x>\n",status));
      		}
	}

      }
     /* The following returns values to DM/Manager about PDM and FTR.
      * If the return value (*miscInfo) is :
	  0 - don't register PDM sets and no FTR engine running 
	  1 - register PDM sets and no FTR engine running 
	  2 - don't register PDM sets and FTR engine running
	  3 - register PDM sets and FTR engine running
      */
     if (NFM_FTR_INITED == 1)
	FTR_flag = 2;
     if (PDMVAULT_DONT_TYPE_SET == 0)
	PDM_flag = 1;
     *miscInfo = PDM_flag + FTR_flag;
     NFMglobal.do_not_register_PDM = *miscInfo;
     *admin_flag = NFMglobal.administrator ;
     *query_rows = NFMglobal.query_rows ;

     _NFMdebug ((fname, "SUCCESSFUL : admin_flag %d : query rows %d : misc info %d\n", *admin_flag, *query_rows, *miscInfo )) ;
     return (NFM_S_SUCCESS);
   }

long NFMget_server_info (ret_date, ret_time, pid) 
    char *ret_date, *ret_time ;
    int  *pid ;
{
  static char *fname = "NFMget_server_info" ;
  long   clock ;
  struct tm *cur_tm ;

  _NFMdebug ((fname, "ENTER\n")) ;
  clock = time ((long *) 0);
  if (! clock)
    {
      _NFMdebug ((fname, "System call to clock failed\n")) ;
      ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "clock") ;
      return (NFM_E_SYSTEM_CALL) ;
    }
  
  cur_tm = localtime (&clock);
  if (cur_tm == NULL)
    {
      _NFMdebug ((fname, "System call to localtime failed\n")) ;
      ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "cur_tm") ;
      return (NFM_E_SYSTEM_CALL) ;
    }

/******************************************************************************
/* Year 2000 Fixes - Ravi 30 May 1998
/* Replacing 2 digit year with 4 digit year.
/* Adding 1900 to tm_year.
/* Print format changed from .2d to .4d for tm_year.
******************************************************************************/ 
/*
  sprintf (ret_date, "%.2d/%.2d/%.2d",
	   cur_tm->tm_mon+1, cur_tm->tm_mday, cur_tm->tm_year) ;
*/

  sprintf (ret_date, "%.2d/%.2d/%.4d",
	   cur_tm->tm_mon+1, cur_tm->tm_mday, cur_tm->tm_year + 1900) ;

/* End of Year 2000 Fixes */
  
  sprintf (ret_time, "%.2d:%.2d:%.2d",
	   cur_tm->tm_hour, cur_tm->tm_min, cur_tm->tm_sec) ;
  
  _NFMdebug ((fname, "DATE %s : TIME %s\n",
	      ret_date, ret_time)) ;
  
  /* get process id */
  *pid = (int) getpid () ;
  
  _NFMdebug ((fname, "Pid <%d>\n", *pid));
  return (NFM_S_SUCCESS) ;
}

