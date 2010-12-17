#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMitems.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "WFstruct.h"

extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;

long NFMplot_item (catalog_name, item_name, item_rev)

/***

  This function will plot an item. The storage area used for submitting
  the plotting is "nfm."

***/

char *catalog_name, *item_name, *item_rev;

{
  char *fname="NFMplot_item";
  char w_clause[256], dumb_str[10], row_str[2048], sql_str[2048];
  char file_status[NFM_STATUS+1];
  char filename[NFM_CIFILENAME+1];
  char **data, **data1, move[10];
  int  q_itemno=0, q_status=1;
                                /* index from NFM_ITEM_FILE_QUERY */
  int  q_fileversion=3, q_cifilename=6, q_cisano=7, q_cofilename=8, 
       q_cosano=9, q_filetype=2, q_cifilesize=5, q_filenum=1;
  int  iparm_exists=0;
  long dumb_value, file_version=0, item_no=0, cat_no=0; 
  long status, x, index;
  MEMptr list=NULL, file_list=NULL, dumb_list=NULL, temp_list=NULL;
  struct NFMsto_info *sto_list, *end_sto, *cur_sto, *new_sto;  
  struct NFMlfm_file *lfm_files;

  _NFMdebug ((fname, "ENTER: plot item [%s.%s]\n", item_name, item_rev));

  sprintf (w_clause, "where n_itemname = '%s' and n_itemrev = '%s'",
               item_name, item_rev);
 
  status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value, 
                   &list, NFM_ITEM_QUERY, NFM_RETURN_MEMPTR, NFM_NO_LOCK);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcommon_query: 0x%.8x\n", status));
    return (status);
  } 

  data = (char **) list->data_ptr;
  item_no = atol (data[q_itemno]);
  strcpy (file_status, data[q_status]);

  status = NFMcheck_catalog_attributes (item_name, item_rev, list, 
           NFM_PLOT_ITEM);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ((fname, "NFMcheck_catalog_attributes: 0x%.8x\n", status));
    return (status);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }

  sprintf (w_clause, "%s %d %s %s f_%s %s %d %s",
           "where n_itemnum =", item_no, 
           "and (n_fileco = 'Y' or n_fileco = 'N')",
           "and n_fileversion = (select max(n_fileversion) from", catalog_name,
           "where n_itemnum =", item_no, ")");
 
  status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value, 
                   &list, NFM_ITEM_FILE_QUERY, NFM_RETURN_MEMPTR, NFM_NO_LOCK);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcommon_query: 0x%.8x\n", status));
    return (status);
  } 

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

  data = (char **) list->data_ptr;
  file_version = atol (data[q_fileversion]);

  sto_list = end_sto = (struct NFMsto_info *) calloc 
                            (1, sizeof (struct NFMsto_info));

  strcpy (sto_list->saname, "nfm");
  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
           sto_list->nodename, sto_list->username, sto_list->passwd,
           sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
           sto_list->partition, sto_list->nfs, sto_list->compress, 
           sto_list->machid, sto_list->opsys, sto_list->tcpip, sto_list->xns, 
           sto_list->decnet, sto_list->netware);
  
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    free (sto_list);
    _NFMdebug ((fname, "NFMget_storage_info: 0x%.8x\n", status));
    return (status);
  }

  if (atol (data[q_cosano]) == sto_list->sano &&
      (strlen (file_status) && strcmp (file_status, "I")))
  {
    MEMclose (&list);
    free (sto_list);
    _NFMdebug ((fname, "Cannot plot item, item is checked out to [nfm]\n"));
    ERRload_struct (NFM, NFM_E_PI_CO_NFM, "", NULL);
    return (NFM_E_PI_CO_NFM);
  }

  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    free (sto_list);
    _NFMdebug ((fname, "NFMbuild_fto_buffer: 0x%.8x\n", status));
    return (status);
  }

  sprintf (row_str,
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
    sto_list->sano,
    sto_list->nodename, sto_list->username, sto_list->passwd, 
    sto_list->pathname, sto_list->devicetype, sto_list->plattername,
    sto_list->partition, sto_list->nfs, sto_list->compress, sto_list->machid, 
    sto_list->opsys, sto_list->tcpip, sto_list->xns, sto_list->decnet,
    sto_list->netware, "\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite: [%s]\n", row_str));
  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (file_list);
    free (sto_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMwrite: 0x%.8x\n", status));
    return (status);
  } 

  lfm_files = (struct NFMlfm_file *) calloc (list->rows, 
               sizeof (struct NFMlfm_file));
  if ((lfm_files == (struct NFMlfm_file *) NULL) && list->rows)
  {
    MEMclose (&list);
    MEMclose (file_list);
    free (sto_list);
    ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                    list->rows * sizeof (struct NFMlfm_file));
    _NFMdebug ((fname, "Failed to malloc for variable lfm_files\n"));
    return (NFM_E_MALLOC);
  }

  if (strcmp (WFinfo.catalog_name, catalog_name))  
  {
    _NFMdebug ((fname, "retrieve catalog information\n"));
    sprintf (w_clause, "n_catalogname = '%s'", catalog_name);
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &cat_no,
               &dumb_list, NFM_CAT_QUERY, NFM_RETURN_VALUE, NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (file_list);
      free (sto_list);
      free (lfm_files);
      _NFMdebug ((fname, "NFMcommon_queries: 0x%.8x\n", status));
      return (status);
    }
  }
  else
  {
    _NFMdebug ((fname, "Use the information in WFinfo\n"));
    cat_no = WFinfo.catalog_no; 
  }
  
  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = list->columns * x;
    if (!strcmp(data[index+q_filetype], "P"))
      iparm_exists = 1;      
    sprintf (w_clause, "%s %d %s '%s' %s %d %s %d %s %s",
             "n_sano =", sto_list->sano, "and n_filename =", data[index+8], 
             "and n_catalogno =", cat_no, "and n_itemno =", 
             item_no, "and n_filenum =", data[index+q_filenum]);
 
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value,
                &temp_list, NFM_LFM_QUERY, NFM_RETURN_MEMPTR, NFM_NO_LOCK);
    if (status == NFM_S_SUCCESS)
    {
      data1 = (char **) temp_list->data_ptr;
      if (atol(data1[q_fileversion]) == atol(data[index+q_fileversion]))
      {
        sprintf (move, "%d", NFM_LFM_NFS_MOVE_NO_REMOVE);
      }
      else
      {
        sprintf (move, "%d", NFM_NFS_MOVE_NO_REMOVE);
        (lfm_files+x)->action = 1; /* update the fileversion only */
      }
      MEMclose (&temp_list);
    }
    else if ( status == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (move, "%d", NFM_LFM_NFS_MOVE_REMOVE);
    }
    else
    {
      _NFMdebug ((fname, "NFMcommon_queries 0x%.8x\n", status));
      MEMclose (&list);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      free (sto_list);
      free (lfm_files);
      return (status);
    }

    /* copy FROM storage area information */

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
      new_sto = (struct NFMsto_info *) calloc (1, sizeof (struct NFMsto_info));
      new_sto->sano = atol (data[index+q_cisano]);
      /*** this should be caught earlier
      if (new_sto->sano < 1)
      {
        _NFMdebug ((fname, "Invalid n_cisano, rows = %d, filenum =%s\n",
                    list->rows, data[index+q_filenum]));
        if (list->rows == 1 && atol (data[index+q_filenum]) == 0)
        {
          ERRload_struct (NFM, NFM_E_PI_STATUS_NULL, "", NULL);
        }
        else
        {
          ERRload_struct (NFM, NFM_E_INVALID_STORAGE_AREA, "", NULL);
        }
        MEMclose (&list);
        MEMclose (&file_list);
        free (lfm_files);
        _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
        return (status);
      }
      ***/
      status = NFMget_storage_info (new_sto->saname, &(new_sto->sano),
                  new_sto->nodename,
                  new_sto->username, new_sto->passwd, new_sto->pathname, 
                  new_sto->devicetype,
                  new_sto->plattername, new_sto->partition, new_sto->nfs, 
                  new_sto->compress,
                  new_sto->machid, new_sto->opsys, new_sto->tcpip, 
                  new_sto->xns, new_sto->decnet, 
                  new_sto->netware);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_storage_info 0x%.8x\n", status));
        MEMclose (&list);
        MEMclose (&file_list);
        free (lfm_files);
        _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
        return (status);
      }
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
      status = NFMget_file_name (NFMglobal.NFMuserid, cat_no, 
                                 atol(data[index]), filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        MEMclose (&list);
        MEMclose (&file_list);
        free (lfm_files);
        _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    }
    strcat (row_str, data[index+q_cofilename]); strcat (row_str, "\1");
    strcat (row_str, data[index+q_filetype]); strcat (row_str, "\1");
    strcat (row_str, data[index+q_cifilesize]); strcat (row_str, "\1");
    
    strcat (row_str, move); strcat (row_str, "\1\1\1");

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&list);
      MEMclose (&file_list);
      free (lfm_files);
      _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }
  }
  if (!iparm_exists)
  {
    _NFMdebug ((fname, "IPARM file is missing, cannot plot\n"));
    MEMclose (&list);
    MEMclose (&file_list);
    free (lfm_files);
    _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
    ERRload_struct (NFM, NFM_E_MISSING_IPARM, "", NULL);
    return (NFM_E_MISSING_IPARM);
  }
  else if (list->rows == 1)
  {
    _NFMdebug ((fname, 
         "IPARM file is the only file associated with the item\n"));
    MEMclose (&list);
    MEMclose (&file_list);
    free (lfm_files);
    _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
    ERRload_struct (NFM, NFM_E_IPARM_ONLY, "", NULL);
    return (NFM_E_IPARM_ONLY);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("plot item buffer", file_list,
                     _NFMdebug_st.NFMdebug_file);

  status = _NFMfs_plot_files (&file_list);
  if (status == NFM_I_RM_PLOTTED_FILES)
  {
    _NFMdebug ((fname, "Command is considered OK, but File(s) is/are \n\
                        not removed successfully\n"));
    ERRload_struct (NFM, NFM_I_RM_PLOTTED_FILES, "", NULL);
  }
  else if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMfs_plot_files: 0x%.8x\n", status));
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("plot item buffer", file_list,
                       _NFMdebug_st.NFMdebug_file);
    _NFMstack_error_from_buffer (file_list, catalog_name,  item_name, item_rev,
            NFM_PLOT_ITEM, (MEMptr) NULL);
    MEMclose (&list);
    MEMclose (&file_list);
    free (lfm_files);
    _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
    return (status);
  }

  for (x = 0; x < list->rows; x ++)
  {
    index = x * list->columns;
    if ((lfm_files+x)->action)
    {
      /* possible optimization in the future, combine the update */

      _NFMdebug ((fname, "fileversion in nfmsafiles needs to be updated\n"));
      sprintf (sql_str, "%s %d %s %d %s %d %s %d %s %s %s '%s'",
       "update nfmsafiles set n_fileversion =", file_version, "where n_sano =",
       sto_list->sano, "and n_catalogno =", cat_no,  "and n_itemno =",
       item_no, "and n_filenum =", data[index+q_filenum], "and n_filename =",
       data[index+q_cofilename]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLstmt: 0x%.8x\n", status));
        MEMclose (&list);
        MEMclose (&file_list);
        free (lfm_files);
        _NFMfree_linked_lists (sto_list, (struct NFMset_member *) NULL);
        /* NFM_I_PLOT_ITEM: 
           The item is plotted, failed to $1 */
        ERRload_struct (NFM, NFM_I_PLOT_ITEM, "%s",
                  "update Local File Manager");
        return (status);
      }
    }
  }

  MEMclose (&list);
  MEMclose (&file_list);
  free (lfm_files);
  _NFMfree_linked_lists (sto_list, (struct NFMset_member*) NULL);

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
