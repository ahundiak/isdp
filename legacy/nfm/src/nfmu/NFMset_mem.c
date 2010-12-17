#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"

extern struct child_info *NFMchildren_list;
extern struct child_info *NFMend_children_list;
extern struct set_info1 *NFMset_list1;
extern struct sto_info *NFMsto_list;
extern struct attr_info1 *NFMcat_list;
int NFMset_members=0;

long NFMget_set_members (cat_no, item_no_list, num_item, level)

long cat_no, *item_no_list, num_item, level;

{
  /***
    This function will get the members of the sets (based on the passed in 
    item_nos.) 

    Note: The caller does not have to make sure the passed in item_nos are sets
          This function is written to improve the CI/CO sets, so it may not
          make full sense to the reader if the reader is not familiar w/ the
          CI/CO sets logic.

       ***This function will build a linked list NFMchildren_list. The caller 
          of this function need to FREE the linked list when it does not
          need NFMchildren_list. To FREE the linked list, use 
          NFMfree_linked_list (....).

  ***/

  char *sql_str, value[40];
  char *fname="NFMget_set_members";  
  char **data;
  int  or, i, x, index;
  long *item_no_list2=NULL, cur_cat;
  long num_item2;
  long status;
  long NFMprint_linked_list ();
  long NFMfree_linked_list ();
  struct child_info *new_child_entry=NULL, *cur_child=NULL; 
  MEMptr list=NULL;

  _NFMdebug ((fname, "ENTER: cat_no = %d, try to get members for %d sets level %d\n", 
               cat_no, num_item, level) );

  sql_str = (char *) malloc ((num_item * 50 + 300) * sizeof (char));
  if (sql_str == (char *) NULL)
  {
    _NFMdebug ((fname, "Malloc %d failed\n",
                (num_item*50+300)*sizeof(char)));
    return (NFM_E_MALLOC);
  }

  sprintf (sql_str, "%s %s %s %d ",
           "SELECT n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, ",
           "n_type FROM nfmsetcit ",
           "WHERE n_pcatalogno = ", cat_no);

  or =0;
  for (x = 0; x < num_item; x++)
  {
    _NFMdebug ( (fname, "item_no = %d \n", item_no_list[x]));
    if (or)
      strcat (sql_str, " OR n_pitemno = ");
    else
    {
      strcat (sql_str, " AND (n_pitemno = ");
      or = 1;
    }
    sprintf (value, "%d", item_no_list[x]);
    strcat (sql_str, value);
  } 
  
  strcat (sql_str, ") ORDER BY n_ccatalogno");

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    free (sql_str);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    free (sql_str);
    _NFMdebug ( (fname, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) );
    return (NFM_E_MEM);
  } 

  
  /* allocate the space(s) for the DIRECT children. */
                 
  new_child_entry = (struct child_info *) calloc ( list->rows, 
                              sizeof (struct child_info));

  /*_NFMdebug ( (fname, "Allocate spaces for the children\n") ); */
  if ((new_child_entry == (struct child_info *) NULL) && (list->rows > 0))
  {
    MEMclose (&list);
    free (sql_str);
    _NFMdebug ( (fname, "new_child_entry calloc failed\n") );
    return (NFM_E_MEM);
  }
                                      /* the 1st entry to the linked list */
  if (NFMchildren_list == (struct child_info *) NULL)
    NFMchildren_list = NFMend_children_list = new_child_entry;
  else                          /* adding to the linked list */
  {
    NFMend_children_list->next = new_child_entry;
    NFMend_children_list = new_child_entry + (list->rows - 1);
  }

  data = (char **) list->data_ptr;

  NFMset_members += list->rows;
  /*_NFMdebug ( (fname, "%d members retrieved so far\n", NFMset_members) ); */

  new_child_entry->consecutive = list->rows;
  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    _NFMdebug ( (fname, "%d -- %s %s %s %s %s\n",
               x, data[index],  data[index+2], 
                data[index+3], data[index+4], data[index+5]) );
    (new_child_entry + x)->citno = atol (data[index] );
    (new_child_entry + x)->ccatalogno = atol( data[index+3] );
    (new_child_entry + x)->citemno = atol ( data[index+4] );
    (new_child_entry + x)->level = level; 


    for (cur_child=NFMchildren_list; cur_child != (struct child_info *) NULL;
         cur_child=cur_child->next)
    {
      _NFMdebug ((fname, "cur_child: citno [%d] cat [%d] item [%d] type [%s]\n",
                  cur_child->citno, cur_child->ccatalogno, cur_child->citemno,
                  cur_child->type) );
        
      if (cur_child->citemno == atol(data[index+2]) )
      {
        _NFMdebug ( (fname, "data[index+2] = %s\n", data[index+2]) );
        if (strcmp (cur_child->type, "S") )
          strcpy ( (new_child_entry + x)->type, data[index+5] );
        else
          strcpy ( (new_child_entry +x)->type, cur_child->type);
        break;
      }
    }
    if (x < list->rows - 1)
      (new_child_entry + x)->next = (new_child_entry + (x + 1));
  }

  if (list->rows)
  {
    cur_cat = new_child_entry->ccatalogno;
    /* allocate the possible maximum size */
    item_no_list2 = (long *) calloc (list->rows, sizeof (long));
    if (item_no_list2 == (long *) NULL)
    {
      _NFMdebug ((fname, "Malloc %d failed\n",
                  (list->rows*sizeof(long))));
      return (NFM_E_MALLOC);
    }
    num_item2 = 0;
  }

  /*_NFMdebug ( (fname, "call NFMget_set_members for the children\n"));*/
  for (x = 0; x < list->rows; x++)
  {
    if ( (new_child_entry+x)->ccatalogno != cur_cat)
    {
      status = NFMget_set_members (cur_cat, item_no_list2, num_item2, level+1);
      if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
      {
        free (item_no_list2);
        free (sql_str);
        _NFMdebug ( (fname, "NFMget_set_memebers: 0x%.8x\n", status));
        return (status);
      }
      cur_cat = (new_child_entry+x)->ccatalogno;
      num_item2 = 0;
      *(item_no_list2+num_item2) = (new_child_entry+x)->citemno;
      ++num_item2;
    }
    else
    {
      *(item_no_list2+num_item2) = (new_child_entry+x)->citemno;
      ++num_item2;
    }
  }

  if (num_item2)
  {  
    status = NFMget_set_members (cur_cat, item_no_list2, num_item2, level+1);
    if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
    {
      free (item_no_list2);
      free (sql_str);
      _NFMdebug ( (fname, "NFMget_set_memebers: 0x%.8x\n", status));
      return (status);
    }
  }
  free (item_no_list2);
  free (sql_str);
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}

long NFMsort_linked_list (sorting_list)
struct child_info *sorting_list;
{

  struct child_info *next_sort, *next_sort_end, *cur, *cur_end;
  char *fname="NFMsort_linked_list";
  long  cur_cat_no;
  long status;
  
  _NFMdebug ( (fname, "ENTER: \n"));
  cur_cat_no = sorting_list->ccatalogno;
  for (next_sort=next_sort_end=cur_end=(struct child_info *)NULL, 
       cur=sorting_list; cur != (struct child_info *) NULL; )
       
  {
    _NFMdebug ( (fname, "cur_cat_no [%d], cur->cat_no [%d]\n", 
                 cur_cat_no, cur->ccatalogno) );
    if (cur->ccatalogno == cur_cat_no)
    {
      if (cur_end == (struct child_info *) NULL)
        cur_end = cur;
      else
      {
        cur_end->next = cur;
        cur_end = cur;
      } 
      cur = cur->next;
      cur_end->next = (struct child_info *) NULL;
    }
    else
    {
      if (next_sort_end == (struct child_info *) NULL)
        next_sort = next_sort_end = cur;
      else
      {
        next_sort_end->next = cur;
        next_sort_end = cur;
      }
      cur = cur->next;
      next_sort_end->next = (struct child_info *) NULL;
    }
  }
  if (next_sort != (struct child_info *) NULL)
  {
    status = NFMsort_linked_list (next_sort);
    cur_end->next = next_sort;
  }
  
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);

}

long NFMfree_linked_list ()

{
  /***
    This function will free the NFMchildren_list.




  ***/

  char *fname="NFMfree_linked_list";
  int x;
  struct child_info *remove_child_entry;
  struct sto_info *remove_sto_entry;
  struct set_info1 *remove_set1_entry;
  struct attr_info1 *remove_cat_entry;

  _NFMdebug ( (fname, "ENTER: \n") );

  NFMset_members = 0;

  for ( ; NFMchildren_list != (struct child_info *) NULL; )
  {
    _NFMdebug ( (fname, "JUST for development, need to del b4 delivery (C)\n\
                 consecutive = [%d]", NFMchildren_list->consecutive) );
    remove_child_entry = NFMchildren_list;
    NFMchildren_list = NFMchildren_list->next;
    for (; (NFMchildren_list->consecutive == 0) && 
           (NFMchildren_list != (struct child_info *) NULL); )
    {
      NFMchildren_list = NFMchildren_list->next;
    }
    if (remove_child_entry->consecutive > 0) free (remove_child_entry);
  }

  for ( ; NFMset_list1 != (struct set_info1 *) NULL; )
  {
    _NFMdebug ( (fname, "JUST for development, need to del b4 delivery (S1)\n\
                 consecutive [%d]", NFMset_list1->consecutive) );
    remove_set1_entry = NFMset_list1;
    NFMset_list1 = NFMset_list1->next;
    for (; (NFMset_list1->consecutive == 0) && 
           (NFMset_list1 != (struct set_info1 *) NULL); )
    {
      NFMset_list1 = NFMset_list1->next;
    }
    free (remove_set1_entry);
  }
  for ( ; NFMcat_list != (struct attr_info1 *) NULL; )
  {
    _NFMdebug ( (fname, "JUST for development, need to del b4 delivery (C1)\n") );
    remove_cat_entry = NFMcat_list;
    NFMcat_list = NFMcat_list->next;
    free (remove_cat_entry);
  }
  for ( ; NFMsto_list != (struct sto_info *) NULL; )
  {
    _NFMdebug ( (fname, "JUST for development, need to del b4 delivery (STO)\n") );
    remove_sto_entry = NFMsto_list;
    NFMsto_list = NFMsto_list->next;
    free (remove_sto_entry);
  }
  NFMchildren_list = (struct child_info *) NULL;
  NFMset_list1 = (struct set_info1 *) NULL;
  NFMcat_list = (struct attr_info1 *) NULL;
  NFMsto_list = (struct sto_info *) NULL;
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
    

/*
long NFMprint_linked_list ()

{
  char *fname="NFMprint_linked_list";
  struct set_info *head_set;
  struct child_info *head_child;   
  struct sto_info *head_sto;
  long NFMprint_an_entry_of_linked_list ();

  _NFMdebug ( (fname, "ENTER:\n"));

  _NFMdebug ( (fname, "NFMchildren_list\n"));
  for (head_child=NFMchildren_list; head_child != (struct child_info *) NULL;
       head_child=head_child->next)
    _NFMdebug 
   ((fname, "cat_no [%d],cat_name[%s],fcat_no [%d],item_no[%d],type [%s]\n",
            head_child->ccatalogno, head_child->cat_name,
            head_child->fcat_no, head_child->citemno, 
            head_child->type) );

   
  _NFMdebug ( (fname, "NFMset_list\n"));
  for (head_set=NFMset_list; head_set != (struct set_info *) NULL;
       head_set=head_set->next)
    NFMprint_an_entry_of_linked_list (head_set);
                 
  for (head_sto=NFMsto_list; head_sto != (struct sto_info *) NULL;
       head_sto=head_sto->next)
    _NFMdebug ( (fname, "sano [%d] node [%s] user [%s]\n\
    \tpaswd [%s] path [%s]\n\
    \tdev [%s] mach [%s]\n\
    \topsys [%s] tcpip [%s] xns [%s] decnet [%s]\n",
    head_sto->info.sano,head_sto->info.nodename,head_sto->info.username,
    head_sto->info.passwd,head_sto->info.pathname,head_sto->info.devicetype,
    head_sto->info.machid,head_sto->info.opsys,head_sto->info.tcpip,
    head_sto->info.xns,head_sto->info.decnet));
  
  _NFMdebug ( (fname, "EXIT:\n"));
  return (NFM_S_SUCCESS);
    
}
*/

/*
long NFMprint_an_entry_of_linked_list (set)
struct set_info *set;
{

  char *fname="NFMprint_an_entry_of_linked_list";

  _NFMdebug ( (fname, "ENTER:\n"));
  _NFMdebug ( (fname, "Description of the Set/Item:\nData Def: %s,%s,%s,%s,%s\n\
  \t%s,%s,%s,%s\n\t%s,%s\nValues:n_itemno [%s],n_itemname [%s],n_itemrev [%s]\n\
  \tn_archivestate = [%s],n_status [%s],n_itemlock [%s],n_versionlimit [%s]\n\
  \tn_fileversion = [%s]\n\ttbl_name [%s], tbl_no = %d, ftbl_no = %d,\n\
  \tcitno = [%d], type = [%s]\n",
  set->cat_item.n_itemno.attr_name, set->cat_item.n_itemname.attr_name,
  set->cat_item.n_itemrev.attr_name, set->cat_item.n_archivestate.attr_name,
  set->cat_item.n_coout.attr_name, set->cat_item.n_itemlock.attr_name,
  set->cat_item.n_versionlimit.attr_name, 
  set->fcat_item.n_itemnum.attr_name, set->fcat_item.n_fileclass.attr_name,
  set->fcat_item.n_fileversion.attr_name, set->fcat_item.n_cifilename.attr_name,

  set->cat_item.n_itemno.data_value, set->cat_item.n_itemname.data_value,
  set->cat_item.n_itemrev.data_value, set->cat_item.n_archivestate.data_value,
  set->cat_item.n_coout.data_value, set->cat_item.n_itemlock.data_value,
  set->cat_item.n_versionlimit.data_value, 
  set->fcat_item.n_fileversion.data_value, 

  set->table_name, set->table_no, set->ftable_no, set->citno, set->type) );

  _NFMdebug ( (fname, "EXIT:\n"));
  return (NFM_S_SUCCESS);
}
*/
