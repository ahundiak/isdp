#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include "MEMstruct.h"
#include "DEBUG.h"
#include "SQLerrordef.h"
#include "NFMerrordef.h"
#include "ERR.h"

#define ADD_COMMANDS 27

long CVTuser_def_wf ()
{
  long status, i, y, new_transno ;
  char addcmd[50][100];
  char sql_str[1024];
  char *fname = "CVTuser_def_wf";
  char **data, **c_data;
  MEMptr buffer = NULL;
  MEMptr c_buffer = NULL;
  long CVTuser_exist ();

  strcpy(sql_str, "Select n_workflowno From nfmworkflow Where \
  n_workflowno > 5");
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
	if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug((fname, "No User Defined Workflows Found\n"));
	  return (NFM_S_SUCCESS);
    }
	if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
	  _NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_QUERY);
    }
  }
  status = MEMbuild_array(buffer);
  if (status != MEM_S_SUCCESS)
  {
	_NFMdebug((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_MEM, "", "");
	return (NFM_E_MEM);
  }

  data = (char **) buffer -> data_ptr;

  /* strcpy(addcmd[0], "Display List of User Working Areas");*/
  strcpy(addcmd[0], "Display List of Working Areas");
  strcpy(addcmd[1], "Change Workflow of Item");
  strcpy(addcmd[2], "Display List of Saveset Entries");
  strcpy(addcmd[3], "Display List of Archives");
  strcpy(addcmd[4], "Display List of Items on Tape");
/*  strcpy(addcmd[5], "Display List of Local Files");
  strcpy(addcmd[6], "Delete Copied Files");
  strcpy(addcmd[7], "Change Working Area Password");*/
  strcpy(addcmd[5], "Flag Project for Archive");
  strcpy(addcmd[6], "Cancel Archive Flag on Project");
  strcpy(addcmd[7], "Copy Item");
  strcpy(addcmd[8], "Add Files to Item");
  strcpy(addcmd[9], "Change File Attributes");
  strcpy(addcmd[10], "Delete Files from Item");
  strcpy(addcmd[11], "Save Files");
  strcpy(addcmd[12], "Purge File Versions");
  strcpy(addcmd[13], "Roll File Version Forward");
  strcpy(addcmd[14], "Add Items to Project");
  strcpy(addcmd[15], "Delete Items from Project");
  strcpy(addcmd[16], "Add Items to Set");
  strcpy(addcmd[17], "Delete Items from Set");
  strcpy(addcmd[18], "Display List of Commands");
  strcpy(addcmd[19], "Delete Saveset Entries") ;
  strcpy(addcmd[20], "Copy ACL Users");
  strcpy(addcmd[21], "Delete Tape Labels");
  strcpy(addcmd[22], "Dump Workflow");
  strcpy(addcmd[23], "Plot Item");
  strcpy(addcmd[24], "Plot Set");
  strcpy(addcmd[25], "Save Item Files");
  strcpy(addcmd[26], "Save Set Files");

  _NFMdebug ((fname, "Adding Commands to nfmcommands and nfmtransitions\n"));
  
  status = _CVTget_next_slot ("nfmtransitions", "n_transitionno", &new_transno);
  if (status != NFM_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Cannot get next n_transitionno");
	return (status);
  }

  fprintf(stderr, "Adding User Defined Workflow..\n");

  for (y=0; y<buffer -> rows; y++)
  {
    for (i=0; i<ADD_COMMANDS; i++)
    {
	  sprintf(sql_str, "Select n_commandno From nfmcommands Where \
	  n_commandname = '%s'", addcmd[i]);
	  status = SQLquery(sql_str, &c_buffer, MEM_SIZE);
	  if (status != SQL_S_SUCCESS)
	  {
		ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
		_NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_QUERY);
      }
	  status = MEMbuild_array(c_buffer);
	  if (status != MEM_S_SUCCESS)
	  {
		ERRload_struct(NFM, NFM_E_MEM, "", "");
		_NFMdebug((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
		return (NFM_E_MEM);
      }

	  c_data = (char **) c_buffer -> data_ptr;

      if (strcmp(addcmd[i], "Display List of Working Areas") == 0)
	  {
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
		   ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	       ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	       _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	       return (NFM_E_SQL_STMT);
	    }
	  }
      else if (strcmp(addcmd[i], "Change Workflow of Item") == 0)
	  {
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /******** mms - only 2 in ris3.0.dmp ********
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    ***********************************/
	}
      else if (strcmp(addcmd[i], "Display List of Saveset Entries") == 0)
	  {
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /******* mms - only 2 in ris3.0.dmp *******
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    ***************************************/
	}
      else if (strcmp(addcmd[i], "Display List of Archives") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      else if (strcmp(addcmd[i], "Display List of Items on Tape") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      else if (strcmp(addcmd[i], "Flag Project for Archive") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "8", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(addcmd[i], "Cancel Archive Flag on Project") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "8", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(addcmd[i], "Copy Item") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(addcmd[i], "Add Files to Item") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
		    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
            ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
            ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
			ERRload_struct(NFM,NFM_E_SQL_STMT, "","");
		    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Change File Attributes") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT,"","");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT,"","");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "","");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Delete Files from Item") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Save Files") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Purge File Versions") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "17", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Roll File Version Forward") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Add Items to Project") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno)values (%d, %d)", 5, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno)values (%d, %d)", 6, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Delete Items from Project") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno)values (%d, %d)", 5, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno)values (%d, %d)", 6, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Add Items to Set") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(addcmd[i], "Delete Items from Set") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		  return (NFM_E_SQL_STMT);
	    }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		    _NFMdebug((fname, "SQL stmt : status = <0x%.8x\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Display List of Commands") == 0)
	{
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "Y", data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 1, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(addcmd[i], "Delete Saveset Entries") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Copy ACL Users") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	  }
	else if (strcmp(addcmd[i], "Delete Tape Labels") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 2, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
      }
	else if (strcmp(addcmd[i], "Dump Workflow") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 1, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
      }
	else if (strcmp(addcmd[i], "Plot Item") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
      }
	else if (strcmp(addcmd[i], "Plot Set") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "1", "1", "N", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
      }
	else if (strcmp(addcmd[i], "Save Item Files") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
		new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
            ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	  {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
      }
	  else if (strcmp(addcmd[i], "Save Set Files") == 0)
	  {
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "14", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	    }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
		new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "15", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	    }
        sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }
        new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %s, %s, '%s', '%s', '%s', %s)", new_transno, addcmd[i], c_data[0], "16", "1", "Y", "Y", "N", data[y]);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
          ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	    }
      }
	  MEMclose(&c_buffer);
    }
    status = _CVTget_next_slot ("nfmtransitions", "n_transitionno", &new_transno);
    if (status != NFM_S_SUCCESS)
    {
  	  ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Cannot get next n_transitionno");
	  return (status);
    }

  }
  status = CVTuser_exist ();
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
	return (status);
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTuser_exist ()
{
  long status, i, y, new_transno;
  char *fname = "CVTuser_exist";
  char sql_str[1024];
  MEMptr buffer = NULL;
  MEMptr w_buffer = NULL;
  char rename[15][50];
  char **w_data;
  char **data;

  strcpy(rename[0], "Flag Project for Backup");
  strcpy(rename[1], "Flag Project for Restore");
  strcpy(rename[2], "Cancel Backup Flag on Project");
  strcpy(rename[3], "Cancel Restore Flag on Project");
  /*strcpy(rename[4], "Purge Signoffs");
  strcpy(rename[5], "Signoff on Item");
  strcpy(rename[6], "Display List of Signoffs on Item");
  strcpy(rename[7], "Display Signoff History");
  strcpy(rename[4], "Display List of Where Item Used in Projects");
  strcpy(rename[5], "Display List of Where Item Used in Sets");*/

  _NFMdebug ((fname, "Adding if not already present\n"));
  strcpy(sql_str, "Select distinct n_workflowno from nfmtransitions \
  where n_workflowno > 5");
  status = SQLquery(sql_str, &w_buffer, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
	if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug((fname, "No User Defined Workflows Found\n"));
	  return (NFM_S_SUCCESS);
    }
	if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
	  _NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_QUERY);
    }
  }
  status = MEMbuild_array(w_buffer);
  if (status != MEM_S_SUCCESS)
  {
	_NFMdebug((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_MEM, "", "");
	return (NFM_E_MEM);
  }

  w_data = (char **) w_buffer -> data_ptr;

  for (y=0; y<w_buffer -> rows; y++)
  {
    for (i=0; i<4; i++)
    {
      sprintf(sql_str, "Select n_commandno from nfmcommands where \
	  n_commandname = '%s'", rename[i]); 
      status = SQLquery(sql_str, &buffer, MEM_SIZE);
    
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
	    _NFMdebug((fname, "SQL Stmt Failure : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
      }
    
      if (status != SQL_S_SUCCESS)
      {
	    ERRload_struct (NFM, NFM_E_SQL_QUERY,"", "");
	    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_QUERY);
	  }
	  status = MEMbuild_array(buffer);
	  if (status != MEM_S_SUCCESS)
	  {
		ERRload_struct(NFM,NFM_E_MEM, "", "");
		_NFMdebug((fname, "MEMbuild_array : status = <0x%.8x>\n",status));
		return(NFM_E_MEM);
      }
	  data = (char **) buffer -> data_ptr;

	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
      if (strcmp(rename[i], "Flag Project for Backup") == 0)
	  {
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 8, 1, "Y", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
	else if (strcmp(rename[i], "Flag Project for Restore") == 0)
	{
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 8, 1, "Y", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      else if (strcmp(rename[i], "Cancel Backup Flag on Project") == 0)
	{
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 8, 1, "Y", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      else if (strcmp(rename[i], "Cancel Restore Flag on Project") == 0)
	{
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 8, 1, "Y", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 5, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 6, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      /*else if (strcmp(rename[i], "Display List of Where Item Used In Projects") == 0)
	{
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 1, 1, "N", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      else if (strcmp(rename[i], "Display List of Where Item Used In Sets") == 0)
	{
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %s, %d, %d, '%s','%s','%s', %s)", new_transno, rename[i], data[0], 1, 1, "N", "Y", "N", w_data[y]);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 7, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 8, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 9, new_transno);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  }*/
	  MEMclose(&buffer);
    }
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

