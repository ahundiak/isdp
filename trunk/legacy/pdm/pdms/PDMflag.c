#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"ERR.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"

static		long		status;
static		char		s[1024];
extern		PDMexec_ptr	PDMexec;
extern		PDMpart_ptr	PDMpart;

/* Flagging and unflagging of parts - kumar 2/10/91 */

int	PDMsflag_part_archive()
{
	char	n_setindicator[3];
	char	PendingFlag[5];
	char	sql_str[512];
	MEMptr	temp_bufr = NULL;
        char    *fname = "PDMflag_part_archive";

	_PDMdebug(fname, "ENTER:PDMsflag_part_archive\n");

	n_setindicator[0] = '\0';
	PendingFlag[0] = '\0';

	status = PDMQueryAssyIndPFlag (PDMexec->catalog,
			               PDMexec->part_num,
                                       PDMexec->revision,
                                       n_setindicator,
                                       PendingFlag);
	if(status != PDM_S_SUCCESS) {
	   _PDMdebug(fname,"PDMquery_assembly_ind failed status %d\n", status);
	   return(status);
	   }

        if (strcmp (PendingFlag, "")) {
           _PDMdebug (fname, "Part already flagged Flag [%s]\n", PendingFlag);
/*
           if (strcmp (n_setindicator, "Y") )
                return (PDM_E_ITEM_FLAGGED);
           else
                return (PDM_E_SET_FLAGGED);
*/
           status = _PDMInterpretPendingFlag (PendingFlag);
           return (status);
          } 

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(n_setindicator,"Y",1))
*/
	if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
	{
	status = NFMflag_set_archive(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMflag_set_archive failed status %d\n", status);
	if(status == NFM_E_SET_ARCHIVED)
	{
	status = PDM_E_ASSEMBLY_ARCHIVED;
        return(status);
	}
	else if(status == NFM_E_SET_OUT)
	{
	status = PDM_E_ASSEMBLY_CHECKED_OUT;
        return(status);
	 }
	else if(status == NFM_E_SET_FLAGGED)
	{
	status = PDM_E_SET_FLAGGED;
        return(status);
         }
	else if(status == NFM_E_ITEM_ARCHIVED)
	{
	status = PDM_E_MEMBER_ARCHIVED;
         return(status);
	}
	else if(status == NFM_E_ITEM_OUT)
	{
	status = PDM_E_MEMBER_CHECKED_OUT;
        return(status);
	 }
	else if(status == NFM_E_NO_FILE)
	{
	status = PDM_E_FILE_NOT_FOUND;
         return(status);
	}	
         else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
         return(status);
	}
        ERRget_specific_number (NFM, &status);
	return(status);
	}
      }
     else {
      
      /* Fix added to filter out parts used in an assy. MaC/Kumar 011994 */
      
       sql_str[0] = '\0';

       sprintf (sql_str, "select %s from %s where %s %s '%s' %s '%s' %s '%s' ",
       " n_pcatalogno, n_pitemno ",
       " nfmsetcit, pdmcit ",
       " pdmcit.p_citno = nfmsetcit.n_citno ",
       " and pdmcit.n_catalogname = ", PDMexec->catalog,
       " and pdmcit.n_itemname = ", PDMexec->part_num,
       " and pdmcit.n_itemrev = ", PDMexec->revision);


        status = SQLquery(sql_str, &temp_bufr, 512);
        if (status != SQL_I_NO_ROWS_FOUND) {
           MEMclose(&temp_bufr);
           if (status == SQL_S_SUCCESS) {
              /*status = PDM_E_BOM_CONT_NOT_EMPTY;*/
              status = PDM_E_PART_USED_IN_AN_ASSY;
              _PDMdebug (fname, "Part is used in an assembly\n");
              return (status);
              }
           _PDMdebug (fname, "SQLquery failed: %d\n", status);
           return (status);
        }
      
       
	status = NFMflag_item_archive(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	  _PDMdebug(fname,"NFMflag_item_archive failed status %d\n", status); 
	  if(status == NFM_E_ITEM_OUT)
	  {
	   status = PDM_E_PART_CHECKED_OUT;
            return(status);
	   }
	   else if(status == NFM_E_NO_FILE)
	   {
	     status = PDM_E_FILE_NOT_FOUND;
             return(status);
	    }	
	   else if(status == NFM_E_NO_FILES_FLAGGED)
	    {
	    status = PDM_E_NO_FILES_FLAGGED;
            return(status);
	    }
	   else if(status == NFM_E_ITEM_ARCHIVED)
	    {
	    status = PDM_E_PART_ARCHIVED;
            return(status);
            }	
	  else if(status == NFM_E_ITEM_FLAGGED)
	    {
	    status = PDM_E_ITEM_FLAGGED;
            return(status);
	    }	
        ERRget_specific_number (NFM, &status);
	return(status);
       }
      }
	_PDMdebug(fname,"EXIT:\n");
	return(PDM_S_SUCCESS);
}

int	PDMsflag_part_backup()
{
	char	n_setindicator[3];
	char	PendingFlag[5];
        char    *fname = "PDMsflag_part_backup";

	_PDMdebug(fname,"ENTER:\n");
	n_setindicator[0] = '\0';
        PendingFlag[0] = '\0';

        status = PDMQueryAssyIndPFlag (PDMexec->catalog,
                                       PDMexec->part_num,
                                       PDMexec->revision,
                                       n_setindicator,
                                       PendingFlag);
        if(status != PDM_S_SUCCESS) {
           _PDMdebug(fname,"PDMquery_assembly_ind failed status %d\n", status);
           return(status);
           }

        if (strcmp (PendingFlag, "")) {
           _PDMdebug (fname, "Part already flagged Flag [%s]\n", PendingFlag);
/*
           if (strcmp (n_setindicator, "Y") )
                return (PDM_E_ITEM_FLAGGED);
           else
                return (PDM_E_SET_FLAGGED);
*/
           status = _PDMInterpretPendingFlag (PendingFlag);
           return (status);
          } 


/*
	status = PDMquery_assembly_ind(PDMexec->catalog,
			 PDMexec->part_num,PDMexec->revision,n_setindicator);
	if(status != PDM_S_SUCCESS)
	{
     _PDMdebug(fname,"PDMquery_assembly_ind failed status <0x%.8x>\n", status); 
	return(status);
	}
*/
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(n_setindicator,"Y",1))
*/
	if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
	{
	status = NFMflag_set_backup(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMflag_set_backup failed status <0x%.8x>\n", status);
	if(status == NFM_E_SET_ARCHIVED)
	{
	status = PDM_E_ASSEMBLY_ARCHIVED;
         return(status);
	}
	else if(status == NFM_E_SET_OUT)
	{
	status = PDM_E_ASSEMBLY_CHECKED_OUT;
         return(status);
	}
	else if(status == NFM_E_SET_FLAGGED)
	{
	status = PDM_E_SET_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_ITEM_BACKED_UP)
	{
	status = PDM_E_ITEM_BACKED_UP;
        return(status);
	}
	else if(status == NFM_E_SET_FLAG_RESTORE)
	{
	status = PDM_E_SET_FLAG_RESTORE;
        return(status);
	}
	else if(status == NFM_E_ITEM_ARCHIVED)
	{
	status = PDM_E_MEMBER_ARCHIVED;
        return(status);
	}
        else if(status == NFM_E_ITEM_OUT)
	{
	status = PDM_E_MEMBER_CHECKED_OUT;
        return(status);
	}
	else if(status == NFM_E_NO_FILE)
	{
	status = PDM_E_FILE_NOT_FOUND;
        return(status);
	}	
	else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
        return(status);
	}
        ERRget_specific_number (NFM, &status);
	return(status);
        }
       }
       else
       {
	status = NFMflag_item_backup(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	 _PDMdebug(fname,"NFMflag_item_backup failed status %d\n", status); 
	if(status == NFM_E_ITEM_OUT)
	{
	status = PDM_E_PART_CHECKED_OUT;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAGGED)
	{
	status = PDM_E_ITEM_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_NO_FILE)
	{
	status = PDM_E_FILE_NOT_FOUND;
        return(status);
	}	
	else if(status == NFM_E_ITEM_BACKED_UP)
	{
	status = PDM_E_ITEM_BACKED_UP;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAG_RESTORE)
	{
	status = PDM_E_ITEM_FLAG_RESTORE;
        return(status);
	}
	else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
        return(status);
	}
	else if(status == NFM_E_ITEM_ARCHIVED)
	{
	status = PDM_E_PART_ARCHIVED;
        return(status);
	}	
        ERRget_specific_number (NFM, &status);
	return(status);
	}
	}
	_PDMdebug(fname,"EXIT:\n");
	return(PDM_S_SUCCESS);
}

int	PDMsflag_part_delete()
{
	char	n_setindicator[3];
	char	PendingFlag[5];
        char    *fname = "PDMsflag_part_delete";

	_PDMdebug(fname,"ENTER:\n");
	n_setindicator[0] = '\0';
        PendingFlag[0] = '\0';

        status = PDMQueryAssyIndPFlag (PDMexec->catalog,
                                       PDMexec->part_num,
                                       PDMexec->revision,
                                       n_setindicator,
                                       PendingFlag);
        if(status != PDM_S_SUCCESS) {
           _PDMdebug(fname,"PDMquery_assembly_ind failed status %d\n", status);
           return(status);
           }

        if (strcmp (PendingFlag, "")) {
           _PDMdebug (fname, "Part already flagged Flag [%s]\n", PendingFlag);
/*
           if (strcmp (n_setindicator, "Y") )
                return (PDM_E_ITEM_FLAGGED);
           else
                return (PDM_E_SET_FLAGGED);
*/
           status = _PDMInterpretPendingFlag (PendingFlag);
           return (status);
          } 


/*
	status = PDMquery_assembly_ind(PDMexec->catalog,
			 PDMexec->part_num,PDMexec->revision,n_setindicator);
	if(status != PDM_S_SUCCESS)
	{
         _PDMdebug(fname,"PDMquery_assembly_ind failed status %d\n", status); 
	return(status);
	}
*/
	status = NFMflag_item_delete(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMflag_item_delete failed status %d\n", status);
	if(status == NFM_E_ITEM_ARCHIVED)
	{
	status = PDM_E_PART_ARCHIVED;
        return(status);
	}
	else if(status == NFM_E_ITEM_BACKED_UP)
	{
	status = PDM_E_ITEM_BACKED_UP;
        return(status);
	}
	else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAG_RESTORE)
	{
	status = PDM_E_ITEM_FLAG_RESTORE;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAGGED)
	{
	status = PDM_E_ITEM_FLAGGED;
        return(status);
	}
        ERRget_specific_number (NFM, &status);
        return(status);
	}
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
}

int	PDMsflag_part_restore()
{
	char	n_setindicator[3];
        char    *fname = "PDMsflag_part_restore";
	char	flag_stat[40];
	int  _PDMcheck_flag_status ();
         

	_PDMdebug(fname,"ENTER:\n");

        flag_stat[0] = '\0';

        status = _PDMcheck_flag_status ("n_archiveno", flag_stat);
        if (status != PDM_S_SUCCESS) {
            _PDMdebug (fname, "Part is not flagged for archive\n");
            return (status);
           }
/*
           status = _PDMInterpretPendingFlag (PendingFlag);
           return (status);
*/
	n_setindicator[0] = '\0';
	status = PDMquery_assembly_ind(PDMexec->catalog,
			 PDMexec->part_num,PDMexec->revision,n_setindicator);
	if(status != PDM_S_SUCCESS)
	{
      _PDMdebug(fname,"PDMquery_assembly_ind failed status <0x%.8x>\n", status); 
	return(status);
	}
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(n_setindicator,"Y",1))
*/
	if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
	{
	status = NFMflag_set_restore(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMflag_set_restore failed status <0x%.8x>\n", status);
	if(status == NFM_E_SET_ARCHIVED)
	{
         status = PDM_E_PART_ARCHIVED;
         return(status);
	}
	else if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
	status = PDM_E_FILE_NOT_ARCHIVED;
         return(status);
	}
	else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
        return(status);
	}
        else if(status == NFM_E_SET_FLAGGED)
	{
	status = PDM_E_SET_FLAGGED;
        return(status);
	}
	else if(status == NFM_E_ITEM_BACKED_UP)
	{
	status = PDM_E_ITEM_BACKED_UP;
        return(status);
	}
	else if(status == NFM_E_SET_FLAG_RESTORE)
	{
	status = PDM_E_ITEM_FLAG_RESTORE;
        return(status);
	}
	else if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
	status = PDM_E_FILE_NOT_ARCHIVED;
        return(status);
	}
        ERRget_specific_number (NFM, &status);
	return(status);
	}
    }
	else
	{
	status = NFMflag_item_restore(PDMexec->user_id,
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMflag_item_restore failed status <0x%.8x>\n",
			status);
	if(status == NFM_E_ITEM_ARCHIVED)
	{
	status = PDM_E_PART_ARCHIVED;
        return(status);
	}
	else if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
	status = PDM_E_FILE_NOT_ARCHIVED;
        return(status);
	}
	else if(status == NFM_E_NO_FILES_FLAGGED)
	{
	status = PDM_E_NO_FILES_FLAGGED;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAGGED)
	{
	status = PDM_E_ITEM_FLAGGED;
        return(status);
	}
	else if(status == NFM_E_ITEM_BACKED_UP)
	{
	status = PDM_E_ITEM_BACKED_UP;
        return(status);
	}
	else if(status == NFM_E_ITEM_FLAG_RESTORE)
	{
	status = PDM_E_ITEM_FLAG_RESTORE;
        return(status);
	}
	else if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
	status = PDM_E_FILE_NOT_ARCHIVED;
        return(status);
	}
        ERRget_specific_number (NFM, &status);
	return(status);
	}
      }
	_PDMdebug(fname,"EXIT:\n");
	return(PDM_S_SUCCESS);
}

int	PDMsUnflag_part_archive()
{
        char    *fname = "PDMsUflag_part_archive";

	_PDMdebug(fname,"ENTER:\n");
         status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fname, "PDMload_part_info failed status %d\n", status);
                return (status);
        }
         if(!strcmp(PDMpart.n_pendingflag,""))
           return(PDM_E_ITEM_NOT_FLAGGED);

/* fix to check that the unflag is for corresponding flag MaC 011894 */

         if  ((strcmp (PDMpart.n_pendingflag, "IA"))
               && (strcmp (PDMpart.n_pendingflag, "SA"))
               && (strcmp (PDMpart.n_pendingflag, "MA"))
               && (strcmp (PDMpart.n_pendingflag, "PA")) )
              return(PDM_E_NOT_FLAGGED_AS_ITEM_ARCHIVE);

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(PDMpart.n_setindicator,"Y",1))
*/
	if(!strncmp(PDMpart.n_setindicator,"Y",1) || 
           !strncmp(PDMpart.n_setindicator,"A",1))
	{
	status = NFMcancel_set_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	_PDMdebug(fname,"NFMcancel_set_archive_flag failed status <0x%.8x>\n",
			status);
	if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
        status = PDM_E_FILE_NOT_ARCHIVED;
        return(status);
	} 
	else if(status == NFM_E_SET_NOT_FLAGGED)
	{
	status = PDM_E_SET_NOT_FLAGGED;
        return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
	status = PDM_E_SET_NOT_FLAGGED;
        return(status);
	}
        ERRget_specific_number (NFM, &status);
	return(status);
      }
    }
	else
	{
	status = NFMcancel_item_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	if(status == NFM_E_FILE_NOT_ARCHIVED)
	{
	status = PDM_E_FILE_NOT_ARCHIVED;
        return(status);
	} 
	else if(status == NFM_E_ITEM_NOT_FLAGGED)
	{
	status = PDM_E_ITEM_NOT_FLAGGED;
        return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
         status = PDM_E_ITEM_NOT_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_ARCHI)
	{
	status = PDM_E_NOT_FLAGGED_AS_ITEM_ARCHIVE;
        return(status);
	}
	_PDMdebug(fname,"NFMcancel_item_archive_flag failed status <0x%.8x>\n",
			status);
        ERRget_specific_number (NFM, &status);
	return(status);
	}
       }
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
}

int	PDMsUnflag_part_delete()
{
        char    *fname = "PDMsUnflag_part_delete";

	_PDMdebug(fname,"ENTER:\n");
        
         status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fname, "PDMload_part_info failed status %d\n", status);
                return (status);
        }
         if(!strcmp(PDMpart.n_pendingflag,""))
           return(PDM_E_ITEM_NOT_FLAGGED);

/* fix to check that the unflag is for corresponding flag MaC 011894 */

         if  (strcmp (PDMpart.n_pendingflag, "ID"))
              return(PDM_E_NOT_FLAGGED_AS_ITEM_DELETE);

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*

	if(!strncmp(PDMpart.n_setindicator,"Y",1))
*/
	if(!strncmp(PDMpart.n_setindicator,"Y",1) || 
           !strncmp(PDMpart.n_setindicator,"A",1))
	{
	status = NFMcancel_set_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	if(status == NFM_E_SET_NOT_FLAGGED)
	{
	status = PDM_E_SET_NOT_FLAGGED;
         return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
	status = PDM_E_SET_NOT_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_RESTO)
	{
	status = PDM_E_NOT_FLAGGED_AS_ITEM_RESTORE;
         return(status);
	}
	else if(status == NFM_E_MEMBER_NOT_FLAGGED)
	{
	status = PDM_E_MEMBER_NOT_FLAGGED;
        return(status);
	}
_PDMdebug(fname,"NFMcancel_set_flag for delete failed status <0x%.8x>\n",
			status);
        ERRget_specific_number (NFM, &status);
	return(status);
	}
      }
     else
        {
	status = NFMcancel_item_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	if(status == NFM_E_ITEM_NOT_FLAGGED)
	{
	status = PDM_E_ITEM_NOT_FLAGGED;
        return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
	status = PDM_E_ITEM_NOT_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_SET_NOT_FLAGGED)
	{
	status = PDM_E_SET_NOT_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_DELET)
	{
	status = PDM_E_NOT_FLAGGED_AS_ITEM_DELETE;
        return(status);
	}
	else if(status == NFM_E_MEMBER_NOT_FLAGGED)
	{
	status = PDM_E_MEMBER_NOT_FLAGGED;
        return(status);
	}
	_PDMdebug(fname,"NFMcancel_item_delete_flag failed status <0x%.8x>\n",
		status);
        ERRget_specific_number (NFM, &status);
	return(status);
	}
       }
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
}

int	PDMsUnflag_part_restore()
{
        char    *fname = "PDMsUnflag_part_restore";

	_PDMdebug(fname,"ENTER:\n");
         status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fname, "PDMload_part_info failed status %d\n", status);
                return (status);
        }

         if(!strcmp(PDMpart.n_pendingflag,""))
           return(PDM_E_ITEM_NOT_FLAGGED);


/* fix to check that the unflag is for corresponding flag MaC 011894 */

         if  ((strcmp (PDMpart.n_pendingflag, "IR"))
               && (strcmp (PDMpart.n_pendingflag, "SR"))
               && (strcmp (PDMpart.n_pendingflag, "MR"))
               && (strcmp (PDMpart.n_pendingflag, "PR")) )
              return(PDM_E_NOT_FLAGGED_AS_ITEM_RESTORE);

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(PDMpart.n_setindicator,"Y",1))
*/
	if(!strncmp(PDMpart.n_setindicator,"Y",1) || 
           !strncmp(PDMpart.n_setindicator,"A",1))
	{
	status = NFMcancel_set_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	if(status == NFM_E_SET_NOT_FLAGGED)
	{
	status = PDM_E_SET_NOT_FLAGGED;
         return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
	status = PDM_E_SET_NOT_FLAGGED;
         return(status);
	}
	else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_RESTO)
	{
	status = PDM_E_NOT_FLAGGED_AS_ITEM_RESTORE;
         return(status);
	}
	else if(status == NFM_E_MEMBER_NOT_FLAGGED)
	{
	status = PDM_E_MEMBER_NOT_FLAGGED;
        return(status);
	}
	_PDMdebug(fname,"NFMcancel_set_restore_flag failed status <0x%.8x>\n",
			status);
        ERRget_specific_number (NFM, &status);
	return(status);
	}
      }
	else
	{
	status = NFMcancel_item_flag(
		 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
	if(status != NFM_S_SUCCESS)
	{
	if(status == NFM_E_ITEM_NOT_FLAGGED)
	{
	status = PDM_E_ITEM_NOT_FLAGGED;
        return(status);
	}
	else if(status == MEM_S_SUCCESS)
	{
	status = PDM_E_ITEM_NOT_FLAGGED;
        return(status);
         }
	else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_RESTO)
	{
	status = PDM_E_NOT_FLAGGED_AS_ITEM_RESTORE;
         return(status);
	}
	_PDMdebug(fname,"NFMcancel_item_restore_flag failed status <0x%.8x>\n",
			status);
        ERRget_specific_number (NFM, &status);
	return(status);
	}
       }
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
}

int	PDMsUnflag_part_backup()
{
        char    *fname = "PDMsUnflag_part_backup";
       

	_PDMdebug(fname,"ENTER:\n");
         status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fname, "PDMload_part_info failed status %d\n", status);
                return (status);
        }
         if(!strcmp(PDMpart.n_pendingflag,""))
           return(PDM_E_ITEM_NOT_FLAGGED);

/* fix to check that the unflag is for corresponding flag MaC 011894 */

         if  ((strcmp (PDMpart.n_pendingflag, "IB"))
               && (strcmp (PDMpart.n_pendingflag, "SB"))
               && (strcmp (PDMpart.n_pendingflag, "MB"))
               && (strcmp (PDMpart.n_pendingflag, "PB")) )
/*
              return(PDM_E_ITEM_NOT_FLAGGED);
*/
              return(PDM_E_NOT_FLAGGED_AS_ITEM_BACKUP);



/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if(!strncmp(PDMpart.n_setindicator,"Y",1))
*/
	if(!strncmp(PDMpart.n_setindicator,"Y",1) || 
           !strncmp(PDMpart.n_setindicator,"A",1))
	{
		status = NFMcancel_set_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMcancel_set_backup_flag failed status %d\n",
			status);PDMdebug(s);
			if(status == NFM_E_ITEM_NOT_BACKED_UP)
			{
				status = PDM_E_ITEM_NOT_BACKED_UP;
                                return(status);
			}
			else if(status == NFM_E_SET_NOT_FLAGGED)
			{
				status = PDM_E_SET_NOT_FLAGGED;
                                return(status);
			}
			else if(status == MEM_S_SUCCESS)
			{
				status = PDM_E_SET_NOT_FLAGGED;
                                return(status);
			}
			else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_DELET)
			{
				status = PDM_E_NOT_FLAGGED_AS_ITEM_DELETE;
                                return(status);
			}
                       ERRget_specific_number (NFM, &status);
			return(status);
		}
    }
	else
	{
		status = NFMcancel_item_flag(
			 PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMcancel_item_backup_flag failed status %d\n",
			status);PDMdebug(s);
			if(status == NFM_E_ITEM_NOT_BACKED_UP)
			{
				status = PDM_E_ITEM_NOT_BACKED_UP;
                                return(status);
			}
			else if(status == NFM_E_ITEM_NOT_FLAGGED)
			{
				status = PDM_E_ITEM_NOT_FLAGGED;
                                return(status);
			}
			else if(status == MEM_S_SUCCESS)
			{
				status = PDM_E_ITEM_NOT_FLAGGED;
                                return(status);
			}
			else if(status == NFM_E_NOT_FLAGGED_AS_ITEM_DELET)
			{
				status = PDM_E_NOT_FLAGGED_AS_ITEM_DELETE;
                                return(status);
			}
                        ERRget_specific_number (NFM, &status);
			return(status);
		}
	}
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
}




int  _PDMcheck_flag_status (attr_name, flag_stat)

char	*attr_name, *flag_stat;
{
	char	*fname = "_PDMcheck_flag_status";
	char	**data;
	MEMptr	temp_bufr = NULL;
	char	sql_str[512];

        _PDMdebug(fname, "EXIT:\n");

    sql_str[0] = '\0';
    
    _PDMdebug (fname, "attr_name[%s] \n", attr_name);

    sprintf (sql_str, 
   "SELECT n_archivestate FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s' AND NOT (n_archivestate is NULL)",
       PDMexec->catalog, PDMexec->part_num, PDMexec->revision);

        status = SQLquery(sql_str, &temp_bufr, 512);
        if (status != SQL_S_SUCCESS) {
           if (status == SQL_I_NO_ROWS_FOUND)
              status = PDM_E_FILE_NOT_ARCHIVED;
           _PDMdebug (fname, "SQLquery failed: %d\n", status);
           MEMclose(&temp_bufr);
           return (status);
        }

        status = MEMbuild_array(temp_bufr);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&temp_bufr);
        _PDMdebug(fname, "MEMbuild_array failed status %d \n", status);
                return (PDM_E_BUILD_ARRAY);
        }

        data = (char **) temp_bufr->data_ptr;
        strcpy(flag_stat, data[0]);
        
        MEMclose(&temp_bufr);
        _PDMdebug (fname, "Flag stat [%s]\n", flag_stat);
        _PDMdebug(fname, "EXIT:\n");
        return (PDM_S_SUCCESS);
}
           

int  _PDMInterpretPendingFlag (PendingFlag)
char	*PendingFlag;
{
   char		*fn = "_PDMInterpretPendingFlag ";
   
 _PDMdebug (fn, "Enter\n");

         if  ((!strcmp (PendingFlag, "IA"))
               || (!strcmp (PendingFlag, "SA"))
               || (!strcmp (PendingFlag, "MA"))
               || (!strcmp (PendingFlag, "PA")) ) {
              _PDMdebug (fn, "Pending Flag -> %s\n", PendingFlag);
              _PDMdebug (fn, "Exit\n");
              return(PDM_E_ALREADY_FLAGGED_FOR_ARCHIVE);
             }

         else if  ((!strcmp (PendingFlag, "IB"))
               || (!strcmp (PendingFlag, "SB"))
               || (!strcmp (PendingFlag, "MB"))
               || (!strcmp (PendingFlag, "PB")) ) {
              _PDMdebug (fn, "Pending Flag -> %s\n", PendingFlag);
              _PDMdebug (fn, "Exit\n");
              return(PDM_E_ALREADY_FLAGGED_FOR_BACKUP);
             }

         else if  (!strcmp (PendingFlag, "ID")) {
              _PDMdebug (fn, "Pending Flag -> %s\n", PendingFlag);
              _PDMdebug (fn, "Exit\n");
              return(PDM_E_ALREADY_FLAGGED_FOR_DELETE);
             }

         else if  ((!strcmp (PendingFlag, "IR"))
               || (!strcmp (PendingFlag, "SR"))
               || (!strcmp (PendingFlag, "MR"))
               || (!strcmp (PendingFlag, "PR")) ) {
              _PDMdebug (fn, "Pending Flag -> %s\n", PendingFlag);
              _PDMdebug (fn, "Exit\n");
              return(PDM_E_ALREADY_FLAGGED_FOR_RESTORE);
             }

_PDMdebug (fn, "Exit\n");
return(PDM_S_SUCCESS);
}

