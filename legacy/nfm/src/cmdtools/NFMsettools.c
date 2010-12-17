#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"


long NFMretrieve_set_members (members_list, count, level, set_head, set_end,
                              num_members)

struct NFMmembers *members_list;
long  count, level;
struct NFMset_member *set_head, *set_end;
long *num_members;

{
  /***
    This recurvsive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 

    Note: The caller does not have to make sure the passed in item_nos are sets

  ***/

  char *fname="NFMretrieve_set_members";

/* char sql_str[5120]; */ /* reconsider this one later */

/* To fix the problem with a set having more than 150 members, 
   increased the string size. Needs better handling - Jujare 24 Oct 95 */ 


  char sql_str[15000]; 
    
  char value[50];
  char **data;
  int x, y, or, index;
  int found;
  long count2;
  long status;
  MEMptr list=NULL;
  struct NFMmembers *members_list2;
  struct NFMset_member *cat_head, *new_node;
  struct NFMset_member *cat_current, *cat_last;

  _NFMdebug ((fname, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 

               count, level, *num_members));

  sprintf (sql_str, "%s %s",
           "SELECT n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, ",
           "n_type FROM nfmsetcit where ");

  for (x = or = 0; x < count; x++)
  {
    _NFMdebug ( (fname, "retrieve member for cat [%d], item [%d]\n",
                 (members_list+x)->cat_no, (members_list+x)->item_no)); 
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

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    if (status != SQL_I_NO_ROWS_FOUND)
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) );
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows,
                      sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL)
  {
    _NFMdebug ((fname, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers)));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                    list->rows * sizeof (struct NFMmembers));
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++)
  {
    index = x * list->columns;
    _NFMdebug ( (fname, "row %d: %s %s %s %s %s %s\n",
               x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5]) );
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
      _NFMdebug ((fname, "allocate a new struct for new cat and item\n"));
      new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
      if (new_node == (struct NFMset_member *) NULL)
      {
        _NFMdebug ((fname, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member)));
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
              strncpy (new_node->type, "S", NFM_TYPE);
              break;
            }
            else
            {
              strncpy (new_node->type, data[index+5], NFM_TYPE);
              break;
            }
          }
        }
      }
      else
        strncpy (new_node->type, data[index+5], NFM_TYPE);
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strncpy ((members_list2+count2)->type, new_node->type, NFM_TYPE);
      count2 ++;
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
        _NFMdebug ((fname, "allocate a new struct for new item\n"));
        new_node = (struct NFMset_member *)calloc (1,
                         sizeof (struct NFMset_member));
        if (new_node == (struct NFMset_member *) NULL)
        {
          _NFMdebug ((fname, "Allocate %d  failed\n", 
                        sizeof (struct NFMset_member)));
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
                strncpy (new_node->type, "S", NFM_TYPE);
                break;
              }
              else
              {
                strncpy (new_node->type, data[index+5], NFM_TYPE);
                break;
              }
            }
          }
        }
        else
          strncpy (new_node->type, data[index+5], NFM_TYPE);
        new_node->next = cat_current;
        cat_last->next = new_node;
        if (cat_current == (struct NFMset_member *) NULL)
        {
          set_end = new_node;
        }
        (*num_members) ++; 
        (members_list2+count2)->cat_no = new_node->cat_no;
        (members_list2+count2)->item_no = new_node->item_no;
        strncpy ((members_list2+count2)->type, new_node->type, NFM_TYPE);
        count2 ++;
      }
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname,"MEMclose (list of members from nfmsetcit) 0x%.8x\n",
                status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }

  if (count2)
  {
    status = NFMretrieve_set_members (members_list2, count2, level+1, set_head,
             set_end, num_members);
    if (status != NFM_S_SUCCESS)
    {
      free (members_list2);
      _NFMdebug ((fname,"NFMretrieve_set_members 0x%.8x\n", status));
      return (status);
    }
  }

  free (members_list2);
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}

long NFMget_catalog_names (set_head, num_members)

struct NFMset_member *set_head;
long num_members;

{
  char *fname="NFMget_catalog_names";
  char sql_str[4096]; /* COME BACK LATER */
  char **data, temp_str[10];
  char dumb_str[2];
  int  y, index, or;
  long status;
  long cur_cat_no;
  long dumb_value;
  MEMptr list=NULL;
  struct NFMset_member *cur_set, *begin_process;

  _NFMdebug ((fname, "ENTER: set_head addr[%ld] %d members\n",
              set_head, num_members))

  for (cur_set = set_head->next; cur_set != (struct NFMset_member *) NULL; 
       cur_set = cur_set->next)
  {
    _NFMdebug ((fname, "cur_set->cat_no = %d\n", cur_set->cat_no));
    if (cur_set->cat_no == set_head->cat_no)
      strcpy (cur_set->cat_name, set_head->cat_name);
    else
      break;
  }

  if (cur_set == (struct NFMset_member *) NULL)
  {
    _NFMdebug ((fname, 
                "EXIT: set & members in same catalog,  successful 0x%.8x\n", 
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }
  else
  {
    _NFMdebug ((fname, "begin set addr [%ld]\n", cur_set));
    begin_process = cur_set;
  }

  strcpy (sql_str, "select n_catalogno, n_catalogname from nfmcatalogs where ");

  for (cur_cat_no = 0, or = 0 ; cur_set != (struct NFMset_member *) NULL; 
       cur_set = cur_set->next)
  {
    if (cur_set->cat_no != cur_cat_no)
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogno = ");
      sprintf (temp_str, "%d", cur_set->cat_no);
      strcat (sql_str, temp_str);
      cur_cat_no = cur_set->cat_no;
    }
  }

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));
  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (cur_set = begin_process, cur_cat_no = cur_set->cat_no; 
       cur_set != (struct NFMset_member *) NULL; )
     
  {
    _NFMdebug ((fname, "given cat_no = %d search...\n", cur_set->cat_no));
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;

      _NFMdebug ((fname, "row %d, cat_no: %s cat_name: %s\n",
                  y, data[index], data[index+1]));

      if (atol(data[index]) == cur_set->cat_no)
      {
        _NFMdebug ((fname, "Found match!\n"));
        break;
      }
    }   

    do 
    {
      strcpy (cur_set->cat_name, data[index+1]);
      _NFMdebug ((fname, "cat_no %d, cat_name %s\n",
                  cur_set->cat_no, cur_set->cat_name));
      cur_set = cur_set->next;
    }
    while ((cur_set != (struct NFMset_member *) NULL) && 
           (cur_set->cat_no == cur_cat_no) );
  }
 
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x \n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long NFMget_members_info (head_process, count, command)

struct NFMset_member *head_process;
long count;
long command;

{

  char *fname="NFMget_members_info";
  char *sql_str=NULL; /* COME BACK LATER */
  char value[50], *sub_str, dumb_str[2];
  char **data;
  char status_to_be[NFM_STATUS+1];
  int x, y, or, index, dumb_value;
  long status;
  MEMptr list=NULL;
  struct NFMset_member *cur_set;

  _NFMdebug ((fname, "ENTER: retrieve %d items from cat_no[%d], command [%d]\n",
                      count, head_process->cat_no, command));

  sql_str = (char *) malloc ( (count * 250 +1024) * sizeof (char) );
 
  if (sql_str == (char *) NULL)
  {
    _NFMdebug ((fname, "Failed to malloc the memory\n"));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                     (count * 250 +1024) * sizeof (char));
    return (NFM_E_MALLOC);
  }

  if (command == NFM_CHECK_OUT_SET_SELECTIVELY)
  {
    sprintf (sql_str, "%s %s %s %s '%s' %s '%s' %s",
           "select n_itemno, n_status, n_archivestate, n_itemlock,",
           "n_pendingflag, n_versionlimit, n_itemname, n_itemrev, n_itemdesc from ",
           head_process->cat_name, "where (n_itemname =", 
           head_process->item_name, "and n_itemrev =", 
           head_process->item_rev, ")");

    for (x = 1, cur_set=head_process->next; x < count; 
         x ++, cur_set=cur_set->next)
    {
      strcat (sql_str, " or (n_itemname = '");
      strcat (sql_str, cur_set->item_name);
      strcat (sql_str, "' and n_itemrev = '");
      strcat (sql_str, cur_set->item_rev);
      strcat (sql_str, "')");
    }
  }
  else
  {
    sprintf (sql_str, "%s %s %s %s %d ",
           "select n_itemno, n_status, n_archivestate, n_itemlock,",
           "n_pendingflag, n_versionlimit, n_itemname, n_itemrev, n_itemdesc from ",
           head_process->cat_name, "where n_itemno =", 
           head_process->item_no);

    for (x = 1, cur_set=head_process->next; x < count; 
         x ++, cur_set=cur_set->next)
    {
      strcat (sql_str, "or n_itemno =");
      sprintf (value, "%d", cur_set->item_no);
      strcat (sql_str, value);
    }
  }

  status = NFMlock_table (head_process->cat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n",
                       head_process->cat_name,status));
    free (sql_str);
    return (status);
  }

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, 
              dumb_str, &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
    free (sql_str);
    return (status);
  }

  data = (char **) list->data_ptr;

  sub_str = (char *) malloc ( count * 100 * sizeof (char));

  if (sub_str == (char *) NULL)
  {
    _NFMdebug ((fname, "Failed to malloc the memory\n"));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                     count * 100 * sizeof (char));
    return (NFM_E_MALLOC);
  }

  strcpy (sub_str, "\0");

  for (x = 0, or = 0; x < list->rows; x++)
  {
    index = list->columns * x;
    _NFMdebug ((fname, "%d retrieved item [%s.%s]\n", x,
                        data[index+6], data[index+7]));
    if (command == NFM_CHECK_OUT_SET_SELECTIVELY)
    {
      for (y = 0, cur_set = head_process; y < count; 
           y++, cur_set = cur_set->next)
      {
        _NFMdebug ((fname, "%d cur_set->item_name [%s.%s]\n", y,
                            cur_set->item_name, cur_set->item_rev));
        if (!strcmp(data[index+6], cur_set->item_name) &&
            !strcmp(data[index+7], cur_set->item_rev)     )
          break;
      }
    }
    else
    {
      for (y = 0, cur_set = head_process; y < count; 
           y++, cur_set = cur_set->next)
      {
        if (atol(data[index]) == cur_set->item_no)
          break;
      }
    }
    if (command == NFM_CHECK_IN || command == NFM_SAVE_FILES)
    {
      strcpy (cur_set->file_status, data[index+1]);
      strcpy (cur_set->lock, data[index+3]);
      strcpy (cur_set->item_rev, data[index+7]);
      strcpy (cur_set->item_desc, data[index+8]);
      strcpy (cur_set->item_name, data[index+6]);
      if (!strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
                    cur_set->type));
        if (cur_set->flag == NFM_SET)
        {
          if (strlen(data[index+1]) && strcmp(data[index+1], "S") &&
              strcmp(data[index+1], "SN") )
          {
            _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                        cur_set->item_no, data[index+1]));
            if (command == NFM_CHECK_IN)
              _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_CHECK_IN,
                            NFM_SET, data[index+1], data[index+2]);
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_SAVE_FILES,
                            NFM_SET, data[index+1], data[index+2]);
            free (sql_str);
            free (sub_str);
            return (NFM_E_BAD_FILE_STATUS);
          }
          else if (command == NFM_SAVE_FILES && !strlen (data[index+1]))
          {
            _NFMdebug ((fname, "set is not checked out\n"));
            ERRload_struct (NFM, NFM_E_SSF_STATUS_I, "", NULL);
            free (sql_str);
            free (sub_str);
            return (NFM_E_SSF_STATUS_I);
          }
        }
        else
        {
          if (strlen(data[index+1]) && strcmp(data[index+1], "M") &&
                                     strcmp(data[index+1], "MN") )
          {
            _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                        cur_set->item_no, data[index+1]));
            if (command == NFM_CHECK_IN)
              _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_CHECK_IN,
                            NFM_PRIMARY_MEMBER, data[index+1], data[index+2]);
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_SAVE_FILES,
                            NFM_PRIMARY_MEMBER, data[index+1], data[index+2]);
            free (sql_str);
            free (sub_str);
            return (NFM_E_BAD_FILE_STATUS);
          }
        }

        /* set/primary member passed the status check */

        if (or)
          strcat (sub_str, "or ");
        else 
          or = 1;
        strcat (sub_str, "n_itemno = ");
        strcat (sub_str, data[index]);
      }
      strcpy (cur_set->archive_state, data[index+2]);
      strcpy (cur_set->pending_flag, data[index+4]);
      cur_set->version_limit = atol (data[index+5]);
    }
    else if (command == NFM_CHECK_OUT)
    {
      strcpy (cur_set->file_status, data[index+1]);
      strcpy (cur_set->lock, data[index+3]);
      strcpy (cur_set->item_rev, data[index+7]);
      strcpy (cur_set->item_desc, data[index+8]);
      strcpy (cur_set->item_name, data[index+6]);
      if (!strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
                    cur_set->type));
        if (strlen(data[index+1]) && strcmp(data[index+1], "I"))
        {
          _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                      cur_set->item_no, data[index+1]));
          if (cur_set->flag != NFM_SET )
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_PRIMARY_MEMBER, data[index+1], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SET, data[index+1], "");
          NFMlog_message ();
          free (sql_str);
          free (sub_str);
          return (NFM_E_BAD_FILE_STATUS);
        }
        if (strlen(data[index+2]) && strcmp(data[index+2], "B"))
        {
          _NFMdebug ((fname, "item [%d] archive state [%s] cannot checkout\n",
                      cur_set->item_no, data[index+2]));
          if (cur_set->flag != NFM_SET)
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_PRIMARY_MEMBER, data[index+2], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SET, data[index+2], "");
          NFMlog_message ();
          free (sql_str);
          free (sub_str);
          return (NFM_E_BAD_ARCHIVE_STATE);
        }
        if (strcmp (data[index+3], "N"))
        {
          _NFMdebug ((fname, "item [%d] lock [%s] cannot checkout\n",
                      cur_set->item_no, data[index+3]));
          if (cur_set->flag != NFM_SET)
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_PRIMARY_MEMBER, data[index+3], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SET, data[index+3], "");
          NFMlog_message ();
          free (sql_str);
          free (sub_str);
          return (NFM_E_ITEM_LOCKED);
        }
        if (strlen (data[index+4]))
        {
          _NFMdebug ((fname, "item [%d] pending flag [%s] cannot checkout\n",
                      cur_set->item_no, data[index+4]));
          if (cur_set->flag != NFM_SET)
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_PRIMARY_MEMBER, data[index+4], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SET, data[index+4], "");
          NFMlog_message ();
          free (sql_str);
          free (sub_str);
          return (NFM_E_BAD_PENDING_FLAG);
        }

        /* set/primary member passed the status check */

        strcpy (cur_set->archive_state, data[index+2]);
        strcpy (cur_set->pending_flag, data[index+4]);
        cur_set->version_limit = atol (data[index+5]);
        if (or)
          strcat (sub_str, "or ");
        else 
          or = 1;
        strcat (sub_str, "n_itemno = ");
        strcat (sub_str, data[index]);
      }
      else /* cur_set->type == "S" */
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
                    cur_set->type));
        if ( !strlen (data[index+1]) ||
             (strlen(data[index+1]) && !strncmp(data[index+1], "T", 1)) )
        {
          /* don't move the file */
          cur_set->move = NFM_NO_MOVE;
          _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                      cur_set->item_no, data[index+1]));
          _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SECONDARY_MEMBER, data[index+1], "");
          NFMlog_message ();
          goto COwarning_4_secondary_member;
        }
        if (strlen(data[index+2]) && strcmp(data[index+2], "B"))
        {
          /* don't move the file */
          _NFMdebug ((fname, "item [%d] archive state [%s] cannot checkout\n",
                      cur_set->item_no, data[index+2]));
          cur_set->move = NFM_NO_MOVE;
          _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SECONDARY_MEMBER, data[index+2], "");
          NFMlog_message ();
          goto COwarning_4_secondary_member;
        }
        if (strcmp (data[index+3], "N"))
        {
          /* don't move the file */
          _NFMdebug ((fname, "item [%d] lock [%s] cannot checkout\n",
                      cur_set->item_no, data[index+3]));
          cur_set->move = NFM_NO_MOVE;
          _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SECONDARY_MEMBER, data[index+3], "");
          NFMlog_message ();
          goto COwarning_4_secondary_member;
        }
        if (strlen (data[index+4]) && strcmp (data[index+4], "IB")
            && strcmp (data[index+4], "SB") && strcmp (data[index+4], "MB")
            && strcmp (data[index+4], "PB") )
        {
          /* don't move the files */
          _NFMdebug ((fname, "item [%d] pending flag [%s] cannot checkout\n",
                      cur_set->item_no, data[index+4]));
          cur_set->move = NFM_NO_MOVE;
          _NFMload_error_message (data[index+6], data[index+7], NFM_CHECK_OUT,
                            NFM_SECONDARY_MEMBER, data[index+4], "");
          NFMlog_message ();
          goto COwarning_4_secondary_member;
        }
        COwarning_4_secondary_member:
        strcpy (cur_set->archive_state, data[index+2]);
        strcpy (cur_set->lock, data[index+3]);
        strcpy (cur_set->pending_flag, data[index+4]);
        strcpy (cur_set->item_rev, data[index+7]);
        strcpy (cur_set->item_desc, data[index+8]);
        strcpy (cur_set->item_name, data[index+6]);
        cur_set->version_limit = atol (data[index+5]);
      }
    }
    else if (command == NFM_COPYFILES || command == NFM_PLOT_SET)
    {
      if (!strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
                    cur_set->type));
        if (strlen(data[index+1]) && !strncmp(data[index+1], "T", 1))
        {
          _NFMdebug ((fname, "item [%d] file status [%s] cannot copy files\n",
                      cur_set->item_no, data[index+1]));
          if (cur_set->flag != NFM_SET )
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_COPYFILES, NFM_PRIMARY_MEMBER, data[index+1], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_PRIMARY_MEMBER, data[index+1], "");
          else
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_COPYFILES, NFM_SET, data[index+1], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SET, data[index+1], "");
          NFMlog_message ();
          free (sql_str);
          return (NFM_E_BAD_FILE_STATUS);
        }
        if (strlen(data[index+2]) && strcmp(data[index+2], "B"))
        {
          _NFMdebug ((fname, "item [%d] archive state [%s] cannot copy files\n",
                      cur_set->item_no, data[index+2]));
          if (cur_set->flag != NFM_SET)
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_COPYFILES, NFM_PRIMARY_MEMBER, data[index+2], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_PRIMARY_MEMBER, data[index+2], "");
          else
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_COPYFILES, NFM_SET, data[index+2], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SET, data[index+2], "");
          NFMlog_message ();
          free (sql_str);
          return (NFM_E_BAD_ARCHIVE_STATE);
        }
        if (!strcmp (data[index+3], "Y"))
        {
          _NFMdebug ((fname, "item [%d] lock [%s] cannot copy files\n",
                      cur_set->item_no, data[index+3]));
          if (cur_set->flag != NFM_SET)
              ERRload_struct (NFM, NFM_E_PM_LOCKED, "", NULL);
          else
              ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
          NFMlog_message ();
          free (sql_str);
          return (NFM_E_ITEM_LOCKED);
        }
        if (strlen (data[index+4]) &&
            strcmp(data[index+4],"IB") && strcmp (data[index+4], "SB")
            && strcmp (data[index+4], "MB") && strcmp (data[index+4], "PB") )
        {
          _NFMdebug ((fname, "item [%d] pending flag [%s] cannot copy files\n",
                      cur_set->item_no, data[index+4]));
          if (cur_set->flag != NFM_SET)
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                  NFM_COPYFILES, NFM_PRIMARY_MEMBER, data[index+4], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                  NFM_PLOT_SET, NFM_PRIMARY_MEMBER, data[index+4], "");
          else
            if (command == NFM_COPYFILES)
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_COPYFILES, NFM_SET, data[index+4], "");
            else
              _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SET, data[index+4], "");
          NFMlog_message ();
          free (sql_str);
          return (NFM_E_BAD_PENDING_FLAG);
        }

        /* set/primary member passed the status check */

        strcpy (cur_set->file_status, data[index+1]);
        strcpy (cur_set->item_rev, data[index+7]);
        strcpy (cur_set->item_desc, data[index+8]);
        strcpy (cur_set->item_name, data[index+6]);
        strcpy (cur_set->archive_state, data[index+2]);
        strcpy (cur_set->lock, data[index+3]);
        strcpy (cur_set->pending_flag, data[index+4]);
        cur_set->version_limit = atol (data[index+5]);
      }
      else /* cur_set->type == "S" */
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
	            cur_set->type));
        if (strlen(data[index+1]) && !strncmp(data[index+1], "T", 1))
        {
          /* don't move the file */
          cur_set->move = NFM_NO_MOVE;
          _NFMdebug ((fname, "item [%d] file status [%s] cannot copy files\n",
                      cur_set->item_no, data[index+1]));
          if (command == NFM_COPYFILES)
            _NFMload_error_message (data[index+6], data[index+7], NFM_COPYFILES,
                            NFM_SECONDARY_MEMBER, data[index+1], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SECONDARY_MEMBER, data[index+1], "");
          NFMlog_message ();
          goto CPwarning_4_secondary_member;
        }
        else if (!strlen(data[index+1]))
        {
          /* don't move the file */
          cur_set->move = NFM_NO_MOVE;
          _NFMdebug ((fname, "item [%d] file status [%s] cannot copy files\n",
                      cur_set->item_no, data[index+1]));
          if (command == NFM_COPYFILES)
            _NFMload_error_message (data[index+6], data[index+7], NFM_COPYFILES,
                            NFM_SECONDARY_MEMBER, data[index+1], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SECONDARY_MEMBER, data[index+1], "");
          NFMlog_message ();
          goto CPwarning_4_secondary_member;
        }
        if (strlen(data[index+2]) && strcmp(data[index+2], "B"))
        {
          /* don't move the file */
          _NFMdebug ((fname, "item [%d] archive state [%s] cannot copy files\n",
                      cur_set->item_no, data[index+2]));
          cur_set->move = NFM_NO_MOVE;
          if (command == NFM_COPYFILES)
            _NFMload_error_message (data[index+6], data[index+7], NFM_COPYFILES,
                            NFM_SECONDARY_MEMBER, data[index+2], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], 
                 NFM_PLOT_SET, NFM_SECONDARY_MEMBER, data[index+2], "");
          NFMlog_message ();
          goto CPwarning_4_secondary_member;
        }
        if (!strcmp (data[index+3], "Y"))
        {
          /* don't move the file */
          _NFMdebug ((fname, "item [%d] lock [%s] cannot copy files\n",
                      cur_set->item_no, data[index+3]));
          cur_set->move = NFM_NO_MOVE;
          if (command == NFM_COPYFILES)
            ERRload_struct (NFM, NFM_W_SM_LOCKED, "", NULL);
          NFMlog_message ();
          goto CPwarning_4_secondary_member;
        }
        if (strlen (data[index+4]) && strcmp (data[index+4], "IB")
            && strcmp (data[index+4], "SB") && strcmp (data[index+4], "MB")
            && strcmp (data[index+4], "PB") )
        {
          /* don't move the files */
          _NFMdebug ((fname, "item [%d] pending flag [%s] cannot copy files\n",
                      cur_set->item_no, data[index+4]));
          cur_set->move = NFM_NO_MOVE;
          if (command == NFM_COPYFILES)
            _NFMload_error_message (data[index+6], data[index+7], NFM_COPYFILES,
                            NFM_SECONDARY_MEMBER, data[index+4], "");
          else
            _NFMload_error_message (data[index+6], data[index+7], NFM_PLOT_SET,
                            NFM_SECONDARY_MEMBER, data[index+4], "");
          NFMlog_message ();
          goto CPwarning_4_secondary_member;
        }
        CPwarning_4_secondary_member:
        strcpy (cur_set->file_status, data[index+1]);
        strcpy (cur_set->item_rev, data[index+7]);
        strcpy (cur_set->item_desc, data[index+8]);
        strcpy (cur_set->item_name, data[index+6]);
        strcpy (cur_set->archive_state, data[index+2]);
        strcpy (cur_set->lock, data[index+3]);
        strcpy (cur_set->pending_flag, data[index+4]);
        cur_set->version_limit = atol (data[index+5]);
      }
    }
    else if (command == NFM_CANCEL_CHECK_OUT)
    {
      strcpy (cur_set->file_status, data[index+1]);
      strcpy (cur_set->item_rev, data[index+7]);
      strcpy (cur_set->item_desc, data[index+8]);
      strcpy (cur_set->item_name, data[index+6]);
      strcpy (cur_set->lock, data[index+3]);
      if (!strcmp(cur_set->type, "P"))
      {
        _NFMdebug ((fname, "item [%d] type [%s]\n", cur_set->item_no,
                    cur_set->type));
        if (cur_set->flag == NFM_SET)
        {
          if (strlen(data[index+1]) && strcmp(data[index+1], "S") &&
              strcmp(data[index+1], "SN") )
          {
            _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                        cur_set->item_no, data[index+1]));
            _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_CANCEL_CHECK_OUT,
                            NFM_SET, data[index+1], "");
            free (sql_str);
            free (sub_str);
            return (NFM_E_BAD_FILE_STATUS);
          }
        }
        else
        {
          if (strlen(data[index+1]) && strcmp(data[index+1], "M") &&
                                     strcmp(data[index+1], "MN") )
          {
            _NFMdebug ((fname, "item [%d] file status [%s] cannot checkout\n",
                        cur_set->item_no, data[index+1]));
            _NFMload_error_message (data[index+6], data[index+7], 
                            NFM_CANCEL_CHECK_OUT,
                            NFM_PRIMARY_MEMBER, data[index+1], "");
            free (sql_str);
            free (sub_str);
            return (NFM_E_BAD_FILE_STATUS);
          }
        }

        /* set/primary member passed the status check */

        if (or)
          strcat (sub_str, "or ");
        else 
          or = 1;
        strcat (sub_str, "n_itemno = ");
        strcat (sub_str, data[index]);
      }
      strcpy (cur_set->archive_state, data[index+2]);
      strcpy (cur_set->pending_flag, data[index+4]);
      cur_set->version_limit = atol (data[index+5]);
    }
    else if (command == NFM_CHECK_OUT_SET_SELECTIVELY)
    {
      cur_set->item_no = atol (data[index]);
      strcpy (cur_set->file_status, data[index+1]);
      strcpy (cur_set->item_rev, data[index+7]);
      strcpy (cur_set->item_desc, data[index+8]);
      strcpy (cur_set->item_name, data[index+6]);
      strcpy (cur_set->archive_state, data[index+2]);
      strcpy (cur_set->lock, data[index+3]);
      strcpy (cur_set->pending_flag, data[index+4]);
      cur_set->version_limit = atol (data[index+5]);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (sub_str);
    free (sql_str);
    return (status);
  }

  if (! strlen (sub_str))
    goto ready_to_return;

  if (command == NFM_CHECK_OUT)
    strcpy (status_to_be, "TO");
  else if (command == NFM_CHECK_IN || command == NFM_CANCEL_CHECK_OUT)
    strcpy (status_to_be, "TI");
  else if (command == NFM_SAVE_FILES)
    strcpy (status_to_be, "TS");
  else if (command == NFM_COPYFILES || command == NFM_CHECK_OUT_SET_SELECTIVELY
                                    || command == NFM_PLOT_SET)
    goto ready_to_return;

  sprintf (sql_str, "%s %s %s '%s' %s %s",
           "update", head_process->cat_name, "set n_status =",
           status_to_be,  "where",
           sub_str);

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    free (sql_str);
    free (sub_str);
    return (status);
  }
  
  ready_to_return:
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "COMMIT WORK 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (status);
  } 

  free (sql_str);
  free (sub_str);

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", status));
  return (NFM_S_SUCCESS);
}

#define NFM_I_CATNO 0
#define NFM_I_ITEMNO 1

long NFMrollback_set_status (command, set_list, files_info, records, frecords, 
               lfm_records, lfm_list1, lfm_list2)

long command; /* possible values: NFM_CHECK_OUT, NFM_CHECK_IN, NFM_COPYFILES */
struct NFMset_member *set_list;
MEMptr files_info; /* list used for NFM_CHECK_IN */
long records; /* number of items records to rollback in the same/different
               <catalog> */
long frecords; /* number of items files records to rollback in the 
                  same/different f_<catalog> */
long lfm_records; /* number of items files records to rollback in nfmsafiles */
struct NFMlfm_file *lfm_list1; /* this has file movement */
struct NFMlfm_file *lfm_list2; /* do not have file movement */

/***

  1. Rollback the file status of set and its members.
  2. Rollback the records in f_<catalog>.
  3. Rollback the records in nfmsafiles.



***/

{
  char *fname="NFMrollback_set_status";
  char sql_str[1024], sql_str1[1024];
  char fcat_name[NFM_CATALOGNAME+3];
  char fileco_str[NFM_FILECO+1];
  char **data;
  int i_catno, i_itemnum, i_filenum, i_fileversion, i_fileco;
  long x, y, z, index, exec;
  long status;
  struct NFMset_member *head;
  struct NFMlfm_file *head_lfm1, *head_lfm2;

  _NFMdebug ((fname, 
            "ENTER: command [%d] rollback file status for %d set and members\n",
             command, records));

  /* NULL condition test added 20 jan 94 SSRS */
  for (head=set_list, x = 0; x < records && head != NULL; head=head->next, x++)
  {
    _NFMdebug ((fname, "item [%d] cat [%s] and type [%s]\n",
                        head->item_no, head->cat_name, head->type));
       /* a good value in head->lock also indicates a good value in
          head->file_status that can be used to roll back item's status */
    if (!strcmp (head->type, "P") && strlen (head->lock))
    {
      if (!strlen (head->file_status))
      {
        sprintf (sql_str, "UPDATE %s SET n_status = NULL WHERE n_itemno = %d",
                 head->cat_name,
               head->item_no);
      }
      else
      {
        sprintf (sql_str, "UPDATE %s SET n_status = '%s' WHERE n_itemno = %d",
                 head->cat_name, head->file_status,
                 head->item_no);
       }
       status = NFMlock_table (head->cat_name);
       if (status != NFM_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
       status = SQLstmt ("COMMIT WORK");
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

    }
  }
  if (command == NFM_CHECK_OUT && files_info != (MEMptr) NULL)
  {
    i_fileversion = 5; i_catno = 0; i_itemnum = 1;
    data = (char **) files_info->data_ptr;
    /* NULL condition test added 20 jan 94 SSRS */
    for (head=set_list, x = 0; x < records && head != NULL; head=head->next, x++)
    {
      _NFMdebug ((fname, "item [%d] cat [%s] and type [%s]\n",
                          head->item_no, head->cat_name, head->type));
      if (!strcmp (head->type, "P") )
      {
        if (strlen (head->file_status))
          strcpy (fileco_str, "Y");
        else
          strcpy (fileco_str, "");
        /* need to use the n_fileversion */
        for ( ; y < files_info->rows; )
        {
          index = files_info->columns * y;
          if (atol (data[index+i_catno]) != head->cat_no ||
              atol (data[index+i_itemnum]) != head->item_no)
            y++;
          else
          {
            break;
          }
        }
        /* */
        sprintf (sql_str, "%s f_%s %s %s '%s' %s %d %s %s",
                 "update", head->cat_name, "set n_couser='', n_codate=NULL,",
                 "n_fileco =", fileco_str,
                 "where n_itemnum =", head->item_no, "and n_fileversion =",
                 data[index+i_fileversion]);
  
        sprintf (fcat_name, "f_%s", head->cat_name);
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
          _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
          _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
          _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

      }
    }
  }
  else if (command == NFM_CHECK_IN)
  {
    /* these indexes are assigned based on _NFMbuild_working_buffer_format in
       NFMcheckin_set code for files_info */
    i_catno = 0; i_itemnum = 1; i_filenum = 4; i_fileversion =5;
    i_fileco = 7;
    /* checking files_info against NULL -- SSRS 24 jan 94 */
    if (files_info != NULL)
      {
    data = (char **) files_info->data_ptr;

    for (head=set_list, x = y = 0; x < frecords; x++, head = head->next)
    {
      index = files_info->columns * y;
      _NFMdebug ((fname, "x [%d] y [%d] item [%d] cat [%s] and type [%s]\n",
                   x, y, head->item_no, head->cat_name, head->type));
      if (!strcmp (head->type, "P") )
      {
        sprintf (fcat_name, "f_%s", head->cat_name);
        for (exec = 0 ; (y < files_info->rows) &&
                (atol(data[index+i_itemnum]) == head->item_no) &&
                (atol(data[index+i_catno]) == head->cat_no);      
                y ++, index = files_info->columns * y)
        {
          _NFMdebug ((fname, "item_num [%s] cat_no [%s]\n",
                      data[index+i_itemnum], data[index+i_catno]));
          if (!exec)
          {
            sprintf (sql_str1, "%s f_%s %s %s %s %d",

                     "delete from", head->cat_name, "where n_fileversion >",
                     data[index+i_fileversion], "and n_itemnum =",
                     head->item_no);
            exec = 1;
            status = NFMlock_table (fcat_name);
            if (status != NFM_S_SUCCESS)
              _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
          }
          sprintf (sql_str, "%s f_%s %s '%s'%s %d %s %s %s %s",
                 "update", head->cat_name, "set n_fileco =", 
                 data[index+i_fileco],
                 "where n_itemnum =", head->item_no, "and n_fileversion =",
                 data[index+i_fileversion], "and n_filenum =",
                 data[index+i_filenum] );
  
          sprintf (fcat_name, "f_%s", head->cat_name);
          _NFMdebug ((fname, "exec qry: %s\n", sql_str));
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
            _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
        }
        if (exec)
        {
          _NFMdebug ((fname, "exec qry: %s\n", sql_str1));
          status = SQLstmt (sql_str1);
          if (status != SQL_S_SUCCESS)
            _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
        }
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
          _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));
      }
    }
      }
  }

  if (command == NFM_CHECK_IN || command == NFM_CHECK_OUT)
  {
    /* null condition check added -- SSRS 20 jan 1994 */
    for (head=set_list, x = y = z = 0, head_lfm1 = lfm_list1, 
         head_lfm2 = lfm_list2; 
         x < lfm_records && head != NULL; head=head->next, x++)
    {
      /* COME BACK AND OPTIMIZE */
      if (head->move == NFM_NO_MOVE)
      {
        for (; atol((head_lfm2+z)->cat_no) == head->cat_no &&
               atol((head_lfm2+z)->item_no) == head->item_no; z ++ )
        {
          if ((lfm_list1+y)->action)
          {
            _NFMdebug ((fname, "n_ref --\n"));
            /** COME BACK AND FIX THIS AFTER MEETING **/
            sprintf (sql_str,
           "%s %d, %s '%s', %s '%s', %s %s %s %s %s %d %s %d %s %s %s %s %s '%s'",
            "update nfmsafiles set n_ref =", (lfm_list1+y)->ref --,
            "n_mountpoint =", (lfm_list1+y)->mountpoint,
            "n_nfs =", (lfm_list1+y)->nfs,
            "n_cisano =", (lfm_list1+y)->cisano,
            "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
            head->cat_no, "and n_itemno =", head->item_no,
            "and n_fileversion =", (lfm_list1+y)->fileversion,
            "and n_filenum =", (lfm_list1+y)->filenum,
            "and n_filename =", (lfm_list1+y)->filename);
            NFMlock_table ("nfmsafiles");
            status = SQLstmt (sql_str);
            if (status != SQL_S_SUCCESS)
              _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
            SQLstmt ("COMMIT WORK");
          } 
          else
          {
            _NFMdebug ((fname, "delete the record \n"));
            sprintf (sql_str,
             "%s %s %s %s %d %s %d %s %s %s %s %s '%s'",
             "delete from nfmsafiles ", 
             "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
             head->cat_no, "and n_itemno =", head->item_no,
             "and n_fileversion =", (lfm_list1+y)->fileversion,
             "and n_filenum =", (lfm_list1+y)->filenum,
             "and n_filename =", (lfm_list1+y)->filename);
             NFMlock_table ("nfmsafiles");
             status = SQLstmt (sql_str);
             if (status != SQL_S_SUCCESS)
               _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
             SQLstmt ("COMMIT WORK");
          }
        }
      }
      else
      {  
        /* is list1->action? Yes: ref--; No: delete the record */
        for  (; atol((head_lfm1+y)->cat_no) == head->cat_no &&
                atol((head_lfm1+y)->item_no) == head->item_no; y++ )
        {
          if (strcmp (head->type, "P"))
          {
            if ((lfm_list1+y)->action)
            {
              _NFMdebug ((fname, "n_ref --\n"));
              /** COME BACK AND FIX THIS AFTER MEETING **/
              sprintf (sql_str,
           "%s %d, %s '%s', %s '%s', %s %s %s %s %s %d %s %d %s %s %s %s %s '%s'",
               "update nfmsafiles set n_ref =", (lfm_list1+y)->ref --,
               "n_mountpoint =", (lfm_list1+y)->mountpoint,
               "n_nfs =", (lfm_list1+y)->nfs,
               "n_cisano =", (lfm_list1+y)->cisano,
               "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
               head->cat_no, "and n_itemno =", head->item_no,
               "and n_fileversion =", (lfm_list1+y)->fileversion,
               "and n_filenum =", (lfm_list1+y)->filenum,
               "and n_filename =", (lfm_list1+y)->filename);
               NFMlock_table ("nfmsafiles");
               status = SQLstmt (sql_str);
               if (status != SQL_S_SUCCESS)
                 _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
               SQLstmt ("COMMIT WORK");
            } 
            else
            {
              _NFMdebug ((fname, "delete the record \n"));
              sprintf (sql_str,
               "%s %s %s %s %d %s %d %s %s %s %s %s '%s'",
               "delete from nfmsafiles ", 
               "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
               head->cat_no, "and n_itemno =", head->item_no,
               "and n_fileversion =", (lfm_list1+y)->fileversion,
               "and n_filenum =", (lfm_list1+y)->filenum,
               "and n_filename =", (lfm_list1+y)->filename);
               NFMlock_table ("nfmsafiles");
               status = SQLstmt (sql_str);
               if (status != SQL_S_SUCCESS)
                 _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
               SQLstmt ("COMMIT WORK");
            }
          }
          else
          {
            if ((lfm_list1+y)->action)
            {
              _NFMdebug ((fname, "n_co = 'N'\n"));
              /** COME BACK AND FIX THIS AFTER MEETING **/
              sprintf (sql_str, "%s, %s '%s', %s '%s', %s %s \
                        %s %s %s %d %s %d %s %s %s %s %s '%s'",
               "update nfmsafiles set n_co = 'N' ", 
               "n_mountpoint =", (lfm_list1+y)->mountpoint,
               "n_nfs =", (lfm_list1+y)->nfs,
               "n_cisano =", (lfm_list1+y)->cisano,
               "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
               head->cat_no, "and n_itemno =", head->item_no,
               "and n_fileversion =", (lfm_list1+y)->fileversion,
               "and n_filenum =", (lfm_list1+y)->filenum,
               "and n_filename =", (lfm_list1+y)->filename);
               NFMlock_table ("nfmsafiles");
               status = SQLstmt (sql_str);
               if (status != SQL_S_SUCCESS)
                 _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
               SQLstmt ("COMMIT WORK");
            } 
            else
            {
              _NFMdebug ((fname, "delete the record \n"));
              sprintf (sql_str,
               "%s %s %s %s %d %s %d %s %s %s %s %s '%s'",
               "delete from nfmsafiles ", 
               "where n_sano =", (lfm_list1+y)->sano, "and n_catalogno =",
               head->cat_no, "and n_itemno =", head->item_no,
               "and n_fileversion =", (lfm_list1+y)->fileversion,
               "and n_filenum =", (lfm_list1+y)->filenum,
               "and n_filename =", (lfm_list1+y)->filename);
               NFMlock_table ("nfmsafiles");
               status = SQLstmt (sql_str);
               if (status != SQL_S_SUCCESS)
                 _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
               SQLstmt ("COMMIT WORK");
            }
          }
        }
      }
    }
  }
  else if (command == NFM_COPYFILES)
  {
    for (x = 0; x < lfm_records; x++)
    {
      if ((lfm_list1+x)->action == NFM_ADD_COPY)
      {
        _NFMdebug ((fname, "delete the rec sa[%s] cat[%s] item[%s] file[%s]\n",
                    (lfm_list1+x)->sano, (lfm_list1+x)->cat_no, 
                    (lfm_list1+x)->item_no, (lfm_list1+x)->filename));
        sprintf (sql_str, "%s %s %s %s %s %s %s '%s' %s %s",
                 "delete from nfmsafiles where n_sano =", 
                 (lfm_list1+x)->sano, "and n_catalogno =", 
                 (lfm_list1+x)->cat_no, "and n_itemno =",
                 (lfm_list1+x)->item_no, "and n_filename = ",
                 (lfm_list1+x)->filename, "and n_filenum = ",
                 (lfm_list1+x)->filenum);
        SQLstmt (sql_str);
      }
      else
      {
        if (strcmp ((lfm_list1+x)->copy, "Y"))
        {
          _NFMdebug ((fname, "clear n_copy sa[%s] cat[%s] item[%s] file[%s]\n",
                    (lfm_list1+x)->sano, (lfm_list1+x)->cat_no, 
                    (lfm_list1+x)->item_no, (lfm_list1+x)->filename));
          sprintf (sql_str, "%s %s %s %s %s %s %s '%s' %s %s",
                 "update nfmsafiles set n_copy = 'N' where n_sano =", 
                 (lfm_list1+x)->sano, "and n_catalogno =", 
                 (lfm_list1+x)->cat_no, "and n_itemno =",
                 (lfm_list1+x)->item_no, "and n_filename = ",
                 (lfm_list1+x)->filename, "and n_filenum = ",
                 (lfm_list1+x)->filenum);
          SQLstmt (sql_str);
        }
        else
        {
          _NFMdebug ((fname, "no need to clean sa[%s] cat[%s] n\
                         item[%s] file[%s]\n",
                    (lfm_list1+x)->sano, (lfm_list1+x)->cat_no, 
                    (lfm_list1+x)->item_no, (lfm_list1+x)->filename));
        }
      }
    }
  }
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMget_catalog_numbers (set_head, num_members)

struct NFMset_member *set_head;
long num_members;

{
  char *fname="NFMget_catalog_numbers";
  char sql_str[4096]; /* COME BACK LATER */
  char **data;
  char dumb_str[2];
  char cur_cat_name[NFM_CATALOGNAME+1];
  int x=0, y, index, or;
  long status;
  long dumb_value;
  MEMptr list=NULL;
  struct NFMset_member *cur_set, *begin_process;

  _NFMdebug ((fname, "ENTER: set_head addr[%ld] %d members\n",
              set_head, num_members))

  if (set_head->cat_no > 0)
  {
    for (cur_set = set_head->next; cur_set != (struct NFMset_member *) NULL; 
         cur_set = cur_set->next)
    {
      _NFMdebug ((fname, "x [%d]\n", x));
      if (!strcmp (cur_set->cat_name, set_head->cat_name))
        cur_set->cat_no = set_head->cat_no;
      else
        break;
    }
  }
  else
  {
    cur_set = set_head;
  }

  if (cur_set == (struct NFMset_member *) NULL)
  {
    _NFMdebug ((fname, 
                "EXIT: set & members in same catalog,  successful 0x%.8x\n", 
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }
  else
  {
    _NFMdebug ((fname, "begin set addr [%ld]\n",
                       cur_set));
    begin_process = cur_set;
  }

  strcpy (sql_str, "select n_catalogno, n_catalogname from nfmcatalogs where ");

  for (cur_cat_name[0]='\0', or = 0 ; cur_set != (struct NFMset_member *) NULL;
       cur_set = cur_set->next)
  {
    _NFMdebug ((fname, "cur_set->cat_name [%s]\n", 
                        cur_set->cat_name));
    if (strcmp(cur_set->cat_name, cur_cat_name))
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogname = '");
      strcat (sql_str, cur_set->cat_name);
      strcat (sql_str, "'");
      strcpy (cur_cat_name, cur_set->cat_name);
    }
  }

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));
  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (cur_set = begin_process, 
       strcpy (cur_cat_name, cur_set->cat_name); 
       cur_set != (struct NFMset_member *) NULL; )
     
  {
    _NFMdebug ((fname, "given cat_name = %s search...\n", cur_set->cat_name));
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;

      _NFMdebug ((fname, "row %d, cat_no: %s cat_name: %s\n",
                  y, data[index], data[index+1]));

      if (!strcmp(cur_set->cat_name, data[index+1]))
      {
        _NFMdebug ((fname, "Found match!\n"));
        break;
      }
    }   

    do 
    {
      cur_set->cat_no = atol(data[index]);
      _NFMdebug ((fname, "cat_no %d, cat_name %s\n",
                  cur_set->cat_no, cur_set->cat_name));
      cur_set = cur_set->next;
    }
    while ((cur_set != (struct NFMset_member *) NULL) && 
           !strcmp(cur_set->cat_name, cur_cat_name) );
  }
 
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (status);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x \n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
