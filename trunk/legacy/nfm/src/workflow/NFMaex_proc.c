
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <pwd.h>
#include <errno.h>
#include <UMS.h>
#include "WF.h"

int post_exec_stat;
extern int errno;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;
/******************************************************************************
                                                                          
    Function: NFMpost_execute_process.                                    
    Date:     January 23, 1990                                             
    Modified: January 30, 1990                                             
                                                                          
              This function is used to call vfork and exec to execute     
              the process referenced by program_name.  

              1.  Query to get all the programs associated with the   
		  transition.
                                                 
              2.  Call NFMget_program_filename to get the absolute        
                  filename of the process (for each row returned from     
                  the query).                                             
                                                                          
              3.  execute the process (for each row returned from the     
                  query).                                                    
                                                                          
    Modified: January 3 1991  
    By. Reddy Velagala
               
               4.  processes are now executed using shared memory to 
                   provide context information 

    Modified: December 5, 1991
    By: Dudley Thomas
 
 	      5.  5. Processes no longer use shared memory to communicate.
                  All information required by the process is passed via
                  command line arguments. Added "app_ptr" to input arguments.  
		  The command status is derived using the error number contained
		  in the app_ptr and a UMS call. Status will be set to one of 
		  the following:
                        S - Command was successful,
                        I - Command generated an informational message,
                        W - Command generated a warning message,
                        E - Command was not successful.
                  The process is executed regardless of the command status.
                  If the process terminates unexpectedly or exits with a
                  non-zero status, an error or informational message will
                  loaded into the global error structure unless the command
                  has already utilized this structure. If the command was
                  not successful, this function will not write to the error
                  buffer.  This would overwrite the message loaded by the
                  command. NFM error messages take precedance over process
                  on transition messages.  
 
*******************************************************************************/

long NFMpost_execute_process (trans_no, app_ptr)
  long          trans_no;
  MSGptr        app_ptr;
{
  static char  *fname = "NFMpost_execute_process" ; 	/* Used for debug */
  int          pstatus;         /* Process status */
  int          exit_status;     /* Process status */
  long         status;		/* Current status of operations */
  long         SQLquery ();
  long         MEMbuild_array(), MEMclose();
  int          process;		/* Returned from vfork() */
  int          x, n;		/* Counters */
  char         sql_str[512];	/* SQL string */
  char         file_name[128];  /* Encrypted program filename */
  char 	       command_status[20]; 	/* S, W, I, or E */
  char 	       d_sch_name[100];		/* Decrypted schema name */
  char 	       d_sch_pass[100];		/* Decrypted schema passwd */
  char         **data;
  char         path_name [301];
  struct passwd *pw_entry;
  MEMptr       process_buffer = NULL; 

  _NFMdebug ((fname, "transition no. = <%d> ", trans_no));

  sprintf (sql_str, "%s, %s.%s, %s %s.%s = %d %s.%s = '%s' %s.%s = %s %s.%s",
           "SELECT NFMPROGRAMS.n_programname", "NFMPROCESSES", "n_seqno",
           "NFMPROGRAMS.n_programfile",
           "FROM NFMPROCESSES, NFMPROGRAMS WHERE NFMPROCESSES",
            "n_transitionno", trans_no, "AND NFMPROCESSES", "n_prepost", "A", 
            "AND NFMPROCESSES", "n_programno", "NFMPROGRAMS.n_programno",
            "ORDER BY NFMPROCESSES", "n_seqno");  

  status = SQLquery (sql_str, &process_buffer, 512);
  if (status != SQL_S_SUCCESS)
  {
     MEMclose (&process_buffer);
     if (status == SQL_I_NO_ROWS_FOUND)  return (NFM_S_SUCCESS);
     _NFMdebug ((fname, "SQLquery = <0x%.8x> ", status));
     ERRload_struct(NFM,NFM_E_SQL_QUERY,"",NULL);
     return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (process_buffer); 
  if (status != MEM_S_SUCCESS) 
  {
     MEMclose (&process_buffer);
     _NFMdebug ((fname, "MEMbuild_array = <0x%.8x> ", status));
     ERRload_struct(NFM,NFM_E_MEM,"",NULL);
     return (NFM_E_MEM);
  }

  data = (char **) process_buffer -> data_ptr;

  
  /* Find path to SYSTEM directory */

  pw_entry = getpwnam ("nfmadmin");
  if (pw_entry == NULL)
  {
      _NFMdebug ((fname, "Cannot access local passwd file\n"));
      ERRload_struct(NFM, NFM_E_FAILURE, "%s%s",
               "Load Program", "Cannot access passwd file");
      return (NFM_E_FAILURE);
  }

  sprintf (path_name, "%s/%s/%s", pw_entry->pw_dir, NFMglobal.environment_name,
	   "system");

  /* Decrypt the schema name and password */
    
  NFMdecrypt (NFMglobal.NFMsch_name, d_sch_name);
  NFMdecrypt (NFMglobal.NFMsch_passwd, d_sch_pass);

  _NFMdebug((fname, "SCHEMA NAME : <%s>\n",d_sch_name));
  _NFMdebug((fname, "SCHEMA PASS : <%s>\n",d_sch_pass));


  /* Determine command status from current error number. */

  status = UMSMsgCode (command_status, app_ptr.error_no,
                UMS_SUPPRESS_COMP|UMS_SUPPRESS_EXT,NULL,NULL,NULL);
  if (status != UMS_S_SUCCESS)
  {
     /* If UMS errors, default the command status to SUCCESS. */

     _NFMdebug ((fname,"UMS Error : status = <0x%.2x>\n",status));
     command_status[0] = 'S';
     command_status[1] = '\0';
  }

  _NFMdebug ((fname, "Command Status = <%s>\n",command_status));


  /* Execute each process assigned to this transaction */ 

  for (x = 0; x < process_buffer -> rows; ++x)
  {
     post_exec_stat = 0;
     n = x * process_buffer -> columns;

     sprintf (file_name,"%s/%s", path_name, data[n+2]);

     _NFMdebug ((fname, "file_name = <%s> ", file_name));

     /* execute the process. */

     pstatus = 0;
#ifdef OS_SCO_UNIX
     /* vfork() not available on SCO. Replacding it by fork().
        SSRS 31 Jan 94 
     */
     process = fork ();
#else
     process = vfork ();
#endif

     if (process > 0)         /* parent */
         wait (&pstatus);

     else if (process == 0)   /* child */
     {
         /* execute process */

         /* execlp can be used to execute shell scripts */
         /* as well as binary executable files. */ 

	 execlp (file_name, file_name, d_sch_name, d_sch_pass,
                command_status, WFinfo.command_name, NFMglobal.NFMusername,
                WFinfo.catalog_name, WFinfo.item_name, WFinfo.item_rev,
                WFinfo.current_statename, (char *)0);

         /* If execlp returns, a problem has occured.  Set the global variable
            post_exec_stat so that the parent process can detect this situation.
            The parent process cannot depend solely on the global variable
            "errno" because errno is set to "ENOEXEC" upon successful
            execution of a shell script.  This is because somewhere below the
            execlp() level, some function is expecting the a.out header format
            in the process to be executed, in this case, a shell script. */

         post_exec_stat = errno;
         _exit(0);
     }
     else if (process == 1)     /* can't create process. */
     {
         status = NFM_E_FORK; /* needs to be changed to cannot fork. */
         _NFMdebug ((fname, "Cannot fork : status = <0x%.8x>\n", status));
	 ERRload_struct(NFM,NFM_E_FORK,"",NULL);
         _exit ();              /*  flush buffered output. */
         MEMclose (&process_buffer);
         return (status);
     } 

     /* Determine status of operation. Report accordingly. */
     
     if (post_exec_stat)
     {
        /* Execl failed. Determine why. Set status, load error message, and
           return. */
        switch(errno)
        {
           case EACCES:
               status = NFM_W_NO_PERMISSION;
               _NFMdebug ((fname,
                    "No execute permission for <%s:%s> : status = <0x%.8x>\n",
                     data[n],file_name, status));
               ERRload_struct(NFM,status,"%s%s",data[n],file_name);
               break;
           case ENOENT:
               status = NFM_W_NO_PROC;
               _NFMdebug((fname,"Process <%s:%s> does not exist.\n", 
					data[n],file_name));
               ERRload_struct(NFM,status,"%s%s",data[n], file_name);
               break;
           default:
               status = NFM_W_BAD_PROGRAM;
               _NFMdebug((fname,
                      "Attempt to execute <%s> failed : execlp status <%d>\n",
                       file_name, post_exec_stat));
               ERRload_struct(NFM,status,"%s",file_name);
               break;
        };
        MEMclose (&process_buffer);
        _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
        return(status);
     }
     else
     {
        /* Execl was successful. */
        /* If pstatus is non-zero, the process did not complete successfully.
           Determine why.  There are three scenarios; (1) process stopped,
           (2)process terminated, (3)process exited with non-zero status. */ 
       
        if (WIFEXITED(pstatus))
        {
           /* Normal Termination. If exit status was not zero, abort
              command without executing any other processes, if they
              exist. */ 
             
           exit_status = WEXITSTATUS(pstatus);
           if (exit_status == 0)
           {
              _NFMdebug ((fname,
                  "Successful Completion of process <%s>\n", file_name));
           }
           else
           {
              status = NFM_W_PROC_EXIT;
              _NFMdebug ((fname,
                        "Process <%s> exited non-zero : exit status = <%d>\n",
                          data[n], exit_status));
              if (command_status[0] == 'S')
                  ERRload_struct(NFM, status, "%s%d", data[n], exit_status);
              MEMclose(&process_buffer);
              _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
              return(status);
           } 
        }
        else if (WIFSIGNALED(pstatus))
        {
           exit_status = WTERMSIG(pstatus);
           status = NFM_W_POST_PROC;
           _NFMdebug ((fname,
                  "EXECUTE PROCESS : Process terminated : signal = <%d>\n",
                   exit_status));
           if (command_status[0] == 'S')
              ERRload_struct(NFM, status, "%s%d", data[n], exit_status);
           MEMclose(&process_buffer);
           _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
           return(status);
        }
        else if (WIFSTOPPED(pstatus))
        {
           exit_status = WSTOPSIG(pstatus);
           status = NFM_W_POST_PROC;
           _NFMdebug ((fname,
                  "EXECUTE PROCESS : Process stopped : signal = <%d>\n",
                   exit_status));
           if (command_status[0] == 'S')
               ERRload_struct(NFM, status, "%s%d", data[n], exit_status);
           MEMclose(&process_buffer);
           _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
           return(status);
        } 

     } /* if post_exec_stat */
    
  }  /* for */

  MEMclose (&process_buffer);
  process_buffer = NULL;
  _NFMdebug ((fname, 
  "EXECUTE PROCESS : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS)); 
  return (NFM_S_SUCCESS); 
}

long NFMget_context_info(bufr,WFinfo)
MEMptr	*bufr;
struct WFstruct WFinfo;
{
  static char *fname = "NFMget_context_info" ;
	char    sql_str[200];
	long	status;
        long    SQLquery ();

  _NFMdebug ((fname, "ENTER\n")) ;
  sprintf(sql_str,"SELECT * FROM %s WHERE n_itemno = %d",
  WFinfo.catalog_name,WFinfo.item_no);
  status = SQLquery(sql_str,bufr,512);
  if(status != SQL_S_SUCCESS)
  {
	_NFMdebug ((fname, "SQLquery failed <0x%.8x>\n",status));
	status = NFM_E_SQL_QUERY;
	ERRload_struct(NFM,status,"",NULL);
	return(status);
  }
  _NFMdebug ((fname, "SUCCESSFUL\n"));
  return(NFM_S_SUCCESS);
}
