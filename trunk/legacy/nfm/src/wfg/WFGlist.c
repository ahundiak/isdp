#include "machine.h"
#include "WFG.h"

/***************************************************************************
 *                                                                         *
 *  Date:  July 9, 1991.                                                   *
 *                                                                         *
 *  Functions:  WFGlist_wfs                                                *
 *              WFGlist_states                                             *
 *              WFGlist_classes                                            *
 *              WFGlist_transitions                                        *
 *              WFGlist_class_access                                       *
 *              WFGlist_commands_short                                     *
 *              WFGlist_commands_long                                      *
 *                                                                         *
 *  These functions hardcode the attributes in the query and in the        *
 *  attr_list.  These functions work like the NFMlist functions except     *
 *  They only support search and sort input strings (not filenames).       * 
 *                                                                         *
 ***************************************************************************/


/***************************************************************************
 *                                                                         *
 *  Function WFGlist* :  These functions will take a search_str            *
 *                       and a sort_str if they are given and              *
 *                       use them as the search/sort criteria, otherwise   *
 *                       the default criteria will be used.                *
 *                                                                         *
 *-------------------------------------------------------------------------*
 *                                                                         * 
 *  type accepts listing types of :                                        *
 *                                  Long Format  = 0 (all data)            *
 *                                  Short Format = 1 (name, number only)   *
 *                                                                         * 
 *                                                                         * 
 *  type determines if long listing or short listing is to be generated    * 
 *                                                                         * 
 ***************************************************************************/


long WFGlist_wfs (user_id, search_str, sort_str, type, attr_list, data_list)
  long		user_id;        /* I */
  char          *search_str;    /* I */
  char          *sort_str;      /* I */
  int           type;           /* I :  0 = list all,  1 = list specific. */
  MEMptr	*attr_list;     /* O :  contains the synonyms     */
  MEMptr	*data_list;     /* O :  contains the data         */
  {
    long    status;
    int     i;
    char    where_clause[1024]; 
    char    order_clause[512]; 
    char    str[2048];
    static  char *fname = "WFGlist_wfs";

    _NFMdebug ((fname, " type       = <%d>\n", type));
    _NFMdebug ((fname, " search_str = <%s>\n", search_str));
    _NFMdebug ((fname, " sort_str   = <%s>\n", sort_str));

    /* process the search (where) clause */

    if (strcmp (search_str, "") == 0)  /* default search criteria */
        strcpy (where_clause, "nfmworkflow.n_workflowno > 0");
    else 
        strcpy (where_clause, search_str);

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    if (strcmp (sort_str, "") == 0)    /* default sort criteria */
        strcpy (order_clause, "nfmworkflow.n_workflowname");
    else 
        strcpy (order_clause, sort_str);

    if (type == 0)   /* list all */
        sprintf (str, "SELECT nfmworkflow.n_workflowname,nfmworkflow.n_workflowdesc, nfmstates.n_statename, nfmacls.n_aclname FROM nfmworkflow, nfmstates, nfmacls WHERE nfmstates.n_stateno = nfmworkflow.n_stateno AND nfmacls.n_aclno = nfmworkflow.n_aclno AND %s ORDER BY %s", where_clause, order_clause);
    else
        sprintf (str, "SELECT n_workflowno, n_workflowname from nfmworkflow WHERE %s ORDER BY %s", where_clause, order_clause);

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
               status = NFM_E_NO_WORKFLOWS_FOUND;

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
         MEMclose (attr_list);
         *attr_list = NULL;
         MEMclose (data_list);
         *data_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Putting the synonyms into the output_buffer\n"));

    if (type == 0)
     {
         for (i = 0; i < 4; ++i)
          {
             str[0] = 0;
             switch (i)
              {
                 case 0:
                    strcat (str, "Workflow Name");
                 break;

                 case 1:
                    strcat (str, "Workflow Description");
                 break; 

                 case 2:
                    strcat (str, "State Name");
                 break;
             
                 case 3:
                    strcat (str, "ACL Name");
                 break;
              }

             strcat (str, "\1");

             status = MEMwrite (*attr_list, str);
             if (status != MEM_S_SUCCESS)
              {
                  MEMclose (attr_list);
                  *attr_list = NULL;
                  MEMclose (data_list);
                  *data_list = NULL;
                  status = NFM_E_MEM;
                  _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
                  return (status);
              }
          } 
     }
    else
     {
          str[0] = 0;
          strcat (str, "Workflow Number");
          strcat (str, "\1");

          status = MEMwrite (*attr_list, str);
          if (status != MEM_S_SUCCESS)
           {
               MEMclose (attr_list);
               *attr_list = NULL;
               MEMclose (data_list);
               *data_list = NULL;
               status = NFM_E_MEM;
               _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
               return (status);
           }

          str[0] = 0;
          strcat (str, "Workflow Name");
          strcat (str, "\1");

          status = MEMwrite (*attr_list, str);
          if (status != MEM_S_SUCCESS)
           {
               MEMclose (attr_list);
               *attr_list = NULL;
               MEMclose (data_list);
               *data_list = NULL;
               status = NFM_E_MEM;
               _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
               return (status);
           }
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGlist_states (user_id, workflow_name, search_str, sort_str, type,
                     attr_list, data_list)
  long		user_id;
  char          *workflow_name;
  char          *search_str;
  char          *sort_str;
  int           type;            /* 0 = list all,   1 = list specific. */
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status, q_status = NFM_S_SUCCESS;
    int     i;
    char    where_clause[1024]; 
    char    order_clause[512]; 
    char    str[2048];
    char    out_str[80];
    static  char *fname = "WFGlist_states";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));
    _NFMdebug ((fname, " type          = <%d>\n", type));
    _NFMdebug ((fname, " search_str    = <%s>\n", search_str));
    _NFMdebug ((fname, " sort_str      = <%s>\n", sort_str));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    if (strcmp (search_str, "") == 0)  /* default search criteria */
     {
         sprintf (where_clause, "(nfmworkflow.n_workflowname = '%s' AND nfmworkflow.n_workflowno = nfmstates.n_workflowno) OR (nfmstates.n_stateno = 0 OR nfmstates.n_stateno = 1)", out_str); 
     }
    else 
         strcpy (where_clause, search_str);

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    if (strcmp (sort_str, "") == 0)    /* default sort criteria */
        strcpy (order_clause, "nfmstates.n_seqno, nfmstates.n_statename");
    else 
        strcpy (order_clause, sort_str);

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    if (type == 0)   /* list all */
        sprintf (str, "SELECT DISTINCT n_statename, n_statedesc,n_signoffs, n_majority, n_transfrom, n_transto, n_seqno FROM nfmstates, nfmworkflow WHERE %s ORDER BY %s", where_clause, order_clause);
    else
        sprintf (str, "SELECT DISTINCT n_stateno, n_statename FROM nfmstates WHERE %s ORDER BY %s", where_clause, order_clause);

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

    if (type == 0)
     {
         for (i = 0; i < 7; ++i)
          {
             str[0] = 0;
             switch (i)
              {
                 case 0:
                    strcat (str, "State Name");
                 break;

                 case 1:
                    strcat (str, "State Description");
                 break; 

                 case 2:
                    strcat (str, "No. Signoff Users");
                 break;
             
                 case 3:
                    strcat (str, "Signoff Type");
                 break;
             
                 case 4:
                    strcat (str, "Trans From");
                 break;
             
                 case 5:
                    strcat (str, "Trans To");
                 break;
             
                 case 6:
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
     }
    else
     {
          str[0] = 0;
          strcat (str, "State Number");
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
          strcat (str, "State Name");
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


long WFGlist_classes (user_id, workflow_name, search_str, sort_str, type,
                      attr_list, data_list)
  long		user_id;
  char          *workflow_name;
  char          *search_str;
  char          *sort_str;
  int           type;            /* 0 = list all,   1 = list specific. */
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status;
    char    where_clause[1024]; 
    char    order_clause[512]; 
    char    str[2048];
    char    out_str[80];
    static  char *fname = "WFGlist_classes";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));
    _NFMdebug ((fname, " type          = <%d>\n", type));
    _NFMdebug ((fname, " search_str    = <%s>\n", search_str));
    _NFMdebug ((fname, " sort_str      = <%s>\n", sort_str));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    if (strcmp (search_str, "") == 0)  /* default search criteria */
     {
         sprintf (where_clause, "nfmworkflow.n_workflowname = '%s' AND nfmworkflow.n_workflowno = nfmclasses.n_workflowno", out_str); 
     }
    else 
         strcpy (where_clause, search_str); 
 
    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    if (strcmp (sort_str, "") == 0)    /* default sort criteria */
        strcpy (order_clause, "nfmclasses.n_classname");
    else 
        strcpy (order_clause, sort_str);

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    if (type == 0)   /* list Long */
        sprintf (str, "SELECT n_classname FROM nfmclasses, nfmworkflow WHERE %s ORDER BY %s", where_clause, order_clause);
    else
        sprintf (str, "SELECT n_classno, n_classname FROM nfmclasses WHERE %s ORDER BY %s", where_clause, order_clause);

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

    if (type == 0)
     {
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
     }
    else
     {
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
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGlist_transitions (user_id, workflow_name, search_str, sort_str, type, 
                          attr_list, data_list)
  long		user_id;
  char          *workflow_name;
  char          *search_str;
  char          *sort_str;
  int           type;            /* 0 = list all,   1 = list specific. */
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {
    long    status, q_status;
    int     i, j, count, k, count1;
    char    where_clause[1024]; 
    char    order_clause[512]; 
    char    str[2048];
    char    out_str[80];
    char    **data, **s_data;
    MEMptr  state_list = NULL;
    MEMptr  list = NULL;
    static  char *fname = "WFGlist_transitions";

    _NFMdebug ((fname, " workflow_name = <%d>\n", workflow_name));
    _NFMdebug ((fname, " type          = <%d>\n", type));
    _NFMdebug ((fname, " search_str    = <%s>\n", search_str));
    _NFMdebug ((fname, " sort_str      = <%s>\n", sort_str));

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    if (strcmp (search_str, "") == 0)  /* default search criteria */
     {
         sprintf (where_clause, 
                  "%s = '%s' AND %s = %s AND %s = %s AND %s = %s",
                  "nfmworkflow.n_workflowname",  out_str,  
                  "nfmtransitions.n_workflowno", "nfmworkflow.n_workflowno",
                  "nfmtransitions.n_commandno",  "nfmcommands.n_commandno",
                  "nfmtransitions.n_fromstate",  "nfmstates.n_stateno"); 
     }
    else 
         strcpy (where_clause, search_str);

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    if (strcmp (sort_str, "") == 0)    /* default sort criteria */
        sprintf (order_clause, "%s, %s", "nfmtransitions.n_transitionname",
                 "nfmstates.n_statename");
    else 
         strcpy (order_clause, sort_str);

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    if (type == 0)
     {
        /* Get the List of states for the workflow in order to replace the
           to_statename with the actual state name.                         */
    
        sprintf (str,
                 "SELECT DISTINCT nfmstates.n_stateno,nfmstates.n_statename FROM nfmworkflow, nfmstates WHERE nfmworkflow.n_workflowname = '%s' AND nfmworkflow.n_workflowno = nfmstates.n_workflowno OR (nfmstates.n_stateno = 0 OR nfmstates.n_stateno = 1)", out_str );
    
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
     }

    /* list all */

    if (type == 0)   /* list all */
        sprintf (str,
                 "SELECT nfmtransitions.n_transitionname,nfmcommands.n_commandname, nfmstates.n_statename,nfmtransitions.n_tostate, nfmtransitions.n_logonsuccess,nfmtransitions.n_logonfailure, nfmtransitions.n_notify FROM nfmtransitions, nfmcommands, nfmstates, nfmworkflow WHERE %s ORDER BY %s",
                 where_clause, order_clause);
    else
        sprintf (str, "SELECT n_transitionno, n_transitionname FROM nfmtransitions WHERE %s ORDER BY %s", where_clause, order_clause);

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    if (type == 0)
     {
        q_status = SQLquery (str, &list, 4 * MEM_SIZE); 
        if ((q_status != SQL_S_SUCCESS) && (q_status != SQL_I_NO_ROWS_FOUND))
         {
             MEMclose (&state_list);
             MEMclose (&list);
             _NFMdebug ((fname, "SQLquery :q_ status = <0x%.8x>\n", q_status));
             return (q_status);
        }
     }
    else
     {
        q_status = SQLquery (str, data_list, 4 * MEM_SIZE); 
        if ((q_status != SQL_S_SUCCESS) && (q_status != SQL_I_NO_ROWS_FOUND))
         {
             MEMclose (data_list);
             *data_list = NULL;
             _NFMdebug ((fname, "SQLquery :q_ status = <0x%.8x>\n", q_status));
             return (q_status);
        }
         q_status = NFM_S_SUCCESS;
     }

    if ((q_status == SQL_S_SUCCESS) && (type == 0))
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
                 if ((j == 3) && (strlen (data[count]) > 0))
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

    if (type == 0)      /* TRUE: Long Listing */
     {
         for (i = 0; i < 7; ++i)
          {
             str[0] = 0;
             switch (i)
              {
                 case 0:
                    strcat (str, "Transition Name");
                 break;

                 case 1:
                    strcat (str, "Command Name");
                 break; 

                 case 2:
                    strcat (str, "From State Name");
                 break;
             
                 case 3:
                    strcat (str, "To State Name");
                 break;
             
                 case 4:
                    strcat (str, "Log on Success");
                 break;
             
                 case 5:
                    strcat (str, "Log on Failure");
                 break;
             
                 case 6:
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
     }
    else   /* FALSE: short_listing */
     {
          str[0] = 0;
          strcat (str, "Transition Number");
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
          strcat (str, "Transition Name");
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



long WFGlist_class_access (user_id, workflow_name, search_str, sort_str, 
                           attr_list, data_list)
  long		user_id;
  char          *workflow_name;
  char          *search_str;
  char          *sort_str;
  MEMptr	*attr_list;
  MEMptr	*data_list;
  {

    long    status, q_status;
    int     i, j, k, count, count1, no_cols;
    char    where_clause[1024]; 
    char    order_clause[512]; 
    char    str[2048];
    char    **data;
    char    **s_data;
    char    out_str[80];
    MEMptr  list = NULL;
    MEMptr  state_list = NULL;
    static  char *fname = "WFGlist_class_access";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " search_str    = <%s>\n", search_str));
    _NFMdebug ((fname, " sort_str      = <%s>\n", sort_str));

    no_cols = 4;

    /* If there are any single tics in the workflow name tic them (RIS) */

    out_str[0] = 0;
    WFGtic_it (workflow_name, out_str);

    /* process the search (where) clause */

    if (strcmp (search_str, "") == 0)  /* default search criteria */
     {
         sprintf (where_clause, 
                  "nfmworkflow.n_workflowname = '%s' AND nfmtransitions.n_workflowno = nfmworkflow.n_workflowno AND nfmclasses.n_workflowno = nfmworkflow.n_workflowno AND nfmtransitions.n_transitionno = nfmaccess.n_transitionno AND nfmclasses.n_classno = nfmaccess.n_classno AND nfmstates.n_stateno = nfmtransitions.n_fromstate", out_str );
     }
    else 
          strcpy (where_clause, search_str);

    _NFMdebug ((fname, " WHERE_CLAUSE = <%s>\n", where_clause));

    /* process the sort (order by) clause */

    if (strcmp (sort_str, "") == 0)    /* default sort criteria */
        strcpy (order_clause, "nfmclasses.n_classname, nfmtransitions.n_transitionname, nfmstates.n_statename");
    else 
        strcpy (order_clause, sort_str);

    _NFMdebug ((fname, "ORDER BY CLAUSE = <%s>\n", order_clause));

    /* Get the List of states for the workflow in order to replace the
       to_statename with the actual state name.                         */

    sprintf (str,
             "SELECT DISTINCT nfmstates.n_stateno, nfmstates.n_statename FROM nfmworkflow, nfmstates WHERE nfmworkflow.n_workflowname = '%s' AND nfmworkflow.n_workflowno = nfmstates.n_workflowno OR (nfmstates.n_stateno = 0 OR nfmstates.n_stateno = 1)", out_str );

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
             "SELECT nfmclasses.n_classname,nfmtransitions.n_transitionname, nfmstates.n_statename,nfmtransitions.n_tostate FROM nfmclasses, nfmaccess, nfmtransitions,nfmworkflow, nfmstates WHERE %s ORDER BY %s",
		 where_clause, order_clause);

    _NFMdebug ((fname, "SQL string = <%s>\n", str));

    q_status = SQLquery (str, &list, 4 * MEM_SIZE); 
    if ((q_status != SQL_S_SUCCESS) &&
        (q_status != SQL_I_NO_ROWS_FOUND))
     {
          MEMclose (&state_list); 
          MEMclose (&list); 
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", q_status));
          status = NFM_E_SQL_QUERY;
          ERRload_struct (NFM, status, NULL);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
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
    
        status = MEMwrite_format (*data_list, "n_classname", "char(20)");
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

        data   = (char **) list->data_ptr;
        s_data = (char **) state_list->data_ptr;
    
        for (i = 0; i < list->rows; ++i)
         {
            str[0] = 0;
            for (j = 0; j < no_cols; ++j)
             {
                count = list->columns * i + j;
                if ((j == no_cols -1) && (strlen (data[count]) > 0))
                 {
                    /* substitute the n_tostate (no) for the to_state name */
    
                    for (k = 0; k < state_list->rows; ++k)
                     {
                        count1 = state_list->columns * k;
                        if (strcmp (s_data[count1], data[count]) == 0)
                         {
                           strcat (str, s_data[count1 + 1]);
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
    else
        q_status = NFM_E_NO_CLASS_ACCESS_DEFINED;
    
    MEMclose (&list);
    MEMclose (&state_list);

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
         MEMclose (attr_list);
         *attr_list = NULL;
         MEMclose (data_list);
         *data_list = NULL;
         status = NFM_E_MEM;
         _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status));
         return (status);
     }

    _NFMdebug ((fname, " Putting the synonyms into the attr_list\n"));

    for (i = 0; i < no_cols; ++i)
     {
        str[0] = 0;

        switch (i)
         {
            case 0 :
                 strcat (str, "Class Name");
            break; 
            
            case 1 :
                 strcat (str, "Transition Name");
            break; 
            
            case 2 :
                 strcat (str, "From State Name");
            break; 
            
            case 3 :
                 strcat (str, "To State Name");
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
 *  Function : WFGlist_commands_short                                       *
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
 *  This function returns n_commandname (and application) in the            * 
 *  output_buffer.                                                          *
 *                                                                          *
 ****************************************************************************/

long WFGlist_commands_short (workflow_name, app_name, attr_list, data_list)
  char          *workflow_name;  /* I: if given app_name should be null */
  char          *app_name;       /* I: if given workflow_name should be null */
  MEMptr	*attr_list;      /* O */
  MEMptr	*data_list;      /* O */
  {
    long    status;
    long    q_status;
    int     type = 0;
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
               "SELECT DISTINCT nfmcommands.n_commandname FROM nfmcommands, nfmtransitions, nfmworkflow WHERE nfmworkflow.n_workflowname = '%s' AND nfmtransitions.n_workflowno = nfmworkflow.n_workflowno AND nfmtransitions.n_commandno = nfmcommands.n_commandno ORDER BY nfmcommands.n_commandname", out_str );
      type = 0;
    }
   else if (strcmp (app_name, "") != 0)
    {
      sprintf (str,
               "SELECT n_commandname FROM nfmcommands WHERE n_application = '%s' AND (n_entity='I' OR n_entity='N' OR n_entity='D')", app_name );
      type = 0;
    }

   else 
    {
      strcpy (str,
               "SELECT n_commandname, n_application FROM nfmcommands WHERE n_entity='I' OR n_entity='N' OR n_entity='D' ORDER BY n_application, n_commandname" );
      type = 1;
    }

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

   /* build the synonym_attr_list  */

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

   syn_list[0] = 0;
   if ((strcmp (workflow_name, "") != 0) || (strcmp (app_name, "") == 0))
    {
        strcat (syn_list, "n_commandname");
        strcat (syn_list, "\1");
    }
   else
    {
        strcat (syn_list, "n_commandname");
        strcat (syn_list, "\1");
        strcat (syn_list, "n_application");
        strcat (syn_list, "\1");
    }

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



long WFGlist_applications (output_buffer)
  MEMptr	*output_buffer;  /* O */
  {
    long    status;
    char    str[512];
    static  char *fname = "WFGlist_applications";

    _NFMdebug ((fname, " function entered\n"));

    sprintf (str, "SELECT DISTINCT n_application FROM nfmcommands %s", 
             "ORDER BY n_application");

   status = SQLquery (str, output_buffer, 2 * MEM_SIZE); 
   if (status != SQL_S_SUCCESS)
     {
          MEMclose (output_buffer);
          *output_buffer = NULL;
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
               status = NFM_E_SQL_QUERY;
               ERRload_struct (NFM, status, NULL);
           }
          else
               status = NFM_E_NO_APPLICATIONS_FOUND;

          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
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

long WFGlist_commands_long (workflow_name, app_name, attr_list, data_list)
  char          *workflow_name;  /* I: if given app_name should be null */
  char          *app_name;       /* I: if given workflow_name should be null */
  MEMptr	*attr_list;      /* O */
  MEMptr	*data_list;      /* O */
  {
    long    status;
    long    q_status;
    int     type = 2; 
/*
    long    table_no;
    char    syn_list[256]; 
*/
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
             "SELECT DISTINCT n_commandname, n_application, n_entity,n_transcommand, n_nfmcommandno FROM nfmcommands, nfmtransitions,nfmworkflow WHERE nfmworkflow.n_workflowname = '%s' AND nfmtransitions.n_workflowno = nfmworkflow.n_workflowno AND nfmtransitions.n_commandno = nfmcommands.n_commandno ORDER BY nfmcommands.n_commandname, nfmcommands.n_application", out_str ); 
    }
   else if (strcmp (app_name, "") != 0)
      sprintf (str,
               "SELECT n_commandname, n_application, n_entity, n_transcommand, n_nfmcommandno FROM nfmcommands WHERE n_application = '%s' ORDER BY nfmcommands.n_commandname", app_name );

   else 
      strcpy (str,
               "SELECT n_commandname, n_application, n_entity, n_transcommand, n_nfmcommandno FROM nfmcommands ORDER BY nfmcommands.n_commandname, nfmcommands.n_application" );

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

