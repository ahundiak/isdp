/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;
extern int dba_append_msg;

/* Function:	dba_append_error */
dba_append_error (add, msg_text)
int add;
char *msg_text;
{
  if (dba_append_msg || add)
    { if (dba_append_msg == 1)
      { dba_add_error (dba_errtxt);  ++dba_append_msg; }
    if (msg_text)
      { sprintf (dba_errtxt, "  %s", msg_text);
      dba_add_error (dba_errtxt); } }
  else
    strcpy (dba_errtxt, msg_text);

  return (0);
}
