#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "MSGstruct.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

char	uti_string[1024];

long NFMSutilities_update( in_list)
    MEMptr	in_list;
{
    long	status = 0;
    long	req_status;
    long	ret_status;

    int		group_no;
    int		utility;
    int		no_copies;

    char	flag;
    char	**data_ptr;
    MEMptr      xfer = NULL;
    UTIpending  flist=NULL;

    static	char *fname = "UTIutilities_update";

    UTI_MSG_BUFFER = NULL;
    UTI_ERR_BUFFER = NULL;

    UTIarchive   = 100;
    UTIarchive_p = 150;
    UTIbackup    = 200;
    UTIbackup_p  = 250;
    UTIrestore   = 300;
    UTIrestore_p = 350;
    UTIdelete    = 400;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = UTIopen_buffers();
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }

    ret_status = MEMbuild_array (in_list);
    if (ret_status != MEM_S_SUCCESS)
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (ret_status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _UTIdebug(( fname, "group_no   : <%s>\n", data_ptr[0]));
    _UTIdebug(( fname, "req_status : <%s>\n", data_ptr[1]));
    _UTIdebug(( fname, "utility    : <%s>\n", data_ptr[2]));
    _UTIdebug(( fname, "client_sa  : <%s>\n", data_ptr[3]));
    _UTIdebug(( fname, "no_copies  : <%s>\n", data_ptr[4]));

    _NFMdebug(( fname, "group_no   : <%s>\n", data_ptr[0]));
    _NFMdebug(( fname, "req_status : <%s>\n", data_ptr[1]));
    _NFMdebug(( fname, "utility    : <%s>\n", data_ptr[2]));
    _NFMdebug(( fname, "client_sa  : <%s>\n", data_ptr[3]));
    _NFMdebug(( fname, "no_copies  : <%s>\n", data_ptr[4]));

    group_no      = atoi( data_ptr[0] );
    req_status    = atol( data_ptr[1] );
    utility       = atoi( data_ptr[2] );
    no_copies     = atoi( data_ptr[4] );

    if( utility == UTIarchive )
    {
	UTIset_globals( "A" );
	flag = 'A';
    }
    else if( utility == UTIbackup )
    {
	UTIset_globals( "B" );
	flag = 'B';
    }
    else if( utility == UTIrestore )
    {
	UTIset_globals( "R" );
	flag = 'R';
    }

    UTI_CLIENT_SA = atoi( data_ptr[3] );

    ret_status = UTIget_client_path( );
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }

/*  Using given group number, find all nfmsaveset entries with this 
 *  group number that have an 'utility pending' status.
 */
    ret_status = UTIfind_group_members( group_no, &flist, flag );
    _NFMdebug(( fname, "UTIfind_group_members flist <%x>  : <0x%.8x>,\n", 
							flist, ret_status));
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }

    ret_status = NFMget_move_files_list( UTIuser_id, &xfer );
    _NFMdebug(( fname, "NFMget_move_files_list  : <0x%.8x>\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        MEMclose( &xfer );
        return( ret_status );
    }

/*  If RESTORE, transfer files to their home location */

    if( utility == UTIrestore )
    {
        ret_status = UTIxfer_files_out( &xfer, UTI_CLIENT_SA, flist, "move" );
        _NFMdebug(( fname, "UTIxfer_files_out  : <0x%.8x>\n", ret_status));
        if( ret_status != UTI_S_SUCCESS )
        {
  	    MEMclose( &xfer );
            status = NFMSsend_one_buffer( ret_status, xfer );
	    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
            return( ret_status );
        }
     }


/*  Now update relevant database tables
 */
    if( utility != UTIrestore )
    {
        ret_status = UTIupdate_nfmarchives_p( group_no, no_copies );
        _NFMdebug(( fname, "UTIupdate_nfmarchive_p <0x%.8x>\n", ret_status));
        if( ret_status != UTI_S_SUCCESS )
	{
            status = NFMSsend_one_buffer( ret_status, xfer );
            _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	    return( ret_status );
	}
    }

    ret_status = UTIupdate_nfmsavesets_p( utility, group_no );
    _NFMdebug(( fname, "UTIupdate_nfmsavesets_p  : <0x%.8x>\n", ret_status));
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }

    ret_status = UTIupdate_f_catalog( utility, flist );
    _NFMdebug(( fname, "UTIupdate_f_catalog  : <0x%.8x>\n", ret_status));
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }
    
    ret_status = UTIupdate_catalog( utility, flist );
    _NFMdebug(( fname, "UTIupdate_catalog  : <0x%.8x>\n", ret_status));
    if( ret_status != UTI_S_SUCCESS )
    {
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	return( ret_status );
    }

/*  If ARCHIVE, remove files from their home location */

    if( utility == UTIarchive )
    {
	MEMclose(&xfer);
	xfer = NULL;
        _NFMdebug(( fname, "flist is <%x>", flist));
        ret_status = UTIxfer_delete_files( &xfer, flist );
        _NFMdebug(( fname, "UTIxfer_delete_files  : <0x%.8x>\n", ret_status));
        if( ret_status != UTI_S_SUCCESS )
        {
            MEMclose( &xfer );
    	    status = NFMSsend_one_buffer( ret_status, xfer );
	    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
	    return( ret_status );
	}
    }
    MEMclose( &xfer );

/*  Build the return buffer to contain the names of files to delete from
 *  the requestor node.
 */
    ret_status = UTIclient_return_buffer( &xfer, flist );
    _NFMdebug(( fname, "UTIclient_return_buffer  : <0x%.8x>\n", ret_status));
    if( ret_status != UTI_S_SUCCESS )
    {
        MEMclose( &xfer );
	xfer = NULL;
        status = NFMSsend_one_buffer( ret_status, xfer );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return( ret_status );
    }

    status = NFMSsend_one_buffer( ret_status, xfer );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &xfer );
    
    UTIclose_buffers();

    _NFMdebug(( fname, "Exiting with SUCCESS\n", status));

    return( NFM_S_SUCCESS );
}
