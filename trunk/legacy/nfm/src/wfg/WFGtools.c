#include "machine.h"
#include "WFG.h"
#include "WFGdefs.h"

/*  extern struct WFstruct WFinfo;  */


extern char  WFG_DONT_CARE_STATE [];
extern char  WFG_NO_CHANGE_STATE [];

 /****************************************************************************
  *                                                                          *
  *  Function:   _WFGcheck_wf_in_use                                         *
  *  Date:       May 20, 1991                                                * 
  *                                                                          *
  *  This function will query the NFMACLS table to see if any ACLS exist for *
  *  the workflow.  If any are found the workflow is in use.                 *  
  *                                                                          *
  ****************************************************************************/


 long _WFGcheck_wf_in_use (wf_no)
   long   wf_no;
   {
     long     status = NFM_S_SUCCESS;
     char     sql_str [512];
     static   char* fname = "_WFGcheck_wf_in_use";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Wf   No = <%d>\n", wf_no  ));

     sprintf (sql_str, "SELECT n_aclno FROM NFMACLS WHERE n_workflowno = %d",
              wf_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     MEMclose (&buffer);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }
     else if (status == SQL_S_SUCCESS)
         status = NFM_I_WF_IN_USE; 
     else if (status == SQL_I_NO_ROWS_FOUND)
         status = NFM_I_WF_NOT_IN_USE; 
      
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }

  long _WFGget_workflow_no (workflowname, wf_no)
   char   *workflowname;       /* I */
   long   *wf_no;              /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     char     out_str[80];
     static   char* fname = "_WFGget_workflow_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Wf Name = <%s>\n", workflowname));

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (workflowname, out_str);

     sprintf (sql_str,
             "SELECT n_workflowno FROM NFMWORKFLOW where n_workflowname = '%s'",
              out_str);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
              status = NFM_E_WF_DOES_NOT_EXIST;
              ERRload_struct (NFM, status, NULL);
              _NFMdebug ((fname,
                          ": Specified WF does not exist status = <0x%.8x>\n",
                          status));
              return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, " MEMbuild_array : status = <0x%.8x>\n",
                      status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *wf_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": WF No    = <%d>\n", *wf_no));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }


  long WFGvalidate_workflow (workflowname)
   char   *workflowname;       /* I */
   {
     long     status = NFM_S_SUCCESS;
     char     sql_str [512];
     char     out_str[80];
     static   char* fname = "WFGvalidate_workflow";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Wf Name = <%s>\n", workflowname));

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (workflowname, out_str);

     sprintf (sql_str, "SELECT * FROM NFMWORKFLOW where n_workflowname = '%s'",
              out_str);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     MEMclose (&buffer);
     if (status != SQL_S_SUCCESS)
      {
         if (status == SQL_I_NO_ROWS_FOUND)
          {
              status = NFM_E_WF_DOES_NOT_EXIST;
              ERRload_struct (NFM, status, NULL);
              _NFMdebug ((fname,
                          ": Specified WF does not exist status = <0x%.8x>\n",
                          status));
              return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     _NFMdebug ((fname, ": return status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

  long _WFGget_class_no (workflow_no, class_name, class_no)
   long   workflow_no;       /* I */
   char   *class_name;       /* I */
   long   *class_no;         /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     char     out_str[80];
     static   char* fname = "_WFGget_class_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Class Name  = <%s>\n", class_name));
     _NFMdebug ((fname, ": Workflow No = <%d>\n", workflow_no));

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (class_name, out_str);

     sprintf (sql_str,
              "SELECT %s FROM NFMCLASSES WHERE %s = '%s' AND %s = %d",
              "n_classno", "n_classname", out_str,
              "n_workflowno", workflow_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_CLASS_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                        ": Specified class does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *class_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": Class No    = <%d>\n", *class_no));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }



  long _WFGget_state_no (workflow_no, state_name, state_no)
   long   workflow_no;       /* I */
   char   *state_name;       /* I */
   long   *state_no;         /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     char     out_str[128];
     static   char* fname = "_WFGget_state_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": State Name = <%s>\n", state_name));
     _NFMdebug ((fname, ": Workflow No = <%d>\n", workflow_no));

     if (strcmp (state_name, WFG_DONT_CARE_STATE) == 0)
      {
          *state_no = 0;
          _NFMdebug ((fname, ": State No    = <%d>\n", *state_no));
          _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
          return (status);
      } 

     if (strcmp (state_name, WFG_NO_CHANGE_STATE) == 0)
      {
          *state_no = 1;
          _NFMdebug ((fname, ": State No    = <%d>\n", *state_no));
          _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
          return (status);
      } 

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (state_name, out_str);

     sprintf (sql_str,
              "SELECT %s FROM NFMSTATES WHERE %s = '%s' AND %s = %d", 
              "n_stateno", "n_statename", out_str,
              "n_workflowno", workflow_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_STATE_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                        ": Specified state does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *state_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": State No    = <%d>\n", *state_no));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }


  long _WFGget_trans_no (workflow_no, trans_name, from_state, trans_no)
   long   workflow_no;       /* I */
   char   *trans_name;       /* I */
   long   from_state;        /* I */ 
   long   *trans_no;         /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     char     out_str[256];
     static   char* fname = "_WFGget_trans_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Transition Name = <%s>\n", trans_name));
     _NFMdebug ((fname, ": From State      = <%d>\n", from_state));
     _NFMdebug ((fname, ": Workflow No     = <%d>\n", workflow_no));

     out_str[0] = 0;
     WFGtic_it (trans_name, out_str);

     sprintf (sql_str,
              "SELECT %s FROM %s WHERE %s = '%s' AND %s = %d AND %s = %d",
              "n_transitionno", "NFMTRANSITIONS", "n_transitionname",
              out_str, "n_fromstate", from_state, "n_workflowno", workflow_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_TRANS_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                        ": Specified trans does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *trans_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": Transition No  = <%d>\n", *trans_no));
     _NFMdebug ((fname, ": return status  = <0x%.8x>\n", status));
     return (status);
   }



  long _WFGget_command_no (command_name, command_no)
   char   *command_name;      /* I */
   long   *command_no;        /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [256], **data;
     char     out_str[256];
     static   char* fname = "_WFGget_command_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Command Name = <%s>\n", command_name));

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (command_name, out_str);

     sprintf (sql_str,
              "SELECT n_commandno FROM nfmcommands WHERE n_commandname = '%s'",
              out_str);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_COMMAND_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                       ": Specified command does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *command_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": Command No  = <%d>\n", *command_no));
     _NFMdebug ((fname, ": return status  = <0x%.8x>\n", status));
     return (status);
   }


  long _WFGget_acl_no (acl_name, acl_no)
   char   *acl_name;       /* I */
   long   *acl_no;         /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     char     out_str[80];
     static   char* fname = "_WFGget_acl_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": ACL Name = <%s>\n", acl_name));

     /* Substitute single tics with double tics */

     out_str[0] = 0;
     WFGtic_it (acl_name, out_str);

     sprintf (sql_str,
             "SELECT n_aclno FROM nfmacls WHERE n_aclname = '%s'", out_str);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
              status = NFM_E_BAD_WF_ACL;
              ERRload_struct (NFM, status, NULL);
              _NFMdebug ((fname,
                         ": Specified ACL does not exist : status = <0x%.8x>\n",
                          status));
              return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, " MEMbuild_array : status = <0x%.8x>\n",
                      status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *acl_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": ACL No    = <%d>\n", *acl_no));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }


/* This function gets the current state for the workflow */

  long _WFGget_wf_state (workflow_no, state_no, state_name)
   long   workflow_no;       /* I */
   long   *state_no;         /* O */
   char   *state_name;       /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [512], **data;
     static   char* fname = "_WFGget_wf_state";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Workflow No = <%d>\n", workflow_no));

     sprintf (sql_str,
              "SELECT %s, %s FROM %s, %s WHERE %s = %d AND %s = %s", 
              "nfmworkflow.n_stateno", "nfmstates.n_statename",
              "nfmworkflow", "nfmstates", "nfmworkflow.n_workflowno",
              workflow_no, "nfmworkflow.n_stateno", "nfmstates.n_stateno");
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_WF_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                      ": Specified workflow does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *state_no = atol (data[0]);
     strcpy (state_name, data[1]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": State No    = <%d>\n", *state_no));
     _NFMdebug ((fname, ": State Name  = <%s>\n", state_name));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }


/* This function gets the table number for the specified table */

  long _WFGget_table_no (table_name, table_no)
   char   *table_name;       /* I */
   long   *table_no;         /* O */
   {
     long     status = NFM_S_SUCCESS;
     long     atol ();
     char     sql_str [256], **data;
     static   char* fname = "_WFGget_table_no";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Table Name = <%s>\n", table_name));

     sprintf (sql_str,  
              "SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s'", 
              table_name);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_TABLE_NUM_NOT_FOUND;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
              " The table does not exist in nfmtables : status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     *table_no = atol (data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": Table No  = <%d>\n", *table_no));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }



/* This function gets the attribute synonyms for the specified attributes */
/* attribute list is a char string and each attribute is delimited by a
   "" equivalent to '\1'                                                */

  long _WFGget_attribute_synonyms (table_no, attr_list, synonym_list)
   long   table_no;         /* I */
   char   *attr_list;       /* I */
   MEMptr *synonym_list;    /* O */
   {
     long     status = NFM_S_SUCCESS;
     int      num_attrs = 0;
     short    comma = FALSE;
     char     *sql_str;
     char     token_list[512];
     char     *token_ptr, *strptr;
     char     table_num[16];
     static   char* fname = "_WFGget_attribute_synonyms";

     _NFMdebug ((fname, ": Table No  = <%d>\n", table_no));
     _NFMdebug ((fname, ": Attr_list = <%s>\n", attr_list));

     if (strcmp (attr_list, "") == 0)
      {
         status = NFM_E_BAD_ATTRIBUTE;
         _NFMdebug ((fname, ": Null attr_list : status = <0x%.8x>\n", status));
         return (status);
      }

     strncpy (token_list, attr_list, 511); 
     token_list[511] = '\0'; 
     strptr = token_list;

     while ((token_ptr = strtok (strptr, "\1")) != NULL)
      {
         ++num_attrs;
         strptr = NULL;
      }

     strncpy (token_list, attr_list, 511); 
     token_list[511] = '\0'; 
     strptr = token_list;

     if (attr_list[strlen(token_list) - 1] != '\1')
       ++num_attrs;

     _NFMdebug ((fname, ": Number of attributes = <%d>\n", num_attrs));

     sql_str = (char *) malloc (num_attrs * 128 + 256);
     if (!sql_str)
      {
         _NFMdebug ((fname, "Malloc : bytes = <%d>\n", num_attrs * 128 + 256));
         ERRload_struct (NFM, NFM_E_MALLOC, "%d", num_attrs * 128 + 256);
         _NFMdebug ((fname, " returning FAILURE\n"));
         return (NFM_E_MALLOC);
      }     

     strcpy (sql_str, "SELECT n_synonym FROM nfmattributes WHERE (n_name = "); 
     while ((token_ptr = strtok (strptr, "\1")) != NULL)
      {
         if (comma)
            strcat (sql_str, " OR n_name = ");
         strcat (sql_str, "'");
         strcat (sql_str, token_ptr);
         strcat (sql_str, "'");
         comma = TRUE;
         strptr = NULL;
      }

     sprintf (table_num, "%d", table_no);
     strcat (sql_str, ") AND n_tableno = "); 
     strcat (sql_str, table_num);
     
     _NFMdebug ((fname, ": sql_str = <%s>\n", sql_str));

     status = SQLquery (sql_str, synonym_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         free (sql_str);
         MEMclose (synonym_list);
         *synonym_list = NULL;
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_BAD_ATTRIBUTE;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
              " Attribute does not exist in nfmattributes: status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }
     free (sql_str);

     status = NFM_S_SUCCESS;
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }



 long _WFGcheck_command_in_use (command_no, command_name)
   long   command_no;
   char   *command_name;
   {
     long     status = NFM_S_SUCCESS;
     long     cmd_no;
     char     sql_str [256];
     static   char* fname = "_WFGcheck_command_in_use";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": Command   No = <%d>\n", command_no  ));
     _NFMdebug ((fname, ": Command Name = <%s>\n", command_name));

     if (command_no > 0)
        cmd_no = command_no;
     else
      {
          status = _WFGget_command_no (command_name, &cmd_no);
          if (status != NFM_S_SUCCESS)
           {
              ERRreset_struct ();
              if (status == NFM_E_COMMAND_DOES_NOT_EXIST)
                   status = NFM_I_COMMAND_NOT_IN_USE; 
              _NFMdebug ((fname, " _WFGget_command_no : status = <0x%.8x>\n",
                          status));
              return (status);
           }
      } 

     sprintf (sql_str, "SELECT * FROM nfmtransitions WHERE n_commandno = %d",
              cmd_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     MEMclose (&buffer);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }
     else if (status == SQL_S_SUCCESS)
         status = NFM_I_COMMAND_IN_USE; 
     else
         status = NFM_I_COMMAND_NOT_IN_USE; 
      
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }


/* Type = 0 (command_name), Type = 1 (command_name, application),
   type = 2 (all)  otherwise  (all)                                */ 


long _WFGget_cmd_synonyms (type, attr_list)
  int           type;        
  MEMptr	*attr_list;
  {
    long    status;
    int     i;
    char    str[80];
    static  char *fname = "_WFGget_cmd_synonyms";

    _NFMdebug ((fname, " type          = <%d>\n", type));

    /* Open the attr_list and put the synonyms into it. */

    status = MEMopen (attr_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    status = MEMwrite_format (*attr_list, "n_synonym", "char(40)");
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Putting the synonyms into the attr_list\n"));

    if (type == 0)  
     {
          str[0] = 0;
          strcat (str, "Command Name");
          strcat (str, "\1");

          status = MEMwrite (*attr_list, str);
          if (status != MEM_S_SUCCESS)
           {
               MEMclose (attr_list);
               *attr_list = NULL;
               status = NFM_E_MEM;
               _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
               return (status);
           }

     }
    else if (type == 1) 
     {
          str[0] = 0;
          strcat (str, "Command Name");
          strcat (str, "\1");

          status = MEMwrite (*attr_list, str);
          if (status != MEM_S_SUCCESS)
           {
               MEMclose (attr_list);
               *attr_list = NULL;
               status = NFM_E_MEM;
               _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
               return (status);
           }

          str[0] = 0;
          strcat (str, "Application");
          strcat (str, "\1");

          status = MEMwrite (*attr_list, str);
          if (status != MEM_S_SUCCESS)
           {
               MEMclose (attr_list);
               *attr_list = NULL;
               status = NFM_E_MEM;
               _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
               return (status);
           }
     }
    else  /* (type == 2) :  TRUE: Long Listing */
     {
         for (i = 0; i < 5; ++i)
          {
             str[0] = 0;
             switch (i)
              {
                 case 0:
                    strcat (str, "Command Name");
                 break;

                 case 1:
                    strcat (str, "Application");
                 break; 

                 case 3:
                    strcat (str, "Transition Command");
                 break;
             
                 case 2:
                    strcat (str, "Entity");
                 break;
             
                 case 4:
                    strcat (str, "I/NFM Command Number");
                 break;
             
              }

             strcat (str, "\1");

             status = MEMwrite (*attr_list, str);
             if (status != MEM_S_SUCCESS)
              {
                   MEMclose (attr_list);
                   *attr_list = NULL;
                  status = NFM_E_MEM;
                  _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
                  return (status);
              }
          } 
     }

    status = NFM_S_SUCCESS;
    _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
    return (status);
  }


  long _WFGget_state_name (workflow_no, state_no, state_name)
   long   workflow_no;       /* I */
   long   state_no;          /* I */
   char   *state_name;       /* O */
   {
     long     status = NFM_S_SUCCESS;
     char     sql_str [512], **data;
     static   char* fname = "_WFGget_state_name";
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, ": State No    = <%d>\n", state_no));
     _NFMdebug ((fname, ": Workflow No = <%d>\n", workflow_no));

     if (workflow_no <= 0) 
         sprintf (sql_str,
              "SELECT %s FROM NFMSTATES WHERE %s = %d", 
              "n_statename", "n_stateno", state_no);
     else 
         sprintf (sql_str,
              "SELECT %s FROM NFMSTATES WHERE %s = %d AND %s = %d", 
              "n_statename", "n_stateno", state_no,
              "n_workflowno", workflow_no);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         MEMclose (&buffer);
         if (status == SQL_I_NO_ROWS_FOUND)
          {
             status = NFM_E_STATE_DOES_NOT_EXIST;
             ERRload_struct (NFM, status, NULL);
             _NFMdebug ((fname,
                        ": Specified state does not exist status = <0x%.8x>\n",
                         status));
             return (status);
          }
         _sql_error (status);
         status = NFM_E_SQL_QUERY;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
      {
          MEMclose (&buffer);
          ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
          status = NFM_E_MEM;
          _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n", status));
          return (status);
      }

     data = (char **) buffer->data_ptr;

     sprintf (state_name, data[0]);
     MEMclose (&buffer);
     status = NFM_S_SUCCESS;

     _NFMdebug ((fname, ": State Name    = <%s>\n", state_name));
     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }

