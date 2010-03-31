
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
*/

class implementation Root;

#define  CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "wl.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"

#include "msdef.h"

#include "HStl_window.h"
#include "HStl_element.h"

#include "bstypes.h"
#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bschangepar.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hsurferrpriv.h"

#include "EMSprop.h"

#include "hstiler.h"
#include "HSfem_spt.h"

%safe
#include "HSpr_render.h"
%endsafe

/*----------------------------
 *  for function
 *     CHT
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*---------------------------*/


from GRgraphics import  GRgetrang;
from GRvg        import GRgetgeom, GRgetsize;
from EMSsfimpbnd import EMget_subbs;
from EMSsubbs    import EMget_boundaries;
from EMSloopset  import EMget_props;
from EMSloopset  import EMgetrange;

%safe
static IGRboolean      HRloopset_chandef_defined = FALSE;
static OM_S_CHANSELECT HRloopset_chandef;
%endsafe

/*---- HRget_surface_id -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRget_surface_id( struct HRsurface_record *surf_rec )
#else
	static void HRget_surface_id( surf_rec )

	struct HRsurface_record *surf_rec;
#endif

/*
DESCRIPTION
	Get the object id of the surface that was located.  If a surface
	has imposed boundaries and has not been compressed, we located the
	top-level DPR object that keeps track of the boundary impositions
	on the surface.

HISTORY
	S.P. Rogers  07/19/89  Creation Date
*/

	{
	IGRlong sts;
	IGRlong msg;
	GRobjid surf_id;
	OMuword surf_classid;

	sts = om$get_classid( osnum     = surf_rec->env->osnum,
	                      objid     = surf_rec->objid,
	                      p_classid = &surf_classid );

	   OM_ERRCHK( sts, "HRget_surface_id:  om$get_classid failed" );

	if ( om$is_ancestry_valid( subclassid     = surf_classid,
	                           superclassname = "EMSsfimpbnd" ) == OM_S_SUCCESS )
	   {
	   /* we located a DPR object on a surface */
	   /* send message to get surface objid    */
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message EMSsfimpbnd.EMget_subbs( &msg, &surf_id ),
	                  senderid = NULL_OBJID,
	                  targetid = surf_rec->objid,
	                  targetos = surf_rec->env->osnum );

	      OM_ERRCHK( sts, "HRget_surface_id:  EMSsfimpbnd.EMget_subbs send failed" );
	      MSG_ERRCHK( msg, "HRget_surface_id:  EMSsfimpbnd.EMget_subbs failed" );

	   surf_rec->objid = surf_id;
	   }

	}  /* HRget_surface_id */


/*--- HRget_surface_boundaries ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRget_surface_boundaries( IGRdouble win_cht,
				      struct HRsurface_record *surf_rec,
					struct IGRbsp_surface *geom )
#else
	static IGRboolean HRget_surface_boundaries( win_cht, surf_rec, geom )

	IGRdouble               win_cht;
	struct HRsurface_record *surf_rec;
	struct IGRbsp_surface   *geom;
#endif

/*
DESCRIPTION
	Get the boundaries of a surface.  If all goes well, TRUE is returned.  Otherwise,
	FALSE, is returned.

HISTORY
	S.P. Rogers  09/04/89  Creation Date
*/

	{
	IGRlong               sts;
 	IGRlong               msg;
	IGRlong               rc;
	IGRdouble             cht;
	OMuint                chan_count;
	IGRushort             ls_props;
	OM_S_OBJECT_LINKAGE   loopset[1];

	geom->num_boundaries = 0;
	geom->bdrys = NULL;

	/* Determine if the surface has boundaries.  A surface has     */
	/* boundaries, if the surface has a loopset and the properties */
	/* word of the loopset says it is not a natural loopset.       */

	if ( ! HRloopset_chandef_defined )
	   {
	   om$make_chanselect( channame     = "EMSsubbs.to_loopset",
	                       p_chanselect = &HRloopset_chandef );

	   HRloopset_chandef_defined = TRUE;
	   }

	sts = om$get_channel_objects( osnum        = surf_rec->env->osnum,
	                              objid        = surf_rec->objid,
	                              p_chanselect = &HRloopset_chandef,
	                              list         = loopset,
	                              size         = 1,
	                              count        = &chan_count );

	   OM_ERRCHK( sts, "HRget_surface_boundaries:  om$get_channel_objects failed" );

	if ( chan_count != 0 )
	   {
	   /* get the properties word of the loopset */
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message EMSloopset.EMget_props( &msg, &ls_props ),
	                  targetid = loopset[0].S_objid,
	                  targetos = loopset[0].osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "HRget_surface_boundaries:  EMget_props send failed" );
	      MSG_ERRCHK( msg, "HRget_surface_boundaries:  EMget_props failed" );

	   if ( !( ls_props & EMLS_NATURAL ) )
	      {
	      /* loopset is not natural => surface has boundaries */

	      /* If the window based CHT is greater than the active CHT, change */
	      /* to window CHT before getting the boundaries for this surface   */
	      /* so order 3 and higher boundaries will be stroked to it.        */
	      if ( win_cht > cht )
	         {
	         BSxtractpar( &rc, BSTOLCHRDHT, &cht );
	         BSchangepar( &rc, BSTOLCHRDHT, win_cht );
	         }

	      /* get the boundaries of the surface */
	      sts = om$send( msg      = message EMSsubbs.EMget_boundaries( &msg,
	                                                                   &surf_rec->env->matrix_type,
	                                                                   surf_rec->env->matrix,
	                                                                   &geom->on_off,
	                                                                   &geom->num_boundaries,
	                                                                   &geom->bdrys ),
	                     senderid = NULL_OBJID,
	                     targetid = surf_rec->objid,
	                     targetos = surf_rec->env->osnum );

	         OM_ERRCHK( sts, "HRget_surface_boundaries:  EMSsubbs.EMget_boundaries send failed" );
	         MSG_ERRCHK( msg, "HRget_surface_boundaries:  EMSsubbs.EMget_boundaries failed" );

	      /* reset the CHT */
	      if ( win_cht > cht )
	         BSchangepar( &rc, BSTOLCHRDHT, cht );

	      if ( ! 1 & sts & msg )
	         return( FALSE );

	      }  /* end: if ( loopset is not natural ) */

	   }  /* end: if ( there is a loopset object ) */

	return( TRUE );

	}  /* HRget_surface_boundaries */


/*---- HRget_surface_geometry --------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRget_surface_geometry( struct HRsurface_record *surf_rec,
				       struct IGRbsp_surface **geom,
						   IGRdouble *world_range,
						   IGRdouble win_cht )
#else
	void HRget_surface_geometry( surf_rec, geom, world_range, win_cht )

	struct HRsurface_record *surf_rec;
	struct IGRbsp_surface   **geom;
	IGRdouble               *world_range;
	IGRdouble               win_cht;
#endif

/*
DESCRIPTION
	Get the geometry of a surface, its range in world coordinates, and the
	minimal uv space range box than encloses the entire solid area of the surface.

	Set *geom to NULL if a failure occurs.

HISTORY
	S.P. Rogers  07/19/89  Creation Date
	S.P. Rogers  09/04/89  Added returning of UV range box
*/

	{
	IGRlong               sts;
 	IGRlong               msg;
	IGRlong               object_size;
	IGRboolean            apply_matrix;

	*geom = NULL;

	/* get the correct surface objid */
	HRget_surface_id( surf_rec );

	/* get the range of the surface in world coordinates */
	apply_matrix = 1;
	sts = om$send( msg      = message GRgraphics.GRgetrang( &msg,
	                                                        &surf_rec->env->matrix_type,
	                                                        surf_rec->env->matrix,
	                                                        &apply_matrix,
	                                                        world_range ),
	               targetid = surf_rec->objid,
	               targetos = surf_rec->env->osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "HRget_surface_geometry:  GRgraphics.GRgetrang send failed" );
	   MSG_ERRCHK( msg, "HRget_surface_geometry:  GRgraphics.GRgetrang send failed" );

	if ( ! 1 & sts & msg )
	   return;

	/* get the size of the surface in bytes */
	sts = om$send ( msg      = message GRvg.GRgetsize( &msg,
	                                                   &surf_rec->env->matrix_type,
	                                                   surf_rec->env->matrix,
	                                                   &object_size ),
	                senderid = NULL_OBJID,
	                targetid = surf_rec->objid,
	                targetos = surf_rec->env->osnum );

	if ( ! 1 & sts & msg )
	   return;

	/* allocate space for surface */
	*geom = (struct IGRbsp_surface *) malloc( object_size );

	if ( *geom )
	   {
	   /* get the geometry of the surface */
	   sts = om$send( msg      = message GRvg.GRgetgeom( &msg,
	                                                     &surf_rec->env->matrix_type,
	                                                     surf_rec->env->matrix,
	                                                     (IGRchar *) *geom ),
	                  senderid = NULL_OBJID,
	                  targetid = surf_rec->objid,
	                  targetos = surf_rec->env->osnum );

	      OM_ERRCHK( sts, "HRget_surface_geometry:  GRvg.GRgetgeom send failed" );
	      MSG_ERRCHK( msg, "HRget_surface_geometry:  GRvg.GRgetgeom failed" );

	   if ( ! 1 & sts & msg )
	      {
	      free( (IGRchar *) *geom );
	      *geom = NULL;
	      return;
	      }

	   /* flip pos_orient if surface is being mirrored */
	   if ( surf_rec->env->mirror_transform )
	      (*geom)->pos_orient = ! (*geom)->pos_orient;

	   if ( ! HRget_surface_boundaries( win_cht, surf_rec, *geom ) )
	      {
	      free( (IGRchar *) *geom );
	      *geom = NULL;
	      return;
	      }

	   }  /* end: if ( *geom ) */

	}  /* HRget_surface_geometry */


/*--- HRfree_surface_geometry ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRfree_surface_geometry( struct IGRbsp_surface *geom )
#else
	void HRfree_surface_geometry( geom )

	struct IGRbsp_surface *geom;
#endif

/*
DESCRIPTION
	This function frees the geometry of a surface including the boundaries.
	The boundaries must have been allocated in a single block of memory
	(like EMSsubbs.EMget_boundaries does) for this function to work properly.

HISTORY
	S.P. Rogers  07/19/89  Creation Date
*/

	{
	/* free the boundaries */
	if ( (geom->num_boundaries > 0) && (geom->bdrys) )
	   {
	   free( (IGRchar *) geom->bdrys );
	   }

	free( (IGRchar *) geom );
	}  /* HRfree_surface_geometry */

end implementation Root;

