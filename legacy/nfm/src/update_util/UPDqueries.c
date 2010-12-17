#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "DEBUG.h"
#include "NFMapi.h"

  extern long silent_mode ;

#define TRUE  1
#define FALSE 0

long NFMdefault_queries ()

{
static char *fname = "NFMdefault_queries";
long   status;
int    ADD_IT = FALSE;
struct NFMquery_info query_struct;
MEMptr sql_buffer = NULL ;

_NFMdebug ((fname, "ENTER\n"));

if (! silent_mode) fprintf (stderr, "Default Queries ...\n");

status = SQLquery 
         ("SELECT * from nfmreports where n_reportname = \'Checked_in\'",
          &sql_buffer, MEM_SIZE);

if (status == SQL_I_NO_ROWS_FOUND)
    ADD_IT = TRUE;

MEMclose (&sql_buffer);

if (ADD_IT)
    {
    status = NFMwrite_query_struct (&query_struct, "*", "dummycat a",
                                    "(a.n_status = 'I')", "", "");
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMwrite_query_struct : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    status = _NFMdefine_query ("Checked_in", "All checked in items",
                               NFM_WHERE_CLAUSE, "NFM", "PUBLIC", query_struct);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMdefine_query : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    NFMfree_query_struct (&query_struct);
    }

ADD_IT = FALSE;
status = SQLquery 
         ("SELECT * from nfmreports where n_reportname = \'Checked_out\'",
          &sql_buffer, MEM_SIZE);

if (status == SQL_I_NO_ROWS_FOUND)
    ADD_IT = TRUE;

MEMclose (&sql_buffer);

if (ADD_IT)
    {
    status = NFMwrite_query_struct (&query_struct, "*", "dummycat a",
                                    "(a.n_status = 'O')", "", "");
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMwrite_query_struct : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    status = _NFMdefine_query ("Checked_out", "All checked out items",
                               NFM_WHERE_CLAUSE, "NFM", "PUBLIC", query_struct);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMdefine_query : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    NFMfree_query_struct (&query_struct);
    }

ADD_IT = FALSE;
status = SQLquery 
         ("SELECT * from nfmreports where n_reportname = \'Sets_only\'",
          &sql_buffer, MEM_SIZE);

if (status == SQL_I_NO_ROWS_FOUND)
    ADD_IT = TRUE;

MEMclose (&sql_buffer);

if (ADD_IT)
    {
    status = NFMwrite_query_struct (&query_struct, "*", "dummycat a",
                                    "(a.n_setindicator = 'Y')", "", "");
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMwrite_query_struct : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    status = _NFMdefine_query ("Sets_only", "Only set items",
                               NFM_WHERE_CLAUSE, "NFM", "PUBLIC", query_struct);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMdefine_query : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    NFMfree_query_struct (&query_struct);
    }

ADD_IT = FALSE;
status = SQLquery 
         ("SELECT * from nfmreports where n_reportname = \'No_set\'",
          &sql_buffer, MEM_SIZE);

if (status == SQL_I_NO_ROWS_FOUND)
    ADD_IT = TRUE;

MEMclose (&sql_buffer);

if (ADD_IT)
    {
    status = NFMwrite_query_struct (&query_struct, "*", "dummycat a",
                                    "(a.n_setindicator IS NULL)", "", "");
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMwrite_query_struct : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    status = _NFMdefine_query ("No_set", "Only non-set items",
                               NFM_WHERE_CLAUSE, "NFM", "PUBLIC", query_struct);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMdefine_query : status =  <0x%.8x>\n", status));
        NFMfree_query_struct (&query_struct);
        return (status);
        }

    NFMfree_query_struct (&query_struct);
    }

_NFMdebug ((fname, "SUCCESSFUL\n"));
return (NFM_S_SUCCESS);
}
