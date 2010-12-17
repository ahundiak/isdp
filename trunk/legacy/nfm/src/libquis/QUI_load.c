#include "machine.h"
#include "QUI.h"

long QUIload_definition (form,where_clause)

Form form;
char *where_clause;

{
  static  char    *fname = "QUIload_definition";
  long index, status = QUI_S_SUCCESS;
  long start;
  long end;
  long clause_len;
  char *trio = NULL;
  char *dummy_clause = NULL;
  char logical_op[4];

  _NFIdebug ((fname, "where_clause = <%s>\n", where_clause));

  QUIglobal.QUI_numofattr = 0;

/* get length of where clause and realloc if necessary */

  clause_len = strlen (where_clause);
  if ((dummy_clause = (char *) malloc (clause_len + 1)) == NULL)
    {
      _NFIdebug ((fname, "malloc failed; size = <%d>\n", clause_len + 1));
      ERRload_struct (NFI, QUI_E_MALLOC, "%d", clause_len + 1);
      _NFIdebug ((fname, "returning <0x%.8x>\n", QUI_E_MALLOC));
      return (QUI_E_MALLOC);
    }

  if ((trio = (char *) malloc (clause_len + 1)) == NULL)
    {
      _NFIdebug ((fname, "malloc failed; size = <%d>\n", clause_len + 1));
      ERRload_struct (NFI, QUI_E_MALLOC, "%d", clause_len + 1);
      _NFIdebug ((fname, "returning <0x%.8x>\n", QUI_E_MALLOC));
      return (QUI_E_MALLOC);
    }

  index = 0;
  while (index<clause_len)
  {
/* increment index to start of trio */
    while (where_clause[index]=='(') index++;
    start=index;
/* increment index to end of trio */
    while (where_clause[index]!=')') index++;
    end=index;    
/* separate trio from where clause */
    strcpy(dummy_clause,&where_clause[start]);
    dummy_clause[end-start] = NULL;
    strcpy(trio,dummy_clause);

/* process trio, stuffing into structure */
  
    _NFIdebug ((fname, "trio = <%s>\n", trio));
    if ((status = QUIparse_trio (trio)) == QUI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "trio parsed correctly; incrementing attribute count\n"));
        QUIglobal.QUI_numofattr++;
      }

/* increment index to end of clause, or next trio, looking for operator */
    index++;
    while ((index<clause_len)&&(where_clause[index]==')')) index++;
    if (index<clause_len)
    {
      while (where_clause[index]==' ') index++;
      start = index;
      while (where_clause[index]!=' ') index++;
      end = index;
      strcpy(dummy_clause,&where_clause[start]);
      dummy_clause[end-start] = NULL;
      strcpy(logical_op,dummy_clause);
      _NFIdebug ((fname, "logical = .%s.\n", logical_op));
      if (strcmp(logical_op,"AND")==0)
        QUI_attrib_displayed[QUIglobal.QUI_numofattr-1].and_or=1;
      else
        QUI_attrib_displayed[QUIglobal.QUI_numofattr-1].and_or=0;
/* increment index beyond next '(' */
      index++;
    }
  }
  QUIset_values(form,0.0);

  if (dummy_clause) free (dummy_clause);
  if (trio) free (trio);

  _NFIdebug ((fname, "returning <0x%.8x>\n", status));
  return (status);
}
