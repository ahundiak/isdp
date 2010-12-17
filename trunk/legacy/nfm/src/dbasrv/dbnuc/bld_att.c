/* $Revision: 1.1 $ */
#include "dba.ext"
#include "cursor.def"
#include "dmalloc.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern struct dba_sch *dba_csch, *dba_fsch;
extern char *dba_errtxt;

/* Function:	dba_build_att 

Description: 	builds an attribute list from the RIS dictionary for the 
		specified entity

Author: 	Brian Potter
*/
int dba_build_att (ent_ptr, schema)
struct dba_ent *ent_ptr;
int schema;
{
  char attnam[32], sqltxt[200], *mscolumns, **defvals, **aliases, **formats,
    stext[241];
  int count, status, row=0, mscolumn, attnum, *attnums, attslot=0, 
    alen, atyp, abyt;
  sqlda *desc;
  struct dba_sch *tsch;
  struct dba_att *tatt, *fatt=0;
  struct dba_code_list *ccl;
  union mixed { char c[2];  short s[1]; } retval;

  if (!schema) schema = dba_csch->schema;
  for (tsch=dba_fsch; tsch; tsch=tsch->nsch) if (tsch->schema == schema) break;
  if (!tsch)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld", 0, 
      (long) schema, NP));
    return (99); }

  mscolumn = dba_read_mscolumns (tsch->name, ent_ptr->entnum, 
    &mscolumns, &attnums, &defvals, &aliases, &formats);

  sprintf (sqltxt, "select * from %s.%s", tsch->name, ent_ptr->entnam);
  status = dba_select (DBA_C1, &desc, sqltxt);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  for (count=0; count<desc->sqld; ++count)
    { strncpy (attnam, desc->sqlvar[count].sqlname.sqlnamec,
      desc->sqlvar[count].sqlname.sqlnamel);
    attnam[desc->sqlvar[count].sqlname.sqlnamel] = 0;
    attnum = 0;
    retval.s[0] = desc->sqlvar[count].sqltype;
    dba_short_swap_bytes (&retval.s[0]);
    atyp = retval.c[0];
    abyt = desc->sqlvar[count].sqllen;
    dba_malloc_att (&tatt, NP);
    dba_add_att_ptr (ent_ptr, tatt, NP);
    if (!fatt) fatt = tatt;

    if (mscolumn)
      { attslot = dba_search_string (mscolumns, attnam);
      if (attslot) 
        { attnum = attnums[attslot];
        if (aliases[attslot]) 
          tatt->alias = dba_dstrdup (aliases[attslot], DM_MEMBER); } }
    if (!tatt->alias) tatt->alias = dba_dstrdup (attnam, DM_MEMBER);

    strcpy (tatt->entnam, ent_ptr->entnam);
/* 6/18/94 blp
    status = dba_set_sch_ptr (schema, NP, &tsch, 1);
    for (tent=tsch->fent; tent; tent=tent->nent)
      if (strcmp (tent->entnam, ent_ptr->entnam) == 0) break;
    if (tent) tatt->entnum = tent->entnum;
*/
    tatt->entnum = ent_ptr->entnum;
    strcpy (tatt->attnam, attnam);
    switch (atyp)
      { case 1:  
        atyp = ATT_ASC;  tatt->alen = abyt;
        if (mscolumn && attslot)
          { if (defvals[attslot])
            tatt->defval = dba_dstrdup (defvals[attslot], DM_MEMBER);
          if (formats[attslot])
            tatt->format = dba_dstrdup (formats[attslot], DM_MEMBER); }
        if (!tatt->defval) tatt->defval = dba_dstrdup ("\0", DM_MEMBER);
        if (!tatt->format) tatt->format = dba_dstrdup ("%s", DM_MEMBER);
        break;
      case 4:  case 5:
        if (atyp == 5) tatt->alen = 6;  else tatt->alen = 11;
        atyp = ATT_INT;  abyt = 4;
        if (mscolumn && attslot)
          { if (defvals[attslot])
            tatt->defval = dba_dstrdup (defvals[attslot], DM_MEMBER);
          if (formats[attslot])
            tatt->format = dba_dstrdup (formats[attslot], DM_MEMBER); }
        if (!tatt->defval) tatt->defval = dba_dstrdup ("0", DM_MEMBER);
        if (!tatt->format) tatt->format = dba_dstrdup ("%ld", DM_MEMBER);
        break;
      case 3:  case 7:  case 8:
        atyp = ATT_DOUBLE;  abyt = 8;
        tatt->alen = 20;  
        if (mscolumn && attslot)
          { if (defvals[attslot])
            tatt->defval = dba_dstrdup (defvals[attslot], DM_MEMBER);
          if (formats[attslot])
            tatt->format = dba_dstrdup (formats[attslot], DM_MEMBER); }
        if (!tatt->defval) tatt->defval = dba_dstrdup ("0.", DM_MEMBER);
        break;
      case 9:
        atyp = ATT_DATE;  tatt->alen = 50;  
        if (mscolumn && attslot)
          { if (defvals[attslot])
            tatt->defval = dba_dstrdup (defvals[attslot], DM_MEMBER);
          if (formats[attslot])
            tatt->format = dba_dstrdup (formats[attslot], DM_MEMBER); }
        if (!tatt->defval) tatt->defval = dba_dstrdup ("\0", DM_MEMBER);
        break; }
    if (schema) tatt->schema = schema;  else tatt->schema = ent_ptr->schema;
    if (attnum) tatt->attnum = attnum;  else tatt->attnum = ent_ptr->anumtot;
    tatt->abyt = abyt;  tatt->atyp = atyp;
    tatt->size = tatt->alen + 1;
    tatt->attval = dba_dmalloc (tatt->size, DM_MEMBER);
    tatt->label = COLUMN;
    tatt->row = row;  ++row;
    tatt->column = 1;
    tatt->subtyp = 0;
    tatt->write = 1;
    tatt->decimal = 6;
    tatt->active = 1;
    tatt->exclude = 1; }

  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

/* find coded columns */
  for (tatt=fatt; tatt; tatt=tatt->natt)
    { if (tatt->atyp != ATT_INT) continue;
    status = dba_find_codelist (tatt->schema, tatt->entnam, tatt->attnam, &ccl);
    if (status) continue;
    tatt->atyp = ATT_CODE;
    status = dba_find_codeval (1, tatt->schema, tatt->entnam, tatt->attnam, 
      stext, &alen);
    if (!status)
      { tatt->defval = dba_drealloc (tatt->defval, alen+1);
      strcpy (tatt->defval, stext); }
    tatt->alen = alen;
    if (tatt->alen + 1 > tatt->size)
      { tatt->size = tatt->alen + 1;
      tatt->attval = dba_drealloc (tatt->attval, tatt->size); } }

  ent_ptr->catt = ent_ptr->fatt;
  ent_ptr->built = 1;
/* 5/15/94 blp
  ent_ptr->dis_built = 0;
*/

  dba_key_columns (tsch->name, ent_ptr);
  if (ent_ptr->key_rec > ent_ptr->key_lng)
    { ent_ptr->key_lng = ent_ptr->key_rec;
    ent_ptr->key = dba_drealloc (ent_ptr->key, ent_ptr->key_lng); }

  return (0);
}
