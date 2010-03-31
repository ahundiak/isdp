class implementation HSactive;



#define CHECK_RETURN_CODES 1

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "stdio.h"

#include "OMerrordef.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsmsg.h"

#include "hsmacdef.h"
#include "hsmacros.h"


#define _start 0

method get_dpb_props ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	*sts = OM_S_SUCCESS;

	hs$get_shading_accuracy( accuracy = &me->accuracy );

	quit:
  return OM_S_SUCCESS;
}

method display_current_value ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	/* display the current shading accuracy */
	ex$message( msgnumb = HS_I_AccIs, type = "%d", var = `me->accuracy` );

	return( OM_S_SUCCESS );

	quit:
  return OM_S_SUCCESS;
}

method set_dpb_props ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	*sts = OM_S_SUCCESS;

	hs$set_shading_accuracy( accuracy = me->accuracy );

	quit:
  return OM_S_SUCCESS;
}

method process_accuracy_keyin ( long * sts )
{
  int		  status = OM_S_SUCCESS;

        IGRlong accuracy;

	accuracy = (IGRlong) me->event1.event.value;
	if ( (accuracy >= 1) && (accuracy <= 15) )
	   {
	   /* user entered a valid accuracy */
	   *sts = OM_S_SUCCESS;
	   me->accuracy = accuracy;
	   }
	else
	   {
	   /* Shading Accuracy out of valid range */
	   *sts = OM_W_WARNING;
	   ex$message( msgnumb = HS_E_InvAcc );
	   sleep( 3 );
	   }

	quit:
  return OM_S_SUCCESS;
}

end implementation HSactive;
