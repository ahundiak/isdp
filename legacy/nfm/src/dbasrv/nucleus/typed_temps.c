/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dbadev.h"

extern char *dba_lib;
extern long dba_template_total;
extern struct dba_template *dba_template_list;

/* Function:	dba_get_typed_templates */
int dba_get_typed_templates (type, temp_ptr)
int type;
struct dba_template **temp_ptr;
{
  int status;
  static int count;
  static struct dba_template *ptr;

  if (!dba_template_total)
    { count = 0;
    if (dba_template_list) dba_dfree (dba_template_list);
    status = dba_list_library (dba_lib, DBA_ALL_TEMPLATES, 
      &dba_template_list, &dba_template_total);
    if (status) return (99);
    if (!dba_template_total) return (1); }

  if (count == 0) ptr = dba_template_list;

read_temp:
  if (count == dba_template_total) { count = 0;  return (1); }

  switch (type)
    { case 0:
      switch (ptr->type)
        { case DATBAS: case USERDATA: case BINARY: case ASCII:  break;
        default:  goto next_temp; }
      break;
    case ALL_STR:
      switch (ptr->type)
        { case UD_S: case BIN_S: case ASC_S:  break;
        default:  goto next_temp; }
      break;
    default:
      if (ptr->type != type) goto next_temp; 
      break; }

  *temp_ptr = ptr;
  ++count;
  ++ptr;
  return (0);

next_temp:
  ++count;
  ++ptr;
  goto read_temp;
}
