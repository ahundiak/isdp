#include <stdio.h>
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "NFMitemfiles.h"
#include "NFMitems.h"
#include "UTIerrordef.h"


long NFMget_preview (cat_list, ftr_search, hits)
MEMptr cat_list;
char *ftr_search;
MEMptr *hits;

{
  
  char *fname="NFMget_preview";
  char *results, *cat_nos, temp_str[10];
  char **data, **list_data;
  char dumb_str[2], sql_str[1024], row_str[1024];
  char *cat_ptr, *no_ptr, *strptr;
  long x, or, index, status, dumb_value;
  MEMptr list=NULL;
  struct NFMquery_ftr_info ftr_info;
  struct NFMbuf_format *format;

  _NFMdebug ((fname, "ENTER, ftr_search [%s] \n", ftr_search));

  status = MEMbuild_array (cat_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    return (status);
  }  

  data = (char **) cat_list->data_ptr;

  strcpy (sql_str, "select n_catalogno, n_catalogname from nfmcatalogs where");

  for (x = or = 0; x < cat_list-> rows; x ++)
  {
    /* cat_list has one column only */

    _NFMdebug ((fname, "data[%d] = [%s]\n", x, data[x]));

    if (or)
    {
      strcat (sql_str, " or ");
    }
    else
    {
      or = 1;
    }
    strcat (sql_str, " n_catalogname = '");
    strcat (sql_str, data[x]);
    strcat (sql_str, "'");
  }

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR,
                               dumb_str, &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("retrieved cat list", list, _NFMdebug_st.NFMdebug_file);

  list_data = (char **) list->data_ptr;
 
  cat_nos = (char *) calloc (list->rows, 11);

  cat_nos[0] = '\0';

  for (x = 0; x < list->rows; x ++)
  {
    index = list->columns * x;

    _NFMdebug ((fname, "cat_no [%s] cat_name [%s]\n",
                        list_data[index], list_data[index+1]));

    sprintf (temp_str, "%s \0", list_data[index]);
    strcat (cat_nos, temp_str);
  }

  if (ftr_search[0] != ' ')
  {
    status = _NFMretrieve_ftr_query (ftr_search, "F", &ftr_info);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMretrieve_ftr_query 0x%.8x\n", status));
      MEMclose (&list);
      free (cat_nos);
      return (status);
    } 
    _NFMdebug ((fname, "cat_nos[%s] retrieved ftr_info.ftr[%s]\n",
                      cat_nos, ftr_info.ftr));
  }
  else
  {
    ftr_info.ftr = (char *) calloc (strlen (ftr_search), sizeof (char));
    for (x = 1; x < strlen (ftr_search); x ++)
    {
      ftr_info.ftr[x-1] = ftr_search[x];
    }
    ftr_info.ftr[x-1] = '\0';
    _NFMdebug ((fname, "assigned ftr string [%s]\n", ftr_info.ftr));
  }

  status = NFT_get_preview (cat_nos, ftr_info.ftr, &results);
  if (status != UTI_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFT_get_preview 0x%.8x\n", status));
    MEMclose (&list);
    free (cat_nos);
    free (results);
    return (status);
  }

  _NFMdebug ((fname, "results [%s]\n", results));


  status = MEMopen (hits, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    MEMclose (&list);
    free (cat_nos);
    free (results);
    return (status);
  }

  format = (struct NFMbuf_format *) calloc (3, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    MEMclose (&list);
    MEMclose (hits);
    free (cat_nos);
    free (results);
    return (NFM_E_MALLOC);
  }

  strcpy ((format+0)->attr_name, "n_catalogname");
  sprintf ((format+0)->data_type, "char(%d)", NFM_CATALOGNAME);
  strcpy ((format+1)->attr_name, "n_catalogno");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "count");
  strcpy ((format+2)->data_type, "integer");

  status = _NFMbuild_working_buffer_format (format, 3, *hits);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    MEMclose (&list);
    MEMclose (hits);
    free (cat_nos);
    free (results);
    free (format);
    return (status);
  }
  free (format);

  strptr = (char *) calloc (strlen (results) + 1, sizeof (char));
  strcpy (strptr, results);

  while (( cat_ptr = (char *) strtok (strptr, " ")) != (char *) NULL)
  {
    _NFMdebug ((fname, "cat_ptr [%s]\n", cat_ptr));
    strptr = (char *) NULL;

    if ((no_ptr = (char *) strtok (strptr, ";")) == (char *) NULL)
    {
      _NFMdebug ((fname, "results corrupted\n"));
      MEMclose (&list);
      MEMclose (hits);
      free (cat_nos);
      free (results);
      return (NFM_E_FAILURE);
    }
    _NFMdebug ((fname, "no_ptr [%s]\n", no_ptr));

    for (x = 0; x < list->rows; x++)
    {
      index = list->columns * x;
      if (atol(list_data[index]) == atol (cat_ptr))
      {
        _NFMdebug ((fname, "found catalog name [%s]\n", list_data[index+1]));
        break;
      }
    }
    if (x >= list->rows)
    {
      _NFMdebug ((fname, "something is corrupted\n"));
      MEMclose (&list);
      MEMclose (hits);
      free (cat_nos);
      free (results);
      return (NFM_E_FAILURE);
    }

    sprintf (row_str, "%s\1%s\1%s\1", list_data[index+1], cat_ptr, no_ptr);
    _NFMdebug ((fname, "row_str[%s]\n", row_str));
    status = MEMwrite (*hits, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite [%s] 0x%.8x\n", row_str, status));
      MEMclose (&list);
      MEMclose (hits);
      free (cat_nos);
      free (results);
      return (status);
    }
  }

  MEMclose (&list);
  free (results);
  free (cat_nos);

  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}
