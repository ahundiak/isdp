/* $Revision: 1.2 $ */
#include "dba.ext"

extern char *dba_errtxt, *dba_fldval;

/* Function:	dba_format_check */
int dba_format_check (att_ptr)
struct dba_att *att_ptr;
{
  char text[200];
  double dtmp;
  int status, itmp, alen;
  long codenum;

  if (!strlen (dba_fldval) || strcmp (dba_fldval, "NULL") == 0) return (0);

  alen = att_ptr->alen;  

  switch (att_ptr->atyp) {
    case ATT_ASC:  case ATT_RIS_TEXT:
      if (strlen (dba_fldval) > alen)
        dba_fldval[alen] = 0;
/* 2/25/93 blp
      dba_double_quote (&dba_fldval, &dba_fv_size);
*/
      break;
    case ATT_INT: /*  case ATT_SHORT: */
      if (!strlen (dba_fldval)) strcpy (dba_fldval, "0");
      status = sscanf (dba_fldval, "%d", &itmp);
      if (status != 1)
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_INT_REQ, NP,0,NP,NP));
        return (99); }
      if ((alen == 6 && (itmp < -32767 || itmp > 32767)) 
        || (alen == 11 && (itmp < -2147483647 || itmp > 2147483647)))
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_INT_OVERFLOW, NP,0,NP,NP));
        return (99); }
      break;
    /* case ATT_FLOAT: */  case ATT_DOUBLE:  case ATT_DECIMAL:
      if (!strlen (dba_fldval)) strcpy (dba_fldval, "0");
      status = sscanf (dba_fldval, "%lf", &dtmp);
      if (status != 1)
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_NUM_REQ, NP,0,NP,NP));
        return (99); }
      break;
    case ATT_CODE:
      if (dba_fldval[0] != '#' || dba_fldval[strlen (dba_fldval)-1] != '#')
        { status = dba_find_codenum (&codenum, att_ptr->schema, att_ptr->entnam,
          att_ptr->attnam, dba_fldval);
        if (status)
          { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CODELIST, NP,0,NP,NP));
          return (99); } }
      else {
        status = sscanf (&dba_fldval[1], "%ld", &codenum);
        if (status != 1 || codenum <= 0)
          { strcpy (dba_errtxt, dba_get_msg (DBA_E_POS_INT_REQ, NP,0,NP,NP));
          return (99); }
        status = dba_find_codeval (codenum, att_ptr->schema, att_ptr->entnam,
          att_ptr->attnam, dba_fldval, &alen);
        if (status)
          { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CODELIST, NP,0,NP,NP));
          return (99); } }
      break;
    case ATT_SERIAL:
      status = sscanf (dba_fldval, "%d", &itmp);
      if (status != 1 || itmp <= 0)
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_POS_INT_REQ, NP,0,NP,NP));
        return (99); }
      if (itmp<-2147483648 || itmp>2147483647)
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_INT_OVERFLOW, NP,0,NP,NP));
        return (99); }
      break;
    case ATT_DATE:
      status = dba_convert_date (text, dba_fldval);
      if (status) return (99);
      break;
    case ATT_MONEY:
      if (dba_fldval[0] == '$') strcpy (dba_fldval, &dba_fldval[1]);
      status = sscanf (dba_fldval, "%lf", &dtmp);
      if (status != 1)
        { strcpy (dba_errtxt, dba_get_msg (DBA_E_NUM_REQ, NP,0,NP,NP));
        return (99); }
      break; }

  return (0);
}
