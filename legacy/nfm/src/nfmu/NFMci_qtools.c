#include "machine.h"
#include "NFMstruct.h"
#include "NFMattr_def.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "ERR.h"
#include "DEBUG.h"

#define FILLED_ROWS  5

#define NULL  0

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif


extern struct NFMitem_info *NFMitem_ptr;
extern MSGptr NFMmsg_ptr;
extern struct NFMglobal_st NFMglobal;
extern MEMptr CAT_list;

long _NFMq_ci_attr (user_id, attr_list, data_list)
long   user_id;
MEMptr *attr_list, *data_list;

{
long  status;
int   x, count;
char  **data;
char  sql_str[300];
long  _NFMtable_template (), _NFMfill_rows ();

  status = _NFMtable_template (attr_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
    _NFM_num ("_NFMq_ci_attr: _NFMtable_template status = <0x%.8x>", status);
    return (status);
  }

/*
  MEMprint_buffers ("attr_list, after q_tab_temp", *attr_list, 
                                                    NFMmsg_ptr.debug_file);
*/
  status = _NFMfill_rows (attr_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFM_num ("_NFMq_ci_attr: _NFMfill_rows status = <0x%.8x>", status);
    return (status);
  }

  /*
  MEMprint_buffers ("attr_list, after fill_rows", *attr_list, 
                                                    NFMmsg_ptr.debug_file);
  */
  
  sprintf (sql_str,
  "(n_tableno = %d OR n_tableno = %d) AND (%s = 'Y' or %s = 'U')",
  NFMitem_ptr->table_no, NFMitem_ptr->ftable_no, "n_checkin", "n_checkin"); 

  status = NFMget_table_attr (user_id, sql_str, "", attr_list);

  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFM_num ("_NFMq_ci_attr: NFMget_table_attr status = <0x%.8x>", status);
    return (status);
  }

  /*
  MEMprint_buffers ("attr_list, after get_table_attr", *attr_list, 
                                                    NFMmsg_ptr.debug_file);
  */

  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMq_ci_attr: MEM Build Array : status = <0x%.8x>\n", 
               NFM_E_MEM);
    return (NFM_E_MEM);
  }

  data   = (char **) (*attr_list) -> data_ptr;
  for (x = FILLED_ROWS; x < (*attr_list) -> rows; ++x)
  {
    status = MEMwrite_data (*attr_list, "0", x + 1, INDEX_N_LISTNO + 1);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMchk_item : MEM Write Data : status = <0x%.8x>\n",
      status);
      return (status);
    }
  }
/*
  MEMprint_buffers ("attr_list, after get_table_attr", *attr_list, 
                                                    NFMmsg_ptr.debug_file);
*/

  status = MEMopen (data_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMq_ci_attr: MEMopen status = <0x%.8x>", status);
    return (status);
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
      _NFM_num ("_NFMq_ci_attr: MEM Write Format : status = <0x%.8x>\n",
      status);
      return (status);
    }
  }
/*
  MEMprint_buffers ("data_list, after get_table_attr", *data_list, 
                                                    NFMmsg_ptr.debug_file);
*/
  return (NFM_S_SUCCESS);
}

long _NFMtable_template (attr_list)
MEMptr *attr_list;
{
long status;

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMtable_template: enter ...");
  
  status = MEMopen (attr_list, 2* MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("NFMtable_template: MEMopen status = <0x%.8x>", status);
    return (status);
  }
  
  /* 1 */
  status = MEMwrite_format (*attr_list, "n_name", "char(20)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 2 */
  status = MEMwrite_format (*attr_list, "n_datatype", "char(15)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 3 */
  status = MEMwrite_format (*attr_list, "n_synonym", "char(40)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 4 */
  status = MEMwrite_format (*attr_list, "n_application", "char(3)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 5 */
  status = MEMwrite_format (*attr_list, "n_read", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 6 */
  status = MEMwrite_format (*attr_list, "n_write", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 7 */
  status = MEMwrite_format (*attr_list, "n_update", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 8 */
  status = MEMwrite_format (*attr_list, "n_delete", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 9 */
  status = MEMwrite_format (*attr_list, "n_null", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 10 */
  status = MEMwrite_format (*attr_list, "n_adviceno", "integer");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 11 */
  status = MEMwrite_format (*attr_list, "n_checkin", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 12 */
  status = MEMwrite_format (*attr_list, "n_checkout", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 13 */
  status = MEMwrite_format (*attr_list, "n_seqno", "integer");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  /* 14 */
  status = MEMwrite_format (*attr_list, "n_valueno", "integer");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    _NFM_num ("_NFMtable_template: MEMwrite_format status = <0x%.8x>", status);
    return (status);
  }
  
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMtable_template: exit, status = <0x%.8x> ", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

long _NFMfill_rows (attr_list)
MEMptr *attr_list;

{
char  *cat_str, *lvl_str, *row_str;
char  *sts_str, *typ_str;
long  status;
 
  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMfill_rows: enter ...");

  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows: MEM Build Array : status = <0x%.8x>\n", 
               NFM_E_MEM);
    return (NFM_E_MEM);
  }

  cat_str = (char *) malloc ((*attr_list) -> row_size);
  if (! cat_str)
  {
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("_NFMfill_rows: Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  lvl_str = (char *) malloc ((*attr_list) -> row_size);
  if (! lvl_str)
  {
    free (cat_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("_NFMfill_rows: Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  row_str = (char *) malloc ((*attr_list) -> row_size);
  if (! row_str)
  {
    free (cat_str);
    free (lvl_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("_NFMfill_rows: Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }
  typ_str = (char *) malloc ((*attr_list) -> row_size);
  if (! typ_str)
  {
    free (cat_str);
    free (lvl_str);
    free (row_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("_NFMfill_rows: Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  sts_str = (char *) malloc ((*attr_list) -> row_size);
  if (! sts_str)
  {
    free (cat_str);
    free (lvl_str);
    free (row_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("_NFMfill_rows: Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }
  cat_str [0] = 0; lvl_str [0] = 0; row_str [0] = 0;
  typ_str [0] = 0; sts_str [0] = 0;

  sprintf (cat_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_catalogname\1",
                    "char(20)\1",
                    "Catalog Name\1",
                    "NFM\1",
                    "Y\1",
                    "N\1",
                    "N\1", 
                    "N\1", 
                    "N\1", 
                    "0\1", 
                    "N\1",   
                    "N\1", 
                    "0\1",  
                    "0\1"); 



  sprintf (lvl_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                   "n_level\1",
                   "integer\1",
                   "Level\1",
                   "NFM\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "0\1" );


  sprintf (row_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                   "n_citno\1", 
                   "integer\1",
                   "Row No\1",
                   "NFM\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "0\1");


  sprintf (sts_str, "%s\1%s%s%s%s%s%s%s%s%s%s%s%s%s",
                   "n_status1",
                   "char(10)\1",
                   "Status\1",
                   "NFM\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "0\1");


  sprintf (typ_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                   "n_type\1",
                   "char(1)\1",
                   "MEM Type\1",
                   "NFM\1",
                   "Y\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "N\1",
                   "N\1",
                   "0\1",
                   "0\1");


  status = MEMwrite (*attr_list, sts_str);
  if (status != MEM_S_SUCCESS)
  {
    free (cat_str);   free (lvl_str);
    free (row_str);   free (sts_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows : MEM Write 1 : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }
  status = MEMwrite (*attr_list, lvl_str);
  if (status != MEM_S_SUCCESS)
  {
    free (cat_str);   free (lvl_str);
    free (row_str);   free (sts_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows: MEM Write 2 : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  status = MEMwrite (*attr_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    free (cat_str);   free (lvl_str);
    free (row_str);   free (sts_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows: MEM Write 3 : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }
  status = MEMwrite (*attr_list, cat_str);
  if (status != MEM_S_SUCCESS)
  {
    free (cat_str);   free (lvl_str);
    free (row_str);   free (sts_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows: MEM Write  4: status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }
  status = MEMwrite (*attr_list, typ_str);
  if (status != MEM_S_SUCCESS)
  {
    free (cat_str);   free (lvl_str);
    free (row_str);   free (sts_str);
    free (typ_str);
    MEMclose (attr_list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("_NFMfill_rows: MEM Write 5 : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  free (cat_str);   free (lvl_str);
  free (row_str);   free (sts_str);
  free (typ_str);

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMfill_rows: exit, status = <0x%.8x>", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}


long NFMg_item_ci_info (user_id, cat_name, attr_list, data_list)

long user_id;
char *cat_name;
MEMptr attr_list, data_list;

{

char   **column, **data, **data1;
MEMptr /* cat_list = NULL, */ list = NULL;
char   fcat_name[80];
long   status;
char   *sql_str;
char   *fname="NFMg_item_ci_info";
int    comma, found; 
int    x, y, z, count, count1;

  _NFMdebug ((fname, "ENTER:\n"));
  if (_NFMdebug_st.NFMdebug_on)
  {
  MEMprint_buffers ("data_list, after enter NFMg_item_ci_info", data_list, 
                                                    _NFMdebug_st.NFMdebug_file);

  MEMprint_buffers ("attr_list, after enter NFMg_item_ci_info", attr_list,
                            _NFMdebug_st.NFMdebug_file);
  }
  
  sprintf (fcat_name, "f_%s", cat_name);

  column = (char **) attr_list->column_ptr;
  data = (char **) attr_list->data_ptr; 

  status = NFMquery_attributes_definition (user_id, "CATALOG", cat_name,
                                           &CAT_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&CAT_list);
    _NFM_num ("NFMg_item_ci_info: status = <0x%.8x>", status);
    return (status);
  } 

  status = MEMbuild_array (CAT_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&CAT_list);
    _NFM_num ("NFMg_item_ci_info: status = <0x%.8x>", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  data1 = (char **) CAT_list->data_ptr;

  sql_str = (char *) malloc (attr_list->rows*100 + MEM_SIZE);
  if (!sql_str)
  {
    MEMclose (&CAT_list);
    _NFM_num ("NFMq_item_ci_info: status = <0x%.8x>", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  sprintf (sql_str, "SELECT ");
  comma = FALSE;
  
  for (x = FILLED_ROWS; x < attr_list->rows; ++x)
  {
    count = attr_list->columns * x;
    found = FALSE;
    _NFMdebug ((fname, "data[count + %d] = %s\n\
                                  data[count + %d] = %s\n",
               INDEX_N_NAME, 
               data[count+INDEX_N_NAME],
               INDEX_N_NFMAPPLICATION, data[count+INDEX_N_NFMAPPLICATION]));
  
    for (y = 0; (y < CAT_list->rows) &&  (!found); ++y)
    {
      count1 = CAT_list->columns * y;
  

         /* data1[count1 + 2], 2, because of the way that query is */
         /* set-up in NFMget_attr_def (called in NFMquery_attr_def,*/
         /* called in NFMquery_attributes_definition) */

      if ( (!strcmp (data[count + INDEX_N_NAME], 
                     data1[count1 + 2])) 
           && (!strcmp (data[count + INDEX_N_NFMAPPLICATION], "NFM")) )
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

      strcat (sql_str, fcat_name);
      strcat (sql_str, ".");
      strcat (sql_str, data[count + INDEX_N_NAME]);
    }
  }
  _NFM_num ("NFMg_item_ci_info: point 4 ");
  strcat (sql_str, " FROM ");
  strcat (sql_str, cat_name);
  strcat (sql_str, ", ");
  strcat (sql_str, fcat_name);

  strcat (sql_str, " WHERE ");
  strcat (sql_str, fcat_name);
  strcat (sql_str, ".");
  strcat (sql_str, NFMitem_ptr->fcat_item.n_itemnum.attr_name);
  strcat (sql_str, " = ");
  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char",4 ))
  {
    strcat (sql_str, "'");
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);
 
  strcat (sql_str, " AND ");
  strcat (sql_str, fcat_name);
  strcat (sql_str, ".");
  strcat (sql_str, "n_fileclass");
  strcat (sql_str, " = ");

  strcat (sql_str, "'C'");
  
  strcat (sql_str, " AND ");
  strcat (sql_str, fcat_name);
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
  strcat (sql_str, fcat_name);
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
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      status = NFMerror (NFM_E_CORRUPTED_CATALOG);
      _NFM_num ("NFMg_item_ci_list: SQLsuery: status = <0x%.8x>", 
                 NFM_E_CORRUPTED_CATALOG);
      return (NFM_E_CORRUPTED_CATALOG);
    }
    status = NFMerror (NFM_E_SQL_QUERY); 
    _NFM_num ("NFMg_item_ci_list: SQLsuery: status = <0x%.8x>", 
               NFM_E_SQL_QUERY);
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&list);
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("NFMg_item_ci_list:  MEM Build Array : status = <0x%.8x>\n", 
               NFM_E_MEM);
    return (NFM_E_MEM);
  }
  /***
  MEMprint_buffers ("list, before exit NFMg_item_ci_info", list, 
                                                    "/usr2/nfmadmin/buffers");
  ***/
  data1 = (char **) list -> data_ptr;
  free (sql_str);
  sql_str = (char *) malloc (data_list -> row_size * 2);
  if (! sql_str)
  {
    MEMclose (&list);
    status = NFMerror (NFM_E_MALLOC);
    _NFM_num ("NFMg_item_ci_list:  Malloc Failed : status = <0x%.8x>\n", 
              NFM_E_MALLOC);
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
      status = NFMerror (NFM_E_MEM);
      _NFM_num ("NFMg_item_ci_list:  MEM Write : status = <%d>\n", status);
      return (status);
    }
  }
  free (sql_str);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    status = NFMerror (NFM_E_MEM);
    _NFM_num ("NFMg_item_ci_list:  MEM Close : status = <%d>\n", status);
    return (status);
   }

   if (NFMmsg_ptr.debug_on)
   _NFM_num ("NFMg_item_ci_list:  SUCCESSFUL : status = <%d>\n", NFM_S_SUCCESS);

  /***
  MEMprint_buffers ("data_list, before exit NFMg_item_ci_info", data_list, 
                                                    "/usr2/nfmadmin/buffers");

  MEMprint_buffers ("attr_list, before exit NFMg_item_ci_info", attr_list,
                                                    "/usr2/nfmadmin/buffers");

  ***/
  
  return (NFM_S_SUCCESS);
}

long _NFMchk_in_user (attr_list, data_list)
MEMptr attr_list, data_list;
{

  long     status;
  char     **column, **data, **data1;
  long     x, y, count, c, i, j, k;

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMchk_in_user: enter ...");

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMchk_in_user: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }
  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;
  
  i = j = k = -1;

  for (x = 0; x < attr_list -> rows; ++x)
  {
    count = attr_list -> columns * x;
    if ( !strcmp (data[count + INDEX_N_NAME], "n_couser"))
      i = x;
    else if ( !strcmp (data[count + INDEX_N_NAME], "n_fileco"))
      j = x;
    else if ( !strcmp (data[count + INDEX_N_NAME], "n_type"))
      k = x;
    else if ( (i > -1) && (j > -1) && (k > -1))
      break;
  }
    

  for (x = 0; x < data_list -> rows; ++x)
  {
    count = data_list -> columns * x;

    /**
    _NFM_str ("_NFMchk_in_user: Co Stat = <%s>  ", data1 [count + j]);
    _NFM_str ("_NFMchk_in_user: Co User = <%s>  ", data1 [count + i]);
    _NFM_str ("_NFMchk_in_user:    User = <%s>\n", NFMglobal.NFMusername    );
    **/

    if (! strcmp (data1 [count + k], "S") )
      continue;
    if (! strcmp (data1 [count + j], "Y"))
    {
      if (strcmp (data1 [count + i], NFMglobal.NFMusername))
      {
        status = ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", 
                     "check in the item", "item");
        _NFM_num ("_NFMchk_in_user: Not CO Out User : status = <0x%.8x>\n",
        NFM_E_NOT_CO_USER);
        return (NFM_E_NOT_CO_USER);
      }
    }
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMchk_in_user: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);

}
