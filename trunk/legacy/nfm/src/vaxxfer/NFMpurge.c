#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

/***********************************************************************
*                                                                       *
*                       NFMfs_purge                                     *
*                                                                       *
*       This function will delete all the files in the buffer. The      *
*        CIFILENAME will be used to identify the file                   *
*       n_status will be changed from NFM_PURGE to NFM_PURGED           *
************************************************************************/


 long NFMfs_purge (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
	return(NFMrm_ci_files(buffer_ptr));
   }

/***********************************************************************
*                                                                       *
*                       _NFMfs_undo_recv_files                          *
*                                                                       *
*       This function is used to undo the operation performed by        *
*        _NFMfs_recv_files. This can be called after a partial failure  *
*       or after a successful completion.                               *
*       All files with n_status set to NFM_TRANSFERED, NFM_READ_ONLY         *
*       NFM_NFSED will be handled.                                      *
*       n_status        n_status                Action                  *
*       before          after                                           *
*       NFM_TRANSFERED  NFM_UNDONE              Delete COFILENAME       *
*       NFM_NFSED       NFM_NFS_UNDONE          Undo nfs mount/link     *
*       NFM_READ_ONLY        NFM_READ_DONE           Change mode on          *
*                                               COFILENAME to Read only *
*                       NFM_FAILURE             Operation Failed        *
*                                                                       *
************************************************************************/


 long _NFMfs_undo_recv_files (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     return(NFMrm_co_files(buffer_ptr,0));
   }

/***********************************************************************
*                                                                       *
*                       _NFMfs_undo_send_files                          *
*                                                                       *
*       This function is used to undo the operation performed by        *
*        _NFMfs_send_files. This can be called after a partial failure  *
*       or after a successful completion.                               *
*       All files with n_status set to NFM_TRANSFERED,                  *
*       NFM_MOVE_MOVE_WARNING, and NFM_MOVE_TRANSFERED will be handled. *
*       n_status        n_status                Action                  *
*       before          after                                           *
*       NFM_TRANSFERED  NFM_UNDONE              Delete CIFILENAME       *
*       NFM_MOVE_MOVE_WARNING                                           *
*                       NFM_UNDONE              Delete CIFILENAME       *
*       NFM_MOVE_TRANSFERED                                             *
*                       NFM_MOVE_MOVE_UNDONE    Delete CIFILENAME       *
*                                               Move n_fileold to       *
*                                               CIFILENAME              *
************************************************************************/


 long _NFMfs_undo_send_files (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     return(NFMrm_ci_files(buffer_ptr));
   }

/***********************************************************************
*			NFMset_buf_stat					*
*									*
*	This procedure sets the buffer status to n_status in FTObuffer	*
************************************************************************/

long NFMset_buf_stat ( list , row_no,col_no,n_status)
	MEMptr list;
	long row_no,col_no,n_status;
{
	char status_str[FTO_MAX_LEN];
	long status;
	char *fname="NFMset_buf_stat";
	_NFMdebug((fname,"Entry: MEMptr list <%x> row_no <%d> col_no <%d> n_status <%d>\n",
list,row_no,col_no,n_status));
	sprintf(status_str,"%d",n_status);
	status=MEMwrite_data(list,status_str,row_no,col_no);
        if(status!=MEM_S_SUCCESS)
	{
               _NFMdebug ((fname,"MEMwrite_data: status = <0x%.8x>\n", status));
               ERRload_struct(NFM,NFM_E_MEM_FAILURE,"%s","MEMwrite_data");
		return(NFM_E_MEM_FAILURE);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
	
}
