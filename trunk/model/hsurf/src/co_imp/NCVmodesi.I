class implementation NCVmodes;



#define SIMULATION      5001
#define INVALID_CHOICE  6001
#define INVALID_VALUE   6002
#define FINISHED        6003

#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"



#define _start 0
#define _simulation_speed 1
#define _shading_style 2

method set_display_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int   i;


   sscanf(me->event1.event.keyin, "%d", &i);

   switch (i)
   {
      case (1):   /* Swept Volume */
         hsnc$put_verification_parameters( display_mode = HSNC_SWVOL );
         break;

      case (2):   /* Swept Volume with Wireframe Tool */
         hsnc$put_verification_parameters( display_mode = HSNC_SWVOL_TOOL );
         break;

      case (0):   /* Default */
      case (3):   /* Simulation */
         hsnc$put_verification_parameters( display_mode = HSNC_SIMULATION );
         *sts = SIMULATION;
         break;

      default:
         ex$message( msgnumb = HS_E_NCVInvDispMode );
         *sts = INVALID_CHOICE;
         break;
   }
quit:
  return OM_S_SUCCESS;
}

method set_simulation_speed ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int   simulation_speed;


   sscanf(me->event1.event.keyin, "%d", &simulation_speed);

   if (simulation_speed == 0)
   {
      simulation_speed = HSNC_DEFAULT_SIM_SPEED;
   }

   if (hsnc$put_verification_parameters( simulation_speed = simulation_speed )
                             != HSNC_SUCCESS)
   {
      ex$message( msgnumb = HS_E_NCVInvSimSpd );
      *sts = INVALID_VALUE;
   }
quit:
  return OM_S_SUCCESS;
}

method set_shading_style ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int   i;

   sscanf(me->event1.event.keyin, "%d", &i);

   switch (i)
   {
      case (0):   /* Default */
      case (1):   /* Constant */
         hsnc$put_verification_parameters(
                                         shading_style = HSNC_CONSTANT_SHADED );
         *sts = FINISHED;
         break;

      case (2):   /* Smooth */
         hsnc$put_verification_parameters( shading_style = HSNC_SMOOTH_SHADED );
         *sts = FINISHED;
         break;

      default:
         ex$message( msgnumb = HS_E_NCVInvShdSty );
         *sts = INVALID_CHOICE;
         break;
   }
quit:
  return OM_S_SUCCESS;
}

end implementation NCVmodes;
