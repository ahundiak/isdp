#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

/**************************************************************
 *
 *  NFMfind_items_on_tape () and NFMmap_saveset_numbers ()
 *  are now in cmdtools due to include file dependencies with
 *  the prototype files - Glenn Scott 2/26/92
 *
 **************************************************************/

typedef struct items_on_tape
{
    char   catalog_name[40];
    char   item_name[60];
    char   revision[60];
    char   storage_area[15];
    char   label[10];
    char   saveset[10];
    char   archive_date[10];
    char   archive_state[10];
    struct items_on_tape *next;
} *it_list;

    char   str[500];

long NFMlist_items_on_tape ( data_list )
    MEMptr *data_list;
{
    long   status;

    static char *fname = "NFMlist_items_on_tape";

    MEMptr rbuff      = NULL;
    it_list item_list = NULL;
    it_list savedlist = NULL;

    _NFMdebug ((fname,"%s\n", "Entering ..."));

    status = MEMopen( &rbuff, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &rbuff );
	_NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Catalog Name", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Item Name", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Revision", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Storage Area", "char(14)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Label", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Saveset", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "Archive Date", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = MEMwrite_format( rbuff, "State", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &rbuff );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	return( status );
    }

    status = NFMfind_items_on_tape( &item_list );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &rbuff );
	_NFMdebug(( fname, "NFMfind_items_on_tape : <0x%.8x>\n", status ));
	return( status );
    }
    savedlist = item_list;
 
    str[0] = 0;
    while( item_list != NULL )
    {
  	sprintf( str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
	item_list->catalog_name, item_list->item_name, item_list->revision,
	item_list->storage_area, item_list->label, item_list->saveset,
	item_list->archive_date, item_list->archive_state );

	_NFMdebug(( fname, "str <%s>\n", str));
	status = MEMwrite( rbuff, str );
	if( status != MEM_S_SUCCESS )
 	{
	    MEMclose( &rbuff );
            _NFMdebug ((fname, "MEMwrite : status <0x%.8x>\n", status));
            return( status );
	}
	str[0] = 0;
	item_list = item_list->next;
    } 

    status = MEMsplit_copy_buffer( rbuff, data_list, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n", status));
	MEMclose( &rbuff );
	return( status );
    }

    MEMclose( &rbuff );

    _NFMdebug (( fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS));

    return( NFM_S_SUCCESS );
}

long NFMdisplay_items_on_tape ( search, sort, syn_list, data_list )
    char   *search;
    char   *sort;
    MEMptr *syn_list;
    MEMptr *data_list;
{
    int    i;
    long   status;
    char   fmt[NFM_SYNONYM+1];
    static char *fname = "NFMdisplay_items_on_tape";

    it_list item_list = NULL;
    it_list savedlist = NULL;

    _NFMdebug ((fname,"%s\n", "Entering ..."));
    _NFMdebug ((fname,"Search <%s>\n", search ));
    _NFMdebug ((fname,"Sort   <%s>\n", sort));

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	_NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
     }

    sprintf( str, "%s\1", "Catalog Name" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Item Name" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Revision" );
    status = MEMwrite( *syn_list, str);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Storage Area" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Label" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Saveset" );
    status = MEMwrite( *syn_list, str);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Archive Date" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1", "Archive State" );
    status = MEMwrite( *syn_list, str);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
	_NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_SANAME );
    status = MEMwrite_format( *data_list, "n_storagearea", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_LABEL );
    status = MEMwrite_format( *data_list, "n_label", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_saveset", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", DATE );
    status = MEMwrite_format( *data_list, "n_archivedate", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ARCHIVESTATE );
    status = MEMwrite_format( *data_list, "n_archivestate", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        MEMclose( data_list );
        _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMfind_items_on_tape( &item_list );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
	_NFMdebug(( fname, "NFMfind_items_on_tape : <0x%.8x>\n", status ));
	return( status );
    }
    savedlist = item_list;
 
    str[0] = 0;
    while( item_list != NULL )
    {
  	sprintf( str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
	item_list->catalog_name, item_list->item_name, item_list->revision,
	item_list->storage_area, item_list->label, item_list->saveset,
	item_list->archive_date, item_list->archive_state );

	_NFMdebug(( fname, "str <%s>\n", str));
	status = MEMwrite( *data_list, str );
	if( status != MEM_S_SUCCESS )
 	{
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            _NFMdebug ((fname, "MEMwrite : status <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
 	}
	str[0] = 0;
	item_list = item_list->next;
    } 

    _NFMdebug (( fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS));

    return( NFM_S_SUCCESS );
}
