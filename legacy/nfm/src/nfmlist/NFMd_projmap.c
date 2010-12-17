#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_project_acl_mapping( project, search, sort, 
				     syn_list, data_list )

char   *project;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_project_acl_mapping";

    _NFMdebug(( fname, "Project <%s>\n", project ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( project ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_ACL_MAP, "%s", " ");
        return ( NFM_E_DISPLAY_PROJ_ACL_MAP );
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

    /*  Build synonym buffer and SELECT statement */

    strcpy( str, "Catalog\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
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
"SELECT nfmcatalogs.n_catalogname, nfmworkflow.n_workflowname,nfmacls.n_aclname FROM nfmcatalogaclmap, nfmcatalogs, nfmworkflow,nfmacls,  nfmprojects,  nfmprojectaclmap WHERE (nfmcatalogs.n_catalogno =nfmcatalogaclmap.n_catalogno) AND (nfmacls.n_aclno =nfmcatalogaclmap.n_aclno) AND (nfmprojects.n_projectname = '%s')",
project );
    strcat( select_str, " AND (nfmprojectaclmap.n_projectno = nfmprojects.n_projectno) AND (nfmcatalogaclmap.n_mapno = nfmprojectaclmap.n_mapno) AND (nfmworkflow.n_workflowno = nfmacls.n_workflowno)");

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
        strcat( select_str, " ORDER BY nfmcatalogs.n_catalogname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_ACL_MAP, "%s", project);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJ_ACL_MAP );
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

long NFMdisplay_project_sa_mapping( project, search, sort, 
				     syn_list, data_list )
char   *project;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_project_sa_mapping";

    _NFMdebug(( fname, "Project <%s>\n", project ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( project ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_SA_MAP, "%s", " " );
        return ( NFM_E_DISPLAY_PROJ_SA_MAP );
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

    strcpy( str, "Catalog\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
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
"SELECT nfmcatalogs.n_catalogname, nfmstoragearea.n_saname FROM nfmcatalogsamap,nfmcatalogs,nfmstoragearea,nfmprojects,nfmprojectsamap WHERE (nfmcatalogs.n_catalogno = nfmcatalogsamap.n_catalogno) AND (nfmstoragearea.n_sano = nfmcatalogsamap.n_sano) AND (nfmprojects.n_projectname= '%s') AND (nfmprojectsamap.n_projectno = nfmprojects.n_projectno) AND (nfmcatalogsamap.n_mapno =nfmprojectsamap.n_mapno)", project);
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
        strcat( select_str, " ORDER BY nfmcatalogs.n_catalogname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_SA_MAP, "%s", project );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJ_SA_MAP );
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

