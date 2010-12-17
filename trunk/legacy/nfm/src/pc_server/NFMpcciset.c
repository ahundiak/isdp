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
#include "NFMfto_buf.h"
#include "NFMstruct.h"

#define NFM_TEMP_SIZE1 19

extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;

long NFMpccheckin_set (catalog_name, catalog_no, set_name, set_revision, set_no,
                      working_area, wf_info, member_operations, operation, 
                      level)
/*** 
 
  This function will check in a set.

  Note: The input "level" is not used. 10/14/91

  CHANGE HISTORY:
    10/14/91 mfb Creation.
***/

char *catalog_name; 
long catalog_no;
char *set_name, *set_revision;
long set_no;
char *working_area;
struct NFMwf_info wf_info;
long member_operations;
struct NFMoperation *operation;
long level;

{
  char *fname="NFMpccheckin_set";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], upd_co_str[2048], upd_ver_str[1024], *del_str;
  char upd_ref_str[1024];
  char row_str[2048], temp_str[20];
  char move_str[10], move_move_str[10], move_first_str[10], file_flag[10];
  char **data, **temp_data, **data1;
  char datetime_str[NFM_CODATE+1];
  char datetime[NFM_CODATE+1];
  char fileco_str[NFM_FILECO+1], filename[NFM_COFILENAME+1];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char file_status[NFM_STATUS+1], file_sta_str[100], dumb_str[1];
  char error_msg[100];
  long error_no, sano1;
  int  subsystem;
  long degree, type_m=0, type_acad=0, m, index_m;
  long x, y, z, count, dropped=0, added=0;
  long index, index1, row, lfm_count, max_file_no;
  long i_catno, i_itemnum, i_type, i_fileno, i_filenum, i_fileversion,
      i_filetype, i_fileco, i_cifilename, i_cofilename, i_row,
      i_cisano, i_fileclass, i_cosano, i_co, i_ref, i_cp,
      i_couser, i_ciuser, i_codate, i_cidate, i_itemrev, i_catname, i_itemname,
      i_itemdesc;
  long add_to_list, del_or, upd_or;
  long m_file=0;
  long move=0;
  long sano, sto_no;
  long cur_cat_no;
  long status;
  long file_version, purge_limit=0;
  long num_members, dumb_value;
  long fs_net_id, move_first_time=0, move_move=0;
  MEMptr list=NULL, file_list=NULL, files_info=NULL;
  MEMptr temp_list=NULL, dumb_list=NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMset_member *set_members, *last, *head, *cur_set, *new_node;
  struct NFMset_member *begin_process;
  struct NFMset_member *new_members=NULL, *remove;
  struct NFMmembers *members_list;
  struct NFMsto_info sto_info, *sto_list;
  struct NFMbuf_format *format;
  struct file_info_struct *micro_info;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n\
                       cat_no [%d] set_no [%d]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] member_operations[%d]\n", 
                       catalog_name, set_name,
                       set_revision, catalog_no, set_no, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation->transfer, operation->delete, operation->purge,
                       member_operations));

  /* check for wf_info, if validate, call validate */
  if (wf_info.workflow)
  {
    _NFMdebug ((fname, 
              "wf_info.workflow is set, but only the set item is validated\n"));

    /* a function needs to be implemented to validate the members. waiting for
       Durwood's decision. (10/91) */

    status = WFvalidate_user_access (NFMglobal.NFMuserid, wf_info.command,
             wf_info.workflow_name, wf_info.project_name,
             catalog_name, set_name, set_revision);
    if (status != NFM_S_SUCCESS)
    {
      degree = 1;
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
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }
  
  status = NFMopen_message_buffer ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMopen_message_buffer: 0x%.8x\n", status));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  /* get the children list of the set */

  if (catalog_no < 1)
  {
    _NFMdebug ((fname, "catalog no not given, retrieve it \n"));
    if (wf_info.workflow)
    {
      catalog_no = WFinfo.catalog_no;
    }
    else
    {
      sprintf (sql_str, "%s '%s'",
               "select n_catalogno from nfmcatalogs where n_catalogname =",
               catalog_name);
      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                   &catalog_no, &dumb_list);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, 
                    "NFMretrieve_values(%s) failed 0x%.8x\n", sql_str, status));
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        if (DM_MANAGER)
        {
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve cabinet's information");
          _DMcall_do_nothing (3);
        }
        else
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve catalog's information");
        return (status);
      }
    }
  }
     

  if (set_no < 1)
  {
    if (wf_info.workflow)
    {
      set_no = WFinfo.item_no;
    }
    else
    {
      sprintf (sql_str, "%s %s %s '%s' %s '%s'",
               "select n_itemno from", catalog_name, "where n_itemname =",
               set_name, "and n_itemrev =", set_revision);
      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                   &set_no, &dumb_list);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLquery(%s) failed 0x%.8x\n", sql_str, status));
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        if (DM_MANAGER)
        {
         _DMcall_do_nothing (3);
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve document's information");
        }
        else
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve item's information");
        return (status);
      }
    }
  }

  sprintf (sql_str, "%s %s %s %d %s %d %s",
           "select n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno,",
           "n_type from nfmsetcit", "where n_pcatalogno = ", catalog_no,
           "and n_pitemno = ", set_no,
           "order by n_ccatalogno");

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));
  
  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               dumb_value, &list);

  if (status != NFM_S_SUCCESS)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, 
                "NFMretrieve_values (%s) failed 0x%.8x\n", sql_str, status));
    if (DM_MANAGER)
    {
      _DMcall_do_nothing (3);
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to retrieve folder/drawing/document group members");
    }
    else
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve set members");
    return (status);
  }

  data = (char **) list->data_ptr;

  set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  members_list = (struct NFMmembers *) calloc (list->rows, 
                                  sizeof (struct NFMmembers));
  if (set_members == (struct NFMset_member *) NULL ||
      members_list == (struct NFMmembers *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      set_members? (list->rows * sizeof(struct NFMmembers )): 
                      sizeof (struct NFMset_member));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    MEMclose (&list);
    free (set_members);
    free (members_list);
    _NFMdebug ((fname, "Allocating %d failed \n", set_members?
                (list->rows *sizeof(struct NFMmembers)): 
                sizeof (struct NFMset_member)));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (NFM_E_MALLOC);
  }

  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = catalog_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;
  for (x = 0, cur_set = set_members; x < list->rows; x++)
  {
    index = x * list->columns;
    _NFMdebug ((fname, "row %d: %s %s %s %s %s %s\n",
                        x, data[index], data[index+1], data[index+2],
                        data[index+3], data[index+4], data[index+5]));
    new_node = (struct NFMset_member *) calloc (1,
                         sizeof (struct NFMset_member));
    new_node->level = 1;
    new_node->citno = atol (data[index]);
    strcpy (new_node->type, data[index+5]);
    strcpy ((members_list+x)->type, data[index+5]);
    new_node->cat_no = (members_list+x)->cat_no = atol (data[index+3]);
    new_node->item_no = (members_list+x)->item_no = atol (data[index+4]);
    num_members++;
    if (new_node->cat_no == catalog_no)
    {
      new_node->next = set_members->next;
      set_members->next = new_node;
      if (cur_set == set_members)
        cur_set = set_members->next;
    }
    else
    {
      cur_set->next = new_node;
      cur_set = new_node;
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, "at this point, children of level 1 is retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  status = NFMretrieve_set_members (members_list, list->rows, 2, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    free (members_list);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, "at this point, children of all level are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  free (members_list);
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  /* retrieve all the catalog numbers from nfmcatalogs */

  status = NFMget_catalog_names (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_catalog_names 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, 
               "at this point, children + catalog name are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  /* retrieve the set and children information */

  _NFMdebug ((fname, "b4 for loop, cur_cat_no = %d, begin_process addr %ld\n", 
              set_members->cat_no, set_members));

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
      status = NFMget_members_info (begin_process, count, NFM_CHECK_IN);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
        NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL, 
            x+1, 0, 0, 
            (struct NFMlfm_file *) NULL, (struct NFmlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      begin_process = cur_set;
      _NFMdebug ((fname, "cur_cat_no = %d begin_process addr %ld\n", 
                 set_members->cat_no, begin_process));
      count = 1;
    }
  }
  
  if ( count )
  {
    status = NFMget_members_info (begin_process, count, NFM_CHECK_IN);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
      NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL, 
           x+1, 0, 0, 
           (struct NFMlfm_file *) NULL, (struct NFmlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
      return (status);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, 
               "at this point, children + catalog name + info from cat \n\
               are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  /* get date & time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL,
          num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL,
                       num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
    return (status);
  }

  for (x = 0, cur_set = set_members, cur_cat_no = 0;
         x < num_members; x ++)
  {
    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }

    _NFMdebug ((fname,
                "prepare to retrieve the information from f_<catalog>\n"));
    sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %d %s",
           "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
   "n_cisano, n_cifilename, n_cofilename, n_fileclass, n_cosano, n_couser from",
           fcat_name, 
           "where n_itemnum =", cur_set->item_no, "and n_fileversion =",
           "(select max(n_fileversion) from ", fcat_name, "where n_itemnum =",
           cur_set->item_no, ")");

    i_filetype = 3; i_cosano = 9; i_filenum = 1; i_fileversion = 2;
    i_couser = 10; 

    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                 dumb_value, &list);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL,  num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                      "Failed to retrieve file information");
    if (DM_MANAGER)
      _DMcall_do_nothing (3);
      return (status);
    }

    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("info from f_<catalog>", list, 
                        _NFMdebug_st.NFMdebug_file);
    }

    data = (char **) list->data_ptr;

    if (!x)
    {
      _NFMdebug ((fname, "set [%d], filetype [%s]\n",
                cur_set->item_no, data[i_filetype]));

      /* get storage area (checkout from) information. 
         If 1st time, use working_area, else use cheked-out */

      if (strlen (set_members->file_status))
      {
        sano = atol (data[i_cosano]);
        working_area[0] = '\0';
        status = NFMget_storage_info 
                 (working_area, &sano, nodename, username, passwd,
                  pathname, devicetype, plattername, partition, nfs, compress,
                  machid, opsys, tcpip,
                  xns, decnet, netware);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                      status));
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return (status);
        }
        if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
                           (strcmp (opsys, "WINDOS") == 0) )
        {
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          _NFMdebug ((fname, "Cannot checkin from PC using NFMinterface\n"));
          ERRload_struct (NFM, NFM_E_NFM_CLIENT_CI_PC, "", NULL);
          return (NFM_E_NFM_CLIENT_CI_PC);
        }
        if (strcmp (data[i_couser], NFMglobal.NFMusername))
        {
          _NFMdebug ((fname, "file is not checked out by the same user\n")); 
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          if (DM_MANAGER)
          {
            ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s",
               "check in the folder/drawing/document group",
               "folder/drawing/document group"); 
            _DMcall_do_nothing (3);
          }
          else
          {
            ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s",
              "check in the set", "check in the set");
          }
          return (NFM_E_NOT_CO_USER);
        }
      }
      else
      {
        sano = -1;
        status = NFMget_storage_info 
                 (working_area, &sano, nodename, username, passwd,
                  pathname, devicetype, plattername, partition, nfs, compress,
                  machid, opsys, tcpip,
                  xns, decnet, netware);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
              (MEMptr) NULL, num_members, 0, 0,
               (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                      status));
          if (DM_MANAGER)
            _DMcall_do_nothing (3);
          return (status);
        }
        if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
                           (strcmp (opsys, "WINDOS") == 0) )
        {
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          _NFMdebug ((fname, "Cannot checkin from PC using NFMinterface\n"));
          ERRload_struct (NFM, NFM_E_NFM_CLIENT_DEL_PC, "", NULL);
          return (NFM_E_NFM_CLIENT_DEL_PC);
        }
      }
      for (m = 0; m < list->rows; m ++)
      {
        index_m = list->columns * m;
        if (!strcmp (data[index_m + i_filetype], "M"))
        {
          type_m = 1;
          break;
        }
        else if (!strcmp (data[index_m + i_filetype], "DWG"))
        {
          type_acad = 1;
          break;
        }
      }
      if (type_m || type_acad)
      {
        /* It is a microstation design file, we can assume the members and
           set parent are from the same catalog (10/15/91). We can also
           assume that members are secondary members. */

        sto_info.sano = sano;
        strcpy (sto_info.nodename, nodename);
        strcpy (sto_info.username, username);
        strcpy (sto_info.passwd, passwd);
        strcpy (sto_info.pathname, pathname);
        strcpy (sto_info.devicetype, devicetype);
        strcpy (sto_info.plattername, plattername);
        strcpy (sto_info.partition, partition);
        strcpy (sto_info.nfs, nfs);
        strcpy (sto_info.compress, compress);
        strcpy (sto_info.machid, machid);
        strcpy (sto_info.opsys, opsys);
        strcpy (sto_info.tcpip, tcpip);
        strcpy (sto_info.xns, xns);
        strcpy (sto_info.decnet, decnet);
        strcpy (sto_info.netware, netware);
        /* if DM/MANAGER+SERVER+AUTOCAD, sto_info.option = DM_AUTOCAD
           if DM/MANAGER+SERVER+microstation, sto_info.option = DM_MICROSTATION
           if I/NFM+SERVER+AUTOCAD, sto_info.option = NFM_AUTOCAD
           if I/NFM+SERVER+AUTOCAD, sto_info.option = NFM_MICROSTATION */

        if (DM_MANAGER)
        {
          if (type_m)
            sto_info.option = DM_MICROSTATION;
          else
            sto_info.option = DM_AUTOCAD;
        }
        else
        {
          if (type_m)
            sto_info.option = NFM_MICROSTATION;
          else
            sto_info.option = NFM_AUTOCAD;
        }


        /* call Melania's function */

        _NFMdebug ((fname, "The set is a microstation design file\n"));
        m_file = 1;
        status = NFMpcupdate_microstation_file (num_members, set_members, 
                 &new_members, sto_info, operation, &dropped, &added,
                 catalog_no, set_no, &micro_info);
        if (status != NFM_S_SUCCESS)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
               (MEMptr) NULL, num_members, 0, 0,
               (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          _NFMdebug ((fname, "NFMpcupdate_microstation_file 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
          return (status);
        } 

        _NFMdebug ((fname, "After NFMpcupdate_microstation_file\
          print set definition before drop [%d] members add [%d] members \n",
                    dropped, added));

        _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                                 set_members);

        if (dropped || added)
        {
          /* remove the dropped members */
          for (z = 0, last = set_members, 
                      head = set_members->next; z < num_members - 1; z ++)
          {
            if (head->flag == NFM_DROPPED_MEMBER)
            {
              last->next = head->next;
              remove = head;
              head = head->next;
              free (remove);  
            } 
            else
            {
              last = head;
              head = head->next;
            }
          }
    
          /* append the new members to the list */
          if (added)
          {
            last->next = new_members; 
            _NFMdebug ((fname, "new members\n"));
            _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                                 new_members);
          }
          num_members = num_members - dropped + added;
        }

        _NFMdebug ((fname, "Revised set definition\n"));
        _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                                 set_members);
      }
      else if (DM_MANAGER)
      {
        _NFMdebug ((fname, "not a type-m-file\n"));
        _DMdo_nothing ();
      }
      status = MEMopen (&files_info, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
             (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
      format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                               sizeof (struct NFMbuf_format));

      if (!format)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to allocate memory");
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
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
      strcpy ((format+5)->attr_name, "n_fileversion");
      strcpy ((format+5)->data_type, "integer");
      strcpy ((format+6)->attr_name, "n_filetype");
      strcpy ((format+6)->data_type, "char(5)");
      strcpy ((format+7)->attr_name, "n_fileco");
      strcpy ((format+7)->data_type, "char(1)");
      strcpy ((format+8)->attr_name, "n_cisano");
      strcpy ((format+8)->data_type, "integer");
      strcpy ((format+9)->attr_name, "n_cifilename");
      strcpy ((format+9)->data_type, "char(14)");
      strcpy ((format+10)->attr_name, "n_cofilename");
      strcpy ((format+10)->data_type, "char(14)");
      strcpy ((format+11)->attr_name, "n_fileclass");
      strcpy ((format+11)->data_type, "char(1)");
      strcpy ((format+12)->attr_name, "n_cosano");
      strcpy ((format+12)->data_type, "integer");
      strcpy ((format+13)->attr_name, "n_couser");
      strcpy ((format+13)->data_type, "char(14)");
      strcpy ((format+14)->attr_name, "n_status1");
      strcpy ((format+14)->data_type, "char(2)");
      strcpy ((format+15)->attr_name, "n_itemrev");
      strcpy ((format+15)->data_type, "char(60)");
      strcpy ((format+16)->attr_name, "n_catname");
      strcpy ((format+16)->data_type, "char(60)");
      strcpy ((format+17)->attr_name, "n_itemname");
      strcpy ((format+17)->data_type, "char(60)");
      strcpy ((format+18)->attr_name, "n_itemdesc");
      strcpy ((format+18)->data_type, "char(40)");

      status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info);
      if (status != NFM_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
             (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        free (format);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
      free (format) ;
    }

    _NFMdebug ((fname, 
               "write the files information of this item to files_info\n"));
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%d\1%d\1%s\1",
               cur_set->cat_no, cur_set->item_no, cur_set->type);
      for (z = 0; z < list->columns; z ++)
      {
        strcat (row_str, data[index+z]);
        strcat (row_str, "\1");
      }
      strcat (row_str, "\1");
      strcat (row_str, cur_set->item_rev);
      strcat (row_str, "\1");
      strcat (row_str, cur_set->cat_name);
      strcat (row_str, "\1");
      strcat (row_str, cur_set->item_name);
      strcat (row_str, "\1");
      strcat (row_str, cur_set->item_desc);
      strcat (row_str, "\1");
      _NFMdebug ((fname, "row_str %s\n", row_str));
      status = MEMwrite (files_info, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
          (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        MEMclose (&files_info);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (0);
      }
    }
    cur_set->file_version = atol (data[i_fileversion]);
    cur_set->filenum = atol (data[i_filenum]);
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
      if (m_file)
      {
        _NFMrollback_microstation_operation (micro_info, catalog_no,
                      set_no, sto_info);
        _NFMfree_file_info_struct (micro_info);
      }
      NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
       (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      MEMclose (&files_info);
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
      return (status);
    }
    cur_set = cur_set->next;
    if ( cur_cat_no != cur_set->cat_no)
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n",
                    fcat_name,status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
  }
  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEM_S_SUCCESS 0x%.8x\n", status));
    if (m_file)
    {
      _NFMrollback_microstation_operation (micro_info, catalog_no,
                       set_no, sto_info);
      _NFMfree_file_info_struct (micro_info);
    }
    NFMrollback_set_status (NFM_CHECK_IN, set_members, 
       (MEMptr) NULL, num_members, 0, 0,
     (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
    return (0);
  }

  data = (char **) files_info->data_ptr;

  i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
  i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cisano = 8;
  i_cifilename = 9; i_cofilename = 10; i_fileclass = 11; i_cosano = 12;
  i_row = 14; i_itemrev = 15; i_catname = 16; i_itemname=17, i_itemdesc=18;

  if (operation->transfer == NFM_NO_TRANSFER)
  {
    _NFMdebug ((fname, "this is a checkin set in place\n"));
    for (x = y = 0, cur_set = set_members, cur_cat_no = 0; 
         x < num_members; x++)
    {
      if (strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item %d is secondary member, don't update\n",
                    cur_set->item_no));
        cur_set = cur_set->next;
        continue;
      }
      if (cur_cat_no != cur_set->cat_no)
      {
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
	    (MEMptr) NULL, num_members, 0, 0,
               (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          MEMclose (&files_info);
          _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                      fcat_name,status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }

      for ( ; y < files_info->rows; )
      {
        index = files_info->columns * y;
        if (atol (data[index+i_catno]) !=  cur_set->cat_no ||
            atol (data[index+i_itemnum]) !=  cur_set->item_no)
          y++;
        else
          break;
      }

      _NFMdebug ((fname, "Update the record(s) in %s\n", fcat_name));
      sprintf (sql_str, 
               "%s %s %s %d %s '%s' %s '%s' %s '%s' %s %d %s %s %s %d %s",
               "update", fcat_name, "set n_cosano = ''", 
               "n_couser = ''", "n_codate = ''", 
               "where n_itemnum = ", cur_set->item_no, 
               "and n_fileversion =", data [index+i_fileversion]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          MEMclose (&files_info);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
      }
    }

    for (x = 0, cur_set = set_members->next, cur_cat_no = 0; 
         x < num_members; x++)
    {
      _NFMdebug ((fname, "Update the record in %s\n", cur_set->cat_name));
      if (strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item %d is secondary member, don't update\n",
                    cur_set->item_no));
        cur_set = cur_set->next;
        continue;
      }
      if (cur_cat_no != cur_set->cat_no)
      {
        status = NFMlock_table (cur_set->cat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          MEMclose (&files_info);
          _NFMdebug ((fname, "NFMlock_table %s 0x%.8x\n", cur_set->cat_name,
                      status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }
      if (x)
      {
        if (strcmp (cur_set->file_status, "M"))
          strcpy (file_status, "");
        else
          strcpy (file_status, "I");
      }
      else
      {
        if (strcmp (cur_set->file_status, "S"))
          strcpy (file_status, "");
        else
          strcpy (file_status, "I");
      }
      status = NFMset_item_status (catalog_name, "", "", cur_set->item_no, 
                                   file_status, NFM_NO_LOCK, "");
      if (status != NFM_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                    catalog_name,status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          MEMclose (&files_info);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      cur_set->cat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
      }
    }
      
    status = NFMstart_transaction (0);
    if (status != NFM_S_SUCCESS)
      _NFMdebug ((fname, "NFMstart_transaction failed 0x%.8x\n", status));

    _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
    return (NFM_S_SUCCESS);
  } /* if (operation->transfer == NFM_NO_TRANSFER */

  else 
  {
    _NFMdebug ((fname, "this is a checkin set with conditional transfer\n"));

    sprintf (move_str, "%d", NFM_MOVE);
    sprintf (move_move_str, "%d", NFM_MOVE_MOVE);
    sprintf (move_first_str, "%d", NFM_MOVE_FIRST_TIME);

    status = _DMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      if (m_file)
      {
        _NFMrollback_microstation_operation (micro_info, catalog_no,
                      set_no, sto_info);
        _NFMfree_file_info_struct (micro_info);
      }
      NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (files_info);
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
      return (status);
    }
  
    sprintf (row_str, 
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
    sano,
    nodename, username, passwd, pathname, devicetype, plattername, partition,
    nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
    "\1\1\1\1\1\1\1\1\1\1\1\1\1");

    _NFMdebug ((fname, "MEMwrite %s\n", row_str));

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      if (m_file)
      {
        _NFMrollback_microstation_operation (micro_info, catalog_no,
                      set_no, sto_info);
        _NFMfree_file_info_struct (micro_info);
      }
      NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (files_info);
      MEMclose (&file_list);
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
      return (status);
    }
   
    sto_list = (struct NFMsto_info *) calloc ((files_info->rows+2),
                         sizeof(struct NFMsto_info));

    if (!sto_list)
    {
      if (m_file)
      {
        _NFMrollback_microstation_operation (micro_info, catalog_no,
                      set_no, sto_info);
        _NFMfree_file_info_struct (micro_info);
      }
      NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      MEMclose (files_info);
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      files_info->rows * sizeof (struct NFMsto_info) );
      _NFMdebug ( (fname, "calloc sto_list failed\n") );
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
      return (NFM_E_MALLOC);
    }

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

    for (x = 0, sto_no = 1; x < files_info->rows; x ++)
    {
      index = files_info->columns * x;
      _NFMdebug ((fname, "data[index+i_cisano] = %s\n", 
                          data[index+i_cisano]));
      sano1 = atol (data[index+i_cisano]);
      if (sano1 < 1 && !strlen (data[index+i_cofilename]))
      {
        _NFMdebug ((fname, "no cisano given for this file"));
        continue;
      }

      /* check to see if the cisano already on the list */

      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->sano: %d\n", y,
                     (sto_list+y)->sano));
        if ( (sto_list+y)->sano  == sano1 )
        {
          _NFMdebug ( (fname, "storage_area_no found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        _NFMdebug ((fname, "n_cisano not found in the list, add to it \n"));
        (sto_list+sto_no)->sano  = sano1;
        sto_no++;
      }
    }

    /* at this point, I have a list of storage nos, so retrieve all the
       information from nfmstoragearea and nfmnodes table. */

    if (sto_no > 1)
    {
      status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
      if (status != NFM_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     (MEMptr) NULL,num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
        return (status);
      }
    }

    _NFMdebug ((fname, "prepare file transfer buffer\n"));
    for (x = cur_cat_no = 0, y = 1, cur_set = set_members, row = 1; 
         x < files_info->rows; x ++)
    {

      index = files_info->columns * x;
      _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
              data[index+i_catno], data[index+i_itemnum], data[index+i_type]));

      if (strcmp (data[index+i_type], "P"))
      {
        _NFMdebug ((fname, "No need to put in transfer buffer\n"));
        continue;
      }
      if (cur_cat_no != atol (data[index+i_catno]))
      {
        for ( ; y < num_members; )
        {
          if (cur_set->cat_no == atol (data[index+i_catno]))
            break;
          else
            cur_set = cur_set->next;
        }

        /* lock the table */
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, x, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");         
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
 
        /* get max (n_fileno) */
        sprintf (sql_str, "select max(n_fileno) from %s", fcat_name);
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                 &max_file_no, &dumb_list);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, x, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                          "Failed to retrieve file information");
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
      }

      if (strlen (data[index+i_cofilename])) 
      {
        strcpy (fileco_str, "'N'");
        file_version = atol(data[index+i_fileversion]);
        move = 1;

        /* insert the record */

        sprintf (sql_str, "%s %s %s %s %s \
        (%d, %s, %s, %d, '%s', '%s', %s, '%s', '%s', %s, '%s', timestamp '%s')",
               "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
              "n_fileversion, n_fileclass, n_filetype, n_fileco, n_cofilename,",
               "n_cifilename, n_cisano, n_ciuser, n_cidate) values ",
               ++max_file_no, data[index+i_itemnum], data[index+i_filenum],
               file_version+1, data[index+i_fileclass],
               data[index+i_filetype], fileco_str, data[index+i_cofilename],
               data[index+i_cifilename],
               data[index+i_cisano], NFMglobal.NFMusername, datetime);

        _NFMdebug ((fname, "sql_str %s\n", sql_str));

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
        if (strlen (data[index+i_fileco]))
        {
          
          sprintf (sql_str, "%s %s %s %s %s %s %d %s %s",
               "update", fcat_name, "set n_fileco = 'N'", 
               "where n_itemnum =", data[index+i_itemnum],
               "and n_fileversion =", file_version,
               "and n_filenum = ", data[index+i_filenum]);

          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
          {
            if (m_file)
            {
              _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
              _NFMfree_file_info_struct (micro_info);
            }
            NFMrollback_set_status (NFM_CHECK_IN,set_members,
	       files_info, num_members, num_members, 0,
                (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
            degree = 1;
            _NFMcleanup (&degree, wf_info, "", "", "");
            _NFMfree_linked_lists (sto_list, set_members);
            MEMclose (&file_list);
            MEMclose (&files_info);
            _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
            return (status);
          }               
        }
      }
      else
      {
        move = 0;
        strcpy (fileco_str, "");
        file_version = 0;
      }

      if (move)
      {
        _NFMdebug ((fname, "Try to find cisano [%d] in sto_list\n",
                  data[index+i_cisano]));
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
            (sto_list+y)->nodename, (sto_list+y)->username, 
            (sto_list+y)->passwd,
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
          _NFMdebug ((fname, "check-in-to storage area incorrect\n"));
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                          "Invalid storage area");
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
        sprintf (temp_str, "%d", max_file_no);
        strcat (row_str, temp_str); strcat (row_str, "\1");
        if (strlen (data[index+i_cifilename]))
        {
          status = NFMget_file_name (0, atol(data[index+i_catno]),
                                   atol(data[index+i_fileno]), filename);
          if (status != NFM_S_SUCCESS)
          {
            if (m_file)
            {
              _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
              _NFMfree_file_info_struct (micro_info);
            }
            NFMrollback_set_status (NFM_CHECK_IN,set_members,
	      files_info, num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
            degree = 1;
            _NFMcleanup (&degree, wf_info, "", "", "");
            _NFMfree_linked_lists (sto_list, set_members);
            MEMclose (&file_list);
            MEMclose (&files_info);
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1"); /* n_fileold */
          strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
          if (!strlen (data[index+i_fileco]))
            move_first_time = 1;
          else
            move_move = 1;
        }
        else 
        {
          strcat (row_str, "\1"); /* n_fileold */
          status = NFMget_file_name (0, atol(data[index+i_catno]),
                                   max_file_no, filename);
          if (status != NFM_S_SUCCESS)
          {
            if (m_file)
            {
              _NFMrollback_microstation_operation (micro_info, catalog_no,
                            set_no, sto_info);
              _NFMfree_file_info_struct (micro_info);
            }
            NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     files_info,num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
            degree = 1;
            _NFMcleanup (&degree, wf_info, "", "", "");
            _NFMfree_linked_lists (sto_list, set_members);
            MEMclose (&file_list);
            MEMclose (&files_info);
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
            return (status);
          }
          strcat (row_str, filename); strcat (row_str, "\1");
        } 
        strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        if (move_first_time)
        {
          strcat (row_str, move_first_str); strcat (row_str, "\1\1\1");
        }
        else if (move_move)
        {
          strcat (row_str, move_move_str); strcat (row_str, "\1\1\1");
        }
        else
        {
          strcat (row_str, move_str); strcat (row_str, "\1\1\1");
        }
        move_first_time = move_move = 0;

        if (DM_MANAGER)
        {
          strcat (row_str, data[index+i_catname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemnum]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemrev]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemdesc]); strcat (row_str, "\1");
        }
        else
        {
          strcat (row_str, "\1\1\1\1\1");
        }
 
        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
        sprintf (temp_str, "%d", row++);
        status = MEMwrite_data (files_info, temp_str, x+1, i_row+1);
        if (status != MEM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
      }

      /* check to commit */

      if ((x == files_info->rows -1) || 
          cur_cat_no != atol (data[index+i_catno+files_info->columns]))
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
          _DMcall_do_nothing (2);
          return (status);
        }
      }
    } /* prepare file transfer buffer */

    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
      MEMprint_buffer ("file list", file_list, _NFMdebug_st.NFMdebug_file);
    }

    if (DM_MANAGER)
      status = _DMfs_send_files (&file_list, &fs_net_id, 0);
    else
      status = _NFMpcfs_send_files (&file_list, &fs_net_id, 0);
    if (status != NFM_S_SUCCESS)
    {
      if (m_file)
      {
        _NFMrollback_microstation_operation (micro_info, catalog_no,
                      set_no, sto_info);
        _NFMfree_file_info_struct (micro_info);
      }
      _NFMstack_error_from_buffer (file_list, catalog_name, 
            set_name, set_revision, NFM_CHECK_IN, files_info);
      NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists (sto_list, set_members);
      _NFMpcfs_undo_send_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "_NFMpcfs_send_files 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMcall_do_nothing (1);
      return (status);
    }

    status = MEMbuild_array (file_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (file_list) 0x%.8x\n", status));
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMpcfs_undo_send_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&files_info);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
      return (NFM_E_MEM);
    }

    /* update n_cifilesize in f_<catalog> */

    data1 = (char **) file_list->data_ptr;
    for (x = cur_cat_no = 0, y =1, cur_set = set_members;
         x < files_info->rows; x ++)
    {
      index = files_info->columns * x;
      _NFMdebug ((fname, "cat[%s] item[%s] type [%s]\n",
             data[index+i_catno], data[index+i_itemnum], data[index+i_type]));
      if (strcmp (data[index+i_type], "P") || 
          !strlen (data[index+i_cofilename]))
      {
        _NFMdebug ((fname, "dont update n_cifilesize -- SM or PM no file\n"));
        continue;
      }
      if (cur_cat_no != atol (data[index+i_catno]))
      {
        for (; y < num_members; )
        {
          if (cur_set->cat_no == atol (data[index+i_catno]))
            break;
          else
            cur_set = cur_set->next;
        }
        /* lock the table */
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          _NFMpcfs_undo_send_files (&file_list);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                      fcat_name,status));
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }
      _NFMdebug ((fname, "corresponding row [%s]\n",
                          data[index+i_row]));
      index1 = file_list->columns * (atol(data[index+i_row]));
      sprintf (sql_str, "%s %s %s %s %s %s",
               "update", fcat_name, "set n_cifilesize = ",
               data1[index1+FTO_CIFILESIZE], "where n_fileno = ",
               data1[index1+FTO_FILENO]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        _NFMpcfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
        return (status);
      }
      if ( (x == files_info->rows - 1) ||
           cur_cat_no != atol (data[index+i_catno+files_info->columns]))
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          _NFMpcfs_undo_send_files (&file_list);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
      }
    }
     
    /* update the <catalog> */
    for (x = y = 0, cur_set = set_members, cur_cat_no = 0; 
         x < num_members; x++)
    {
      if (strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item %d is secondary member, don't update\n",
                    cur_set->item_no));
        cur_set = cur_set->next;
        continue;
      }
      if (cur_cat_no != cur_set->cat_no)
      {
        status = NFMlock_table (cur_set->cat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          _NFMpcfs_undo_send_files (&file_list);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                      fcat_name,status));
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
        _NFMdebug ((fname, "Update the record(s) in %s\n", cur_set->cat_name));
      }

      if (strlen (cur_set->file_status) == 1 || cur_set->filenum ||
          cur_set->file_version)
        sprintf (file_sta_str, "set n_status = 'I'");
      else
        sprintf (file_sta_str, "set n_status = NULL");

      sprintf (sql_str, "%s %s %s %s %d", 
               "update", cur_set->cat_name, file_sta_str, 
               "where n_itemno = ", cur_set->item_no);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        if (m_file)
        {
          _NFMrollback_microstation_operation (micro_info, catalog_no,
                        set_no, sto_info);
          _NFMfree_file_info_struct (micro_info);
        }
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        _NFMpcfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          if (m_file)
          {
            _NFMrollback_microstation_operation (micro_info, catalog_no,
                          set_no, sto_info);
            _NFMfree_file_info_struct (micro_info);
          }
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          _NFMpcfs_undo_send_files (&file_list);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
      }
    }
    if (m_file)
      _NFMfree_file_info_struct (micro_info);

    /* Check-In-Set is considered as successful */

    if (operation->delete == NFM_CONDITIONAL_DELETE)
    {
    lfm_files = (struct NFMlfm_file *)calloc (2 * files_info->rows,
                  sizeof (struct NFMlfm_file) );
    if (!lfm_files)
    {
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "malloc %d for lfm_files failed\n",
                         files_info->rows * sizeof (struct NFMlfm_file)));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                         files_info->rows * sizeof (struct NFMlfm_file));
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
      return (NFM_E_MALLOC);
    }

    
    i_co = 0; i_cp = 1; i_ref = 2;
    for (x = lfm_count = 0 ; x < files_info->rows; x ++)
    {

      index = files_info->columns * x;
      _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
                data[index+i_catno], data[index+i_itemnum], 
                data[index+i_type]));

      if (strcmp (data[index+i_type], "P"))
      {
        _NFMdebug ((fname, "secondary member, or item has no file, skip it\n"))
        continue;
      }
      sprintf (sql_str, 
               "%s %s %d %s '%s' %s %s %s %s %s %s %s %s",
               "select n_co, n_copy, n_ref, n_nfs",
               "from nfmsafiles where n_sano =", sano, "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =", 
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum], "and n_fileversion =",
               data[index+i_fileversion]);

      status = SQLquery (sql_str, &temp_list, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
      {
        status = MEMbuild_array (temp_list);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        } 

        temp_data = (char **) temp_list->data_ptr;
        _NFMdebug ((fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                    temp_data[i_co], temp_data[i_cp], temp_data[i_ref]));

        if (strcmp (temp_data[i_cp], "Y") && atol (temp_data[i_ref]) == 0)
        {
          sprintf (file_flag, "%d", NFM_DELETE_FILE);
          strcpy((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
          strcpy((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
          sprintf((lfm_files+lfm_count)->sano, "%d", sto_list->sano);
          strcpy ((lfm_files+lfm_count)->filename, data[index+i_cofilename]);
          strcpy((lfm_files+lfm_count)->filenum, data[index+i_filenum]);
          strcpy((lfm_files+lfm_count)->fileversion, data[index+i_fileversion]);
          (lfm_files+lfm_count)->action = NFM_DELETE_FROM_NFMSAFILES;
                              /* it is in lfm, no one else uses it, delete */
          lfm_count++;
        }
        else
        {
          sprintf (file_flag, "%d", NFM_READ_ONLY);
          strcpy((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
          strcpy((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
          sprintf((lfm_files+lfm_count)->sano, "%d", sto_list->sano);
          strcpy ((lfm_files+lfm_count)->filename, data[index+i_cofilename]);
          strcpy((lfm_files+lfm_count)->filenum, data[index+i_filenum]);
          strcpy((lfm_files+lfm_count)->fileversion, data[index+i_fileversion]);
          (lfm_files+lfm_count)->action = NFM_NULL_CO_FROM_NFMSAFILES;
                            /* it is in lfm, null out n_co */
          lfm_count++;
        } 
        status = MEMclose (&temp_list);
      }
      else if (status == SQL_I_NO_ROWS_FOUND)
      {
        sprintf (file_flag, "%d", NFM_DELETE_FILE);
        status = MEMclose (&temp_list);
      }
      else  
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        if (!DM_MANAGER)
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
        return (status);
      }

      status = MEMwrite_data (file_list, file_flag, 
                              atol(data[index+i_row])+1,
                              FTO_STATUS1+1);
      if (status != MEM_S_SUCCESS)
      { 
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        if (!DM_MANAGER)
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n"));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
        return (status);
      }
    }
    for (x = add_to_list = 0; x < files_info->rows; x ++)
    {
      index = files_info->columns * x;
      _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
              data[index+i_catno], data[index+i_itemnum], data[index+i_type]));
      if (strcmp (data[index+i_type], "S"))
      {
        _NFMdebug ((fname, "Primary member, or item has no file, skip it\n"));
        continue;
      }

      /** take out n_fileversion of query. S member can be checked in/out 
          many time while it is also referenced **/

      sprintf (sql_str,
               "%s %s %d %s '%s' %s %s %s %s %s %s",
     "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint, n_fileversion",
               "from nfmsafiles where n_sano =", sano, "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =",
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum]);

      status = SQLquery (sql_str, &temp_list, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
      {
        status = MEMbuild_array (temp_list);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }

        temp_data = (char **) temp_list->data_ptr;
        _NFMdebug ((fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                    temp_data[i_co], temp_data[i_cp], temp_data[i_ref]));

        if (strcmp (temp_data[i_cp], "Y") && atol (temp_data[i_ref]) < 2  &&
            strcmp (temp_data[i_co], "Y") )
        {
          add_to_list = 1;
          sprintf (file_flag, "%d", NFM_DELETE_FILE);
          strcpy((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
          strcpy((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
          sprintf((lfm_files+lfm_count)->sano, "%d", sto_list->sano);
          strcpy ((lfm_files+lfm_count)->filename, data[index+i_cofilename]);
          strcpy((lfm_files+lfm_count)->filenum, data[index+i_filenum]);
          strcpy((lfm_files+lfm_count)->fileversion, temp_data[6]);
          strcpy((lfm_files+lfm_count)->nfs, temp_data[3]);
          strcpy((lfm_files+lfm_count)->mountpoint, temp_data[5]);
          strcpy((lfm_files+lfm_count)->cisano, temp_data[4]);
          (lfm_files+lfm_count)->action = NFM_DELETE_FROM_NFMSAFILES; 
          lfm_count++;
        }
        else
        {
          strcpy((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
          strcpy((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
          sprintf((lfm_files+lfm_count)->sano, "%d", sto_list->sano);
          strcpy ((lfm_files+lfm_count)->filename, data[index+i_cofilename]);
          strcpy((lfm_files+lfm_count)->filenum, data[index+i_filenum]);
          strcpy((lfm_files+lfm_count)->fileversion, temp_data[6]);
          (lfm_files+lfm_count)->ref = atol(temp_data[i_ref]);
          (lfm_files+lfm_count)->action = NFM_DECREMENT_REF;
          lfm_count++;
        } 
        status = MEMclose (&temp_list);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
            _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);  
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
      }
      else if (status == SQL_I_NO_ROWS_FOUND)
      {
        status = MEMclose (&temp_list);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
            _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);  
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
      }
      else  
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        if (!DM_MANAGER)
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);  
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
        return (status);
      }
      if (add_to_list)
      {
        if (!strcmp ((lfm_files+lfm_count-1)->nfs, "Y"))
        {
          sprintf (file_flag, "%d", NFM_NFSED);
          /*
         */
        }
        sprintf(row_str, "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1");
        strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        strcat (row_str, file_flag); strcat (row_str, "\1\1\1");
        if (DM_MANAGER)
        {
          strcat (row_str, data[index+i_catname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemnum]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemrev]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemdesc]); strcat (row_str, "\1");
        }
        else
        {
          strcat (row_str, "\1\1\1\1\1");
        }
 
        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          if (DM_MANAGER)
            _DMcall_do_nothing (1);
          return (status);
        }
        /* double check the necessity of the following 2 stmts */
        sprintf (temp_str, "%d", row++);
        status = MEMwrite_data (files_info, temp_str, x+1, i_row+1);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          if (!DM_MANAGER)
          MEMclose (&file_list);
          MEMclose (&files_info);
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          if (DM_MANAGER)
            _DMcall_do_nothing (1);
          return (status);
        }
        add_to_list = 0;
      }

    } /* prepare file transfer buffer */
 
    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
      MEMprint_buffer ("file list", file_list, _NFMdebug_st.NFMdebug_file);
    }

    if (DM_MANAGER)
      status = DMrm_co_files (&file_list, fs_net_id);
    else
      status = NFMpcrm_co_files (&file_list, fs_net_id);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMpcrm_co_files 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
    }

    strcpy (upd_co_str, "update nfmsafiles set n_co = 'N' where");
    del_str = (char *) calloc (lfm_count * 150 + 50, sizeof (char));
    strcpy (del_str, "delete from nfmsafiles where");

    for (x = upd_or = del_or = 0; x < lfm_count; x ++)
    {
      _NFMdebug ((fname, "cat [%s] item [%s] action [%d]\n",
                  (lfm_files+x)->cat_no, (lfm_files+x)->item_no,
                  (lfm_files+x)->action));

      if ((lfm_files+x)->action == NFM_DELETE_FROM_NFMSAFILES)
      {
        if (del_or)
          strcat (del_str, " or ");
        else 
          del_or = 1;
        strcat (del_str, "(n_sano = ");
        strcat (del_str, (lfm_files+x)->sano);
        strcat (del_str, "and n_filename = '"); 
        strcat (del_str, (lfm_files+x)->filename);
        strcat (del_str, "'"); 
        strcat (del_str, "and n_catalogno ="); 
        strcat (del_str, (lfm_files+x)->cat_no);
        strcat (del_str, "and n_itemno ="); 
        strcat (del_str, (lfm_files+x)->item_no);
        strcat (del_str, "and n_filenum = "); 
        strcat (del_str, (lfm_files+x)->filenum);
        strcat (del_str, "and n_fileversion = "); 
        strcat (del_str, (lfm_files+x)->fileversion);
        strcat (del_str, ")");
      }
      else if ((lfm_files+x)->action == NFM_NULL_CO_FROM_NFMSAFILES)
      {
        if (upd_or)
          strcat (upd_co_str, " or ");
        else 
          upd_or = 1;
        strcat (upd_co_str, "(n_sano = ");
        strcat (upd_co_str, (lfm_files+x)->sano);
        strcat (upd_co_str, "and n_filename = '"); 
        strcat (upd_co_str, (lfm_files+x)->filename);
        strcat (upd_co_str, "'"); 
        strcat (upd_co_str, "and n_catalogno ="); 
        strcat (upd_co_str, (lfm_files+x)->cat_no);
        strcat (upd_co_str, "and n_itemno ="); 
        strcat (upd_co_str, (lfm_files+x)->item_no);
        strcat (upd_co_str, "and n_filenum = "); 
        strcat (upd_co_str, (lfm_files+x)->filenum);
        strcat (upd_co_str, ")");
        sprintf (upd_ver_str, "%s %d %s %s %s '%s' %s %s %s %s %s %s",
                 "update nfmsafiles set n_fileversion = ",
                 atol ((lfm_files+x)->fileversion) + 1,
                 "where n_sano = ", (lfm_files+x)->sano,
                 "and n_filename = ", (lfm_files+x)->filename,
                 "and n_catalogno = ", (lfm_files+x)->cat_no,
                 "and n_itemno = ", (lfm_files+x)->item_no,
                 "and n_filenum = ", (lfm_files+x)->filenum);
        status = SQLstmt (upd_ver_str);
        if (status != SQL_S_SUCCESS)
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
      } 
      else if ((lfm_files+x)->action == NFM_DECREMENT_REF)
      {
        sprintf (upd_ref_str, "%s %d %s",
                 "update nfmsafiles set n_ref =",
                 (lfm_files+x)->ref - 1, "where");

        strcat (upd_ref_str, "(n_sano = ");
        strcat (upd_ref_str, (lfm_files+x)->sano);
        strcat (upd_ref_str, "and n_filename = '"); 
        strcat (upd_ref_str, (lfm_files+x)->filename);
        strcat (upd_ref_str, "'"); 
        strcat (upd_ref_str, "and n_catalogno ="); 
        strcat (upd_ref_str, (lfm_files+x)->cat_no);
        strcat (upd_ref_str, "and n_itemno ="); 
        strcat (upd_ref_str, (lfm_files+x)->item_no);
        strcat (upd_ref_str, "and n_filenum = "); 
        strcat (upd_ref_str, (lfm_files+x)->filenum);
        strcat (upd_ref_str, "and n_fileversion = "); 
        strcat (upd_ref_str, (lfm_files+x)->fileversion);
        strcat (upd_ref_str, ")");
        status = SQLstmt (upd_ref_str);
        if (status != SQL_S_SUCCESS)
          _NFMdebug ((fname, "SQLstmt(%s) 0x%.8x\n", upd_ref_str, status));
      } 
    }

    if (upd_or)
    {
      _NFMdebug ((fname, "upd_co_str %s\n", upd_co_str));
      status = SQLstmt (upd_co_str);
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
    }
    if (del_or)
    {
      _NFMdebug ((fname, "del_str %s\n", del_str));
      status = SQLstmt (del_str);
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
    }
    }
    else if (DM_MANAGER && (operation->delete == NFM_NO_DELETE))
    {
      _DMdo_nothing ();
    }
    else
    {
      sprintf (file_flag, "%d", NFM_DELETE_FILE);
      for (x = 0; x < files_info->rows; x ++)
      {
        index = files_info->columns * x;
        _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
              data[index+i_catno], data[index+i_itemnum], data[index+i_type]));
        if (strcmp (data[index+i_type], "S"))
        {
          _NFMdebug ((fname, "Primary member, or item has no file, skip it\n"));
          continue;
        }
        sprintf(row_str, "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1");
        strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        strcat (row_str, file_flag); strcat (row_str, "\1\1\1");
        if (DM_MANAGER)
        {
          strcat (row_str, data[index+i_catname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemnum]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemrev]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemname]); strcat (row_str, "\1");
          strcat (row_str, data[index+i_itemdesc]); strcat (row_str, "\1");
        }
        else
        {
          strcat (row_str, "\1\1\1\1\1");
        }
        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
        /* double check the necessity of the following 2 stmts */
        sprintf (temp_str, "%d", row++);
        status = MEMwrite_data (files_info, temp_str, x+1, i_row+1);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          MEMclose (&files_info);
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      if (DM_MANAGER)
        _DMcall_do_nothing (1);
          return (status);
        }
      }
      if (_NFMdebug_st.NFMdebug_on)
      {
        MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
        MEMprint_buffer ("file list", file_list, _NFMdebug_st.NFMdebug_file);
      }

      if (DM_MANAGER)
        status = DMrm_co_files (&file_list, fs_net_id);
      else
        status = NFMpcrm_co_files (&file_list, fs_net_id);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMpcrm_co_files 0x%.8x\n", status));
      }
    }
  }

  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));

  status = MEMclose (&files_info);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));

  free (lfm_files);

  /* if operation->purge == NFM_PURGE, purge the internal files and records */
  if (operation->purge == NFM_PURGE)
  {
    /* prepare buffer for the file server */

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      return (status);
    }

    for (x = 0, cur_set = set_members, cur_cat_no = 0;
         x < num_members; x ++)
    {
      if (strcmp (cur_set->type, "P"))
      {
        _NFMdebug ((fname, "type %s , skip purging\n",
                    cur_set->type));
        cur_set = cur_set->next;
        continue;
      }

      if (cur_set->cat_no != cur_cat_no)
      {
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }

      _NFMdebug ((fname,
                  "prepare to retrieve the information from f_<catalog>\n"));
      sprintf (sql_str, "%s %s %s %s %d %s %d",
               "select n_fileno, n_fileversion, n_filetype,",
               "n_cisano, n_cifilename, n_fileco from",
               fcat_name, 
               "where n_itemnum =", cur_set->item_no, "and n_fileversion <=",
               cur_set->file_version + 1 - cur_set->version_limit);
      
      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status == SQL_I_NO_ROWS_FOUND)
      {
        cur_set = cur_set->next;
        if (cur_set->cat_no != cur_cat_no)
        {
          status = SQLstmt ("COMMIT WORK");
          if (status != SQL_S_SUCCESS)
          {
            degree = 1;
            _NFMcleanup (&degree, wf_info, "", "", "");
            _NFMfree_linked_lists (sto_list, set_members);
            MEMclose (&file_list);
            _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            return (status);
          }
        }
        MEMclose (&list);
        continue;
      }
      else if (status != SQL_S_SUCCESS)
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }

      data = (char **) list->data_ptr;

      for (y = 0; y < list->rows; y++)
      {
        index = list->columns * y;

        if (atol(data[index+1]) == 0 || !strlen (data[index+5]) ||
            !strcmp (data[index+5], "O") )
        {
          continue;
        }
        /* purge  storage area information */
        for (z = 0; z < sto_no; z ++)
        {
          if ((sto_list+z)->sano == atol (data[index+3]))
          {
            sprintf (row_str,
           "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
            (sto_list+z)->sano,
            (sto_list+z)->nodename, (sto_list+z)->username, 
            (sto_list+z)->passwd,
            (sto_list+z)->pathname, (sto_list+z)->devicetype,
            (sto_list+z)->plattername,
            (sto_list+z)->partition, (sto_list+z)->nfs, (sto_list+z)->compress, 
            (sto_list+z)->machid,
            (sto_list+z)->opsys, (sto_list+z)->tcpip, (sto_list+z)->xns, 
            (sto_list+z)->decnet,
            (sto_list+z)->netware);
            break;
          }
        }

        _NFMdebug ((fname, "row_str[%s]\n", row_str));
        strcat (row_str, data[index]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        status = NFMget_file_name (
                 NFMglobal.NFMuserid, cur_set->cat_no, atol(data[index]), 
                 filename);
        if (status != NFM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1");
        strcat (row_str, "\1");
        strcat (row_str, "\1");
        strcat (row_str, "\1");
        sprintf (temp_str, "%d", NFM_PURGE_FILE);
        strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

        _NFMdebug ((fname, "row_str [%s]\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          return (status);
        }
      }

      status = MEMclose (&list);

      cur_set = cur_set->next;
      if (cur_set->cat_no != cur_cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          return (status);
        }
      }
    }
    /* move the files */
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

    status = NFMpcfs_purge (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMpcfs_send_files 0x%.8x\n", status));
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    }

    /* consider purging file status */
    for (x = 0, cur_set = set_members, cur_cat_no = 0;
         x < num_members; x ++)
    {
      if (strcmp (cur_set->type, "P"))
      {
        _NFMdebug ((fname, "type %s , skip purging\n",
                    cur_set->type));
        cur_set = cur_set->next;
        continue;
      }

      if (cur_set->cat_no != cur_cat_no)
      {
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        cur_cat_no = cur_set->cat_no;
      }

      if (cur_set->version_limit < 1)
        purge_limit = 1;
      else
        purge_limit = cur_set->version_limit;

      sprintf (sql_str, "%s %s %s %d %s %d %s",
        "delete from", fcat_name, "where n_fileversion <=", 
        cur_set->file_version + 1 - purge_limit, "and n_itemnum =", 
        cur_set->item_no, "and n_filenum > 0 and n_archiveno is NULL"); 

      /* n_filenum > 0, because of PM no file */

      status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));

      /* COME BACK and UPDATE n_fileco when n_archiveno > 0 */

      sprintf (sql_str, "%s %s %s %d %s %d %s",
        "update", fcat_name, "set n_fileco = 'O' where n_fileversion <=", 
        cur_set->file_version + 1 - purge_limit, "and n_itemnum =", 
        cur_set->item_no, "and n_filenum > 0 and n_archiveno > 0"); 

      status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));

      cur_set = cur_set->next;
      if (cur_set->cat_no != cur_cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
          _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
      }
    }
  }
  /* else if operation->purge == NFM_NO_PURGE, don't purge. */

  
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));

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

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
