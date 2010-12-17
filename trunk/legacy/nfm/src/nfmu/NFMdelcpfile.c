#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMfto_buf.h"

extern long DM_MANAGER;

long NFMdelete_copied_files (working_area, data_list)

/***
  This function will delete a list of user selected file(s) in a selected
  storage area. It will also update the nfmsafiles table (LFM.)

  Note: Before each file is deleted, the corresponding item's file status will
        be checked then locked to avoid loss of the file due to multiuser 
        contention. This command will try to delete as many files as possible.
***/

char *working_area;
MEMptr data_list;

{
  char *fname="NFMdelete_copied_files";
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char sql_str[1024], pre_str[1024], item_str[4096], row_str[1024], 
       upd_str[1024], temp_str[10];
  char **data, **data1, **column, dumb_str[2];
  char cur_cat[NFM_CATALOGNAME+1], cur_item[NFM_ITEMNAME+1];
  char cur_rev[NFM_ITEMREV+1];
  char **f_data, warn_str[1024];
  int f_index;
  int i_catname=-1,i_itemname=-1,i_itemrev=-1,i_filename=-1,i_fileversion=-1,
      i_nfs=-1;
  int x, y, or, index, index1, dumb_value, found=0;
  long sano=-1;
  long status, at_least_1_valid=0;
  MEMptr file_list=NULL, list=NULL, cat_list=NULL;
  struct NFMitem_entry *items_list=NULL, *new_item;
  struct NFMitem_entry *head_item, *beginning, *check;
  struct NFMfile_entry *head_file, *new_file;

  long NFMrollback_delete_copied_files_status ();

  _NFMdebug ((fname, "ENTER: working_area [%s], DM_MANAGER = %d\n", 
                     working_area, DM_MANAGER));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("data_list", data_list, _NFMdebug_st.NFMdebug_file);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (data_list->rows)
  {
    _NFMdebug ((fname, "delete [%d] files\n", data_list->rows));
  }
  else 
  {
    _NFMdebug ((fname, "no info in data_list, what files to delete??\n"));
    ERRload_struct (NFM, NFM_E_INCOMPLETE_INFORMATION,
                    "delete copied files", "file information");
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_INCOMPLETE_INFORMATION);
  }

  /* set indexes values */

  column = (char **) data_list->column_ptr;
  data = (char **) data_list->data_ptr;

  for (x = 0; x < data_list->columns; x ++)
  {
    _NFMdebug ((fname, "column[%d] = %s\n", x, column[x]));

    if (!strcmp (column[x], "n_catalogname"))
      i_catname = x;
    else if (!strcmp (column[x], "n_itemname"))
      i_itemname = x;
    else if (!strcmp (column[x], "n_itemrev"))
      i_itemrev = x;
    else if (!strcmp (column[x], "n_filename"))
      i_filename = x;
    else if (!strcmp (column[x], "n_fileversion"))
      i_fileversion = x;
    else if (!strcmp (column[x], "n_nfs"))
      i_nfs = x; /* 11/2/92, this is optional */
  }

  if (i_catname < 0 || i_itemname < 0 || i_itemrev < 0 ||
      i_filename < 0 || i_fileversion < 0 )
  {
    _NFMdebug ((fname, "Not enough information given:\n\
                       i_catname = [%d] i_itemname [%d] i_itemrev[%d]\n\
                       i_filename [%d] i_fileversion [%d]\n",
                       i_catname, i_itemname, i_itemrev,
                       i_filename, i_fileversion));
    ERRload_struct (NFM, NFM_E_INCOMPLETE_INFORMATION, "%s%s",
                    "delete copied files",
                    "input information");
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_INCOMPLETE_INFORMATION);
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip, xns,
                                decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMget_storage_info: 0x%.8x\n", status));
    NFMstart_transaction (0);  
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
      (strcmp (opsys, "WINDOS") == 0) )
  {
    _NFMdebug ((fname, "Cannot use I/NFM to delete local files on PC\n"));
    NFMstart_transaction (0); 
    ERRload_struct (NFM, NFM_E_NFM_CLIENT_DEL_PC, "", NULL);
    return (NFM_E_NFM_CLIENT_DEL_PC);
  }

  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMbuild_fto_buffer: 0x%.8x\n"));
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano, nodename, username, passwd, pathname, devicetype, plattername,
  partition, nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
  "\1\1\1\1\1\1\1\1\1");

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite: 0x%.8x\n", status));
    MEMclose (file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  strcpy (sql_str, 
           "select n_catalogname, n_catalogno from nfmcatalogs where ");

  strcpy (pre_str,
           "select n_itemname, n_itemrev, n_itemno, n_status from");

  /* at this point file_list have 1 row, storage area in which deletion will
     take place. */

  /* 1/20/92, at this moment, it is OK to assume the data_list will be grouped
     by catalog_no and item_no. It will be hard coded in the display routines*/

  head_item = items_list = (struct NFMitem_entry *) calloc (1,
                sizeof (struct NFMitem_entry));
  strcpy (items_list->cat_name, data[i_catname]);
  strcpy (items_list->item_name, data[i_itemname]);
  strcpy (items_list->item_rev, data[i_itemrev]);
  items_list->files = 1;
  head_file = items_list->next_file = (struct NFMfile_entry *) calloc (1,
                           sizeof (struct NFMfile_entry));
  strcpy (items_list->next_file->cofilename, data[i_filename]);
  items_list->next_file->fileversion = atol (data[i_fileversion]);
  if (i_nfs > -1)
    strcpy (items_list->next_file->nfs, data[i_nfs]);

  strcpy (cur_cat, data[i_catname]);
  strcpy (cur_item, data[i_itemname]);
  strcpy (cur_rev, data[i_itemrev]);

  beginning = head_item;
  sprintf (item_str, "%s %s where %s '%s' %s '%s' %s",
           pre_str, cur_cat, "(n_itemname =", cur_item, "and n_itemrev =",
           cur_rev, ")"); 

  strcat (sql_str, "n_catalogname = '");
  strcat (sql_str, cur_cat);
  strcat (sql_str, "'");

  for (x = 1; x < data_list->rows; x ++)
  {
    index = x * data_list->columns;
    _NFMdebug ((fname, "cur_cat [%s] cur_item[%s.%s] \n\
                data[%d] catname[%s] itemname [%s] rev[%s]\n", 
                cur_cat, cur_item, cur_rev,
                index, data[index+i_catname], data[index+i_itemname], 
                data[index+i_itemrev] ));  
    if (strcmp (cur_cat, data[index+i_catname]))
    {
      _NFMdebug ((fname, "retrieve items' information\n"));

      sprintf (upd_str, "%s %s %s",
               "update", cur_cat, "set n_status = 'TD' where ");


      status = NFMlock_table (cur_cat);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        NFMstart_transaction (0);
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      }

      status = NFMretrieve_values (item_str, NFM_RETURN_MEMPTR, dumb_str,
                                   &dumb_value, &list);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLquery: 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        NFMstart_transaction (0);
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      }

      /*5/9/94 SQLstmt ("COMMIT WORK"); */

      data1 = (char **) list->data_ptr;
      for (y = 0, or = 0; y < list->rows; y ++)
      {
        index1 = list->columns * y;
        for (check=beginning; check != (struct NFMitem_entry *) NULL; 
             check = check->next_item)
        {
          if (!strcmp(check->cat_name, cur_cat) &&
              !strcmp(check->item_name, data1[index1]) &&
              !strcmp(check->item_rev, data1[index1+1]))
          {
            _NFMdebug ((fname, "found match\n"));
            check->item_no = atol (data1[index1+2]);

            _NFMdebug ((fname, "file status = %s\n", data1[index1+3]));
           
            /* if statu = TD, concurrent delete local files, item
               has multiple files */
            if (strcmp (data1[index1+3], "TD"))
            {
              strcpy (check->status, data1[index1+3]);
              if (or)
                strcat (upd_str, " or ");
              else
                or = 1;
              strcat (upd_str, "n_itemno =");
              strcat (upd_str, data1[index1+2]);
              at_least_1_valid ++;
            }
            else
            {
              _NFMdebug ((fname, 
                "This item is currently accessed by another user\n"));
              strcpy (check->status, "NN");
              if (DM_MANAGER)
              {
                sprintf (warn_str, "%s of document %s revision %s of %s cannot be deleted because the document is being accessed by another user",
                data[index+i_filename], check->item_name, check->item_rev,
                check->cat_name);
              }
              else
              {
                sprintf (warn_str, "%s of item %s revision %s of %s cannot be deleted because the item is being accessed by another user",
                data[index+i_filename], check->item_name, check->item_rev,
                check->cat_name);
              }

              ERRload_struct (NFM, NFM_E_MESSAGE, "%s", warn_str);
            }
            break;
          }  
        }
      }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_delete_copied_files_status (items_list);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", upd_str, status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        NFMstart_transaction (0);
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      }

      /* 5/9/94 take out lock table */

      if (or)
      {
        status = SQLstmt (upd_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_delete_copied_files_status (items_list);
          _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", upd_str, status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          NFMstart_transaction (0);
          if (DM_MANAGER)
            _DMdo_nothing ();
          return (status);
        } 
      }

      SQLstmt ("COMMIT WORK");

      _NFMdebug ((fname, "next catalog\n"));
      strcpy (cur_cat, data[index+i_catname]);

      strcat (sql_str, "or n_catalogname = '");
      strcat (sql_str, cur_cat);
      strcat (sql_str, "'");

      new_item = (struct NFMitem_entry *) calloc (1,
                sizeof (struct NFMitem_entry));
      strcpy (new_item->cat_name, data[index+i_catname]);
      strcpy (new_item->item_name, data[index+i_itemname]);
      strcpy (new_item->item_rev, data[index+i_itemrev]);
      new_item->files = 1;
      new_item->next_file = (struct NFMfile_entry *) calloc (1,
                           sizeof (struct NFMfile_entry));
      strcpy (new_item->next_file->cofilename, data[index+i_filename]);
      new_item->next_file->fileversion = atol (data[index+i_fileversion]);
      if (i_nfs > -1)
        strcpy (new_item->next_file->nfs, data[index+i_nfs]);
      head_item->next_item = new_item;
      head_item = head_item->next_item;
      head_file = new_item->next_file; 
      strcpy (cur_cat, data[index+i_catname]);
      strcpy (cur_item, data[index+i_itemname]);
      strcpy (cur_rev, data[index+i_itemrev]);
      sprintf (item_str, "%s %s where %s '%s' %s '%s' %s",
           pre_str, cur_cat, "(n_itemname =", cur_item, "and n_itemrev =",
           cur_rev, ")"); 
    }
    else if (strcmp (cur_item, data[index+i_itemname]) ||
             strcmp (cur_rev, data[index+i_itemrev])        )
    {
      _NFMdebug ((fname, "next item\n"));
      strcpy (cur_item, data[index+i_itemname]);
      strcpy (cur_rev, data[index+i_itemrev]);

      strcat (item_str, "or (n_itemname = '");
      strcat (item_str, cur_item);
      strcat (item_str, "' and n_itemrev = '");
      strcat (item_str, cur_rev);
      strcat (item_str, "')");

      /* more */
      new_item = (struct NFMitem_entry *) calloc (1,
                sizeof (struct NFMitem_entry));
      strcpy (new_item->cat_name, data[index+i_catname]);
      strcpy (new_item->item_name, data[index+i_itemname]);
      strcpy (new_item->item_rev, data[index+i_itemrev]);
      new_item->files = 1;
      new_item->next_file = (struct NFMfile_entry *) calloc (1,
                           sizeof (struct NFMfile_entry));
      strcpy (new_item->next_file->cofilename, data[index+i_filename]);
      new_item->next_file->fileversion = atol (data[index+i_fileversion]);
      if (i_nfs > -1)
        strcpy (new_item->next_file->nfs, data[index+i_nfs]);
      head_item->next_item = new_item;
      head_item = head_item->next_item;
      head_file = new_item->next_file; 
    }
    else
    {
      _NFMdebug ((fname, "next file\n"));
      new_file = (struct NFMfile_entry *) calloc (1, 
                                            sizeof (struct NFMfile_entry));
      strcpy (new_file->cofilename, data[index+i_filename]);
      new_file->fileversion = atol (data[index+i_fileversion]);
      if (i_nfs > -1)
        strcpy (new_file->nfs, data[index+i_nfs]);
      head_file->next_file = new_file;
      head_file = head_file->next_file;
      head_item->files ++; /* increment the number of files associated. */
    }
  }
 
  _NFMdebug ((fname, "retrieve items' information\n"));

  sprintf (upd_str, "%s %s %s",
           "update", cur_cat, "set n_status = 'TD' where ");


  status = NFMlock_table (cur_cat);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
    NFMrollback_delete_copied_files_status (items_list);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }


  status = NFMretrieve_values (item_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery: 0x%.8x\n", status));
    NFMrollback_delete_copied_files_status (items_list);
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  SQLstmt ("COMMIT WORK");

  data1 = (char **) list->data_ptr;
  for (y = 0, or = 0; y < list->rows; y ++)
  {
    index1 = list->columns * y;
    for (check=beginning; check != (struct NFMitem_entry *) NULL;  
         check=check->next_item )
    {
      if (!strcmp(check->cat_name, cur_cat) &&
          !strcmp(check->item_name, data1[index1]) &&
          !strcmp(check->item_rev, data1[index1+1]))
      {
        _NFMdebug ((fname, "found match\n"));
        check->item_no = atol (data1[index1+2]);

        _NFMdebug ((fname, "file status = %s\n", data1[index1+3]));

        /* if statu = TD, concurrent delete local files, item
               has multiple files */
        if (strcmp (data1[index1+3], "TD"))
        {
          strcpy (check->status, data1[index1+3]);
          if (or)
            strcat (upd_str, " or ");
          else
            or = 1;
          strcat (upd_str, "n_itemno =");
          strcat (upd_str, data1[index1+2]);
          at_least_1_valid ++;
        }
        else
        {
          _NFMdebug ((fname, "this is also been accessed by the other\n"));
          strcpy (check->status, "NN");
          if (DM_MANAGER)
          {
            sprintf (warn_str, "%s of document %s revision %s of %s cannot be deleted because the document is being accessed by another user",
            data[index+i_filename], check->item_name, check->item_rev,
            check->cat_name);
          }
          else
          {
            sprintf (warn_str, "%s of item %s revision %s of %s cannot be deleted because the item is being accessed by another user",
            data[index+i_filename], check->item_name, check->item_rev,
            check->cat_name);
          }
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s", warn_str);
        }
        break;
      }  
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_delete_copied_files_status (items_list);
    _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", upd_str, status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (! at_least_1_valid)
  {
    _NFMdebug ((fname, "no file(s) of item(s) can be accessed\n"));
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_MESSAGE);
  }

  /* 5/9/94 take out lock table */

  if (or)
  {
    status = SQLstmt (upd_str);
    if (status != SQL_S_SUCCESS)
    {
      NFMrollback_delete_copied_files_status (items_list);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", upd_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      NFMstart_transaction (0);
      if (DM_MANAGER)
        _DMdo_nothing ();
      return (status);
    }
  }

  SQLstmt ("COMMIT WORK");

  /* query for catalogs, and store them. */

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &cat_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_delete_copied_files_status (items_list);
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }
  data1 = (char **) cat_list->data_ptr;
  for (x = 0; x < cat_list->rows; x ++)
  {
    index1 = cat_list->columns * x;
    for (head_item=items_list, found = 0; 
         head_item != (struct NFMitem_entry *) NULL;
         head_item=head_item->next_item)
    {
      if (!strcmp(head_item->cat_name, data1[index1]))
      {
        head_item->cat_no = atol (data1[index1+1]);
        found = 1;
      }
      else if (found)
        break;
    }
  }
  
  /* need to query nfmsafiles for nfs */

  if (i_nfs > -1)
  {
    _NFMdebug ((fname, "nfs value is given from calling function\n"));

    for (head_item = items_list; 
         (head_item != (struct NFMitem_entry * ) NULL) /*&&
         (strcmp(head_item->status, "NN"))*/;  
         head_item = head_item->next_item)
    {
      if (!strcmp(head_item->status, "NN"))
      {
        _NFMdebug ((fname, "not available fore delete\n"));
        continue;
      }

      for (head_file = head_item->next_file; 
           head_file != (struct NFMfile_entry * ) NULL; 
           head_file = head_file->next_file)
      {
        if (!strcmp(head_file->nfs, "Y"))
        {
          _NFMdebug ((fname, "this file was NFSed\n"));

          /* According to Makarand (4/17/92), the only information needed by
             Fileserver is status == NFM_NFSED and local file name. */
          sprintf (row_str,
          "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1%s\1\1\1%d\1\1\1",
          head_file->cofilename, NFM_NFSED);
        }
        else
        {
          _NFMdebug ((fname, "this file was transfered, not NFSed\n"));
          sprintf (row_str,
          "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1%s\1\1\1%d\1\1\1",
          head_file->cofilename, NFM_DELETE_FILE);
        }

        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          NFMrollback_delete_copied_files_status (items_list);
          _NFMdebug ((fname, "MEMwrite: (%s) 0x%.8x\n",
           row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
      }
    }
  }
  else
  {
    for (head_item = items_list; 
         (head_item != (struct NFMitem_entry * ) NULL) /*&&
         (strcmp (head_item->status, "NN"))*/;  
         head_item = head_item->next_item)
    {
      _NFMdebug ((fname, "get info of item [%d] status [%s]in nfmsafiles\n",
                  head_item->item_no, head_item->status));
      if (!strcmp (head_item->status, "NN"))
      {
        _NFMdebug ((fname, "file is not available for delete\n"));
        continue;
      }
      sprintf (sql_str, "%s %s %d %s %d %s %d %s",
          "select n_nfs, n_cisano, n_mountpoint, n_filename from nfmsafiles",
          "where n_sano =", sano, "and n_catalogno =", head_item->cat_no,
          "and n_itemno =", head_item->item_no, "and (");
      for (head_file = head_item->next_file, or = 0; 
           head_file != (struct NFMfile_entry * ) NULL; 
           head_file = head_file->next_file)
      {
        if (or)
          strcat (sql_str, " or ");
        else
          or = 1;
        strcat (sql_str, "(n_filename ='");
        strcat (sql_str, head_file->cofilename);
        strcat (sql_str, "' and n_fileversion =");
        sprintf (temp_str, "%d", head_file->fileversion);
        strcat (sql_str, temp_str);
        strcat (sql_str, ")");
      }
      strcat (sql_str, ")");
      status = NFMlock_table ("nfmsafiles");
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_delete_copied_files_status (items_list);
        _NFMdebug ((fname, "NFMlock_table: 0x%.8x\n", status));
        NFMstart_transaction (0);
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      }
      status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                   &dumb_value, &list);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_delete_copied_files_status (items_list);
        _NFMdebug ((fname, "NFMretrieve_values: 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        NFMstart_transaction (0);
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      } 
      SQLstmt ("COMMIT WORK");
      data1 = (char **) list->data_ptr;
      for (x = 0; x < list->rows; x ++)
      {
        index = list->columns * x;
        if (!strcmp(data1[index], "Y"))
        {
          _NFMdebug ((fname, "this file was NFSed\n"));
          /* more */

          /* According to Makarand (4/17/92), the only information needed by
             Fileserver is status == NFM_NFSED and local file name. */
          sprintf (row_str,
          "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1%s\1\1\1%d\1\1\1",
          data1[index+3], NFM_NFSED);
        }
        else
        {
          _NFMdebug ((fname, "this file was transfered, not NFSed\n"));
          sprintf (row_str, 
          "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1%s\1\1\1%d\1\1\1",
          data1[index+3], NFM_DELETE_FILE);  
        }
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          NFMrollback_delete_copied_files_status (items_list);
          _NFMdebug ((fname, "MEMwrite: (%s) 0x%.8x\n",
           row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    NFMstart_transaction (0);
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
      }
      status = MEMclose (&list);
    }
  }

  /* call NFMrm_co_files with buffer-A */

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
  }

  if (DM_MANAGER)
    status = DMrm_co_files (&file_list, 0);
  else
    status = NFMrm_co_files (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMrm_co_files: 0x%.8x\n", status));
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    MEMbuild_array (file_list);
    f_data = (char **) file_list->data_ptr;
    for (x = 1; x < file_list->rows; x ++)
    {
      f_index = x * file_list->columns;
      if (atol (f_data[f_index+FTO_STATUS1]) != NFM_E_UNLINK_CO_FILENAME ||
          atol (f_data[f_index+FTO_STATUS2]) != 2  )
      {
        _NFMdebug ((fname, "Fatal failure, status [%s] status2 [%s]\n", 
          f_data[f_index+FTO_STATUS1], f_data[f_index+FTO_STATUS2]));
        NFMrollback_delete_copied_files_status (items_list);
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                      "Failed to delete files");
    NFMstart_transaction (0);
        return (status);
      }
    }
    ERRload_struct (NFM, NFM_W_MESSAGE, "%s",
                    "File(s) was/were not in the local area");
  }

  /* update nfmsafiles table */

  for (head_item = items_list;
       (head_item != (struct NFMitem_entry * ) NULL) /*&&
       (strcmp(head_item->status, "NN"))*/;
       head_item = head_item->next_item)
  {
    _NFMdebug ((fname, "delete info of item [%d] status [%s] in nfmsafiles\n",
                head_item->item_no, head_item->status));
    if (!strcmp(head_item->status, "NN"))
    {
      _NFMdebug ((fname, "this file is not deleted\n"));
      continue;
    }
    sprintf (sql_str, "%s %s %d %s %d %s %d %s",
        "delete from nfmsafiles",
        "where n_sano =", sano, "and n_catalogno =", head_item->cat_no,
        "and n_itemno =", head_item->item_no, "and (");
    for (head_file = head_item->next_file, or = 0;
         head_file != (struct NFMfile_entry * ) NULL;
         head_file = head_file->next_file)
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "(n_filename ='");
      strcat (sql_str, head_file->cofilename);
      strcat (sql_str, "' and n_fileversion =");
      sprintf (temp_str, "%d", head_file->fileversion);
      strcat (sql_str, temp_str);
      strcat (sql_str, ")");
    }
    strcat (sql_str, ")");
    status = NFMlock_table ("nfmsafiles");
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      NFMrollback_delete_copied_files_status (items_list);
      NFMstart_transaction (0);
      if (DM_MANAGER)
        _DMdo_nothing ();
      return (status);
    }

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      NFMrollback_delete_copied_files_status (items_list);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      NFMstart_transaction (0);
      return (status);
    }

    SQLstmt ("COMMIT WORK");
  } 
  NFMrollback_delete_copied_files_status (items_list);
    NFMstart_transaction (0);
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
