/* $Revision: 1.2 $ */
#include "dba.ext"
#include "keys.def"

extern char *dba_errtxt, *dba_fldval, dba_text[];
extern unsigned long dba_fv_size;

/* Function:	dba_add_find */
int dba_add_find (logical, att_ptr, relop)
char *logical, *relop;
struct dba_att *att_ptr;
{
  char and_or[4], my_relop[100];
  int status;
  int (*func)();
  long codenum;
  struct dba_ent *tent;
  struct dba_find *tfind;

  status = dba_set_ent_ptr (att_ptr->schema, 0, att_ptr->entnam, &tent, 1, 0);
  if (status) return (99);

  if (!tent->ffind) strcpy (and_or, "   ");
  else { strncpy (and_or, logical, 3);  and_or[3] = 0; }

  dba_parse_relop (att_ptr, relop);

  status = dba_format_check (att_ptr);
  if (status) return (status);
  switch (att_ptr->atyp) {
    case ATT_ASC:  case ATT_RIS_TEXT:
    dba_double_quote (&dba_fldval, &dba_fv_size);
    break;
  }
  dba_malloc_find (&tfind, NP);
  tfind->text_lng = att_ptr->alen + 100;
  tfind->text = dba_drealloc (tfind->text, tfind->text_lng);

  if (strcmp (dba_fldval, "NULL"))
    switch (att_ptr->atyp)
      { case ATT_CODE:
        status = dba_find_codenum (&codenum, att_ptr->schema, att_ptr->entnam,
          att_ptr->attnam, dba_fldval);
        if (status) codenum = 0;
        sprintf (dba_fldval, "%ld", codenum);
        break;
      case ATT_DATE:
        dba_convert_date (dba_fldval, dba_fldval);
        break; }

  if (!strlen (dba_fldval) || strcmp (dba_fldval, "NULL") == 0)
    { strcpy (my_relop, relop);
    dba_upper (my_relop);
    if (strcmp (my_relop, "=") == 0 || strcmp (my_relop, "IS") == 0)
      sprintf (tfind->text, " %s %s.%s is NULL",
        and_or, att_ptr->entnam, att_ptr->attnam);
    else 
      sprintf (tfind->text, " %s %s.%s is not NULL",
        and_or, att_ptr->entnam, att_ptr->attnam); }

  else {
    strcpy (my_relop, relop);
    if (strcmp (my_relop, "!!") == 0)
      { strcpy (my_relop, "like");
      sprintf (dba_text, "%c%s%c", '%', dba_fldval, '%');  
      strcpy (dba_fldval, dba_text); 
    }
    switch (att_ptr->atyp) {
      case ATT_ASC:  case ATT_RIS_TEXT:
      sprintf (tfind->text, " %s %s.%s %s '%s'",
        and_or, att_ptr->entnam, att_ptr->attnam, my_relop, dba_fldval);
      break;

      default:
      sprintf (tfind->text, " %s %s.%s %s %s",
        and_or, att_ptr->entnam, att_ptr->attnam, my_relop, dba_fldval);
      break;
    }
  }

  dba_add_find_ptr (&tent->ffind, &tent->lfind, tfind);
  func = dba_inq_service (DBA_PAINT_FIND);
  if (func) (*func) (tent);
  strcpy (dba_errtxt, dba_get_msg (DBA_M_FIND_ADDED, NP,0,NP,NP));

  return (98);
}
