#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "NFMdef.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"

long ADMtables_list(user_id,list)
         long       user_id;
    	 MEMptr     *list;
{
	long   status = 0, i;
	char    qry_str[5*STR_SIZE];
	char   n_tablename[SIZE];
	char   **data;
	static char *fname = "ADMtables_list";
	MEMptr attr_list = MEMNULL;
	long   return_status = NFM_S_SUCCESS;
	long   length, size;
        strcpy(n_tablename, "n_tablename");
   
     _NFMdebug((fname, "Enter\n"));
/*  check if the list pointer is NULL */

     if (list == MEMPTRNULL)
     {
	_NFMdebug((fname, "MEMptr list address is <%d>\n", list));
	
	status = ERRload_struct(NFM, NFM_E_NULL_OUTPUT_MEMPTR, "%s",
	"Output Buffer ptr");
	
        if(status!=ERR_S_SUCCESS)
          _NFMdebug((fname, "ERRload_struct status= <0x%.8x>\n", status));
          return(NFM_E_NULL_OUTPUT_MEMPTR);
      }
    
/*  make sure that the list is NULL as we will fill new info here */
    if (*list != MEMNULL)
    {
      
      _NFMdebug((fname, "List is non empty List=<0x%.8x>\n", *list));
      _NFMdebug((fname,  "MEMclose on List =<0x%.8x>\n", *list));
      MEMclose(list);
     }

     size = strlen(qry_str);
/*   select * from nfmtables  */

     sprintf(qry_str,  "SELECT nfmtables.%s",  n_tablename);
     strcat(qry_str,  " FROM nfmtables");
   
   /*  sprintf(qry_str, "SELECT n_tablename FROM nfmtables WHERE \
             n_tabletype = 'catalog' or n_tabletype = 'f_catalog'");*?

     _NFMdebug((fname, "nfmtables\n"));

     
/* Call the SQL functions */
 if((status=SQLquery (qry_str, list,  2*MEM_SIZE))!=SQL_S_SUCCESS)
   {
     _NFMdebug((fname, "SQL query failed status <0x%.8x>\n", status));
     MEMclose(list);
     if(status == SQL_I_NO_ROWS_FOUND)
     {
       status = ERRload_struct(NFM, NFM_E_NO_TABLES_FOUND, "%s","ADMcatalog_list");
       if(status!=ERR_S_SUCCESS)
       _NFMdebug((fname, "NFM_E_NO_TABLES_FOUND <0x%.8x>\n", status));
       return(NFM_E_NO_CATALOGS);
     }
       else
       {
         if(status!=ERR_S_SUCCESS)
         _NFMdebug((fname, "ERRload_struct status= <0x%.8x>\n", status));
          return(NFM_E_SQL_QUERY);
       }
   }

   _NFMdebug((fname,  "Exit >> SUCCESSFul\n"));
   return(NFM_S_SUCCESS);
}
