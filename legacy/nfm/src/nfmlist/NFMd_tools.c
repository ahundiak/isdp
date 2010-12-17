#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

/*  This routine gets the <n_synonym> for the input <n_name> from the
 *  nfmsysattributes table.
 */
long  NFMd_get_name_synonym( name, table, ret_syn )
    char *name;
    char *table;
    char *ret_syn;
{
    long   status;
    char   select_str[512];
    char   **data_ptr;
    MEMptr buffer = NULL;

    static char *fname = "NFMd_get_name_synonym";

    _NFMdebug(( fname, "In Name <%s>\n", name ));
    _NFMdebug(( fname, "Table   <%s>\n", table ));

    sprintf( select_str, "SELECT n_synonym FROM nfmsysattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_name = '%s'", table, name );
    status = SQLquery( select_str, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "Query <0x%.8x>\n", status ));
        MEMclose( &buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
        return( NFM_E_SQL_QUERY );
    }

    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    data_ptr = (char**)buffer->data_ptr;
    strcpy( ret_syn, data_ptr[0] );
    MEMclose( &buffer );
    
    _NFMdebug(( fname, "Returning synonym <%s>\n", ret_syn ));
    
    return( NFM_S_SUCCESS );
}

/*  This routine gets the <n_synonym> for the input <n_name> from the
 *  nfmattributes table 
 */
long  NFMd_get_attr_name_synonym( name, table, ret_syn )
    char *name;
    char *table;
    char *ret_syn;
{
    long   status;
    char   select_str[512];
    char   **data_ptr;
    MEMptr buffer = NULL;

    static char *fname = "NFMd_get_attr_name_synonym";

    _NFMdebug(( fname, "In Name <%s>\n", name ));
    _NFMdebug(( fname, "Table   <%s>\n", table ));

    sprintf( select_str, "SELECT n_synonym FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_name = '%s'", table, name );
    status = SQLquery( select_str, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "Query <0x%.8x>\n", status ));
        MEMclose( &buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
        return( NFM_E_SQL_QUERY );
    }

    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    data_ptr = (char**)buffer->data_ptr;
    strcpy( ret_syn, data_ptr[0] );
    MEMclose( &buffer );
    
    _NFMdebug(( fname, "Returning synonym <%s>\n", ret_syn ));
    
    return( NFM_S_SUCCESS );
}
