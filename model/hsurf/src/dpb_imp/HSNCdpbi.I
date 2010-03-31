
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation HSNCdpb;

/*
DESCRIPTION
	Implementation of the HSNCdpb object for shaded NC Verification
*/

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"
#include "igewindef.h"
#include "hsncdef.h"

#include "hslight.h"
#include "hsurf.h"

%safe
#include "HSpr_dpb_imp.h"
%endsafe


/*--- super_construct -------------------------------------------------------*/

method super_construct()

/*
DESCRIPTION
 Load default instance data 
*/

	{
	me->display_mode = HSNC_SIMULATION;
	me->shading_style = HSNC_SMOOTH_SHADED;
	me->simulation_speed = HSNC_DEFAULT_SIM_SPEED;

	return( OM_S_SUCCESS );
	}


/*--- get_verification_parms -----------------------------------------------------------*/

method get_verification_parms(	IGRint *display_mode;
				IGRint *simulation_speed;
				IGRint *shading_style )

/*
DESCRIPTION
	Get the requested verification parameters from the instance data.
*/

	{
	if (display_mode) *display_mode = me->display_mode;
	if (simulation_speed) *simulation_speed = me->simulation_speed;
	if (shading_style) *shading_style = me->shading_style;
	return(OM_S_SUCCESS);
	}


/*--- put_verification_parms -----------------------------------------------------------*/

method put_verification_parms(	IGRint display_mode;
				IGRint simulation_speed;
				IGRint shading_style  )

/*
DESCRIPTION
	Put the given verification parameters into the instance data.
*/

	{
	IGRboolean	out_of_range = FALSE;

	if (display_mode)
	   {
	   if ((display_mode == HSNC_SWVOL) ||
	       (display_mode == HSNC_SWVOL_TOOL) ||
	       (display_mode == HSNC_SIMULATION))
	      {
	      me->display_mode = display_mode;
	      }
	   else
	      {
	      out_of_range = TRUE;
	      }
	   }

	if (simulation_speed)
	   {
	   if ((simulation_speed >= HSNC_MIN_SIM_SPEED) &&
	       (simulation_speed <= HSNC_MAX_SIM_SPEED))
	      {
	      me->simulation_speed = simulation_speed;
	      }
	   else
	      {
	      out_of_range = TRUE;
	      }
	   }

	if (shading_style)
	   {
	   if ((shading_style == HSNC_SMOOTH_SHADED) ||
	       (shading_style == HSNC_CONSTANT_SHADED))
	      {
	      me->shading_style = shading_style;
	      }
	   else
	      {
	      out_of_range = TRUE;
	      }
	   }

	return((out_of_range) ? (HSNC_FAILURE) : (HSNC_SUCCESS));
	}


/* ################## FUNCTIONS USED TO ACCESS DPB DATA ################## */

/* Functions return HSNC_SUCCESS (0) if successful, HSNC_FAILURE (1) if a failure occurs */


/*--- HSNCget_dpb_super -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSNCget_dpb_super( OM_S_OBJID *super_id,
				   OMuword *super_os )
#else
	void HSNCget_dpb_super( super_id, super_os )

	OM_S_OBJID	*super_id;
	OMuword		*super_os;
#endif

	{
	OM_S_OBJID	temp_mod_id;
	OMuword		temp_mod_os;

	ex$get_cur_mod( osnum = &temp_mod_os, id = &temp_mod_id );

	ex$get_super( mod_id      = temp_mod_id,
	              mod_osnum   = temp_mod_os,
	              super_name  = "HSNCdpb",
	              super_class = "HSNCdpb",
	              super_id    = super_id,
	              super_osnum = super_os,
	              create      = 1 );
	}  /* HSget_dpb_super */


/*--- HSNCget_verification_parms -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSNCget_verification_parms( IGRint *display_mode,
					 IGRint *simulation_speed,
					 IGRint *shading_style )
#else
	void HSNCget_verification_parms( display_mode, simulation_speed, shading_style )

	IGRint	*display_mode;
	IGRint	*simulation_speed;
	IGRint	*shading_style;
#endif

/*
DESCRIPTION
	This function reads the requested verification parameters
	from the current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	HSNCget_dpb_super( &super_id, &super_os );

	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message HSNCdpb.get_verification_parms(
						display_mode,
						simulation_speed,
						shading_style ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );
	}  /* HSNCget_verification_parms */


/*--- HSNCput_verification_parms -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSNCput_verification_parms( IGRint display_mode,
					IGRint simulation_speed,
					IGRint shading_style )
#else
	int HSNCput_verification_parms( display_mode, simulation_speed, shading_style )

	IGRint	display_mode;
	IGRint	simulation_speed;
	IGRint	shading_style;
#endif

/*
DESCRIPTION
	This function modifies the given verification parameters
	in the current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	HSNCget_dpb_super( &super_id, &super_os );

	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message HSNCdpb.put_verification_parms(
						display_mode,
						simulation_speed,
						shading_style ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( sts );
	}  /* HSNCput_verification_parms */


end implementation HSNCdpb;

