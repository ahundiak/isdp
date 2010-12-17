#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "NFMerrordef.h"
#include "NFMschema.h"
#include "ERR.h"
#include "DEBUG.h"

#define	 BUFFER_SIZE	1000

char	 sql_str[1024];

/*  This routine takes the input label for examination.
 *  If the label is "SYSLAB", the user wanted the label 
 *  generated. Otherwise, nothing else is done with 
 *  the label.
 */
UTIprocess_label( in_label, out_label )
    char *in_label;
    char *out_label;
{
    static char *fname = "UTIprocess_label";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( strcmp( in_label, "SYSLAB" ) != 0 )
    {
	strcpy( out_label, in_label );
	return( UTI_S_SUCCESS );
    }
/*  Generate a label
 */
    UTIgen_label( out_label );
    _UTIdebug(( fname, "Generated label : <%s>\n", out_label ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine takes the storage area number and label and creates
 *  an 'NFMarch' structure and 'UTIarch' structure. These two structures
 *  are used to build scripts and update the database.
 */
UTIget_sa_info( sa_no, label, flist, nfm_arch_loc, uti_arch_loc )
    int		sa_no;
    char	*label;
    UTIpending  flist;
    NFMarch	*nfm_arch_loc;
    UTIarch	*uti_arch_loc;
{
    int		status;
    int		node_no;

    char	ss_num[10];
    char	path_name[50];
    char	**sa_ptr;
    char	**node_ptr;

    MEMptr	sa_buffer   = NULL;
    MEMptr	node_buffer = NULL;

    NFMarch	nfm_loc;
    UTIarch	uti_loc;

    static 	char *fname = "UTIget_sa_info :";
    
    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    nfm_loc = (NFMarch)malloc( sizeof( struct nfmarchives ) );
    uti_loc = (UTIarch)malloc( sizeof( struct archive_loc ) );

    sprintf( sql_str, "SELECT n_nodeno,n_username,n_passwd,n_pathname,n_devicetype FROM nfmstoragearea WHERE n_sano = %d", sa_no );
    status = SQLquery( sql_str, &sa_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", sa_no );
	MEMclose( &sa_buffer );
	return( UTI_E_QUERYSA );
    }

    status = MEMbuild_array( sa_buffer );
    if( status != MEM_S_SUCCESS )
    {
	_UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    sa_ptr = (char**)sa_buffer->data_ptr;
    node_no = atoi( sa_ptr[0] );

    sprintf( sql_str, "SELECT n_nodename,n_tcpip,n_xns,n_decnet,n_opsys,n_netware,n_nfs FROM nfmnodes WHERE n_nodeno = %d", node_no );
    status = SQLquery( sql_str, &node_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", node_no );
	MEMclose( &sa_buffer );
	MEMclose( &node_buffer );
	return( UTI_E_QUERYNODE );
    }

    status = MEMbuild_array( node_buffer );
    if( status != MEM_S_SUCCESS )
    {
        _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    node_ptr = (char**)node_buffer->data_ptr;

/*  Get nfm_loc
 */
    UTIget_next_spot( &(nfm_loc->archive_no) );
    nfm_loc->label 	    = UTIload( label );
    UTIgen_saveset( nfm_loc->archive_no, label, ss_num, sa_no );
    nfm_loc->saveset	    = UTIload( ss_num );
    nfm_loc->storageno      = sa_no;
    strcpy( path_name, sa_ptr[3] );
    nfm_loc->archive_date   = UTIload( UTIgen_date() );
    nfm_loc->archive_method = UTIload( "I" );
    nfm_loc->archive_copies = 1;
    nfm_loc->archive_size   = UTIget_archive_size( flist );
    nfm_loc->no_vol         = 1;

/*  Get uti_loc
 */
    uti_loc->label          = UTIload( label );
    uti_loc->saveset        = UTIload( nfm_loc->saveset );
    strcpy( uti_loc->node.name, node_ptr[0] );
    uti_loc->node.val       = node_no;
    uti_loc->user_name      = UTIload( sa_ptr[1] );
    uti_loc->password       = UTIload( sa_ptr[2] );
    uti_loc->device_type    = UTIload( sa_ptr[4] );
    uti_loc->device_name    = UTIload( sa_ptr[3] );
    uti_loc->op_sys         = UTIload( node_ptr[4] );
    uti_loc->protocol       = UTIset_protocol( node_ptr[2],
		       node_ptr[1],node_ptr[3], node_ptr[5], node_ptr[6]);
/*  Alter my path name to have '/' at the end if not already there
 */ 
    nfm_loc->archive_path = UTIgood_path( path_name, node_ptr[4] );
    uti_loc->path_name	  = UTIgood_path( path_name, node_ptr[4] );

    UTIupcase( uti_loc->device_type );
    UTIupcase( uti_loc->op_sys );
    strcpy( UTI_ARCHIVE_OPSYS, uti_loc->op_sys );

    if( ( strcmp( uti_loc->device_type, "CT" ) == 0 ) ||
	( strcmp( uti_loc->device_type, "MT" ) == 0 ) ||
	( strcmp( uti_loc->device_type, "UT" ) == 0 ) ||
	( strcmp( uti_loc->device_type, "FD" ) == 0 ) )
    {
	OFF_LINE = TRUE;
	_UTIdebug(( fname, "%s\n", "OFF_LINE Device : " ));
    }
    else
    {
	ON_LINE  = TRUE;
	_UTIdebug(( fname, "%s\n", "ON_LINE Device : " ));
    }

    UTIprint_nfmarchives( nfm_loc );
    UTIprint_archive_loc( uti_loc );

    *nfm_arch_loc = nfm_loc;
    *uti_arch_loc = uti_loc;

    MEMclose( &sa_buffer );
    MEMclose( &node_buffer );

    status = UTISget_util_sa_info( node_no );
    if( status != UTI_S_SUCCESS )
    {
	UTIrm_saveset_entry( nfm_loc->archive_no );
	return( status );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine sets the UTI_CLIENT_SA value and UTI_CLIENT_PATH 
 *  which corresponds to default storage area for utilities on the
 *  chosen node ( i.e. /usr/ip32/nfm/utilities )
 */
UTISget_util_sa_info( node_no )
    int 	node_no;
{
    long	status;
    char	**sa_ptr, **node_ptr;
    MEMptr	sa_buffer = NULL;
    MEMptr	node_buffer = NULL;
    char 	nodename[NFM_NODENAME+1];

    static	char *fname = "UTIget_util_sa_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( sql_str, "SELECT n_sano,n_pathname FROM nfmstoragearea WHERE n_nodeno = %d and n_saname = '%d-UTIL'",node_no, node_no );
    status = SQLquery( sql_str, &sa_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &sa_buffer );
	sprintf(sql_str, "SELECT n_nodename FROM nfmnodes WHERE n_nodeno = %d",
		node_no);
	status = SQLquery(sql_str, &node_buffer, BUFFER_SIZE);	
	if(status != SQL_S_SUCCESS)
	{
		_UTIdebug((fname, "Query for #-UTIL storage area for nodeno %d failed <0x%.8x>\n", node_no, status)); 
        	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", node_no );
		return(UTI_E_QUERYSA);
	}
	else
	{
		status = MEMbuild_array(node_buffer);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&node_buffer);
			_UTIdebug((fname, "Query for #-UTIL storage area for nodeno %d failed <0x%.8x>\n", node_no, status)); 
        		ERRload_struct( UTI, UTI_E_QUERYSA, "%d", node_no );
			return(UTI_E_QUERYSA);
		}
		else
		{
			node_ptr = (char **)node_buffer->data_ptr;
			strcpy(nodename , node_ptr[0]);
			MEMclose(&node_buffer);

			status = UTI_E_QUERY_UTIL;
			_UTIdebug((fname, "Query for %d-UTIL storage area for node %s failed <0x%.8x>\n", node_no, nodename, status)); 

        		ERRload_struct(UTI, status, "%s%d", nodename, node_no);
			return(status);
		}
	}
    }

    status = MEMbuild_array( sa_buffer );
    if( status != MEM_S_SUCCESS )
    {
        _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sa_ptr = (char**)sa_buffer->data_ptr;
    UTI_CLIENT_SA = atol( sa_ptr[0] );
    strcpy( UTI_CLIENT_PATH, sa_ptr[1] );

    if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
        strcat( UTI_CLIENT_PATH, "/" );

    MEMclose( &sa_buffer );

    _UTIdebug(( fname, "UTI_CLIENT_SA : <%ld>\n", UTI_CLIENT_SA ));
    _UTIdebug(( fname, "UTI_CLIENT_PATH : <%s>\n", UTI_CLIENT_PATH));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}


/*  This routine fills in empty spots of file list that weren't known
 *  until the storage device and label was chosen. It also sets the
 *  storage number to be negative if the chosen media if OFF-LINE.
 */
UTIprocess_files( nfm_loc, uti_loc, flist )
    NFMarch	nfm_loc;
    UTIarch	uti_loc;
    UTIpending  flist;
{
    int		flag;

    static	char *fname = "UTIprocess_files";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    flag = 0;
    if(( strcmp( UTI_UTILITY,"ARCHIVE" ) == 0 ) ||
       ( strcmp( UTI_UTILITY,"BACKUP"  ) == 0 )  )
	flag = 1;
    while( flist != NULL )
    {
	strcpy( flist->node.name, uti_loc->node.name );
  	flist->node.val = uti_loc->node.val;
	if( flag )
	    flist->rstr.archive_no = nfm_loc->archive_no;
	flist->rstr.storage_no = nfm_loc->storageno;
	if( OFF_LINE )
  	    flist->rstr.storage_no = -flist->rstr.storage_no;
	flist->label	  = UTIload( nfm_loc->label );
	flist->saveset	  = UTIload( nfm_loc->saveset );
	flist->state	  = 0;  /* reset link number */
	flist = flist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine generates a script name, which will be sent back to
 *  the user, but mainly, it builds the script given the input file
 *  list and the NFMarch structure.
 */
UTIbuild_script( utility, group_no, arch_loc, flist )
    int		utility;
    int		group_no;
    UTIarch	arch_loc;
    UTIpending  flist;
{
    long	status = UTI_S_SUCCESS;

    static	char *fname = "UTIbuild_script";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
    {
        UTIset_media( arch_loc->device_type );
	if( OFF_LINE )
	{
            sprintf( UTI_SCRIPT, "%sARCHIVE.%d",UTI_SERVER_PATH,
		     group_no);
            sprintf( UTI_CONFIG, "%sARCHIVE_C.%d",UTI_SERVER_PATH,
		     group_no);
	}
	else if( ON_LINE )
	    sprintf( UTI_SCRIPT, "%sARCHIVE.COM", UTI_SERVER_PATH );

        status = UTIu_build_archive_script( flist, arch_loc );
    }
    else if( utility == UTIbackup )
    {
        UTIset_media( arch_loc->device_type );
	if( OFF_LINE )
	{
            sprintf( UTI_SCRIPT,"%sBACKUP.%d",UTI_SERVER_PATH,group_no);
            sprintf( UTI_CONFIG,"%sBACKUP_C.%d",UTI_SERVER_PATH,group_no);
	}
	else if( ON_LINE )
	    sprintf( UTI_SCRIPT, "%sBACKUP.COM", UTI_SERVER_PATH );

	status = UTIu_build_backup_script( flist, arch_loc );
    }
    else if( utility == UTIrestore )
    {
	UTIget_rstr_no();
	status = UTIu_process_restore( flist );
    }

    if( status != UTI_S_SUCCESS )
        return( status );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine handles the intricacies of RESTORE
 */
UTIu_process_restore( flist )
    UTIpending	flist;
{
    long	status;
    char	script_name[1024];

    static	char *fname = "UTIu_process_restore";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( script_name, "%sRESTORE.REQ", UTI_SERVER_PATH );
    status = UTIwrite_script( flist, script_name );
    if( status != UTI_S_SUCCESS )
	return( status );

    status = UTIsort_restore_requests();
    if( status != UTI_S_SUCCESS )
	return( status );

    status = UTIbuild_restore_master( flist );
    if( status != UTI_S_SUCCESS )
	return( status );
    
    unlink(script_name);

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine loads the script name into the return buffer to 
 *  be returned to the user. This is the script that should be executed
 *  on the given node (node name also returned to the user.
 */
UTIreturn_info( s_name, node_name, label )
    char	*s_name;
    char	*node_name;
    char	*label; /**Return the label name 8/14/92 DONTU**/
{
    long	status;

    char	str[80];

    static	char *fname = "UTIreturn_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "Script <%s>\n", s_name));
    _UTIdebug(( fname, "Node_name <%s>\n", node_name));
    _UTIdebug(( fname, "Label <%s>\n", label ));

    strcpy( str, s_name );
    strcat( str, "\1" );
    strcat( str, node_name );
    strcat( str, "\1" );
    strcat( str, label );
    strcat( str, "\1" );
    status = MEMwrite( UTI_MSG_BUFFER, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    MSG = TRUE;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );

}
/*  This routine is called at the beginning to open up error buffers 
 *  and return information buffers. These buffers remain open for
 *  additions until returning to the main server loop.
 */
UTIopen_buffers()
{
    long	status;
    static      char *fname = "UTIopen_buffers";

    status = MEMopen( &UTI_ERR_BUFFER, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( UTI_ERR_BUFFER, "err", "char(132)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_ERR_BUFFER);
        _UTIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( UTI_ERR_BUFFER, "err_num", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_ERR_BUFFER);
        _UTIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMopen( &UTI_MSG_BUFFER, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( UTI_MSG_BUFFER, "script", "char(50)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( UTI_MSG_BUFFER, "node_name", "char(30)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( UTI_MSG_BUFFER, "label", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&UTI_MSG_BUFFER);
        _UTIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    MSG = FALSE;	/* 'Message written' flag */

    return( UTI_S_SUCCESS );
}
/*  This routine closes the global buffers
 */
UTIclose_buffers()
{
    long  status;

    if( UTI_MSG_BUFFER != NULL )
    {
        status = MEMappend( UTI_MSG_BUFFER, UTI_ERR_BUFFER );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &UTI_MSG_BUFFER );
            return( status );
        }
    }
    MEMclose( &UTI_MSG_BUFFER );

    return( UTI_S_SUCCESS );
}

/*  This routine returns information regarding the utilities storage 
 *  area node.
 */
UTIget_node_info( sa_no, node_info, mach_id, tcp, xns, dec, net, nfs )
    int		sa_no;
    UTIarch	*node_info;
    char	*mach_id;
    char	*tcp;
    char 	*xns;
    char 	*dec;
    char	*net;
    char	*nfs;
{
    int		node_no;
    long	status;

    char	**sa_ptr;
    char	**node_ptr;

    UTIarch	node;

    MEMptr	sa_buffer   = NULL;
    MEMptr	node_buffer = NULL;
    
    static	char *fname = "UTIget_node_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    node = (UTIarch)malloc( sizeof( struct archive_loc ) );

    sprintf( sql_str, "SELECT n_nodeno,n_username,n_passwd,n_pathname,n_devicetype FROM nfmstoragearea WHERE n_sano = %d ",sa_no);
    status = SQLquery( sql_str, &sa_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", sa_no );
	MEMclose( &sa_buffer );
	return( UTI_E_QUERYSA );
    }

    status = MEMbuild_array( sa_buffer );
    if( status != MEM_S_SUCCESS )
    {
        _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    sa_ptr = (char**)sa_buffer->data_ptr;
    node_no = atoi( sa_ptr[0] );

    sprintf( sql_str, 
	"SELECT n_nodename,n_tcpip,n_xns,n_decnet,n_opsys,n_machid,n_netware,n_nfs FROM nfmnodes WHERE n_nodeno = %d", node_no );
    status = SQLquery( sql_str, &node_buffer, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", node_no );
	MEMclose( &sa_buffer );
	MEMclose( &node_buffer );
	return( UTI_E_QUERYNODE );
    }

    status = MEMbuild_array( node_buffer );
    if( status != MEM_S_SUCCESS )
    {
        _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    node_ptr = (char**)node_buffer->data_ptr;

    node->label       = UTIload( " " );
    node->saveset     = UTIload( " " );
    node->device_type = UTIload( sa_ptr[4] );
    node->device_name = UTIload( sa_ptr[3] );
    node->node.val    = node_no;
    strcpy( node->node.name, node_ptr[0] );
    node->user_name   = UTIload( sa_ptr[1] );
    node->password    = UTIload( sa_ptr[2] );
    node->path_name   = UTIload( sa_ptr[3] );
    node->op_sys      = UTIload( node_ptr[4] );
    strcpy( mach_id, node_ptr[5] );
    strcpy( tcp, node_ptr[1] );
    strcpy( xns, node_ptr[2] );
    strcpy( dec, node_ptr[3] );
    strcpy( net, node_ptr[6] );
    strcpy( nfs, node_ptr[7] );
    node->protocol    = UTIset_protocol( xns, tcp, dec, net, nfs );
 
    MEMclose( &node_buffer );
    MEMclose( &sa_buffer );

    *node_info = node;
    
    UTIprint_archive_loc( node );
 
    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine unlinks input list of local files
 */
UTIdelete_local_files( flist )
    UTIpending flist;
{
    char	cmd[132];
    long	status;

    static 	char *fname = "UTIdelete_local_files";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    while( flist != NULL )
    {
	if( flist->state != -1 )
	{
            /*  If there is an old format name, use that name.
             */
            if( strlen( flist->format.name ) > 0 )
                sprintf( cmd, "%s%s", UTI_SERVER_PATH, flist->format.name );
            else
	        sprintf( cmd, "%s%s", UTI_SERVER_PATH, flist->ci_file_name);
	    status = unlink( cmd );
	    _UTIdebug(( fname, "Delete file <%s>\n", cmd ));
	}
	flist = flist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine returns the storage area number for the storage area 
 *  named UTILITIES. This has been changed to 1-UTIL
 */
UTIget_reserved_sano( )
{
    long	status;

    char	**sa_ptr, **node_ptr;

    int node_no;

    MEMptr	sa_buffer   = NULL, node_buffer = NULL;

    static	char *fname = "UTIget_reserved_sano";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    
       sprintf(sql_str,
       "SELECT n_sano,n_pathname FROM nfmstoragearea a, nfmnodes b WHERE (a.n_saname = 'UTILITIES') AND (a.n_nodeno = b.n_nodeno) AND (b.n_nodename = '%s')", UTI_WRK_NODE );

    status = SQLquery( sql_str, &sa_buffer, BUFFER_SIZE );
    if(status != SQL_S_SUCCESS)  
    {
       MEMclose(&sa_buffer);
       /** Query for #-UTIL on this machine ***/ 

       sprintf(sql_str,
       "SELECT n_sano,n_pathname FROM nfmstoragearea a, nfmnodes b WHERE (a.n_saname LIKE '%%-UTIL') AND (a.n_nodeno = b.n_nodeno) AND (b.n_nodename = '%s')", UTI_WRK_NODE );

       status = SQLquery( sql_str, &sa_buffer, BUFFER_SIZE );
       if( status != SQL_S_SUCCESS )
       {
/****
 	   ERRload_struct( UTI, UTI_E_QUERYSA, "%s", "UTILITIES or #-UTIL" );
	   MEMclose( &sa_buffer );
	   return( UTI_E_QUERYSA );
****/
	   sprintf(sql_str, "SELECT n_nodeno FROM nfmnodes WHERE n_nodename='%s'", UTI_WRK_NODE);
	   status = SQLquery(sql_str, &node_buffer, BUFFER_SIZE);
	   if(status != SQL_S_SUCCESS)
	   {
	      MEMclose(&node_buffer);
	      status = UTI_E_QUERY_UTIL;
	      ERRload_struct( UTI, status, "%s%s", UTI_WRK_NODE, "#");
	      return(status);
	   }
	   else
	   {
	      status = MEMbuild_array(node_buffer);
              if( status != MEM_S_SUCCESS )
              {
                  _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
                  ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                  return( NFM_E_MEM );
              }
              node_ptr = (char**)node_buffer->data_ptr;
              node_no = atoi( node_ptr[0] );

	      MEMclose( &node_buffer );
	      status = UTI_E_QUERY_UTIL;
	      _UTIdebug((fname, "Query for %d-UTIL storage area for node %s failed <0x%.8x>\n", node_no, UTI_WRK_NODE, status)); 
              ERRload_struct(UTI, status, "%s%d", UTI_WRK_NODE, node_no);
	      return(status);
	   }
       }
    }

    status = MEMbuild_array( sa_buffer );
    if( status != MEM_S_SUCCESS )
    {
        _UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    sa_ptr = (char**)sa_buffer->data_ptr;

    UTI_RES_SA = atoi( sa_ptr[0] );

/*************/

    strcpy(UTI_SERVER_PATH, sa_ptr[1]);
    strcat(UTI_SERVER_PATH, "/");
    _UTIdebug(( fname, "\n\t******NEW SERVER PATH <%s>******\n", UTI_SERVER_PATH));
/*************/

    MEMclose( &sa_buffer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
