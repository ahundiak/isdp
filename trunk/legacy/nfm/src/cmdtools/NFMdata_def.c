#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMattr_def.h"

long NFMci_get_data_def (table_no, ftable_no, attr_list, data_list)

long    table_no, ftable_no;
MEMptr *attr_list, *data_list;

{
  /***
     This function will retrieve the attributes data definition of the 
     <catalog> and f_<catalog> from nfmattributes table.

     CHANGE HISTORY:
       04/02/91 mfb creation.
  ***/

  char **column, **data, **format;
  char **column1, **data1;
  char sql_str[1024], row_str[1024], *buf_str;
  char *fname="NFMci_get_data_def1";
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
           ") AND (n_checkin = 'Y' OR n_checkin = 'U') ",
           " AND (n_application = 'NFM') ORDER by n_seqno " ); 

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery: 0x%.8x\n", NFM_E_SQL_QUERY) );
    return (NFM_E_SQL_QUERY);
  }
 
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


  MEMbuild_array (*attr_list);
  
  buf_str = (char *) malloc ( (*attr_list)->row_size);
  
  sprintf (buf_str, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                    "n_catalogname\1", "char(20)\1", "Catalog Name\1",
                    "NFM\1", "Y\1", "N\1", "N\1", 
                    "N\1", "N\1", "N\1", "N\1", "0\1", "0\1", "0\1");


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
                    "NFM\1", "N\1", "N\1", "N\1", "N\1", "N\1", "N\1",
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

  for (x = 0; x < list->rows; ++x)
  {
    index = x * list->columns;

      sprintf (row_str, 
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
               data[index], data[index+1], data[index+2], data[index+3], 
               data[index+4], data[index+5], data[index+6], data[index+7], 
               data[index+8], data[index+9], data[index+10], data[index+11], 
               data[index+12], data[index+13] );
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
                            /* 13 == n_listno */
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (attr_list);
      _NFMdebug ( (fname, "MEMwrite_data (attr_list): 0x%.8x\n",
      status) );
      return (status);
    }
  }

  status = MEMopen (data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
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
      MEMclose (&list);
      MEMclose (attr_list);
      MEMclose (data_list);
      _NFMdebug ( (fname, "MEMwrite_formate: 0x%.8x\n", status) );
      return (status);
    }
  }

  _NFMdebug ( (fname, "EXIT: SSUCCESSFUL\n") );
  return (NFM_S_SUCCESS);
}
