#include "machine.h"
#include "CMDTOOLS.h"
#include "UTIerrordef.h"

extern char   str[500];

NFMfind_items_on_tape( list )
    it_list *list;
{
    long   status;

    int    i;
    int    j;
    int    k;
    int    cnt;

    it_list savedlist;
    it_list link;
    it_list listend;

    char    catalog[40];
    char    item[60];
    char    rev[60];

    char    **sa_data;
    char    **ar_data;
    char    **sv_data;

    MEMptr  sa_buffer = NULL;
    MEMptr  ar_buffer = NULL;
    MEMptr  sv_buffer = NULL;
 
    static char *fname = "NFMfind_items_on_tape";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    savedlist = listend = NULL;
    cnt = 0;
  
    strcpy( str, "SELECT n_archiveno FROM nfmarchives" );
    status = SQLquery( str, &sa_buffer, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose (&sa_buffer);
	ERRload_struct( UTI, UTI_E_NO_ITEMS_ON_TAPE, NULL, NULL );	
        return( UTI_E_NO_ITEMS_ON_TAPE );
    }
    MEMclose( &sa_buffer );
    sa_buffer = NULL;
  
    strcpy( str, "SELECT n_sano, n_saname FROM nfmstoragearea WHERE n_devicetype IN ('UT','CT','MT' )" );
    status = SQLquery( str, &sa_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose (&sa_buffer);
	ERRload_struct( UTI, UTI_E_NO_TAPE_DEVICES, NULL, NULL );	
        return( UTI_E_NO_TAPE_DEVICES );
    }

    MEMbuild_array (sa_buffer);
    sa_data = (char **) sa_buffer->data_ptr;

    for( i=0; i<(sa_buffer->rows)*(sa_buffer->columns); i+=sa_buffer->columns )
    {
	sprintf( str, "SELECT n_archiveno, n_label, n_saveset, n_archivedate FROM nfmarchives WHERE n_sano = %s", sa_data[i] );
        status = SQLquery( str, &ar_buffer, MEM_SIZE);
        if( status != SQL_S_SUCCESS )
        {
            _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
            MEMclose (&ar_buffer);
	    ar_buffer = NULL;
	    ERRreset_struct();
	    continue;
        }
   
        MEMbuild_array (ar_buffer);
        ar_data = (char **) ar_buffer->data_ptr;

        for( j=0; j<(ar_buffer->rows)*(ar_buffer->columns);
		  j+=ar_buffer->columns )
        {
	    sprintf( str, "SELECT n_catalogno, n_itemno, n_itemstate FROM nfmsavesets where n_archiveno = %s", ar_data[j] );
            status = SQLquery( str, &sv_buffer, MEM_SIZE);
            if( status != SQL_S_SUCCESS )
            {
                _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
                ERRreset_struct();
                continue;
            }

            MEMbuild_array (sv_buffer);
            sv_data = (char **) sv_buffer->data_ptr;

  	    for( k=0; k<(sv_buffer->rows)*(sv_buffer->columns); 
		      k+=sv_buffer->columns )
  	    {
  	        status = NFMmap_saveset_numbers( sv_data[k], sv_data[k+1],
				 catalog, item, rev);
	        if( status != NFM_S_SUCCESS )
	        {
	  	    MEMclose( &sa_buffer );
		    MEMclose( &ar_buffer );
		    MEMclose( &sv_buffer );
	  	    return( status );
	        }
		++cnt;
	        /* Add another link to the list */
	        link = (it_list)malloc( sizeof( struct items_on_tape ) );
                strcpy( link->catalog_name, catalog );
                strcpy( link->item_name, item );
	        strcpy( link->revision, rev );
	        strcpy( link->storage_area, sa_data[i+1] );
	        strcpy( link->label, ar_data[j+1] );
	        strcpy( link->saveset, ar_data[j+2] );
   	        strcpy( link->archive_date, ar_data[j+3] );
	        strcpy( link->archive_state, sv_data[k+2] );
                link->next = NULL;

                if( savedlist == NULL )
                    savedlist = listend = link; /* First link */
                else
                {
                    listend->next = link;
                    listend = link;
                }
  	    }
	    MEMclose( &sv_buffer );
	    sv_buffer = NULL;
        }
	MEMclose( &ar_buffer );
	ar_buffer = NULL;
    }
    MEMclose( &sa_buffer );

    if( cnt == 0 )
    {
	ERRload_struct( UTI, UTI_E_NO_ITEMS_ON_TAPE, NULL, NULL );	
        return( UTI_E_NO_ITEMS_ON_TAPE );
    }
    else
        *list = savedlist;

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}

NFMmap_saveset_numbers( catalog_no, item_no, catalog, item, rev)
    char  *catalog_no;
    char  *item_no;
    char  *catalog;
    char  *item;
    char  *rev;
{
    long  status;

    char  **data;

    MEMptr buffer = NULL;

    static char *fname = "NFMmap_saveset_numbers";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( str, "SELECT n_tablename FROM nfmtables WHERE n_tableno = %s",
	     catalog_no );
    status = SQLquery( str, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    strcpy( catalog, data[0] );
    MEMclose( &buffer );

    sprintf( str, "SELECT n_itemname, n_itemrev FROM %s WHERE n_itemno = %s",
		catalog, item_no );
    status = SQLquery( str, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    strcpy( item, data[0] );
    strcpy( rev, data[1] );
    MEMclose( &buffer );

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}
