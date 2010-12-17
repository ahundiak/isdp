#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "ERR.h"
#include "PDMproto.h"
#include "NFMfile.h"

extern PDMpart_ptr PDMpart;
extern struct child_info *PDMchildren_list;
extern struct set_info1 *PDMassy_mem_list1;
extern struct attr_info1 *PDMcat_list;
extern struct sto_info *PDMsto_list;
extern struct sto_info *NFMend_sto_list;
extern struct sto_area_info STO_info;

extern char PDM_DEBUG_FILE[];
extern int	PDMdebug_on;


extern int PDMset_members;
extern int ind_cat, ind_sta, ind_type, ind_itemno, ind_coout, ind_fileco;
extern int ind_cisa, ind_cifile, ind_cofile, ind_filetype, ind_set, ind_filever;
extern int ind_fileno, ind_level;


long PDMXget_set_ci_files_info1 (head, quantity, file_list)

struct set_info1 *head;
int    quantity;
MEMptr file_list;

{

  char pre_str[1024];
  char sql_str[4096];
  char  **data, **data1, **col1;
  char fcat_name[61], cat_name[61];
  char type[3], cit_no_str[40], level_str[20];
  char *fname="PDMget_set_ci_files_info1";
  char row_str[1024], tables[123];
  int comma, x, y, z, count;
  int found;
  /*
  char  post_str[1024];
  char **column;
  int  count1;
  */

  int index_to_n_itemno=0;
  long cur_item_no, cur_cat_no;
  long status;
  struct set_info1 *current;
  struct attr_info1 *head_cat;
  MEMptr list=NULL;


  _PDMdebug  (fname, "ENTER:\n");

  current = head;
  _PDMdebug  (fname, "current = %ld\n", current );

if (PDMdebug_on)
_PDMprint_setinfo1_struct ("head", head);

  for (head_cat = PDMcat_list; head_cat != (struct attr_info1 *) NULL;
                               head_cat = head_cat->next)
  {
    _PDMdebug ( fname, "head_cat->table_no [%d], current->table_no [%d]\n",
                         head_cat->table_no, current->table_no );
    if (head_cat->table_no == current->table_no)
      break; 
  }

  if (head_cat == (struct attr_info1 *) NULL)
  {
    _PDMdebug ( fname, "The linked list is corrupted, STOP\n" );
    return (NFM_E_DATA);
  }

  sprintf (fcat_name, "f_%s", head_cat->table_name);
  strcpy (cat_name, head_cat->table_name);
  cur_cat_no = current->table_no;

PDMdebug ("parent info:\n");
if (PDMdebug_on) {
_PDMdebug ("cur_item_processed:", "%s\n", current->itemname_v);
_PDMprint_setinfo1_struct ("current", current);
}
          
  sprintf (pre_str, "SELECT %s.n_itemno, %s.n_itemname, %s.n_itemrev,\
    %s.n_setindicator, %s.n_status, %s.n_colevel, f_%s.n_itemnum, f_%s.n_fileno,\
    f_%s.n_fileclass, f_%s.n_filetype, f_%s.n_fileversion, f_%s.n_cisano,\
    f_%s.n_cifilename, f_%s.n_cifilesize, f_%s.n_ciuser, f_%s.n_cidate,\
    f_%s.n_citime, f_%s.n_cosano, f_%s.n_cofilename, f_%s.n_couser \
    FROM %s, f_%s WHERE %s.n_itemno = f_%s.n_itemnum  \
    AND ( ( f_%s.n_itemnum = %s AND f_%s.n_fileversion = %s )",
    cat_name, cat_name, cat_name, cat_name, cat_name, cat_name, cat_name,
    cat_name, cat_name, cat_name, cat_name, cat_name, cat_name, cat_name,
    cat_name, cat_name, cat_name, cat_name, cat_name, cat_name, cat_name,
    cat_name, cat_name, cat_name, cat_name, current->itemno_v, cat_name, 
    current->fileversion_v);
  comma = 0;
  
  sql_str[0] = '\0';
/*  strcpy(sql_str, " ( ");  */

  for (x = 1, current=current->next; x < quantity; x++, current=current->next)
  {
    strcat (sql_str, " OR ( ");
    strcat (sql_str, fcat_name);
    strcat (sql_str, ".n_itemnum = ");

      strcat (sql_str, current->itemno_v);

    strcat (sql_str, " AND ");
    strcat (sql_str, fcat_name);
    strcat (sql_str, ".n_fileversion = ");
      strcat (sql_str, current->fileversion_v);
    strcat (sql_str, ")");
if (PDMdebug_on) {
_PDMdebug ("cur_item_processed:", "%s\n", current->itemname_v);
_PDMprint_setinfo1_struct ("current", current);
    }
  }

  strcat (sql_str, ") AND "); 
/*  strcat (sql_str, " AND "); */
  strcat (sql_str, fcat_name);
  strcat (sql_str, ".n_fileclass = 'C' ");

  strcat (pre_str, sql_str);


  sprintf (tables, "%s, %s", cat_name, fcat_name);
  status = NFMlock_table (tables);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug ( fname, "NFMlock_table 0x%.8x\n" );
    return (status);
  }

  status = SQLquery (pre_str, &list, 2 * MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery: 0x%.8x\n", status );
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array: 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&file_list);
    _PDMdebug ( fname, "MEMbuild_array: 0x%.8x\n", status );
    return (status);
  }

  data1 = (char **) list->data_ptr;
  col1 = (char **) list->column_ptr;
  data = (char **) file_list->column_ptr;
if (PDMdebug_on){
  MEMprint_buffers ("In PDMXget_set_ci_files_info, file_list", 
					file_list, PDM_DEBUG_FILE);
  MEMprint_buffers ("In PDMXget_set_ci_files_info, list", 
					list, PDM_DEBUG_FILE);
          }
  cur_item_no = -1;
  strcpy (type, "\0");
  strcpy (cit_no_str, "-1");
  strcpy (level_str, "-1");
  found = -1;
/* since n_itemno is the first column */
  index_to_n_itemno = 0;
  _PDMdebug ( fname, "cur_item_no = %d, type [%s], cit_no [%s]\n",
                       cur_item_no, type, cit_no_str );     
  for (x = 0; x < list->rows; x++)
  {
    count = list->columns * x;
    row_str[0]='\0';
    found = -1;
    _PDMdebug ( fname, "at the start of big for: row_str = %s \n", row_str );
    _PDMdebug ( fname, "count = %d, index_to_n_itemno = %d\n", count,
                  index_to_n_itemno );

    _PDMdebug ( fname, "cur_item_no = %d, data1 [%d + %d] = %s\n",
                 cur_item_no, count, index_to_n_itemno, 
                 data1[count + index_to_n_itemno] );
    if (cur_item_no != atol(data1[count + index_to_n_itemno]) )
    {
      _PDMdebug (fname, "**** cur_itemno{%d} != data1[count{%d} + 0] {%s}\n", 
			cur_item_no, count, data1 [count + index_to_n_itemno]);
      for (current = head; current != (struct set_info1 *) NULL; 
           current = current->next)
      {
       if (PDMdebug_on)
       _PDMprint_setinfo1_struct ("current", current);
       _PDMdebug ( fname, "current = %ld\n", current );
       _PDMdebug ( fname, "current->itemno_v = %d\n",
                     atol(current->itemno_v) );

        if (atol (data1[count + index_to_n_itemno]) == 
            atol (current->itemno_v) )
        {
           _PDMdebug ( fname, "Found Match %s = %s\n",
                        data1[count + index_to_n_itemno],
                        current->itemno_v );
           strcpy (type, current->type);
           sprintf (cit_no_str, "%d",current->citno);
           sprintf (level_str, "%d",current->level);
           found = 1;
           break;
        }
      }
      cur_item_no = atol(data1[count + index_to_n_itemno]) ;
   }
   else
    {
      _PDMdebug (fname, 
"Not part of assy or already added: cur_itemno{%d} == data1[count{%d} + 0] {%s}\n", 
			cur_item_no, count, data1 [count + index_to_n_itemno]);
                  }

/*
if (PDMdebug_on)
_PDMprint_setinfo1_struct ("current", current);
*/
if (found ==1) {
    _PDMdebug ( fname, "cat_name = %s, cur_item_no = %d, \n\
                      type = %s, cit_no_str =%s, level_str = %s\n",
                 cat_name, cur_item_no, type, cit_no_str, level_str );


    for (y = 0, z = 0; y < (file_list)->columns; y++)
    {
      if (!strcmp (data[y], "n_catalogname") )
        strcat (row_str, cat_name);
      else if (!strcmp (data[y], "n_level") )
        strcat (row_str, level_str);
      else if (!strcmp (data[y], "n_citno") )
        strcat (row_str, cit_no_str);
      else if (!strcmp (data[y], "n_type") )
        strcat (row_str, type);
      else if (!strcmp (data[y], "n_status") )
        strcat (row_str, "");
      else if (!strcmp (data[y], "n_fileco") )
        strcat (row_str, "");
      else if (z < list->columns)
      {
        strcat (row_str, data1[count + z]);
        /*strcat (row_str, data1[y + z]); 
 _PDMdebug (fname, "data1[%d + %d] = %s\n", y, z, data1[y + z]);*/
 _PDMdebug (fname, "col1[%d] = %s, data1[%d + %d] = %s; data1[%d + %d] = %s\n", 
                  z, col1[z], count, z, data1[count + z], y, z, data1[y + z]);
        z++;
      }
      else 
      {
        strcat (row_str, "");
      }
      strcat (row_str, "\1");
    } 
    _PDMdebug ( fname, 
        "after loading form file_list:\n  row_str = %s\n", row_str );
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      _PDMdebug ( fname, "MEMwrite: 0x%.8x\n", status );
      return (status);
    }
   }
  }  

if (PDMdebug_on){
  MEMprint_buffers ("assy struct buffer in  PDMXget_set_ci_files_info, ", 
					file_list, PDM_DEBUG_FILE);
          }
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMclose: 0x%.8x\n", status );
    return (status);
  }

  _PDMdebug ( fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}


long PDMXcheck_and_update_items_status1 (catalog, head_set, type)
char *catalog;
struct set_info1 *head_set;
int type;

{
  char sql_str[1024];
  char *fname="PDMXcheck_and_update_items_status1";
  char **data;
  char co_str[3];
  int x, index;
  /* int  or;*/
  long status;
  MEMptr list=NULL;
  struct set_info1 *current;
  struct attr_info1 *head_cat;

  _PDMdebug ( fname, "ENTER: type = %s\n", (type == NFM_SET_OUT)? 
                  "NFM_SET_OUT": "NFM_MEM_OUT" );
  
  current = head_set;
  for (head_cat = PDMcat_list; head_cat != (struct attr_info1 *) NULL;
                               head_cat = head_cat->next)
    if (head_cat->table_no == current->table_no)
      break;

  if (head_cat == (struct attr_info1 *) NULL)
  {
    _PDMdebug ( fname, "The linked list is corrupted, STOP\n" );
    return (NFM_E_DATA);
  }
    sql_str[0] = '\0';
  sprintf (sql_str, 
     "SELECT %s.n_itemno, %s.n_itemlock, %s.n_archivestate,\
     %s.n_status, %s.n_itemname, %s.n_itemrev, f_%s.n_pendingflag \
     FROM %s, f_%s WHERE %s.n_itemno = %d AND f_%s.n_itemnum = %d", 
     catalog, catalog, catalog, catalog, catalog, catalog, 
     catalog, catalog, catalog, catalog, PDMpart.n_itemno, catalog, 
     PDMpart.n_itemnum);
  
/*
  status = NFMlock_table (head_cat->table_name);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug ( fname, "NFMlock_table 0x%.8x\n" );
    return (status);
  }
*/

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _PDMdebug ( fname, "SQLquery: 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _PDMdebug ( fname, "MEMbuild_array 0x%.8x\n", status  );
    return (status);
  }
 
if (PDMdebug_on) {
  MEMprint_buffers ("In PDMXcheck_and_update_items_status1, query result", 
					list, PDM_DEBUG_FILE);
            }

  data = (char **) list->data_ptr;

  if (type == NFM_MEM_OUT)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (! strcmp(data[index + 1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _PDMdebug ( fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index + 1] );
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index + 2]) && strcmp (data[index + 2], "B") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 1, data[index + 2]);
        _PDMdebug ( fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index + 2] );
        return (NFM_E_MEM_FLAGGED);
      }
      if ( strlen(data[index + 3]) && !strcmp (data[index + 3],"I") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 5, data[index + 3]);
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 3] );
        return (NFM_E_MEM_NOT_READY_OUT);
      }
      if ( strlen(data[index + 6]) )
      {
        _NFMload_message (data[index + 4], data[index + 5], 1, data[index + 6]);
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 6] );
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
      if (!  strcmp(data[index + 1], "Y")) {
        _PDMdebug ( fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index + 1] );
        return (NFM_E_SET_LOCKED);
      }
      if ( strlen(data[index + 2]) && !strcmp(data[index + 2], "B") ) {
        _NFMload_message (data[index + 4], data[index + 5], 1, data[index + 2]);
        _PDMdebug ( fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index + 2] );
        return (NFM_E_SET_FLAGGED);
      }
      if ( strlen(data[index + 3]) && !strcmp (data[index + 3],"I") ) {
        _NFMload_message (data[index + 4], data[index + 5], 6, data[index + 3]);
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 3] );
        return (NFM_E_SET_NOT_READY_OUT);
      }
      if ( strlen(data[index + 6]) ) {
        _NFMload_message (data[index + 4], data[index + 5], 1, data[index + 6]);
        _PDMdebug ( fname, "item %s, n_pending = %s\n",
                            data[index], data[index + 6] );
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
      if (! strcmp(data[index + 1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _PDMdebug ( fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index + 1] );
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index + 2]) && strcmp (data[index + 2], "B") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 2, data[index + 2]); 
        _PDMdebug ( fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index + 2] );
        return (NFM_E_MEM_FLAGGED);
      }
/*
      if ( strlen(data[index + 3]) && strcmp (data[index + 3],"I") &&
           strcmp (data[index + 3], "O")&& strcmp (data[index + 3], "S")&&
           strcmp (data[index + 3], "M")&& strcmp (data[index + 3], "SN")&&
           strcmp (data[index + 3], "MN")&& strcmp (data[index + 3], "TO") ) 
      {
        _NFMload_message (data[index + 4], data[index + 5], 2, data[index + 3]); 
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 3] );
        return (NFM_E_MEM_NOT_READY_OUT);
      }
*/
      if ( strlen(data[index + 6]) )
      {
        _NFMload_message (data[index + 4], data[index + 5], 2, data[index + 6]); 
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 6] );
        return (NFM_E_MEM_FLAGGED);
      }
    }
  }
  else if (type == NFM_MEM_IN)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (! strcmp(data[index + 1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_MEM_LOCKED, "", NULL);
        _PDMdebug ( fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index + 1] );
        return (NFM_E_MEM_LOCKED);
      }
      if ( strlen(data[index + 2]) && strcmp (data[index + 2], "B") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 0, data[index + 2]); 
        _PDMdebug ( fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index + 2] );
        return (NFM_E_MEM_FLAGGED);
      }
/*
      if ( strlen(data[index + 3]) && strcmp (data[index + 3],"M") &&
           strcmp (data[index + 3], "MN") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 3, data[index + 3]); 
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 3] );
        return (NFM_E_MEM_NOT_READY_IN);
      }
*/
    }
    strcpy (co_str, "TI");
  }
  else if (type == NFM_SET_IN)
  {
    for (x = 0; x < list->rows; x++)
    {
      index = x * list->columns;
      if (!  strcmp(data[index + 1], "Y"))
      {
        ERRload_struct (NFM, NFM_E_SET_LOCKED, "", NULL);
        _PDMdebug ( fname, "item %s, n_itemlock = %s\n",
                            data[index], data[index + 1] );
        return (NFM_E_SET_LOCKED);
      }
      if ( strlen(data[index + 2]) && strcmp (data[index + 2], "B") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 0, data[index + 2]); 
        _PDMdebug ( fname, "item %s, n_archivestate = %s\n",
                            data[index], data[index + 2] );
        return (NFM_E_SET_FLAGGED);
      }
/*
      if ( strlen(data[index + 3]) && strcmp (data[index + 3],"S") &&
           strcmp (data[index + 3], "SN") )
      {
        _NFMload_message (data[index + 4], data[index + 5], 4, data[index + 3]); 
        _PDMdebug ( fname, "item %s, n_status = %s\n",
                            data[index], data[index + 3] );
        return (NFM_E_SET_NOT_READY_IN);
      }
*/
    }
    strcpy (co_str, "TI");
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _PDMdebug ( fname, "MEMclose: 0x%.8x\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  if ( (type == NFM_SET_COPY) || (type == NFM_MEM_COPY) )
  {
    _PDMdebug ( fname, "No need to update n_status flag\n" );
    return (NFM_S_SUCCESS);
  } 

/*
  current = head_set;

  sprintf (sql_str, "UPDATE %s SET n_status = '%s' WHERE n_itemno = %d", 
                    catalog, co_str, PDMpart.n_itemno);
  

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n", status );
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (NFM_E_SQL_QUERY);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n" );
    return (status);
  }
*/

  _PDMdebug ( fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}



long PDMXset_colevel (cat_name, item_no, level)
char *cat_name;
long *item_no;
char *level;
{
  char *fname="PDMXset_colevel";
  char sql_str[126];
  long status;

  _PDMdebug ( fname, "ENTER: catalog [%s] item_no [%d] set to level [%s]\n",
                       cat_name, item_no, level );

  sprintf (sql_str, "UPDATE %s SET n_colevel = %s WHERE n_itemno = %d",
                 cat_name, level, item_no);
    
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug ( fname, "NFMlock_table 0x%.8x\n", status );
    return (status);
  }

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt 0x%.8x\n", status );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (NFM_E_SQL_STMT);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _PDMdebug ( fname, "SQLstmt {commit work} 0x%.8x\n", status );
    return (status);
  }

  _PDMdebug ( fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS );
  return (NFM_S_SUCCESS);
}

long PDMXget_children_info ()

{
  /***
    This function will query the catalog names and f_catalog numbers of the 
    members.

  ***/

  char sql_str[3072], cur_cat_name[61], temp_name[61];
  char *fname="PDMXget_children_info";
  char **data;
  char value[50];
  long  cur_cat;
  int  x, index;
  long status;
  struct child_info  *head;
  MEMptr list=NULL;
 
  _PDMdebug ( fname, "ENTER:\n ");

  /* skip the 1st one, because the information is obtained. */
  head = PDMchildren_list->next;
  cur_cat = head->ccatalogno;

  sprintf (sql_str, "%s %s %d",
           "SELECT n_catalogno, n_catalogname FROM NFMCATALOGS WHERE ",
           "n_catalogno = ", cur_cat);

  head = head->next;
  for (; head != (struct child_info *) NULL; head = head->next)
  {
    if ( head->ccatalogno != cur_cat)
    {
      strcat (sql_str, "OR n_catalogno = ");
      sprintf (value, " %d ", head->ccatalogno);
      strcat (sql_str, value);
      cur_cat = head->ccatalogno;
    }
  } 
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array (list) 0x%.8x\n", status);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    head = PDMchildren_list->next;
    for (; head != (struct child_info *) NULL; head = head->next)
    {
      if (head->ccatalogno == atoi (data[index]) )
        strcpy (head->cat_name, data[index + 1]);
    }
  }
  
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug ( fname, "MEMclose: 0x%.8x\n", status );
    return (status);
  }

  head = PDMchildren_list->next;
  strcpy (cur_cat_name, head->cat_name);

  sprintf (sql_str, "%s %s 'f_%s'",
           "SELECT n_tablename, n_tableno FROM nfmtables WHERE ",
           "n_tablename = ", head->cat_name);

  head = head->next;
  for (; head != (struct child_info *) NULL; head = head->next)
  {
    if ( strcmp (head->cat_name, cur_cat_name) ) 
    {
      strcat (sql_str, "OR n_tablename = 'f_");
      strcat (sql_str, head->cat_name);
      strcat (sql_str, "'");
      strcpy (cur_cat_name, head->cat_name);
    }
  }
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "SQLquery 0x%.8x\n", status );
    return (status);
  }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _PDMdebug ( fname, "MEMbuild_array (list) 0x%.8x\n", status);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    head = PDMchildren_list->next;
    for (; head != (struct child_info *) NULL; head = head->next)
    {
      sprintf (temp_name, "f_%s", head->cat_name);
      if (!strcmp (temp_name, data[index]))
        head->fcat_no = atoi(data[index + 1]);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug ( fname, "MEMclose 0x%.8x\n", status );
    return (status);
  }

  _PDMdebug ( fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

