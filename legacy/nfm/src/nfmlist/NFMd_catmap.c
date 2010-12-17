#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_catalog_acl_mapping( catalog, search, sort,syn_list, data_list)

char   *catalog;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_catalog_acl_mapping";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));
     
    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_CAT_ACL_MAP, "%s", " ");
        return ( NFM_E_DISPLAY_CAT_ACL_MAP );
    }

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Workflow\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "ACL\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str,
"SELECT nfmworkflow.n_workflowname,  nfmacls.n_aclname FROM nfmcatalogaclmap, nfmworkflow, nfmacls, nfmcatalogs WHERE (nfmacls.n_aclno= nfmcatalogaclmap.n_aclno) AND (nfmcatalogs.n_catalogname = '%s') AND (nfmcatalogaclmap.n_catalogno = nfmcatalogs.n_catalogno) AND (nfmworkflow.n_workflowno = nfmacls.n_workflowno)", catalog );

    if( strlen(search) > 0 )
    {
        strcat( select_str, " AND (" );
        strcat( select_str, search );
        strcat( select_str, ")" );
    }
    if( strlen(sort) > 0 )
    {
        strcat( select_str, " ORDER BY " );
        strcat( select_str, sort );
    }
    else
        strcat( select_str, " ORDER BY nfmworkflow.n_workflowname,nfmacls.n_aclname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_CAT_ACL_MAP, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_CAT_ACL_MAP );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    return( NFM_S_SUCCESS );
}

long NFMdisplay_catalog_sa_mapping( catalog, search, sort,syn_list, data_list )

char   *catalog;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_catalog_sa_mapping";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_CAT_SA_MAP, "%s", " ");
        return ( NFM_E_DISPLAY_CAT_SA_MAP );
    }

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Storage Area\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str,
"SELECT nfmstoragearea.n_saname FROM nfmcatalogsamap,  nfmstoragearea, nfmcatalogs WHERE (nfmstoragearea.n_sano =nfmcatalogsamap.n_sano) AND (nfmcatalogs.n_catalogname = '%s') AND (nfmcatalogsamap.n_catalogno=nfmcatalogs.n_catalogno)", catalog );

    if( strlen(search) > 0 )
    {
        strcat( select_str, " AND (" );
        strcat( select_str, search );
        strcat( select_str, ")" );
    }
    if( strlen(sort) > 0 )
    {
        strcat( select_str, " ORDER BY " );
        strcat( select_str, sort );
    }
    else
        strcat( select_str, " ORDER BY nfmstoragearea.n_saname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_CAT_SA_MAP, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_CAT_SA_MAP );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    return( NFM_S_SUCCESS );
}

