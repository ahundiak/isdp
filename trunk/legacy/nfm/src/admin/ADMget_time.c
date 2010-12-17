#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "ERR.h"

extern struct NFMglobal_st NFMglobal;

extern char NFMprint_file[] ;

long ADMadd_time_type (next_row_no, date_type)
long  *next_row_no;
char  *date_type ;
{
    long   status;
    int    i, j, z , k;
	int    tot_data;
	int    count;
	int    pos;
	char   sql_str[512];
	char   qry_str[512];
	char   **data;
    MEMptr out_list = NULL;

	static char *fname = "ADMget_time_type";


    _NFMdebug ((fname, "ENTER\n"));

    
  sprintf(sql_str, "SELECT n_rowno, n_description \
           FROM nfmsyscat WHERE \
           n_infotype = 'TIME_FORMAT'");

  status = SQLquery (sql_str, &out_list, 2*MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && ((status) != SQL_I_NO_ROWS_FOUND))
   {
     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMdebug ((fname,"SQL_E_QUERY : status = <0x%.8x>\n",status));
     return (NFM_E_SQL_QUERY);
   }

    if (status == SQL_I_NO_ROWS_FOUND)
	{	
	    MEMclose (&out_list) ;
    
	    status = NFMget_serial_slot(NFMglobal.NFMuserid, "nfmsyscat", "n_rowno",next_row_no);
 	
  	  if (status != NFM_S_SUCCESS)
   	  {
    	   return (NFM_E_FAILURE);
     	}
	
 	   sprintf(sql_str, "INSERT INTO nfmsyscat \
  	          (n_rowno, n_infotype, n_description) VALUES (%d,\
   	          'TIME_FORMAT', '%s')", *next_row_no, "24HR") ;
    	
	status = SQLexec_imm (sql_str) ;
	if (status != SQL_S_SUCCESS)
	{	
 	 if (status == SQL_E_DUPLICATE_VALUE)
  	  {
   	   _NFMdebug ((fname, "Duplicate ROW NO\n")) ;
       return (status) ;
 	   }
 	   _NFMdebug ((fname, "SQL exec imm failed : status = <0x%.8x>\n",
  	 status)) ;
	  return (NFM_E_SQL_STMT) ;
	}
	strcpy (date_type, "24HR") ;
} /* if no no rows */
	else if (out_list->rows == 1)
{
	status = MEMbuild_array (out_list) ;
    data = (char **) out_list -> data_ptr ;
    strcpy (date_type, data [1]) ;
	*next_row_no = (long) atol (data [0]) ;
	status = MEMclose (&out_list) ;
}
/*
	else if (out_list->rows > 1)
{*/
	/* delete all entries where n_infotype = 'DATE_FORMAT' */
	/* insert as above */
/*}*/
_NFMdebug ((fname, "SUCCESSFUL\n")) ;

return (NFM_S_SUCCESS) ;
  }
