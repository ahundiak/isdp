#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_workflows( search, sort, type, syn_list, data_list )

char   *search;
char   *sort;
int    type;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   NFMdisplay_workflows_short();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_workflows";

    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));
 /* The format for print changed from %s to %d for type - SSRS -17/11/93 */
    _NFMdebug(( fname, "Type    <%d>\n", type ));

    if( type == NFM_SHORT_DISPLAY )
    {
	status = NFMdisplay_workflows_short( search, sort, syn_list,data_list);
	return( status );
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

    strcpy( str, "Workflow Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Description\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Type\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "State\1" );
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

    strcpy( select_str, "SELECT DISTINCT nfmworkflow.n_workflowname,nfmworkflow.n_workflowdesc,nfmworkflow.n_workflowtype, nfmstates.n_statename, nfmacls.n_aclname FROM nfmworkflow, nfmstates,nfmacls WHERE (nfmstates.n_stateno =nfmworkflow.n_stateno) AND (nfmacls.n_aclno = nfmworkflow.n_aclno) AND (nfmworkflow.n_workflowno > 0)" );
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
        strcat( select_str, " ORDER BY nfmworkflow.n_workflowname" );
    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_WORKFLOWS, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_WORKFLOWS );
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

long NFMdisplay_workflows_short( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   select_str[1024];

    static char *fname = "NFMdisplay_workflows_short";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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

    strcpy( select_str, "Workflow Number\1");
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Workflow Name\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str,"SELECT DISTINCT nfmworkflow.n_workflowno,nfmworkflow.n_workflowname FROM nfmworkflow,nfmacls,nfmstates WHERE (nfmstates.n_stateno = nfmworkflow.n_stateno) AND (nfmworkflow.n_aclno = nfmacls.n_aclno) AND (nfmworkflow.n_workflowno > 0)");
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

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_WORKFLOWS, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_WORKFLOWS );
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
