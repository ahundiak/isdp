#include "machine.h"
#include "NFMerrordef.h"
#include "NFMRextern.h"
#include "UTIerrordef.h"

#define  BUFFER_SIZE 	1000

create_archive()
{

    long	status;

    char	sa_no[10];
    char	label[10];

    MEMptr	file_value = NULL;
    MEMptr	sa_attr	   = NULL;
    MEMptr      label_value = NULL;
    MEMptr	file_list   = NULL;
    MEMptr	msg_buf	    = NULL;
    static	char *fname = "NFAarchive";

/*  Retrieve storage areas, flagged files and existing labels from
 *  NFM server
 */
    status = NFMRquery_archive( &sa_attr, &file_value, &label_value );
    if( status != NFM_S_SUCCESS )
        return( status );

/*  If no files are flagged - No point to continue
 */
    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &file_value );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    _NFIdebug(( fname, "# rows returned <%d>\n", file_value->rows ));

    if( file_value->rows == 0 )
    {
	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
	MEMclose( &file_value );
	return( UTI_S_SUCCESS );
    }

/*  Choose storage areas and labels
 */
    status = UTIchoose_sa( "ARCHIVE", "A", sa_attr, label_value, 
			    sa_no, label );
    if( status != UTI_S_SUCCESS )
        return( status );

/*  Pick pending flagged files
 */
    status = UTIchoose_flagged_files( "ARCHIVE", "A", file_value, &file_list );
    _NFIdebug (( fname, "UTIchoose_flagged_files returned <0x%.8x>", status));
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_list );
        return( status );
    }

    status = NFMRarchive_files( NFMserver, NFMenv, NFMuser, NFMpasswd, 
				sa_no, label, file_list, &msg_buf );
    _NFIdebug (( fname, "NFMRarchive_files returned <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_list );
        return( status );
    }

    MEMclose( &file_list );

    status = UTIRprocess_status( msg_buf );
    MEMclose( &msg_buf );

    return( NFI_S_SUCCESS );
}

create_backup()
{
    long	status;

    char	sa_no[10];
    char	label[10];

    MEMptr	file_value = NULL;
    MEMptr	sa_attr	   = NULL;
    MEMptr      label_value = NULL;
    MEMptr	file_list   = NULL;
    MEMptr	msg_buf     = NULL;

    static 	char *fname =  "NFAbackup";

    _NFIdebug(( fname, "ENTRY\n" ));

/*  Retrieve storage areas, flagged files and existing labels from
 *  NFM server
 */
    status = NFMRquery_backup( &sa_attr,&file_value, &label_value );
    _NFIdebug(( fname, "NFMRquery_backup <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
        return( status );

/*  If no files are flagged - No point to continue
 */
    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
    	_NFIdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        MEMclose( &file_value );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    if( file_value->rows == 0 )
    {
	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
    	_NFIdebug(( fname, "NO FLAGGED FILES FOUND\n"));
	MEMclose( &file_value );
	return( UTI_S_SUCCESS );
    }

/*  Choose storage areas and labels
 */
    status = UTIchoose_sa( "BACKUP","B", sa_attr, label_value, sa_no, label );
    _NFIdebug(( fname, "UTIchoose_sa <0x%.8x>\n", status ));
    if( status != UTI_S_SUCCESS )
        return( status );

/*  Pick pending flagged files
 */
    status = UTIchoose_flagged_files( "BACKUP", "B", file_value, &file_list );
    _NFIdebug(( fname, "UTIchoose_flagged_files <0x%.8x>\n", status ));
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_list );
        return( status );
    }

    _NFIdebug(( fname, "sa_no <%s>\n", sa_no ));
    _NFIdebug(( fname, "label <%s>\n", label ));

    status = NFMRbackup_files( NFMserver, NFMenv, NFMuser, NFMpasswd, 
				sa_no, label, file_list, &msg_buf );
    _NFIdebug(( fname, "NFMRbackup_files <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_list );
	MEMclose( &msg_buf );
        return( status );
    }
    MEMclose( &file_list );

    status = UTIRprocess_status( msg_buf );
    MEMclose( &msg_buf );
 
    return( NFI_S_SUCCESS );
}

create_restore()
{
    long	status;

    MEMptr	file_value = NULL;
    MEMptr	file_list  = NULL;
    MEMptr	msg_buf	   = NULL;

    static	char *fname = "NFArestore";

/*  Retrieve storage areas, flagged files and existing labels from
 *  NFM server
 */
    status = NFMRquery_restore( &file_value );
    if( status != NFM_S_SUCCESS )
        return( status );

    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &file_value );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    if( file_value->rows == 0 )
    {
	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
	MEMclose( &file_value );
	return( UTI_I_NO_FLAGGED_FILES );
    }

/*  Pick pending flagged files
 */
    status = UTIchoose_flagged_files( "RESTORE", "R", file_value, &file_list );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_list );
        return( status );
    }

/* Build return buffer
 */
    status = NFMRrestore_files( NFMserver, NFMenv, NFMuser, NFMpasswd,
				file_list, &msg_buf );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_list );
 	MEMclose( &msg_buf );
        return( status );
    }

    MEMclose( &file_list );

    status = UTIRprocess_status( msg_buf );
    MEMclose( &msg_buf );

    return( NFI_S_SUCCESS );

}

create_delete()
{
    long	status;

    MEMptr	file_value = NULL;
    MEMptr      file_list  = NULL;

    static 	char *fname = "NFAdelete";

/*  Retrieve flagged files from NFM server
 */
    status = NFMRquery_delete( &file_value );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug(( fname, "NFMRquery_delete <0x%.8x>\n", status ));
        return( status );
    }

    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &file_value );
        _NFIdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    if( file_value->rows == 0 )
    {
	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        _NFIdebug(( fname, "file_value->rows is ZERO\n"));
	MEMclose( &file_value );
	return( UTI_I_NO_FLAGGED_FILES );
    }

/*  Pick pending flagged files
 */
    status = UTIchoose_flagged_files( "DELETE", "D", file_value, &file_list );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_list );
        _NFIdebug(( fname, "UTIchoose_flagged_files <0x%.8x>\n", status ));
        return( status );
    }

/* Build return buffer
 */
    status = NFMRdelete_files( NFMserver, NFMenv, NFMuser, NFMpasswd,
			       file_list );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_list );
        _NFIdebug(( fname, "NFMRdelete_files <0x%.8x>\n", status ));
        return( status );
    }

    MEMclose( &file_list );

    return( NFI_S_SUCCESS );

}
