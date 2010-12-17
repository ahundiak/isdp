#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMSextern.h"
#include "NFMsysstruct.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "DEBUG.h"

extern  struct NFMuser_info_struct NFMuser_info;

UTIprocess_archive( sa_no, label, flist )
    int		sa_no;
    char	*label;
    UTIpending  flist;
{
    long	status;
 
    char	true_label[10];
    char	script_name[80];
    char 	env[15];

    NFMarch	nfm_arch_loc = NULL;
    UTIarch	uti_arch_loc = NULL;

    MEMptr	xfer = NULL;
    static	char *fname = "UTIprocess_archive";

/*  Now that desired information has been retrieved from the user,
 *  Information on the storage area must be retrieved, the label 
 *  must be generated or verified, and file information not gathered
 *  during 'query_archive' must be obtained. ... Then the scripts 
 *  will be generated, files and scripts transferred to archive location,
 *  and an informational message sent back to the user.
 */
    _UTIdebug(( fname, "User_info.dir <%s>, UTIenv : <%s>\n",
			NFMuser_info.dir,  UTIenv ));

/***************
    if(strcmp(NFMuser_info.dir,"") == 0)
       sprintf( UTI_SERVER_PATH, "/usr/nfmadmin/%s/utilities/", UTIenv );
    else
       sprintf( UTI_SERVER_PATH, "%s/%s/utilities/", NFMuser_info.dir, UTIenv );
***************/


    _UTIdebug(( fname, "UTI_SERVER_PATH : <%s>\n", UTI_SERVER_PATH ));

    status = UTIprocess_label( label, true_label );
    if( status != UTI_S_SUCCESS )
	return( status );

    status = UTIget_sa_info( sa_no, true_label, flist,
			     &nfm_arch_loc, &uti_arch_loc );
    if( status != UTI_S_SUCCESS )
	return( status );

    status = UTIprocess_files( nfm_arch_loc, uti_arch_loc, flist );
    if( status != UTI_S_SUCCESS )
    {
	UTIrm_saveset_entry( nfm_arch_loc->archive_no );
 	return( status );
    }

    UTI_GROUP_NO = nfm_arch_loc->archive_no;

    status = UTIbuild_script( UTIarchive, nfm_arch_loc->archive_no,
			      uti_arch_loc, flist );
    if( status != UTI_S_SUCCESS )
    {
	UTIrm_saveset_entry( nfm_arch_loc->archive_no );
 	return( status );
    }

/*  If OFF_LINE, transfer script and files to archive location; otherwise,
 *  files and scripts are local to make cpio file which is moved to
 *  archive location.
 */
    status = NFMget_move_files_list( UTIuser_id, &xfer );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose( &xfer );
        _UTIdebug(( fname, "NFMget_move_files_list <0x%.8x>\n", status ));
	UTIrm_saveset_entry( nfm_arch_loc->archive_no );
        return( status );
    }

    if( OFF_LINE )
    {
	sprintf( script_name, "ARCHIVE.%d", nfm_arch_loc->archive_no);
        chmod( script_name, 06777 );
        status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script_name );
        if( status != UTI_S_SUCCESS )
        {
  	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
   	    return( status );
	}

        if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
	{
  	    sprintf( script_name, "ARCHIVE_C.%d", nfm_arch_loc->archive_no);
            chmod( script_name, 06777 );
            status = UTIxfer_non_nfm_file_in( UTI_CLIENT_SA, script_name );
            if( status != UTI_S_SUCCESS )
            {
    	        UTIrm_saveset_entry( nfm_arch_loc->archive_no );
      	        return( status );
	    }
	}
        status = UTIxfer_files_in( &xfer, UTI_CLIENT_SA, flist, "move" );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
    	    return( status );
	}

	status = UTIupdate_f_catalog( UTIarchive_p, flist );
	if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
	    return( status );
	}

	status = UTIupdate_catalog( UTIarchive_p, flist );
	if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
	    return( status );
	}

        status = UTIupdate_nfmarchives( UTIarchive_p, nfm_arch_loc );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
    	    return( status );
	}

        status = UTIupdate_nfmsavesets( UTIarchive_p, nfm_arch_loc->archive_no,
				       flist );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
 	    return( status );
	}
 	status = UTIupdate_nfmprojectcit( UTIarchive, nfm_arch_loc->archive_no,
					  flist );
        if( status != UTI_S_SUCCESS )
 	    return( status );
    }    
    else if( ON_LINE )
    {
	/*  Move files from storage location to local reserved directory
   	 */
        status = UTIxfer_files_in( &xfer, UTI_RES_SA, flist, "move" );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
    	    return( status );
	}

	/*  Execute script to make cpio file
	 */
	status = UTIexecute_script( UTI_SCRIPT );
	if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
	    return( status );
	}

	/*  Transfer cpio file to chosen archive location
	 */
        status = UTIxfer_non_nfm_file_in( nfm_arch_loc->storageno, 
				          nfm_arch_loc->saveset );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
   	    return( status );
	}

	/*  Update catalog
	 */
	status = UTIupdate_catalog( UTIarchive, flist );
	if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
	    return( status );
	}
	/*  Update file catalog
	 */
	status = UTIupdate_f_catalog( UTIarchive, flist );
	if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
	    return( status );
	}

 	/*  Update nfmarchives table
	 */
        status = UTIupdate_nfmarchives( UTIarchive, nfm_arch_loc );
        if( status != UTI_S_SUCCESS )
	{
   	    UTIrm_saveset_entry( nfm_arch_loc->archive_no );
  	    return( status );
	}

	/*  Update nfmsavesets table
 	 */
        status = UTIupdate_nfmsavesets( UTIarchive, nfm_arch_loc->archive_no,
				       flist );
        if( status != UTI_S_SUCCESS )
  	    return( status );

	/*  Update nfmprojectcit table 
	 */
        status = UTIupdate_nfmprojectcit( UTIarchive, nfm_arch_loc->archive_no,
                                          flist );
        if( status != UTI_S_SUCCESS )
            return( status );

   	status = UTIxfer_delete_files( &xfer, flist );

   	MEMclose( &xfer );

	status = UTIdelete_local_files( flist );

	/*  Delete local saveset file
	 */

   	/***
   	sprintf( UTImsg, "%s/%s/utilities/%s",
	 	 NFMuser_info.dir, UTIenv, nfm_arch_loc->saveset );
	***/

	sprintf( UTImsg, "%s%s", UTI_SERVER_PATH, nfm_arch_loc->saveset );
        status = unlink( UTImsg );
	_UTIdebug(( fname, "Unlink status <%ld>\n", status ));

    }

    return( UTI_S_SUCCESS );
}
