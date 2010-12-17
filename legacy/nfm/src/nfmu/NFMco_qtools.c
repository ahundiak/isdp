#include "machine.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "NFMattr_def.h"
#include "ERR.h"
#include "MSGstruct.h"

#define FILLED_ROWS  5
#define NULL  0

extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr;
extern MEMptr CAT_list;


long _NFMq_co_attr (user_id, cat_name, attr_list, data_list)
long     user_id;
char     *cat_name;
MEMptr   *attr_list, *data_list;
{
  long     status;
  char     **column, **data;
  long     a, b, c, x, y, count;
  char     *cat_str, *lvl_str, *row_str;
  char     *sts_str, *typ_str;
  char     sql_str [2048];
  char     file_cat [100];
  long     tab_no1, tab_no2;
  char     data_type [50];

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMq_co_attr: enter...");

  status = _NFMtable_template (attr_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
    _NFM_num ("_NFMq_co_attr: _NFMtable_template status = <0x%.8x>", status);
    return (status);
  }

  status = _NFMfill_rows (attr_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFM_num ("_NFMq_co_attr: _NFMfill_rows status = <0x%.8x>", status);
    return (status);
  }

  sprintf (sql_str,
  " (n_tableno = %d OR n_tableno = %d) AND (%s = 'Y' or %s = 'U')",
  NFMitem_ptr->table_no, NFMitem_ptr->ftable_no, "n_checkout", "n_checkout");

  status = NFMget_table_attr (user_id, sql_str, "", attr_list);
  if (status != NFM_S_SUCCESS)
  {
     MEMclose (attr_list);
     _NFM_num ("_NFMq_co_attr: NFMget_table_attr <0x%.8x>\n", status);
     return (status);
  }

  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMq_co_attr: MEMbuild_array (attr_list) <0x%.8x>\n", 
    NFM_E_MEM);
    return (NFM_E_MEM);        
  }

  column = (char **) (*attr_list) -> column_ptr;
  data   = (char **) (*attr_list) -> data_ptr;

  for (x = FILLED_ROWS; x < (*attr_list) -> rows; ++x)
  {
    status = MEMwrite_data (*attr_list, "0", x + 1, INDEX_N_LISTNO + 1);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMq_co_list : MEM Write Data : status = <0x%.8x>\n",
      status);
      return (status);
    }
  }

  status = MEMopen (data_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMq_co_attr : MEMopena (data_list) <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);        
  }

  for (x = 0; x < (*attr_list) -> rows; ++x)
  {
    count = (*attr_list) -> columns * x;
    status = MEMwrite_format (*data_list,
                 data [count + INDEX_N_NAME], data [count + INDEX_N_DATATYPE]);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMq_co_attr: MEMwrite_format (data_list) <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);        
    }
  }
          
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMq_co_attr: exit SUCCESSFUL <0x%.8x>", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

long _NFMg_item_co_info (user_id, cat_name, attr_list, data_list)

long     user_id;
char     *cat_name;
MEMptr   attr_list, data_list;
{
  long    status;
  char    file_cat [100];
  long    y, x, z, count;
  long    count1, comma, found;
  long    i;
  char    **column, **data, **data1, **data2;
  char    *sql_str, sql_str1 [1024];
  char    attr [50], value [50];
  MEMptr  list = NULL;

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMg_item_co_info: enter ...");

  sprintf (file_cat, "f_%s", cat_name);

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  status = NFMquery_attributes_definition (user_id, "CATALOG",
              cat_name, &CAT_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&CAT_list);
    _NFM_num ("_NFMg_item_co_info: NFMquery_attributes_definition <0x%.8x>\n", 
    status);
    return (status);
  }


  status = MEMbuild_array (CAT_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("CO LIST : MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }


  data1 = (char **) CAT_list -> data_ptr;
     
  sql_str = (char *) malloc (attr_list -> rows * 100 + MEM_SIZE);
  if (! sql_str)
  {
    MEMclose (&CAT_list);
    ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("CO LIST : Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }
  sql_str [0] = 0;

  sprintf (sql_str, "SELECT ");
  comma = 0;

  for (x = FILLED_ROWS; x < attr_list -> rows; ++x)
  {
    count = attr_list -> columns * x;
    found = 0;

    _NFM_str ("_NFMg_item_co_info: attr_name <%s>", 
               data [count + INDEX_N_NAME]);

    for (y = 0; (y < CAT_list -> rows) && (! found); ++y)
    {
      count1 = CAT_list -> columns * y;

      if ((! strcmp (data [count + INDEX_N_NAME], data1 [count1 + 2])) &&
               (! strcmp (data [count + INDEX_N_NFMAPPLICATION], "NFM")))
      {
        if (comma) strcat (sql_str, ", ");
        else       comma = 1;

        strcat (sql_str, cat_name);
        strcat (sql_str, ".");
        strcat (sql_str, data [count + INDEX_N_NAME]);
        found = 1;
      }
      else if ( !strcmp (data[count + INDEX_N_NAME], data1[count1]) )
      {
        if (comma)
          strcat (sql_str, ", ");
        else
          comma = TRUE;

        strcat (sql_str, cat_name);
        strcat (sql_str, ".");
        strcat (sql_str, data[count + INDEX_N_NAME]);
        found = TRUE;
      }

    }
    if  ( (!found) &&
          (!strcmp (data[count + INDEX_N_NFMAPPLICATION], "NFM")) )
    {
      if (comma)
        strcat (sql_str, ",");
      else
        comma = TRUE;

      strcat (sql_str, file_cat);
      strcat (sql_str, ".");
      strcat (sql_str, data[count + INDEX_N_NAME]);
    }
  }
  _NFM_str ("_NFMg_item_co_info: finishing going thru the attr_list data");

  strcat (sql_str, " FROM ");
  strcat (sql_str, cat_name);
  strcat (sql_str, ",  ");
  strcat (sql_str, file_cat);
  strcat (sql_str, " WHERE ");

  strcat (sql_str, file_cat);
  strcat (sql_str, ".");
  strcat (sql_str, NFMitem_ptr->fcat_item.n_itemnum.attr_name);
  strcat (sql_str, " = ");

  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char", 4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);

  strcat (sql_str, " AND ");
  strcat (sql_str, file_cat);
  strcat (sql_str, ".");
  strcat (sql_str, "n_fileclass");/* n_fileclass is not allowed to be changed */
  strcat (sql_str, " = ");

  strcat (sql_str, "'C'");

  strcat (sql_str, " AND ");
  strcat (sql_str, file_cat);
  strcat (sql_str, ".");
  strcat (sql_str, NFMitem_ptr->fcat_item.n_fileversion.attr_name);
  strcat (sql_str, " = ");

  if (! strncmp (NFMitem_ptr->fcat_item.n_fileversion.attr_dtype, "char", 4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, NFMitem_ptr->fcat_item.n_fileversion.data_value);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, NFMitem_ptr->fcat_item.n_fileversion.data_value);

  strcat (sql_str, " AND ");
  strcat (sql_str, file_cat);
  strcat (sql_str, ".");
  strcat (sql_str, NFMitem_ptr->fcat_item.n_itemnum.attr_name);
  strcat (sql_str, " = ");
  strcat (sql_str, cat_name);
  strcat (sql_str,".");
  strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.attr_name);

  status = SQLquery (sql_str, &list, 2 * MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&list);
 
    if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
      _NFM_num ("_NFMg_item_co_info: Cat Entries Are Bad: <0x%.8x>\n",
      NFM_E_CORRUPTED_CATALOG);
      return (NFM_E_CORRUPTED_CATALOG);
    }

    ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
    _NFM_num ("_NFMg_item_co_info: SQLquery <0x%.8x>\n",  NFM_E_SQL_QUERY);
    return ( NFM_E_SQL_QUERY);
  }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMg_co_list: MEMbuild_array(list) <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);       
  }

  data1 = (char **) list -> data_ptr;

  free (sql_str);

  sql_str = (char *) malloc (data_list -> row_size * 2);
  if (! sql_str)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("_NFMg_co_list: malloc sql_str <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);       
  }

  for (x = 0; x < list -> rows; ++x)
  {
    count = list -> columns * x;
    sql_str [0] = 0; z = 0;

    for (y = 0; y < attr_list -> rows; ++y)
    {
      count1 = attr_list -> columns * y;

      if (! strcmp (data [count1 + INDEX_N_NAME], "n_catalogname"))
        strcat (sql_str, cat_name);
      else if (! strcmp (data [count1 + INDEX_N_NAME], "n_level"))
        strcat (sql_str, "");
      else if (! strcmp (data [count1 + INDEX_N_NAME], "n_citno"))
        strcat (sql_str, "");
      else if (! strcmp (data [count1 + INDEX_N_NAME], "n_type"))
        strcat (sql_str, "");
      else if (! strcmp (data [count1 + INDEX_N_NAME], "n_status1"))
        strcat (sql_str, "");
      else
      {
        strcat (sql_str, data1 [count + z]);
        z++;
      }

      strcat (sql_str, "\1");
    }

    status = MEMwrite (data_list, sql_str);
    if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMg_item_co_info: MEMwrite: <0x%.8x>\n", NFM_E_MEM);
      return (NFM_E_MEM);       
    }
  }

  free (sql_str);
 
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMg_item_co_info: MEMclose: <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);       
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMg_item_co_info: SUCCESSFUL: <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

