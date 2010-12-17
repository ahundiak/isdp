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
UTICsys_stat( stat )
    int  stat;
{
    int  return_status;

    return_status = 0;

/*In the below line 'if UNIX' changed to 'ifdef OS_UNIX' - SSRS 28 Dec 93 */
#ifdef OS_UNIX
    if( stat != 0 )
	return_status = 1;
#endif
#if VMS
    if( stat != 196609 && stat != 1 )
	return_status = 1;
#endif

    return( return_status );
}
/* Check to see if a file exists in "/usr/tmp/uti_dbg"; if it is there,
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

    dbg_file = fopen( "/usr/tmp/uti_dbg", "r" );
    if( dbg_file == NULL )
	return( 0 );
    UTIdebug = 0;    

/*  The /usr/tmp/uti_dbg file contains the server debugs that we want to
 *  turn on.  The debug is in the format of #:output for each of the
 *  four possible subsystems - NFM NET SQL MEM. The debug is read in
 *  the order of NFM NET SQL MEM from /usr/tmp/uti_dbg.
 */

    while( i = fscanf( dbg_file, "%d %s", &toggle, file_name ) >0 )
    {
	ch = fgetc( dbg_file );

	/* First record is client debug file */
	if( !UTIdebug )
	{
	    UTIdebug   = 1;
	    UTIconsole = fopen( file_name, "w" );
	    continue;
	}
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
UTICprepare_media( hdr )
    script_header hdr;
{
    char   input[80], tjb_spec[120];
    int	   loc, tjb_len,tjb_slot;
    long UTICprepare_TJB_media();
    long status; 

    _UTI_dbg( "UTICprepare_media : device <%s>", hdr->device );
    _UTI_dbg( "UTICprepare_media : label <%s>",  hdr->label );

    _UTI_dbg( "%s", "Enter UTICprepare_media :" );
    loc = atoi( hdr->location );

    switch( loc )
    {
	case  F_DISK :
	    fprintf(stdout,"Nfmutil :  Insert formatted floppy into drive \n");
	    fprintf( stdout,
 	    "Nfmutil :  Press <Return> to continue OR <quit> to interrupt \n");
	    break;

	case  M_TAPE :
	    fprintf( stdout,  "Nfmutil :  Mount label <%s> on drive <%s>\n", 
	   	     hdr->label, hdr->device );
	    fprintf( stdout,
 	    "Nfmutil :  Press <Return> to continue OR <quit> to interrupt \n");
	    break;

	case  C_TAPE :
	    fprintf( stdout,  "Nfmutil :  Insert tape <%s> into drive <%s>\n", 
		     hdr->label, hdr->device );
	    fprintf( stdout,
 	    "Nfmutil :  Press <Return> to continue OR <quit> to interrupt \n");
	    break;

	case  U_TAPE :
	    fprintf( stdout,  "Nfmutil :  Mount label <%s> on drive <%s>\n", 
		     hdr->label, hdr->device );
	    fprintf( stdout,
 	    "Nfmutil :  Press <Return> to continue OR <quit> to interrupt \n");
	    break;

	case  TJB :
	    fprintf( stdout, "Nfmutil :  Input TJB specification [TJB01]: ");

    	    fgets( tjb_spec, 81, stdin );
	    tjb_len = strlen(tjb_spec);

	    if(tjb_len > 1)
	    {
	       tjb_spec[tjb_len - 1] = '\0';/** Over write that new line char**/
	    }
	    else if(tjb_len == 1)
	       strcpy(tjb_spec, "TJB01"); /** Default is TJB01 **/

	    status = UTICprepare_TJB_media(tjb_spec, hdr);

	    if(status != UTI_S_SUCCESS)
	    {
		fprintf(stdout, "Nfmutil :  Unable to prepare tape label <%s> on drive <%s>\n", hdr->label, hdr->device);
		return(UTI_E_FAILURE);
	    }
	    fprintf( stdout,
 	    "Nfmutil :  Input Slot address for tape <%s> OR <quit> to interrupt \n\t  (0 if tape is already IN the drive): ", hdr->label);
    	    fgets( input, 81, stdin );
	    if(input[0] == 'q')
	    {
		fprintf( stdout, "Nfmutil :  Canceling !!!\n" );
		return(UTI_E_FAILURE);
	    }
	    if(!isdigit(input[0]))
	    {
		fprintf( stdout, "Nfmutil :  Invalid Slot address <%s>\n",input);
		return(UTI_E_FAILURE);
	    }
		
	    if(isdigit(input[1]))
	    {
		input[2] = '\0';
		tjb_slot = atoi(input);
		if((tjb_slot < 0) || (tjb_slot > 10))
	    	{
			fprintf( stdout,"Nfmutil :  Invalid Slot address <%d>\n",tjb_slot);
			return(UTI_E_FAILURE);
	    	}
	    }
	    else
	    {
		input[1] = '\0';
		tjb_slot = atoi(input);
	    }
	    status = UTICload_TJB_tape(tjb_slot, tjb_spec);
	    if(status != UTI_S_SUCCESS)
	    {
		fprintf( stdout,"Nfmutil :  Unable to load tape from Slot <%d> to Slot <0> on <%s>\n",tjb_slot, tjb_spec);
		return(UTI_E_FAILURE);
	    }
	    return(UTI_S_SUCCESS);
	    /**break;**/

     	default :
	    fprintf( stdout,  "Nfmutil :  Illegal destination \n" );
	    return( UTI_E_FAILURE );
    }
    fgets( input, 81, stdin );
    if( input[0] == 'q' )
    {
	fprintf( stdout, "Nfmutil :  Cancelling !!!\n" );
	return( UTI_E_FAILURE );
    }
	
    _UTI_dbg( "%s", "Exit UTICprepare_media :" );
    return( UTI_S_SUCCESS );

}
/*  Routine to print header values read from input script 
 */
UTICprint_header( hdr )
    script_header hdr;
{
    _UTI_dbg( "UTICprint_header : utility   <%s>", hdr->utility );
    _UTI_dbg( "UTICprint_header : location  <%s>", hdr->location );
    _UTI_dbg( "UTICprint_header : saveset   <%s>", hdr->saveset );
    _UTI_dbg( "UTICprint_header : server    <%s>", hdr->server );
    _UTI_dbg( "UTICprint_header : env       <%s>", hdr->env );
    _UTI_dbg( "UTICprint_header : username  <%s>", hdr->username );
    _UTI_dbg( "UTICprint_header : passwd    <%s>", hdr->passwd );
    _UTI_dbg( "UTICprint_header : protocol  <%s>", hdr->protocol );
    _UTI_dbg( "UTICprint_header : sa number <%s>", hdr->sa_number );
    _UTI_dbg( "UTICprint_header : device    <%s>", hdr->device );
    _UTI_dbg( "UTICprint_header : label     <%s>", hdr->label );

}
/* Routine to get string beyond colon */

UTICpast_colon( rec, ret_str ) 
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

UTICupcase( str )
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

