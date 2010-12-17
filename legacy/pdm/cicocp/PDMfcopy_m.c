#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include                "NFMapi.h"
#include                "NFMitems.h"
#include                "NFMitemfiles.h"
#include                 "MSGstruct.h"
#include                 "PDUstorage.h"
#include		"PDMproto.h"

#define NFM_TEMP_SIZE1 12

/* APOGEE START static long     RIScode; APOGEE END */
static long     status;
static int      curbuf_no;
static char     s[1024];
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern struct PDUstorage *storage;
extern char   glob_var[100];

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
 * Kumar - 5.3.91
 */

int 
PDMfcopy_attach(PDMexec)
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
	char            sql_str[1024];
        char            cur_date[12],cur_time[12];
	char          **data;
	char          **temp_data;
	char          **ass_data;
	int             n_itemname,p_ref2;
	long            p_seqno;

	PDMdebug("ENTER:PDMfcopy_attach\n");

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
        status = PDMload_part_info(PDMexec->catalog,PDMexec->part_num,
                                   PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&type_bufr);
		MEMclose(&strg_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_LOAD_PART);
	}
	if (!strncmp(PDMpart.p_parttype, "N", 1) || !strncmp(PDMpart.p_parttype, "n", 1)) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "p_parttype is set to non-graphic\n");
			PDMdebug(s);
			return (PDM_E_PART_NONGRAPHIC);
		}
	if (!strncmp(PDMpart.n_status, "", 1) || !strncmp(PDMpart.n_status, "TI", 1) || !strncmp(PDMpart.n_status, "TI", 1)  || !strncmp(PDMpart.n_status, "TO", 1)) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "Part is in a wrong state\n");
			PDMdebug(s);
			return (PDM_E_BAD_STATE);
		}
	if (!strncmp(PDMpart.n_itemlock, "Y", 1) || !strncmp(PDMpart.n_itemlock, "y", 1) ) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
			sprintf(s, "Part is in a wrong state\n");
			PDMdebug(s);
			return (PDM_E_ITEM_LOCKED);
		}


	/* p_seqno = 0 */

	if (p_seqno == 0) 
      {
   status = PDMris_get_fmgr(PDMpart.n_catalogno,PDMpart.n_itemno,PDMpart.n_cosano,cur_date,cur_time,&p_ref2,&n_itemname);

	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&type_bufr);
		MEMclose(&strg_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_FMGR);
	}
        if (status == SQL_I_NO_ROWS_FOUND)
           {
              status = PDMload_fmgr_ris(n_itemname,PDMpart.n_catalogno,
                PDMpart.n_itemno,PDMpart.n_cosano,PDMpart.n_cofilename,1,3);
	        if (status != PDM_S_SUCCESS) {
		MEMclose(&type_bufr);
		MEMclose(&strg_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (PDM_E_FMGR);
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
             }
             else if (status == SQL_S_SUCCESS)
              {
                status = PDMfmgr_increment(n_itemname,PDMpart.n_cosano, 1, p_ref2);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&type_bufr);
			MEMclose(&strg_bufr);
		sprintf(s, "PDMfmgr_increment failed status %d\n", status);
			PDMdebug(s);
			return (status);
		                             }
                }
        }
	 else 
            {		/* copy from active bom */
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
						   atol(data[0]), &assembly);
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
			status = PDMcopy_atomic_file(
						     PDMexec->user_id,
						 temp_data[0], temp_data[1],
						     temp_data[2], strg_bufr,
						     p_seqno, &attach_bufr);
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
	PDMdebug("EXIT:PDMfcopy_attach\n");
	return (PDM_S_SUCCESS);
}



/* 
     The specified PDM parts file is copied to the WS
     Part should have the assoc. graphic file 
	 Also the ws_buffer contains all the storage area info
     - Kumar
*/

int	PDMcopy_file(copy_bufr, exp_copy_bufr)
    MEMptr		copy_bufr;
    MEMptr		*exp_copy_bufr;
{
  char *fname="PDMcopy_part_files";
  char sql_str[1024], working_area[20];
  char row_str[3048];
  char dumb_str[2];
  char **data = NULL, **file_data = NULL, **copy_data = NULL, **temp_data = NULL,**column_ptr = NULL;
  char *msg = NULL;
  char **file_data1, **file_column;
  char filename[NFM_COFILENAME+1];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  int x, y, z,nxi;
  int n1,n2,n3,n4,n5,n6,n7,xi = 0,i = 0, j= 0, nxj = 0;
  int index;
  int i_catno, i_itemnum, i_type, i_fileno, i_filenum, i_fileversion,
      i_filetype, i_fileco, i_cifilename, i_cofilename,
      i_cisano, i_status1;
  long  sano = 0, sto_no;
  long status, dumb_value, fmgr_status;
  MEMptr file_list = NULL, files_info = NULL;
  MEMptr temp_list = NULL, list = NULL,fmgr_bufr = NULL ;
  struct NFMsto_info  *sto_list = NULL;
  struct NFMbuf_format *format;

	PDMdebug("ENTER:PDMcopy_file\n");

        dumb_value = -1;
        PDMreset_dots();
        msg = (char *)PDUtranslate_message(PDM_I_COPYING_FILES); 
        strcpy(glob_var,msg);
        PDMupdate_dots();
      
	*exp_copy_bufr = NULL;
        strcpy(working_area,storage->storage_name);

if(PDMdebug_on)
	MEMprint_buffer("copy_bufr",copy_bufr,PDM_DEBUG_FILE);

  _PDMdebug ( fname, " working_area[%s] \n", working_area);

       status = PDMload_partnos(copy_bufr);
        if(status != PDM_S_SUCCESS)
         {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
          }

        PDMupdate_dots();
  status = MEMbuild_array(copy_bufr);
  if(status != MEM_S_SUCCESS)
   {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
    }
  copy_data = (char **)copy_bufr->data_ptr;
  column_ptr = (char **)copy_bufr->column_ptr;
        n1 = -1;
        n2 = -1;
        n3 = -1;
        n4 = -1;
        n5 = -1;
        n6 = -1;
        n7 = -1;
   
      for(i=0; i < copy_bufr->columns; i++)
       {
                if (!strcmp(column_ptr[i], "n_catalogno"))
                        n1 = i;
                else if (!strcmp(column_ptr[i], "n_itemno"))
                        n2 = i;
                else if (!strcmp(column_ptr[i], "n_catalogname"))
                        n3 = i;
                else if (!strcmp(column_ptr[i], "n_itemname"))
                        n4 = i;
                else if (!strcmp(column_ptr[i], "n_itemrev"))
                        n5 = i;
                else if (!strcmp(column_ptr[i], "n_cofilename"))
                        n6 = i;
                else if (!strcmp(column_ptr[i], "p_action"))
                        n7 = i;
        } 
if (n1 == -1 || n2 == -1 ||
            n3 == -1 || n4 == -1 ||
            n5 == -1 || n6 == -1 || n7 == -1){
                _PDMdebug(fname, " %s %s \n",
                        "PDMcopy_part_files : ", "Failed to set offsets");
                return (PDM_E_BUFFER_FORMAT);
        }
/* Expand the copy bufr */

 status = PDMexp_copy_bufr(copy_bufr, exp_copy_bufr);
                        if (status != PDM_S_SUCCESS) {
                                sprintf(s,
                                "PDMexpand_copy_bufr failed status %d\n",
                                        status);
                                PDMdebug(s);
                                return (status);
                        }

        PDMupdate_dots();
if(PDMdebug_on)
	MEMprint_buffer("exp_copy_bufr",*exp_copy_bufr,PDM_DEBUG_FILE);
  status = PDMstop_transaction (1200);
  if (status != PDM_S_SUCCESS)
  {
    _PDMdebug (fname, "PDMstop_transaction: 0x%.8x\n", status);
    return (status);
  }


  status = MEMbuild_array(*exp_copy_bufr);
  if(status != MEM_S_SUCCESS)
   {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
    }
  copy_data = (char **)(*exp_copy_bufr)->data_ptr;
  column_ptr = (char **)(*exp_copy_bufr)->column_ptr;
  /* get storage area information */

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status);
    return (status);
  }

        PDMupdate_dots();
  status = MEMopen (&files_info, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
      return (status);
  }

  format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                              NFM_TEMP_SIZE1 * sizeof (struct NFMbuf_format));

  if (!format)
  {
    MEMclose (&files_info);
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemnum");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_type");
  strcpy ((format+2)->data_type, "char(1)");
  strcpy ((format+3)->attr_name, "n_fileno");
  strcpy ((format+3)->data_type, "integer");
  strcpy ((format+4)->attr_name, "n_filenum");
  strcpy ((format+4)->data_type, "integer");
  strcpy ((format+5)->attr_name, "n_fileversion");
  strcpy ((format+5)->data_type, "integer");
  strcpy ((format+6)->attr_name, "n_filetype");
  strcpy ((format+6)->data_type, "char(5)");
  strcpy ((format+7)->attr_name, "n_fileco");
  strcpy ((format+7)->data_type, "char(1)");
  strcpy ((format+8)->attr_name, "n_cisano");
  strcpy ((format+8)->data_type, "integer");
  strcpy ((format+9)->attr_name, "n_cifilename");
  strcpy ((format+9)->data_type, "char(14)");
  strcpy ((format+10)->attr_name, "n_cofilename");
  strcpy ((format+10)->data_type, "char(14)");
  strcpy ((format+11)->attr_name, "n_status1");
  strcpy ((format+11)->data_type, "char(2)");

  status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&files_info);
    PDMrollback_transaction (1200);
    free (format);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

  status = PDMcreate_fmgr_bufr(&fmgr_bufr);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&files_info);
    MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    free (format);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

  free (format);

  i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
  i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cisano = 8;
  i_cifilename = 9; i_cofilename = 10; i_status1 = 11;

        PDMupdate_dots();
    
  for (x = 0; x < (*exp_copy_bufr)->rows; x++ )
  {
      xi = x * (*exp_copy_bufr)->columns;
    /* prepare buffer for file transfer */

    _PDMdebug (fname,
               "prepare to retrieve the information from f_<%s>\n",copy_data[xi+n3]);
    sprintf (sql_str, "%s %s f_%s %s %s %s '%s' %s %s %s f_%s %s %s %s",
             "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
             "n_cisano, n_cifilename, n_cofilename from", copy_data[xi+n3], 
              "where n_itemnum =", copy_data[xi+n2], 
             "and n_cofilename =", copy_data[xi+n6], "and n_fileversion != 0",
             "and n_fileversion = ",
             "(select max(n_fileversion) from ", copy_data[xi+n3], "where n_itemnum =", copy_data[xi+n2], ")");
    
    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                 dumb_value, &list);
    if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fname, "Part %s %s  of %s catalog not found\n", copy_data[xi+n4],copy_data[xi+n5], copy_data[xi+n3]);
     MEMclose (&list);
           MEMwrite_data(*exp_copy_bufr,"NOT_FOUND",x+1,n7+1);
       continue;
    }
        PDMupdate_dots();
   file_data = (char **) list->data_ptr;

       fmgr_status = PDM_I_FILE_MOVE;

   fmgr_status = PDMcheck_fmgr_copy(sano,copy_data[xi+n6],atoi(copy_data[xi+n1]),atoi(copy_data[xi+n2]),atoi(file_data[1]),atoi(file_data[2]));
        _PDMdebug(fname,"FMGR status 0x%.8x\n",fmgr_status);
         if(fmgr_status == PDM_I_FILE_MOVE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0]='\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "MOVE");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
            }
        else if(fmgr_status == PDM_I_NO_UPDATE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0]='\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1], copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6], "NO_UPDATE");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
               MEMclose(&list);
      list = (MEMptr) NULL;
               continue;
            }
        else if(fmgr_status == PDM_I_CHECK_OUT) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0]='\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "CHECKOUT");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
               MEMclose(&list);
      list = (MEMptr) NULL;
               continue;
            }
        else if(fmgr_status == PDM_I_VERSION_UPDATE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0]='\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "VERSION_UPDATE");
     status =   MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
            }
        else  
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0]='\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "UPDATE_COPY");
     status =   MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
            }
    _PDMdebug (fname, 
                "write the files information of this item to files_info\n");
  if((fmgr_status == PDM_I_VERSION_UPDATE) || (fmgr_status == PDM_I_FILE_MOVE))
  {
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%s\1%s\1%s\1",
               copy_data[xi+n1], copy_data[xi+n2], "S");
      for (z = 0; z < list->columns; z ++)
      {
        strcat (row_str, file_data[index+z]);
        strcat (row_str, "\1");
      }
      strcat (row_str, "\1");
      _PDMdebug (fname, "row_str %s\n", row_str);
      status = MEMwrite (files_info, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
        MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
        PDMrollback_transaction (1200);
        return (status);
      }
    }
   }
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      PDMrollback_transaction (1200);
      return (status);
    }
      list = (MEMptr) NULL;
  }

  if(files_info->rows > 0)
  {
  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEM_S_SUCCESS 0x%.8x\n", status);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    return (status);
  }
  if(PDMdebug_on)
       MEMprint_buffer("files_info",files_info,PDM_DEBUG_FILE);
  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    return (status);
  }
  
  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername, partition,
  nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
  "\1\1\1\1\1\1\1\1\1");

  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    PDMrollback_transaction (1200);
    return (status);
  }
   
  sto_list = (struct NFMsto_info *) calloc (files_info->rows,
                      (files_info->rows +1 ) * sizeof(struct NFMsto_info));

  if (!sto_list)
  {
    _NFMfree_linked_lists (sto_list, NULL);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    _PDMdebug  (fname, "calloc sto_list failed\n") ;
    return (NFM_E_MALLOC);
  }

  sto_list->sano = sano;
  strcpy (sto_list->nodename, nodename);
  strcpy (sto_list->username, username);
  strcpy (sto_list->passwd, passwd);
  strcpy (sto_list->pathname, pathname);
  strcpy (sto_list->devicetype, devicetype);
  strcpy (sto_list->plattername, plattername);
  strcpy (sto_list->partition, partition);
  strcpy (sto_list->nfs, nfs);
  strcpy (sto_list->compress, compress);
  strcpy (sto_list->machid, machid);
  strcpy (sto_list->opsys, opsys);
  strcpy (sto_list->tcpip, tcpip);
  strcpy (sto_list->xns, xns);
  strcpy (sto_list->decnet, decnet);
  strcpy (sto_list->netware, netware);
  
  data = (char **) files_info->data_ptr;

  for (x = 0, sto_no = 1; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    _PDMdebug (fname, "data[index+i_cisano] = %s\n", 
                          data[index+i_cisano]);

    /* check to see if the cisano already on the list */

    for (y = 0; y < sto_no ; y++)
    {
      _PDMdebug  (fname, "(sto_list+%d)->sano: %d\n", y,
                  (sto_list+y)->sano);
      if ( (sto_list+y)->sano  == atol (data[index + i_cisano]) )
      {
        _PDMdebug (fname, "storage_area_no found in sto_list \n" );
        break;
      }
    }
    if (y >= sto_no)
    {
      _PDMdebug (fname, "n_cisano not found in the list, add to it \n");
      _PDMdebug (fname, "n_cisano %s add  \n", data[index+i_cisano]);
      (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
      sto_no++;
    }
  }


  /* at this point, I have a list of storage nos, so retrieve all the
     information from nfmstoragearea and nfmnodes table. */

  status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, NULL);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "NFMget_storages_information 0x%.8x\n", status);
    return (status);
  }
        PDMupdate_dots();

  _PDMdebug (fname, "prepare file transfer buffer\n");
  for (x = 0; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
     sql_str[0] = '\0';
    sprintf (sql_str, 
               "%s %s %d %s '%s' %s %s %s %s %s %s ",
               "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
               "n_fileversion from nfmsafiles where n_sano =", sano, 
               "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =", 
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum]);

    /* COME BACK AND FIX: save the n_co, and n_ref value */
    status = SQLquery (sql_str, &temp_list, MEM_SIZE);
    if (status == SQL_S_SUCCESS)
    {
      status = MEMbuild_array (temp_list);
      if (status != MEM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, NULL);
        MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
        MEMclose (&file_list);
        MEMclose (&temp_list);
        PDMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }

      temp_data = (char **) temp_list->data_ptr;
/*
      _PDMdebug (fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                  temp_data[i_co], temp_data[i_cp], temp_data[i_ref]);
*/
    }
    else if (status == SQL_I_NO_ROWS_FOUND)
    {
       /* add to the table */
    }
    else  
    {
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      PDMrollback_transaction (1200);
      _PDMdebug (fname, "SQLquery 0x%.8x\n", status);
      return (status);
    }
    _PDMdebug (fname, "Try to find cisano [%s] in sto_list\n",
                data[index+i_cisano]);
    _PDMdebug (fname, "sto_no [%d] \n",sto_no);
    row_str[0] = '\0';
    for (y = 0; y < sto_no; y ++)
    {
      _PDMdebug (fname, "(sto_list+%d)->sano = %d\n",
                          y, (sto_list+y)->sano);
      if ((sto_list+y)->sano == atol (data[index+i_cisano]))
      {
        _PDMdebug (fname, "found match in sto_list\n");
        _PDMdebug (fname, "%d\n", (sto_list+y)->sano);
        _PDMdebug (fname, "%s\n", (sto_list+y)->nodename);
        _PDMdebug (fname, "%s\n", (sto_list+y)->username);
        _PDMdebug (fname, "%s\n", (sto_list+y)->passwd);
        _PDMdebug (fname, "%s\n", (sto_list+y)->pathname);
        _PDMdebug (fname, "%s\n", (sto_list+y)->devicetype);
        _PDMdebug (fname, "%s\n", (sto_list+y)->plattername);
        _PDMdebug (fname, "%s\n", (sto_list+y)->partition);
        _PDMdebug (fname, "%s\n", (sto_list+y)->nfs);
        _PDMdebug (fname, "%s\n", (sto_list+y)->compress);
        _PDMdebug (fname, "%s\n", (sto_list+y)->machid);
        _PDMdebug (fname, "%s\n", (sto_list+y)->opsys);
        _PDMdebug (fname, "%s\n", (sto_list+y)->tcpip);
        _PDMdebug (fname, "%s\n", (sto_list+y)->xns);
        _PDMdebug (fname, "%s\n", (sto_list+y)->decnet);
        _PDMdebug (fname, "%s\n", (sto_list+y)->netware);
        sprintf (row_str, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (sto_list+y)->sano,
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
        (sto_list+y)->pathname, (sto_list+y)->devicetype, 
        (sto_list+y)->plattername,
        (sto_list+y)->partition, (sto_list+y)->nfs,
        (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
        (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
        (sto_list+y)->netware);
        _PDMdebug (fname, "Row_str %s\n", row_str);
        break;
      }
    } 
    if (y >= sto_no)
    {
      _PDMdebug (fname, "check-in-to storage area incorrect\n");
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      PDMrollback_transaction (1200);
      return (status);
    }
    if (strlen (data[index+i_fileno]))
    {
    strcat (row_str, data[index+i_fileno]); 
     strcat (row_str, "\1");
      }
     else strcat (row_str, "\1");
    strcat (row_str, "\1"); /* n_fileold */
    if (strlen (data[index+i_cifilename]))
    {
      strcat (row_str, data[index+i_cifilename]);
     strcat (row_str, "\1");
    }
    else 
    {
      status = NFMnew_file_name (0, atol(data[index+i_catno]),
                                 atol(data[index+i_fileno]), filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, NULL);
        MEMclose (&files_info);
        MEMclose (&file_list);
      MEMclose (&fmgr_bufr);
        MEMclose (&temp_list);
        PDMrollback_transaction (1200);
        _PDMdebug (fname, "NFMget_file_name 0x%.8x\n", status);
        return (status);
      }
      strcat (row_str, filename); 
     strcat (row_str, "\1");
    } 
    if (strlen (data[index+i_cofilename]))
    {
    strcat (row_str, data[index+i_cofilename]);
     strcat (row_str, "\1");
    }
     else  strcat (row_str, "\1");
    if (strlen (data[index+i_filetype]))
    {
    strcat (row_str, data[index+i_filetype]); 
     strcat (row_str, "\1");
    }
     else strcat (row_str, "\1");
    /* if (strlen (data[index+i_cifilesize]))
     strcat (row_str, data[index+i_cifilesize]);  
     else  */
          strcat (row_str, "100\1"); 
      strcat (row_str, "2033\1\1\1");

    _PDMdebug (fname, "row_str %s\n", row_str);
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      PDMrollback_transaction (1200);
      return (status);
    }
  } /* prepare file transfer buffer */
if(PDMdebug_on)
{
MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);
MEMprint_buffer("fmgr_bufr",fmgr_bufr,PDM_DEBUG_FILE);
 }

        PDMupdate_dots();
  status = _NFMfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
      _PDMdebug (fname, "_NFMfs_recv_files 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&fmgr_bufr);
      PDMrollback_transaction (1200);
      return (status);
  }

        PDMupdate_dots();
  } /* if there is any information in files_info */
  else
    {
    _PDMdebug (fname, "No files to move\n");
    }

  if(fmgr_bufr->rows > 0)
  {
    if(PDMdebug_on)
    MEMprint_buffer("fmgr_bufr for fmgr update",fmgr_bufr,PDM_DEBUG_FILE);
/* 2/7/96 MJG - TR 139526084 */
/* Added argument "copy_bufr" to function call */
  status = PDMupdate_fmgr_copy_file (sano,fmgr_bufr, copy_bufr);
  if (status != PDM_S_SUCCESS)
   {
      _PDMdebug (fname, "PDMupdate_fmgr_copy 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      _NFMfs_undo_recv_files (&file_list);
      PDMrollback_transaction (1200);
      return (status);
    }
        PDMupdate_dots();
   }

  status = MEMbuild_array(*exp_copy_bufr);
  if(status != MEM_S_SUCCESS)
   {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
    }
  copy_data = (char **)(*exp_copy_bufr)->data_ptr;
  column_ptr = (char **)(*exp_copy_bufr)->column_ptr;

if(PDMdebug_on)
{
MEMprint_buffer("file_list after file movement",file_list,PDM_DEBUG_FILE);
 }
PDMdebug("calling MEMbuild_array for file_list\n");
      for(i=0; i < (*exp_copy_bufr)->columns; i++)
       {
                if (!strcmp(column_ptr[i], "n_cofilename")) n6 = i;
                else if (!strcmp(column_ptr[i], "p_action")) n7 = i;
        }
status =  MEMbuild_array(file_list);
   if(status == MEM_S_SUCCESS)
    {
         file_data1 = (char **)file_list->data_ptr;
         file_column = (char **)file_list->column_ptr;

        for(i=0; i < file_list->columns; i++)
       {
                if (!strcmp(file_column[i], "n_cofilename")) n1 = i;
                else if (!strcmp(file_column[i], "n_status1")) n2 = i;
        }

for (i = 0; i < (*exp_copy_bufr)->rows; i++) {
                nxi = i * (*exp_copy_bufr)->columns;
                status = MEMwrite_data(*exp_copy_bufr, "NOT_MOVED", i + 1, n7 + 1);
                if (status != MEM_S_SUCCESS) {
                        sprintf(s, "MEMwrite_data failed status %d\n",
                                status);
                        PDMdebug(s);
                        return (PDM_E_WRITE_COLUMN);
                }
        }

for (j = 0; j < (*exp_copy_bufr)->rows; j++)
    {
        nxj = j * (*exp_copy_bufr)->columns;

       for(i=1; i < file_list->rows; i++)
          {
              nxi = i * file_list->columns;
             if ( !strcmp(copy_data[nxj + n6], file_data1[nxi + n1] ))
             { 
               row_str[0] = '\0';
              if(atoi(file_data1[nxi+n2]) == 2035 || atoi(file_data1[nxi+n2]) == 2036)
              {
                  MEMwrite_data(*exp_copy_bufr,"SUCCESS",j+1,n7+1);
               }
              else
               {
                  MEMwrite_data(*exp_copy_bufr,"FAILURE",j+1,n7+1);
                }
             }
          }
    }
   }

else if( (status != MEM_S_SUCCESS) || (file_list == NULL))
     {
       for(i=0; i < (*exp_copy_bufr)->rows; i++)
                  MEMwrite_data(*exp_copy_bufr,"NO_UPDATE",i+1,n7+1);
       }

  PDMdebug("calling NFMfree_linked lists\n");
   if(sto_list != NULL)
   {
  status = _NFMfree_linked_lists (sto_list, NULL);
  if (status != NFM_S_SUCCESS)
    _PDMdebug (fname, "_NFMfree_linked_lists 0x%.8x\n", status);
   }
      
  PDMdebug("MEMclosing buffers\n");
  if (file_list != NULL && file_list->rows > 0) status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
  /*
  if (files_info != NULL) status = MEMclose (&files_info);
  PDMdebug("after MEMclosing buffers\n");
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
  if(fmgr_bufr != NULL) status =   MEMclose (&fmgr_bufr);
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
  */
  status = PDMstart_transaction (1200);
  if (status != PDM_S_SUCCESS)
    _PDMdebug (fname, "PDMstart_transaction 0x%.8x\n", status);


        PDMupdate_dots();
        PDMreset_dots();
  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}

