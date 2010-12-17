#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "ERR.h"

/***
  This file is created due to rewriting CI/CO set. However, these functions 
  could be used by other functions. When the group restructure the code, this
  file should be renamed to something more general.
***/


long NFMget_cat_fcat_no (cat_name, cat_no, fcat_no, type)

char *cat_name; /* i - catalog name */
long  *cat_no;   /* o - catalog/table number */
long  *fcat_no;  /* o - f_catalog/table number */
int  type;      /* ignored */

{
  /***
    This function retrieve the table numbers of <catalog> or/and f_<catalog>
    based on the passed in catalog name and type. 

             database 

    Note: this function will call ERRload_struct before it return the failing
          status.

  ***/

  char          file_cat[50];
  char *fname="NFMget_cat_fcat_no";
  char **data;
  char fcat_name[61];
  char   sql_str[300];
  int f_row, no_rows;
  int    x, index;
  long status;
  MEMptr list = NULL;

  _NFMdebug ( (fname,"ENTER: cat_name = %s type = %d\n", cat_name, type ));
  *cat_no = -1; *fcat_no = -1;
  sprintf (fcat_name, "f_%s", cat_name);

  sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s' OR %s = '%s'",
           "n_tablename, n_tableno", "nfmtables", "n_tablename",
           cat_name, "n_tablename", fcat_name);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "cat & fcat # are not found 0x%.8x\n", 
                 NFM_E_BAD_ATTR_VALUE) );
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array 0x%.8x\n", NFM_E_MEM) );
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (! strcmp (cat_name, data[index]))
      *cat_no = atoi (data[index+1]);
    else if (! strcmp (fcat_name, data[index]))
      *fcat_no = atoi (data[index+1]);
  }
   status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose 0x%.8x\n", NFM_E_MEM));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
