#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"NFMfile.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"PDMproto.h"


static long     status;
static char     s[1024];
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];


int 
PDMcopy_assembly_files(
		       user_id, catalog,
		       part_num, revision,
		       strg_bufr, attach_bufr)
	long            user_id;
	char           *catalog;
	char           *part_num;
	char           *revision;
	MEMptr          strg_bufr;
	MEMptr         *attach_bufr;
{
	char            review_bom[40];
	MEMptr          new_files = NULL;

	PDMdebug("ENTER:PDMcopy_assembly_files\n");

	review_bom[0] = '\0';
	status = PDMquery_bom_name(catalog,
				   part_num,
				   revision,
				   "R", review_bom);
	if (status != PDM_S_SUCCESS &&
	    status != PDM_E_BOM_NOT_FOUND) {
		sprintf(s, "PDMquery_bom_name failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMprocess_attachments(user_id,
					catalog,
					part_num,
					revision,
					review_bom,
					1, attach_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "PDMprocess_attachments failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = MEMbuild_array(*attach_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMcopy_file_transfers(*attach_bufr,
					strg_bufr, &new_files);
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "PDMcopy_file_transfers failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMsend_files(user_id, *attach_bufr, strg_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		MEMclose(&new_files);
		sprintf(s, "PDMsend_files failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMupdate_filemanager(catalog, part_num, revision,
				       new_files, strg_bufr, "COPY");
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		MEMclose(&new_files);
		sprintf(s, "PDMupdate_filemanager failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	MEMclose(&new_files);
	PDMdebug("EXIT:PDMcopy_assembly_files\n");
	return (PDM_S_SUCCESS);
}

int 
PDMcopy_atomic_file(user_id,
		    catalog,
		    part_num,
		    revision,
		    strg_bufr,
		    p_seqno, attach_bufr)
	long            user_id;
	char           *catalog;
	char           *part_num;
	char           *revision;
	MEMptr          strg_bufr;
	int             p_seqno;
	MEMptr         *attach_bufr;
{
	/* APOGEE START */
	/*char            sql_str[512];*/
	/* APOGEE END */
	char            p_parttype[2];
	long            n_itemno;
	char            filename[20];
	MEMptr          new_files = NULL;
	int             COPY_ATTACH;

	PDMdebug("ENTER:PDMcopy_atomic_file\n");

	if (p_seqno == -1) {
		COPY_ATTACH = 0;
		p_seqno = 0;
	} else
		COPY_ATTACH = 1;

	p_parttype[0] = '\0';

	status = PDMquery_parttype(catalog,
				   part_num,
				   revision, p_parttype);
	if (status != PDM_S_SUCCESS) {
		/* APOGEE START */
		/*
		sprintf("PDMquery_parttype failed %d\n", status);
		*/
		/* APOGEE END */
		sprintf(s,"PDMquery_parttype failed %d\n", status);
		PDMdebug(s);
	}
	status = PDMquery_partno(catalog,
				 part_num,
				 revision, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_partno failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	/* do not perform copy if file is NON-GRAPHIC */

	if (!strncmp(p_parttype, "N", 1) ||
	    !strncmp(p_parttype, "n", 1)) {
		sprintf(s, "p_parttype is set to non-graphic\n");
		PDMdebug(s);
		return (PDM_E_PART_NONGRAPHIC);
	}
	status = NFMcheck_item(user_id,
			       catalog,
			       n_itemno, NFM_ITEM_COPY);
	if (status != NFM_S_SUCCESS) {
		sprintf(s, "NFMcheck_item failed status %d\n", status);
		PDMdebug(s);
		if (status == NFM_E_ITEM_OUT)
			return (PDM_E_PART_CHECKED_OUT);
/* MSFC fix by Beth 9/17/91 */
		else
                if (status == NFM_E_ITEM_IN_TRANS)
                        return (PDM_E_CHECKING_IN);
/* end fix */
		else
			return (status);
	}
	status = PDMi_prepare_buffer1(attach_bufr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_prepare_buffer1 failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	status = PDMi_find_cofilename(catalog, part_num, revision, 
                                                            filename);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_cofilename failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	sprintf(s, "%s\1%s\1%s\1%d\1%s\1%s\1\1%s\1\1",
	   catalog, part_num, revision, p_seqno, filename, p_parttype, "Y");
	status = MEMwrite(*attach_bufr, s);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite failed statuis %d \n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_ROW);
	}
	status = PDMcopy_file_transfers(*attach_bufr,
					strg_bufr, &new_files);
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "PDMcopy_file_transfers failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMsend_files(user_id, *attach_bufr, strg_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		MEMclose(&new_files);
		sprintf(s, "PDMsend_files failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	if (COPY_ATTACH)
		status = PDMupdate_filemanager(catalog, part_num, revision,
					new_files, strg_bufr, "COPYATTACH");
	else
		status = PDMupdate_filemanager(catalog, part_num, revision,
					       new_files, strg_bufr, "COPY");
	if (status != PDM_S_SUCCESS) {
		MEMclose(attach_bufr);
		MEMclose(&new_files);
		sprintf(s, "PDMupdate_filemanager failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	MEMclose(&new_files);
	PDMdebug("EXIT:PDMcopy_atomic_file\n");
	return (PDM_S_SUCCESS);
}

/*
 * returns parts from cit (cit_level members) and parts from bom (all levels)
 * whose p_attached is set to "Y" also n_fileco = 'Y'
 * 
 * format  of attach_bufr
 * 
 * n_catalogname		char(14); n_itemname			char(14);
 * n_itemrev			char(14); p_seqno
 * nteger;   = 0 for cit attachment > 0 for bom attachment BOM(p_seqno)
 * n_cofilename		char(14); n_citno
 * r    Valid for CIT entries p_parttype			char(2)
 * n_fileco 			char(1)
 */

int 
PDMprocess_attachments(
		       user_id, catalog, partnum,
		       revision, bom, cit_level, attach_bufr)
	long            user_id;
	char           *catalog;
	char           *partnum;
	char           *revision;
	char           *bom;
	int             cit_level;
	MEMptr         *attach_bufr;
{
	char            p_attached[2];
	char          **data;
	char          **column_ptr;
	char            p_parttype[2];
	char            filename[20];
	char            zero[30];
	char            sql_str[1024];
	MEMptr          attr_bufr = NULL;
	MEMptr          data_bufr = NULL;
	MEMptr          bufr = NULL;
	int             n1, n2, n3, n4, n5;
	int             i, nxi;

	PDMdebug("ENTER:PDMprocess_attachments\n");

	/* create output buffer */

	status = PDMi_prepare_buffer1(attach_bufr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_prepare_buffer1 failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	/* query set members */

	status = NFMquery_set_members(user_id,
				      catalog, partnum,
				      revision, cit_level, 0,
				      &attr_bufr, &data_bufr);
	if (status != NFM_S_SUCCESS) {
		sprintf(s, "NFMquery_set_members failed status %d\n", status);
		PDMdebug(s);
		MEMclose(attach_bufr);
		return (PDM_E_QUERY_SET_MEMBERS);
	}
	MEMclose(&attr_bufr);
	if (PDMdebug_on) {
		MEMprint_buffer("data_bufr", data_bufr, PDM_DEBUG_FILE);
	}
	status = MEMbuild_array(data_bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		MEMclose(attach_bufr);
		return (PDM_E_BUILD_ARRAY);
	}
        n1 = n2 = n3 = n4 = n5 = -1;
	column_ptr = (char **) data_bufr->column_ptr;
	for (i = 0; i < data_bufr->columns; i++) {
		if (!strcmp(column_ptr[i], "n_citno"))
			n1 = i;
		if (!strcmp(column_ptr[i], "n_status"))
			n2 = i;
		if (!strcmp(column_ptr[i], "n_catalogname"))
			n3 = i;
		if (!strcmp(column_ptr[i], "n_itemname"))
			n4 = i;
		if (!strcmp(column_ptr[i], "n_itemrev"))
			n5 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n5 == -1) {
		MEMclose(attach_bufr);
		MEMclose(&data_bufr);
		PDMdebug("Incorrect NFM buffer <data_bufr> format %d\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) data_bufr->data_ptr;

	/*
	 * The first row is for the part in question load it in attach_bufr
	 */

	status = PDMquery_parttype(data[n3], data[n4],
				   data[n5], p_parttype);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_parttype failed status %d\n",
			status);
		PDMdebug(s);
	}
	status = PDMi_find_cofilename(data[n3], data[n4],
				      data[n5], filename);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_cofilename failed status %d\n",
			status);
		PDMdebug(s);
	}
	zero[0] = '\0';
	sprintf(zero, "%d", 0);
	s[0] = '\0';
	sprintf(s, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
		data[n3], data[n4], data[n5], zero, filename, p_parttype, data[n1], "Y");
	status = MEMwrite(*attach_bufr, s);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		MEMclose(&data_bufr);
		sprintf(s, "MEMwrite failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_WRITE_ROW);
	}
	/* query p_attached from pdmcit and store */

	for (i = 1; i < data_bufr->rows; i++) {
		nxi = i * data_bufr->columns;
		p_attached[0] = '\0';
		status = PDMquery_cit_attachment(
						 atol(data[nxi + n1]),
						 p_attached);
		if (status != PDM_S_SUCCESS) {
			MEMclose(attach_bufr);
			MEMclose(&data_bufr);
			sprintf(s,
				"PDMquery_cit_attachment failed status %d\n", status);
			PDMdebug(s);
			return (status);
		}
		if (!strncmp(p_attached, "Y", 1) ||
		    !strncmp(p_attached, "y", 1)) {
			p_parttype[0] = '\0';
			status = PDMquery_parttype( data[nxi + n3], 
                                                     data[nxi + n4],
                                                     data[nxi + n5], 
                                                     p_parttype);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "PDMquery_parttype failed status %d\n",
					status);
				PDMdebug(s);
			}
			zero[0] = '\0';
			sprintf(zero, "%d", 0);
			s[0] = '\0';
			sprintf(s, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1",
			     data[nxi + n3], data[nxi + n4], data[nxi + n5],
				zero, "", p_parttype, data[nxi + n1], "Y");
			status = MEMwrite(*attach_bufr, s);
			if (status != MEM_S_SUCCESS) {
				MEMclose(attach_bufr);
				MEMclose(&data_bufr);
				sprintf(s,
			     "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				return (PDM_E_WRITE_ROW);
			}
		}
	}
	if (PDMdebug_on) {
		MEMprint_buffer("attach_bufr with parts from CIT",
				*attach_bufr, PDM_DEBUG_FILE);
	}
	MEMclose(&data_bufr);

	/* if bom exists find parts that are attached */

	if (strlen(bom)) {
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s %s",
		  "SELECT n_catalogname,n_itemname,n_itemrev,p_seqno FROM ",
			bom, "WHERE p_attached = 'Y'");
		status = SQLquery(sql_str, &bufr, 1024);
		if (status != SQL_S_SUCCESS) {
			MEMclose(&bufr);
			if (status == SQL_I_NO_ROWS_FOUND) {
				PDMdebug("EXIT:PDMprocess_attachements\n");
				return (PDM_S_SUCCESS);
			}
			MEMclose(attach_bufr);
			sprintf(s, "Failed to query %s status %d\n", bom, status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
		status = MEMbuild_array(bufr);
		if (status != MEM_S_SUCCESS) {
			MEMclose(attach_bufr);
			MEMclose(&bufr);
			sprintf(s, "MEMbuild_array failed status %d\n", status);
			PDMdebug(s);
			return (PDM_E_BUILD_ARRAY);
		}
		data = (char **) bufr->data_ptr;
		for (i = 0; i < bufr->rows; i++) {
			nxi = i * bufr->columns;
			p_parttype[0] = '\0';
			status = PDMquery_parttype( data[nxi + 0], 
                                                   data[nxi + 1],
                                                   data[nxi + 2], 
                                                   p_parttype);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, 
                                 "PDMquery_parttype failed status %d\n",
					status);
				PDMdebug(s);
			}
			s[0] = '\0';
			sprintf(s, "%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1",
				data[nxi + 0], data[nxi + 1], data[nxi + 2],
				data[nxi + 3], "", p_parttype, "Y");
			status = MEMwrite(*attach_bufr, s);
			if (status != MEM_S_SUCCESS) {
				MEMclose(attach_bufr);
				MEMclose(&bufr);
				sprintf(s, "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				return (PDM_E_WRITE_ROW);
			}
		}
		MEMclose(&bufr);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("attach_bufr with parts from cit+bom",
				*attach_bufr, PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMprocess_attachments\n");
	return (PDM_S_SUCCESS);
}

/*
 * first ....
 * 
 * a call is made to figure out the files that are actually required to be sent.
 * 
 * next ....
 * 
 * all the files in attach_bufr with n_fileco == 'Y' are sent to a destination
 * specified by strg_bufr "n_cofilename" in attach_bufr is updated
 */

int 
PDMsend_files(user_id, attach_bufr, strg_bufr)
	long            user_id;
	MEMptr          attach_bufr;
	MEMptr          strg_bufr;
{
	char          **attach_data;
	char          **strg_data;
	char          **column_ptr;
	char          **data;
	int             i, j, nxi;
	int             n1, n2, n3, n4, n5, n6;
	int             m1;
	MEMptr          attr_list = NULL;
	MEMptr          data_list = NULL;

	PDMdebug("ENTER:PDMsend_files\n");
	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMstop_transaction failed status %d\n", status);
		PDMdebug(s);
	}
	m1 = -1;
	status = MEMbuild_array(attach_bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	column_ptr = (char **) attach_bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	n6 = -1;
	for (i = 0; i < attach_bufr->columns; i++) {
		if (!strcmp(column_ptr[i], "n_catalogname"))
			n1 = i;
		if (!strcmp(column_ptr[i], "n_itemname"))
			n2 = i;
		if (!strcmp(column_ptr[i], "n_itemrev"))
			n3 = i;
		if (!strcmp(column_ptr[i], "n_fileco"))
			n4 = i;
		if (!strcmp(column_ptr[i], "n_cofilename"))
			n5 = i;
		if (!strcmp(column_ptr[i], "p_parttype"))
			n6 = i;
	}
	if (n1 == -1 || n2 == -1 ||
	    n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1) {
		PDMdebug("<attach_bufr> Buffer format is incorrect\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	status = MEMbuild_array(strg_bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	attach_data = (char **) attach_bufr->data_ptr;
	strg_data = (char **) strg_bufr->data_ptr;

	/*
	 * prepare each item for a copy complete each item copy if success
	 * store the file name in attach_bufr
	 */

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMstart_transaction failed status %d\n", status);
		PDMdebug(s);
	}
	for (i = 0; i < attach_bufr->rows; i++) {
		nxi = i * attach_bufr->columns;

		if ((!strcmp(attach_data[nxi + n4], "Y"))
		    && ((strcmp(attach_data[nxi + n6], "N")) && (strcmp(attach_data[nxi + n6], "n")))) {

			status = NFMprepare_item_copy(
						      user_id,
						      attach_data[nxi + n1],
						      attach_data[nxi + n2],
						      attach_data[nxi + n3],
						    &attr_list, &data_list);
			if (status != NFM_S_SUCCESS) {
				sprintf(s, "%s %d \n",

					"NFMprepare_item_copy failed status ", status);
				PDMdebug(s);
				status = PDMrollback_transaction(1200);
				return (PDM_E_PREPARE_ITEM_COPY);
			}
			status = PDMstop_transaction(1200);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "PDMstop_transaction failed status %d\n", status);
				PDMdebug(s);
			}
			status = MEMbuild_array(data_list);
			if (status != MEM_S_SUCCESS) {
				sprintf(s, "MEMbuild_array failed status %d\n", status);
				PDMdebug(s);
				status = PDM_E_BUILD_ARRAY;
				goto cleanup;
			}
			data = (char **) data_list->data_ptr;
			if (m1 == -1) {
				column_ptr = (char **) data_list->column_ptr;
				for (j = 0; j < data_list->columns; j++) {
					if (!strcmp(column_ptr[j], "n_cofilename"))
						m1 = j;
				}
				if (m1 == -1) {
					PDMdebug("Failed to set offset in data_bufr\n");
					return (PDM_E_BUFFER_FORMAT);
				}
			}
			status = PDMstart_transaction(1200);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "PDMstart_transaction failed status %d\n", status);
				PDMdebug(s);
			}
			status = NFMcomplete_item_copy( user_id, 
                                                        strg_data[0],
                                                        strg_data[1], 
                                                        strg_data[2],
                                                        strg_data[3], 
                                                        strg_data[4],
						        attr_list, 
                                                        data_list);
			if (status != NFM_S_SUCCESS) {
				sprintf(s, "%s %d \n",
					"NFMcomplete_item_copy failed status ", status);
				PDMdebug(s);
				status = PDM_E_COMPLETE_ITEM_COPY;
				goto cleanup;
			} else {
				/* store file name in attach_bufr */

				status = MEMbuild_array(data_list);
				if (status != MEM_S_SUCCESS) {
					sprintf(s, "MEMbuild_array failed status %d\n", status);
					PDMdebug(s);
					status = PDM_E_BUILD_ARRAY;
					goto cleanup;
				}
				data = (char **) data_list->data_ptr;
				if (PDMdebug_on) {
					MEMprint_buffer("data_list",
						 data_list, PDM_DEBUG_FILE);
				}
				status = MEMwrite_data(attach_bufr, data[m1],
						       i + 1, n5 + 1);
				if (status != MEM_S_SUCCESS) {
					sprintf(s, "MEMwrite_data failed status %d\n",
						status);
					PDMdebug(s);
					status = PDM_E_WRITE_COLUMN;
					goto cleanup;
				}
				MEMclose(&attr_list);
				attr_list = NULL;
				MEMclose(&data_list);
				data_list = NULL;
			}
		}		/* if n_fileco == 'Y' */
	}
	PDMdebug("EXIT:PDMsend_files\n");
	return (PDM_S_SUCCESS);
cleanup:
	status = NFMcancel_item_copy(user_id, attr_list, data_list);
	if (status != NFM_S_SUCCESS) {
		sprintf(s, "%s %d \n",
			"NFMcancel_item_copy failed ", status);
		PDMdebug(s);
		return (PDM_E_CANCEL_ITEM_COPY);
	}
	status = PDMrollback_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMrollback_transaction failed status %d\n", status);
		PDMdebug(s);
	}
	MEMclose(&attr_list);
	MEMclose(&data_list);
	return (status);
}

