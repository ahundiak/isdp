#include "machine.h"
#include "NFMU.h"
#include "WFstruct.h"

 extern struct NFMglobal_st NFMglobal ;
 extern struct WFstruct WFinfo ;

long NFMget_item_attr_for_copy (cat_name,itemname, itemrev,
				attr_cat, data_cat, value_cat,
				attr_f_cat, data_f_cat, value_f_cat)
   char     *cat_name, *itemname, *itemrev ;
   MEMptr   *attr_cat, *data_cat, *value_cat;
   MEMptr   *attr_f_cat, *data_f_cat, *value_f_cat ;
   {
     static char *fname = "NFMget_item_attr_for_copy" ;
     long     status, cisano_pos, ret_status = NFM_S_SUCCESS ;
     char     acl_no [50], sa_no [50];
     char     date [50] ;
     char     **data, **column, **data1, **column1 ;
     char     *sql_str, *sql_str1, *empty_str ;
     int      x,y,c,d,count, z, offset ;
     long     _NFMget_cat_acl_list ();
     long     _NFMget_cat_internal_sa_list ();
     long     _NFMget_proj_acl_list ();
     long     _NFMget_proj_sa_list ();
     long     _NFMget_catalog_info () ;
     long     cat_no, no_buffers, move_files ;
     MEMptr   list = NULL, buffer = NULL ;
     long     _NFMquery_template_attributes ();
     long _NFMquery_catalog_attributes_for_copy ();

     _NFMdebug ((fname, "ENTER : Cat  Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n", 
		 cat_name, itemname, itemrev )) ;

     ret_status = NFM_S_SUCCESS ;
     if (WFinfo.catalog_no > 0)
       {
	 cat_no = WFinfo.catalog_no ;
       }
     else
       {
	 status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     ERRload_struct (NFM, NFM_E_BAD_CATALOG, "%s", cat_name) ;
	     _NFMdebug ((fname, "Bad Catalog %s\n", cat_name)) ;
	     return (status) ;
	   }
       }

     /* Get all attributes */
     status = _NFMquery_catalog_attributes_for_copy (cat_name,
					    attr_cat, data_cat, value_cat,
					    attr_f_cat,data_f_cat,value_f_cat);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_cat);
	 MEMclose (data_cat);
	 MEMclose (value_cat);
	 MEMclose (attr_f_cat);
	 MEMclose (data_f_cat);
	 MEMclose (value_f_cat);
	 _NFMdebug ((fname, "Query Cat Attr : status = <0x%.8x>\n",
		     status));
	 return (status);          
       }

     /* get validation list for n_cisano and n_aclno */

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_cat);
        MEMclose (data_cat);
        MEMclose (value_cat);
        MEMclose (attr_f_cat);
        MEMclose (data_f_cat);
        MEMclose (value_f_cat);
        _NFMdebug ((fname, "Get Date Time : status = <0x%.8x>\n",
        status));
        return (status);          
      }
     
     status = _NFMget_acl_for_item (cat_name, itemname, itemrev,&list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		     status)) ;
	 return (status);
       }
     
     if (list -> rows < 1)
       {
	 MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
	 _NFMdebug ((fname, "Bad User Add Item In Cat : status = <0x%.8x>\n",
		     NFM_E_CATALOG_ACCESS));
	 return (NFM_E_CATALOG_ACCESS);          
       }
     
     if (*value_cat)
       {
	 status = MEMappend (list, *value_cat);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
       }
     else
       {
	 status = MEMsplit_copy_buffer (list, value_cat, 0);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
       }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	 return (NFM_E_MEM);          
       }
     
     MEMno_buffers (*value_cat, &no_buffers );
     sprintf (acl_no, "%d", no_buffers );
     
     status = _NFMget_internal_sa_list_for_item (cat_name, itemname, itemrev,
						 &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
     
     if (list -> rows < 1)
       {
	 MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
	 _NFMdebug ((fname, "User Can't Add Item In Cat : status = <0x%.8x>\n",
		     NFM_E_CATALOG_ACCESS));
	 return (NFM_E_CATALOG_ACCESS);          
       }
     
     if (*value_f_cat)
       {
	 status = MEMappend (list, *value_f_cat);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
       }
     else
       {
	 status = MEMsplit_copy_buffer (list, value_f_cat, 0);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
       }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	 return (NFM_E_MEM);          
       }
     MEMno_buffers (*value_f_cat, &no_buffers );
     sprintf (sa_no, "%d", no_buffers );

     /* Load catalog data list with information of original item */

     _NFMdebug ((fname, "loading cat information from original item\n")) ;

     status = MEMbuild_array (*attr_cat);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_f_cat);
        MEMclose (data_f_cat);
        MEMclose (value_f_cat);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMbuild_array (*data_cat);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_f_cat);
        MEMclose (data_f_cat);
        MEMclose (value_f_cat);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) (*attr_cat) -> column_ptr;
     data   = (char **) (*attr_cat) -> data_ptr;
     
     c = -1; d = -1;
     
     for (y = 0; y < (*attr_cat) -> columns; ++y)
       {
	 if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))       d = y;
       }
     
     
     sql_str = (char *) malloc ((*attr_cat)->rows * 30) ;
     if (sql_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }
     
     sql_str [0] = 0 ;
     for (x = 0; x < (*attr_cat) -> rows; ++x)
       {
	 count = (*attr_cat) -> columns * x;
	 
	 if (! strcmp (data [count + c], "n_aclno"))
	   {
	     status = MEMwrite_data (*attr_cat, acl_no, x + 1, d + 1);
	     if (status != MEM_S_SUCCESS)
	       {
		 free (sql_str) ;
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_MEM);          
	       }
	   }

	 if ((! strcmp (data [count + c], "original_itemno")) ||
	     (! strcmp (data [count + c], "original_status")) ||
	     (! strcmp (data [count + c], "original_aclno")))
	   {
	     /* skip */
	   }
	else 
	  {
	    if (strlen (sql_str))
	      {
		strcat (sql_str, ",") ;
	      }
	    strcat (sql_str, data [count+c]) ;
	  }
      }

     sql_str1 = (char *) malloc (strlen (sql_str) + 500) ;
     if (sql_str1 == NULL)
       {
	 free (sql_str) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     if (strlen (sql_str))
       {
	 sprintf (sql_str1, "Select %s from %s where n_itemno  = %d",
		  sql_str, cat_name, WFinfo.item_no) ;
	 
	 status = SQLquery (sql_str1, &buffer, MEM_SIZE) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     MEMclose (&buffer) ;
	     free (sql_str) ;
	     free (sql_str1) ;
	     if (status == SQL_I_NO_ROWS_FOUND)
	       {
		 ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
		 return (NFM_E_BAD_ITEM) ;
	       }
	     _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	     return (NFM_E_SQL_QUERY) ;
	   }
       }
     else
       {
	 MEMclose (&buffer) ;
	 free (sql_str) ;
	 free (sql_str1) ;
	 _NFMdebug ((fname, "Failure : No writable attributes available\n"));
	 ERRload_struct (NFM, NFM_E_BAD_ATTRIBUTE, "", "") ;
	 return (NFM_E_BAD_ATTRIBUTE) ;
       }

     free (sql_str) ;
     free (sql_str1) ;

/******* mms - Do not need to build again *******
     status = MEMbuild_array (*data_cat) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }
***********************************************/
     /* Put original item information */

     status = MEMbuild_array (buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&buffer) ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }
     
     data1 = (char **) buffer -> data_ptr ;
     column1 = (char **) buffer->column_ptr ;
     
     column = (char **) (*data_cat)->column_ptr ;
     _NFMdebug ((fname, "cat columns %d : buffer columns %d\n",
		 (*data_cat)->columns, buffer->columns)) ;
     
     move_files = 1 ;
     for (x = 0; x < (*data_cat) -> columns; ++x)
       {
	 for (y=0 ; y<buffer->columns; ++y)
	   {
	     if (! strcmp (column [x], column1 [y]))
	       {
		 if (! strcmp (column1 [y], "n_itemlock"))
		   {
		     status = MEMwrite_data (*data_cat, "N", 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 else if (! strcmp (column1 [y], "n_creator"))
		   {
		     status = MEMwrite_data (*data_cat, NFMglobal.NFMusername,
					     1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 else if (! strcmp (column1 [y], "n_creationdate"))
		   {
		     status = MEMwrite_data (*data_cat, date, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (status);          
		       }
		   }
		 else if (! strcmp (column1 [y], "n_itemrev"))
		   {
		     status = MEMwrite_data (*data_cat, "", 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (status);          
		       }
		   }
		 else if (! strcmp (column1 [y], "n_setindicator"))
		   {
/* mms - 09/13/92 in copy_set this value should be filled with "Y" */
		     status = MEMwrite_data (*data_cat, "", 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (status);          
		       }
		   }
		 else if (! strcmp (column1 [y], "n_archivestate"))
		   {
		     if (strcmp (data1 [y], "A") == 0) 
		       {
			 ERRload_struct (NFM, NFM_I_ARCHIVED_NO_FILE_INFO, "","");
			 ret_status = NFM_I_ARCHIVED_NO_FILE_INFO ;
			 move_files = 0 ;
		       }
		   }
		 
		 else if (! strcmp (column1 [y], "n_itemlock"))
		   {
		     if ((strcmp (data1 [y], "N")) && (strcmp (data1 [y], "")))
		       {
			 /*		    move_files = 0 ; */
			 _NFMdebug ((fname, "Item is locked\n")) ;
			 MEMclose (&buffer) ;
			 ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", "") ;
			 return (NFM_E_ITEM_LOCKED) ;
		       }
		   }
		 else if (! strcmp (column1 [y], "n_pendingflag"))
		   {
		     if  (  strcmp (data1 [y], ""))  
		       {
			 ERRload_struct (NFM, NFM_I_FLAGGED_NO_FILE_INFO, "","");
			 ret_status = NFM_I_FLAGGED_NO_FILE_INFO ;
			 move_files = 0 ;
		       }
		   }
		 else
		   {
		     status = MEMwrite_data (*data_cat, data1[y], 1, x + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&buffer) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
	       }
	     
	     /* if data buffer column = original_itemno 
		and original item info buffer = n_itemno */
	     
	     else if ((! strcmp (column [x], "original_itemno")) &&
		      (! strcmp (column1 [y], "n_itemno")))
	       {
		 status = MEMwrite_data (*data_cat, data1[y], 1, x + 1);
		 if (status != MEM_S_SUCCESS)
		   {
		     MEMclose (&buffer) ;
		     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				 status));
		     return (NFM_E_MEM);          
		   }
	       }
	     /* if data buffer column = original_status and original item info buffer = n_status */
	     else if ((! strcmp (column [x], "original_status")) &&
		      (! strcmp (column1 [y], "n_status")))
	       {
		 status = MEMwrite_data (*data_cat, data1[y], 1, x + 1) ;
		 if (status != MEM_S_SUCCESS)
		   {
		     MEMclose (&buffer) ;
		     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				 status));
		     return (NFM_E_MEM);          
		   }
	       }
	     
	     /* if data buffer column = original_aclno and original item info buffer = n_aclno */
	     else if ((! strcmp (column [x], "original_aclno")) &&
		      (! strcmp (column1 [y], "n_aclno")))
	       {
		 status = MEMwrite_data (*data_cat, data1[y], 1, x + 1) ;
		 if (status != MEM_S_SUCCESS)
		   {
		     MEMclose (&buffer) ;
		     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				 status));
		     return (NFM_E_MEM);          
		   }
	       }
	   }
       }
     
     MEMclose (&buffer) ;

     if (!move_files)
       {
	 _NFMdebug ((fname, "No file catalog information will be copied : ret status <0x%.8x>\n", ret_status)) ;
	 return (ret_status) ;
       }

/******** f_cat ***************/
     _NFMdebug ((fname, "file catalog data buffer\n")) ;

     status = MEMbuild_array (*attr_f_cat);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_f_cat);
        MEMclose (data_f_cat);
        MEMclose (value_f_cat);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMbuild_array (*data_f_cat);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) (*attr_f_cat) -> column_ptr;
     data   = (char **) (*attr_f_cat) -> data_ptr;

     c = -1; d = -1;

     for (y = 0; y < (*attr_f_cat) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))   d = y;
      }

     sql_str = (char *) malloc ((*attr_f_cat)->rows * 30) ;
     if (sql_str == NULL)
       {
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 return (NFM_E_MALLOC) ;
       }
     
     empty_str = (char *) malloc ((*attr_f_cat)->rows*5) ;
     if (empty_str == NULL) 
       {
	 _NFMdebug ((fname, "Malloc empty_str failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }
     
     sql_str [0] = 0 ;
     empty_str [0] = 0 ;
     cisano_pos = -1 ;
     for (x = 0; x < (*attr_f_cat) -> rows; ++x)
       {
	 count = x * (*attr_f_cat) -> columns ;
	 strcat (empty_str, "\001") ;
	 /*	_NFMdebug ((fname, "comparing %s\n", data [count+c])) ; */
	 
	 if (! strcmp (data [count + c], "n_action"))
	   {
	     /* skip */
	   }
	 else if (! strcmp (data [count + c], "original_cisano"))
	   {
	     /* skip */
	   }
	 else if (! strcmp (data [count + c], "original_cifilename")) 
	   {
	     /* skip */
	   }
	 else if (! strcmp (data [count + c], "original_fileno")) 
	   {
	     /* skip */
	   }
	 else 
	   {
	     if (! strcmp (data [count + c], "n_cisano"))
	       {
		 cisano_pos = c ;
		 status = MEMwrite_data (*attr_f_cat, sa_no, x + 1, d + 1);
		 if (status != MEM_S_SUCCESS)
		   {
		     free (sql_str) ;
		     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				 status));
		     return (NFM_E_MEM);          
		   }
	       }
	     if (strlen (sql_str))
	       {
		 strcat (sql_str, ",") ;
	       }
	     strcat (sql_str, data [count+c]) ;
	   }
       }
     
     if (cisano_pos == -1)
       {
	 strcat (sql_str, ", n_cisano") ;
       }
     
     sql_str1 = (char *) malloc (strlen (sql_str) + 1000) ;
     if (sql_str1 == NULL)
       {
	 free (sql_str) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     sprintf (sql_str1, 
"Select %s  from f_%s where n_itemnum = %d and n_filenum != 0 and n_fileversion = (select max(n_fileversion) from f_%s where n_itemnum = %d)",
	      sql_str, cat_name, WFinfo.item_no,
	      cat_name, WFinfo.item_no) ;

     status = SQLquery (sql_str1, &buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&buffer) ;
	 free (sql_str) ;
	 free (sql_str1) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     _NFMdebug ((fname, "No files associated with this item\n")) ;
	     return (ret_status) ;
	   }
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_SQL_QUERY) ;
       }
     free (sql_str) ;
     free (sql_str1) ;

     status = MEMbuild_array (buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&buffer) ;
	 free (empty_str) ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     data1 = (char **) buffer -> data_ptr ;
     column1 = (char **) buffer->column_ptr ;
     for (z=0; z < buffer->rows; ++z)
       {
	 offset = z * buffer->columns ;
	 status = MEMwrite (*data_f_cat, empty_str) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&buffer) ;
	     free (empty_str) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
	     return (NFM_E_MEM) ;
	   }
	 status = MEMbuild_array (*data_f_cat) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&buffer) ;
	     _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }

	 for (x = 0; x < (*attr_f_cat) -> rows; ++x)
	   {
	     count = (*attr_f_cat) ->columns * x;
	     for (y=0 ; y<buffer->columns; ++y)
	       { 
		 if (! strcmp (data [count+c], column1 [y])) 
		   {
		     _NFMdebug ((fname, "writing %s into %d %d\n",
				 data1[offset+y], z+1, x+1)); 
		     status = MEMwrite_data (*data_f_cat, data1[offset+y], 
					     z+1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&buffer) ;
			 free (empty_str) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     break ;
		   }
/* if data buffer column = original_cisano and original item info buffer = n_cisano */
		 else if (! strcmp (data [count+c], "original_cisano") &&
			  (! strcmp (column1 [y], "n_cisano")))
		   {
		     status = MEMwrite_data (*data_f_cat, data1[offset+y], 
					     z+1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&buffer) ;
			 free (empty_str) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }

/* if data buffer column = original_fileno and original item info buffer = n_fileno */
		 else if (! strcmp (data [count+c], "original_fileno") &&
			  (! strcmp (column1 [y], "n_fileno")))
		   {
		     status = MEMwrite_data (*data_f_cat, data1[offset+y], 
					     z+1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&buffer) ;
			 free (empty_str) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }



/* if data buffer column = original_cifilename and original item info buffer = n_cifilename */
		 else if ((! strcmp (data [count+c], "original_cifilename")) &&
			  (! strcmp (column1 [y], "n_cifilename")))
		   {
		     status = MEMwrite_data (*data_f_cat, data1[offset+y], 
					     z+1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&buffer) ;
			 free (empty_str) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
	       }
	   }
       }
     free (empty_str) ;
 /* tmpPS
     MEMclose (&buffer) ;
     if (_NFMdebug_st.NFMdebug_on)
       {
	 MEMprint_buffer ("attr cat", *attr_cat, _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffer ("data cat", *data_cat, _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffers ("value cat", *value_cat, 
			   _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffer ("attr f_cat", *attr_f_cat, 
			  _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffer ("data f_cat", *data_f_cat, 
			  _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffers ("value f_cat", *value_f_cat, 
			   _NFMdebug_st.NFMdebug_file);
       }
*/
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS) ;
   }

/* note : data2_list has no rows when it returns */
long _NFMquery_catalog_attributes_for_copy (catalog_name,
					    attr1_list, data1_list, 
					    value1_list,
					    attr2_list, data2_list, 
					    value2_list)
     char     *catalog_name ;
     MEMptr   *attr1_list, *data1_list, *value1_list;
     MEMptr   *attr2_list, *data2_list, *value2_list;
{
  static char *fname = "_NFMquery_catalog_attributes_for_copy" ;
  long     status ;
  char     **column, str [1024], tmp_str [512] ;
  long     _NFMget_tables_attr_w ();
  long _NFMbuild_row_string () ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  
  status = _NFMget_tables_attr_for_copy (catalog_name,  
					 attr1_list, attr2_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  status = MEMbuild_array (*attr2_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : attr2_list : failed = status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr2_list)->column_ptr ;
  
  /******* n_action ********/
  _NFMbuild_row_string (str, *attr2_list, column,
			"n_action", "Action to be taken",
			"char(20)") ;
  
  /* add row to the buffer for n_action */
  status = MEMwrite (*attr2_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr2_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr2_list)->column_ptr ;
  
  /******** Original cisano *******/
  _NFMbuild_row_string (str, *attr2_list, column,
			"original_cisano", "Original Cisano",
			"integer") ;
  
  /* add row to the buffer for original_cisano */
  status = MEMwrite (*attr2_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr2_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr2_list)->column_ptr ;
  
  /******** Original fileno *******/
  _NFMbuild_row_string (str, *attr2_list, column,
			"original_fileno", "Original fileno",
			"integer") ;
  
  /* add row to the buffer for original_fileno */
  status = MEMwrite (*attr2_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr2_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr2_list)->column_ptr ;
  
  
  /******* original cifilename ******/
  sprintf (tmp_str, "char(%d)", NFM_CIFILENAME) ;
  _NFMbuild_row_string (str, *attr2_list, column,
			"original_cifilename", "Original Cifilename",
			tmp_str) ;
  
  /* add row to the buffer for original_cifilename */
  status = MEMwrite (*attr2_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr2_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : attr2_list : failed = status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr1_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : attr2_list : failed = status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr1_list)->column_ptr ;
  
  /******     original_itemno ******/
  _NFMbuild_row_string (str, *attr1_list, column,
			"original_itemno", "Original Itemno",
			"integer") ;
  
  /* add row to the buffer for original_itemno */
  status = MEMwrite (*attr1_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr1_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr1_list)->column_ptr ;
  
  /******     original_aclno ******/
  _NFMbuild_row_string (str, *attr1_list, column,
			"original_aclno", "Original Aclno",
			"integer") ;
  
  /* add row to the buffer for original_aclno */
  status = MEMwrite (*attr1_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr1_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*attr1_list)->column_ptr ;
  
  /******* original_status ********/
  sprintf (tmp_str, "char(%d)", NFM_STATUS) ;
  _NFMbuild_row_string (str, *attr1_list, column,
			"original_status", "Original Status",
			tmp_str) ;
  
  /* add row to the buffer for original_status */
  status = MEMwrite (*attr1_list, str) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMbuild_array (*attr1_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEMwrite : *list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  status = _NFMget_data_value (*attr1_list, data1_list, 
			       value1_list, "A", "R");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
		  status));
      return (status);          
    }
  /*
    status = _NFMget_data_value_no_data_rows (*attr2_list, data2_list, 
    value2_list);
    */
  status = _NFMget_data_value (*attr2_list, data2_list, 
			       value2_list, "A", "N");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
		  status));
      return (status);          
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

/*    get all attributes */
long _NFMget_tables_attr_for_copy (catalog_name, list, f_list)
     char     *catalog_name ;
     MEMptr   *list;
     MEMptr   *f_list;
{
  static char *fname = "_NFMget_tables_attr_for_copy" ;
  long     status;
  char     sql_str [2048], table_str [100] ;
  
  /*******  catalog ***********/
  
  sprintf (table_str, "n_tableno in (select n_tableno from nfmtables \
where n_tablename = '%s')",
	   catalog_name) ;
  
  sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s  %s",
	   "n_name, n_datatype, n_synonym, ",
	   "n_application, n_read, n_write, n_update, n_delete, n_null, ",
	   "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
	   "NFMATTRIBUTES", table_str, "ORDER BY n_seqno");
  
  status = _NFMget_attributes_from_query ( sql_str, list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  /******** f_catalog *******/
  
  sprintf (table_str, "n_tableno in (select n_tableno from nfmtables \
where n_tablename = 'f_%s')",
	   catalog_name) ;
  
  sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
	   "n_name, n_datatype, n_synonym, ",
	   "n_application, n_read, n_write, n_update, n_delete, n_null, ",
	   "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
	   "NFMATTRIBUTES", table_str, "ORDER BY n_seqno");
  
  status = _NFMget_attributes_from_query ( sql_str, f_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long _NFMbuild_row_string (str, attr_list, column,
			   n_name, n_synonym, n_datatype)
     char *str ;
     MEMptr attr_list ;
     char **column ;
     char *n_name ;
     char *n_synonym ;
     char *n_datatype ;
{
  char *fname = "_NFMbuild_row_string" ;
  long c, i ;
  char tmp_str [200] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* add an extra row for action in attr2_list */
  str [0] = 0 ;
  c = -1 ; 
/*  for (i=0; i<(*attr2_list)->columns; i++) */
  for (i=0; i<attr_list->columns; i++)
    {
      if (strcmp (column [i], "n_name") == 0)
	{
	  c = i ;
	  sprintf (tmp_str, "%s\001", n_name) ;
/*	  strcat (str, "n_action\1") ; */
	  strcat (str, tmp_str) ;
	}
      else if (strcmp (column [i], "n_datatype") == 0)
	{
/*	  strcat (str, "char(20)\1") ; */
	  sprintf (tmp_str, "%s\001", n_datatype) ;
	  strcat (str, tmp_str) ;
	}
      else if (strcmp (column [i], "n_synonym") == 0)
	{
/*	  strcat (str, "Action to be taken\1") ; */
	  sprintf (tmp_str, "%s\001", n_synonym) ;
	  strcat (str, tmp_str) ;
	}
      else if (strcmp (column [i], "n_application") == 0)
	strcat (str, "NFM\1") ;
      else if (strcmp (column [i], "n_read") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_write") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_update") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_delete") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_null") == 0)
	strcat (str, "Y\1") ;
      else if (strcmp (column [i], "n_checkin") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_checkout") == 0)
	strcat (str, "N\1") ;
      else if (strcmp (column [i], "n_attrno") == 0)
	strcat (str, "-1\1") ;
      else if (strcmp (column [i], "n_tableno") == 0)
	strcat (str, "-1\1") ;
      else if (strcmp (column [i], "n_seqno") == 0)
	{
	  sprintf (tmp_str, "%d\1", -1) ;
	  strcat (str, tmp_str) ;
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

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
