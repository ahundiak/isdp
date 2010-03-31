
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#include <stdio.h>

#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "msdef.h"

#include "exmacros.h"

#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "godef.h"
#include "go.h"

#include "DIdef.h"
#include "DEso.h"
#include "DEsomacros.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "VEsodef.h"

/* prototype files */
#include "VEpr_utilimp.h"

#include "DEmac.h"

static struct GRid win_grid;

from DEso import DEinit, DEget_size, DEchange_size;

/*--- VEcreate_soo -------------------------------------------------------*/

#if defined(__STDC__)
VEcreate_soo( long       *msg,
	      OM_S_OBJID *p_objid,
	      OMuword    osnum,
	      int        num_surfaces,
	      int        num_curves,
	      int        resolution )
#else
VEcreate_soo( msg, p_objid, osnum, num_surfaces, num_curves, resolution )

	long       *msg;
	OM_S_OBJID *p_objid;
	OMuword    osnum;
	int        num_surfaces;
	int        num_curves;
	int        resolution;
#endif

/*
NAME
	VEcreate_soo

DESCRIPTION
	This function will create, if necessary, and possibly resize the SO
	hash table object for a given object space.

PARAMETERS
	msg (OUT) - status return
	p_objid (OUT) - object id of the SO object create, can be NULL
	osnum (IN) - the object space number for the SO
	num_surfaces (IN) - number of surfaces that will have SOs applied
	num_curves (IN) - number of curves that will have SOs applied
	resoultion (IN) - resoultion of the VHL process that is applying
	                  the SOs

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS

HISTORY
	xx/xx/91    Unknown Programmer
	   Creation Date
	03/02/92    S.P. Rogers
	   Changed to call de$create_soo() and added prologue comment
*/

	{
	OMuword mod_osnum;
	GRobjid soo = NULL_OBJID, mod_id;
	double  multiplier;
	int     cur_hash_size, hash_size, resize_hash_table;

	/* get the DEso object for this object space */
	de$create_soo( msg = msg, osnum = osnum, p_objid = &soo );

	resize_hash_table = ( (num_surfaces != -1) || (num_curves != -1) );

	if ( resize_hash_table )
	   {
	   switch ( resolution )
	      {
	      case VESO_HIGH_RES:
	         multiplier = 2.8;
	         break;
	      case VESO_MED_RES:
	         multiplier = 4.8;
	         break;
	      default:  /* low resolution */
	         multiplier = 3.8;
	         break;
	      }

	   /* the 128 is an assumption about the number of manual SOs already in hash table, */
	   /* multiplier is the average number of SOs per element and the 0.6 allows for a   */
	   /* "fullness" factor of 60% in the hash table                                     */
	   hash_size = (128 + (multiplier * (num_curves + num_surfaces))) / 0.6;
	   }
	else
	   hash_size = -1;

	if ( resize_hash_table )
	   {
	   ex$get_cur_mod ( id = &mod_id, osnum = &mod_osnum );

	   om$send ( msg = message DEso.DEget_size( msg, &cur_hash_size ),
	             targetid = soo,
	             targetos = mod_osnum,
	             senderid = NULL_OBJID );

	   if ( hash_size > cur_hash_size )
	      {
	      om$send ( msg = message DEso.DEchange_size( msg, hash_size ),
	                targetid = soo,
	                targetos = mod_osnum,
	                senderid = NULL_OBJID );
	      }
	   }

	if ( (*msg == MSSUCC) && (p_objid) )
	   *p_objid = soo;

	return OM_S_SUCCESS;
	}  /* VEcreate_soo */

/*--- VEsetup_soo_view --------------------------------------------*/

#if defined(__STDC__)
void VEsetup_soo_view( OM_S_OBJID viewid,
		       OMuword viewos )
#else
void VEsetup_soo_view( viewid, viewos )

	OM_S_OBJID viewid;
	OMuword viewos;
#endif

/*
NAME
	VEsetup_soo_view

DESCRIPTION
	This function is an auxiliary function which sets up variables
	which the other function will need. Thus, it must be called, for a
	given view, prior to any calls to VEplace_multiple_soos().

PARAMETERS
	viewid (IN) - object id of window that will have SOs placed
	viewos (IN) - object space number of window that will have SOs placed

GLOBALS USED
	win_grid (static)

HISTORY
	xx/xx/91    Unknown Programmer
	   Creation Date
	03/02/92    S.P. Rogers
	   Added prologue comment
*/

	{
	win_grid.osnum = viewos;
	win_grid.objid = viewid;
	} /* VEsetup_soo_view */


/*--- VEplace_multiple_soos -------------------------------------------*/

void VEplace_multiple_soos( number_of_boundaries, u_parms, span_type,
	                    continuous, curve_objid, curve_env )

	int number_of_boundaries;
	double *u_parms;
	short span_type[], continuous;
	OM_S_OBJID curve_objid;
	struct GRmd_env *curve_env;

/*
NAME
	VEplace_multiple_soos

DESCRIPTION
	This fuunction places hidden/invisible symbology overrides on 
	a curve.

PARAMETERS
	number_of_boundaries (IN) - number of SOs to place
	u_parms (IN) - array of U parameters for the SOs
	span_type (IN) - array of types for the SOs
	continuous (IN) - flag indicating whether SOs are continuous
	curve_objid (IN) - object id of curve to get the SOs
	curve_env (IN) - module environment of the curve

GLOBALS USED
	win_grid (static)

HISTORY
	xx/xx/91    Unknown Programmer
	   Creation Date
	03/02/92    S.P. Rogers
	   Added prologue comment
*/

	{
	struct GRid       go_grid;
	struct IGRdisplay symb;
	int               soo_type;
	int               i, j, incr;
	long              msg;

	symb.color = 2;
	symb.weight = 0;
	symb.style = 2;

	go_grid.osnum = curve_env->md_id.osnum;
	go_grid.objid = curve_objid;

	if ( continuous )
	   {
	   incr = 1;
	   }
	else
	   {
	   incr = 2;
	   number_of_boundaries *= 2;
	   }

	for (i = 0, j = 0; i < number_of_boundaries; i += incr, j++ )
	   {
	   switch ( span_type[j] )
	      {
	      case HE_HIDDEN_SPAN:
	         soo_type = DE_HIDDEN;
	         break;
	      case HE_INVISIBLE_SPAN:
	         soo_type = DE_INVIS;
	         break;
	      default:
	         continue;  /* don't place visible SOs */
	      }  /* end: switch */

	   de$place_override( msg = &msg, type = soo_type, symbology = &symb,
	                      u1 = u_parms[i], u2 = u_parms[i+1], go_grid = &go_grid,
	                      window_grid = &win_grid, module = curve_env );

	   }  /* end: for */

	}  /* VEplace_multiple_soos */

end implementation Root;
