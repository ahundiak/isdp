
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $

HISTORY:
		Ramana  08/16/95 Added emsdef.h as bsvalues.h is changed.
*/

class implementation Root;


#define CHECK_RETURN_CODES	1

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bsvalues.h"

#include "msdef.h"
#include "gr.h"

#include "igrdp.h"
#include "go.h"
#include "godef.h"

#include "dpstruct.h"

#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSobjmgrdef.h"
#include "emsdef.h"

#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bschrdlkts.h"

#if TIMING
extern IGRdouble  VEtime_ptloc;
extern IGRint     VEcount_ptloc;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

/* Global Variables */

%safe
extern struct VEexecution_parms VEexec_parms;
extern struct VEid_list		*VEcommon_id_list;

static struct GRmdenv_info      VEid_env = { 2,                       /* matrix type */
	                                     { 1.0, 0.0, 0.0, 0.0,    /* matrix */
	                                       0.0, 1.0, 0.0, 0.0,
	                                       0.0, 0.0, 1.0, 0.0,
	                                       0.0, 0.0, 0.0, 1.0 } };

static IGRboolean      VEcommon_edge_chan_defined = FALSE;
static OM_S_CHANSELECT VEcommon_edge_chan;
%endsafe

/* External functions */
extern double fabs();

/* Imported messages */
from EMSsurface  import EMputLsIfNotThere;
from EMSboundary import EMget_edges;
from EMSboundary import EMgetsurface_info;
from EMSedge     import EMget_props, EMget_bcxyz_geom, EMendpts;
from GRvg        import GRgetsymb;

/*--- VEset_iso_edge_info -----------------------------------------------*/

void VEset_iso_edge_info( struct VEedge_header *edge,
                          OMuword              osnum,
                          IGRushort            edge_prop_word )

/*
NAME
	VEset_iso_edge_info

DESCRIPTION
	Given an edge from a loopset and its properties word, this function
	determines if the edge is an isocurve.  If it is, it sets the
	information in the edge header appropriately.

PARAMETERS
	edge (IN/OUT) - the edge whose iso information is to be set
	osnum (IN) - the object space number of the edge
	edge_prop_word (IN) - the properties word of the edge

GLOBALS USED
	none

HISTORY
	03/11/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong           sts, msg;
	IGRdouble         beg_pt[2], end_pt[2];
	
	/* see if the edge is an iso-curve */
	if ( edge_prop_word & (EMED_ISO | EMED_NATURAL) )
	   {
	   /* get beginning and ending points of the edge in UV space */
	   sts = om$send( msg      = message EMSedge.EMendpts( &msg, beg_pt, end_pt, NULL, NULL, NULL ),
	                  senderid = NULL_OBJID,
	                  targetid = edge->edge_id,
	                  targetos = osnum );

	      OM_ERRCHK( sts, "VEset_iso_edge_info: EMendpts send failed" ); 	
	      MSG_ERRCHK( msg, "VEset_iso_edge_info: EMendpts failed" ); 	

	   if ( fabs( beg_pt[0] - end_pt[0]) < 0.0000001 )
	      {
	      /* constant u */
	      edge->status |= CONSTANT_U_ISOCURVE;
	      edge->iso_parm = beg_pt[0];
	      }
	   else if ( fabs( beg_pt[1] - end_pt[1]) < 0.0000001 )
	      {
	      /* constant v */
	      edge->status |= CONSTANT_V_ISOCURVE;
	      edge->iso_parm = beg_pt[1];
	      }
	   }

	}  /* VEset_iso_edge_info */


/*--- VEedge_in_common_id_list --------------------------------------------*/

static IGRboolean VEedge_in_common_id_list( 	OM_S_OBJID edge_id,
						IGRshort   attach_id )

/*
NAME
	VEedge_in_common_id_list (static)

DESCRIPTION
	This function determines if an edge is in the common id list.
	If it is, TRUE is returned and the entry for the edge is removed
	from the list.  If it isn't, FALSE is returned.

PARAMETERS
	edge_id (IN) - the edge id to search for in the common id list
	attach_id (IN) - the attachment id of the edge

GLOBALS USED
	VEcommon_id_list

RETURN VALUES
	TRUE - edge is in common id list
	FALSE - edge is not in common id list

HISTORY
	04/19/89    S.P. Rogers
	   Creation Date
*/

	{
	struct VEid_list *id_node, *prev_id_node;

	id_node = VEcommon_id_list;
	prev_id_node = NULL;
	while ( id_node )
	   {
	   if ( (id_node->objid == edge_id) && (id_node->attach_id == attach_id) )
	      {
	      /* The edge is in the id list => remove the node */
	      /* from the list and return TRUE                 */
	      if ( prev_id_node == NULL )
	         VEcommon_id_list = id_node->next;
	      else
	         prev_id_node->next = id_node->next;

	      VEfree_id_list_node( id_node );
	      return( TRUE );
	      }
	   else
	      {
	      prev_id_node = id_node;
	      id_node = id_node->next;
	      }
	   }  /* end: while */
					
	return( FALSE );

	}  /* VEedge_in_common_id_list */


/*--- VEdummy_surface_on_displayed_layer ------------------------------------------------*/

static IGRboolean VEdummy_surface_on_displayed_layer( OM_S_OBJID dummy_surf_id,
						      OMuword    dummy_surf_os,
						      IGRint     *layer_mask )

/*
NAME
	VEdummy_surface_on_displayed_layer (static)

DESCRIPTION
	This function determines if a surface is on a layer that is currently
	displayed.

PARAMETERS
	dummy_surf_id (IN) - the object id of the surface
	dummy_surf_os (IN) - the object space number of the surface
	layer_mask (IN) - the current layer mask

GLOBALS USED
	none

RETURN VALUES
	TRUE - if surface is on a displayed layer
	FALSE - if surface is on a non-displayed layer

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong            sts;
	IGRlong            msg;
	struct GRsymbology symb;


	/* get the layer of the surface */
	sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &symb ),
	               targetid = dummy_surf_id,
	               targetos = dummy_surf_os,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEdummy_surface: GRgetsymb send failed" ); 	
	   MSG_ERRCHK( msg, "VEdummy_surface: GRget_symb failed" ); 	

	if ( ( ( 1 << (symb.level % 32) ) & layer_mask[symb.level >> 5] ) )
	   return( TRUE );
	else
	   return( FALSE );

	}  /* VEdummy_surface_on_displayed_layer */


/*--- VEget_edge_geometry ----------------------------------------------------*/

struct BSgeom_bsp_curve *VEget_edge_geometry( struct IGRbsp_surface *surf,
	  				      OM_S_OBJID            edge_id,
					      struct VEenv_info     *env,
					      IGRboolean            ok_to_reparameterize )

/*
NAME
	VEget_edge_geometry

DESCRIPTION
	This function gets the geometry of an edge that is part of a loopset.
	If surf is NULL, then we must get the geometry in world coordinates
	and transform it to the view.  If surf is not NULL, the curve geometry
	will be constructed using the surface so it will be in the same
	coordinate system as the surface (i.e., viewing coordinates).

PARAMETERS
	surf (IN) - the surface that the edge belongs to (can be NULL)
	edge_id (IN) - the object id of the edge
	env (IN) - the environment of the edge
	ok_to_reparameterize (IN) - if TRUE, an order 2 curve is reparameterize
	                            to get a non-uniform knot vector

GLOBALS USED
	none

RETURN VALUES
	A pointer to the edge geometry is returned.  NULL is returned if there
	was an error

NOTES
	The curve that is returned should be freed by the caller

HISTORY
	02/16/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 sts;
	IGRlong                 msg;
	IGRlong                 rc;
	IGRint                  last_pole;
	IGRint                  ii;
        IGRdouble               knot_spacing, knot_value;
	struct GRmdenv_info     elem_env;
	struct GRmdenv_info     *mdenv_info;
	struct IGRbsp_curve     *curve;
	struct BSgeom_bsp_curve *gmcurve;

	gmcurve = VEalloc_geom_curve( 0, 0, 0, 0 );
	if ( ! gmcurve )
	   return( NULL );

	gmcurve->bspcv = curve = (struct IGRbsp_curve *) malloc( sizeof( struct IGRbsp_curve ) );
	if ( ! curve )
	   return( NULL );

	curve->poles = NULL;
	curve->knots = NULL;
	curve->weights = NULL;

	if ( surf == NULL )
	   {
	   /* set up an environment structure so the curve   */
	   /* geometry will be returned in world coordinates */
	   mdenv_info = &elem_env;
	   elem_env.matrix_type = env->matrix_type;
	   memcpy( elem_env.matrix, env->matrix, sizeof( IGRdouble ) * 16 );
	   }
	else
	   {
	   /* environment should be the identity because we want     */
	   /* the curve in the same coordinate system as the surface */
	   mdenv_info = &VEid_env;
	   }

	sts = om$send( msg      = message EMSedge.EMget_bcxyz_geom( &msg,
	                                                            mdenv_info,
	                                                            NULL,
	                                                            surf,
	                                                            0,
	                                                            0x7fffffff,
	                                                            FALSE,
	                                                            NULL,
	                                                            curve ),
	               senderid = NULL_OBJID,
	               targetid = edge_id,
	               targetos = env->osnum );
					
	if ( (1 & sts & msg) )
	   {
	   if (! curve->phy_closed )
	      {
	      /* sometimes edges that are physically closed don't have the bit set */
	      /* properly.  Test for closure here until Allen/Prasad fix it        */
	      last_pole = (curve->num_poles - 1) * 3;
	      if ( (curve->poles[0] == curve->poles[last_pole]) &&
	           (curve->poles[1] == curve->poles[last_pole+1]) &&
	           (curve->poles[2] == curve->poles[last_pole+2]) )
	         curve->phy_closed = TRUE;
	      }

	   if ( surf == NULL )
	      VEtrans_curve_to_view( curve );

	   if ( curve->order == 2 )
	      {
              if ( ok_to_reparameterize )
                 {
	         /* Space knots with respect to arc length between poles => this    */
	         /* is done so that a point evaluated at the parametric midpoint of */
	         /* a span will be approximately equal to the geometric midpoint    */
   	         /* of the span.                                                    */
	         curve->non_uniform = TRUE;
	         BSchrdlkts( &rc, &curve->num_poles, curve->poles,
	                     &curve->order, &curve->periodic, curve->knots );

	            BS_ERRCHK( rc, "VEget_edge_geometry: BSchrdlkts failed" );
	         }
              else if ( ! curve->rational )
                 {
                 /* make sure order 2, non-rational curves have a uniform knot   */
                 /* vector;  this is to guarantee that SOs match the model space */
                 /* counterpart parameterization which is always uniform         */

                 knot_spacing = 1.0 / (curve->num_poles - 1);
                 for ( ii = 2, knot_value = knot_spacing;
                       ii < curve->num_poles;
                       ii++, knot_value += knot_spacing )
                    {
                    curve->knots[ii] = knot_value;
                    }
                 }
              }
	   return( gmcurve );
	   }
	else
	   {
	   fprintf(stderr, "VEget_edge_geometry: EMget_bcxyz_geom send failed" );
	   free( (IGRchar *) curve );
	   return( NULL );
	   }
					
	}  /* VEget_edge_geometry */



/*--- VEget_surf_edges_and_bdrys ----------------------------------------------------*/

struct VEedge_header *VEget_surf_edges_and_bdrys( element )

	struct VEelement_header *element;

/*
NAME
	VEget_surf_edges_and_bdrys

DESCRIPTION
	This function creates a list of edge headers that represent
	the natural edges and boundaries of a surface.  A pointer to
	the head of this edge list is returned.

PARAMETERS
	element (IN) - the element whose edge list is to be created

GLOBALS USED 
	VEexec_parms.VEhiding

RETURN VALUES
	A pointer to the edge list is returned

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
	03/26/92    S.P. Rogers
	   Added code to make sure seam edges are not created as shared
	   edges.
*/

	{
	OM_S_OBJECT_LINKAGE  common_edge_linkage[1];
	OM_S_OBJID           dummy_surf_id;
	IGRlong              msg;
	OMuint               common_edge_count;
	IGRlong              get_edges_option;
	struct GRid          *edge_ids;
	IGRint               edge_id_size;
	IGRint               num_edges;
	IGRint               ii;
	IGRint               sts;
	IGRushort            edge_prop_word;
	IGRushort            dummy_prop_word;
	struct VEid_list     *id_node;
	struct VEedge_header *head, *tail, *new_edge;
	IGRboolean           use_dummy_geom;
	GRobjid              loopset_id;
	IGRboolean           loopset_created;


	head = tail = NULL;
	 
	/* make sure this surface has a loopset */
	sts = om$send( msg = message EMSsurface.EMputLsIfNotThere( &msg,
	                                                           &element->env->md_env.md_env,
	                                                           NULL, &loopset_id,
	                                                           0, &loopset_created ),
	               senderid = NULL_OBJID,
	               targetid = element->objid,
	               targetos = element->env->osnum );

	if ( !(1 & sts & msg) )
	   return( NULL );  /* couldn't get the loopset for the surface */

	element->loopset_id = loopset_id;

	/* the surface has a loopset => get the edges from the loopset */
	edge_id_size = 0;
	num_edges = 0;
	edge_ids = NULL;

	get_edges_option = EMS_OPT_NONDEG_NONTANSEAM;
	sts = om$send( msg      = message EMSboundary.EMget_edges( &msg,
								   MAXINT,
	                                                           get_edges_option,
	                                                           &edge_ids,
	                                                           &edge_id_size,
	                                                           &num_edges ),
	               senderid = NULL_OBJID,
	               targetid = loopset_id,
	               targetos = element->env->osnum );
		
	   OM_ERRCHK( sts,  "VEget_surf_edges_and_bdrys: EMget_edges send failed" );


	if ( ! VEcommon_edge_chan_defined )
	   {
	   om$make_chanselect( channame     = "EMSedge.to_common_edge",
	                       p_chanselect = &VEcommon_edge_chan );
	   VEcommon_edge_chan_defined = TRUE;
	   }

	for ( ii = 0; ii < num_edges; ii++ )
	   {
	   new_edge = NULL;
	   use_dummy_geom = FALSE;

	   /* get the properties word for the edge */
	   sts = om$send( msg      = message EMSedge.EMget_props( &msg, &edge_prop_word ),
	                  senderid = NULL_OBJID,
	                  targetid = edge_ids[ii].objid,
	                  targetos = edge_ids[ii].osnum );

	      OM_ERRCHK( sts, "VEget_surf_edges_and_bdrys: EMget_props send failed" ); 	

	   /* check the common edge channel to see if this edge is a shared edge */
	   sts = om$get_channel_objects( osnum        = edge_ids[ii].osnum,
	                                 objid        = edge_ids[ii].objid,
	                                 p_chanselect = &VEcommon_edge_chan,
	                                 list         = common_edge_linkage,
	                                 size         = 1,
	                                 count        = &common_edge_count );

	      OM_ERRCHK( sts, "VEget_surf_edges_and_bdrys:  om$get_channel_count for common edge failed" );

	   if ( edge_prop_word & EMED_SEAM )
	      {
	      /* This edge is a seam edge so only activate the dominant one of the pair. */
	      /* Activating the dominant one will ensure that things like SOs are placed */
	      /* properly.  We don't need shared seam edges for correct output because   */
	      /* both edges are on the same surface.  Also, shared edges on the same     */
	      /* surface will be in the same edge list which will cause massive problems */
	      /* for the shared edge linking, splitting, classifying, etc. code          */
	      if ( ! (edge_prop_word & EMED_SUBORDINATE) )
	         {
	         /* this will cause the edge to activate as a non-shared edge */
	         common_edge_count = 0;
	         }
	      else
	         {
	         /* skip this subordinate seam edge */
	         continue;
	         }
	      }

	   if ( common_edge_count > 0 )
	      {
	      /* get the properties word for the dummy edge */
	      sts = om$send( msg      = message EMSedge.EMget_props( &msg, &dummy_prop_word ),
	                     senderid = NULL_OBJID,
	                     targetid = common_edge_linkage[0].S_objid,
	                     targetos = common_edge_linkage[0].osnum );

	         OM_ERRCHK( sts, "VEget_surf_edges_and_bdrys: EMget_props send failed" ); 	

	      /* This edge is a shared edge => see if the other shared */
	      /* edge has already been activated                       */			
	      if ( ! VEedge_in_common_id_list( edge_ids[ii].objid, element->env->attach_id ) )
	         {
	         /* This edge is the first edge to be activated of a shared     */
	         /* edge pair => activate it as a real shared edge if its dummy */
	         /* edge is active and the surface that owns the dummy edge is  */
	         /* on a layer that is turned on; otherwise activate it as a    */
	         /* generic non-shared edge.                                    */
	         new_edge = VEalloc_edge_header();
	         new_edge->edge_id = edge_ids[ii].objid;

	         /* get the surface that owns the dummy_edge => the surface will */
	         /* be the NULL_OBJID if the dummy_edge is not active            */
	         dummy_surf_id = NULL_OBJID;
	         sts = om$send( mode     = OM_e_wrt_object,
	                        msg      = message EMSboundary.EMgetsurface_info( &msg,
	                                                                          &dummy_surf_id,
	                                                                          NULL ),
	                        targetid = common_edge_linkage[0].S_objid,
	                        targetos = element->env->osnum,
	                        senderid = NULL_OBJID );

	            OM_ERRCHK( sts, "VEget_surf_edges_and_bdrys: EMgetsurface_info send failed" ); 	
	            MSG_ERRCHK( msg, "VEget_surf_edges_and_bdrys: EMgetsurface_info failed" ); 	

	         /* See if we should get the geometry for this edge from   */
	         /* the dummy edge because it is better.  The edge with    */
	         /* the best geometry doesn't have the suborinate bit set. */
	         if ( edge_prop_word & (EMED_NATURAL | EMED_ISO) )
	            use_dummy_geom = FALSE;  /* real edge is a natural edge or isocurve */
	         else if ( dummy_prop_word & (EMED_NATURAL | EMED_ISO) )
	            use_dummy_geom = TRUE;  /* dummy edge is a natural edge or isocurve */
	         else
	            use_dummy_geom = ! (dummy_prop_word & EMED_SUBORDINATE);

	         if ( ( dummy_surf_id != NULL_OBJID ) &&
	              (VEdummy_surface_on_displayed_layer( dummy_surf_id,
	                                                   element->env->osnum,
	                                                   element->env->layers ) ) )
	            {
	            /* new_edge should be activated as a real shared edge   */

	            new_edge->status |= REAL_SHARED_EDGE;

	            /* add the id of the dummy edge to the common edge id list */
	            id_node = VEalloc_id_list_node();
	            id_node->objid = common_edge_linkage[0].S_objid;
	            id_node->attach_id = element->env->attach_id;

	            id_node->next = VEcommon_id_list;
	            VEcommon_id_list = id_node;

	            /* set the flag in the edge header that indicates whether this     */
	            /* shared edge pair consists of two edges that are of different    */
	            /* types (i.e., one is a boundary and the other is a natural edge) */

	            if ((edge_prop_word & EMED_NATURAL) != (dummy_prop_word & EMED_NATURAL))
	               {
	               /* the real and shared edges are of different edge types */
	               new_edge->status |= DIFFERENT_EDGE_TYPES;
	               }

	            /* set tangent edge flag for the edge */
	            if ( (edge_prop_word & EMED_TANGENT) || (dummy_prop_word & EMED_TANGENT) )
	               new_edge->status |= EDGE_IS_TANGENT;

	            }  /* end: if ( VEdummy_surface ... */

	         /* get the geometry for this edge because it is the real shared edge */
	         if ( use_dummy_geom )
	            {
	            new_edge->gm_curve3d = VEget_edge_geometry( (struct IGRbsp_surface *) NULL,
	                                                   common_edge_linkage[0].S_objid,
	                                                   element->env, TRUE );

	            if ( new_edge->gm_curve3d != NULL )
	               {
		       new_edge->gm_curve3d->type = VEget_edge_geom_type( common_edge_linkage[0].S_objid,
	                                                                  element->env->osnum, FALSE );
	               new_edge->gm_curve3d->geom_prop = FALSE;
	               new_edge->gm_curve3d->bscv_flag = TRUE;
	               }
	            }
	         else
	            {
	            new_edge->gm_curve3d = VEget_edge_geometry( element->geom.gmsurf->bspsf,
	                                                        edge_ids[ii].objid,
	                                                        element->env, TRUE );

	            if ( new_edge->gm_curve3d != NULL )
	               {
	               new_edge->gm_curve3d->type = VEget_edge_geom_type( edge_ids[ii].objid,
	                                                                  element->env->osnum, FALSE );
	               new_edge->gm_curve3d->geom_prop = FALSE;
	               new_edge->gm_curve3d->bscv_flag = TRUE;
	               }
                    }

	         if ( new_edge->gm_curve3d == NULL )
	            {
	            VEfree_edge_header( new_edge );
	            new_edge = NULL;
	            }

	         VEset_iso_edge_info( new_edge, element->env->osnum, edge_prop_word );

	         }  /* end: if ( edge is not in common id list ) */

	      else if ( VEexec_parms.VEhiding )

	         {
	         /* This edge is the second edge of shared edge pair to be */
	         /* activated and we are doing hiding => activate the new  */
	         /* edge as a dummy and record the object id of its        */
	         /* corresponding real edge in its num_sh_spans field.     */
	         new_edge = VEalloc_edge_header();
	         new_edge->edge_id = edge_ids[ii].objid;
	         new_edge->status |= WAS_A_DUMMY;
	         new_edge->num_sh_spans = common_edge_linkage[0].S_objid;
	         new_edge->gm_curve3d = NULL;
	         VEset_iso_edge_info( new_edge, element->env->osnum, edge_prop_word );

	         /* set tangent edge flag for the edge */
	         if ( (edge_prop_word & EMED_TANGENT) || (dummy_prop_word & EMED_TANGENT) )
	            new_edge->status |= EDGE_IS_TANGENT;
	         }  /* end: else if ( VEexec_parms.VEhiding ) */

	      }  /* end: edge has a common edge */
	   else
	      {
	      /* the edge doesn't have a common edge => activate it as */
	      /* a non-shared edge                                     */
	      new_edge = VEalloc_edge_header();
	      new_edge->edge_id = edge_ids[ii].objid;
	      new_edge->gm_curve3d = VEget_edge_geometry( element->geom.gmsurf->bspsf,
	                                             edge_ids[ii].objid,
	                                             element->env, TRUE );

	      if ( new_edge->gm_curve3d == NULL )
	         {
	         VEfree_edge_header( new_edge );
	         new_edge = NULL;
	         }
	      else
	         {
	         new_edge->gm_curve3d->type = VEget_edge_geom_type( edge_ids[ii].objid,
	                                                            element->env->osnum,
                                                                    TRUE );
	         new_edge->gm_curve3d->geom_prop = FALSE;
	         new_edge->gm_curve3d->bscv_flag = TRUE;

	         VEset_iso_edge_info( new_edge, element->env->osnum, edge_prop_word );
	         }

	      }  /* end: else */

	   if ( new_edge )
	      {
	      /* an edge was successfully created => fill in the rest of its data */
			
	      /* determine the edge type from the appropriate props word */
	      if ( use_dummy_geom )
	         {
	         new_edge->type = (dummy_prop_word & EMED_NATURAL) ? NATURAL : BOUNDARY;
	         new_edge->status |= USING_DUMMY_GEOMETRY;
	         }
	      else
	         new_edge->type = (edge_prop_word & EMED_NATURAL) ? NATURAL : BOUNDARY;

	      if ( new_edge->gm_curve3d )
	         new_edge->visib_list = VEconstruct_visib_list( new_edge->gm_curve3d->bspcv, VISIBLE );

	      VEadd_edges_to_list( new_edge, &head, &tail );
	      }  /* end: if ( new_edge ) */

	   }  /* end: for all edges */

	if ( (num_edges) && (edge_ids) )
	   om$dealloc( ptr = edge_ids );  /* allocated with om$malloc() */

	return( head );

	}  /* VEget_surf_edges_and_bdrys */

end implementation Root;
