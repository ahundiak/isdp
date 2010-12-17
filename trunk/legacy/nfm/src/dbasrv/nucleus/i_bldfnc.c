/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern int dba_graphic_mode;

/* Function:	dba_inq_build_fence */
int dba_inq_build_fence (create_flag, got_where, ent_ptr, s1_ptr, s1_size, 
  fpt, label, row)
int create_flag, *got_where, label, row;
struct dba_ent *ent_ptr;
char **s1_ptr;
unsigned long *s1_size;
Form fpt;
{
  int (*func)();

  switch (dba_graphic_mode) {
    case 1:  case 3:
      func = dba_inq_service (DBA_USTN_BUILD_FENCE);
      if (func)
        return ((*func) (create_flag, got_where, ent_ptr, s1_ptr, s1_size, 
          fpt, label, row));
    case 2:  case 4:
      func = dba_inq_service (DBA_RASTER_BUILD_FENCE);
      if (func)
        return ((*func) (got_where, ent_ptr, s1_ptr, s1_size, 
          fpt, label, row));
  }
  return (0);
}
