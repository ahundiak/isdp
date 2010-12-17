#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "WFstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "NFTftr.h"
#include "UTIerrordef.h"

extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;
extern char NFM_DM_NODENAME[NFM_NODENAME+1];
extern long DM_MANAGER;
extern long NFM_FTR_INITED;

long NFMsave_item_files (catalog_name, item_name, item_revision)

/***

  This function will post new version(s) of file(s) to internal storage area
  for checked out file(s).

  Note: Microstation file does not need to be  handled specially. 


***/

char *catalog_name; /* item's catalog */
char *item_name; /* item's name */
char *item_revision; /* item's revision */

{
  char *fname="NFMsave_item_files";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], row_str[1024], w_clause[512], upd_lfm_str[512];
  char move_move_str[10], first_temp_str[10], temp_str[10], temp_str1[10];
  char **data, **data1, ftr_row[2048],ftr_tmp[10];
  char file_status[NFM_STATUS+1], archive[NFM_ARCHIVESTATE+1];
  char datetime_str[NFM_DATE+1];
  char datetime[NFM_DATE+1], filename[NFM_CIFILENAME+1];
  char dumb_str[100], itemdesc[NFM_ITEMDESC+1];
  long  x, y, index, first_move=0, move_move=0;
  long  sto_no, cat_no, upd_lfm=0, do_purge=0, upd_bkup=0;
  long  q_itemno=0, q_status=1, q_archivestate=2, q_versionlimit=5;
  long  q_fileno=0, q_filenum=1, q_filetype=2, q_fileversion=3, q_fileco=4, 
       q_cifilesize=5, q_cifilename=6, q_cisano=7, q_cofilename=8, q_cosano=9, 
       q_couser=13, q_fileclass=14, q_archiveno=15;
  long file_version, max_file_no, file_no, file_first_time;
  long version_limit, purge_limit;
  long item_no, ftr_status=UTI_S_SUCCESS;
  long status;
  long dumb_value;
  long fs_net_id;
  MEMptr list=NULL, dumb_list= NULL, file_list=NULL, ftr_file_list=NULL;
  struct NFMsto_info *sto_list, *cur_sto;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n",
                       catalog_name, item_name, item_revision));

  sprintf (fcat_name, "f_%s", catalog_name);

  /* set autocommit off */
  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  /* retrieve item's information from catalog */

  sprintf (w_clause, "%s '%s' %s '%s'",
           "where n_itemname = ", item_name, "and n_itemrev = ",      
           item_revision);

  status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
              &dumb_value, &list, NFM_ITEM_QUERY, NFM_RETURN_MEMPTR, 
              NFM_LOCK_COMMIT);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose(&list);
    _NFMdebug ((fname, "NFMretrieve_values (item's info) 0x%.8x\n", status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  data = (char **) list->data_ptr;
  item_no = atol (data[q_itemno]);
  strcpy (file_status, data[q_status]);
  version_limit = atol (data[q_versionlimit]);
  strcpy (archive, data[q_archivestate]);
  strncpy (itemdesc, data[6], NFM_ITEMDESC);
  itemdesc[NFM_ITEMDESC] = '\0';
  _NFMdebug ((fname, "itemdesc = %s\n", itemdesc));

  /* make sure item is eligible for check in */

  if (strlen(file_status))
  {
    if (strcmp(file_status, "O") && strcmp(file_status, "ON")   )
    {
      _NFMload_error_message (item_name, item_revision, NFM_SAVE_FILES, 
                      NFM_ITEM, file_status, archive);
      _NFMdebug ((fname, "Cannot save item because file status = %s\n",
                  file_status));
      MEMclose (&list);
      NFMstart_transaction (0);
      if (DM_MANAGER)
        _DMdo_nothing ();  
      return (NFM_E_BAD_FILE_STATUS);
    }
  }
  else
  {
    _NFMdebug ((fname, 
        "Cannot save item's file(s), this item was never checked in\n"));
    ERRload_struct (NFM, NFM_E_SIF_STATUS_NULL, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_SIF_STATUS_NULL);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose (list has item's information) 0x%.8x\n",
                status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_MEM);
  }

  /* set item file status */

  status = NFMset_item_status (catalog_name, "", "", item_no, "TS", 
           NFM_LOCK_COMMIT, "");
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    _NFMdebug ((fname, "NFMset_item_status [%d] [%s] failed 0x%.8x\n",
                item_no, "TI"));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }
  /* Nfmadmin: to rollback TS status is to upsate n_status */

  /* retrieve item's information from f_<catalog> */

  sprintf (w_clause, "%s %d %s %s %s %d %s",
           "where n_itemnum =", item_no, 
           "and n_fileversion = (select max(n_fileversion) from", 
           fcat_name, "where n_itemnum =", item_no, ")");

  status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
             &dumb_value, &list, NFM_ITEM_FILE_QUERY, NFM_RETURN_MEMPTR, 
              NFM_LOCK_COMMIT);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    MEMclose (&list);
    _NFMdebug ((fname, "NFMcommon_queries (file info) 0x%.8x\n", status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  data = (char **) list->data_ptr;

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("info from f_<catalog>", list, _NFMdebug_st.NFMdebug_file);
                
  file_version = atol (data[q_fileversion]);

  if (strcmp (data[q_couser], NFMglobal.NFMusername))
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    SQLstmt ("COMMIT WORK");
    MEMclose (&list);
    if (DM_MANAGER)
      ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", 
         "save document's file(s)", "document");
    else
      ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "save item's file(s)", 
       "item");
    _NFMdebug ((fname, "Not the checkout user \n"));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_NOT_CO_USER);
  }

  if ( list->rows == 1 && atol (data[q_fileversion]) == 0 && 
       !strlen(data[q_cofilename]) )
  {
    _NFMdebug ((fname, 
       "this item was checked out, but no file associated, no file to save\n"));
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    SQLstmt ("COMMIT WORK");
    ERRload_struct (NFM, NFM_E_SIF_NO_FILE, "", NULL);
    MEMclose (&list);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_SIF_NO_FILE);
  }
 
  /* get date and time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  _NFMdebug ((fname, "datetime = %s\n", datetime));

  /* get storage area information */

  sto_list = (struct NFMsto_info *) calloc ((list->rows+1), 
                           sizeof (struct NFMsto_info));
  sto_list->sano = atol (data[q_cosano]);

  for (x = 0, sto_no = 1; x < list->rows; x++)
  {
    index = list->columns * x;
    _NFMdebug ((fname, "data[index+q_cisano] = %s\n",
                        data[index+q_cisano]));
    for ( y = 0; y < sto_no; y ++)
    {
      _NFMdebug ((fname, "(sto_list+%d)->sano: %d\n", y,
                           (sto_list+y)->sano));
      if ( (sto_list+y)->sano == atol (data[index+q_cisano]))
      {
        _NFMdebug ((fname, "found in the sto_list\n"));
        break;
      }
    }
    if (y >= sto_no)
    {
      _NFMdebug ((fname, "n_cisano not found in the list, add to it\n"));
      (sto_list+sto_no)->sano = atol (data[index+q_cisano]);
      sto_no ++;
    }
  }
  status = NFMget_storages_information (sto_list, sto_no, 1);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_storages_information failed 0x%.8x\n", status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  if (DM_MANAGER && (strcmp (sto_list->nodename, NFM_DM_NODENAME)) )
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    _NFMdebug ((fname, 
      "The file(s) was/were checked out to a different PC\n"));
    NFMstart_transaction (0);
    /* Replace this after Mehry is done recompiling all messages
    ERRload_struct (NFM, NFM_E_CI_FROM_DIFF_PC, "", NULL);
    return (NFM_E_CI_FROM_DIFF_PC);
    */
    _DMdo_nothing ();
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
      "The file(s) was/were checked out to a different PC");
    return (NFM_E_MESSAGE);
  }
  if (!DM_MANAGER && (strcmp (sto_list->machid, "PC") == 0) &&
                     (strcmp (sto_list->opsys, "WINDOS") == 0) )
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    _NFMdebug ((fname, 
      "Cannot save an item that is cheked out to DOS using NFMinterface\n"));
    NFMstart_transaction (0);
    ERRload_struct (NFM, NFM_E_NFM_CLIENT_SAVE_PC, "", NULL);
    return (NFM_E_NFM_CLIENT_SAVE_PC);
  }

  /* prepare buffer for the file server */

  /* 1st row for save_from_storage_area */

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose(&list);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  status = _DMbuild_ftr_buffer (&ftr_file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    NFMset_item_status (catalog_name, "", "", item_no, file_status,
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose(&list);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  sprintf (row_str,
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
    sto_list->sano, sto_list->nodename, sto_list->username, 
    sto_list->passwd, sto_list->pathname, sto_list->devicetype, 
    sto_list->plattername, sto_list->partition, sto_list->nfs,
    sto_list->compress, sto_list->machid, sto_list->opsys, 
    sto_list->tcpip, sto_list->xns, sto_list->decnet, sto_list->netware, 
    "\1\1\1\1\1\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose(&file_list); MEMclose (&ftr_file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_MEM);
  }

  strcpy (ftr_row, row_str);
  strcat (ftr_row, "\1");
  _NFMdebug ((fname, "ftr_row[%s]\n", ftr_row));

  status = MEMwrite (ftr_file_list, ftr_row);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
    NFMset_item_status (catalog_name, "", "", item_no, file_status,
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose(&file_list); MEMclose (&ftr_file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_MEM);
  }
    
  if (strcmp (WFinfo.catalog_name, catalog_name))
  {
    sprintf (w_clause, "n_catalogname = '%s' ", catalog_name);
    status = NFMcommon_queries (catalog_name, w_clause,
               dumb_str, &cat_no, &dumb_list, NFM_CAT_QUERY,
               NFM_RETURN_VALUE, NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMcommon_queries 0x%.8x\n", status));
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
      free (sto_list);
      MEMclose (&list);
      MEMclose(&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      if (DM_MANAGER)
      _DMdo_nothing ();  
      return (NFM_E_SQL_QUERY);
    }
  }
  else
  {
    _NFMdebug ((fname, "Use the info in WFinfo\n"));
    cat_no = WFinfo.catalog_no;
  }

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (status);
  }

  sprintf (sql_str, "select max(n_fileno) from %s", fcat_name);

  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                 &file_no, &dumb_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    _NFMdebug ((fname, "NFMretrieve_values (max(fileno)) 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return (NFM_E_SQL_QUERY);
  }

  max_file_no = file_no;
  _NFMdebug ((fname, "file_no %d max_file_no %d\n", file_no,
                       max_file_no));

  sprintf (temp_str, "%d", NFM_MOVE); /* for FTO_STATUS1 in the buffer going
                                           to FS */
  sprintf (first_temp_str, "%d", NFM_MOVE_FIRST_TIME);

  sprintf (move_move_str, "%d", NFM_MOVE_MOVE);

  /** Need to rollback insert and update if failure occurs **/

  for (x = file_first_time = 0; x < list->rows; x++, file_first_time = 0)
  {
    index = list->columns * x;

    sprintf (sql_str, "%s %s %s %s %s %s (%d, %d, %s, %d, '%s', '%s', \
        '%s', '%s', %s, '%s', timestamp '%s', '%s', %s, '%s', timestamp '%s' )",
           "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
           "n_fileversion, n_fileclass, n_filetype, n_fileco,",
           "n_cifilename, n_cisano, n_ciuser, n_cidate, n_cofilename,",
           "n_cosano, n_couser, n_codate) values ", 
           ++max_file_no, item_no, data[index+q_filenum], file_version+1, 
           data[index+q_fileclass], data[index+q_filetype], 
           "Y", data[index+q_cifilename], 
           data[index+q_cisano], NFMglobal.NFMusername, datetime, 
           data[index+q_cofilename], data[index+q_cosano],
           NFMglobal.NFMusername, datetime);
    _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      if (!strlen(data[index+q_cisano]) || atol (data[index+q_cisano]) < 1)
      {
        ERRload_struct (NFM, NFM_E_CISANO_NOT_VALID, "", NULL); 
        status = NFM_E_CISANO_NOT_VALID;
      }
      else
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        status = NFM_E_SQL_STMT;
      }
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
      free (sto_list);
      MEMclose (&list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
      NFMrollback_transaction (0);
      if (DM_MANAGER)
      _DMdo_nothing ();  
      return (status);
    } 

    if (!strlen (data[index+q_fileco]))
    {
      file_first_time = 1;
    }

    if (! file_first_time)
    {
      sprintf (sql_str,
             "%s %s %s 'N' %s %d %s %d %s %s", 
             "update", fcat_name, "set n_fileco =", 
             "where n_itemnum =", item_no, "and n_fileversion =",
             file_version, "and n_filenum =", data[index+q_filenum]); 

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
        free (sto_list);
        MEMclose (&list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        NFMrollback_transaction (0);
        if (DM_MANAGER)
      _DMdo_nothing ();  
        return ( NFM_E_SQL_STMT);
      }
    }

    /* check in TO storage area information */
    for ( y = 0, cur_sto = sto_list; y < sto_no; y ++)
    {
      if ((cur_sto+y)->sano == atol (data[index+q_cisano]))
      {
        sprintf (row_str,
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (cur_sto+y)->sano, (cur_sto+y)->nodename, (cur_sto+y)->username, 
        (cur_sto+y)->passwd,
        (cur_sto+y)->pathname, (cur_sto+y)->devicetype, 
        (cur_sto+y)->plattername,
        (cur_sto+y)->partition, (cur_sto+y)->nfs, /*mountpoint */
        (cur_sto+y)->compress, (cur_sto+y)->machid,
        (cur_sto+y)->opsys, (cur_sto+y)->tcpip, (cur_sto+y)->xns, 
        (cur_sto+y)->decnet,
        (cur_sto+y)->netware);
        break;
      }
    }
    sprintf (temp_str1, "%d", max_file_no);
    strcat (row_str, temp_str1); strcat (row_str, "\1");
    if (strlen (data[index+q_cifilename]))
    {
      if (file_first_time)
      {
        strcpy (filename, "\0");
        first_move = 1;
      }
      else
      {
        status = NFMget_file_name (NFMglobal.NFMuserid, cat_no, 
                                   atol(data[index+q_fileno]), 
                                   filename);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", item_no, 
                              file_status, 
                        NFM_NO_LOCK, "");
          free (sto_list);
          MEMclose (&list);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          NFMrollback_transaction (0);
          if (DM_MANAGER)
      _DMdo_nothing ();  
          return (status);
        }
        move_move = 1;
      }
      strcat (row_str, filename); strcat (row_str, "\1");
      strcat (row_str, data[index+q_cifilename]); strcat (row_str, "\1");
    }
    else
    {
      strcat (row_str, "\1");
      status = NFMget_file_name (NFMglobal.NFMuserid, cat_no, max_file_no, 
                                 filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
        free (sto_list);
        MEMclose (&list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        NFMrollback_transaction (0);
        if (DM_MANAGER)
      _DMdo_nothing ();  
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    }
    strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
    strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
    strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
    if (first_move)
    {
      strcat (row_str, first_temp_str);
      first_move = 0;
    }
    else if (move_move)
    {
      strcat (row_str, move_move_str);
      move_move = 0;
    }
    else
      strcat (row_str, temp_str); 
    strcat (row_str, "\1\1\1");

    /*
    if (DM_MANAGER)
    { */
      sprintf (dumb_str, "%s\1%d\1%s\1%s\1%s\1", 
               catalog_name, item_no, item_revision, item_name, itemdesc);
               
      strcat (row_str, dumb_str);
    /*
    }
    else
    {
      strcat (row_str, "\1\1\1\1\1");
    }
    */

    _NFMdebug ((fname, "row_str:%s\n", row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
      free (sto_list);
      MEMclose (&list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      NFMrollback_transaction (0);
      if (DM_MANAGER)
      _DMdo_nothing ();  
      return (NFM_E_MEM);
    }

    strcpy (ftr_row, row_str);
    sprintf (ftr_tmp, "%d\1", cat_no);
    strcat (ftr_row, ftr_tmp);
   
    status = MEMwrite (ftr_file_list, ftr_row);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      NFMset_item_status (catalog_name, "", "", item_no, file_status,
                        NFM_NO_LOCK, "");
      free (sto_list);
      MEMclose (&list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      NFMrollback_transaction (0);
      if (DM_MANAGER)
      _DMdo_nothing ();
      return (NFM_E_MEM);
    }
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    NFMrollback_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();  
    return ( NFM_E_SQL_STMT);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list, 
                      _NFMdebug_st.NFMdebug_file);

  /* move the files */
  if (DM_MANAGER)
    status = _DMfs_send_files (&file_list, &fs_net_id, 1);
  else
    status = _NFMfs_send_files (&file_list, &fs_net_id, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMfs_send_files 0x%.8x\n", status));
    MEMbuild_array (file_list);
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file transfer buffer", file_list, 
                       _NFMdebug_st.NFMdebug_file);
    NFMopen_message_buffer ();
    _NFMstack_error_from_buffer (file_list, catalog_name, item_name, 
                                 item_revision, NFM_CHECK_IN, (MEMptr) NULL);
      _NFMfs_undo_send_files (&file_list);
    NFMlock_table (fcat_name);
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    SQLstmt ("COMMIT WORK");
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    NFMrollback_transaction (0);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list, 
                      _NFMdebug_st.NFMdebug_file);

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      _NFMfs_undo_send_files (&file_list);
    NFMlock_table (fcat_name);
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    SQLstmt ("COMMIT WORK");
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }

  if (DM_MANAGER &&NFM_FTR_INITED)
  {
    _NFMdebug ((fname, "FTR enabled, client == DMM, add file and index\n"));
    MEMbuild_array (ftr_file_list);
    status = _NFMmount_add_index (ftr_file_list, NFM_ITEM);
    if (status != UTI_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMmount_add_index 0x%.8x\n", status));
      ftr_status = status;
    }
    ERRreset_struct ();
  }
  else if (NFM_FTR_INITED)
  {
    _NFMdebug ((fname, "FTR is enabled, but client != DMM\n"));
    MEMbuild_array (ftr_file_list);
 
    /* since client != DMM, no ability to modify keywords, but
       do need to maintain keywords if there is any.
       put older file no in FTO_ITEMDESC field to retrieve from collection */

    for (x = 0; x < list->rows; x ++)
    {
      index = list->columns * x;
      _NFMdebug ((fname, "write old file no [%s]\n", data[index+q_fileno]));
      status = MEMwrite_data (ftr_file_list, data[index+q_fileno], 2 + x,
                               FTO_ITEMDESC+1);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname,
          "Failed to write old fileno [%s] to item-description field\n",
           data[q_fileno]));
      }
    }
    status = _NFMmount_add_index (ftr_file_list, NFM_ITEM_NO_KEYWORDS);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMmount_add_index 0x%.8x\n", status));
      ftr_status = status;
    }
    ERRreset_struct ();
  }
  else if (DM_MANAGER)
  {
    _NFMdebug ((fname,
      "FTR engine is not enabled or client is not DM_MANAGER\n"));
    ERRload_struct (NFM, NFM_W_KW_LOSS, "", NULL);
  }
    MEMclose (&ftr_file_list);

  if (NFM_FTR_INITED && (ftr_status == UTI_S_SUCCESS))
  {
    for (x = 0; x < list->rows; x ++)
    {
      index = list->columns * x;
      status = NFT_delete_entry (cat_no, item_no, 
                                 atol(data[index+q_fileno]));
      if (status != UTI_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFT_delete_entry 0x%.8x\n", status));
      }
      else
      {
        _NFMdebug ((fname, "NFT_delete_entry successfully\n"));
      }
        ERRreset_struct ();
    }
  }

  /* update <catalog> */

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
      _NFMfs_undo_send_files (&file_list);
    NFMlock_table (fcat_name);
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    SQLstmt ("COMMIT WORK");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    NFMrollback_transaction (0);
    return (status);
  }

  data1 = (char **) file_list->data_ptr;
  for (x = 1; x < file_list->rows; x++)
  {
    index = file_list->columns * x;
    _NFMdebug ((fname, "Update the cifilesize\n"));
    sprintf (sql_str, "%s %s %s %s %s %s",
             "update", fcat_name, "set n_cifilesize =",
             data1[index+FTO_CIFILESIZE], "where n_fileno =",
             data1[index+FTO_FILENO]);
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
        _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
      free (sto_list);
      MEMclose (&list);
      MEMclose (&file_list);
      _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      NFMrollback_transaction (0);
      return ( NFM_E_SQL_STMT);
    }
  }
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
      _NFMfs_undo_send_files (&file_list);
    NFMlock_table (fcat_name);
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    SQLstmt ("COMMIT WORK");
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list);
    _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    NFMrollback_transaction (0);
    return ( NFM_E_SQL_STMT);
  }

  status = NFMset_item_status (catalog_name, "", "", item_no, 
                               "O" , NFM_LOCK_COMMIT, "");
  if (status != NFM_S_SUCCESS)
  {
    NFMlock_table (fcat_name);
    sprintf (sql_str, "%s %s %s %d %s %d",
             "delete from", fcat_name, "where n_itemnum = ", item_no, 
             "and n_fileversion = ", file_version+1);
    SQLstmt(sql_str);
    SQLstmt ("COMMIT WORK");
      _NFMfs_undo_send_files (&file_list);
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                        NFM_NO_LOCK, "");
    free (sto_list);
    MEMclose (&list);
    MEMclose (&file_list);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
    NFMrollback_transaction (0);
    return (status);
  }

  /* At this point, the save item files is considered successful. The following
     code is for updating LFM and purging */

  for (x = upd_lfm = 0; x < list->rows; x++)
  {
    index = list->columns * x;
  
    if (strlen (data[index+q_fileco]))
    {
      _NFMdebug ((fname, 
        "record already exists in fmsafiles, update ver, cat_no %d\n", cat_no));
      if (upd_lfm) 
      {
        strcat (upd_lfm_str, " or ");
      }
      else
      {
        upd_lfm = 1;
        sprintf (upd_lfm_str, "%s %d %s %s %s %d %s %d %s",
                 "update nfmsafiles set n_fileversion =", file_version+1,
                 "where n_sano =", data[index+q_cosano], "and n_catalogno =",
                 cat_no, "and n_itemno =", item_no, "and (");
      }
      strcat (upd_lfm_str, "n_filenum = ");
      strcat (upd_lfm_str, data[index+q_filenum]);
    }
    else
    {
      _NFMdebug ((fname, "record is not in the nfmsafiles, add to it\n"));
      sprintf (sql_str, 
               "%s %s %s %s, %d, %d, '%s', %s, %d, '%s', '%s', %s",
               "insert into nfmsafiles (n_sano, n_catalogno, n_itemno,",
               "n_filename, n_filenum, n_fileversion, n_co, n_copy, n_ref)",
               "values (", data[index+q_cosano], cat_no, item_no,
               data[index+q_cofilename], data[index+q_filenum], 
               file_version+1, "Y", "N", "0)");

      status = NFMlock_table ("nfmsafiles");
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        if (DM_MANAGER)
          ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
            "Save Document Files", "update local file manager");
        else
          ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
            "Save Item Files", "update local file manager");
        NFMrollback_transaction (0);
        return (NFM_W_SQL_STMT);
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "failed to update nfmsafile\n"));
        if (DM_MANAGER)
          ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
            "Save Document Files", "update local file manager");
        else
          ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
            "Save Item Files", "update local file manager");
        NFMrollback_transaction (0);
        return (NFM_W_SQL_STMT);
      }
      SQLstmt ("COMMIT WORK");
    }
  }

  if (upd_lfm)
  {
    strcat (upd_lfm_str, ")");
    status = NFMlock_table ("nfmsafiles");
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
        "Save Item Files", "update local file manager");
      NFMrollback_transaction (0);
      return (NFM_W_SQL_STMT);
    }
    status = SQLstmt (upd_lfm_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "failed to update nfmsafile\n"));
      ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
        "Save Item Files", "update local file manager");
      NFMrollback_transaction (0);
      return (NFM_W_SQL_STMT);
    }
    SQLstmt ("COMMIT WORK");
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (sto_list);
    MEMclose (&file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }
  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sto_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }

  /* prepare buffer for the file server */

  /* if versionlimit not given, default to 1 and WARN the user */

  if (version_limit > 0)
    purge_limit = version_limit;
  else
    purge_limit = 1;

  if (file_version+1-purge_limit < 0)
  {
    _NFMdebug ((fname, "no need to purge\n"));
    goto SIend;
  }

  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    free (sto_list);
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);
  }

  sprintf (w_clause, "%s %d %s %d",
     "where n_fileversion <=", file_version + 1 - purge_limit, 
     "and n_itemnum =", item_no); 

  status = NFMcommon_queries(catalog_name, w_clause, 
                  dumb_str, &dumb_value, &list, NFM_ITEM_FILE_QUERY,
                  NFM_RETURN_MEMPTR, NFM_LOCK_COMMIT);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, "No rows qualified for purging\n"));
    goto SIend;
  }
  else if (status != NFM_S_SUCCESS)
  {
    MEMclose (&file_list);
    _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (&file_list);
    _NFMdebug ((fname, "MEMbuild_array (fileversion info) 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

  sprintf (temp_str, "%d", NFM_PURGE_FILE);
  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x++)
  {
    index = list->columns * x;

    if (atol (data[index+q_fileversion]) == 0 || 
        !strlen (data[index+q_fileco]) )
      continue;

    if (atol (data[index+q_archiveno]) > 0)
      upd_bkup = 1;

    /* purge  storage area information */
    for (y = 0, cur_sto = sto_list; y < sto_no; y ++)
    {
      if ((cur_sto+y)->sano == atol (data[index+q_cisano]))
      {
        sprintf (row_str,
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (cur_sto+y)->sano,
        (cur_sto+y)->nodename, (cur_sto+y)->username, (cur_sto+y)->passwd,
        (cur_sto+y)->pathname, (cur_sto+y)->devicetype, 
        (cur_sto+y)->plattername,
        (cur_sto+y)->partition, (cur_sto+y)->nfs, (cur_sto+y)->compress, 
        (cur_sto+y)->machid,
        (cur_sto+y)->opsys, (cur_sto+y)->tcpip, (cur_sto+y)->xns, 
        (cur_sto+y)->decnet, (cur_sto+y)->netware);
        break;
      }
    }

    strcat (row_str, data[index]); strcat (row_str, "\1");
    strcat (row_str, "\1");
    status = NFMget_file_name (NFMglobal.NFMuserid, 
             cat_no, atol(data[index]), filename);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&file_list);
      MEMclose (&list);
      _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
      NFMrollback_transaction (0);
      return (status);
    }
    strcat (row_str, filename); strcat (row_str, "\1");
    strcat (row_str, "\1");
    strcat (row_str, "\1");
    strcat (row_str, "\1");
    strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

    _NFMdebug ((fname, "MEMwrite [%s]\n", row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&list);
      MEMclose (&file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      NFMrollback_transaction (0);
      return (NFM_E_MEM);
    }
    if (NFM_FTR_INITED)
    {
      status = NFT_delete_entry (cat_no, item_no, atol(data[index]));
      if (status != UTI_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFT_delete_entry 0x%.8x\n", status));
      }
      ERRreset_struct ();
    }
    do_purge = 1;
  }
  /* move the files */

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

  if (do_purge)
  {
    status = NFMfs_purge (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_purge 0x%.8x\n", status));
      if (DM_MANAGER)
        ERRload_struct (NFM, NFM_W_PURGE_FILES_FAILED, "%s", 
                        "Save Document Files");
      else
        ERRload_struct (NFM, NFM_W_PURGE_FILES_FAILED, "%s", "Save Item Files");
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      NFMrollback_transaction (0);
      return (NFM_W_PURGE_FILES_FAILED);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&file_list);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    if (DM_MANAGER)
      ERRload_struct (NFM, NFM_W_MEM, "%s%s", "Save Document Files", 
                      "purge files");
    else
      ERRload_struct (NFM, NFM_W_MEM, "%s%s", "Save Item Files", "purge files");
    NFMrollback_transaction (0);
    return (NFM_W_MEM);
  }

  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    if (DM_MANAGER)
      ERRload_struct (NFM, NFM_W_MEM, "%s%s", 
                      "Save Document Files", "purge files");
    else
      ERRload_struct (NFM, NFM_W_MEM, "%s%s", "Save Item Files", "purge files");
    NFMrollback_transaction (0);
    return (NFM_W_MEM);
  }

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s", "Save Files", 
                    "purge files");
    NFMrollback_transaction (0);
    return (NFM_W_SQL_STMT);
  }

  sprintf (sql_str, "%s %s %s %d %s %d %s",
           "delete from", fcat_name, "where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_archiveno is NULL"); 

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
  }

  if (upd_bkup)
  {
    sprintf (sql_str, "%s %s %s %d %s %d %s",
             "update", fcat_name, "set n_fileco = 'O' where n_fileversion <=", 
             file_version + 1 - purge_limit, "and n_itemnum =", 
             item_no, "and n_archiveno > 0"); 

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    }
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
  }

  SIend:
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));

  _NFMdebug ((fname, "EXIT: successfully 0x%.8x version = %d\n", 
                            NFM_S_SUCCESS, version_limit));

  if (version_limit < 1)
  {
    ERRload_struct (NFM, NFM_W_INVALID_VERSION_LIMIT, "%d", version_limit);  
    return (NFM_W_INVALID_VERSION_LIMIT);
  }

  return (NFM_S_SUCCESS);
}
