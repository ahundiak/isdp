#include		<stdio.h>
#include                "PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"PDUstorage.h"
#include		"PDMproto.h"
#include		"PDMmessage.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];
extern char   glob_var[100];
extern		PDMexec_ptr	PDMexec;
extern struct	PDUstorage *storage;

/*
	INPUT: storage_buffer
		   Buffer containing the storage area information 
		   of the requester
			   
	OUTPUT: local_files  Buffer containing a List of Local Files
*/

int PDMlist_local_files(file_list)
	MEMptr		*file_list;
{

   PDMdebug("ENTER:PDMlist_local_files\n");

   *file_list = NULL;

/*
   status = MEMbuild_array(storage_buffer);
   if(status != MEM_S_SUCCESS)
   {
	sprintf(s, "MEMbuild_array failed status %d\n", status);
	PDMdebug(s);
	return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) storage_buffer->data_ptr;
   columns = (char **) storage_buffer->column_ptr;
   n1 = -1; n2 = -1; n3 = -1;
   for(j=0;j<storage_buffer->columns;j++)
   {
	   if(!strcmp(columns[j], "node_name"))  n1 = j;
       if(!strcmp(columns[j], "user_name"))  n2 = j;
       if(!strcmp(columns[j], "path_name"))  n3 = j;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1)
   {
		PDMdebug("Couldnot find cols in <storage_buffer>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
*/
   status = PDMshow_file_list(file_list);
   if(status == PDM_S_SUCCESS)
   {
	   PDMdebug("EXIT:PDMlist_local_files\n");
	   return(PDM_S_SUCCESS);
   }
   else if(status ==  PDM_I_NO_FILES_FOUND)
   {
	   PDMdebug("No file_list to send \n");
	   PDMdebug("EXIT:PDMlist_local_files\n");
	   return(status);		
   }
   else
   {
		sprintf(s, "PDMshow_file_list failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
}

/*
	INPUT: 
	
	(a).   storage_buffer

		   Buffer containing the storage area information 
		   of the requester
			   
	(b).   local_files  

		   Buffer containing a List of Local Files to delete

          Kumar - 2/7/92
*/

int PDMdelete_local_files (
	MEMptr		pdu_file_list, 
	MEMptr		*return_buffer
)
{
	char		**columns, **data;
        char            *fname = "PDMdelete_local_files";
	int			n1, n2, n3, n4, n5, n6, n7 = 0;
	int			nx, i;
	int			p_sano;
        char            action[20];
        char            *msg = NULL;
        MEMptr          file_list = NULL;
        long            fmgr_status = PDM_I_FILE_DELETE;

    _PDMdebug(fname, "ENTER:\n");
        msg = (char *)PDUtranslate_message(PDS_M_DELETE_LOCAL_FILES);
        strcpy(glob_var, msg);
        PDMupdate_dots();
   
    action[0] = '\0';

   if (PDMdebug_on)
      {
	PDMprint_storage_area();
        MEMprint_buffer("file list from pdu", file_list, PDM_DEBUG_FILE);
       }

   p_sano = storage->storage_no;
   status = PDMload_partnos(pdu_file_list);
   if(status != PDM_S_SUCCESS)
   {
       _PDMdebug(fname, "PDMload_partnos failed status %d\n", status);
	return(status);
   }
        PDMupdate_dots();
     status = PDMexp_copy_bufr(pdu_file_list, &file_list);
      if(status != PDM_S_SUCCESS)
      {
       _PDMdebug(fname, "PDMexp_copy_bufr failed status %d\n", status);
	return(status);
      }

        PDMupdate_dots();
   status = PDMload_partnos(file_list);
   if(status != PDM_S_SUCCESS)
   {
       _PDMdebug(fname, "PDMload_partnos failed status %d\n", status);
	return(status);
   }
        PDMupdate_dots();
   status = MEMbuild_array(file_list);
   if(status != MEM_S_SUCCESS)
   {
        _PDMdebug(fname, "MEMbuild_array failed : status %d\n", status);
        return(PDM_E_BUILD_ARRAY);
   }
   data = (char **) (file_list)->data_ptr;
   columns = (char **) (file_list)->column_ptr;

    n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1; n6 = -1;

    for(i=0; i < (file_list)->columns; i++)
    {
                if (!strcmp(columns[i], "n_catalogno"))
                        n1 = i;
                else if (!strcmp(columns[i], "n_itemno"))
                        n2 = i;
                else if (!strcmp(columns[i], "n_catalogname"))
                        n3 = i;
                else if (!strcmp(columns[i], "n_itemname"))
                        n4 = i;
                else if (!strcmp(columns[i], "n_itemrev"))
                        n5 = i;
                else if (!strcmp(columns[i], "n_cofilename"))
                        n6 = i;
                else if (!strcmp(columns[i], "p_action"))
                        n7 = i;
    }
if (n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1 ){
          _PDMdebug(fname, " %s %s \n", 
                        "PDMcodelete_local_files : ", "Failed to set offsets");
                return (PDM_E_BUFFER_FORMAT);
        }

   for(i=0;i<(file_list)->rows;i++)
   {
	nx = i * (file_list)->columns;
        PDMupdate_dots();
	fmgr_status = PDMupdate_fmgr_delete(p_sano, data[nx+n6], atoi(data[nx+n1]), atoi(data[nx+n2]), pdu_file_list);

      _PDMdebug(fname, "PDMupdate_fmgr_delete status <0x%x.8>\n", fmgr_status);
        if(fmgr_status == PDM_I_FILE_DELETE) strcpy(action, "SUCCESS");
       else  if(fmgr_status == PDM_I_CHECK_OUT) strcpy(action, "CHECKED OUT");
       else if(fmgr_status == PDM_I_COPY_UPDATE) strcpy(action, "REFERENCED");
       else  continue;
      status = MEMwrite_data((file_list), action, i+1, n7+1);
      if (status != MEM_S_SUCCESS)
       {
        _PDMdebug (fname, "MEM error  0x%.8x\n", status);
         return (NFM_E_MEM);
      }
   }
       MEMsplit_copy_buffer(file_list, return_buffer, 0);
       if(PDMdebug_on)
       MEMprint_buffer("delete_list to pdu", *return_buffer, PDM_DEBUG_FILE);

        PDMupdate_dots();
       PDMreset_dots();
   _PDMdebug(fname, "EXIT:-SUCCESS\n");
   return(PDM_S_SUCCESS);
}

/*
	INPUT: storage_buffer
		   Buffer containing the storage area information 
	OUTPUT: local_files  Buffer containing a List of Local Files
*/

int PDMchkin_files_of_user(file_list)
MEMptr		*file_list;
{
	char		**data, **cat_data, **info_data;
	int		j, jxj, k, kx;
	MEMptr		bufr = NULL;
	MEMptr		cat_bufr = NULL;
	MEMptr		info_bufr = NULL;
        int             userno;
        char            sql_str[1024];
        char            a_row[1024];

   PDMdebug("ENTER:PDMchkin_files_of_user\n");

   *file_list = NULL;

      userno = PDMexec->user_id;

       sql_str[0] = '\0';
    sprintf(sql_str, " SELECT n_username from nfmusers WHERE n_userno = %d", userno);
      status = SQLquery(sql_str, &bufr, 512);
        if(status != SQL_S_SUCCESS)
           {
              MEMclose(&bufr);
              return(status);
           }
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
              MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   data = (char **) bufr->data_ptr;
    
   sql_str[0] = '\0';

    sprintf(sql_str, "SELECT n_catalogname, n_type FROM nfmcatalogs WHERE n_identifier ='PDM' AND n_catalogname != 'pdmlibraries' ORDER BY n_catalogname");
       status = SQLquery(sql_str, &cat_bufr, 512);
        if(status != SQL_S_SUCCESS)
           {
              MEMclose(&bufr);
              MEMclose(&cat_bufr);
              if(status != SQL_I_NO_ROWS_FOUND)
                    return(PDM_E_CATALOG_NOT_FOUND);
              return(status);
           }
          status = MEMbuild_array(cat_bufr);
                   if(status != MEM_S_SUCCESS)
                    {
                MEMclose(&bufr);
                MEMclose(&cat_bufr);
                MEMclose(&info_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
                     }
          cat_data = (char **) cat_bufr->data_ptr;


 status = MEMopen(file_list, 1024);
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list); MEMclose(&bufr);
                sprintf(s, "MEMopen failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*file_list, "n_catalogname", "char(20)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemname", "char(120)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
              return(PDM_E_WRITE_FORMAT);
   }
 status = MEMwrite_format(*file_list, "n_itemrev", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemdesc", "char(120)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_filetype", "char(5)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                     return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_cofilename", "char(15)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_local", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_statename", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
               MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_update", "char(3)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_parttype", "char(2)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(file_list);MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }

   for(j=0;j<cat_bufr->rows;j++)
   {
       jxj = j * cat_bufr->columns;
      sql_str[0] = '\0';         
       _PDMdebug("catalog", "%s type %s\n", cat_data[jxj], cat_data[jxj+1]);
/* Added support for PXT type of catalogs MaC 041494 */
         if((strcmp(cat_data[jxj+1], "P")) 
            && (strcmp(cat_data[jxj+1], "PXT"))
            && (strcmp(cat_data[jxj+1], "EID"))
            && (strcmp(cat_data[jxj+1], "CID")))
         {
sprintf(sql_str, "SELECT t1.n_itemname, t1.n_itemrev, t1.n_itemdesc, t1.p_parttype, t2.n_cofilename, t2.n_filetype, t3.n_statename FROM f_%s t2, %s t1, nfmstates t3 WHERE t1.n_status = 'I' AND t2.n_ciuser = '%s' AND  t1.n_itemno = t2.n_itemnum  AND t3.n_stateno = t1.n_stateno AND t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum) ORDER BY t1.n_itemname, t1.n_itemrev, t2.n_cofilename", cat_data[jxj], cat_data[jxj], data[0], cat_data[jxj]);
            status = SQLquery(sql_str, &info_bufr, 512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&info_bufr);
                     continue;
                    }
               else
                    {
                    MEMclose(&bufr);
                    MEMclose(&cat_bufr);
                     MEMclose(&info_bufr);
                     return(PDM_E_SQL_QUERY);
                    }
               }
             status = MEMbuild_array(info_bufr);
                   if(status != MEM_S_SUCCESS)
                    {
                MEMclose(&bufr);
                MEMclose(&cat_bufr);
                MEMclose(&info_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
                     }
          info_data = (char **) info_bufr->data_ptr;
            for(k = 0; k < info_bufr->rows; k++)
            {
               kx = k * info_bufr->columns;

            a_row[0] = '\0';
sprintf(a_row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
        cat_data[jxj], info_data[kx], info_data[kx+1], info_data[kx+2], info_data[kx+5], info_data[kx+4], "CHECKED IN", info_data[kx+6], "Y", info_data[kx+3]);
                status = MEMwrite(*file_list, a_row);
                if(status != MEM_S_SUCCESS)
                {
                        MEMclose(file_list);MEMclose(&bufr);
                        MEMclose(&cat_bufr);
                        MEMclose(&info_bufr);
                        sprintf(s, "MEMwrite failed status %d\n", status);
                        PDMdebug(s);
                        return(PDM_E_WRITE_ROW);
                }
             }
               MEMclose(&info_bufr);
               info_bufr = NULL;
          }
               
       }
                MEMclose(&bufr);
                MEMclose(&cat_bufr);
                MEMclose(&info_bufr);

	   PDMdebug("EXIT:PDMchkin_files_of_user\n");
	   return(PDM_S_SUCCESS);
}


/*
	INPUT: storage_buffer
		   Buffer containing the storage area information 
		   of the requester
			   
	OUTPUT: local_files  Buffer containing a List of Local Files
*/

int PDMlist_chkout_files(file_list)
	MEMptr		*file_list;
{

   PDMdebug("ENTER:PDMlist_chkout_files\n");

   *file_list = NULL;

/*
   status = MEMbuild_array(storage_buffer);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) storage_buffer->data_ptr;
   columns = (char **) storage_buffer->column_ptr;
   n1 = -1; n2 = -1; n3 = -1;
   for(j=0;j<storage_buffer->columns;j++)
   {
	   if(!strcmp(columns[j], "node_name"))  n1 = j;
       if(!strcmp(columns[j], "user_name"))  n2 = j;
       if(!strcmp(columns[j], "path_name"))  n3 = j;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1)
   {
		PDMdebug("Couldnot find cols in <storage_buffer>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
*/
   status = PDMshow_chkout_files(file_list);
   if(status == PDM_S_SUCCESS)
   {
	   PDMdebug("EXIT:PDMlist_chkout_files\n");
	   return(PDM_S_SUCCESS);
   }
   else if(status ==  PDM_I_NO_FILES_FOUND)
   {
	   PDMdebug("No file_list to send \n");
	   PDMdebug("EXIT:PDMlist_chkout_files\n");
	   return(status);		
   }
   else
   {
		sprintf(s, "PDMshow_chkout_files failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
}

