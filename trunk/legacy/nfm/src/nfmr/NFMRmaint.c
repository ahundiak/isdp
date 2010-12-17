#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_savesets_to_delete
 
 Abstract:
     This function will return the entries of the nfmarchives table
     in an edited format.( Not standard interface format ! )

 */

long NFMRquery_savesets_to_delete( syn_list, data_list )

MEMptr  *syn_list;     /* o - the returned synonym_list */
MEMptr  *data_list;    /* o - the returned data list */
{
    MEMptr info = NULL;

    long   status = 0;
    long   ret_status = 0;
    static char *fname = "NFMRquery_savesets_to_delete";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_SAVESETS, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		syn_list, data_list );
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRdelete_savesets
 
 Abstract:
     This function will delete a saveset entry from the nfmsavesets
     table using information from NFMRquery_savesets and the user.
     
 */
long NFMRdelete_savesets (data_list)
    MEMptr  data_list;   /* i - list of data */
{

    long   status = 0;
    long   ret_status = 0;

    static char *fname = "NFMRdelete_savesets";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DELETE_SAVESETS, 
				data_list);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRquery_archives_to_delete
 
 Abstract:
     This function will return the entries of the nfmarchives table
     in an edited format.( Not standard interface format ! )

 */

long NFMRquery_archives_to_delete( syn_list, data_list )

MEMptr  *syn_list;     /* o - the returned synonym_list */
MEMptr  *data_list;    /* o - the returned data list */
{
    MEMptr info = NULL;

    long   status = 0;
    long   ret_status = 0;
    static char *fname = "NFMRquery_archives_to_delete";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ARCHIVES, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		syn_list, data_list );
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRdelete_archives
 
 Abstract:
     This function will delete a saveset entry from the nfmarchives
     table using information from NFMRquery_archives and the user.
     
 */
long NFMRdelete_archives (data_list)
    MEMptr  data_list;   /* i - list of data */
{

    long   status = 0;
    long   ret_status = 0;

    static char *fname = "NFMRdelete_archives";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DELETE_ARCHIVES, 
				data_list);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
