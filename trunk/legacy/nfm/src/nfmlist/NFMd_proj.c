#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define  BUFFER_SIZE  4000

extern   int  SQLcursor[40];

long NFMdisplay_projects( search, sort, type, syn_list, data_list )

char   *search;
char   *sort;
int    type;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   NFMdisplay_projects_short();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_projects";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));
/* The format for print changed from %s to %d for type - SSRS - 17/11/93*/
    _NFMdebug(( fname, "Type   <%d>\n", type ));

    if( type == NFM_SHORT_DISPLAY )
    {
	status = NFMdisplay_projects_short(search, sort, syn_list, data_list );
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
    strcpy( str, "Project Name\1" );
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
        strcpy( str, "Number\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Manager\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Application\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Creation Date\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Pending Flag\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Archive State\1" );
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

    strcpy( select_str,"SELECT nfmprojects.n_projectname,nfmprojects.n_projectdesc,nfmprojects.n_projectnum,nfmprojects.n_projectmgr,nfmprojects.n_application,nfmprojects.n_creationdate,nfmprojects.n_pendingflag,nfmprojects.n_archivestate,nfmstates.n_statename,nfmacls.n_aclname FROM nfmprojects, nfmstates, nfmacls WHERE (nfmstates.n_stateno = nfmprojects.n_stateno) AND (nfmacls.n_aclno = nfmprojects.n_aclno) AND (nfmprojects.n_projectno > 0)");
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
        strcat( select_str, " ORDER BY nfmprojects.n_projectname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJECTS, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJECTS );
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

long NFMdisplay_projects_short( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   select_str[1024];
    static char *fname = "NFMdisplay_projects_short";

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

    strcpy( select_str, "Project Number\1");
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Project Name\1");
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( select_str, "SELECT n_projectno, n_projectname FROM nfmprojects" );
    if( strlen(search) > 0 )
    {
        strcat( select_str, " WHERE (" );
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
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJECTS, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJECTS );
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

long NFMdisplay_project_members( project, search, sort, syn_list, data_list )

char   *project;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   catalog_name[NFM_CATALOGNAME+1];
    char   **data_ptr1;
    char   **data_ptr2;
    MEMptr buffer1 = NULL;
    MEMptr buffer2 = NULL;

    static char *fname = "NFMdisplay_project_members";

    _NFMdebug(( fname, "Project <%s>\n", project ));
    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

    if( strlen(project) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", " " );
        return ( NFM_E_DISPLAY_PROJ_MEM );
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
    strcpy( str, "Item Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Item Revision\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Member Type\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list ); 
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_TYPE );
    status = MEMwrite_format( *data_list, "n_type", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str, "SELECT n_catalogno,n_itemno,n_type FROM nfmprojectcit WHERE n_projectno = (SELECT n_projectno FROM nfmprojects WHERE n_projectname = '%s')", project );
    status = SQLquery( select_str, &buffer1, BUFFER_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJ_MEM );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer1 );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)buffer1->data_ptr;

    for( i=0; i<buffer1->rows*buffer1->columns; i+=buffer1->columns )
        _NFMdebug((fname, "data[%d] <%s>\n", i, data_ptr1[i] ));


    for( i=0; i<buffer1->rows*buffer1->columns; i+=buffer1->columns )
    {
        sprintf( select_str, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", data_ptr1[i] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
             return ( NFM_E_DISPLAY_PROJ_MEM );
        }
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY);
        }

        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        data_ptr2 = (char**)buffer2->data_ptr;
        strncpy( catalog_name, data_ptr2[0], NFM_CATALOGNAME );
 	MEMclose( &buffer2 );

        sprintf( select_str, "SELECT n_itemname,n_itemrev FROM %s WHERE n_itemno = %s", catalog_name, data_ptr1[i+1] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_DISPLAY_PROJ_MEM );
	}
        else if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY);
        }

        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        data_ptr2 = (char**)buffer2->data_ptr;

 	sprintf( select_str, "%s\1%s\1%s\1%s\1", catalog_name,
		 data_ptr2[0], data_ptr2[1], data_ptr1[i+2] );
	status = MEMwrite( *data_list, select_str );
        if (status != MEM_S_SUCCESS)
        {
            _NFMdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return (NFM_E_MEM);
        }
	MEMclose( &buffer2 );   		
    }

    MEMclose( &buffer1 );

    return( NFM_S_SUCCESS );
}

long NFMdisplay_project_members_partial( project, search, sort, rows,
					 syn_list, data_list )

char   *project;
char   *search;
char   *sort;
long   rows;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    long   status;
    long   save_status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   catalog_name[NFM_CATALOGNAME+1];
    char   **data_ptr1;
    char   **data_ptr2;
    MEMptr buffer1 = NULL;
    MEMptr buffer2 = NULL;

    static char *fname = "NFMdisplay_project_members_partial";

    _NFMdebug(( fname, "Project <%s>\n", project ));
    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));
    _NFMdebug(( fname, "Rows   <%ld>\n", rows ));

/*  If rows == 0, we are just here to close the cursor and clean up
 *  the partial query.
 */
    if( rows == 0 )
    {
        status = SQLquery_cursor5( "", data_list, BUFFER_SIZE, rows );
        if( status != SQL_S_SUCCESS )
        {
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( status );
        }
	return( NFM_S_SUCCESS );
    }

    if( strlen(project) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", " " );
        return ( NFM_E_DISPLAY_PROJ_MEM );
    }

    status = NFMcheck_transaction();
    if( status == NFM_E_TRANSACTION_OFF )
    {
        ERRload_struct( NFM, NFM_S_SUCCESS, NULL, NULL );
        _NFMdebug(( fname, "%s\n", "Autocommit was turned off" ));
    }
    else
    {
        status = NFMset_autocommit_off (0);
        _NFMdebug(( fname, "Autocommit status <0x%.8x>\n", status ));
        _NFMdebug(( fname, "%s\n", "Autocommit was turned on" ));
    }

  if( !SQLcursor[5] )
  {
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
    strcpy( str, "Item Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Item Revision\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Member Type\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
  }
  else
  {
    MEMclose( syn_list );
    *syn_list = NULL;
  }

    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list ); 
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_TYPE );
    status = MEMwrite_format( *data_list, "n_type", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str, "SELECT n_catalogno,n_itemno,n_type FROM nfmprojectcit WHERE n_projectno = (SELECT n_projectno FROM nfmprojects WHERE n_projectname = '%s')", project );
    status = SQLquery_cursor5( select_str, &buffer1, BUFFER_SIZE, rows );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_PROJ_MEM );
    }
    else if( status != SQL_S_SUCCESS && status != SQL_I_NO_MORE_DATA)
    {
	MEMclose( &buffer1 );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
 
    save_status = status;

    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	if( SQLcursor[5] )
	    status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)buffer1->data_ptr;

    for( i=0; i<buffer1->rows*buffer1->columns; i+=buffer1->columns )
    {
        sprintf( select_str, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", data_ptr1[i] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
             return ( NFM_E_DISPLAY_PROJ_MEM );
        }
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
            return ( NFM_E_SQL_QUERY);
        }

        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
            return( NFM_E_MEM );
        }
        data_ptr2 = (char**)buffer2->data_ptr;
        strncpy( catalog_name, data_ptr2[0], NFM_CATALOGNAME );
 	MEMclose( &buffer2 );

        sprintf( select_str, "SELECT n_itemname,n_itemrev FROM %s WHERE n_itemno = %s", catalog_name, data_ptr1[i+1] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_DISPLAY_PROJ_MEM, "%s", project );
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
            return ( NFM_E_DISPLAY_PROJ_MEM );
	}
        else if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
            return ( NFM_E_SQL_QUERY);
        }

        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
            return( NFM_E_MEM );
        }
        data_ptr2 = (char**)buffer2->data_ptr;

 	sprintf( select_str, "%s\1%s\1%s\1%s\1", catalog_name,
		 data_ptr2[0], data_ptr2[1], data_ptr1[i+2] );
	status = MEMwrite( *data_list, select_str );
        if (status != MEM_S_SUCCESS)
        {
            _NFMdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            if( SQLcursor[5] )
                status = SQLquery_cursor5( "", data_list, MEM_SIZE, 0 );
	    return (NFM_E_MEM);
        }
	MEMclose( &buffer2 );   		
    }

    MEMclose( &buffer1 );

    if( save_status == SQL_I_NO_MORE_DATA )
	return( NFM_I_NO_MORE_BUFFERS );

    return( NFM_S_SUCCESS );
}


long NFMdisplay_where_used_project( catalog, item, rev, syn_list, data_list )

char   *catalog;
char   *item;
char   *rev;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    long   status;
    long   catalog_no;
    long   item_no;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   **data_ptr1;
    char   **data_ptr2;
    MEMptr buffer1 = NULL;
    MEMptr buffer2 = NULL;

    static char *fname = "NFMdisplay_where_used_project";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Item   <%s>\n", item ));
    _NFMdebug(( fname, "Rev    <%s>\n", rev ));

    if( (strlen(catalog) == 0) ||
	(strlen(item)    == 0) ||
	(strlen(rev)     == 0))
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_WH_USED_PROJ, "%s%s%s", " ",
			" ", " " );
        return ( NFM_E_DISPLAY_WH_USED_PROJ );
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
    strcpy( str, "Project\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Member Type\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format( *data_list, "n_projectname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list ); 
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_TYPE );
    status = MEMwrite_format( *data_list, "n_type", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str, "SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = '%s'", catalog );
    status = SQLquery( select_str, &buffer1, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer1 );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    data_ptr1 = (char**)buffer1->data_ptr;
    catalog_no = atol( data_ptr1[0] );
    MEMclose( &buffer1 );

    sprintf( select_str, "SELECT n_itemno FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", catalog, item, rev );
    status = SQLquery( select_str, &buffer1, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &buffer1 );
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_WH_USED_PROJ, "%s%s%s", 
			catalog, item, rev );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_WH_USED_PROJ );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer1 );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    data_ptr1 = (char**)buffer1->data_ptr;
    item_no = atol( data_ptr1[0] );
    MEMclose( &buffer1 );

    sprintf( select_str, "SELECT n_projectno,n_type FROM nfmprojectcit WHERE n_catalogno= %d AND n_itemno = %d", catalog_no, item_no );
    status = SQLquery( select_str, &buffer1, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &buffer1 );
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_WH_USED_PROJ, "%s%s%s", 
			catalog, item, rev );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_WH_USED_PROJ );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer1 );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    data_ptr1 = (char**)buffer1->data_ptr;

    for( i=0; i<buffer1->rows*buffer1->columns; i+=buffer1->columns )
    {
        sprintf( select_str, "SELECT n_projectname FROM nfmprojects WHERE n_projectno = %s", data_ptr1[i] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY);
        }
        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        data_ptr2 = (char**)buffer2->data_ptr;

 	sprintf( select_str, "%s\1%s\1", data_ptr2[0], data_ptr1[i+1] );
	status = MEMwrite( *data_list, select_str );
        if (status != MEM_S_SUCCESS)
        {
            _NFMdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return (NFM_E_MEM);
        }
	MEMclose( &buffer2 );   		
    }

    MEMclose( &buffer1 );

    return( NFM_S_SUCCESS );
}
