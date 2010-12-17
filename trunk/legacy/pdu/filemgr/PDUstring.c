#include <stdio.h>
#include <ctype.h>
#include "FI.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUintdef.h"
#include "PDUproto.h"

int PDUsearch_string_to_arrays(string, attr_list, attrs, expressions, entry)
char     *string;
MEMptr    attr_list;
char   ***attrs;
char   ***expressions;
int      *entry;
{
int       status = PDM_S_SUCCESS;
int       char_index;
int       i;
int       syn = 0;
int       repeat_entry = 0;
int       attr_flag = TRUE;
int       expr_flag = FALSE;
int       repeat = FALSE;
int       syn_col;
int       attr_row;
char    **attr_list_data;
char     *P1 = NULL; 
char     *P2 = NULL; 
char     *expr1 = NULL; 
char     *synonym = NULL; 

  _pdm_debug("In the function PDUsearch_string_to_arrays", 0);

  *attrs = (char **) malloc (sizeof(char *) * 50);
  memset(*attrs, NULL, sizeof(char *) * 50);
  *expressions = (char **) malloc (sizeof(char *) * 50);
  memset(*expressions, NULL, sizeof(char *) * 50);

  MEMbuild_array(attr_list);
  PDUget_buffer_col(attr_list, "n_synonym", &syn_col);
  PDUsetup_buffer(attr_list, ROW, &attr_list_data); 

  char_index = 0;
  *entry = 0;
  i = 0;

  while (string != NULL)
   {
    expr_flag = FALSE;
    char_index = 0;
    while ((string[char_index] == ' ') && (string[char_index] != '\0'))
      ++char_index;

    P1 = string + char_index;
    P2 = P1;

    char_index = 0;
    while ((P2[char_index] != ' ') && (string[char_index] != '\0'))
      ++char_index;

    string = P2 + char_index + 1;
    P2[char_index] = '\0';

    if (attr_flag == TRUE)
      {
      /* find the attribute argument in the attribute buffer */
      attr_row = PDUfind_attr_in_buffer(attr_list, P1);
      if ( attr_row == -1 )
        return(PDM_E_ATTR_NOT_FOUND);
      else
        if (strcmp(attr_list_data[(attr_list->columns * attr_row) + syn_col],
            "") != 0)
          {
          PDUfill_in_string(&synonym, 
                  attr_list_data[(attr_list->columns * attr_row) + syn_col]);
          syn = TRUE;
          }


      if (*entry > 0)
        {
        for (repeat_entry = 0; repeat_entry < *entry; ++repeat_entry)
           {
           if (strcmp(P1, *attrs[repeat_entry]) == 0)
             {
             repeat = TRUE;
             break; 
             }
           }
        } /* end if entry > 0 */

      if (repeat == FALSE)
        {
        if (syn ==TRUE)
          {
          PDUfill_in_string(&((*attrs)[*entry]), synonym);
          syn = FALSE;
          }
        else
          PDUfill_in_string(&((*attrs)[*entry]), P1);
        }

      attr_flag = FALSE;
      } /* end if attr_flag */

    char_index = 0;
    while (string[char_index] == ' ')
      ++char_index;

    P1 = string + char_index;
    P2 = P1;

    char_index = 0;
    while ((P2[char_index] != ' ') && (P2[char_index] != '\0'))
      ++char_index;

    if (P2[char_index] == '\0')
      {
      _pdm_debug("error parsing string", 0);
      }
    else
      {
      while (expr_flag == FALSE)
        {
        if ((strncmp(P2 + char_index + 1, "and ", 4) == 0)  ||
            (strncmp(P2 + char_index + 1, "or ", 3) == 0)   ||
            (strncmp(P2 + char_index + 1, "not ", 4) == 0)) 
           {
           expr_flag = TRUE;
           if ((strncmp(P2 + char_index + 1, "and ", 4) == 0)  ||
               (strncmp(P2 + char_index + 1, "not ", 4) == 0)) 
             {
             string = P2 + char_index + 5;
             P2[char_index + 4] = '\0';
             if (repeat == TRUE)
               {
               PDUfill_in_string(&expr1, (*expressions)[repeat_entry]);
/*
               concat_len = strlen(expr1) + strlen(P1);
               (*expressions)[repeat_entry] =
                      (char *) malloc (sizeof (char) * concat_len + 2);
               memset(*expressions[repeat_entry], NULL, 
                         sizeof (char) * concat_len + 2);
*/
               PDUfill_in_string(expressions[repeat_entry], expr1);
               strcat((*expressions)[repeat_entry], " ");
               strcat((*expressions)[repeat_entry], P1);
               attr_flag = TRUE;
               repeat = FALSE;
               }
             else
               {
               PDUfill_in_string(&((*expressions)[*entry]), P1);
               attr_flag = TRUE;
               ++(*entry);
               }
             }
           if (strncmp(P2 + char_index + 1, "or ", 3) == 0)  
             {
             string = P2 + char_index + 4;
             P2[char_index + 3] = '\0';
             if (repeat == TRUE)
               {
               PDUfill_in_string(&expr1, (*expressions)[repeat_entry]);
/*
               concat_len = strlen(expr1) + strlen(P1);
               (*expressions)[repeat_entry] =
                      (char *) malloc (sizeof (char) * concat_len + 2);
               memset(*expressions[repeat_entry], NULL, 
                         sizeof (char) * concat_len + 2);
*/
               PDUfill_in_string(expressions[repeat_entry], expr1);
               strcat((*expressions)[repeat_entry], " ");
               strcat((*expressions)[repeat_entry], P1);
               attr_flag = TRUE;
               repeat = FALSE;
               }
             else
               {
               PDUfill_in_string(&((*expressions)[*entry]), P1);
               attr_flag = TRUE;
               ++(*entry);
               }
             }
           }
         else
           {
           while ((P2[char_index + 1] != ' ') && (P2[char_index + 1] != '\0'))
             ++char_index;

           if (P2[char_index + 1] == '\0')
             {
             PDUfill_in_string(&((*expressions)[*entry]), P1);
             string = NULL;
             break;
             }
           else
             while ((P2[char_index + 1] == ' ') && (string[char_index] != '\0'))
               ++char_index;
           }
        } /*end while expr_flag = FALSE */
      } /* end if P2[char_index] != NULL */
   } /* end while not eos */

  return(status);
} /* end PDUsearch_string_to_array */

int PDUsearch_arrays_to_form(attrs, exprs, form, field, no_attrs)
char   **attrs;
char   **exprs;
Form     form;
int      field;
int      no_attrs;
{
static char   *text;
int     index;
int     row;
int     num_rows;
int     select;
int     pos;
int     length;
int     status = PDM_S_SUCCESS;
int     column;

  _pdm_debug("in the function PDUsearch_arrays_to_form", 0);

  ++no_attrs;

  /* cycle through the rows in the attrs array and find the matching row in 
     the mcf */
     FIfld_get_num_rows(form, field, &num_rows);
     for (index = 0; index < no_attrs; ++index)
        {
        for (row = 0; row < num_rows; ++row)
           {
           FIfld_get_text_length(form, field, row, 0, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(form, field, row, 0, length, (unsigned char *)text, 
                          &select, &pos);
           _pdm_debug("text = <%s>", text);
           if (strcmp(text, attrs[index]) == 0)
             {
             /* truncate the conjuction at the end of the string */
             status = PDUtrunc_string(&(exprs[index]));

             /* take the quotes out of the string */
             PDUunquote_string(&(exprs[index]));

             /* check to see which column the value should be written to */
             status = PDUcheck_column(&(exprs[index]), &column);

             /* fill the value/condition in on the form */
             FIfld_set_text(form, field, row, column, exprs[index], FALSE);
             row = num_rows;
             }
           PDUfree_string(&text);
           } /* end for row */
        }  /* end for index */

  return(status);
}  /* end PDUsearch_arrays_to_form */

int PDUtrunc_string(string)
char  **string;
{
char   *s;
int     offset;
int     char_index;
int     status = PDM_S_SUCCESS;
char   *temp = NULL;

  if (*string)
    {
    s = *string + strlen(*string) - 1;
    char_index = strlen(*string) - 1;
    
    offset = 0;
    while ((*string)[char_index] != ' ')
      {
      --char_index;
      ++offset;
      }

    --offset;
    temp = (char*) malloc (sizeof (char) * 5);
    memset(temp, NULL, sizeof (char) * 5);
    strncpy(temp, (s-offset), 3);
    _pdm_debug("temp string = <%s>", temp);

    if ((strncmp((s - offset), "and", 3) == 0)  ||
        (strncmp((s - offset), "not", 3) == 0)) 
      (s - 3)[0] = '\0';

    else if (strncmp((s - offset + 1), "or", 2) == 0)
      (s - 2)[0] = '\0';
    
    _pdm_debug("string = <%s>", *string);
    } /* end if string */

  PDUfree_string(&temp);
  return(status);
} /* end PDUtrunc_string */

PDUunquote_string(string)
char   **string;
{
char   *out_string = NULL;
int     length;
int     old_index;
int     new_index;

  length = strlen(*string);
  out_string = (char *) malloc (sizeof (char) * length);
  memset(out_string, NULL, sizeof (char) * length);

  old_index = 0;
  new_index = 0;

  while ((*string)[old_index] != '\0')
     {
     if (((*string)[old_index] != '"') && ((*string)[old_index] != '\''))
       {
       out_string[new_index] = (*string)[old_index];
       ++new_index;
       ++old_index;
       }
     else
       ++old_index;
     }

  out_string[new_index] = '\0';
  *string = NULL;
  PDUfill_in_string(string, out_string);
  _pdm_debug("string without quotes = <%s>", *string);

  PDUfree_string(&out_string);

} /* end PDUunquote_string */

int PDUcheck_column(string, column)
char    **string;
int      *column;
{
int     index;
int     flag = FALSE;
int     status = PDM_S_SUCCESS;

   index = 0;

   if (*string)
     {
     while ((*string)[index] != '\0')
       {
       while (((*string)[index] != ' ') && ((*string)[index] != '\0'))
         ++index;

       while (((*string)[index] == ' ') && ((*string)[index] != '\0'))
         ++index;

       if ((strncmp((*string) + index, "and ", 4)  == 0) ||
           (strncmp((*string) + index, "or ", 3)  == 0)  ||
           (strncmp((*string) + index, "not ", 4)  == 0))
         {
         *column = 2;
         flag = TRUE;
         break;
         }
       } /* end while string */

     if (flag == FALSE)
       {
       index = 0;
       while ((*string)[index] != '\0')
         {
         if ((*string)[index] == '=')
           {
           *column = 1;
           *string = (*string) + index + 2;
           break;
           }
         else if ((*string)[index] == '<')
           {
           *column = 2;
           break;
           }
         else if ((*string)[index] == '>')
           {
           *column = 2;
           break;
           }
         else if ((*string)[index] == '!')
           {
           *column = 2;
           break;
           }
         else if ((*string)[index] == 'l')
           {
           *column = 2;
           break;
           }
         ++index;
         }  /* end while string */
       } /* end if flag */
     }  /* end if string */
   
  return(status);
}  /* PDUcheck_column */


int PDUget_search_string(form, field, attr_bufr, search_string)
Form      form;
int       field;
MEMptr    attr_bufr;
char    **search_string;
{
int       status = PDM_S_SUCCESS;
int       column;
int       row;
int       name_col;
int       type_col;
int       syn_col;
int       select;
int       pos;
int       entry;
char     *tmp_text = NULL;
char     *empty = NULL;
char     *search_cond = NULL;
char     *attr = NULL;
char    **data_row;
static char     *text;
extern struct PDUforms  forms;

  text = (char *) malloc (sizeof (char) * 50);
  memset(text, NULL, sizeof (char) * 50);

  MEMbuild_array(attr_bufr);
  PDUget_buffer_col(attr_bufr, "n_name", &name_col);
  PDUget_buffer_col(attr_bufr, "n_synonym", &syn_col);
  PDUget_buffer_col(attr_bufr, "n_datatype", &type_col);
  PDUsetup_buffer(attr_bufr, ROW, &data_row);

  PDUfill_in_string(&empty, "\177\1\24");

  entry = 0;
  *search_string = (char *) malloc (sizeof (char) * 200);
  memset(*search_string, NULL, sizeof (char) * 200);
  strcpy(*search_string, "where ");

  for (row = 0; row < attr_bufr->rows; ++row)
     {
     for (column = 1; column < 3; ++column)
        {
        FIfld_get_text(form, field, row, column, 40, (unsigned char *)text, 
                       &select, &pos);
        if ((text != NULL) && (strcmp(text, "") != 0) &&
            (strcmp(text, empty) != 0))
          {
          /* get the datatype of the attribute */
          if (strncmp(data_row[(attr_bufr->columns * row) + type_col], 
                        "char", 4) == 0)
            {
            if (column == 1)
              {
              /* add quotes to the string */
              tmp_text = (char *) malloc (sizeof (char) * (strlen(text) + 5));
              memset(tmp_text, NULL, sizeof (char) * (strlen(text) + 5));
              strcpy(tmp_text, "\'");
              strcat(tmp_text, text);
              strcat(tmp_text, "\'");
              PDUfill_in_string(&text, tmp_text);
              PDUfree_string(&tmp_text);
              }
            if (column == 2)
              {
              /* call function to add quotes to the string */
              PDUfill_in_string(&attr, data_row[(attr_bufr->columns * row)+ 0]);
              status = PDUadd_quotes(&search_cond, attr, "");
              if (status == PDM_E_INVALID_STRING)
                return(status);
              }
            }

          if (entry > 0)
            {
            strcat(*search_string, " ");
            strcat(*search_string, "and");
            strcat(*search_string, " ");
            }

          strcat(*search_string,data_row[(attr_bufr->columns*row)+name_col]);
          strcat(*search_string, " ");
          if (column == 1)
            {
            strcat(*search_string, "=");
            strcat(*search_string, " ");
            strcat(*search_string, text);
            column = 3;
            }
          else
            {
            strcat(*search_string, search_cond);
            }
          ++entry;
          } /* end if text */
        PDUfill_in_string(&text, "");
        }  /* end for column */
     }  /* end for row */

  PDUfree_string(&text);
  return(status);
}  /* end PDUget_search_string */

int PDUadd_quotes(string, attr, datatype)
char    **string;
char     *attr;
char     *datatype;
{
int       status = PDM_S_SUCCESS;
int       old_index;
int       new_index;
int       i;
char     *new_string = NULL;

   _pdm_debug("in the function PDUadd_quotes", 0);

   old_index = 0;
   new_index = 0;

   new_string = (char *) malloc (sizeof (char) * 150);
   memset(new_string, NULL, sizeof (char) * 150);

   while ((*string)[old_index] != '\0')
     {
     if (((*string)[old_index] == '=') ||
         ((*string)[old_index] == '<') ||
         ((*string)[old_index] == '>') ||
         ((*string)[old_index] == 'l') ||
         ((*string)[old_index] == '!'))
       {
       while (((*string)[old_index] != ' ') && ((*string)[old_index] != '\0'))
         {
         new_string[new_index] = (*string)[old_index];
         ++old_index;
         ++new_index;
         }

       while (((*string)[old_index] == ' ') && ((*string)[old_index] != '\0'))
         {
         new_string[new_index] = (*string)[old_index];
         ++old_index;
         ++new_index;
         }

       /* add timestamp for creationdate */
       if (strcmp(datatype, "timestamp") == 0)
         {
         _pdm_debug("adding TIMESTAMP for date", 0);
         strcat(new_string, "TIMESTAMP");
         new_index = new_index + 9;
         new_string[new_index] = ' ';
         ++new_index;
         }

       new_string[new_index] = '\'';
       ++new_index;

       while ((*string)[old_index] != '\0')
         {
         if ((strncmp(*string + old_index, "and ", 4) != 0) &&
             (strncmp(*string + old_index, "or ", 3) != 0) &&
             (strncmp(*string + old_index, "not ", 4) != 0))
           {
           while (((*string)[old_index] != ' ') && 
                  ((*string)[old_index] != '\0'))
             {
             new_string[new_index] = (*string)[old_index];
             ++old_index;
             ++new_index;
             }
  
           while (((*string)[old_index] == ' ') && 
                  ((*string)[old_index] != '\0'))
             {
             new_string[new_index] = (*string)[old_index];
             ++old_index;
             ++new_index;
             }
           } /* end if string */
         else
           {
           new_string[new_index - 1] = '\'';
           new_string[new_index] = ' ';
           ++new_index;

           while (((*string)[old_index] != ' ') && 
                  ((*string)[old_index] != '\0'))
             {
             new_string[new_index] = (*string)[old_index];
             ++old_index;
             ++new_index;
             }

           while (((*string)[old_index] == ' ') && 
                  ((*string)[old_index] != '\0'))
             {
             new_string[new_index] = (*string)[old_index];
             ++old_index;
             ++new_index;
             }
      
           for (i = 0; i < strlen(attr); ++i)
              {
              new_string[new_index] = attr[i];
              ++new_index;
              }

           new_string[new_index] = ' ';
           ++new_index;
           break;
           }
         } /* end while (*string)[old_index] != '\0' */

       }  /* end if string */
     else
       return(PDM_E_INVALID_STRING);
     }  /* end while string */

  new_string[new_index] = '\'';
  ++new_index;
  new_string[new_index] = '\0';
  *string = NULL;
  PDUfill_in_string(string, new_string);
  _pdm_debug("string with quotes = <%s>", *string);

  PDUfree_string(&new_string);

  return(status);
}  /* end PDUadd_quotes */

void PDUget_display_attrs(buffer, attr_list)
MEMptr     buffer;
char     **attr_list;
{
char     **data_row;
int        row;
int        length;
int        col;

   MEMbuild_array(buffer);
   PDUget_buffer_col(buffer, "p_pdmname", &col);
   PDUsetup_buffer(buffer, ROW, &data_row);

   /* calculate the length of the attribute list */
   length = 1;
   for (row = 0; row < buffer->rows; ++row)
      {
      length = length + strlen(data_row[(buffer->columns * row) + col]) + 2;
      }

   *attr_list = (char *) malloc (length + 1);
   memset(*attr_list, NULL, (length + 1));

   /* concatenate the attributes together separated by commas */
   strcpy(*attr_list, "");

   for (row = 0; row < buffer->rows; ++row)
      {
      if (row != 0)
        strcat(*attr_list, ", ");
      strcat(*attr_list, data_row[(buffer->columns * row) + col]);
      }

   _pdm_debug("Attribute list = <%s>", *attr_list);
   MEMclose(&buffer);

}  /* end PDUget_display_attrs */

void PDUadd_tablename(string, catalog)
char      **string;
char      *catalog;
{
int       old_index;
int       new_index;
char      *new_string = NULL;

  new_string = (char *) malloc (sizeof (char) * 500);
  memset(new_string, NULL, sizeof (char) * 500);
  old_index = 0;
  new_index = 0;

  while (((*string)[old_index] != ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  while (((*string)[old_index] == ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  strcat(new_string, catalog);
  new_index += strlen(catalog);
  strcat(new_string, ".");
  ++new_index;

  while ((*string)[old_index] != '\0')
    {
    if ((strncmp(*string + old_index, "and ", 4) != 0) &&
        (strncmp(*string + old_index, "or ", 3) != 0) &&
        (strncmp(*string + old_index, "not ", 4) != 0))
      {
      while (((*string)[old_index] != ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }

      while (((*string)[old_index] == ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }
      }  /* end if string */
    else
      {
      while (((*string)[old_index] != ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }

      while (((*string)[old_index] == ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }

      strcat(new_string, catalog);
      new_index += strlen(catalog);
      strcat(new_string, ".");
      ++new_index;
      
      }  /* end else */
  }  /* end while not NULL */

  new_string[new_index] = '\0';
  *string = NULL;
  PDUfill_in_string(string, new_string);
  _pdm_debug("string with tablename = <%s>", *string);

  PDUfree_string(&new_string);

}  /* end PDUadd_tablename */

int PDUcheck_search_string_syntax(string)
char    *string;
{
int       index;
short     alpha;

   _pdm_debug("in the function PDUcheck_search_string_syntax", 0);

   index = 0;

   /* go past any blank spaces */
   while ((string[index] != '\0') && (string[index] == ' '))
     ++index;

   /* check for an operator */
   if (((string)[index] == '=') || ((string)[index] == '<') ||
       ((string)[index] == '>') || ((string)[index] == '!') ||
       ((string)[index] == 'l'))
     {
     /* if index = l, make sure the string is "like" */
     if (string[index] == 'l')
       {
       if (strncmp(string, "like ", 5) != 0)
         return(PDM_E_INVALID_STRING);
       }
     ++index; 
     }
   else
     return(PDM_E_INVALID_STRING);

   alpha = FALSE;
   /* look for the first occurrence of an alphanumeric character */
   while ((string)[index] != '\0')
     if (isalnum(string[index]))
       {
       alpha = TRUE;
       break;
       }
     else
       ++index;

   if (alpha == TRUE)
     return(PDM_S_SUCCESS);
   else
     return(PDM_E_INVALID_STRING);
}  /* end PDUcheck_search_string_syntax */

void PDUadd_tablename_to_sort_string(string, catalog)
char      **string;
char      *catalog;
{
int       old_index;
int       new_index;
char      *new_string = NULL;

  new_string = (char *) malloc (sizeof (char) * 500);
  memset(new_string, NULL, sizeof (char) * 500);
  old_index = 0;
  new_index = 0;

  /* go past "order" */
  while (((*string)[old_index] != ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  /* go past any blank spaces */
  while (((*string)[old_index] == ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  /* go past "by" */
  while (((*string)[old_index] != ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  /* go past any blank spaces */
  while (((*string)[old_index] == ' ') && ((*string)[old_index] != '\0'))
    {
    new_string[new_index] = (*string)[old_index];
    ++old_index;
    ++new_index;
    }

  if (new_index == 0)
    strcpy(new_string, catalog);
  else
    strcat(new_string, catalog);
  new_index += strlen(catalog);
  strcat(new_string, ".");
  ++new_index;

  while ((*string)[old_index] != '\0')
    {
    if ((*string)[old_index] != ',')
      {
      while (((*string)[old_index] != ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }

      while (((*string)[old_index] == ' ') &&
             ((*string)[old_index] != '\0'))
        {
        new_string[new_index] = (*string)[old_index];
        ++old_index;
        ++new_index;
        }

    if ((*string)[old_index] != '\0')
      {
      strcat(new_string, catalog);
      new_index += strlen(catalog);
      strcat(new_string, ".");
      ++new_index;
      }
      
      }  /* end if string */
  }  /* end while not NULL */

  new_string[new_index] = '\0';
  *string = NULL;
  PDUfill_in_string(string, new_string);
  _pdm_debug("sort string with tablename = <%s>", *string);

  PDUfree_string(&new_string);
}

PDUtic_it(string)
char   **string;
{
char   *out_string = NULL;
int     length;
int     old_index;
int     new_index;

  _pdm_debug("in the function PDUtic_it", 0);
  _pdm_debug("string = <%s>", *string);

  length = strlen(*string) + 50;
  out_string = (char *) malloc (sizeof (char) * length);
  memset(out_string, NULL, sizeof (char) * length);

  old_index = 0;
  new_index = 0;

  while ((*string)[old_index] != '\0')
     {
     if ((*string)[old_index] != '\'')
       {
       out_string[new_index] = (*string)[old_index];
       ++new_index;
       ++old_index;
       }
     else
       {
       out_string[new_index] = '\'';
       ++new_index;
       out_string[new_index] = '\'';
       ++new_index;
       ++old_index;
       }
     }

  out_string[new_index] = '\0';
  *string = NULL;
  PDUfill_in_string(string, out_string);
  _pdm_debug("string with tic marks = <%s>", *string);

  PDUfree_string(&out_string);

} /* end PDUtic_it */

void PDUlike_search_string(string)
char     **string;
{
int       old_index;
int       new_index;
int       index;
int       length;
char      *new_string = NULL;

  _pdm_debug("in the function PDUlike_search_string", 0);
  _pdm_debug("mallocing new_string", 0);

  length = strlen(*string);
  new_string = (char *) malloc (sizeof (char) * length);
  memset(new_string, NULL, sizeof (char) * length);

  _pdm_debug("string = <%s>", *string);

   index = 0;

   /* go past "where" */
   while (((*string)[index] != '\0') && ((*string)[index] != ' '))
     ++index;

   while ((*string)[index] != '\0')
      {
      /* go past blank spaces */
      while (((*string)[index] != '\0') && ((*string)[index] == ' '))
        ++index;

      /* go past attribute */
      while (((*string)[index] != '\0') && ((*string)[index] != ' '))
        ++index;

      /* go past blank spaces */
      while (((*string)[index] != '\0') && ((*string)[index] == ' '))
        ++index;

      /* check for an operator */
      _pdm_debug("checking for operator", 0);
      if (strncmp((*string) + index, "like ", 5)  == 0)
        {
        _pdm_debug("adding () for LIKE", 0);
        new_index = 0;
        old_index = 0;
        strcpy(new_string, "where (");
        new_index += strlen(new_string);
        old_index += strlen(new_string) - 1;
        while ((*string)[old_index] != '\0')
          {
          new_string[new_index] = (*string)[old_index];
          ++old_index;
          ++new_index;
          }
       
        _pdm_debug("after adding opening paren", 0);
        _pdm_debug("new_string = <%s>", new_string);
        new_string[new_index] = ')';
        _pdm_debug("after adding closing paren", 0);
        _pdm_debug("new_string = <%s>", new_string);
        ++new_index;
  
        new_string[new_index] = '\0';
        _pdm_debug("after adding NULL terminator", 0);
        _pdm_debug("new_string = <%s>", new_string);
        *string = NULL;
        PDUfill_in_string(string, new_string);
        _pdm_debug("string with ()s = <%s>", *string);
      
        PDUfree_string(&new_string);
        return;
        }
      else
        {
        /* go past operator */
        while (((*string)[index] != '\0') && ((*string)[index] != ' '))
          ++index;
 
        /* go past blank spaces */
        while (((*string)[index] != '\0') && ((*string)[index] == ' '))
          ++index;

        /* go past value */
        while (((*string)[index] != '\0') && ((*string)[index] != ' '))
          ++index;
        }
      }

  _pdm_debug("returning string unchanged", 0);

} /* end PDUlike_search_string */

int PDUfind_server_in_string(string, servers, no_servers)
  char    *string;
  char    ***servers;
  int     *no_servers;
{
  int     i, index, char_index;

  _pdm_debug("in the function PDUfind_server_in_string", 0);

  *no_servers = 0;
  index = 0;

  *servers = (char **) malloc (sizeof (char *) * 200);
  memset(*servers, NULL, sizeof (char *) * 200);

  for (i = 0; i < 200; ++i)
     {
     (*servers)[i] = (char *) malloc (sizeof (char) * 25);
     memset((*servers)[i], NULL, sizeof (char) * 25);
     }

  /* go past address */
  _pdm_debug("passing address", 0);
  while ((string[index] != '\0') && (string[index] != ' '))
    ++index;

  while (string[index] != '\0')
      {
      /* go past blank spaces */
      _pdm_debug("passing blank spaces", 0);
      while ((string[index] != '\0') && (string[index] == ' '))
        ++index;

      /* check next entry */
      _pdm_debug("checking for pdms", 0);
      if (strncmp(string + index, "pdms_", 5) == 0)
        {
        /* pass the pdms_ */
        index += 5;
        char_index = 0;
        while ((string[index] != '\0') && (string[index] != ' '))
           {
           (*servers)[*no_servers][char_index] = string[index];
           ++char_index;
           ++index;
           }

        _pdm_debug("server found = <%s>", (*servers)[*no_servers]);
        _pdm_debug("incrementing number of servers", 0);
        ++(*no_servers);
        }
      else
        {
        /* go past this entry */
        _pdm_debug("passing current entry", 0);
        while ((string[index] != '\0') && (string[index] != ' '))
          ++index;
        }
      }

  _pdm_debug("number of servers = %d", (char *)*no_servers);

  for (i = 0; i < (*no_servers); ++i)
     {
     _pdm_debug("entry = %d", (char *)i);
     _pdm_debug("server entry = <%s>", (*servers)[i]);
     }

  return(PDM_S_SUCCESS);
}

int PDUfind_env_in_string(string, envs, no_envs)
  char    *string;
  char    ***envs;
  int     *no_envs;
{
  int     status = PDM_S_SUCCESS;
  int     i, index, char_index;

  _pdm_debug("in the function PDUfind_env_in_string", 0);

  *no_envs = 0;
  index = 0;

  *envs = (char **) malloc (sizeof (char *) * 200);
  memset(*envs, NULL, sizeof (char *) * 200);

  for (i = 0; i < 200; ++i)
     {
     (*envs)[i] = (char *) malloc (sizeof (char) * 25);
     memset((*envs)[i], NULL, sizeof (char) * 25);
     }

  /* go past address */
  _pdm_debug("passing address", 0);
  while ((string[index] != '\0') && (string[index] != ' '))
    ++index;

  while (string[index] != '\0')
      {
      /* go past blank spaces */
      _pdm_debug("passing blank spaces", 0);
      while ((string[index] != '\0') && (string[index] == ' '))
        ++index;

      /* check next entry */
      _pdm_debug("checking for pdme", 0);
      if (strncmp(string + index, "pdme_", 5) == 0)
        {
        /* pass the pdme_ */
        index += 5;
        char_index = 0;
        while ((string[index] != '\0') && (string[index] != ' '))
           {
           (*envs)[*no_envs][char_index] = string[index];
           ++char_index;
           ++index;
           }

        _pdm_debug("env found = <%s>", (*envs)[*no_envs]);
        _pdm_debug("incrementing number of envs", 0);
        ++(*no_envs);
        }
      else
        {
        /* go past this entry */
        _pdm_debug("passing current entry", 0);
        while ((string[index] != '\0') && (string[index] != ' '))
          ++index;
        }
      }

  _pdm_debug("number of envs = %d", (char *)*no_envs);

  for (i = 0; i < (*no_envs); ++i)
     {
     _pdm_debug("entry = %d", (char *)i);
     _pdm_debug("env entry = <%s>", (*envs)[i]);
     }

  return(status);
}

int PDUvalidate_criteria(form, string)
Form    form;
char    *string;
{
int     index = 0;
int     status = PDM_S_SUCCESS;
extern Form PDU_form_id;

  _pdm_debug("in the function PDUvalidate_criteria", 0);

  form = PDU_form_id;

  while (string[index] != '\0')
     {
     if (string[index] == ' ')
       {
       status = PDM_E_SYNTAX_ERROR;
       return(status);
       }
     else
       ++index;
     }
  return(status);
}

int PDUtrunc_usageid(string)
char  **string;
{
char   *s;
int     char_index;
int     status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUtrunc_usageid", 0);

  if (*string)
    {
    s = *string + strlen(*string) - 1;
    char_index = strlen(*string) - 1;
    
    while ((*string)[char_index] != '#')
      {
      --char_index;
      }

    /* decrement the string */
    --char_index;

    (*string)[char_index] = '\0';

    _pdm_debug("string = <%s>", *string);
    } /* end if string */

  return(status);
} /* end PDUtrunc_usageid */
