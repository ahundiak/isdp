#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"NFMapi.h"
#include		"PDUris_incl.h"
#include                "ERR.h"
#include		"PDMproto.h"
#include		"PDMtypes.h"

extern	int 	PDMdebug_on;
extern PDMpart_ptr PDMpart;
extern	char	PDM_DEBUG_FILE[];
/*static int		status;*/
/*static int		curbuf_no;*/
/*static char		s[1024];*/
extern PDMexec_ptr PDMexec;

/* Written to support parts GUI 
    - Kumar 2.2.92 */

int PDMprepare_file_info (fileattr_list)
MEMptr*fileattr_list;
{
	char		*fn = "PDMprepare_file_info";
	long		status;
	char		sql_str[250];
	MEMptr		filedata_list = NULL;
	MEMptr		file_list = NULL;
	MEMptr		temp_bufr = NULL;
	long 		PDMtranslate_item_flag ();


      PDMdebug("ENTER:PDMprepare_file_info:\n");

  if( PDMexec->entity == NFM_CHANGE_FILE_INFORMATION) {
      _PDMdebug (fn, "Mode = %d\n", PDMexec->entity);
      status = NFMget_file_information (PDMexec->catalog, 
                                          PDMexec->part_num, 
                                          PDMexec->revision, 
                                          NFM_CHANGE_FILE_INFORMATION, 
                                          fileattr_list, 
                                          &filedata_list, 
                                          &file_list);    
      if(status != NFM_S_SUCCESS) {
            MEMclose(fileattr_list);
            MEMclose(&filedata_list);
            MEMclose(&file_list);
            _PDMdebug (fn, "NFMget_file_information failed status -> %d \n", 
                                                                    status);
               if(status == NFM_E_ITEM_FLAGGED) {
                return (PDMtranslate_item_flag (PDMexec->catalog, 
                                                PDMexec->part_num, 
                                                PDMexec->revision)  );
                }
               else if (status == NFM_E_LOCK_TABLE_FAILED) {
                     _PDMdebug (fn, "table is locked\n");
                     status = PDM_I_TABLE_LOCKED;
                     return (status);
                     }
                else {
                 ERRget_specific_number (NFM, &status);
                 return(status);
                 }
/* Commented Out by Mychelle - 4/19/93.  Per Meeiling and Karen, this 
   function should only be called when NFMget_file_information is successful
            NFMreset_file_information (PDMexec->catalog, 
                                       PDMexec->part_num, 
                                       PDMexec->revision);
*/
            }
    }
    else if (( PDMexec->entity == NFM_DELETE_FILE_FROM_ITEM) ||
               ( PDMexec->entity == PDM_REVIEW_PART_INFORMATION) ) 
      {
          _PDMdebug (fn, "Mode = %d\n", PDMexec->entity);
          status = NFMget_file_information (PDMexec->catalog, 
                                            PDMexec->part_num, 
                                            PDMexec->revision, 
        				    NFM_CHANGE_FILE_INFORMATION, 
                                            fileattr_list, 
                                            &filedata_list, 
                                            &file_list);    
          if(status != NFM_S_SUCCESS) 
            {
            MEMclose(fileattr_list);
            MEMclose(&filedata_list);
            MEMclose(&file_list);
            PDMdebug("PDMprepare_file_info :\n");
            _PDMdebug (fn, "NFMget_file_information failed status -> %d \n", 
                                                                    status);
            if(status == NFM_E_ITEM_FLAGGED) 
               {
               return (PDMtranslate_item_flag (PDMexec->catalog, 
                                                PDMexec->part_num, 
                                                PDMexec->revision)  );
               }
            else if (status == NFM_E_LOCK_TABLE_FAILED) {
                     _PDMdebug (fn, "table is locked\n");
                     status = PDM_I_TABLE_LOCKED;
                     return (status);
                     }
             else 
               {
                     ERRget_specific_number (NFM, &status);
                     return(status);
               }
              }
      }
    else 
      {
      sql_str[0]= '\0';
      sprintf (sql_str, 
          "SELECT n_itemlock FROM %s %s '%s' %s '%s' %s ", 
           PDMexec->catalog, 
           "WHERE n_itemname = ", 
           PDMexec->part_num, 
           "AND n_itemrev = ", 
           PDMexec->revision, 
           "AND n_status = 'I'");

       status = SQLquery (sql_str, &temp_bufr, 512);
       if (status != SQL_I_NO_ROWS_FOUND) {
          MEMclose(&temp_bufr);
          PDMexec->return_buffer = NULL;
          if (status != SQL_S_SUCCESS) {
          PDMdebug("EXIT:PDMprepare_file_info - CAN'T ADD FILES -CHECKED IN\n");
            }
          else PDMdebug("ERROR:PDMprepare_file_info - CAN'T ADD FILES \n");
          return(PDM_S_SUCCESS);
          }
        
       status = NFMget_file_information( PDMexec->catalog, 
                                            PDMexec->part_num, 
                                            PDMexec->revision, 
                                            NFM_ADD_FILE_TO_ITEM, 
                                            fileattr_list, 
                                            &filedata_list, 
                                            &file_list);    
        if (status != NFM_S_SUCCESS) {
          MEMclose(fileattr_list);
          MEMclose(&filedata_list);
          MEMclose(&file_list);
          _PDMdebug (fn, "NFMget_file_information failed status -> %d \n", 
                                                                    status);
          if (status == NFM_E_ITEM_FLAGGED) {
             return (PDMtranslate_item_flag (PDMexec->catalog, 
                                                PDMexec->part_num, 
                                                PDMexec->revision)  );
                }
          else if (status == NFM_E_LOCK_TABLE_FAILED) {
             _PDMdebug (fn, "table is locked\n");
             status = PDM_I_TABLE_LOCKED;
             return (status);
             }
          else {
              ERRget_specific_number (NFM, &status);
              return(status);
             }
           }
      }
      status = PDMstart_transaction(0);
      if (status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "PDMstart_transaction failed status %d\n", status);
         return(status);
        }

      status = NFMreset_file_information(PDMexec->catalog, 
                                            PDMexec->part_num, 
                                            PDMexec->revision);
       if (status != NFM_S_SUCCESS) {
         _PDMdebug (fn, "NFMreset_file_information failed : %d\n", status);
         if (status == NFM_E_LOCK_TABLE_FAILED) {
            _PDMdebug (fn, "table is locked\n");
            status = PDM_I_TABLE_LOCKED;
            }
         return(PDM_E_CANCEL_UPDATE_ITEM);
          }

       if(PDMdebug_on) {
         MEMprint_buffer("fileattr_list", *fileattr_list, PDM_DEBUG_FILE);
         MEMprint_buffer("filedata_list", filedata_list, PDM_DEBUG_FILE);
         }

       status = MEMappend(filedata_list, *fileattr_list);
       if(status != MEM_S_SUCCESS) {
         MEMclose(fileattr_list);
         MEMclose(&filedata_list);
         MEMclose(&file_list);
         _PDMdebug (fn, "MEMappend failed : status %d\n", status);
         return(PDM_E_APPEND_BUFFER);
         }

       if(file_list != NULL) {
         status = MEMappend(file_list, *fileattr_list);
         if(status != MEM_S_SUCCESS) {
           MEMclose(fileattr_list);
           MEMclose(&filedata_list);
           MEMclose(&file_list);
           _PDMdebug (fn, "MEMappend failed : status %d\n", status);
           return(PDM_E_APPEND_BUFFER);
           }
          }

    if (PDMdebug_on)
        MEMprint_buffers("file buffers", *fileattr_list, PDM_DEBUG_FILE);

  PDMdebug ("EXIT:PDMprepare_file_info \n");
  return(PDM_S_SUCCESS);
}


int PDMadd_file_bufr(fileattr_list)
	MEMptr		*fileattr_list;
{
	long		status;
	char		s[120], sql_str[250];
	MEMptr		filedata_list = NULL;
	MEMptr		file_list = NULL;
	MEMptr		temp_bufr = NULL;
	long            PDMtranslate_item_flag();
	

	PDMdebug("ENTER:PDMadd_file_bufr:\n");

	*fileattr_list = NULL;

		status = NFMreset_file_information(PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
	    if(status != NFM_S_SUCCESS)
		{
		}
sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
      SQLstmt(sql_str);

        sprintf(sql_str, "SELECT n_itemlock FROM %s %s '%s' %s '%s' %s ", PDMexec->catalog, "WHERE n_itemname = ", PDMexec->part_num, "AND n_itemrev = ", PDMexec->revision, "AND (NOT(n_status = 'I') OR n_status is null) ");
        status = SQLquery(sql_str, &temp_bufr, 512);
        if (status != SQL_S_SUCCESS) {
                   MEMclose(&temp_bufr);
          PDMdebug("EXIT:PDMadd_file_bufr - CAN'T ADD FILES -CHECKED IN\n");
                    return(PDM_E_CANNOT_ADD_FILES);
                    /*return(PDM_S_SUCCESS);*/
                     }
        
    status = NFMget_file_information( PDMexec->catalog, PDMexec->part_num, PDMexec->revision, NFM_ADD_FILE_TO_ITEM, fileattr_list, &filedata_list, &file_list);			    
    if(status != NFM_S_SUCCESS)
    {
	    MEMclose(fileattr_list);
	 	MEMclose(&filedata_list);
		MEMclose(&file_list);
		PDMdebug("PDMadd_file_bufr :\n");
		sprintf(s, "NFMget_file_information failed status -> %d \n", 
			status);
		PDMdebug(s);
               if(status == NFM_E_ITEM_FLAGGED)
               {
                return (PDMtranslate_item_flag (PDMexec->catalog, 
                                                PDMexec->part_num, 
                                                PDMexec->revision)  );
                }
                else
                {
                 ERRget_specific_number (NFM, &status);
		return(status);
                 }
    }
if(PDMdebug_on)
{
	MEMprint_buffer("fileattr_list", *fileattr_list, PDM_DEBUG_FILE);
	MEMprint_buffer("filedata_list", filedata_list, PDM_DEBUG_FILE);
}
		status = NFMreset_file_information(PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
	    if(status != NFM_S_SUCCESS)
		{
		}
sprintf (sql_str, "UPDATE %s SET n_itemlock = 'U' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
      SQLstmt(sql_str);

    status = MEMappend(filedata_list, *fileattr_list);
    if(status != MEM_S_SUCCESS)
    {
	    MEMclose(fileattr_list);
	 	MEMclose(&filedata_list);
		MEMclose(&file_list);
		PDMdebug("PDMadd_file_bufr:\n");
		sprintf(s, "MEMappend failed : status %d\n", 	status);
		PDMdebug(s);
		return(PDM_E_APPEND_BUFFER);
    }
    if(file_list != NULL)
    {
    status = MEMappend(file_list, *fileattr_list);
    if(status != MEM_S_SUCCESS)
    {
	    MEMclose(fileattr_list);
	 	MEMclose(&filedata_list);
		MEMclose(&file_list);
		PDMdebug("PDMadd_file_bufr:\n");
		sprintf(s, "MEMappend failed : status %d\n", 	status);
		PDMdebug(s);
		return(PDM_E_APPEND_BUFFER);
    }
     }
	if (PDMdebug_on)
  	  MEMprint_buffers("file buffers", *fileattr_list, PDM_DEBUG_FILE);
    PDMdebug("EXIT:PDMadd_file_bufr \n");
    return(PDM_S_SUCCESS);		
}

long PDMtranslate_item_flag
(
char *catalog, 
char *partnum, 
char *revision
)
{
char *fn = "PDMtranslate_item_flag";

/* ANSI */
	catalog = NULL;
	partnum = NULL;
	revision = NULL;
   

        PDMload_part_info(PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
        if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
                _PDMdebug (fn,  "Part is flagged for achive\n");
                return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SB", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for backup\n");
                return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SD", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
           || (!strncmp(PDMpart.n_pendingflag, "SR", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }
        else if (!strncmp(PDMpart.n_archivestate, "A", 1)
         || !strncmp(PDMpart.n_archivestate, "B", 1))
           {
                _PDMdebug (fn,  "Part is archived or backedup\n");
             return(PDM_E_PART_ARCHIVED);
           }
        else return(NFM_E_ITEM_FLAGGED);
}



long PDM20modify_part(attr_list, data_list, filedata_list, filelist_list)
        MEMptr          attr_list;
        MEMptr          data_list;
        MEMptr          filedata_list;
        MEMptr          filelist_list;
{
        char            *fn = "PDM20modify_part";
        long            status;
        char            s[120];
        MEMptr          dummy_attr = NULL;
        MEMptr          dummy_data = NULL;
        MEMptr          dummy_list = NULL;

        PDMdebug("ENTER:PDMmodify_part:\n");

/*************** Added load part info: This is because, if 
                 there is a crash during change, we have to reset the 
                 part info/status as before 030394 MaC ******************/

    status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                                  PDMexec->revision);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
      return (status);
          }


     /* check if cancellation is requested */

    if(PDMexec->operation) {
       MEMclose(&filedata_list);
       MEMclose(&filelist_list);
       status = NFMcancel_update_item(PDMexec->user_id, 
                                                attr_list, data_list);

       if (status != NFM_S_SUCCESS) {
        _PDMdebug (fn, "\t%s %d \n", 
                "NFMcancel_update_item failed status ", status);
        return(PDM_E_CANCEL_UPDATE_ITEM);
       }
/* Mychelle - Per Meeiling, this should not be called unless 
   NFMget_file_information has been called */
/*
       status = NFMreset_file_information(PDMexec->catalog, 
                                   PDMexec->part_num, PDMexec->revision);
*/
       if(status != NFM_S_SUCCESS) {
        _PDMdebug (fn, "%s %d \n", 
                "NFMreset_file_information failed status ", status);
         if (status == NFM_E_LOCK_TABLE_FAILED) {
             _PDMdebug (fn, "table is locked\n");
             status = PDM_I_TABLE_LOCKED;
             return (status);
             }
        return(PDM_E_CANCEL_UPDATE_ITEM);
                }
        }
    if(PDMdebug_on) {
        MEMprint_buffer("Update Item - attr_list", attr_list, PDM_DEBUG_FILE);
        MEMprint_buffer("Upate Item - data_list", data_list, PDM_DEBUG_FILE);
       }
    status = NFMupdate_item(PDMexec->user_id, 
                        PDMexec->catalog, attr_list, data_list);

    if(status != NFM_S_SUCCESS) {
      PDMdebug("PDMmodify_part :\n");
      _PDMdebug (fn, "NFMupdate_item failed status -> %d \n", status);
/*
      NFMreset_file_information(PDMexec->catalog, 
                                  PDMexec->part_num, PDMexec-> revision);
*/
      NFMcancel_update_item(PDMexec->user_id, attr_list, data_list);
      if (status == NFM_E_LOCK_TABLE_FAILED) {
        _PDMdebug (fn, "table is locked\n");
        status = PDM_I_TABLE_LOCKED;
        return (status);
        }
      ERRget_specific_number (NFM, &status);
      return(status);
       }

   if((filelist_list != NULL) && (filelist_list->rows > 1)) {
    if(PDMdebug_on) {
        MEMprint_buffer("Add file to Item - filelist_list", 
                                            filelist_list, PDM_DEBUG_FILE);
        }
   status = NFMget_file_information( PDMexec->catalog, 
                                             PDMexec->part_num, 
                                             PDMexec->revision, 
                                             NFM_ADD_FILE_TO_ITEM, 
                                             &dummy_attr, 
                                             &dummy_data, 
                                             &dummy_list);

    if(status != NFM_S_SUCCESS) {
      MEMclose(&dummy_attr);
      MEMclose(&dummy_data);
      MEMclose(&dummy_list);
      _PDMdebug (fn, 
      "NFMget_file_information [NFM_ADD_FILE_TO_ITEM] failed  %d \n", status);
      if (status == NFM_E_LOCK_TABLE_FAILED) {
        _PDMdebug (fn, "table is locked\n");
        status = PDM_I_TABLE_LOCKED;
        return (status);
        }
      return(status);
    }
      MEMclose(&dummy_attr);
      MEMclose(&dummy_data);
      MEMclose(&dummy_list);
      status = PDMstart_transaction(0);
      if (status != PDM_S_SUCCESS) {
         sprintf(s, "PDMstart_transaction failed status %d\n", status);
         PDMdebug(s);
         return(status);
        }
       status = PDMstop_transaction(1200);
        if (status != PDM_S_SUCCESS) {
           sprintf(s, "PDMstop_transaction failed status %d\n", status);
           PDMdebug(s);
           return(status);
        }

    status = NFMdefine_file_information(PDMexec->catalog, 
                                               PDMexec->part_num, 
                                               PDMexec->revision, 
                                               NFM_ADD_FILE_TO_ITEM, 
                                               filelist_list);
   if(status != NFM_S_SUCCESS) {
      _PDMdebug (fn, "NFMdefine_file_info [NFM_ADD_FILE_TO_ITEM] failed %d \n", 
                status);
      NFMcancel_update_item(PDMexec->user_id, attr_list, data_list);
      if (status == NFM_E_LOCK_TABLE_FAILED) {
        _PDMdebug (fn, "table is locked\n");
        status = PDM_I_TABLE_LOCKED;
        return (status);
        }
      else if (status == NFM_E_DFI_DUPLICATE_CIFILENAME)
             return (PDM_E_STG_FN_NOT_UNIQUE);

      ERRget_specific_number (NFM, &status);
      return(status);
    }
    status = PDMstart_transaction(1200);
    if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMstart_transaction failed status %d\n", status);
       return(status);
       }

   }
 else {
      /* Mychelle commented out call to NFMreset_file_information 5/25/93.
         Per Meeiling this function can not be called until NFMget_file_
         information has been called */
/*
         NFMreset_file_information(PDMexec->catalog, 
                                     PDMexec->part_num, PDMexec->revision);
*/
         }

    if (((filedata_list != NULL) && (filedata_list-> rows > 0))
                             && (!strcmp(PDMexec->drawing, "CHANGE"))) {
    status = NFMget_file_information( PDMexec->catalog, 
                                                  PDMexec->part_num, 
                                                  PDMexec->revision, 
                                                  NFM_CHANGE_FILE_INFORMATION, 
                                                  &dummy_attr, 
                                                  &dummy_data, 
                                                  &dummy_list);

    if(status != NFM_S_SUCCESS) {
     MEMclose(&dummy_attr);
     MEMclose(&dummy_data);
     MEMclose(&dummy_list);
     _PDMdebug (fn, 
      "NFMget_file_information [NFM_CHANGE_FILE_INFORMATION] failed -> %d \n", 
                status);
      if (status == NFM_E_LOCK_TABLE_FAILED) {
        _PDMdebug (fn, "table is locked\n");
        status = PDM_I_TABLE_LOCKED;
        return (status);
        }
     ERRget_specific_number (NFM, &status);
     return(status);
    }
               MEMclose(&dummy_attr);
                MEMclose(&dummy_data);
                MEMclose(&dummy_list);
if(PDMdebug_on)
{
        MEMprint_buffer("change files of Item - filedata_list", filedata_list, PDM_DEBUG_FILE);
}
status = PDMstart_transaction(0);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstart_transaction failed status %d\n", status);
                PDMdebug(s);
/* Mychelle - Per Meeling NFMreset_file_information or NFMdefine_file_
   information must be called after NFMget_file_information.  This call was
   added to clean up when PDMstart_transaction fails.  5/25/93 */
                NFMreset_file_information(PDMexec->catalog, 
                                      PDMexec->part_num, PDMexec->revision);
                return(status);
        }
status = PDMstop_transaction(1200);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstop_transaction failed status %d\n", status);
                PDMdebug(s);
                NFMreset_file_information(PDMexec->catalog, 
                                      PDMexec->part_num, PDMexec->revision);
                return(status);
        }
    status = NFMdefine_file_information (PDMexec->catalog, 
                                         PDMexec->part_num, 
                                         PDMexec->revision, 
                                         NFM_CHANGE_FILE_INFORMATION, 
                                         filedata_list);
     if(status != NFM_S_SUCCESS) {
       _PDMdebug (fn, "NFMdefine_file_information failed status -> %d \n", 
                        status);
       NFMcancel_update_item (PDMexec->user_id, attr_list, data_list);
       if (status == NFM_E_LOCK_TABLE_FAILED) {
        _PDMdebug (fn, "table is locked\n");
        status = PDM_I_TABLE_LOCKED;
        return (status);
        }
      else if (status == NFM_E_DFI_DUPLICATE_CIFILENAME)
             return (PDM_E_STG_FN_NOT_UNIQUE);
       ERRget_specific_number (NFM, &status);
            return(status);
           }
       status = PDMstart_transaction(1200);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstart_transaction failed status %d\n", status);
                PDMdebug(s);
                return(status);
               }
         }


/*
    MEMclose(&attr_list);
    MEMclose(&data_list);
       MEMclose(&filedata_list);
       MEMclose(&filelist_list);
*/
    PDMdebug("EXIT:PDMmodify_part \n");
    return(PDM_S_SUCCESS);
}

