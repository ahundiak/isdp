#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


long NFMSvalidate_and_format_date (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char display_date[50];
char timestamp_date[50];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSvalidate_and_format_date";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, fname, "MEMbuild_array" );
    return (NFM_E_MEM);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "in_string : <%s>\n", data_ptr[0]));

ret_status = NFMvalidate_and_format_date ( data_ptr[0], display_date, 
					   timestamp_date );
_NFMSdebug(( fname, "NFMvalidate_and_format_date <0x%.8x>\n", ret_status ));
if( ret_status != NFM_S_SUCCESS )
{
    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
    return( ret_status );
}
	
status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
status = MEMwrite_format (data_list, "display_date", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = MEMwrite_format (data_list, "timestamp_date", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
sprintf (str, "%s\1%s\1", display_date, timestamp_date);
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

return (ret_status);
}


long NFMSget_date_info (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char date_type[50];
char time_type[50];
char format_string[50];
char str[200];
MEMptr data_list = NULL;

static char *fname = "NFMSget_date_info";

ret_status = NFMget_date_info ( date_type, time_type, format_string );
if( ret_status != NFM_S_SUCCESS )
{
    _NFMSdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
    return( ret_status );
}

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, fname, "MEMopen" );
    return (NFM_E_MEM);
    }
    
status = MEMwrite_format (data_list, "date_type", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = MEMwrite_format (data_list, "time_type", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = MEMwrite_format (data_list, "format_string", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
sprintf (str, "%s\1%s\1%s\1", date_type, time_type, format_string);
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

return (ret_status);
}

