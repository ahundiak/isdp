#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long NFMquery_loc_definition (user_id, loc_name, attr_list)
   long     user_id;
   char     *loc_name;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_loc_definition" ;
     long     status;

     user_id = user_id ;
     sprintf (loc_name, "%s", "NFMCATALOGS");

     _NFMdebug ((fname, "LOC  Name  = <%s>\n", loc_name));

     status = NFMquery_table_definition (NFMglobal.NFMuserid, "NFMSYSTEM",
              loc_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        _NFMdebug ((fname, "Tab Definition : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long NFMquery_changeto_loc_attributes (user_id, loc_name, cat_name, 
                                  attr_list, data_list, value_list)
   long     user_id;
   char     *loc_name, *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_change_loc_attributes" ;
     long     status;
     char     *sql_str, sql_str1 [1024];
     char     **column, **data;
     char     user_name [50];
     char     date [50], time [50];
     long     x, y, count, a, b ;

     sprintf (loc_name, "%s", "NFMCATALOGS");
     user_id = user_id ;
     _NFMdebug ((fname, "LOC  Name  = <%s> : Cat Name = <%s>\n", 
		 loc_name, cat_name));

     status = _NFMquery_systable_attributes ("nfmcatalogs",
					     attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
        return (status);          
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

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);                     
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1;
     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + (*attr_list) -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", loc_name);

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        if (x) strcat (sql_str, ", ");

        strcat (sql_str, data [count + a]);

        if (! strcmp (data [count + a], "n_catalogname"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if ((! strncmp (data [count + b], "char", 4)) ||
               (! strncmp (data [count + b], "date", 4)))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, cat_name);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, cat_name);            
         }
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, data_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_CAT_NOT_IN_LOC, "", NULL);
           _NFMdebug ((fname, "No Such Loc Entry : status = <0x%.8x>\n",
           NFM_E_CAT_NOT_IN_LOC));
           return (NFM_E_CAT_NOT_IN_LOC);           
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);           
      }

     free (sql_str);

     strcpy (user_name, NFMglobal.NFMusername) ;

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Date Time : status = <0x%.8x>\n",
        status));
        return (status);           
     }

     status = MEMbuild_array (*data_list);
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

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        if (! strcmp (data [count + a], "n_updater"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + a], "n_updatedate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + a], "n_updatetime"))
         {
           status = MEMwrite_data (*data_list, time, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);           
            }
         }
      }

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }

     sql_str [0] = 0;

     data = (char **) (*data_list) -> data_ptr;

     for (y = 0; y < (*data_list) -> columns; ++y)
      {
        strcat (sql_str, data [y]);
        strcat (sql_str, "\1");
      }

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);           
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long NFMquery_addto_loc_attributes (user_id, loc_name,
				    attr_list, data_list, value_list)
     long     user_id ;
     char     *loc_name ;
     MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_addto_loc_attributes" ;
     long     status;
     long     t_basic_row = -1, t_appl_row = -1, i, column_of_valueno, x, c ;
     char     **data, **column, user_name [50] ;
     char     str [1024], seq [5], date [50], tmp_str [512] ;
     long     next_seq_no = -1, count, no_buffers ;
     char     acl_no [20] ;
     MEMptr   list = NULL ;
     long     _NFMget_table_sysattr ();
     long     _NFMget_data_info ();
     long     _NFMadd_to_value_list () ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
/* loc_name is set because it is in api but its not used by the NFM interface*/
     strcpy (loc_name, "nfmcatalogs") ;
     
     status = _NFMget_systable_attr ("nfmcatalogs", attr_list, &next_seq_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get Tables Sysattributes failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = MEMbuild_array (*attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 _NFMdebug ((fname, "MEMbuild_array : *attr_list : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     column = (char **) (*attr_list) -> column_ptr ;
     data = (char **) (*attr_list) -> data_ptr ;

     t_basic_row = (*attr_list)->rows + 1 ;
     t_appl_row = (*attr_list)->rows + 2 ;

     _NFMdebug ((fname, "next_seq_no %d, t_basic_rows is %d : t_appl_row is %d\n",
		 next_seq_no, t_basic_row, t_appl_row)) ;

     /* add an extra row for t_basic */
     str [0] = 0 ;
     c = -1 ; column_of_valueno = -1;
     for (i=0; i<(*attr_list)->columns; i++)
       {
	 if (strcmp (column [i], "n_name") == 0)
	   {
	     c = i ;
	     strcat (str, "t_basic\1") ;
	   }
	 else if (strcmp (column [i], "n_datatype") == 0)
	   strcat (str, "char(20)\1") ;
	 else if (strcmp (column [i], "n_synonym") == 0)
	   strcat (str, "Basic Application\1") ;
	 else if (strcmp (column [i], "n_application") == 0)
	   strcat (str, "NFM\1") ;
	 else if (strcmp (column [i], "n_read") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_write") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_update") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_delete") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_null") == 0)
	   strcat (str, "N\1") ;
	 else if (strcmp (column [i], "n_checkin") == 0)
	   strcat (str, "N\1") ;
	 else if (strcmp (column [i], "n_checkout") == 0)
	   strcat (str, "N\1") ;
	 else if (strcmp (column [i], "n_attrno") == 0)
	   strcat (str, "-1\1") ;
	 else if (strcmp (column [i], "n_seqno") == 0)
	   {
	     sprintf (seq, "%d\1", next_seq_no++) ;
	     strcat (str, seq) ;
	   }
	 else if (strcmp (column [i], "n_valueno") == 0)
	   {
	     strcat (str, "0\1") ;
	   }
/*
	 else if (strcmp (column [i], "n_adviceno") == 0)
	   {
	     strcat (str, "0\1") ;
	   }
*/
	 else
	   strcat (str, "\1") ;
       }

     /* add row to the buffer for t_basic */
     status = MEMwrite (*attr_list, str) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     status = MEMbuild_array (*attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 _NFMdebug ((fname, "MEMbuild_array : *attr_list : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     column = (char **) (*attr_list)->column_ptr ;

     /* add an extra row for t_appl */
     str [0] = 0 ;
     for (i=0; i<(*attr_list)->columns; i++)
       {
	 if (strcmp (column [i], "n_name") == 0)
	   strcat (str, "t_appl\1") ;
	 else if (strcmp (column [i], "n_datatype") == 0)
	   strcat (str, "char(20)\1") ;
	 else if (strcmp (column [i], "n_synonym") == 0)
	   strcat (str, "Secondary Application\1") ;
	 else if (strcmp (column [i], "n_application") == 0)
	   strcat (str, "NFM\1") ;
	 else if (strcmp (column [i], "n_read") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_write") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_update") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_delete") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_null") == 0)
	   strcat (str, "Y\1") ;
	 else if (strcmp (column [i], "n_checkin") == 0)
	   strcat (str, "N\1") ;
	 else if (strcmp (column [i], "n_checkout") == 0)
	   strcat (str, "N\1") ;
	 else if (strcmp (column [i], "n_attrno") == 0)
	   strcat (str, "-1\1") ;
	 else if (strcmp (column [i], "n_seqno") == 0)
	   {
	     sprintf (seq, "%d\1", next_seq_no) ;
	     strcat (str, seq) ;
	   }
	 else if (strcmp (column [i], "n_valueno") == 0)
	   {
	     column_of_valueno = i +1;
	     strcat (str, "0\1") ;
	   }
/*
	 else if (strcmp (column [i], "n_adviceno") == 0)
	   {
	     strcat (str, "0\1") ;
	   }
*/
	 else
	   strcat (str, "\1") ;
       }

     /* add row to the buffer for t_appl */
     status = MEMwrite (*attr_list, str) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     status = _NFMget_data_info (*attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }


     /* default of t_basic and t_appl to NFM */
     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS)
     {
       ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       _NFMdebug ((fname, "MEMbuild_array : *data_list : status = <0x%x.8>\n",
		   status)) ;
       return (NFM_E_MEM) ;
     }

     column = (char **) (*data_list)->column_ptr ;

     for (i=0; i<(*data_list)->columns; i++)
       {
	 if (strcmp (column [i], "t_basic") == 0)
	   {
	     status = MEMwrite_data (*data_list, "NFM", 1, i+1) ;
	     if (status != MEM_S_SUCCESS)
	       {
		 _NFMdebug ((fname, "MEMwrite_data (*data_list) : status = <0x%x.8>\n",
			     status)) ;
		 return (NFM_E_MEM) ;
	       }
	   }
/***********************************
	 else if (strcmp (column [i], "t_appl") == 0)
	   {
	     status = MEMwrite_data (*data_list, "NFM", 1, i+1) ;
	     if (status != MEM_S_SUCCESS)
	       {
		 _NFMdebug ((fname, "MEMwrite_data (*data_list) : status = <0x%x.8>\n",
			     status)) ;
		 return (NFM_E_MEM) ;
	       }
	   }
*****************************************/
       }


     strcpy (user_name, NFMglobal.NFMusername) ;

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get Ris date : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

/********
     status = NFMget_transition_acl_list (NFMglobal.NFMuserid, &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get ACL list : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
***************/
     status = _NFMget_catalog_acl_list (&list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get ACL list : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     if (*value_list)
       {
         status = MEMappend (list, *value_list);
         if (status != MEM_S_SUCCESS)
	   {
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     _NFMdebug ((fname, "MEMappend : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_MEM) ;
	   }
       }
     else
       {
         status = MEMsplit_copy_buffer (list, value_list, 0);
	 if (status != MEM_S_SUCCESS)
	   {
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     _NFMdebug ((fname, "MEMsplit_copy_buffer : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_MEM) ;
	   }
       }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
	 return (NFM_E_MEM) ;
       }
 
     MEMno_buffers (*value_list, &no_buffers );
     sprintf (acl_no, "%d", no_buffers );

     _NFMdebug ((fname, "acl_no is %d\n", acl_no)) ;


     status = MEMbuild_array (*attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
       ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       _NFMdebug ((fname, "MEMbuild_array : *data_list : status = <0x%x.8>\n",
		   status)) ;
       return (NFM_E_MEM) ;
       }

     data = (char **) (*attr_list) -> data_ptr ;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;
	_NFMdebug ((fname, "columns is %s\n", data [count+c])) ;
        if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + c], "n_aclno"))
         {
	   sprintf (tmp_str, "%d", WFinfo.acl) ;
           status = MEMwrite_data (*data_list, tmp_str, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_MEM);           
            }

           status = MEMwrite_data (*attr_list, acl_no, x + 1,
				   column_of_valueno);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_MEM);           
            }

         }
      }

     /* Add to value list :
	value list for t_basic and t_appl */
     status = _NFMadd_to_value_list (attr_list, value_list, "t_basic",
				     t_basic_row, column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "NFMadd_to_value_list : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     
     status = _NFMadd_to_value_list (attr_list, value_list, "t_appl", 
				     t_appl_row, column_of_valueno) ;
     if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND)) 
       {
	 _NFMdebug ((fname, "NFMadd_to_value_list : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
