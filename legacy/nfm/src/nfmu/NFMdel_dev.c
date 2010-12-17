#include "machine.h"
#include "NFMA.h"

 long NFMdelete_storage_area (user_id, storage_name)
   long    user_id;
   char    *storage_name;
   {
     static char *fname = "NFMdelete_storagea_area" ;
      long      status, atol ();
      char      sql_str [1024];
      long      sa_no;
      long      NFMcheck_files_sa ();
      long      NFMcheck_sa_in_catalog_map ();      

      _NFMdebug ((fname, "Storagea Area Name = <%s>\n", storage_name));

      status = NFMget_sa_no (user_id, storage_name, &sa_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Failure : Get Sa No : status = <0x%.8x>\n",
         status));
         return (status);
       }
 
      if (sa_no <= 4)
       {
         ERRload_struct (NFM, NFM_E_SYSTEM_SA, "", NULL);
         _NFMdebug ((fname, "Failure : System Storage Area : status = <0x%.8x>\n",
		     NFM_E_SYSTEM_SA));
         return (NFM_E_SYSTEM_SA);
       }

      status = NFMcheck_files_sa (user_id, sa_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Failure : Chk If Files In Sa : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcheck_sa_in_catalog_map (user_id, sa_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Failure : Chk User In Sign Off : status = <0x%.8x>\n",
         status));
         return (status);
       }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d",
	      "NFMSTORAGEAREA", "n_sano", sa_no);

      status = NFMset_autocommit_off (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Failure : SQL Stmt Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);
       }

      status = NFMreturn_serial_slot (user_id, "nfmstoragearea", 
               "n_sano", sa_no);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "Failure : Return Serial Slot : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMset_autocommit_on (0) ;
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_files_sa (user_id, sa_no)
   long    user_id;
   long    sa_no;
   {
     static char *fname = "NFMcheck_files_sa" ;
      long     status, atol ();
      char     sql_str [1024], value [50];
      char     file_cat [100];
      MEMptr   list = NULL;
      char     **data;
      long     x;

      _NFMdebug ((fname, "Storage Area No = <%d>\n", sa_no));

      sprintf (sql_str, "SELECT n_catalogname FROM %s where n_catalogname != 'nfmsyscat'", "NFMCATALOGS");

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS && 
          ((status) != SQL_I_NO_ROWS_FOUND)))
       {
         MEMclose (&list);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "Failure : SQL Query Syntax : status = <0x%.8x>\n",
		     status));
         return ( NFM_E_SQL_QUERY);            
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "Failure : MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);            
       }

      data = (char **) list -> data_ptr;

      for (x = 0; x < list -> rows; ++x)
       {
         sprintf (file_cat, "f_%s", data [x]);

	 sprintf (sql_str, "WHERE %s = %d", "n_cisano", sa_no);

         status = NFMget_attr_value (user_id, file_cat, "COUNT(*)",
                  sql_str, value);
         if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
          {
             MEMclose (&list);
             _NFMdebug ((fname, "Failure : Get Attr Value : status = <0x%.8x>\n",
             status));
             return (status);            
          }

         if (atol (value) > 0)
          {
             MEMclose (&list);
         ERRload_struct (NFM, NFM_E_ACTIVE_CI_SA, "", NULL);
             _NFMdebug ((fname, "Failure : Active Ci Sa : status = <0x%.8x>\n",
             NFM_E_ACTIVE_CI_SA));
             return (NFM_E_ACTIVE_CI_SA);            
          }

	 sprintf (sql_str, "WHERE %s = %d", "n_cosano", sa_no);

         strcat (sql_str, " AND ");
         strcat (sql_str, "n_fileco");
         strcat (sql_str, " = ");

	 strcat (sql_str, "'Y'");

         status = NFMget_attr_value (user_id, file_cat, "COUNT(*)",
                  sql_str, value);
         if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
          {
             MEMclose (&list);
             _NFMdebug ((fname, "Failure : Get Attr Value : status = <0x%.8x>\n",
             status));
             return (status);            
          }

         if (atol (value) > 0)
          {
             MEMclose (&list);
         ERRload_struct (NFM, NFM_E_ACTIVE_CO_SA, "", NULL);
             _NFMdebug ((fname, "Failure : Active Co Sa : status = <0x%.8x>\n",
             NFM_E_ACTIVE_CO_SA));
             return (NFM_E_ACTIVE_CO_SA);            
          }
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "Failure : MEM Close : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);            
       }
      
      _NFMdebug ((fname, "SUCCESSFUL\n"));
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_sa_in_catalog_map (user_id, sa_no)
   long    user_id;
   long    sa_no;
   {
     static char *fname = "NFMcheck_sa_in_catalog_map" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

     _NFMdebug ((fname, "Sa No %d\n", sa_no)) ;

     sprintf (sql_str, "WHERE %s = %d", "n_sano", sa_no);

      status = NFMget_attr_value (user_id, "NFMCATALOGSAMAP", "COUNT(*)",
               sql_str, value);
      if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
       {
         _NFMdebug ((fname, "Failure : Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);            
       }

      if (atol (value) > 0)
       {
         ERRload_struct (NFM, NFM_E_SA_CATALOG_MAP, "", NULL);
         _NFMdebug ((fname, "Failure : Sa Exists In Cat Map : status = <0x%.8x>\n",
         NFM_E_SA_CATALOG_MAP));
         return (NFM_E_SA_CATALOG_MAP);            
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

