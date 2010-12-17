#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

char	 *strcpy();
char	 *strchr();

/* This routine process status results from using 'system' to spawn
 * a command. The return for 'system' varies in UNIX and VMS but
 * this routine forces a good return to 0 and a bad return to 1 for
 * both operating systems.
*/
UTIVsys_stat( stat )
    int  stat;
{
    int  return_status;

    return_status = 0;

    if( stat != 196609 && stat != 1 )
	return_status = 1;

    return( return_status );
}
/* Check to see if a file exists in "[]uti.dbg"; if it is there,
 * turn debug on.
 */
debug_setup( NFMserver_dbg )
    srvdbg *NFMserver_dbg;
{
    FILE   *fopen();
    FILE   *dbg_file;

    int	   toggle;
    int    i;

    char   ch;
    char   file_name[50];

    srvdbg link;
    srvdbg savedlist;
    srvdbg listend;

    savedlist = listend = NULL;

    dbg_file = fopen( NFM_SERVER_DEBUG_FILE, "r" );
    if( dbg_file == NULL )
	return( 0 );
    UTIdebug = 1;    

    UTIconsole = fopen( UTILITY_DEBUG_FILE, "w" );

/*  The []nfm_srv.dbg file contains the server debugs that we want to
 *  turn on.  The debug is in the format of <# output_file> for each of the
 *  four possible subsystems - NFM NET SQL MEM. The debug is read in
 *  the order of NFM NET SQL MEM from []nfm_srv.dbg
 */

    while( i = fscanf( dbg_file, "%d %s", &toggle, file_name ) >0 )
    {
	ch = fgetc( dbg_file );

        link = (srvdbg) malloc ( sizeof( struct server_dbg ) );
	link->val = toggle;
        strcpy( link->file_name, file_name );
        if( savedlist == NULL )
            savedlist = listend = link; /* first link */
        else
        {
            listend->next = link;
            listend = link;
        }
    } /* end while */
    fclose( dbg_file );
    *NFMserver_dbg = savedlist;
}

/*  This routine asks user to mount labels and prepare for OFF-line 
 *  media access.
 */
UTIVprepare_media( hdr )
    script_header hdr;
{
    char  input[80];

    fprintf( stdout,  "NFMutil :  Mount label <%s> on drive <%s>\n", 
   	     hdr->label, hdr->device );
    fprintf( stdout,
        "NFMutil :  Press <Return> to continue OR <quit> to interrupt \n");

    fgets( input, 81, stdin );
    if( input[0] == 'q' )
    {
	fprintf( stdout, "NFMutil :  Quit ... \n" );
	return( UTI_E_FAILURE );
    }
    _UTI_dbg( "%s", "Exit UTIVprepare_media :" );
    return( UTI_S_SUCCESS );

}
/*  Routine to print header values read from input script 
 */
UTIVprint_header( hdr )
    script_header hdr;
{
    _UTI_dbg( "UTIVprint_header : utility   <%s>", hdr->utility );
    _UTI_dbg( "UTIVprint_header : location  <%s>", hdr->location );
    _UTI_dbg( "UTIVprint_header : saveset   <%s>", hdr->saveset );
    _UTI_dbg( "UTIVprint_header : server    <%s>", hdr->server );
    _UTI_dbg( "UTIVprint_header : env       <%s>", hdr->env );
    _UTI_dbg( "UTIVprint_header : username  <%s>", hdr->username );
    _UTI_dbg( "UTIVprint_header : passwd    <%s>", hdr->passwd );
    _UTI_dbg( "UTIVprint_header : protocol  <%s>", hdr->protocol );
    _UTI_dbg( "UTIVprint_header : sa number <%s>", hdr->sa_number );
    _UTI_dbg( "UTIVprint_header : device    <%s>", hdr->device );
    _UTI_dbg( "UTIVprint_header : label     <%s>", hdr->label );
    _UTI_dbg( "UTIVprint_header : group     <%s>", hdr->group );

}

/* Routine to get string beyond colon */

UTIVpast_colon( rec, ret_str ) 
    char *rec;
    char *ret_str;
{
    int  i;
    int  j;
    int  len;

    char meat[50];
    char tmpr[80];

    strcpy( tmpr, rec );

    len = strlen( tmpr ) - 1; /* minus newline */
    for( i=0; i<len; ++i )
    {
	if( tmpr[i] != ':' )
	    continue;
	else
	{
	    ++i;
	    for( j=0; j+i<len; ++j )
		meat[j] = tmpr[i+j];
	    break;
	}
    }

    meat[j] = 0;
    strcpy( ret_str, meat );
}

UTIVupcase( str )
    char *str;
{
/* Translate the string into uppercase.
 */

    int i;
    char c;

    for( i=0; ; ++i )
    {
	c = *(str + i);

	if( c == (char) 0 )
	    break;
	else if( (c >= 'a') && (c <= 'z') )
	    *(str + i) = c - 'a' + 'A';
    }
}
