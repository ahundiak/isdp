#include "machine.h"
#include <stdio.h>
#include "NFMlocks.h"
#include "NFMfile.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "DEBUG.h"
#include "ERR.h"

/* #include "NFMtime.h" */

/* #define time_it 0 */
                                               
struct child_info *NFMchildren_list=NULL;/* list of the set's children */
struct child_info *NFMend_children_list=NULL;
extern struct set_info1  *NFMset_list1; 
                         /* contain the info about the set and its members */
extern struct set_info1  *NFMend_set_list1;
extern struct attr_info1 *NFMcat_list;
extern struct attr_info1 *NFMend_cat_list;

extern int NFMset_members;
/* extern struct _NFMdebug_st _NFMdebug_st; */
extern struct sto_area_info STO_info;
extern struct NFMglobal_st NFMglobal;

long NFMprepare_set_checkin (user_id, cat_name, item_name, item_rev, 
                             attr_list, data_list)

long   user_id;
char   *cat_name, *item_name, *item_rev;
MEMptr *attr_list, *data_list;

{
  char *fname="NFMprepare_set_checkin";
  char cur_cat_name[50];
  char sql_str[1024];
  long cur_cat_no, cur_fcat_no;
  int quantity; 
  long cat_no, fcat_no;
  long item_no, *item_no_list, item_num;
  long status;
  struct set_info1 *head_new_set_entry=NULL, *end_new_set_entry=NULL;
  struct set_info1 *head_set, *cur_set;
  struct set_info1 *new_set_entry;
  struct child_info *head, *cur_child, *to_be_sort;

  /*
  if (!time_it)
  {
  _NFMdebug_st.NFMdebug_on=1;
  strcpy (_NFMdebug_st.NFMdebug_file, "/usr2/nfmadmin/prepare.dbg");
  _NFMdebug_st.SQLdebug_on=1;
  strcpy (_NFMdebug_st.SQLdebug_file, "/usr2/nfmadmin/prepare.dbg");
  }
  */

  _NFMdebug ( (fname, "ENTER:, cat_name = %s, item = %s.%s\n", cat_name, 
               item_name, item_rev) );

  /*
  if (time_it)
    mb_time1 = times (&mb_tms1);
  */

  /* make sure the application/user is allowed to execute the ci set */

  status = NFMcheck_process_locks (user_id);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcheck_process_locks 0x%.8x\n", 
                NFM_E_BAD_COMMAND_ORDER));
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMstop_transaction 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  /* <catalog> & f_<catalog> numbers of the set */

  status = NFMget_cat_fcat_no (cat_name, &cat_no, &fcat_no, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMget_cat_fcat_no 0x%.8x\n", 
                 NFM_E_CORRUPTED_CATALOG) );
    ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
    NFMrollback_transaction (0);
    return (NFM_E_CORRUPTED_CATALOG);
  }

  /* retrieve the data definition and values of the set */

  status = NFMget_item_data_def_and_values1 (cat_no, fcat_no, cat_name,
                                           item_name, item_rev, &new_set_entry);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFMdebug ( (fname, "NFMget_item_data_def (tbl %d, %d, item %s.%s) 0x%.8x\n",
                 cat_no, fcat_no, item_name, item_rev, NFM_E_BAD_ATTR_VALUE) );
    NFMrollback_transaction (0);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* NFMprint_an_entry_of_linked_list (new_set_entry); */
  NFMset_list1 = NFMend_set_list1 = new_set_entry; /* 1st entry */
  NFMset_list1->consecutive = 1;


  /* retrieve the set's children and store the information in */
  /* NFMchildren_list */
 
  NFMchildren_list = NFMend_children_list = (struct child_info *) calloc ( 1, 
                                           sizeof (struct child_info));
  NFMchildren_list->ccatalogno = cat_no;
  NFMchildren_list->citemno = atol (NFMset_list1->itemno_v);
  NFMchildren_list->fcat_no = fcat_no;
  NFMchildren_list->consecutive = 1;
  NFMchildren_list->level = 0;
  strcpy (NFMchildren_list->cat_name, cat_name);
  strcpy (NFMchildren_list->type, "P");

  /* NFMprint_linked_list (); */
  item_no = atol (NFMset_list1->itemno_v);
  status = NFMget_set_members (cat_no, &item_no, 1, 1); 
           
  if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    NFMfree_linked_list();
    _NFMdebug ( (fname, "NFMget_set_members cat_no = %d, 0x%.8x\n",
                 cat_no,  status) );
    ERRload_struct (NFM, NFM_E_GET_SET_MEMBERS, "", NULL); /* FINISH */
    NFMrollback_transaction (0);
    return (NFM_E_GET_SET_MEMBERS);
  }

  to_be_sort = NFMchildren_list->next;
  if (to_be_sort != (struct child_info *) NULL)
  {
    status = NFMsort_linked_list (to_be_sort);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list();
      _NFMdebug ( (fname, "NFMsort_linked_list 0x%.8x\n ", status) );
      ERRload_struct (NFM, NFM_E_DATA, "", NULL); /* FINISH */
    NFMrollback_transaction (0);
      return (NFM_E_DATA);
    }
  }

  /*
  if (! time_it)
    NFMprint_linked_list1 ();
  */

  _NFMdebug ( (fname, "This set has %d members\n", NFMset_members) );
  /* get the catalogname of the members and f_<catalog> number of the members */

  if (NFMchildren_list->next != (struct child_info *) NULL)
  {
    status = NFMget_children_info ();
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      ERRload_struct ( NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
      _NFMdebug ( (fname, "NFMget_children_info 0x%.8x\n", NFM_E_BAD_ATTR_VALUE));
    NFMrollback_transaction (0);
      return (NFM_E_BAD_ATTR_VALUE);
    }
  }

  /*NFMprint_linked_list ();*/

  /* retrieve the values (item_lock, coout etc..) of the members, since  */
  /* the 1st entry in NFMchildren_list is set itself, skip it */

  if (NFMset_members)
    item_no_list = (long *) calloc (NFMset_members, 
                            sizeof (long));
  item_num = 0;

  head = NFMchildren_list->next;
  if (head != (struct child_info *) NULL)
  {
    cur_cat_no = head->ccatalogno;
    strcpy (cur_cat_name, head->cat_name);
    cur_fcat_no = head->fcat_no;
    *item_no_list = head->citemno;
    item_num = 1;
    head = head->next;

  }

  for (; head != (struct child_info *) NULL; head = head->next)
  {
    if (  head->ccatalogno != cur_cat_no)
    {
      status = NFMget_items_data_def_values1 (
               cur_cat_no, cur_fcat_no, cur_cat_name, 
               item_no_list, item_num,
               &head_new_set_entry, &end_new_set_entry);
      if (status != NFM_S_SUCCESS)
      {
        NFMfree_linked_list();
        ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
        _NFMdebug ( (fname, "NFMget_items_data_def_values 0x%.8x\n", status) );
    NFMrollback_transaction (0);
        return (NFM_E_BAD_ATTR_VALUE);
      }
      
      NFMend_set_list1->next = head_new_set_entry;
      NFMend_set_list1 = end_new_set_entry;
         
      cur_cat_no = head->ccatalogno;
      strcpy (cur_cat_name, head->cat_name);
      cur_fcat_no = head->fcat_no;
      *item_no_list = head->citemno;
      item_num = 1;
      head_new_set_entry = end_new_set_entry = (struct set_info1 *) NULL;
    }
    else
    {
      *(item_no_list + item_num) = head->citemno;
      item_num ++;
    }  
  }

  if (item_num)
  {
  status = NFMget_items_data_def_values1 (cur_cat_no, cur_fcat_no, 
           cur_cat_name, item_no_list, item_num,
           &head_new_set_entry, &end_new_set_entry);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list();
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFMdebug ( (fname, "NFMget_items_data_def_values 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (NFM_E_BAD_ATTR_VALUE);
  }
  NFMend_set_list1->next = head_new_set_entry;
  NFMend_set_list1 = end_new_set_entry;
  }


  for (cur_child = NFMchildren_list;
       cur_child != (struct child_info *) NULL;
       cur_child = cur_child->next)
  {
    for (cur_set = NFMset_list1; cur_set != (struct set_info1 *) NULL;
         cur_set = cur_set->next)
    {
      if ( (atol (cur_set->itemno_v) == cur_child->citemno) &&
           (cur_set->table_no == cur_child->ccatalogno) )
      {
        strcpy (cur_set->type, cur_child->type);
        cur_set->citno =  cur_child->citno;
        cur_set->level =  cur_child->level;
        break;
      }
    }
  }

  /*
  if (!time_it)
    NFMprint_linked_list1 ();  
  */
  status = NFMci_get_data_def (cat_no, fcat_no, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMget_data_def: 0x%.8x \n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  /*
  if (!time_it)
  { 
  MEMprint_buffers ("In NFMprepare_set_checkin, attr_list", *attr_list,
                     "/usr2/nfmadmin/buffers");
  MEMprint_buffers ("In NFMprepare_set_checkin, data_list", *data_list,
                     "/usr2/nfmadmin/buffers");
  }
  */
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "SQLstmt: 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  head_set = cur_set = NFMset_list1;
  cur_cat_no = head_set->table_no;
  quantity = 0;

  for (; cur_set != (struct set_info1 *) NULL; cur_set = cur_set->next)
  {
    if ( cur_set->table_no != cur_cat_no)
    {
      status = NFMget_set_ci_files_info1 (head_set, quantity, *attr_list, 
                                         *data_list);
      if (status != NFM_S_SUCCESS)
      {
        NFMfree_linked_list ();
        ERRload_struct (NFM, status, "", NULL);
        _NFMdebug ( (fname, "NFMget_set_ci_files_info: 0x%.8x\n", status) );
    NFMrollback_transaction (0);
        return (status);
      }
      head_set = cur_set;
      cur_cat_no = head_set->table_no;
      quantity = 1;
    }
    else
      quantity++;
  }

  status = NFMget_set_ci_files_info1 (head_set, quantity, 
                                     *attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, status, "", NULL);
    _NFMdebug ( (fname, "NFMget_set_ci_files_info: 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  head_set = NFMset_list1;
  status = NFMcheck_and_update_items_status1 (head_set, 1, NFM_SET_IN);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }
  head_set = cur_set = NFMset_list1->next;
  if (head_set != (struct set_info1 *) NULL)
    cur_cat_no = head_set->table_no;
  quantity = 0;

  for (; cur_set != (struct set_info1 *) NULL; cur_set = cur_set->next)
  {
    if (cur_set->table_no != cur_cat_no)
    {
      status = NFMcheck_and_update_items_status1 
                      (head_set, quantity, NFM_MEM_IN);
      if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
      {
        NFMfree_linked_list ();
        _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
    NFMrollback_transaction (0);
        return (status);
      }
      head_set = cur_set;
      cur_cat_no = head_set->table_no;
      quantity = 1;
    }
    else
      quantity ++;
  }

  if (quantity)
  {
  status = NFMcheck_and_update_items_status1 (head_set, quantity, NFM_MEM_IN);
  if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }
  }
  
  status = _NFMchk_in_user (*attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "check in the set", "set");
    _NFMdebug ( (fname, "_NFMchk_in_user 0x%.8x\n", NFM_E_NOT_CO_USER) );
    NFMrollback_transaction (0);
    return (NFM_E_NOT_CO_USER);
  }

  status = NFMset_process_lock (user_id, NFM_I_PL_CI_SET);
  if (status != NFM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMset_process_lock 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  /*
  MEMprint_buffers ("In NFMcomplete_set_checkin, attr_list", *attr_list,
                     "/usr/tmp/buffers");
  MEMprint_buffers ("In NFMcomplete_set_checkin, data_list", *data_list,
                     "/usr/tmp/buffers");
  */
    
  /*
  if (time_it)
  {
    mb_time2 = times (&mb_tms2);

    _NFMdebug_st.NFMdebug_on = 1;
    strcpy (_NFMdebug_st.NFMdebug_file, "/usr2/nfmadmin/time.new");

    _NFMdebug ( (fname, "T = %ld, cpu = %d, sys =%d \n",
                mb_time2-mb_time1,
                mb_tms2.tms_utime - mb_tms1.tms_utime,
                mb_tms2.tms_stime - mb_tms1.tms_stime) );

    _NFMdebug_st.NFMdebug_on = 0;
    strcpy (_NFMdebug_st.NFMdebug_file, "\0");

  }
  */
  
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}


long NFMcancel_set_checkin (user_id, attr_list, data_list)
long      user_id;
MEMptr    attr_list, data_list;
{
  long  status;
  char  *fname="NFMcancel_set_checkin";

  _NFMdebug ( (fname, "ENTER:\n"));

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CI_SET))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFMdebug ( (fname, "NFMcheck_process_locks 0x%.8x\n",
                 NFM_E_BAD_COMMAND_ORDER) );       
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CI_SET)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CI_SET);
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_set ();
      NFMfree_linked_list ();
      _NFMdebug ( (fname, "NFMreset_process_lock 0x%.8x\n", status) );
      return (status);
    }
  }

  status = _NFMrollback_set ();
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "_NFMrollback_set 0x%.8x\n", status) );
    return (status);
  }

  status = NFMfree_linked_list ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMfree_linked_list 0x%.8x\n", status) );
    return (status);
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMstart_transaction 0x%.8x\n", status) );
    return (status);
  }
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}



long NFMcomplete_set_checkin (user_id, storage_name,
                              node_name, user_name, passwd, path_name, 
                              attr_list, data_list)
long      user_id;
char      *storage_name;
char      *node_name, *user_name, *passwd, *path_name;
MEMptr    attr_list, data_list;
{
  char *fname="NFMcomplete_set_checkin";
  char datetime_str[50];
  char datetime[50];
  int  i, j, k;
  long status, del_status, pur_status;
  MEMptr list=NULL;
  

  _NFMdebug ( (fname, "ENTER: \n") )

  /*
  if (time_it)
    mb_time1 = times (&mb_tms1);
  */

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CI_SET))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFMdebug ( (fname, "NFMcheck_process_locks 0x%.8x\n",
                 NFM_E_BAD_COMMAND_ORDER) );
    NFMrollback_transaction (0);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CI_SET)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CI_SET);
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_set ();
      NFMfree_linked_list ();
      _NFMdebug ( (fname, "NFMreset_process_lock 0x%.8x\n", status));
    NFMrollback_transaction (0);
      return (status);
    }
  }

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMget_datetime 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMascii_to_timestamp_format 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);
  }

  if (strlen (storage_name))
  {
    status = _NFMsa_info (storage_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_set ();
      NFMfree_linked_list ();
      ERRload_struct ( NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFMdebug ( (fname, "_NFMsa_info 0x%.8x\n", status));
    NFMrollback_transaction (0);
      return (status);     
    }
    passwd [0] = 0;
  }
  else if ((strlen (node_name)) || (strlen (user_name)) ||
           (strlen (path_name)))
  {
/* PUT IN PASSWORD SO THAT TEMP SA HAS PASSWD MRG 07/18/91 */

    status = _NFMadd_temp_sa (user_id, node_name, user_name,
                  path_name,passwd);
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_set ();
      NFMfree_linked_list ();
      ERRload_struct ( NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFMdebug ( (fname, "_NFMadd_temp_sa 0x%.8x\n", status));
    NFMrollback_transaction (0);
      return (status);     
    }
  }
  else
  {
     _NFMrollback_set ();
     NFMfree_linked_list ();
     ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
     _NFMdebug ( (fname, "Bad Storage 0x%.8x\n", NFM_E_BAD_ST_AREA));
    NFMrollback_transaction (0);
     return (NFM_E_BAD_ST_AREA);     
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMbuild_array (attr_list) 0x%.8x\n", NFM_E_MEM));
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMbuild_array (data_list) 0x%.8x\n", NFM_E_MEM));
    NFMrollback_transaction (0);
    return (NFM_E_MEM);
  }

  status = NFMget_move_files_list (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMrollback_set ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
    _NFMdebug ( (fname, "NFMget_move_files_list 0x%.8x\n", NFM_E_BAD_TEMPLATE));
    NFMrollback_transaction (0);
    return (NFM_E_BAD_TEMPLATE);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  status = NFMget_ci_set_files (user_id, attr_list, data_list, list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
    _NFMdebug ( (fname, "NFMget_move_files_list 0x%.8x\n", NFM_E_BAD_FILE));
    NFMrollback_transaction (0);
    return (NFM_E_BAD_FILE);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    NFMrollback_transaction (0);
    return (status);
  }

  /*
  NFMprint_linked_list ();
  MEMprint_buffers ("In NFMcomplete_set_checkin, attr_list", attr_list,
                     "/usr2/nfmadmin/buffers");
  MEMprint_buffers ("In NFMcomplete_set_checkin, data_list", data_list,
                     "/usr2/nfmadmin/buffers");
  MEMprint_buffers ("In NFMcomplete_set_checkin, list", list,
                     "/usr2/nfmadmin/buffers");
  */
 
  status = _NFMmv_files_out (user_id, STO_info.sano, passwd, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "_NFMmv_files_out 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);               
  }

  status = NFMcopy_in_files (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    _NFMdebug ( (fname, "NFMcopy_in_files 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);               
  }
    
  status = NFMupd_ci_set_cat_fcat (user_id, NFMglobal.NFMusername, datetime, 
                                 STO_info.sano, attr_list, data_list, list);

  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMrollback_set ();
    _NFMrollback_fcat_records ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
    _NFMdebug ( (fname, "NFMcopy_in_files 0x%.8x\n", status));
    NFMrollback_transaction (0);
    return (status);               
  }

  del_status = _NFMdel_in_files (user_id, STO_info.sano, passwd, &list);
  if (del_status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMdelete_in_files: 0x%.8x\n", del_status));
  }

  pur_status = NFMpurge_ci_set_item_files (user_id);
  if (pur_status != NFM_S_SUCCESS)
  {
     _NFMdebug ( (fname, "NFMpurge_ci_set_item_files 0x%.8x\n", pur_status));
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose 0x%.8x\n", status));
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMstart_transaction 0x%.8x\n", status) );
    return (status);
  }

  NFMfree_linked_list ();
  /*
  if (time_it)
  {
    mb_time2 = times (&mb_tms2);

    _NFMdebug_st.NFMdebug_on = 1;
    strcpy (_NFMdebug_st.NFMdebug_file, "/usr2/nfmadmin/time.new");

    _NFMdebug ( (fname, "T = %ld, cpu = %d, sys =%d \n",
                mb_time2-mb_time1,
                mb_tms2.tms_utime - mb_tms1.tms_utime,
                mb_tms2.tms_stime - mb_tms1.tms_stime) );

    _NFMdebug_st.NFMdebug_on = 0;
    strcpy (_NFMdebug_st.NFMdebug_file, "\0");

  }
  */

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
