#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long  NFMRvalidate_and_format_date( in_str, display_date, timestamp_date )
    char *in_str;	  /* i - input date string */
    char *display_date;	  /* o - date string in user's defined format */
    char *timestamp_date; /* o - date string in timestamp format */

{
    long   status;
    long   ret_status;
    char   str[50];
    char   **data_ptr;
    MEMptr info = NULL;

    static char *fname = "NFMRvalidate_and_format_date";

    _NFMRdebug(( fname, "input_string <%s>\n", in_str ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMopen");
        return (NFM_E_MEM);
        }

    status = MEMwrite_format (info, "in_date", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite_format");
        return (NFM_E_MEM);
        }

    sprintf( str, "%s\1", in_str );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite");
        return (NFM_E_MEM);
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_VALID_DATE, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
	{
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild");
        return (NFM_E_MEM);
        }

    data_ptr = (char**)info->data_ptr;

    _NFMRdebug(( fname, "Display   Date <%s>\n", data_ptr[0] ));
    _NFMRdebug(( fname, "Timestamp Date <%s>\n", data_ptr[1] ));

    strcpy( display_date, data_ptr[0]);
    strcpy( timestamp_date, data_ptr[1]);

    MEMclose( &info );

    return( NFM_S_SUCCESS ); 
}

long NFMRget_date_info (date_type, time_type, format_string)
     char *date_type ;         /* o-  AMERICAN, ITALIAN, etc...*/
     char *time_type ;         /* o-  24HR or 12HR *************/
     char *format_string ;     /* o-   mm/dd/yyyy hh24:nn:ss... RIS input */
			  
{
    long   status;
    long   ret_status;
    char   **data_ptr;
    MEMptr info = NULL;

    static char *fname = "NFMRget_date_info";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_DATE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
	{
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild");
        return (NFM_E_MEM);
        }

    data_ptr = (char**)info->data_ptr;

    _NFMRdebug(( fname, "Date Type <%s>\n", data_ptr[0] ));
    _NFMRdebug(( fname, "Time Type <%s>\n", data_ptr[1] ));
    _NFMRdebug(( fname, "Format String <%s>\n", data_ptr[2] ));

    strcpy( date_type, data_ptr[0] );
    strcpy( time_type, data_ptr[1] );
    strcpy( format_string, data_ptr[2] );

    MEMclose( &info );

    return( NFM_S_SUCCESS ); 
}
