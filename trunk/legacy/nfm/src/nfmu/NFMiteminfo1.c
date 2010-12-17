#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "ERR.h"

extern struct child_info *NFMchildren_list;
extern struct set_info1 *NFMset_list1;
extern struct attr_info1 *NFMcat_list;
extern struct attr_info1 *NFMend_cat_list;

long NFMget_item_data_def_and_values1 
     (table_no, ftable_no, cat_name, item_name, item_rev, new_set_info)

long table_no, ftable_no;
char *cat_name, *item_name, *item_rev;
struct set_info1 **new_set_info;

{
	/* THE FOLLOWING NEED TO BE REVISED */
  /***
  This function queries the n_name and n_datatype for n_itemname, n_itemrev,
  n_itemno, n_archivestate, n_coout, n_itemlock, n_versionlimit, n_itemnum,
  n_fileversion, n_cifilename, and n_fileclass,
  and it returns the information in item_info.

  This function ALSO queries the values for n_itemno, n_itemlock, n_archivestate
  n_coout, and n_versionlimit  for the item,
  and stores the information in item_info.

  Note: the item_info will be allocated in this function, the calling program 
        need to make sure to FREE item_info when it does not need item_info.

  CHANGE HISTORY:
    04/01/91 MFB creation
  ***/

  char   sql_str[1024];
  char   sub_str[300];
  char   **data;
  char   *fname="NFMget_item_data_def_and_values1";
  char   fcat_name[61];
  int    x, index;
  long   status;
  struct set_info1 *item_info;
  struct attr_info1 *attr_info;
  MEMptr list = NULL;
  long NFMprint_an_entry_of_linked_list1 ();

  _NFMdebug ( (fname, "ENTER: table %d & %d\n", table_no, ftable_no) );

  item_info = (struct set_info1 *) calloc (1, sizeof (struct set_info1));
  attr_info = (struct attr_info1 *) calloc (1, sizeof (struct attr_info1));

  strcpy (attr_info->table_name, cat_name);
  attr_info->ftable_no = ftable_no;
  attr_info->table_no = table_no;

  sprintf (sql_str,
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) %s %s %s %s %s ",
           "n_name, n_datatype", "nfmattributes",
           "n_tableno", table_no,
           "n_tableno", ftable_no,
           "AND (n_name = 'n_itemno' OR n_name = 'n_itemname' ",
           "OR n_name = 'n_itemrev' OR n_name = 'n_archivestate' ",
           "OR n_name = 'n_itemlock' OR n_name = 'n_versionlimit' ",
           "OR n_name = 'n_itemnum' OR n_name = 'n_fileversion' ",
           "OR n_name = 'n_cifilename' ) " );

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery: <0x%.8x> \n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (! strcmp (data[index], "n_itemno"))
    {
      strcpy (attr_info->itemno_n, data[index+0]);
      strcpy (attr_info->itemno_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemname"))
    {
      strcpy (attr_info->itemname_n, data[index+0]);
      strcpy (attr_info->itemname_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemrev"))
    {
      strcpy (attr_info->itemrev_n, data[index+0]);
      strcpy (attr_info->itemrev_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_archivestate"))
    {
      strcpy (attr_info->archivestate_n, data[index+0]);
      strcpy (attr_info->archivestate_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemlock"))
    {
      strcpy (attr_info->itemlock_n, data[index+0]);
      strcpy (attr_info->itemlock_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_versionlimit"))
    {
      strcpy (attr_info->versionlimit_n, data[index+0]);
      strcpy (attr_info->versionlimit_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemnum"))
    {
      strcpy (attr_info->itemnum_n, data[index+0]);
      strcpy (attr_info->itemnum_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_fileversion"))
    {
      strcpy (attr_info->fileversion_n, data[index+0]);
      strcpy (attr_info->fileversion_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_cifilename"))
    {
      strcpy (attr_info->cifilename_n, data[index+0]);
      strcpy (attr_info->cifilename_d,  data[index+1]);
    }
  }
   
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (attr_info);
    free (item_info);
    _NFMdebug ( (fname, "MEMclose: (list) <0x%.8x> \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }


  if (! strncmp (attr_info->itemname_d, "char", 4))
    sprintf (sub_str, "WHERE %s = '%s'",
                       attr_info->itemname_n, item_name);
  else
    sprintf (sub_str, "WHERE %s = %s",
                       attr_info->itemname_n, item_name);

  strcat (sub_str, " AND ");
  strcat (sub_str, attr_info->itemrev_n);
  strcat (sub_str, " = ");

  if (! strncmp (attr_info->itemrev_d, "char", 4))
  {
    strcat (sub_str, "'");
    strcat (sub_str, item_rev);
    strcat (sub_str, "'");
  }
  else
    strcat (sub_str, item_rev);
  sprintf (sql_str, "SELECT %s, %s, %s, %s, %s FROM %s %s",
           attr_info->itemno_n,
           attr_info->itemlock_n,
           attr_info->archivestate_n,
           "n_status",              /* n_coout is not expected to be changed */
           attr_info->versionlimit_n,
           cat_name, sub_str);

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }
 
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }
    
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "SQLquery <0x%.8x> \n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;

  if (strlen (data[0]))
    strcpy (item_info->itemno_v, data[0]);
  if (strlen (data[1]))
    strcpy (item_info->itemlock_v, data[1]);
  if (strlen (data[2]))
    strcpy (item_info->archivestate_v, data[2]);
  if (strlen (data[3]))
    strcpy (item_info->coout_v, data[3]);
  if (strlen (data[4]))
    strcpy (item_info->versionlimit_v, data[4]);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "MEMclose (list) 0x%.8x \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  sprintf (sql_str, "SELECT MAX(%s) FROM f_%s WHERE %s = %d ",
           attr_info->fileversion_n, cat_name,
           attr_info->itemnum_n, 
           atol(item_info->itemno_v)); 

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }

  sprintf (fcat_name, "f_%s", cat_name);
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n") );
    return (status);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery <0x%.8x> \n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;
  if (strlen (data[0]))
  {
    strcpy (item_info->fileversion_v, data[0]);
  }
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _NFMdebug ( (fname, "MEMclose (list) 0x%.8x \n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  if (NFMcat_list == (struct attr_info1 *) NULL)
  {
    NFMcat_list = NFMend_cat_list = attr_info;
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
  }
  else
  {
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
    NFMend_cat_list->next = attr_info;
    NFMend_cat_list = attr_info;
    NFMend_cat_list->next = (struct attr_info1 *) NULL;
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
  }
  
  item_info->table_no = table_no;
  *new_set_info = item_info;

  _NFMdebug ( (fname, "EXIT:  0x%.8x\n", NFM_S_SUCCESS) ); 
  return (NFM_S_SUCCESS);
}

long NFMget_items_data_def_values1 (cur_cat_no, cur_fcat_no,
                          cur_cat_name, item_no_list, item_num, 
                          head_set, end_set) 

long cur_cat_no, cur_fcat_no;
char *cur_cat_name;
long *item_no_list, item_num;
struct set_info1 **head_set, **end_set; 
                               /* o - the values of item(s) */

{
  /***
    This function is going to get values of n_itemno, n_archivestate, n_coout, 
    n_itemlock, n_versionlimit based on the list of item numbers passed in.
    It returns a pointer new_set_entry (linked list structure).

    Note: make sure new_set_entry is set to NULL before this function is called.

  ***/
  
  char **data;
  char sql_str[1024], *sql_str2;
  char *fname="NFMget_items_data_def_values1";
  char value[40], fcat_name[61];
  int  x, y, index;
  long status;
  struct set_info1 *head_new_set_entry=NULL, *end_new_set_entry=NULL;
  struct attr_info1 *attr_info;
  MEMptr list=NULL;

  _NFMdebug ( (fname, "ENTER: \n"));

  attr_info = (struct attr_info1 *) calloc (1, sizeof (struct attr_info1));

  attr_info->table_no = cur_cat_no;
  attr_info->ftable_no = cur_fcat_no;
  strcpy (attr_info->table_name, cur_cat_name);

  head_new_set_entry = (struct set_info1 *) calloc (item_num, 
                                    sizeof (struct set_info1) );
  if (head_new_set_entry == (struct set_info1 *) NULL)
  {
    _NFMdebug ( (fname, "failed to malloc new_set_entry"));
    return (NFM_E_MEM);
  }

  head_new_set_entry->consecutive = item_num;

  sprintf (sql_str,
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) %s %s %s %s %s ",
           "n_name, n_datatype", "nfmattributes",
           "n_tableno", cur_cat_no,
           "n_tableno", cur_fcat_no,
           "AND (n_name = 'n_itemno' OR n_name = 'n_itemname' ",
           "OR n_name = 'n_itemrev' OR n_name = 'n_archivestate' ",
           "OR n_name = 'n_itemlock' OR n_name = 'n_versionlimit' ",
           "OR n_name = 'n_itemnum' OR n_name = 'n_fileversion' ",
           "OR n_name = 'n_cifilename' ) " );

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery: <0x%.8x> \n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", status) );
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x ++)
  {
    index = x * list->columns;
    if (! strcmp (data[index], "n_itemno"))
    {
      strcpy (attr_info->itemno_n, data[index+0]);
      strcpy (attr_info->itemno_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemname"))
    {
      strcpy (attr_info->itemname_n, data[index+0]);
      strcpy (attr_info->itemname_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemrev"))
    {
      strcpy (attr_info->itemrev_n, data[index+0]);
      strcpy (attr_info->itemrev_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_archivestate"))
    {
      strcpy (attr_info->archivestate_n, data[index+0]);
      strcpy (attr_info->archivestate_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemlock"))
    {
      strcpy (attr_info->itemlock_n, data[index+0]);
      strcpy (attr_info->itemlock_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_versionlimit"))
    {
      strcpy (attr_info->versionlimit_n, data[index+0]);
      strcpy (attr_info->versionlimit_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemnum"))
    {
      strcpy (attr_info->itemnum_n, data[index+0]);
      strcpy (attr_info->itemnum_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_fileversion"))
    {
      strcpy (attr_info->fileversion_n, data[index+0]);
      strcpy (attr_info->fileversion_d, data[index+1]);
    }
    else if (! strcmp (data[index], "n_cifilename"))
    {
      strcpy (attr_info->cifilename_n, data[index+0]);
      strcpy (attr_info->cifilename_d,  data[index+1]);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose: 0x%.8x\n", status));
    return (status);
  }

  sql_str2 = (char *) malloc ((item_num * 50 + 300) * sizeof (char));
  if (sql_str2 == (char *) NULL)
  {
    _NFMdebug ((fname, "Malloc %d failed\n",
               (item_num*50+300)*sizeof (char)));
    return (NFM_E_MALLOC);
  }

  sprintf (sql_str2, "SELECT %s, %s, %s, %s, %s FROM %s WHERE %s = %d ",
           attr_info->itemno_n, "n_itemlock", 
           attr_info->archivestate_n, "n_status", attr_info->versionlimit_n,
           cur_cat_name, 
           attr_info->itemno_n, *item_no_list); 

  for (x = 1; x < item_num; x++)
  {
    strcat (sql_str2, "OR ");
    strcat (sql_str2, attr_info->itemno_n);
    strcat (sql_str2, " = ");
    sprintf (value, "%d", *(item_no_list +x));
    strcat (sql_str2, value);
  }
           
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str2);
    return (status);
  }

  status = NFMlock_table (cur_cat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str2);
    return (status);
  }

  status = SQLquery (sql_str2, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    free (sql_str2);
    return (status);
  }


  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str2);
    return (status);
  }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array (list) 0x%.8x\n", NFM_E_MEM) );
    free (sql_str2);
    return (NFM_E_MEM);
  }
  
  /*
  if (list->rows != item_num)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "Failed to get ALL the values of set and members") );
    return (NFM_E_BAD_ATTR_VALUE);
  }
  */


  data = (char **) list->data_ptr;
 
  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (strlen (data[index + 0]))
      strcpy ((head_new_set_entry+x)->itemno_v, data[index + 0]);
    if (strlen (data[index + 1]))
      strcpy ((head_new_set_entry+x)->itemlock_v, data[index + 1]);
    if (strlen (data[index + 2]))
      strcpy ((head_new_set_entry+x)->archivestate_v, data[index + 2]);
    if (strlen (data[index + 3]))
      strcpy ((head_new_set_entry+x)->coout_v, data[index + 3]);
    if (strlen (data[index + 4]))
      strcpy ((head_new_set_entry+x)->versionlimit_v, data[index + 4]);
    (head_new_set_entry+x)->table_no = cur_cat_no; 
    if (x < list->rows - 1)
      (head_new_set_entry + x)->next = (head_new_set_entry + x + 1);
  }

  end_new_set_entry = (head_new_set_entry + (list->rows - 1));

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose(list) 0x%.8x\n", status) );
    free (sql_str2);
    return (status);
  }
  
  sprintf (sql_str2, "SELECT %s, MAX(%s) FROM f_%s WHERE %s = %d ",
           attr_info->itemnum_n, attr_info->fileversion_n,
           cur_cat_name, attr_info->itemnum_n, *item_no_list);

  for (x = 1; x < item_num; x++)
  {
    strcat (sql_str2, "OR ");
    strcat (sql_str2, attr_info->itemnum_n);
    strcat (sql_str2, " = ");
    sprintf (value, "%d", *(item_no_list +x));
    strcat (sql_str2, value);
  }

  strcat (sql_str2, "GROUP BY ");
  strcat (sql_str2, attr_info->itemnum_n);

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str2);
    return (status);
  }

  sprintf (fcat_name, "f_%s", cur_cat_name);
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str2);
    return (status);
  }

  status = SQLquery (sql_str2, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    free (sql_str2);
    return (status);
  }

  free (sql_str2);

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array (list) 0x%.8x\n", NFM_E_MEM) );
    return (NFM_E_MEM);
  }

  /*
  if (list->rows != item_num)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "Failed to get ALL the max(f_ver) of set and mems") );
    return (NFM_E_BAD_ATTR_VALUE);
  }
  */

  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    _NFMdebug ( (fname, "x = %d, item num = %s, fileversion = %s\n",
                        x, data[index], data[index+1]) );
    for (y = 0; y < list->rows; y++)
    {
      if ( atol (data[index]) == 
           atol ((head_new_set_entry+y)->itemno_v))
      {
        _NFMdebug ( (fname, "Found match, y = %d itemno = %s \n", y,
                       (head_new_set_entry+y)->itemno_v));
        strcpy ((head_new_set_entry+y)->fileversion_v, data[index+1]);
        if (list->rows == item_num) /* temporary patch for speed */
          break;
      }
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose(list) 0x%.8x\n", status) );
    return (status);
  }

  *head_set = head_new_set_entry;
  *end_set = end_new_set_entry;
  if (NFMcat_list == (struct attr_info1 *) NULL)
  {
    NFMcat_list = NFMend_cat_list = attr_info;
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
  }
  else
  {
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
    NFMend_cat_list->next = attr_info;
    NFMend_cat_list = attr_info;
    NFMend_cat_list->next = (struct attr_info1 *) NULL;
    _NFMdebug ( (fname, "NFMcat_list [%ld], NFMend_cat_list [%ld] \n",
                 NFMcat_list, NFMend_cat_list) );
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", status) );
  return (NFM_S_SUCCESS);
}


long NFMprint_linked_list1 ()

{
  char *fname="NFMprint_linked_list1";
  int  index;
  struct set_info1 *head_set;
  struct attr_info1 *head_cat;
  struct child_info *head_child;   
  /* struct sto_info *head_sto; */
  long NFMprint_an_entry_of_linked_list1 ();

  _NFMdebug ( (fname, "ENTER: ..........................................\n"));

  _NFMdebug ( (fname, "NFMchildren_list\n"));
  for (head_child=NFMchildren_list; head_child != (struct child_info *) NULL;
       head_child=head_child->next)
    _NFMdebug 
   ((fname, "cat_no [%d],cat_name[%s],fcat_no [%d],item_no[%d],type [%s]\n\
            consecutive = [%d]\n",
            head_child->ccatalogno, head_child->cat_name,
            head_child->fcat_no, head_child->citemno, 
            head_child->type, head_child->consecutive) );

  for (head_set = NFMset_list1; head_set != (struct set_info1 *) NULL;
       head_set = head_set->next)
    NFMprint_an_entry_of_linked_list1 (head_set);
     
  for (head_cat = NFMcat_list; head_cat != (struct attr_info1 *) NULL;
       head_cat = head_cat->next)
    _NFMdebug ((fname, "attr def of cat_no [%d], fcat_no [%d]\n\
    \tcat_name [%s] n_itemno [%s] type [%s]\n\
    \tn_itemname [%s] type [%s]\n\
    \tn_itemrev [%s], type [%s]\n\
    \tn_archivestate [%s] type [%s]\n\
    \tn_itemlock [%s], type [%s]\n\
    \tn_versionlimit [%s] type [%s]\n\
    \tn_itemnum [%s], type [%s]\n\
    \tn_fileversion [%s], type [%s]\n\
    \tn_cifilename [%s] type [%s]\n",
    head_cat->table_no, head_cat->ftable_no, head_cat->table_name,
    head_cat->itemno_n, head_cat->itemno_d, head_cat->itemname_n, 
    head_cat->itemname_d, head_cat->itemrev_n, head_cat->itemrev_d,
    head_cat->archivestate_n, head_cat->archivestate_d, 
    head_cat->itemlock_n, head_cat->itemlock_d, 
    head_cat->versionlimit_n, head_cat->versionlimit_d, 
    head_cat->itemnum_n, head_cat->itemnum_d, 
    head_cat->fileversion_n, head_cat->fileversion_d, 
    head_cat->cifilename_n, head_cat->cifilename_d) );
  
  _NFMdebug ( (fname, "EXIT: ...........................................\n"));
  return (NFM_S_SUCCESS);
    
}

long NFMprint_an_entry_of_linked_list1 (set)
struct set_info1 *set;
{

  char *fname="NFMprint_an_entry_of_linked_list1";

  _NFMdebug ( (fname, "ENTER: *******************************\n"));

  _NFMdebug ( (fname, "cat_no [%d], citno [%d], type [%s],\n\
  \titemno [%s], itemname[%s], itemrev[%s]\n\
  \tarchivestate [%s], itemlock [%s], versionlimit[%s], fileclass [%s],\n\
  \tfileversion [%s], cifilename [%s], consecutive [%d]\n",
  set->table_no, set->citno, set->type,
  set->itemno_v, set->itemname_v, set->itemrev_v, 
  set->archivestate_v, set->itemlock_v, set->versionlimit_v, set->fileclass_v,
  set->fileversion_v, set->cifilename_v, set->consecutive));

  _NFMdebug ( (fname, "EXIT: ********************************\n"));
  return (NFM_S_SUCCESS);
}
