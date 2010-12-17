#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;

 long NFMquery_project_acl_map (user_id, project_name,
                               attr_list, data_list, value_list)
   long      user_id;
   char      *project_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_project_acl_map" ;
     long     status;
     long     a, b, d, x, y, count, comma;
     long     proj_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno, row_of_proj_no, row_of_map_no ;

     _NFMdebug ((fname, "Project Name = <%s>\n", project_name));

     status = NFMget_project_no (user_id, project_name, &proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Project No : status = <0x%.8x>\n",
		    status));
        return (status);
      }

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMPROJECTACLMAP", attr_list, data_list, value_list);
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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1; column_of_valueno = -1 ;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno"))  column_of_valueno = y+1;
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMPROJECTACLMAP");
     comma = 0;
     row_of_proj_no = -1; row_of_map_no = -1;
     
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_projectno"))
          {
	    row_of_proj_no = x + 1 ;
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
      
            sprintf (value, "%d", proj_no);

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
          }
	 else  if (! strcmp (data [count + a], "n_mapno"))
	   {
	     row_of_map_no = x+1 ;
	   }

         if (comma) strcat (sql_str, ", ");
         comma = 1;

         strcat (sql_str, data [count + a]);
       }
    

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     sql_str [0] =0;

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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
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
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);
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
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     sprintf (sql_str1, "select nfmcatalogaclmap.n_mapno, nfmcatalogs.n_catalogname, nfmacls.n_aclname from nfmcatalogaclmap,nfmcatalogs,nfmacls \
where nfmcatalogaclmap.n_catalogno = nfmcatalogs.n_catalogno \
and nfmacls.n_aclno = nfmcatalogaclmap.n_aclno \
and nfmacls.n_complete = 'Y' \
order by nfmcatalogaclmap.n_mapno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_map_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
/**** alpha uses this to get the project no ******/
     sprintf (sql_str1, "select n_projectno, n_projectname from nfmprojects \
where n_projectno = %d",
	      proj_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_proj_no, 
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

 long NFMupdate_project_acl_map (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "NFMupdate_project_acl_map" ;
     long    status;
     long    a, b, i, x, y, count;
     char    **column, **data, **data1;
     char    tab_no [50];
     long    NFMadd_project_acl_map ();
     long    NFMdrop_project_acl_map ();

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
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
  
        if (! strcmp (data [count + a], "n_projectno")) i = x;
      }

     sprintf (tab_no, "%d", WFinfo.proj_no);

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        status = MEMwrite_data (data_list, tab_no, x + 1, i + 1);
        if (status != MEM_S_SUCCESS)
         {
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
		       status));
           return (NFM_E_MEM);      
         }
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
		    status));
        return (status);      
      }

     status = NFMdrop_project_acl_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop Proj Acl Map : status = <0x%.8x>\n", 
		    status));
        return (status);      
      }

     status = NFMadd_project_acl_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Proj Acl Map : status = <0x%.8x>\n", 
		    status));
        return (status);      
      }

     status = _NFMcheck_project_state (WFinfo.proj_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 NFMrollback_transaction (0) ;
	 _NFMdebug ((fname, "Bad project status = 0x%.8x\n",
		     status)) ;
	 return (status) ;
       }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
		 NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);      
   }
  
 long NFMadd_project_acl_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_project_acl_map" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1;  i = -1;

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
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMPROJECTACLMAP");
           sprintf (sql_str1, ") VALUES (");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list->columns * x;
              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1,  ", ");
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
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
               NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdrop_project_acl_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMdrop_project_acl_map" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, j, k, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     long   NFMconvert_project_owned_members ();
     long   NFMcheck_project_owned_members ();
     long   NFMupdate_project_state ();

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1; j = -1; k = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))     i = x;
        else if (! strcmp (data [count + a], "n_projectno"))  j = x;
        else if (! strcmp (data [count + a], "n_mapno"))      k = x;
      }

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
                  NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "DROP"))
         {
           status = _NFMcheck_acl_project_owned_members (user_id, 
                    atol (data1[count1 + j]), atol (data1[count1 + k])) ;

           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _NFMdebug ((fname, "Check item ownership to project failed : status = <0x%.8x>\n",
			status));
              return (status);
            }
           
           sprintf (sql_str,  "DELETE FROM %s", "NFMPROJECTACLMAP");
           sprintf (sql_str1, " WHERE ");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list->columns * x;
              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str1, " AND ");
                  }
                 comma = 1;

                 strcat (sql_str1, data [count + a]);
                 strcat (sql_str1, " = ");
  
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

           status = NFMupdate_project_state(user_id, atol (data1[count1 + j])); 
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Update Proj State: status = <0x%.8x>\n",
                        status));
              return (status);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMquery_project_sa_map (user_id, project_name,
                               attr_list, data_list, value_list)
   long      user_id;
   char      *project_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_project_sa_map" ;
     long     status;
     long     a, b, d, x, y, count, comma;
     long     proj_no ;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno, row_of_proj_no, row_of_map_no ;

     _NFMdebug ((fname, "Project Name = <%s>\n", project_name));

     status = NFMget_project_no (user_id, project_name, &proj_no) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Project No : status = <0x%.8x>\n",status));
        return (status);
      }

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMPROJECTSAMAP", attr_list, data_list, value_list);
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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1; column_of_valueno = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
        else if (! strcmp (column [y], "n_valueno")) column_of_valueno =y+1;
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",status));
        return (NFM_E_MEM);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMPROJECTSAMAP");
     comma = 0;
     row_of_proj_no = -1 ; row_of_map_no = -1 ;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_projectno"))
          {
	    row_of_proj_no = x + 1 ;
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
      
            sprintf (value, "%d", proj_no) ;

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
          }
         else if (! strcmp (data [count + a], "n_mapno"))
	   {
	     row_of_map_no = x + 1;
	   }

         if (comma) strcat (sql_str, ", ");
         comma = 1;

         strcat (sql_str, data [count + a]);
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     sql_str [0] =0;

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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
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
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);
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
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     sprintf (sql_str1, "select nfmcatalogsamap.n_mapno, nfmcatalogs.n_catalogname, nfmstoragearea.n_saname from nfmcatalogsamap,nfmcatalogs,nfmstoragearea \
where nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno \
and nfmstoragearea.n_sano = nfmcatalogsamap.n_sano \
order by nfmcatalogsamap.n_mapno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_map_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_projectno, n_projectname from nfmprojects \
where n_projectno = %d",
	      proj_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_proj_no, 
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

 long NFMupdate_project_sa_map (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "NFMupdate_project_sa_map" ;
     long    status;
     long    a, b, i, x, y, count;
     char    **column, **data, **data1;
     char    tab_no [50];
     long    NFMadd_project_sa_map ();
     long    NFMdrop_project_sa_map ();

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1;  i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_projectno"))  i = x;
      }

     sprintf (tab_no, "%d", WFinfo.proj_no);

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        status = MEMwrite_data (data_list, tab_no, x + 1, i + 1);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
		       status));
           return (NFM_E_MEM);      
         }
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMdrop_project_sa_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop Proj Sa Map : status = <0x%.8x>\n",
        status));
        return (status);      
      }

     status = NFMadd_project_sa_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Proj Sa Map : status = <0x%.8x>\n", 
        status));
        return (status);
      }
     status = _NFMcheck_project_state (WFinfo.proj_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "check project status failed : status = <0x%.8x>\n",
		     status)) ;
	 NFMrollback_transaction (0) ;
	 return (status) ;
       }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);      
   }
  
 long NFMadd_project_sa_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_project_sa_map" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
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
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMPROJECTSAMAP");
           sprintf (sql_str1, ") VALUES (");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list->columns * x;
              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1,  ", ");
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
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
		 NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdrop_project_sa_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMdrop_project_sa_map" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, j, k, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     long   NFMconvert_project_owned_members ();
     long   NFMcheck_project_owned_members ();
     long   NFMupdate_project_state ();

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1;  i = -1; j = -1; k = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))     i = x;
        else if (! strcmp (data [count + a], "n_projectno"))  j = x;
        else if (! strcmp (data [count + a], "n_mapno"))      k = x;
      }

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
                  NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
                  NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "DROP"))
         {
	   status = _NFMcheck_sa_project_owned_members (user_id,
		    atol (data1[count1 + j]), atol (data1[count1 + k])) ;

           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _NFMdebug ((fname, "Failure : owned : status = <0x%.8x>\n",
			status));
              return (status);
            }
           
           sprintf (sql_str,  "DELETE FROM %s", "NFMPROJECTSAMAP");
           sprintf (sql_str1, " WHERE ");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list->columns * x;
              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str1, " AND ");
                  }
                 comma = 1;

                 strcat (sql_str1, data [count + a]);
                 strcat (sql_str1, " = ");
  
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

           status = NFMupdate_project_state (user_id, atol(data1[count1 + j])); 
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Update Proj State: status = <0x%.8x>\n",
                        status));
              return (status);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }


long NFMconvert_project_owned_members (user_id, proj_no,
                                       map_no, table_name)
   long  user_id;
   long  proj_no;
   long  map_no;
   char  *table_name;
{
   static char *fname = "NFMconvert_project_owned_members" ;
   long status; 
   long catalog_no; 
   int a, b, i, j, k, l, x, y, count;
   char **column, **data, **data1;
   char tbl_name[80];
   char sql_str[1024];
   char sql_str1[512];
   MEMptr attr_list = NULL;
   MEMptr sql_buffer = NULL;

   _NFMdebug ((fname, "Project No.  = <%d> : Map No = <%d> : Table Name = <%s>\n", 
	       proj_no, map_no, table_name));

   /* Call NFMquery table definition to get the attributes from the 
      catalog map table in order to get the catalog_no associated
      with the project. map_no maps into the catalog map tables. */ 
   tbl_name[0] = 0;

   if (!strcmp (table_name, "NFMPROJECTACLMAP"))
    { 
      sprintf (tbl_name, "%s", "NFMCATALOGACLMAP");
    }
   else if (!strcmp (table_name, "NFMPROJECTSAMAP"))
    { 
      sprintf (tbl_name, "%s", "NFMCATALOGSAMAP");
    }
   else 
    { 
        ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL);
	_NFMdebug ((fname, "Invalid Table Name = < 0x%.8x >\n", 
                 NFM_E_BAD_TABLE));
	return (NFM_E_BAD_TABLE);
    }
   status = NFMquery_table_definition (user_id, "NFMSYSTEM", 
                                       tbl_name, &attr_list); 
   if (status != NFM_S_SUCCESS)
    {
       MEMclose (&attr_list);
       _NFMdebug ((fname, "Query Table Definition = < 0x%.8x >\n", status));
       return (status);
    } 

   status = MEMbuild_array (attr_list);
   if (status != MEM_S_SUCCESS)
    {
       MEMclose (&attr_list);
       _NFMdebug ((fname, "MEMbuild Array = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }

   data   = (char **) attr_list->data_ptr;
   column = (char **) attr_list->column_ptr;

   a = -1; b = -1;  i = -1; j = -1; 

   for (y = 0; y < attr_list -> columns; ++y)
    {
           if (! strcmp (column [y], "n_name"))     a = y;
      else if (! strcmp (column [y], "n_datatype")) b = y;
    }

   for (x = 0; x < attr_list -> rows; ++x)
    {
      count = attr_list -> columns * x;

           if (! strcmp (data [count + a], "n_mapno"))      i = x;
      else if (! strcmp (data [count + a], "n_catalogno"))  j = x;
    }

   if (!strncmp (data[attr_list->columns * i + b], "char", 4))
      sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%d'",
               data[attr_list->columns * j + a], tbl_name,
               data[attr_list->columns * i + a], map_no); 
   else
      sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
               data[attr_list->columns * j + a], tbl_name,
               data[attr_list->columns * i + a], map_no); 

   status = MEMclose (&attr_list);
   if (status != MEM_S_SUCCESS)
     {
       _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
     }
   attr_list = NULL;
   
   status = SQLquery (sql_str, &sql_buffer, 256);
   if (status != SQL_S_SUCCESS)
     {
       MEMclose (&sql_buffer);
       _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
       if (status == SQL_I_NO_ROWS_FOUND)
	 {
	   ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
	   _NFMdebug ((fname, "Failed: status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
	   return (NFM_E_CORRUPTED_BUFFERS);
	 }
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "status = <0x%.8x>\n", NFM_E_SQL_QUERY));
       return (NFM_E_SQL_QUERY);
     }
   
   status = MEMbuild_array (sql_buffer);
   if (status != MEM_S_SUCCESS)
     {
       MEMclose (&sql_buffer);
       _NFMdebug ((fname, "MEMbuild Array = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
     }
   
   if (sql_buffer->rows != 1)
    {
      MEMclose (&sql_buffer);
      ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
      _NFMdebug ((fname, "Invalid no rows returned: = < 0x%.8x >\n", NFM_E_CORRUPTED_SYSTEM));
      return (NFM_E_CORRUPTED_SYSTEM);
    }

   data = (char **) sql_buffer->data_ptr;
   catalog_no = atol(data[0]);

   status = MEMclose (&sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
       _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }
   sql_buffer = NULL;

   /* get the attributes for the NFMprojectcit table to be used to build 
      the update statement.                                              */

   status = NFMquery_table_definition (user_id, "NFMSYSTEM", 
                                       "NFMPROJECTCIT", &attr_list); 
   if (status != NFM_S_SUCCESS)
    {
       MEMclose (&attr_list);
       _NFMdebug ((fname, "Query Table Definition = < 0x%.8x >\n", status));
       return (status);
    } 
  
   status = MEMbuild_array (attr_list);
   if (status != MEM_S_SUCCESS)
    {
       MEMclose (&attr_list);
       _NFMdebug ((fname, "MEMbuild Array = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }

   data   = (char **) attr_list->data_ptr;
   column = (char **) attr_list->column_ptr;

   a = -1; b = -1; i = -1; j = -1; k = -1; l = -1; 

   for (y = 0; y < attr_list -> columns; ++y)
    {
           if (! strcmp (column [y], "n_name"))     a = y;
      else if (! strcmp (column [y], "n_datatype")) b = y;
    }

   for (x = 0; x < attr_list -> rows; ++x)
    {
      count = attr_list -> columns * x;

           if (! strcmp (data [count + a], "n_citno"))      i = x;
      else if (! strcmp (data [count + a], "n_projectno"))  j = x;
      else if (! strcmp (data [count + a], "n_catalogno"))  k = x;
      else if (! strcmp (data [count + a], "n_type"))       l = x;
    }

   if (!strncmp (data[attr_list->columns * j + b], "char", 4))
      sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%d' AND ",
               data[attr_list->columns * i + a], "NFMPROJECTCIT",
               data[attr_list->columns * j + a], proj_no); 
   else
      sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d AND ",
               data[attr_list->columns * i + a], "NFMPROJECTCIT",
               data[attr_list->columns * j + a], proj_no); 

   if (!strncmp (data[attr_list->columns * k + b], "char", 4))
      sprintf (sql_str1, "%s = '%d' AND %s = 'O'",
               data[attr_list->columns * k + a], catalog_no,
               data[attr_list->columns * l + a]); 
   else
      sprintf (sql_str1, "%s = %d AND %s = 'O'",
               data[attr_list->columns * k + a], catalog_no,
               data[attr_list->columns * l + a]); 

   strcat (sql_str, sql_str1); 

   status = SQLquery (sql_str, &sql_buffer, 1024);
   if (status != SQL_S_SUCCESS)
    {
       MEMclose (&sql_buffer);
       MEMclose (&attr_list);
       _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
       if ((status) == SQL_I_NO_ROWS_FOUND)
       {
         status = NFM_S_SUCCESS;
          _NFMdebug ((fname, "status = <0x%.8x>\n", status));
          return (status);
       }
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "status = <0x%.8x>\n",  NFM_E_SQL_QUERY));
       return ( NFM_E_SQL_QUERY);
    }

   status = MEMbuild_array (sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
       MEMclose (&sql_buffer);
       MEMclose (&attr_list);
       _NFMdebug ((fname, "MEMbuild Array = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }

   if (sql_buffer->rows < 1)
    {
      MEMclose (&sql_buffer);
      MEMclose (&attr_list);
      ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFMdebug ((fname, "Bad Buffer returned from query: = < 0x%.8x >\n",NFM_E_CORRUPTED_BUFFERS));
      return (NFM_E_CORRUPTED_BUFFERS);
    }

   data1 = (char **) sql_buffer->data_ptr;
   for (x = 0; x < sql_buffer->rows; ++x)
    {
       if (!strncmp (data[attr_list->columns * i + b], "char", 4))
          sprintf (sql_str, "UPDATE %s SET %s = 'R' WHERE %s = '%s'",
                   "NFMPROJECTCIT", data[attr_list->columns * l + a],
                   data[attr_list->columns * i + a], data1[x]); 
       else
          sprintf (sql_str, "UPDATE %s SET %s = 'R' WHERE %s = %s",
                   "NFMPROJECTCIT", data[attr_list->columns * l + a],
                   data[attr_list->columns * i + a], data1[x]); 

       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
        {
           MEMclose (&sql_buffer);
           MEMclose (&attr_list);
           _NFMdebug ((fname, "SQLstmt : status = <0x%.8x>\n", status));
	   ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "status = <0x%.8x>\n", status));
           return (NFM_E_SQL_STMT);
        }
    }

   status = MEMclose (&sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
       MEMclose (&attr_list);
       _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }
   sql_buffer = NULL;

   status = MEMclose (&attr_list);
   if (status != MEM_S_SUCCESS)
    {
       _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
       return (NFM_E_MEM);
    }
   attr_list = NULL;

    _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
 }

/* check if project (proj_no) has any items owned ("O") that
   follow the storagearea being unmapped (map_no) */
   
long NFMcheck_project_owned_members (user_id, proj_no,
				     map_no, table_name)
   long  user_id;
   long  proj_no;
   long  map_no;
   char  *table_name;
{
   static char *fname = "NFMcheck_project_owned_members";
   long status; 
   char tbl_name[80];
   char sql_str[1024];
   MEMptr sql_buffer = NULL;

   _NFMdebug ((fname, "Project No.  = <%d> : Map No = <%d> : Table Name = <%s>\n",
	       proj_no, map_no, table_name));
   user_id = user_id ;
   tbl_name[0] = 0;

   if (!strcmp (table_name, "NFMPROJECTACLMAP"))
    { 
      sprintf (tbl_name, "%s", "NFMCATALOGACLMAP");
    }
   else if (!strcmp (table_name, "NFMPROJECTSAMAP"))
    { 
      sprintf (tbl_name, "%s", "NFMCATALOGSAMAP");
    }
   else 
     { 
       ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL);
       _NFMdebug ((fname, "Invalid Table Name = < 0x%.8x >\n", 
		   NFM_E_BAD_TABLE));
       return (NFM_E_BAD_TABLE);
     }
   
   sprintf (sql_str, "SELECT NFMPROJECTCIT.n_itemno \
FROM NFMPROJECTCIT, %s \
WHERE %s.n_mapno = %d \
AND   %s.n_catalogno = NFMPROJECTCIT.n_catalogno \
AND   NFMPROJECTCIT.n_type = 'O' \
AND   NFMPROJECTCIT.n_projectno = %d",
	    tbl_name, tbl_name, map_no, tbl_name, proj_no) ;

   status = SQLquery (sql_str, &sql_buffer, 2*MEM_SIZE);
   if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       MEMclose (&sql_buffer);
       _NFMdebug ((fname,"SQLquery : status = <0x%.8x>\n", status));
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);
     }
   
   if (status != SQL_I_NO_ROWS_FOUND)
     {
       MEMclose (&sql_buffer) ;
       _NFMdebug ((fname, "Item is owned by this project that follows the mapping being deleted : status = <0x%.8x>\n", NFM_E_PROJECT_MEM_OWNED));
       ERRload_struct (NFM, NFM_E_DEL_MAP_OWNED_ITEM, NULL, NULL) ;
       return (NFM_E_DEL_MAP_OWNED_ITEM) ;
     }

   status = MEMclose (&sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
      _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
      return (NFM_E_MEM);
    }

    _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
 }

/* check if project (proj_no) has any items owned ("O") that
   follow the storagearea being unmapped (map_no) */
   
long _NFMcheck_acl_project_owned_members (user_id, proj_no, map_no)
   long  user_id;
   long  proj_no;
   long  map_no;
{
   static char *fname = "_NFMcheck_acl_project_owned_members";
   long status; 
   char sql_str[1024];
   char catalog_name [NFM_CATALOGNAME +1] ;
   char **data ;
   MEMptr sql_buffer = NULL;

   _NFMdebug ((fname, "Project No.  = <%d> : Map No = <%d>\n",
	       proj_no, map_no)) ;
   user_id = user_id ;
   sprintf (sql_str, "select a.n_catalogname \
from nfmcatalogs a, nfmcatalogaclmap b \
where a.n_catalogno = b.n_catalogno \
and b.n_mapno = %d",
	    map_no) ;

   status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
   if (status != SQL_S_SUCCESS) 
     {
       _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		   status)) ;
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
   strcpy (catalog_name, data [0]) ;

   MEMclose (&sql_buffer) ;
  /* PS - This query always results some rows when there are entries for
          the project in nfmprojectcit table for the project, though the
          item do not belong to the acl_map specified. This query is
          replaced with the new one coded below.  20th Oct, 95
 
   sprintf (sql_str, "select a.n_itemno \
from %s a, NFMPROJECTCIT b, NFMCATALOGACLMAP c \
where b.n_projectno = %d and b.n_type = 'O' \
and c.n_mapno = %d \
and c.n_catalogno = b.n_catalogno \
and a.n_aclno = c.n_aclno",
	    catalog_name, proj_no, map_no) ;
*/
   sprintf (sql_str, "select a.n_itemno \
from %s a, NFMPROJECTCIT b, NFMCATALOGACLMAP c \
where b.n_projectno = %d and b.n_type = 'O' \
and c.n_mapno = %d \
and a.n_itemno = b.n_itemno \
and c.n_catalogno = b.n_catalogno \
and a.n_aclno = c.n_aclno",
            catalog_name, proj_no, map_no) ;
 

   status = SQLquery (sql_str, &sql_buffer, 2*MEM_SIZE);
   if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       MEMclose (&sql_buffer);
       _NFMdebug ((fname,"SQLquery : status = <0x%.8x>\n", status));
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);
     }
   
   if (status != SQL_I_NO_ROWS_FOUND)
     {
       MEMclose (&sql_buffer) ;
       _NFMdebug ((fname, "Item is owned by this project that follows the mapping being deleted : status = <0x%.8x>\n", NFM_E_PROJECT_MEM_OWNED));
       ERRload_struct (NFM, NFM_E_DEL_MAP_OWNED_ITEM, NULL, NULL) ;
       return (NFM_E_DEL_MAP_OWNED_ITEM) ;
     }

   status = MEMclose (&sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
      _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
      return (NFM_E_MEM);
    }

    _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
 }

/* check if project (proj_no) has any items owned ("O") that
   follow the storagearea being unmapped (map_no) */
   
long _NFMcheck_sa_project_owned_members (user_id, proj_no, map_no)
   long  user_id;
   long  proj_no;
   long  map_no;
{
   static char *fname = "_NFMcheck_sa_project_owned_members";
   long status; 
   char sql_str[1024];
   char catalog_name [NFM_CATALOGNAME +1] ;
   char **data ;
   MEMptr sql_buffer = NULL;

   _NFMdebug ((fname, "Project No.  = <%d> : Map No = <%d>\n",
	       proj_no, map_no)) ;
   user_id = user_id ;
   sprintf (sql_str, "select a.n_catalogname \
from nfmcatalogs a, nfmcatalogsamap b \
where a.n_catalogno = b.n_catalogno \
and b.n_mapno = %d",
	    map_no) ;

   status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
   if (status != SQL_S_SUCCESS) 
     {
       _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		   status)) ;
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
   strcpy (catalog_name, data [0]) ;

   MEMclose (&sql_buffer) ;
   
   sprintf (sql_str, "select a.n_itemnum \
from f_%s a, NFMPROJECTCIT b, NFMCATALOGSAMAP c \
where b.n_projectno = %d and b.n_type = 'O' \
and c.n_mapno = %d \
and c.n_catalogno = b.n_catalogno \
and a.n_cisano = c.n_sano",
	    catalog_name, proj_no, map_no) ;

   status = SQLquery (sql_str, &sql_buffer, 2*MEM_SIZE);
   if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       MEMclose (&sql_buffer);
       _NFMdebug ((fname,"SQLquery : status = <0x%.8x>\n", status));
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);
     }
   
   if (status != SQL_I_NO_ROWS_FOUND)
     {
       MEMclose (&sql_buffer) ;
       _NFMdebug ((fname, "Item is owned by this project that follows the mapping being deleted : status = <0x%.8x>\n", NFM_E_PROJECT_MEM_OWNED));
       ERRload_struct (NFM, NFM_E_DEL_MAP_OWNED_ITEM, NULL, NULL) ;
       return (NFM_E_DEL_MAP_OWNED_ITEM) ;
     }

   status = MEMclose (&sql_buffer);
   if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
      _NFMdebug ((fname, "MEMclose = < 0x%.8x >\n", status));
      return (NFM_E_MEM);
    }

    _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
 }


  /**********************************************************************
   *   This function will check to see if all the mapping (acl & sa)    *
   *   for a project has been done.  If so it will reset the project    *
   *   state in NFMprojectss to the "PROJECT CREATED" state.            *
   *   This function uses the hard coded state "PROJECT CREATED" and    *
   *   therefore if the statename changes the hardcoded name must be    *
   *   changed here also.  This should be considered a temporary fix    *
   **********************************************************************/

  long NFMupdate_project_state (user_id, proj_num)
    long   user_id; 
    long  proj_num;
  {
    static char *fname = "NFMupdate_project_state";
    long   status;
    long   workflowno, stateno;
    long   NFMget_workflow_no(), NFMget_state_no();
    char   sql_str[256]; 
    MEMptr sql_buffer = NULL; 

     _NFMdebug ((fname, "project_number = <%d>\n", proj_num));

     workflowno = 0;  stateno = 0;
     sprintf (sql_str, "SELECT %s FROM NFMPROJECTACLMAP WHERE %s = %d",
              "n_mapno", "n_projectno", proj_num);
     status = SQLquery (sql_str, &sql_buffer, 256);

     if ((status) != SQL_I_NO_ROWS_FOUND)
     {
        MEMclose (&sql_buffer);
        if (status != SQL_S_SUCCESS)
        {
	  ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	  _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",  NFM_E_SQL_QUERY));
	  status = NFM_E_SQL_QUERY;
        }
        else
	  {
           status = NFM_S_SUCCESS;
           _NFMdebug ((fname, "Proj ACL Map Exist : status = <0x%.8x>\n",
                     status));
        }
        return (status);
     } 

     status = MEMclose (&sql_buffer);
     if (status != MEM_S_SUCCESS)
     {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
        return (status);
     }
     sql_buffer = NULL; 
 
     sprintf (sql_str, "SELECT %s FROM NFMPROJECTSAMAP WHERE %s = %d",
              "n_mapno", "n_projectno", proj_num);
     status = SQLquery (sql_str, &sql_buffer, 256);

     if ((status) != SQL_I_NO_ROWS_FOUND)
     {
        MEMclose (&sql_buffer);
        if (status != SQL_S_SUCCESS)
        {
	  ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	  _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
	  status = NFM_E_SQL_QUERY;
        }
        else
        {
           status = NFM_S_SUCCESS;
           _NFMdebug ((fname, "Proj SA Map Exist : status = <0x%.8x>\n",
                     status));
        }
        return (status);
     } 

     /* there is no project mapping, set the state back to PROJECT CREATED */

     status = NFMget_workflow_no (user_id, "NFM_PROJECT_WORKFLOW",
                                  &workflowno);
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Get WF No : status = <0x%.8x>\n", status));
        return (status);
     }

     status = NFMget_state_no (user_id, workflowno, "PROJECT CREATED",
                               &stateno);
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Get State No : status = <0x%.8x>\n", status));
        return (status);
     }

     sprintf (sql_str, "UPDATE %s SET %s = %d WHERE %s = %d",
              "NFMPROJECTS", "n_stateno", stateno, "n_projectno", proj_num); 
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n", status));
        return (status);
     } 

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
  }

