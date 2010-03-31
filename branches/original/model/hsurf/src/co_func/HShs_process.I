
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1


#include <stdio.h>
#include <FI.h>
#include "wl.h"

/*  KLUDGE: DEglob references this constant  */
#ifndef  ENV5  
#define MAX_WINDOW 40
#endif

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "growner.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "grgs.h"
#include "grgsmacros.h"

#include "bs.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsvhl.h"
#include "HSlvhl.h" 
#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hswinmacros.h"
#include "hsmessage.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "hstiler.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSpvhl.h"
#include "godef.h"
#include "HSplot.h"


%safe
#include "HSpr_co_func.h"

/*------------------------
 *  for function
 *     HSset_window_object_info
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------
 *  for functions
 *     HSget_components
 *     HSremove_VEso_from_edge
 */
 
#include "HSpr_lvhl.h"

/*-----------------------------------*/


%endsafe

from DEso		import DEget;
from GRvg		import GRgetsymb;

/*
 *  Prototype declaration for static functions
 */


%safe

#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HShs_process.I */
static void HSdump_hidden_symbology __((GRobjid msc_id, 
				     GRspacenum msc_os, 
				       IGRshort *matrix_type, 
				      IGRmatrix matrix));

#if defined(__cplusplus)
}
#endif


#undef __



static struct GRid	window;
static IGRdouble	rotation[16];
static IGRboolean	delete_ve_soo = TRUE;
static struct GRmd_env 	DDDmaster_env;
%endsafe

/*extern IGRboolean HSremove_VEso_on_edge();*/
	
/*---HSinit_delete_detail_display----------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSinit_delete_detail_display( struct GRid *selected_window,
						IGRint mode,
					     IGRdouble *view_rotation )
#else
	void HSinit_delete_detail_display( selected_window, mode, view_rotation )

	struct GRid	*selected_window;
	IGRint		mode;
	IGRdouble	*view_rotation;
#endif

/*
NAME
	HSinit_delete_detail_display

DESCRIPTION
	This function initializes the information necessary to perform
	Delete Detail Display on elements.  It must be called before
	any elements are processed.

PARAMETERS
	selected_window (IN) - the window that will have the detail display
	                       deleted
	mode (IN) - mode flag, either DELETE or DUMP (debug only)
	view_rotation (IN) - the rotation matrix for the window

GLOBALS USED
	DDDmaster_env (static)
	delete_ve_soo (static)
	window (static)
	rotation (static)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/17/92    S.P. Rogers
	   Added prologue comment
*/

	{
	gr$get_module_env( buffer = &DDDmaster_env );

	window.objid = selected_window->objid;
	window.osnum = selected_window->osnum;

	delete_ve_soo = (mode == 0);
	
	HSset_window_object_info( selected_window );
	
	if( view_rotation == NULL )
		{
		rotation[0]  = 1.0;
		rotation[1]  = 0.0;
		rotation[2]  = 0.0;
		rotation[3]  = 0.0;
		rotation[4]  = 0.0;
		rotation[5]  = 1.0;
		rotation[6]  = 0.0;
		rotation[7]  = 0.0;
		rotation[8]  = 0.0;
		rotation[9]  = 0.0;
		rotation[10] = 1.0;
		rotation[11] = 0.0;
		rotation[12] = 0.0;
		rotation[13] = 0.0;
		rotation[14] = 0.0;
		rotation[15] = 1.0;
		}
	else
		{
		memcpy( rotation, view_rotation, sizeof(double)*16 );
		}
		
	}  /* HSinit_delete_detail_display */


/*---HSprocess_soos_on_solid----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSprocess_soos_on_solid( struct GRid *elem,
					 IGRshort *matrix_type,
					IGRmatrix matrix,
				  struct GRmd_env *master_env,
					   IGRint complex )
#else
	void HSprocess_soos_on_solid( elem,
				      matrix_type,
				      matrix,
				      master_env,
				      complex )

	struct GRid	*elem;
	IGRshort	*matrix_type;
	IGRmatrix	matrix;
	struct GRmd_env	*master_env;
	IGRint		complex;
#endif

/*
NAME
	HSprocess_soos_on_solid

DESCRIPTION
	This function performs the delete detail display function
	on a solid, composite surface, or surface element.

PARAMETERS
	elem (IN) - GRid of element
	matrix_type (IN) - type of 'matrix'
	matrix (IN) - module environment matrix for 'elem'
	master_env (IN) - the module environment of the master file
	complex (IN) - if TRUE, 'elem' is a composite surface of solid

GLOBALS USED
	HSlvhl.md_env
	rotation (static)
	delete_ve_soo (static)
	
HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/17/92    S.P. Rogers
	   Added prologue comment and removed display logic
*/


	{
	IGRint			comp_count;
	IGRint			comps;
	struct GRid		*comp_ids;

	if( complex )
		{
		HSget_components( elem, master_env, &comp_count, &comp_ids );
	
		for( comps = 0; comps<comp_count; comps++ )
			{
			HSget_surface_edges( 
				NULL,
				comp_ids[comps].objid,
				comp_ids[comps].osnum,
				NULL,
				&HSlvhl.md_env.md_env,
				0, 0, 0, 0, 0, 0.0, NULL,
				rotation,
				delete_ve_soo ? HS_GET_EDGES_MODE_DELETE_VESO : HS_GET_EDGES_MODE_DUMP_SO,
				FALSE, NULL );
			}
		
		if( comp_ids ) free( (IGRchar *)comp_ids );
		}
	else
		{
		HSget_surface_edges( 
			NULL,
			elem->objid,
			elem->osnum,
			NULL,
			&HSlvhl.md_env.md_env,
			0, 0, 0, 0, 0, 0.0, NULL,
			rotation,
			delete_ve_soo ? HS_GET_EDGES_MODE_DELETE_VESO : HS_GET_EDGES_MODE_DUMP_SO,
			FALSE, NULL );
		}

	}  /* HSprocess_soo_on_solid */
	
	
/*---HSdump_hidden_symbology---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSdump_hidden_symbology( GRobjid msc_id,
					      GRspacenum msc_os,
					        IGRshort *matrix_type,
					       IGRmatrix matrix )
#else
	static void	HSdump_hidden_symbology( 
				msc_id, 
				msc_os,
				matrix_type,
				matrix )


	GRobjid		msc_id;
	GRspacenum	msc_os;
	IGRshort	*matrix_type;
	IGRmatrix	matrix;
#endif

/*
NAME
	HSdump_hidden_symbology (static)

KEYWORD
	debug

DESCRIPTION
	This function dumps the SOs of an edge to stderr.

PARAMETERS
	msc_id (IN) - the object id of the edge
	msc_os (IN) - the object space number of the edge
	matrix_type (IN) - type of 'matrix'
	matrix (IN) - module environment matrix for 'elem'

GLOBALS USED
	window (static)
	DEsos

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/17/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRint                  *p_types;
	IGRdouble		*p_parms;
	struct IGRdisplay	*p_attr;
	struct GRsymbology      symbology;
	IGRint			p_count, status, i, j;
	IGRlong			msg;
	

	if ( ! DEsos )
		return;

	status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
		     senderid = NULL_OBJID,
		     targetid = msc_id,
		     targetos = msc_os );

	status = om$send( msg = message DEso.DEget( 
						&msg,
						&p_types,
						&p_parms,
						&p_count,
						&p_attr,
						&symbology.display_attr,
						msc_id,
						window.objid,
						matrix_type,
						matrix,
						0, TRUE ),  /* all soos */
		     senderid = NULL_OBJID,
		     targetid = DEsos[msc_os],
		     targetos = msc_os );

	if( (status & 1) && p_count > 0 )
		{
		fprintf( stderr, "Soo's: p_count: %d\n", p_count );
		for( i=0, j=0; i<p_count; i++, j+=2 )
			fprintf( stderr, "   0x%X %f %f %d %d %d\n",
				p_types[i],
				p_parms[j], p_parms[j+1],
				p_attr[i].color,
				p_attr[i].weight,
				p_attr[i].style );
		}

	}  /* HSdump_hidden_symbology */


/*---HSprocess_soos_on_surface_edge----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSprocess_soos_on_surface_edge( struct GRid *msc_GRid,
						   IGRshort *matrix_type,
						  IGRmatrix matrix )
#else
	void	HSprocess_soos_on_surface_edge( msc_GRid,
		                                matrix_type,
		                                matrix )


	struct GRid *msc_GRid;
	IGRshort    *matrix_type;
	IGRmatrix   matrix;
#endif

/*
NAME
	HSprocess_soos_on_surface_edge

DESCRIPTION
	This function processes the SOs on a surface edge for
	delete detail display.

PARAMETERS
	msc_GRid (IN) - the GRid of the surface edge
	matrix_type (IN) - the type of 'matrix'
	matrix (IN) - the environment matrix of the surface edge

GLOBALS USED
	delete_ve_soo (static)
	window (static)
	HSlvhl.md_env
	DDDmaster_env (static)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/17/92    S.P. Rogers
	   Added prologue comment and removed display logic
*/

	{
	if ( delete_ve_soo )
		{
		HSremove_VEso_on_edge( msc_GRid->objid,
		                       msc_GRid->osnum,
		                       window.objid,
	                               window.osnum,
	                               &HSlvhl.md_env,
	                               &DDDmaster_env,
	                               -1.0, -1.0,   /* remove from entire range */
	                               FALSE, /* automatic SOs only */ 
				       TRUE  /* re-display the edge */ );

		}
	else
		{
		HSdump_hidden_symbology( msc_GRid->objid, msc_GRid->osnum, matrix_type, matrix );
		}

	}  /* HSprocess_soos_on_surface_edge */


/*---HSprocess_soos_on_curve----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSprocess_soos_on_curve( struct GRid *elem,
					 IGRshort *matrix_type,
					IGRmatrix matrix )
#else
	void HSprocess_soos_on_curve( 
				elem,
				matrix_type,
				matrix )

	struct GRid	*elem;
	IGRshort	*matrix_type;
	IGRmatrix	matrix;
#endif

/*
NAME
	HSprocess_soos_on_curve

DESCRIPTION
	This function processes the SOs on a curve for
	delete detail display.

PARAMETERS
	elem (IN) - the GRid of the curve
	matrix_type (IN) - the type of 'matrix'
	matrix (IN) - the environment matrix of the curve

GLOBALS USED
	delete_ve_soo (static)
	window (static)
	HSlvhl.md_env
	DDDmaster_env (static)

HISTORY
	xx/xx/91    Mike Lanier
	   Creation Date
	02/17/92    S.P. Rogers
	   Added prologue comment and removed display logic
*/

	{
	if ( delete_ve_soo )
	   {
	   HSremove_VEso_on_edge( elem->objid,
	                          elem->osnum,
	                          window.objid,
	                          window.osnum,
	                          &HSlvhl.md_env,
	                          &DDDmaster_env,
	                          -1.0, -1.0,   /* remove from entire range */
	                          FALSE, /* automatic SOs only */
				  TRUE  /* re-display the edge */ );
	   }
	else
	   {
	   HSdump_hidden_symbology( elem->objid, elem->osnum, matrix_type, matrix );
	   }

	}  /* HSprocess_soos_on_curve */
	
end implementation Root;
