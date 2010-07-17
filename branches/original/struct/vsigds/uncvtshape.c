#include <stdio.h>
#include "sysdata.h"
#include "idenvelope.h"


void UNCVT_SHAPE( s )
  basic_shape_data	*s;
{
  
  short		i;

  switch ( s->su.size[1] )			/* size[1] = shape type   */
    {
    case 1 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.cylinder.cy_pri[i] );
        unconvert_double( &s->geom.cylinder.cy_sec[i] );
        }
      return;
    case 2 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.conic.co_pri[i] );
        unconvert_double( &s->geom.conic.co_sec[i] );
        }
      return;
    case 3 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.toroid.to_pri[i] );
        unconvert_double( &s->geom.toroid.to_sec[i] );
        }
      unconvert_double( &s->geom.toroid.to_sweep_angle );
      return;
    case 4 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.projected_shape.ps_pri[i] );
        unconvert_double( &s->geom.projected_shape.ps_sec[i] );
        }
      return;
    case 5 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.semi_ellipsoid.el_pri[i] );
        unconvert_double( &s->geom.semi_ellipsoid.el_sec[i] );
        }
      return;
    case 6 :
      for ( i = 0 ; i <= 2 ; i ++ )
        {
        unconvert_double( &s->geom.revolved_shape.rs_pri[i] );
        unconvert_double( &s->geom.revolved_shape.rs_sec[i] );
        }
      unconvert_double( &s->geom.revolved_shape.rs_sweep_angle );
      return;
    default :
      return;
    }
}

