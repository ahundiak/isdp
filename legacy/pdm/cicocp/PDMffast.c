#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"NFMstruct.h"
#include		"NFMfile.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"PDMproto.h"
#include		"PDUstorage.h"
#include                "PDMmessage.h"


/* APOGEE START static long     RIScode; APOGEE END */
static long     status;
static char     s[1024];
extern PDMpart_ptr  PDMpart;
extern PDMchild_ptr  PDMchild;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern struct PDUstorage *storage;
extern char glob_var[100];

extern struct sto_area_info STO_info;

/*
 * see the desc. on pdmr side
 * 
 * ws_buffer contains copy_bufr and strg_bufr of the following formats
 * 
 * n_catalogname, n_itemname, n_itemrev, n_catalogno, n_itemno, n_cofilename
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
 * Creation _ kumar Narayanan
 */

int PDMcopy_attach(copy_bufr, return_buffer)
	MEMptr		copy_bufr;
	MEMptr          *return_buffer;
{
	MEMptr          success_bufr = NULL;
	MEMptr          failure_bufr = NULL;
        char            *fn = "PDMcopy_attach";
        char            *msg = NULL;

	PDMdebug("ENTER:PDMcopy_attach\n");

        msg = (char *)PDUtranslate_message(PDM_I_COPYING_FILES);
        strcpy(glob_var, msg);
        PDMupdate_dots();
	*return_buffer = NULL;
     status = MEMopen (&success_bufr, 512);
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (success_bufr, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (success_bufr, "n_status", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMopen (&failure_bufr, 512);
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (failure_bufr, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
		MEMclose(&failure_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (failure_bufr, "n_status", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
		MEMclose(&copy_bufr);
		MEMclose(&success_bufr);
		MEMclose(&failure_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
	if (PDMdebug_on) {
		MEMprint_buffer("copy_bufr", copy_bufr, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
        PDMupdate_dots();
 status = PDMcopy_part_files(storage->storage_name, copy_bufr, success_bufr, failure_bufr);
			if (status != PDM_S_SUCCESS) {
			MEMclose(&copy_bufr);
		       MEMclose(&success_bufr);
		       MEMclose(&failure_bufr);
				sprintf(s, 
				"PDMcopy_part_files failed status %d\n", 
					status);
				PDMdebug(s);
				return (status);
			}

	status = PDMload_copy_buffer(copy_bufr, success_bufr, failure_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&copy_bufr);
		sprintf(s, "MEMbuild_array failed status \n", status);
		PDMdebug(s);
		return (status);
	}
        PDMupdate_dots();
	if (PDMdebug_on) {
		MEMprint_buffer("success_bufr", success_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("failure_bufr", failure_bufr, PDM_DEBUG_FILE);
	}
        *return_buffer = copy_bufr;
		       MEMclose(&success_bufr);
		       MEMclose(&failure_bufr);
        PDMreset_dots();
        msg = (char *)PDUtranslate_message(PDM_S_SUCCESS);
        UI_status(msg);
	PDMdebug("EXIT:PDMfcopy_attach\n");
	return (PDM_S_SUCCESS);
}

/* 3-1-91 - Kumar written to copy a atomic part */

int PDMcopy_atomic(user_id, catalog, partnum, revision, strg_bufr, attach_bufr)
long   user_id;
char   *catalog;
char   *partnum;
char   *revision;
MEMptr strg_bufr;
MEMptr *attach_bufr;
{

  MEMptr list; 
  char   write[500];
  char   node_name[50], user_name[50], passwd[50];
  char   path_name[50], device_type[10], mach_id[20];
  char   net_xns[10], net_tcp[10], op_sys[10], net_dec[10];
  static char *fn = "PDMcopy_atomic:";
  int    to_sano;
  char   **data3;

    PDMdebug("ENTER: PDMcopy_atomic\n");
     status = MEMopen (&list, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_catalogno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_itemno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_sano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_nodename", "char(30)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_username", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_passwd", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_pathname", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_devicetype", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_machid", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_opsys", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_tcpip", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_xns", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_decnet", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cifilename", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_filetype", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
      status = NFMget_sa_no_info(user_id, PDMpart.n_cisano, node_name, 
               user_name, passwd, path_name, device_type, mach_id, op_sys, 
               net_tcp, net_xns, net_dec);
         if(status != NFM_S_SUCCESS)
        {
         sprintf(s, "NFMget_sa_no_info failed status %d\n", status);
         PDMdebug(s);
         MEMclose(&list);
         return(PDM_E_BAD_STRG);
        } 
            
    sprintf(write, "%d\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", PDMpart.n_catalogno, PDMpart.n_itemno, PDMpart.n_fileno, PDMpart.n_cisano, node_name, user_name, passwd, path_name, device_type, mach_id, op_sys, net_tcp, net_xns, net_dec, PDMpart.n_cifilename, PDMpart.n_cofilename, "", "", "move");

       status = MEMwrite(list, write);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr  : status = <0x%.8x>\n", status);
        return (status);
       }
       status = PDMi_find_storageno(strg_bufr, &to_sano);
       if (status != PDM_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND)
        {
           MEMclose(&list);
           return(PDM_E_BAD_STRG);
        }
               MEMbuild_array(strg_bufr);
               data3 = (char **)strg_bufr->data_ptr;
        if (status == SQL_I_NO_ROWS_FOUND)
            {
            
             status = _NFMadd_temp_sa(user_id, data3[1], data3[2], 
                            data3[3], data3[4]);
                if (status != NFM_S_SUCCESS)
                     {
                       MEMclose(&list);
                       sprintf(s, "_NFMadd_temp_sa failed %d\n", status);
                       return(PDM_E_BAD_STRG);
                     }
                   status = PDMi_find_storageno(strg_bufr, &to_sano);
                 if (status != PDM_S_SUCCESS )
                      {
                          MEMclose(&list);
                          return(PDM_E_BAD_STRG);
                      }
              }
      if(PDMdebug_on)
        MEMprint_buffer("list buffer", list, PDM_DEBUG_FILE);

/* this function loads the global storage area structure with the
   data obtained from nfmstoragearea and nfmnodes table.
   this structure is later used by NFMmv_files_in to construct
   a buffer and append it to the list buffer... */

       status =  PDMXXsa_info (to_sano);
           if (status != NFM_S_SUCCESS)
              {
               MEMclose(&list);
               sprintf(s, "PDMXXsa_info failed status %d\n", status);
               PDMdebug(s);
               return(status);
               }
    
       status = _NFMmv_files_in(user_id, to_sano, data3[3], &list);
           if (status != NFM_S_SUCCESS)
              {
               MEMclose(&list);
               sprintf(s, "NFMmv_files_in failed status %d\n", status);
               PDMdebug(s);
               return(PDM_E_MOVE_FILE);
               }
       status = PDMi_prepare_buffer1(attach_bufr);
if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMi_prepare_buffer1 failed status %d\n", 
                        status);
                PDMdebug(s);
                return (status);
        }
sprintf(s, "%s\1%s\1%s\1%d\1%s\1%s\1\1%s\1\1", 
           catalog, partnum, revision, 0, PDMpart.n_cofilename, PDMpart.p_parttype, "Y");
        status = MEMwrite(*attach_bufr, s);
        if (status != MEM_S_SUCCESS) {
                MEMclose(attach_bufr);
                sprintf(s, "MEMwrite failed statuis %d \n", 
                        status);
                PDMdebug(s);
                return (PDM_E_WRITE_ROW);
        }

    PDMdebug("EXIT: PDMcopy_atomic\n");
       return(PDM_S_SUCCESS);


}

/* Kumar - 3-3-91 - written to copy an assembly */

int PDMfcopy_assembly(user_id, catalog, partnum, revision, strg_bufr, attach_bufr)
long   user_id;
char   *catalog;
char   *partnum;
char   *revision;
MEMptr strg_bufr;
MEMptr attach_bufr;
{

  MEMptr list; 
  char   write[500];
  char   node_name[50], user_name[50], passwd[50];
  char   path_name[50], device_type[10], mach_id[20];
  char   net_xns[10], net_tcp[10], op_sys[10], net_dec[10];
  static char *fn = "PDMcopy_assembly:";
  int    to_sano, n1, n2, n3, n4, n5, n6, i, nxi;
  char   **data3, **column_ptr, **attach_data;
   

    PDMdebug("ENTER: PDMcopy_assembly\n");
/* ANSI */
     catalog = NULL;
     partnum = NULL;
     revision = NULL;

     status = MEMopen (&list, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_catalogno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_itemno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_sano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_nodename", "char(30)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_username", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_passwd", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_pathname", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_devicetype", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_machid", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_opsys", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_tcpip", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_xns", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_decnet", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cifilename", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_filetype", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMbuild_array (attach_bufr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
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
                else if (!strcmp(column_ptr[i], "n_itemname"))
                        n2 = i;
                else if (!strcmp(column_ptr[i], "n_itemrev"))
                        n3 = i;
                else if (!strcmp(column_ptr[i], "n_fileco"))
                        n4 = i;
                else if (!strcmp(column_ptr[i], "n_cofilename"))
                        n5 = i;
                else if (!strcmp(column_ptr[i], "p_parttype"))
                        n6 = i;
        }
        if (n1 == -1 || n2 == -1 ||
            n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1) {
PDMdebug("<attach_bufr> Buffer format is incorrect\n");
                return (PDM_E_BUFFER_FORMAT);
        }
       attach_data = (char**)attach_bufr->data_ptr;

for(i=0;i<attach_bufr->rows; i++)
        {
       nxi = i * attach_bufr->columns;
                if ((!strcmp(attach_data[nxi + n4], "Y")) && ((strcmp(attach_data[nxi + n6], "N")) && (strcmp(attach_data[nxi + n6], "n")))) {
       
       status = PDMload_child_info(attach_data[nxi+n1], attach_data[nxi+n2], 
                                   attach_data[nxi+n3]);
       if(status != SQL_S_SUCCESS)
       {
       }
      status = NFMget_sa_no_info(user_id, PDMchild.n_cisano, node_name, 
               user_name, passwd, path_name, device_type, mach_id, op_sys, 
               net_tcp, net_xns, net_dec);
         if(status != NFM_S_SUCCESS)
        {
         sprintf(s, "NFMget_sa_no_info failed status %d\n", status);
         PDMdebug(s);
         MEMclose(&list);
         return(PDM_E_BAD_STRG);
        } 
            
    sprintf(write, "%d\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", PDMchild.n_catalogno, PDMchild.n_itemno, PDMchild.n_fileno, PDMchild.n_cisano, node_name, user_name, passwd, path_name, device_type, mach_id, op_sys, net_tcp, net_xns, net_dec, PDMchild.n_cifilename, PDMchild.n_cofilename, "", "-1", "copy");

       status = MEMwrite(list, write);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr  : status = <0x%.8x>\n", status);
        return (status);
       }
      status = MEMwrite_data(attach_bufr, PDMchild.n_cofilename, i+1, n5+1);
      if(status != MEM_S_SUCCESS)
           {
          sprintf(s, "MEMwrite_data failed status %d\n", status);
          PDMdebug(s);
          return(PDM_E_WRITE_COLUMN);
           }
     }/* if the file is tobe moved */
    }/* for all the rows in the attach bufr */

       status = PDMi_find_storageno(strg_bufr, &to_sano);
       if (status != PDM_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND)
        {
           MEMclose(&list);
           return(PDM_E_BAD_STRG);
        }
               MEMbuild_array(strg_bufr);
               data3 = (char **)strg_bufr->data_ptr;
        if (status == SQL_I_NO_ROWS_FOUND)
            {
            
             status = _NFMadd_temp_sa(user_id, data3[1], data3[2], 
                            data3[3], data3[4]);
                if (status != NFM_S_SUCCESS)
                     {
                       MEMclose(&list);
                       sprintf(s, "_NFMadd_temp_sa failed %d\n", status);
                       return(PDM_E_BAD_STRG);
                     }
                   status = PDMi_find_storageno(strg_bufr, &to_sano);
                 if (status != PDM_S_SUCCESS )
                      {
                          MEMclose(&list);
                          return(PDM_E_BAD_STRG);
                      }
              }
      if(PDMdebug_on)
        MEMprint_buffer("list buffer", list, PDM_DEBUG_FILE);

/* this function loads the global storage area structure with the
   data obtained from nfmstoragearea and nfmnodes table.
   this structure is later used by NFMmv_files_in to construct
   a buffer and append it to the list buffer... */

       status =  PDMXXsa_info (to_sano);
           if (status != NFM_S_SUCCESS)
              {
               MEMclose(&list);
               sprintf(s, "PDMXXsa_info failed status %d\n", status);
               PDMdebug(s);
               return(status);
               }
    
       status = _NFMmv_files_out(user_id, to_sano, data3[3], &list);
           if (status != NFM_S_SUCCESS)
              {
               MEMclose(&list);
               sprintf(s, "NFMmv_files_in failed status %d\n", status);
               PDMdebug(s);
               return(PDM_E_MOVE_FILE);
               }

    PDMdebug("EXIT: PDMcopy_atomic\n");
       return(PDM_S_SUCCESS);


}


int PDMload_copy_buffer(bufr, success_bufr, failure_bufr)
        MEMptr          bufr;
        MEMptr          success_bufr;
        MEMptr          failure_bufr;
{
        char            *fname = "PDMload_copy_buffer";
        int             i, j, nxj, nxi;
        int             n1, n2;
     char            **data = NULL, **column= NULL, **data1=NULL, **data2= NULL;

         _PDMdebug(fname, "ENTER:\n");
        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                return (PDM_E_BUILD_ARRAY);
        }
        status = MEMbuild_array(success_bufr);
        if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                return (PDM_E_BUILD_ARRAY);
        }
        status = MEMbuild_array(failure_bufr);
        if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                return (PDM_E_BUILD_ARRAY);
        }
        _PDMdebug(fname, "after MEMbuild_array\n");
        column = (char **) bufr->column_ptr;
        data = (char **) bufr->data_ptr;
        if(success_bufr->rows > 0)
        data1 = (char **) success_bufr->data_ptr;
        if(failure_bufr->rows > 0)
        data2 = (char **) failure_bufr->data_ptr;
        _PDMdebug(fname, "after setting data pointers\n");
        n1 = -1;
        n2 = -1;
        for (i = 0; i < bufr->columns; i++) {
                if (!strcmp(column[i], "n_cofilename")) n1 = i;
                else if (!strcmp(column[i], "n_action")) n2 = i;
        }
        _PDMdebug(fname, "after setting n1 and n2\n");
        if (n1 == -1 || n2 == -1 ) {
                _PDMdebug(fname, "Couldnot find reqd columns in <bufr>\n");
                return (PDM_E_BUFFER_FORMAT);
        }
        for (i = 0; i < bufr->rows; i++) {
                nxi = i * bufr->columns;
                _PDMdebug(fname, "MEMwrite_data LOCAL count %d\n", i);
                status = MEMwrite_data(bufr, "LOCAL", i + 1, n2 + 1);
                if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite_data failed status %d\n", status);
                        return (PDM_E_WRITE_COLUMN);
                }
        }
           if(PDMdebug_on)
           {
              MEMprint_buffer("copy_bufr", bufr, PDM_DEBUG_FILE);
              MEMprint_buffer("success_bufr", success_bufr, PDM_DEBUG_FILE);
              MEMprint_buffer("failure_bufr", failure_bufr, PDM_DEBUG_FILE);
            }
                _PDMdebug(fname, "After MEMwriting LOCAL <bufr>\n");
        for (i = 0; i < bufr->rows; i++) {
                nxi = i * bufr->columns;
                _PDMdebug(fname, "MEMwrite_data status count %d\n", i);
                        for (j = 0; j < success_bufr->rows; j++)
                      {
                _PDMdebug(fname, "MEMwrite_data status j  %d\n", j);
                       nxj = j * success_bufr->columns;
                if ( !strcmp(data1[nxj], data[nxi + n1] ))
                              {
                _PDMdebug(fname, "MEMwrite_data SUCCESS j  %d\n", j);
                     status = MEMwrite_data(bufr, "SUCCESS", i + 1, n2 + 1);
                                      if (status != MEM_S_SUCCESS)
                               {
                   _PDMdebug(fname, "MEMwrite_data failed status %d\n", status);
                                 return (PDM_E_WRITE_COLUMN);
                               }
                               }
                      }
        }
                _PDMdebug(fname, "After MEMwriting SUCCESS <bufr>\n");
        for (i = 0; i < bufr->rows; i++) {
                nxi = i * bufr->columns;
                _PDMdebug(fname, "MEMwrite_data status count %d\n", i);
                        for (j = 0; j < failure_bufr->rows; j++)
                      {
                _PDMdebug(fname, "MEMwrite_data status j  %d\n", j);
                       nxj = j * failure_bufr->columns;
                if ( !strcmp(data2[nxj], data[nxi + n1] ))
                              {
                _PDMdebug(fname, "MEMwrite_data FAILURE j  %d\n", j);
                     status = MEMwrite_data(bufr, "FAILURE", i + 1, n2 + 1);
                                      if (status != MEM_S_SUCCESS)
                               {
                            _PDMdebug(fname, "MEMwrite_data failed status %d\n", 
                                                        status);
                                 return (PDM_E_WRITE_COLUMN);
                               }
                               }
                      }
        }
         _PDMdebug(fname, "EXIT: \n");
        return (PDM_S_SUCCESS);
}

