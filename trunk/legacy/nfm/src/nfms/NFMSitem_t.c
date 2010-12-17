#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "NFMdef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMschema.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSget_item_no
 
 Abstract:
     This function will return an item number given a catalog name, item name,
     and item revision.

 */
 
long NFMSget_item_no (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long item_no;
char item_num[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_item_no";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMget_item_no (user_id, data_ptr[1], data_ptr[2], data_ptr[3],
                             &item_no);
_NFMSdebug(( fname, "NFMget_item_no <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_itemno", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf (item_num, "%ld", item_no);

strcpy (str, item_num);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );
    
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSget_item_name
 
 Abstract:
     This function will return an item name and item revision given a catalog
     name and item number.
 */
 
long NFMSget_item_name (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long item_no;
char item_name[NFM_ITEMNAME+1];
char item_rev[NFM_ITEMREV+1];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_item_name";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "cat name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item no  : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);
item_no = atol (data_ptr[2]);

ret_status = NFMget_item_name (user_id, data_ptr[1], item_no, item_name,
                               item_rev);
_NFMSdebug(( fname, "NFMget_item_name <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf( str, "char(%d)", NFM_ITEMNAME );
status = MEMwrite_format (data_list, "n_itemname", str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf( str, "char(%d)", NFM_ITEMREV );
status = MEMwrite_format (data_list, "n_itemrev", str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, item_name);
strcat (str, "\1");
strcat (str, item_rev);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );
    
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMScheck_co_status
 
 Abstract:
     This function will return an item's checked out status given a catalog
     name and item number.
 */
 
long NFMScheck_co_status (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long item_no;
char co_status[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMScheck_co_status";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "cat name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item no  : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);
item_no = atol (data_ptr[2]);

ret_status = NFMcheck_co_status (user_id, data_ptr[1], item_no, co_status);
_NFMSdebug(( fname, "NFMcheck_co_status <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_costatus", "char(10)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, co_status);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );
    
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


