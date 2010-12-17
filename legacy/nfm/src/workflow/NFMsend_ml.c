#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "WF.h"

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;

/****************************************************************************
 *                                                                          *
 *   Function: NFMsend_mail.                                                *
 *   Date:     February 12, 1990                                            * 
 *                                                                          *
 *             This function is used to send notification mail to the       *
 *             users in the NFMacl and NFMsignoff tables.                   * 
 *                                                                          *
 *             This function will do the following:                         *
 *                  1.  Query to get all the distinct users and their       *
 *                      email addresses from tables NFMaclusers,            *
 *                      NFMsignoffusers and NFMusers for the acl number     *
 *                      specified in the WFinfo structure.                  *
 *                                                                          *
 *                  2.  Build the mail notification strings.                * 
 *                                                                          *
 *                  3.  Write the strings out to a temporary file.          * 
 *                                                                          *
 *                  4.  Call system to send the mail to the user(s).        * 
 *                                                                          *
 *             This function assumes that the n_emailaddress in the         *
 *             NFMusers table will contain the specific mail address        *
 *             string that has been set up for the system.                  *
 *                                                                          *
 *             Modified 4/11/90 to write the mail file out according to     *
 *             the WFentity.                                                *
 * 									    *
 *  Modified : 2/6/92                                                       *
 *  By       : Dudley Thomas                                                *
 *  Comments : Modified the mailaddress query to omit NFMSIGNOFFUSERS.      *
 *             See inline comments below.                                   * 
 *                                                                          *
 ****************************************************************************/

long NFMsend_mail (user_id, app_name, app_msg)
  long	  user_id;    /* user who caused the transition to occur.   I */ 
  char    *app_name;  /* name of the application.                   I */
  MSGptr  app_msg;    /*                                            I */
{
  static char *fname = "NFMsend_mail" ;
  FILE   *outfile, *fopen();
  long   status;
  long   SQLquery();
  long   MEMbuild_array(), MEMclose();
  int    x ;
  char   tempfile [L_tmpnam];
  char   **data;
  char   date[40];    
  char   successfail[8];    
  char   failreason[88];    
  char   sql_str[1024];
  char   *command;
  char   temp_str[256];
  MEMptr sql_buffer = NULL;

  _NFMdebug ((fname, "ENTER\n")) ;
  date[0] = 0; 
  successfail[0] = 0; 
  failreason[0] = 0; 

  /* Build the query string to get all the users email addresses. */

/* Commented by DT per BW 2/6/92 : User must be in ACL to do signoffs, this
   is no longer needed.

  sprintf (sql_str, 
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) AND (%s OR %s)",
           "DISTINCT NFMUSERS.n_emailaddr",
           "NFMUSERS, NFMACLUSERS, NFMSIGNOFFUSERS",
           "NFMACLUSERS.n_aclno", WFinfo.acl, 
           "NFMSIGNOFFUSERS.n_aclno", WFinfo.acl, 
           "NFMUSERS.n_userno = NFMACLUSERS.n_userno",
           "NFMUSERS.n_userno = NFMSIGNOFFUSERS.n_userno");

Replaced this query with the following:
*/

  sprintf (sql_str,
           "SELECT %s FROM %s WHERE %s = %d AND %s",
           "DISTINCT NFMUSERS.n_emailaddr",
           "NFMUSERS, NFMACLUSERS",
           "NFMACLUSERS.n_aclno", WFinfo.acl,
           "NFMUSERS.n_userno = NFMACLUSERS.n_userno");

  status = SQLquery (sql_str, &sql_buffer, 1024);
  if (status != SQL_S_SUCCESS) 
  {
     MEMclose (&sql_buffer);
     if (status  == SQL_I_NO_ROWS_FOUND)
     {
        _NFMdebug ((fname, "There are no notification users\n")) ;
        return (NFM_S_SUCCESS);
     }
     _NFMdebug ((fname, "SQLquery = <%d>\n", status));
     status = NFM_E_SQL_QUERY;
     ERRload_struct(NFM,status,"",NULL);
     return (status);
  }

  /* There are users to send notification mail to. */

  status = _WFget_error_info (successfail, failreason, app_msg);
  if (status != NFM_S_SUCCESS)
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "NFMtranslate_wf_struct = <%d>\n", status));
     return (status);
  }

  /* get the date and time. */

  status = NFMget_datetime (date) ;
  if (status != NFM_S_SUCCESS)
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "NFMget_date_time = <%d>\n", status));
     return (status);
  }


  /* open a temporary file to be used by mailx. */

  tmpnam (tempfile);
  if ((outfile = fopen (tempfile, "w")) == 0)  
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "Fopen failed\n")) ;
     status = NFM_E_OPEN_FILE;
     ERRload_struct(NFM,status,"",NULL);
     return (status);
  }

  /* Build the mail string and write it out to the file. */

  fprintf (outfile, "Environment     = <%s>\n", NFMglobal.environment_name);
  fprintf (outfile, "Command     = <%s>\n", WFinfo.command_name);

  if (WFinfo.entity [0] == 'N')
   {
     fprintf (outfile, "Transition  = <%s>\n", WFinfo.transition_name) ;
     fprintf (outfile, "Workflow    = <%s>\n", WFinfo.workflow_name);
     fprintf (outfile, "Acl         = <%s>\n", WFinfo.acl_name);
   }

  fprintf (outfile, "Executor    = <%s>\n", NFMglobal.NFMusername) ;
  fprintf (outfile, "Date        = <%s>\n", date);

      if(WFinfo.entity [0] == 'S')
      {
                fprintf (outfile, "Work Flow   = <%s>\n", WFinfo.workflow_name);
      }
      else if(WFinfo.entity [0] == 'A') 
      {
               if (WFinfo.acl > 0)
                 fprintf (outfile, "ACL         = <%s>\n", WFinfo.acl_name);

               if (WFinfo.catalog_no > 0)
                 fprintf (outfile, "Table Name  = <%s>\n", WFinfo.catalog_name);
      }
      else if(WFinfo.entity [0] == 'C') 
      {
                fprintf (outfile, "Catalog     = <%s>\n", WFinfo.catalog_name);
      }
      else if(WFinfo.entity [0] == 'P')
      {
                fprintf (outfile, "Project     = <%s>\n", WFinfo.proj_name);
      }
      else if(WFinfo.entity [0] == 'I')
      {      
                fprintf (outfile, "Project     = <%s>\n", WFinfo.proj_name);
                fprintf (outfile, "Catalog     = <%s>\n", WFinfo.catalog_name);
                fprintf (outfile, "Item Name   = <%s>\n", WFinfo.item_name);
                fprintf (outfile, "Item Rev    = <%s>\n", WFinfo.item_rev);
      }
      else if(WFinfo.entity [0] == 'N')

  fprintf (outfile, "Prev State  = <%s>\n", WFinfo.current_statename) ;
  fprintf (outfile, "New State   = <%s>\n", WFinfo.next_statename) ;
  fprintf (outfile, "Application = <%s>\n", app_name);
  if (successfail[0] != '0') 
  {
     fprintf (outfile, "Status      = <%s>\n", "Failure");
     fprintf (outfile, "Fail Reason = <%s>\n", failreason);
  } 
  else
  {
     fprintf (outfile, "Status      = <%s>\n", "Successful");
  }

  fclose (outfile);

  status = MEMbuild_array (sql_buffer);
  if (status != MEM_S_SUCCESS)
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "MEMbuild_array = <%d>\n", status));
     status = NFM_E_MEM;
     ERRload_struct(NFM,status,"",NULL);
     return (status);
  }
  
  if (sql_buffer->rows < 1)
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "sql_buffer->rows = <%d>\n", sql_buffer->rows));
     return (NFM_S_SUCCESS);
  }

  data = (char **) sql_buffer -> data_ptr;

  command = (char *) malloc (sql_buffer->rows * MEM_SIZE); 
  if (!command)
  {
     MEMclose (&sql_buffer);
     status = NFM_E_MALLOC;
     ERRload_struct(NFM,status,"",NULL);
     _NFMdebug ((fname, "Malloc Failed = <%d>\n", status));
     return (status);
  }


  /* As 'mailx' is not available on SUN ,  it is replaced by 'mail' for SUN.
     SSRS - 17/11/93
  */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX))
  sprintf (command,  "mail -s \"%s\" \"%s\"",  "NFM Mail Notification", 
              data[0]);
#else
  sprintf (command, "mailx -s \"%s\" \"%s\"", "NFM Mail Notification",
              data[0]);  

#endif

  for (x = 1; x < sql_buffer -> rows; ++x)
  {
     sprintf (temp_str, ", \"%s\"", data[x]);  
     strcat  (command, temp_str);
  }

  sprintf (temp_str, " < %s > /dev/null 2>&1 ", tempfile); 
  strcat (command, temp_str);


#ifdef OS_UNIX
  strcat (command, "&");  /* run the process in the background. */
#endif

  _NFMdebug ((fname, "Command Str = <%s> ", command));

  /* Call system to send the mail to each user. */

  status=NFMsystem_imm (command); 
  if(status != NFM_S_SUCCESS)
  {
        _NFMdebug((fname, "NFMsystem failed status <0x%.8x>\n",status));
	return(status);
  }
  free (command);

  MEMclose (&sql_buffer);

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

