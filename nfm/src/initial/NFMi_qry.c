#include "machine.h"
#include "INIT.h"
#include "NFMapi.h"

long NFMdefault_queries ()

{
static char *fname = "NFMdefault_queries";
long   status;
struct NFMquery_info query_struct;

_NFMdebug ((fname, "ENTER\n"));

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

_NFMdebug ((fname, "SUCCESSFUL\n"));
return (NFM_S_SUCCESS);
}


