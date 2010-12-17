#include "stdio.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "PDMproto.h"
#include "PDUerror.h"
#include "PDUnode.h"

/* #include "NFMmfb.h" */

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
struct PDUcat_node *PDMparam_cat_list;
extern PDMpart_ptr PDMpart;
extern char glob_var[100];
static long     status;


long PDMretrieve_set_members (members_list, count, level, set_head, set_end,
                              num_members)

struct NFMmembers *members_list;
long  count, level;
struct NFMset_member *set_head, *set_end;
long *num_members;

{
  /***
    This recursive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 

    Note: The caller does not have to make sure the passed in item_nos are sets


    CHANGE HISTORY:
      09/01/91 mfb creation.
  ***/

  char *fn="PDMretrieve_set_members";
  char sql_str[5120]; /* reconsider this one later */
  char value[50];
  char **data;
  int x, or, index;
  long count2;
  MEMptr list=NULL;
  struct NFMmembers *members_list2;
  struct NFMset_member *cat_head, *new_node;

  _PDMdebug (fn, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 
               count, level, *num_members);

  new_node = (struct NFMset_member *) NULL; 
  cat_head = (struct NFMset_member *) NULL; 
  members_list2 = (struct NFMmembers *) NULL; 

  sprintf (sql_str, "%s %s",
           "SELECT n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, ",
           "n_type FROM nfmsetcit where ");

  for (x = or = 0; x < count; x++)
  {
    _PDMdebug ( fn, "retrieve member for cat [%d], item [%d]\n",
                 (members_list+x)->cat_no, (members_list+x)->item_no); 
    if (or)
    {
      strcat (sql_str, "or ((n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
    }
    else
    {
      strcat (sql_str, "((n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
      or = 1;
    }
  } 
  
  strcat (sql_str, "ORDER BY n_ccatalogno");

  _PDMdebug (fn, "exec qry: %s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
  }

        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows,
                     list->rows * sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL)
  {
    _PDMdebug (fn, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers));
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++)
  {
    index = x * list->columns;
    _PDMdebug ( fn, "row %d: %s %s %s %s %s %s\n",
               x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5] );
/*
    if (cat_head->cat_no != atol (data[index+3]))
    {
      for (cat_head = set_head; cat_head != (struct NFMset_member *)NULL;)
        if (cat_head->cat_no == atol(data [index+3]))
          break;
        else
          cat_head = cat_head->next;
    }
    if (cat_head == NULL)
    {
*/
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = level;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
/*
      if (strcmp(data[index+5], "S"))
      {
        for (y = 0; y < count; y++)
        {
          if (atol(data[index+1]) == (members_list+y)->cat_no &&
              atol(data[index+2]) == (members_list+y)->item_no)
          {
            if (! strcmp((members_list+y)->type, "S"))  
            {
              strcpy (new_node->type, "S");
              break;
            }
            else
            {
              strcpy (new_node->type, data[index+5]);
              break;
            }
          }
        }
      }
      else
*/
        strcpy (new_node->type, data[index+5]);
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strcpy ((members_list+count2)->type, new_node->type);
      count2 ++;
/*
    }
    else
    {
      for (found=0, cat_current = cat_last = cat_head; 
           cat_current != (struct NFMset_member *) NULL &&
           cat_current->cat_no == atol(data[index+3]) && !found; )
      {
        if (cat_current->item_no == atol(data[index+4]) )
        {
          found = 1;
          break;
        }
        cat_last = cat_current;
        cat_current = cat_current->next;
      }
      if (! found)
      {
        new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
        if (new_node == (struct NFMset_member *) NULL)
        {
          _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member));
          ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                          sizeof (struct NFMset_member));
          return (NFM_E_MALLOC);
        }
        new_node->level = level;
        new_node->citno = atol(data[index]);
        new_node->item_no = atol (data[index+4]);
        new_node->cat_no = atol (data[index+3]);
        if (strcmp(data[index+5], "S"))
        {
          for (y = 0; y < count; y++)
          {
            if (atol(data[index+1]) == (members_list+y)->cat_no &&
                atol(data[index+2]) == (members_list+y)->item_no)
            {
              if (! strcmp((members_list+y)->type, "S"))  
              {
                strcpy (new_node->type, "S");
                break;
              }
              else
              {
                strcpy (new_node->type, data[index+5]);
                break;
              }
            }
          }
        }
        else
          strcpy (new_node->type, data[index+5]);
        new_node->next = cat_current;
        cat_last->next = new_node;
        if (cat_current == (struct NFMset_member *) NULL)
        {
          set_end = new_node;
        }
        (*num_members) ++; 
        (members_list2+count2)->cat_no = new_node->cat_no;
        (members_list2+count2)->item_no = new_node->item_no;
        strcpy ((members_list+count2)->type, new_node->type);
        count2 ++;
      }
    }
*/
   _PDMprint_setmember ("new_node", new_node);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fn,"MEMclose (list of members from nfmsetcit) 0x%.8x\n",
                status);
    return (status);
  }

  if (count2)
  {
    status = PDMretrieve_set_members (members_list2, count2, level+1, set_head,
             set_end, num_members);
    if (status != NFM_S_SUCCESS)
    {
      free (members_list2);
      _PDMdebug (fn,"PDMretrieve_set_members 0x%.8x\n", status);
      return (status);
    }
  }

  free (members_list2);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}

long XPDMget_catalog_names (set_head, num_members)
struct NFMset_member *set_head;
long num_members;

{
  char *fn="NFMget_catalog_names";
  char sql_str[4096]; /* COME BACK LATER */
  char **data = NULL;
  char dumb_str[2];
  int x, y, index, rest, or;
  long cur_cat_no;
  long dumb_value;
  MEMptr list=NULL;
  struct NFMset_member *cur_set, *begin_process;
  struct NFMset_member *cur_cat;

  cur_set = (struct NFMset_member *) NULL; 
  begin_process = (struct NFMset_member *) NULL; 
  cur_cat = (struct NFMset_member *) NULL; 
  index = -1;

  _PDMdebug (fn, "ENTER: set_head addr[%ld] %d members\n",
              set_head, num_members);

  for (x = 0, cur_set = set_head->next; x < num_members - 1; 
       x++, cur_set = cur_set->next)
  {
    if (cur_set->cat_no == set_head->cat_no)
      strcpy (cur_set->cat_name, set_head->cat_name);
    else
      break;
  }

  if (cur_set == (struct NFMset_member *) NULL)
  {
    _PDMdebug (fn, 
                "EXIT: set & members in same catalog,  successful 0x%.8x\n", 
                NFM_S_SUCCESS);
    return (NFM_S_SUCCESS);
  }
  else
  {
    _PDMdebug (fn, "begin set addr [%ld], [%d] members left\n",
                       cur_set, num_members-x-1);
    begin_process = cur_set;
    rest = x;
  }

  strcpy (sql_str, "select n_catalogno, n_catalogname from nfmcatalogs where");

  for (cur_cat_no = cur_set->cat_no, or = 0 ; x < num_members; 
       x++, cur_set = cur_set->next)
  {
    if (cur_set->cat_no != cur_cat_no)
    {
      if (or)
        strcat (sql_str, "or");
      else
        or = 1;
      strcat (sql_str, "n_catalogno =");
      strcat (sql_str, cur_set->cat_no);
      cur_cat_no = cur_cat->cat_no;
    }
  }

  _PDMdebug (fn, "exec qry: %s\n", sql_str);
  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fn, "NFMretrueve_values: SQl_str (%s) 0x%.8x\n", sql_str, status);
    return (status);
  }

  for (x = rest, cur_set = begin_process, cur_cat_no = cur_set->cat_no; 
       x < num_members; )
     
  {
    _PDMdebug (fn, "given cat_no = %d search...\n", cur_set->cat_no);
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;

      _PDMdebug (fn, "row %d, cat_no: %s cat_name: %s\n",
                  y, data[index], data[index+1]);

      if (atol(data[index]) == cur_set->cat_no)
      {
        _PDMdebug (fn, "Found match!\n");
        break;
      }
    }   

    do 
    {
      strcpy (cur_set->cat_name, data[index+1]);
      _PDMdebug (fn, "cat_no %d, cat_name %s\n",
                  cur_set->cat_no, cur_cat->cat_name);
      cur_set = cur_set->next;
      x ++;
    }
    while ((cur_set != (struct NFMset_member *) NULL) && 
           (cur_set->cat_no == cur_cat_no) );
  }
 
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fn, "MEMclose 0x%.8x\n", status);
    return (status);
  }

  _PDMdebug (fn, "EXIT: successful 0x%.8x \n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}


long PDMXXretrieve_set_members (members_list, count, level, set_head, set_end,
                              num_members)

struct NFMmembers *members_list;
long  count, level;
struct NFMset_member *set_head, *set_end;
long *num_members;

{
  /***
    This recursive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 
    This function returns SQL_I_NO_ROWS_FOUND or NFM_S_SUCCESS
    for successful statii.
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached. The returning list will have
    only those member/s which are attached.

    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      09/01/91 mfb creation.
      02/12/92 MaC added support of checking attach flag.
  ***/

  char *fn="PDMXretrieve_set_members";
  char sql_str[5120]; /* reconsider this one later */
  char value[50];
  char **data;
  int x, or, index;
  long count2;
  MEMptr list=NULL;
  struct NFMmembers *members_list2;
  struct NFMset_member *cat_head, *new_node;

  _PDMdebug (fn, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 
               count, level, *num_members);

  sprintf (sql_str, "%s %s %s %s",
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno," , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ",
"pdmcit.p_attached FROM nfmsetcit, pdmcit ",
"where pdmcit.p_citno = nfmsetcit.n_citno and (");

  for (x = or = 0; x < count; x++)
  {
    _PDMdebug ( fn, "retrieve member for cat [%d], item [%d]\n",
                 (members_list+x)->cat_no, (members_list+x)->item_no); 
    if (or)
    {
      strcat (sql_str, " or ((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
    }
    else
    {
      strcat (sql_str, "((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
      or = 1;
    }
  } 
  
  strcat (sql_str, " ) ORDER BY n_ccatalogno");

  _PDMdebug (fn, "exec qry: %s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
  }

        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows,
                     list->rows * sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL) {
    _PDMdebug (fn, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers));
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
    index = x * list->columns;
    _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n",
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
      if (! strcmp (data[index+6], "Y")) {
      new_node = (struct NFMset_member *) NULL; 
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
      _PDMdebug (fn, "new_node->type's strlen = %d\n", strlen (new_node->type));
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strncpy ((members_list2+count2)->type, new_node->type, 2);
      /* strncpy ((members_list+count2)->type, new_node->type, 2);*/
      count2 ++;
   _PDMprint_setmember ("new_node", new_node);
     }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fn,"MEMclose (list of members from nfmsetcit) 0x%.8x\n",
                status);
    return (status);
  }

  if (count2)
  {
   status = PDMXXretrieve_set_members (members_list2, count2, level+1, set_head,
             set_end, num_members);
    if (status != NFM_S_SUCCESS)
    {
      free (members_list2);
      _PDMdebug (fn,"PDMXXretrieve_set_members 0x%.8x\n", status);
      return (status);
    }
  }

  free (members_list2);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}



long PDMXretrieve_set_members (members_list, count, level, set_head, set_end,
                              num_members)

struct NFMmembers *members_list;
long  count, level;
struct NFMset_member *set_head, *set_end;
long *num_members;

{
  /***
    This recursive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached. The returning list will have
    only those member/s which are attached.
    Further, this functions returns only unique child members.
    The list output will have only non-duplicate members.
    Note, that the tree structure of the assy is not preserved,
    the list only contains those members whose entries in the LFM
    have to be modified.

    This function returns SQL_I_NO_ROWS_FOUND or NFM_S_SUCCESS
    for successful statii.
    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      09/01/91 mfb creation.
      02/12/92 MaC added support of checking attach flag.
      03/02/92  MaC added support of removing duplicate members.
  ***/


  char *fn="PDMXretrieve_set_members";
  char sql_str[5120]; /* reconsider this one later */
  char value[50];
  char **data;
  int x, or, index;
  int duplicate, cat_no, item_no;
  long count2;
  MEMptr list=NULL;
  struct NFMmembers *members_list2;
  struct NFMset_member *cat_head, *new_node, *cur_mem;

  _PDMdebug (fn, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 
               count, level, *num_members);

  sprintf (sql_str, "%s %s %s %s",
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno," , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ",
"pdmcit.p_attached FROM nfmsetcit, pdmcit ",
"where pdmcit.p_citno = nfmsetcit.n_citno and (");

  for (x = or = 0; x < count; x++)
  {
    _PDMdebug ( fn, "retrieve member for cat [%d], item [%d]\n",
                 (members_list+x)->cat_no, (members_list+x)->item_no); 
    if (or)
    {
      strcat (sql_str, " or ((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
    }
    else
    {
      strcat (sql_str, "((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
      or = 1;
    }
  } 
  
  strcat (sql_str, " ) ORDER BY n_ccatalogno");

  _PDMdebug (fn, "exec qry: %s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
  }
     PDMupdate_dots();

        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows,
                     list->rows * sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL) {
    _PDMdebug (fn, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers));
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
    index = x * list->columns;
     cat_no = atol (data[index+3]);
     item_no = atol (data[index+4]);
    _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n",
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
      if (! strcmp (data[index+6], "Y")) {
/* added support for removing duplicates.. */
      duplicate = 0;
/*
      for (z = 0; z <= count2; ++z) {
        if ( ((members_list2 + z)->cat_no == cat_no) &&
                ((members_list2 + z)->item_no == item_no) ) {
_PDMdebug (fn,
"***Aha! Found a duplicate!! ==>> cat_no[%d] item[%d] \n", cat_no, item_no);

               duplicate = 1;
               break;
               }
        }
*/
      for (cur_mem = set_head; 
                        cur_mem != (struct NFMset_member *) NULL; 
                             cur_mem = cur_mem->next) {
_PDMdebug (fn,
"Checking ==>> cat_no[%d] item[%d] \n", cat_no, item_no);
        if ( (cur_mem->cat_no == cat_no) &&
                (cur_mem->item_no == item_no) ) {
_PDMdebug (fn,
"***Aha! Found a duplicate!! ==>> cat_no[%d] item[%d] \n", cat_no, item_no);

               duplicate = 1;
               break;
               }
        }
    _PDMdebug (fn, "duplicate [%d]\n", duplicate);
      if (duplicate == 0) {
      new_node = (struct NFMset_member *) NULL; 
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
      _PDMdebug (fn, "new_node->type's strlen = %d\n", strlen (new_node->type));
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strncpy ((members_list2+count2)->type, new_node->type, 2);
      /* strncpy ((members_list+count2)->type, new_node->type, 2);*/
      count2 ++;
   _PDMprint_setmember ("new_node", new_node);
       }
     }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fn,"MEMclose (list of members from nfmsetcit) 0x%.8x\n",
                status);
    return (status);
  }

  if (count2)
  {
    status = PDMXretrieve_set_members (members_list2, count2, level+1, set_head,
             set_end, num_members);
    if (status != NFM_S_SUCCESS)
    {
      free (members_list2);
      _PDMdebug (fn,"PDMretrieve_set_members 0x%.8x\n", status);
      return (status);
    }
     PDMupdate_dots();
  }

  free (members_list2);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}





long PDMexp_retrieve_set_members (members_list, count, level, set_head, set_end,
                              num_members)

struct NFMmembers *members_list;
long  count, level;
struct NFMset_member *set_head, *set_end;
long *num_members;

{
  /***
    This recursive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached. The returning list will have
    only those member/s which are attached.
    Further, this functions returns only unique child members.
    The list output will have only non-duplicate members.
    Note, that the tree structure of the assy is not preserved,
    the list only contains those members whose entries in the LFM
    have to be modified.

    This function returns SQL_I_NO_ROWS_FOUND or NFM_S_SUCCESS
    for successful statii.
    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      09/01/91 mfb creation.
      02/12/92 MaC added support of checking attach flag.
      03/02/92  MaC added support of removing duplicate members.
      04/09/92  MaC added support of checking p_explode flag.
      09/14/92  MaC added support of loading catalogname/itemname/revision/
                cofilename information into the linked list.
  ***/


  char *fn="PDMexp_retrieve_set_members";
  char *sql_str;
  char value[50];
  char **data;
  int x, or, index;
  int duplicate, cat_no, item_no;
  long count2;
  int	inc_str = 0;
  MEMptr list=NULL;
  long  PDMcheck_and_add_cat();
  struct NFMmembers *members_list2;
  struct NFMset_member *cat_head, *new_node, *cur_mem;

  _PDMdebug (fn, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 
               count, level, *num_members);

  new_node = (struct NFMset_member *) NULL; 
  cur_mem = (struct NFMset_member *) NULL; 
  cat_head = (struct NFMset_member *) NULL; 
  members_list2 = (struct NFMmembers *) NULL; 
 
/* sql_str will be dynamically allocated MaC 012793 */
  
    sql_str = (char *) malloc ((*num_members * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';

  sprintf (sql_str, "%s %s %s %s %s %s",
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno," , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ",
"pdmcit.p_attached, pdmcit.p_explode, pdmcit.n_catalogname, ",
"pdmcit.n_itemname, pdmcit.n_itemrev, pdmcit.n_cofilename, pdmcit.p_incbom ",
"FROM nfmsetcit, pdmcit ",
"where pdmcit.p_citno = nfmsetcit.n_citno and (");

  for (x = or = 0; x < count; x++)
  {
    _PDMdebug ( fn, "retrieve member for cat [%d], item [%d]\n",
                 (members_list+x)->cat_no, (members_list+x)->item_no); 
    if (or)
    {
      strcat (sql_str, " or ((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
    }
    else
    {
      strcat (sql_str, "((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
      or = 1;
    }
  } 
  
  strcat (sql_str, " ) ORDER BY n_ccatalogno");

  _PDMdebug (fn, "exec qry: %s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    free (sql_str);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
status = _PDMget_db_error (status);
    return (status);
  }

  free (sql_str);
  PDMupdate_dots();

  if (PDMdebug_on) {
     MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
     }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows,
                     list->rows * sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL) {
    _PDMdebug (fn, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers));
    MEMclose (&list);
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
    index = x * list->columns;
     cat_no = atol (data[index+3]);
     item_no = atol (data[index+4]);
    _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n",
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
      /* Added to support macro libraries - Kumar 4.6.93 */
       status = PDMcheck_and_add_cat(data[index+8]);
        if(status != PDM_S_SUCCESS)
        {
   _PDMdebug (fn, "Unable to determine the type of %s \n", new_node->cat_name);
   _PDMdebug (fn, "But still proceeding...\n");
        }
/* if p_attached is Y then add the member to the list */
      if (! strcmp (data[index+6], "Y")) {
/* added support for removing duplicates.. */
      duplicate = 0;
      for (cur_mem = set_head; 
                        cur_mem != (struct NFMset_member *) NULL; 
                             cur_mem = cur_mem->next) {
               _PDMdebug (fn,
               "Checking ==>> cat_no[%d] item[%d] \n", 
                                    cat_no, item_no);
        if ( (cur_mem->cat_no == cat_no) &&
                (cur_mem->item_no == item_no) ) {
               _PDMdebug (fn,
               "***Aha! Found a duplicate!! ==>> cat_no[%d] item[%d] \n", 
                                    cat_no, item_no);

               duplicate = 1;
               break;
               }
        }
    _PDMdebug (fn, "duplicate [%d]\n", duplicate);
/* added support for checking p_incbom flag...
    if set to Y or A then do not look for its children...*/

     inc_str = 0;

/* If the member already exists in the list, it is immaterial 
   whether it is attached again with incbom set to no. MaC 051693 */
     /*if ((duplicate == 0) &&
        ( (!strcmp (data[index+12], "Y") || !strcmp (data[index+12], "y")) ||
    (!strcmp (data[index+12], "A") || !strcmp (data[index+12], "a"))) ) */

     if (duplicate == 0) {
        if ( (!strcmp (data[index+12], "Y") 
                              || !strcmp (data[index+12], "y")) ||
              (!strcmp (data[index+12], "A") 
                              || !strcmp (data[index+12], "a")) )/* {  */
                                     inc_str = 1;
         else inc_str = 0;
        _PDMdebug (fn, "p_incbom[%s], inc_str[%d]\n", data[index+12], inc_str);
      /* Further addition to incstr support;
              This means that if incbom is y or a and level is not one
              then chop off that branch of the tree. If it is level one
              then add the member and stop looking further in that dir */
      if ( (inc_str == 0 && level == 0 ) || (inc_str == 1) ) {
      new_node = (struct NFMset_member *) NULL; 
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member));
        MEMclose (&list);
        return (NFM_E_MALLOC);
      }
      new_node->level = level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
      strcpy (new_node->cat_name, data[index+8]);
      /* Added to support macro libraries - Kumar 4.6.93 */
       status = PDMcheck_and_add_cat(new_node->cat_name);
        if(status != PDM_S_SUCCESS)
        {
   _PDMdebug (fn, "Unable to determine the type of %s \n", new_node->cat_name);
   _PDMdebug (fn, "But still proceeding...\n");
        }
        
      strcpy (new_node->item_name, data[index+9]);
      strcpy (new_node->item_rev, data[index+10]);
      strcpy (new_node->co_filename, data[index+11]);
      _PDMdebug (fn, "new_node->type's strlen = %d\n", strlen (new_node->type));
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
/* added support for checking p_explode flag...
    if set to N or n then do not look for its children...*/
     if ( ((!strcmp (data[index+7], "Y")) || (!strcmp (data[index+7], "y")))) {
/*
      if (inc_str != 0 ) {
*/
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strncpy ((members_list2+count2)->type, new_node->type, 2);
      /* strncpy ((members_list+count2)->type, new_node->type, 2);*/
      count2 ++;
/*
            }
*/
         }
   _PDMprint_setmember ("new_node", new_node);
         }
/*
       }
*/
      } /*duplicate end*/
     }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn,"MEMclose (list of members from nfmsetcit) 0x%.8x\n",
                status);
    return (status);
  }

  if (count2)
  {
    status = PDMexp_retrieve_set_members (members_list2, count2, level+1, 
                                            set_head, set_end, num_members);
    if (status != NFM_S_SUCCESS)
    {
      free (members_list2);
      _PDMdebug (fn,"PDMretrieve_set_members 0x%.8x\n", status);
      return (status);
    }
     PDMupdate_dots();
  }

  free (members_list2);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}

/* Code to support the movement of macro libararies during
   checkout - Kumar 4.9.93 */

long PDMcheck_and_add_cat(char *cat_name)
{

struct  PDUcat_node  *head = NULL;
struct  PDUcat_node  *temp = NULL;
int     found = 0, catno;
char    type[5];
char    *fname = "PDMcheck_and_add_cat";

      _PDMdebug(fname,"Enter");
      type[0] = '\0';
      status = PDMget_catno_type(cat_name, &catno, type);
      if(status != SQL_S_SUCCESS)
          return(PDM_S_SUCCESS);
 
     /*if(!strcmp(type,"P") || !strcmp(type,"CID") || !strcmp(type,"EID")) */
/* Added to support new parametric external catalog type MaC 010194*/
     if(!strcmp(type,"P") || !strcmp(type,"CID") ||
            !strcmp(type,"PXT") || !strcmp(type,"EID"))

      {
       found = 0;
    /* Create a node with catalog name */
      if (PDMparam_cat_list != NULL)
         {
               found = 0;
           /* Get to the end of list */
              head = PDMparam_cat_list;
             for (; head != NULL; head = head->next )
             {
    _PDMdebug (fname,"address of head %d= %x\n", head, head);
              if(!strcmp(head->catalog,cat_name)) 
               {
               found = 1;
               break;
                }
               }
          }
           if(found == 0)
           {
            temp = (struct PDUcat_node *) malloc(sizeof(struct PDUcat_node));
            /* Add catalog name to link list */
             /* Initialize temp fields */
             temp->catalog = (char *) malloc (25);
              strcpy(temp->catalog , cat_name);
              temp->count = 1;
              temp->next = NULL;
                if (PDMparam_cat_list)  
                 {
                 /* Get to the end of list */
                  head = PDMparam_cat_list;
                  while (head->next)     
                    {
              _PDMdebug (fname,"address of head %d= %x\n", head, head);
                    head = head->next;
                    }
                   /* Add catalog name to link list */
                     head->next = temp;
                 }
                  else
                    {
                    /* This is the first node in the list */
              _PDMdebug (fname,"address of temp %d= %x\n", temp, temp);
                     PDMparam_cat_list = temp;
                     }
          }

       }
      _PDMdebug(fname,"Exit");
      return(PDM_S_SUCCESS);
}
