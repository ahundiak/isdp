#include "machine.h"
#include "NFMA.h"
  
  extern struct NFMglobal_st NFMglobal ;
  extern long NFM_TRANSACTION ;

 long NFMdelete_catalog (user_id, cat_name, cat_no)
   long      user_id;
   char      *cat_name;
   long      *cat_no;
   {
     static char *fname = "NFMdelete_catalog" ;
     long     status;
     char     file_cat [100];
     long     NFMcheck_catalog_empty ();
     long     _NFMcheck_cat_no_mapping () ;
     long     NFMdelete_default_catalog_acl_map ();
     long     NFMdelete_default_catalog_sa_map ();
     long     NFMdelete_loc_entry ();
     long     _NFMrm_nfmsafiles_entry () ;
     long     _NFMrm_nfmsafiles_entry () ;

     *cat_no = 0;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name ));
     user_id = user_id ;

     /* the argument must match what the global variable NFM_TRANSACTION has
        in order to COMMIT WORK will get executed and then it set
        NFM_TRANSACTION to -1 */

     status = NFMset_autocommit_on (0) ;
     if ((status != NFM_S_SUCCESS) || (NFM_TRANSACTION != -1))
       {
         _NFMdebug ((fname, "Failure to force autocommit on : NFM_TRANSACTION is <%d>\n", NFM_TRANSACTION)) ;
         return (status) ;
       }

     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, cat_no);
     if (status != NFM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL) ;
        _NFMdebug ((fname, "Get Catalog No : status = <0x%.8x>\n", status));
        return (NFM_E_BAD_CATALOG) ;
      }

     status = NFMcheck_catalog_empty (NFMglobal.NFMuserid, cat_name);
     if (status != NFM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_NOT_EMPTY_CAT, "", NULL) ;
        _NFMdebug ((fname, "Empty Catalog : status = <0x%.8x>\n", status));
        return (NFM_E_NOT_EMPTY_CAT);
      }

     status = _NFMcheck_cat_no_mapping (NFMglobal.NFMuserid, *cat_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Cat Mappings exist\n", status)) ;
	 return (status) ;
       }

/************************************************************
     status = NFMdelete_default_catalog_acl_map (NFMglobal.NFMuserid, *cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Empty Catalog : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMdelete_default_catalog_sa_map (NFMglobal.NFMuserid, *cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Empty Catalog : status = <0x%.8x>\n", status));
        return (status);
      }
 ******************************************************************/
     status = _NFMrm_nfmsafiles_entry (*cat_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	 return (status) ;
       }

     status = NFMdelete_table (NFMglobal.NFMuserid, "CATALOG", cat_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Table : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMdelete_table (NFMglobal.NFMuserid, "F_CATALOG", file_cat);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Table : status = <0x%.8x>\n", status));
        return (status);
      }

     status = _NFMdelete_application_tables (cat_name) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Table : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMdelete_loc_entry (NFMglobal.NFMuserid, *cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Loc Entry : status = <0x%.8x>\n", status));
        return (status);
      }
 
     _NFMdebug ((fname, "Cat No = <%d> : SUCCESSFUL\n", *cat_no));

     return (NFM_S_SUCCESS);
   }

 long NFMcheck_catalog_empty (user_id, cat_name)
   long    user_id;
   char    *cat_name;
   {
     static char *fname = "NFMcheck_catalog_empty" ;
     long   status, atol ();
     char   value [20];

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;

     status = NFMget_attr_value (NFMglobal.NFMuserid, cat_name,
              "COUNT(*)", "", value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     if (atol (value) > 0)
      {
        ERRload_struct (NFM, NFM_E_NOT_EMPTY_CAT, "", NULL);
        _NFMdebug ((fname, "Cat Not Empty : status = <0x%.8x>\n", NFM_E_NOT_EMPTY_CAT));
        return (NFM_E_NOT_EMPTY_CAT);
      }
          
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_default_catalog_acl_map (user_id, cat_no)
   long    user_id;
   long    cat_no;
   {
     static char *fname = "NFMdelete_default_catalog_acl_map" ;
     long    status, atol ();
     char    **data;
     MEMptr  list = NULL;
     char    sql_str [1024];
     long    x;
     long    NFMdelete_default_project_acl_map ();

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no ));
     user_id = user_id ;
     
     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
                "n_mapno", "NFMCATALOGACLMAP", "n_catalogno", cat_no);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
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

     for (x = 0; x < list -> rows; ++x)
      {
        status = NFMdelete_default_project_acl_map (NFMglobal.NFMuserid,
                 atol (data [x]));
        if ((status != NFM_S_SUCCESS) &&
            (status != NFM_E_NO_PROJECT_ACL_MAP))
         {
           MEMclose (&list);
           _NFMdebug ((fname, "Del Proj Map : status = <0x%.8x>\n",
           status));
           return (status);
         }

	sprintf (sql_str, "DELETE FROM %s WHERE %s = %s",
		 "NFMCATALOGACLMAP", "n_mapno", cat_no);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           MEMclose (&list);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT);
         }

        status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmcatalogaclmap", 
                 "n_mapno", atol (data [x]));
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           _NFMdebug ((fname, "Ret Ser Slot : status = <0x%.8x>\n",
           status));
           return (NFM_S_SUCCESS);
         }
      }

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_default_catalog_sa_map (user_id, cat_no)
   long    user_id;
   long    cat_no;
   {
     static char *fname = "NFMdelete_default_catalog_sa_map" ;
     long    status, atol ();
     char    **data;
     MEMptr  list = NULL;
     char    sql_str [1024];
     long    x;
     long    NFMdelete_default_project_sa_map ();

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no ));
     user_id = user_id ;

     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
	      "n_mapno", "NFMCATALOGSAMAP", "n_catalogno", cat_no);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
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

     for (x = 0; x < list -> rows; ++x)
      {
        status = NFMdelete_default_project_sa_map (NFMglobal.NFMuserid,
                 atol (data [x]));
        if ((status != NFM_S_SUCCESS) &&
            (status != NFM_E_NO_PROJECT_SA_MAP))
         {
           MEMclose (&list);
           _NFMdebug ((fname, "Del Project Map : status = <0x%.8x>\n",
           status));
           return (status);
         }

	sprintf (sql_str, "DELETE FROM %s WHERE %s = %s",
		 "NFMCATALOGSAMAP", "n_mapno", cat_no);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           MEMclose (&list);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT);
         }

        status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmcatalogsamap", 
                 "n_mapno", atol (data [x]));
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_loc_entry (user_id, cat_no)
   long    user_id;
   long    cat_no;
   {
     static char *fname = "NFMdelete_loc_entry" ;
     long      status;
     int       error_subsystem ;
     long      error_no ;
     char      sql_str [1024], message [512] ;

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no ));
     user_id = user_id ;

     ERRget_message (message) ;
     ERRget_number (&error_no, &error_subsystem) ;
     _NFMdebug ((fname, "error found was <0x%.8x> subsystem %d\n",
		 error_no, error_subsystem)) ;
     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
                "NFMCATALOGS", "n_catalogno", cat_no);

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     if ((error_subsystem == SQL) && (error_no != SQL_S_SUCCESS))
       {
	 /* reload previous SQL error */
	 _NFMdebug ((fname, "Reloading SQL error <0x%.8x>\n", error_no)) ;
	 ERRload_struct (SQL, error_no, "%s", message) ;
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
       }
     else if ((error_subsystem == MEM) && (error_no != MEM_S_SUCCESS))
       {
	 /* reload previous MEM error */
	 _NFMdebug ((fname, "Reloading MEM error <0x%.8x>\n", error_no)) ;
	 ERRload_struct (MEM, error_no, "%s", message) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       }


     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_default_project_acl_map (user_id, map_no)
   long    user_id;
   long    map_no;
   {
     static char *fname = "NFMdelete_default_project_acl_map" ;
     long    status;
     char    sql_str [1024];

     _NFMdebug ((fname, "Map  No = <%d>\n", map_no ));
     user_id = user_id ;
     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
	      "NFMPROJECTACLMAP", "n_mapno", map_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT); 
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_default_project_sa_map (user_id, map_no)
   long    user_id;
   long    map_no;
   {
     static char *fname = "NFMdelete_default_project_sa_map" ;
     long    status;
     char    sql_str [1024];

     _NFMdebug ((fname, "Map  No = <%d>\n", map_no ));
     user_id = user_id ;

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
	      "NFMPROJECTSAMAP", "n_mapno", map_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT); 
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

/* return NFM_S_SUCCESS if catalog has no mappings */
long _NFMcheck_cat_no_mapping (user_id, cat_no)
   long    user_id;
   long    cat_no;
   {
     static char *fname = "_NFMcheck_cat_no_mapping" ;
     long    status, sa_status, acl_status ;
     MEMptr  list = NULL;
     char    sql_str [1024];

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no ));
     user_id = user_id ;
     sprintf (sql_str, "SELECT n_mapno FROM NFMCATALOGACLMAP \
WHERE n_catalogno = %d", cat_no) ;

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     acl_status = status ;

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     sprintf (sql_str, "SELECT n_mapno FROM NFMCATALOGSAMAP \
WHERE n_catalogno = %d", cat_no) ;

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     sa_status = status ;

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     if ((acl_status != SQL_I_NO_ROWS_FOUND) &&
	 (sa_status != SQL_I_NO_ROWS_FOUND))
       {
	 ERRload_struct (NFM, NFM_E_MAPPINGS_EXIST, "", NULL);
	 return (NFM_E_MAPPINGS_EXIST) ;
       }
     else if (acl_status != SQL_I_NO_ROWS_FOUND)
       {
	 ERRload_struct (NFM, NFM_E_ACL_MAP_EXIST, "", NULL) ; 
	 return (NFM_E_ACL_MAP_EXIST) ;
       }
     else if (sa_status != SQL_I_NO_ROWS_FOUND)
       {
	 ERRload_struct (NFM, NFM_E_SA_CATALOG_MAP_EXIST, "", NULL) ;
	 return (NFM_E_SA_CATALOG_MAP_EXIST) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long _NFMrm_nfmsafiles_entry (catalog_no)
     long catalog_no ;
{
  char *fname = "_NFMrm_nfmsafiles_entry" ;
  long status ;
  char sql_str [500] ;

  _NFMdebug ((fname, "catalog no <%d>\n", catalog_no)) ;

  sprintf (sql_str, "delete from nfmsafiles where n_catalogno = %d",
	   catalog_no) ;

  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


