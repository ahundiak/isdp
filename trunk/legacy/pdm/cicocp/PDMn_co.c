#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"NFMstruct.h"
#include                "PDUstorage.h"
#include                "ERR.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"
#include		"PDUnode.h"
#include		"PDMmessage.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
char     PDMuser[25];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;
static char     s[1024];
extern struct sto_area_info STO_info;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;
extern struct PDUcat_node *PDMparam_cat_list;
extern struct PDUstorage *storage;
extern char   glob_var[100];

/* additional declarations for NFM3.0 */
#include                "NFMschema.h"
#include                "NFMapi.h"
#include                "NFMitems.h"
#include                "NFMitemfiles.h"
#include                "WFexterns.h"
extern struct NFMwf_info  PDMwf_info;
extern struct NFMoperation  *PDMoperation, *PDMlast_oper;

/* Global variable to maintain processed items and files information */

extern struct NFMitem_entry  *NFMitem_files;

#define UPDMEM   7   /* file moved due to obselete fileversion */
#define ATTCH   8   /* file attached but local */
#define MOVE    9   /* file attached and not local */
#define NOPE    10   /* file not attached */





/*
 * The part is either an assy or atomic part If it is atomic use
 * NFMprepare_item_checkout  & NFMcomplete_item_checkout If it is an assy
 * Handle CIT attachments using NFMprepare_set_checkout  &
 * NFMcomplete_set_checkout
 * 
 * BOM attachments are handled individually by PDM
 */

int PDMcheckout_part(file_bufr, out_file_bufr, attach_bufr)
	MEMptr          file_bufr;
	MEMptr		*out_file_bufr;
	MEMptr		*attach_bufr;
{

	char		*fn = "PDMcheckout_part";
	char          **data;
	char            n_cofilename[40];
	char            sql_str[512];
        char            *msg = NULL;
        /*struct PDUcat_node  *para_cats = NULL;*/

	PDMdebug("ENTER: PDMcheckout_part:\n");

      msg = (char *)PDUtranslate_message(PDS_M_CHECKOUT_PART);
      strcpy(glob_var,msg);
  _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n",
                PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
   
        sql_str[0] = '\0';

	/* check if part exists */
	status = NFMstop_transaction (0);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn, "Stop Transaction : status = <0x%.8x>\n",
		    status);
		return (status);
	}
	status = NFMlock_table (PDMexec->catalog);
	if (status != NFM_S_SUCCESS) {
	    _PDMdebug (fn, "Set Co Out -> Temp In: <0x%.8x>\n", status);
            if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
	    return (status);
	}
	status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
	    PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
	    _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
	       status = NFMstart_transaction (0);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn, "Start Transaction : status = <0x%.8x>\n",
		    status);
		return (status);
	       }
	    return (PDM_E_COULD_NOT_LOAD_PART_INFO);
	}
        PDMupdate_dots();
        sprintf (sql_str, "UPDATE %s SET n_status = 'TO' WHERE n_itemno = %d",
                  PDMexec->catalog, PDMpart.n_itemno);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt failed status %d\n", status);
        status = _PDMget_db_error (status);
        return (status);
        }

	_PDMdebug (fn, "catno = %d, partno = %d, parttype = %s,n_status = %s\n",
    PDMpart.n_catalogno,PDMpart.n_itemno,PDMpart.p_parttype, PDMpart.n_status);

	status = NFMstart_transaction(0);
	if(status != NFM_S_SUCCESS) {
	   NFMrollback_transaction(0);
	   _PDMdebug (fn, "Start Transaction failed\n");
	   return(status);
	}



      if (strcmp(PDMpart.n_status, "I")) {
        if((!strcmp(PDMpart.n_status,"S")) ||
                     (!strcmp(PDMpart.n_status,"O"))) {
           if (strcmp (NFMglobal.NFMusername, PDMpart.n_couser)) {
          _PDMdebug (fn, "This user[%s]  not checkout_user[%s] \n",
                                    NFMglobal.NFMusername, PDMpart.n_couser);
           PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
           return(PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
           }
           else
           if (storage->storage_no != PDMpart.n_cosano) {
          _PDMdebug (fn, "This sa[%d]  not checkout_sa[%d] \n",
                                    storage->storage_no, PDMpart.n_cosano);
           PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
            return (PDM_E_CO_SAME_USER_DIFF_SA);
           }
          }
          else if ( !strcmp(PDMpart.n_status,"TI")) {
                return (PDM_E_TEMP_IN);

                    }
          else if ( !strcmp(PDMpart.n_status,"TO")) {
           return(PDM_E_TEMP_OUT);
                    }
           return(PDM_E_PART_CHECKED_OUT);
           }

	if (!strncmp(PDMpart.p_parttype, "N", 1) ||
                         !strncmp(PDMpart.p_parttype, "n", 1)) {
		_PDMdebug (fn,  "p_parttype is set to non-graphic\n");
		PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_PART_NONGRAPHIC);
	}
	if (!strncmp(PDMpart.n_itemlock, "Y", 1) ||
                     !strncmp(PDMpart.n_itemlock, "y", 1) ) {
		_PDMdebug (fn,  "Part is in a wrong state\n");
		PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_ITEM_LOCKED);
	}
      
       /* Kumar Better error messages 11/2/92 */
	if ((!strncmp(PDMpart.n_pendingflag, "IA", 2)) 
	 || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
		_PDMdebug (fn,  "Part is flagged for achive\n");
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
	else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2)) 
	 || (!strncmp(PDMpart.n_pendingflag, "SB", 2))) 
           {
		_PDMdebug (fn,  "Part is flagged for backup\n");
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
	else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2)) 
	 || (!strncmp(PDMpart.n_pendingflag, "SD", 2))) 
           {
		_PDMdebug (fn,  "Part is flagged for delete\n");
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
	else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2)) 
	 || (!strncmp(PDMpart.n_pendingflag, "SR", 2))) 
           {
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		_PDMdebug (fn,  "Part is flagged for delete\n");
		return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }

	/* can not checkout a part that is non graphic */

	/* set the name of the checkin file */

	status = MEMbuild_array(file_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&file_bufr);
		_PDMdebug (fn,  " %s %s %d \n",
		    "MEMbuild_array ", " failed status -> ", status);
		return (PDM_E_BUILD_ARRAY);
	}

	n_cofilename[0] = '\0';
	data = (char **) file_bufr->data_ptr;
	strcpy(n_cofilename, data[0]);
	MEMclose(&file_bufr);
	file_bufr = NULL;
	status = NFMstop_transaction(0);
	if(status != NFM_S_SUCCESS)
	{
		NFMrollback_transaction(0);
		_PDMdebug (fn, "Start Transaction failed\n");
		return(status);
	}

        /* reset the file_bufr */
        MEMclose(&file_bufr);
	file_bufr = NULL;

        PDMupdate_dots();
	if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
	    !strncmp(PDMpart.n_setindicator, "y", 1)) {
		status = PDMcheckout_assembly_part(
		                attach_bufr, out_file_bufr);

		if (status != PDM_S_SUCCESS) {
			_PDMdebug (fn,  "%s %s %d \n",
			    "PDMcheckout_part:PDMcheckout_assembly_part ",
			    "failed status ", status);
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
			return (status);
		}
	} else {
		/*status = PDMcheckout_atomic_part
		    (attach_bufr, out_file_bufr);*/
		status = PDMcheckout_atomic_part
		    (out_file_bufr);

		if (status != PDM_S_SUCCESS) {
			_PDMdebug (fn,  "%s %s %d \n",
			    "PDMcheckout_part:PDMcheckout_atomic_part ",
			    "failed status ", status);
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
			return (status);
		}
	}
        PDMupdate_dots();
        PDMreset_dots();
        
	PDMdebug("EXIT:PDMcheckout_part\n");
	return (PDM_S_SUCCESS);
}

/*
 * DESCRIPTION:  Checkout a part which is an assembly
 * 
 * CIT attachments are handled thru NFM File Mgr is used to check the transfers
 * BOM attachments are to be handled using NFMcopy_item
 */

int PDMcheckout_assembly_part(attach_bufr, file_bufr)
MEMptr          *attach_bufr;
MEMptr          *file_bufr;
{
	char		*fn = "PDMcheckout_assembly_part";
/*	char            active_bom[40];
	char            review_bom[40];*/
	MEMptr          out_bufr = NULL;
	char            sql_str[512];
        char            *msg = NULL;
	int             x;
	int             status1 = -1;
	int             level, storage_no;
	int             child_opt;
	long			nchildren;
	struct	NFMset_member	*set_head = (struct NFMset_member *) NULL;
	struct	NFMset_member	*set_end = (struct NFMset_member *) NULL;
	struct	NFMset_member	*temp_mem;
	struct	NFMset_member	*cur_mem;
        struct PDUcat_node            *head = NULL;
        struct PDUcat_node            *para_cats = NULL;

	PDMdebug("ENTER:PDMcheckout_assembly_part\n");

  _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n",
                PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
        PDMparam_cat_list = NULL;

        sql_str[0] = '\0';

	/* find BOM names */
	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug (fn, "PDMstop_transaction failed status %d\n", status);
	goto wrapup;
	}
/* commented out for new storage structure
	status = MEMbuild_array(strg_bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "MEMbuild_array ", " failed status -> ", status);
		return (PDM_E_BUILD_ARRAY);
	}
*/
	/* add code to manipulate global storage structure */
        strcpy (PDMuser, storage->user_name);
        storage_no = storage->storage_no;
/*
	strg_data = (char **) strg_bufr->data_ptr;
        strcpy (PDMuser, strg_data[3]);
        storage_no = atol (strg_data[0]);
*/

/* commented out as not used later 031292-MaC....
	active_bom[0] = '\0';
	review_bom[0] = '\0';

	status = PDMquery_bom_name( PDMexec->catalog,
	    				PDMexec->part_num,
	    				PDMexec->revision,
	    				"A", active_bom);

	if (status != PDM_S_SUCCESS && status != PDM_E_BOM_NOT_FOUND) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMquery_bom_name failed ", status);
		return (status);
	}
	status = PDMquery_bom_name( PDMexec->catalog,
	    				PDMexec->part_num,
	    				PDMexec->revision,
	    				"R", review_bom);
	if (status != PDM_S_SUCCESS && status != PDM_E_BOM_NOT_FOUND) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMquery_bom_name failed ", status);
		return (status);
	}
........... end comment  031292-MaC*/


	/* prepare checkout - complete checkout */

	level = PDMpart.p_maxlevel;
	if (level == 0)
		level = 50;

/* get the children for the assy */

        PDMupdate_dots();

	status = PDMget_assy_members (PDMpart.n_catalogno,
                                      PDMpart.n_itemno, 
                                      level, 
                                      &set_head, 
                                      &set_end, 
                                      &nchildren);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, 
                   "PDMget_assy_members failed status %d\n", status);
		goto wrapup;
	}

        PDMupdate_dots();

        /* load item and catalog names into the struct */
/*
      This information is already available in pdmcit table...
        status = PDMload_cat_part_info (PDMexec->catalog,
                                      PDMexec->part_num,
                                      PDMexec->revision,
                                      nchildren,
                                      set_head);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, 
                   "PDMload_cat_part_info failed status %d\n", status);
		goto wrapup;
	}
*/


/* added info about sano to get fmgr values .*/

	status = PDMget_fmgr_values ( PDMexec->catalog,
                                      PDMexec->part_num,
                                      PDMexec->revision,
                                      PDMpart.n_catalogno,
                                      PDMpart.n_itemno,
				      storage_no,
                                      nchildren,
                                      set_head, set_end,
                                      &out_bufr);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, 
                   "PDMget_fmgr_values failed status %d\n", status);
		goto wrapup;
	}

        PDMupdate_dots();

        _PDMdebug ( fn, "printing linked lists after fmgr..\n");
	if (PDMdebug_on) {
		MEMprint_buffer("out_bufr", out_bufr, PDM_DEBUG_FILE);
	}



	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, 
                   "PDMstart_transaction failed status %d\n", status);
		goto wrapup;
	}

/* additional changes made to accomodate NFM3.0 */

     /* call this function to make sure that global items/files info
      status = NFMset_load_item_files (NFM_LOAD_ITEM_FILE);
        is loaded */
      status = NFMset_load_item_files (1);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "NFMset_load_item_files  ", " failed status -> ", status);
		return (status);
	}

        PDMupdate_dots();
     /* generate the operation structure for the children to be
         moved */

        status =  PDMco_set_info_oper_struct (set_head,
                                              nchildren);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n",
                        "PDMco_set_info_oper_struct", status);
                goto wrapup;
           }

	child_opt = NFM_MEMBER_OPERATIONS;

_PDMdebug (fn, "before NFMcheckout_set, catalog = %s, n_catalogno = %d,\n\
part_num = %s, revision = %s, n_itemno = %d, storage->storage_name = %s,\n\
child_opt = %d\n", PDMexec->catalog, PDMpart.n_catalogno, PDMexec->part_num,
 PDMexec->revision, PDMpart.n_itemno, storage->storage_name, child_opt);

if (PDMdebug_on) {
_PDMdebug (fn, "\nPDMoperation array before NFMcheckout_set:\n");
        for (x=0; (strlen ((PDMoperation+x)->catalog))  ; ++x) {
        sprintf  (s, 
        "PDMoperation->catalog = %s, item_name = %s, item_rev = %s\n",
         (PDMoperation+x)->catalog, (PDMoperation+x)->item_name,
          (PDMoperation+x)->item_rev);
PDMdebug (s);
}
_PDMdebug (fn, "\nExtra member allocated:\n");
 ++x;
sprintf  (s, "PDMoperation->transfer = %d, delete = %d, purge = %d, \n\
catalog = %s, item_name = %s, item_rev = %s\n",
(PDMoperation+x)->transfer, (PDMoperation+x)->delete, (PDMoperation+x)->purge,
(PDMoperation+x)->catalog, (PDMoperation+x)->item_name,
           (PDMoperation+x)->item_rev);
PDMdebug (s);
}
        NFMitem_files = (struct NFMitem_entry *) NULL;
       /* _PDMdebug (fn, "NFMglobal.date_format[%s]\n",
	                           NFMglobal.date_format); */

        sprintf (sql_str, "UPDATE %s SET n_status = 'I' WHERE n_itemno = %d",
                  PDMexec->catalog, PDMpart.n_itemno);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS) {
              status = _PDMget_db_error (status);
        _PDMdebug (fn, "SQLstmt failed status %d\n", status);
        return (status);
        }


        PDMupdate_dots();
        status = NFMcheckout_set ( PDMexec->catalog,
                                   PDMpart.n_catalogno,
                                   PDMexec->part_num,
                                   PDMexec->revision,
                                   PDMpart.n_itemno,
                                   storage->storage_name,
                                   PDMwf_info,
                                   child_opt,
                                   PDMoperation,
                                   level);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn, 
		    "NFMcheckout_set failed status %d\n", status);
/*
                if (status == NFM_E_SET_OUT) {
                        status = PDM_E_ASSY_NOT_CHECKEDIN;
                } else if (status == NFM_E_NO_FILE) {
                        status = PDM_E_NO_PART_FILE;
                } else if (status == NFM_E_ITEM_FLAG_DELETE) {
                        status = PDM_E_ITEM_FLAG_DELETE;
                } else if (status == NFM_E_ITEM_FLAG_BACKUP) {
                        status = PDM_E_ITEM_FLAG_BACKUP;
                } else if (status == NFM_E_ITEM_FLAG_ARCHIVE) {
                        status = PDM_E_ITEM_FLAG_ARCHIVE;
                } else if (status == NFM_E_SET_FLAG_BACKUP) {
                        status = PDM_E_SET_FLAG_BACKUP;
                } else if (status == NFM_E_SET_FLAG_ARCHIVE) {
                        status = PDM_E_SET_FLAG_ARCHIVE;
                }
*/
    ERRget_specific_number (NFM, &status);
    _PDMdebug (fn, "status = %d\n", status);
   _PDMdebug (fn, "****CHECKOUT FAILED *****\n");
     if (status == NFM_E_LOCK_TABLE_FAILED)
           status = PDM_I_TABLE_LOCKED;
                goto cleanup1;
        }

	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug (fn,  "PDMstop_transaction failed status %d\n", status);
	goto cleanup;
	}

        PDMupdate_dots();
       
        _PDMdebug (fn, "Locking nfmsafiles in share mode\n");

	/* Update pdmfilemgr info */

        sprintf(sql_str, "LOCK TABLES NFMSAFILES IN SHARE MODE");
         status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS) {
           PDMupdate_dots ();
           msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_FILE_ACCESS);
           UI_status (msg);
           sleep (30);
           sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
           if(status != SQL_S_SUCCESS) {
             UI_status (msg);
             sleep (30);
             sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
             if(status != SQL_S_SUCCESS) {
                sprintf(s, "LOCK NFMSAFILES failed status %d\n", status);
                PDMdebug(s);
                msg = (char *)PDUtranslate_message(PDS_M_CHECKIN_CHECKOUT_PROGRESS);
                UI_status (msg);
                goto cleanup;
                }
              }
            }



        if (NFMitem_files != (struct NFMitem_entry *) NULL) {

        NFMprint_item_file_information (NFMitem_files);

        status =  PDMco_update_filemanager (PDMexec->catalog,
                                             PDMexec->part_num,
                                               PDMexec->revision,
                                               PDMpart.n_catalogno,
                                               PDMpart.n_itemno,
                                              set_head, set_end,
                                              out_bufr, file_bufr);

	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMco_update_filemanager failed ", status);
                NFMfree_item_file_information (NFMitem_files);
		goto cleanup;
	}

       /* unlocking the table ..*/

        PDMupdate_dots();

         status = NFMfree_item_file_information (NFMitem_files);
	 if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "NFMfree_item_file_information failed ", status);
		goto cleanup;
	}

     /* call this function to make sure that global items/files info
      status = NFMset_load_item_files (0);
        is not loaded for next command... */
      status = NFMset_load_item_files (NFM_NO_LOAD_ITEM_FILE);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "NFMset_load_item_files  ", " failed status -> ", status);
		return (status);
	}
 }
         
	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
		goto cleanup;
	}
/* added 041692 -MaC*/

         
	status = PDMload_attach_buffer (set_head, set_end, attach_bufr);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  
                  "PDMload_attach_buffer failed status %d\n", status);
		goto cleanup;
	}

	status = MEMbuild_array (*file_bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "MEMbuild_array: file_bufr: ", 
                         " failed status -> ", status);
		goto cleanup;
	}

        PDMupdate_dots();
   /* added a fix if none of the children are attached...050492-MaC*/
/* Mychelle - commented out for 2.1
	status = MEMbuild_array (*attach_bufr);
	if  (status == MEM_S_SUCCESS) {
       status = MEMappend (*attach_bufr, *file_bufr);
        if (status  != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMappend status = <%d>\n", status);
                return (PDM_E_APPEND_BUFFER);
                    }

   MEMclose (attach_bufr);
   if(PDMdebug_on) {
                MEMprint_buffers ("file_bufr",
                                        *file_bufr, PDM_DEBUG_FILE);
                 }
           }
	else  {
              if (status != MEM_E_NULL_LIST) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "MEMbuild_array: attach: ", 
                     " failed status -> ", status);
		goto cleanup;
	       }
         }
*/
	  if ((*attach_bufr) && (PDMdebug_on))
            MEMprint_buffer("attach_buffer", *attach_bufr, PDM_DEBUG_FILE);
          else
            PDMdebug("attach buffer is NULL");
          if(PDMdebug_on) {
             MEMprint_buffer ("single file_bufr",
                                        *file_bufr, PDM_DEBUG_FILE);
                 }


/* end of additions 041692 -MaC*/

	MEMclose(&out_bufr);

/* free all the structures allocated */

        _PDMdebug (fn, "freeing PDMoperation ...\n");
         free (PDMoperation); 
        _PDMdebug (fn, "freeing NFMset_member struct ...\n");
        for (cur_mem = set_head; cur_mem != (struct NFMset_member *) NULL; ) {
            temp_mem = cur_mem;
            cur_mem = cur_mem->next;
            _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n", 
                            temp_mem->cat_name, temp_mem->item_name);
            free ( temp_mem );
        
         }
        _PDMdebug (fn, "done freeing ...\n");

        PDMupdate_dots();
  status = PDMattach_macro_library(storage->storage_name, PDMparam_cat_list);
	if (status1 != PDM_S_SUCCESS) 
      _PDMdebug (fn,  "PDMattach_macro_library failed status %d\n", status);
        para_cats = PDMparam_cat_list;

/* Free up PDU_param_cat_list */
  if(para_cats != NULL)
     {
      head = PDMparam_cat_list;
      while (para_cats)
            {
             para_cats = para_cats->next;
             free(head);
             head = para_cats;
            } /* end while loop */
      }
      PDMparam_cat_list = NULL;

	PDMdebug("EXIT:PDMcheckout_assembly_part\n");
	return (PDM_S_SUCCESS);

wrapup:
	status1 = PDMrollback_transaction(1200);
	if (status1 != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "PDMrollback_transaction failed status %d\n", status1);
	}
        _PDMdebug (fn, "freeing PDMoperation ...\n");
         free (PDMoperation); 
        _PDMdebug (fn, "freeing NFMset_member struct ...\n");
        for (cur_mem = set_head; cur_mem != (struct NFMset_member *) NULL; ) {
            temp_mem = cur_mem;
            cur_mem = cur_mem->next;
            _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n", 
                            temp_mem->cat_name, temp_mem->item_name);
            free ( temp_mem );
        
         }
        _PDMdebug (fn, "done freeing ...\n");
	return (status);
cleanup:
        if (NFMitem_files != (struct NFMitem_entry *) NULL) {
         NFMfree_item_file_information (NFMitem_files);
                }
	 PDMrollback_transaction(1200);
         status1 = NFMcancel_check_out_set ( PDMexec->catalog, 
                                                    PDMpart.n_catalogno, 
                                                    PDMexec->part_num, 
                                                    PDMexec->revision, 
                                                    PDMpart.n_itemno, 
                                                    PDMwf_info, 
                                                    child_opt, 
                                                    PDMoperation, level);
	if (status1 != NFM_S_SUCCESS) {
	  _PDMdebug (fn,  "NFMcancel_checkout_set failed status %d\n", status1);
	}
        _PDMdebug (fn, "freeing PDMoperation ...\n");
         if (PDMoperation) free (PDMoperation); 
        _PDMdebug (fn, "freeing NFMset_member struct ...\n");
        for (cur_mem = set_head; cur_mem != (struct NFMset_member *) NULL; ) {
            temp_mem = cur_mem;
            cur_mem = cur_mem->next;
            _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n", 
                            temp_mem->cat_name, temp_mem->item_name);
            if (temp_mem) free ( temp_mem );
        
         }
        _PDMdebug (fn, "done freeing ...\n");
	return (status);

cleanup1:
        _PDMdebug(fn, "executing cleanup1\n");
        if (NFMitem_files != (struct NFMitem_entry *) NULL)
          {
          NFMfree_item_file_information (NFMitem_files);
          }
	PDMrollback_transaction(1200);
        _PDMdebug (fn, "freeing PDMoperation ...\n");
         free (PDMoperation); 
        _PDMdebug (fn, "freeing NFMset_member struct ...\n");
        for (cur_mem = set_head; cur_mem != (struct NFMset_member *) NULL; )
            {
            temp_mem = cur_mem;
            cur_mem = cur_mem->next;
            _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n", 
                            temp_mem->cat_name, temp_mem->item_name);
            free ( temp_mem );
            }
        _PDMdebug (fn, "done freeing ...\n");
	return (status);
}

/*
 * Part is not an assembly therefore there are no attachments from BOM
 */

int PDMcheckout_atomic_part(file_bufr)
/*
int PDMcheckout_atomic_part(attach_bufr, file_bufr)
MEMptr          *attach_bufr;*/
MEMptr          *file_bufr;
{
	MEMptr          file_list = NULL;
	int		storage_no;
	char		*fn = "PDMcheckout_atomic_part";
	char            sql_str[512];
        char            *msg = NULL;
	int		status1 = 0;
	int		status2 = 0;

	PDMdebug("ENTER:PDMcheckout_atomic_part\n");

	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "PDMstop_transaction failed status %d\n", status);
		goto wrapup;
	}

        sql_str[0] = '\0';

/* commented out for new storage structure 
	status = MEMbuild_array(strg_bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug (fn,  " %s %s %d \n",
		    "MEMbuild_array ", " failed status -> ", status);
		return (PDM_E_BUILD_ARRAY);
	}
	strg_data = (char **) strg_bufr->data_ptr;
        storage_no = atol (strg_data [0]);
*/
        storage_no = storage->storage_no;

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
		goto wrapup;
	}

/* additional changes made to accomodate NFM3.0 */

        status =  PDMset_info_oper_struct (PDMexec->catalog,
                                             PDMexec->part_num,
                                               PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n",
                        "PDMset_info_oper_struct", status);
                goto wrapup;
           }

        PDMupdate_dots();
	_PDMdebug(fn, "%s %s\n", 
                  "storage->storage_name = ", storage->storage_name);
	PDMdebug("calling NFMcheckout_item\n");

        sprintf (sql_str, "UPDATE %s SET n_status = 'I' WHERE n_itemno = %d",
                  PDMexec->catalog, PDMpart.n_itemno);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt failed status %d\n", status);
         return(status = _PDMget_db_error (status));
        }

        status = NFMcheckout_item ( PDMexec->catalog,
                                   PDMpart.n_catalogno,
                                   PDMexec->part_num,
                                   PDMexec->revision,
                                   storage->storage_name,
                                   PDMwf_info,
                                   *PDMoperation);
	if (status != NFM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "NFMcheckout_item  failed status ",
		    status);
    ERRget_specific_number (NFM, &status);
    _PDMdebug (fn, "status = %d\n", status);
     if (status == NFM_E_LOCK_TABLE_FAILED)
           status = PDM_I_TABLE_LOCKED;
		return (status);
	}
        PDMupdate_dots();
	PDMdebug("after NFMcheckout_item\n");
	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn,  "PDMstop_transaction failed status %d\n", status);
	   goto wrapup;
	}

	/* update fmgr */
       
        _PDMdebug (fn, "Locking nfmsafiles in share mode\n");
        sprintf(sql_str, "LOCK TABLES NFMSAFILES IN SHARE MODE");
         status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS) {
           PDMupdate_dots ();
           msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_FILE_ACCESS);
           UI_status (msg);
           sleep (30);
           sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
           if(status != SQL_S_SUCCESS) {
             UI_status (msg);
             sleep (30);
             sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
             if(status != SQL_S_SUCCESS) {
                sprintf(s, "LOCK NFMSAFILES failed status %d\n", status);
                PDMdebug(s);
                msg = (char *)PDUtranslate_message(PDS_M_CHECKIN_CHECKOUT_PROGRESS);
                UI_status (msg);
                goto wrapup;
                }
              }
            }

	PDMdebug("calling PDMco_item_update_filemanager\n");
	status = PDMco_item_update_filemanager ( PDMexec->catalog, 
						 PDMexec->part_num,
						 PDMexec->revision,
						 PDMpart.n_catalogno,
						 PDMpart.n_itemno, 
						 storage_no, file_bufr);
	if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn,  "%s %d\n",
		    "PDMco_item_update_filemanager failed status ", status);
           status1 = NFMcancel_check_out_item (PDMexec->catalog, 
                                               PDMpart.n_catalogno,
                                               PDMexec->part_num,
                                               PDMexec->revision, 
                                               PDMwf_info, 
                                               *PDMoperation);
           _PDMdebug (fn, "NFMcancel_checkout_item returns : %d\n", status1);
	   goto wrapup;
	       }

        PDMupdate_dots();

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
	   goto wrapup;
	        }

   if(PDMdebug_on) {
                MEMprint_buffer ("file_bufr",
                                        *file_bufr, PDM_DEBUG_FILE);
          }

	MEMclose(&file_list);
        _PDMdebug ("EXIT", "%s\n", fn);
	return (PDM_S_SUCCESS);

wrapup:

	MEMclose(&file_list);
	status2 = PDMrollback_transaction(1200);
	if (status2 != PDM_S_SUCCESS) {
	   _PDMdebug (fn, "PDMrollback_transaction failed status %d\n", status);
	}
	return (status);

}

/* function to set wfinfo and operation structure */

int PDMco_set_info_oper_struct (head, nchildren)
struct NFMset_member        *head; 
int			     nchildren;
{
    char	*fn = "PDMco_set_info_oper_struct";
	_PDMdebug ("ENTER:", "PDMset_info_oper_struct\n");
	PDMwf_info.workflow = NFM_NO_WORKFLOW;
	strcpy (WFinfo.command_name, PDMwf_info.command) ;
	strcpy (WFinfo.workflow_name, PDMwf_info.workflow_name) ;
	strcpy (WFinfo.proj_name, PDMwf_info.project_name) ;
	strcpy ("PDM", PDMwf_info.app_name) ;

        status = PDMco_set_oper_struct (head, nchildren);
        if (status != PDM_S_SUCCESS) {
             _PDMdebug (fn, "PDMset_oper_struct failed status %d\n", status);
             PDMdebug (s);
             return (status);
        }
	_PDMdebug ("EXIT:", "PDMco_set_info_oper_struct\n");
	return (PDM_S_SUCCESS);
}


int PDMXXco_set_oper_struct (head, nchildren)
struct NFMset_member *head;
int	nchildren;
{
 char   *fn = "PDMXXco_set_oper_struct";
 int	x, y;
struct NFMset_member *cur_mem;
   PDMdebug ("ENTER: PDMXXco_set_oper_struct\n");
   
 _PDMdebug (fn, "# of children =  %d\n", nchildren);
 PDMoperation = PDMlast_oper = (struct NFMoperation *)
                        calloc ((nchildren + 10), 
                              (nchildren + 10) * sizeof (struct NFMoperation));

  if (!PDMoperation) {
      _PDMdebug (fn, "calloc PDMoperation failed...");
       return (PDM_E_COULD_NOT_MALLOC);
     }
  _PDMdebug (fn, "calloc successful\n");
 _PDMprint_setmember ("head", head);

  for (cur_mem = head, x = 0, y = 0;
                         y < nchildren ; 
                                 ++y, cur_mem = cur_mem->next) {
  if (! strcmp (cur_mem->type, "S") &&
        cur_mem->move == MOVE ) {
 _PDMprint_setmember ("cur_mem", cur_mem);
       (PDMoperation+x)->transfer = NFM_TRANSFER;
       (PDMoperation+x)->delete = NFM_NO_DELETE;
       (PDMoperation+x)->purge = NFM_PURGE;
       strcpy ((PDMoperation+x)->catalog, cur_mem->cat_name) ;
       strcpy ((PDMoperation+x)->item_name, cur_mem->item_name) ;
       strcpy ((PDMoperation+x)->item_rev, cur_mem->item_rev) ;
sprintf  (s, "PDMoperation->transfer = %d, PDMoperation->delete = %d,\n\
PDMoperation->purge = %d, PDMoperation->catalog = %s,\n\
PDMoperation->item_name = %s, PDMoperation->item_rev = %s\n",
(PDMoperation+x)->transfer, (PDMoperation+x)->delete, (PDMoperation+x)->purge,
(PDMoperation+x)->catalog, (PDMoperation+x)->item_name,
           (PDMoperation+x)->item_rev);
PDMdebug (s);
        ++x;
          }
    }
  /* additional struct as Meeiling requested */
    x +=1;
/*
    (PDMoperation+x) = (struct NFMoperation *) NULL;
       (PDMoperation+x)->transfer = -1;
       (PDMoperation+x)->delete = -1;
       (PDMoperation+x)->purge = -1;
       (PDMoperation+x)->catalog[0] = '\0';
       (PDMoperation+x)->item_name[0] = '\0';
       (PDMoperation+x)->item_rev[0] = '\0';
*/
  
   
   PDMdebug ("EXIT:PDMXXco_set_oper_struct\n");
 return (PDM_S_SUCCESS);
}



int _PDMchk_in_user (data_list)
MEMptr data_list;
{
  char     *fn = "_PDMchk_in_user";
  long     status;
  char     **column, **data1;
  long     x, count, i, j, k;

  PDMdebug ("_PDMchk_in_user: enter ...");

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFM_num ("_NFMchk_in_user: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column = (char **) data_list -> column_ptr;
  data1  = (char **) data_list -> data_ptr;
  
  i = j = k = -1;


  for (x = 0; x < data_list -> columns; ++x)
  {
    if ( !strcmp (column [x], "n_couser"))
      i = x;
    else if ( !strcmp (column [x], "n_fileco"))
      j = x;
    else if ( !strcmp (column [x], "n_type"))
      k = x;
    else if ( (i > -1) && (j > -1) && (k > -1))
      break;
  }

_PDMdebug (fn, "column[i] = %s, column[j] = %s & column[k] = %s\n",
                column[i], column[j], column[k]);

  for (x = 0; x < data_list -> rows; ++x)
  {
    count = data_list -> columns * x;
    _PDMdebug (fn, "Co Stat = <%s>  ", data1 [count + j]);
    _PDMdebug (fn, "Co User = <%s>  ", data1 [count + i]);
    _PDMdebug (fn, "User = <%s>\n", PDMuser        );
    if ( (! strcmp (data1 [count + k], "P") ) &&
          (! strcmp (data1 [count + j], "Y")) )
      {
        if (strcmp (data1 [count + i], PDMuser)) {
        _PDMdebug (fn, "Not CO Out User : status = <0x%.8x>\n",
        NFM_E_NOT_CO_USER);
        return (NFM_E_NOT_CO_USER);
        }
       else
       break;
      }
  }

  _PDMdebug (fn, " SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);

}

/* loads catalogname, partname etc into the head <-> end linked
    list */


int PDMload_cat_part_info (catalog, part_num, revision,
                           ch, head)
char		*catalog, *part_num, *revision;
int		ch;
struct NFMset_member		*head;
{
  char			*fn = "PDMload_cat_part_info";
  int			prev_catno, prev_itemno;
  struct NFMset_member	*cur_mem;
  char			cat_name[60], item_name[40], item_rev[10];
  int			x;
 
  _PDMdebug ("ENTER", "%s\n", fn);
  _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n",
                catalog, part_num, revision);
   
   prev_catno = prev_itemno = -1;
   cat_name[0] = '\0';
   item_name[0] = '\0';
   item_rev[0] = '\0';

  /* this has to be optimised ... 
     check to see of previous catalog is same as present one..
     check to see of previous itemno is same as present one..
     */ 
  for (x = 0, cur_mem = head; x < ch ; ++x, cur_mem = cur_mem->next){
    if (strcmp (cur_mem->type, "P")) {
      if (cur_mem->cat_no != prev_catno) {
       _PDMdebug (fn, "different catalog, different itemno\n");
      prev_catno = cur_mem->cat_no;
      status = PDMget_catalog_name (cur_mem->cat_no, cat_name);
       if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMget_catalog_name failed %d\n", status);
       return (status);
              }
      status = PDMget_itemname (cur_mem->item_no, cat_name, 
					item_name, item_rev);
       if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMget_itemname failed %d\n", status);
       return (status);
             }
       } else {
       _PDMdebug (fn, "same catalog, different itemno\n");
       if (cur_mem->item_no != prev_itemno) {
       prev_itemno = cur_mem->item_no;
        status = PDMget_itemname (cur_mem->item_no, cat_name,
                                       item_name, item_rev);
       if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMget_itemname failed %d\n", status);
       return (status);
             }
          }
        }
      }
    else {
         strcpy (cat_name, catalog);
	 strcpy (item_name, part_num);
	 strcpy (item_rev, revision);
/*
         prev_catno = cur_mem->cat_no;
         prev_itemno = cur_mem->item_no;
*/
     }
      strcpy (cur_mem->cat_name, cat_name);
	 strcpy (cur_mem->item_name, item_name);
	 strcpy (cur_mem->item_rev, item_rev);
_PDMdebug (fn, "cat_name[%s] item[%s] rev[%s]\n", 
                      cat_name, item_name, item_rev);
    }
     
  _PDMdebug ("EXIT", "%s\n", fn);
      return (PDM_S_SUCCESS);
}     

/*int PDMremove_oper_duplicates (head, end, nchildren)*/
int PDMco_set_oper_struct (head, nchildren)
struct NFMset_member *head;
int	nchildren;
{
 char   *fn = "PDMco_set_oper_struct";
 int	x, y, z, duplicate;
struct NFMset_member *cur_mem;
   PDMdebug ("ENTER: PDMco_set_oper_struct\n");
   
 _PDMdebug (fn, "# of children =  %d\n", nchildren);
 PDMoperation = PDMlast_oper = (struct NFMoperation *)
                        calloc ((nchildren + 1), 
                              (nchildren + 1) * sizeof (struct NFMoperation));

  if (!PDMoperation) {
      _PDMdebug (fn, "calloc PDMoperation failed...");
       return (PDM_E_COULD_NOT_MALLOC);
     }
  _PDMdebug (fn, "calloc successful\n");

  duplicate = 0;
  for (cur_mem = head, x = 0, y = 0;
                         y < nchildren ; 
                                 ++y, cur_mem = cur_mem->next) {
 /* code to remove duplicates */
    duplicate = 0;
    for (z = 0; z < x ; ++z) {
      if ( ! strcmp ( (PDMoperation+z)->catalog, cur_mem->cat_name ) &&
          (!strcmp((PDMoperation+z)->item_name, cur_mem->item_name))  &&
           (!strcmp((PDMoperation+z)->item_rev, cur_mem->item_rev)) ){
            duplicate = 1;
_PDMdebug (fn, 
"***Aha! Found a duplicate!!\n  ===>> cat_name[%s] item[%s] rev[%s]\n", 
                cur_mem->cat_name, cur_mem->item_name, cur_mem->item_rev);
            break;
            }
        }
    _PDMdebug (fn, "duplicate [%d]\n", duplicate);
  if (! strcmp (cur_mem->type, "S") &&
        ( cur_mem->move == MOVE || cur_mem->move == UPDMEM ) &&
        duplicate == 0) {
  _PDMdebug (fn, "x[%d], y[%d]\n", x, y);
 _PDMprint_setmember ("cur_mem", cur_mem);
       (PDMoperation+x)->transfer = NFM_TRANSFER;
       (PDMoperation+x)->delete = NFM_NO_DELETE;
       (PDMoperation+x)->purge = NFM_PURGE;
       strcpy ((PDMoperation+x)->catalog, cur_mem->cat_name) ;
       strcpy ((PDMoperation+x)->item_name, cur_mem->item_name) ;
       strcpy ((PDMoperation+x)->item_rev, cur_mem->item_rev) ;
/*
sprintf  (s, "PDMoperation->transfer = %d, PDMoperation->delete = %d,\n\
PDMoperation->purge = %d, PDMoperation->catalog = %s,\n\
PDMoperation->item_name = %s, PDMoperation->item_rev = %s\n",
(PDMoperation+x)->transfer, (PDMoperation+x)->delete, (PDMoperation+x)->purge,
(PDMoperation+x)->catalog, (PDMoperation+x)->item_name,
           (PDMoperation+x)->item_rev);
PDMdebug (s);
*/
sprintf  (s, 
"	PDMoperation->catalog[%s], \n	PDMoperation->item_name[%s],\n	 PDMoperation->item_rev[%s]\n",
(PDMoperation+x)->catalog, (PDMoperation+x)->item_name,
           (PDMoperation+x)->item_rev);
PDMdebug (s);
        ++x;
          }
  _PDMdebug (fn, "one child over x[%d], y[%d]\n", x, y);
    }
  _PDMdebug (fn, "after loop: x[%d], y[%d]\n", x, y);
   PDMdebug ("EXIT:PDMco_set_oper_struct\n");
 return (PDM_S_SUCCESS);
}


/* cancel part checkout...
   we first set the n_status of checked out set as O instead of S
     and call cancel item checkout */

/*
 * The part is either an assembly or atomic part If it is atomic use
 * NFMcancel_co_item If it is an assembly call NFMcancel_co_set update file
 * manager
 */



int PDMcancel_checkout_part(delete_list, attach_list, child_bufr, para_cats, mul_files)
MEMptr          *delete_list;
MEMptr          attach_list;
MEMptr          child_bufr;
MEMptr          *mul_files;
struct  PDUcat_node *para_cats;
{
	char			*fn = "PDMcancel_checkout_part";
	char            	p_assembly[5];
	char           		*p_coout;
	int             	p_partno, p_catalogno;
	char			sql_str[512];
        char                    *msg = NULL;
        int             	nchildren = -1;
        int			wrapup_status;
        int			storage_no;
        int			err_status;
	MEMptr			tmp_delete_list = NULL;
        struct  NFMset_member   *set_head = (struct NFMset_member *) NULL;
        struct  NFMset_member   *set_end = (struct NFMset_member *) NULL;

       
	PDMdebug("ENTER: PDMcancel_checkout_part:\n");

        msg = (char *)PDUtranslate_message(PDS_M_CANCEL_CHECKOUT_PART); 
        strcpy(glob_var,msg);

	status = MEMbuild_array(child_bufr);
       /* Added by kumar - 3.27.93 to fix atomic cancel part checkout */
	if (status != MEM_S_SUCCESS 
               && status != MEM_E_NULL_BUFFER 
                     && status != MEM_E_NULL_LIST) {
		_PDMdebug (fn, "MEMbuild_array failed status -> %d", status);
		return (PDM_E_BUILD_ARRAY);
	}

      _PDMdebug (fn, "Printing the child buffer\n");
        if(PDMdebug_on) {
           MEMprint_buffer ("CHILD BUFFER", child_bufr, PDM_DEBUG_FILE);
        }

        storage_no = storage->storage_no;
        _PDMdebug (fn, "storage_no[%d]\n", storage_no);

/* fix to check whether user is allowed to cancel checkout part */

	status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
	    PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
	    _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
	    return (PDM_E_COULD_NOT_LOAD_PART_INFO);
	}

        PDMupdate_dots();
       if (strcmp (NFMglobal.NFMusername, PDMpart.n_couser)) {
          _PDMdebug (fn, "This user[%s]  not checkout_user[%s] \n",
                                    NFMglobal.NFMusername, PDMpart.n_couser);
           return (PDM_E_NOT_CO_USER);
         }

	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug (fn,  "PDMstop_transaction failed status %d\n", status);
	goto wrapup;
	}

	status = PDMverify_part(PDMexec->catalog, PDMexec->part_num,
	    PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "PDMverify_part failed status %d\n", status);
		return (status);
	}
        PDMupdate_dots();
	status = PDMquery_catalog_partnos(PDMexec->catalog,
	    PDMexec->part_num, PDMexec->revision,
	    &p_catalogno, &p_partno);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMquery_catalog_partnos failed ", status);
		return (status);
	}
        PDMupdate_dots();
	status = PDMquery_file_status(PDMexec->catalog,
	    PDMexec->part_num, PDMexec->revision,
	    &p_coout);

	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMquery_file_status failed ", status);
		return (status);
	}
	if (!strcmp(p_coout, "I"))
		return (PDM_E_NOTCHECK_OUT);
	if (!strcmp(p_coout, ""))
		return (PDM_E_NOTCHECK_IN);

/* added support to undo any files added since checkout.
                                                 MaC 031893 */

      
      status = MEMopen (&tmp_delete_list, 512);
      if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEM Open : failed status : %lx\n", status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (tmp_delete_list, "n_cofilename", "char(128)");
         if (status != MEM_S_SUCCESS) {
            MEMclose (delete_list);
            _PDMdebug (fn, "MEM Wr For : failed status %lx\n", status);
            return (NFM_E_MEM);
          }

       *delete_list = tmp_delete_list;

        status = PDMundo_part_file_co_changes ( delete_list);
        if (status != PDM_S_SUCCESS) {
          _PDMdebug (fn, "PDMundo_part_file_co_changes failed %d\n", status);
           return (status);
          }
         
	p_assembly[0] = '\0';

        PDMupdate_dots();
	status = PDMquery_assembly_ind(PDMexec->catalog,
	    PDMexec->part_num, PDMexec->revision, p_assembly);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn,  "%s %d\n",
		    "PDMquery_assembly_ind failed ", status);
		return (status);
	}
        PDMupdate_dots();
	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
	   goto wrapup;
	}
	if ( (!strncmp(p_assembly, "Y", 1) ||
	    !strncmp(p_assembly, "y", 1)) || (child_bufr != NULL) ) {
            status = PDMget_assy_members_for_cancel_part_co (p_catalogno, 
					   p_partno,
					   1, 
					   &set_head,
					   &set_end, 
					   &nchildren, attach_list,
                                           child_bufr);
              if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn,
                   "PDMget_assy_members_for_cancel_part_co failed status %d\n",
                                                                 status);
                goto wrapup;
              }

        PDMupdate_dots();
/* set n_status to O so that we can use cancel item instead of cancel set */

       sprintf (sql_str, "UPDATE %s SET n_status = 'O' WHERE n_itemno = %d",
                                              PDMexec->catalog, p_partno);
        status = SQLstmt(sql_str);
        if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt failed status %d\n", status);
        status = _PDMget_db_error (status);
        return (status);
        }
      }
    
        PDMupdate_dots();
        status =  PDMset_info_oper_struct (PDMexec->catalog,
       PDMexec->part_num, PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n",
                        "PDMset_info_oper_struct", status);
                goto wrapup;
           }

       /* Added by kumar to prevent the files from getting deleted
          at the discretion of NFM local file manager - 3.27.93 */ 

        PDMoperation->transfer = NFM_NO_TRANSFER;

       status = NFMcancel_check_out_item (PDMexec->catalog, 
					  PDMpart.n_catalogno,
                                          PDMexec->part_num, 
                                          PDMexec->revision, 
                                          PDMwf_info, 
                                          *PDMoperation);
		if (status != NFM_S_SUCCESS) {
			_PDMdebug (fn,  "%s %s %d \n",
			    "PDMcancel_checkout_part: NFMcancel_co_item ",
			    "failed status ", status);
    ERRget_specific_number (NFM, &status);
    _PDMdebug (fn, "status = %d\n", status);
			goto wrapup;
		}
        /* if (nchildren == -1) nchildren = 1; */

       /* if there are no children; or if the it is an item */
/*
        if (set_head == (struct NFMset_member *) NULL) {
             set_head->next = (struct NFMset_member *) NULL;
                  }
*/


        _PDMdebug (fn, "Locking nfmsafiles in share mode\n");
       
        sprintf(sql_str, "LOCK TABLES NFMSAFILES IN SHARE MODE");
         status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS) {
           PDMupdate_dots ();
           msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_FILE_ACCESS);
           UI_status (msg);
           sleep (30);
           sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
           if(status != SQL_S_SUCCESS) {
             UI_status (msg);
             sleep (30);
             sprintf(sql_str,"LOCK TABLES NFMSAFILES IN SHARE MODE");
             if(status != SQL_S_SUCCESS) {
                sprintf(s, "LOCK NFMSAFILES failed status %d\n", status);
                PDMdebug(s);
                msg = (char *)PDUtranslate_message(PDS_M_CHECKIN_CHECKOUT_PROGRESS);
                UI_status (msg);
                goto wrapup;
                }
              }
            }



        PDMupdate_dots();
        status = PDMcancel_co_update_filemanager ( p_catalogno,
                                                   p_partno,
                                                   PDMexec->catalog,
                                                   PDMexec->part_num,
                                                   PDMexec->revision,
                                                   storage_no,
                                                   set_head,
                                                   set_end,
                                                   nchildren,
 						   delete_list,
 						   child_bufr);
 						   /*delete_list);*/

        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn,  "%s %d\n",
                    "PDMco_item_update_filemanager failed status ", status);
                goto wrapup;
        }

        PDMupdate_dots();

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
	   goto wrapup;
	}

/* file buffer will contain files to be deleted ..*/

     /* code added to undo undo part/file changes.
        the algorithm is  as follows:
         get all the files for this part from f_catalog 
         where n_fileco is NOT Y
         delete 'em,
         add the filenames to the filebufr to PDU to be deleted
         */

/*
        status = PDMundo_part_file_co_changes ( delete_list);
        if (status != PDM_S_SUCCESS) {
          _PDMdebug (fn, "PDMundo_part_file_co_changes failed %d\n", status);
           goto wrapup;
          }
*/
        status = PDMdelete_local_macros(para_cats, delete_list);
           if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "Cleanup of macro libraries failed: 0x%.8x\n", status);
            }

     /* Getting the list of files whose permissions need to be changed */

      status = _PDMupdate_permission_change_bufr (PDMexec->catalog,
                                                  PDMpart.n_itemno,
                                                  mul_files, delete_list);
      if(status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "Updating permission files failed: 0x%.8x\n", status);
            }

      if(PDMdebug_on){
         MEMprint_buffer("delete_list to pdu",*delete_list,PDM_DEBUG_FILE);
         MEMprint_buffer("mul_files to pdu", *mul_files, PDM_DEBUG_FILE);
        }

     /* fix added to set the p_incpartrpt to "" because now the part
        db as well as OSpace is updated. MaC 052793 */

       PDMset_update_os_flag ("U");

       PDMreset_dots();
       PDMdebug("EXIT:PDMcancel_checkout_part\n");
       return (PDM_S_SUCCESS);
wrapup:

        err_status = status;
	wrapup_status = PDMrollback_transaction(1200);
	if (wrapup_status != PDM_S_SUCCESS) {
	  _PDMdebug (fn, "PDMrollback_transaction failed status %d\n", 
                                                            wrapup_status);
	}
	return (err_status);
}


int PDMload_attach_buffer (set_head, set_end, attach_bufr)
MEMptr  *attach_bufr;
struct  NFMset_member   *set_head;
struct  NFMset_member   *set_end;
{
 char		*fn = "PDMload_attach_buffer";
 char		load_str [128];
 struct		NFMset_member   *cur_mem;
 MEMptr		list = NULL;
 int		flag = -1;


   PDMdebug("ENTER: PDMload_attach_buffer\n");

/* ANSI */
   set_end = NULL;

   status = MEMopen (&list, 512);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMopen failed: status %d\n", status);
       return (status);
      }
    
      status = MEMwrite_format (list, "n_catalogno", "integer");
         if (status != MEM_S_SUCCESS) {
          MEMclose(&list);
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }


      status = MEMwrite_format (list, "n_itemno", "integer");
         if (status != MEM_S_SUCCESS) {
          MEMclose(&list);
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }

    for (cur_mem = set_head; 
                  cur_mem != NULL;
                       cur_mem = cur_mem->next) {
     load_str[0] = '\0';
     if (strcmp (cur_mem->type, "P") ) {
       flag = 1;
       sprintf (load_str, 
       "%d\1%d\1", cur_mem->cat_no, cur_mem->item_no);
       _PDMdebug ("load_str", "%s\n", load_str);
        status = MEMwrite(list, load_str);
          if(status != MEM_S_SUCCESS) {
             MEMclose(&list);
             _PDMdebug (fn, "MEMwrite failed status %d\n",status);
             return(PDM_E_WRITE_ROW);
             }
       }
      }
   _PDMdebug (fn, "flag = %d\n", flag);
   if(PDMdebug_on) {
                MEMprint_buffer ("attach_buffer", list, PDM_DEBUG_FILE);
   }
   if (flag == -1) list = NULL;

   *attach_bufr = list;
   PDMdebug("EXIT: PDMload_attach_buffer\n");
return (PDM_S_SUCCESS);
}



int PDMundo_part_file_co_changes (file_bufr)
MEMptr	*file_bufr;
{

 char		*fn = "PDMundo_part_file_co_changes";
 char		mem_str [512];
 char		sql_str [512];
 MEMptr		file_list = NULL;
 int		index, i;
 char		**list_data;


   PDMdebug("ENTER: PDMundo_part_file_co_changes\n");
   
/*
   sprintf (sql_str,
 "SELECT %s FROM f_%s, %s WHERE %s.%s = '%s' AND %s.%s = '%s' AND %s.%s = f_%s.%s"
    "n_fileno, n_filenum, n_cofilename",
    PDMexec->catalog,
    PDMexec->catalog,
    PDMexec->catalog, "n_itemname",
    PDMexec->part_num, 
    PDMexec->catalog, "n_itemrev",
    PDMexec->revision, 
    PDMexec->catalog, "n_itemno",
    PDMexec->catalog, "n_itemnum");
*/
   sprintf (sql_str,
   "SELECT %s FROM f_%s WHERE n_itemnum = %d AND n_fileco is NULL ",
    "n_fileno, n_cofilename",
     PDMexec->catalog,
     PDMpart.n_itemno);

   _PDMdebug ("sql_str", "%s\n", sql_str);

   status = SQLquery (sql_str, &file_list, MEM_SIZE);
   if ( status != SQL_S_SUCCESS ) {
     /* Added by kumar on 3.27.93 to take of No files added condition */
        if(status == SQL_I_NO_ROWS_FOUND)
          {
      MEMclose (&file_list);
      _PDMdebug  (fn, "No files got added after checkout %d\n", status) ;
      return (PDM_S_SUCCESS);
          }
      MEMclose (&file_list);
      _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
      return (status);
      }
   status = MEMbuild_array(file_list);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
     return(PDM_E_BUILD_ARRAY);
     }

  if (PDMdebug_on) {
    MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
    }

   list_data = (char **) file_list->data_ptr;


/* for each entry in the buffer, delete the entry in f_catalog */

   for (i=0; i<file_list->rows; i++) {
    index = i * file_list->columns;
    sql_str[0] = '\0';
    sprintf(sql_str,
         "DELETE FROM  f_%s  WHERE n_fileno = %s", PDMexec->catalog,
                                                        list_data[index]);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Delete failed for filename %s \n", list_data[index+1]);
        return (status);
         }

     sprintf (mem_str, "%s\1", list_data[index+1]);
     status = MEMwrite (*file_bufr, mem_str);
     if (status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMwrite Failed %d\n", status);
       _PDMdebug (fn, "MEMwrite failed for filename %s \n", list_data[index+1]);
       return (status);
        }

    }

   PDMdebug("EXIT: PDMundo_part_file_co_changes\n");
  return (PDM_S_SUCCESS);
}

