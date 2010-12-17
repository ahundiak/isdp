#include "machine.h"
#include "WFG.h"

/***************************************************************************
 *                                                                         *
 *  Date:  June 9, 1992.                                                   *
 *                                                                         *
 *  Functions:  WFGdump_workflow                                           *
 *                                                                         *
 * This function is used by the workflow generator to dump an existing     *
 * workflow into the format required by the "Load Workflow" command.       * 
 *                                                                         *
 ***************************************************************************/


long WFGdump_workflow (workflow_name, file_name)
  char   *workflow_name;
  char   *file_name;     /* if not given name will be defaulted and created
                            in the current working location                */
  {
    long    workflow_no;
    long    status = NFM_S_SUCCESS;
    long    warning = NFM_S_SUCCESS;
    int     i, j, count;
    FILE    *out_file;
    char    workflow_desc[48];
    char    acl_name[48];
    char    filename[20];
    char    wf_type[8];
    char    *file_ptr;
    char    **s_data;
    char    **c_data;
    char    **t_data;
    char    **a_data;
    MEMptr  state_buffer = NULL;
    MEMptr  class_buffer = NULL;
    MEMptr  trans_buffer = NULL;
    MEMptr  class_list   = NULL;
    static  char *fname = "_WFGdump_workflow";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " file_name     = <%s>\n", file_name));

    if (strcmp (workflow_name, "") == 0)
     {
         /* The workflow name has not been given, return with an error. */

         status = NFM_E_NULL_WF;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, " No workflow given : status = <0x%.8x>\n",
                     status));
         return (status);
     }
    
    filename[0] = 0;
    strcpy (filename, "WorkFlow.dmp");
    file_ptr = file_name;

    if (strcmp (file_name, "") == 0)
     {
         /* The file_name has not been given, it will be defaulted  */ 

         file_ptr = filename;
         warning  = NFM_I_DEFAULTING_FILENAME;  /* NEW Message */
     }

    /* Open the file specified by file_ptr */

    if ( (out_file = fopen (file_ptr, "w")) ==  NULL)
     {
       /* cannot open the file specified by file_ptr */ 

         status = NFM_E_CANNOT_OPEN_FILE;      /* NEW Message */
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname," Cannot open the output file : status = <0x%.8x>\n",
                     status));
         return (status);
     }

    workflow_no = 0;
    acl_name[0] = 0;
    workflow_desc[0] = 0;  
    wf_type[0] = 0;  

    /* Get the workflow information */

    status = WFGqry_wf_info (workflow_name, &workflow_no, workflow_desc,
                             wf_type, acl_name);
    if (status != NFM_S_SUCCESS)
     {
        fclose (out_file);
        _NFMdebug ((fname, "WFGqry_wf_info : status = <0x%.8x>\n", status));
        return (status);
     }

    /* Output the workflow information to the ascii file */ 

    WFGoutput_line (out_file, "NFMWORKFLOW", 11, TRUE);
    WFGoutput_line (out_file, " ", 1, TRUE);
    WFGoutput_line (out_file, workflow_name, 20, FALSE);
    WFGoutput_line (out_file, workflow_desc, 30, FALSE);
    WFGoutput_line (out_file, wf_type, 1, FALSE);
    WFGoutput_line (out_file, acl_name, 20, TRUE);
    WFGoutput_line (out_file, " ", 1, TRUE);
    WFGoutput_line (out_file, "NFMSTATES", 9, TRUE);
    WFGoutput_line (out_file, " ", 1, TRUE);

    /* Get all the states for the workflow (state_no, state_name, seqno) */

    status = WFGqry_wf_states (workflow_no, &state_buffer);
    if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
        fclose (out_file);
        MEMclose (&state_buffer);
        _NFMdebug ((fname, "WFGqry_wf_states : status = <0x%.8x>\n", status));
        return (status);
     }

    if (status == NFM_S_SUCCESS)
     {
        /* Write the states out to the file */ 

        s_data = (char **) state_buffer->data_ptr;
        for (i = 0; i < state_buffer->rows; ++i)
         {
            count = i * state_buffer->columns;
            WFGoutput_line (out_file, s_data[count + 1], 40, FALSE);
            WFGoutput_line (out_file, s_data[count + 2], 40, FALSE);
            WFGoutput_line (out_file, s_data[count + 3], 1, FALSE);
            WFGoutput_line (out_file, s_data[count + 4], 1, FALSE);
            WFGoutput_line (out_file, s_data[count + 5], 2, FALSE);
            WFGoutput_line (out_file, s_data[count + 6], 1, FALSE);
            WFGoutput_line (out_file, s_data[count + 7], 5, TRUE);
         }

        WFGoutput_line (out_file, " ", 1, TRUE);
     }

    WFGoutput_line (out_file, "NFMCLASSES", 10, TRUE);
    WFGoutput_line (out_file, " ", 1, TRUE);

    /* Get all the classes for the workflow ( class_no, class_name) */

    status = WFGqry_wf_classes (workflow_no, &class_buffer);
    if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
        fclose (out_file);
        MEMclose (&class_buffer);
        MEMclose (&state_buffer);
        _NFMdebug ((fname, "WFGqry_wf_classes : status = <0x%.8x>\n", status));
        return (status);
     }

    if (status == NFM_S_SUCCESS)
     {
        /* Write the classes out to the file */ 

        c_data = (char **) class_buffer->data_ptr;
        for (i = 0; i < class_buffer->rows; ++i)
         {
            count = i * class_buffer->columns;
            WFGoutput_line (out_file, c_data[count + 1], 20, TRUE);
         }

        WFGoutput_line (out_file, " ", 1, TRUE);
     }

    WFGoutput_line (out_file, "NFMTRANSITIONS", 14, TRUE);
    WFGoutput_line (out_file, " ", 1, TRUE);

    /* Get all the transitions for the workflow (trans_no, trans_name,
       command_name, from_state_no, from_state_no (calc), to_state_no (calc),
       logon_success, logon_failure, notify                              */

    status = WFGqry_wf_transitions (workflow_no, &trans_buffer, state_buffer);
    if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
        fclose (out_file);
        MEMclose (&class_buffer);
        MEMclose (&state_buffer);
        MEMclose (&trans_buffer);
        _NFMdebug ((fname, "WFGqry_wf_transitions : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    if (status == NFM_S_SUCCESS)
     {
        t_data = (char **) trans_buffer->data_ptr;
        for (i = 0; i < trans_buffer->rows; ++i)
         {
            count = i * trans_buffer->columns;

            /* Write the transitions out to the file */

            WFGoutput_line (out_file, t_data[count + 1], 100, FALSE);
            WFGoutput_line (out_file, t_data[count + 2], 100, FALSE);
            WFGoutput_line (out_file, t_data[count + 3], 2, FALSE);
            WFGoutput_line (out_file, t_data[count + 4], 2, FALSE);
            WFGoutput_line (out_file, t_data[count + 5], 1, FALSE);
            WFGoutput_line (out_file, t_data[count + 6], 1, FALSE);
            WFGoutput_line (out_file, t_data[count + 7], 1, FALSE);

            /* Get the classes that have access to the transition */

            status = WFGqry_wf_class_access (atol (t_data[count]),
                                            class_buffer, &class_list);
            if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
             {
                fclose (out_file);
                MEMclose (&class_buffer);
                MEMclose (&state_buffer);
                MEMclose (&trans_buffer);
                MEMclose (&class_list);
                _NFMdebug ((fname,
                     "WFGqry_wf_class_access : status = <0x%.8x>\n", status));
                return (status);
             }

            if (status == NFM_S_SUCCESS)
             {
                /* Write the classes out to the file */ 

                a_data = (char **) class_list->data_ptr;
                for (j = 0; j < class_list->rows; ++j)
                 {
                    count = j * class_list->columns;
                    if (j == (class_list->rows -1))
                       WFGoutput_line (out_file, a_data[count], 2, TRUE);
                    else
                       WFGoutput_line (out_file, a_data[count], 2, FALSE);
                 } 
             } 
            else
               WFGoutput_line (out_file, " ", 1, TRUE);
            
            MEMclose (&class_list);
            class_list = NULL; 
         }

        WFGoutput_line (out_file, " ", 1, TRUE);
     }

    fclose (out_file);
    MEMclose (&class_buffer);
    MEMclose (&state_buffer);
    MEMclose (&trans_buffer);

    if (warning != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname,
                " No Filename given : it was defaulted : status = <0x%.8x>\n",
                    warning));
        ERRload_struct (NFM, warning, NULL);
        return (warning);
     } 

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGqry_wf_info (workflow_name, workflow_no, workflow_desc, wf_type,
                     acl_name)
    char  *workflow_name;
    long  *workflow_no;
    char  *workflow_desc;
    char  *wf_type;
    char  *acl_name;  
  {
    long    status = NFM_S_SUCCESS;
    char    sql_str[512];
    char    **data;
    MEMptr  sql_buffer = NULL;
    static  char *fname = "_WFGqry_wf_info";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));

    sprintf (sql_str, "SELECT nfmworkflow.n_workflowno,nfmworkflow.n_workflowdesc, nfmworkflow.n_workflowtype,nfmacls.n_aclname FROM nfmworkflow, nfmacls WHERE nfmworkflow.n_workflowname = '%s' AND nfmworkflow.n_aclno = nfmacls.n_aclno",
	     workflow_name );
    status = SQLquery (sql_str, &sql_buffer, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (&sql_buffer);
        _sql_error (status);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_WF_DOES_NOT_EXIST, NULL);
           _NFMdebug ((fname, "Cannot get workflow info : status = <0x%.8x>\n",
                       NFM_E_WF_DOES_NOT_EXIST));  
           return (NFM_E_WF_DOES_NOT_EXIST);
         }

        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }
    
    status = MEMbuild_array (sql_buffer);
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    data = (char **) sql_buffer->data_ptr; 

    *workflow_no = atol (data[0]); 
    strcpy (workflow_desc, data[1]);
    strcpy (wf_type,  data[2]);
    strcpy (acl_name, data[3]);
    MEMclose (&sql_buffer);

    _NFMdebug ((fname, "Workflow No   = <%d>\n", *workflow_no));
    _NFMdebug ((fname, "Workflow Desc = <%s>\n", workflow_desc));
    _NFMdebug ((fname, "Workflow Type = <%s>\n", wf_type));
    _NFMdebug ((fname, "ACL Name      = <%s>\n", acl_name));

    _NFMdebug ((fname, "returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


/****************************************************************************
 *                                                                          *
 *  WFGoutput_line : This function will write the specified string to the   *
 *                   specified file.                                        *
 *                   This function assumes that the file is already opened  *
 *                   in a writable mode.                                    *
 *                   This function will append an EOL to the line after it  *
 *                   has been outputed.                                     *
 *                                                                          *
 ****************************************************************************/

long WFGoutput_line (out_file, wf_str, length, write_line)
    FILE   *out_file;
    char   *wf_str;  /* string contains a value that may or may not be padded */
    int    length;   /* Maximum allowable Length of the above string */
    int    write_line;  /* TRUE / FALSE */   
  {
     int     t_length;
     int     i, j; 
     int     max_padding = 30;
     char    tmp_str[256]; 
     static  char *delim = "|";
     static  char *blank = " ";

     /* static  char *fname = "_WFGoutput_line"; */
     
     j = length;
     strcpy (tmp_str, wf_str);
     t_length = strlen (wf_str);

     if (t_length < length)
      {
         /* blank pad the wf_str */

         for (i = (t_length); ((i < length) && (i < max_padding)); ++i)
          {
            j = i;
            tmp_str[i] = blank[0];
          }

         if (j == length) 
            j = t_length;  /* No blank padding on the string */
      }
    
     if (write_line)
      {
         tmp_str[j] = 0;
         fprintf (out_file, "%s\n", tmp_str);  
      }
     else
      {
         tmp_str[j] = delim[0];
         tmp_str[j + 1] = 0;
         fprintf (out_file, "%s", tmp_str);  
      }

     return (NFM_S_SUCCESS);
  }



long WFGqry_wf_states (workflow_no, state_buffer)
    long    workflow_no;
    MEMptr  *state_buffer; 
  {
    long    status = NFM_S_SUCCESS;
    char    sql_str[512];
    static  char *fname = "_WFGqry_wf_states";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    sprintf (sql_str, "SELECT n_stateno, n_statename, n_statedesc,n_transfrom, n_transto, n_signoffs, n_majority, n_seqno FROM nfmstates WHERE nfmstates.n_workflowno = %d ORDER BY n_seqno", workflow_no );
    status = SQLquery (sql_str, state_buffer, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (state_buffer);
        *state_buffer = NULL;
        _sql_error (status);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           _NFMdebug ((fname, "No states exist for the workflow = <0x%.8x>\n",
                       status));  
           return (status);
         }

        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }

    status = MEMbuild_array (*state_buffer);
    if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }
    
    _NFMdebug ((fname, "returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGqry_wf_classes (workflow_no, class_buffer)
    long    workflow_no;
    MEMptr  *class_buffer; 
  {
    long    status = NFM_S_SUCCESS;
    char    sql_str[256];
    static  char *fname = "_WFGqry_wf_classes";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    sprintf (sql_str, "SELECT n_classno, n_classname FROM nfmclasses WHERE n_workflowno = %d ORDER BY n_classno", workflow_no );

    status = SQLquery (sql_str, class_buffer, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (class_buffer);
        *class_buffer = NULL; 
        _sql_error (status);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           _NFMdebug ((fname, "No classes exist for the workflow = <0x%.8x>\n",
                       status));  
           return (status);
         }

        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }

    status = MEMbuild_array (*class_buffer);
    if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }
    
    _NFMdebug ((fname, "returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGqry_wf_transitions (workflow_no, trans_buffer, state_buffer)
    long    workflow_no;
    MEMptr  *trans_buffer; 
    MEMptr  state_buffer; 
  {
    long    status = NFM_S_SUCCESS;
    int     i, j, count, s_count;
    int     x, y;
    int     rows, columns = 8; 
    short   found;
    char    sql_str[512];
    char    **data;
    char    **s_data;
    static  char *fname = "_WFGqry_wf_transitions";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    x = 3;  /* offset for from_state */
    y = 4;  /* offset for to_state */

    sprintf (sql_str, "SELECT n_transitionno, n_transitionname,n_commandname, n_fromstate, n_tostate, n_logonsuccess, n_logonfailure,n_notify FROM nfmtransitions, nfmcommands WHERE n_workflowno = %d AND nfmtransitions.n_commandno = nfmcommands.n_commandno ORDER BY n_transitionname", workflow_no );
    status = SQLquery (sql_str, trans_buffer, 4028);
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (trans_buffer);
        *trans_buffer = NULL;
        _sql_error (status);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           _NFMdebug ((fname, "No transitions for the workflow = <0x%.8x>\n",
                       status));  
           return (status);
         }

        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }

    status = MEMbuild_array (*trans_buffer);
    if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    if (state_buffer != NULL)
     {
       status = MEMbuild_array (state_buffer);
       if (status != MEM_S_SUCCESS)
        {
           ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
           _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);
        }

       data   = (char **) (*trans_buffer)->data_ptr;
       s_data = (char **) state_buffer->data_ptr;
       rows = (*trans_buffer)->rows;
       columns = (*trans_buffer)->columns;
   
       _NFMdebug ((fname, " Rows = <%d>\n", rows));
       _NFMdebug ((fname, " State Buffer->Rows = <%d>\n", state_buffer->rows));
   
       for (i = 0; i < state_buffer->rows; ++i)
        {
            s_count = i * state_buffer->columns;
            _NFMdebug ((fname, "State_no = <%s>\n",   s_data[s_count]));
            _NFMdebug ((fname, "State_name = <%s>\n", s_data[s_count + 1]));
        }
   
       /* alter the from_state, to_states to reflect the correct numbering
          scheme used by the "Load Workflow" command.                      */
   
       for (i = 0; i < rows; ++i) 
        {
           count = i * columns;
           if ((strcmp (data[count + x], "1") != 0) &&
               (strcmp (data[count + x], "0") != 0))
            { 
               found = FALSE; 
   
               /* find the from_state in the state_list */
   
               for (j = 0; j < state_buffer->rows; ++j)
                {
                   s_count = j * state_buffer->columns;
                   if (strcmp (data[count + x], s_data[s_count]) == 0)
                    {
                       /* substitute the from_state */
   
                       sql_str[0] = 0;
                       sprintf (sql_str, "%d", j + 2);
                       status = MEMwrite_data (*trans_buffer, sql_str, i + 1,
                                               x + 1);
                       if (status != MEM_S_SUCCESS)
                        {
                           MEMclose (trans_buffer);
                           *trans_buffer = NULL;
                           ERRload_struct (NFM, NFM_E_MEM, "%s%x",
                                           "MEMwrite_data", status);
                           _NFMdebug ((fname,
                                "MEM Write Data: status = <0x%.8x>\n", status));
                           return (NFM_E_MEM);
                        }
   
                       status = MEMbuild_array (*trans_buffer);
                       if (status != MEM_S_SUCCESS)
                        {
                           ERRload_struct (NFM, NFM_E_MEM, "%s%x", 
                                           "MEMbuild_array", status);
                           _NFMdebug ((fname,
                             "MEM Build Array : status = <0x%.8x>\n", status));
                           return (NFM_E_MEM);
                        }
   
                       found = TRUE; 
                       break;
                    }
                }
             }
   
           if ((strcmp (data[count + y], "1") != 0) &&
               (strcmp (data[count + y], "0") != 0))
            { 
               found = FALSE; 
   
               /* find the to_state in the state_list */
   
               for (j = 0; j < state_buffer->rows; ++j)
                {
                   s_count = j * state_buffer->columns;
                   if (strcmp (data[count + y], s_data[s_count]) == 0)
                    {
                       /* substitute the to_state */
   
                       sql_str[0] = 0;
                       sprintf (sql_str, "%d", j + 2);
                       status = MEMwrite_data (*trans_buffer, sql_str, i + 1,
                                               y + 1);
                       if (status != MEM_S_SUCCESS)
                        {
                           MEMclose (trans_buffer);
                           *trans_buffer = NULL;
                           ERRload_struct (NFM, NFM_E_MEM, "%s%x",
                                           "MEMwrite_data", status);
                           _NFMdebug ((fname,
                                "MEM Write Data: status = <0x%.8x>\n", status));
                           return (NFM_E_MEM);
                        }
   
                       status = MEMbuild_array (*trans_buffer);
                       if (status != MEM_S_SUCCESS)
                        {
                           ERRload_struct (NFM, NFM_E_MEM, "%s%x", 
                                           "MEMbuild_array", status);
                           _NFMdebug ((fname,
                             "MEM Build Array : status = <0x%.8x>\n", status));
                           return (NFM_E_MEM);
                        }
   
                       found = TRUE; 
                       break;
                    }
                }
            }
        }
     }

    _NFMdebug ((fname, "returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

long WFGqry_wf_class_access (trans_no, class_buffer, class_list)
    long    trans_no;
    MEMptr  class_buffer; 
    MEMptr  *class_list; 
  {
    long    status = NFM_S_SUCCESS;
    int     i, j, count;
    int     x;
    int     rows; 
    short   found;
    char    sql_str[256];
    char    **data;
    char    **c_data;
    static  char *fname = "_WFGqry_wf_class_access";

    _NFMdebug ((fname, " trans_no = <%d>\n", trans_no));

    x = 0;  /* offset for class_no */

    sprintf (sql_str, "SELECT n_classno FROM nfmaccess WHERE n_transitionno = %d ORDER BY n_classno", trans_no );

    status = SQLquery (sql_str, class_list, 256);
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (class_list);
        *class_list = NULL;
        _sql_error (status);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           _NFMdebug ((fname, "No classes for the workflow = <0x%.8x>\n",
                       status));  
           return (status);
         }

        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }

    status = MEMbuild_array (*class_list);
    if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    status = MEMbuild_array (class_buffer);
    if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    data   = (char **) (*class_list)->data_ptr;
    c_data = (char **) class_buffer->data_ptr;
    rows = (*class_list)->rows;
    _NFMdebug ((fname, " Rows = <%d>\n", rows));

    /* alter the class_no to reflect the correct numbering
       scheme used by the "Load Workflow" command.                      */

    for (i = 0; i < rows; ++i) 
     {
        found = FALSE; 

        /* find the class_no in the class_buffer */

        for (j = 0; j < class_buffer->rows; ++j)
         {
            count = j * class_buffer->columns;
            if (strcmp (data[i], c_data[count]) == 0)
             {
                /* substitute the class_no */

                sql_str[0] = 0;
                sprintf (sql_str, "%d", j + 1);
                status = MEMwrite_data (*class_list, sql_str, i + 1,
                                        x + 1);
                if (status != MEM_S_SUCCESS)
                 {
                    MEMclose (class_list);
                    *class_list = NULL;
                    ERRload_struct (NFM, NFM_E_MEM, "%s%x",
                                    "MEMwrite_data", status);
                    _NFMdebug ((fname,
                         "MEM Write Data: status = <0x%.8x>\n", status));
                    return (NFM_E_MEM);
                 }

                status = MEMbuild_array (*class_list);
                if (status != MEM_S_SUCCESS)
                 {
                    ERRload_struct (NFM, NFM_E_MEM, "%s%x",
                                    "MEMbuild_array", status);
                    _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
                                status));
                    return (NFM_E_MEM);
                 }

                found = TRUE; 
                break;
             }
         }
     }

    _NFMdebug ((fname, "returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

