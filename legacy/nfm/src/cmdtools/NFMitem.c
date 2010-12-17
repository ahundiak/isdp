#include "machine.h"
#include "CMDTOOLS.h"
#include "NFMfile.h"

 long NFMget_item_no (user_id, cat_name, item_name, item_rev, item_no)
   long    user_id;
   char    *cat_name, *item_name, *item_rev;
   long    *item_no;
   {
     static char *fname = "NFMget_item_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];
     char    theItemName[100]; /* ticked item PS */
     char    theItemRevn[100];

     NFMtic_to_tics(item_name, theItemName);
     NFMtic_to_tics(item_rev, theItemRevn);

     *item_no = 0;

     _NFMdebug ((fname,"Cat Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n",
		 cat_name, item_name, item_rev));

/* PS */
     NFMtic_to_tics(item_name, theItemName);
     NFMtic_to_tics(item_rev, theItemRevn);
 
/* item_name is changed to theItemName - PS */
     sprintf (sql_str, "WHERE %s = '%s'", "n_itemname", theItemName) ;

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_itemrev");
     strcat (sql_str, " = ");

     strcat (sql_str, "'");
     strcat (sql_str, theItemRevn); /* item_rev is changed to theItemRevn -PS*/
     strcat (sql_str, "'");

     status = NFMget_attr_value (user_id, cat_name, "n_itemno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
           _NFMdebug ((fname, "No Such Item : status = <0x%.8x>\n", 
		       NFM_E_BAD_ITEM));
           return (NFM_E_BAD_ITEM);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *item_no = atol (value);

     status = NFMget_attr_value (user_id, cat_name, "n_itemlock",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     if (! strcmp (value, "Y"))
      {
           ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Item Locked : status = <0x%.8x>\n",
		    NFM_E_ITEM_LOCKED));
        return (NFM_E_ITEM_LOCKED);        
      }

     _NFMdebug ((fname, "Item No = <%d>\n", *item_no));

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMget_item_name (user_id, cat_name, item_no, item_name, item_rev)
   long    user_id;
   char    *cat_name;
   long    item_no;
   char    *item_name, *item_rev;
   {
     static char *fname = "NFMget_item_name" ;
     long    status;
     char    sql_str [1024], value [50];
     MEMptr  list = NULL;
     char    **data;

     item_name [0] = 0; item_rev [0] = 0;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n",
		 cat_name, item_no));

     sprintf (sql_str, "SELECT %s, %s FROM %s WHERE %s = %d",
	      "n_itemname", "n_itemrev", cat_name, "n_itemno", item_no);
 
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);

        if ((status) != SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
           _NFMdebug ((fname, "No Such Item : status = <0x%.8x>\n",
           NFM_E_BAD_ITEM));
           return (NFM_E_BAD_ITEM);
         }

           ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char **) list -> data_ptr;

     sprintf (item_name, "%s", data [0]);
     sprintf (item_rev,  "%s", data [1]);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }
     sprintf (sql_str, "WHERE %s = %d", "n_itemno", item_no);

     status = NFMget_attr_value (user_id, cat_name, "n_itemlock",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     if (! strcmp (value, "Y"))
      {
           ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Item Locked : status = <0x%.8x>\n", 
		    NFM_E_ITEM_LOCKED));
        return (NFM_E_ITEM_LOCKED);        
      }

     _NFMdebug ((fname, "Item Name = <%s> : Item Rev = <%s>\n", 
		 item_name, item_rev));

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_item (user_id, cat_name, item_no, type)
   long     user_id;
   char     *cat_name;
   long     item_no;
   long     type;
   {
     static char *fname = "NFMcheck_item" ;
     long    status;
     char    co_status [10];
     long NFMcheck_pending_flag () ;

     _NFMdebug ((fname, "Cat  Name  = <%s> : Item No = <%d> : Type = <%d>\n",
		 cat_name, item_no, type));

     status = NFMcheck_archive_state (user_id, cat_name, item_no);
     if ((status != NFM_S_SUCCESS) && (status != NFM_E_ITEM_BACKED_UP) &&
         (status != NFM_E_ITEM_NOT_BACKED_UP))
      {
        _NFMdebug ((fname, "Check Online : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMcheck_co_status (user_id, cat_name, item_no, co_status);
     if ((status != NFM_S_SUCCESS) && (status != NFM_E_NO_FILE)  &&
         (status != NFM_E_ITEM_IN) && (status != NFM_E_ITEM_OUT) &&
         (status != NFM_E_SET_OUT) && (status != NFM_E_MEM_OUT)  &&
         (status != NFM_E_SET_OUT_NO_FILE)     && 
         (status != NFM_E_MEM_OUT_NO_FILE)     &&
         (status != NFM_E_ITEM_OUT_TRANS)      &&
         (status != NFM_E_NO_FILE_OUT_TRANS))
      {
        _NFMdebug ((fname, "Check Co Out : status = <0x%.8x>\n", status));
        return (status);
      }
 
     if (type == NFM_ITEM_IN)
      {
        if (status != NFM_E_NO_FILE  && status != NFM_E_ITEM_OUT)
         {
           ERRload_struct (NFM, NFM_E_ITEM_NOT_READY_IN, "", NULL);
           _NFMdebug ((fname, "Item Not ready In : status = <0x%.8x>\n",
           NFM_E_ITEM_NOT_READY_IN));
           return (NFM_E_ITEM_NOT_READY_IN);
         }
      }
 
     if (type == NFM_ITEM_OUT)
      {
        if (status != NFM_E_ITEM_IN)
         {
           ERRload_struct (NFM, NFM_E_ITEM_NOT_READY_OUT, "", NULL);
           _NFMdebug ((fname, "Item Not Ready Out : status = <0x%.8x>\n", 
           NFM_E_ITEM_NOT_READY_OUT));
           return (NFM_E_ITEM_NOT_READY_OUT);
         }
      }

     if (type == NFM_ITEM_COPY)
      {
        if (status != NFM_E_ITEM_IN        &&
            status != NFM_E_ITEM_OUT       &&
            status != NFM_E_SET_OUT        &&
            status != NFM_E_MEM_OUT        &&
            status != NFM_E_ITEM_OUT_TRANS)
         {
           ERRload_struct (NFM, NFM_E_ITEM_NOT_READY_COPY, "", NULL);
           _NFMdebug ((fname, "Item Not Ready Copy : status = <0x%.8x>\n",
           NFM_E_ITEM_NOT_READY_COPY));
           return (NFM_E_ITEM_NOT_READY_COPY);
         }
      }

     if (type == NFM_SET_IN)
      {
        if (status != NFM_E_SET_OUT          &&
            status != NFM_E_SET_OUT_NO_FILE  &&
            status != NFM_E_NO_FILE)
         {
           ERRload_struct (NFM, NFM_E_SET_NOT_READY_IN, "", NULL);
           _NFMdebug ((fname, "Set Not Ready In : status = <0x%.8x>\n",
           NFM_E_SET_NOT_READY_IN));
           return (NFM_E_SET_NOT_READY_IN);
         }
      }

     if (type == NFM_SET_OUT)
      {
        if (status != NFM_E_ITEM_IN          &&
            status != NFM_E_NO_FILE)
         {
           ERRload_struct (NFM, NFM_E_SET_NOT_READY_OUT, "", NULL);
           _NFMdebug ((fname, "Set Not Ready Out : status = <0x%.8x>\n",
           NFM_E_SET_NOT_READY_OUT));
           return (NFM_E_SET_NOT_READY_OUT);
         }
      }

     if (type == NFM_SET_COPY)
      {
        if (status != NFM_E_ITEM_IN          &&
            status != NFM_E_NO_FILE          &&
            status != NFM_E_ITEM_OUT         &&
            status != NFM_E_SET_OUT          &&
            status != NFM_E_MEM_OUT          &&
            status != NFM_E_SET_OUT_NO_FILE  &&
            status != NFM_E_MEM_OUT_NO_FILE  &&
            status != NFM_E_ITEM_OUT_TRANS   &&
            status != NFM_E_NO_FILE_OUT_TRANS)
         {
           ERRload_struct (NFM, NFM_E_SET_NOT_READY_COPY, "", NULL);
           _NFMdebug ((fname, "Set Not Ready Copy : status = <0x%.8x>\n", 
           NFM_E_SET_NOT_READY_COPY));
           return (NFM_E_SET_NOT_READY_COPY);
         }
      }

     if (type == NFM_MEM_IN)
      {
        if (status != NFM_E_MEM_OUT          &&
            status != NFM_E_MEM_OUT_NO_FILE)
         {
           ERRload_struct (NFM, NFM_E_MEM_NOT_READY_IN, "", NULL);
           _NFMdebug ((fname, "Mem Not Ready In : status = <0x%.8x>\n",
           NFM_E_MEM_NOT_READY_IN));
           return (NFM_E_MEM_NOT_READY_IN);
         }
      }

     if (type == NFM_MEM_OUT)
      {
        if (status != NFM_E_ITEM_IN          &&
            status != NFM_E_NO_FILE)
         {
           ERRload_struct (NFM, NFM_E_MEM_NOT_READY_OUT, "", NULL);
           _NFMdebug ((fname, "Mem Not Ready Out : status = <0x%.8x>\n",
           NFM_E_MEM_NOT_READY_OUT));
           return (NFM_E_MEM_NOT_READY_OUT);
         }
      }

     if (type == NFM_MEM_COPY)
      {
        if (status != NFM_E_ITEM_IN           &&
            status != NFM_E_ITEM_OUT          &&
            status != NFM_E_NO_FILE           &&
            status != NFM_E_SET_OUT           &&
            status != NFM_E_MEM_OUT           &&
            status != NFM_E_SET_OUT_NO_FILE   &&
            status != NFM_E_MEM_OUT_NO_FILE   &&
            status != NFM_E_ITEM_OUT_TRANS    &&
            status != NFM_E_NO_FILE_OUT_TRANS)
         {
           ERRload_struct (NFM, NFM_E_MEM_NOT_READY_COPY, "", NULL);
           _NFMdebug ((fname, "Mem Not Ready Copy : status = <0x%.8x>\n",
           NFM_E_MEM_NOT_READY_COPY));
           return (NFM_E_MEM_NOT_READY_COPY);
         }
      }

     status = NFMcheck_pending_flag (user_id, cat_name, item_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Check Pend Flags : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMqry_items_in_cat  (user_id, catalog_name, data_list)   
   long     user_id;
   char     *catalog_name ;
   MEMptr   *data_list;
   {
      static char *fname = "NFMqry_items_in_cat" ;
      long     status, cat_no ;
      MEMptr   item_list = NULL ;
      char     sql_str [1024], str [512];
      char     **item_data ;
      int      i ;

      _NFMdebug ((fname,"Catalog Name = <%s>\n", catalog_name));

      if (strlen (catalog_name))
	{
	  status = NFMget_catalog_no (user_id, catalog_name, &cat_no) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "NFMget_catalog_no : status = <0x%.8x>\n",
			status));
	      return (status);
	    }
	  _NFMdebug ((fname, "Catalog Number = <%d>", cat_no));
	}
      else
	{
	  _NFMdebug ((fname, "Blank Catalog Name : status = <0x%.8x>\n",
		    NFM_E_BAD_CATALOG));
	  return (NFM_E_BAD_CATALOG) ;
	}

      sprintf (sql_str, "SELECT %s, %s, %s FROM %s",
               "n_itemno", "n_itemname", "n_itemrev",
	       catalog_name) ;

      status = SQLquery (sql_str, &item_list, 2*MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&item_list);
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
	  _NFMdebug ((fname, "SQL Query Syntax Error  = <0x%.8x>\n", status));
	  return (NFM_E_SQL_QUERY) ;
	}

      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&item_list) ;
	  ERRload_struct (NFM, NFM_E_NO_ITEMS_FOUND_IN_CAT, "", NULL) ;
	  return (NFM_E_NO_ITEMS_FOUND_IN_CAT) ;
	}

      status = MEMbuild_array (item_list) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&item_list);
	  ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
	  return (NFM_E_MEM) ;
	}

      item_data = (char **) item_list->data_ptr ;

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&item_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	  _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
	  return (NFM_E_MEM);          
	}
      
      status = MEMwrite_format (*data_list, "n_itemno", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&item_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*data_list, "n_itemname", "char(60)");
      if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&item_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*data_list, "n_itemrev", "char(60)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&item_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
         return (NFM_E_MEM);          
       }


      for (i=0; i<item_list->rows; i++)
	{
	  strcpy (str, item_data [i*item_list->columns]);
	  strcat (str, "\1");
	  strcat (str, item_data [i*item_list->columns+1]) ;
	  strcat (str, "\1");
	  strcat (str, item_data [i*item_list->columns+2]) ;
	  strcat (str, "\1");

	  status = MEMwrite (*data_list, str);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&item_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "MEMwrite : <0x%.8x>", status));
	      return (NFM_E_MEM);
	    }
  	}
      
      status = MEMclose (&item_list) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	  return (NFM_E_MEM);
	}

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
    }

 long NFMcheck_item_set_parent (user_id, cat_no, item_no)
   long     user_id;
   long     cat_no, item_no;
   {
     static char *fname = "NFMcheck_item_set_parent" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Cat  No = <%d>  : Item No = <%d>\n", 
		 cat_no, item_no));

     sprintf (sql_str, "WHERE %s = %d", "n_pcatalogno", cat_no);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_pitemno");
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     strcat (sql_str, value);

     status = NFMget_attr_value (user_id, "NFMSETCIT", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (atol (value) > 0)
      {
        ERRload_struct (NFM, NFM_E_SET_PARENT, "", NULL);
        _NFMdebug ((fname, "Set Parent : status = <0x%.8x>\n", NFM_E_SET_PARENT));
        return (NFM_E_SET_PARENT);
      }
     else
      {
        ERRload_struct (NFM, NFM_E_NOT_SET_PARENT, "", NULL);
        _NFMdebug ((fname, "Not A Set Parent : status = <0x%.8x>\n",
        NFM_E_NOT_SET_PARENT));
        return (NFM_E_NOT_SET_PARENT);
      }

/*** unreachable *****
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
**********************/
   }

 long NFMcheck_item_set_member (user_id, cat_no, item_no)
   long     user_id;
   long     cat_no, item_no;
   {
     static char *fname = "NFMcheck_item_set_member" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Cat  No = <%d>  : Item No = <%d>\n",
		 cat_no, item_no));

     sprintf (sql_str, "WHERE %s = %d", "n_ccatalogno", cat_no);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_citemno");
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     strcat (sql_str, value);

     status = NFMget_attr_value (user_id, "NFMSETCIT", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (atol (value) > 0)
      {
        ERRload_struct (NFM, NFM_E_SET_MEMBER, "", NULL);
        _NFMdebug ((fname, "Set Member : status = <0x%.8x>\n", NFM_E_SET_MEMBER));
        return (NFM_E_SET_MEMBER);
      }
     else
      {
        ERRload_struct (NFM, NFM_E_NOT_SET_MEMBER, "", NULL);
        _NFMdebug ((fname, "Not A Set Member : status = <0x%.8x>\n",
        NFM_E_NOT_SET_MEMBER));
        return (NFM_E_NOT_SET_MEMBER);
      }

/*** unreachable ***
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
********************/
   }

 long NFMcheck_item_project_member (user_id, cat_no, item_no)
   long     user_id;
   long     cat_no, item_no;
   {
     static char *fname = "NFMcheck_item_project_member" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Cat  No = <%d> : Item No = <%d>\n", 
		 cat_no, item_no));

     sprintf (sql_str, "WHERE %s = %d", "n_catalogno", cat_no);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_itemno");
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     strcat (sql_str, value);

     status = NFMget_attr_value (user_id, "NFMPROJECTCIT", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (atol (value) > 0)
      {
        ERRload_struct (NFM, NFM_E_PROJECT_MEMBER, "", NULL);
        _NFMdebug ((fname, "Project Member : status = <0x%.8x>\n",
        NFM_E_PROJECT_MEMBER));
        return (NFM_E_PROJECT_MEMBER);
      }
     else
      {
        ERRload_struct (NFM, NFM_E_NOT_PROJECT_MEMBER, "", NULL);
        _NFMdebug ((fname, "Not A Project Member : status = <0x%.8x>\n",
        NFM_E_NOT_PROJECT_MEMBER));
        return (NFM_E_NOT_PROJECT_MEMBER);
      }
/****  unreacheable
     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
****/
   }

 long NFMcheck_pending_flag (user_id, cat_name, item_no)
   long     user_id;
   char     *cat_name;
   long     item_no;
   {
     char *fname = "NFMcheck_pending_flag" ;
     long       status;
     char       sql_str [1024], sql_str1 [1024];
     MEMptr     list = NULL;
     char       **data;
     long       x;

     _NFMdebug ((fname, "Cat   Name = <%s> : Item No = <%d>\n", 
		 cat_name, item_no));
     user_id = user_id ;
     sprintf (sql_str, "WHERE n_itemno = %d", item_no);

/********** not needed ************
     strcat (sql_str, " AND ");
     strcat (sql_str, "n_fileclass");
     strcat (sql_str, " = ");

     strcat (sql_str, "'C'");        

     sprintf (attr, "MAX(%s)", "n_fileversion");

     status = NFMget_attr_value (user_id, file_cat, attr,
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
         if (status == NFM_I_BAD_CONDITION)
          {
            ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
            _NFMdebug ((fname, "No Such File : status = <0x%.8x>\n", 
			NFM_E_BAD_FILE)) ;
            return (NFM_E_BAD_FILE);
          }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_fileversion");
     strcat (sql_str, " = ");
     
     strcat (sql_str, value);
**************************/

    sprintf (sql_str1, "SELECT n_pendingflag FROM %s %s",
	     cat_name, sql_str);

    status = SQLquery (sql_str1, &list, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
       MEMclose (&list);

       if ((status ) == SQL_I_NO_ROWS_FOUND)
        {
	  ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
          _NFMdebug ((fname, "No Such Item File : status = <0x%.8x>\n", 
		      NFM_E_BAD_FILE));
          return (NFM_E_BAD_FILE);
        }

       _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
       return (status);
     }

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
     {
       MEMclose (&list);
       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
       _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		   status));
       return (NFM_E_MEM);
     }

    data = (char **) list -> data_ptr;

    /* Choudhary, This is causing the condition in the for loop to fail. so
       a check is never made to see if the item is checked out. I changed this
       to -1, you can change it back to whatever you want.  B.W. 5/16/90. */

    /* status = NFM_S_SUCCESS; */

    status = -1;

    for (x = 0; ((x < list -> rows) && (status != NFM_S_SUCCESS)); ++x)
     {
       if (! strlen (data [x]))     status = NFM_S_SUCCESS;
       else if (! strcmp (data [x], "IA"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_FLAG_ARCHIVE, "", NULL);
         status = NFM_E_ITEM_FLAG_ARCHIVE;
       }
       else if (! strcmp (data [x], "IB"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_FLAG_BACKUP, "", NULL);
         status = NFM_E_ITEM_FLAG_BACKUP;
       }
       else if (! strcmp (data [x], "ID"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_FLAG_DELETE, "", NULL);
         status = NFM_E_ITEM_FLAG_DELETE;
       }
       else if (! strcmp (data [x], "IR"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_FLAG_RESTORE, "", NULL);
         status = NFM_E_ITEM_FLAG_RESTORE;
       }
       else if (! strcmp (data [x], "SA"))
       {
         ERRload_struct (NFM, NFM_E_SET_FLAG_ARCHIVE, "", NULL);
         status = NFM_E_SET_FLAG_ARCHIVE;
       }
       else if (! strcmp (data [x], "SB"))
       {
         ERRload_struct (NFM, NFM_E_SET_FLAG_BACKUP, "", NULL);
         status = NFM_E_SET_FLAG_BACKUP;
       }
       else if (! strcmp (data [x], "SR"))
       {
         ERRload_struct (NFM, NFM_E_SET_FLAG_RESTORE, "", NULL);
         status = NFM_E_SET_FLAG_RESTORE;
       }
       else if (! strcmp (data [x], "MA"))
       {
         ERRload_struct (NFM, NFM_E_MEM_FLAG_ARCHIVE, "", NULL);
         status = NFM_E_MEM_FLAG_ARCHIVE;
       }
       else if (! strcmp (data [x], "MB"))
       {
         ERRload_struct (NFM, NFM_E_MEM_FLAG_BACKUP, "", NULL);
         status = NFM_E_MEM_FLAG_BACKUP;
       }
       else if (! strcmp (data [x], "MR"))
       {
         ERRload_struct (NFM, NFM_E_MEM_FLAG_RESTORE, "", NULL);
         status = NFM_E_MEM_FLAG_RESTORE;
       }
       else if (! strcmp (data [x], "PB"))
       {
         ERRload_struct (NFM, NFM_E_PROJ_FLAG_BACKUP, "", NULL);
         status = NFM_E_PROJ_FLAG_BACKUP;
       }
       else if (! strcmp (data [x], "PR"))
       {
         ERRload_struct (NFM, NFM_E_PROJ_FLAG_RESTORE, "", NULL);
         status = NFM_E_PROJ_FLAG_RESTORE;
       }
       else
       {
         ERRload_struct (NFM, NFM_E_UNKNOWN_PEND_FLAG, "", NULL);
         status = NFM_E_UNKNOWN_PEND_FLAG;
       }
     }

    if (status != NFM_S_SUCCESS)
     {
       MEMclose (&list);
       _NFMdebug ((fname, "Item Pend Flag : status = <0x%.8x>\n",
       status));
       return (status);
     }

    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
     {
       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
       _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		   status));
       return (NFM_E_MEM);
     }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
  }

