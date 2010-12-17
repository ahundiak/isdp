#include "machine.h"
#include <stdio.h>
#include "NFMlocks.h"
#include "NFMfile.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "ERR.h"

/* #include "NFMtime.h" */
/* #define time_it 0 */

extern struct child_info *NFMchildren_list;/* list of the set's children */
extern struct child_info *NFMend_children_list;
extern struct set_info1  *NFMset_list1; 
extern struct set_info1  *NFMend_set_list1;

extern struct attr_info1  *NFMcat_list;
extern struct attr_info1  *NFMend_cat_list;

extern int NFMset_members;
/* extern struct _NFMdebug_st _NFMdebug_st; */
extern struct sto_area_info STO_info;

long NFMprepare_set_copy (user_id, cat_name, item_name, item_rev,
                               level, attr_list, data_list)
long    user_id;
char    *cat_name, *item_name, *item_rev;
long    level;
MEMptr  *attr_list, *data_list;
{
  char  **column, **data, **data1;
  char  cur_cat_name[50], temp_cat [100], temp_flag [10];
  char  *fname="NFMprepare_set_copy";  
  int   quantity;
  long   cat_no, fcat_no, cur_cat_no, cur_fcat_no;
  long   item_num, *item_no_list;
  long  status;
  long  a, b, c, i, j, k, l, x, y, count;
  long  item_no;
  struct set_info1 *new_set_entry, *cur_set, *head_set;
  struct set_info1 *head_new_set_entry=NULL, *end_new_set_entry=NULL;
  struct child_info *to_be_sort, *head, *cur_child;
 
  /*
  if (!time_it)
  {
  _NFMdebug_st.NFMdebug_on=1;
  strcpy (_NFMdebug_st.NFMdebug_file, "/usr2/nfmadmin/prepare.dbg");
  _NFMdebug_st.SQLdebug_on=1;
  strcpy (_NFMdebug_st.SQLdebug_file, "/usr2/nfmadmin/prepare.dbg");
  }
  */

  _NFMdebug ( (fname, "ENTER: cat = %s, item = %s.%s\n", cat_name, 
                              item_name, item_rev));


  /*
  if (time_it)
    mb_time1 = times (&mb_tms1);
  */

  status = NFMcheck_process_locks (user_id);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcheck_process_locks 0x%.8x\n",
                NFM_E_BAD_COMMAND_ORDER));
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    return (NFM_E_BAD_COMMAND_ORDER);

  }

  status = NFMget_cat_fcat_no (cat_name, &cat_no, &fcat_no, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMget_cat_fcat_no 0x%.8x\n", 
                 NFM_E_CORRUPTED_CATALOG))
    ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
    return (NFM_E_CORRUPTED_CATALOG);
  }


  status = NFMget_item_data_def_and_values1 (cat_no, fcat_no, cat_name,
                                           item_name, item_rev, &new_set_entry);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMget_item_data_def (tbl %d, %d, item %s.%s) 0x%.8x\n",
                cat_no, fcat_no, item_name, item_rev, NFM_E_BAD_ATTR_VALUE) );
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  NFMset_list1 = NFMend_set_list1 = new_set_entry;
  NFMset_list1->consecutive = 1;
  _NFMdebug ( (fname, "NFMset_list1 = %ld, NFMend_set_list1 = %ld\n",
                       NFMset_list1, NFMend_set_list1) );


  NFMchildren_list = NFMend_children_list = (struct child_info *) calloc ( 1,
                                           sizeof (struct child_info));
  NFMchildren_list->ccatalogno = cat_no;
  NFMchildren_list->citemno = atol (NFMset_list1->itemno_v);
  NFMchildren_list->fcat_no = fcat_no;
  NFMchildren_list->consecutive = 1;
  NFMchildren_list->level = 0;
  strcpy (NFMchildren_list->cat_name, cat_name);
  strcpy (NFMchildren_list->type, "P");

  item_no = atol (NFMset_list1->itemno_v);
  status = NFMget_set_members (cat_no, &item_no, 1, 1);

  if ((status != NFM_S_SUCCESS)&& (status != SQL_I_NO_ROWS_FOUND))
  {
    NFMfree_linked_list();
    _NFMdebug ( (fname, "NFMget_set_members cat_no = %d, 0x%.8x\n",
                 cat_no,  status) );
    ERRload_struct (NFM, NFM_E_GET_SET_MEMBERS, "", NULL); /* FINISH */
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
      return (NFM_E_DATA);
    }
  }
  /* NFMprint_linked_list1 (); */

  if (NFMchildren_list->next != (struct child_info *) NULL)
  {
    status = NFMget_children_info ();
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      ERRload_struct ( NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
      _NFMdebug ( (fname, "NFMget_children_info 0x%.8x\n", NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }
  }

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
        _NFMdebug ( (fname, "NFMget_items_data_def_values1 0x%.8x\n", status) );
        return (NFM_E_BAD_ATTR_VALUE);
      }

      _NFMdebug ( (fname, "NFMset_list1 = %ld, NFMend_set_list1 = %ld\n",
                       NFMset_list1, NFMend_set_list1) );
      NFMend_set_list1->next = head_new_set_entry;
      NFMend_set_list1 = end_new_set_entry;
      _NFMdebug ( (fname, "NFMset_list1 = %ld, NFMend_set_list1 = %ld\n",
                       NFMset_list1, NFMend_set_list1) );

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
    _NFMdebug ( (fname, "NFMget_items_data_def_values1 0x%.8x\n", status) );
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
      _NFMdebug ( (fname, "cur_child->citemno [%d], cur_set->itemno_v[%s]\n",
                   cur_child->citemno, cur_set->itemno_v) );
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

  status = NFMget_data_def1 (cat_no, fcat_no, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_DATA, "", NULL);
    _NFMdebug ( (fname, "NFMget_data_def: 0x%.8x \n", status) );
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

  head_set = NFMset_list1;
  status = NFMcheck_and_update_items_status1 (head_set, 1, NFM_SET_COPY);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
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
                      (head_set, quantity, NFM_MEM_COPY);
      if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
      {
        NFMfree_linked_list ();
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
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
  status = NFMcheck_and_update_items_status1 (head_set, quantity, NFM_MEM_COPY);
  if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
  {
    NFMfree_linked_list ();
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFMdebug ( (fname, "NFMcheck_item_status 0x%.8x\n", status) );
    return (status);
  }
  }

  status = NFMset_process_lock (user_id, NFM_I_PL_CP_SET);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    MEMclose (attr_list);
    MEMclose (data_list);
    return (status);
  }


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

long NFMcancel_set_copy (user_id, attr_list, data_list)
long      user_id;
MEMptr    attr_list, data_list;
{
  char  *fname="NFMcancel_set_copy";
  long     status;

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CP_SET))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFMdebug ( (fname, "NFMcheck_process_locks 0x%.8x\n",
                 NFM_E_BAD_COMMAND_ORDER) );
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CP_SET)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CP_SET);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      return (status);
    }
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}


long NFMcomplete_set_copy (user_id, storage_name,
                               node_name, user_name, passwd, path_name,
                               attr_list, data_list)
long      user_id;
char      *storage_name;
char      *node_name, *user_name, *passwd, *path_name;
MEMptr    attr_list, data_list;
{
  char   **column, **data, **data1;
  char   cat_name [100], mem_type [10];
  char   file_cat[50];
  char   *fname="NFMcomplete_set_copy";
  long   status;
  long   item_no;
  long   a, b, c, x, y, count;
  long   i, j, k, l;
  MEMptr list = NULL;

  _NFMdebug ( (fname, "ENTER: sto_name [%s] node [%s] user_name [%s] \n\
  \tpasswd [%s] path [%s]\n", storage_name, node_name, user_name, passwd, 
                            path_name) );

  /*
  if (time_it)
    mb_time1 = times (&mb_tms1);
  */

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CP_SET))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFMdebug ( (fname, "NFMcheck_process_locks 0x%.8x\n",
    NFM_E_BAD_COMMAND_ORDER) );
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CP_SET)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CP_SET);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      _NFMdebug ( (fname, "NFMreset_process_lock 0x%.8x\n", status) );
      return (status);
    }
  }

  if (strlen (storage_name))
  {
    status = _NFMsa_info (storage_name);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFMdebug ( (fname, "_NFMsa_info 0x%.8x\n", status) );
      return (status);     
    }

    passwd [0] = 0;
  }
  else if ((strlen (node_name)) || (strlen (passwd)) || 
           (strlen (path_name)))
  {
/* PUT IN PASSWORD SO THAT TEMP SA HAS PASSWD MRG 07/18/91 */

    status = _NFMadd_temp_sa (user_id, node_name, user_name, 
              path_name,passwd);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFMdebug ( (fname, "_NFMadd_temp_sa 0x%.8x\n", status));
      return (status);     
    }
  }
  else
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL); 
    _NFMdebug ( (fname, "_NFMadd_temp_sa 0x%.8x\n", status));
    return (NFM_E_BAD_ST_AREA);     
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  status = NFMget_move_files_list (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
    _NFMdebug ( (fname, "NFMget_move_files_list 0x%.8x\n", 
                 NFM_E_BAD_TEMPLATE) );
    return (NFM_E_BAD_TEMPLATE);
  }

  status = NFMget_co_set_files (user_id, attr_list, data_list, list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
    _NFMdebug ( (fname, "NFMget_co_set_files 0x%.8x\n", status) );
    return (status);
  }
  /*
  if (!time_it)
    MEMprint_buffers ("In NFMcomplete_set_checkout, list", list,
                     "/usr2/nfmadmin/buffers");
  */
    
  status = _NFMmv_files_in (user_id, STO_info.sano, passwd, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_in (user_id, STO_info.sano, passwd, &list);
    MEMclose (&list);
    NFMfree_linked_list ();
    return (status);               
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "This is a warning MEMclose 0x%.8x\n", status) );
  }

  /*NFMprint_linked_list1 ();*/
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
   
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
