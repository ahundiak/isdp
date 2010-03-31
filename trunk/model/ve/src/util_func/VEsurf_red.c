
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "ve_timing.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#include "bsfreesf.h"
#include "bsdta_rdusf.h"

#if TIMING
extern struct tms VEs_time;
extern struct tms VEe_time;
extern IGRdouble  VEtime_datred;
extern IGRint     VEcount_datred;
#endif


/* External Global Variables */
extern struct VEexecution_parms VEexec_parms;


/*---- VEsurface_reduction --------------------------------------------------------*/

void VEsurface_reduction( element )

	struct VEelement_header *element;
	
/*
NAME
	VEsurface_reduction

DESCRIPTION
	This procedure checks if the poles of element are greater than or
	equal to VEexec_parms.VEsurf_threshold in either the u or v dimension
	(or both). If so, then the math routine BSdta_rdusf(), which performs
	surface data reduction in the required dimensions, is called.
	
PARAMETERS
	element (IN) - the element to be reduced

GLOBALS USED
	VEexec_parms

HISTORY
	10/03/88    P.R. Slubicki
	   Creation Date
*/

  {
  BSrc   rc;
  IGRint option = 0;
  IGRint tanl = 0,
         tanr = 0,
         tant = 0,
         tanb = 0;

  struct IGRbsp_surface *surf, *reduced_surf;

  if (VEexec_parms.VEdata_reduction)
    {

    VEupdate_heartbeat();

    /* Check if it is necessary to apply data reduction to the
     * surface (i.e., if either the u or v dimension is greater
     * than or equal to VEexec_parms.VEsurf_threshold). If so, then call
     * BSdta_rdusf().
     */
    surf = element->geom.gmsurf->bspsf;
 
    if (surf->u_num_poles >= VEexec_parms.VEsurf_threshold
     || surf->v_num_poles >= VEexec_parms.VEsurf_threshold)
      {
      /* Option: 0 if u reduction; 1 if v; 2 if both. Option has
       * been initialized to 0 in the declaration.
       */
      if (surf->v_num_poles >= VEexec_parms.VEsurf_threshold)
        {
        option++;
        if (surf->u_num_poles >= VEexec_parms.VEsurf_threshold)
          option++;
        }

#if TIMING
      times(&VEs_time);
#endif

      BSdta_rdusf(surf,
                  option,
                  tanl, tanr, tant, tanb,
                  FALSE,
                  NULL, NULL, NULL, NULL, NULL, NULL,
                  &reduced_surf,
                  &rc);

#if TIMING
      times(&VEe_time);
      VEcount_datred++;
      VEtime_datred += (((VEe_time.tms_utime + VEe_time.tms_stime)
                        - (VEs_time.tms_utime + VEs_time.tms_stime))
                        / 60.0);
#endif

      if (rc == BSSUCC)
        {
        BSfreesf (&rc,
                  surf);
               
        element->geom.gmsurf->bspsf = reduced_surf;
        }
               
      } /* end if (surf->u_num_poles || surf->v_num_poles > VEexec_parms.VEsurf_threshold) */
             
    } /* end if (VEexec_parms.VEdata_reduction) */

  } /* VEsurface_reduction */
