#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "UTIstruct.h"
#include "UTIdef.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

int     empty;
char    line[132];
char    command[132];
char    utidir_name[132];
char    *MTname();
char	*UTIgood_vax_file();

FILE    *script_file;

UTIv_archive_MTAPE( utility, rlist, rec )
    int		utility;
    UTIpending  rlist;
    UTIarch	rec;
{
    int	 abnum;

    char *mtname;

    static char *fname = "UTIv_archive_MTAPE";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
	abnum = UTI_ARCHIVE;
    else 
	abnum = UTI_BACKUP;

    mtname = MTname( rec->device_name );
    if( mtname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_VMS, UTI_UTILITY, abnum );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sMagnetic Tape :%d", UTI_COMMENT_VMS, M_TAPE );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_VMS, UTI_CLIENT_SA );

    strcpy( line, "$ on error then goto quit" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, 
	"$ set message/nofacility/noidentification/noseverity/notext" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set noon" );
    fprintf( script_file, "%s\n", line );    

    fprintf( script_file, "$ allocate %s\n", mtname );    

    if( strcmp( rec->saveset, "0") == 0 )
    {
    /*  Case of new tape */
        strcpy( line, "$ ini " );
        strcat( line, mtname );
        strcat( line, rec->label );
        strcat( line, " " );
        strcat( line, rec->label );
        fprintf( script_file, "%s\n", line );
    }
    strcpy( line, "$ mount/foreign " );
    strcat( line, mtname );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ backup/norewind/ignore=label_processing - " );
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

            sprintf( line, "%s", UTI_CLIENT_PATH );
	    strcat( line, UTIgood_vax_file( rlist->ci_file_name ) );
	    strcat( line, ";0" );
	    if( rlist->next == NULL )
	 	strcat( line, " -" );
	    else
		strcat( line, ",-" );
	    fprintf( script_file, "%s\n", line );
	}

	rlist = rlist->next;
    }
    strcpy( line, mtname );
    strcat( line, rec->saveset );
    strcat( line, "/save" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$quit:" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set message/facility/ident/sev/text " );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set on" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ dismount/nounload " );
    strcat( line, mtname );
    fprintf( script_file, "%s\n", line );

    fprintf( script_file, "$ deallocate %s\n", mtname );    

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIv_rstr_MTAPE( rlist, rec )
    UTIpending rlist;
    UTIarch    rec;
{
    char *mtname;
    char *tmptr;
 
    static char *fname = "UTIv_rstr_MTAPE";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    mtname = MTname( rec->device_name );
    if( mtname == NULL )
	return( UTI_E_FAILURE );

    sprintf( line, "%s%s :%d", UTI_COMMENT_VMS, UTI_UTILITY, UTI_RESTORE );
    fprintf( script_file, "%s\n", line );

    sprintf( line, "%sMagnetic Tape :%d", UTI_COMMENT_VMS, M_TAPE );
    fprintf( script_file, "%s\n", line );

    UTIscript_header( script_file, rec, UTI_COMMENT_VMS, UTI_CLIENT_SA );

    strcpy( line, "$ on error then goto quit " );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set message/nofacility/noidentification/noseverity/notext" );
    fprintf( script_file, "%s\n", line );

    fprintf( script_file, "$ allocate %s\n", mtname );    

    strcpy( line, "$ set noon" );
    fprintf( script_file, "%s\n", line );    

    strcpy( line, "$ mount/foreign " );
    strcat( line, mtname );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ backup/rewind/ignore=label_processing " );
    strcat( line, mtname );
    strcat( line, rec->saveset );
    strcat( line, "/save/new/select=(-" );
    fprintf( script_file, "%s\n", line );

    while( rlist != NULL )
    {
        /*  Check for set item with no file checked in
         */
        if( ( strcmp( rlist->set_indicator, "Y" ) == 0 ) &&
            ( rlist->size == 0 ) )
        {
            rlist = rlist->next;
            continue;
        }
        /*  Must strip device off the filename */
        sprintf( command, "%s%s", UTI_CLIENT_PATH, rlist->ci_file_name);
	tmptr = strchr( command, ':' );
	if( tmptr != NULL )
	{
	    ++tmptr;
	    strcpy( line, tmptr );
	}
	else
  	    strcpy( line, UTIgood_vax_file( command ) );

	if( rlist->next != NULL )
	    strcat( line, ",-" );
	else
	    strcat( line, " )-" );
    
        empty = FALSE;
        rlist->rstr.restore_no = UTI_GROUP_NO;

	fprintf( script_file, "%s\n", line );
	rlist = rlist->next;
    }
    sprintf( line, " %s", UTI_CLIENT_PATH );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$quit:" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set message/facility/ident/sev/text " );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ set on" );
    fprintf( script_file, "%s\n", line );

    strcpy( line, "$ dismount/nounload " );
    strcat( line, mtname );
    fprintf( script_file, "%s\n", line );

    fprintf( script_file, "$ deallocate %s\n", mtname );    

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

char*
MTname( text )
  char *text;
{
/*  Get tape drive name in 'name:' format 
 */
	char str[10];
	char *ret;
	int  len;
        int  i;

	strcpy( str, text );

/*  Search for embedded blanks
 */
    	len = strlen( text );
        for( i=0; i<len; ++i)
	{
	    if( str[i] == ' ' )
	    {
		UTIreq_err( UTI_E_DEVICE, text );
		return( NULL );
	    }
   	}      

	len = strlen( text );
	if( str[len-1] != ':' )
	    strcat( str, ":" );

	ret = strcpy( (char*)malloc( strlen(str) + 1 ), str );
	return( ret );
}

char*
UTIgood_vax_file( file )
    char *file;
{
    char tmp_file[80];
    char *ret;
    int  len;

    strcpy( tmp_file, file );

    len = strlen( tmp_file ) - 1;
    if( tmp_file[ len ] != '.' )
    {
	if( strchr( tmp_file, '.' ) == NULL )
            strcat( tmp_file, "." );
    }
    ret = (char*) malloc( strlen( tmp_file )+1 );
    strcpy( ret, tmp_file );

    return( ret );
}
