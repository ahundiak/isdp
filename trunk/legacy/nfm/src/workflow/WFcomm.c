#include "machine.h"
#include <ctype.h>
/* #include "NFMdb.h" */
#include "WF.h"

 long WFload_commands (user_id, app_name, file_name)
   long    user_id;
   char    *app_name, *file_name;
   {
     char *fname = "WFload_commands" ;
     long    status;
     FILE    *infile, *fopen ();
     char    inline [512], state [20];
     MEMptr  comm_attr = NULL, comm_data = NULL, comm_value = NULL;
     long    WFquery_commands ();
     long    WFupdate_commands ();
     long    WFload_commands_list ();

     _NFMdebug ((fname, "App  Name = <%s> : Comm File = <%s>\n", 
		 app_name, file_name));

     if (! strlen (app_name))
      {
        status = NFM_E_APPLICATION_TYPE;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Bad APP Type : status = <0x%.8x>\n", status));
        return (status);
      }

     infile = fopen (file_name, "r");
     if (! infile)
      {
        status = NFM_E_OPEN_FILE;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Open input File : status = <0x%.8x>\n",
        status));
        return (status);       
      }

     inline [0] = 0;

     status = WFfread_file (inline, infile);
     if (status != NFM_S_SUCCESS)
      {
        fclose (infile);
        _NFMdebug ((fname, "Fread File : status = <0x%.8x>\n", status));
        return (status);       
      }
   
     state [0] = 0;
     status = NFM_S_SUCCESS;

     while (status == NFM_S_SUCCESS)
      {
        if (! strcmp (inline, "NFMCOMMANDS"))
         {
           sprintf (state, "%s", "NFMCOMMAND");

           status = WFquery_commands (user_id, app_name,
                    &comm_attr, &comm_data, &comm_value);
           if (status != NFM_S_SUCCESS)
            {
              fclose (infile);
              MEMclose (&comm_attr);
              MEMclose (&comm_data);
              MEMclose (&comm_value);
              _NFMdebug ((fname, "Qry Comm : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else if (! strcmp (state, "NFMCOMMAND"))
         {
           status = WFload_commands_list (user_id, app_name,
                    comm_attr, comm_data, inline);
           if (status != NFM_S_SUCCESS)
            {
              fclose (infile);
              MEMclose (&comm_attr);
              MEMclose (&comm_data);
              MEMclose (&comm_value);
              _NFMdebug ((fname, "Ld Comm : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else
         {
           status = NFM_E_INVALID_PARAMETER;
	ERRload_struct(NFM,status,"",NULL);
           if (status != NFM_S_SUCCESS)
            {
              fclose (infile);
              MEMclose (&comm_attr);
              MEMclose (&comm_data);
              MEMclose (&comm_value);
              _NFMdebug ((fname, "Invalid Parm : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }

        status = WFfread_file (inline, infile);
        if ((status != NFM_S_SUCCESS) && (status != EOF))
         {
           fclose (infile);
           MEMclose (&comm_attr);
           MEMclose (&comm_data);
           MEMclose (&comm_value);
           _NFMdebug ((fname, "Read File : status = <0x%.8x>\n", status));
           return (status);
         }
      }

     fclose (infile);

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&comm_attr);
        MEMclose (&comm_data);
        MEMclose (&comm_value);
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFupdate_commands (user_id, comm_attr, comm_data);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&comm_attr);
        MEMclose (&comm_data);
        MEMclose (&comm_value);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Enter States : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&comm_attr);
        MEMclose (&comm_data);
        MEMclose (&comm_value);
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     MEMclose (&comm_attr);
     MEMclose (&comm_data);
     MEMclose (&comm_value);

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
   }

 long WFquery_commands (user_id, app_name,
                        attr_list, data_list, value_list)
   long      user_id;
   char      *app_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     char *fname = "WFquery_commands" ;
     long     status;
     long     a, b, d, x, y, count, comma;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024] ;
     long     column_of_valueno, row_of_nfmcomm_no ;

     _NFMdebug ((fname, "App  Name = <%s>\n", app_name));

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMCOMMANDS", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1; column_of_valueno = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno")) column_of_valueno = y+1;
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (status);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMCOMMANDS");
     comma = 0;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_application"))
          {
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, app_name);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, app_name);
          }
	 else  if (! strcmp (data [count + a], "n_nfmcommandno"))
	   {
	     row_of_nfmcomm_no = x + 1 ;
	   }

         if (comma) strcat (sql_str, ", ");
         comma = 1;

         strcat (sql_str, data [count + a]);
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_SQL_QUERY;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
        return (status);
      }

     sql_str [0] = 0;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (y == a) strcat (sql_str, "n_status");
        else if (y == b) strcat (sql_str, "char(15)");
        else if (y == d) strcat (sql_str, "STATUS");

        strcat (sql_str, "\1");
      }

     status = MEMwrite (*attr_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (status);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (status);
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);;
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        sql_str [0] = 0;

        for (y = 0; y < list -> columns; ++y)
         {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
         }
 
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (status);
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (status);
      }

     strcpy (sql_str1, "select n_commandno, n_commandname from nfmcommands where n_application = 'NFM' and n_transcommand = 'Y' order by n_commandno");

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_nfmcomm_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long WFupdate_commands (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     char *fname = "WFpdate_commands" ;
     long    status;
     long    a, b, i, x, y, count;
     char    **column, **data, **data1;
     char    app_name [10];
     long    WFadd_commands ();
     long    WFdrop_commands ();

     _NFMdebug ((fname, "ENTER\n")) ;
  
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_application"))   i = x;
      }

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        if (! x)    sprintf (app_name, "%s", data1 [count + i]);
        else if (strcmp (app_name, data1 [count + i]))
         {
           status = NFM_E_COMM_MUL_APP;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Mul App Commands : status = <0x%.8x>\n", 
           status));
           return (status);      
         }
      }
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", status));
        return (status);      
      }

     status = WFadd_commands (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Wf Comms : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFdrop_commands (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop WF Comms : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }
  
 long WFadd_commands (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFadd_commands" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     long   comm_no;
     char   value [50];

     _NFMdebug ((fname, "ENTER\n")) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_status"))  i = x;
      }
     
     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMchange_case (data1 [count1 + i], 0);

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMCOMMANDS");
           sprintf (sql_str1, ") VALUES (");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_commandno"))
               {
                 status = NFMget_serial_slot (user_id, "nfmcommands",
                          data [count + a], &comm_no);
                 if (status != NFM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
                    _NFMdebug ((fname, "Serial Slot : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
  
                 sprintf (value, "%d", comm_no);

                 status = MEMwrite_data (data_list, value, y + 1, x + 1);
                 if (status != MEM_S_SUCCESS) /* DUR 1/7/91*/
                  {
                    free (sql_str);
                    free (sql_str1);
                    status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
               }

              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1, ", ");
                  }
                 comma = 1;

                 strcat (sql_str, data [count + a]);
  
                 if (! strncmp (data [count + b], "char", 4))
                  {
                    strcat (sql_str1, "'");
                    strcat (sql_str1, data1 [count1 + x]);
                    strcat (sql_str1, "'");
                  }
                 else
                  {
                    if (strlen (data1 [count1 + x]))
                       strcat (sql_str1, data1 [count1 + x]);
                    else
                       strcat (sql_str1, "null");
                  }
               }
            }

           strcat (sql_str, sql_str1);
           strcat (sql_str, ")");

           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);

              if (status != SQL_E_DUPLICATE_VALUE)
               {
                 status = NFM_E_COMMAND_EXISTS;
	ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Dup Comm : status = <0x%.8x>\n",
                 status));
                 return (status);
               }

              status = NFM_E_SQL_STMT;
	ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFdrop_commands (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     char *fname = "WFdrop_commands" ;

     _NFMdebug ((fname, "ENTER\n")) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFload_commands_list (user_id, app_name,
                            attr_list, data_list, inline)
   long     user_id;
   char     *app_name;
   MEMptr   attr_list, data_list;
   char     *inline;
   {
     char *fname = "WFload_commands_list" ;
     long    status;
     char    *sql_str, *token, *strtok ();
     long    comm_no;
     char    value [50];
     long    x, y, z, count, c;
     char    **column, **data;
     
     _NFMdebug ((fname, "App    Name : <%s> : Inline : <%s>\n", 
		 app_name, inline));

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);          
      }

     sql_str = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);          
      }
     sql_str [0] = 0;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     for (y = 0; y < attr_list -> columns; ++y)
       if (! strcmp (column [y], "n_name"))    c = y;

     y = 0;
      
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        _NFMdebug ((fname, "Column Name : <%s>", data [count + c]));

        if (! strcmp (data [count + c], "n_commandno"));
        else if (! strcmp (data [count + c], "n_application"))
          strcat (sql_str, app_name);
        else if (! strcmp (data [count + c], "n_status"))
          strcat (sql_str, "ADD");
        else
         {
           if (y)     token = strtok (NULL, "|");
           else       token = strtok (inline, "|");

           y = 1;

           if (! strcmp (data [count + c], "n_nfmcommandno"))
            {
              if (token) 
               {
                 for (z = strlen (token);
                      isspace (token [z - 1]) && z > 0;
                      --z)
                  token [z - 1] = 0;
 
                 if (strlen (token))
                  {
                    status = NFMget_command_no (user_id, token, &comm_no);
                    if (status != NFM_S_SUCCESS)
                     {
                       free (sql_str);
                       _NFMdebug ((fname, "Comm No : status = <0x%.8x>\n",
                       status));
                       return (status);                       
                     }

                    sprintf (value, "%d", comm_no);

                    strcat (sql_str, value);
                  }
                 else strcat (sql_str, "");
               }
              else strcat (sql_str, "");
            }
           else if (token) strcat (sql_str, token);
         }

        strcat (sql_str, "\1");
      }

     _NFMdebug ((fname, "Sql Str : <%s>\n", sql_str));
      
     status = MEMwrite (data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        status = (NFM_E_MEM);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);         
   }
