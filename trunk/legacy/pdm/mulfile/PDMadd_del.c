#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"NFMapi.h"
#include		"PDMdbs_err.h"
#include		"PDMproto.h"

extern int      PDMdebug_on;
extern PDMpart_ptr PDMpart;
extern char     PDM_DEBUG_FILE[];
static long     status;
/*static int      curbuf_no;*/
extern PDMexec_ptr PDMexec;


int PDMdelete_files_from_part (data_list)
	MEMptr          data_list;
{
        static char  *fname = "PDMdelete_files_from_part:";
        short          sts;
	MEMptr          dummy_attr = NULL;
	MEMptr          dummy_data = NULL;
	MEMptr          dummy_list = NULL;
        char            sql_str[512];

	_PDMdebug(fname, "Enter\n");
      
if (PDMdebug_on) {
   MEMprint_buffers ("PDU returned buffer", data_list, PDM_DEBUG_FILE);
     }

         status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num, 
                                    PDMexec->revision);
          if(status != PDM_S_SUCCESS)
          {
            if(status == PDM_E_PART_NOT_FOUND) 
              return(PDM_E_PART_NOT_FOUND);
           _PDMdebug(fname, "PDMload_part_info failed status %d\n", status);
           return(PDM_E_LOAD_PART);
           }

/* You can't detach a file to a non-graphic part */
        if(!strcmp(PDMpart.p_parttype, "N")) {
_PDMdebug (fname, "You can't detach a file to a non-graphic part \n");
            return(PDM_E_PART_NONGRAPHIC);
      }
/* You can't detach a file to a checked in part */
  else if(!strcmp(PDMpart.n_status, "O") || !strcmp(PDMpart.n_status, "S")) {
_PDMdebug (fname, " You can't detach a file to a checked in part \n");
            return(PDM_E_PART_CHECKEDIN);
      }
/* You can't detach a file to a archived part */
 else if(!strcmp(PDMpart.n_archivestate, "A") || 
             !strcmp(PDMpart.n_archivestate, "B") ) {
_PDMdebug (fname, " You can't detach a file to a archived part \n");
                return(PDM_E_PART_ARCHIVED);
      }
/* You can't detach a file to a locked part */
/* No! No! The Item is gonna be locked when you come to this part! MaC 121492*/
/*
 else if(!strcmp(PDMpart.n_itemlock, "Y") || !strcmp(PDMpart.n_itemlock, "y") ) {
_PDMdebug (fname, " You can't detach a file to a locked part \n");
                return(PDM_E_ITEM_LOCKED);
      }
*/
 else if(!strcmp(PDMpart.n_pendingflag, "IA") || 
             !strcmp(PDMpart.n_pendingflag, "IB") ) {
                return(PDM_E_ITEM_FLAGGED);
      }
        /*  pull out data_list from input */

_PDMdebug (fname, "Pulling out data_list from input \n");
       
       /* Make a transaction processing so as to roll back */
        status = PDMstart_transaction(0);
        if (status != PDM_S_SUCCESS) {
               MEMclose(&data_list);
           _PDMdebug(fname, "PDMstart_transaction failed status %d\n", status);
                goto wrapup;
        }
sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
      SQLstmt(sql_str);

        /* Delete the file(s) from the part */
status = NFMget_file_information(PDMexec->catalog, PDMexec->part_num, PDMexec->revision, NFM_DELETE_FILE_FROM_ITEM, &dummy_attr, &dummy_data, &dummy_list);
                MEMclose(&dummy_attr);
                MEMclose(&dummy_data);
                MEMclose(&dummy_list);

        status = NFMdefine_file_information(PDMexec->catalog, PDMexec->part_num, 
                 PDMexec->revision, NFM_DELETE_FILE_FROM_ITEM, data_list);
        if(status != NFM_S_SUCCESS)
            {
              MEMclose(&data_list);
       _PDMdebug(fname, "NFMdefine_file_information failed status %d\n", status);
sts = NFMreset_file_information(PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
            if(sts != NFM_S_SUCCESS)
                {
                        return(PDM_E_CANCEL_UPDATE_ITEM);
                }
                goto wrapup;
            }

       /*   commit the transaction */    
        status = PDMstop_transaction(0);
        if (status != PDM_S_SUCCESS) {
               MEMclose(&data_list);
           _PDMdebug(fname, "PDMstop_transaction failed status %d\n", status);
                goto wrapup;
        }
	return (PDM_S_SUCCESS);
wrapup:

        sts = PDMrollback_transaction(0);
        if (sts != PDM_S_SUCCESS) {
           _PDMdebug(fname, "PDMstop_transaction failed status %d\n", status);
        }
        return (status);
}





