/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

/* Function:	dba_malloc_sch */
int dba_malloc_sch (sch_ptr, in_sch_ptr)
struct dba_sch **sch_ptr, *in_sch_ptr;
{
  *sch_ptr =
    (struct dba_sch *) dba_dmalloc (sizeof (struct dba_sch), DM_SCHEMA);
  if (!in_sch_ptr)
    memset (*sch_ptr, 0, sizeof (struct dba_sch));
  else
    { memcpy (*sch_ptr, in_sch_ptr, sizeof (struct dba_sch));
    (*sch_ptr)->fent = 0;  (*sch_ptr)->lent = 0;  (*sch_ptr)->built = 0; 
    (*sch_ptr)->fcc = 0;  (*sch_ptr)->lcc = 0;  
    (*sch_ptr)->fcl = 0;  (*sch_ptr)->lcl = 0;  (*sch_ptr)->code_built = 0; }

  return (0);
}
/* Function:	dba_free_sch */
int dba_free_sch (sch_ptr)
struct dba_sch **sch_ptr;
{
  struct dba_ent *cent, *tent;
  struct dba_coded_column *ccc, *tcc;
  struct dba_code_list *ccl, *tcl;

  for (cent=tent=(*sch_ptr)->fent; tent; )
    { tent = cent->nent;  dba_dfree (cent);  cent = tent; }
  for (ccc=tcc=(*sch_ptr)->fcc; tcc; )
    { tcc = ccc->ncc;  dba_dfree (ccc);  ccc = tcc; }
  for (ccl=tcl=(*sch_ptr)->fcl; tcl; )
    { tcl = ccl->ncl;  dba_dfree (ccl);  ccl = tcl; }
  dba_dfree (*sch_ptr);  *sch_ptr = 0;

  return (0);
}
/* Function:	dba_malloc_find */
int dba_malloc_find (find_ptr, in_find_ptr)
struct dba_find **find_ptr, *in_find_ptr;
{
  *find_ptr =
    (struct dba_find *) dba_dmalloc (sizeof (struct dba_find), DM_QUERY);
  if (!in_find_ptr)
    memset (*find_ptr, 0, sizeof (struct dba_find));
  else
    { memcpy (*find_ptr, in_find_ptr, sizeof (struct dba_find));
    if (in_find_ptr->text_lng)
      { (*find_ptr)->text = dba_dmalloc (in_find_ptr->text_lng, DM_MEMBER);
      strcpy ((*find_ptr)->text, in_find_ptr->text); } }

  return (0);
}
/* Function:	dba_free_find */
int dba_free_find (ent_ptr)
struct dba_ent *ent_ptr;
{
  struct dba_find *cfind, *tfind;

  for (cfind=ent_ptr->ffind; cfind; )
    { tfind = cfind->nfind;
    if (cfind->text) dba_dfree (cfind->text);
    dba_dfree (cfind);
    cfind = tfind; }
  ent_ptr->ffind = 0;  ent_ptr->lfind = 0;

  return (0);
}
/* Function:	dba_malloc_repatt */
int dba_malloc_repatt (rep_ptr, in_rep_ptr)
struct dba_repatt **rep_ptr, *in_rep_ptr;
{
  *rep_ptr =
    (struct dba_repatt *) dba_dmalloc (sizeof (struct dba_repatt), DM_REPATT);
  memset (*rep_ptr, 0, sizeof (struct dba_repatt));

/*
  (*rep_ptr)->join_from = dba_dmalloc (1, DM_MEMBER);
  (*rep_ptr)->join_from[0] = 0;
  (*rep_ptr)->from_lng = 1;
  (*rep_ptr)->join_to = dba_dmalloc (1, DM_MEMBER);
  (*rep_ptr)->join_to[0] = 0;
  (*rep_ptr)->to_lng = 1;
*/

  if (in_rep_ptr)
    { memcpy (*rep_ptr, in_rep_ptr, sizeof (struct dba_repatt));
    if (in_rep_ptr->join_from)
      { (*rep_ptr)->join_from = dba_dmalloc (in_rep_ptr->from_lng, DM_MEMBER);
      strcpy ((*rep_ptr)->join_from, in_rep_ptr->join_from); }
    if (in_rep_ptr->join_to)
      { (*rep_ptr)->join_to = dba_dmalloc (in_rep_ptr->to_lng, DM_MEMBER);
      strcpy ((*rep_ptr)->join_to, in_rep_ptr->join_to); } }
/*
    if (strlen (in_rep_ptr->join_from))
      dba_strdup (in_rep_ptr->join_from, &((*rep_ptr)->join_from),
        &((*rep_ptr)->from_lng));
    if (strlen (in_rep_ptr->join_to))
      dba_strdup (in_rep_ptr->join_to, &((*rep_ptr)->join_to),
        &((*rep_ptr)->to_lng)); }
*/

  return (0);
}
/* Function:	dba_free_repatt */
int dba_free_repatt (rep_ptr)
struct dba_repatt **rep_ptr;
{
  if ((*rep_ptr)->retval.c) dba_dfree ((*rep_ptr)->retval.c);
  if ((*rep_ptr)->join_from) dba_dfree ((*rep_ptr)->join_from);
  if ((*rep_ptr)->join_to) dba_dfree ((*rep_ptr)->join_to);
  dba_dfree (*rep_ptr);
  *rep_ptr = 0;

  return (0);
}
/* Function:	dba_malloc_outjoin */
int dba_malloc_outjoin (outjoin_ptr, in_outjoin_ptr)
struct dba_outjoin **outjoin_ptr, *in_outjoin_ptr;
{
  *outjoin_ptr =
   (struct dba_outjoin *) dba_dmalloc (sizeof (struct dba_outjoin), DM_OUTJOIN);
  if (!in_outjoin_ptr)
    memset (*outjoin_ptr, 0, sizeof (struct dba_outjoin));
  else
    memcpy (*outjoin_ptr, in_outjoin_ptr, sizeof (struct dba_outjoin));

  return (0);
}
/* Function:	dba_free_outjoin */
int dba_free_outjoin (outjoin_ptr)
struct dba_outjoin **outjoin_ptr;
{
  struct dba_repatt *ra1, *ra2;

  for (ra1=ra2=(*outjoin_ptr)->frepatt; ra2; )
    { ra2 = ra1->nrepatt;
    dba_free_repatt (&ra1);
    ra1 = ra2; }
  dba_dfree (*outjoin_ptr);  *outjoin_ptr = 0;

  return (0);
}
