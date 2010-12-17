#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

UTICarchive_cmd( script, hdr )
    char           *script;		/*  Script file name */
    script_header  hdr;			/*  Header of script file */
{
    long    status;
    int     making_copies;
    int     no_copies;
    char    config_name[16];
    struct stat devbuf;   /* PS */
    
    _UTI_dbg("UTIarch_cmd : script : %s", script );

    UTILITY = UTI_ARCHIVE;
    making_copies = 1;
    no_copies     = 1;

    while( making_copies )
    {
        status = UTICprepare_media( hdr );
        if( status != UTI_S_SUCCESS )
        {
    	    _UTI_dbg( "UTICarchive_cmd : Prepare media status <%d>", status );
	    return( status );
        }

        fprintf(stdout, "Nfmutil :  Executing Utility Script <%s>\n", script );

        status = UTICexecute_script( script );
        if( status != UTI_S_SUCCESS )
        {
	    _UTI_dbg( "UTICarchive_cmd : Execute script status <%d>", status);
	    return( status );
        }
/* PS - check if the output is to a device file in case of U_TAPE */
        if ((atoi(hdr->location) == C_TAPE) || (atoi(hdr->location) == U_TAPE))
        {
                status = stat( hdr->device, &devbuf );
                if ( devbuf.st_rdev == 0 ) {/* use macro S_IFCHR instead - PS */
                fprintf( stdout, "Nfmutil : WARNING: Backup files may not be written to the tape/floppy.\n");
                fprintf( stdout, "          Please check your storage area device path.\n");
                fprintf( stdout, "          Restore files from the current storage area before changing the path.\n");
                chmod(hdr->device, 0766);
                }
        }

        _UTI_dbg( "UTICarchive_cmd : UTI_GROUP_NO <%d>", UTI_GROUP_NO );

	/* If this is an exabyte tape (hdr->location = C_TAPE), we will
	   not ask about another copy.
	 */

/* Giving user the option to make multiple copies of backup and archive, which 
   is is required by TR # 249402636. Also fixed the related TR # 249500135.
   --  Jujare,  29 MAR 1995 */
/*
 	if ((atoi(hdr->location) != C_TAPE) && (atoi(hdr->location) != U_TAPE))
        {
*/

	    fprintf( stdout, "Nfmutil :  Do you want to make another archive copy ? (y/n) " );
            fgets( UTImsg, 81, stdin );
            if( UTImsg[0] == 'y' || UTImsg[0] == 'Y' )
	    {
	        ++no_copies;
	        fprintf( stdout, "Nfmutil : Making copy number <%d>\n",no_copies);
	        continue;
  	    }
/*
	 }
*/
         making_copies = 0;

     } /* end while */

/*  Update server database 
 */
    status = UTICupdate_db( UTI_GROUP_NO, UTI_S_SUCCESS, UTILITY, no_copies);
    if( status != UTI_S_SUCCESS )
    {
	_UTI_dbg( "UTICarchive_cmd : Bad DB update <%d>", status );
    	UTICerror( UTI_E_FAILURE, script );
    }
    else
    {
	_UTI_dbg( "UTICarchive_cmd : Good DB update <%d>", status );
	UTICerror( UTI_S_SUCCESS, script );
	unlink( script );
	if(strcmp(UTI_CONFIG, "")==0)
	{
		sprintf(config_name,"ARCHIVE_C.%d", UTI_GROUP_NO);
		unlink(config_name);
	}
	else
		unlink(UTI_CONFIG);
	_UTI_dbg( "UTICarchive_cmd : Deleting saveset <%s>", hdr->saveset );
 	unlink( hdr->saveset );
    }

    _UTI_dbg( "%s", "Exit UTICarchive_cmd : " );
    return( status );
}

UTICbackup_cmd( script, hdr )
    char           *script;
    script_header  hdr;
{
    long    status;
    int	    making_copies;
    int     no_copies;
    char    config_name[16];
    struct  stat devbuf; /* PS */
    
    _UTI_dbg("UTIback_cmd : script : %s", script );

    UTILITY = UTI_BACKUP;
 
    making_copies = 1;
    no_copies     = 1;

    while( making_copies )
    {
        status = UTICprepare_media( hdr );
        if( status != UTI_S_SUCCESS )
        {
            _UTI_dbg( "UTICbackup_cmd : Prepare media status <%d>", status );
	    return( status );
        }

        fprintf(stdout, "Nfmutil :  Executing Utility Script <%s>\n", script );

        status = UTICexecute_script( script );
        if( status != UTI_S_SUCCESS )
        {
	    _UTI_dbg( "UTICbackup_cmd : Execute script status <%d>", status );
 	    return( status );
        }

/* PS - check if the output is to a device file in case of U_TAPE */
        if ((atoi(hdr->location) == C_TAPE) || (atoi(hdr->location) == U_TAPE))
        {
                status = stat( hdr->device, &devbuf );
                if ( devbuf.st_rdev == 0 ) { /* use macro S_IFCHR instead -PS */
                fprintf( stdout, "Nfmutil : Unsuccessful Completion: Backup files may not be written to the tape/floppy.\n");
                fprintf( stdout, "          Please check your storage area device path after restoring the files.\n");
                fprintf( stdout, "          from the current storage area.\n");
                chmod(hdr->device, 0766);
                }
        }
	/* Don't make copies for exabyte */

/* Giving user the option to make multiple copies of backup and archive, which 
   is is required by TR # 249402636. Also fixed the related TR # 249500135.
   --  Jujare,  29 MAR 1995 */
/*
	if ((atoi(hdr->location) != C_TAPE) && (atoi(hdr->location) != U_TAPE))
	{
*/
            fprintf(stdout, "Nfmutil :  Do you want to make another backup copy? (y/n)" );
            fgets( UTImsg, 81, stdin );
            if( UTImsg[0] == 'y' || UTImsg[0] == 'Y' )
            {
	        ++no_copies;
	        fprintf( stdout, "Nfmutil : Making copy number <%d>\n",no_copies);
	        continue;
            }
/*
	}
*/
        making_copies = 0;
    } /* end while */
    _UTI_dbg( "UTICbackup_cmd : UTI_GROUP_NO <%d>", UTI_GROUP_NO );

/*  Update server database
 */
    status = UTICupdate_db( UTI_GROUP_NO, UTI_S_SUCCESS, UTILITY, no_copies);
    if( status != UTI_S_SUCCESS )
    {
    	UTICerror( UTI_E_FAILURE, script );
	_UTI_dbg( "UTICbackup_cmd : Bad DB update status <%d>", status );
    }
    else
    {
	UTICerror( UTI_S_SUCCESS, script );
	_UTI_dbg( "UTICbackup_cmd : Good DB update status <%d>", status );
	unlink( script );
	if(strcmp(UTI_CONFIG, "")==0)
	{
		sprintf(config_name,"BACKUP_C.%d", UTI_GROUP_NO);
		unlink(config_name);
	}
	else
		unlink(UTI_CONFIG);
        _UTI_dbg( "UTICbackup_cmd : Deleting saveset <%s>", hdr->saveset );
	unlink( hdr->saveset );
    }

    _UTI_dbg( "%s", "Exit UTICbackup_cmd : " );
    return( status );
}

UTICrestore_cmd( script, dbg )
    char    *script;
    srvdbg  dbg;
{
    long    status;

    UTILITY = UTI_RESTORE;

    _UTI_dbg("UTIrstr_cmd : script : %s", script );

/*  Execute file of script names
 */
    status = UTICexecute_group( script, dbg );

    _UTI_dbg( "%s", "Exit UTICrestore_cmd : " );
    return( status );
}
