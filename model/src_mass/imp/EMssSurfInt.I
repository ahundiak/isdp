/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>
#include "bsparameters.h"
#include "bserr.h"
#include "emsmass.h"
#include "wanginc.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define MASS_PROPS 0
#define SURF_PROPS 1
#define AREA_ONLY  2

method EMsurfintgrl(IGRlong               *msg;
                    struct GRmd_env       *my_env;
                    IGRboolean            new_tiler;
                    IGRvector             trans_vector;
		            struct IGRbsp_surface *surf;
                    IGRchar	              *char_surf_info;
                    IGRlong               option;
                    IGRdouble             *density;
                    IGRdouble             *out_int)
/*
Description
	This method receives surface geometry, and evaluates
	the surface integral contribution towards mass properties/area
	properties.
	
Return values
	EMS_S_Success if all's well
Notes

History
	gk	11/11/87	Design date
*/

{
  IGRlong		bsmsg, i, status;
  IGRdouble		tol, prop[NUMB_PROPS];
 extern  IGRboolean  BNsb_fct();
 extern  IGRboolean  BNsb_fsd();
  IGRboolean		flat_check, log_status;
  struct BNsf_data	*surf_data;
  struct GRid       my_GRid;


  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;
  
  ex$message(msgnumb = EMS_I_Processing, field = PROMPT_FIELD)

  BSEXTRACTPAR(&bsmsg, BSTOLCHRDHT, tol);
  flat_check = FALSE;

  log_status = BNsb_fct(&bsmsg, surf, &tol, &flat_check, &surf_data);
  if(NOT log_status)	/* screwed up */
   {
     fprintf(stderr, "EMssSurfint: Faceting error msg = %ld\n", bsmsg);
     status = OM_E_ABORT;
     *msg = EMS_F_Fail;
   }

/* Invoke integration scheme */

  for(i = 0; i < NUMB_PROPS; i ++)prop[i] = 0.0;

  ex$message(msgnumb = EMS_I_Integrating, field = PROMPT_FIELD)

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  if ((option == MASS_PROPS) && (new_tiler))
      EMfacetint(&bsmsg, my_env, trans_vector, surf, &my_GRid,
                 surf_data, option, density, prop);
  else
      MSfacetint(&bsmsg, surf_data, option, density, prop);

  ex$message(msgnumb = EMS_P_ClearPromptField)

  log_status = BNsb_fsd(&bsmsg, surf_data);
  if( NOT log_status)
   {
     fprintf(stderr, "EMssSurfInt: memory free msg = %ld\n", bsmsg);
     status = OM_E_ABORT;
     *msg = EMS_F_Fail;
   }

  for(i = 0; i < NUMB_PROPS; i ++)out_int[i] += prop[i];

  return(status);
}

end implementation EMSsubbs;

