#include "machine.h"
#include "WFG.h"

/***************************************************************************
 *                                                                         *
 *  Date:  July 9, 1991.                                                   *
 *                                                                         *
 *  Functions:                                                             *
 *              WFGn_list_states                                           *
 *              WFGn_list_classes                                          *
 *              WFGn_list_transitions                                      *
 *              WFGn_list_commands_long                                    *
 *                                                                         *
 *  These functions hardcode the attributes in the query and in the        *
 *  attr_list.                                                             *
 *  They return the index number as well as the name. 
 *                                                                         *
 ***************************************************************************/



long WFGn_list_states (workflow_name, attr_list, data_list)
  char          *workflow_name;
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status, q_status = NFM_S_SUCCESS;
    int     i;
    char    where_clause[256]; 
    char    order_clause[80]; 
    char    str[1024];
    char    out_str[80];
    static  char *fname = "WFGn_list_states";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause, "(%s = '%s' AND %s = %s) OR %s",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_workflowno", "nfmstates.n_workflowno",
             "(nfmstates.n_stateno = 0 OR nfmstates.n_stateno = 1)"); 

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    strcpy (order_clause, "nfmstates.n_seqno, nfmstates.n_statename");

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    sprintf (str,
             "SELECT DISTINCT nfmstates.%s, %s FROM %s WHERE %s ORDER BY %s",
             "n_stateno, n_statename, n_statedesc, n_signoffs, n_majority", 
             "n_transfrom, n_transto, n_seqno", 
             "nfmstates, nfmworkflow",
             where_clause, order_clause);

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    q_status = SQLquery (str, data_list, 2 * MEM_SIZE); 
    if ((q_status != SQL_S_SUCCESS) && (q_status != SQL_I_NO_ROWS_FOUND))
     {
          MEMclose (data_list);
          *data_list = NULL;
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", q_status));
          q_status = NFM_E_SQL_QUERY;
          ERRload_struct (NFM, q_status, NULL);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", q_status));
          return (q_status);
     }

    if (q_status == SQL_I_NO_ROWS_FOUND)
     {
         q_status = NFM_E_NO_STATES_DEFINED; 
         MEMclose (data_list);
         *data_list = NULL;
         _NFMdebug ((fname, " No states found : returning synonyms\n"));
     }
    else
         q_status = NFM_S_SUCCESS;

    /* Open the attr_list and put the synonyms into it. */

    status = MEMopen (attr_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }


    status = MEMwrite_format (*attr_list, "n_synonym", "char(40)");
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }


    _NFMdebug ((fname, " Putting the synonyms into the attr_list\n"));

    for (i = 0; i < 8; ++i)
     {
        str[0] = 0;
        switch (i)
         {
            case 0:
               strcat (str, "State Number");
            break;

            case 1:
               strcat (str, "State Name");
            break;

            case 2:
               strcat (str, "State Description");
            break; 

            case 3:
               strcat (str, "No. Signoff Users");
            break;
        
            case 4:
               strcat (str, "Signoff Type");
            break;
        
            case 5:
               strcat (str, "Trans From");
            break;
             
            case 6:
               strcat (str, "Trans To");
            break;
        
            case 7:
               strcat (str, "Sequence No");
            break;
         }

        strcat (str, "\1");

        status = MEMwrite (*attr_list, str);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (data_list);
             *data_list = NULL;
             MEMclose (attr_list);
             *attr_list = NULL;
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
             return (status);
         }
     } 

    _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", q_status));
    return (q_status);
  }


long WFGn_list_classes (workflow_name, attr_list, data_list)
  char          *workflow_name;
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status;
    char    where_clause[256]; 
    char    order_clause[80]; 
    char    str[1024];
    char    out_str[80];
    static  char *fname = "WFGn_list_classes";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause, "%s = '%s' AND %s = %s",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_workflowno", "nfmclasses.n_workflowno"); 
 
    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    strcpy (order_clause, "nfmclasses.n_classname");

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    sprintf (str, "SELECT %s FROM %s WHERE %s ORDER BY %s",
             "n_classno, n_classname",  "nfmclasses, nfmworkflow",
             where_clause, order_clause);

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    status = SQLquery (str, data_list, 2 * MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
          MEMclose (data_list);
          *data_list = NULL;
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

    /* Open the attr_list and put the synonyms into it. */

    status = MEMopen (attr_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    status = MEMwrite_format (*attr_list, "n_synonym", "char(40)");
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Putting the synonyms into the attr_list\n"));

    str[0] = 0;
    strcat (str, "Class Number");
    strcat (str, "\1");

    status = MEMwrite (*attr_list, str);
    if (status != MEM_S_SUCCESS)
     {
        MEMclose (data_list);
        *data_list = NULL;
        MEMclose (attr_list);
        *attr_list = NULL;
        status = NFM_E_MEM;
        _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
        return (status);
     }

    str[0] = 0;
    strcat (str, "Class Name");
    strcat (str, "\1");

    status = MEMwrite (*attr_list, str);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGn_list_transitions (workflow_name, attr_list, data_list)
  char          *workflow_name;
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status, q_status;
    int     i, j, count, k, count1;
    char    where_clause[512]; 
    char    order_clause[80]; 
    char    str[1024];
    char    out_str[80];
    char    **data, **s_data;
    MEMptr  state_list = NULL;
    MEMptr  list = NULL;
    static  char *fname = "WFGlist_transitions";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    sprintf (where_clause, 
             "%s = '%s' AND %s = %s AND %s = %s AND %s = %s",
             "nfmworkflow.n_workflowname",  out_str,  

             "nfmtransitions.n_workflowno", "nfmworkflow.n_workflowno",
             "nfmtransitions.n_commandno",  "nfmcommands.n_commandno",
             "nfmtransitions.n_fromstate",  "nfmstates.n_stateno"); 

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    sprintf (order_clause, "%s, %s", "nfmtransitions.n_transitionname",
             "nfmstates.n_statename");

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    /* Get the List of states for the workflow in order to replace the
       to_statename with the actual state name.                         */
    
    sprintf (str,
             "SELECT %s, %s FROM %s, %s WHERE %s = '%s' AND %s = %s OR %s",
             "DISTINCT nfmstates.n_stateno", "nfmstates.n_statename", 
             "nfmworkflow", "nfmstates",
             "nfmworkflow.n_workflowname", out_str,
             "nfmworkflow.n_workflowno", "nfmstates.n_workflowno",
             "(nfmstates.n_stateno = 0 OR nfmstates.n_stateno = 1)");  
    
    status = SQLquery (str, &state_list, 2 * MEM_SIZE); 
    if (status != SQL_S_SUCCESS)
     {
        MEMclose (&state_list);
        _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        if (status != SQL_I_NO_ROWS_FOUND)
         {
            status = NFM_E_SQL_QUERY;
            ERRload_struct (NFM, status, NULL);
         }
        else
            status = NFM_E_NO_STATES_FOUND_IN_WF;

        _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        return (status);
     }
    
    status = MEMbuild_array (state_list);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (&state_list);
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    /* list all */

    sprintf (str,
             "SELECT %s, %s, %s, %s FROM %s WHERE %s ORDER BY %s",
             "n_transitionno, n_transitionname, nfmcommands.n_commandname",
             "nfmstates.n_statename, nfmtransitions.n_tostate",
             "nfmtransitions.n_logonsuccess, nfmtransitions.n_logonfailure",
             "nfmtransitions.n_notify", 
             " nfmtransitions, nfmcommands, nfmstates, nfmworkflow",
             where_clause, order_clause);

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    q_status = SQLquery (str, &list, 4 * MEM_SIZE); 
    if ((q_status != SQL_S_SUCCESS) && (q_status != SQL_I_NO_ROWS_FOUND))
     {
         MEMclose (&state_list);
         MEMclose (&list);
         _NFMdebug ((fname, "SQLquery :q_ status = <0x%.8x>\n", q_status));
         return (q_status);
     }

    if (q_status == SQL_S_SUCCESS)
     {

        status = MEMbuild_array (list);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (&state_list);
             MEMclose (&list);
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
             return (status);
         }
    
        /* Open the data_list and put the data into it */
    
        status = MEMopen (data_list, 4 * MEM_SIZE);
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (&list);
             MEMclose (&state_list); 
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
             return (status);
         }
     
        status = MEMwrite_format (*data_list, "n_transitionno", "integer");
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (&list);
             MEMclose (data_list);
             *data_list = NULL;
             MEMclose (&state_list); 
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
          }
     
        status = MEMwrite_format (*data_list, "n_transitionname", "char(80)");
        if (status != MEM_S_SUCCESS)
         {
             MEMclose (&list);
             MEMclose (data_list);
             *data_list = NULL;
             MEMclose (&state_list); 
             status = NFM_E_MEM;
             _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                         status));
             return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_commandname", "char(100)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_fromstate", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_tostate", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_logonsuccess", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_logonfailure", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         status = MEMwrite_format (*data_list, "n_notify", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
              MEMclose (&list);
              MEMclose (data_list);
              *data_list = NULL;
              MEMclose (&state_list); 
              status = NFM_E_MEM;
              _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
                          status));
              return (status);
          }
     
         data   = (char **) list->data_ptr;
         s_data = (char **) state_list->data_ptr;
     
         for (i = 0; i < list->rows; ++i)
          {
             str[0] = 0;
             for (j = 0; j < list->columns; ++j)
              {
                 count = list->columns * i + j;
                 if ((j == 4) && (strlen (data[count]) > 0))
                  {
                     /* substitute the n_tostate (no) for to_state name */
     
                     for (k = 0; k < state_list->rows; ++k)
                      {
                         count1 = state_list->columns * k;
                         if (strcmp (s_data[count1], data[count]) == 0)
                          {
                             strcat (str, s_data[count1 + 1]); /* state_name */
                             break;
                          }
                      }
                  }
                 else
                   strcat (str, data[count]);
     
                 strcat (str, "\1");
              }
     
             status = MEMwrite (*data_list, str);
             if (status != MEM_S_SUCCESS)
              {
                  MEMclose (data_list);
                  *data_list = NULL;
                  MEMclose (&state_list); 
                  MEMclose (&list); 
                  status = NFM_E_MEM;
                  _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
                  return (status);
              }
          }

         q_status = NFM_S_SUCCESS;
     }
    else if (q_status == SQL_I_NO_ROWS_FOUND)
        q_status = NFM_E_NO_TRANSITIONS_DEFINED;

    if (state_list)
        MEMclose (&state_list);
    if (list)
        MEMclose (&list);

    /* Open the attr_list and put the synonyms into it. */

    status = MEMopen (attr_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n", status));
         return (status);
     }

    status = MEMwrite_format (*attr_list, "n_synonym", "char(40)");
    if (status != MEM_S_SUCCESS)
     {
         MEMclose (data_list);
         *data_list = NULL;
         MEMclose (attr_list);
         *attr_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Putting the synonyms into the attr_list\n"));

    for (i = 0; i < 8; ++i)
     {
        str[0] = 0;
        switch (i)
         {
            case 0:
               strcat (str, "Transition Number");
            break;

            case 1:
               strcat (str, "Transition Name");
            break;

            case 2:
               strcat (str, "Command Name");
            break; 

            case 3:
               strcat (str, "From State Name");
            break;
             
            case 4:
               strcat (str, "To State Name");
            break;
         
            case 5:
               strcat (str, "Log on Success");
            break;
        
            case 6:
               strcat (str, "Log on Failure");
            break;
        
            case 7:
               strcat (str, "Notify");
            break;
         }

        strcat (str, "\1");

        status = MEMwrite (*attr_list, str);
        if (status != MEM_S_SUCCESS)
         {
            MEMclose (data_list);
            *data_list = NULL;
            MEMclose (attr_list);
            *attr_list = NULL;
            status = NFM_E_MEM;
            _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
            return (status);
         }
     } 

    _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", q_status));
    return (q_status);
  }


/****************************************************************************
 *                                                                          *
 *  Function : WFGlist_commands_long                                        *
 *  Date     : August 22, 1991                                              *
 *                                                                          *
 *  This function is used to list all the commands used in a workflow       *
 *  commands specified in the transition table for the workflow or          * 
 *  all the commands specified in an application (nfmcommands) table.       * 
 *                                                                          *
 *  either workflow_name or application must be given.  If both are given   *
 *  then the specified workflow will be used.  If neither is given all      *
 *  commands in the system will be returned.                                *
 *                                                                          *
 ****************************************************************************/

long WFGn_list_commands_long (workflow_name, app_name, attr_list, data_list)
  char          *workflow_name;  /* I: if given app_name should be null */
  char          *app_name;       /* I: if given workflow_name should be null */
  MEMptr	*attr_list;      /* O */
  MEMptr	*data_list;      /* O */
  {
    long    status;
    long    q_status;
    int     type = 2; 
    char    str[512];
    char    out_str[80];
    static  char *fname = "WFGlist_commands";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " app_name      = <%s>\n", app_name));

   if (strcmp (workflow_name, "") != 0)
    {
      /* If there are any single tics in the workflow name tic them (RIS) */

      out_str[0] = 0;
      WFGtic_it (workflow_name, out_str);
      sprintf (str,
             "SELECT %s, %s FROM %s WHERE %s = '%s' AND %s AND %s %s", 
               "n_commandname, n_application, n_entity, n_transcommand", 
               "n_nfmcommandno", "nfmcommands, nfmtransitions, nfmworkflow",
               "nfmworkflow.n_workflowname", out_str,
               "nfmtransitions.n_workflowno = nfmworkflow.n_workflowno",
               "nfmtransitions.n_commandno = nfmcommands.n_commandno",
               "ORDER BY nfmcommands.n_commandname, nfmcommands.n_application");
    }
   else if (strcmp (app_name, "") != 0)
      sprintf (str,
               "SELECT %s, %s FROM %s WHERE %s = '%s' ORDER BY %s", 
               "n_commandname, n_application, n_entity, n_transcommand", 
               "n_nfmcommandno", "nfmcommands", "n_application", app_name,
               "nfmcommands.n_commandname");

   else 
      sprintf (str,
               "SELECT %s, %s FROM %s ORDER BY %s", 
               "n_commandname, n_application, n_entity, n_transcommand", 
               "n_nfmcommandno", "nfmcommands",
               "nfmcommands.n_commandname, nfmcommands.n_application"); 

   q_status = SQLquery (str, data_list, 4 * MEM_SIZE); 
   if ((q_status != SQL_S_SUCCESS) && (q_status != SQL_I_NO_ROWS_FOUND))
     {
          MEMclose (data_list);
          *data_list = NULL;
          _NFMdebug ((fname, "SQLquery : q_status = <0x%.8x>\n", q_status));
          status = NFM_E_SQL_QUERY;
          ERRload_struct (NFM, status, NULL);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

   if (q_status == SQL_S_SUCCESS)
      q_status = NFM_S_SUCCESS; 
   else
      q_status = NFM_E_NO_COMMANDS_FOUND; 

   status = _WFGget_cmd_synonyms (type, attr_list);
   if (status != NFM_S_SUCCESS)
    {
        MEMclose (data_list);
        *data_list = NULL;
        MEMclose (attr_list);
        *attr_list = NULL;
        _NFMdebug ((fname, "_WFGget_cmd_synonyms : status = <0x%.8x>\n",
                    status));
        return (status);
    }
   
/*
   status = _WFGget_table_no ("nfmcommands", &table_no); 
   if (status != NFM_S_SUCCESS)
    {
        MEMclose (data_list);
        *data_list = NULL;
        _NFMdebug ((fname, "_WFGget_table_no : status = <0x%.8x>\n", status));
        return (status);
    }

   / * build the synonym_attr_list  * /

   syn_list[0] = 0;
   strcat (syn_list, "n_commandname");
   strcat (syn_list, "\1");
   strcat (syn_list, "n_application");
   strcat (syn_list, "\1");
   strcat (syn_list, "n_entity");
   strcat (syn_list, "\1");
   strcat (syn_list, "n_transcommand");
   strcat (syn_list, "\1");
   strcat (syn_list, "n_nfmcommandno");
   strcat (syn_list, "\1");

   / * put the synonyms in the attr_list * /

   status = _WFGget_attribute_synonyms (table_no, syn_list, attr_list);
   if (status != NFM_S_SUCCESS)
    {
        MEMclose (data_list);
        *data_list = NULL;
        MEMclose (attr_list);
        *attr_list = NULL;
        _NFMdebug ((fname, "_WFGget_attribute_synonyms : status = <0x%.8x>\n",
                    status));
        return (status);
    }
*/
   
    _NFMdebug ((fname, " Returning SUCCESS : q_status = <0x%.8x>\n", q_status));
    return (q_status);
  }

