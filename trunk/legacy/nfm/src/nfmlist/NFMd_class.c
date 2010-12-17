#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_classes( wf_name, search, sort, type, syn_list, data_list )

char   *wf_name;
char   *search;
char   *sort;
int    type;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   NFMdisplay_classes_short();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_classes";

    _NFMdebug(( fname, "WF Name   <%s>\n", wf_name ));
    _NFMdebug(( fname, "Search    <%s>\n", search ));
    _NFMdebug(( fname, "Sort      <%s>\n", sort ));
/* The format for print changed from %s to %d for type - SSRS - 17/11/93*/
    _NFMdebug(( fname, "Type      <%d>\n", type ));

    if( strlen( wf_name ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_CLASSES, "%s", " " );
        return ( NFM_E_DISPLAY_CLASSES );
    }

    if( type == NFM_SHORT_DISPLAY )
    {
	status = NFMdisplay_classes_short( wf_name, search, sort, 
			syn_list, data_list );
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

    sprintf( str, "Class Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( select_str, "SELECT nfmclasses.n_classname FROM nfmclasses, nfmworkflow WHERE (nfmworkflow.n_workflowname = '%s') AND (nfmclasses.n_workflowno = nfmworkflow.n_workflowno)",wf_name);
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
        strcat( select_str, " ORDER BY nfmclasses.n_classname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_CLASSES, "%s", wf_name );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_CLASSES );
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

long NFMdisplay_classes_short( wf_name, search, sort, syn_list, data_list )

char   *wf_name;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   select_str[1024];

    static char *fname = "NFMdisplay_classes_short";

    _NFMdebug(( fname, "WF Name <%s>\n", wf_name ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( wf_name ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_CLASSES, "%s", " " );
        return ( NFM_E_DISPLAY_CLASSES );
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

    strcpy( select_str, "Class Number\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Class Name\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( select_str, "SELECT nfmclasses.n_classno,nfmclasses.n_classname FROM nfmclasses,nfmworkflow WHERE (nfmworkflow.n_workflowname = '%s') AND (nfmclasses.n_workflowno = nfmworkflow.n_workflowno)", wf_name);
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
        ERRload_struct (NFM,  NFM_E_DISPLAY_CLASSES, "%s", wf_name);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_CLASSES );
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
