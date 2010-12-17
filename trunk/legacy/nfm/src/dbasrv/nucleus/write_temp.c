/* $Revision: 1.1 $ */
#if defined (__WIN32__) || defined (__WIN16__)
#include "io.h"
#endif

#include "dba.ext"
#include <errno.h>
#include "keys.def"
#define W_OK    2       /* Test for Write permission */
#define F_OK    0       /* Test for existence of File */

extern char *dba_errtxt, *dba_stext;
extern int dba_template_total;
extern unsigned long dba_st_size;

#if defined __SUN__ || defined sco
#define _access access
#endif

/* Function:	dba_write_template */
int dba_write_template (library, template, type, verify_library, 
  verify_template, templib)
char *library, *template;
int type, verify_library, verify_template;
struct dba_library **templib;
{
  char text[100], stext[100];
  int status, temp_type, exist_key=0;
  int (*func)();

  if (!library || strlen (library) == 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_LIB_NAME, NP, 0, NP, NP));
    return (99); }

  if (_access (library, F_OK))
    { status = dba_create_library (library, verify_library);
    if (status) return (status); }

  if (_access (library, W_OK))
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_FILE, "%s%d", 0, library, 
      errno));
    return (99); }

  dba_init_error ();

  while (template && strlen (template) 
      && template[strlen (template) - 1] == ' ')
    template[strlen (template) - 1] = 0;
  if (!template || strlen (template) == 0) 
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_TEMPLATE_NAME, "%s", 0, 
      template, NP));
    return (99); }
  if (strchr (template, ' '))
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_BLANK_IN_TEMPLATE, "%s", 0,
      template, NP));
    return (99); }

  dba_upper (template);

  *templib = dba_lib_open (library, "r+");
  if (!*templib) 
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_FILE, "%s%d", 0, library, 
      errno));
    return (99); }

  exist_key = dba_lookup_key (*templib, template, type, NP);
  if (exist_key)
    { if (verify_template)
      { status = dba_get_record (*templib, &dba_stext, &dba_st_size, NP, 0);
      if (strcmp (dba_stext, "Names") != 0) goto read_type;
      status = dba_get_record (*templib, &dba_stext, &dba_st_size, NP, 0);
    read_type:
      status = sscanf (dba_stext, "Template_Type %d", &temp_type);
      if (!status) temp_type = DATBAS;

      dba_template_type_from_number (text, temp_type);
      sprintf (stext, "%s template \"%s\"", text, template);

      switch (temp_type)
        { case DATBAS:  case USERDATA:  case ASCII:  case BINARY:
          temp_type = 0;  break;
        case UD_S:  case ASC_S:  case BIN_S:
          temp_type = ALL_STR;  break; }

      func = dba_inq_service (DBA_YES_NO);
      if (func) 
        { if (temp_type == type)
          status = (*func) (DBA_M_REPLACE_TEMPLATE, stext, 0);
        else
          status = (*func) (DBA_M_DELETE_TEMPLATE, stext, 1); }
      else
        { status = 1; } }
    else
      { status = 1; }

    if (!status || status == 99)
      { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_TEMPLATE_ABORT, 
        NP,0,NP,NP));
      goto write_error; }
    dba_delete_key (*templib, template, type, 1); }

  dba_insert_key (*templib, template, 0, type);

  if (exist_key != 1) dba_template_total = 0;
  (*templib)->rebuild = 1;

  return (0);

write_error:
  dba_lib_close (*templib);

  return (99);
}
