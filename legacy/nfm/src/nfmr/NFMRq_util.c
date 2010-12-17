#include "machine.h"
#include "NFMRextern.h"
#include "UTIerrordef.h"
 
#define  BUFFER_SIZE  1000

/*  This function querys the NFM server for all storage areas, flagged 
 *  files for archive, and labels used.
 */
long  NFMRquery_archive( sa_value, f_value, label_value )
    MEMptr *sa_value;		/* o - list of sa values */
    MEMptr *f_value;		/* o - list of file values */
    MEMptr *label_value;	/* o - list of label values */
{
    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_archive";

    _NFMRdebug(( fname, "%s\n", "Entering ... " ));

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_ARCHIVE , info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        return (status);
    }

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status,
		sa_value, f_value, label_value);
    _NFMRdebug(( fname, "NFMRreceive_three_buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
	return( status );

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
    {
	MEMprint_buffers( "SA VALUES", *sa_value, 
			   _NFMdebug_st.NFMRdebug_file);
	MEMprint_buffers( "FILE VALUES", *f_value,
			   _NFMdebug_st.NFMRdebug_file);
	MEMprint_buffers( "LABEL VALUES", *label_value, 
			   _NFMdebug_st.NFMRdebug_file);
    }

    return (NFM_S_SUCCESS); 
}

long  NFMRquery_backup( sa_value, f_value, label_value )
    MEMptr *sa_value;		/* list of sa values */
    MEMptr *f_value;		/* list of file values */
    MEMptr *label_value;	/* list of label values */
{
    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_backup";

    _NFMRdebug(( fname, "%s\n", "Entering ... " ));

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_BACKUP, info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        return (status);
    }

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
	sa_value, f_value, label_value);
    _NFMRdebug(( fname, "NFMRreceive_three_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
    {
        MEMprint_buffers( "SA VALUES", *sa_value,
                           _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers( "FILE VALUES", *f_value,
                           _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers( "LABEL VALUES", *label_value,
                           _NFMdebug_st.NFMRdebug_file);
    }

    return (NFM_S_SUCCESS); 
}

/* This routine requests a list of files flagged for restore from
 * the NFM server.
 */

long  NFMRquery_restore( f_value )
    MEMptr *f_value;		/* o - list of file values */
{
    long   status;
    long   ret_status;

    MEMptr info     = NULL;
    static char *fname = "NFMRquery_restore";

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_RESTORE, info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        return (status);
    }

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
		f_value);
    _NFMRdebug(( fname, "NFMReceive_one_buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "FILE VALUES", *f_value,
                           _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}

/* This routine requests a list of files flagged for delete from
 * the NFM server.
 */

long  NFMRquery_delete( f_value )
    MEMptr *f_value;		/* list of file values */
{
    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_delete";

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_UTIL_DELETE , info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        return (status);
    }

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, f_value);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "FILE VALUES", *f_value,
                           _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}
