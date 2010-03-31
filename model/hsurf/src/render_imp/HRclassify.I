
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

 
class implementation Root;
 
#define CHECK_RETURN_CODES 1
#define DEBUG_LOCATE       0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"

#include <sys/types.h>
#include <sys/stat.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "godef.h"
#include "gr.h"

#include "bs.h"

#include "msdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpgraphics.h"

#include "hstexmacros.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hstiler.h"
#include "hsurferrpriv.h"
#include "HSfem_spt.h"

#include "hsmacdef.h"
#include "hsmacros.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_render.h"

/*------------------------------------
 *  for function
 *     HSoutside_z_range
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------------
 *  for functions
 *     HStexture_file_not_found
 *     HStexture_file_save_as_output_file
 */
 
%safe
#include "HSpr_co_func.h"
%endsafe

/*----------------------------------*/


%safe
/*
 *  Prototype declaration for static functions
 */


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

/* HRclassify.I */
static IGRboolean HRis_solid_near_z_clipped __((
			   struct GRid *elem, 
			     IGRmatrix matrix, 
			      IGRshort matrix_type, 
				IGRint *master_layers));
				
static IGRboolean HRis_a_surface_transparent __((
				IGRint count, 
			   struct GRid *ids));
			   
static void HRbuild_surface_record __((
			   struct GRid *elem, 
			     IGRmatrix matrix, 
			      IGRshort matrix_type, 
				IGRint *master_layers, 
			    IGRboolean dont_cull));
			    


#if defined(__cplusplus)
}
#endif


#undef __


%endsafe

from GRgraphics import GRgetrang;
from GRvg       import GRgenabsg;
from GRvg       import GRgetsymb;
from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRowner    import GRget_matrix;


/* Class-id's Needed For Element Classification */
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_GRflxown_class_id;
extern OMuword OPP_GRclhdr_class_id;
extern OMuword OPP_GRsmhdr_class_id;
extern OMuword OPP_GRsmdfhdr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_ACcpx_class_id;
extern OMuword OPP_AScontents_class_id;
extern OMuword OPP_ASnode_class_id;
extern OMuword OPP_EMSmassprop_class_id;


/* External HSURF functions */
/*
extern struct HRsurface_record *HRalloc_surface_record();
extern struct HRenv_record     *HRget_environment_info();
extern struct HRtexture_list   *HRalloc_texture_list();
extern void                    HRget_surface_range();
extern void                    HRbucket_sort_surface();
extern void                    HRopen_texture_file();
*/

#define IS_A_SUBCLASS( sclass, pclass )  \
	(om$is_ancestry_valid( subclassid = sclass, superclassid = pclass ) == OM_S_SUCCESS)

/*--- HRis_solid_near_z_clipped -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRis_solid_near_z_clipped( struct GRid *elem,
						       IGRmatrix matrix,
							IGRshort matrix_type,
							  IGRint *master_layers )
#else
	static IGRboolean HRis_solid_near_z_clipped( elem, matrix, matrix_type, master_layers )

	struct GRid *elem;
	IGRmatrix   matrix;
	IGRshort    matrix_type;
	IGRint      *master_layers;
#endif

/*
DESCRIPTION
	This function determines whether a solid is going to be near Z clipped
	by getting the range of the solid and comparing it with the Z-min of the
	active window's clipping range.  If the solid is going to be near Z clipped,
	TRUE is returned, otherwise FALSE is returned.

HISTORY
	S.P. Rogers  11/30/89  Creation Date
*/

	{
	IGRint              sts;
	IGRlong             msg;
	IGRboolean          apply_mat;
	IGRdouble           zmin;
	IGRdouble           range[6];
	struct HRenv_record *env;

	/* get the environment for this solid so we will have access to its clipping range */
	env = HRget_environment_info( elem->osnum, matrix, matrix_type, master_layers );

	apply_mat = 1;
	sts = om$send( msg      = message GRgraphics.GRgetrang( &msg, (IGRshort *) &matrix_type, matrix,
	                                                        &apply_mat, range ),
	               targetid = elem->objid,
	               targetos = elem->osnum,
	               senderid = NULL_OBJID );

	
	   OM_ERRCHK( sts, "HRis_solid_near_z_clipped: GRget_rang send failed" );
	   MSG_ERRCHK( msg, "HRis_solid_near_z_clipped: GRget_rang failed" );

	if ( active_window->perspective )
	   zmin = (env->clip_range[2] - active_window->dit_clip_range[2]) /
		  (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]);
	else
	   zmin = env->clip_range[2];

	return( HSoutside_z_range( TRUE, zmin, range ) );

	}  /* HRis_solid_near_z_clipped */



/*--- HRis_a_surface_transparent ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRboolean HRis_a_surface_transparent( IGRint count,
						 struct GRid *ids )
#else
	static IGRboolean HRis_a_surface_transparent( count, ids )

	IGRint       count;
	struct GRid *ids;
#endif

/*
DESCRIPTION
	This function determines whether the surfaces from a solid shouldn't
	be culled based on their transparencies.  If any of the surfaces of a
	solid are transparent, then none of the surfaces should be culled because
	back facing facets might be seen.

HISTORY
	S.P. Rogers  11/28/89  Creation Date
*/

	{
	IGRint    i;
	IGRint    trans_mode;
	IGRdouble act_trans, elem_trans;

	hs$get_symbology_modes( trans_mode = &trans_mode );

	if ( trans_mode == HS_MODE_ACTIVE )
	   {
	   /* check the active transparency */
	   hs$get_active_shading_symb( transparency = &act_trans );
	   return( act_trans > 0.0 );
	   }

	/* check the transparency of each surface of the solid */
	for ( i = 0; i < count; i++ )
	   {
	   hs$get_element_shading_symb( objid        = ids[i].objid,
	                                osnum        = ids[i].osnum,
	                                transparency = &elem_trans );

	   if ( elem_trans > 0.0 )
	      return( TRUE );
	   }

	return( FALSE );

	}  /* HRis_a_surface_transparent */


/*---- HRget_components -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRget_components( struct GRid *elem,
				    IGRint *num_components,
			       struct GRid **comp_ids )
#else
	void HRget_components( elem, num_components, comp_ids )

	struct GRid *elem;
	IGRint      *num_components;
	struct GRid **comp_ids;
#endif

/*
DESCRIPTION
	This function gets the components owned by an object of class GRowner.
	It returns the components in an array that it has malloced so the
	caller is responsible for freeing the array when he is through with it.

HISTORY
	S.P. Rogers  02/03/88  Creation Date
*/

	{
	IGRlong         sts;
	IGRlong         msg;
	IGRint          buf_size;
	IGRint          size;
	IGRint          nret;
	struct GRmd_env master_env;

	/* get the number of components */
	*num_components = 0;
	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message GRowner.GRget_number_components( &msg,
	                                                                   num_components ),
	               senderid = NULL_OBJID,
	               targetid = elem->objid,
	               targetos = elem->osnum );

	   OM_ERRCHK( sts, "HRget_components: GRget_number_components send failed" );
	   MSG_ERRCHK( msg, "HRget_components: GRget_number_components failed" );

	/* allocate array for component ids */
	buf_size = *num_components;
	*comp_ids = (struct GRid *) malloc( *num_components * sizeof( struct GRid ) );

	/* get the current module envrionment */
	size = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = &msg,
	                   sizbuf = &size,
	                   buffer = &master_env,
	                   nret   = &nret );

	   MSG_ERRCHK( msg, "HRget_components: gr$get_module_env failed" );

	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message GRowner.GRget_components( &msg,
	                                                            &master_env,
	                                                            *comp_ids,
	                                                            buf_size,
	                                                            num_components,
	                                                            0, 99999 ),
	               senderid = NULL_OBJID,
	               targetid = elem->objid,
	               targetos = elem->osnum );

	   OM_ERRCHK( sts, "HRget_components: GRget_components send failed" );
	   MSG_ERRCHK( msg, "HRget_components: GRget_components failed" );

	}  /* HRget_components */


/*---- HRbuild_surface_record -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRbuild_surface_record( struct GRid *elem,
					      IGRmatrix matrix,
					       IGRshort matrix_type,
						 IGRint *master_layers,
					     IGRboolean dont_cull )
#else
	static void HRbuild_surface_record( elem, matrix, matrix_type, master_layers, dont_cull )

	struct GRid          *elem;
	IGRmatrix            matrix;
	IGRshort             matrix_type;
	IGRint               *master_layers;
	IGRboolean           dont_cull;
#endif

/*
DESCRIPTION
	This function allocates and initializes a sort record for a new element.
	It also adds the sort record to the array of buckets used for sorting.

	If 'dont_cull' is TRUE, then the surface comes from a solid that has at
	least one transparent surface and should not be culled.

HISTORY
	S.P. Rogers  02/03/88  Creation Date
*/

	{
	IGRlong                          sts;
	IGRlong                          msg;
	IGRchar                          *absgeom;
	IGRdouble                        range[6];
	IGRuchar                 tex_orient;
	IGRushort                tex_index;
	IGRint                           elem_finish;
	IGRdouble                        elem_trans;
	IGRdouble                        elem_diff_reflect, elem_spec_reflect;
	struct IGRbsp_surface            *surf;
	struct HRsurface_record          *surf_rec;
	struct HRenv_record              *env;
	struct GRsymbology               symb;
	struct HRspecial_rendering_parms *rend_parms;
	IGRchar                          filename[300], opened_name[300];
	struct HRtexture_list            *texture;
	int                              fp;
	IGRuchar                 red, green, blue;
#ifdef CLIX
	struct statl                     stbuf_texture, stbuf_output;
#else
	struct stat                      stbuf_texture, stbuf_output;
#endif

	/* get the layer of this element */
	sts = om$send( mode     = OM_e_wrt_object,
	               msg      = message GRvg.GRgetsymb( &msg, &symb ),
	               targetid = elem->objid,
	               targetos = elem->osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "HRbuild_surface_record:  GRvg.GRgetsymb send failed" );
	   MSG_ERRCHK( msg, "HRbuild_surface_record:  GRvg.GRgetsymb failed" );

	env = HRget_environment_info( elem->osnum, matrix, matrix_type, master_layers );

	/* make sure element is on a displayed layer */
	if ( ( (1 << (symb.level % 32) ) & env->layers[symb.level >> 5] ) )
	   {
	   /* get the abstract geometry of the element */
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message GRvg.GRgenabsg( &msg,
	                                                     (IGRshort *) &matrix_type,
	                                                     matrix,
	                                                     &absgeom ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = env->osnum );

	      OM_ERRCHK( sts, "HRbuild_surface_record:  GRvg.GRgenabsg send failed" );
	      MSG_ERRCHK( msg, "HRbuild_surface_record:  GRvg.GRgenabsg failed" );

	   /* get the range of the element in viewing coordinates */
	   surf = (struct IGRbsp_surface *) absgeom;

	   HRget_dit_range( surf->u_num_poles * surf->v_num_poles,
	                    surf->poles,
	                    (surf->rational) ? surf->weights : NULL,
	                    range );

	   if ( (range[0] > rendering_globals.source_x_dits) ||
	        (range[1] > rendering_globals.source_y_dits) ||
	        (range[3] < 0.0) || (range[4] < 0.0) )
	      {

	      /* surface lies entirely outside of the   */
	      /* window = > we should get rid of it now */
	      return;
	      }

	   /* allocate and initialize sort record */
	   surf_rec = HRalloc_surface_record();

	   surf_rec->objid             = elem->objid;
	   surf_rec->env               = env;
	   surf_rec->resorted_by_tiler = FALSE;
	   surf_rec->dont_cull         = dont_cull;

	   /* get the rendering attributes of this surface */
	   hs$get_element_shading_symb( objid        = surf_rec->objid,
	                                osnum        = surf_rec->env->osnum,
	                                finish       = &elem_finish,
	                                spec_refl    = &elem_spec_reflect,
	                                diff_refl    = &elem_diff_reflect,
	                                transparency = &elem_trans,	
	                                tex_orient   = &tex_orient,
	                                tex_index    = &tex_index );

	   rend_parms = &surf_rec->rend_parms;

	   rend_parms->finish = elem_finish;

	   rend_parms->spec_refl = (elem_spec_reflect * 0x8000 + 0.5);

	   rend_parms->diff_refl = (elem_diff_reflect * 0x8000 + 0.5);

	   rend_parms->transparency = (elem_trans * 0x8000 + 0.5);

	   rend_parms->opacity = 0x8000 - rend_parms->transparency;

	   rend_parms->texture_orientation = tex_orient;
	   rend_parms->surface_texture = NULL;

	   if ( tex_index != 0 )
	      {
	      hs$retrieve_texture_file( index = tex_index, filename = filename, mod_osnum = surf_rec->env->osnum );

	      /* see if this texture is in the texture list already */
	      texture = rendering_globals.texture_list;
	      while ( texture )
	         {
	         if ( strcmp( filename, texture->Fname ) == 0 )
	            break;
	         texture = texture->next;
	         }

	      if ( ! texture )
	         {
	         /* texture isn't in the list already */
	         texture = HRalloc_texture_list();
	         strcpy( texture->Fname, filename );
	         texture->next = rendering_globals.texture_list;
	         rendering_globals.texture_list = texture;

	         HRopen_texture_file( filename, &fp, opened_name );
	         if ( fp == -1 )
	            {
	            /* couldn't open texture file => error */
	            HStexture_file_not_found( filename );
	            texture->found = FALSE;
	            }
	         else
	            {
	            texture->found = TRUE;
	            if ( rendering_globals.output_file[0] != '\0' )
	               {
#ifdef CLIX
	               statl( opened_name, &stbuf_texture );
	               statl( rendering_globals.output_file, &stbuf_output );
#else
	               stat( opened_name, &stbuf_texture );
	               stat( rendering_globals.output_file, &stbuf_output );
#endif
	               if ( (stbuf_texture.st_ino == stbuf_output.st_ino) &&
	                    (stbuf_texture.st_dev == stbuf_output.st_dev) )
	                  {
	                  HStexture_file_same_as_output_file( filename );
	                  texture->found = FALSE;
	                  }
	               }

	            close( fp );
	            }
	         }

	      if ( texture->found )
	         rend_parms->surface_texture = texture;

	      }

	   if ( rend_parms->surface_texture != NULL )
	      rend_parms->transparency = 0x0000;  /* no transparent surfaces with texture */

	   /* MOD object color with the number of colors to get the */
	   /* base color of the object in the current configuration */
	   if ( symb.display_attr.color != 0 )
	      {
	      rend_parms->color = symb.display_attr.color % rendering_globals.num_colors;
	      if ( rend_parms->color == 0 )
	         rend_parms->color = rendering_globals.num_colors;
	      }
	   else
	      rend_parms->color = 0;

	   if ( rendering_globals.use_rgb )
	      {
	      hs$get_element_shading_symb( objid = surf_rec->objid,
	                                   osnum = surf_rec->env->osnum,
	                                   red   = &red,
	                                   green = &green,
	                                   blue  = &blue );

	      rend_parms->red = (red == 0) ? 0 : red * 0x0080 + 0x0040;
	      rend_parms->green = (green == 0) ? 0 : green * 0x0080 + 0x0040;
	      rend_parms->blue = (blue == 0) ? 0 : blue * 0x0080 + 0x0040;
	      }
	   else
	      {
	      rend_parms->red = rendering_globals.red[rend_parms->color] * 0x0080;
	      if ( rend_parms->red != 0 )
	         rend_parms->red += 0x0040;  /* only add one-half for rounding if not zero */
	      rend_parms->green = rendering_globals.green[rend_parms->color] * 0x0080;
	      if ( rend_parms->green != 0 )
	         rend_parms->green += 0x0040;  /* only add one-half for rounding if not zero */
	      rend_parms->blue = rendering_globals.blue[rend_parms->color] * 0x0080;
	      if ( rend_parms->blue != 0 )
	         rend_parms->blue += 0x0040;  /* only add one-half for rounding if not zero */
	      }

	   /* add surface to sort structure */
	   HRbucket_sort_surface( surf_rec, (IGRint) range[0] );

	   }  /* end: if ( element on displayed layer ) */

	}  /* HRbuild_surface_record */


/*---- HRclassify_located_object -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRclassify_located_object( struct GRid *elem,
					  IGRmatrix matrix,
					   IGRshort matrix_type,
					     IGRint *master_layers,
					 IGRboolean near_z_clip_possible )
#else
	void HRclassify_located_object( elem, matrix, matrix_type,
		                        master_layers, near_z_clip_possible )

	struct GRid          *elem;
	IGRmatrix            matrix;
	IGRshort             matrix_type;
	IGRint               *master_layers;
	IGRboolean           near_z_clip_possible;
#endif

/*
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
	                                           HRclassify_located_object recursively
	                                           on them

	   Symbol Header:                          Build a new environment matrix for
	                                           the symbol, get each component and
	                                           call HRclassify_located_object recursively

HISTORY
	S.P. Rogers  02/03/88  Creation Date
*/

	{
	OMuword         elem_classid;
	IGRshort        comp_matrix_type;
	IGRlong         sts;
	IGRlong         msg;
	IGRint          comp_count;
	IGRint          comps;
	IGRmatrix       comp_matrix;
	struct GRid     *comp_ids;
	IGRboolean      dont_cull;


#if DEBUG_LOCATE
	{
	IGRchar classname[50];

	om$get_classname( osnum = elem->osnum,
	                  objid = elem->objid,
	                  classname = classname );

	fprintf( stderr, "   Classifying %d:%d - %s\n", elem->objid, elem->osnum, classname );
	}
#endif

	/* get the classid of this object */
	sts = om$get_classid( osnum     = elem->osnum,
	                      objid     = elem->objid,
	                      p_classid = &elem_classid );

	if ( ( IS_A_SUBCLASS( elem_classid, OPP_GRflxown_class_id ) ) ||
	     ( elem_classid == OPP_GRclhdr_class_id ) ||
	     ( elem_classid == OPP_GRsmdfhdr_class_id ) )

	   {
	   /* The located object is a flexible grouping (graphic group), cell header, */
	   /* or a symbol definition header => get each component and classify them   */
	   /* individually because they can be nested.                                */
	   HRget_components( elem, &comp_count, &comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Cell/Symbol definition header: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      HRclassify_located_object( &comp_ids[comps], matrix, matrix_type,
	                                 master_layers, near_z_clip_possible );
	      }  /* end: for ( comps < comp_count ) */

	   /* free array of component GRid's */
	   if ( comp_ids )
	      free( (IGRchar *) comp_ids );
	   }  /* end: object was a grouping object */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_GRsmhdr_class_id ) )
	   {
	   /* The located object is a symbol header => build a new environment matrix */
	   /* for the objects in the symbol, get each component and classify them     */
	   /* inidividually because they can be nested                                */
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message GRowner.GRget_matrix( &msg,
	                                                           (IGRshort *) &matrix_type,
	                                                           matrix,
	                                                           &comp_matrix_type,
	                                                           comp_matrix ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->osnum );

	      OM_ERRCHK( sts, "HRclassify_located_object: GRowner.GRget_matrix send failed" );
	      MSG_ERRCHK( msg, "HRclassify_located_object: GRowner.GRget_matrix failed" );

	   HRget_components( elem, &comp_count, &comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Symbol header: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      HRclassify_located_object( &comp_ids[comps], comp_matrix, comp_matrix_type,
	                                 master_layers, near_z_clip_possible );
	      }  /* end: for ( comps < comp_count ) */

	   /* free array of component GRid's */
	   if ( comp_ids )
	      free( (IGRchar *) comp_ids );

	   }  /* end: the object was a symbol header */

	else if ( (IS_A_SUBCLASS( elem_classid, OPP_ACcpx_class_id ) ) ||
	          (IS_A_SUBCLASS( elem_classid, OPP_AScontents_class_id ) ) ||
	          (IS_A_SUBCLASS( elem_classid, OPP_ASnode_class_id ) ) )
	   {
	   /* element is an associative element that can own geometry => get */
 	   /* its components and classify them individually                  */
	   HRget_components( elem, &comp_count, &comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Associative Complex: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      HRclassify_located_object( &comp_ids[comps], matrix, matrix_type,
	                                 master_layers, near_z_clip_possible );
	      }  /* end: for ( comps < comp_count ) */

	   /* free array of component GRid's */
	   if ( comp_ids )
	      free( (IGRchar *) comp_ids );

	   }  /* end: object was an associative complex */
	else if ( IS_A_SUBCLASS( elem_classid, OPP_EMScomposite_class_id ) )
	   {
	   /* EMScomposite is an ancestor */

	   if ( IS_A_SUBCLASS( elem_classid, OPP_EMSmassprop_class_id ) )
	      return;  /* object is a mass properties object => ignore it */

	   /* The object is a solid, composite surface or composite curve. */
	   if ( IS_A_SUBCLASS( elem_classid, OPP_EMScompsurf_class_id ) )
	      {
	      /* The object is a solid or composite surface */
	      /* get the components of this composite and process them individually */
	      HRget_components( elem, &comp_count, &comp_ids );
#if DEBUG_LOCATE
	      fprintf( stderr, "      Composite surface/solid: %d components\n", comp_count );
#endif

	      if ( IS_A_SUBCLASS( elem_classid, OPP_EMSsolid_class_id ) )
	         {
	         /* the object is a solid => determine if culling shouldn't be attempted */
	         /* for any of its components                                            */
	         dont_cull = (near_z_clip_possible) &&
	                     HRis_solid_near_z_clipped( elem, matrix, matrix_type, master_layers );
	         if ( ! dont_cull )
	            dont_cull = HRis_a_surface_transparent( comp_count, comp_ids );
	         }
	      else
	         dont_cull = FALSE;

	      for ( comps = 0; comps < comp_count; comps++ )
	         {
	         HRbuild_surface_record( &comp_ids[comps], matrix, matrix_type,
	                                 master_layers, dont_cull );
	         }  /* end: for ( comps < comp_count ) */

	      /* free array of component GRid's */
	      if ( comp_ids )
	         free( (IGRchar *) comp_ids );

	      }  /* end: if */

	   }  /* end: EMSabscomp is an ancestor */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_EMSsurface_class_id ) )
	   {
   	   /* EMSsurface is an ancestor */
	   /* The object is a surface so build a sort record for it */
#if DEBUG_LOCATE
	   fprintf( stderr, "      Surface\n" );
#endif
	   HRbuild_surface_record( elem, matrix, matrix_type, master_layers, FALSE );
	      
	   }  /* end: EMSsurface is an ancestor */


}  /* HRclassify_located_objects */

end implementation Root;
