#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "WFstruct.h"
#include "MSGstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "NFMproto.h"


extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern long NFM_FTR_INITED;
extern struct WFstruct WFinfo;
extern long special_msg; 

long NFMcheckout_item (catalog_name, catalog_no, item_name, item_revision,
                       working_area, wf_info, operation)

/***
  This function will check out an item with its associated files.

  Note: operation.delete and operation.purge will be ignored.

***/

char *catalog_name;  /* I: item's catalog */
long catalog_no;     /* I: optional, < 1 if unknown. */
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
char *working_area;  /* I: checkout storage area */
struct NFMwf_info wf_info; /* I: turn on/off validation and set_to_state */
struct NFMoperation operation; /* I: file transfer mode */

{
  char *fname="NFMcheckout_item";
  char sql_str[1024], ins_str[1024], row_str[3072], w_clause[1024];
  char fcat_name[NFM_CATALOGNAME+3];
  char datetime_str[NFM_CODATE+1];
  char datetime[NFM_CODATE+1];
  char **data, **data1;
  char file_status1[NFM_STATUS+1];
  char file_status[NFM_STATUS+1], 
       filename[NFM_CIFILENAME+1];
  char dumb_str[1024], error_msg[1024];
  char lfm_move_str[10], move_str[10], itemdesc[NFM_ITEMDESC+1];
  long  x, index, nothing;
  int subsystem;
  long q_filenum=1, q_filetype=2, q_fileversion=3, q_cifilesize=5, 
      q_cifilename=6, q_cisano=7, q_cofilename=8, q_codate=11;
  long file_version, error_no, q_itemdesc=6;
  long fs_blank=0;
  long item_no;
  long ret_status, status;
  long degree, native_and_raster=0;
  long dumb_value;
  long no_move_file_warning = 0, no_file_warning = 0;
  MEMptr list=NULL, list1=NULL, file_list=NULL, dumb_list=NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMsto_info *sto_list, *end_sto, *cur_sto, *new_sto;
  struct NFMitem_entry item_entry;
  char   theItemName[100];  /* PS 11 dec 95 */
  char   theItemRevision[100];
 
  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] user name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name, 
                       operation.transfer, operation.delete, operation.purge,
                       NFMglobal.NFMusername));
  sprintf (fcat_name, "f_%s", catalog_name);


  /* check the wf_info.workflow and take proper actions, such as validating.
     if validating fails, needs to call set_to_state */

  if (wf_info.workflow)
  {
    status = WFvalidate_user_access (NFMglobal.NFMuserid, wf_info.command,
             wf_info.workflow_name, wf_info.project_name,
             catalog_name, item_name, item_revision);
    if (status != NFM_S_SUCCESS)
    {
      degree = 0;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
      return (status);
    }
  }

  /* set autocommit off */
  status = NFMstop_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMstop_transaction: 0x%.8x\n", status) );
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }


  /* lock <catalog> and retrieve the item information, check the file status,
     if the item is eligible to be checked out, set file status == TO, commit*/ 
/* PS - tick the item name and revision */
 
   NFMtic_to_tics(item_name, theItemName);
   NFMtic_to_tics(item_revision, theItemRevision);
/*
  sprintf (w_clause, "%s '%s' %s '%s'",
    "where n_itemname = ", item_name, "and n_itemrev = ",
    item_revision);
*/

  sprintf (w_clause, "%s '%s' %s '%s'",
    "where n_itemname = ", theItemName, "and n_itemrev = ",
    theItemRevision);

  status = NFMcommon_queries (catalog_name, w_clause, 
                              dumb_str, &dumb_value, &list, 
                              NFM_ITEM_QUERY, NFM_RETURN_MEMPTR,
                              NFM_LOCK_NO_COMMIT);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 5;
    if (DM_MANAGER)
    {
      _DMcall_do_nothing (2);
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve document's information");
    }
    else
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve item's information");
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ( (fname, "NFMcommon_queries  0x%.8x\n", status) );
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

  data = (char **)list->data_ptr;
  item_no = atol (data[0]);
  strncpy (file_status, data[1], NFM_STATUS);
  strncpy (itemdesc, data[q_itemdesc], NFM_ITEMDESC);
  itemdesc[NFM_ITEMDESC] = '\0';

  status = NFMcheck_catalog_attributes (item_name, item_revision, 
                                        list, NFM_CHECK_OUT);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcheck_catalog_attributes 0x%.8x\n", status));
    degree = 5;
    _NFMcleanup (&degree, wf_info, "", "", "");
    MEMclose (&list);
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }

  MEMclose (&list);

  if (!strlen (file_status))
    fs_blank = 1;

  status = NFMset_item_status (catalog_name, "", "", item_no, "TO", 
                               NFM_COMMIT_ONLY, "");
  if (status != NFM_S_SUCCESS)
  {
    degree = 7;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ( (fname, "NFMset_item_status [%d] [%s] failed 0x%.8x\n",
                 item_no, "TO") );
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }

  /* lock f_<catalog> and retrieve the file information */
 
  sprintf (w_clause, "%s %d %s %s %s %d %s",
           "where n_itemnum =", item_no,
           "and n_fileversion = (select max(n_fileversion) from ", fcat_name,
           "where n_itemnum = ", item_no, ") order by n_filetype ASC");

  status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value, 
                               &list, NFM_ITEM_FILE_QUERY, 
                               NFM_RETURN_MEMPTR, NFM_LOCK_COMMIT);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve file information");
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ( (fname, "NFMcommon_queries 0x%.8x\n", status));
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

  data = (char **) list->data_ptr;

  /* 10/31/94 check for native_and_raster */

  if (list->rows == 2)
  {
    if ( ( (strcmp (data[q_filetype], "DOCN") == 0) &&
           (strcmp (data[list->columns+q_filetype], "DOCR") == 0) ) ||
         ( (strcmp (data[q_filetype], "WPN") == 0) &&
           (strcmp (data[list->columns+q_filetype], "WPR") == 0)  ) ||
         ( (strcmp (data[q_filetype], "LOTN") == 0) &&
           (strcmp (data[list->columns+q_filetype], "LOTR") == 0) ) ||
         ( (strcmp (data[q_filetype], "XLSN") == 0) &&
           (strcmp (data[list->columns+q_filetype], "XLSR") == 0) )    )
    {
      native_and_raster = 1;
      _NFMdebug ((fname, "Special item has a native file and a raster file\n"));
    }
    else
    {
      native_and_raster = 0;
      _NFMdebug ((fname, "file 1 type = %s, file 2 type = %s\n",
                  data[3], data[list->columns+3]));
    }
  }
  else
  {
    native_and_raster = 0;
    _NFMdebug ((fname, "%d files associated\n", list->rows));
  }

  /* end of 10/31/94 */

  file_version = atol (data[q_fileversion]);

  _NFMdebug ((fname, "retrieved max(fileversion) [%d] \n", file_version));

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }

  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
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
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
      if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }

  if (!DM_MANAGER && (strcmp (sto_list->machid, "PC") == 0) &&
       (strcmp (sto_list->opsys, "WINDOS") == 0)                )
  {
    MEMclose (&list);
    free (sto_list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "cannot check out to DMM node\n"));
    ERRload_struct (NFM, NFM_E_CO_DMM_NODE, "", NULL);
    return ( NFM_E_CO_DMM_NODE);
  }



  /* if operation.transfer == NFM_NO_TRANSFER, update <catalog> and 
     f_<catalog> */

  if (operation.transfer == NFM_NO_TRANSFER ||
      (list->rows == 1 && atol (data[q_fileversion]) == 0 &&
        !strlen(data[q_cofilename]) ))
  {
    _NFMdebug ((fname, "this is a CO item in place or CO no file\n"));

    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      MEMclose (&list);
      free (sto_list);
      _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status));
      if (DM_MANAGER)
      _DMcall_do_nothing(2);
      return (status);
    }

    _NFMdebug ((fname, "Update the record(s) in %s\n", fcat_name));

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
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing(2);
      return (status);
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      free (sto_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname,"SQLstmt failed 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing(2);
      return (status);
    }

    _NFMdebug ((fname, "Update the record in %s \n", catalog_name ));
    _NFMdebug ((fname, "file_status is %s \n", file_status ));

    if (strlen (file_status))
    {
      strncpy (file_status1, "O", NFM_STATUS);
      no_move_file_warning = 1;
    }
    else
    {
      strncpy (file_status1, "ON", NFM_STATUS);
      no_file_warning = 1;
    }

    if (DM_MANAGER)
      _DMdo_nothing ();

    status = NFMset_item_status (catalog_name, "", "", item_no, 
                                 file_status1, NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      sprintf (sql_str, "%s %s %s %s %s %d %s %d",
             "update", fcat_name, "set n_cosano = NULL",
             "n_couser = NULL, n_codate = NULL", 
             "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version);
      MEMclose (&list);
      free (sto_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname,"NFMset_item_status 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing(2);
      return (status);
    }
  }
  else 
  {
    /* prepare buffer for the file server */
    /* 1st row for out_to_storage */
    if (fs_blank)
    {
      _NFMdebug ((fname, "Item's file(s) aren't checked in\n"));
      ERRload_struct (NFM, NFM_E_COI_STATUS_NULL, "%s%s", 
                      item_name, item_revision);
      MEMclose(&list);
      free (sto_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
      return (NFM_E_COI_STATUS_NULL);
    }

    status = _DMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
      MEMclose(&list);
      free (sto_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing(2);
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
     sto_list->netware, "\1\1\1\1\1\1\1\1\1\1\1\1\1");

    _NFMdebug ((fname, "MEMwrite %s\n", row_str));

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&list);
      MEMclose (&file_list);
      free (sto_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing(2);
      return (status);
    }


    if (catalog_no < 1)
    {
      if (wf_info.workflow)
      {
        catalog_no = WFinfo.catalog_no;
      }
      else
      {
        sprintf (sql_str, "%s '%s'",
                 "select n_catalogno from nfmcatalogs where n_catalogname =",
                 catalog_name);
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str, 
                  &catalog_no, &dumb_list);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
          free (lfm_files);
          MEMclose (&list);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
          degree = 3;
          if (DM_MANAGER)
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                          "Failed to retrieve cabinet information");
          else
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                          "Failed to retrieve catalog information");
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
            _DMcall_do_nothing(2);
            return (status);
        }
      }
    }

    sprintf (lfm_move_str, "%d", NFM_LFM_MOVE);
    sprintf (move_str, "%d", NFM_MOVE);

    if (operation.transfer == NFM_CONDITIONAL_TRANSFER )
    {
      lfm_files = (struct NFMlfm_file *) calloc (list->rows, 
                    sizeof (struct NFMlfm_file));
      if (lfm_files == (struct NFMlfm_file *) NULL)
      {
        _NFMdebug ((fname, "Failed to malloc\n"));
        MEMclose (&list);
        MEMclose (&file_list);
        free (sto_list);
        degree = 3;
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                        "Failed to allocate memory");
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
        _DMcall_do_nothing(2);
        return (NFM_E_MALLOC);
      }
      for (x = 0; x < list->rows; x++)
      {
        index = list->columns * x;
        /* query lfm */
        sprintf (sql_str, "%s %d %s '%s' %s %d %s %d %s %s",
                 "select n_co from nfmsafiles where n_sano =", sto_list->sano,
                 "and n_filename =", data[index+q_cofilename], 
                 "and n_catalogno =",
                 catalog_no, "and n_itemno =", item_no, "and n_filenum =",
                 data[index+q_filenum]);
 
        status = NFMlock_table ("nfmsafiles");
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
          free (lfm_files);
          MEMclose (&list);
          MEMclose (&list1);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
           _DMcall_do_nothing(2);
          return (status);
        }
        status = SQLquery (sql_str, &list1, MEM_SIZE);
        if (status == SQL_S_SUCCESS)
        {
          SQLstmt ("COMMIT WORK");
          (lfm_files+x)->action = NFM_UPDATE_CO; /* update the entry only */
          MEMclose (&list1);
        }
        else if ( status == SQL_I_NO_ROWS_FOUND)
        {
          SQLstmt ("COMMIT WORK");
          (lfm_files+x)->action = NFM_ADD_CO; /* add to the table */
          MEMclose (&list1);
        }
        else
        {
          SQLstmt ("COMMIT WORK");
          _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
          free (lfm_files);
          MEMclose (&list);
          MEMclose (&list1);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
           _DMcall_do_nothing(2);
          return (status);
        }
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
            cur_sto->partition, cur_sto->nfs, cur_sto->compress, cur_sto->machid,
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
                   new_sto->nodename, new_sto->username, new_sto->passwd, 
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
          new_sto->sano, new_sto->nodename, new_sto->username, 
          new_sto->passwd, new_sto->pathname, new_sto->devicetype, 
          new_sto->plattername,
          new_sto->partition, new_sto->nfs, new_sto->compress, new_sto->machid, 
          new_sto->opsys, new_sto->tcpip, new_sto->xns, new_sto->decnet,
          new_sto->netware);
        }
        strcat (row_str, data[index]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        if (strlen (data[index+q_cifilename]))
        {
          strcat (row_str, data[index+q_cifilename]); strcat (row_str, "\1");
        }
        else
        {
          status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, 
                                     atol(data[index]), 
                                     filename);
          if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            free (lfm_files);
            MEMclose (&list);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            degree = 3;
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
           if (DM_MANAGER)  
        _DMcall_do_nothing(2);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1");
        }
        strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
        if ( (lfm_files+x)->action == NFM_ADD_CO)
        {
          if (native_and_raster &&
              ( strcmp (data[index+q_filetype], "DOCR") == 0 ||
                strcmp (data[index+q_filetype], "WPR")  == 0 ||
                strcmp (data[index+q_filetype], "LOTR") == 0 ||
                strcmp (data[index+q_filetype], "XLSR") == 0   ) )
            strcat (row_str, "");
          else
            strcat (row_str, lfm_move_str);
          strcat (row_str, "\1\1\1");
        }
        else
        {
          if (native_and_raster &&
              ( strcmp (data[index+q_filetype], "DOCR") == 0 ||
                strcmp (data[index+q_filetype], "WPR")  == 0 ||
                strcmp (data[index+q_filetype], "LOTR") == 0 ||
                strcmp (data[index+q_filetype], "XLSR") == 0   ) )
            strcat (row_str, "");
          else
            strcat (row_str, move_str);
          strcat (row_str, "\1\1\1");
        }

        if (DM_MANAGER)
        {
          sprintf (dumb_str, "%s\1%d\1%s\1%s\1%s\1", catalog_name, item_no,
                   item_revision, item_name, itemdesc);
          strcat (row_str, dumb_str);
          NFMparse_local_filename (data[index+q_cofilename]);
        }
        else
        {
          strcat (row_str, "\1\1\1\1\1");
        }

        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
          free (lfm_files);
          MEMclose (&list);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
        _DMcall_do_nothing(2);
          return (status);
        }
      }
    }
    else
    {
      _NFMdebug ((fname, "move files without consulting LFM\n"));
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
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            MEMclose (&list);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            degree = 3;
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
            if (DM_MANAGER)
        _DMcall_do_nothing(2);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1");
        }
        strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
        strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
        if (native_and_raster &&
            ( strcmp (data[index+q_filetype], "DOCR") == 0 ||
              strcmp (data[index+q_filetype], "WPR")  == 0 ||
              strcmp (data[index+q_filetype], "LOTR") == 0 ||
              strcmp (data[index+q_filetype], "XLSR") == 0   ) )
          strcat (row_str, "");
        else
          strcat (row_str, move_str);
        strcat (row_str, "\1\1\1");
        if (DM_MANAGER)
        {
          sprintf (dumb_str, "%s\1%d\1%s\1%s\1%s\1", catalog_name, item_no,
                   item_revision, item_name, itemdesc);
          strcat (row_str, dumb_str);
        }
        else
        {
          strcat (row_str, "\1\1\1\1\1");
        }
  
        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
          MEMclose (&list);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
                     _DMcall_do_nothing(2);
            return (status);
        }
      }
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

    if (DM_MANAGER)
      status = _DMfs_recv_files (&file_list);
    else
      status = _NFMfs_recv_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_recv_files 0x%.8x\n", status));
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      MEMbuild_array (file_list);
      NFMopen_message_buffer ();
      if (DM_MANAGER)
      {
        special_msg = 1;
      }
      ret_status = _NFMstack_error_from_buffer 
         (file_list, catalog_name, item_name, item_revision,
                              NFM_CHECK_OUT, (MEMptr) NULL);
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1);
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMfs_undo_recv_files (&file_list);
      free (lfm_files);
      MEMclose (&list);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (ret_status);
    }

      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

    /* update <catalog> and f_<catalog> and lfm */
    
    /* lock the table */
  
    SQLstmt ("COMMIT WORK");

    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1);
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      degree = 3;
      /* mms - I do not what is loaded into the structure */
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
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
      _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1_FCAT);
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    /* commit the table */

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
         lfm_files, list, catalog_name, catalog_no, item_no, 
         sto_list->sano, NFM_RLBK_LFM1_FCAT);
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    if (operation.transfer == NFM_CONDITIONAL_TRANSFER )
    {
      _NFMdebug ((fname, "conditional transfer, update LFM\n"));

      sprintf (sql_str, "%s %s %d %s %d %s %d %s %d %s",
               "update nfmsafiles set n_co = 'Y', n_cisano = NULL,",
               "n_nfs = NULL, n_mountpoint = NULL, n_fileversion =", 
               file_version, "where n_sano =",
               sto_list->sano, "and n_catalogno =", catalog_no, 
               "and n_itemno =",
               item_no, "and (");

      for (x = 0, nothing = 1; x < list->rows; x ++)
      {
        index = x * list->columns;
        if ((lfm_files+x)->action == NFM_UPDATE_CO)
        {
          _NFMdebug ((fname, "File_num %s in nfmsafiles needs to be updated\n",
                      data[index+q_filenum]));
          if (!nothing)
            strcat (sql_str, "or");
          else
            nothing = 0;
          strcat (sql_str, "(n_filenum = ");
          strcat (sql_str, data[index+q_filenum]);
          strcat (sql_str, "and n_filename = '");
          strcat (sql_str, data[index+q_cofilename]);
          strcat (sql_str, "')");
        }
        else 
        {
          _NFMdebug ((fname, "add filenum %s to nfmsafiles\n",
                            data[index+q_filenum]));
          sprintf (ins_str, "%s %s %d, '%s', %d, %d, %s, %d, %s",
            "insert into nfmsafiles (n_sano, n_filename, n_catalogno,",
            "n_itemno, n_filenum, n_fileversion, n_co, n_copy, n_ref) values (",
            sto_list->sano, data[index+q_cofilename], catalog_no, item_no,
            data[index+q_filenum], file_version, "'Y', 'N', 0)");
          status = NFMlock_table ("nfmsafiles");
          if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
            _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
              lfm_files, list, catalog_name, catalog_no, item_no,
              sto_list->sano, NFM_RLBK_LFM2_FCAT);
            if (DM_MANAGER)
              _DMfs_undo_recv_files (&file_list);
            else
              _NFMfs_undo_recv_files (&file_list);
            MEMclose (&list);
            free (lfm_files);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            degree = 3;
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
            return (status);
          }
          status = SQLstmt (ins_str);
          if (status != SQL_S_SUCCESS)
          {
            _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
            _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
              lfm_files, list, catalog_name, catalog_no, item_no, 
              sto_list->sano, NFM_RLBK_LFM2_FCAT);
            if (DM_MANAGER)
              _DMfs_undo_recv_files (&file_list);
            else 
              _NFMfs_undo_recv_files (&file_list);
            MEMclose (&list);
            free (lfm_files);
            MEMclose (&file_list);
            _NFMfree_linked_lists (sto_list, NULL);
            degree = 3;
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
            return (status);
          }
          SQLstmt ("COMMIT WORK");
        }
      }
      strcat (sql_str, ")");
      if (!nothing)
      {
        status = NFMlock_table ("nfmsafiles");
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
          _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
            lfm_files, list, catalog_name, catalog_no, item_no,
            sto_list->sano, NFM_RLBK_LFM2_FCAT);
          if (DM_MANAGER)
            _DMfs_undo_recv_files (&file_list);
          else
            _NFMfs_undo_recv_files (&file_list);
          MEMclose (&list);
          free (lfm_files);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          return (status);
        }
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
          _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
            lfm_files, list, catalog_name, catalog_no, item_no, 
            sto_list->sano, NFM_RLBK_LFM2_FCAT);
          if (DM_MANAGER)
            _DMfs_undo_recv_files (&file_list);
          else
            _NFMfs_undo_recv_files (&file_list);
          MEMclose (&list);
          free (lfm_files);
          MEMclose (&file_list);
          _NFMfree_linked_lists (sto_list, NULL);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          return (status);
        }
      }
      SQLstmt ("COMMIT WORK");
    }

    status = NFMset_item_status (catalog_name, "", "", item_no, "O", 
             NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_and_undo_buffer (NFM_CHECK_OUT, NFM_ITEM, file_list,
        lfm_files, list, catalog_name, catalog_no, item_no, 
        sto_list->sano, NFM_RLBK_LFM2_FCAT);
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMfs_undo_recv_files (&file_list);
      MEMclose (&list);
      free (lfm_files);
      MEMclose (&file_list);
      _NFMfree_linked_lists (sto_list, NULL);
      degree = 3;
      /* mms - I do not what is loaded into the structure */
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname,"NFMset_item_status failed 0x%.8x\n", status));
      return (status);
    }
    if (operation.transfer == NFM_CONDITIONAL_TRANSFER)
      free (lfm_files);
  }

  _NFMdebug ((fname, "NFMglobal.load_item_file [%d]\n",
                      NFMglobal.load_item_file));
  if ((NFMglobal.load_item_file == NFM_LOAD_ITEM_FILE) ||
      (DM_MANAGER && NFM_FTR_INITED) )
  {
    _NFMdebug ((fname, "Load processed items/files info into global\n"));
    strncpy (item_entry.cat_name, catalog_name, NFM_CATALOGNAME);
    item_entry.cat_no = catalog_no;
    strncpy (item_entry.item_name, item_name, NFM_ITEMNAME);
    strncpy (item_entry.item_rev, item_revision, NFM_ITEMREV);
    strncpy (item_entry.status, file_status, NFM_STATUS);
    item_entry.item_no = item_no;
    item_entry.files = list->rows;
    item_entry.next_item = (struct NFMitem_entry *) NULL;
    item_entry.next_file = (struct NFMfile_entry *) NULL;
    for (x = 0; (x+1) < list->rows;  x++)
    {
      status = MEMwrite_data (list, datetime, x + 1, q_codate);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_data: 0x%.8x\n", status));
      }
    }
    MEMbuild_array (file_list);
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
  }
   
  _NFMdebug ((fname, "free all link list\n"));
  _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
  _NFMdebug ((fname, "Close list\n"));
  MEMclose (&list);
  _NFMdebug ((fname, "Close file_list\n"));
  if (DM_MANAGER)
  {
    _DMdo_nothing ();
  }
  MEMclose (&file_list);
      
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction failed 0x%.8x\n", status));

  /* check the wf_info.workflow and take proper action, such as set_to_state.
     if anything goes wrong in set_to_state, the item is NOT ROLLED BACK */

  if (wf_info.workflow)
  {
    ERRget_message (error_msg);
    ERRget_number (&error_no, &subsystem);
    status = NFMset_wf_state (wf_info.app_name, error_no, error_msg);
    if (status != NFM_S_SUCCESS)
      _NFMdebug ((fname, "NFMset_wf_state 0x%.8x\n", status));
  }

  if (no_move_file_warning && !DM_MANAGER)
  {
    ERRload_struct (NFM, NFM_W_NO_FILE_MOVE, "", NULL);
    _NFMdebug ((fname, "EXIT: transfer == NFM_NO_TRANSFER\n"));
    return (NFM_W_NO_FILE_MOVE);
  }
  else if (no_file_warning && !DM_MANAGER)
  {
    ERRload_struct (NFM, NFM_W_NO_FILE, "", NULL);
    _NFMdebug ((fname, "EXIT: no file associated with item\n"));
    return (NFM_W_NO_FILE);
  }
  _NFMdebug ( (fname,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
