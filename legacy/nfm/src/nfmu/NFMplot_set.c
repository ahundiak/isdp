#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMitems.h"
#include "NFMfto_buf.h"
#include "WFstruct.h"

extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;

#define NFM_TEMP_SIZE1 14

long NFMplot_set (catalog_name, set_name, set_rev)

/*** 

  This function will plot a set and its members. The storage area used will
  be "nfm."



***/

char *catalog_name, *set_name, *set_rev;

{
  char *fname="NFMplot_set";
  char fcat_name[NFM_CATALOGNAME+3], filename[NFM_CIFILENAME+1];
  char w_clause[1024], dumb_str[2], row_str[1024];
  char **data, **temp_data;
  char nfs_move_no_remove[10], lfm_nfs_move_no_remove[10],
       lfm_nfs_move_remove[10];
  int x, y, z, index, count, iparm_exists=0;
  int i_catno,i_itemnum,i_type,i_fileno,i_filenum,i_fileversion,i_filetype,
      i_fileco,i_cifilesize,i_cifilename,i_cisano,i_cofilename,i_cosano,
      i_status1;
  int q_co=0, q_cp=1, q_ref=2, q_fileversion=3, q_nfs=4, q_cisano=5;
  int q_mountpoint=6, q_filetype=2;
  long cat_no, cur_cat_no, set_no, num_members, status, dumb_value;
  long sto_no, lfm_count;
  MEMptr dumb_list=NULL, list=NULL, files_info=NULL, files_info1=NULL;
  MEMptr which_list=NULL, file_list=NULL, temp_list=NULL;
  struct NFMset_member *set_members=NULL, *cur_set, *begin_process;
  struct NFMmembers members_list;
  struct NFMsto_info  *sto_list=NULL, *end_sto;
  struct NFMbuf_format *format=NULL;
  struct NFMlfm_file *lfm_files=NULL;

  _NFMdebug ((fname, "ENTER: plot set [%s.%s]\n", set_name, set_rev));

  if (strcmp (WFinfo.catalog_name, catalog_name))
  {
    _NFMdebug ((fname, "retrieve catalog information\n"));
    sprintf (w_clause, "n_catalogname = '%s'", catalog_name);
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &cat_no,
                              &dumb_list, NFM_CAT_QUERY, NFM_RETURN_VALUE, 
                              NFM_NO_LOCK);  
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMcommon_queries: 0x%.8x\n", status));
      return (status);
    }
  }
  else
  {
    _NFMdebug ((fname, "Use WFinfo, WFinfo.catalog_name = %s no = %d\n",
                WFinfo.catalog_name, WFinfo.catalog_no));
    cat_no = WFinfo.catalog_no;
  }
  
  if (strcmp (WFinfo.item_name, set_name) ||
      strcmp (WFinfo.item_rev, set_rev) )
  {
    _NFMdebug ((fname, "retrieve set name information\n"));
    sprintf (w_clause, "where n_itemname = '%s' and n_itemrev = '%s'",
             set_name, set_rev);
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
                &set_no, &list, NFM_ITEM_QUERY, NFM_RETURN_VALUE, 
                              NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMcommon_queries: 0x%.8x\n", status));
      return (status);
    }
  }
  else
  {
    _NFMdebug ((fname, "use WFinfo, WFinfo.item_name [%s] rev [%s], no [%d]\n",
                WFinfo.item_name, WFinfo.item_rev, WFinfo.item_no));
    set_no = WFinfo.item_no;
  }

  cur_set = set_members = (struct NFMset_member *) calloc (1,
                  sizeof (struct NFMset_member));
 
  if (set_members == (struct NFMset_member *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", sizeof (struct NFMset_member));
    free (set_members);
    return (NFM_E_MALLOC);
  }

  members_list.cat_no = cat_no;
  members_list.item_no = set_no;
  
  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = cat_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;

  status = NFMretrieve_set_members (&members_list, 1, 1, set_members,
                     &cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, "NFMretrieve_set_members: 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info*)NULL, set_members);
    return (status);
  }

  _NFMdebug ((fname, "This set has %d members\n", num_members));

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL, set_members);
  
  status = NFMget_catalog_names (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMget_catalog_names: 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info*)NULL, set_members);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL, set_members);

  for (x = count = 0, cur_cat_no = set_members->cat_no,
       cur_set = begin_process = set_members; x < num_members;
       x++, cur_set = cur_set->next)
  {
    if (cur_set->cat_no == cur_cat_no)
    {
      count ++;
    }
    else
    {
      status = NFMget_members_info (begin_process, count, NFM_PLOT_SET);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      begin_process = cur_set;
      _NFMdebug ((fname, "cur_cat_no = %d begin_process addr %ld\n",
                 set_members->cat_no, begin_process));
      count = 1;
    }
  }

  status = NFMget_members_info (begin_process, count, NFM_PLOT_SET);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
    return (status);
  }
 
  status = MEMopen (&files_info, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "MEMopen: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  status = MEMopen (&files_info1, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "MEMopen: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                    sizeof (struct NFMbuf_format));

  if (!format)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "failed to malloc memory %d\n",
                NFM_TEMP_SIZE1 * sizeof (struct NFMbuf_format)));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                    NFM_TEMP_SIZE1 * sizeof (struct NFMbuf_format));
    return (NFM_E_MALLOC);
  }
  
  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemnum");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_type");
  strcpy ((format+2)->data_type, "char(1)");
  strcpy ((format+3)->attr_name, "n_fileno");
  strcpy ((format+3)->data_type, "integer");
  strcpy ((format+4)->attr_name, "n_filenum");
  strcpy ((format+4)->data_type, "integer");
  strcpy ((format+5)->attr_name, "n_filetype");
  strcpy ((format+5)->data_type, "char(5)");
  strcpy ((format+6)->attr_name, "n_fileversion");
  strcpy ((format+6)->data_type, "integer");
  strcpy ((format+7)->attr_name, "n_fileco");
  strcpy ((format+7)->data_type, "char(1)");
  strcpy ((format+8)->attr_name, "n_cifilesize");
  strcpy ((format+8)->data_type, "integer");
  strcpy ((format+9)->attr_name, "n_cifilename");
  strcpy ((format+9)->data_type, "char(14)");
  strcpy ((format+10)->attr_name, "n_cisano");
  strcpy ((format+10)->data_type, "integer");
  strcpy ((format+11)->attr_name, "n_cofilename");
  strcpy ((format+11)->data_type, "char(14)");
  strcpy ((format+12)->attr_name, "n_cosano");
  strcpy ((format+12)->data_type, "integer");
  strcpy ((format+13)->attr_name, "n_status1");
  strcpy ((format+13)->data_type, "char(2)");

  status = _NFMbuild_working_buffer_format 
              (format, NFM_TEMP_SIZE1, files_info);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    free (format);
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format: 0x%.8x\n",
                status));
    return (status);
  }

  status = _NFMbuild_working_buffer_format 
              (format, NFM_TEMP_SIZE1, files_info1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    free (format);
    MEMclose (&files_info);
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format: 0x%.8x\n",
                status));
    return (status);
  }

  free (format);

  i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
  i_fileversion = 6; i_filetype = 5; i_fileco = 7; i_cifilesize = 8;
  i_cifilename = 9; i_cisano = 10;
  i_cofilename = 11; i_cosano = 12; i_status1 = 13;

  for ( x = 0, cur_set = set_members, cur_cat_no = 0;
        x < num_members; x ++, cur_set = cur_set->next)
  {
    if (cur_set->move == NFM_NO_MOVE)
    {
      which_list = files_info1;
    }
    else
      which_list = files_info;

    /* Is this catalog same as the previous one?
       yes: table is already locked, don't do anything.
       no: lock the f_<catalog> */

    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }
    _NFMdebug ((fname,
               "prepare to retrieve the information from f_<catalog>\n"));
    sprintf (w_clause, "%s %d %s %s %s %s %d %s %s",
             "where n_itemnum =", cur_set->item_no, "and n_fileversion =",
             "(select max(n_fileversion) from ", fcat_name, "where n_itemnum =",
             cur_set->item_no, ")", "and (n_fileco = 'Y' or n_fileco = 'N')");
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value, 
               &list, NFM_ITEM_FILE_QUERY, NFM_RETURN_MEMPTR, 
                              NFM_NO_LOCK);
    if (status == SQL_I_NO_ROWS_FOUND &&
        cur_set->flag == NFM_SET)
    {
      _NFMdebug ((fname, "IPARM file is missing, cannot plot\n"));
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      ERRload_struct (NFM, NFM_E_MISSING_IPARM, "", NULL);
      return (NFM_E_MISSING_IPARM);
    } 
    else if (status != NFM_S_SUCCESS)
    {
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      _NFMdebug ((fname, "NFMcommon_queries 0x%.8x\n", status));
      return (status);
    }

    data = (char **) list->data_ptr;
    _NFMdebug ((fname, "Write the files information\n"));

    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%d\1%d\1%s\1",
               cur_set->cat_no, cur_set->item_no, cur_set->type);
      for (z = 0; z < list->columns - 6; z ++)
      {
        strcat (row_str, data[index+z]);
        strcat (row_str, "\1");
      }
      strcat (row_str, "\1");
      if (cur_set->flag == NFM_SET && !strcmp(data[index+q_filetype], "P"))
        iparm_exists = 1;
      _NFMdebug ((fname, "row_str %s\n", row_str));

      /* This check needs to be per file base. */

      if (!strlen (data[index+i_fileco]))
      {
        which_list = files_info1;
        cur_set->move = NFM_NO_MOVE;
      }
      status = MEMwrite (which_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (NFM_E_MEM);
      }
    }

    if (cur_set->flag == NFM_SET && !iparm_exists)
    {
      _NFMdebug ((fname, "IPARM file is missing, cannot plot\n"));
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      ERRload_struct (NFM, NFM_E_MISSING_IPARM, "", NULL);
      return (NFM_E_MISSING_IPARM);
    }
      
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (NFM_E_MEM);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("files_info1", files_info1, _NFMdebug_st.NFMdebug_file);
  }

  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  if (files_info->rows == 1)
  {
    _NFMdebug ((fname, "The only file for transfer is IPARM file\n"));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    ERRload_struct (NFM, NFM_E_SET_AND_MEMBERS_NOT_IN, "", NULL);
    return (NFM_E_SET_AND_MEMBERS_NOT_IN);
  }
 
  data = (char **) files_info->data_ptr;

  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    return (status);
  }

  sto_list = end_sto = (struct NFMsto_info *) calloc
                        (files_info->rows + 1, 
                        sizeof (struct NFMsto_info));
  strcpy (sto_list->saname, "nfm");
  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano),
             sto_list->nodename, sto_list->username, sto_list->passwd,
             sto_list->pathname, sto_list->devicetype, sto_list->plattername,
             sto_list->partition, sto_list->nfs, sto_list->compress,
             sto_list->machid, sto_list->opsys, sto_list->tcpip, sto_list->xns,
             sto_list->decnet, sto_list->netware);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, set_members);
    _NFMdebug ((fname, "NFMget_storage_info: 0x%.8x\n", status));
    return (status);
  }

  sprintf (row_str,
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sto_list->sano, sto_list->nodename, sto_list->username, 
  sto_list->passwd, sto_list->pathname, sto_list->devicetype, 
  sto_list->plattername, sto_list->partition,
  sto_list->nfs, sto_list->compress, sto_list->machid, 
  sto_list->opsys, sto_list->tcpip, sto_list->xns, 
  sto_list->decnet, sto_list->netware,
  "\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }

  for (x = 0, sto_no = 1; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
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
      (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
      sto_no++;
    }
  }
  /* at this point, I have a list of storage nos, so retrieve all the
     information from nfmstoragearea and nfmnodes table. */

  status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
    return (status);
  }

  lfm_files = (struct NFMlfm_file *)calloc (files_info->rows,
                sizeof (struct NFMlfm_file) );
  if (!lfm_files)
  {
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    _NFMdebug ((fname, "malloc %d for lfm_files failed\n",
                files_info->rows * sizeof (struct NFMlfm_file)));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                    files_info->rows * sizeof (struct NFMlfm_file));
    return (NFM_E_MALLOC);
  }
  _NFMdebug ((fname, "prepare file transfer buffer\n"));

  sprintf (nfs_move_no_remove, "%d", NFM_NFS_MOVE_NO_REMOVE);
  sprintf (lfm_nfs_move_no_remove, "%d", NFM_LFM_NFS_MOVE_NO_REMOVE);
  sprintf (lfm_nfs_move_remove, "%d", NFM_LFM_NFS_MOVE_REMOVE);

  for (x = lfm_count = 0; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    sprintf (w_clause,
               "%s %d %s '%s' %s %s %s %s %s %s",
               "n_sano =", sto_list->sano,
               "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =",
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum]);

    status = NFMcommon_queries (catalog_name, w_clause, dumb_str, &dumb_value,
               &temp_list, NFM_LFM_QUERY, NFM_RETURN_MEMPTR, 
                              NFM_NO_LOCK);
    if (status == NFM_S_SUCCESS)
    {
      status = MEMbuild_array (temp_list);
      if (status != MEM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        MEMclose (&temp_list);
        free (lfm_files);
        _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
      temp_data = (char **) temp_list->data_ptr;
      _NFMdebug ((fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                  temp_data[q_co], temp_data[q_cp], temp_data[q_ref]));

      (lfm_files+x)->action = 1;

      strcpy((lfm_files+x)->item_no, data[index+i_itemnum]);
      strcpy((lfm_files+x)->cat_no, data[index+i_catno]);
      sprintf((lfm_files+x)->sano, "%d", sto_list->sano);
      strcpy ((lfm_files+x)->filename, data[index+i_cofilename]);
      strcpy((lfm_files+x)->filenum, data[index+i_filenum]);
      strcpy((lfm_files+x)->fileversion, temp_data[q_fileversion]);
      strcpy((lfm_files+x)->copy, temp_data[q_cp]);
      if (!strcmp(temp_data[q_nfs], "Y"))
      {
        strcpy ((lfm_files+x)->nfs, "Y");
        strcpy ((lfm_files+x)->cisano, temp_data[q_cisano]);
        strcpy ((lfm_files+x)->mountpoint, temp_data[q_mountpoint]);
      }
      status = MEMclose (&temp_list);
    }
    else if (status == SQL_I_NO_ROWS_FOUND)
    {
      (lfm_files+x)->action = 0; /* add to the table */
      strcpy((lfm_files+x)->item_no, data[index+i_itemnum]);
      strcpy((lfm_files+x)->cat_no, data[index+i_catno]);
      sprintf((lfm_files+x)->sano, "%d", sto_list->sano);
      strcpy ((lfm_files+x)->filename, data[index+i_cofilename]);
      strcpy((lfm_files+x)->filenum, data[index+i_filenum]);
    }
    else
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      free (lfm_files);
      _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      return (status);
    }
    _NFMdebug ((fname, "LFM information:\n\
                action [%d] item [%s] cat [%s] sano [%s]\n\
                filename [%s] filenum [%s] fileversion [%s]\n\
                Try to find cisano [%d] in sto_list\n",
                (lfm_files+x)->action, (lfm_files+x)->item_no,
                (lfm_files+x)->cat_no, (lfm_files+x)->sano,
                (lfm_files+x)->filename, (lfm_files+x)->filenum,
                (lfm_files+x)->fileversion, data[index+i_cisano]));
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
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      free (lfm_files);
      _NFMdebug ((fname, "check-in-to storage area incorrect\n"));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
           "Invalid storage area");
      return (status);
    }

    strcat (row_str, data[index+i_fileno]); strcat (row_str, "\1");
    strcat (row_str, "\1"); /* n_fileold */
    if (strlen (data[index+i_cifilename]))
    {
      strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
    }
    else
    {
      status = NFMget_file_name (0, atol(data[index+i_catno]),
                                 atol(data[index+i_fileno]), filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        MEMclose (&temp_list);
        free (lfm_files);
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    }

    strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");

    if ((lfm_files+x)->action)
    {
      if ( atol ((lfm_files+x)->fileversion) !=
           atol (data[index+i_fileversion])    )
      {
        strcat (row_str, nfs_move_no_remove); strcat (row_str, "\1\1\1");
        (lfm_files+x)->action = NFM_UPDATE_FILEVERSION;
      }
      else
      {
        strcat (row_str, lfm_nfs_move_no_remove); strcat (row_str, "\1\1\1");
      }
    }
    else
    {
      strcat (row_str, lfm_nfs_move_remove); strcat (row_str, "\1\1\1");
    }

    _NFMdebug ((fname, "row_str %s\n", row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      free (lfm_files);
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }

    status = MEMclose (&temp_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      free (lfm_files);
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }
  } /* prepare file transfer buffer */

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file); 

  status = _NFMfs_plot_files (&file_list);
  if (status == NFM_I_RM_PLOTTED_FILES)
  {
    _NFMdebug ((fname, "Command is considered OK, but File(s) is/are \n\
                        not removed successfully\n"));
    ERRload_struct (NFM, NFM_I_RM_PLOTTED_FILES, "", NULL);
    /* NFM_I_RM_PLOTTED_FILES --
       Plotting request submitted, failed to remove file(s) completely */
  }
  else if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    free (lfm_files);
    return (status);
  }

  for (x = 0; x < files_info->rows; x ++)
  {
    index = x * files_info->columns;
    if ((lfm_files+x)->action == NFM_UPDATE_FILEVERSION)
    {
      _NFMdebug ((fname, "fileversion in nfmsafiles needs to be updated\n"));
      sprintf (w_clause, "%s %d %s %d %s %d %s %d %s %s %s '%s'",
       "update nfmsafiles set n_fileversion =", data[index+i_fileversion], 
       "where n_sano", sto_list->sano, "and n_catalogno =", 
       data[index+i_catno],  "and n_itemno =", data[index+i_itemnum], 
       "and n_filenum =", data[index+i_filenum], "and n_filename =",
       data[index+i_cofilename]);
      status = SQLstmt (w_clause);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLstmt: 0x%.8x\n", status));
        MEMclose (&file_list);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        free (lfm_files);
        _NFMfree_linked_lists (sto_list, set_members);
        /* NFM_I_PLOT_ITEM:
           The item is plotted, failed to $1 */
        ERRload_struct (NFM, NFM_I_PLOT_ITEM, "%s",
                  "update Local File Manager");
        return (status);
      }
    }
  }
  MEMclose (&file_list);
  MEMclose (&files_info);
  MEMclose (&files_info1);
  free (lfm_files);
  _NFMfree_linked_lists (sto_list, set_members);

  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}
