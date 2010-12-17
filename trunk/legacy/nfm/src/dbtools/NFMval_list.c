#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long NFMget_transition_acl_list (user_id, list)
   long    user_id;
   MEMptr  *list;
   {
     static char *fname = "NFMget_transition_acl_list" ;
     long     status, atol ();
     char     sql_str [4096], sql_str1 [2048], value [50];
     MEMptr   list1 = NULL;
     char     **data;
     long     x;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     sprintf (sql_str1, "SELECT DISTINCT (%s.%s) FROM %s, %s, %s ",
              "NFMACLUSERS", "n_aclno", "NFMTRANSITIONS",
              "NFMACCESS", "NFMACLUSERS");

     sprintf (sql_str, 
     "%s WHERE %s.%s = %d AND %s.%s = %s.%s AND %s.%s = %s.%s",
     sql_str1, "NFMTRANSITIONS", "n_commandno", WFinfo.command, 
     "NFMACCESS", "n_transitionno", "NFMTRANSITIONS", "n_transitionno",
     "NFMACLUSERS", "n_classno", "NFMACCESS", "n_classno");

     status = SQLquery (sql_str, &list1, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list1);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     data = (char **) list1 -> data_ptr;


     for (x = 0; x < list1 -> rows; ++x)
      {
	sprintf (value, "'Y'");

        sprintf (sql_str1, 
        "%s (%s.%s), %s.%s, %s.%s FROM %s WHERE %s.%s = %s AND ",
        "SELECT DISTINCT",
        "NFMACLS", "n_aclno", "NFMWORKFLOW", "n_workflowname", "NFMACLS", "n_aclname",
        "NFMACLUSERS, NFMACLS, NFMWORKFLOW", "NFMACLS", "n_complete", value);

	sprintf (value, "%d", NFMglobal.NFMuserno);
      
	sprintf (sql_str,
		 "%s %s.%s = %s AND %s.%s = %s AND %s.%s = %s.%s AND %s.%s = %s.%s",
		 sql_str1, "NFMACLUSERS", "n_aclno", data [x], 
		 "NFMACLUSERS", "n_userno", value,
		 "NFMACLS", "n_aclno", "NFMACLUSERS", "n_aclno",
		 "NFMWORKFLOW", "n_workflowno", "NFMACLS", "n_workflowno");

        status = SQLquery (sql_str, list, MEM_SIZE);
        if ((status != SQL_S_SUCCESS) &&
            ((status) != SQL_I_NO_ROWS_FOUND))
         {
           MEMclose (list);
           MEMclose (&list1);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
           _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
           return ( NFM_E_SQL_QUERY);
         }
      }

     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n"))  ;
     return (NFM_S_SUCCESS);
   }

long _NFMget_catalog_acl_list (list)
     MEMptr  *list;
{
  char *fname = "_NFMget_catalog_acl_list" ;
  long status  ;
  char sql_str [1024] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  sprintf (sql_str, "select a.n_aclno, a.n_aclname \
from nfmacls a, nfmworkflow b, nfmaclusers c \
where a.n_workflowno = b.n_workflowno \
and a.n_aclno = c.n_aclno \
and c.n_userno = %d \
and b.n_workflowname = 'NFM_CATALOG_WORKFLOW'",
	   NFMglobal.NFMuserno) ;

  status = SQLquery (sql_str, list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (list) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "no rows\n")) ;
	  return (NFM_S_SUCCESS) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}







