#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include "NFMerrordef.h"
#include "SQLerrordef.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "ERR.h"
#include "DEBUG.h"
#define  TABLES 2
#define  ADD_COMMANDS 31 
#define  COMMANDS 66

long CVTconvert_workflow ()
{
  char *fname = "CVTconvert_workflow" ;
  long status ;
  long CVTconvert_wf ();

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = CVTconvert_wf () ;
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : status =<0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
/*  status = CVTuser_def_wf ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "Adding Commands to User Defined Workflow Failed : status = <0x%.8x>\n", status));
    ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
    return (NFM_E_MESSAGE);
  }*/
  _NFMdebug ((fname, "SUCCESSFUL\n"));
  return (NFM_S_SUCCESS) ;
}


long CVTconvert_wf ()
{
  long status, i;
  char table[2][50];
  char *fname = "CVTconvert_wf" ;
  char flag[2];
  MEMptr buffer = NULL;
  int last_row ;
  long CVTreseq_table ();
  long CVTdelete_command ();
  long CVTadd_command ();
  long CVTadd_transition() ;
  long CVTdelete_transition() ;
  long CVTchange_entity ();
  long CVTadd_exist ();
  long CVTrename() ;
  long CVTcatalog_wf() ;
  long CVTstates (), CVTworkflow ();

  strcpy(table[0], "nfmcommands");
  strcpy(table[1], "nfmtransitions");

  last_row = 0;
  _NFMdebug((fname, "Workflow conversion started.\n"));
  fprintf(stderr, "Workflow conversion started.\n");

  status = CVTquery_cvtlog_entry ("CVTSTATUS3", flag, &last_row);
  if (status == NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "Workflow has already been converted.\n"));
	fprintf(stderr, "Workflow has already been converted.\n");
    return (status);
  }

    status = CVTquery_cvtlog_entry ("nfmcommands", flag, &last_row);
	if (status == NFM_S_SUCCESS)
	{
	  if (flag[0] == 'C')
	  {
		_NFMdebug ((fname, "Workflow Converted : status = <0x%.8x>\n", status));
		return (NFM_S_SUCCESS);
      }
    }
	if (status == NFM_I_NO_ROWS_FOUND) 
	{
	  _NFMdebug ((fname, "No entry Found : status = <0x%.8x>\n", status));
	  return (status);
    }
    status = CVTquery_cvtlog_entry ("nfmtransitions", flag, &last_row);
	if (status == NFM_S_SUCCESS)
	{
	  if (flag[0] == 'C')
	  {
		_NFMdebug ((fname, "Workflow Converted : status = <0x%.8x>\n", status));
		return (NFM_S_SUCCESS);
      }
    }
	if (status == NFM_I_NO_ROWS_FOUND) 
	{
	  _NFMdebug ((fname, "No entry Found : status = <0x%.8x>\n", status));
	  return (status);
    }

  fprintf (stderr, "Deleting old commands..\n") ;
     status = CVTdelete_command();
	 if (status != NFM_S_SUCCESS)
	 {
		ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
	    return (NFM_E_MESSAGE);
	 }

     fprintf (stderr, "Re-seqencing commands..\n");
     for (i=0; i<TABLES; i++)
	 {
       status = CVTreseq_table(table[i]);
       if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Re-sequencing nfmcommands and nfmtransitions table failed : status = <0x%.8x>\n", status));
	     ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
         return (NFM_E_MESSAGE);
       }
       if (status == NFM_S_SUCCESS)
       {
		  if (strcmp(table[i], "nfmcommands") == 0)
		  {
	        status = CVTupdate_cvtlog(table[i], "C", 0);
	        if (status != NFM_S_SUCCESS)
            {
	          _NFMdebug ((fname, "Cannot Update Nfmconvertlog : status = <0x%.8x>\n", status));
	          return (status);
            }
          }
       }
       status = MEMclose(&buffer);
     }

fprintf (stderr, "Renaming old commands..\n") ;
  status = CVTrename() ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Rename command or create If it Doesn't Exist Failed : status = <0x%.8x>\n", status));
      ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Rename command failed");
      return (NFM_E_MESSAGE);
    }
    
 fprintf (stderr, "Adding new commands..\n") ;
 status = CVTadd_command ();
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug ((fname, "Adding Command Failed : status = <0x%.8x>\n", status));
   ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
   return (NFM_E_MESSAGE);
 }

  status = CVTadd_transition();
  if (status != NFM_S_SUCCESS)
    {
   _NFMdebug ((fname, "Adding Transition Failed : status = <0x%.8x>\n", 
	       status));
   ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
   return (NFM_E_MESSAGE);
    }

  status = CVTdelete_transition();
  if (status != NFM_S_SUCCESS)
    {
   _NFMdebug ((fname, "Delete Transition Failed : status = <0x%.8x>\n", 
	       status));
   ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
   return (NFM_E_MESSAGE);
    }

 fprintf (stderr, "Changing entities in commands..\n") ;
 status = CVTchange_entity ();
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug ((fname, "Changing Entity Failed : status = <0x%.8x>\n", status));
   ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
   return (NFM_E_MESSAGE);
 }

 fprintf (stderr, "Adding commands if they do not exist already..\n") ;
 status = CVTadd_exist ();
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug ((fname, "Adding Command If it Doesn't Exist Failed : status = <0x%.8x>\n", status));
   ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
   return (NFM_E_MESSAGE);
 }

  /*fprintf(stderr, "Adding User Defined Workflow..\n");*/
  status = CVTuser_def_wf ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "Adding Commands to User Defined Workflow Failed : status = <0x%.8x>\n", status));
    ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
    return (NFM_E_MESSAGE);
  }

  status = CVTcatalog_wf () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Catalog Workflow changes Failed : status = <0x%.8x>\n",
		  status));
      return (status) ;
    }
 /*status = CVTstates ();
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug((fname, "Converting NFMSTATES FAILED : status = <0x%.8x>\n", status ));
   status = CVTupdate_cvtlog("NFMSTATES", "E", 0); 
   return (status);
 }*/

 status = CVTquery_cvtlog_entry ("nfmworkflow", flag, &last_row);
 if (status == NFM_S_SUCCESS)
 {
   if (flag[0] == 'C')
   {
     _NFMdebug ((fname, "Workflow Converted : status = <0x%.8x>\n", status));
	 return (NFM_S_SUCCESS);
   }
 }
 if (status == NFM_I_NO_ROWS_FOUND) 
 {
    _NFMdebug ((fname, "No entry Found : status = <0x%.8x>\n", status));
    return (status);
 }

 status = CVTupdate_cvtlog("nfmworkflow", "C", 0);
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug ((fname, "Cannot Update Nfmconvertlog : status = <0x%.8x>\n", status));
   return (status);
 }

 status = CVTworkflow ();
 if (status != NFM_S_SUCCESS)
 {
   _NFMdebug((fname, "Converting NFMWORKFLOW FAILED : status = <0x%.8x>\n", status ));
   status = CVTupdate_cvtlog("nfmworkflow", "E", 0); 
   return (status);
 }
 if (status == NFM_S_SUCCESS)
 {
   status = CVTupdate_cvtlog("CVTSTATUS3", "C", 0);
   if (status != NFM_S_SUCCESS)
   {
	 _NFMdebug((fname, "Cannot update nfmconvertlog\n"));
	 fflush(stdout);
	 fprintf(stdout, "Write access failed for table <nfmconvertlog>\n");
	 return (status);
   }
 }
 fprintf(stderr, "Workflow conversion completed.\n");
 return (NFM_S_SUCCESS);
}

long CVTreseq_table(table_name)
char *table_name;
{
  long status, i ;
  char sql_str[1024];
  MEMptr c_buffer = NULL;
  MEMptr new_buffer = NULL;
  char *fname = "CVTreseq_table";
  char **new_data;
  int num, process_on_transitions;

  process_on_transitions = 0;
  _NFMdebug ((fname, "Re-sequencing table <%s>\n", table_name));

  if (strcmp(table_name, "nfmcommands") == 0)
  {
    sprintf(sql_str, "SELECT n_commandno \
    FROM %s order by n_commandno", table_name);
    status = SQLquery(sql_str, &new_buffer, MEM_SIZE); 
    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array (new_buffer) ;
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      ERRload_struct(NFM, NFM_E_MEM, "", "");
      return (NFM_E_MEM);
    }

    new_data = (char **) new_buffer -> data_ptr;
    num =1;

    for (i=0; i<new_buffer -> rows; i++)
    {
		    sprintf(sql_str, "UPDATE nfmcommands SET n_commandno = %d  WHERE n_commandno = %s",
		    num, new_data[i]) ;

		    status = SQLstmt(sql_str);
		    if (status != SQL_S_SUCCESS)
		    {
			  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
			  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			  return (NFM_E_SQL_STMT);
		    }

			sprintf(sql_str, "UPDATE nfmtransitions SET n_commandno = %d Where n_commandno = %s", num, new_data[i]);
		    status = SQLstmt(sql_str);
		    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		    {
			  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
			  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			  return (NFM_E_SQL_STMT);
		    }
			num++;
 }
 status = MEMclose(&new_buffer);
 }
 else if (strcmp(table_name, "nfmtransitions") == 0)
 {
	status = CVTcheck_process_on_transitions ();
	if (status != SQL_I_NO_ROWS_FOUND)
	{
	  process_on_transitions = 1;
    }
    sprintf(sql_str, "SELECT n_transitionno FROM %s", 
	    table_name);
    status = SQLquery(sql_str, &new_buffer, MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
    {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array (new_buffer) ;
    if (status != MEM_S_SUCCESS)
    {
       _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
	   ERRload_struct(NFM, NFM_E_MEM, "", "");
       return (NFM_E_MEM);
    }

    new_data = (char **) new_buffer -> data_ptr;
    num = 1; 

    for (i=0; i<new_buffer -> rows; i++)
    {
	          sprintf(sql_str, "UPDATE nfmtransitions SET n_transitionno = %d WHERE n_transitionno = %s",
	          num, new_data[i]) ;

	          status = SQLstmt(sql_str);
	          if (status != SQL_S_SUCCESS)
	          {
		        ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
		        _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		        return (NFM_E_SQL_STMT);
	          }
			  status = MEMclose(&c_buffer);
			  if (process_on_transitions == 1)
			  { 
				status = CVTprocess_tran(new_data[i], num);
				if (status != NFM_S_SUCCESS)
				{
				  _NFMdebug((fname, "Converting Process on Transitions Failed : status = <0x%.8x>\n", status));
				  ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
				  return (NFM_E_MESSAGE);
                }
              }
			  status = CVTnfmaccess(new_data[i], num);   
			  if (status != NFM_S_SUCCESS)
			  {
				_NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
				ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
				return (NFM_E_MESSAGE);
              }
			  num++;
   } 
 }
 status = MEMclose(&new_buffer);
 return (NFM_S_SUCCESS);
}

long CVTdelete_command ()
{
  char **data;
  char **column;
  long status, i, y, x;
  MEMptr buffer = NULL;
  long CVTdelete ();
  int offset;
  char *fname = "CVTdelete_command";
  char sql_str[500];
  char delcmd[70][100];

  strcpy(delcmd[0], "Initialize");
  strcpy(delcmd[1], "Login");  
  strcpy(delcmd[2], "Display List of Copied Items on SA"); 
  strcpy(delcmd[3], "Remove Copied Items on SA"); 
  strcpy(delcmd[4], "Define User Defaults");  
  strcpy(delcmd[5], "Retrieve Default Active Data"); 
  strcpy(delcmd[6], "Display List of Tables");
  strcpy(delcmd[7], "Create Table"); 
  strcpy(delcmd[8], "Change Table");
  strcpy(delcmd[9], "Delete Table"); 
  strcpy(delcmd[10], "Flag Catalog Files for Backup"); 
  strcpy(delcmd[11], "Flag Catalog Files for Restore"); 
  strcpy(delcmd[12], "Cancel Backup Flag on Catalog Files"); 
  strcpy(delcmd[13], "Cancel Restore Flag on Catalog Files"); 
  strcpy(delcmd[14], "Purge Files in Catalog"); 
  strcpy(delcmd[15], "Display List of Reports");
  strcpy(delcmd[16], "Add File Type"); 
  strcpy(delcmd[17], "Change File Type");
  strcpy(delcmd[18], "Delete File Type"); 
  strcpy(delcmd[19], "Display List of Reports");
  strcpy(delcmd[20], "Define Report"); 
  strcpy(delcmd[21], "Load Report");
  strcpy(delcmd[22], "Delete Report");
  strcpy(delcmd[23], "Run Report"); 
  strcpy(delcmd[24], "Load Search Criteria");
  strcpy(delcmd[25], "Load Sort Criteria"); 
  strcpy(delcmd[26], "Display List of Programs");
  strcpy(delcmd[27], "Load Program");
  strcpy(delcmd[28], "Delete Program");
  strcpy(delcmd[29], "Display List of Programs to Pre Transition");
  strcpy(delcmd[30], "Display List of Programs to Post Transition"); 
  strcpy(delcmd[31], "Add Program to Pre Transition"); 
  strcpy(delcmd[32], "Add Program to Post Transition"); 
  strcpy(delcmd[33], "Delete Program to Pre Transition"); 
  strcpy(delcmd[34], "Delete Program to Post Transition"); 
  strcpy(delcmd[35], "Change Item File to be Restored"); 
  strcpy(delcmd[36], "Display List of Copied Files"); 
  strcpy(delcmd[37], "Remove Copied Files");
  strcpy(delcmd[38], "Add States");
  strcpy(delcmd[39], "Delete States"); 
  strcpy(delcmd[40], "Add Classes");
  strcpy(delcmd[41], "Delete Classes");
  strcpy(delcmd[42], "Add Transitions"); 
  strcpy(delcmd[43], "Delete Transitions");
  strcpy(delcmd[44], "Add Transition to Class Access"); 
  strcpy(delcmd[45], "Delete Transition to Class Access"); 
  strcpy(delcmd[46], "Display List of Files in Item"); 
  strcpy(delcmd[47], "Convert Item to Set"); 
  strcpy(delcmd[48], "Check Out Item/No Copy"); 
  strcpy(delcmd[49], "Purge Files for Item");
  strcpy(delcmd[50], "Add Set");
  strcpy(delcmd[51], "Display List of Sets");
  strcpy(delcmd[52], "Convert Set to Item");
  strcpy(delcmd[53], "Display List of Defaults"); 
  strcpy(delcmd[54], "Define Defaults");
  strcpy(delcmd[55], "Connect to Server"); 
  strcpy(delcmd[56], "Disconnect from Server"); 
  strcpy(delcmd[57], "Login to Environment");
  strcpy(delcmd[58], "Logout from Environment"); 
  strcpy(delcmd[59], "Display List of Copied Files for User");  
  strcpy(delcmd[60], "Remove Copied Files for User"); 
  strcpy(delcmd[61], "Define Project Members");
  strcpy(delcmd[62], "Define Set Members");
  strcpy(delcmd[63], "Clear Saveset") ;
  strcpy(delcmd[64], "Display List of File Types") ;
  strcpy(delcmd[65], "Display List of Savesets");
  /*strcpy(delcmd[66], "Change Password") ;*/


  strcpy(sql_str, "SELECT n_commandno, n_commandname, n_entity, \
  n_transcommand, n_nfmcommandno, n_application FROM nfmcommands");
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    ERRload_struct(NFM, NFM_E_MEM, "", "");
    return (NFM_E_MEM);
  }

  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;

  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer -> columns;
      for (y=0; y<buffer->columns; y++)
	{
	  if (strcmp(column[y], "n_commandname") == 0)
	    {
	      for (x=0; x<COMMANDS; x++)
		{
		  if (strcmp(data[offset+y], delcmd[x]) == 0)
		    {
		      status = CVTdelete(data[offset], data[offset+y]) ;
		      if (status != NFM_S_SUCCESS)
			{
			  _NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
			  ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			  return (NFM_E_MESSAGE);
			}
		    }
		}
	    }
	}
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTdelete (c_data)
char *c_data;
{
  char sql_str[500];
  long status ;
  char *fname = "CVTdelete";

  sprintf(sql_str, "DELETE FROM nfmaccess where n_transitionno in (select n_transitionno from nfmtransitions where n_commandno = %s)", 
	  c_data) ;
  status = SQLexec_imm (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }

  sprintf(sql_str, "DELETE FROM nfmprocesses where n_transitionno in (select n_transitionno from nfmtransitions where n_commandno = %s)", 
	  c_data) ;
  status = SQLexec_imm (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }
  
  sprintf(sql_str, "DELETE FROM nfmtransitions where n_commandno = %s", 
	  c_data);
  status = SQLexec_imm (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }

  sprintf(sql_str, "DELETE FROM nfmcommands WHERE n_commandno = %s",
	  c_data) ;
  status = SQLexec_imm (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status ));
    return (NFM_E_SQL_STMT);
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTupdate(data, trans, transno)
char **data, *trans;
int *transno;
{
  long status; 
  char query[500];
  char *fname = "CVTupdate";

  sprintf(query, "UPDATE nfmtransitions SET n_transitionname = '%s' \
  WHERE n_transitionname = '%s' and n_transitionno = %d", \
  trans, data, transno);
  status = SQLstmt(query);
  if (status != SQL_S_SUCCESS)
  {
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  return (SQL_S_SUCCESS);
}

long CVTadd_command ()
{
  long status, i, new_tableno, new_transno ;
  char addcmd[50][100];
  char sql_str[1024];
  char *fname = "CVTadd_command";

  strcpy(addcmd[0], "Display List of User Working Areas");
  strcpy(addcmd[1], "Display List of Working Areas");
  strcpy(addcmd[2], "Change Workflow of Item");
  strcpy(addcmd[3], "Display List of Saveset Entries");
  strcpy(addcmd[4], "Display List of Archives");
  strcpy(addcmd[5], "Display List of Items on Tape");
  strcpy(addcmd[6], "Display List of Local Files");
  strcpy(addcmd[7], "Delete Copied Files");
  strcpy(addcmd[8], "Change Working Area Password");
  strcpy(addcmd[9], "Flag Project for Archive");
  strcpy(addcmd[10], "Cancel Archive Flag on Project");
  strcpy(addcmd[11], "Copy Item");
  strcpy(addcmd[12], "Add Files to Item");
  strcpy(addcmd[13], "Change File Attributes");
  strcpy(addcmd[14], "Delete Files from Item");
  strcpy(addcmd[15], "Save Files");
  strcpy(addcmd[16], "Purge File Versions");
  strcpy(addcmd[17], "Roll File Version Forward");
  strcpy(addcmd[18], "Add Items to Project");
  strcpy(addcmd[19], "Delete Items from Project");
  strcpy(addcmd[20], "Add Items to Set");
  strcpy(addcmd[21], "Delete Items from Set");
  strcpy(addcmd[22], "Display List of Commands");
  strcpy(addcmd[23], "Delete Saveset Entries") ;
  strcpy(addcmd[24], "Copy ACL Users");
  strcpy(addcmd[25], "Delete Tape Labels");
  strcpy(addcmd[26], "Dump Workflow");
  strcpy(addcmd[27], "Plot Item");
  strcpy(addcmd[28], "Plot Set");
  strcpy(addcmd[29], "Save Item Files");
  strcpy(addcmd[30], "Save Set Files");

  _NFMdebug ((fname, "Adding Commands to nfmcommands and nfmtransitions\n"));
  
  status = _CVTget_next_slot ("nfmcommands", "n_commandno", &new_tableno);
  status = _CVTget_next_slot ("nfmtransitions", "n_transitionno", &new_transno);
  for (i=0; i<ADD_COMMANDS; i++)
    {
      if (strcmp(addcmd[i], "Display List of User Working Areas") == 0)
	{
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D"); 
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x\n>", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /****** mms - No transitions in initialize DB *******
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 1);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 1, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    *************************************/
	}
      else if (strcmp(addcmd[i], "Display List of Working Areas") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "A");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 2);
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
	  /**** mms - only n_classno = 2 in ris3.0.dmp ********
	    sprintf(sql_str, "Insert into nfmaccess (n_classno, n_transitionno) values (%d, %d)", 3, new_transno);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    *************************/
	}
      else if (strcmp(addcmd[i], "Change Workflow of Item") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "A");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM,NFM_E_SQL_STMT,"","");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 2);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 2);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 2);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 2);
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
      else if (strcmp(addcmd[i], "Display List of Local Files") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /****** mms - no transitions in ris3.0.dmp *******
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 1);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    *****************************************************/
	}
      else if (strcmp(addcmd[i], "Delete Copied Files") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /********** mms - no transitions in ris3.0.dmp ******
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 1);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    *****************************/
	}
      else if (strcmp(addcmd[i], "Change Working Area Password") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "D");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  /******* no transitions in ris3.0.dmp ******
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 1);
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	    {
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	    }
	    **************************/
	}
      else if (strcmp(addcmd[i], "Flag Project for Archive") == 0)
	{
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "P");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "8", "1", "Y", "Y", "N", 4);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "P");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "8", "1", "Y", "Y", "N", 4);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
		  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
			ERRload_struct(NFM,NFM_E_SQL_STMT,"","");
		    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		    return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "17", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "P");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 4);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "P");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	    ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 4);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
	      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	  new_tableno++;
	  sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "N");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	        ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");	
	        _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	        return (NFM_E_SQL_STMT);
	    }
	  new_transno++;
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "Y", 1);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "A");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 2);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "A");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 2);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "A");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "Y", "Y", "N", 2);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "S");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 1);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "1", "1", "N", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
	    new_tableno++;
	    sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity) values (%d, '%s', '%s', '%s', '%s')", new_tableno, addcmd[i], "NFM", "N", "I");
	    status = SQLstmt(sql_str);
	    if (status != SQL_S_SUCCESS)
	      {
        ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
	      }
	    new_transno++;
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "14", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "15", "1", "Y", "Y", "N", 5);
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
	    sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, addcmd[i], new_tableno, "16", "1", "Y", "Y", "N", 5);
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
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTadd_transition()
{
  long status, i, new_transno ;
  char transcom[25][100];
  char sql_str[1024];
  MEMptr sql_buffer = NULL ;
  char **data ;
  char *fname = "CVTadd_transition" ;
  long commandno ;
  /*long CVTstates ();*/

  strcpy(transcom[0], "Display List of Workflows") ;

  _NFMdebug ((fname, "Adding transitions nfmtransitions\n"));
  
  status = _CVTget_next_slot ("nfmtransitions", "n_transitionno", &new_transno);
  for (i=0; i<1; i++)
    {
      sprintf (sql_str, "Select n_commandno from nfmcommands where n_commandname = '%s'",
	       transcom[i]) ;
      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      data = (char **) sql_buffer -> data_ptr ;
      commandno = atol (data [0]) ;
      MEMclose (&sql_buffer) ;

      if (strcmp(transcom[i], "Display List of Workflows") == 0)
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %s, %s, '%s', '%s', '%s', %d)", new_transno, transcom[i], commandno, "1", "1", "N", "Y", "N", 2);
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
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

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long CVTdelete_transition()
{
  long status, i ;
  char transcom[25][100];
  char sql_str[1024];
  MEMptr sql_buffer = NULL ;
  char **data ;
  char *fname = "CVTdelete_transition" ;
  long commandno ;
  /*long CVTstates ();*/

  strcpy(transcom[0], "Display List of Storage Areas") ;

  _NFMdebug ((fname, "Deleting transitions nfmtransitions\n"));
  
  for (i=0; i<1; i++)
    {
      sprintf (sql_str, "Select n_commandno from nfmcommands where n_commandname = '%s'",
	       transcom[i]) ;
      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      data = (char **) sql_buffer -> data_ptr ;
      commandno = atol (data [0]) ;
      MEMclose (&sql_buffer) ;

      if (strcmp(transcom[i], "Display List of Storage Areas") == 0)
	  sprintf(sql_str, "Delete from nfmaccess where n_transitionno in (select n_transitionno from nfmtransitions where n_commandno = %d and n_workflowno != 2)",
		  commandno) ;
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	  sprintf(sql_str, "Delete from nfmtransitions where n_commandno = %d and n_workflowno != 2",
		  commandno) ;

	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}




long CVTchange_entity ()
{
  long status, i, y;
  char *fname = "CVTchange_entity";
  char sql_str[500];
  char **data, **column;
  MEMptr buffer = NULL;
  int offset;

  _NFMdebug ((fname, "Changing entity\n"));

  sprintf(sql_str, "Select n_commandname, n_entity \
  From nfmcommands");
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    return (NFM_E_MEM);
  }
    
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;

  for (i=0; i<buffer->rows; i++)
  {
    offset = i * buffer -> columns;
	for (y=0; y<buffer -> columns; y++)
	  {
	    if (strcmp(column[y], "n_commandname") == 0)
	      {
		if (strcmp(data[offset+y], "Display List of Storage Areas") == 0)
		  {
		    strcpy(data[offset+y+1], "A");
		    sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		    status = SQLstmt(sql_str);
		    if (status != SQL_S_SUCCESS)
		      {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
		      }
		  }
		else if (strcmp(data[offset+y], "Display List of Catalogs") == 0)
		  {
		    strcpy(data[offset+y+1], "D");
		    sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items Flagged for Delete") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of States") == 0)
		{
		  strcpy(data[offset+y+1], "S");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Classes") == 0)
		{
		  strcpy(data[offset+y+1], "S");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Transitions") == 0)
		{
		  strcpy(data[offset+y+1], "S");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Class to Transition Accesses") == 0)
		{
		  strcpy(data[offset+y+1], "S");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Projects") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items in Project") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Signoffs on Item") == 0)
		{
		  strcpy(data[offset+y+1], "I");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display Signoff History") == 0)
		{
		  strcpy(data[offset+y+1], "I");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Purge Signoffs") == 0)
		{
		  strcpy(data[offset+y+1], "I");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Change Password") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items Flagged for Archive") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items Flagged for Backup") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Items Flagged for Restore") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display Search Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display Sort Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Define Search Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Define Sort Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Delete Search Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Delete Sort Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Search Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "Display List of Sort Criteria") == 0)
		{
		  strcpy(data[offset+y+1], "D");
		  sprintf(sql_str, "Update nfmcommands set n_entity = '%s' where \
		  n_commandname = '%s'", data[offset+y+1], data[offset+y]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
      }
    }
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTadd_exist ()
{
  long status, i, new_transno;
  char *fname = "CVTadd_exist";
  char sql_str[1024];
  MEMptr buffer = NULL;
  int commandno;
  char addifnot[15][50];
  char rename[15][50], entity[15][2], n_trans[15][2];
 
  strcpy(addifnot[0], "Flag Project Files for Backup");
  strcpy(addifnot[1], "Flag Project Files for Restore");
  strcpy(addifnot[2], "Cancel Backup Flag on Project Files");
  strcpy(addifnot[3], "Cancel Restore Flag on Project Files");
  strcpy(addifnot[4], "Purge Signoff Users");
  strcpy(addifnot[5], "Signoff on Item");
  strcpy(addifnot[6], "Display List of Signoffs on Item");
  strcpy(addifnot[7], "Display Signoff History");
  strcpy(addifnot[8], "Display List of Where Item Used In Project");
  strcpy(addifnot[9], "Display List of Where Item Used In Set");

  strcpy(rename[0], "Flag Project for Backup");
  strcpy(rename[1], "Flag Project for Restore");
  strcpy(rename[2], "Cancel Backup Flag on Project");
  strcpy(rename[3], "Cancel Restore Flag on Project");
  strcpy(rename[4], "Purge Signoffs");
  strcpy(rename[5], "Signoff on Item");
  strcpy(rename[6], "Display List of Signoffs on Item");
  strcpy(rename[7], "Display Signoff History");
  strcpy(rename[8], "Display List of Where Item Used in Projects");
  strcpy(rename[9], "Display List of Where Item Used in Sets");

  strcpy(entity[0], "P");
  strcpy(entity[1], "P");
  strcpy(entity[2], "P");
  strcpy(entity[3], "P");
  strcpy(entity[4], "I");
  strcpy(entity[5], "I");
  strcpy(entity[6], "I");
  strcpy(entity[7], "I");
  strcpy(entity[8], "I");
  strcpy(entity[9], "I");

  strcpy(n_trans[0], "Y");
  strcpy(n_trans[1], "N");
  strcpy(n_trans[2], "N");
  strcpy(n_trans[3], "N");
  strcpy(n_trans[4], "N");
  strcpy(n_trans[5], "N");
  strcpy(n_trans[6], "N");
  strcpy(n_trans[7], "N");
  strcpy(n_trans[8], "N");
  strcpy(n_trans[9], "N");

  _NFMdebug ((fname, "Adding if not already present\n"));

  for (i=0; i<10; i++)
  {
    sprintf(sql_str, "Select n_commandname from nfmcommands where \
	n_commandname = '%s'", rename[i]);
    status = SQLquery(sql_str, &buffer, MEM_SIZE);
    
    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
	_NFMdebug((fname, "SQL Stmt Failure : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
      }
    
    if (status == SQL_I_NO_ROWS_FOUND)
      {
	status = _CVTget_next_slot("nfmcommands", "n_commandno", &commandno);
	sprintf(sql_str, "Insert into nfmcommands (n_commandno, n_commandname, n_entity, n_application, n_transcommand) values (%d, '%s', '%s', '%s', '%s')", commandno, rename[i], entity[i], "NFM", n_trans[i]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS)
	  {
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
      if (strcmp(rename[i], "Flag Project for Backup") == 0)
	{
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d', '%s','%s','%s', %d)", new_transno, rename[i], commandno, 8, 1, "Y", "Y", "N", 4);
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
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d, '%s','%s','%s', %d)", new_transno, rename[i], commandno, 8, 1, "Y", "Y", "N", 4);
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
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d, '%s','%s','%s', %d)", new_transno, rename[i], commandno, 8, 1, "Y", "Y", "N", 4);
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
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d, '%s','%s','%s', %d)", new_transno, rename[i], commandno, 8, 1, "Y", "Y", "N", 4);
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
      else if (strcmp(rename[i], "Display List of Where Item Used In Projects") == 0)
	{
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d, '%s','%s','%s', %d)", new_transno, rename[i], commandno, 1, 1, "N", "Y", "N", 5);
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
	}
      else if (strcmp(rename[i], "Display List of Where Item Used In Sets") == 0)
	{
	  status = _CVTget_next_slot("nfmtransitions", "n_transitionno", &new_transno);
	  sprintf(sql_str, "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, n_workflowno) values (%d, '%s', %d, %d, %d, '%s','%s','%s', %d)", new_transno, rename[i], commandno, 1, 1, "N", "Y", "N", 5);
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
	}
    }
	/*if (status == SQL_S_SUCCESS)
	  {
	  sprintf(sql_str, "Update nfmcommands set n_commandname = '%s' where n_commandname = '%s'", rename[i], addifnot[i]);
	  status = SQLstmt(sql_str);
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	  {
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_STMT);
	  }
	  }*/
      }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTrename() 
{
  long status, i ;
  char *fname = "CVTrename" ;
  char sql_str[1024];
  char old_name[20][NFM_COMMANDNAME+1];
  char new_name[20][NFM_COMMANDNAME+1] ;
 
  strcpy(old_name[0], "Flag Project Files for Backup");
  strcpy(old_name[1], "Flag Project Files for Restore");
  strcpy(old_name[2], "Cancel Backup Flag on Project Files");
  strcpy(old_name[3], "Cancel Restore Flag on Project Files");
  strcpy(old_name[4], "Purge Signoff Users");
  strcpy(old_name[5], "Display List of Where Item Used In Project");
  strcpy(old_name[6], "Display List of Where Item Used In Set");
  strcpy (old_name[7], "Cancel Archive Flag on Item Files") ;
  strcpy (old_name [8], "Cancel Archive Flag on Set Files");
  strcpy (old_name [9], "Cancel Backup Flag on Item Files");
  strcpy (old_name [10], "Cancel Backup Flag on Set Files");
  strcpy (old_name [11], "Cancel Restore Flag on Item Files");
  strcpy (old_name [12], "Cancel Restore Flag on Set Files");
  strcpy (old_name [13], "Flag Item Files for Archive") ;
  strcpy (old_name [14], "Flag Item Files for Backup") ;
  strcpy (old_name [15], "Flag Item Files for Restore") ;
  strcpy (old_name [16], "Flag Set Files for Archive") ;
  strcpy (old_name [17], "Flag Set Files for Backup") ;
  strcpy (old_name [18], "Flag Set Files for Restore") ;

  strcpy(new_name[0], "Flag Project for Backup");
  strcpy(new_name[1], "Flag Project for Restore");
  strcpy(new_name[2], "Cancel Backup Flag on Project");
  strcpy(new_name[3], "Cancel Restore Flag on Project");
  strcpy(new_name[4], "Purge Signoffs");
  strcpy(new_name[5], "Display List of Where Item Used In Projects");
  strcpy(new_name[6], "Display List of Where Item Used In Sets");
  strcpy (new_name[7], "Cancel Archive Flag on Item") ;
  strcpy (new_name [8], "Cancel Archive Flag on Set");
  strcpy (new_name [9], "Cancel Backup Flag on Item");
  strcpy (new_name [10], "Cancel Backup Flag on Set");
  strcpy (new_name [11], "Cancel Restore Flag on Item");
  strcpy (new_name [12], "Cancel Restore Flag on Set");
  strcpy (new_name [13], "Flag Item for Archive") ;
  strcpy (new_name [14], "Flag Item for Backup") ;
  strcpy (new_name [15], "Flag Item for Restore") ;
  strcpy (new_name [16], "Flag Set for Archive") ;
  strcpy (new_name [17], "Flag Set for Backup") ;
  strcpy (new_name [18], "Flag Set for Restore") ;

  _NFMdebug ((fname, "Renaming command/transition\n")) ;

  for (i=0; i<19; i++)
    {
      _NFMdebug ((fname, "Renaming command <%s> to command <%s>\n",
		  old_name[i], new_name[i])) ;
	      
      sprintf(sql_str, "Update nfmcommands set n_commandname = '%s' where n_commandname = '%s'",
	      new_name [i], old_name[i]) ;
      status = SQLstmt(sql_str);
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_STMT);
	}

      sprintf(sql_str, "Update nfmtransitions set n_transitionname = '%s' where n_transitionname = '%s'",
	      new_name [i], old_name[i]) ;
      status = SQLstmt(sql_str);
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
	  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_STMT);
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long CVTcatalog_wf ()
{
  char *fname = "CVTcatalog_wf" ;
  long status, i, offset ;
  char sql_str [1024] ;
  MEMptr sql_buffer = NULL ;
  char **data ;
  char prev_trans [NFM_TRANSITIONNAME + 1] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  strcpy (sql_str, "select n_transitionname, n_transitionno from nfmtransitions where n_workflowno = 3 order by n_transitionname") ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "No transitions for catalog workflow\n")) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "Failure : MEMbuild array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer-> data_ptr ;
  prev_trans[0] = 0 ;
  for (i=0; i<sql_buffer->rows; i++)
    {
      offset = i*sql_buffer->columns ;
      if (strcmp (prev_trans, data [offset]) == 0)
	{
	  /* delete this transition */
	  sprintf (sql_str, "Delete from nfmtransitions where n_transitionno = %s",
		   data[offset+1]) ;
	  status = SQLstmt (sql_str) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "Failure : sql stmt : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_SQL_STMT) ;
	    }
	  
	  sprintf (sql_str, "Delete from nfmaccess where n_transitionno = %s",
		   data[offset+1]) ;
	  status = SQLstmt (sql_str) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "Failure : sql stmt : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_SQL_STMT) ;
	    }
	}
      else
	strcpy (prev_trans, data [offset]) ;
    }
  MEMclose (&sql_buffer) ;

  /* all transitions in catalog workflow except Create Catalog has from and to state = 1 */
  status = SQLstmt ("Update nfmtransitions set n_fromstate = 1, n_tostate = 1 where n_workflowno = 3 and n_transitionname != 'Create Catalog'") ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long CVTstates (workflowno, s_data)
long workflowno;
char **s_data;
{
  static char *fname = "CVTstates" ;
  long status ;
  char **column, sql_str[1024];
  MEMptr buffer = NULL;
  long CVTupdate_states ();

  _NFMdebug((fname, "Converting NFMSTATES table\n"));

  sprintf(sql_str, "Select n_stateno from nfmstates where n_workflowno = %d order by n_seqno", workflowno);
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status == SQL_I_NO_ROWS_FOUND))
  {
	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
	_NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
  {
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	return (NFM_E_MEM);
  }

  s_data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;
  return (NFM_S_SUCCESS);
}
/*
  seqno1=0;
  seqno2=0;
  seqno3=0;
  seqno4=0;
  seqno5=0;*/

 /* for (i=0; i<buffer -> rows; i++)
  {
	offset = i * buffer -> columns;
	for (y=0; y<buffer -> columns; y++)
	{
	  if (strcmp(column[y], "n_workflowno") == 0 )
	  {
		if (strcmp(data[offset+y], "1") == 0)
		{
		  status = CVTupdate_states(data[offset+y-3], seqno1);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmstates update failed : status = <0x%.8x>\n", status));
			return (NFM_E_MESSAGE);
          }
		  seqno1++ ;
        }
		else if (strcmp(data[offset+y], "2") == 0)
		{
		  status = CVTupdate_states(data[offset+y-3], seqno2);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmstates update failed : status = <0x%.8x>\n", status));
			return (NFM_E_MESSAGE);
          }
		  seqno2++;
        }
		else if (strcmp(data[offset+y], "3") == 0)
		{
		  status = CVTupdate_states(data[offset+y-3], seqno3);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmstates update failed : status = <0x%.8x>\n", status));
			return (NFM_E_MESSAGE);
          }
		  seqno3++;
        }
		else if (strcmp(data[offset+y], "4") == 0)
		{
		  status = CVTupdate_states(data[offset+y-3], seqno4);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmstates update failed : status = <0x%.8x>\n", status));
			return (NFM_E_MESSAGE);
          }
		  seqno4++;
        }
		else if (strcmp(data[offset+y], "5") == 0)
		{
		  status = CVTupdate_states(data[offset+y-3], seqno5);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmstates update failed : status = <0x%.8x>\n", status));
			return (NFM_E_MESSAGE);
          }
		  seqno5++;
        }
      }
    }
  }
  return (NFM_S_SUCCESS);
}*/

long CVTupdate_states(data, seqno)
char **data;
{
  long status;
  char sql_str[1024];
  char *fname = "CVTupdate_states";

  sprintf(sql_str, "Update nfmstates set n_seqno = %d where n_stateno = %s", seqno, data);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	return (NFM_E_SQL_STMT);
  }
  return (NFM_S_SUCCESS);
}
 
long CVTworkflow () 
{
  long status, i, y;
  char *fname = "CVTworkflow";
  char sql_str[1024], **data, **column;
  MEMptr buffer = NULL;
  int offset;
  long CVTupdate_workflow ();

  _NFMdebug ((fname, "Converting NFMWORKFLOW\n"));

  strcpy(sql_str, "Update nfmworkflow set n_workflowtype = 'I' where n_workflowno >=6");
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
	_NFMdebug((fname, "Update failure : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	return (NFM_E_SQL_STMT);
  }

  sprintf(sql_str, "Select n_workflowno, n_workflowname, \
  n_workflowdesc, n_workflowtype From nfmworkflow");
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status == SQL_I_NO_ROWS_FOUND))
  {
	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
	_NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
  {
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_MEM, "", "");
	return (NFM_E_MEM);
  }

  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;
  
  for (i=0; i<buffer->rows; i++)
  {
	offset = i*buffer->columns;
	for (y=0; y<buffer->columns; y++)
	{
	  if (strcmp(column[y], "n_workflowno") == 0)
	  {
		if (strcmp(data[offset+y], "1") == 0)
		{
		  strcpy(data[offset+3], "S");
		  status = CVTupdate_workflow (data[offset+y], data[offset+3]);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmworkflow update failed : status = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			return (NFM_E_MESSAGE);
          }
        }
		else if (strcmp(data[offset+y], "2") == 0)
		{
		  strcpy(data[offset+3], "A");
		  status = CVTupdate_workflow (data[offset+y], data[offset+3]);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmworkflow update failed : status = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			return (NFM_E_MESSAGE);
          }
        }
		else if (strcmp(data[offset+y], "3") == 0)
		{
		  strcpy(data[offset+3], "C");
		  status = CVTupdate_workflow (data[offset+y], data[offset+3]);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmworkflow update failed : status = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			return (NFM_E_MESSAGE);
          }
        }
		else if (strcmp(data[offset+y], "4") == 0)
		{
		  strcpy(data[offset+3], "P");
		  status = CVTupdate_workflow (data[offset+y], data[offset+3]);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmworkflow update failed : status = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			return (NFM_E_MESSAGE);
          }
        }
		else if (strcmp(data[offset+y], "5") == 0)
		{
		  strcpy(data[offset+3], "I");
		  status = CVTupdate_workflow (data[offset+y], data[offset+3]);
		  if (status != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, "Nfmworkflow update failed : status = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_MESSAGE, "", "");
			return (NFM_E_MESSAGE);
          }
        }
      }
    }
  }
  return (NFM_S_SUCCESS);
}

long CVTupdate_workflow(data, name)
char **data;
{
  long status;
  char sql_str[500], *fname = "CVTupdate_workflow";

  sprintf(sql_str, "Update nfmworkflow set n_workflowtype = '%s' where n_workflowno = %s", name, data);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	return (NFM_E_SQL_STMT);
  }
  return (NFM_S_SUCCESS);
}

int CVTnfmaccess(data, num)
char *data;
int num;
{
  char *fname = "CVTnfmaccess";
  char sql_str[500];
  long status ;

  sprintf(sql_str, "Update nfmaccess SET n_transitionno = %d Where \
			n_transitionno = %s", num, data);
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
    return (NFM_E_SQL_STMT);
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


int CVTdelete_nfmaccess (data)
char *data;
{
  long status ;
  char sql_str[500];
  char *fname = "CVTdelete_nfmaccess";

  sprintf(sql_str, "Delete from nfmaccess where n_transitionno = %s", \
				    data);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  return (NFM_S_SUCCESS);
}

int CVTcheck_process_on_transitions()
{
  char *fname = "CVTprocess_on_transitions";
  long status ;
  char sql_str[500];
  MEMptr buffer = NULL;

  sprintf(sql_str, "Select n_transitionno, n_programno, \
  n_seqno, n_prepost FROM nfmprocesses");
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
	if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug((fname, "No Process on Transitions found\n", status));
	  return (SQL_I_NO_ROWS_FOUND);
    }
    _NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_QUERY);
  }
  return(status);
}

int CVTprocess_tran(data, num)
char *data;
int num;
{
  long status, i;
  char *fname = "CVTprocess_tran";
  char sql_str[500];
  char **p_data, flag[10];
  MEMptr p_buffer = NULL;
  int last_row;

  status = CVTquery_cvtlog_entry("nfmprocesses", flag, &last_row);
  if (status == NFM_S_SUCCESS)
  {
	if (flag[0] == 'C')
	{
	  _NFMdebug((fname, "Process on Transitions Converted : status = <0x%.8x>\n", status));
	  return (NFM_S_SUCCESS);
    }
  }
  if (status == NFM_I_NO_ROWS_FOUND)
  {
	_NFMdebug((fname, "No entry Found : status = <0x%.8x>\n", status));
	return (status);
  }

  sprintf(sql_str, "Select n_transitionno From nfmprocesses");
  status = SQLquery(sql_str, &p_buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    _NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status ));
    return (NFM_E_SQL_QUERY);
  }
	
  status = MEMbuild_array(p_buffer);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    return (NFM_E_MEM);
  }

  p_data = (char **) p_buffer -> data_ptr ;
  
  for (i = 0; i < p_buffer -> rows; i++)
  {
	if (strcmp(p_data[i], data) == 0)
	{
	  
      sprintf(sql_str, "UPDATE nfmprocesses SET n_transitionno = %d Where \
       n_transitionno = %s", num, p_data[i]);
      status = SQLstmt(sql_str);
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
	    _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
      }
	}
  }
  return (NFM_S_SUCCESS);
}

/*long CVTget_transitionno(data, a_data)
char *data;
long *a_data;
{
  long status;
  char sql_str[500];
  char **tran_data;
  MEMptr tran_buf = NULL;
  char *fname = "CVTget_transitionno";

  sprintf(sql_str, "Select n_transitionno from nfmtransitions \
  where n_commandno = %s", data);
  status = SQLquery(sql_str, &tran_buf, MEM_SIZE);
  if (status != SQL_S_SUCCESS) 
  {
	if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug((fname, "No Rows Found\n", status));
	  return(status);
    }
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (tran_buf);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    ERRload_struct(NFM, NFM_E_MEM, "", "");
    return (NFM_E_MEM);
  }

  tran_data = (char **) tran_buf -> data_ptr;
  *a_data = atol (tran_data[0]);

  _NFMdebug((fname, "Transition number to delete in nfmaccess table : transitionno %d\n", *a_data));

  return (NFM_S_SUCCESS);
}
*/
