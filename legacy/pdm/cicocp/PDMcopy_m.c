#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"NFMfile.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"PDUstorage.h"
#include		"PDMproto.h"
#include		"NFMstruct.h"
#include		"NFMfto_buf.h"
#include 		"PDMmessage.h"


/* APOGEE START static long     RIScode; APOGEE END */
static long     status;
static int      curbuf_no;
static char     s[1024];
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern struct   PDUstorage *storage;
extern char glob_var[100];

/*
 * Copies all the files associated with a part. If the part happens to be an
 * assembly all the first level CIT attachments and n-th level attachments
 * from review BOM (if it exists)
 * 
 * ws_buffer contains strg_bufr of the following format
 * 
 * strg_name		char(14) node_name		char(14) user_name
 * har(14) passwd			char(25) path_name
 * 00)
 * 
 * If successfull return_buffer points to MEMbuffer of the following format
 * 
 * n_catalogname		char(XX) n_itemname			char(XX)
 * n_itemrev			char(XX) p_seqno
 * ong n_cofilename		char(14) p_parttype
 * )
 * Written to support part operations form - Kumar
 */

int PDMscopy
(
char *catalog,
char *part,
char *rev,
char *filename
)
{
	MEMptr          copy_bufr = NULL;
	MEMptr          exp_copy_bufr = NULL;
        char            mem_str[512];
        char            *msg = NULL;

	PDMdebug("ENTER:PDMcopy\n");

        msg = (char *)PDUtranslate_message(PDM_I_COPYING_FILES);
        strcpy(glob_var,msg);
        PDMupdate_dots();
         status = MEMopen(&copy_bufr,512);
         if (status != MEM_S_SUCCESS)
          {
                MEMclose(&copy_bufr);
                sprintf(s,"MEMopen failed status %d \n",status);
                PDMdebug(s);
                return(PDM_E_OPEN_BUFFER);
          }
   status = MEMwrite_format(copy_bufr,"n_catalogno","integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"n_itemno","integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"n_catalogname","char(20)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"n_itemname","char(40)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"n_itemrev","char(40)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"n_cofilename","char(14)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"p_parttype","char(2)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(copy_bufr,"p_action","char(20)");
   if(status != MEM_S_SUCCESS)
   {

                MEMclose(&copy_bufr);
                sprintf(s,"MEMwrite_format failed status %d \n",status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }

    mem_str[0] = '\0';
    sprintf(mem_str,"\1\1%s\1%s\1%s\1%s\1\1\1",
                     catalog,part,rev,filename);
   status = MEMwrite(copy_bufr,mem_str);
   if(status != MEM_S_SUCCESS)
   {

                MEMclose(&copy_bufr);
                sprintf(s,"MEMwrite failed status %d \n",status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }
        PDMupdate_dots();
       
		status = PDMcopy_file( copy_bufr, &exp_copy_bufr);
		if (status != PDM_S_SUCCESS)
                   {
              MEMclose(&copy_bufr);
              MEMclose(&exp_copy_bufr);
			sprintf(s, "PDMcopy_atomic_file failed status %d\n",
				status);
			PDMdebug(s);
			return (status);
		}

        PDMupdate_dots();
              MEMclose(&copy_bufr);
              MEMclose(&exp_copy_bufr);
	PDMdebug("EXIT:PDMcopy\n");
        PDMreset_dots();
	return (PDM_S_SUCCESS);
}

/*
 * see the desc. on pdmr side
 * 
 * ws_buffer contains type_bufr and strg_bufr of the following formats
 * 
 * attach_type 		integer p_seqno				integer
 * 
 * strg_name		char(14) node_name		char(14) user_name
 * har(14) passwd			char(25) path_name
 * 00)
 * 
 * If successfull return_buffer points to MEMbuffer of the following format
 * 
 * n_catalogname		char(14) n_itemname			char(14)
 * n_itemrev			char(14) p_seqno
 * ong n_cofilename		char(14) p_parttype
 * )
 * - Kumar Narayanan
 */

int 
PDMXcopy_attach(PDMexec)
	PDMexec_ptr     PDMexec;
{
	MEMptr          assembly = NULL;
	MEMptr          ass = NULL;
	MEMptr          strg_bufr = NULL;
	MEMptr          type_bufr = NULL;
	MEMptr          temp_bufr = NULL;
	MEMptr          attach_bufr = NULL;
	MEMptr          new_files = NULL;
	char            active_bom[40];
	char            p_parttype[2];
/* APOGEE START char            n_status[3]; 
	char            n_archive[2]; APOGEE END */
	char            n_setindicator[2];
	char            sql_str[1024];
	char          **data;
	char          **temp_data;
	char          **ass_data;
	int             n_itemno;
	long            p_seqno;

	PDMdebug("ENTER:PDMcopy_attach\n");

	status = MEMreset_buffer(PDMexec->ws_buffer, &curbuf_no);
	if (status != MEM_S_SUCCESS) {
		sprintf(s,"MEMreset_buffer failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_RESET_BUFFER);
	} else if (curbuf_no != 2) {
		sprintf(s,"Incorrect number of buffers\n");
		PDMdebug(s);
		return (PDM_E_NUMBER_OF_BUFFERS);
	}
	status = MEMsplit_copy_buffer(PDMexec->ws_buffer, &type_bufr, 0);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMsplit_copy_buffer failed status \n", status);
		PDMdebug(s);
		return (PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(PDMexec->ws_buffer, &curbuf_no);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&type_bufr);
		sprintf(s,"MEMreset_buffer failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_RESET_BUFFER);
	} else if (curbuf_no != 3) {
		MEMclose(&type_bufr);
		sprintf(s,"Incorrect number of buffers\n");
		PDMdebug(s);
		return (PDM_E_NUMBER_OF_BUFFERS);
	}
	status = MEMsplit_copy_buffer(PDMexec->ws_buffer, &strg_bufr, 0);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&type_bufr);
		sprintf(s, "MEMsplit_copy_buffer failed status \n", status);
		PDMdebug(s);
		return (PDM_E_COPY_BUFFER);
	}
	status = MEMbuild_array(type_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&type_bufr);
		MEMclose(&strg_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("type_bufr", type_bufr, PDM_DEBUG_FILE);
	}
	data = (char **) type_bufr->data_ptr;
	status = MEMbuild_array(strg_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&type_bufr);
		MEMclose(&strg_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	p_seqno = atol(data[0]);

	/* p_seqno = 0 */

	if (p_seqno == 0) {
		status = PDMquery_partno(PDMexec->catalog,
					 PDMexec->part_num,
					 PDMexec->revision, &n_itemno);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "PDMquery_partno failed status %d\n", status);
			PDMdebug(s);
			return (status);
		}
		/* do not perform copy if file is NON-GRAPHIC */

		p_parttype[0] = '\0';
		status = PDMquery_parttype(PDMexec->catalog,
					   PDMexec->part_num,
					   PDMexec->revision, p_parttype);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "PDMquery_parttype failed status %d\n", status);
			PDMdebug(s);
			return (status);
		}
		if (!strncmp(p_parttype, "N", 1) || !strncmp(p_parttype, "n", 1)) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "p_parttype is set to non-graphic\n");
			PDMdebug(s);
			return (PDM_E_PART_NONGRAPHIC);
		}
		/*
		 * figure out if part is assembly or atomic this is only to
		 * decide on NFMcheck_item
		 */

		n_setindicator[0] = '\0';
		status = PDMquery_assembly_ind(PDMexec->catalog,
					       PDMexec->part_num,
					       PDMexec->revision, 
                                               n_setindicator);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "%s %d\n",
			    "PDMquery_assembly_ind failed status ", status);
			PDMdebug(s);
			return (status);
		}
		/* Check if the part state is OK for a copy */

/* 10/23/95 - MJG - TR 139424087 DM Manager */
		if (!strncmp(n_setindicator, "Y", 1) ||
                    !strncmp(n_setindicator, "A", 1)) {
			status = NFMcheck_item(PDMexec->user_id,
					       PDMexec->catalog,
					       n_itemno, NFM_SET_COPY);
			if (status != NFM_S_SUCCESS) {
				sprintf(s, "NFMcheck_item failed status %d\n", status);
				PDMdebug(s);
/* MSFC fix by Beth 9/17/91 */
                        	if (status == NFM_E_ITEM_IN_TRANS)
					return (PDM_E_CHECKING_IN);
/* end fix */
				return (status);
			}
		} else {
			status = NFMcheck_item(PDMexec->user_id,
					       PDMexec->catalog,
					       n_itemno, NFM_ITEM_COPY);
			if (status != NFM_S_SUCCESS) {
				sprintf(s, "NFMcheck_item failed status %d\n", status);
				PDMdebug(s);
/* MSFC fix by Beth 9/17/91 */
                                if (status == NFM_E_ITEM_IN_TRANS)
        				return (PDM_E_CHECKING_IN);
/* end fix */
				return (status);
			}
		}

		/* copy only the 1-level file (assembly/part) */

		status = PDMcopy_atomic_file(
					     PDMexec->user_id,
					     PDMexec->catalog,
					     PDMexec->part_num,
					     PDMexec->revision, strg_bufr,
					     p_seqno, &attach_bufr);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "PDMcopy_atomic_file failed status %d\n",
				status);
			PDMdebug(s);
			return (status);
		}
	} else {		/* copy from active bom */
		/* get active bom name */

		active_bom[0] = '\0';
		status = PDMquery_bom_name(PDMexec->catalog,
					   PDMexec->part_num,
					   PDMexec->revision,
					   "A", active_bom);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "PDMquery_bom_name failed status \n", status);
			PDMdebug(s);
			return (status);
		}
		if (atol(data[1])) {	/* copy the entire assembly */
			sprintf(sql_str, "%s %s %s %s %s",
			"SELECT p_seqno,n_catalogname,n_itemname, ",
			"n_itemrev,p_attached,p_level FROM ",
			active_bom, "WHERE p_seqno = ", data[0]);
			status = SQLquery(sql_str, &assembly, 1024);
			if (status != SQL_S_SUCCESS) {
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				sprintf(s, "Failed to query %s\n", active_bom);
				PDMdebug(s);
				return (PDM_E_SQL_QUERY);
			}
			status = PDMbuild_assembly(active_bom,
						   atol(data[0]), 
                                                    &assembly);
			if (status) {
				sprintf(s,
				     "PDMbuild_assembly failed status %d\n",
					status);
				PDMdebug(s);
				MEMclose(&assembly);
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				return (status);
			}
			status = PDMmodify_assembly(assembly, &attach_bufr);
			if (status != PDM_S_SUCCESS) {
				sprintf(s,
				    "PDMmodify_assembly failed status %d\n",
					status);
				PDMdebug(s);
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				return (status);
			}
			status = PDMcopy_file_transfers(attach_bufr,
							strg_bufr,
							&new_files);
			if (status != PDM_S_SUCCESS) {
				MEMclose(attach_bufr);
				sprintf(s,
				"PDMcopy_file_transfers failed status %d\n",
					status);
				PDMdebug(s);
				return (status);
			}
			status = PDMsend_files(PDMexec->user_id,
					       attach_bufr, strg_bufr);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "PDMsend_files failed status \n", status);
				PDMdebug(s);
				return (status);
			}
			sprintf(sql_str, "%s %s %s %s %s",
			"SELECT p_seqno,n_catalogname,n_itemname, ",
			"n_itemrev,p_attached,p_level FROM ",
			active_bom, "WHERE p_seqno = ", data[0]);
			status = SQLquery(sql_str, &ass, 1024);
			if (status != SQL_S_SUCCESS) {
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				sprintf(s, "Failed to query %s\n", active_bom);
				PDMdebug(s);

				return (PDM_E_SQL_QUERY);
			}
			status = MEMbuild_array(ass);
			if (status != MEM_S_SUCCESS) {
				MEMclose(&ass);
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				sprintf(s, "MEMbuild_array failed status \n", status);
				PDMdebug(s);
				return (PDM_E_BUILD_ARRAY);
			}
			ass_data = (char **) ass->data_ptr;
			status = PDMupdate_filemanager(ass_data[1],
						   ass_data[2], ass_data[3],
					new_files, strg_bufr, "COPYATTACH");
			if (status != PDM_S_SUCCESS) {
				MEMclose(attach_bufr);
				MEMclose(&new_files);
				sprintf(s,
				 "PDMupdate_filemanager failed status %d\n",
					status);
				PDMdebug(s);
				return (status);
			}
			MEMclose(&new_files);
			MEMclose(&assembly);
			MEMclose(&ass);
		} else {	/* copy only the 1-level entry */
			/* find catalog, part_num and revision from BOM */

			sprintf(sql_str, "%s %s %s %s %s",
				"SELECT n_catalogname,n_itemname, ",
				" n_itemrev FROM ", active_bom,
				"WHERE p_seqno = ", data[0]);
			status = SQLquery(sql_str, &temp_bufr, 1024);
			if (status != SQL_S_SUCCESS) {
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				return (status);
			}
			status = MEMbuild_array(temp_bufr);
			if (status != MEM_S_SUCCESS) {
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				return (PDM_E_BUILD_ARRAY);
			}
			temp_data = (char **) temp_bufr->data_ptr;
			status = PDMcopy_atomic_file( PDMexec->user_id,
                                                      temp_data[0], 
                                                      temp_data[1],
                                                      temp_data[2], 
                                                      strg_bufr,
                                                      p_seqno, 
                                                      &attach_bufr);
			if (status != PDM_S_SUCCESS) {
				MEMclose(&type_bufr);
				MEMclose(&strg_bufr);
				sprintf(s, "PDMcopy_atomic_file failed status %d\n",
					status);
				PDMdebug(s);
				return (status);
			}
			MEMclose(&temp_bufr);
		}
	}
	MEMclose(&type_bufr);
	MEMclose(&strg_bufr);
	if (PDMdebug_on) {
		MEMprint_buffer("attach_bufr", attach_bufr, PDM_DEBUG_FILE);
	}
	PDMexec->return_buffer = attach_bufr;
	PDMdebug("EXIT:PDMcopy_attach\n");
	return (PDM_S_SUCCESS);
}

/*
 *  Detaches a given set of files from the local file manager and tells
 *  PDU to delete the list of given files.
 *      - Kumar  2/7/92
 * ws_buffer contains detach_bufr and strg_bufr of the following formats
 * 
 *  detach_bufr(n_catalogno,n_itemno,n_catalogname,n_itename, n_itemrev,
 *              n_cofilename,n_action)
 *  strg_bufr( strg_no, strg_namechar(14), node_namechar(14),user_name char(14)
 *             passwdchar(25), path_name )
 * 
 * If successfull return_buffer points to MEMbuffer of the following format
 * 
 * n_cofilename		char(128)  for nfs support */

int 
PDMdetach(detach_bufr, delete_list)
	MEMptr          detach_bufr;
	MEMptr          *delete_list;
{

        char *msg = NULL;

	PDMdebug("ENTER:PDMdetach\n");

        msg = (char *)PDUtranslate_message(PDS_M_DETACHING_FILE); 
        strcpy(glob_var,msg);
        PDMupdate_dots();
	*delete_list = NULL;
	status = MEMbuild_array(detach_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&detach_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	if (PDMdebug_on) {
		PDMprint_storage_area();
		MEMprint_buffer("detach_bufr", detach_bufr, PDM_DEBUG_FILE);
	}

status = MEMopen (delete_list, 512);

      if (status != MEM_S_SUCCESS)
       {
		MEMclose(&detach_bufr);
         PDMdebug ( "MEM Open : failed\n");
         return (NFM_E_MEM);
       }
   status = MEMwrite_format (*delete_list, "n_cofilename", "char(128)");
         if (status != MEM_S_SUCCESS)
          {
		MEMclose(&detach_bufr);
                 MEMclose (delete_list);
            PDMdebug ("MEM Wr For : failed status \n");
            return (NFM_E_MEM);
          }
        PDMupdate_dots();
	status = PDMdelete_filelist_pdu(detach_bufr, delete_list);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&detach_bufr);
                 MEMclose (delete_list);
		sprintf(s, "PDMdelete_filemanager_pdu failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
        PDMupdate_dots();
	if (PDMdebug_on) {
		MEMprint_buffer("delete_list", *delete_list, PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMdetach\n");
        PDMreset_dots();
	return (PDM_S_SUCCESS);
}


int PDMXcheck_dup_sa_fname (filename, strg_name)
char           *filename;
char           *strg_name;
{
        char            *fn = "PDMcheck_dup_filename_sa";
        MEMptr          qry1_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        char            **attr;
        char            sql_str[1024];
        int             col, attr_index;
        long            sano = 0;


   PDMdebug("ENTER:PDMcheck_dup_filename_sano\n");

   _PDMdebug (fn, "filename[%s], strg_name[%s]\n", filename, strg_name);


/*
   status = PDMris_get_sano  (strg_name, &sano);
*/
   status = PDMget_storageno (strg_name, &sano);
   if (status != PDM_S_SUCCESS) {
         _PDMdebug (fn, " PDMget_storageno failed %d \n", status);
           return (status);
   }


   sprintf (sql_str,
   "SELECT n_tablename FROM nfmtables WHERE n_tabletype = 'f_catalog'");


   status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
   if (status != SQL_S_SUCCESS ) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
    }

    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
      MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

   if (PDMdebug_on) {
      MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
       }

   attr = (char **) (qry_bufr)->data_ptr;

   for (col = 1; col < qry_bufr->rows; col++) {
      attr_index = col * (qry_bufr)->columns;
      sprintf (sql_str,
      "SELECT n_cifilename, n_cisano FROM %s WHERE %s = '%s' AND %s = %d",
        attr[attr_index], "n_cifilename", filename,
       "n_cisano", sano);

      status = SQLquery (sql_str, &qry1_bufr, MEM_SIZE);
      if ( (status != SQL_S_SUCCESS ) &&
               (status != SQL_I_NO_ROWS_FOUND ) ) {
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
       MEMclose (&qry1_bufr);
       MEMclose (&qry_bufr);
status = _PDMget_db_error (status);
       return (status);
       }

       if (status == SQL_S_SUCCESS) {
           _PDMdebug(fn, "%s exists in %s\n", filename, strg_name);
             MEMclose(&qry1_bufr);
             MEMclose (&qry_bufr);
             return (PDM_E_FILE_ALREADY_EXISTS);
         }
        else {
            _PDMdebug (fn,
             "There is no corresponding filename among parts in %s\n",
                                                       attr[attr_index]);
            }
        MEMclose (&qry1_bufr);
        }

  _PDMdebug(fn, "%s does not exist in %s\n", filename, strg_name);
  MEMclose (&qry_bufr);
  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}
