#include "machine.h"
#include "WFG.h"

/***************************************************************************
 *                                                                         *
 *  Date:  August 22, 1991.                                                *
 *                                                                         *
 *  Functions:  WFGquery_classes                                           *
 *              WFGquery_states                                            *
 *              WFGquery_transitions                                       *
 *              WFGquery_commands     (need to write this one)             *
 *                                                                         *
 *  These functions hardcode the attributes in the query and in the        *
 *  attr_list.  These functions return a specific list structure specified *
 *  for the workflow commands.                                             * 
 *                                                                         *
 ***************************************************************************/


long WFGqry_classes (workflow_name, output_buffer)
  char          *workflow_name;
  MEMptr	*output_buffer;
  {
    long    status;
    char    str[512];
    char    where_clause[256];
    int     row, col, count;
    char    **data_ptr, **format_ptr, **column_ptr;
    char    out_str[80];
    MEMptr  data_list = NULL;
    static  char *fname = "_WFGqry_classes";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single quotes in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause, "%s = '%s' AND %s = %s",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_workflowno", "nfmclasses.n_workflowno"); 

    sprintf (str, "SELECT %s FROM %s WHERE %s ORDER BY %s",
                 "n_classname",  "nfmclasses, nfmworkflow",
                 where_clause, "n_classname");

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    status = SQLquery (str, &data_list, 2 * MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
          MEMclose (&data_list);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
               status = NFM_E_SQL_QUERY;
               ERRload_struct (NFM, status, NULL);
           }
          else
               status = NFM_E_NO_CLASSES_DEFINED;

          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
         return (status);
     }

    data_ptr   = (char **) data_list->data_ptr;
    format_ptr = (char **) data_list->format_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* Open the output_buffer and write the columns into it. */

    status = MEMopen (output_buffer, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    for (col = 0; col < data_list->columns; ++col)
     {
        status = MEMwrite_format (*output_buffer, column_ptr[col],
                                  format_ptr[col]);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    status = MEMwrite_format (*output_buffer, "n_status", "char(10)");
    if (status != MEM_S_SUCCESS)
      {
         MEMclose (output_buffer);
         *output_buffer = NULL;
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                     status));
         return (status);
     }

    /* write the rows of data into the output_list */

    for (row = 0; row < data_list->rows; ++row)
     {
        str[0] = 0;

        for (col = 0; col < data_list->columns; ++col)
         {
             count = data_list->columns * row + col;
             strcat (str, data_ptr[count]);
             strcat (str, "\1");
         }
        strcat (str, "EXISTING");   /* n_status */
        strcat (str, "\1");

        status = MEMwrite (*output_buffer, str);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    MEMclose (&data_list);

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGquery_states (workflow_name, output_buffer)
  char          *workflow_name;
  MEMptr	*output_buffer;
  {
    long    status;
    int     row, col, count;
    char    str[512];
    char    where_clause[256];
    char    out_str[80];
    char    **data_ptr, **format_ptr, **column_ptr;
    MEMptr  data_list = NULL;
    static  char *fname = "WFGquery_states";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single quotes in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause, "%s = '%s' AND %s = %s",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_workflowno", "nfmstates.n_workflowno"); 

    sprintf (str, "SELECT %s, %s FROM %s WHERE %s ORDER BY %s",
             "n_statename, n_statedesc, n_signoffs, n_majority", 
             "n_transfrom, n_transto, n_seqno", 
             "nfmstates, nfmworkflow",
             where_clause, "n_statename");

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    status = SQLquery (str, &data_list, 2 * MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
          MEMclose (&data_list);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
               status = NFM_E_SQL_QUERY;
               ERRload_struct (NFM, status, NULL);
           }
          else
               status = NFM_E_NO_STATES_DEFINED;

          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
         return (status);
     }

    data_ptr   = (char **) data_list->data_ptr;
    format_ptr = (char **) data_list->format_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* Open the output_buffer and write the columns into it. */

    status = MEMopen (output_buffer, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    for (col = 0; col < data_list->columns; ++col)
     {
        status = MEMwrite_format (*output_buffer, column_ptr[col],
                                  format_ptr[col]);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    status = MEMwrite_format (*output_buffer, "n_status", "char(10)");
    if (status != MEM_S_SUCCESS)
      {
         MEMclose (output_buffer);
         *output_buffer = NULL;
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                     status));
         return (status);
     }

    /* write the rows of data into the output_list */

    for (row = 0; row < data_list->rows; ++row)
     {
        str[0] = 0;

        for (col = 0; col < data_list->columns; ++col)
         {
             count = data_list->columns * row + col;
             strcat (str, data_ptr[count]);
             strcat (str, "\1");
         }
        strcat (str, "EXISTING");   /* n_status */
        strcat (str, "\1");

        status = MEMwrite (*output_buffer, str);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    MEMclose (&data_list);

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGquery_transitions (workflow_name, output_buffer)
  char          *workflow_name;
  MEMptr	*output_buffer;
  {
    long    status;
    int     row, col, count;
    char    str[512];
    char    where_clause[256];
    char    out_str[80];
    char    **data_ptr, **format_ptr, **column_ptr;
    MEMptr  data_list = NULL;
    static  char *fname = "WFGquery_transitions";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single quotes in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause,
             "%s = '%s' AND %s = %s AND %s = %s AND %s = %s",
             "nfmworkflow.n_workflowname",   out_str,
             "nfmtransitions.n_workflowno", "nfmworkflow.n_workflowno",
             "nfmtransitions.n_commandno",  "nfmcommands.n_commandno",
             "nfmtransitions.n_fromstate",  "nfmstates.n_stateno");

    sprintf (str,
             "SELECT %s, %s, %s, %s FROM %s WHERE %s ORDER BY %s",
             "nfmtransitions.n_transitionname, nfmcommands.n_commandname",
             "nfmstates.n_statename, nfmtransitions.n_tostate",
             "nfmtransitions.n_logonsuccess, nfmtransitions.n_logonfailure",
             "nfmtransitions.n_notify",
             " nfmtransitions, nfmcommands, nfmstates, nfmworkflow",
             where_clause, "nfmtransitions.n_transitionname"); 

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    status = SQLquery (str, &data_list, 2 * MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
          MEMclose (&data_list);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
               status = NFM_E_SQL_QUERY;
               ERRload_struct (NFM, status, NULL);
           }
          else
               status = NFM_E_NO_TRANSITIONS_DEFINED;

          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
         return (status);
     }

    data_ptr   = (char **) data_list->data_ptr;
    format_ptr = (char **) data_list->format_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* Open the output_buffer and write the columns into it. */

    status = MEMopen (output_buffer, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    for (col = 0; col < data_list->columns; ++col)
     {
        status = MEMwrite_format (*output_buffer, column_ptr[col],
                                  format_ptr[col]);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    status = MEMwrite_format (*output_buffer, "n_status", "char(10)");
    if (status != MEM_S_SUCCESS)
      {
         MEMclose (output_buffer);
         *output_buffer = NULL;
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                     status));
         return (status);
     }

    /* write the rows of data into the output_list */

    for (row = 0; row < data_list->rows; ++row)
     {
        str[0] = 0;

        for (col = 0; col < data_list->columns; ++col)
         {
             count = data_list->columns * row + col;
             strcat (str, data_ptr[count]);
             strcat (str, "\1");
         }
        strcat (str, "EXISTING");   /* n_status */
        strcat (str, "\1");

        status = MEMwrite (*output_buffer, str);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (output_buffer);
             *output_buffer = NULL;
             MEMclose (&data_list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
         }
     }

    MEMclose (&data_list);

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long WFGget_wf_info (workflow_name, workflow_no, wf_complete, workflow_desc)
  char          *workflow_name;    /* I */
  long          *workflow_no;      /* O */
  char          *wf_complete;      /* O */
  char          *workflow_desc;    /* O */
  {
    long    status;
    char    str[256];
    char    **data;
    char    out_str[80];
    MEMptr  data_list = NULL;

    static  char *fname = "WFGget_wf_desc";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single quotes in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    sprintf (str, "SELECT %s, %s, %s FROM %s where %s = '%s' AND %s = %s",
             "nfmworkflow.n_workflowno", "nfmstates.n_statename",
             "nfmworkflow.n_workflowdesc", "nfmworkflow, nfmstates",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_stateno", "nfmstates.n_stateno" );

    status = SQLquery (str, &data_list, MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
          MEMclose (&data_list);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
               status = NFM_E_SQL_QUERY;
               ERRload_struct (NFM, status, NULL);
           }
          else
               status = NFM_E_WF_DOES_NOT_EXIST;

          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&data_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
         return (status);
     }

    data = (char **) data_list->data_ptr;

    *workflow_no = atol (data[0]);
    strcpy (workflow_desc, data[2]);

    if ((strcmp (data[2], "WORKFLOW COMPLETE") == 0) ||   
        (strcmp (data[2], "WORKFLOW USABLE")   == 0))
       strcpy (wf_complete, "Y");
    else 
       strcpy (wf_complete, "N");

    MEMclose (&data_list);

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



