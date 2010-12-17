#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000

long NFMlfm_information (sa_no, flag, search, sort, output_list)

   long            sa_no;           /*  I  The working area number to
                                          retrieve information about. A
                                          value of <0 implies that working
                                          storage area number will be
                                          ignored. */
   long            flag;            /*  I  NFM_QUERY_LFM_BY_SANO = query the
                                          nfmsafiles table using the sa_no
                                          working area;
                                          INFM_QUERY_LFM = query the 
					  nfmsafiles table for all entries. */
   char            *search;         /*  I  The query may be limited using a
                                          search criteria. "" implies no
                                          search criteria. */
   char            *sort;           /*  I  The query is to be sorted by sort
                                          criteria. Default is n_sano. */
   MEMptr          *output_list;    /*  O  Memory buffer containing the
					  results of the query */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRlfm_information";

    _NFMRdebug(( fname, "sa_no         : <%ld>\n", sa_no));
    _NFMRdebug(( fname, "flag          : <%ld>\n", flag ));
    _NFMRdebug(( fname, "search        : <%s>\n", search ));
    _NFMRdebug(( fname, "sort          : <%s>\n", sort));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "sa_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (info, "flag", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1) );    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( (INTEGER*2) + strlen(search) + strlen(sort) );

    sprintf(fmt, "%ld", sa_no );
    strcpy (str, fmt );
    strcat (str, "\1");
    sprintf(fmt, "%ld", flag );
    strcat (str, fmt);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort );
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LFM_INFORMATION, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
		output_list);
    _NFMRdebug((fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

long NFMlfm_update (input_list, flag)
 
   MEMptr          input_list;      /*  I  List of all the attributes to be
                                          added/deleted/updated along with
                                          the values. */
 
   long            flag;            /*  I  Flag that specifies the mode of
                                          local file manager update.
                                          Possible values:
                                          NFM_LFM_INSERT;
                                          NFM_LFM_DELETE;
                                          NFM_LFM_CHANGE. */
{
MEMptr info = NULL;
char   *str;
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRlfm_update";

    _NFMRdebug(( fname, "flag <%ld>\n", flag ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "flag", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER );
    
    sprintf( str, "%ld\1", flag );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
 	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    free (str);

    status = MEMappend (input_list, info);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LFM_UPDATE, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}
