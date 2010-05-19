/*
Author:  dh
Date:  3/6/95
*/

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"

#include "bsparameters.h"
#include "bserr.h"

#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "ve.h"
#include "vedef.h"

#include "go.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#include "GRgetrefrang.h"

#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bscv_copy.h"
#include "bssf_copy.h"
#include "mainvmx.h"


/* External Global Variables */
extern struct VEwindow_info VEwin_info;
extern struct VEexecution_parms VEexec_parms;
extern struct VEtolerance_info VEtolerances;
extern struct VEresults_info VEoutput_data;

/* Static Local Variables */
static IGRdouble i_matrix[4][4];

static IGRdouble active_z;
static IGRdouble dit_clip_range[6];
static IGRdouble world_to_viewport[4][4];
static IGRdouble viewport_to_world[4][4];

/*--- VEtransform_3D_points -------------------------------------------------*/

void VEtransform_3D_points( matrix, num_points, points, weights )

	IGRdouble matrix[4][4];
	IGRint    num_points;
	IGRdouble *points;
	IGRdouble *weights;
	
/*
NAME
	VEtransform_3D_points

DESCRIPTION
	This function transforms an array of points, weighted or
	unweighted, using the given matrix.
	
PARAMETERS
	matrix (IN) - the matrix to use for the transformation
	num_points (IN) - the number of points to transform
	points (IN/OUT) - the points to transform
	weight (IN) - the weights for the points (NULL, if no weights)

GLOBALS USED
	none

HISTORY
	12/05/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    ii;
	IGRdouble *pt_ptr;
	IGRdouble new_x, new_y, new_z;

	pt_ptr = points;

	if ( weights )
	   {
	   for ( ii = 0; ii < num_points; ii++ )
	      {
	      new_x = (matrix[0][0] * pt_ptr[0]) +
	              (matrix[0][1] * pt_ptr[1]) +
	              (matrix[0][2] * pt_ptr[2]);

	      new_y = (matrix[1][0] * pt_ptr[0]) +
	              (matrix[1][1] * pt_ptr[1]) +
	              (matrix[1][2] * pt_ptr[2]);

	      new_z = (matrix[2][0] * pt_ptr[0]) +
	              (matrix[2][1] * pt_ptr[1]) +
	              (matrix[2][2] * pt_ptr[2]);

	      *pt_ptr++ = new_x + matrix[0][3] * weights[ii];
	      *pt_ptr++ = new_y + matrix[1][3] * weights[ii];
	      *pt_ptr++ = new_z + matrix[2][3] * weights[ii];

	      }  /* end: for */

	   }
	else
	   {
	   for ( ii = 0; ii < num_points; ii++ )
	      {
	      new_x = (matrix[0][0] * pt_ptr[0]) +
	              (matrix[0][1] * pt_ptr[1]) +
	              (matrix[0][2] * pt_ptr[2]) +
	              matrix[0][3];

	      new_y = (matrix[1][0] * pt_ptr[0]) +
	              (matrix[1][1] * pt_ptr[1]) +
	              (matrix[1][2] * pt_ptr[2]) +
	              matrix[1][3];

	      new_z = (matrix[2][0] * pt_ptr[0]) +
	              (matrix[2][1] * pt_ptr[1]) +
	              (matrix[2][2] * pt_ptr[2]) +
	              matrix[2][3];

	      *pt_ptr++ = new_x;
	      *pt_ptr++ = new_y;
	      *pt_ptr++ = new_z;

	      }  /* end: for */

	   }  /* end: else */

	}  /* VEtransform_3D_points */
	

/*--- VEtransform_dit_range_to_view_range ------------------------------------------*/

static void VEtransform_dit_range_to_view_range(
   IGRdouble *range )
	
/*
NAME
	VEtransform_dit_range_to_view_range (static)

DESCRIPTION
	This function takes the diagonal of a range box in DITS and calculates
	the diagonal of the range box in unscaled view coordinates by taking
	the diagonal of the DIT based range box and transforming it to world
	coordinates and then back to unscaled view coordinates.
	
PARAMETERS
	range (IN/OUT) - the range to transform

GLOBALS USED
	viewport_to_world (static)
	VEwin_info

HISTORY
	01/06/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    i;
	IGRdouble temp;

	/* transform diagonal from DITS to world coordinates */
	VEtransform_3D_points( viewport_to_world, 2, range, (IGRdouble *) NULL );
	  
	/* transform diagonal from world to unscaled viewing coordinates */
	VEtransform_3D_points( VEwin_info.VEt_matrix, 2, range, (IGRdouble *) NULL );

	/* re-order so that mins and maxs are in the right places */
	for ( i = 0; i < 3; i++ )
	   {
	   if ( range[i] > range[i+3] )
	      {
	      temp = range[i];
	      range[i] = range[i+3];
	      range[i+3] = temp;
	      }
	   }  /* end: for */

	}  /* VEtransform_dit_range_to_view_range */

		
/*--- VEsetup_window_clip_range -------------------------------------------------*/

static void VEsetup_window_clip_range(
   IGRdouble act_z )

/*
NAME
	VEsetup_window_clip_range (static)

DESCRIPTION
	This function determines the clipping range and active Z for
	the window.

PARAMETERS
	act_z (IN) - the active Z of the window

GLOBALS USED
	VEwin_info

HISTORY
	12/05/88    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRint    i;
	
        for ( i = 0; i < 6; i++ )
	   VEwin_info.clip_range[i] = dit_clip_range[i];

	VEtransform_dit_range_to_view_range( VEwin_info.clip_range );
	   
	active_z = - act_z;   /* Z's are flipped */

	}  /* VEsetup_window_clip_range */


/*--- VEassign_clipping_planes_from_range -------------------------------------------------*/

void VEassign_clipping_planes_from_range( clip_planes, range )

	struct VEplane *clip_planes;
	IGRdouble      *range;
	
/*
NAME
	VEassign_clipping_planes_from_range

DESCRIPTION
	This function sets the clipping planes from a range box that is
	assumed to be in the viewing coordinate system.

PARAMETERS
	clip_planes (IN) - array of clipping planes
	range (IN) - the range to use

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint ii;

	/* initialize points and normals to ZERO */
	for ( ii = 0; ii < 6; ii++ )
	   {
	   clip_planes[ii].point[0] = clip_planes[ii].point[1] = clip_planes[ii].point[2] = 0.0;
	   clip_planes[ii].normal[0] = clip_planes[ii].normal[1] = clip_planes[ii].normal[2] = 0.0;
	   }

	clip_planes[0].point[0] = range[0];  /* Min X */
	clip_planes[0].normal[0] = 1.0;

	clip_planes[1].point[1] = range[1];  /* Min Y */
	clip_planes[1].normal[1] = 1.0;

	clip_planes[2].point[2] = range[2];  /* Min Z */
	clip_planes[2].normal[2] = 1.0;

	clip_planes[3].point[0] = range[3];  /* Max X */
	clip_planes[3].normal[0] = -1.0;

	clip_planes[4].point[1] = range[4];  /* Max Y */
	clip_planes[4].normal[1] = -1.0;

	clip_planes[5].point[2] = range[5];  /* Max Z */
	clip_planes[5].normal[2] = -1.0;

	}  /* VEassign_clipping_planes_from_range */


/*--- VEdetermine_clipping_planes -------------------------------------------------*/

void VEdetermine_clipping_planes( struct VEenv_info *env,
				  IGRboolean        is_master_env )
	
/*
NAME
	VEdetermine_clipping_planes

DESCRIPTION
	This function determines the clipping planes for an environment. The
	normals for the planes will point in the direction of visibility and
	will be normalized.

	   If the environment is the master file environment (indicated by 
	   is_master_env  set to TRUE), the clipping planes are set to be the
	   intersection of the window's volume and the volume defined by the
	   fence if a fence exists in the window.  If the environment is not
	   the master file environment, a function is called to get the range 
	   cube of the nested clipping planes for the environment.  This volume
	   is intersected with the window's volume and the fence volume to
	   determine the actual clipping planes.
	   
PARAMETERS
	env (IN) - the environment whose clipping planes are to be set
	is_master_env (IN) - TRUE, if the environment is for the master file

GLOBALS USED
	VEwin_info

HISTORY
	01/04/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong        msg;
	IGRdouble      ref_range[6];
	GRspacenum     osnum;
	struct VEplane *clip_planes;
	
	clip_planes = env->clip_planes;

	if ( is_master_env )
	   {
	   /* this is the master environment => set clipping planes */
	   /* to be the concatenation of the window range and the   */
	   /* fence range if a fence exists. This concatentation is */
	   /* stored in VEwin_info.clip_range                       */
	   
	   VEassign_clipping_planes_from_range( clip_planes, VEwin_info.clip_range );

	   }
	else
	   {
	   /* not the master environment => get the nested clipping planes */
	   /* for this environment and take the intersection of them with  */
	   /* the window clipping range (i.e., the intersecton of the      */
	   /* window and fence clipping ranges                             */
	   osnum = env->osnum;
	   GRgetrefrange( &msg,
	                  &osnum,
	                  &env->matrix_type,
	                  env->matrix,
	                  dit_clip_range,
	                  (IGRdouble *)world_to_viewport,
	                  ref_range );
	   	                
	   /* GRgetrefrange gives the clipping range in DITS, transform it */
	   /* to viewing coordinates so we can use it                      */
	   VEtransform_dit_range_to_view_range( ref_range );
	   
	   /* intersect ref. range with window clipping range */
	   if (ref_range[0] < VEwin_info.clip_range[0])
	      ref_range[0] = VEwin_info.clip_range[0];
	   if (ref_range[1] < VEwin_info.clip_range[1])
	      ref_range[1] = VEwin_info.clip_range[1];
	   if (ref_range[2] < VEwin_info.clip_range[2])
	      ref_range[2] = VEwin_info.clip_range[2];

	   if (ref_range[3] > VEwin_info.clip_range[3])
	      ref_range[3] = VEwin_info.clip_range[3];
	   if (ref_range[4] > VEwin_info.clip_range[4])
	      ref_range[4] = VEwin_info.clip_range[4];
	   if (ref_range[5] > VEwin_info.clip_range[5])
	      ref_range[5] = VEwin_info.clip_range[5];
	   
	   VEassign_clipping_planes_from_range( clip_planes, ref_range );
	   }

	}  /* VEdetermine_clipping_planes */

	
/*--- VEset_transformations -------------------------------------------------*/

IGRboolean VEset_transformations( gra_gad )

	struct DPgra_gad *gra_gad;

/*
NAME
	VEset_transformations

DESCRIPTION
	Copies (while making the necessary changes) the transformation and 
	and inverse matrix to the local matrices.

PARAMETERS
	gra_gad (IN) - pointer to graphic gadget instance data of the gragad
	               that is having VE run

GLOBALS USED
	world_to_viewport, viewport_to_world, dit_clip_range (static)
	VEwin_info

HISTORY
	02/20/87    S.A. Rapa
	   Created
	12/05/88    S.P. Rogers
	   Changed to use wld_to_view matrix which has no scaling
*/


	{
	IGRlong  msg;
	IGRshort dim;
	IGRint   row, col;

	/* save dit_clip_range, world_to_viewport, viewport_to_world and rotation */
	memcpy( dit_clip_range, gra_gad->dit_clip_range, sizeof( IGRdouble ) * 6 );

	memcpy( (char *) world_to_viewport, (char *) gra_gad->wld_to_viewport, sizeof( IGRdouble ) * 16 );
	memcpy( (char *) viewport_to_world, (char *) gra_gad->viewport_to_wld, sizeof( IGRdouble ) * 16 ); 
	memcpy( (char *) VEwin_info.VErot_matrix, (char *) gra_gad->rotation, sizeof( IGRdouble ) * 16 );

	/* Transformation matrix ... use the world to view matrix */
	/* which has no scaling and negate Z's                    */
	for (row = 0; row < 3; row++)
	   for (col = 0; col < 4; col++)
	      VEwin_info.VEt_matrix[row][col] = gra_gad->wld_to_view[row][col];

	for ( col = 0; col < 4; col++ )
	   VEwin_info.VEt_matrix[2][col] = -VEwin_info.VEt_matrix[2][col];

	VEwin_info.VEt_matrix[3][0] = 0.0;
	VEwin_info.VEt_matrix[3][1] = 0.0;
	VEwin_info.VEt_matrix[3][2] = 0.0;
	VEwin_info.VEt_matrix[3][3] = 1.0;

	/* Inverse matrix. */
	dim = 4;
	MAinvmx( &msg, &dim, (IGRdouble *)VEwin_info.VEt_matrix, 
				(IGRdouble *)i_matrix );

	/* save view vector */
	VEwin_info.VEview_vector[0] = gra_gad->rotation[2][0];
	VEwin_info.VEview_vector[1] = gra_gad->rotation[2][1];
	VEwin_info.VEview_vector[2] = gra_gad->rotation[2][2];

	/* setup clipping range for window */
	VEsetup_window_clip_range( gra_gad->act_z );

	return (TRUE);

	}  /* VEset_transformations */


/*--- VEget_range -----------------------------------------------------------*/

void VEget_range( IGRint    num_poles,
		  IGRdouble *poles,
		  IGRdouble *weights,
		  IGRdouble *range,
		  IGRboolean transform )

/*
NAME
	VEget_range

DESCRIPTION
	Returns the range of a list of poles after they have been
	transformed to the view.

PARAMETERS
	num_poles (IN) - number of poles
	poles (IN) - array of poles
	weights (IN) - array of weights (NULL, if no weights)
	range (OUT) - range of the poles
	transform (IN) - if TRUE, poles are transformed to the view

GLOBALS USED
	VEwin_info

HISTORY
	04/29/87    S.A. Rapa
	   Created
*/
 
	{
	IGRint    ii;
	IGRdouble new_poles[3],
	          new_x, new_y, new_z;

	range[0] =  1.0E100;
	range[1] =  1.0E100;
	range[2] =  1.0E100;
	range[3] = -1.0E100;
	range[4] = -1.0E100;
	range[5] = -1.0E100;
	for (ii = 0; ii < num_poles; ii++)
	   {
	   /* Unweight the poles */
	   if (weights)
	      {
	      new_poles[0] = *poles++ / weights[ii];
	      new_poles[1] = *poles++ / weights[ii];
	      new_poles[2] = *poles++ / weights[ii];
	      }
	   else
	      {
	      new_poles[0] = *poles++;
	      new_poles[1] = *poles++;
	      new_poles[2] = *poles++;
	      }

	   if ( transform )
	      {
	      /* Transform the 3D points */
	      new_x = (VEwin_info.VEt_matrix[0][0] * new_poles[0]) +
	              (VEwin_info.VEt_matrix[0][1] * new_poles[1]) +
	              (VEwin_info.VEt_matrix[0][2] * new_poles[2]) +
	              (VEwin_info.VEt_matrix[0][3]);
	      new_y = (VEwin_info.VEt_matrix[1][0] * new_poles[0]) +
	              (VEwin_info.VEt_matrix[1][1] * new_poles[1]) +
	              (VEwin_info.VEt_matrix[1][2] * new_poles[2]) +
	              (VEwin_info.VEt_matrix[1][3]);
	      new_z = (VEwin_info.VEt_matrix[2][0] * new_poles[0]) +
	              (VEwin_info.VEt_matrix[2][1] * new_poles[1]) +
	              (VEwin_info.VEt_matrix[2][2] * new_poles[2]) +
	              (VEwin_info.VEt_matrix[2][3]);
	      }
	   else
	      {
	      new_x = new_poles[0];
	      new_y = new_poles[1];
	      new_z = new_poles[2];
	      }

	   /* Update range */
	   if (new_x < range[0]) range[0] = new_x;
	   if (new_y < range[1]) range[1] = new_y;
	   if (new_z < range[2]) range[2] = new_z;
	   if (new_x > range[3]) range[3] = new_x;
	   if (new_y > range[4]) range[4] = new_y;
	   if (new_z > range[5]) range[5] = new_z;

	   }  /* end: for */

	}  /* VEget_range */


/*--- VEset_fence_clip  -----------------------------------------------------*/

void VEset_fence_clip( fence )

	struct IGRbsp_curve *fence;

/*
NAME
	VEset_fence_clip

DESCRIPTION
	Accepts a curve defining a fence & updates the clipping planes
	based on the XY range of the fence's poles.

PARAMETERS
	fence (IN) - curve representing the fence

GLOBALS USED
	VEwin_info

HISTORY
	05/21/87    S.A. Rapa
	   Created.
*/


	{
	IGRdouble range[6];

	if (! (fence->rational))
	   fence->weights = NULL;

	VEget_range( (IGRint)fence->num_poles, fence->poles, fence->weights, range, TRUE );

	if (range[0] > VEwin_info.clip_range[0])
	   VEwin_info.clip_range[0] = range[0];
	if (range[1] > VEwin_info.clip_range[1])
	   VEwin_info.clip_range[1] = range[1];
	if (range[3] < VEwin_info.clip_range[3])
	   VEwin_info.clip_range[3] = range[3];
	if (range[4] < VEwin_info.clip_range[4])
	   VEwin_info.clip_range[4] = range[4];

	}  /* VEset_fence_clip */


/*--- VEtrans_curve_to_view -------------------------------------------------------*/

void VEtrans_curve_to_view( curve )

	struct IGRbsp_curve *curve;
	
/*
NAME
	VEtrans_curve_to_view

DESCRIPTION
	This function transforms a curve to viewing coordinates.
	
PARAMETERS
	curve (IN) - the curve to transform

GLOBALS USED
	VEwin_info

HISTORY
	04/18/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    i;
	IGRdouble *poles, *weights;
	IGRdouble x, y, z;

	poles = (IGRdouble *) curve->poles;
	
	weights = (curve->rational) ? curve->weights : NULL;
	
	for ( i = 0; i < curve->num_poles; i++ )
	   {
	   x = (VEwin_info.VEt_matrix[0][0] * poles[0]) +
	       (VEwin_info.VEt_matrix[0][1] * poles[1]) +
	       (VEwin_info.VEt_matrix[0][2] * poles[2]);
	   y = (VEwin_info.VEt_matrix[1][0] * poles[0]) +
	       (VEwin_info.VEt_matrix[1][1] * poles[1]) +
	       (VEwin_info.VEt_matrix[1][2] * poles[2]);
	   z = (VEwin_info.VEt_matrix[2][0] * poles[0]) +
	       (VEwin_info.VEt_matrix[2][1] * poles[1]) +
	       (VEwin_info.VEt_matrix[2][2] * poles[2]);

	   if ( weights )
	      {
	      *poles++ = x + (VEwin_info.VEt_matrix[0][3] * *weights);
	      *poles++ = y + (VEwin_info.VEt_matrix[1][3] * *weights);
	      *poles++ = z + (VEwin_info.VEt_matrix[2][3] * *weights);
	      weights++;
	      }
	   else
	      {
	      *poles++ = x + VEwin_info.VEt_matrix[0][3];
	      *poles++ = y + VEwin_info.VEt_matrix[1][3];
	      *poles++ = z + VEwin_info.VEt_matrix[2][3];
	      }

	   }  /* end: for */

	}  /* VEtrans_curve_to_view */
	

/*--- VEcopy_and_trans_to_view -------------------------------------------------------*/

IGRboolean VEcopy_and_trans_to_view( char    **geom,
				     IGRint  type )

/*
NAME
	VEcopy_and_trans_to_view

DESCRIPTION
	Copies and transforms a surface/curve to viewing coordinates.

PARAMETERS
	geom (IN/OUT) - the geometry to copy and transform
	type (IN) - the type of geometry, CURVE or SURFACE

RETURN VALUES
	TRUE,  if all goes well
	FALSE, if there is an error.

GLOBALS USED
	VEwin_info

HISTORY
	02/19/87    S.A. Rapa
	   Created
	04/30/87    S.A. Rapa
	   No longer returns transformed range
*/

	{
	IGRlong   ii;
	IGRdouble *old_poles, *new_poles;
	IGRint    num_poles;
	IGRdouble *weights;
	IGRlong   rc;

	if ( type == SURFACE )
	   {
	   struct IGRbsp_surface *old_surf;
	   struct IGRbsp_surface *new_surf;

	   old_surf = (struct IGRbsp_surface *) (*geom);

	   /* allocate space for surface copy */
	   BSallocsf( old_surf->u_order, old_surf->v_order,
	              old_surf->u_num_poles, old_surf->v_num_poles,
	              old_surf->rational,
	              0,				/* number of boundaries */
	              &new_surf,
	              &rc );

	   if ( rc != BSSUCC )
	      {
	      fprintf( stderr, "VEcopy_and_trans_to_view: Alloc Error\n" );
	      return( FALSE );
	      }

	   new_poles = new_surf->poles;
	   old_poles = old_surf->poles;
	   num_poles = old_surf->u_num_poles * old_surf->v_num_poles;

	   /* copy old surface to new surface */
	   BSsf_copy( &rc, old_surf, new_surf );

	   new_surf->num_boundaries = old_surf->num_boundaries;
	   new_surf->bdrys          = old_surf->bdrys;
	   *geom                    = (IGRchar *) new_surf;
      
	   /* Because our transformation to viewing coordinates   */
	   /* involves a change from a right-handed coordinate    */
	   /* system to a left-handed one (essentially a mirror), */
	   /* we must invert the pos_orient flag                  */
	   new_surf->pos_orient = ! new_surf->pos_orient;

	   if ( new_surf->rational )
	      weights = new_surf->weights;
	   else
	      weights = (IGRdouble *) 0;
	   }

	else
	   {
	   struct IGRbsp_curve *old_curve;
	   struct IGRbsp_curve *new_curve;

	   old_curve = (struct IGRbsp_curve *) (*geom);

	   /* allocate space for curve copy */
	   BSalloccv( old_curve->order, old_curve->num_poles,
	              old_curve->rational,
	              0,				/* number of boundaries */
	              &new_curve,
	              &rc );

	   if (rc != BSSUCC)
	      {
	      fprintf( stderr, "VEcopy_and_trans_to_view: Alloc Error\n" );
 	      return( FALSE );
	      }

	   new_poles = new_curve->poles;
	   old_poles = old_curve->poles;
	   num_poles = old_curve->num_poles;

	   /* copy old curve to new curve */
	   BScv_copy( &rc, old_curve, new_curve );

	   *geom = (IGRchar *) new_curve;

	   if ( new_curve->rational )
	      weights = new_curve->weights;
	   else
	      weights = (IGRdouble *) 0;
	   }

	/* Transform the poles */
	for ( ii = 0; ii < num_poles; ii++ )
	   {
	   new_poles[0] = (VEwin_info.VEt_matrix[0][0] * old_poles[0]) +
	                  (VEwin_info.VEt_matrix[0][1] * old_poles[1]) +
	                  (VEwin_info.VEt_matrix[0][2] * old_poles[2]);
	   new_poles[1] = (VEwin_info.VEt_matrix[1][0] * old_poles[0]) +
	                  (VEwin_info.VEt_matrix[1][1] * old_poles[1]) +
	                  (VEwin_info.VEt_matrix[1][2] * old_poles[2]);
	   new_poles[2] = (VEwin_info.VEt_matrix[2][0] * old_poles[0]) +
	                  (VEwin_info.VEt_matrix[2][1] * old_poles[1]) +
	                  (VEwin_info.VEt_matrix[2][2] * old_poles[2]);

	   if ( weights )
	      {
	      new_poles[0] += (VEwin_info.VEt_matrix[0][3] * weights[ii]);
	      new_poles[1] += (VEwin_info.VEt_matrix[1][3] * weights[ii]);
	      new_poles[2] += (VEwin_info.VEt_matrix[2][3] * weights[ii]);
	      }
	   else
	      {
	      new_poles[0] += VEwin_info.VEt_matrix[0][3];
	      new_poles[1] += VEwin_info.VEt_matrix[1][3];
	      new_poles[2] += VEwin_info.VEt_matrix[2][3];
	      }

	   old_poles += 3;
	   new_poles += 3;

	   }  /* end: for */

	return( TRUE );

	}  /* VEcopy_and_trans_to_view */
	

/*--- VEtrans_to_world ------------------------------------------------------*/

void VEtrans_to_world( geom, type )


	IGRchar *geom;
	IGRint  type;

/*
NAME
	VEtrans_to_world

DESCRIPTION
	Transforms a surface/curve to world coordinates using the
	matrix already setup projecting to the active Z as part of 
	the transformation.

PARAMETERS
	geom (IN) - the geometry to transform
	type (IN) - the type of geometry, SURFACE or CURVE

GLOBALS USED
	i_matrix (static)

HISTORY
	02/19/87    S.A. Rapa
	   Created
	12/18/89    S.P. Rogers
	   Added ability to transform surfaces
*/

	{
	IGRlong   ii, num_poles;
	IGRdouble new_x, new_y, new_z;
	IGRdouble *poles, *weights;

	if ( type == SURFACE )
	   {
	   struct IGRbsp_surface *surf;

	   surf = (struct IGRbsp_surface *) geom;

	   num_poles = surf->u_num_poles * surf->v_num_poles;
	   poles = surf->poles;
	   weights = (surf->rational) ? surf->weights : NULL;
	   }
	else
	   {
	   struct IGRbsp_curve *curve;

	   curve = (struct IGRbsp_curve *) geom;

	   num_poles = curve->num_poles;
	   poles = curve->poles;
	   weights = (curve->rational) ? curve->weights : NULL;
	   }

	for ( ii = 0; ii < num_poles; ii++ )
	   {
	   if ( VEoutput_data.output_2d )
	      {
	      /* flatten curve to active Z of the window */
	      if (  weights )
	         poles[2] = active_z * weights[ii];
	      else
	         poles[2] = active_z;
	      }

	   /* Transform 3D points */
	   new_x = (i_matrix[0][0] * poles[0]) +
	           (i_matrix[0][1] * poles[1]) +
	           (i_matrix[0][2] * poles[2]);
	   new_y = (i_matrix[1][0] * poles[0]) +
	           (i_matrix[1][1] * poles[1]) +
	           (i_matrix[1][2] * poles[2]);
	   new_z = (i_matrix[2][0] * poles[0]) +
	           (i_matrix[2][1] * poles[1]) +
	           (i_matrix[2][2] * poles[2]);

	   if ( weights )
	      {
	      new_x += i_matrix[0][3] * weights[ii];
	      new_y += i_matrix[1][3] * weights[ii];
	      new_z += i_matrix[2][3] * weights[ii];
	      }       	
	   else
	      {
	      new_x += i_matrix[0][3];
	      new_y += i_matrix[1][3];
	      new_z += i_matrix[2][3];
	      }

	   *poles++ = new_x;
	   *poles++ = new_y;
	   *poles++ = new_z;

	   }  /* end: for */

	}  /* VEtrans_to_world */


/*--- VEtrans_to_world_without_projecting ------------------------------------------------------*/

void VEtrans_to_world_without_projecting( geom, type )


	IGRchar *geom;
	IGRint  type;

/*
NAME
	VEtrans_to_world_without_projecting

DESCRIPTION
	Transforms a surface/curve to world coordinates using the
	matrix already setup with projecting to the active Z.

PARAMETERS
	geom (IN) - the geometry to transform
	type (IN) - the type of geometry, SURFACE or CURVE

GLOBALS USED
	i_matrix (static)

HISTORY
	12/18/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong   ii, num_poles;
	IGRdouble new_x, new_y, new_z;
	IGRdouble *poles, *weights;

	if ( type == SURFACE )
	   {
	   struct IGRbsp_surface *surf;

	   surf = (struct IGRbsp_surface *) geom;

	   num_poles = surf->u_num_poles * surf->v_num_poles;
	   poles = surf->poles;
	   weights = (surf->rational) ? surf->weights : NULL;
	   }
	else
	   {
	   struct IGRbsp_curve *curve;

	   curve = (struct IGRbsp_curve *) geom;

	   num_poles = curve->num_poles;
	   poles = curve->poles;
	   weights = (curve->rational) ? curve->weights : NULL;
	   }

	for ( ii = 0; ii < num_poles; ii++ )
	   {
	   /* Transform 3D points */
	   new_x = (i_matrix[0][0] * poles[0]) +
	           (i_matrix[0][1] * poles[1]) +
	           (i_matrix[0][2] * poles[2]);
	   new_y = (i_matrix[1][0] * poles[0]) +
	           (i_matrix[1][1] * poles[1]) +
	           (i_matrix[1][2] * poles[2]);
	   new_z = (i_matrix[2][0] * poles[0]) +
	           (i_matrix[2][1] * poles[1]) +
	           (i_matrix[2][2] * poles[2]);

	   if ( weights )
	      {
	      new_x += i_matrix[0][3] * weights[ii];
	      new_y += i_matrix[1][3] * weights[ii];
	      new_z += i_matrix[2][3] * weights[ii];
	      }       	
	   else
	      {
	      new_x += i_matrix[0][3];
	      new_y += i_matrix[1][3];
	      new_z += i_matrix[2][3];
	      }

	   *poles++ = new_x;
	   *poles++ = new_y;
	   *poles++ = new_z;

	   }  /* end: for */

	}  /* VEtrans_to_world_without_projecting */


/*--- VEget_curve_points_in_dits ----------------------------------------------*/

void VEget_curve_points_in_dits( curve, end_pt0, end_pt1 )

	struct IGRbsp_curve *curve;
	IGRdouble           end_pt0[3];
	IGRdouble           end_pt1[3];

/*
NAME
	VEget_curve_points_in_dits

DESCRIPTION
	This function takes a curve in world coordinates and returns its
	endpoints in dits.

PARAMETERS
	curve (IN) - the curve whose endpoints are to be found in dits
	end_pt0 (OUT) - start point of in dits
	end_pt1 (OUT) - end point of curve in dits

GLOBALS USED
	world_to_viewport

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint num_poles_minus_one;

	num_poles_minus_one = curve->num_poles - 1;

	end_pt0[0] = curve->poles[0];
	end_pt0[1] = curve->poles[1];
	end_pt0[2] = curve->poles[2];

	end_pt1[0] = curve->poles[num_poles_minus_one*3];
	end_pt1[1] = curve->poles[num_poles_minus_one*3 + 1];
	end_pt1[2] = curve->poles[num_poles_minus_one*3 + 2];

	if ( curve->rational )
	   {
	   end_pt0[0] /= curve->weights[0];
	   end_pt0[1] /= curve->weights[0];
	   end_pt0[2] /= curve->weights[0];

	   end_pt1[0] /= curve->weights[num_poles_minus_one];
	   end_pt1[1] /= curve->weights[num_poles_minus_one];
	   end_pt1[2] /= curve->weights[num_poles_minus_one];
	   }

	VEtransform_3D_points( world_to_viewport, 1, end_pt0, (IGRdouble *) NULL );
	VEtransform_3D_points( world_to_viewport, 1, end_pt1, (IGRdouble *) NULL );

	}  /* VEget_curve_points_in_dits */

/*--- VDve_set_transformations -----------------------------------------*/

IGRboolean VDve_set_transformations( IGRdouble VDdit_clip_range[6],
                                     IGRdouble VDwld_to_viewport[4][4],
                                     IGRdouble VDviewport_to_wld[4][4],
                                     IGRdouble VDrotation[4][4],
                                     IGRdouble VDwld_to_view[4][4],
                                     IGRdouble VDact_z )
/*
NAME
        VDve_set_transformations

DESCRIPTION
        Copies (while making the necessary changes) the transformation
        and inverse matrix to the local matrices.  This entry point was
        added to enable VDS-specific VE processing; it was added in this
        file due to the reliance on static variables (e.g., i_matrix).

PARAMETERS
        VDdit_clip_range (IN) - equivalent of gragad's dit clip range in
                                screen units relative to the window origin
        VDwld_to_viewport (IN) - equivalent of gragad's world-to-viewport
                                 transformation matrix
        VDviewport_to_wld (IN) - equivalent of gragad's viewport-to-world
                                 transformation matrix
        VDrotation (IN) - equivalent of gragad's view rotation matrix
        VDwld_to_view (IN) - equivalent of gragad's viewport-to-view
                                 transformation matrix
        VDact_z (IN) - equivalent of gragad's active z in the viewing
                       coordinate system
GLOBALS USED
        world_to_viewport, viewport_to_world, dit_clip_range (static)
        VEwin_info

HISTORY
        03/06/95  dh  Created
*/
{
   IGRlong msg;
   IGRshort dim;
   IGRint row, col;

   /* save dit_clip_range and transformation matrices */
   memcpy( dit_clip_range, VDdit_clip_range, sizeof( IGRdouble ) * 6 );
   memcpy( ( char * ) world_to_viewport, ( char * ) VDwld_to_viewport,
           sizeof( IGRdouble ) * 16 );
   memcpy( ( char * ) viewport_to_world, ( char * ) VDviewport_to_wld,
           sizeof( IGRdouble ) * 16 );
   memcpy( ( char * ) VEwin_info.VErot_matrix, ( char * ) VDrotation,
           sizeof( IGRdouble ) * 16 );

   /* Transformation matrix ... use the world to view matrix, which has */
   /* no scaling and negate Z's */
   for ( row = 0; row < 3; row++ )
      for ( col = 0; col < 4; col++ )
         VEwin_info.VEt_matrix[row][col] = VDwld_to_view[row][col];

   for ( col = 0; col < 4; col++ )
      VEwin_info.VEt_matrix[2][col] = -VEwin_info.VEt_matrix[2][col];

   VEwin_info.VEt_matrix[3][0] = 0.0;
   VEwin_info.VEt_matrix[3][1] = 0.0;
   VEwin_info.VEt_matrix[3][2] = 0.0;
   VEwin_info.VEt_matrix[3][3] = 1.0;

   /* Inverse matrix */
   dim = 4;
   MAinvmx( &msg, &dim, ( IGRdouble * ) VEwin_info.VEt_matrix,
            ( IGRdouble * ) i_matrix );

   /* save view vector */
   VEwin_info.VEview_vector[0] = VDrotation[2][0];
   VEwin_info.VEview_vector[1] = VDrotation[2][1];
   VEwin_info.VEview_vector[2] = VDrotation[2][2];

   /* setup clipping range for window */
   VEsetup_window_clip_range( VDact_z );

   return ( TRUE );

}/* VDve_set_transformations */
