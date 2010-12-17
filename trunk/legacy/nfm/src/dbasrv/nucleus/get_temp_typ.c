/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

extern int dba_first_turbo;

/* Function:	dba_get_template_type */
int dba_get_template_type (lib_ptr, block, s_byte, type)
struct dba_library *lib_ptr;
long block;
int s_byte, *type;
{
  int status;
  long bytes;
  static char *stext;
  static unsigned long st_size;

  if (st_size == 0) 
    { st_size = 100;  stext = dba_dmalloc (st_size, DM_STATIC); }

  bytes = (block - 1) * 512 + s_byte + 18;
  if (s_byte >= 494) bytes += 6;
  status = fseek (lib_ptr->ptr, bytes, 0);

  dba_first_turbo = 1;
  dba_get_record (NP,NP,NP,NP,1);

  dba_get_record (lib_ptr, &stext, &st_size, NP, 0);
  if (strcmp (stext, "Names") == 0)
    dba_get_record (lib_ptr, &stext, &st_size, NP, 0);
  status = sscanf (stext, "Template_Type %d", type);
  if (!status) *type = DATBAS;

  dba_first_turbo = 0;

  return (0);
}
