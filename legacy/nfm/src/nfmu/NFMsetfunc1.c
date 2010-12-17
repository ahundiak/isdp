#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMattr_def.h"
#include "ERR.h"
#include "NFMfile.h"

extern struct child_info *NFMchildren_list;
extern struct set_info1 *NFMset_list1;
extern struct attr_info1 *NFMcat_list;
extern struct sto_info *NFMsto_list;
extern struct sto_info *NFMend_sto_list;
extern struct sto_area_info STO_info;

extern int NFMset_members;
extern int ind_cat, ind_sta, ind_type, ind_itemno, ind_coout, ind_fileco;
extern int ind_cisa, ind_cifile, ind_cofile, ind_filetype, ind_set, ind_filever;
extern int ind_fileno, ind_level;



long NFMget_data_def1 (table_no, ftable_no, attr_list, data_list)

long    table_no, ftable_no;
MEMptr *attr_list, *data_list;

{
  /***
     This function will retrieve the attributes data definition of the 
     <catalog> and f_<catalog> from nfmattributes table.

  ***/

  /*** THIS FUNCTION NEEDS TO BE CLEANED UP BEFORE DELIVERY ****/

  char **column, **data, **format;
  char **column1, **data1;
  char sql_str[1024], row_str[1024], *buf_str;
  char *fname="NFMget_data_def1";
  int x, index;
  long status;
  MEMptr list=NULL;

  _NFMdebug ( (fname, "ENTER: cat_no = %d, fcat_no = %d\n", table_no,
                       ftable_no) );

  sprintf (sql_str, "%s%s%s%s%s%s%s%d%s%d%s%s",
           "SELECT ",
           "n_name, n_datatype, n_synonym, ",
           "n_application, n_read, n_write, n_update, n_delete, ",
           "n_null, n_checkin, n_checkout, n_seqno, n_attrno, ", 
           "n_tableno ",
           "FROM NFMATTRIBUTES ", 
           "WHERE (n_tableno = ", table_no, 
           " OR n_tableno = ", ftable_no, 
           ") AND (n_checkout = 'Y' or n_checkout = 'U') ",
           " AND (n_application = 'NFM') ORDER by n_seqno " ); 

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if (status != SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ( (fname, "SQLquery: 0x%.8x\n", NFM_E_BAD_ATTR_VALUE) );
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
         "Failed to retrieve information");
      return (NFM_E_BAD_ATTR_VALUE);
    }
    _NFMdebug ( (fname, "SQLquery: 0x%.8x\n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }
 
  /*MEMprint_buffer ("in NFMget_data_def, list ", list, 
                     "/usr2/nfmadmin/buffers");*/ /* del this b4 delivery */

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array: 0x%.8x\n", status) );
    return (NFM_E_MEM);
  }

  column = (char **) list->column_ptr;
  format = (char **) list->format_ptr;
  data = (char **) list->data_ptr;

  status = MEMopen (attr_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMopen (attr_list) 0x%.8x\n", status) );
    return (status);
  }

  for (x = 0; x < list->columns; x++)
  {
    status = MEMwrite_format (*attr_list, column[x], format[x]);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (attr_list);
      _NFMdebug ( (fname, "MEMwrite_format(attr_list): 0x%.8x\n", status));
      return (status);
    } 
  }

  /*MEMprint_buffer ("in _NFMget_item_data_def(columns), attr_list ", 
                    *attr_list, "/usr2/nfmadmin/buffers" );*/ /* del b4 deliver */

  MEMbuild_array (*attr_list);
  
  buf_str = (char *) malloc ( (*attr_list)->row_size);
  
  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_catalogname\1", "char(20)\1", "Catalog Name\1",
                    "NFM\1", "Y\1", "N\1", "N\1", 
                    "N\1", "N\1",  "N\1", "N\1", "0\1", "0\1", "0\1");

  status = MEMwrite (*attr_list, buf_str); 
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    _NFMdebug ( (fname, "MEMwrite (n_catalogname to attr_list) 0x%.8x\n",
                 status) );
    return (status);
  }

  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_level\1", "integer\1", "Level\1", 
                    "NFM\1", "N\1", "N\1", "N\1", "N\1", "N\1",  "N\1",
                    "N\1", "0\1", "0\1", "0\1"); 
  status = MEMwrite (*attr_list, buf_str); 
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    _NFMdebug ( (fname, "MEMwrite (n_level to attr_list) 0x%.8x\n",
                 status) );
    return (status);
  }

  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_citno\1", "integer\1", "Row No\1",
                    "NFM\1", "N\1", "N\1", "N\1", "N\1", "N\1", "N\1",
                    "N\1", "0\1", "0\1", "0\1");
  status = MEMwrite (*attr_list, buf_str);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    _NFMdebug ( (fname, "MEMwrite (n_citno to attr_list) 0x%.8x\n",
                 status) );
    return (status);
  }

  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_status1\1", "char(10)\1", "Status\1",
                    "NFM\1", "N\1", "N\1", "N\1", "N\1", "N\1", "N\1",
                    "N\1", "0\1", "0\1", "0\1");
  status = MEMwrite (*attr_list, buf_str);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    _NFMdebug ( (fname, "MEMwrite (n_status to attr_list) 0x%.8x\n",
                 status) );
    return (status);
  }

  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_type\1", "char(1)\1", "MEM Type\1",
                    "NFM\1", "Y\1", "N\1", "N\1", "N\1", "N\1", "N\1",
                    "N\1", "0\1", "0\1", "0\1"); 
  status = MEMwrite (*attr_list, buf_str);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    _NFMdebug ( (fname, "MEMwrite (n_type to attr_list) 0x%.8x\n",
                 status) );
    return (status);
  }

  /* MEMprint_buffer ("in NFMget_data_def, attr_list (columns and 5 data rows)", 
                    *attr_list, "/usr2/nfmadmin/buffers");*/ /*del this b4 deliv*/
  
  for (x = 0; x < list->rows; ++x)
  {
    index = x * list->columns;

      sprintf (row_str, 
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
               data[index], data[index+1], data[index+2],  
               data[index+3], data[index+4], data[index+5], data[index+6], 
               data[index+7],
               data[index+8], data[index+9], data[index+10], data[index+11], 
               data[index+12], data[index+13]);
      status = MEMwrite (*attr_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        /* MEMclose (&CAT_list); */
        _NFMdebug ( (fname, "MEMwrite (attr_list): 0x%.8x\n", status) );
        return (status);
      }
  }

  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    MEMclose (attr_list);
    /* MEMclose (&CAT_list); */
    _NFMdebug ( (fname, "MEMbuild_array (attr_list): 0x%.8x\n",
               NFM_E_MEM) );
    return (NFM_E_MEM);
  }
  
  column1 = (char **) (*attr_list) -> column_ptr;
  data1 = (char **) (*attr_list) -> data_ptr;

  sprintf (column1 [12], "%s", "n_listno");
  for (x = 5; x < (*attr_list) -> rows; ++x)
  {
    status = MEMwrite_data (*attr_list, "0", x + 1, 13);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (attr_list);
      /* MEMclose (&CAT_list); */
      _NFMdebug ( (fname, "MEMwrite_data (attr_list): 0x%.8x\n",
      status) );
      return (status);
    }
  }
  /*MEMprint_buffer ("in NFMget_data_def(columns, data), attr_list ", 
                    *attr_list, "/usr2/nfmadmin/buffers");*/ /* del b4 deliver */

  status = MEMopen (data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    /* MEMclose (&CAT_list); */
    MEMclose (&list);
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFMdebug ( (fname, "MEMopen (data_list): 0x%.8x\n", status) );
    return (status);
  }

  for (x = 0; x < (*attr_list) -> rows; ++x)
  {
    index = (*attr_list) -> columns * x;

    status = MEMwrite_format (*data_list,
             data1 [index + INDEX_N_NAME], data1 [index + INDEX_N_DATATYPE]);
    if (status != MEM_S_SUCCESS)
    {
      /* MEMclose (&CAT_list); */
      MEMclose (&list);
      MEMclose (attr_list);
      MEMclose (data_list);
      _NFMdebug ( (fname, "MEMwrite_formate: 0x%.8x\n", status) );
      return (status);
    }
  }
  /*MEMprint_buffer ("in _NFMget_item_data_def(columns), data_list ", 
                    *data_list, "/usr2/nfmadmin/buffers" );*/ /* del b4 deliver */

  _NFMdebug ( (fname, "EXIT: SSUCCESSFUL\n") );
  return (NFM_S_SUCCESS);
}

long NFMget_set_ci_files_info1 (head, quantity, attr_list, data_list)

struct set_info1 *head;
int    quantity;
MEMptr attr_list, data_list;

{

  char pre_str[1024], post_str[1024];
  char *sql_str;
  char **column, **data, **data1;
  char fcat_name[61], cat_name[61];
  char type[3], cit_no_str[40], level_str[20];
  char *fname="NFMget_set_ci_files_info1";
  char row_str[1024], tables[123];
  int comma, x, y, z, count, count1;
  int index_to_n_itemno=0;
  long cur_item_no, cur_cat_no;
  long status;
  struct set_info1 *current;
  struct attr_info1 *head_cat;
  MEMptr list=NULL;

  _NFMdebug ( (fname, "ENTER:\n"));
  sql_str = (char *) malloc ((quantity * 100 + 2048) * sizeof (char));
  if (sql_str == (char *) NULL)
  {
    _NFMdebug ((fname, "Malloc %d failed\n",
               (quantity*100+2048)*sizeof (char)));
    return (NFM_E_MALLOC);
  }

  current = head;
  _NFMdebug ( (fname, "current = %ld\n", current) );

  for (head_cat = NFMcat_list; head_cat != (struct attr_info1 *) NULL;
                               head_cat = head_cat->next)
  {
    _NFMdebug ( (fname, "head_cat->table_no [%d], current->table_no [%d]\n",
                         head_cat->table_no, current->table_no) );
    if (head_cat->table_no == current->table_no)
      break; 
  }

  if (head_cat == (struct attr_info1 *) NULL)
  {
    _NFMdebug ( (fname, "The linked list is corrupted, STOP\n") );
    free (sql_str);
    return (NFM_E_DATA);
  }

  sprintf (fcat_name, "f_%s", head_cat->table_name);
  strcpy (cat_name, head_cat->table_name);
  cur_cat_no = current->table_no;

  column = (char **) attr_list->column_ptr;
  data = (char **) attr_list->data_ptr;
          
  sprintf (pre_str, "SELECT ");
  comma = 0;
  
  for (x = 5; x < attr_list->rows; ++x)
  {
    count = attr_list->columns * x;
  
    _NFMdebug ( (fname, "data[count+INDEX_N_NAME] [%s], \n\
                 data[count+INDEX_N_NFMAPPLICATION] [%s] \n",
                 data[count + INDEX_N_NAME], 
                 data[count + INDEX_N_NFMAPPLICATION]) );

    if ( atol (data[count + INDEX_N_TABLENO]) == NFMcat_list->table_no )
    {
      if (! strcmp (data[count+INDEX_N_NAME], "n_itemno"))
      {
        index_to_n_itemno = x - 5;
        _NFMdebug ( (fname, "index_to_n_itemno = %d \n", 
                               index_to_n_itemno) );
      }
      if (comma)
        strcat (pre_str, ", ");
      else
        comma = 1;

      strcat (pre_str, cat_name);
      strcat (pre_str, ".");
      strcat (pre_str, data[count + INDEX_N_NAME]);
    }
    else if (!strcmp (data[count+INDEX_N_NFMAPPLICATION], "NFM") )
    {
      if (comma)
        strcat (pre_str, ",");
      else
        comma = 1;

      strcat (pre_str, fcat_name);
      strcat (pre_str, ".");
      strcat (pre_str, data[count + INDEX_N_NAME]);
    }
  }
  
  strcpy (post_str, cat_name);
  strcat (post_str, ".");
  strcat (post_str, head_cat->itemno_n);
  strcat (post_str, " = ");
  strcat (post_str, fcat_name);
  strcat (post_str, ".");
  strcat (post_str, head_cat->itemnum_n);

  sprintf (sql_str, "%s FROM %s, %s where ( (%s.%s = ",
                    pre_str, cat_name, fcat_name,
                    fcat_name, 
                    head_cat->itemnum_n);
  if (!strncmp(head_cat->itemnum_d, "char", 4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, current->itemno_v);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, current->itemno_v);

  strcat (sql_str, " AND ");
  strcat (sql_str, head_cat->fileversion_n);
  strcat (sql_str, " = ");
  if (!strncmp(head_cat->fileversion_d, "char", 4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, current->fileversion_v);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, current->fileversion_v);
  strcat (sql_str, ")");


  for (x = 1, current=current->next; x < quantity; x++, current=current->next)
  {
    strcat (sql_str, " OR ");
    strcat (sql_str, " ( ");
    strcat (sql_str, fcat_name);
    strcat (sql_str, ".");
    strcat (sql_str, head_cat->itemnum_n);
    strcat (sql_str, " = ");
   
    if (!strncmp(head_cat->itemnum_d, "char", 4))
    {
      strcat (sql_str, "'");
      strcat (sql_str, current->itemno_v);
      strcat (sql_str, "'");
    }
    else
      strcat (sql_str, current->itemno_v);

    strcat (sql_str, " AND ");
    strcat (sql_str, head_cat->fileversion_n);
    strcat (sql_str, " = ");
    if (!strncmp(head_cat->fileversion_d, "char", 4))
    {
      strcat (sql_str, "'");
      strcat (sql_str, current->fileversion_v);
      strcat (sql_str, "'");
    }
    else
      strcat (sql_str, current->fileversion_v);
    strcat (sql_str, ")");

  }

  strcat (sql_str, ") AND ");
  strcat (sql_str, fcat_name);
  strcat (sql_str, ".n_fileclass = 'C' AND ");

  strcat (sql_str, post_str);

  /*
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    return (status);
  }
  */

  sprintf (tables, "%s, %s", cat_name, fcat_name);
  status = NFMlock_table (tables);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n") );
    free (sql_str);
    return (status);
  }

  status = SQLquery (sql_str, &list, 2 * MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery: 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array: 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  data1 = (char **) list->data_ptr;
  /*
  MEMprint_buffers ("In NFMget_set_ci_files_info, list", list,
                     "/usr2/nfmadmin/buffers");
  */
  cur_item_no = -1;
  strcpy (type, "\0");
  strcpy (cit_no_str, "-1");
  strcpy (level_str, "-1");
  _NFMdebug ( (fname, "cur_item_no = %d, type [%s], cit_no [%s]\n",
                       cur_item_no, type, cit_no_str) );     
  for (x = 0; x < list->rows; x++)
  {
    count = list->columns * x;
    _NFMdebug ( (fname, "count = %d, index_to_n_itemno =%d\n", count,
                  index_to_n_itemno) );
    row_str[0]=0;
    _NFMdebug ( (fname, "row_str = %s \n", row_str) );

    _NFMdebug ( (fname, "cur_item_no = %d, data1[%d+%d] = %s\n",
                 cur_item_no, count, index_to_n_itemno, 
                 data1[count+index_to_n_itemno]) );
    if (cur_item_no != atol(data1[count+index_to_n_itemno]) )
    {
      for (current = head; current != (struct set_info1 *) NULL; 
           current = current->next)
      {
        _NFMdebug ( (fname, "current = %ld\n", current) );
        _NFMdebug ( (fname, "current->itemno_v = %d\n",
                     atol(current->itemno_v)) );

        if (atol (data1[count+index_to_n_itemno]) == 
            atol (current->itemno_v) )
        {
           _NFMdebug ( (fname, "Found Match %s = %s\n",
                        data1[count+index_to_n_itemno],
                        current->itemno_v) );
           strcpy (type, current->type);
           sprintf (cit_no_str, "%d",current->citno);
           sprintf (level_str, "%d",current->level);
           break;
        }
      }
      cur_item_no = atol(data1[count+index_to_n_itemno]) ;
    }

    _NFMdebug ( (fname, "cur_item_no = %d, type = %s, cit_no_str =%s\n",
                 cur_item_no, type, cit_no_str) );

    for (y = 0, z = 0; y < attr_list->rows; y++)
    {
      count1 = attr_list->columns * y;
      if (!strcmp (data[count1+INDEX_N_NAME], "n_catalogname") )
        strcat (row_str, cat_name);
      else if (!strcmp (data[count1+INDEX_N_NAME], "n_level") )
        strcat (row_str, level_str);
      else if (!strcmp (data[count1+INDEX_N_NAME], "n_citno") )
        strcat (row_str, cit_no_str);
      else if (!strcmp (data[count1+INDEX_N_NAME], "n_type") )
        strcat (row_str, type);
      else if (!strcmp (data[count1+INDEX_N_NAME], "n_status1") )
        strcat (row_str, "");
      else if (z < list->columns)
      {
        strcat (row_str, data1[count+z]);
        z++;
      }
      else 
      {
        strcat (row_str, "");
      }
      strcat (row_str, "\1");
    } 
    _NFMdebug ( (fname, "row_str = %s\n", row_str) );
    status = MEMwrite (data_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      _NFMdebug ( (fname, "MEMwrite: 0x%.8x\n", status) );
      free (sql_str);
      return (status);
    }
  }  

  free (sql_str);
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMclose: 0x%.8x\n", status) );
    return (status);
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long NFMcheck_and_update_items_status1 (head_set, quantity, type)

struct set_info1 *head_set;
int quantity, type;

{
  char *sql_str;
  char *fname="NFMcheck_and_update_items_status1";
  char **data;
  char co_str[3];
  int x, index;
  int  or;
  long status;
  MEMptr list=NULL;
  struct set_info1 *current;
  struct attr_info1 *head_cat;

  _NFMdebug ( (fname, "ENTER: type = %s\n", (type == NFM_SET_OUT)? 
                  "NFM_SET_OUT": "NFM_MEM_OUT") );
  
  current = head_set;
  for (head_cat = NFMcat_list; head_cat != (struct attr_info1 *) NULL;
                               head_cat = head_cat->next)
    if (head_cat->table_no == current->table_no)
      break;

  if (head_cat == (struct attr_info1 *) NULL)
  {
    _NFMdebug ( (fname, "The linked list is corrupted, STOP\n") );
    return (NFM_E_DATA);
  }

  sql_str = (char *) malloc ((quantity * 20 + 300) * sizeof (char)); 
  if (sql_str == (char *) NULL)
  {
    _NFMdebug ((fname, "Malloc %d failed\n",
                (quantity*20+300)*sizeof(char)));
    return (NFM_E_MALLOC);
  }

  sprintf (sql_str, "SELECT %s, %s, %s, %s, %s, %s, %s FROM %s, f_%s", 
                    head_cat->itemno_n,
                    head_cat->itemlock_n,
                    head_cat->archivestate_n,
                    "n_status",
                    head_cat->itemname_n,
                    head_cat->itemrev_n,
                    "n_pendingflag",
                    head_cat->table_name, head_cat->table_name);
  
  or =0;
  for (x = 0; x < quantity; x++, current = current->next)
  {
    if (! strcmp (current->type, "P"))
    {
    if (or)
      strcat (sql_str, " OR ");
    else
    {
      strcat (sql_str, " WHERE (");
      strcat (sql_str, head_cat->itemnum_n);
      strcat (sql_str, " = ");
      strcat (sql_str, head_cat->itemno_n);
      strcat (sql_str, ") AND  (");
      or = 1;
    }
    strcat (sql_str, head_cat->itemnum_n);
    strcat (sql_str, " = ");
    if (!strncmp (head_cat->itemnum_d, "char", 4) )
    {
      strcat (sql_str, "'");
      strcat (sql_str, current->itemno_v);
      strcat (sql_str, "'");
    }
    else
      strcat (sql_str, current->itemno_v);
    }
  }
  strcat (sql_str, ")");

  if ( !or )
  {
    _NFMdebug ((fname, "Not primary member(s), no need to proceed to chk sta"));
    free (sql_str);
    return (NFM_E_NOT_PRIMARY_MEMBERS);
  }

  status = NFMlock_table (head_cat->table_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str);
    return (status);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMdebug ( (fname, "SQLquery: 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", status ) );
    free (sql_str);
    return (status);
  }

  data = (char **) list->data_ptr;

  if (type == NFM_MEM_OUT)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (! strcmp(data[index+1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _NFMdebug ( (fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index+1]) );
        free (sql_str);
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index+2]) && strcmp (data[index+2], "B") )
      {
        _NFMload_message (data[index+4], data[index+5], 1, data[index+2]); 
        _NFMdebug ( (fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index+2]) );
        free (sql_str);
        return (NFM_E_MEM_FLAGGED);
      }
      if ( strlen(data[index+3]) && strcmp (data[index+3],"I") )
      {
        _NFMload_message (data[index+4], data[index+5], 5, data[index+3]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+3]) );
        free (sql_str);
        return (NFM_E_MEM_NOT_READY_OUT);
      }
      if ( strlen(data[index+6]) )
      {
        _NFMload_message (data[index+4], data[index+5], 1, data[index+6]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+6]) );
        free (sql_str);
        return (NFM_E_MEM_FLAGGED);
      }
    }
    strcpy (co_str, "TO");
  }
  else if (type == NFM_SET_OUT)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (!  strcmp(data[index+1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_SET_LOCKED, "", NULL);
        _NFMdebug ( (fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index+1]) );
        free (sql_str);
        return (NFM_E_SET_LOCKED);
      }
      if ( strlen(data[index+2]) && strcmp (data[index+2], "B") )
      {
        _NFMload_message (data[index+4], data[index+5], 1, data[index+2]); 
        _NFMdebug ( (fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index+2]) );
        free (sql_str);
        return (NFM_E_SET_FLAGGED);
      }
      if ( strlen(data[index+3]) && strcmp (data[index+3],"I") )
      {
        _NFMload_message (data[index+4], data[index+5], 6, data[index+3]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+3]) );
        free (sql_str);
        return (NFM_E_SET_NOT_READY_OUT);
      }
      if ( strlen(data[index+6]) )
      {
        _NFMload_message (data[index+4], data[index+5], 1, data[index+6]); 
        _NFMdebug ( (fname, "item %s, n_pending = %s\n",
                            data[index], data[index+6]) );
        free (sql_str);
        return (NFM_E_SET_FLAGGED);
      }
    }
    strcpy (co_str, "TO");
  }
  else if ( (type == NFM_MEM_COPY) || (type == NFM_SET_COPY))
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (! strcmp(data[index+1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _NFMdebug ( (fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index+1]) );
        free (sql_str);
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index+2]) && strcmp (data[index+2], "B") )
      {
        _NFMload_message (data[index+4], data[index+5], 2, data[index+2]); 
        _NFMdebug ( (fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index+2]) );
        free (sql_str);
        return (NFM_E_MEM_FLAGGED);
      }
      if ( strlen(data[index+3]) && strcmp (data[index+3],"I") &&
           strcmp (data[index+3], "O")&& strcmp (data[index+3], "S")&&
           strcmp (data[index+3], "M")&& strcmp (data[index+3], "SN")&&
           strcmp (data[index+3], "MN")&& strcmp (data[index+3], "TO") ) 
      {
        _NFMload_message (data[index+4], data[index+5], 2, data[index+3]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+3]) );
        free (sql_str);
        return (NFM_E_MEM_NOT_READY_OUT);
      }
      if ( strlen(data[index+6]) )
      {
        _NFMload_message (data[index+4], data[index+5], 2, data[index+6]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+6]) );
        free (sql_str);
        return (NFM_E_MEM_FLAGGED);
      }
    }
  }
  else if (type == NFM_MEM_IN)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (! strcmp(data[index+1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _NFMdebug ( (fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index+1]) );
        free (sql_str);
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index+2]) && strcmp (data[index+2], "B") )
      {
        _NFMload_message (data[index+4], data[index+5], 0, data[index+2]); 
        _NFMdebug ( (fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index+2]) );
        free (sql_str);
        return (NFM_E_MEM_FLAGGED);
      }
      if ( strlen(data[index+3]) && strcmp (data[index+3],"M") &&
           strcmp (data[index+3], "MN") )
      {
        _NFMload_message (data[index+4], data[index+5], 3, data[index+3]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+3]) );
        free (sql_str);
        return (NFM_E_MEM_NOT_READY_IN);
      }
    }
    strcpy (co_str, "TI");
  }
  else if (type == NFM_SET_IN)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (!  strcmp(data[index+1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_SET_LOCKED, "", NULL);
        _NFMdebug ( (fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index+1]) );
        free (sql_str);
        return (NFM_E_SET_LOCKED);
      }
      if ( strlen(data[index+2]) && strcmp (data[index+2], "B") )
      {
        _NFMload_message (data[index+4], data[index+5], 0, data[index+2]); 
        _NFMdebug ( (fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index+2]) );
        free (sql_str);
        return (NFM_E_SET_FLAGGED);
      }
      if ( strlen(data[index+3]) && strcmp (data[index+3],"S") &&
           strcmp (data[index+3], "SN") )
      {
        _NFMload_message (data[index+4], data[index+5], 4, data[index+3]); 
        _NFMdebug ( (fname, "item %s, n_status = %s\n",
                            data[index], data[index+3]) );
        free (sql_str);
        return (NFM_E_SET_NOT_READY_IN);
      }
    }
    strcpy (co_str, "TI");
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ( (fname, "MEMclose: 0x%.8x\n", NFM_E_MEM));
    free (sql_str);
    return (NFM_E_MEM);
  }

  if ( (type == NFM_SET_COPY) || (type == NFM_MEM_COPY) )
  {
    _NFMdebug ( (fname, "No need to update n_status flag\n") );
    free (sql_str);
    return (NFM_S_SUCCESS);
  } 

  current = head_set;

  sprintf (sql_str, "UPDATE %s SET n_status = '%s' ", 
                    head_cat->table_name, co_str);
  
  or =0;
  for (x = 0; x < quantity; x++, current = current->next)
  {
    if ( !strcmp (current->type, "P"))
    {
    if (or)
      strcat (sql_str, " OR ");
    else
    {
      strcat (sql_str, " WHERE ");
      or = 1;
    }
    strcat (sql_str, head_cat->itemno_n);
    strcat (sql_str, " = ");
    if (!strncmp (head_cat->itemno_d, "char", 4) )
    {
      strcat (sql_str, "'");
      strcat (sql_str, current->itemno_v);
      strcat (sql_str, "'");

    }
    else
      strcat (sql_str, current->itemno_v);
    }
  }

  if ( !or )
  {
    _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
    free (sql_str);
    return (NFM_S_SUCCESS);
  }

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    free (sql_str);
    return (NFM_E_SQL_QUERY);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
    free (sql_str);
    return (status);
  }

  free(sql_str);
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}


long NFMget_co_set_files (user_id, attr_list, data_list, file_list)

long    user_id;
MEMptr  attr_list, data_list, file_list;

{

  char row_str[1024];
  char **data, **data1;
  char file_cat[61], cur_cat_name[61];
  char *fname="NFMget_co_set_files";
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  char file_type[3], file_name[20];   
  int x, count, found;
  long status;
  struct attr_info1 *cur_cat;
  struct sto_info *cur_sto, *new_sto;

  _NFMdebug ( (fname, "ENTER:\n"));

  data   = (char **) attr_list -> data_ptr;
  data1  = (char **) data_list -> data_ptr;

  for (x = 0; x < attr_list -> rows; ++x)
  { 
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_catalogname")) 
      ind_cat = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status1")) 
      ind_sta = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_type")) 
      ind_type = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_colevel")) 
      ind_level = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      ind_itemno = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
      ind_coout = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
      ind_fileno = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
      ind_fileco = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileversion"))
      ind_filever = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cisano"))
      ind_cisa = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilename"))
      ind_cifile = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
      ind_cofile = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_filetype"))
      ind_filetype = x;
    else if (! strcmp (data [count + INDEX_N_NAME],"n_setindicator"))
      ind_set  = x;
  }

  strcpy (cur_cat_name, data1[ind_cat]);

  sprintf (file_cat, "f_%s", data1[ind_cat]);
  
  /* the 1st entry of storage area linked list */

  NFMsto_list = (struct sto_info *) calloc (1, sizeof (struct sto_info));
  NFMend_sto_list = NFMsto_list;
  memcpy (&(NFMsto_list->info), &(STO_info), sizeof (STO_info));

  for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
       cur_cat=cur_cat->next)
  if ( !strcmp (cur_cat->table_name, data1[ind_cat]))
    break;

  for (x = 0; x < data_list->rows; ++x)
  {
    count = data_list -> columns * x;

    if (strcmp (cur_cat_name, data1[count+ind_cat]))
    {
      strcpy (cur_cat_name, data1[count+ind_cat]);

      sprintf (file_cat, "f_%s", data1[count+ind_cat]);
      for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
           cur_cat=cur_cat->next)
        if ( !strcmp (cur_cat->table_name, cur_cat_name))
          break;

    }
      
    found = 0;
    if ( !strcmp (data1[count+ind_set],"Y") &&
        (!strcmp (data1[count+ind_coout],"") ) )
    {
      found = 1;
      strcpy (node_name, "");
      strcpy (user_name, "");
      strcpy (passwd, "");
      strcpy (path_name, "");
      strcpy (device_type, "");
      strcpy (mach_id, "");
      strcpy (op_sys, "");
      strcpy (net_tcp, "");
      strcpy (net_xns, "");
      strcpy (net_dec, "");
    }

    for (cur_sto=NFMsto_list; (cur_sto != (struct sto_info *) NULL) && !found;
         cur_sto=cur_sto->next)
    {
      _NFMdebug ( (fname, "sano [%d] of linked list, item's cisano  %s\n",
                   cur_sto->info.sano, data1[count+ind_cisa]) );
      if (cur_sto->info.sano == atol (data1[count+ind_cisa]))
      {
        found = 1;
        strcpy (node_name, cur_sto->info.nodename);
        strcpy (user_name, cur_sto->info.username);
        strcpy (passwd, cur_sto->info.passwd);
        strcpy (path_name, cur_sto->info.pathname);
        strcpy (device_type, cur_sto->info.devicetype);
        strcpy (mach_id, cur_sto->info.machid);
        strcpy (op_sys, cur_sto->info.opsys);
        strcpy (net_tcp, cur_sto->info.tcpip);
        strcpy (net_xns, cur_sto->info.xns);
        strcpy (net_dec, cur_sto->info.decnet);
      }
    }

    if (! found)
    {
      status = NFMget_sa_no_info (user_id,
                atol (data1 [count + ind_cisa]),
                node_name, user_name, passwd, path_name, device_type,
                mach_id, op_sys, net_tcp, net_xns, net_dec);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMget_sa_no_info 0x%.8x\n", status) );
        return (status);        
      }
      /***  add an entry to NFMsto_list  ***/

      new_sto = (struct sto_info *) calloc (1, sizeof (struct sto_info));
      new_sto->info.sano = atol (data1[count+ind_cisa]);
      strcpy (new_sto->info.nodename, node_name);
      strcpy (new_sto->info.username, user_name);
      strcpy (new_sto->info.passwd, passwd);
      strcpy (new_sto->info.pathname, path_name);
      strcpy (new_sto->info.devicetype, device_type);
      strcpy (new_sto->info.machid, mach_id);
      strcpy (new_sto->info.opsys, op_sys);
      strcpy (new_sto->info.tcpip, net_tcp);
      strcpy (new_sto->info.xns, net_xns);
      strcpy (new_sto->info.decnet, net_dec);
    
      NFMend_sto_list->next = new_sto;
      NFMend_sto_list = new_sto;
    }

    strcpy (file_type, data1[count + ind_filetype]);
        
    NFMchange_case (data1 [count + ind_sta], 0);

    sprintf (row_str, "%s\1", data1[count+ind_fileno]);
    strcat (row_str, data1 [count + ind_cisa]); strcat (row_str, "\1");
    strcat (row_str, node_name); strcat (row_str, "\1");
    strcat (row_str, user_name); strcat (row_str, "\1");
    strcat (row_str, passwd); strcat (row_str, "\1");
    strcat (row_str, path_name); strcat (row_str, "\1");
    strcat (row_str, device_type); strcat (row_str, "\1");
    strcat (row_str, mach_id); strcat (row_str, "\1");
    strcat (row_str, op_sys); strcat (row_str, "\1");
    strcat (row_str, net_tcp); strcat (row_str, "\1");
    strcat (row_str, net_xns); strcat (row_str, "\1");
    strcat (row_str, net_dec); strcat (row_str, "\1");

    if (!strcmp (data1[count+ind_fileco], "N") || 
        !strlen (data1[count+ind_coout]) ||
        !strcmp (data1[count+ind_coout], "SN") ||
        !strcmp (data1[count+ind_coout], "MN"))
    {
      strcat (row_str, data1[count + ind_cifile]);
      strcat (row_str, "\1");
      strcat (row_str, data1 [count + ind_cofile]);
      strcat (row_str, "\1");
      strcat (row_str, file_type); strcat (row_str, "\1");
      strcat (row_str, ""); strcat (row_str, "\1");
      strcat (row_str, "none");
    }
    else
    {
      if (strlen (data1 [count + ind_cifile]))
        strcat (row_str, data1 [count + ind_cifile]);
      else 
      {
        status = NFMget_file_name (user_id, cur_cat->table_no,
                               atol(data1[count+ind_fileno]), file_name);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ( (fname, "NFMget_file_name 0x%.8x\n", status));
          return (status);
        }
        strcat (row_str, file_name);
      }
      strcat (row_str, "\1");
      strcat (row_str, data1 [count + ind_cofile]);
      strcat (row_str, "\1");
      strcat (row_str, file_type); strcat (row_str, "\1");
      strcat (row_str, "-1"); strcat (row_str, "\1");
      strcat (row_str, "move");
      strcat (row_str, "\1");
    }

    _NFMdebug ( (fname, "row_str = %s \n", row_str) );
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "MEMwrite 0x%.8x\n", NFM_E_MEM) );
      return (NFM_E_MEM);      
    }           
  }

     
  _NFMdebug ( (fname, "EXIT: 0x%.8x \n",NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);    
}

long NFMupd_co_set_cat_fcat (user_id, c_user, c_datetime, sa_no,
                             attr_list, data_list, file_list)
long      user_id;
char      *c_user, *c_datetime;
long      sa_no;
MEMptr    attr_list, data_list, file_list;
{
  long     status;
  char  *fname="NFMupd_co_set_cat_fcat";
  char     fcat_name [61], cur_cat_name[61];
  char     **column, **data, **data1;
  char     **column2, **data2;
  long     x, y;
  long ftable_no;
  long     count, count1, count2;
  long     comma, update;
  long     i, j, k=0;
  char     sql_str[1024], sql_str1 [1024], value [50];

  _NFMdebug ( (fname, "ENTER: user_id = %ld\n", user_id));

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", status) );
    return (NFM_E_MEM);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1   = (char **) data_list -> data_ptr;

  column2 = (char **) file_list -> column_ptr;
  data2   = (char **) file_list -> data_ptr;


  for (y = 0; y < file_list -> columns; ++y)
  {
    if (! strcmp (column2 [y], "n_fileno"))      i = y;
    else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
    else if (! strcmp (column2 [y], "n_status"))      k = y;
  }

  ftable_no = -1;
  strcpy (cur_cat_name, "\0");

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    return (status);
  }
   
  for (x = 0; x < data_list->rows; ++x)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;

    if (strcmp (data1[count1+ind_type], "P"))
    {
      _NFMdebug ( (fname, "It is not a primary member\n") );
      continue;
    }
 
    comma = 0;
    sql_str  [0] = 0; sql_str1 [0] = 0;

    sprintf (sql_str,  "UPDATE f_%s SET ", data1[count1+ind_cat]);
    sprintf (sql_str1, " WHERE ");

    /*
    if (strcmp (data2 [count2 + k], "none"))
    { */
      for (y = 0; y < attr_list -> rows; ++y)
      {
        count = attr_list -> columns * y;
        update = 0;

        if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
        {
          strcat (sql_str1, data [count+INDEX_N_NAME]);
          strcat (sql_str1, " = ");
 
          if (! strncmp (data [count+INDEX_N_DATATYPE], "char", 4))
          {
            strcat (sql_str1, "'");
            strcat (sql_str1, data1 [count1 + ind_fileno]);
            strcat (sql_str1, "'");
          }
          else
            strcat (sql_str1, data1 [count1 + ind_fileno]);
        }
        else if (! strcmp (data [count + INDEX_N_NAME], "n_couser"))
        {
          sprintf (value, "%s", c_user);
          update = 1;
        }
        else if (! strcmp (data [count + INDEX_N_NAME], "n_codate"))
        {
          sprintf (value, "timestamp '%s'", c_datetime);
          update = 1;
        }
        /*
        else if (! strcmp (data [count + INDEX_N_NAME], "n_cotime"))
        {
          sprintf (value, "%s", c_time);
          update = 1;
        }
        */
        else if (! strcmp (data [count + INDEX_N_NAME], "n_cosano"))
        {
          sprintf (value, "%d", sa_no);
          update = 1;
        }
        else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
        {
          sprintf (value, "%s", data1 [count1 + y]);
          update = 1;
        }
        else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
        {
          if (strcmp (data2 [count2 + k], "none"))
            sprintf (value, "%s", "Y");
          else
            sprintf (value, "%s", "");
          update = 1;
        }
        else if (! strcmp (data [count + INDEX_N_NAME], "n_cocomment"))
        {
          sprintf (value, "%s", data1 [count1 + y]);
          update = 1;
        }

        if (update)
        {
          if (comma) strcat (sql_str, ", ");
          comma = 1;

          strcat (sql_str, data [count + INDEX_N_NAME]);
          strcat (sql_str, " = ");
    
          if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
          {
            strcat (sql_str, "'");
            strcat (sql_str, value);
            strcat (sql_str, "'");
          }
          else
          {
            if (! strlen (value))
              strcat (sql_str, "null");
            else
              strcat (sql_str, value);
          }
        }
      }

      strcat (sql_str, sql_str1);

      sprintf (fcat_name,  "f_%s", data1[count1+ind_cat]);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
        return (status);
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
        return (NFM_E_SQL_STMT);
      }
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
        return (status);
      }
   
    /* } */
  }

  for (x = 0; x < data_list->rows; x++)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;

    if (strcmp (data1[count1+ind_type], "P") )
    {
      _NFMdebug ( (fname, "It is not a primary member\n"));
      continue;
    }
 
    comma = 0; update = 0;

    sprintf (sql_str,  "UPDATE %s SET ", data1[count1+ind_cat]);
    sprintf (sql_str1, " WHERE ");

    for (y = 0; y < attr_list -> rows; ++y)
    {
      count = attr_list -> columns * y;

      if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      {
        strcat (sql_str1, data [count + INDEX_N_NAME]);
        strcat (sql_str1, " = ");

        if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
        { 
          strcat (sql_str1, "'");
          strcat (sql_str1, data1 [count1 + ind_fileno]);
          strcat (sql_str1, "'");
        }
        else
          strcat (sql_str1, data1 [count1 + y]);
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
      {
        if (comma) strcat (sql_str, ", ");
        else comma = 1;
   
        strcat (sql_str, data [count + INDEX_N_NAME]);
        strcat (sql_str, " = ");
   
        strcat (sql_str, "'");
        if ( (atol (data1[count1+ind_itemno]) == atol (NFMset_list1->itemno_v))
            && (! strcmp (data1[count1+ind_cat], NFMcat_list->table_name) ) )
          if (strlen (data1[count1+ind_coout]) )
            strcat (sql_str, "S");
          else
            strcat (sql_str, "SN");
        else if (strlen (data1[count1+ind_coout]) )
            strcat (sql_str, "M");
          else
            strcat (sql_str, "MN");
        strcat (sql_str, "'");
      }
    }

    strcat (sql_str, sql_str1);

    status = NFMlock_table (data1[count1+ind_cat]);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
      return (status);
    }

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (NFM_E_SQL_STMT);
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
      return (status);
    }
  }
 
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}

long NFMset_colevel (cat_name, item_no, level, attr_list)
char *cat_name;
long *item_no;
char *level;
MEMptr attr_list;
{
  char *fname="NFMset_colevel";
  char sql_str[126], value[50];
  char **data;
  long status;

  _NFMdebug ( (fname, "ENTER: catalog [%s] item_no [%d] set to level [%s]\n",
                       cat_name, item_no, level) );

  data   = (char **) attr_list -> data_ptr;

  sprintf (value, "%d", item_no);
  sprintf (sql_str, "UPDATE %s SET %s = %s WHERE %s = ",
                 cat_name, data[attr_list->columns * ind_level+ INDEX_N_NAME],
                 level, data[attr_list->columns * ind_itemno + INDEX_N_NAME]);
  if (!strncmp(data[attr_list->columns*ind_itemno + INDEX_N_DATATYPE],"char",4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, value);
    strcat (sql_str, "'");
  }
  else   
    strcat (sql_str, value);
    
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
    return (status);
  }

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (NFM_E_SQL_STMT);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    return (status);
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
