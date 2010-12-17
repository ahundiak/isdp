/* $Revision: 1.1 $ */
#include "dba.ext"
extern int dba_graphic_mode, dba_no_join_query;
extern struct dba_sch *dba_csch;
extern struct dba_ent *dba_cent, *dba_ment[];

/* Function:	dba_build_where_text */
int dba_build_where_text (s1_ptr, s1_size, mnunum)
char **s1_ptr;
unsigned long *s1_size;
int mnunum;
{
  int status, fence=0, do_fence=0, where_lng=0, got_where=0;
  struct dba_ent *tent, *ment;
  struct dba_outjoin *outjoin;

  if (mnunum == 102) ment = dba_cent;
  else ment = dba_ment[mnunum];

  if (ment->where)
    { where_lng = strlen (ment->where);
    if (where_lng > 0)
      { if (strlen (*s1_ptr) + where_lng + 100 > *s1_size)
        { *s1_size += where_lng + 100;
        *s1_ptr = dba_drealloc (*s1_ptr, *s1_size); }
      strcat (*s1_ptr, " where ");
      strcat (*s1_ptr, ment->where);
      got_where = 1; } }

  for (outjoin=ment->foutjoin; outjoin; outjoin=outjoin->noutjoin)
    { if (outjoin->outer || outjoin->to_repatt->att->schema != ment->schema
      || outjoin->to_repatt->att->sql_driven)
      continue;
    if (strlen (*s1_ptr) + 200 > *s1_size)
      { *s1_size += 200;  *s1_ptr = dba_drealloc (*s1_ptr, *s1_size); }
    if (!got_where) strcat (*s1_ptr, " where ");
    else strcat (*s1_ptr, " and ");
    strcat (*s1_ptr, outjoin->from_repatt->att->entnam);
    strcat (*s1_ptr, ".");
    strcat (*s1_ptr, outjoin->from_repatt->att->attnam);
    strcat (*s1_ptr, " = ");
    strcat (*s1_ptr, outjoin->to_repatt->att->entnam);
    strcat (*s1_ptr, ".");
    strcat (*s1_ptr, outjoin->to_repatt->att->attnam);
    got_where = 1; }

  fence = dba_inq_fence_exists ();

  for (tent=dba_csch->fent; tent; tent=tent->nent)
    { if (tent->select <= 0) continue;
    if (tent->select > 1 && dba_no_join_query) continue;
    if (fence)
      { if (tent == dba_cent) do_fence = 1;  else do_fence = 0; }
    status = dba_build_where (tent, &got_where, do_fence, 1,
      s1_ptr, s1_size, 0);
    if (status) return (status); }

/*	changed 10/14/92.  blp
      { tent->totrow = 0;  tent->currow = 0;
      dba_paint_current_row (mnunum);
      return (status); } }
*/

  return (0);
}
