/* $Revision: 1.1 $ */
#include "dba.ext"
extern int dba_field_label, dba_field_mnunum;
extern struct dba_ent *dba_ment[], *dba_cent;
extern struct dba_att *dba_catt;
extern Form dba_form[];

/* Function:	dba_set_catt */
int dba_set_catt ()
{
  int status, itype=0, dtype=0, column=0, row=0, pos=0;
  struct dba_ent *cent=0;
  struct dba_att *catt=0;
  struct dba_gadget *gadg=0;
  Form fpt=dba_form[dba_field_mnunum];

  if (!fpt) return (99);

  status = FIg_get_type (fpt, dba_field_label, &itype);

  switch (itype)
    { case FI_MULTI_COL:
      status = dba_get_active_col (fpt, dba_field_label, &column, &pos);
    case FI_FIELD:
#if defined __WIN32__
    case FI_NATIVE_FIELD:
#endif
      if (dba_field_mnunum <= 100)
        { cent = dba_ment[dba_field_mnunum];
        dba_get_gadget_type (dba_field_mnunum, dba_field_label, &dtype);
        switch (dtype)
          { case WORKSHEET_HDR:
            for (gadg=cent->fgadget; gadg; gadg=gadg->ngadget)
              if (gadg->header == dba_field_label)
                { dba_field_label = gadg->label;  break; }
            if (!dba_field_label) return (99);
          case WORKSHEET: 
            for (catt=cent->fatt; catt; catt=catt->natt)
              if (catt->label == dba_field_label && catt->column == column)
                break;
            break;
          default:
            status = dba_get_active_row (fpt, dba_field_label, &row, &pos);
            for (catt=cent->fatt; catt; catt=catt->natt)
              if (catt->label == dba_field_label && catt->row == row)
                break;
            break; } }
      else
        { if (dba_cent && dba_field_mnunum == FORM_DBE 
          && dba_field_label == COLUMN)
          { status = dba_get_active_row (fpt, dba_field_label, &row, &pos);
          for (catt=dba_cent->fatt; catt; catt=catt->natt)
            if (catt->row == row) break; } } }

  if (!catt) return (1);

  dba_catt = catt;

  return (0);
}
