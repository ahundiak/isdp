#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

long _UTICget_owner_info(char *file,long *uid,long *gid);
long _UTICset_owner_info(char *file,long uid,long gid);
long _UTICset_uid_gid( long uid, long gid);
long gl_uid, gl_gid;

UTICexecute_script( str )
    char *str;
{
    long   status;
    struct stat buf;
    char   command[256];
    long src_uid, src_gid;

    _UTI_dbg( "%s", "Enter UTICexecute_script : ");
    _UTI_dbg( "UTIexecute_script : Script <%s>", str );
/* Get the uid and gid  for self */
    gl_uid=src_uid = getuid();
    gl_gid=src_gid = getgid();

    status = UTICmerge_files();
    if( status != UTI_S_SUCCESS )
    {
        _UTI_dbg( "UTIexecute_script : Bad Merge Script <0x%.8x>", status );
	UTICerror( UTI_E_MERGE_SCRIPT );
    	return( UTI_E_MERGE_SCRIPT );
    }

/*  See if script exists.
 */
    if( stat( str, &buf ) != 0 )
    {
	_UTI_dbg( "UTIexecute_script : Cannot find <%s>", str );
	UTICerror( UTI_E_BADSCRIPT, str );
	return( UTI_E_FAILURE );
    }
    chmod( str, 06777 );
/**    sprintf( command,"%s > /dev/null 2>&1", str ); **/

    sprintf( command,"%s ", str );  /** New method **/ 
    
    _UTI_dbg( "UTIexecute_script : script <%s>", command );

    unlink("/usr/tmp/UTI.ERR"); /** remove error file before execution **/


    if(UTILITY != UTI_BACKUP && UTILITY != UTI_ARCHIVE )
    	_UTICset_uid_gid(-1,-1);
    status = system( command );
    _UTI_dbg( "UTIexecute_script : execute script status <%d>", status );    
    if( UTICsys_stat( status ) != 0 )
    {
	UTICerror( UTI_E_EXESCRIPT, str );
	return( UTI_E_FAILURE );
    }
    _UTICset_uid_gid(src_uid,src_gid);

    status = stat("/usr/tmp/UTI.ERR", &buf);

    chmod("/usr/tmp/UTI.ERR", 00666);

    if((status == 0) && (buf.st_size > 0))
    {
	UTICerror(UTI_E_EXESCRIPT, str );	
	return( UTI_E_FAILURE );
    }

    unlink("/usr/tmp/UTI.ERR");
    _UTI_dbg( "%s", "UTIexecute_script : SUCCESSFUL" );
    return( UTI_S_SUCCESS );
}

UTICexecute_group( str, dbg )
    char   *str;
    srvdbg dbg;
{
    int    i;
    int    no_copies = 1;
    int	   all_are_ok = 1;
    long   status;

    char   script_name[50];
    char   config_name[15];
    char   ch;  
    char   old_device[50];
    char   old_label[50];
    char   final_rewind[100];
    char   command[MAXSTR+1];

    char   *ret;

    strptr UTICparsecommand();
    strptr scripts;

    script_header hdr = NULL;

    FILE   *script_file;
    FILE   *fopen();

    _UTI_dbg( "%s", "Enter UTIexecute_group :" );
    _UTI_dbg( "UTIexecute_group : Group name <%s>", str );

    chmod( str, 06777 );
    script_file = fopen( str, "r" );
    if( script_file == NULL )
    {
	_UTI_dbg( "UTIexecute_group : Cannot open <%s>",str );
	UTICerror( UTI_E_OPENSCRIPT, str );
	return( UTI_E_FAILURE );
    }
    
    old_label[0] = '\0';
    old_device[0] = '\0';
    old_device[1] = '\0';
    old_device[2] = '\0';
    old_device[3] = '\0'; /** Just in case **/

    all_are_ok = 1;
    while( i = fscanf( script_file, "%s", script_name ) > 0 )
    {
	ch = fgetc( script_file );

/*  Read header information from script
 */
	_UTI_dbg( "UTIexecute_group : Read script <%s>", script_name );
        fprintf( stdout, "Nfmutil ( configurable file for <%s> - <RETURN> if not configuring ) ---> " );
        ret = fgets( command, MAXSTR, stdin );
        if( ( ret == NULL )  || strlen( command ) <= 1 )
            strcpy( UTI_CONFIG, "" );
        else
        {
            scripts = UTICparsecommand( command );
            strcpy( UTI_CONFIG, scripts->str );
        }
        status = UTICread_script( script_name, &hdr );
        if( status != UTI_S_SUCCESS )
	{
	    _UTI_dbg( "UTIexecute_group : Error reading script <%s>",
		script_name );
	    all_are_ok = 0;
	    continue;
	}

        status = UTICtalk( hdr, dbg );
   	if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    free( &hdr );
	    _UTI_dbg( "%s", "UTIexecute_group : Error in connection" );
	    all_are_ok = 0;
	    continue;
	}

        _UTI_dbg( "%s", "UTIexecute_group : Try to prepare media" );
      
	if(strcmp(old_label, hdr->label) ||
	   strcmp(old_device, hdr->device) ||
	   strncmp(hdr->device,"mt", 2) ||
	   hdr->device[3] != 'n')	
        	status = UTICprepare_media( hdr );


        if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    free( &hdr );
	    _UTI_dbg( "%s", "UTIexecute_group : Error preparing media" );
	    all_are_ok = 0;
	    continue;
	}
	strcpy(old_label,hdr->label);
	strcpy(old_device,hdr->device);

        fprintf( stdout, "Nfmutil :  Executing Utility Script <%s>\n",
		 script_name );

    	status = UTICexecute_script( script_name );
 	_UTI_dbg( "UTIexecute_group : Execute script status <%d>",status );
        if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    free( &hdr );
	    _UTI_dbg( "UTIexecute_group : Error executing <%s>",script_name );
	    all_are_ok = 0;
	    continue;
	}

 	_UTI_dbg( "UTIexecute_group : UTI_GROUP_NO <%d>",UTI_GROUP_NO );

/*  Update server database
 */
	status = UTICupdate_db( UTI_GROUP_NO, status, UTI_RESTORE,no_copies );
        if( status != UTI_S_SUCCESS )
	{
	    _UTI_dbg( "UTIexecute_group : Bad update_db <%d>", status );
            UTICerror( UTI_E_FAILURE, script_name );
	    all_are_ok = 0;
	}
	else
	{
	    _UTI_dbg( "UTIexecute_group : Good update_db <%d>", status );
       	    UTICerror( UTI_S_SUCCESS, script_name );
	    unlink( script_name );
	    if(strcmp(UTI_CONFIG, "") == 0)
	    {
		sprintf(config_name, "RSTR_C.%d", UTI_GROUP_NO);
		unlink(config_name);
	    }
  	    else
		unlink(UTI_CONFIG);
	    _UTI_dbg( "UTIexecute_group : Deleting saveset <%s>",hdr->saveset);
	    unlink( hdr->saveset );
	}

	status = NFMRterminate();
/*	free( &hdr ); */
    } /* end RESTORE GROUP */
	
    if((old_device[0] == 'm') && 
       (old_device[1] == 't'))
    {
        if(old_device[3] == 'n') /** If old device is no-rewind, make it **/
	    old_device[3] = '\0';/** rewind device before you rewind   **/

    	sprintf(final_rewind, "mt -f /dev/rmt/%s rewind ", old_device);
        strcat(final_rewind, " 2>/usr/tmp/UTI.ERR"); /* PS */

    	status = system(final_rewind);
	if(status != 0) {
            _UTI_dbg( "UTIexecute_group : WARNING! Unable to rewind tape device <%s>", old_device); 
            fprintf(stdout, "Nfmutil: WARNING! Unable to rewind tape device <%s>\n", old_device);
	}
    }
    fclose( script_file );

    if(all_are_ok == 1)
    	unlink( str );

    _UTI_dbg( "%s", "Exit UTIexecute_group :" );
    return( UTI_S_SUCCESS );
}
/*  This routine reads the given input script, searching for important
 *  data. The data is always within a comment and if it is important,
 *  it appears after the first ':' occurrence. The data is ordered in
 *  sequential records as follows :
 *      NFM utility.location.saveset :
 *	NFM server :
 *	NFM environment :
 * 	NFM username :
 *	NFM password : 
 * 	NFM protocol :
 *	NFM storage number :
 *	NFM device name :
 *	NFM label : 
 */

UTICread_script( script, return_header )
    char          *script;
    script_header *return_header;
{
    int    header_line;

    char   rec[80];

    strptr scripts;
    strptr UTICparsecommand();

    script_header hdr  = NULL;

    FILE   *script_file;

    _UTI_dbg( "UTICread_script : script <%s>", script );
 
    chmod( script, 06777 );
    script_file = fopen( script, "r" );
    if( script_file == NULL )
    {
    	UTICerror( UTI_E_OPENSCRIPT, script );
	return( UTI_E_FAILURE );
    }

/*  Read all script lines starting with comment character '#'
 */
    header_line = 0;
    hdr = (script_header)malloc( sizeof( struct header ) );

    while( fgets( rec, 81, script_file ) != (char*)NULL )
    {
	if( rec[0] != '#' )
	    break;
	++header_line;
	switch( header_line )
	{
	    case UTI_HDR_UTILITY :
	    	UTICpast_colon( rec, hdr->utility );
		break;

	    case UTI_HDR_LOCATION :
		UTICpast_colon( rec, hdr->location );
	 	break;

	    case UTI_HDR_SAVESET :
		UTICpast_colon( rec, hdr->saveset );
		break;

	    case UTI_HDR_SERVER :
		UTICpast_colon( rec, hdr->server );
		break;

	    case UTI_HDR_ENV :
		UTICpast_colon( rec, hdr->env );
		break;

	    case UTI_HDR_USERNAME :
		UTICpast_colon( rec, hdr->username );
		break;

	    case UTI_HDR_PASSWD :
		UTICpast_colon( rec, hdr->passwd );
		break;

	    case UTI_HDR_PROTOCOL :
		UTICpast_colon( rec, hdr->protocol );
		break;

	    case UTI_HDR_SA_NUMBER :
		UTICpast_colon( rec, hdr->sa_number  );
		UTI_CLIENT_SA = atol( hdr->sa_number );
	        _UTI_dbg( "UTICread_script : UTI_CLIENT_SA <%d>", 
			   UTI_CLIENT_SA );
		break;

	    case UTI_HDR_DEVICE :
		UTICpast_colon( rec, hdr->device );
		break;

	    case UTI_HDR_LABEL :
		UTICpast_colon( rec, hdr->label );
		break;

	    case UTI_HDR_GROUP :
		UTICpast_colon( rec, hdr->group );
		UTI_GROUP_NO = atoi( hdr->group );
		break;

	    default :
		break;
	} /* end switch */
    } /* end while */

    fclose( script_file );   

/*  If the script was created by a combined client/server image, there
 *  will be no server information.  Prompt the user for that now.
 */
    if( strcmp( hdr->server, "" ) == 0 )
    {
	fprintf( stdout, "Nfmutil ( NFM server name ? ) ---> " );
        fgets( UTImsg, 81, stdin );
	if(strcmp(UTImsg, "\n")==0)
	{
		fprintf( stdout, "Nfmutil: Error. NFM server name is required to continue processing." );
		return(UTI_E_FAILURE);
	}
        scripts = UTICparsecommand( UTImsg );
	strcpy( hdr->server, "nfms_" );
        strcat( hdr->server, scripts->str );
        _UTI_dbg( "UTICread_script : server <%s>", hdr->server );
    }
    *return_header = hdr;

    return( UTI_S_SUCCESS );
}

UTICmerge_files( )
{
    int		status;

    FILE	*fopen();
    FILE	*config;    
    FILE	*script;
    FILE	*new_script;

    char	script_rec[132];
    char	config_rec[132];
    char	script_name[132];
    char 	config_name[132];
    char	new_script_name[132];
    char	str[200];
    long	uid, gid;
  
    strcpy( config_name, UTI_CONFIG );
    _UTI_dbg( "UTImerge_files : UTILITY <%d>", UTILITY );
    if( UTILITY == UTI_ARCHIVE )
    {
	sprintf( script_name, "%ARCHIVE.%d", UTI_GROUP_NO );
	sprintf( new_script_name, "ARCHIVE_N.%d", UTI_GROUP_NO );
	if( strcmp( UTI_CONFIG, "" ) == 0 )
  	    sprintf( config_name, "ARCHIVE_C.%d", UTI_GROUP_NO );
    }
    else if( UTILITY == UTI_BACKUP )
    {
	sprintf( script_name, "BACKUP.%d", UTI_GROUP_NO );
	sprintf( new_script_name, "BACKUP_N.%d", UTI_GROUP_NO );
        if( strcmp( UTI_CONFIG, "" ) == 0 )
  	    sprintf( config_name, "BACKUP_C.%d", UTI_GROUP_NO );
    }
    else
    {
	sprintf( script_name, "RSTR.%d", UTI_GROUP_NO );
	sprintf( new_script_name, "RSTR_N.%d", UTI_GROUP_NO );
        if( strcmp( UTI_CONFIG, "" ) == 0 )
  	    sprintf( config_name, "RSTR_C.%d", UTI_GROUP_NO );
    }

    _UTI_dbg( "UTImerge_files : Script_name <%s>", script_name );
    _UTI_dbg( "UTImerge_files : Config_name <%s>", config_name );
    _UTI_dbg( "UTImerge_files : New_name <%s>", new_script_name );

    script = fopen( script_name, "r" );
    if( script == NULL )
    {	
        _UTI_dbg( "UTImerge_files : Cannot open <%s>", script_name );
        UTICerror( UTI_E_OPENSCRIPT, script_name );
 	return( UTI_E_OPENSCRIPT );
    }

    config = fopen( config_name, "r" );
    if( config == NULL )
    {
        _UTI_dbg( "UTImerge_files : Cannot open <%s>", config_name );
        UTICerror( UTI_E_OPENSCRIPT, config_name );
 	return( UTI_E_OPENSCRIPT );
    }
/*  Read First Comment Record
 */
    fgets( config_rec, 81, config );

    chmod( new_script_name, 06777 );
  
    new_script = fopen( new_script_name, "w" );
    if( new_script == NULL )
    {
        _UTI_dbg( "UTImerge_files : Cannot open <%s>", new_script_name );
        UTICerror( UTI_E_OPENSCRIPT, new_script_name );
 	return( UTI_E_OPENSCRIPT );
    }

    while( fgets( script_rec, 81, script ) != (char*)NULL )    
    {
	if( strncmp( script_rec, "#  PROCESSING BLOCK", 19 ) == 0 )
	{
	    while( fgets( config_rec, 81, config ) != (char*)NULL )
	    {
		if( strncmp( config_rec, "#  PROCESSING BLOCK", 19 ) == 0 )
		    break;
		else
		    fprintf( new_script, "%s", config_rec );
	    }
	}
	else
  	    fprintf( new_script, "%s", script_rec );
    }

    fclose( new_script );
    fclose( script );
    fclose( config );

    _UTI_dbg( "UTImerge_files : Script_name <%s>", script_name );
    _UTI_dbg( "UTImerge_files : Config_name <%s>", config_name );
    _UTI_dbg( "UTImerge_files : New_name <%s>", new_script_name );

/* Get the owner and group of the original script */

    if(UTILITY != UTI_BACKUP && UTILITY != UTI_ARCHIVE )
    {
	status = _UTICget_owner_info(script_name,&uid,&gid);
	if(status != UTI_S_SUCCESS)
	{
    		_UTI_dbg( "UTICget_owner_info : Cannot get UID and GID for file <%s>", script_name );
	}
	else
	{
		gl_uid = uid;
		gl_gid = gid;
		status = _UTICset_owner_info(new_script_name,uid,gid);
		if(status != UTI_S_SUCCESS)
		{
    			_UTI_dbg( "UTICset_owner_info : Cannot set UID and GID for file <%s>", new_script_name );
		}
	}
    } 

    sprintf( str, "mv %s %s", new_script_name, script_name );
    _UTI_dbg( "UTImerge_files : Str <%s>", str );    
    status = system( str );
    if( UTICsys_stat( status ) != 0 )
    {
        _UTI_dbg( "UTImerge_files : Status from move <%d>", status );    
	UTICerror( UTI_E_EXESCRIPT, new_script );
	return( UTI_E_EXESCRIPT );
    }

    return( UTI_S_SUCCESS );
}


long _UTICget_owner_info(file,uid,gid)
	char *file;
	long *uid, *gid;
{
	long status;
	struct stat buf;

	status = stat(file,&buf);
	if(status)
	{
        	_UTI_dbg( "UTImerge_files : Status from move <%d>", status );    
		UTICerror( UTI_E_EXESCRIPT, "stat" );
		return( UTI_E_EXESCRIPT );
		
	}

	*uid = buf.st_uid;
	*gid = buf.st_gid;
	return(UTI_S_SUCCESS);
}

long _UTICset_owner_info(file,uid,gid)
	char *file;
	long uid, gid;
{

	long status;

	status = chown(file,uid,gid);
	if(status)
	{
        	_UTI_dbg( "UTImerge_files : Status from move <%d>", status );    
		UTICerror( UTI_E_EXESCRIPT, "chown" );
                fprintf(stdout, "chown status: %d\n", status);
		return( UTI_E_EXESCRIPT );
	}
	return(UTI_S_SUCCESS);
}
long _UTICset_uid_gid(uid,gid)
	long uid, gid;
{
	if (gid > 0 ) setgid(gid);
	{
		setgid(gl_gid);
	}
	if (uid > 0 ) setuid(uid);
	else
	{
		setuid(gl_uid);
	}
}
