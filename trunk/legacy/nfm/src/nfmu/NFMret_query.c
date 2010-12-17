#include "machine.h"
#include <stdio.h> 
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"

long NFMretrieve_query (query_name, query_info)
   char     *query_name;             /* I - Query name. */
   struct NFMquery_info *query_info; /* O - Structure pointer of returned 
                                            query info. */

{
long    status;
static  char *fname = "NFMretrieve_query";

_NFMdebug ((fname, "Enter.\n"));
status = _NFMretrieve_query (query_name, query_info);

_NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
return (status);
}


long NFMretrieve_query_info (query_name, query_type, application, appl_type,
                             query_desc, owner, query_info)
   char     *query_name;             /* I - Query name. */
   char     *query_type;             /* I - Query type: W-search, O-order_by. */
   char     *application;            /* I - Application who defined query. */
   char     *appl_type;              /* I - Appl. type assigned to query. */
   char     *query_desc;             /* O - Query description. */
   char     *owner;                  /* O - Owner of the query. */
   struct NFMquery_info *query_info; /* O - Structure pointer of returned 
                                            query info. */
{
long    status;
static  char *fname = "NFMretrieve_query_info";

_NFMdebug ((fname, "Enter.\n"));
status = _NFMretrieve_query_info (query_name, query_type, application, 
                                  appl_type, query_desc, owner, query_info);

_NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
return (status);
}

long NFMretrieve_ftr_query (query_name, query_type, query_info)
   char     *query_name;             /* I - Query name. */
   char     *query_type;	     /* I - Query type. */
   struct NFMquery_ftr_info *query_info; /* O - Structure pointer of returned 
                                            query info. */

{
long    status;
static  char *fname = "NFMretrieve_ftr_query";

_NFMdebug ((fname, "Enter.\n"));
status = _NFMretrieve_ftr_query (query_name, query_type, query_info);

_NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
return (status);
}


long NFMretrieve_ftr_query_info (query_name, query_type, application, 
		appl_type, query_desc, owner, query_info)
   char     *query_name;             /* I - Query name. */
   char     *query_type;             /* I - Query type: W-search, O-order_by. */
   char     *application;            /* I - Application who defined query. */
   char     *appl_type;              /* I - Appl. type assigned to query. */
   char     *query_desc;             /* O - Query description. */
   char     *owner;                  /* O - Owner of the query. */
   struct NFMquery_ftr_info *query_info; /* O - Structure pointer of returned 
                                            query info. */
{
long    status;
static  char *fname = "NFMretrieve_ftr_query_info";

_NFMdebug ((fname, "Enter.\n"));
status = _NFMretrieve_ftr_query_info (query_name, query_type, application, 
                                  appl_type, query_desc, owner, query_info);

_NFMdebug ((fname, "Exit: <0x%.8x>.\n", status));
return (status);
}
