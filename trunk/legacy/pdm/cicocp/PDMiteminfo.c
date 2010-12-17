#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "PDMproto.h"

extern struct child_info *PDMchildren_list;
extern struct set_info1 *PDMassy_mem_list;
struct attr_info1 *PDMcat_list;
struct attr_info1 *PDMend_cat_list;

long PDMXget_item_data_def_and_values1 
     (table_no, ftable_no, cat_name, item_name, item_rev, new_set_info)

long table_no, ftable_no;
char *cat_name, *item_name, *item_rev;
struct set_info1 **new_set_info;

{
	/* THE FOLLOWING NEED TO BE REVISED */
  /***
  This function queries the n_name and n_datatype for n_itemname, n_itemrev,
  n_itemno, n_archivestate, n_status, n_itemlock, n_versionlimit, n_itemnum,
  n_fileversion, n_cifilename, and n_fileclass,
  and it returns the information in item_info.

  This function ALSO queries the values for n_itemno, n_itemlock, n_archivestate
  n_status, and n_versionlimit  for the item,
  and stores the information in item_info.

  Note: the item_info will be allocated in this function, the calling program 
        need to make sure to FREE item_info when it does not need item_info.

  CHANGE HISTORY:
    04/01/91 MFB creation
    10/09/91 Kumar  modification for faster checkin and checkout */

  char   sql_str[1024];
  char   **data;
  char   *fname="PDMXget_item_data_def_and_values1";
  char   fcat_name[61];
  long   status;
  struct set_info1 *item_info;
  struct attr_info1 *attr_info;
  MEMptr list = NULL;
  long NFMprint_an_entry_of_linked_list1 ();

  _PDMdebug  (fname, "ENTER: table %d & %d\n", table_no, ftable_no) ;

  item_info = (struct set_info1 *) calloc (1, sizeof (struct set_info1));
  attr_info = (struct attr_info1 *) calloc (1, sizeof (struct attr_info1));

  strcpy (attr_info->table_name, cat_name);
  attr_info->ftable_no = ftable_no;
  attr_info->table_no = table_no;
/*
  sprintf (sql_str,
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) %s %s %s %s %s ",
           "n_nfmname, n_name, n_datatype", "nfmattributes",
           "n_tableno", table_no,
           "n_tableno", ftable_no,
           "AND (n_nfmname = 'n_itemno' OR n_nfmname = 'n_itemname' ",
           "OR n_nfmname = 'n_itemrev' OR n_nfmname = 'n_archivestate' ",
           "OR n_nfmname = 'n_itemlock' OR n_nfmname = 'n_versionlimit' ",
           "OR n_nfmname = 'n_itemnum' OR n_nfmname = 'n_fileversion' ",
           "OR n_nfmname = 'n_cifilename' ) " );

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery: <0x%.8x> \n", NFM_E_SQL_QUERY) ;
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (! strcmp (data[index], "n_itemno"))
    {
      strcpy (attr_info->itemno_n, data[index+1]);
      strcpy (attr_info->itemno_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemname"))
    {
      strcpy (attr_info->itemname_n, data[index+1]);
      strcpy (attr_info->itemname_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemrev"))
    {
      strcpy (attr_info->itemrev_n, data[index+1]);
      strcpy (attr_info->itemrev_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_archivestate"))
    {
      strcpy (attr_info->archivestate_n, data[index+1]);
      strcpy (attr_info->archivestate_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemlock"))
    {
      strcpy (attr_info->itemlock_n, data[index+1]);
      strcpy (attr_info->itemlock_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_versionlimit"))
    {
      strcpy (attr_info->versionlimit_n, data[index+1]);
      strcpy (attr_info->versionlimit_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemnum"))
    {
      strcpy (attr_info->itemnum_n, data[index+1]);
      strcpy (attr_info->itemnum_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_fileversion"))
    {
      strcpy (attr_info->fileversion_n, data[index+1]);
      strcpy (attr_info->fileversion_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_cifilename"))
    {
      strcpy (attr_info->cifilename_n, data[index+1]);
      strcpy (attr_info->cifilename_d,  data[index+2]);
    }
  }
   
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (attr_info);
    free (item_info);
    _PDMdebug ( fname, "MEMclose: (list) <0x%.8x> \n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
*/
  sprintf (sql_str, "SELECT n_itemno,n_itemlock, n_archivestate, n_status,n_versionlimit FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", cat_name, item_name,item_rev);

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }
 
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }
    
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "SQLquery <0x%.8x> \n", NFM_E_SQL_QUERY );
    return (NFM_E_SQL_QUERY);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) ;
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
    _PDMdebug ( fname, "MEMclose (list) 0x%.8x \n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
   sql_str[0] = '\0';
  sprintf (sql_str, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d ",
            cat_name, atol(item_info->itemno_v)); 

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  sprintf (fcat_name, "f_%s", cat_name);
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _PDMdebug ( fname, "NFMlock_table 0x%.8x\n" );
    return (status);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery <0x%.8x> \n", NFM_E_SQL_QUERY );
    return (NFM_E_SQL_QUERY);
  }
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (item_info);
    free (attr_info);
    MEMclose (&list);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    free (item_info);
    free (attr_info);
    _PDMdebug ( fname, "MEMbuild_array (list) <0x%.8x> \n", NFM_E_MEM) ;
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
    _PDMdebug ( fname, "MEMclose (list) 0x%.8x \n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }

  if (PDMcat_list == (struct attr_info1 *) NULL)
  {
    PDMcat_list = PDMend_cat_list = attr_info;
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list) ;
  }
  else
  {
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list) ;
    PDMend_cat_list->next = attr_info;
    PDMend_cat_list = attr_info;
    PDMend_cat_list->next = (struct attr_info1 *) NULL;
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list );
  }
  
  item_info->table_no = table_no;
  *new_set_info = item_info;

  _PDMdebug ( fname, "EXIT:  0x%.8x\n", NFM_S_SUCCESS ); 
  return (NFM_S_SUCCESS);
}

long PDMXget_items_data_def_values1 (cur_cat_no, cur_fcat_no,
                          cur_cat_name, item_no_list, item_num, 
                          head_set, end_set) 

long cur_cat_no, cur_fcat_no;
char *cur_cat_name;
long *item_no_list, item_num;
struct set_info1 **head_set, **end_set; 
                               /* o - the values of item(s) */

{
  /***
    This function is going to get values of n_itemno, n_archivestate, n_status, 
    n_itemlock, n_versionlimit based on the list of item numbers passed in.
    It returns a pointer new_set_entry (linked list structure).

    Note: make sure new_set_entry is set to NULL before this function is called.

    CHANGE HISTORY:
      04/03/91 mfb creation.
  ***/
  
  char **data;
  char sql_str[1024];
  char *fname="PDMXget_items__data_def_values";
  char value[40], fcat_name[61];
  int  x, y, index;
  long status;
  struct set_info1 *head_new_set_entry=NULL, *end_new_set_entry=NULL;
  struct attr_info1 *attr_info;
  MEMptr list=NULL;

  _PDMdebug ( fname, "ENTER: \n");

  attr_info = (struct attr_info1 *) calloc (1, sizeof (struct attr_info1));

  attr_info->table_no = cur_cat_no;
  attr_info->ftable_no = cur_fcat_no;
  strcpy (attr_info->table_name, cur_cat_name);

  head_new_set_entry = (struct set_info1 *) calloc (item_num, item_num *
                                    sizeof (struct set_info1) );
  if (head_new_set_entry == (struct set_info1 *) NULL)
  {
    _PDMdebug ( fname, "failed to malloc new_set_entry");
    return (NFM_E_MEM);
  }

  head_new_set_entry->consecutive = item_num;
   /*

  sprintf (sql_str,
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) %s %s %s %s %s ",
           "n_nfmname, n_name, n_datatype", "nfmattributes",
           "n_tableno", cur_cat_no,
           "n_tableno", cur_fcat_no,
           "AND (n_nfmname = 'n_itemno' OR n_nfmname = 'n_itemname' ",
           "OR n_nfmname = 'n_itemrev' OR n_nfmname = 'n_archivestate' ",
           "OR n_nfmname = 'n_itemlock' OR n_nfmname = 'n_versionlimit' ",
           "OR n_nfmname = 'n_itemnum' OR n_nfmname = 'n_fileversion' ",
           "OR n_nfmname = 'n_cifilename' ) " );

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery: <0x%.8x> \n", NFM_E_SQL_QUERY );
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug ( fname, "MEMbuild_array 0x%.8x\n", status );
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x ++)
  {
    index = x * list->columns;
    if (! strcmp (data[index], "n_itemno"))
    {
      strcpy (attr_info->itemno_n, data[index+1]);
      strcpy (attr_info->itemno_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemname"))
    {
      strcpy (attr_info->itemname_n, data[index+1]);
      strcpy (attr_info->itemname_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemrev"))
    {
      strcpy (attr_info->itemrev_n, data[index+1]);
      strcpy (attr_info->itemrev_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_archivestate"))
    {
      strcpy (attr_info->archivestate_n, data[index+1]);
      strcpy (attr_info->archivestate_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemlock"))
    {
      strcpy (attr_info->itemlock_n, data[index+1]);
      strcpy (attr_info->itemlock_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_versionlimit"))
    {
      strcpy (attr_info->versionlimit_n, data[index+1]);
      strcpy (attr_info->versionlimit_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_itemnum"))
    {
      strcpy (attr_info->itemnum_n, data[index+1]);
      strcpy (attr_info->itemnum_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_fileversion"))
    {
      strcpy (attr_info->fileversion_n, data[index+1]);
      strcpy (attr_info->fileversion_d, data[index+2]);
    }
    else if (! strcmp (data[index], "n_cifilename"))
    {
      strcpy (attr_info->cifilename_n, data[index+1]);
      strcpy (attr_info->cifilename_d,  data[index+2]);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug ( fname, "MEMclose: 0x%.8x\n", status);
    return (status);
  }
*/
  sprintf (sql_str, "SELECT n_itemno, n_itemlock, n_archivestate, n_status, n_versionlimit FROM %s WHERE n_itemno = %d ",  cur_cat_name,  *(item_no_list)); 

  for (x = 1; x < item_num; x++)
  {
    strcat (sql_str, "OR n_itemno = ");
    sprintf (value, "%d", *(item_no_list +x));
    strcat (sql_str, value);
  }
           
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = NFMlock_table (cur_cat_name);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery 0x%.8x\n", status );
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
  
  /*
  if (list->rows != item_num)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "Failed to get ALL the values of set and members" );
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
    _PDMdebug ( fname, "MEMclose(list) 0x%.8x\n", status) ;
    return (status);
  }
  
  sprintf (sql_str, "SELECT n_itemnum, MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d ", cur_cat_name,*item_no_list);

  for (x = 1; x < item_num; x++)
  {
    strcat (sql_str, "OR n_itemnum = ");
    sprintf (value, "%d", *(item_no_list +x));
    strcat (sql_str, value);
  }

  strcat (sql_str, "GROUP BY n_itemnum");

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  sprintf (fcat_name, "f_%s", cur_cat_name);
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery 0x%.8x\n", status );
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }

  /*
  if (list->rows != item_num)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "Failed to get ALL the max(f_ver) of set and mems") ;
    return (NFM_E_BAD_ATTR_VALUE);
  }
  */

  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    _PDMdebug ( fname, "x = %d, item num = %s, fileversion = %s\n",
                        x, data[index], data[index+1] );
    for (y = 0; y < list->rows; y++)
    {
      if ( atol (data[index]) == 
           atol ((head_new_set_entry+y)->itemno_v))
      {
        _PDMdebug ( fname, "Found match, y = %d itemno = %s \n", y,
                       (head_new_set_entry+y)->itemno_v);
        strcpy ((head_new_set_entry+y)->fileversion_v, data[index+1]);
        if (list->rows == item_num) /* temporary patch for speed */
          break;
      }
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug ( fname, "MEMclose(list) 0x%.8x\n", status) ;
    return (status);
  }

  *head_set = head_new_set_entry;
  *end_set = end_new_set_entry;
  if (PDMcat_list == (struct attr_info1 *) NULL)
  {
    PDMcat_list = PDMend_cat_list = attr_info;
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list );
  }
  else
  {
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list );
    PDMend_cat_list->next = attr_info;
    PDMend_cat_list = attr_info;
    PDMend_cat_list->next = (struct attr_info1 *) NULL;
    _PDMdebug ( fname, "PDMcat_list [%ld], PDMend_cat_list [%ld] \n",
                 PDMcat_list, PDMend_cat_list );
  }

  _PDMdebug ( fname, "EXIT: 0x%.8x\n", status );
  return (NFM_S_SUCCESS);
}
