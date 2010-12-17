
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMlisten.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NETdef.h"

 long NFMswitch_command (in_pipe, out_pipe, in_command, in_list, out_list)
   long      *in_pipe, *out_pipe, in_command;
   MEMptr    in_list, *out_list;
   {
char *fname="NFMswitch_command ";
      long    status;
      MEMptr buffer_ptr, error_ptr;
      buffer_ptr = in_list ;
         
      _NFMdebug ((fname,"In  Pipe = <%d> Out Pipe = <%d> Command <%d>\n  ", *in_pipe  ,*out_pipe,in_command));

      switch (in_command)
       {
         case NFM_FILE_SEND :
           status = NFMfile_send_s (in_pipe, out_pipe);
	   switch (status)
	   {
		case NFM_E_TLI_SEND_FS1_FS2:
		case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
		case NFM_E_TLI_RECEIVE_FS1_FS2:
		_NFMdebug((fname,"Connection lost with fileserver1: Exiting\n"));
		exit();
		break;
		default:
                break;   /* 12/16/92 - KT - SUN Port */
	
	   }
           break;

         case NFM_FILE_RECEIVE :
           status = NFMfile_receive_s (in_pipe, out_pipe);
	   switch (status)
	   {
		case NFM_E_TLI_SEND_FS1_FS2:
		case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
		case NFM_E_TLI_RECEIVE_FS1_FS2:
		_NFMdebug((fname,"Connection lost with fileserver1: Exiting\n"));
		exit();
		break;
		default:
                break;   /* 12/16/92 - KT - SUN Port */
	
	   }
           break;

         case NFM_FILE_COPY :
           status = NFMfile_copy_s (in_pipe, out_pipe);
	   switch (status)
	   {
		case NFM_E_TLI_SEND_FS1_FS2:
		case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
		case NFM_E_TLI_RECEIVE_FS1_FS2:
		_NFMdebug((fname,"Connection lost with fileserver1: Exiting\n"));
		exit();
		break;
		default:
                break;   /* 12/16/92 - KT - SUN Port */
	
	   }
           break;
	 
         case NFM_SEND_FILES :
           status = NFMser_get_files_out (in_list, out_list);
           break;

         case NFM_RECEIVE_FILES :
           status = NFMser_get_files_in (in_list, out_list);
           break;

         case NFM_COPY_FILE :
           status = NFMser_copy_file (in_list, out_list);
           break;

         case NFM_DELETE_IN_FILES :
           status = NFMser_delete_files_ci (in_list, out_list);
           break;

         case NFM_DELETE_OUT_FILES :
           status = NFMser_delete_files_co (in_list, out_list);
           break;

         case NFM_BULK_LOAD :
           status = NFMser_get_bulk_data (in_list, out_list);
           break;

/* New Cases */
	 case NFM_DEST_RECEIVE_FILES:
	   /*status = NFMfs_dest_recv_clix ( &buffer_ptr, &error_ptr);*/
           /* Removed second argument as function def. has only one 
              SSRS - 14/12/93 
           */
	   status = NFMfs_dest_recv_clix ( &buffer_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_SRC_SEND_FILES:
	   /*status = NFMfs_src_send_clix ( &buffer_ptr, &error_ptr);*/
           /* Removed second argument as function def. has only one 
              SSRS - 14/12/93 
           */
	   status = NFMfs_src_send_clix ( &buffer_ptr );
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_RM_CO_FILES:
	   status = NFMfs_rm_co_files ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_RM_CI_FILES:
	   status = NFMfs_rm_ci_files ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_RENAME_FILES:
	   status = NFMfs_rename_files ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_UNDO_RENAME_FILES:
	   status = NFMfs_undo_rename_files ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_GET_MICRO_FILES:
	   status = NFMfs_get_micro_files ( in_list, out_list);
	   break;
	 case NFM_GET_ACAD_FILES:
	   status = NFMfs_get_acad_files ( in_list, out_list);
	   break;
	 case NFM_DEST_PLOT_FILES:
	   status = NFMfs_dest_plot_clix ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;
	 case NFM_NFS_CLEANUP:
	   status = NFMfs_dest_nfs_cleanup ( &buffer_ptr, &error_ptr);
	   *out_list = buffer_ptr ;
	   break;

/* New Cases to Handle FTR Options file Operations */

         case NFM_FTR_NO_OP_LOCK :
           status = NFMftr_no_op_lock_s ((int *)in_pipe, (int *)out_pipe);
	   switch (status)
	   {
		case NFM_E_TLI_SEND_FS1_FS2:
		case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
		case NFM_E_TLI_RECEIVE_FS1_FS2:
		_NFMdebug((fname,"Connection lost with fileserver1: Exiting\n"));
		exit();
		break;
		default:
                break;   /* 12/16/92 - KT - SUN Port */
	
	   }
           break;

         case NFM_FTR_OPTIONS_FILE_RESET :
           status = NFMftr_options_file_reset_s ((int *)in_pipe, (int *)out_pipe);
	   switch (status)
	   {
		case NFM_E_TLI_SEND_FS1_FS2:
		case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
		case NFM_E_TLI_RECEIVE_FS1_FS2:
		_NFMdebug((fname,"Connection lost with fileserver1: Exiting\n"));
		exit();
		break;
		default:
                break;   /* 12/16/92 - KT - SUN Port */
	
	   }
           break;
	 

	 
/*
         case NFM_READ_REPORT_FILE :
           status = NFMser_read_report (in_list, out_list);
           break;

         case NFM_READ_SEARCH_FILE :
           status = NFMser_read_search (in_list, out_list);
           break;

         case NFM_READ_SORT_FILE :
           status = NFMser_read_sort (in_list, out_list);
           break;

         case NFM_WRITE_REPORT_FILE :
           status = NFMser_write_report (in_list, out_list);
           break;

         case NFM_WRITE_SEARCH_FILE :
           status = NFMser_write_search (in_list, out_list);
           break;

         case NFM_WRITE_SORT_FILE :
           status = NFMser_write_sort (in_list, out_list);
           break;
*/
         default :
           status = NFM_E_UNKNOWN_COMMAND;
	   ERRload_struct(NFM,status,"");
           break;
       }

     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"Switch Comm : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname,"SUCCESS : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }
