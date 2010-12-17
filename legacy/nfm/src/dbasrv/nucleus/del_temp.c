/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>
#include "keys.def"

#define W_OK    2       /* Test for Write permission */

#if defined __SUN__ || defined sco
#define _access access
#endif

extern char *dba_errtxt, *dba_lib;
extern int dba_template_total;

/* Function:	dba_delete_template 

Description: 	delete a template from library

Author:         Brian Potter

Revisions:
	2-14-94  -- (TAT) Added "lib" argument.
*/
int dba_delete_template (lib, template, type, verify)
char *lib, *template;
int type, verify;
{
  char ctype[10], text[50];
  int status;
  int (*func)();
  struct dba_library *templib;

  if (!lib)
    lib = dba_lib;

  if (_access (lib, W_OK))
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_FILE, "%s%d", 0, lib, 
      errno));
    return (99); }

  if (verify)
    { dba_template_type_from_number (ctype, type);
    sprintf (text, "%s template \"%s\"", ctype, template);
    func = dba_inq_service (DBA_YES_NO);
    if (func)
      status = (*func) (DBA_M_DELETE_TEMPLATE, text, 1);
    else
      status = 0;
    if (!status) return (1);
    if (status == 99) return (99); }

  templib = dba_lib_open (lib, "r+");
  if (!templib)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_FILE, "%s%d", 0, lib, 
      errno));
    return (99); }
  status = dba_delete_key (templib, template, type, 1);
  dba_lib_close (templib);
  if (!status) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_TEMPLATE, "%s%s", 0,
      template, lib));
    return (99);
  }
  dba_template_total = 0;
  templib->rebuild = 1;

  return (0);
}
