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


#define NFM_TEMP_SIZE1 14
extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;


long NFMprocess_selected_set_members (catalog_name, catalog_no, set_name, 
                      set_revision, set_no,
                      working_area, wf_info, member_operations, operation, 
                      level, command)
/*** 
 
  This function will checkout/copy a set and only trnasfer certain item's files
  according to the input "operation."
  n_status, n_archivestate, n_itemlock and n_pendingflag will not be checked
  for the set and members. LFM (nfmsatables) will not be queried before 
  constructing the file transfer buffers. LFM will not be updated. This function
  is created for I/PDM's special need.

***/

char *catalog_name; 
long catalog_no;
char *set_name, *set_revision;
long set_no;
char *working_area;
struct NFMwf_info wf_info;
int member_operations;
struct NFMoperation *operation;
long level;
long command;

{
  char *fname="NFMprocess_selected_set_members";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], upd_co_str[2048], del_str[2041];
  char row_str[2048], big_upd_str[2048], upd_str[1024], ins_str[1024];
  char move_str[10], lfm_move_str[10], temp_str[10];
  char nfs_str[10], lfm_nfs_str[10];
  char **data, **temp_data, **data1, **data2;
  char datetime_str[NFM_CODATE+1];
  char datetime[NFM_CODATE+1];
  char filename[NFM_COFILENAME+1];
  char fileco_str[NFM_FILECO+1];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char file_status[NFM_STATUS+1];
  char dumb_str[1];
  char error_msg[100];
  long error_no;
  int subsystem;
  int degree;
  int x, y, z, count, dropped, added, or;
  int index, index1, row, lfm_count;
  int i_catno, i_itemnum, i_type, i_fileno, i_filenum, i_fileversion,
      i_filetype, i_fileco, i_cifilename, i_cofilename,
      i_cisano, i_cifilesize, i_codate;
  int add_to_list, del_or, upd_or;
  long temp_i_cosano, sano=-1, sto_no;
  long cur_cat_no;
  long status, status1;
  long file_version;
  long num_members;
  long dumb_value;
  MEMptr list=NULL, list1=NULL, list2=NULL, file_list=NULL, files_info=NULL, 
          files_info1=NULL, which_list=NULL;
  MEMptr temp_list=NULL;
  struct NFMlfm_file *lfm_files, *lfm_files1;
  struct NFMset_member *set_members, *next, *last, *head, *cur_set, *new_node;
  struct NFMset_member *begin_process;
  struct NFMset_member *new_members, *remove;
  struct NFMmembers *members_list;
  struct NFMsto_info sto_info, *sto_list;
  struct NFMbuf_format *format;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n\
                       cat_no [%d] set_no [%d]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] member_operations[%d]\n\
                       command[%d]\n", 
                       catalog_name, set_name,
                       set_revision, catalog_no, set_no, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation->transfer, operation->delete, operation->purge,
                       member_operations, command));

  
  sprintf (fcat_name, "f_%s", catalog_name);

  /* check for wf_info, if validate, call validate */
  if (wf_info.workflow)
  {
    /* call validate */
    _NFMdebug ((fname, "validate requested, only validate the set item\n"));
    status = WFvalidate_user_access (NFMglobal.NFMuserid, wf_info.command,
             wf_info.workflow_name, wf_info.project_name,
             catalog_name, set_name, set_revision);
    if (status != NFM_S_SUCCESS)
    {
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
      return (status);
    }

  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    return (status);
  }

  status = NFMopen_message_buffer ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMopen_message_buffer: 0x%.8x\n", status));
    return (status);
  }



  if (catalog_no < 1 && wf_info.workflow)
  {
    catalog_no = WFinfo.catalog_no;
    _NFMdebug ((fname, "catalog_no =%d \n", catalog_no));
  }

  if (set_no < 1 && wf_info.workflow)
  {
    set_no = WFinfo.item_no;
    _NFMdebug ((fname, "set_no = %d\n", set_no));
  }

  /* store the "operation" information into set_members */
  last = cur_set = set_members = (struct NFMset_member *) calloc (1,
                               sizeof (struct NFMset_member));
  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = catalog_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);
  strcpy (set_members->item_name, set_name);
  strcpy (set_members->item_rev, set_revision);
  num_members = 1;

  /** 01/31/92 per Arun, we can assume this list is grouped by catalog number*/
  for (x=0; strlen((operation+x)->catalog); x++)
  {
    _NFMdebug ((fname, "%d operation: cat_name [%s] item[%s.%s]\n",
                x, (operation+x)->catalog,
                (operation+x)->item_name, (operation+x)->item_rev));
    new_node = (struct NFMset_member *) calloc (1,
                         sizeof (struct NFMset_member));
    strcpy (new_node->type, "S");
    strcpy(new_node->cat_name, (operation+x)->catalog);
    new_node->cat_no = (operation+x)->catalog_no;
    strcpy(new_node->item_name,(operation+x)->item_name);
    strcpy(new_node->item_rev,(operation+x)->item_rev);
    num_members++;
 
    cur_set->next = new_node;
    cur_set = cur_set->next;
  }

  /* retrieve all the catalog numbers from nfmcatalogs */

  status = NFMget_catalog_numbers (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_catalog_numbers 0x%.8x\n", status));
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, 
                "At this point, I have all the children + catalog numbers\n"));
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
      status = NFMget_members_info (begin_process, count, 
                                   NFM_CHECK_OUT_SET_SELECTIVELY);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        NFMrollback_transaction (0);
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

  status = NFMget_members_info (begin_process, count, 
                                NFM_CHECK_OUT_SET_SELECTIVELY);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
    return (status);
  }
  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, "At this point, I have all the children\n\
                        + catalog names + information from catalogs\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                             set_members);
  }

  /* lock the set, don't worry about checking the set's status.
      per Arun, 01/31/92 */

  if (command == NFM_CHECK_OUT)
  {
    _NFMdebug ((fname, "update the set status\n"));
    status = NFMset_item_status (catalog_name, "", "",
             set_members->item_no, "TO", NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMset_item_status: 0x%.8x\n", status));
      NFMrollback_transaction (0);
      return (status);
    }
  }

  /* get date & time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    if (command == NFM_CHECK_OUT)
      NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                            (struct NFMlfm_file *) NULL, 
                            (struct NFMlfm_file *) NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    if (command == NFM_CHECK_OUT)
      NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                            (struct NFMlfm_file *) NULL, 
                            (struct NFMlfm_file *) NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    return (status);
  }

  /* get storage area information */

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    if (command == NFM_CHECK_OUT)
      NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_filee *) NULL, (struct NFMlfm_file *) NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status));
    return (status);
  }

    _NFMdebug ((fname, 
                 "this is a checkout set with transfer un/conditional\n"));
    status = MEMopen (&files_info, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members,
		 (MEMptr) NULL, num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }


    format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1, 
                                 sizeof (struct NFMbuf_format));

    if (!format)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "Failed to allocate memory");
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
    strcpy ((format+11)->attr_name, "n_cidate");
    strcpy ((format+11)->data_type, "timestamp");
    strcpy ((format+12)->attr_name, "n_codate");
    strcpy ((format+12)->data_type, "timestamp");
    strcpy ((format+13)->attr_name, "n_cifilesize");
    strcpy ((format+13)->data_type, "integer");

    status = _NFMbuild_working_buffer_format 
                            (format, NFM_TEMP_SIZE1, files_info);
    if (status != NFM_S_SUCCESS)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members,
		 (MEMptr) NULL, num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      NFMrollback_transaction (0);
      free (format);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
      return (status);
    }
    free (format);
    
    i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
    i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cisano = 8;
    i_cifilename = 9; i_cofilename = 10; i_codate=12; i_cifilesize = 13;
    
    for (x = 0, cur_set = set_members, cur_cat_no = 0;
         x < num_members; x ++, cur_set=cur_set->next)
    {
      /* prepare buffer for file transfer */

      /* Is this catalog same as the previous one?
         yes: table is already locked, don't do anything.
         no: lock the f_<catalog> */

      if (cur_set->cat_no != cur_cat_no)
      {
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          if (command == NFM_CHECK_OUT)
            NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
          MEMclose (&files_info);
          MEMclose (&files_info1);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }

      _NFMdebug ((fname,
                "prepare to retrieve the information from f_<catalog>\n"));
      sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %d %s",
             "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
      "n_cisano, n_cifilename,n_cofilename,n_cidate,n_codate,n_cifilesize from",
               fcat_name, 
               "where n_itemnum =", cur_set->item_no, "and n_fileversion =",
               "(select max(n_fileversion) from ", fcat_name, 
               "where n_itemnum =",
               cur_set->item_no, ")");
    
      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str, 
                                   dumb_value,
                                   &list);
      if (status != NFM_S_SUCCESS)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        return (status);
      }

      data = (char **) list->data_ptr;
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
        _NFMdebug ((fname, "row_str %s\n", row_str));
        status = MEMwrite (files_info, row_str);
        if (status != MEM_S_SUCCESS)
        {
          if (command == NFM_CHECK_OUT)
            NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
          MEMclose (&files_info);
          MEMclose (&files_info1);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          return (0);
        }
      }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (0);
      }
    }
    status = MEMbuild_array (files_info);
    if (status != MEM_S_SUCCESS)
    {

      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEM_S_SUCCESS 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (0);
    }

    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("files_info, movable files", files_info,
                        _NFMdebug_st.NFMdebug_file);
    }

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      return (status);
    }
  
    sprintf (row_str, 
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
    sano,
    nodename, username, passwd, pathname, devicetype, plattername, partition,
    nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
    "\1\1\1\1\1\1\1\1\1");

    _NFMdebug ((fname, "MEMwrite %s\n", row_str));

    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      NFMrollback_transaction (0);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }
   
    sto_list = (struct NFMsto_info *) calloc (files_info->rows+2,
                         sizeof(struct NFMsto_info));

    if (!sto_list)
    {
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      files_info->rows * sizeof (struct NFMsto_info) );
      _NFMdebug ( (fname, "calloc sto_list failed\n") );
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

  
    data = (char **) files_info->data_ptr;

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

    if (sto_no > 1)
    {
      status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
      if (status != NFM_S_SUCCESS)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
          NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
        return (status);
      }
    }
    if (_NFMdebug_st.NFMdebug_on)
      _NFMprint_storages_information (sto_list, sto_no);

    sprintf (move_str, "%d", NFM_MOVE);

    sprintf (nfs_str, "%d", NFM_NFS_MOVE);

    _NFMdebug ((fname, "prepare file transfer buffer\n"));
    for (x = 0; x < files_info->rows; x ++)
    {

      index = files_info->columns * x;

      if (!strlen (data[index+i_fileco]))
      {
        _NFMdebug ((fname, "this file is not checked in, skip\n"));
        continue;
      }
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
           (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
           (sto_list+y)->pathname, (sto_list+y)->devicetype, 
           (sto_list+y)->plattername, 
           (sto_list+y)->partition, 
           (sto_list+y)->nfs, 
           (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
           (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
           (sto_list+y)->netware);
          break;
        }
      } 
      if (y >= sto_no)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
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
          if (command == NFM_CHECK_OUT)
            NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&files_info1);
          MEMclose (&file_list);
          free (lfm_files);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1");
      } 
      strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
 
      if (strcmp (data[index+i_type], "S"))
      {
        _NFMdebug ((fname, "this file belong to primary member\n"));
        if (command == NFM_CHECK_OUT)
        {
          strcat (row_str, move_str); strcat (row_str, "\1\1\1");
        }
        else
        {
          strcat (row_str, nfs_str); strcat (row_str, "\1\1\1");
        }
      }
      else
      {
        _NFMdebug ((fname, "this file belong to secondary member\n"));
        strcat (row_str, nfs_str); strcat (row_str, "\1\1\1");
      }

      _NFMdebug ((fname, "row_str %s\n", row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
    } /* prepare file transfer buffer */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    status = _NFMfs_recv_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMbuild_array (file_list);
      status1 = _NFMstack_error_from_buffer (file_list, catalog_name,
               set_name, set_revision, NFM_CHECK_OUT, files_info);
      if (status1 != NFM_S_SUCCESS)
      {
        if (command == NFM_CHECK_OUT)
          NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        free (lfm_files);
        _NFMfs_undo_recv_files (&file_list);
        MEMclose (&file_list);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "_NFMfs_recv_files 0x%.8x\n", status));
        return (status);
      }
      _NFMdebug ((fname, 
                  "File movement for file(s) failed, but cmd can continu\n"));
    }
    status = MEMbuild_array (file_list);
     
    if (command == NFM_CHECK_OUT)
    {
    /* update the f_<catalog> */
    sprintf (fcat_name, "f_%s", catalog_name);
    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
              (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                  fcat_name,status));
      return (status);
    }

    if (strlen (set_members->file_status))
      strcpy (fileco_str, "n_fileco = 'Y'");
    else
      strcpy (fileco_str, "");

    sprintf (sql_str, 
      "%s %s %s %d, %s '%s', %s '%s', %s %s %d %s %s ",
             "update", fcat_name, "set n_cosano =", sano, 
             "n_couser = ", NFMglobal.NFMusername, 
             "n_codate = timestamp ", datetime, fileco_str,
             "where n_itemnum = ", set_members->item_no, 
             "and n_fileversion =", data [i_fileversion]);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
	 (MEMptr) NULL,num_members, x+1, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
	 (MEMptr) NULL,num_members, x+1, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                     fcat_name,status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }

    /* update the <catalog> */
    status = NFMlock_table (catalog_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMfs_undo_recv_files (&file_list);
      if (command == NFM_CHECK_OUT)
        NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
         (MEMptr) NULL,num_members, num_members,
            num_members, lfm_files, lfm_files1);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
			      fcat_name,status));
	  return (status);
     }

     if (strlen (set_members->file_status))
       strcpy (file_status, "S");
     else
       strcpy (file_status, "SN");

     sprintf (sql_str, "%s %s %s '%s' %s %d", 
          "update", catalog_name, "set n_status =", file_status, 
          "where n_itemno = ", set_members->item_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
     {
       _NFMfs_undo_recv_files (&file_list);
       if (command == NFM_CHECK_OUT)
         NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 
                     num_members, num_members, lfm_files, lfm_files1);
       _NFMfree_linked_lists (sto_list, set_members);
       MEMclose (&files_info);
       MEMclose (&file_list);
       NFMrollback_transaction (0);
       _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (status);
     }
     status = SQLstmt ("COMMIT WORK");
     if (status != SQL_S_SUCCESS)
     {
       _NFMfs_undo_recv_files (&file_list);
       if (command == NFM_CHECK_OUT)
         NFMrollback_set_status (NFM_CHECK_OUT,set_members, 
           (MEMptr) NULL,num_members, num_members,
                   num_members, lfm_files, lfm_files1);
       _NFMfree_linked_lists (sto_list, set_members);
       MEMclose (&files_info);
       MEMclose (&file_list);
       NFMrollback_transaction (0);
       _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
			      fcat_name,status));
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (status);
     }
     }

     /* take out before delivery */

     NFMset_load_item_files (NFM_LOAD_ITEM_FILE);

     /** **/

     if (NFMglobal.load_item_file == NFM_LOAD_ITEM_FILE)
     {
       _NFMdebug ((fname, "Load processed items/files info into global\n"));
       MEMwrite_data (files_info, datetime, 1, i_codate+1);
       NFMload_item_file_information (NFM_SET, files_info, file_list,
         (struct NFMitem_entry *) NULL, set_members);
     }

     _NFMfree_linked_lists (sto_list, set_members);
     MEMclose (&files_info);
     MEMclose (&file_list);

  NFMstart_transaction (0);

  if (wf_info.workflow)
  {
    /* set to state */
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
