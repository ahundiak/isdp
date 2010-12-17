#include "NFMerrordef.h"
#include <stdio.h>
#include <errno.h>
#include "PDUerror.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "MSGstruct.h"
#include "PDUstorage.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"
#include "PDUnode.h"


#define NFM_TEMP_SIZE1 12

extern int      PDMdebug_on;
extern struct PDUstorage *storage;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;


/*long PDMcopy_macro_library(working_area, copy_bufr)*/
/* Added a third parameter to return the statii of different
   libraries, whether they are copied out or not. MaC 06164 */

long PDMcopy_macro_library(working_area, copy_bufr, status_buffer)
/***

  This function will copy a given set of macro libraries.
All *.e's and *.rle's associated to the macro library are copied to local.
All *.e's are bundled together as a cpio file. All *.rle's are bundled
together as a cpio file. These cpio files are treated as multiple files
per part. As soon as these files are brought to local, they will be
unbundled. It's not a rule that they have to be a cpio file. If the file_type
of the macro is other than "CPIO" then those files won't be unbundled.

    6/24/92 - Kumar
***/
	char           *working_area;
	MEMptr          copy_bufr;
	MEMptr          *status_buffer;

{
	char           *fname = "PDMcopy_macro_library";
	char            sql_str[1024];
	char            row_str[3048], line[200];
	char            dumb_str[1];
	char          **data, **file_data, **file_data1;
	char		 **copy_data, **temp_data, **column_ptr;
	char          **file_column;
	char            filename[NFM_COFILENAME + 1];
	char            nodename[NFM_NODENAME + 1], username[NFM_USERNAME + 1];
	char            passwd[NFM_PASSWD + 1], pathname[NFM_PATHNAME + 1];
	char            devicetype[NFM_DEVICETYPE + 1], machid[NFM_MACHID + 1];
	char            opsys[NFM_OPSYS + 1], tcpip[NFM_TCPIP + 1];
	char            xns[NFM_XNS + 1], decnet[NFM_DECNET + 1];
	char            netware[NFM_NETWARE + 1];
	char            plattername[NFM_PLATTERNAME + 1];
	char            partition[NFM_PARTITION + 1], nfs[NFM_NFS + 1];
	char            compress[NFM_COMPRESS + 1];
	int             x, y, z, nxi, yi;
	int             n1, n2, n3, n4, n5, n6, xi, i;
	int             index, catno;
	int             i_catno, i_itemnum, i_type, i_fileno, i_filenum;
	int             i_fileversion, i_filetype, i_fileco, i_cifilename;
	int             i_cofilename, i_cisano, i_status1;
	long            sano = 0, sto_no;
	long            status, dumb_value = 0, fmgr_status = 0;
	MEMptr          success_bufr = NULL, failure_bufr = NULL;
	MEMptr          file_list = NULL, files_info = NULL;
	MEMptr          temp_list = NULL, list = NULL, fmgr_bufr = NULL;
	struct NFMsto_info *sto_list = NULL;
	struct NFMbuf_format *format;
/* added for support libraries support MaC */
	int             MacIndex, AssyIndex, M, Added, partno_sav;
	MEMptr          AssyBufr = NULL;
	char            **AssyData;
	char            **MacData;
	char            setindicator[3], parttype[3];
	char            mem_str[512];
	char            cofilename[40];

	temp_list = (MEMptr) NULL;
	list = (MEMptr) NULL;
	_PDMdebug(fname, 
            "ENTER: PDMcopy_macro_lib working_area[%s] \n", working_area);

	status = PDMload_partno_filename(copy_bufr);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
		return (status);
	}
	status = MEMopen(&success_bufr, 512);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&copy_bufr);
		status = PDM_E_BUILD_ARRAY;
		_PDMdebug(fname, "MEM Open : status = <0x%.8x>\n", status);
		return (status);
	}
	status = MEMwrite_format(success_bufr, "n_cofilename", "char(128)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(success_bufr, "n_filetype", "char(20)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(success_bufr, "n_status", "char(20)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
		status = PDM_E_BUILD_ARRAY;
		_PDMdebug(fname, "MEM Wr Format : status = <0x%.8x>\n", status);
		return (status);
	}
	status = MEMopen(&failure_bufr, 512);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
		status = PDM_E_BUILD_ARRAY;
		_PDMdebug(fname, "MEM Open : status = <0x%.8x>\n", status);
		return (status);
	}
	status = MEMwrite_format(failure_bufr, "n_cofilename", "char(128)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(success_bufr, "n_filetype", "char(20)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(failure_bufr, "n_status", "char(20)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
		MEMclose(&failure_bufr);
		status = PDM_E_BUILD_ARRAY;
		_PDMdebug(fname, "MEM Wr Format : status = <0x%.8x>\n", status);
		return (status);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("copy_bufr", copy_bufr, PDM_DEBUG_FILE);
	}

	status = MEMbuild_array(copy_bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
		return (status);
	}
	copy_data = (char **) copy_bufr->data_ptr;
/**************************************************************************
     Adding fix for support libraries MaC
*************************************************************************/

     partno_sav = PDMpart.n_itemno;
     /* Get the assy struct for this part */

      status =  PDMquery_assyind_parttype ( copy_data[2],
                                            copy_data[3],
                                            copy_data[4],
                                            setindicator,
                                            parttype);
        if(status != PDM_S_SUCCESS) {
              _PDMdebug (fname, "PDMquery_assyind_parttype:failed: 0x%.8x\n", 
                                                               status);
              setindicator[0] = '\0';
              strcpy (setindicator, "Y");
              }

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
       if (!strcmp (setindicator, "Y") || !strcmp (setindicator, "y"))
*/
       if (!strcmp (setindicator, "Y") || !strcmp (setindicator, "y") ||
           !strcmp (setindicator, "A") || !strcmp (setindicator, "a")) {
       /* This function needs to access PDMpart structure:
          we have stored the value in this member. we now load
          value of this itemno into this */

        PDMpart.n_itemno = atol (copy_data[1]);

        AssyBufr = NULL;
        status = PDMquery_ass_struc ( copy_data[2],
                                       copy_data[3],
                                       copy_data[4],
                                       50,
                                       setindicator,
                                       0,
                                       &AssyBufr);
        if( (status != PDM_S_SUCCESS ) &&
              (status != PDM_E_PART_NOT_ASSEMBLY)) {
           _PDMdebug(fname,"PDMquery_ass_struc failed status %d\n", status);
           PDMrollback_transaction (1200);
           return(PDM_E_QUERY_SET_MEMBERS);
          }

	if (PDMdebug_on) 
             MEMprint_buffer ("AssyBufr", AssyBufr, PDM_DEBUG_FILE);


      status = MEMbuild_array(copy_bufr);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      MacData = (char **) copy_bufr->data_ptr;

      status = MEMbuild_array (AssyBufr);
      if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      AssyData = (char **) AssyBufr->data_ptr;

      for (y = 1; y < AssyBufr->rows; y++) {
       AssyIndex = y * AssyBufr->columns;
       _PDMdebug ("Checking Library", "%s\1%s\1%s\1%s\1%s\1",
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4]);
       Added = 0;
       for (M = 0; M < copy_bufr->rows; M++) {
	 MacIndex = M * copy_bufr->columns;
        if ((atol (MacData[MacIndex + 3]) == atol (AssyData[AssyIndex + 3])) &&
           (atol (MacData[MacIndex + 4]) == atol (AssyData[AssyIndex + 4]) ) ){
           _PDMdebug (fname, "cat[%s]:item[%s] already added \n",
                              AssyData[AssyIndex + 10],
                                AssyData[AssyIndex + 11]);
            Added = 1;
            break;
            }

         }
        if (Added != 1) {
        status = PDMi_find_cofilename( AssyData[AssyIndex + 10],
                                        AssyData[AssyIndex + 11],
                                        AssyData[AssyIndex + 12], 
                                        cofilename);

           sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1N\1",
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4],
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                                        cofilename);

           _PDMdebug (fname, "mem_str[%s]\n", mem_str);
           status = MEMwrite(copy_bufr, mem_str);
           if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite Failed 0x%.8x\n", status);
                /*return (status);*/
		}

           status = MEMbuild_array(copy_bufr);
           if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

           MacData = (char **) copy_bufr->data_ptr;
         }
        }
       MEMclose (&AssyBufr);
      }
 
  PDMpart.n_itemno = partno_sav;
  if (PDMdebug_on) 
             MEMprint_buffer ("Copy_bufr after adding children libs", 
                                       copy_bufr, PDM_DEBUG_FILE);



/*************************************************************************/
	status = MEMbuild_array(copy_bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
		return (status);
	}
	copy_data = (char **) copy_bufr->data_ptr;
	column_ptr = (char **) copy_bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	n6 = -1;

	for (i = 0; i < copy_bufr->columns; i++) {
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
	}
	if (n1 == -1 || n2 == -1 ||
	    n3 == -1 || n4 == -1 ||
	    n5 == -1 || n6 == -1) {
		_PDMdebug(fname, " %s %s \n",
		       "PDMcopy_macro_library : ", "Failed to set offsets");
		return (PDM_E_BUFFER_FORMAT);
	}
	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "PDMstop_transaction: 0x%.8x\n", status);
		return (status);
	}
	/* get storage area information */

	status = NFMget_storage_info(working_area, &sano, nodename, username, passwd,
			       pathname, devicetype, plattername, partition,
				     nfs, compress, machid, opsys, tcpip,
				     xns, decnet, netware);
	if (status != NFM_S_SUCCESS) {
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
			  status);
		return (status);
	}
	status = MEMopen(&files_info, MEM_SIZE);
	if (status != MEM_S_SUCCESS) {
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}
	/*
	 * status = MEMopen (&files_info1, MEM_SIZE); if (status !=
	 * MEM_S_SUCCESS) { MEMclose (&files_info); PDMrollback_transaction
	 * (1200); _PDMdebug (fname, "MEMopen 0x%.8x\n", status); return
	 * (status); }
	 */

	format = (struct NFMbuf_format *) calloc(NFM_TEMP_SIZE1,
			     NFM_TEMP_SIZE1 * sizeof(struct NFMbuf_format));

	if (!format) {
		MEMclose(&files_info);
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}
	strcpy((format + 0)->attr_name, "n_catno");
	strcpy((format + 0)->data_type, "integer");
	strcpy((format + 1)->attr_name, "n_itemnum");
	strcpy((format + 1)->data_type, "integer");
	strcpy((format + 2)->attr_name, "n_type");
	strcpy((format + 2)->data_type, "char(1)");
	strcpy((format + 3)->attr_name, "n_fileno");
	strcpy((format + 3)->data_type, "integer");
	strcpy((format + 4)->attr_name, "n_filenum");
	strcpy((format + 4)->data_type, "integer");
	strcpy((format + 5)->attr_name, "n_fileversion");
	strcpy((format + 5)->data_type, "integer");
	strcpy((format + 6)->attr_name, "n_filetype");
	strcpy((format + 6)->data_type, "char(5)");
	strcpy((format + 7)->attr_name, "n_fileco");
	strcpy((format + 7)->data_type, "char(1)");
	strcpy((format + 8)->attr_name, "n_cisano");
	strcpy((format + 8)->data_type, "integer");
	strcpy((format + 9)->attr_name, "n_cifilename");
	strcpy((format + 9)->data_type, "char(14)");
	strcpy((format + 10)->attr_name, "n_cofilename");
	strcpy((format + 10)->data_type, "char(14)");
	strcpy((format + 11)->attr_name, "n_status1");
	strcpy((format + 11)->data_type, "char(2)");

	status = _NFMbuild_working_buffer_format
		(format, NFM_TEMP_SIZE1, files_info);
	if (status != NFM_S_SUCCESS) {
		MEMclose(&files_info);
		PDMrollback_transaction(1200);
		free(format);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}
	status = PDMcreate_fmgr_bufr(&fmgr_bufr);
	if (status != NFM_S_SUCCESS) {
		MEMclose(&files_info);
		MEMclose(&fmgr_bufr);
		PDMrollback_transaction(1200);
		free(format);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}
	free(format);

	i_catno = 0;
	i_itemnum = 1;
	i_type = 2;
	i_fileno = 3;
	i_filenum = 4;
	i_fileversion = 5;
	i_filetype = 6;
	i_fileco = 7;
	i_cisano = 8;
	i_cifilename = 9;
	i_cofilename = 10;
	i_status1 = 11;

	catno = 0;

	for (x = 0; x < copy_bufr->rows; x++) {
		xi = x * copy_bufr->columns;

		/* prepare buffer for file transfer */

		status = PDMris_get_catno(copy_data[xi + n3], &catno);
		if (status != SQL_S_SUCCESS) {
			if (status == SQL_I_NO_ROWS_FOUND)
				continue;
			else
				return (PDM_E_SQL_STMT);

		}
		_PDMdebug(fname, "prepare to retrieve the information from %s f_<%s>\n", copy_data[xi + n3], copy_data[xi + n3]);
		sprintf(sql_str, "%s %s %s, f_%s %s '%s' %s '%s' %s '%s' %s %s %s f_%s %s %s %s",
			"select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
			"n_cisano, n_cifilename, n_cofilename,n_itemno from",
			copy_data[xi + n3], copy_data[xi + n3],
			"where n_itemname =",
			copy_data[xi + n4],
			"and n_itemrev =",
			copy_data[xi + n5],
			"and n_cofilename =",
			copy_data[xi + n6],
			"and n_fileversion != 0",
			"and n_fileversion =",
			"(select max(n_fileversion) from ",
			copy_data[xi + n3],
			"where n_itemnum =",
			copy_data[xi + n2], ")");

		status = NFMretrieve_values(sql_str, NFM_RETURN_MEMPTR, dumb_str,
					    dumb_value, &list);
		if (status != NFM_S_SUCCESS) {
			_PDMdebug(fname, "Part %s %s of of catalog not found\n", copy_data[xi + n4], copy_data[xi + n5], copy_data[xi + n3]);
			MEMclose(&list);
			row_str[0] = '\0';
			sprintf(row_str, "%s\1%d\1", copy_data[xi + n6], PDM_E_PART_NOT_CHECKEDIN);
			status = MEMwrite(failure_bufr, row_str);
			if (status != MEM_S_SUCCESS)
				_PDMdebug(fname, "MEMwrite failed status %s\n", status);
			continue;
		}
		if (PDMdebug_on)
			MEMprint_buffer("list", list, PDM_DEBUG_FILE);
		status = MEMbuild_array(list);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMbuild_array failed status %s\n", status);
			return (status);
		}
		file_data = (char **) list->data_ptr;

		for (y = 0; y < list->rows; y++) {

			yi = y * list->columns;

			fmgr_status = PDM_I_FILE_MOVE;

			fmgr_status = PDMcheck_fmgr_attach(sano, file_data[yi + 7], catno, atoi(file_data[yi + 8]), atoi(file_data[1]), atoi(file_data[2]));
			_PDMdebug(fname, "FMGR status %d\n", status);
			if (fmgr_status == PDM_I_FILE_MOVE) {
				/* MEMwrite on to fmgr_bufr */
				sql_str[0] = '\0';
				sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "MOVE");
				status = MEMwrite(fmgr_bufr, sql_str);
				if (status != MEM_S_SUCCESS) {
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					MEMclose(&list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
					return (status);
				}
			} else if (fmgr_status == PDM_I_REF_UPDATE) {
				/* MEMwrite on to fmgr_bufr */
				sql_str[0] = '\0';
				sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "REF_UPDATE");
				/*
				 * 
				 * sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\
				 * 1", copy_data[xi+n1],
				 * copy_data[xi+n2],file_data[1],file_data[2],
				 * file_data[5],copy_data[xi+n6],
				 * "REF_UPDATE");
				 */
				status = MEMwrite(fmgr_bufr, sql_str);
				if (status != MEM_S_SUCCESS) {
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					MEMclose(&list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
					return (status);
				}
				continue;
			} else if (fmgr_status == PDM_I_CHECK_OUT) {
				/* MEMwrite on to fmgr_bufr */
				sql_str[0] = '\0';
				sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "CHECKOUT");
				/*
				 * 
				 * sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\
				 * 1", copy_data[xi+n1],
				 * copy_data[xi+n2],file_data[1],file_data[2],
				 * file_data[5],copy_data[xi+n6],
				 * "CHECKOUT");
				 */
				status = MEMwrite(fmgr_bufr, sql_str);
				if (status != MEM_S_SUCCESS) {
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					MEMclose(&list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
					return (status);
				}
				continue;
			} else if (fmgr_status == PDM_I_VERSION_UPDATE) {
				/* MEMwrite on to fmgr_bufr */
				sql_str[0] = '\0';
				sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "VERSION_UPDATE");
				/*
				 * 
				 * sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\
				 * 1", copy_data[xi+n1],
				 * copy_data[xi+n2],file_data[1],file_data[2],
				 * file_data[5],copy_data[xi+n6],
				 * "VERSION_UPDATE");
				 */
				status = MEMwrite(fmgr_bufr, sql_str);
				if (status != MEM_S_SUCCESS) {
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					MEMclose(&list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
					return (status);
				}
			}
		}
		_PDMdebug(fname,
		"write the files information of this item to files_info\n");
		if ((fmgr_status == PDM_I_VERSION_UPDATE) || (fmgr_status == PDM_I_FILE_MOVE)) {
			for (y = 0; y < list->rows; y++) {
				index = list->columns * y;
				sprintf(row_str, "%s\1%s\1%s\1",
				copy_data[xi + n1], copy_data[xi + n2], "S");
				for (z = 0; z < (list->columns - 1); z++) {
					strcat(row_str, file_data[index + z]);
					strcat(row_str, "\1");
				}
				strcat(row_str, "\1");
				_PDMdebug(fname, "row_str %s\n", row_str);
				status = MEMwrite(files_info, row_str);
				if (status != MEM_S_SUCCESS) {
					_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					PDMrollback_transaction(1200);
					return (status);
				}
			}
		}
		status = MEMclose(&list);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMclose 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		list = (MEMptr) NULL;
	}

        if(files_info != NULL)
        {
	if (files_info->rows > 0) {
		status = MEMbuild_array(files_info);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		if (PDMdebug_on)
			MEMprint_buffer("files_info", files_info, PDM_DEBUG_FILE);
		status = NFMbuild_fto_buffer(&file_list, 0);
		if (status != NFM_S_SUCCESS) {
			_PDMdebug(fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		sprintf(row_str,
			"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
			sano,
			nodename, username, passwd, pathname, devicetype, plattername, partition,
		  nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
			"\1\1\1\1\1\1\1\1\1");

		_PDMdebug(fname, "MEMwrite %s\n", row_str);

		status = MEMwrite(file_list, row_str);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
			return (status);
		}
		sto_list = (struct NFMsto_info *) calloc(files_info->rows,
		       (files_info->rows + 1) * sizeof(struct NFMsto_info));

		if (!sto_list) {
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			_PDMdebug(fname, "calloc sto_list failed\n");
			return (NFM_E_MALLOC);
		}
		sto_list->sano = sano;
		strcpy(sto_list->nodename, nodename);
		strcpy(sto_list->username, username);
		strcpy(sto_list->passwd, passwd);
		strcpy(sto_list->pathname, pathname);
		strcpy(sto_list->devicetype, devicetype);
		strcpy(sto_list->plattername, plattername);
		strcpy(sto_list->partition, partition);
		strcpy(sto_list->nfs, nfs);
		strcpy(sto_list->compress, compress);
		strcpy(sto_list->machid, machid);
		strcpy(sto_list->opsys, opsys);
		strcpy(sto_list->tcpip, tcpip);
		strcpy(sto_list->xns, xns);
		strcpy(sto_list->decnet, decnet);
		strcpy(sto_list->netware, netware);

		data = (char **) files_info->data_ptr;

		for (x = 0, sto_no = 1; x < files_info->rows; x++) {
			index = files_info->columns * x;
			_PDMdebug(fname, "data[index+i_cisano] = %s\n",
				  data[index + i_cisano]);

			/* check to see if the cisano already on the list */

			for (y = 0; y < sto_no; y++) {
				_PDMdebug(fname, "(sto_list+%d)->sano: %d\n", y,
					  (sto_list + y)->sano);
				if ((sto_list + y)->sano == atol(data[index + i_cisano])) {
					_PDMdebug(fname, "storage_area_no found in sto_list \n");
					break;
				}
			}
			if (y >= sto_no) {
				_PDMdebug(fname, "n_cisano not found in the list, add to it \n");
				_PDMdebug(fname, "n_cisano %s add  \n", data[index + i_cisano]);
				(sto_list + sto_no)->sano = atol(data[index + i_cisano]);
				sto_no++;
			}
		}


		/*
		 * at this point, I have a list of storage nos, so retrieve
		 * all the information from nfmstoragearea and nfmnodes
		 * table.
		 */

		status = NFMget_storages_information(sto_list + 1, sto_no - 1, 1);
		if (status != NFM_S_SUCCESS) {
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
			_PDMdebug(fname, "NFMget_storages_information 0x%.8x\n", status);
			return (status);
		}
		_PDMdebug(fname, "prepare file transfer buffer\n");
		for (x = 0; x < files_info->rows; x++) {
			index = files_info->columns * x;
			sql_str[0] = '\0';
			sprintf(sql_str,
				"%s %s %d %s '%s' %s %s %s %s %s %s ",
				"select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
			"n_fileversion from nfmsafiles where n_sano =", sano,
				"and n_filename =",
			    data[index + i_cofilename], "and n_catalogno =",
				data[index + i_catno], "and n_itemno =", data[index + i_itemnum],
				"and n_filenum =", data[index + i_filenum]);

			status = SQLquery(sql_str, &temp_list, MEM_SIZE);
			if (status == SQL_S_SUCCESS) {
				status = MEMbuild_array(temp_list);
				if (status != MEM_S_SUCCESS) {
					_NFMfree_linked_lists(sto_list, NULL);
					MEMclose(&files_info);
					MEMclose(&fmgr_bufr);
					MEMclose(&file_list);
					MEMclose(&temp_list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "MEMbuild_array 0x%.8x\n", status);
					return (status);
				}
				temp_data = (char **) temp_list->data_ptr;
			} else if (status == SQL_I_NO_ROWS_FOUND) {
				/* add to the table */
			} else {
				_NFMfree_linked_lists(sto_list, NULL);
				MEMclose(&files_info);
				MEMclose(&fmgr_bufr);
				MEMclose(&file_list);
				PDMrollback_transaction(1200);
				_PDMdebug(fname, "SQLquery 0x%.8x\n", status);
				return (status);
			}
			_PDMdebug(fname, "Try to find cisano [%s] in sto_list\n",
				  data[index + i_cisano]);
			_PDMdebug(fname, "sto_no [%d] \n", sto_no);
			row_str[0] = '\0';
			for (y = 0; y < sto_no; y++) {
				_PDMdebug(fname, "(sto_list+%d)->sano = %d\n",
					  y, (sto_list + y)->sano);
				if ((sto_list + y)->sano == atol(data[index + i_cisano])) {
					_PDMdebug(fname, "found match in sto_list\n");
					_PDMdebug(fname, "%d\n", (sto_list + y)->sano);
					_PDMdebug(fname, "%s\n", (sto_list + y)->nodename);
					_PDMdebug(fname, "%s\n", (sto_list + y)->username);
					_PDMdebug(fname, "%s\n", (sto_list + y)->passwd);
					_PDMdebug(fname, "%s\n", (sto_list + y)->pathname);
					_PDMdebug(fname, "%s\n", (sto_list + y)->devicetype);
					_PDMdebug(fname, "%s\n", (sto_list + y)->plattername);
					_PDMdebug(fname, "%s\n", (sto_list + y)->partition);
					_PDMdebug(fname, "%s\n", (sto_list + y)->nfs);
					_PDMdebug(fname, "%s\n", (sto_list + y)->compress);
					_PDMdebug(fname, "%s\n", (sto_list + y)->machid);
					_PDMdebug(fname, "%s\n", (sto_list + y)->opsys);
					_PDMdebug(fname, "%s\n", (sto_list + y)->tcpip);
					_PDMdebug(fname, "%s\n", (sto_list + y)->xns);
					_PDMdebug(fname, "%s\n", (sto_list + y)->decnet);
					_PDMdebug(fname, "%s\n", (sto_list + y)->netware);
					sprintf(row_str,
						"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
						(sto_list + y)->sano,
						(sto_list + y)->nodename, (sto_list + y)->username, (sto_list + y)->passwd,
						(sto_list + y)->pathname, (sto_list + y)->devicetype,
						(sto_list + y)->plattername,
						(sto_list + y)->partition, (sto_list + y)->nfs,
						(sto_list + y)->compress, (sto_list + y)->machid, (sto_list + y)->opsys,
						(sto_list + y)->tcpip, (sto_list + y)->xns, (sto_list + y)->decnet,
						(sto_list + y)->netware);
					_PDMdebug(fname, "Row_str %s\n", row_str);
					break;
				}
			}
			if (y >= sto_no) {
				_PDMdebug(fname, "check-in-to storage area incorrect\n");
				_NFMfree_linked_lists(sto_list, NULL);
				MEMclose(&files_info);
				MEMclose(&fmgr_bufr);
				MEMclose(&file_list);
				MEMclose(&temp_list);
				PDMrollback_transaction(1200);
				return (status);
			}
			if (strlen(data[index + i_fileno])) {
				strcat(row_str, data[index + i_fileno]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			strcat(row_str, "\1");	/* n_fileold */
			if (strlen(data[index + i_cifilename])) {
				strcat(row_str, data[index + i_cifilename]);
				strcat(row_str, "\1");
			} else {
				status = NFMnew_file_name(0, atol(data[index + i_catno]),
				    atol(data[index + i_fileno]), filename);
				if (status != NFM_S_SUCCESS) {
					_NFMfree_linked_lists(sto_list, NULL);
					MEMclose(&files_info);
					MEMclose(&file_list);
					MEMclose(&fmgr_bufr);
					MEMclose(&temp_list);
					PDMrollback_transaction(1200);
					_PDMdebug(fname, "NFMget_file_name 0x%.8x\n", status);
					return (status);
				}
				strcat(row_str, filename);
				strcat(row_str, "\1");
			}
			if (strlen(data[index + i_cofilename])) {
				strcat(row_str, data[index + i_cofilename]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			if (strlen(data[index + i_filetype])) {
				strcat(row_str, data[index + i_filetype]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			/*
			 * if (strlen (data[index+i_cifilesize])) strcat
			 * (row_str, data[index+i_cifilesize]);  else
			 */
			strcat(row_str, "100\1");
			strcat(row_str, "2033\1\1\1");

			_PDMdebug(fname, "row_str %s\n", row_str);
			status = MEMwrite(file_list, row_str);
			if (status != MEM_S_SUCCESS) {
				_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
				_NFMfree_linked_lists(sto_list, NULL);
				MEMclose(&files_info);
				MEMclose(&fmgr_bufr);
				MEMclose(&file_list);
				PDMrollback_transaction(1200);
				return (status);
			}
		}		/* prepare file transfer buffer */
		if (PDMdebug_on) {
			MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
			MEMprint_buffer("fmgr_bufr", fmgr_bufr, PDM_DEBUG_FILE);
		}
		status = _NFMfs_recv_files(&file_list);
		if (status != NFM_S_SUCCESS) {
			_PDMdebug(fname, "_NFMfs_recv_files 0x%.8x\n", status);
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			_NFMfs_undo_recv_files(&file_list);
			MEMclose(&file_list);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
	   }
		else _PDMdebug(fname, "No files to move\n");
        }
	 /* if there is any information in files_info */ 
	else {
		_PDMdebug(fname, "No files to move\n");
	}

	if (fmgr_bufr != NULL ) {
	if (fmgr_bufr->rows > 0) {
		status = PDMupdate_fmgr_copy(sano, fmgr_bufr);
		if (status != PDM_S_SUCCESS) {
			_PDMdebug(fname, "PDMupdate_fmgr_copy 0x%.8x\n", status);
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			_NFMfs_undo_recv_files(&file_list);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
			return (status);
		}
	}
       }
	if (PDMdebug_on)
		MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);

	if (file_list != NULL) {
		status = MEMbuild_array(file_list);
		if (status == MEM_S_SUCCESS) {
			file_data1 = (char **) file_list->data_ptr;
			file_column = (char **) file_list->column_ptr;

			for (i = 0; i < file_list->columns; i++) {
				if (!strcmp(file_column[i], "n_cofilename"))
					n1 = i;
				else if (!strcmp(file_column[i], "n_status1"))
					n2 = i;
				else if (!strcmp(file_column[i], "n_filetype"))
					n3 = i;
			}

			for (i = 1; i < file_list->rows; i++) {
				nxi = i * file_list->columns;
				row_str[0] = '\0';
				if (atoi(file_data1[nxi + n2]) == 2035) {
					PDMconvert_to_lower(file_data1[nxi + n3], file_data1[nxi + n3]);
					if (!strcmp(file_data1[nxi + n3], "CPIO")) {
						sprintf(line, "cpio -it < %s/%s > %s/.%s", storage->path_name, file_data1[nxi + n1], storage->path_name, file_data1[nxi + n1]);
						_PDMdebug(fname, "cpio command <%s> \n", line);
						status = NFMsystem(line);
						if (status != NFM_S_SUCCESS) {
							_PDMdebug(fname, "cpio command <%s> \n", line);
							_PDMdebug(fname, "cpio listing failed for  <%s> : errno < %d>\n", file_data1[nxi + n1], errno);
						}
						sprintf(line, "cpio -ivumd < %s/%s", storage->path_name, file_data1[nxi + n1]);
						_PDMdebug(fname, "cpio command <%s> \n", line);
						status = NFMsystem(line);
						if (status != NFM_S_SUCCESS) {
							_PDMdebug(fname, "cpio failed for  <%s> : errno < %d>\n", file_data1[nxi + n1], errno);
							sprintf(row_str, "%s\1%d\1", file_data1[nxi + n1], PDM_E_MOVE_FILE);
							MEMwrite(failure_bufr, row_str);
						}
					}
					sprintf(row_str, "%s\1%d\1", file_data1[nxi + n1], PDM_S_SUCCESS);
					MEMwrite(success_bufr, row_str);
				} else {
					sprintf(row_str, "%s\1%d\1", file_data1[nxi + n1], PDM_E_MOVE_FILE);
					MEMwrite(failure_bufr, row_str);
				}
			}
		}
	}
	status = _NFMfree_linked_lists(sto_list, NULL);
	if (status != NFM_S_SUCCESS)
		_PDMdebug(fname, "_NFMfree_linked_lists 0x%.8x\n", status);
	if (fmgr_bufr != NULL && fmgr_bufr->rows > 0 && fmgr_bufr->rows < 10000)
		status = MEMclose(&fmgr_bufr);
	if (status != MEM_S_SUCCESS)
		_PDMdebug(fname, "MEMclose 0x%.8x\n", status);

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS)
		_PDMdebug(fname, "PDMstart_transaction 0x%.8x\n", status);
       /* Added to return statii. MaC 060994 */
     
      if (failure_bufr && PDMdebug_on) 
         MEMprint_buffer("failure_bufr", failure_bufr, PDM_DEBUG_FILE);
       
       *status_buffer = failure_bufr;

	_PDMdebug(fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS);
	return (PDM_S_SUCCESS);
}

/*
 * This function is written to support detach parametric parts. Detach
 * parametric parts means deleting the macro library belonging to the
 * parametric catalog. INPUT:
 * 
 * (a).   parametric catalog in which the part to be detached belongs This needs
 * to be the last occurence of that parametric family. (b).   para_cats
 * containing the list of unique parametric catalog information of the active
 * assembly OUTPUT
 * 
 * (c).   file_bufr buffer containing the file information to be deleted - Kumar
 * 4.3.93
 */

int PDMdetach_macro_library(
			char *macro_cat,
			struct PDUcat_node * para_cats1,
			MEMptr *delete_list
                           )
{
	char            **macro_data, **data = NULL, **sa_data = NULL;
	char            sql_str[1024], mem_str[100];
	int             ref_count = 0;
	int             n_itemno = 0, n_catalogno = 0;
	MEMptr          sa_bufr = NULL;
	MEMptr          macro_bufr = NULL;
	MEMptr          bufr = NULL;
	struct PDUcat_node *para_cats;
	char           *fname = "PDMdetach_macro_library";
        long           status = PDM_S_SUCCESS;

	_PDMdebug(fname, "ENTER: macro_cat[%s]\n", macro_cat);

    status = MEMopen (delete_list, 512);
    if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : failed\n");
         return (NFM_E_MEM);
       }

    status = MEMwrite_format (*delete_list, "n_cofilename", "char(128)");
    if (status != MEM_S_SUCCESS)
          {
            _PDMdebug (fname,"MEM Wr For : failed status \n");
            return (NFM_E_MEM);
          }
   
    sprintf(sql_str, "SELECT %s FROM %s WHERE %s '%s'",
          " p_macrocat, p_macropartno, p_macrorev ", " pdmparamloc ",
          " n_catalogname = ", macro_cat);

    _PDMdebug ("sql_str", "%s\n", sql_str);

    status = SQLquery(sql_str, &macro_bufr, 512);
    if (status != SQL_S_SUCCESS) {
    	MEMclose(&macro_bufr);
    	_PDMdebug(fname, "SQLquery failed status %d\n", status);
    	return (PDM_E_MACRO_NOT_FOUND);
	}

    status = MEMbuild_array(macro_bufr);
    if (status != MEM_S_SUCCESS) {
    	MEMclose(&macro_bufr);
    	_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
    	return (status);
	}

      if (PDMdebug_on) 
                  MEMprint_buffer ("macro_bufr", macro_bufr, PDM_DEBUG_FILE);


  macro_data = (char **) macro_bufr->data_ptr;
  para_cats = para_cats1;

  if (para_cats != NULL) {
   for (; para_cats != NULL; para_cats = para_cats->next) {
      _PDMdebug(fname, 
         "linked list %x and next <%x>\n", para_cats, para_cats->next);
      _PDMdebug(fname, 
         "Checking the macro lib for <%s>\n", para_cats->catalog);
      sql_str[0] = '\0';
      mem_str[0] = '\0';
      sprintf(sql_str, "SELECT %s FROM %s WHERE %s '%s' ",
       " p_macrocat, p_macropartno, p_macrorev ",
       " pdmparamloc ",
       " n_catalogname = ", para_cats->catalog);

      status = SQLquery(sql_str, &bufr, 512);
      if (status != SQL_S_SUCCESS) {
      	MEMclose(&bufr);
      	if (status == SQL_I_NO_ROWS_FOUND)
      		continue;
      	_PDMdebug(fname, "SQLquery failed status %d\n", status);
      	return (status);
      }

      status = MEMbuild_array(bufr);
      if (status != MEM_S_SUCCESS) {
      	MEMclose(&bufr);
        	_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
      	return (status);
      }

      if (PDMdebug_on) 
                  MEMprint_buffer ("bufr", bufr, PDM_DEBUG_FILE);

      data = (char **) bufr->data_ptr;

/* Why is this needed?
    */
      if (!strcmp(macro_data[0], data[0]) &&
          !strcmp(macro_data[1], data[1]) &&
          !strcmp(macro_data[2], data[2])) {
      	MEMclose(&bufr);
      	MEMclose(&macro_bufr);
      	_PDMdebug("MACRO LIBRARY IS NESTED", 
            "<%s> <%s> <%s> nested in <%s> <%s> <%s>\n", 
            macro_data[0], macro_data[1], macro_data[2], 
            data[0], data[1], data[2]);
      	return (PDM_S_SUCCESS);
      }
      MEMclose(&bufr);
   }
  }

  status = PDMquery_catalog_partnos (macro_data[0], 
                                       macro_data[1], 
                                       macro_data[2], 
                                       &n_catalogno, 
                                       &n_itemno);
  if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
	MEMclose(&macro_bufr);
	return (PDM_E_LIBRARY_NOT_FOUND);
     }
  sql_str[0] = '\0';
  sprintf(sql_str, "%s %s %d %s %d %s %d ",
      " select n_co, n_copy, n_fileversion, n_ref, n_filename, n_filenum ",
      " from nfmsafiles where n_sano = ", storage->storage_no,
      " and n_catalogno = ", n_catalogno,
      " and n_itemno = ", n_itemno);

   status = SQLquery(sql_str, &sa_bufr, 512);
   if (status != SQL_S_SUCCESS) {
	MEMclose(&sa_bufr);
	MEMclose(&macro_bufr);
	if (status == SQL_I_NO_ROWS_FOUND) {
	  /* report that the files to be moved */
	  _PDMdebug("", "No filemgr update is needed for this item\n");
	  return (PDM_S_SUCCESS);
	} 
        else {
	  _PDMdebug(fname, "SQLquery failed   0x%.8x\n", status);
	  return (PDM_E_SQL_QUERY);
	}
     }
    status = MEMbuild_array(sa_bufr);
    if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEM error  0x%.8x\n", status);
	MEMclose(&sa_bufr);
	MEMclose(&bufr);
	return (status);
    }
    sa_data = (char **) sa_bufr->data_ptr;
    if (PDMdebug_on)
	_PDMdebug(fname, "n_co %s, n_copy %s n_ref %s n_filename %s \n", sa_data[0], sa_data[1], sa_data[3], sa_data[4]);

    if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
        && (!strcmp(sa_data[1], "Y") || !strcmp(sa_data[1], "y"))
        && (!strcmp(sa_data[3], "")))
    {
    /* fmgr-case 2 */
    /* Checked out and  copied  - DO_NOTHING */
    _PDMdebug("case 2 DO NOTHING", "for <%s>  \n", sa_data[4]);
    MEMclose(&macro_bufr);
    MEMclose(&sa_bufr);
    return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
	       && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	   && (!strcmp(sa_data[3], "")))
    {
    /* fmgr-case 1 */
    /* Just Checked out  - DO_NOTHING */
    _PDMdebug("case 1 DO NOTHING", "for <%s>  \n", sa_data[4]);
    MEMclose(&macro_bufr);
    MEMclose(&sa_bufr);
    return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
	       && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	       && (atoi(sa_data[3]) > 0)) {
	/* fmgr-case 3 */
	/* Checked out and   referenced  - UPDATE_REF */
	ref_count = atoi(sa_data[3]);
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 3 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N"))
	   && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	   && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-7 */
	/* Just  referenced - UPDATE_CO */
	if (atoi(sa_data[3]) == 1) {

		sprintf(sql_str, "DELETE FROM  NFMSAFILES  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
			return (status);
		}
		_PDMdebug("case 7 DELETE  ", "file <%s>  \n", sa_data[4]);
		mem_str[0] = '\0';
		sprintf(mem_str, "%s\1", sa_data[4]);
		status = MEMwrite(*delete_list, mem_str);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "MEM Wr For : status = <0x%.8x>\n", status);
			return (NFM_E_MEM);
		}
	} else {
		ref_count = atoi(sa_data[3]);
		if (ref_count != 0)
			ref_count = ref_count - 1;
		sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
		_PDMdebug("case 7 UPDATE REF ", "for <%s>  \n", sa_data[4]);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
			return (status);
		}
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		return (PDM_S_SUCCESS);
	}
} else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N"))
	   && (!strcmp(sa_data[1], "Y") || !strcmp(sa_data[1], "y"))
	   && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-9 */
	/* Referenced and copied - UPDATE_REF */
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 9 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "N") || !strcmp(sa_data[0], "")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (!strcmp(sa_data[3], ""))) {
	/* fmgr case-4 */
	/* Just copy - DO_NOTHING */
	_PDMdebug("case 4 DO NOTHING", "for <%s>  \n", sa_data[4]);
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (!strcmp(sa_data[3], ""))
) {
	/* fmgr case-5  DO_NOTHING */
	_PDMdebug("case 5 DO NOTHING", "for <%s>  \n", sa_data[4]);
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-6 UPDATE_REF */
	/* Copy and referenced */
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 6 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	MEMclose(&sa_bufr);
	MEMclose(&macro_bufr);
	return (PDM_S_SUCCESS);
        }
_PDMdebug(fname, "EXIT ..\n");
return (PDM_S_SUCCESS);
}


long PDMattach_macro_library(working_area, families)

/***

  This function is called from during checkout to move the macro
  libararies needed for the parametric parts.

  This function will copy a given set of macro libraries.
All *.e's and *.rle's associated to the macro library are copied to local.
All *.e's are bundled together as a cpio file. All *.rle's are bundled
together as a cpio file. These cpio files are treated as multiple files
per part. As soon as these files are brought to local, they will be
unbundled. It's not a rule that they have to be a cpio file. If the file_type
of the macro is other than "CPIO" then those files won't be unbundled.



    4/9/93 - Kumar
***/
	char           *working_area;
        struct PDUcat_node *families;

{
	char           *fname = "PDMattach_macro_library";
	char            sql_str[1024];
	char            row_str[3048], line[200];
	char            dumb_str[1];
	char            **data, **file_data, **file_data1;
        char	        **copy_data, **temp_data;
	char            **file_column;
	char            filename[NFM_COFILENAME + 1];
	char            nodename[NFM_NODENAME + 1], username[NFM_USERNAME + 1];
        char            passwd[NFM_PASSWD + 1], pathname[NFM_PATHNAME + 1];
        char            devicetype[NFM_DEVICETYPE + 1], machid[NFM_MACHID + 1];
        char            opsys[NFM_OPSYS + 1], tcpip[NFM_TCPIP + 1];
        char            xns[NFM_XNS + 1], decnet[NFM_DECNET + 1];
        char            netware[NFM_NETWARE + 1];
        char            plattername[NFM_PLATTERNAME + 1];
        char            partition[NFM_PARTITION + 1], nfs[NFM_NFS + 1];
        char            compress[NFM_COMPRESS + 1];
	int             x, y, z, nxi, yi;
	int             n1, n2, n3, i;
	int             index, catno, n_itemno;
	int             i_catno, i_itemnum, i_type, i_fileno, i_filenum;
        int             i_fileversion, i_filetype, i_fileco, i_cifilename;
        int             i_cofilename, i_cisano, i_status1;
	long            sano = 0, sto_no;
	long            status, dumb_value = 0, fmgr_status = 0;
	MEMptr          bufr = NULL, file_list = NULL, files_info = NULL;
	MEMptr          temp_list = NULL, list = NULL, fmgr_bufr = NULL;
        struct PDUcat_node     *para_cats;
	struct NFMsto_info *sto_list = NULL;
	struct NFMbuf_format *format;
/* added for support libraries support MaC */
	int             MacIndex, AssyIndex, M, Added, partno_sav;
	MEMptr          AssyBufr = NULL, MacLib = NULL;
	char            **AssyData;
	char            **MacData;
	char            setindicator[3], parttype[3];
	char            mem_str[512];
	char            **TmpRow, **TmpColumn, **Format;
	int             col, AlreadyAdded;
	char		**Ndata;
	int		Frow, Nrow, Findex, Nindex;
	MEMptr          TmpFmgrBufr = NULL, TmpFilesInfo = NULL;



        _PDMdebug(fname, "ENTER: Working Area[%s] \n", working_area);

	temp_list = (MEMptr) NULL;
	list = (MEMptr) NULL;
        i_catno = 0;
        i_itemnum = 0;
        i_type = 0;
        i_filenum = 0;
        i_cofilename = 0;
        i_cifilename = 0;
        i_fileno = 0;
        i_filetype = 0;
        i_fileco = 0;
        i_cisano = 0;
        i_fileversion = 0;
        i_status1 = 0;
	n1 = n2 = n3 = 0;
        if(families != NULL)
        {
        para_cats = families;
        if(para_cats != NULL)
        {
	/* get storage area information */

        status = NFMget_storage_info(working_area, &sano, nodename, 
                             username, passwd,
         		     pathname, devicetype, plattername, partition,
			     nfs, compress, machid, opsys, tcpip,
			     xns, decnet, netware);
	if (status != NFM_S_SUCCESS) {
	   PDMrollback_transaction(1200);
	   _PDMdebug(fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
			  status);
	   return (status);
	}

	status = MEMopen(&files_info, MEM_SIZE);
	if (status != MEM_S_SUCCESS) {
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}


	format = (struct NFMbuf_format *) calloc(NFM_TEMP_SIZE1,
			     NFM_TEMP_SIZE1 * sizeof(struct NFMbuf_format));

	if (!format) {
		MEMclose(&files_info);
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}

	strcpy((format + 0)->attr_name, "n_catno");
	strcpy((format + 0)->data_type, "integer");
	strcpy((format + 1)->attr_name, "n_itemnum");
	strcpy((format + 1)->data_type, "integer");
	strcpy((format + 2)->attr_name, "n_type");
	strcpy((format + 2)->data_type, "char(1)");
	strcpy((format + 3)->attr_name, "n_fileno");
	strcpy((format + 3)->data_type, "integer");
	strcpy((format + 4)->attr_name, "n_filenum");
	strcpy((format + 4)->data_type, "integer");
	strcpy((format + 5)->attr_name, "n_fileversion");
	strcpy((format + 5)->data_type, "integer");
	strcpy((format + 6)->attr_name, "n_filetype");
	strcpy((format + 6)->data_type, "char(5)");
	strcpy((format + 7)->attr_name, "n_fileco");
	strcpy((format + 7)->data_type, "char(1)");
	strcpy((format + 8)->attr_name, "n_cisano");
	strcpy((format + 8)->data_type, "integer");
	strcpy((format + 9)->attr_name, "n_cifilename");
	strcpy((format + 9)->data_type, "char(14)");
	strcpy((format + 10)->attr_name, "n_cofilename");
	strcpy((format + 10)->data_type, "char(14)");
	strcpy((format + 11)->attr_name, "n_status1");
	strcpy((format + 11)->data_type, "char(2)");

	status = _NFMbuild_working_buffer_format
		(format, NFM_TEMP_SIZE1, files_info);
	if (status != NFM_S_SUCCESS) {
		MEMclose(&files_info);
		PDMrollback_transaction(1200);
		free(format);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}

	status = PDMcreate_fmgr_bufr(&fmgr_bufr);
	if (status != NFM_S_SUCCESS) {
		MEMclose(&files_info);
		MEMclose(&fmgr_bufr);
		PDMrollback_transaction(1200);
		free(format);
		_PDMdebug(fname, "MEMopen 0x%.8x\n", status);
		return (status);
	}

	free(format);

	i_catno = 0;
	i_itemnum = 1;
	i_type = 2;
	i_fileno = 3;
	i_filenum = 4;
	i_fileversion = 5;
	i_filetype = 6;
	i_fileco = 7;
	i_cisano = 8;
	i_cifilename = 9;
	i_cofilename = 10;
	i_status1 = 11;

	catno = 0;
/****************************************************************************
   Adding support for support libraries to macro libraries.
   The support libraries are in nfmcit as children to the macro
   libraries.
   Alg:
     - For each catalog in linked list,  get the associated
       macro cat & part;
     - For each of these parts, get the assy structure;
     - add the catno and itemno of the assy structure 
       to the MacLibList bufr; only if this part does not
       already exist.
     - For each part in MacLibList; get the file info
     - Add the file info into the file_list bufr 
     - Go by the lfm and bring the files local
****************************************************************************/

  /* Create the MacLib buffer */

      status = MEMopen (&MacLib, 1024);
      if (status != MEM_S_SUCCESS) {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
      status = MEMwrite_format (MacLib, "n_catalogname", "char(40)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemname", "char(80)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemrev", "char(80)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_catalogno", "integer");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemno", "integer");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }

      status = MEMbuild_array(MacLib);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      MacData = (char **) MacLib->data_ptr;

  partno_sav = PDMpart.n_itemno;

  for (; para_cats != NULL; para_cats = para_cats->next ) {
      _PDMdebug (fname, "para_cats->catalog[%s]\n", para_cats->catalog);
      _PDMdebug(fname,"linked list %x and next <%x>\n",
                                             para_cats, para_cats->next);
      _PDMdebug(fname,"Checking the macro lib for <%s>\n",
                                             para_cats->catalog);
      sql_str[0] = '\0';
      sprintf(sql_str,
               "SELECT %s FROM  pdmparamloc WHERE n_catalogname = '%s'", 
                        " p_macrocat,p_macropartno,p_macrorev ",
                        para_cats->catalog);
      status = SQLquery(sql_str,&bufr,512);
      if(status != SQL_S_SUCCESS) {
                  if(status == SQL_I_NO_ROWS_FOUND) continue;
                  _PDMdebug(fname, "SQLquery failed status %d\n", status);
                   return (status);
                  }
      status = MEMbuild_array(bufr);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      copy_data = (char **) bufr->data_ptr;

     /* Need to add parent to the list also. The AssyBufr
        returned will not have this information */

     
      status = PDMquery_catalog_partnos(copy_data[0],
                                              copy_data[1],
                                              copy_data[2],
                                              &catno, &n_itemno);
      if(status != PDM_S_SUCCESS) {
         _PDMdebug (fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
         MEMclose(&bufr);
         continue;
       }

/* There needs a check whether this library is already added.
   Look at the same area in ../cicocp/PDMn_ci.c to see how
   it is done. */

      sprintf (mem_str, "%s\1%s\1%s\1%d\1%d\1",
                       copy_data[0], copy_data[1],
                       copy_data[2], catno, n_itemno);

     _PDMdebug (fname, "mem_str[%s]\n", mem_str);
     status = MEMwrite(MacLib, mem_str);
     if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite Failed 0x%.8x\n", status);
		}

     status = MEMbuild_array(MacLib);
     if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

     MacData = (char **) MacLib->data_ptr;

     /* Get the assy struct for this part */

      status =  PDMquery_assyind_parttype ( copy_data[0],
                                       copy_data[1],
                                       copy_data[2],
                                       setindicator,
                                       parttype);
        if(status != PDM_S_SUCCESS) {
              _PDMdebug (fname, "PDMquery_assyind_parttype:failed: 0x%.8x\n", 
                                                               status);
              setindicator[0] = '\0';
              strcpy (setindicator, "Y");
              }

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
       if (!strcmp (setindicator, "Y") || !strcmp (setindicator, "y"))
*/
       if (!strcmp (setindicator, "Y") || !strcmp (setindicator, "y") ||
           !strcmp (setindicator, "A") || !strcmp (setindicator, "a")) {

       /* This function needs to access PDMpart structure:
          we have stored the value in this member. we now load
          value of this itemno into this */

        PDMpart.n_itemno = n_itemno;

        AssyBufr = NULL;
        status = PDMquery_ass_struc ( copy_data[0],
                                       copy_data[1],
                                       copy_data[2],
                                       50,
                                       setindicator,
                                       0,
                                       &AssyBufr);
        if( (status != PDM_S_SUCCESS ) &&
              (status != PDM_E_PART_NOT_ASSEMBLY)) {
           _PDMdebug(fname,"PDMquery_ass_struc failed status %d\n", status);
           PDMrollback_transaction (1200);
           return(PDM_E_QUERY_SET_MEMBERS);
          }

	if (PDMdebug_on) 
             MEMprint_buffer ("AssyBufr", AssyBufr, PDM_DEBUG_FILE);


      status = MEMbuild_array(MacLib);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      MacData = (char **) MacLib->data_ptr;

      status = MEMbuild_array (AssyBufr);
      if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      AssyData = (char **) AssyBufr->data_ptr;

      for (y = 1; y < AssyBufr->rows; y++) {
       AssyIndex = y * AssyBufr->columns;
       _PDMdebug ("Checking Library", "%s\1%s\1%s\1%s\1%s\1",
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4]);
       Added = 0;
       for (M = 0; M < MacLib->rows; M++) {
	 MacIndex = M * MacLib->columns;
        if ((atol (MacData[MacIndex + 3]) == atol (AssyData[AssyIndex + 3])) &&
           (atol (MacData[MacIndex + 4]) == atol (AssyData[AssyIndex + 4]) ) ){
           _PDMdebug (fname, "cat[%s]:item[%s] already added \n",
                              AssyData[AssyIndex + 10],
                                AssyData[AssyIndex + 11]);
            Added = 1;
            break;
            }

         }
        if (Added != 1) {
           sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1",
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4]);

           _PDMdebug (fname, "mem_str[%s]\n", mem_str);
           status = MEMwrite(MacLib, mem_str);
           if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite Failed 0x%.8x\n", status);
                /*return (status);*/
		}

           status = MEMbuild_array(MacLib);
           if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

           MacData = (char **) MacLib->data_ptr;
         }
        }
       MEMclose (&AssyBufr);
       }
/* Fix to make sure that we get new library */
      MEMclose (&bufr);
      }
 
  PDMpart.n_itemno = partno_sav;

	if (PDMdebug_on) 
             MEMprint_buffer ("MacLib", MacLib, PDM_DEBUG_FILE);

/****************************************************************************
   End of additions
****************************************************************************/

/*
         for (; para_cats != NULL; para_cats = para_cats->next ) {
           _PDMdebug(fname,"linked list %x and next <%x>\n",
                                             para_cats, para_cats->next);
           _PDMdebug(fname,"Checking the macro lib for <%s>\n",
                                             para_cats->catalog);
           sql_str[0] = '\0';
           sprintf(sql_str,
               "SELECT %s FROM  pdmparamloc WHERE n_catalogname = '%s'", 
                        " p_macrocat,p_macropartno,p_macrorev ",
                        para_cats->catalog);
           status = SQLquery(sql_str,&bufr,512);
           if(status != SQL_S_SUCCESS) {
                  if(status == SQL_I_NO_ROWS_FOUND) continue;
                  _PDMdebug(fname, "SQLquery failed status %d\n", status);
                   return (status);
                  }
           status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }
            copy_data = (char **) bufr->data_ptr;
            status = PDMquery_catalog_partnos(copy_data[0],
                                              copy_data[1],
                                              copy_data[2],
                                              &catno, &n_itemno);
            if(status != PDM_S_SUCCESS) {
               _PDMdebug (fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
               MEMclose(&bufr);
               continue;
               }
               }

*/
       for (M = 0; M < MacLib->rows; M++) {
         MacIndex = M * MacLib -> columns;
         copy_data = MacData;
	    _PDMdebug(fname, 
             "prepare to retrieve the information from %s for<%s> <%s> \n", 
                             copy_data[MacIndex+0], copy_data[MacIndex+1], copy_data[MacIndex+2]);
         catno = atol (MacData[MacIndex + 3]);
         n_itemno = atol (MacData[MacIndex + 4]);
/* Join clause is missing ... MaC   042994 ...
             sprintf(sql_str, 
               "%s %s %s, f_%s %s '%s' %s '%s' %s %s %s f_%s %s %d %s",
	     "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
			"n_cisano, n_cifilename, n_cofilename,n_itemno from",
			copy_data[0], copy_data[0],
			"where n_itemname =",
			copy_data[1],
			"and n_itemrev =",
			copy_data[2],
			"and n_fileversion != 0",
			"and n_fileversion =",
			"(select max(n_fileversion) from ",
			copy_data[0],
			"where n_itemnum =",
			n_itemno, ")");
             */

             sprintf(sql_str, 
               "%s %s %s, f_%s %s '%s' %s '%s' %s %d %s %s %s f_%s %s %d %s",
	     "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
			"n_cisano, n_cifilename, n_cofilename,n_itemno from",
			copy_data[MacIndex+0], copy_data[MacIndex+0],
			"where n_itemname =",
			copy_data[MacIndex+1],
			"and n_itemrev =",
			copy_data[MacIndex+2],
			"and n_itemnum =",
                        n_itemno,
			"and n_fileversion != 0",
			"and n_fileversion =",
			"(select max(n_fileversion) from ",
			copy_data[MacIndex+0],
			"where n_itemnum =",
			n_itemno, ")");

	     status = NFMretrieve_values(sql_str, NFM_RETURN_MEMPTR, dumb_str,
					    dumb_value, &list);
	     if (status != NFM_S_SUCCESS) {
	       _PDMdebug(fname, 
                "Macro library %s %s of of catalog not found\n", 
                            copy_data[MacIndex+1], copy_data[MacIndex+2], copy_data[MacIndex+0]);
        	MEMclose(&list);
		continue;
		}
	     if (PDMdebug_on) MEMprint_buffer("list", list, PDM_DEBUG_FILE);
	     status = MEMbuild_array(list);
	     if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array failed status %s\n", status);
		return (status);
	     }

	     file_data = (char **) list->data_ptr;

	     for (y = 0; y < list->rows; y++) {
	     	yi = y * list->columns;
	     	fmgr_status = PDM_I_FILE_MOVE;
	     	fmgr_status = PDMcheck_fmgr_attach (sano, file_data[yi + 7],
                                                catno, atoi(file_data[yi + 8]), 
                                                atoi(file_data[1]), 
                                                atoi(file_data[2]));
	     	_PDMdebug(fname, "FMGR status %d\n", status);
	     	if (fmgr_status == PDM_I_FILE_MOVE) {
			/* MEMwrite on to fmgr_bufr */
		  sql_str[0] = '\0';
		  sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", 
catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "MOVE");
		  status = MEMwrite(fmgr_bufr, sql_str);
		  if (status != MEM_S_SUCCESS) {
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&list);
			PDMrollback_transaction(1200);
			_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
			return (status);
		      	  }
		} else if (fmgr_status == PDM_I_REF_UPDATE) {
		   /* MEMwrite on to fmgr_bufr */
		   sql_str[0] = '\0';
		   sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "REF_UPDATE");
		   status = MEMwrite(fmgr_bufr, sql_str);
		   if (status != MEM_S_SUCCESS) {
		       MEMclose(&files_info);
		       MEMclose(&fmgr_bufr);
		       MEMclose(&list);
		       PDMrollback_transaction(1200);
			_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
			return (status);
		             }
		             continue;
			} else if (fmgr_status == PDM_I_CHECK_OUT) {
	             /* MEMwrite on to fmgr_bufr */
        	     sql_str[0] = '\0';
		     sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "CHECKOUT");
			status = MEMwrite(fmgr_bufr, sql_str);
			if (status != MEM_S_SUCCESS) {
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&list);
			PDMrollback_transaction(1200);
			_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
			return (status);
			   }
		       	continue;
		       } else if (fmgr_status == PDM_I_VERSION_UPDATE) {
				/* MEMwrite on to fmgr_bufr */
			sql_str[0] = '\0';
			sprintf(sql_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1", catno, file_data[yi + 8], file_data[1], file_data[2], file_data[5], file_data[yi + 7], "VERSION_UPDATE");
		status = MEMwrite(fmgr_bufr, sql_str);
		if (status != MEM_S_SUCCESS) {
		MEMclose(&files_info);
		MEMclose(&fmgr_bufr);
		MEMclose(&list);
		PDMrollback_transaction(1200);
		_PDMdebug(fname, "MEMerror 0x%.8x\n", status);
		return (status);
         	     }
		   }
		}
		_PDMdebug(fname,
		"write the files information of this item to files_info\n");
		if ((fmgr_status == PDM_I_VERSION_UPDATE) || (fmgr_status == PDM_I_FILE_MOVE)) {
		for (y = 0; y < list->rows; y++) {
		index = list->columns * y;
		sprintf(row_str, "%d\1%d\1%s\1",
		catno, n_itemno, "S");
		for (z = 0; z < (list->columns - 1); z++) {
		strcat(row_str, file_data[index + z]);
		strcat(row_str, "\1");
		}
		strcat(row_str, "\1");
		_PDMdebug(fname, "row_str %s\n", row_str);
		status = MEMwrite(files_info, row_str);
		if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
		MEMclose(&files_info);
		MEMclose(&fmgr_bufr);
		PDMrollback_transaction(1200);
		return (status);
		    }
		  }
		}
		status = MEMclose(&list);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMclose 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		list = (MEMptr) NULL;
                MEMclose(&bufr);
                bufr = (MEMptr) NULL;
	   }
            MEMclose(&bufr);
            bufr = (MEMptr) NULL;
/*************************************************************************/
/*  Added fix to make sure that duplicates are eliminated in the
    buffers.
    Both files_info and fmgr_bufr needs to be fixed. 
    I know, I know, the better alternative is to eliminate
    duplicates as they are added; the code is not really condusive
    for that...
*/

   if (PDMdebug_on) {
      MEMprint_buffer("files_info before Fix", files_info, PDM_DEBUG_FILE);
      MEMprint_buffer("fmgr_bufr before Fix", fmgr_bufr, PDM_DEBUG_FILE);
      }

     _PDMdebug (fname, "SQLSTR[%s]\n", sql_str);

     status = MEMopen (&TmpFmgrBufr, MEM_SIZE);
      if (status != MEM_S_SUCCESS) {
        MEMclose(&files_info);
        MEMclose(&fmgr_bufr);
        PDMrollback_transaction(1200);
        _PDMdebug (fname, "MEM Open : failed\n");
        return (NFM_E_MEM);
       }

     status = MEMopen (&TmpFilesInfo, MEM_SIZE);
      if (status != MEM_S_SUCCESS) {
        MEMclose(&files_info);
        MEMclose(&fmgr_bufr);
        PDMrollback_transaction(1200);
        _PDMdebug (fname, "MEM Open : failed\n");
        return (NFM_E_MEM);
       }

    status = MEMbuild_array(files_info);
    if (status != MEM_S_SUCCESS) {
        _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
        MEMclose(&files_info);
        MEMclose(&fmgr_bufr);
        PDMrollback_transaction(1200);
        return (status);
      }

    TmpRow = (char **) files_info->data_ptr;
    TmpColumn = (char **) files_info->column_ptr;
    Format = (char **) files_info->format_ptr;

    for (col = 0; col < files_info->columns; col++) {
      status = MEMwrite_format (TmpFilesInfo, TmpColumn[col], Format[col]);
      if (status != MEM_S_SUCCESS) {
            _PDMdebug (fname,"MEM Wr For : failed status 0x%.8x\n", status);
            MEMclose(&files_info);
            MEMclose(&fmgr_bufr);
            PDMrollback_transaction(1200);
            return (NFM_E_MEM);
          }
      }

    status = MEMbuild_array (TmpFilesInfo);
    if (status != MEM_S_SUCCESS) {
        _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
        MEMclose(&files_info);
        MEMclose(&fmgr_bufr);
        PDMrollback_transaction(1200);
        return (status);
      }

    Ndata = (char **) TmpFilesInfo->data_ptr;

    for (Frow = 0; Frow < files_info->rows; Frow++) {
     Findex = files_info->columns * Frow;
     AlreadyAdded = 0;
     for (Nrow = 0; Nrow < TmpFilesInfo->rows; Nrow++) {
       Nindex = TmpFilesInfo->columns * Nrow;
       if (!strcmp (Ndata[Nindex + 10], TmpRow[Findex + 10])) {
         AlreadyAdded = 1;
         break;
         }
       }
      if (AlreadyAdded != 1) {
         sql_str[0] = '\0';
         for (col = 0; col < files_info->columns; col++) {
           strcat (sql_str, TmpRow[Findex + col]);
           strcat (sql_str, "\1");
           }
         _PDMdebug ("Row to TmpFilesInfo", "%s\n", sql_str);
         status = MEMwrite(TmpFilesInfo, sql_str);
         if (status != MEM_S_SUCCESS) {
          _PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
          MEMclose(&files_info);
          MEMclose(&fmgr_bufr);
          PDMrollback_transaction(1200);
          return (status);
          }

          status = MEMbuild_array (TmpFilesInfo);
          if (status != MEM_S_SUCCESS) {
              _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
              MEMclose(&files_info);
              MEMclose(&fmgr_bufr);
              PDMrollback_transaction(1200);
              return (status);
            }
          Ndata = (char **) TmpFilesInfo->data_ptr;
       }
      else {
       _PDMdebug (fname, "File [%s] already added\n", TmpRow[Findex + 10]);
       }
     }

    status = MEMbuild_array(fmgr_bufr);
    if (status != MEM_S_SUCCESS) {
        _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
        MEMclose(&files_info);
        MEMclose(&fmgr_bufr);
        PDMrollback_transaction(1200);
        return (status);
      }

    TmpRow = (char **) fmgr_bufr->data_ptr;
    TmpColumn = (char **) fmgr_bufr->column_ptr;
    Format = (char **) fmgr_bufr->format_ptr;
   
    for (col = 0; col < fmgr_bufr->columns; col++) {
      status = MEMwrite_format (TmpFmgrBufr, TmpColumn[col], Format[col]);
      if (status != MEM_S_SUCCESS) {
            _PDMdebug (fname,"MEM Wr For : failed status 0x%.8x\n", status);
            MEMclose(&files_info);
            MEMclose(&fmgr_bufr);
            PDMrollback_transaction(1200);
            return (NFM_E_MEM);
          }
      }

    status = MEMbuild_array (TmpFmgrBufr);
    if (status != MEM_S_SUCCESS) {
              _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
              MEMclose(&files_info);
              MEMclose(&fmgr_bufr);
              PDMrollback_transaction(1200);
              return (status);
            }
    Ndata = (char **) TmpFmgrBufr->data_ptr;

    for (Frow = 0; Frow < fmgr_bufr->rows; Frow++) {
     Findex = fmgr_bufr->columns * Frow;
     AlreadyAdded = 0;
     _PDMdebug (fname, "Checking [%s] ...\n", TmpRow[Findex + 5]);
     for (Nrow = 0; Nrow < TmpFmgrBufr->rows; Nrow++) {
       Nindex = TmpFmgrBufr->columns * Nrow;
       if (!strcmp (Ndata[Nindex + 5], TmpRow[Findex + 5])) {
         AlreadyAdded = 1;
         break;
         }
       }
      if (AlreadyAdded != 1) {
         _PDMdebug (fname, "Adding [%s] ...\n", TmpRow[Findex + 5]);
         sql_str[0] = '\0';
         for (col = 0; col < fmgr_bufr->columns; col++) {
           strcat (sql_str, TmpRow[Findex + col]);
           strcat (sql_str, "\1");
           }
         _PDMdebug ("Row to TmpFmgrBufr", "%s\n", sql_str);
         status = MEMwrite(TmpFmgrBufr, sql_str);
         if (status != MEM_S_SUCCESS) {
          _PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
          MEMclose(&files_info);
          MEMclose(&fmgr_bufr);
          PDMrollback_transaction(1200);
          return (status);
          }

          status = MEMbuild_array (TmpFmgrBufr);
          if (status != MEM_S_SUCCESS) {
              _PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
              MEMclose(&files_info);
              MEMclose(&fmgr_bufr);
              PDMrollback_transaction(1200);
              return (status);
            }
          Ndata = (char **) TmpFmgrBufr->data_ptr;
         _PDMdebug (fname, "Added [%s] successfully\n", TmpRow[Findex + 5]);
       }
      else {
       _PDMdebug (fname, "File [%s] already added\n", TmpRow[Findex + 5]);
       }
     }

   MEMclose(&files_info);
   MEMclose(&fmgr_bufr);
   files_info = TmpFilesInfo;
   fmgr_bufr  = TmpFmgrBufr;

   if (PDMdebug_on) {
      MEMprint_buffer("files_info", files_info, PDM_DEBUG_FILE);
      MEMprint_buffer("fmgr_bufr", fmgr_bufr, PDM_DEBUG_FILE);
      }


/*************************************************************************/
          }
	if (files_info->rows > 0) {
		status = MEMbuild_array(files_info);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEM_S_SUCCESS 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		if (PDMdebug_on)
		MEMprint_buffer("files_info", files_info, PDM_DEBUG_FILE);
		status = NFMbuild_fto_buffer(&file_list, 0);
		if (status != NFM_S_SUCCESS) {
		_PDMdebug(fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
		sprintf(row_str,
		"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
		sano, nodename, username, passwd, pathname, devicetype, plattername, partition, nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
			"\1\1\1\1\1\1\1\1\1");

		_PDMdebug(fname, "MEMwrite %s\n", row_str);

		status = MEMwrite(file_list, row_str);
		if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
			return (status);
		}
		sto_list = (struct NFMsto_info *) calloc(files_info->rows,
		       (files_info->rows + 1) * sizeof(struct NFMsto_info));

		if (!sto_list) {
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			_PDMdebug(fname, "calloc sto_list failed\n");
			return (NFM_E_MALLOC);
		}
		sto_list->sano = sano;
		strcpy(sto_list->nodename, nodename);
		strcpy(sto_list->username, username);
		strcpy(sto_list->passwd, passwd);
		strcpy(sto_list->pathname, pathname);
		strcpy(sto_list->devicetype, devicetype);
		strcpy(sto_list->plattername, plattername);
		strcpy(sto_list->partition, partition);
		strcpy(sto_list->nfs, nfs);
		strcpy(sto_list->compress, compress);
		strcpy(sto_list->machid, machid);
		strcpy(sto_list->opsys, opsys);
		strcpy(sto_list->tcpip, tcpip);
		strcpy(sto_list->xns, xns);
		strcpy(sto_list->decnet, decnet);
		strcpy(sto_list->netware, netware);

		data = (char **) files_info->data_ptr;

		for (x = 0, sto_no = 1; x < files_info->rows; x++) {
			index = files_info->columns * x;
			_PDMdebug(fname, "data[index+i_cisano] = %s\n",
				  data[index + i_cisano]);
			/* check to see if the cisano already on the list */
		for (y = 0; y < sto_no; y++) {
		_PDMdebug(fname, "(sto_list+%d)->sano: %d\n", y,
				  (sto_list + y)->sano);
		if ((sto_list + y)->sano == atol(data[index + i_cisano])) {
		_PDMdebug(fname, "storage_area_no found in sto_list \n");
					break;
				}
			}
			if (y >= sto_no) {
	_PDMdebug(fname, "n_cisano not found in the list, add to it \n");
	_PDMdebug(fname, "n_cisano %s add  \n", data[index + i_cisano]);
		(sto_list + sto_no)->sano = atol(data[index + i_cisano]);
				sto_no++;
			}
		}


		/*
		 * at this point, I have a list of storage nos, so retrieve
		 * all the information from nfmstoragearea and nfmnodes
		 * table.
		 */

	status = NFMget_storages_information(sto_list + 1, sto_no - 1, 1);
		if (status != NFM_S_SUCCESS) {
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
	_PDMdebug(fname, "NFMget_storages_information 0x%.8x\n", status);
			return (status);
		}
		_PDMdebug(fname, "prepare file transfer buffer\n");
		for (x = 0; x < files_info->rows; x++) {
			index = files_info->columns * x;
			sql_str[0] = '\0';
			sprintf(sql_str,
				"%s %s %d %s '%s' %s %s %s %s %s %s ",
				"select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
			"n_fileversion from nfmsafiles where n_sano =", sano,
			"and n_filename =",
         	         data[index + i_cofilename], "and n_catalogno =",
	data[index + i_catno], "and n_itemno =", data[index + i_itemnum],
		"and n_filenum =", data[index + i_filenum]);
	status = SQLquery(sql_str, &temp_list, MEM_SIZE);
		if (status == SQL_S_SUCCESS) {
		status = MEMbuild_array(temp_list);
			if (status != MEM_S_SUCCESS) {
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			MEMclose(&temp_list);
			PDMrollback_transaction(1200);
			_PDMdebug(fname, "MEMbuild_array 0x%.8x\n", status);
			return (status);
			}
			temp_data = (char **) temp_list->data_ptr;
			} else if (status == SQL_I_NO_ROWS_FOUND) {
				/* add to the table */
			} else {
				_NFMfree_linked_lists(sto_list, NULL);
				MEMclose(&files_info);
				MEMclose(&fmgr_bufr);
				MEMclose(&file_list);
				PDMrollback_transaction(1200);
				_PDMdebug(fname, "SQLquery 0x%.8x\n", status);
				return (status);
			}
		_PDMdebug(fname, "Try to find cisano [%s] in sto_list\n",
				  data[index + i_cisano]);
		_PDMdebug(fname, "sto_no [%d] \n", sto_no);
		row_str[0] = '\0';
		for (y = 0; y < sto_no; y++) {
		_PDMdebug(fname, "(sto_list+%d)->sano = %d\n",
				  y, (sto_list + y)->sano);
		if ((sto_list + y)->sano == atol(data[index + i_cisano])) {
			_PDMdebug(fname, "found match in sto_list\n");
			_PDMdebug(fname, "%d\n", (sto_list + y)->sano);
			_PDMdebug(fname, "%s\n", (sto_list + y)->nodename);
			_PDMdebug(fname, "%s\n", (sto_list + y)->username);
			_PDMdebug(fname, "%s\n", (sto_list + y)->passwd);
			_PDMdebug(fname, "%s\n", (sto_list + y)->pathname);
			_PDMdebug(fname, "%s\n", (sto_list + y)->devicetype);
			_PDMdebug(fname, "%s\n", (sto_list + y)->plattername);
			_PDMdebug(fname, "%s\n", (sto_list + y)->partition);
			_PDMdebug(fname, "%s\n", (sto_list + y)->nfs);
			_PDMdebug(fname, "%s\n", (sto_list + y)->compress);
			_PDMdebug(fname, "%s\n", (sto_list + y)->machid);
			_PDMdebug(fname, "%s\n", (sto_list + y)->opsys);
			_PDMdebug(fname, "%s\n", (sto_list + y)->tcpip);
			_PDMdebug(fname, "%s\n", (sto_list + y)->xns);
			_PDMdebug(fname, "%s\n", (sto_list + y)->decnet);
			_PDMdebug(fname, "%s\n", (sto_list + y)->netware);
			sprintf(row_str,
			"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
			(sto_list + y)->sano, (sto_list + y)->nodename,
                        (sto_list + y)->username, (sto_list + y)->passwd,
			(sto_list + y)->pathname, (sto_list + y)->devicetype,
(sto_list + y)->plattername, (sto_list + y)->partition, (sto_list + y)->nfs,
(sto_list + y)->compress, (sto_list + y)->machid, (sto_list + y)->opsys,
(sto_list + y)->tcpip, (sto_list + y)->xns, (sto_list + y)->decnet,
					(sto_list + y)->netware);
			_PDMdebug(fname, "Row_str %s\n", row_str);
					break;
				}
			}
			if (y >= sto_no) {
		_PDMdebug(fname, "check-in-to storage area incorrect\n");
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
         		MEMclose(&fmgr_bufr);
			MEMclose(&file_list);
			MEMclose(&temp_list);
			PDMrollback_transaction(1200);
			return (status);
			}
			if (strlen(data[index + i_fileno])) {
				strcat(row_str, data[index + i_fileno]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			strcat(row_str, "\1");	/* n_fileold */
			if (strlen(data[index + i_cifilename])) {
				strcat(row_str, data[index + i_cifilename]);
				strcat(row_str, "\1");
			} else {
		status = NFMnew_file_name(0, atol(data[index + i_catno]),
				    atol(data[index + i_fileno]), filename);
				if (status != NFM_S_SUCCESS) {
					_NFMfree_linked_lists(sto_list, NULL);
					MEMclose(&files_info);
					MEMclose(&file_list);
					MEMclose(&fmgr_bufr);
					MEMclose(&temp_list);
					PDMrollback_transaction(1200);
			_PDMdebug(fname, "NFMget_file_name 0x%.8x\n", status);
					return (status);
				}
				strcat(row_str, filename);
				strcat(row_str, "\1");
			}
			if (strlen(data[index + i_cofilename])) {
				strcat(row_str, data[index + i_cofilename]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			if (strlen(data[index + i_filetype])) {
				strcat(row_str, data[index + i_filetype]);
				strcat(row_str, "\1");
			} else
				strcat(row_str, "\1");
			strcat(row_str, "100\1");
			strcat(row_str, "2033\1\1\1");

			_PDMdebug(fname, "row_str %s\n", row_str);
			status = MEMwrite(file_list, row_str);
			if (status != MEM_S_SUCCESS) {
				_PDMdebug(fname, "MEMwrite 0x%.8x\n", status);
				_NFMfree_linked_lists(sto_list, NULL);
				MEMclose(&files_info);
				MEMclose(&fmgr_bufr);
				MEMclose(&file_list);
				PDMrollback_transaction(1200);
				return (status);
			}
		}		/* prepare file transfer buffer */
		if (PDMdebug_on) {
			MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
			MEMprint_buffer("fmgr_bufr", fmgr_bufr, PDM_DEBUG_FILE);
		}
		status = _NFMfs_recv_files(&file_list);
		if (status != NFM_S_SUCCESS) {
			_PDMdebug(fname, "_NFMfs_recv_files 0x%.8x\n", status);
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			_NFMfs_undo_recv_files(&file_list);
			MEMclose(&file_list);
			MEMclose(&fmgr_bufr);
			PDMrollback_transaction(1200);
			return (status);
		}
	}
	 /* if there is any information in files_info */ 
	else {
		_PDMdebug(fname, "No files to move\n");
	}

	if (fmgr_bufr->rows > 0) {
		status = PDMupdate_fmgr_copy(sano, fmgr_bufr);
		if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "PDMupdate_fmgr_copy 0x%.8x\n", status);
			_NFMfree_linked_lists(sto_list, NULL);
			MEMclose(&files_info);
			MEMclose(&fmgr_bufr);
			_NFMfs_undo_recv_files(&file_list);
			MEMclose(&file_list);
			PDMrollback_transaction(1200);
			return (status);
		}
	}
	if (PDMdebug_on)
		MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);

	if (file_list != NULL) {
		status = MEMbuild_array(file_list);
		if (status == MEM_S_SUCCESS) {
		file_data1 = (char **) file_list->data_ptr;
		file_column = (char **) file_list->column_ptr;
		for (i = 0; i < file_list->columns; i++) {
		if (!strcmp(file_column[i], "n_cofilename"))
			n1 = i;
		else if (!strcmp(file_column[i], "n_status1"))
			n2 = i;
		else if (!strcmp(file_column[i], "n_filetype"))
			n3 = i;
			}
	for (i = 1; i < file_list->rows; i++) {
		nxi = i * file_list->columns;
		row_str[0] = '\0';
		if (atoi(file_data1[nxi + n2]) == 2035) {
		PDMconvert_to_lower(file_data1[nxi + n3], file_data1[nxi + n3]);
		if (!strcmp(file_data1[nxi + n3], "CPIO")) {
		sprintf(line, "cpio -it < %s/%s > %s/.%s", storage->path_name, file_data1[nxi + n1], storage->path_name, file_data1[nxi + n1]);
        	_PDMdebug(fname, "cpio command <%s> \n", line);
		status = NFMsystem(line);
		if (status != NFM_S_SUCCESS) {
		_PDMdebug(fname, "cpio command <%s> \n", line);
        	_PDMdebug(fname, "cpio listing failed for  <%s> : errno < %d>\n", file_data1[nxi + n1], errno);
		}
		sprintf(line, "cpio -ivumd < %s/%s", storage->path_name, file_data1[nxi + n1]);
		_PDMdebug(fname, "cpio command <%s> \n", line);
		status = NFMsystem(line);
		if (status != NFM_S_SUCCESS) {
		_PDMdebug(fname, "cpio failed for  <%s> : errno < %d>\n", file_data1[nxi + n1], errno);
			}
		}
			} else {
				}
			}
		}
	}
	status = _NFMfree_linked_lists(sto_list, NULL);
	if (status != NFM_S_SUCCESS)
		_PDMdebug(fname, "_NFMfree_linked_lists 0x%.8x\n", status);
	if (fmgr_bufr != NULL && fmgr_bufr->rows > 0 && fmgr_bufr->rows < 10000)
		status = MEMclose(&fmgr_bufr);
	if (status != MEM_S_SUCCESS)
		_PDMdebug(fname, "MEMclose 0x%.8x\n", status);

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS)
		_PDMdebug(fname, "PDMstart_transaction 0x%.8x\n", status);

       }
	_PDMdebug(fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS);
	return (PDM_S_SUCCESS);
}


int PDMold_detach_macro_library(
			char *macro_cat,
			struct PDUcat_node * para_cats1,
			MEMptr *delete_list
                           )
{
	char            **macro_data, **data = NULL, **sa_data = NULL;
	char            sql_str[1024], mem_str[100];
	int             ref_count = 0;
	int             n_itemno = 0, n_catalogno = 0;
	MEMptr          sa_bufr = NULL;
	MEMptr          macro_bufr = NULL;
	MEMptr          bufr = NULL;
	struct PDUcat_node *para_cats;
	char           *fname = "PDMdetach_macro_library";
        long           status = PDM_S_SUCCESS;

	_PDMdebug(fname, "ENTER:\n");

     status = MEMopen (delete_list, 512);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : failed\n");
         return (NFM_E_MEM);
       }
   status = MEMwrite_format (*delete_list, "n_cofilename", "char(128)");
         if (status != MEM_S_SUCCESS)
          {
            _PDMdebug (fname,"MEM Wr For : failed status \n");
            return (NFM_E_MEM);
          }
   
	sprintf(sql_str, "SELECT p_macrocat,p_macropartno,p_macrorev FROM pdmparamloc WHERE n_catalogname = '%s'", macro_cat);
	status = SQLquery(sql_str, &macro_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&macro_bufr);
		_PDMdebug(fname, "SQLquery failed status %d\n", status);
		return (PDM_E_MACRO_NOT_FOUND);
	}

	status = MEMbuild_array(macro_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&macro_bufr);
		_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
		return (status);
	}

      if (PDMdebug_on) 
                  MEMprint_buffer ("macro_bufr", macro_bufr, PDM_DEBUG_FILE);


	macro_data = (char **) macro_bufr->data_ptr;
para_cats = para_cats1;

 if (para_cats != NULL) {
   for (; para_cats != NULL; para_cats = para_cats->next) {
      _PDMdebug(fname, 
         "linked list %x and next <%x>\n", para_cats, para_cats->next);
      _PDMdebug(fname, 
         "Checking the macro lib for <%s>\n", para_cats->catalog);
      sql_str[0] = '\0';
      mem_str[0] = '\0';
      sprintf(sql_str, "SELECT %s FROM %s WHERE %s '%s' ",
       " p_macrocat, p_macropartno, p_macrorev ",
       " pdmparamloc ",
       " n_catalogname = ", para_cats->catalog);

      status = SQLquery(sql_str, &bufr, 512);
      if (status != SQL_S_SUCCESS) {
      	MEMclose(&bufr);
      	if (status == SQL_I_NO_ROWS_FOUND)
      		continue;
      	_PDMdebug(fname, "SQLquery failed status %d\n", status);
      	return (status);
      }

      status = MEMbuild_array(bufr);
      if (status != MEM_S_SUCCESS) {
      	MEMclose(&bufr);
        	_PDMdebug(fname, "MEMbuild_array: 0x%.8x\n", status);
      	return (status);
      }

      if (PDMdebug_on) 
                  MEMprint_buffer ("bufr", bufr, PDM_DEBUG_FILE);

      data = (char **) bufr->data_ptr;

      if (!strcmp(macro_data[0], data[0]) &&
          !strcmp(macro_data[1], data[1]) &&
          !strcmp(macro_data[2], data[2])) {
      	MEMclose(&bufr);
      	MEMclose(&macro_bufr);
      	_PDMdebug("MACRO LIBRARY IS NESTED", 
            "<%s> <%s> <%s> nested in <%s> <%s> <%s>\n", 
            macro_data[0], macro_data[1], macro_data[2], 
            data[0], data[1], data[2]);
      	return (PDM_S_SUCCESS);
      }
      MEMclose(&bufr);
   }
  }

  status = PDMquery_catalog_partnos (macro_data[0], 
                                       macro_data[1], 
                                       macro_data[2], 
                                       &n_catalogno, 
                                       &n_itemno);
  if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
	MEMclose(&macro_bufr);
	return (PDM_E_LIBRARY_NOT_FOUND);
     }
  sql_str[0] = '\0';
  sprintf(sql_str, "%s %s %d %s %d %s %d ",
      " select n_co, n_copy, n_fileversion, n_ref, n_filename, n_filenum ",
      " from nfmsafiles where n_sano = ", storage->storage_no,
      " and n_catalogno = ", n_catalogno,
      " and n_itemno = ", n_itemno);

   status = SQLquery(sql_str, &sa_bufr, 512);
   if (status != SQL_S_SUCCESS) {
	MEMclose(&sa_bufr);
	MEMclose(&macro_bufr);
	if (status == SQL_I_NO_ROWS_FOUND) {
	  /* report that the files to be moved */
	  _PDMdebug("", "No filemgr update is needed for this item\n");
	  return (PDM_S_SUCCESS);
	} 
        else {
	  _PDMdebug(fname, "SQLquery failed   0x%.8x\n", status);
	  return (PDM_E_SQL_QUERY);
	}
     }
    status = MEMbuild_array(sa_bufr);
    if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEM error  0x%.8x\n", status);
	MEMclose(&sa_bufr);
	MEMclose(&bufr);
	return (status);
    }
    sa_data = (char **) sa_bufr->data_ptr;
    if (PDMdebug_on)
	_PDMdebug(fname, "n_co %s, n_copy %s n_ref %s n_filename %s \n", sa_data[0], sa_data[1], sa_data[3], sa_data[4]);

    if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
        && (!strcmp(sa_data[1], "Y") || !strcmp(sa_data[1], "y"))
        && (!strcmp(sa_data[3], "")))
    {
    /* fmgr-case 2 */
    /* Checked out and  copied  - DO_NOTHING */
    _PDMdebug("case 2 DO NOTHING", "for <%s>  \n", sa_data[4]);
    MEMclose(&macro_bufr);
    MEMclose(&sa_bufr);
    return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
	       && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	   && (!strcmp(sa_data[3], "")))
    {
    /* fmgr-case 1 */
    /* Just Checked out  - DO_NOTHING */
    _PDMdebug("case 1 DO NOTHING", "for <%s>  \n", sa_data[4]);
    MEMclose(&macro_bufr);
    MEMclose(&sa_bufr);
    return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y"))
	       && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	       && (atoi(sa_data[3]) > 0)) {
	/* fmgr-case 3 */
	/* Checked out and   referenced  - UPDATE_REF */
	ref_count = atoi(sa_data[3]);
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 3 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	return (PDM_S_SUCCESS);
    } else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N"))
	   && (!strcmp(sa_data[1], "") || !strcmp(sa_data[1], "N"))
	   && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-7 */
	/* Just  referenced - UPDATE_CO */
	if (atoi(sa_data[3]) == 1) {

		sprintf(sql_str, "DELETE FROM  NFMSAFILES  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
			return (status);
		}
		_PDMdebug("case 7 DELETE  ", "file <%s>  \n", sa_data[4]);
		mem_str[0] = '\0';
		sprintf(mem_str, "%s\1", sa_data[4]);
		status = MEMwrite(*delete_list, mem_str);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "MEM Wr For : status = <0x%.8x>\n", status);
			return (NFM_E_MEM);
		}
	} else {
		ref_count = atoi(sa_data[3]);
		if (ref_count != 0)
			ref_count = ref_count - 1;
		sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
		_PDMdebug("case 7 UPDATE REF ", "for <%s>  \n", sa_data[4]);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
			MEMclose(&macro_bufr);
			MEMclose(&sa_bufr);
			_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
			return (status);
		}
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		return (PDM_S_SUCCESS);
	}
} else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N"))
	   && (!strcmp(sa_data[1], "Y") || !strcmp(sa_data[1], "y"))
	   && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-9 */
	/* Referenced and copied - UPDATE_REF */
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 9 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&macro_bufr);
		MEMclose(&sa_bufr);
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "N") || !strcmp(sa_data[0], "")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (!strcmp(sa_data[3], ""))) {
	/* fmgr case-4 */
	/* Just copy - DO_NOTHING */
	_PDMdebug("case 4 DO NOTHING", "for <%s>  \n", sa_data[4]);
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "Y") || !strcmp(sa_data[0], "y")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (!strcmp(sa_data[3], ""))
) {
	/* fmgr case-5  DO_NOTHING */
	_PDMdebug("case 5 DO NOTHING", "for <%s>  \n", sa_data[4]);
	MEMclose(&macro_bufr);
	MEMclose(&sa_bufr);
	return (PDM_S_SUCCESS);
} else if ((!strcmp(sa_data[0], "") || !strcmp(sa_data[0], "N")) && (!strcmp(sa_data[1], "y") || !strcmp(sa_data[1], "Y")) && (atoi(sa_data[3]) > 0)) {
	/* fmgr case-6 UPDATE_REF */
	/* Copy and referenced */
	if (ref_count != 0)
		ref_count = ref_count - 1;
	sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, sa_data[1], sa_data[0], storage->storage_no, n_catalogno, n_itemno, sa_data[5], sa_data[2], sa_data[4]);
	_PDMdebug("case 6 UPDATE REF ", "for <%s>  \n", sa_data[4]);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		_PDMdebug(fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
		return (status);
	}
	MEMclose(&sa_bufr);
	MEMclose(&macro_bufr);
	return (PDM_S_SUCCESS);
        }
_PDMdebug(fname, "EXIT ..\n");
return (PDM_S_SUCCESS);
}
