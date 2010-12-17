#include "machine.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "WFstruct.h"
#include "UTIerrordef.h"


#define DEL_CLAUSE_LENGTH 60
#define MAIN_LENGTH       100

extern struct NFMglobal_st NFMglobal;
extern struct NFMactive *NFMactive_item;
extern MEMptr NFMactive_data_list;
extern struct WFstruct WFinfo;
extern long DM_MANAGER;
extern long NFM_FTR_INITED;

int i_status=-1, i_cisaname=-1, i_cifilename=-1, i_cofilename=-1, i_filetype=-1,    i_filenum=-1, i_fileno=-1, i_cifilesize=-1, i_fileco=-1, i_fileversion=-1;

long NFMdefine_file_information (catalog_name, item_name, item_revision,
                                 operation, data_list) 

/***
  This function is used to add/delete/change an item's file information


***/

char *catalog_name;
char *item_name;
char *item_revision;
long operation;
MEMptr data_list;

{
  char *fname="NFMdefine_file_information";
  char **data, **column;
  int x;
  long status;
  long NFMadd_files_to_item(), NFMdelete_files_from_item(),
       NFMchange_files_information ();

  _NFMdebug ( (fname, "ENTER: cat name [%s] item name[%s] item rev [%s] \n\
                       operation = %d\n",
               catalog_name, item_name,  item_revision, operation) );

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("data_list", data_list, _NFMdebug_st.NFMdebug_file);

  /* check for the sequence of command (i.e. 1. NFMget_file_information,
     2. NFMdefine_file_information) */

  if (NFMactive_item->command == NFM_GET_FILE_INFO)
  {
    if (strcmp (NFMactive_item->cat_name, catalog_name) ||
        strcmp (NFMactive_item->item_name, item_name)   ||
        strcmp (NFMactive_item->item_rev, item_revision))
    {
      _NFMdebug ((fname, "Given input (catalog [%s] item [%s.%s])\n\
                 doesn't match the maintained information\n\
                 (catalog [%s] item [%s.%s])\n",
                catalog_name, item_name, item_revision,
                NFMactive_item->cat_name,
                NFMactive_item->item_name,
                NFMactive_item->item_rev));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
            "Failed to follow command order");
      free (NFMactive_item);
      MEMclose (&data_list);
      MEMclose (&NFMactive_data_list);
      return (NFM_E_BAD_COMMAND_ORDER);
    }
  }
  else
  {
    _NFMdebug ((fname, "Command out of order\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
            "Failed to follow command order");
    free (NFMactive_item);
    MEMclose (&data_list);
    MEMclose (&NFMactive_data_list);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (data list)0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&data_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  status = MEMbuild_array (NFMactive_data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (data list)0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&data_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  column = (char **) data_list->column_ptr;
  data = (char **) data_list->data_ptr;
  for (x=0; x < data_list->columns; x ++)
  {
    if (!strcmp (column[x], "n_status"))
      i_status = x;
    else if (!strcmp (column[x], "n_cisaname"))
      i_cisaname = x;
    else if (!strcmp (column[x], "n_cifilename"))
      i_cifilename = x;
    else if (!strcmp (column[x], "n_cofilename"))
      i_cofilename = x;
    else if (!strcmp (column[x], "n_filetype"))
      i_filetype = x;
    else if (!strcmp (column[x], "n_filenum"))
      i_filenum = x;
    else if (!strcmp (column[x], "n_fileno"))
      i_fileno = x;
    else if (!strcmp (column[x], "n_fileco"))
      i_fileco = x;
    else if (!strcmp (column[x], "n_fileversion"))
      i_fileversion = x;
    else if (!strcmp (column[x], "n_cifilesize"))
      i_cifilesize = x;
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
       NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    free (NFMactive_item);
    MEMclose (&data_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  if (operation == NFM_ADD_FILE_TO_ITEM)
  {
    status = NFMadd_files_to_item (catalog_name, NFMactive_item->item_no, 
             NFMactive_item->file_status, data_list);
    if (status != NFM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      NFMstart_transaction (0);
      free (NFMactive_item);
      MEMclose (&data_list);
      MEMclose (&NFMactive_data_list);
      _NFMdebug ((fname, "NFMadd_files_to_item 0x%.8x\n", status));
      return (status);
    }
  }
  else if (operation == NFM_DELETE_FILE_FROM_ITEM)
  {
    status = NFMdelete_files_from_item (catalog_name, NFMactive_item->item_no, 
         NFMactive_item->file_status, data_list);
    if (status != NFM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      NFMstart_transaction (0);
      _NFMdebug ((fname, "NFMdelete_files_from_item 0x%.8x\n", status));
      free (NFMactive_item);
      MEMclose (&data_list);
      MEMclose (&NFMactive_data_list);
      return (status);
    }
  }
  else if (operation == NFM_CHANGE_FILE_INFORMATION)
  {
    status = NFMchange_files_information (catalog_name, NFMactive_item->item_no,
         NFMactive_item->file_status, data_list);
    if (status != NFM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      NFMstart_transaction (0);
      _NFMdebug ((fname, "NFMchange_files_information 0x%.8x\n", status));
      free (NFMactive_item);
      MEMclose (&data_list);
      MEMclose (&NFMactive_data_list);
      return (status);
    }
  }

  status = NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    NFMstart_transaction (0);
    _NFMdebug ((fname, "NFMset_item_status 0x%.8x\n", status));
    free (NFMactive_item);
    MEMclose (&data_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  free (NFMactive_item);
  MEMclose (&NFMactive_data_list);
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));
 
  _NFMdebug ( (fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}


long NFMadd_files_to_item (cat_name, item_no, file_status, data_list)

/***
  This function will add file(s) to the item.

***/

char *cat_name;
long item_no;
char *file_status;
MEMptr data_list;

{
  char *fname="NFMadd_files_to_item";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024];
  char post_str[1024];
  char **column, **format;
  char **data1, **data2;
  char dumb_str[2];
  int index1, index2, index3;
  int x, y, z, index; 
  int remove=0;
  long max_file_no, file_no, max_file_version, file_version;
  long max_file_num, file_num;
  long found_sano, sto_no;
  long status;
  MEMptr list=NULL;
  struct NFMsto_info *sto_list;
  
  _NFMdebug ((fname, "ENTER:\n"));

  /* add this code to fix TR 92W1979 */
 
  data1 = (char **) data_list->data_ptr;  
  data2 = (char **) NFMactive_data_list->data_ptr;

  for (x = 1; x < data_list->rows; x ++)
  {
    index1 = data_list->columns * x;
    _NFMdebug ((fname, "%d: n_cifilename [%s] n_cofilename [%s]\n",
      x, (i_cifilename > -1)? data1[index1+i_cifilename]: "",
                data1[index1+i_cofilename]));

    if (i_cifilename > -1 && strlen (data1[index1+i_cifilename]))
    {
      for (y = 1; y < NFMactive_data_list->rows; y ++)
      {
        index2 = NFMactive_data_list->columns * y;
        if (strcmp (data1[index1+i_cifilename], 
                    data2[index2+i_cifilename]))
        {
          _NFMdebug ((fname, "%d: existing n_cifilename [%s]\n", y,
                             data2[index2+i_cifilename]));
        }
        else
        {
          _NFMdebug ((fname, "%d: matching existing n_cifilename [%s]\n",
                      y, data2[index2+i_cifilename]));
          ERRload_struct (NFM, NFM_E_DFI_DUPLICATE_CIFILENAME, "%s",
                           data1[index1+i_cifilename]);
          return (NFM_E_DFI_DUPLICATE_CIFILENAME);
        }
      }
      for (z = x - 1; z > 0; z --)
      {
        index3 = data_list->columns * z;
        if (strcmp (data1[index1+i_cifilename], 
                    data1[index3+i_cifilename]))
        {
          _NFMdebug ((fname, "%d: existing n_cifilename [%s]\n", z,
                             data1[index3+i_cifilename]));
        }
        else
        {
          _NFMdebug ((fname, "%d: matching existing n_cifilename [%s]\n",
                      z, data1[index3+i_cifilename]));
          ERRload_struct (NFM, NFM_E_DFI_DUPLICATE_CIFILENAME, "%s",
                           data1[index1+i_cifilename]);
          return (NFM_E_DFI_DUPLICATE_CIFILENAME);
        }
      }
    }
    /* it has to have a valid string for n_cofilename */
    for (y = 1; y < NFMactive_data_list->rows; y ++)
    {
      index2 = NFMactive_data_list->columns * y;
      if (strcmp (data1[index1+i_cofilename], 
                  data2[index2+i_cofilename]))
      {
        _NFMdebug ((fname, "%d: existing n_cofilename [%s]\n", y,
                           data2[index2+i_cofilename]));
      }
      else
      {
        _NFMdebug ((fname, "%d: matching existing n_cofilename [%s]\n",
                    y, data2[index2+i_cofilename]));
        ERRload_struct (NFM, NFM_E_DFI_DUPLICATE_COFILENAME, "%s",
                         data1[index1+i_cofilename]);
        return (NFM_E_DFI_DUPLICATE_COFILENAME);
      }
    }
    for (z = x - 1; z > 0; z --)
    {
      index3 = data_list->columns * z;
      if (strcmp (data1[index1+i_cofilename], 
                  data1[index3+i_cofilename]))
      {
        _NFMdebug ((fname, "%d: existing n_cofilename [%s]\n", z,
                           data1[index3+i_cofilename]));
      }
      else
      {
        _NFMdebug ((fname, "%d: matching existing n_cofilename [%s]\n",
                    z, data1[index3+i_cofilename]));
        ERRload_struct (NFM, NFM_E_DFI_DUPLICATE_COFILENAME, "%s",
                         data1[index1+i_cofilename]);
        return (NFM_E_DFI_DUPLICATE_COFILENAME);
      }
    }
  }

  sprintf (fcat_name, "f_%s", cat_name);

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", cat_name, 
                status));
    return (status);
  }

  /* retrieve the max(n_fileno) */
  sprintf (sql_str, "%s %s",
           "select max(n_fileno) from", fcat_name);

  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );

  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE,
             dumb_str, &file_no, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLquery (%s) failed 0x%.8x\n", 
                 sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to retrieve file informaiton");
    return (status);
  }
  max_file_no = file_no;
    
  _NFMdebug ( (fname, "retrieved max(n_fileno) = %d\n", max_file_no) );
  
      
  /* retrieve the max(n_fileversion) */

  sprintf (sql_str, "%s %s %s %d",
           "select max(n_fileversion) from",
            fcat_name, "where n_itemnum = ", item_no);
  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );
  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE,
           dumb_str, &file_version, &list);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ( (fname, "SQLquery (%s) failed 0x%.8x\n", 
                 sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to retrieve file informaiton");
    return (status);
  }
  max_file_version = file_version;

  _NFMdebug ((fname, "retrieved max(n_fileversion)[%d]\n",  max_file_version) );

  /* retrieve the max(n_filenum) */

  sprintf (sql_str, "%s %s %s %d",
           "select max(n_filenum) from",
            fcat_name, "where n_itemnum = ", item_no);
  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );
  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, 
           dumb_str, &file_num, &list);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ( (fname, "SQLquery (%s) failed 0x%.8x\n", 
                 sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to retrieve file informaiton");
    return (status);
  }
  max_file_num = file_num;

  /* remove the place holder */
  if (max_file_num == 0 && max_file_version == 0)
    remove = 1;

  _NFMdebug ((fname, "retrieved max(n_filenum)[%d]\n", max_file_num) );

  sto_list = (struct NFMsto_info *) calloc (data_list->rows - 1, 
                          sizeof (struct NFMsto_info) );
  if (sto_list == (struct NFMsto_info *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                     (data_list-> rows -1) * sizeof (struct NFMsto_info) );
    _NFMdebug ( (fname, "calloc sto_list failed\n") );
    return (NFM_E_MALLOC);
  }

  column = (char **) data_list->column_ptr;
  format = (char **) data_list->format_ptr;

  for (x = 1, sto_no = 0; x < data_list->rows; x++)
  {
    index = data_list->columns * x;
    _NFMdebug ( (fname, "row %d, data1[index+i_cisaname] = %s\n",
                  x, data1[index+i_cisaname]));

    for (y = 0; y < sto_no ; y++)
    {
      _NFMdebug ( (fname, "(sto_list+%d)->saname: %s \n", y, 
                   (sto_list+y)->saname));
      if ( !strcmp ((sto_list+y)->saname, data1[index+i_cisaname]) )
      {
        _NFMdebug ( (fname, "storage area name found in sto_list \n") ); 
        break;
      }
    }   
    if (y >= sto_no)
    {
      strcpy ((sto_list+sto_no)->saname, data1[index+i_cisaname]);
      sto_no++;
    }
  }

  status = NFMget_storages_information (sto_list, sto_no, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
    free (sto_list);
    return (status);
  }

  /* update f_<catalog> to add file(s) to the item. */

  for (x = 1; x < data_list->rows; x ++)
  {
    index = data_list->columns * x;
    _NFMdebug ( (fname, "row %d: cisaname [%s] cifilename [%s] \n\
                 cofilename [%s] filetype [%s]\n",
                 x, data1[index+i_cisaname],
                 (i_cifilename > -1)?data1[index+i_cifilename]:"", 
                 data1[index+i_cofilename],
                 (i_filetype > -1)?data1[index+i_filetype]:""));

    _NFMdebug ( (fname, "look for  sano of [%s]\n", data1[index+i_cisaname])); 
    for (y = 0, found_sano=0; y < sto_no; y++)
    {
      _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n", 
                            y, (sto_list+y)->saname) );
      if (!strcmp ((sto_list+y)->saname, data1[index+i_cisaname]))
      {
        _NFMdebug ( (fname, "found match in sto_list\n") );
        found_sano = (sto_list+y)->sano; 
        break;
      }
    }
        
    if (!strcmp (file_status, "") || !strcmp (file_status, "I") )
    {
      sprintf (sql_str, "%s %s %s %s",
             "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
             "n_fileversion, n_cisano, n_fileclass");
      sprintf (post_str, "%s %d, %d, %d, %d, %d, '%s'",
               ") values (", ++max_file_no, item_no, ++max_file_num,
               max_file_version, found_sano, "C");
    }
    else
    {
      sprintf (sql_str, "%s %s %s %s",
             "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
             "n_fileversion, n_cisano, n_couser, n_cosano, n_fileclass");
      sprintf (post_str, "%s %d, %d, %d, %d, %d, '%s', %d, '%s'",
               ") values (", ++max_file_no, item_no, ++max_file_num,
               max_file_version, found_sano, NFMglobal.NFMusername,
               NFMactive_item->cosano, "C");
    }

    for (y = 0; y < data_list->columns; y ++)
    {

      if (!strcmp(column[y], "n_fileno") || !strcmp(column[y],"n_itemnum") ||
          !strcmp(column[y], "n_filenum")|| !strcmp(column[y],"n_fileversion")
          || !strcmp(column[y], "n_cisaname")||!strcmp(column[y], "n_status" )||
          !strcmp (column[y], "n_cosano") || !strcmp (column[y], "n_couser") )
      {
        _NFMdebug ((fname, "don't add to the str\n"));
      }
      else
      {
        if (strlen (data1[index+y]))
        {
          if (strncmp (format[y], "char", 4))
          {
            strcat (sql_str, ",");
            strcat (sql_str, column[y]);
            strcat (post_str, ",");
            strcat (post_str, data1[index+y]);
          }
          else
          {
            strcat (sql_str, ",");
            strcat (sql_str, column[y]);
            strcat (post_str, ",");
            strcat (post_str, "'");
            strcat (post_str, data1[index+y]);
            strcat (post_str, "'");
          }
        }
      }
    }
    strcat (sql_str, post_str);
    strcat (sql_str, ")");
    _NFMdebug ( (fname, "exec qry: %s\n", sql_str));
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      free (sto_list);
      return (NFM_E_SQL_STMT);
    }
  }

  free (sto_list);

  if (remove)
  {
    sprintf (sql_str, "%s %s %s %d %s",
             "delete from", fcat_name, "where n_itemnum =",
             item_no, "and n_filenum = 0 and n_fileversion = 0");

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "SQLstmt(%s): 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt (COMMIT WORK) after add a file 0x%.8x\n",
                 status) );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);  
    return (status);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMdelete_files_from_item (cat_name, item_no, file_status, data_list)

/***
  This function will delete file(s) from the item.

***/

char *cat_name;
long item_no;
char *file_status;
MEMptr data_list;

{
  char *fname="NFMdelete_files_from_item";
  char fcat_name[NFM_CATALOGNAME+3];
  char **data, **data1;
  char *del_str;
  char row_str[1024], sql_str[1024], pre_str[526];
  char del_lfm[1024], del_saveset[1024];
  char del_value[10], dumb_str[2];
  char filename[NFM_CIFILENAME+1];
  int delete, zero, delete_file, file_no;
  int x, y, sto_no, index, found_sano, index1;
  long status;
  long cat_no, dumb_value;
  MEMptr file_list=NULL, dumb_list=NULL, list=NULL;
  struct NFMsto_info *sto_list;

  _NFMdebug ((fname, "ENTER: \n"));

  sprintf (fcat_name, "f_%s", cat_name);


  /* go down the list and retrieve the information of storage area(s) */

  sto_list = (struct NFMsto_info *) calloc (data_list->rows, 
                             sizeof (struct NFMsto_info) );
  if (!sto_list)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                    data_list->rows * sizeof (struct NFMsto_info) );
    _NFMdebug ( (fname, "calloc sto_list failed\n") );
    return (NFM_E_MALLOC);
  }

  data = (char **) data_list->data_ptr;

  for (x = 0, sto_no = 0; x < data_list->rows; x++)
  {
    index = data_list->columns * x;
    _NFMdebug ( (fname, "row %d, data[index+i_cisaname] = %s\n\
                 data[index+i_status] = %s\n", x,
                 data[index+i_cisaname], data[index+i_status]));

    if (!strlen (data[index+i_status]))
      continue;

    for (y = 0; y < sto_no ; y++)
    {
      _NFMdebug ( (fname, "(sto_list+%d)->saname: %s \n", y, 
                   (sto_list+y)->saname));
      if ( !strcmp ((sto_list+y)->saname, data[index+i_cisaname]) )
      {
        _NFMdebug ( (fname, "storage area name found in sto_list \n") ); 
        break;
      }
    }   
    if (y >= sto_no)
    {
      strcpy ((sto_list+sto_no)->saname, data[index+i_cisaname]);
      sto_no++;
    }
  }

  status = NFMget_storages_information (sto_list, sto_no, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
    free (sto_list);
    return (status);
  }
  del_str = (char *) malloc ((data_list->rows*DEL_CLAUSE_LENGTH+MAIN_LENGTH)
                             *sizeof(char));
  if (!del_str)
  {
    free (sto_list);
    ERRload_struct (NFM, NFM_E_MALLOC, "", NULL); /* COME BACK & FIX THIS */
    _NFMdebug ( (fname, "del_str = %ld, Error Malloc\n", del_str));
    return (NFM_E_MALLOC);
  }

  if (!strcmp (WFinfo.catalog_name, cat_name) && WFinfo.catalog_no > 0)
  {
    cat_no = WFinfo.catalog_no;
    _NFMdebug ((fname, "cat_no =%d\n", cat_no));
  }
  else
  {
    sprintf (sql_str, "%s '%s'",
             "select n_catalogno from nfmcatalogs where n_catalogname =",
             cat_name);
    status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
             &cat_no, &dumb_list);
    if (status != NFM_S_SUCCESS)
    {
      free (sto_list);
      free (del_str);
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "Failed to retrieve catalog's information");
      return (status);
    }
    _NFMdebug ((fname, "cat_no =%d\n", cat_no));
  }
 
  for (x = 0, delete = zero = delete_file = 0; x < data_list->rows; x++)
  {
    index = data_list->columns * x;

    if (!strlen (data[index+i_status]))
    {
      zero = 1;
      continue;
    }
      
    if (! delete)
    {
      sprintf (del_str, "%s %s %s %d %s %s ", 
               "delete from", fcat_name, "where n_itemnum = ",
               item_no, 
               "and (n_filenum = ", data[index+i_filenum]);
      delete = 1;
      sprintf (del_value, "%d", NFM_DELETE_FILE);
      status = NFMbuild_fto_buffer (&file_list, 0);
      if (status != NFM_S_SUCCESS)
      {
        free(sto_list);
        free (del_str);
        _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n",
                    status));
        return (status);
      } 

      sprintf (del_lfm, "%s %d %s %d %s %s",
               "delete from nfmsafiles where n_catalogno =",
               cat_no, "and n_itemno =", item_no,
               "and (n_filenum =", data[index+i_filenum]);

      sprintf (del_saveset, "%s %d %s %d %s %s",
               "delete from nfmsavesets where n_catalogno =",
               cat_no, "and n_itemno =", item_no,
               "and (n_fileno =", data[index+i_fileno]);


    }  
    else
    {
      strcat (del_str, "or n_filenum = ");
      strcat (del_str, data[index+i_filenum]);

      strcat (del_lfm, "or n_filenum = ");
      strcat (del_lfm, data[index+i_filenum]);

      strcat (del_saveset, "or n_fileno = ");
      strcat (del_saveset, data[index+i_fileno]);
    }
    if (strlen (data[index+i_fileco]) && 
        (strcmp (data[index+i_fileco], "Y") || 
         strcmp (data[index+i_fileco], "N")   ))
    {
      _NFMdebug ((fname, "there is a file to delete\n"));
    }
    else
    {
      _NFMdebug ((fname, "no file with this record\n"));
      continue;
    }

    _NFMdebug ((fname, "try to match %s\n", data[index+i_cisaname]));
    for (y = 0, found_sano=0; y < sto_no; y++)
    {
      _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n", 
                        y, (sto_list+y)->saname) );
      if (!strcmp ((sto_list+y)->saname, data[index+i_cisaname]))
      {
        _NFMdebug ( (fname, "found match in sto_list\n") );
        found_sano = (sto_list+y)->sano; 
        break;
      }
    }
    sprintf (row_str, 
       "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
       (sto_list+y)->sano,
       (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
       (sto_list+y)->pathname, (sto_list+y)->devicetype, 
       (sto_list+y)->plattername,
       (sto_list+y)->partition, (sto_list+y)->nfs,
       (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
       (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
       (sto_list+y)->netware);
    strcat (row_str, data[index+i_filenum]); strcat (row_str, "\1");
    strcat (row_str, "\1");
    if (strlen (data[index+i_cifilename]))
    {
      strcat (row_str, data[index+i_cifilename]); 
      strcat (row_str, "\1"); 
    }
    else
    {
      status = NFMget_file_name (NFMglobal.NFMuserid, cat_no,
               atol(data[index+i_fileno]), filename); 
      strcat (row_str, filename);
      strcat (row_str, "\1");
    }
    strcat (row_str, (i_cofilename > -1)?data[index+i_cofilename]:""); 
    strcat (row_str, "\1"); 
    strcat (row_str, (i_filetype > -1)?data[index+i_filetype]:""); 
    strcat (row_str, "\1"); 
    strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1"); 
    strcat (row_str, del_value); strcat (row_str, "\1\1\1"); 
    _NFMdebug ((fname, "row %d: %s\n", x, row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      free (sto_list);
      free (del_str);
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      MEMclose (&file_list);
      return (status);
    }
    delete_file = 1;
    sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %s",
     "select n_fileno, n_cifilename, n_fileversion, n_fileco, n_filetype,",
     "n_cifilesize, n_archiveno from",
     fcat_name, "where n_itemnum =", item_no, "and n_filenum =",
     data[index+i_filenum], "and n_fileversion <", 
     data[index+i_fileversion], 
     "and (n_fileco = 'Y' or n_fileco = 'N' or n_fileco = 'O')");

    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
             &dumb_value, &list);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "no previous file(s) need to be deleted \n"));
      MEMclose (&list);
    }
    else if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMretrieve_values: (previous version) 0x%.8x\n",
                    status));
      free (sto_list);
      free (del_str);
      _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      MEMclose (&file_list);
      return (status);
    }
    else
    {
      sprintf (pre_str, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (sto_list+y)->sano,
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
        (sto_list+y)->pathname, (sto_list+y)->devicetype, 
        (sto_list+y)->plattername,
        (sto_list+y)->partition, (sto_list+y)->nfs,
        (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
        (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
        (sto_list+y)->netware);
      _NFMdebug ((fname, "pre_str [%s]\n", pre_str));
      data1 = (char **) list->data_ptr;
      for (y = 0; y < list->rows; y++)
      {
        index1 = list->columns * y;

        /* index1 + 6 => n_archiveno, if there is a value, clean up nfmsaveset;
           index1 + 3 => n_fileco, file is purged.
        */

        if ( strlen (data1[index1+6]))
        {
          _NFMdebug ((fname, "this file is backed-up/archived \n"));
          strcat (del_saveset, "or n_fileno = ");
          strcat (del_saveset, data1[index1]);
        }

        if (! strcmp (data1[index1+3], "O"))
          continue;

        strcpy (row_str, pre_str);
        strcat (row_str, data1[index1]); strcat (row_str, "\1\1");
        status = NFMget_file_name (0, cat_no,
                           atol (data1[index1]), filename);
        if (status != NFM_S_SUCCESS)
        {
          free (sto_list);
          free (del_str);
          MEMclose (&list);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          MEMclose (&file_list);
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1\1");
        strcat (row_str, data1[index1+4]); strcat (row_str, "\1");
        strcat (row_str, data1[index1+5]); strcat (row_str, "\1");
        strcat (row_str, del_value); strcat (row_str, "\1\1\1");
        _NFMdebug ((fname, "row_str [%s]\n", row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          free (sto_list);
          free (del_str);
          MEMclose (&list);
          _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          MEMclose (&file_list);
          return (status);
        }
      }
      MEMclose (&list);
    }
  }
  
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

  if (delete_file)
  {
    status = NFMfs_chg_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMfs_chg_files 0x%.8x\n", status));
      /* for each file that is deleted, delete the record, otherwise, skip */
    }
  }
  MEMclose (&file_list);

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", cat_name, 
                status));
    free (sto_list);
    free (del_str);
    return (status);
  }
  strcat (del_str, ")");
  status = SQLstmt (del_str);
  if (status != SQL_S_SUCCESS)
  {
    free (sto_list);
    free (del_str);
    _NFMdebug ( (fname, "SQLstmt(%s) failed 0x%.8x\n", del_str, status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);  
    return (status);
  }

  if (NFM_FTR_INITED)
  {
  for (x = 0; x < data_list->rows; x++)
  {
    index = data_list->columns * x;
    _NFMdebug ((fname, "mark [%s] to be deleted in the collection\n",
                        data[index+i_fileno]));
    status = NFT_delete_entry (cat_no, item_no, atol(data[index + i_fileno]));
    if (status != UTI_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFT_delete_entry 0x%.8x\n", status));
    }
    else
    {
      _NFMdebug ((fname, "NFT_delete_entry successfully\n"));
    }
        ERRreset_struct ();
  }
  }

  free (del_str);
  free (sto_list);

  if (!zero)
  {
    _NFMdebug ((fname, "delete all files associated, put a place holder\n"));
    sprintf (sql_str, "%s f_%s",
             "select max(n_fileno) from", cat_name);
    status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                 &file_no, &dumb_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMretrieve_values(%s): 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
         "Failed to retrieve file information");
      return (status);
    }
    sprintf (sql_str, "%s f_%s %s %s %d, %d, %d, %d, '%s' %s",
             "insert into", cat_name, "(n_fileno, n_itemnum, n_filenum, ",
             "n_fileversion, n_fileclass) values (", 
             ++file_no, item_no, 0, 0, "C", ")");
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLstmt(%s): 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);  
      return (status);
    }
    strcpy (file_status, "");
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt (COMMIT WORK) after add a file 0x%.8x\n",
                 status) );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (status);
  }

  strcat (del_lfm, ")");
  status = SQLstmt (del_lfm);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
                    "Delete Files from Item", 
                    "cleaning up local file manager table");
  }

  strcat (del_saveset, ")");
  status = SQLstmt (del_saveset);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s",
                    "Delete Files from Item", 
                    "cleaning up nfmsaveset table");
  }
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMchange_files_information (cat_name, item_no, file_status, data_list)

/***
  This function will change file(s) information.
***/

char *cat_name;
long item_no;
char *file_status;
MEMptr data_list;

{

  char *fname="NFMchange_files_information";
  char fcat_name[NFM_CATALOGNAME+3];
  char dest_val[10], rename_val[10], move_val[10];
  char **data, **g_data, **data1, **column;
  char **format;
  char sql_str[1024], post_str[1024], upd_cifname[1024];
  char row_str[1024], row_dest[1024], row_src[1024], dumb_str[2];
  char file_name[NFM_CIFILENAME+1];
  char sano_str[10], temp_str[10];
  int index, index1, found_sano;
  int x, y, z, index_no, sto_no, and, comma;
  int *indexes;
  long status, dumb_value, upd_cif=0, upd_cisano=0;
  long status1;
  MEMptr file_list=NULL, dumb_list=NULL, list=NULL;
  struct NFMsto_info *sto_list;


  _NFMdebug ((fname, "ENTER:\n"));


  sprintf (fcat_name, "f_%s", cat_name);

  sprintf (dest_val, "%d", NFM_DESTINATION);
  sprintf (rename_val, "%d", NFM_RENAME);
  sprintf (move_val, "%d", NFM_MOVE);

  data = (char **)data_list->data_ptr;
  g_data = (char **) NFMactive_data_list->data_ptr;

  /* The following loop will make sure the users did not change local file
     name when item is out */
 
  for (x = 0; x < data_list->rows; x ++)
  {
    index = data_list->columns * x;
    _NFMdebug ((fname, "row %d, filenum = %s data[index+i_status] = %s\n",
                        x, data[index+i_filenum], data[index+i_status]));
    if (!strlen (data[index+i_status]))
      continue;
    if ((i_cofilename > -1) && 
        strcmp (data[index+i_cofilename], g_data[index+i_cofilename]))
    {
      if ( !strncmp (file_status, "O", 1) ||
           !strncmp (file_status, "S", 1) ||
           !strncmp (file_status, "M", 1)    )
      {
        ERRload_struct (NFM, NFM_E_DFI_NO_COFILE_CHG, "", NULL); 
        _NFMdebug ( (fname, 
                 "Local filename cannot be changed while the item is out\n") );
        return (NFM_E_DFI_NO_COFILE_CHG);
      }
    }
  }

  /* VARIABLE "indexes" keeps the indexes into data_list that indicates
     the cisaname, cifilename changes. */

  indexes = (int *) malloc (data_list->rows * sizeof (int));

  /* VARIABLE "sto_list" keeps all the storage areas and nodes information
     that will be needed */

  sto_list = (struct NFMsto_info *) calloc (2 * data_list->rows,
                            sizeof (struct NFMsto_info) );
  if (!sto_list || !indexes)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", sizeof (struct NFMsto_info) );
    _NFMdebug ( (fname, "calloc sto_list failed\n") );
    return (NFM_E_MALLOC);
  }
  
  for (x = 0, index_no = sto_no = 0; x < data_list->rows; x ++)
  {
    index = data_list->columns * x;
    _NFMdebug ((fname, "row %d, filenum = %s data[index+i_status] = %s\n",
                        x, data[index+i_filenum], data[index+i_status]));
    if (!strlen (data[index+i_status]))
      continue;
    if ((i_cisaname > -1) && 
        strcmp (data[index+i_cisaname], g_data[index+i_cisaname]))
    {
      _NFMdebug ((fname, "cisaname is requested to change\n\
                  new cisaname [%s] old cisaname [%s]\n",
                  data[index+i_cisaname], g_data[index+i_cisaname]));

      /* check to see if the destination cisaname already on the list */

      /* check the destination location */
      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname: %s \n", y,
                     (sto_list+y)->saname));
        if ( !strcmp ((sto_list+y)->saname, data[index+i_cisaname]) )
        {
          _NFMdebug ( (fname, "storage area name found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        strcpy ((sto_list+sto_no)->saname, data[index+i_cisaname]);
        sto_no++;
      }

      /* check the source location */
      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname: %s \n", y,
                     (sto_list+y)->saname));
        if ( !strcmp ((sto_list+y)->saname, g_data[index+i_cisaname]) )
        {
          _NFMdebug ( (fname, "storage area name found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        strcpy ((sto_list+sto_no)->saname, g_data[index+i_cisaname]);
        sto_no++;
      }

      *(indexes+index_no) = x;
      index_no ++;
    }
    else if ((i_cifilename > -1) &&
             strcmp (data[index+i_cifilename], g_data[index+i_cifilename]) &&
             (!strcmp (data[index+i_fileco], "Y") ||
             !strcmp (data[index+i_fileco], "N")     ) )
    {
      _NFMdebug ((fname, "cifilename is requested to change\n\
                  new cifilename [%s] old cifilename [%s]\n",
                  data[index+i_cisaname], g_data[index+i_cisaname]));

      /* check to see if the cisaname already on the list */

      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname: %s \n", y,
                     (sto_list+y)->saname));
        if ( !strcmp ((sto_list+y)->saname, data[index+i_cisaname]) )
        {
          _NFMdebug ( (fname, "storage area name found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        strcpy ((sto_list+sto_no)->saname, data[index+i_cisaname]);
        sto_no++;
      }

      *(indexes+index_no) = x;
      index_no ++;
    }
  }
  /* at this point, I have a list of storage names, so retrieve all the
     information from nfmstoragearea and nfmnodes table. */

  status = NFMget_storages_information (sto_list, sto_no, 0);
  if (status != NFM_S_SUCCESS)
  {
    free (sto_list);
    free (indexes);
    _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
    return (status);
  }

  /* prepare the buffer for File Server */

  if (index_no)
  {
    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      free(sto_list);
      free (indexes);
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n",
                  status));
      return (status);
    }
    if (!strcmp (WFinfo.catalog_name, cat_name) && WFinfo.catalog_no > 0)
    {
      NFMactive_item->cat_no = WFinfo.catalog_no;
      _NFMdebug ((fname, "cat_no =%d\n", NFMactive_item->cat_no));
    }
    else
    {
      sprintf (sql_str, "%s '%s'",
             "select n_catalogno from nfmcatalogs where n_catalogname =",
             cat_name);
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
             &(NFMactive_item->cat_no), &dumb_list);
      if (status != NFM_S_SUCCESS)
      {
        free (sto_list);
        free (indexes);
        MEMclose (&file_list);
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
           "Failed to retrieve catalog's information");
        return (status);
      }
    }
  }

  for (x = 0; x < index_no; x ++)
  {
    index = data_list->columns * (*(indexes+x));
    _NFMdebug ((fname, "row %d, filenum = %s data[index+i_status] = %s\n",
                        *(indexes+x), data[index+i_filenum], 
                        data[index+i_status]));
    if (strcmp (data[index+i_cisaname], g_data[index+i_cisaname]) &&
        strlen (data[index+i_fileco]) )
    {
      _NFMdebug ((fname, "cisaname is requested to change\n"));
      /** need to do it for previous versions **/
      for (y = 0, found_sano=0; y < sto_no; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n", 
                        y, (sto_list+y)->saname) );
        if (!strcmp ((sto_list+y)->saname, data[index+i_cisaname]))
        {
          _NFMdebug ( (fname, "found match in sto_list\n") );
          found_sano = (sto_list+y)->sano; 
          break;
        }
      }
      sprintf (row_dest, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (sto_list+y)->sano,
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
        (sto_list+y)->pathname, (sto_list+y)->devicetype, 
        (sto_list+y)->plattername,
        (sto_list+y)->partition, (sto_list+y)->nfs, 
        (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
        (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
        (sto_list+y)->netware);
      strcat (row_dest, "\1");
      strcat (row_dest, "\1");
      strcat (row_dest, "\1"); 
      strcat (row_dest, "\1"); /* cofilename */
      strcat (row_dest, (i_filetype > -1)?data[index+i_filetype]:""); 
      strcat (row_dest, "\1");
      strcat (row_dest, "\1");
      strcat (row_dest, dest_val); strcat (row_dest, "\1\1\1");
      _NFMdebug ((fname, "row %d: %s\n", *(indexes+x), row_dest));
      if (strcmp (NFMactive_item->archive, "A"))
      {
        _NFMdebug ((fname, "Not archived\n"));
        status = MEMwrite (file_list, row_dest);
        if (status != MEM_S_SUCCESS)
        {
          free (sto_list);
          free (indexes);
          MEMclose (&file_list);
          _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          return (status);
        }
      }
      for (y = 0, found_sano=0; y < sto_no; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n", 
                        y, (sto_list+y)->saname) );
        if (!strcmp ((sto_list+y)->saname, g_data[index+i_cisaname]))
        {
          _NFMdebug ( (fname, "found match in sto_list\n") );
          found_sano = (sto_list+y)->sano; 
          break;
        }
      }
      sprintf (row_src, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (sto_list+y)->sano,
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
        (sto_list+y)->pathname, (sto_list+y)->devicetype, 
        (sto_list+y)->plattername,
        (sto_list+y)->partition, (sto_list+y)->nfs, 
        (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
        (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
        (sto_list+y)->netware);
      if (strcmp (NFMactive_item->archive, "A"))
      {
        strcpy (row_str, row_src);
        strcat (row_str, data[index+i_filenum]); strcat (row_str, "\1");
        strcat (row_str, "\1");
        if (strlen (g_data[index+i_cifilename]))
        {
          strcat (row_str, g_data[index+i_cifilename]); strcat (row_str, "\1");
        }
        else
        {
          status = NFMget_file_name (0, NFMactive_item->cat_no, 
                               atol (data[index+i_fileno]), file_name);
          if (status != NFM_S_SUCCESS)
          {
            free (sto_list);
            free (indexes);
            MEMclose (&file_list);
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            return (status);
          }
          strcat (row_str, file_name); strcat (row_str, "\1");
        }
        if (strlen (data[index+i_cifilename]))
        {
          strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
        }
        else
        {
          status = NFMget_file_name (0, NFMactive_item->cat_no, 
                               atol (data[index+i_fileno]), file_name);
          if (status != NFM_S_SUCCESS)
          {
            free (sto_list);
            free (indexes);
            MEMclose (&file_list);
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            return (status);
          }
          strcat (row_str, file_name); strcat (row_str, "\1");
        }
        strcat (row_str, (i_filetype > -1)?data[index+i_filetype]:""); 
        strcat (row_str, "\1");
        strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
        strcat (row_str, move_val); strcat (row_str, "\1\1\1");
        _NFMdebug ((fname, "row %d: %s\n", *(indexes+x), row_str));
        status = MEMwrite (file_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          free (sto_list);
          free (indexes);
          MEMclose (&file_list);
          _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          return (status);
        }
      }
      
      sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %s",
      "select n_fileno, n_cifilename, n_fileversion, n_fileco, n_filetype,",
      "n_cifilesize from",
               fcat_name, "where n_itemnum =", item_no, "and n_filenum =",
          data[index+i_filenum], "and n_fileversion <", 
          data[index+i_fileversion], "and (n_fileco = 'Y' or n_fileco = 'N')");

      status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                   &dumb_value, &list);
      if (status == SQL_I_NO_ROWS_FOUND)
      {
        _NFMdebug ((fname, "no previous file(s) need to be moved \n"));
        MEMclose (&list);
      }
      else if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMretrieve_values: (previous version) 0x%.8x\n",
                    status));
        free (sto_list);
        free (indexes);
        MEMclose (&file_list);
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        return (status);
      }
      else
      {
        data1 = (char **) list->data_ptr;
        for (y = 0; y < list->rows; y++)
        {
          index1 = list->columns * y;
          _NFMdebug ((fname, "MEMwrite [%s]\n", row_dest));
          status = MEMwrite (file_list, row_dest);
          if (status != MEM_S_SUCCESS)
          {
            free (sto_list);
            free (indexes);
            MEMclose (&file_list);
            _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            return (status);
          }
          strcpy (row_str, row_src);
          strcat (row_str, data1[index1]); strcat (row_str, "\1\1");
          status = NFMget_file_name (0, NFMactive_item->cat_no,
                             atol (data1[index1]), file_name);
          if (status != NFM_S_SUCCESS)
          {
            free (sto_list);
            free (indexes);
            MEMclose (&file_list);
            MEMclose (&list);
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            return (status);
          }
          strcat (row_str, file_name); strcat (row_str, "\1");
          strcat (row_str, file_name); strcat (row_str, "\1");
          strcat (row_str, data1[index1+4]); strcat (row_str, "\1");
          strcat (row_str, data1[index1+5]); strcat (row_str, "\1");
          strcat (row_str, move_val); strcat (row_str, "\1\1\1");
          _NFMdebug ((fname, "row_str [%s]\n", row_str));
          status = MEMwrite (file_list, row_str);
          if (status != MEM_S_SUCCESS)
          {
            free (sto_list);
            free (indexes);
            MEMclose (&file_list);
            MEMclose (&list);
            _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            return (status);
          }
        }
        MEMclose (&list);
      }
    }
    else if (strcmp (data[index+i_cifilename], g_data[index+i_cifilename]) &&
             (!strcmp (data[index+i_fileco], "Y") ||
             !strcmp (data[index+i_fileco], "N") )  )
    {
      _NFMdebug ((fname, "cifilename is requested to change\n"));

      for (y = 0, found_sano=0; y < sto_no; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n", 
                        y, (sto_list+y)->saname) );
        if (!strcmp ((sto_list+y)->saname, data[index+i_cisaname]))
        {
          _NFMdebug ( (fname, "found match in sto_list\n") );
          found_sano = (sto_list+y)->sano; 
          break;
        }
      }
      sprintf (row_str, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        (sto_list+y)->sano,
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
        (sto_list+y)->pathname, (sto_list+y)->devicetype, 
        (sto_list+y)->plattername,
        (sto_list+y)->partition, (sto_list+y)->nfs, 
        (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
        (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
        (sto_list+y)->netware);
      strcat (row_str, data[index+i_filenum]); strcat (row_str, "\1");
      strcat (row_str, "\1");
      if (strlen (g_data[index+i_cifilename]))
      {
        strcat (row_str, g_data[index+i_cifilename]); strcat (row_str, "\1");
      }
      else
      {
        status = NFMget_file_name (0, NFMactive_item->cat_no,
                               atol (data[index+i_fileno]), file_name);
        if (status != NFM_S_SUCCESS)
        {
          free (sto_list);
          free (indexes);
          MEMclose (&file_list);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          return (status);
        }
        strcat (row_str, file_name); strcat (row_str, "\1");
      }
      if (strlen (data[index+i_cifilename]))
      {
        strcat (row_str, data[index+i_cifilename]); 
        strcat (row_str, "\1");
      }
      else
      {
        status = NFMget_file_name (0, NFMactive_item->cat_no,
                               atol (data[index+i_fileno]), file_name);
        if (status != NFM_S_SUCCESS)
        {
          free (sto_list);
          free (indexes);
          MEMclose (&file_list);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          return (status);
        }
        strcat (row_str, file_name); 
        strcat (row_str, "\1");
      }
      strcat (row_str, (i_filetype > -1)?data[index+i_filetype]:""); 
      strcat (row_str, "\1");
      strcat (row_str, (i_cifilesize > -1)?data[index+i_cifilesize]:"");
      strcat (row_str, "\1");
      strcat (row_str, rename_val); strcat (row_str, "\1\1\1");
      _NFMdebug ((fname, "row %d: %s\n", *(indexes+x), row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        free (sto_list);
        free (indexes);
        MEMclose (&file_list);
        _NFMdebug ((fname, "MEMwrite %s 0x%.8x\n", row_str, status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
    }
  }

  if (index_no)
  {
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    status = NFMfs_chg_files (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMfs_chg_files 0x%.8x\n", status));
      status1 = _NFMextract_info_from_buf (status, file_list,
                DM_MANAGER, NFM_CHANGE_FILE_INFORMATION, NFM_SINGLE_ERROR,
                NFMactive_item->cat_name, NFMactive_item->item_name,
                NFMactive_item->item_rev);
      if (status1 == NFM_E_ERROR_NOT_LOADED)
      {
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Failed to move files");
      }
      free (sto_list);
      free (indexes);
      MEMclose (&file_list);
      return (status);
    }
  }
  free (indexes);

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, 
                status));
    if (index_no)
      NFMfs_undo_chg_files (&file_list);
    free (sto_list);
    MEMclose (&file_list);
    return (status);
  }

  column = (char **) data_list->column_ptr;
  format = (char **) data_list->format_ptr;
  for (x = upd_cif = 0; x < data_list->rows; x ++)
  {
    index = data_list->columns * x;
    if (!strlen (data[index+i_status]))
      continue;

    sprintf (sql_str, "%s %s %s",
             "update", fcat_name, "set ");
    sprintf (upd_cifname, "%s %s %s",
             "update", fcat_name, "set ");
    strcpy (post_str, "\0");
    
    for (y = and = comma = 0; y < data_list->columns; y ++)
    {
      _NFMdebug ((fname, "column[%d]=[%s],format[%d]=[%s],data[%d]=[%s]\n",
         y, column[y], y, format[y], index+y, data[index+y]));

      if ( !strcmp(column[y], "n_cisaname"))
      {
        if (strcmp (data[index+y], g_data[index+y]))
        {
          strcat (sql_str, "n_cisano = ");
          for (z = 0, found_sano=0; z < sto_no; z++)
          {
            _NFMdebug ( (fname, "(sto_list+%d)->saname = %s\n",
                            z, (sto_list+z)->saname) );
            if (!strcmp ((sto_list+z)->saname, data[index+y]))
            {
              _NFMdebug ( (fname, "found match in sto_list\n") );
              found_sano = (sto_list+z)->sano;
              break;
            }
          }
          sprintf (sano_str, "%d", (sto_list+z)->sano);
          strcat (sql_str, sano_str);
          upd_cisano = 1;
        }
      }
      else if (!strcmp(column[y], "n_fileno") || 
               !strcmp(column[y],"n_fileversion") ||
               !strcmp(column[y],"n_fileco") ||
               !strcmp(column[y], "n_status") ||
               !strcmp(column[y], "n_cosano") ||
               !strcmp(column[y], "n_couser")    )
      {
      }
      else if (!strcmp(column[y], "n_filenum"))
      {
        strcat (post_str, " where ");
        strcat (post_str, column[y]);
        strcat (post_str, " = ");
        strcat (post_str, data[index+y]);
      }
      else if ( !strcmp(column[y], "n_cifilename"))
      {
        if (strcmp (data[index+y], g_data[index+y]))
        {
          if (comma)
            strcat (upd_cifname, ",");
          else 
            comma = 1;
          strcat (upd_cifname, "n_cifilename = '");
          strcat (upd_cifname, data[index+y]);
          strcat (upd_cifname, "'");
          upd_cif = 1;
        }
      }
      else
      {
        if (!strncmp (format[y], "char", 4))
        {
          if (comma)
            strcat (upd_cifname, ",");
          else 
            comma = 1;
          strcat (upd_cifname, column[y]);
          strcat (upd_cifname, " = '");
          strcat (upd_cifname, data[index+y]);
          strcat (upd_cifname, "'");
        }
        else if (strlen (data[index+y]))
        {
          if (comma)
            strcat (upd_cifname, ",");
          else 
            comma = 1;
          strcat (upd_cifname, column[y]);
          strcat (upd_cifname, " = ");
          strcat (upd_cifname, data[index+y]);
        }
        upd_cif = 1;
      }
    }
    sprintf (temp_str, "%d",item_no);
    if (upd_cisano)
    {
      strcat (sql_str, post_str);
      strcat (sql_str, " and n_itemnum = ");
      strcat (sql_str, temp_str);
      _NFMdebug ( (fname, "upd_cisano (%d) exec qry: %s\n", upd_cif, sql_str));
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        free (sto_list);
        if (index_no)
        NFMfs_undo_chg_files (&file_list);
        MEMclose (&file_list);
        _NFMdebug ( (fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        NFMrollback_transaction (0);  /* undo any database changes */
        return (status);
      }
      upd_cisano = 0;
    }
    if (upd_cif)
    {
      strcat (upd_cifname, post_str);
      strcat (upd_cifname, " and n_itemnum = ");
      strcat (upd_cifname, temp_str);
      strcat (upd_cifname, " and n_fileversion = ");
      strcat (upd_cifname, data[index+i_fileversion]);
      status = SQLstmt (upd_cifname);
      if (status != SQL_S_SUCCESS)
      {
        free (sto_list);
        if (index_no)
        NFMfs_undo_chg_files (&file_list);
        MEMclose (&file_list);
        _NFMdebug ( (fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);  
        NFMrollback_transaction (0);  /* undo any database changes */
        return (status);
      }
      upd_cif = 0;
    }
  }
  free (sto_list);
  MEMclose (&file_list);

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt (COMMIT WORK) after add a file 0x%.8x\n",
                 status) );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (status);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
