#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMchange_project (user_id, lop_attr, lop_data)
   long      user_id;
   MEMptr    lop_attr, lop_data;
   {
     static char *fname = "NFMchange_project" ;
     long     status;
     long     NFMupdate_lop_entry ();

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
/******
     status = MEMbuild_array (lop_attr);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (lop_data);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }
************/
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMupdate_lop_entry (NFMglobal.NFMuserid, lop_attr, lop_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);

        _NFMdebug ((fname, "Update Lop Entry : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMupdate_lop_entry (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMupdate_lop_entry" ;
     long    status;
     char    *sql_str, *sql_str1;
     char    **column, **data, **data1;
     long    x, y, count, count1, mod, comma;
     long    a, b, d;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))         a = y;
        else if (! strcmp (column [y], "n_datatype"))     b = y;
        else if (! strcmp (column [y], "n_application"))  d = y;
      }

     sql_str = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str [0] = 0;

     sql_str1 = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str1 [0] = 0;

     sprintf (sql_str,  "UPDATE %s SET ", "NFMPROJECTS");
     sprintf (sql_str1, "%s", " WHERE ");

     comma = 0;  mod = 0;

     count1 = data_list -> columns ;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
	mod = 0 ;

        if (! strcmp (data [count + d], "NFM"))
         {

           if (! strcmp (data [count + a], "n_projectno"))
            {
              mod = 0;

              strcat (sql_str1, data [count + a]);
              strcat (sql_str1, " = ");
	      strcat (sql_str1, data1 [x]);
            }
/*********
           else if (! strcmp (data [count + a], "n_application"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_projectname"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_projectdesc"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_projectmgr"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_stateno"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_aclno"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_archivestate"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_archiveno"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendingflag"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendinguser"))
              mod = 0;
           else if (strcmp (data1 [x], data1 [count1 + x]))
	     mod = 1;
******/
           if (strcmp (data1 [x], data1 [count1 + x]))
	     mod = 1;

           if (mod)
            {
              if (comma)  strcat (sql_str, ", ");
              else comma  = 1;

              strcat (sql_str, data [count + a]);
              strcat (sql_str, " = ");

              if (! strncmp (data [count + b], "char", 4))
               {
                 strcat (sql_str, "'");
                 strcat (sql_str, data1 [x]);
                 strcat (sql_str, "'");
               }
              else
                 strcat (sql_str, data1 [x]);
            }              

           mod = 0;
         }
      }

     strcat (sql_str, sql_str1);
     if (comma)
       {
	 status = SQLstmt (sql_str);
	 if (status != SQL_S_SUCCESS)
	   {
	     free (sql_str);
	     free (sql_str1);
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_SQL_STMT);
	   }
       }

     free (sql_str);
     free (sql_str1);
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }




