#include <stdio.h>
#include "sysdata.h"
#include "idenvelope.h"

#include "unct_double.h"

UNCVT_COMP( s )
  component_data	*s;
{
  unconvert_double( &s->rs.r_d[0] );		/* insulation */
}

