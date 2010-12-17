#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "WFstruct.h"
#include "NFMstruct.h"

#define NFM_ATTR_NAME_MAX_SIZE 60
#define NFM_ATTR_VALUE_MAX_SIZE 60
#define NFM_TOL 360

struct NFMactive *NFMactive_item;
MEMptr NFMactive_data_list=NULL;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;

long NFMget_file_information (catalog_name, item_name, item_revision, operation,
                              attr_list, data_list, value_list)

/*******************************************************************************
  03/09/92 From nfmvalues table, n_defaultno is not used.
           If n_type == "A",  n_listno == n, n is unique in nfmlist
           If n_type == "C", n_listno = m, m could have > 1 occurence in
           nfmlist.
*******************************************************************************/

char *catalog_name, *item_name, *item_revision;
long operation;
MEMptr *attr_list, *data_list, *value_list;

{
  char *fname="NFMget_file_information";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], *sql_str2;
  char row_str[1024], *row_str2;
  char list_str[1024];
  char *value_str2;
  char *first_row;
  char **data, **data1, **data2, **dataj, **list_data, **list2_data;
  char dumb_str[2];
  char temp_value [100];
  int  x, y, z, or, list_no=0; 
  int  i_cofilename=-1, i_cisano=-1, i_archiveno=-1,i_cifilename=-1, 
       i_filenum=-1, i_couser=-1, i_cosano=-1;
  int comma, j, indexj;
  int cisano_default=0, cisano_write=0, cisano_update=0, cifile_update=0;
      /* the above three var work together */
  int chk_user=0, get_cosano=0; /* check co user for add/change files,
                                   record cosano for add files request */
  long status;
  long fcat_no, cat_no, index, index1, index2;
  long dumb_value; 
  long attrno1=0, attrno2=0;
  MEMptr list=NULL, list1=NULL, list2 = NULL, temp_value_list=NULL;
  MEMptr temp_value_list1=NULL;
  struct NFMbuf_format *format;

  _NFMdebug ((fname, "ENTER: catalog[%s] item[%s.%s] operation[%d]\n", 
              catalog_name, item_name, item_revision, operation));


  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    return (status);
  }

  /* lock <catalog> table, retrieve the file status */

  status = NFMlock_table (catalog_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlock_table (%s) 0x%.8x\n", catalog_name, status));
    return (status);
  }

  sprintf (sql_str, "%s '%s' %s '%s'",
           "where n_itemname = ", item_name, "and n_itemrev = ", item_revision);

  status = NFMcommon_queries (catalog_name, sql_str, dumb_str, &dumb_value, 
             &list, NFM_ITEM_QUERY, NFM_RETURN_MEMPTR, 
               NFM_NO_LOCK);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "SQLquery(%s) failed 0x%.8x\n", sql_str) );
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (status);
  }

  NFMactive_item = (struct NFMactive *) calloc (1, sizeof (struct NFMactive));

  list_data = (char **) list->data_ptr;
  NFMactive_item->item_no = atol (list_data[0]);
  strcpy (NFMactive_item->archive, list_data[2]);
  strcpy (NFMactive_item->file_status, list_data[1]);
  NFMactive_item->command = NFM_GET_FILE_INFO;
  strcpy (NFMactive_item->cat_name, catalog_name);
  strcpy (NFMactive_item->item_name, item_name);
  strcpy (NFMactive_item->item_rev, item_revision);
  _NFMdebug ( (fname, "retrieved item number [%d], file status [%s]\n",
               NFMactive_item->item_no, NFMactive_item->file_status) );

  status = NFMcheck_catalog_attributes (item_name, item_revision,
             list, operation);

  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    free (NFMactive_item);
    MEMclose (&list);
    return (status);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ( (fname, "MEMclose (list contains item number) 0x%.8x\n",
                         status) );
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    return (status);
  }

  status = NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
             "TF", NFM_NO_LOCK , "");
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMset_item_status [%d] [%s] failed 0x%.8x\n",
                 NFMactive_item->item_no, "TF") );
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
                        NFMactive_item->file_status, NFM_NO_LOCK, "" );
    NFMrollback_transaction (0);
    free (NFMactive_item);
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt (COMMIT WORK to table %s) failed 0x%.8x\n",
                 status) );
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
                        NFMactive_item->file_status, NFM_NO_LOCK , "");
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    free (NFMactive_item);
    return (status);
  }

  /* retrieve the table number for  f_<catalog> && <catalog> and save in the 
     global*/

  sprintf (fcat_name, "f_%s", catalog_name);

  status = NFMget_cat_fcat_no (catalog_name, &cat_no, &fcat_no, 0);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "" );
    _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    free (NFMactive_item);
    return (status);
  }

  _NFMdebug ((fname, "Retrieved cat_no [%d], fcat_no [%d]\n", 
                                cat_no, fcat_no));

  /* retrieve the attributes from nfmattributes table based on n_update */

  if (operation == NFM_ADD_FILE_TO_ITEM)
  {
    /* 8/24/92 n_write is added because of TR 92W2339 */
    sprintf (sql_str, "%s %s %d %s %s",
           "select n_attrno, n_name, n_synonym, n_datatype, n_null, n_read,",
           "n_write from nfmattributes where n_tableno =",
           fcat_no, 
           "and (n_write = 'Y' or n_name = 'n_cisano' or n_name = 'n_filenum'",
           "or n_name = 'n_cosano' or n_name = 'n_couser') order by n_attrno");
  }
  else
  {
    /* 9/30/92 n_update is added because of TR 92W3438 */
    sprintf (sql_str, "%s %s %d %s %s %s %s %s",
      "select n_attrno, n_name, n_synonym, n_datatype, n_null, n_read,",
      "n_write, n_update from nfmattributes where n_tableno =",
      fcat_no, 
      "and (n_update = 'Y' or n_name = 'n_filenum' or n_name = 'n_fileno'",
      "or n_name = 'n_fileco' or n_name = 'n_fileversion' or ",
      "n_name = 'n_archiveno' or n_name = 'n_cosano' or n_name = 'n_couser'",
      "or n_name = 'n_cifilesize' or n_name = 'n_cifilename'",
      "or n_name = 'n_cisano') order by n_attrno");
  }

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                              &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
       NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMretrieve_values (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    return (status);
  }

  if (list->rows == 4 && (operation == NFM_ADD_FILE_TO_ITEM))
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
       NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "No writable file attributes\n"));
    ERRload_struct (NFM, NFM_E_DFI_NO_W, "", NULL);
    NFMstart_transaction (0);
    free (NFMactive_item);
    MEMclose (&list);
    return (NFM_E_DFI_NO_W);
  }

  status = MEMopen (data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMopen (data_list) 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    return (status);
  }

  status = MEMopen (&NFMactive_data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    return (status);
  }

  /* list looks like the following:

     n_attrno | n_name       | n_synonym        | n_datatype  | n_null | n_write
     ---------|--------------|------------------|-------------|--------|--------
      17      | n_filenum (*)| File Number      |   ...       | ...    |  ...
      29      | n_cifilename | Storage Filename |   ...       | ...    |
      31      | n_cofilename | Local Filename   |   ...       | ...    |
      35      | n_filetype   | File Type        |   ...       | ...    |
      49      | n_cisano     | Storage Location |   ...       | ...    |
      .
      .

     attr_list will look like the following:

     n_synonym        | n_null | n_read | n_adviceno | n_valueno
     -----------------|--------|--------|------------|----------
     File Number (*)  | N      | N      |  ""         | "" 
     Storage Filename | Y      | Y      |  ""         | ""
     Local filename   | N (**) | Y      |  ""         | ""
     File Type        | Y      | Y      |  ""         | ""
     Storage Location | N (**) | Y      |  ""         | ""
      .
      .

     Note:
     ** -- override values

     data_list will look the following:

     n_filenum |n_cifilename |n_cofilename |n_filetype |n_cisaname ........
     ----------|-------------|-------------|-----------|--------------------
       1       |             | file1.txt   |           | STO1
       2       |             | file2.txt   |           | STO1
      
  */

  status = MEMopen (attr_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  format = (struct NFMbuf_format *) calloc (5, sizeof (struct NFMbuf_format));

  if (format == (struct NFMbuf_format *) NULL)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "malloc for format failed \n"));
    ERRload_struct (NFM, NFM_E_MALLOC, "%d",  
                         5 * sizeof (struct NFMbuf_format));
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    return (NFM_E_MALLOC);
  }

  strcpy ((format+0)->attr_name, "n_synonym");
  strcpy ((format+0)->data_type, "char(40)");
  strcpy ((format+1)->attr_name, "n_null");
  strcpy ((format+1)->data_type, "char(1)");
  strcpy ((format+2)->attr_name, "n_read");
  strcpy ((format+2)->data_type, "char(1)");
  strcpy ((format+3)->attr_name, "n_advice");
  strcpy ((format+3)->data_type, "char(40)");
  strcpy ((format+4)->attr_name, "n_valueno");
  strcpy ((format+4)->data_type, "integer");

  status = _NFMbuild_working_buffer_format (format, 5, *attr_list);
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    return (status);
  }

  free (format);

  data = (char **) list->data_ptr;

  sql_str2 = (char *) malloc 
               ((list->rows * NFM_ATTR_NAME_MAX_SIZE + NFM_TOL)* sizeof (char));
  strcpy (sql_str2, "select ");

  for (x = 0, comma=0; x < list->rows; x ++)
  {
    index = list->columns * x;
    if (!strcmp (data[index+1], "n_cofilename"))
    {
      i_cofilename = x;
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "N", data[index+5]);
    }
    else if (!strcmp (data[index+1], "n_cisano"))
    {
      if (operation == NFM_ADD_FILE_TO_ITEM)
      {
        if (!strcmp (data[index+6], "Y"))
          cisano_write = 1;
        else ;
        sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "N", (cisano_write? data[index+5]: "N"));
      }
      else
      {
        if (!strcmp (data[index+7], "Y"))
          cisano_update = 1;
        else ;
        sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "N", (cisano_update? data[index+5]: "N"));
      }
    }
    else if (!strcmp (data[index+1], "n_fileco"))
    {
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_archiveno"))
    {
      i_archiveno = x;
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_cifilesize"))
    {
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_fileversion"))
    {
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_couser"))
    {
      i_couser = x;
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_cosano"))
    {
      i_cosano = x;
      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_filenum"))
    {
        i_filenum = x;
        sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], "Y", "N");
    }
    else if (!strcmp (data[index+1], "n_cifilename"))
    {
      i_cifilename = x;
      if (operation == NFM_ADD_FILE_TO_ITEM)
      {
        sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], data[index+4], data[index+5]);
      }
      else
      {
        if (!strcmp (data[index+7], "Y"))
        {
          cifile_update = 1;
          sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], data[index+4], data[index+5]);
        }
        else 
          sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], data[index+4], "N");
      }
    }
    else
    {

      sprintf (row_str, "%s\1%s\1%s\1\1\1",
             data[index+2], data[index+4], data[index+5]);
    }
    status = MEMwrite (*attr_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
        NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite(%s) 0x%.8x\n", row_str, status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }

    if (!strcmp (data[index+1], "n_cisano"))
    {
      i_cisano = x;
      status = MEMwrite_format (*data_list, "n_cisaname", "char(30)");
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
          NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
        _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        free (NFMactive_item);
        MEMclose (&list);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        free (sql_str2);
        return (status);
      }
      status = MEMwrite_format (NFMactive_data_list, "n_cisaname", "char(30)");
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", 
          NFMactive_item->item_no, 
          NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
        _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        free (NFMactive_item);
        MEMclose (&list);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        free (sql_str2);
        return (status);
      }
    }
    else
    {
      status = MEMwrite_format (*data_list, data[index+1], data[index+3]);
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", 
          NFMactive_item->item_no, 
          NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
        _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        free (NFMactive_item);
        MEMclose (&list);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        free (sql_str2);
        return (status);
      }
      status = MEMwrite_format (NFMactive_data_list, data[index+1], 
                                 data[index+3]);
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", 
          NFMactive_item->item_no, 
          NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
        _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);  
        free (NFMactive_item);
        MEMclose (&list);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        free (sql_str2);
        return (status);
      }
    }
    if (comma)
      strcat (sql_str2, ", ");
    else
      comma = 1;
    strcat (sql_str2, data[index+1]);
  }

  if (operation != NFM_ADD_FILE_TO_ITEM)
  {
    if (list->rows == 10 && !cifile_update && !cisano_update)
    {
      NFMset_item_status (catalog_name, "", "", 
        NFMactive_item->item_no, NFMactive_item->file_status,
        NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "no updateble file attributes\n"));
      ERRload_struct (NFM, NFM_E_DFI_NO_U, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }
    sprintf (row_str, "%s\1%s\1%s\1\1\1", "Status", "Y", "N");
    status = MEMwrite (*attr_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", 
        NFMactive_item->item_no, NFMactive_item->file_status,
        NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite(%s) 0x%.8x\n", row_str, status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }
    status = MEMwrite_format (*data_list, "n_status", "char(1)");
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
         NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }
    status = MEMwrite_format (NFMactive_data_list, "n_status", "char(1)");
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
        NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }
  }  
  else if ( i_cofilename == -1)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status,NFM_LOCK_COMMIT, "");
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_DFI_NO_W_COFILENAME, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    free (sql_str2);
    return (NFM_E_MESSAGE);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    /* attr_list is complete, data_list and ... has column info complete */
    MEMprint_buffer ("attr_list", *attr_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("data_list", *data_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMactive_data_list", NFMactive_data_list, 
                                             _NFMdebug_st.NFMdebug_file);
  }

  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    free (sql_str2);
    return (status);
  }

  /* build value list, get the default values. */
  /* write the first row with default */

  _NFMdebug ((fname, "get available storage area names\n"));

  if (strlen(WFinfo.proj_name))
  {
    status = _NFMget_proj_sa_list (cat_no, WFinfo.proj_no, &temp_value_list1);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_proj_sa_list 0x%.8x\n", status));
      status = _NFMget_cat_internal_sa_list (cat_no, &temp_value_list1);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_cat_sa_list 0x%.8x\n", status));
        NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
          NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
        free (NFMactive_item);
        MEMclose (&list);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        free (sql_str2);
        return (status);
      }
    }
  }
  else
  {
    status = _NFMget_cat_internal_sa_list (cat_no, &temp_value_list1);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_cat_sa_list 0x%.8x\n", status));
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
        NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      return (status);
    }
  }
  *value_list = temp_value_list1; 
  list_no ++;
  sprintf (temp_value, "%d", list_no);
  status = MEMwrite_data (*attr_list, temp_value, i_cisano+1, 5);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    free (sql_str2);
    MEMclose (value_list); /* temp_value_list1 */
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("attr_list", *attr_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffers ("value_list", *value_list, _NFMdebug_st.NFMdebug_file);
  }

  value_str2 = (char *) malloc 
                (list->rows * NFM_ATTR_NAME_MAX_SIZE * sizeof(char) + 200 );

  sprintf (value_str2, "%s %s",
      "select n_attrno, n_listno, n_type, n_defaultvalue, n_maxvalue,",
      "n_minvalue from nfmvalues where");

  for (x = or = 0; x < list->rows; x++)
  {
    if (or)
      strcat (value_str2, " or ");
    else 
      or = 1;

    index = list->columns * x;
    strcat (value_str2, " n_attrno = ");
    strcat (value_str2, data[index]);
  }

  strcat (value_str2, " order by n_attrno");
  
  status = SQLquery (value_str2, &list1, MEM_SIZE);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, 
      "no default, advice, value found in nfmvalues, malloc [%d]\n",
           (list->rows * (sizeof(char) +1))));
    first_row = (char *) calloc 
                 (list->rows + 1, sizeof(char));
    if (! first_row)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
        NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                                         (list->rows + 1) * sizeof (char));
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      MEMclose (value_list); /* temp_value_list1 */
      free (value_str2);
      MEMclose (&list1);
      free (first_row);
      return (NFM_E_MALLOC);
    }
    for (x = 0; x < list->rows; x++)
    {
      strcat (first_row, "\1");
    }
    _NFMdebug ((fname, "first_row: (%s)\n", first_row));
    free (value_str2);
    MEMclose (&list1);
  } 
  else if (status != SQL_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
      NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", value_str2, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    free (NFMactive_item);
    MEMclose (&list);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    free (sql_str2);
    free (value_str2);
    MEMclose (&list1);
    free (first_row);
    MEMclose (value_list);  /* temp_value_list1 */
    return (status);
  }
  else
  {
    free (value_str2);
    status = MEMbuild_array (list1);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
        NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      MEMclose (&list1);
      free (first_row);
      MEMclose (value_list); /* temp_value_list1 */
      return (status);
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("list1", list1, _NFMdebug_st.NFMdebug_file);

    data1 = (char **) list1->data_ptr;
    first_row = (char *) calloc 
                  (list->rows * NFM_ATTR_VALUE_MAX_SIZE,  sizeof(char));
    for (x = y = 0; x < list->rows; )
    {
      index = list->columns * x;

      _NFMdebug ((fname, "list[%d].n_attrno = %s\n", x, data[index]));

      /* find the index into attr_list */

      attrno1 = atol (data[index]);

      for (; y < list1->rows; y++)
      {
        index1 = list1->columns * y;
        _NFMdebug ((fname, "list[%d].n_attrno = %s\n", y, data1[index1]));
        attrno2 = atol (data1[index1]);

        if (attrno1 == attrno2)
        {
          _NFMdebug ((fname, "Found match\n"));
          break;
        }
        else if (attrno1 < attrno2)
        {
          _NFMdebug ((fname, "no default or advice\n"));
          break;
        }
      }

      if  (y >= list1->rows || attrno1 < attrno2)
      {
        _NFMdebug ((fname, "this attr does not have advice or value\n"));
        strcat (first_row, "\1");
        x ++;
        continue;
      } 
      if (strlen (data1[index1+3]))
      {
        _NFMdebug ((fname, "n_attrno %s, default value %s\n",
                    data1[index1], data1[index1+3]));
        if (!strcmp (data[index+1], "n_cisano"))
        {
          _NFMdebug ((fname, "n_cisano has a default value\n"));
          cisano_default = atol(data1[index1+3]);
          status = MEMbuild_array (temp_value_list1);
          dataj = (char **) temp_value_list1->data_ptr;
          for (j = 0; j < temp_value_list1->rows; j ++)
          {
            indexj = temp_value_list1->columns * j;
            if (cisano_default == atol (dataj[indexj]))
            {
              _NFMdebug ((fname, "found cisano name [%s]\n", dataj[indexj+1]));
              strcat (first_row, dataj[indexj+1]);
              break;
            }
          }
          if (j == temp_value_list1->rows)
          {
            _NFMdebug ((fname, "Invalid Internal Storage Area\n"));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
                                NFMactive_item->file_status, 
                                NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_INVALID_STORAGE_AREA, "%s",
                   data1[index1+3]);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            return (NFM_E_INVALID_STORAGE_AREA);
          }
        }
        else 
          strcat (first_row, data1[index1+3]);
      }
      else if (strlen (data1[index1+4]))
      {
        _NFMdebug ((fname, "n_attrno %d, max_value %s \n",
                      data1[index1], data1[index1+4]));
        status = MEMopen (&temp_value_list, MEM_SIZE);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMopen (temp_value_list) 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
            NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        status = MEMwrite_format (temp_value_list, "n_maxvalue", "char(40)");
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_format, n_maxvalue\n"));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
            NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        if (strlen (data1[index1+5]))
        {
          _NFMdebug ((fname, "n_attrno %d, ALSO has min_value %s\n",
                      data1[index1], data1[index1+5]));
          status = MEMwrite_format (temp_value_list, "n_minvalue", "char(40)");
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMwrite_format, n_minvalue\n"));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            return (status);
          }  
          sprintf (row_str, "%s\1%s\1",
                   data1[index1+4], data1[index1+5]);
        }
        else
        {
          sprintf (row_str, "%s\1", data1[index1+4]);
        }
      
        status = MEMwrite (temp_value_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_format, n_minvalue\n"));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
            NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        status = MEMappend (temp_value_list, *value_list);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMappend 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
                             NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        status = MEMclose (&temp_value_list);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMappend 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
                              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        list_no ++;
        sprintf (temp_value, "%d", list_no);
        status = MEMwrite_data (*attr_list, temp_value, x+1, 4);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
            NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        if (_NFMdebug_st.NFMdebug_on)
        {
          MEMprint_buffer ("attr_list", *attr_list,
                               _NFMdebug_st.NFMdebug_file);
          MEMprint_buffers ("value_list", *value_list,
                               _NFMdebug_st.NFMdebug_file);
        }
      }
      else if (strlen (data1[index1+5]))
      {
        _NFMdebug ((fname, "n_attrno %d, min_value %s no max_value\n",
                    data1[index1], data1[index1+5]));
        status = MEMopen (&temp_value_list, MEM_SIZE);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMopen (temp_value_list) 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        status = MEMwrite_format (temp_value_list, "n_minvalue", "char(40)");
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_format, n_maxvalue\n"));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        sprintf (row_str, "%s\1", data1[index1+4]);
        status = MEMwrite (temp_value_list, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_format, n_minvalue\n"));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        status = MEMappend (temp_value_list, *value_list);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMappend 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
                             NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        status = MEMclose (&temp_value_list);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no, 
                             NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }  
        list_no ++;
        sprintf (temp_value, "%d", list_no);
        status = MEMwrite_data (*attr_list, temp_value, x+1, 4);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          return (status);
        }
        if (_NFMdebug_st.NFMdebug_on)
        {
          MEMprint_buffer ("attr_list", *attr_list,
                               _NFMdebug_st.NFMdebug_file);
          MEMprint_buffers ("value_list", *value_list,
                               _NFMdebug_st.NFMdebug_file);
        }
      }
      else if (strlen (data1[index1+1]))
      {
        _NFMdebug ((fname, "n_attrno %s, listno = %s\n",
                    data1[index1], data1[index1+1]));

        sprintf (list_str, "%s %s",
                 "select n_value from nfmlists where n_listno =",
                 data1[index1+1]);

        status = SQLquery (list_str, &list2, MEM_SIZE);
        if (status != SQL_S_SUCCESS)
        {
          _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          MEMclose (&list2);
          return (status);
        }

        status = MEMbuild_array (list2);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          free (NFMactive_item);
          MEMclose (&list);
          MEMclose (data_list);
          MEMclose (attr_list);
          MEMclose (&NFMactive_data_list);
          free (sql_str2);
          MEMclose (&list1);
          free (first_row);
          MEMclose (value_list); /* temp_value_list1 */
          MEMclose (&list2);
          return (status);
        }

        if (_NFMdebug_st.NFMdebug_on)
          MEMprint_buffer ("list2", list2, 
                           _NFMdebug_st.NFMdebug_file);
        if (!strcmp (data1[index1+2], "A"))
        {
          list2_data = (char **) list2->data_ptr;
          status = MEMwrite_data (*attr_list, list2_data[0], 
                                  x+1, 4);
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMwrite_data to attr_list: 0x%.8x\n",
                        status));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
                NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            MEMclose (&list2);
            return (status);
          }
          status = MEMclose (&list2);
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMclose to attr_list: 0x%.8x\n",
                        status));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
                NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            MEMclose (&list2);
            return (status);
          }
        }
        else 
        {
          status = MEMappend (list2, *value_list);
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMappend 0x%.8x\n", status));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            MEMclose (&list2);
            return (status);
          }  
          status = MEMclose (&list2);
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            MEMclose (&list2);
            return (status);
          }
      
          list_no ++;
          sprintf (temp_value, "%d", list_no);
          status = MEMwrite_data (*attr_list, temp_value, x+1, 5);
          if (status != MEM_S_SUCCESS)
          {
            _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
            NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
                NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            free (NFMactive_item);
            MEMclose (&list);
            MEMclose (data_list);
            MEMclose (attr_list);
            MEMclose (&NFMactive_data_list);
            free (sql_str2);
            MEMclose (&list1);
            free (first_row);
            MEMclose (value_list); /* temp_value_list1 */
            return (status);
          }
        }
        if (_NFMdebug_st.NFMdebug_on)
        {
          MEMprint_buffer ("attr_list", *attr_list, 
                               _NFMdebug_st.NFMdebug_file);
          MEMprint_buffers ("value_list", *value_list, 
                               _NFMdebug_st.NFMdebug_file);
        }
      }
      if (y == list1->rows-1)
      {
        strcat (first_row, "\1");
        x++;
      }
      else if (strcmp (data[index], data1[index1+list1->columns]))
      {
        strcat (first_row, "\1");
        x++;
      }
      else
        y++;
    }
  }

  MEMclose (&list1);

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("attr_list", *attr_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffers ("value_list", *value_list, _NFMdebug_st.NFMdebug_file);
  }

  _NFMdebug ((fname, "default values %s\n", first_row));

  if (operation == NFM_ADD_FILE_TO_ITEM)
  {
    if (!cisano_default && !cisano_write )
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "n_cisano is not writable and no def value\n"));
      ERRload_struct (NFM, NFM_E_DFI_NO_W_DEF_CISANO, "", NULL); 
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      free (first_row);
      MEMclose (value_list); /* temp_value_list1 */
      return (NFM_E_DFI_NO_W_DEF_CISANO);
    }
    status = MEMwrite (*data_list, first_row);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      free (first_row);
      MEMclose (value_list); /* temp_value_list1 */
      return (status);
    }
    status = MEMwrite (NFMactive_data_list, first_row);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite %s\n", first_row));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (&list);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      free (sql_str2);
      free (first_row);
      MEMclose (value_list); /* temp_value_list1 */
      return (status);
    }
  }

  free (first_row);
  MEMclose (&list);

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("data_list", *data_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMactive_data_list", NFMactive_data_list, 
                                             _NFMdebug_st.NFMdebug_file);
  }

  /* retrieve the information from f_<catalog> */

  strcat (sql_str2, " from ");
  strcat (sql_str2, fcat_name);
  strcat (sql_str2, " where n_itemnum = ");
  sprintf (temp_value, "%d", NFMactive_item->item_no);
  strcat (sql_str2, temp_value);
  strcat (sql_str2, 
         " and n_fileversion = (select max(n_fileversion) from ");
  strcat (sql_str2, fcat_name);
  strcat (sql_str2, " where n_itemnum =");
  strcat (sql_str2, temp_value);
  strcat (sql_str2, ")");

  status = SQLquery (sql_str2, &list1, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str2, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    free (NFMactive_item);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    free (sql_str2);
    MEMclose (value_list); /* temp_value_list1 */
    return (status);
  }

  free (sql_str2);

  status = MEMbuild_array (list1);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMbuild_array  0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    MEMclose (value_list); /* temp_value_list1 */
    return (status);
  }

  data1 = (char **) list1->data_ptr;
  if (list1->rows == 1)
  {
    /* check for place holder record? */
    if (atol(data1[i_filenum]) == 0)
    {
      if (operation == NFM_ADD_FILE_TO_ITEM)
      {
        NFMactive_item->cosano = atol (data1[i_cosano]);
        MEMclose (&list1);
        _NFMdebug ((fname, 
           "EXIT: successful (no file associated w/item yet, cosano = %d)\n",
                        NFMactive_item->cosano));
        return (NFM_S_SUCCESS);
      }
      ERRload_struct (NFM, NFM_E_NO_ITEM_FILES_FOUND, "", NULL);
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "no file associated with the item\n"));
      free (NFMactive_item);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      MEMclose (value_list); /* temp_value_list1 */
      MEMclose (&list1);
      return (NFM_E_NO_ITEM_FILES_FOUND);
    }
  }

  status = MEMbuild_array (temp_value_list1);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
    _NFMdebug ((fname, "MEMbuild_array  0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    free (NFMactive_item);
    MEMclose (data_list);
    MEMclose (attr_list);
    MEMclose (&NFMactive_data_list);
    MEMclose (value_list); /* temp_value_list1 */
    MEMclose (&list1);
    return (status);
  }
  data2 = (char **) temp_value_list1->data_ptr;

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list1", list1, _NFMdebug_st.NFMdebug_file);

  row_str2 = (char *) calloc 
          (list1->columns * NFM_ATTR_VALUE_MAX_SIZE  + 300,
           sizeof (char));

  if (operation != NFM_ADD_FILE_TO_ITEM && strlen (data1[i_archiveno]))
  {
    _NFMdebug ((fname, 
             "file is archived/backed up, not allowed to chg cifilename\n"));
    status = MEMwrite_data (*attr_list, "N", i_cifilename+1, 3);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      MEMclose (value_list); /* temp_value_list1 */
      free (row_str2);
      MEMclose (&list1);
      return (status);
    }
  }

  if (operation == NFM_ADD_FILE_TO_ITEM && strlen (NFMactive_item->file_status))
  {
    /* when it reaches this point, status should only be "", or OUT, 
       should not be "I" */

    _NFMdebug ((fname, 
       "item is checked out, chk couser and get info for cosano\n"));
    get_cosano = chk_user = 0;
  }
  else if (operation == NFM_CHANGE_FILE_INFORMATION && 
           strcmp (NFMactive_item->file_status, "I") )
  {
    /* if item is checked out, the couser needs to be verified */
    get_cosano = 1;
    chk_user = 0;
  }
  else
  {
    _NFMdebug ((fname, "Ignore the cosano and couser\n"));
    get_cosano = chk_user = 1;
  }

  for (x = 0; x < list1->rows ; x ++, row_str2[0]='\0')
  {
    index1 = list1->columns * x;
    for (y = 0; y < list1->columns; y ++)
    {
      _NFMdebug ((fname, "data1[index1+%d] = %s\n",
                          y, data1[index1+y]));
      if (y == i_cisano)
      {
        for (z = 0; z < temp_value_list1->rows; z ++)
        {
          index2 = temp_value_list1->columns * z;
          _NFMdebug ((fname, "data2[index2+1] = %s\n", 
                              data2[index2+1]));

          if (!strcmp (data1[index1+y], data2[index2]))
          {
            strcat (row_str2, data2[index2+1]);
            strcat (row_str2, "\1");
            break;
          }
        }
        if (z == temp_value_list1->rows)
        {
          strcat (row_str2, "\1");
        }
      }
      else
      {
        strcat (row_str2, data1[index1+y]);
        strcat (row_str2, "\1");
      }
    }

    if (!get_cosano && strlen (data1[index1+i_cosano]))
    {
      _NFMdebug ((fname, "need to save cosano info [%s]\n",
                  data1[index1+i_cosano]));
      NFMactive_item->cosano = atol (data1[index1+i_cosano]);
      get_cosano = 1;
    }
    if (!chk_user && strlen (data1[index1+i_couser]))
    {
      if (strcmp (NFMglobal.NFMusername, data1[index1+i_couser]))
      {
        _NFMdebug ((fname, 
           "NO add/chg file information, couser is not the current user\n"));
        NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
        ERRload_struct (NFM, NFM_E_DFI_COUSER, "", NULL);
        free (NFMactive_item);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        MEMclose (value_list); /* temp_value_list1 */
        free (row_str2);
        MEMclose (&list1);
        return (NFM_E_DFI_COUSER);
      }
      chk_user = 1;
    }

    _NFMdebug ((fname, "operation = %d, row_str2 = %s\n", operation, row_str2));

    status = MEMwrite (NFMactive_data_list, row_str2);
    if (status != MEM_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      free (NFMactive_item);
      MEMclose (data_list);
      MEMclose (attr_list);
      MEMclose (&NFMactive_data_list);
      MEMclose (value_list); /* temp_value_list1 */
      free (row_str2);
      MEMclose (&list1);
      return (status);
    }

    if (operation != NFM_ADD_FILE_TO_ITEM)
    {
      status = MEMwrite (*data_list, row_str2);
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", NFMactive_item->item_no,
              NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        free (NFMactive_item);
        MEMclose (data_list);
        MEMclose (attr_list);
        MEMclose (&NFMactive_data_list);
        MEMclose (value_list); /* temp_value_list1 */
        MEMclose (&list1);
        free (row_str2);
        return (status);
      }
    }
  }
 
  free (row_str2);
  MEMclose (&list1);

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("data_list", *data_list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMactive_data_list", NFMactive_data_list, 
                                             _NFMdebug_st.NFMdebug_file);
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstart_transaction 0x%.8x\n", status));
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
