
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <pwd.h>
#include <errno.h>
#include "WF.h"

int pre_exec_stat;
extern int errno;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;

/***************************************************************************
 *                                                                         *
 *   Function: NFMpre_execute_process.                                     *
 *   Date:     January 23, 1990                                            * 
 *   Modified: December 6, 1991                                            * 
 *                                                                         *
 *             This function is used to call vfork and exec to execute     *
 *             the process referenced by program_name.                     *
 *                                                                         *
 *             1.  Query to get all the programs associated with the       *
 *                 transition.                                             *
 *                                                                         *
 *             2.  Call NFMget_program_filename to get the absolute        *
 *                 filename of the process (for each row returned from     *
 *                 the query).                                             *
 *                                                                         *
 *             3.  execute the process (for each row returned from the     *
 *                 query).                                                 *   
 *                                                                         *
 *    Modified : Jan 3 1991                                                *
 *    By: Reddy Velagala                                                   *
 *                                                                         *
 *             4. processes are now executed using shared memory to        *    
 *		  communicate contextual information                       *
 *     									   *
 *    Modfified : Dec 06, 1991                                             *
 *    By: Dudley Thomas						           *	
 *                                                                         *
 *             5. Processes no longer communicate using shared memory.     *
 *                All information required by the process is passed        *
 *                via command line arguments. Command status is defaulted  *
 *                to 'S'. The command is aborted is the process does not   *
 *	          complete successfully or exit(0).                        * 
 **************************************************************************/

long NFMpre_execute_process (trans_no)
  long          trans_no;
{
  static char  *fname = "NFMpre_execute_process" ; 	/* Used for debug */
  int          pstatus;			/* Process status */
  int          exit_status;		/* Process status */
  long         status;			/* Current status of operations */
  long         SQLquery ();
  long         MEMbuild_array(), MEMclose();
  int          process;			/* Returned from vfork() */
  int          x, n;			/* Counters */
  char         sql_str[512];		/* SQL string */
  char         file_name[128];		/* Encrypted program filename */
  char         d_sch_name[100];		/* Decrypted schema name */
  char         d_sch_pass[100];		/* Decrypted schema pass */
  char         **data;
  char         path_name [301];
  struct passwd *pw_entry;
  MEMptr       process_buffer = NULL; 

  _NFMdebug ((fname, "transition no. = <%d> ", trans_no));


  /* Query to get all the processes associated with the transition. */

  sprintf (sql_str, "%s, %s.%s, %s %s.%s = %d %s.%s = '%s' %s.%s = %s %s.%s",
           "SELECT NFMPROGRAMS.n_programname", "NFMPROCESSES", "n_seqno",
           "NFMPROGRAMS.n_programfile",
           "FROM NFMPROCESSES, NFMPROGRAMS WHERE NFMPROCESSES",
           "n_transitionno", trans_no, "AND NFMPROCESSES", "n_prepost", "B", 
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

  /* Decrypt the schema name and passwd */

  NFMdecrypt (NFMglobal.NFMsch_name, d_sch_name);
  NFMdecrypt (NFMglobal.NFMsch_passwd, d_sch_pass);
    
  _NFMdebug ((fname, "SCHEMA NAME : <%s>\n", d_sch_name)); 
  _NFMdebug ((fname, "SCHEMA PASS : <NOT PRINTED>\n")); 

  
  /* Execute each process assigned to this transition */

  for (x = 0; x < process_buffer -> rows; ++x)
  {
      pre_exec_stat = 0;
      n = x * process_buffer -> columns;

      sprintf(file_name, "%s/%s", path_name, data[n+2]);

      _NFMdebug ((fname, "file_name = <%s>\n", file_name));

      /* Check to insure that the executable file exists on this node.  If not, 
	 do not continue. */ 

      /* execute the process. */

      pstatus = 0;
#ifdef OS_SCO_UNIX
      /* vfork() not available on SCO. Replacing it by fork().
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
          /* as well binary executable files */

          execlp (file_name, file_name, d_sch_name, d_sch_pass,  "S", 
		WFinfo.command_name, NFMglobal.NFMusername, WFinfo.catalog_name,
		WFinfo.item_name, WFinfo.item_rev, WFinfo.current_statename, 
		(char *)0);  

          /* If execlp returns, a problem has occured.  Set the global variable
             pre_exec_stat so that the parent process can detect this situation.
             The parent process cannot depend solely on the global variable
             "errno" because errno is set to "ENOEXEC" upon successful 
	     execution of a shell script.  This is because somewhere below the 
	     execlp() level, some function is expecting the a.out header format 
	     in the process to be executed, in this case, a shell script. */

          pre_exec_stat = errno;
          _exit(0);
      }
      else if (process == -1)     /* can't create process. */
      {
          status = NFM_E_FORK;
          _NFMdebug ((fname,
               "EXECUTE PROCESS : Cannot fork : status = <0x%.8x>\n", status)); 
          ERRload_struct(NFM,status,"",NULL);
          return (status);
      } 


      /* Determine status of operation. Report accordingly. */

      if (pre_exec_stat)
      {
          /* Execl failed. Determine why. Set status, load error message, and
             return. */
          switch(errno)
          {
             case EACCES:
                 status = NFM_E_NO_PERMISSION;
                 _NFMdebug ((fname, 
	            "No execute permission for <%s> : status = <0x%.8x>\n", 
                     file_name, status));
	         ERRload_struct(NFM,status,"%s%s",file_name, data[n]);
                 break;
             case ENOENT:
                 status = NFM_E_NO_PROC;
                 _NFMdebug((fname,"Process <%s> does not exist.\n",
								file_name));
                 ERRload_struct(NFM,status,"%s%s",file_name,data[n]);
                 break;
             default:
                 status = NFM_E_BAD_PROGRAM;
                 _NFMdebug((fname,
			"Attempt to execute <%s> failed : execlp status <%d>\n",
			 file_name, pre_exec_stat));
                 ERRload_struct(NFM,status,"%s",data[n]);
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
                   status = NFM_E_PROC_EXIT;
                   _NFMdebug ((fname,
	                 "Process <%s> exited non-zero : exit status = <%d>\n",
	                  data[n], exit_status));
                   ERRload_struct(NFM, status, "%s%d", data[n], exit_status); 
                   MEMclose(&process_buffer);
                   _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
                   return(status);
                }
           }
           else if (WIFSIGNALED(pstatus))
           {
               exit_status = WTERMSIG(pstatus);
               status = NFM_E_PRE_PROC;
               _NFMdebug ((fname,
	          "EXECUTE PROCESS : Process terminated : signal = <%d>\n",
	           exit_status));
               ERRload_struct(NFM, status, "%s%d", data[n], exit_status); 
               MEMclose(&process_buffer);
               _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
               return(status);
           }
           else if (WIFSTOPPED(pstatus))
           {
               exit_status = WSTOPSIG(pstatus);
               status = NFM_E_PRE_PROC;
               _NFMdebug ((fname,
	          "EXECUTE PROCESS : Process stopped : signal = <%d>\n",
	           exit_status));
               ERRload_struct(NFM, status, "%s%d", data[n], exit_status); 
               MEMclose(&process_buffer);
               _NFMdebug((fname, "Exiting : status <0x%.8x>\n", status));
               return(status);
           }

       } /* if pre_exec_stat */

  }  /* for */

  MEMclose (&process_buffer);
  process_buffer = NULL;
  _NFMdebug ((fname, 
        "EXECUTE PROCESS : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS)); 
  return (NFM_S_SUCCESS); 
}

