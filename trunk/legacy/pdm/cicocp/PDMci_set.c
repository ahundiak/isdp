#include <stdio.h>
#include "NFMlocks.h"
#include "NFMfile.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "PDMproto.h"

/* #include "NFMmfb.h" */
/* #include "NFMtime.h" */
/* #define time_it 0 */
                                               
extern struct child_info *PDMchildren_list;/* list of the set's children */
extern struct child_info *PDMlast_child;
struct set_info1  *PDMassy_mem_list=NULL;
struct set_info1  *PDMassy_last_mem=NULL;

struct attr_info1  *PDMcat_list=NULL;
struct attr_info1  *PDMend_cat_list=NULL;

extern int PDMassy_members;
/* extern struct _NFMdebug_st _NFMdebug_st; */
extern struct sto_area_info STO_info;
extern char NFMuser[];

extern PDMpart_ptr PDMpart;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];

long PDMXprepare_set_checkin (cat_name, item_name, item_rev, 
                             level, data_list)
char   *cat_name, *item_name, *item_rev;
long	level;
MEMptr *data_list;

{
  char *fname="PDMXprepare_set_checkin";
  char cur_cat_name[50];
  long cur_cat_no, cur_fcat_no;
  int quantity; 
  long cat_no, fcat_no;
  long item_no, *item_no_list, item_num;
  long status;
  struct set_info1 *head_new_set_entry=NULL, *end_new_set_entry=NULL;
  struct set_info1 *head_set, *cur_set;
  struct set_info1 *new_set_entry;
  struct child_info *head, *cur_child, *to_be_sort;

/* ANSI */
  item_no_list = (long *) NULL;
  level = 0;
  cur_cat_no = 0;
  cur_fcat_no = 0;
  cur_cat_name[0] = '\0';
  level = 0;

  _PDMdebug (fname, "ENTER:, cat_name = %s, item = %s.%s\n", cat_name, 
               item_name, item_rev );

  cat_no = PDMpart.n_catalogno;
  fcat_no = PDMpart.f_catalogno;

  /* make sure the application/user is allowed to execute the ci set */

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMstop_transaction 0x%.8x\n", status );
    return (status);
  }

  /* retrieve the data definition and values of the set */

  status = PDMXget_item_data_def_and_values1 (cat_no, 
                                              fcat_no, 
                                              cat_name,
                                              item_name, 
                                              item_rev, 
                                              &new_set_entry);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_item_data_def (tbl %d, %d, item %s.%s) 0x%.8x\n",
                 cat_no, fcat_no, item_name, item_rev, NFM_E_BAD_ATTR );
    ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
    return (NFM_E_BAD_ATTR);
  }

  /* NFMprint_an_entry_of_linked_list (new_set_entry); */
if (PDMdebug_on)
_PDMprint_setinfo1_struct ("new_set_entry", new_set_entry);

  PDMassy_mem_list = PDMassy_last_mem = new_set_entry; /* 1st entry */
  PDMassy_mem_list->consecutive = 1;


  /* retrieve the set's children and store the information in */
  /* PDMchildren_list */
 
  PDMchildren_list = PDMlast_child = (struct child_info *) calloc ( 1, 
                                           sizeof (struct child_info));
  PDMchildren_list->ccatalogno = cat_no;
  PDMchildren_list->citemno = atol (PDMassy_mem_list->itemno_v);
  PDMchildren_list->fcat_no = fcat_no;
  PDMchildren_list->consecutive = 1;
  PDMchildren_list->level = 0;
  strcpy (PDMchildren_list->cat_name, cat_name);
  strcpy (PDMchildren_list->type, "P");

  /* NFMprint_linked_list (); */
  item_no = atol (PDMassy_mem_list->itemno_v);
  status = PDMXXget_set_members (cat_no, &item_no, 1, 1); 
           
  if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
    NFMfree_linked_list();
    _PDMdebug (fname, "NFMget_set_members cat_no = %d, 0x%.8x\n",
                 cat_no,  status );
    ERRload_struct (NFM, NFM_E_GET_SET_MEMBERS, "", NULL); /* FINISH */
    return (NFM_E_GET_SET_MEMBERS);
  }

  to_be_sort = PDMchildren_list->next;
  if (to_be_sort != (struct child_info *) NULL)
  {
    status = PDMXXsort_linked_list (to_be_sort);
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list();
      _PDMdebug (fname, "NFMsort_linked_list 0x%.8x\n ", status );
      ERRload_struct (NFM, NFM_E_DATA, "", NULL); /* FINISH */
      return (NFM_E_DATA);
    }
  }
    /*NFMprint_linked_list1 ();*/

/*  _PDMdebug (fname, "This set has %d members\n", PDMassy_members );*/
  /* get the catalogname of the members and f_<catalog> number of the members */

  if (PDMchildren_list->next != (struct child_info *) NULL)
  {
    status = PDMXget_children_info ();
    if (status != NFM_S_SUCCESS)
    {
      NFMfree_linked_list ();
      ERRload_struct ( NFM, NFM_E_BAD_ATTR, "", NULL);
      _PDMdebug (fname, "NFMget_children_info 0x%.8x\n", NFM_E_BAD_ATTR);
      return (NFM_E_BAD_ATTR);
    }
  }

/*  NFMprint_linked_list1 (); */

  /* retrieve the values (item_lock, coout etc..) of the members, since  */
  /* the 1st entry in PDMchildren_list is set itself, skip it */

  if (PDMassy_members)
    item_no_list = (long *) calloc (PDMassy_members, 
                            PDMassy_members * sizeof (long));
  item_num = 0;

  cur_cat_name[0] = '\0';
  head = PDMchildren_list->next;
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
      status = PDMXget_items_data_def_values1 (
               cur_cat_no, cur_fcat_no, cur_cat_name, 
               item_no_list, item_num,
               &head_new_set_entry, &end_new_set_entry);
      if (status != NFM_S_SUCCESS)
      {
        NFMfree_linked_list();
        ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
        _PDMdebug (fname, "NFMget_items_data_def_values 0x%.8x\n", status );
        return (NFM_E_BAD_ATTR);
      }
      _PDMdebug (fname, "PDMassy_mem_list = %ld, PDMassy_last_mem = %ld\n",
                       PDMassy_mem_list, PDMassy_last_mem );
      
      PDMassy_last_mem->next = head_new_set_entry;
      PDMassy_last_mem = end_new_set_entry;
      _PDMdebug (fname, "PDMassy_mem_list = %ld, PDMassy_last_mem = %ld\n",
                       PDMassy_mem_list, PDMassy_last_mem );
         
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
  status = PDMXget_items_data_def_values1 (cur_cat_no, cur_fcat_no, 
           cur_cat_name, item_no_list, item_num,
           &head_new_set_entry, &end_new_set_entry);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list();
    ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
    _PDMdebug (fname, "NFMget_items_data_def_values 0x%.8x\n", status );
    return (NFM_E_BAD_ATTR);
  }
  PDMassy_last_mem->next = head_new_set_entry;
  PDMassy_last_mem = end_new_set_entry;
  }


  for (cur_child = PDMchildren_list;
       cur_child != (struct child_info *) NULL;
       cur_child = cur_child->next)
  {
    for (cur_set = PDMassy_mem_list; cur_set != (struct set_info1 *) NULL;
         cur_set = cur_set->next)
    {
      _PDMdebug (fname, "cur_child->citemno [%d], cur_set->itemno_v[%s]\n",
                       cur_child->citemno, cur_set->itemno_v );
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

status = PDMmake_data_buffer (data_list);

    NFMprint_linked_list1 ();  

/*
  status = NFMci_get_data_def (cat_no, fcat_no, , data_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _PDMdebug (fname, "NFMget_data_def: 0x%.8x \n", status );
    return (status);
  }
*/

  if (PDMdebug_on)
  { 
  MEMprint_buffers ("In NFMprepare_set_checkin, data_list", *data_list,
                     PDM_DEBUG_FILE);
  }
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _PDMdebug (fname, "SQLstmt: 0x%.8x\n", status );
    return (status);
  }

  head_set = cur_set = PDMassy_mem_list;
  cur_cat_no = head_set->table_no;
  quantity = 0;

  for (; cur_set != (struct set_info1 *) NULL; cur_set = cur_set->next)
  {
    if ( cur_set->table_no != cur_cat_no)
    {
      status = PDMXget_set_ci_files_info1 (head_set, quantity, *data_list);
      if (status != NFM_S_SUCCESS)
      {
        NFMfree_linked_list ();
        ERRload_struct (NFM, status, "", NULL);
        _PDMdebug (fname, "NFMget_set_ci_files_info: 0x%.8x\n", status );
        return (status);
      }
      head_set = cur_set;
      cur_cat_no = head_set->table_no;
      quantity = 1;
    }
    else
      quantity++;
  }

  status = PDMXget_set_ci_files_info1 (head_set, quantity, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    ERRload_struct (NFM, status, "", NULL);
    _PDMdebug (fname, "NFMget_set_ci_files_info: 0x%.8x\n", status );
    return (status);
  }

  head_set = PDMassy_mem_list;
  status = PDMXcheck_and_update_items_status1 (cat_name, head_set, NFM_SET_IN);
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _PDMdebug (fname, "NFMcheck_item_status 0x%.8x\n", status );
    return (status);
  }
  head_set = cur_set = PDMassy_mem_list->next;
  if (head_set != (struct set_info1 *) NULL)
    cur_cat_no = head_set->table_no;
  quantity = 0;

  for (; cur_set != (struct set_info1 *) NULL; cur_set = cur_set->next)
  {
    if (cur_set->table_no != cur_cat_no)
    {
      status = PDMXcheck_and_update_items_status1 
                      (cat_name, head_set, NFM_MEM_IN);
      if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
      {
        NFMfree_linked_list ();
        _PDMdebug (fname, "NFMcheck_item_status 0x%.8x\n", status );
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
  status = PDMXcheck_and_update_items_status1 (cat_name, head_set, NFM_MEM_IN);
  if ( (status != NFM_S_SUCCESS) && (status != NFM_E_NOT_PRIMARY_MEMBERS) )
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    _PDMdebug (fname, "NFMcheck_item_status 0x%.8x\n", status );
    return (status);
  }
  }
  
  status = _PDMchk_in_user (*data_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMrollback_set ();
    NFMfree_linked_list ();
    ERRload_struct (NFM, NFM_E_NOT_CO_USER, "", NULL);
    _PDMdebug (fname, "_NFMchk_in_user 0x%.8x\n", NFM_E_NOT_CO_USER );
    return (NFM_E_NOT_CO_USER);
  }


  if(PDMdebug_on)
  MEMprint_buffers ("In PDMXprepare_set_checkin, data_list", *data_list,
                     PDM_DEBUG_FILE);
  
  _PDMdebug (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}


long PDMXXcancel_set_checkin (user_id, attr_list, data_list)
long      user_id;
MEMptr    attr_list, data_list;
{
  long  status;
  char  *fname="NFMcancel_set_checkin";

  _PDMdebug (fname, "ENTER:\n");

 /* ANSI */
  attr_list = NULL;
  data_list = NULL;

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CI_SET))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _PDMdebug (fname, "NFMcheck_process_locks 0x%.8x\n",
                 NFM_E_BAD_COMMAND_ORDER );       
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CI_SET)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CI_SET);
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_set ();
      NFMfree_linked_list ();
      _PDMdebug (fname, "NFMreset_process_lock 0x%.8x\n", status );
      return (status);
    }
  }

  status = _NFMrollback_set ();
  if (status != NFM_S_SUCCESS)
  {
    NFMfree_linked_list ();
    _PDMdebug (fname, "_NFMrollback_set 0x%.8x\n", status );
    return (status);
  }

  status = NFMfree_linked_list ();
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMfree_linked_list 0x%.8x\n", status );
    return (status);
  }

  _PDMdebug (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}

