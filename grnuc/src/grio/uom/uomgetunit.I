class implementation UOMsuper;


#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

method get_distance_units( char units[] )
{
  int num;
  int ii;

  num = om$dimension_of( varray = me->type );
  
  for( ii = 0 ; ii < num ; ii++ )
  {
    if( ! strcmp( me->type[ii].name, "distance" ))
    {
      strcpy( units, me->type[ii].defalias[0] );
      break;
    }
  }  
  return( 1 );
}
end implementation UOMsuper;
