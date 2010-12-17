#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"

/* 
 Doc: NFM query tools
*/
 
long NFMwrite_query_struct (query, select, from, where, order, prompts)
    struct NFMquery_info *query;
    char *select, *from, *where, *order, *prompts;
{
  struct NFMquery_info *q;
  static char *fname = "NFMwrite_query_struct";

  _NFMdebug ((fname, "Enter.\n"));

  _NFMdebug ((fname, "select: <%s>\n", select));
  _NFMdebug ((fname, "from: <%s>\n", from));
  _NFMdebug ((fname, "where: <%s>\n", where));
  _NFMdebug ((fname, "order: <%s>\n", order));
  _NFMdebug ((fname, "prompts: <%s>\n", prompts));

  q = query;

  if ((q->select_clause = (char *) malloc (strlen (select) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (select) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (select) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->select_clause, select);

  if ((q->from_clause = (char *) malloc (strlen (from) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (from) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (from) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->from_clause, from);

  if ((q->where_clause = (char *) malloc (strlen (where) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (where) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (where) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->where_clause, where);

  if ((q->order_by_clause = (char *) malloc (strlen (order) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (order) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (order) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->order_by_clause, order);

  if ((q->prompts = (char *) malloc (strlen (prompts) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (prompts) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (prompts) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->prompts, prompts);

  _NFMdebug ((fname, "Exit: NFM_S_SUCCESS.\n"));
  return (NFM_S_SUCCESS);
}

long NFMfree_query_struct (query)
    struct NFMquery_info *query;
{
  struct NFMquery_info *q;
  static char *fname = "NFMfree_query_struct";

  _NFMdebug ((fname, "Enter.\n"));
  q = query;

  if (q->select_clause)    free (q->select_clause);
  if (q->from_clause)      free (q->from_clause);
  if (q->where_clause)     free (q->where_clause);
  if (q->order_by_clause)  free (q->order_by_clause);
  if (q->prompts)          free (q->prompts);
  q->select_clause = 0;
  q->from_clause = 0;
  q->where_clause = 0;
  q->order_by_clause = 0;
  q->prompts = 0;

  _NFMdebug ((fname, "Exit: NFM_S_SUCCESS.\n"));
  return (NFM_S_SUCCESS);
}
 
long NFMwrite_ftr_query_struct (query, select, from, where, order, prompts,
		ftr, aqs, aqf, aqw)
    struct NFMquery_ftr_info *query;
    char *select, *from, *where, *order, *prompts, *ftr, *aqs, *aqf, *aqw;
{
  struct NFMquery_ftr_info *q;
  static char *fname = "NFMwrite_ftr_query_struct";

  _NFMdebug ((fname, "Enter.\n"));

  _NFMdebug ((fname, "select: <%s>\n", select));
  _NFMdebug ((fname, "from: <%s>\n", from));
  _NFMdebug ((fname, "where: <%s>\n", where));
  _NFMdebug ((fname, "order: <%s>\n", order));
  _NFMdebug ((fname, "prompts: <%s>\n", prompts));
  _NFMdebug ((fname, "ftr: <%s>\n", ftr));
  _NFMdebug ((fname, "aqs: <%s>\n", aqs));
  _NFMdebug ((fname, "aqf: <%s>\n", aqf));
  _NFMdebug ((fname, "aqw: <%s>\n", aqw));

  q = query;

  if ((q->select_clause = (char *) malloc (strlen (select) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (select) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (select) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->select_clause, select);

  if ((q->from_clause = (char *) malloc (strlen (from) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (from) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (from) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->from_clause, from);

  if ((q->where_clause = (char *) malloc (strlen (where) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (where) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (where) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->where_clause, where);

  if ((q->order_by_clause = (char *) malloc (strlen (order) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (order) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (order) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->order_by_clause, order);

  if ((q->prompts = (char *) malloc (strlen (prompts) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (prompts) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (prompts) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->prompts, prompts);

  if ((q->ftr = (char *) malloc (strlen (ftr) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (ftr) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (ftr) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->ftr, ftr);

  if ((q->aqs = (char *) malloc (strlen (aqs) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (aqs) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (aqs) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->aqs, aqs);

  if ((q->aqf = (char *) malloc (strlen (aqf) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (aqf) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (aqf) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->aqf, aqf);

  if ((q->aqw = (char *) malloc (strlen (aqw) + 1)) == NULL)
      {
      _NFMdebug ((fname, "malloc failed; size = <%d>\n", strlen (aqw) + 1));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d", strlen (aqw) + 1);
      return (NFM_E_MALLOC);
      }
  strcpy (q->aqw, aqw);

  _NFMdebug ((fname, "Exit: NFM_S_SUCCESS.\n"));
  return (NFM_S_SUCCESS);
}

long NFMfree_ftr_query_struct (query)
    struct NFMquery_ftr_info *query;
{
  struct NFMquery_ftr_info *q;
  static char *fname = "NFMfree_ftr_query_struct";

  _NFMdebug ((fname, "Enter.\n"));
  q = query;

  if (q->select_clause)    free (q->select_clause);
  if (q->from_clause)      free (q->from_clause);
  if (q->where_clause)     free (q->where_clause);
  if (q->order_by_clause)  free (q->order_by_clause);
  if (q->prompts)          free (q->prompts);
  if (q->ftr)		   free (q->ftr);
  if (q->aqs)		   free (q->aqs);
  if (q->aqf)		   free (q->aqf);
  if (q->aqw)		   free (q->aqw);

  q->select_clause = 0;
  q->from_clause = 0;
  q->where_clause = 0;
  q->order_by_clause = 0;
  q->prompts = 0;
  q->ftr = 0;
  q->aqs = 0;
  q->aqf = 0;
  q->aqw = 0;
 
  _NFMdebug ((fname, "Exit: NFM_S_SUCCESS.\n"));
  return (NFM_S_SUCCESS);
}
