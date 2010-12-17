#include "machine.h"
#include "NFMRextern.h"
#include "NFMdef.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRall_debug
 
 Abstract:
     This function will turn debug on for the specified
     underlying I/NFM subsystems. The subsystems are represented 
     in each input array in the following order :

	NFI  -  Interface debug
	NFMR -  Requestor interface debug
	NETC -  Network subsystem (client side) debug
	MEMC -  Memory subsystem (client side) debug
	ERRC -  Error message subsystem (client side) debug
	NETS -  Network subsystem (server side) debug
        NFMS -  Server interface debug
	NFM  -  NFM subsystem debug
	SQL  -  SQL subsystem debug	
	RDB  -  RDB subsystem debug
	MEMS -  Memory subsystem (server side) debug
	UTI  -  Utilities subsystem debug
	RPS  -  RPS subsystem debug
	ERRS -  Error message subsystem (server side) debug
     
 Returns:
       NFM_S_SUCCESS    - Success
       !(NFM_S_SUCCESS) - Failure
     
 */
 
long NFMRall_debug ( toggles, files )

int  toggles[NFM_DEBUG_SUBSYSTEMS];
		 /* i - array of subsystem debugs on (1) or off (0) */
char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
		 /* i - array of subsystem debug filenames */
{
MEMptr info = NULL;
char   str[1024];
long   status = 0;
long   ret_status = 0;
char   flag[2];
char   file_size[10];
static char *fname = "NFMRall_debug";

_NFMRdebug ((fname, "NFI       : <%d>\n", toggles[0]));
_NFMRdebug ((fname, "NFI  File : <%s>\n", files[0]));
_NFMRdebug ((fname, "NFMR      : <%d>\n", toggles[2] ));
_NFMRdebug ((fname, "NFMR File : <%s>\n", files[2] ));
_NFMRdebug ((fname, "NETC      : <%d>\n", toggles[3] ));
_NFMRdebug ((fname, "NETC File : <%s>\n", files[3] ));
_NFMRdebug ((fname, "MEMC      : <%d>\n", toggles[4] ));
_NFMRdebug ((fname, "MEMC File : <%s>\n", files[4] ));
_NFMRdebug ((fname, "ERRC      : <%d>\n", toggles[5] ));
_NFMRdebug ((fname, "ERRC File : <%s>\n", files[5] ));
_NFMRdebug ((fname, "NETS      : <%d>\n", toggles[6] ));
_NFMRdebug ((fname, "NETS File : <%s>\n", files[6] ));
_NFMRdebug ((fname, "NFMS      : <%d>\n", toggles[7] ));
_NFMRdebug ((fname, "NFMS File : <%s>\n", files[7] ));
_NFMRdebug ((fname, "NFM       : <%d>\n", toggles[8] ));
_NFMRdebug ((fname, "NFM File  : <%s>\n", files[8] ));
_NFMRdebug ((fname, "SQL       : <%d>\n", toggles[9] ));
_NFMRdebug ((fname, "SQL File  : <%s>\n", files[9] ));
_NFMRdebug ((fname, "MEMS      : <%d>\n", toggles[11] ));
_NFMRdebug ((fname, "MEMS File : <%s>\n", files[11] ));
_NFMRdebug ((fname, "UTI       : <%d>\n", toggles[12] ));
_NFMRdebug ((fname, "UTI File  : <%s>\n", files[12] ));
_NFMRdebug ((fname, "ERRS      : <%d>\n", toggles[14] ));
_NFMRdebug ((fname, "ERRS File : <%s>\n", files[14] ));

    _NFMdebug_st.NFIdebug_on = toggles[0];
    strncpy( _NFMdebug_st.NFIdebug_file, files[0],
	     sizeof( _NFMdebug_st.NFIdebug_file ) - 1 );

    _NFMdebug_st.NFMRdebug_on = toggles[2];
    strncpy( _NFMdebug_st.NFMRdebug_file, files[2],
	     sizeof( _NFMdebug_st.NFMRdebug_file ) - 1 );

    _NFMdebug_st.NETCdebug_on = toggles[3];
    strncpy( _NFMdebug_st.NETCdebug_file, files[3],
	     sizeof( _NFMdebug_st.NETCdebug_file ) - 1 );

    _NFMdebug_st.MEMdebug_on = toggles[4];
    strncpy( _NFMdebug_st.MEMdebug_file, files[4],
	     sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );

    _NFMdebug_st.ERRdebug_on = toggles[5];
    strncpy( _NFMdebug_st.ERRdebug_file, files[5],
	     sizeof( _NFMdebug_st.ERRdebug_file ) - 1 );

    _NFMdebug_st.NETSdebug_on = toggles[6];
    strncpy( _NFMdebug_st.NETSdebug_file, files[6],
	     sizeof( _NFMdebug_st.NETSdebug_file ) - 1 );

    _NFMdebug_st.NFMSdebug_on = toggles[7];
    strncpy( _NFMdebug_st.NFMSdebug_file, files[7],
	     sizeof( _NFMdebug_st.NFMSdebug_file ) - 1 );

    _NFMdebug_st.NFMdebug_on = toggles[8];
    strncpy( _NFMdebug_st.NFMdebug_file, files[8],
	     sizeof( _NFMdebug_st.NFMdebug_file ) - 1 );

    _NFMdebug_st.SQLdebug_on = toggles[9];
    strncpy( _NFMdebug_st.SQLdebug_file, files[9],
	     sizeof( _NFMdebug_st.SQLdebug_file ) - 1 );

    _NFMdebug_st.MEMdebug_on = toggles[11];
    strncpy( _NFMdebug_st.MEMdebug_file, files[11],
	     sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );

    _NFMdebug_st.UTIdebug_on = toggles[12];
    strncpy( _NFMdebug_st.UTIdebug_file, files[12],
	     sizeof( _NFMdebug_st.UTIdebug_file ) - 1 );

    _NFMdebug_st.ERRdebug_on = toggles[14];
    strncpy( _NFMdebug_st.ERRdebug_file, files[14],
	     sizeof( _NFMdebug_st.ERRdebug_file ) - 1 );

    sprintf( file_size, "char(%d)", NFM_DEBUG_FILE_SIZE );

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug ((fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfi", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfi_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    
    status = MEMwrite_format (info, "nfmr", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfmr_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    
    status = MEMwrite_format (info, "netc", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "netc_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    
    status = MEMwrite_format (info, "memc", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "memc_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    
    status = MEMwrite_format (info, "errc", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "errc_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    
    status = MEMwrite_format (info, "nets", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nets_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "nfms", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfms_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfm", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfm_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "sql", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "sql_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "mem", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "mem_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "uti", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "uti_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "err", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "err_file", file_size);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (flag, "%d", toggles[0] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[0]);
    strcat (str, "\1");
    
    sprintf (flag, "%d", toggles[2] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[2]);
    strcat (str, "\1");
    
    sprintf (flag, "%d", toggles[3] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[3]);
    strcat (str, "\1");
    
    sprintf (flag, "%d", toggles[4] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[4]);
    strcat (str, "\1");
    
    sprintf (flag, "%d", toggles[5] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[5]);
    strcat (str, "\1");
    
    sprintf (flag, "%d", toggles[6] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[6]);
    strcat (str, "\1");

    sprintf (flag, "%d", toggles[7] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[7] );
    strcat (str, "\1");
   
    sprintf (flag, "%d", toggles[8] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[8] );
    strcat (str, "\1");

    sprintf (flag, "%d", toggles[9] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[9] );
    strcat (str, "\1");

    sprintf (flag, "%d", toggles[11] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[11] );
    strcat (str, "\1");

    sprintf (flag, "%d", toggles[12] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[12] );
    strcat (str, "\1");

    sprintf (flag, "%d", toggles[14] );
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, files[14] );
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug ((fname, "MEMwrite : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ALL_DEBUG, info);
    _NFMRdebug ((fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug ((fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug ((fname, "Return Status : <0x%.8x>\n", ret_status));

    return (ret_status); 
}
 
long NFMRclient_debug ( toggles, files )

int  toggles[NFM_DEBUG_SUBSYSTEMS];
		 /* i - array of subsystem debugs on (1) or off (0) */
char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
		 /* i - array of subsystem debug filenames */
{
static char *fname = "NFMRall_debug";

_NFMRdebug ((fname, "NFI       : <%d>\n", toggles[0]));
_NFMRdebug ((fname, "NFI  File : <%s>\n", files[0]));
_NFMRdebug ((fname, "NFMR      : <%d>\n", toggles[2] ));
_NFMRdebug ((fname, "NFMR File : <%s>\n", files[2] ));
_NFMRdebug ((fname, "NETC      : <%d>\n", toggles[3] ));
_NFMRdebug ((fname, "NETC File : <%s>\n", files[3] ));
_NFMRdebug ((fname, "MEMC      : <%d>\n", toggles[4] ));
_NFMRdebug ((fname, "MEMC File : <%s>\n", files[4] ));
_NFMRdebug ((fname, "ERRC      : <%d>\n", toggles[5] ));
_NFMRdebug ((fname, "ERRC File : <%s>\n", files[5] ));

    _NFMdebug_st.NFIdebug_on = toggles[0];
    strncpy( _NFMdebug_st.NFIdebug_file, files[0],
	     sizeof( _NFMdebug_st.NFIdebug_file ) - 1 );

    _NFMdebug_st.NFMRdebug_on = toggles[2];
    strncpy( _NFMdebug_st.NFMRdebug_file, files[2],
	     sizeof( _NFMdebug_st.NFMRdebug_file ) - 1 );

    _NFMdebug_st.NETCdebug_on = toggles[3];
    strncpy( _NFMdebug_st.NETCdebug_file, files[3],
	     sizeof( _NFMdebug_st.NETCdebug_file ) - 1 );

    _NFMdebug_st.MEMdebug_on = toggles[4];
    strncpy( _NFMdebug_st.MEMdebug_file, files[4],
	     sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );

    _NFMdebug_st.ERRdebug_on = toggles[5];
    strncpy( _NFMdebug_st.ERRdebug_file, files[5],
	     sizeof( _NFMdebug_st.ERRdebug_file ) - 1 );

    return (NFM_S_SUCCESS); 
}
 
long NFMRdebug (nfm, nfm_file, net, net_file, sql, sql_file, mem, mem_file)

int  nfm;       /* i - nfm debug on (1) or off (0) */
char *nfm_file; /* i - nfm debug_file */
int  net;       /* i - net debug on (1) or off (0) */
char *net_file; /* i - net debug_file */
int  sql;       /* i - sql debug on (1) or off (0) */
char *sql_file; /* i - sql debug_file */
int  mem;       /* i - mem debug on (1) or off (0) */
char *mem_file; /* i - mem debug_file */

{
MEMptr info = NULL;
char   str[512];
long   status = 0;
long   ret_status = 0;
char   flag[2];

static char *fname = "NFMRdebug";

    _NFMRdebug ((fname, "NFM      : <%d>\n", nfm));
    _NFMRdebug ((fname, "NFM file : <%s>\n", nfm_file));
    _NFMRdebug ((fname, "NET      : <%d>\n", net));
    _NFMRdebug ((fname, "NET file : <%s>\n", net_file));
    _NFMRdebug ((fname, "SQL      : <%d>\n", sql));
    _NFMRdebug ((fname, "SQL file : <%s>\n", sql_file));
    _NFMRdebug ((fname, "MEM      : <%d>\n", mem));
    _NFMRdebug ((fname, "MEM file : <%s>\n", mem_file));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug ((fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfm", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "nfm_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "net", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "net_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "sql", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "sql_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "mem", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "mem_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (flag, "%d", nfm);
    strcpy (str, flag);
    strcat (str, "\1");
    strcat (str, nfm_file);
    strcat (str, "\1");

    sprintf (flag, "%d", net);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, net_file);
    strcat (str, "\1");

    sprintf (flag, "%d", sql);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, sql_file);
    strcat (str, "\1");

    sprintf (flag, "%d", mem);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, mem_file);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug ((fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DEBUG, info);
    _NFMRdebug ((fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status );
    _NFMRdebug ((fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug ((fname, "Return Status : <0x%.8x>\n", ret_status));

    return (ret_status); 
}
