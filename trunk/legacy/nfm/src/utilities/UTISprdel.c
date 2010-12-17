#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "DEBUG.h"

UTIprocess_delete( flist )
    UTIpending  flist;
{
    long	status;

    MEMptr	xfer = NULL; 

    static	char *fname = "UTIprocess_delete";

/*  Get utilities reserved storage area number */
    status = UTIget_reserved_sano();
    if( status != UTI_S_SUCCESS )
    {
        _UTIdebug(( fname, "UTIget_reserved_sano : <0x%.8x>\n", status ));
	return( status );
    }

/**********
    status = NFMget_move_files_list( UTIuser_id, &xfer );
    if( status != NFM_S_SUCCESS)
    {
        MEMclose( &xfer );
        _UTIdebug(( fname, "NFMget_move_files_list : <0x%.8x>\n", status ));
        return( status );
    }
***********/

/*  Delete files from fs location
 */
    xfer = NULL;
    status = UTIxfer_delete_files( &xfer, flist );
    if( status != UTI_S_SUCCESS )
    {
        _UTIdebug(( fname, "UTIxfer_delete_files : <0x%.8x>\n", status ));
        return( status );
    }

/*  Update file catalog
 */
    status = UTIupdate_f_catalog( UTIdelete, flist );
    if( status != UTI_S_SUCCESS )
    {
        _UTIdebug(( fname, "UTIupdate_f_catalog : <0x%.8x>\n", status ));
        return( status );
    }

/*  Update catalog
 */
    status = UTIupdate_catalog( UTIdelete, flist );
    if( status != UTI_S_SUCCESS )
    {
        _UTIdebug(( fname, "UTIupdate_catalog : <0x%.8x>\n", status ));
        return( status );
    }

/*  Update local file manager 'nfmsafiles'
 *  Since only delete files calls update_safiles, no need to pass
 *  the utility name here.
 */
    status = UTIupdate_safiles(flist);
    if( status != UTI_S_SUCCESS )
    {
        _UTIdebug(( fname, "UTIupdate_safiles : <0x%.8x>\n", status ));
	/** Failure is not an error **/
    }

    /*  Update nfmsavesets table
     */
    status = UTIupdate_nfmsavesets( UTIdelete, flist->rstr.archive_no,
    			            flist );
    if( status != UTI_S_SUCCESS )
        return( status );

    _UTIdebug(( fname, "Success: <0x%.8x>\n", UTI_S_SUCCESS ));
    return( UTI_S_SUCCESS );
}
