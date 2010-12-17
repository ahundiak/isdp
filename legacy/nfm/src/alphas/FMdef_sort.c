#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <tools.h>
#include <stdarg.h>
#include <sys/types.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "DEBUG.h"

extern  char  WORKING_user[20];

long define_sort ()

{
long   status;
int    i;
char   rep_file_name[50];
char   rep_desc[50];
char   *sort_string;
MEMptr out_buffer = NULL;
MEMptr attr_list = NULL;
struct NFMquery_info query_struct;
static char *fname = "NFAdefine_sort";

    SCdisplay_msg ("Working..");    

/* choose attributes to select during query */

    status = NFMRquery_table_definition (NFMuser_id, "catalog", NFMcatalog,
                                         &attr_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        return (status);
        }

/* KT - 2/18/93 - Call this function to filter out n_aclno, n_stateno, 
                  and n_prevstateno. These attributes are not in the select 
                  list for displaying items, so they cannot be used in the 
                  ORDER BY clause.
*/

   status = _NFMfilter_sort_buffer (&attr_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);

/****************************************************/

/* get sort string */
    status = NFAdefine_sort (&sort_string, attr_list);
    _NFIdebug ((fname, "sort string is <%s>\n", sort_string));
    if (status != NFI_S_SUCCESS)
        return (status);

    _NFIdebug(( fname, "sort_string : <%s>\n", sort_string));

/*********************************************************/

/* get server side report file name */
    status = NFAfind_report_name ("Sort Criteria", rep_file_name, rep_desc);
    if (status != NFI_S_SUCCESS)
        return (status);

/****************************************************/

/* Build report buffers */

    NFMwrite_query_struct (&query_struct, "", "", "", sort_string, "");

    _NFIdebug(( fname, "sort_string : <%s>\n", sort_string));
    free (sort_string);


    for (i =0; i < strlen (rep_file_name); ++i)
     {
       if (isspace (rep_file_name[i]))
          rep_file_name[i] = '_';
     }
    _NFIdebug((fname, "sort name is <%s>\n", rep_file_name));
    strcpy( NFMsort_name, rep_file_name );
    _NFIdebug(( fname, "Sort name <%s>\n", NFMsort_name));
    _NFIdebug(( fname, "select_clause <%s>\n", query_struct.select_clause));
    _NFIdebug(( fname, "from_clause <%s>\n", query_struct.from_clause));
    _NFIdebug(( fname, "where_clause <%s>\n", query_struct.where_clause));
    _NFIdebug(( fname, "order_by_clause <%s>\n",query_struct.order_by_clause));
    _NFIdebug(( fname, "prompts <%s>\n", query_struct.prompts));

    SCdisplay_msg ("Working..");
    status = NFMRdefine_query (rep_file_name, rep_desc, NFM_ORDER_BY_CLAUSE, 
		"NFM", WORKING_user, query_struct);

    _NFIdebug(( fname, "Return from NFMRdefine_query -> 0x%.8x\n", status));
    NFMfree_query_struct (&query_struct);

    MEMclose (&out_buffer);
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}
