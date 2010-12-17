#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "NFMerrordef.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "NETstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

/**#define NFM_COPY_LOCAL 2053**/

extern struct NFMglobal_st NFMglobal;

char int_ch[15];
char xns[2];
char tcp[2];
char dec[2];
char net[2];
char nfs[2];
char mach_id[10];
static char *method = " ";

/*  This routine transfers the local file to the designated 
 *  storage area number. Used for transferring locally created
 *  cpio file or script to specified storage area.
 */

UTIxfer_non_nfm_file_in( sa_no, file)
    long	sa_no;		/* 'in' to this storage area */
    char	*file;		/* local file ( sa #3 ) to move */
{
	char *fname = "UTIxfer_non_nfm_file_in";
	MEMptr xfer = NULL;
	struct fto_buf file_buffer;
	long status;
	int netid=0;

    	_UTIdebug(( fname, "%s\n", "Entering ..." ));

    	_UTIdebug(( fname, "sa_no : <%ld>\n", sa_no ));
    	_UTIdebug(( fname, "file : <%s>\n", file ));

    	if(UTI_RES_SA == sa_no) /** Source and Dest are the same**/
    	{
        	_UTIdebug(( fname, "Source <%d> and Dest <%d> are the same !!\nReturing Success without file transfer\n", sa_no, UTI_RES_SA ));
        	return(UTI_S_SUCCESS);
    	}
	status = _NFMget_sano_info_fto_buf( UTI_RES_SA, "", &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", 
				status));
		return(status);
	}

	status = NFMbuild_fto_buffer(&xfer, MEM_SIZE);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMbuild_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

    	_UTIdebug(( fname, "Field sano is <%d>\n", file_buffer.n_sano));
	file_buffer.n_sano = UTI_RES_SA;
	status = NFMload_fto_buf(&xfer, &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

	status = _NFMget_sano_info_fto_buf( sa_no, "", &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", 
				status));
		return(status);
	}
	strcpy(file_buffer.n_cifilename, file); 
	strcpy(file_buffer.n_cofilename, file); 
	file_buffer.n_status1 = NFM_MOVE;

    	_UTIdebug((fname,"second row: Field sano is<%d>\n",file_buffer.n_sano));
	file_buffer.n_sano = sa_no;
	status = NFMload_fto_buf(&xfer, &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

	if(_NFMdebug_st.UTIdebug_on)
		MEMprint_buffers("Xfer Buffer", xfer, _NFMdebug_st.UTIdebug_file);

	status = _NFMfs_send_files( &xfer, &netid, 1);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMfs_send_files: <0x%.8x>\n", status));
		return(status);
	}

	MEMclose(&xfer);
	return(UTI_S_SUCCESS);
}
/***************************************************************
	Testing new API for file transfer

UTIxfer_non_nfm_file_in( sa_no, file)
    long	sa_no;		/ * 'in' to this storage area * /
    char	*file;		/ * local file ( sa #3 ) to move * /
{
    long	status;

    char uti_string[1024];
    UTIarch	local  = NULL;
    MEMptr	xfer   = NULL;
    
    static	char *fname = "UTIxfer_non_nfm_file_in";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "sa_no : <%ld>\n", sa_no ));
    _UTIdebug(( fname, "file : <%s>\n", file ));

    if(UTI_RES_SA == sa_no) / ** Source and Dest are the same** /
    {
    	_UTIdebug(( fname, "Source <%d> and Dest <%d> are the same !!\nReturing Success without file transfer\n", sa_no, UTI_RES_SA ));
	return(UTI_S_SUCCESS);
    }
	 	
    local = (UTIarch)malloc( sizeof( struct archive_loc ) );
    status = UTIget_node_info( UTI_RES_SA, &local, mach_id, tcp, xns, dec,
			       net, nfs );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &xfer );
	return( status );
    }
    _UTIdebug(( fname, "mach_id : <%s>\n", mach_id ));
    _UTIdebug(( fname, "tcp : <%s>\n", tcp ));
    _UTIdebug(( fname, "xns : <%s>\n", xns ));
    _UTIdebug(( fname, "dec : <%s>\n", dec ));
    _UTIdebug(( fname, "net : <%s>\n", net ));
    _UTIdebug(( fname, "nfs : <%s>\n", nfs ));

    status = NFMget_move_files_list( UTIuser_id, &xfer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &xfer );
	return( status );
    }

/ *  Set up buffer to transfer file
 * /
    strcpy( uti_string, "0" );                   / * file number not used * /
    strcat( uti_string, "\1" );
    sprintf( int_ch, "%d", UTI_RES_SA );
    strcat( uti_string, int_ch );                / * storage number * /
    strcat( uti_string, "\1" );
/ ******************
    strcat( uti_string, local->node.name );      / * node name * /
****************** /
    strcat( uti_string, UTI_WRK_NODE );      / * Local node name! * /
    strcat( uti_string, "\1" );
    strcat( uti_string, local->user_name );      / * user name * /
    strcat( uti_string, "\1" );
    strcat( uti_string, local->password );	    / * password * /
    strcat( uti_string, "\1" );
    strcat( uti_string, local->path_name );	    / * path * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, local->device_type );   / * device type * /
    strcat( uti_string, "\1" );
    strcat( uti_string, mach_id );  	    / * machine id * /
    strcat( uti_string, "\1" );
    strcat( uti_string, local->op_sys );	    / * op_sys * /
    strcat( uti_string, "\1" );
    strcat( uti_string, tcp );		    / * tcp protocol * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, xns );		    / * xns protocol * /
    strcat( uti_string, "\1" );			 
    strcat( uti_string, dec );		    / * dec protocol * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, file );		    / * ci filename * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, file );		    / * co filename * /
    strcat( uti_string, "\1" );
    strcat( uti_string, method );	  	    / * file type method * /
    strcat( uti_string, "\1" );
    strcat( uti_string, "-1" );		    / * file size not used * /
    strcat( uti_string, "\1" );
    strcat( uti_string, "move" );		    / * file action * /
    strcat( uti_string, "\1" );

    status = MEMwrite( xfer, uti_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &xfer );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    status = NFMmove_files_in( UTIuser_id, sa_no, "", &xfer ); 
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &xfer );
	ERRload_struct( UTI, UTI_E_XFER_SCR_IN, "%s", file );
	_UTIdebug(( fname, "Bad xfer file in : <0x%.8x>\n", status));
	return( UTI_E_XFER_SCR_IN );
    }
    MEMclose( &xfer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));
    
    return( UTI_S_SUCCESS );
}
END
*******************************************************************/

/*  This routine transfers the remote file to the local storage # 3.
 *  Used for transferring cpio files used in a restore operation to
 *  the local utilities storage.
 */
UTIxfer_non_nfm_file_out( sa_no, file)
    long	sa_no;		/* out from this storage area */
    char	*file;		/* remote file to be moved */
{
	char *fname = "UTIxfer_non_nfm_file_out";
	MEMptr xfer = NULL;
	struct fto_buf file_buffer;
	long status;
	int netid=0;

    	_UTIdebug(( fname, "%s\n", "Entering ..." ));

    	_UTIdebug(( fname, "sa_no : <%ld>\n", sa_no ));
    	_UTIdebug(( fname, "file : <%s>\n", file ));

    	if(UTI_RES_SA == sa_no) /** Source and Dest are the same**/
    	{
        	_UTIdebug(( fname, "Source <%d> and Dest <%d> are the same !!\nReturing Success without file transfer\n", sa_no, UTI_RES_SA ));
        	return(UTI_S_SUCCESS);
    	}
	status = _NFMget_sano_info_fto_buf( UTI_RES_SA, "", &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", 
				status));
		return(status);
	}

	status = NFMbuild_fto_buffer(&xfer, MEM_SIZE);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMbuild_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

	status = NFMload_fto_buf(&xfer, &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

	status = _NFMget_sano_info_fto_buf( sa_no, "", &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", 
				status));
		return(status);
	}
	strcpy(file_buffer.n_cifilename, file); 
	strcpy(file_buffer.n_cofilename, file); 
	file_buffer.n_status1 = NFM_MOVE;

	status = NFMload_fto_buf(&xfer, &file_buffer);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
		return(status);
	}

	if(_NFMdebug_st.UTIdebug_on)
		MEMprint_buffers("OUT Xfer Buffer", xfer, 
					_NFMdebug_st.UTIdebug_file);

	status = _NFMfs_recv_files( &xfer, &netid, 1);
	if(status != NFM_S_SUCCESS)
	{
    		_UTIdebug(( fname, "_NFMfs_send_files: <0x%.8x>\n", status));
		return(status);
	}

	MEMclose(&xfer);
	return(UTI_S_SUCCESS);
}

/************************************************************************
UTIxfer_non_nfm_file_out( sa_no, file)
    long	sa_no;		/ * 'out' from this storage area * /
    char	*file;		/ * file to move to sa #3 * /
{
    long	status;

    char        uti_string[1024];
    UTIarch	remote = NULL;
    MEMptr	xfer = NULL;
    
    static	char *fname = "UTIxfer_non_nfm_file_out";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "sa_no : <%ld>\n", sa_no ));
    _UTIdebug(( fname, "file : <%s>\n", file ));

    if(UTI_RES_SA == sa_no) / ** Source and Dest are the same** /
    {
        _UTIdebug(( fname, "Source <%d> and Dest <%d> are the same !!\nReturing Success without file transfer\n", sa_no, UTI_RES_SA ));
        return(UTI_S_SUCCESS);
    }

    status = NFMget_move_files_list( UTIuser_id, &xfer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &xfer );
	return( status );
    }

    remote = (UTIarch)malloc( sizeof( struct archive_loc ) );
    status = UTIget_node_info( UTI_RES_SA, &remote, mach_id, tcp, xns, dec,
			       net, nfs );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &xfer );
	return( status );
    }

/ *  Set up buffer to transfer file
 * /
    strcpy( uti_string, "0" );                  / * file number not used * /
    strcat( uti_string, "\1" );
    sprintf(int_ch, "%d", UTI_RES_SA );
    strcat( uti_string, int_ch );               / * storage number * /
    strcat( uti_string, "\1" );
/ *******************
    strcat( uti_string, remote->node.name );    / * node name * /
******************* /
    strcat( uti_string, UTI_WRK_NODE);    / * Local node name! * /
    strcat( uti_string, "\1" );
    strcat( uti_string, remote->user_name );    / * user name * /
    strcat( uti_string, "\1" );
    strcat( uti_string, remote->password );	    / * password * /
    strcat( uti_string, "\1" );
    strcat( uti_string, remote->path_name );    / * path * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, remote->device_type );   / * device type * /
    strcat( uti_string, "\1" );
    strcat( uti_string, mach_id );  	    / * machine id * /
    strcat( uti_string, "\1" );
    strcat( uti_string, remote->op_sys );	    / * op_sys * /
    strcat( uti_string, "\1" );
    strcat( uti_string, tcp );		    / * tcp protocol * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, xns );		    / * xns protocol * /
    strcat( uti_string, "\1" );			 
    strcat( uti_string, dec );		    / * dec protocol * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, file );		    / * ci filename * /
    strcat( uti_string, "\1" );	
    strcat( uti_string, file );		    / * co filename * /
    strcat( uti_string, "\1" );
    strcat( uti_string, method );	  	    / * file type method * /
    strcat( uti_string, "\1" );
    strcat( uti_string, "-1" );		    / * file size not used * /
    strcat( uti_string, "\1" );
    strcat( uti_string, "move" );		    / * file action * /
    strcat( uti_string, "\1" );

    status = MEMwrite( xfer, uti_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &xfer );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMmove_files_out( UTIuser_id, sa_no, "", &xfer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &xfer );
	ERRload_struct( UTI, UTI_E_XFER_SCR_OUT, "%s", file );
	_UTIdebug(( fname, "Bad xfer file out <0x%.8x>\n", status));
	return( UTI_E_XFER_SCR_OUT );
    }
    MEMclose( &xfer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));
    
    return( UTI_S_SUCCESS );
}
**********************************************************************/

/*  This routine transfers the input list of files to the designated
 *  archive location.
 */
UTIxfer_files_in( xfer, sa_no, flist, action )
    MEMptr	*xfer;
    long	sa_no;
    UTIpending  flist;
    char	*action;
{
    long	status;
    int		cnt,netid=0;
    char        uti_string[1024], cstatus1[10], cfileno[10];
    struct 	fto_buf file_buffer;
    
    static	char *fname = "UTIxfer_files_in";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "SA_NO : <%ld>\n", sa_no ));

/** Resetup xfer buffer **/
    if(*xfer)
    	MEMclose(xfer);

/** Set up the source location **/
    status = _NFMget_sano_info_fto_buf( sa_no, "", &file_buffer);
    if(status != NFM_S_SUCCESS)
    {
           _UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", status));
	   return(status);
    }
    file_buffer.n_sano = sa_no;

    status = NFMbuild_fto_buffer(xfer, 4 * MEM_SIZE);
    if(status != NFM_S_SUCCESS)
    {
   	_UTIdebug(( fname, "NFMbuild_fto_buffer: <0x%.8x>\n", status));
	return(status);
    }


    status = NFMload_fto_buf(xfer, &file_buffer);
    if(status != NFM_S_SUCCESS)
    {
   	_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
	return(status);
    }

/*********************************/

    if(_NFMdebug_st.UTIdebug_on)
	MEMprint_buffers("BeforeXfer Buffer", *xfer, _NFMdebug_st.UTIdebug_file);
    
/*  Loop through linked list of files and add a row to the buffer
 *  for each file
 */
    cnt = 0;
    while( flist != NULL )
    {  
	if( flist->size == 0 )
	{
   	    _UTIdebug(( fname, "Skip <%s>\n",flist->ci_file_name ));
	    flist = flist->next;
	    continue;
	}
	if(flist->home.sano == sa_no) /** Source and Dest are the same**/
        {
            _UTIdebug(( fname, "Source <%d> and Dest <%d> are the same for <%s>, SKIP IT\n", sa_no, flist->home.sano, flist->ci_file_name ));
	    flist = flist->next;
	    continue;
    	}
	sprintf( int_ch, "%d", flist->home.sano );
	strcpy( uti_string, int_ch );                   /* storage number */
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.node_name );    /* node name */
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.user_name );    /* user name */
  	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.passwd );	    /* password */
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.path );	    /* path */
	strcat( uti_string, "\1" );	
        strcat( uti_string, flist->home.device_type );  /* device type */
        strcat( uti_string, "\1" );
        			  			/* platter name */
        strcat( uti_string, "\1" );
        			  			/* partition */
        strcat( uti_string, "\1" );
        			  			/* nfs */
        strcat( uti_string, "\1" );
        			  			/* mount point */
        strcat( uti_string, "\1" );
        			  			/* compress */
        strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.mach_id );	    /* machine id */
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.op_sys );	    /* op_sys */
	strcat( uti_string, "\1" );
	UTIunset_protocol( flist->home.protocol, xns, tcp, dec, net, nfs );
	strcat( uti_string, tcp );			    /* tcp protocol */
	strcat( uti_string, "\1" );	
	strcat( uti_string, xns );			    /* xns protocol */
	strcat( uti_string, "\1" );			 
	strcat( uti_string, dec );			    /* dec protocol */
	strcat( uti_string, "\1" );	
	strcat( uti_string, net );			    /* netware */
	strcat( uti_string, "\1" );	
	sprintf( cfileno, "%d", flist->file_no);
	strcat( uti_string, cfileno );	    		    /* fileno */
	strcat( uti_string, "\1" );	
							    /* fileold*/
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->ci_file_name );	    /* ci filename */
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->ci_file_name );	    /* co filename */
	strcat( uti_string, "\1" );
	strcat( uti_string, method );		    /* file type method */
	strcat( uti_string, "\1" );
	strcat( uti_string, "-1" );			    /* file size */
	strcat( uti_string, "\1" );

	sprintf(cstatus1, "%d", NFM_MOVE); 
	strcat( uti_string, cstatus1 );		    	/* status1 */
	strcat( uti_string, "\1" );
							/* status2*/
	strcat( uti_string, "\1" );
							/* status3*/
	strcat( uti_string, "\1" );

	
	_UTIdebug(( fname, "uti_string <%s>\n", uti_string));
        status = MEMwrite( *xfer, uti_string );
        if( status != MEM_S_SUCCESS )
        {
	    _UTIdebug(( fname, "MEMwrite failed <0x%.8x>\n", status));
            MEMclose( xfer );
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
	flist = flist->next;
	++cnt;
    } /* end while */

    if( cnt == 0 )
    {
	_UTIdebug(( fname, "%s\n", "No files in move list" ));
	MEMclose( xfer );

/** Is this an error ?
	ERRload_struct( UTI, UTI_E_XFER_IN, NULL, NULL );
	return( UTI_E_XFER_IN );
****/
	return(UTI_S_SUCCESS);
    }

    if(_NFMdebug_st.UTIdebug_on)
	MEMprint_buffers("IN Xfer Buffer", *xfer, _NFMdebug_st.UTIdebug_file);

    status = _NFMfs_recv_files( xfer, &netid, 1);
    if(status != NFM_S_SUCCESS)
    {
	MEMclose( xfer );
	/**ERRload_struct( UTI, UTI_E_XFER_IN, NULL, NULL );**/
   	_UTIdebug(( fname, "_NFMfs_send_files: <0x%.8x>\n", status));
	_UTIdebug(( fname, "Bad xfer files in : <0x%.8x>\n", status ));
	return(status);
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
UTIxfer_files_out( xfer, sa_no, flist, action )
    MEMptr	*xfer;
    long	sa_no;
    UTIpending  flist;
    char	*action;
{
    long	status;
    int		cnt,netid=0;
    char        uti_string[1024], cstatus1[10], cfileno[10];
    struct 	fto_buf file_buffer;
    
    static	char *fname = "UTIxfer_files_out";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "SA_NO : <%ld>\n", sa_no ));

/** Resetup xfer buffer **/
    if(*xfer)
    	MEMclose(xfer);

/** Set up the source location **/
    status = _NFMget_sano_info_fto_buf( sa_no, "", &file_buffer);
    if(status != NFM_S_SUCCESS)
    {
           _UTIdebug(( fname, "_NFMget_sano_info_fto_buf: <0x%.8x>\n", status));
	   return(status);
    }
    status = NFMbuild_fto_buffer(xfer, 4 * MEM_SIZE);
    if(status != NFM_S_SUCCESS)
    {
   	_UTIdebug(( fname, "NFMbuild_fto_buffer: <0x%.8x>\n", status));
	return(status);
    }

    status = NFMload_fto_buf(xfer, &file_buffer);
    if(status != NFM_S_SUCCESS)
    {
   	_UTIdebug(( fname, "NFMload_fto_buffer: <0x%.8x>\n", status));
	return(status);
    }

/*********************************/

    if(_NFMdebug_st.UTIdebug_on)
	MEMprint_buffers("BeforeXfer Buffer OUT", *xfer, _NFMdebug_st.UTIdebug_file);
    
/*  Loop through linked list of files and add a row to the buffer
 *  for each file
 */
    cnt = 0;
    while( flist != NULL )
    {  
	if( flist->size == 0 )
	{
   	    _UTIdebug(( fname, "Skip <%s>\n",flist->ci_file_name ));
	    flist = flist->next;
	    continue;
	}
	if(flist->home.sano == sa_no) /** Source and Dest are the same**/
        {
            _UTIdebug(( fname, "Source <%d> and Dest <%d> are the same for <%s>, SKIP IT\n", sa_no, flist->home.sano, flist->ci_file_name ));
	    flist = flist->next;
	    continue;
    	}
/***********

***********/
	sprintf( int_ch, "%d", flist->home.sano );
	strcpy( uti_string, int_ch );                   /* storage number */
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.node_name );    /* node name */
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.user_name );    /* user name */
  	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.passwd );	    /* password */
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.path );	    /* path */
	strcat( uti_string, "\1" );	
        strcat( uti_string, flist->home.device_type );  /* device type */
        strcat( uti_string, "\1" );
        			  			/* platter name */
        strcat( uti_string, "\1" );
        			  			/* partition */
        strcat( uti_string, "\1" );
        			  			/* nfs */
        strcat( uti_string, "\1" );
        			  			/* mount point */
        strcat( uti_string, "\1" );
        			  			/* compress */
        strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.mach_id );	    /* machine id */
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.op_sys );	    /* op_sys */
	strcat( uti_string, "\1" );
	UTIunset_protocol( flist->home.protocol, xns, tcp, dec, net, nfs );
	strcat( uti_string, tcp );			    /* tcp protocol */
	strcat( uti_string, "\1" );	
	strcat( uti_string, xns );			    /* xns protocol */
	strcat( uti_string, "\1" );			 
	strcat( uti_string, dec );			    /* dec protocol */
	strcat( uti_string, "\1" );	
	strcat( uti_string, net );			    /* netware */
	strcat( uti_string, "\1" );	
	sprintf( cfileno, "%d", flist->file_no);
	strcat( uti_string, cfileno );	    		    /* fileno */
	strcat( uti_string, "\1" );	
							    /* fileold*/
	strcat( uti_string, "\1" );	
/*****************
	strcat( uti_string, flist->ci_file_name );	    / * ci filename * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->ci_file_name );	    / * co filename * /
	strcat( uti_string, "\1" );
******************/
	strcat( uti_string, flist->home.co_file_name );     /* co filename */
	strcat( uti_string, "\1" );	
        /*  If there is an old format name, use that name
         *  to get it out of the cpio file.
         */
        if( strlen( flist->format.name ) > 0 )
            strcat( uti_string, flist->format.name );
        else
            strcat( uti_string, flist->ci_file_name );
	strcat( uti_string, "\1" );
	strcat( uti_string, method );		    /* file type method */
	strcat( uti_string, "\1" );
	strcat( uti_string, "-1" );			    /* file size */
	strcat( uti_string, "\1" );

	sprintf(cstatus1, "%d", NFM_MOVE); 
	strcat( uti_string, cstatus1 );		    	/* status1 */
	strcat( uti_string, "\1" );
							/* status2*/
	strcat( uti_string, "\1" );
							/* status3*/
	strcat( uti_string, "\1" );

	
	_UTIdebug(( fname, "uti_string <%s>\n", uti_string));
        status = MEMwrite( *xfer, uti_string );
        if( status != MEM_S_SUCCESS )
        {
	    _UTIdebug(( fname, "MEMwrite failed <0x%.8x>\n", status));
            MEMclose( xfer );
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
	flist = flist->next;
	++cnt;
    } /* end while */

    if( cnt == 0 )
    {
	_UTIdebug(( fname, "%s\n", "No files in move list" ));
	MEMclose( xfer );

/** Is this an error ?
	ERRload_struct( UTI, UTI_E_XFER_IN, NULL, NULL );
	return( UTI_E_XFER_IN );
****/
	return(UTI_S_SUCCESS);
    }

    if(_NFMdebug_st.UTIdebug_on)
	MEMprint_buffers("OUT Xfer Buffer", *xfer, _NFMdebug_st.UTIdebug_file);

    status = _NFMfs_send_files( xfer, &netid, 1);
    if(status != NFM_S_SUCCESS)
    {
	MEMclose( xfer );
	/**ERRload_struct( UTI, UTI_E_XFER_OUT, NULL, NULL );**/
   	_UTIdebug(( fname, "_NFMfs_send_files: <0x%.8x>\n", status));
	_UTIdebug(( fname, "Bad xfer files out : <0x%.8x>\n", status ));
	return(status);
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine transfers the input list of files from their storage
 *  location to the local reserved directory so that a cpio file can
 *  be created and moved to the chosen archive location.
 */
/***********************************************
UTIxfer_files_out( xfer, sa_no, flist, action )
    MEMptr	*xfer;
    long	sa_no;
    UTIpending  flist;
    char	*action;
{
    long	status;
    int         cnt;
    char        uti_string[1024];

    static	char *fname = "UTIxfer_files_out";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    _UTIdebug(( fname, "SA_NO : <%ld>\n", sa_no ));
    
/ *  Loop through linked list of files and add a row to the buffer
 *  for each file
 * /
    cnt = 0;
    while( flist != NULL )
    {  
        if( flist->size == 0 )
        {
            _UTIdebug(( fname, "Skip <%s>\n", flist->ci_file_name ));
            flist = flist->next;
            continue;
        }

        if((flist->home.sano == sa_no) && (strlen(flist->format.name) == 0) &&
	   (strcmp(flist->ci_file_name, flist->home.co_file_name)==0))
        {
            _UTIdebug(( fname, "Source <%d> and Dest <%d> are the same for <%s>, SKIP IT\n", sa_no, flist->home.sano, flist->ci_file_name ));
            flist = flist->next;
            continue;
        }
        else if((flist->home.sano==sa_no) && (strlen(flist->format.name) > 0) &&
	   (strcmp(flist->format.name, flist->home.co_file_name)==0))
        {
            _UTIdebug(( fname, "Source <%d> and Dest <%d> are the same for <%s>, SKIP IT\n", sa_no, flist->home.sano, flist->home.co_file_name ));
            flist = flist->next;
            continue;
        }

	sprintf( int_ch, "%d", flist->file_no );
        strcpy( uti_string, int_ch );                   / * file number * /
	strcat( uti_string, "\1" );
   	sprintf( int_ch, "%d", flist->home.sano );
	strcat( uti_string, int_ch );                   / * storage number * /
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.node_name );    / * node name * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.user_name );    / * user name * /
  	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.passwd );	    / * password * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.path );	    / * path * /
	strcat( uti_string, "\1" );	
  	strcat( uti_string, flist->home.device_type );  / * device type * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.mach_id );	    / * machine id * /
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.op_sys );	    / * op_sys * /
	strcat( uti_string, "\1" );
	UTIunset_protocol( flist->home.protocol, xns, tcp, dec, net, nfs );
	strcat( uti_string, tcp );			    / * tcp protocol * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, xns );			    / * xns protocol * /
	strcat( uti_string, "\1" );			 
	strcat( uti_string, dec );			    / * dec protocol * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->home.co_file_name ); / * co filename * /
	strcat( uti_string, "\1" );	
        / *  If there is an old format name, use that name
         *  to get it out of the cpio file.
         * /
        if( strlen( flist->format.name ) > 0 )
            strcat( uti_string, flist->format.name );
        else
            strcat( uti_string, flist->ci_file_name );
	strcat( uti_string, "\1" );
	strcat( uti_string, method );		    / * file type method * /
	strcat( uti_string, "\1" );
	strcat( uti_string, "-1" ); 		    / * file size * /
	strcat( uti_string, "\1" );
	strcat( uti_string, action );		    / * file action * /
	strcat( uti_string, "\1" );

        status = MEMwrite( *xfer, uti_string );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( xfer );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
	flist = flist->next;
	++cnt;
    } / * end while * /

    if( cnt == 0 )
    {
	MEMclose( xfer );
/ ***Is this an error ??
	ERRload_struct( UTI, UTI_E_XFER_OUT, NULL, NULL );
	_UTIdebug(( fname, "Bad xfer in : <0x%.8x>\n", status ));
	return( UTI_E_XFER_OUT );
**** /
	_UTIdebug(( fname, "No files transferred, SUCCESS\n" ));
	return(UTI_S_SUCCESS);
    }

    status = NFMmove_files_out( UTIuser_id, sa_no, "", xfer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( xfer );
	ERRload_struct( UTI, UTI_E_XFER_OUT, NULL, NULL );
	_UTIdebug(( fname, "Bad xfer in : <0x%.8x>\n", status ));
	return( UTI_E_XFER_OUT );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
**********************************************************************/

/*  This routine deletes the input list of files from their storage
 *  location. The input buffer is the one returned from having previously
 *  done file transfers. 
 */
/**********************************
UTIxfer_delete_files( xfer, flist )
    MEMptr	*xfer;
    UTIpending  flist;
{
    long	status;
    char        uti_string[1024];
    
    static	char *fname = "UTIxfer_delete_files";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    
/ *  Loop through linked list of files and add a row to the buffer
 *  for each file
 * /
    while( flist != NULL )
    {  
	sprintf( int_ch, "%d", flist->file_no );
        strcpy( uti_string, int_ch );                   / * file number * /
	strcat( uti_string, "\1" );
	sprintf( int_ch, "%ld", flist->home.sano ); / * storage area number * /
	strcat( uti_string, int_ch );                   / * storage number * /
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.node_name );    / * node name * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.user_name );    / * user name * /
  	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.passwd );	    / * password * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.path );	    / * path * /
	strcat( uti_string, "\1" );	
  	strcat( uti_string, "HD" );  		    / * device type * /
	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.mach_id );	    / * machine id * /
 	strcat( uti_string, "\1" );
	strcat( uti_string, flist->home.op_sys );	    / * op_sys * /
	strcat( uti_string, "\1" );
	UTIunset_protocol( flist->home.protocol, xns, tcp, dec, net, nfs );
	strcat( uti_string, tcp );			    / * tcp protocol * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, xns );			    / * xns protocol * /
	strcat( uti_string, "\1" );			 
	strcat( uti_string, dec );			    / * dec protocol * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->ci_file_name );	    / * ci filename * /
	strcat( uti_string, "\1" );	
	strcat( uti_string, flist->ci_file_name );	    
	strcat( uti_string, "\1" );
	strcat( uti_string, method );		    / * file type method * /
	strcat( uti_string, "\1" );
	sprintf( int_ch, "%d", flist->size );
	strcat( uti_string, int_ch ); 		    / * file size * /
	strcat( uti_string, "\1" );
	strcat( uti_string, "move" );		    / * file action * /
	strcat( uti_string, "\1" );

        status = MEMwrite( *xfer, uti_string );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( xfer );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }

        status = NFMdelete_in_files( UTIuser_id, flist->home.sano,"", xfer );
        if( status != NFM_S_SUCCESS )
        {
	    _UTIdebug(( fname, "Bad xfer delete : <0x%.8x>\n", status ));
        }
	flist = flist->next;
    } / * end while * /

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
***************************/

UTIxfer_delete_files( xfer, flist )
    MEMptr	*xfer;
    UTIpending  flist;
{
	char *fname="UTIxfer_delete_files";
	long status;
	int cnt;
	char uti_string[1024];
	char cfileno[10], cstatus1[10];

	_UTIdebug(( fname, "Entry\n"));
	if(*xfer == NULL) /** If it is NULL, build the buffer **/
	{
	    status = NFMbuild_fto_buffer(xfer, 4 * MEM_SIZE);
	    if(status != NFM_S_SUCCESS)
	    {
		_UTIdebug(( fname, "NFMbuild_fto_buffer: <0x%.8x>\n", status));
		return(status);
	    }
	    cnt = 0;
	    while( flist != NULL )
	    {   /** If the file had been purged or the version == 0**/
		if(( flist->size == -999 ) || (flist->ver == 0))
		{
		    _UTIdebug(( fname, "Skip <%s>\n",flist->ci_file_name ));
		    flist = flist->next;
		    continue;
		}

		sprintf( int_ch, "%d", flist->home.sano );
		strcpy( uti_string, int_ch );               /* storage number */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.node_name );    /* node name */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.user_name );    /* user name */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.passwd );       /* password */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.path );	    /* path */
		strcat( uti_string, "\1" );	
		strcat( uti_string, flist->home.device_type ); /* device type */
		strcat( uti_string, "\1" );
							     /* platter name */
		strcat( uti_string, "\1" );
								/* partition */
		strcat( uti_string, "\1" );
								/* nfs */
		strcat( uti_string, "\1" );
							     /* mount point */
		strcat( uti_string, "\1" );
								/* compress */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.mach_id );     /* machine id */
		strcat( uti_string, "\1" );
		strcat( uti_string, flist->home.op_sys );	    /* op_sys */
		strcat( uti_string, "\1" );
		UTIunset_protocol(flist->home.protocol,xns, tcp, dec, net, nfs);
		strcat( uti_string, tcp );		      /* tcp protocol */
		strcat( uti_string, "\1" );	
		strcat( uti_string, xns );		      /* xns protocol */
		strcat( uti_string, "\1" );			 
		strcat( uti_string, dec );		      /* dec protocol */
		strcat( uti_string, "\1" );	
		strcat( uti_string, net );			   /* netware */
		strcat( uti_string, "\1" );	
		sprintf( cfileno, "%d", flist->file_no);
		strcat( uti_string, cfileno );	    		    /* fileno */
		strcat( uti_string, "\1" );	
								    /* fileold*/
		strcat( uti_string, "\1" );	
		strcat( uti_string, flist->ci_file_name );	/* ci filename*/
		strcat( uti_string, "\1" );	
		strcat( uti_string, flist->ci_file_name );	/* co filename*/
		strcat( uti_string, "\1" );
		strcat( uti_string, method );		   /* file type method*/
		strcat( uti_string, "\1" );
		strcat( uti_string, "-1" );		        /* file size */
		strcat( uti_string, "\1" );

		sprintf(cstatus1, "%d", NFM_DELETE_FILE); 
		strcat( uti_string, cstatus1 );		    	/* status1 */
		strcat( uti_string, "\1" );
								/* status2*/
		strcat( uti_string, "\1" );
								/* status3*/
		strcat( uti_string, "\1" );

		
		_UTIdebug(( fname, "uti_string <%s>\n", uti_string));
		status = MEMwrite( *xfer, uti_string );
		if( status != MEM_S_SUCCESS )
		{
		    _UTIdebug(( fname, "MEMwrite failed <0x%.8x>\n", status));
		    MEMclose( xfer );
		    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		    return( NFM_E_MEM );
		}
		flist = flist->next;
		++cnt;
	    } /* end while */

	    if(_NFMdebug_st.NFMdebug_on)
		MEMprint_buffers("Delete Buffer", *xfer, 
						_NFMdebug_st.NFMdebug_file);
	    status = NFMrm_ci_files(xfer, 0);
	    if(status != NFM_S_SUCCESS)
	    {
	        _UTIdebug(( fname,"Delete ci files  FAILED : NFMfs_chg_files: <0x%.8x>\n", status ));
	        return(status);
	    }

	}
	else
	{
	    if(_NFMdebug_st.UTIdebug_on)
		MEMprint_buffers("Delete Buffer", *xfer, 
						_NFMdebug_st.UTIdebug_file);
	    status = NFMrm_ci_files(xfer, 0);
	    if(status != NFM_S_SUCCESS)
	    {
	        _UTIdebug(( fname, "Delete ci files FAILED : NFMrm_ci_files: <0x%.8x>\n", status ));
	        return(status);
	    }
	}
	_UTIdebug(( fname, "Successful delete ci files\n"));
	return(UTI_S_SUCCESS);
}

UTIcopy_f1_to_f2 (sano, file1, file2, move_buffer, delete_flag)
     long sano ;	   /** Storage area no 			**/
     char *file1, *file2 ; /** f1: Source, f2: destination 	**/ 
     MEMptr *move_buffer ; /** Output buffer for NFMfs_chg_files**/
     int delete_flag;      /** value 1=>delete source; 0=> don't **/
{
  char *fname = "UTIcopy_f1_to_f2" ;
  long status ;
  struct fto_buf file_buffer ;

  _UTIdebug ((fname, "Sano %d, Source %s, Destination %s\n",
	      sano, file1, file2)) ;

  status = _NFMget_sano_info_fto_buf (sano, "",  &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get sano info status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  if (!(*move_buffer))
    {
      status = NFMbuild_fto_buffer (move_buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, 
		      "Build fto buffer : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  if(delete_flag)
  	file_buffer.n_status1 = NFM_RENAME ;
  else
  	file_buffer.n_status1 = NFM_COPY_LOCAL ;

  /**Source file**/
  strcpy (file_buffer.n_cifilename, file1) ;

  /**Destination file**/
  strcpy(file_buffer.n_cofilename, file2);

  status = NFMload_fto_buf (move_buffer, &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long UTIcopy_ud_to_NFMencrypted (sano, cat_no, file_no, filename, 
				    move_buffer, delete_flag)
     long sano ;
     long cat_no ;
     long file_no ;
     char *filename ;
     MEMptr *move_buffer ;
     int delete_flag;  /** if 1, rename else copy **/
{
  char *fname = "UTIcopy_ud_to_NFMencrypted" ;
  long status ;
  struct fto_buf file_buffer ;

  _NFMdebug ((fname, "sano %d : cat_no %d : file_no %d : filename %s\n",
	      sano, cat_no, file_no, filename)) ;

  status = _NFMget_sano_info_fto_buf (sano, "",  &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get sano info status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  if (!(*move_buffer))
    {
      status = NFMbuild_fto_buffer (move_buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, 
		      "Build fto buffer : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  if(delete_flag)
  	file_buffer.n_status1 = NFM_RENAME ;
  else
  	file_buffer.n_status1 = NFM_COPY_LOCAL ;

/* new name is encrypted -> n_cifilename */
  status = NFMget_file_name (NFMglobal.NFMuserid,
			     cat_no, file_no,
			     file_buffer.n_cofilename) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

/* old name n_cofilename */
  strcpy (file_buffer.n_cifilename, filename) ;

  status = NFMload_fto_buf (move_buffer, &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
