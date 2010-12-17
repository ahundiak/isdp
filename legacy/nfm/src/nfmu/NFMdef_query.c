#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"
#include "NFMsysinc.h"

/* 
 Doc: NFMdefine_query
 
 Abstract:
     This function will define a query for I/NFM. A report file is created and
     an entry is made to nfmreports.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
 */
 
long NFMdefine_query (query_name, query_desc, query_type, application, 
                      user_name, query_info)
    char  *query_name;               /* I - Name of query bring defined. */
    char  *query_desc;               /* I - Description of the query. */
    short query_type;                /* I - Type of query being defined.
                                        NFM_WHERE_CLAUSE, NFM_ORDER_BY_CLAUSE,
                                        NFM_SIMPLE_QUERY, or NFM_EXPERT_QUERY */
    char  *application;              /* I - Application defining the query. */
    char  *user_name;                /* I - User defining the query. */
    struct NFMquery_info query_info; /* I - A NFMquery_info structure with the
                                            info needed to define the query. */
{
    long   status;
    static  char *fname = "NFMdefine_query";

    _NFMdebug ((fname, "Enter.\n"));
    status = _NFMdefine_query (query_name, query_desc, query_type, application, 
                               user_name, query_info);

    _NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
    return (status);
} 
/* 
 Doc: NFMdefine_query
 
 Abstract:
     This function will define a query for I/NFM. A report file is created and
     an entry is made to nfmreports.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
 */
 
long NFMdefine_ftr_query (query_name, query_desc, query_type, application, 
                      user_name, query_info)
    char  *query_name;               /* I - Name of query bring defined. */
    char  *query_desc;               /* I - Description of the query. */
    short query_type;                /* I - Type of query being defined.
                                        NFM_WHERE_CLAUSE, NFM_ORDER_BY_CLAUSE,
                                        NFM_SIMPLE_QUERY, NFM_EXPERT_QUERY or
					NFM_FTR_QUERY  or NFM_ADV_QUERY */
    char  *application;              /* I - Application defining the query. */
    char  *user_name;                /* I - User defining the query. */
    struct NFMquery_ftr_info query_info; /* I - A NFMquery_info structure 
					    with the info needed to define 
					    the query. */
{
    long   status;
    static  char *fname = "NFMdefine_ftr_query";

    _NFMdebug ((fname, "Enter.\n"));
    status = _NFMdefine_ftr_query (query_name, query_desc, query_type, 
		application, user_name, query_info);

    _NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
    return (status);
} 
