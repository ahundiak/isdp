#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "PDUerror.h"
#include "NFMstruct.h"
/* added to accomodate NFM3.0 changes MaC */
#include "NFMitems.h"
#include "PDMproto.h"


extern struct child_info *PDMchildren_list;
extern struct child_info *PDMlast_child;
extern struct set_info1 *PDMassy_mem_list;
extern struct sto_info *PDMsto_list;
extern int PDMassy_members;

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];


long PDMXXget_set_members (cat_no, item_no_list, num_item, level)

long cat_no, *item_no_list, num_item, level;


{
  /***
    This function will get the members of the sets (based on the passed in 
    item_nos.) 

    Note: The caller does not have to make sure the passed in item_nos are sets
          This function is written to improve the CI/CO sets, so it may not
          make full sense to the reader if the reader is not familiar w/ the
          CI/CO sets logic.

       ***This function will build a linked list PDMchildren_list. The caller 
          of this function need to FREE the linked list when it does not
          need PDMchildren_list. To FREE the linked list, use 
          NFMfree_linked_list (....).

    CHANGE HISTORY:
      04/01/91 mfb creation.
  ***/

  char sql_str[1024], value[40];
  char *fname="PDMXXget_set_members";  
  char **data;
  int  or, x, index;
  long *item_no_list2=NULL, cur_cat;
  long num_item2;
  long status;
  long NFMprint_linked_list ();
  long NFMfree_linked_list ();
  struct child_info *new_child_entry=NULL, *cur_child=NULL; 
  MEMptr list=NULL;

  _PDMdebug (fname, "ENTER: cat_no = %d, try to get members for %d sets and level %d\n", 
               cat_no, num_item,  level );

   cur_cat = -1;
   num_item2 = -1;
  sprintf (sql_str, "%s %s %s %d ",
           "SELECT n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, ",
           "n_type FROM nfmsetcit ",
           "WHERE n_pcatalogno = ", 
            cat_no );

  or =0;
  for (x = 0; x < num_item; x++)
  {
    _PDMdebug  (fname, "item_no = %d \n", item_no_list[x]);
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


sprintf (s, "first query is :\n%s\n", sql_str);
PDMdebug (s);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug  (fname, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug  (fname, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  } 
if (PDMdebug_on) {
   MEMprint_buffer ("children buffer ", list, PDM_DEBUG_FILE);
     }

  
  /* allocate the space(s) for the DIRECT children. */
                 
  new_child_entry = (struct child_info *) calloc ( list->rows, list->rows *
                              sizeof (struct child_info));

  _PDMdebug  (fname, "Allocate spaces for the children\n") ; 
  if ((new_child_entry == (struct child_info *) NULL) && (list->rows > 0))
  {
    MEMclose (&list);
    PDMdebug ( "new_child_entry calloc failed\n" );
    return (NFM_E_MEM);
  }
                                      /* the 1st entry to the linked list */
  if (PDMchildren_list == (struct child_info *) NULL)
    PDMchildren_list = PDMlast_child = new_child_entry;
  else                          /* adding to the linked list */
  {
    PDMlast_child->next = new_child_entry;
    PDMlast_child = new_child_entry + (list->rows - 1);
  }

  data = (char **) list->data_ptr;

  PDMassy_members += list->rows;
  _PDMdebug  (fname, "%d members retrieved so far\n", PDMassy_members );
  sprintf (s, "%d members retrieved so far\n", PDMassy_members);
PDMdebug (s);

  new_child_entry->consecutive = list->rows;
  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    _PDMdebug  (fname, 
"%d -- n_citno %s n_pitemno %s n_ccatalogno %s n_citemno %s n_type %s\n",
               x, data[index],  data[index+2], 
                data[index+3], data[index+4], data[index+5] );
    sprintf  (s,
"%d -- n_citno %s n_pitemno %s n_ccatalogno %s n_citemno %s n_type %s\n",
               x, data[index],  data[index+2], 
                data[index+3], data[index+4], data[index+5]);
PDMdebug (s);
    (new_child_entry + x)->citno = atol (data[index] );
    (new_child_entry + x)->ccatalogno = atol( data[index+3] );
    (new_child_entry + x)->citemno = atol ( data[index+4] );
    (new_child_entry + x)->level = level; 

_PDMprint_childinfo_struct1 ("new_child_entry", new_child_entry);

    for (cur_child=PDMchildren_list; cur_child != (struct child_info *) NULL;
         cur_child=cur_child->next)
    {
      _PDMdebug (fname, "cur_child: citno [%d] cat [%d] item [%d] type [%s]\n",
                  cur_child->citno, cur_child->ccatalogno, cur_child->citemno,
                  cur_child->type );
        
      if (cur_child->citemno == atol(data[index+2]) )
      {
        _PDMdebug  (fname, "data[index+2] = %s\n", data[index+2]) ;
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
    item_no_list2 = (long *) calloc (list->rows, list->rows * sizeof (long));
    num_item2 = 0;
  }

  _PDMdebug  (fname, "call PDMXXget_set_members for the children\n");
  for (x = 0; x < list->rows; x++)
  {
    if ( (new_child_entry+x)->ccatalogno != cur_cat)
    {
      status = PDMXXget_set_members (cur_cat, item_no_list2, num_item2, level+1);
      if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
      {
        free (item_no_list2);
        _PDMdebug  (fname, "PDMXXget_set_memebers: 0x%.8x\n", status);
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
    status = PDMXXget_set_members (cur_cat, item_no_list2, num_item2, level+1);
    if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
    {
      free (item_no_list2);
      _PDMdebug  (fname, "PDMXXget_set_memebers: 0x%.8x\n", status);
      return (status);
    }
  }
  free (item_no_list2);
  _PDMdebug  (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}

long PDMXXsort_linked_list (sorting_list)
struct child_info *sorting_list;
{

  struct child_info *next_sort, *next_sort_end, *cur, *cur_end;
  char *fname="PDMXXsort_linked_list";
  long  cur_cat_no;
  long status;
  
  _PDMdebug  (fname, "ENTER: \n");
  cur_cat_no = sorting_list->ccatalogno;
  for (next_sort=next_sort_end=cur_end=(struct child_info *)NULL, 
       cur=sorting_list; cur != (struct child_info *) NULL; )
       
  {
    _PDMdebug  (fname, "cur_cat_no [%d], cur->cat_no [%d]\n", 
                 cur_cat_no, cur->ccatalogno );
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
    status = PDMXXsort_linked_list (next_sort);
    cur_end->next = next_sort;
  }
  
  _PDMdebug  (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);

}

long PDMXXfree_linked_list ()

{
  /***
    This function will free the PDMchildren_list.


    CHANGE HISTORY:

      04/02/91 mfb creation.

  ***/

  char *fname="PDMXXfree_linked_list";
  struct child_info *remove_child_entry;
  struct set_info1 *remove_set1_entry;

  _PDMdebug  (fname, "ENTER: \n" );

  PDMassy_members = 0;

  for ( ; PDMchildren_list != (struct child_info *) NULL; )
  {
    _PDMdebug  (fname, "JUST for development, need to del b4 delivery (C)\n\
                 consecutive = [%d]", PDMchildren_list->consecutive) ;
    remove_child_entry = PDMchildren_list;
    PDMchildren_list = PDMchildren_list->next;
    for (; (PDMchildren_list->consecutive == 0) && 
           (PDMchildren_list != (struct child_info *) NULL); )
    {
      PDMchildren_list = PDMchildren_list->next;
    }
    if (remove_child_entry->consecutive > 0) free (remove_child_entry);
  }

  for ( ; PDMassy_mem_list != (struct set_info1 *) NULL; )
  {
    _PDMdebug  (fname, "JUST for development, need to del b4 delivery (S1)\n\
                 consecutive [%d]", PDMassy_mem_list->consecutive) ;
    remove_set1_entry = PDMassy_mem_list;
    PDMassy_mem_list = PDMassy_mem_list->next;
    for (; (PDMassy_mem_list->consecutive == 0) && 
           (PDMassy_mem_list != (struct set_info1 *) NULL); )
    {
      PDMassy_mem_list = PDMassy_mem_list->next;
    }
    free (remove_set1_entry);
  }
/*
  for ( ; NFMcat_list != (struct attr_info1 *) NULL; )
  {
    _PDMdebug  (fname, "JUST for development, need to del b4 delivery (C1)\n" );
    remove_cat_entry = NFMcat_list;
    NFMcat_list = NFMcat_list->next;
    free (remove_cat_entry);
  }
  for ( ; PDMsto_list != (struct sto_info *) NULL; )
  {
    _PDMdebug  (fname, "JUST for development, need to del b4 delivery (STO)\n" );
    remove_sto_entry = PDMsto_list;
    PDMsto_list = PDMsto_list->next;
    free (remove_sto_entry);
  }
*/
  PDMchildren_list = (struct child_info *) NULL;
  PDMassy_mem_list = (struct set_info1 *) NULL;
  /*NFMcat_list = (struct attr_info1 *) NULL;*/
  /*PDMsto_list = (struct sto_info *) NULL; */
  _PDMdebug  (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}
    

 _PDMprint_childinfo_struct1 (struct_name, set)
char *struct_name;
struct child_info *set;
{
sprintf (s, "%s.cat_name = %s, %s.type = %s\n",
  struct_name, set->cat_name, 
  struct_name, set->type );
PDMdebug (s);

sprintf (s, 
  "%s.level = %d, %s.citno = %d, %s.ccatalogno = %d, \n\
   %s.fcat_no = %d, %s.citemno = %d, %s.consecutive = %d\n",
  struct_name, set->level,
  struct_name, set->citno,
  struct_name, set->ccatalogno,
  struct_name, set->fcat_no,
  struct_name, set->citemno,
  struct_name, set->consecutive );
PDMdebug (s);
}


int PDMget_assy_members (catno, partno, level,
                                       set_head, set_end, nch)
int	catno, partno;
int	level, *nch;
struct	NFMset_member **set_head, **set_end;
{
  char		*fn = "PDMget_assy_members";
  MEMptr	list = NULL;
  long		status;
  int		nchildren;
  struct	NFMmembers	*parent_struct;
  struct	NFMset_member *mem;
  struct	NFMset_member *head, *end;

    _PDMdebug ("ENTER", "%s\n", fn);
    _PDMdebug (fn, "catno = %d, partno = %d, level = %d, nchildren = %d\n",
    catno, partno, level, nchildren);


  /* load the struct with 1st level children_info */

  head = end = (struct NFMset_member *) calloc (1,
                               sizeof (struct NFMset_member));

  parent_struct = (struct NFMmembers *) calloc (1,
                                   sizeof (struct NFMmembers));
  if (head == (struct NFMset_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct NFMset_member));
    return (NFM_E_MALLOC);
  }


  head->level = 0; 
  head->flag = 1; 
  head->cat_no = catno; 
  head->item_no = partno; 
  strcpy (head->type, "P"); 
  /*strcpy (head->cat_name, catalog_name);*/


  nchildren = 1;

     _PDMprint_setmember ("head", head);

    _PDMdebug (fn, "Loading Parent structure ...\n");
       /*load parent_struct */
        parent_struct->cat_no = catno;
        parent_struct->item_no = partno;
        strcpy (parent_struct->type, "P");

    /* algorithm for level is:
       Info re. all the children for an assembly below the specified 
       level no will be retrieved. If the level specified is 3 and
       the assy has 5 levels, leaves of the last 2 level will be retrieved.
    */
        level = 0;

    _PDMdebug (fn, "Parent struct loaded ..\n \
                    before PDMretrieve_set_members;\n\
                    nchildren = %d\n", nchildren); 

        status = PDMexp_retrieve_set_members (parent_struct, 1, level,
                                       head, end, &nchildren);

          if ( (status != NFM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn,
              "PDMexp_retrieve_set_members failed status %d\n", status);
            return (status);
        }

    /* printing the linked list */

    _PDMdebug (fn, "list from PDMretrieve_set_members\n");
    for ( mem = head; 
              mem != (struct NFMset_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_setmember ("mem", mem);
      }

    if (nchildren > 1) {
        status = PDMsort_set_member_list (head);

          if (status != NFM_S_SUCCESS) {
            _PDMdebug (fn,
              "PDMsort_set_member_list failed status %d\n", status);
            return (status);
        }

    _PDMdebug (fn, "list after sorting\n");
    for ( mem = head; 
              mem != (struct NFMset_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_setmember ("mem", mem);
      }
  }

    *nch = nchildren;
    *set_head = head;
    *set_end = end;
       
   MEMclose (&list);
   return (PDM_S_SUCCESS);
}

int PDMsort_set_member_list (sorting_list)
struct NFMset_member *sorting_list;
{

  struct NFMset_member *next_sort, *next_sort_end, *cur, *cur_end;
  char *fname="PDMsort_set_member_list";
  long  cur_cat_no;
  long status;
  
  _PDMdebug  (fname, "ENTER: \n");
  cur_cat_no = sorting_list->cat_no;
  for (next_sort=next_sort_end=cur_end=(struct NFMset_member *)NULL, 
       cur=sorting_list; cur != (struct NFMset_member *) NULL; ) {
    _PDMdebug  (fname, "cur_cat_no [%d], cur->cat_no [%d]\n", 
                 cur_cat_no, cur->cat_no );
    if (cur->cat_no == cur_cat_no)
    {
      if (cur_end == (struct NFMset_member *) NULL)
        cur_end = cur;
      else
      {
        cur_end->next = cur;
        cur_end = cur;
      } 
      cur = cur->next;
      cur_end->next = (struct NFMset_member *) NULL;
    }
    else
    {
      if (next_sort_end == (struct NFMset_member *) NULL)
        next_sort = next_sort_end = cur;
      else
      {
        next_sort_end->next = cur;
        next_sort_end = cur;
      }
      cur = cur->next;
      next_sort_end->next = (struct NFMset_member *) NULL;
    }
  }
  if (next_sort != (struct NFMset_member *) NULL)
  {
    status = PDMsort_set_member_list (next_sort);
    cur_end->next = next_sort;
  }
  
  _PDMdebug  (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);

}


  
int PDMget_assy_members_for_cancel_part_co (catno, partno, level,
                                       set_head, set_end, nch, attach_list,
                                       child_bufr)
int	catno, partno;
int	level, *nch;
struct	NFMset_member **set_head, **set_end;
MEMptr	attach_list, child_bufr;
{
  char		*fn = "PDMget_assy_members_for_cancel_part_co";
  MEMptr	list = NULL;
  char		**data;
  int		x, index;
  long		status;
  long		count;
  int		nchildren;
  struct	NFMmembers	*parent_struct;
  struct	NFMset_member *cur_mem, *mem;
  struct	NFMset_member *head, *end;
  struct	NFMset_member *new_node;

    _PDMdebug ("ENTER", "%s\n", fn);
    _PDMdebug (fn, "catno = %d, partno = %d, level = %d\n",
    catno, partno, level);


  /* load the struct with 1st level children_info */

 x = -1;
 if (attach_list != NULL && x != -1) {

  _PDMdebug (fn, "attach_list has data\n");

  status = MEMbuild_array (attach_list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  } 

if (PDMdebug_on) {
   MEMprint_buffer ("attach buffer ", attach_list, PDM_DEBUG_FILE);
     }


  head = end = (struct NFMset_member *) calloc ((attach_list->rows + 2),
                               sizeof (struct NFMset_member));

  parent_struct = (struct NFMmembers *) calloc ((attach_list->rows + 2),
                                   sizeof (struct NFMmembers));
  if (head == (struct NFMset_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct NFMset_member));
    return (NFM_E_MALLOC);
  }

  head->level = 0; 
  head->flag = 1; 
  head->cat_no = catno; 
  head->item_no = partno; 
  strcpy (head->type, "P"); 
  /*strcpy (head->cat_name, catalog_name);*/


  nchildren = attach_list->rows + 1; /* one for the parent ... */

     _PDMprint_setmember ("head", head);

/**********************************************************************/
  count = 0;

  data = (char **) attach_list->data_ptr;
  for (x = 0, cur_mem = head; x < attach_list->rows; x++) {
    index = x * attach_list->columns;
/*
     cat_no = atol (data[index+0]);
     item_no = atol (data[index+1]);
*/
    _PDMdebug ( fn, "index %d, row %d: %s %s \n",
                                  index, x, data[index],  data[index+1]); 
/* check for removing duplicates is removed because Jamal sends
   me an unique list of first level children -MaC */
      new_node = (struct NFMset_member *) NULL; 
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL) {
        _PDMdebug (fn, "Allocate %d  failed\n", sizeof (struct NFMset_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = level + 1;
      new_node->flag = 4;
      new_node->item_no = atol (data[index+1]);
      new_node->cat_no = atol (data[index+0]);
      strcpy (new_node->type, "S");
      end->next = new_node;
      end = new_node;
      (parent_struct+count)->cat_no = new_node->cat_no;
      (parent_struct+count)->item_no = new_node->item_no;
      strncpy ((parent_struct+count)->type, new_node->type, 2);
      count ++;
   _PDMprint_setmember ("new_node", new_node);
  }

  status = MEMclose (&attach_list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn,"MEMclose (attach_list of members from nfmsetcit) 0x%.8x\n",
                status);
    return (status);
  }

  if (count) {
    status = PDMexp_retrieve_set_members (parent_struct, count, level+2, 
                                            head, end, &nchildren);
    if ( (status != NFM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
       _PDMdebug (fn,
              "PDMexp_retrieve_set_members failed status %d\n", status);
        return (status);
        }
      }
/**********************************************************************/
   }


 else if (child_bufr != NULL) {

  _PDMdebug (fn, "child bufr has data\n");

  status = MEMbuild_array (child_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  } 

if (PDMdebug_on) {
   MEMprint_buffer ("child buffer ", child_bufr, PDM_DEBUG_FILE);
     }


  head = end = (struct NFMset_member *) calloc ((child_bufr->rows + 2),
                               sizeof (struct NFMset_member));

  parent_struct = (struct NFMmembers *) calloc ((child_bufr->rows + 2),
                                   sizeof (struct NFMmembers));
  if (head == (struct NFMset_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct NFMset_member));
    return (NFM_E_MALLOC);
  }

  head->level = 0; 
  head->flag = 1; 
  head->cat_no = catno; 
  head->item_no = partno; 
  strcpy (head->type, "P"); 
  /*strcpy (head->cat_name, catalog_name);*/


 /* All the children may not be attached...*/
  /*nchildren = child_bufr->rows + 1;  one for the parent ... */
  nchildren = 1; /* one for the parent ... */

 _PDMprint_setmember ("head", head);

/* child bufr structure
0->p_childno~ 1->n_catalogname~ 2->n_itemname~ 3->n_itemrev~
4->p_attached~ 5->p_quantity~ 6->p_usageid~ 7->p_tagno~
8->p_alttagno~ 9->p_incbom~ 10->p_incstr~ 11->p_explode~
12->n_cofilename~ 13->p_history~ 14->n_catalogno~ 15->n_itemno~ 16->n_level~
*/

  count = 0;

  data = (char **) child_bufr->data_ptr;
  for (x = 0, cur_mem = head; x < child_bufr->rows; x++) {
    index = x * child_bufr->columns;
    _PDMdebug ( fn, "index %d, row %d: %s %s \n",
                                  index, x, data[index],  data[index+1]); 
     if (!strcmp (data[index + 4], "Y")) {
      new_node = (struct NFMset_member *) NULL; 
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL) {
        _PDMdebug (fn, "Allocate %d  failed\n", sizeof (struct NFMset_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = level + 1;
      new_node->flag = 4;
      new_node->item_no = atol (data[index+15]);
      new_node->cat_no = atol (data[index+14]);
      strcpy (new_node->type, "S");
nchildren++;
      end->next = new_node;
      end = new_node;
      (parent_struct+count)->cat_no = new_node->cat_no;
      (parent_struct+count)->item_no = new_node->item_no;
      strncpy ((parent_struct+count)->type, new_node->type, 2);
      count ++;
   _PDMprint_setmember ("new_node", new_node);
      }
  }

  if (count) {
    status = PDMexp_retrieve_set_members (parent_struct, count, level+2, 
                                            head, end, &nchildren);
    if ( (status != NFM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
       _PDMdebug (fn,
              "PDMexp_retrieve_set_members failed status %d\n", status);
        return (status);
        }
      }
   }



 else { /* attach_list and child_bufr is NULL */
  _PDMdebug (fn, "attach_list and child bufr are NULL\n");
  head = end = (struct NFMset_member *) calloc (1,
                               sizeof (struct NFMset_member));

  parent_struct = (struct NFMmembers *) calloc (1,
                                   sizeof (struct NFMmembers));
  if (head == (struct NFMset_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct NFMset_member));
    return (NFM_E_MALLOC);
  }


  head->level = 0; 
  head->flag = 1; 
  head->cat_no = catno; 
  head->item_no = partno; 
  strcpy (head->type, "P"); 
  /*strcpy (head->cat_name, catalog_name);*/


  nchildren = 1;

     _PDMprint_setmember ("head", head);

    _PDMdebug (fn, "Loading Parent structure ...\n");
       /*load parent_struct */
        parent_struct->cat_no = catno;
        parent_struct->item_no = partno;
        strcpy (parent_struct->type, "P");

    /* algorithm for level is:
       Info re. all the children for an assembly below the specified 
       level no will be retrieved. If the level specified is 3 and
       the assy has 5 levels, leaves of the last 2 level will be retrieved.
    */
        level = 0;

    _PDMdebug (fn, "Parent struct loaded ..\n \
                    before PDMretrieve_set_members;\n\
                    nchildren = %d\n", nchildren); 

        status = PDMexp_retrieve_set_members (parent_struct, 1, level,
                                       head, end, &nchildren);

          if ( (status != NFM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn,
              "PDMexp_retrieve_set_members failed status %d\n", status);
            return (status);
        }
     }

        free (parent_struct);
    /* printing the linked list */

    _PDMdebug (fn, "list from PDMretrieve_set_members\n");
    for ( mem = head; 
              mem != (struct NFMset_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_setmember ("mem", mem);
      }

    if (nchildren > 1) {
        status = PDMsort_set_member_list (head);

          if (status != NFM_S_SUCCESS) {
            _PDMdebug (fn,
              "PDMsort_set_member_list failed status %d\n", status);
            return (status);
        }

    _PDMdebug (fn, "list after sorting\n");
    for ( mem = head; 
              mem != (struct NFMset_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_setmember ("mem", mem);
      }
  }

    *nch = nchildren;
    *set_head = head;
    *set_end = end;
       
   MEMclose (&list);
   return (PDM_S_SUCCESS);
}

