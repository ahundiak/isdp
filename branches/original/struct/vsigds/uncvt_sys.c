#include "sysdata.h"
#include "idenvelope.h"

UNCVT_SYS( s )
  struct 	system_data	*s;
{
  unconvert_double( &s->version );
  unconvert_double( &s->cyl_len_cone );
  unconvert_double( &s->slicing_dist );
  unconvert_double( &s->delta_radius );
  unconvert_double( &s->cyl_len_ellips );
}

