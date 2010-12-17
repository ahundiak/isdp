#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

extern struct WFstruct WFinfo;

 long NFMadd_project (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "NFMadd_project" ;
     long    status;
     long    NFMadd_project_entry ();

     _NFMdebug ((fname, "ENTER\n")) ;
  
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", status));
        return (status);      
      }

     status = NFMadd_project_entry (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Project Entry : status = <0x%.8x>\n", status));
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
  


  long NFMadd_project_entry (user_id, attr_list, data_list)
    long       user_id;
    MEMptr     attr_list;
    MEMptr     data_list;
    {
      static char *fname = "NFMadd_project_entry" ;
      long    status;
      long    proj_no;
      int     insert = 0;
      char    lop_name [40];
      char    *sql_str, *sql_str1;
      char    **data, **column, **data1;
      int     a, b, i, x, y, comma, count;
      char    proj_val [40], date [20] ;
      long    NFMget_acl_state_no();

      _NFMdebug ((fname, "ENTER\n")) ;

      strcpy (lop_name, "NFMPROJECTS");;

      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS )
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEMbuild Array Failed : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }    

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS )
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEMbuild Array Failed : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }    

      sql_str = (char *) malloc (4 * data_list->row_size + MEM_SIZE);
      if (! sql_str)
       {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str [0] = 0;

      sql_str1 = (char *) malloc (4 * data_list->row_size + MEM_SIZE);
      if (! sql_str1)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str1 [0] = 0;

      a = -1; b = -1; 

      data1  = (char **) data_list -> data_ptr;
      data   = (char **) attr_list -> data_ptr;
      column = (char **) attr_list -> column_ptr;

      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      sprintf (sql_str, "INSERT INTO %s (", lop_name);
      strcpy (sql_str1, ") VALUES (");

      comma = 0;  i = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
         insert = 0;

              if (! strcmp (data [count + a], "n_archivestate"))  insert = 0;
         else if (! strcmp (data [count + a], "n_archiveno"))     insert = 0;
         else if (! strcmp (data [count + a], "n_stateno"))       insert = 0;
         else if (! strcmp (data [count + a], "n_pendingflag"))   insert = 0;
         else if (! strcmp (data [count + a], "n_projectname"))
          {
            insert = 1;
            sprintf (WFinfo.proj_name, "%s", data1 [x]);
          }
         else if (! strcmp (data [count + a], "n_projectno"))
          {
            insert = 1;

            proj_no = 0;
            status = NFMget_serial_slot (user_id, lop_name, data [count + a], 
                                         &proj_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "Get Serial Slot : status = <0x%.8x>\n",
                         status));
               return (status);
             }

            sprintf (proj_val, "%d", proj_no);
            WFinfo.proj_no = proj_no;

            status = MEMwrite_data (data_list, proj_val, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "MEMwrite_data : status = <0x%.8x>\n",status));
               return (status);
             }

            _NFMdebug ((fname, "Project No = <%d>\n", proj_no));

          }
         else if (! strcmp (data [count + a], "n_creationdate"))
          {
            insert = 1;
	    status = NFMget_RISdatetime (date) ;
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Failure : ris date time : status = <0x%.8x>\n",
			    status)) ;
		return (status) ;
	      }

            status = MEMwrite_data (data_list, date, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "MEMwrite_data : status = <0x%.8x>\n",status));
               return (status);
             }

          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
	    insert = 1;
	    WFload_acl_st (atol (data1 [x])) ;
	    
            status = WFload_wf_struct_for_sts () ;
            if (status != NFM_S_SUCCESS)
              {
                _NFMdebug ((fname, "load transition for acl %d failed : status = <0x%.8x>\n",
                            atol (data1 [x]), status)) ;
                return (status) ;
              }
          }
         else 
            insert = 1;

         if (insert) 
          {
            if (comma) 
             {
                strcat (sql_str , ", ");
                strcat (sql_str1, ", ");
             }
             else
                comma = 1;

            strcat (sql_str, data [count + a]);

            if (! strncmp (data [count + b], "char", 4)) 
	      {
		strcat (sql_str1, "'");
		strcat (sql_str1, data1 [x]);
		strcat (sql_str1, "'");              
	      }
	    else if (! strcmp (data [count + b], "timestamp"))
	      {
		strcat (sql_str1, "TIMESTAMP '") ;
		strcat (sql_str1, data1 [x]) ;
		strcat (sql_str1, "'") ;
	      }
            else
	      if (strlen (data1 [x])) strcat (sql_str1, data1 [x]);
	      else                    strcat (sql_str1, "null");
          }
       }/* for */
/****
      status = NFMget_acl_state_no (user_id, atol (data1[i]), &state_no);
      if (status != NFM_S_SUCCESS)
      {
         free (sql_str1);
         free (sql_str);
         _NFMdebug ((fname, "Get ACL State No : status = <0x%.8x>\n", status));
         return (status);
      }
*****/
      strcat (sql_str1, ")");
      strcat (sql_str, sql_str1);

      free (sql_str1);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS )
       {
         free (sql_str);

         if (status == SQL_E_DUPLICATE_VALUE)
          {
            ERRload_struct (NFM, NFM_E_DUP_PROJECT, "", NULL);
            _NFMdebug ((fname, "Project Exists : status = <0x%.8x>\n", 
                      NFM_E_DUP_PROJECT));
            return (NFM_E_DUP_PROJECT);         
          }

         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Syntax Error : status = <0x%.8x>\n", 
		     status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
    }

