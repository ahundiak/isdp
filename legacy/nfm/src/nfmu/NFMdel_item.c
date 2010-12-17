#include "machine.h"
#include "NFMU.h"
#include "NFMfto_buf.h"
#include "WFstruct.h"
#include "UTIerrordef.h"

extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;
extern long NFM_FTR_INITED;

 long NFMdelete_item (user_id, cat_name, item_name, item_rev, item_no)
   long    user_id;
   char    *cat_name;
   char    *item_name, *item_rev;
   long    *item_no;
   {
     static char *fname = "NFMdelete_item" ;
     long     status, atol () ;
     long     cat_no, x, offset, delete_saveset_flag, latest_version ;
     char     sql_str [1024], file_cat [100] ;
     MEMptr   list = NULL, move_buffer = NULL, error_ptr = NULL ;
     char     **data, cifilename [50], file_status [2] ;
     struct   fto_buf file_buffer ;
     long _NFMcheck_item_condition_delete_item ();
     
     *item_no = 0;
     user_id = user_id ;
     _NFMdebug ((fname, "Cat  Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n",
		 cat_name, item_name, item_rev)) ;

     if (WFinfo.catalog_no > 0)
       {
	 cat_no = WFinfo.catalog_no ;
       }
     else
       {
	 status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
	     return (status);
	   }
       }

     if (WFinfo.item_no > 0)
       {
	 *item_no = WFinfo.item_no ;
       }
     else
       {
	 status = NFMget_item_no (NFMglobal.NFMuserid, cat_name,
				  item_name, item_rev, item_no);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
	     return (status);
	   }
       }

/* item has to be checked in, not a set, not a member of set, not a member of project */

     status = _NFMcheck_item_condition_delete_item (cat_name,
						    item_name, item_rev,
						    cat_no, *item_no,
						    &delete_saveset_flag,
						    file_status);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Item can not be deleted : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (file_cat, "f_%s", cat_name);

     sprintf (sql_str, "SELECT n_fileno, n_cifilename, n_cisano, n_fileversion, n_fileco FROM %s WHERE n_itemnum = %d order by n_fileversion",
	      file_cat, *item_no);
 
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
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

     latest_version = atol (data [(list -> rows -1) * (list -> columns) + 3]);
     _NFMdebug ((fname, "Latest version is %d\n", latest_version)) ;

     if (strcmp (file_status, "I") == 0) 
       {
	 for (x = 0; x < list -> rows; ++x)
	   {
	     offset = x*list->columns ;
	     if (strcmp (data [offset+4], "O"))
	       {
		 status = _NFMget_sano_info_fto_buf (atol (data [offset+2]), "",
						     &file_buffer) ;
		 if (status != NFM_S_SUCCESS)
		   {
		     _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
				 status)) ;
		     return (status) ;
		   }
		 
		 if (! move_buffer)
		   {
		     status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
				     status)) ;
			 MEMclose (&move_buffer) ;
			 continue ;
		       }
		   }
		 
		 file_buffer.n_status1 = NFM_DELETE_FILE ;
		 
		 if ((atol (data [offset+3]) == latest_version) &&
		     (strlen (data [offset+1])))
		   {
		     strcpy (file_buffer.n_cifilename, data[offset+1]) ;
		   }
		 else
		   {
		     status = NFMget_file_name (NFMglobal.NFMuserid,
						cat_no, atol (data [offset]),
						cifilename) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 MEMclose (&move_buffer) ;
			 _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
				     status)) ;
			 continue ;
		       }
		     strcpy (file_buffer.n_cifilename, cifilename) ;
		   }
		 status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
		 if (status != NFM_S_SUCCESS)
		   {
		     MEMclose (&move_buffer) ;
		     _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
				 status)) ;
		     continue ;
		   }
	       }
	   }
       }
     else
       {
	 _NFMdebug ((fname, "Item is not checked in\n")) ;
       }
     
     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 _NFMdebug ((fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
     /* 02/08/93 -MFB- Adding 2 delete stmt (nfmsafiles and nfmsavesets) to fix
                       TR 249203257 */
     sprintf (sql_str, 
       "delete from nfmsafiles where n_catalogno = %d and n_itemno = %d",
       cat_no, *item_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS && 
         status != SQL_I_NO_ROWS_FOUND)
     {
       _NFMdebug ((fname, "Failed to delete from nfmsafiles\n"));
       MEMclose (&list);
       MEMclose (&move_buffer) ;
       NFMrollback_transaction (0);
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (NFM_E_SQL_STMT);
     }
     sprintf (sql_str, 
       "delete from nfmsavesets where n_catalogno = %d and n_itemno = %d",
       cat_no, *item_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS && 
         status != SQL_I_NO_ROWS_FOUND)
     {
       _NFMdebug ((fname, "Failed to delete from nfmsavesets\n"));
       MEMclose (&list);
       MEMclose (&move_buffer) ;
       NFMrollback_transaction (0);
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (NFM_E_SQL_STMT);
     }

     sprintf (sql_str, "DELETE FROM %s WHERE n_itemnum = %d",
	      file_cat, *item_no) ;
	      
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND)) 
       {
	 MEMclose (&list);
	 MEMclose (&move_buffer) ;
	 NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	 _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_SQL_STMT);
       }
     
     for (x=0; x<list->rows; ++x)
       {
	 offset = x*list->columns ;

/******* do not return n_fileno ********
	 status = NFMreturn_serial_slot (NFMglobal.NFMuserid, file_cat,
					 "n_fileno", atol (data [offset]));
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     MEMclose (&move_buffer) ;
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
			 status));
	     return (status) ;
	   }
***********/
       }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_MEM);
       }
     
     sprintf (sql_str, "DELETE FROM %s WHERE n_itemno = %d",
	      cat_name, *item_no);
     
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
	MEMclose (&move_buffer) ;
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     status = NFMreturn_serial_slot (NFMglobal.NFMuserid, cat_name, 
              "n_itemno", *item_no);
     if (status != NFM_S_SUCCESS)
      {
	MEMclose (&move_buffer) ;
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
        status));
        return (status);
      }
     _NFMdebug ((fname, "delete saveset flag is %d\n", delete_saveset_flag)) ;

     sprintf (sql_str, "DELETE FROM NFMSAVESETS WHERE n_catalogno = %d and n_itemno = %d",
	      cat_no, *item_no) ;
     
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (&move_buffer) ;
	 MEMclose (&list) ;
	 NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	 _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_SQL_STMT);
       }

     if (NFM_FTR_INITED)
     {
       _NFMdebug ((fname, 
           "clean up FTR collection, cat_no [%d] item_no [%d]\n", cat_no,
           *item_no));
       status = NFT_delete_item (cat_no, *item_no);
       if (status != UTI_S_SUCCESS)
       {
         /* not a fatal error for a mixed environment */
         _NFMdebug ((fname, "NFT_delete_item 0x%.8x\n", status));
       }
       ERRreset_struct ();
     }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 _NFMdebug ((fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     if (_NFMdebug_st.NFMdebug_on)
       {
	 MEMprint_buffers ("delete buffer", move_buffer, 
			   _NFMdebug_st.NFMdebug_file) ;
       }
     
     if (move_buffer != NULL)
       {
	 status = NFMfs_chg_files (&move_buffer, &error_ptr) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "remove co files failed : status = <0x%.8x>\n",
			 status)) ;
	     /* send warning */
             /* 12/8/94 Since it is going to return successfully, clear the
                        error buffer, so no one will panic, TR 249301798 */
             ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
	   }
	 
	 MEMclose (&move_buffer) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
  }


/* item has to be checked in, not a set, not a member of set, 
   not a member of project */
long _NFMcheck_item_condition_delete_item (catalog_name,
					    item_name, item_rev,
					   cat_no, item_no, 
					   delete_saveset_flag,
					   file_status)
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
     long cat_no ;
     long item_no ;
     long *delete_saveset_flag ;
     char *file_status ;
{
  static char *fname = "_NFMcheck_item_conditon_delete_item" ;
  MEMptr sql_buffer = NULL ;
  long status ;
  char **data ;
  char sql_str [1024];

  *delete_saveset_flag = 0 ;

  sprintf (sql_str, "select n_status, n_setindicator, n_archivestate, n_pendingflag, n_itemlock from %s where n_itemname = '%s' and n_itemrev = '%s'",
	   catalog_name, item_name, item_rev) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Bad item : cat %s : item %s : rev %s\n",
		      catalog_name, item_name, item_rev)) ;
	  ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
	  return (NFM_E_BAD_ITEM) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  strcpy (file_status, data[0]) ;

  if ((strcmp (data [0], "I")) && (strcmp (data [0], "")))
    {
      _NFMdebug ((fname, "Item is not checked in\n")) ;
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_OUT, "%s", item_name) ;
      return (NFM_E_ITEM_OUT) ;
    }
  else if (strcmp (data [1], ""))
    {
      _NFMdebug ((fname, "Item is set\n")) ;
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_SET, "", "") ;
      return (NFM_E_SET) ;
    }
 else if (strcmp (data [2], ""))
   {
     if (strcmp (data [2], "A") == 0)
       {
	 *delete_saveset_flag = 1 ;
/*	 ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "", "") ; */
	 MEMclose (&sql_buffer) ;
       }
     else if (strcmp (data[2], "B") == 0)
       {
/*	 ERRload_struct (NFM, NFM_E_ITEM_BACKED_UP, "", "") ; */
	 *delete_saveset_flag = 1 ;
	 MEMclose (&sql_buffer) ;
       }
   }
  else if ((strcmp (data [3], "")) && (strcmp (data [3], "ID")))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name) ;
      _NFMdebug ((fname, "Item is flagged\n")) ;
      return (NFM_E_ITEM_FLAGGED) ; 
    }
  else if (strcmp (data [4], "N"))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", "") ;
      _NFMdebug ((fname, "Item is locked\n")) ;
      return (NFM_E_ITEM_LOCKED) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  sprintf (sql_str, "select n_citemno from nfmsetcit where (n_ccatalogno = %d and n_citemno = %d) or (n_pcatalogno = %d and n_pitemno = %d)",
	   cat_no, item_no, cat_no, item_no) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "item member of set\n")) ;
      ERRload_struct (NFM, NFM_E_SET_MEMBER, "", "") ;
      return (NFM_E_SET_MEMBER) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  sprintf (sql_str, "select n_catalogno from nfmprojectcit where n_catalogno = %d and n_itemno = %d",
	   cat_no, item_no) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "item member of project\n")) ;
      ERRload_struct (NFM, NFM_E_PROJECT_MEMBER, "", "") ;
      return (NFM_E_PROJECT_MEMBER) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



