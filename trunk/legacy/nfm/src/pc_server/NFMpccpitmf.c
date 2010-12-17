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


extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;
extern long special_msg;

long NFMpccopy_item_files (catalog_name, catalog_no, item_name, item_revision,
                         working_area, wf_info, operation)

/***
  This function will copy item's files.

  Note: operation.delete and operation.purge will be ignored.

  CHANGE HISTORY:
    08/28/91 mfb Creation.
***/

char *catalog_name;  /* I: item's catalog */
long catalog_no;     /* I: optional, < 1 if unknown. */
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
char *working_area;  /* I: checkout storage area */
struct NFMwf_info wf_info; /* I: turn on/off validation and set_to_state */
struct NFMoperation operation; /* I: file transfer mode */

{
  char *fname="NFMpccopy_item_files";
  char sql_str[1024], row_str[3072], temp_str[1024];
  char upd_str[2048], ins_pre_str[1024];
  char fcat_name[NFM_CATALOGNAME+3], itemdesc[NFM_ITEMDESC+1];
  char *datetime;
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1], 
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1], 
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1], 
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1], 
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1], 
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char **data, **data1;
  char file_status[NFM_STATUS+1], arc_state[NFM_ARCHIVESTATE+1],
       lock[NFM_ITEMLOCK+1], pending_flag[NFM_PENDINGFLAG+1], 
       /*fileversion[NFM_FILEVERSION+1],*/ filename[NFM_CIFILENAME+1];
  char saname[NFM_SANAME+1];
  char dumb_str[20], error_msg[1024];
  long  x, index, index1, nothing, call_sql;
  int subsystem;
  long version_match;
  long file_version;
  long transfer_status;
  long item_no;
  long ret_status, status, warning=0;
  long sano=0;
  long add_to_lfm = 0;
  long dumb_value, error_no;
  MEMptr list=NULL, list1=NULL, file_list=NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMsto_info *sto_list, *end_sto, *cur_sto, *new_sto;
  struct NFMitem_entry item_entry;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d]\n", catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name, 
                       operation.transfer, operation.delete, operation.purge));
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
      ERRget_message (error_msg);
      ERRget_number (&error_no, &subsystem);
      NFMset_wf_state (wf_info.app_name, error_no, error_msg);
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
      return (status);
    }
  }

  /* lock <catalog> and retrieve the item information, check the file status,
     make sure it is OK to copy item's files */ 

  status = NFMlock_table (catalog_name);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "NFMlock_table (%s) failed 0x%.8x\n", 
                 catalog_name, status));
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
    return (status);
  }

  sprintf (sql_str, "%s %s %s '%s' %s '%s'",
   "select n_itemno, n_status, n_archivestate, n_itemlock, n_pendingflag, n_itemdesc from",
    catalog_name, "where n_itemname =", item_name, "and n_itemrev = ",
    item_revision);

  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "MEMbuild_array (list contains item info) 0x%.8x\n",
                 status) );
    if (DM_MANAGER)
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve document's information"); 
      _DMcall_do_nothing (2);
    }
    else
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve item's information"); 
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    MEMclose (&list);
    _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status) );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }


  data = (char **)list->data_ptr;
  item_no = atol (data[0]);
  strcpy (itemdesc, data[5]);

  if (!strlen(data[1]) )
  {
    _NFMload_error_message (item_name, item_revision, NFM_COPYFILES, NFM_ITEM,
                            data[1], "");
    NFMrollback_transaction (0); 
    _NFMdebug ( (fname, "Cannot copy item because file status = %s\n",
                 data[1]) );
    MEMclose (&list);
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (NFM_E_BAD_FILE_STATUS);
  }  
  
  if (strlen (data[2]) && ! strcmp (data[2], "A") )
  {
    _NFMload_error_message (item_name, item_revision, NFM_COPYFILES, NFM_ITEM,
                            data[2], "");
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "Cannot checkout item because archive state = %s\n",
                data[2]) );
    MEMclose (&list);
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (NFM_E_BAD_ARCHIVE_FLAG);
  }

  if (!strcmp (data[3], "Y"))
  {
    ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "Cannot checkout item because lock = %s\n", data[3]));
    MEMclose (&list);
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (NFM_E_ITEM_LOCKED);
  }

  if (strlen (data[4]) && strcmp (data[4], "IB") && strcmp (data[4], "SB") &&
                          strcmp (data[4], "PB") )
  {
    _NFMload_error_message (item_name, item_revision, NFM_COPYFILES, NFM_ITEM,
                   data[4], "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "Cannot checkout item because pending flag = %s\n",
                data[4]));
    MEMclose (&list);
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (NFM_E_ITEM_FLAGGED);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0); 
    _NFMdebug ( (fname, "MEMclose (list contains item information)0x%.8x",
                 status) );
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  /* lock f_<catalog> and retrieve the file information */
 
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status));
    if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  sprintf (sql_str, "%s %s %s %s %s %d %s and %s %s %s %d %s",
           "select n_fileno, n_filenum, n_fileversion, n_filetype,", 
           "n_fileco, n_cifilesize, n_cifilename,",
           "n_cisano, n_cofilename, n_cidate, n_codate from", fcat_name,
           "where n_itemnum = ", item_no, 
           "and (n_fileco = 'Y' or n_fileco = 'N')",
           "n_fileversion = (select max(n_fileversion) from ", fcat_name,
           "where n_itemnum = ", item_no, ")");

  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str, 
                               &dumb_value, &list);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "NFMretrieve_values(%s)failed 0x%.8x\n", 
                 sql_str, status));
    if (DM_MANAGER)
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "No files checked in for the document");
      _DMcall_do_nothing (2);
    }
    else
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "No files checked in for the item");
    return (status);
  }
  else if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "NFMretrieve_values(%s)failed 0x%.8x\n", 
                 sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve file information");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  } 

  data = (char **) list->data_ptr;
  file_version = atol (data[2]);

  _NFMdebug ((fname, "retrieved max(fileversion) [%d] \n", file_version));

  /* retrieve the storage area information */

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip, xns,
                                decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
       (strcmp (opsys, "WINDOS") == 0)                )
  {
    NFMrollback_transaction (0);
    MEMclose (&list);
    _NFMdebug ((fname, "cannot copy to DMM node\n"));
    ERRload_struct (NFM, NFM_E_CO_DMM_NODE, "", NULL);
    return (NFM_E_CO_DMM_NODE);
  }


  if (operation.transfer == NFM_CONDITIONAL_TRANSFER)
  {
  /* prepare buffer for the file server */
  /* 1st row for out_to_storage */

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    NFMrollback_transaction (0);
    MEMclose(&list);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  sprintf (row_str, 
 "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername,
  partition, nfs, compress, machid, opsys, tcpip, xns, decnet,
  netware, "\1\1\1\1\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
    NFMrollback_transaction (0);
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  sto_list = end_sto = (struct NFMsto_info *) calloc 
                                              (1, sizeof (struct NFMsto_info));
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

  lfm_files = (struct NFMlfm_file *) calloc (list->rows, 
               sizeof (struct NFMlfm_file));
  if (lfm_files == (struct NFMlfm_file *) NULL)
  {
    _NFMdebug ((fname, "Failed to malloc\n"));
    NFMrollback_transaction (0);
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "%s",
                    "Failed to allocate memory");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (NFM_E_MALLOC);
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
                                   &catalog_no, &list1);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
        NFMrollback_transaction (0);
        MEMclose (&list);
        free (lfm_files);
        if (DM_MANAGER)
        {
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                         "Failed to retrieve cabinet's information"); 
                _DMcall_do_nothing (2);
        }
        else
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                        "Failed to retrieve catalog's information"); 
        return (status);
      }
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list : ", list, _NFMdebug_st.NFMdebug_file);
  data = (char **) list->data_ptr;
  for (x = 0, version_match = 0; x < list->rows; x++, version_match = 0)
  {
    index = list->columns * x;
    /* query lfm */
    sprintf (sql_str, "%s %d %s '%s' %s %d %s %d %s %s",
           "select n_copy, n_fileversion from nfmsafiles where n_sano =", 
             sto_list->sano,
             "and n_filename =", data[index+8], "and n_catalogno =",
             catalog_no, "and n_itemno =", item_no, "and n_filenum =",
             data[index+1]);
 
    status = SQLquery (sql_str, &list1, MEM_SIZE);
    if (status == SQL_S_SUCCESS)
    {
      (lfm_files+x)->action = 1; /* update the entry only */
      status = MEMbuild_array (list1);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_arra 0x%.8x\n", status));
        MEMclose (&list);
        MEMclose (&list1);
        free (lfm_files);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      data1 = (char **) list1->data_ptr;
      if (atol(data1[1]) == atol(data[index+2]))
        version_match = 1;
    }
    else if ( status == SQL_I_NO_ROWS_FOUND)
    {
      (lfm_files+x)->action = 0; /* add to the table */
      add_to_lfm ++;
      version_match = 1; /* since  no record, set to 1 so NFM_LFM_NFS_MOVE */
    }
    else
    {
      _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
      NFMrollback_transaction (0);
      MEMclose (&list);
      MEMclose (&list1);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }

    /* copy FROM storage area information */

    for (cur_sto = sto_list; cur_sto != (struct NFMsto_info *) NULL; 
         cur_sto = cur_sto->next)
    {
      if (cur_sto->sano == atol (data[index+7]))
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
      new_sto->sano = sano = atol (data[index+7]);
      status = NFMget_storage_info (saname, &sano, nodename,
                                    username, passwd, pathname, devicetype,
                                    plattername, partition, nfs, compress,
                                    machid, opsys, tcpip, xns, decnet, 
                                    netware);
      strcpy (new_sto->nodename, nodename);
      strcpy (new_sto->username, username);
      strcpy (new_sto->passwd, passwd);
      strcpy (new_sto->pathname, pathname);
      strcpy (new_sto->devicetype, devicetype);
      strcpy (new_sto->plattername, plattername);
      strcpy (new_sto->partition, partition);
      strcpy (new_sto->nfs, nfs);
      strcpy (new_sto->compress, compress);
      strcpy (new_sto->machid, machid);
      strcpy (new_sto->opsys, opsys);
      strcpy (new_sto->tcpip, tcpip);
      strcpy (new_sto->xns, xns);
      strcpy (new_sto->decnet, decnet);
      strcpy (new_sto->netware, netware);
      end_sto->next = new_sto;
      end_sto = new_sto;
      sprintf (row_str, 
      "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
      sano,
      nodename, username, passwd, pathname, devicetype, plattername,
      partition, nfs, compress, machid, opsys, tcpip, xns, decnet,
      netware);
    }
    strcat (row_str, data[index]); strcat (row_str, "\1");
    strcat (row_str, "\1");
    if (strlen (data[index+6]))
    {
      strcat (row_str, data[index+6]); strcat (row_str, "\1");
    }
    else
    {
      status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, atol(data[index]), 
                                 filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        NFMrollback_transaction (0);
        MEMclose (&list);
        MEMclose (&list1);
        free (lfm_files);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    }
    strcat (row_str, data[index+8]); strcat (row_str, "\1"); /* n_cofilename */
    strcat (row_str, data[index+3]); strcat (row_str, "\1");
    strcat (row_str, data[index+5]); strcat (row_str, "\1");
    
    if (operation.transfer == NFM_TRANSFER || !version_match)
    {
      sprintf (temp_str, "%d", NFM_NFS_MOVE);
      strcat (row_str, temp_str); strcat (row_str, "\1\1\1");
    }
    else 
    {
      sprintf (temp_str, "%d", NFM_LFM_NFS_MOVE);
      strcat (row_str, temp_str); strcat (row_str, "\1\1\1");
    }
    if (DM_MANAGER)
    {
      sprintf (temp_str, "%s\1%d\1%s\1%s\1%s\1", catalog_name, item_no, 
               item_revision, item_name, itemdesc);
      strcat (row_str, temp_str);
      NFMparse_local_filename (data[index+8]);
    }
    else 
    {
      strcat (row_str, "\1\1\1\1\1");
    }

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMrollback_transaction (0);
      MEMclose (&list);
      MEMclose (&list1);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }

    status = MEMclose (&list1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMrollback_transaction (0);
      MEMclose (&list);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list,
                      _NFMdebug_st.NFMdebug_file);

  if (DM_MANAGER)
  {
    status = _DMfs_recv_files (&file_list);
  }
  else
  {
    status = _NFMpcfs_recv_files (&file_list);
  }
  if ( status == NFM_E_LFM_FILE_EXISTS ||
       status == NFM_E_LFM_EXISTS_LOCALLY ||
       status == NFM_E_LFM_NFS_EXISTS_LOCALLY ||
       status == NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "status 0x%.8x\n", status));
  }
  else 
  {
    _NFMdebug ((fname, "_NFMpcfs_recv_files 0x%.8x\n", status));
    MEMbuild_array (file_list);
    if (DM_MANAGER)
    {
      special_msg = 1;
      _DMfs_undo_recv_files (&file_list);
    }
    else
      _NFMpcfs_undo_recv_files (&file_list);
    NFMstart_transaction (0);
    ret_status = _NFMstack_error_from_buffer (file_list, catalog_name, item_name,
                                 item_revision, NFM_COPYFILES, (MEMptr) NULL);
    MEMclose (&file_list);
    MEMclose (&list);
    free (lfm_files);
    return (ret_status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list,
                      _NFMdebug_st.NFMdebug_file);

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMpcfs_recv_files 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMfs_undo_recv_files (&file_list);
    else
      _NFMpcfs_undo_recv_files (&file_list);
    MEMclose (&list);
    free (lfm_files);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }
  data1 = (char **) file_list->data_ptr;
    
  _NFMdebug ((fname, "update local file manager table\n"));

  sprintf (upd_str, "%s %d %s %d %s %d %s %d %s",
   "update nfmsafiles set n_copy = 'Y', n_fileversion =", file_version,
   "where n_sano =",
   sto_list->sano, "and n_catalogno =", catalog_no, "and n_itemno =",
   item_no, "and (");
  sprintf (ins_pre_str, "%s %s %d, %d, %d, %d, %s",
               "insert into nfmsafiles (n_sano, n_catalogno, n_itemno,",
          "n_fileversion, n_copy, n_co, n_ref, n_filenum, n_filename) values (",
          sto_list->sano, catalog_no, item_no, file_version, "'Y', 'N', 0");
  for (x = 0, call_sql = 1, nothing = 1; x < list->rows; x ++, call_sql = 1)
  {
    index = list->columns * x;
    index1 = file_list->columns * (x+1);

    transfer_status = atol(data1[index1+FTO_STATUS1]);

    if (transfer_status == NFM_NFSED)
    {
      _NFMdebug ((fname, "file transferes using nfs\n"));
      if ((lfm_files+x)->action)
        sprintf (sql_str, 
           "%s, %s %s, %s '%s', %s %d %s %d %s %d %s %d %s %s %s '%s'",
                 "update nfmsafiles set n_copy = 'Y', n_nfs = 'Y'", 
                 "n_cisano =", data[index+7], "n_mountpoint =",
                 data1[index1+FTO_MOUNTPOINT], 
                 "n_fileversion =", file_version, "where n_sano =",
                 sto_list->sano, "and n_catalogno =", catalog_no,
                 "and n_itemno =", item_no, 
                 "and n_filenum =", data[index+1], "and n_filename =",
                 data[index+8]);
      else
        sprintf (sql_str, 
          "%s %s %s %d, %d, %d, %d, %s, %s, '%s', '%s', '%s', %s %s",
          "insert into nfmsafiles (n_sano, n_catalogno, n_itemno,",
          "n_fileversion, n_copy, n_co, n_ref, n_filenum, n_filename, n_nfs,",
          "n_mountpoint, n_cisano) values (",
          sto_list->sano, catalog_no, item_no, file_version, "'Y', 'N', 0",
                 data[index+1], data1[index1+FTO_COFILENAME], "Y",
                 data1[index1+FTO_MOUNTPOINT],
                 data[index+7], ")");
    }
    else if (transfer_status == NFM_TRANSFERED)
    {
      _NFMdebug ((fname, "file transferes using regular method\n"));
      if ((lfm_files+x)->action)
      {
        if (nothing)
          nothing = 0;
        else
          strcat (upd_str, "or");
 
        strcat(upd_str, "(n_filenum = ");
        strcat(upd_str, data[index+1]);
        strcat(upd_str, "and n_filename = '");
        strcat(upd_str, data1[index1+FTO_COFILENAME]);
        strcat(upd_str, "')");
        call_sql = 0;
      }
      else
        sprintf (sql_str, "%s, %s, '%s' %s", 
                 ins_pre_str, data[index+1], data1[index1+FTO_COFILENAME], ")");
    }
    else if (transfer_status == NFM_E_LFM_FILE_EXISTS ||
             transfer_status == NFM_E_LFM_EXISTS_LOCALLY ||
             transfer_status == NFM_E_LFM_NFS_EXISTS_LOCALLY )
    {
      _NFMdebug ((fname, "no file transferes, local file exists \n"));
      if ((lfm_files+x)->action)
      {
        sprintf (sql_str, 
                 "%s %s %d %s %d %s %d %s %d %s %s %s '%s'",
                 "update nfmsafiles set n_copy = 'Y'", 
                 "where n_sano =",
                 sto_list->sano, "and n_catalogno =", catalog_no,
                 "and n_itemno =", item_no, "and n_fileversion =", file_version,                  "and n_filenum =", data[index+1], "and n_filename =",
                 data[index+8]);
        ERRload_struct (NFM, NFM_W_KNOWN_FILE_LOCAL, "%s", "item's");
        warning = 1;
      }
      else
      {
        _NFMdebug ((fname, "Unknown file exists locally\n"));
        if (DM_MANAGER)
          _DMfs_undo_recv_files (&file_list);
        else
          _NFMpcfs_undo_recv_files (&file_list);
        /* roll back lfm */
        MEMclose (&list);
        free (lfm_files);
        /*transfer_status = atol(data1[index1+FTO_STATUS1]);*/
        ERRload_struct (NFM, NFM_E_UNKNOWN_FILE_LOCAL, "%s%s%s", 
                        data1[index1+FTO_COFILENAME], item_name, item_revision);
        return (NFM_E_UNKNOWN_FILE_LOCAL);
      }
    }
    if (call_sql)
    {
      _NFMdebug ((fname, "exec sql: %s\n", sql_str));
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
        if (DM_MANAGER)
          _DMfs_undo_recv_files (&file_list);
        else
          _NFMpcfs_undo_recv_files (&file_list);
        /* roll back lfm */
        MEMclose (&list);
        free (lfm_files);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }
    }
  }

  if (!nothing)
  {
    strcat (upd_str, ")");
    status = SQLstmt (upd_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
      if (DM_MANAGER)
        _DMfs_undo_recv_files (&file_list);
      else
        _NFMpcfs_undo_recv_files (&file_list);
      /* roll back lfm */
      MEMclose (&list);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
  }

  free (lfm_files);

  status = _NFMfree_linked_lists (sto_list, NULL);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "_NFMfree_linked_lists 0x%.8x\n", status));
  }
  else if (operation.transfer == NFM_TRANSFER)
  {
  /* prepare buffer for the file server */
  /* 1st row for out_to_storage */

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    NFMrollback_transaction (0);
    MEMclose(&list);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  sprintf (row_str, 
 "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername,
  partition, nfs, compress, machid, opsys, tcpip, xns, decnet,
  netware, "\1\1\1\1\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
    NFMrollback_transaction (0);
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  sto_list = end_sto = (struct NFMsto_info *) calloc 
                                              (1, sizeof (struct NFMsto_info));
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
                                   &catalog_no, &list1);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
        NFMrollback_transaction (0);
        MEMclose (&list);
        free (lfm_files);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list : ", list, _NFMdebug_st.NFMdebug_file);
  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x++)
  {
    index = list->columns * x;

    /* copy FROM storage area information */

    for (cur_sto = sto_list; cur_sto != (struct NFMsto_info *) NULL; 
         cur_sto = cur_sto->next)
    {
      if (cur_sto->sano == atol (data[index+7]))
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
      new_sto->sano = sano = atol (data[index+7]);
      status = NFMget_storage_info (saname, &sano, nodename,
                                    username, passwd, pathname, devicetype,
                                    plattername, partition, nfs, compress,
                                    machid, opsys, tcpip, xns, decnet, 
                                    netware);
      strcpy (new_sto->nodename, nodename);
      strcpy (new_sto->username, username);
      strcpy (new_sto->passwd, passwd);
      strcpy (new_sto->pathname, pathname);
      strcpy (new_sto->devicetype, devicetype);
      strcpy (new_sto->plattername, plattername);
      strcpy (new_sto->partition, partition);
      strcpy (new_sto->nfs, nfs);
      strcpy (new_sto->compress, compress);
      strcpy (new_sto->machid, machid);
      strcpy (new_sto->opsys, opsys);
      strcpy (new_sto->tcpip, tcpip);
      strcpy (new_sto->xns, xns);
      strcpy (new_sto->decnet, decnet);
      strcpy (new_sto->netware, netware);
      end_sto->next = new_sto;
      end_sto = new_sto;
      sprintf (row_str, 
      "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
      sano,
      nodename, username, passwd, pathname, devicetype, plattername,
      partition, nfs, compress, machid, opsys, tcpip, xns, decnet,
      netware);
    }
    strcat (row_str, data[index]); strcat (row_str, "\1");
    strcat (row_str, "\1");
    if (strlen (data[index+6]))
    {
      strcat (row_str, data[index+6]); strcat (row_str, "\1");
    }
    else
    {
      status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, atol(data[index]), 
                                 filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        NFMrollback_transaction (0);
        MEMclose (&list);
        MEMclose (&list1);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    }
    strcat (row_str, data[index+8]); strcat (row_str, "\1");
    strcat (row_str, data[index+3]); strcat (row_str, "\1");
    strcat (row_str, data[index+5]); strcat (row_str, "\1");
    
    sprintf (temp_str, "%d", NFM_NFS_MOVE);
    strcat (row_str, temp_str); strcat (row_str, "\1\1\1");
    if (DM_MANAGER)
    {
      sprintf (temp_str, "%s\1%d\1%s\1%s\1%s\1", 
               catalog_name, item_no, item_revision, item_name, itemdesc);
      strcat (row_str, temp_str);
    }
    else
    {
      strcat (row_str, "\1\1\1\1\1");
    }

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMrollback_transaction (0);
      MEMclose (&list);
      MEMclose (&list1);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }

    status = MEMclose (&list1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMrollback_transaction (0);
      MEMclose (&list);
      free (lfm_files);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list,
                      _NFMdebug_st.NFMdebug_file);

  if (DM_MANAGER)
    status = _DMfs_recv_files (&file_list);
  else
    status = _NFMpcfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMpcfs_recv_files 0x%.8x\n", status));
    MEMbuild_array (file_list);
    if (DM_MANAGER)
      _DMfs_undo_recv_files (&file_list);
    else
      _NFMpcfs_undo_recv_files (&file_list);
    NFMstart_transaction (0);
    MEMclose (&list);
    MEMclose (&file_list);
    free (lfm_files);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list,
                      _NFMdebug_st.NFMdebug_file);

  status = _NFMfree_linked_lists (sto_list, NULL);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "_NFMfree_linked_lists 0x%.8x\n", status));
  }

  if (NFMglobal.load_item_file == NFM_LOAD_ITEM_FILE)
  {
    _NFMdebug ((fname, "Load processed items/files info into global\n"));
    strcpy (item_entry.cat_name, catalog_name);
    item_entry.cat_no = catalog_no;
    strcpy (item_entry.item_name, item_name);
    strcpy (item_entry.item_rev, item_revision);
    strcpy (item_entry.status, file_status);
    item_entry.item_no = item_no;
    item_entry.files = list->rows;
    item_entry.next_item = (struct NFMitem_entry *) NULL;
    item_entry.next_file = (struct NFMfile_entry *) NULL;
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
  }
   
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose failed 0x%.8x\n", status));

  if (DM_MANAGER)
  {
    _DMdo_nothing ();
  }
  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose failed 0x%.8x\n", status));
      

  /* check the wf_info.workflow and take proper action, such as set_to_state.
     if anything goes wrong in set_to_state, the item is NOT ROLLED BACK */

  if (wf_info.workflow)
  {
    status = ERRget_message (error_msg);
    if (status != ERR_S_SUCCESS)
      _NFMdebug ((fname, "ERRget_message: 0x%.8x\n", status));
    ERRget_number (&error_no, &subsystem);
    if (status != ERR_S_SUCCESS)
      _NFMdebug ((fname, "ERRget_number: 0x%.8x\n", status));
    status = NFMset_wf_state (wf_info.app_name, error_no, error_msg);
    if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMset_wf_state 0x%.8x\n", status));
  }

  if (warning)
  {
    _NFMdebug ( (fname,"EXIT: warning 0x%.8x\n", NFM_W_KNOWN_FILE_LOCAL) );
    return (NFM_W_KNOWN_FILE_LOCAL);
  }
  _NFMdebug ( (fname,"EXIT: successful 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
