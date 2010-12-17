#include <stdio.h>
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMitems.h"
#include "UTIerrordef.h"


long NFMget_word_wheel (cat_list, start, count, hits)
MEMptr cat_list;
char *start;
long count;
MEMptr *hits;

{
  
  char *fname="NFMget_word_wheel";
  char *words=NULL, *cat_nos, sql_str[1024], temp_str[10];
  char **data, **list_data;
  char dumb_str[2], d_type[10], row_str[1024];
  char *tok_ptr, *strptr;
  long x, or, index, status, dumb_value, length;
  MEMptr list=NULL;

  _NFMdebug ((fname, "ENTER, start [%s] limit [%d]\n", start, count));

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
 
  cat_nos = (char *) calloc (list->rows, 12);

  cat_nos[0] = '\0';

  for (x = 0; x < list->rows; x ++)
  {
    index = list->columns * x;

    _NFMdebug ((fname, "cat_no [%s] cat_name [%s]\n",
                        list_data[index], list_data[index+1]));

    sprintf (temp_str, "%s \0", list_data[index]);
    strcat (cat_nos, temp_str);
  }
  
  MEMclose (&list);

  _NFMdebug ((fname, "cat_nos[%s]\n", cat_nos));

  if (_NFMdebug_st.NFMdebug_on)
  {
    /* this is to trace a bug that Dave reported */
    if (words != (char *) NULL)
    {
      _NFMdebug ((fname, "words [%s]\n", words));
    }
    else
    {
      _NFMdebug ((fname, "words == NULL = [%s]\n", words));
    }
  }
  status = NFT_get_word_wheel (cat_nos, start, count, &words);
  if (status != UTI_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFT_get_word_wheel 0x%.8x\n", status));
    free (cat_nos);
    free (words);
    return (status);
  }
  free (cat_nos);

  _NFMdebug ((fname, "words [%s]\n", words));


  status = MEMopen (hits, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    free (words);
    return (status);
  }

  strptr = (char *) calloc (strlen (words) + 1, sizeof (char));
  strcpy (strptr, words);

  length = 0;
  while (( tok_ptr = (char *) strtok (strptr, "\t")) != (char *) NULL)
  {
    _NFMdebug ((fname, "tok_ptr [%s]\n", tok_ptr));
    if (length < strlen (tok_ptr))
    {
      _NFMdebug ((fname, "new record [%d]\n", strlen (tok_ptr)));
      length = strlen (tok_ptr);
    }
    strptr = (char *) NULL;
  }
  _NFMdebug ((fname, "the longest word is (%d) characters\n", length));

  sprintf (d_type, "char(%d)", length);

  status = MEMwrite_format (*hits, "word", d_type);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
    free (words);
    return (status);
  }

  strptr = (char *) calloc (strlen (words) + 1, sizeof (char));
  strcpy (strptr, words);

  while (( tok_ptr = (char *) strtok (strptr, "\t")) != (char *) NULL)
  {
    _NFMdebug ((fname, "tok_ptr [%s]\n", tok_ptr));
    sprintf (row_str, "%s\1", tok_ptr);
    status = MEMwrite (*hits, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      MEMclose (hits);
      free (words);
      return (status);
    }
    strptr = (char *) NULL;
  }

  free (words);

  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}
