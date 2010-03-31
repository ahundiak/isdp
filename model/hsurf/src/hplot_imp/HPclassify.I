
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;
 
#define CHECK_RETURN_CODES 1

#define DEBUG_LOCATE       0

#include <stdio.h>
#include <FI.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "bs.h"

#include "wl.h"
#include "hplot_imp.h"
#include "hsmsg.h"
#include "HSplot.h"
#include "HSplot_def.h"

#include "HSpr_hplot.h"


from GRvg       import GRgenabsg;
from GRvg       import GRchgprops;
from GRvg       import GRgetsymb;
from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRowner    import GRget_matrix;

from EMSsfimpbnd	import EMget_subbs;


/* External - global variables */

/* Class-id's Needed For Element Classification */
extern OMuword OPP_IGEwinsup_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRtext_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRreffile_class_id;
extern OMuword OPP_GRflxown_class_id;
extern OMuword OPP_GRclhdr_class_id;
extern OMuword OPP_GRsmhdr_class_id;
extern OMuword OPP_GRsmdfhdr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_ACcpx_class_id;
extern OMuword OPP_AScontents_class_id;
extern OMuword OPP_ASnode_class_id;
extern OMuword OPP_GRdvattach_class_id;
extern OMuword OPP_EMSmassprop_class_id;


#define	POINT	1
#define CURVE	2
#define SURFACE	3

%safe
/*
 *  Prototype declaration for static functions
 */


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HPclassify.I */
static void HPget_surface_id __((struct GRid *elem));

static void HPget_components __((struct GRid *elem, 
			     struct GRmd_env *mod_id, 
				      IGRint *num_components, 
				 struct GRid **comp_ids));

#if defined(__cplusplus)
}
#endif


#undef __


%endsafe

/*---HPget_surface_id-----------------------------------------*/

/*
NAME
	HPget_surface_id: static
	
KEYWORDS
	static
	

DESCRIPTION
	Get the object id of the surface that was located.  If a surface
	has imposed boundaries and has not been compressed, VE locates the
	top-level DPR object that keeps track of the boundary impositions
	on the surface.  We must have the object id of the actual surface
	in order to easily locate the loopset object for the surface.

PARAMETERS
	elem	:(IN) : the objid, osnum of the object

FUNCTIONS CALLED
	om$get_classid
	om$is_ancesty_valid
	om$send
		EMSisimpbnd.EMget_subbs
	OM_ERRCHK
	MSG_ERRCHK
		
HISTORY
	09/21/87	S.P. Rogers  
		Creation Date
	08/30/89	M. Lanier
		Stole from VE.
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPget_surface_id( struct GRid *elem )
#else
	static void HPget_surface_id( elem )

	struct GRid	*elem;
#endif


	{
	IGRlong sts;
	IGRlong msg;
	OMuword surf_classid;


	sts = om$get_classid( osnum     = elem->osnum,
	                      objid     = elem->objid,
	                      p_classid = &surf_classid );

	OM_ERRCHK( sts, "HPget_surface_id:  om$get_classid failed" );

	if ( om$is_ancestry_valid( subclassid     = surf_classid,
	                           superclassname = "EMSsfimpbnd" ) == OM_S_SUCCESS )
		{
		/* we located a DPR object on a surface */
		/* send message to get surface objid    */

		sts = om$send(	mode     = OM_e_wrt_object,
				msg      = message EMSsfimpbnd.EMget_subbs( &msg, &elem->objid ),
				senderid = NULL_OBJID,
				targetid = elem->objid,
				targetos = elem->osnum );

		OM_ERRCHK( sts, "HPget_surface_id:  EMSsfimpbnd.EMget_subbs send failed" );
		MSG_ERRCHK( msg, "HPget_surface_id:  EMSsfimpbnd.EMget_subbs failed" );
		}
	}

/*---- HPget_components -------------------------------------------------*/

/*
NAME
	HPget_components

KEYWORDS
	static
	shaded plotting
	
DESCRIPTION
	This function gets the components owned by an object of class GRowner.
	It returns the components in an array that it has malloced so the
	caller is responsible for freeing the array when he is through with it.

PARAMETERS
	elem		:(IN) : objid, osnum of the object
	mod_id		:(IN) : module id
	num_components	:(OUT): Number of components elem has
	comp_ids	:(OUT): array of ids of elem's components

FUNCTIONS CALLED
	om$send
		GRowner.GRget_number_components
		GRowner.GRget_components
	OM_ERRCHK
	MSG_ERRCHK
	malloc
		
HISTORY
	02/03/88	S.P. Rogers
		Creation Date
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HPget_components( struct GRid *elem,
				  struct GRmd_env *mod_id,
					   IGRint *num_components,
				      struct GRid **comp_ids )
#else
	static void HPget_components( elem, mod_id, num_components, comp_ids )

	struct GRid	*elem;
	struct GRmd_env	*mod_id;
	IGRint		*num_components;
	struct GRid	**comp_ids;
#endif

	{
	IGRlong sts;
	IGRlong msg;
	IGRint  buf_size;

	/* get the number of components */
	
	*num_components = 0;
	
	sts = om$send(
		mode     = OM_e_wrt_object,
		msg      = message GRowner.GRget_number_components(
							&msg,
							num_components ),
		senderid = NULL_OBJID,
		targetid = elem->objid,
		targetos = elem->osnum );
		
	OM_ERRCHK( sts, "HPget_components: GRget_number_components send failed" );
	MSG_ERRCHK( msg, "HPget_components: GRget_number_components failed" );

	/* allocate array for component ids */
	
	buf_size = *num_components;
	*comp_ids = (struct GRid *) malloc( *num_components * sizeof( struct GRid ) );

	sts = om$send(
		mode     = OM_e_wrt_object,
		msg      = message GRowner.GRget_components( &msg,
					mod_id,
					*comp_ids,
					buf_size,
					num_components,
					0, 99999 ),
		senderid = NULL_OBJID,
		targetid = elem->objid,
		targetos = elem->osnum );

	OM_ERRCHK( sts, "HPget_components: GRget_components send failed" );
	MSG_ERRCHK( msg, "HPget_components: GRget_components failed" );

	}  /* HPget_components */


/*---- HPclassify_located_object -------------------------------------------*/

/*
NAME
	HPclassify_located_object
	
KEYWORDS
	shaded plotting
	classify
	
DESCRIPTION
	This function classifies a located object and performs the functions
	necessary to process the object.

	Following is a list of classes and the functions performed:

	   Composite Surface/Curve or Solid:       Get each component and
	                                           create sort records for them

	   Surface, Curve, or Point:               Create a sort record for it

	   Reference File Header:                  Turn off the display of the ref. file
	                                           if required by user

	   Graphic Group or Cell:                  Get each component and call
	                                           HPclassify_located_object recursively
	                                           on them

	   Symbol Header:                          Build a new environment matrix for
	                                           the symbol, get each component and
	                                           call HPclassify_located_object recursively

PARAMETERS
	file_id		:(IN) : File pointer for the output shaded plotfiles
	elem		:(IN) : osnum, objid of the object to classify
	mod_id		:(IN) : the module id
	matrix		:(IN) : 
	matrix_type	:(IN) :
	master_layers	:(IN) :
	num_colors	:(IN) :
	num_shades	:(IN) :
	window		:(IN) : objid, osnum of the selected window
	z_vector	:(IN) :
	
HISTORY
	02/03/88	S.P. Rogers
		Creation Date
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPclassify_located_object( IGRlong *file_id,
				       struct GRid *elem,
				   struct GRmd_env *mod_id,
					 IGRmatrix matrix,
					  IGRshort matrix_type,
					    IGRint *master_layers,
					  IGRshort *num_colors,
					  IGRshort *num_shades,
				       struct GRid *window,
					 IGRdouble *z_vector )
#else
	IGRint	HPclassify_located_object( file_id,
					elem, 
					mod_id,
		                        matrix, 
		                        matrix_type,
		                        master_layers,
		                        num_colors,
		                        num_shades,
		                        window,
		                        z_vector )

	IGRlong		*file_id;
	struct GRid	*elem;
	struct GRmd_env	*mod_id;
	IGRmatrix	matrix;
	IGRshort	matrix_type;
	IGRint		*master_layers;
	IGRshort	*num_colors;
	IGRshort	*num_shades;
	struct GRid	*window;
	IGRdouble	*z_vector;
#endif


	{
	OMuword         elem_classid;
	IGRshort        comp_type;
	IGRshort        comp_matrix_type;
	IGRlong         sts;
	IGRlong         msg;
	IGRint          comp_count;
	IGRint          comps;
	IGRmatrix       comp_matrix;
	struct GRid     *comp_ids;
	IGRint		status;


#	if DEBUG_LOCATE
	{
	IGRchar classname[50];
	
	om$get_classname( osnum = elem->osnum,
	                  objid = elem->objid,
	                  classname = classname );

	fprintf( stderr, "   Classifying %d:%d - %s\n", elem->objid, elem->osnum, classname );
	}
#	endif

	status = OM_S_SUCCESS;
	
	/*HPget_surface_id( elem );*/

	/* get the classid of this object */
		
	sts = om$get_classid(	osnum     = elem->osnum,
				objid     = elem->objid,
				p_classid = &elem_classid );

	if( ( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_GRflxown_class_id ) == OM_S_SUCCESS ) ||
		 ( elem_classid == OPP_GRclhdr_class_id ) ||
		 ( elem_classid == OPP_GRsmdfhdr_class_id ) )

		{
				
		/* The located object is a flexible grouping (graphic group), */
		/* cell header, or a symbol definition header => get each */
		/* component and classify them individually because they can */
		/* be nested. */
			
		HPget_components( elem, mod_id, &comp_count, &comp_ids );
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Cell/Symbol definition header: %d components\n", comp_count );
#		endif

		for( comps = 0; comps < comp_count; comps++ )
			{
			status = HPclassify_located_object( 
					file_id,
					&comp_ids[comps], 
					mod_id,
					matrix, 
					matrix_type,
					master_layers,
					num_colors,
					num_shades,
					window,
					z_vector );
					
			if( status == HS_E_PltFlWrtErr ) break;
			}

		/* free array of component GRid's */
			
		if( comp_ids ) free( (IGRchar *) comp_ids );
			
		}  /* end: object was a grouping object */

	else if( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
		{
				
		/* The located object is a symbol header => build */
		/* a new environment matrix for the objects in the */
		/* symbol, get each component and classify them */
		/* inidividually because they can be nested */
			
		sts = om$send(
			mode     = OM_e_wrt_object,
			msg      = message GRowner.GRget_matrix(
						(long *)&msg,
						(IGRshort *) &matrix_type,
						matrix,
						&comp_matrix_type,
						comp_matrix ),
			senderid = NULL_OBJID,
			targetid = elem->objid,
			targetos = elem->osnum );

		OM_ERRCHK( sts, "HPclassify_located_object: GRowner.GRget_matrix send failed" );
		MSG_ERRCHK( msg, "HPclassify_located_object: GRowner.GRget_matrix failed" );

		HPget_components( elem, mod_id, &comp_count, &comp_ids );
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Symbol header: %d components\n", comp_count );
#		endif

		for( comps = 0; comps < comp_count; comps++ )
			{
			status = HPclassify_located_object( 
					file_id,
					&comp_ids[comps],
					mod_id,
					comp_matrix, 
					comp_matrix_type,
					master_layers,
					num_colors,
					num_shades,
					window,
					z_vector );
					
			if( status == HS_E_PltFlWrtErr ) break;
			}

		/* free array of component GRid's */
			
		if( comp_ids ) free( (IGRchar *) comp_ids );

		}  /* end: the object was a symbol header */

	else if( ( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_ACcpx_class_id ) == OM_S_SUCCESS ) ||
	         ( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_AScontents_class_id ) == OM_S_SUCCESS ) ||
	         ( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_ASnode_class_id ) == OM_S_SUCCESS ) )
		{
				
		/* element is an associative element that may own geometry => get its */
		/* components and classify them individually                          */
			
		HPget_components( elem, mod_id, &comp_count, &comp_ids );
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Associative Complex: %d components\n", comp_count );
#		endif

		for( comps = 0; comps < comp_count; comps++ )
			{
			status = HPclassify_located_object( 
					file_id,
					&comp_ids[comps],
					mod_id,
					matrix, 
					matrix_type,
					master_layers,
					num_colors,
					num_shades,
					window,
					z_vector );
					
			if( status == HS_E_PltFlWrtErr ) break;
			}
			
		/* free array of component GRid's */
			
		if( comp_ids ) free( (IGRchar *) comp_ids );

		}  /* end: object was an associative complex */

	else if( om$is_ancestry_valid( 
		subclassid   = elem_classid,
		superclassid = OPP_EMScomposite_class_id ) == OM_S_SUCCESS )
		{
				
		/* EMScomposite is an ancestor */
		/* The object is a solid, composite surface or composite curve. */
			
		if ( om$is_ancestry_valid( subclassid = elem_classid,
						superclassid = OPP_GRcompcurve_class_id ) == OM_S_SUCCESS )
			comp_type = CURVE;
		else if ( om$is_ancestry_valid( subclassid = elem_classid,
						superclassid = OPP_EMScompsurf_class_id ) == OM_S_SUCCESS )
			comp_type = SURFACE;
		else
			return( status );

		/* get the components of this composite and process */
		/* them individually */
				
		HPget_components( elem, mod_id, &comp_count, &comp_ids );
				
#		if DEBUG_LOCATE
		if( comp_type == CURVE )
			fprintf( stderr, "      Composite curve: %d components\n", comp_count );
		else
			fprintf( stderr, "      Composite surface/solid: %d components\n", comp_count );
#		endif

		for( comps=0; comps<comp_count; comps++ )
			{
			status = HPclassify_located_object( 
					file_id,
					&comp_ids[comps], 
					mod_id,
		                        matrix, 
		                        matrix_type,
		                        master_layers,
		                        num_colors,
		                        num_shades,
		                        window,
		                        z_vector );
		                        
		        if( status == HS_E_PltFlWrtErr ) break;
			}

		/* free array of component GRid's */
		
		if( comp_ids ) free( (IGRchar *) comp_ids );

		}  /* end: EMSabscomp is an ancestor */

	else if( om$is_ancestry_valid(
			subclassid   = elem_classid,
			superclassid = OPP_EMSsurface_class_id ) == OM_S_SUCCESS )
		{
				
		/* EMSsurface is an ancestor */
		/* The object is a surface */
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Surface\n" );
#		endif

		HPget_surface_id( elem );

		HPwrite_surface( 
				elem, 
				&matrix_type,
				matrix, 
				mod_id,
				(IGRint)0,
				(struct HSplot_info *)(NULL) );

		}  /* end: EMSsurface is an ancestor */

	else if( om$is_ancestry_valid(
			subclassid   = elem_classid,
			superclassid = OPP_GRbspline_class_id ) == OM_S_SUCCESS )
		{
				
		/* GRbspline is an ancestor => element is wireframe */
			
		if( om$is_ancestry_valid(
				subclassid   = elem_classid,
				superclassid = OPP_GRpoint_class_id ) == OM_S_SUCCESS )
			{
					
			/* GRpoint is an ancestor */
			/* create sort record for point */
				
#			if DEBUG_LOCATE
			fprintf( stderr, "      Point\n" );
#			endif

			}  /* end: GRpoint is an ancestor */

		else
			{
					
			/* The object is a curve and not the fence */
			/* object =>  create sort record */
				
#			if DEBUG_LOCATE
			fprintf( stderr, "      Curve\n" );
#			endif

			HPwrite_curve( 
					elem, 
					&matrix_type,
					matrix, 
					mod_id,
					(struct HSplot_info *)(NULL) );

			}  /* end: element is a curve */

		}  /* end: GRbspline is an ancestor */

	else if( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_GRtext_class_id ) == OM_S_SUCCESS )
		{
				
		/* GRtext is an ancestor => do nothing (because output */
		/* is always planar) */
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Text\n" );
#		endif
		}  /* end: GRtext is an ancestor */

	else if( om$is_ancestry_valid( 
			subclassid   = elem_classid,
			superclassid = OPP_EMSmassprop_class_id ) == OM_S_SUCCESS )
		{
				
		/* EMSmassprop is an ancestor => do nothing */
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      EMSmassprop\n" );
#		endif
		}  /* end: EMSmassprop is an ancestor */

	else if( (elem_classid == OPP_GRreffile_class_id) ||
		 (elem_classid == OPP_GRdvattach_class_id) )
		{
				
		/* the element is a reference file or drawing view attachment */
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Reference File/Drawing View Attachment\n" );
#		endif
		}  /* end:  element is a reference file */

	 else
		{
		/* this element is unclassifiable */
			
#		if DEBUG_LOCATE
		fprintf( stderr, "      Unclassifiable object\n" );
#		endif
		}

	return( status );
	}  /* HPclassify_located_objects */

end implementation Root;
