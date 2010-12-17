#include "machine.h"
#include "NFMA.h"

/****************************************************************************
 *                                                                          *
 *   Function: NFMload_processes.                                           *
 *   Date:     January 22, 1990                                             * 
 *                                                                          *
 *             This function is used to define a process to invoke          *
 *             for an existing transition.                                  *
 *                                                                          *
 *             This function will do the following for each row in the      *
 *             data_list.                                                   *
 *                  1.  Build the Insert statement.                         *
 *                  2.  add a row to table NFMPROCESSES.                    *
 *                                                                          *
 ****************************************************************************/

long NFMload_processes (user_id, attr_list, data_list)
  long	  user_id;
  MEMptr  attr_list;
  MEMptr  data_list;
{
  static char *fname = "NFMload_processes" ;
  long   status;
  long   SQLquery(), SQLstmt();
  long   MEMbuild_array(), MEMclose();
  int    i, s, t, p;
  int    x, y, n;
  int    a, b ;
  int    count;
  char   **data;
  char   **attr;
  char   **column;
  char   attr_str[512];
  char   value_str[512];
  char   sql_str[1024];

  _NFMdebug ((fname, "ENTER\n")) ;

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
     status = NFM_E_MEM;
     ERRload_struct(NFM,status,"",NULL);
     _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
     return (status);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
     status = NFM_E_MEM;
     ERRload_struct(NFM,status,"",NULL);
     _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
     return (status);
  }

  column = (char **) attr_list -> column_ptr;
  attr   = (char **) attr_list -> data_ptr;

  data  = (char **) data_list -> data_ptr;

  a = -1; b = -1; 

  for (y = 0; y < attr_list -> columns; ++y)
  {
     if (! strcmp (column [y], "n_name"))           a = y;
     else if (! strcmp (column [y], "n_datatype"))  b = y;
  }
       
  i = -1;
  t = -1;
  s = -1;
  p = -1;

  for (x = 0; x < attr_list -> rows; ++x)
  {
     count = attr_list -> columns * x;

     if (! strcmp (attr [count + a], "n_itemno"))              i = x;
     else if (! strcmp (attr [count + a], "n_transitionno"))  t = x;
     else if (! strcmp (attr [count + a], "n_seqno"))         s = x;
     else if (! strcmp (attr [count + a], "n_prepost"))       p = x;
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "Stop transaction : status = <0x%.8x>\n", status));
     return (status);
  }

  for (x = 0; x < data_list -> rows; ++x)
  {
     n = x * data_list -> columns;
     sprintf (sql_str, "INSERT INTO %s (", "NFMPROCESSES");
     sprintf (value_str, "%s", " VALUES (");
     attr_str[0] = 0;

     for (y = 0; y < attr_list -> rows; ++y)
     {
         count = attr_list -> columns * y;
         strcat (attr_str, attr [count + a]);

         if (y < attr_list -> rows - 1)
            strcat (attr_str, ", ");
         else
            strcat (attr_str, ")");

         if (! strncmp (attr [count + b], "char", 4))
         {
            strcat (value_str, "'");
            strcat (value_str, data [n +y]);
            strcat (value_str, "'");
         }
         else
         {
            if (strlen (data [n + y])) strcat (value_str, data [n + y]);
            else                    strcat (value_str, "null");   
         }

         if (y < attr_list -> rows - 1)
            strcat (value_str, ", ");
         else
            strcat (value_str, ")");
     }

     strcat (sql_str, attr_str); 
     strcat (sql_str, value_str); 
     _NFMdebug ((fname, "sql_str = <%s> ", sql_str));

     /* add a row to NFMprocess for the transition.             */ 

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
     {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt: status = <0x%.8x> ", status));
        return (status);
     } 
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "Start transaction : status = <0x%.8x>\n", status));
     return (status);
  }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

