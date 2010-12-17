#include "machine.h"
#include "NFMA.h"
#include "MSGstruct.h"
#include "WFstruct.h"

  extern struct NFMglobal_st NFMglobal ;
  extern struct WFstruct WFinfo ;

long NFMchange_wf_item (catalog_name, item_name, item_rev, workflow_name, 
			aclname, acl_no, 
			statename, state_no)
     char *catalog_name ;   /** input - catalog name **/
     char *item_name ;      /** input - item name **/
     char *item_rev ;       /** input - item rev **/
     char *workflow_name ;   /** input **/
     char *aclname;
     long acl_no ;          /** input - acl no   **/
     char *statename;
     long state_no ;        /** input - state no **/
{
  static char *fname = "NFMchange_wf_item" ;
  char sql_str [1024] ;
  long status, cat_no, item_no, old_stateno, old_aclno ;
  MSGptr  app_msg;
  MEMptr  sql_buffer = NULL ;
  char   **data ;
  char   old_statename [NFM_STATENAME+1] ;
  struct  WFstruct wf_str ;
  long _NFMcheck_item_condition_for_ch_wf ();
  char  theItemName[100]; /* PS */
  char  theItemRevn[100];
  
  status = NFMget_catalog_no (NFMglobal.NFMuserid, catalog_name, &cat_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Bad catalog : %s : status = <0x%.8x>\n",
		  catalog_name, status)) ;
      return (status) ;
    }
  
   NFMtic_to_tics(item_name, theItemName);
   NFMtic_to_tics(item_rev, theItemRevn);
 
  sprintf (sql_str, "select a.n_itemno, a.n_stateno, a.n_aclno, b.n_statename  from %s a, nfmstates b where a.n_itemname = '%s' and a.n_itemrev = '%s' \
and a.n_stateno = b.n_stateno",
/* PS 
	   catalog_name, item_name, item_rev) ;
*/
	   catalog_name, theItemName, theItemRevn) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;

  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;
  item_no = atol (data [0]) ;
  old_stateno = atol (data [1]) ;
  old_aclno = atol (data [2]) ;
  strcpy (old_statename, data [3]) ;

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  status = _NFMcheck_item_condition_for_ch_wf (catalog_name,
					       item_name, item_rev,
					       cat_no, item_no, acl_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Item %s %s in cat %s in bad state\n",
		  item_name, item_rev, catalog_name)) ;
      return (status) ;
    }

  sprintf (sql_str, "delete from nfmsignoff where n_catalogno = %d and n_itemno = %d and n_stateno = %d",
	   cat_no, item_no, old_stateno) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_STMT) ;
    }

/* n_prevstateno is null */
  sprintf (sql_str, "update %s set n_aclno = %d, n_stateno = %d  where n_itemname = '%s' and n_itemrev = '%s'",
/* PS - item_rev is changed to theItemRevn which have proper ticks in it */
	   catalog_name, acl_no, state_no, theItemName, theItemRevn) ;

  status = SQLstmt (sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      _NFMdebug ((fname, "SQLstmt : status = <0x%8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
    }
  ERRload_struct (NFM, NFM_S_SUCCESS, "", "") ;
  app_msg.error_no = NFM_S_SUCCESS ;
  ERRget_message (app_msg.error_msg) ;
  /* copy the wf */
  strcpy (WFinfo.catalog_name, catalog_name) ;
  strcpy (WFinfo.item_name, item_name) ;
  strcpy (WFinfo.current_statename, old_statename) ;
  strcpy (WFinfo.next_statename, statename) ;
  strcpy (WFinfo.workflow_name, workflow_name) ;
  strcpy (WFinfo.acl_name, aclname) ;
  status = WFcopy_workflow_structure (NFMglobal.NFMuserid, 0, &wf_str) ;
  if (status == NFM_S_SUCCESS)
    {
      NFMadd_activity_entry (NFMglobal.NFMuserid, "NFM", app_msg) ;
      WFcopy_workflow_structure (NFMglobal.NFMuserid, 1, &wf_str) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

/******* only used for user *******************************/
long NFMget_wf_and_completed_acl_list_for_user (syn_list, data_list) 
     MEMptr *syn_list ;    /* output - */
     MEMptr *data_list ;   /* output - */
{
  char *fname = "NFMget_wf_and_completed_acl_list_for_user" ;
  long status ;
  char sql_str [1024] ;
  long _NFMget_synonym_buffer_acl_list ();

  status = _NFMget_synonym_buffer_acl_list (syn_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get synonym buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  sprintf (sql_str, "Select DISTINCT nfmworkflow.n_workflowname, nfmacls.n_aclname, nfmacls.n_aclno from nfmworkflow, nfmacls, nfmaclusers \
where nfmaclusers.n_userno = %d and \
nfmaclusers.n_aclno = nfmacls.n_aclno and \
nfmworkflow.n_workflowno = nfmacls.n_workflowno and \
nfmworkflow.n_workflowtype = 'I' and \
nfmacls.n_complete = 'Y'",
	   NFMglobal.NFMuserno) ;

  status = SQLquery (sql_str, data_list, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/* TR 249301030 - get all completed acls */
long NFMget_wf_and_completed_acl_list (syn_list, data_list) 
     MEMptr *syn_list ;    /* output - */
     MEMptr *data_list ;   /* output - */
{
  char *fname = "NFMget_wf_and_completed_acl_list" ;
  long status ;
  char sql_str [1024] ;
  long _NFMget_synonym_buffer_acl_list ();

  status = _NFMget_synonym_buffer_acl_list (syn_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get synonym buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  strcpy (sql_str, "Select DISTINCT nfmworkflow.n_workflowname, nfmacls.n_aclname, nfmacls.n_aclno from nfmworkflow, nfmacls, nfmaclusers \
where \
nfmaclusers.n_aclno = nfmacls.n_aclno and \
nfmworkflow.n_workflowno = nfmacls.n_workflowno and \
nfmworkflow.n_workflowtype = 'I' and \
nfmacls.n_complete = 'Y'") ;

  status = SQLquery (sql_str, data_list, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



long _NFMget_synonym_buffer_acl_list (synonym_list) 
    MEMptr *synonym_list ;
{
  static char *fname = "_NFMget_synonym_buffer_acl_list" ;
  long status ;
  char sql_str [1024], **data ;
  MEMptr sql_buffer = NULL ;  

  sprintf (sql_str, "Select n_synonym, n_seqno, n_name from nfmsysattributes \
where n_tableno in (select n_tableno from nfmtables where n_tablename = 'nfmworkflow' or n_tablename = 'nfmacls')\
and (n_name = 'n_workflowname' or n_name = 'n_aclname' or n_name = 'n_aclno')") ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;

  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  /* open buffer */
  status = MEMopen (synonym_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*synonym_list, "n_synonym", "char(40)");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*synonym_list, "n_read", "char(1)");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = _NFMinsert_synonym (sql_buffer, "n_workflowname", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_aclname", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_aclno", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
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


long NFMget_state_list_for_workflow (workflowname, syn_list, data_list) 
     char   *workflowname ;  /* input */
     MEMptr *syn_list ;      /* output */
     MEMptr *data_list ;     /* output */
{
  char *fname = "NFMget_state_list_for_workflow" ;
  long status ;
  char sql_str [1024] ;
  long _NFMget_synonym_buffer_state_list ();

  _NFMdebug ((fname, "ENTER\n")) ;
  status = _NFMget_synonym_buffer_state_list (syn_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get synonym buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  sprintf (sql_str, "Select a.n_statename, a.n_statedesc, a.n_stateno, a.n_seqno from nfmstates a, nfmworkflow b \
where a.n_workflowno = b.n_workflowno \
and b.n_workflowname = '%s' \
order by a.n_seqno",
	   workflowname) ;

  status = SQLquery (sql_str, data_list, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMget_synonym_buffer_state_list (synonym_list) 
    MEMptr *synonym_list ;
{
  static char *fname = "_NFMget_synonym_buffer_state_list" ;
  long status ;
  char sql_str [1024], **data ;
  MEMptr sql_buffer = NULL ;  

  sprintf (sql_str, "Select n_synonym, n_seqno, n_name from nfmsysattributes \
where n_tableno in (select n_tableno from nfmtables where n_tablename = 'nfmstates') \
and (n_name = 'n_statename' or n_name = 'n_statedesc' or n_name = 'n_stateno' or n_name = 'n_seqno')") ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;

  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  /* open buffer */
  status = MEMopen (synonym_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*synonym_list, "n_synonym", "char(40)");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*synonym_list, "n_read", "char(1)");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = _NFMinsert_synonym (sql_buffer, "n_statename", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_statedesc", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_stateno", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_seqno", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
/** verify that the ACL selected is valid for the item's catalog (mapped) 
    verify that the ACL selected is valid for the item's project (owned) 
    verify that the item is not locked 
 **/

long _NFMcheck_item_condition_for_ch_wf (catalog_name,
					 item_name, item_rev, 
					 cat_no, item_no,acl_no)
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
     long cat_no ;
     long item_no ;
     long acl_no ;
{
  static char *fname = "_NFMcheck_item_condition_for_ch_wf" ;
  MEMptr sql_buffer = NULL ;
  long status, i ;
  char **data ;
  char sql_str [1024];

  sprintf (sql_str, "select n_itemlock from %s where n_itemno = %d",
	   catalog_name, item_no) ;

  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Bad item : cat %s : item %s : rev %s\n",
		      catalog_name, item_name, item_rev)) ;
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

  if (strcmp (data [0], "N"))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", "") ;
      _NFMdebug ((fname, "Item is locked\n")) ;
      return (NFM_E_ITEM_LOCKED) ;
    }

  MEMclose (&sql_buffer) ;

/* is item owned by any project */
  sprintf (sql_str, "select c.n_aclno \
from nfmprojectcit a, nfmprojectaclmap b, nfmcatalogaclmap c \
where a.n_itemno = %d and a.n_catalogno = %d and a.n_type = 'O' \
and a.n_projectno = b.n_projectno \
and b.n_mapno = c.n_mapno \
and c.n_catalogno = a.n_catalogno",
	   item_no, cat_no) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      /* item is owned by project */
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}
      
      data = (char **) sql_buffer -> data_ptr ;
      
      for (i=0; i<sql_buffer->rows; i++)
	{
	  if (acl_no == atol (data [i]))
	    break ;
	}
      if (i == sql_buffer->rows)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_INV_ACL_FOR_OWNED_MEMBER, "", "") ;
	  _NFMdebug ((fname, "ACL not valid for owned item\n")) ;
	  return (NFM_E_INV_ACL_FOR_OWNED_MEMBER) ;
	}

      MEMclose (&sql_buffer) ;
    }
  else
    {
      /* is catalog mapped */
      sprintf (sql_str, "select n_aclno from nfmcatalogaclmap \
where n_catalogno = %d",
	       cat_no) ;
      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  /* catalog mapped */
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer -> data_ptr ;
	  
	  for (i=0; i<sql_buffer->rows; i++)
	    {
	      if (acl_no == atol (data [i]))
		break ;
	    }
	  if (i == sql_buffer->rows)
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_INV_ACL_FOR_MAPPED_CAT, "", "") ;
	      _NFMdebug ((fname, "ACL not valid for mapped catalog\n")) ;
	      return (NFM_E_INV_ACL_FOR_MAPPED_CAT) ;
	    }
	  MEMclose (&sql_buffer) ;
	}
      else
	{
	  _NFMdebug ((fname, "any acl is good\n")) ;
	}
    }  

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/****** ask jill undefined in NFMSdisplays ***/
/*
long NFMget_state_list_for_acl (aclname, syn_list, data_list) 
     char   *aclname ;  
     MEMptr *syn_list ; 
     MEMptr *data_list ;
{
  *aclname = *aclname ;
  *syn_list = *syn_list ;
  *data_list = *data_list ;

}

long NFMget_acl_list_for_catalog (catalog_name, syn_list, data_list)
     char *catalog_name ;
     MEMptr *syn_list ;   
     MEMptr *data_list ;  
{
}
*/


