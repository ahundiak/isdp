/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;

/* Function:	dba_get_attnam 

Description: 	returns the attribute name of the specified attribute number

Author: 	Brian Potter
*/
int dba_get_attnam (entnam, attnum, text_ptr)
char *entnam, *text_ptr;
int attnum;
{
  struct dba_ent *tent;
  struct dba_att *tatt;

  dba_set_ent_ptr (0, 0, entnam, &tent, 0, 0);
  if (tent)
    { for (tatt=tent->fatt; tatt; tatt=tatt->natt)
      if (strcmp (tatt->entnam, entnam) == 0 && tatt->attnum == attnum)
        { strcpy (text_ptr, tatt->attnam);  return (0); }

    sprintf (text_ptr, "%d", attnum);
    dba_append_error (0, dba_get_msg (DBA_E_NO_COLUMN, "%s%s", 0, entnam,
      text_ptr));
    return (99); }

  dba_append_error (0, dba_get_msg (DBA_E_NO_ENTNAM, "%s", 0, entnam, NP));
  sprintf (text_ptr, "%d", attnum);
  return (99);
}
