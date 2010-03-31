
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "EMSopt.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "ve_timing.h"
#include "veerr.h"
#include "vedef.h"
#include "ve.h"
   
from EMSloopset import EMpt_location;

/* prototype files */
#include "VEpr_utilimp.h"

#if TIMING
extern IGRdouble  VEtime_ptloc;
extern IGRint     VEcount_ptloc;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif


/*---- VEin_solid ------------------------------------------------------------*/

IGRboolean VEin_solid( element, uval, vval )

/*
NAME
	VEin_solid

DESCRIPTION
	Find out the solid/hole status of a uv point on a surface.	

PARAMETERS
	element (IN) - the element whose UV solid/hole status is to be checked
	uval (IN) - the u parameter of the UV point to test
	vval (IN) - the v parameter of the UV point to test

GLOBALS USED
	none

HISTORY
	06/25/87    S.P. Rogers
	   Creation Date
*/

	struct VEelement_header *element;
	IGRdouble               uval;
	IGRdouble               vval;

	{
	IGRboolean            in_solid;
	IGRlong               sts;
	IGRlong               msg;
	IGRdouble             point[2];
	struct EMSptloc_info  loc;
	struct EMSpartolbasis partol;


	point[0] = uval;
	point[1] = vval;

	loc.options = EMS_PTLOC_BOXCHECK;

	partol.tol      = 0.000001;
	partol.is_valid = TRUE;
	
	/* send EMpt_location to the loopset for this surface, */
	/* via the surface itself                              */

#if TIMING
	times( &VEs_time );
#endif
		    
	sts = om$send( msg      = message EMSloopset.EMpt_location( &msg,
		       	                                            point,
		       	                                            &loc,
		       	                                            &partol ),
		       senderid = NULL_OBJID,
		       targetid = element->loopset_id,
	               targetos = element->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_ptloc++;
	VEtime_ptloc += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   OM_ERRCHK( sts, "VEin_solid: EMSloopset.EMpt_location send failed" );
	   MSG_ERRCHK( msg, "VEin_solid: EMSloopset.EMpt_location failed" );
	   
	switch( loc.location )
	   {
	   case EMS_L_ONEDGE : case EMS_L_ONVRTX : case EMS_L_INAREA : 
	
	      in_solid = TRUE;
	      break;

	   case EMS_L_INHOLE : case EMS_L_UNKNWN :
	   
	      in_solid = FALSE;
	      break;

	   default :

	      in_solid = FALSE;
	      break;
	   }

	return( in_solid );
	}   /* VEin_solid */
	

end implementation Root;
