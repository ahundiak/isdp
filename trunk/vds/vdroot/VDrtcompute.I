/* $Id: VDrtcompute.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdroot/VDrtcompute.I
 *
 * Description:
 *
 *      This file implements the methods to compute/recompute a object.
 *
 * Dependencies:
 *      VDSroot.S
 *
 * History:
 *      11/02/95        A. Zuurhout      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

extern	IGRboolean	ASbroadcast_in_progress;

/*+me
 -------------------------------------------------------------------------
  Public Message 
	VDcompute

  Abstract
	Compute the object.

  Status/Return Code
	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method VDcompute(	IGRlong			*msg;
			IGRint			*type ){

IGRlong			sts;		/* OMreturn code	*/
struct GRid 		myGRid ;
IGRint			wtBatch;
IGRboolean		saveBroad ;


	SetProc( VDcompute ); Begin

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	/*
	 * Get the compute Type is givem.
	 */
	if( type ){
		sts =
		nd$wait_batch(	type       = GR_GEOM_POSTED,
				l_object   = &myGRid,
				l_obj_info = type,
				nb_obj     = 1 );
	}
	else {
		sts =
		nd$wait_batch(	type       = GR_GEOM_POSTED,
				l_object   = &myGRid,
				l_obj_info = NULL,
				nb_obj     = 1 );
	}

	nd$mod_batch(	request    = ND_INQ,
			p_ret_mode = &wtBatch);
     
	saveBroad		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress = FALSE ;

/**
	if( wtBatch != ND_DEFER ) 
		nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
 **/

	ASbroadcast_in_progress = saveBroad ;

	End;
	*msg = MSSUCC;
	return OM_S_SUCCESS;

wrapup:
	End;
	*msg = MSFAIL;
	return OM_E_ABORT;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot;

