
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

 
class implementation Root;
 
#define CHECK_RETURN_CODES 1

#define DEBUG_LOCATE       0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <alloca.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"

#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "dpstruct.h"

#include "godef.h"
#include "gr.h"
#include "go.h"

#include "bs.h"
#include "bsvalues.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemsg.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "VEpr_driver.h"

from GRgraphics import GRcopy;
from GRvg       import GRgenabsg;
from GRvg       import GRgetprops;
from GRvg       import GRchgprops;
from GRvg       import GRgetsymb;
from GRvg       import GRchglevel;
from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRowner    import GRget_matrix;


/* External - global variables */
extern struct GRmd_env           VEmaster_env;
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;


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
extern OMuword OPP_GRpart_class_id;
extern OMuword OPP_GRsmdfhdr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_ACcpx_class_id;
extern OMuword OPP_AScontents_class_id;
extern OMuword OPP_ASnode_class_id;
extern OMuword OPP_GRdvattach_class_id;
extern OMuword OPP_EMSmassprop_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_EMSasectvw_class_id;

#define IS_A_SUBCLASS( sclass, pclass )  \
	(om$is_ancestry_valid( subclassid = sclass, superclassid = pclass ) == OM_S_SUCCESS)


/*---- VEget_components -------------------------------------------------*/

void VEget_components( elem, num_components, comp_ids )

	struct GRid *elem;
	IGRint      *num_components;
	struct GRid *comp_ids;

/*
NAME
	VEget_components

DESCRIPTION
	This function gets the components owned by an object of class GRowner.
	If *num_components is ZERO, then the number of components will be
	determined.  If comp_ids is not NULL, then the component ids are
	determined.  A typical calling sequence for this function is:

	   VEget_components( elem, &num, NULL );  -- get number
	   -- allocate space for the component ids
	   VEget_components( elem, &num, ids );  -- get ids
	
PARAMETERS
	elem (IN) - the element whose components are to be gotten
	num_components (IN/OUT) - number of components, if non-zero it will
	                          not be changed
	comp_ids (OUT) - array of component ids, must be allocated by caller;
	                 if NULL, only the number of components will be
	                 returned

GLOBALS USED
	VEmaster_env

HISTORY
	02/03/88    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong sts, msg;

	if ( (*num_components) == 0 )
	   {
	   /* get the number of components */
	   sts = om$send( msg      = message GRowner.GRget_number_components( &msg,
	                                                                      num_components ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->osnum );

	      OM_ERRCHK( sts, "VEget_components: GRget_number_components send failed" );
	      MSG_ERRCHK( msg, "VEget_components: GRget_number_components failed" );
	   }

	if ( comp_ids )
	   {
	   sts = om$send( msg      = message GRowner.GRget_components( &msg,
	                                                               &VEmaster_env,
	                                                               comp_ids,
	                                                               *num_components,
	                                                               num_components,
	                                                               0, 99999 ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->osnum );

	      OM_ERRCHK( sts, "VEget_components: GRget_components send failed" );
	      MSG_ERRCHK( msg, "VEget_components: GRget_components failed" );
	   }

	}  /* VEget_components */


/*--- VEcopy_text --------------------------------------------------------------*/

static void VEcopy_text(	OM_S_OBJID text_id,
				OMuword    text_os,
				IGRdouble  *matrix,
				IGRshort   matrix_type )

/*
NAME
	VEcopy_text (static)

DESCRIPTION
	This function copies a text object to the text output level in
	the master file.

PARAMETERS
	text_id (IN) - object id of the text
	text_os (IN) - object space number of the text
	matrix (IN) - matrix used in building environment for the copy
	matrix_type (IN) - the type of 'matrix'

GLOBALS USED
	VEmaster_env

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong         sts, msg;
	GRobjid         new_id;   
	struct GRmd_env text_env;

	text_env.md_id.osnum = text_os;
	ex$get_modid( mod_osnum = text_os, mod_id = &text_env.md_id.objid );

	text_env.md_env.matrix_type = matrix_type;
	memcpy( text_env.md_env.matrix, matrix, sizeof( IGRdouble ) * 16 );

	sts = om$send( msg = message GRgraphics.GRcopy( &msg, &text_env, &VEmaster_env, &new_id ),
	               targetid = text_id, targetos = text_os, senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEcopy_text: GRgraphics.GRcopy send failed" );
	   MSG_ERRCHK( msg, "VEcopy_text: GRgraphics.GRcopy failed" );

	sts = om$send( msg = message GRvg.GRchglevel( &msg, (IGRshort *) &VEoutput_data.text_level ),
	               targetid = new_id, targetos = VEmaster_env.md_id.osnum, senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEcopy_text: GRvg.GRchglevel send failed" );
	   MSG_ERRCHK( msg, "VEcopy_text: GRvg.GRchglevel failed" );

	}  /* VEcopy_text */


/*--- VEturn_off_ref_file_display ----------------------------------------------*/

static void VEturn_off_ref_file_display( ref_grid )

	struct GRid *ref_grid;

/*
NAME
	VEturn_off_ref_file_display

DESCRIPTION
	This function turns off the display of a reference file if it is
	attached directly to the master file (i.e., nested attachments 
	will not be turned off ).  Nested files won't display, however,
	because the top level attachment will be turned off.

PARAMETERS
	ref_grid (IN) - the GRid of the ref. file

GLOBALS USED
	VEmaster_env
	VEexec_status

HISTORY
	xx/xx/xx   S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong  sts;
	IGRlong  msg;
	IGRshort action;
	IGRshort clear_mask;

	/* see if reference file attachment is directly to the master file */
	if ( ref_grid->osnum == VEmaster_env.md_id.osnum )
	   {
	   VEexec_status.VEupdate_window = TRUE;

	   /* turn off the display of the reference file */
	   action = 0;  /* clear bits */
	   clear_mask = GRIS_DISPLAYABLE;
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message GRvg.GRchgprops( &msg, &action, &clear_mask ),
	                  senderid = NULL_OBJID,
	                  targetid = ref_grid->objid,
	                  targetos = ref_grid->osnum );

	      OM_ERRCHK( sts, "VEturn_off_ref_file_display: GRchgprops send failed" );
	      MSG_ERRCHK( msg, "VEturn_off_ref_file_display: GRchgprops failed" );
	   }

	}  /* VEturn_off_ref_file_display */


/*--- VEget_object_layer --------------------------------------------*/

static void VEget_object_layer(	OM_S_OBJID objid,
				OMuword    osnum,
				IGRshort   *layer )

/*
NAME
	VEget_object_layer (static)

DESCRIPTION
	Get the symbology structure of an object

PARAMETERS
	objid (IN) - object id of object
	osnum (IN) - object space number of object
	layer (OUT) - layer of object

GLOBALS USED
	none

HISTORY
	02/11/92    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong            sts, msg;
	struct GRsymbology symb;

	sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &symb ),
	               targetid = objid,
	               targetos = osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEget_object_layer:  GRvg.GRgetsymb send failed" );
	   MSG_ERRCHK( msg, "VEget_object_layer:  GRvg.GRgetsymb failed" );

	*layer = symb.level;

	}  /* VEget_object_layer */


/*---- VEbuild_sort_record -------------------------------------------*/

static void VEbuild_sort_record(struct GRid       *elem,
				struct VEenv_info *elem_env,
				IGRmatrix         matrix,
				IGRshort          matrix_type,
				struct GRmd_env   *mod_env,
				OM_S_OBJID        parent_id,
				IGRboolean        from_solid,
				IGRshort          type,
				IGRshort          sym_header_layer )

/*
NAME
	VEbuild_sort_record (static)

DESCRIPTION
	This function allocates and initializes a sort record for a new
	element.  It also adds the sort record to the array of buckets used
	for sorting.

PARAMETERS
	elem (IN) - the element whose sort record is to be built
	elem_env (IN) - the environment of the element, can be NULL
	matrix (IN) - the matrix of the element's environment
	matrix_type (IN) - the type of 'matrix'
	mod_env (IN) - module environment of the element
	parent_id (IN) - the object id of the parent of the element
	from_solid (IN) - flag indicating the element is from a solid
	type (IN) - the type of the element
	sym_header_layer (IN) - the layer of the symbol that owns the element,
	                        should be -1 if the element is not owned by a
	                        symbol

GLOBALS USED
	VEexec_status

HISTORY
	02/03/88    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
        10/02/95    Sikandar Saifullah
           Continue past, on failure of GRgenabsg
*/

	{
	IGRlong               sts;
	IGRlong               msg;
	IGRshort              props;
	IGRint                ii;
	IGRchar               *absgeom;
	struct IGRbsp_curve   *curve;
	struct IGRbsp_surface *surf;
	struct VEsort_record  *sort_rec;
	struct VEenv_info     *env;
	IGRint                comp_count;
	struct GRid           *comp_ids;
	IGRdouble             total_range[6];
	IGRdouble             temp_range[6];
	IGRshort              obj_layer;

	if ( (type == CURVE) || (type == POINT) )
	   {
	   /* see if this curve/point is the result of a previous CHE run */
	   sts = om$send( msg      = message GRvg.GRgetprops( &msg, &props ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->osnum );

	      OM_ERRCHK( sts, "VEbuild_sort_record: GRgetprops send failed" );
	      MSG_ERRCHK( msg, "VEbuild_sort_record: GRgetprops failed" );

	   if ( props & GRIS_VE_CURVE )
	      {
	      VEexec_status.VEprev_output_found = TRUE;
	      return;
	      }
	   }

	if ( sym_header_layer == -1 )
	   VEget_object_layer( elem->objid, elem->osnum, &obj_layer );
	else
	   obj_layer = sym_header_layer;  /* object is from a symbol -> use symbol header's layer */

	if ( elem_env )
	   env = elem_env;
	else
	   {
	   /* don't know environement already => get it */
	   env = VEget_environment_info( elem->osnum, matrix, matrix_type, mod_env, FALSE, NULL );
	   }

	/* make sure element is on a displayed layer */
	if ( ( (1 << (obj_layer % 32) ) & env->layers[obj_layer >> 5] ) )
	   {
	   /* allocate and initialize sort record */
	   sort_rec = (struct VEsort_record *) malloc( sizeof( struct VEsort_record ) );

	   sort_rec->objid     = elem->objid;
	   sort_rec->parent_id = parent_id;
	   sort_rec->type      = type;
	   sort_rec->env       = env;
	   sort_rec->flags     = 0;

	   if ( from_solid )
	      {
	      sort_rec->flags |= SORT_REC_FROM_SOLID;
	      comp_count = 0;
	      VEget_components( elem, &comp_count, (struct GRid *)NULL );
	      comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	      VEget_components( elem, &comp_count, comp_ids );
	      }
	   else
	      {
	      comp_count = 1;
	      comp_ids = elem;
	      }

	   /* get range of element */
	   total_range[XMIN] = total_range[YMIN] = total_range[ZMIN] = MAXDOUBLE;
	   total_range[XMAX] = total_range[YMAX] = total_range[ZMAX] = MINDOUBLE;

	   for ( ii = 0; ii < comp_count; ii++ )
	      {
	      /* get the abstract geometry of the element. On failure continue.*/
	      absgeom = NULL;
	      sts = om$send( msg      = message GRvg.GRgenabsg( &msg,
	                                                        (IGRshort *) &matrix_type,
	                                                        matrix,
	                                                        &absgeom ),
	                     senderid = NULL_OBJID,
	                     targetid = comp_ids[ii].objid,
	                     targetos = sort_rec->env->osnum );

	         OM_ERRCHK( sts, "VEbuild_sort_record:  GRvg.GRgenabsg send failed" );
	         MSG_ERRCHK( msg, "VEbuild_sort_record:  GRvg.GRgenabsg failed" );
	         if (!(1 & sts & msg) || !absgeom)
 	           continue;

	      /* get the range of the element in viewing coordinates */
	      switch ( type )
	         {
	         case SURFACE :

	            surf = (struct IGRbsp_surface *) absgeom;
	            VEget_range( surf->u_num_poles * surf->v_num_poles,
	                         surf->poles,
	                         (surf->rational) ? surf->weights : NULL,
	                         temp_range, TRUE );
	            break;

	         case CURVE : case POINT :

	            curve = (struct IGRbsp_curve *) absgeom;
	            VEget_range( curve->num_poles,
	                         curve->poles,
	                         (curve->rational) ? curve->weights : NULL,
	                         temp_range, TRUE );
	            break;

	         }  /* end: switch */

	      if ( temp_range[XMIN] < total_range[XMIN] )
	         total_range[XMIN] = temp_range[XMIN];
	      if ( temp_range[YMIN] < total_range[YMIN] )
	         total_range[YMIN] = temp_range[YMIN];
	      if ( temp_range[ZMIN] < total_range[ZMIN] )
	         total_range[ZMIN] = temp_range[ZMIN];

	      if ( temp_range[XMAX] > total_range[XMAX] )
	         total_range[XMAX] = temp_range[XMAX];
	      if ( temp_range[YMAX] > total_range[YMAX] )
	         total_range[YMAX] = temp_range[YMAX];
	      if ( temp_range[ZMAX] > total_range[ZMAX] )
	         total_range[ZMAX] = temp_range[ZMAX];

	      }  /* end: for */

	   memcpy( sort_rec->range, total_range, sizeof( IGRdouble ) * 6 );

	   /* add element to sort structure */
	   if ( VEsort_by_min_x( sort_rec ) )
	      {
	      VEexec_status.VEtotal_elems += comp_count;
	      if ( type == SURFACE )
	         (env->num_surfs) += comp_count;
	      else
	         (env->num_curves) += comp_count;
	      }

	   }  /* end: if ( element on displayed layer ) */

	}  /* VEbuild_sort_record */


/*---- VEclassify_located_object -------------------------------------------*/

#if defined(__STDC__)
void VEclassify_located_object( struct GRid       *elem,
				struct VEenv_info *elem_env,
				IGRmatrix         matrix,
				IGRshort          matrix_type,
				struct GRmd_env   *mod_env,
				struct GRmd_env   *batch_env,
				IGRboolean        batch_copy,
				struct GRid       *fence_grid,
				IGRshort          sym_header_layer )
#else
void VEclassify_located_object( elem, elem_env,
	                        matrix, matrix_type, mod_env,
	                        batch_env, batch_copy, fence_grid, sym_header_layer )

	struct GRid       *elem;
	struct VEenv_info *elem_env;
	IGRmatrix         matrix;
	IGRshort          matrix_type;
	struct GRmd_env   *mod_env;
	struct GRmd_env   *batch_env;
	IGRboolean        batch_copy;
	struct GRid       *fence_grid;
	IGRshort          sym_header_layer;
#endif

/*
NAME
	VEclassify_located_object

DESCRIPTION
	This function classifies a located object and performs the functions
	necessary to process the object.

	Following is a list of classes and the functions performed:

	   Composite Surface/Curve or Solid:  Get each component and
	                                      create sort records for them

	   Surface, Curve, or Point:          Create a sort record for it

	   Reference File Header:             Turn off the display of the ref.
	                                      file if required by user

	   Graphic Group or Cell:             Get each component and call
	                                      VEclassify_located_object
	                                      recursively on them

	   Symbol Header:                     Build a new environment matrix
	                                      for the symbol, get each
	                                      component and call
	                                      VEclassify_located_object
	                                      recursively

PARAMETERS
	elem (IN) - the element whose sort record is to be built
	elem_env (IN) - the environment of the element, can be NULL
	matrix (IN) - the matrix of the element's environment
	matrix_type (IN) - the type of 'matrix'
	mod_env (IN) - module environment of the element
	batch_env (IN) - module environment for invisible batch object space,
	                 if doing a batch submission
	batch_copy (IN) - TRUE, if doing a batch submission
	fence_grid (IN) - object id of the fence
	sym_header_layer (IN) - the layer of the symbol that owns the element,
	                        should be -1 if the element is not owned by a
	                        symbol

GLOBALS USED
	VEexec_parms	
	VEoutput_data	
	OPP_IGEwinsup_class_id	
	OPP_GRcompcurve_class_id	
	OPP_EMScompsurf_class_id	
	OPP_GRbspline_class_id	
	OPP_GRtext_class_id	
	OPP_GRpoint_class_id	
	OPP_GRreffile_class_id	
	OPP_GRflxown_class_id	
	OPP_GRclhdr_class_id	
	OPP_GRsmhdr_class_id	
	OPP_GRsmdfhdr_class_id	
	OPP_EMSsurface_class_id	
	OPP_EMScomposite_class_id	
	OPP_ACcpx_class_id	
	OPP_AScontents_class_id	
	OPP_ASnode_class_id	
	OPP_GRdvattach_class_id	
	OPP_EMSmassprop_class_id	
	OPP_EMSsolid_class_id	
	OPP_SKmgr_class_id

HISTORY
	02/03/88    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
	06/17/92    S.P. Rogers
	   Modified to process profiles (SKmgr objects)
	09/04/92    S.P. Rogers
	   Modified to process section view objects (EMSasectvw)
*/

	{
	OMuword            elem_classid, comp_classid;
	IGRshort           comp_type;
	IGRshort           comp_matrix_type;
	IGRboolean         is_solid;
	IGRlong            sts;
	IGRlong            msg;
	IGRint             comp_count;
	IGRint             comps;
	IGRmatrix          comp_matrix;
	struct GRid        *comp_ids;


#if DEBUG_LOCATE
	{
	IGRchar classname[50];

	sts = om$get_classname( osnum = elem->osnum,
	                        objid = elem->objid,
	                        classname = classname );

        if ( 1 & sts )
	   fprintf( stderr, "   Classifying %d:%d - %s\n", elem->objid, elem->osnum, classname );
        else
	   fprintf( stderr, "   Classifying %d:%d - ERROR getting class name\n", elem->objid, elem->osnum );

	}
#endif

	/* get the classid of this object */
	sts = om$get_classid( osnum     = elem->osnum,
	                      objid     = elem->objid,
	                      p_classid = &elem_classid );

        if ( !(1 & sts) )
           return;

	if ( ( IS_A_SUBCLASS( elem_classid, OPP_EMSasectvw_class_id ) ) )
	   {
	   /* The located object is a cross section view.  It is an owner of solids */
	   /* that need to be processed.                                            */
	   comp_count = 0;
	   VEget_components( elem, &comp_count, (struct GRid *)NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( elem, &comp_count, comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Cross Section View header: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      /* only process solids owned by the cross section view */
	      sts = om$get_classid( osnum     = comp_ids[comps].osnum,
	                            objid     = comp_ids[comps].objid,
	                            p_classid = &comp_classid );

              if ( !(1 & sts) )
                 continue;

	      if ( IS_A_SUBCLASS( comp_classid, OPP_EMScompsurf_class_id ) )
	         {
	         VEclassify_located_object( &comp_ids[comps], elem_env, matrix, matrix_type, mod_env,
	                                    batch_env, batch_copy, fence_grid, sym_header_layer );
	         }
	      }  /* end: for ( comps < comp_count ) */
	   }
	else if ( ( IS_A_SUBCLASS( elem_classid, OPP_GRflxown_class_id ) ) ||
	          ( elem_classid == OPP_GRclhdr_class_id ) ||
	          ( elem_classid == OPP_GRpart_class_id ) ||
	          ( elem_classid == OPP_GRsmdfhdr_class_id ) )

	   {
	   /* The located object is a flexible grouping (graphic group), cell header, */
	   /* or a symbol definition header => get each component and classify them   */
	   /* individually because they can be nested.                                */
	   comp_count = 0;
	   VEget_components( elem, &comp_count, (struct GRid *)NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( elem, &comp_count, comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Cell/Symbol/Part definition header: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      VEclassify_located_object( &comp_ids[comps], elem_env, matrix, matrix_type, mod_env,
	                                 batch_env, batch_copy, fence_grid, sym_header_layer );
	      }  /* end: for ( comps < comp_count ) */

	   }  /* end: object was a grouping object */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_GRsmhdr_class_id ) )
	   {
	   /* The located object is a symbol header => build a new environment matrix */
	   /* for the objects in the symbol, get each component and classify them     */
	   /* inidividually because they can be nested                                */

	   /* SOs can't be applied to symbols so they must be */
	   /* be ignored if we are outputting SOs             */
	   if ( VEoutput_data.output_curves )
	      {
	      sts = om$send( msg      = message GRowner.GRget_matrix( &msg,
	                                                              (IGRshort *) &matrix_type,
	                                                              matrix,
	                                                              &comp_matrix_type,
	                                                              comp_matrix ),
	                     senderid = NULL_OBJID,
	                     targetid = elem->objid,
	                     targetos = elem->osnum );

	         OM_ERRCHK( sts, "VEclassify_located_object: GRowner.GRget_matrix send failed" );
	         MSG_ERRCHK( msg, "VEclassify_located_object: GRowner.GRget_matrix failed" );

	      /* get the layer of this symbol header because it should */
	      /* be interpreted as the layer of all of its components  */
	      VEget_object_layer( elem->objid, elem->osnum, &sym_header_layer );

	      comp_count = 0;
	      VEget_components( elem, &comp_count, (struct GRid *)NULL );
	      comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	      VEget_components( elem, &comp_count, comp_ids );
#if DEBUG_LOCATE
	      fprintf( stderr, "      Symbol header: %d components\n", comp_count );
#endif
	      for ( comps = 0; comps < comp_count; comps++ )
	        {
	         VEclassify_located_object( &comp_ids[comps], elem_env, comp_matrix, comp_matrix_type, mod_env,
	                                    batch_env, batch_copy, fence_grid, sym_header_layer );
	         }  /* end: for ( comps < comp_count ) */

	      }  /* end: if ( outputing soos ) */
	   else
	      {
	      if ( ! VEexec_status.VEsymbol_found )
	         {
	         ex$message( msgnumb = VE_I_NoSymbols );
	         sleep( 3 );
	         }
	      VEexec_status.VEsymbol_found = TRUE;
	      }

	   }  /* end: the object was a symbol header */

	else if ( (IS_A_SUBCLASS( elem_classid, OPP_ACcpx_class_id ) ) ||
	          (IS_A_SUBCLASS( elem_classid, OPP_AScontents_class_id ) ) ||
	          (IS_A_SUBCLASS( elem_classid, OPP_ASnode_class_id ) ) )
	   {
	   /* element is an associative object that could own geometry => get */
	   /* its components and  classify them individually                  */
	   comp_count = 0;
	   VEget_components( elem, &comp_count, (struct GRid *)NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( elem, &comp_count, comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Associative Complex: %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      VEclassify_located_object( &comp_ids[comps], elem_env, matrix, matrix_type, mod_env,
	                                 batch_env, batch_copy, fence_grid, sym_header_layer );
	      }  /* end: for ( comps < comp_count ) */

	   }  /* end: object was an associative complex */

	else if ( IS_A_SUBCLASS(elem_classid, OPP_SKmgr_class_id) )
	   {
	   /* SKmgr is an ancestor => the object is a profile */
	   /* get its components a classify them              */
	   comp_count = 0;
	   VEget_components( elem, &comp_count, (struct GRid *)NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( elem, &comp_count, comp_ids );
#if DEBUG_LOCATE
	   fprintf( stderr, "      Profile (SKmgr): %d components\n", comp_count );
#endif
	   for ( comps = 0; comps < comp_count; comps++ )
	      {
	      VEclassify_located_object( &comp_ids[comps], elem_env, matrix, matrix_type, mod_env,
	                                 batch_env, batch_copy, fence_grid, sym_header_layer );
	      }  /* end: for ( comps < comp_count ) */

	   }
	else if ( IS_A_SUBCLASS(elem_classid, OPP_EMScomposite_class_id) )
	   {
	   /* EMScomposite is an ancestor */
	   if ( IS_A_SUBCLASS( elem_classid, OPP_EMSmassprop_class_id ) )
	      return;  /* object is a mass properties object => ignore it */

	   /* The object is a solid, composite surface or composite curve. */
	   if ( IS_A_SUBCLASS( elem_classid, OPP_GRcompcurve_class_id ) )
	      comp_type = CURVE;
	   else if ( IS_A_SUBCLASS( elem_classid, OPP_EMScompsurf_class_id ) )
	      comp_type = SURFACE;
	   else
	      return;  /* a composite that isn't made up of curves/surfaces */

	   if ( (comp_type == CURVE) && ( ! VEexec_parms.VEprocessing_wireframe) )
	      return;   /* user wants to ignore wireframe elements */

	   if ( batch_copy )
	      VEcopy_for_batch( elem, elem_classid, matrix, matrix_type, batch_env, TRUE );
	   else
	      {
	      is_solid = IS_A_SUBCLASS( elem_classid, OPP_EMSsolid_class_id );

	      if ( is_solid )
	         {
	         /* make one entry for solid */
#if DEBUG_LOCATE
	         fprintf( stderr, "      Solid\n" );
#endif
	         VEbuild_sort_record( elem, elem_env, matrix, matrix_type, mod_env,
	                              elem->objid, is_solid, comp_type, sym_header_layer );
	         }
	      else
	         {
	         /* get the components of this composite and process them individually */
	         comp_count = 0;
	         VEget_components( elem, &comp_count, (struct GRid *)NULL );
	         comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	         VEget_components( elem, &comp_count, comp_ids );

#if DEBUG_LOCATE
	         if ( comp_type == CURVE )
	            fprintf( stderr, "      Composite curve: %d components\n", comp_count );
	         else
	            fprintf( stderr, "      Composite surface: %d components\n", comp_count );
#endif

	         for ( comps = 0; comps < comp_count; comps++ )
	            {
	            VEbuild_sort_record( &comp_ids[comps], elem_env, matrix, matrix_type, mod_env,
	                                 elem->objid, is_solid, comp_type, sym_header_layer );
	            }  /* end: for ( comps < comp_count ) */

	         }

	      }  /* end: else */

	   }  /* end: EMSabscomp is an ancestor */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_EMSsurface_class_id ) )
	   {
   	   /* EMSsurface is an ancestor */
	   /* The object is a surface so build a sort record for it */
#if DEBUG_LOCATE
	   fprintf( stderr, "      Surface\n" );
#endif
	   if ( batch_copy )
	      VEcopy_for_batch( elem, elem_classid, matrix, matrix_type, batch_env, FALSE );
	   else
	      VEbuild_sort_record( elem, elem_env,
	                           matrix, matrix_type, mod_env,
	                           elem->objid, FALSE, SURFACE, sym_header_layer );
	      
	   }  /* end: EMSsurface is an ancestor */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_GRbspline_class_id ) )
	   {
	   /* GRbspline is an ancestor => element is wireframe */
	   if (! ( VEexec_parms.VEprocessing_wireframe ) )
	      return;   /* user wants to ignore wireframe elements */

	   if ( IS_A_SUBCLASS( elem_classid, OPP_GRpoint_class_id ) )
	      {
	      /* GRpoint is an ancestor */
	      /* create sort record for point */
#if DEBUG_LOCATE
	      fprintf( stderr, "      Point\n" );
#endif
	      if ( batch_copy )
	         VEcopy_for_batch( elem, elem_classid, matrix, matrix_type,
	                           batch_env, FALSE );
	      else
	         VEbuild_sort_record( elem, elem_env,
	                              matrix, matrix_type, mod_env,
	                              elem->objid, FALSE, POINT, sym_header_layer );
	      }  /* end: GRpoint is an ancestor */

	   else if ( ( elem->objid != fence_grid->objid) || ( elem->osnum != fence_grid->osnum ) )
	      {
	      /* The object is a curve and not the fence object =>  create sort record */
#if DEBUG_LOCATE
	      fprintf( stderr, "      Curve\n" );
#endif
	      if ( batch_copy )
	         VEcopy_for_batch( elem, elem_classid, matrix, matrix_type,
	                           batch_env, FALSE);
	      else
	         VEbuild_sort_record( elem, elem_env,
	                              matrix, matrix_type, mod_env,
	                              elem->objid, FALSE, CURVE, sym_header_layer );

	      }  /* end: element is a curve */

	   }  /* end: GRbspline is an ancestor */

	else if ( IS_A_SUBCLASS( elem_classid, OPP_GRtext_class_id ) )
	   {
	   /* GRtext is an ancestor => do nothing (because output is always planar) */
#if DEBUG_LOCATE
	      fprintf( stderr, "      Text\n" );
#endif
	   if ( VEoutput_data.copy_text )
	      VEcopy_text( elem->objid, elem->osnum, matrix, matrix_type );

	   }  /* end: GRtext is an ancestor */

	else if ( (elem_classid == OPP_GRreffile_class_id) ||
	          (elem_classid == OPP_GRdvattach_class_id) )
	   {
	   /* the element is a reference file or drawing view attachment */
#if DEBUG_LOCATE
	   fprintf( stderr, "      Reference File/Drawing View Attachment\n" );
#endif
	   if ( (! batch_copy) && (VEexec_parms.VEturn_ref_files_off) )
	      {
	      VEturn_off_ref_file_display( elem );
	      }  /* end: option is turn off ref. file display */

	   }  /* end:  element is a reference file */

	else
	   {
	   /* this element is unclassifiable */
#if DEBUG_LOCATE
	   fprintf( stderr, "      Unclassifiable object\n" );
#endif
	   }

	}  /* VEclassify_located_objects */

end implementation Root;
