#include "machine.h"
#include "NFMU.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMlock_item (user_id, cat_name, item_name, item_rev)
   long    user_id;
   char    *cat_name, *item_name,  *item_rev;
{
  static char *fname = "NFMlock_item" ;
  long     status;
  char     sql_str [1024] ;
  char     copy_item_lock [NFM_DESCRIPTION+1] ;
  char     **data ;
  MEMptr   return_buffer = NULL ;
  long _NFMcheck_condition_for_lock  ();
  char    theItemName[100]; /* ticked item PS */
  char    theItemRevn[100];
  
  _NFMdebug ((fname, "Catalog Name = <%s>:Item Name = <%s> : Item Rev = <%s>\n",
	      cat_name, item_name, item_rev)) ;
/* PS */
  NFMtic_to_tics(item_name, theItemName);
  NFMtic_to_tics(item_rev, theItemRevn);
 
  user_id = user_id ;

/* PS - item_name and item-rev are replaced with the ticked variables
	theItemName and theItemRevn
*/
  status = _NFMcheck_condition_for_lock (cat_name, theItemName, theItemRevn);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Item can not be lock : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  strcpy (sql_str,
	  "select n_description from nfmsyscat where n_infotype = 'COPY ITEM LOCK'") ;
  
  status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  strcpy (copy_item_lock , "Y") ;
  
  if (status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (return_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      data = (char **) return_buffer->data_ptr ;
/* PS */
    _NFMdebug ((fname, "nfmsyscat:copy_item_lock : <%s>\n", data[0])) ;

      if ((! strcmp (data[0], "Y")))
	{
	  strcpy (copy_item_lock, "C")  ; 
	}
      
      status = MEMclose (&return_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }
/* PS */
    _NFMdebug ((fname, "item_lock set to: <%s>\n", copy_item_lock)) ;

/* PS - item_name and item_rev are replaced with theItemName and theItemRevn */ 
  sprintf (sql_str, "Update %s set n_itemlock = '%s', n_updater = '%s' \
           where n_itemname = '%s' and n_itemrev = '%s'",
           cat_name, copy_item_lock, NFMglobal.NFMusername, theItemName, 
           theItemRevn) ;
  
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", 
		  status));
      return (NFM_E_SQL_STMT);         
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long NFMunlock_item (user_id, cat_name, item_name, item_rev)
     long    user_id ;
     char    *cat_name, *item_name,  *item_rev;
{
  static char *fname = "NFMunlock_item" ;
  long     status;
  char     sql_str [1024] ;
  MEMptr   list = NULL ;
  char     **data ;
  char     message [512] ;
  char    theItemName[100]; /* ticked item PS */
  char    theItemRevn[100];

  _NFMdebug ((fname, "Catalog Name <%s> : Item Name <%s> : Item Rev <%s>\n",
	      cat_name, item_name, item_rev)) ;
  user_id = user_id ;
/* PS */
  NFMtic_to_tics(item_name, theItemName);
  NFMtic_to_tics(item_rev, theItemRevn);

/* PS - item_name and item_rev are replaced with theItemName and theItemRevn */ 
  sprintf (sql_str, "Select n_itemlock, n_updater from %s where n_itemname = '%s' and n_itemrev = '%s'",
  cat_name, theItemName, theItemRevn) ;
  
  status = SQLquery (sql_str, &list, 2 * MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Bad Item %s Rev %s in Cat %s\n",
		      item_name, item_rev, cat_name)) ;
	  ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
	  return (NFM_E_BAD_ITEM) ;
	}
      _NFMdebug ((fname, "Sql query : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array (list) : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM) ;
    }
  
  data = (char **) list->data_ptr ;
  
  if (!strcmp (data [0], "N"))
    {
      MEMclose (&list) ;
      _NFMdebug ((fname, "Item is not locked : status = <0x%.8x>\n",
		  NFM_E_ITEM_NOT_LOCKED)) ;
      ERRload_struct (NFM, NFM_E_ITEM_NOT_LOCKED, NULL) ;
      return (NFM_E_ITEM_NOT_LOCKED) ;
    }
  
  if (strcmp (data [1], NFMglobal.NFMusername))
    {
      MEMclose (&list) ;
      _NFMdebug ((fname, "Current User did not lock this item\n")) ;
      sprintf (message, "%s : %s", item_name, item_rev) ;
      ERRload_struct (NFM, NFM_E_USER_DID_NOT_LOCK, "%s", message) ; 
      return (NFM_E_USER_DID_NOT_LOCK) ;
    }
  
  status = MEMclose (&list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
/* PS - item_name and item_rev are replaced with theItemName and theItemRevn */  
  sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' where n_itemname = '%s' \
	   and n_itemrev = '%s'", cat_name, theItemName, theItemRevn) ;
  
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);         
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


/****** Item can be lock only if item is not checked out and when is not
        flag for archive, delete or restore ******************************/

long _NFMcheck_condition_for_lock  (catalog_name,
				    item_name, item_rev) 
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
{
  static char *fname = "_NFMcheck_condition_for_lock" ;
  MEMptr sql_buffer = NULL ;
  long status, offset, y ;
  char **data ;
  char sql_str [1024];

  sprintf (sql_str, "select n_status, n_pendingflag from %s where n_itemname = '%s' and n_itemrev = '%s'",
	   catalog_name,  item_name, item_rev) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  for (y=0; y<sql_buffer->rows; y++)
    {
      offset = y*sql_buffer->columns ;
      /* item must be in */
      if (strcmp (data [offset], "I")  && strcmp (data [offset], ""))
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Item is checked out\n")) ;
	  ERRload_struct (NFM, NFM_E_ITEM_OUT, "%s", item_name) ;
	  return (NFM_E_ITEM_OUT) ;
	}
      
      /* item must be not be flagged */
      if ((!strcmp (data [offset+1], "IA")) ||
          (!strcmp (data [offset+1], "IR")) ||
	  (!strcmp (data [offset+1], "ID")))
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Item is flagged for archive, or delete or restore\n")) ;
	  ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name) ;
	  return (NFM_E_ITEM_FLAGGED) ;
	}
    }
  
  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

