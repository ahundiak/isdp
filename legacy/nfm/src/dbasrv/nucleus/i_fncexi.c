/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern int dba_graphic_mode;

/* Function:	dba_inq_fence_exists */
int dba_inq_fence_exists ()
{
  int (*func)();

  switch (dba_graphic_mode)
    { case 1:  case 3:
      func = dba_inq_service (DBA_USTN_FENCE_EXISTS);
      if (func) return ((*func)());
    case 2:  case 4:
      func = dba_inq_service (DBA_RASTER_FENCE_EXISTS);
      if (func) return ((*func)()); }

  return (0);
}
