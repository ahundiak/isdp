#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMapi.h" 
#include "NFMitems.h"
#include "ERR.h"
#include "NFMsysstruct.h"
int IN_PIPE = 0 ;
int OUT_PIPE = 0 ;

extern struct NFMuser_info_struct NFMuser_info ;
extern long silent_mode ;

long _NFMprogram ()
{
  char *fname = "_NFMprogram"  ;
  long  status ;
  long  UPDnew_commands();
  long  UPDnfmattributes () ;
  long  UPDnfmsysattributes() ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMcheck_30version () ;
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug ((fname,  "Failure : Erroneous version\n")) ;
	return (status) ;
  }

  NFMuser_info.uid = getuid () ;
  NFMuser_info.gid = getgid () ;

  _NFMdebug ((fname, "Initialized the uid to <%d> and gid to <%d>\n",
	      NFMuser_info.uid, NFMuser_info.gid)) ;

  UPDnew_commands();
  UPDnfmattributes() ;
  UPDnfmsysattributes() ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long UPDnew_commands ()
{
  char *fname ="UPDnew_commands";
  long commandno, transitionno ;
  long status, wfno ;
  long _NFMadd_command () ;
  long _NFMadd_transition() ;
  long _NFMadd_access() ;

/* Copy ACL Users*/
  if (! silent_mode) fprintf (stderr, "Copy ACL Users...\n") ;
  status = _NFMadd_command ("Copy ACL Users", "A", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Copy ACL Users",
			       "NFM_ADMIN_WORKFLOW",
			       "NO CHANGE STATE",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "administrator") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
/* Delete Tape Labels */
  if (! silent_mode) fprintf (stderr, "Delete Tape Labels ...\n") ;
  status = _NFMadd_command ("Delete Tape Labels", "A", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Delete Tape Labels",
			       "NFM_ADMIN_WORKFLOW",
			       "NO CHANGE STATE",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "administrator") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  


/* Dump Workflow */
  if (! silent_mode) fprintf (stderr, "Dump Workflow ...\n") ;
  
  status = _NFMadd_command ("Dump Workflow", "S", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_transition (commandno,
			       "Dump Workflow",
			       "NFM_SDP_WORKFLOW",
			       "NO CHANGE STATE",
			       "NO CHANGE STATE",
			       &transitionno,
			       "N", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno, wfno,
			   "administrator") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
/* Plot Item */
  if (! silent_mode) fprintf (stderr, "Plot Item ...\n") ;
  status = _NFMadd_command ("Plot Item", "I", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Plot Item",
			       "NFM_ITEM_WORKFLOW",
			       "NO CHANGE STATE",
			       "NO CHANGE STATE",
			       &transitionno,
			       "N", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "designer") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

/* Plot Set */
  if (! silent_mode) fprintf (stderr, "Plot Set ...\n") ;
  status = _NFMadd_command ("Plot Set", "I", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Plot Set",
			       "NFM_ITEM_WORKFLOW",
			       "NO CHANGE STATE",
			       "NO CHANGE STATE",
			       &transitionno,
			       "N", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "designer") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

/* Save Item Files */
  if (! silent_mode) fprintf (stderr, "Save Item Files ...\n") ;
  status = _NFMadd_command ("Save Item Files", "I", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Save Item Files",
			       "NFM_ITEM_WORKFLOW",
			       "creation complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "designer") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_transition (commandno,
			       "Save Item Files",
			       "NFM_ITEM_WORKFLOW",
			       "modification complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Save Item Files",
			       "NFM_ITEM_WORKFLOW",
			       "approval complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
/* Save Set Files */
  if (! silent_mode) fprintf (stderr, "Save Set Files ...\n") ;
  status = _NFMadd_command ("Save Set Files", "I", &commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Save Set Files",
			       "NFM_ITEM_WORKFLOW",
			       "creation complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "designer") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Save Set Files",
			       "NFM_ITEM_WORKFLOW",
			       "modification complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "supervisor") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_transition (commandno,
			       "Save Set Files",
			       "NFM_ITEM_WORKFLOW",
			       "approval complete",
			       "NO CHANGE STATE",
			       &transitionno,
			       "Y", "N",
			       &wfno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMadd_access (transitionno,
			   wfno,
			   "manager") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long UPDnfmattributes ()
{
  char *fname = "UPDnfmattributes" ;
  long status ;
  char sql_str [512] ;

  if (! silent_mode) fprintf (stderr, "Read flag for working area attribute ...\n") ;
  strcpy (sql_str, "Update nfmattributes set n_read = 'Y' where n_name = 'n_cosano'") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long UPDnfmsysattributes ()
{
  char *fname = "UPDnfmsysattributes" ;
  long status ;
  char sql_str [512] ;

  if (! silent_mode) fprintf (stderr, "Read/Write/Update flags for nodes attribute ...\n") ;
  strcpy (sql_str, "Update nfmsysattributes set n_read = 'N', n_write = 'N', n_update ='N' where n_name = 'n_netware' or n_name = 'n_decnet'") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMadd_command (commandname, entity, commandno)
     char *commandname ;
     char *entity ;
     long *commandno ;
{
  char *fname = "_NFMadd_command" ;
  long status ;
  char sql_str [1024], cond_str [200], value [100] ;
  long _NFMget_next_slot() ;
  long _NFMget_value () ;

  _NFMdebug ((fname, "commandname <%s> : entity <%s>\n",
	      commandname, entity)) ;

  status = _NFMget_next_slot ("nfmcommands", "n_commandno", commandno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
  sprintf (sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_entity, n_transcommand, n_application) values (%d, '%s', '%s', 'N', 'NFM')",
	   *commandno, commandname, entity) ;
  
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  if (status == SQL_E_DUPLICATE_VALUE)
    {
      /* get commandno */
      sprintf (cond_str, "n_commandname= '%s'", commandname) ;
      status = _NFMget_value ("nfmcommands", "n_commandno", cond_str, value) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
      *commandno = atol (value) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMadd_transition (commandno,
			 transitionname,
			  workflowname,
			  from_state,
			  to_state,
			  transitionno, 
			 logon_success,
			 notify,
			 wfno)
     long commandno ;
     char *transitionname ;
     char *workflowname ;
     char *from_state ;
     char *to_state ;
     long *transitionno ;
     char *logon_success ;
     char *notify ;
     long *wfno ;
{
  char *fname = "NFMadd_transition" ;
  long status ;
  char sql_str[1024], cond_str [500] ;
  long to_stateno, from_stateno ;
  char value[500] ;
  long _NFMget_value () ;
  long _NFMget_next_slot () ;

  _NFMdebug ((fname, "commandno <%d> : transitionname <%s> : workflowname <%s> : from_state <%s> : to_state <%s>\n",
	      commandno, transitionname, workflowname, from_state, to_state)) ;

  status = _NFMget_next_slot ("nfmtransitions", "n_transitionno",
			      transitionno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  sprintf (cond_str, "n_workflowname = '%s'", workflowname) ;
  status = _NFMget_value ("nfmworkflow", "n_workflowno", cond_str, value) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  *wfno = atol (value) ;


  /* find from state */
  sprintf (cond_str, "n_statename = '%s'", from_state) ;
  status = _NFMget_value ("nfmstates", "n_stateno", cond_str, value) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  from_stateno = atol (value) ;

  /* find to state */
  sprintf (cond_str, "n_statename = '%s'", to_state) ;
  status = _NFMget_value ("nfmstates", "n_stateno", cond_str, value) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  to_stateno = atol (value) ;

  _NFMdebug ((fname, "%d : %d : %s : %d : %d : %d\n",
	      *transitionno, *wfno, transitionname, commandno,
	      from_stateno, to_stateno)) ;

  sprintf (sql_str, "INSERT INTO nfmtransitions (n_transitionno, n_workflowno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify) values (%d, %d, '%s', %d, %d, %d,'%s','Y','%s')",
	   *transitionno, *wfno, transitionname, commandno, 
	   from_stateno, to_stateno, logon_success, notify) ;

  _NFMdebug ((fname,"<%s>\n", sql_str)) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
    }
  
  if (status == SQL_E_DUPLICATE_VALUE)
    {
      sprintf (cond_str, "n_transitionname= '%s'", transitionname) ;
      status = _NFMget_value ("nfmtransitions", "n_transitionno",
			      cond_str, value) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
      *transitionno = atol (value) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMadd_access (transitionno, wfno, classname)
     long transitionno ;
     long wfno ;
     char *classname ;
{
  char *fname = "_NFMadd_access" ;
  long status ;
  char sql_str [1024], cond_str [500], value [100] ;
  long classno ;
  long _NFMget_value () ;

  _NFMdebug ((fname, "transitionno <%d> : workflowno <%d> : classname <%s>\n",
	      transitionno, wfno, classname)) ;
  /* find from state */
  sprintf (cond_str, "n_classname = '%s' and n_workflowno = %d",
	   classname, wfno) ;

  status = _NFMget_value ("nfmclasses", "n_classno", cond_str, value) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  classno = atol (value) ;
  
  /* get classno */
  sprintf (sql_str, "INSERT INTO nfmaccess (n_transitionno, n_classno) values (%d, %d)",
	   transitionno, classno) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMget_next_slot (tablename, columnname, next_slot)
     char *tablename ;
     char *columnname ;
     long *next_slot ;
{
  char *fname = "_NFMget_next_slot" ;
  long status ;
  char sql_str [1024] ;
  MEMptr sql_buffer = NULL ;
  char **data ;

  _NFMdebug ((fname, "tablename <%s> : columnname <%s>\n",
	      tablename, columnname)) ;
  sprintf (sql_str, "select MAX(%s) from %s",
	   columnname, tablename) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", 
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) sql_buffer -> data_ptr ;

  *next_slot = atol (data[0]) + 1 ;

  MEMclose (&sql_buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



long _NFMget_value (tablename, columnname, cond_str, value) 
     char *tablename ;
     char *columnname ;
     char *cond_str ;
     char *value ;
{
  char *fname = "_NFMget_value" ;
  long status ;
  char sql_str [1024] ;
  MEMptr sql_buffer = NULL;
  char **data ;

  _NFMdebug ((fname, "tablename <%s> : columnname <%s> : cond str <%s>\n",
	      tablename, columnname, cond_str)) ;
  sprintf (sql_str, "select %s from %s where %s",
	   columnname, tablename, cond_str) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", 
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) sql_buffer -> data_ptr ;

  strcpy (value, data [0]) ;

  MEMclose (&sql_buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL : value <%s>\n", value)) ;
  return (NFM_S_SUCCESS) ;
}


