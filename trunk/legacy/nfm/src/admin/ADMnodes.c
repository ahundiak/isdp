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

long ADMnode_list(user_id,list)
     long       user_id;
	 MEMptr     *list;
{
	long   status = 0, i;
	char    qry_str[5*STR_SIZE], return_str[2*STR_SIZE];
	char   **data;
	MEMptr attr_list = MEMNULL;
	long   return_status = NFM_S_SUCCESS;
	long   length, size;
   	static char *fname = "ADMnode_list";

     _NFMdebug((fname, "Enter\n"));
/*  check if the list pointer is NULL */

     if (list == MEMPTRNULL)
     {
	_NFMdebug((fname, "MEMptr list address is <%d>\n", list));
	
	status = ERRload_struct(NFM, NFM_E_NULL_OUTPUT_MEMPTR, "%s", "Output Buffer ptr");
	
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
/*   select * from nfmstoragearea and nfmnodes  */

     sprintf(qry_str,  "SELECT DISTINCT n_nodename, n_nodeno FROM  nfmnodes");

     _NFMdebug((fname, "nfmnodes\n"));

     
/* Call the SQL functions */
 if((status=SQLquery (qry_str, list,  MEM_SIZE))!=SQL_S_SUCCESS)
   {
     _NFMdebug((fname, "SQL query failed status <0x%.8x>\n", status));
     MEMclose(list);
     if(status == SQL_I_NO_ROWS_FOUND)
     {
       status = ERRload_struct(NFM, NFM_E_DISPLAY_NODES, "", NULL);
       if(status!=ERR_S_SUCCESS)
       _NFMdebug((fname, "NFM_E_DISPLAY_NODES <0x%.8x>\n", status));
       return(NFM_E_DISPLAY_NODES);
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
