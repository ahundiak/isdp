/*******************************************************************************
   scpio is not supported on non-CLIX machines. It is replaced by cpio for
   non-CLIX machines.  IGI - 12 Jul 94 .
*******************************************************************************/
#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "UTIstruct.h"
#include "UTIdef.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

int     empty;
long    status;
char    line[132];
char    command[132];
char    utidir_name[132];
char    *pwd;
char	*UTname();
char	*ODname();

FILE    *script_file;
FILE    *config_file;

/****DELETE THIS
#define UTI_E_SCR_TOO_BIG 99999***/

UTIu_build_archive_script( rlist, rec )
    UTIpending rlist;
    UTIarch    rec;
{
    int   archive_no;
    int   normal_length=0, recommend=0;
    struct stat stat_buf;

    static char *fname = "UTIu_build_archive_script";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    archive_no = rlist->rstr.archive_no;
    empty = TRUE;

    script_file = fopen( UTI_SCRIPT, "w" );
    if( script_file == NULL )
    {
	_UTIdebug(( fname, "Can't open <%s>\n", UTI_SCRIPT));
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_SCRIPT );
	return( UTI_E_WRTSCR );
    }

    switch( UTI_MEDIA )
    {
	case F_DISK:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
	    status = UTIu_archive_FDISK( UTIarchive, rlist, rec );
	    break;

    	case U_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
 	    status = UTIu_archive_UTAPE( UTIarchive, rlist, rec );
	    break;

	case C_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
 	    status = UTIu_archive_CTAPE( UTIarchive, rlist, rec );
	    break;

	case M_TAPE:
 	    status = UTIv_archive_MTAPE( UTIarchive, rlist, rec );
	    break;

	case H_DISK:
	    status = UTIu_archive_HDISK( UTIarchive, rlist, rec );
	    break;

/*******Not supported in 3.0
	case O_DISK:
	    status = UTIu_archive_ODISK( UTIarchive, rlist, rec );
	    break;

	case JUKE_BOX:
	    status = UTIu_archive_JUKEBOX( UTIarchive, rlist, rec );
	    break;
***************************/

	case CACHE:
	    status = UTIu_archive_CACHE( UTIarchive, rlist, rec );
	    break;

	case TJB:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
            status = UTIu_archive_TJB( UTIarchive, rlist, rec );
            break;

	default:
	    _UTIdebug(( fname, "%s\n", "NO UTI_MEDIA match"));
	    ERRload_struct( UTI, UTI_E_DEVICE, "%s", rec->device_type );
	    status = UTI_E_DEVICE;
	    break;
    }
    fclose( script_file );
    fclose( config_file );
    if( status != UTI_S_SUCCESS )
        return( UTI_E_FAILURE );

/*  If there were no filenames written into the script ( rlist->state = -1 ),
 *  delete the script and return failure
 */
    if( empty )
    {
	ERRload_struct( UTI, UTI_E_NOFILES, "%s", UTI_SCRIPT );
	return( UTI_E_NOFILES );
    }

/*  Set privileges for the script
 */
    chmod( UTI_SCRIPT, 06777 );
    chmod( UTI_CONFIG, 06777 );

/***Do a stat on each one of these files and check whether their size is
    Less than 11,000 characters. Since "find" (all unix shell commands for
    that matter) is failing for arguments size  
    more than that size, this fix is necessary --DONTU ***/

    status = stat(UTI_SCRIPT, &stat_buf);
    if(status != 0)
    {
	_UTIdebug(( fname, "Script file <%s> not found!",UTI_SCRIPT));
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_SCRIPT );
        return( UTI_E_WRTSCR );
    }
    else if(stat_buf.st_size > 11000)
    {
	_UTIdebug(( fname, "Script file <%s> is TOO BIG: <%d>\n",
						UTI_SCRIPT, stat_buf.st_size));

	if((UTI_MEDIA == C_TAPE) || 
	   (UTI_MEDIA == U_TAPE) || 
	   (UTI_MEDIA == TJB)    || 
	   (UTI_MEDIA == F_DISK))
	{
		normal_length = strlen(UTI_CLIENT_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	else
	{
		normal_length = strlen(UTI_SERVER_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	recommend = (int )(11000 / normal_length);

	ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d", "ARCHIVE", recommend );
        return( UTI_E_SCR_TOO_BIG );
    }

    if((UTI_MEDIA == C_TAPE) || 
       (UTI_MEDIA == U_TAPE) || 
       (UTI_MEDIA == TJB)    || 
       (UTI_MEDIA == F_DISK))
    {
    	status = stat(UTI_CONFIG, &stat_buf);
    	if(status != 0)
    	{
	  _UTIdebug(( fname, "Not using Config Script file <%s>\n",UTI_CONFIG));
	  /** We don't care if it doesn't exist **/
    	}
        else if(stat_buf.st_size > 11000)
        {
	  _UTIdebug(( fname, "Config Script file <%s> is TOO BIG: <%d>\n",
						UTI_CONFIG, stat_buf.st_size));

	  normal_length = strlen(UTI_CLIENT_PATH) + 
				strlen(rlist->ci_file_name) + 2;

	  recommend = (int )(11000 / normal_length);

	  ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d", "ARCHIVE",recommend );
          return( UTI_E_SCR_TOO_BIG );
        }
    }

    /***********************************************************/

    _UTIdebug(( fname, "%s\n", "SUCCESS"));
/*  Store script name and node number in return buffer
 */
    if( OFF_LINE )
    {
	sprintf( utidir_name,"%sARCHIVE.%d",UTI_CLIENT_PATH,archive_no );
        UTIreturn_info( utidir_name, rec->node.name, rec->label );
    }
    return( UTI_S_SUCCESS );
}

UTIu_build_restore_script( rlist, rec  )
    UTIpending  rlist;
    UTIarch     rec;
{
    char script[132];
    char config[132];
    int  normal_length=0, recommend=0; 
    struct stat stat_buf;
    char *ptr;
    char *UTIalloc_more(char *ptr, long more);

    static char *fname = "UTIu_build_restore_script";

    empty = TRUE;
    if( ON_LINE )
        sprintf( script,"%sRESTORE.COM", UTI_SERVER_PATH );
    else
    {
	sprintf( script,"%sRSTR.%d", UTI_SERVER_PATH, UTI_GROUP_NO );
	sprintf( UTI_CONFIG,"%sRSTR_C.%d", UTI_SERVER_PATH, UTI_GROUP_NO );
    }

    script_file = fopen( script, "w+" );
    if( script_file == NULL )
    {
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", script );
 	return( UTI_E_WRTSCR );
    }

    switch( UTI_MEDIA )
    {
	case F_DISK:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
	    status = UTIu_rstr_FDISK( rlist, rec );
	    break;

    	case U_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
 	    if( config_file == NULL )
    	    {
     	        _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
		ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
		return( UTI_E_WRTSCR );
	    }
	    ptr = UTIalloc_more(rec->device_name, 2);
	    if(ptr != NULL)
		rec->device_name = ptr;
	    else
	    {
		_UTIdebug((fname, "Not enough memory!\n"));
	    	return(UTI_E_FAILURE);
 	    }
/* PS - n should not be concatenated for non_clix machines */
#if !defined(OS_INTELSOL)
	    strcat(rec->device_name,"n");
#endif
	    status = UTIu_rstr_UTAPE( rlist, rec );
	    break;

	case C_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n",UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
	    ptr = UTIalloc_more(rec->device_name, 2);
	    if(ptr != NULL)
		rec->device_name = ptr;
	    else
	    {
		_UTIdebug((fname, "Not enough memory!\n"));
	    	return(UTI_E_FAILURE);
 	    }
/* PS - n should not be concatenated for non_clix machines */
#if !( defined(OS_SCO_UNIX) || defined(OS_INTELSOL) )
	    strcat(rec->device_name,"n");
#endif
 	    status = UTIu_rstr_CTAPE( rlist, rec );
	    break;

	case M_TAPE:
 	    status = UTIv_rstr_MTAPE( rlist, rec );
	    break;

	case H_DISK:
	    status = UTIu_rstr_HDISK( rlist, rec );
	    break;

/*******Not supported in 3.0
	case O_DISK:
	    status = UTIu_rstr_ODISK( rlist, rec );
	    break;

	case JUKE_BOX:
	    status = UTIu_rstr_JUKEBOX( rlist, rec );
	    break;
****************************/

	case CACHE:
	    status = UTIu_rstr_CACHE( rlist, rec );
	    break;

	case TJB:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n", UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
	    ptr = UTIalloc_more(rec->device_name, 2);
	    if(ptr != NULL)
		rec->device_name = ptr;
	    else
	    {
		_UTIdebug((fname, "Not enough memory!\n"));
	    	return(UTI_E_FAILURE);
 	    }
            strcat(rec->device_name,"n");
            status = UTIu_rstr_TJB( rlist, rec );
            break;

	default:
	    ERRload_struct( UTI, UTI_E_DEVICE,"%s", rec->device_type );
	    status = UTI_E_DEVICE;
	    break;
    }
    fclose( script_file );
    fclose( config_file );
    chmod( script, 06777 );
    chmod( config, 06777 );

    if( status != UTI_S_SUCCESS )
        return( UTI_E_FAILURE );

/*  If there were no filenames written into the script ( rlist->value = -1 ),
 *  delete the script and return failure
 */
    if( empty )
    {
	ERRload_struct( UTI, UTI_E_NOFILES, "%s", script );
	return( UTI_E_NOFILES );
    }

/***Do a stat on each one of these files and check whether their size is
    Less than 11,000 characters. Since "find" (all unix shell commands for
    that matter) is failing for arguments size  
    more than that size, this fix is necessary --DONTU ***/

    status = stat(script, &stat_buf);
    if(status != 0)
    {
	_UTIdebug(( fname, "Script file <%s> not found!",script));
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", script );
        return( UTI_E_WRTSCR );
    }
    else if(stat_buf.st_size > 11000)
    {
	_UTIdebug(( fname, "Script file <%s> is TOO BIG: <%d>\n",
						script, stat_buf.st_size));

	if((UTI_MEDIA == C_TAPE) || 
	   (UTI_MEDIA == U_TAPE) || 
	   (UTI_MEDIA == TJB)    || 
	   (UTI_MEDIA == F_DISK))
	{
		normal_length = strlen(UTI_CLIENT_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	else
	{
		normal_length = strlen(UTI_SERVER_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	recommend = (int )(11000 / normal_length);

	ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d", "RESTORE", recommend );
        return( UTI_E_SCR_TOO_BIG );
    }

    if((UTI_MEDIA == C_TAPE) || 
       (UTI_MEDIA == U_TAPE) || 
       (UTI_MEDIA == TJB)    || 
       (UTI_MEDIA == F_DISK))
    {
    	status = stat(UTI_CONFIG, &stat_buf);
    	if(status != 0)
    	{
	  _UTIdebug(( fname, "Not using Config Script file <%s>\n",UTI_CONFIG));
	  /** We don't care if it doesn't exist **/
    	}
        else if(stat_buf.st_size > 11000)
        {
	  _UTIdebug(( fname, "Config Script file <%s> is TOO BIG: <%d>\n",
						UTI_CONFIG, stat_buf.st_size));

	  normal_length = strlen(UTI_SERVER_PATH) + 
				strlen(rlist->ci_file_name) + 2;

	  recommend = (int )(11000 / normal_length);

	  ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d", "RESTORE",recommend );
          return( UTI_E_SCR_TOO_BIG );
        }
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_build_backup_script( rlist, rec )
    UTIpending  rlist;
    UTIarch     rec;
{
    int		archive_no, normal_length=0, recommend=0;
    struct      stat stat_buf;

    static char *fname = "UTIu_build_backup_script";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    archive_no  = rlist->rstr.archive_no;

    script_file = fopen( UTI_SCRIPT, "w" );
    if( script_file == NULL )
    {
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_SCRIPT );
	return( UTI_E_WRTSCR );
    }

    switch( UTI_MEDIA )
    {
	case F_DISK:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n",UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
	    status = UTIu_archive_FDISK( UTIbackup, rlist, rec );
	    break;

    	case U_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n",UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
 	    status = UTIu_archive_UTAPE( UTIbackup, rlist, rec );
	    break;

	case C_TAPE:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n",UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
 	    status = UTIu_archive_CTAPE( UTIbackup, rlist, rec );
	    break;

	case M_TAPE:
 	    status = UTIv_archive_MTAPE( UTIbackup, rlist, rec );
	    break;

	case H_DISK:
	    status = UTIu_archive_HDISK( UTIbackup, rlist, rec );
	    break;

/***********Not supported
	case O_DISK:
	    status = UTIu_archive_ODISK( UTIbackup, rlist, rec );
	    break;

	case JUKE_BOX:
	    status = UTIu_archive_JUKEBOX( UTIbackup, rlist, rec );
	    break;
*************************/

	case CACHE:
	    status = UTIu_archive_CACHE( UTIbackup, rlist, rec );
	    break;

	case TJB:
            config_file = fopen( UTI_CONFIG, "w" );
            if( config_file == NULL )
            {
                _UTIdebug(( fname, "Can't open <%s>\n",UTI_CONFIG));
                ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_CONFIG );
                return( UTI_E_WRTSCR );
            }
          status = UTIu_archive_TJB( UTIbackup, rlist, rec );
          break;

	default:
	    ERRload_struct( UTI, UTI_E_DEVICE,"%s", rec->device_type );
	    status = UTI_E_DEVICE;
	    break;
    }
    fclose( script_file );
    fclose( config_file );
    if( status != UTI_S_SUCCESS )
        return( UTI_E_FAILURE );

/*  If there were no filenames written into the script ( rlist->state = -1 ),
 *	delete the script and return failure
 */
    if( empty )
    {
	ERRload_struct( UTI, UTI_E_NOFILES, "%s", UTI_SCRIPT );
	return( UTI_E_NOFILES );
    }

/*  Set privileges for the script
 */
    chmod( UTI_SCRIPT, 06777 );
    chmod( UTI_CONFIG, 06777 );

/***Do a stat on each one of these files and check whether their size is
    Less than 11,000 characters. Since "find" (all unix shell commands for
    that matter) is failing for arguments size  
    more than that size, this fix is necessary --DONTU ***/

    status = stat(UTI_SCRIPT, &stat_buf);
    if(status != 0)
    {
	_UTIdebug(( fname, "Script file <%s> not found!",UTI_SCRIPT));
	ERRload_struct( UTI, UTI_E_WRTSCR, "%s", UTI_SCRIPT );
        return( UTI_E_WRTSCR );
    }
    else if(stat_buf.st_size > 11000)
    {
	_UTIdebug(( fname, "Script file <%s> is TOO BIG: <%d>\n",
						UTI_SCRIPT, stat_buf.st_size));

	if((UTI_MEDIA == C_TAPE) || 
	   (UTI_MEDIA == U_TAPE) || 
	   (UTI_MEDIA == TJB)    || 
	   (UTI_MEDIA == F_DISK))
	{
		normal_length = strlen(UTI_CLIENT_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	else
	{
		normal_length = strlen(UTI_SERVER_PATH) + 
				strlen(rlist->ci_file_name) + 2;
	}
	recommend = (int )(11000 / normal_length);

	ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d","BACKUP", recommend );
        return( UTI_E_SCR_TOO_BIG );
    }

    if((UTI_MEDIA == C_TAPE) || 
       (UTI_MEDIA == U_TAPE) || 
       (UTI_MEDIA == TJB)    || 
       (UTI_MEDIA == F_DISK))
    {
    	status = stat(UTI_CONFIG, &stat_buf);
    	if(status != 0)
    	{
	  _UTIdebug(( fname, "Not using Config Script file <%s>\n",UTI_CONFIG));
	  /** We don't care if it doesn't exist **/
    	}
        else if(stat_buf.st_size > 11000)
        {
	  _UTIdebug(( fname, "Config Script file <%s> is TOO BIG: <%d>\n",
						UTI_CONFIG, stat_buf.st_size));

	  normal_length = strlen(UTI_SERVER_PATH) + 
				strlen(rlist->ci_file_name) + 2;

	  recommend = (int )(11000 / normal_length);

	  ERRload_struct( UTI, UTI_E_SCR_TOO_BIG, "%s%d", "BACKUP", recommend );
          return( UTI_E_SCR_TOO_BIG );
        }
    }

    if( OFF_LINE )
    {
	sprintf( utidir_name, "%sBACKUP.%d", UTI_CLIENT_PATH,archive_no );
        UTIreturn_info( utidir_name, rec->node.name, rec->label );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_archive_HDISK( utility, rlist, rec )
    int	  	utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int 	abnum;

    static char *fname = "UTIu_archive_HDISK";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else
	abnum = UTI_BACKUP;

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sDisk :%d", UTI_COMMENT_UNIX, H_DISK  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    strcpy( line, "find \\" );
    fprintf( script_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
	    if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) && 
	  	( rlist->size == 0 ) )
	    {
		rlist = rlist->next;
		continue;
	    }
	    empty = FALSE;
	    sprintf( line, "%s", UTI_SERVER_PATH );
	    strcat( line, rlist->ci_file_name );
  	    strcat( line, " \\" );
	    fprintf( script_file, "%s\n", line );
	}
	rlist = rlist->next;
    }
    sprintf( line, " -print 2>/usr/tmp/UTI.ERR | cpio -o > %s", UTI_SERVER_PATH );
    strcat( line, rec->saveset );
    strcat( line, " 2>&1" );
    fprintf( script_file, "%s\n", line );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}


UTIu_archive_CACHE( utility, rlist, rec )
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int  abnum;

    static char *fname = "UTIu_archive_CACHE";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else
	abnum = UTI_BACKUP;

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%s CAFS :%d", UTI_COMMENT_UNIX, CACHE );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    strcpy( line, "find \\" );
    fprintf( script_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
	    /*  Check for set item with no file checked in
	     */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
            sprintf( line, "%s", UTI_SERVER_PATH );
	    strcat( line, rlist->ci_file_name );
  	    strcat( line, " \\" );
	    fprintf( script_file, "%s\n", line );
	}
	rlist = rlist->next;
    }
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s", UTI_SERVER_PATH );
    strcat( line, rec->saveset );
    strcat( line, " 2>&1" );
    fprintf( script_file, "%s\n", line );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_archive_FDISK( utility, rlist, rec )
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int		abnum;

    static char *fname = "UTIu_archive_FDISK";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else 
	abnum = UTI_BACKUP;

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sFloppy :%d", UTI_COMMENT_UNIX, F_DISK  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX,UTI_CLIENT_SA );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    strcpy( line, "find \\" );
    fprintf( config_file, "%s\n", line );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
            sprintf( line, "%s", UTI_CLIENT_PATH );
            strcat( line, rlist->ci_file_name );
      	    strcat( line, " \\" );
	    fprintf( config_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

#if defined OS_SUNOS  || defined OS_SCO_UNIX || defined OS_SOLARIS
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o -O%s" , rec->device_name);
#elif defined OS_HPUX
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , rec->device_name);
#else
    strcpy( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o | to_flop" );
#endif
    fprintf( config_file, "%s\n", line );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_archive_UTAPE( utility, rlist, rec )
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int	 abnum;

    char *utname;

    static char *fname = "UTIu_archive_UTAPE";

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else 
	abnum = UTI_BACKUP;

    utname = UTname( rec->device_name );
    if( utname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sUnix Tape :%d", UTI_COMMENT_UNIX, U_TAPE  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    UTIposition( rec );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    strcpy( line, "find \\" );
    fprintf( config_file, "%s\n", line );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
            sprintf( line, "%s", UTI_CLIENT_PATH );
            strcat( line, rlist->ci_file_name );
	    strcat( line, " \\" );
	    fprintf( config_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

/* PS - commented. consider the device name based on the OS type
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) 
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | cpio -o -O%s", utname );
#elif defined OS_HPUX
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , rec->device_name);
#else
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O /dev/rmt/%s", utname );
#endif
**/
/* format the line differently for clix and non-clix machines PS-27 Mar 96*/

if (!(strcmp(rec->op_sys, "CLIX"))){
  if (!(strncmp(utname, "/dev/rmt/", 9)))
   sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O %s", utname );
  else
   sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O /dev/rmt/%s", utname );
}
else
  sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , utname);
 
    fprintf( config_file, "%s\n", line ); 
 
    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_archive_CTAPE( utility, rlist, rec )
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int  abnum;
    char *ctname;

    static char *fname = "UTIu_archive_CTAPE";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else
	abnum = UTI_BACKUP;

    ctname = UTname( rec->device_name );
    if( ctname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sTape :%d", UTI_COMMENT_UNIX, C_TAPE  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    UTIposition( rec );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    strcpy( line, "find \\" );
    fprintf( config_file, "%s\n", line );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
            sprintf( line, "%s", UTI_CLIENT_PATH );
            strcat( line, rlist->ci_file_name );
  	    strcat( line, " \\" );
	    fprintf( config_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( config_file, "%s\n", line );
    fprintf( script_file, "%s\n", line );

/* PS - commented. consider the device name based on the OS type
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) 
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | cpio -o -O%s", ctname );
#elif defined OS_HPUX
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , rec->device_name);
#else
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O /dev/rmt/%s", ctname);
#endif
**/
/* format the line differently for clix and non-clix machines PS-27 Mar 96*/
 
if (!(strcmp(rec->op_sys, "CLIX"))) {
  if (!(strncmp(ctname, "/dev/rmt/", 9))) 
   sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O %s", ctname );
  else
   sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O /dev/rmt/%s", ctname );
}
else
  sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , ctname);

    fprintf( config_file, "%s\n", line ); 

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_archive_TJB( utility, rlist, rec ) /** Tape Juke Box **/
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int	 abnum;

    char *utname;

    static char *fname = "UTIu_archive_TJB";

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else 
	abnum = UTI_BACKUP;

    utname = UTname( rec->device_name );
    if( utname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sTape Juke Box:%d", UTI_COMMENT_UNIX, TJB  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    UTIposition( rec );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    strcpy( line, "find \\" );
    fprintf( config_file, "%s\n", line );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
            sprintf( line, "%s", UTI_CLIENT_PATH );
            strcat( line, rlist->ci_file_name );
	    strcat( line, " \\" );
	    fprintf( config_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) 
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | cpio -o -O%s", utname );
#elif defined OS_HPUX
    sprintf( line, "-print 2>/usr/tmp/UTI.ERR | cpio -o > %s" , rec->device_name);
#else
    sprintf( line, " -print 2>>/usr/tmp/UTI.ERR | scpio -o -C 63488 -z 25 -O /dev/rmt/%s", utname );
#endif

    fprintf( config_file, "%s\n", line ); 
 
    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_HDISK( rlist, rec )
    UTIpending  rlist;
    UTIarch	rec;
{
    static 	char *fname = "UTIu_rstr_HDISK";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sDisk :%d", UTI_COMMENT_UNIX, H_DISK  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );
   
    sprintf( line, "cat %s", UTI_SERVER_PATH );
    strcat( line, rec->saveset );
    strcat( line, " | cpio -imud \\" );
    fprintf( script_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            sprintf( line, "\"%s", UTI_SERVER_PATH );

	    /*  If there is an old format name, use that name 
	     *  to get it out of the cpio file.
	     */
	    if( strlen( rlist->format.name ) > 0 )
		strcat( line, rlist->format.name );
	    else
                strcat( line, rlist->ci_file_name );
	    strcat( line, "\"" );
	    if( rlist->next != NULL )
	  	strcat( line, " \\" );
	    else
		strcat( line, " > /dev/null 2>&1" );
	    fprintf( script_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_FDISK( rlist, rec )
    UTIpending  rlist;
    UTIarch	rec;
{
    static 	char *fname = "UTIu_rstr_FDISK";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sFloppy :%d", UTI_COMMENT_UNIX, F_DISK  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

#if defined OS_SUNOS || defined OS_SCO_UNIX || defined OS_SOLARIS
    sprintf( line, "cpio -imud -I%s \\" , rec->device_name);
#elif defined OS_HPUX
    sprintf( line, "cat %s | cpio -imud\\" , rec->device_name);
#else
    strcpy( line, "fr_flop | cpio -imud \\" );
#endif
    fprintf( config_file, "%s\n", line );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            /*  If there is an old format name, use that name
             *  to get it out of the cpio file.
             */
            if( strlen( rlist->format.name ) > 0 )
                sprintf( line, "%s%s", UTI_CLIENT_PATH, rlist->format.name );
            else
                sprintf( line,"%s%s", UTI_CLIENT_PATH, rlist->ci_file_name );
	    if( rlist->next != NULL )
	  	strcat( line, " \\" );
	    fprintf( config_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_CACHE( rlist, rec )
    UTIpending  rlist;
    UTIarch	rec;
{

    static char *fname = "UTIu_rstr_CACHE";

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%s CAFS :%d", UTI_COMMENT_UNIX, CACHE );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    sprintf( line, "cat %s", UTI_SERVER_PATH );
    strcat( line, rec->saveset );
    strcat( line, " | cpio -imud \\" );
    fprintf( script_file, "%s\n", line );

    while( rlist != NULL )
    {
	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            sprintf( line, "\"%s", UTI_SERVER_PATH );
            /*  If there is an old format name, use that name
             *  to get it out of the cpio file.
             */
            if( strlen( rlist->format.name ) > 0 )
                strcat( line, rlist->format.name );
            else
                strcat( line, rlist->ci_file_name );
	    strcat( line, "\"" );
	    if( rlist->next != NULL )
	  	strcat( line, " \\" );
	    else
		strcat( line, " > /dev/null 2>&1" );
	    fprintf( script_file, "%s\n", line );
	}
	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_UTAPE( rlist, rec )
    UTIpending rlist;
    UTIarch    rec;
{
    char *utname;
 
    static	char *fname = "UTIu_rstr_UTAPE";
    static      char old_label[100]={0};
    static      int old_saveset= -1;
		int first_time = 1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if((rlist == NULL) && (rec == NULL)) /** Cleanup called by rstr_same_node**/
    {
	old_saveset = -1;
	old_label[0] = '\0';
	old_label[1] = '\0';
	_UTIdebug((fname,"Cleanup static variables\n"));
	return(UTI_S_SUCCESS);
    }

    utname = UTname( rec->device_name );
    if( utname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sUnix Tape :%d", UTI_COMMENT_UNIX, U_TAPE  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    if(!strcmp(rec->label,old_label) &&
	(atoi(rec->saveset) > old_saveset))
    {
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset:%d\n",rec->saveset,old_saveset));
        UTIrstr_position( rec,old_saveset,1 ); /** New funtion to support
						   NO-REWIND logic    **/
	old_saveset = atoi(rec->saveset);
    }
    else
    {
	old_saveset = atoi(rec->saveset);
	strcpy(old_label,rec->label);
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset=-1\n",rec->saveset));
	UTIrstr_position(rec,-1,0);
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );
  

    first_time = 1;
    while( rlist != NULL )
    {
 	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
    		if(first_time && ((rlist->format.val==3000) || 
       			   	  (rlist->format.val==2100) || 
       			   	  (rlist->format.val==0)))   
    		{
/* PS - commented. consider the device name based on the OS type
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX)
    			sprintf( line, 
			"cpio -imud -I%s %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#elif defined OS_HPUX
    			sprintf( line, 
			"cat %s | cpio -imud %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#else
    			sprintf( line, 
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#endif
**/
/* format the line differently for clix and non-clix machines
   PS-27 Mar 96*/
                if (!(strcmp(rec->op_sys, "CLIX"))){
                   if (!(strncmp(utname, "/dev/rmt/", 9))) {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I %s %s%s",
                        utname, UTI_CLIENT_PATH, rec->saveset );
                   } else {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s %s%s",
                        utname, UTI_CLIENT_PATH, rec->saveset );
                   }
                } else {
                        sprintf( line,
                        "cpio -imud -I%s %s%s",
                        utname, UTI_CLIENT_PATH, rec->saveset );
                }
    			fprintf( config_file, "%s\n", line );

    			sprintf( line, "cpio -idmv < %s%s  \\", 
					UTI_CLIENT_PATH,rec->saveset );
    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}
    		else if(first_time && (rlist->format.val>=3200)) 
				/** from version 3.2 onwards **/
    		{
/* PS - commented. consider the device name based on the OS type
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX)
    			sprintf( line, 
			"cpio -imud -I%s \\", utname);
#elif defined OS_HPUX
    			sprintf( line, "cat %s | cpio -imud\\" , utname);
#else
    			sprintf( line, 
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s \\", utname);
#endif
**/
/* format the line differently for clix and non-clix machines
   PS-27 Mar 96*/
                if (!(strcmp(rec->op_sys, "CLIX"))){
                   if (!(strncmp(utname, "/dev/rmt/", 9))) {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I %s \\", utname);
                   } else {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s \\", utname);
                   }
                } else {
                        sprintf( line,
                        "cpio -imud -I%s \\", utname);
                }
    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}

    		sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    		fprintf( script_file, "%s\n", line );
    		fprintf( config_file, "%s\n", line );

	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            /*  If there is an old format name, use that name
             *  to get it out of the cpio file.
             */
            if( strlen( rlist->format.name ) > 0 )
	    {
                sprintf( line, "%s%s", UTI_CLIENT_PATH,  rlist->format.name );
	    }
            else
  	    {
  	        sprintf( line, "%s%s", UTI_CLIENT_PATH, rlist->ci_file_name );
	    }
	    if( rlist->next != NULL )
		strcat( line," \\" );
	    fprintf( config_file, "%s\n", line );
	}
   	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_CTAPE( rlist, rec )
    UTIpending rlist;
    UTIarch    rec;
{
    char *ctname;
 
    static char *fname = "UTIu_rstr_CTAPE";
    static      char old_label[100]={0};
    static      int old_saveset= -1;
		int first_time = 1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if((rlist == NULL) && (rec == NULL)) /** Cleanup called by rstr_same_node**/
    {
	old_saveset = -1;
	old_label[0] = '\0';
	old_label[1] = '\0';
	_UTIdebug((fname,"Cleanup static variables\n"));
	return(UTI_S_SUCCESS);
    }

    ctname = UTname( rec->device_name );
    if( ctname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sTape :%d", UTI_COMMENT_UNIX, C_TAPE  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    if(!strcmp(rec->label,old_label) &&
        (atoi(rec->saveset) > old_saveset))
    {
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset:%d\n",rec->saveset,old_saveset));
        UTIrstr_position( rec,old_saveset,1 ); /** New funtion to support
                                                   NO-REWIND logic    **/
	old_saveset = atoi(rec->saveset);
    }
    else
    {
        old_saveset = atoi(rec->saveset);
        strcpy(old_label,rec->label);
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset=-1\n",rec->saveset));
        UTIrstr_position(rec,-1,0);
    }
  
    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    first_time = 1;
    while( rlist != NULL )
    {
 	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
    		if(first_time && ((rlist->format.val==3000) ||
       		    		  (rlist->format.val==2100) ||
       		    		  (rlist->format.val==0)))
    		{
/* PS - commented. consider the device name based on the OS type
    			sprintf( line, 
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX)
			"cpio -imud  -I%s %s%s", 
				ctname, UTI_CLIENT_PATH, rec->saveset );
#elif defined (OS_HPUX)
			"cat %s | cpio -imud %s%s", 
				ctname, UTI_CLIENT_PATH, rec->saveset );
#else
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s %s%s", 
				ctname, UTI_CLIENT_PATH, rec->saveset );
#endif
**/
/* format the line differently for clix and non-clix machines
   PS-27 Mar 96*/
                if (!(strcmp(rec->op_sys, "CLIX"))){
                   if (!(strncmp(ctname, "/dev/rmt/", 9))) {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I %s %s%s",
                        ctname, UTI_CLIENT_PATH, rec->saveset );
                   } else {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s %s%s",
                        ctname, UTI_CLIENT_PATH, rec->saveset );
                   }
                } else {
                        sprintf( line,
                        "cpio -imud -I%s %s%s",
                        ctname, UTI_CLIENT_PATH, rec->saveset );
                }
    			fprintf( config_file, "%s\n", line );

    			sprintf( line, "cpio -idmv < %s%s \\", 
					UTI_CLIENT_PATH, rec->saveset );
    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}
    		else if(first_time && (rlist->format.val>=3200))
						/**From 3.2 onwards **/
    		{
/* PS - commented. consider the device name based on the OS type
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) 
    			sprintf( line, 
			"cpio -imud -I%s \\",ctname );
#elif defined(OS_HPUX)
    			sprintf( line, 
			"cat %s | cpio -imud  \\",ctname );
#else
    			sprintf( line, 
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s \\",ctname );
#endif
**/
/* format the line differently for clix and non-clix machines
   PS-27 Mar 96*/
                if (!(strcmp(rec->op_sys, "CLIX"))){
                   if (!(strncmp(ctname, "/dev/rmt/", 9))) {
                        sprintf( line,
                        "scpio -idmv -C 63488 -z 25 -I %s \\", ctname);
                   } else {
                      sprintf( line,
                      "scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s \\", ctname);
                   }
                } else {
                        sprintf( line,
                        "cpio -imud -I%s \\", ctname);
                }

    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}

    		sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    		fprintf( script_file, "%s\n", line );
    		fprintf( config_file, "%s\n", line );

	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            /*  If there is an old format name, use that name
             *  to get it out of the cpio file.
             */
            if( strlen( rlist->format.name ) > 0 )
                sprintf( line, "%s%s", UTI_CLIENT_PATH, rlist->format.name );
            else
                sprintf( line, "%s%s", UTI_CLIENT_PATH, rlist->ci_file_name );
	    if( rlist->next != NULL )
		strcat( line," \\" );
	    fprintf( config_file, "%s\n", line );
	}
   	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIu_rstr_TJB( rlist, rec )
    UTIpending rlist;
    UTIarch    rec;
{
    char *utname;
 
    static	char *fname = "UTIu_rstr_TJB";
    static      char old_label[100]={0};
    static      int old_saveset= -1;
		int first_time = 1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if((rlist == NULL) && (rec == NULL)) /** Cleanup called by rstr_same_node**/
    {
	old_saveset = -1;
	old_label[0] = '\0';
	old_label[1] = '\0';
	_UTIdebug((fname,"Cleanup static variables\n"));
	return(UTI_S_SUCCESS);
    }

    utname = UTname( rec->device_name );
    if( utname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_UNIX, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sTape Juke Box:%d", UTI_COMMENT_UNIX, TJB  );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_UNIX, UTI_CLIENT_SA );

    if(!strcmp(rec->label,old_label) &&
	(atoi(rec->saveset) > old_saveset))
    {
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset:%d\n",rec->saveset,old_saveset));
        UTIrstr_position( rec,old_saveset,1 ); /** New funtion to support
						   NO-REWIND logic    **/
	old_saveset = atoi(rec->saveset);
    }
    else
    {
	old_saveset = atoi(rec->saveset);
	strcpy(old_label,rec->label);
	_UTIdebug((fname,"call UTIrstr_position rec->saveset:%s, old_saveset=-1\n",rec->saveset));
	UTIrstr_position(rec,-1,0);
    }

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );
  

    first_time = 1;
    while( rlist != NULL )
    {
 	if( rlist->state != -1 )
	{
            /*  Check for set item with no file checked in
             */
            if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
                ( rlist->size == 0 ) )
            {
                rlist = rlist->next;
                continue;
            }
    		if(first_time && ((rlist->format.val==3000) || 
       			   	  (rlist->format.val==2100) || 
       			   	  (rlist->format.val==0)))   
    		{
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) 
    			sprintf( line, 
			"cpio -imud -I%s %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#elif defined(OS_HPUX)
    			sprintf( line, 
			"cat %s | cpio -imud  %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#else
    			sprintf( line, 
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s %s%s",
		    			utname, UTI_CLIENT_PATH, rec->saveset );
#endif
    			fprintf( config_file, "%s\n", line );

    			sprintf( line, "cpio -idmv < %s%s  \\", 
					UTI_CLIENT_PATH,rec->saveset );
    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}
    		else if(first_time && (rlist->format.val>=3200)) 
				/** from version 3.2 onwards **/
    		{ 
#if defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX)
    			sprintf( line, 
			"cpio -imud -I%s \\", utname);
#elif defined(OS_HPUX)
    			sprintf( line, 
			"cat %s | cpio -imud \\", utname);
#else
    			sprintf( line, 
			"scpio -idmv -C 63488 -z 25 -I /dev/rmt/%s \\", utname);
#endif
    			fprintf( config_file, "%s\n", line );
			first_time = 0;
    		}

    		sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    		fprintf( script_file, "%s\n", line );
    		fprintf( config_file, "%s\n", line );

	    empty = FALSE;
	    rlist->rstr.restore_no = UTI_GROUP_NO;
            /*  If there is an old format name, use that name
             *  to get it out of the cpio file.
             */
            if( strlen( rlist->format.name ) > 0 )
	    {
                sprintf( line, "%s%s", UTI_CLIENT_PATH,  rlist->format.name );
	    }
            else
  	    {
  	        sprintf( line, "%s%s", UTI_CLIENT_PATH, rlist->ci_file_name );
	    }
	    if( rlist->next != NULL )
		strcat( line," \\" );
	    fprintf( config_file, "%s\n", line );
	}
   	rlist = rlist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/* This routine positions UTAPE or CTAPE to the input saveset position
 */
UTIposition( rec )
   UTIarch  rec;
{
    char *dname;

    static char *fname = "UTIposition";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    dname = UTname( rec->device_name );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );
       

#if ! (defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))

    /* mt and rewind not supported for non-CLIX machines.
       IGI - 12 Jul 94 */
    if( strcmp( rec->saveset, "0" ) == 0 )
    {
	strcpy( line, "mt -f /dev/rmt/" );
	strcat( line, dname );
	strcat( line, " rewind 2>/usr/tmp/UTI.ERR" );
   	fprintf( config_file, "%s\n", line );
    } 
    else
    {
        strcpy( line, "mt -f /dev/rmt/" );
        strcat( line, dname );
        strcat( line, "n" );
        strcat( line, " fsf " );
        strcat( line, rec->saveset );
        fprintf( config_file, "%s 2>/usr/tmp/UTI.ERR\n", line );
    }
#endif

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/** The following function has been written for supporting NO-REWIND tape
    devices (UT and CT) while restoring archives & backups. 
    dname (devicename) is made to default to
    NO-REWIND device (Example: mt6n) after NFM 2.3.0.7 version -DEP
**/
UTIrstr_position( rec, old_saveset, offset )
   UTIarch  rec;
   int old_saveset, offset;
{
    char *dname;
    int dname_size;
    int current_saveset;
    int relative_movement;
	

    static char *fname = "UTIrstr_position";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    dname = UTname( rec->device_name );

    sprintf( line, "%sPROCESSING BLOCK", UTI_COMMENT_UNIX );
    fprintf( script_file, "%s\n", line );
    fprintf( config_file, "%s\n", line );

    current_saveset = atoi(rec->saveset);
    _UTIdebug((fname, "Current_saveset: %d, old_saveset: %d\n", current_saveset,old_saveset));
       
#if ! (defined(OS_SUNOS)    || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))

    /* mt and rewind not supported for non-CLIX machines
       IGI - 12 Jul 94 */
    if( (current_saveset==0) || 
        (old_saveset == -1)  
      )
    {
	dname_size = strlen(dname);
	if(dname[dname_size-1] == 'n')  
	{
		/** delete the last 'n' for device name **/
		dname[dname_size-1] = '\0';  
	}
	strcpy( line, "mt -f /dev/rmt/" );
	strcat( line, dname );
	strcat( line, " rewind " );
   	fprintf( config_file, "%s 2>/usr/tmp/UTI.ERR\n", line );
    _UTIdebug(( fname, "Tape rewind: %s\n", line));
	if(current_saveset > 0)
	{
		strcat(dname,"n"); /** append the last "n" back again **/
		strcpy( line, "mt -f /dev/rmt/" );
		strcat( line, dname );
		strcat( line, " fsf " );
		strcat( line, rec->saveset);
   		fprintf( config_file, "%s 2>/usr/tmp/UTI.ERR\n", line );
    _UTIdebug(( fname, "Absolute Tape Move: %s\n", line));
	}
    } 
    else if((old_saveset >= 0) && (current_saveset > old_saveset)) 
    {
	relative_movement = current_saveset - old_saveset - offset;

     	if(relative_movement == 0) /** no need to move **/
	    sprintf(line,"#mt -f /dev/rmt/%s fsf %d",dname,relative_movement);
	else
	    sprintf(line,"mt -f /dev/rmt/%s fsf %d 2>/usr/tmp/UTI.ERR",dname,relative_movement);

/**old code -DEP
        strcpy( line, "mt -f /dev/rmt/" );
        strcat( line, dname );
        strcat( line, " fsf " );
        strcat( line, rec->saveset );
**/
        fprintf( config_file, "%s\n", line );
    _UTIdebug(( fname, "Relative Tape Move: %s\n", line));
    }
#endif

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
