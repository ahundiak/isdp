#include <stdio.h>
#include "FI.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "gr.h"
#include "godef.h"
#include "griodef.h"
#include "go.h"
#include "grio.h"
#include "griomacros.h" 
#include "exmacros.h"
#include "EMCRfPlanPar.h"


void EMCRfPlanPar_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  IGRdouble  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  IGRlong         msg_loc, sts, event_size;
  IGRint          response;
  struct GRevent  event;
 
  sts = OM_S_SUCCESS;
  event_size = sizeof(struct GRevent);

  switch ( g_label )
  {
    /*********** GROUP PARALLEL_TO_PLANAR_FACE ***********/
    case EMS_g_BOTH_AXES:
    {
         break;
    }

    case EMS_g_ONE_AXIS:
    {
         break;
    }

    case EMS_g_ARBITRARY:
    {
         break;
    }


    /*********** GROUP PARALLEL_TO_REF_PLANE ***********/
    case EMS_g_ALIGN:
    {
         break;
    }

    case EMS_g_DEFINE_AXES:
    {
         break;
    }


    /*********** GROUP FIRST_AXIS ***********/


    case EMS_g_X_PRIMARY:
    {
         break;
    }

    case EMS_g_Y_PRIMARY:
    {
         break;
    }


    /*********** GROUP FI_CTRL_GROUP ***********/
    case FI_ACCEPT:
    {
         /* Erase the displayed form */
         FIf_erase ( fp );
	 FIg_set_state_off( fp, FI_ACCEPT );
	 response = EX_FORM_FINISHED;
         event.response = EX_FORM_FINISHED;
         sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event.event);
         if(!(sts & 1)) goto ret_end;
         break;
    }

  } /* END switch ( g_label ) */
ret_end:
    ;
} /* END EMCRfPlanPar_notification_routine() */

