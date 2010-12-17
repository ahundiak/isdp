#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <tools.h>
#include <stdarg.h>
#include <sys/types.h>
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

extern  char WORKING_user[20];

long define_search ()

{
long   status;
int    i;
char   rep_file_name[50];
char   rep_desc[50];
char   str_format[20];
char   f_cat[NFM_CATALOGNAME+1];
char   *search_string;
char   *from_string;
MEMptr out_buffer = NULL;
MEMptr attr_list = NULL;
MEMptr f_attr_list = NULL;
struct NFMquery_info query_struct;
static char *fname = "NFAdefine_search";

    SCdisplay_msg ("Working..");    

/* choose attributes to select during query from the catalog and f_catalog
 * tables. */

    status = NFMRquery_table_definition (NFMuser_id, "catalog", NFMcatalog,
                                         &attr_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &attr_list );
	MEMclose( &f_attr_list );
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    sprintf( f_cat, "f_%s", NFMcatalog );
    status = NFMRquery_table_definition (NFMuser_id, "f_catalog", f_cat,
                                         &f_attr_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
	MEMclose (&f_attr_list);
        return (status);
        }

    status = MEMbuild_array (f_attr_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &attr_list );
	MEMclose( &f_attr_list );
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

/*********************************************************/

/* get search string */
    status = NFAdefine_search (&search_string, &from_string, 
				attr_list, f_attr_list);
    if (status != NFI_S_SUCCESS)
    {
	MEMclose( &attr_list );
	MEMclose( &f_attr_list );
        return (status);
    }

    MEMclose( &attr_list );
    MEMclose( &f_attr_list );

    _NFIdebug(( fname, "search_string : <%s>\n", search_string));
    _NFIdebug(( fname, "from_string : <%s>\n", from_string));

/*********************************************************/

/* get server side report file name */

    status = NFAfind_report_name ("Search Criteria", rep_file_name, rep_desc);
    if (status != NFI_S_SUCCESS)
        return (status);

/****************************************************/

/* Build report buffers */
    NFMwrite_query_struct (&query_struct, "", from_string, search_string, 
			    "", "");

   _NFIdebug(( fname, "search_string : <%s>\n", search_string));
    
    free (search_string);

    for (i =0; i < strlen (rep_file_name); ++i)
     {
       if (isspace (rep_file_name[i]))
          rep_file_name[i] = '_';
     }
    _NFIdebug((fname, "search name is <%s>\n", rep_file_name));

    strcpy( NFMsearch_name, rep_file_name );
    _NFIdebug(( fname, "Search name <%s>\n", NFMsearch_name));
    _NFIdebug(( fname, "select_clause <%s>\n", query_struct.select_clause));
    _NFIdebug(( fname, "from_clause <%s>\n", query_struct.from_clause));
    _NFIdebug(( fname, "where_clause <%s>\n", query_struct.where_clause));
    _NFIdebug(( fname, "order_by_clause <%s>\n",query_struct.order_by_clause));
    _NFIdebug(( fname, "prompts <%s>\n", query_struct.prompts));

    SCdisplay_msg ("Working..");
    status = NFMRdefine_query (rep_file_name, rep_desc, NFM_WHERE_CLAUSE, 
		"NFM", WORKING_user, query_struct);

    _NFIdebug(( fname, "Return from NFMRdefine_query -> 0x%.8x\n", status));

    if (status != NFM_S_SUCCESS)
        {
	strcpy( NFMsearch_name, "" );
        return (status);
        }

    strcpy (NFMsearch_name, rep_file_name);
    NFMfree_query_struct (&query_struct);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


