#include "machine.h"
#include <string.h>
#include "WF.h"

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;

/****************************************************************************
 *                                                                          *
 *   Function: NFMadd_activity_entry.                                       *
 *   Date:     February 7, 1990                                             * 
 *                                                                          *
 *             This function is used to add a row to the activity table.    *
 *                                                                          *
 *             This function will do the following:                         *
 *                  1.  Convert the WFinfo values to there names.           *
 *                  2.  build the Insert statement. changed mms 1/22/92     *
 *                  3.  add a row to table NFMactivity.                     *
 *                                                                          *
 ****************************************************************************/

long NFMadd_activity_entry (user_id, app_name, app_msg)
  long	  user_id;
  char    *app_name;
  MSGptr  app_msg;
{
  static char *fname = "NFMadd_activity_entry" ;
  long   status;
  char   date[40];    
  char   successfail[8];    
  char   failreason[NFM_FAILREASON+1], n_failreason[NFM_FAILREASON+1] ;
  char   sql_str[2048];
  char   theItemName[100];  /* PS */
  char   theItemRevision[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
  *app_name = *app_name ;
  date[0] = 0; 
  successfail[0] = 0; 
  failreason[0] = 0; 

/* get failreason, successfail */

  status = _WFget_error_info (successfail, failreason, app_msg);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "NFMtranslate_wf_struct = <0x%.8x> ", status));
     return (status);
  }

  /* get the date and time.  */

  status = NFMget_RISdatetime (date) ;

  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_date_time = <0x%.8x> ", status));
      return (status);
    }

  /* check for single ticks in the n_failreason field */

  status = NFMparse_string (failreason, n_failreason) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
/* add tics to each of tics in item name and item revision -PS */
 
   NFMtic_to_tics(WFinfo.item_name, theItemName);
   NFMtic_to_tics(WFinfo.item_rev, theItemRevision);
 
  sprintf (sql_str, "Insert into nfmactivity (n_username, n_projectname, \
n_catalogname, n_itemname, n_itemrev, n_date, n_commandname, \
n_transitionname,  n_oldstatename, n_newstatename, \
n_successfail, n_failreason, \
n_workflowname, n_aclname) \
values \
('%s', '%s', '%s', '%s', '%s', TIMESTAMP '%s', '%s', '%s', '%s', '%s', %s, '%s', '%s', '%s')",
NFMglobal.NFMusername,WFinfo.proj_name,
/* replace this with ticked item name and revision values - PS 11 dec 95
WFinfo.catalog_name, WFinfo.item_name,WFinfo.item_rev,date, WFinfo.command_name,
*/
WFinfo.catalog_name, theItemName, theItemRevision, date, WFinfo.command_name,
WFinfo.transition_name, WFinfo.current_statename, WFinfo.next_statename,
successfail, n_failreason,
WFinfo.workflow_name, WFinfo.acl_name) ;

  status = SQLexec_imm (sql_str);
  if (status != SQL_S_SUCCESS)
  {
     _NFMdebug ((fname, "SQL Stmt = <0x%.8x> ", status));
     ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
     return (NFM_E_SQL_STMT);
  }
_NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

