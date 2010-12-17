
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "MEMstruct.h"
#include "NETdef.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMSextern.h"
#include "NETstruct.h"

#define BUFFER_SIZE          1000
#define NFM_DEBUG_SUBSYSTEMS 15

extern struct _ERRstruct   _ERRstruct;
/* 
 Doc: NFMSdebug
 
 Abstract:
     This function will turn debug on for the specified subsystems
     
 */
 
/*long NFMSdebug (in_list, out_list)

MEMptr in_list;
MEMptr *out_list;*/
/* Removing additional second argument - SSRS - 16/12/93 */
long NFMSdebug (in_list)

MEMptr in_list;

{
long status;
char **data_ptr;
static char *fname = "NFMSdebug";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "NFM      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "NFM File : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "NET      : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "NET File : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "SQL      : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "SQL File : <%s>\n", data_ptr[5]));
_NFMSdebug(( fname, "MEM      : <%s>\n", data_ptr[6]));
_NFMSdebug(( fname, "MEM File : <%s>\n", data_ptr[7]));

if (strncmp (data_ptr[0], "1", 1) == 0)
    NFMmsg_ptr.debug_on = 1;
else if (strncmp (data_ptr[0], "2", 1) == 0 )
    {
    NFMmsg_ptr.debug_on = 0;
    _ERRstruct.debug_on = 1;
    }
else if (strncmp (data_ptr[0], "3", 1) == 0 )
    {
    NFMmsg_ptr.debug_on = 1;
    _ERRstruct.debug_on = 1;
    }
else 
    {
    NFMmsg_ptr.debug_on = 0;
    _ERRstruct.debug_on = 0;
    }

/* file name is 16 characters in MSGstruct.h */

if (strcmp (data_ptr[1], "") != 0)
    {
    strncpy (NFMmsg_ptr.debug_file, data_ptr[1],
             (sizeof (NFMmsg_ptr.debug_file) - 1));
    strncpy (_ERRstruct.debug_file, data_ptr[1],
             (sizeof (_ERRstruct.debug_file) - 1));
    }

status = NFMSsend_error_buffers( NFM_S_SUCCESS, NFM_S_SUCCESS );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (NFM_S_SUCCESS);
}
 
/*long NFMSall_debug (in_list, out_list)

MEMptr in_list;
MEMptr *out_list;*/
/* Removing additional second argument - SSRS - 16/12/93 */
long NFMSall_debug (in_list)

MEMptr in_list;

{
long status;
long ret_status;

int  toggles[NFM_DEBUG_SUBSYSTEMS];
int  i;

char **data_ptr;
char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

static char *fname = "NFMSall_debug";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

    for( i=0; i<NFM_DEBUG_SUBSYSTEMS; ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "/dev/console" );
    }

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
	_NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "NFI      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "NFI File : <%s>\n", data_ptr[1]));
    toggles[0] = atoi( data_ptr[0] );
    strncpy( files[0], data_ptr[1], sizeof( _NFMdebug_st.NFIdebug_file )-1);

_NFMSdebug(( fname, "NFMR      : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "NFMR File : <%s>\n", data_ptr[3]));
    toggles[2] = atoi( data_ptr[2] );
    strncpy( files[2], data_ptr[3], sizeof( _NFMdebug_st.NFMRdebug_file )-1);

_NFMSdebug(( fname, "NETC      : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "NETC File : <%s>\n", data_ptr[5]));
    toggles[3] = atoi( data_ptr[4] );
    strncpy( files[3], data_ptr[5], sizeof( _NFMdebug_st.NETCdebug_file )-1);

_NFMSdebug(( fname, "MEMC      : <%s>\n", data_ptr[6]));
_NFMSdebug(( fname, "MEMC File : <%s>\n", data_ptr[7]));
    toggles[4] = atoi( data_ptr[6] );
    strncpy( files[4], data_ptr[7], sizeof( _NFMdebug_st.MEMdebug_file )-1);

_NFMSdebug(( fname, "ERRC      : <%s>\n", data_ptr[8]));
_NFMSdebug(( fname, "ERRC File : <%s>\n", data_ptr[9]));
    toggles[5] = atoi( data_ptr[8] );
    strncpy( files[5], data_ptr[9], sizeof( _NFMdebug_st.ERRdebug_file )-1);

_NFMSdebug(( fname, "NETS      : <%s>\n", data_ptr[10]));
_NFMSdebug(( fname, "NETS File : <%s>\n", data_ptr[11]));
    toggles[6] = atoi( data_ptr[10] );
    strncpy( files[6], data_ptr[11], sizeof( _NFMdebug_st.NETSdebug_file )-1);

_NFMSdebug(( fname, "NFMS      : <%s>\n", data_ptr[12]));
_NFMSdebug(( fname, "NFMS File : <%s>\n", data_ptr[13]));
    toggles[7] = atoi( data_ptr[12] );
    strncpy( files[7], data_ptr[13], sizeof( _NFMdebug_st.NFMSdebug_file )-1);

_NFMSdebug(( fname, "NFM       : <%s>\n", data_ptr[14]));
_NFMSdebug(( fname, "NFM File  : <%s>\n", data_ptr[15]));
    toggles[8] = atoi( data_ptr[14] );
    strncpy( files[8], data_ptr[15], sizeof( _NFMdebug_st.NFMdebug_file )-1);

_NFMSdebug(( fname, "SQL       : <%s>\n", data_ptr[16]));
_NFMSdebug(( fname, "SQL File  : <%s>\n", data_ptr[17]));
    toggles[9] = atoi( data_ptr[16] );
    strncpy( files[9], data_ptr[17], sizeof( _NFMdebug_st.SQLdebug_file )-1);

_NFMSdebug(( fname, "MEM       : <%s>\n", data_ptr[18]));
_NFMSdebug(( fname, "MEM File  : <%s>\n", data_ptr[19]));
    toggles[11] = atoi( data_ptr[18] );
    strncpy( files[11], data_ptr[19], sizeof( _NFMdebug_st.MEMdebug_file )-1);

_NFMSdebug(( fname, "UTI       : <%s>\n", data_ptr[20]));
_NFMSdebug(( fname, "UTI File  : <%s>\n", data_ptr[21]));
    toggles[12] = atoi( data_ptr[20] );
    strncpy( files[12], data_ptr[21], sizeof( _NFMdebug_st.UTIdebug_file )-1);

_NFMSdebug(( fname, "ERR       : <%s>\n", data_ptr[22]));
_NFMSdebug(( fname, "ERR File  : <%s>\n", data_ptr[23]));
    toggles[14] = atoi( data_ptr[22] );
    strncpy( files[14], data_ptr[23], sizeof( _NFMdebug_st.ERRdebug_file )-1);

ret_status = NFMall_debug ( toggles, files );
_NFMSdebug(( fname, "NFMall_debug <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return( ret_status );
}
