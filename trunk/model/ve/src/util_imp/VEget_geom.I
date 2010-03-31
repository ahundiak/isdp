
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/


class implementation Root;

#define  CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "gr.h"
#include "godef.h"
#include "go.h"

#include "dpstruct.h"

#include "msdef.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "EMSprop.h"

#include "bsparameters.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bsxtractpar.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEget_surface_id __((	struct VEelement_header *elem ));

#if defined(__cplusplus)
}
#endif

#undef __
%endsafe

from GRvg        import GRgenabsg;
from EMSsfimpbnd import EMget_subbs;
from EMSloopset  import EMget_props;
from EMSloopset  import EMgetrange;

/* External Global Variables */
extern struct VEtolerance_info VEtolerances;

%safe
static IGRboolean      VEloopset_chandef_defined = FALSE;
static OM_S_CHANSELECT VEloopset_chandef;
%endsafe

/*---- VEget_surface_id -----------------------------------------*/

static void VEget_surface_id(	struct VEelement_header *elem )

/*
NAME
	VEget_surface_id (static)

DESCRIPTION
	Get the object id of the surface that was located.  If a surface
	has imposed boundaries and has not been compressed, VE locates the
	top-level DPR object that keeps track of the boundary impositions
	on the surface.  We must have the object id of the actual surface
	in order to easily locate the loopset object for the surface.

PARAMETERS
	elem (IN) - the element whose surface id is to be found

GLOBALS USED
	none

HISTORY
	S.P. Rogers  09/21/87  Creation Date
*/

	{
	IGRlong sts;
	IGRlong msg;
	OMuword surf_classid;


	sts = om$get_classid( osnum     = elem->env->osnum,
	                      objid     = elem->objid,
	                      p_classid = &surf_classid );

	   OM_ERRCHK( sts, "VEget_surface_id:  om$get_classid failed" );

	if ( om$is_ancestry_valid( subclassid     = surf_classid,
	                           superclassname = "EMSsfimpbnd" ) == OM_S_SUCCESS )
	   {
	   /* we located a DPR object on a surface */
	   /* send message to get surface objid    */
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message EMSsfimpbnd.EMget_subbs( &msg,
	                                                              (GRobjid *) &elem->objid ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->env->osnum );

	      OM_ERRCHK( sts, "VEget_surface_id:  EMSsfimpbnd.EMget_subbs send failed" );
	      MSG_ERRCHK( msg, "VEget_surface_id:  EMSsfimpbnd.EMget_subbs failed" );

	   }

	}  /* VEget_surface_id */



/*---- VEget_element_geometry --------------------------------------*/

void VEget_element_geometry( elem, env )

	struct VEelement_header *elem;        /* element header                     */
	struct VEenv_info       *env;         /* pointer to environment information */

/*
NAME
	VEget_element_geometry

DESCRIPTION
	Get the geometry of an element.

PARAMETERS
	elem (IN) - the element whose geomtry to get
	env (IN) - the VE environemnt of the element

GLOBALS USED
	VEtolerances
	VEloopset_chandef_defined, VEloopset_chandef (static)

HISTORY
	05/01/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               rc;
	IGRlong               sts;
 	IGRlong               msg;
	OMuint                chan_count;
	IGRushort             ls_props;
	IGRchar               *absgeom;
	IGRdouble             min_u, min_v, max_u, max_v;
	IGRdouble             uv_range[4];
	IGRdouble             current_cht;
	IGRdouble             current_base_tol;
	struct IGRbsp_surface *surf;
	OM_S_OBJECT_LINKAGE   loopset[1];


	/* save the current CHT and base_tol */
	BSxtractpar( &rc, BSTOLCHRDHT, &current_cht );
	BSxtractpar( &rc, BSTOLBASIS, &current_base_tol );
	
	/* reset the CHT and base_tol to the values they had before */
	/* Visible Edges was started => this will ensure that the   */
	/* GRgenabsg method won't fail because VE has changed the   */
	/* tolerances.                                              */
	BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_cht );
	BSchgdeppar( VEtolerances.VEsystem_base_tol, &rc );

	elem->u_range[0] = elem->v_range[0] = 0.0;
	elem->u_range[1] = elem->v_range[1] = 1.0;

	/* get the abstract geometry of the element */
	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message GRvg.GRgenabsg( &msg,
	                                                  &env->matrix_type,
	                                                  env->matrix,
	                                                  &absgeom ),
	               senderid = NULL_OBJID,
	               targetid = elem->objid,
	               targetos = elem->env->osnum );

	   OM_ERRCHK( sts, "VEget_element_geometry:  GRvg.GRgenabsg send failed" );
	   MSG_ERRCHK( msg, "VEget_element_geometry:  GRvg.GRgenabsg failed" );

        if ( !(1 & sts & msg) )
           {
           elem->geom.curve = NULL;
           return;
           }

	/* restore the CHT and base_tol */
	BSchangepar( &rc, BSTOLCHRDHT, current_cht );
	BSchgdeppar( current_base_tol, &rc );

	switch ( elem->type )
	   {
	   case SURFACE :

	      elem->geom.gmsurf = (struct BSgeom_bsp_surf *) malloc( sizeof( struct BSgeom_bsp_surf ) );

	      /* get the type of the surface */
	      getsftype( elem->objid, elem->env->osnum, &elem->geom.gmsurf->type );

	      elem->geom.gmsurf->geom_prop = FALSE;
	      elem->geom.gmsurf->bounded = TRUE;
	      elem->geom.gmsurf->sfgen_cv = NULL;
	      
	      elem->geom.gmsurf->bspsf = surf = (struct IGRbsp_surface *) absgeom;
	      surf->num_boundaries = 0;
	      surf->bdrys = NULL;

	      /* copy surface from cache buffer into malloced space */
	      /* and transform it to viewing coordinates            */
	      if ( ! VEcopy_and_trans_to_view( (IGRchar **)&(elem->geom.gmsurf->bspsf),
                                               SURFACE ) )
                 {
                 /* failure */
                 elem->geom.gmsurf = NULL;
                 return;
                 }

	      /* if environment has a mirror transformation, flip pos_orient flag     */
	      /* so natural normals will be point in the correct direction for solids */
	      if ( env->flags & VE_ENV_MIRROR_TRANS )
	         elem->geom.gmsurf->bspsf->pos_orient = !elem->geom.gmsurf->bspsf->pos_orient;

	      /* get the correct surface objid */
	      VEget_surface_id( elem );

	      /* Determine if the surface has boundaries.  A surface has */
	      /* boundaries, if the surface has a loopset and the        */
	      /* properties word of the loopset says it is not a natural */
	      /* loopset.  Also save the object id of the loopset id in  */
	      /* the surface's element header.                           */
	      if ( ! VEloopset_chandef_defined )
	         {
	         om$make_chanselect( channame     = "EMSsubbs.to_loopset",
	                             p_chanselect = &VEloopset_chandef );

	         VEloopset_chandef_defined = TRUE;
	         }

	      sts = om$get_channel_objects( osnum        = elem->env->osnum,
	                                    objid        = elem->objid,
	                                    p_chanselect = &VEloopset_chandef,
	                                    list         = loopset,
	                                    size         = 1,
	                                    count        = &chan_count );

	         OM_ERRCHK( sts, "VEget_element_geometry:  om$get_channel_objects failed" );

	      if ( chan_count != 0 )
	         {
	         sts = om$send( mode     = OM_e_wrt_object,
	                        msg      = message EMSloopset.EMget_props( &msg, &ls_props ),
	                        targetid = loopset[0].S_objid,
	                        targetos = loopset[0].osnum,
	                        senderid = NULL_OBJID );

	            OM_ERRCHK( sts, "VEget_element_geometry:  EMget_props send failed" );
	            MSG_ERRCHK( msg, "VEget_element_geometry:  EMget_props failed" );

	         elem->loopset_id = loopset[0].S_objid;

	         if ( !( ls_props & EMLS_NATURAL ) )
	            {
	            /* loopset is not natural => surface has boundaries */
	            elem->flags |= HAS_BOUNDARIES;

	            /* get the uv space range box of the boundaries */
	            sts = om$send( mode         = OM_e_wrt_object,
	                           msg          = message EMSloopset.EMgetrange( &msg,
	                                                                         uv_range ),
	                           senderid     = NULL_OBJID,
	                           targetid     = elem->loopset_id,
	                           targetos     = elem->env->osnum );
		       
	               OM_ERRCHK( sts, "VEget_geom: EMSloopset.EMgetrange send failed" );
	               MSG_ERRCHK( msg, "VEget_geom: EMSloopset.EMgetrange failed" );

	            /* make sure the loopset range is within the range of the surface */
	            min_u = surf->u_knots[ surf->u_order - 1 ];
	            max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	            min_v = surf->v_knots[ surf->v_order - 1 ];
	            max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];

	            if ( uv_range[0] < min_u ) uv_range[0] = min_u;
	            if ( uv_range[1] < min_v ) uv_range[1] = min_v;
	            if ( uv_range[2] > max_u ) uv_range[2] = max_u;
	            if ( uv_range[3] > max_v ) uv_range[3] = max_v;

	            elem->u_range[0] = uv_range[0];
	            elem->u_range[1] = uv_range[2];
	            elem->v_range[0] = uv_range[1];
	            elem->v_range[1] = uv_range[3];

	            }
	         }
	      else
	         {
	         /* surface doesn't have a loopset => set loopset id to NULL */
	         elem->loopset_id = NULL_OBJID;
	         }

	      memcpy( elem->geom.gmsurf->urange, elem->u_range, sizeof( IGRdouble ) * 2 );
	      memcpy( elem->geom.gmsurf->vrange, elem->v_range, sizeof( IGRdouble ) * 2 );
	      break;

	   case CURVE : case POINT :

	      elem->geom.curve = (struct IGRbsp_curve *) absgeom;

	      /* copy curve/point from cache buffer into malloced */
	      /* space and transform it to viewing coordinates    */
	      if ( ! VEcopy_and_trans_to_view( (IGRchar **)&(elem->geom.curve), 
                                                CURVE ) )
                 {
                 /* failure */
                 elem->geom.curve = NULL;
                 return;
                 }
	      break;
	   }

	}  /* VEget_element_geometry */

end implementation Root;
