#include    <stdio.h>
#include    "PDUerror.h"
#include    "MEMstruct.h"
#include    "MEMerrordef.h"
#include    "NFMerrordef.h"
#include    "SQLerrordef.h"
#include    "PDUris_incl.h"
#include    "NFMfile.h"
#include    "NFMstruct.h"
#include    "PDUstorage.h"
#include    "ERR.h"
#include    "PDMproto.h"
#include    "PDUpdmrpro.h"
#include    "PDMmessage.h"
#include    "PDUnode.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
char     PDMuser[25];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;
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
#include                "NFMfto_buf.h"
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

int PDMcheckout_part (file_bufr, out_file_bufr, attach_bufr)
  MEMptr          file_bufr;
  MEMptr    *out_file_bufr;
  MEMptr    *attach_bufr;
{

  char                          *fn = "PDMcheckout_part";
  char                          **data;
  /*char                        n_cofilename[40];*/
  char                          sql_str[512];
  char                          *msg = NULL;
  MEMptr                        AssyBuf = NULL;
  int		                status1 = -1;
  int		                x, index;
  struct PDUcat_node            *head = NULL;
  struct PDUcat_node            *para_cats = NULL;

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
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (PDMexec->catalog);
                  if (status != NFM_S_SUCCESS) {
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                 sleep (30);
                status = NFMlock_table (PDMexec->catalog);
                  if (status != NFM_S_SUCCESS) {
                 _PDMdebug (fn, "Set Co Out -> Temp In: <0x%.8x>\n", status);
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                   return (status);
                     }
             }
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
      _PDMdebug (fn, "Part is temp in (TI)\n");
      return (PDM_E_TEMP_IN);
                            }
     else if ( !strcmp(PDMpart.n_status,"TO")) {
      _PDMdebug (fn, "Part is temp out (TO)\n");
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
      
  PDMupdate_dots();

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
/* Added check to see if the part was archived.. MaC 041494 */
	if (!strncmp(PDMpart.n_archivestate, "A", 1))  {
		_PDMdebug (fn,  "Part is archived\n");
	PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
		return (PDM_E_PART_ARCHIVED);
           }

  PDMupdate_dots();
  
  file_bufr = NULL;

  status = PDMCheckoutPart (PDMexec->catalog, 
                                  PDMpart.n_catalogno, 
                                  PDMexec->part_num,
                                  PDMexec->revision, 
                                  storage->storage_name,
                                  out_file_bufr);
  if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMCheckoutPart failed 0x%.8x\n", status);
      PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
      return (status);
    }

  
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
  if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
      !strncmp(PDMpart.n_setindicator, "y", 1)) 
*/

  if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
      !strncmp(PDMpart.n_setindicator, "y", 1) ||
      !strncmp(PDMpart.n_setindicator, "A", 1) ||
      !strncmp(PDMpart.n_setindicator, "a", 1)) {
    PDMexec->entity = PDMpart.p_maxlevel;
    status = PDMsget_assembly_structure(&AssyBuf, 0);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMsget_assembly_structure failed 0x%.8x\n", status);
      PDMreset_ncoout(PDMexec->catalog,PDMpart.n_itemno,PDMpart.n_status);
      return (status);
    }

     status = MEMbuild_array (AssyBuf);
     if (status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array failed status 0x.8x\n", status);
       return(PDM_E_BUILD_ARRAY);
     }

   data = (char **) AssyBuf->data_ptr;



    PDMparam_cat_list = NULL;

    for (x = 0; x < AssyBuf->rows; x++) {
      index = AssyBuf->columns * x;
      status = PDMcheck_and_add_cat (data [index + 10]);
      if(status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "Unable to determine the type of %s \n", 
                                                  data [index + 10]);
        _PDMdebug (fn, "But still proceeding...\n");
        }
       }

     status1 = PDMattach_macro_library (storage->storage_name, 
                                             PDMparam_cat_list);
     if (status1 != PDM_S_SUCCESS)
        _PDMdebug (fn,  "PDMattach_macro_library failed status 0x%.8x\n", 
								status);
     para_cats = PDMparam_cat_list;

     /* Free up PDU_param_cat_list */

     if(para_cats != NULL) {
          head = PDMparam_cat_list;
          while (para_cats) {
              para_cats = para_cats->next;
              free(head);
              head = para_cats;
              } /* end while loop */
       }

     PDMparam_cat_list = NULL;


  } else {
    AssyBuf = NULL;
    }
  *attach_bufr = AssyBuf;

  PDMupdate_dots();
  PDMreset_dots();
        
  PDMdebug("EXIT:PDMcheckout_part\n");
  return (PDM_S_SUCCESS);
}



/**********************************************************************/


int PDMCheckoutPart (catalog_name, catalog_no, item_name, 
                                  item_revision, working_area, file_bufr)

char *catalog_name;  /* I: item's catalog */
long catalog_no;     /* I: optional, < 1 if unknown. */
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
char *working_area;  /* I: checkout storage area */
MEMptr *file_bufr;

{

/***
  This function will check out Parent assembly with its associated files.

  CHANGE HISTORY:
    08/8/93 MaC Creation.
***/
  char *fn="PDMCheckoutPart";
  char sql_str[2096], row_str[3072];
  char fcat_name[NFM_CATALOGNAME+3];
  char datetime_str[NFM_CODATE+1];
  char datetime[NFM_CODATE+1];
  char **data;
  char file_status[NFM_STATUS+1], 
       filename[NFM_CIFILENAME+1];
  char lfm_move_str[10], move_str[10];
  int  x, index;
  int q_filetype=2, q_cifilesize=5, 
      q_cifilename=6, q_cisano=7, q_cofilename=8, q_codate=11;
  long file_version;
  long fs_blank=0;
  long item_no;
  long storage_no;
  long status;
  MEMptr file_list=NULL;
  MEMptr list = NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMsto_info *sto_list, *end_sto, *cur_sto, *new_sto;
  struct NFMitem_entry item_entry;

/*
  _PDMdebug (fn, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       user name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name, 
                       NFMglobal.NFMusername);
*/

  strcpy (PDMuser, storage->user_name);
  storage_no = storage->storage_no;
  item_no = PDMpart.n_itemno;
  file_version = PDMpart.n_fileversion;

  sprintf (fcat_name, "f_%s", catalog_name);


  /* set autocommit off */
  status = NFMstop_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug  (fn, "NFMstop_transaction: 0x%.8x\n", status );
    return (status);
  }

/*
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
*/


  /* lock <catalog> and retrieve the item information, check the file status,
     if the item is eligible to be checked out, set file status == TO, commit*/ 

  sprintf (sql_str, "UPDATE %s SET n_status = 'TO' WHERE n_itemno = %d",
                  PDMexec->catalog, PDMpart.n_itemno);

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
           PDUmessage (PDM_E_CON_ACCESS, 's');
          sleep (30);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS) {
           PDUmessage (PDM_E_CON_ACCESS1, 's');
              sleep (30);
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
           PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                   MEMclose (&list);
                   free (sto_list);
      _PDMdebug (fn,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }
    }

  /* lock f_<catalog> and retrieve the file information */
 
/* Already have in PDMpart struct 
  _PDMdebug  (fn, "retrieved max(fileversion) [%d] \n", file_version);
*/

  sprintf (sql_str,
    "select n_fileno, n_filenum, n_filetype, n_fileversion, \
    n_fileco, n_cifilesize, n_cifilename, n_cisano, n_cofilename, \
    n_cosano, n_cidate, n_codate, n_ciuser, n_couser, n_fileclass, \
    n_archiveno from %s where n_itemnum = %d \
    and n_fileversion = (select max(n_fileversion) from %s \
    where n_itemnum = %d )", 
    fcat_name, PDMpart.n_itemno, fcat_name, PDMpart.n_itemno);


   _PDMdebug ("sql_str", "%s\n", sql_str);

   status = SQLquery (sql_str, &list, MEM_SIZE);
   if ( status != SQL_S_SUCCESS ) {
      MEMclose (&list);
      _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
      return (status);
      }
   status = MEMbuild_array(list);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
     return(PDM_E_BUILD_ARRAY);
     }

  if (PDMdebug_on) {
    MEMprint_buffer("list from f_catalog", list, PDM_DEBUG_FILE);
    }

   data = (char **) list->data_ptr;



  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug (fn, "NFMget_datetime failed 0x%.8x\n", status);
    return (status);
  }

  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug (fn, "NFMget_datetime failed 0x%.8x\n", status);
    return (status);
  }

  /* retrieve the storage area information */

  sto_list = end_sto = (struct NFMsto_info *) calloc
                            (1, sizeof (struct NFMsto_info));

  strcpy (sto_list->saname, working_area);

  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
           sto_list->nodename, sto_list->username, sto_list->passwd,
           sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
           sto_list->partition,
           sto_list->nfs, sto_list->compress, sto_list->machid, 
           sto_list->opsys, sto_list->tcpip, sto_list->xns,
           sto_list->decnet, sto_list->netware);

  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    free (sto_list);
    _PDMdebug (fn, "NFMget_storage_info failed 0x%.8x\n", status);
    return (status);
  }

  if ( PDMpart.n_fileversion == 0 && !strlen (PDMpart.n_cofilename))
  {
    _PDMdebug (fn, "this is a CO item in place or CO no file\n");

    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
     if (status != NFM_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
          PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
          PDUmessage (PDM_E_CON_ACCESS1, 's');
                 sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
          PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                   MEMclose (&list);
                   free (sto_list);
      _PDMdebug (fn,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status);
                   return (status);
                     }
             }
        }

    _PDMdebug (fn, "Update the record(s) in %s\n", fcat_name);

/*
    sprintf (sql_str, "%s %s %s %d, %s '%s', %s '%s' %s %d %s %d",
             "update", fcat_name, "set n_cosano =", sto_list->sano, 
             "n_couser = ", NFMglobal.NFMusername, "n_codate = timestamp", 
             datetime,
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      free (sto_list);
      _PDMdebug (fn, "SQLstmt 0x%.8x\n", status);
      return (status);
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      free (sto_list);
      _PDMdebug (fn,"SQLstmt failed 0x%.8x\n", status);
      return (status);
    }

    _PDMdebug (fn, "Update the record in %s \n", catalog_name );
    if (strlen (file_status))
    {
      strcpy (file_status1, "O");
      no_move_file_warning = 1;
    }
    else
    {
      strcpy (file_status1, "ON");
      no_file_warning = 1;
    }

    status = NFMset_item_status (catalog_name, "", "", item_no, 
                                 file_status1, NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
*/
    sprintf (sql_str, "%s %s %s %d, %s '%s', %s '%s' %s %d %s %d",
             "update", fcat_name, "set n_cosano =", sto_list->sano, 
             "n_couser = ", NFMglobal.NFMusername, "n_codate = timestamp", 
             datetime,
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);
/*
      sprintf (sql_str, "%s %s %s %s %s %d %s %d",
             "update", fcat_name, "set n_cosano = NULL",
             "n_couser = NULL, n_codate = NULL", 
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);
      MEMclose (&list);
      free (sto_list);
*/
      _PDMdebug (fn,"NFMset_item_status 0x%.8x\n", status);
      return (status);
/*
    }
*/
  }
  else 
  {
    /* prepare buffer for the file server */
    /* 1st row for out_to_storage */
    if (fs_blank)
    {
      _PDMdebug (fn, "Item's file(s) aren't checked in\n");
      
      free (sto_list);
      return (NFM_E_COI_STATUS_NULL);
    }

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fn, "NFMbuild_fto_buffer 0x%.8x\n", status);
      
      free (sto_list);
      return (status);
    }
    sprintf (row_str, 
     "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
     sto_list->sano,
     sto_list->nodename, sto_list->username, sto_list->passwd, 
     sto_list->pathname, sto_list->devicetype, sto_list->plattername,
     sto_list->partition, sto_list->nfs, sto_list->compress, 
     sto_list->machid, sto_list->opsys, sto_list->tcpip, 
     sto_list->xns, sto_list->decnet,
     sto_list->netware, "\1\1\1\1\1\1\1\1\1");

    _PDMdebug (fn, "MEMwrite %s\n", row_str);

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fn, "MEMwrite (%s) 0x%.8x\n", row_str, status);
      MEMclose (&list);
      MEMclose (&file_list);
      free (sto_list);
      return (status);
    }


    sprintf (lfm_move_str, "%d", NFM_LFM_MOVE);
    sprintf (move_str, "%d", NFM_MOVE);
      _PDMdebug (fn, "move files without consulting LFM\n");
      lfm_files = (struct NFMlfm_file *) NULL;
/* for each file for the part, add a row into the file_list buffer */
   
      for (x = 0; x < list->rows; x++)
      {
        index = list->columns * x;

        /* check out FROM storage area information */
        for (cur_sto = sto_list; cur_sto != (struct NFMsto_info *) NULL; 
             cur_sto = cur_sto->next)
        {
          if (cur_sto->sano == atol (data[index+q_cisano]))
          {
            sprintf (row_str, 
            "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
            cur_sto->sano,
            cur_sto->nodename, cur_sto->username, cur_sto->passwd, 
            cur_sto->pathname, cur_sto->devicetype, cur_sto->plattername,
            cur_sto->partition, cur_sto->nfs, cur_sto->compress, 
            cur_sto->machid,
            cur_sto->opsys, cur_sto->tcpip, cur_sto->xns, cur_sto->decnet,
            cur_sto->netware);
            break;
          } 
        }
        if (cur_sto == (struct NFMsto_info *) NULL)
        {
          new_sto = (struct NFMsto_info *) calloc 
                                              (1, sizeof (struct NFMsto_info));
          new_sto->sano = atol (data[index+q_cisano]);
          status = NFMget_storage_info (new_sto->saname, &(new_sto->sano), 
                   new_sto->nodename,
                   new_sto->username, new_sto->passwd, 
                   new_sto->pathname, new_sto->devicetype,
                   new_sto->plattername, new_sto->partition, 
                   new_sto->nfs, new_sto->compress,
                   new_sto->machid, new_sto->opsys, 
                   new_sto->tcpip, new_sto->xns, new_sto->decnet, 
                   new_sto->netware);

          end_sto->next = new_sto;
          end_sto = new_sto;
          sprintf (row_str, 
          "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
          new_sto->sano, new_sto->nodename, new_sto->username, new_sto->passwd,
          new_sto->pathname, new_sto->devicetype, new_sto->plattername,
          new_sto->partition, new_sto->nfs, new_sto->compress, 
          new_sto->machid, new_sto->opsys, new_sto->tcpip, new_sto->xns, 
          new_sto->decnet, new_sto->netware);
        }
        strcat (row_str, data[index]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        if (strlen (data[index+q_cifilename]))
        {
          strcat (row_str, data[index+q_cifilename]); strcat (row_str, "\1");
        }
        else
        {
          status = NFMget_file_name (NFMglobal.NFMuserid, 
                   catalog_no, atol(data[index]), filename);
          if (status != NFM_S_SUCCESS)
          {
            _PDMdebug (fn, "NFMget_file_name 0x%.8x\n", status);
            MEMclose (&list);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1");
        }
        strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
        strcat (row_str, move_str); strcat (row_str, "\1\1\1");
  
        _PDMdebug (fn, "row_str %s\n", row_str);
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _PDMdebug (fn, "MEMwrite (%s) 0x%.8x\n", row_str, status);
          MEMclose (&list);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          return (status);
        }
      } /* end of for loop */

    if (PDMdebug_on)
      MEMprint_buffer ("file_list", file_list, PDM_DEBUG_FILE);

    status = _NFMfs_recv_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
/*
      _PDMdebug (fn, "_NFMfs_recv_files 0x%.8x\n", status);
      MEMbuild_array (file_list);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      return (status);
*/
      _PDMdebug (fn, "_NFMfs_recv_files 0x%.8x\n", status);
      MEMbuild_array (file_list);
      if (PDMdebug_on)
        MEMprint_buffer ("file transfer buffer", file_list, PDM_DEBUG_FILE);
/*
      NFMdisconnect (&fs_net_id);

      _NFMfs_undo_send_files (&file_list);

      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %s %d %s %d ",
        "update", fcat_name, "set n_fileco = 'N'",
        "where n_itemnum =", item_no, "and n_fileversion =",
        file_version);
      SQLstmt (sql_str);
      SQLstmt ("COMMIT WORK");
*/
      MEMclose (&file_list);
      return (status);

    }

    /* lock the table for updating f_cat*/
  
    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
              PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
               status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
              PDUmessage (PDM_E_CON_ACCESS1, 's');
                 sleep (30);
               status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
              PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fn, "NFMlock_table 0x%.8x\n", status);
                    _NFMfs_undo_recv_files (&file_list);
                     MEMclose (&list);
                     MEMclose (&file_list);
                      return (status);
                     }
             }
        }

    sprintf (sql_str, "%s %s %s %d, %s '%s', %s timestamp '%s', %s %s %d %s %d",
             "update", fcat_name, "set n_cosano =", sto_list->sano,
             "n_couser =", NFMglobal.NFMusername, "n_codate =", datetime, 
             "n_fileco = 'Y'",
             "where n_itemnum =", item_no, "and n_fileversion = ", 
             file_version);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fn, "SQLstmt 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      return (status);
    }

    /* commit the table */

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fn, "SQLstmt(COMMIT WORK) 0x%.8x\n", status);
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1_FCAT);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      return (status);
    }


/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
  if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
                     !strncmp(PDMpart.n_setindicator, "y", 1)) 
*/
  if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
      !strncmp(PDMpart.n_setindicator, "y", 1) ||
      !strncmp(PDMpart.n_setindicator, "A", 1) ||
      !strncmp(PDMpart.n_setindicator, "a", 1)) {
    status = NFMset_item_status (catalog_name, "", "", item_no, "S", 
             NFM_LOCK_COMMIT, "");
      }
  else {
    status = NFMset_item_status (catalog_name, "", "", item_no, "O", 
             NFM_LOCK_COMMIT, "");
    }
 
    if (status != NFM_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      _PDMdebug (fn,"NFMset_item_status failed 0x%.8x\n", status);
      return (status);
    }
  }

  _PDMdebug (fn, "Load processed items/files info into global\n");

    strcpy (item_entry.cat_name, catalog_name);
    item_entry.cat_no = catalog_no;
    strcpy (item_entry.item_name, item_name);
    strcpy (item_entry.item_rev, item_revision);
    strcpy (item_entry.status, file_status);
    item_entry.item_no = item_no;
    item_entry.files = list->rows;
    item_entry.next_item = (struct NFMitem_entry *) NULL;
    item_entry.next_file = (struct NFMfile_entry *) NULL;
    for (x = 0; x < list->rows;  x++)
    {
      status = MEMwrite_data (list, datetime, x + 1, q_codate);
      if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fn, "MEMwrite_data: 0x%.8x\n", status);
      }
    }
    MEMbuild_array (file_list);
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
   
  _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
  MEMclose (&list);
  MEMclose (&file_list);
      
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _PDMdebug (fn, "NFMstart_transaction failed 0x%.8x\n", status);

  /* check the wf_info.workflow and take proper action, such as set_to_state.
     if anything goes wrong in set_to_state, the item is NOT ROLLED BACK */
   
  status = PDMCoUpdateFilemgrForPart ( PDMexec->catalog, 
                                           PDMexec->part_num,
                                           PDMexec->revision,
                                           PDMpart.n_catalogno,
                                           PDMpart.n_itemno, 
                                           storage_no, file_bufr);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
                NFMfree_item_file_information (NFMitem_files);
       /*goto cleanup;*/
       }


  _PDMdebug  (fn,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS );
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



/*
int PDMcancel_checkout_part(delete_list, attach_list, 
                                       child_bufr, para_cats, mul_files)
*/

int PDMcancel_checkout_part(delete_list, attach_list, 
                                       para_cats, mul_files)
MEMptr          *delete_list;
MEMptr          attach_list;
MEMptr          *mul_files;
struct  PDUcat_node *para_cats;
{
  char      *fn = "PDMcancel_checkout_part";
  char              p_assembly[5];
  char               *p_coout;
  int               p_partno, p_catalogno;
  char      sql_str[512];
  char      s[512];
  int      wrapup_status;
  int      storage_no;
  int      AssyFlag;
  int      err_status;
  char     *msg = NULL;
  /*MEMptr      tmp_delete_list = NULL;*/

       
  PDMdebug("ENTER: PDMcancel_checkout_part:\n");

  msg = (char *)PDUtranslate_message(PDS_M_CANCEL_CHECKOUT_PART);
  strcpy(glob_var,msg);
  s[0] = '\0';

  status = MEMbuild_array(attach_list);
       /* Added by kumar - 3.27.93 to fix atomic cancel part checkout */
  if (status != MEM_S_SUCCESS 
               && status != MEM_E_NULL_BUFFER 
                     && status != MEM_E_NULL_LIST) {
    _PDMdebug (fn, "MEMbuild_array failed status -> %d", status);
    return (PDM_E_BUILD_ARRAY);
    }

   _PDMdebug (fn, "Printing the attach_list\n");
   if(PDMdebug_on) {
           MEMprint_buffer ("attach_list BUFFER", attach_list, PDM_DEBUG_FILE);
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

  status = MEMopen (delete_list, 512);
  if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEM Open : failed status : %lx\n", status);
         return (NFM_E_MEM);
       }

  status = MEMwrite_format (*delete_list, "n_cofilename", "char(128)");
  if (status != MEM_S_SUCCESS) {
            MEMclose (delete_list);
            _PDMdebug (fn, "MEM Wr For : failed status %lx\n", status);
            return (NFM_E_MEM);
          }

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

  AssyFlag = 0;

  if ( (!strncmp(p_assembly, "Y", 1) ||
      !strncmp(p_assembly, "y", 1)) || (attach_list != NULL) ) {

/* set n_status to O so that we can use cancel item instead of cancel set */

       AssyFlag = 1;
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

       status = PDMCancelCheckoutPart (PDMexec->catalog, 
                                          PDMpart.n_catalogno,
                                          PDMexec->part_num, 
                                          PDMexec->revision, 
				          storage->storage_name, delete_list);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn,  "PDMCancelCheckoutPart failed status 0x%.8x\n", status);
      goto wrapup;
    }

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


/*

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

        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn,  "%s %d\n",
                    "PDMco_item_update_filemanager failed status ", status);
                goto wrapup;
        }

        PDMupdate_dots();
*/

/*
  if (AssyFlag != 1) {
  status = PDMCancelCoUpdateFilemgrForPart ( PDMexec->catalog, 
                                           PDMexec->part_num,
                                           PDMexec->revision,
                                           PDMpart.n_catalogno,
                                           PDMpart.n_itemno, 
                                           storage_no, delete_list);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
       }
   }
  else { 
  status = PDMCancelCoUpdateFilemgrForAssy ( PDMexec->catalog,
                                             PDMexec->part_num,
                                             PDMexec->revision,
                                             PDMpart.n_catalogno,
                                             PDMpart.n_itemno,
                                             storage_no, attach_list,
                                             delete_list);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
       }
   }
*/

  if (AssyFlag == 1) {
  status = PDMCancelCoUpdateFilemgrForAssy ( PDMexec->catalog,
                                             PDMexec->part_num,
                                             PDMexec->revision,
                                             PDMpart.n_catalogno,
                                             PDMpart.n_itemno,
                                             storage_no, attach_list,
                                             delete_list);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
       }
   }

  status = PDMstart_transaction(1200);
  if (status != PDM_S_SUCCESS) {
     _PDMdebug (fn,  "PDMstart_transaction failed status %d\n", status);
     goto wrapup;
  }

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


int PDMundo_part_file_co_changes (file_bufr)
MEMptr  *file_bufr;
{

 char    *fn = "PDMundo_part_file_co_changes";
 char    mem_str [512];
 char    sql_str [512];
 MEMptr    file_list = NULL;
 int    index, i;
 char    **list_data;


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


/***
  This function will check out an item with its associated files.

  CHANGE HISTORY:
    08/28/91 mfb Creation.
***/

long PDMRetrieveAssyFiles ( assy_buf, status_buffer)
MEMptr  assy_buf, *status_buffer;
{
  char *fn="PDMRetrieveAssyFiles";

  _PDMdebug  (fn,"ENTER:\n");

  if (PDMdebug_on) {
    MEMprint_buffer("assy_buf", assy_buf, PDM_DEBUG_FILE);
    }

    _PDMdebug (fn, "Calling PDMcopy_attach...\n");
    status = PDMcopy_attach( assy_buf, status_buffer);
    if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMcopy_attach failed 0x%.8x\n", status );
  /* Fix added to check to see if ci files could not be found..MaC*/
       if (status == NFM_E_STAT_CI_FILENAME)
          return (PDM_E_COPY_FILES);
       return (status);
      }

  if (PDMdebug_on) {
    MEMprint_buffer("status_buffer", *status_buffer, PDM_DEBUG_FILE);
    }

  _PDMdebug  (fn,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}




int PDMCancelCheckoutPart (catalog_name, catalog_no, item_name, 
                                  item_revision, working_area, delete_list)

char *catalog_name;  /* I: item's catalog */
long catalog_no;     /* I: optional, < 1 if unknown. */
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
char *working_area; 
MEMptr *delete_list;
{

/***
  This function will cancel check out part 

  CHANGE HISTORY:
    08/8/93 MaC Creation.
***/
  char *fn="PDMCancelCheckoutPart";
  char sql_str[2096];
  char fcat_name[NFM_CATALOGNAME+3];
  long item_no;
  long storage_no;
  long status;

  long file_version;



/*
  _PDMdebug (fn, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       user name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name, 
                       NFMglobal.NFMusername);
*/
  _PDMdebug (fn, "Enter\n");

  _PDMdebug (fn, "catno[%d], itemname[%s], rev[%s], working_area[%s]\n",
                   catalog_no, item_name, item_revision, working_area);

  strcpy (PDMuser, storage->user_name);
  storage_no = storage->storage_no;
  item_no = PDMpart.n_itemno;
  file_version = PDMpart.n_fileversion;

  sprintf (fcat_name, "f_%s", catalog_name);


  /* set autocommit off */
  status = NFMstop_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug  (fn, "NFMstop_transaction: 0x%.8x\n", status );
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


  /* lock <catalog> and retrieve the item information, check the file status,
     if the item is eligible to be checked out, set file status == TO, commit*/ 

  sprintf (sql_str, "UPDATE %s SET n_status = 'I' WHERE n_itemno = %d",
                      PDMexec->catalog, PDMpart.n_itemno);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS) {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }


  sprintf (sql_str, "UPDATE %s SET n_fileco = 'N' WHERE n_itemnum = %d",
                      fcat_name, PDMpart.n_itemno);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS) {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }

  status = NFMstart_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug  (fn, "NFMstop_transaction: 0x%.8x\n", status );
    return (status);
  }
/* This needs to be in called function .. */
  status = PDMCancelCoUpdateFilemgrForPart ( PDMexec->catalog, 
                                           PDMexec->part_num,
                                           PDMexec->revision,
                                           PDMpart.n_catalogno,
                                           PDMpart.n_itemno, 
                                           storage_no, delete_list);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
        NFMfree_item_file_information (NFMitem_files);
       }

  _PDMdebug  (fn,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}






int PDMOLDCancelCheckoutPart (catalog_name, catalog_no, item_name, 
                                  item_revision, working_area)

char *catalog_name;  /* I: item's catalog */
long catalog_no;     /* I: optional, < 1 if unknown. */
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
char *working_area;  /* I: checkout storage area */
/*MEMptr *file_bufr;*/
{

/***
  This function will cancel check out part 

  CHANGE HISTORY:
    08/8/93 MaC Creation.
***/
  char *fn="PDMCancelCheckoutPart";
  char sql_str[2096], row_str[3072];
  char fcat_name[NFM_CATALOGNAME+3];
  char **data;
  int  x, index;
  long item_no;
  long storage_no;
  long status;
  MEMptr file_list=NULL;
  MEMptr list = NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMsto_info *sto_list, *end_sto, *cur_sto, *new_sto;
  struct NFMitem_entry item_entry;

  char datetime[NFM_CODATE+1];
  char file_status[NFM_STATUS+1],
       filename[NFM_CIFILENAME+1];
  char lfm_move_str[10], move_str[10];
  int q_filetype=2, q_cifilesize=5,
      q_cifilename=6, q_cisano=7, q_cofilename=8, q_codate=11;
  long file_version;
  long fs_blank=0;



/*
  _PDMdebug (fn, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       user name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name, 
                       NFMglobal.NFMusername);
*/
  _PDMdebug (fn, "Enter\n");

  strcpy (PDMuser, storage->user_name);
  storage_no = storage->storage_no;
  item_no = PDMpart.n_itemno;
  file_version = PDMpart.n_fileversion;

  sprintf (fcat_name, "f_%s", catalog_name);


  /* set autocommit off */
  status = NFMstop_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug  (fn, "NFMstop_transaction: 0x%.8x\n", status );
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


  /* lock <catalog> and retrieve the item information, check the file status,
     if the item is eligible to be checked out, set file status == TO, commit*/ 

  sprintf (sql_str, "UPDATE %s SET n_status = 'I' WHERE n_itemno = %d",
                  PDMexec->catalog, PDMpart.n_itemno);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS) {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }

  status = NFMstart_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug  (fn, "NFMstop_transaction: 0x%.8x\n", status );
    return (status);
  }
 

  sprintf (sql_str,
    "select n_fileno, n_filenum, n_filetype, n_fileversion, \
    n_fileco, n_cifilesize, n_cifilename, n_cisano, n_cofilename, \
    n_cosano, n_cidate, n_codate, n_ciuser, n_couser, n_fileclass, \
    n_archiveno from %s where n_itemnum = %d \
    and n_fileversion = (select max(n_fileversion) from %s \
    where n_itemnum = %d )", 
    fcat_name, PDMpart.n_itemno, fcat_name, PDMpart.n_itemno);


   _PDMdebug ("sql_str", "%s\n", sql_str);

   status = SQLquery (sql_str, &list, MEM_SIZE);
   if ( status != SQL_S_SUCCESS ) {
      MEMclose (&list);
      _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
      return (status);
      }
   status = MEMbuild_array(list);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
     return(PDM_E_BUILD_ARRAY);
     }

  if (PDMdebug_on) {
    MEMprint_buffer("list from f_catalog", list, PDM_DEBUG_FILE);
    }

   data = (char **) list->data_ptr;


  /* retrieve the storage area information */

  sto_list = end_sto = (struct NFMsto_info *) calloc
                            (1, sizeof (struct NFMsto_info));

  strcpy (sto_list->saname, working_area);

  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
           sto_list->nodename, sto_list->username, sto_list->passwd,
           sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
           sto_list->partition,
           sto_list->nfs, sto_list->compress, sto_list->machid, 
           sto_list->opsys, sto_list->tcpip, sto_list->xns,
           sto_list->decnet, sto_list->netware);

  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    free (sto_list);
    _PDMdebug (fn, "NFMget_storage_info failed 0x%.8x\n", status);
    return (status);
  }

  if ( PDMpart.n_fileversion == 0 && !strlen (PDMpart.n_cofilename))
  {
    _PDMdebug (fn, "this is a CO item in place or CO no file\n");

    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
     if (status != NFM_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
            PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
            PDUmessage (PDM_E_CON_ACCESS1, 's');
                 sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
            PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    MEMclose (&list);
                   free (sto_list);
      _PDMdebug (fn,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status);
                   return (status);
                     }
             }
        }

    _PDMdebug (fn, "Update the record(s) in %s\n", fcat_name);

/*
*/
    sprintf (sql_str, "%s %s %s %d, %s '%s', %s '%s' %s %d %s %d",
             "update", fcat_name, "set n_cosano =", sto_list->sano, 
             "n_couser = ", NFMglobal.NFMusername, "n_codate = timestamp", 
             datetime,
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);
/*
      sprintf (sql_str, "%s %s %s %s %s %d %s %d",
             "update", fcat_name, "set n_cosano = NULL",
             "n_couser = NULL, n_codate = NULL", 
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);
      MEMclose (&list);
      free (sto_list);
*/
      _PDMdebug (fn,"NFMset_item_status 0x%.8x\n", status);
      return (status);
/*
    }
*/
  }
  else 
  {
    /* prepare buffer for the file server */
    /* 1st row for out_to_storage */
    if (fs_blank)
    {
      _PDMdebug (fn, "Item's file(s) aren't checked in\n");
      
      free (sto_list);
      return (NFM_E_COI_STATUS_NULL);
    }

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fn, "NFMbuild_fto_buffer 0x%.8x\n", status);
      
      free (sto_list);
      return (status);
    }
    sprintf (row_str, 
     "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
     sto_list->sano,
     sto_list->nodename, sto_list->username, sto_list->passwd, 
     sto_list->pathname, sto_list->devicetype, sto_list->plattername,
     sto_list->partition, sto_list->nfs, sto_list->compress, 
     sto_list->machid, sto_list->opsys, sto_list->tcpip, 
     sto_list->xns, sto_list->decnet,
     sto_list->netware, "\1\1\1\1\1\1\1\1\1");

    _PDMdebug (fn, "MEMwrite %s\n", row_str);

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fn, "MEMwrite (%s) 0x%.8x\n", row_str, status);
      MEMclose (&list);
      MEMclose (&file_list);
      free (sto_list);
      return (status);
    }


    sprintf (lfm_move_str, "%d", NFM_LFM_MOVE);
    sprintf (move_str, "%d", NFM_MOVE);
      _PDMdebug (fn, "move files without consulting LFM\n");
      lfm_files = (struct NFMlfm_file *) NULL;
/* for each file for the part, add a row into the file_list buffer */
   
      for (x = 0; x < list->rows; x++)
      {
        index = list->columns * x;

        /* check out FROM storage area information */
        for (cur_sto = sto_list; cur_sto != (struct NFMsto_info *) NULL; 
             cur_sto = cur_sto->next)
        {
          if (cur_sto->sano == atol (data[index+q_cisano]))
          {
            sprintf (row_str, 
            "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
            cur_sto->sano,
            cur_sto->nodename, cur_sto->username, cur_sto->passwd, 
            cur_sto->pathname, cur_sto->devicetype, cur_sto->plattername,
            cur_sto->partition, cur_sto->nfs, cur_sto->compress, 
            cur_sto->machid,
            cur_sto->opsys, cur_sto->tcpip, cur_sto->xns, cur_sto->decnet,
            cur_sto->netware);
            break;
          } 
        }
        if (cur_sto == (struct NFMsto_info *) NULL)
        {
          new_sto = (struct NFMsto_info *) calloc 
                                              (1, sizeof (struct NFMsto_info));
          new_sto->sano = atol (data[index+q_cisano]);
          status = NFMget_storage_info (new_sto->saname, &(new_sto->sano), 
                   new_sto->nodename,
                   new_sto->username, new_sto->passwd, 
                   new_sto->pathname, new_sto->devicetype,
                   new_sto->plattername, new_sto->partition, 
                   new_sto->nfs, new_sto->compress,
                   new_sto->machid, new_sto->opsys, 
                   new_sto->tcpip, new_sto->xns, new_sto->decnet, 
                   new_sto->netware);

          end_sto->next = new_sto;
          end_sto = new_sto;
          sprintf (row_str, 
          "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
          new_sto->sano, new_sto->nodename, new_sto->username, new_sto->passwd,
          new_sto->pathname, new_sto->devicetype, new_sto->plattername,
          new_sto->partition, new_sto->nfs, new_sto->compress, 
          new_sto->machid, new_sto->opsys, new_sto->tcpip, new_sto->xns, 
          new_sto->decnet, new_sto->netware);
        }
        strcat (row_str, data[index]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        if (strlen (data[index+q_cifilename]))
        {
          strcat (row_str, data[index+q_cifilename]); strcat (row_str, "\1");
        }
        else
        {
          status = NFMget_file_name (NFMglobal.NFMuserid, 
                   catalog_no, atol(data[index]), filename);
          if (status != NFM_S_SUCCESS)
          {
            _PDMdebug (fn, "NFMget_file_name 0x%.8x\n", status);
            MEMclose (&list);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1");
        }
        strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
        strcat (row_str, move_str); strcat (row_str, "\1\1\1");
  
        _PDMdebug (fn, "row_str %s\n", row_str);
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _PDMdebug (fn, "MEMwrite (%s) 0x%.8x\n", row_str, status);
          MEMclose (&list);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          return (status);
        }
      } /* end of for loop */

    if (PDMdebug_on)
      MEMprint_buffer ("file_list", file_list, PDM_DEBUG_FILE);

    status = _NFMfs_recv_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fn, "_NFMfs_recv_files 0x%.8x\n", status);
      MEMbuild_array (file_list);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      return (status);
    }

    /* lock the table for updating f_cat*/
  
    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
     if (status != NFM_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
            PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
            PDUmessage (PDM_E_CON_ACCESS1, 's');
                 sleep (30);
                status = NFMlock_table (fcat_name);
                  if (status != NFM_S_SUCCESS) {
            PDUmessage (PDM_E_CON_TRY_LATER, 's');
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                   _PDMdebug (fn, "NFMlock_table 0x%.8x\n", status);
                   _NFMfs_undo_recv_files (&file_list);
                   MEMclose (&list);
                   MEMclose (&file_list);
                   return (status);
                     }
             }
        }

    sprintf (sql_str, "%s %s %s %d, %s '%s', %s timestamp '%s', %s %s %d %s %d",
             "update", fcat_name, "set n_cosano =", sto_list->sano,
             "n_couser =", NFMglobal.NFMusername, "n_codate =", datetime, 
             "n_fileco = 'Y'",
             "where n_itemnum =", item_no, "and n_fileversion = ", 
             file_version);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fn, "SQLstmt 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      return (status);
    }

    /* commit the table */

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fn, "SQLstmt(COMMIT WORK) 0x%.8x\n", status);
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1_FCAT);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      return (status);
    }

    status = NFMset_item_status (catalog_name, "", "", item_no, "O", 
             NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      _PDMdebug (fn,"NFMset_item_status failed 0x%.8x\n", status);
      return (status);
    }
  }

  _PDMdebug (fn, "Load processed items/files info into global\n");

    strcpy (item_entry.cat_name, catalog_name);
    item_entry.cat_no = catalog_no;
    strcpy (item_entry.item_name, item_name);
    strcpy (item_entry.item_rev, item_revision);
    strcpy (item_entry.status, file_status);
    item_entry.item_no = item_no;
    item_entry.files = list->rows;
    item_entry.next_item = (struct NFMitem_entry *) NULL;
    item_entry.next_file = (struct NFMfile_entry *) NULL;
    for (x = 0; x < list->rows;  x++)
    {
      status = MEMwrite_data (list, datetime, x + 1, q_codate);
      if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fn, "MEMwrite_data: 0x%.8x\n", status);
      }
    }
    MEMbuild_array (file_list);
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
   
  _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
  MEMclose (&list);
  MEMclose (&file_list);
      
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _PDMdebug (fn, "NFMstart_transaction failed 0x%.8x\n", status);

  /* check the wf_info.workflow and take proper action, such as set_to_state.
     if anything goes wrong in set_to_state, the item is NOT ROLLED BACK */
   
  status = PDMCoUpdateFilemgrForPart ( PDMexec->catalog, 
                                           PDMexec->part_num,
                                           PDMexec->revision,
                                           PDMpart.n_catalogno,
                                           PDMpart.n_itemno, 
                                           storage_no, file_list);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn,  "%s %d\n",
           "PDMco_update_filemanager failed ", status);
                NFMfree_item_file_information (NFMitem_files);
       /*goto cleanup;*/
       }


  _PDMdebug  (fn,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}

