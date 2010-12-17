#include "NFMuinc.h"
#include "NFMuglobal.h"

extern long special_msg;

long NFMcheckin_item (catalog_name, catalog_no, item_name, item_revision,
                      working_area, wf_info, operation)

char *catalog_name; /* item's catalog */
long catalog_no;
char *item_name; /* item's name */
char *item_revision; /* item's revision */
char *working_area; /* check in from for the 1st time checkin */
struct NFMwf_info wf_info; /* I: turn on/off validation and set_to_state */
struct NFMoperation operation; /* I: file transfer mode */

{
  char *fname="NFMcheckin_item";
  char tmp_str[1024], tmp_cofilename[NFM_COFILENAME+1],
       tmp_type [NFM_FILETYPE+1];
  char fcat_name[NFM_CATALOGNAME+3], sql_str[2048], sub_str[1024], 
       row_str[1024], w_clause[1024], move_move_str[10], first_temp_str[10], 
       temp_str[10], temp_str1[10], file_status[NFM_STATUS+1], 
       file_status1[NFM_STATUS+1], file_co[NFM_FILECO+1], 
       datetime_str[NFM_DATE+1], datetime[NFM_DATE+1], 
       filename[NFM_CIFILENAME+1], temp_datetime[NFM_DATE+1], 
       itemdesc[NFM_ITEMDESC+1], dumb_str[1024], error_msg[1024], 
       type_m_file[NFM_COFILENAME+1], ftr_row[2048], ftr_tmp[40];
  char **data, **data1, **column, **format;
  long  x, y, count, index, index1, first_time, first_move=0, move_move=0,
        nothing, sto_no; long i_co, i_cp, i_ref, q_itemno=0, q_status=1, 
        q_archivestate=2, q_lock=3, q_versionlimit=5, q_itemdesc=6, type_m=0,
        type_acad=0, known=0, archive_no=0, micro, m_set=0, error_no,
        file_version, max_file_no, file_no, version_limit, purge_limit,
        item_no, status, status1, degree, dumb_value, fs_net_id, 
        no_move_file_warning=0, no_file_warning=0, ftr_status=UTI_S_SUCCESS,
        tmp_filenum, tmp_len;
  int subsystem;
  long  name_length=0;
  long _DMcall_do_nothing (), _nfm_find_index ();
  MEMptr list=NULL, list1=NULL, dumb_list= NULL, file_list=NULL, 
         ftr_file_list=NULL;
  struct NFMlfm_file *lfm_files=NULL;
  struct NFMsto_info *sto_list=NULL, check_sto;
  struct NFMitem_entry item_entry;
  char   theItemName[100];           /* PS */
  char   theItemRevision[100];

#include "NFMuindexes.h"

  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] user_name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation.transfer, operation.delete, operation.purge,
                       NFMglobal.NFMusername));

  sprintf (fcat_name, "f_%s", catalog_name);

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
        _DMcall_do_nothing (3);
      return (status);
    }
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    degree = 0;
    _NFMcleanup (&degree, wf_info, "", "", "");
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

/* add a tic to each of the tics in item name and revisions - PS 11th dec 95 */
 
   NFMtic_to_tics(item_name, theItemName);
   NFMtic_to_tics(item_revision, theItemRevision);
 
/* retrieve item's information from catalog */

/* PS
  sprintf (w_clause, "%s '%s' %s '%s'",
    "where n_itemname = ", item_name, "and n_itemrev = ",
    item_revision);
*/

  sprintf (w_clause, "%s '%s' %s '%s'",
    "where n_itemname = ", theItemName, "and n_itemrev = ",      
    theItemRevision);

  status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
                               &dumb_value, &list, NFM_ITEM_QUERY,
                              NFM_RETURN_MEMPTR, NFM_LOCK_NO_COMMIT);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose(&list);
    ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMcommon_queries  0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (NFM_E_MESSAGE);
  }

  data = (char **) list->data_ptr;
  item_no = atol (data[q_itemno]);
  strncpy (file_status, data[q_status], NFM_STATUS);
  file_status[NFM_STATUS] = '\0';
  strncpy (itemdesc, data[q_itemdesc], NFM_ITEMDESC);
  itemdesc[NFM_ITEMDESC] = '\0';
  version_limit = atol (data[q_versionlimit]);

  MEMclose (&list);

  /* make sure item is eligible for check in */

  if (strlen(file_status))
  {
    first_time = 0;
    if (strncmp(file_status, "O",1) && strncmp(file_status, "ON", 2)   )
    {
      _NFMload_error_message (item_name, item_revision, NFM_CHECK_IN, 
                      NFM_ITEM, file_status, data[q_archivestate]);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "Cannot checkin item because file status = %s\n",
                  file_status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_BAD_FILE_STATUS);
    }
  }
  else
  {
    first_time = 1; 
    if (strcmp(data[q_lock], "N"))
    {
      ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "Cannot checkin item because n_itemlock = %s\n",
                  data[4]));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_ITEM_LOCKED);
    }
  }

  /* set item file status */

  status = NFMset_item_status (catalog_name, "", "", item_no, "TI", 
           NFM_COMMIT_ONLY, "");
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMset_item_status [%d] [%s] failed 0x%.8x\n",
                item_no, "TI"));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  /* retrieve item's information from f_<catalog> */

  sprintf (sql_str, "%s %s %s %d %s %s %s %d %s",
          "select * from",
           fcat_name, "where n_itemnum =", item_no, 
           "and n_fileversion = (select max(n_fileversion) from", 
         fcat_name, "where n_itemnum =", item_no, ") order by n_filetype ASC");

  status = _NFMlock_and_retrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
             &dumb_value, &list, NFM_LOCK_COMMIT, fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL); 
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "_NFMlock_and_retrieve_values 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (NFM_E_BAD_ITEM);
  }

  column = (char **) list->column_ptr;
  format = (char **) list->format_ptr;

  for (x = 0; x < list->columns; x ++)
  {
    if (!strcmp (column[x], "n_fileno"))            i_fileno = x;
    else if (!strcmp (column[x], "n_itemnum"))      i_itemnum = x;
    else if (!strcmp (column[x], "n_filenum"))      i_filenum = x;
    else if (!strcmp (column[x], "n_cofilename"))   i_cofilename = x;
    else if (!strcmp (column[x], "n_fileversion"))  i_fileversion = x;
    else if (!strcmp (column[x], "n_filetype"))     i_filetype = x;
    else if (!strcmp (column[x], "n_fileclass"))    i_fileclass = x;
    else if (!strcmp (column[x], "n_restoreflag"))  i_restoreflag = x;
    else if (!strcmp (column[x], "n_archiveno"))    i_archiveno = x;
    else if (!strcmp (column[x], "n_cisano"))       i_cisano = x;
    else if (!strcmp (column[x], "n_cifilename"))   i_cifilename = x;
    else if (!strcmp (column[x], "n_ciuser"))       i_ciuser = x;
    else if (!strcmp (column[x], "n_cidate"))       i_cidate = x;
    else if (!strcmp (column[x], "n_cifilesize"))   i_cifilesize = x;
    else if (!strcmp (column[x], "n_cocomment"))    i_cocomment = x;
    else if (!strcmp (column[x], "n_cosano"))       i_cosano = x;
    else if (!strcmp (column[x], "n_couser"))       i_couser = x;
    else if (!strcmp (column[x], "n_codate"))       i_codate = x;
    else if (!strcmp (column[x], "n_fileco"))       i_fileco = x;
    else if (!strcmp (column[x], "n_convertind"))   i_convertind = x;
  }

  data = (char **) list->data_ptr;

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("info from f_<catalog>", list, _NFMdebug_st.NFMdebug_file);

  /* 10/31/94 This section of code is for Mobil short term  solution */

  if ( strcmp (data[i_filetype], "DOCN") == 0 ||
       strcmp (data[i_filetype], "WPN") == 0 ||
       strcmp (data[i_filetype], "LOTN") == 0 ||
       strcmp (data[i_filetype], "XLSN") == 0   ) 
  {
    if (list->rows == 1)
    {
      _NFMdebug  ((fname, "A special item for Mobil, add a raster file\n"));
      /* lock the f_<catalog>  and select the max(n_fileno) */

      sprintf (tmp_str, "select max(n_fileno) from %s", fcat_name);  
      status = _NFMlock_and_retrieve_values (tmp_str, NFM_RETURN_VALUE, 
               dumb_str, &dumb_value, &dumb_list, NFM_LOCK_NO_COMMIT, 
               fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Failed to add raster file\n"));
        MEMclose (&list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (status);
      }
      /* now, dumb_value has new n_fileno to be for the raster file */

      /* add the file */


      for (name_length = 0; name_length < strlen (data[i_cofilename]); 
           name_length ++)
      {
        if (data[i_cofilename][name_length] == '.')
          break;
      }

      _NFMdebug ((fname, "name_length = %d\n", name_length));

      strncpy (tmp_cofilename, data[i_cofilename], 
               name_length);
  
      tmp_cofilename [name_length] = '\0';

      strcat (tmp_cofilename, ".cit");

      if (strcmp(data[i_filetype], "WPN") == 0 )
        strcpy (tmp_type, "WPR");
      else if (strcmp(data[i_filetype], "DOCN") == 0 )
        strcpy (tmp_type, "DOCR");
      else if (strcmp(data[i_filetype], "XLSN") == 0 )
        strcpy (tmp_type, "XLSR");
      else if (strcmp(data[i_filetype], "LOTN") == 0 )
        strcpy (tmp_type, "LOTR");

      tmp_filenum = atol (data[i_filenum]) + 1;

      sprintf (tmp_str, 
        "%s %s %s %s %s (%d, %d, %d, '%s', %s, '%s', '%s', %s, %s, '%s')",
        "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
        "n_cofilename, n_fileversion, n_filetype, n_fileclass,",
        "n_cisano, n_cosano, n_couser) values", ++dumb_value,
        item_no, tmp_filenum, tmp_cofilename,
        data[i_fileversion], tmp_type, data[i_fileclass],
        data[i_cisano], (strlen(data[i_cosano])? data[i_cosano]: "NULL"),
        (strlen(data[i_couser]) ? data[i_couser]: ""));

      status = SQLstmt (tmp_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "failed to execute add file query\n"));
        MEMclose (&list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (NFM_E_SQL_STMT);
      }

      SQLstmt ("COMMIT WORK");

      /* now, a raster file is added to the item */

      /* reexecute the query and rebuild  the "list" */

      MEMclose (&list);
      status = _NFMlock_and_retrieve_values (sql_str, 
               NFM_RETURN_MEMPTR, dumb_str,
               &dumb_value, &list, NFM_LOCK_COMMIT, fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "_NFMlock_and_retrieve_values 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (NFM_E_BAD_ITEM);
      }
      column = (char **) list->column_ptr;
      format = (char **) list->format_ptr;

      for (x = 0; x < list->columns; x ++)
      {
        if (!strcmp (column[x], "n_fileno"))            i_fileno = x;
        else if (!strcmp (column[x], "n_itemnum"))      i_itemnum = x;
        else if (!strcmp (column[x], "n_filenum"))      i_filenum = x;
        else if (!strcmp (column[x], "n_cofilename"))   i_cofilename = x;
        else if (!strcmp (column[x], "n_fileversion"))  i_fileversion = x;
        else if (!strcmp (column[x], "n_filetype"))     i_filetype = x;
        else if (!strcmp (column[x], "n_fileclass"))    i_fileclass = x;
        else if (!strcmp (column[x], "n_restoreflag"))  i_restoreflag = x;
        else if (!strcmp (column[x], "n_archiveno"))    i_archiveno = x;
        else if (!strcmp (column[x], "n_cisano"))       i_cisano = x;
        else if (!strcmp (column[x], "n_cifilename"))   i_cifilename = x;
        else if (!strcmp (column[x], "n_ciuser"))       i_ciuser = x;
        else if (!strcmp (column[x], "n_cidate"))       i_cidate = x;
        else if (!strcmp (column[x], "n_cifilesize"))   i_cifilesize = x;
        else if (!strcmp (column[x], "n_cocomment"))    i_cocomment = x;
        else if (!strcmp (column[x], "n_cosano"))       i_cosano = x;
        else if (!strcmp (column[x], "n_couser"))       i_couser = x;
        else if (!strcmp (column[x], "n_codate"))       i_codate = x;
        else if (!strcmp (column[x], "n_fileco"))       i_fileco = x;
        else if (!strcmp (column[x], "n_convertind"))   i_convertind = x;
      }

      data = (char **) list->data_ptr;

      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("info from f_<catalog>", list, 
                          _NFMdebug_st.NFMdebug_file);
 
    }
    else if ((list->rows == 2) && 
             (strcmp (data[list->columns + i_filetype], "DOCR") ||
              strcmp (data[list->columns + i_filetype], "WPR")  ||
              strcmp (data[list->columns + i_filetype], "LOTR") ||
              strcmp (data[list->columns + i_filetype], "XLSR")   ) )
    {
      _NFMdebug ((fname, "Native and raster file are there, continue\n"));
    }
    else
    {
      _NFMdebug ((fname, "The item has a file type == \n\
                   DOCN || WPN || LOTN || EXCN, AND other file TYPES\n"));
      /*ERRload_struct (NFM, NFM_E_MOBIL_F_TYPES, "%d", list->rows);*/
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
        "Raster file is not found"); 
      MEMclose (&list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_FAILURE);
    } 
  }
  /* end of 10/31/94 short solution */
                
                
  file_version = atol (data[i_fileversion]);

  _NFMdebug ((fname, "file status: [%s] %s check the checked-out-user\n",
              file_status, (first_time? "DO NOT" : "DO")));

  /* mack sure COuser == CIuser */

  if (!first_time && strcmp (data[i_couser], NFMglobal.NFMusername))
  {
    MEMclose (&list);
    if (DM_MANAGER)
      ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "check in the document", 
         "document");
    else
      ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "check in the item", 
         "item");
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "Not the checkout user \n"));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (NFM_E_NOT_CO_USER);
  }
 
  /* get date and time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  _NFMdebug ((fname, "datetime = %s\n", datetime));

  /* If item was checked-out, CI-from-location == CO-location,
     else CI-from-location == active-WA */

  sto_list = (struct NFMsto_info *) calloc ((list->rows) + 1, 
              sizeof (struct NFMsto_info));

  if (!first_time)
  {
     sto_list->sano = atol (data[i_cosano]);
     _NFMdebug ((fname, "This is NOT first time checkin, FROM = CO = %d\n",
                  sto_list->sano));
  }
  else 
    strcpy (sto_list->saname, working_area);

  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
           sto_list->nodename, sto_list->username, sto_list->passwd,
           sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
           sto_list->partition, sto_list->nfs, sto_list->compress, 
           sto_list->machid, sto_list->opsys, sto_list->tcpip, sto_list->xns,
           sto_list->decnet, sto_list->netware);

  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list); free (sto_list);
    _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  /* if client == DM_MANAGER && item is checked-out, make sure
     CI-from-location == DM_MANAGER location because there is
     no indepent Fileserver implemented on PC as 5/26/94 */

  if (DM_MANAGER && 
      (!first_time && strcmp (sto_list->saname, working_area)) ) 
  {
    strcpy (check_sto.saname, working_area);
    check_sto.sano = 0;
    status = NFMget_storage_info (&(check_sto.saname), &(check_sto.sano), 
           &(check_sto.nodename), &(check_sto.username), &(check_sto.passwd),
           &(check_sto.pathname), &(check_sto.devicetype), 
           &(check_sto.plattername), 
           &(check_sto.partition), &(check_sto.nfs), &(check_sto.compress), 
           &(check_sto.machid), &(check_sto.opsys), &(check_sto.tcpip), 
           &(check_sto.xns),
           &(check_sto.decnet), &(check_sto.netware));
    if (strcmp (sto_list->nodename,  check_sto.nodename) )
    {
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      MEMclose (&list); free (sto_list);
      _NFMdebug ((fname, 
            "the file(s) was/were checked out to a different PC\n"));
      ERRload_struct (NFM, NFM_E_CI_FROM_DIFF_PC, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_CI_FROM_DIFF_PC);
    }
  }

  /* if clien == NFM, do not allow CI of an item that was CO
     USED DMM */

  if (!DM_MANAGER && (strcmp (sto_list->machid, "PC") == 0) &&
       (strcmp (sto_list->opsys, "WINDOS") == 0)                )
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list); free (sto_list);
    _NFMdebug ((fname, "Can not check in from PC, windows-DOS\n"));
    ERRload_struct (NFM, NFM_E_NFM_CLIENT_CI_PC, "", NULL);
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (NFM_E_NFM_CLIENT_CI_PC);
  }

  /* if operation.transfer == NFM_NO_TRANSFER, update <catalog> & f_<catalog> */

  if (operation.transfer == NFM_NO_TRANSFER ||
      (list->rows == 1 && atol (data[i_fileversion]) == 0 && 
        !strlen(data[i_cofilename]) ))
  {
    _NFMdebug ((fname, "%s\n",
                ((operation.transfer == 0)? 
                  "operation.transfer == NFM_NO_TRANSFER":
                  "Item does not have associated files") ));
    free (sto_list);
    SQLstmt ("COMMIT WORK");
    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (status);
    }
    for (x = 0; x < list->rows; x++)
    {
      count = list->columns * x;
      if (strlen (data[count+i_fileco]))
        strncpy (file_co, "N", NFM_FILECO);
      else
        strncpy (file_co, "", NFM_FILECO);

      sprintf (sql_str, 
               "%s %s %s %s '%s', %s '%s', %s '%s' %s %d %s %s", 
               "update", fcat_name, "set n_cosano = NULL, n_couser = NULL,",
               "n_codate = NULL, n_ciuser =", NFMglobal.NFMusername,
               "n_cidate = timestamp",
               datetime, "n_fileco =", file_co, "where n_itemnum =",
               item_no, "and n_fileversion =", data[count+i_fileversion] ); 
      
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose(&list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return ( NFM_E_SQL_STMT);
      } 
    }
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM,
                                    NULL, NULL, list, catalog_name, 0,
                                    item_no, 0, NFM_RLBK_FCAT_NT);
      MEMclose(&list);
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return ( NFM_E_SQL_STMT);
    }

    if (! strcmp (file_status, "O"))
    {
      strncpy (file_status1, "I", NFM_STATUS);
      no_move_file_warning = 1;
    }
    else
    {
      strncpy (file_status1, "", NFM_STATUS);
      no_file_warning = 1;
    }
 
    status = NFMset_item_status (catalog_name, "", "", item_no, 
                                 file_status1, NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM,
                                    NULL, NULL, list, catalog_name, 0,
                                    item_no, 0, NFM_RLBK_FCAT_NT);
      MEMclose (&list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (status);
    }

    NFMstart_transaction (0);
 
    MEMclose (&list);
       
    if (no_move_file_warning)
    {
      _NFMdebug ((fname, "EXIT: operation == NFM_NO_TRANSFER\n"));
      if (DM_MANAGER)
      {
        _DMcall_do_nothing (3);
        return (NFM_S_SUCCESS);
      }
      ERRload_struct (NFM, NFM_W_NO_FILE_MOVE, "", NULL);
      return (NFM_W_NO_FILE_MOVE);
    }
    else if (no_file_warning)
    {
      _NFMdebug ((fname, "EXIT: no file associated\n"));
      if (DM_MANAGER)
      {
        _DMcall_do_nothing (3); 
        return (NFM_S_SUCCESS);
      }
      ERRload_struct (NFM, NFM_W_NO_FILE, "", NULL);
      return (NFM_W_NO_FILE);
    }
    _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }
  else  /* operation = NFM_TRANSFER */
  { 
    status = _DMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
      MEMclose(&list); free (sto_list);
      MEMclose(&file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (status);
    }

    status = _DMbuild_ftr_buffer (&ftr_file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
      MEMclose(&list); free (sto_list);
      MEMclose(&file_list); MEMclose (&ftr_file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (status);
    }

    sprintf (row_str,
     "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
     sto_list->sano, sto_list->nodename, sto_list->username, 
     sto_list->passwd, sto_list->pathname, sto_list->devicetype, 
     sto_list->plattername,
     sto_list->partition, sto_list->nfs,/* mountpoint */
     sto_list->compress, sto_list->machid, sto_list->opsys, 
     sto_list->tcpip, sto_list->xns, sto_list->decnet,
     sto_list->netware, "\1\1\1\1\1\1\1\1\1\1\1\1\1\1");

    _NFMdebug ((fname, "MEMwrite %s\n", row_str));

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&list); free (sto_list);
      MEMclose(&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_MEM);
    }

    strcpy (ftr_row, row_str);
    strcat (ftr_row, "\1");
    _NFMdebug ((fname, "ftr_row [%s]\n", ftr_row));

    status = MEMwrite (ftr_file_list, ftr_row);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&list); free (sto_list);
      MEMclose(&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_MEM);
    }

    for (x = 0, sto_no = 1; x < list->rows; x ++)
    {
      index = list->columns * x;
      _NFMdebug ((fname, "data[index+i_cisano] = %s\n",
                            data[index+i_cisano]));

      /* check to see if the cisano already on the list */

      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->sano: %d\n", y,
                    (sto_list+y)->sano));
        if ( (sto_list+y)->sano  == atol (data[index + i_cisano]) )
        {
          _NFMdebug ( (fname, "storage_area_no found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        _NFMdebug ((fname, "n_cisano not found in the list, add to it \n"));
        if (strlen (data[index+i_cisano]) == 0 ||
            atol(data[index+i_cisano]) == 0      )
        {
          _NFMdebug ((fname, "Invalid ci-sto\n"));
          MEMclose (&list); free (sto_list);
          MEMclose(&file_list); MEMclose (&ftr_file_list);
          ERRload_struct (NFM, NFM_E_INVALID_STORAGE_AREA, "%s", "0/NULL");
          degree = 3;
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return (NFM_E_INVALID_STORAGE_AREA);
        }
        (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
        sto_no++;
      }
    }

    status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
      MEMclose (&list); free (sto_list);
      MEMclose(&file_list); MEMclose (&ftr_file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (status);
    }

    SQLstmt ("COMMIT WORK");

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
          MEMclose (&list); free (sto_list);
          MEMclose(&file_list); MEMclose (&ftr_file_list);
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          degree = 3;
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return (NFM_E_SQL_QUERY);
        }
      }
    }

    sprintf (sql_str, "select max(n_fileno) from %s", fcat_name);

    status = _NFMlock_and_retrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                &file_no, &dumb_list, NFM_LOCK_NO_COMMIT, fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_and_retrieve_values 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return (NFM_E_SQL_QUERY);
    }
    max_file_no = file_no;
    _NFMdebug ((fname, "file_no %d max_file_no %d\n", file_no,
                       max_file_no));

    sprintf (temp_str, "%d", NFM_MOVE); /* for FTO_STATUS1 in the buffer going
                                           to FS */
    sprintf (first_temp_str, "%d", NFM_MOVE_FIRST_TIME);
    sprintf (move_move_str, "%d", NFM_MOVE_MOVE);

    for (x = 0; x < list->rows; x++)
    {
      index = list->columns * x;

      sprintf (sql_str, "%s %s %s %s %s ",
               "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
               "n_fileversion, n_fileclass, n_filetype, n_fileco,",
               "n_cifilename, n_cisano, n_ciuser, n_cidate, n_cofilename");

      sprintf (sub_str, "%s (%d, %d, %s, %d, '%s', '%s', \
               '%s', '%s', %s, '%s', timestamp '%s', '%s'",
               ") values ", 
               ++max_file_no, item_no, data[index+i_filenum], file_version+1, 
               data[index+i_fileclass], data[index+i_filetype], 
               "N", data[index+i_cifilename], 
               data[index+i_cisano], NFMglobal.NFMusername, datetime, 
               data[index+i_cofilename]);

      for (y = 0; y < list->columns; y ++)
      {
        /* take care of UDA */
        if ( y == i_fileno || y == i_itemnum || y == i_filenum ||
             y == i_cofilename || y == i_fileversion || y == i_filetype ||
             y == i_fileclass || y == i_restoreflag || y == i_archiveno ||
             y == i_cisano || y == i_cifilename || y == i_ciuser ||
             y == i_cidate || y == i_cifilesize || y == i_cocomment ||
             y == i_cosano || y == i_couser || y == i_codate ||
             y == i_fileco || y == i_convertind )
          continue;
        else
        {
          if (strlen (data[index+y]))
          {
            strcat (sql_str, ",");
            strcat (sql_str, column[y]);
     
            if (!strncmp (format[y], "char", 4))
            {
              strcat (sub_str, ", '");
              strcat (sub_str, data[index+y]);
              strcat (sub_str, "'");
            }
            else if (!strcmp (format[y], "integer"))
            {
              strcat (sub_str, ",");
              strcat (sub_str, data[index+y]);
            }
            else
            {
              NFMascii_to_timestamp_format (data[index+y], temp_datetime);
              strcat (sub_str, ", timestamp '");
              strcat (sub_str, temp_datetime);
              strcat (sub_str, "'");
            }
          }
        }
      }
      strcat (sql_str, sub_str);
      strcat (sql_str, ")");

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (status);
      } 

      if (strlen (data[index+i_fileco]))
      {
        /* update the record that has file checked out */
        sprintf (sql_str,
                 "%s %s %s %s %d %s %d %s %s", 
                 "update", fcat_name, "set n_fileco = 'N'", 
                 "where n_itemnum =", item_no, "and n_fileversion =",
                 file_version, "and n_filenum =", data[index+i_filenum]); 

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          MEMclose (&list); free (sto_list);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return ( NFM_E_SQL_STMT);
        }
      }
      /* check in TO storage area information */
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                             y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+i_cisano]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
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
          break;
        }
      }
      if (y >= sto_no)
      {
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "invalid cisano\n"));
        ERRload_struct (NFM, NFM_E_INVALID_STORAGE_AREA, "%s", 
                      "0/NULL");
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return ( NFM_E_MESSAGE);
      }

      sprintf (temp_str1, "%d", max_file_no);
      strcat (row_str, temp_str1); strcat (row_str, "\1");
      if (strlen (data[index+i_cifilename]))
      {
        if (first_time  || !(strlen (data[index+i_fileco])))
        {
          strncpy (filename, "\0", NFM_CIFILENAME);
          first_move = 1;
        }
        else
        {
          status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, 
                                    atol(data[index+i_fileno]), 
                                    filename);
          if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            MEMclose (&list); free (sto_list);
            MEMclose (&file_list); MEMclose (&ftr_file_list);
            degree = 3;
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
            if (DM_MANAGER)
              _DMcall_do_nothing (3);
            return (status);
          }
          move_move = 1;
        }
        strcat (row_str, filename); strcat (row_str, "\1");
        strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
      }
      else
      {
        strcat (row_str, "\1");
        status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, max_file_no,
                                    filename);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          MEMclose (&list);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          degree = 3;
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1");
      }
      strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
      if (! strcmp (data[index+i_filetype], "M"))
      {
        type_m = 1;
        strncpy (type_m_file, data[index+i_cofilename], NFM_COFILENAME);
      }
      else if (! strcmp (data[index+i_filetype], "DWG"))
      {
        type_acad = 1; /* added for DM/MANAGER to handle autocad files, 
                          the name "type_m_file" might
                          be misleading, it could be changed later */
        strncpy (type_m_file, data[index+i_cofilename], NFM_COFILENAME);
      }
      strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
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

      sprintf (dumb_str, "%s\1%d\1%s\1%s\1%s\1", catalog_name, item_no, 
                 item_revision, item_name, itemdesc);
      strcat (row_str, dumb_str);

      _NFMdebug ((fname, "row_str: %s\n", row_str));

      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (NFM_E_MEM);
      }

      strcpy (ftr_row, row_str);
      sprintf (ftr_tmp, "%d\1", catalog_no);
      strcat (ftr_row, ftr_tmp);
      _NFMdebug ((fname, "ftr_row[%s]\n", ftr_row));
      status = MEMwrite (ftr_file_list, ftr_row);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
          _DMcall_do_nothing (3);
        return (NFM_E_MEM);
      }
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      /* rollback, remove inserted record, and update n_fileco */
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      if (DM_MANAGER)
        _DMcall_do_nothing (3);
      return ( NFM_E_SQL_STMT);
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file transfer buffer", file_list, 
                        _NFMdebug_st.NFMdebug_file);

    /* move the files */
    if (DM_MANAGER)
      status = _DMfs_send_files (&file_list, &fs_net_id, 0);
    else
      status = _NFMfs_send_files (&file_list, &fs_net_id, 0);

    if (_NFMdebug_st.NFMdebug_on)
    { MEMprint_buffer ("file transfer buffer", file_list, 
                          _NFMdebug_st.NFMdebug_file); }

    status1 = MEMbuild_array (file_list);

    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_send_files 0x%.8x\n", status));
      NFMopen_message_buffer ();
      if(DM_MANAGER)
      {
        special_msg = 1;
        _DMcall_do_nothing (2);
      }
      else
        NFMdisconnect (&fs_net_id);
      _NFMstack_error_from_buffer (file_list, catalog_name, item_name, 
                               item_revision, NFM_CHECK_IN, (MEMptr) NULL);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      /* update the record that has file checked out */
      sprintf (sql_str,
        "%s %s %s %s %d %s %d %s",
        "update", fcat_name, "set n_fileco = 'Y'",
        "where n_itemnum =", item_no, "and n_fileversion =",
        file_version, "and n_fileco = 'N'");
      SQLstmt (sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    if (status1 != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status1));
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
      else
        NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no,
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list); MEMclose (&ftr_file_list);
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    /* is NFM_FTR_INITED and client == DM_MANAGER
       yes - call _NFMmount_add_index
       no - do nothing */

    if (NFM_FTR_INITED && DM_MANAGER)
    {
      _NFMdebug ((fname, "FTR engine is enabled & client == DMM\n"));
      MEMbuild_array (ftr_file_list);
      status = _NFMmount_add_index (ftr_file_list, NFM_ITEM);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "_NFMmount_add_index 0x%.8x\n", status));
        ftr_status = status;
      }
      if (status != UTI_E_INDEX && status != UTI_E_ADD_FILE)
        ERRreset_struct ();
    }
    else if (NFM_FTR_INITED)
    {
      _NFMdebug ((fname, "FTR engine is enabled but the client is not DMM\n"));

      MEMbuild_array (ftr_file_list);

      /* since client != DMM, need to retrieve keywords of the last file
         which is stored in collection with an older file no, put this
         older file no in FTO_ITEMDESC field */

      for (x = 0; x < list->rows; x ++)
      {
        index = list->columns * x;
        _NFMdebug ((fname, "write old file no [%s]\n", data[index+i_fileno]));
        status = MEMwrite_data (ftr_file_list, data[index+i_fileno], 2 + x, 
                                FTO_ITEMDESC+1);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname,
            "Failed to write old fileno [%s] to item-description field\n",
             data[i_fileno]));
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
        "FTR engine is not enabled \n"));
      ERRload_struct (NFM, NFM_W_KW_LOSS, "", NULL); 
    }
    MEMclose (&ftr_file_list);

    if (NFM_FTR_INITED && (ftr_status == UTI_S_SUCCESS))
    {
      _NFMdebug ((fname, "mark the previous record for delete in FTR\n"));
      for (x = 0; x < list->rows; x ++)
      {
        index = list->columns * x;
        status = NFT_delete_entry (catalog_no, item_no, 
                                   atol(data[index + i_fileno]));
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
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
      else
        NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
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
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        else
          NFMdisconnect (&fs_net_id);
        _NFMfs_undo_send_files (&file_list);
        NFMlock_table (fcat_name);
        sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
        SQLstmt(sql_str);
        SQLstmt ("COMMIT WORK");
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
        return ( NFM_E_SQL_STMT);
      }
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      if (DM_MANAGER)
        _DMcall_do_nothing (2);
      else
        NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list);
      MEMclose (&file_list);
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      return ( NFM_E_SQL_STMT);
    }

    if (type_m || type_acad)
    {
      _NFMdebug ((fname, "the file is type [%s]\n",
                  (type_m? "M": "DWG")));
      /* if DM/MANAGER+SERVER+AUTOCAD, sto_list->option = DM_AUTOCAD
         if DM/MANAGER+SERVER+microstation, sto_list->option = DM_MICROSTATION
         if I/NFM+SERVER+AUTOCAD, sto_list->option = NFM_AUTOCAD
         if I/NFM+SERVER+AUTOCAD, sto_list->option = NFM_MICROSTATION */ 

      if (DM_MANAGER)
      {
        if (type_m)
          sto_list->option = DM_MICROSTATION;
        else
          sto_list->option = DM_AUTOCAD;
      }
      else
      {
        if (type_m)
          sto_list->option = NFM_MICROSTATION;
        else
          sto_list->option = NFM_AUTOCAD;
      }
      status = NFMbuild_microstation_set (catalog_name, catalog_no,
                item_no, type_m_file, &micro, *sto_list);
      if (status == NFM_I_ITEM_PROMOTED_TO_MS_SET)
      {
        _NFMdebug ((fname, "the item is promoted into a set\n"));
        m_set =1;
      }
      else if (status != NFM_S_SUCCESS)
      {
        if (DM_MANAGER)
          _DMcall_do_nothing (1);
        else
          NFMdisconnect (&fs_net_id);
        NFMlock_table (fcat_name);
        sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no,
               "and n_fileversion = ", file_version+1);
        SQLstmt(sql_str);
        SQLstmt ("COMMIT WORK");  
        _NFMfs_undo_send_files (&file_list);
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
        NFMundo_microstation_set (catalog_name, catalog_no, item_no, micro);
        ERRload_struct (NFM, NFM_E_OPEN_DRAWING, "", NULL);
        return (NFM_E_OPEN_DRAWING);
      }
      SQLstmt ("COMMIT WORK");
    }
    else if (DM_MANAGER)
    {
      _NFMdebug ((fname, "this is not a type-m-file\n"));
      _DMdo_nothing ();
    }
 
    status = NFMset_item_status (catalog_name, "", "", item_no, "I",
                                 NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      if (DM_MANAGER)
        _DMdo_nothing ();
      else
        NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMset_item_status 0x%.8x\n", status));
      NFMundo_microstation_set (catalog_name, catalog_no, item_no, micro);
      return (status);
    }
  }

  if (NFMglobal.load_item_file == NFM_LOAD_ITEM_FILE)
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
    for (x = 0; x < list->rows;  x++)
    {
      status = MEMwrite_data (list, datetime, x + 1, i_cidate);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_data: 0x%.8x\n", status));
      }
    }
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
  }

  /* At this point, the checkin is considered successful. The following
     code is designated for cleaning up */

  /* if operation.delete == NFM_NO_DELETE, don't delete from files,
     dont do anything */

  /* else if operation.delete == NFM_CONDITIONAL_DELETE, build buffer
     consulting local file manager */

  if (operation.delete == NFM_CONDITIONAL_DELETE)
  {
    lfm_files = (struct NFMlfm_file *) calloc (list->rows,
                  sizeof (struct NFMlfm_file));
    if (lfm_files == (struct NFMlfm_file *) NULL)
    {
      _NFMdebug ((fname, "Failed to malloc\n"));
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list);
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", 
                      "Failed to malloc memory");
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      if (DM_MANAGER)
        _DMdo_nothing ();
      return (NFM_E_MESSAGE);
    }
    i_cp = 1; i_ref = 2; i_co =0; 
    for (x = 0; x < list->rows; x++)
    {
      index = list->columns * x;
      index1 = file_list->columns * x;
      /* query lfm */

      if (!strcmp (data[index+i_fileco], "Y"))
      {
        _NFMdebug ((fname, "this file was checked-out\n"));
        known = 1;
      }
      else
      {
        _NFMdebug ((fname, "this file was not checked out, \n\
          it could be brought down by other item or\n\
          it could be created by the user \n"));
        known = 0;
      }

      if (known)
      {
        sprintf (sql_str, "%s %d %s '%s' %s %d %s %d %s %s %s %s",
               "select n_co, n_copy, n_ref from nfmsafiles where n_sano =", 
               sto_list->sano,
               "and n_filename =", data[index+i_cofilename], 
               "and n_catalogno =",
               catalog_no, "and n_itemno =", item_no, "and n_filenum =",
               data[index+i_filenum], "and n_fileversion =", 
               data[index+i_fileversion]);
      }
      else
      {
        sprintf (sql_str, "%s %d %s '%s'",
               "select n_co, n_copy, n_ref from nfmsafiles where n_sano =", 
               sto_list->sano,
               "and n_filename =", data[index+i_cofilename]);
      }

      status = _NFMlock_and_retrieve_values (sql_str, NFM_RETURN_MEMPTR,
                   dumb_str, &dumb_value, &list1, NFM_LOCK_COMMIT, 
                   "nfmsafiles");
      if (status == NFM_S_SUCCESS)
      {
        data1 = (char **) list1->data_ptr;
        if (!known)
        {
          _NFMdebug ((fname, 
            "file came down with other item, do not delete\n"));
          (lfm_files+x)->action = NFM_NO_CHANGE;
          MEMwrite_data (file_list, "", x+2, FTO_STATUS1+1);
        }
        else
        {
          if (strcmp (data1[i_cp], "N") || atol (data1[i_ref]) > 0 )
          {
            _NFMdebug ((fname, 
              "DO not delete file, it was copied/referenced\n"));
            (lfm_files+x)->action = NFM_UPDATE_CO;
            sprintf (temp_str, "%d", NFM_READ_ONLY);
            MEMwrite_data (file_list, temp_str, x+2, FTO_STATUS1+1);
          }
          else
          {
            (lfm_files+x)->action = NFM_DELETE_FROM_NFMSAFILES;
          }
        }
        MEMclose (&list1);
      }
      else if ( status == SQL_I_NO_ROWS_FOUND)
      {
        (lfm_files+x)->action = NFM_NO_CHANGE; /* no entry */
        MEMclose (&list1);
      }
      else
      {
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        free (lfm_files);
        ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return (NFM_E_SQL_QUERY);
      }
    }
    /* delete files */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file to delete:", file_list, 
                           _NFMdebug_st.NFMdebug_file);
    if (DM_MANAGER)
      status = DMrm_co_files (&file_list, fs_net_id);
    else
      status = NFMrm_co_files (&file_list, fs_net_id);
    if (status != NFM_S_SUCCESS)
    {        
      _NFMdebug ((fname, "NFMrm_co_files: 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
    }
  }

  else if (operation.delete == NFM_DELETE_FILES)
  {
    /* delete files */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file to delete:", file_list, 
                           _NFMdebug_st.NFMdebug_file);
    if (DM_MANAGER)
      status = DMrm_co_files (&file_list, fs_net_id);
    else
      status = NFMrm_co_files (&file_list, fs_net_id);
    if (status != NFM_S_SUCCESS)
    {        
      _NFMdebug ((fname, "NFMrm_co_files: 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
    }
  }
  else if (!DM_MANAGER && (operation.delete == NFM_NO_DELETE && 
           (operation.transfer == NFM_CONDITIONAL_TRANSFER ||
            operation.transfer == NFM_TRANSFER) ) )
  {
    _NFMdebug ((fname, "Disconnect the fileserver connection\n"));
    status = NFMdisconnect (&fs_net_id);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMdisconnect: 0x%.8x\n", status));
      MEMclose (&list); free (sto_list);
      MEMclose (&file_list);
      /* ignore error */
      ERRload_struct (NFM, NFM_S_SUCCESS, "", "") ;
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      return (status);
    }
  }
  else if (DM_MANAGER && (operation.delete == NFM_NO_DELETE))
  {
    _DMdo_nothing ();
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("info from f_<catalog>", list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("info from file_server", file_list, 
                    _NFMdebug_st.NFMdebug_file);
  }

  if (operation.delete == NFM_CONDITIONAL_DELETE)
  {
    sprintf (sql_str, "%s %d %s %d %s %d %s %d %s",
             "update nfmsafiles set n_co = 'N' where n_sano =",
             sto_list->sano, "and n_catalogno =", catalog_no, "and n_itemno =",
             item_no, "and n_fileversion =", file_version, "and (");
    for (x = 0, nothing = 1; x < list->rows; x ++)
    {
      index = x * list->columns;
      if ((lfm_files+x)->action == NFM_UPDATE_CO)
      {
        if (!nothing)
          strcat (sql_str, "or");
        else
          nothing = 0;
        strcat (sql_str, "(n_filenum = ");
        strcat (sql_str, data[index+i_filenum]);
        strcat (sql_str, "and n_filename = '");
        strcat (sql_str, data[index+i_cofilename]);
        strcat (sql_str, "')");
      }
    }
    strcat (sql_str, ")");
    _NFMdebug ((fname, "nothing = %d\n", nothing));
    if (!nothing)
    {
      status = NFMlock_table ("nfmsafiles");
      if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        free (lfm_files);
        degree = 2;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return ( NFM_E_SQL_STMT);
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        free (lfm_files);
        degree = 2;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return ( NFM_E_SQL_STMT);
      }
      SQLstmt ("COMMIT WORK");
    }
    sprintf (sql_str, "%s %d %s %d %s %d %s %d %s",
             "delete from nfmsafiles where n_sano =",
             sto_list->sano, "and n_catalogno =", catalog_no, "and n_itemno =",
             item_no, "and n_fileversion =", file_version, "and (");
    for (x = 0, nothing = 1; x < list->rows; x ++)
    {
      index = x * list->columns;
      if ((lfm_files+x)->action == NFM_DELETE_FROM_NFMSAFILES)
      {
        if (!nothing)
          strcat (sql_str, "or");
        else
          nothing = 0;
        strcat (sql_str, "(n_filenum = ");
        strcat (sql_str, data[index+i_filenum]);
        strcat (sql_str, "and n_filename = '");
        strcat (sql_str, data[index+i_cofilename]);
        strcat (sql_str, "')");
      }
    }
    strcat (sql_str, ")");
    _NFMdebug ((fname, "nothing: %d\n", nothing));
    if (!nothing)
    {
      status = NFMlock_table ("nfmsafiles");
      if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        free (lfm_files);
        degree = 2;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return ( NFM_E_SQL_STMT);
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list); free (sto_list);
        MEMclose (&file_list);
        free (lfm_files);
        degree = 2;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return ( NFM_E_SQL_STMT);
      }
      SQLstmt ("COMMIT WORK");
    }
    free (lfm_files); 
  }

  MEMclose (&list);
  MEMclose (&file_list);

  if (operation.purge == NFM_NO_PURGE)
    goto CIIend;

  /* if operation.purge == NFM_PURGE, purge the internal files and records */
  if (operation.purge == NFM_PURGE)
  {
    /* if versionlimit not given, default to 1 and WARN the user */

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
      degree = 2;
      /* ignore error */
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      return (status);
    }

    SQLstmt ("COMMIT WORK");
    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      degree = 2;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Lock Table Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      MEMclose (&file_list);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
      return (status);
    }

    if (version_limit > 0)
      purge_limit = version_limit;
    else
      purge_limit = 1;

    sprintf (sql_str, "%s %s %s %s %d %s %d %s",
      "select n_fileno, n_cifilename, n_cisano, n_fileversion, n_fileco,",
      "n_archiveno from",
           fcat_name, "where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_fileco = 'N'"); 

    status = SQLquery(sql_str, &list, MEM_SIZE);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "No rows qualified for purging\n"));
      MEMclose (&file_list); free (sto_list);
      MEMclose (&list);
      goto CIIpurge_record;
    }
    else if (status != SQL_S_SUCCESS)
    {
      MEMclose (&file_list);
      MEMclose (&list); free (sto_list);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
      return (NFM_E_SQL_QUERY);
    }

    SQLstmt ("COMMIT WORK");

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&file_list);
      MEMclose (&list); free (sto_list);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "MEMbuild_array (fileversion info) 0x%.8x\n", status));
      return (NFM_E_MEM);
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

    sprintf (temp_str, "%d", NFM_PURGE_FILE);
    data = (char **) list->data_ptr;
    for (x = 0, archive_no = 0; x < list->rows; x++)
    {
      index = list->columns * x;

      /* purge  storage area information */
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                             y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+2]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
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
          break;
        }
      }

      if (strlen (data[index+5]))
        archive_no = 1;

      strcat (row_str, data[index]); strcat (row_str, "\1");
      strcat (row_str, "\1");
      status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, 
                                 atol(data[index]), filename);
      if (status != NFM_S_SUCCESS)
      {
        MEMclose (&file_list);
        MEMclose (&list); free (sto_list);
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        degree = 1;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

      _NFMdebug ((fname, "MEMwrite [%s]\n",
                          row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 1;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return (NFM_E_MEM);
      }
    }
    /* move the files */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

    status = NFMfs_purge (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_purge 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    }

    MEMclose (&list);
    MEMclose (&file_list);
    free (sto_list);

    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
      return (status);
    }

    CIIpurge_record:
    sprintf (sql_str, "%s %s %s %d %s %d %s",
           "delete from", fcat_name, "where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_archiveno is NULL"); 

    SQLstmt (sql_str);

    if (archive_no)
    {
      sprintf (sql_str, "%s %s %s %d %s %d %s",
           "update", fcat_name, "set n_fileco = 'O' where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_archiveno > 0"); 

      SQLstmt (sql_str);
    }

    SQLstmt ("COMMIT WORK");

  }

  CIIend:
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));

  if (m_set)
    ERRload_struct (NFM, NFM_I_ITEM_PROMOTED_TO_MS_SET, "", NULL);
 
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
    {
      _NFMdebug ((fname, "NFMset_wf_state 0x%.8x\n", status));
    }
  }

  _NFMdebug ((fname, "EXIT: successfully 0x%.8x\n\
                            version = %d, m_set = %d, ftr_status 0x%.8x\n", 
                            NFM_S_SUCCESS, version_limit, m_set, ftr_status));
  if (version_limit < 1)
  {
    ERRload_struct (NFM, NFM_W_INVALID_VERSION_LIMIT, "%d",
                    version_limit);  
    return (NFM_W_INVALID_VERSION_LIMIT);
  }
  else if (m_set)
  {
    return (NFM_I_ITEM_PROMOTED_TO_MS_SET);
  }
  else if (ftr_status != UTI_S_SUCCESS && DM_MANAGER)
  {
   return (ftr_status);
  }

  return (NFM_S_SUCCESS);
}
