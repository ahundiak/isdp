#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "MSGstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "WFstruct.h"


#define NFM_TEMP_SIZE1 18
extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;


long NFMpccancel_check_out_set (catalog_name, catalog_no, set_name, 
                      set_revision, set_no,
                      wf_info, member_operations, operation, 
                      level)
/*** 
 
  This function will cancel a checked-out-set.

  Notes: input "level" is not used. (10/9/91)

  CHANGE HISTORY:
    01/20/92 mfb Creation.
***/

char *catalog_name; 
long catalog_no;
char *set_name, *set_revision;
long set_no;
struct NFMwf_info wf_info;
long member_operations;
struct NFMoperation *operation;
long level;

{
  char *fname="NFMpccancel_check_out_set";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024];
  char row_str[2048];
  char read_str[10], delete_str[10], nfs_str[10];
  char **data, **data1;
  char fileco_str[NFM_FILECO+1];
  char working_area [NFM_SANAME+1];
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
  long degree;
  long x, y, z, count;
  long index;
  long i_catno, i_itemnum, i_type, i_fileno, i_filenum, i_fileversion,
      i_filetype, i_fileco, i_cifilename, i_cofilename, i_status1,
      i_cosano, i_cifilesize=0, i_cisano, i_itemrev, i_catname, i_itemname,
      i_itemdesc;
  long sano=-1, sto_no;
  long cur_cat_no;
  long status, status1;
  long num_members;
  long dumb_value, lfm_count;
  MEMptr list=NULL, list1=NULL, file_list=NULL, files_info=NULL; 
  struct NFMlfm_file *lfm_files;
  struct NFMset_member *set_members, *cur_set, *new_node;
  struct NFMset_member *begin_process;
  struct NFMmembers *members_list;
  struct NFMsto_info *sto_list;
  struct NFMbuf_format *format;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n\
                       cat_no [%d] set_no [%d]\n\
                       wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] member_operations[%d]\n\
                       user name [%s]\n", 
                       catalog_name, set_name,
                       set_revision, catalog_no, set_no, 
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation->transfer, operation->delete, operation->purge,
                       member_operations, NFMglobal.NFMusername));

  sprintf (fcat_name, "f_%s", catalog_name);

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

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
      if (DM_MANAGER)
      _DMdo_nothing ();
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
      return (status);
    }

  }
  status = NFMopen_message_buffer ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMopen_message_buffer: 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
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
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, 
                                   dumb_str, &catalog_no, &list);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMretrieve_values(%s) failed 0x%.8x\n", 
                     sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        if (DM_MANAGER)
      _DMdo_nothing ();
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
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str, &set_no,
                                   &list);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLquery(%s) failed 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        if (DM_MANAGER)
      _DMdo_nothing ();
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
                               &dumb_value, &list); 
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "SQLquery (%s) failed 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  /* "list" contains 1st level children */

  data = (char **) list->data_ptr;

  cur_set = set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  members_list = (struct NFMmembers *) calloc (list->rows, 
                                   sizeof (struct NFMmembers));
  if (set_members == (struct NFMset_member *) NULL ||
      members_list == (struct NFMmembers *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      set_members? (list->rows * sizeof(struct NFMmembers )): 
                      sizeof (struct NFMset_member));
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "Allocating %d failed \n", set_members?
                (list->rows *sizeof(struct NFMmembers)): 
                sizeof (struct NFMset_member)));
    if (DM_MANAGER)
    _DMdo_nothing ();
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

  status = NFMretrieve_set_members (members_list, list->rows, 2, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL,
                           set_members);
    free (members_list);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  free (members_list);
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL,
                           set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }
 

  /* retrieve all the catalog numbers from nfmcatalogs */

  status = NFMget_catalog_names (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMget_catalog_names 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
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
      status = NFMget_members_info (begin_process, count, NFM_CANCEL_CHECK_OUT);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT, set_members, 
              (MEMptr) NULL, x+1, 0, 0, 
                                (struct NFMlfm_file *) NULL, 
                                (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
        if (DM_MANAGER)
          _DMdo_nothing ();
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      begin_process = cur_set;
      _NFMdebug ((fname, "cur_cat_no = %d begin_process addr %ld\n", 
                 set_members->cat_no, begin_process));
      count = 1;
    }
  }

  status = NFMget_members_info (begin_process, count, NFM_CANCEL_CHECK_OUT);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,x+1, 0, 0, 
                            (struct NFMlfm_file *) NULL, 
                            (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    NFMstart_transaction (0);
    _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }


  if (operation->transfer == NFM_NO_TRANSFER)
  {
    _NFMdebug ((fname, "this is a checkout set in place\n"));
    for (x = 0, cur_set = set_members, cur_cat_no = 0; 
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
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, x + 1,
            (struct NFMlfm_file *)NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                      fcat_name,status));
          if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }

      _NFMdebug ((fname, "Update the record(s) in %s\n", fcat_name));
      sprintf (sql_str, 
               "%s %s %s %s %s %d %s %s %s %d %s",
               "update", fcat_name, "set n_cosano = NULL,", 
               "n_couser = NULL, n_codate = NULL ", 
               "where n_itemnum = ", cur_set->item_no, 
               "and n_fileversion = (select max(n_fileversion) from",
               fcat_name, "where n_itemnum =", cur_set->item_no, ")");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, x + 1, 0, 
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {

          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members,
		 (MEMptr) NULL, num_members, x + 1, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
      }
    }

    for (x = 0, cur_set = set_members->next, cur_cat_no = 0; 
         x < num_members; x++)
    {
      /* this for loop can be improved for speed, COME BACK when there is
         more time */

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
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMlock_table %s 0x%.8x\n", cur_set->cat_name,
                      status));
          if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }
      if (!x)
      {
        if (strlen (cur_set->file_status))
          strcpy (file_status, "I");
        else
          strcpy (file_status, "");
      }
      else
      {
        if (strlen (cur_set->file_status))
          strcpy (file_status, "I");
        else
          strcpy (file_status, "");
      }
      status = NFMset_item_status (catalog_name, "", "", cur_set->item_no, 
                                   file_status, NFM_NO_LOCK, "");
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        NFMrollback_transaction (0);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                    catalog_name,status));
        if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      cur_set->cat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
      }
    }
      
    status = NFMstart_transaction (0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMstart_transaction failed 0x%.8x\n", status));
    }

    status = _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    if (status != NFM_S_SUCCESS)
      _NFMdebug ((fname, "_NFMfree_linked_lists 0x%.8x\n", status));

    _NFMdebug ((fname, "EXIT: (operation == NFM_NO_TRANSFER) 0x%.8x\n", 
                NFM_S_SUCCESS));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_S_SUCCESS);
  } /* if (operation->transfer == NFM_NO_TRANSFER */

  else 
  {
    _NFMdebug ((fname, "this is a checkout set with conditional transfer\n"));
    status = MEMopen (&files_info, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members,
		 (MEMptr) NULL, num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (status);
    }

    format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1, 
                                 sizeof (struct NFMbuf_format));

    if (!format)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "Failed to allocate memory");
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (NFM_E_MESSAGE);
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
    strcpy ((format+8)->attr_name, "n_cosano");
    strcpy ((format+8)->data_type, "integer");
    strcpy ((format+9)->attr_name, "n_cifilename");
    strcpy ((format+9)->data_type, "char(14)");
    strcpy ((format+10)->attr_name, "n_cofilename");
    strcpy ((format+10)->data_type, "char(14)");
    strcpy ((format+11)->attr_name, "n_cisano");
    strcpy ((format+11)->data_type, "integer");
    strcpy ((format+12)->attr_name, "n_cifilesize");
    strcpy ((format+12)->data_type, "integer");
    strcpy ((format+13)->attr_name, "n_status1");
    strcpy ((format+13)->data_type, "char(2)");
    strcpy ((format+14)->attr_name, "n_itemrev");
    strcpy ((format+14)->data_type, "char(60)");
    strcpy ((format+15)->attr_name, "n_catname");
    strcpy ((format+15)->data_type, "char(60)");
    strcpy ((format+16)->attr_name, "n_itemname");
    strcpy ((format+16)->data_type, "char(60)");
    strcpy ((format+17)->attr_name, "n_itemdesc");
    strcpy ((format+17)->data_type, "char(40)");

    status = _NFMbuild_working_buffer_format 
                            (format, NFM_TEMP_SIZE1, files_info);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members,
		 (MEMptr) NULL, num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      NFMrollback_transaction (0);
      free (format);
      _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (status);
    }

    free (format);
    
    i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
    i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cosano = 8;
    i_cifilename = 9; i_cofilename = 10; i_cisano = 11; i_cifilesize = 12;
    i_status1 = 13; i_itemrev = 14; i_catname=15; i_itemname=16; i_itemdesc=17;
    
    for (x = 0, cur_set = set_members, cur_cat_no = 0;
         x < num_members; x ++, cur_set=cur_set->next)
    {
      /* Is this catalog same as the previous one?
         yes: table is already locked, don't do anything.
         no: lock the f_<catalog> */

      if (cur_set->cat_no != cur_cat_no)
      {
        sprintf (fcat_name, "f_%s", cur_set->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
          MEMclose (&files_info);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
      }

      _NFMdebug ((fname,
                "prepare to retrieve the information from f_<catalog>\n"));
      sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %d %s",
             "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
  "n_cosano, n_cifilename, n_cofilename, n_cisano, n_couser, n_cifilesize from",
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
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }

      data = (char **) list->data_ptr;

      if (!x)
      {
        _NFMdebug ((fname, "Retrieve checked-out storage area information\n"));
        sano = atol (data[5]);
        status = NFMget_storage_info 
                               (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_filee *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status));
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
        if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
                        (strcmp (opsys, "WINDOS") == 0)    )
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_filee *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, 
             "cannot cco item that was checked out using DMM\n"));
          ERRload_struct (NFM, NFM_E_NFM_CLIENT_CCO_PC, "", NULL);
          return (NFM_E_NFM_CLIENT_CCO_PC);
        }
        if (strcmp (data[9], NFMglobal.NFMusername))
        {
          if (DM_MANAGER)
            ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", 
              "cancel check out folder/drawing/document group", "set");
          else
            ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", 
              "cancel check out set", "set");
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_filee *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status));
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (NFM_E_NOT_CO_USER);
        }
      }
      _NFMdebug ((fname, 
                  "write the files information of this item to files_info\n"));
      for (y = 0; y < list->rows; y ++)
      {
        index = list->columns * y;
        if (!strlen (data[index+4]) && (atol (data[index+1]) > 0))
        {
          _NFMdebug ((fname, 
             "file was added to the set/member while it was out\n"));
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
          MEMclose (&files_info);
          NFMstart_transaction ();
          if (DM_MANAGER)
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
            "File(s) was/were added to the drawing/document group or its links/attachments");
            _DMdo_nothing ();
          }
          else
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
            "File(s) was/were added to the set or its members");
          
          return (NFM_E_FAILURE);
        }
        sprintf (row_str, "%d\1%d\1%s\1",
                 cur_set->cat_no, cur_set->item_no, cur_set->type);
        for (z = 0; z < list->columns - 1; z ++)
        {
          strcat (row_str, data[index+z]);
          strcat (row_str, "\1");
        }
        strcat (row_str, "\1");
        strcat (row_str, cur_set->item_rev); /* added these two for DMM */
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
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
          MEMclose (&files_info);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (0);
        }
      }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (0);
      }
    }
    status = MEMbuild_array (files_info);
    if (status != MEM_S_SUCCESS)
    {

      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEM_S_SUCCESS 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (0);
    }

    status = _DMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
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
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      NFMrollback_transaction (0);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (status);
    }
   
    sto_list = (struct NFMsto_info *) calloc (files_info->rows,
                        sizeof(struct NFMsto_info));

    if (!sto_list)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      files_info->rows * sizeof (struct NFMsto_info) );
      _NFMdebug ( (fname, "calloc sto_list failed\n") );
    if (DM_MANAGER)
      _DMdo_nothing ();
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
      if (y >= sto_no && atol(data[index+i_cisano]) > 0)
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
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
                (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&file_list);
          NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
    }
    if (_NFMdebug_st.NFMdebug_on)
      _NFMprint_storages_information (sto_list, sto_no);

    lfm_files = (struct NFMlfm_file *)calloc (files_info->rows,
                  sizeof (struct NFMlfm_file) );
    if (!lfm_files)
    {
      NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&file_list);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "malloc %d for lfm_files failed\n", 
                         files_info->rows * sizeof (struct NFMlfm_file)));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                         files_info->rows * sizeof (struct NFMlfm_file));
    if (DM_MANAGER)
      _DMdo_nothing ();
      return (NFM_E_MALLOC);
    }
 
    sprintf (read_str, "%d", NFM_READ);
    sprintf (delete_str, "%d", NFM_DELETE_FILE);
    sprintf (nfs_str, "%d", NFM_NFSED);

    _NFMdebug ((fname, "prepare file transfer buffer\n"));
    for (x = lfm_count = 0; x < files_info->rows; x ++)
    {
      index = files_info->columns * x;
      _NFMdebug ((fname, "processing cat [%s] item [%s]\n",
                          data[index+i_catno], data[index+i_itemnum]));
      if (!strlen (data[index+i_fileco]) ||
          atol (data[index+i_filenum]) < 1 ||
          atol (data[index+i_fileversion]) < 1)
      {
        _NFMdebug ((fname, "no file movement, continue\n"))
        continue;
      }
      sprintf (sql_str, 
               "%s %s %d %s '%s' %s %s %s %s %s %s",
               "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
               "n_fileversion from nfmsafiles where n_sano =", 
               sano, "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =", 
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum]);

      /* COME BACK AND FIX: save the n_co, and n_ref value */
      status = SQLquery (sql_str, &list1, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
      {
        status = MEMbuild_array (list1);
        if (status != MEM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&file_list);
          free (lfm_files);
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
          return (status);
        }
        data1 = (char **) list1->data_ptr;
        if (strcmp (data[index+i_type], "S"))
        {
          if (atol (data1[2]) > 0 || strcmp (data1[1], "N"))
          {
            _NFMdebug ((fname, "primary member checked out, NO DELETE, \n\
              it is copied or referenced\n"));
            (lfm_files+lfm_count)->action = NFM_NULL_CO_FROM_NFMSAFILES;
          }
          else
          {
            _NFMdebug ((fname, "primary member checked out, DELETE \n"));
            (lfm_files+lfm_count)->action = NFM_DELETE_FROM_NFMSAFILES;
          }
        }
        else if (atol (data1[2]) > 1 || strcmp (data1[1], "N") ||
                 strcmp (data1[0], "N") )
        {
          _NFMdebug ((fname, "secondary member, NO DELETE, \n\
            it is copied or referenced or checked out\n"));
          (lfm_files+lfm_count)->action = NFM_DECREMENT_REF;
        }
        else
        {
          _NFMdebug ((fname, "secondary member, DELETE \n"));
          (lfm_files+lfm_count)->action = NFM_DELETE_FROM_NFMSAFILES;
        }
        strcpy ((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
        strcpy ((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
        strcpy ((lfm_files+lfm_count)->filename, data[index+i_cofilename]);
        strcpy ((lfm_files+lfm_count)->filenum, data[index+i_filenum]);
        strcpy ((lfm_files+lfm_count)->type, data[index+i_type]);
        strcpy ((lfm_files+lfm_count)->co, data1);
        strcpy ((lfm_files+lfm_count)->copy, data1[1]);
        (lfm_files+lfm_count)->ref = atol (data1[2]);
        if (strlen (data1[3]))
        {
          strcpy ((lfm_files+lfm_count)->nfs, data1[3]);
          strcpy ((lfm_files+lfm_count)->cisano, data1[4]);
          strcpy ((lfm_files+lfm_count)->mountpoint, data1[5]);
        }
        strcpy ((lfm_files+lfm_count)->fileversion, data1[6]);
        MEMclose (&list1);
      }
      else if (status == SQL_I_NO_ROWS_FOUND)
      {
        (lfm_files+lfm_count)->action = 0; /* no entry in the table */
        strcpy ((lfm_files+lfm_count)->cat_no, data[index+i_catno]);
        strcpy ((lfm_files+lfm_count)->item_no, data[index+i_itemnum]);
        strcpy ((lfm_files+lfm_count)->type, data[index+i_type]);
      }
      else  
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
      _NFMdebug ((fname, "Try to find cisano [%d] in sto_list\n",
                  data[index+i_cosano]));
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                            y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+i_cisano]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
          sprintf (row_str,
         "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
           (sto_list+y)->sano,
           (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
           (sto_list+y)->pathname, (sto_list+y)->devicetype,
           (sto_list+y)->plattername,
           (sto_list+y)->partition,
           (lfm_files+lfm_count)->nfs, (lfm_files+lfm_count)->mountpoint,
           (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
           (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
           (sto_list+y)->netware);
          break;
        }
      }
      if (y >= sto_no)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members,
                 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "check-in-to storage area incorrect\n"));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
           "Invalid storage area");
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
      strcat (row_str, data[index+i_fileno]); strcat (row_str, "\1\1\1");
      strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
 
      if (strcmp (data[index+i_type], "S"))
      {
        _NFMdebug ((fname, "this file belong to primary member\n"));
        if ((lfm_files+lfm_count)->action == NFM_NULL_CO_FROM_NFMSAFILES)
        {
          strcat (row_str, read_str); strcat (row_str, "\1\1\1");
        }
        else
        {
          strcat (row_str, delete_str); strcat (row_str, "\1\1\1");
        }
      }
      else
      {
        if ((lfm_files+lfm_count)->action == NFM_DECREMENT_REF)
        {
          strcat (row_str, "\1\1\1");
        }       
        else if (!strcmp ((lfm_files+lfm_count)->nfs, "Y"))
        {
          strcat (row_str, nfs_str); strcat (row_str, "\1\1\1");
        }
        else 
        {
          strcat (row_str, delete_str); strcat (row_str, "\1\1\1");
        }
      }
      lfm_count ++;
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
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,

              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
      _DMdo_nothing ();
        return (status);
      }
    } /* prepare file transfer buffer */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
 
    if (DM_MANAGER)
      status = DMrm_co_files (&file_list, 0);
    else
      status = NFMpcrm_co_files (&file_list, 0);

    if (status != NFM_S_SUCCESS)
    {
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      status1 = _NFMstack_error_from_buffer (file_list, catalog_name,
               set_name, set_revision, NFM_CANCEL_CHECK_OUT, files_info);
      if (status1 != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        free (lfm_files);
        if (DM_MANAGER)
          _DMfs_undo_recv_files (&file_list);
        else
          _NFMpcfs_undo_recv_files (&file_list);
        MEMclose (&file_list);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "_NFMpcfs_recv_files 0x%.8x\n", status));
        return (status);
      }
      _NFMdebug ((fname, 
                  "File movement for file(s) failed, but cmd can continu\n"));
    }
     
    /* update the f_<catalog> */
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
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, 0, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&file_list);
          free (lfm_files);
          NFMrollback_transaction (0);
          _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                      fcat_name,status));
          return (status);
        }
        cur_cat_no = cur_set->cat_no;
        _NFMdebug ((fname, "Update the record(s) in %s\n", fcat_name));
      }


      for ( ; y < files_info->rows; y++ )
      {
        index = files_info->columns * y;
        if (atol(data[index+i_catno]) == cur_set->cat_no &&
            atol(data[index+i_itemnum]) == cur_set->item_no )
          break;
      }
      _NFMdebug ((fname, "found match, [%d], cat_no [%s] item_no [%s]\n",
                         y, data[index+i_catno], data[index+i_itemnum]));
     
      if (strlen(data[index+i_fileco]))
        strcpy (fileco_str, ",n_fileco = 'N'");
      else 
        strcpy (fileco_str, "");

      sprintf (sql_str, 
        "%s %s %s %s %s %s %s %d %s %s ",
               "update", fcat_name, "set n_cosano = NULL,", 
               "n_couser = NULL,", 
                "n_codate = NULL", fileco_str,
               "where n_itemnum = ", cur_set->item_no, 
               "and n_fileversion =", data [index+i_fileversion]);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, x+1, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&file_list);
        free (lfm_files);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);  
        return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, x+1, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *) NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&file_list);
          free (lfm_files);
          NFMrollback_transaction (0);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
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
	  NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
	 (MEMptr) NULL,num_members, num_members,
                  num_members, lfm_files, (struct NFMlfm_file*) NULL);
	  _NFMfree_linked_lists (sto_list, set_members);
	  MEMclose (&files_info);
	  MEMclose (&file_list);
          free (lfm_files);
	  NFMrollback_transaction (0);
	  _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
		      fcat_name,status));
	  return (status);
	}
	cur_cat_no = cur_set->cat_no;
	_NFMdebug ((fname, "Update the record(s) in %s\n", cur_set->cat_name));
      }

      if (x)
      {
	if (strlen (cur_set->file_status) == 1)
	  strcpy (file_status, "I");
	else
	  strcpy (file_status, "");
      }
      else
      {
	if (strlen (cur_set->file_status) == 1)
	  strcpy (file_status, "I");
	else
	  strcpy (file_status, "");
      }

      sprintf (sql_str, "%s %s %s '%s' %s %d", 
	       "update", cur_set->cat_name, "set n_status =", file_status, 
	       "where n_itemno = ", cur_set->item_no);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
	NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
	 (MEMptr) NULL,num_members, 
         num_members, num_members, lfm_files, (struct NFMlfm_file*)NULL);
	_NFMfree_linked_lists (sto_list, set_members);
	MEMclose (&files_info);
	MEMclose (&file_list);
        free (lfm_files);
	NFMrollback_transaction (0);
	_NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	return (status);
      }
      cur_set = cur_set->next;
      if ( cur_cat_no != cur_set->cat_no)
      {
	status = SQLstmt ("COMMIT WORK");
	if (status != SQL_S_SUCCESS)
	{
	  NFMrollback_set_status (NFM_CANCEL_CHECK_OUT,set_members, 
		 (MEMptr) NULL,num_members, num_members,
                  num_members, lfm_files, (struct NFMlfm_file*)NULL);
	  _NFMfree_linked_lists (sto_list, set_members);
	  MEMclose (&files_info);
	  MEMclose (&file_list);
          free (lfm_files);
	  NFMrollback_transaction (0);
	  _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
		      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	  return (status);
	}
      }
    }
    if (operation->transfer == NFM_CONDITIONAL_TRANSFER)
    {
      _NFMdebug ((fname, "update local file manager\n"));

      for (x = 0; x < lfm_count; x ++)
      {
        _NFMdebug ((fname, "cat [%s] item [%s]\n",
                    (lfm_files+x)->cat_no, (lfm_files+x)->item_no));

        if ((lfm_files+x)->action == NFM_DELETE_FROM_NFMSAFILES)
        {
          _NFMdebug ((fname, "remove record from nfmsafiles\n"));
          sprintf (sql_str,
          "%s %d %s '%s' %s %s %s %s %s %s %s %s", 
          "delete from nfmsafiles where n_sano =", sano,
          "and n_filename =", (lfm_files+x)->filename,
          "and n_catalogno =", (lfm_files+x)->cat_no,
          "and n_itemno =", (lfm_files+x)->item_no,
          "and n_filenum =", (lfm_files+x)->filenum,
          "and n_fileversion =", (lfm_files+x)->fileversion);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
            _NFMdebug ((fname, "SQLstmt(%s) 0x%.8x\n", status));
        }
        else if ((lfm_files+x)->action == NFM_NULL_CO_FROM_NFMSAFILES)
        {
          _NFMdebug ((fname, "set n_co == N\n"));
          sprintf (sql_str,
          "%s %d %s '%s' %s %s %s %s %s %s %s %s", 
          "update nfmsafiles set n_co = 'N' where n_sano =", sano,
          "and n_filename =", (lfm_files+x)->filename,
          "and n_catalogno =", (lfm_files+x)->cat_no,
          "and n_itemno =", (lfm_files+x)->item_no,
          "and n_filenum =", (lfm_files+x)->filenum,
          "and n_fileversion =", (lfm_files+x)->fileversion);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
            _NFMdebug ((fname, "SQLstmt(%s) 0x%.8x\n", status));
        }
        else if ((lfm_files+x)->action == NFM_DECREMENT_REF)
        {
          _NFMdebug ((fname, "n_ref --\n"));
          sprintf (sql_str,
          "%s %d %s %d %s '%s' %s %s %s %s %s %s %s %s", 
          "update nfmsafiles set n_ref =", --(lfm_files+x)->ref,
          "where n_sano =", sano,
          "and n_filename =", (lfm_files+x)->filename,
          "and n_catalogno =", (lfm_files+x)->cat_no,
          "and n_itemno =", (lfm_files+x)->item_no,
          "and n_filenum =", (lfm_files+x)->filenum,
          "and n_fileversion =", (lfm_files+x)->fileversion);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
            _NFMdebug ((fname, "SQLstmt(%s) 0x%.8x\n", status));
        }
      }
    }
  }

  free (lfm_files);
  _NFMfree_linked_lists (sto_list, set_members);
  MEMclose (&files_info);
  MEMclose (&file_list);

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
