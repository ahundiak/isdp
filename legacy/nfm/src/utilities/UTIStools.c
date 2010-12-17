#include "machine.h"
#include <stdio.h>
#include <time.h>
#include "UNIX_or_VMS.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "NFMstruct.h"
#include "DEBUG.h"

#define  BUFFER_SIZE 1000

char  	 *tmp_pwd;
char 	 uti_string[1024];
extern   struct  NFMglobal_st  NFMglobal;

/*  This routine generates a unique tape label using day of year and 
 *  how many tapes have already been generated on this date.
 */

UTIgen_label( label )
    char *label;
{
    int  tapeno;
    long seconds;
    long status;

    char *tmplabel;
    struct tm *mytime;    

    MEMptr sql_buffer = NULL;
    char   **data_ptr;

    static char *fname = "UTIgen_label";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    tmplabel = (char*) malloc (20);

    time( &seconds );
    mytime = localtime( &seconds );    
    sprintf( label, "%.3d", mytime->tm_yday );
    strcpy( tmplabel, label );
    strcat( tmplabel, "000" );

    sprintf( uti_string, 
	"SELECT MAX(n_label) FROM nfmarchives WHERE n_label BETWEEN '%s%s' AND '%s%s'", label, "000", label, "999" );
    status = SQLquery( uti_string, &sql_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
  	tapeno = atoi( tmplabel );
    else 
    {
	MEMbuild_array( sql_buffer );
	data_ptr = (char**) sql_buffer->data_ptr;
        strcpy( tmplabel,  data_ptr[0]);
        tapeno = atoi( tmplabel ) + 1;
	if( tapeno == 1 )	/* kludge for INFORMIX initialize problem */
	{
	    sprintf( label, "%.3d", mytime->tm_yday );
	    strcpy( tmplabel, label );
	    strcat( tmplabel, "000" );
	    tapeno = atoi( tmplabel ) + 1;	    
	}
    }
    sprintf( tmplabel, "%.6d", tapeno );
    strcpy( label, tmplabel );
    MEMclose( &sql_buffer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine generates the current date in mm:dd:yy format.
 */
char*
UTIgen_date()
{
    char *now_date;
    
    static char *fname = "UTIgen_date";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    now_date = (char*)malloc(50);
    NFMget_RISdatetime(now_date);

/**************** Directly call RISdatetime 1/22/92 --Dontu
    now_date = (char*)malloc(11);
    time( &now_time );
    the_time = localtime( &now_time );

/ *    if( NFMglobal.date_format == 1 ) * / / * ANSI date format * /
        sprintf( now_date, "%.4d.%.2d.%.2d", (the_time->tm_year)+1900,
                (the_time->tm_mon)+1, the_time->tm_mday);
/ *    else
        sprintf( now_date, "%.2d/%.2d/%.2d", (the_time->tm_mon)+1, 
	     the_time->tm_mday, the_time->tm_year );
* /
******************/

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( now_date );
}

/*  This routine generates the current date in hr:mn:ss format.
 */
char*
UTIgen_time()
{
    char now_date[20];
    char *ret_time;

    long now_time;
     
    struct tm *the_time;

    static char *fname = "UTIgen_time";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    ret_time = (char*)malloc(9);

    time( &now_time );
    the_time = localtime( &now_time );
    sprintf( now_date, "%.2d:%.2d:%.2d", the_time->tm_hour, 
	     the_time->tm_min, the_time->tm_sec );
    strcpy( ret_time, now_date );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( ret_time );
}

/*  This routine builds the NFM filename for an item from the given
 *  table number and item number. It also takes into consideration
 *  if the user has supplied a name for the file.
 */
UTIbuild_file_name
    ( table_no, file_num, host_file_name, destination)
    int     table_no;
    int	    file_num;
    char    *host_file_name;
    char    *destination;

{
    int     i, j;
    char    number [15];
    char    tab_no [8];
    char    rem_file [8];

    static  char *fname = "UTIbuild_file_name";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy (tab_no,   "0000000");
    strcpy (rem_file, "0000000");

    _UTIdebug(( fname, "File_no : <%d>\n", file_num ));

    j = 0;
    sprintf (number, "%d", table_no);
    for (i = (7 - strlen (number)); i < 7; ++i)
	{
	tab_no [i] = number [j];
	++j;
	}

    j = 0;
    sprintf (number, "%d", file_num);
    for (i = (7 - strlen (number)); i < 7; ++i)
	{
	rem_file [i] = number [j];
	++j;
	}

    if( strcmp( host_file_name, "" ) != 0 )
	strcpy( destination, host_file_name );
    else
    {
        strcpy( destination, tab_no );
        strcat( destination, rem_file );
    }
    _UTIdebug(( fname, "file_name <%s>\n", destination ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine returns the next highest archive number entry from
 *  the NFMarchives table.
 */
UTIget_next_spot( archive_no )
    int  *archive_no;
{
    long status;

    MEMptr sql_buffer = NULL;
    char   **data_ptr;

    static char *fname = "UTIget_next_spot";

    strcpy( uti_string, "SELECT MAX(n_archiveno) FROM nfmarchives" );
    status = SQLquery( uti_string, &sql_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	*archive_no = 1;
	MEMclose( &sql_buffer );
	return( UTI_S_SUCCESS );
    } 
    MEMbuild_array( sql_buffer );
    data_ptr = (char**) sql_buffer->data_ptr;
    *archive_no = (atoi( data_ptr[0] ) )+1;
    if( *archive_no < 0 )
	*archive_no = 1;
    MEMclose( &sql_buffer );

    _UTIdebug(( fname, "archive_no <%d>\n", *archive_no ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/* This routine process status results from using 'system' to spawn
 * a command. The return for 'system' varies in UNIX and VMS but
 * this routine forces a good return to 0 and a bad return to 1 for
 * both operating systems.
*/
UTIsys_stat( stat )
    int  stat;
{
    int  return_status;

    static char *fname = "UTIsys_stat";

    return_status = 0;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "status <%d>\n", stat ));

#if OS_UNIX
    if( stat != 0 )
	return_status = 1;
#endif
#if VMS
    if( stat != 196609 && stat != 1 )
	return_status = 1;
#endif

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( return_status );
}
/* This routine checks the size of the NFM.ERR file to see if errors
 * were written from the just executed shell script.  If the file is
 * size 0, no errors were written.  Otherwise, there were errors.
 */
UTIsys_err()
{
    struct stat buf;
    long   status;

    status = stat( "NFM.ERR", &buf );
#if VMS
    if( status == -1 )
	return( 0 );
    else
	return( buf.st_size );
#endif
#if OS_UNIX
    if( status != 0 )
	return( 0 );
    else
	return( buf.st_size );
#endif		
}

/* Routine to malloc and strcpy from MEMbuf locations into local
 * structures.
 */
char*
UTIload( membuf )
    char *membuf;
{
    char *str;
    int  len;

    len = strlen( membuf );
    if( len == 0 || membuf == 0 )
    {
	str = (char*) malloc(2);
	strcpy( str, "" );
    }
    else
    {
        str = (char*) malloc ( len+1 );
        strcpy( str, membuf );
    }
    return( str );
}

char*
UTIup( text )
  char *text;
{
	char *str;
	char *ret;

	str = (char*) malloc( strlen( text ) +1 );
	ret = str;
	for( ; *text != '\0'; )
	    *str++ = toupper( *text++ );
        *str = '\0';

	return( ret );
}

/*  This routine checks returns the input path with an ending slash 
 *  if the op_sys is UNIX.
 */
char*
UTIgood_path( path, op_sys )
    char *path;
    char *op_sys;
{
    char tmp_path[80];
    char *ret;

    static char *fname = "UTIgood_path";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy( tmp_path, path );

    _UTIdebug(( fname, "op_sys <%s>\n", op_sys ));
    _UTIdebug(( fname, "in_path <%s>\n", path ));

    if(( strcmp(op_sys, "CLIX") != 0) && (strcmp(op_sys, "UNIX") != 0))
    {
        ret = strcpy( (char*) malloc( strlen( path )+1 ), path );
        return( ret );
    }

    if( strlen( tmp_path ) == 0 )
	strcpy( tmp_path, "./" );
    else if( tmp_path[ strlen( tmp_path )-1 ] != '/' )
        strcat( tmp_path, "/" );
    ret = strcpy( (char*) malloc( strlen( tmp_path )+1 ), tmp_path );

    _UTIdebug(( fname, "out_path <%s>\n", ret ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( ret );
}

UTIlowcase( str )
    char *str;
{
/* Translate the string into lowercase.  Don't want any of them critters
 * with their permanently stuck caps lock keys to suffer.
 */

    int i;
    char c;

    for( i=0; ; ++i )
    {
	c = *(str + i);

	if( c == (char) 0 )
	    break;
	else if( (c >= 'A') && (c <= 'Z') )
	    *(str + i) = c - 'A' + 'a';
    }
}

UTIupcase( str )
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

UTIprint_list( link )
    UTIlist link;
{
    static char *fname = "** struct LIST **";

    _UTIdebug(( fname, "  list->name  -> %s\n", link->name ));
    _UTIdebug(( fname, "  list->no    -> %d\n", link->no ));
 
    _UTIdebug(( fname, "%s\n", "** end struct LIST **" ));
}

UTIprint_pending_files( link )
    UTIpending link;
{
    static char *fname = "** struct PENDING_FILES **";

    UTIprint_restore( link->rstr );
    UTIprint_gen( link->node );
    _UTIdebug(( fname, "  label        -> %s\n", link->label ));
    _UTIdebug(( fname, "  saveset      -> %s\n", link->saveset ));
    _UTIdebug(( fname, "  ci_file_name -> %s\n", link->ci_file_name ));
    UTIprint_gen( link->cat );
    UTIprint_gen( link->item );
    UTIprint_fs(  link->home );
    _UTIdebug(( fname, "  rev          -> %s\n", link->rev ));
    _UTIdebug(( fname, "  ver          -> %d\n", link->ver ));
    _UTIdebug(( fname, "  file_no      -> %d\n", link->file_no ));
    _UTIdebug(( fname, "  state        -> %d\n", link->state ));
    _UTIdebug(( fname, "  flow_state   -> %d\n", link->flow_state ));
    _UTIdebug(( fname, "  file_size    -> %d\n", link->size ));
    UTIprint_gen( link->type );
    _UTIdebug(( fname, "  set_indicator-> %s\n", link->set_indicator ));
    _UTIdebug(( fname, "  project_no   -> %d\n", link->project_no ));
    
    UTIprint_gen( link->format );

    _UTIdebug(( fname, "%s\n",  "** end struct PENDING_FILES **" ));
}
/*  Routine to print 'struct gen'
 */
UTIprint_gen( gs )
    struct gen gs;
{
    static char *fname =  "** struct GEN **";

    _UTIdebug(( fname, "  gen.name    -> %s\n", gs.name ));
    _UTIdebug(( fname, "  gen.val     -> %d\n", gs.val ));

    _UTIdebug(( fname, "%s\n",  "** end struct GEN **" ));
}
/*  Routine to print 'struct restore'
 */
UTIprint_restore( rt )
    struct restore rt;
{
    static char *fname = "** struct RESTORE **";

    _UTIdebug(( fname, "  rstr.archive_no    -> %d\n", rt.archive_no ));
    _UTIdebug(( fname, "  rstr.storage_no    -> %d\n", rt.storage_no ));
    _UTIdebug(( fname, "  rstr.restore_no   -> %d\n", rt.restore_no ));

    _UTIdebug(( fname, "%s\n",  "** end struct RESTORE **" ));
}
/*  Routine to print 'struct fs'
 */
UTIprint_fs( home )
    struct fs home;
{
    static char *fname = "** struct FS **";

    _UTIdebug(( fname, "  fs.node_name   -> %s\n", home.node_name ));
    _UTIdebug(( fname, "  fs.user_name   -> %s\n", home.user_name ));
    _UTIdebug(( fname, "  fs.passwd      -> %s\n", home.passwd ));
    _UTIdebug(( fname, "  fs.sano        -> %d\n", home.sano ));
    _UTIdebug(( fname, "  fs.path        -> %s\n", home.path )); 
    _UTIdebug(( fname, "  fs.device_type -> %s\n", home.device_type )); 
    _UTIdebug(( fname, "  fs.co_file_name-> %s\n", home.co_file_name ));
    _UTIdebug(( fname, "  fs.op_sys      -> %s\n", home.op_sys ));
    _UTIdebug(( fname, "  fs.mach_id     -> %s\n", home.mach_id ));
    _UTIdebug(( fname, "  fs.protocol    -> %d\n", home.protocol ));

    _UTIdebug(( fname, "%s\n",  "** end struct FS **" ));
}
/*  Routine to print 'struct nfmarchives'
 */
UTIprint_nfmarchives( ar )
    NFMarch ar;
{
    static char *fname = "** struct NFMARCHIVES **";

    _UTIdebug(( fname, "  archive_no-> %d\n", ar->archive_no ));
    _UTIdebug(( fname, "  label ->     %s\n", ar->label ));
    _UTIdebug(( fname, "  saveset ->   %s\n", ar->saveset ));
    _UTIdebug(( fname, "  storage_no-> %d\n", ar->storageno ));
    _UTIdebug(( fname, "  archive_path -> %s\n", ar->archive_path ));
    _UTIdebug(( fname, "  archive_date -> %s\n", ar->archive_date ));
    _UTIdebug(( fname, "  archive_method -> %s\n", ar->archive_method ));
    _UTIdebug(( fname, "  archive_copies -> %d\n", ar->archive_copies ));
    _UTIdebug(( fname, "  archive_size   -> %d\n", ar->archive_size ));
    _UTIdebug(( fname, "  no_vol         -> %d\n", ar->no_vol ));

    _UTIdebug(( fname, "%s\n",  "** end struct NFMARCHIVES **" ));
}

/*  Routine to print structure ARCHIVE_LOC
 */
UTIprint_archive_loc( srv )
    UTIarch srv;
{
    static char *fname = "** struct ARCHIVE_LOC **";

    _UTIdebug(( fname, "  label -> %s\n", srv->label ));
    _UTIdebug(( fname, "  saveset -> %s\n", srv->saveset ));
    UTIprint_gen( srv->node );
    _UTIdebug(( fname, "  user_name -> %s\n", srv->user_name ));
    _UTIdebug(( fname, "  password -> %s\n", srv->password ));
    _UTIdebug(( fname, "  path_name -> %s\n", srv->path_name ));
    _UTIdebug(( fname, "  device_type -> %s\n", srv->device_type ));
    _UTIdebug(( fname, "  device_name -> %s\n", srv->device_name ));
    _UTIdebug(( fname, "  op_sys -> %s\n", srv->op_sys ));
    _UTIdebug(( fname, "  protocol -> %d\n", srv->protocol ));

    _UTIdebug(( fname, "%s\n",  "** end struct ARCHIVE_LOC **"));
}

/*  Routine to print struct FILE_SPEC 
 */
UTIprint_file_spec( spec )
    UTIfiles spec;
{
    static char *fname = "** struct FILE_SPEC ** ";

    _UTIdebug(( fname, "  cat -> %s\n", spec->cat ));
    _UTIdebug(( fname, "  file -> %s\n", spec->file ));
    _UTIdebug(( fname, "  rev -> %s\n", spec->rev ));
    _UTIdebug(( fname, "  ver -> %d\n", spec->ver ));

    _UTIdebug(( fname, "%s\n",  "** end struct FILE_SPEC **" ));
}
/*  This routine copies the flist link to the rlink link.
 */
UTIcopy_link( link, list )
    UTIpending  link;
    UTIpending  list;
{
    link->rstr.archive_no   = list->rstr.archive_no;
    link->rstr.storage_no   = list->rstr.storage_no;
    link->rstr.restore_no  = list->rstr.restore_no;

    strcpy( link->node.name, list->node.name );
    link->node.val    	    = list->node.val;

    if (list->label != NULL)
    {
    link->label = 
	strcpy( (char*)malloc(strlen(list->label)+1),list->label );
    }
    if (list->saveset != NULL)
    {
    link->saveset      =
	strcpy( (char*)malloc(strlen(list->saveset)+1),list->saveset );
    }
    link->ci_file_name    =
	strcpy( (char*)malloc(strlen(list->ci_file_name)+1),
	list->ci_file_name );

    strcpy( link->cat.name, list->cat.name );
    link->cat.val      =             list->cat.val;

    strcpy( link->item.name, list->item.name );
    link->item.val     =             list->item.val;

    strcpy( link->home.node_name,    list->home.node_name );
    strcpy( link->home.user_name,    list->home.user_name );
    strcpy( link->home.passwd,       list->home.passwd );
    strcpy( link->home.path,         list->home.path );
    strcpy( link->home.co_file_name, list->home.co_file_name );
    strcpy( link->home.op_sys,       list->home.op_sys );
    strcpy( link->home.device_type,  list->home.device_type );
    strcpy( link->home.mach_id,      list->home.mach_id );
    link->home.protocol =            list->home.protocol;
    link->home.sano	=            list->home.sano;
    link->rev           = 
	strcpy( (char*)malloc(strlen(list->rev)+1),list->rev );
    link->ver          =             list->ver;
    link->file_no      =             list->file_no;
    link->state        =             list->state;
    link->flow_state   =             list->flow_state;
    link->size	       =             list->size;
    strcpy( link->type.name,         list->type.name );
    link->type.val     =             list->type.val;
    link->set_indicator=
     strcpy( (char*)malloc(strlen(list->set_indicator)+1),list->set_indicator);
    strcpy( link->format.name,	     list->format.name );
    link->format.val   = 	     list->format.val;
    link->project_no   = 	     list->project_no;
}

UTIpending
UTImake_list( )
{
    UTIpending  ret;

    ret = (UTIpending) malloc (sizeof( struct pending_files ) );

    ret->rstr.archive_no = 0;
    ret->rstr.storage_no = 0;
    ret->rstr.restore_no = 0;

    strcpy( ret->node.name, "" );
    ret->node.val 	 = 0;

    ret->label        = NULL;
    ret->saveset      = NULL;
    ret->ci_file_name = NULL;

    strcpy( ret->cat.name, "" );
    ret->cat.val      = 0;

    strcpy( ret->item.name, "" );
    ret->item.val     = 0;

    strcpy( ret->home.node_name, "" );
    strcpy( ret->home.user_name, "" );
    strcpy( ret->home.passwd, "" );
    strcpy( ret->home.path, "" );
    strcpy( ret->home.co_file_name, "" );
    strcpy( ret->home.op_sys, "" );
    strcpy( ret->home.mach_id, "" );
    ret->home.protocol= 0;
    ret->home.sano    = 0;

    ret->rev          = NULL;
    ret->ver          = 0;
    ret->file_no       = 0;
    ret->state        = 0;
    ret->flow_state   = 0;
    ret->next         = NULL;
    ret->size	      = 0;
    strcpy( ret->type.name, "" );
    ret->type.val     = 0;
    ret->set_indicator= NULL;
    strcpy( ret->format.name, "" );
    ret->format.val   = 0;
    ret->project_no   = 0;
    return( ret );
}

UTIarch
UTImake_rec( )
{
    UTIarch  ret;

    ret = (UTIarch) malloc (sizeof( struct archive_loc ) );

    ret->label        = NULL;
    ret->saveset      = NULL;
    strcpy( ret->node.name, "" );
    ret->node.val     = 0;
    ret->user_name    = NULL;
    ret->password     = NULL;
    ret->path_name    = NULL;
    ret->device_type  = NULL;
    ret->device_name  = NULL;
    ret->op_sys       = NULL;
    ret->protocol     = 0;

    return( ret );
}
/*  Set UTI integer protocol value given three different NFM char values
 *  bit 0 - set for XNS
 *  bit 1 - set for TCPIP
 *  bit 2 - set for DECnet
 */
UTIset_protocol( xns, tcpip, dec, net, nfs )
    char *xns;
    char *tcpip;
    char *dec;
    char *net;
    char *nfs;
{
    int  protocol;
    unsigned int  bit_xns   = 01;
    unsigned int  bit_tcpip = 02;
    unsigned int  bit_dec   = 04;
    unsigned int  bit_net   = 010;
    unsigned int  bit_nfs   = 020;

    static char *fname = "UTIset_protocol";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    protocol = 0;
    
    if( strcmp( xns,   "Y" ) == 0 )
    {
	protocol |= bit_xns;
	_UTIdebug(( fname, "xns set : protocol <%d>\n", protocol));
    }

    if( strcmp( tcpip, "Y" ) == 0 )
    {
	protocol |= bit_tcpip;
	_UTIdebug(( fname, "tcpip set : protocol <%d>\n", protocol));
    }

    if( strcmp( dec,   "Y" ) == 0 )
    {
	protocol |= bit_dec;
	_UTIdebug(( fname, "decnet set : protocol <%d>\n", protocol));
    }

    if( strcmp( net,   "Y" ) == 0 )
    {
	protocol |= bit_net;
	_UTIdebug(( fname, "net set : protocol <%d>\n", protocol));
    }

    if( strcmp( nfs,   "Y" ) == 0 )
    {
	protocol |= bit_nfs;
	_UTIdebug(( fname, "nfs set : protocol <%d>\n", protocol));
    }

    _UTIdebug(( fname, "protocol : <%d>\n", protocol ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( protocol );
}
/*  This routine takes the integer protocol that I created and
 *  determines if xns and/or tcpip and/or dec was set for that node.
 */
UTIunset_protocol( protocol, xns, tcp, dec, net, nfs )
    int  protocol;
    char *xns;
    char *tcp;
    char *dec;
    char *net;
    char *nfs;
{
    unsigned int  xns_on = 01;
    unsigned int  tcp_on = 02;
    unsigned int  dec_on = 04;
    unsigned int  net_on = 010;
    unsigned int  nfs_on = 020;

    static char *fname = "UTIunset_protocol";

    _UTIdebug(( fname, "protocol : <%d>\n", protocol ));

    strcpy( xns, "N" );
    strcpy( tcp, "N" );
    strcpy( dec, "N" );
    strcpy( net, "N" );
    strcpy( nfs, "N" );

    if( protocol & xns_on )
	strcpy( xns, "Y" );
    if( protocol & tcp_on )
	strcpy( tcp, "Y" );
    if( protocol & dec_on )
	strcpy( dec, "Y" );
    if( protocol & net_on )
	strcpy( net, "Y" );
    if( protocol & nfs_on )
	strcpy( nfs, "Y" );

    _UTIdebug(( fname, "xns : <%s>\n", xns ));
    _UTIdebug(( fname, "tcp : <%s>\n", tcp ));
    _UTIdebug(( fname, "dec : <%s>\n", dec ));
    _UTIdebug(( fname, "net : <%s>\n", net ));
    _UTIdebug(( fname, "nfs : <%s>\n", nfs ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine generates a unique saveset within the given 
 *  input label.
 */
UTIgen_saveset( archive_no, label, saveset, sa_no )
    int  archive_no;
    char *label;
    char *saveset;
    int  sa_no;
{
    int  setno;
    int  tmpno;
    int  constant;
    int  columns;
    int  cnt;
    int  status;

    char disk_label[20];

    MEMptr sql_buffer = NULL;
    char   **data_ptr;

    static char *fname = "UTIgen_saveset";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy( disk_label, label );
    setno   = 0;

/* We could have a DISK_A label for disk archives or a DISK_B label for
 * disk backups or DISK_O for optical disk backups. Must make sure the 
 * saveset is unique within these two labels. 
 */      
    if( strspn( "DISK_A", label ) == 6 || strspn( "DISK_B", label ) == 6 ||
        strspn( "DISK_O", label ) == 6 || strspn( "DISK_F", label ) == 6 ||
	strspn( "DISK_J", label ) == 6 || strspn( "DISK_C", label ) == 6 )
        strcpy( uti_string, "SELECT n_saveset FROM nfmarchives WHERE n_label IN ('DISK_A','DISK_B', 'DISK_C', 'DISK_O', 'DISK_F','DISK_J')");
    else
	sprintf( uti_string, "SELECT n_saveset FROM nfmarchives WHERE n_label = '%s'",label );
    status = SQLquery( uti_string, &sql_buffer, BUFFER_SIZE );
    if( status == SQL_S_SUCCESS )
    {
	MEMbuild_array( sql_buffer );
	data_ptr = (char**)sql_buffer->data_ptr;
	constant = sql_buffer->columns * sql_buffer->rows;
	columns  = sql_buffer->columns;
	for( cnt = 0;
		cnt < constant - columns;
		    cnt += columns )
	{
	    tmpno = atoi( data_ptr[cnt] );
	    if( setno < tmpno )
		setno = tmpno;
	}
	tmpno = atoi( data_ptr[constant - columns] );
	if( setno < tmpno )
	    setno = tmpno;
	setno = setno + 1;
        MEMclose( &sql_buffer );
    }
    _UTIdebug(( fname, "saveset : <%d>\n", setno ));
    sprintf( saveset, "%d", setno );

/*  Now insert a row into the table so this saveset number and label 
 *  will be not be used during this archival.
 */
    sprintf( uti_string, "INSERT INTO nfmarchives (n_archiveno,n_label,n_saveset,n_sano) VALUES (%d,'%s','%s',%d )", archive_no, label, saveset, sa_no );
    status = SQLstmt( uti_string );
    if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( UTI, UTI_E_UPDARCHIVES, NULL, NULL );
	return( UTI_E_UPDARCHIVES );
    }

    UTI_SS_ALLOCATED = 1;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine adds up the file sizes to get total archive size
 */
UTIget_archive_size( flist )
    UTIpending 	flist;
{
    int  	archive_size = 0;

    while( flist != NULL )
    {
	archive_size += flist->size;
	flist = flist->next;
    }
    return( archive_size );
}
/*  This routine, given the input device type sets the global 'UTI_MEDIA'
 *  and sets the global 'UTI_RSTR_NAME' which is used in the locally 
 *  written restore script name and the globals 'UTI_SERVER_PATH' which
 *  is the local reserved utility path.
 */
UTIset_media( device )
    char *device;
{
    static char *fname = "UTIset_media";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( strcmp( device, "HD") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_ON" );
	UTI_MEDIA = H_DISK;
    }
    else if( strcmp( device, "CA") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_ON" );
	UTI_MEDIA = CACHE;
    }
    else if( strcmp( device, "FD") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_OFF" );
	UTI_MEDIA = F_DISK;
    }
    else if( strcmp( device, "OD") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_ON" );
	UTI_MEDIA = O_DISK;
    }
    else if( strcmp( device, "UT") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_OFF" );
	UTI_MEDIA = U_TAPE;
    }
    else if( strcmp( device, "CT") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_OFF" );
	UTI_MEDIA = C_TAPE;
    }
    else if( strcmp( device, "MT") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_OFF" );
	UTI_MEDIA = M_TAPE;
    }
    else if( strcmp( device, "TJ") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_OFF" );
	UTI_MEDIA = TJB;
    }
    else if( strcmp( device, "MO") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_ON" );
	UTI_MEDIA = JUKE_BOX;
    }
    else if( strcmp( device, "WR") == 0 )
    {
	strcpy( UTI_RSTR_NAME, "RSTR_ON" );
	UTI_MEDIA = JUKE_BOX;
    }

    _UTIdebug(( fname, "UTI_MEDIA <%s>\n",device ));
    _UTIdebug(( fname, "UTI_RSTR_NAME <%s>\n",UTI_RSTR_NAME ));
    _UTIdebug(( fname, "UTI_SERVER_PATH <%s>\n",UTI_SERVER_PATH ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));
 
    return( UTI_S_SUCCESS );
}

char*
ODname( text )
  char *text;
{
/*  Get optical disk platter name in ':name:' format
 */
	char str[100];
	char *ret;
        int  i;
        int  len;

	strcpy( str, text );

/*  Search for embedded blanks
 */
    	len = strlen( text );
        for( i=0; i<len; ++i)
	{
	    if( str[i] == ' ' )
	    {
		ERRload_struct( UTI, UTI_E_DEVICE, "%s", text );
		return( NULL );
	    }
   	}      
	if( str[0] != ':' )
	{
	    strcpy( str, ":" );
	    strcat( str, text );
	}
	i = strlen( str );
	if( str[i-1] != ':' )
	    strcat( str, ":" );

	ret = strcpy( (char*)malloc( strlen(str) + 1 ), str );

	return( ret );
}

char*
UTname( text )
  char *text;
{
/*  Get tape drive name in 'name' format 
 */
	char str[80];
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
		ERRload_struct( UTI, UTI_E_DEVICE, "%s", text );
		return( NULL );
	    }
   	}      

	len = strlen( text );
	if( str[len-1] == ':' )
	    str[len-1] = 0;

		
	ret = strcpy( (char*)malloc( strlen(str) + 1 ), str );
	return( ret );
}


/*  This routine builds the NFM filename for an item from the given
 *  table number and item number.
 */
char*
UTIbuild_nfm_name( table_no, file_num )
    char    *table_no;
    char    *file_num;
{
    long    status;
    char    *ret_name;
    char    filename[100];

    static char *fname = "UTIbuild_nfm_name";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

/*  What follows is the old algorithm used before 2.0.1 

    sprintf (filename, "%4.4d%9.9d0", atol(table_no), atol(file_num) );
 
    for (i = 0; i < strlen (filename); ++i)
        if (filename [i] == ' ') filename [i] = '0';

    for (i = strlen (filename) - 1; i > 9;  --i)
        filename [i] = filename [i - 1];
 
    filename [8] = '.';

*/
    status = NFMnew_file_name( UTIuser_id, atoi(table_no), atoi(file_num),
			       filename );
    _UTIdebug(( fname, "NFMnew_file_name : <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
	return( NULL );

    _UTIdebug(( fname, "file_name : <%s>\n", filename ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));
  
    ret_name = (char*)malloc( strlen( filename ) + 1 );
    strcpy( ret_name, filename );
    return( ret_name );
}

UTIscript_header( script_file, rec, comment, sa_no  )
    FILE	*script_file;
    UTIarch	rec;
    char	*comment;
    int		sa_no;
{
    sprintf( uti_string, "%sSaveset :%s%s", comment, UTI_CLIENT_PATH,
	                  rec->saveset );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sNFM Server :%s", comment, UTIserver );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sNFM Environment :%s", comment, UTIenv );
    fprintf( script_file, "%s\n", uti_string );
 
    sprintf( uti_string, "%sNFM Username :%s", comment, UTIuser );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sNFM Password :%s", comment, UTIpasswd );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sNFM Protocol :%d", comment, rec->protocol );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sNFM Storage Number :%d", comment, sa_no );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sDevice Name :%s", comment, rec->device_name );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sLabel :%s", comment, rec->label );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%sGroup :%d", comment, UTI_GROUP_NO );
    fprintf( script_file, "%s\n", uti_string );

    sprintf( uti_string, "%s", comment );
    fprintf( script_file, "%s\n", uti_string );

    return( UTI_S_SUCCESS );
}
 
/*  This routine given a storage area number returns its associated
 *  path name.
 */
UTIget_client_path( )
{
    int    node_no;
    long   status;
    char   **sa_ptr;
    MEMptr buffer = NULL;

    static char *fname = "UTIget_client_path";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( uti_string, "SELECT n_pathname,n_nodeno FROM nfmstoragearea WHERE n_sano = %d", UTI_CLIENT_SA );
    status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( UTI, UTI_E_QUERYSA, "%d", UTI_CLIENT_SA );
	MEMclose( &buffer );
        return( UTI_E_QUERYSA );
    }

    MEMbuild_array( buffer );
    sa_ptr = (char**)buffer->data_ptr;
    strcpy( UTI_CLIENT_PATH, sa_ptr[0] );
    node_no = atoi( sa_ptr[1] );
    MEMclose( &buffer );

/*  Now get node information 
 */
    sprintf( uti_string, "SELECT n_opsys FROM nfmnodes WHERE n_nodeno= %d",
	     node_no );
    status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", node_no  );
	MEMclose( &buffer );
        return( UTI_E_QUERYNODE );
    }

    MEMbuild_array( buffer );
    sa_ptr = (char**)buffer->data_ptr;
    strcpy( UTI_ARCHIVE_OPSYS, sa_ptr[0] );
    MEMclose( &buffer );

    if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
        strcat( UTI_CLIENT_PATH, "/" );

    _UTIdebug(( fname, "UTI_CLIENT_PATH <%s>\n", UTI_CLIENT_PATH ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/* 
   Free the BIG BACK BONE GLOBAL linked list generated by UTIquery*  functions
   Created: 11/30/92
   Author:  DEP 
*/

UTIfree_pending_list(in_list)
UTIpending *in_list;
{
    char *fname="UTIfree_pending_list";
    UTIpending temp=NULL;

    _UTIdebug((fname, "Entry:in_list<%x>, *in_list <%x>\n", in_list, *in_list));

    while(*in_list)
    {
        _UTIdebug((fname, "in_list<%x>, *in_list <%x>\n", in_list, *in_list));
        temp = *in_list;
	(*in_list) = (*in_list)->next;
	temp->next = NULL;
        _UTIdebug((fname, "Free <%x>\n", temp));
	free(temp);
    }
}

/*************************************************************************** 
    This routine searches through the linked list of selected files for
    Archive, Backup, Or Restore for duplicates. If Duplicates are found
    an error status UTI_E_FAILURE is returned. The output parameters 
    first and second point to items in the linked list that collide in
    their ci_file_name field. If there are no duplicates, UTI_S_SUCCESS
    status is returned.

Created: DEP
Date   : 10/19/93
Version: 03040018
****************************************************************************/

UTIfind_duplicate_files(in_list, first, second, operation)
UTIpending in_list;       /**Input:  linked list of items **/
UTIpending *first;         /**Output: First Item that collides with other **/
UTIpending *second;        /**Output: Second Item that collides with first**/
char *operation;
{
	char *fname="UTIfind_duplicate_files";
	UTIpending temp=NULL, temp2=NULL;
	long status;

	temp = in_list;
	while (temp)
	{
	   _UTIdebug((fname, "Considering ... <%s>\n",  temp->ci_file_name));
	   temp2 = temp->next;
	   while(temp2)
	   {
	   	_UTIdebug((fname, "	Consider ... <%s>\n",  temp2->ci_file_name));
		if(strcmp(temp->ci_file_name, temp2->ci_file_name)==0)
		{
		   _UTIdebug((fname, "Item <%s.%s.%s> has the same checkin file name <%s> as the item <%s.%s.%s>!\n", temp->cat.name, temp->item.name, temp->rev,temp->ci_file_name,temp2->cat.name, temp2->item.name, temp2->rev));
		   status = UTI_E_DUP_ITEM;
		   ERRload_struct(UTI, status, "%s%s%s%s%s%s%s%s", temp->cat.name, temp->item.name, temp->rev, temp2->cat.name, temp2->item.name, temp2->rev, temp->ci_file_name, operation);
		   *first = temp;
		   *second = temp2;
		   return(status);
		}
		temp2 = temp2->next;
	   }
	   temp = temp->next;
	}
	_UTIdebug((fname, "No Duplicates were found, success!\n"));
	return(UTI_S_SUCCESS);
}

/** This function allocates num_bytes_more more to the original string,
    frees the original string and returns the address of the new string.
    Returns: Addr of New string
    Error:   (Char *) 0 **/

char *UTIalloc_more(ptr, num_bytes_more)
char *ptr;  		/** Original String **/
long num_bytes_more; 	/** # of bytes allocated in this function **/
{
	char *tmp;
	static char *fname="UTIalloc_more";

	tmp = (char *)malloc(strlen(ptr)+num_bytes_more+1);
	if(tmp == NULL)
	{
		_UTIdebug((fname, "Out of Memory!\n"));
		return((char *)0);
	}
	if(ptr != NULL)
		strcpy(tmp, ptr);
	free(ptr);
	return(tmp);
}
